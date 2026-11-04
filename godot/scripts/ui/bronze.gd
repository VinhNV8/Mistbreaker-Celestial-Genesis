extends RefCounted
## UI-41 (docs/35 §11, chủ dự án 03/11 chọn theo ảnh mẫu): bộ vẽ giao diện "đồng chạm khắc" dùng chung —
## khung viền đồng nhiều lớp + chấm chạm khắc, ngọc gắn 4 góc, nền xanh rêu tối, chữ vàng kiểu cổ (Cormorant SC);
## hoạ tiết rồng / đầu sư tử giản lược, cuộn giấy da + dấu sáp, thanh tiến độ, nhãn phím treo.
## Mọi hàm vẽ bằng RenderingServer trên RID canvas item (dùng được cả trong StyleBox._draw lẫn Control._draw:
## truyền get_canvas_item()).

const UiTheme = preload("res://scripts/ui/ui_theme.gd")

const FONT_TITLE := "res://assets/fonts/CormorantSC-Bold.ttf"

const MOSS := Color("#1b251f")
const MOSS_HI := Color("#2e3d31")
const BR_DARK := Color("#2a1c0e")
const BR := Color("#8a6636")
const BR_MID := Color("#b48c4c")
const BR_LIGHT := Color("#ecca86")
const GOLD_TEXT := Color("#f3d78e")
const GEM_BLUE := Color("#34b4ea")
const GEM_RED := Color("#e2483c")
const GEM_GREEN := Color("#3ccf7a")
const GEM_PURPLE := Color("#a35cff")
const PARCH := Color("#ead9ae")
const PARCH_DARK := Color("#b8995e")
const INK := Color("#3a2614")
const INK_RED := Color("#7a2a12")
const WAX := Color("#b0241c")

static var _title: Font


## Font tiêu đề kiểu cổ (Cormorant SC Bold, OFL — assets/fonts/OFL-CormorantSC.txt); thiếu file dùng font đậm.
static func title_font() -> Font:
	if _title == null:
		if ResourceLoader.exists(FONT_TITLE):
			var f = load(FONT_TITLE)
			if f is FontFile:
				var ff: FontFile = (f as FontFile).duplicate()
				ff.fallbacks = [UiTheme.bold_font()]
				_title = ff
		if _title == null:
			_title = UiTheme.bold_font()
	return _title


# ------------------------------------------------------------------ khung


static func _sb(bg: Color, radius: float, border: float, bcol: Color, center := true) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.draw_center = center
	sb.set_corner_radius_all(int(radius))
	sb.set_border_width_all(int(border))
	sb.border_color = bcol
	sb.anti_aliasing = true
	return sb


## Khung đồng: nền rêu, viền 3 lớp (tối – đồng – gờ sáng), chấm chạm khắc dọc viền, góc gắn ngọc.
## s = tỉ lệ (1 bảng lớn, ~0,7 khung HUD); crest = phù hiệu giữa cạnh trên (bảng lớn).
static func frame(ci: RID, r: Rect2, s := 1.0, bg := Color(MOSS, 0.94), gem := GEM_BLUE, crest := false) -> void:
	var rs := RenderingServer
	var w := maxf(3.0, roundf(6.0 * s))
	var base := _sb(bg, 6.0 * s, 0, Color.TRANSPARENT)
	base.shadow_color = Color(0, 0, 0, 0.45)
	base.shadow_size = int(7.0 * s)
	base.shadow_offset = Vector2(0, 2)
	base.draw(ci, r)
	# vệt sáng nửa trên (rêu sáng hơn)
	var hi := _sb(Color(MOSS_HI, 0.45), 4.0 * s, 0, Color.TRANSPARENT)
	hi.draw(ci, Rect2(r.position + Vector2(w, w), Vector2(maxf(0.0, r.size.x - 2.0 * w), maxf(0.0, r.size.y * 0.42 - w))))
	# viền: lớp tối ngoài, đồng, gờ sáng trên / tối dưới
	_sb(Color.TRANSPARENT, 7.0 * s, w + 2.0, BR_DARK, false).draw(ci, r)
	_sb(Color.TRANSPARENT, 6.0 * s, w, BR, false).draw(ci, r.grow(-1.0))
	var p := r.position
	var e := r.end
	rs.canvas_item_add_line(ci, p + Vector2(8 * s, 2), Vector2(e.x - 8 * s, p.y + 2), Color(BR_LIGHT, 0.85), 1.2, true)
	rs.canvas_item_add_line(ci, Vector2(p.x + 2, p.y + 8 * s), Vector2(p.x + 2, e.y - 8 * s), Color(BR_LIGHT, 0.5), 1.0, true)
	rs.canvas_item_add_line(ci, Vector2(p.x + 8 * s, e.y - 2), Vector2(e.x - 8 * s, e.y - 2), Color(BR_DARK, 0.9), 1.2, true)
	rs.canvas_item_add_line(ci, Vector2(e.x - 2, p.y + 8 * s), Vector2(e.x - 2, e.y - 8 * s), Color(BR_DARK, 0.7), 1.0, true)
	# viền trong mảnh vàng
	_sb(Color.TRANSPARENT, 3.0 * s, 1, Color(BR_LIGHT, 0.4), false).draw(ci, r.grow(-(w + 2.0)))
	# chạm khắc: chấm + vạch xen kẽ dọc dải viền
	var step := maxf(7.0, 10.0 * s)
	var mid := w * 0.5 + 1.0
	var x := p.x + 18.0 * s
	var k := 0
	while x < e.x - 18.0 * s:
		var col := Color(BR_DARK, 0.6)
		if k % 2 == 0:
			rs.canvas_item_add_circle(ci, Vector2(x, p.y + mid), maxf(0.9, 1.3 * s), col)
			rs.canvas_item_add_circle(ci, Vector2(x, e.y - mid), maxf(0.9, 1.3 * s), col)
		else:
			rs.canvas_item_add_line(ci, Vector2(x, p.y + mid - 1.5 * s), Vector2(x, p.y + mid + 1.5 * s), col, 1.0)
			rs.canvas_item_add_line(ci, Vector2(x, e.y - mid - 1.5 * s), Vector2(x, e.y - mid + 1.5 * s), col, 1.0)
		x += step
		k += 1
	var y := p.y + 18.0 * s
	k = 0
	while y < e.y - 18.0 * s:
		if k % 2 == 0:
			rs.canvas_item_add_circle(ci, Vector2(p.x + mid, y), maxf(0.9, 1.3 * s), Color(BR_DARK, 0.6))
			rs.canvas_item_add_circle(ci, Vector2(e.x - mid, y), maxf(0.9, 1.3 * s), Color(BR_DARK, 0.6))
		y += step
		k += 1
	for c in [[p, Vector2(1, 1)], [Vector2(e.x, p.y), Vector2(-1, 1)], [e, Vector2(-1, -1)], [Vector2(p.x, e.y), Vector2(1, -1)]]:
		corner(ci, c[0] + c[1] * (w * 0.5 + 1.0), c[1], s, gem)
	if crest and r.size.x > 160.0:
		crest_at(ci, Vector2(r.get_center().x, p.y + 1.0), s, gem)


## Góc khung: tấm đồng hình thoi + 2 cuộn hoa văn chạy dọc 2 cạnh + ngọc giữa.
static func corner(ci: RID, at: Vector2, d: Vector2, s: float, gem: Color) -> void:
	var rs := RenderingServer
	for side in [Vector2(d.x, 0), Vector2(0, d.y)]:
		var pts := PackedVector2Array()
		for i in 9:
			var t := float(i) / 8.0
			var along: Vector2 = side * (6.0 + 18.0 * t) * s
			var off: Vector2 = Vector2(side.y, side.x).abs() * Vector2(d.x, d.y) * sin(t * PI) * 4.0 * s
			pts.append(at + along + off)
		rs.canvas_item_add_polyline(ci, pts, PackedColorArray([BR_DARK]), maxf(2.0, 3.2 * s), true)
		rs.canvas_item_add_polyline(ci, pts, PackedColorArray([BR_LIGHT]), maxf(1.0, 1.4 * s), true)
		rs.canvas_item_add_circle(ci, pts[pts.size() - 1], maxf(1.2, 1.8 * s), BR_LIGHT)
	var q := 10.0 * s
	_poly(ci, [at + Vector2(0, -q - 2), at + Vector2(q + 2, 0), at + Vector2(0, q + 2), at + Vector2(-q - 2, 0)], BR_DARK)
	_poly(ci, [at + Vector2(0, -q), at + Vector2(q, 0), at + Vector2(0, q), at + Vector2(-q, 0)], BR)
	_poly(ci, [at + Vector2(0, -q), at + Vector2(q, 0), at, at + Vector2(-q, 0)], Color(BR_LIGHT, 0.45))
	gem_at(ci, at, 4.6 * s, gem)


## Phù hiệu giữa cạnh trên: tấm khiên đồng nhỏ + ngọc + 2 cánh hoa văn.
static func crest_at(ci: RID, at: Vector2, s: float, gem: Color) -> void:
	var rs := RenderingServer
	for sx in [-1.0, 1.0]:
		var pts := PackedVector2Array()
		for i in 10:
			var t := float(i) / 9.0
			pts.append(at + Vector2(sx * (14.0 + 34.0 * t) * s, (-2.0 - 6.0 * sin(t * PI)) * s))
		rs.canvas_item_add_polyline(ci, pts, PackedColorArray([BR_DARK]), 3.4 * s, true)
		rs.canvas_item_add_polyline(ci, pts, PackedColorArray([BR_LIGHT]), 1.4 * s, true)
	var h := 13.0 * s
	var wv := 15.0 * s
	_poly(ci, [at + Vector2(-wv - 2, -h - 2), at + Vector2(wv + 2, -h - 2), at + Vector2(wv + 2, 2), at + Vector2(0, h + 4), at + Vector2(-wv - 2, 2)], BR_DARK)
	_poly(ci, [at + Vector2(-wv, -h), at + Vector2(wv, -h), at + Vector2(wv, 1), at + Vector2(0, h + 1), at + Vector2(-wv, 1)], BR)
	_poly(ci, [at + Vector2(-wv, -h), at + Vector2(wv, -h), at + Vector2(wv * 0.6, -h * 0.4), at + Vector2(-wv * 0.6, -h * 0.4)], Color(BR_LIGHT, 0.5))
	gem_at(ci, at + Vector2(0, -2 * s), 5.5 * s, gem)


## Ngọc mài giác gắn ổ đồng.
static func gem_at(ci: RID, c: Vector2, r: float, col: Color) -> void:
	var rs := RenderingServer
	rs.canvas_item_add_circle(ci, c, r + 2.2, BR_DARK)
	rs.canvas_item_add_circle(ci, c, r + 1.2, BR_LIGHT)
	rs.canvas_item_add_circle(ci, c, r, col.darkened(0.45))
	_poly(ci, [c + Vector2(0, -r), c + Vector2(r * 0.95, -r * 0.1), c + Vector2(0, r * 0.25)], col)
	_poly(ci, [c + Vector2(0, -r), c + Vector2(-r * 0.95, -r * 0.1), c + Vector2(0, r * 0.25)], col.lightened(0.25))
	_poly(ci, [c + Vector2(-r * 0.95, -r * 0.1), c + Vector2(0, r * 0.25), c + Vector2(0, r * 0.95)], col.darkened(0.2))
	rs.canvas_item_add_circle(ci, c + Vector2(-r * 0.35, -r * 0.4), maxf(0.8, r * 0.22), Color(1, 1, 1, 0.85))


# ------------------------------------------------------------------ hoạ tiết


## Đầu rồng đồng giản lược (nhìn ngang, hướng phải; flip = hướng trái): cổ vươn, hàm há có răng, 2 sừng cong ra sau,
## bờm gai dọc gáy, cánh dơi xoè lên phía sau. Gốc = chân cổ. s ≈ 1 → cao ~60 px.
static func dragon(ci: RID, at: Vector2, s: float, flip := false, eye := GEM_RED) -> void:
	var fx := -1.0 if flip else 1.0
	var rs := RenderingServer
	# cánh (sau cùng): 3 xương nan, màng giữa các nan
	var root := Vector2(-6, -14)
	var tips := [Vector2(-4, -66), Vector2(-24, -58), Vector2(-40, -42)]
	var dips := [Vector2(-12, -44), Vector2(-28, -36), Vector2(-30, -18)]
	var wing := [root, tips[0], dips[0], tips[1], dips[1], tips[2], dips[2]]
	_outlined(ci, _xf(wing, at, s, fx), Color(BR, 0.95), BR_DARK, 2.2 * s)
	for t in tips:
		rs.canvas_item_add_line(ci, _xf([root], at, s, fx)[0], _xf([t], at, s, fx)[0], Color(BR_LIGHT, 0.7), 1.6 * s, true)
	# cổ + đầu
	var head := [Vector2(-8, 0), Vector2(-4, -16), Vector2(4, -28), Vector2(14, -36), Vector2(26, -38), Vector2(38, -35), Vector2(52, -30),
		Vector2(62, -26), Vector2(64, -21), Vector2(52, -19), Vector2(40, -20), Vector2(58, -12), Vector2(54, -7), Vector2(38, -10),
		Vector2(26, -6), Vector2(16, 0)]
	var th := _xf(head, at, s, fx)
	# sừng cong ra sau (vẽ trước đầu)
	for hn in [[Vector2(20, -36), Vector2(8, -50), Vector2(-6, -54)], [Vector2(28, -37), Vector2(22, -52), Vector2(10, -60)]]:
		var hp := _xf([hn[0], hn[1], hn[2]], at, s, fx)
		rs.canvas_item_add_polyline(ci, hp, PackedColorArray([BR_DARK]), 6.0 * s, true)
		rs.canvas_item_add_polyline(ci, hp, PackedColorArray([BR_LIGHT]), 3.0 * s, true)
	# bờm gai dọc gáy
	for k in 4:
		var b0 := Vector2(-6 + k * 5, -10 - k * 7)
		_outlined(ci, _xf([b0, b0 + Vector2(-10, -4), b0 + Vector2(-2, 5)], at, s, fx), BR, BR_DARK, 1.4 * s)
	_outlined(ci, th, BR_MID, BR_DARK, 2.4 * s)
	# gờ sáng sống mũi, gờ mày, lỗ mũi, vảy cổ
	rs.canvas_item_add_polyline(ci, _xf([Vector2(14, -35), Vector2(38, -33), Vector2(60, -25)], at, s, fx), PackedColorArray([Color(BR_LIGHT, 0.9)]), 1.6 * s, true)
	rs.canvas_item_add_polyline(ci, _xf([Vector2(26, -33), Vector2(34, -36), Vector2(40, -31)], at, s, fx), PackedColorArray([BR_DARK]), 1.8 * s, true)
	rs.canvas_item_add_circle(ci, _xf([Vector2(58, -25)], at, s, fx)[0], 1.3 * s, BR_DARK)
	for k in 3:
		var p0 := Vector2(-2 + k * 6, -6 - k * 8)
		rs.canvas_item_add_polyline(ci, _xf([p0, p0 + Vector2(5, 2), p0 + Vector2(8, 6)], at, s, fx), PackedColorArray([Color(BR_DARK, 0.8)]), 1.2 * s, true)
	# răng trên / dưới, lưỡi
	for k in 3:
		var tp := Vector2(44 + k * 5, -20)
		_poly(ci, _xf([tp, tp + Vector2(3, 0), tp + Vector2(1.5, 4)], at, s, fx), Color("#f4ecd8"))
		var bp := Vector2(42 + k * 5, -10)
		_poly(ci, _xf([bp, bp + Vector2(3, 0), bp + Vector2(1.5, -4)], at, s, fx), Color("#f4ecd8"))
	rs.canvas_item_add_polyline(ci, _xf([Vector2(40, -15), Vector2(52, -15), Vector2(58, -18)], at, s, fx), PackedColorArray([Color("#c0402e")]), 1.6 * s, true)
	gem_at(ci, _xf([Vector2(32, -29)], at, s, fx)[0], 2.8 * s, eye)


## Huy hiệu đầu sư tử: vòng đồng, bờm 14 tia, mặt, mắt, mũi.
static func lion(ci: RID, c: Vector2, r: float) -> void:
	var rs := RenderingServer
	rs.canvas_item_add_circle(ci, c, r + 3.0, BR_DARK)
	rs.canvas_item_add_circle(ci, c, r + 1.5, BR_LIGHT)
	rs.canvas_item_add_circle(ci, c, r, Color("#3a2a16"))
	for i in 14:
		var a := TAU * i / 14.0
		var tip := c + Vector2.from_angle(a) * r * 0.95
		_poly(ci, [c + Vector2.from_angle(a - 0.24) * r * 0.5, tip, c + Vector2.from_angle(a + 0.24) * r * 0.5], BR if i % 2 else BR_MID)
	rs.canvas_item_add_circle(ci, c + Vector2(0, r * 0.06), r * 0.52, BR_MID)
	rs.canvas_item_add_circle(ci, c + Vector2(0, -r * 0.08), r * 0.42, Color(BR_LIGHT, 0.55))
	for sx in [-1.0, 1.0]:
		_poly(ci, [c + Vector2(sx * r * 0.32, -r * 0.16), c + Vector2(sx * r * 0.12, -r * 0.2), c + Vector2(sx * r * 0.14, -r * 0.08)], BR_DARK)
		rs.canvas_item_add_circle(ci, c + Vector2(sx * r * 0.5, -r * 0.42), r * 0.12, BR)
	_poly(ci, [c + Vector2(-r * 0.12, r * 0.08), c + Vector2(r * 0.12, r * 0.08), c + Vector2(0, r * 0.22)], BR_DARK)
	rs.canvas_item_add_line(ci, c + Vector2(0, r * 0.22), c + Vector2(0, r * 0.32), BR_DARK, 1.2, true)
	rs.canvas_item_add_polyline(ci, PackedVector2Array([c + Vector2(-r * 0.2, r * 0.38), c + Vector2(0, r * 0.32), c + Vector2(r * 0.2, r * 0.38)]),
		PackedColorArray([BR_DARK]), 1.2, true)


# ------------------------------------------------------------------ giấy da, thanh, nhãn


## Cuộn giấy da: thân giấy (mép sẫm, vết ố), 2 trục cuộn trên / dưới có núm gỗ, dấu sáp đỏ góc trên phải.
static func parchment(ci: RID, r: Rect2, seal := true) -> void:
	var rs := RenderingServer
	var body := Rect2(r.position + Vector2(4, 9), r.size - Vector2(8, 18))
	var sb := _sb(PARCH, 3, 2, PARCH_DARK)
	sb.shadow_color = Color(0, 0, 0, 0.4)
	sb.shadow_size = 6
	sb.shadow_offset = Vector2(0, 3)
	sb.draw(ci, body)
	# mép sẫm dần vào trong
	for i in 4:
		_sb(Color.TRANSPARENT, 3, 2, Color(PARCH_DARK, 0.22 - i * 0.05), false).draw(ci, body.grow(-2.0 - i * 2.0))
	for v in [Vector3(0.18, 0.3, 14), Vector3(0.74, 0.62, 18), Vector3(0.4, 0.85, 10)]:
		rs.canvas_item_add_circle(ci, body.position + Vector2(v.x, v.y) * body.size, v.z, Color(PARCH_DARK, 0.12))
	for y in [r.position.y + 6.0, r.end.y - 6.0]:
		var roll := Rect2(Vector2(r.position.x - 4, y - 6), Vector2(r.size.x + 8, 12))
		_sb(PARCH_DARK, 6, 1, Color("#7a5a30")).draw(ci, roll)
		rs.canvas_item_add_line(ci, Vector2(roll.position.x + 6, y - 3), Vector2(roll.end.x - 6, y - 3), Color(PARCH, 0.9), 2.0, true)
		rs.canvas_item_add_line(ci, Vector2(roll.position.x + 6, y + 3), Vector2(roll.end.x - 6, y + 3), Color("#7a5a30", 0.6), 1.0, true)
		for x in [roll.position.x - 3.0, roll.end.x + 3.0]:
			rs.canvas_item_add_circle(ci, Vector2(x, y), 6.0, BR_DARK)
			rs.canvas_item_add_circle(ci, Vector2(x, y), 4.2, Color("#6a4424"))
			rs.canvas_item_add_circle(ci, Vector2(x - 1, y - 1.5), 1.6, Color(BR_LIGHT, 0.6))
	if seal:
		wax_seal(ci, Vector2(r.end.x - 16, r.position.y + 20), 10.0)


static func wax_seal(ci: RID, c: Vector2, r: float) -> void:
	var rs := RenderingServer
	var pts := PackedVector2Array()
	for i in 16:
		var a := TAU * i / 16.0
		pts.append(c + Vector2.from_angle(a) * r * (1.0 + 0.12 * sin(i * 2.7)))
	rs.canvas_item_add_polygon(ci, pts, PackedColorArray([WAX.darkened(0.25)]))
	rs.canvas_item_add_circle(ci, c, r * 0.78, WAX)
	rs.canvas_item_add_circle(ci, c, r * 0.6, WAX.darkened(0.15))
	for i in 5:
		var a := -PI / 2.0 + TAU * i / 5.0
		_poly(ci, [c, c + Vector2.from_angle(a - 0.25) * r * 0.22, c + Vector2.from_angle(a) * r * 0.5, c + Vector2.from_angle(a + 0.25) * r * 0.22], Color("#e8786a"))
	rs.canvas_item_add_circle(ci, c + Vector2(-r * 0.35, -r * 0.4), r * 0.16, Color(1, 1, 1, 0.35))


## Thanh tiến độ (rãnh tối viền đồng, phần đầy màu col có vệt bóng) + chữ "a/b" giữa.
static func progress(ci: RID, r: Rect2, frac: float, col: Color, text := "", font_size := 10) -> void:
	var rs := RenderingServer
	_sb(Color("#2a1a0c"), r.size.y * 0.5, 1, BR_DARK).draw(ci, r)
	var f := clampf(frac, 0.0, 1.0)
	if f > 0.0:
		var fr := Rect2(r.position + Vector2(1.5, 1.5), Vector2(maxf(r.size.y - 3.0, (r.size.x - 3.0) * f), r.size.y - 3.0))
		_sb(col, fr.size.y * 0.5, 0, Color.TRANSPARENT).draw(ci, fr)
		rs.canvas_item_add_line(ci, fr.position + Vector2(3, 2), Vector2(fr.end.x - 3, fr.position.y + 2), Color(1, 1, 1, 0.45), 1.2, true)
	if text != "":
		var font := UiTheme.bold_font()
		var y := r.position.y + r.size.y * 0.5 + (font.get_ascent(font_size) - font.get_descent(font_size)) * 0.5
		font.draw_string_outline(ci, Vector2(r.position.x, y), text, HORIZONTAL_ALIGNMENT_CENTER, r.size.x, font_size, 3, Color(0, 0, 0, 0.8))
		font.draw_string(ci, Vector2(r.position.x, y), text, HORIZONTAL_ALIGNMENT_CENTER, r.size.x, font_size, Color.WHITE)


## Nhãn phím treo dưới ô (tấm khiên đồng nhọn đáy). top = giữa mép trên tấm.
static func key_tab(ci: RID, top: Vector2, key: String, s := 1.0, col := BR_LIGHT) -> void:
	if key == "":
		return
	var font := UiTheme.bold_font()
	var fsz := int(round(11.0 * s))
	var tw := maxf(16.0 * s, font.get_string_size(key, HORIZONTAL_ALIGNMENT_LEFT, -1, fsz).x + 10.0 * s)
	var h := 15.0 * s
	var hw := tw * 0.5
	_outlined(ci, PackedVector2Array([top + Vector2(-hw, 0), top + Vector2(hw, 0), top + Vector2(hw, h - 4 * s), top + Vector2(0, h + 3 * s),
		top + Vector2(-hw, h - 4 * s)]), Color("#2c2014"), BR_MID, 1.6)
	var y := top.y + h * 0.5 + (font.get_ascent(fsz) - font.get_descent(fsz)) * 0.5 + 0.5
	font.draw_string(ci, Vector2(top.x - hw, y), key, HORIZONTAL_ALIGNMENT_CENTER, tw, fsz, col)


## Chữ tiêu đề vàng kiểu cổ (viền nâu đậm). align theo HorizontalAlignment trong khung width.
static func title(ci: RID, pos: Vector2, text: String, size: int, width := -1.0, align := HORIZONTAL_ALIGNMENT_LEFT, col := GOLD_TEXT) -> void:
	var f := title_font()
	f.draw_string_outline(ci, pos, text, align, width, size, 4, Color("#1a0f05", 0.9))
	f.draw_string(ci, pos, text, align, width, size, col)


# ------------------------------------------------------------------ tiện ích


static func _poly(ci: RID, pts: Array, col: Color) -> void:
	RenderingServer.canvas_item_add_polygon(ci, PackedVector2Array(pts), PackedColorArray([col]))


static func _outlined(ci: RID, pts: PackedVector2Array, fill: Color, line: Color, width: float) -> void:
	RenderingServer.canvas_item_add_polygon(ci, pts, PackedColorArray([fill]))
	var closed := pts.duplicate()
	closed.append(pts[0])
	RenderingServer.canvas_item_add_polyline(ci, closed, PackedColorArray([line]), width, true)


static func _xf(pts: Array, at: Vector2, s: float, fx: float) -> PackedVector2Array:
	var out := PackedVector2Array()
	for p in pts:
		out.append(at + Vector2(p.x * fx, p.y) * s)
	return out
