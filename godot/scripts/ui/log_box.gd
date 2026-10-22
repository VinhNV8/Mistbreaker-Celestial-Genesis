extends StyleBox
## UI-20: nền một dòng nhật ký thông báo (góc trái dưới) — thay hộp xám bo góc cũ.
## Dải nền tối mờ dần sang phải (không viền khung), vạch màu theo loại tin ở mép trái, huy hiệu kim cương
## màu theo loại (vàng = tốt, đỏ = xấu, xanh xám = thường) ở đầu dòng. Chữ đặt sau huy hiệu (content_margin_left).

const TONES := {"good": Color("#f2c85b"), "bad": Color("#ff5a6e"), "info": Color("#8fb4d8")}

var tone := "info"


func _init(t := "info") -> void:
	tone = t
	content_margin_left = 26
	content_margin_right = 56
	content_margin_top = 4
	content_margin_bottom = 5


static func color_of(t: String) -> Color:
	return TONES.get(t, TONES.info)


func _draw(ci: RID, rect: Rect2) -> void:
	var rs := RenderingServer
	var col := color_of(tone)
	var p := rect.position
	var e := rect.end
	# dải nền: đậm bên trái, mờ dần về phải
	var dark := Color(0.03, 0.02, 0.06, 0.78)
	var clear := Color(0.03, 0.02, 0.06, 0.0)
	var mid := p.x + rect.size.x * 0.62
	rs.canvas_item_add_polygon(ci, PackedVector2Array([p, Vector2(mid, p.y), Vector2(mid, e.y), Vector2(p.x, e.y)]),
		PackedColorArray([dark, Color(dark, 0.6), Color(dark, 0.6), dark]))
	rs.canvas_item_add_polygon(ci, PackedVector2Array([Vector2(mid, p.y), Vector2(e.x, p.y), Vector2(e.x, e.y), Vector2(mid, e.y)]),
		PackedColorArray([Color(dark, 0.6), clear, clear, Color(dark, 0.6)]))
	# chỉ vàng mảnh mép trên, mờ dần
	rs.canvas_item_add_polygon(ci, PackedVector2Array([p, Vector2(mid, p.y), Vector2(mid, p.y + 1), Vector2(p.x, p.y + 1)]),
		PackedColorArray([Color(col, 0.45), Color(col, 0.0), Color(col, 0.0), Color(col, 0.45)]))
	# vạch màu mép trái
	rs.canvas_item_add_rect(ci, Rect2(p, Vector2(2.5, rect.size.y)), col)
	# huy hiệu kim cương đầu dòng
	var c := Vector2(p.x + 14.0, p.y + 12.0)
	var s := 5.0
	rs.canvas_item_add_polygon(ci, PackedVector2Array([c + Vector2(0, -s - 1.5), c + Vector2(s + 1.5, 0), c + Vector2(0, s + 1.5), c + Vector2(-s - 1.5, 0)]),
		PackedColorArray([Color(0, 0, 0, 0.7)]))
	rs.canvas_item_add_polygon(ci, PackedVector2Array([c + Vector2(0, -s), c + Vector2(s, 0), c + Vector2(0, s), c + Vector2(-s, 0)]), PackedColorArray([col]))
	rs.canvas_item_add_polygon(ci, PackedVector2Array([c + Vector2(0, -s), c + Vector2(s * 0.5, -s * 0.2), c, c + Vector2(-s * 0.5, -s * 0.2)]),
		PackedColorArray([col.lightened(0.6)]))
