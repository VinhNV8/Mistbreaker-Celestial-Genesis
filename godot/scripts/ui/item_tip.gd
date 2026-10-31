extends PanelContainer
## SN11-01, SN11-02 (Spec_Notes đợt 11): thẻ thông tin trang bị khi rê chuột.
## - Đồ đang mặc: 1 thẻ "ĐANG MẶC".
## - Đồ trong túi: thẻ "ĐANG XEM" (kèm dòng so sánh ▲/▼ với đồ cùng ô) + thẻ "ĐANG MẶC" bên cạnh — như các game nhập vai.
## top_level: nổi trên bảng, đặt cạnh con trỏ, không ra khỏi màn hình; không chặn chuột.

const UiTheme = preload("res://scripts/ui/ui_theme.gd")
const Items = preload("res://scripts/core/items.gd")
const ItemData = preload("res://scripts/data/items.gd")

const CARD_W := 270.0
const UP := Color("#5bd16a")
const DOWN := Color("#ff6a6a")


## Dòng chênh lệch giữa 2 món (đồ đang xem đã tính cấp cường hoá nhận khi mặc) — [[chữ, màu], ...].
static func diff_lines(world, item: Dictionary, worn: Dictionary) -> Array:
	var it := item.duplicate()
	if world != null:
		it.plus = Items.plus_after_equip(world.profile, item)
	var a := Items.item_stats(it)
	var b := Items.item_stats(worn) if not worn.is_empty() else {}
	var keys: Array = []
	for k in a:
		keys.append(k)
	for k in b:
		if not keys.has(k):
			keys.append(k)
	var out: Array = []
	for k in keys:
		var d: float = float(a.get(k, 0.0)) - float(b.get(k, 0.0))
		var pct: bool = k in ItemData.PERCENT_STATS
		if absf(d) < (0.0005 if pct else 0.5):
			continue
		var num := ("%.1f%%" % absf(d * 100.0)) if pct else ("%d" % roundi(absf(d)))
		out.append(["%s %s %s" % ["▲" if d > 0.0 else "▼", num, ItemData.AFFIXES[k].name], UP if d > 0.0 else DOWN])
	if world != null:
		var dp: int = world.power_if_equipped(item) - world.combat_power()
		if dp != 0:
			out.append(["%s %d Lực chiến" % ["▲" if dp > 0 else "▼", absi(dp)], UP if dp > 0 else DOWN])
	return out


## Một thẻ: tiêu đề nhỏ, tên, phẩm chất · ô · cấp, chỉ số gốc + dòng phụ, hiệu ứng riêng, bộ; worn ≠ {} thì thêm phần so sánh.
static func card(world, item: Dictionary, header: String, worn := {}, compare := false) -> PanelContainer:
	var c := Items.rarity_color(item)
	var pc := PanelContainer.new()
	pc.add_theme_stylebox_override("panel", UiTheme.box(Color(0.06, 0.045, 0.03, 0.97), 8, 2, c, 10))
	pc.mouse_filter = MOUSE_FILTER_IGNORE
	var v := UiTheme.vbox(3)
	v.custom_minimum_size.x = CARD_W
	pc.add_child(v)
	var h := UiTheme.label(header, "Small")
	h.add_theme_color_override("font_color", UiTheme.GOLD if header == "ĐANG MẶC" else UiTheme.MUTED)
	v.add_child(h)
	var t := UiTheme.label(Items.display_name(item), "", CARD_W)
	t.add_theme_color_override("font_color", c)
	t.add_theme_font_size_override("font_size", 17)
	v.add_child(t)
	v.add_child(UiTheme.label("%s · %s · Cấp %d" % [ItemData.RARITIES[item.rarity].name, ItemData.SLOTS[item.slot].name, int(item.level)], "Small"))
	v.add_child(UiTheme.label(Items.base_text(item) + "  (gốc)", "", CARD_W))
	for af in item.affixes:
		var l := UiTheme.label(Items.stat_text(af.stat, af.value), "", CARD_W)
		l.add_theme_color_override("font_color", Color("#9ec8ff"))
		v.add_child(l)
	if str(item.unique) != "":
		var u := UiTheme.label(str(ItemData.UNIQUES[item.unique].text), "Small", CARD_W)
		u.add_theme_color_override("font_color", c)
		v.add_child(u)
	if str(item.set) != "":
		var s := UiTheme.label(str(ItemData.SETS[item.set].get("name", item.set)), "Small", CARD_W)
		s.add_theme_color_override("font_color", Color("#7ad65a"))
		v.add_child(s)
	if compare:
		v.add_child(HSeparator.new())
		var lines := diff_lines(world, item, worn)
		v.add_child(UiTheme.label("So với đang mặc:" if not worn.is_empty() else "Ô này đang trống — mặc vào:", "Small"))
		if lines.is_empty():
			v.add_child(UiTheme.label("Chỉ số như nhau", "Small"))
		for ln in lines:
			var dl := UiTheme.label(str(ln[0]), "", CARD_W)
			dl.add_theme_color_override("font_color", ln[1])
			v.add_child(dl)
	return pc


## Khung nổi cho một món: đồ trong túi → [ĐANG XEM + so sánh][ĐANG MẶC]; đồ đang mặc → [ĐANG MẶC].
static func make(world, item: Dictionary, in_bag: bool) -> Control:
	var tip = load("res://scripts/ui/item_tip.gd").new()
	tip.name = "ItemTip"
	tip.top_level = true
	tip.z_index = 90
	tip.mouse_filter = MOUSE_FILTER_IGNORE
	tip.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	var row := UiTheme.hbox(8)
	row.mouse_filter = MOUSE_FILTER_IGNORE
	tip.add_child(row)
	if in_bag:
		var worn: Dictionary = world.profile.equipment.get(str(item.slot), {})
		row.add_child(card(world, item, "ĐANG XEM", worn, true))
		if not worn.is_empty():
			row.add_child(card(world, worn, "ĐANG MẶC"))
	else:
		row.add_child(card(world, item, "ĐANG MẶC"))
	return tip


## Đặt khung cạnh con trỏ (bên phải, dưới), lật lại nếu tràn màn hình.
func place(mouse: Vector2) -> void:
	var vp := get_viewport_rect().size if is_inside_tree() else Vector2(1366, 768)
	var sz := get_combined_minimum_size()
	var pos := mouse + Vector2(18, 12)
	if pos.x + sz.x > vp.x - 8:
		pos.x = mouse.x - sz.x - 18
	if pos.y + sz.y > vp.y - 8:
		pos.y = vp.y - sz.y - 8
	global_position = Vector2(maxf(8.0, pos.x), maxf(8.0, pos.y))
