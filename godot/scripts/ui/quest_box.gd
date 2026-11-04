extends StyleBox
## UI-16b (Spec_Notes đợt 7: "Nhiệm vụ: khung hình hơi xấu, cần design lại"); UI-41 (03/11): cuộn giấy da. Trước đây cùng phong cách
## khung nhân vật (UI-08) — tím đêm mờ, viền vàng mảnh 2 lớp, ngọc tím 4 góc + ngọc giữa cạnh trên.
## Dùng: PanelContainer.add_theme_stylebox_override("panel", QuestBox.new()).

const Bronze = preload("res://scripts/ui/bronze.gd")
const GOLD := Color("#d9a845")
const GOLD_DARK := Color("#6e4a17")
const GOLD_LIGHT := Color("#ffe39a")
const GEM := Color("#9a4dff")
const GEM_LIGHT := Color("#e2c4ff")


func _init() -> void:
	# UI-41: lề chừa 2 trục cuộn trên / dưới và dấu sáp góc phải
	content_margin_left = 16
	content_margin_right = 30
	content_margin_top = 22
	content_margin_bottom = 20


## UI-41 (docs/35 §11): cuộn giấy da + dấu sáp (thay nền tím mờ UI-16b).
func _draw(ci: RID, rect: Rect2) -> void:
	Bronze.parchment(ci, rect, true)


## UI-41: thanh tiến độ nhiệm vụ "(a/b)" (HUD đặt frac / text; ẩn khi mục tiêu không có số đếm).
class Progress:
	extends Control
	var frac := 0.0
	var text := ""

	func _init() -> void:
		custom_minimum_size = Vector2(0, 13)
		mouse_filter = MOUSE_FILTER_IGNORE

	func _draw() -> void:
		Bronze.progress(get_canvas_item(), Rect2(Vector2(2, 0), Vector2(size.x - 4, size.y)), frac, Color("#e0a830"), text, 9)


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
			draw_line(Vector2(cx - x0, y), Vector2(cx - x0 - cx / steps, y), Color(Bronze.INK_RED, 0.7 * a), 1.0)
			draw_line(Vector2(cx + x0, y), Vector2(cx + x0 + cx / steps, y), Color(Bronze.INK_RED, 0.7 * a), 1.0)
		draw_colored_polygon(PackedVector2Array([Vector2(cx, y - 4), Vector2(cx + 4, y), Vector2(cx, y + 4), Vector2(cx - 4, y)]), Bronze.INK_RED)
		draw_colored_polygon(PackedVector2Array([Vector2(cx, y - 2.5), Vector2(cx + 2.5, y), Vector2(cx, y + 2.5), Vector2(cx - 2.5, y)]), Color("#d9a845"))
