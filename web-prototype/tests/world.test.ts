import { describe, expect, it } from 'vitest';
import { newProfile, type Profile } from '../src/core/profile';
import { mulberry32 } from '../src/core/rng';
import { ARENA, GATE_X, World, type Input } from '../src/core/world';

/** Bot đơn giản: lao vào quái gần nhất, chém liên tục, né khi quái đang vung đòn ngay cạnh. */
function botInput(w: World): Input {
  const p = w.player;
  let target = w.enemies[0];
  let best = Infinity;
  for (const e of w.enemies) {
    const d = Math.hypot(e.x - p.x, e.y - p.y);
    if (d < best) {
      best = d;
      target = e;
    }
  }
  if (!target) return { moveX: 1, moveY: 0, aimX: p.x + 100, aimY: p.y, attack: false, skill: false, talent: false, dodge: false };
  const dx = target.x - p.x;
  const dy = target.y - p.y;
  const threat = w.enemies.some((e) => e.state === 'windup' && e.timer < 0.2 && Math.hypot(e.x - p.x, e.y - p.y) < 140);
  const close = best < 60 + target.radius;
  return {
    moveX: close ? 0 : Math.sign(dx),
    moveY: close ? 0 : Math.sign(dy),
    aimX: target.x,
    aimY: target.y,
    attack: true,
    skill: best < 120,
    talent: true,
    dodge: threat,
  };
}

function run(w: World, seconds: number, input: (w: World) => Input, until?: () => boolean): void {
  const dt = 1 / 60;
  for (let t = 0; t < seconds; t += dt) {
    w.update(dt, input(w));
    if (until?.()) return;
  }
}

describe('World', () => {
  it('bot đánh quái được, lên cấp, không sinh giá trị NaN', () => {
    const profile = newProfile('kiem-tam', mulberry32(3), 0);
    const w = new World(profile, mulberry32(11));
    w.player.x = 700;
    run(w, 180, botInput);
    expect(profile.kills).toBeGreaterThan(10);
    expect(profile.level).toBeGreaterThan(1);
    expect(Number.isFinite(w.player.x) && Number.isFinite(w.player.hp)).toBe(true);
  });

  it('sương mù chặn lối vào hang khi chưa đủ điều kiện', () => {
    const w = new World(newProfile('tay-nhanh', mulberry32(3), 0), mulberry32(1));
    w.enemies = [];
    w.player.x = GATE_X - 50;
    run(w, 2, (ww) => ({ moveX: 1, moveY: 0, aimX: ww.player.x + 100, aimY: ww.player.y, attack: false, skill: false, talent: false, dodge: false }));
    expect(w.player.x).toBeLessThanOrEqual(GATE_X);
    expect(w.boss).toBeUndefined();
  });

  it('quái thường không đuổi theo vào hang Sói Chúa', () => {
    const profile = newProfile('tay-nhanh', mulberry32(3), 0);
    profile.bossDefeated = true;
    const w = new World(profile, mulberry32(2));
    w.enemies = [];
    w.player.x = ARENA.x;
    w.player.y = ARENA.y;
    const wolf = w.spawnEnemy('wolf', 3, ARENA.x - ARENA.r - 40, ARENA.y);
    wolf.state = 'chase';
    run(w, 1, (ww) => ({ moveX: 0, moveY: 0, aimX: ww.player.x, aimY: ww.player.y, attack: false, skill: false, talent: false, dodge: false }));
    expect(wolf.state).toBe('idle');
  });

  it('nhân vật cấp 5 có build hợp lý hạ được Sói Chúa', () => {
    const profile: Profile = newProfile('kiem-tam', mulberry32(3), 0);
    profile.level = 5;
    profile.points = { str: 12, agi: 0, vit: 8 };
    for (const t of profile.tiles.slice(1, 7)) t.status = 'owned';
    const w = new World(profile, mulberry32(5));
    w.enemies = [];
    w.player.hp = w.stats.maxHp;
    w.player.x = ARENA.x - 100;
    w.player.y = ARENA.y;
    let deaths = 0;
    run(
      w,
      600,
      (ww) => {
        for (const ev of ww.drainEvents()) if (ev.type === 'death') deaths++;
        if (!ww.boss && !profile.bossDefeated && ww.player.deadTimer <= 0) {
          // sau khi chết, quay lại hang
          ww.player.x = ARENA.x - 100;
          ww.player.y = ARENA.y;
        }
        return botInput(ww);
      },
      () => profile.bossDefeated,
    );
    expect(profile.bossDefeated).toBe(true);
    // Trận boss nên khó nhưng không phải tường: bot ngây ngô chết không quá vài lần.
    expect(deaths).toBeLessThan(4);
  });
});
