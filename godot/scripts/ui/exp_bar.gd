extends Control
## UI-41 (docs/35 §11): thanh kinh nghiệm tím chạy dài ở đáy màn hình — rãnh đồng, phần đầy tím có vệt sáng + đốm
## sáng đầu thanh, chữ "EXP 75% · còn 12.500 tới cấp 56", 2 đầu rồng đồng + 2 huy hiệu ngọc ở 2 đầu.
## HUD gọi set_exp(frac, level, need) mỗi khung hình — chỉ vẽ lại khi số đổi (PF-01).

const UiTheme = preload("res://scripts/ui/ui_theme.gd")
const Bronze = preload("res://scripts/ui/bronze.gd")
const Ornate = preload("res://scripts/ui/ornate.gd")
const DrawLayer = preload("res://scripts/ui/draw_layer.gd")

const H := 22.0
## Đầu rồng 2 bên nhô ra ngoài khung control (px): gốc ở mép thanh − 4, dài 64 × 0,75.
const DRAGON_OUT := 26.0
const PURPLE := Color("#9b4dff")
const PURPLE_LIGHT := Color("#d8b4ff")

var frac := 0.0
var level := 1
var need := 0
var maxed := false
## PF-01: rãnh / rồng / ngọc ở lớp tĩnh sau, vạch chia + viền ở lớp tĩnh trước; phần đầy + chữ chỉ vẽ lại khi số đổi.
var _back: Control
var _front: Control
var _sig := ""


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(400, H + 8)
	_back = DrawLayer.new(_paint_back, true, true)
	_front = DrawLayer.new(_paint_front, false, true)
	add_child(_back)
	add_child(_front)
	resized.connect(func():
		_back.rebake()
		_front.rebake()
		queue_redraw())


func set_exp(f: float, lv: int, need_left: int, at_max := false) -> void:
	frac = clampf(f, 0.0, 1.0)
	level = lv
	need = need_left
	maxed = at_max
	var sig := "%d|%d|%d|%s" % [roundi(frac * 1000.0), lv, need_left, at_max]
	if sig != _sig:
		_sig = sig
		queue_redraw()


func _bar() -> Rect2:
	return Rect2(Vector2(18, 4), Vector2(size.x - 36, H))


func _paint_back(cv: CanvasItem) -> void:
	var ci := cv.get_canvas_item()
	var r := _bar()
	Bronze.dragon(ci, Vector2(r.position.x + 4, r.end.y + 2), 0.75, true, Bronze.GEM_PURPLE)
	Bronze.dragon(ci, Vector2(r.end.x - 4, r.end.y + 2), 0.75, false, Bronze.GEM_PURPLE)
	# rãnh đồng
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("#160f20")
	sb.set_corner_radius_all(int(H * 0.5))
	sb.set_border_width_all(3)
	sb.border_color = Bronze.BR
	sb.shadow_color = Color(0, 0, 0, 0.45)
	sb.shadow_size = 4
	sb.anti_aliasing = true
	cv.draw_style_box(sb, r)
	for x in [r.position.x - 2.0, r.end.x + 2.0]:
		Bronze.gem_at(ci, Vector2(x, r.get_center().y), 6.0, Bronze.GEM_PURPLE)


## Vạch chia 10% + viền sáng (nằm trên phần đầy).
func _paint_front(cv: CanvasItem) -> void:
	var r := _bar()
	var inner := r.grow(-3.0)
	for i in range(1, 10):
		var x := inner.position.x + inner.size.x * i / 10.0
		cv.draw_line(Vector2(x, inner.position.y + 2), Vector2(x, inner.end.y - 2), Color(0, 0, 0, 0.35), 1.0)
	cv.draw_style_box(_ring(), r)


func _draw() -> void:
	var r := _bar()
	var inner := r.grow(-3.0)
	var fr := Rect2(inner.position, Vector2(maxf(inner.size.y, inner.size.x * frac), inner.size.y))
	if frac > 0.0:
		var fsb := StyleBoxFlat.new()
		fsb.bg_color = PURPLE
		fsb.set_corner_radius_all(int(inner.size.y * 0.5))
		fsb.anti_aliasing = true
		draw_style_box(fsb, fr)
		draw_line(fr.position + Vector2(6, 3), Vector2(fr.end.x - 6, fr.position.y + 3), Color(PURPLE_LIGHT, 0.7), 2.0, true)
		draw_line(Vector2(fr.position.x + 6, fr.end.y - 2), Vector2(fr.end.x - 6, fr.end.y - 2), Color(0.25, 0.05, 0.45, 0.6), 2.0, true)
		# đốm sáng đầu thanh
		var tip := Vector2(fr.end.x - 3.0, fr.get_center().y)
		draw_circle(tip, 9.0, Color(PURPLE_LIGHT, 0.25))
		draw_line(tip + Vector2(0, -inner.size.y * 0.5 - 2), tip + Vector2(0, inner.size.y * 0.5 + 2), Color(1, 1, 1, 0.85), 2.0, true)
	var f := UiTheme.bold_font()
	var txt := "EXP %d%% · còn %s tới cấp %d" % [floori(frac * 100.0), Ornate.group(need), level + 1] if not maxed else "Cấp tối đa"
	var y := r.get_center().y + (f.get_ascent(12) - f.get_descent(12)) * 0.5
	draw_string_outline(f, Vector2(r.position.x, y), txt, HORIZONTAL_ALIGNMENT_CENTER, r.size.x, 12, 4, Color(0.08, 0.02, 0.15, 0.95))
	draw_string(f, Vector2(r.position.x, y), txt, HORIZONTAL_ALIGNMENT_CENTER, r.size.x, 12, Color.WHITE)


func _ring() -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.draw_center = false
	sb.set_corner_radius_all(int(H * 0.5))
	sb.set_border_width_all(1)
	sb.border_color = Color(Bronze.BR_LIGHT, 0.7)
	sb.anti_aliasing = true
	return sb
