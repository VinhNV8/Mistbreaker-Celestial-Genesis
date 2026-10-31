extends "res://scripts/ui/modal.gd"
## C1-30, C1-32 (phím E ở làng / nói chuyện người bán). UI-24 (Spec_Notes đợt 8: "Shop design chưa common"):
## bố cục cửa hàng quen thuộc — biển tiêu đề + ô tiền tệ · tab dọc (Tạp hoá / Thương nhân lữ hành / Bán đồ) ·
## lưới thẻ hàng (icon theo phẩm chất, giá, "có N") · khung chi tiết (mô tả, chọn số lượng, tổng tiền, Mua / Bán).
## Xưởng Rèn và thợ rèn đã tách sang Lò Rèn (forge_panel.gd, phím R) — nút "Lò Rèn" ở cột tab.

signal open_forge

const Items = preload("res://scripts/core/items.gd")
const ItemData = preload("res://scripts/data/items.gd")
const SpriteLib = preload("res://scripts/view/sprite_lib.gd")
const GameWorld = preload("res://scripts/core/game_world.gd")
const BulkBox = preload("res://scripts/ui/bulk_box.gd")
const W = preload("res://scripts/ui/shop_widgets.gd")

const GRID_W := 492.0
const DETAIL_W := 300.0
const KEEPERS := {
	"2-1": "Thương nhân Mạc Tam",
	"3-1": "Người dẫn đường A Mộc",
	"4-1": "Lão Ngư · Làng Chài Lau",
	"5-1": "Thương hội Kim Luân · Trại Tro Hồng",
	"6-1": "Thợ săn Lão Hàn · Trạm Tuyết Bạc",
	"7-1": "Thuyền trưởng Phong Linh · Bến Mây",
	"8-1": "Nữ tư tế Tuyết Nga · Tiền Đồn Tinh Quang",
}

## "buy" | "merchant" | "sell"
var tab := "buy"
## Món đang chọn: "potion", "stone"… ở tab Tạp hoá; chỉ số món ở tab Lữ hành; id đồ ở tab Bán.
var _sel := ""
var _qty := 1
var _sell_id := -1


func open(w) -> void:
	_qty = 1
	super.open(w)


func _render(content: VBoxContainer) -> void:
	var p = world.profile
	content.add_theme_constant_override("separation", 12)
	content.add_child(W.title_bar(SpriteLib.icon("res-gold"), "Cửa hàng", "%s · %s" % [str(world.map.safe.name), _keeper()], [
		W.currency("res-gold", int(p.gold), "Vàng"),
		W.currency("res-stone", int(p.stones), "Đá Cường Hoá"),
		W.currency("res-potion", int(p.potions), "Bình máu (tối đa %d)" % GameWorld.POTION_MAX),
		W.currency("res-mp_potion", int(p.mp_potions), "Bình MP"),
	], close, "Đóng (E / Esc)"))
	var body := UiTheme.hbox(12)
	var side := UiTheme.vbox(6)
	var m_badge := ""
	if world.merchant_active():
		m_badge = "%d" % p.merchant.items.size()
	for t in [["buy", "Tạp hoá", "res-potion", ""], ["merchant", "Lữ hành", "item-armor", m_badge],
			["sell", "Bán đồ", "res-gold", "%d" % p.inventory.size() if p.inventory.size() > 0 else ""]]:
		var key: String = t[0]
		side.add_child(W.side_tab(key, t[1], SpriteLib.icon(t[2]), tab == key, func():
			tab = key
			_sel = ""
			_qty = 1
			refresh(), t[3]))
	side.add_child(UiTheme.spacer())
	var fb := W.side_tab("forge", "Lò Rèn (R)", SpriteLib.icon("res-stone"), false, func(): open_forge.emit())
	fb.name = "ForgeButton"
	fb.tooltip_text = "Cường hoá, chế tạo, luyện nguyên liệu, phân rã"
	side.add_child(fb)
	body.add_child(side)
	match tab:
		"merchant":
			_merchant(body, p)
		"sell":
			_sell(body, p)
		_:
			_supplies(body, p)
	content.add_child(body)


func _keeper() -> String:
	return str(KEEPERS.get(world.map_id, "Thương nhân làng"))


# ------------------------------------------------------------------ Tạp hoá


## [kind, icon, tên, giá, đang có, mua tối đa thêm, mô tả]
func _supply_rows(p) -> Array:
	var region := int(world.map.get("region", 1))
	var rows: Array = [
		["potion", "res-potion", "Bình máu", GameWorld.SHOP_POTION, int(p.potions), GameWorld.POTION_MAX - int(p.potions),
			"Phím Q hồi 35%% HP, hồi chiêu 8 giây. Mang tối đa %d bình." % GameWorld.POTION_MAX],
		["mp_potion", "res-mp_potion", "Bình MP", GameWorld.SHOP_MP_POTION, int(p.mp_potions), 99,
			"Phím F hồi 40% MP, hồi chiêu 8 giây (riêng với bình máu). Mang bao nhiêu cũng được. Cũng rơi từ quái, tinh anh và boss."],
		["stone", "res-stone", "Đá Cường Hoá", GameWorld.SHOP_STONE, int(p.stones), 99,
			"Nguyên liệu cường hoá trang bị ở Lò Rèn (phím R). Cũng rơi từ quái, rương và khi phân rã đồ."],
	]
	if region == 4:
		rows.append(["antidote", "res-herb", "Thuốc Giải", GameWorld.Ch4.SHOP_ANTIDOTE, int(p.antidotes), 99,
			"Phím Q khi có từ 3 tầng độc: xoá hết độc (ưu tiên hơn bình máu)."])
		rows.append(["torch", "res-torch", "Đuốc Lửa", GameWorld.Ch4.SHOP_TORCH, int(p.fire_torches), 99,
			"Phím Q cạnh gốc đầu Thất Đầu vừa bị chặt: đốt cháy, đầu không mọc lại."])
	if region == 5:
		rows.append(["holy_water", "res-holy_water", "Bình Nước Thánh", GameWorld.Ch5.SHOP_HOLY, int(p.holy_water), 99,
			"Phím Q khi Phượng Hoàng Tro dưới 15% HP và ở gần: ngăn nó tái sinh."])
	if region == 6:
		rows.append(["ember", "res-ember", "Than Hồng", GameWorld.Ch6.SHOP_EMBER, int(p.embers), 99,
			"Phím Q khi có từ 2 tầng băng giá: xoá hết và miễn băng giá 30 giây."])
	if region == 7:
		rows.append(["feather", "res-feather", "Lông Vũ Gió", GameWorld.Ch7.SHOP_FEATHER, int(p.feathers), 99,
			"Phím Q: lơ lửng 2 giây — không rơi khi ra khỏi mép đảo, tốc chạy +20%."])
	if region == 8:
		rows.append(["lantern", "res-lantern", "Đèn Lồng Tinh Quang", GameWorld.Ch8.SHOP_LANTERN, int(p.lanterns), 99,
			"Phím Q khi Suy Thiên từ 20%: xoá Suy Thiên và miễn Suy Thiên 45 giây."])
	return rows


func _supplies(body: HBoxContainer, p) -> void:
	var rows := _supply_rows(p)
	if _sel == "" or rows.filter(func(r): return r[0] == _sel).is_empty():
		_sel = rows[0][0]
	var sec: Array = W.section(_keeper().to_upper(), GRID_W)
	body.add_child(sec[0])
	var grid := _grid()
	for r in rows:
		var kind: String = r[0]
		grid.add_child(W.item_card(kind, SpriteLib.icon(r[1]), UiTheme.GOLD_DARK if kind != _sel else UiTheme.GOLD, r[2], "res-gold", r[3],
			int(p.gold) >= int(r[3]), kind == _sel, func():
				_sel = kind
				_qty = 1
				refresh(), "có %d" % int(r[4])))
	sec[1].add_child(grid)
	var row: Array = rows.filter(func(x): return x[0] == _sel)[0]
	# chi tiết
	var det: Array = W.section("", DETAIL_W)
	body.add_child(det[0])
	var col: VBoxContainer = det[1]
	_detail_head(col, SpriteLib.icon(row[1]), str(row[2]), UiTheme.TEXT, "Đang có: %d" % int(row[4]))
	col.add_child(UiTheme.label(str(row[6]), "", DETAIL_W))
	col.add_child(UiTheme.spacer())
	var afford := int(p.gold) / maxi(1, int(row[3]))
	var max_n := clampi(mini(afford, int(row[5])), 0, 99)
	_qty = clampi(_qty, 1, maxi(1, max_n))
	col.add_child(HSeparator.new())
	col.add_child(UiTheme.label("Số lượng", "Small"))
	col.add_child(W.qty_box(_qty, max_n, func(n: int):
		_qty = n
		refresh()))
	var total := _qty * int(row[3])
	col.add_child(_total_line("Tổng", total, int(p.gold) >= total))
	var b := UiTheme.button("Mua ×%d" % _qty, true)
	b.name = "Buy_" + str(row[0])
	b.custom_minimum_size = Vector2(0, 46)
	b.disabled = max_n <= 0
	var kind: String = row[0]
	b.pressed.connect(func():
		for i in _qty:
			if not bool(world.shop_buy(kind).get("ok", false)):
				break
		_qty = 1
		refresh())
	col.add_child(b)
	if max_n <= 0:
		var why := UiTheme.label("Đã mang tối đa." if int(row[5]) <= 0 else "Không đủ vàng.", "Small")
		why.add_theme_color_override("font_color", W.SHORT)
		col.add_child(why)


# ------------------------------------------------------------------ Thương nhân lữ hành


func _merchant(body: HBoxContainer, p) -> void:
	var sec: Array = W.section("THƯƠNG NHÂN LỮ HÀNH", GRID_W)
	body.add_child(sec[0])
	var det: Array = W.section("", DETAIL_W)
	body.add_child(det[0])
	if not world.merchant_active():
		sec[1].add_child(UiTheme.label("Thương nhân chưa tới. Tìm ô Thương nhân lữ hành trên Bản đồ khai phá (phím M) rồi mời về làng.", "Muted", GRID_W))
		det[1].add_child(UiTheme.label("Thương nhân bán vài món trang bị ngẫu nhiên, ở lại một thời gian rồi đi.", "Small", DETAIL_W))
		return
	var timer := UiTheme.label("Còn ở lại %d phút" % ceili(int(world.merchant_left()) / 60.0), "Small")
	timer.add_theme_color_override("font_color", UiTheme.GOLD)
	sec[1].add_child(timer)
	var items: Array = p.merchant.items
	if items.is_empty():
		sec[1].add_child(UiTheme.label("Đã bán hết hàng.", "Muted"))
		det[1].add_child(UiTheme.label("Chọn một món để xem chi tiết.", "Muted", DETAIL_W))
		return
	var idx := clampi(int(_sel) if _sel.is_valid_int() else 0, 0, items.size() - 1)
	_sel = str(idx)
	var grid := _grid()
	for i in items.size():
		var it: Dictionary = items[i]
		var k := i
		grid.add_child(W.item_card("m%d" % i, SpriteLib.item_icon(it), Items.rarity_color(it), Items.display_name(it), "res-gold", int(it.price),
			int(p.gold) >= int(it.price), i == idx, func():
				_sel = str(k)
				refresh(), "Cấp %d" % int(it.level)))
	sec[1].add_child(grid)
	var item: Dictionary = items[idx]
	var col: VBoxContainer = det[1]
	_item_detail(col, item)
	var delta: int = world.power_if_equipped(item) - world.combat_power()
	var cmp := UiTheme.label("Mặc vào: Lực chiến %s%d" % ["+" if delta >= 0 else "", delta], "Small")
	cmp.add_theme_color_override("font_color", UiTheme.GOOD if delta >= 0 else UiTheme.BAD)
	col.add_child(cmp)
	col.add_child(UiTheme.spacer())
	col.add_child(HSeparator.new())
	col.add_child(_total_line("Giá", int(item.price), int(p.gold) >= int(item.price)))
	var b := UiTheme.button("Mua", true)
	b.name = "BuyMerchant"
	b.custom_minimum_size = Vector2(0, 46)
	b.disabled = int(p.gold) < int(item.price) or p.inventory.size() >= ItemData.BAG_SIZE
	b.pressed.connect(func():
		world.buy_merchant(idx)
		_sel = ""
		refresh())
	col.add_child(b)


# ------------------------------------------------------------------ Bán đồ


func _sell(body: HBoxContainer, p) -> void:
	var sec: Array = W.section("TÚI ĐỒ · %d/%d" % [p.inventory.size(), ItemData.BAG_SIZE], GRID_W)
	body.add_child(sec[0])
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(GRID_W, 240)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var bag := GridContainer.new()
	bag.columns = 7
	bag.add_theme_constant_override("h_separation", 6)
	bag.add_theme_constant_override("v_separation", 6)
	if Items.find_in_bag(p, _sell_id) < 0:
		_sell_id = -1
	for it in p.inventory:
		var b := UiTheme.button("")
		b.icon = SpriteLib.item_icon(it)
		b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		b.expand_icon = true
		b.custom_minimum_size = Vector2(62, 62)
		var c := Items.rarity_color(it)
		var sel: bool = int(it.id) == _sell_id
		var normal := UiTheme.box(Color(c, 0.3 if sel else 0.08), 6, 2 if sel else 1, c.lightened(0.3) if sel else c, 6)
		b.add_theme_stylebox_override("normal", normal)
		b.add_theme_stylebox_override("pressed", normal)
		b.add_theme_stylebox_override("hover", UiTheme.box(Color(c, 0.3), 6, 2, c.lightened(0.3), 6))
		b.tooltip_text = "%s — bán %d vàng" % [Items.display_name(it), GameWorld.sell_price(it)]
		var id := int(it.id)
		b.pressed.connect(func():
			_sell_id = id
			refresh())
		bag.add_child(b)
	if p.inventory.is_empty():
		bag.add_child(UiTheme.label("Túi trống.", "Muted"))
	scroll.add_child(bag)
	sec[1].add_child(scroll)
	sec[1].add_child(HSeparator.new())
	sec[1].add_child(BulkBox.build(world, "sell", refresh, GRID_W))
	var det: Array = W.section("", DETAIL_W)
	body.add_child(det[0])
	var col: VBoxContainer = det[1]
	if _sell_id < 0:
		col.add_child(UiTheme.label("Chọn món trong túi để bán. Đồ đang mặc phải tháo ra trước.", "Muted", DETAIL_W))
		return
	var item: Dictionary = p.inventory[Items.find_in_bag(p, _sell_id)]
	_item_detail(col, item)
	col.add_child(UiTheme.spacer())
	col.add_child(HSeparator.new())
	col.add_child(_total_line("Bán được", GameWorld.sell_price(item), true))
	var sb := UiTheme.button("Bán", true)
	sb.name = "SellButton"
	sb.custom_minimum_size = Vector2(0, 46)
	sb.pressed.connect(func():
		world.sell_item(_sell_id)
		_sell_id = -1
		refresh())
	col.add_child(sb)


# ------------------------------------------------------------------ chung


func _grid() -> GridContainer:
	var g := GridContainer.new()
	g.columns = 3
	g.add_theme_constant_override("h_separation", 8)
	g.add_theme_constant_override("v_separation", 8)
	return g


func _detail_head(col: VBoxContainer, icon: Texture2D, title: String, color: Color, sub: String) -> void:
	var h := UiTheme.hbox(10)
	var fr := UiTheme.panel(UiTheme.box(Color("#0b0805"), 8, 2, color if color != UiTheme.TEXT else UiTheme.GOLD_DARK, 6))
	fr.add_child(UiTheme.icon_rect(icon, 64))
	h.add_child(fr)
	var v := UiTheme.vbox(2)
	var t := UiTheme.strong(title, 18, color)
	t.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	t.custom_minimum_size.x = DETAIL_W - 100
	v.add_child(t)
	v.add_child(UiTheme.label(sub, "Small"))
	h.add_child(v)
	col.add_child(h)
	col.add_child(HSeparator.new())


func _item_detail(col: VBoxContainer, item: Dictionary) -> void:
	var rarity: Dictionary = ItemData.RARITIES[item.rarity]
	_detail_head(col, SpriteLib.item_icon(item), Items.display_name(item), Items.rarity_color(item),
		"%s · %s · Cấp %d" % [rarity.name, ItemData.SLOTS[item.slot].name, int(item.level)])
	col.add_child(UiTheme.label(Items.base_text(item) + "  (gốc)"))
	for af in item.affixes:
		var l := UiTheme.label(Items.stat_text(af.stat, af.value))
		l.add_theme_color_override("font_color", Color("#9ec8ff"))
		col.add_child(l)
	if item.unique != "":
		var u := UiTheme.label(ItemData.UNIQUES[item.unique].text, "", DETAIL_W)
		u.add_theme_color_override("font_color", Items.rarity_color(item))
		col.add_child(u)
	if item.set != "":
		var s := UiTheme.label("Bộ: %s" % ItemData.SETS[item.set].name, "Small")
		s.add_theme_color_override("font_color", Color("#9be08a"))
		col.add_child(s)


func _total_line(label: String, amount: int, ok: bool) -> HBoxContainer:
	var h := UiTheme.hbox(6)
	h.add_child(UiTheme.label(label, "Small"))
	h.add_child(UiTheme.spacer())
	h.add_child(UiTheme.icon_rect(SpriteLib.icon("res-gold"), 22))
	var l := UiTheme.strong(W.group(amount), 20, Color("#ffd877") if ok else W.SHORT)
	l.name = "TotalLabel"
	h.add_child(l)
	return h
