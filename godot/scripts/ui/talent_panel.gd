extends "res://scripts/ui/modal.gd"
const Ch4 = preload("res://scripts/core/chapter4.gd")
const Ch7 = preload("res://scripts/core/chapter7.gd")
## Bảng Thiên phú (phím T) — TL-15: thẻ, cấp, hiệu ứng, kỹ năng L, hiệu ứng phụ, luyện cấp.

const Explore = preload("res://scripts/core/explore.gd")
const Monsters = preload("res://scripts/data/monsters.gd")
const Talents = preload("res://scripts/data/talents.gd")
## TP-05 / 13 / 14 (docs/33): Thiên phú phụ, cộng hưởng, tẩy.
const TalentSlots = preload("res://scripts/core/talent_slots.gd")

## UI-28c: bề rộng chữ trong mỗi cột (3 cột vừa một màn hình, không cuộn).
const W := 330.0
const CharBar = preload("res://scripts/ui/char_bar.gd")
const Ornate = preload("res://scripts/ui/ornate.gd")

## UI-28b: bấm tab khác trên thanh tiêu đề chung — main.gd đóng bảng này rồi mở bảng / tab tương ứng.
signal open_panel(id: String)


## UI-28d (chủ dự án 30/10: "chưa thấy điểm nổi bật của cấp thiên phú"): khối cấp nổi bật trong thẻ —
## "CẤP" + số lớn vàng "/10" + nhãn TỐI ĐA khi đủ cấp; 10 ô tiến độ (đã đạt tô màu hạng, mốc 5 / 10 viền vàng).
func _level_block(lv: int, rank_color: Color) -> Control:
	var box := UiTheme.panel(UiTheme.box(Color("#0e0a06", 0.85), 8, 1, Color("#7a5a2a"), 8))
	box.name = "TalentLevel"
	var v := UiTheme.vbox(6)
	box.add_child(v)
	var head := UiTheme.hbox(6)
	var cap := UiTheme.strong("CẤP", 13, Color("#b8a888"))
	cap.size_flags_vertical = Control.SIZE_SHRINK_END
	head.add_child(cap)
	var num := UiTheme.strong(str(lv), 34, Color("#ffd877"))
	num.name = "TalentLevelValue"
	head.add_child(num)
	var of := UiTheme.strong("/ %d" % Talents.MAX_TALENT_LEVEL, 16, Color("#b8a888"))
	of.size_flags_vertical = Control.SIZE_SHRINK_END
	head.add_child(of)
	head.add_child(UiTheme.spacer())
	var maxed := lv >= Talents.MAX_TALENT_LEVEL
	var tag := UiTheme.panel(UiTheme.box(Color("#3a2a10") if maxed else Color("#14202a"), 5, 1, UiTheme.GOLD if maxed else Color("#4a6a8a"), 4))
	tag.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	tag.add_child(UiTheme.strong("TỐI ĐA" if maxed else "Cấp kế: %d" % (lv + 1), 12, UiTheme.GOLD if maxed else Color("#9cc4e8")))
	head.add_child(tag)
	v.add_child(head)
	var pips := UiTheme.hbox(4)
	for i in Talents.MAX_TALENT_LEVEL:
		var on := i < lv
		var milestone := (i + 1) % 5 == 0
		var pip := Panel.new()
		pip.custom_minimum_size = Vector2(0, 10)
		pip.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		pip.add_theme_stylebox_override("panel", UiTheme.box(rank_color if on else Color("#1e1610"), 3,
			1, UiTheme.GOLD if milestone else (rank_color.darkened(0.3) if on else Color("#3a2a18")), 0))
		pip.tooltip_text = "Cấp %d%s" % [i + 1, " — mốc mở hiệu ứng phụ" if milestone else ""]
		pips.add_child(pip)
	v.add_child(pips)
	return box


## TL-UI (Spec_Notes 10/11: "có thêm thiên phú → bị vỡ khung layout - che khuất màn hình"): bảng không bao giờ cao hơn
## màn hình — 3 cột cao cố định theo màn hình, nội dung dài cuộn trong từng cột (tiêu đề cột đứng yên).
const MARGIN := 24.0
## Phần ngoài 3 cột: thanh tiêu đề chung + hàng Thiên phú phụ + viền bảng.
const CHROME_H := 300.0
const COL_MIN_H := 220.0
const COL_MAX_H := 470.0


## Chiều cao 3 cột theo màn hình hiện tại.
func _col_height() -> float:
	var vh := get_viewport_rect().size.y if is_inside_tree() else 768.0
	return clampf(vh - 2.0 * MARGIN - CHROME_H, COL_MIN_H, COL_MAX_H)


## Một cột trong khung vẽ, tiêu đề vàng; nội dung pixel bên trong giữ Nearest. Nội dung cuộn dọc khi dài.
func _column(parent: Control, title: String, name_: String) -> VBoxContainer:
	var frame := UiTheme.panel(Ornate.panel_style(20))
	frame.name = name_
	Ornate.linear(frame)
	frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var wrap := UiTheme.vbox(6)
	frame.add_child(wrap)
	wrap.add_child(UiTheme.strong(title, 19, Color("#f3d27a")))
	var scroll := ScrollContainer.new()
	scroll.name = "Scroll"
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size = Vector2(W + 14.0, _col_height() - 48.0)
	wrap.add_child(scroll)
	var col := UiTheme.vbox(8)
	col.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	col.custom_minimum_size.x = W
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(col)
	parent.add_child(frame)
	return col


## UI-28c (chủ dự án 30/10: "trình bày lại cho gọn trên 1 page"): 3 cột —
## trái: thẻ Thiên phú + kỹ năng L + trạng thái riêng · giữa: hiệu ứng theo cấp + luyện cấp · phải: cây tiến hoá.
func _render(outer: VBoxContainer) -> void:
	outer.add_child(CharBar.build(world, "talent", func(key: String): open_panel.emit(key), close))
	var p = world.profile
	var t: Dictionary = world.talent()
	# C4-45 (M7): dạng tiến hoá hiện tại; lv = cấp của dạng hiện tại (talent_level là cấp hiệu dụng).
	# C7-46: dạng bậc 2 / Đột Phá (chapter7.form).
	var form: Array = Ch7.form(t.id, int(p.evo))
	var lv: int = Ch4.stage_level(p)
	var color := Talents.rank_color(form[1])
	var body := UiTheme.hbox(12)
	outer.add_child(body)

	# ---- cột trái: thẻ Thiên phú
	var left := _column(body, "Thiên phú", "TalentCard")
	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", UiTheme.rank_box(color))
	var cv := UiTheme.vbox(6)
	var top := UiTheme.hbox(12)
	top.add_child(UiTheme.icon_rect(preload("res://scripts/view/sprite_lib.gd").talent_icon(t.id), 64))
	var rank := UiTheme.strong(form[1], 40, color)
	rank.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	top.add_child(rank)
	var nv := UiTheme.vbox(2)
	nv.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	nv.add_child(UiTheme.strong(str(form[0]), 18, Color("#ece6d8")))
	nv.add_child(UiTheme.label(Talents.group_name(t) + ((" · Tiến hoá %d/2" % int(p.evo)) if int(p.evo) > 0 else ""), "Muted"))
	top.add_child(nv)
	cv.add_child(top)
	cv.add_child(_level_block(lv, color))
	cv.add_child(UiTheme.label(t.description, "", W - 20))
	card.add_child(cv)
	left.add_child(card)
	if int(p.starwater) > 0:
		left.add_child(_wash_button(p, -1))
	if Talents.has_skill(t):
		left.add_child(UiTheme.label("KỸ NĂNG (PHÍM L)", "Eyebrow"))
		left.add_child(UiTheme.label("%s — %s Hồi chiêu %.1f giây." % [world.talent_skill_name(), t.skill.text, world.talent_skill_cd()], "Small", W))
	_talent_state(left, p, t)
	# TP-39 (M4.2): Đạo Tặc có ≥ 2 kỹ năng sao chép thì chọn kỹ năng dùng bằng phím L.
	if t.id == "dao-tac" and p.copied_skills.size() >= 2:
		var copy_row := HFlowContainer.new()
		copy_row.add_child(UiTheme.label("Kỹ năng L:", "Small"))
		for sk in p.copied_skills:
			var b := UiTheme.button(str(world.COPY_NAMES.get(sk, sk)), sk == world.active_copy())
			b.name = "Copy_" + str(sk)
			var id: String = sk
			b.pressed.connect(func():
				world.set_active_copy(id)
				refresh())
			copy_row.add_child(b)
		left.add_child(copy_row)

	# ---- cột giữa: hiệu ứng theo cấp + luyện cấp
	var mid := _column(body, "Hiệu ứng theo cấp", "TalentLevels")
	# TP-41: hiệu ứng chính mạnh dần tới Lv10.
	var main_now := Talents.main_effect_text(t.id, p.talent_level)
	if main_now != "":
		mid.add_child(UiTheme.label("Cấp %d: %s" % [lv, main_now], "", W))
		if lv < Talents.MAX_TALENT_LEVEL:
			var nx := UiTheme.label("→ Cấp %d: %s" % [lv + 1, Talents.main_effect_text(t.id, p.talent_level + 1)], "Small", W)
			nx.add_theme_color_override("font_color", UiTheme.GOOD)
			mid.add_child(nx)
	var bonus: int = 2 * (int(p.talent_level) - 1)
	mid.add_child(UiTheme.label("+%d%% Tấn công, +%d%% HP (mỗi cấp hiệu dụng +2%%)." % [bonus, bonus], "Muted", W))
	var subs: Array = Talents.GROUP_SUB[t.group]
	for i in subs.size():
		var need := (i + 1) * 5
		var on: bool = int(p.talent_level) >= need
		var l := UiTheme.label("%s Cấp %d — %s" % ["✓" if on else "○", need, subs[i]], "", W)
		l.add_theme_color_override("font_color", UiTheme.GOOD if on else UiTheme.MUTED)
		mid.add_child(l)
	mid.add_child(HSeparator.new())
	mid.add_child(UiTheme.label("Thiên Phú Tinh Hoa: %d" % p.essence, ""))
	var src := UiTheme.label("Boss chương 3 mỗi lần hạ +1, boss hiếm +5.", "Small", W)
	src.add_theme_color_override("font_color", UiTheme.MUTED)
	mid.add_child(src)
	if lv >= Talents.MAX_TALENT_LEVEL:
		mid.add_child(UiTheme.label("Đã đạt cấp tối đa của dạng này.", "Muted"))
	else:
		var cost := Talents.level_cost(lv)
		var blocker := ""
		if not Explore.is_built(p, "temple"):
			blocker = "Cần xây Đền Thiên Phú (Bản đồ khai phá, phím M)." if not Explore.is_started(p, "temple") \
				else "Đền Thiên Phú đang xây, còn %d giây." % ceili(Explore.remaining(p, "temple"))
		elif p.essence < cost:
			blocker = "Thiếu Tinh Hoa."
		var b := UiTheme.button("Luyện cấp %d → %d (%d Tinh Hoa)" % [lv, lv + 1, cost])
		b.name = "LevelButton"
		Ornate.button(b, "gold")
		b.custom_minimum_size.y = 48
		b.disabled = blocker != ""
		if blocker != "":
			b.tooltip_text = blocker  # UI-62: lý do khoá
		b.pressed.connect(func():
			world.level_talent()
			refresh())
		mid.add_child(b)
		if blocker != "":
			var w := UiTheme.label(blocker, "Small", W)
			w.add_theme_color_override("font_color", Color("#ffb27a"))
			mid.add_child(w)

	# ---- cột phải: cây tiến hoá
	_evolution(_column(body, "Cây tiến hoá", "TalentEvolution"), t)
	_subs_row(outer, p)


## TP-05 / TP-13 / TP-14 (docs/33): hàng Thiên phú phụ (2 ô) + Nước Thánh + cộng hưởng dưới 3 cột.
func _subs_row(outer: VBoxContainer, p) -> void:
	var box := PanelContainer.new()
	box.name = "SubTalents"
	box.add_theme_stylebox_override("panel", UiTheme.inset(Color("#140d08"), Color("#5a4220"), 10, 8))
	var row := UiTheme.hbox(12)
	box.add_child(row)
	var open_n := TalentSlots.sub_slots_open(p)
	for i in TalentSlots.MAX_SUBS:
		var cell := UiTheme.vbox(4)
		cell.name = "SubSlot_%d" % i
		cell.custom_minimum_size.x = 250
		if i < p.subs.size():
			var sd: Dictionary = p.subs[i]
			var st := Talents.get_talent(str(sd.id))
			var c := Talents.rank_color(st.rank)
			var top := UiTheme.hbox(8)
			top.add_child(UiTheme.icon_rect(preload("res://scripts/view/sprite_lib.gd").talent_icon(str(st.id)), 34))
			top.add_child(UiTheme.strong("%s · %s" % [st.rank, st.name], 15, c))
			cell.add_child(top)
			var eff := Talents.main_effect_text(str(st.id), int(sd.level))
			cell.add_child(UiTheme.label("%s · Cấp %d%s" % [Talents.group_name(st), int(sd.level), (" · " + eff) if eff != "" else ""], "Small", 245))
			var btns := UiTheme.hbox(6)
			if int(sd.level) < Talents.MAX_TALENT_LEVEL:
				var cost := Talents.level_cost(int(sd.level))
				var lb := UiTheme.button("Luyện cấp (%d Tinh Hoa)" % cost)
				lb.name = "SubLevel_%d" % i
				lb.disabled = not Explore.is_built(p, "temple") or p.essence < cost
				lb.tooltip_text = "Luyện ở Đền Thiên Phú, cùng bảng giá Tinh Hoa với Thiên phú chính."
				var si: int = i
				lb.pressed.connect(func():
					world.level_sub(si)
					refresh())
				btns.add_child(lb)
			btns.add_child(_wash_button(p, i))
			cell.add_child(btns)
		elif i < open_n:
			cell.add_child(UiTheme.strong("Ô Thiên phú phụ %d" % (i + 1), 15, UiTheme.GOLD))
			cell.add_child(UiTheme.label("Ô đã mở — chạm Bia Đá để nhận Thiên phú.", "Small", 245))
			var rb := UiTheme.button("Lễ Thức Tỉnh", true)
			rb.name = "SubRitual_%d" % i
			rb.pressed.connect(func(): open_panel.emit("sub_ritual"))
			cell.add_child(rb)
		else:
			cell.add_child(UiTheme.strong("🔒 Ô Thiên phú phụ %d" % (i + 1), 15, UiTheme.MUTED))
			cell.add_child(UiTheme.label("Mở khi chuyển chức %d (cấp %d)." % [i + 1, 30 if i == 0 else 60], "Small", 245))
		row.add_child(cell)
	row.add_child(VSeparator.new())
	var res := UiTheme.vbox(3)
	res.name = "Resonances"
	res.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	res.add_child(UiTheme.strong("Cộng hưởng", 15, UiTheme.GOLD))
	var rows: Array = TalentSlots.resonance_rows(p)
	if rows.is_empty():
		res.add_child(UiTheme.label("2 Thiên phú cùng nhóm → hiệu ứng chính +10%; một số cặp có cộng hưởng đặc biệt.", "Small", 320))
	for r in rows:
		var l := UiTheme.label("%s %s — %s" % ["✦" if r[2] else "○", r[0], r[1]], "Small", 320)
		l.add_theme_color_override("font_color", UiTheme.GOOD if r[2] else UiTheme.MUTED)
		res.add_child(l)
	res.add_child(UiTheme.label("Nước Thánh Tinh Quang: %d (tẩy 1 Thiên phú, giữ 50%% cấp)" % int(p.starwater), "Small", 320))
	row.add_child(res)
	outer.add_child(box)


## TP14: nút Tẩy cho Thiên phú chính (slot −1) hoặc phụ (0 / 1).
func _wash_button(p, slot: int) -> Button:
	var b := UiTheme.button("Tẩy")
	b.name = "Wash_%d" % slot
	var id := str(p.talent) if slot < 0 else str(p.subs[slot].id)
	b.disabled = int(p.starwater) <= 0 or id in TalentSlots.NO_ROLL
	b.tooltip_text = ("Không tẩy được Đạo Tặc." if id in TalentSlots.NO_ROLL else
		"Dùng 1 Nước Thánh Tinh Quang: quay 1 lần ra Thiên phú khác, giữ 50%% cấp luyện%s." % (" (mất tiến hoá)" if slot < 0 and int(p.evo) > 0 else ""))
	b.pressed.connect(func():
		world.wash_talent(slot)
		refresh())
	return b


## Trạng thái riêng của từng Thiên phú (hệ, thú cưng, kỹ năng sao chép…).
## C1-14 (TP-43): cây tiến hoá hiện trước để người quay hạng thấp thấy đường đi lên.
func _evolution(content: VBoxContainer, t: Dictionary) -> void:
	var stages: Array = Talents.EVOLUTION.get(t.id, [])
	if stages.is_empty():
		content.add_child(UiTheme.label("Thiên phú này đã ở đỉnh — không tiến hoá.", "Small", W))
		return
	var evo: int = int(world.profile.evo)
	for i in stages.size():
		var st: Array = stages[i]
		var row := UiTheme.hbox(8)
		if i < evo:
			row.modulate = Color(0.6, 1.0, 0.6)
		var rank := UiTheme.label("%s" % st[1], "Heading")
		rank.add_theme_color_override("font_color", Talents.rank_color(st[1]))
		rank.custom_minimum_size.x = 34
		row.add_child(rank)
		var l := UiTheme.label("Bậc %d · %s — %s" % [i + 1, st[0], st[2]], "Small", W - 50)
		row.add_child(l)
		content.add_child(row)
	content.add_child(UiTheme.label("Điều kiện bậc 1 (M7): Thiên phú Lv10 + 1 Tinh Hoa Tiến Hoá + nhiệm vụ chương 4 bước Tiến hoá. Có %d Tinh Hoa Tiến Hoá." % int(world.profile.evo_essence), "Small", W))
	# C4-43: nút Tiến hoá — hoàn 50% Tinh Hoa đã luyện, không tụt sức mạnh.
	# C7-43/44: lần 2 đi qua chapter7 (bước 7 chương 7; Thiên phú hết bậc 2 → Đột Phá).
	if evo == 1 and not stages.is_empty():
		var why2: String = Ch7.can_evolve2(world)
		var nxt: Array = Ch7.form(t.id, 2)
		var eb2 := UiTheme.button("Tiến hoá lần 2 → %s (%s)" % [nxt[0], nxt[1]], why2 == "")
		eb2.name = "EvolveButton"
		eb2.disabled = why2 != ""
		eb2.size_flags_horizontal = SIZE_SHRINK_BEGIN
		eb2.pressed.connect(func():
			Ch7.evolve2(world)
			refresh())
		content.add_child(eb2)
		if why2 != "":
			var wl2 := UiTheme.label(why2, "", W)
			wl2.add_theme_color_override("font_color", Color("#ffb27a"))
			content.add_child(wl2)
	elif evo < stages.size() and evo == 0:
		var why: String = Ch4.can_evolve(world)
		var eb := UiTheme.button("Tiến hoá → %s (%s)" % [stages[evo][0], stages[evo][1]], why == "")
		eb.name = "EvolveButton"
		eb.disabled = why != ""
		if why != "":
			eb.tooltip_text = why  # UI-62: lý do khoá
		eb.size_flags_horizontal = SIZE_SHRINK_BEGIN
		eb.pressed.connect(func():
			Ch4.evolve(world)
			refresh())
		content.add_child(eb)
		if why != "":
			var wl := UiTheme.label(why, "", W)
			wl.add_theme_color_override("font_color", Color("#ffb27a"))
			content.add_child(wl)


func _talent_state(content: VBoxContainer, p, t: Dictionary) -> void:
	var lines: Array[String] = []
	match t.id:
		"ngu-hanh":
			var e: String = p.element
			lines.append("Hệ đang dùng: %s — khắc %s." % [Monsters.ELEMENT_NAMES[e], Monsters.ELEMENT_NAMES[Monsters.COUNTERS[e]]])
			lines.append("Quái Rừng Sương: Sói Sương và Sói Chúa hệ Mộc, Nấm Độc hệ Thổ, Tinh Linh Sương hệ Thủy.")
		"thuan-thu":
			lines.append("Thú cưng: %d/%d." % [p.pets.size(), world.ally_cap("pet")])
		"bay-dan":
			lines.append("Lính bóng tối tối đa: %d." % world.ally_cap("shadow"))
		"dao-tac":
			var copies: Array = p.copied_skills.map(func(sk): return str(world.COPY_NAMES.get(sk, sk)))
			lines.append("Đã sao chép: %s." % (", ".join(copies) if not copies.is_empty() else "chưa có"))
			# DT-03/17/18/19: giới hạn, Túi Tang Vật, Đà Cướp, Sổ Đạo Tặc.
			lines.append("Điểm cướp: %d/%d (giới hạn = cấp Thiên phú %d × cấp nhân vật %d)." % [p.stolen.size(), world.steal_cap(), Ch4.stage_level(p), p.level])
			var bag: Array = p.steal_bag.map(func(k): return str(Monsters.STAT_NAMES.get(k, str(k).to_upper())))
			lines.append("Túi Tang Vật: %d/%d%s — lên cấp sẽ tự cộng vào nhân vật." % [p.steal_bag.size(), world.STEAL_BAG_MAX, (" (" + ", ".join(bag) + ")") if not bag.is_empty() else ""])
			if not world.steal_buffs.is_empty():
				var buffs: Array = world.steal_buffs.map(func(b): return "%s %ds" % [Monsters.STAT_NAMES.get(b.stat, str(b.stat).to_upper()), int(ceil(float(b.left)))])
				lines.append("Đà Cướp (+%d%% mỗi tầng): %s." % [int(world.STEAL_BUFF_PCT * 100), ", ".join(buffs)])
			var kinds: Array = p.steal_log.keys()
			kinds.sort_custom(func(a, b): return int(p.steal_log[a]) > int(p.steal_log[b]))
			var entries: Array = kinds.map(func(k): return "%s %d/%d" % [Monsters.DEFS.get(k, {}).get("name", k), int(p.steal_log[k]), world.steal_species_cap(k)])
			# UI-28c: chỉ hiện 6 loài cướp nhiều nhất để cột không dài quá trang
			var shown: Array = entries.slice(0, 6)
			lines.append("Sổ Đạo Tặc — đã cướp %d/%d loài: %s%s." % [kinds.size(), world.steal_species_total(), ", ".join(shown) if not shown.is_empty() else "chưa có", " …" if entries.size() > 6 else ""])
		"long-mach":
			var state := "đã xây" if Explore.is_built(p, "dragon") else "chưa xây — xây ở Bản đồ khai phá"
			lines.append("Long Mạch Đàn: %s." % state)
		"thao-duoc", "hap-huyet":
			lines.append("Bình máu: %d · Thảo dược: %d." % [p.potions, p.herbs])
	for line in lines:
		var l := UiTheme.label(line, "Small", W)
		l.add_theme_color_override("font_color", UiTheme.MUTED)
		content.add_child(l)
