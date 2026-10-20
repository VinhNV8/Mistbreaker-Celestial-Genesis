extends "res://scripts/ui/modal.gd"
## C1-30, C1-32 (phím E ở Làng Thanh Thạch): cửa hàng làng, Thương nhân lữ hành, Xưởng Rèn, bán đồ.

const Items = preload("res://scripts/core/items.gd")
const ItemData = preload("res://scripts/data/items.gd")
const Explore = preload("res://scripts/core/explore.gd")
const SpriteLib = preload("res://scripts/view/sprite_lib.gd")
const GameWorld = preload("res://scripts/core/game_world.gd")
const BulkBox = preload("res://scripts/ui/bulk_box.gd")

const W := 860.0
var _sell_id := -1


func _render(content: VBoxContainer) -> void:
	var p = world.profile
	content.custom_minimum_size.x = W
	var town: bool = world.map_id == "2-1"
	_header(content, ("Thành Biên Đài · Cửa hàng" if town else "Làng Thanh Thạch · Cửa hàng"), "Đóng (E)")
	content.add_child(UiTheme.label("Vàng %d · Đá Cường Hoá %d · Bình máu %d/%d · Túi %d/%d" % [
		int(p.gold), p.stones, p.potions, GameWorld.POTION_MAX, p.inventory.size(), ItemData.BAG_SIZE], "Muted", W))
	var body := UiTheme.hbox(24)
	content.add_child(body)
	var left := UiTheme.vbox(8)
	left.custom_minimum_size.x = 400
	body.add_child(left)
	var right := UiTheme.vbox(8)
	right.custom_minimum_size.x = 420
	body.add_child(right)

	# --- cửa hàng làng
	left.add_child(UiTheme.label("THƯƠNG NHÂN MẠC TAM" if town else "THƯƠNG NHÂN LÀNG", "Eyebrow"))
	for row in [["potion", "res-potion", "Bình máu", GameWorld.SHOP_POTION], ["stone", "res-stone", "Đá Cường Hoá", GameWorld.SHOP_STONE]]:
		var h := UiTheme.hbox(8)
		h.add_child(_icon(SpriteLib.icon(row[1])))
		var l := UiTheme.label("%s — %d vàng" % [row[2], row[3]])
		l.size_flags_horizontal = SIZE_EXPAND_FILL
		h.add_child(l)
		var b := UiTheme.button("Mua")
		b.name = "Buy_" + row[0]
		b.disabled = p.gold < row[3]
		var kind: String = row[0]
		b.pressed.connect(func():
			world.shop_buy(kind)
			refresh())
		h.add_child(b)
		left.add_child(h)

	# --- Thương nhân lữ hành
	left.add_child(HSeparator.new())
	left.add_child(UiTheme.label("THƯƠNG NHÂN LỮ HÀNH", "Eyebrow"))
	if world.merchant_active():
		var left_s: int = int(world.merchant_left())
		left.add_child(UiTheme.label("Còn ở lại %d phút." % ceili(left_s / 60.0), "Small"))
		var items: Array = p.merchant.items
		for i in items.size():
			var it: Dictionary = items[i]
			var h := UiTheme.hbox(8)
			h.add_child(_icon(SpriteLib.item_icon(it)))
			var l := UiTheme.label("%s — %d vàng" % [Items.display_name(it), int(it.price)], "", 260)
			l.add_theme_color_override("font_color", Items.rarity_color(it))
			l.size_flags_horizontal = SIZE_EXPAND_FILL
			h.add_child(l)
			var b := UiTheme.button("Mua")
			b.disabled = p.gold < int(it.price)
			var idx: int = i
			b.pressed.connect(func():
				world.buy_merchant(idx)
				refresh())
			h.add_child(b)
			left.add_child(h)
	else:
		left.add_child(UiTheme.label("Chưa có. Tìm ô Thương nhân lữ hành trên Bản đồ khai phá (phím M) rồi mời về làng.", "Small", 400))

	# --- M4.3 (TB-11): Thợ rèn Thiết Ngưu đổi Đá, Sắt
	if town:
		left.add_child(HSeparator.new())
		left.add_child(UiTheme.label("THỢ RÈN THIẾT NGƯU · Đá %d · Sắt %d" % [int(p.ore), int(p.iron)], "Eyebrow"))
		for row in [["stone", "10 Đá → 1 Đá Cường Hoá", p.ore >= GameWorld.SMITH_STONE_ORE],
				["tinh_kim", "20 Đá + 10 Sắt → 1 Tinh Kim", p.ore >= GameWorld.SMITH_KIM_ORE and p.iron >= GameWorld.SMITH_KIM_IRON]]:
			var h := UiTheme.hbox(8)
			var l := UiTheme.label(row[1])
			l.size_flags_horizontal = SIZE_EXPAND_FILL
			h.add_child(l)
			var b := UiTheme.button("Đổi")
			b.name = "Smith_" + row[0]
			b.disabled = not row[2]
			var kind: String = row[0]
			b.pressed.connect(func():
				world.smith_trade(kind)
				refresh())
			h.add_child(b)
			left.add_child(h)

	# --- Xưởng Rèn
	left.add_child(HSeparator.new())
	left.add_child(UiTheme.label("XƯỞNG RÈN", "Eyebrow"))
	if Explore.is_built(p, "forge"):
		left.add_child(UiTheme.label("Chế 1 món cấp %d: %d vàng + %d Đá. Xanh lá 60%% · Xanh dương 35%% · Tím 5%%." % [
			p.level, world.forge_cost(), GameWorld.FORGE_STONES], "Small", 400))
		var grid := GridContainer.new()
		grid.columns = 4
		for slot in ItemData.SLOT_ORDER:
			var b := UiTheme.button(ItemData.SLOTS[slot].name)
			b.name = "Forge_" + slot
			b.icon = SpriteLib.icon("item-" + slot)
			b.custom_minimum_size = Vector2(96, 40)
			b.add_theme_font_size_override("font_size", 12)
			b.disabled = p.gold < world.forge_cost() or p.stones < GameWorld.FORGE_STONES
			var s: String = slot
			b.pressed.connect(func():
				world.forge_craft(s)
				refresh())
			grid.add_child(b)
		left.add_child(grid)
	else:
		left.add_child(UiTheme.label("Chưa xây. Xây Xưởng Rèn ở mục Công trình trên Bản đồ khai phá (150 vàng, 80 gỗ).", "Small", 400))

	# --- bán đồ
	right.add_child(UiTheme.label("BÁN ĐỒ TRONG TÚI", "Eyebrow"))
	right.add_child(UiTheme.label("Chọn món rồi bấm Bán. Đồ đang mặc phải tháo ra trước.", "Small", 420))
	var bag := GridContainer.new()
	bag.columns = 6
	bag.add_theme_constant_override("h_separation", 4)
	bag.add_theme_constant_override("v_separation", 4)
	if Items.find_in_bag(p, _sell_id) < 0:
		_sell_id = -1
	for it in p.inventory:
		var b := UiTheme.button("")
		b.icon = SpriteLib.item_icon(it)
		b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		b.custom_minimum_size = Vector2(62, 54)
		var c := Items.rarity_color(it)
		var sel: bool = int(it.id) == _sell_id
		b.add_theme_stylebox_override("normal", UiTheme.box(Color(c, 0.25 if sel else 0.08), 6, 2 if sel else 1, c, 6))
		b.tooltip_text = "%s — bán %d vàng" % [Items.display_name(it), GameWorld.sell_price(it)]
		var id := int(it.id)
		b.pressed.connect(func():
			_sell_id = id
			refresh())
		bag.add_child(b)
	right.add_child(bag)
	if _sell_id >= 0:
		var it: Dictionary = p.inventory[Items.find_in_bag(p, _sell_id)]
		var sb := UiTheme.button("Bán %s (+%d vàng)" % [Items.display_name(it), GameWorld.sell_price(it)], true)
		sb.name = "SellButton"
		sb.pressed.connect(func():
			world.sell_item(_sell_id)
			_sell_id = -1
			refresh())
		right.add_child(sb)
	# SN-12: bán nhanh theo bộ lọc
	right.add_child(HSeparator.new())
	right.add_child(BulkBox.build(world, "sell", refresh, 420.0))


func _icon(tex: Texture2D) -> TextureRect:
	var ic := TextureRect.new()
	ic.texture = tex
	ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	ic.custom_minimum_size = Vector2(32, 32)
	return ic
