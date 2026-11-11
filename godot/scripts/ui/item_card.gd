extends RefCounted
## UI-64…66 (docs/42): giao diện "xem đồ" — ô đồ theo bậc phẩm chất và thẻ thông tin trang bị dùng chung cho bảng
## chi tiết túi đồ (inventory_panel._detail) lẫn thẻ nổi khi rê chuột (item_tip).
## Quy chuẩn (docs/42 §2, nghiên cứu inventory các game nhập vai): phẩm chất đọc được KHÔNG cần rê chuột — nền ô nhuộm
## màu phẩm chất toả từ đáy + khung đổi hình theo bậc (Trắng trơn → Lục viền → Lam + đinh góc → Tím + nẹp góc vàng →
## Cam + nẹp góc + quầng sáng), không chỉ đổi màu; icon chiếm ~90% ô; thẻ thông tin có dải đầu nhuộm màu phẩm chất,
## icon lớn, tên màu phẩm chất, chỉ số chính số to kèm biểu tượng, dòng phụ có biểu tượng chỉ số, phân cách có ngọc.

const EnhanceFx = preload("res://scripts/ui/enhance_fx.gd")
const UiTheme = preload("res://scripts/ui/ui_theme.gd")
const Bronze = preload("res://scripts/ui/bronze.gd")
const Items = preload("res://scripts/core/items.gd")
const ItemData = preload("res://scripts/data/items.gd")
const SpriteLib = preload("res://scripts/view/sprite_lib.gd")
const Gear = preload("res://scripts/core/gear.gd")
const GearData = preload("res://scripts/data/gear_data.gd")
const Monsters = preload("res://scripts/data/monsters.gd")
const AWAKEN_COL := Color("#ffd36a")

## Màu nền / chữ nhạt dùng chung.
const INK := Color("#120d09")
const TEXT_DIM := Color("#b9ab8c")
const AFFIX_COL := Color("#9ec8ff")
const STAT_ICON := {"atk": "stat-atk", "max_hp": "stat-hp", "def": "stat-def", "crit": "stat-crit", "crit_dmg": "stat-critdmg",
	"atk_speed": "stat-aspd", "move_speed": "stat-move", "res_kim": "stat-res", "res_moc": "stat-res", "res_thuy": "stat-res",
	"res_hoa": "stat-res", "res_tho": "stat-res",
	# HR-1: dòng hồi phục dùng lại icon HP / Hồi MP
	"hp_on_kill": "stat-hp", "hp_regen": "stat-hp", "leech_hp": "stat-hp",
	"mp_on_kill": "stat-regen", "mp_on_hit": "stat-regen", "leech_mp": "stat-regen", "mp_regen_pct": "stat-regen"}
const TIER_LABEL := ["Thường", "Tốt", "Hiếm", "Sử thi", "Huyền thoại"]


## Bậc phẩm chất 0 (Trắng) … 4 (Cam); -1 = ô trống.
static func tier_of(item: Dictionary) -> int:
	if item.is_empty():
		return -1
	return maxi(0, ItemData.RARITY_ORDER.find(str(item.get("rarity", "white"))))


static func stat_icon(stat: String) -> Texture2D:
	return SpriteLib.icon(str(STAT_ICON.get(stat, "stat-main")))


## Nền ô đồ theo bậc (StyleBox tự vẽ — dùng cho normal / hover / pressed / disabled của Button).
class SlotBox:
	extends StyleBox
	var tier := -1
	var col := Color.WHITE
	var selected := false
	var hover := false

	func _init(t := -1, c := Color.WHITE, sel := false, hov := false) -> void:
		tier = t
		col = c
		selected = sel
		hover = hov
		content_margin_left = 3
		content_margin_right = 3
		content_margin_top = 3
		content_margin_bottom = 3

	func _sb(bg: Color, bw: float, bc: Color, center := true) -> StyleBoxFlat:
		var s := StyleBoxFlat.new()
		s.bg_color = bg
		s.draw_center = center
		s.set_corner_radius_all(6)
		s.set_border_width_all(int(bw))
		s.border_color = bc
		s.anti_aliasing = true
		return s

	func _draw(ci: RID, r: Rect2) -> void:
		var rs := RenderingServer
		# quầng sáng ngoài (Cam) / viền chọn
		if tier >= 4:
			_sb(Color.TRANSPARENT, 3, Color(col, 0.35), false).draw(ci, r.grow(2.0))
		if selected:
			_sb(Color.TRANSPARENT, 2, Color("#ffe39a"), false).draw(ci, r.grow(3.0))
		_sb(INK, 0, Color.TRANSPARENT).draw(ci, r)
		if tier >= 0:
			# nền nhuộm màu phẩm chất toả từ đáy lên
			var a: float = [0.16, 0.22, 0.28, 0.34, 0.42][tier] + (0.08 if hover else 0.0)
			var inner := r.grow(-2.0)
			var mid := inner.position.y + inner.size.y * 0.35
			var c0 := Color(col, 0.0)
			var c1 := Color(col.darkened(0.15), a)
			rs.canvas_item_add_polygon(ci, PackedVector2Array([Vector2(inner.position.x, mid), Vector2(inner.end.x, mid), inner.end,
				Vector2(inner.position.x, inner.end.y)]), PackedColorArray([c0, c0, c1, c1]))
			rs.canvas_item_add_polygon(ci, PackedVector2Array([inner.position, Vector2(inner.end.x, inner.position.y),
				Vector2(inner.end.x, mid), Vector2(inner.position.x, mid)]), PackedColorArray([Color(1, 1, 1, 0.04), Color(1, 1, 1, 0.04), c0, c0]))
			# đốm sáng đáy (ellipse)
			var ec := Vector2(inner.get_center().x, inner.end.y - inner.size.y * 0.12)
			var pts := PackedVector2Array()
			for i in 24:
				var ang := TAU * i / 24.0
				pts.append(ec + Vector2(cos(ang) * inner.size.x * 0.42, sin(ang) * inner.size.y * 0.18))
			rs.canvas_item_add_polygon(ci, pts, PackedColorArray([Color(col.lightened(0.2), a * 0.55)]))
		# gờ sáng mép trên
		rs.canvas_item_add_line(ci, r.position + Vector2(6, 1.5), Vector2(r.end.x - 6, r.position.y + 1.5), Color(1, 1, 1, 0.07), 1.0)
		# khung theo bậc
		var bw: float = [1.0, 1.0, 1.5, 2.0, 2.0, 2.5][tier + 1]
		var bc := Color("#3a2c1c") if tier <= 0 else col.darkened(0.05)
		if tier == 0:
			bc = Color("#8a8070")
		if hover:
			bc = bc.lightened(0.25)
		_sb(Color.TRANSPARENT, bw, bc, false).draw(ci, r)
		if tier >= 2:  # đinh 4 góc
			for p in [r.position + Vector2(5, 5), Vector2(r.end.x - 5, r.position.y + 5), r.end - Vector2(5, 5), Vector2(r.position.x + 5, r.end.y - 5)]:
				rs.canvas_item_add_circle(ci, p, 1.8, col.lightened(0.45))
		if tier >= 3:  # nẹp góc vàng hình chữ L
			var L := 10.0
			var g := Bronze.BR_LIGHT
			for corner in [[r.position, Vector2(1, 1)], [Vector2(r.end.x, r.position.y), Vector2(-1, 1)], [r.end, Vector2(-1, -1)],
					[Vector2(r.position.x, r.end.y), Vector2(1, -1)]]:
				var o: Vector2 = corner[0] + corner[1] * 2.0
				var d: Vector2 = corner[1]
				rs.canvas_item_add_polyline(ci, PackedVector2Array([o + Vector2(d.x * L, 0), o, o + Vector2(0, d.y * L)]),
					PackedColorArray([g]), 2.0, true)
		if tier >= 4:  # hình thoi giữa cạnh trên / dưới
			for p in [Vector2(r.get_center().x, r.position.y), Vector2(r.get_center().x, r.end.y)]:
				rs.canvas_item_add_polygon(ci, PackedVector2Array([p + Vector2(0, -3.5), p + Vector2(3.5, 0), p + Vector2(0, 3.5), p + Vector2(-3.5, 0)]),
					PackedColorArray([Bronze.BR_LIGHT]))


## Gán bộ nền ô cho nút đồ (icon chiếm ~90% ô nhờ lề trong 3 px).
static func style_slot(b: Button, item: Dictionary, selected := false) -> void:
	var t := tier_of(item)
	var c := Items.rarity_color(item) if not item.is_empty() else Color.WHITE
	b.add_theme_stylebox_override("normal", SlotBox.new(t, c, selected))
	b.add_theme_stylebox_override("hover", SlotBox.new(t, c, selected, true))
	b.add_theme_stylebox_override("pressed", SlotBox.new(t, c, true))
	b.add_theme_stylebox_override("disabled", SlotBox.new(t, c, selected))
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())


## Ô icon cố định (không bấm) — dùng trong thẻ thông tin.
static func icon_slot(item: Dictionary, px: float) -> Control:
	var pc := PanelContainer.new()
	pc.add_theme_stylebox_override("panel", SlotBox.new(tier_of(item), Items.rarity_color(item)))
	pc.custom_minimum_size = Vector2(px, px)
	pc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tr := TextureRect.new()
	tr.texture = SpriteLib.item_icon(item)
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pc.add_child(tr)
	# EN-1 (docs/43): icon lớn trong thẻ cũng có hiệu ứng cường hoá (số "+N" đã có ở chip nên tắt tấm số)
	var fx = EnhanceFx.attach(tr, item, tr.texture, 0.0, 5.0)
	fx.badge = false
	return pc


## Dải đầu thẻ: nền nhuộm màu phẩm chất mờ dần sang phải.
class HeaderBox:
	extends StyleBox
	var col := Color.WHITE

	func _init(c := Color.WHITE) -> void:
		col = c
		content_margin_left = 8
		content_margin_right = 8
		content_margin_top = 8
		content_margin_bottom = 8

	func _draw(ci: RID, r: Rect2) -> void:
		var a := Color(col.darkened(0.35), 0.55)
		var b := Color(col.darkened(0.35), 0.0)
		RenderingServer.canvas_item_add_polygon(ci, PackedVector2Array([r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)]),
			PackedColorArray([a, b, b, a]))
		RenderingServer.canvas_item_add_rect(ci, Rect2(r.position, Vector2(r.size.x, 2)), Color(col, 0.9))


## Đường phân cách có ngọc giữa.
class Divider:
	extends Control
	var col := Bronze.BR

	func _init(c := Bronze.BR) -> void:
		col = c
		custom_minimum_size = Vector2(0, 10)
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		var y := size.y / 2.0
		var m := size.x / 2.0
		draw_polygon(PackedVector2Array([Vector2(0, y), Vector2(m - 8, y - 0.8), Vector2(m - 8, y + 0.8)]), PackedColorArray([Color(col, 0.0), Color(col, 0.9), Color(col, 0.9)]))
		draw_polygon(PackedVector2Array([Vector2(size.x, y), Vector2(m + 8, y - 0.8), Vector2(m + 8, y + 0.8)]), PackedColorArray([Color(col, 0.0), Color(col, 0.9), Color(col, 0.9)]))
		draw_polygon(PackedVector2Array([Vector2(m, y - 4), Vector2(m + 4, y), Vector2(m, y + 4), Vector2(m - 4, y)]), PackedColorArray([col.lightened(0.3)]))


static func _row(icon: Texture2D, text: String, col: Color, fs := 14, width := 0.0) -> HBoxContainer:
	var h := UiTheme.hbox(6)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if icon != null:
		var ic := UiTheme.icon_rect(icon, 18)
		ic.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		h.add_child(ic)
	var l := UiTheme.label(text, "", maxf(0.0, width - 26.0) if width > 0.0 else 0.0)
	l.add_theme_color_override("font_color", col)
	l.add_theme_font_size_override("font_size", UiTheme.fs(fs))
	h.add_child(l)
	return h


## GC-1: 1 dòng lỗ ngọc trên thẻ đồ — key "" = lỗ trống.
static func gem_row(key: String, slot: String, width: float) -> HBoxContainer:
	var h := UiTheme.hbox(6)
	h.name = "GemRow"
	h.set_meta("gem_row", key)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var ic := UiTheme.icon_rect(SpriteLib.icon(Gear.gem_icon_id(key) if key != "" else "gem-socket"), 20)
	ic.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_child(ic)
	if key == "":
		var el := UiTheme.label("Lỗ trống — khảm ở Lò Rèn (tab Khảm ngọc)")
		el.add_theme_font_size_override("font_size", UiTheme.fs(12))
		el.add_theme_color_override("font_color", Color(TEXT_DIM, 0.75))
		h.add_child(el)
		return h
	var pr := Items.gem_parse(key)
	var nl := UiTheme.label(Gear.gem_name(key))
	nl.add_theme_font_override("font", UiTheme.bold_font())
	nl.add_theme_font_size_override("font_size", UiTheme.fs(13))
	nl.add_theme_color_override("font_color", Color(str(Monsters.ELEMENT_HEX.get(pr[0], "#e8dcc4"))).lightened(0.1))
	nl.custom_minimum_size.x = 118.0
	h.add_child(nl)
	var gv := Items.gem_value(str(pr[0]), int(pr[1]), slot)
	var parts := PackedStringArray()
	for k in gv:
		parts.append(Items.stat_text(k, gv[k]))
	var sl := UiTheme.label(", ".join(parts), "", maxf(0.0, width - 170.0))
	sl.add_theme_font_size_override("font_size", UiTheme.fs(13))
	sl.add_theme_color_override("font_color", UiTheme.GOOD)
	h.add_child(sl)
	return h


static func _chip(text: String, col: Color) -> PanelContainer:
	var pc := PanelContainer.new()
	pc.add_theme_stylebox_override("panel", UiTheme.box(Color(col.darkened(0.55), 0.85), 8, 1, Color(col, 0.8), 3))
	pc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var l := UiTheme.label(text)
	l.add_theme_font_override("font", UiTheme.bold_font())
	l.add_theme_font_size_override("font_size", UiTheme.fs(11))
	l.add_theme_color_override("font_color", col.lightened(0.35))
	pc.add_child(l)
	return pc


## Thẻ thông tin trang bị (không có nút hành động). header = "ĐANG XEM" / "ĐANG MẶC" / "" ; compare = thêm phần so sánh
## với worn (dòng ▲ ▼ do diff_fn trả về [[chữ, màu], …]); p = hồ sơ (để tính số món của bộ đang mặc), có thể null.
static func build(item: Dictionary, width: float, header := "", p = null, diff: Array = [], compare_title := "", note := "") -> VBoxContainer:
	var c := Items.rarity_color(item)
	var t := tier_of(item)
	var v := UiTheme.vbox(5)
	v.custom_minimum_size.x = width
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# --- dải đầu: icon lớn + tên + phẩm chất · ô · cấp + nhãn bậc
	var head := PanelContainer.new()
	head.add_theme_stylebox_override("panel", HeaderBox.new(c))
	head.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var hr := UiTheme.hbox(10)
	hr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hr.add_child(icon_slot(item, 64))
	var hv := UiTheme.vbox(2)
	hv.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if header != "":
		var hl := UiTheme.label(header)
		hl.add_theme_font_size_override("font_size", UiTheme.fs(11))
		hl.add_theme_color_override("font_color", UiTheme.GOLD if header == "ĐANG MẶC" else TEXT_DIM)
		hv.add_child(hl)
	var name := UiTheme.label(Items.display_name(item), "", width - 96.0)
	name.add_theme_font_override("font", UiTheme.bold_font())
	name.add_theme_font_size_override("font_size", UiTheme.fs(18))
	name.add_theme_color_override("font_color", c.lightened(0.1))
	name.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	name.add_theme_constant_override("outline_size", 3)
	hv.add_child(name)
	# UI-65b (06/11): bỏ "· Cấp N" (cấp món chỉ để tính chỉ số, không giới hạn mặc — chỉ số đã hiện bên dưới)
	var sub := UiTheme.label(str(ItemData.SLOTS[item.slot].name))
	sub.add_theme_color_override("font_color", TEXT_DIM)
	sub.add_theme_font_size_override("font_size", UiTheme.fs(12))
	hv.add_child(sub)
	var chips := UiTheme.hbox(4)
	chips.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chips.add_child(_chip("%s · %s" % [ItemData.RARITIES[item.rarity].name, TIER_LABEL[t]], c))
	# UI-65b (06/11): bỏ chip "+N" — tên món đã có "+N" (Items.display_name)
	if str(item.get("set", "")) != "":
		chips.add_child(_chip("Đồ bộ", Color("#7ad65a")))
	hv.add_child(chips)
	hr.add_child(hv)
	head.add_child(hr)
	v.add_child(head)
	# --- chỉ số chính: số to + biểu tượng
	var base_stat := str(Items.base_stat(item))
	var main := UiTheme.hbox(8)
	main.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var mi := UiTheme.icon_rect(stat_icon(str(base_stat)), 26)
	mi.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	main.add_child(mi)
	var ml := RichTextLabel.new()
	ml.bbcode_enabled = true
	ml.fit_content = true
	ml.scroll_active = false
	ml.autowrap_mode = TextServer.AUTOWRAP_OFF
	ml.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ml.add_theme_font_override("normal_font", UiTheme.bold_font())
	ml.add_theme_font_override("bold_font", UiTheme.bold_font())
	ml.add_theme_font_size_override("normal_font_size", UiTheme.fs(20))
	ml.add_theme_font_size_override("bold_font_size", UiTheme.fs(20))
	ml.add_theme_color_override("default_color", Color("#f3ead6"))
	ml.text = Items.base_text(item, -1, true)
	ml.custom_minimum_size.x = 0.0
	main.add_child(ml)
	var gl := UiTheme.label("(gốc)")
	gl.add_theme_color_override("font_color", TEXT_DIM)
	gl.add_theme_font_size_override("font_size", UiTheme.fs(12))
	gl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	main.add_child(gl)
	v.add_child(main)
	# --- dòng phụ
	if not item.affixes.is_empty():
		v.add_child(Divider.new())
		var rf := int(item.get("reforged", -1))
		for i in item.affixes.size():
			var af: Dictionary = item.affixes[i]
			# NL-1: dòng đã tẩy luyện có ✦
			v.add_child(_row(stat_icon(str(af.stat)), ("✦ " if i == rf else "") + Items.stat_text(af.stat, af.value), AFFIX_COL, 14, width))
	# --- NL-1 (docs/47 §5) + GC-1 (Spec_Notes 10/11: "thuộc tính của đá sau khi gắn → section riêng, từng dòng tương ứng
	# với đá, có icon nhỏ"): mục NGỌC KHẢM riêng — mỗi lỗ 1 dòng: icon ngọc · tên (màu hệ) · chỉ số viên đó; lỗ trống mờ.
	if int(item.get("sockets", 0)) > 0:
		var gems: Array = item.get("gems", [])
		v.add_child(Divider.new())
		var gh := UiTheme.label("NGỌC KHẢM  %d/%d" % [gems.size(), int(item.sockets)])
		gh.name = "GemHead"
		gh.add_theme_font_override("font", UiTheme.bold_font())
		gh.add_theme_font_size_override("font_size", UiTheme.fs(11))
		gh.add_theme_color_override("font_color", UiTheme.GOLD)
		v.add_child(gh)
		for i in int(item.sockets):
			v.add_child(gem_row(str(gems[i]) if i < gems.size() else "", str(item.slot), width))
		if str(item.slot) == "weapon":
			var seal := Items.weapon_seal({"weapon": item})
			if seal != "":
				var sl := UiTheme.label("Ấn hệ %s — khắc hệ +%d%%" % [Monsters.ELEMENT_NAMES[seal], roundi(GearData.SEAL_BONUS * 100.0)], "", width)
				sl.add_theme_font_size_override("font_size", UiTheme.fs(12))
				sl.add_theme_color_override("font_color", Color(str(Monsters.ELEMENT_HEX[seal])))
				v.add_child(sl)
	# --- NL-1: Thức Tỉnh
	var aw: Dictionary = item.get("awaken", {})
	if str(aw.get("id", "")) != "":
		var al := UiTheme.label("%s Thức Tỉnh: %s" % ["★".repeat(int(aw.tier)), Items.awaken_text(str(aw.id), int(aw.tier))], "", width)
		al.add_theme_font_size_override("font_size", UiTheme.fs(13))
		al.add_theme_color_override("font_color", AWAKEN_COL)
		v.add_child(al)
	# --- hiệu ứng riêng (đồ độc nhất)
	if str(item.get("unique", "")) != "":
		var ub := PanelContainer.new()
		ub.add_theme_stylebox_override("panel", UiTheme.box(Color(c.darkened(0.6), 0.6), 6, 1, Color(c, 0.6), 7))
		ub.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var ul := UiTheme.label("✦ " + str(ItemData.UNIQUES[item.unique].text), "", width - 20.0)
		ul.add_theme_color_override("font_color", c.lightened(0.25))
		ul.add_theme_font_size_override("font_size", UiTheme.fs(13))
		ub.add_child(ul)
		v.add_child(ub)
	# --- bộ trang bị: tên + số món đang mặc + các mốc
	if str(item.get("set", "")) != "":
		v.add_child(Divider.new(Color("#5aa04a")))
		var sd: Dictionary = ItemData.SETS[item.set]
		var worn := 0
		if p != null:
			for s in p.equipment:
				if str(p.equipment[s].get("set", "")) == str(item.set):
					worn += 1
		v.add_child(_row(SpriteLib.icon("stat-set"), "%s  (%d/%d)" % [sd.get("name", item.set), worn, int(sd.tiers[-1].count)], Color("#8ae07a"), 14, width))
		for tier in sd.tiers:
			var on := worn >= int(tier.count)
			var tl := UiTheme.label("%s (%d) %s" % ["✓" if on else "·", int(tier.count), tier.text], "", width - 12.0)
			tl.add_theme_font_size_override("font_size", UiTheme.fs(12))
			tl.add_theme_color_override("font_color", UiTheme.GOOD if on else TEXT_DIM)
			v.add_child(tl)
	# --- so sánh
	if compare_title != "":
		v.add_child(Divider.new())
		var ct := UiTheme.label(compare_title, "", width)
		ct.add_theme_font_size_override("font_size", UiTheme.fs(12))
		ct.add_theme_color_override("font_color", TEXT_DIM)
		ct.name = "CompareHeader"
		v.add_child(ct)
		if diff.is_empty():
			v.add_child(_row(null, "Chỉ số như nhau", TEXT_DIM, 13, width))
		var flow := HFlowContainer.new()
		flow.custom_minimum_size.x = width
		flow.add_theme_constant_override("h_separation", 4)
		flow.add_theme_constant_override("v_separation", 4)
		flow.mouse_filter = Control.MOUSE_FILTER_IGNORE
		for ln in diff:
			flow.add_child(_chip(str(ln[0]), ln[1]))
		v.add_child(flow)
	# --- NL-1: Lực chiến món này, tách theo nguồn (rê chuột xem)
	var pp := Items.item_power_parts(item)
	var cpl := UiTheme.label("Lực chiến món: %d" % int(pp.total), "", width)
	cpl.name = "ItemPower"
	cpl.add_theme_font_size_override("font_size", UiTheme.fs(12))
	cpl.add_theme_color_override("font_color", UiTheme.GOLD)
	cpl.mouse_filter = Control.MOUSE_FILTER_PASS
	cpl.tooltip_text = "Gốc %d · Cường hoá %d · Dòng phụ %d · Ngọc %d" % [int(pp.base), int(pp.plus), int(pp.affix), int(pp.gem)]
	var sub2 := PackedStringArray()
	for k in [["Gốc", pp.base], ["Cường hoá", pp.plus], ["Dòng phụ", pp.affix], ["Ngọc", pp.gem]]:
		if int(k[1]) > 0:
			sub2.append("%s %d" % [k[0], int(k[1])])
	cpl.text += "  (" + " · ".join(sub2) + ")"
	v.add_child(cpl)
	if note != "":
		var nl := UiTheme.label(note, "", width)
		nl.add_theme_font_size_override("font_size", UiTheme.fs(12))
		nl.add_theme_color_override("font_color", UiTheme.GOLD)
		v.add_child(nl)
	return v
