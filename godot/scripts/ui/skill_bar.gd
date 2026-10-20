extends Control
## UI-03: thanh kỹ năng kiểu khung trang trí — ô tròn viền vàng, phím ở góc, tên dưới icon,
## hồi chiêu quét tròn kèm số giây, lóe sáng khi hồi xong. Tự vẽ bằng _draw (không cần ảnh khung).
## HUD gọi set_slot(i, {...}) mỗi khung hình; khoá dữ liệu:
##   key: String, name: String, icon: Texture2D, cd: 0..1 (phần còn lại), cd_text: String,
##   sub: String (dòng nhỏ dưới tên), ring: Color (màu viền, mặc định vàng), dim: bool (thiếu MP), locked: bool

const UiTheme = preload("res://scripts/ui/ui_theme.gd")

const R := 26.0                 # bán kính ô tròn
const PITCH := 82.0             # khoảng cách tâm 2 ô
const PAD := Vector2(18, 12)    # lề trong khung
const TITLE := "Kỹ năng"
const GOLD_DARK := Color("#7a5a2a")
const GOLD := Color("#c9a45c")
const GOLD_LIGHT := Color("#f3d27a")
const WOOD := Color("#2a1d14")
const WOOD_DARK := Color("#170f0a")
const DIM := Color("#4a9df8")

var _slots: Array = []
var _flash: Array = []


func _init() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	mouse_filter = MOUSE_FILTER_IGNORE


func set_count(n: int) -> void:
	_slots.resize(n)
	_flash.resize(n)
	for i in n:
		if _slots[i] == null:
			_slots[i] = {}
			_flash[i] = 0.0
	custom_minimum_size = Vector2(PAD.x * 2.0 + PITCH * n, PAD.y + R * 2.0 + 44.0 + 14.0)
	size = custom_minimum_size


func set_slot(i: int, d: Dictionary) -> void:
	var old_cd: float = float(_slots[i].get("cd", 0.0))
	if old_cd > 0.0 and float(d.get("cd", 0.0)) <= 0.0:
		_flash[i] = 0.45
	_slots[i] = d


func _process(delta: float) -> void:
	for i in _flash.size():
		_flash[i] = maxf(0.0, _flash[i] - delta)
	queue_redraw()


## Tâm ô thứ i (toạ độ cục bộ) — dùng cho test và chú thích.
func slot_center(i: int) -> Vector2:
	return Vector2(PAD.x + PITCH * (i + 0.5), 14.0 + PAD.y + R)


func _draw() -> void:
	var w := size.x
	var top := 14.0
	var body := Rect2(0, top, w, size.y - top)
	_draw_frame(body)
	_draw_title(Vector2(w / 2.0, top))
	for i in _slots.size():
		_draw_slot(i, slot_center(i), _slots[i])


func _draw_frame(r: Rect2) -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(WOOD, 0.94)
	sb.set_corner_radius_all(16)
	sb.set_border_width_all(3)
	sb.border_color = GOLD_DARK
	sb.shadow_color = Color(0, 0, 0, 0.45)
	sb.shadow_size = 6
	draw_style_box(sb, r)
	# viền vàng sáng bên trong + vạch tối dưới đáy tạo khối
	var inner := r.grow(-5)
	var sb2 := StyleBoxFlat.new()
	sb2.draw_center = false
	sb2.set_corner_radius_all(12)
	sb2.set_border_width_all(1)
	sb2.border_color = Color(GOLD, 0.55)
	draw_style_box(sb2, inner)
	draw_line(Vector2(r.position.x + 18, r.end.y - 3), Vector2(r.end.x - 18, r.end.y - 3), Color(WOOD_DARK, 0.9), 2.0)
	# hoa văn 4 góc: cung cuộn + hạt kim cương
	for c in [[r.position + Vector2(10, 10), 0.0], [Vector2(r.end.x - 10, r.position.y + 10), PI * 0.5],
			[r.end - Vector2(10, 10), PI], [Vector2(r.position.x + 10, r.end.y - 10), PI * 1.5]]:
		var p: Vector2 = c[0]
		var a: float = c[1]
		draw_arc(p + Vector2(8, 8).rotated(a), 8.0, a + PI, a + PI * 1.5, 8, GOLD, 2.0)
		_diamond(p, 4.0, GOLD_LIGHT)
	# hạt trang trí giữa 2 cạnh bên
	_diamond(Vector2(r.position.x + 4, r.get_center().y), 4.0, GOLD)
	_diamond(Vector2(r.end.x - 4, r.get_center().y), 4.0, GOLD)


func _draw_title(c: Vector2) -> void:
	var f := UiTheme.bold_font()
	var fs := 14
	var tw := f.get_string_size(TITLE, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	var hw := tw / 2.0 + 22.0
	var pts := PackedVector2Array([c + Vector2(-hw - 10, 6), c + Vector2(-hw, -12), c + Vector2(hw, -12),
		c + Vector2(hw + 10, 6), c + Vector2(hw, 12), c + Vector2(-hw, 12)])
	draw_colored_polygon(pts, Color("#3a2618"))
	var loop := pts.duplicate()
	loop.append(pts[0])
	draw_polyline(loop, GOLD, 2.0, true)
	_diamond(c + Vector2(-hw - 10, 6), 3.0, GOLD_LIGHT)
	_diamond(c + Vector2(hw + 10, 6), 3.0, GOLD_LIGHT)
	var pos := c + Vector2(-tw / 2.0, 5)
	draw_string_outline(f, pos, TITLE, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, 3, Color(0, 0, 0, 0.8))
	draw_string(f, pos, TITLE, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, GOLD_LIGHT)


func _draw_slot(i: int, c: Vector2, d: Dictionary) -> void:
	var ring: Color = d.get("ring", GOLD)
	var dim: bool = d.get("dim", false)
	var locked: bool = d.get("locked", false)
	var cd := clampf(float(d.get("cd", 0.0)), 0.0, 1.0)
	# hào quang sau ô khi sẵn sàng / lóe sáng khi vừa hồi xong
	if _flash[i] > 0.0:
		draw_circle(c, R + 10.0, Color(GOLD_LIGHT, _flash[i] * 0.9))
	elif cd <= 0.0 and not dim and not locked:
		draw_circle(c, R + 5.0, Color(ring, 0.16))
	# nền + icon cắt tròn
	draw_circle(c, R + 4.0, WOOD_DARK)
	draw_circle(c, R, Color("#1d2430"))
	var tex: Texture2D = d.get("icon")
	if tex != null:
		var mod := Color.WHITE
		if locked:
			mod = Color(0.35, 0.35, 0.35)
		elif dim:
			mod = Color(0.5, 0.62, 1.0)
		_circle_texture(c, R - 2.0, tex, mod)
	# hồi chiêu: quạt tối quét theo chiều kim đồng hồ từ đỉnh
	if cd > 0.0:
		var pts := PackedVector2Array([c])
		var steps := maxi(2, ceili(40.0 * cd))
		for s in steps + 1:
			var a := -PI / 2.0 + TAU * (1.0 - cd) + TAU * cd * float(s) / steps
			pts.append(c + Vector2.from_angle(a) * R)
		draw_colored_polygon(pts, Color(0, 0, 0, 0.62))
	# bóng đổ trong (đáy phải tối) cho ô có chiều sâu
	draw_arc(c, R - 2.0, PI * -0.15, PI * 0.85, 24, Color(0, 0, 0, 0.35), 4.0, true)
	# viền: vòng tối ngoài, vòng màu, điểm sáng góc trên trái
	var rc := DIM if dim else ring
	draw_arc(c, R + 2.5, 0.0, TAU, 48, GOLD_DARK if not dim else DIM.darkened(0.5), 4.0, true)
	draw_arc(c, R + 1.0, 0.0, TAU, 48, rc, 2.0, true)
	draw_arc(c, R + 1.5, PI * 1.05, PI * 1.45, 12, Color(1, 1, 1, 0.55), 1.5, true)
	var f := UiTheme.bold_font()
	var cd_text: String = d.get("cd_text", "")
	if cd_text != "":
		_text_center(f, c + Vector2(0, 7), cd_text, 20, Color.WHITE)
	# nhãn phím: viên thuốc ở góc dưới phải
	var key: String = d.get("key", "")
	if key != "":
		var ks := 11
		var kw := maxf(18.0, f.get_string_size(key, HORIZONTAL_ALIGNMENT_LEFT, -1, ks).x + 10.0)
		var kc := c + Vector2(R * 0.72, R * 0.72)
		var kr := Rect2(kc - Vector2(kw / 2.0, 9), Vector2(kw, 18))
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color("#20160f")
		sb.set_corner_radius_all(9)
		sb.set_border_width_all(1)
		sb.border_color = GOLD
		draw_style_box(sb, kr)
		_text_center(f, kc + Vector2(0, 4), key, ks, GOLD_LIGHT)
	# tên + dòng phụ
	var nm: String = d.get("name", "")
	_text_center(f, c + Vector2(0, R + 19), _fit(f, nm, 12, PITCH - 4.0), 12, UiTheme.TEXT)
	var sub: String = d.get("sub", "")
	if sub != "":
		_text_center(UiTheme.font(), c + Vector2(0, R + 33), _fit(UiTheme.font(), sub, 11, PITCH - 4.0), 11,
			DIM.lightened(0.3) if dim else UiTheme.MUTED)


func _circle_texture(c: Vector2, r: float, tex: Texture2D, mod: Color) -> void:
	var pts := PackedVector2Array()
	var uvs := PackedVector2Array()
	# icon 32×32 có lề trong ~2 px: phóng sao cho phần hình lấp đầy vòng tròn
	var half := r * 1.12
	for s in 32:
		var v := Vector2.from_angle(TAU * s / 32.0)
		pts.append(c + v * r)
		uvs.append(Vector2(0.5, 0.5) + v * r / (half * 2.0))
	draw_colored_polygon(pts, mod, uvs, tex)


func _diamond(p: Vector2, s: float, col: Color) -> void:
	draw_colored_polygon(PackedVector2Array([p + Vector2(0, -s), p + Vector2(s, 0), p + Vector2(0, s), p + Vector2(-s, 0)]), col)


func _text_center(f: Font, base: Vector2, t: String, fs: int, col: Color) -> void:
	var tw := f.get_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	var pos := base - Vector2(tw / 2.0, 0)
	draw_string_outline(f, pos, t, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, 3, Color(0, 0, 0, 0.85))
	draw_string(f, pos, t, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, col)


## Cắt chữ cho vừa bề rộng ô (thêm "…").
static func _fit(f: Font, t: String, fs: int, max_w: float) -> String:
	if f.get_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x <= max_w:
		return t
	var s := t
	while s.length() > 1 and f.get_string_size(s + "…", HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x > max_w:
		s = s.substr(0, s.length() - 1)
	return s.strip_edges() + "…"
