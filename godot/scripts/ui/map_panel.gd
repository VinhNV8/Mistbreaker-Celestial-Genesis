extends "res://scripts/ui/modal.gd"
## Bản đồ khai phá: dọn sương mù, chiếm ô đất, nâng cấp trại.

signal nest_started

const Config = preload("res://scripts/core/config.gd")
const Explore = preload("res://scripts/core/explore.gd")
const HexMap = preload("res://scripts/ui/hex_map.gd")

const CLAIM_LABEL := {
	"resource": "Xây Xưởng Gỗ (%d vàng)",
	"nest": "Chinh phục (gọi quái tinh anh ra)",
	"relic": "Mở rương di tích",
	"survivor": "Mời gia nhập lãnh địa",
	"wonder": "Chiếm Kỳ quan",
}

var _selected := 0


func _render(content: VBoxContainer) -> void:
	var p = world.profile
	content.custom_minimum_size.x = 820
	_header(content, "Bản đồ khai phá · Rừng Sương", "Đóng (M)")

	var owned := Explore.owned_count(p.tiles)
	var total := Explore.explore_total(p.tiles)
	var rate := Explore.production_per_minute(p)
	var summary := "Khai phá %d/%d ô (%d%% · cần %d%% để mở hang Sói Chúa)     Đuốc %d · Vàng %d · Gỗ %d     Sản lượng +%.1f vàng, +%.1f gỗ / phút" % [
		owned, total, roundi(100.0 * owned / total), roundi(Config.EXPLORE_REQ * 100), p.torches, int(p.gold), int(p.wood), rate.gold, rate.wood
	]
	content.add_child(UiTheme.label(summary, "Muted", 790))

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
	var kinds := [["camp2", "+20% sản lượng"], ["temple", "luyện cấp Thiên phú (phím T)"]]
	if p.talent == "long-mach":
		kinds.append(["dragon", "+10% Tấn công và HP cho nhân vật, đồng minh"])
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
			text = "%s — %s. %d vàng + %d gỗ, %d giây" % [def.name, k[1], def.gold, def.wood, roundi(Explore.build_time(p, kind))]
		var l := UiTheme.label(text, "Small", 250)
		if Explore.is_built(p, kind):
			l.add_theme_color_override("font_color", UiTheme.GOOD)
		row.add_child(l)
		if not Explore.is_started(p, kind):
			var b := UiTheme.button("Xây")
			b.disabled = p.gold < def.gold or p.wood < def.wood
			b.pressed.connect(func():
				world.build(kind)
				refresh())
			row.add_child(b)
		info.add_child(row)


func _on_tile(id: int) -> void:
	_selected = id
	refresh()


func _tile_info(info: VBoxContainer, t: Dictionary) -> void:
	var p = world.profile
	var ev: Dictionary = Explore.EVENT_INFO[t.event]
	if t.status == "fog":
		info.add_child(UiTheme.label("Ô đất bị sương mù che", "Heading"))
		if Explore.is_event_visible(p.tiles, t, p.talent):
			var eagle := UiTheme.label("Mắt Ưng nhìn thấy: %s" % ev.name, "", 330)
			eagle.add_theme_color_override("font_color", Color("#9ec8ff"))
			info.add_child(eagle)
		info.add_child(UiTheme.label("Dùng 1 Đuốc Khai Giới để dọn sương. Mỗi ô dọn được cho EXP.", "Muted", 330))
		var blocker := Explore.reveal_blocker(p, t)
		var b := UiTheme.button("Dùng Đuốc (còn %d)" % p.torches, true)
		b.size_flags_horizontal = SIZE_SHRINK_BEGIN
		b.disabled = blocker != ""
		b.pressed.connect(func():
			world.reveal_tile(_selected)
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
	info.add_child(UiTheme.label(ev.desc, "", 330))
	if t.event == "resource" and t.status == "owned":
		var key := "lumber_%d" % int(t.id)
		var state := "Xưởng Gỗ đang hoạt động." if Explore.is_built(p, key) else "Xưởng Gỗ đang xây, còn %d giây." % ceili(Explore.remaining(p, key))
		info.add_child(UiTheme.label(state, "Muted", 330))
	if t.status != "revealed":
		return
	if world.nest_active(int(t.id)):
		info.add_child(_warn("Quái tinh anh đang chờ bạn ngoài Rừng Sương."))
		return
	var label: String = CLAIM_LABEL.get(t.event, "Chiếm")
	if t.event == "resource":
		label = label % Config.LUMBER_COST_GOLD
	var claim := UiTheme.button(label, true)
	claim.size_flags_horizontal = SIZE_SHRINK_BEGIN
	claim.pressed.connect(_on_claim)
	info.add_child(claim)


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
