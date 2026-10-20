extends Control
## HUD khi đang chơi. Dựng bằng code; cập nhật mỗi khung hình từ GameWorld.

const Config = preload("res://scripts/core/config.gd")
const Explore = preload("res://scripts/core/explore.gd")
const Formulas = preload("res://scripts/core/formulas.gd")
const GameWorld = preload("res://scripts/core/game_world.gd")
const Talents = preload("res://scripts/data/talents.gd")
const UiTheme = preload("res://scripts/ui/ui_theme.gd")
const Monsters = preload("res://scripts/data/monsters.gd")
const SpriteLib = preload("res://scripts/view/sprite_lib.gd")
const Classes = preload("res://scripts/data/classes.gd")
const Story = preload("res://scripts/data/story.gd")
const Resources = preload("res://scripts/data/resources.gd")
## C1-03: tài nguyên hiện trên HUD (icon + số, rê chuột xem chú thích).
const HUD_RESOURCES := ["gold", "wood", "torches", "stones", "essence", "ore", "iron"]
## TB-11: Đá, Sắt chỉ hiện khi đã có.
const HUD_OPTIONAL := ["ore", "iron"]
const Maps = preload("res://scripts/data/maps.gd")
const SkillBar = preload("res://scripts/ui/skill_bar.gd")
## DH-11: thứ tự ô trên thanh kỹ năng.
const SLOT_BASIC := 0
const SLOT_DODGE := 5
const SLOT_TALENT := 6
const SLOT_POTION := 7

var _tl: PanelContainer
var _level: Label
var _talent: Label
var _hp_bar: ProgressBar
var _hp_text: Label
var _mp_bar: ProgressBar
var _mp_text: Label
var _exp_bar: ProgressBar
var _exp_text: Label
var _points: Label
var _power: Label

var _tr: PanelContainer
var _resources: Label
var _res_labels := {}
var _res_slots: Array = []

var _obj: PanelContainer
var _objectives: Array[Label] = []

var _boss_box: VBoxContainer
var _boss_name: Label
var _boss_hp: ProgressBar
var _boss_poise: ProgressBar

var _combo: Label
var _wind: Label
## DH-11: ô 0 = đánh thường, 1–4 = kỹ năng lớp, 5 né, 6 Thiên phú (L), 7 bình máu.
var _skills: Control
var _extra: Label

var _log: VBoxContainer
var _banner: Label
var _dead: ColorRect
var _map_name: Label
var _obj_title: Label
var _travel: ColorRect
var _travel_label: Label


func _ready() -> void:
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	mouse_filter = MOUSE_FILTER_IGNORE

	_tl = PanelContainer.new()
	_tl.custom_minimum_size.x = 290
	var v := UiTheme.vbox(6)
	_tl.add_child(v)
	var row := UiTheme.hbox()
	_level = UiTheme.label("", "Heading")
	_talent = UiTheme.label("")
	row.add_child(_level)
	row.add_child(UiTheme.spacer())
	row.add_child(_talent)
	v.add_child(row)
	_hp_bar = _bar("HpBar", 20)
	_hp_text = _bar_label(_hp_bar, 12)
	v.add_child(_hp_bar)
	_mp_bar = _bar("MpBar", 12)
	_mp_text = _bar_label(_mp_bar, 10)
	v.add_child(_mp_bar)
	_exp_bar = _bar("ExpBar", 14)
	_exp_text = _bar_label(_exp_bar, 11)
	v.add_child(_exp_bar)
	_power = UiTheme.label("", "Small")
	v.add_child(_power)
	_extra = UiTheme.label("", "Small")
	v.add_child(_extra)
	_points = UiTheme.label("")
	_points.add_theme_color_override("font_color", UiTheme.GOLD)
	_points.add_theme_font_size_override("font_size", 13)
	v.add_child(_points)
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
		ic.custom_minimum_size = Vector2(26, 26)
		cell.add_child(ic)
		var l := UiTheme.label("0")
		l.add_theme_font_override("font", UiTheme.bold_font())
		cell.add_child(l)
		_res_labels[rid] = l
		_res_slots.append(cell)
		res_row.add_child(cell)
	trv.add_child(res_row)
	trv.add_child(_resources)
	_map_name = UiTheme.label("", "Small")
	trv.add_child(_map_name)
	_tr.add_child(trv)
	add_child(_tr)

	_obj = PanelContainer.new()
	_obj.custom_minimum_size.x = 290
	var ov := UiTheme.vbox(4)
	_obj.add_child(ov)
	_obj_title = UiTheme.label("CHƯƠNG 1 · THỨC TỈNH", "Eyebrow")
	ov.add_child(_obj_title)
	for i in 3:
		var l := UiTheme.label("", "", 266)
		l.add_theme_font_size_override("font_size", 14)
		_objectives.append(l)
		ov.add_child(l)
	ov.add_child(UiTheme.label("M: Khai phá · N: Lục địa · I: Túi đồ · C: Chỉ số · T: Thiên phú", "Small", 266))
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
	_combo = UiTheme.label("", "HudLabel")
	_combo.add_theme_font_override("font", UiTheme.bold_font())
	_combo.add_theme_font_size_override("font_size", 24)
	_combo.add_theme_color_override("font_color", UiTheme.GOLD)
	add_child(_combo)

	_skills = SkillBar.new()
	_skills.set_count(8)
	add_child(_skills)

	_log = UiTheme.vbox(4)
	add_child(_log)

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

	_ignore_mouse(self)
	# Ô tài nguyên nhận chuột để hiện chú thích (C1-03).
	for cell in _res_slots:
		cell.mouse_filter = MOUSE_FILTER_PASS


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


func log_message(text: String, tone := "info") -> void:
	var item := PanelContainer.new()
	item.theme_type_variation = {"good": "LogGood", "bad": "LogBad"}.get(tone, "LogInfo")
	item.mouse_filter = MOUSE_FILTER_IGNORE
	var l := UiTheme.label(text, "", 320)
	l.add_theme_font_size_override("font_size", 14)
	item.add_child(l)
	_log.add_child(item)
	while _log.get_child_count() > 6:
		var old := _log.get_child(0)
		_log.remove_child(old)
		old.queue_free()
	var tw := item.create_tween()
	tw.tween_interval(7.0)
	tw.tween_property(item, "modulate:a", 0.0, 1.0)
	tw.tween_callback(item.queue_free)


func banner(text: String) -> void:
	_banner.text = text
	var tw := _banner.create_tween()
	_banner.modulate.a = 0.0
	tw.tween_property(_banner, "modulate:a", 1.0, 0.25)
	tw.tween_interval(1.4)
	tw.tween_property(_banner, "modulate:a", 0.0, 0.6)


func update_from(w: GameWorld) -> void:
	var p = w.profile
	var pl := w.player
	var s := w.stats
	var t := w.talent()
	var rank_color := Talents.rank_color(t.rank)

	_level.text = "%s · Cấp %d" % [p.name, p.level]
	_talent.text = "%s · %s" % [t.rank, t.name]
	_talent.add_theme_color_override("font_color", rank_color)
	_hp_bar.value = maxf(0.0, pl.hp) / float(s.max_hp)
	_hp_text.text = "%d / %d" % [ceili(maxf(0.0, pl.hp)), s.max_hp]
	_mp_bar.value = maxf(0.0, pl.mp) / maxf(1.0, float(s.max_mp))
	_mp_text.text = "MP %d / %d" % [floori(maxf(0.0, pl.mp)), s.max_mp]
	var need := Formulas.exp_to_next(p.level)
	_exp_bar.value = minf(1.0, float(p.xp) / need)
	_exp_text.text = "EXP %d / %d" % [p.xp, need]
	_power.text = "Lực chiến %d%s" % [w.combat_power(), "   ·   TỰ ĐÁNH (Z)" if w.auto_fight else ""]
	_points.visible = p.unspent > 0
	_points.text = "+%d điểm tiềm năng — nhấn C" % p.unspent

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
	_resources.text = ("Đuốc hồi%s · rê chuột vào icon để xem chú thích" % torch_note) if torch_note != "" else "Rê chuột vào icon để xem chú thích"

	_update_quest(w)
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

	_combo.visible = w.combo >= 5
	_combo.text = "%d combo · +%d%% EXP" % [w.combo, roundi((Formulas.combo_exp_multiplier(w.combo) - 1.0) * 100.0)]

	_update_skill_bar(w, t, rank_color)
	var extra: Array[String] = []
	if p.talent_level > 1:
		extra.append("Thiên phú cấp %d" % p.talent_level)
	if not w.allies.is_empty():
		extra.append("Đồng minh %d" % w.allies.size())
	if p.talent == "ngu-hanh":
		extra.append("Hệ %s" % Monsters.ELEMENT_NAMES[p.element])
	_extra.text = "   ·   ".join(extra)
	_extra.visible = not extra.is_empty()

	var boss := w.big_enemy()
	_boss_box.visible = boss != null
	if boss != null:
		var tags := (" · Giai đoạn 2" if boss.phase > 1 else "") + (" · CHOÁNG" if boss.broken else "")
		_boss_name.text = boss.name + tags
		_boss_hp.value = maxf(0.0, boss.hp) / boss.max_hp
		_boss_poise.value = boss.poise / boss.max_poise
	_dead.visible = pl.dead_timer > 0.0 and w.travel_timer <= 0.0
	_travel.visible = w.travel_timer > 0.0
	if _travel.visible:
		var dest: Dictionary = Maps.get_map(w.travel_target)
		_travel_label.text = "Đang lên đường tới %s…\n%.1f giây" % [dest.name, w.travel_timer]
	var m: Dictionary = w.map
	_map_name.text = "%s · cấp %d–%d" % [m.name, m.levels[0], m.levels[1]]
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
	_skills.set_slot(SLOT_BASIC, {"key": "J", "name": c.basic.name, "icon": SpriteLib.icon("skill-" + str(c.basic.icon)),
		"sub": "Đánh thường"})
	for i in 4:
		var sk: Dictionary = c.skills[i]
		var cd_left: float = pl.skill_cds[i]
		var mp := int(w.skill_mp(i))
		var low := pl.mp < mp
		_skills.set_slot(i + 1, {"key": str(i + 1), "name": sk.name, "icon": SpriteLib.icon("skill-" + str(sk.icon)),
			"cd": cd_left / maxf(0.1, w.skill_cd_of(i)), "cd_text": str(ceili(cd_left)) if cd_left > 0.0 else "",
			"sub": "%d MP" % mp, "dim": low})
	_skills.set_slot(SLOT_DODGE, {"key": "Space", "name": "Né lăn", "icon": SpriteLib.icon("skill-dodge"),
		"cd": pl.dodge_cd / GameWorld.DODGE_CD, "cd_text": ("%.1f" % pl.dodge_cd) if pl.dodge_cd > 0.0 else ""})
	var tal := {"key": "L", "icon": SpriteLib.talent_icon(t.id), "ring": rank_color}
	if Talents.has_skill(t):
		tal.name = w.talent_skill_name()
		tal.cd = pl.talent_cd / maxf(0.1, w.talent_skill_cd())
		tal.cd_text = str(ceili(pl.talent_cd)) if pl.talent_cd > 0.0 else ""
		tal.sub = t.name
	else:
		tal.name = t.name
		tal.sub = "Bị động"
	_skills.set_slot(SLOT_TALENT, tal)
	var pot := {"key": "Q", "name": "Bình máu", "icon": SpriteLib.icon("skill-potion")}
	if p.talent == "hap-huyet":
		pot.sub = "Bị khoá"
		pot.locked = true
	else:
		pot.sub = "×%d · Thảo %d/2" % [p.potions, p.herbs]
		pot.cd = pl.potion_cd / GameWorld.POTION_CD
		pot.cd_text = str(ceili(pl.potion_cd)) if pl.potion_cd > 0.0 else ""
		pot.dim = p.potions <= 0
	_skills.set_slot(SLOT_POTION, pot)


## C1-12: bảng nhiệm vụ chương 1 (thay 3 mục tiêu cũ).
static func _arrow(d: Vector2) -> String:
	var arrows := ["về Đông", "về Đông Nam", "về Nam", "về Tây Nam", "về Tây", "về Tây Bắc", "về Bắc", "về Đông Bắc"]
	return arrows[posmod(roundi(d.angle() / (PI / 4.0)), 8)]


func _update_quest(w: GameWorld) -> void:
	var p = w.profile
	var q := w.quest()
	# M4.3: nhiệm vụ chính chương 2 khi đã tới vùng 2 (hoặc chương 1 đã xong).
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
		_set_obj(1, "Chương 3: Sa Mạc Xích Sa — sắp mở (cần Lực chiến 5.000)", UiTheme.MUTED)
		_set_obj(2, "", UiTheme.MUTED)
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


func _set_obj(i: int, text: String, color: Color) -> void:
	_objectives[i].text = text
	_objectives[i].visible = text != ""
	_objectives[i].add_theme_color_override("font_color", color)


func _objective(i: int, done: bool, text: String) -> void:
	_objectives[i].text = ("✓ " if done else "○ ") + text
	_objectives[i].add_theme_color_override("font_color", UiTheme.GOOD if done else UiTheme.MUTED)


func _layout() -> void:
	var sz := size
	_tl.position = Vector2(12, 12)
	_tr.reset_size()
	_tr.position = Vector2(sz.x - _tr.size.x - 12, 12)
	_obj.position = Vector2(sz.x - _obj.size.x - 12, _tr.position.y + _tr.size.y + 8)
	var boss_w := clampf(sz.x - 680.0, 260.0, 520.0)
	_boss_box.size = Vector2(boss_w, 0)
	_boss_box.position = Vector2((sz.x - boss_w) / 2.0, 14)
	_wind.reset_size()
	_wind.position = Vector2((sz.x - _wind.size.x) / 2.0, 92.0 if _boss_box.visible else 18.0)
	_combo.reset_size()
	_combo.position = Vector2(sz.x - _combo.size.x - 24, sz.y / 2.0)
	_skills.position = Vector2((sz.x - _skills.size.x) / 2.0, sz.y - _skills.size.y - 14)
	# UI-02: nhật ký nằm trên thanh kỹ năng.
	_log.reset_size()
	_log.position = Vector2(12, _skills.position.y - _log.size.y - 10)
	_banner.reset_size()
	_banner.position = Vector2((sz.x - _banner.size.x) / 2.0, sz.y * 0.28)
