extends "res://scripts/ui/modal.gd"
## Bản đồ khai phá: dọn sương mù, chiếm ô đất, nâng cấp trại.

signal nest_started

const Endgame = preload("res://scripts/core/endgame.gd")
const Config = preload("res://scripts/core/config.gd")
const Explore = preload("res://scripts/core/explore.gd")
const HexMap = preload("res://scripts/ui/hex_map.gd")
const Maps = preload("res://scripts/data/maps.gd")

const CLAIM_LABEL := {
	"resource": "Xây Xưởng Gỗ (%d vàng)",
	"nest": "Chinh phục (gọi quái tinh anh ra)",
	"relic": "Phá khoá rương (thưởng thường)",
	"survivor": "Mời gia nhập lãnh địa",
	"wonder": "Chiếm Kỳ quan",
	"merchant": "Mời thương nhân về làng",
	"mine": "Xây Mỏ (40 vàng, 40 gỗ)",
	"fishery": "Xây Bến Cá (30 vàng, 30 gỗ)",
	"vein": "Khai thác Mạch Tinh Thạch (+10 Tinh Thạch)",
}

var _selected := 0


func _render(content: VBoxContainer) -> void:
	var p = world.profile
	content.custom_minimum_size.x = 820
	var region := int(p.tiles_region)
	var reg_info: Dictionary = Maps.region(region)
	var reg_title: String = str(reg_info.get("name", "Vùng %d" % region))
	_header(content, "Bản đồ khai phá · %s" % reg_title, "Đóng (M)")

	var owned := Explore.owned_count(p.tiles)
	var total := Explore.explore_total(p.tiles)
	var rate := Explore.production_per_minute(p)
	# Spec_Notes N10: thông tin tách 2 dòng ngắn, không chồng lên lưới.
	var summary := "Lãnh địa %d/%d ô · Đuốc %d · Mỗi phút (mọi vùng): +%.1f vàng, +%.1f gỗ, +%.1f Đá, +%.1f Sắt" % [
		owned, total, p.torches, rate.gold, rate.wood, rate.ore, rate.iron
	]
	if region == 1:
		summary += " · Mở hang Sói Chúa: cấp %d + chiếm %d ô" % [Config.BOSS_LEVEL_REQ, Config.BOSS_TILES_REQ]
	elif region == 2:
		summary += " · Hạng Liên minh: %s · Bến Cá +%d%% HP" % [world.alliance_rank(), roundi(Explore.fishery_hp_pct(p) * 100)]
	content.add_child(UiTheme.label(summary, "Muted", 790))
	var zones := PackedStringArray()
	for z in [1, 2, 3]:
		var n: int = p.tiles.filter(func(t): return t.event != "camp" and Explore.zone_of(t) == z).size()
		var zname: String = Explore.zone_name(region, z)
		if zname == "":
			zname = "Khu %d" % z
		zones.append("%s %d/%d%s" % [zname, Explore.zone_owned(p.tiles, z), n,
			" (khoá — hạ Sói Chúa)" if region == 1 and z == 3 and not p.boss_defeated else ""])
	content.add_child(UiTheme.label("   ·   ".join(zones), "Small", 790))

	var body := UiTheme.hbox(20)
	var map := HexMap.new()
	map.profile = p
	map.selected = _selected
	map.tile_pressed.connect(_on_tile)
	body.add_child(map)

	var info := UiTheme.vbox(10)
	info.custom_minimum_size.x = 330
	_tile_info(info, Explore.find_tile(p, _selected))
	info.add_child(HSeparator.new())
	_buildings(info, p)
	body.add_child(info)
	content.add_child(body)


## TL-22: mục Công trình — Thôn, Đền Thiên Phú, Long Mạch Đàn.
func _buildings(info: VBoxContainer, p) -> void:
	info.add_child(UiTheme.label("CÔNG TRÌNH", "Eyebrow"))
	# C7-02 / C7-04: trung tâm lãnh địa hiện cấp; chỉ liệt kê bậc nâng kế tiếp + Cảng Khí Cầu khi đã Hoàng Thành.
	info.add_child(UiTheme.label("Trung tâm: %s · %d ô đã chiếm" % [Explore.camp_name(p), Explore.total_owned(p)], "Small", 320))
	var kinds := []
	var next_camp := "camp%d" % (int(p.camp_level) + 1)
	if Explore.BUILDINGS.has(next_camp):
		kinds.append([next_camp, "+%d%% sản lượng" % roundi(Explore.CAMP_BONUS[int(p.camp_level) + 1] * 100.0)])
	elif int(p.camp_level) >= 5:
		kinds.append(["port", "mở Bến Khí Cầu tới Quần Đảo Thiên Không"])
	kinds += [["temple", "luyện cấp Thiên phú (phím T)"],
		["forge", "chế trang bị (phím E ở làng)"], ["garden", "1 thảo dược mỗi 3 phút, cả khi offline"]]
	if Explore.TalentSlots.has(p, "long-mach"):
		kinds.append(["dragon", "+10% Tấn công và HP cho nhân vật, đồng minh"])
	# C9-52 (M12): Tái Thiết Lục Địa — công trình của vùng đang xem (sau kết thúc Hiến tế).
	if str(p.ending) == "hien-te" and Explore.BUILDINGS.has("rebuild%d" % int(p.tiles_region)):
		var rk := int(p.tiles_region)
		kinds.append(["rebuild%d" % rk, "Tái Thiết: " + str(Endgame.REBUILD_TEXT[rk]) + (" · cần 2 Lõi Hư Vô" if rk >= 8 else "")])
	for k in kinds:
		var kind: String = k[0]
		var def: Dictionary = Explore.BUILDINGS[kind]
		var row := UiTheme.hbox(8)
		var text: String
		if Explore.is_built(p, kind):
			text = "✓ %s — %s" % [def.name, k[1]]
		elif Explore.is_started(p, kind):
			text = "%s — đang xây, còn %d giây" % [def.name, ceili(Explore.remaining(p, kind))]
		else:
			text = "%s — %s. %s, %d giây" % [def.name, k[1], Explore.cost_text(kind), roundi(Explore.build_time(p, kind))]
			if int(def.get("tiles", 0)) > 0:
				text += " · cần %d ô" % int(def.tiles)
		var l := UiTheme.label(text, "Small", 250)
		if Explore.is_built(p, kind):
			l.add_theme_color_override("font_color", UiTheme.GOOD)
		row.add_child(l)
		if not Explore.is_started(p, kind):
			var b := UiTheme.button("Xây")
			b.disabled = Explore.build_blocker(p, kind) != ""
			b.tooltip_text = Explore.build_blocker(p, kind)
			b.pressed.connect(func():
				world.build(kind)
				refresh())
			row.add_child(b)
		info.add_child(row)


func _on_tile(id: int) -> void:
	_selected = id
	refresh()


func _tile_info(info: VBoxContainer, t: Dictionary) -> void:
	if t.is_empty():
		info.add_child(UiTheme.label("Chưa chọn ô đất", "Heading"))
		info.add_child(UiTheme.label("Bấm vào một ô trên bản đồ bên trái để xem chi tiết.", "Muted", 330))
		return
	var p = world.profile
	var ev: Dictionary = Explore.EVENT_INFO.get(t.event, {})
	if ev.is_empty():
		info.add_child(UiTheme.label("Ô đất không xác định", "Heading"))
		return
	var zname: String = Explore.zone_name(int(p.tiles_region), Explore.zone_of(t))
	if zname != "":
		info.add_child(UiTheme.label(zname.to_upper(), "Eyebrow"))
	if t.status == "fog":
		info.add_child(UiTheme.label("Ô đất bị sương mù che", "Heading"))
		if Explore.event_visible(p, t):
			var eagle := UiTheme.label("Mắt Ưng nhìn thấy: %s" % ev.name, "", 330)
			eagle.add_theme_color_override("font_color", Color("#9ec8ff"))
			info.add_child(eagle)
		info.add_child(UiTheme.label("Dùng 1 Đuốc Khai Giới để dọn sương. Mỗi ô dọn được cho EXP.", "Muted", 330))
		var blocker := Explore.reveal_blocker(p, t)
		var b := UiTheme.button("Dùng Đuốc (còn %d)" % p.torches, true)
		b.size_flags_horizontal = SIZE_SHRINK_BEGIN
		b.disabled = blocker != ""
		if blocker != "":
			b.tooltip_text = blocker
		var tid: int = int(t.id)
		b.pressed.connect(func():
			world.reveal_tile(tid)
			refresh())
		info.add_child(b)
		if blocker != "":
			info.add_child(_warn(blocker))
		return

	info.add_child(UiTheme.label(ev.name, "Heading"))
	var tag := UiTheme.label("Đã thuộc lãnh địa" if t.status == "owned" else "Đã dọn sương", "Small")
	if t.status == "owned":
		tag.add_theme_color_override("font_color", UiTheme.GOOD)
	info.add_child(tag)

	var desc_text: String = ev.desc
	if t.status == "owned":
		if t.event == "nest":
			desc_text = "Đã tiêu diệt quái tinh anh canh giữ. Ô đất đã thuộc về lãnh địa của bạn."
		elif t.event == "relic":
			desc_text = "Rương di tích đã được mở và thu thập báu vật."
	info.add_child(UiTheme.label(desc_text, "", 330))

	var bkind: String = {"resource": "lumber", "mine": "mine", "fishery": "fishery"}.get(t.event, "")
	if bkind != "" and t.status == "owned":
		var key := Explore.tile_key(bkind, t, int(p.tiles_region))
		var bname: String = Explore.BUILDINGS[bkind].name
		var state: String
		if Explore.is_built(p, key):
			state = "%s đang hoạt động." % bname
		elif Explore.is_started(p, key):
			state = "%s đang xây, còn %d giây." % [bname, ceili(Explore.remaining(p, key))]
		else:
			state = "%s chưa được xây dựng." % bname
		info.add_child(UiTheme.label(state, "Muted", 330))

	if t.status != "revealed":
		return

	if world.nest_active(int(t.id)):
		var map_name: String = str(world.map.get("name", "chiến trường"))
		info.add_child(_warn("Quái tinh anh đang chờ bạn ngoài %s." % map_name))
		return

	if t.event == "relic":
		_relic_ui(info, int(t.id))
		var rlock: float = world.relic_locked(int(t.id))
		var bypass_b := UiTheme.button("Bỏ qua câu đố: Phá khoá rương (thưởng thường)", false)
		bypass_b.size_flags_horizontal = SIZE_SHRINK_BEGIN
		bypass_b.disabled = rlock > 0.0
		if rlock > 0.0:
			bypass_b.tooltip_text = "Cơ quan rương đang khoá, không thể phá khoá lúc này."
		else:
			bypass_b.tooltip_text = "Mở rương ngay mà không cần giải câu đố (chỉ nhận vàng thông thường, không có Đá Cường Hoá và thưởng EXP ×2)."
		bypass_b.pressed.connect(_on_claim)
		info.add_child(bypass_b)
		return

	var blocker := Explore.claim_blocker(p, t)
	var label: String = CLAIM_LABEL.get(t.event, "Chiếm")
	if t.event == "resource":
		label = label % Config.LUMBER_COST_GOLD
	var claim := UiTheme.button(label, true)
	claim.size_flags_horizontal = SIZE_SHRINK_BEGIN
	claim.disabled = blocker != ""
	if blocker != "":
		claim.tooltip_text = blocker
	claim.pressed.connect(_on_claim)
	info.add_child(claim)
	if blocker != "":
		info.add_child(_warn(blocker))


## M5-04 (KP-04): câu đố mở rương Di tích — giải được thì thưởng gấp đôi + 1 Đá Cường Hoá.
func _relic_ui(info: VBoxContainer, id: int) -> void:
	var pz: Dictionary = world.relic_puzzle(id)
	info.add_child(HSeparator.new())
	if pz.kind == "lights":
		info.add_child(UiTheme.label("TRẬN ĐÈN CỔ", "Eyebrow"))
		info.add_child(UiTheme.label("Bấm một bùa thì nó và các bùa kề bên đảo sáng/tối. Thắp đủ 9 bùa để mở rương (thưởng ×2).", "Muted", 330))
		var grid := GridContainer.new()
		grid.columns = 3
		grid.add_theme_constant_override("h_separation", 6)
		grid.add_theme_constant_override("v_separation", 6)
		for i in pz.cells.size():
			var lit: bool = pz.cells[i]
			var b := UiTheme.button("✦" if lit else "·", lit)
			b.name = "Rune_%d" % i
			b.custom_minimum_size = Vector2(56, 44)
			var idx: int = i
			b.pressed.connect(func():
				world.relic_press(id, idx)
				refresh())
			grid.add_child(b)
		info.add_child(grid)
		info.add_child(UiTheme.label("Đã bấm %d lần" % int(pz.moves), "Small"))
	else:
		info.add_child(UiTheme.label("CÂU HỎI CỔ THƯ", "Eyebrow"))
		info.add_child(UiTheme.label(str(pz.q), "", 330))
		var lock: float = world.relic_locked(id)
		for k in pz.options.size():
			var b := UiTheme.button(str(pz.options[k]))
			b.name = "Answer_%d" % k
			b.disabled = lock > 0.0
			b.size_flags_horizontal = SIZE_FILL
			var choice: int = k
			b.pressed.connect(func():
				world.relic_answer(id, choice)
				refresh())
			info.add_child(b)
		if lock > 0.0:
			info.add_child(_warn("Cơ quan rương đang khoá: còn %d giây." % ceili(lock)))
		else:
			info.add_child(UiTheme.label("Trả lời đúng: thưởng ×2. Sai: rương khoá 30 giây.", "Small", 330))


func _on_claim() -> void:
	var res: Dictionary = world.claim_tile(_selected)
	if res.ok and res.start_nest:
		close()
		nest_started.emit()
		return
	refresh()


func _warn(text: String) -> Label:
	var l := UiTheme.label(text, "", 330)
	l.add_theme_color_override("font_color", Color("#ffb27a"))
	l.add_theme_font_size_override("font_size", 13)
	return l
