extends SceneTree
## EN-1 (docs/43): ảnh ô đồ cường hoá THẬT (InventoryPanel._item_button + EnhanceFx) ở 64 px và 44 px, vũ khí Tím / giáp Cam,
## +0 +3 +4 +6 +7 +9 +10 +12 +13 +15. Chụp nhiều khung cách nhau ~0,35 giây. Cần cửa sổ (không headless).
##   Godot_console.exe --path godot --script res://tests/enh_now.gd -- --out=<prefix>   → <prefix>-1.png, -2.png, -3.png
const InventoryPanel = preload("res://scripts/ui/inventory_panel.gd")
const UiTheme = preload("res://scripts/ui/ui_theme.gd")
var _out := "user://enh_now"

func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--out="):
			_out = a.substr(6)
	_run.call_deferred()

func _row(panel, grid: GridContainer, rarity: String, slot: String, px: float, pl: Array) -> void:
	for i in pl.size():
		var it := {"id": 7 + i, "slot": slot, "style": "", "rarity": rarity, "set": "", "unique": "", "plus": pl[i], "level": 30, "affixes": []}
		var b: Button = panel._item_button(it, "", false, "")
		b.custom_minimum_size = Vector2(px, px)
		b.expand_icon = true
		b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		grid.add_child(b)

func _run() -> void:
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	root.size = Vector2i(780, 330)
	root.theme = UiTheme.get_theme()
	var bg := ColorRect.new()
	bg.color = Color("#17120d")
	bg.size = Vector2(root.size)
	root.add_child(bg)
	var panel = InventoryPanel.new()
	var pl := [0, 3, 4, 6, 7, 9, 10, 12, 13, 15]
	for i in pl.size():
		var l := Label.new()
		l.text = "+%d" % pl[i]
		l.position = Vector2(30 + i * 74, 8)
		root.add_child(l)
	var g := GridContainer.new()
	g.columns = 10
	g.position = Vector2(14, 34)
	g.add_theme_constant_override("h_separation", 10)
	g.add_theme_constant_override("v_separation", 12)
	root.add_child(g)
	_row(panel, g, "purple", "weapon", 64, pl)
	_row(panel, g, "orange", "armor", 64, pl)
	var g2 := GridContainer.new()
	g2.columns = 10
	g2.position = Vector2(14, 200)
	g2.add_theme_constant_override("h_separation", 30)
	g2.add_theme_constant_override("v_separation", 10)
	root.add_child(g2)
	_row(panel, g2, "blue", "helm", 44, pl)
	_row(panel, g2, "green", "boots", 44, pl)
	for i in 10:
		await process_frame
	for shot in 3:
		await create_timer(0.35).timeout
		await process_frame
		root.get_viewport().get_texture().get_image().save_png("%s-%d.png" % [_out, shot + 1])
	print("ok ", _out)
	quit()
