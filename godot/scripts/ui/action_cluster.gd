extends Control
## UI-41 (docs/35 §11, ảnh mẫu chủ dự án 03/11): cụm nút góc phải dưới — nút Đánh tròn lớn, 5 nút nhỏ quanh nó
## (bình máu Q, bình MP F, Thiên phú L, Né Space, Tự đánh Z). Bấm / chạm được (điều khiển kiểu mobile):
## nút gửi đúng action bàn phím (Input.action_press / action_release) nên logic game không đổi; nút Đánh giữ = đánh
## liên tục. HUD gọi set_button(id, {icon, cd 0..1, cd_text, badge, dim, ring, key}) mỗi khung hình.
## UI-41c (03/11, ảnh concept thứ 2 của chủ dự án): nút Đánh = đĩa icon + vòng thép + vành đồng có gai 4 hướng và
## đinh tán; 4 nút màu lớn (Q, F, L, Space) giãn rộng trên vòng cung phía trên – trái, giữa các nút có đốm sáng vàng
## nhấp nháy; nút phụ Z màu đá trầm gắn trên cánh tay đồng cong bên phải. Nhãn phím = viên đồng nhỏ ngoài nút.

signal auto_pressed

const UiTheme = preload("res://scripts/ui/ui_theme.gd")
const Bronze = preload("res://scripts/ui/bronze.gd")

## Nút Đánh: đĩa icon BIG_R, vòng thép tới STEEL_R, vành đồng tới RING_R, gai tới RING_R + 8.
const BIG_R := 36.0
const STEEL_R := 45.0
const RING_R := 53.0
const SMALL_R := 24.0
const ARC_R := 112.0
## [id, action (""= tín hiệu riêng), góc độ (0 = phải, -90 = trên), phím, tên (chú thích), khoảng cách tâm, bán kính, kiểu]
## kiểu "main" = nút màu trên vòng cung, "sub" = nút phụ màu đá trên cánh tay đồng.
const BUTTONS := [["potion", "potion", 165.0, "Q", "Bình máu", ARC_R, SMALL_R, "main"],
	["mp_potion", "mp_potion", 204.0, "F", "Bình MP", ARC_R, SMALL_R, "main"],
	["talent", "talent", 243.0, "L", "Kỹ năng Thiên phú", ARC_R, SMALL_R, "main"],
	["dodge", "dodge", 282.0, "Space", "Né lăn", ARC_R, SMALL_R, "main"],
	["auto", "", -14.0, "Z", "Tự đánh (bật / tắt)", 88.0, 20.0, "sub"]]
const SIZE := Vector2(282, 230)
const CENTER := Vector2(164, 160)
const STONE := Color("#4a4438")
## UI-41d: icon HD riêng của cụm nút (tools/art/hd/action_icons.py) — "act-<tên>"; thiếu file thì dùng icon HUD gửi.
const ACT_DIR := "res://assets/hd/icons/"
const ACT_ICON := {"potion": "act-potion", "mp_potion": "act-mp_potion", "dodge": "act-dodge", "auto": "act-auto"}
const STEEL := Color("#9a9ea2")

var auto_on := false
var _data := {}
var _held := ""
var _t := 0.0
var _tex_cache := {}


func _ready() -> void:
	custom_minimum_size = SIZE
	size = SIZE
	mouse_filter = MOUSE_FILTER_STOP
	# main.gd: chuột / chạm trên cụm nút không bị coi là "đang trỏ vào giao diện" (vẫn đánh được), ngắm theo hướng đi.
	set_meta("hud_action", true)
	tooltip_text = " "


func _get_tooltip(at: Vector2) -> String:
	var id := button_at(at)
	if id == "attack":
		var n: String = _data.get("attack", {}).get("name", "")
		return "Đánh thường" + ((" — " + n) if n != "" else "") + " (J, giữ = đánh liên tục)"
	var b := _def(id)
	if b.is_empty():
		return ""
	var n2: String = _data.get(id, {}).get("name", b[4])
	return "%s (%s)" % [n2, b[3]]


func set_button(id: String, d: Dictionary) -> void:
	_data[id] = d


## Icon của nút: icon HD riêng (theo ACT_ICON, nút Đánh theo d.act = "act-<đòn đánh thường của lớp>"),
## không có thì icon HUD gửi kèm (d.icon).
func _icon(id: String, d: Dictionary) -> Texture2D:
	var name: String = d.get("act", "") if id == "attack" else str(ACT_ICON.get(id, ""))
	if name != "":
		if not _tex_cache.has(name):
			var path := ACT_DIR + name + ".png"
			_tex_cache[name] = null
			if ResourceLoader.exists(path):
				# icon HD 128 px thu nhỏ còn ~48–72 px: lọc tuyến tính + mipmap (icon pixel cũ vẫn Nearest)
				var ct := CanvasTexture.new()
				ct.diffuse_texture = load(path)
				ct.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
				_tex_cache[name] = ct
		if _tex_cache[name] != null:
			return _tex_cache[name]
	return d.get("icon")


func _def(id: String) -> Array:
	for b in BUTTONS:
		if b[0] == id:
			return b
	return []


## Tâm nút id (toạ độ cục bộ).
func button_center(id: String) -> Vector2:
	if id == "attack":
		return CENTER
	var b := _def(id)
	if b.is_empty():
		return Vector2.INF
	return CENTER + Vector2.from_angle(deg_to_rad(float(b[2]))) * float(b[5])


func button_radius(id: String) -> float:
	if id == "attack":
		return RING_R
	var b := _def(id)
	return 0.0 if b.is_empty() else float(b[6])


## Tâm nhãn phím của nút: nút màu — hướng ra ngoài vòng cung; nút phụ — ngay dưới nút (cánh tay đồng ở trên).
func key_pos(id: String) -> Vector2:
	if id == "attack":
		return CENTER + Vector2(0, RING_R + 4.0)
	var b := _def(id)
	var c := button_center(id)
	if b[7] == "sub":
		return c + Vector2(0, float(b[6]) + 12.0)
	return c + Vector2.from_angle(deg_to_rad(float(b[2]))) * (float(b[6]) + 13.0)


## Mép trái nội dung cụm nút (nút + vành + nhãn phím) — HUD dùng để thanh EXP (đầu rồng) không chạm bình máu.
func left_edge() -> float:
	var x := CENTER.x - RING_R - 10.0
	for b in BUTTONS:
		var w := 10.0 + 6.0 * str(b[3]).length()
		x = minf(x, minf(button_center(b[0]).x - float(b[6]) - 6.0, key_pos(b[0]).x - w))
	return x


func button_at(at: Vector2) -> String:
	if at.distance_to(CENTER) <= RING_R + 2.0:
		return "attack"
	for b in BUTTONS:
		if at.distance_to(button_center(b[0])) <= float(b[6]) + 5.0:
			return b[0]
	return ""


func _action_of(id: String) -> String:
	if id == "attack":
		return "attack"
	var b := _def(id)
	return "" if b.is_empty() else str(b[1])


func _gui_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton) or event.button_index != MOUSE_BUTTON_LEFT:
		return
	if event.pressed:
		var id := button_at(event.position)
		if id == "":
			return
		accept_event()
		if id == "auto":
			auto_pressed.emit()
			return
		var act := _action_of(id)
		if act != "" and InputMap.has_action(act):
			Input.action_press(act)
			_held = act
	elif _held != "":
		Input.action_release(_held)
		_held = ""
		accept_event()


func _notification(what: int) -> void:
	# thả chuột ngoài nút / mất focus: nhả action đang giữ
	if (what == NOTIFICATION_MOUSE_EXIT or what == NOTIFICATION_WM_WINDOW_FOCUS_OUT) and _held != "":
		Input.action_release(_held)
		_held = ""


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _draw() -> void:
	var ci := get_canvas_item()
	_draw_arm()
	_draw_glints()
	_draw_attack(ci)
	for b in BUTTONS:
		if b[7] == "sub":
			_draw_sub(b[0], button_center(b[0]), float(b[6]))
		else:
			_draw_main(b[0], button_center(b[0]), float(b[6]))
	for b in BUTTONS:
		var key: String = b[3]
		var col := Bronze.BR_LIGHT
		if b[0] == "auto":
			key = "Z · " + ("BẬT" if auto_on else "TẮT")
			col = Bronze.BR_LIGHT if auto_on else Color(0.68, 0.65, 0.6)
		_key_pill(key_pos(b[0]), key, col)
	_key_pill(key_pos("attack"), "J", Bronze.BR_LIGHT)


## Cánh tay đồng cong nối vành nút Đánh tới nút phụ (Z), hai đầu có núm.
func _draw_arm() -> void:
	for b in BUTTONS:
		if b[7] != "sub":
			continue
		var a := deg_to_rad(float(b[2]))
		var r := float(b[5])
		var a0 := a - 0.62
		var a1 := a + 0.1
		draw_arc(CENTER, r, a0, a1, 32, Color(0, 0, 0, 0.45), 11.0, true)
		draw_arc(CENTER, r, a0, a1, 32, Bronze.BR_DARK, 9.0, true)
		draw_arc(CENTER, r, a0, a1, 32, Bronze.BR, 6.0, true)
		draw_arc(CENTER, r + 1.5, a0, a1, 32, Color(Bronze.BR_LIGHT, 0.65), 1.4, true)
		for e in [a0, a1]:
			var p := CENTER + Vector2.from_angle(e) * r
			draw_circle(p, 5.5, Bronze.BR_DARK)
			draw_circle(p, 4.2, Bronze.BR)
			draw_circle(p + Vector2(-1, -1), 1.6, Color(Bronze.BR_LIGHT, 0.9))


## Đốm sáng vàng nhấp nháy giữa các nút màu (như concept).
func _draw_glints() -> void:
	var mains := BUTTONS.filter(func(b): return b[7] == "main")
	for i in mains.size() - 1:
		var a := deg_to_rad((float(mains[i][2]) + float(mains[i + 1][2])) / 2.0)
		var p := CENTER + Vector2.from_angle(a) * (ARC_R - 22.0)
		var k := 0.65 + 0.35 * sin(_t * 2.4 + i * 1.7)
		draw_circle(p, 9.0, Color(1.0, 0.82, 0.4, 0.10 * k))
		draw_circle(p, 6.0, Color(1.0, 0.85, 0.45, 0.22 * k))
		draw_circle(p, 3.6, Color(1.0, 0.9, 0.6, 0.55 * k))
		draw_circle(p, 2.2, Color(1.0, 0.98, 0.85, k))


func _draw_attack(ci: RID) -> void:
	var c := CENTER
	var d: Dictionary = _data.get("attack", {})
	var pressed := _held == "attack"
	draw_circle(c + Vector2(0, 3), RING_R + 9.0, Color(0, 0, 0, 0.42))
	# gai: 4 hướng chính (trừ hướng dưới — chỗ nhãn phím J) + 4 gai nhỏ chéo
	for i in 8:
		var a := -PI / 2.0 + TAU * i / 8.0
		if i == 4:
			continue
		var big := i % 2 == 0
		var tip := c + Vector2.from_angle(a) * (RING_R + (9.0 if big else 5.0))
		var hw := 7.0 if big else 4.0
		var n := Vector2.from_angle(a).orthogonal()
		var base := c + Vector2.from_angle(a) * (RING_R - 2.0)
		var pts := PackedVector2Array([base + n * hw, tip, base - n * hw])
		draw_colored_polygon(pts, Bronze.BR)
		draw_colored_polygon(PackedVector2Array([base + n * hw, tip, base]), Bronze.BR_MID)
		pts.append(pts[0])
		draw_polyline(pts, Bronze.BR_DARK, 1.4, true)
	# vành đồng: tối ngoài – đồng – gờ sáng trên trái / tối dưới phải – đinh tán
	draw_circle(c, RING_R + 1.0, Bronze.BR_DARK)
	draw_circle(c, RING_R - 0.5, Bronze.BR)
	draw_arc(c, RING_R - 2.5, PI * 0.95, PI * 1.75, 28, Color(Bronze.BR_LIGHT, 0.7), 2.4, true)
	draw_arc(c, RING_R - 2.5, PI * 0.0, PI * 0.75, 28, Color(Bronze.BR_DARK, 0.55), 2.4, true)
	for i in 8:
		var p := c + Vector2.from_angle(TAU * (i + 0.5) / 8.0) * (RING_R - 4.0)
		draw_circle(p, 1.9, Bronze.BR_DARK)
		draw_circle(p + Vector2(-0.4, -0.4), 1.1, Bronze.BR_LIGHT)
	# vòng thép: viền tối, thân xám, nửa trên sáng, nửa dưới tối
	draw_circle(c, STEEL_R + 0.8, Color("#1c1c1e"))
	draw_circle(c, STEEL_R - 0.4, STEEL)
	var mid := (STEEL_R + BIG_R) / 2.0
	var tw := STEEL_R - BIG_R - 1.5
	draw_arc(c, mid, PI * 1.0, PI * 2.0, 40, Color("#c9ccd0", 0.75), tw * 0.6, true)
	draw_arc(c, mid, PI * 0.1, PI * 0.9, 32, Color("#5d6166", 0.8), tw * 0.6, true)
	draw_arc(c, STEEL_R - 1.5, PI * 1.1, PI * 1.6, 24, Color(1, 1, 1, 0.6), 1.2, true)
	# đĩa icon
	draw_circle(c, BIG_R + 0.8, Color("#151719"))
	draw_circle(c, BIG_R, Color("#3e4044") if not pressed else Color("#2c2e31"))
	var tex := _icon("attack", d)
	if tex != null:
		_circle_texture(c, BIG_R - 1.0, tex, Color(0.8, 0.8, 0.8) if pressed else Color.WHITE)
	else:
		_crossed_swords(c, 16.0, Color("#e8e4dc"))
	draw_arc(c, BIG_R - 2.0, 0.0, TAU, 48, Color(0, 0, 0, 0.45), 3.5, true)
	draw_arc(c, BIG_R - 5.0, PI * 1.15, PI * 1.55, 20, Color(1, 1, 1, 0.2), 2.0, true)
	# 4 ngọc xanh trên vòng thép (giữ nét đồng chạm khắc chung của UI-41)
	for i in 4:
		Bronze.gem_at(ci, c + Vector2.from_angle(PI / 4.0 + PI / 2.0 * i) * mid, 2.0, Bronze.GEM_BLUE)


## Nút màu lớn trên vòng cung: vành đồng dày, nền tối có quầng màu theo hệ / bậc, icon cắt tròn.
func _draw_main(id: String, c: Vector2, r: float) -> void:
	var d: Dictionary = _data.get(id, {})
	var ring: Color = d.get("ring", Bronze.BR_MID)
	var dim: bool = d.get("dim", false)
	var cd := clampf(float(d.get("cd", 0.0)), 0.0, 1.0)
	var pressed := _held != "" and _held == _action_of(id)
	var tinted := ring != Bronze.BR_MID
	draw_circle(c + Vector2(0, 2.5), r + 6.5, Color(0, 0, 0, 0.42))
	if cd <= 0.0 and not dim and tinted:
		draw_circle(c, r + 8.0, Color(ring, 0.10 + 0.05 * sin(_t * 3.0)))
		draw_circle(c, r + 6.0, Color(ring, 0.16 + 0.06 * sin(_t * 3.0)))
	_bronze_rim(c, r)
	draw_circle(c, r, Color("#12161a") if not pressed else Color("#0a0c0e"))
	if tinted:
		draw_circle(c, r * 0.8, Color(ring, 0.22))
	var tex := _icon(id, d)
	if tex != null:
		_circle_texture(c, r - 1.0, tex, Color(0.4, 0.4, 0.42) if dim else (Color(0.8, 0.8, 0.8) if pressed else Color.WHITE))
	_cooldown(c, r, cd)
	draw_arc(c, r - 1.5, 0.0, TAU, 40, Color(0, 0, 0, 0.45), 3.0, true)
	draw_arc(c, r - 4.0, PI * 1.15, PI * 1.55, 16, Color(1, 1, 1, 0.22), 1.6, true)
	if tinted:
		draw_arc(c, r + 0.3, 0.0, TAU, 40, Color(ring, 0.9), 1.6, true)
	_cd_and_badge(c, r, d)


## Nút phụ màu đá trầm (Z): vành đồng mảnh hơn, icon kiếm chéo màu ngà; bật = quầng vàng + 2 vệt quay.
func _draw_sub(id: String, c: Vector2, r: float) -> void:
	var on := id == "auto" and auto_on
	draw_circle(c + Vector2(0, 2.5), r + 5.5, Color(0, 0, 0, 0.42))
	if on:
		draw_circle(c, r + 7.0, Color(Bronze.BR_LIGHT, 0.16 + 0.08 * sin(_t * 4.0)))
	_bronze_rim(c, r, 3.0)
	draw_circle(c, r, STONE if not on else STONE.lightened(0.12))
	draw_circle(c + Vector2(-2, -3), r * 0.75, Color(1, 1, 1, 0.05))
	draw_arc(c, r - 1.5, 0.0, TAU, 36, Color(0, 0, 0, 0.35), 2.5, true)
	var tex := _icon(id, {})
	if tex != null:
		_circle_texture(c, r - 1.0, tex, Color.WHITE if on else Color(0.86, 0.84, 0.8))
	else:
		_crossed_swords(c, r * 0.45, Color("#ece2c8") if on else Color("#c9bea4"))
	if on:
		var a0 := _t * 3.0
		draw_arc(c, r - 3.5, a0, a0 + PI * 0.8, 16, Color(Bronze.BR_LIGHT, 0.9), 2.0, true)
		draw_arc(c, r - 3.5, a0 + PI, a0 + PI * 1.8, 16, Color(Bronze.BR_LIGHT, 0.9), 2.0, true)


## Vành đồng nút tròn: viền tối ngoài, thân đồng dày w, gờ sáng trên trái, bóng dưới phải, viền tối trong.
func _bronze_rim(c: Vector2, r: float, w := 4.0) -> void:
	draw_circle(c, r + w + 1.2, Bronze.BR_DARK)
	draw_circle(c, r + w, Bronze.BR)
	draw_arc(c, r + w * 0.55, PI * 0.95, PI * 1.75, 24, Color(Bronze.BR_LIGHT, 0.85), w * 0.45, true)
	draw_arc(c, r + w * 0.55, PI * 0.05, PI * 0.8, 24, Color(Bronze.BR_DARK, 0.5), w * 0.45, true)
	draw_circle(c, r + 0.8, Bronze.BR_DARK)


func _cooldown(c: Vector2, r: float, cd: float) -> void:
	if cd <= 0.0:
		return
	var pts := PackedVector2Array([c])
	var steps := maxi(2, ceili(32.0 * cd))
	for st in steps + 1:
		var a := -PI / 2.0 + TAU * (1.0 - cd) + TAU * cd * float(st) / steps
		pts.append(c + Vector2.from_angle(a) * r)
	draw_colored_polygon(pts, Color(0, 0, 0, 0.62))


## Số giây hồi chiêu giữa nút; số lượng (bình thuốc) ở góc dưới phải, nằm trong nút.
func _cd_and_badge(c: Vector2, r: float, d: Dictionary) -> void:
	var f := UiTheme.bold_font()
	var cd_text: String = d.get("cd_text", "")
	if cd_text != "" and cd_text.to_float() > 0.0:
		_text(f, c + Vector2(0, 5.5), cd_text, 15, Color.WHITE)
	var badge: String = d.get("badge", "")
	if badge != "":
		var bc := c + Vector2(r * 0.6, r * 0.62)
		var bw := maxf(15.0, f.get_string_size(badge, HORIZONTAL_ALIGNMENT_LEFT, -1, 10).x + 8.0)
		_pill(Rect2(bc - Vector2(bw / 2.0, 7.5), Vector2(bw, 15.0)), Color("#1a1210") if badge != "0" else Color("#4a1616"))
		_text(f, bc + Vector2(0, 4), badge, 10, Color.WHITE if badge != "0" else Color("#ff9a90"))


## Nhãn phím dạng viên đồng nhỏ, tâm tại c.
func _key_pill(c: Vector2, key: String, col: Color) -> void:
	var f := UiTheme.bold_font()
	var w := maxf(16.0, f.get_string_size(key, HORIZONTAL_ALIGNMENT_LEFT, -1, 10).x + 9.0)
	_pill(Rect2(c - Vector2(w / 2.0, 8.0), Vector2(w, 16.0)), Color("#241a10"))
	_text(f, c + Vector2(0, 4.0), key, 10, col)


func _pill(r: Rect2, bg: Color) -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.set_corner_radius_all(int(r.size.y / 2.0))
	sb.set_border_width_all(1)
	sb.border_color = Bronze.BR_MID
	sb.anti_aliasing = true
	sb.shadow_color = Color(0, 0, 0, 0.5)
	sb.shadow_size = 2
	draw_style_box(sb, r)


func _crossed_swords(c: Vector2, L: float, col: Color) -> void:
	for side in [-1.0, 1.0]:
		var d := Vector2(side, -1.0).normalized()
		var base := c - d * L
		var tip := c + d * L
		draw_line(base, tip, col, 3.0, true)
		var n := d.orthogonal()
		draw_line(base + d * L * 0.35 + n * L * 0.35, base + d * L * 0.35 - n * L * 0.35, col, 2.0, true)


## Icon cắt tròn. Icon HD riêng (CanvasTexture, nền trong) vừa khít đường kính; icon ô vuông cũ phóng 112 % lấy giữa.
func _circle_texture(c: Vector2, r: float, tex: Texture2D, mod: Color) -> void:
	var pts := PackedVector2Array()
	var uvs := PackedVector2Array()
	var half := r * (1.0 if tex is CanvasTexture else 1.12)
	for s in 32:
		var v := Vector2.from_angle(TAU * s / 32.0)
		pts.append(c + v * r)
		uvs.append(Vector2(0.5, 0.5) + v * r / (half * 2.0))
	draw_colored_polygon(pts, mod, uvs, tex)


func _text(f: Font, base: Vector2, t: String, fs: int, col: Color) -> void:
	var tw := f.get_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	var pos := base - Vector2(tw / 2.0, 0)
	draw_string_outline(f, pos, t, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, 3, Color(0, 0, 0, 0.85))
	draw_string(f, pos, t, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, col)
