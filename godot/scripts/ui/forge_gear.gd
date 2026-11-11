extends RefCounted
## NL-1 (docs/47 §5): các tab mới của Lò Rèn — Khảm ngọc, Tẩy luyện, Thăng phẩm + Luyện cấp, Thức tỉnh, Bảo Giám,
## Gợi ý tăng Lực chiến. Hàm tĩnh nhận `fp` = forge_panel (đọc / ghi fp._item_id…, gọi fp.refresh(), fp.world).

const Items = preload("res://scripts/core/items.gd")
const ItemData = preload("res://scripts/data/items.gd")
const Gear = preload("res://scripts/core/gear.gd")
const GearData = preload("res://scripts/data/gear_data.gd")
const SpriteLib = preload("res://scripts/view/sprite_lib.gd")
const Monsters = preload("res://scripts/data/monsters.gd")
const W = preload("res://scripts/ui/shop_widgets.gd")
const UiTheme = preload("res://scripts/ui/ui_theme.gd")
const ItemCard = preload("res://scripts/ui/item_card.gd")

const CENTER_W := 380.0
const SIDE_W := 300.0
const AFFIX_COL := Color("#9ec8ff")
const AWAKEN_COL := Color("#ffd36a")


## Tab của Lò Rèn → tính năng cần mở.
static func tab_unlocked(p, tab: String) -> bool:
	match tab:
		"gems":
			return Gear.unlocked(p, "gems")
		"reforge":
			return Gear.unlocked(p, "reforge")
		"ascend":
			return Gear.unlocked(p, "ascend") or Gear.unlocked(p, "levelup")
		"awaken":
			return Gear.unlocked(p, "awaken")
	return true


static func tab_lock_text(tab: String) -> String:
	match tab:
		"gems":
			return Gear.lock_text("gems")
		"reforge":
			return Gear.lock_text("reforge")
		"ascend":
			return Gear.lock_text("levelup")
		"awaken":
			return Gear.lock_text("awaken")
	return ""


static func _warn(text: String, w := CENTER_W) -> Label:
	var l := UiTheme.label(text, "", w)
	l.add_theme_color_override("font_color", W.SHORT)
	return l


static func _note(text: String, w := CENTER_W) -> Label:
	var l := UiTheme.label(text, "Small", w)
	l.add_theme_color_override("font_color", Color("#b08a5a"))
	return l


static func _button(text: String, blocker: String, primary := true) -> Button:
	var b := UiTheme.button(text, primary)
	b.custom_minimum_size = Vector2(0, 40)
	b.disabled = blocker != ""
	if blocker != "":
		b.tooltip_text = blocker
	return b


## Ô khoá cả tab (chưa tới chương).
static func locked(body: HBoxContainer, tab: String, title: String, what: String) -> void:
	var sec: Array = W.section(title, 640.0)
	body.add_child(sec[0])
	sec[1].add_child(UiTheme.strong("Chưa mở — " + tab_lock_text(tab), 18, UiTheme.GOLD))
	sec[1].add_child(UiTheme.label(what, "", 620))


## Đầu cột giữa: icon + tên món + dòng phụ. Trả {} nếu chưa chọn món.
static func head(fp, col: VBoxContainer, p, empty_text: String) -> Dictionary:
	var found := Items.find_item(p, int(fp._item_id))
	if found.is_empty():
		col.add_child(UiTheme.label(empty_text, "Muted", CENTER_W))
		return {}
	var item: Dictionary = found.item
	var c := Items.rarity_color(item)
	var h := UiTheme.hbox(12)
	var frame := UiTheme.panel(UiTheme.box(Color(c.darkened(0.7), 0.9), 8, 2, c, 6))
	frame.add_child(UiTheme.icon_rect(SpriteLib.item_icon(item), 60))
	h.add_child(frame)
	var hv := UiTheme.vbox(2)
	hv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var nm := UiTheme.strong(Items.display_name(item), 18, c)
	nm.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	nm.custom_minimum_size.x = CENTER_W - 100
	hv.add_child(nm)
	hv.add_child(UiTheme.label("%s · %s · Cấp %d%s" % [ItemData.RARITIES[item.rarity].name, ItemData.SLOTS[item.slot].name, int(item.level),
		" · đang mặc" if found.where != "bag" else ""], "Small"))
	hv.add_child(UiTheme.strong("Lực chiến món: %s" % W.group(int(Items.item_power_parts(item).total)), 13, UiTheme.GOLD))
	h.add_child(hv)
	col.add_child(h)
	col.add_child(HSeparator.new())
	return item


static func _gem_icon(key: String, size := 34.0) -> TextureRect:
	return UiTheme.icon_rect(SpriteLib.icon(Gear.gem_icon_id(key)), size)


static func gem_stat_text(key: String, slot: String) -> String:
	var pr := Items.gem_parse(key)
	var parts := PackedStringArray()
	var gv := Items.gem_value(pr[0], int(pr[1]), slot if slot != "" else "weapon")
	for k in gv:
		parts.append(Items.stat_text(k, gv[k]))
	return ", ".join(parts)


# ------------------------------------------------------------------ A. Khảm ngọc


static func gems(fp, body: HBoxContainer, p) -> void:
	if not tab_unlocked(p, "gems"):
		locked(body, "gems", "KHẢM NGỌC NGŨ HÀNH", "Ngọc Ngũ Hành rơi theo hệ của quái (Rừng Sương ra Bích Ngọc Mộc…), tinh anh, boss, cổng dungeon, rương uỷ thác. Khảm vào lỗ trên trang bị để tăng chỉ số; vũ khí có 2 viên cùng hệ được ấn hệ, khắc hệ +15%.")
		return
	fp._picker(body, p)
	var mid: Array = W.section("", CENTER_W)
	body.add_child(mid[0])
	var col: VBoxContainer = mid[1]
	var item := head(fp, col, p, "Chọn một món bên trái để khảm ngọc.")
	if not item.is_empty():
		var id := int(item.id)
		col.add_child(UiTheme.label("LỖ NGỌC (%d / %d)" % [Array(item.gems).size(), int(item.sockets)], "Eyebrow"))
		var row := UiTheme.hbox(8)
		row.name = "SocketRow"
		for i in int(item.sockets):
			var b := UiTheme.button("")
			b.custom_minimum_size = Vector2(56, 56)
			b.expand_icon = true
			b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
			if i < item.gems.size():
				var key := str(item.gems[i])
				b.icon = SpriteLib.icon(Gear.gem_icon_id(key))
				b.tooltip_text = "%s: %s\nBấm để tháo về Túi Ngọc (%d vàng, ngọc không vỡ)." % [Gear.gem_name(key), gem_stat_text(key, str(item.slot)), Gear.unsocket_cost(key)]
				var idx := i
				b.pressed.connect(func():
					fp.world.gem_unsocket(id, idx)
					fp.refresh())
			else:
				b.icon = SpriteLib.icon("gem-socket")
				b.tooltip_text = "Lỗ trống — chọn ngọc ở Túi Ngọc bên phải để khảm."
				b.disabled = true
			row.add_child(b)
		if int(item.sockets) == 0:
			row.add_child(UiTheme.label("Món này chưa có lỗ.", "Muted"))
		col.add_child(row)
		# GC-1 (Spec_Notes 10/11): chỉ số từng viên — mỗi viên 1 dòng (cùng kiểu thẻ đồ), rồi tổng
		var gs := Items.gem_stats(item)
		if not gs.is_empty():
			for g in item.gems:
				col.add_child(ItemCard.gem_row(str(g), str(item.slot), CENTER_W))
			if item.gems.size() > 1:
				var parts := PackedStringArray()
				for k in gs:
					parts.append(Items.stat_text(k, gs[k]))
				var gl := UiTheme.label("Tổng ngọc: " + ", ".join(parts), "Small", CENTER_W)
				gl.add_theme_color_override("font_color", UiTheme.GOOD)
				col.add_child(gl)
		if item.slot == "weapon":
			var seal := Items.weapon_seal({"weapon": item})
			if seal != "":
				var sl := UiTheme.strong("Ấn hệ %s: đòn đánh khắc hệ +%d%%" % [Monsters.ELEMENT_NAMES[seal], roundi(GearData.SEAL_BONUS * 100.0)], 15, Color(str(Monsters.ELEMENT_HEX[seal])))
				sl.name = "SealLabel"
				col.add_child(sl)
			else:
				col.add_child(_note("Vũ khí có ≥ 2 viên cùng hệ → ấn hệ đó, đòn đánh khắc hệ +%d%%." % roundi(GearData.SEAL_BONUS * 100.0)))
		# đục lỗ
		if int(item.sockets) < GearData.MAX_SOCKETS:
			col.add_child(UiTheme.label("ĐỤC THÊM LỖ", "Eyebrow"))
			var pc := Gear.punch_cost(item)
			var pr := UiTheme.hbox(8)
			pr.add_child(W.cost_row([["res-gold", pc.gold, int(p.gold), "Vàng"], ["res-tinh_kim", pc.tinh_kim, int(p.tinh_kim), "Tinh Kim"]]))
			pr.add_child(UiTheme.spacer())
			var pb := _button("Đục lỗ", Gear.punch_blocker(p, item), false)
			pb.name = "PunchButton"
			pb.pressed.connect(func():
				fp.world.gem_punch(id)
				fp.refresh())
			pr.add_child(pb)
			col.add_child(pr)
		col.add_child(_note("Phân rã / bán món: ngọc tự về Túi Ngọc. Đồ phòng thủ: ngọc cộng thêm kháng hệ cùng hệ."))
	# phải: Túi Ngọc
	var side: Array = W.section("TÚI NGỌC · %d viên" % Gear.gem_total(p), SIDE_W)
	body.add_child(side[0])
	var sc: VBoxContainer = side[1]
	var cb := _button("Ghép tất cả (%d)" % Gear.combinable(p), "" if Gear.combinable(p) > 0 else "Chưa có 3 viên cùng loại cùng cấp.", false)
	cb.name = "CombineAll"
	cb.pressed.connect(func():
		fp.world.gem_combine_all()
		fp.refresh())
	sc.add_child(cb)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(SIDE_W, 330)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var list := UiTheme.vbox(4)
	list.name = "GemList"
	var gl2 := Gear.gem_list(p)
	if gl2.is_empty():
		list.add_child(UiTheme.label("Chưa có ngọc. Ngọc rơi từ quái theo hệ của quái, tinh anh, boss, cổng dungeon hạng C+, rương uỷ thác ngày, phân rã đồ Cam.", "Muted", SIDE_W - 10))
	for e in gl2:
		var key: String = e[0]
		var n: int = e[1]
		var r := UiTheme.hbox(6)
		r.add_child(_gem_icon(key, 30))
		var v := UiTheme.vbox(0)
		v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var el: String = Items.gem_parse(key)[0]
		v.add_child(UiTheme.strong("%s ×%d" % [Gear.gem_name(key), n], 13, Color(str(Monsters.ELEMENT_HEX[el])).lightened(0.2)))
		var stl := UiTheme.label(gem_stat_text(key, str(item.get("slot", ""))), "Small")
		stl.add_theme_color_override("font_color", AFFIX_COL)
		v.add_child(stl)
		r.add_child(v)
		if not item.is_empty():
			var kb := UiTheme.button("Khảm")
			kb.name = "Socket_" + key.replace(":", "_")
			var bl := Gear.socket_blocker(p, item, key)
			kb.disabled = bl != ""
			kb.tooltip_text = bl
			var iid := int(item.id)
			kb.pressed.connect(func():
				fp.world.gem_socket(iid, key)
				fp.refresh())
			r.add_child(kb)
		if n >= GearData.GEM_COMBINE and int(Items.gem_parse(key)[1]) < GearData.GEM_MAX_LV:
			var mb := UiTheme.button("Ghép")
			mb.tooltip_text = "3 viên → 1 %s cấp %d" % [GearData.GEM_NAMES[el], int(Items.gem_parse(key)[1]) + 1]
			mb.pressed.connect(func():
				fp.world.gem_combine(key)
				fp.refresh())
			r.add_child(mb)
		list.add_child(r)
	scroll.add_child(list)
	sc.add_child(scroll)


# ------------------------------------------------------------------ B. Tẩy luyện


static func reforge(fp, body: HBoxContainer, p) -> void:
	if not tab_unlocked(p, "reforge"):
		locked(body, "reforge", "TẨY LUYỆN DÒNG PHỤ", "Quay lại 1 dòng phụ của món (giá trị hoặc loại dòng), rồi chọn giữ dòng cũ hay lấy dòng mới — không bao giờ mất món.")
		return
	fp._picker(body, p)
	var mid: Array = W.section("", CENTER_W)
	body.add_child(mid[0])
	var col: VBoxContainer = mid[1]
	var item := head(fp, col, p, "Chọn một món bên trái để tẩy luyện.")
	_reforge_help(body)
	if item.is_empty():
		return
	var id := int(item.id)
	if item.affixes.is_empty():
		col.add_child(_warn("Món này không có dòng phụ (đồ Trắng)."))
		return
	var pend: Dictionary = item.get("reforge_pending", {})
	if not pend.is_empty():
		var idx := int(pend.idx)
		col.add_child(UiTheme.label("KẾT QUẢ TẨY LUYỆN — CHỌN 1", "Eyebrow"))
		var cmp := UiTheme.hbox(10)
		cmp.name = "ReforgeCompare"
		for side in [["Dòng cũ", item.affixes[idx], false], ["Dòng mới", pend.af, true]]:
			var box := UiTheme.panel(UiTheme.box(Color("#120c07"), 8, 2 if side[2] else 1, UiTheme.GOLD if side[2] else Color("#4a3620"), 10))
			var v := UiTheme.vbox(6)
			v.custom_minimum_size.x = CENTER_W / 2.0 - 20
			v.add_child(UiTheme.label(side[0], "Small"))
			v.add_child(UiTheme.strong(Items.stat_text(side[1].stat, side[1].value), 16, AFFIX_COL if not side[2] else UiTheme.GOOD))
			var take: bool = side[2]
			var b := UiTheme.button("Lấy dòng mới" if take else "Giữ dòng cũ", take)
			b.name = "ReforgeNew" if take else "ReforgeOld"
			b.pressed.connect(func():
				fp.world.reforge_keep(id, take)
				fp.refresh())
			v.add_child(b)
			box.add_child(v)
			cmp.add_child(box)
		col.add_child(cmp)
		return
	col.add_child(UiTheme.label("CHỌN DÒNG PHỤ", "Eyebrow"))
	if not Gear.reforge_allowed(item, int(fp._affix_idx)):
		fp._affix_idx = maxi(0, int(item.get("reforged", -1)))
	for i: int in range(item.affixes.size()):
		var af: Dictionary = item.affixes[i]
		var allowed := Gear.reforge_allowed(item, i)
		var sel: bool = i == int(fp._affix_idx)
		var b := UiTheme.button(("✦ " if int(item.get("reforged", -1)) == i else "") + Items.stat_text(af.stat, af.value))
		b.name = "Affix_%d" % i
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.disabled = not allowed
		if not allowed:
			b.tooltip_text = "Mỗi món chỉ tẩy được 1 dòng (dòng ✦)."
		var st := UiTheme.box(Color("#3a2812") if sel else Color("#140e08"), 6, 2 if sel else 1, UiTheme.GOLD if sel else Color("#4a3620"), 8)
		b.add_theme_stylebox_override("normal", st)
		b.add_theme_stylebox_override("pressed", st)
		b.add_theme_color_override("font_color", AFFIX_COL)
		var ii: int = i
		b.pressed.connect(func():
			fp._affix_idx = ii
			fp.refresh())
		col.add_child(b)
	var idx2 := int(fp._affix_idx)
	for mode in ["value", "swap"]:
		var c := Gear.reforge_cost(item, mode)
		var r := UiTheme.hbox(8)
		r.add_child(W.cost_row([["res-gold", c.gold, int(p.gold), "Vàng"], ["res-crystal", c.crystal, int(p.crystal), "Tinh Thạch"],
			["res-tinh_kim", c.tinh_kim, int(p.tinh_kim), "Tinh Kim"]]))
		r.add_child(UiTheme.spacer())
		var b := _button(str(GearData.REFORGE[mode].name), Gear.reforge_blocker(p, item, idx2, mode), mode == "value")
		b.name = "Reforge_" + mode
		b.custom_minimum_size.x = 140
		var m: String = mode
		b.pressed.connect(func():
			fp.world.reforge(id, idx2, m)
			fp.refresh())
		r.add_child(b)
		col.add_child(r)
	if int(item.get("reforges", 0)) > 0:
		col.add_child(_note("Đã tẩy %d lần — chi phí ×%s." % [int(item.reforges), Items.num_text(Gear.reforge_mult(item))]))


static func _reforge_help(body: HBoxContainer) -> void:
	var side: Array = W.section("CÁCH TẨY LUYỆN", SIDE_W)
	body.add_child(side[0])
	for t in [
		"Luyện giá trị: giữ loại dòng, quay lại số (0,8–1,2 lần mức chuẩn). Tốn vàng + Tinh Thạch.",
		"Đổi dòng: quay loại dòng khác (không trùng các dòng còn lại). Tốn vàng + Tinh Kim.",
		"Sau khi quay, chọn giữ dòng cũ hay lấy dòng mới — chỉ mất nguyên liệu.",
		"Mỗi món chỉ tẩy được 1 dòng (dòng ✦ chọn lần đầu). Mỗi lần tẩy chi phí ×1,25, tối đa ×3.",
		"Hiệu ứng riêng đồ Cam và hiệu ứng bộ không tẩy được.",
	]:
		side[1].add_child(UiTheme.label("• " + t, "Small", SIDE_W - 10))


# ------------------------------------------------------------------ C + D. Thăng phẩm / Luyện cấp


static func ascend(fp, body: HBoxContainer, p) -> void:
	if not tab_unlocked(p, "ascend"):
		locked(body, "ascend", "THĂNG PHẨM · LUYỆN CẤP", "Thăng phẩm: dùng 1 món trùng ô để nâng món chính lên 1 bậc (tới Tím). Luyện cấp: đồ Cam và đồ bộ theo kịp cấp nhân vật.")
		return
	fp._picker(body, p)
	var mid: Array = W.section("", CENTER_W)
	body.add_child(mid[0])
	var col: VBoxContainer = mid[1]
	var item := head(fp, col, p, "Chọn một món bên trái.")
	var side: Array = W.section("LUYỆN CẤP ĐỒ CAM / ĐỒ BỘ", SIDE_W)
	body.add_child(side[0])
	if item.is_empty():
		side[1].add_child(UiTheme.label("Chọn món để xem.", "Muted", SIDE_W - 10))
		return
	var id := int(item.id)
	# Thăng phẩm
	col.add_child(UiTheme.label("THĂNG PHẨM", "Eyebrow"))
	if not Gear.unlocked(p, "ascend"):
		col.add_child(_warn(Gear.lock_text("ascend")))
	elif not Gear.can_ascend_rarity(item):
		col.add_child(_warn(Gear.ascend_blocker(p, item)))
	else:
		var c := Gear.ascend_cost(item)
		var to := str(c.to)
		var step := UiTheme.hbox(10)
		step.add_child(UiTheme.strong(str(ItemData.RARITIES[item.rarity].name), 18, Color(str(ItemData.RARITIES[item.rarity].color))))
		step.add_child(UiTheme.strong("➜", 18, UiTheme.GOLD))
		step.add_child(UiTheme.strong(str(ItemData.RARITIES[to].name), 18, Color(str(ItemData.RARITIES[to].color))))
		col.add_child(step)
		col.add_child(_note("Giữ cường hoá, ngọc, dòng cũ; thêm 1 dòng phụ ngẫu nhiên và lỗ ngọc. Luôn thành công."))
		var mats := Gear.ascend_materials(p, item)
		if mats.filter(func(x): return int(x.id) == int(fp._mat_id)).is_empty():
			fp._mat_id = int(mats[0].id) if not mats.is_empty() else -1
		if mats.is_empty():
			col.add_child(_warn(Gear.ascend_blocker(p, item)))
		else:
			col.add_child(UiTheme.label("Món nguyên liệu (sẽ mất):", "Small"))
			var mg := HFlowContainer.new()
			mg.custom_minimum_size.x = CENTER_W
			for m in mats:
				var mb := UiTheme.button("")
				mb.custom_minimum_size = Vector2(48, 48)
				mb.expand_icon = true
				mb.icon = SpriteLib.item_icon(m)
				mb.tooltip_text = "%s · cấp %d" % [Items.display_name(m), int(m.level)]
				var sel := int(m.id) == int(fp._mat_id)
				var mc := Items.rarity_color(m)
				var st := UiTheme.box(Color(mc, 0.3 if sel else 0.08), 6, 2 if sel else 1, UiTheme.GOLD if sel else mc, 4)
				mb.add_theme_stylebox_override("normal", st)
				mb.add_theme_stylebox_override("pressed", st)
				var mid2 := int(m.id)
				mb.pressed.connect(func():
					fp._mat_id = mid2
					fp.refresh())
				mg.add_child(mb)
			col.add_child(mg)
			var mat: Dictionary = Items.find_item(p, int(fp._mat_id)).get("item", {})
			if not mat.is_empty() and int(mat.plus) > int(item.plus):
				col.add_child(_note("Món nguyên liệu +%d → món chính nhận +%d." % [int(mat.plus), int(mat.plus)]))
		var r := UiTheme.hbox(8)
		r.add_child(W.cost_row([["res-gold", c.gold, int(p.gold), "Vàng"], ["res-crystal", c.crystal, int(p.crystal), "Tinh Thạch"],
			["res-tinh_kim", c.tinh_kim, int(p.tinh_kim), "Tinh Kim"]]))
		r.add_child(UiTheme.spacer())
		var b := _button("Thăng phẩm", Gear.ascend_blocker(p, item, int(fp._mat_id)))
		b.name = "AscendButton"
		b.pressed.connect(func():
			fp.world.ascend(id, int(fp._mat_id))
			fp.refresh())
		r.add_child(b)
		col.add_child(r)
	# Luyện cấp (cột phải)
	var sc: VBoxContainer = side[1]
	if not Gear.unlocked(p, "levelup"):
		sc.add_child(_warn(Gear.lock_text("levelup"), SIDE_W - 10))
	elif not Gear.can_levelup_kind(item):
		sc.add_child(UiTheme.label("Chỉ đồ Cam và đồ bộ luyện cấp được — đồ thường hãy thay đồ mới.", "Muted", SIDE_W - 10))
	else:
		var tgt := Gear.levelup_target(p, item)
		var lr := UiTheme.hbox(8)
		lr.add_child(UiTheme.strong("Cấp %d" % int(item.level), 18, UiTheme.TEXT))
		lr.add_child(UiTheme.strong("➜", 18, UiTheme.GOLD))
		lr.add_child(UiTheme.strong("Cấp %d" % tgt, 18, UiTheme.GOOD))
		sc.add_child(lr)
		if tgt > int(item.level):
			var probe := item.duplicate(true)
			probe.level = tgt
			sc.add_child(UiTheme.label("%s  ➜  %s" % [Items.base_text(item), Items.base_text(probe)], "Small", SIDE_W - 10))
		var lc := Gear.levelup_cost(item)
		sc.add_child(W.cost_row([["res-gold", lc.gold, int(p.gold), "Vàng"], ["res-tinh_kim", lc.tinh_kim, int(p.tinh_kim), "Tinh Kim"]]))
		var lb := _button("Luyện cấp +%d" % GearData.LEVELUP_STEP, Gear.levelup_blocker(p, item))
		lb.name = "LevelupButton"
		lb.pressed.connect(func():
			fp.world.gear_levelup(id)
			fp.refresh())
		sc.add_child(lb)
		sc.add_child(_note("Mỗi lần +%d cấp, tối đa bằng cấp nhân vật. Dòng phụ tính lại theo cấp mới, giữ độ may mắn đã quay." % GearData.LEVELUP_STEP, SIDE_W - 10))


# ------------------------------------------------------------------ E. Thức tỉnh


static func awaken(fp, body: HBoxContainer, p) -> void:
	if not tab_unlocked(p, "awaken"):
		locked(body, "awaken", "THỨC TỈNH TRANG BỊ", "Sau chuyển chức 3, món Tím / Cam đạt +%d mở dòng Thức Tỉnh theo lớp và Thiên phú (sát thương boss, kỹ năng, hút máu…), nâng bậc 1 → 5 bằng Thiên Phú Tinh Hoa." % GearData.AWAKEN_MIN_PLUS)
		return
	fp._picker(body, p)
	var mid: Array = W.section("", CENTER_W)
	body.add_child(mid[0])
	var col: VBoxContainer = mid[1]
	var item := head(fp, col, p, "Chọn một món Tím / Cam +%d trở lên." % GearData.AWAKEN_MIN_PLUS)
	_awaken_side(body, p)
	if item.is_empty():
		return
	var id := int(item.id)
	var aw: Dictionary = item.get("awaken", {})
	var offer: Array = aw.get("offer", [])
	if not offer.is_empty():
		col.add_child(UiTheme.label("CHỌN 1 DÒNG THỨC TỈNH", "Eyebrow"))
		for line in offer:
			var ln: String = str(line)
			var b := UiTheme.button(("✓ " if ln == str(aw.get("id", "")) else "") + Items.awaken_text(ln, maxi(1, int(aw.get("tier", 0)))), true)
			b.name = "AwakenPick_" + ln
			b.alignment = HORIZONTAL_ALIGNMENT_LEFT
			b.custom_minimum_size = Vector2(CENTER_W, 40)
			b.pressed.connect(func():
				fp.world.awaken_choose(id, ln)
				fp.refresh())
			col.add_child(b)
		return
	if str(aw.get("id", "")) != "":
		var t := int(aw.tier)
		col.add_child(UiTheme.strong("★".repeat(t) + "☆".repeat(GearData.AWAKEN_MAX_TIER - t) + "  Bậc %d" % t, 18, AWAKEN_COL))
		col.add_child(UiTheme.strong(Items.awaken_text(str(aw.id), t), 16, AWAKEN_COL))
		if t < GearData.AWAKEN_MAX_TIER:
			col.add_child(UiTheme.label("Bậc %d: %s" % [t + 1, Items.awaken_text(str(aw.id), t + 1)], "Small"))
	else:
		col.add_child(UiTheme.label("Món chưa Thức Tỉnh. Mở để rút 3 dòng theo lớp và Thiên phú của bạn, chọn 1.", "", CENTER_W))
	var c := Gear.awaken_next_cost(item)
	if not c.is_empty():
		var r := UiTheme.hbox(8)
		r.add_child(W.cost_row([["res-essence", c.essence, int(p.essence), "Thiên Phú Tinh Hoa"], ["res-void_core", c.void, int(p.void_cores), "Lõi Hư Vô"]]))
		r.add_child(UiTheme.spacer())
		var b := _button("Mở Thức Tỉnh" if str(aw.get("id", "")) == "" else "Nâng bậc %d" % (int(aw.tier) + 1), Gear.awaken_blocker(p, item))
		b.name = "AwakenButton"
		b.pressed.connect(func():
			fp.world.awaken(id)
			fp.refresh())
		r.add_child(b)
		col.add_child(r)
		var bl := Gear.awaken_blocker(p, item)
		if bl != "":
			col.add_child(_warn(bl))
	if str(aw.get("id", "")) != "":
		var rc := Gear.awaken_reroll_cost(item)
		var rb := _button("Đổi dòng (%d Tinh Hoa, giữ bậc)" % rc, "" if int(p.essence) >= rc else "Cần %d Thiên Phú Tinh Hoa." % rc, false)
		rb.name = "AwakenReroll"
		rb.pressed.connect(func():
			fp.world.awaken_reroll(id)
			fp.refresh())
		col.add_child(rb)
		var active_slots: Array = Items.active_awakens(p.equipment).map(func(a): return a.slot)
		if not (str(item.slot) in active_slots) and Items.find_item(p, id).where != "bag":
			col.add_child(_warn("Đang có %d món Thức Tỉnh bậc cao hơn — món này chưa có hiệu lực." % GearData.AWAKEN_MAX_ACTIVE))


static func _awaken_side(body: HBoxContainer, p) -> void:
	var side: Array = W.section("ĐANG HIỆU LỰC (TỐI ĐA %d)" % GearData.AWAKEN_MAX_ACTIVE, SIDE_W)
	body.add_child(side[0])
	var act := Items.active_awakens(p.equipment)
	if act.is_empty():
		side[1].add_child(UiTheme.label("Chưa có món nào.", "Muted", SIDE_W - 10))
	for a in act:
		var l := UiTheme.label("%s · ★%d  %s" % [ItemData.SLOTS[a.slot].name, int(a.tier), Items.awaken_text(a.id, a.tier)], "Small", SIDE_W - 10)
		l.add_theme_color_override("font_color", AWAKEN_COL)
		side[1].add_child(l)
	side[1].add_child(HSeparator.new())
	side[1].add_child(UiTheme.label("Chi phí bậc 1 → 5: %s Tinh Hoa; bậc 4–5 thêm 1 / 2 Lõi Hư Vô." % " / ".join(GearData.AWAKEN_ESSENCE.map(func(x): return str(x))), "Small", SIDE_W - 10))


# ------------------------------------------------------------------ F. Bảo Giám


static func codex(fp, body: HBoxContainer, p) -> void:
	var sec: Array = W.section("", 920.0)
	body.add_child(sec[0])
	var col: VBoxContainer = sec[1]
	var pts := Gear.codex_points(p)
	var mx := Gear.codex_max_points()
	var top := UiTheme.hbox(12)
	top.add_child(UiTheme.strong("BẢO GIÁM · %d / %d điểm" % [pts, mx], 18, UiTheme.GOLD))
	var bar := ProgressBar.new()
	bar.show_percentage = false
	bar.max_value = mx
	bar.value = pts
	bar.custom_minimum_size = Vector2(260, 14)
	bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	bar.add_theme_stylebox_override("fill", UiTheme.box(UiTheme.GOLD, 4, 0, UiTheme.GOLD, 0))
	bar.add_theme_stylebox_override("background", UiTheme.box(Color("#0b0805"), 4, 1, Color("#4a3620"), 0))
	top.add_child(bar)
	col.add_child(top)
	col.add_child(_note("Ghi danh lần đầu sở hữu — không cần giữ hay mặc. Mốc điểm cho thưởng vĩnh viễn.", 900))
	var ms := HFlowContainer.new()
	ms.custom_minimum_size.x = 900
	ms.add_theme_constant_override("h_separation", 8)
	for m in GearData.CODEX_MILESTONES:
		var on := pts >= int(m.at)
		var chip := UiTheme.panel(UiTheme.box(Color("#2a3a1a") if on else Color("#140e08"), 6, 1, UiTheme.GOOD if on else Color("#4a3620"), 6))
		var l := UiTheme.label("%s %d: %s" % ["✓" if on else "·", int(m.at), m.text], "Small")
		l.add_theme_color_override("font_color", UiTheme.GOOD if on else Color("#c9b89a"))
		chip.add_child(l)
		ms.add_child(chip)
	col.add_child(ms)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(900, 360)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var list := UiTheme.vbox(6)
	list.name = "CodexList"
	var entries := Gear.codex_entries(p)
	# đồ bộ: mỗi bộ 1 hàng 8 ô
	list.add_child(UiTheme.label("ĐỒ BỘ (2 điểm / món, đủ 6 ô +%d)" % GearData.CODEX_SET_FULL, "Eyebrow"))
	for set_id in ItemData.SETS:
		var row := UiTheme.hbox(6)
		var n := Gear.codex_set_count(p, set_id)
		var nl := UiTheme.label("%s  %d/8" % [ItemData.SETS[set_id].name, n], "Small", 190)
		nl.add_theme_color_override("font_color", UiTheme.GOOD if n >= GearData.CODEX_SET_FULL_N else Color("#c9b89a"))
		row.add_child(nl)
		for e in entries.filter(func(x): return x.kind == "set" and x.group == set_id):
			var probe := {"slot": e.slot, "rarity": "purple", "set": set_id, "unique": "", "id": 0, "style": ""}
			row.add_child(_codex_icon(SpriteLib.item_icon(probe), e))
		list.add_child(row)
	list.add_child(UiTheme.label("ĐỒ CAM (5 điểm / món)", "Eyebrow"))
	var uf := HFlowContainer.new()
	uf.custom_minimum_size.x = 880
	for e in entries.filter(func(x): return x.kind == "unique"):
		var probe := {"slot": e.slot, "rarity": "orange", "set": "", "unique": e.group, "id": 0, "style": ""}
		uf.add_child(_codex_icon(SpriteLib.item_icon(probe), e))
	list.add_child(uf)
	list.add_child(UiTheme.label("MỐC CƯỜNG HOÁ LẦN ĐẦU (+10 / +13 / +15: 1 / 2 / 4 điểm)", "Eyebrow"))
	var pf := HFlowContainer.new()
	pf.custom_minimum_size.x = 880
	for e in entries.filter(func(x): return x.kind == "plus"):
		var chip := UiTheme.panel(UiTheme.box(Color("#2a3a1a") if e.have else Color("#140e08"), 6, 1, UiTheme.GOOD if e.have else Color("#4a3620"), 4))
		var l := UiTheme.label(e.name, "Small")
		l.add_theme_color_override("font_color", UiTheme.GOOD if e.have else Color("#7a6a52"))
		chip.add_child(l)
		pf.add_child(chip)
	list.add_child(pf)
	list.add_child(UiTheme.label("NGỌC CẤP 7 / 10 LẦN ĐẦU (3 / 6 điểm)", "Eyebrow"))
	var gf := HFlowContainer.new()
	gf.custom_minimum_size.x = 880
	for e in entries.filter(func(x): return x.kind == "gem"):
		gf.add_child(_codex_icon(SpriteLib.icon(Gear.gem_icon_id("%s:%d" % [e.group, 7 if e.name.ends_with("7") else 10])), e))
	list.add_child(gf)
	scroll.add_child(list)
	col.add_child(scroll)


static func _codex_icon(tex: Texture2D, e: Dictionary) -> Control:
	var r := UiTheme.icon_rect(tex, 40)
	r.mouse_filter = Control.MOUSE_FILTER_STOP
	r.tooltip_text = "%s — %s (+%d điểm)" % [e.name, "đã ghi danh" if e.have else "chưa có", int(e.points)]
	if not e.have:
		r.modulate = Color(0.25, 0.25, 0.28, 0.75)
	return r


# ------------------------------------------------------------------ Gợi ý tăng Lực chiến


static func tips(fp, body: HBoxContainer, p) -> void:
	var sec: Array = W.section("", 920.0)
	body.add_child(sec[0])
	var col: VBoxContainer = sec[1]
	col.add_child(UiTheme.strong("GỢI Ý TĂNG LỰC CHIẾN · Lực chiến hiện tại %s" % W.group(int(fp.world.combat_power())), 18, UiTheme.GOLD))
	var list: Array = fp.world.power_tips()
	if list.is_empty():
		col.add_child(UiTheme.label("Chưa có việc nào làm được ngay. Hãy cày thêm Đá Cường Hoá, ngọc, Tinh Thạch, Tinh Kim.", "Muted", 900))
	for t in list:
		var row := UiTheme.panel(UiTheme.box(Color("#120c07"), 8, 1, Color("#4a3620"), 6))
		var h := UiTheme.hbox(10)
		h.add_child(UiTheme.strong("▲", 16, UiTheme.GOOD))
		var l := UiTheme.label(str(t.text), "", 700)
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		h.add_child(l)
		var b := UiTheme.button("Làm ngay", true)
		var tab := str(t.tab)
		var iid := int(t.id)
		b.pressed.connect(func():
			if iid >= 0:
				fp._item_id = iid
			fp.tab = tab
			fp.refresh())
		h.add_child(b)
		row.add_child(h)
		col.add_child(row)
	col.add_child(HSeparator.new())
	var ways := [
		["Cường hoá", "+0 → +15, mỗi cấp +10% chỉ số gốc", true],
		["Khảm ngọc", "ngọc Ngũ Hành vào lỗ; vũ khí 2 viên cùng hệ được ấn hệ", Gear.unlocked(p, "gems")],
		["Tẩy luyện", "quay lại 1 dòng phụ, giữ cũ hoặc lấy mới", Gear.unlocked(p, "reforge")],
		["Thăng phẩm", "hút đồ trùng ô, lên 1 bậc (tới Tím)", Gear.unlocked(p, "ascend")],
		["Luyện cấp", "đồ Cam / đồ bộ theo kịp cấp nhân vật", Gear.unlocked(p, "levelup")],
		["Thức tỉnh", "dòng đặc biệt theo lớp / Thiên phú (sau chuyển chức 3)", Gear.unlocked(p, "awaken")],
		["Bảo Giám", "sưu tập đồ bộ / đồ Cam / mốc cường hoá → thưởng vĩnh viễn", true],
	]
	col.add_child(UiTheme.label("CÁC CÁCH TĂNG LỰC CHIẾN CHO TRANG BỊ", "Eyebrow"))
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 16)
	grid.add_theme_constant_override("v_separation", 2)
	for w in ways:
		var l2 := UiTheme.label("%s %s — %s" % ["•" if w[2] else "(chưa mở)", w[0], w[1]], "Small", 440)
		l2.add_theme_color_override("font_color", UiTheme.TEXT if w[2] else UiTheme.MUTED)
		grid.add_child(l2)
	col.add_child(grid)
