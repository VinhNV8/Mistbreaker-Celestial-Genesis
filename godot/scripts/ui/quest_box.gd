extends StyleBox
## UI-16b (Spec_Notes đợt 7: "Nhiệm vụ: khung hình hơi xấu, cần design lại"): nền khung nhiệm vụ cùng phong cách
## khung nhân vật (UI-08) — tím đêm mờ, viền vàng mảnh 2 lớp, ngọc tím 4 góc + ngọc giữa cạnh trên.
## Dùng: PanelContainer.add_theme_stylebox_override("panel", QuestBox.new()).

const GOLD := Color("#d9a845")
const GOLD_DARK := Color("#6e4a17")
const GOLD_LIGHT := Color("#ffe39a")
const GEM := Color("#9a4dff")
const GEM_LIGHT := Color("#e2c4ff")


func _init() -> void:
	content_margin_left = 14
	content_margin_right = 12
	content_margin_top = 10
	content_margin_bottom = 10


func _draw(ci: RID, rect: Rect2) -> void:
	var rs := RenderingServer
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.05, 0.025, 0.1, 0.74)
	bg.set_corner_radius_all(10)
	bg.set_border_width_all(1)
	bg.border_color = Color(GOLD, 0.8)
	bg.shadow_color = Color(0, 0, 0, 0.35)
	bg.shadow_size = 4
	bg.draw(ci, rect)
	# vệt sáng tím nửa trên
	var top := StyleBoxFlat.new()
	top.bg_color = Color(GEM, 0.08)
	top.corner_radius_top_left = 9
	top.corner_radius_top_right = 9
	top.draw(ci, Rect2(rect.position + Vector2(1, 1), Vector2(rect.size.x - 2, rect.size.y * 0.45)))
	var inner := StyleBoxFlat.new()
	inner.draw_center = false
	inner.set_corner_radius_all(7)
	inner.set_border_width_all(1)
	inner.border_color = Color(GOLD, 0.22)
	inner.draw(ci, rect.grow(-4))
	for p in [rect.position + Vector2(4, 4), Vector2(rect.end.x - 4, rect.position.y + 4), rect.end - Vector2(4, 4), Vector2(rect.position.x + 4, rect.end.y - 4)]:
		_gem(ci, p, 3.0)
	_gem(ci, Vector2(rect.get_center().x, rect.position.y), 4.0)
	rs.canvas_item_add_line(ci, Vector2(rect.get_center().x - 34, rect.position.y), Vector2(rect.get_center().x - 8, rect.position.y), GOLD_LIGHT, 1.0)
	rs.canvas_item_add_line(ci, Vector2(rect.get_center().x + 8, rect.position.y), Vector2(rect.get_center().x + 34, rect.position.y), GOLD_LIGHT, 1.0)


static func _gem(ci: RID, p: Vector2, s: float) -> void:
	var rs := RenderingServer
	rs.canvas_item_add_polygon(ci, PackedVector2Array([p + Vector2(0, -s - 1.5), p + Vector2(s + 1.5, 0), p + Vector2(0, s + 1.5), p + Vector2(-s - 1.5, 0)]), PackedColorArray([GOLD]))
	rs.canvas_item_add_polygon(ci, PackedVector2Array([p + Vector2(0, -s), p + Vector2(s, 0), p + Vector2(0, s), p + Vector2(-s, 0)]), PackedColorArray([GEM]))
	rs.canvas_item_add_polygon(ci, PackedVector2Array([p + Vector2(0, -s), p + Vector2(s * 0.5, -s * 0.2), p, p + Vector2(-s * 0.5, -s * 0.2)]), PackedColorArray([GEM_LIGHT]))


## Đường kẻ dưới tiêu đề: vạch vàng mờ dần 2 đầu + ngọc giữa.
class Divider:
	extends Control

	func _init() -> void:
		custom_minimum_size = Vector2(0, 8)
		mouse_filter = MOUSE_FILTER_IGNORE

	func _draw() -> void:
		var y := size.y / 2.0
		var cx := size.x / 2.0
		var steps := 10
		for i in steps:
			var a := 1.0 - float(i) / steps
			var x0 := cx * float(i) / steps
			draw_line(Vector2(cx - x0, y), Vector2(cx - x0 - cx / steps, y), Color(GOLD, 0.7 * a), 1.0)
			draw_line(Vector2(cx + x0, y), Vector2(cx + x0 + cx / steps, y), Color(GOLD, 0.7 * a), 1.0)
		draw_colored_polygon(PackedVector2Array([Vector2(cx, y - 4), Vector2(cx + 4, y), Vector2(cx, y + 4), Vector2(cx - 4, y)]), GOLD)
		draw_colored_polygon(PackedVector2Array([Vector2(cx, y - 2.5), Vector2(cx + 2.5, y), Vector2(cx, y + 2.5), Vector2(cx - 2.5, y)]), GEM)
