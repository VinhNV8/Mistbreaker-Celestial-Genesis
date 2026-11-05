extends Control
## UI-52 (docs/38): dải nhặt đồ bên trái màn hình — EXP / vàng / Đá / đồ rơi / hồi máu không còn nổi trên đầu
## nhân vật (đè tên, đè số sát thương) mà xếp thành cột ở đây: dòng mới nhất ở dưới, gộp số theo loại
## (GameWorld._pickup_note), viên ngọc màu theo loại + chữ cùng màu, hiện dần rồi mờ dần. HUD gọi update_from(world).

const UiTheme = preload("res://scripts/ui/ui_theme.gd")
const Bronze = preload("res://scripts/ui/bronze.gd")

const ROW_H := 24.0
const W := 280.0

var _notes: Array = []


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(W, ROW_H * 6.0)
	size = custom_minimum_size


func update_from(w) -> void:
	_notes = w.pickup_notes
	queue_redraw()


func _draw() -> void:
	var ci := get_canvas_item()
	var f := UiTheme.bold_font()
	var fs := UiTheme.fs(14)
	var n := _notes.size()
	for i in n:
		var note = _notes[i]
		var a := clampf(note.ttl * 1.6, 0.0, 1.0)
		var y := size.y - (n - i) * ROW_H
		var tw := f.get_string_size(note.text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		# dải nền tối mờ dần sang phải (cùng kiểu dòng nhật ký UI-20)
		var bw := minf(W, tw + 44.0)
		var dark := Color(0.03, 0.02, 0.06, 0.7 * a)
		draw_polygon(PackedVector2Array([Vector2(0, y + 2), Vector2(bw, y + 2), Vector2(bw, y + ROW_H - 2), Vector2(0, y + ROW_H - 2)]),
			PackedColorArray([dark, Color(dark, 0.0), Color(dark, 0.0), dark]))
		var col: Color = note.color
		Bronze.gem_at(ci, Vector2(14, y + ROW_H / 2.0), 4.0 if note.big else 3.2, Color(col, a))
		var base := Vector2(28, y + ROW_H / 2.0 + (f.get_ascent(fs) - f.get_descent(fs)) / 2.0)
		draw_string_outline(f, base, note.text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, 4, Color(0, 0, 0, 0.85 * a))
		draw_string(f, base, note.text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(col.lightened(0.15), a))
