extends Control
## SN10-01 (Spec_Notes đợt 10): kết quả cường hoá hiện giữa màn hình (thay hiệu ứng nhỏ trong Túi đồ / Lò Rèn).
## EN-1 E2/E3 (docs/43 §6): icon món đồ to ở giữa mang sẵn hiệu ứng cường hoá của cấp mới (EnhanceFx),
##   số chạy "+N−1 → +N"; mốc bậc (+4 / +7 / +10 / +13) và +15 = "ĐỘT PHÁ" / "TUYỆT PHẨM": cột sáng, loé màn hình, giữ lâu hơn.
##   Thất bại: icon xám rung, vết nứt, "Mất nguyên liệu · món đồ vẫn +N" — ngắn, không gây khó chịu.
## top_level: luôn canh giữa khung nhìn, đè lên mọi bảng; tự huỷ sau LIFE giây; không chặn chuột.

const UiTheme = preload("res://scripts/ui/ui_theme.gd")
const Items = preload("res://scripts/core/items.gd")
const EnhanceFx = preload("res://scripts/ui/enhance_fx.gd")

const LIFE := 1.8
const LIFE_MILESTONE := 2.6
const BOX := Vector2(460, 300)
const ICON := 96.0
const MILESTONES := [4, 7, 10, 13, 15]

var success := true
var plus := 0
var item_name := ""
var icon: Texture2D
var t := 0.0
var _icon_node: TextureRect


## Tạo và gắn hiệu ứng vào parent (bảng đang mở). Trả về node để test kiểm.
static func pop(parent: Node, ok: bool, new_plus: int, label: String = "", tex: Texture2D = null) -> Control:
	var fx = load("res://scripts/ui/enhance_toast.gd").new()
	fx.name = "EnhanceToast"
	fx.success = ok
	fx.plus = new_plus
	fx.item_name = label
	fx.icon = tex
	fx.top_level = true
	fx.z_index = 100
	fx.mouse_filter = MOUSE_FILTER_IGNORE
	fx.size = BOX
	parent.add_child(fx)
	fx._build_icon()
	fx._center()
	return fx


func milestone() -> bool:
	return success and plus in MILESTONES


func life() -> float:
	return LIFE_MILESTONE if milestone() else LIFE


func _ready() -> void:
	_build_icon()


func _build_icon() -> void:
	if icon == null or _icon_node != null:
		return
	_icon_node = TextureRect.new()
	_icon_node.texture = icon
	_icon_node.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_icon_node.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_icon_node.size = Vector2(ICON, ICON)
	_icon_node.pivot_offset = Vector2(ICON, ICON) / 2.0
	_icon_node.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(_icon_node)
	if success:
		var fx = EnhanceFx.attach(_icon_node, {"plus": plus, "id": 0}, icon, 0.0, 10.0)
		fx.badge = false
	else:
		_icon_node.modulate = Color(0.62, 0.62, 0.68)
	_place_icon()


func _center() -> void:
	if not is_inside_tree():
		return
	global_position = get_viewport_rect().size / 2.0 - size / 2.0 - Vector2(0, 40)


func _alpha() -> float:
	# hiện nhanh 0,12 giây, giữ, mờ dần 0,5 giây cuối
	return clampf(t / 0.12, 0.0, 1.0) * clampf((life() - t) / 0.5, 0.0, 1.0)


func _place_icon() -> void:
	if _icon_node == null:
		return
	var pop_k := clampf(t / 0.25, 0.0, 1.0)
	var sc := (1.35 - 0.35 * pop_k) if success else 1.0
	var shake := Vector2.ZERO
	if not success and t < 0.5:
		shake = Vector2(sin(t * 70.0) * 6.0 * (1.0 - t / 0.5), 0)
	_icon_node.scale = Vector2(sc, sc)
	_icon_node.position = Vector2(size.x / 2.0 - ICON / 2.0, 6.0) + shake
	_icon_node.modulate.a = _alpha()


func _process(delta: float) -> void:
	t += delta
	_center()
	_place_icon()
	queue_redraw()
	if t > life():
		queue_free()


func _draw() -> void:
	var a := _alpha()
	var ic := Vector2(size.x / 2.0, 6.0 + ICON / 2.0)
	var k := clampf(t / 0.6, 0.0, 1.0)
	var f := UiTheme.bold_font()
	var col: Color = (Items.enhance_color(plus) if Items.enhance_tier(plus) > 0 else UiTheme.GOLD) if success else Color(0.72, 0.74, 0.8)
	if success:
		if milestone():
			# loé màn hình + cột sáng dọc qua icon
			var vp := get_viewport_rect().size
			draw_rect(Rect2(-global_position, vp), Color(col, 0.22 * clampf(1.0 - t / 0.35, 0.0, 1.0)))
			var pw := 70.0 + 30.0 * sin(t * 6.0)
			for i in 4:
				var w := pw * (1.0 - i * 0.22)
				draw_rect(Rect2(Vector2(ic.x - w / 2.0, -global_position.y), Vector2(w, vp.y)), Color(col, 0.06 * a))
		draw_circle(ic, 30.0 + 120.0 * k, Color(col, 0.28 * (1.0 - k) * a))
		for i in 18:
			var ang := TAU * i / 18.0 + t * 0.6
			draw_line(ic + Vector2.from_angle(ang) * (40.0 + 60.0 * k), ic + Vector2.from_angle(ang) * (70.0 + 130.0 * k),
				Color(col, 0.9 * (1.0 - k) * a), 3.0, true)
		draw_circle(ic, ICON * 0.55, Color(col, 0.16 * a))
	else:
		# vết nứt gãy khúc rơi xuống quanh icon
		for i in 7:
			var x := -90.0 + i * 30.0
			var y := -10.0 + 80.0 * k
			var p0 := ic + Vector2(x, y)
			draw_polyline(PackedVector2Array([p0, p0 + Vector2(5, 9), p0 + Vector2(-2, 16), p0 + Vector2(4, 25)]),
				Color(0.55, 0.56, 0.62, (1.0 - k) * a), 2.5, true)
	# khung chữ
	var rise := -10.0 * clampf(t / life(), 0.0, 1.0)
	var box := Rect2(Vector2(20, 118 + rise), Vector2(size.x - 40, 112))
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.08, 0.06, 0.04, 0.88 * a)
	sb.set_corner_radius_all(10)
	sb.set_border_width_all(2)
	sb.border_color = Color(col, a)
	sb.shadow_color = Color(0, 0, 0, 0.5 * a)
	sb.shadow_size = 8
	draw_style_box(sb, box)
	var title := "CƯỜNG HOÁ THÀNH CÔNG"
	if not success:
		title = "CƯỜNG HOÁ THẤT BẠI"
	elif plus >= 15:
		title = "TUYỆT PHẨM +%d" % plus
	elif milestone():
		title = "ĐỘT PHÁ +%d" % plus
	_text(f, Vector2(box.position.x, box.position.y + 36), box.size.x, title, 26, col, a)
	if success:
		# số chạy: "+N−1 → +N", số mới phóng to rồi về cỡ thường
		var roll := clampf((t - 0.15) / 0.35, 0.0, 1.0)
		var big := int(22.0 + 10.0 * (1.0 - roll) * float(roll > 0.0))
		var old_s := "+%d  →  " % (plus - 1)
		var new_s := "+%d" % plus
		var w_old := f.get_string_size(old_s, HORIZONTAL_ALIGNMENT_LEFT, -1, 22).x
		var w_new := f.get_string_size(new_s, HORIZONTAL_ALIGNMENT_LEFT, -1, big).x
		var x0 := box.position.x + (box.size.x - w_old - w_new) / 2.0
		var y0 := box.position.y + 70
		_text(f, Vector2(x0, y0), -1, old_s, 22, Color(0.75, 0.72, 0.66), a, HORIZONTAL_ALIGNMENT_LEFT)
		_text(f, Vector2(x0 + w_old, y0), -1, new_s, big, col.lightened(0.15), a * (0.3 + 0.7 * roll), HORIZONTAL_ALIGNMENT_LEFT)
		# item_name là Items.display_name (đã có "+N")
		if item_name != "":
			_text(f, Vector2(box.position.x, box.position.y + 98), box.size.x, item_name, 16, Color(1, 1, 1), a)
	else:
		_text(f, Vector2(box.position.x, box.position.y + 80), box.size.x, "Mất nguyên liệu · món đồ vẫn +%d" % plus, 19, Color(0.85, 0.86, 0.9), a)


func _text(f: Font, pos: Vector2, w: float, s: String, fs: int, col: Color, a: float, al := HORIZONTAL_ALIGNMENT_CENTER) -> void:
	draw_string_outline(f, pos, s, al, w, fs, 6, Color(0, 0, 0, a))
	draw_string(f, pos, s, al, w, fs, Color(col, a))
