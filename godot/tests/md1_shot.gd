extends SceneTree
## MD-1 (docs/39): chụp mọi quái của 1 vùng đứng trong game thật (nền vùng, cây, tỉ lệ thật). Cần cửa sổ.
##   Godot_console.exe --path godot --script res://tests/md1_shot.gd -- --region=5 --out=<file.png> [--hd=0]
## "E:" = bản tinh anh (elite_sprite) của loại đó.
const GameWorld = preload("res://scripts/core/game_world.gd")
const Profile = preload("res://scripts/core/profile.gd")
const RngUtil = preload("res://scripts/core/rng_util.gd")
const WorldView = preload("res://scripts/view/world_view.gd")
const SpriteLib = preload("res://scripts/view/sprite_lib.gd")

const KINDS := {
	1: ["wolf", "mushroom", "wisp", "moc-tinh", "nam-con", "goc-re", "boss", "lao-thu", "bach-ho"],
	2: ["ung-gio", "linh-danh-thue", "E:linh-danh-thue", "cung-thu", "loc-xoay", "E:loc-xoay", "huyen-anh"],
	3: ["bo-cat", "E:bo-cat", "ran-cat", "xac-uop", "E:xac-uop", "phap-su-cat", "sa-hoang", "nhan-su"],
	4: ["ech-doc", "dia", "hon-ma", "E:hon-ma", "ca-sau", "E:ca-sau", "mong-chau", "dau-thuy-quai", "nu-vuong", "thuy-quai"],
	5: ["than-lan-lua", "E:than-lan-lua", "nguoi-da", "E:nguoi-da", "manh-da", "linh-hon-lua", "phap-su-hoa-diem", "linh-kim-luan",
		"doi-truong-kim-luan", "xuong-no", "phuong-hoang", "vien-long"],
	6: ["soi-bang", "nguoi-tuyet", "E:nguoi-tuyet", "tinh-linh-bang", "E:tinh-linh-bang", "cung-thu-bang", "guong-bang", "anh-bong",
		"ban-nga", "long-bang"],
	7: ["dai-bang-may", "E:dai-bang-may", "nguoi-go-dao", "E:nguoi-go-dao", "tien-gio", "hiep-si-thien-khong", "neo-hu-vo",
		"ky-lan-may", "cu-than"],
	8: ["bong-hu-vo", "ke-nuot", "E:ke-nuot", "giap-si-hu-vo", "E:giap-si-hu-vo", "mat-hu-vo", "long-hu-vo", "tru-phong-an",
		"hu-vo-thu", "giao-chu"],
	9: ["thien-binh", "E:thien-binh", "tan-hon", "E:tan-hon", "thien-ma", "linh-thu-ngu-hanh", "ma-ton", "thien-dao-hu-anh"],
}
const MAP := {1: "1-1", 2: "2-1", 3: "3-1", 4: "4-1", 5: "5-1", 6: "6-1", 7: "7-1", 8: "8-1", 9: "9-1"}
var _out := "user://md1_shot.png"
var _region := 1
var _hd := true


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--out="):
			_out = a.substr(6)
		elif a.begins_with("--region="):
			_region = int(a.substr(9))
		elif a == "--hd=0":
			_hd = false
	_run.call_deferred()


func _run() -> void:
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	root.size = Vector2i(1280, 720)
	SpriteLib.set_hd(_hd)
	var p := Profile.new()
	p.setup("tay-nhanh", RngUtil.make(7), 0.0)
	p.quest_step = 12
	p.level = 10 * _region
	p.map_id = MAP[_region]
	var w := GameWorld.new(p, RngUtil.make(5))
	w.enemies = []
	w.field_spawn = false
	var c := w.world_size * 0.5
	w.player.pos = c + Vector2(0, 300)
	w.fog.reveal(c, 1400.0)
	var kinds: Array = KINDS[_region]
	var cols := 5
	for i in kinds.size():
		var k := str(kinds[i])
		var elite := k.begins_with("E:")
		if elite:
			k = k.substr(2)
		var at := c + Vector2(-500 + (i % cols) * 250, -230 + (i / cols) * 260)
		var e := w.spawn_enemy(k, 10 * _region, at)
		e.elite = elite
		e.state = "idle"
		e.target = e.pos + Vector2(100, 0)
		e.face = 0.0
	var view := WorldView.new()
	root.add_child(view)
	view.set_process(false)
	var cam := Camera2D.new()
	view.add_child(cam)
	view.camera = cam
	cam.position = c + Vector2(0, 30)
	cam.make_current()
	view.world = w
	for i in 14:
		view._process(1.0 / 60.0)
		await process_frame
	root.get_viewport().get_texture().get_image().save_png(_out)
	print("MD1 shot: vùng %d (HD %s) → %s" % [_region, str(_hd), _out])
	SpriteLib.set_hd(true)
	quit()
