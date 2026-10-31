extends RefCounted
## UI-24, UI-25 (Spec_Notes đợt 8): thành phần chung của Cửa hàng và Lò Rèn — biển tiêu đề, ô tiền tệ,
## tab dọc, thẻ hàng, ô chi phí "cần / có", ô chọn số lượng. Cùng phong cách gỗ-vàng của Túi đồ (UI-21).

const UiTheme = preload("res://scripts/ui/ui_theme.gd")
const SpriteLib = preload("res://scripts/view/sprite_lib.gd")

const INSET_BG := Color("#1a120b")
const INSET_LINE := Color("#5a4220")
const PLATE_TEXT := Color("#f3d27a")
const SHORT := Color("#ff7a6a")


## Biển tiêu đề gỗ (icon + tên + dòng phụ), các ô tiền tệ, nút X đóng.
static func title_bar(icon: Texture2D, title: String, subtitle: String, chips: Array, close_cb: Callable, close_hint: String) -> HBoxContainer:
	var top := UiTheme.hbox(10)
	var plate := UiTheme.panel(UiTheme.box(Color("#1a120b"), 8, 2, UiTheme.GOLD_DARK, 8))
	var ph := UiTheme.hbox(10)
	ph.add_child(UiTheme.icon_rect(icon, 40))
	var tv := UiTheme.vbox(0)
	tv.add_child(UiTheme.strong(title, 24, PLATE_TEXT))
	if subtitle != "":
		var s := UiTheme.label(subtitle, "Small")
		s.add_theme_color_override("font_color", Color("#c9b89a"))
		tv.add_child(s)
	ph.add_child(tv)
	plate.add_child(ph)
	top.add_child(plate)
	top.add_child(UiTheme.spacer())
	for c in chips:
		c.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		top.add_child(c)
	top.add_child(close_button(close_cb, close_hint))
	return top


static func close_button(cb: Callable, hint: String) -> Button:
	var x := UiTheme.button("X")
	x.name = "CloseButton"
	x.tooltip_text = hint
	x.custom_minimum_size = Vector2(46, 46)
	x.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	x.add_theme_font_size_override("font_size", UiTheme.fs(22))
	x.add_theme_stylebox_override("normal", UiTheme.box(Color("#5a1a14"), 6, 2, Color("#c9a45c"), 6))
	x.add_theme_stylebox_override("hover", UiTheme.box(Color("#7a261c"), 6, 2, Color("#f3d27a"), 6))
	x.add_theme_stylebox_override("pressed", UiTheme.box(Color("#3e120e"), 6, 2, Color("#c9a45c"), 6))
	x.add_theme_color_override("font_color", Color("#f3d27a"))
	x.add_theme_color_override("font_hover_color", Color.WHITE)
	x.pressed.connect(cb)
	return x


## Ô tiền tệ trên thanh tiêu đề: icon + số (nhóm hàng nghìn).
static func currency(icon_id: String, amount: int, tip: String) -> PanelContainer:
	var pw := UiTheme.panel(UiTheme.box(Color("#120c07"), 8, 1, UiTheme.GOLD_DARK, 8))
	pw.tooltip_text = tip
	var h := UiTheme.hbox(6)
	h.add_child(UiTheme.icon_rect(SpriteLib.icon(icon_id), 24))
	var l := UiTheme.strong(group(amount), 17, Color("#ffd877") if icon_id == "res-gold" else UiTheme.TEXT)
	l.custom_minimum_size.x = 34
	h.add_child(l)
	pw.add_child(h)
	return pw


## Ô chi phí: icon + "cần" lớn + "có N" nhỏ; thiếu thì viền và số đỏ. Dùng cho cường hoá, chế đồ, đổi nguyên liệu.
static func cost_chip(icon_id: String, need: int, have: int, what: String) -> PanelContainer:
	var ok := have >= need
	var chip := UiTheme.panel(UiTheme.box(Color("#120c07"), 6, 1, UiTheme.GOLD_DARK if ok else Color(SHORT, 0.8), 6))
	chip.name = "Cost_" + icon_id
	chip.tooltip_text = "%s: cần %s, đang có %s%s" % [what, group(need), group(have), "" if ok else " — thiếu %s" % group(need - have)]
	var h := UiTheme.hbox(6)
	h.add_child(UiTheme.icon_rect(SpriteLib.icon(icon_id), 26))
	var v := UiTheme.vbox(-2)
	v.add_child(UiTheme.strong(group(need), 16, UiTheme.TEXT if ok else SHORT))
	var hl := UiTheme.label("có %s" % group(have), "Small")
	hl.add_theme_font_size_override("font_size", UiTheme.fs(11))
	hl.add_theme_color_override("font_color", UiTheme.MUTED if ok else SHORT)
	v.add_child(hl)
	h.add_child(v)
	chip.add_child(h)
	return chip


## Hàng các ô chi phí. costs: [[icon_id, cần, có, tên], ...]; bỏ qua mục cần = 0.
static func cost_row(costs: Array) -> HBoxContainer:
	var row := UiTheme.hbox(6)
	row.name = "CostRow"
	for c in costs:
		if int(c[1]) > 0:
			row.add_child(cost_chip(str(c[0]), int(c[1]), int(c[2]), str(c[3])))
	return row


## Tab dọc bên trái (icon + tên + huy hiệu nhỏ tuỳ chọn).
static func side_tab(id: String, text: String, icon: Texture2D, on: bool, cb: Callable, badge := "") -> Button:
	var b := UiTheme.button(text)
	b.name = "Tab_" + id
	b.icon = icon
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.add_theme_constant_override("icon_max_width", 28)
	b.add_theme_constant_override("h_separation", 10)
	b.custom_minimum_size = Vector2(160, 50)
	var bg := Color("#3a2812") if on else Color("#140e08")
	var line := UiTheme.GOLD if on else Color("#4a3620")
	var normal := UiTheme.box(bg, 8, 2 if on else 1, line, 10)
	b.add_theme_stylebox_override("normal", normal)
	b.add_theme_stylebox_override("pressed", normal)
	b.add_theme_stylebox_override("hover", UiTheme.box(Color("#2a1d0e"), 8, 2, Color("#c9a45c"), 10))
	b.add_theme_color_override("font_color", PLATE_TEXT if on else Color("#c9b89a"))
	b.add_theme_color_override("font_hover_color", Color.WHITE)
	if badge != "":
		var bl := UiTheme.strong(badge, 11, Color("#1a120b"))
		var bp := UiTheme.panel(UiTheme.box(UiTheme.GOLD, 8, 0, UiTheme.GOLD, 3))
		bp.add_child(bl)
		bp.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bp.set_anchors_and_offsets_preset(Control.PRESET_CENTER_RIGHT)
		bp.position.x -= 34
		b.add_child(bp)
	b.pressed.connect(cb)
	return b


## Thẻ hàng: khung icon theo màu (phẩm chất), tên, giá kèm đồng vàng (đỏ khi không đủ tiền), huy hiệu góc ("có N").
static func item_card(id: String, icon: Texture2D, frame: Color, title: String, price_icon: String, price: int, affordable: bool,
		selected: bool, cb: Callable, badge := "") -> Button:
	var b := Button.new()
	b.name = "Card_" + id
	b.focus_mode = Control.FOCUS_NONE
	b.custom_minimum_size = Vector2(148, 150)
	var normal := UiTheme.box(Color(frame.darkened(0.7), 0.85) if selected else Color("#140e08"), 8, 2 if selected else 1,
		frame.lightened(0.25) if selected else Color(frame, 0.55), 8)
	b.add_theme_stylebox_override("normal", normal)
	b.add_theme_stylebox_override("pressed", normal)
	b.add_theme_stylebox_override("hover", UiTheme.box(Color(frame.darkened(0.6), 0.8), 8, 2, frame.lightened(0.2), 8))
	b.tooltip_text = title
	var v := UiTheme.vbox(4)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	v.offset_left = 8
	v.offset_right = -8
	v.offset_top = 8
	v.offset_bottom = -8
	var ic_box := UiTheme.panel(UiTheme.box(Color("#0b0805"), 6, 1, Color(frame, 0.7), 4))
	ic_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ic_box.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var ic := UiTheme.icon_rect(icon, 56)
	ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ic_box.add_child(ic)
	v.add_child(ic_box)
	var nl := UiTheme.label(title)
	nl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	nl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	nl.max_lines_visible = 2
	nl.add_theme_font_size_override("font_size", UiTheme.fs(13))
	nl.add_theme_color_override("font_color", frame.lightened(0.35) if frame != UiTheme.GOLD_DARK else UiTheme.TEXT)
	nl.size_flags_vertical = Control.SIZE_EXPAND_FILL
	nl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(nl)
	var pr := UiTheme.hbox(4)
	pr.alignment = BoxContainer.ALIGNMENT_CENTER
	pr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var pi := UiTheme.icon_rect(SpriteLib.icon(price_icon), 18)
	pi.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pr.add_child(pi)
	var pl := UiTheme.strong(group(price), 15, Color("#ffd877") if affordable else SHORT)
	pl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pr.add_child(pl)
	v.add_child(pr)
	b.add_child(v)
	if badge != "":
		var bp := UiTheme.panel(UiTheme.box(Color("#0b0805"), 5, 1, Color("#5a4220"), 3))
		bp.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var bl := UiTheme.label(badge, "Small")
		bl.add_theme_font_size_override("font_size", UiTheme.fs(11))
		bp.add_child(bl)
		bp.position = Vector2(6, 6)
		b.add_child(bp)
	b.pressed.connect(cb)
	return b


## Ô chọn số lượng: [−] N [+] [Tối đa]. on_change(n) nhận số mới (đã kẹp 1..max_n).
static func qty_box(n: int, max_n: int, on_change: Callable) -> HBoxContainer:
	var h := UiTheme.hbox(6)
	h.name = "QtyBox"
	var minus := UiTheme.button("−")
	minus.name = "QtyMinus"
	minus.custom_minimum_size = Vector2(36, 36)
	minus.disabled = n <= 1
	minus.pressed.connect(func(): on_change.call(clampi(n - 1, 1, maxi(1, max_n))))
	h.add_child(minus)
	var box := UiTheme.panel(UiTheme.box(Color("#0b0805"), 6, 1, UiTheme.GOLD_DARK, 6))
	var l := UiTheme.strong(str(n), 17)
	l.name = "QtyLabel"
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.custom_minimum_size.x = 44
	box.add_child(l)
	h.add_child(box)
	var plus := UiTheme.button("+")
	plus.name = "QtyPlus"
	plus.custom_minimum_size = Vector2(36, 36)
	plus.disabled = n >= max_n
	plus.pressed.connect(func(): on_change.call(clampi(n + 1, 1, maxi(1, max_n))))
	h.add_child(plus)
	var mx := UiTheme.button("Tối đa")
	mx.name = "QtyMax"
	mx.disabled = n >= max_n
	mx.pressed.connect(func(): on_change.call(maxi(1, max_n)))
	h.add_child(mx)
	return h


## Khung lõm có tiêu đề nhỏ (Eyebrow) ở trên.
static func section(title: String, min_w := 0.0) -> Array:
	var outer := UiTheme.panel(UiTheme.inset(INSET_BG, INSET_LINE, 12, 10))
	var col := UiTheme.vbox(8)
	if min_w > 0.0:
		col.custom_minimum_size.x = min_w
	outer.add_child(col)
	if title != "":
		col.add_child(UiTheme.label(title, "Eyebrow"))
	return [outer, col]


## 12345 → "12.345".
static func group(n: int) -> String:
	var s := str(absi(n))
	var out := ""
	while s.length() > 3:
		out = "." + s.substr(s.length() - 3) + out
		s = s.substr(0, s.length() - 3)
	return ("-" if n < 0 else "") + s + out
