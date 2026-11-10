extends RefCounted
## C1-42 (KT-07): cài đặt người chơi — lưu user://settings.cfg (tách khỏi save game).

const PATH := "user://settings.cfg"
## UI-40 (docs/35): hd_art — dùng hình HD (cel-shade) khi có, tắt thì về hình pixel.
## FX-1 (docs/36): skill_fx — "fx1" (mặc định: FX-1 cả 70 kỹ năng) / "auto" (FX-1, giữ hình đã duyệt) / "old" (hình cũ).
## skill_fx_rev: phiên bản mặc định; file cài đặt cũ (rev 0) đang "auto" = mặc định cũ → chuyển sang "fx1" một lần.
const DEFAULTS := {"master": 0.8, "music": 0.6, "sfx": 0.8, "fullscreen": false, "font_scale": 1.0, "hd_art": true,
	"skill_fx": "fx1", "skill_fx_rev": 1, "fx_shake": true, "fx_soft": false, "tele_style": "natural",
	"nameplates": "smart", "low_hp_warn": true, "colorblind": false, "keybinds": {},
	"view_range": "mid", "ui_scale": 0.0, "quest_compact": false, "depth_fx": true,
	"tilt": "low", "hud_minimap": true, "hud_quest": true, "ambient": 0.7,
	"combo_style": "big"}
## VS-1 (docs/44): view_range — Tầm nhìn "near" / "mid" / "far"; ui_scale — cỡ giao diện (0 = tự động theo độ phân giải);
## quest_compact — khung nhiệm vụ HUD thu gọn (chuột phải vào khung); depth_fx — bóng đổ + ánh sáng nền (chiều sâu bản đồ).
## MU-1 (docs/46): ambient — âm lượng âm thanh môi trường (bus "Ambient").
## CR-05: hud_minimap / hud_quest — hiện bản đồ nhỏ / khung nhiệm vụ trên HUD (nút ẩn / hiện cạnh bản đồ nhỏ).
## GN-3 (docs/45 Q223): combo_style — bộ đếm combo "big" (mặc định) / "small" (dòng chữ UI-54) / "off".
const COMBO_STYLES := [["big", "Lớn"], ["small", "Nhỏ"], ["off", "Tắt"]]
## GN-1 (docs/45): tilt — nghiêng phối cảnh "off" / "low" (mặc định) / "mid".
## UI-53 / 55 / 61 / 63 (docs/38): nameplates — "smart" / "always" / "off" (bảng tên quái); low_hp_warn — viền đỏ máu thấp;
## colorblind — bảng màu cho người mù màu đỏ–lục; keybinds — {action: [mã phím vật lý…]} phím người chơi đổi.
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
	AudioServer.set_bus_volume_db(_bus("Ambient"), linear_to_db(maxf(0.0001, float(values.get("ambient", 0.7)))))
	if DisplayServer.get_name() != "headless":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if values.fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
