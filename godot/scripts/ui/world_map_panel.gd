extends "res://scripts/ui/modal.gd"
## MP-02: bản đồ lục địa (phím N) — 9 vùng của Huyền Thổ, map con, điểm dịch chuyển, nút Lên đường.

const Maps = preload("res://scripts/data/maps.gd")
const Monsters = preload("res://scripts/data/monsters.gd")

const W := 760.0

## Dòng chữ cảnh kết chương (MP-06), hiện một lần khi mở từ màn hình chiến thắng.
var intro := ""


func _render(content: VBoxContainer) -> void:
	content.custom_minimum_size.x = W
	_header(content, "Bản đồ lục địa Huyền Thổ", "Đóng (N)")
	if intro != "":
		var l := UiTheme.label(intro, "", W)
		l.add_theme_color_override("font_color", UiTheme.GOLD)
		content.add_child(l)
	var here: Dictionary = Maps.get_map(world.map_id)
	content.add_child(UiTheme.label("Đang ở: %s · cấp %d–%d. Lên đường khi không giao chiến; mất %.1f giây đi đường." % [
		here.name, here.levels[0], here.levels[1], world.travel_seconds()], "Muted", W))
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	for r in Maps.REGIONS:
		grid.add_child(_region_card(r))
	content.add_child(grid)


func _region_open(r: Dictionary) -> bool:
	for m in r.maps:
		if m in world.profile.unlocked_maps or world.travel_blocker(m) == "":
			return true
	return false


func _region_card(r: Dictionary) -> Control:
	var open := _region_open(r)
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(246, 150)
	var el: String = r.element
	var accent := Color(Monsters.ELEMENT_HEX[el]) if el != "" else Color("#9b6ee0")
	var current: bool = int(r.id) == int(Maps.get_map(world.map_id).region)
	var bg := Color(accent.darkened(0.8), 1.0) if open else Color(0.08, 0.09, 0.12, 1.0)
	card.add_theme_stylebox_override("panel", UiTheme.box(bg, 10, 3 if current else 1, UiTheme.GOLD if current else (accent if open else UiTheme.LINE), 10))
	var v := UiTheme.vbox(4)
	card.add_child(v)
	var title := UiTheme.label("%d. %s" % [r.id, r.name], "", 226)
	title.add_theme_font_override("font", UiTheme.bold_font())
	title.add_theme_color_override("font_color", UiTheme.TEXT if open else UiTheme.MUTED)
	v.add_child(title)
	v.add_child(UiTheme.label("Cấp %d–%d%s" % [r.levels[0], r.levels[1], (" · hệ " + Monsters.ELEMENT_NAMES[el]) if el != "" else ""], "Small"))
	if r.maps.is_empty():
		v.add_child(UiTheme.label("Cần: " + str(r.get("unlock", "Chưa mở")), "Small", 226))
		return card
	for m_id in r.maps:
		var m: Dictionary = Maps.MAPS[m_id]
		var row := UiTheme.hbox(6)
		var here: bool = m_id == world.map_id
		var unlocked: bool = m_id in world.profile.unlocked_maps
		var block: String = world.travel_blocker(m_id)
		var name := UiTheme.label("%s%s (%d–%d)" % ["● " if here else ("◆ " if unlocked else ""), m.name, m.levels[0], m.levels[1]], "Small", 150)
		name.size_flags_horizontal = SIZE_EXPAND_FILL
		row.add_child(name)
		if not here:
			var b := UiTheme.button("Lên đường")
			b.name = "Travel_" + m_id
			b.add_theme_font_size_override("font_size", 12)
			b.disabled = block != ""
			b.tooltip_text = block if block != "" else world.challenge_warning(m_id)
			var id: String = m_id
			b.pressed.connect(func():
				var res: Dictionary = world.travel(id)
				if res.ok:
					intro = ""
					close())
			row.add_child(b)
		v.add_child(row)
		if not here and block != "" and not unlocked:
			v.add_child(UiTheme.label("Cần: " + block, "Small", 226))
		elif not here and world.challenge_warning(m_id) != "":
			var warn := UiTheme.label("Thử thách vượt ải (quái mạnh hơn)", "Small")
			warn.add_theme_color_override("font_color", UiTheme.BAD)
			v.add_child(warn)
	return card
