extends ColorRect
## CR-06 (docs/CR-06): màn Chọn nhân vật kiểu ARPG cổ điển — nhân vật đang chọn đứng to giữa cảnh trên bệ đá
## trước Bia Đá Thiên Đạo, tên / lớp / Thiên phú phía trên; danh sách 5 ô dọc khung đồng bên phải; nút "Vào game"
## lớn giữa đáy, "Quay lại" góc trái dưới. Bấm một dòng = chọn, nhấp đúp = vào game; ↑ ↓ chọn, Enter vào, Esc quay lại.
## Không vẽ lại hình nhân vật (keep-owner-art): dùng đúng sprite trong game (SpriteLib.draw_hero) phóng to.

const UiTheme = preload("res://scripts/ui/ui_theme.gd")
const Bronze = preload("res://scripts/ui/bronze.gd")
const FrameBox = preload("res://scripts/ui/frame_box.gd")
const SpriteLib = preload("res://scripts/view/sprite_lib.gd")
const Classes = preload("res://scripts/data/classes.gd")
const Talents = preload("res://scripts/data/talents.gd")

## Vị trí ngang của nhân vật (tỉ lệ bề ngang) — chừa bên phải cho danh sách.
const HERO_X := 0.42
## Chân nhân vật (tỉ lệ chiều cao) và chiều cao hình (tỉ lệ chiều cao màn hình).
const FEET_Y := 0.79
const HERO_H := 0.42
const LIST_W := 372.0
const REGIONS := ["Rừng Sương", "Gió Hú", "Xích Sa", "U Minh", "Viêm Long", "Bắc Cực", "Thiên Không", "Vực Hư Vô", "Thiên Đạo"]

var slots_info: Array
var selected := 0
var _on_play: Callable
var _on_delete: Callable
var _on_new: Callable
var _on_back: Callable
var _on_settings: Callable
var _on_quit: Callable
var stage: HeroStage
var _rows := {}
var _name_l: Label
var _class_l: Label
var _talent_l: Label
var _meta_l: Label
var _play_b: Button
var _del_b: Button
var _new_b: Button


## Sân khấu: bệ đá + vòng phù văn theo màu hạng Thiên phú, cột sáng, nhân vật phóng to (lọc Nearest), đốm lửa bay.
## Đổi nhân vật → hiện dần 0,35 giây + múa một đòn (anim attack) rồi đứng thở (idle).
class HeroStage:
	extends Control
	var class_id := ""
	var look := {}
	var accent := Color(1.0, 0.86, 0.55)
	var t := 0.0
	var since := 99.0

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	func show_hero(cid: String, lk: Dictionary, col: Color) -> void:
		class_id = cid
		look = lk
		accent = col
		since = 0.0

	func _process(delta: float) -> void:
		t += delta
		since += delta
		queue_redraw()

	## Sprite vẽ trên sân khấu: "pcx-<lớp>" (cắt ở độ phân giải gốc của sheet, nét hơn khi phóng to) nếu nhân vật
	## dùng kiểu "Hình lớp"; không thì đúng sprite trong game (thân + tóc theo ngoại hình).
	static func stage_sprite(cid: String, lk: Dictionary) -> String:
		var id := SpriteLib.hero_sprite(cid, lk)
		if id == "pc-" + cid and SpriteLib.has_sprite("pcx-" + cid):
			return "pcx-" + cid
		return id

	## size_mul để hình cao ~`h` px trên màn hình, làm tròn để mỗi pixel ảnh = số nguyên pixel màn hình (nét đều).
	static func size_mul_for(id: String, h: float) -> float:
		var s: Dictionary = SpriteLib.data().get("sprites", {}).get(id, {})
		if s.is_empty():
			return 1.0
		var unit := SpriteLib.scale() * float(s.get("size_mul", 1.0)) / SpriteLib.px_of(s)
		var k := maxf(1.0, roundf(h / float(s.h)))
		return k / maxf(0.001, unit)

	func _ellipse(c: Vector2, r: Vector2, col: Color) -> void:
		draw_set_transform(c, 0.0, Vector2(1.0, r.y / r.x))
		draw_circle(Vector2.ZERO, r.x, col)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	func _ring(c: Vector2, r: Vector2, col: Color, w: float) -> void:
		var pts := PackedVector2Array()
		for i in 49:
			pts.append(c + Vector2(cos(TAU * i / 48.0) * r.x, sin(TAU * i / 48.0) * r.y))
		draw_polyline(pts, col, w, true)

	func _draw() -> void:
		var feet := Vector2(size.x * HERO_X, size.y * FEET_Y)
		var h := size.y * HERO_H
		var pulse := 0.5 + 0.5 * sin(t * 2.2)
		var vis := smoothstep(0.0, 0.35, since) if class_id != "" else 0.0
		# cột sáng từ trên chiếu xuống bệ
		var top := Color(accent, 0.0)
		var low := Color(accent.lerp(Color.WHITE, 0.5), 0.10 + 0.08 * vis)
		draw_polygon(PackedVector2Array([feet + Vector2(-60, -size.y), feet + Vector2(60, -size.y), feet + Vector2(150, 0), feet + Vector2(-150, 0)]),
			PackedColorArray([top, top, low, low]))
		# bệ đá: mặt trên + thành bệ
		var rx := h * 0.62
		_ellipse(feet + Vector2(0, 16), Vector2(rx + 10, rx * 0.30), Color(0, 0, 0, 0.55))
		_ellipse(feet + Vector2(0, 10), Vector2(rx, rx * 0.28), Color("#1d2421"))
		_ellipse(feet, Vector2(rx, rx * 0.28), Color("#3a4440"))
		_ellipse(feet, Vector2(rx * 0.86, rx * 0.24), Color("#2b3431"))
		# vòng phù văn sáng theo hạng
		var glow := Color(accent, (0.35 + 0.25 * pulse) * maxf(0.35, vis))
		_ring(feet, Vector2(rx * 0.74, rx * 0.205), glow, 2.5)
		_ring(feet, Vector2(rx * 0.56, rx * 0.155), Color(accent, glow.a * 0.6), 1.5)
		for i in 8:
			var a := TAU * i / 8.0 + t * 0.25
			var p := feet + Vector2(cos(a) * rx * 0.65, sin(a) * rx * 0.18)
			draw_circle(p, 3.0, Color(accent.lerp(Color.WHITE, 0.4), glow.a))
		_ellipse(feet, Vector2(rx * 0.5, rx * 0.14), Color(accent, 0.10 + 0.10 * pulse * vis))
		if class_id == "":
			return
		# bóng chân + nhân vật
		_ellipse(feet + Vector2(0, 2), Vector2(h * 0.22, h * 0.05), Color(0, 0, 0, 0.5 * vis))
		var id := stage_sprite(class_id, look)
		var mul := size_mul_for(id, h)
		var anim := "idle"
		var frame := SpriteLib.frame_at(id, "idle", t)
		if since < 0.9 and since > 0.2:
			anim = "attack"
			frame = SpriteLib.frame_progress(id, "attack", (since - 0.2) / 0.7)
		var at := feet + Vector2(0, roundf((1.0 - vis) * 14.0))
		if id.begins_with("pcx-"):
			SpriteLib.draw_frame(self, id, anim, frame, at, false, Color(1, 1, 1, vis), mul)
		else:
			SpriteLib.draw_hero(self, class_id, look, anim, frame, at, false, Color(1, 1, 1, vis), mul)
		# đốm lửa bay quanh bệ
		for i in 18:
			var k := fposmod(t * (0.22 + (i % 5) * 0.05) + i * 0.137, 1.0)
			var x := feet.x + sin(i * 2.3 + t * 0.7) * rx * 0.8
			var y := feet.y - k * h * 1.1
			draw_circle(Vector2(x, y), 1.5 + (i % 3) * 0.7, Color(accent.lerp(Color.WHITE, 0.3), (1.0 - k) * 0.7 * vis))


func _init(info: Array, on_play: Callable, on_delete: Callable, on_new: Callable, on_back: Callable, sel: int, backdrop: Control,
		on_settings := Callable(), on_quit := Callable()) -> void:
	slots_info = info
	_on_settings = on_settings
	_on_quit = on_quit
	_on_play = on_play
	_on_delete = on_delete
	_on_new = on_new
	_on_back = on_back
	name = "CharSelect"
	color = UiTheme.BG
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if backdrop != null:
		add_child(backdrop)
	stage = HeroStage.new()
	stage.name = "HeroStage"
	add_child(stage)
	_build()
	if sel < 1 or sel > slots_info.size() or slots_info[sel - 1].is_empty():
		sel = _first_used()
	select(sel)


func _first_used() -> int:
	for i in slots_info.size():
		if not slots_info[i].is_empty():
			return i + 1
	return 0


func _used() -> int:
	return slots_info.filter(func(s): return not s.is_empty()).size()


static func region_name(map_id: String) -> String:
	var head := map_id.split("-")[0]
	if not head.is_valid_int():
		return ""
	var r := int(head)
	return "Vùng %d · %s" % [r, REGIONS[r - 1]] if r >= 1 and r <= REGIONS.size() else ""


static func class_line(s: Dictionary) -> String:
	return "Lv %d · %s" % [int(s.level), Classes.title(str(s.class_id), str(s.job), str(s.job2), str(s.job3))]


static func _label(text: String, size: int, col: Color, font: Font = null) -> Label:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", UiTheme.fs(size))
	l.add_theme_color_override("font_color", col)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	l.add_theme_constant_override("outline_size", 4)
	if font != null:
		l.add_theme_font_override("font", font)
	return l


func _build() -> void:
	# tiêu đề góc trên-trái
	var head := UiTheme.vbox(0)
	head.position = Vector2(28, 18)
	var title := _label("Chọn nhân vật", 30, Bronze.GOLD_TEXT, Bronze.title_font())
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	title.add_theme_constant_override("outline_size", 6)
	head.add_child(title)
	var cnt := _label("%d / %d nhân vật" % [_used(), slots_info.size()], 13, Color("#b9ab8c"))
	cnt.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	cnt.name = "CountLabel"
	head.add_child(cnt)
	add_child(head)
	# khối tên nhân vật trên đầu
	var info := UiTheme.vbox(2)
	info.name = "HeroInfo"
	info.anchor_left = HERO_X
	info.anchor_right = HERO_X
	info.offset_left = -320
	info.offset_right = 320
	info.offset_top = 64
	info.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_name_l = _label("", 44, Bronze.GOLD_TEXT, Bronze.title_font())
	_name_l.name = "HeroName"
	_name_l.add_theme_color_override("font_outline_color", Color("#1a0f05"))
	_name_l.add_theme_constant_override("outline_size", 8)
	info.add_child(_name_l)
	_class_l = _label("", 19, Color("#efe6cf"), UiTheme.bold_font())
	info.add_child(_class_l)
	_talent_l = _label("", 15, Bronze.GOLD_TEXT)
	info.add_child(_talent_l)
	_meta_l = _label("", 13, Color("#b9ab8c"))
	info.add_child(_meta_l)
	add_child(info)
	# danh sách bên phải
	var panel := PanelContainer.new()
	panel.name = "SlotList"
	panel.add_theme_stylebox_override("panel", FrameBox.new().setup(Color(Bronze.MOSS, 0.93), 16, "large"))
	panel.anchor_left = 1.0
	panel.anchor_right = 1.0
	panel.anchor_bottom = 1.0
	panel.offset_left = -LIST_W - 24
	panel.offset_right = -24
	panel.offset_top = 24
	panel.offset_bottom = -24
	add_child(panel)
	var col := UiTheme.vbox(8)
	panel.add_child(col)
	var lh := _label("Nhân vật", 22, Bronze.GOLD_TEXT, Bronze.title_font())
	col.add_child(lh)
	var sep := ColorRect.new()
	sep.color = Color(Bronze.BR_MID, 0.5)
	sep.custom_minimum_size = Vector2(0, 1)
	col.add_child(sep)
	for i in slots_info.size():
		var row := _row(i + 1)
		_rows[i + 1] = row
		col.add_child(row)
	var fill := Control.new()
	fill.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(fill)
	var brow := UiTheme.hbox(8)
	_new_b = UiTheme.button("Tạo nhân vật mới")
	_new_b.name = "NewButton"
	_new_b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_new_b.pressed.connect(_on_new)
	_new_b.disabled = _used() >= slots_info.size()
	_new_b.tooltip_text = "Đã đủ %d nhân vật — xoá bớt để tạo mới" % slots_info.size() if _new_b.disabled else ""
	brow.add_child(_new_b)
	_del_b = UiTheme.button("Xoá")
	_del_b.name = "DeleteButton"
	_del_b.custom_minimum_size.x = 84
	_del_b.pressed.connect(_delete_selected)
	brow.add_child(_del_b)
	col.add_child(brow)
	var hint := _label("↑ ↓ chọn · Enter / nhấp đúp vào game · Esc màn tiêu đề", 11, Color("#8f8570"))
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(hint)
	# nút Vào game giữa đáy dưới chân nhân vật
	_play_b = UiTheme.button("Vào game", true)
	_play_b.name = "PlayButton"
	_play_b.add_theme_font_size_override("font_size", UiTheme.fs(22))
	_play_b.anchor_left = HERO_X
	_play_b.anchor_right = HERO_X
	_play_b.anchor_top = 1.0
	_play_b.anchor_bottom = 1.0
	_play_b.offset_left = -150
	_play_b.offset_right = 150
	_play_b.offset_top = -92
	_play_b.offset_bottom = -32
	_play_b.pressed.connect(_play_selected)
	add_child(_play_b)
	# CR-06b: màn này là màn đầu khi mở game → góc trái dưới: Màn tiêu đề · Cài đặt · Thoát game
	var left := UiTheme.vbox(8)
	left.name = "MenuButtons"
	left.anchor_top = 1.0
	left.anchor_bottom = 1.0
	left.offset_left = 28
	left.offset_right = 188
	left.offset_bottom = -36
	left.grow_vertical = Control.GROW_DIRECTION_BEGIN
	var back := UiTheme.button("Màn tiêu đề")
	back.name = "BackButton"
	back.pressed.connect(_on_back)
	left.add_child(back)
	if _on_settings.is_valid():
		var bs := UiTheme.button("Cài đặt")
		bs.name = "SettingsButton"
		bs.pressed.connect(_on_settings)
		left.add_child(bs)
	if _on_quit.is_valid():
		var bq := UiTheme.button("Thoát game")
		bq.name = "QuitButton"
		bq.pressed.connect(_on_quit)
		left.add_child(bq)
	for b in left.get_children():
		(b as Button).custom_minimum_size = Vector2(160, 40)
	add_child(left)


func _row_style(state: String) -> StyleBoxFlat:
	match state:
		"sel":
			var sb := UiTheme.box(Color(Bronze.BR_MID, 0.22), 8, 2, Bronze.BR_LIGHT, 8)
			sb.shadow_color = Color(Bronze.BR_LIGHT, 0.25)
			sb.shadow_size = 6
			return sb
		"hover":
			return UiTheme.box(Color(1, 1, 1, 0.07), 8, 1, Color(Bronze.BR_MID, 0.9), 8)
		"empty":
			return UiTheme.box(Color(0, 0, 0, 0.18), 8, 1, Color(Bronze.BR, 0.35), 8)
	return UiTheme.box(Color(0, 0, 0, 0.3), 8, 1, Color(Bronze.BR, 0.6), 8)


## Một dòng trong danh sách: chân dung + tên + Lv · lớp + Thiên phú; ô trống = "+ Tạo nhân vật mới".
func _row(n: int) -> Button:
	var s: Dictionary = slots_info[n - 1]
	var b := Button.new()
	b.name = "Slot_%d" % n
	b.focus_mode = Control.FOCUS_NONE
	b.custom_minimum_size = Vector2(0, 76)
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var h := UiTheme.hbox(10)
	h.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	h.offset_left = 8
	h.offset_right = -10
	b.add_child(h)
	if s.is_empty():
		for st in ["normal", "pressed", "disabled", "focus"]:
			b.add_theme_stylebox_override(st, _row_style("empty"))
		b.add_theme_stylebox_override("hover", _row_style("hover"))
		var plus := _label("+", 34, Color(Bronze.BR_MID, 0.9), Bronze.title_font())
		plus.custom_minimum_size = Vector2(60, 0)
		h.add_child(plus)
		var t := _label("Ô trống — Tạo nhân vật mới", 15, Color("#b9ab8c"))
		t.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		t.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		h.add_child(t)
		b.pressed.connect(_on_new)
	else:
		var frame := PanelContainer.new()
		frame.add_theme_stylebox_override("panel", UiTheme.box(Color(0, 0, 0, 0.4), 6, 1, Color(Bronze.BR_MID, 0.8), 2))
		frame.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		frame.add_child(UiTheme.icon_rect(SpriteLib.icon("portrait-" + str(s.class_id)), 58))
		h.add_child(frame)
		var v := UiTheme.vbox(0)
		v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		v.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		var nm := _label(str(s.name), 17, Bronze.GOLD_TEXT, UiTheme.bold_font())
		nm.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		nm.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		v.add_child(nm)
		var cl := _label(class_line(s), 14, Color("#efe6cf"))
		cl.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		cl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		v.add_child(cl)
		var t: Dictionary = Talents.get_talent(str(s.talent))
		if not t.is_empty():
			var tl := _label("Thiên phú %s · %s" % [t.rank, t.name], 12, Talents.rank_color(str(t.rank)))
			tl.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
			tl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
			v.add_child(tl)
		h.add_child(v)
		b.pressed.connect(func(): select(n))
		b.gui_input.connect(func(e: InputEvent):
			if e is InputEventMouseButton and e.double_click and e.button_index == MOUSE_BUTTON_LEFT:
				_on_play.call(n))
	_ignore_mouse(h)
	return b


func _ignore_mouse(c: Control) -> void:
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for ch in c.get_children():
		if ch is Control:
			_ignore_mouse(ch)


## Chọn ô n (có nhân vật): tô dòng, cập nhật khối tên + sân khấu. n = 0 → chưa có nhân vật nào.
func select(n: int) -> void:
	if n > 0 and slots_info[n - 1].is_empty():
		return
	var changed := n != selected
	selected = n
	for k in _rows:
		var b: Button = _rows[k]
		if slots_info[k - 1].is_empty():
			continue
		var st := "sel" if k == n else "normal"
		for s in ["normal", "pressed", "focus", "disabled"]:
			b.add_theme_stylebox_override(s, _row_style(st))
		b.add_theme_stylebox_override("hover", _row_style("sel" if k == n else "hover"))
	_play_b.disabled = n == 0
	_del_b.disabled = n == 0
	if n == 0:
		_name_l.text = ""
		_class_l.text = "Chưa có nhân vật"
		_talent_l.text = ""
		_meta_l.text = "Bấm \"Tạo nhân vật mới\" để bắt đầu hành trình"
		stage.show_hero("", {}, Color(1.0, 0.86, 0.55))
		return
	var s: Dictionary = slots_info[n - 1]
	_name_l.text = str(s.name)
	_class_l.text = class_line(s)
	var t: Dictionary = Talents.get_talent(str(s.talent))
	var col := Color(1.0, 0.86, 0.55)
	if t.is_empty():
		_talent_l.text = ""
	else:
		col = Talents.rank_color(str(t.rank))
		_talent_l.text = "Thiên phú %s · %s" % [t.rank, t.name]
	_talent_l.add_theme_color_override("font_color", col)
	var mins := roundi(float(s.get("play_seconds", 0.0)) / 60.0)
	var meta := "Đã chơi %d giờ %02d phút" % [mins / 60, mins % 60]
	var reg := region_name(str(s.get("map_id", "")))
	_meta_l.text = (reg + "  ·  " + meta) if reg != "" else meta
	if changed or stage.class_id == "":
		stage.show_hero(str(s.class_id), s.get("look", {}), col)


func _play_selected() -> void:
	if selected > 0:
		_on_play.call(selected)


func _delete_selected() -> void:
	if selected > 0:
		_on_delete.call(selected)


## Ô có nhân vật kế tiếp theo hướng dir (±1), vòng quanh.
func step(dir: int) -> int:
	var count := slots_info.size()
	var n := selected if selected > 0 else 1
	for i in count:
		n = posmod(n - 1 + dir, count) + 1
		if not slots_info[n - 1].is_empty():
			return n
	return selected


func _unhandled_key_input(e: InputEvent) -> void:
	if not is_visible_in_tree() or not e.is_pressed() or e.is_echo():
		return
	# bảng Cài đặt (hoặc lớp phủ khác) đang mở đè lên thì không nhận phím
	if get_parent() != null:
		for c in get_parent().get_children().slice(get_index() + 1):
			if c is Control and (c as Control).visible:
				return
	if e.is_action("ui_up") or e.is_action("ui_left"):
		select(step(-1))
	elif e.is_action("ui_down") or e.is_action("ui_right"):
		select(step(1))
	elif e.is_action("ui_accept"):
		_play_selected()
	elif e.is_action("ui_cancel"):
		_on_back.call()
	elif e is InputEventKey and e.keycode == KEY_DELETE:
		_delete_selected()
	else:
		return
	get_viewport().set_input_as_handled()
