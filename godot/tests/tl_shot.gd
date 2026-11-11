extends SceneTree
## Chụp bảng Thiên phú (phím T) ở trường hợp nặng: Thiên phú chính đã tiến hoá + 2 Thiên phú phụ + nhiều dòng trạng thái.
## Cần cửa sổ (không headless).
##   Godot_console.exe --path godot --script res://tests/tl_shot.gd -- --out=<file.png> [--talent=dao-tac] [--size=1366x768]

const GameWorld = preload("res://scripts/core/game_world.gd")
const Profile = preload("res://scripts/core/profile.gd")
const RngUtil = preload("res://scripts/core/rng_util.gd")
const UiTheme = preload("res://scripts/ui/ui_theme.gd")
const TalentPanel = preload("res://scripts/ui/talent_panel.gd")

var _out := "user://tl_shot.png"
var _talent := "dao-tac"
var _size := Vector2i(1366, 768)
var _subs := 2


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--out="):
			_out = a.substr(6)
		elif a.begins_with("--talent="):
			_talent = a.substr(9)
		elif a.begins_with("--subs="):
			_subs = int(a.substr(7))
		elif a.begins_with("--size="):
			var s := a.substr(7).split("x")
			_size = Vector2i(int(s[0]), int(s[1]))
	_run.call_deferred()


func _run() -> void:
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	root.size = _size
	root.theme = UiTheme.get_theme()
	var p := Profile.new()
	p.setup(_talent, RngUtil.make(7), 0.0, "kiem-khach")
	p.level = 64
	p.job = "x"
	p.talent_level = 10
	p.evo = 1
	p.essence = 40
	p.starwater = 2
	p.evo_essence = 1
	p.potions = 12
	p.herbs = 5
	p.copied_skills = ["wolf_howl", "spore", "frost_nova"]
	for k in ["wolf", "mushroom", "frost_wolf", "spirit", "bat", "slime", "golem", "wolf_king"]:
		p.steal_log[k] = 3
	var subs := [{"id": "hap-huyet", "level": 7}, {"id": "ngu-hanh", "level": 10}]
	p.subs = subs.slice(0, _subs)
	var w := GameWorld.new(p, RngUtil.make(5))
	var bg := ColorRect.new()
	bg.color = Color("#2a3a2a")
	bg.size = Vector2(_size)
	root.add_child(bg)
	var tp = TalentPanel.new()
	root.add_child(tp)
	await process_frame
	tp.open(w)
	for i in 6:
		await process_frame
	var r: Rect2 = tp.box.get_global_rect()
	print("TL shot box: ", r, " viewport ", _size, " overflow=", r.position.y < 0 or r.end.y > _size.y or r.position.x < 0 or r.end.x > _size.x)
	root.get_viewport().get_texture().get_image().save_png(_out)
	print("TL shot: ", _out)
	quit()
