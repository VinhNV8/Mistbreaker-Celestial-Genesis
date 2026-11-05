extends Control
## UI-22: màn chọn lớp (bước 1 của tạo nhân vật, create_screen.gd) kiểu thẻ — 5 cột (3 lớp đang có + Hộ Vệ, Triệu Hồi Sư "Sắp ra mắt",
## docs/19). Mỗi thẻ: huy hiệu + tên + vai trò, nhân vật trên bệ trong cảnh theo lớp kèm 8 ô đồ khởi đầu,
## câu dẫn, 7 chỉ số cấp 1, 4 kỹ năng đặc trưng, nút "Chọn lớp". on_pick(class_id) khi bấm.

const UiTheme = preload("res://scripts/ui/ui_theme.gd")
const SpriteLib = preload("res://scripts/view/sprite_lib.gd")
const Classes = preload("res://scripts/data/classes.gd")
const Stats = preload("res://scripts/core/stats.gd")

## Thẻ hiển thị: lớp đang có lấy dữ liệu từ Classes; lớp chưa làm (docs/19) chỉ có khung + "Sắp ra mắt".
const CARDS := [
	{"id": "kiem-khach", "accent": "#e0484f", "scene": "hall", "emblem": "skill-slash", "tag": "Cận chiến · Bùng nổ",
		"quote": "Kiếm trong tay, chính nghĩa trong tim. Chém tan bóng tối, bảo vệ những điều quý giá.",
		"skills": ["spin", "dash", "wave", "vankiem"]},
	{"id": "tho-san", "accent": "#5bd16a", "scene": "forest", "emblem": "skill-shot", "tag": "Tầm xa · Linh hoạt",
		"quote": "Gió là bạn đồng hành, mũi tên là lời thì thầm của cái chết từ xa.",
		"skills": []},
	{"id": "phap-su", "accent": "#a070f0", "scene": "arcane", "emblem": "skill-nova", "tag": "Phép thuật · Diện rộng",
		"quote": "Tri thức là ngọn lửa soi sáng thế giới. Phép thuật là câu trả lời cho mọi giới hạn.",
		"skills": []},
	{"id": "ho-ve", "accent": "#e0a630", "scene": "hall_gold", "emblem": "stat-def", "tag": "Kiên định · Bảo vệ", "name": "Hộ Vệ",
		"quote": "Tấm khiên không chỉ để chặn đòn đánh, mà còn để che chở những người bên cạnh.",
		"skills": ["khieukhich", "khienthep", "chandia", "thanhbatdiet"]},
	{"id": "trieu-hoi-su", "accent": "#c060f0", "scene": "void", "emblem": "skill-trieuhoi", "tag": "Triệu hồi · Hỗ trợ", "name": "Triệu Hồi Sư",
		"quote": "Ta không chiến đấu một mình. Những linh hồn trung thành sẽ chiến đấu thay ta.",
		"skills": ["soibong", "tieuquy", "lienket", "quandoan"]},
]

var on_pick: Callable


static func accent_of(class_id: String) -> String:
	for d in CARDS:
		if d.id == class_id:
			return str(d.accent)
	return "#c9a45c"


var look := {}


## Cảnh nền thẻ: sảnh đá + cờ / rừng / vòng phép / sảnh vàng / hư không; nhân vật đứng trên bệ.
class ClassScene:
	extends Control
	var class_id := ""
	var look := {}
	var kind := "hall"
	var accent := Color.WHITE
	var locked := false
	var t := 0.0

	func _init() -> void:
		clip_contents = true
		mouse_filter = MOUSE_FILTER_IGNORE

	func _process(delta: float) -> void:
		t += delta
		queue_redraw()

	func _draw() -> void:
		var w := size.x
		var h := size.y
		var top := Color("#120d0b")
		var bot := Color("#2a201a")
		match kind:
			"forest":
				top = Color("#0a1610"); bot = Color("#1c2c1c")
			"arcane":
				top = Color("#0e0b1c"); bot = Color("#221a3a")
			"hall_gold":
				top = Color("#15110b"); bot = Color("#2e2618")
			"void":
				top = Color("#120a1c"); bot = Color("#2a1840")
		for i in 12:
			var k := i / 12.0
			draw_rect(Rect2(0, h * k, w, h / 12.0 + 1), top.lerp(bot, k))
		if kind == "forest":
			for i in 5:
				SpriteLib.draw_env(self, ["tree-pine", "tree-0", "tree-1", "tree-pine", "tree-2"][i], Vector2(w * (i + 0.1) / 4.2, h * 0.6), Color(0.3, 0.45, 0.35), 0.9, i % 2 == 1)
			for k in 6:
				var a := fmod(t * 0.3 + k * 0.17, 1.0)
				draw_circle(Vector2(w * (0.1 + 0.15 * k), h * (0.7 - a * 0.5)), 1.5, Color(0.6, 1.0, 0.5, 0.7 * (1.0 - a)))
		else:
			# tường gạch đá + cửa vòm
			var brick := Color(1, 1, 1, 0.05)
			for row in 9:
				var y := row * 18.0
				draw_line(Vector2(0, y), Vector2(w, y), brick, 1.0)
				for c in 8:
					var x := c * 36.0 + (18.0 if row % 2 == 1 else 0.0)
					draw_line(Vector2(x, y), Vector2(x, y + 18), brick, 1.0)
			var arch_c := Vector2(w / 2.0, h * 0.42)
			draw_rect(Rect2(arch_c.x - 36, arch_c.y, 72, h * 0.3), Color(0, 0, 0, 0.35))
			draw_circle(arch_c, 36.0, Color(0, 0, 0, 0.35))
			if kind == "hall" or kind == "hall_gold":
				var bc := accent.darkened(0.45) if kind == "hall" else Color("#3a4a7a")
				for side: float in [-1.0, 1.0]:
					var x := w / 2.0 + side * w * 0.3
					var flag := PackedVector2Array([Vector2(x - 12, 10), Vector2(x + 12, 10), Vector2(x + 12, 70), Vector2(x, 62), Vector2(x - 12, 70)])
					draw_colored_polygon(flag, bc)
					draw_polyline(PackedVector2Array([flag[0], flag[1], flag[2], flag[3], flag[4], flag[0]]), Color(0.79, 0.64, 0.36, 0.7), 1.0)
			else:
				# ô cửa sổ phát sáng màu lớp
				draw_circle(arch_c + Vector2(0, -6), 26.0, Color(accent, 0.12 + 0.05 * sin(t * 2.0)))
		# bệ
		var c := Vector2(w / 2.0, h * 0.84)
		draw_set_transform(c + Vector2(0, 9), 0.0, Vector2(1.0, 0.3))
		draw_circle(Vector2.ZERO, w * 0.36, Color("#2c2a28"))
		draw_set_transform(c, 0.0, Vector2(1.0, 0.3))
		draw_circle(Vector2.ZERO, w * 0.36, Color("#56534d"))
		draw_circle(Vector2.ZERO, w * 0.29, Color("#6a665e"))
		if kind == "arcane" or kind == "void":
			draw_arc(Vector2.ZERO, w * 0.27, 0, TAU, 48, Color(accent, 0.7 + 0.3 * sin(t * 3.0)), 3.0)
			draw_arc(Vector2.ZERO, w * 0.2, 0, TAU, 48, Color(accent, 0.45), 1.5)
		else:
			draw_arc(Vector2.ZERO, w * 0.29, 0, TAU, 40, Color("#46433e"), 2.0)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		draw_circle(c + Vector2(0, -30), 50.0, Color(accent, 0.06))
		# AR-44: nhân vật cắt từ sprite sheet 5 lớp (pc-<lớp>) đứng trên bệ, cứ 4 giây vung đòn một lần
		var hs := SpriteLib.hero_sprite(class_id, look)
		if hs == "pc-" + class_id:
			var phase := fmod(t + class_id.length() * 0.7, 4.0)
			var anim := "attack" if phase > 3.4 else "idle"
			var frame := SpriteLib.frame_at(hs, anim, phase - 3.4 if anim == "attack" else phase)
			SpriteLib.draw_hero(self, class_id, look, anim, frame, c + Vector2(0, 6), false, Color.WHITE, 2.3)
		# không có: chân dung lớn (tools/art/portraits.py), thở nhẹ lên xuống
		var tex := SpriteLib.icon("portrait-" + class_id) if hs != "pc-" + class_id else null
		if tex != null:
			var k := 2.0
			var bob := roundf(sin(t * 2.2 + class_id.length()) * 1.2)
			var sz := tex.get_size() * k
			draw_texture_rect(tex, Rect2(Vector2(c.x - sz.x / 2.0, c.y + 8 - sz.y + bob), sz), false)
		if locked:
			var f := UiTheme.bold_font()
			draw_rect(Rect2(0, h - 22, w, 22), Color(0, 0, 0, 0.6))
			draw_string(f, Vector2(0, h - 6), "SẮP RA MẮT", HORIZONTAL_ALIGNMENT_CENTER, w, 13, Color(accent, 0.95))


## Huy hiệu lớp: vòng kim cương viền màu lớp, icon ở giữa.
class Emblem:
	extends Control
	var tex: Texture2D
	var accent := Color.WHITE

	func _init() -> void:
		custom_minimum_size = Vector2(54, 54)
		mouse_filter = MOUSE_FILTER_IGNORE

	func _draw() -> void:
		var c := size / 2.0
		var r := size.x * 0.46
		var pts := PackedVector2Array([c + Vector2(0, -r), c + Vector2(r, 0), c + Vector2(0, r), c + Vector2(-r, 0)])
		draw_circle(c, r * 0.95, Color(accent, 0.15))
		draw_colored_polygon(pts, Color("#140d08"))
		pts.append(pts[0])
		draw_polyline(pts, accent, 2.0)
		draw_arc(c, r * 0.62, 0, TAU, 32, Color(accent, 0.5), 1.0)
		if tex != null:
			draw_texture_rect(tex, Rect2(c - Vector2(15, 15), Vector2(30, 30)), false)


func _ready() -> void:
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = UiTheme.BG
	bg.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	add_child(bg)
	# UI-60 (docs/38): khung cao hơn cửa sổ 768 px (dòng chân bị cắt) → thu nhỏ vừa cửa sổ, căn giữa (_fit).
	var box := PanelContainer.new()
	box.theme_type_variation = "SolidPanel"
	add_child(box)
	_box = box
	resized.connect(_fit)
	box.resized.connect(_fit)
	var col := UiTheme.vbox(10)
	box.add_child(col)
	# tiêu đề
	var top := UiTheme.hbox(10)
	var plate := UiTheme.panel(UiTheme.box(Color("#1a120b"), 8, 2, UiTheme.GOLD_DARK, 6))
	var ph := UiTheme.hbox(8)
	ph.add_child(UiTheme.icon_rect(SpriteLib.icon("stat-atk"), 30))
	ph.add_child(UiTheme.strong("Chọn lớp nhân vật", 22, Color("#f3d27a")))
	plate.add_child(ph)
	top.add_child(plate)
	top.add_child(UiTheme.spacer())
	var sub := UiTheme.label("Chọn con đường của bạn, viết nên huyền thoại.", "Muted")
	sub.size_flags_vertical = SIZE_SHRINK_CENTER
	top.add_child(sub)
	col.add_child(top)
	var cards := UiTheme.hbox(8)
	for def in CARDS:
		cards.add_child(_card(def))
	col.add_child(cards)
	var foot := UiTheme.hbox(10)
	foot.alignment = BoxContainer.ALIGNMENT_CENTER
	foot.add_child(UiTheme.strong("NĂM CON ĐƯỜNG, MỘT THẾ GIỚI", 14, Color("#c9a45c")))
	col.add_child(foot)


var _box: PanelContainer


func _fit() -> void:
	if _box == null:
		return
	var need := _box.get_combined_minimum_size()
	_box.size = need
	var k := minf(1.0, minf((size.x - 16.0) / maxf(1.0, need.x), (size.y - 16.0) / maxf(1.0, need.y)))
	_box.scale = Vector2(k, k)
	_box.position = ((size - need * k) / 2.0).floor()


func _card(def: Dictionary) -> PanelContainer:
	var cid: String = def.id
	var locked := not Classes.DEFS.has(cid)
	var accent := Color(def.accent)
	var card := UiTheme.panel(UiTheme.box(Color("#150f0a"), 8, 2, Color(accent, 0.55 if not locked else 0.3), 8))
	card.name = "Card_" + cid
	card.custom_minimum_size.x = 252
	var v := UiTheme.vbox(6)
	card.add_child(v)
	# đầu thẻ
	var head := UiTheme.panel(UiTheme.box(Color(accent.darkened(0.8), 0.9), 6, 1, Color(accent, 0.35), 6))
	var hh := UiTheme.hbox(8)
	var em := Emblem.new()
	em.tex = SpriteLib.icon(str(def.emblem))
	em.accent = accent
	hh.add_child(em)
	var nv := UiTheme.vbox(0)
	nv.size_flags_vertical = SIZE_SHRINK_CENTER
	var nm: String = def.get("name", Classes.DEFS[cid].name if not locked else cid)
	nv.add_child(UiTheme.strong(nm, 20, accent.lightened(0.2)))
	nv.add_child(UiTheme.label(str(def.tag), "Small"))
	hh.add_child(nv)
	head.add_child(hh)
	v.add_child(head)
	# cảnh + 8 ô đồ khởi đầu
	var mid := UiTheme.hbox(4)
	mid.add_child(_slots(["helm", "armor", "gloves", "boots"], accent, locked))
	var sc := ClassScene.new()
	sc.class_id = cid
	sc.look = look
	sc.kind = str(def.scene)
	sc.accent = accent
	sc.locked = locked
	sc.custom_minimum_size = Vector2(0, 176)
	sc.size_flags_horizontal = SIZE_EXPAND_FILL
	var frame := UiTheme.panel(UiTheme.box(Color("#0b0908"), 6, 1, Color(accent, 0.35), 1))
	frame.size_flags_horizontal = SIZE_EXPAND_FILL
	frame.add_child(sc)
	mid.add_child(frame)
	mid.add_child(_slots(["weapon", "necklace", "ring", "amulet"], accent, locked))
	v.add_child(mid)
	var q := UiTheme.label(str(def.quote), "Small", 236)
	q.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	q.add_theme_color_override("font_color", Color("#c9b89a"))
	q.custom_minimum_size.y = 62
	v.add_child(q)
	v.add_child(HSeparator.new())
	# chỉ số cấp 1
	var s := {} if locked else Stats.derive(1, {"str": 0, "agi": 0, "int": 0, "vit": 0, "luk": 0}, "", {}, 1, cid)
	for r in [["stat-hp", "HP", "max_hp", "%d", 1.0], ["stat-mp", "MP", "max_mp", "%d", 1.0], ["stat-atk", "Tấn công", "atk", "%d", 1.0],
			["stat-def", "Phòng thủ", "def", "%.1f", 1.0], ["stat-aspd", "Tốc đánh", "atk_speed", "%d%%", 100.0],
			["stat-crit", "Chí mạng", "crit", "%.1f%%", 100.0], ["stat-eva", "Né tránh", "evasion", "%.1f%%", 100.0]]:
		var row := UiTheme.hbox(6)
		row.add_child(UiTheme.icon_rect(SpriteLib.icon(r[0]), 18))
		row.add_child(UiTheme.label(r[1], "Muted"))
		row.add_child(UiTheme.spacer())
		var val := "—" if locked else (str(r[3]) % (float(s[r[2]]) * float(r[4])) if str(r[3]).contains("f") else str(r[3]) % roundi(float(s[r[2]]) * float(r[4])))
		row.add_child(UiTheme.strong(val, 14))
		v.add_child(row)
	# CS-UI8 (docs/26): 7 thuộc tính khởi tạo (CR-001); rê chuột xem tự tăng mỗi cấp.
	if not locked:
		var st: Dictionary = Stats.base_stats(cid)
		var gr: Dictionary = Stats.GROW[Stats.class_of(cid)]
		var parts := PackedStringArray()
		for k in Stats.STATS:
			parts.append("%s %d" % [str(k).to_upper(), int(st[k])])
		var at := UiTheme.label(" · ".join(parts), "Small", 236)
		at.name = "Attrs_" + cid
		at.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		at.add_theme_color_override("font_color", accent.lightened(0.35))
		at.mouse_filter = Control.MOUSE_FILTER_PASS
		var gp := PackedStringArray()
		for k in gr:
			gp.append("%s +%s" % [str(k).to_upper(), str(gr[k]).replace(".", ",")])
		at.tooltip_text = "Thuộc tính khởi tạo. Tự tăng mỗi cấp: " + ", ".join(gp)
		v.add_child(at)
	var kt := UiTheme.label("— Kỹ năng đặc trưng —", "Small")
	kt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(kt)
	var sk := UiTheme.hbox(6)
	sk.alignment = BoxContainer.ALIGNMENT_CENTER
	for e in _skill_icons(def, locked):
		var slot := UiTheme.panel(UiTheme.box(Color("#0f0a06"), 5, 1, Color(accent, 0.6), 2))
		var ic := UiTheme.icon_rect(e[0], 40)
		if locked:
			ic.modulate = Color(1, 1, 1, 0.4)
		slot.add_child(ic)
		slot.tooltip_text = e[1]
		sk.add_child(slot)
	v.add_child(sk)
	var b := UiTheme.button("Sắp ra mắt" if locked else "Chọn lớp")
	b.name = "Pick_" + cid
	b.disabled = locked
	b.custom_minimum_size = Vector2(0, 42)
	b.add_theme_stylebox_override("normal", UiTheme.box(accent.darkened(0.7), 6, 2, accent.darkened(0.1), 8))
	b.add_theme_stylebox_override("hover", UiTheme.box(accent.darkened(0.55), 6, 2, accent.lightened(0.2), 8))
	b.add_theme_stylebox_override("pressed", UiTheme.box(accent.darkened(0.75), 6, 2, accent, 8))
	b.add_theme_stylebox_override("disabled", UiTheme.box(Color("#14100c"), 6, 1, Color(accent, 0.25), 8))
	b.add_theme_color_override("font_color", accent.lightened(0.5))
	b.pressed.connect(func():
		if on_pick.is_valid():
			on_pick.call(cid))
	v.add_child(b)
	return card


func _slots(slots: Array, accent: Color, locked: bool) -> VBoxContainer:
	var v := UiTheme.vbox(4)
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	for s in slots:
		var p := UiTheme.panel(UiTheme.box(Color("#0f0a06"), 5, 1, Color(accent, 0.45 if not locked else 0.2), 2))
		var ic := UiTheme.icon_rect(SpriteLib.icon("item-" + str(s)), 34)
		ic.modulate = Color(1, 1, 1, 0.85 if not locked else 0.25)
		p.add_child(ic)
		v.add_child(p)
	return v


## [texture, chú thích] của 4 kỹ năng hiện trên thẻ.
func _skill_icons(def: Dictionary, locked: bool) -> Array:
	var out := []
	if locked:
		for id in def.icons:
			out.append([SpriteLib.icon(str(id)), "Lớp đang phát triển (docs/19)"])
		return out
	var c: Dictionary = Classes.DEFS[def.id]
	var want: Array = def.get("skills", [])
	var list: Array = c.skills.filter(func(sk): return want.has(sk.id)) if not want.is_empty() else []
	if list.is_empty():
		list = c.skills.slice(0, 3)
		for sk in c.skills:
			if sk.get("ultimate", false):
				list.append(sk)
				break
	for sk in list:
		out.append([SpriteLib.icon("skill-" + str(sk.icon)), "%s — %s" % [sk.name, sk.text]])
	return out
