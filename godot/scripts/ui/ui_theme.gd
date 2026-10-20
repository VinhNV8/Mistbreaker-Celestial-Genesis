extends RefCounted
## Theme chung + vài hàm dựng Control nhanh. Đổi màu/font toàn game ở đây.

static var TEXT := Color("#ece6d8")
static var MUTED := Color("#9aa3b2")
static var GOLD := Color("#ffc940")
static var GOOD := Color("#5bd16a")
static var BAD := Color("#ff5470")
static var ACCENT := Color("#c9a45c")
static var BG := Color("#0e1218")
static var PANEL := Color(0.063, 0.078, 0.11, 0.88)
static var PANEL_SOLID := Color("#161b25")
static var LINE := Color(1, 1, 1, 0.1)

static var _font: Font
static var _bold: Font
static var _theme: Theme


## Font hệ thống có đủ dấu tiếng Việt (Segoe UI trên Windows); thiếu thì Godot tự dùng font dự phòng.
static func font() -> Font:
	if _font == null:
		_font = _system_font(500)
	return _font


static func bold_font() -> Font:
	if _bold == null:
		_bold = _system_font(800)
	return _bold


static func _system_font(weight: int) -> SystemFont:
	var f := SystemFont.new()
	f.font_names = PackedStringArray(["Be Vietnam Pro", "Segoe UI", "Noto Sans", "Helvetica Neue", "Arial"])
	f.font_weight = weight
	return f


static func box(bg: Color, radius := 10, border := 1, border_color := LINE, margin := 12) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.set_corner_radius_all(radius)
	sb.set_border_width_all(border)
	sb.border_color = border_color
	sb.set_content_margin_all(margin)
	return sb


static func get_theme() -> Theme:
	if _theme != null:
		return _theme
	var t := Theme.new()
	t.default_font = font()
	t.default_font_size = 15

	t.set_stylebox("panel", "PanelContainer", box(PANEL))
	t.set_type_variation("SolidPanel", "PanelContainer")
	t.set_stylebox("panel", "SolidPanel", box(PANEL_SOLID, 14, 1, LINE, 20))
	for tone in [["LogInfo", MUTED], ["LogGood", GOOD], ["LogBad", BAD]]:
		var sb := box(PANEL, 8, 0, LINE, 8)
		sb.border_width_left = 3
		sb.border_color = tone[1]
		t.set_type_variation(tone[0], "PanelContainer")
		t.set_stylebox("panel", tone[0], sb)

	t.set_color("font_color", "Label", TEXT)
	for v in [["Muted", MUTED, 14], ["Small", MUTED, 12], ["Eyebrow", ACCENT, 13], ["Heading", TEXT, 22], ["Title", ACCENT, 60]]:
		t.set_type_variation(v[0], "Label")
		t.set_color("font_color", v[0], v[1])
		t.set_font_size("font_size", v[0], v[2])
	t.set_font("font", "Heading", bold_font())
	t.set_font("font", "Title", bold_font())
	t.set_type_variation("HudLabel", "Label")
	t.set_color("font_outline_color", "HudLabel", Color(0, 0, 0, 0.85))
	t.set_constant("outline_size", "HudLabel", 5)

	_button_styles(t, "Button", Color(1, 1, 1, 0.06), Color(1, 1, 1, 0.13), TEXT)
	t.set_type_variation("PrimaryButton", "Button")
	_button_styles(t, "PrimaryButton", Color("#c9a45c"), Color("#dfbd78"), Color("#1b1408"))

	t.set_stylebox("background", "ProgressBar", box(Color(0, 0, 0, 0.55), 5, 0, LINE, 0))
	for bar in [["HpBar", Color("#e0484f")], ["ExpBar", Color("#4a9df8")], ["MpBar", Color("#7a6cf0")], ["BossBar", Color("#8a63e6")], ["PoiseBar", GOLD]]:
		t.set_type_variation(bar[0], "ProgressBar")
		t.set_stylebox("fill", bar[0], box(bar[1], 5, 0, LINE, 0))
	_theme = t
	return t


static func _button_styles(t: Theme, type_name: String, normal: Color, hover: Color, text: Color) -> void:
	var border := Color(1, 1, 1, 0.18)
	t.set_stylebox("normal", type_name, box(normal, 8, 1, border, 10))
	t.set_stylebox("hover", type_name, box(hover, 8, 1, Color(1, 1, 1, 0.3), 10))
	t.set_stylebox("pressed", type_name, box(hover.darkened(0.15), 8, 1, border, 10))
	t.set_stylebox("disabled", type_name, box(Color(normal, normal.a * 0.4), 8, 1, Color(border, 0.08), 10))
	t.set_stylebox("focus", type_name, StyleBoxEmpty.new())
	t.set_color("font_color", type_name, text)
	t.set_color("font_hover_color", type_name, text)
	t.set_color("font_pressed_color", type_name, text)
	t.set_color("font_focus_color", type_name, text)
	t.set_color("font_disabled_color", type_name, Color(text, 0.4))
	t.set_font("font", type_name, bold_font())


# ------------------------------------------------------------------ dựng nhanh


static func label(text: String, variation := "", wrap_width := 0.0) -> Label:
	var l := Label.new()
	l.text = text
	l.theme_type_variation = variation
	if wrap_width > 0.0:
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.custom_minimum_size.x = wrap_width
	return l


static func button(text: String, primary := false) -> Button:
	var b := Button.new()
	b.text = text
	b.focus_mode = Control.FOCUS_NONE
	if primary:
		b.theme_type_variation = "PrimaryButton"
	return b


static func vbox(separation := 8) -> VBoxContainer:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", separation)
	return v


static func hbox(separation := 8) -> HBoxContainer:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", separation)
	return h


static func spacer() -> Control:
	var c := Control.new()
	c.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return c


## Khung viền màu theo hạng Thiên phú.
static func rank_box(color: Color) -> StyleBoxFlat:
	return box(Color(color, 0.1), 10, 2, color, 12)
