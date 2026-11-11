extends "res://scripts/ui/modal.gd"
## WB-1 (docs/48 §B): thẻ chào khi vào lại game với nhân vật cũ (main._on_continue). Game tạm dừng tới khi bấm
## "Vào game" / Esc / bấm ra ngoài. Dữ liệu dựng ở core/welcome.gd.

const SpriteLib = preload("res://scripts/view/sprite_lib.gd")
const W := 520.0
const TONE := {"": Color("#e8dcc4"), "good": Color("#8ae07a"), "todo": Color("#ffd36a")}

var data := {}


func show_welcome(w, d: Dictionary) -> void:
	data = d
	open(w)


func _render(content: VBoxContainer) -> void:
	content.custom_minimum_size.x = W
	content.add_theme_constant_override("separation", 8)
	var head := UiTheme.hbox(12)
	var portrait := UiTheme.icon_rect(SpriteLib.icon("portrait-" + str(world.profile.class_id)), 64)
	if portrait.texture != null:
		head.add_child(portrait)
	var hv := UiTheme.vbox(2)
	var t := UiTheme.strong(str(data.get("title", "")), 22, UiTheme.GOLD)
	t.name = "WelcomeTitle"
	t.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	t.custom_minimum_size.x = W - 90
	hv.add_child(t)
	hv.add_child(UiTheme.label(str(data.get("subtitle", "")), "Small"))
	head.add_child(hv)
	content.add_child(head)
	for sec in data.get("sections", []):
		content.add_child(HSeparator.new())
		content.add_child(UiTheme.label(str(sec.head), "Eyebrow"))
		for ln in sec.lines:
			var row := UiTheme.hbox(8)
			var ic := UiTheme.icon_rect(SpriteLib.icon(str(ln[0])), 20)
			ic.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
			row.add_child(ic)
			var l := UiTheme.label(str(ln[1]), "", W - 34)
			l.add_theme_color_override("font_color", TONE.get(str(ln[2]), TONE[""]))
			row.add_child(l)
			content.add_child(row)
	content.add_child(HSeparator.new())
	var b := UiTheme.button("Vào game", true)
	b.name = "WelcomeGo"
	b.custom_minimum_size = Vector2(0, 42)
	b.pressed.connect(close)
	content.add_child(b)
