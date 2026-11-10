extends SceneTree
## CR-04 (docs/CR-04): chụp Túi đồ THẬT với khung dưới "Tự động" / "Mua lại" / "Bán nhanh", món đang chọn có nút Bán / Khoá,
## ô đã khoá có ổ khoá, thẻ đồ có dòng giá. Cần cửa sổ (không headless).
##   Godot_console.exe --path godot --script res://tests/cr4_shot.gd -- --dir=<thư mục>

const GameWorld = preload("res://scripts/core/game_world.gd")
const Profile = preload("res://scripts/core/profile.gd")
const RngUtil = preload("res://scripts/core/rng_util.gd")
const Items = preload("res://scripts/core/items.gd")
const UiTheme = preload("res://scripts/ui/ui_theme.gd")
const InventoryPanel = preload("res://scripts/ui/inventory_panel.gd")
const ItemTip = preload("res://scripts/ui/item_tip.gd")

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
	print("CR4 shot: ", path)


func _run() -> void:
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	root.size = Vector2i(1366, 768)
	root.theme = UiTheme.get_theme()
	var p := Profile.new()
	p.setup("tay-nhanh", RngUtil.make(7), 0.0)
	p.quest_step = 12
	p.class_id = "kiem-khach"
	p.level = 22
	p.gold = 4850
	var w := GameWorld.new(p, RngUtil.make(5))
	w.enemies = []
	var rng := RngUtil.make(9)
	for s in ["weapon", "helm", "armor", "gloves", "boots", "necklace", "ring", "amulet"]:
		p.equipment[s] = Items.new_item(p, 20, "purple", rng, s)
	var rar := ["white", "green", "blue", "white", "green", "purple", "blue", "white", "orange", "green", "white", "blue",
		"green", "white", "purple", "white", "blue", "green"]
	for r in rar:
		var it := Items.new_item(p, 14 + int(rng.call() * 8), r, rng)
		Items.add_item(p, it)
	p.inventory[3]["plus"] = 5
	p.inventory[6]["locked"] = true
	w._refresh_stats()
	# bán vài món để có danh sách mua lại
	for i in 3:
		var it := Items.new_item(p, 18, ["white", "green", "blue"][i], rng)
		Items.add_item(p, it)
		w.sell_item(int(it.id))
	w.set_loot_rules({"mode": "pickup", "by_rarity": Items.LOOT_PRESETS.balanced[1].duplicate()})
	w.loot_stats = {"sold": 47, "gold": 1320, "salvaged": 18, "stones": 41}
	var inv = InventoryPanel.new()
	root.add_child(inv)
	inv.open(w)
	inv._selected_id = int(p.inventory[0].id)
	inv._bottom = "auto"
	inv.refresh()
	await _shot("cr4-tui-tu-dong")
	# TD-17 (U3): trang Nâng cao
	var LootBox = load("res://scripts/ui/loot_box.gd")
	var rr: Dictionary = w.loot_rules()
	rr.by_slot.amulet = "sell"
	rr.by_slot.ring = "keep"
	rr.keep_stats = ["crit", "atk_speed"]
	w.set_loot_rules(rr)
	LootBox.advanced = true
	inv.refresh()
	await _shot("cr4-tui-nang-cao")
	LootBox.advanced = false
	inv._bottom = "buyback"
	inv._selected_id = int(p.inventory[6].id)
	inv.refresh()
	await _shot("cr4-tui-mua-lai")
	inv._bottom = "sell"
	inv._selected_id = int(p.inventory[5].id)
	inv._confirm = {"id": int(p.inventory[5].id), "act": "sell"}
	inv.refresh()
	await _shot("cr4-tui-ban-nhanh")
	inv._confirm = {}
	inv.refresh()
	var tip := ItemTip.make(w, p.inventory[1], true)
	root.add_child(tip)
	tip.place(Vector2(300, 120))
	await _shot("cr4-the-do-gia")
	tip.queue_free()
	inv.close()
	# R6: tab Bán đồ của cửa hàng làng có Mua lại
	var shop = load("res://scripts/ui/shop_panel.gd").new()
	root.add_child(shop)
	shop.open(w)
	shop.tab = "sell"
	shop.refresh()
	await _shot("cr4-cua-hang-mua-lai")
	quit()
