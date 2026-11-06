extends PanelContainer
## SN11-01, SN11-02 (Spec_Notes đợt 11): thẻ thông tin trang bị khi rê chuột.
## - Đồ đang mặc: 1 thẻ "ĐANG MẶC".
## - Đồ trong túi: thẻ "ĐANG XEM" (kèm dòng so sánh ▲/▼ với đồ cùng ô) + thẻ "ĐANG MẶC" bên cạnh — như các game nhập vai.
## top_level: nổi trên bảng, đặt cạnh con trỏ, không ra khỏi màn hình; không chặn chuột.

const UiTheme = preload("res://scripts/ui/ui_theme.gd")
const Items = preload("res://scripts/core/items.gd")
const ItemCard = preload("res://scripts/ui/item_card.gd")
const ItemData = preload("res://scripts/data/items.gd")

const CARD_W := 290.0
const UP := Color("#5bd16a")
const DOWN := Color("#ff6a6a")


## UI-63: bảng màu mù màu → lam / cam (mũi tên ▲ ▼ vẫn giữ để không chỉ dựa vào màu).
static func _up() -> Color:
	return UiTheme.GOOD_CB if UiTheme.colorblind else UP


static func _down() -> Color:
	return UiTheme.BAD_CB if UiTheme.colorblind else DOWN


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
		out.append(["%s %s %s" % ["▲" if d > 0.0 else "▼", num, ItemData.AFFIXES[k].name], _up() if d > 0.0 else _down()])
	if world != null:
		var dp: int = world.power_if_equipped(item) - world.combat_power()
		if dp != 0:
			out.append(["%s %d Lực chiến" % ["▲" if dp > 0 else "▼", absi(dp)], _up() if dp > 0 else _down()])
	return out


## Một thẻ (UI-65, docs/42): khung tối viền màu phẩm chất bọc ItemCard.build — dải đầu nhuộm màu, icon lớn, tên,
## chỉ số chính số to, dòng phụ có biểu tượng, bộ, hiệu ứng riêng; worn ≠ {} / compare thì thêm phần so sánh (chip ▲ ▼).
static func card(world, item: Dictionary, header: String, worn := {}, compare := false) -> PanelContainer:
	var c := Items.rarity_color(item)
	var pc := PanelContainer.new()
	var sb := UiTheme.box(Color(0.055, 0.04, 0.03, 0.97), 8, 2, c.darkened(0.1), 6)
	sb.shadow_color = Color(0, 0, 0, 0.55)
	sb.shadow_size = 8
	pc.add_theme_stylebox_override("panel", sb)
	pc.mouse_filter = MOUSE_FILTER_IGNORE
	var diff: Array = diff_lines(world, item, worn) if compare else []
	var title := ""
	if compare:
		title = "So với đang mặc:" if not worn.is_empty() else "Ô này đang trống — mặc vào:"
	pc.add_child(ItemCard.build(item, CARD_W, header, world.profile if world != null else null, diff, title))
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
