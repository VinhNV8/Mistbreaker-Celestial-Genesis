extends RefCounted
## UI-11 (Spec_Notes đợt 6): trang Chỉ số — cộng điểm tiềm năng, tẩy điểm, tự cộng, xem Thiên phú.
## Trước là bảng riêng (phím C); nay là tab "Chỉ số" trong Túi đồ (phím C mở thẳng tab này).

const UiTheme = preload("res://scripts/ui/ui_theme.gd")
const Config = preload("res://scripts/core/config.gd")
const Talents = preload("res://scripts/data/talents.gd")
const Classes = preload("res://scripts/data/classes.gd")
const Stats = preload("res://scripts/core/stats.gd")

## UI-03: 5 chỉ số gốc; tác dụng STR/AGI/INT khác nhau theo lớp (03-mvp-spec mục 5.2–5.3, 09 SN-02).
## [id, tên, mô tả Kiếm Khách, mô tả Thợ Săn ("" = như Kiếm Khách), mô tả Pháp Sư ("" = như Kiếm Khách)]
const ROWS := [
	["str", "Sức mạnh (STR)", "+2 Tấn công", "+1 Tấn công", "Không tăng Tấn công của Pháp Sư"],
	["agi", "Nhanh nhẹn (AGI)", "+1% tốc đánh, +0,5% chí mạng, +0,3% né tránh", "+2 Tấn công, +1% tốc đánh, +0,5% chí mạng, +0,3% né tránh", ""],
	["int", "Trí tuệ (INT)", "+6 MP, +0,05 MP/giây, +0,5% sát thương kỹ năng", "", "+2 Tấn công, +6 MP, +0,05 MP/giây, +0,5% sát thương kỹ năng"],
	["vit", "Thể lực (VIT)", "+12 HP, +0,5 Phòng thủ", "", ""],
	["luk", "May mắn (LUK)", "+0,3% chí mạng, +0,2% tỉ lệ rơi đồ", "", ""],
]


static func build(content: VBoxContainer, world, refresh: Callable) -> void:
	var p = world.profile
	var t: Dictionary = world.talent()
	content.custom_minimum_size.x = 520

	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", UiTheme.rank_box(Talents.rank_color(t.rank)))
	var ch := UiTheme.hbox(14)
	var rank := UiTheme.label(t.rank, "Heading")
	rank.add_theme_font_size_override("font_size", 38)
	rank.add_theme_color_override("font_color", Talents.rank_color(t.rank))
	ch.add_child(rank)
	var cv := UiTheme.vbox(2)
	cv.add_child(UiTheme.label("%s · %s" % [t.name, Talents.group_name(t)]))
	cv.add_child(UiTheme.label(t.description, "Muted", 300))
	ch.add_child(cv)
	card.add_child(ch)
	content.add_child(card)

	# UI-19: mỗi chỉ số = mặc định của lớp + điểm tiềm năng đã cộng.
	content.add_child(UiTheme.label("Điểm tiềm năng còn lại: %d   ·   chỉ số = mặc định của lớp + điểm cộng" % p.unspent, "Muted", 520))
	var base: Dictionary = Stats.base_stats(str(p.class_id))
	var col: int = {"tho-san": 3, "phap-su": 4}.get(p.class_id, 2)
	var stolen := Stats.total_points({}, p.stolen)
	for r in ROWS:
		var row := UiTheme.hbox(10)
		row.tooltip_text = "Mỗi điểm: " + (r[col] if r[col] != "" else r[2])
		var left := UiTheme.vbox(0)
		left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		left.mouse_filter = Control.MOUSE_FILTER_PASS
		left.add_child(UiTheme.label(r[1]))
		# Đã có điểm: ghi điểm đang cho bao nhiêu; chưa có: ghi tác dụng mỗi điểm.
		var gives := contribution(p, r[0])
		var sub := UiTheme.label(("Đang cho: " + gives) if gives != "" else ("Mỗi điểm: " + (r[col] if r[col] != "" else r[2])), "Small")
		if gives != "":
			sub.add_theme_color_override("font_color", Color("#ffd877"))
		left.add_child(sub)
		row.add_child(left)
		# "mặc định + điểm cộng" (+ điểm Đạo Tặc cướp, đỏ)
		var extra: int = stolen[r[0]]
		var vals := UiTheme.hbox(4)
		vals.custom_minimum_size.x = 120
		vals.alignment = BoxContainer.ALIGNMENT_END
		vals.tooltip_text = "Mặc định của lớp %d + điểm cộng %d%s" % [int(base.get(r[0], 0)), int(p.points.get(r[0], 0)),
			(" + Đạo Tặc cướp %d" % extra) if extra > 0 else ""]
		var bl := UiTheme.label(str(int(base.get(r[0], 0))), "Heading")
		bl.add_theme_color_override("font_color", UiTheme.MUTED)
		vals.add_child(bl)
		vals.add_child(UiTheme.label("+", "Muted"))
		vals.add_child(UiTheme.label(str(int(p.points.get(r[0], 0))), "Heading"))
		if extra > 0:
			var el := UiTheme.label("+%d" % extra, "Heading")
			el.add_theme_color_override("font_color", Color("#ff5470"))
			vals.add_child(el)
		row.add_child(vals)
		var plus := UiTheme.button("+")
		plus.custom_minimum_size.x = 44
		plus.disabled = p.unspent <= 0
		var key: String = r[0]
		plus.pressed.connect(func():
			world.allocate(key)
			refresh.call())
		row.add_child(plus)
		content.add_child(row)

	if not p.stolen.is_empty():
		content.add_child(UiTheme.label("Đạo Tặc: %d/%d điểm cướp được (màu đỏ) — không bị tẩy điểm." % [p.stolen.size(), p.level], "Small"))
	# Chỉ số dẫn xuất (HP, Tấn công, chí mạng…) chỉ hiện ở cột nhân vật bên trái (inventory_panel._character_column) — không lặp lại ở đây.

	var used := 0
	for k in Stats.STATS:
		used += int(p.points.get(k, 0))
	var respec := UiTheme.button("Tẩy điểm (miễn phí trước cấp %d)" % Config.FREE_RESPEC_LEVEL)
	respec.disabled = p.level >= Config.FREE_RESPEC_LEVEL or used == 0
	respec.pressed.connect(func():
		world.respec()
		refresh.call())
	var buttons := UiTheme.hbox(8)
	respec.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	buttons.add_child(respec)
	# C1-34: tự cộng điểm theo lớp
	var auto := UiTheme.button("Tự cộng điểm (%s)" % {"tho-san": "3 AGI : 1 VIT : 1 LUK", "phap-su": "3 INT : 2 VIT"}.get(p.class_id, "3 STR : 2 VIT"), true)
	auto.name = "AutoAllocate"
	auto.disabled = p.unspent <= 0
	auto.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	auto.pressed.connect(func():
		world.auto_allocate()
		refresh.call())
	buttons.add_child(auto)
	content.add_child(buttons)


## Chỉ số chỉ tính chỉ số mặc định + điểm tiềm năng (kể cả điểm Đạo Tặc cướp) — không Thiên phú, không trang bị.
## skip: bỏ hẳn chỉ số đó (cả mặc định lẫn điểm cộng) để biết nó đang cho bao nhiêu.
static func _bare(p, skip := "") -> Dictionary:
	var pts := {}
	var stolen: Array = []
	var base: Dictionary = Stats.base_stats(str(p.class_id)).duplicate()
	for k in Stats.STATS:
		if k != skip:
			pts[k] = int(p.points.get(k, 0))
		else:
			base[k] = 0
	for k in p.stolen:
		if str(k) != skip:
			stolen.append(k)
	return Stats.derive(int(p.level), pts, "", {}, 1, str(p.class_id), stolen, base)


## UI-19: chỉ số key (mặc định + điểm cộng) đang cho bao nhiêu ("+24 Tấn công, +6% chí mạng"); "" nếu bằng 0.
static func contribution(p, key: String) -> String:
	var a := _bare(p)
	var b := _bare(p, key)
	var parts := PackedStringArray()
	for f in [["atk", "Tấn công", 1.0, "%d"], ["max_hp", "HP", 1.0, "%d"], ["def", "Phòng thủ", 1.0, "%.1f"], ["max_mp", "MP", 1.0, "%d"],
			["mp_regen", "MP/giây", 1.0, "%.2f"], ["atk_speed", "% tốc đánh", 100.0, "%.1f"], ["crit", "% chí mạng", 100.0, "%.1f"],
			["evasion", "% né tránh", 100.0, "%.1f"], ["skill_mul", "% sát thương kỹ năng", 100.0, "%.1f"], ["drop_bonus", "% rơi đồ", 100.0, "%.1f"]]:
		var d: float = (float(a[f[0]]) - float(b[f[0]])) * float(f[2])
		if d > 0.001:
			var num: String = (str(f[3]) % d).trim_suffix(".0")
			parts.append("+" + num + ("" if str(f[1]).begins_with("%") else " ") + str(f[1]))
	return ", ".join(parts)
