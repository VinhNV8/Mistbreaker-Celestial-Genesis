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
	## M5-01: boss hiếm Mắt Bão (06 vùng 2). Kỹ năng: Hổ Vồ, Gầm Gió, Cưỡi Gió (game_world._update_rare).
	"bach-ho": {
		"element": "kim",
		"name": "Bạch Hổ Phong Vân",
		"arch": "nhanh",
		"speed": 105.0,
		"radius": 34.0,
		"range": 34.0,
		"windup": 0.6,
		"recover": 1.2,
		"attack": "melee",
		"color": "#e8e6dc",
		"steal": {"str": 40, "agi": 60},
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
	# ---------------------------------------------------------------- M6: vùng 3 Sa Mạc Xích Sa (06 vùng 3, docs/10)
	## C3-20: đi bầy 5 con. Tinh anh: Bọ Hung Giáp Vàng (khiên trước + Lăn cầu).
	"bo-cat": {
		"element": "tho", "name": "Bọ Cát", "arch": "bay", "speed": 140.0, "radius": 13.0, "range": 30.0,
		"windup": 0.4, "recover": 0.6, "attack": "melee", "color": "#b8663a", "steal": {"vit": 50, "str": 50}, "pack": 5,
		"elite_name": "Bọ Hung Giáp Vàng", "elite_arch": "giap", "elite_min_level": 23, "elite_skill": "roll", "elite_sprite": "bo-hung",
		"elite_element": "kim",
	},
	## C3-21: chui cát 1,5 giây (bất tử), trồi lên dưới chân người chơi vòng 3 m ×1,4.
	"ran-cat": {
		"element": "tho", "name": "Rắn Đồi Cát", "arch": "nhanh", "speed": 160.0, "radius": 14.0, "range": 34.0,
		"windup": 0.5, "recover": 0.8, "attack": "melee", "color": "#8a4428", "steal": {"agi": 60, "str": 40}, "burrow": true,
	},
	## C3-22: Nguyền rủa −20% hồi máu 6 giây. Tinh anh: Thủ Lĩnh Xác Ướp (Hồi sinh).
	"xac-uop": {
		"element": "tho", "name": "Xác Ướp Khai Giới", "arch": "li", "speed": 80.0, "radius": 17.0, "range": 36.0,
		"windup": 0.8, "recover": 1.0, "attack": "curse", "color": "#c4b78e", "steal": {"vit": 60, "int": 40},
		"elite_name": "Thủ Lĩnh Xác Ướp", "elite_arch": "li", "elite_min_level": 27, "elite_skill": "revive", "elite_sprite": "thu-linh-xac-uop",
	},
	## C3-23: đánh xa 18 m bằng Lốc cát (vòng 7 m tại chỗ người chơi, chậm 40% 3 giây).
	"phap-su-cat": {
		"element": "hoa", "name": "Pháp Sư Cát", "arch": "phep", "speed": 110.0, "radius": 16.0, "range": 180.0,
		"windup": 1.0, "recover": 1.3, "attack": "sandvortex", "color": "#d6a865", "steal": {"int": 70, "luk": 30},
	},
	## C3-30: boss chương 3.
	"sa-hoang": {
		"element": "tho", "name": "Bọ Cạp Sa Hoàng", "arch": "boss", "speed": 120.0, "radius": 34.0, "range": 50.0,
		"windup": 0.6, "recover": 0.8, "attack": "claw", "color": "#5a3418", "steal": {"str": 40, "vit": 40, "agi": 20},
	},
	## C3-33: boss hiếm 3-3.
	"nhan-su": {
		"element": "tho", "name": "Nhân Sư Đá", "arch": "giap", "speed": 90.0, "radius": 34.0, "range": 50.0,
		"windup": 0.7, "recover": 0.9, "attack": "melee", "color": "#d6a865", "steal": {"int": 40, "vit": 40, "str": 20},
	},
	# ---------------------------------------------------------------- M7: vùng 4 Đầm Lầy U Minh (06 vùng 4, docs/11)
	"ech-doc": {
		"element": "thuy", "name": "Ếch Độc", "arch": "xa", "speed": 70.0, "radius": 15.0, "range": 120.0,
		"windup": 0.7, "recover": 1.2, "attack": "tongue", "color": "#5bd16a", "steal": {"agi": 50, "vit": 50},
	},
	"dia": {
		"element": "thuy", "name": "Đỉa Hút Máu", "arch": "nhanh", "speed": 160.0, "radius": 11.0, "range": 26.0,
		"windup": 0.4, "recover": 0.8, "attack": "latch", "color": "#5a2a3a", "steal": {"vit": 60, "luk": 40},
	},
	"hon-ma": {
		"element": "thuy", "name": "Hồn Ma Đầm", "arch": "phep", "speed": 110.0, "radius": 16.0, "range": 70.0,
		"windup": 0.9, "recover": 1.1, "attack": "wail", "color": "#b4bac8", "steal": {"int": 70, "luk": 30},
		"elite_name": "Phù Thuỷ Đầm Lầy", "elite_arch": "phep", "elite_min_level": 36, "elite_skill": "toxrain", "elite_sprite": "phu-thuy-dam",
	},
	"ca-sau": {
		"element": "tho", "name": "Cá Sấu Bùn", "arch": "giap", "speed": 70.0, "radius": 20.0, "range": 40.0,
		"windup": 0.8, "recover": 1.1, "attack": "chomp", "color": "#4a5a32", "steal": {"str": 60, "vit": 40},
		"elite_name": "Cá Sấu Chúa", "elite_arch": "giap", "elite_min_level": 40, "elite_skill": "deathroll", "elite_sprite": "ca-sau-chua",
	},
	# ---------------------------------------------------------------- M8: vùng 5 Núi Viêm Long (06 vùng 5, docs/12)
	"than-lan-lua": {
		"element": "hoa", "name": "Thằn Lằn Lửa", "arch": "nhanh", "speed": 160.0, "radius": 14.0, "range": 26.0,
		"windup": 0.45, "recover": 0.8, "attack": "melee", "color": "#e0562a", "steal": {"agi": 60, "str": 40},
		"elite_name": "Rồng Non Lửa", "elite_arch": "nhanh", "elite_min_level": 50, "elite_skill": "flamebreath", "elite_sprite": "rong-non",
	},
	"nguoi-da": {
		"element": "tho", "name": "Người Đá Dung Nham", "arch": "giap", "speed": 70.0, "radius": 20.0, "range": 40.0,
		"windup": 0.8, "recover": 1.1, "attack": "punch", "color": "#45404c", "steal": {"vit": 60, "str": 40},
		"elite_name": "Thợ Rèn Hư Vô", "elite_arch": "giap", "elite_min_level": 54, "elite_skill": "forgehammer", "elite_sprite": "tho-ren-hu-vo",
	},
	## Mảnh Đá: Người Đá vỡ ra khi bị hạ (C5-21).
	"manh-da": {
		"element": "tho", "name": "Mảnh Đá", "arch": "bay", "speed": 120.0, "radius": 10.0, "range": 20.0,
		"windup": 0.4, "recover": 0.8, "attack": "melee", "color": "#6a6470", "steal": {"vit": 100},
	},
	"linh-hon-lua": {
		"element": "hoa", "name": "Linh Hồn Lửa", "arch": "tu_no", "speed": 170.0, "radius": 13.0, "range": 20.0,
		"windup": 0.8, "recover": 0.5, "attack": "fireburst", "color": "#ff7a1a", "steal": {"int": 50, "luk": 50},
	},
	"phap-su-hoa-diem": {
		"element": "hoa", "name": "Pháp Sư Hoả Diệm", "arch": "phep", "speed": 110.0, "radius": 16.0, "range": 180.0,
		"windup": 1.0, "recover": 1.2, "attack": "firepillar", "color": "#a8321c", "steal": {"int": 70, "luk": 30},
	},
	## Công Trại (C5-42, C5-26): lính Thương hội Kim Luân.
	"linh-kim-luan": {
		"element": "kim", "name": "Lính Kim Luân", "arch": "li", "speed": 100.0, "radius": 16.0, "range": 34.0,
		"windup": 0.6, "recover": 0.9, "attack": "melee", "color": "#d4a83a", "steal": {"str": 50, "vit": 50},
	},
	"doi-truong-kim-luan": {
		"element": "kim", "name": "Đội Trưởng Kim Luân", "arch": "li", "speed": 95.0, "radius": 20.0, "range": 40.0,
		"windup": 0.7, "recover": 1.0, "attack": "melee", "color": "#b8862a", "steal": {"str": 60, "vit": 40},
	},
	## C5-30: boss chương 5.
	"vien-long": {
		"element": "hoa", "name": "Viêm Long", "arch": "boss", "speed": 120.0, "radius": 40.0, "range": 60.0,
		"windup": 0.6, "recover": 0.9, "attack": "claw", "color": "#c83a1a", "steal": {"str": 50, "int": 50},
	},
	## C5-33: boss hiếm 5-3.
	"phuong-hoang": {
		"element": "hoa", "name": "Phượng Hoàng Tro", "arch": "phep", "speed": 140.0, "radius": 30.0, "range": 200.0,
		"windup": 0.8, "recover": 1.0, "attack": "featherbolt", "color": "#ff7a1a", "steal": {"int": 60, "luk": 40},
	},
	## C5-46: Xương Nô của Tử Linh Sư (đồng minh).
	"xuong-no": {
		"element": "", "name": "Xương Nô", "arch": "nhanh", "speed": 150.0, "radius": 14.0, "range": 26.0,
		"windup": 0.4, "recover": 0.6, "attack": "melee", "color": "#d2c8b2", "steal": {},
	},
	# ---------------------------------------------------------------- M9: vùng 6 Băng Nguyên Bắc Cực (06 vùng 6, docs/14)
	## C6-20: đi bầy 4 con; cắn +1 tầng băng giá.
	"soi-bang": {
		"element": "thuy", "name": "Sói Băng", "arch": "bay", "speed": 140.0, "radius": 15.0, "range": 30.0,
		"windup": 0.45, "recover": 0.7, "attack": "frostbite", "color": "#a8c8e8", "steal": {"agi": 60, "str": 40}, "pack": 4,
	},
	## C6-21: ném cầu tuyết vòng 3 m. Tinh anh: Gấu Băng Khổng Lồ (Đập băng 3 đường).
	"nguoi-tuyet": {
		"element": "thuy", "name": "Người Tuyết", "arch": "li", "speed": 80.0, "radius": 20.0, "range": 140.0,
		"windup": 0.9, "recover": 1.2, "attack": "snowball", "color": "#e8eef6", "steal": {"vit": 60, "str": 40},
		"elite_name": "Gấu Băng Khổng Lồ", "elite_arch": "li", "elite_min_level": 63, "elite_skill": "icecrack", "elite_sprite": "gau-bang",
	},
	## C6-22: Băng trụ vòng 4 m, đóng băng 1 giây. Tinh anh: Pháp Sư Bão Tuyết (Bão tuyết).
	"tinh-linh-bang": {
		"element": "thuy", "name": "Tinh Linh Băng", "arch": "phep", "speed": 110.0, "radius": 15.0, "range": 180.0,
		"windup": 1.0, "recover": 1.2, "attack": "icepillar", "color": "#7ad0ff", "steal": {"int": 70, "luk": 30},
		"elite_name": "Pháp Sư Bão Tuyết", "elite_arch": "phep", "elite_min_level": 66, "elite_skill": "blizzard", "elite_sprite": "phap-su-bao-tuyet",
		"elite_element": "kim",
	},
	## C6-23: mũi tên xuyên, tầm 24 m.
	"cung-thu-bang": {
		"element": "kim", "name": "Cung Thủ Băng", "arch": "xa", "speed": 70.0, "radius": 15.0, "range": 240.0,
		"windup": 0.8, "recover": 1.1, "attack": "icearrow", "color": "#c8d8ec", "steal": {"agi": 70, "luk": 30},
	},
	## C6-30: boss chương 6 — cái bóng của chính người chơi (vẽ theo dáng lớp người chơi).
	"ban-nga": {
		"element": "kim", "name": "Bản Ngã Bóng Tối", "arch": "boss", "speed": 140.0, "radius": 22.0, "range": 44.0,
		"windup": 0.5, "recover": 0.8, "attack": "melee", "color": "#2a1a42", "steal": {"str": 34, "agi": 33, "int": 33},
	},
	## C6-30b: Gương Băng giả (bất tử, phản sát thương).
	"guong-bang": {
		"element": "kim", "name": "Gương Băng", "arch": "li", "speed": 0.0, "radius": 22.0, "range": 0.0,
		"windup": 1.0, "recover": 1.0, "attack": "none", "color": "#b8d8f0", "steal": {"int": 100},
	},
	## C6-30c: Ảnh Bóng (Bản Ngã giai đoạn 3, nhóm triệu hồi).
	"anh-bong": {
		"element": "kim", "name": "Ảnh Bóng", "arch": "nhanh", "speed": 150.0, "radius": 13.0, "range": 26.0,
		"windup": 0.45, "recover": 0.7, "attack": "melee", "color": "#3a2a5a", "steal": {"agi": 100},
	},
	## C6-33: boss hiếm 6-3.
	"long-bang": {
		"element": "thuy", "name": "Long Băng Bắc Cực", "arch": "li", "speed": 110.0, "radius": 40.0, "range": 60.0,
		"windup": 0.6, "recover": 0.9, "attack": "icebite", "color": "#9ad8ff", "steal": {"vit": 50, "int": 50},
	},
	## C4-30: boss chương 4
	"nu-vuong": {
		"element": "thuy", "name": "Nữ Vương Phệ Mộng", "arch": "boss", "speed": 110.0, "radius": 30.0, "range": 50.0,
		"windup": 0.5, "recover": 0.8, "attack": "melee", "color": "#8248b8", "steal": {"int": 50, "agi": 30, "luk": 20},
	},
	"mong-chau": {
		"element": "thuy", "name": "Mộng Châu", "arch": "li", "speed": 0.0, "radius": 16.0, "range": 0.0,
		"windup": 1.0, "recover": 1.0, "attack": "none", "color": "#c28af0", "steal": {"int": 100},
	},
	## C4-33: boss hiếm 4-3 — thân bất tử, 7 đầu
	"thuy-quai": {
		"element": "thuy", "name": "Thuỷ Quái Thất Đầu", "arch": "li", "speed": 0.0, "radius": 44.0, "range": 0.0,
		"windup": 1.0, "recover": 1.0, "attack": "none", "color": "#1f5a9a", "steal": {"vit": 60, "str": 40},
	},
	"dau-thuy-quai": {
		"element": "thuy", "name": "Đầu Thuỷ Quái", "arch": "li", "speed": 0.0, "radius": 18.0, "range": 150.0,
		"windup": 0.8, "recover": 1.0, "attack": "jet", "color": "#3a86c8", "steal": {"vit": 100},
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
