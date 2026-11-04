extends SceneTree
## FX-1 (docs/36): smoke chụp hiệu ứng kỹ năng trong game thật (cần cửa sổ / GPU, không chạy headless).
##   Godot_console.exe --path godot --script res://tests/fx1_smoke.gd -- --class=phap-su --out=<thư mục> [--mode=fx1|auto|old]
## Mỗi kỹ năng: world thật + world_view, thi triển bằng use_skill thật trước 4 quái, chụp 3 thời điểm
## (<id>-0 tụ lực, -1 va chạm, -2 tan) vùng 720×420 quanh người chơi. Không đổi logic game.

const GameWorld = preload("res://scripts/core/game_world.gd")
const Profile = preload("res://scripts/core/profile.gd")
const RngUtil = preload("res://scripts/core/rng_util.gd")
const WorldView = preload("res://scripts/view/world_view.gd")
const Classes = preload("res://scripts/data/classes.gd")
const Fx1 = preload("res://scripts/view/fx1.gd")

var _cls := "phap-su"
var _out := "user://fx1_smoke"
var _mode := "fx1"
## --frames=N: chụp liên tục N ảnh, mỗi ảnh cách 4 khung game (1/15 giây) → <id>-fNN.png (làm GIF so với bản thiết kế).
var _seq := 0
var _only: Array = []


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--class="):
			_cls = a.substr(8)
		elif a.begins_with("--out="):
			_out = a.substr(6)
		elif a.begins_with("--mode="):
			_mode = a.substr(7)
		elif a.begins_with("--frames="):
			_seq = int(a.substr(9))
		elif a.begins_with("--only="):
			_only = a.substr(7).split(",")
	_run.call_deferred()


func _profile(sk: Dictionary) -> Profile:
	var p := Profile.new()
	p.setup("tay-nhanh", RngUtil.make(7), 0.0)
	p.quest_step = 12
	p.class_id = _cls
	p.level = 100
	p.job = "smoke"
	p.job2 = str(sk.get("job2", ""))
	p.job3 = "smoke"
	return p


## World và world_view cùng bước 1/60 giây (view tắt _process tự động): khung chụp khớp thời gian gameplay
## dù cửa sổ smoke chạy chậm hơn 60 FPS.
var _view: Node2D


func _frames(w: GameWorld, n: int) -> void:
	var inp := {"move": Vector2.ZERO, "aim": w.player.pos + Vector2(300, 20), "attack": false, "skill": false, "talent": false, "dodge": false}
	for i in n:
		w.update(1.0 / 60.0, inp)
		_view._process(1.0 / 60.0)
		await process_frame


func _snap(view: Node2D, w: GameWorld, name: String) -> void:
	await process_frame
	await process_frame
	var img := root.get_viewport().get_texture().get_image()
	var cam: Vector2 = view.camera.get_screen_center_position()
	var size := Vector2(root.get_viewport().get_visible_rect().size)
	# --frames: khung 480×280 quanh người chơi (nhân vật cao ~85 px ≈ tỉ lệ bản thiết kế khi phóng về 576×336)
	var half := Vector2(240, 140) if _seq > 0 else Vector2(360, 210)
	var c := (w.player.pos - cam) + size / 2.0 + (Vector2(130, -40) if _seq > 0 else Vector2(150, -30))
	var r := Rect2i(Vector2i(c - half), Vector2i(half * 2.0)).intersection(Rect2i(Vector2i.ZERO, img.get_size()))
	img.get_region(r).save_png("%s/%s.png" % [_out, name])


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(_out)
	root.size = Vector2i(1280, 720)
	Fx1.set_mode(_mode)
	var skills: Array = []
	for sk in Classes.DEFS[_cls].skills:
		if Fx1.SK.has(str(sk.id)) and (_only.is_empty() or str(sk.id) in _only):
			skills.append(sk)
	for sk in skills:
		var w := GameWorld.new(_profile(sk), RngUtil.make(5))
		w.enemies = []
		w.player.pos = Vector2(900, 700)
		for i in 4:
			var e := w.spawn_enemy(["wolf", "mushroom", "wolf", "wolf"][i], 60, w.player.pos + Vector2(170 + 60 * (i % 2), -70 + i * 45))
			e.hp = e.max_hp * 1000.0
			e.max_hp = e.hp
		w.fog.reveal(w.player.pos, 900.0)
		var view := WorldView.new()
		root.add_child(view)
		view.set_process(false)
		_view = view
		var cam := Camera2D.new()
		view.add_child(cam)
		view.camera = cam
		cam.position = w.player.pos + Vector2(150, 0)
		cam.make_current()
		view.world = w
		w.player.facing = 0.1
		await _frames(w, 20)
		# đặt kỹ năng vào ô hợp lệ (ô Tuyệt kỹ / ô thường) rồi thi triển thật
		var slot := -1
		for i in Classes.SKILL_SLOTS:
			var lo: Array = []
			for j in Classes.SKILL_SLOTS:
				lo.append(str(sk.id) if j == i else "")
			w.profile.loadout = lo
			if str(w.slot_skill(i).get("id", "")) == str(sk.id):
				slot = i
				break
		await _frames(w, 3)
		w.player.mp = 9999.0
		w.player.skill_cds[maxi(0, slot)] = 0.0
		var used := slot >= 0 and w.use_skill(slot)
		if not used:
			Fx1.on_cast(w, sk)
			print("FX1 smoke: %s không thi triển được qua use_skill (ô %d) — vẽ trực tiếp" % [sk.id, slot])
		if _seq > 0:
			for k in _seq:
				await _snap(view, w, "%s-f%02d" % [sk.id, k])
				await _frames(w, 4)
			view.queue_free()
			await process_frame
			continue
		var dur: float = Fx1.SK[sk.id][3]
		var times := [0.18, 0.5, 0.85] if dur < 3.0 else [0.08, 0.2, 0.4]
		var at := 0.0
		for k in 3:
			var want: float = dur * float(times[k]) if dur < 3.0 else float(times[k]) * 3.0
			await _frames(w, maxi(1, int((want - at) * 60.0)))
			at = want
			await _snap(view, w, "%s-%d" % [sk.id, k])
		view.queue_free()
		await process_frame
	print("FX1 smoke done: %s %d kỹ năng" % [_cls, skills.size()])
	quit()
