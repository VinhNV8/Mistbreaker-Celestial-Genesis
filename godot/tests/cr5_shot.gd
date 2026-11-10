extends SceneTree
## CR-05: chụp HUD THẬT — bình thường / nhân vật dưới bản đồ nhỏ (mờ) / dưới khung nhiệm vụ / tắt cả 2 khung.
## Cần cửa sổ (không headless).
##   Godot_console.exe --path godot --script res://tests/cr5_shot.gd -- --dir=<thư mục>

const GameWorld = preload("res://scripts/core/game_world.gd")
const Profile = preload("res://scripts/core/profile.gd")
const RngUtil = preload("res://scripts/core/rng_util.gd")
const UiTheme = preload("res://scripts/ui/ui_theme.gd")
const Hud = preload("res://scripts/ui/hud.gd")
const Settings = preload("res://scripts/core/settings.gd")

var _dir := "user://"


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--dir="):
			_dir = a.substr(6)
	_run.call_deferred()


func _shot(name: String, hud, w) -> void:
	for i in 40:
		hud.update_from(w)
		await process_frame
	var path := _dir.path_join(name + ".png")
	root.get_viewport().get_texture().get_image().save_png(path)
	print("CR5 shot: ", path)


func _run() -> void:
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	root.size = Vector2i(1366, 768)
	root.theme = UiTheme.get_theme()
	Settings.values["hud_minimap"] = true
	Settings.values["hud_quest"] = true
	var p := Profile.new()
	p.setup("tay-nhanh", RngUtil.make(7), 0.0)
	p.class_id = "kiem-khach"
	var w := GameWorld.new(p, RngUtil.make(5))
	var bg := ColorRect.new()
	bg.color = Color("#3d5a3a")
	bg.size = Vector2(1366, 768)
	root.add_child(bg)
	var dummy := ColorRect.new()
	dummy.color = Color("#ff4fd0")
	dummy.size = Vector2(56, 100)
	root.add_child(dummy)
	var hud = Hud.new()
	root.add_child(hud)
	dummy.position = Vector2(640, 340)
	hud.focus_rect = Rect2(dummy.position, dummy.size)
	await _shot("cr5-binh-thuong", hud, w)
	dummy.position = hud._minimap.position + Vector2(80, 90)
	hud.focus_rect = Rect2(dummy.position, dummy.size)
	await _shot("cr5-duoi-ban-do", hud, w)
	dummy.position = hud._obj.position + Vector2(80, 20)
	hud.focus_rect = Rect2(dummy.position, dummy.size)
	await _shot("cr5-duoi-nhiem-vu", hud, w)
	Settings.values["hud_minimap"] = false
	Settings.values["hud_quest"] = false
	await _shot("cr5-an-ca-hai", hud, w)
	quit()
