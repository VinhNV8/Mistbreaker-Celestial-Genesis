extends SceneTree
## IC-1 (docs/37): ảnh thanh kỹ năng THẬT của game (ui/skill_bar.gd), icon lấy qua SpriteLib.icon như HUD:
## hàng trên tắt "Đồ hoạ HD" (icon cũ), hàng dưới bật (IC-1, lớp phủ manifest.hd.icons). Cần cửa sổ (không headless).
##   Godot_console.exe --path godot --script res://tests/ic1_bar.gd -- --out=<file.png>

const SkillBar = preload("res://scripts/ui/skill_bar.gd")
const SpriteLib = preload("res://scripts/view/sprite_lib.gd")
const Classes = preload("res://scripts/data/classes.gd")
const UiTheme = preload("res://scripts/ui/ui_theme.gd")

var _out := "user://ic1_bar.png"


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--out="):
			_out = a.substr(6)
	_run.call_deferred()


func _run() -> void:
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED  # ảnh chụp đúng 1:1, không theo co giãn của project
	root.size = Vector2i(1600, 1420)
	var bg := ColorRect.new()
	bg.color = Color("#141820")
	bg.size = Vector2(root.size)
	root.add_child(bg)
	var y := 8.0
	for cls in Classes.ORDER:
		var skills: Array = Classes.DEFS[cls].skills
		for half in 2:
			for row in 2:
				var lab := Label.new()
				lab.text = "%s %s — %s" % [Classes.DEFS[cls].name, "1–7" if half == 0 else "8–14", "HD tắt (icon cũ)" if row == 0 else "HD bật (IC-1)"]
				lab.position = Vector2(8 + half * 790, y + row * 74 + 16)
				lab.add_theme_font_size_override("font_size", 13)
				root.add_child(lab)
				var bar = SkillBar.new()
				bar.position = Vector2(8 + half * 790 + 200, y + row * 74)
				root.add_child(bar)
				bar.set_count(7)
				for i in 7:
					var k: int = half * 7 + i
					if k >= skills.size():
						bar.set_slot(i, {"hidden": true})
						continue
					var ic := str(skills[k].icon)
					SpriteLib.set_hd(row == 1)
					var tex: Texture2D = SpriteLib.icon("skill-" + ic)
					bar.set_slot(i, {"key": str(i + 1), "name": str(skills[k].name), "icon": tex, "cd": 0.0})
		y += 278.0
	SpriteLib.set_hd(true)
	for i in 6:
		await process_frame
	root.get_viewport().get_texture().get_image().save_png(_out)
	print("IC1 bar: ", _out)
	quit()
