extends RefCounted
## Dựng các màn hình toàn trang: tiêu đề, Lễ Thức Tỉnh, chiến thắng.

const Awakening = preload("res://scripts/core/awakening.gd")
const Explore = preload("res://scripts/core/explore.gd")
const Talents = preload("res://scripts/data/talents.gd")
const UiTheme = preload("res://scripts/ui/ui_theme.gd")
const Classes = preload("res://scripts/data/classes.gd")
const SpriteLib = preload("res://scripts/view/sprite_lib.gd")

const CONTROLS := [
	["W A S D", "Di chuyển"],
	["Chuột", "Ngắm hướng đánh"],
	["Chuột trái / J", "Đánh thường (giữ để đánh liên tục)"],
	["1 · 2 · 3 · 4", "4 kỹ năng của lớp (tốn MP); K / chuột phải = kỹ năng 1"],
	["Space", "Né lăn — bất tử 0,3 giây"],
	["L", "Kỹ năng Thiên phú (nếu có)"],
	["Q", "Uống bình máu"],
	["M · N · I · C · T", "Khai phá · Lục địa · Túi đồ · Chỉ số · Thiên phú"],
	["E · Z", "Cửa hàng (ở làng) · Tự đánh"],
]


## C1-13: lục địa Huyền Thổ vỡ 9 mảnh quanh lõi Hư Vô; vùng 1 đã sáng, vùng 2 nhấp nháy.
class Continent:
	extends Control
	const NAMES := ["Rừng Sương", "Gió Hú", "Xích Sa", "U Minh", "Viêm Long", "Bắc Cực", "Thiên Không", "Vực Hư Vô", "Thiên Đạo"]
	const POS := [Vector2(-230, 40), Vector2(-120, 70), Vector2(0, 80), Vector2(120, 60), Vector2(230, 30),
		Vector2(170, -60), Vector2(40, -80), Vector2(-90, -60), Vector2(0, -10)]
	var t := 0.0

	func _process(delta: float) -> void:
		t = minf(t + delta, 99.0)
		queue_redraw()

	func _draw() -> void:
		var c := size / 2.0
		var font := UiTheme.font()
		for i in 9:
			var p: Vector2 = c + POS[i]
			var reveal := clampf(t * 1.5 - i * 0.15, 0.0, 1.0)
			var col := Color(0.18, 0.16, 0.26, 0.9 * reveal)
			if i == 0:
				col = Color(0.36, 0.82, 0.42, 0.9 * reveal)
			elif i == 1:
				col = Color(1.0, 0.8, 0.3, (0.5 + 0.4 * sin(t * 4.0)) * reveal)
			elif i == 8:
				col = Color(0.6, 0.4, 1.0, 0.5 * reveal)
			var r := 34.0 if i < 8 else 26.0
			var pts := PackedVector2Array()
			for k in 7:
				var a := TAU * k / 7.0 + i
				pts.append(p + Vector2.from_angle(a) * r * (0.8 + 0.25 * sin(i * 3.1 + k * 1.7)))
			draw_colored_polygon(pts, col)
			pts.append(pts[0])
			draw_polyline(pts, Color(0, 0, 0, 0.6 * reveal), 2.0, true)
			draw_string(font, p + Vector2(-50, r + 16), "%d. %s" % [i + 1, NAMES[i]], HORIZONTAL_ALIGNMENT_CENTER, 100, 12, Color(1, 1, 1, 0.8 * reveal))


## C1-15: Bia Đá Thiên Đạo phát sáng theo màu hạng (S trở lên có tia sáng).
class SteleGlow:
	extends Control
	var rank := ""
	var t := 0.0

	func _process(delta: float) -> void:
		t += delta
		queue_redraw()

	func _draw() -> void:
		var base := Vector2(size.x / 2.0, size.y - 20.0)
		var c := Talents.rank_color(rank) if rank != "" else Color(1.0, 0.86, 0.55)
		var strength := 0.25 if rank == "" else 0.45 + 0.1 * Talents.rank_index(rank)
		var pulse := 0.5 + 0.5 * sin(t * (2.0 + Talents.rank_index(rank) if rank != "" else 2.0))
		for i in 4:
			draw_circle(base + Vector2(0, -60), 30.0 + i * 16.0, Color(c, strength * (0.25 - i * 0.05) * (0.7 + 0.3 * pulse)))
		if rank != "" and Talents.rank_index(rank) >= Talents.rank_index("S"):
			for i in 10:
				var a := TAU * i / 10.0 + t * 0.6
				draw_line(base + Vector2(0, -60), base + Vector2(0, -60) + Vector2.from_angle(a) * (90.0 + 20.0 * pulse), Color(c, 0.35), 3.0, true)
		SpriteLib.draw_env(self, "stele", base, Color(1, 1, 1).lerp(c, 0.35 * strength + 0.1 * pulse), 2.0)


## Nền + cột nội dung căn giữa. Trả về [màn hình, cột].
static func _page(bg_alpha := 1.0, width := 640.0) -> Array:
	var screen := ColorRect.new()
	screen.color = Color(UiTheme.BG, bg_alpha)
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen.add_child(center)
	var col := UiTheme.vbox(14)
	col.custom_minimum_size.x = width
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_child(col)
	return [screen, col]


static func _centered(text: String, variation := "", wrap := 0.0) -> Label:
	var l := UiTheme.label(text, variation, wrap)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return l


static func _buttons(col: VBoxContainer) -> HBoxContainer:
	var row := UiTheme.hbox(12)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_child(row)
	return row


static func title(has_save: bool, on_new: Callable, on_continue: Callable, on_settings := Callable()) -> Control:
	var page := _page()
	var col: VBoxContainer = page[1]
	col.add_child(_centered("MISTBREAKER: CELESTIAL GENESIS", "Eyebrow"))
	col.add_child(_centered("Thiên Phú Khai Giới", "Title"))
	col.add_child(_centered("Nhận Thiên phú từ Bia Đá, đánh quái lên cấp, xua tan sương mù Hư Vô và hạ Sói Chúa.", "Muted", 560))
	var row := _buttons(col)
	var b_new := UiTheme.button("Hành trình mới", true)
	b_new.name = "NewButton"
	b_new.pressed.connect(on_new)
	row.add_child(b_new)
	var b_cont := UiTheme.button("Tiếp tục")
	b_cont.name = "ContinueButton"
	b_cont.disabled = not has_save
	b_cont.pressed.connect(on_continue)
	row.add_child(b_cont)
	if on_settings.is_valid():
		var b_set := UiTheme.button("Cài đặt")
		b_set.name = "SettingsButton"
		b_set.pressed.connect(on_settings)
		row.add_child(b_set)
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 24)
	grid.add_theme_constant_override("v_separation", 6)
	grid.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	for c in CONTROLS:
		var k := UiTheme.label(c[0])
		k.add_theme_font_override("font", UiTheme.bold_font())
		grid.add_child(k)
		grid.add_child(UiTheme.label(c[1], "Muted"))
	col.add_child(grid)
	return page[0]


## Lễ Thức Tỉnh. on_accept nhận id Thiên phú đã chọn.
static func awakening(rng: Callable, on_accept: Callable, player_name := "") -> Control:
	var page := _page()
	var screen: Control = page[0]
	var col: VBoxContainer = page[1]
	var state := {"aw": Awakening.new(rng), "selected": -1, "rolling": null}

	col.add_child(_centered("LỄ THỨC TỈNH · LÀNG THANH THẠCH", "Eyebrow"))
	var heading := _centered("Bia Đá Thiên Đạo", "Heading")
	heading.add_theme_font_size_override("font_size", 34)
	col.add_child(heading)
	var speech := _centered("Trưởng làng Thạch Lão: “%sĐặt tay lên Bia Đá, để Thiên Đạo phán xét con.”" % (player_name + ", " if player_name != "" else ""))
	speech.add_theme_color_override("font_color", Color("#e4d4ae"))
	col.add_child(speech)

	var card_holder := CenterContainer.new()
	col.add_child(card_holder)
	var history := HFlowContainer.new()
	history.alignment = FlowContainer.ALIGNMENT_CENTER
	col.add_child(history)
	var row := _buttons(col)
	var b_roll := UiTheme.button("Chạm Bia Đá", true)
	b_roll.name = "RollButton"
	row.add_child(b_roll)
	var b_accept := UiTheme.button("Nhận Thiên phú này")
	b_accept.name = "AcceptButton"
	row.add_child(b_accept)

	# TL-03: tỉ lệ theo hạng.
	var rates := PackedStringArray()
	for r in Talents.RANK_ORDER:
		rates.append("%s %s%%" % [r, str(Talents.RANK_WEIGHT[r])])
	col.add_child(_centered(
		"Có thể chọn lại bất kỳ lần quay nào. Bảo hiểm: nếu cả 4 lần đều dưới hạng B, lần cuối được nâng lên hạng B.\nTỉ lệ theo hạng: %s. Bể quay gồm 20 Thiên phú. Mọi Thiên phú đều dùng được với cả hai lớp." % " · ".join(rates),
		"Small", 600
	))

	var render := func() -> void:
		var aw = state.aw
		for holder in [card_holder, history]:
			for old in holder.get_children():
				holder.remove_child(old)
				old.queue_free()
		var shown = state.rolling if state.rolling != null else (aw.rolls[state.selected] if state.selected >= 0 else null)
		# C1-15 (TP-04): Bia Đá toả sáng theo màu hạng vừa quay.
		var pair := UiTheme.hbox(24)
		var stele := SteleGlow.new()
		stele.custom_minimum_size = Vector2(140, 230)
		stele.rank = "" if shown == null or state.rolling != null else str(shown.rank)
		pair.add_child(stele)
		pair.add_child(_card(shown, state.rolling != null))
		card_holder.add_child(pair)
		for i in aw.rolls.size():
			var t: Dictionary = aw.rolls[i]
			var chip := UiTheme.button("Lần %d: %s · %s" % [i + 1, t.rank, t.name])
			var c := Talents.rank_color(t.rank)
			chip.add_theme_stylebox_override("normal", UiTheme.box(Color(c, 0.25 if i == state.selected else 0.04), 999, 1, c, 8))
			chip.add_theme_stylebox_override("hover", UiTheme.box(Color(c, 0.3), 999, 1, c, 8))
			var idx: int = i
			chip.pressed.connect(func():
				state.selected = idx
				screen.get_meta("render").call())
			history.add_child(chip)
		var rolling: bool = state.rolling != null
		b_roll.text = "Chạm Bia Đá" if aw.rolls.is_empty() else "Quay lại (còn %d lần)" % aw.rerolls_left()
		b_roll.disabled = rolling or not aw.can_roll()
		b_accept.disabled = rolling or state.selected < 0
	screen.set_meta("render", render)

	b_roll.pressed.connect(func():
		var aw = state.aw
		if not aw.can_roll() or state.rolling != null:
			return
		var started := Time.get_ticks_msec()
		while Time.get_ticks_msec() - started < 1100:
			# Hiệu ứng quay chỉ lướt qua Thiên phú không ẩn (TL-03: SSS chỉ lộ khi trúng).
			var visible_pool: Array = Talents.LIST.filter(func(x): return not x.get("hidden", false))
			state.rolling = visible_pool[randi() % visible_pool.size()]
			render.call()
			await screen.get_tree().create_timer(0.08).timeout
		state.rolling = null
		aw.roll()
		state.selected = aw.rolls.size() - 1
		render.call())
	b_accept.pressed.connect(func():
		if state.selected >= 0:
			on_accept.call(state.aw.rolls[state.selected].id))
	render.call()
	return screen


## CL-01: chọn lớp sau Lễ Thức Tỉnh. on_choose nhận id lớp.
static func class_select(talent_name: String, on_choose: Callable) -> Control:
	var page := _page(1.0, 900.0)
	var col: VBoxContainer = page[1]
	col.add_child(_centered("TẠO NHÂN VẬT", "Eyebrow"))
	var heading := _centered("Chọn con đường của con", "Heading")
	heading.add_theme_font_size_override("font_size", 34)
	col.add_child(heading)
	col.add_child(_centered("Thiên phú: %s. Mọi Thiên phú đều dùng được với cả hai lớp." % talent_name, "Muted"))
	var row := UiTheme.hbox(20)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_child(row)
	for cid in Classes.ORDER:
		var c: Dictionary = Classes.DEFS[cid]
		var card := PanelContainer.new()
		card.custom_minimum_size = Vector2(420, 0)
		card.add_theme_stylebox_override("panel", UiTheme.box(UiTheme.PANEL_SOLID, 14, 2, UiTheme.LINE, 18))
		var v := UiTheme.vbox(8)
		card.add_child(v)
		var top := UiTheme.hbox(14)
		var portrait := _portrait(c.sprite)
		top.add_child(portrait)
		var head := UiTheme.vbox(2)
		head.add_child(UiTheme.label(c.name, "Heading"))
		head.add_child(UiTheme.label("%s · Chỉ số chính %s" % [c.role, c.main], "Small"))
		top.add_child(head)
		v.add_child(top)
		v.add_child(UiTheme.label(c.description, "Muted", 380))
		for i in 4:
			var sk: Dictionary = c.skills[i]
			var line := UiTheme.hbox(8)
			var ic := TextureRect.new()
			ic.texture = SpriteLib.icon("skill-" + str(sk.icon))
			ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			ic.custom_minimum_size = Vector2(32, 32)
			line.add_child(ic)
			line.add_child(UiTheme.label("%d · %s — %s" % [i + 1, sk.name, sk.text], "Small", 330))
			v.add_child(line)
		var b := UiTheme.button("Chọn %s" % c.name, cid == "kiem-khach")
		b.name = "Class_" + cid
		var id: String = cid
		b.pressed.connect(func(): on_choose.call(id))
		v.add_child(b)
		row.add_child(card)
	return page[0]


## Khung chân dung: frame đứng của sprite, phóng ×3.
static func _portrait(sprite_id: String) -> Control:
	var holder := TextureRect.new()
	holder.custom_minimum_size = Vector2(96, 96)
	holder.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	holder.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var s: Dictionary = SpriteLib.data().get("sprites", {}).get(sprite_id, {})
	if not s.is_empty():
		var at := AtlasTexture.new()
		at.atlas = SpriteLib.texture(s.path)
		at.region = Rect2(0, 0, float(s.w), float(s.h))
		holder.texture = at
	return holder


static func _card(t, spinning: bool) -> Control:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(340, 220)
	var v := UiTheme.vbox(6)
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	card.add_child(v)
	if t == null:
		card.add_theme_stylebox_override("panel", UiTheme.box(UiTheme.PANEL_SOLID, 14, 2, UiTheme.LINE, 18))
		var q := _centered("?", "Title")
		q.add_theme_color_override("font_color", UiTheme.MUTED)
		v.add_child(q)
		v.add_child(_centered("Bia Đá đang chờ bàn tay của con.", "Muted"))
		return card
	var c := Talents.rank_color(t.rank)
	card.add_theme_stylebox_override("panel", UiTheme.box(Color(c.darkened(0.82), 1.0), 14, 2, c, 18))
	var rank := _centered(t.rank, "Title")
	rank.add_theme_color_override("font_color", c)
	v.add_child(rank)
	var name_l := _centered(t.name, "Heading")
	v.add_child(name_l)
	var kind := ("Kỹ năng L: %s" % t.skill.name) if Talents.has_skill(t) else "Bị động"
	v.add_child(_centered("%s · %s" % [Talents.group_name(t), kind], "Small"))
	v.add_child(_centered("…" if spinning else t.description, "", 300))
	return card


static func victory(world, on_continue: Callable, on_title: Callable) -> Control:
	var page := _page(0.82)
	var col: VBoxContainer = page[1]
	var p = world.profile
	var t: Dictionary = world.talent()
	col.add_child(_centered("CHƯƠNG 1 HOÀN THÀNH", "Eyebrow"))
	var h := _centered("Sói Chúa Hư Vô đã ngã xuống", "Title")
	h.add_theme_font_size_override("font_size", 44)
	col.add_child(h)
	col.add_child(_centered("Ánh sáng từ Bia Đá lan tới tận hang sói. Phía đông, Đồng Bằng Gió Hú đang chờ… và Thiên phú trong %s khẽ rung động, như có một mảnh thứ hai đang thức giấc." % p.name, "Muted", 580))
	# C1-13 (TN-09): bản đồ lục địa hiện ra, vùng 1 sáng, vùng 2 nhấp nháy.
	var art := Continent.new()
	art.custom_minimum_size = Vector2(620, 290)
	art.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	col.add_child(art)
	col.add_child(_centered("Thời gian chơi %d phút  ·  Cấp %d  ·  Quái đã hạ %d  ·  Khai phá %d/%d  ·  Thiên phú %s · %s" % [
		roundi(p.play_seconds / 60.0), p.level, p.kills, Explore.owned_count(p.tiles), Explore.explore_total(p.tiles), t.rank, t.name
	], "", 600))
	col.add_child(_centered("Lõi Sương (cấp 7–10) đã mở — bấm Tiếp tục khám phá để xem bản đồ lục địa (phím N). Chương 2 — Đồng Bằng Gió Hú — đang được phát triển.", "Small", 580))
	var row := _buttons(col)
	var b1 := UiTheme.button("Tiếp tục khám phá", true)
	b1.pressed.connect(on_continue)
	row.add_child(b1)
	var b2 := UiTheme.button("Về màn hình chính")
	b2.pressed.connect(on_title)
	row.add_child(b2)
	return page[0]
