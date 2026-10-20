extends RefCounted
## Quái vùng 1 (tài liệu 06). HP/Tấn công/Phòng thủ KHÔNG ghi ở đây: tính bằng Formulas.mob_stats(cấp, bậc, arch)
## lúc sinh quái (CB-21). windup = thời gian vung đòn (có vòng báo hiệu) — cửa sổ để người chơi né.
## element: hệ ngũ hành (TL-S6). steal: bảng đặc trưng Đạo Tặc cướp (CR-01, %).
## elite_*: quái tinh anh của loại này (CB-13); loại không có elite_name thì không sinh tinh anh.

const ELEMENT_ORDER := ["kim", "moc", "thuy", "hoa", "tho"]
const ELEMENT_NAMES := {"kim": "Kim", "moc": "Mộc", "thuy": "Thủy", "hoa": "Hỏa", "tho": "Thổ"}
const ELEMENT_HEX := {"kim": "#e8e2c8", "moc": "#5bd16a", "thuy": "#4a9df8", "hoa": "#ff6a3c", "tho": "#c9a45c"}
## Hệ tấn công → hệ bị khắc: Kim → Mộc → Thổ → Thủy → Hỏa → Kim (kịch bản mục 5).
const COUNTERS := {"kim": "moc", "moc": "tho", "tho": "thuy", "thuy": "hoa", "hoa": "kim"}
const COUNTER_BONUS := 0.3
const STAT_NAMES := {"str": "STR", "agi": "AGI", "int": "INT", "vit": "VIT", "luk": "LUK"}


static func counters(attacker: String, defender: String) -> bool:
	return COUNTERS.get(attacker, "") == defender


static func elite_capable(kind: String, level: int) -> bool:
	var d: Dictionary = DEFS[kind]
	return d.has("elite_name") and level >= int(d.elite_min_level)

const DEFS := {
	"wolf": {
		"element": "moc",
		"name": "Sói Sương",
		"arch": "nhanh",
		"speed": 150.0,
		"radius": 16.0,
		"range": 34.0,
		"windup": 0.45,
		"recover": 0.6,
		"attack": "melee",
		"color": "#8fa3b8",
		"steal": {"str": 35, "agi": 50, "vit": 15},
		"elite_name": "Sói Đầu Đàn",
		"elite_arch": "nhanh",
		"elite_min_level": 3,
		"elite_skill": "howl",
	},
	"mushroom": {
		"element": "tho",
		"name": "Nấm Độc",
		"arch": "xa",
		"speed": 70.0,
		"radius": 18.0,
		"range": 240.0,
		"windup": 0.7,
		"recover": 1.3,
		"attack": "spore",
		"color": "#b86fd6",
		"steal": {"vit": 45, "int": 35, "luk": 20},
		"elite_name": "Nấm Mẹ",
		"elite_arch": "li",
		"elite_min_level": 5,
		"elite_skill": "spawn",
	},
	"wisp": {
		"element": "thuy",
		"name": "Tinh Linh Sương",
		"arch": "phep",
		"speed": 115.0,
		"radius": 15.0,
		"range": 110.0,
		"windup": 0.35,
		"recover": 0.6,
		"attack": "dash",
		"color": "#9de0e6",
		"steal": {"agi": 35, "int": 45, "luk": 20},
		## C1-24: Lao sương — lao tới 15 m.
		"dash": 150.0,
	},
	## MC-01 (M3): chậm, phòng thủ cao, Dậm đất vòng 6 m.
	"moc-tinh": {
		"element": "moc",
		"name": "Mộc Tinh",
		"arch": "giap",
		"speed": 70.0,
		"radius": 18.0,
		"range": 34.0,
		"windup": 1.0,
		"recover": 1.2,
		"attack": "stomp",
		"color": "#4f9452",
		"steal": {"str": 40, "vit": 60},
	},
	## Nấm Con do Nấm Mẹ đẻ ra (CB-12): lao tới, tự nổ.
	"nam-con": {
		"element": "tho",
		"name": "Nấm Con",
		"arch": "tu_no",
		"speed": 150.0,
		"radius": 11.0,
		"range": 16.0,
		"windup": 0.5,
		"recover": 0.5,
		"attack": "explode",
		"color": "#dc86c6",
		"steal": {"vit": 45, "int": 35, "luk": 20},
	},
	## C1-23: boss hiếm Lõi Sương (06). Kỹ năng: Rễ Trói, Lá Độc, Rừng Thức Tỉnh (game_world._rare_*).
	"lao-thu": {
		"element": "moc",
		"name": "Lão Thụ Sương Mù",
		"arch": "li",
		"speed": 55.0,
		"radius": 38.0,
		"range": 40.0,
		"windup": 0.7,
		"recover": 0.9,
		"attack": "melee",
		"color": "#4f6a52",
		"steal": {"str": 30, "vit": 50, "int": 20},
	},
	## Gốc Rễ: đứng yên; còn gốc rễ thì Lão Thụ hồi máu.
	"goc-re": {
		"element": "moc",
		"name": "Gốc Rễ",
		"arch": "giap",
		"speed": 0.0,
		"radius": 16.0,
		"range": 0.0,
		"windup": 1.0,
		"recover": 1.0,
		"attack": "none",
		"color": "#674a32",
		"steal": {"vit": 100},
	},
	# ---------------------------------------------------------------- M4.2: vùng 2 (06 vùng 2)
	"ung-gio": {
		"element": "kim", "name": "Ưng Gió", "arch": "nhanh", "speed": 160.0, "radius": 15.0, "range": 150.0,
		"windup": 0.6, "recover": 0.9, "attack": "dive", "color": "#e8e2c8", "steal": {"agi": 60, "luk": 40},
	},
	## Khiên chặn: giảm 70% sát thương từ phía trước (±60°), không quay người khi đang vung đòn.
	"linh-danh-thue": {
		"element": "kim", "name": "Lính Đánh Thuê Hư Vô", "arch": "giap", "speed": 70.0, "radius": 18.0, "range": 40.0,
		"windup": 0.6, "recover": 0.9, "attack": "melee", "melee_mul": 1.2, "shield": true, "color": "#9ba8bc",
		"steal": {"str": 50, "vit": 50},
		"elite_name": "Đội Trưởng Đánh Thuê", "elite_arch": "giap", "elite_min_level": 13, "elite_skill": "whirl", "elite_sprite": "doi-truong",
	},
	"cung-thu": {
		"element": "moc", "name": "Cung Thủ Thảo Nguyên", "arch": "xa", "speed": 70.0, "radius": 16.0, "range": 240.0,
		"windup": 0.8, "recover": 1.2, "attack": "volley", "color": "#43754b", "steal": {"agi": 70, "luk": 30},
	},
	"loc-xoay": {
		"element": "kim", "name": "Lốc Xoáy Con", "arch": "phep", "speed": 110.0, "radius": 16.0, "range": 70.0,
		"windup": 2.0, "recover": 1.0, "attack": "pull", "color": "#e2e6ee", "steal": {"int": 60, "agi": 40},
		"elite_name": "Phù Thuỷ Gió", "elite_arch": "phep", "elite_min_level": 15, "elite_skill": "gale", "elite_sprite": "phu-thuy-gio",
	},
	## Boss chương 2 (kịch bản: phân thân 3 bản, chỉ bản thật có bóng).
	"huyen-anh": {
		"element": "kim", "name": "Tướng Gián Điệp Huyền Ảnh", "arch": "boss", "speed": 150.0, "radius": 28.0, "range": 50.0,
		"windup": 0.55, "recover": 1.1, "attack": "melee", "color": "#56308a", "steal": {"str": 30, "agi": 50, "int": 20},
	},
	"huyen-anh-ao": {
		"element": "kim", "name": "Bản sao Huyền Ảnh", "arch": "boss", "speed": 150.0, "radius": 28.0, "range": 230.0,
		"windup": 0.6, "recover": 2.2, "attack": "dart1", "color": "#56308a", "steal": {"agi": 100},
	},
	"boss": {
		"element": "moc",
		"name": "Sói Chúa Hư Vô",
		"arch": "boss",
		"speed": 175.0,
		"radius": 40.0,
		"range": 58.0,
		"windup": 0.55,
		"recover": 0.8,
		"attack": "melee",
		"color": "#6a5a92",
		"steal": {"str": 40, "agi": 30, "vit": 30},
	},
}
