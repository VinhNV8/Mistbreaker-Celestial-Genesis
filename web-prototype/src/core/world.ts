import { MONSTERS, type MonsterAttack, type MonsterKind } from '../data/monsters';
import { getTalent, type TalentDef } from '../data/talents';
import {
  BOSS_LEVEL_REQ,
  EXPLORE_REQ,
  FREE_RESPEC_LEVEL,
  MAX_FIELD_MOBS,
  MAX_LEVEL,
  POINTS_PER_LEVEL,
  TORCH_MAX,
} from './config';
import * as explore from './explore';
import { comboExpMultiplier, computeDamage, expToNext, mobExp } from './formulas';
import type { Profile } from './profile';
import type { Rng } from './rng';
import { deriveStats, type DerivedStats, type StatKey } from './stats';

export const WORLD_W = 2600;
export const WORLD_H = 1600;
export const VILLAGE = { x: 230, y: 800, r: 170 };
export const ARENA = { x: 2290, y: 800, r: 270 };
/** Bức tường sương mù chắn lối vào hang Sói Chúa khi chưa đủ điều kiện. */
export const GATE_X = ARENA.x - ARENA.r - 60;

export const PLAYER_RADIUS = 16;
export const SLASH_RANGE = 80;
export const SPIN_RANGE = 125;
export const POUNCE_RADIUS = 80;
export const SKILL_CD = 6;
export const DODGE_CD = 3;
export const TALENT_CD = 90;

const SLASH_ARC = Math.PI / 3;
const SLASH_INTERVAL = 0.5;
const SPIN_MUL = 1.8;
/** Né lăn: 0,3 giây bất tử (tài liệu mục 5). */
const DODGE_TIME = 0.3;
const DODGE_SPEED = 760;
const FREEZE_TIME = 3;
const RESPAWN_TIME = 2.5;
const COMBO_TIMEOUT = 5;
const BOSS_LEVEL = 6;
const BOSS_POISE = 600;
const BOSS_STUN = 5;
const BOSS_EXP = 1500;
const BOSS_GOLD = 300;

export interface Input {
  moveX: number;
  moveY: number;
  aimX: number;
  aimY: number;
  attack: boolean;
  skill: boolean;
  talent: boolean;
  dodge: boolean;
}

export interface Player {
  x: number;
  y: number;
  hp: number;
  facing: number;
  attackCd: number;
  skillCd: number;
  talentCd: number;
  dodgeCd: number;
  dodgeTime: number;
  dodgeDx: number;
  dodgeDy: number;
  swing: number;
  swingKind: 'slash' | 'spin';
  hits: number;
  hurt: number;
  deadTimer: number;
}

export type EnemyState = 'idle' | 'chase' | 'windup' | 'recover' | 'stunned';
export type AttackKind = MonsterAttack | 'pounce';
export type EnemyRole = 'field' | 'nestGuard' | 'nestMinion' | 'bossMinion' | 'boss';

export interface Enemy {
  id: number;
  kind: MonsterKind;
  role: EnemyRole;
  name: string;
  level: number;
  elite: boolean;
  x: number;
  y: number;
  homeX: number;
  homeY: number;
  wanderX: number;
  wanderY: number;
  hp: number;
  maxHp: number;
  atk: number;
  def: number;
  speed: number;
  radius: number;
  range: number;
  state: EnemyState;
  timer: number;
  windupTotal: number;
  attackKind: AttackKind;
  targetX: number;
  targetY: number;
  hitFlash: number;
  dead: boolean;
  nestTileId: number | null;
  poise: number;
  maxPoise: number;
  broken: boolean;
  phase: number;
  pounceCd: number;
}

export interface Projectile {
  x: number;
  y: number;
  vx: number;
  vy: number;
  ttl: number;
  atk: number;
  radius: number;
}

export interface Pickup {
  x: number;
  y: number;
  kind: 'gold' | 'orb';
  value: number;
  ttl: number;
}

export interface FloatText {
  x: number;
  y: number;
  text: string;
  color: string;
  ttl: number;
  big: boolean;
}

export type Tone = 'info' | 'good' | 'bad';

export type GameEvent =
  | { type: 'message'; text: string; tone: Tone }
  | { type: 'levelup'; level: number }
  | { type: 'death' }
  | { type: 'victory' }
  | { type: 'tile'; tileId: number };

const clamp = (v: number, lo: number, hi: number): number => Math.min(hi, Math.max(lo, v));
const dist = (ax: number, ay: number, bx: number, by: number): number => Math.hypot(ax - bx, ay - by);

function angleDiff(a: number, b: number): number {
  let d = (a - b) % (Math.PI * 2);
  if (d > Math.PI) d -= Math.PI * 2;
  if (d < -Math.PI) d += Math.PI * 2;
  return d;
}

/** Cấp quái tăng dần từ làng (trái) về phía hang Sói Chúa (phải). */
export function zoneLevel(x: number): number {
  return clamp(1 + Math.floor((x - 450) / 260), 1, 6);
}

export class World {
  readonly player: Player;
  enemies: Enemy[] = [];
  projectiles: Projectile[] = [];
  pickups: Pickup[] = [];
  texts: FloatText[] = [];
  stats: DerivedStats;
  freezeTimer = 0;
  combo = 0;
  time = 0;

  private events: GameEvent[] = [];
  private comboTimer = 0;
  private nextId = 1;
  private spawnTimer = 0;
  private gateMsgCd = 0;
  private passiveMsgCd = 0;

  constructor(
    readonly profile: Profile,
    private readonly rng: Rng = Math.random,
  ) {
    this.stats = deriveStats(profile.level, profile.points, profile.talent);
    this.player = {
      x: VILLAGE.x + 60,
      y: VILLAGE.y,
      hp: this.stats.maxHp,
      facing: 0,
      attackCd: 0,
      skillCd: 0,
      talentCd: 0,
      dodgeCd: 0,
      dodgeTime: 0,
      dodgeDx: 0,
      dodgeDy: 0,
      swing: 0,
      swingKind: 'slash',
      hits: 0,
      hurt: 0,
      deadTimer: 0,
    };
    for (let i = 0; i < MAX_FIELD_MOBS; i++) this.spawnFieldMob();
  }

  get talent(): TalentDef {
    return getTalent(this.profile.talent);
  }

  get explored(): number {
    return explore.exploredRatio(this.profile.tiles);
  }

  get bossUnlocked(): boolean {
    return this.profile.bossDefeated || (this.profile.level >= BOSS_LEVEL_REQ && this.explored >= EXPLORE_REQ);
  }

  get boss(): Enemy | undefined {
    return this.enemies.find((e) => e.role === 'boss' && !e.dead);
  }

  drainEvents(): GameEvent[] {
    const out = this.events;
    this.events = [];
    return out;
  }

  /** Sói Chúa giai đoạn 2 ẩn trong sương mù, chỉ lộ khi vung đòn, bị choáng hoặc ở rất gần. */
  isHidden(e: Enemy): boolean {
    if (e.role !== 'boss' || e.phase < 2) return false;
    if (e.state === 'windup' || e.state === 'stunned') return false;
    return dist(e.x, e.y, this.player.x, this.player.y) > 140;
  }

  // ---------------------------------------------------------------- vòng lặp

  update(dt: number, input: Input): void {
    this.time += dt;
    this.profile.playSeconds += dt;
    this.tickTexts(dt);
    explore.tickProduction(this.profile, dt);
    if (explore.regenTorches(this.profile, dt) > 0) this.message('+1 Đuốc Khai Giới đã hồi.', 'info');

    const p = this.player;
    if (p.deadTimer > 0) {
      p.deadTimer -= dt;
      if (p.deadTimer <= 0) this.respawn();
      return;
    }

    p.attackCd -= dt;
    p.skillCd -= dt;
    p.talentCd -= dt;
    p.dodgeCd -= dt;
    p.swing -= dt;
    p.hurt -= dt;
    this.gateMsgCd -= dt;
    this.passiveMsgCd -= dt;
    this.comboTimer -= dt;
    if (this.comboTimer <= 0) this.combo = 0;

    p.facing = Math.atan2(input.aimY - p.y, input.aimX - p.x);
    this.movePlayer(dt, input);
    if (input.attack && p.attackCd <= 0 && p.dodgeTime <= 0) this.slash();
    if (input.skill && p.skillCd <= 0 && p.dodgeTime <= 0) this.spin();
    if (input.talent) this.useTalent();

    if (this.freezeTimer > 0) {
      this.freezeTimer -= dt;
    } else {
      for (const e of this.enemies) if (!e.dead) this.updateEnemy(e, dt);
      this.separateEnemies();
      this.updateProjectiles(dt);
    }
    this.updatePickups(dt);
    this.updateSpawning(dt);
    this.enemies = this.enemies.filter((e) => !e.dead);
  }

  // ---------------------------------------------------------------- người chơi

  private movePlayer(dt: number, input: Input): void {
    const p = this.player;
    if (input.dodge && p.dodgeCd <= 0 && p.dodgeTime <= 0) {
      let dx = input.moveX;
      let dy = input.moveY;
      const len = Math.hypot(dx, dy);
      if (len < 0.01) {
        dx = Math.cos(p.facing);
        dy = Math.sin(p.facing);
      } else {
        dx /= len;
        dy /= len;
      }
      p.dodgeDx = dx;
      p.dodgeDy = dy;
      p.dodgeTime = DODGE_TIME;
      p.dodgeCd = DODGE_CD;
    }

    let vx = 0;
    let vy = 0;
    if (p.dodgeTime > 0) {
      p.dodgeTime -= dt;
      vx = p.dodgeDx * DODGE_SPEED;
      vy = p.dodgeDy * DODGE_SPEED;
    } else {
      const len = Math.hypot(input.moveX, input.moveY);
      if (len > 0) {
        const s = this.stats.moveSpeed / Math.max(1, len);
        vx = input.moveX * s;
        vy = input.moveY * s;
      }
    }

    p.x = clamp(p.x + vx * dt, PLAYER_RADIUS, WORLD_W - PLAYER_RADIUS);
    p.y = clamp(p.y + vy * dt, PLAYER_RADIUS, WORLD_H - PLAYER_RADIUS);

    if (!this.bossUnlocked && p.x > GATE_X) {
      p.x = GATE_X;
      if (this.gateMsgCd <= 0) {
        this.message(
          `Sương mù Hư Vô chặn đường: cần cấp ${BOSS_LEVEL_REQ} và khai phá ${EXPLORE_REQ * 100}% vùng đất (phím M).`,
          'bad',
        );
        this.gateMsgCd = 4;
      }
    }

    if (!this.profile.bossDefeated && !this.boss && dist(p.x, p.y, ARENA.x, ARENA.y) < ARENA.r) {
      const boss = this.spawnEnemy('boss', BOSS_LEVEL, ARENA.x + 120, ARENA.y, { role: 'boss' });
      boss.state = 'chase';
      this.message('Sói Chúa Hư Vô xuất hiện! Đánh vào thanh Phá Thế để làm nó choáng.', 'bad');
    }
  }

  private slash(): void {
    const p = this.player;
    p.attackCd = SLASH_INTERVAL / this.stats.atkSpeed;
    p.swing = 0.16;
    p.swingKind = 'slash';
    p.hits++;
    const double = this.profile.talent === 'kiem-tam' && p.hits % 5 === 0;
    if (double) this.text(p.x, p.y - 34, 'Kiếm Tâm!', '#5bd16a', true);
    for (const e of this.enemies) {
      if (e.dead) continue;
      const dx = e.x - p.x;
      const dy = e.y - p.y;
      const d = Math.hypot(dx, dy);
      if (d > SLASH_RANGE + e.radius) continue;
      const inArc = Math.abs(angleDiff(Math.atan2(dy, dx), p.facing)) <= SLASH_ARC;
      if (!inArc && d > e.radius + PLAYER_RADIUS) continue;
      this.hitEnemy(e, double ? 2 : 1);
    }
  }

  private spin(): void {
    const p = this.player;
    p.skillCd = SKILL_CD;
    p.swing = 0.3;
    p.swingKind = 'spin';
    for (const e of this.enemies) {
      if (e.dead) continue;
      if (dist(e.x, e.y, p.x, p.y) <= SPIN_RANGE + e.radius) this.hitEnemy(e, SPIN_MUL);
    }
  }

  private useTalent(): void {
    const p = this.player;
    if (!this.talent.active) {
      if (this.passiveMsgCd <= 0) {
        this.message(`${this.talent.name} là Thiên phú bị động — luôn có hiệu lực.`, 'info');
        this.passiveMsgCd = 3;
      }
      return;
    }
    if (p.talentCd > 0) return;
    this.freezeTimer = FREEZE_TIME;
    p.talentCd = TALENT_CD;
    this.text(p.x, p.y - 40, 'Thời Gian Ngưng Đọng!', '#b36bff', true);
  }

  allocate(stat: StatKey): void {
    if (this.profile.unspent <= 0) return;
    this.profile.points[stat]++;
    this.profile.unspent--;
    this.refreshStats();
  }

  /** Tẩy điểm miễn phí trước cấp 30 (tài liệu mục 4). */
  respec(): boolean {
    if (this.profile.level >= FREE_RESPEC_LEVEL) return false;
    const pts = this.profile.points;
    this.profile.unspent += pts.str + pts.agi + pts.vit;
    this.profile.points = { str: 0, agi: 0, vit: 0 };
    this.refreshStats();
    return true;
  }

  private refreshStats(): void {
    const before = this.stats.maxHp;
    this.stats = deriveStats(this.profile.level, this.profile.points, this.profile.talent);
    const gain = Math.max(0, this.stats.maxHp - before);
    this.player.hp = clamp(this.player.hp + gain, 0, this.stats.maxHp);
  }

  addExp(amount: number, fromCombat: boolean): void {
    const p = this.profile;
    let gain = amount;
    if (fromCombat && explore.hasWonder(p.tiles)) gain *= 1.1;
    p.exp += Math.round(gain);
    while (p.level < MAX_LEVEL && p.exp >= expToNext(p.level)) {
      p.exp -= expToNext(p.level);
      p.level++;
      p.unspent += POINTS_PER_LEVEL;
      p.torches = Math.min(TORCH_MAX, p.torches + 1);
      this.refreshStats();
      this.player.hp = this.stats.maxHp;
      this.events.push({ type: 'levelup', level: p.level });
      this.message(`Lên cấp ${p.level}! +${POINTS_PER_LEVEL} điểm tiềm năng (C), +1 Đuốc Khai Giới.`, 'good');
    }
  }

  private damagePlayer(atk: number, mul: number): void {
    const p = this.player;
    if (p.deadTimer > 0) return;
    if (p.dodgeTime > 0) {
      this.text(p.x, p.y - 28, 'Né!', '#9de0e6', false);
      return;
    }
    const dmg = Math.max(1, Math.round(computeDamage(atk, this.stats.def, mul)));
    p.hp -= dmg;
    p.hurt = 0.2;
    this.combo = 0;
    this.text(p.x, p.y - 26, `-${dmg}`, '#ff5470', false);
    if (p.hp <= 0) this.die();
  }

  private die(): void {
    const p = this.player;
    p.hp = 0;
    p.deadTimer = RESPAWN_TIME;
    this.events.push({ type: 'death' });
    this.message('Bạn đã gục ngã… hồi sinh tại Làng Thanh Thạch.', 'bad');
    const boss = this.boss;
    if (boss) {
      for (const e of this.enemies) if (e.role === 'boss' || e.role === 'bossMinion') e.dead = true;
      this.message('Sói Chúa Hư Vô rút về hang, hồi phục toàn bộ sinh lực.', 'bad');
    }
  }

  private respawn(): void {
    const p = this.player;
    p.x = VILLAGE.x + 60;
    p.y = VILLAGE.y;
    p.hp = this.stats.maxHp;
    p.dodgeTime = 0;
    for (const e of this.enemies) {
      if (dist(e.x, e.y, VILLAGE.x, VILLAGE.y) < VILLAGE.r + 220 && e.role === 'field') e.dead = true;
    }
    this.projectiles = [];
  }

  // ---------------------------------------------------------------- quái

  private hitEnemy(e: Enemy, skillMul: number): void {
    const s = this.stats;
    const talentBonus = this.profile.talent === 'huyet-chien' && this.player.hp < s.maxHp * 0.3 ? 0.2 : 0;
    const crit = this.rng() < s.crit;
    const mul = skillMul * (crit ? 1.5 : 1) * (e.broken ? 1.5 : 1);
    const dmg = Math.max(1, Math.round(computeDamage(s.atk, e.def, mul, 0, talentBonus) * (0.9 + this.rng() * 0.2)));
    e.hp -= dmg;
    e.hitFlash = 0.12;
    this.text(e.x, e.y - e.radius - 8, crit ? `${dmg}!` : `${dmg}`, crit ? '#ffc940' : '#ffffff', crit);
    this.combo++;
    this.comboTimer = COMBO_TIMEOUT;
    if (e.state === 'idle') e.state = 'chase';

    if (e.role === 'boss') {
      this.damagePoise(e, dmg);
    } else if (e.state !== 'windup') {
      const a = Math.atan2(e.y - this.player.y, e.x - this.player.x);
      e.x += Math.cos(a) * 10;
      e.y += Math.sin(a) * 10;
    }

    if (e.hp <= 0) this.killEnemy(e);
    else if (e.role === 'boss' && e.phase === 1 && e.hp <= e.maxHp * 0.5) this.bossPhaseTwo(e);
  }

  private damagePoise(e: Enemy, dmg: number): void {
    if (e.broken || e.state === 'stunned') return;
    e.poise -= dmg;
    if (e.poise <= 0) {
      e.poise = 0;
      e.broken = true;
      e.state = 'stunned';
      e.timer = BOSS_STUN;
      this.message('Phá Thế! Sói Chúa choáng 5 giây và nhận thêm 50% sát thương.', 'good');
    }
  }

  private bossPhaseTwo(e: Enemy): void {
    e.phase = 2;
    for (let i = 0; i < 3; i++) {
      const a = (i / 3) * Math.PI * 2;
      const wolf = this.spawnEnemy('wolf', 5, e.x + Math.cos(a) * 90, e.y + Math.sin(a) * 90, { role: 'bossMinion' });
      wolf.state = 'chase';
    }
    this.message('Sói Chúa hú gọi bầy sói và ẩn mình vào sương mù!', 'bad');
  }

  private killEnemy(e: Enemy): void {
    e.dead = true;
    const p = this.profile;
    p.kills++;
    const isBoss = e.role === 'boss';
    this.addExp((isBoss ? BOSS_EXP : mobExp(e.level, e.elite)) * comboExpMultiplier(this.combo), true);

    const gold = isBoss ? BOSS_GOLD : Math.round(e.level * 3 * (e.elite ? 4 : 1) * (0.8 + this.rng() * 0.4));
    this.pickups.push({ x: e.x, y: e.y, kind: 'gold', value: gold, ttl: 30 });
    if (e.elite || this.rng() < 0.15) {
      this.pickups.push({ x: e.x + 14, y: e.y - 10, kind: 'orb', value: 0.2, ttl: 30 });
    }
    if (e.elite && p.torches < TORCH_MAX) {
      p.torches++;
      this.message(`Hạ ${e.name}: +1 Đuốc Khai Giới.`, 'good');
    }
    if (e.nestTileId !== null && explore.conquerTile(p, e.nestTileId)) {
      this.events.push({ type: 'tile', tileId: e.nestTileId });
      this.message('Đã chiếm Ổ quái! Lãnh địa mở rộng thêm một ô.', 'good');
    }
    if (isBoss) {
      p.bossDefeated = true;
      for (const m of this.enemies) if (m.role === 'bossMinion') m.dead = true;
      this.message('Sói Chúa Hư Vô đã ngã xuống!', 'good');
      this.events.push({ type: 'victory' });
    }
  }

  private updateEnemy(e: Enemy, dt: number): void {
    const def = MONSTERS[e.kind];
    const p = this.player;
    if (e.hitFlash > 0) e.hitFlash -= dt;
    const alive = p.deadTimer <= 0;
    const d = dist(e.x, e.y, p.x, p.y);
    // Quái thường không theo vào làng; quái ngoài hang không theo vào hang Sói Chúa.
    const outsider = e.role !== 'boss' && e.role !== 'bossMinion';
    const playerSafe =
      dist(p.x, p.y, VILLAGE.x, VILLAGE.y) < VILLAGE.r ||
      (outsider && dist(p.x, p.y, ARENA.x, ARENA.y) < ARENA.r);

    switch (e.state) {
      case 'stunned':
        e.timer -= dt;
        if (e.timer <= 0) {
          e.state = 'chase';
          e.broken = false;
          e.poise = e.maxPoise;
        }
        return;
      case 'idle': {
        e.timer -= dt;
        if (dist(e.x, e.y, e.wanderX, e.wanderY) < 8 || e.timer <= 0) {
          e.wanderX = clamp(e.homeX + (this.rng() - 0.5) * 240, 40, WORLD_W - 40);
          e.wanderY = clamp(e.homeY + (this.rng() - 0.5) * 240, 40, WORLD_H - 40);
          e.timer = 2 + this.rng() * 3;
        } else {
          this.moveToward(e, e.wanderX, e.wanderY, e.speed * 0.35, dt);
        }
        const aggro = e.role === 'boss' ? 2000 : 260;
        if (alive && !playerSafe && d < aggro) e.state = 'chase';
        return;
      }
      case 'chase': {
        const leash = e.role !== 'boss' && (d > 560 || playerSafe);
        if (!alive || leash) {
          e.state = 'idle';
          e.homeX = e.x;
          e.homeY = e.y;
          e.timer = 0;
          return;
        }
        if (e.role === 'boss') {
          e.pounceCd -= dt;
          if (e.pounceCd <= 0 && d > 150) {
            this.beginAttack(e, 'pounce', 0.85);
            e.pounceCd = 5;
            return;
          }
        }
        if (d <= e.radius + e.range + PLAYER_RADIUS) {
          this.beginAttack(e, def.attack, def.windup);
          return;
        }
        this.moveToward(e, p.x, p.y, e.speed, dt);
        return;
      }
      case 'windup':
        e.timer -= dt;
        if (e.timer <= 0) {
          this.performAttack(e);
          e.state = 'recover';
          e.timer = def.recover;
        }
        return;
      case 'recover':
        e.timer -= dt;
        if (e.timer <= 0) e.state = 'chase';
        return;
    }
  }

  private beginAttack(e: Enemy, kind: AttackKind, windup: number): void {
    e.state = 'windup';
    e.attackKind = kind;
    e.timer = windup;
    e.windupTotal = windup;
    e.targetX = this.player.x;
    e.targetY = this.player.y;
    if (e.role === 'boss') this.clampToArena(e, 'target');
  }

  private performAttack(e: Enemy): void {
    const p = this.player;
    switch (e.attackKind) {
      case 'melee':
        if (dist(e.x, e.y, p.x, p.y) <= e.radius + e.range + PLAYER_RADIUS + 12) this.damagePlayer(e.atk, 1);
        return;
      case 'spore': {
        const a = Math.atan2(e.targetY - e.y, e.targetX - e.x);
        this.projectiles.push({ x: e.x, y: e.y, vx: Math.cos(a) * 280, vy: Math.sin(a) * 280, ttl: 1.6, atk: e.atk, radius: 8 });
        return;
      }
      case 'pounce':
        e.x = e.targetX;
        e.y = e.targetY;
        if (dist(e.targetX, e.targetY, p.x, p.y) <= POUNCE_RADIUS + PLAYER_RADIUS) this.damagePlayer(e.atk, 2);
        return;
    }
  }

  private moveToward(e: Enemy, tx: number, ty: number, speed: number, dt: number): void {
    const d = dist(e.x, e.y, tx, ty);
    if (d < 1) return;
    const step = Math.min(d, speed * dt);
    e.x += ((tx - e.x) / d) * step;
    e.y += ((ty - e.y) / d) * step;
    if (e.role === 'boss') this.clampToArena(e, 'body');
  }

  private clampToArena(e: Enemy, which: 'body' | 'target'): void {
    const x = which === 'body' ? e.x : e.targetX;
    const y = which === 'body' ? e.y : e.targetY;
    const limit = ARENA.r - e.radius;
    const d = dist(x, y, ARENA.x, ARENA.y);
    if (d <= limit) return;
    const nx = ARENA.x + ((x - ARENA.x) / d) * limit;
    const ny = ARENA.y + ((y - ARENA.y) / d) * limit;
    if (which === 'body') {
      e.x = nx;
      e.y = ny;
    } else {
      e.targetX = nx;
      e.targetY = ny;
    }
  }

  private separateEnemies(): void {
    const list = this.enemies;
    for (let i = 0; i < list.length; i++) {
      const a = list[i];
      if (a.dead) continue;
      for (let j = i + 1; j < list.length; j++) {
        const b = list[j];
        if (b.dead) continue;
        const d = dist(a.x, a.y, b.x, b.y);
        const min = a.radius + b.radius;
        if (d >= min || d < 0.001) continue;
        const push = (min - d) / 2;
        const nx = (b.x - a.x) / d;
        const ny = (b.y - a.y) / d;
        if (a.role !== 'boss') {
          a.x -= nx * push;
          a.y -= ny * push;
        }
        if (b.role !== 'boss') {
          b.x += nx * push;
          b.y += ny * push;
        }
      }
    }
  }

  private updateProjectiles(dt: number): void {
    const p = this.player;
    for (const pr of this.projectiles) {
      pr.x += pr.vx * dt;
      pr.y += pr.vy * dt;
      pr.ttl -= dt;
      if (pr.ttl > 0 && dist(pr.x, pr.y, p.x, p.y) <= pr.radius + PLAYER_RADIUS) {
        this.damagePlayer(pr.atk, 1);
        pr.ttl = 0;
      }
    }
    this.projectiles = this.projectiles.filter((pr) => pr.ttl > 0);
  }

  private updatePickups(dt: number): void {
    const p = this.player;
    for (const pk of this.pickups) {
      pk.ttl -= dt;
      const d = dist(pk.x, pk.y, p.x, p.y);
      if (d < 130 && d > 0.001) {
        const step = Math.min(d, 380 * dt);
        pk.x += ((p.x - pk.x) / d) * step;
        pk.y += ((p.y - pk.y) / d) * step;
      }
      if (d < 22) {
        pk.ttl = 0;
        if (pk.kind === 'gold') {
          this.profile.gold += pk.value;
          this.text(p.x, p.y - 30, `+${pk.value} vàng`, '#ffc940', false);
        } else {
          const heal = Math.round(this.stats.maxHp * pk.value);
          p.hp = Math.min(this.stats.maxHp, p.hp + heal);
          this.text(p.x, p.y - 30, `+${heal} HP`, '#5bd16a', false);
        }
      }
    }
    this.pickups = this.pickups.filter((pk) => pk.ttl > 0);
  }

  private updateSpawning(dt: number): void {
    this.spawnTimer -= dt;
    if (this.spawnTimer > 0) return;
    this.spawnTimer = 1.2;
    const fieldCount = this.enemies.filter((e) => !e.dead && e.role === 'field').length;
    if (fieldCount < MAX_FIELD_MOBS) this.spawnFieldMob();
  }

  private pickKind(level: number): MonsterKind {
    const r = this.rng();
    if (level <= 2) return level === 2 && r < 0.3 ? 'mushroom' : 'wolf';
    if (level <= 4) return r < 0.5 ? 'wolf' : 'mushroom';
    return r < 0.6 ? 'wisp' : r < 0.8 ? 'mushroom' : 'wolf';
  }

  private spawnFieldMob(): void {
    const p = this.player;
    for (let attempt = 0; attempt < 12; attempt++) {
      const x = 480 + this.rng() * (GATE_X - 520);
      const y = 80 + this.rng() * (WORLD_H - 160);
      if (dist(x, y, p.x, p.y) < 450) continue;
      if (dist(x, y, VILLAGE.x, VILLAGE.y) < VILLAGE.r + 150) continue;
      const level = zoneLevel(x);
      this.spawnEnemy(this.pickKind(level), level, x, y, { elite: this.rng() < 0.06 });
      return;
    }
  }

  spawnEnemy(
    kind: MonsterKind,
    level: number,
    x: number,
    y: number,
    opts: { elite?: boolean; role?: EnemyRole; nestTileId?: number } = {},
  ): Enemy {
    const def = MONSTERS[kind];
    const elite = opts.elite ?? false;
    const isBoss = kind === 'boss';
    const hp = isBoss ? def.hp : Math.round(def.hp * (1 + 0.35 * (level - 1)) * (elite ? 2.2 : 1));
    const enemy: Enemy = {
      id: this.nextId++,
      kind,
      role: opts.role ?? 'field',
      name: elite ? `${def.name} Tinh Anh` : def.name,
      level,
      elite,
      x,
      y,
      homeX: x,
      homeY: y,
      wanderX: x,
      wanderY: y,
      hp,
      maxHp: hp,
      atk: isBoss ? def.atk : def.atk * (1 + 0.25 * (level - 1)) * (elite ? 1.5 : 1),
      def: def.def + (isBoss ? 0 : level),
      speed: def.speed,
      radius: def.radius * (elite ? 1.3 : 1),
      range: def.range,
      state: 'idle',
      timer: 0,
      windupTotal: def.windup,
      attackKind: def.attack,
      targetX: x,
      targetY: y,
      hitFlash: 0,
      dead: false,
      nestTileId: opts.nestTileId ?? null,
      poise: isBoss ? BOSS_POISE : 0,
      maxPoise: isBoss ? BOSS_POISE : 0,
      broken: false,
      phase: 1,
      pounceCd: 4,
    };
    this.enemies.push(enemy);
    return enemy;
  }

  // ---------------------------------------------------------------- khai phá

  revealTile(id: number): explore.ActionResult {
    const res = explore.revealTile(this.profile, id);
    if (res.ok && res.exp) this.addExp(res.exp, false);
    this.message(res.message, res.ok ? 'good' : 'bad');
    return res;
  }

  claimTile(id: number): explore.ActionResult {
    if (this.enemies.some((e) => !e.dead && e.nestTileId === id)) {
      const res = { ok: false, message: 'Quái tinh anh của ổ này vẫn đang chờ bạn ngoài Rừng Sương.' };
      this.message(res.message, 'info');
      return res;
    }
    const res = explore.claimTile(this.profile, id);
    if (res.ok && res.exp) this.addExp(res.exp, false);
    if (res.ok && res.startNest) this.startNest(id);
    if (res.ok && !res.startNest) this.events.push({ type: 'tile', tileId: id });
    this.message(res.message, res.ok ? 'good' : 'bad');
    return res;
  }

  upgradeCamp(): explore.ActionResult {
    const res = explore.upgradeCamp(this.profile);
    this.message(res.message, res.ok ? 'good' : 'bad');
    return res;
  }

  private startNest(tileId: number): void {
    const p = this.player;
    const level = clamp(Math.max(2, this.profile.level), 1, 8);
    let x = clamp(p.x + Math.cos(p.facing) * 280, 120, GATE_X - 40);
    let y = clamp(p.y + Math.sin(p.facing) * 280, 120, WORLD_H - 120);
    if (dist(x, y, VILLAGE.x, VILLAGE.y) < VILLAGE.r + 80) {
      x = VILLAGE.x + VILLAGE.r + 300;
      y = VILLAGE.y;
    }
    const kind = this.pickKind(level);
    const guard = this.spawnEnemy(kind, level, x, y, { elite: true, role: 'nestGuard', nestTileId: tileId });
    guard.name = `Thủ lĩnh ${MONSTERS[kind].name}`;
    for (let i = 0; i < 3; i++) {
      const a = (i / 3) * Math.PI * 2;
      this.spawnEnemy(this.pickKind(level), level, x + Math.cos(a) * 70, y + Math.sin(a) * 70, { role: 'nestMinion' });
    }
  }

  // ---------------------------------------------------------------- tiện ích

  private message(text: string, tone: Tone): void {
    this.events.push({ type: 'message', text, tone });
  }

  private text(x: number, y: number, text: string, color: string, big: boolean): void {
    this.texts.push({ x: x + (this.rng() - 0.5) * 16, y, text, color, ttl: big ? 1.1 : 0.8, big });
  }

  private tickTexts(dt: number): void {
    for (const t of this.texts) {
      t.ttl -= dt;
      t.y -= 38 * dt;
    }
    this.texts = this.texts.filter((t) => t.ttl > 0);
  }
}
