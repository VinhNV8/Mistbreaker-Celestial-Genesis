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

## DH-11: font chính thức đóng gói kèm game (Be Vietnam Pro, giấy phép OFL — assets/fonts/OFL.txt).
const FONT_MEDIUM := "res://assets/fonts/BeVietnamPro-Medium.ttf"
const FONT_BOLD := "res://assets/fonts/BeVietnamPro-ExtraBold.ttf"
const FrameBox = preload("res://scripts/ui/frame_box.gd")
## Màu khung gỗ / vàng (DH-11, cùng thanh kỹ năng).
static var WOOD := Color("#22180f")
static var WOOD_HUD := Color(0.11, 0.08, 0.05, 0.86)
static var GOLD_DARK := Color("#7a5a2a")

static var _font: Font
static var _bold: Font
static var _theme: Theme
## KT-07: hệ số cỡ chữ của theme (1.0 = mặc định). Đổi bằng set_font_scale() rồi gán lại theme cho cây UI.
static var font_scale := 1.0


## Font hệ thống có đủ dấu tiếng Việt (Segoe UI trên Windows); thiếu thì Godot tự dùng font dự phòng.
static func font() -> Font:
	if _font == null:
		_font = _file_font(FONT_MEDIUM, 500)
	return _font


static func bold_font() -> Font:
	if _bold == null:
		_bold = _file_font(FONT_BOLD, 800)
	return _bold


## Font trong assets/fonts; thiếu file thì dùng font hệ thống. Font hệ thống làm dự phòng cho ký tự lạ (biểu tượng ✦ ◆ …).
static func _file_font(path: String, weight: int) -> Font:
	if not ResourceLoader.exists(path):
		return _system_font(weight)
	var f = load(path)
	if not (f is FontFile):
		return _system_font(weight)
	var ff: FontFile = (f as FontFile).duplicate()
	ff.fallbacks = [_system_font(weight)]
	return ff


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
	t.default_font_size = fs(15)

	# DH-11: khung trang trí — bảng phủ (SolidPanel) khung lớn, khung HUD (PanelContainer) khung nhỏ.
	t.set_stylebox("panel", "PanelContainer", FrameBox.new().setup(WOOD_HUD, 12, "small"))
	t.set_type_variation("SolidPanel", "PanelContainer")
	t.set_stylebox("panel", "SolidPanel", FrameBox.new().setup(WOOD, 22, "large"))
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
		t.set_font_size("font_size", v[0], fs(v[2]))
	t.set_font("font", "Heading", bold_font())
	t.set_font("font", "Title", bold_font())
	t.set_type_variation("HudLabel", "Label")
	t.set_color("font_outline_color", "HudLabel", Color(0, 0, 0, 0.85))
	t.set_constant("outline_size", "HudLabel", 5)

	# DH-11: nút gỗ viền vàng; nút chính màu vàng có gờ dưới tối (nổi khối).
	_button_styles(t, "Button", Color("#2e2216"), Color("#3e2e1d"), TEXT, GOLD_DARK, ACCENT)
	t.set_type_variation("PrimaryButton", "Button")
	_button_styles(t, "PrimaryButton", Color("#c9a45c"), Color("#e0bf7c"), Color("#1b1408"), Color("#7a5a2a"), Color("#f3d27a"))
	t.set_stylebox("normal", "LineEdit", box(Color("#140e09"), 6, 1, GOLD_DARK, 8))
	t.set_stylebox("focus", "LineEdit", box(Color("#140e09"), 6, 2, ACCENT, 8))

	t.set_stylebox("background", "ProgressBar", box(Color(0, 0, 0, 0.55), 5, 0, LINE, 0))
	for bar in [["HpBar", Color("#e0484f")], ["ExpBar", Color("#4a9df8")], ["MpBar", Color("#7a6cf0")], ["BossBar", Color("#8a63e6")], ["PoiseBar", GOLD]]:
		t.set_type_variation(bar[0], "ProgressBar")
		t.set_stylebox("fill", bar[0], box(bar[1], 5, 0, LINE, 0))
	_theme = t
	return t


## Cỡ chữ đã nhân hệ số KT-07.
static func fs(size: int) -> int:
	return maxi(8, roundi(size * font_scale))


## KT-07: đổi hệ số cỡ chữ (0,8–1,5); trả về theme mới — nơi gọi gán lại `theme` cho Control gốc.
## Chỉ đổi cỡ chữ lấy từ theme; chỗ code tự đặt `add_theme_font_size_override` muốn theo thì dùng UiTheme.fs().
static func set_font_scale(k: float) -> Theme:
	font_scale = clampf(k, 0.8, 1.5)
	_theme = null
	return get_theme()


static func _button_styles(t: Theme, type_name: String, normal: Color, hover: Color, text: Color,
		border := Color(1, 1, 1, 0.18), hover_border := Color(1, 1, 1, 0.3)) -> void:
	t.set_stylebox("normal", type_name, _bevel(normal, border))
	t.set_stylebox("hover", type_name, _bevel(hover, hover_border))
	var pressed := box(hover.darkened(0.15), 6, 1, border, 10)
	pressed.content_margin_top = 11
	pressed.content_margin_bottom = 9
	t.set_stylebox("pressed", type_name, pressed)
	t.set_stylebox("disabled", type_name, box(Color(normal.darkened(0.3), 0.55), 6, 1, Color(border, 0.35), 10))
	t.set_stylebox("focus", type_name, StyleBoxEmpty.new())
	t.set_color("font_color", type_name, text)
	t.set_color("font_hover_color", type_name, text)
	t.set_color("font_pressed_color", type_name, text)
	t.set_color("font_focus_color", type_name, text)
	t.set_color("font_disabled_color", type_name, Color(text, 0.4))
	t.set_font("font", type_name, bold_font())


## Nút nổi khối: gờ dưới dày, tối hơn viền.
static func _bevel(bg: Color, border: Color) -> StyleBoxFlat:
	var sb := box(bg, 6, 1, border, 10)
	sb.border_width_bottom = 3
	sb.content_margin_bottom = 8
	return sb


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
