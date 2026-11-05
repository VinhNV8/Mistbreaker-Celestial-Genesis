extends ColorRect
## C1-42 (KT-07): menu tạm dừng (Esc) — Tiếp tục · Cài đặt · Trợ giúp (UI-17) · Về màn hình chính.
## UI-61 (docs/38): khung đồng (SolidPanel) như các bảng khác; Cài đặt chia 4 tab — Âm thanh · Hiển thị (toàn màn hình,
## HD, hiệu ứng kỹ năng, cỡ chữ) · Điều khiển (đổi phím trong game, ui/../core/keybinds.gd) · Trợ năng (bảng tên quái,
## cảnh báo máu thấp, bảng màu mù màu, rung, giảm chớp).

const UiTheme = preload("res://scripts/ui/ui_theme.gd")
const Settings = preload("res://scripts/core/settings.gd")
const Keybinds = preload("res://scripts/core/keybinds.gd")
const Bronze = preload("res://scripts/ui/bronze.gd")

signal resume
signal quit_to_title
## UI-17: mở bảng Trợ giúp.
signal help
## M5-05: người chơi đổi cỡ chữ — main.gd dựng lại theme.
signal font_scale_changed(k: float)

const TABS := [["audio", "Âm thanh"], ["display", "Hiển thị"], ["controls", "Điều khiển"], ["access", "Trợ năng"]]
const NAMEPLATE_MODES := [["smart", "Thông minh"], ["always", "Luôn hiện"], ["off", "Chỉ quái mạnh"]]

var _box: VBoxContainer
var settings_only := false
var tab := "audio"
## Đổi phím: action đang chờ bấm phím mới ("" = không chờ).
var _waiting := ""
var _note := ""


func _ready() -> void:
	color = Color(0, 0, 0, 0.6)
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	add_child(center)
	var panel := PanelContainer.new()
	panel.theme_type_variation = "SolidPanel"
	center.add_child(panel)
	_box = UiTheme.vbox(12)
	_box.custom_minimum_size.x = 380
	panel.add_child(_box)
	if settings_only:
		show_settings()
	else:
		show_menu()


func _clear() -> void:
	for c in _box.get_children():
		_box.remove_child(c)
		c.queue_free()


func _heading(text: String) -> void:
	var h := Label.new()
	h.text = text
	h.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	h.add_theme_font_override("font", Bronze.title_font())
	h.add_theme_font_size_override("font_size", UiTheme.fs(30))
	h.add_theme_color_override("font_color", Bronze.GOLD_TEXT)
	h.add_theme_color_override("font_outline_color", Color("#1a0f05"))
	h.add_theme_constant_override("outline_size", 6)
	_box.add_child(h)


func show_menu() -> void:
	_clear()
	_box.custom_minimum_size.x = 380
	_heading("Tạm dừng")
	for pair in [["Tiếp tục (Esc)", func(): resume.emit(), "ResumeButton"], ["Cài đặt", show_settings, "SettingsButton"], ["Trợ giúp (F1)", func(): help.emit(), "HelpButton"],
			["Về màn hình chính", func(): quit_to_title.emit(), "TitleButton"]]:
		var b := UiTheme.button(pair[0], pair[2] == "ResumeButton")
		b.name = pair[2]
		b.custom_minimum_size.y = 40
		b.pressed.connect(pair[1])
		_box.add_child(b)


func show_settings() -> void:
	_clear()
	_box.custom_minimum_size.x = 560
	_heading("Cài đặt")
	var tabs := UiTheme.hbox(6)
	tabs.alignment = BoxContainer.ALIGNMENT_CENTER
	for t in TABS:
		var b := UiTheme.button(str(t[1]), tab == t[0])
		b.name = "Tab_" + str(t[0])
		b.custom_minimum_size.x = 120
		var id: String = t[0]
		b.pressed.connect(func():
			tab = id
			_waiting = ""
			_note = ""
			show_settings())
		tabs.add_child(b)
	_box.add_child(tabs)
	_box.add_child(HSeparator.new())
	match tab:
		"display":
			_tab_display()
		"controls":
			_tab_controls()
		"access":
			_tab_access()
		_:
			_tab_audio()
	var back := UiTheme.button("Xong", true)
	back.name = "DoneButton"
	back.pressed.connect(func():
		if settings_only:
			resume.emit()
		else:
			show_menu())
	_box.add_child(back)


func _row(title: String) -> HBoxContainer:
	var row := UiTheme.hbox(8)
	var l := UiTheme.label(title)
	l.custom_minimum_size.x = 170
	row.add_child(l)
	_box.add_child(row)
	return row


func _check(name: String, text: String, key: String, default: bool, on_change := Callable()) -> void:
	var c := CheckBox.new()
	c.name = name
	c.text = text
	c.button_pressed = bool(Settings.values.get(key, default))
	c.toggled.connect(func(on):
		Settings.set_value(key, on)
		if on_change.is_valid():
			on_change.call(on))
	_box.add_child(c)


func _choices(title: String, key: String, options: Array, prefix: String, cur, on_pick := Callable()) -> void:
	var row := _row(title)
	for opt in options:
		var b := UiTheme.button(str(opt[1]), str(opt[0]) == str(cur) if not (cur is float) else is_equal_approx(float(opt[0]), float(cur)))
		b.name = prefix + (str(opt[0]) if not (opt[0] is float) else str(roundi(float(opt[0]) * 100.0)))
		var v = opt[0]
		b.pressed.connect(func():
			Settings.set_value(key, v)
			if on_pick.is_valid():
				on_pick.call(v)
			show_settings())
		row.add_child(b)


func _tab_audio() -> void:
	for pair in [["master", "Âm lượng tổng"], ["music", "Nhạc nền"], ["sfx", "Hiệu ứng âm thanh"]]:
		var row := _row(pair[1])
		var s := HSlider.new()
		s.name = "Slider_" + pair[0]
		s.min_value = 0.0
		s.max_value = 1.0
		s.step = 0.05
		s.value = float(Settings.values[pair[0]])
		s.custom_minimum_size.x = 260
		s.size_flags_vertical = SIZE_SHRINK_CENTER
		var pct := UiTheme.label("%d%%" % roundi(s.value * 100.0))
		pct.custom_minimum_size.x = 48
		var key: String = pair[0]
		s.value_changed.connect(func(v):
			pct.text = "%d%%" % roundi(v * 100.0)
			Settings.set_value(key, v))
		row.add_child(s)
		row.add_child(pct)


func _tab_display() -> void:
	_check("Fullscreen", "Toàn màn hình", "fullscreen", false)
	# UI-40 (docs/35): hình HD cel-shade / hình pixel cũ.
	_check("HdArt", "Đồ hoạ HD (cảnh, quái, icon)", "hd_art", true, func(on):
		load("res://scripts/view/sprite_lib.gd").set_hd(on))
	# FX-1 (docs/36, Q181): hiệu ứng kỹ năng — FX-1 chạy song song với hình đã duyệt.
	_choices("Hiệu ứng kỹ năng", "skill_fx", preload("res://scripts/view/fx1.gd").MODES, "SkillFx_", str(Settings.values.get("skill_fx", "fx1")))
	_choices("Cỡ chữ", "font_scale", Settings.FONT_SCALES, "Font_", float(Settings.values.get("font_scale", 1.0)),
		func(k): font_scale_changed.emit(float(k)))


func _tab_access() -> void:
	_choices("Tên quái", "nameplates", NAMEPLATE_MODES, "Nameplates_", str(Settings.values.get("nameplates", "smart")))
	_box.add_child(UiTheme.label("Thông minh: quái thường chỉ hiện tên khi là mục tiêu hoặc đã mất máu.", "Small", 540))
	_check("LowHpWarn", "Cảnh báo máu thấp (viền màn hình đỏ dưới 30% máu)", "low_hp_warn", true)
	_check("Colorblind", "Bảng màu cho người mù màu đỏ – lục (tốt / xấu: lam – cam)", "colorblind", false, func(on):
		UiTheme.set_colorblind(on))
	# FX-1 §9.8: rung màn hình + khựng đòn; giảm chớp sáng (nhạy cảm ánh sáng / máy yếu).
	_check("FxShake", "Rung màn hình khi chiêu mạnh va chạm", "fx_shake", true)
	_check("FxSoft", "Giảm chớp sáng hiệu ứng (nhạy cảm ánh sáng)", "fx_soft", false)
	# FX-1 §9.12: cảnh báo đòn quái — tự nhiên (vết nứt / bóng đổ / sương giá, quái thường chỉ báo bằng động tác) hoặc rõ ràng.
	_choices("Cảnh báo đòn quái", "tele_style", preload("res://scripts/view/fx1.gd").TELE_STYLES, "Tele_", str(Settings.values.get("tele_style", "natural")))
	_box.add_child(UiTheme.label("Tự nhiên: quái thường chỉ báo bằng động tác, tinh anh / boss vẽ vết trên mặt đất. Rõ ràng: vòng / dải / nón cho mọi đòn.", "Small", 540))


func _tab_controls() -> void:
	var sc := ScrollContainer.new()
	sc.custom_minimum_size = Vector2(540, 330)
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var grid := GridContainer.new()
	grid.columns = 4
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 4)
	for a in Keybinds.REBINDABLE:
		var l := UiTheme.label(str(a[1]))
		l.custom_minimum_size.x = 150
		grid.add_child(l)
		var action: String = a[0]
		var b := UiTheme.button("Bấm phím…" if _waiting == action else Keybinds.key_name(action), _waiting == action)
		b.name = "Key_" + action
		b.custom_minimum_size.x = 104
		b.pressed.connect(func():
			_waiting = action
			_note = "Bấm phím mới cho \"%s\" (Esc để huỷ)." % a[1]
			show_settings())
		grid.add_child(b)
	sc.add_child(grid)
	_box.add_child(sc)
	_box.add_child(UiTheme.label(_note if _note != "" else "Bấm ô phím rồi bấm phím mới. Chuột trái đánh, chuột phải dùng kỹ năng 1.", "Small", 540))
	var reset := UiTheme.button("Khôi phục phím mặc định")
	reset.name = "KeysReset"
	reset.pressed.connect(func():
		Keybinds.reset()
		_waiting = ""
		_note = "Đã khôi phục phím mặc định."
		show_settings())
	_box.add_child(reset)


func _input(event: InputEvent) -> void:
	if _waiting == "" or not (event is InputEventKey) or not event.pressed or event.echo:
		return
	get_viewport().set_input_as_handled()
	var code: int = event.physical_keycode
	var action := _waiting
	_waiting = ""
	if code == KEY_ESCAPE:
		_note = "Đã huỷ đổi phím."
	else:
		var taken := Keybinds.set_key(action, code)
		_note = "Đã gán %s." % OS.get_keycode_string(code)
		if taken != "":
			for a in Keybinds.REBINDABLE:
				if a[0] == taken:
					_note += " \"%s\" mất phím này — hãy gán phím khác." % a[1]
	show_settings()
