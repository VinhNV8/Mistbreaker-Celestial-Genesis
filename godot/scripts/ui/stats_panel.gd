extends "res://scripts/ui/modal.gd"
## Bảng chỉ số: cộng điểm tiềm năng, tẩy điểm, xem Thiên phú.

const Config = preload("res://scripts/core/config.gd")
const Talents = preload("res://scripts/data/talents.gd")

const ROWS := [
	["str", "Sức mạnh (STR)", "+2 Tấn công"],
	["agi", "Nhanh nhẹn (AGI)", "+1% tốc đánh, +0,5% chí mạng"],
	["vit", "Thể lực (VIT)", "+12 HP, +0,5 Phòng thủ"],
]


func _render(content: VBoxContainer) -> void:
	var p = world.profile
	var s: Dictionary = world.stats
	var t: Dictionary = world.talent()
	content.custom_minimum_size.x = 460
	_header(content, "Kiếm Khách · Cấp %d" % p.level, "Đóng (C)")

	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", UiTheme.rank_box(Talents.rank_color(t.rank)))
	var ch := UiTheme.hbox(14)
	var rank := UiTheme.label(t.rank, "Heading")
	rank.add_theme_font_size_override("font_size", 38)
	rank.add_theme_color_override("font_color", Talents.rank_color(t.rank))
	ch.add_child(rank)
	var cv := UiTheme.vbox(2)
	cv.add_child(UiTheme.label("%s · %s" % [t.name, t.group]))
	cv.add_child(UiTheme.label(t.description, "Muted", 330))
	ch.add_child(cv)
	card.add_child(ch)
	content.add_child(card)

	content.add_child(UiTheme.label("Điểm tiềm năng còn lại: %d" % p.unspent, "Muted"))
	for r in ROWS:
		var row := UiTheme.hbox(10)
		var left := UiTheme.vbox(0)
		left.size_flags_horizontal = SIZE_EXPAND_FILL
		left.add_child(UiTheme.label(r[1]))
		left.add_child(UiTheme.label(r[2], "Small"))
		row.add_child(left)
		var val := UiTheme.label(str(p.points[r[0]]), "Heading")
		val.custom_minimum_size.x = 40
		val.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		row.add_child(val)
		var plus := UiTheme.button("+")
		plus.custom_minimum_size.x = 44
		plus.disabled = p.unspent <= 0
		var key: String = r[0]
		plus.pressed.connect(func(): _allocate(key))
		row.add_child(plus)
		content.add_child(row)

	var derived := "Lực chiến %d\nHP %d   ·   Tấn công %d   ·   Phòng thủ %.1f\nTốc đánh %d%%   ·   Chí mạng %.1f%%   ·   Sát thương chí mạng ×%.2f" % [
		world.combat_power(), s.max_hp, int(s.atk), s.def, roundi(s.atk_speed * 100.0), s.crit * 100.0, 1.0 + s.crit_dmg
	]
	var dl := UiTheme.label(derived, "Muted")
	dl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(dl)

	var used: int = int(p.points.str) + int(p.points.agi) + int(p.points.vit)
	var respec := UiTheme.button("Tẩy điểm (miễn phí trước cấp %d)" % Config.FREE_RESPEC_LEVEL)
	respec.disabled = p.level >= Config.FREE_RESPEC_LEVEL or used == 0
	respec.pressed.connect(func():
		world.respec()
		refresh())
	content.add_child(respec)


func _allocate(stat: String) -> void:
	world.allocate(stat)
	refresh()
