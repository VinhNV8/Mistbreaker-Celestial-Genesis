extends RefCounted
## Chỉ số phái sinh từ lớp + cấp + điểm tiềm năng (+ điểm Đạo Tặc cướp) + Thiên phú (và cấp Thiên phú) + trang bị.

const Talents = preload("res://scripts/data/talents.gd")

const BASE_SPIN_CD := 6.0
const STATS := ["str", "agi", "int", "vit", "luk"]
## ST-04: trần né tránh.
const EVASION_CAP := 0.3
const RES_CAP := 0.5
## SN-07: tốc đánh mỗi điểm AGI — Thợ Săn chỉ +0,6% (AGI đã cho cả Tấn công lẫn chí mạng; với +1% thì
## ở cấp 17 Thợ Săn hạ Huyền Ảnh nhanh hơn 2 lớp kia 31%).
const AGI_SPEED := 0.01
const HUNTER_AGI_SPEED := 0.006
## M6 (TL-B3): chí mạng mỗi điểm AGI — Thợ Săn chỉ +0,25% (lớp khác +0,5%). Ở cấp 29 (84 AGI) Thợ Săn hạ
## Sa Hoàng nhanh hơn Kiếm Khách 47% vì AGI cộng cả Tấn công, tốc đánh lẫn chí mạng.
const AGI_CRIT := 0.005
## M6 (TL-B3): tốc đánh từ AGI của Thợ Săn tối đa +20% (≈ 33 AGI, cấp 12) — tránh tăng tuyến tính mãi.
const HUNTER_SPEED_CAP := 0.20
const HUNTER_AGI_CRIT := 0.0025
## SN-02: Pháp Sư.
const MAGE_MP := 30
const MAGE_MP_REGEN := 1.0
## UI-19: chỉ số mặc định theo lớp (tổng 17) — hiện ở trang Chỉ số dạng "mặc định + điểm cộng". Tính như điểm thường;
## phần nền theo lớp + cấp đã trừ đúng phần chỉ số mặc định đóng góp, nên chỉ số cuối cùng giữ nguyên như trước khi có mặc định
## (không lệch cân bằng TL-B…). Trần (tốc đánh Thợ Săn, né, rơi đồ) vẫn áp lên phần trên mặc định như cũ.
const BASE_STATS := {
	"kiem-khach": {"str": 5, "agi": 3, "int": 2, "vit": 5, "luk": 2},
	"tho-san": {"str": 3, "agi": 5, "int": 2, "vit": 4, "luk": 3},
	"phap-su": {"str": 2, "agi": 3, "int": 5, "vit": 4, "luk": 3},
}


static func base_stats(class_id: String) -> Dictionary:
	return BASE_STATS.get(class_id, BASE_STATS["kiem-khach"])


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
## base: chỉ số mặc định dùng thay cho BASE_STATS của lớp (trang Chỉ số dùng để tính "mỗi chỉ số đang cho bao nhiêu").
static func derive(level: int, pts: Dictionary, talent: String, bonus := {}, talent_level := 1,
		class_id := "kiem-khach", stolen: Array = [], base = null) -> Dictionary:
	var lv := level - 1
	var t := total_points(pts, stolen)
	var b0: Dictionary = base_stats(class_id)
	var bs: Dictionary = b0 if base == null else base
	# chỉ số = mặc định + điểm cộng (+ điểm Đạo Tặc cướp)
	for k in STATS:
		t[k] = int(t[k]) + int(bs.get(k, 0))
	var str_pts: int = t.str
	var agi_pts: int = t.agi
	var int_pts: int = t.int
	var vit_pts: int = t.vit
	var luk_pts: int = t.luk
	# phần nền đã trừ đúng phần mặc định của lớp đóng góp (b0) — chỉ số cuối cùng như khi chưa có mặc định
	var b_str: int = int(b0.str)
	var b_agi: int = int(b0.agi)
	var b_int: int = int(b0.int)
	var b_vit: int = int(b0.vit)
	var b_luk: int = int(b0.luk)
	var hunter := class_id == "tho-san"
	var mage := class_id == "phap-su"
	var flat: Dictionary = bonus.get("flat", {})
	var tlv := clampi(talent_level, 1, Talents.MAX_EFFECTIVE_LEVEL)
	# TL-10: mỗi cấp Thiên phú trên 1 → +2% Tấn công và HP.
	var tl_pct := 0.02 * (tlv - 1)
	var dragon := Talents.lv_value(0.1, 0.15, tlv) if bonus.get("dragon", false) else 0.0
	var hp_pct: float = bonus.get("max_hp_pct", 0.0) + tl_pct + dragon \
		+ (Talents.lv_value(0.08, 0.12, tlv) if talent == "than-the" else 0.0)
	var atk_pct: float = bonus.get("atk_pct", 0.0) + tl_pct + dragon
	var crit_bonus := 0.05 if Talents.has_sub(talent, talent_level, "combat", 1) else 0.0
	var crit_dmg_bonus := 0.15 if Talents.has_sub(talent, talent_level, "combat", 2) else 0.0
	# CL: Kiếm Khách lấy Tấn công từ STR; Thợ Săn từ AGI (STR phụ), máu mỏng hơn, né gốc 5%.
	# SN-02: Pháp Sư lấy Tấn công từ INT, máu mỏng nhất, MP gốc +30, hồi MP +1/giây.
	var atk_from_pts: float = (str_pts - b_str) * 2
	var base_hp := 100 + lv * 15
	if hunter:
		atk_from_pts = (agi_pts - b_agi) * 2 + (str_pts - b_str)
		base_hp = 90 + lv * 13
	elif mage:
		atk_from_pts = (int_pts - b_int) * 2
		base_hp = 85 + lv * 12
	vit_pts -= b_vit
	int_pts -= b_int
	luk_pts -= b_luk
	agi_pts -= b_agi
	return {
		"class": class_id,
		"max_hp": int(round((base_hp + vit_pts * 12 + flat.get("max_hp", 0.0)) * (1.0 + hp_pct))),
		"atk": (10.0 + lv * 2 + atk_from_pts + flat.get("atk", 0.0)) * (1.0 + atk_pct),
		"def": 5.0 + lv * 1.5 + vit_pts * 0.5 + flat.get("def", 0.0),
		"atk_speed": 1.0 + (minf(HUNTER_SPEED_CAP, agi_pts * HUNTER_AGI_SPEED) if hunter else agi_pts * AGI_SPEED) + (Talents.lv_value(0.05, 0.075, tlv) if talent == "tay-nhanh" else 0.0) + flat.get("atk_speed", 0.0)
			+ float(bonus.get("atk_speed_pct", 0.0)),
		"crit": minf(0.6, 0.05 + agi_pts * (HUNTER_AGI_CRIT if hunter else AGI_CRIT) + luk_pts * 0.003
			+ (Talents.lv_value(0.1, 0.15, tlv) if talent == "mat-ung" else 0.0) + flat.get("crit", 0.0) + crit_bonus),
		## Chí mạng gây ×(1 + crit_dmg); gốc 0,5 → ×1,5.
		"crit_dmg": 0.5 + flat.get("crit_dmg", 0.0) + crit_dmg_bonus,
		"move_speed": (230.0 + flat.get("move_speed", 0.0)) * (1.0 + float(bonus.get("move_pct", 0.0))),
		"spin_cd": BASE_SPIN_CD - float(bonus.get("spin_cd", 0.0)),
		"uniques": bonus.get("uniques", []),
		# ST-01…04 (M3)
		"max_mp": 50 + lv * 5 + int_pts * 6 + (MAGE_MP if mage else 0),
		"mp_regen": 3.0 + int_pts * 0.05 + (MAGE_MP_REGEN if mage else 0.0),
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
