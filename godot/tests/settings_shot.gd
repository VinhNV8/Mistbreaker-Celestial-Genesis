extends SceneTree
## FX-1 §9.12: chụp thẻ Cài đặt (mặc định "Trợ năng") của bảng tạm dừng thật. Cần cửa sổ.
##   Godot_console.exe --path godot --script res://tests/settings_shot.gd -- --out=<file.png> [--tab=display]
var _out := "user://settings_shot.png"
var _tab := "access"


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--out="):
			_out = a.substr(6)
		elif a.begins_with("--tab="):
			_tab = a.substr(6)
	_run.call_deferred()


func _run() -> void:
	root.size = Vector2i(1280, 720)
	var pm = load("res://scripts/ui/pause_menu.gd").new()
	root.add_child(pm)
	await process_frame
	pm.tab = _tab
	pm.show_settings()
	pm.visible = true
	for i in 6:
		await process_frame
	root.get_viewport().get_texture().get_image().save_png(_out)
	print("settings shot: ", _out)
	quit()
