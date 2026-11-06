extends "res://scripts/ui/modal.gd"
## NV-A3 (docs/41): Sổ nhiệm vụ (phím O). Tab Chính · Phụ · Uỷ thác · Đã xong.
## Tab Chính: cột trái 9 chương (✓ xong · ◆ đang làm · khoá), cột phải chương đang chọn — dẫn truyện, các bước
## (✓ đã xong gạch, ◆ đang làm + tiến độ, ○ sắp tới), chi tiết bước đang làm (gợi ý, thưởng, chỉ đường) và nút
## "Chỉ đường" (đóng sổ, tự chạy tới mục tiêu / mở bảng cần dùng — main nối guide_requested).

signal guide_requested

const QuestLog = preload("res://scripts/core/quest_log.gd")
const Story = preload("res://scripts/data/story.gd")
const Hud = preload("res://scripts/ui/hud.gd")
const Quests = preload("res://scripts/core/quests.gd")
const SideQuests = preload("res://scripts/data/side_quests.gd")

const TABS := [["main", "Chính"], ["side", "Phụ"], ["daily", "Uỷ thác"], ["done", "Đã xong"]]

var _tab := "main"
var _chapter := 0
## NV-C: chuỗi phụ đang xem chi tiết ở tab Phụ.
var _focus := ""


func open(w) -> void:
	world = w
	var ms := QuestLog.main_step(w)
	_chapter = int(ms.get("chapter", _last_reached(w)))
	super.open(w)


func _last_reached(w) -> int:
	var last := 1
	for ch in range(1, 10):
		if _reached(w, ch):
			last = ch
	return last


func _reached(w, ch: int) -> bool:
	return ch == 1 or QuestLog.chapter_step(w, ch) >= 1


func _done(w, ch: int) -> bool:
	return QuestLog.chapter_step(w, ch) > QuestLog.quests_of(ch).size()


func _render(content: VBoxContainer) -> void:
	content.custom_minimum_size = Vector2(820, 520)
	_header(content, "Sổ nhiệm vụ", "Đóng (O)")
	var tabs := UiTheme.hbox(6)
	for t in TABS:
		var b := UiTheme.button(t[1], t[0] == _tab)
		b.name = "QuestTab_" + str(t[0])
		b.pressed.connect(func():
			_tab = t[0]
			refresh())
		tabs.add_child(b)
	content.add_child(tabs)
	match _tab:
		"main":
			_render_main(content)
		"done":
			_render_done(content)
		"daily":
			_render_daily(content)
		"side":
			_render_side(content)


func _render_main(content: VBoxContainer) -> void:
	var w = world
	var row := UiTheme.hbox(16)
	var left := UiTheme.vbox(4)
	left.custom_minimum_size.x = 230
	for ch in range(1, 10):
		var reached := _reached(w, ch)
		var mark := "✓" if _done(w, ch) else ("◆" if reached else "🔒")
		var b := UiTheme.button("%s  Chương %d · %s" % [mark, ch, QuestLog.CHAPTER_NAMES[ch - 1]] if reached else "%s  Chương %d" % [mark, ch], ch == _chapter)
		b.name = "QuestChapter_%d" % ch
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.disabled = not reached
		b.pressed.connect(func():
			_chapter = ch
			refresh())
		left.add_child(b)
	row.add_child(left)
	var right := UiTheme.vbox(6)
	right.custom_minimum_size.x = 540
	var ch := clampi(_chapter, 1, 9)
	right.add_child(UiTheme.strong("Chương %d · %s" % [ch, QuestLog.CHAPTER_NAMES[ch - 1]], 18, UiTheme.GOLD))
	right.add_child(UiTheme.label(QuestLog.CHAPTER_LORE[ch - 1], "Muted", 520))
	var qs: Array = QuestLog.quests_of(ch)
	var cur := QuestLog.chapter_step(w, ch)
	var ms := QuestLog.main_step(w)
	var active_here: bool = int(ms.get("chapter", 0)) == ch
	var list := UiTheme.vbox(3)
	for i in qs.size():
		var q: Dictionary = qs[i]
		var n := i + 1
		var txt: String
		var col := UiTheme.MUTED
		if n < cur or _done(w, ch):
			txt = "✓  " + str(q.title)
			col = Color(UiTheme.MUTED, 0.75)
		elif n == cur and active_here:
			var st: Array = ms.status
			txt = "◆  " + str(q.title) + ("  (%d/%d)" % st if int(st[1]) > 1 else "")
			col = UiTheme.GOLD
		else:
			txt = "○  " + str(q.title)
		var l := UiTheme.label(txt, "", 520)
		l.add_theme_color_override("font_color", col)
		list.add_child(l)
	right.add_child(list)
	if active_here:
		var q: Dictionary = ms.q
		var det := UiTheme.vbox(4)
		det.add_child(UiTheme.label("ĐANG LÀM", "Eyebrow"))
		det.add_child(UiTheme.label(str(q.hint), "", 520))
		var rt := Story.reward_text(q.reward)
		if rt != "":
			det.add_child(UiTheme.label(Hud.group_numbers("Thưởng: " + rt), "Muted", 520))
		var g := QuestLog.guide(w)
		var r: Dictionary = g.get("route", {})
		var where := Hud.group_numbers(QuestLog.guide_text(w))
		if where != "":
			var wl := UiTheme.label(where, "", 520)
			wl.add_theme_color_override("font_color", UiTheme.GOLD)
			det.add_child(wl)
		var go := UiTheme.button("Chỉ đường", true)
		go.name = "QuestGuideButton"
		go.disabled = r.is_empty() or (r.pos == Vector2.INF and str(r.panel) == "")
		go.pressed.connect(func():
			close()
			guide_requested.emit())
		det.add_child(go)
		right.add_child(det)
	row.add_child(right)
	content.add_child(row)


func _render_done(content: VBoxContainer) -> void:
	var w = world
	var col := UiTheme.vbox(3)
	var n := 0
	for ch in range(1, 10):
		var qs: Array = QuestLog.quests_of(ch)
		var cur := QuestLog.chapter_step(w, ch)
		for i in qs.size():
			if i + 1 < cur or _done(w, ch):
				col.add_child(UiTheme.label("✓  Chương %d · %s" % [ch, qs[i].title], "Muted", 760))
				n += 1
	if n == 0:
		col.add_child(UiTheme.label("Chưa hoàn thành nhiệm vụ nào.", "Muted"))
	var sc := ScrollContainer.new()
	sc.custom_minimum_size = Vector2(780, 440)
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	sc.add_child(col)
	content.add_child(sc)


## NV-D (docs/41): tab Uỷ thác — 3 việc hôm nay (tiến độ, thưởng, Ghim / Đổi / Nhận thưởng), chuỗi ngày, Điểm Uỷ Thác
## + cửa hàng điểm. Nhận thưởng chỉ ở khu an toàn.
func _render_daily(content: VBoxContainer) -> void:
	var w = world
	var ts: Array = Quests.tasks(w)
	var d: Dictionary = w.profile.daily
	var head := UiTheme.label("Uỷ thác hôm nay — đổi lúc 0 giờ. Mỗi việc: +%s EXP, +1 Đuốc, +%d Điểm Uỷ Thác. Đủ 3 việc: rương ngày + chuỗi ngày (%d/%d; 7 ngày: 1 món Tím)." 		% [Hud.group_numbers(str(Quests.reward_exp(w))), Quests.TASK_POINTS, int(d.get("streak", 0)), Quests.STREAK_GOAL], "Muted", 780)
	content.add_child(head)
	for i in ts.size():
		var t: Dictionary = ts[i]
		var row := UiTheme.hbox(10)
		var info := UiTheme.vbox(2)
		info.custom_minimum_size.x = 440
		var mark := "✓" if bool(t.claimed) else ("◆" if Quests.done(t) else "◇")
		info.add_child(UiTheme.strong("%s  %s  (%d/%d)" % [mark, Quests.task_title(t), int(t.n), int(t.need)], 15, UiTheme.GOLD if not bool(t.claimed) else UiTheme.MUTED))
		info.add_child(UiTheme.label(Quests.task_hint(t), "Muted", 440))
		row.add_child(info)
		var key := "daily:%d" % i
		var pin := UiTheme.button("Bỏ ghim" if QuestLog.is_tracked(w, key) else "Ghim")
		pin.name = "DailyPin_%d" % i
		pin.disabled = bool(t.claimed)
		pin.pressed.connect(func():
			QuestLog.toggle_track(w, key)
			refresh())
		row.add_child(pin)
		var sw := UiTheme.button("Đổi")
		sw.name = "DailySwap_%d" % i
		sw.disabled = not Quests.can_swap(w, i)
		sw.tooltip_text = "Đổi sang việc khác (1 lần / ngày)"
		sw.pressed.connect(func():
			Quests.swap(w, i)
			refresh())
		row.add_child(sw)
		var why := Quests.claim_blocker(w, i)
		var cl := UiTheme.button("Nhận thưởng", why == "")
		cl.name = "DailyClaim_%d" % i
		cl.disabled = why != ""
		cl.tooltip_text = why
		cl.pressed.connect(func():
			Quests.claim(w, i)
			refresh())
		row.add_child(cl)
		content.add_child(row)
		if why != "" and why != "Chưa xong." and why != "Đã nhận thưởng.":
			content.add_child(UiTheme.label("   " + why, "Muted", 760))
	var shop := UiTheme.hbox(8)
	shop.add_child(UiTheme.strong("Điểm Uỷ Thác: %d" % int(d.get("points", 0)), 15, UiTheme.GOLD))
	for r in Quests.SHOP:
		var b := UiTheme.button("%s · %d điểm" % [r[1], int(r[2])])
		b.name = "DailyShop_" + str(r[0])
		b.disabled = int(d.get("points", 0)) < int(r[2])
		b.pressed.connect(func():
			Quests.buy(w, str(r[0]))
			refresh())
		shop.add_child(b)
	content.add_child(shop)


## Mở tab Phụ tại chuỗi id (main gọi khi E ở NPC có việc chờ trả).
func show_side(id: String) -> void:
	_tab = "side"
	_focus = id
	refresh()


## NV-C (docs/41): tab Phụ — đang làm (bước, tiến độ, Ghim; xong → chọn 1 trong 3 thưởng), có thể nhận (người giao ở
## đâu), đã xong + danh hiệu.
func _render_side(content: VBoxContainer) -> void:
	var w = world
	var col := UiTheme.vbox(6)
	var active: Array = SideQuests.SIDE.filter(func(q): return str(Quests.side_state(w, q.id).get("state", "")) in ["active", "reward"])
	col.add_child(UiTheme.label("ĐANG LÀM (%d)" % active.size(), "Eyebrow"))
	if active.is_empty():
		col.add_child(UiTheme.label("Chưa nhận nhiệm vụ phụ nào — tìm NPC có dấu ! vàng trong khu an toàn, bấm E.", "Muted", 760))
	for q in active:
		col.add_child(_side_card(w, q))
	var offers: Array = SideQuests.SIDE.filter(func(q): return Quests.side_available(w, q))
	if not offers.is_empty():
		col.add_child(UiTheme.label("CÓ THỂ NHẬN (%d)" % offers.size(), "Eyebrow"))
		for q in offers:
			var m := QuestLog.npc_map(str(q.giver))
			var where: String = str(QuestLog.Maps.get_map(m).get("safe", {}).get("name", m)) if m != "" else ""
			col.add_child(UiTheme.label("!  %s — gặp %s ở %s" % [q.title, _npc_name(m, str(q.giver)), where], "", 760))
	var done: Array = SideQuests.SIDE.filter(func(q): return str(Quests.side_state(w, q.id).get("state", "")) == "done")
	col.add_child(UiTheme.label("ĐÃ HOÀN THÀNH %d / %d · Danh hiệu: %s" % [done.size(), SideQuests.SIDE.size(), ", ".join(w.profile.titles) if not w.profile.titles.is_empty() else "chưa có"], "Muted", 760))
	if not w.profile.titles.is_empty():
		var tr := UiTheme.hbox(6)
		tr.add_child(UiTheme.label("Đeo danh hiệu:", "Muted", 0))
		for t in w.profile.titles + [""]:
			var b := UiTheme.button(str(t) if str(t) != "" else "Không đeo", str(t) == str(w.profile.title))
			b.pressed.connect(func():
				w.profile.title = str(t)
				refresh())
			tr.add_child(b)
		col.add_child(tr)
	var sc := ScrollContainer.new()
	sc.custom_minimum_size = Vector2(800, 420)
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	sc.add_child(col)
	content.add_child(sc)


func _npc_name(map_id: String, npc_id: String) -> String:
	if map_id == "":
		return npc_id
	for n in QuestLog.Maps.MAPS[map_id].get("npcs", []):
		if str(n[0]) == npc_id:
			return str(n[3]).replace(" · E", "")
	return npc_id


func _side_card(w, q: Dictionary) -> Control:
	var s := Quests.side_state(w, q.id)
	var box := UiTheme.vbox(3)
	box.name = "SideCard_" + str(q.id)
	var ready := str(s.state) == "reward"
	box.add_child(UiTheme.strong(("?  " if ready else "◆  ") + str(q.title), 16, UiTheme.GOLD))
	box.add_child(UiTheme.label(str(q.lore), "Muted", 740))
	for i in q.steps.size():
		var st: Dictionary = q.steps[i]
		var txt := str(st.text)
		var c := UiTheme.MUTED
		if i < int(s.step) or ready:
			txt = "✓  " + txt
		elif i == int(s.step):
			txt = "◇  %s  (%d/%d)" % [txt, int(s.n), int(st.need)]
			c = UiTheme.TEXT
		else:
			txt = "○  " + txt
		var l := UiTheme.label(txt, "", 740)
		l.add_theme_color_override("font_color", c)
		box.add_child(l)
	var row := UiTheme.hbox(8)
	if ready:
		row.add_child(UiTheme.label("Chọn 1 phần thưởng:", "", 0))
		for k in q.reward.choices.size():
			var b := UiTheme.button(str(q.reward.choices[k][0]), k == 0)
			b.name = "SideReward_%s_%d" % [q.id, k]
			b.pressed.connect(func():
				Quests.side_claim(w, str(q.id), k)
				refresh())
			row.add_child(b)
	else:
		var key := "side:" + str(q.id)
		var pin := UiTheme.button("Bỏ ghim" if QuestLog.is_tracked(w, key) else "Ghim")
		pin.name = "SidePin_" + str(q.id)
		pin.pressed.connect(func():
			QuestLog.toggle_track(w, key)
			refresh())
		row.add_child(pin)
	if q.reward.has("title"):
		row.add_child(UiTheme.label("+ danh hiệu \"%s\"" % q.reward.title, "Muted", 0))
	box.add_child(row)
	return box
