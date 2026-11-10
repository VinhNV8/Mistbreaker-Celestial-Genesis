extends SceneTree
## CR-06: chụp màn Chọn nhân vật mới (dữ liệu giả 4 nhân vật + 1 ô trống, chọn lần lượt vài nhân vật).
## Cần cửa sổ (không headless).
##   Godot_console.exe --path godot --script res://tests/cr6_shot.gd -- --dir=<thư mục>

const UiTheme = preload("res://scripts/ui/ui_theme.gd")
const Screens = preload("res://scripts/ui/screens.gd")

var _dir := "user://"


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--dir="):
			_dir = a.substr(6)
	_run.call_deferred()


static func fake(n: int, nm: String, cid: String, lv: int, talent: String, map_id: String, mins: int) -> Dictionary:
	return {"slot": n, "name": nm, "class_id": cid, "job": "", "job2": "", "job3": "", "level": lv, "talent": talent,
		"play_seconds": mins * 60.0, "last_seen": 0.0, "look": {"gender": "nam", "skin": 1, "hair_style": "ngan", "hair_color": 0}, "map_id": map_id}


func _shot(name: String) -> void:
	for i in 60:
		await process_frame
	var path := _dir.path_join(name + ".png")
	root.get_viewport().get_texture().get_image().save_png(path)
	print("CR6 shot: ", path)


func _run() -> void:
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	root.size = Vector2i(1366, 768)
	root.theme = UiTheme.get_theme()
	var info := [fake(1, "Khai Giới Giả", "kiem-khach", 30, "tay-nhanh", "1-2", 0),
		fake(2, "Đệ Nhị", "ho-ve", 35, "thuan-thu", "3-1", 85),
		fake(3, "Đệ Tam", "phap-su", 67, "dao-tac", "7-2", 230),
		{},
		fake(5, "Đệ Ngũ", "tho-san", 3, "ban-tay-vang", "1-1", 2)]
	var nop := func(_a = null): pass
	var scr: Control = Screens.slots(info, nop, nop, nop, nop, 3, nop, nop)
	root.add_child(scr)
	await _shot("cr6-chon-o3")
	scr.select(2)
	await _shot("cr6-chon-o2")
	var empty: Control = Screens.slots([{}, {}, {}, {}, {}], nop, nop, nop, nop)
	scr.queue_free()
	root.add_child(empty)
	await _shot("cr6-chua-co")
	quit()
