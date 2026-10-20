extends RefCounted


## EXP cần để lên cấp tiếp theo: EXP(L) = 100·L^2.2 + 500·⌊L/10⌋³ (tài liệu mục 4).
static func exp_to_next(level: int) -> int:
	return int(floor(100.0 * pow(level, 2.2) + 500.0 * pow(floor(level / 10.0), 3.0)))


static func mob_exp(level: int, elite: bool) -> int:
	return int(round(30.0 * pow(level, 1.5) * (3.0 if elite else 1.0)))


## DMG = ATK · HệSốKỹNăng · ATK/(ATK+DEF) · (1+KhắcHệ) · (1+ThiênPhú) (tài liệu mục 5).
static func compute_damage(atk: float, def: float, skill_mul := 1.0, element_bonus := 0.0, talent_bonus := 0.0) -> float:
	if atk <= 0.0:
		return 0.0
	return atk * skill_mul * (atk / (atk + maxf(0.0, def))) * (1.0 + element_bonus) * (1.0 + talent_bonus)


## Combo không bị trúng đòn: tối đa +20% EXP ở 100 combo.
static func combo_exp_multiplier(combo: int) -> float:
	return 1.0 + clampf(combo, 0.0, 100.0) / 100.0 * 0.2
