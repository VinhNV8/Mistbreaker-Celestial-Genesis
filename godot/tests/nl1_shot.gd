extends SceneTree
## NL-1 (docs/47): chụp Lò Rèn THẬT — tab Gợi ý, Khảm ngọc, Tẩy luyện (so sánh cũ / mới), Thăng phẩm + Luyện cấp,
## Thức tỉnh (chọn 1 trong 3 + đang hiệu lực), Bảo Giám; thẻ đồ có lỗ ngọc / ✦ / Thức Tỉnh / Lực chiến món.
## Cần cửa sổ (không headless).
##   Godot_console.exe --path godot --script res://tests/nl1_shot.gd -- --dir=<thư mục>

const GameWorld = preload("res://scripts/core/game_world.gd")
const Profile = preload("res://scripts/core/profile.gd")
const RngUtil = preload("res://scripts/core/rng_util.gd")
const Items = preload("res://scripts/core/items.gd")
const Gear = preload("res://scripts/core/gear.gd")
const UiTheme = preload("res://scripts/ui/ui_theme.gd")
const ForgePanel = preload("res://scripts/ui/forge_panel.gd")
const ItemCard = preload("res://scripts/ui/item_card.gd")

var _dir := "user://"


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--dir="):
			_dir = a.substr(6)
	_run.call_deferred()


func _shot(name: String) -> void:
	for i in 6:
		await process_frame
	var path := _dir.path_join(name + ".png")
	root.get_viewport().get_texture().get_image().save_png(path)
	print("NL1 shot: ", path)


func _run() -> void:
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	root.size = Vector2i(1366, 768)
	root.theme = UiTheme.get_theme()
	var p := Profile.new()
	p.setup("tay-nhanh", RngUtil.make(7), 0.0)
	p.quest_step = 12
	p.class_id = "kiem-khach"
	p.level = 62
	p.gold = 250000
	p.stones = 80
	p.tinh_kim = 12
	p.crystal = 30.0
	p.essence = 60
	p.void_cores = 3
	p.job3 = "kiem-than"
	p.unlocked_maps = ["1-1", "2-1", "3-1", "4-1", "5-1"]
	var w := GameWorld.new(p, RngUtil.make(5))
	w.enemies = []
	var rng := RngUtil.make(9)
	for s in ["weapon", "helm", "armor", "gloves", "boots", "necklace", "ring", "amulet"]:
		p.equipment[s] = Items.new_item(p, 60, "purple", rng, s, "cuc_quang" if s in ["boots", "gloves"] else "")
	var wp: Dictionary = p.equipment.weapon
	wp.plus = 13
	wp.gems = ["kim:6", "kim:5"]
	p.equipment.helm.gems = ["tho:4"]
	p.equipment.armor.plus = 12
	p.equipment.armor.awaken = {"id": "boss", "tier": 3, "spent": 35, "offer": []}
	p.equipment.ring.reforged = 1
	p.equipment.gloves.level = 45
	p.gem_bag = {"kim:3": 4, "moc:2": 2, "thuy:1": 5, "hoa:7": 1, "tho:4": 1, "moc:9": 1}
	for r in ["blue", "blue", "green", "purple", "orange", "white"]:
		Items.add_item(p, Items.new_item(p, 58, r, rng, "necklace" if r == "blue" else ""))
	for u in ["wolf_fang", "huyen_anh_mask", "long_tam"]:
		Items.add_item(p, Items.new_item(p, 40, "orange", rng, "", "", u))
	for s in ["weapon", "helm", "armor", "boots", "gloves", "ring"]:
		Items.codex_item(p, Items.new_item(p, 40, "purple", rng, s, "frost_hunter"))
	Items.codex_add(p, "p:weapon:10")
	Items.codex_add(p, "p:weapon:13")
	Items.codex_add(p, "g:hoa:7")
	w._refresh_stats()
	var fp = ForgePanel.new()
	root.add_child(fp)
	fp.open_tab(w, "tips")
	await _shot("nl1-goi-y")
	fp._item_id = int(wp.id)
	fp.tab = "gems"
	fp.refresh()
	await _shot("nl1-kham-ngoc")
	fp._item_id = int(p.equipment.ring.id)
	fp.tab = "reforge"
	fp.refresh()
	await _shot("nl1-tay-luyen")
	w.reforge(int(p.equipment.ring.id), 1, "swap")
	fp.refresh()
	await _shot("nl1-tay-luyen-chon")
	w.reforge_keep(int(p.equipment.ring.id), true)
	var neck := p.inventory.filter(func(x): return x.rarity == "blue" and x.slot == "necklace")
	fp._item_id = int(neck[0].id)
	fp.tab = "ascend"
	fp.refresh()
	await _shot("nl1-thang-pham")
	fp._item_id = int(p.equipment.gloves.id)
	fp.refresh()
	await _shot("nl1-luyen-cap")
	var hl: Dictionary = p.equipment.helm
	hl.plus = 12
	fp._item_id = int(hl.id)
	fp.tab = "awaken"
	fp.refresh()
	w.awaken(int(hl.id))
	fp.refresh()
	await _shot("nl1-thuc-tinh")
	fp.tab = "codex"
	fp.refresh()
	await _shot("nl1-bao-giam")
	fp.close()
	# thẻ đồ
	var bg := ColorRect.new()
	bg.color = Color("#1a1410")
	bg.size = Vector2(1366, 768)
	root.add_child(bg)
	var row := HBoxContainer.new()
	row.position = Vector2(20, 20)
	row.add_theme_constant_override("separation", 20)
	root.add_child(row)
	for it in [wp, p.equipment.armor, p.equipment.ring]:
		var pc := PanelContainer.new()
		pc.add_child(ItemCard.build(it, 300.0, "ĐANG MẶC", p))
		row.add_child(pc)
	await _shot("nl1-the-do")
	quit()
