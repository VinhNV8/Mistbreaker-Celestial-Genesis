extends "res://scripts/ui/modal.gd"
## Túi đồ (phím I; phím C mở thẳng tab Chỉ số — UI-11) — EQ-18: ô đang mặc, túi 30 ô, chi tiết + so sánh, Mặc/Tháo/Cường hoá/Phân rã.
## UI-21: giao diện mới 3 cột (nhân vật · nội dung tab · Lực chiến/chi tiết), khung gỗ-vàng, icon chỉ số.

const Items = preload("res://scripts/core/items.gd")
const ItemData = preload("res://scripts/data/items.gd")
const ItemCard = preload("res://scripts/ui/item_card.gd")
const SpriteLib = preload("res://scripts/view/sprite_lib.gd")
const Classes = preload("res://scripts/data/classes.gd")
const Resources = preload("res://scripts/data/resources.gd")
const CreateScreen = preload("res://scripts/ui/create_screen.gd")
const BulkBox = preload("res://scripts/ui/bulk_box.gd")
const LootBox = preload("res://scripts/ui/loot_box.gd")
const StatsPage = preload("res://scripts/ui/stats_page.gd")
const CharWidgets = preload("res://scripts/ui/char_widgets.gd")
const Talents = preload("res://scripts/data/talents.gd")
const Ch4 = preload("res://scripts/core/chapter4.gd")
const Ch7 = preload("res://scripts/core/chapter7.gd")
const ShopW = preload("res://scripts/ui/shop_widgets.gd")
const Ornate = preload("res://scripts/ui/ornate.gd")
const CharBar = preload("res://scripts/ui/char_bar.gd")
const EnhanceToast = preload("res://scripts/ui/enhance_toast.gd")
const EnhanceFx = preload("res://scripts/ui/enhance_fx.gd")
const ItemTip = preload("res://scripts/ui/item_tip.gd")

const DETAIL_W := 300.0

var _selected_id := -1
## SN11-01, 02: thẻ thông tin trang bị đang hiện khi rê chuột (null nếu không có).
var _tip: Control = null
## "bag" | "res" | "stats" (UI-11: bảng Chỉ số gộp vào Túi đồ)
var _tab := "bag"
## Hiệu ứng vừa cường hoá: {item_id, success, plus, t}
var _fx := {}
## CR-04: khung dưới lưới túi — "salvage" (Phân rã nhanh) | "sell" (Bán nhanh) | "auto" (Tự động) | "buyback" (Mua lại).
var _bottom := "salvage"
## CR-04: món đang rê chuột trong túi (phím S bán / D phân rã / L khoá), -1 = không.
var _hover_id := -1
## CR-04 TD-01: món đang chờ bấm lần 2 để bán ("sell") / phân rã ("salvage"): {id, act, t (ms)}.
## R3: tự huỷ sau CONFIRM_MS, khi đổi món, đổi khung dưới, mở / đóng bảng.
var _confirm := {}
const CONFIRM_MS := 4000

## TD-19 (U5): phần tự xử lý từ lần mở Túi đồ trước (lấy lúc mở bảng).
var _since := {}

const BOTTOM_TABS := [["salvage", "Phân rã nhanh"], ["sell", "Bán nhanh"], ["auto", "Tự động"], ["buyback", "Mua lại"]]


## CR-04.2: ổ khoá nhỏ góc trên trái ô đồ đã khoá.
class LockMark:
	extends Control

	func _draw() -> void:
		var o := Vector2(4, 4)
		draw_rect(Rect2(o + Vector2(0, 0), Vector2(16, 16)), Color(0, 0, 0, 0.7))
		draw_arc(o + Vector2(8, 7), 3.6, PI, TAU, 10, Color("#ffe08a"), 1.8, true)
		draw_rect(Rect2(o + Vector2(3, 7), Vector2(10, 7)), Color("#ffce50"))
		draw_rect(Rect2(o + Vector2(7, 9), Vector2(2, 3)), Color(0.2, 0.12, 0.02))


## Spec_Notes N8: khung phát sáng theo cấp cường hoá + số "+N" trên ô đồ.
## UI-63 (docs/38): chấm phẩm chất góc dưới trái ô đồ — Trắng 1 … Cam 5 chấm, để phẩm chất không chỉ báo bằng màu viền.
class RarityPips:
	extends Control
	var n := 1
	var col := Color.WHITE

	func _draw() -> void:
		for i in n:
			var c := Vector2(7.0 + i * 6.0, size.y - 7.0)
			draw_circle(c, 2.8, Color(0, 0, 0, 0.85))
			draw_circle(c, 1.9, col)


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
	if _tab == "bag":
		var lc := _loot_card()
		if lc != null:
			col.add_child(lc)
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
## TD-19 (U5): thẻ "Tự xử lý đồ" — đang bật chế độ nào, đã xử lý gì từ lần mở Túi đồ trước.
func _loot_card() -> PanelContainer:
	var r: Dictionary = world.loot_rules()
	var any := int(_since.get("sold", 0)) + int(_since.get("salvaged", 0)) > 0
	if str(r.mode) == "off" and not any:
		return null
	var pc := UiTheme.panel(UiTheme.box(Color("#0e0a06", 0.85), 8, 1, UiTheme.GOLD_DARK, 10))
	pc.name = "LootSummary"
	var v := UiTheme.vbox(3)
	pc.add_child(v)
	v.add_child(UiTheme.label("TỰ XỬ LÝ ĐỒ · %s" % str(Items.LOOT_MODE_NAMES[r.mode]).to_upper(), "Eyebrow"))
	var txt := "Từ lần mở túi trước: chưa xử lý món nào."
	if any:
		txt = "Từ lần mở túi trước: tự bán %d món (+%s vàng), tự phân rã %d món (+%s đá)." % [int(_since.sold),
			Ornate.group(int(_since.gold)), int(_since.salvaged), Ornate.group(int(_since.stones))]
	var l := UiTheme.label(txt, "Small", 300)
	l.name = "LootSummaryText"
	v.add_child(l)
	return pc


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
			# UI-64 (docs/42): ô trống = bóng khắc chìm của loại đồ (mờ, không màu) trên nền ô trống
			b.icon = SpriteLib.icon("item-" + slot)
			ItemCard.style_slot(b, {})
			b.add_theme_color_override("icon_normal_color", Color(0.75, 0.68, 0.55, 0.22))
			b.add_theme_color_override("icon_disabled_color", Color(0.75, 0.68, 0.55, 0.22))
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
	# TD-18 (U4): khoá nhanh đồ đang mặc · TD-15 (U1): sắp xếp túi
	var all_locked: bool = world.worn_all_locked()
	var lw := LootBox._seg("Mở khoá đồ mặc" if all_locked else "Khoá đồ mặc", all_locked, Color("#ffce50"))
	lw.name = "LockWorn"
	lw.tooltip_text = "Khoá / mở khoá mọi món đang mặc — món khoá tháo ra vẫn không bị bán, phân rã hay tự xử lý."
	lw.pressed.connect(func():
		world.toggle_lock_worn()
		refresh())
	head.add_child(lw)
	var sort := MenuButton.new()
	sort.name = "SortBag"
	sort.text = "Sắp xếp ▾"
	sort.flat = false
	sort.focus_mode = Control.FOCUS_NONE
	sort.add_theme_font_size_override("font_size", UiTheme.fs(12))
	for st in ["normal", "hover", "pressed"]:
		sort.add_theme_stylebox_override(st, UiTheme.box(Color(UiTheme.GOLD, 0.06 if st == "normal" else 0.22), 6, 1, Color(UiTheme.GOLD, 0.5), 5))
	sort.tooltip_text = "Sắp xếp túi (món khoá luôn đứng đầu)."
	var modes: Array = Items.SORT_MODES.keys()
	for i in modes.size():
		sort.get_popup().add_item("Theo " + str(Items.SORT_MODES[modes[i]]).to_lower(), i)
	sort.get_popup().id_pressed.connect(func(i: int):
		world.sort_bag(str(modes[i]))
		refresh())
	head.add_child(sort)
	var cnt := UiTheme.panel(UiTheme.box(Color("#0e0a06"), 6, 1, UiTheme.GOLD_DARK, 6))
	cnt.add_child(UiTheme.strong("%d/%d" % [p.inventory.size(), ItemData.BAG_SIZE], 14))
	head.add_child(cnt)
	col.add_child(head)
	var grid := GridContainer.new()
	grid.columns = 6
	grid.add_theme_constant_override("h_separation", 5)
	grid.add_theme_constant_override("v_separation", 5)
	# SN-11 / CR-04: dấu góc theo khung dưới đang mở — bộ lọc nhanh (đỏ) hoặc quy tắc tự động (vàng = bán, đỏ = phân rã).
	var marked := {}
	if _bottom == "auto":
		marked = LootBox.marked_ids(world)
	elif _bottom != "buyback":
		for id in BulkBox.marked_ids(world):
			marked[id] = Color("#ff5470")
	for i in ItemData.BAG_SIZE:
		var item: Dictionary = p.inventory[i] if i < p.inventory.size() else {}
		var b := _item_button(item, "", true, "bag")
		b.name = "Bag_%d" % i
		# SN-11: món khớp bộ lọc phân rã nhanh có dấu đỏ ở góc.
		if not item.is_empty() and marked.has(int(item.id)):
			var dot := ColorRect.new()
			dot.color = marked[int(item.id)]
			dot.size = Vector2(8, 8)
			dot.position = Vector2(4, 4)
			dot.mouse_filter = MOUSE_FILTER_IGNORE
			b.add_child(dot)
		b.custom_minimum_size = Vector2(62, 58)
		b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		b.expand_icon = true
		if item.is_empty():
			ItemCard.style_slot(b, {})
		b.disabled = item.is_empty()
		grid.add_child(b)
	col.add_child(grid)
	col.add_child(HSeparator.new())
	var tabs := UiTheme.hbox(4)
	for t in BOTTOM_TABS:
		var on: bool = _bottom == t[0]
		var label: String = t[1]
		if t[0] == "buyback" and not world.buyback_list.is_empty():
			label += " (%d)" % world.buyback_list.size()
		if t[0] == "auto" and str(world.loot_rules().mode) != "off":
			label += " ●"
		var b := LootBox._seg(label, on, UiTheme.GOLD)
		b.name = "Bottom_" + t[0]
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var key: String = t[0]
		b.pressed.connect(func():
			_bottom = key
			_confirm = {}
			refresh())
		tabs.add_child(b)
	col.add_child(tabs)
	match _bottom:
		"auto":
			col.add_child(LootBox.build(world, refresh, 390.0))
		"buyback":
			col.add_child(LootBox.build_buyback(world, refresh, 390.0))
		_:
			col.add_child(BulkBox.build(world, _bottom, refresh, 390.0))
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
		var hid := int(item.id)
		b.set_meta("cr4_item", hid)
		b.mouse_entered.connect(func():
			_hover_id = hid
			_show_tip(it, in_bag))
		b.mouse_exited.connect(func():
			if _hover_id == hid:
				_hover_id = -1
			_hide_tip())
	var pips := RarityPips.new()
	pips.n = ItemData.RARITY_ORDER.find(str(item.rarity)) + 1
	pips.col = c
	pips.mouse_filter = MOUSE_FILTER_IGNORE
	pips.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	b.add_child(pips)
	# EN-1 (docs/43): hiệu ứng cường hoá hướng D (ánh kim / linh hoả + vệt sáng chạy quanh viền + tấm "+N")
	EnhanceFx.attach(b, item, b.icon, 3.0, 7.0)
	var selected := int(item.id) == _selected_id
	# UI-64 (docs/42): ô đồ theo bậc phẩm chất — nền nhuộm màu toả từ đáy, khung đổi hình theo bậc, icon ~90% ô
	ItemCard.style_slot(b, item, selected)
	if Items.is_locked(item):
		var lk := LockMark.new()
		lk.name = "Lock"
		lk.mouse_filter = MOUSE_FILTER_IGNORE
		lk.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
		b.add_child(lk)
	b.add_theme_color_override("font_color", c.lightened(0.25))
	b.add_theme_color_override("font_hover_color", Color.WHITE)
	var id := int(item.id)
	b.pressed.connect(func():
		if id != _selected_id:
			_confirm = {}
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
	# UI-66 (docs/42): phần thông tin = thẻ ItemCard (dải đầu nhuộm màu phẩm chất, icon lớn, chỉ số chính số to, dòng
	# phụ có biểu tượng, bộ, so sánh dạng chip ▲ ▼); nút Mặc / Phân rã / Cường hoá giữ như cũ bên dưới.
	var diff: Array = []
	var ctitle := ""
	var note := ""
	if in_bag:
		# SN11-02: so sánh với đồ đang mặc cùng ô (▲ / ▼ từng chỉ số + Lực chiến)
		var worn: Dictionary = p.equipment.get(str(item.slot), {})
		ctitle = ("So với đang mặc: %s" % Items.display_name(worn)) if not worn.is_empty() else "Ô này đang trống — mặc vào:"
		diff = ItemTip.diff_lines(world, item, worn)
		# SN-20: báo trước cấp cường hoá được chuyển từ đồ đang mặc.
		var moved := Items.plus_after_equip(p, item)
		if moved > int(item.plus):
			note = "Mặc vào: nhận +%d từ đồ đang mặc (đồ cũ còn +%d)." % [moved, int(item.plus)]
	col.add_child(ItemCard.build(item, DETAIL_W, "", p, diff, ctitle, note))

	col.add_child(HSeparator.new())
	var row := UiTheme.hbox(6)
	var locked := Items.is_locked(item)
	var id := int(item.id)
	if in_bag:
		var wear := UiTheme.button("Mặc", true)
		wear.pressed.connect(func():
			world.equip(id)
			refresh())
		row.add_child(wear)
		# CR-04.1 TD-01: bán ngay trong túi, ở mọi nơi (Q211: đủ giá).
		for a in [["sell", "Bán +%s vàng" % Ornate.group(world.sell_price(item, p))], ["salvage", "Phân rã +%d đá" % Items.salvage_value(item, p)]]:
			var act: String = a[0]
			var asking: bool = _asking(id, act)
			var ab := UiTheme.button(("Chắc chắn? " + a[1]) if asking else a[1], asking)
			ab.name = "SellButton" if act == "sell" else "SalvageButton"
			ab.add_theme_font_size_override("font_size", UiTheme.fs(13))
			ab.disabled = locked
			ab.tooltip_text = Items.LOCKED_MSG if locked else ("Phím S" if act == "sell" else "Phím D")
			ab.pressed.connect(func():
				_do_item_action(id, act)
				refresh())
			row.add_child(ab)
	else:
		var off := UiTheme.button("Tháo")
		off.pressed.connect(func():
			world.unequip(str(item.slot))
			refresh())
		row.add_child(off)
	col.add_child(row)
	# CR-04.2 TD-06: khoá đồ — không bán / phân rã / tự xử lý được.
	var lrow := UiTheme.hbox(6)
	var lb := UiTheme.button("Mở khoá (L)" if locked else "Khoá (L)")
	lb.name = "LockButton"
	lb.add_theme_font_size_override("font_size", UiTheme.fs(13))
	lb.tooltip_text = "Món khoá không bán, phân rã hay tự xử lý được (kể cả khớp bộ lọc)."
	lb.pressed.connect(func():
		world.toggle_lock(id)
		refresh())
	lrow.add_child(lb)
	if locked:
		var ll := UiTheme.label("Đã khoá", "Small")
		ll.add_theme_color_override("font_color", Color("#ffce50"))
		ll.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lrow.add_child(ll)
	col.add_child(lrow)
	_enhance_block(col, p, item)
	return col


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
	if blocker != "":
		b.tooltip_text = blocker  # UI-62: lý do khoá
	b.pressed.connect(func():
		var res: Dictionary = world.enhance(int(item.id))
		refresh()
		if res.ok:
			_play_burst(res.get("success", false), int(Items.find_item(world.profile, int(item.id)).item.plus),
				Items.display_name(Items.find_item(world.profile, int(item.id)).item), SpriteLib.item_icon(item)))
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


## R3: đang chờ bấm lần 2 cho (id, act) và chưa quá CONFIRM_MS.
func _asking(id: int, act: String) -> bool:
	return int(_confirm.get("id", -1)) == id and str(_confirm.get("act", "")) == act 		and Time.get_ticks_msec() - int(_confirm.get("t", 0)) < CONFIRM_MS


## CR-04 TD-01: món Tím trở lên hoặc đã cường hoá từ +4 phải bấm 2 lần (lần 1 hỏi lại).
static func needs_confirm(item: Dictionary) -> bool:
	return str(item.rarity) in ["purple", "orange"] or int(item.plus) >= 4


## Bán / phân rã một món trong túi, có bước hỏi lại. Trả true nếu đã thực hiện.
func _do_item_action(id: int, act: String) -> bool:
	var found := Items.find_item(world.profile, id)
	if found.is_empty() or found.where != "bag":
		return false
	var item: Dictionary = found.item
	if Items.is_locked(item):
		world._message(Items.LOCKED_MSG, "bad")
		return false
	if needs_confirm(item) and not _asking(id, act):
		_confirm = {"id": id, "act": act, "t": Time.get_ticks_msec()}
		_selected_id = id
		return false
	_confirm = {}
	if act == "sell":
		world.sell_item(id)
	else:
		world.salvage(id)
	if _selected_id == id:
		_selected_id = -1
	return true


## CR-04 TD-04: rê chuột lên món trong túi — S bán, D phân rã, L khoá / mở khoá (bán / phân rã vẫn hỏi lại như nút).
func _input(event: InputEvent) -> void:
	if not visible or world == null or _tab != "bag" or _hover_id < 0:
		return
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	var code: int = (event as InputEventKey).physical_keycode
	if not (code in [KEY_S, KEY_D, KEY_L]):
		return
	var found := Items.find_item(world.profile, _hover_id)
	if found.is_empty() or not _really_hovered(_hover_id):
		return
	if get_viewport() != null:
		get_viewport().set_input_as_handled()
	if code == KEY_L:
		world.toggle_lock(_hover_id)
	elif found.where == "bag":
		_do_item_action(_hover_id, "sell" if code == KEY_S else "salvage")
	_hover_id = -1 if Items.find_item(world.profile, _hover_id).is_empty() else _hover_id
	refresh()


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


## R2: chuột phải đang nằm trên đúng ô của món (không dùng id rê chuột cũ sau khi đóng / mở / dựng lại bảng).
## Ngoài cây cảnh (test headless) thì bỏ qua bước kiểm tra này.
func _really_hovered(id: int) -> bool:
	if not is_inside_tree():
		return true
	var c: Node = get_viewport().gui_get_hovered_control()
	while c != null and c != self:
		if c.has_meta("cr4_item"):
			return int(c.get_meta("cr4_item")) == id
		c = c.get_parent()
	return false


func open(w) -> void:
	_hover_id = -1
	_confirm = {}
	_since = w.loot_since_seen() if w != null and w.has_method("loot_since_seen") else {}
	super.open(w)


func close() -> void:
	_hide_tip()
	_hover_id = -1
	_confirm = {}
	super.close()


## SN10-01: kết quả cường hoá hiện giữa màn hình (EnhanceToast), không còn hiệu ứng nhỏ trên chân dung.
func _play_burst(success: bool, plus: int, label := "", tex: Texture2D = null) -> void:
	EnhanceToast.pop(self, success, plus, label, tex)


## UI-11: mở Túi đồ ở một tab (phím I → "bag", phím C → "stats"). Đang mở đúng tab đó thì đóng.
func toggle_tab(w, tab: String) -> void:
	if visible and _tab == tab:
		close()
		return
	_tab = tab
	open(w)
