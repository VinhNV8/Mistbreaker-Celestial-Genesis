extends RefCounted
## Chỉ số phái sinh từ cấp + điểm tiềm năng + Thiên phú (và cấp Thiên phú) + trang bị.

const Talents = preload("res://scripts/data/talents.gd")

const BASE_SPIN_CD := 6.0


## bonus: kết quả Items.equipment_bonus() — {flat: {stat: value}, max_hp_pct, atk_pct, spin_cd, uniques},
## cộng thêm "dragon": true khi Long Mạch Đàn đã xây xong.
static func derive(level: int, pts: Dictionary, talent: String, bonus := {}, talent_level := 1) -> Dictionary:
	var lv := level - 1
	var str_pts: int = int(pts["str"])
	var agi_pts: int = int(pts["agi"])
	var vit_pts: int = int(pts["vit"])
	var flat: Dictionary = bonus.get("flat", {})
	# TL-10: mỗi cấp Thiên phú trên 1 → +2% Tấn công và HP.
	var tl_pct := 0.02 * (clampi(talent_level, 1, Talents.MAX_TALENT_LEVEL) - 1)
	var dragon := 0.1 if bonus.get("dragon", false) else 0.0
	var hp_pct: float = bonus.get("max_hp_pct", 0.0) + tl_pct + dragon + (0.08 if talent == "than-the" else 0.0)
	var atk_pct: float = bonus.get("atk_pct", 0.0) + tl_pct + dragon
	var crit_bonus := 0.05 if Talents.has_sub(talent, talent_level, "combat", 1) else 0.0
	var crit_dmg_bonus := 0.15 if Talents.has_sub(talent, talent_level, "combat", 2) else 0.0
	return {
		"max_hp": int(round((100 + lv * 15 + vit_pts * 12 + flat.get("max_hp", 0.0)) * (1.0 + hp_pct))),
		"atk": (10.0 + lv * 2 + str_pts * 2 + flat.get("atk", 0.0)) * (1.0 + atk_pct),
		"def": 5.0 + lv * 1.5 + vit_pts * 0.5 + flat.get("def", 0.0),
		"atk_speed": 1.0 + agi_pts * 0.01 + (0.05 if talent == "tay-nhanh" else 0.0) + flat.get("atk_speed", 0.0),
		"crit": minf(0.6, 0.05 + agi_pts * 0.005 + (0.1 if talent == "mat-ung" else 0.0) + flat.get("crit", 0.0) + crit_bonus),
		## Chí mạng gây ×(1 + crit_dmg); gốc 0,5 → ×1,5.
		"crit_dmg": 0.5 + flat.get("crit_dmg", 0.0) + crit_dmg_bonus,
		"move_speed": 230.0 + flat.get("move_speed", 0.0),
		"spin_cd": BASE_SPIN_CD - float(bonus.get("spin_cd", 0.0)),
		"uniques": bonus.get("uniques", []),
	}
