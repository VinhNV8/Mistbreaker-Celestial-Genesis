extends SceneTree
## FX-1 §9.9 / §9.11: chụp cảnh báo đòn của quái đang vung trong game thật. Cần cửa sổ.
##   Godot_console.exe --path godot --script res://tests/fx1_telegraph.gd -- --out=<file.png> [--set=lines]
##   --set=lines: dải / nón (bắn loạt, lá, lăn, lao, ánh nhìn, bào tử) thay cho 4 vòng tròn.
const GameWorld = preload("res://scripts/core/game_world.gd")
const Profile = preload("res://scripts/core/profile.gd")
const RngUtil = preload("res://scripts/core/rng_util.gd")
const WorldView = preload("res://scripts/view/world_view.gd")
var _elite := false
var _map := ""
var _seq := false
var _k := 0.55
var _out := "user://fx1_telegraph.png"
var _set := "zones"
func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--out="):
			_out = a.substr(6)
		elif a.begins_with("--map="):
			_map = a.substr(6)
		elif a == "--seq":
			_seq = true
		elif a == "--elite":
			_elite = true
		elif a.begins_with("--k="):
			_k = float(a.substr(4))
		elif a.begins_with("--set="):
			_set = a.substr(6)
	_run.call_deferred()
func _run() -> void:
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	root.size = Vector2i(1280, 720)
	var p := Profile.new()
	p.setup("tay-nhanh", RngUtil.make(7), 0.0)
	p.quest_step = 12
	if _map != "":
		p.level = 60
		p.map_id = _map
	var w := GameWorld.new(p, RngUtil.make(5))
	w.enemies = []
	w.player.pos = Vector2(900, 700)
	w.fog.reveal(w.player.pos, 900.0)
	var kinds := [["wolf", "pounce"], ["boss", "stomp"], ["wolf", "roar"], ["mushroom", "roots"]]
	if _set == "lines":
		kinds = [["wolf", "volley"], ["mushroom", "leaf"], ["boss", "roll"], ["wolf", "dash"], ["wolf", "gaze"], ["mushroom", "spore"]]
	for i in kinds.size():
		var at := w.player.pos + Vector2(-260 + i * 190, -40 + (i % 2) * 80)
		if _set == "lines":
			at = w.player.pos + Vector2(-480 + (i % 3) * 330, -220 + (i / 3) * 260)
		var e := w.spawn_enemy(kinds[i][0], 20, at)
		e.state = "windup"
		e.attack_kind = kinds[i][1]
		e.windup_total = 1.0
		e.timer = 1.0 - _k
		e.elite = _elite
		e.target = e.pos + (Vector2(200, 70) if _set == "lines" else Vector2(0, 60))
	var view := WorldView.new()
	root.add_child(view)
	view.set_process(false)
	var cam := Camera2D.new()
	view.add_child(cam)
	view.camera = cam
	cam.position = w.player.pos
	cam.make_current()
	view.world = w
	if _seq:
		await _sequence(w, view)
		quit()
		return
	for i in 14:  # cây che mờ dần (§9.13) cần ~8 khung
		view._process(1.0 / 60.0)
		await process_frame
	root.get_viewport().get_texture().get_image().save_png(_out)
	print("FX1 telegraph: ", _out)
	quit()


## --seq: chụp một nhịp lấy đà 1 giây (60 khung, world.time chạy thật) quanh con quái đầu tiên, mỗi 6 khung một ảnh →
## dải 10 ảnh để xem chuyển động (hiện dần, run người, ánh loé) có giật / chớp không.
func _sequence(w, view) -> void:
	var e = w.enemies[0]
	var strip := Image.create(10 * 240, 200, false, Image.FORMAT_RGBA8)
	var shot := 0
	for f in 60:
		for fe in w.enemies:
			fe.timer = 1.0 - float(f) / 60.0
		w.time += 1.0 / 60.0
		view._process(1.0 / 60.0)
		await process_frame
		if f % 6 == 5:
			var img: Image = root.get_viewport().get_texture().get_image()
			var cam_off: Vector2 = Vector2(640, 360) - view.camera.position
			var c: Vector2 = e.pos + cam_off
			strip.blit_rect(img, Rect2i(int(c.x) - 120, int(c.y) - 120, 240, 200), Vector2i(shot * 240, 0))
			shot += 1
	strip.save_png(_out)
	print("FX1 telegraph seq: ", _out)
