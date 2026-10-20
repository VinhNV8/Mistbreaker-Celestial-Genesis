import { MONSTERS } from '../data/monsters';
import { RANK_COLOR } from '../data/talents';
import { mulberry32 } from '../core/rng';
import {
  ARENA,
  GATE_X,
  PLAYER_RADIUS,
  POUNCE_RADIUS,
  SLASH_RANGE,
  SPIN_RANGE,
  VILLAGE,
  WORLD_H,
  WORLD_W,
  type Enemy,
  type World,
} from '../core/world';

export interface Camera {
  x: number;
  y: number;
  w: number;
  h: number;
}

interface Deco {
  x: number;
  y: number;
  r: number;
  shade: number;
}

const FONT = '"Be Vietnam Pro", system-ui, sans-serif';

/** Vẽ thế giới bằng hình khối đơn giản (placeholder) — đồ hoạ thật thay sau khi chốt art style. */
export class Renderer {
  private readonly trees: Deco[] = [];
  private readonly patches: Deco[] = [];

  constructor(private readonly ctx: CanvasRenderingContext2D) {
    const rng = mulberry32(20261019);
    for (let i = 0; i < 600 && this.trees.length < 240; i++) {
      const x = rng() * WORLD_W;
      const y = rng() * WORLD_H;
      if (Math.hypot(x - VILLAGE.x, y - VILLAGE.y) < VILLAGE.r + 70) continue;
      if (Math.hypot(x - ARENA.x, y - ARENA.y) < ARENA.r + 60) continue;
      if (Math.abs(y - VILLAGE.y) < 90 && x > VILLAGE.x && x < ARENA.x) continue;
      this.trees.push({ x, y, r: 16 + rng() * 22, shade: rng() });
    }
    for (let i = 0; i < 160; i++) {
      this.patches.push({ x: rng() * WORLD_W, y: rng() * WORLD_H, r: 40 + rng() * 110, shade: rng() });
    }
  }

  draw(world: World, cam: Camera): void {
    const ctx = this.ctx;
    ctx.clearRect(0, 0, cam.w, cam.h);
    ctx.save();
    ctx.translate(-Math.round(cam.x), -Math.round(cam.y));
    this.drawGround(cam);
    this.drawVillage(world.time);
    this.drawArena(world);
    this.drawTrees(cam);
    this.drawPickups(world);
    for (const e of world.enemies) this.drawTelegraph(e);
    for (const e of world.enemies) this.drawEnemy(world, e);
    this.drawProjectiles(world);
    this.drawPlayer(world);
    if (!world.bossUnlocked) this.drawGate(world.time);
    this.drawTexts(world);
    ctx.restore();
    this.drawVignette(world, cam);
  }

  private visible(cam: Camera, x: number, y: number, pad: number): boolean {
    return x > cam.x - pad && x < cam.x + cam.w + pad && y > cam.y - pad && y < cam.y + cam.h + pad;
  }

  private circle(x: number, y: number, r: number): void {
    this.ctx.beginPath();
    this.ctx.arc(x, y, r, 0, Math.PI * 2);
  }

  private drawGround(cam: Camera): void {
    const ctx = this.ctx;
    ctx.fillStyle = '#1c3226';
    ctx.fillRect(0, 0, WORLD_W, WORLD_H);
    for (const p of this.patches) {
      if (!this.visible(cam, p.x, p.y, p.r)) continue;
      ctx.fillStyle = p.shade > 0.5 ? 'rgba(70,110,70,0.18)' : 'rgba(10,25,18,0.25)';
      this.circle(p.x, p.y, p.r);
      ctx.fill();
    }
    // lối mòn từ làng tới hang
    ctx.fillStyle = 'rgba(120,100,70,0.22)';
    ctx.fillRect(VILLAGE.x, VILLAGE.y - 45, ARENA.x - VILLAGE.x, 90);
    // sương mù dày dần về phía đông
    const g = ctx.createLinearGradient(0, 0, WORLD_W, 0);
    g.addColorStop(0, 'rgba(0,0,0,0)');
    g.addColorStop(1, 'rgba(40,20,70,0.45)');
    ctx.fillStyle = g;
    ctx.fillRect(0, 0, WORLD_W, WORLD_H);
  }

  private drawVillage(time: number): void {
    const ctx = this.ctx;
    ctx.fillStyle = '#4a3b2a';
    this.circle(VILLAGE.x, VILLAGE.y, VILLAGE.r);
    ctx.fill();
    ctx.strokeStyle = '#7a5f3e';
    ctx.lineWidth = 5;
    ctx.setLineDash([10, 8]);
    this.circle(VILLAGE.x, VILLAGE.y, VILLAGE.r);
    ctx.stroke();
    ctx.setLineDash([]);
    const tents: [number, number][] = [
      [-90, -70],
      [-110, 40],
      [-30, 100],
      [60, -105],
    ];
    for (const [dx, dy] of tents) {
      ctx.fillStyle = '#b08d57';
      ctx.beginPath();
      ctx.moveTo(VILLAGE.x + dx, VILLAGE.y + dy - 26);
      ctx.lineTo(VILLAGE.x + dx - 24, VILLAGE.y + dy + 16);
      ctx.lineTo(VILLAGE.x + dx + 24, VILLAGE.y + dy + 16);
      ctx.closePath();
      ctx.fill();
    }
    // Bia Đá Thiên Đạo
    const glow = 0.5 + 0.5 * Math.sin(time * 2);
    ctx.fillStyle = `rgba(255,220,140,${0.12 + glow * 0.12})`;
    this.circle(VILLAGE.x, VILLAGE.y, 46);
    ctx.fill();
    ctx.fillStyle = '#8c8f99';
    ctx.fillRect(VILLAGE.x - 12, VILLAGE.y - 34, 24, 50);
    ctx.fillStyle = `rgba(255,230,160,${0.5 + glow * 0.5})`;
    ctx.fillRect(VILLAGE.x - 3, VILLAGE.y - 24, 6, 26);
    this.label('Làng Thanh Thạch', VILLAGE.x, VILLAGE.y - VILLAGE.r - 12, '#f3e3c3', 15);
  }

  private drawArena(world: World): void {
    const ctx = this.ctx;
    ctx.fillStyle = '#251d33';
    this.circle(ARENA.x, ARENA.y, ARENA.r);
    ctx.fill();
    ctx.strokeStyle = 'rgba(160,130,220,0.35)';
    ctx.lineWidth = 3;
    this.circle(ARENA.x, ARENA.y, ARENA.r);
    ctx.stroke();
    this.label(world.profile.bossDefeated ? 'Hang Sói Chúa (đã chinh phục)' : 'Hang Sói Chúa', ARENA.x, ARENA.y - ARENA.r - 12, '#d8c8ff', 15);
  }

  private drawTrees(cam: Camera): void {
    const ctx = this.ctx;
    for (const t of this.trees) {
      if (!this.visible(cam, t.x, t.y, t.r)) continue;
      ctx.fillStyle = 'rgba(0,0,0,0.25)';
      this.circle(t.x + 6, t.y + 8, t.r);
      ctx.fill();
      ctx.fillStyle = t.shade > 0.5 ? '#244a32' : '#1e3e2b';
      this.circle(t.x, t.y, t.r);
      ctx.fill();
      ctx.fillStyle = 'rgba(120,170,110,0.12)';
      this.circle(t.x - t.r * 0.3, t.y - t.r * 0.3, t.r * 0.5);
      ctx.fill();
    }
  }

  private drawGate(time: number): void {
    const ctx = this.ctx;
    const g = ctx.createLinearGradient(GATE_X - 40, 0, GATE_X + 140, 0);
    g.addColorStop(0, 'rgba(120,90,200,0)');
    g.addColorStop(0.35, 'rgba(120,90,200,0.55)');
    g.addColorStop(1, 'rgba(40,25,70,0.92)');
    ctx.fillStyle = g;
    ctx.fillRect(GATE_X - 40, 0, 180, WORLD_H);
    for (let i = 0; i < 14; i++) {
      const y = ((i * 131 + time * 30) % WORLD_H + WORLD_H) % WORLD_H;
      ctx.fillStyle = 'rgba(190,170,255,0.12)';
      this.circle(GATE_X + 30 + Math.sin(time + i) * 20, y, 50);
      ctx.fill();
    }
    this.label('Sương mù Hư Vô', GATE_X + 50, VILLAGE.y - 70, '#e6dcff', 14);
  }

  private drawPickups(world: World): void {
    const ctx = this.ctx;
    for (const p of world.pickups) {
      const bob = Math.sin(world.time * 6 + p.x) * 2;
      ctx.fillStyle = p.kind === 'gold' ? '#ffc940' : '#5bd16a';
      this.circle(p.x, p.y + bob, p.kind === 'gold' ? 5 : 7);
      ctx.fill();
    }
  }

  private drawTelegraph(e: Enemy): void {
    if (e.state !== 'windup') return;
    const ctx = this.ctx;
    const progress = 1 - Math.max(0, e.timer) / e.windupTotal;
    if (e.attackKind === 'pounce') {
      ctx.fillStyle = 'rgba(255,60,80,0.15)';
      this.circle(e.targetX, e.targetY, POUNCE_RADIUS);
      ctx.fill();
      ctx.fillStyle = 'rgba(255,60,80,0.35)';
      this.circle(e.targetX, e.targetY, POUNCE_RADIUS * progress);
      ctx.fill();
    } else if (e.attackKind === 'spore') {
      ctx.strokeStyle = `rgba(200,120,255,${0.25 + progress * 0.5})`;
      ctx.lineWidth = 2;
      ctx.setLineDash([6, 6]);
      ctx.beginPath();
      ctx.moveTo(e.x, e.y);
      ctx.lineTo(e.targetX, e.targetY);
      ctx.stroke();
      ctx.setLineDash([]);
    } else {
      ctx.strokeStyle = `rgba(255,60,80,${0.2 + progress * 0.6})`;
      ctx.lineWidth = 3;
      this.circle(e.x, e.y, e.radius + e.range * progress);
      ctx.stroke();
    }
  }

  private drawEnemy(world: World, e: Enemy): void {
    const ctx = this.ctx;
    const p = world.player;
    ctx.save();
    ctx.globalAlpha = world.isHidden(e) ? 0.15 : 1;
    ctx.fillStyle = 'rgba(0,0,0,0.3)';
    this.circle(e.x + 4, e.y + 6, e.radius);
    ctx.fill();
    ctx.fillStyle = e.hitFlash > 0 ? '#ffffff' : MONSTERS[e.kind].color;
    this.circle(e.x, e.y, e.radius);
    ctx.fill();
    if (e.elite || e.role === 'boss') {
      ctx.strokeStyle = e.role === 'boss' ? '#ff5470' : '#ffc940';
      ctx.lineWidth = 3;
      this.circle(e.x, e.y, e.radius + 3);
      ctx.stroke();
    }
    if (world.freezeTimer > 0) {
      ctx.fillStyle = 'rgba(140,200,255,0.45)';
      this.circle(e.x, e.y, e.radius);
      ctx.fill();
    }
    // mắt nhìn về phía người chơi
    const a = Math.atan2(p.y - e.y, p.x - e.x);
    ctx.fillStyle = e.role === 'boss' || e.elite ? '#ff3b4e' : '#1a1a1a';
    for (const side of [-0.45, 0.45]) {
      this.circle(e.x + Math.cos(a + side) * e.radius * 0.55, e.y + Math.sin(a + side) * e.radius * 0.55, Math.max(2, e.radius * 0.12));
      ctx.fill();
    }
    if (e.state === 'stunned') this.label('✦ choáng ✦', e.x, e.y - e.radius - 14, '#ffc940', 13);
    if (e.role !== 'boss') {
      if (e.hp < e.maxHp) {
        const w = e.radius * 2;
        ctx.fillStyle = 'rgba(0,0,0,0.6)';
        ctx.fillRect(e.x - w / 2, e.y - e.radius - 10, w, 4);
        ctx.fillStyle = '#ff5470';
        ctx.fillRect(e.x - w / 2, e.y - e.radius - 10, (w * Math.max(0, e.hp)) / e.maxHp, 4);
      }
      if (e.elite) this.label(`${e.name} · Lv${e.level}`, e.x, e.y - e.radius - 16, '#ffd877', 12);
    }
    ctx.restore();
  }

  private drawProjectiles(world: World): void {
    const ctx = this.ctx;
    for (const pr of world.projectiles) {
      ctx.fillStyle = 'rgba(190,110,240,0.9)';
      this.circle(pr.x, pr.y, pr.radius);
      ctx.fill();
    }
  }

  private drawPlayer(world: World): void {
    const ctx = this.ctx;
    const p = world.player;
    ctx.save();
    if (p.deadTimer > 0) ctx.globalAlpha = 0.3;
    else if (p.dodgeTime > 0) ctx.globalAlpha = 0.55;

    if (p.swing > 0) {
      ctx.fillStyle = `rgba(255,255,255,${0.25 * Math.min(1, p.swing / 0.16)})`;
      if (p.swingKind === 'slash') {
        ctx.beginPath();
        ctx.moveTo(p.x, p.y);
        ctx.arc(p.x, p.y, SLASH_RANGE, p.facing - Math.PI / 3, p.facing + Math.PI / 3);
        ctx.closePath();
        ctx.fill();
      } else {
        ctx.strokeStyle = `rgba(200,230,255,${0.7 * Math.min(1, p.swing / 0.3)})`;
        ctx.lineWidth = 10;
        this.circle(p.x, p.y, SPIN_RANGE * (1 - p.swing / 0.6));
        ctx.stroke();
      }
    }

    ctx.strokeStyle = RANK_COLOR[world.talent.rank];
    ctx.globalAlpha *= 0.6;
    ctx.lineWidth = 2;
    this.circle(p.x, p.y, PLAYER_RADIUS + 6);
    ctx.stroke();
    ctx.globalAlpha /= 0.6;

    ctx.fillStyle = 'rgba(0,0,0,0.3)';
    this.circle(p.x + 4, p.y + 6, PLAYER_RADIUS);
    ctx.fill();
    ctx.fillStyle = p.hurt > 0 ? '#ff8a8a' : '#e8d9a8';
    this.circle(p.x, p.y, PLAYER_RADIUS);
    ctx.fill();
    ctx.strokeStyle = '#3b2f1e';
    ctx.lineWidth = 2;
    ctx.stroke();

    ctx.strokeStyle = '#cfe3ff';
    ctx.lineWidth = 4;
    ctx.lineCap = 'round';
    ctx.beginPath();
    ctx.moveTo(p.x + Math.cos(p.facing) * (PLAYER_RADIUS - 2), p.y + Math.sin(p.facing) * (PLAYER_RADIUS - 2));
    ctx.lineTo(p.x + Math.cos(p.facing) * (PLAYER_RADIUS + 26), p.y + Math.sin(p.facing) * (PLAYER_RADIUS + 26));
    ctx.stroke();
    ctx.restore();
  }

  private drawTexts(world: World): void {
    const ctx = this.ctx;
    ctx.textAlign = 'center';
    for (const t of world.texts) {
      ctx.globalAlpha = Math.min(1, t.ttl * 2);
      ctx.font = `800 ${t.big ? 18 : 14}px ${FONT}`;
      ctx.lineWidth = 3;
      ctx.strokeStyle = 'rgba(0,0,0,0.8)';
      ctx.strokeText(t.text, t.x, t.y);
      ctx.fillStyle = t.color;
      ctx.fillText(t.text, t.x, t.y);
    }
    ctx.globalAlpha = 1;
  }

  private label(text: string, x: number, y: number, color: string, size: number): void {
    const ctx = this.ctx;
    ctx.font = `600 ${size}px ${FONT}`;
    ctx.textAlign = 'center';
    ctx.lineWidth = 3;
    ctx.strokeStyle = 'rgba(0,0,0,0.7)';
    ctx.strokeText(text, x, y);
    ctx.fillStyle = color;
    ctx.fillText(text, x, y);
  }

  private drawVignette(world: World, cam: Camera): void {
    const ctx = this.ctx;
    const p = world.player;
    const sx = p.x - cam.x;
    const sy = p.y - cam.y;
    const density = 0.45 + 0.35 * (p.x / WORLD_W);
    const g = ctx.createRadialGradient(sx, sy, 200, sx, sy, Math.max(cam.w, cam.h) * 0.75);
    g.addColorStop(0, 'rgba(12,16,24,0)');
    g.addColorStop(1, `rgba(12,16,24,${density})`);
    ctx.fillStyle = g;
    ctx.fillRect(0, 0, cam.w, cam.h);
    if (world.freezeTimer > 0) {
      ctx.fillStyle = 'rgba(120,170,255,0.12)';
      ctx.fillRect(0, 0, cam.w, cam.h);
    }
  }
}
