extends "res://scripts/ui/modal.gd"
## Túi đồ (phím I) — EQ-18: ô đang mặc, túi 30 ô, chi tiết + so sánh, Mặc/Tháo/Cường hoá/Phân rã.

const Items = preload("res://scripts/core/items.gd")
const ItemData = preload("res://scripts/data/items.gd")
const SpriteLib = preload("res://scripts/view/sprite_lib.gd")
const Classes = preload("res://scripts/data/classes.gd")
const Resources = preload("res://scripts/data/resources.gd")
const CreateScreen = preload("res://scripts/ui/create_screen.gd")
const BulkBox = preload("res://scripts/ui/bulk_box.gd")

const DETAIL_W := 300.0

var _selected_id := -1
## "bag" | "res"
var _tab := "bag"
## Hiệu ứng vừa cường hoá: {item_id, success, plus, t}
var _fx := {}


## Spec_Notes N8: khung phát sáng theo cấp cường hoá + số "+N" trên ô đồ.
class PlusGlow:
	extends Control
	var plus := 0
	var t := 0.0

	func _process(delta: float) -> void:
		t += delta
		queue_redraw()

	func _draw() -> void:
		var c := Items.enhance_color(plus)
		var tier := Items.enhance_tier(plus)
		if tier > 0:
			var a := 0.45 + 0.35 * sin(t * (2.0 + tier))
			for i in tier:
				draw_rect(Rect2(Vector2.ONE * (1 + i * 2), size - Vector2.ONE * (2 + i * 4)), Color(c, a / (i + 1)), false, 2.0)
			for k in tier * 2:
				var ang := t * 1.5 + k * TAU / (tier * 2)
				var r := size.x * 0.42
				draw_circle(size / 2.0 + Vector2.from_angle(ang) * r, 1.5 + tier * 0.4, Color(c, 0.9))
		if plus > 0:
			var f := UiTheme.bold_font()
			var col := c if tier > 0 else Color.WHITE
			draw_string_outline(f, Vector2(0, size.y - 4), "+%d" % plus, HORIZONTAL_ALIGNMENT_RIGHT, size.x - 4, 12, 3, Color.BLACK)
			draw_string(f, Vector2(0, size.y - 4), "+%d" % plus, HORIZONTAL_ALIGNMENT_RIGHT, size.x - 4, 12, col)


## Hiệu ứng khi bấm Cường hoá: thành công = chùm sáng toả ra; thất bại = tia xám rơi xuống.
class EnhanceBurst:
	extends Control
	var success := true
	var plus := 0
	var t := 0.0

	func _process(delta: float) -> void:
		t += delta
		queue_redraw()
		if t > 1.2:
			queue_free()

	func _draw() -> void:
		var c := size / 2.0
		var k := clampf(t / 1.0, 0.0, 1.0)
		var f := UiTheme.bold_font()
		if success:
			var col := Items.enhance_color(plus) if Items.enhance_tier(plus) > 0 else UiTheme.GOLD
			draw_circle(c, 20.0 + 70.0 * k, Color(col, 0.35 * (1.0 - k)))
			for i in 14:
				var a := TAU * i / 14.0
				draw_line(c + Vector2.from_angle(a) * (10.0 + 40.0 * k), c + Vector2.from_angle(a) * (24.0 + 90.0 * k), Color(col, 1.0 - k), 3.0, true)
			draw_string_outline(f, c + Vector2(-100, -50 - 30 * k), "+%d!" % plus, HORIZONTAL_ALIGNMENT_CENTER, 200, 30, 5, Color(0, 0, 0, 1.0 - k))
			draw_string(f, c + Vector2(-100, -50 - 30 * k), "+%d!" % plus, HORIZONTAL_ALIGNMENT_CENTER, 200, 30, Color(col, 1.0 - k))
		else:
			for i in 8:
				var x := -60.0 + i * 17.0
				draw_line(c + Vector2(x, -20 + 60 * k), c + Vector2(x + 4, -4 + 60 * k), Color(0.6, 0.6, 0.65, 1.0 - k), 3.0)
			draw_string_outline(f, c + Vector2(-100, -40), "Thất bại", HORIZONTAL_ALIGNMENT_CENTER, 200, 24, 4, Color(0, 0, 0, 1.0 - k))
			draw_string(f, c + Vector2(-100, -40), "Thất bại", HORIZONTAL_ALIGNMENT_CENTER, 200, 24, Color(0.8, 0.8, 0.85, 1.0 - k))


func _render(content: VBoxContainer) -> void:
	var p = world.profile
	_header(content, "Túi đồ · Lực chiến %d" % world.combat_power(), "Đóng (I)")
	var tabs := UiTheme.hbox(8)
	for pair in [["bag", "Túi đồ %d/%d" % [p.inventory.size(), ItemData.BAG_SIZE]], ["res", "Tài nguyên"]]:
		var tb := UiTheme.button(pair[1], _tab == pair[0])
		tb.name = "Tab_" + pair[0]
		var key: String = pair[0]
		tb.pressed.connect(func():
			_tab = key
			refresh())
		tabs.add_child(tb)
	content.add_child(tabs)
	if Items.find_item(p, _selected_id).is_empty():
		_selected_id = -1

	var body := UiTheme.hbox(18)
	body.add_child(_character_column(p))
	if _tab == "res":
		body.add_child(_resource_list(p))
	else:
		body.add_child(_bag_grid(p))
		body.add_child(_detail(p))
	content.add_child(body)


# ------------------------------------------------------------------ cột trái: nhân vật (C1-04, Spec_Notes N7)

const PAPER_LEFT := ["helm", "armor", "gloves", "boots"]
const PAPER_RIGHT := ["weapon", "necklace", "ring", "amulet"]


func _character_column(p) -> VBoxContainer:
	var col := UiTheme.vbox(6)
	col.custom_minimum_size.x = 300
	var t: Dictionary = world.talent()
	var title := UiTheme.label("%s" % p.name, "Heading")
	col.add_child(title)
	col.add_child(UiTheme.label("%s · Cấp %d · %s %s" % [Classes.title(str(p.class_id), str(p.job), str(p.job2)), p.level, t.rank, t.name], "Small"))
	# Búp bê giấy: 4 ô trái · chân dung · 4 ô phải
	var doll := UiTheme.hbox(6)
	doll.add_child(_slot_column(p, PAPER_LEFT))
	var frame := PanelContainer.new()
	frame.add_theme_stylebox_override("panel", UiTheme.box(Color(0, 0, 0, 0.25), 10, 1, UiTheme.LINE, 4))
	var portrait = CreateScreen.Preview.new()
	portrait.custom_minimum_size = Vector2(160, 250)
	portrait.class_id = p.class_id
	portrait.look = p.look
	portrait.mouse_filter = MOUSE_FILTER_IGNORE
	frame.add_child(portrait)
	doll.add_child(frame)
	doll.add_child(_slot_column(p, PAPER_RIGHT))
	col.add_child(doll)
	var s: Dictionary = world.stats
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 16)
	for pair in [
		["Lực chiến", str(world.combat_power())], ["HP", str(s.max_hp)], ["MP", str(s.max_mp)],
		["Tấn công", str(int(s.atk))], ["Phòng thủ", "%.1f" % s.def], ["Chí mạng", "%.1f%%" % (s.crit * 100.0)],
		["Tốc đánh", "%d%%" % roundi(s.atk_speed * 100.0)], ["Né tránh", "%.1f%%" % (s.evasion * 100.0)],
	]:
		grid.add_child(UiTheme.label(pair[0], "Small"))
		var v := UiTheme.label(pair[1])
		v.add_theme_font_override("font", UiTheme.bold_font())
		grid.add_child(v)
	col.add_child(grid)
	var bonus := Items.equipment_bonus(p.equipment)
	for set_id in bonus.sets:
		var set_def: Dictionary = ItemData.SETS[set_id]
		col.add_child(UiTheme.label("%s (%d/6)" % [set_def.name, bonus.sets[set_id]], "Small"))
	return col


func _slot_column(p, slots: Array) -> VBoxContainer:
	var v := UiTheme.vbox(6)
	for slot in slots:
		var item: Dictionary = p.equipment.get(slot, {})
		var b := _item_button(item, "")
		b.custom_minimum_size = Vector2(58, 58)
		b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		b.expand_icon = true
		var slot_name: String = ItemData.SLOTS[slot].name
		b.tooltip_text = "%s: %s" % [slot_name, Items.display_name(item) if not item.is_empty() else "trống"]
		if item.is_empty():
			b.icon = SpriteLib.icon("item-" + slot)
			b.add_theme_color_override("icon_normal_color", Color(1, 1, 1, 0.25))
			b.add_theme_color_override("icon_disabled_color", Color(1, 1, 1, 0.25))
			b.disabled = true
		v.add_child(b)
	return v


## C1-03: giải thích 8 loại tài nguyên.
func _resource_list(p) -> VBoxContainer:
	var col := UiTheme.vbox(6)
	col.custom_minimum_size.x = 400
	col.add_child(UiTheme.label("TÀI NGUYÊN", "Eyebrow"))
	for r in Resources.LIST:
		var row := UiTheme.hbox(10)
		var ic := TextureRect.new()
		ic.texture = SpriteLib.icon("res-" + str(r.icon))
		ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		ic.custom_minimum_size = Vector2(36, 36)
		row.add_child(ic)
		var v := UiTheme.vbox(0)
		var head := UiTheme.label("%s: %d" % [r.name, Resources.value(p, r.id)])
		head.add_theme_font_override("font", UiTheme.bold_font())
		v.add_child(head)
		v.add_child(UiTheme.label(r.desc, "Small", 340))
		row.add_child(v)
		col.add_child(row)
	return col


# ------------------------------------------------------------------ giữa: túi


func _bag_grid(p) -> VBoxContainer:
	var col := UiTheme.vbox(4)
	col.add_child(UiTheme.label("TÚI ĐỒ", "Eyebrow"))
	var grid := GridContainer.new()
	grid.columns = 6
	grid.add_theme_constant_override("h_separation", 4)
	grid.add_theme_constant_override("v_separation", 4)
	var marked := BulkBox.marked_ids(world)
	for i in ItemData.BAG_SIZE:
		var item: Dictionary = p.inventory[i] if i < p.inventory.size() else {}
		var text := ""
		if not item.is_empty():
			text = "+%d" % int(item.plus) if int(item.plus) > 0 else ""
		var b := _item_button(item, text)
		# SN-11: món khớp bộ lọc phân rã nhanh có dấu đỏ ở góc.
		if not item.is_empty() and marked.has(int(item.id)):
			var dot := ColorRect.new()
			dot.color = Color("#ff5470")
			dot.size = Vector2(8, 8)
			dot.position = Vector2(50, 4)
			dot.mouse_filter = MOUSE_FILTER_IGNORE
			b.add_child(dot)
			b.tooltip_text += "
(khớp bộ lọc phân rã nhanh)"
		b.custom_minimum_size = Vector2(62, 54)
		b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		b.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
		b.add_theme_font_size_override("font_size", 12)
		b.disabled = item.is_empty()
		grid.add_child(b)
	col.add_child(grid)
	col.add_child(HSeparator.new())
	col.add_child(BulkBox.build(world, "salvage", refresh, 390.0))
	return col


func _item_button(item: Dictionary, text: String) -> Button:
	var b := UiTheme.button(text)
	if item.is_empty():
		return b
	var c := Items.rarity_color(item)
	b.icon = SpriteLib.item_icon(item)
	b.tooltip_text = Items.display_name(item)
	var glow := PlusGlow.new()
	glow.plus = int(item.plus)
	glow.mouse_filter = MOUSE_FILTER_IGNORE
	glow.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	b.add_child(glow)
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
		# SN-20: báo trước cấp cường hoá được chuyển từ đồ đang mặc.
		var moved := Items.plus_after_equip(p, item)
		if moved > int(item.plus):
			var tl := UiTheme.label("Mặc vào: nhận +%d từ đồ đang mặc (đồ cũ còn +%d)." % [moved, int(item.plus)], "", DETAIL_W)
			tl.add_theme_color_override("font_color", UiTheme.GOLD)
			col.add_child(tl)

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
		var res: Dictionary = world.enhance(int(item.id))
		refresh()
		if res.ok:
			_play_burst(res.get("success", false), int(Items.find_item(world.profile, int(item.id)).item.plus)))
	col.add_child(b)
	if blocker != "":
		var w := UiTheme.label(blocker, "", DETAIL_W)
		w.add_theme_color_override("font_color", Color("#ffb27a"))
		w.add_theme_font_size_override("font_size", 13)
		col.add_child(w)


func _play_burst(success: bool, plus: int) -> void:
	var fx := EnhanceBurst.new()
	fx.success = success
	fx.plus = plus
	fx.mouse_filter = MOUSE_FILTER_IGNORE
	fx.custom_minimum_size = Vector2(240, 200)
	fx.size = Vector2(240, 200)
	add_child(fx)
	fx.position = get_viewport_rect().size / 2.0 + Vector2(220, -120)
