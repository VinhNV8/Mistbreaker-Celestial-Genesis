extends SceneTree
## GN-1 (docs/45): chụp cảnh thật để duyệt góc nhìn / cảnh trại / quầng sáng. Cần cửa sổ.
##   Godot_console.exe --path godot --script res://tests/gn1_shot.gd -- --out=<png> [--map=1-1] [--at=arena|camp|village|path]
##     [--tilt=off|low|mid] [--hud] [--size=1920x1080] [--mobs] [--hd=0] [--depth=0]
const Profile = preload("res://scripts/core/profile.gd")
const RngUtil = preload("res://scripts/core/rng_util.gd")
const CampDecor = preload("res://scripts/view/camp_decor.gd")

var main
var out := "user://gn1.png"
var map_id := "1-1"
var at := "arena"
var tilt := "low"
var hud := false
var mobs := false
var size := Vector2i(1366, 768)
var hd := true
var depth := true
var n := 0
var combo := 0
var upright := true


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--out="):
			out = a.substr(6)
		elif a.begins_with("--map="):
			map_id = a.substr(6)
		elif a.begins_with("--at="):
			at = a.substr(5)
		elif a.begins_with("--tilt="):
			tilt = a.substr(7)
		elif a == "--hud":
			hud = true
		elif a == "--mobs":
			mobs = true
		elif a == "--hd=0":
			hd = false
		elif a == "--depth=0":
			depth = false
		elif a == "--noupright":
			upright = false
		elif a.begins_with("--combo="):
			combo = int(a.substr(8))
		elif a.begins_with("--size="):
			var p := a.substr(7).split("x")
			size = Vector2i(int(p[0]), int(p[1]))
	root.size = size
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)


func _process(_d: float) -> bool:
	n += 1
	if n == 5:
		main.Settings.values["tilt"] = tilt
		main.Settings.values["depth_fx"] = depth
		main._view.SpriteLib.set_hd(hd)
		var p := Profile.new()
		p.setup("tay-nhanh", RngUtil.make(3), 0.0)
		p.quest_step = 12
		p.class_id = "kiem-khach"
		p.level = 30
		p.map_id = map_id
		main._start_world(p)
		if not mobs:
			main.world.field_spawn = false
			main.world.enemies = []
		var w = main.world
		var pos: Vector2 = w.safe_pos + Vector2(-70, -10)  # tránh đứng trên Cổng Dịch Chuyển (tự mở bản đồ lục địa)
		match at:
			"arena":
				pos = w.arena_pos + Vector2(0, w.arena_r * 0.35)
			"path":
				pos = w.safe_pos + Vector2(w.safe_r + 420.0, 0)
			"top":
				pos = Vector2(w.world_size.x * 0.4, 60.0)
			"corner":
				pos = Vector2(w.world_size.x - 60.0, w.world_size.y - 60.0)
			"lake":
				var wd = w.map.get("water", null)
				if wd != null:
					pos = wd.zones[0][0] + Vector2(0, float(wd.zones[0][1]) + 60.0)
				for z in w.map.get("lava", []):
					pos = z[0] + Vector2(0, float(z[1]) + 70.0)
					break
			"camp":
				# bãi trại đầu tiên (vùng dọn cây không phải đấu trường)
				var cd := CampDecor.build(w)
				for c in cd.clear:
					if w.map.arena == null or c[0].distance_to(w.arena_pos) > 10.0:
						pos = c[0] + Vector2(0, 90)
						break
		if at == "arena":
			w.gate_x = INF  # chụp trong đấu trường: bỏ màn sương chặn (chỉ trong công cụ chụp)
		w.player.pos = pos
		w.fog.reveal(pos, 3000.0)
		main.bot = func(_w): return {"move": Vector2.ZERO, "aim": pos + Vector2.RIGHT, "attack": false, "skill": false, "talent": false, "dodge": false}
		main._camera.position = pos
		main._camera.reset_smoothing()
		main.hud.visible = hud
	if combo > 0 and n >= 40 and n % 4 == 0 and main.world.combo < combo:
		main.world.combo = mini(combo, main.world.combo + 3 if main.world.combo > 0 else combo - 3)
		main.world._combo_timer = 5.0
	if n > 5 and not upright:
		main._view.tilt_g = 0.0
	if n == 70:
		root.get_viewport().get_texture().get_image().save_png(out)
		print("GN1 shot: ", out)
		return true
	return false
