extends ColorRect
## C1-02: Tạo nhân vật — tên, giới tính, màu da, kiểu tóc, màu tóc, lớp — trên 1 màn hình, xem trước nhân vật động.
## Gọi on_done với {name, look, class_id}.

const UiTheme = preload("res://scripts/ui/ui_theme.gd")
const Looks = preload("res://scripts/data/looks.gd")
const Classes = preload("res://scripts/data/classes.gd")
const SpriteLib = preload("res://scripts/view/sprite_lib.gd")


## Ô xem trước: vẽ nhân vật lần lượt đứng → chạy → đánh.
class Preview:
	extends Control
	var class_id := "kiem-khach"
	var look := {}
	var t := 0.0

	func _process(delta: float) -> void:
		t += delta
		queue_redraw()

	func _draw() -> void:
		var c := size / 2.0 + Vector2(0, size.y * 0.32)
		draw_circle(c, 70.0, Color(0, 0, 0, 0.0))
		draw_set_transform(c, 0.0, Vector2(1.0, 0.3))
		draw_circle(Vector2.ZERO, 90.0, Color(0.3, 0.4, 0.3, 0.35))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		var phase := int(t / 2.5) % 3
		var anim: String = ["idle", "run", "attack"][phase]
		var hs := Looks.base_sprite(class_id, look)
		var id := hs if SpriteLib.has_sprite(hs) else "hero-" + class_id
		if not SpriteLib.has_sprite(id):
			return
		var frame := SpriteLib.frame_at(id, anim, fmod(t, 2.5))
		SpriteLib.draw_hero(self, class_id, look, anim, frame, c, false, Color.WHITE, 3.0)


var on_done: Callable
var _look := Looks.default_look("nam")
var _class := "kiem-khach"
var _name_edit: LineEdit
var _preview: Preview
var _ok: Button
var _hint: Label
var _rows := {}


func _init(done: Callable) -> void:
	on_done = done


func _ready() -> void:
	color = UiTheme.BG
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	add_child(center)
	var col := UiTheme.vbox(10)
	center.add_child(col)
	var eb := UiTheme.label("TẠO NHÂN VẬT", "Eyebrow")
	eb.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(eb)
	var h := UiTheme.label("Người được Bia Đá gọi tên", "Heading")
	h.add_theme_font_size_override("font_size", 30)
	h.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(h)

	var body := UiTheme.hbox(28)
	col.add_child(body)
	# Trái: xem trước
	var left := PanelContainer.new()
	left.add_theme_stylebox_override("panel", UiTheme.box(UiTheme.PANEL_SOLID, 14, 1, UiTheme.LINE, 12))
	_preview = Preview.new()
	_preview.custom_minimum_size = Vector2(300, 380)
	left.add_child(_preview)
	body.add_child(left)
	# Phải: lựa chọn
	var form := UiTheme.vbox(10)
	form.custom_minimum_size.x = 560
	body.add_child(form)

	form.add_child(UiTheme.label("Tên nhân vật (%d–%d ký tự)" % [Looks.NAME_MIN, Looks.NAME_MAX], "Small"))
	_name_edit = LineEdit.new()
	_name_edit.name = "NameEdit"
	_name_edit.placeholder_text = "Ví dụ: Lâm Phong"
	_name_edit.max_length = Looks.NAME_MAX
	_name_edit.text = ""
	_name_edit.text_changed.connect(func(_t): _validate())
	form.add_child(_name_edit)

	_choice_row(form, "gender", "Giới tính", Looks.GENDERS.map(func(g): return Looks.GENDER_NAMES[g]), func(i):
		var g: String = Looks.GENDERS[i]
		if g != _look.gender:
			var keep_color: int = _look.hair_color
			var keep_skin: int = _look.skin
			_look = Looks.default_look(g)
			_look.hair_color = keep_color
			_look.skin = keep_skin)
	_choice_row(form, "skin", "Màu da", Looks.SKIN_NAMES, func(i): _look.skin = i)
	_choice_row(form, "hair_style", "Kiểu tóc", Looks.HAIR_STYLES.map(func(s): return Looks.HAIR_STYLE_NAMES[s]), func(i):
		_look.hair_style = Looks.HAIR_STYLES[i])
	_choice_row(form, "hair_color", "Màu tóc", Looks.HAIR_COLORS.map(func(c): return c[0]), func(i): _look.hair_color = i)

	form.add_child(UiTheme.label("Lớp nhân vật", "Small"))
	var crow := UiTheme.hbox(10)
	form.add_child(crow)
	_rows["class"] = []
	for cid in Classes.ORDER:
		var c: Dictionary = Classes.DEFS[cid]
		var b := UiTheme.button("")
		b.name = "Class_" + cid
		b.custom_minimum_size = Vector2(275, 96)
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		var v := UiTheme.vbox(2)
		v.mouse_filter = MOUSE_FILTER_IGNORE
		v.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
		v.offset_left = 12
		v.offset_top = 8
		v.add_child(UiTheme.label("%s · %s" % [c.name, c.main], "Heading"))
		v.add_child(UiTheme.label(c.role, "Small"))
		var icons := UiTheme.hbox(4)
		for sk in c.skills:
			var ic := TextureRect.new()
			ic.texture = SpriteLib.icon("skill-" + str(sk.icon))
			ic.custom_minimum_size = Vector2(28, 28)
			ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			ic.tooltip_text = "%s — %s" % [sk.name, sk.text]
			icons.add_child(ic)
		v.add_child(icons)
		for n in [v, icons]:
			n.mouse_filter = MOUSE_FILTER_IGNORE
		b.add_child(v)
		var id: String = cid
		b.pressed.connect(func():
			_class = id
			_refresh())
		crow.add_child(b)
		_rows["class"].append(b)
	_hint = UiTheme.label("", "Small", 560)
	form.add_child(_hint)

	var row := UiTheme.hbox(12)
	var rnd := UiTheme.button("Ngẫu nhiên")
	rnd.pressed.connect(_randomize)
	row.add_child(rnd)
	_ok = UiTheme.button("Tới Bia Đá Thiên Đạo", true)
	_ok.name = "CreateButton"
	_ok.pressed.connect(_finish)
	row.add_child(_ok)
	form.add_child(row)
	_refresh()
	_name_edit.grab_focus()


func _choice_row(parent: Control, key: String, title: String, labels: Array, on_pick: Callable) -> void:
	var row := UiTheme.hbox(8)
	var l := UiTheme.label(title, "Small")
	l.custom_minimum_size.x = 90
	row.add_child(l)
	_rows[key] = []
	for i in labels.size():
		var b := UiTheme.button(str(labels[i]))
		b.custom_minimum_size = Vector2(70, 32)
		if key == "hair_color":
			var c: Color = Looks.HAIR_COLORS[i][1]
			b.add_theme_color_override("font_color", c.lightened(0.2))
		var idx: int = i
		b.pressed.connect(func():
			on_pick.call(idx)
			_refresh())
		row.add_child(b)
		_rows[key].append(b)
	parent.add_child(row)


func _refresh() -> void:
	var sel := {
		"gender": Looks.GENDERS.find(_look.gender),
		"skin": int(_look.skin),
		"hair_style": Looks.HAIR_STYLES.find(_look.hair_style),
		"hair_color": int(_look.hair_color),
		"class": Classes.ORDER.find(_class),
	}
	for key in _rows:
		var arr: Array = _rows[key]
		for i in arr.size():
			var b: Button = arr[i]
			var on: bool = i == int(sel[key])
			var c := UiTheme.GOLD if on else UiTheme.LINE
			b.add_theme_stylebox_override("normal", UiTheme.box(Color(c, 0.22 if on else 0.04), 8, 2 if on else 1, c, 6))
	_preview.class_id = _class
	_preview.look = _look
	_validate()


func _validate() -> void:
	var n := Looks.clean_name(_name_edit.text)
	_ok.disabled = n == ""
	var c: Dictionary = Classes.DEFS[_class]
	_hint.text = ("Nhập tên %d–%d ký tự để tiếp tục. " % [Looks.NAME_MIN, Looks.NAME_MAX] if n == "" else "") + str(c.description)


func _randomize() -> void:
	var names := ["Lâm Phong", "Tô Vân", "Mộc Lan", "Hàn Sơn", "Thanh Hà", "Vũ Minh", "Bạch Tuyết", "Diệp Thần"]
	_name_edit.text = names[randi() % names.size()]
	_look = {
		"gender": Looks.GENDERS[randi() % 2],
		"skin": randi() % Looks.SKIN_NAMES.size(),
		"hair_style": Looks.HAIR_STYLES[randi() % Looks.HAIR_STYLES.size()],
		"hair_color": randi() % Looks.HAIR_COLORS.size(),
	}
	_class = Classes.ORDER[randi() % Classes.ORDER.size()]
	_refresh()


func set_name_for_test(n: String) -> void:
	_name_edit.text = n
	_validate()


func _finish() -> void:
	var n := Looks.clean_name(_name_edit.text)
	if n == "":
		return
	on_done.call({"name": n, "look": _look.duplicate(), "class_id": _class})
