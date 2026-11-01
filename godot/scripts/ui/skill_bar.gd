extends Control
## DH-11: thanh kỹ năng kiểu khung trang trí — ô tròn viền vàng, phím ở góc,
## hồi chiêu quét tròn kèm số giây, lóe sáng khi hồi xong. Tự vẽ bằng _draw (không cần ảnh khung).
## UI-10 (Spec_Notes đợt 6): thanh thấp — bỏ bảng tiêu đề, tên và dòng phụ dưới ô; chỉ còn icon, phím,
## hồi chiêu, huy hiệu số nhỏ (cấp kỹ năng / số bình) và chữ khoá ("Cấp 8") ngay trên ô bị khoá.
## HUD gọi set_slot(i, {...}) mỗi khung hình; khoá dữ liệu:
##   key: String, name: String (giữ cho test/chú thích, không vẽ), icon: Texture2D, cd: 0..1 (phần còn lại),
##   cd_text: String, badge: String (góc trên phải), lock: String (chữ trên ô khoá), ring: Color (màu viền,
##   mặc định vàng), dim: bool (thiếu MP), locked: bool
## SN12-02 (docs/31): hidden: bool (ô chưa mở — không vẽ, các ô sau dồn lại), big: bool (ô Tuyệt kỹ — to hơn, viền vàng
##   sáng), empty: bool (ô đã mở nhưng chưa lắp — vẽ ô trống "+"). Chuột phải một ô → tín hiệu slot_menu; kéo kỹ năng
##   (dữ liệu {"skill_id": id}) thả vào ô → skill_dropped (HUD kiểm ô nhận được qua accept_drop).

signal slot_menu(i: int, at: Vector2)
signal skill_dropped(i: int, id: String)

const UiTheme = preload("res://scripts/ui/ui_theme.gd")

const R := 22.0                 # bán kính ô tròn
const PITCH := 60.0             # khoảng cách tâm 2 ô
const PAD := Vector2(14, 10)    # lề trong khung
const GOLD_DARK := Color("#7a5a2a")
const GOLD := Color("#c9a45c")
const GOLD_LIGHT := Color("#f3d27a")
const WOOD := Color("#2a1d14")
const WOOD_DARK := Color("#170f0a")
const DIM := Color("#4a9df8")
## SN12-02: ô Tuyệt kỹ to hơn + khoảng cách thêm hai bên.
const BIG_R := 26.0
const BIG_GAP := 10.0

var _slots: Array = []
var _flash: Array = []
## Tâm x của từng ô (ô ẩn = -1), tính lại khi ô ẩn / hiện / to nhỏ đổi.
var _xs: Array = []
var _shape_key := ""
## (ô, {"skill_id"}) -> bool: ô nhận kỹ năng kéo thả không (HUD đặt).
var accept_drop: Callable


func _init() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	# SN12-02: nhận chuột phải + thả kỹ năng; vùng thanh nhỏ ở đáy màn hình nên không cản đánh thường.
	mouse_filter = MOUSE_FILTER_PASS


func set_count(n: int) -> void:
	_slots.resize(n)
	_flash.resize(n)
	for i in n:
		if _slots[i] == null:
			_slots[i] = {}
			_flash[i] = 0.0
	_relayout()


func set_slot(i: int, d: Dictionary) -> void:
	var old_cd: float = float(_slots[i].get("cd", 0.0))
	if old_cd > 0.0 and float(d.get("cd", 0.0)) <= 0.0:
		_flash[i] = 0.45
	_slots[i] = d
	var key := ""
	for s in _slots:
		key += ("h" if bool(s.get("hidden", false)) else ("b" if bool(s.get("big", false)) else "n"))
	if key != _shape_key:
		_relayout()


func _relayout() -> void:
	_shape_key = ""
	_xs = []
	var x := PAD.x
	for s in _slots:
		var hidden: bool = bool(s.get("hidden", false))
		var big: bool = bool(s.get("big", false))
		_shape_key += "h" if hidden else ("b" if big else "n")
		if hidden:
			_xs.append(-1.0)
			continue
		var w := PITCH + (BIG_GAP * 2.0 if big else 0.0)
		_xs.append(x + w / 2.0)
		x += w
	custom_minimum_size = Vector2(x + PAD.x, PAD.y * 2.0 + R * 2.0 + 6.0)
	size = custom_minimum_size


func is_slot_visible(i: int) -> bool:
	return i >= 0 and i < _xs.size() and float(_xs[i]) >= 0.0


## Ô dưới điểm `at` (toạ độ cục bộ), -1 nếu không có.
func slot_at(at: Vector2) -> int:
	for i in _xs.size():
		if is_slot_visible(i) and at.distance_to(slot_center(i)) <= _radius(i) + 6.0:
			return i
	return -1


func _radius(i: int) -> float:
	return BIG_R if bool(_slots[i].get("big", false)) else R


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		var i := slot_at(event.position)
		if i >= 0:
			slot_menu.emit(i, get_global_transform() * event.position)
			accept_event()


func _can_drop_data(at: Vector2, data: Variant) -> bool:
	var i := slot_at(at)
	if i < 0 or not (data is Dictionary) or not data.has("skill_id"):
		return false
	return accept_drop.is_valid() and bool(accept_drop.call(i, data))


func _drop_data(at: Vector2, data: Variant) -> void:
	skill_dropped.emit(slot_at(at), str(data.skill_id))


func _process(delta: float) -> void:
	for i in _flash.size():
		_flash[i] = maxf(0.0, _flash[i] - delta)
	queue_redraw()


## Tâm ô thứ i (toạ độ cục bộ) — dùng cho test và chú thích. Ô ẩn: tâm của vị trí ô trước nó.
func slot_center(i: int) -> Vector2:
	var x := PAD.x + PITCH * (i + 0.5)
	if i >= 0 and i < _xs.size() and float(_xs[i]) >= 0.0:
		x = float(_xs[i])
	return Vector2(x, PAD.y + R + 2.0)


func _draw() -> void:
	_draw_frame(Rect2(Vector2.ZERO, size))
	for i in _slots.size():
		if is_slot_visible(i):
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


func _draw_slot(i: int, c: Vector2, d: Dictionary) -> void:
	var rr := _radius(i)  # SN12-02: ô Tuyệt kỹ to hơn
	var big: bool = d.get("big", false)
	var ring: Color = d.get("ring", GOLD_LIGHT if big else GOLD)
	var dim: bool = d.get("dim", false)
	var locked: bool = d.get("locked", false)
	var cd := clampf(float(d.get("cd", 0.0)), 0.0, 1.0)
	if big:
		draw_circle(c, rr + 9.0, Color(GOLD_LIGHT, 0.12))
	if bool(d.get("empty", false)):
		# SN12-02: ô đã mở nhưng chưa lắp kỹ năng
		draw_circle(c, rr + 4.0, WOOD_DARK)
		draw_circle(c, rr, Color("#141a22"))
		draw_arc(c, rr + 1.0, 0.0, TAU, 48, Color(ring, 0.55), 2.0, true)
		var fe := UiTheme.bold_font()
		_text_center(fe, c + Vector2(0, 7), "+", 22, Color(ring, 0.7))
		_key_pill(fe, c, rr, str(d.get("key", "")))
		return
	# hào quang sau ô khi sẵn sàng / lóe sáng khi vừa hồi xong
	if _flash[i] > 0.0:
		draw_circle(c, rr + 10.0, Color(GOLD_LIGHT, _flash[i] * 0.9))
	elif cd <= 0.0 and not dim and not locked:
		draw_circle(c, rr + 5.0, Color(ring, 0.16))
	# nền + icon cắt tròn
	draw_circle(c, rr + 4.0, WOOD_DARK)
	draw_circle(c, rr, Color("#1d2430"))
	var tex: Texture2D = d.get("icon")
	if tex != null:
		var mod := Color.WHITE
		if locked:
			mod = Color(0.35, 0.35, 0.35)
		elif dim:
			mod = Color(0.5, 0.62, 1.0)
		_circle_texture(c, rr - 2.0, tex, mod)
	# hồi chiêu: quạt tối quét theo chiều kim đồng hồ từ đỉnh
	if cd > 0.0:
		var pts := PackedVector2Array([c])
		var steps := maxi(2, ceili(40.0 * cd))
		for s in steps + 1:
			var a := -PI / 2.0 + TAU * (1.0 - cd) + TAU * cd * float(s) / steps
			pts.append(c + Vector2.from_angle(a) * rr)
		draw_colored_polygon(pts, Color(0, 0, 0, 0.62))
	# bóng đổ trong (đáy phải tối) cho ô có chiều sâu
	draw_arc(c, rr - 2.0, PI * -0.15, PI * 0.85, 24, Color(0, 0, 0, 0.35), 4.0, true)
	# viền: vòng tối ngoài, vòng màu, điểm sáng góc trên trái
	var rc := DIM if dim else ring
	draw_arc(c, rr + 2.5, 0.0, TAU, 48, GOLD_DARK if not dim else DIM.darkened(0.5), 4.0, true)
	draw_arc(c, rr + 1.0, 0.0, TAU, 48, rc, 2.0, true)
	draw_arc(c, rr + 1.5, PI * 1.05, PI * 1.45, 12, Color(1, 1, 1, 0.55), 1.5, true)
	var f := UiTheme.bold_font()
	var cd_text: String = d.get("cd_text", "")
	# số giây làm tròn về 0 ("0.0", "0") thì không hiện
	if cd_text != "" and cd_text.to_float() > 0.0:
		_text_center(f, c + Vector2(0, 6), cd_text, 18, Color.WHITE)
	# nhãn phím: viên thuốc ở góc dưới phải
	_key_pill(f, c, rr, str(d.get("key", "")))
	# UI-10: huy hiệu số góc trên phải (cấp kỹ năng, số bình máu)
	var badge: String = d.get("badge", "")
	if badge != "":
		var bs := 11
		var bw := maxf(16.0, f.get_string_size(badge, HORIZONTAL_ALIGNMENT_LEFT, -1, bs).x + 8.0)
		var bc := c + Vector2(rr * 0.72, -rr * 0.78)
		var bsb := StyleBoxFlat.new()
		bsb.bg_color = Color("#2a1638")
		bsb.set_corner_radius_all(8)
		bsb.set_border_width_all(1)
		bsb.border_color = Color("#b46bff")
		draw_style_box(bsb, Rect2(bc - Vector2(bw / 2.0, 8), Vector2(bw, 16)))
		_text_center(f, bc + Vector2(0, 4), badge, bs, Color.WHITE)
	# UI-10: ô khoá ghi cấp mở ngay trên icon
	var lock: String = d.get("lock", "")
	if lock != "":
		_text_center(f, c + Vector2(0, 5), lock, 12, Color("#ffd6a0"))


func _key_pill(f: Font, c: Vector2, r: float, key: String) -> void:
	if key == "":
		return
	var ks := 11
	var kw := maxf(16.0, f.get_string_size(key, HORIZONTAL_ALIGNMENT_LEFT, -1, ks).x + 8.0)
	var kc := c + Vector2(r * 0.72, r * 0.78)
	var kr := Rect2(kc - Vector2(kw / 2.0, 8), Vector2(kw, 16))
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("#20160f")
	sb.set_corner_radius_all(9)
	sb.set_border_width_all(1)
	sb.border_color = GOLD
	draw_style_box(sb, kr)
	_text_center(f, kc + Vector2(0, 4), key, ks, GOLD_LIGHT)


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

