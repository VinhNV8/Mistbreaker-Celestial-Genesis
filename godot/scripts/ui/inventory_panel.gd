extends "res://scripts/ui/modal.gd"
## Túi đồ (phím I; phím C mở thẳng tab Chỉ số — UI-11) — EQ-18: ô đang mặc, túi 30 ô, chi tiết + so sánh, Mặc/Tháo/Cường hoá/Phân rã.
## UI-21: giao diện mới 3 cột (nhân vật · nội dung tab · Lực chiến/chi tiết), khung gỗ-vàng, icon chỉ số.

const Items = preload("res://scripts/core/items.gd")
const ItemData = preload("res://scripts/data/items.gd")
const SpriteLib = preload("res://scripts/view/sprite_lib.gd")
const Classes = preload("res://scripts/data/classes.gd")
const Resources = preload("res://scripts/data/resources.gd")
const CreateScreen = preload("res://scripts/ui/create_screen.gd")
const BulkBox = preload("res://scripts/ui/bulk_box.gd")
const StatsPage = preload("res://scripts/ui/stats_page.gd")
const CharWidgets = preload("res://scripts/ui/char_widgets.gd")
const Talents = preload("res://scripts/data/talents.gd")
const Ch4 = preload("res://scripts/core/chapter4.gd")
const Ch7 = preload("res://scripts/core/chapter7.gd")
const ShopW = preload("res://scripts/ui/shop_widgets.gd")
const Ornate = preload("res://scripts/ui/ornate.gd")
const CharBar = preload("res://scripts/ui/char_bar.gd")
const EnhanceToast = preload("res://scripts/ui/enhance_toast.gd")
const ItemTip = preload("res://scripts/ui/item_tip.gd")

const DETAIL_W := 300.0

var _selected_id := -1
## SN11-01, 02: thẻ thông tin trang bị đang hiện khi rê chuột (null nếu không có).
var _tip: Control = null
## "bag" | "res" | "stats" (UI-11: bảng Chỉ số gộp vào Túi đồ)
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
	_hide_tip()
	var p = world.profile
	content.add_theme_constant_override("separation", 12)
	content.add_child(_top_bar(p))
	if Items.find_item(p, _selected_id).is_empty():
		_selected_id = -1

	var body := UiTheme.hbox(14)
	body.add_child(_character_column(p))
	if _tab == "res":
		body.add_child(_resource_list(p))
	elif _tab == "stats":
		var page := UiTheme.vbox(10)
		StatsPage.build(page, world, refresh)
		body.add_child(page)
		body.add_child(StatsPage.build_side(world))
	else:
		body.add_child(_bag_grid(p))
		var det := _frame()
		var dc: Control = _detail(p)
		dc.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		det.add_child(dc)
		body.add_child(det)
	content.add_child(body)


# ------------------------------------------------------------------ thanh tiêu đề (UI-28, dùng chung CharBar)

## Tab ngoài bảng này (Kỹ năng / Thiên phú): main.gd đóng bảng rồi mở bảng tương ứng (UI-28b).
signal open_panel(id: String)


func _top_bar(_p) -> PanelContainer:
	return CharBar.build(world, _tab, func(key: String):
		if key in ["skills", "talent"]:
			open_panel.emit(key)
			return
		_tab = key
		refresh(), close)


## UI-27/28: khung cột vẽ (cắt từ ảnh mẫu) dùng chung cho mọi tab — khung lọc Linear, nội dung pixel bên trong
## phải tự đặt lại Nearest.
func _frame() -> PanelContainer:
	var f := UiTheme.panel(Ornate.panel_style())
	Ornate.linear(f)
	return f


# ------------------------------------------------------------------ cột trái: nhân vật (C1-04, Spec_Notes N7, UI-21)

const PAPER_LEFT := ["helm", "armor", "gloves", "boots"]
const PAPER_RIGHT := ["weapon", "necklace", "ring", "amulet"]


func _character_column(p) -> PanelContainer:
	var outer := _frame()
	var col := UiTheme.vbox(8)
	col.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	col.custom_minimum_size.x = 340
	outer.add_child(col)
	var t: Dictionary = world.talent()
	var form: Array = Ch7.form(t.id, int(p.evo))
	# tên + "Lv · chức nghiệp · Thiên phú"
	var name_row := UiTheme.hbox(10)
	var emb := UiTheme.panel(UiTheme.box(Color("#0f0a06"), 6, 1, UiTheme.GOLD_DARK, 4))
	emb.add_child(UiTheme.icon_rect(SpriteLib.icon("item-weapon"), 30))
	name_row.add_child(emb)
	var nv := UiTheme.vbox(0)
	nv.add_child(UiTheme.strong(str(p.name), 22, Color("#ece6d8")))
	nv.add_child(UiTheme.label("Lv.%d  •  %s  •  %s" % [p.level, Classes.title(str(p.class_id), str(p.job), str(p.job2), str(p.job3)), form[0]], "Muted"))
	name_row.add_child(nv)
	col.add_child(name_row)
	# Búp bê giấy: 4 ô trái · chân dung trên bệ đá · 4 ô phải
	var doll := UiTheme.hbox(8)
	doll.add_child(_slot_column(p, PAPER_LEFT))
	var frame := UiTheme.panel(UiTheme.box(Color("#0b1410"), 8, 1, UiTheme.GOLD_DARK, 2))
	# Chân dung giãn hết chỗ trống: cột ô đồ phải thẳng mép phải với thẻ Thiên phú bên dưới.
	frame.size_flags_horizontal = SIZE_EXPAND_FILL
	var portrait = CharWidgets.ScenePortrait.new()
	# tab Chỉ số không có 8 chỉ số chính ở cột trái (UI-21b) → chân dung cao hơn
	portrait.name = "Portrait"
	portrait.custom_minimum_size = Vector2(168, 248)
	portrait.class_id = p.class_id
	portrait.look = p.look
	frame.add_child(portrait)
	doll.add_child(frame)
	doll.add_child(_slot_column(p, PAPER_RIGHT))
	col.add_child(doll)
	col.add_child(_talent_card(p, t, form))
	# UI-21c: 3 tab chung cột trái, không lặp 8 chỉ số chính (đã có ở "Chỉ số chiến đấu" tab Chỉ số).
	# Khung bộ đồ chỉ hiện khi đang mặc ít nhất 1 món thuộc bộ.
	var sets: Dictionary = Items.equipment_bonus(p.equipment).sets
	if not sets.is_empty():
		# UI-26c: khung bộ đồ cuộn trong phần còn lại của cột — mặc nhiều bộ không đẩy cột cao quá cửa sổ
		# (trước đó làm cả bảng tràn, che nút Tẩy điểm / Tự cộng điểm ở tab Chỉ số).
		var set_scroll := ScrollContainer.new()
		set_scroll.name = "SetScroll"
		set_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		set_scroll.size_flags_vertical = SIZE_EXPAND_FILL
		set_scroll.custom_minimum_size.y = 90
		var sb := _set_box(p, sets)
		sb.size_flags_horizontal = SIZE_EXPAND_FILL
		set_scroll.add_child(sb)
		col.add_child(set_scroll)
	return outer


## Thẻ Thiên phú: huy hiệu hạng, tên dạng hiện tại, sao theo cấp (2 cấp = 1 sao), mô tả, nút "?".
func _talent_card(p, t: Dictionary, form: Array) -> PanelContainer:
	var rank := str(form[1])
	var rc := Talents.rank_color(rank)
	var card := UiTheme.panel(UiTheme.box(Color(rc.darkened(0.85), 0.9), 8, 1, Color(rc, 0.55), 8))
	var row := UiTheme.hbox(10)
	card.add_child(row)
	var badge = CharWidgets.RankBadge.new()
	badge.rank = rank
	badge.color = rc
	row.add_child(badge)
	var v := UiTheme.vbox(2)
	v.size_flags_horizontal = SIZE_EXPAND_FILL
	var head := UiTheme.hbox(6)
	var nm := UiTheme.strong(str(form[0]), 16)
	nm.size_flags_horizontal = SIZE_EXPAND_FILL
	head.add_child(nm)
	var help := UiTheme.button("?")
	help.custom_minimum_size = Vector2(28, 28)
	help.add_theme_font_size_override("font_size", UiTheme.fs(14))
	help.tooltip_text = "%s · hạng %s · %s\n%s\n\nXem chi tiết, tiến hoá: bảng Thiên phú (phím T)." % [form[0], rank, Talents.group_name(t), t.description]
	head.add_child(help)
	v.add_child(head)
	var lv: int = Ch4.stage_level(p)
	var stars = CharWidgets.Stars.new()
	stars.filled = clampi(int(ceil(lv / 2.0)), 0, 5)
	stars.tooltip_text = "Thiên phú cấp %d/10%s" % [lv, (" · tiến hoá %d" % int(p.evo)) if int(p.evo) > 0 else ""]
	v.add_child(stars)
	var d := UiTheme.label(str(t.description), "Small", 220)
	d.add_theme_color_override("font_color", Color("#c9b89a"))
	d.max_lines_visible = 3
	v.add_child(d)
	row.add_child(v)
	return card


## UI-21c: khung bộ đồ — tên bộ, huy hiệu số món, 6 ô món (thiếu để mờ), đủ 3 mức thưởng (Đang có / Thiếu N); không còn nút "Xem set".
func _set_box(p, sets: Dictionary) -> PanelContainer:
	var box := UiTheme.panel(UiTheme.box(Color("#120c07"), 8, 1, UiTheme.GOLD_DARK, 10))
	box.name = "SetBox"
	var v := UiTheme.vbox(6)
	box.add_child(v)
	for set_id in sets:
		var set_def: Dictionary = ItemData.SETS[set_id]
		var worn := int(sets[set_id])
		var row := UiTheme.hbox(10)
		row.add_child(UiTheme.icon_rect(SpriteLib.icon("stat-set"), 40))
		var nv := UiTheme.vbox(4)
		nv.size_flags_horizontal = SIZE_EXPAND_FILL
		var head := UiTheme.hbox(6)
		head.add_child(UiTheme.strong(str(set_def.name), 15, Color("#9be08a")))
		head.add_child(UiTheme.spacer())
		var cnt := UiTheme.panel(UiTheme.box(Color("#0e0a06"), 5, 1, Color("#4f7a3a"), 4))
		cnt.add_child(UiTheme.strong("%d/6" % worn, 13, Color("#9be08a")))
		head.add_child(cnt)
		nv.add_child(head)
		# 6 ô món của bộ: món đang mặc sáng, ô còn thiếu để trống mờ
		var pieces := UiTheme.hbox(4)
		var shown := 0
		for slot in PAPER_LEFT + PAPER_RIGHT:
			var it: Dictionary = p.equipment.get(slot, {})
			if not it.is_empty() and str(it.get("set", "")) == str(set_id):
				var pc := UiTheme.panel(UiTheme.box(Color("#0f0a06"), 4, 1, Color("#4f7a3a"), 2))
				pc.add_child(UiTheme.icon_rect(SpriteLib.item_icon(it), 24))
				pc.tooltip_text = Items.display_name(it)
				pieces.add_child(pc)
				shown += 1
		for i in maxi(0, 6 - shown):
			var empty := UiTheme.panel(UiTheme.box(Color("#0f0a06"), 4, 1, Color("#3a2a18"), 2))
			var sp := Control.new()
			sp.custom_minimum_size = Vector2(24, 24)
			empty.add_child(sp)
			pieces.add_child(empty)
		nv.add_child(pieces)
		row.add_child(nv)
		v.add_child(row)
		# Hiện đủ các mức thưởng — mức đã đạt màu xanh, chưa đạt màu xám + số món còn thiếu.
		v.add_child(HSeparator.new())
		for tier in set_def.tiers:
			var on: bool = worn >= int(tier.count)
			var tr := UiTheme.hbox(8)
			var mark := UiTheme.panel(UiTheme.box(Color("#2c5a2a") if on else Color("#0f0a06"), 4, 1, Color("#7ac46a") if on else Color("#4a3620"), 2))
			var ml := UiTheme.strong("%d" % int(tier.count), 12, Color.WHITE if on else UiTheme.MUTED)
			ml.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			ml.custom_minimum_size.x = 16
			mark.add_child(ml)
			tr.add_child(mark)
			var l := UiTheme.label(str(tier.text), "Small", 210)
			l.add_theme_color_override("font_color", UiTheme.GOOD if on else UiTheme.MUTED)
			l.size_flags_horizontal = SIZE_EXPAND_FILL
			tr.add_child(l)
			var st := UiTheme.label("Đang có" if on else "Thiếu %d" % (int(tier.count) - worn), "Small")
			st.add_theme_color_override("font_color", UiTheme.GOOD if on else Color("#b08a5a"))
			tr.add_child(st)
			v.add_child(tr)
	return box


func _slot_column(p, slots: Array) -> VBoxContainer:
	var v := UiTheme.vbox(6)
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	for slot in slots:
		var item: Dictionary = p.equipment.get(slot, {})
		var b := _item_button(item, "", true, "worn")
		b.custom_minimum_size = Vector2(58, 58)
		b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		b.expand_icon = true
		var slot_name: String = ItemData.SLOTS[slot].name
		# SN11-01: đồ đang mặc có thẻ thông tin khi rê chuột (ItemTip) — chỉ ô trống còn tooltip chữ
		b.tooltip_text = "" if not item.is_empty() else "%s: trống" % slot_name
		b.name = "Worn_" + str(slot)
		if item.is_empty():
			b.icon = SpriteLib.icon("item-" + slot)
			b.add_theme_stylebox_override("disabled", UiTheme.box(Color("#0f0a06"), 6, 1, Color("#4a3620"), 8))
			b.add_theme_color_override("icon_normal_color", Color(1, 1, 1, 0.22))
			b.add_theme_color_override("icon_disabled_color", Color(1, 1, 1, 0.22))
			b.disabled = true
		v.add_child(b)
	return v


## C1-03: giải thích các loại tài nguyên (UI-21: thẻ 2 cột trong khung lõm).
func _resource_list(p) -> PanelContainer:
	var outer := _frame()
	var col := UiTheme.vbox(8)
	col.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	col.custom_minimum_size.x = 640
	outer.add_child(col)
	col.add_child(UiTheme.strong("Tài nguyên", 20, Color("#f3d27a")))
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	for r in Resources.LIST:
		var card := UiTheme.panel(UiTheme.inset(Color("#21170e"), Color("#4a3620"), 8, 8))
		card.size_flags_horizontal = SIZE_EXPAND_FILL
		var row := UiTheme.hbox(10)
		var slot := UiTheme.panel(UiTheme.box(Color("#0f0a06"), 6, 1, Color("#5a4220"), 3))
		slot.add_child(UiTheme.icon_rect(SpriteLib.icon("res-" + str(r.icon)), 34))
		slot.size_flags_vertical = SIZE_SHRINK_BEGIN
		row.add_child(slot)
		var v := UiTheme.vbox(0)
		var head := UiTheme.hbox(6)
		head.add_child(UiTheme.strong(str(r.name), 15))
		head.add_child(UiTheme.spacer())
		head.add_child(UiTheme.strong(str(Resources.value(p, r.id)), 16, Color("#ffd877")))
		head.custom_minimum_size.x = 250
		v.add_child(head)
		v.add_child(UiTheme.label(r.desc, "Small", 250))
		row.add_child(v)
		card.add_child(row)
		grid.add_child(card)
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.custom_minimum_size = Vector2(640, 560)
	grid.size_flags_horizontal = SIZE_EXPAND_FILL
	scroll.add_child(grid)
	col.add_child(scroll)
	return outer


# ------------------------------------------------------------------ giữa: túi


func _bag_grid(p) -> PanelContainer:
	var outer := _frame()
	var col := UiTheme.vbox(6)
	col.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	outer.add_child(col)
	var head := UiTheme.hbox(8)
	head.add_child(UiTheme.strong("Túi đồ", 20, Color("#f3d27a")))
	head.add_child(UiTheme.spacer())
	var cnt := UiTheme.panel(UiTheme.box(Color("#0e0a06"), 6, 1, UiTheme.GOLD_DARK, 6))
	cnt.add_child(UiTheme.strong("%d/%d" % [p.inventory.size(), ItemData.BAG_SIZE], 14))
	head.add_child(cnt)
	col.add_child(head)
	var grid := GridContainer.new()
	grid.columns = 6
	grid.add_theme_constant_override("h_separation", 5)
	grid.add_theme_constant_override("v_separation", 5)
	var marked := BulkBox.marked_ids(world)
	for i in ItemData.BAG_SIZE:
		var item: Dictionary = p.inventory[i] if i < p.inventory.size() else {}
		var b := _item_button(item, "", true, "bag")
		b.name = "Bag_%d" % i
		# SN-11: món khớp bộ lọc phân rã nhanh có dấu đỏ ở góc.
		if not item.is_empty() and marked.has(int(item.id)):
			var dot := ColorRect.new()
			dot.color = Color("#ff5470")
			dot.size = Vector2(8, 8)
			dot.position = Vector2(4, 4)
			dot.mouse_filter = MOUSE_FILTER_IGNORE
			b.add_child(dot)
		b.custom_minimum_size = Vector2(62, 58)
		b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		b.expand_icon = true
		if item.is_empty():
			b.add_theme_stylebox_override("disabled", UiTheme.box(Color("#0f0a06"), 6, 1, Color("#3a2a18"), 8))
		b.disabled = item.is_empty()
		grid.add_child(b)
	col.add_child(grid)
	col.add_child(HSeparator.new())
	col.add_child(BulkBox.build(world, "salvage", refresh, 390.0))
	return outer


## doll = true: nền đậm theo phẩm chất (ô trang bị / ô túi kiểu mới UI-21).
## tip: "bag" / "worn" — rê chuột hiện thẻ thông tin (SN11), "" — tooltip chữ như cũ.
func _item_button(item: Dictionary, text: String, doll := false, tip := "") -> Button:
	var b := UiTheme.button(text)
	if item.is_empty():
		return b
	var c := Items.rarity_color(item)
	b.icon = SpriteLib.item_icon(item)
	b.tooltip_text = "" if tip != "" else Items.display_name(item)
	if tip != "":
		var it := item
		var in_bag := tip == "bag"
		b.mouse_entered.connect(func(): _show_tip(it, in_bag))
		b.mouse_exited.connect(_hide_tip)
	var glow := PlusGlow.new()
	glow.plus = int(item.plus)
	glow.mouse_filter = MOUSE_FILTER_IGNORE
	glow.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	b.add_child(glow)
	var selected := int(item.id) == _selected_id
	var fill := (0.32 if selected else 0.2) if doll else (0.22 if selected else 0.08)
	var normal := UiTheme.box(Color(c.darkened(0.45), fill + 0.35) if doll else Color(c, fill), 6, 2 if (selected or doll) else 1,
		c.lightened(0.3) if selected else c, 6)
	b.add_theme_stylebox_override("normal", normal)
	b.add_theme_stylebox_override("hover", UiTheme.box(Color(c, 0.3), 6, 2, c.lightened(0.3), 6))
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
	# SN9-07: gốc + phần cường hoá ("+9 + 15 Tấn công (gốc)")
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
		_set_lines(col, p, item.set)

	if in_bag:
		# SN11-02: so sánh với đồ đang mặc cùng ô (▲ / ▼ từng chỉ số + Lực chiến)
		var worn: Dictionary = p.equipment.get(str(item.slot), {})
		var hd := UiTheme.label(("So với đang mặc: %s" % Items.display_name(worn)) if not worn.is_empty() else "Ô này đang trống — mặc vào:", "Small", DETAIL_W)
		hd.name = "CompareHeader"
		col.add_child(hd)
		var lines := ItemTip.diff_lines(world, item, worn)
		if lines.is_empty():
			col.add_child(UiTheme.label("Chỉ số như nhau", "Small", DETAIL_W))
		for ln in lines:
			var dl := UiTheme.label(str(ln[0]), "", DETAIL_W)
			dl.add_theme_color_override("font_color", ln[1])
			col.add_child(dl)
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


## EQ-12/13: hiện chi phí, tỉ lệ, lý do bị khoá. UI-25 (Spec_Notes đợt 8): chi phí là các ô icon "cần / có"
## (thiếu thì đỏ) thay cho dòng chữ nhỏ; bảng chi phí mọi cấp ở Lò Rèn (phím R).
signal open_forge

func _enhance_block(col: VBoxContainer, p, item: Dictionary) -> void:
	var plus := int(item.plus)
	if plus >= ItemData.MAX_PLUS:
		col.add_child(UiTheme.label("Đã cường hoá tối đa +%d." % ItemData.MAX_PLUS, "Muted"))
		return
	var cost := Items.enhance_cost(item, p)
	var rate := Items.enhance_rate(item, p)
	var next_base := Items.base_value(item, plus + 1)
	var head := UiTheme.hbox(6)
	head.add_child(UiTheme.strong("Cường hoá +%d → +%d" % [plus, plus + 1], 15, UiTheme.GOLD))
	head.add_child(UiTheme.spacer())
	var rl := UiTheme.strong("Tỉ lệ %d%%" % roundi(rate * 100.0), 14, UiTheme.GOOD if rate >= 0.99 else Color("#ffb27a"))
	head.add_child(rl)
	col.add_child(head)
	var nl := UiTheme.label("%s (gốc)" % Items.base_text(item, plus + 1), "Small", DETAIL_W)
	nl.add_theme_color_override("font_color", UiTheme.GOOD)
	col.add_child(nl)
	col.add_child(ShopW.cost_row([
		["res-gold", cost.gold, int(p.gold), "Vàng"],
		["res-stone", cost.stones, int(p.stones), "Đá Cường Hoá"],
		["res-tinh_kim", cost.tinh_kim, int(p.tinh_kim), "Tinh Kim"],
	]))
	if rate < 1.0:
		col.add_child(UiTheme.label("Thất bại chỉ mất nguyên liệu, món đồ giữ nguyên.", "Small", DETAIL_W))
	var blocker := Items.enhance_blocker(p, item)
	var brow := UiTheme.hbox(8)
	col.add_child(brow)
	var b := UiTheme.button("Cường hoá", true)
	b.name = "EnhanceButton"
	b.disabled = blocker != ""
	b.pressed.connect(func():
		var res: Dictionary = world.enhance(int(item.id))
		refresh()
		if res.ok:
			_play_burst(res.get("success", false), int(Items.find_item(world.profile, int(item.id)).item.plus),
				Items.display_name(Items.find_item(world.profile, int(item.id)).item)))
	brow.add_child(b)
	var fb := UiTheme.button("Lò Rèn (R)")
	fb.name = "ForgeButton"
	fb.tooltip_text = "Bảng chi phí mọi cấp, chế tạo, luyện nguyên liệu"
	fb.pressed.connect(func(): open_forge.emit())
	brow.add_child(fb)
	if blocker != "":
		var w := UiTheme.label(blocker, "", DETAIL_W)
		w.add_theme_color_override("font_color", Color("#ffb27a"))
		w.add_theme_font_size_override("font_size", 13)
		col.add_child(w)


func _show_tip(item: Dictionary, in_bag: bool) -> void:
	_hide_tip()
	if not visible or world == null:
		return
	_tip = ItemTip.make(world, item, in_bag)
	add_child(_tip)
	_tip.place(get_global_mouse_position() if is_inside_tree() else Vector2.ZERO)


func _hide_tip() -> void:
	if is_instance_valid(_tip):
		_tip.queue_free()
	_tip = null


func close() -> void:
	_hide_tip()
	super.close()


## SN10-01: kết quả cường hoá hiện giữa màn hình (EnhanceToast), không còn hiệu ứng nhỏ trên chân dung.
func _play_burst(success: bool, plus: int, label := "") -> void:
	EnhanceToast.pop(self, success, plus, label)


## UI-11: mở Túi đồ ở một tab (phím I → "bag", phím C → "stats"). Đang mở đúng tab đó thì đóng.
func toggle_tab(w, tab: String) -> void:
	if visible and _tab == tab:
		close()
		return
	_tab = tab
	open(w)
