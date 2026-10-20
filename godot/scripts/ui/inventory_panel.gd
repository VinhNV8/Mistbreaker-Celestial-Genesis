extends "res://scripts/ui/modal.gd"
## Túi đồ (phím I) — EQ-18: ô đang mặc, túi 30 ô, chi tiết + so sánh, Mặc/Tháo/Cường hoá/Phân rã.

const Items = preload("res://scripts/core/items.gd")
const ItemData = preload("res://scripts/data/items.gd")
const SpriteLib = preload("res://scripts/view/sprite_lib.gd")

const DETAIL_W := 300.0

var _selected_id := -1


func _render(content: VBoxContainer) -> void:
	var p = world.profile
	_header(content, "Túi đồ · Lực chiến %d" % world.combat_power(), "Đóng (I)")
	content.add_child(UiTheme.label(
		"Vàng %d   ·   Đá Cường Hoá %d   ·   Tinh Kim %d   ·   Túi %d/%d" % [int(p.gold), p.stones, p.tinh_kim, p.inventory.size(), ItemData.BAG_SIZE], "Muted"
	))
	if Items.find_item(p, _selected_id).is_empty():
		_selected_id = -1

	var body := UiTheme.hbox(18)
	body.add_child(_equipped_column(p))
	body.add_child(_bag_grid(p))
	body.add_child(_detail(p))
	content.add_child(body)


# ------------------------------------------------------------------ cột trái: đang mặc


func _equipped_column(p) -> VBoxContainer:
	var col := UiTheme.vbox(4)
	col.custom_minimum_size.x = 250
	col.add_child(UiTheme.label("ĐANG MẶC", "Eyebrow"))
	for slot in ItemData.SLOT_ORDER:
		var item: Dictionary = p.equipment.get(slot, {})
		var slot_name: String = ItemData.SLOTS[slot].name
		var text := "%s: %s" % [slot_name, Items.display_name(item) if not item.is_empty() else "— trống —"]
		var b := _item_button(item, text)
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.custom_minimum_size = Vector2(250, 38)
		if item.is_empty():
			# ô trống: hiện mờ icon loại đồ
			b.icon = SpriteLib.icon("item-" + slot)
			b.add_theme_color_override("icon_normal_color", Color(1, 1, 1, 0.25))
			b.add_theme_color_override("icon_disabled_color", Color(1, 1, 1, 0.25))
		col.add_child(b)
	var bonus := Items.equipment_bonus(p.equipment)
	for set_id in bonus.sets:
		var set_def: Dictionary = ItemData.SETS[set_id]
		col.add_child(UiTheme.label("%s (%d/6)" % [set_def.name, bonus.sets[set_id]], "Small"))
	return col


# ------------------------------------------------------------------ giữa: túi


func _bag_grid(p) -> VBoxContainer:
	var col := UiTheme.vbox(4)
	col.add_child(UiTheme.label("TÚI ĐỒ", "Eyebrow"))
	var grid := GridContainer.new()
	grid.columns = 6
	grid.add_theme_constant_override("h_separation", 4)
	grid.add_theme_constant_override("v_separation", 4)
	for i in ItemData.BAG_SIZE:
		var item: Dictionary = p.inventory[i] if i < p.inventory.size() else {}
		var text := ""
		if not item.is_empty():
			text = "+%d" % int(item.plus) if int(item.plus) > 0 else ""
		var b := _item_button(item, text)
		b.custom_minimum_size = Vector2(62, 54)
		b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		b.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
		b.add_theme_font_size_override("font_size", 12)
		b.disabled = item.is_empty()
		grid.add_child(b)
	col.add_child(grid)
	return col


func _item_button(item: Dictionary, text: String) -> Button:
	var b := UiTheme.button(text)
	if item.is_empty():
		return b
	var c := Items.rarity_color(item)
	b.icon = SpriteLib.item_icon(item)
	b.tooltip_text = Items.display_name(item)
	var selected := int(item.id) == _selected_id
	var normal := UiTheme.box(Color(c, 0.22 if selected else 0.08), 6, 2 if selected else 1, c, 6)
	b.add_theme_stylebox_override("normal", normal)
	b.add_theme_stylebox_override("hover", UiTheme.box(Color(c, 0.3), 6, 2, c, 6))
	b.add_theme_stylebox_override("pressed", normal)
	b.add_theme_color_override("font_color", c.lightened(0.25))
	b.add_theme_color_override("font_hover_color", Color.WHITE)
	var id := int(item.id)
	b.pressed.connect(func():
		_selected_id = id
		refresh())
	return b


# ------------------------------------------------------------------ phải: chi tiết


func _detail(p) -> VBoxContainer:
	var col := UiTheme.vbox(6)
	col.custom_minimum_size.x = DETAIL_W
	var found := Items.find_item(p, _selected_id)
	if found.is_empty():
		col.add_child(UiTheme.label("Chọn một món đồ để xem chi tiết.", "Muted", DETAIL_W))
		col.add_child(UiTheme.label(
			"Quái tinh anh luôn rơi đồ Xanh dương hoặc Tím. Sói Chúa rơi đồ Tím và có thể rơi Nanh Sói Chúa.", "Small", DETAIL_W
		))
		return col
	var item: Dictionary = found.item
	var in_bag: bool = found.where == "bag"
	var rarity: Dictionary = ItemData.RARITIES[item.rarity]

	var title := UiTheme.label(Items.display_name(item), "Heading", DETAIL_W)
	title.add_theme_color_override("font_color", Items.rarity_color(item))
	title.add_theme_font_size_override("font_size", 19)
	col.add_child(title)
	col.add_child(UiTheme.label(
		"%s · %s · Cấp %d" % [rarity.name, ItemData.SLOTS[item.slot].name, int(item.level)], "Small"
	))
	col.add_child(UiTheme.label(Items.stat_text(Items.base_stat(item), Items.base_value(item)) + "  (gốc)"))
	for af in item.affixes:
		var l := UiTheme.label(Items.stat_text(af.stat, af.value))
		l.add_theme_color_override("font_color", Color("#9ec8ff"))
		col.add_child(l)
	if item.unique != "":
		var u := UiTheme.label(ItemData.UNIQUES[item.unique].text, "", DETAIL_W)
		u.add_theme_color_override("font_color", Items.rarity_color(item))
		col.add_child(u)
	if item.set != "":
		_set_lines(col, p, item.set)

	if in_bag:
		var delta: int = world.power_if_equipped(item) - world.combat_power()
		var cmp := UiTheme.label(
			"Mặc vào: Lực chiến %s%d" % ["+" if delta >= 0 else "", delta], "", DETAIL_W
		)
		cmp.add_theme_color_override("font_color", UiTheme.GOOD if delta >= 0 else UiTheme.BAD)
		col.add_child(cmp)

	col.add_child(HSeparator.new())
	var row := UiTheme.hbox(8)
	if in_bag:
		var wear := UiTheme.button("Mặc", true)
		wear.pressed.connect(func():
			world.equip(int(item.id))
			refresh())
		row.add_child(wear)
		var sv := UiTheme.button("Phân rã (+%d đá)" % Items.salvage_value(item, p))
		sv.pressed.connect(func():
			world.salvage(int(item.id))
			refresh())
		row.add_child(sv)
	else:
		var off := UiTheme.button("Tháo")
		off.pressed.connect(func():
			world.unequip(str(item.slot))
			refresh())
		row.add_child(off)
	col.add_child(row)
	_enhance_block(col, p, item)
	return col


func _set_lines(col: VBoxContainer, p, set_id: String) -> void:
	var set_def: Dictionary = ItemData.SETS[set_id]
	var worn: int = Items.equipment_bonus(p.equipment).sets.get(set_id, 0)
	col.add_child(UiTheme.label("%s — đang mặc %d/6" % [set_def.name, worn], "Small"))
	for tier in set_def.tiers:
		var on: bool = worn >= int(tier.count)
		var l := UiTheme.label("  (%d) %s" % [tier.count, tier.text], "", DETAIL_W)
		l.add_theme_font_size_override("font_size", 13)
		l.add_theme_color_override("font_color", UiTheme.GOOD if on else UiTheme.MUTED)
		col.add_child(l)


## EQ-12/13: hiện chi phí, tỉ lệ, lý do bị khoá.
func _enhance_block(col: VBoxContainer, p, item: Dictionary) -> void:
	var plus := int(item.plus)
	if plus >= ItemData.MAX_PLUS:
		col.add_child(UiTheme.label("Đã cường hoá tối đa +%d." % ItemData.MAX_PLUS, "Muted"))
		return
	var cost := Items.enhance_cost(item, p)
	var rate := Items.enhance_rate(item, p)
	var next_base := Items.base_value(item, plus + 1)
	col.add_child(UiTheme.label(
		"Cường hoá +%d → +%d: %s (gốc). Tỉ lệ %d%%. Tốn %d vàng, %d đá%s." % [
			plus, plus + 1, Items.stat_text(Items.base_stat(item), next_base), roundi(rate * 100.0), cost.gold, cost.stones,
			(", %d Tinh Kim" % cost.tinh_kim) if cost.tinh_kim > 0 else ""
		], "Small", DETAIL_W
	))
	if rate < 1.0:
		col.add_child(UiTheme.label("Thất bại chỉ mất nguyên liệu, món đồ giữ nguyên.", "Small", DETAIL_W))
	var blocker := Items.enhance_blocker(p, item)
	var b := UiTheme.button("Cường hoá", true)
	b.size_flags_horizontal = SIZE_SHRINK_BEGIN
	b.disabled = blocker != ""
	b.pressed.connect(func():
		world.enhance(int(item.id))
		refresh())
	col.add_child(b)
	if blocker != "":
		var w := UiTheme.label(blocker, "", DETAIL_W)
		w.add_theme_color_override("font_color", Color("#ffb27a"))
		w.add_theme_font_size_override("font_size", 13)
		col.add_child(w)
