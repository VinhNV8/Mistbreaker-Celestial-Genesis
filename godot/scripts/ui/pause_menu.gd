extends ColorRect
## C1-42 (KT-07): menu tạm dừng (Esc) — Tiếp tục · Cài đặt · Về màn hình chính. Cài đặt: âm lượng, toàn màn hình, cỡ chữ (M5-05).

const UiTheme = preload("res://scripts/ui/ui_theme.gd")
const Settings = preload("res://scripts/core/settings.gd")

signal resume
signal quit_to_title
## M5-05: người chơi đổi cỡ chữ — main.gd dựng lại theme.
signal font_scale_changed(k: float)

var _box: VBoxContainer
var settings_only := false


func _ready() -> void:
	color = Color(0, 0, 0, 0.6)
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	add_child(center)
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", UiTheme.box(UiTheme.PANEL_SOLID, 14, 2, UiTheme.LINE, 22))
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


func show_menu() -> void:
	_clear()
	var h := UiTheme.label("Tạm dừng", "Heading")
	h.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_box.add_child(h)
	for pair in [["Tiếp tục (Esc)", func(): resume.emit(), "ResumeButton"], ["Cài đặt", show_settings, "SettingsButton"],
			["Về màn hình chính", func(): quit_to_title.emit(), "TitleButton"]]:
		var b := UiTheme.button(pair[0], pair[2] == "ResumeButton")
		b.name = pair[2]
		b.pressed.connect(pair[1])
		_box.add_child(b)


func show_settings() -> void:
	_clear()
	var h := UiTheme.label("Cài đặt", "Heading")
	h.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_box.add_child(h)
	for pair in [["master", "Âm lượng tổng"], ["music", "Nhạc nền"], ["sfx", "Hiệu ứng âm thanh"]]:
		var row := UiTheme.hbox(10)
		var l := UiTheme.label(pair[1])
		l.custom_minimum_size.x = 150
		row.add_child(l)
		var s := HSlider.new()
		s.name = "Slider_" + pair[0]
		s.min_value = 0.0
		s.max_value = 1.0
		s.step = 0.05
		s.value = float(Settings.values[pair[0]])
		s.custom_minimum_size.x = 180
		s.size_flags_vertical = SIZE_SHRINK_CENTER
		var pct := UiTheme.label("%d%%" % roundi(s.value * 100.0), "Small")
		pct.custom_minimum_size.x = 40
		var key: String = pair[0]
		s.value_changed.connect(func(v):
			pct.text = "%d%%" % roundi(v * 100.0)
			Settings.set_value(key, v))
		row.add_child(s)
		row.add_child(pct)
		_box.add_child(row)
	var fs := CheckBox.new()
	fs.text = "Toàn màn hình"
	fs.button_pressed = bool(Settings.values.fullscreen)
	fs.toggled.connect(func(on): Settings.set_value("fullscreen", on))
	_box.add_child(fs)
	var frow := UiTheme.hbox(6)
	var fl := UiTheme.label("Cỡ chữ")
	fl.custom_minimum_size.x = 150
	frow.add_child(fl)
	var cur := float(Settings.values.get("font_scale", 1.0))
	for opt in Settings.FONT_SCALES:
		var b := UiTheme.button(str(opt[1]), is_equal_approx(float(opt[0]), cur))
		b.name = "Font_%d" % roundi(float(opt[0]) * 100.0)
		var k: float = opt[0]
		b.pressed.connect(func():
			Settings.set_value("font_scale", k)
			font_scale_changed.emit(k)
			show_settings())
		frow.add_child(b)
	_box.add_child(frow)
	_box.add_child(UiTheme.label("Đổi phím: Project Settings → Input Map (xem tài liệu 02 mục 4).", "Small", 380))
	var back := UiTheme.button("Xong", true)
	back.pressed.connect(func():
		if settings_only:
			resume.emit()
		else:
			show_menu())
	_box.add_child(back)
