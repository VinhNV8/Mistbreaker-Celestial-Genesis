extends Control
## HUD khi đang chơi. Dựng bằng code; cập nhật mỗi khung hình từ GameWorld.

const Config = preload("res://scripts/core/config.gd")
const Minimap = preload("res://scripts/ui/minimap.gd")
const Explore = preload("res://scripts/core/explore.gd")
const Formulas = preload("res://scripts/core/formulas.gd")
const GameWorld = preload("res://scripts/core/game_world.gd")
const Talents = preload("res://scripts/data/talents.gd")
const UiTheme = preload("res://scripts/ui/ui_theme.gd")
const Monsters = preload("res://scripts/data/monsters.gd")
const SpriteLib = preload("res://scripts/view/sprite_lib.gd")
const Classes = preload("res://scripts/data/classes.gd")
const Story = preload("res://scripts/data/story.gd")
const QuestLog = preload("res://scripts/core/quest_log.gd")
const Resources = preload("res://scripts/data/resources.gd")
## C1-03: tài nguyên hiện trên HUD (icon + số, rê chuột xem chú thích).
const HUD_RESOURCES := ["gold", "wood", "torches", "stones", "essence", "ore", "iron", "crystal"]
## TB-11: Đá, Sắt chỉ hiện khi đã có.
const HUD_OPTIONAL := ["ore", "iron", "crystal"]
const Maps = preload("res://scripts/data/maps.gd")
const TargetFrame = preload("res://scripts/ui/target_frame.gd")
const SkillBar = preload("res://scripts/ui/skill_bar.gd")
const Chapters = preload("res://scripts/core/chapters.gd")
const CharFrame = preload("res://scripts/ui/char_frame.gd")
const AutoButton = preload("res://scripts/ui/auto_button.gd")
const QuestBox = preload("res://scripts/ui/quest_box.gd")
const LogBox = preload("res://scripts/ui/log_box.gd")
const Bronze = preload("res://scripts/ui/bronze.gd")
const ActionCluster = preload("res://scripts/ui/action_cluster.gd")
const PickupFeed = preload("res://scripts/ui/pickup_feed.gd")
const LowHpOverlay = preload("res://scripts/ui/low_hp_overlay.gd")
const ExpBar = preload("res://scripts/ui/exp_bar.gd")
const Skills2 = preload("res://scripts/core/skills2.gd")
## UI-20: nhật ký tối đa 5 dòng, mỗi dòng sống 6 giây rồi mờ dần.
## UI-54 (docs/38): nhật ký thu gọn — 3 dòng mới nhất (cũ: 5), tự mờ.
const LOG_MAX := 3
const LOG_LIFE := 6.0
## DH-11: thứ tự ô trên thanh kỹ năng.
## UI-10: thanh đã vẽ gọn (ô R 22, không tên) nên giữ tỉ lệ 1.
const SKILL_BAR_SCALE := 1.0
const SLOT_BASIC := 0
## SN12-02 (docs/31): ô kỹ năng 1–7 của bộ lắp ở chỉ số 1–7 trên thanh (7 = ô Tuyệt kỹ, phím G).
const SLOT_SKILL0 := 1
const SLOT_DODGE := 8
const SLOT_TALENT := 9
const SLOT_POTION := 10
## SN10-02: ô bình MP (phím F) ngay sau bình máu.
const SLOT_MP_POTION := 11
const BAR_COUNT := 12
## UI-16: bề rộng khung nhiệm vụ.
const OBJ_W := 240

var _tl: CharFrame
## UI-12: nút bật/tắt Tự đánh (main nối tín hiệu auto_toggled → world.toggle_auto()).
## UI-41: nằm trong cụm nút góc phải (ActionCluster) cùng nút Đánh, Né, Thiên phú, 2 bình thuốc.
var _cluster: ActionCluster
var _exp_bar: ExpBar
signal auto_toggled
## NV-A4 (docs/41): bấm khung nhiệm vụ → main tự chạy tới mục tiêu / mở bảng cần dùng.
signal quest_clicked
## NV-A4: bấm dòng việc đang ghim (uỷ thác / nhiệm vụ phụ) → main tự chạy tới mục tiêu của việc đó.
signal track_clicked(key: String)

var _tr: PanelContainer
var _resources: Label
var _res_labels := {}
var _res_slots: Array = []

var _obj: PanelContainer
var _objectives: Array[Label] = []
var _obj_progress: Control
## NV-A1: dòng chỉ đường "➜ 85 m · Cổng → …" dưới mục tiêu.
var _obj_guide: Label
## NV-A4: tối đa 2 dòng việc đang ghim dưới nhiệm vụ chính.
var _track_lines: Array[Label] = []

var _boss_box: VBoxContainer
var _boss_name: Label
var _boss_hp: ProgressBar
var _boss_poise: ProgressBar
## R1: đang thu gọn HUD bên phải vì có thanh máu boss.
var _boss_compact := false

var _combo: Label
## UI-52: dải nhặt đồ bên trái; UI-55: viền đỏ máu thấp.
var _feed: PickupFeed
var _low_hp: LowHpOverlay
var _wind: Label
## DH-11: ô 0 = đánh thường, 1–4 = kỹ năng lớp, 5 né, 6 Thiên phú (L), 7 bình máu, 8 bình MP (SN10-02).
var _skills: Control
## SN12-02: menu chọn nhanh kỹ năng cho một ô (chuột phải) — ô đang mở menu, danh sách id theo mục.
var _slot_popup: PopupMenu
var _menu_slot := -1
var _menu_ids: Array = []
var _world

var _log: VBoxContainer
var _banner: Label
var _banner_sub: Label
var _target: Control
var _dead: ColorRect
var _map_name: Label
var _obj_title: Label
var _travel: ColorRect
var _travel_label: Label
## M5-03: bản đồ nhỏ (phím V đổi cỡ).
var _minimap: Minimap


func _ready() -> void:
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	mouse_filter = MOUSE_FILTER_IGNORE

	# UI-55 (docs/38): viền đỏ máu thấp — dưới mọi thành phần HUD.
	_low_hp = LowHpOverlay.new()
	add_child(_low_hp)
	# UI-08 (Spec_Notes đợt 6): khung nhân vật kiểu khung vàng – ngọc tím (ui/char_frame.gd).
	_tl = CharFrame.new()
	add_child(_tl)

	_tr = PanelContainer.new()
	var trv := UiTheme.vbox(2)
	_resources = UiTheme.label("", "Small")
	var res_row := UiTheme.hbox(12)
	for rid in HUD_RESOURCES:
		var info := Resources.info(rid)
		var cell := UiTheme.hbox(4)
		cell.tooltip_text = "%s — %s" % [info.name, info.desc]
		var ic := TextureRect.new()
		ic.texture = SpriteLib.icon("res-" + str(info.icon))
		ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		ic.custom_minimum_size = Vector2(22, 22)
		cell.add_child(ic)
		var l := UiTheme.label("0")
		l.add_theme_font_override("font", UiTheme.bold_font())
		cell.add_child(l)
		_res_labels[rid] = l
		_res_slots.append(cell)
		res_row.add_child(cell)
	trv.add_child(res_row)
	trv.add_child(_resources)
	_tr.add_child(trv)
	add_child(_tr)
	# UI-56 (docs/38): dòng "vùng · cấp · khám phá" rời khỏi thanh tài nguyên (cho thanh gọn 1 hàng số), đặt dưới la bàn.
	_map_name = UiTheme.label("", "HudLabel")
	_map_name.add_theme_font_size_override("font_size", UiTheme.fs(13))
	_map_name.add_theme_color_override("font_color", Color("#e8dcc0"))
	_map_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_map_name)

	_minimap = Minimap.new()
	add_child(_minimap)

	# UI-16 (Spec_Notes đợt 7): khung nhiệm vụ gọn — nền mờ + vạch vàng bên trái (không khung gỗ), chữ nhỏ,
	# 3 dòng: mục tiêu (vàng, đậm) · gợi ý · thưởng; bỏ dòng phím tắt (chuyển vào Trợ giúp F1).
	# UI-16b (đợt 7): nền QuestBox cùng phong cách khung nhân vật; tiêu đề căn giữa + đường kẻ có ngọc.
	_obj = PanelContainer.new()
	_obj.custom_minimum_size.x = OBJ_W
	_obj.add_theme_stylebox_override("panel", QuestBox.new())
	var ov := UiTheme.vbox(3)
	_obj.add_child(ov)
	# UI-41 (docs/35 §11): cuộn giấy da — tiêu đề chữ cổ mực đỏ, nội dung mực nâu (không viền), thanh tiến độ "(a/b)".
	_obj_title = UiTheme.label("CHƯƠNG 1 · THỨC TỈNH", "HudLabel")
	_obj_title.add_theme_font_size_override("font_size", UiTheme.fs(15))
	_obj_title.add_theme_font_override("font", Bronze.title_font())
	_obj_title.add_theme_color_override("font_color", Bronze.INK_RED)
	_obj_title.add_theme_constant_override("outline_size", 0)
	_obj_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ov.add_child(_obj_title)
	ov.add_child(QuestBox.Divider.new())
	for i in 3:
		var l := UiTheme.label("", "HudLabel", OBJ_W - 46)
		l.add_theme_font_size_override("font_size", UiTheme.fs([13, 12, 11][i]))
		l.add_theme_constant_override("outline_size", 0)
		if i == 0:
			l.add_theme_font_override("font", UiTheme.bold_font())
		_objectives.append(l)
		ov.add_child(l)
		if i == 0:
			_obj_progress = QuestBox.Progress.new()
			_obj_progress.visible = false
			ov.add_child(_obj_progress)
	# NV-A1 / A4 (docs/41): dòng chỉ đường + bấm khung để tự chạy tới
	_obj_guide = UiTheme.label("", "HudLabel", OBJ_W - 46)
	_obj_guide.add_theme_font_size_override("font_size", UiTheme.fs(12))
	_obj_guide.add_theme_font_override("font", UiTheme.bold_font())
	_obj_guide.add_theme_constant_override("outline_size", 0)
	_obj_guide.add_theme_color_override("font_color", Bronze.INK_RED)
	_obj_guide.visible = false
	ov.add_child(_obj_guide)
	for i in 3:
		var tl := UiTheme.label("", "HudLabel", OBJ_W - 46)
		tl.add_theme_font_size_override("font_size", UiTheme.fs(11))
		tl.add_theme_constant_override("outline_size", 0)
		tl.add_theme_color_override("font_color", parchment_ink(UiTheme.TEXT))
		tl.visible = false
		tl.mouse_filter = Control.MOUSE_FILTER_STOP
		tl.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		tl.gui_input.connect(func(ev: InputEvent):
			if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT and tl.has_meta("key"):
				track_clicked.emit(str(tl.get_meta("key")))
				tl.accept_event())
		_track_lines.append(tl)
		ov.add_child(tl)
	_obj.mouse_filter = Control.MOUSE_FILTER_STOP
	_obj.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_obj.tooltip_text = "Bấm: tự chạy tới mục tiêu nhiệm vụ · O: Sổ nhiệm vụ"
	_obj.gui_input.connect(func(ev: InputEvent):
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
			quest_clicked.emit()
			_obj.accept_event())
	add_child(_obj)

	_boss_box = UiTheme.vbox(4)
	_boss_name = UiTheme.label("", "HudLabel")
	_boss_name.add_theme_font_override("font", UiTheme.bold_font())
	_boss_name.add_theme_font_size_override("font_size", 18)
	_boss_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_boss_box.add_child(_boss_name)
	_boss_hp = _bar("BossBar", 20)
	_boss_box.add_child(_boss_hp)
	_boss_poise = _bar("PoiseBar", 12)
	var poise_label := _bar_label(_boss_poise, 10)
	poise_label.text = "Phá Thế"
	_boss_box.add_child(_boss_poise)
	add_child(_boss_box)

	_wind = UiTheme.label("", "HudLabel")
	_wind.add_theme_font_override("font", UiTheme.bold_font())
	_wind.add_theme_font_size_override("font_size", 16)
	add_child(_wind)
	# SN9-09: khung mục tiêu (quái đang đánh / rê chuột)
	_target = TargetFrame.new()
	add_child(_target)
	_combo = UiTheme.label("", "HudLabel")
	_combo.add_theme_font_override("font", UiTheme.bold_font())
	# UI-54 (docs/38): dòng combo nhỏ lại, đặt sát trên cụm nút (thông tin phụ, không nặng hơn thanh máu).
	_combo.add_theme_font_size_override("font_size", UiTheme.fs(15))
	_combo.add_theme_color_override("font_color", UiTheme.GOLD)
	add_child(_combo)

	_skills = SkillBar.new()
	_skills.set_count(BAR_COUNT)
	# SN12-02: chuột phải ô kỹ năng → chọn nhanh; thả kỹ năng (kéo từ bảng Kỹ năng) vào ô.
	_skills.slot_menu.connect(_on_slot_menu)
	_skills.skill_dropped.connect(_on_skill_dropped)
	_skills.accept_drop = _accept_drop
	_slot_popup = PopupMenu.new()
	_slot_popup.name = "SlotMenu"
	_slot_popup.id_pressed.connect(_on_slot_pick)
	add_child(_slot_popup)
	# UI-07 / UI-10: thanh kỹ năng gọn (Spec_Notes đợt 4, 6).
	_skills.scale = Vector2.ONE * SKILL_BAR_SCALE
	add_child(_skills)

	_log = UiTheme.vbox(3)
	add_child(_log)
	_feed = PickupFeed.new()
	add_child(_feed)

	_banner = UiTheme.label("", "HudLabel")
	_banner.add_theme_font_override("font", UiTheme.bold_font())
	_banner.add_theme_font_size_override("font_size", 46)
	_banner.add_theme_color_override("font_color", UiTheme.GOLD)
	_banner.modulate.a = 0.0
	add_child(_banner)

	_dead = ColorRect.new()
	_dead.color = Color(0.12, 0.0, 0.0, 0.35)
	_dead.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	var dl := UiTheme.label("Bạn đã gục ngã…", "HudLabel")
	dl.add_theme_font_override("font", UiTheme.bold_font())
	dl.add_theme_font_size_override("font_size", 36)
	dl.add_theme_color_override("font_color", UiTheme.BAD)
	dl.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	dl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_dead.add_child(dl)
	add_child(_dead)

	# MP-03: màn hình đi đường
	_travel = ColorRect.new()
	_travel.color = Color(0.03, 0.04, 0.06, 0.92)
	_travel.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	_travel_label = UiTheme.label("", "HudLabel")
	_travel_label.add_theme_font_override("font", UiTheme.bold_font())
	_travel_label.add_theme_font_size_override("font_size", 30)
	_travel_label.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	_travel_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_travel_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_travel.add_child(_travel_label)
	add_child(_travel)

	# UI-41 (docs/35 §11): thanh EXP tím dưới đáy + cụm nút góc phải (bấm / chạm được).
	_exp_bar = ExpBar.new()
	add_child(_exp_bar)
	_cluster = ActionCluster.new()
	add_child(_cluster)

	_ignore_mouse(self)
	# Ô tài nguyên nhận chuột để hiện chú thích (C1-03).
	for cell in _res_slots:
		cell.mouse_filter = MOUSE_FILTER_PASS
	_cluster.mouse_filter = MOUSE_FILTER_STOP
	_cluster.auto_pressed.connect(func(): auto_toggled.emit())


func _ignore_mouse(node: Node) -> void:
	for c in node.get_children():
		if c is Control:
			(c as Control).mouse_filter = MOUSE_FILTER_IGNORE
		_ignore_mouse(c)


func _bar(variation: String, height: float) -> ProgressBar:
	var b := ProgressBar.new()
	b.theme_type_variation = variation
	b.min_value = 0.0
	b.max_value = 1.0
	b.step = 0.0
	b.show_percentage = false
	b.custom_minimum_size.y = height
	return b


func _bar_label(bar: ProgressBar, font_size: int) -> Label:
	var l := UiTheme.label("", "HudLabel")
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_constant_override("outline_size", 3)
	l.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	bar.add_child(l)
	return l


## UI-20: dòng nhật ký — dải nền mờ dần (LogBox), huy hiệu màu theo loại, chữ có viền; dòng mới trượt vào từ
## trái + hiện dần, dòng cũ mờ dần rồi biến mất. Phần số trong câu (+5, 10 phút…) tô đậm màu loại tin.
func log_message(text: String, tone := "info") -> void:
	var item := PanelContainer.new()
	item.add_theme_stylebox_override("panel", LogBox.new(tone))
	item.mouse_filter = MOUSE_FILTER_IGNORE
	var l := RichTextLabel.new()
	l.bbcode_enabled = true
	l.fit_content = true
	l.scroll_active = false
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size.x = 300
	l.mouse_filter = MOUSE_FILTER_IGNORE
	l.add_theme_font_override("normal_font", UiTheme.font())
	l.add_theme_font_override("bold_font", UiTheme.bold_font())
	l.add_theme_font_size_override("normal_font_size", UiTheme.fs(13))
	l.add_theme_font_size_override("bold_font_size", UiTheme.fs(13))
	l.add_theme_color_override("default_color", Color("#ece6d8"))
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	l.add_theme_constant_override("outline_size", 3)
	l.text = _log_bbcode(text, LogBox.color_of(tone))
	item.add_child(l)
	_log.add_child(item)
	while _log.get_child_count() > LOG_MAX:
		var old := _log.get_child(0)
		_log.remove_child(old)
		old.queue_free()
	item.modulate.a = 0.0
	var tw := item.create_tween()
	tw.tween_property(item, "modulate:a", 1.0, 0.18)
	tw.tween_interval(LOG_LIFE)
	tw.tween_property(item, "modulate:a", 0.0, 0.8)
	tw.tween_callback(item.queue_free)


## Tô đậm các cụm số ("+5", "10 phút", "+1 Tinh Kim"…) bằng màu loại tin; thoát ký tự [ ] của BBCode.
static func _log_bbcode(text: String, col: Color) -> String:
	var safe := text.replace("[", "[lb]")
	var re := RegEx.new()
	re.compile("[+−-]?[0-9][0-9.,]*%?")
	var out := ""
	var last := 0
	for m in re.search_all(safe):
		out += safe.substr(last, m.get_start() - last)
		out += "[b][color=#%s]%s[/color][/b]" % [col.to_html(false), _group_thousands(m.get_string())]
		last = m.get_end()
	return out + safe.substr(last)


## R1 (docs/19 RS-UI06): mọi số nguyên ≥ 5 chữ số trong câu có dấu chấm ngăn nghìn ("100000 EXP" → "100.000 EXP").
static func group_numbers(text: String) -> String:
	var re := RegEx.new()
	re.compile("(?<![0-9.,])[0-9]{5,}(?![0-9.,])")
	var out := ""
	var last := 0
	for m in re.search_all(text):
		out += text.substr(last, m.get_start() - last) + _group_thousands(m.get_string())
		last = m.get_end()
	return out + text.substr(last)


## "80000" → "80.000" (chỉ số nguyên ≥ 5 chữ số, có thể có dấu +/−).
static func _group_thousands(n: String) -> String:
	var sign := ""
	var digits := n
	if n.length() > 0 and not n[0].is_valid_int():
		sign = n[0]
		digits = n.substr(1)
	if digits.length() < 5 or not digits.is_valid_int():
		return n
	var out := ""
	for i in digits.length():
		if i > 0 and (digits.length() - i) % 3 == 0:
			out += "."
		out += digits[i]
	return sign + out


## sub: dòng phụ nhỏ dưới biểu ngữ (SN9-08: "HP +15 · Tấn công +2 …" khi lên cấp).
func banner(text: String, sub := "") -> void:
	_banner.text = text
	if _banner_sub == null:
		_banner_sub = UiTheme.label("", "")
		_banner_sub.add_theme_font_size_override("font_size", UiTheme.fs(16))
		_banner_sub.add_theme_color_override("font_color", Color("#f2d79a"))
		_banner_sub.add_theme_constant_override("outline_size", 4)
		_banner_sub.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
		_banner_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_banner_sub.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
		_banner_sub.grow_horizontal = Control.GROW_DIRECTION_BOTH
		_banner.add_child(_banner_sub)
	_banner_sub.text = sub
	var tw := _banner.create_tween()
	_banner.modulate.a = 0.0
	tw.tween_property(_banner, "modulate:a", 1.0, 0.25)
	tw.tween_interval(1.4)
	tw.tween_property(_banner, "modulate:a", 0.0, 0.6)


func toggle_minimap() -> void:
	_minimap.toggle_size()


func update_from(w: GameWorld) -> void:
	_minimap.update_from(w)
	var p = w.profile
	var pl := w.player
	var s := w.stats
	var t := w.talent()
	var rank_color := Talents.rank_color(t.rank)

	var form: Array = GameWorld.Ch7.form(t.id, int(p.evo))
	var need := Formulas.exp_to_next(p.level)
	var frame := {
		"name": p.name, "title": Classes.title(str(p.class_id), str(p.job), str(p.job2), str(p.job3)), "level": p.level, "class_id": p.class_id, "look": p.look, "time": w.time,
		"talent_name": "%s · %s" % [form[1], form[0]], "talent_icon": SpriteLib.talent_icon(t.id), "rank_color": rank_color,
		"hp": maxf(0.0, pl.hp) / float(s.max_hp), "hp_text": "%d / %d" % [ceili(maxf(0.0, pl.hp)), s.max_hp],
		"mp": maxf(0.0, pl.mp) / maxf(1.0, float(s.max_mp)), "mp_text": "%d / %d" % [floori(maxf(0.0, pl.mp)), s.max_mp],
		"exp": minf(1.0, float(p.xp) / need), "exp_text": "EXP %.1f%%" % (minf(1.0, float(p.xp) / need) * 100.0),
		"power": w.combat_power(), "points": p.unspent,
	}

	var torch_note := ""
	var torch_cap := Explore.torch_max(p)
	if p.torches < torch_cap:
		var left := maxi(0, ceili(Explore.torch_regen_sec(p) - p.torch_timer))
		torch_note = "  (+1 sau %d:%02d)" % [left / 60, left % 60]
	for i in HUD_RESOURCES.size():
		var rid: String = HUD_RESOURCES[i]
		_res_labels[rid].text = str(Resources.value(p, rid)) + ("/%d" % torch_cap if rid == "torches" else "")
		if rid in HUD_OPTIONAL:
			_res_slots[i].visible = Resources.value(p, rid) > 0
	# UI-07: bỏ dòng gợi ý cố định cho gọn; chỉ hiện khi Đuốc đang hồi.
	_resources.text = ("Đuốc hồi%s" % torch_note) if torch_note != "" else ""
	_resources.visible = _resources.text != ""

	_update_quest(w)
	_update_guide(w)
	_update_tracked(w)
	# M4.2 (GI-01): hướng gió + báo trước 2 giây.
	_wind.visible = w.wind_dir != Vector2.ZERO
	if _wind.visible:
		var txt := "Gió thổi %s%s" % [_arrow(w.wind_dir), " (mạnh ×2)" if w.wind_power() > 1.0 else ""]
		if w.wind_next != Vector2.ZERO:
			txt += "   ·   sắp đổi %s sau %.0f giây" % [_arrow(w.wind_next), ceilf(w.wind_timer)]
			_wind.add_theme_color_override("font_color", UiTheme.GOLD)
		else:
			_wind.add_theme_color_override("font_color", Color("#e8e2c8"))
		_wind.text = txt
	# M6+ (D38): trạng thái môi trường của chương (sa mạc, đầm lầy…) — dùng chung dòng của gió.
	var env := Chapters.env_text(w)
	if env != "":
		_wind.visible = true
		_wind.text = env
		var alert: bool = Chapters.env_alert(w)
		_wind.add_theme_color_override("font_color", Color("#ff9a3c") if alert else Color("#f2d79a"))

	_combo.visible = w.combo >= 5
	_combo.text = "×%d combo · +%d%% EXP" % [w.combo, roundi((Formulas.combo_exp_multiplier(w.combo) - 1.0) * 100.0)]
	_feed.update_from(w)
	_low_hp.update_hp(pl.hp, float(s.max_hp), get_process_delta_time())

	_update_skill_bar(w, t, rank_color)
	var extra: Array[String] = []
	if int(p.talent_level) > 1:
		extra.append("Thiên phú cấp %d%s" % [GameWorld.Ch4.stage_level(p), (" · tiến hoá %d" % int(p.evo)) if int(p.evo) > 0 else ""])
	if not w.allies.is_empty():
		extra.append("Đồng minh %d" % w.allies.size())
	# UI-13: hệ ngũ hành hiện bằng biểu tượng trên hoa sen Thiên phú (không ghi chữ).
	frame.element = str(p.element) if w.has_talent("ngu-hanh") else ""
	_cluster.auto_on = w.auto_fight
	_exp_bar.set_exp(minf(1.0, float(p.xp) / need), int(p.level), maxi(0, need - int(p.xp)), int(p.level) >= Config.MAX_LEVEL)
	frame.extra = " · ".join(extra)
	_tl.set_data(frame)
	_target.update_from(w)

	var boss := w.big_enemy()
	_boss_box.visible = boss != null
	if boss != null:
		var tags := (" · Giai đoạn 2" if boss.phase > 1 else "") + (" · CHOÁNG" if boss.broken else "")
		_boss_name.text = boss.name + tags
		_boss_hp.value = maxf(0.0, boss.hp) / boss.max_hp
		_boss_poise.value = boss.poise / boss.max_poise
	# R1 (docs/19 RS-UI02): đang đánh boss — khung nhiệm vụ thu về 1 dòng, bản đồ nhỏ mờ để không che đấu trường
	# (hang boss vùng 4–6 nằm phía đông map, đúng chỗ cột HUD bên phải).
	if boss != null:
		_objectives[1].visible = false
		_objectives[2].visible = false
	if _boss_compact != (boss != null):
		_boss_compact = boss != null
		_obj.modulate.a = 0.7 if _boss_compact else 1.0
		_minimap.modulate.a = 0.35 if _boss_compact else 1.0
		_obj.reset_size()
	_dead.visible = pl.dead_timer > 0.0 and w.travel_timer <= 0.0
	_travel.visible = w.travel_timer > 0.0
	if _travel.visible:
		var dest: Dictionary = Maps.get_map(w.travel_target)
		_travel_label.text = "Đang lên đường tới %s…\n%.1f giây" % [dest.name, w.travel_timer]
	var m: Dictionary = w.map
	_map_name.text = "%s · cấp %d–%d · Khám phá %d%%" % [m.name, m.levels[0], m.levels[1], floori(w.explore_ratio(w.map_id) * 100.0)]
	if w.in_cave():
		# HP (docs/15): hang không tính khai phá — hiện số quái còn lại / Chúa Hang.
		var left := w.enemies.filter(func(e): return not e.dead).size()
		var boss_alive := w.enemies.any(func(e): return e.cave_boss and not e.dead)
		var boss_name := "Chúa Cổng" if m.has("gate_rank") else "Chúa Hang"
		_map_name.text = "%s · cấp %d–%d · còn %d quái · %s" % [m.name, m.levels[0], m.levels[1], left, (boss_name + " đang chờ") if boss_alive else "đã dọn ✓"]
	if w.challenge_warning(w.map_id) != "":
		_map_name.text += " · Vượt ải: EXP ×2"
		_map_name.add_theme_color_override("font_color", UiTheme.BAD)
	else:
		_map_name.remove_theme_color_override("font_color")
	_layout()


func _update_skill_bar(w: GameWorld, t: Dictionary, rank_color: Color) -> void:
	var pl := w.player
	var p = w.profile
	var c: Dictionary = Classes.get_class_def(p.class_id)
	_world = w
	# UI-41: Đánh, Né, Thiên phú, 2 bình chuyển sang cụm nút góc phải — ô trên thanh ẩn (giữ chỉ số ô cho code cũ).
	var basic := {"key": "J", "name": c.basic.name, "icon": SpriteLib.icon("skill-" + str(c.basic.icon)), "act": "act-" + str(c.basic.icon)}
	_cluster.set_button("attack", basic)
	_skills.set_slot(SLOT_BASIC, {"hidden": true, "key": "J", "name": c.basic.name})
	for i in Classes.SKILL_SLOTS:
		# SK1: ô kỹ năng theo bộ lắp; chưa mở thì mờ + ghi cấp mở. SN12-02: ô 5, 6, G chưa mở thì ẩn; đã mở mà trống thì "+".
		var key: String = Classes.SLOT_KEYS[i]
		var big: bool = i == Classes.SLOT_ULT
		if not w.slot_open(i):
			_skills.set_slot(SLOT_SKILL0 + i, {"hidden": true, "key": key})
			continue
		var sk: Dictionary = w.slot_skill(i)
		if sk.is_empty():
			_skills.set_slot(SLOT_SKILL0 + i, {"empty": true, "key": key, "name": "", "big": big})
			continue
		var cd_left: float = pl.skill_cds[i]
		var mp := int(w.skill_mp(i))
		var locked: bool = not w.skill_unlocked(sk)
		var low := pl.mp < mp
		var lv: int = w.skill_level(str(sk.id))
		# UI-10: cấp kỹ năng ở huy hiệu, ô khoá ghi cấp mở; thiếu MP thì ô ngả xanh (dim).
		_skills.set_slot(SLOT_SKILL0 + i, {"key": key, "name": sk.name, "icon": SpriteLib.icon("skill-" + str(sk.icon)),
			"cd": 0.0 if locked else cd_left / maxf(0.1, w.skill_cd_of(i)), "cd_text": "" if locked else (str(ceili(cd_left)) if cd_left > 0.0 else ""),
			"badge": str(lv) if lv > 1 and not locked else "", "lock": ("Cấp %d" % int(sk.unlock)) if locked else "",
			"dim": low or locked, "big": big, "ring": skill_ring(w, str(sk.id), big), "el": Skills2.element_of(w, str(sk.id))})
	var dodge := {"key": "Space", "name": "Né lăn", "icon": SpriteLib.icon("skill-dodge"),
		"cd": pl.dodge_cd / GameWorld.DODGE_CD, "cd_text": ("%.1f" % pl.dodge_cd) if pl.dodge_cd > 0.0 else ""}
	_cluster.set_button("dodge", dodge)
	_skills.set_slot(SLOT_DODGE, {"hidden": true, "key": "Space", "name": "Né lăn"})
	# TP5-05 (docs/33): ô L theo Thiên phú có kỹ năng (chính, hoặc phụ khi chính bị động).
	var lt: Dictionary = w.skill_talent()
	if lt.id != t.id:
		t = lt
		rank_color = Talents.rank_color(lt.rank)
	var tal := {"key": "L", "icon": SpriteLib.talent_icon(t.id), "ring": rank_color}
	if Talents.has_skill(t):
		tal.name = w.talent_skill_name()
		tal.cd = pl.talent_cd / maxf(0.1, w.talent_skill_cd())
		tal.cd_text = str(ceili(pl.talent_cd)) if pl.talent_cd > 0.0 else ""
	else:
		tal.name = t.name
	_cluster.set_button("talent", tal)
	_skills.set_slot(SLOT_TALENT, {"hidden": true, "key": "L", "name": tal.name})
	var pot := {"key": "Q", "name": "Bình máu", "icon": SpriteLib.icon("skill-potion")}
	pot.badge = str(p.potions)
	pot.cd = pl.potion_cd / GameWorld.POTION_CD
	pot.cd_text = str(ceili(pl.potion_cd)) if pl.potion_cd > 0.0 else ""
	pot.dim = p.potions <= 0
	# UI-55: máu thấp + còn bình → viền bình máu đỏ (gợi ý bấm Q)
	if p.potions > 0 and pl.potion_cd <= 0.0 and LowHpOverlay.level_of(pl.hp, float(w.stats.max_hp)) > 0.0:
		pot.ring = Color("#ff5470")
	_cluster.set_button("potion", pot)
	_skills.set_slot(SLOT_POTION, {"hidden": true, "key": "Q", "name": "Bình máu"})
	_cluster.set_button("mp_potion", {"key": "F", "name": "Bình MP", "icon": SpriteLib.icon("skill-mp_potion"),
		"badge": str(int(p.mp_potions)), "cd": pl.mp_potion_cd / GameWorld.MP_POTION_CD,
		"cd_text": str(ceili(pl.mp_potion_cd)) if pl.mp_potion_cd > 0.0 else "", "dim": int(p.mp_potions) <= 0})
	_skills.set_slot(SLOT_MP_POTION, {"hidden": true, "key": "F", "name": "Bình MP"})


## UI-41: viền ô kỹ năng theo hệ (biến thể ✦ đã chọn hệ) — chưa có hệ: đồng; Tuyệt kỹ: vàng.
static func skill_ring(w: GameWorld, id: String, big: bool) -> Color:
	var el := Skills2.element_of(w, id)
	if el != "" and Monsters.ELEMENT_HEX.has(el):
		return Color(Monsters.ELEMENT_HEX[el])
	return Color("#f3d27a") if big else Bronze.BR_MID


## SN12-02: ô trên thanh (chỉ số thanh) → ô bộ lắp (0–6), -1 nếu không phải ô kỹ năng.
static func loadout_slot(bar_index: int) -> int:
	var i := bar_index - SLOT_SKILL0
	return i if i >= 0 and i < Classes.SKILL_SLOTS else -1


func _accept_drop(bar_index: int, data: Dictionary) -> bool:
	var i := loadout_slot(bar_index)
	if i < 0 or _world == null:
		return false
	var sk: Dictionary = Classes.skill_by_id(str(_world.profile.class_id), str(data.get("skill_id", "")))
	return not sk.is_empty() and _world.skill_unlocked(sk) and _world.slot_accepts(i, sk)


func _on_skill_dropped(bar_index: int, id: String) -> void:
	var i := loadout_slot(bar_index)
	if i >= 0 and _world != null:
		_world.set_slot(i, id, true)  # kéo từ cây kỹ năng — bảng U đang mở (SN14-02)


## Chuột phải ô kỹ năng: danh sách kỹ năng đã mở lắp được vào ô đó (đang lắp ở ô khác thì 2 ô đổi chỗ) + "Bỏ trống ô".
func _on_slot_menu(bar_index: int, at: Vector2) -> void:
	var i := loadout_slot(bar_index)
	if i < 0 or _world == null:
		return
	_slot_popup.clear()
	_menu_slot = i
	_menu_ids = []
	var lo: Array = _world.profile.loadout
	for sk in Classes.skills_of(str(_world.profile.class_id)):
		if not _world.skill_unlocked(sk) or not _world.slot_accepts(i, sk):
			continue
		var at_slot: int = lo.find(str(sk.id))
		var label := str(sk.name) + (("  (ô %s)" % Classes.SLOT_KEYS[at_slot]) if at_slot >= 0 else "")
		_slot_popup.add_icon_item(SpriteLib.icon("skill-" + str(sk.icon)), label, _menu_ids.size())
		if at_slot == i:
			_slot_popup.set_item_disabled(_menu_ids.size(), true)
		_menu_ids.append(str(sk.id))
	_slot_popup.add_separator()
	_slot_popup.add_item("Bỏ trống ô %s" % Classes.SLOT_KEYS[i], _menu_ids.size())
	_menu_ids.append("")
	_slot_popup.reset_size()
	_slot_popup.position = Vector2i(at) - Vector2i(0, int(_slot_popup.size.y) + 8)
	_slot_popup.popup()


func _on_slot_pick(idx: int) -> void:
	if _world == null or idx < 0 or idx >= _menu_ids.size():
		return
	_world.set_slot(_menu_slot, str(_menu_ids[idx]))


## C1-12: bảng nhiệm vụ chương 1 (thay 3 mục tiêu cũ).
static func _arrow(d: Vector2) -> String:
	var arrows := ["về Đông", "về Đông Nam", "về Nam", "về Tây Nam", "về Tây", "về Tây Bắc", "về Bắc", "về Đông Bắc"]
	return arrows[posmod(roundi(d.angle() / (PI / 4.0)), 8)]


func _update_quest(w: GameWorld) -> void:
	var p = w.profile
	var q := w.quest()
	# M4.3: nhiệm vụ chính chương 2 khi đã tới vùng 2 (hoặc chương 1 đã xong).
	# M6+ (D38): nhiệm vụ chương 3 trở đi do module chương cung cấp.
	var qh := Chapters.quest_hud(w)
	if not qh.is_empty():
		_obj_title.text = str(qh.title)
		var colors := {"gold": UiTheme.GOLD, "text": UiTheme.TEXT, "muted": UiTheme.MUTED}
		for i in 3:
			var ln: Array = qh.lines[i] if i < qh.lines.size() else ["", "muted"]
			_set_obj(i, str(ln[0]), colors.get(ln[1], UiTheme.TEXT))
		return
	var q2 := w.quest2()
	if not q2.is_empty() and (q.is_empty() or int(w.map.get("region", 1)) == 2):
		_obj_title.text = "CHƯƠNG 2 · NHIỆM VỤ %d/%d · Hạng %s" % [int(p.quest.ch2), Story.QUESTS2.size(), w.alliance_rank()]
		var st2 := w.quest2_status()
		_set_obj(0, "◆ " + str(q2.title) + ("  (%d/%d)" % st2 if int(st2[1]) > 1 else ""), UiTheme.GOLD)
		_set_obj(1, str(q2.hint), UiTheme.TEXT)
		var rt2 := Story.reward_text(q2.reward)
		_set_obj(2, ("Thưởng: " + rt2) if rt2 != "" else "", UiTheme.MUTED)
		return
	if q.is_empty() and int(p.quest.ch2) >= Story.DONE2:
		_obj_title.text = "CHƯƠNG 2 · HOÀN THÀNH ✓"
		_set_obj(0, "Hạng Liên minh: %s (Bạc 10 ô, Vàng 25 ô vùng 2)" % w.alliance_rank(), UiTheme.TEXT)
		_set_obj(1, "Săn boss hiếm Bạch Hổ Phong Vân ở Mắt Bão — xuất hiện 2 lần mỗi ngày", UiTheme.MUTED)
		_set_obj(2, "Chương 3: Sa Mạc Xích Sa — hạ Huyền Ảnh, Lực chiến 5.000, cấp 18 (phím N)", UiTheme.MUTED)
		return
	if q.is_empty():
		_obj_title.text = "CHƯƠNG 1 · HOÀN THÀNH ✓"
		_set_obj(0, "Luyện cấp ở Lõi Sương (bản đồ lục địa, phím N)", UiTheme.TEXT)
		_set_obj(1, "Săn boss hiếm Lão Thụ Sương Mù — xuất hiện 2 lần mỗi ngày", UiTheme.MUTED)
		_set_obj(2, "Chương 2: Đồng Bằng Gió Hú — cấp 10 + khai phá 60% vùng 1, đi bằng phím N", UiTheme.MUTED)
		return
	_obj_title.text = "CHƯƠNG 1 · NHIỆM VỤ %d/%d" % [p.quest_step, Story.QUESTS.size()]
	var st := w.quest_status()
	var prog := "  (%d/%d)" % st if int(st[1]) > 1 else ""
	_set_obj(0, "◆ " + str(q.title) + prog, UiTheme.GOLD)
	_set_obj(1, str(q.hint), UiTheme.TEXT)
	var rt := Story.reward_text(q.reward)
	_set_obj(2, ("Thưởng: " + rt) if rt != "" else "", UiTheme.MUTED)


## NV-A1 (docs/41): "➜ 85 m · Bãi quái" / "➜ 1.240 m · Cổng → Mắt Bão" / "➜ Mở Bản đồ khai phá (M)".
func _update_guide(w: GameWorld) -> void:
	var txt := group_numbers(QuestLog.guide_text(w))
	_obj_guide.text = txt
	_obj_guide.visible = txt != ""


## NV-A4: "◇ Săn 15 Sói Sương 7/15 · 85 m" (xong: "✓ … — về khu an toàn nhận thưởng").
func _update_tracked(w: GameWorld) -> void:
	var tr := QuestLog.tracked(w)
	for i in _track_lines.size():
		var l := _track_lines[i]
		l.visible = i < tr.size()
		if not l.visible:
			continue
		var e: Dictionary = tr[i]
		l.set_meta("key", e.key)
		var txt := ""
		if bool(e.done):
			txt = "✓ %s — về khu an toàn nhận thưởng" % e.title
		else:
			txt = ("%s" % e.title) if str(e.key) == "road" else "◇ %s  %d/%d" % [e.title, int(e.n), int(e.need)]
			var r: Dictionary = e.route
			if r.pos != Vector2.INF:
				txt += " · %d m" % QuestLog.meters(w.player.pos, r.pos)
		l.text = group_numbers(txt)


func _set_obj(i: int, text: String, color: Color) -> void:
	# UI-16: tiêu đề gọn ("CHƯƠNG 2 · NHIỆM VỤ 1/5" → "CHƯƠNG 2 · 1/5"); thưởng nhạt hơn
	_obj_title.text = _obj_title.text.replace("NHIỆM VỤ ", "")
	text = group_numbers(text)
	_objectives[i].text = text
	_objectives[i].visible = text != ""
	_objectives[i].add_theme_color_override("font_color", parchment_ink(color))
	if i == 0:
		# UI-41: "(a/b)" ở mục tiêu → thanh tiến độ
		var m := RegEx.create_from_string("[(]([0-9]+)/([0-9]+)[)]").search(text)
		_obj_progress.visible = m != null and int(m.get_string(2)) > 1
		if _obj_progress.visible:
			_obj_progress.frac = float(m.get_string(1)) / float(m.get_string(2))
			_obj_progress.text = "%s/%s" % [m.get_string(1), m.get_string(2)]
			_obj_progress.queue_redraw()


## UI-41: màu chữ HUD (vàng / thường / nhạt / tốt / xấu) → mực tương ứng trên giấy da.
static func parchment_ink(c: Color) -> Color:
	if c == UiTheme.GOLD:
		return Bronze.INK_RED
	if c == UiTheme.MUTED:
		return Color("#6a5232")
	if c == UiTheme.GOOD:
		return Color("#2f6a24")
	if c == UiTheme.BAD:
		return Color("#9a1c14")
	return Bronze.INK


func _objective(i: int, done: bool, text: String) -> void:
	_objectives[i].text = ("✓ " if done else "○ ") + text
	_objectives[i].add_theme_color_override("font_color", parchment_ink(UiTheme.GOOD if done else UiTheme.MUTED))


func _layout() -> void:
	var sz := size
	# Spec_Notes đợt 4 (UI-07): tài nguyên giữa cạnh trên; bản đồ nhỏ góc phải trên, nhiệm vụ ngay dưới.
	_tl.position = Vector2(12, 12)
	_tr.reset_size()
	_tr.position = Vector2((sz.x - _tr.size.x) / 2.0, 8)
	_minimap.position = Vector2(sz.x - _minimap.size.x - 12, 12)
	_map_name.reset_size()
	_map_name.position = Vector2(minf(_minimap.position.x + (_minimap.size.x - _map_name.size.x) / 2.0, sz.x - _map_name.size.x - 8.0),
		_minimap.position.y + _minimap.size.y + 2.0)
	_obj.reset_size()
	_obj.position = Vector2(sz.x - _obj.size.x - 12, _map_name.position.y + (_map_name.size.y if _map_name.visible and _map_name.text != "" else 0.0) + 6.0)
	var boss_w := clampf(sz.x - 680.0, 260.0, 520.0)
	_boss_box.size = Vector2(boss_w, 0)
	_boss_box.position = Vector2((sz.x - boss_w) / 2.0, _tr.position.y + _tr.size.y + 6)
	_wind.reset_size()
	var wind_y := _tr.position.y + _tr.size.y + 6
	if _boss_box.visible:
		_boss_box.reset_size()
		_boss_box.size.x = boss_w
		_boss_box.position.x = (sz.x - boss_w) / 2.0
		wind_y = _boss_box.position.y + _boss_box.size.y + 4
	_wind.position = Vector2((sz.x - _wind.size.x) / 2.0, wind_y)
	# SN9-09: khung mục tiêu ngay dưới dòng môi trường / thanh boss
	var target_y := wind_y + (_wind.size.y + 4.0 if _wind.visible else 0.0)
	_target.position = Vector2((sz.x - _target.size.x) / 2.0, target_y)
	_combo.reset_size()
	# UI-41: thanh EXP sát đáy, thanh kỹ năng ngay trên, cụm nút góc phải dưới
	# 03/11: đầu rồng phải của thanh EXP (nhô ~26 px ngoài khung) không được chạm cụm nút (bình máu Q) — rút ngắn thanh.
	_cluster.position = sz - _cluster.size - Vector2(6, 4)
	var exp_right := _cluster.position.x + _cluster.left_edge() - ExpBar.DRAGON_OUT - 8.0
	var exp_w := minf(clampf(sz.x * 0.6, 460.0, 1000.0), maxf(320.0, 2.0 * (exp_right - sz.x / 2.0)))
	_exp_bar.size = Vector2(exp_w, ExpBar.H + 8.0)
	_exp_bar.position = Vector2((sz.x - exp_w) / 2.0, sz.y - _exp_bar.size.y - 4.0)
	var sk_size: Vector2 = _skills.custom_minimum_size * _skills.scale
	_skills.position = Vector2((sz.x - sk_size.x) / 2.0, _exp_bar.position.y - sk_size.y - 4.0)
	# UI-02: nhật ký nằm trên thanh kỹ năng.
	_log.reset_size()
	_log.position = Vector2(12, _skills.position.y - _log.size.y - 12)
	# dải nhặt đồ ngay trên vùng nhật ký: chỗ cố định cho 3 dòng ngắn, nhật ký cao hơn (dòng xuống hàng) thì đẩy lên
	_feed.position = Vector2(12, minf(_log.position.y, _skills.position.y - 12.0 - LOG_MAX * 34.0) - _feed.size.y - 6.0)
	_combo.position = Vector2(sz.x - _combo.size.x - 16, _cluster.position.y - _combo.size.y - 2.0)
	_banner.reset_size()
	_banner.position = Vector2((sz.x - _banner.size.x) / 2.0, sz.y * 0.28)
