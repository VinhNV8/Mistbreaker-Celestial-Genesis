extends RefCounted
## Chỉ số phái sinh từ lớp + cấp + thuộc tính (khởi tạo + tự tăng + điểm tiềm năng + điểm Đạo Tặc cướp) + Thiên phú
## (và cấp Thiên phú) + trang bị.
## CS (docs/26, gộp docs/24 + CR-001): 7 thuộc tính; mỗi lớp có thuộc tính khởi tạo + tự tăng mỗi cấp theo CR-001,
## phần gốc theo cấp (HP, Tấn công, Phòng thủ, MP) hiện ở trang Chỉ số; Tấn công chỉ lấy từ thuộc tính chính của lớp.

const Talents = preload("res://scripts/data/talents.gd")

const BASE_SPIN_CD := 6.0
const STATS := ["str", "agi", "vit", "int", "wis", "dex", "luk"]
## Trần chung (docs/26 mục 2.1).
const EVASION_CAP := 0.3
const RES_CAP := 0.5
const CRIT_CAP := 0.6
const SPEED_CAP := 2.0
const PEN_CAP := 0.4
const DROP_CAP := 0.10

## CR-001: thuộc tính khởi tạo (cấp 1) và tự tăng mỗi cấp.
const START := {
	"kiem-khach": {"str": 18, "agi": 15, "vit": 12, "int": 5, "wis": 6, "dex": 14, "luk": 10},
	"tho-san": {"str": 8, "agi": 20, "vit": 10, "int": 6, "wis": 8, "dex": 19, "luk": 14},
	"phap-su": {"str": 4, "agi": 8, "vit": 8, "int": 24, "wis": 18, "dex": 10, "luk": 8},
	"ho-ve": {"str": 14, "agi": 6, "vit": 22, "int": 5, "wis": 10, "dex": 8, "luk": 5},
	"trieu-hoi-su": {"str": 3, "agi": 10, "vit": 12, "int": 20, "wis": 20, "dex": 10, "luk": 10},
}
const GROW := {
	"kiem-khach": {"str": 2.5, "agi": 2.0, "dex": 1.5, "vit": 1.0},
	"tho-san": {"agi": 2.5, "dex": 2.5, "luk": 1.5},
	"phap-su": {"int": 3.0, "wis": 2.0, "dex": 1.0},
	"ho-ve": {"vit": 3.0, "str": 1.5, "wis": 1.0},
	"trieu-hoi-su": {"int": 2.5, "wis": 2.5, "vit": 1.0},
}
## Phần gốc theo cấp + đặc tính lớp (docs/26 mục 2.2, 3.1).
## MP-1 (docs/49, Spec_Notes 10/11 "MP quá ít, ra vài chiêu đã hết"): 3 lớp vật lý MP gốc 25 → 55, mỗi cấp +3,5 / +4;
## mp_hit: MP hồi mỗi lượt đánh thường trúng (kiểu "đánh thường tích nội lực" của ARPG hiện đại) — lớp phép = 0.
## hp0/hpg, atkg, defg, mp0/mpg: gốc cấp 1 / mỗi cấp; atkx: Tấn công gốc mỗi cấp cộng thêm từ cấp 31 (cân bằng: Hộ Vệ mạnh dần,
## Thợ Săn chậm lại; xem thêm LATE_ATK từ cấp 81). aspd: tốc đánh gốc. crit/crit_dmg/eva/pen/skill: cộng thêm của lớp.
## atk: Tấn công mỗi điểm thuộc tính. hp_vit: HP mỗi VIT. def_mult: Phòng thủ × (Hộ Vệ +30%). cc: kháng hiệu ứng.
const CLASS := {
	"kiem-khach": {"hp0": 50.0, "hpg": 20.0, "atkg": 3.0, "defg": 1.2, "mp0": 55.0, "mpg": 3.5, "mp_hit": 0.0, "aspd": 1.0, "move": 265.0,
		"crit": 0.05, "crit_dmg": 0.2, "eva": 0.10, "eva_cap": EVASION_CAP, "pen": 0.0, "skill": 0.0, "def_mult": 1.0, "cc": 0.0,
		"hp_vit": 5.0, "atk": {"str": 0.6}},
	"tho-san": {"hp0": 30.0, "hpg": 22.0, "atkg": 5.6, "atkx": -1.2, "defg": 1.0, "mp0": 55.0, "mpg": 4.0, "mp_hit": 1.0, "aspd": 1.0, "move": 250.0,
		"crit": 0.15, "crit_dmg": 0.0, "eva": 0.0, "eva_cap": 0.4, "pen": 0.10, "skill": 0.0, "def_mult": 1.0, "cc": 0.0,
		"hp_vit": 5.0, "atk": {"dex": 0.25, "agi": 0.2, "str": 0.1}},
	"phap-su": {"hp0": 35.0, "hpg": 24.0, "atkg": 4.0, "defg": 0.85, "mp0": 50.0, "mpg": 12.0, "aspd": 0.95, "move": 220.0,
		"crit": 0.0, "crit_dmg": 0.0, "eva": 0.0, "eva_cap": EVASION_CAP, "pen": 0.15, "skill": 0.2, "def_mult": 1.0, "cc": 0.0,
		"hp_vit": 5.0, "atk": {"int": 0.45}},
	"ho-ve": {"hp0": 0.0, "hpg": 16.0, "atkg": 8.0, "atkx": 2.8, "defg": 1.6, "mp0": 40.0, "mpg": 3.0, "mp_hit": 0.0, "aspd": 0.9, "move": 210.0,
		"crit": 0.0, "crit_dmg": 0.0, "eva": 0.0, "eva_cap": EVASION_CAP, "pen": 0.0, "skill": 0.0, "def_mult": 1.3, "cc": 0.25,
		"hp_vit": 6.0, "atk": {"str": 0.55, "vit": 0.12}},
	"trieu-hoi-su": {"hp0": 25.0, "hpg": 25.0, "atkg": 5.6, "atkx": 0.6, "defg": 1.3, "mp0": 30.0, "mpg": 10.0, "aspd": 1.0, "move": 220.0,
		"crit": 0.0, "crit_dmg": 0.0, "eva": 0.0, "eva_cap": EVASION_CAP, "pen": 0.0, "skill": 0.0, "def_mult": 1.0, "cc": 0.0,
		"hp_vit": 5.0, "atk": {"int": 0.45}},
}
## Tác dụng chung mỗi điểm (docs/26 mục 2.1).
const AGI_SPEED := 0.0015
const AGI_CRIT := 0.0005
const AGI_EVA := 0.0008
const VIT_DEF := 0.25
const INT_MP := 3.0
const INT_SKILL := 0.003
const WIS_REGEN := 0.02
const WIS_RES := 0.001
const DEX_PEN := 0.001
const DEX_POISE := 0.002
const LUK_CRIT := 0.0015
const LUK_DROP := 0.001
const BASE_CRIT := 0.03
const BASE_REGEN := 3.0
## MP-1 (docs/49): ngoài giao tranh hồi MP ×3.
const MP_OOC_MULT := 3.0
## Riêng lớp: WIS của Triệu Hồi Sư +0,3% HP linh thú; WIS của Hộ Vệ +0,1% kháng hiệu ứng (trần 60%).
const SUMMONER_WIS_PET := 0.003
const GUARD_WIS_CC := 0.001
const CC_CAP := 0.6
## Q167: chí mạng vượt trần 60% của Thợ Săn đổi thành ST chí mạng (0,15% chí mạng → 0,2% ST chí mạng).
const HUNTER_OVERCAP := 0.002 / 0.0015


static func class_of(class_id: String) -> String:
	return class_id if CLASS.has(class_id) else "kiem-khach"


## Thuộc tính khởi tạo của lớp (CR-001).
static func base_stats(class_id: String) -> Dictionary:
	return START[class_of(class_id)]


## CS cân bằng TL-J3: từ cấp 81 Tấn công gốc mỗi cấp giảm bớt (thuộc tính tự tăng đã dồn đủ mạnh) — giữ nhịp chương 8–9
## như trước CS và để chức 3 của Hộ Vệ (Thần Kỹ thay Khiên Thép) không nhanh hơn chức 2 quá 20%.
const LATE_LEVEL := 80
const LATE_ATK := {"kiem-khach": -10.0, "tho-san": -14.0, "phap-su": -10.0, "ho-ve": -22.0, "trieu-hoi-su": -10.0}


## Tấn công gốc theo cấp (không tính thuộc tính).
static func base_atk(class_id: String, level: int) -> float:
	var c: Dictionary = CLASS[class_of(class_id)]
	var cid := class_of(class_id)
	return float(c.atkg) * maxi(0, level - 1) + float(c.get("atkx", 0.0)) * maxi(0, level - 30) \
		+ float(LATE_ATK[cid]) * maxi(0, level - LATE_LEVEL)


## Thuộc tính tự tăng tới cấp level (làm tròn xuống).
static func grown(class_id: String, level: int) -> Dictionary:
	var g: Dictionary = GROW[class_of(class_id)]
	var out := {}
	for k in STATS:
		out[k] = int(floor(float(g.get(k, 0.0)) * maxi(0, level - 1) + 0.0001))
	return out


## Đọc điểm an toàn với save/test cũ thiếu khoá.
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


## Thuộc tính cuối = khởi tạo + tự tăng + điểm cộng (+ cướp). skip: bỏ hẳn thuộc tính đó (trang Chỉ số tính "đang cho bao nhiêu").
static func attributes(level: int, pts: Dictionary, class_id: String, stolen: Array = [], skip := "") -> Dictionary:
	var t := total_points(pts, stolen)
	var s: Dictionary = base_stats(class_id)
	var g := grown(class_id, level)
	var out := {}
	for k in STATS:
		out[k] = 0 if k == skip else int(s.get(k, 0)) + int(g[k]) + int(t[k])
	return out


## bonus: kết quả Items.equipment_bonus() — {flat: {stat: value}, max_hp_pct, atk_pct, spin_cd, uniques},
## cộng thêm "dragon": true khi Long Mạch Đàn đã xây xong.
## skip: bỏ thuộc tính đó (trang Chỉ số dùng để tính "mỗi thuộc tính đang cho bao nhiêu").
static func derive(level: int, pts: Dictionary, talent: String, bonus := {}, talent_level := 1,
		class_id := "kiem-khach", stolen: Array = [], skip := "") -> Dictionary:
	var lv := maxi(0, level - 1)
	var cid := class_of(class_id)
	var c: Dictionary = CLASS[cid]
	var a := attributes(level, pts, cid, stolen, skip)
	var flat: Dictionary = bonus.get("flat", {})
	var tlv := clampi(talent_level, 1, Talents.MAX_EFFECTIVE_LEVEL)
	# C8-10 (M11): hiệu lực Thiên phú (Suy Thiên, Hút Thiên phú) — nhân mọi phần chỉ số đến từ Thiên phú.
	var tk: float = float(bonus.get("talent_k", 1.0))
	# TL-10: mỗi cấp Thiên phú trên 1 → +2% Tấn công và HP.
	var tl_pct := 0.02 * (tlv - 1) * tk
	# TP-05 (docs/33): GameWorld truyền sẵn giá trị Thiên phú chính + phụ (cấp riêng, cộng hưởng) qua bonus.talent_vals /
	# dragon_val / combat_sub1/2; không có (trang Chỉ số, màn chọn lớp) thì tính theo Thiên phú chính như cũ.
	var tvals: Dictionary = bonus.get("talent_vals", {})
	var dragon: float = float(bonus.get("dragon_val", Talents.lv_value(0.1, 0.15, tlv))) * tk if bonus.get("dragon", false) else 0.0
	var v_tough: float = float(tvals.get("than-the", Talents.lv_value(0.08, 0.12, tlv) if talent == "than-the" else 0.0))
	var v_eagle: float = float(tvals.get("mat-ung", Talents.lv_value(0.1, 0.15, tlv) if talent == "mat-ung" else 0.0))
	var v_quick: float = float(tvals.get("tay-nhanh", Talents.lv_value(0.05, 0.075, tlv) if talent == "tay-nhanh" else 0.0))
	var hp_pct: float = bonus.get("max_hp_pct", 0.0) + tl_pct + dragon + v_tough * tk
	var atk_pct: float = bonus.get("atk_pct", 0.0) + tl_pct + dragon
	var crit_bonus := 0.05 if bool(bonus.get("combat_sub1", Talents.has_sub(talent, talent_level, "combat", 1))) else 0.0
	var crit_dmg_bonus := 0.15 if bool(bonus.get("combat_sub2", Talents.has_sub(talent, talent_level, "combat", 2))) else 0.0
	var atk_attr := 0.0
	var per: Dictionary = c.atk
	for k in per:
		atk_attr += float(a[k]) * float(per[k])
	var raw_crit: float = BASE_CRIT + float(c.crit) + a.agi * AGI_CRIT + a.luk * LUK_CRIT \
		+ v_eagle * tk + flat.get("crit", 0.0) + crit_bonus
	var overcap := maxf(0.0, raw_crit - CRIT_CAP) * HUNTER_OVERCAP if cid == "tho-san" else 0.0
	var res_wis: float = a.wis * WIS_RES
	var cc: float = float(c.cc) + (a.wis * GUARD_WIS_CC if cid == "ho-ve" else 0.0)
	return {
		"class": cid,
		"attrs": a,
		"max_hp": int(round((float(c.hp0) + float(c.hpg) * lv + a.vit * float(c.hp_vit) + flat.get("max_hp", 0.0)) * (1.0 + hp_pct))),
		"atk": (base_atk(cid, level) + atk_attr + flat.get("atk", 0.0)) * (1.0 + atk_pct),
		"def": (2.0 + float(c.defg) * lv + a.vit * VIT_DEF) * float(c.def_mult) + flat.get("def", 0.0),
		"atk_speed": minf(SPEED_CAP, float(c.aspd) + a.agi * AGI_SPEED + v_quick * tk
			+ flat.get("atk_speed", 0.0) + float(bonus.get("atk_speed_pct", 0.0))),
		"crit": minf(CRIT_CAP, raw_crit),
		## Chí mạng gây ×(1 + crit_dmg); gốc 0,5 → ×1,5.
		"crit_dmg": 0.5 + float(c.crit_dmg) + flat.get("crit_dmg", 0.0) + crit_dmg_bonus + overcap,
		"move_speed": (float(c.move) + flat.get("move_speed", 0.0)) * (1.0 + float(bonus.get("move_pct", 0.0))),
		"spin_cd": BASE_SPIN_CD - float(bonus.get("spin_cd", 0.0)),
		"uniques": bonus.get("uniques", []),
		"max_mp": int(round(float(c.mp0) + float(c.mpg) * lv + a.int * INT_MP)),
		"mp_regen": BASE_REGEN + a.wis * WIS_REGEN,
		"mp_hit": float(c.get("mp_hit", 0.0)),
		"skill_mul": 1.0 + a.int * INT_SKILL + float(c.skill),
		"drop_bonus": minf(DROP_CAP, a.luk * LUK_DROP),
		"evasion": minf(float(c.eva_cap), float(c.eva) + a.agi * AGI_EVA),
		## CS: xuyên giáp (bỏ qua % Phòng thủ quái), sát thương thêm vào thanh Phá Thế, kháng hiệu ứng, HP linh thú.
		"armor_pen": minf(PEN_CAP, float(c.pen) + a.dex * DEX_PEN),
		"poise_bonus": a.dex * DEX_POISE,
		"cc_resist": minf(CC_CAP, cc),
		"pet_hp_pct": a.wis * SUMMONER_WIS_PET if cid == "trieu-hoi-su" else 0.0,
		# NV-17: kháng hệ (tối đa 50%), M4.2; CS: WIS cộng đều 5 hệ.
		"res": {
			"kim": minf(RES_CAP, res_wis + flat.get("res_kim", 0.0)), "moc": minf(RES_CAP, res_wis + flat.get("res_moc", 0.0)),
			"thuy": minf(RES_CAP, res_wis + flat.get("res_thuy", 0.0)), "hoa": minf(RES_CAP, res_wis + flat.get("res_hoa", 0.0)),
			"tho": minf(RES_CAP, res_wis + flat.get("res_tho", 0.0)),
		},
		"dodge_cd": 3.0 - float(bonus.get("dodge_cd", 0.0)),
	}
