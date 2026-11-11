extends RefCounted
## CR-04 (docs/CR-04): khung dưới lưới Túi đồ.
## - "Tự động" (CR-04.3): chế độ Tắt / Khi nhặt / Khi túi đầy, bảng Giữ / Bán / Phân rã theo phẩm chất (bấm để đổi),
##   mẫu cấu hình, ngoại lệ luôn giữ, thống kê phiên, nút "Áp dụng cho túi" (hỏi xác nhận như BulkBox).
## - "Mua lại" (TD-11): 10 món bán gần nhất trong phiên, mua lại đúng giá đã bán.

const UiTheme = preload("res://scripts/ui/ui_theme.gd")
const ItemData = preload("res://scripts/data/items.gd")
const Items = preload("res://scripts/core/items.gd")
const SpriteLib = preload("res://scripts/view/sprite_lib.gd")
const Ornate = preload("res://scripts/ui/ornate.gd")

## Màu hành động (dùng cả cho dấu trên ô túi).
const ACT_COLOR := {"keep": Color("#9aa3b2"), "sell": Color("#ffc940"), "salvage": Color("#ff5470")}

## Đang hỏi xác nhận "Áp dụng cho túi". Đổi quy tắc thì huỷ hỏi.
static var confirming := false
## TD-17 (U3): đang xem trang Nâng cao (theo ô / theo dòng chỉ số).
static var advanced := false


static func build(world, refresh: Callable, width := 390.0) -> VBoxContainer:
	if advanced:
		return build_advanced(world, refresh, width)
	var col := UiTheme.vbox(5)
	col.custom_minimum_size.x = width
	var r: Dictionary = world.loot_rules()
	# tiêu đề + mẫu cấu hình sẵn cùng một hàng (khung phải vừa túi đồ ở 1366×768)
	var head := UiTheme.hbox(4)
	var hl := UiTheme.label("TỰ XỬ LÝ ĐỒ", "Eyebrow")
	hl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	head.add_child(hl)
	head.add_child(UiTheme.spacer())
	var cur := Items.rules_preset(r)
	head.add_child(_cap("Mẫu:" if cur != "" else "Mẫu (đang tuỳ chỉnh):", 0))
	for k in Items.LOOT_PRESETS:
		var b := _seg(Items.LOOT_PRESETS[k][0], cur == k, UiTheme.GOLD)
		b.name = "LootPreset_" + k
		b.tooltip_text = _preset_tip(k)
		var pk: String = k
		b.pressed.connect(func():
			var nr: Dictionary = world.loot_rules()
			nr.by_rarity = (Items.LOOT_PRESETS[pk][1] as Dictionary).duplicate()
			_save_rules(world, nr, refresh))
		head.add_child(b)
	col.add_child(head)

	# chế độ
	var mr := UiTheme.hbox(4)
	mr.add_child(_cap("Chế độ", 58))
	for m in Items.LOOT_MODES:
		var on: bool = r.mode == m
		var b := _seg(Items.LOOT_MODE_NAMES[m], on, UiTheme.GOOD if m != "off" else UiTheme.MUTED)
		b.name = "LootMode_" + m
		b.tooltip_text = {"off": "Không tự xử lý — đồ nhặt được vào túi như cũ.",
			"pickup": "Món nhặt được khớp Bán / Phân rã được xử lý ngay, không vào túi.",
			"full": "Túi còn chỗ thì vào túi; túi đầy thì món mới xử lý theo bảng dưới."}[m]
		var mid: String = m
		b.pressed.connect(func():
			var nr: Dictionary = world.loot_rules()
			nr.mode = mid
			_save_rules(world, nr, refresh))
		mr.add_child(b)
	mr.add_child(UiTheme.spacer())
	var n_adv := Items.rules_advanced_count(r)
	var adv := _seg("Nâng cao%s ▸" % ((" (%d)" % n_adv) if n_adv > 0 else ""), n_adv > 0, UiTheme.GOLD)
	adv.name = "LootAdvanced"
	adv.tooltip_text = "Quy tắc theo ô trang bị và luôn giữ đồ có dòng chỉ số chọn sẵn."
	adv.pressed.connect(func():
		advanced = true
		confirming = false
		refresh.call())
	mr.add_child(adv)
	col.add_child(mr)

	# bảng phẩm chất: bấm để đổi Giữ → Bán → Phân rã (Cam luôn giữ)
	var rr := UiTheme.hbox(4)
	for rid in Items.LOOT_RARITIES:
		var act: String = r.by_rarity[rid]
		var c := Color(ItemData.RARITIES[rid].color)
		var ac: Color = ACT_COLOR[act]
		var b := UiTheme.button("%s\n%s" % [ItemData.RARITIES[rid].name, Items.LOOT_ACTION_NAMES[act]])
		b.name = "LootRarity_" + rid
		b.focus_mode = Control.FOCUS_NONE
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.add_theme_font_size_override("font_size", UiTheme.fs(12))
		b.add_theme_color_override("font_color", ac if act != "keep" else c)
		b.add_theme_color_override("font_hover_color", Color.WHITE)
		b.add_theme_stylebox_override("normal", UiTheme.box(Color(c, 0.10), 6, 2 if act != "keep" else 1, c if act != "keep" else Color(c, 0.4), 4))
		b.add_theme_stylebox_override("hover", UiTheme.box(Color(c, 0.22), 6, 2, c, 4))
		b.add_theme_stylebox_override("pressed", UiTheme.box(Color(c, 0.30), 6, 2, c, 4))
		b.tooltip_text = "%s: bấm để đổi Giữ → Bán → Phân rã. Đồ Cam luôn được giữ." % ItemData.RARITIES[rid].name
		var key: String = rid
		b.pressed.connect(func():
			var nr: Dictionary = world.loot_rules()
			var i := Items.LOOT_ACTIONS.find(str(nr.by_rarity[key]))
			nr.by_rarity[key] = Items.LOOT_ACTIONS[(i + 1) % Items.LOOT_ACTIONS.size()]
			_save_rules(world, nr, refresh))
		rr.add_child(b)
	col.add_child(rr)

	# ngoại lệ luôn giữ
	var g := GridContainer.new()
	g.columns = 2
	g.add_theme_constant_override("h_separation", 10)
	g.add_theme_constant_override("v_separation", 0)
	for opt in [["keep_plus", "Giữ đồ đã cường hoá"], ["keep_set", "Giữ đồ bộ"], ["keep_better", "Giữ đồ mạnh hơn đang mặc"]]:
		var cb := _check(opt[1], bool(r[opt[0]]))
		cb.name = "LootOpt_" + opt[0]
		var key: String = opt[0]
		cb.toggled.connect(func(v: bool):
			var nr: Dictionary = world.loot_rules()
			nr[key] = v
			_save_rules(world, nr, refresh))
		g.add_child(cb)
	var gap_row := UiTheme.hbox(2)
	var gap: int = int(r.keep_level_gap)
	var gcb := _check("Giữ đồ cấp ≥ mình −", gap >= 0)
	gcb.name = "LootOpt_gap"
	gcb.tooltip_text = "Giữ đồ có cấp từ (cấp nhân vật − N) trở lên."
	gcb.toggled.connect(func(v: bool):
		var nr: Dictionary = world.loot_rules()
		nr.keep_level_gap = 5 if v else -1
		_save_rules(world, nr, refresh))
	gap_row.add_child(gcb)
	var sp := SpinBox.new()
	sp.name = "LootGap"
	sp.min_value = 0
	sp.max_value = Items.LOOT_GAP_MAX
	sp.value = gap if gap >= 0 else 5
	sp.editable = gap >= 0
	sp.custom_minimum_size.x = 64
	sp.add_theme_font_size_override("font_size", UiTheme.fs(12))
	sp.value_changed.connect(func(v: float):
		var nr: Dictionary = world.loot_rules()
		if int(nr.keep_level_gap) >= 0:
			nr.keep_level_gap = int(v)
			_save_rules(world, nr, refresh))
	gap_row.add_child(sp)
	g.add_child(gap_row)
	col.add_child(g)

	# thống kê phiên + áp dụng cho túi hiện tại
	var st: Dictionary = world.loot_stats
	var pv: Dictionary = world.loot_preview()
	var n_sell: int = pv.sell.size()
	var n_salv: int = pv.salvage.size()
	if confirming and n_sell + n_salv > 0:
		col.add_child(UiTheme.label("Bán %d món (+%s vàng), phân rã %d món (+%s đá)? Món bán mua lại được ở tab Mua lại." % [
			n_sell, Ornate.group(int(pv.gold)), n_salv, Ornate.group(int(pv.stones))], "", width))
		var row := UiTheme.hbox(8)
		var yes := UiTheme.button("Đồng ý", true)
		yes.name = "LootApplyConfirm"
		yes.pressed.connect(func():
			confirming = false
			world.loot_apply()
			refresh.call())
		row.add_child(yes)
		var no := UiTheme.button("Huỷ")
		no.pressed.connect(func():
			confirming = false
			refresh.call())
		row.add_child(no)
		col.add_child(row)
	else:
		confirming = false
		var row := UiTheme.hbox(8)
		var sl := UiTheme.label("Phiên này: tự bán %d (+%s vàng) · tự phân rã %d (+%s đá)" % [
			int(st.sold), Ornate.group(int(st.gold)), int(st.salvaged), Ornate.group(int(st.stones))], "Small")
		sl.name = "LootStats"
		sl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		sl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		sl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		sl.tooltip_text = "Món khoá và đồ Cam luôn được giữ."
		row.add_child(sl)
		var go := UiTheme.button("Áp dụng cho túi (%d)" % (n_sell + n_salv), true)
		go.name = "LootApply"
		go.add_theme_font_size_override("font_size", UiTheme.fs(13))
		go.disabled = n_sell + n_salv == 0
		go.tooltip_text = "Chạy bảng quy tắc một lần lên đồ đang có trong túi: bán %d, phân rã %d (dấu vàng = bán, đỏ = phân rã)." % [n_sell, n_salv]
		go.pressed.connect(func():
			confirming = true
			refresh.call())
		row.add_child(go)
		col.add_child(row)
	return col


## TD-17 (U3): trang Nâng cao — ô ghi đè bảng phẩm chất (bấm xoay Theo bảng → Giữ → Bán → Phân rã),
## dòng chỉ số luôn giữ (bật / tắt). Thứ tự xét: khoá / Cam → dòng chỉ số → ô → phẩm chất → ngoại lệ.
const SLOT_ACTION_NAMES := {"rule": "Theo bảng", "keep": "Giữ", "sell": "Bán", "salvage": "Phân rã"}
## Nhãn ngắn cho nút ô (một dòng, 4 cột vừa khung ở 1366×768); tên đủ ở tooltip.
const SLOT_SHORT := {"weapon": "Vũ khí", "helm": "Mũ", "armor": "Áo", "gloves": "Găng", "boots": "Giày",
	"necklace": "Dây chuyền", "ring": "Nhẫn", "amulet": "Bùa"}
const SLOT_ACTION_SHORT := {"rule": "Bảng", "keep": "Giữ", "sell": "Bán", "salvage": "Rã"}


static func build_advanced(world, refresh: Callable, width := 390.0) -> VBoxContainer:
	var col := UiTheme.vbox(5)
	col.custom_minimum_size.x = width
	var r: Dictionary = world.loot_rules()
	var head := UiTheme.hbox(4)
	var hl := UiTheme.label("QUY TẮC NÂNG CAO", "Eyebrow")
	hl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	head.add_child(hl)
	head.add_child(UiTheme.spacer())
	var reset := _seg("Xoá hết", false, UiTheme.MUTED)
	reset.name = "LootAdvReset"
	reset.pressed.connect(func():
		var nr: Dictionary = world.loot_rules()
		var d := Items.default_rules()
		nr.by_slot = d.by_slot
		nr.keep_stats = []
		_save_rules(world, nr, refresh))
	head.add_child(reset)
	var back := _seg("◂ Quay lại", true, UiTheme.GOLD)
	back.name = "LootAdvBack"
	back.pressed.connect(func():
		advanced = false
		refresh.call())
	head.add_child(back)
	col.add_child(head)

	col.add_child(_cap("Theo ô (ưu tiên hơn bảng phẩm chất; Bảng = theo phẩm chất):", 0))
	var sg := GridContainer.new()
	sg.columns = 4
	sg.add_theme_constant_override("h_separation", 4)
	sg.add_theme_constant_override("v_separation", 4)
	for sl in ItemData.SLOT_ORDER:
		var act: String = r.by_slot[sl]
		var on := act != "rule"
		var c: Color = ACT_COLOR.get(act, UiTheme.MUTED) if on else UiTheme.MUTED
		var b := _seg("%s: %s" % [SLOT_SHORT[sl], SLOT_ACTION_SHORT[act]], on, c)
		b.name = "LootSlot_" + sl
		b.tooltip_text = "%s: %s — bấm để đổi Theo bảng → Giữ → Bán → Phân rã." % [ItemData.SLOTS[sl].name, SLOT_ACTION_NAMES[act]]
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var key: String = sl
		b.pressed.connect(func():
			var nr: Dictionary = world.loot_rules()
			var i := Items.LOOT_SLOT_ACTIONS.find(str(nr.by_slot[key]))
			nr.by_slot[key] = Items.LOOT_SLOT_ACTIONS[(i + 1) % Items.LOOT_SLOT_ACTIONS.size()]
			_save_rules(world, nr, refresh))
		sg.add_child(b)
	col.add_child(sg)

	col.add_child(_cap("Luôn giữ đồ có dòng chỉ số:", 0))
	var ag := GridContainer.new()
	ag.columns = 4
	ag.add_theme_constant_override("h_separation", 4)
	ag.add_theme_constant_override("v_separation", 4)
	# HR-1 (docs/49 §G): 7 dòng hồi phục gộp 1 nút "Dòng hồi phục" (bật = giữ món có bất kỳ dòng hồi nào) — lưới giữ 4 hàng
	var rec: Array = ItemData.AFFIXES.keys().filter(func(k): return Items.is_recover(k))
	var rec_on: bool = rec.all(func(k): return k in r.keep_stats)
	var rb := _seg("Dòng hồi phục", rec_on, UiTheme.GOOD)
	rb.name = "LootStat_recover"
	rb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rb.tooltip_text = "Giữ đồ có dòng hồi phục: " + ", ".join(rec.map(func(k): return str(ItemData.AFFIXES[k].name)))
	rb.pressed.connect(func():
		var nr: Dictionary = world.loot_rules()
		for k in rec:
			nr.keep_stats.erase(k)
			if not rec_on:
				nr.keep_stats.append(k)
		_save_rules(world, nr, refresh))
	for st in ItemData.AFFIXES:
		if Items.is_recover(st):
			continue
		var on: bool = st in r.keep_stats
		var b := _seg(str(ItemData.AFFIXES[st].name).replace("Sát thương chí mạng", "ST chí mạng"), on, UiTheme.GOOD)
		b.name = "LootStat_" + st
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.tooltip_text = ItemData.AFFIXES[st].name
		var key: String = st
		b.pressed.connect(func():
			var nr: Dictionary = world.loot_rules()
			if key in nr.keep_stats:
				nr.keep_stats.erase(key)
			else:
				nr.keep_stats.append(key)
			_save_rules(world, nr, refresh))
		ag.add_child(b)
	ag.add_child(rb)
	col.add_child(ag)
	return col


## TD-11: danh sách mua lại.
static func build_buyback(world, refresh: Callable, width := 390.0) -> VBoxContainer:
	var col := UiTheme.vbox(5)
	col.custom_minimum_size.x = width
	col.add_child(UiTheme.label("MUA LẠI (10 MÓN BÁN GẦN NHẤT, TRONG PHIÊN)", "Eyebrow"))
	var list: Array = world.buyback_list
	if list.is_empty():
		col.add_child(UiTheme.label("Chưa bán món nào trong phiên này.", "Muted", width))
		return col
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(width, 168)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var v := UiTheme.vbox(3)
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for i in list.size():
		var e: Dictionary = list[i]
		var it: Dictionary = e.item
		var row := UiTheme.hbox(6)
		row.name = "Buyback_%d" % i
		row.add_child(UiTheme.icon_rect(SpriteLib.item_icon(it), 26))
		var nl := UiTheme.label(Items.display_name(it))
		nl.add_theme_color_override("font_color", Items.rarity_color(it))
		nl.add_theme_font_size_override("font_size", UiTheme.fs(13))
		nl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		nl.clip_text = true
		row.add_child(nl)
		var b := UiTheme.button("Mua lại %s vàng" % Ornate.group(int(e.price)))
		b.add_theme_font_size_override("font_size", UiTheme.fs(12))
		b.disabled = int(world.profile.gold) < int(e.price) or world.profile.inventory.size() >= ItemData.BAG_SIZE
		var idx := i
		b.pressed.connect(func():
			world.buyback(idx)
			refresh.call())
		row.add_child(b)
		v.add_child(row)
	scroll.add_child(v)
	col.add_child(scroll)
	return col


## Id món trong túi → màu dấu (quy tắc tự động: vàng = sẽ bán, đỏ = sẽ phân rã).
static func marked_ids(world) -> Dictionary:
	var out := {}
	var pv: Dictionary = world.loot_preview()
	for it in pv.sell:
		out[int(it.id)] = ACT_COLOR.sell
	for it in pv.salvage:
		out[int(it.id)] = ACT_COLOR.salvage
	return out


static func _save_rules(world, nr: Dictionary, refresh: Callable) -> void:
	world.set_loot_rules(nr)
	confirming = false
	refresh.call_deferred()


static func _cap(text: String, w: float) -> Label:
	var l := UiTheme.label(text, "Small")
	if w > 0.0:
		l.custom_minimum_size.x = w
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return l


static func _seg(text: String, on: bool, c: Color) -> Button:
	var b := UiTheme.button(text)
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_font_size_override("font_size", UiTheme.fs(12))
	b.add_theme_color_override("font_color", c if on else UiTheme.MUTED)
	b.add_theme_stylebox_override("normal", UiTheme.box(Color(c, 0.22) if on else Color(c, 0.04), 6, 2 if on else 1, c if on else Color(c, 0.3), 5))
	b.add_theme_stylebox_override("hover", UiTheme.box(Color(c, 0.25), 6, 2, c, 5))
	return b


static func _check(text: String, on: bool) -> CheckBox:
	var cb := CheckBox.new()
	cb.text = text
	cb.button_pressed = on
	cb.focus_mode = Control.FOCUS_NONE
	cb.add_theme_font_size_override("font_size", UiTheme.fs(12))
	for st in ["normal", "hover", "pressed", "hover_pressed", "disabled", "focus"]:
		var e := StyleBoxEmpty.new()
		e.content_margin_top = 1
		e.content_margin_bottom = 1
		e.content_margin_left = 2
		cb.add_theme_stylebox_override(st, e)
	return cb


static func _preset_tip(k: String) -> String:
	var parts: Array = []
	for rid in Items.LOOT_RARITIES:
		parts.append("%s: %s" % [ItemData.RARITIES[rid].name, Items.LOOT_ACTION_NAMES[Items.LOOT_PRESETS[k][1][rid]]])
	return ", ".join(parts)
