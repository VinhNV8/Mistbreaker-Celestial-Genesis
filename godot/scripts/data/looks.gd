extends RefCounted
## C1-02: ngoại hình nhân vật. Hình: thân hero-<lớp>-<giới tính>-<da> + tóc hair-<lớp>-<kiểu> tô màu
## (tools/art/catalog.py sinh). Tên hiện trên màn hình Tạo nhân vật.

const GENDERS := ["nam", "nu"]
const GENDER_NAMES := {"nam": "Nam", "nu": "Nữ"}
const SKIN_NAMES := ["Sáng", "Vừa", "Ngăm"]
const HAIR_STYLES := ["ngan", "dai", "bui", "duoi"]
const HAIR_STYLE_NAMES := {"ngan": "Ngắn", "dai": "Dài", "bui": "Búi", "duoi": "Đuôi ngựa"}
## [tên, màu nhân lên dải xám của tóc]
const HAIR_COLORS := [
	["Đen", Color(0.32, 0.28, 0.38)],
	["Nâu", Color(0.66, 0.44, 0.28)],
	["Vàng", Color(1.0, 0.86, 0.45)],
	["Bạc", Color(0.96, 0.96, 1.0)],
	["Đỏ", Color(0.88, 0.32, 0.26)],
	["Lam", Color(0.42, 0.58, 0.98)],
]
const NAME_MIN := 2
const NAME_MAX := 16
const DEFAULT_NAME := "Khai Giới Giả"


static func default_look(gender := "nam") -> Dictionary:
	return {"gender": gender, "skin": 1, "hair_style": "ngan" if gender == "nam" else "dai", "hair_color": 0}


## Chuẩn hoá ngoại hình đọc từ save (giá trị lạ → mặc định).
static func sanitize(look) -> Dictionary:
	var d := default_look()
	if look is Dictionary:
		var g := str(look.get("gender", "nam"))
		d.gender = g if g in GENDERS else "nam"
		d.skin = clampi(int(look.get("skin", 1)), 0, SKIN_NAMES.size() - 1)
		var st := str(look.get("hair_style", "ngan"))
		d.hair_style = st if st in HAIR_STYLES else "ngan"
		d.hair_color = clampi(int(look.get("hair_color", 0)), 0, HAIR_COLORS.size() - 1)
	return d


## Tên hợp lệ: bỏ khoảng trắng thừa; "" nếu không hợp lệ.
static func clean_name(raw: String) -> String:
	var n := " ".join(raw.strip_edges().split(" ", false))
	if n.length() < NAME_MIN or n.length() > NAME_MAX:
		return ""
	return n


static func base_sprite(class_id: String, look: Dictionary) -> String:
	return "hero-%s-%s-%d" % [class_id, look.get("gender", "nam"), int(look.get("skin", 1))]


static func hair_sprite(class_id: String, look: Dictionary) -> String:
	return "hair-%s-%s" % [class_id, look.get("hair_style", "ngan")]


static func hair_color(look: Dictionary) -> Color:
	return HAIR_COLORS[clampi(int(look.get("hair_color", 0)), 0, HAIR_COLORS.size() - 1)][1]
