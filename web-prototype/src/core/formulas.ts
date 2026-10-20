/** EXP cần để lên cấp tiếp theo: EXP(L) = 100·L^2.2 + 500·⌊L/10⌋³ (tài liệu mục 4). */
export function expToNext(level: number): number {
  return Math.floor(100 * Math.pow(level, 2.2) + 500 * Math.pow(Math.floor(level / 10), 3));
}

export function mobExp(level: number, elite: boolean): number {
  return Math.round(30 * Math.pow(level, 1.5) * (elite ? 3 : 1));
}

/** DMG = ATK · HệSốKỹNăng · ATK/(ATK+DEF) · (1+KhắcHệ) · (1+ThiênPhú) (tài liệu mục 5). */
export function computeDamage(atk: number, def: number, skillMul = 1, elementBonus = 0, talentBonus = 0): number {
  if (atk <= 0) return 0;
  return atk * skillMul * (atk / (atk + Math.max(0, def))) * (1 + elementBonus) * (1 + talentBonus);
}

/** Combo không bị trúng đòn: tối đa +20% EXP ở 100 combo. */
export function comboExpMultiplier(combo: number): number {
  return 1 + (Math.min(Math.max(combo, 0), 100) / 100) * 0.2;
}
