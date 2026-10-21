extends Control
## UI-08 (Spec_Notes đợt 6): khung nhân vật góc trái trên kiểu "khung vàng – ngọc tím" theo hình mẫu:
## bảng tên trên cùng, chân dung tròn viền vàng, khiên cấp ở chân chân dung, 2 huy hiệu lục giác hai bên
## (Lực chiến, Điểm tiềm năng).
## UI-08b (góp ý sau bản đầu): EXP là vòng tím quanh chân dung, hai đầu nối vào khiên cấp; không nền,
## không viền chữ nhật (nhìn xuyên thấy bản đồ); cả khung thu nhỏ ×SCALE.
## UI-08f (góp ý lần 2): HP / MP cũng thành vòng bao quanh (nửa trái đỏ, nửa phải xanh, đầy từ dưới lên),
## Thiên phú (hoa sen + tên) dời xuống dưới, chỗ thanh HP/MP cũ.
## Vẽ toàn bộ bằng code trong _draw() (không cần ảnh) — hud.gd gán dữ liệu qua set_data() rồi tự vẽ lại.

const UiTheme = preload("res://scripts/ui/ui_theme.gd")
const SpriteLib = preload("res://scripts/view/sprite_lib.gd")
const ElementIcon = preload("res://scripts/ui/element_icon.gd")

const W := 236.0
const H := 244.0
## Thu nhỏ cả khung (Control.scale). Nhân vật vẽ ×1/SCALE để ra đúng 1 điểm ảnh gốc = 2 điểm màn hình (sắc nét).
const SCALE := 0.75
const GOLD_DARK := Color("#6e4a17")
const GOLD := Color("#d9a845")
const GOLD_LIGHT := Color("#ffe39a")
const GEM := Color("#9a4dff")
const GEM_LIGHT := Color("#e2c4ff")
const PLATE := Color("#160c2a")
const HP_COL := Color("#d8202c")
const MP_COL := Color("#1f4fe0")
const EXP_COL := Color("#b46bff")
## Khoảng hở ở đáy vòng EXP (chỗ khiên cấp), radian mỗi bên.
const EXP_GAP := 0.42
## Vòng HP/MP: hở đáy (khiên cấp) và hở đỉnh (ngọc đỉnh), radian.
const ORB_GAP_BOTTOM := 0.5
const ORB_GAP_TOP := 0.2

const PORTRAIT_C := Vector2(W / 2.0, 108.0)
const PORTRAIT_R := 40.0
## Bán kính vòng HP/MP (ngoài vòng EXP).
const ORB_R := PORTRAIT_R + 19.0

var data := {
	"name": "", "level": 1, "class_id": "", "look": {}, "talent_name": "", "talent_icon": null,
	"rank_color": Color.WHITE, "hp": 1.0, "hp_text": "", "mp": 1.0, "mp_text": "", "exp": 0.0, "exp_text": "",
	"power": 0, "points": 0, "extra": "", "time": 0.0, "element": "",
}


func _ready() -> void:
	custom_minimum_size = Vector2(W, H)
	size = custom_minimum_size
	mouse_filter = MOUSE_FILTER_IGNORE
	scale = Vector2.ONE * SCALE


func set_data(d: Dictionary) -> void:
	data.merge(d, true)
	var extra_h := 20.0 if str(data.extra) != "" else 0.0
	custom_minimum_size.y = H + extra_h
	size = custom_minimum_size
	queue_redraw()


func _draw() -> void:
	_draw_orbs()
	_draw_portrait()
	_draw_name_plate()
	_draw_level_shield(Vector2(PORTRAIT_C.x, PORTRAIT_C.y + PORTRAIT_R + 12.0))
	_text(str(data.exp_text), Vector2(PORTRAIT_C.x - 40.0, PORTRAIT_C.y + PORTRAIT_R + 44.0), 80.0, 13, GEM_LIGHT, true)
	_draw_hex(Vector2(28.0, 70.0), "power")
	_draw_hex(Vector2(W - 28.0, 70.0), "points")
	_draw_orb_value(Vector2(28.0, 128.0), str(data.hp_text), "heart")
	_draw_orb_value(Vector2(W - 28.0, 128.0), str(data.mp_text), "drop")
	_draw_talent(Vector2(34.0, 214.0))
	if str(data.extra) != "":
		_text(str(data.extra), Vector2(0, H + 6.0), W, 13, UiTheme.TEXT, false)


# ------------------------------------------------------------------ từng phần


func _draw_name_plate() -> void:
	var cy := 20.0
	var x0 := 22.0
	var x1 := W - 22.0
	var hh := 13.0
	var pts := PackedVector2Array([Vector2(x0, cy), Vector2(x0 + 12, cy - hh), Vector2(x1 - 12, cy - hh),
		Vector2(x1, cy), Vector2(x1 - 12, cy + hh), Vector2(x0 + 12, cy + hh)])
	draw_colored_polygon(pts, PLATE)
	_gold_outline(pts, 2.0)
	var inner := PackedVector2Array()
	for p in pts:
		inner.append(p + (Vector2(W / 2.0, cy) - p).normalized() * Vector2(4, 3))
	_poly_line(inner, Color(GOLD, 0.45), 1.0)
	# đầu nhọn + móc xoắn hai bên
	for side in [-1.0, 1.0]:
		var tip := Vector2(W / 2.0 + side * (W / 2.0 - 8.0), cy)
		var base := Vector2(W / 2.0 + side * (W / 2.0 - 22.0), cy)
		draw_line(base, tip, GOLD, 2.0, true)
		_diamond(tip, 4.0, GOLD_LIGHT, GOLD_DARK)
		draw_arc(base + Vector2(side * 6.0, -6.0), 5.0, PI * 0.5, PI * 1.5 if side < 0 else -PI * 0.5, 8, GOLD, 1.5, true)
		draw_arc(base + Vector2(side * 6.0, 6.0), 5.0, -PI * 0.5, PI * 0.5 if side > 0 else -PI * 1.5, 8, GOLD, 1.5, true)
	_gem(Vector2(W / 2.0, cy - hh - 1.0), 6.0)
	_text(str(data.name), Vector2(x0 + 12, cy), x1 - x0 - 24, 19, GOLD_LIGHT, true)


func _draw_portrait() -> void:
	var c := PORTRAIT_C
	var r := PORTRAIT_R
	draw_circle(c, r, Color("#05030b"))
	for k in 5:
		draw_circle(c + Vector2(0, -6), r * (0.85 - k * 0.15), Color(GEM, 0.04))
	# nhân vật: chân ở 3/4 dưới vòng tròn, cỡ vừa lọt khung
	if str(data.class_id) != "":
		var frame := int(float(data.time) * 3.0) % 2
		SpriteLib.draw_hero(self, str(data.class_id), data.look, "idle", frame, c + Vector2(0, r * 0.7), false, Color.WHITE, 1.0 / SCALE)
	# vành: vàng tối – vàng – rãnh EXP – vàng mảnh
	draw_arc(c, r + 1.5, 0, TAU, 64, GOLD_DARK, 3.0, true)
	draw_arc(c, r + 4.0, 0, TAU, 64, GOLD, 3.0, true)
	draw_arc(c, r + 3.0, PI * 1.1, PI * 1.45, 16, GOLD_LIGHT, 1.5, true)
	draw_arc(c, r + 8.0, 0, TAU, 64, Color("#0b0614", 0.9), 5.0, true)
	# UI-08b: vòng EXP tím — chạy theo chiều kim đồng hồ từ mép trái khiên cấp vòng qua đỉnh về mép phải
	var a0 := PI / 2.0 + EXP_GAP
	var span := (TAU - EXP_GAP * 2.0) * clampf(float(data.exp), 0.0, 1.0)
	if span > 0.01:
		var pulse := 0.8 + 0.2 * sin(float(data.time) * 3.0)
		draw_arc(c, r + 8.0, a0, a0 + span, 64, Color(GEM, 0.35 * pulse), 9.0, true)
		draw_arc(c, r + 8.0, a0, a0 + span, 64, EXP_COL, 4.0, true)
		draw_arc(c, r + 7.0, a0, a0 + span, 64, Color(GEM_LIGHT, 0.6), 1.0, true)
		draw_circle(c + Vector2.from_angle(a0 + span) * (r + 8.0), 3.0, Color(GEM_LIGHT, pulse))
	draw_arc(c, r + 11.0, 0, TAU, 64, GOLD, 1.5, true)
	# gai vàng chéo + ngọc hai bên + ngọc đỉnh
	for ang in [PI * 0.25, PI * 0.75, PI * 1.25, PI * 1.75]:
		var d := Vector2.from_angle(ang)
		var n := d.orthogonal()
		var p0 := c + d * (ORB_R + 6.0)
		draw_colored_polygon(PackedVector2Array([p0 + n * 4.0, p0 + d * 10.0, p0 - n * 4.0]), GOLD)
		draw_line(p0, p0 + d * 9.0, GOLD_LIGHT, 1.0, true)
	for ang in [0.0, PI]:
		_gem(c + Vector2.from_angle(ang) * (r + 11.0), 5.0)
	var top := c + Vector2(0, -ORB_R)
	for side in [-1.0, 1.0]:
		draw_arc(top + Vector2(side * 9.0, 2.0), 7.0, PI * (1.0 if side < 0 else 1.5), PI * (1.5 if side < 0 else 2.0), 8, GOLD, 2.0, true)
	_gem(top, 7.0)


func _draw_level_shield(c: Vector2) -> void:
	var w := 22.0
	var pts := PackedVector2Array([c + Vector2(-w, -16), c + Vector2(-6, -16), c + Vector2(0, -21), c + Vector2(6, -16),
		c + Vector2(w, -16), c + Vector2(w, 4), c + Vector2(0, 20), c + Vector2(-w, 4)])
	draw_colored_polygon(pts, PLATE)
	_gold_outline(pts, 2.0)
	for side in [-1.0, 1.0]:
		_diamond(c + Vector2(side * (w + 4.0), -6.0), 3.5, GEM, GOLD)
	_gem(c + Vector2(0, -20), 4.0)
	_gem(c + Vector2(0, 21), 3.5)
	var lv := str(data.level)
	_text(lv, c + Vector2(-w, -2), w * 2.0, 20 if lv.length() < 3 else 15, GOLD_LIGHT, true)


func _draw_talent(c: Vector2) -> void:
	var rc: Color = data.rank_color
	var glow := 0.75 + 0.25 * sin(float(data.time) * 2.0)
	draw_circle(c + Vector2(0, -2), 22.0, Color(rc, 0.12 * glow))
	# cánh sen: 7 cánh hình giọt, nhạt dần ra ngoài
	for i in 7:
		var ang := -PI / 2.0 + (i - 3) * 0.42
		_petal(c + Vector2(0, 8), ang, 22.0, 8.0, Color(rc.lightened(0.35), 0.55 + 0.1 * glow))
	for i in 5:
		var ang := -PI / 2.0 + (i - 2) * 0.32
		_petal(c + Vector2(0, 8), ang, 16.0, 6.0, Color(rc.lightened(0.6), 0.75))
	var tex: Texture2D = data.talent_icon
	if tex != null:
		draw_texture_rect(tex, Rect2(c + Vector2(-11, -9), Vector2(22, 22)), false)
	# UI-13: hệ ngũ hành đang dùng (Ngũ Hành Linh Căn) — biểu tượng góc dưới phải hoa sen
	if str(data.element) != "":
		ElementIcon.draw(self, c + Vector2(20, 12), str(data.element), 10.0)
	# đế vàng uốn cong
	draw_arc(c + Vector2(0, -6), 26.0, PI * 0.2, PI * 0.8, 16, GOLD, 2.0, true)
	for side in [-1.0, 1.0]:
		draw_arc(c + Vector2(side * 22.0, 14.0), 5.0, 0, TAU * 0.75, 10, GOLD, 1.5, true)
	# tên Thiên phú bên phải hoa sen, gạch vàng + ngọc bên dưới
	var x0 := c.x + 32.0
	var tw := W - 8.0 - x0
	# Spec_Notes đợt 6: tên Thiên phú một dòng (tự thu chữ cho vừa), không xuống dòng
	_text(str(data.talent_name), Vector2(x0, c.y), tw, 15, GOLD_LIGHT, true)
	draw_line(Vector2(x0 + 10.0, c.y + 22.0), Vector2(x0 + tw - 10.0, c.y + 22.0), GOLD, 1.5, true)
	_diamond(Vector2(x0 + tw / 2.0, c.y + 22.0), 4.0, GEM, GOLD)


func _draw_hex(c: Vector2, kind: String) -> void:
	var r := 23.0
	var pts := PackedVector2Array()
	for i in 6:
		pts.append(c + Vector2.from_angle(-PI / 2.0 + i * TAU / 6.0) * r)
	var active := kind == "power" or int(data.points) > 0
	draw_colored_polygon(pts, PLATE)
	_gold_outline(pts, 2.0)
	var inner := PackedVector2Array()
	for i in 6:
		inner.append(c + Vector2.from_angle(-PI / 2.0 + i * TAU / 6.0) * (r - 4.0))
	_poly_line(inner, Color(GOLD, 0.45), 1.0)
	for side in [-1.0, 1.0]:
		draw_line(c + Vector2(side * r * 0.87, 0), c + Vector2(side * (r * 0.87 + 5.0), 0), GOLD, 2.0, true)
	_gem(c + Vector2(0, r + 1.0), 3.5)
	if kind == "power":
		_compass(c + Vector2(0, -8), 8.0)
		_text(_short(int(data.power)), c + Vector2(-r, 8), r * 2.0, 15, GOLD_LIGHT, true)
		return
	var pts_n := int(data.points)
	var col := GOLD_LIGHT if active else Color(GOLD, 0.45)
	if active:
		var pulse := 0.5 + 0.5 * sin(float(data.time) * 4.0)
		_poly_line(pts, Color(GOLD_LIGHT, 0.4 * pulse), 4.0)
	_text("+%d" % pts_n if active else "0", c + Vector2(-r, -5), r * 2.0, 18, col, true)
	_text("Điểm", c + Vector2(-r, 10), r * 2.0, 11, Color(col, 0.85), false)


## UI-08f: vòng HP (nửa trái) và MP (nửa phải) bao ngoài vòng EXP, đầy từ đáy (khiên cấp) lên đỉnh.
func _draw_orbs() -> void:
	var c := PORTRAIT_C
	var r := ORB_R
	var lo := PI / 2.0 + ORB_GAP_BOTTOM
	var hi := PI * 1.5 - ORB_GAP_TOP
	var len := hi - lo
	# rãnh tối + 2 viền vàng mảnh
	for side in [1.0, -1.0]:
		var a0: float = PI / 2.0 + side * ORB_GAP_BOTTOM
		var a1: float = PI / 2.0 + side * (PI - ORB_GAP_TOP)
		draw_arc(c, r, minf(a0, a1), maxf(a0, a1), 48, Color("#0b0614", 0.92), 11.0, true)
		draw_arc(c, r - 6.0, minf(a0, a1), maxf(a0, a1), 48, GOLD_DARK, 1.5, true)
		draw_arc(c, r + 6.0, minf(a0, a1), maxf(a0, a1), 48, GOLD, 2.0, true)
		_diamond(c + Vector2.from_angle(a0) * r, 4.0, GOLD, GOLD_DARK)
	var pulse := 0.8 + 0.2 * sin(float(data.time) * 3.0)
	# HP: chiều kim đồng hồ từ đáy trái lên đỉnh; MP: ngược chiều từ đáy phải lên đỉnh
	for orb in [[float(data.hp), HP_COL, 1.0], [float(data.mp), MP_COL, -1.0]]:
		var v := clampf(float(orb[0]), 0.0, 1.0)
		if v <= 0.005:
			continue
		var col: Color = orb[1]
		var side: float = orb[2]
		var a0: float = PI / 2.0 + side * ORB_GAP_BOTTOM
		var a1 := a0 + side * len * v
		var from := minf(a0, a1)
		var to := maxf(a0, a1)
		draw_arc(c, r, from, to, 48, col, 8.0, true)
		draw_arc(c, r - 2.0, from, to, 48, Color(col.lightened(0.5), 0.6), 2.0, true)
		draw_arc(c, r + 3.0, from, to, 48, col.darkened(0.4), 1.5, true)
		draw_circle(c + Vector2.from_angle(a1) * r, 3.5, Color(col.lightened(0.6), pulse))


## Số HP/MP cạnh vòng: huy hiệu tim / giọt nước + "hiện tại / tối đa".
func _draw_orb_value(c: Vector2, label: String, emblem: String) -> void:
	var er := 12.0
	draw_circle(c, er, PLATE)
	draw_arc(c, er, 0, TAU, 32, GOLD, 2.0, true)
	if emblem == "heart":
		_heart(c + Vector2(0, 1), er * 0.62)
	else:
		_drop(c + Vector2(0, 1), er * 0.62)
	var parts := label.split(" / ")
	if parts.size() == 2:
		_text(parts[0], c + Vector2(-28, er + 10.0), 56.0, 15, Color.WHITE, true)
		_text("/ " + parts[1], c + Vector2(-28, er + 24.0), 56.0, 11, UiTheme.MUTED, false)
	else:
		_text(label, c + Vector2(-28, er + 10.0), 56.0, 13, Color.WHITE, true)


# ------------------------------------------------------------------ nét vẽ


func _gold_outline(pts: PackedVector2Array, width: float) -> void:
	_poly_line(pts, GOLD_DARK, width + 2.0)
	_poly_line(pts, GOLD, width)


func _poly_line(pts: PackedVector2Array, col: Color, width: float) -> void:
	var closed := pts.duplicate()
	closed.append(pts[0])
	draw_polyline(closed, col, width, true)


func _diamond(p: Vector2, s: float, fill: Color, edge: Color) -> void:
	var pts := PackedVector2Array([p + Vector2(0, -s), p + Vector2(s, 0), p + Vector2(0, s), p + Vector2(-s, 0)])
	draw_colored_polygon(pts, fill)
	_poly_line(pts, edge, 1.0)


## Ngọc tím viền vàng có điểm sáng.
func _gem(p: Vector2, s: float) -> void:
	_diamond(p, s + 2.0, GOLD, GOLD_DARK)
	_diamond(p, s, GEM, GEM.darkened(0.4))
	draw_colored_polygon(PackedVector2Array([p + Vector2(0, -s), p + Vector2(s * 0.5, -s * 0.2), p + Vector2(0, 0), p + Vector2(-s * 0.5, -s * 0.2)]),
		Color(GEM_LIGHT, 0.85))


func _petal(base: Vector2, ang: float, length: float, width: float, col: Color) -> void:
	var d := Vector2.from_angle(ang)
	var n := d.orthogonal()
	var pts := PackedVector2Array()
	for i in 9:
		var t := float(i) / 8.0
		pts.append(base + d * length * t + n * width * sin(t * PI) * (1.0 - t * 0.3))
	for i in range(7, 0, -1):
		var t := float(i) / 8.0
		pts.append(base + d * length * t - n * width * sin(t * PI) * (1.0 - t * 0.3))
	draw_colored_polygon(pts, col)


func _heart(c: Vector2, s: float) -> void:
	var pts := PackedVector2Array()
	for i in 32:
		var t := TAU * i / 32.0
		var x := 16.0 * pow(sin(t), 3)
		var y := -(13.0 * cos(t) - 5.0 * cos(2 * t) - 2.0 * cos(3 * t) - cos(4 * t))
		pts.append(c + Vector2(x, y) * s / 16.0)
	draw_colored_polygon(pts, HP_COL)
	_poly_line(pts, Color("#5a0008"), 1.0)
	draw_circle(c + Vector2(-s * 0.4, -s * 0.35), s * 0.22, Color(1, 0.8, 0.8, 0.7))


func _drop(c: Vector2, s: float) -> void:
	var pts := PackedVector2Array()
	pts.append(c + Vector2(0, -s * 1.15))
	for i in 17:
		var a := -PI * 0.15 + PI * 1.3 * i / 16.0
		pts.append(c + Vector2(0, s * 0.25) + Vector2.from_angle(a) * s * 0.75)
	draw_colored_polygon(pts, Color("#3a7bff"))
	_poly_line(pts, Color("#0a1d6a"), 1.0)
	draw_circle(c + Vector2(-s * 0.25, s * 0.1), s * 0.18, Color(0.85, 0.95, 1, 0.75))


## La bàn 4 cánh (biểu tượng Lực chiến).
func _compass(c: Vector2, s: float) -> void:
	for i in 4:
		var d := Vector2.from_angle(i * PI / 2.0)
		var n := d.orthogonal()
		draw_colored_polygon(PackedVector2Array([c + n * s * 0.25, c + d * s, c - n * s * 0.25]), GOLD_LIGHT if i % 2 == 0 else GOLD)
	for i in 4:
		var d := Vector2.from_angle(PI / 4.0 + i * PI / 2.0)
		draw_line(c, c + d * s * 0.55, GOLD, 1.5, true)
	draw_arc(c, s * 0.6, 0, TAU, 16, GOLD, 1.0, true)


## Chữ căn giữa theo chiều ngang trong [at.x, at.x + width], tâm dọc tại at.y; tự thu nhỏ cỡ chữ cho vừa.
func _text(s: String, at: Vector2, width: float, font_size: int, col: Color, bold: bool, max_lines := 1) -> void:
	if s == "":
		return
	var f := UiTheme.bold_font() if bold else UiTheme.font()
	var fsz := UiTheme.fs(font_size)
	while fsz > 7 and f.get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, fsz).x > width * max_lines * 0.92:
		fsz -= 1
	if max_lines > 1 and f.get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, fsz).x > width:
		var top := at.y - f.get_height(fsz) * 0.5
		draw_multiline_string_outline(f, Vector2(at.x, top + f.get_ascent(fsz)), s, HORIZONTAL_ALIGNMENT_CENTER, width, fsz, max_lines, 3, Color(0, 0, 0, 0.85))
		draw_multiline_string(f, Vector2(at.x, top + f.get_ascent(fsz)), s, HORIZONTAL_ALIGNMENT_CENTER, width, fsz, max_lines, col)
		return
	var base := Vector2(at.x, at.y + (f.get_ascent(fsz) - f.get_descent(fsz)) * 0.5)
	draw_string_outline(f, base, s, HORIZONTAL_ALIGNMENT_CENTER, width, fsz, 3, Color(0, 0, 0, 0.85))
	draw_string(f, base, s, HORIZONTAL_ALIGNMENT_CENTER, width, fsz, col)


static func _short(n: int) -> String:
	if n >= 1000000:
		return "%.1fM" % (n / 1000000.0)
	if n >= 10000:
		return "%.1fk" % (n / 1000.0)
	return str(n)
