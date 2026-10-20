extends RefCounted
## Chỉ số phái sinh từ lớp + cấp + điểm tiềm năng (+ điểm Đạo Tặc cướp) + Thiên phú (và cấp Thiên phú) + trang bị.

const Talents = preload("res://scripts/data/talents.gd")

const BASE_SPIN_CD := 6.0
const STATS := ["str", "agi", "int", "vit", "luk"]
## ST-04: trần né tránh.
const EVASION_CAP := 0.3
const RES_CAP := 0.5


## Đọc điểm an toàn với save/test cũ chỉ có str/agi/vit.
static func pts_of(pts: Dictionary, key: String) -> int:
	return int(pts.get(key, 0))


## stolen: mảng thuộc tính Đạo Tặc cướp được (CR-01), cộng thẳng vào điểm.
static func total_points(pts: Dictionary, stolen: Array = []) -> Dictionary:
	var out := {}
	for k in STATS:
		out[k] = pts_of(pts, k)
	for k in stolen:
		out[str(k)] = int(out.get(str(k), 0)) + 1
	return out


## bonus: kết quả Items.equipment_bonus() — {flat: {stat: value}, max_hp_pct, atk_pct, spin_cd, uniques},
## cộng thêm "dragon": true khi Long Mạch Đàn đã xây xong.
static func derive(level: int, pts: Dictionary, talent: String, bonus := {}, talent_level := 1,
		class_id := "kiem-khach", stolen: Array = []) -> Dictionary:
	var lv := level - 1
	var t := total_points(pts, stolen)
	var str_pts: int = t.str
	var agi_pts: int = t.agi
	var int_pts: int = t.int
	var vit_pts: int = t.vit
	var luk_pts: int = t.luk
	var hunter := class_id == "tho-san"
	var flat: Dictionary = bonus.get("flat", {})
	var tlv := clampi(talent_level, 1, Talents.MAX_TALENT_LEVEL)
	# TL-10: mỗi cấp Thiên phú trên 1 → +2% Tấn công và HP.
	var tl_pct := 0.02 * (tlv - 1)
	var dragon := Talents.lv_value(0.1, 0.15, tlv) if bonus.get("dragon", false) else 0.0
	var hp_pct: float = bonus.get("max_hp_pct", 0.0) + tl_pct + dragon \
		+ (Talents.lv_value(0.08, 0.12, tlv) if talent == "than-the" else 0.0)
	var atk_pct: float = bonus.get("atk_pct", 0.0) + tl_pct + dragon
	var crit_bonus := 0.05 if Talents.has_sub(talent, talent_level, "combat", 1) else 0.0
	var crit_dmg_bonus := 0.15 if Talents.has_sub(talent, talent_level, "combat", 2) else 0.0
	# CL: Kiếm Khách lấy Tấn công từ STR; Thợ Săn từ AGI (STR phụ), máu mỏng hơn, né gốc 5%.
	var atk_from_pts := (agi_pts * 2 + str_pts) if hunter else str_pts * 2
	var base_hp := (90 + lv * 13) if hunter else (100 + lv * 15)
	return {
		"class": class_id,
		"max_hp": int(round((base_hp + vit_pts * 12 + flat.get("max_hp", 0.0)) * (1.0 + hp_pct))),
		"atk": (10.0 + lv * 2 + atk_from_pts + flat.get("atk", 0.0)) * (1.0 + atk_pct),
		"def": 5.0 + lv * 1.5 + vit_pts * 0.5 + flat.get("def", 0.0),
		"atk_speed": 1.0 + agi_pts * 0.01 + (Talents.lv_value(0.05, 0.075, tlv) if talent == "tay-nhanh" else 0.0) + flat.get("atk_speed", 0.0)
			+ float(bonus.get("atk_speed_pct", 0.0)),
		"crit": minf(0.6, 0.05 + agi_pts * 0.005 + luk_pts * 0.003
			+ (Talents.lv_value(0.1, 0.15, tlv) if talent == "mat-ung" else 0.0) + flat.get("crit", 0.0) + crit_bonus),
		## Chí mạng gây ×(1 + crit_dmg); gốc 0,5 → ×1,5.
		"crit_dmg": 0.5 + flat.get("crit_dmg", 0.0) + crit_dmg_bonus,
		"move_speed": (230.0 + flat.get("move_speed", 0.0)) * (1.0 + float(bonus.get("move_pct", 0.0))),
		"spin_cd": BASE_SPIN_CD - float(bonus.get("spin_cd", 0.0)),
		"uniques": bonus.get("uniques", []),
		# ST-01…04 (M3)
		"max_mp": 50 + lv * 5 + int_pts * 6,
		"mp_regen": 3.0 + int_pts * 0.05,
		"skill_mul": 1.0 + int_pts * 0.005,
		"drop_bonus": minf(0.10, luk_pts * 0.002),
		"evasion": minf(EVASION_CAP, (0.05 if hunter else 0.0) + agi_pts * 0.003),
		# NV-17: kháng hệ (tối đa 50%), M4.2
		"res": {
			"kim": minf(RES_CAP, flat.get("res_kim", 0.0)), "moc": minf(RES_CAP, flat.get("res_moc", 0.0)),
			"thuy": minf(RES_CAP, flat.get("res_thuy", 0.0)), "hoa": minf(RES_CAP, flat.get("res_hoa", 0.0)),
			"tho": minf(RES_CAP, flat.get("res_tho", 0.0)),
		},
		"dodge_cd": 3.0 - float(bonus.get("dodge_cd", 0.0)),
	}
