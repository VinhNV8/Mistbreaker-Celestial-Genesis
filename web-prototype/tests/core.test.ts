import { describe, expect, it } from 'vitest';
import { Awakening } from '../src/core/awakening';
import { TORCH_REGEN_SEC } from '../src/core/config';
import * as explore from '../src/core/explore';
import { comboExpMultiplier, computeDamage, expToNext } from '../src/core/formulas';
import { newProfile } from '../src/core/profile';
import { mulberry32 } from '../src/core/rng';
import { applyOffline } from '../src/core/save';
import { TALENTS } from '../src/data/talents';

describe('công thức', () => {
  it('EXP theo tài liệu và luôn tăng dần', () => {
    expect(expToNext(1)).toBe(100);
    expect(expToNext(10)).toBe(Math.floor(100 * Math.pow(10, 2.2) + 500));
    for (let l = 1; l < 100; l++) expect(expToNext(l + 1)).toBeGreaterThan(expToNext(l));
  });

  it('sát thương', () => {
    expect(computeDamage(0, 10)).toBe(0);
    expect(computeDamage(20, 20)).toBe(10);
    expect(computeDamage(20, 20, 2, 0.3, 0.2)).toBeCloseTo(10 * 2 * 1.3 * 1.2);
  });

  it('combo tối đa +20% EXP ở 100 combo', () => {
    expect(comboExpMultiplier(0)).toBe(1);
    expect(comboExpMultiplier(100)).toBeCloseTo(1.2);
    expect(comboExpMultiplier(500)).toBeCloseTo(1.2);
  });
});

describe('Lễ Thức Tỉnh', () => {
  it('1 lần quay + 3 lần quay lại, rồi hết lượt', () => {
    const a = new Awakening(mulberry32(1));
    expect(a.rerollsLeft).toBe(3);
    a.roll();
    expect(a.rerollsLeft).toBe(3);
    a.roll();
    a.roll();
    a.roll();
    expect(a.rerollsLeft).toBe(0);
    expect(a.canRoll).toBe(false);
    expect(() => a.roll()).toThrow();
  });

  it('bảo hiểm: 4 lần đều dưới hạng B thì lần cuối thành hạng B', () => {
    const a = new Awakening(() => 0); // luôn ra Thiên phú đầu bảng (hạng F)
    for (let i = 0; i < 3; i++) expect(a.roll().rank).toBe('F');
    expect(a.roll().rank).toBe('B');
  });

  it('tỉ lệ quay xấp xỉ bảng độ hiếm', () => {
    const rng = mulberry32(42);
    const counts: Record<string, number> = {};
    const n = 20000;
    for (let i = 0; i < n; i++) {
      const t = new Awakening(rng).roll();
      counts[t.rank] = (counts[t.rank] ?? 0) + 1;
    }
    const total = TALENTS.reduce((s, t) => s + ({ F: 30, C: 28, B: 22, A: 13, S: 5 } as Record<string, number>)[t.rank], 0);
    expect(counts.F / n).toBeCloseTo(30 / total, 1);
    expect(counts.S / n).toBeCloseTo(5 / total, 1);
  });
});

describe('khai phá', () => {
  const fresh = () => newProfile('kiem-tam', mulberry32(7), 0);

  it('lưới 10 ô + trại, đúng cơ cấu sự kiện', () => {
    const p = fresh();
    expect(p.tiles).toHaveLength(11);
    expect(explore.ownedCount(p.tiles)).toBe(0);
    const count = (ev: explore.TileEvent) => p.tiles.filter((t) => t.event === ev).length;
    expect([count('resource'), count('nest'), count('relic'), count('survivor'), count('wonder')]).toEqual([4, 2, 2, 1, 1]);
  });

  it('chỉ dọn được ô kề lãnh địa, mỗi lần tốn 1 Đuốc', () => {
    const p = fresh();
    const ring2 = p.tiles.find((t) => explore.hexDistance(t, { q: 0, r: 0 }) === 2)!;
    expect(explore.revealBlocker(p, ring2)).not.toBeNull();
    const ring1 = p.tiles.filter((t) => explore.hexDistance(t, { q: 0, r: 0 }) === 1);
    expect(explore.revealTile(p, ring1[0].id).ok).toBe(true);
    expect(p.torches).toBe(2);
    p.torches = 0;
    expect(explore.revealTile(p, ring1[1].id).ok).toBe(false);
  });

  it('xây Xưởng Gỗ cần vàng, sau đó có sản lượng', () => {
    const p = fresh();
    const res = p.tiles.find((t) => t.event === 'resource' && explore.hexDistance(t, { q: 0, r: 0 }) === 1)!;
    explore.revealTile(p, res.id);
    expect(explore.claimTile(p, res.id).ok).toBe(false);
    p.gold = 50;
    expect(explore.claimTile(p, res.id).ok).toBe(true);
    expect(p.gold).toBe(20);
    expect(explore.productionPerMinute(p).wood).toBeGreaterThan(0);
    expect(explore.exploredRatio(p.tiles)).toBeCloseTo(0.1);
  });

  it('Ổ quái không tự chiếm được, phải hạ quái tinh anh', () => {
    const p = fresh();
    const nest = p.tiles.find((t) => t.event === 'nest')!;
    nest.status = 'revealed';
    const r = explore.claimTile(p, nest.id);
    expect(r.startNest).toBe(true);
    expect(nest.status).toBe('revealed');
    expect(explore.conquerTile(p, nest.id)).toBe(true);
    expect(nest.status).toBe('owned');
  });

  it('Mắt Ưng nhìn xuyên sương mù', () => {
    const p = fresh();
    const fog = p.tiles.find((t) => t.status === 'fog')!;
    expect(explore.isEventVisible(p.tiles, fog, 'kiem-tam')).toBe(false);
    expect(explore.isEventVisible(p.tiles, fog, 'mat-ung')).toBe(true);
  });

  it('thu hoạch offline giới hạn 12 giờ và hồi Đuốc', () => {
    const p = fresh();
    const res = p.tiles.find((t) => t.event === 'resource')!;
    res.status = 'owned';
    p.torches = 0;
    const out = applyOffline(p, 48 * 3600 * 1000);
    expect(out.seconds).toBe(12 * 3600);
    expect(out.wood).toBeCloseTo(6 * 12 * 60);
    expect(p.torches).toBe(Math.min(10, Math.floor((12 * 3600) / TORCH_REGEN_SEC)));
  });
});
