extends "res://scripts/ui/modal.gd"
## Bảng chỉ số: cộng điểm tiềm năng, tẩy điểm, xem Thiên phú.

const Config = preload("res://scripts/core/config.gd")
const Talents = preload("res://scripts/data/talents.gd")
const Classes = preload("res://scripts/data/classes.gd")
const Stats = preload("res://scripts/core/stats.gd")

## UI-03: 5 chỉ số gốc; tác dụng STR/AGI khác nhau theo lớp (03-mvp-spec mục 5.2–5.3).
const ROWS := [
	["str", "Sức mạnh (STR)", "+2 Tấn công", "+1 Tấn công"],
	["agi", "Nhanh nhẹn (AGI)", "+1% tốc đánh, +0,5% chí mạng, +0,3% né tránh", "+2 Tấn công, +1% tốc đánh, +0,5% chí mạng, +0,3% né tránh"],
	["int", "Trí tuệ (INT)", "+6 MP, +0,05 MP/giây, +0,5% sát thương kỹ năng", ""],
	["vit", "Thể lực (VIT)", "+12 HP, +0,5 Phòng thủ", ""],
	["luk", "May mắn (LUK)", "+0,3% chí mạng, +0,2% tỉ lệ rơi đồ", ""],
]


func _render(content: VBoxContainer) -> void:
	var p = world.profile
	var s: Dictionary = world.stats
	var t: Dictionary = world.talent()
	content.custom_minimum_size.x = 560
	_header(content, "%s · Cấp %d" % [Classes.get_class_def(p.class_id).name, p.level], "Đóng (C)")

	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", UiTheme.rank_box(Talents.rank_color(t.rank)))
	var ch := UiTheme.hbox(14)
	var rank := UiTheme.label(t.rank, "Heading")
	rank.add_theme_font_size_override("font_size", 38)
	rank.add_theme_color_override("font_color", Talents.rank_color(t.rank))
	ch.add_child(rank)
	var cv := UiTheme.vbox(2)
	cv.add_child(UiTheme.label("%s · %s" % [t.name, Talents.group_name(t)]))
	cv.add_child(UiTheme.label(t.description, "Muted", 330))
	ch.add_child(cv)
	card.add_child(ch)
	content.add_child(card)

	content.add_child(UiTheme.label("Điểm tiềm năng còn lại: %d" % p.unspent, "Muted"))
	var hunter: bool = p.class_id == "tho-san"
	var stolen := Stats.total_points({}, p.stolen)
	for r in ROWS:
		var row := UiTheme.hbox(10)
		var left := UiTheme.vbox(0)
		left.size_flags_horizontal = SIZE_EXPAND_FILL
		left.add_child(UiTheme.label(r[1]))
		left.add_child(UiTheme.label(r[3] if hunter and r[3] != "" else r[2], "Small"))
		row.add_child(left)
		var extra: int = stolen[r[0]]
		var val := UiTheme.label(str(int(p.points.get(r[0], 0))) + (" +%d" % extra if extra > 0 else ""), "Heading")
		if extra > 0:
			val.add_theme_color_override("font_color", Color("#ff5470"))
			val.tooltip_text = "Đạo Tặc cướp được %d điểm" % extra
		val.custom_minimum_size.x = 64
		val.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		row.add_child(val)
		var plus := UiTheme.button("+")
		plus.custom_minimum_size.x = 44
		plus.disabled = p.unspent <= 0
		var key: String = r[0]
		plus.pressed.connect(func(): _allocate(key))
		row.add_child(plus)
		content.add_child(row)

	if not p.stolen.is_empty():
		content.add_child(UiTheme.label("Đạo Tặc: %d/%d điểm cướp được (màu đỏ) — không bị tẩy điểm." % [p.stolen.size(), p.level], "Small"))
	var derived := "Lực chiến %d\nHP %d   ·   MP %d   ·   Tấn công %d   ·   Phòng thủ %.1f\nTốc đánh %d%%   ·   Chí mạng %.1f%%   ·   Sát thương chí mạng ×%.2f   ·   Né tránh %.1f%%" % [
		world.combat_power(), s.max_hp, s.max_mp, int(s.atk), s.def, roundi(s.atk_speed * 100.0), s.crit * 100.0, 1.0 + s.crit_dmg, s.evasion * 100.0
	]
	var dl := UiTheme.label(derived, "Muted")
	dl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(dl)

	var used := 0
	for k in Stats.STATS:
		used += int(p.points.get(k, 0))
	var respec := UiTheme.button("Tẩy điểm (miễn phí trước cấp %d)" % Config.FREE_RESPEC_LEVEL)
	respec.disabled = p.level >= Config.FREE_RESPEC_LEVEL or used == 0
	respec.pressed.connect(func():
		world.respec()
		refresh())
	content.add_child(respec)
	# C1-34: tự cộng điểm theo lớp
	var auto := UiTheme.button("Tự cộng điểm (%s)" % ("3 AGI : 1 VIT : 1 LUK" if p.class_id == "tho-san" else "3 STR : 2 VIT"), true)
	auto.name = "AutoAllocate"
	auto.disabled = p.unspent <= 0
	auto.pressed.connect(func():
		world.auto_allocate()
		refresh())
	content.add_child(auto)


func _allocate(stat: String) -> void:
	world.allocate(stat)
	refresh()
