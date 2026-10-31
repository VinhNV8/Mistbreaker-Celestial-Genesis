extends RefCounted
## UI-11 (Spec_Notes đợt 6): trang Chỉ số — cộng điểm tiềm năng, tẩy điểm, tự cộng, xem Thiên phú.
## UI-21: dựng lại theo thiết kế mới — cột giữa "Điểm thuộc tính" (build), cột phải Lực chiến + chỉ số chiến đấu (build_side).
## Trước là bảng riêng (phím C); nay là tab "Chỉ số" trong Túi đồ (phím C mở thẳng tab này).

const UiTheme = preload("res://scripts/ui/ui_theme.gd")
const Config = preload("res://scripts/core/config.gd")
const Talents = preload("res://scripts/data/talents.gd")
const Classes = preload("res://scripts/data/classes.gd")
const Stats = preload("res://scripts/core/stats.gd")
const SpriteLib = preload("res://scripts/view/sprite_lib.gd")
const Ornate = preload("res://scripts/ui/ornate.gd")

## CS (docs/26): 7 thuộc tính — [id, tên]. Tác dụng mỗi điểm theo lớp sinh từ hằng số Stats (per_point).
## UI-26c: thứ tự cố định cho mọi lớp (theo ảnh mẫu) — lớp nào cũng STR · VIT · AGI · INT · WIS · DEX · LUK.
const ROWS := [
	["str", "Sức mạnh (STR)"], ["vit", "Thể lực (VIT)"], ["agi", "Nhanh nhẹn (AGI)"], ["int", "Trí tuệ (INT)"],
	["wis", "Tinh thần (WIS)"], ["dex", "Khéo léo (DEX)"], ["luk", "May mắn (LUK)"],
]

## UI-21: icon từng thuộc tính (tools/art/stat_icons.py).
const ICONS := {"str": "stat-str", "agi": "stat-agi", "int": "stat-int", "vit": "stat-vit", "luk": "stat-luk",
	"wis": "stat-wis", "dex": "stat-dex"}

## CS (docs/26 mục 5): 3 build mỗi lớp — [tên, chu kỳ 5 điểm, nhánh chức 2 hợp ("" = mặc định)].
## Build 0 = Mặc định, trùng `auto` trong classes.gd (GameWorld.auto_allocate, bot test).
const PRESETS := {
	"kiem-khach": [["Mặc định (3 STR : 1 VIT : 1 AGI)", ["str", "str", "vit", "str", "agi"], ""],
		["Bạo Kích (3 STR : 1 AGI : 1 LUK)", ["str", "agi", "str", "luk", "str"], "kiem-thanh"],
		["Huyết Chiến (3 STR : 2 VIT)", ["str", "vit", "str", "vit", "str"], "huyet-kiem"]],
	"tho-san": [["Mặc định (2 DEX : 2 AGI : 1 VIT)", ["dex", "agi", "dex", "agi", "vit"], ""],
		["Bách Phát (3 DEX : 2 AGI)", ["dex", "agi", "dex", "agi", "dex"], "than-tien"],
		["Bẫy Thủ (3 DEX : 1 VIT : 1 WIS)", ["dex", "vit", "dex", "wis", "dex"], "tho-bay"]],
	"phap-su": [["Mặc định (3 INT : 1 VIT : 1 WIS)", ["int", "int", "vit", "int", "wis"], ""],
		["Nguyên Tố (4 INT : 1 WIS)", ["int", "int", "wis", "int", "int"], "dai-phap-su"],
		["Tử Linh (2 INT : 2 VIT : 1 WIS)", ["int", "vit", "int", "vit", "wis"], "tu-linh-su"]],
	"ho-ve": [["Mặc định (3 VIT : 2 STR)", ["vit", "str", "vit", "str", "vit"], ""],
		["Thành Trì (3 VIT : 1 STR : 1 WIS)", ["vit", "str", "vit", "wis", "vit"], "thiet-ve"],
		["Thánh Chiến (3 STR : 1 VIT : 1 AGI)", ["str", "vit", "str", "agi", "str"], "thanh-ky-si"]],
	"trieu-hoi-su": [["Mặc định (3 INT : 1 VIT : 1 WIS)", ["int", "int", "vit", "int", "wis"], ""],
		["Long Uy (4 INT : 1 VIT)", ["int", "int", "vit", "int", "int"], "ngu-long-su"],
		["Đồ Đằng (2 INT : 2 WIS : 1 VIT)", ["int", "wis", "int", "wis", "vit"], "do-dang-su"]],
}
## Mẫu đang chọn theo lớp (chỉ trong phiên chơi, không lưu save).
static var preset := {}

const QUOTES := {
	"kiem-khach": "“Một thanh kiếm, một tấm lòng — đủ để rẽ màn sương.”",
	"tho-san": "“Kẻ lang thang giữa rừng sâu, cũng có thể viết nên huyền thoại.”",
	"phap-su": "“Ngọn lửa nhỏ trong tay, là ánh sao giữa đêm dài.”",
	"ho-ve": "“Chừng nào khiên còn đứng, phía sau ta không ai ngã xuống.”",
	"trieu-hoi-su": "“Ta không bao giờ đi một mình — vạn linh theo ta.”",
}


static func presets_for(class_id: String) -> Array:
	return PRESETS.get(class_id, PRESETS["kiem-khach"])


## CS-UI6: build đang chọn — chưa chọn thì gợi ý build khớp nhánh chức 2 (từ cấp 60), không thì Mặc định.
static func preset_index(p) -> int:
	var list := presets_for(str(p.class_id))
	if preset.has(p.class_id):
		return clampi(int(preset[p.class_id]), 0, list.size() - 1)
	for i in list.size():
		if str(list[i][2]) != "" and str(list[i][2]) == str(p.job2):
			return i
	return 0


## CS-UI7: tác dụng 1 điểm thuộc tính cho lớp đang chơi (sinh từ hằng số Stats — luôn khớp công thức).
static func per_point(class_id: String, key: String) -> String:
	return ", ".join(per_point_lines(class_id, key))


## UI-26: như per_point nhưng mỗi tác dụng một dòng (tooltip nút i của hàng thuộc tính).
static func per_point_lines(class_id: String, key: String) -> PackedStringArray:
	var cid := Stats.class_of(class_id)
	var c: Dictionary = Stats.CLASS[cid]
	var parts := PackedStringArray()
	var atk := float(c.atk.get(key, 0.0))
	if atk > 0.0:
		parts.append("+%s Tấn công%s" % [_n(atk), " phép" if cid == "phap-su" else (" (cả linh thú)" if cid == "trieu-hoi-su" else "")])
	match key:
		"agi":
			parts.append_array(["+%s%% Tốc đánh" % _n(Stats.AGI_SPEED * 100), "+%s%% Chí mạng" % _n(Stats.AGI_CRIT * 100), "+%s%% Né tránh" % _n(Stats.AGI_EVA * 100)])
		"vit":
			parts.append_array(["+%s Sinh lực (HP)" % _n(float(c.hp_vit)), "+%s Phòng thủ%s" % [_n(Stats.VIT_DEF), " (×1,3 của lớp)" if float(c.def_mult) > 1.0 else ""]])
		"int":
			parts.append_array(["+%s Năng lượng (MP)" % _n(Stats.INT_MP), "+%s%% Sát thương kỹ năng" % _n(Stats.INT_SKILL * 100)])
		"wis":
			parts.append_array(["+%s MP/giây" % _n(Stats.WIS_REGEN), "+%s%% Kháng nguyên tố" % _n(Stats.WIS_RES * 100)])
			if cid == "trieu-hoi-su":
				parts.append("+%s%% HP linh thú" % _n(Stats.SUMMONER_WIS_PET * 100))
			if cid == "ho-ve":
				parts.append("+%s%% Kháng hiệu ứng" % _n(Stats.GUARD_WIS_CC * 100))
		"dex":
			parts.append_array(["+%s%% Xuyên giáp" % _n(Stats.DEX_PEN * 100), "+%s%% Phá Thế" % _n(Stats.DEX_POISE * 100)])
		"luk":
			parts.append_array(["+%s%% Chí mạng" % _n(Stats.LUK_CRIT * 100), "+%s%% Tỉ lệ rơi đồ" % _n(Stats.LUK_DROP * 100)])
			if cid == "tho-san":
				parts.append("Chí mạng vượt trần 60% → ST chí mạng")
		"str":
			if atk <= 0.0:
				parts.append("Không tăng Tấn công của lớp này")
	return parts


static func _n(v: float) -> String:
	var t := ("%.2f" % v).rstrip("0").rstrip(".")
	return t.replace(".", ",")


## Tự cộng hết điểm theo mẫu idx của lớp. Mẫu 0 gọi thẳng GameWorld.auto_allocate (C1-34).
static func apply_preset(world, idx: int) -> int:
	var list := presets_for(str(world.profile.class_id))
	idx = clampi(idx, 0, list.size() - 1)
	if idx == 0:
		return world.auto_allocate()
	var pattern: Array = list[idx][1]
	var n := 0
	while world.profile.unspent > 0:
		world.allocate(pattern[n % pattern.size()])
		n += 1
	if n > 0:
		world._message("Tự cộng %d điểm tiềm năng (%s)." % [n, list[idx][0]], "good")
	return n


## UI-27 (ảnh mẫu của chủ dự án, trang trí cắt từ ảnh — tools/art/ui_cut.py): cột giữa "Thuộc tính".
## Tiêu đề + nút i + ô "Điểm thuộc tính" có cánh; 7 hàng gọn (icon vẽ · STR / Sức mạnh · nhãn Chính · tổng + dòng nhỏ
## "gốc +cộng" tách màu · nút i (tác dụng mỗi điểm, đang cho bao nhiêu) · nút +); dưới: nút vàng "Phân bổ tự động",
## ô chọn mẫu, Tẩy điểm. Thứ tự hàng cố định cho mọi lớp (UI-26c).
static func build(content: VBoxContainer, world, refresh: Callable) -> void:
	var p = world.profile
	var wrap := UiTheme.panel(Ornate.panel_style())
	Ornate.linear(wrap)
	wrap.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var col := UiTheme.vbox(6)
	col.custom_minimum_size.x = 520
	wrap.add_child(col)
	content.add_child(wrap)

	var head := UiTheme.hbox(10)
	var title := UiTheme.strong("Thuộc tính", 26, Color("#f3d27a"))
	title.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	head.add_child(title)
	var hint := Ornate.image("ui-btn-info", 28, 28)
	hint.name = "PointsHelp"
	hint.mouse_filter = Control.MOUSE_FILTER_STOP
	hint.tooltip_text = "Mỗi cấp nhận 5 điểm thuộc tính.\nThuộc tính = cơ bản (khởi tạo của lớp + tự tăng theo cấp) + điểm tự cộng.\nRê chuột vào nút i từng hàng để xem tác dụng mỗi điểm."
	head.add_child(hint)
	head.add_child(UiTheme.spacer())
	var badge := Ornate.Plate.new("ui-points", 180)
	badge.name = "PointsBadge"
	badge.title = "Điểm thuộc tính"
	badge.value = str(p.unspent)
	badge.title_y = 0.27
	badge.value_y = 0.6
	badge.title_size = 11
	badge.value_size = 24
	head.add_child(badge)
	col.add_child(head)

	var base: Dictionary = Stats.base_stats(str(p.class_id))
	var grow := Stats.grown(str(p.class_id), int(p.level))
	var stolen := Stats.total_points({}, p.stolen)
	var mains := str(Classes.DEFS.get(p.class_id, {}).get("main", "")).to_lower()
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size.y = 300
	var cards := UiTheme.vbox(3)
	cards.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(cards)
	col.add_child(scroll)
	for r in ROWS:
		var key: String = r[0]
		var card := UiTheme.panel(Ornate.row_style())
		Ornate.linear(card)
		card.name = "StatCard_" + key
		card.custom_minimum_size.y = 54
		var row := UiTheme.hbox(12)
		card.add_child(row)
		row.add_child(Ornate.image("attr-" + key, 46, 42))
		var names := UiTheme.vbox(0)
		names.custom_minimum_size.x = 92
		names.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		names.add_child(UiTheme.strong(key.to_upper(), 19, Color("#f4ecdc")))
		var full := UiTheme.label(str(r[1]).get_slice(" (", 0), "Small")
		full.add_theme_color_override("font_color", Color("#b8aa90"))
		names.add_child(full)
		row.add_child(names)
		if key in mains:
			var tag := Ornate.image("ui-tag-main", 70, 27)
			tag.name = "MainTag_" + key
			tag.tooltip_text = "Thuộc tính chính của lớp — nên ưu tiên cộng điểm."
			row.add_child(tag)
		row.add_child(UiTheme.spacer())
		# tổng + dòng nhỏ tách nguồn: gốc (trắng) · +điểm tự cộng (xanh lá) · +cướp (đỏ) — UI-26b
		var extra: int = stolen[key]
		var b0 := int(base.get(key, 0)) + int(grow[key])
		var pts := int(p.points.get(key, 0))
		var tot := UiTheme.vbox(0)
		tot.custom_minimum_size.x = 90
		tot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		tot.mouse_filter = Control.MOUSE_FILTER_PASS
		tot.tooltip_text = "Khởi tạo %d + tự tăng theo cấp %d + điểm cộng %d%s" % [int(base.get(key, 0)), int(grow[key]), pts, (" + Đạo Tặc cướp %d" % extra) if extra > 0 else ""]
		var total := UiTheme.strong(str(b0 + pts + extra), 26, Color("#f4ecdc"))
		total.name = "Total_" + key
		total.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		tot.add_child(total)
		var parts := [[str(b0), Color("#d8ccb4")], ["+%d" % pts, Color("#5cff7a") if pts > 0 else UiTheme.MUTED]]
		if extra > 0:
			parts.append(["+%d" % extra, Color("#ff6a80")])
		var src_row := UiTheme.hbox(4)
		src_row.name = "Source_" + key
		src_row.alignment = BoxContainer.ALIGNMENT_CENTER
		src_row.mouse_filter = Control.MOUSE_FILTER_PASS
		for i in parts.size():
			var piece := UiTheme.strong(str(parts[i][0]), 11, parts[i][1]) if i > 0 else UiTheme.label(str(parts[i][0]), "Small")
			piece.add_theme_font_size_override("font_size", UiTheme.fs(11))
			piece.add_theme_color_override("font_color", parts[i][1])
			src_row.add_child(piece)
		tot.add_child(src_row)
		row.add_child(tot)
		# nút i: tác dụng mỗi điểm + đang cho bao nhiêu
		var gives := contribution(p, key)
		var help := Ornate.image("ui-btn-info", 30, 30)
		help.name = "Help_" + key
		help.mouse_filter = Control.MOUSE_FILTER_STOP
		help.mouse_default_cursor_shape = Control.CURSOR_HELP
		help.tooltip_text = "%s%s\nTăng mỗi điểm:\n%s\n\nĐang cho: %s" % [r[1], "  · Thuộc tính chính" if key in mains else "",
			"\n".join(per_point_lines(str(p.class_id), key)), gives if gives != "" else "chưa có"]
		row.add_child(help)
		var plus := UiTheme.button("")
		plus.name = "Plus_" + key
		Ornate.button(plus, "plus")
		plus.custom_minimum_size = Vector2(44, 44)
		plus.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		plus.disabled = p.unspent <= 0
		plus.tooltip_text = "Cộng 1 điểm vào " + str(r[1])
		plus.pressed.connect(func():
			world.allocate(key)
			refresh.call())
		row.add_child(plus)
		cards.add_child(card)

	if not p.stolen.is_empty() or not p.steal_bag.is_empty():
		var bag := (" · Túi Tang Vật %d/%d" % [p.steal_bag.size(), world.STEAL_BAG_MAX]) if not p.steal_bag.is_empty() else ""
		col.add_child(UiTheme.label("Đạo Tặc: %d/%d điểm cướp được (màu đỏ, giới hạn = cấp Thiên phú × cấp) — không bị tẩy điểm%s." % [p.stolen.size(), world.steal_cap(), bag], "Small"))

	# dưới: nút vàng Phân bổ tự động | ô chọn mẫu + Tẩy điểm (C1-34, UI-21)
	var list := presets_for(str(p.class_id))
	var cur: int = preset_index(p)
	var bottom := UiTheme.hbox(12)
	var auto := UiTheme.button("Phân bổ tự động")
	auto.name = "AutoAllocate"
	Ornate.button(auto, "gold")
	auto.add_theme_font_size_override("font_size", UiTheme.fs(19))
	auto.icon = SpriteLib.icon("stat-auto")
	auto.add_theme_constant_override("icon_max_width", 30)
	auto.disabled = p.unspent <= 0
	auto.custom_minimum_size = Vector2(0, 62)
	auto.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	auto.tooltip_text = "Cộng hết điểm còn lại theo mẫu: " + str(list[cur][0])
	auto.pressed.connect(func():
		apply_preset(world, cur)
		refresh.call())
	bottom.add_child(auto)
	var right := UiTheme.vbox(6)
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var pick := OptionButton.new()
	pick.name = "AutoPreset"
	pick.focus_mode = Control.FOCUS_NONE
	Ornate.button(pick, "dark")
	pick.custom_minimum_size.y = 34
	pick.clip_text = true
	for e in list:
		pick.add_item(str(e[0]))
	pick.select(cur)
	var job2 := str(list[cur][2])
	pick.tooltip_text = "Mẫu phân bổ tự động" + ((" — hợp nhánh chức 2: " + str(Classes.job2_def(str(p.class_id), job2).get("name", job2))) if job2 != "" else "")
	pick.item_selected.connect(func(i: int):
		preset[p.class_id] = i
		refresh.call())
	right.add_child(pick)
	var used := 0
	for k in Stats.STATS:
		used += int(p.points.get(k, 0))
	var rrow := UiTheme.hbox(8)
	var respec := UiTheme.button("Tẩy điểm")
	respec.name = "Respec"
	Ornate.button(respec, "dark")
	respec.icon = SpriteLib.icon("stat-respec")
	respec.add_theme_constant_override("icon_max_width", 20)
	respec.custom_minimum_size.y = 32
	respec.disabled = p.level >= Config.FREE_RESPEC_LEVEL or used == 0
	respec.pressed.connect(func():
		world.respec()
		refresh.call())
	rrow.add_child(respec)
	var free := UiTheme.label("Miễn phí trước cấp %d" % Config.FREE_RESPEC_LEVEL, "Small")
	free.add_theme_color_override("font_color", UiTheme.MUTED)
	free.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	rrow.add_child(free)
	right.add_child(rrow)
	bottom.add_child(right)
	col.add_child(bottom)


## Cột phải: biển Lực chiến (cánh + kiếm) + Chỉ số chiến đấu (kể cả chỉ số phụ) + cảnh kiếm cắm đất kèm câu trích theo lớp.
static func build_side(world) -> VBoxContainer:
	var side := UiTheme.vbox(8)
	side.custom_minimum_size.x = 320
	var banner := Ornate.Plate.new("ui-power", 280)
	banner.name = "PowerBanner"
	banner.power = world.combat_power()
	banner.title = "Lực chiến"
	banner.value = Ornate.group(banner.power)
	banner.title_y = 0.51
	banner.value_y = 0.73
	banner.title_size = 16
	banner.value_size = 32
	banner.tooltip_text = "Lực chiến — tổng hợp Tấn công, Phòng thủ, HP, tốc đánh, chí mạng…"
	side.add_child(banner)
	var s: Dictionary = world.stats
	# lề 20: góc hoa văn của khung không đè lên chữ
	var box := UiTheme.panel(Ornate.panel_style(20))
	Ornate.linear(box)
	var col := UiTheme.vbox(0)
	box.add_child(col)
	var head := UiTheme.strong("Chỉ số chiến đấu", 17, Color("#f3d27a"))
	head.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(head)
	var res: Dictionary = s.get("res", {})
	var res_txt := PackedStringArray()
	var best := 0.0
	for e in [["kim", "Kim"], ["moc", "Mộc"], ["thuy", "Thủy"], ["hoa", "Hỏa"], ["tho", "Thổ"]]:
		var v := float(res.get(e[0], 0.0))
		best = maxf(best, v)
		res_txt.append("%s %d%%" % [e[1], roundi(v * 100.0)])
	# C: số đòn đánh thường mỗi giây theo tốc đánh (chưa tính buff tạm thời).
	var interval: float = world.basic_interval(str(world.profile.class_id))
	var hits: float = float(s.atk_speed) / interval
	for r in [
		["stat-atk", "Tấn công", str(int(s.atk))], ["stat-def", "Phòng thủ", "%.1f" % s.def],
		["stat-hp", "HP tối đa", str(s.max_hp)], ["stat-mp", "MP tối đa", str(s.max_mp)],
		["stat-aspd", "Tốc đánh", "%d%% · %.2f đòn/giây" % [roundi(s.atk_speed * 100.0), hits],
			"Đánh thường: %.2f đòn/giây (%.2f giây mỗi đòn; gốc %.2f giây ÷ tốc đánh). Mỗi AGI +%s%% tốc đánh, trần ×%.1f." % [hits, 1.0 / hits, interval, _n(Stats.AGI_SPEED * 100.0), Stats.SPEED_CAP]], ["stat-crit", "Tỉ lệ chí mạng", "%.1f%%" % (s.crit * 100.0)],
		["stat-critdmg", "ST chí mạng", "×%.2f" % (1.0 + s.crit_dmg)], ["stat-eva", "Né tránh", "%.1f%%" % (s.evasion * 100.0)],
		["stat-regen", "Hồi MP", "%.2f/giây" % s.mp_regen], ["stat-skill", "ST kỹ năng", "+%.1f%%" % ((s.skill_mul - 1.0) * 100.0)],
		["stat-drop", "Rơi đồ", "+%.1f%%" % (s.drop_bonus * 100.0)],
		["stat-dex", "Xuyên giáp", "%.1f%%" % (float(s.get("armor_pen", 0.0)) * 100.0), "Bỏ qua phần trăm Phòng thủ của quái. Sát thương vào thanh Phá Thế +%.1f%%." % (float(s.get("poise_bonus", 0.0)) * 100.0)],
		["stat-move", "Tốc chạy", "%d" % roundi(float(s.move_speed))],
		["stat-res", "Kháng hệ", "tối đa %d%%" % roundi(best * 100.0), "Kháng: " + ", ".join(res_txt)],
	] + ([["stat-wis", "Kháng hiệu ứng", "%d%%" % roundi(float(s.cc_resist) * 100.0), "Choáng, trói, chậm ngắn đi."]] if float(s.get("cc_resist", 0.0)) > 0.0 else []):
		var row := UiTheme.hbox(8)
		row.add_child(UiTheme.icon_rect(SpriteLib.icon(r[0]), 20))
		row.add_child(UiTheme.label(r[1], "Muted"))
		row.add_child(UiTheme.spacer())
		row.add_child(UiTheme.strong(r[2], 15))
		if r.size() > 3:
			row.tooltip_text = r[3]
		col.add_child(row)
	side.add_child(box)
	var camp := UiTheme.panel(Ornate.panel_style(18))
	Ornate.linear(camp)
	camp.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var cv := UiTheme.vbox(4)
	var q := UiTheme.label(QUOTES.get(world.profile.class_id, QUOTES["kiem-khach"]), "Small", 280)
	q.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	q.add_theme_color_override("font_color", Color("#d8c8a8"))
	cv.add_child(q)
	var scene := TextureRect.new()
	scene.texture = Ornate.tex("ui-scene")
	scene.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	scene.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	scene.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scene.custom_minimum_size.y = 40
	scene.clip_contents = true
	cv.add_child(scene)
	camp.add_child(cv)
	side.add_child(camp)
	return side


## Chỉ số chỉ tính thuộc tính (khởi tạo + tự tăng + điểm, kể cả điểm Đạo Tặc cướp) — không Thiên phú, không trang bị.
## skip: bỏ hẳn thuộc tính đó để biết nó đang cho bao nhiêu.
static func _bare(p, skip := "") -> Dictionary:
	var pts := {}
	for k in Stats.STATS:
		pts[k] = int(p.points.get(k, 0))
	return Stats.derive(int(p.level), pts, "", {}, 1, str(p.class_id), p.stolen, skip)


## UI-19 / CS: thuộc tính key đang cho bao nhiêu ("+24 Tấn công, +6% chí mạng"); "" nếu bằng 0.
static func contribution(p, key: String) -> String:
	var a := _bare(p)
	var b := _bare(p, key)
	var parts := PackedStringArray()
	for f in [["atk", "Tấn công", 1.0, "%d"], ["max_hp", "HP", 1.0, "%d"], ["def", "Phòng thủ", 1.0, "%.1f"], ["max_mp", "MP", 1.0, "%d"],
			["mp_regen", "MP/giây", 1.0, "%.2f"], ["atk_speed", "% tốc đánh", 100.0, "%.1f"], ["crit", "% chí mạng", 100.0, "%.1f"],
			["evasion", "% né tránh", 100.0, "%.1f"], ["skill_mul", "% sát thương kỹ năng", 100.0, "%.1f"], ["drop_bonus", "% rơi đồ", 100.0, "%.1f"],
			["armor_pen", "% xuyên giáp", 100.0, "%.1f"], ["poise_bonus", "% Phá Thế", 100.0, "%.1f"], ["cc_resist", "% kháng hiệu ứng", 100.0, "%.1f"],
			["pet_hp_pct", "% HP linh thú", 100.0, "%.1f"]]:
		var d: float = (float(a[f[0]]) - float(b[f[0]])) * float(f[2])
		if d > 0.001:
			var num: String = (str(f[3]) % d).trim_suffix(".0")
			parts.append("+" + num + ("" if str(f[1]).begins_with("%") else " ") + str(f[1]))
	var rk := float(a.res.kim) - float(b.res.kim)
	if rk > 0.0001:
		parts.append("+%s%% kháng hệ" % ("%.1f" % (rk * 100.0)).trim_suffix(".0"))
	if parts.is_empty():
		return ""
	# CS-UI7: chạm trần thì ghi rõ
	if key in ["agi", "luk"] and float(a.crit) >= Stats.CRIT_CAP - 0.0001:
		parts.append("chí mạng đã chạm trần 60%")
	return ", ".join(parts)
