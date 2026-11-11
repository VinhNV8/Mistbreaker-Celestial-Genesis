extends SceneTree
## WB-1 (docs/48 §B): chụp thẻ chào quay lại trên nền HUD thật. Cần cửa sổ.
##   Godot_console.exe --path godot --script res://tests/wb1_shot.gd -- --out=<file.png>

const GameWorld = preload("res://scripts/core/game_world.gd")
const Profile = preload("res://scripts/core/profile.gd")
const RngUtil = preload("res://scripts/core/rng_util.gd")
const UiTheme = preload("res://scripts/ui/ui_theme.gd")
const Welcome = preload("res://scripts/core/welcome.gd")
const WelcomePanel = preload("res://scripts/ui/welcome_panel.gd")

var _out := "user://wb1_shot.png"


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--out="):
			_out = a.substr(6)
	_run.call_deferred()


func _run() -> void:
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	root.size = Vector2i(1366, 768)
	root.theme = UiTheme.get_theme()
	var p := Profile.new()
	p.setup("tay-nhanh", RngUtil.make(7), 0.0, "phap-su")
	p.name = "Anh Vinh Đẹp Zai"
	p.level = 24
	p.quest_step = 12
	p.unspent = 3
	var w := GameWorld.new(p, RngUtil.make(5))
	var bg := ColorRect.new()
	bg.color = Color("#2a3a2a")
	bg.size = Vector2(1366, 768)
	root.add_child(bg)
	var wp = WelcomePanel.new()
	root.add_child(wp)
	await process_frame
	wp.show_welcome(w, Welcome.build(w, 2 * 86400.0 + 3 * 3600.0, {"seconds": 28800.0, "gold": 640.0, "wood": 210.0, "torches": 4, "herbs": 6, "exp": 1850.0}, 20))
	for i in 6:
		await process_frame
	root.get_viewport().get_texture().get_image().save_png(_out)
	print("WB1 shot: ", _out)
	quit()
