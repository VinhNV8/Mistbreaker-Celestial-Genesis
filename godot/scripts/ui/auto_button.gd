extends Control
## UI-12 (Spec_Notes đợt 6): nút tròn bật/tắt Tự đánh (thay dòng chữ "TỰ ĐÁNH (Z)" trên khung nhân vật).
## Bấm chuột hoặc phím Z. Đang bật: viền vàng sáng + vòng quay; tắt: xám mờ.

const UiTheme = preload("res://scripts/ui/ui_theme.gd")

signal pressed

const R := 22.0
const GOLD := Color("#d9a845")
const GOLD_LIGHT := Color("#ffe39a")

var on := false
var _t := 0.0


func _ready() -> void:
	custom_minimum_size = Vector2(R * 2.0 + 12.0, R * 2.0 + 12.0)
	size = custom_minimum_size
	mouse_filter = MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	tooltip_text = "Tự đánh (Z): bật / tắt"


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		pressed.emit()
		accept_event()


func _draw() -> void:
	var c := size / 2.0
	if on:
		draw_circle(c, R + 5.0, Color(GOLD_LIGHT, 0.18 + 0.08 * sin(_t * 4.0)))
	draw_circle(c, R + 3.0, Color("#160c2a"))
	draw_circle(c, R, Color("#2a1d3a") if on else Color("#1a1620"))
	draw_arc(c, R + 2.0, 0, TAU, 40, GOLD if on else Color(0.45, 0.42, 0.4), 2.5, true)
	if on:
		var a0 := _t * 3.0
		draw_arc(c, R - 3.0, a0, a0 + PI * 0.9, 16, Color(GOLD_LIGHT, 0.8), 2.0, true)
		draw_arc(c, R - 3.0, a0 + PI, a0 + PI * 1.9, 16, Color(GOLD_LIGHT, 0.8), 2.0, true)
	# 2 thanh kiếm bắt chéo
	var col := GOLD_LIGHT if on else Color(0.6, 0.58, 0.55)
	for side in [-1.0, 1.0]:
		var d := Vector2(side, -1.0).normalized()
		var base := c - d * 11.0
		var tip := c + d * 11.0
		draw_line(base, tip, col, 3.0, true)
		var n := d.orthogonal()
		draw_line(base + d * 4.0 + n * 4.0, base + d * 4.0 - n * 4.0, col, 2.0, true)
	var f := UiTheme.bold_font()
	var txt := "BẬT" if on else "TẮT"
	draw_string_outline(f, Vector2(c.x - 20, c.y + R + 2.0), txt, HORIZONTAL_ALIGNMENT_CENTER, 40, 10, 3, Color(0, 0, 0, 0.85))
	draw_string(f, Vector2(c.x - 20, c.y + R + 2.0), txt, HORIZONTAL_ALIGNMENT_CENTER, 40, 10, col)
	# phím Z góc trên phải
	var kr := Rect2(c + Vector2(R * 0.55, -R - 4.0), Vector2(16, 15))
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("#20160f")
	sb.set_corner_radius_all(7)
	sb.set_border_width_all(1)
	sb.border_color = GOLD
	draw_style_box(sb, kr)
	draw_string(f, kr.position + Vector2(0, 11.5), "Z", HORIZONTAL_ALIGNMENT_CENTER, kr.size.x, 10, GOLD_LIGHT)
