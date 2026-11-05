extends SceneTree
## IC-2 (docs/37 §7–8): chụp 20 icon Thiên phú + icon trang bị + tài nguyên + chỉ số qua SpriteLib (lớp phủ HD, mipmap + Linear) ở 64 và 32 px. Cần cửa sổ.
##   Godot_console.exe --path godot --script res://tests/ic2_grid.gd -- --out=<file.png>
const SL = preload("res://scripts/view/sprite_lib.gd")
const Talents = preload("res://scripts/data/talents.gd")
var _out := "user://ic2_grid.png"


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--out="):
			_out = a.substr(6)
	_run.call_deferred()


func _run() -> void:
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	root.size = Vector2i(1500, 920)
	var bg := ColorRect.new()
	bg.color = Color("#1c1826")
	bg.size = Vector2(1500, 920)
	root.add_child(bg)
	SL.set_hd(true)
	var ids: Array = []
	for t in Talents.LIST:
		ids.append("talent-" + str(t.id))
	for k in SL.data().icons:
		if str(k).begins_with("item-"):
			ids.append(str(k))
	for k in SL.data().icons:
		if str(k).begins_with("res-") or str(k).begins_with("stat-"):
			ids.append(str(k))
	for i in ids.size():
		var tex: Texture2D = SL.icon(ids[i])
		for big in [true, false]:
			var r := TextureRect.new()
			r.texture = tex
			r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			r.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			r.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
			var col := i % 20
			var row := i / 20
			if big:
				r.size = Vector2(64, 64)
				r.position = Vector2(10 + col * 74, 10 + row * 180)
			else:
				r.size = Vector2(32, 32)
				r.position = Vector2(26 + col * 74, 84 + row * 180)
			bg.add_child(r)
	for i in 6:
		await process_frame
	root.get_viewport().get_texture().get_image().save_png(_out)
	print("IC2 grid: ", _out)
	quit()
