extends SceneTree
## EQ-HD (docs/40): ảnh túi đồ THẬT (ô đồ dựng bằng InventoryPanel._item_button như trong game, icon qua
## SpriteLib.item_icon): 5 lớp × 30 món ngẫu nhiên (phẩm chất theo bảng rơi, ~25% thuộc bộ); mỗi lớp 2 hàng ô —
## trái: tắt "Đồ hoạ HD" (icon cũ), phải: bật (EQ-HD). Cần cửa sổ (không headless).
##   Godot_console.exe --path godot --script res://tests/eq_bag.gd -- --out=<file.png>

const InventoryPanel = preload("res://scripts/ui/inventory_panel.gd")
const SpriteLib = preload("res://scripts/view/sprite_lib.gd")
const Classes = preload("res://scripts/data/classes.gd")
const ItemData = preload("res://scripts/data/items.gd")
const UiTheme = preload("res://scripts/ui/ui_theme.gd")

const STYLE := {"kiem-khach": "", "tho-san": "bow", "phap-su": "staff", "ho-ve": "mace", "trieu-hoi-su": "orb"}
const RARITY_W := [["white", 30], ["green", 28], ["blue", 22], ["purple", 13], ["orange", 7]]

var _out := "user://eq_bag.png"


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--out="):
			_out = a.substr(6)
	_run.call_deferred()


func _rarity(rng: RandomNumberGenerator) -> String:
	var r := rng.randi_range(1, 100)
	for p in RARITY_W:
		r -= int(p[1])
		if r <= 0:
			return str(p[0])
	return "white"


func _run() -> void:
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	root.size = Vector2i(1460, 820)
	root.theme = UiTheme.get_theme()
	var bg := ColorRect.new()
	bg.color = Color("#17120d")
	bg.size = Vector2(root.size)
	root.add_child(bg)
	var panel = InventoryPanel.new()
	var rng := RandomNumberGenerator.new()
	rng.seed = 40
	var sets: Array = ItemData.SETS.keys()
	var y := 8.0
	for cls in Classes.ORDER:
		var items := []
		for i in 30:
			var slot: String = ItemData.SLOT_ORDER[rng.randi_range(0, ItemData.SLOT_ORDER.size() - 1)]
			var in_set := rng.randf() < 0.25
			items.append({"id": 100 + i, "slot": slot, "style": STYLE[cls] if slot == "weapon" else "",
				"rarity": "purple" if in_set else _rarity(rng), "set": sets[rng.randi_range(0, sets.size() - 1)] if in_set else "",
				"unique": "", "plus": rng.randi_range(0, 3) if rng.randf() < 0.3 else 0, "level": 10, "affixes": []})
		for half in 2:
			SpriteLib.set_hd(half == 1)
			var lab := Label.new()
			lab.text = "%s — %s" % [Classes.DEFS[cls].name, "HD tắt (icon cũ)" if half == 0 else "HD bật (EQ-HD)"]
			lab.position = Vector2(8 + half * 730, y)
			lab.add_theme_font_size_override("font_size", 13)
			root.add_child(lab)
			var grid := GridContainer.new()
			grid.columns = 15
			grid.position = Vector2(8 + half * 730, y + 20)
			grid.add_theme_constant_override("h_separation", 4)
			grid.add_theme_constant_override("v_separation", 4)
			root.add_child(grid)
			for it in items:
				var b: Button = panel._item_button(it, "", false, "")
				b.custom_minimum_size = Vector2(44, 44)
				b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
				b.expand_icon = true
				grid.add_child(b)
		y += 160.0
	SpriteLib.set_hd(true)
	for i in 8:
		await process_frame
	root.get_viewport().get_texture().get_image().save_png(_out)
	print("EQ bag: ", _out)
	panel.free()
	quit()
