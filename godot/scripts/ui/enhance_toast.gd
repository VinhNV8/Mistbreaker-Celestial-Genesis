extends Control
## SN10-01 (Spec_Notes đợt 10): kết quả cường hoá hiện giữa màn hình (thay hiệu ứng nhỏ trong Túi đồ / Lò Rèn).
## Thành công: vòng sáng màu theo cấp + tia toả ra, tiêu đề "CƯỜNG HOÁ THÀNH CÔNG", tên món kèm "+N".
## Thất bại: khung xám, vết nứt rơi xuống, "CƯỜNG HOÁ THẤT BẠI" + "Mất nguyên liệu · món đồ vẫn +N".
## top_level: luôn canh giữa khung nhìn, đè lên mọi bảng; tự huỷ sau LIFE giây; không chặn chuột.

const UiTheme = preload("res://scripts/ui/ui_theme.gd")
const Items = preload("res://scripts/core/items.gd")

const LIFE := 1.8
const BOX := Vector2(460, 230)

var success := true
var plus := 0
var item_name := ""
var t := 0.0


## Tạo và gắn hiệu ứng vào parent (bảng đang mở). Trả về node để test kiểm.
static func pop(parent: Node, ok: bool, new_plus: int, label: String = "") -> Control:
	var fx = load("res://scripts/ui/enhance_toast.gd").new()
	fx.name = "EnhanceToast"
	fx.success = ok
	fx.plus = new_plus
	fx.item_name = label
	fx.top_level = true
	fx.z_index = 100
	fx.mouse_filter = MOUSE_FILTER_IGNORE
	fx.size = BOX
	parent.add_child(fx)
	fx._center()
	return fx


func _center() -> void:
	if not is_inside_tree():
		return
	global_position = get_viewport_rect().size / 2.0 - size / 2.0 - Vector2(0, 40)


func _process(delta: float) -> void:
	t += delta
	_center()
	queue_redraw()
	if t > LIFE:
		queue_free()


func _alpha() -> float:
	# hiện nhanh 0,12 giây, giữ, mờ dần 0,5 giây cuối
	return clampf(t / 0.12, 0.0, 1.0) * clampf((LIFE - t) / 0.5, 0.0, 1.0)


func _draw() -> void:
	var a := _alpha()
	var c := size / 2.0
	var k := clampf(t / 0.6, 0.0, 1.0)
	var rise := -14.0 * clampf(t / LIFE, 0.0, 1.0)
	var f := UiTheme.bold_font()
	var col: Color = (Items.enhance_color(plus) if Items.enhance_tier(plus) > 0 else UiTheme.GOLD) if success else Color(0.72, 0.74, 0.8)
	# hiệu ứng nền
	if success:
		draw_circle(c, 30.0 + 120.0 * k, Color(col, 0.28 * (1.0 - k) * a))
		for i in 18:
			var ang := TAU * i / 18.0 + t * 0.6
			draw_line(c + Vector2.from_angle(ang) * (40.0 + 60.0 * k), c + Vector2.from_angle(ang) * (70.0 + 130.0 * k),
				Color(col, 0.9 * (1.0 - k) * a), 3.0, true)
	else:
		for i in 9:
			var x := -110.0 + i * 27.0
			var y := -30.0 + 90.0 * k
			draw_line(c + Vector2(x, y), c + Vector2(x + 6, y + 18), Color(0.55, 0.56, 0.62, (1.0 - k) * a), 3.0)
	# khung chữ
	var box := Rect2(Vector2(20, 64 + rise), Vector2(size.x - 40, 108))
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.08, 0.06, 0.04, 0.88 * a)
	sb.set_corner_radius_all(10)
	sb.set_border_width_all(2)
	sb.border_color = Color(col, a)
	sb.shadow_color = Color(0, 0, 0, 0.5 * a)
	sb.shadow_size = 8
	draw_style_box(sb, box)
	var title := "CƯỜNG HOÁ THÀNH CÔNG" if success else "CƯỜNG HOÁ THẤT BẠI"
	# item_name là Items.display_name (đã có "+N")
	var line2 := (item_name if item_name != "" else "+%d!" % plus) if success else "Mất nguyên liệu · món đồ vẫn +%d" % plus
	_text(f, Vector2(box.position.x, box.position.y + 44), box.size.x, title, 28, col, a)
	_text(f, Vector2(box.position.x, box.position.y + 84), box.size.x, line2, 20, Color(1, 1, 1) if success else Color(0.85, 0.86, 0.9), a)


func _text(f: Font, pos: Vector2, w: float, s: String, fs: int, col: Color, a: float) -> void:
	draw_string_outline(f, pos, s, HORIZONTAL_ALIGNMENT_CENTER, w, fs, 6, Color(0, 0, 0, a))
	draw_string(f, pos, s, HORIZONTAL_ALIGNMENT_CENTER, w, fs, Color(col, a))
