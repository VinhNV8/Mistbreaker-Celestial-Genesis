extends RefCounted
## C1-42 (KT-07): cài đặt người chơi — lưu user://settings.cfg (tách khỏi save game).

const PATH := "user://settings.cfg"
## UI-40 (docs/35): hd_art — dùng hình HD (cel-shade) khi có, tắt thì về hình pixel.
## FX-1 (docs/36): skill_fx — "fx1" (mặc định: FX-1 cả 70 kỹ năng) / "auto" (FX-1, giữ hình đã duyệt) / "old" (hình cũ).
## skill_fx_rev: phiên bản mặc định; file cài đặt cũ (rev 0) đang "auto" = mặc định cũ → chuyển sang "fx1" một lần.
const DEFAULTS := {"master": 0.8, "music": 0.6, "sfx": 0.8, "fullscreen": false, "font_scale": 1.0, "hd_art": true,
	"skill_fx": "fx1", "skill_fx_rev": 1, "fx_shake": true, "fx_soft": false}
## FX-1 §9.8: fx_shake — rung màn hình + khựng đòn ngắn khi chiêu mạnh va chạm; fx_soft — giảm chớp sáng (không làm tối nền,
## lớp glow 55%) cho người nhạy cảm ánh sáng / máy yếu.
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
		migrate(int(cf.get_value("settings", "skill_fx_rev", 0)))
	apply()


## FX-1 (03/11/2026): chủ dự án chọn FX-1 làm mặc định cho cả 70 kỹ năng — cài đặt lưu trước đó với mặc định cũ "auto"
## được chuyển sang "fx1" một lần (người chơi vẫn chọn lại "auto" / "old" được).
static func migrate(rev: int) -> void:
	if rev < 1:
		if str(values.get("skill_fx", "")) == "auto":
			values["skill_fx"] = "fx1"
		values["skill_fx_rev"] = 1


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
