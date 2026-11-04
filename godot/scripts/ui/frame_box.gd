extends StyleBox
## DH-11: nền bảng kiểu khung trang trí (cùng phong cách thanh kỹ năng): nền gỗ tối, viền vàng 2 lớp,
## hoa văn 4 góc, hạt kim cương giữa cạnh trên/dưới. Dùng làm StyleBox nên mọi PanelContainer dùng theme
## "SolidPanel" (bảng phủ: túi đồ, cửa hàng, chỉ số…) hay "FramePanel" (HUD) đổi theo, không phải sửa từng bảng.

const Bronze = preload("res://scripts/ui/bronze.gd")
const GOLD_DARK := Color("#7a5a2a")
const GOLD := Color("#c9a45c")
const GOLD_LIGHT := Color("#f3d27a")

var bg := Color("#22180f")
var corner := 14
## "large" (bảng phủ) | "small" (khung HUD: hoa văn nhỏ, không hạt giữa cạnh)
var size_kind := "large"

var _base: StyleBoxFlat
var _inner: StyleBoxFlat


## Dùng: FrameBox.new().setup(màu nền, lề trong, "large" | "small").
func setup(bg_color: Color, margin := 20, kind := "large") -> StyleBox:
	bg = bg_color
	size_kind = kind
	corner = 14 if kind == "large" else 10
	set_content_margin_all(margin)
	_build()
	return self


func _build() -> void:
	_base = StyleBoxFlat.new()
	_base.bg_color = bg
	_base.set_corner_radius_all(corner)
	_base.set_border_width_all(3 if size_kind == "large" else 2)
	_base.border_color = GOLD_DARK
	_base.shadow_color = Color(0, 0, 0, 0.4)
	_base.shadow_size = 8 if size_kind == "large" else 3
	_inner = StyleBoxFlat.new()
	_inner.draw_center = false
	_inner.set_corner_radius_all(maxi(2, corner - 4))
	_inner.set_border_width_all(1)
	_inner.border_color = Color(GOLD, 0.5)


func _draw(ci: RID, rect: Rect2) -> void:
	# UI-41 (docs/35 §11): khung đồng chạm khắc, ngọc 4 góc, nền xanh rêu (giữ độ trong của màu nền truyền vào).
	var large := size_kind == "large"
	Bronze.frame(ci, rect, 1.0 if large else 0.7, Color(Bronze.MOSS, bg.a), Bronze.GEM_BLUE, large)


static func _diamond(ci: RID, p: Vector2, s: float, col: Color) -> void:
	RenderingServer.canvas_item_add_polygon(ci, PackedVector2Array([p + Vector2(0, -s), p + Vector2(s, 0), p + Vector2(0, s), p + Vector2(-s, 0)]),
		PackedColorArray([col]))
