extends "res://scripts/ui/modal.gd"
## SK1 (docs/13): bảng Kỹ năng (phím U) — kỹ năng của lớp, cấp kỹ năng, Điểm Kỹ Năng,
## lắp vào 4 ô (chỉ ở vùng an toàn), tẩy điểm miễn phí ở vùng an toàn.
## SK2: biến thể 3 tầng mở ở cấp kỹ năng 4 / 7 / 10 (đổi ở vùng an toàn). SK3: tối thượng, nhánh chuyển chức 2, Bí Kíp.
## UI-23: giao diện mới — cột tab trái (Lớp · Chuyển chức 1 · Tối thượng · Chuyển chức 2), biển lớp + Điểm kỹ năng,
## cây kỹ năng có mũi tên theo thứ tự mở, cột phải chi tiết kỹ năng đang chọn (hiệu ứng hiện tại / cấp kế, Nâng cấp,
## ô lắp, biến thể), chân bảng Tẩy điểm.
## PV (docs/27): tab "Bị động" — cột trái 4 bị động học bằng Điểm Kỹ Năng (cấp 0–5), cột phải bị động sẵn có
## (đặc tính lớp, chuyển chức 1 / 2 / 3) chỉ để xem.

const Classes = preload("res://scripts/data/classes.gd")
const Skills2 = preload("res://scripts/core/skills2.gd")
const Passives = preload("res://scripts/core/passives.gd")
const SpriteLib = preload("res://scripts/view/sprite_lib.gd")
const StatsPage = preload("res://scripts/ui/stats_page.gd")
const CharBar = preload("res://scripts/ui/char_bar.gd")

## UI-28b: bấm tab khác trên thanh tiêu đề chung — main.gd đóng bảng này rồi mở bảng / tab tương ứng.
signal open_panel(id: String)
const ClassSelect = preload("res://scripts/ui/class_select.gd")

const TREE_W := 520.0
const TREE_H := 436.0
const DETAIL_W := 340.0
const NODE := 54.0
const CELL_W := 170.0
const GOLD_LIGHT := Color("#f3d27a")

## Tab đang mở: "base" | "job" | "ult" | "job2" | "job3" | "passive"; kỹ năng đang chọn (id).
var _tab := "base"
var _sel := ""


## Ô kỹ năng trên cây: khung vuông, icon, khoá, huy hiệu cấp "n/10", số ô đang lắp ở góc.
class SkillNode:
	extends Control
	var tex: Texture2D
	var unlocked := true
	var selected := false
	var level := 1
	## PV: cấp tối đa trên huy hiệu; level < 0 = không có huy hiệu (bị động sẵn có).
	var max_level := Classes.SKILL_MAX_LEVEL
	var slot := -1
	var on_click: Callable

	func _init() -> void:
		custom_minimum_size = Vector2(56, 56)
		mouse_default_cursor_shape = CURSOR_POINTING_HAND

	func _gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			on_click.call()
			accept_event()

	func _draw() -> void:
		var r := Rect2(Vector2.ZERO, size)
		if selected:
			draw_rect(r.grow(5), Color(1.0, 0.82, 0.4, 0.18))
			draw_rect(r.grow(3), Color(1.0, 0.82, 0.4, 0.35))
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color("#1a1420") if unlocked else Color("#1c1210")
		sb.set_corner_radius_all(6)
		sb.set_border_width_all(3 if selected else 2)
		sb.border_color = Color("#f3d27a") if selected else (Color("#c9a45c") if unlocked else Color("#5a4220"))
		draw_style_box(sb, r)
		if tex != null:
			draw_texture_rect(tex, r.grow(-5), false, Color.WHITE if unlocked else Color(0.55, 0.4, 0.38))
		if not unlocked:
			# ổ khoá
			var c := Vector2(size.x / 2.0, size.y - 15)
			draw_arc(c + Vector2(0, -5), 5.0, PI, TAU, 12, Color("#e8e0d0"), 2.0)
			draw_rect(Rect2(c + Vector2(-7, -5), Vector2(14, 11)), Color("#e8e0d0"))
			draw_rect(Rect2(c + Vector2(-1, -2), Vector2(2, 5)), Color("#3a2a1a"))
			return
		if level < 0:
			return
		var f := UiTheme.bold_font()
		var txt := "%d/%d" % [level, max_level]
		var pill := Rect2(Vector2(size.x / 2.0 - 20, size.y - 10), Vector2(40, 16))
		var ps := StyleBoxFlat.new()
		ps.bg_color = Color("#120c08")
		ps.set_corner_radius_all(8)
		ps.set_border_width_all(1)
		ps.border_color = Color("#c9a45c")
		draw_style_box(ps, pill)
		draw_string(f, Vector2(pill.position.x, pill.position.y + 12), txt, HORIZONTAL_ALIGNMENT_CENTER, pill.size.x, 11, Color.WHITE)
		if slot >= 0:
			var c2 := Vector2(size.x - 2, 2)
			draw_circle(c2, 9.0, Color("#2a5a9a"))
			draw_arc(c2, 9.0, 0, TAU, 20, Color("#cfe3ff"), 1.5)
			draw_string(f, c2 + Vector2(-9, 4), str(slot + 1), HORIZONTAL_ALIGNMENT_CENTER, 18, 11, Color.WHITE)


## Nền cây kỹ năng: đường nối gấp khúc vàng + đầu mũi tên từ kỹ năng trước tới kỹ năng mở sau.
class TreeCanvas:
	extends Control
	## [Vector2 điểm đi, Vector2 điểm đến]
	var edges: Array = []

	func _draw() -> void:
		var col := Color("#c9a45c")
		for e in edges:
			var a: Vector2 = e[0]
			var b: Vector2 = e[1]
			var pts := PackedVector2Array([a])
			if absf(a.x - b.x) > 1.0:
				var my := a.y + 8.0
				pts.append(Vector2(a.x, my))
				pts.append(Vector2(b.x, my))
			pts.append(b - Vector2(0, 5))
			draw_polyline(pts, col, 2.0)
			draw_colored_polygon(PackedVector2Array([b, b + Vector2(-5, -7), b + Vector2(5, -7)]), col)


func _render(content: VBoxContainer) -> void:
	var p = world.profile
	content.add_theme_constant_override("separation", 10)
	var groups := _groups()
	if _group(groups, _tab).is_empty():
		_tab = str(groups[0].id) if not groups.is_empty() else "base"
	var g := _group(groups, _tab)
	var skills: Array = g.get("skills", [])
	var found := false
	for sk in skills + g.get("extra", []):
		found = found or str(sk.id) == _sel
	if not found:
		_sel = str(skills[0].id) if not skills.is_empty() else ""

	# UI-28b: thanh tiêu đề chung nhóm Nhân vật — chuyển sang Thuộc tính / Trang bị / Tài nguyên / Thiên phú
	content.add_child(CharBar.build(world, "skills", func(key: String): open_panel.emit(key), close))
	var body := UiTheme.hbox(12)
	body.add_child(_tabs(groups))
	var mid := UiTheme.vbox(10)
	mid.add_child(_banner(p))
	var passive := _tab == "passive"
	mid.add_child(_passive_tree(g) if passive else _tree(g))
	body.add_child(mid)
	var det := UiTheme.panel(UiTheme.inset(Color("#1a120b"), Color("#5a4220"), 12, 10))
	det.name = "SkillDetail"
	var sel := Classes.skill_by_id(str(p.class_id), _sel)
	var dv := UiTheme.vbox(10)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(DETAIL_W, TREE_H - 26)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.add_child(_passive_detail(g) if passive else _detail(sel))
	dv.add_child(scroll)
	dv.add_child(_passive_upgrade() if passive else _upgrade_block(sel))
	det.add_child(dv)
	body.add_child(det)
	content.add_child(body)
	content.add_child(_footer())


# ------------------------------------------------------------------ nhóm kỹ năng theo tab


## Chia kỹ năng của lớp thành các tab: lớp (cấp 1–29), chuyển chức 1, tối thượng, chuyển chức 2. Tab rỗng bị bỏ.
func _groups() -> Array:
	var p = world.profile
	var cid := str(p.class_id)
	var base: Array = []
	var job: Array = []
	var ult: Array = []
	var job2: Array = []
	var job3: Array = []
	for sk in Classes.skills_of(cid):
		if bool(sk.get("job3", false)):
			job3.append(sk)
		elif sk.has("job2"):
			# SK3: đã chọn nhánh chuyển chức 2 thì ẩn kỹ năng của nhánh còn lại.
			if str(p.job2) == "" or str(sk.job2) == str(p.job2):
				job2.append(sk)
		elif bool(sk.get("ultimate", false)):
			ult.append(sk)
		elif bool(sk.get("job", false)):
			job.append(sk)
		else:
			base.append(sk)
	var jd := Classes.job_def(cid)
	var j2 := Classes.job2_def(cid, str(p.job2))
	var j3 := Classes.job3_def(cid)
	var out: Array = []
	for g in [
			{"id": "base", "name": str(Classes.get_class_def(cid).name), "skills": base, "why": ""},
			{"id": "job", "name": str(jd.get("name", "Chuyển chức 1")), "skills": job,
				"why": "" if str(p.job) != "" else "Chuyển chức 1 ở cấp %d" % Classes.JOB_LEVEL},
			{"id": "ult", "name": "Tối thượng", "skills": ult,
				"why": "" if ult.is_empty() or int(p.level) >= int(ult[0].unlock) else "Mở ở cấp %d" % int(ult[0].unlock)},
			{"id": "job2", "name": str(j2.get("name", "Chuyển chức 2")), "skills": job2,
				"why": "" if str(p.job2) != "" else "Chuyển chức 2 ở cấp %d" % Classes.JOB2_LEVEL},
			# J3 (docs/23 J3-UI3): Thần Kỹ
			{"id": "job3", "name": str(j3.get("name", "Chức 3")) if str(p.job3) != "" else "Chức 3", "skills": job3,
				"why": "" if str(p.job3) != "" else "Chuyển chức 3 ở cấp %d" % Classes.JOB3_LEVEL},
			# PV (docs/27): bị động học được + bị động sẵn có (extra, chỉ xem)
			{"id": "passive", "name": "Bị động", "skills": Passives.defs_of(cid), "extra": _innate(),
				"why": "", "icon": "skill-pv-tab"}]:
		if not (g.skills as Array).is_empty():
			out.append(g)
	return out


func _group(groups: Array, id: String) -> Dictionary:
	for g in groups:
		if str(g.id) == id:
			return g
	return {}


# ------------------------------------------------------------------ tiêu đề, tab, biển lớp


func _tabs(groups: Array) -> Control:
	var col := UiTheme.vbox(8)
	var emblem := "skill-slash"
	for d in ClassSelect.CARDS:
		if str(d.id) == str(world.profile.class_id):
			emblem = str(d.emblem)
	for g in groups:
		var on: bool = str(g.id) == _tab
		var locked: bool = str(g.why) != ""
		var b := UiTheme.button(str(g.name))
		b.name = "Tab_" + str(g.id)
		b.icon = SpriteLib.icon(emblem if g.id == "base" else (str(g.icon) if g.has("icon") else "skill-" + str(g.skills[0].icon)))
		b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		b.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
		b.expand_icon = true
		b.custom_minimum_size = Vector2(104, 96)
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		b.add_theme_font_size_override("font_size", UiTheme.fs(13))
		b.add_theme_constant_override("icon_max_width", 40)
		var st := UiTheme.box(Color("#3a2a16") if on else Color("#1a120b"), 8, 2 if on else 1, GOLD_LIGHT if on else UiTheme.GOLD_DARK, 8)
		b.add_theme_stylebox_override("normal", st)
		b.add_theme_stylebox_override("hover", UiTheme.box(Color("#2e2216"), 8, 2, Color("#c9a45c"), 8))
		b.add_theme_stylebox_override("pressed", st)
		b.add_theme_color_override("font_color", GOLD_LIGHT if on else (UiTheme.MUTED if locked else UiTheme.TEXT))
		if locked:
			b.modulate = Color(1, 1, 1, 0.7)
		b.tooltip_text = str(g.why) if locked else str(g.name)
		var id: String = g.id
		b.pressed.connect(func():
			_tab = id
			_sel = ""
			refresh())
		col.add_child(b)
	return col


func _banner(p) -> Control:
	var cid := str(p.class_id)
	var card: Dictionary = {}
	for d in ClassSelect.CARDS:
		if str(d.id) == cid:
			card = d
	var accent := Color(str(card.get("accent", "#c9a45c")))
	var pn := UiTheme.panel(UiTheme.box(Color("#141a2a"), 8, 2, UiTheme.GOLD_DARK, 0))
	pn.custom_minimum_size = Vector2(TREE_W, 92)
	pn.clip_contents = true
	var h := UiTheme.hbox(10)
	pn.add_child(h)
	var sc := ClassSelect.ClassScene.new()
	sc.class_id = cid
	sc.look = p.look
	sc.kind = str(card.get("scene", "hall"))
	sc.accent = accent
	sc.custom_minimum_size = Vector2(130, 92)
	h.add_child(sc)
	var nv := UiTheme.vbox(4)
	nv.size_flags_horizontal = SIZE_EXPAND_FILL
	nv.size_flags_vertical = SIZE_SHRINK_CENTER
	nv.add_child(UiTheme.strong(Classes.title(cid, str(p.job), str(p.job2), str(p.job3)), 24, Color.WHITE))
	var q := UiTheme.label(str(StatsPage.QUOTES.get(cid, "")), "Muted", 210)
	q.add_theme_font_size_override("font_size", UiTheme.fs(12))
	nv.add_child(q)
	h.add_child(nv)
	# Điểm kỹ năng còn lại
	var pbox := UiTheme.panel(UiTheme.box(Color(0, 0, 0, 0.35), 0, 0, UiTheme.LINE, 8))
	pbox.custom_minimum_size.x = 160
	var bv := UiTheme.vbox(2)
	pbox.add_child(bv)
	var pts := int(p.skill_points)
	var t := UiTheme.strong("Điểm kỹ năng còn lại", 13, GOLD_LIGHT)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bv.add_child(t)
	var circ := UiTheme.panel(UiTheme.box(Color("#1a120b"), 22, 2, UiTheme.GOLD if pts > 0 else UiTheme.GOLD_DARK, 0))
	circ.name = "SkillPoints"
	circ.custom_minimum_size = Vector2(44, 44)
	circ.size_flags_horizontal = SIZE_SHRINK_CENTER
	var n := UiTheme.strong(str(pts), 22, UiTheme.GOLD if pts > 0 else UiTheme.TEXT)
	n.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	n.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	circ.add_child(n)
	bv.add_child(circ)
	var hint := UiTheme.label("Mỗi cấp: +%d%% sát thương\n−%d%% hồi chiêu (hỗ trợ)" % [
		roundi(Classes.SKILL_LEVEL_MUL * 100), roundi(Classes.SKILL_LEVEL_CD * 100)], "Small")
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bv.add_child(hint)
	pbox.tooltip_text = "Mỗi lần lên cấp +1 Điểm Kỹ Năng; mỗi Bí Kíp nhặt được +1. Dùng để nâng kỹ năng, học bị động và mở biến thể ✦."
	h.add_child(pbox)
	return pn


# ------------------------------------------------------------------ cây kỹ năng


## Vị trí ô trên cây: 2 kỹ năng đầu xếp dọc giữa, các kỹ năng sau chia 2 nhánh trái/phải (mỗi nhánh nối tiếp nhau).
## Tab chuyển chức 2 chưa chọn nhánh: mỗi nhánh 1 cột. Trả về [[cột 0..2, hàng], ...] và cạnh [[cha, con], ...].
func _layout(g: Dictionary) -> Array:
	var skills: Array = g.skills
	var cells: Array = []
	var edges: Array = []
	if str(g.id) == "job2" and str(world.profile.job2) == "":
		var branches: Array = []
		for sk in skills:
			if not branches.has(str(sk.job2)):
				branches.append(str(sk.job2))
		var rows := {}
		for i in skills.size():
			var b := branches.find(str(skills[i].job2))
			var r: int = rows.get(b, 0)
			cells.append([0 if b == 0 else 2, r])
			if r > 0:
				edges.append([i - 1, i])
			rows[b] = r + 1
		return [cells, edges]
	for i in skills.size():
		if i < 2:
			cells.append([1, i])
			if i == 1:
				edges.append([0, 1])
		else:
			cells.append([(i - 2) % 2 * 2, 2 + (i - 2) / 2])
			edges.append([1 if i < 4 else i - 2, i])
	return [cells, edges]


func _tree(g: Dictionary) -> Control:
	var frame := UiTheme.panel(UiTheme.inset(Color("#140e0a"), Color("#5a4220"), 0, 8))
	var canvas := TreeCanvas.new()
	canvas.custom_minimum_size = Vector2(TREE_W, TREE_H)
	frame.add_child(canvas)
	if g.is_empty():
		return frame
	var lay := _layout(g)
	var cells: Array = lay[0]
	var rows := 1
	for c in cells:
		rows = maxi(rows, int(c[1]) + 1)
	var top := 8.0
	if str(g.id) == "job2" and str(world.profile.job2) == "":
		top = 40.0
		for j in Classes.job2_defs(str(world.profile.class_id)):
			var idx := Classes.job2_defs(str(world.profile.class_id)).find(j)
			var hl := UiTheme.strong("Nhánh %s" % j.name, 14, Color(str(j.color)))
			hl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			hl.custom_minimum_size.x = CELL_W
			hl.position = Vector2(_col_x(0 if idx == 0 else 2) - CELL_W / 2.0, 10)
			canvas.add_child(hl)
	var row_h := minf(120.0, (TREE_H - top) / rows)
	var ends: Array = []
	for i in g.skills.size():
		var sk: Dictionary = g.skills[i]
		var x := _col_x(int(cells[i][0]))
		var y := top + int(cells[i][1]) * row_h
		var unlocked: bool = world.skill_unlocked(sk)
		var cell := UiTheme.vbox(2)
		cell.position = Vector2(x - CELL_W / 2.0, y)
		cell.custom_minimum_size.x = CELL_W
		var nd := SkillNode.new()
		nd.name = "Node_" + str(sk.id)
		nd.tex = SpriteLib.icon("skill-" + str(sk.icon))
		nd.unlocked = unlocked
		nd.selected = str(sk.id) == _sel
		nd.level = world.skill_level(str(sk.id))
		nd.slot = world.profile.loadout.find(str(sk.id))
		nd.custom_minimum_size = Vector2(NODE, NODE)
		nd.size_flags_horizontal = SIZE_SHRINK_CENTER
		nd.tooltip_text = str(sk.name)
		var id: String = sk.id
		nd.on_click = func():
			_sel = id
			refresh()
		cell.add_child(nd)
		var gap := Control.new()
		gap.custom_minimum_size.y = 4
		cell.add_child(gap)
		var nm := UiTheme.strong(str(sk.name), 13, GOLD_LIGHT if nd.selected else (Color.WHITE if unlocked else UiTheme.MUTED))
		nm.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cell.add_child(nm)
		var bottom := y + NODE + 26.0
		if not unlocked:
			var why := UiTheme.label(_lock_reason(sk), "Small")
			why.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			cell.add_child(why)
			bottom += 15.0
		canvas.add_child(cell)
		ends.append([Vector2(x, y), Vector2(x, bottom)])
	for e in lay[1]:
		canvas.edges.append([ends[e[0]][1] + Vector2(0, 2), ends[e[1]][0] - Vector2(0, 2)])
	return frame


func _col_x(col: int) -> float:
	return TREE_W * [0.25, 0.5, 0.75][col]


func _lock_reason(sk: Dictionary) -> String:
	var p = world.profile
	if bool(sk.get("job", false)) and str(p.job) == "":
		return "Cần chuyển chức 1"
	if sk.has("job2") and str(p.job2) != str(sk.job2):
		return "Cần chuyển chức 2" if str(p.job2) == "" else "Nhánh khác"
	if bool(sk.get("job3", false)) and str(p.job3) == "":
		return "Cần chuyển chức 3"
	return "Mở ở cấp %d" % int(sk.unlock)


# ------------------------------------------------------------------ cột phải: chi tiết kỹ năng


func _detail(sk: Dictionary) -> Control:
	var col := UiTheme.vbox(8)
	col.custom_minimum_size.x = DETAIL_W - 14
	if sk.is_empty():
		col.add_child(UiTheme.label("Chọn một kỹ năng trên cây.", "Muted"))
		return col
	var id: String = sk.id
	var p = world.profile
	var unlocked: bool = world.skill_unlocked(sk)
	var lv: int = world.skill_level(id)
	var maxed := lv >= Classes.SKILL_MAX_LEVEL

	var head := UiTheme.hbox(10)
	var icf := UiTheme.panel(UiTheme.box(Color("#101826"), 6, 2, Color("#c9a45c"), 3))
	var ic := UiTheme.icon_rect(SpriteLib.icon("skill-" + str(sk.icon)), 70)
	ic.modulate = Color.WHITE if unlocked else Color(0.55, 0.45, 0.42)
	icf.add_child(ic)
	head.add_child(icf)
	var hv := UiTheme.vbox(4)
	hv.size_flags_horizontal = SIZE_EXPAND_FILL
	hv.add_child(UiTheme.strong(str(sk.name), 20, Color.WHITE))
	var tags := UiTheme.hbox(4)
	var kind := "Tối thượng" if bool(sk.get("ultimate", false)) else ("Hỗ trợ" if Skills2.is_utility(sk) else "Chủ động")
	tags.add_child(_chip(kind, Color("#8fb8ff")))
	var el := Skills2.element_of(world, id)
	if el != "":
		tags.add_child(_chip("Hệ " + str(Skills2.ELEMENT_NAMES[el]), Color("#ffb070")))
	hv.add_child(tags)
	hv.add_child(UiTheme.strong(("Cấp %d / %d" % [lv, Classes.SKILL_MAX_LEVEL]) if unlocked else _lock_reason(sk), 16,
		UiTheme.TEXT if unlocked else UiTheme.BAD))
	head.add_child(hv)
	col.add_child(head)

	col.add_child(UiTheme.label(str(sk.text), "", DETAIL_W - 14))
	col.add_child(UiTheme.label("Biến thể mở ở cấp kỹ năng 4 / 7 / 10.", "Muted", DETAIL_W - 14))

	col.add_child(_effect_box("Hiệu ứng hiện tại (Cấp %d)" % lv, sk, lv, -1))
	if not maxed:
		col.add_child(_effect_box("Hiệu ứng cấp kế (Cấp %d)" % (lv + 1), sk, lv + 1, lv))

	if unlocked:
		col.add_child(_slots(id))
		col.add_child(_variants(sk))
	return col


## Chân cột chi tiết (cố định, không cuộn): thanh cấp kỹ năng + nút Nâng cấp.
func _upgrade_block(sk: Dictionary) -> Control:
	var col := UiTheme.vbox(8)
	if sk.is_empty():
		return col
	var id: String = sk.id
	var p = world.profile
	var unlocked: bool = world.skill_unlocked(sk)
	var lv: int = world.skill_level(id)
	var maxed := lv >= Classes.SKILL_MAX_LEVEL
	# thanh cấp
	var lvbox := UiTheme.panel(UiTheme.box(Color(0, 0, 0, 0.25), 6, 1, Color("#5a4220"), 8))
	var lvv := UiTheme.vbox(4)
	lvbox.add_child(lvv)
	lvv.add_child(UiTheme.label("Cấp %d / %d" % [lv, Classes.SKILL_MAX_LEVEL]))
	var bar := ProgressBar.new()
	bar.theme_type_variation = "PoiseBar"
	bar.max_value = Classes.SKILL_MAX_LEVEL
	bar.value = lv
	bar.show_percentage = false
	bar.custom_minimum_size.y = 16
	lvv.add_child(bar)
	col.add_child(lvbox)

	var up := UiTheme.button("+  Nâng cấp" if not maxed else "Đã đạt cấp tối đa", true)
	up.name = "SkillUp_" + id
	up.custom_minimum_size.y = 48
	up.add_theme_font_size_override("font_size", UiTheme.fs(18))
	up.disabled = not unlocked or maxed or int(p.skill_points) <= 0
	up.pressed.connect(func():
		world.skill_upgrade(id)
		refresh())
	col.add_child(up)
	if unlocked and not maxed and int(p.skill_points) <= 0:
		up.tooltip_text = "Hết Điểm Kỹ Năng — mỗi lần lên cấp nhận +1."
	return col


func _chip(text: String, color: Color) -> Control:
	var c := UiTheme.panel(UiTheme.box(Color(color, 0.12), 4, 1, Color(color, 0.6), 3))
	c.add_child(UiTheme.strong(text, 11, color))
	return c


## Bảng chỉ số kỹ năng ở cấp lv; prev ≥ 1 thì so với cấp prev (hiện chênh lệch màu xanh).
func _effect_box(title: String, sk: Dictionary, lv: int, prev: int) -> Control:
	var pn := UiTheme.panel(UiTheme.box(Color(0, 0, 0, 0.2), 4, 0, UiTheme.LINE, 8))
	var v := UiTheme.vbox(3)
	pn.add_child(v)
	var hd := UiTheme.strong(title, 14, GOLD_LIGHT)
	v.add_child(hd)
	var now := _numbers(sk, lv)
	var before := _numbers(sk, prev) if prev >= 1 else {}
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 2)
	for k in now:
		var l := UiTheme.label(str(k), "Muted")
		l.custom_minimum_size.x = 120
		grid.add_child(l)
		var val: Array = now[k]
		grid.add_child(UiTheme.label(str(val[1])))
		var diff := ""
		if before.has(k) and absf(float(val[0]) - float(before[k][0])) > 0.001:
			var d := float(val[0]) - float(before[k][0])
			diff = ("▲ +" if d > 0 else "▼ ") + _num(d) + str(val[2])
		var dl := UiTheme.label(diff)
		dl.add_theme_color_override("font_color", UiTheme.GOOD)
		grid.add_child(dl)
	v.add_child(grid)
	return pn


## {tên: [giá trị số, chữ hiển thị, đơn vị chênh lệch]} của kỹ năng ở cấp lv (theo biến thể đang chọn).
func _numbers(sk: Dictionary, lv: int) -> Dictionary:
	var id: String = sk.id
	var out := {}
	var mul := float(sk.mul)
	if mul > 0.0:
		var pct := roundf(mul * (1.0 + Classes.SKILL_LEVEL_MUL * (lv - 1)) * 100.0)
		out["Sát thương"] = [pct, "%d%% công" % int(pct), "%"]
	var re := RegEx.create_from_string("(\\d+(?:,\\d+)?) m\\b")
	var m := re.search(str(sk.text))
	if m != null:
		out["Phạm vi"] = [0.0, m.get_string(1) + " m", ""]
	var mp := float(sk.mp) * Skills2.cost_mult(world, id, "mp")
	out["Tiêu hao MP"] = [mp, _num(mp), ""]
	var cd := float(sk.cd)
	if Skills2.is_utility(sk):
		cd *= 1.0 - Classes.SKILL_LEVEL_CD * (lv - 1)
	cd *= Skills2.cost_mult(world, id, "cd")
	out["Hồi chiêu"] = [cd, _num(cd) + " giây", " giây"]
	return out


## Số kiểu Việt: 1 chữ số thập phân, dấu phẩy, bỏ ",0".
func _num(x: float) -> String:
	var s := "%.1f" % x
	if s.ends_with(".0"):
		s = s.substr(0, s.length() - 2)
	return s.replace(".", ",")


func _slots(id: String) -> Control:
	var safe: bool = world.in_safe_zone()
	var v := UiTheme.vbox(4)
	var row := UiTheme.hbox(6)
	row.add_child(UiTheme.strong("Lắp vào ô", 14, GOLD_LIGHT))
	row.add_child(UiTheme.spacer())
	var slot: int = world.profile.loadout.find(id)
	for i in Classes.SKILL_SLOTS:
		var b := UiTheme.button(str(i + 1), slot == i)
		b.name = "Slot_%s_%d" % [id, i]
		b.custom_minimum_size = Vector2(40, 36)
		b.tooltip_text = "Lắp vào ô %d (phím %d)" % [i + 1, i + 1]
		b.disabled = not safe or slot == i
		var si: int = i
		b.pressed.connect(func():
			world.set_slot(si, id)
			refresh())
		row.add_child(b)
	v.add_child(row)
	if not safe:
		v.add_child(UiTheme.label("Đổi ô và biến thể: về làng / trại / thành (vùng an toàn).", "Small", DETAIL_W - 14))
	return v


## SK2: 3 tầng biến thể, mỗi tầng chọn 1 (tầng II: 5 hệ ngũ hành với kỹ năng sát thương).
func _variants(sk: Dictionary) -> Control:
	var id: String = sk.id
	var safe: bool = world.in_safe_zone()
	var box := UiTheme.vbox(4)
	box.add_child(UiTheme.strong("Biến thể", 14, GOLD_LIGHT))
	var tiers: Array = Skills2.tiers_for(sk)
	var cur: Array = world.profile.variants.get(id, [])
	for t in 3:
		var open: bool = world.skill_level(id) >= Skills2.TIER_LEVELS[t]
		if not open:
			box.add_child(UiTheme.label("Tầng %s mở ở cấp kỹ năng %d." % [Skills2.TIER_NAMES[t], Skills2.TIER_LEVELS[t]], "Small"))
			break
		box.add_child(UiTheme.label("Tầng %s (cấp %d)" % [Skills2.TIER_NAMES[t], Skills2.TIER_LEVELS[t]], "Small"))
		var row := HFlowContainer.new()
		row.add_theme_constant_override("h_separation", 4)
		row.add_theme_constant_override("v_separation", 4)
		for o in tiers[t]:
			var chosen: bool = t < cur.size() and str(cur[t]) == str(o[0])
			var book: bool = o.size() > 3
			var owned: bool = not book or Skills2.has_book(world, id, t)
			var b := UiTheme.button(("✦ " if book else "") + str(o[1]), chosen)
			b.name = "Var_%s_%d_%s" % [id, t, o[0]]
			b.tooltip_text = str(o[2]) + ("" if owned else "\nChưa mở — bấm \"Mở ✦\" (%d Điểm Kỹ Năng)." % Skills2.STAR_COST)
			b.disabled = not safe or chosen or not owned
			var tier: int = t
			var opt: String = o[0]
			b.pressed.connect(func():
				Skills2.set_variant(world, id, tier, opt)
				refresh())
			row.add_child(b)
			if book and not owned:
				# BK (docs/29): mở ✦ bằng Điểm Kỹ Năng — mở ở mọi nơi, chọn biến thể vẫn ở vùng an toàn.
				var why := Skills2.can_unlock_star(world, id, t)
				var ex := UiTheme.button("Mở ✦ (%d điểm)" % Skills2.STAR_COST, why == "")
				ex.name = "Book_%s_%d" % [id, t]
				ex.tooltip_text = why if why != "" else "Dùng %d Điểm Kỹ Năng để mở %s." % [Skills2.STAR_COST, str(o[1])]
				ex.disabled = why != ""
				ex.pressed.connect(func():
					Skills2.unlock_star(world, id, tier)
					refresh())
				row.add_child(ex)
		box.add_child(row)
	return box


# ------------------------------------------------------------------ chân bảng


func _footer() -> Control:
	var safe: bool = world.in_safe_zone()
	var foot := UiTheme.hbox(12)
	var reset := UiTheme.button("Tẩy điểm")
	reset.name = "SkillReset"
	reset.custom_minimum_size = Vector2(150, 38)
	reset.disabled = not safe
	reset.pressed.connect(func():
		world.skill_reset()
		refresh())
	foot.add_child(reset)
	var note := UiTheme.label(("Tẩy lại toàn bộ điểm kỹ năng, hoàn đủ điểm — miễn phí ở vùng an toàn." if safe
		else "Tẩy điểm và đổi ô kỹ năng: về làng / trại / thành (vùng an toàn)."), "Muted")
	note.size_flags_vertical = SIZE_SHRINK_CENTER
	foot.add_child(note)
	foot.add_child(UiTheme.spacer())
	var books := UiTheme.label("Bí Kíp = +1 Điểm Kỹ Năng", "Muted")
	books.tooltip_text = "Bí Kíp rơi từ tinh anh, boss vùng, Chúa Hang, boss hiếm và ô Di tích. Nhặt được là cộng ngay 1 Điểm Kỹ Năng."
	books.mouse_filter = Control.MOUSE_FILTER_STOP
	books.size_flags_vertical = SIZE_SHRINK_CENTER
	foot.add_child(books)
	return foot


# ------------------------------------------------------------------ PV: tab Bị động (docs/27)


## Bị động sẵn có: đặc tính lớp + hiệu ứng chuyển chức 1 / 2 / 3 (chỉ xem, không nâng cấp).
func _innate() -> Array:
	var p = world.profile
	var cid := str(p.class_id)
	var emblem := "skill-slash"
	for d in ClassSelect.CARDS:
		if str(d.id) == cid:
			emblem = str(d.emblem)
	var job_icon := func(pred: Callable) -> String:
		for sk in Classes.skills_of(cid):
			if pred.call(sk):
				return "skill-" + str(sk.icon)
		return emblem
	var jd := Classes.job_def(cid)
	var j2 := Classes.job2_def(cid, str(p.job2))
	var j3 := Classes.job3_def(cid)
	var j2_text := str(j2.get("text", ""))
	if j2.is_empty():
		var parts: Array = []
		for j in Classes.job2_defs(cid):
			parts.append("%s: %s" % [j.name, j.text])
		j2_text = "Chọn 1 trong 2 nhánh.\n" + "\n".join(parts)
	return [
		{"id": "trait", "name": "Đặc tính lớp", "icon": emblem, "owned": true, "why": "",
			"text": str(Passives.TRAITS.get(cid, ""))},
		{"id": "job1", "name": str(jd.get("name", "Chuyển chức 1")), "owned": str(p.job) != "",
			"icon": job_icon.call(func(sk): return bool(sk.get("job", false))),
			"why": "Chuyển chức 1 ở cấp %d" % Classes.JOB_LEVEL, "text": str(jd.get("text", ""))},
		{"id": "job2", "name": str(j2.get("name", "Chuyển chức 2")), "owned": str(p.job2) != "",
			"icon": job_icon.call(func(sk): return sk.has("job2") and (str(p.job2) == "" or str(sk.job2) == str(p.job2))),
			"why": "Chuyển chức 2 ở cấp %d" % Classes.JOB2_LEVEL, "text": j2_text},
		{"id": "job3", "name": str(j3.get("name", "Chuyển chức 3")) if str(p.job3) != "" else "Chuyển chức 3",
			"owned": str(p.job3) != "", "icon": job_icon.call(func(sk): return bool(sk.get("job3", false))),
			"why": "Chuyển chức 3 ở cấp %d" % Classes.JOB3_LEVEL, "text": "\n".join(j3.get("effects", []))},
	]


## Cây tab Bị động: cột trái 4 bị động nối theo cấp mở, cột phải bị động sẵn có.
func _passive_tree(g: Dictionary) -> Control:
	var frame := UiTheme.panel(UiTheme.inset(Color("#140e0a"), Color("#5a4220"), 0, 8))
	var canvas := TreeCanvas.new()
	canvas.custom_minimum_size = Vector2(TREE_W, TREE_H)
	frame.add_child(canvas)
	var p = world.profile
	var top := 34.0
	for pair in [[0, "Học bằng Điểm Kỹ Năng"], [2, "Sẵn có"]]:
		var hl := UiTheme.strong(str(pair[1]), 14, GOLD_LIGHT)
		hl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		hl.custom_minimum_size.x = CELL_W
		hl.position = Vector2(_col_x(int(pair[0])) - CELL_W / 2.0, 8)
		canvas.add_child(hl)
	var row_h := (TREE_H - top) / 4.0
	for c in [[g.skills, 0], [g.get("extra", []), 2]]:
		var learnable: bool = int(c[1]) == 0
		var list: Array = c[0]
		var ends: Array = []
		for i in list.size():
			var d: Dictionary = list[i]
			var x := _col_x(int(c[1]))
			var y := top + i * row_h
			var unlocked: bool = int(p.level) >= int(d.unlock) if learnable else bool(d.owned)
			var cell := UiTheme.vbox(2)
			cell.position = Vector2(x - CELL_W / 2.0, y)
			cell.custom_minimum_size.x = CELL_W
			var nd := SkillNode.new()
			nd.name = "Node_" + str(d.id)
			nd.tex = SpriteLib.icon(str(d.icon))
			nd.unlocked = unlocked
			nd.selected = str(d.id) == _sel
			nd.level = Passives.level_of(p, str(d.id)) if learnable else -1
			nd.max_level = Passives.MAX_LEVEL
			nd.custom_minimum_size = Vector2(NODE, NODE)
			nd.size_flags_horizontal = SIZE_SHRINK_CENTER
			nd.tooltip_text = str(d.name)
			var id: String = d.id
			nd.on_click = func():
				_sel = id
				refresh()
			cell.add_child(nd)
			var gap := Control.new()
			gap.custom_minimum_size.y = 4
			cell.add_child(gap)
			var nm := UiTheme.strong(str(d.name), 13, GOLD_LIGHT if nd.selected else (Color.WHITE if unlocked else UiTheme.MUTED))
			nm.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			cell.add_child(nm)
			var bottom := y + NODE + 26.0
			if not unlocked:
				var why := UiTheme.label(("Mở ở cấp %d" % int(d.unlock)) if learnable else str(d.why), "Small")
				why.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				cell.add_child(why)
				bottom += 15.0
			canvas.add_child(cell)
			ends.append([Vector2(x, y), Vector2(x, bottom)])
		if learnable:
			for i in range(1, ends.size()):
				# dòng "Mở ở cấp" làm hàng sát nhau: mũi tên quá ngắn sẽ đè lên chữ nên bỏ
				if ends[i][0].y - ends[i - 1][1].y >= 10.0:
					canvas.edges.append([ends[i - 1][1] + Vector2(0, 2), ends[i][0] - Vector2(0, 2)])
	return frame


func _passive_sel(g: Dictionary) -> Dictionary:
	for d in g.skills + g.get("extra", []):
		if str(d.id) == _sel:
			return d
	return {}


func _passive_detail(g: Dictionary) -> Control:
	var col := UiTheme.vbox(8)
	col.custom_minimum_size.x = DETAIL_W - 14
	var d := _passive_sel(g)
	if d.is_empty():
		col.add_child(UiTheme.label("Chọn một bị động trên cây.", "Muted"))
		return col
	var p = world.profile
	var learnable: bool = d.has("per")
	var lv := Passives.level_of(p, str(d.id)) if learnable else 0
	var unlocked: bool = int(p.level) >= int(d.unlock) if learnable else bool(d.owned)
	var head := UiTheme.hbox(10)
	var icf := UiTheme.panel(UiTheme.box(Color("#101826"), 6, 2, Color("#c9a45c"), 3))
	var ic := UiTheme.icon_rect(SpriteLib.icon(str(d.icon)), 70)
	ic.modulate = Color.WHITE if unlocked else Color(0.55, 0.45, 0.42)
	icf.add_child(ic)
	head.add_child(icf)
	var hv := UiTheme.vbox(4)
	hv.size_flags_horizontal = SIZE_EXPAND_FILL
	hv.add_child(UiTheme.strong(str(d.name), 20, Color.WHITE))
	var tags := UiTheme.hbox(4)
	tags.add_child(_chip("Bị động", Color("#9ad46a")))
	tags.add_child(_chip("Luôn có tác dụng" if learnable else "Sẵn có", Color("#8fb8ff")))
	hv.add_child(tags)
	var status := ""
	if learnable:
		status = ("Cấp %d / %d" % [lv, Passives.MAX_LEVEL]) if unlocked else "Mở ở cấp %d" % int(d.unlock)
	else:
		status = "Đang có" if unlocked else str(d.why)
	hv.add_child(UiTheme.strong(status, 16, UiTheme.TEXT if unlocked else UiTheme.BAD))
	head.add_child(hv)
	col.add_child(head)
	if not learnable:
		col.add_child(UiTheme.label(str(d.text), "", DETAIL_W - 14))
		col.add_child(UiTheme.label("Không tốn Điểm Kỹ Năng, không cần lắp vào ô.", "Muted", DETAIL_W - 14))
		return col
	col.add_child(UiTheme.label("Không cần lắp vào ô, không cần bấm. Mỗi cấp tốn 1 Điểm Kỹ Năng (dùng chung với kỹ năng chủ động).",
		"Muted", DETAIL_W - 14))
	col.add_child(_passive_box("Hiệu ứng hiện tại (Cấp %d)" % lv, Passives.describe(d, lv) if lv > 0 else "Chưa học."))
	if lv < Passives.MAX_LEVEL:
		col.add_child(_passive_box("Hiệu ứng cấp kế (Cấp %d)" % (lv + 1), Passives.describe(d, lv + 1)))
	return col


func _passive_box(title: String, text: String) -> Control:
	var pn := UiTheme.panel(UiTheme.box(Color(0, 0, 0, 0.2), 4, 0, UiTheme.LINE, 8))
	var v := UiTheme.vbox(3)
	pn.add_child(v)
	v.add_child(UiTheme.strong(title, 14, GOLD_LIGHT))
	v.add_child(UiTheme.label(text, "", DETAIL_W - 34))
	return pn


## Chân cột chi tiết của bị động học được: thanh cấp 0–5 + nút Học / Nâng cấp.
func _passive_upgrade() -> Control:
	var col := UiTheme.vbox(8)
	var p = world.profile
	var d := Passives.def_of(str(p.class_id), _sel)
	if d.is_empty():
		return col
	var id: String = d.id
	var lv := Passives.level_of(p, id)
	var maxed := lv >= Passives.MAX_LEVEL
	var lvbox := UiTheme.panel(UiTheme.box(Color(0, 0, 0, 0.25), 6, 1, Color("#5a4220"), 8))
	var lvv := UiTheme.vbox(4)
	lvbox.add_child(lvv)
	lvv.add_child(UiTheme.label("Cấp %d / %d" % [lv, Passives.MAX_LEVEL]))
	var bar := ProgressBar.new()
	bar.theme_type_variation = "PoiseBar"
	bar.max_value = Passives.MAX_LEVEL
	bar.value = lv
	bar.show_percentage = false
	bar.custom_minimum_size.y = 16
	lvv.add_child(bar)
	col.add_child(lvbox)
	var why := Passives.can_upgrade(p, id)
	var up := UiTheme.button(("+  Học" if lv == 0 else "+  Nâng cấp") if not maxed else "Đã đạt cấp tối đa", true)
	up.name = "PassiveUp_" + id
	up.custom_minimum_size.y = 48
	up.add_theme_font_size_override("font_size", UiTheme.fs(18))
	up.disabled = why != ""
	up.tooltip_text = why
	up.pressed.connect(func():
		world.passive_upgrade(id)
		refresh())
	col.add_child(up)
	return col
