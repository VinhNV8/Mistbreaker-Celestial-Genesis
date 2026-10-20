extends RefCounted
## Lưu/nạp tiến trình ra file JSON trong thư mục dữ liệu người dùng của Godot (user://).

const Config = preload("res://scripts/core/config.gd")
const Explore = preload("res://scripts/core/explore.gd")
const Profile = preload("res://scripts/core/profile.gd")

## Chế độ smoke test đổi sang file riêng để không đụng vào save thật.
static var save_path := "user://save.json"


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
	p.last_seen = now
	return {"seconds": seconds, "gold": made.gold, "wood": made.wood, "torches": torches, "herbs": herbs}
