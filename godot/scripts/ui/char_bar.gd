extends RefCounted
## UI-28/28b: thanh tiêu đề chung của nhóm bảng Nhân vật — Túi đồ (tab Thuộc tính / Trang bị / Tài nguyên),
## Kỹ năng, Thiên phú. Cả 3 bảng dùng cùng thanh nên chuyển qua lại được từ bất kỳ bảng nào.
## Mảnh vẽ cắt từ ảnh mẫu (tools/art/ui_cut.py topbar).

const UiTheme = preload("res://scripts/ui/ui_theme.gd")
const Ornate = preload("res://scripts/ui/ornate.gd")
const ItemData = preload("res://scripts/data/items.gd")

## [id, tên]. stats / bag / res là tab của Túi đồ; skills / talent là bảng riêng (U / T).
const TABS := [["stats", "Thuộc tính"], ["bag", "Trang bị"], ["res", "Tài nguyên"], ["skills", "Kỹ năng"], ["talent", "Thiên phú"]]
const TIPS := {"stats": "Thuộc tính (C)", "bag": "Trang bị · túi đồ (I)", "res": "Tài nguyên", "skills": "Kỹ năng (U)", "talent": "Thiên phú (T)"}


## active: id tab đang mở. on_pick(id): bấm tab (hoặc nút + → "res"). on_close: nút quay lại / X.
## Nút quay lại · "Nhân Vật" · tab chữ (tab chọn nền vàng sáng + hình thoi dưới; tab khác chỉ chữ, rê chuột sáng nhẹ)
## ngăn bằng vạch mảnh · Vàng, Tinh Thạch · nút + · nút X.
static func build(world, active: String, on_pick: Callable, on_close: Callable) -> PanelContainer:
	var p = world.profile
	var bar := UiTheme.panel(Ornate.style("ui-topbar", 0, 0, 0, 0, Vector4.ZERO))
	bar.name = "TopBar"
	Ornate.linear(bar)
	var row := UiTheme.hbox(0)
	bar.add_child(row)
	var back := Ornate.image_button("ui-topbar-back", 68, 57)
	back.name = "BackButton"
	back.tooltip_text = "Quay lại"
	back.pressed.connect(on_close)
	row.add_child(back)
	var title := UiTheme.panel(Ornate.style("ui-topbar-title", 0, 0, 0, 0, Vector4.ZERO))
	title.custom_minimum_size = Vector2(143, 57)
	var tl := UiTheme.strong("Nhân Vật", 24, Color("#e9cc99"))
	tl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.add_child(tl)
	row.add_child(title)
	var on_style := Ornate.style("ui-tab-active", 0, 0, 0, 0, Vector4.ZERO)
	var hover := on_style.duplicate() as StyleBoxTexture
	hover.modulate_color = Color(1, 1, 1, 0.35)
	for t in TABS:
		var key: String = t[0]
		var on := active == key
		var tb := Button.new()
		tb.name = "Tab_" + key
		tb.text = t[1]
		tb.focus_mode = Control.FOCUS_NONE
		tb.custom_minimum_size = Vector2(127, 57)
		tb.tooltip_text = TIPS[key] + ((" · %d/%d ô" % [p.inventory.size(), ItemData.BAG_SIZE]) if key == "bag" else "")
		tb.add_theme_font_size_override("font_size", UiTheme.fs(17))
		for e in [["normal", on_style if on else StyleBoxEmpty.new()], ["hover", on_style if on else hover], ["pressed", on_style],
				["hover_pressed", on_style], ["focus", StyleBoxEmpty.new()]]:
			tb.add_theme_stylebox_override(e[0], e[1])
		tb.add_theme_color_override("font_color", Color("#ede9de") if on else Color("#c3ae92"))
		tb.add_theme_color_override("font_hover_color", Color("#ede9de") if on else Color("#e8d6b4"))
		tb.add_theme_color_override("font_pressed_color", Color("#ede9de"))
		tb.pressed.connect(func():
			if not on:
				on_pick.call(key))
		row.add_child(tb)
		row.add_child(Ornate.image("ui-tab-sep", 5, 57))
	row.add_child(UiTheme.spacer())
	# tiền: Vàng · Tinh Thạch (số có dấu chấm ngăn nghìn)
	for c in [["ui-coin", int(p.gold), "Vàng"], ["ui-gem", int(p.crystal), "Tinh Thạch"]]:
		var ic := Ornate.image(c[0], 28, 28)
		ic.tooltip_text = c[2]
		row.add_child(ic)
		row.add_child(_gap(6))
		var cl := UiTheme.strong(Ornate.group(c[1]), 16, Color("#c9b8a0"))
		cl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		cl.tooltip_text = c[2]
		cl.mouse_filter = Control.MOUSE_FILTER_PASS
		row.add_child(cl)
		row.add_child(_gap(26))
	var plus := Ornate.image_button("ui-topbar-plus", 32, 32)
	plus.name = "CurrencyPlus"
	plus.tooltip_text = "Xem tài nguyên"
	plus.pressed.connect(func():
		if active != "res":
			on_pick.call("res"))
	row.add_child(plus)
	row.add_child(_gap(24))
	var x := Ornate.image_button("ui-topbar-close", 75, 57)
	x.name = "CloseButton"
	x.tooltip_text = "Đóng (Esc)"
	x.pressed.connect(on_close)
	row.add_child(x)
	return bar


static func _gap(w: float) -> Control:
	var c := Control.new()
	c.custom_minimum_size.x = w
	return c
