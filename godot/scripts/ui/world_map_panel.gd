extends "res://scripts/ui/modal.gd"
## MP-02: bản đồ lục địa (phím N) — 9 vùng của Huyền Thổ, map con, điểm dịch chuyển, nút Lên đường.
## MP-09: chỉ chọn được nơi đến khi đứng ở Cổng Dịch Chuyển (vùng an toàn) và chỉ tới map đã mở; map mới
## phải đi bộ qua cổng ở rìa map. Mở bằng phím N ở chỗ khác thì chỉ để xem.

const Maps = preload("res://scripts/data/maps.gd")
const Monsters = preload("res://scripts/data/monsters.gd")
## BD-11 (docs/34): dòng Cổng dungeon đang mở dưới map.
const Gates = preload("res://scripts/core/gates.gd")

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
	var how := "Đang đứng ở Cổng Dịch Chuyển — chọn một map đã mở để đi (mất %.1f giây)." % world.travel_seconds() if world.at_waypoint() 		else "Muốn đi: bước vào cổng ở rìa map (sang map kề bên), hoặc tới Cổng Dịch Chuyển trong vùng an toàn để về nhanh map đã mở."
	content.add_child(UiTheme.label("Đang ở: %s · cấp %d–%d. %s" % [here.name, here.levels[0], here.levels[1], how], "Muted", W))
	var gp = world.profile
	var gtxt := "Cổng dungeon: chưa có cổng nào đang mở — cổng hạng E → S mở ngẫu nhiên trên map đã tới (tồn tại 2 giờ chơi), dọn sương ô khai phá cũng có thể lộ cổng."
	if not gp.gates.is_empty():
		var parts := PackedStringArray()
		for gid in gp.gates:
			var gl := ceili(Gates.left(gp, str(gid)))
			parts.append("hạng %s ở %s (còn %d:%02d)" % [str(gp.gates[gid].rank), str(Maps.MAPS[str(gid)].name), gl / 3600, (gl / 60) % 60])
		gtxt = "Cổng dungeon đang mở: " + ", ".join(parts) + "."
	var gl_lbl := UiTheme.label(gtxt + (" Đã dọn %d cổng%s." % [int(gp.gates_cleared), (", cao nhất hạng " + str(gp.gate_best)) if str(gp.gate_best) != "" else ""] if int(gp.gates_cleared) > 0 else ""), "Small", W)
	gl_lbl.name = "GateInfo"
	gl_lbl.add_theme_color_override("font_color", UiTheme.GOLD if not gp.gates.is_empty() else UiTheme.MUTED)
	content.add_child(gl_lbl)
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
		var name := UiTheme.label("%s%s (%d–%d)%s%s" % ["● " if here else ("◆ " if unlocked else ""), m.name, m.levels[0], m.levels[1],
			(" · %d%%" % floori(world.explore_ratio(m_id) * 100.0)) if unlocked or here else "",
			(" · ⚔ Cổng %s" % Gates.rank_of(world.profile, m_id)) if world.profile.gates.has(m_id) else ""], "Small", 150)
		name.size_flags_horizontal = SIZE_EXPAND_FILL
		row.add_child(name)
		if not here:
			var b := UiTheme.button("Lên đường")
			b.name = "Travel_" + m_id
			b.add_theme_font_size_override("font_size", 12)
			var at_wp: bool = world.at_waypoint()
			b.disabled = block != "" or not unlocked or not at_wp
			if block != "":
				b.tooltip_text = block
			elif not unlocked:
				b.tooltip_text = "Lần đầu phải đi bộ qua cổng ở rìa map."
			elif not at_wp:
				b.tooltip_text = "Tới Cổng Dịch Chuyển trong vùng an toàn để đi nhanh."
			else:
				b.tooltip_text = world.challenge_warning(m_id)
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
