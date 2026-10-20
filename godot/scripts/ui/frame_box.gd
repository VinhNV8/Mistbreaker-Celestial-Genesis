extends StyleBox
## DH-11: nền bảng kiểu khung trang trí (cùng phong cách thanh kỹ năng): nền gỗ tối, viền vàng 2 lớp,
## hoa văn 4 góc, hạt kim cương giữa cạnh trên/dưới. Dùng làm StyleBox nên mọi PanelContainer dùng theme
## "SolidPanel" (bảng phủ: túi đồ, cửa hàng, chỉ số…) hay "FramePanel" (HUD) đổi theo, không phải sửa từng bảng.

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
	if _base == null:
		_build()
	_base.draw(ci, rect)
	var inset := 5.0 if size_kind == "large" else 4.0
	_inner.draw(ci, rect.grow(-inset))
	# vệt sáng mảnh dưới mép trên — gợi khối gỗ
	var rs := RenderingServer
	rs.canvas_item_add_line(ci, rect.position + Vector2(corner + 6, inset + 2), Vector2(rect.end.x - corner - 6, rect.position.y + inset + 2),
		Color(1, 0.9, 0.7, 0.06), 2.0)
	var s := 1.0 if size_kind == "large" else 0.65
	var p := rect.position
	var e := rect.end
	for c in [[p + Vector2(9, 9) * s, Vector2(1, 1)], [Vector2(e.x, p.y) + Vector2(-9, 9) * s, Vector2(-1, 1)],
			[e + Vector2(-9, -9) * s, Vector2(-1, -1)], [Vector2(p.x, e.y) + Vector2(9, -9) * s, Vector2(1, -1)]]:
		var at: Vector2 = c[0]
		var d: Vector2 = c[1]
		# góc: 2 thanh vàng chữ L + hạt kim cương
		rs.canvas_item_add_line(ci, at, at + Vector2(d.x * 16.0 * s, 0), GOLD, 2.0)
		rs.canvas_item_add_line(ci, at, at + Vector2(0, d.y * 16.0 * s), GOLD, 2.0)
		rs.canvas_item_add_line(ci, at + d * 4.0 * s, at + d * 4.0 * s + Vector2(d.x * 8.0 * s, 0), Color(GOLD_LIGHT, 0.7), 1.0)
		rs.canvas_item_add_line(ci, at + d * 4.0 * s, at + d * 4.0 * s + Vector2(0, d.y * 8.0 * s), Color(GOLD_LIGHT, 0.7), 1.0)
		_diamond(ci, at, 4.0 * s, GOLD_LIGHT)
	if size_kind == "large" and rect.size.x > 160.0:
		var cx := rect.get_center().x
		_diamond(ci, Vector2(cx, p.y + 1.5), 5.0, GOLD)
		_diamond(ci, Vector2(cx, p.y + 1.5), 2.5, GOLD_LIGHT)
		_diamond(ci, Vector2(cx, e.y - 1.5), 4.0, GOLD)
		rs.canvas_item_add_line(ci, Vector2(cx - 40, p.y + 1.5), Vector2(cx - 9, p.y + 1.5), GOLD_LIGHT, 1.0)
		rs.canvas_item_add_line(ci, Vector2(cx + 9, p.y + 1.5), Vector2(cx + 40, p.y + 1.5), GOLD_LIGHT, 1.0)


static func _diamond(ci: RID, p: Vector2, s: float, col: Color) -> void:
	RenderingServer.canvas_item_add_polygon(ci, PackedVector2Array([p + Vector2(0, -s), p + Vector2(s, 0), p + Vector2(0, s), p + Vector2(-s, 0)]),
		PackedColorArray([col]))
