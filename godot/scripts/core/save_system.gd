extends RefCounted
## Lưu/nạp tiến trình ra file JSON trong thư mục dữ liệu người dùng của Godot (user://).

const Config = preload("res://scripts/core/config.gd")
const Explore = preload("res://scripts/core/explore.gd")
const Profile = preload("res://scripts/core/profile.gd")

## Chế độ smoke test đổi sang file riêng để không đụng vào save thật.
static var save_path := "user://save.json"

## SN9-02 (Spec_Notes đợt 9): tối đa 5 nhân vật, mỗi ô một file. Ô 1 dùng lại `save.json` (save cũ thành ô 1),
## ô 2…5 là `save_2.json`… Ô chơi gần nhất lưu ở `slots.cfg`. Smoke test đổi `prefix` / `slots_cfg`.
const MAX_SLOTS := 5
static var prefix := "user://save"
static var slots_cfg := "user://slots.cfg"
static var slot := 1


static func path_of(n: int) -> String:
	return ("%s.json" % prefix) if n == 1 else ("%s_%d.json" % [prefix, n])


## Chọn ô đang chơi — mọi load_profile / save_profile / clear_save sau đó dùng file của ô này.
static func select_slot(n: int) -> void:
	slot = clampi(n, 1, MAX_SLOTS)
	save_path = path_of(slot)


static func _load_path(path: String) -> Profile:
	if not FileAccess.file_exists(path):
		return null
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(data) != TYPE_DICTIONARY:
		return null
	var p := Profile.new()
	return p if p.load_dict(data) else null


## Thông tin hiện ở màn Chọn nhân vật: {} nếu ô trống, ngược lại {slot, name, class_id, job, job2, job3, level,
## talent, play_seconds, last_seen, look, map_id} (CR-06: look + map_id để vẽ nhân vật / ghi vùng ở màn Chọn nhân vật).
static func slot_summary(n: int) -> Dictionary:
	var p := _load_path(path_of(n))
	if p == null:
		return {}
	return {"slot": n, "name": str(p.name), "class_id": str(p.class_id), "job": str(p.job), "job2": str(p.job2),
		"job3": str(p.job3), "level": int(p.level), "talent": str(p.talent),
		"play_seconds": float(p.play_seconds), "last_seen": float(p.last_seen), "look": p.look.duplicate(), "map_id": str(p.map_id)}


static func list_slots() -> Array:
	var out: Array = []
	for n in range(1, MAX_SLOTS + 1):
		out.append(slot_summary(n))
	return out


static func any_save() -> bool:
	for n in range(1, MAX_SLOTS + 1):
		if FileAccess.file_exists(path_of(n)) and _load_path(path_of(n)) != null:
			return true
	return false


## Ô trống đầu tiên (0 = đủ 5 nhân vật).
static func first_empty() -> int:
	for n in range(1, MAX_SLOTS + 1):
		if _load_path(path_of(n)) == null:
			return n
	return 0


static func delete_slot(n: int) -> void:
	var path := path_of(n)
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


## Q153: tên nhân vật không trùng giữa các ô (không phân biệt hoa thường, bỏ khoảng trắng hai đầu).
static func name_taken(name: String, except_slot := 0) -> bool:
	var key := name.strip_edges().to_lower()
	for n in range(1, MAX_SLOTS + 1):
		if n == except_slot:
			continue
		var s := slot_summary(n)
		if not s.is_empty() and str(s.name).strip_edges().to_lower() == key:
			return true
	return false


static func remember_slot(n: int) -> void:
	var cf := ConfigFile.new()
	cf.set_value("slots", "last", n)
	cf.save(slots_cfg)


## Ô chơi gần nhất còn nhân vật (0 nếu không còn ô nào).
static func last_slot() -> int:
	var cf := ConfigFile.new()
	var n := 1
	if cf.load(slots_cfg) == OK:
		n = int(cf.get_value("slots", "last", 1))
	if _load_path(path_of(n)) != null:
		return n
	for m in range(1, MAX_SLOTS + 1):
		if _load_path(path_of(m)) != null:
			return m
	return 0


static func has_save() -> bool:
	return load_profile() != null


static func load_profile() -> Profile:
	if not FileAccess.file_exists(save_path):
		return null
	var text := FileAccess.get_file_as_string(save_path)
	var data: Variant = JSON.parse_string(text)
	if typeof(data) != TYPE_DICTIONARY:
		return null
	var p := Profile.new()
	return p if p.load_dict(data) else null


static func save_profile(p: Profile) -> void:
	var f := FileAccess.open(save_path, FileAccess.WRITE)
	if f == null:
		push_warning("Không lưu được tiến trình: %s" % error_string(FileAccess.get_open_error()))
		return
	f.store_string(JSON.stringify(p.to_dict()))


static func clear_save() -> void:
	if FileAccess.file_exists(save_path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path))


## Lãnh địa tiếp tục sản xuất khi người chơi vắng mặt, tối đa 12 giờ.
static func apply_offline(p: Profile, now: float) -> Dictionary:
	var seconds := clampf(now - p.last_seen, 0.0, Explore.offline_cap(p))
	# Công trình xong trước rồi mới tính sản lượng (đơn giản hoá: coi như xong từ đầu khoảng offline).
	Explore.tick_build_clock(p, seconds)
	var made := Explore.tick_production(p, seconds)
	var torches := Explore.regen_torches(p, seconds)
	var herbs := Explore.tick_garden(p, seconds)
	# NV-24: EXP offline từ lãnh địa — main.gd cộng qua GameWorld.add_exp để lên cấp đúng.
	var exp_gain := Explore.offline_exp_per_minute(p) * seconds / 60.0
	p.last_seen = now
	return {"seconds": seconds, "gold": made.gold, "wood": made.wood, "torches": torches, "herbs": herbs,
		"ore": made.ore, "iron": made.iron, "exp": exp_gain}
