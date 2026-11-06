extends RefCounted
## UI-61 (docs/38): đổi phím trong game (Cài đặt → Điều khiển). Phím người chơi chọn lưu ở Settings.values.keybinds
## = {action: [physical_keycode]}; áp lên InputMap khi khởi động (main._setup_input → apply) và mỗi lần đổi.
## Phím chuột (đánh = chuột trái, kỹ năng 1 = chuột phải) giữ nguyên. Một phím chỉ thuộc một thao tác: gán phím
## đang dùng ở thao tác khác thì thao tác kia mất phím đó (về phím mặc định còn lại, nếu có).

const Settings = preload("res://scripts/core/settings.gd")

## Thao tác cho đổi phím: [action, tên hiển thị]. Esc (đóng bảng / tạm dừng) cố định.
const REBINDABLE := [
	["move_up", "Đi lên"], ["move_down", "Đi xuống"], ["move_left", "Sang trái"], ["move_right", "Sang phải"],
	["attack", "Đánh thường"], ["skill_1", "Kỹ năng 1"], ["skill_2", "Kỹ năng 2"], ["skill_3", "Kỹ năng 3"],
	["skill_4", "Kỹ năng 4"], ["skill_5", "Kỹ năng 5"], ["skill_6", "Kỹ năng 6"], ["skill_7", "Tuyệt kỹ"],
	["swap_loadout", "Đổi Bộ kỹ năng"], ["talent", "Kỹ năng Thiên phú"], ["dodge", "Né lăn"], ["potion", "Bình máu"],
	["mp_potion", "Bình MP"], ["auto_fight", "Tự đánh"], ["interact", "Nói chuyện / tương tác"],
	["toggle_stats", "Nhân vật"], ["toggle_inventory", "Túi đồ"], ["toggle_skills", "Kỹ năng"],
	["toggle_talent", "Thiên phú"], ["toggle_map", "Khai phá"], ["toggle_world", "Bản đồ lục địa"],
	["toggle_minimap", "Bản đồ nhỏ"], ["toggle_forge", "Lò Rèn"], ["toggle_help", "Trợ giúp"],
	["toggle_quests", "Sổ nhiệm vụ"],
]

## Phím mặc định (main.KEY_ACTIONS) — main gán lúc khởi động.
static var defaults := {}


static func _codes(action: String) -> Array:
	var kb: Dictionary = Settings.values.get("keybinds", {})
	if kb.has(action):
		return kb[action]
	return defaults.get(action, [])


## Áp mọi phím (mặc định + người chơi đổi) lên InputMap; giữ sự kiện chuột.
static func apply() -> void:
	for action in defaults:
		if not InputMap.has_action(action):
			continue
		for ev in InputMap.action_get_events(action):
			if ev is InputEventKey:
				InputMap.action_erase_event(action, ev)
		for code in _codes(action):
			var k := InputEventKey.new()
			k.physical_keycode = int(code)
			InputMap.action_add_event(action, k)


## Gán phím chính cho action. Thao tác khác đang dùng phím này thì bỏ phím đó khỏi thao tác kia.
## Trả về action bị lấy phím ("" nếu không có).
static func set_key(action: String, code: int) -> String:
	var kb: Dictionary = (Settings.values.get("keybinds", {}) as Dictionary).duplicate(true)
	var taken := ""
	for other in defaults:
		if other == action:
			continue
		var cs: Array = (kb[other] if kb.has(other) else defaults[other]).duplicate()
		if cs.has(code):
			cs.erase(code)
			kb[other] = cs
			taken = other
	kb[action] = [code]
	Settings.set_value("keybinds", kb)
	apply()
	return taken


static func reset() -> void:
	Settings.set_value("keybinds", {})
	apply()


## Tên phím đang gán (phím đầu tiên), "—" nếu chưa có.
static func key_name(action: String) -> String:
	var cs := _codes(action)
	if cs.is_empty():
		return "—"
	return OS.get_keycode_string(int(cs[0]))
