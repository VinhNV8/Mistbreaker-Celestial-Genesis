extends RefCounted
## C1-42 (KT-07): cài đặt người chơi — lưu user://settings.cfg (tách khỏi save game).

const PATH := "user://settings.cfg"
const DEFAULTS := {"master": 0.8, "music": 0.6, "sfx": 0.8, "fullscreen": false, "font_scale": 1.0}
## M5-05 (KT-07): các mức cỡ chữ trong Cài đặt. Theme dựng lại ở main.gd (UiTheme.set_font_scale).
const FONT_SCALES := [[0.9, "Nhỏ"], [1.0, "Vừa"], [1.15, "Lớn"], [1.3, "Rất lớn"]]

static var values := DEFAULTS.duplicate()
static var _loaded := false


static func load_settings() -> void:
	if _loaded:
		return
	_loaded = true
	var cf := ConfigFile.new()
	if cf.load(PATH) == OK:
		for k in DEFAULTS:
			values[k] = cf.get_value("settings", k, DEFAULTS[k])
	apply()


static func save_settings() -> void:
	var cf := ConfigFile.new()
	for k in values:
		cf.set_value("settings", k, values[k])
	cf.save(PATH)


static func set_value(key: String, v) -> void:
	values[key] = v
	apply()
	save_settings()


static func _bus(name: String) -> int:
	var i := AudioServer.get_bus_index(name)
	if i < 0:
		AudioServer.add_bus()
		i = AudioServer.bus_count - 1
		AudioServer.set_bus_name(i, name)
		AudioServer.set_bus_send(i, "Master")
	return i


static func apply() -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(maxf(0.0001, float(values.master))))
	AudioServer.set_bus_volume_db(_bus("Music"), linear_to_db(maxf(0.0001, float(values.music))))
	AudioServer.set_bus_volume_db(_bus("SFX"), linear_to_db(maxf(0.0001, float(values.sfx))))
	if DisplayServer.get_name() != "headless":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if values.fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
