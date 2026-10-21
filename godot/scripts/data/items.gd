extends RefCounted
## Dữ liệu trang bị — theo đặc tả MVP M1 (docs/03-mvp-spec.md, mục 3.3–3.7).

## EQ-01: 8 ô trang bị. base = chỉ số gốc; value = a + b·L (L = cấp đồ).
const SLOTS := {
	"weapon": {"name": "Vũ khí", "item": "Kiếm", "base": "atk", "a": 4.0, "b": 2.0},
	"helm": {"name": "Mũ", "item": "Mũ", "base": "max_hp", "a": 10.0, "b": 5.0},
	"armor": {"name": "Áo", "item": "Giáp", "base": "def", "a": 2.0, "b": 1.0},
	"gloves": {"name": "Găng", "item": "Găng", "base": "atk", "a": 1.0, "b": 0.8},
	"boots": {"name": "Giày", "item": "Giày", "base": "max_hp", "a": 6.0, "b": 3.0},
	"necklace": {"name": "Dây chuyền", "item": "Dây Chuyền", "base": "crit", "a": 0.02, "b": 0.001},
	"ring": {"name": "Nhẫn", "item": "Nhẫn", "base": "crit_dmg", "a": 0.08, "b": 0.004},
	"amulet": {"name": "Bùa hộ mệnh", "item": "Bùa", "base": "max_hp", "a": 8.0, "b": 4.0},
}
const SLOT_ORDER := ["weapon", "helm", "armor", "gloves", "boots", "necklace", "ring", "amulet"]

## EQ-02: phẩm chất, số affix, hệ số chỉ số gốc, Đá Cường Hoá khi phân rã (3.6).
const RARITIES := {
	"white": {"name": "Trắng", "affixes": 0, "mult": 1.0, "salvage": 1, "color": "#e6e6e6", "prefix": "Cũ"},
	"green": {"name": "Xanh lá", "affixes": 1, "mult": 1.1, "salvage": 2, "color": "#5bd16a", "prefix": "Sắt"},
	"blue": {"name": "Xanh dương", "affixes": 2, "mult": 1.2, "salvage": 3, "color": "#4a9df8", "prefix": "Tinh Luyện"},
	"purple": {"name": "Tím", "affixes": 3, "mult": 1.35, "salvage": 5, "color": "#b36bff", "prefix": "Huyền Thiết"},
	"orange": {"name": "Cam", "affixes": 4, "mult": 1.5, "salvage": 8, "color": "#ff9a3c", "prefix": "Huyền Thoại"},
}
const RARITY_ORDER := ["white", "green", "blue", "purple", "orange"]

## 3.4: affix; value = (a + b·L) × ngẫu nhiên 0,8–1,2.
## Kháng hệ chỉ có ở đồ phòng thủ (vũ khí, găng, nhẫn giữ affix tấn công) — M4.2.
const RES_SLOTS := ["helm", "armor", "boots", "necklace", "amulet"]
const AFFIXES := {
	"atk": {"name": "Tấn công", "a": 1.0, "b": 0.6},
	"max_hp": {"name": "HP", "a": 6.0, "b": 3.0},
	"def": {"name": "Phòng thủ", "a": 1.0, "b": 0.4},
	"crit": {"name": "Chí mạng", "a": 0.03, "b": 0.0},
	"crit_dmg": {"name": "Sát thương chí mạng", "a": 0.10, "b": 0.0},
	"atk_speed": {"name": "Tốc đánh", "a": 0.04, "b": 0.0},
	"move_speed": {"name": "Tốc chạy", "a": 10.0, "b": 0.0},
	# NV-17 (M4.2): kháng 5 hệ — giảm % sát thương nhận từ quái hệ đó (tối đa 50%).
	"res_kim": {"name": "Kháng Kim", "a": 0.03, "b": 0.002, "slots": RES_SLOTS},
	"res_moc": {"name": "Kháng Mộc", "a": 0.03, "b": 0.002, "slots": RES_SLOTS},
	"res_thuy": {"name": "Kháng Thủy", "a": 0.03, "b": 0.002, "slots": RES_SLOTS},
	"res_hoa": {"name": "Kháng Hỏa", "a": 0.03, "b": 0.002, "slots": RES_SLOTS},
	"res_tho": {"name": "Kháng Thổ", "a": 0.03, "b": 0.002, "slots": RES_SLOTS},
}
## Chỉ số hiển thị dạng phần trăm.
const PERCENT_STATS := ["crit", "crit_dmg", "atk_speed", "res_kim", "res_moc", "res_thuy", "res_hoa", "res_tho"]

## 3.5: tỉ lệ lên từ +n → +n+1, chỉ số mảng = n.
const ENHANCE_RATES := [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.8, 0.7, 0.6, 0.5, 0.4, 0.3, 0.25, 0.2]
const MAX_PLUS := 15

## EQ-05/06: bảng phẩm chất rơi theo nguồn.
const DROP_TABLES := {
	"field": {"white": 60.0, "green": 35.0, "blue": 5.0},
	"elite": {"blue": 65.0, "purple": 35.0},
	"relic": {"blue": 100.0},
}
const FIELD_ITEM_CHANCE := 0.06
const FIELD_STONE_CHANCE := 0.25
const BOSS_UNIQUE_CHANCE := 0.15
## 25% đồ Tím rơi trong vùng là đồ bộ của vùng.
const SET_CHANCE := 0.25

## EQ-15: bộ trang bị vùng 1. bonus: max_hp_pct / atk_pct / spin_cd (giây giảm).
const SETS := {
	"frost_hunter": {
		"name": "Bộ Thợ Săn Sương",
		"suffix": "Thợ Săn Sương",
		"tiers": [
			{"count": 2, "text": "+8% HP tối đa", "bonus": {"max_hp_pct": 0.08}},
			{"count": 4, "text": "+10% Tấn công", "bonus": {"atk_pct": 0.10}},
			{"count": 6, "text": "Xoáy Kiếm hồi chiêu 6 → 4 giây", "bonus": {"spin_cd": 2.0}},
		],
	},
	## TB-04 (M4.2): bộ vùng 2.
	"phong_hanh": {
		"name": "Bộ Phong Hành",
		"suffix": "Phong Hành",
		"tiers": [
			{"count": 2, "text": "+8% tốc chạy", "bonus": {"move_pct": 0.08}},
			{"count": 4, "text": "+8% tốc đánh", "bonus": {"atk_speed_pct": 0.08}},
			{"count": 6, "text": "Né lăn hồi chiêu 3 → 2 giây", "bonus": {"dodge_cd": 1.0}},
		],
	},
	## C3-35 (M6): bộ vùng 3.
	"sa_hanh": {
		"name": "Bộ Sa Hành Giả",
		"suffix": "Sa Hành Giả",
		"tiers": [
			{"count": 2, "text": "Miễn nhiễm Nắng gắt", "bonus": {}},
			{"count": 4, "text": "+10% Phòng thủ", "bonus": {}},
			{"count": 6, "text": "Xoáy Kiếm / Mưa Tên / Băng Ngục để lại lốc cát 4 giây làm chậm quái 40%", "bonus": {}},
		],
	},
}
## C3-35 (M6): bộ vùng 3 — hiệu ứng xử lý trong code (core/chapter3.gd, GameWorld._derive), bonus để trống.
const SA_HANH := "sa_hanh"
const REGION_SET := "frost_hunter"
## Đồ Tím rơi ở vùng nào thì thuộc bộ của vùng đó (M4.2).
const REGION_SETS := {1: "frost_hunter", 2: "phong_hanh", 3: "sa_hanh"}
## Đồ Cam của từng boss chương.
const BOSS_UNIQUES := {"boss": "wolf_fang", "huyen-anh": "huyen_anh_mask", "sa-hoang": "sa_hoang_tail"}

## EQ-16: đồ Cam có hiệu ứng riêng.
const UNIQUES := {
	"wolf_fang": {
		"name": "Nanh Sói Chúa",
		"slot": "weapon",
		"text": "Mỗi đòn chém thứ 3 gây thêm 60% sát thương.",
	},
	## M4.2: rơi từ Tướng Gián Điệp Huyền Ảnh (15%).
	"huyen_anh_mask": {
		"name": "Mặt Nạ Huyền Ảnh",
		"slot": "helm",
		"text": "Né lăn để lại 1 phân thân hút đòn của quái trong 2 giây.",
	},
	## C3-31 (M6): rơi từ Bọ Cạp Sa Hoàng (15%).
	"sa_hoang_tail": {
		"name": "Đuôi Sa Hoàng",
		"slot": "weapon",
		"text": "Đòn đánh gây độc ×0,2 mỗi giây trong 4 giây, cộng dồn 3 lần.",
	},
	## C3-34 (M6): rơi từ boss hiếm Nhân Sư Đá.
	"nhan_su_eye": {
		"name": "Mắt Nhân Sư",
		"slot": "necklace",
		"text": "+10% chí mạng; chí mạng vào quái bị khắc hệ gây ×1,2.",
	},
	## C1-23: rơi từ boss hiếm Lão Thụ Sương Mù.
	"lao_thu_bark": {
		"name": "Vỏ Lão Thụ",
		"slot": "amulet",
		"text": "Đứng yên 1 giây thì hồi 2% HP mỗi giây.",
	},
	## M5-01: rơi từ boss hiếm Bạch Hổ Phong Vân.
	"bach_ho_claw": {
		"name": "Vuốt Bạch Hổ",
		"slot": "gloves",
		"text": "Đòn chí mạng gây chảy máu: 30% Tấn công mỗi giây trong 4 giây.",
	},
}
const BOSS_UNIQUE := "wolf_fang"

const BAG_SIZE := 30
