extends SceneTree
## FX-1 §9.9: chụp vòng cảnh báo đòn của quái (4 kiểu đòn đang vung) trong game thật. Cần cửa sổ.
##   Godot_console.exe --path godot --script res://tests/fx1_telegraph.gd -- --out=<file.png>
const GameWorld = preload("res://scripts/core/game_world.gd")
const Profile = preload("res://scripts/core/profile.gd")
const RngUtil = preload("res://scripts/core/rng_util.gd")
const WorldView = preload("res://scripts/view/world_view.gd")
var _out := "user://fx1_telegraph.png"
func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--out="):
			_out = a.substr(6)
	_run.call_deferred()
func _run() -> void:
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	root.size = Vector2i(1280, 720)
	var p := Profile.new()
	p.setup("tay-nhanh", RngUtil.make(7), 0.0)
	p.quest_step = 12
	var w := GameWorld.new(p, RngUtil.make(5))
	w.enemies = []
	w.player.pos = Vector2(900, 700)
	w.fog.reveal(w.player.pos, 900.0)
	var kinds := [["wolf", "pounce"], ["boss", "stomp"], ["wolf", "roar"], ["mushroom", "roots"]]
	for i in kinds.size():
		var e := w.spawn_enemy(kinds[i][0], 20, w.player.pos + Vector2(-260 + i * 190, -40 + (i % 2) * 80))
		e.state = "windup"
		e.attack_kind = kinds[i][1]
		e.windup_total = 1.0
		e.timer = 0.45
		e.target = e.pos + Vector2(0, 60)
	var view := WorldView.new()
	root.add_child(view)
	view.set_process(false)
	var cam := Camera2D.new()
	view.add_child(cam)
	view.camera = cam
	cam.position = w.player.pos
	cam.make_current()
	view.world = w
	for i in 6:
		view._process(1.0 / 60.0)
		await process_frame
	root.get_viewport().get_texture().get_image().save_png(_out)
	print("FX1 telegraph: ", _out)
	quit()
