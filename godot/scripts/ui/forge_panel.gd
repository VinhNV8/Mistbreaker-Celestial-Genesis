extends "res://scripts/ui/modal.gd"
## UI-25 (Spec_Notes đợt 8: "Xưởng rèn nên tách ra khỏi shop"; "cường hoá không hiện tốn bao nhiêu"):
## Lò Rèn riêng (phím R, nói chuyện Thợ rèn Thiết Ngưu, hoặc nút "Lò Rèn" ở Cửa hàng). 4 tab dọc:
## Cường hoá (chọn món · +N → +N+1 · tỉ lệ · ô chi phí cần/có · bảng chi phí mọi cấp),
## Chế tạo (Xưởng Rèn), Luyện nguyên liệu (Thiết Ngưu, Tinh Thạch → Tinh Kim), Phân rã.
## NL-1 (docs/47 §5): thêm Khảm ngọc, Tẩy luyện, Thăng phẩm (+ Luyện cấp), Thức tỉnh, Bảo Giám, Gợi ý Lực chiến
## (ui/forge_gear.gd). Tab chưa mở vẫn hiện, bấm vào thấy điều kiện mở.

const Items = preload("res://scripts/core/items.gd")
const ItemData = preload("res://scripts/data/items.gd")
const Explore = preload("res://scripts/core/explore.gd")
const SpriteLib = preload("res://scripts/view/sprite_lib.gd")
const GameWorld = preload("res://scripts/core/game_world.gd")
const Maps = preload("res://scripts/data/maps.gd")
const BulkBox = preload("res://scripts/ui/bulk_box.gd")
const W = preload("res://scripts/ui/shop_widgets.gd")
const Inv = preload("res://scripts/ui/inventory_panel.gd")
const ForgeGear = preload("res://scripts/ui/forge_gear.gd")
const Gear = preload("res://scripts/core/gear.gd")

const TABS := [
	["tips", "Gợi ý", "stat-atk"],
	["enhance", "Cường hoá", "res-stone"],
	["gems", "Khảm ngọc", "gem-kim-2"],
	["reforge", "Tẩy luyện", "res-crystal"],
	["ascend", "Thăng phẩm", "item-armor"],
	["awaken", "Thức tỉnh", "res-essence"],
	["codex", "Bảo Giám", "stat-set"],
	["craft", "Chế tạo", "item-weapon"],
	["refine", "Luyện nguyên liệu", "res-tinh_kim"],
	["salvage", "Phân rã", "res-ore"],
]
const SLOT_ROW := ["weapon", "armor", "helm", "boots", "gloves", "necklace", "ring", "amulet"]
const CENTER_W := 360.0
const TABLE_W := 270.0
const PICK_W := 266.0

## "tips" | "enhance" | "gems" | "reforge" | "ascend" | "awaken" | "codex" | "craft" | "refine" | "salvage"
var tab := "enhance"
var _item_id := -1
## NL-1: dòng phụ đang chọn (Tẩy luyện), món nguyên liệu (Thăng phẩm).
var _affix_idx := 0
var _mat_id := -1
var _craft_slot := "weapon"
var _last_craft := {}


func open_tab(w, t: String) -> void:
	tab = t
	open(w)


## Mở từ Túi đồ: chọn sẵn món đang xem.
func select_item(id: int) -> void:
	if id >= 0:
		_item_id = id


func _render(content: VBoxContainer) -> void:
	var p = world.profile
	content.add_theme_constant_override("separation", 12)
	content.add_child(W.title_bar(SpriteLib.icon("item-weapon"), "Lò Rèn", "Cường hoá · khảm ngọc · tẩy luyện · thăng phẩm · thức tỉnh · chế tạo", [
		W.currency("res-gold", int(p.gold), "Vàng"),
		W.currency("res-stone", int(p.stones), "Đá Cường Hoá"),
		W.currency("res-tinh_kim", int(p.tinh_kim), "Tinh Kim"),
	], close, "Đóng (R / Esc)"))
	var body := UiTheme.hbox(12)
	var side := UiTheme.vbox(6)
	side.add_theme_constant_override("separation", 4)
	for t in TABS:
		var key: String = t[0]
		var badge := ""
		if key == "tips":
			var n: int = world.power_tips().size()
			badge = str(n) if n > 0 else ""
		var st := W.side_tab(key, t[1], SpriteLib.icon(t[2]), tab == key, func():
			tab = key
			refresh(), badge)
		st.custom_minimum_size.y = 38
		if not ForgeGear.tab_unlocked(p, key):
			st.modulate = Color(1, 1, 1, 0.55)
			st.tooltip_text = ForgeGear.tab_lock_text(key)
		side.add_child(st)
	side.add_child(UiTheme.spacer())
	var hint := UiTheme.label("Cường hoá thất bại chỉ mất nguyên liệu — món đồ giữ nguyên cấp.", "Small", 160)
	hint.add_theme_color_override("font_color", Color("#b08a5a"))
	side.add_child(hint)
	body.add_child(side)
	match tab:
		"tips":
			ForgeGear.tips(self, body, p)
		"gems":
			ForgeGear.gems(self, body, p)
		"reforge":
			ForgeGear.reforge(self, body, p)
		"ascend":
			ForgeGear.ascend(self, body, p)
		"awaken":
			ForgeGear.awaken(self, body, p)
		"codex":
			ForgeGear.codex(self, body, p)
		"craft":
			_craft(body, p)
		"refine":
			_refine(body, p)
		"salvage":
			_salvage(body, p)
		_:
			_enhance(body, p)
	content.add_child(body)


# ------------------------------------------------------------------ Cường hoá


## Cột trái chọn món (đang mặc + túi) — dùng chung cho Cường hoá và các tab NL-1.
func _picker(body: HBoxContainer, p) -> void:
	if Items.find_item(p, _item_id).is_empty():
		_item_id = -1
		for slot in SLOT_ROW:
			var it: Dictionary = p.equipment.get(slot, {})
			if not it.is_empty():
				_item_id = int(it.id)
				break
	var pick: Array = W.section("ĐANG MẶC", PICK_W)
	var eq := GridContainer.new()
	eq.columns = 4
	eq.add_theme_constant_override("h_separation", 6)
	eq.add_theme_constant_override("v_separation", 6)
	for slot in SLOT_ROW:
		eq.add_child(_pick_button(p.equipment.get(slot, {}), slot))
	pick[1].add_child(eq)
	pick[1].add_child(UiTheme.label("TÚI ĐỒ", "Eyebrow"))
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(PICK_W, 250)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var bag := GridContainer.new()
	bag.columns = 4
	bag.add_theme_constant_override("h_separation", 6)
	bag.add_theme_constant_override("v_separation", 6)
	for it in p.inventory:
		bag.add_child(_pick_button(it, ""))
	if p.inventory.is_empty():
		bag.add_child(UiTheme.label("Túi trống.", "Muted"))
	scroll.add_child(bag)
	pick[1].add_child(scroll)
	body.add_child(pick[0])


func _enhance(body: HBoxContainer, p) -> void:
	_picker(body, p)
	# giữa: món đang chọn
	var mid: Array = W.section("", CENTER_W)
	body.add_child(mid[0])
	var col: VBoxContainer = mid[1]
	var found := Items.find_item(p, _item_id)
	if found.is_empty():
		col.add_child(UiTheme.label("Chọn một món đồ bên trái để cường hoá.", "Muted", CENTER_W))
		body.add_child(_cost_table(p, {}))
		return
	var item: Dictionary = found.item
	var plus := int(item.plus)
	var c := Items.rarity_color(item)
	var head := UiTheme.hbox(12)
	var frame := UiTheme.panel(UiTheme.box(Color(c.darkened(0.7), 0.9), 8, 2, c, 6))
	var ic := UiTheme.icon_rect(SpriteLib.item_icon(item), 72)
	Inv.EnhanceFx.attach(ic, item, ic.texture, 0.0, 6.0)
	frame.add_child(ic)
	head.add_child(frame)
	var hv := UiTheme.vbox(2)
	hv.size_flags_horizontal = SIZE_EXPAND_FILL
	var nm := UiTheme.strong(Items.display_name(item), 19, c)
	nm.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	nm.custom_minimum_size.x = CENTER_W - 110
	hv.add_child(nm)
	hv.add_child(UiTheme.label("%s · %s · Cấp %d%s" % [ItemData.RARITIES[item.rarity].name, ItemData.SLOTS[item.slot].name, int(item.level),
		" · đang mặc" if found.where != "bag" else ""], "Small"))
	head.add_child(hv)
	col.add_child(head)
	col.add_child(HSeparator.new())
	if plus >= ItemData.MAX_PLUS:
		col.add_child(UiTheme.strong("Đã cường hoá tối đa +%d." % ItemData.MAX_PLUS, 17, UiTheme.GOLD))
		body.add_child(_cost_table(p, item))
		return
	# +N → +N+1 và chỉ số gốc
	var step := UiTheme.hbox(10)
	step.alignment = BoxContainer.ALIGNMENT_CENTER
	step.add_child(UiTheme.strong("+%d" % plus, 30, Items.enhance_color(plus) if Items.enhance_tier(plus) > 0 else UiTheme.TEXT))
	step.add_child(UiTheme.strong("➜", 24, UiTheme.GOLD))
	step.add_child(UiTheme.strong("+%d" % (plus + 1), 30, Items.enhance_color(plus + 1) if Items.enhance_tier(plus + 1) > 0 else UiTheme.GOOD))
	col.add_child(step)
	var stat := Items.base_stat(item)
	var now := Items.base_value(item)
	var nxt := Items.base_value(item, plus + 1)
	# SN9-07: "+9 + 15 Tấn công" — tách gốc và phần cường hoá
	var sl := UiTheme.label("%s  ➜  %s  (gốc)" % [Items.base_text(item), Items.base_text(item, plus + 1)])
	sl.name = "EnhanceStat"
	sl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sl.add_theme_color_override("font_color", UiTheme.GOOD)
	col.add_child(sl)
	# tỉ lệ
	var rate := Items.enhance_rate(item, p)
	var rr := UiTheme.hbox(8)
	rr.add_child(UiTheme.label("Tỉ lệ thành công", "Small"))
	var bar := ProgressBar.new()
	bar.show_percentage = false
	bar.max_value = 100
	bar.value = rate * 100.0
	bar.custom_minimum_size = Vector2(170, 14)
	bar.size_flags_vertical = SIZE_SHRINK_CENTER
	bar.size_flags_horizontal = SIZE_EXPAND_FILL
	var rc := UiTheme.GOOD if rate >= 0.99 else (UiTheme.GOLD if rate >= 0.5 else Color("#ff8a5a"))
	bar.add_theme_stylebox_override("fill", UiTheme.box(rc, 4, 0, rc, 0))
	bar.add_theme_stylebox_override("background", UiTheme.box(Color("#0b0805"), 4, 1, Color("#4a3620"), 0))
	rr.add_child(bar)
	rr.add_child(UiTheme.strong("%d%%" % roundi(rate * 100.0), 16, rc))
	col.add_child(rr)
	var bonus := Items.talent_rate_bonus(p)
	if bonus > 0.0:
		var bl := UiTheme.label("Gồm +%d%% từ Thiên phú." % roundi(bonus * 100.0), "Small")
		bl.add_theme_color_override("font_color", Color("#9be08a"))
		col.add_child(bl)
	# chi phí lần này
	col.add_child(UiTheme.label("CHI PHÍ LẦN NÀY", "Eyebrow"))
	var cost := Items.enhance_cost(item, p)
	col.add_child(W.cost_row([
		["res-gold", cost.gold, int(p.gold), "Vàng"],
		["res-stone", cost.stones, int(p.stones), "Đá Cường Hoá"],
		["res-tinh_kim", cost.tinh_kim, int(p.tinh_kim), "Tinh Kim"],
	]))
	if rate < 1.0:
		col.add_child(UiTheme.label("Thất bại: mất nguyên liệu, món đồ vẫn +%d." % plus, "Small", CENTER_W))
	var blocker := Items.enhance_blocker(p, item)
	var b := UiTheme.button("Cường hoá +%d" % (plus + 1), true)
	b.name = "EnhanceButton"
	b.custom_minimum_size = Vector2(0, 46)
	b.disabled = blocker != ""
	if blocker != "":
		b.tooltip_text = blocker  # UI-62: lý do khoá
	var id := int(item.id)
	b.pressed.connect(func():
		var res: Dictionary = world.enhance(id)
		refresh()
		if res.ok:
			var it: Dictionary = Items.find_item(world.profile, id).item
			_burst(res.get("success", false), int(it.plus), Items.display_name(it), SpriteLib.item_icon(it)))
	col.add_child(b)
	if blocker != "":
		var bw := UiTheme.label(blocker, "", CENTER_W)
		bw.add_theme_color_override("font_color", W.SHORT)
		col.add_child(bw)
	body.add_child(_cost_table(p, item))


func _pick_button(item: Dictionary, slot: String) -> Button:
	var b := UiTheme.button("")
	b.custom_minimum_size = Vector2(62, 62)
	b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	b.expand_icon = true
	if item.is_empty():
		b.icon = SpriteLib.icon("item-" + slot)
		b.disabled = true
		b.tooltip_text = "%s: trống" % ItemData.SLOTS[slot].name
		b.add_theme_stylebox_override("disabled", UiTheme.box(Color("#0f0a06"), 6, 1, Color("#3a2a18"), 8))
		b.add_theme_color_override("icon_disabled_color", Color(1, 1, 1, 0.2))
		return b
	var c := Items.rarity_color(item)
	var sel := int(item.id) == _item_id
	b.icon = SpriteLib.item_icon(item)
	if tab == "enhance":
		b.tooltip_text = "%s\nLần tới: %s" % [Items.display_name(item), _cost_text(Items.enhance_cost(item, world.profile)) if int(item.plus) < ItemData.MAX_PLUS else "đã tối đa"]
	else:
		b.tooltip_text = "%s\nLỗ ngọc %d/%d" % [Items.display_name(item), Array(item.get("gems", [])).size(), int(item.get("sockets", 0))]
	var normal := UiTheme.box(Color(c, 0.3 if sel else 0.1), 6, 2 if sel else 1, c.lightened(0.3) if sel else c, 6)
	b.add_theme_stylebox_override("normal", normal)
	b.add_theme_stylebox_override("pressed", normal)
	b.add_theme_stylebox_override("hover", UiTheme.box(Color(c, 0.3), 6, 2, c.lightened(0.3), 6))
	Inv.EnhanceFx.attach(b, item, b.icon, 6.0, 6.0)
	var id := int(item.id)
	b.pressed.connect(func():
		_item_id = id
		refresh())
	return b


## Bảng chi phí mọi cấp của món đang chọn (Spec_Notes: "không hiện mỗi lần cường hoá tốn bao nhiêu").
func _cost_table(p, item: Dictionary) -> PanelContainer:
	var sec: Array = W.section("BẢNG CHI PHÍ CƯỜNG HOÁ", TABLE_W)
	var col: VBoxContainer = sec[1]
	sec[0].name = "CostTable"
	if item.is_empty():
		col.add_child(UiTheme.label("Chọn món để xem chi phí từng cấp.", "Muted", TABLE_W))
		return sec[0]
	var grid := GridContainer.new()
	grid.name = "CostGrid"
	grid.columns = 5
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 2)
	for h in ["Cấp", "Tỉ lệ", "Vàng", "Đá", "T.Kim"]:
		var hl := UiTheme.label(h, "Small")
		hl.add_theme_color_override("font_color", Color("#b08a5a"))
		grid.add_child(hl)
	var plus := int(item.plus)
	var probe := item.duplicate()
	for n in ItemData.MAX_PLUS:
		probe.plus = n
		var cost := Items.enhance_cost(probe, p)
		var rate := Items.enhance_rate(probe, p)
		var colr := UiTheme.GOLD if n == plus else (UiTheme.MUTED if n < plus else UiTheme.TEXT)
		var cells := ["+%d→%d" % [n, n + 1], "%d%%" % roundi(rate * 100.0), W.group(cost.gold), str(cost.stones), str(cost.tinh_kim) if cost.tinh_kim > 0 else "—"]
		for txt in cells:
			var l := UiTheme.strong(txt, 13, colr) if n == plus else UiTheme.label(txt, "Small")
			if n != plus:
				l.add_theme_color_override("font_color", colr)
			grid.add_child(l)
	col.add_child(grid)
	var total := {"gold": 0, "stones": 0, "tinh_kim": 0}
	for n in range(plus, ItemData.MAX_PLUS):
		probe.plus = n
		var cost := Items.enhance_cost(probe, p)
		for k in total:
			total[k] += int(cost[k])
	if plus < ItemData.MAX_PLUS:
		col.add_child(HSeparator.new())
		col.add_child(UiTheme.label("Lên +%d (nếu không thất bại lần nào): %s." % [ItemData.MAX_PLUS, _cost_text(total)], "Small", TABLE_W))
	return sec[0]


func _cost_text(cost: Dictionary) -> String:
	var parts := PackedStringArray(["%s vàng" % W.group(int(cost.gold)), "%d Đá" % int(cost.stones)])
	if int(cost.tinh_kim) > 0:
		parts.append("%d Tinh Kim" % int(cost.tinh_kim))
	return ", ".join(parts)


## SN10-01: kết quả cường hoá hiện giữa màn hình.
func _burst(success: bool, plus: int, label := "", tex: Texture2D = null) -> void:
	if not is_inside_tree():
		return
	Inv.EnhanceToast.pop(self, success, plus, label, tex)


# ------------------------------------------------------------------ Chế tạo (Xưởng Rèn)


func _craft(body: HBoxContainer, p) -> void:
	var sec: Array = W.section("XƯỞNG RÈN · CHẾ 1 MÓN CẤP %d" % maxi(1, int(p.level)), 660.0)
	body.add_child(sec[0])
	var col: VBoxContainer = sec[1]
	if not Explore.is_built(p, "forge"):
		var lk := UiTheme.label("Chưa xây Xưởng Rèn. Xây ở mục Công trình trên Bản đồ khai phá (phím M): %d vàng, %d Gỗ." % [
			int(Explore.BUILDINGS.forge.gold), int(Explore.BUILDINGS.forge.wood)], "", 620)
		lk.add_theme_color_override("font_color", W.SHORT)
		col.add_child(lk)
		return
	col.add_child(UiTheme.label("Chọn ô trang bị muốn chế:", "Small"))
	var grid := GridContainer.new()
	grid.columns = 4
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	var cost: int = world.forge_cost()
	var can: bool = p.gold >= cost and p.stones >= GameWorld.FORGE_STONES
	for slot in SLOT_ROW:
		var s: String = slot
		grid.add_child(W.item_card("forge_" + s, SpriteLib.icon("item-" + s), UiTheme.GOLD if s == _craft_slot else UiTheme.GOLD_DARK,
			str(ItemData.SLOTS[s].name), "res-gold", cost, can, s == _craft_slot, func():
				_craft_slot = s
				refresh()))
	col.add_child(grid)
	var rates := UiTheme.hbox(14)
	rates.add_child(UiTheme.label("Phẩm chất:", "Small"))
	for r in GameWorld.FORGE_RATES:
		var rl := UiTheme.strong("%s %d%%" % [ItemData.RARITIES[r].name, int(GameWorld.FORGE_RATES[r])], 14, Color(str(ItemData.RARITIES[r].color)))
		rates.add_child(rl)
	col.add_child(rates)
	col.add_child(UiTheme.label("CHI PHÍ", "Eyebrow"))
	var row := UiTheme.hbox(10)
	row.add_child(W.cost_row([
		["res-gold", cost, int(p.gold), "Vàng"],
		["res-stone", GameWorld.FORGE_STONES, int(p.stones), "Đá Cường Hoá"],
	]))
	row.add_child(UiTheme.spacer())
	var b := UiTheme.button("Chế %s" % str(ItemData.SLOTS[_craft_slot].name), true)
	b.name = "Forge_" + _craft_slot
	b.custom_minimum_size = Vector2(200, 46)
	var full: bool = p.inventory.size() >= ItemData.BAG_SIZE
	b.disabled = not can or full
	b.tooltip_text = "Túi đồ đã đầy." if full else ""
	b.pressed.connect(func():
		var res: Dictionary = world.forge_craft(_craft_slot)
		_last_craft = res.get("item", {})
		refresh())
	row.add_child(b)
	col.add_child(row)
	if not _last_craft.is_empty() and not Items.find_item(p, int(_last_craft.id)).is_empty():
		col.add_child(HSeparator.new())
		var lr := UiTheme.hbox(10)
		lr.add_child(UiTheme.icon_rect(SpriteLib.item_icon(_last_craft), 40))
		var ll := UiTheme.strong("Vừa chế: %s" % Items.display_name(_last_craft), 15, Items.rarity_color(_last_craft))
		ll.name = "LastCraft"
		lr.add_child(ll)
		col.add_child(lr)


# ------------------------------------------------------------------ Luyện nguyên liệu


func _refine(body: HBoxContainer, p) -> void:
	var sec: Array = W.section("LUYỆN NGUYÊN LIỆU", 640.0)
	body.add_child(sec[0])
	var col: VBoxContainer = sec[1]
	var town: bool = world.map_id == "2-1"
	col.add_child(UiTheme.strong("Thợ rèn Thiết Ngưu", 16, W.PLATE_TEXT))
	if town:
		_recipe(col, "Smith_stone", [["res-ore", GameWorld.SMITH_STONE_ORE, int(p.ore), "Đá"]], "res-stone", "1 Đá Cường Hoá",
			func(): return world.smith_trade("stone"))
		_recipe(col, "Smith_tinh_kim", [["res-ore", GameWorld.SMITH_KIM_ORE, int(p.ore), "Đá"], ["res-iron", GameWorld.SMITH_KIM_IRON, int(p.iron), "Sắt"]],
			"res-tinh_kim", "1 Tinh Kim", func(): return world.smith_trade("tinh_kim"))
	else:
		col.add_child(UiTheme.label("Gặp Thiết Ngưu ở %s (vùng 2) để luyện Đá, Sắt từ mỏ thành Đá Cường Hoá và Tinh Kim." % str(Maps.get_map("2-1").name), "Muted", 620))
	if int(world.map.get("region", 1)) == 5:
		col.add_child(HSeparator.new())
		col.add_child(UiTheme.strong("Thương Hội Kim Luân", 16, W.PLATE_TEXT))
		_recipe(col, "Buy_crystal_kim", [["res-crystal", GameWorld.Ch5.CRYSTAL_PER_KIM, int(p.crystal), "Tinh Thạch"]], "res-tinh_kim", "1 Tinh Kim",
			func(): return world.shop_buy("crystal_kim"))


## Một công thức: [ô nguyên liệu] ➜ [sản phẩm] [Luyện] [Luyện hết].
func _recipe(col: VBoxContainer, id: String, inputs: Array, out_icon: String, out_text: String, act: Callable) -> void:
	var row := UiTheme.panel(UiTheme.box(Color("#120c07"), 8, 1, Color("#4a3620"), 8))
	var h := UiTheme.hbox(10)
	row.add_child(h)
	h.add_child(W.cost_row(inputs))
	h.add_child(UiTheme.strong("➜", 20, UiTheme.GOLD))
	h.add_child(UiTheme.icon_rect(SpriteLib.icon(out_icon), 30))
	h.add_child(UiTheme.strong(out_text, 15))
	h.add_child(UiTheme.spacer())
	var times := 1 << 30
	for inp in inputs:
		times = mini(times, int(inp[2]) / maxi(1, int(inp[1])))
	var b := UiTheme.button("Luyện", true)
	b.name = id
	b.disabled = times <= 0
	b.pressed.connect(func():
		act.call()
		refresh())
	h.add_child(b)
	var all := UiTheme.button("Luyện hết (%d)" % times)
	all.name = id + "_all"
	all.disabled = times <= 1
	all.pressed.connect(func():
		for i in times:
			if not bool(act.call().get("ok", false)):
				break
		refresh())
	h.add_child(all)
	col.add_child(row)


# ------------------------------------------------------------------ Phân rã


func _salvage(body: HBoxContainer, _p) -> void:
	var sec: Array = W.section("PHÂN RÃ ĐỒ THÀNH ĐÁ CƯỜNG HOÁ", 640.0)
	body.add_child(sec[0])
	var col: VBoxContainer = sec[1]
	col.add_child(UiTheme.label("Đá nhận được theo phẩm chất, cộng thêm theo cấp cường hoá. Phân rã từng món: chọn món trong Túi đồ (phím I).", "Small", 620))
	col.add_child(BulkBox.build(world, "salvage", refresh, 620.0))
