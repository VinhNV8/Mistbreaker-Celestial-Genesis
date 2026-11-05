extends SceneTree
## FX-1 §9.11: chụp cảnh báo đòn quái riêng của vùng 5–9 (view từng chương) trong game thật. Cần cửa sổ.
##   Godot_console.exe --path godot --script res://tests/fx1_regions.gd -- --region=5 --out=<file.png> [--mode=old]
const GameWorld = preload("res://scripts/core/game_world.gd")
const Profile = preload("res://scripts/core/profile.gd")
const RngUtil = preload("res://scripts/core/rng_util.gd")
const WorldView = preload("res://scripts/view/world_view.gd")
const Fx1 = preload("res://scripts/view/fx1.gd")

## vùng → [đòn quái đang vung], vòng báo (marks) thêm riêng
const KINDS := {
	5: ["fireburst", "hammer", "pdive", "dbreath", "firepillar"],
	6: ["snowball", "icepillar", "icecrack", "frostbreath", "m_spin", "m_dash"],
	7: ["lance", "clouddash", "rootlash"],
	8: ["seal", "voidbeam", "heavycleave", "jaw", "sacrifice"],
	9: ["elemlance", "gallop", "roar9", "spin9"],
}
var _elite := false
var _k := 0.55
var _out := "user://fx1_regions.png"
var _region := 5
var _mode := "fx1"


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--out="):
			_out = a.substr(6)
		elif a == "--elite":
			_elite = true
		elif a.begins_with("--k="):
			_k = float(a.substr(4))
		elif a.begins_with("--region="):
			_region = int(a.substr(9))
		elif a.begins_with("--mode="):
			_mode = a.substr(7)
	_run.call_deferred()


func _run() -> void:
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	root.size = Vector2i(1280, 720)
	var p := Profile.new()
	p.setup("tay-nhanh", RngUtil.make(7), 0.0)
	p.quest_step = 12
	p.level = 90
	p.map_id = "%d-1" % _region
	var w := GameWorld.new(p, RngUtil.make(5))
	w.enemies = []
	w.field_spawn = false
	var c := w.world_size * 0.5
	w.player.pos = c
	w.fog.reveal(c, 1200.0)
	Fx1.set_mode(_mode)
	var kinds: Array = KINDS[_region]
	for i in kinds.size():
		var at := c + Vector2(-470 + (i % 3) * 360, -200 + (i / 3) * 300)
		var e := w.spawn_enemy("wolf", 30, at)
		e.state = "windup"
		e.attack_kind = kinds[i]
		e.windup_total = 1.0
		e.timer = 1.0 - _k
		e.elite = _elite
		e.target = e.pos + Vector2(160, 60)
		e.face = (e.target - e.pos).angle()
	var mk := {"pos": c + Vector2(80, 230), "r": 70.0, "t": 0.6, "total": 1.5, "color": "#9ad8ff"}
	match _region:
		5:
			w.ch5.meteors.append({"pos": c + Vector2(80, 230), "t": 0.8})
			w.ch5.feathers.append({"pos": c + Vector2(-160, 260), "t": 0.5})
		6:
			w.ch6.marks.append(mk)
		7:
			w.ch7.marks.append(mk)
		8:
			w.ch8.marks.append(mk)
		9:
			mk["color"] = "#ffb060"
			w.ch9.marks.append(mk)
	var view := WorldView.new()
	root.add_child(view)
	view.set_process(false)
	var cam := Camera2D.new()
	view.add_child(cam)
	view.camera = cam
	cam.position = c
	cam.make_current()
	view.world = w
	for i in 14:  # cây che mờ dần (§9.13) cần ~8 khung
		view._process(1.0 / 60.0)
		await process_frame
	root.get_viewport().get_texture().get_image().save_png(_out)
	print("FX1 regions: vùng %d → %s" % [_region, _out])
	Fx1.set_mode("")
	quit()
