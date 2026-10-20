extends RefCounted
## SN-10…12: khung "Phân rã nhanh" (túi đồ) / "Bán nhanh" (cửa hàng) với bộ lọc dùng chung.
## Bộ lọc lưu trong save (profile.bulk_filter). Bấm nút lần 1 → hỏi xác nhận; lần 2 → thực hiện.

const UiTheme = preload("res://scripts/ui/ui_theme.gd")
const ItemData = preload("res://scripts/data/items.gd")
const Items = preload("res://scripts/core/items.gd")
const GameWorld = preload("res://scripts/core/game_world.gd")

## Trạng thái đang hỏi xác nhận, theo chế độ ("salvage" | "sell"). Đổi bộ lọc thì huỷ hỏi.
static var confirming := {}


## mode: "salvage" | "sell". refresh: Callable dựng lại bảng. width: bề rộng khung.
static func build(world, mode: String, refresh: Callable, width := 390.0) -> VBoxContainer:
	var col := UiTheme.vbox(6)
	col.custom_minimum_size.x = width
	var p = world.profile
	var f: Dictionary = world.bulk_filter()
	col.add_child(UiTheme.label("PHÂN RÃ NHANH" if mode == "salvage" else "BÁN NHANH", "Eyebrow"))

	# phẩm chất: nút bật/tắt theo màu
	var rr := UiTheme.hbox(4)
	for r in ItemData.RARITY_ORDER:
		var on: bool = r in f.rarities
		var c := Color(ItemData.RARITIES[r].color)
		var b := UiTheme.button(ItemData.RARITIES[r].name)
		b.name = "Rarity_" + r
		b.toggle_mode = true
		b.button_pressed = on
		b.add_theme_font_size_override("font_size", 12)
		b.add_theme_color_override("font_color", c if on else UiTheme.MUTED)
		b.add_theme_color_override("font_pressed_color", c)
		b.add_theme_stylebox_override("normal", UiTheme.box(Color(c, 0.06), 6, 1, Color(c, 0.35), 5))
		b.add_theme_stylebox_override("pressed", UiTheme.box(Color(c, 0.25), 6, 2, c, 5))
		var rid: String = r
		b.toggled.connect(func(v: bool):
			var nf: Dictionary = world.bulk_filter()
			if v and not (rid in nf.rarities):
				nf.rarities.append(rid)
			elif not v:
				nf.rarities.erase(rid)
			_changed(world, nf, refresh))
		rr.add_child(b)
	col.add_child(rr)

	for opt in [["keep_plus", "Giữ đồ đã cường hoá"], ["keep_set", "Giữ đồ bộ"], ["only_weaker", "Chỉ đồ yếu hơn đồ đang mặc"]]:
		var cb := CheckBox.new()
		cb.name = "Opt_" + opt[0]
		cb.text = opt[1]
		cb.button_pressed = bool(f[opt[0]])
		cb.add_theme_font_size_override("font_size", 13)
		var key: String = opt[0]
		cb.toggled.connect(func(v: bool):
			var nf: Dictionary = world.bulk_filter()
			nf[key] = v
			_changed(world, nf, refresh))
		col.add_child(cb)

	var items: Array = world.bulk_list()
	var gain := 0
	for it in items:
		gain += Items.salvage_value(it, p) if mode == "salvage" else GameWorld.sell_price(it)
	var unit := "đá" if mode == "salvage" else "vàng"
	var verb := "Phân rã nhanh" if mode == "salvage" else "Bán nhanh"
	if bool(confirming.get(mode, false)) and not items.is_empty():
		col.add_child(UiTheme.label("%s %d món (+%d %s)? Không hoàn tác được." % [verb, items.size(), gain, unit], "", width))
		var row := UiTheme.hbox(8)
		var yes := UiTheme.button("Đồng ý", true)
		yes.name = "BulkConfirm"
		yes.pressed.connect(func():
			confirming[mode] = false
			if mode == "salvage":
				world.salvage_many(world.bulk_list())
			else:
				world.sell_many(world.bulk_list())
			refresh.call())
		row.add_child(yes)
		var no := UiTheme.button("Huỷ")
		no.pressed.connect(func():
			confirming[mode] = false
			refresh.call())
		row.add_child(no)
		col.add_child(row)
	else:
		confirming[mode] = false
		var go := UiTheme.button("%s %d món (+%d %s)" % [verb, items.size(), gain, unit], true)
		go.name = "BulkButton"
		go.disabled = items.is_empty()
		go.pressed.connect(func():
			confirming[mode] = true
			refresh.call())
		col.add_child(go)
	return col


static func _changed(world, nf: Dictionary, refresh: Callable) -> void:
	world.set_bulk_filter(nf)
	confirming.clear()
	refresh.call_deferred()


## Id các món khớp bộ lọc (để tô đánh dấu trong lưới túi).
static func marked_ids(world) -> Dictionary:
	var out := {}
	for it in world.bulk_list():
		out[int(it.id)] = true
	return out
