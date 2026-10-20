extends PanelContainer
## C1-11: hộp thoại — chân dung, tên người nói, lời chạy chữ. Space/Enter/chuột để tiếp.
## Khi đang mở, main.gd dừng thế giới (giống bảng phủ).

const UiTheme = preload("res://scripts/ui/ui_theme.gd")
const SpriteLib = preload("res://scripts/view/sprite_lib.gd")
const Story = preload("res://scripts/data/story.gd")

const PORTRAITS := {
	Story.ELDER: "npc-elder",
	"Thương nhân lữ hành": "npc-merchant",
	"Sói Chúa Hư Vô": "boss",
	"Lão Thụ Sương Mù": "lao-thu",
}
const CHARS_PER_SEC := 55.0


class Portrait:
	extends Control
	var sprite := ""
	var hero := {}
	var t := 0.0

	func _process(delta: float) -> void:
		t += delta
		queue_redraw()

	func _draw() -> void:
		var at := Vector2(size.x / 2.0, size.y - 6.0)
		if not hero.is_empty():
			SpriteLib.draw_hero(self, hero.class_id, hero.look, "idle", int(t * 3.0) % 2, at, false, Color.WHITE, 1.4)
		elif SpriteLib.has_sprite(sprite):
			var big: bool = SpriteLib.data().sprites[sprite].w > 32
			SpriteLib.draw_frame(self, sprite, "idle", int(t * 3.0) % 2, at, true, Color.WHITE, 0.75 if big else 1.4)


var auto_advance := false
var _lines: Array = []
var _shown := 0.0
var _name: Label
var _text: Label
var _portrait: Portrait
var _hint: Label
var _player_name := ""
var _hero := {}
var _auto_t := 0.0


func _ready() -> void:
	add_theme_stylebox_override("panel", UiTheme.box(Color(0.06, 0.07, 0.1, 0.96), 12, 2, UiTheme.GOLD, 14))
	var row := UiTheme.hbox(14)
	add_child(row)
	_portrait = Portrait.new()
	_portrait.custom_minimum_size = Vector2(100, 100)
	row.add_child(_portrait)
	var col := UiTheme.vbox(4)
	row.add_child(col)
	_name = UiTheme.label("", "Heading")
	_name.add_theme_color_override("font_color", UiTheme.GOLD)
	col.add_child(_name)
	_text = UiTheme.label("", "", 600)
	_text.add_theme_font_size_override("font_size", 17)
	_text.custom_minimum_size.y = 56
	col.add_child(_text)
	_hint = UiTheme.label("Space / nhấp chuột để tiếp", "Small")
	col.add_child(_hint)
	visible = false
	mouse_filter = MOUSE_FILTER_STOP


func setup(player_name: String, class_id: String, look: Dictionary) -> void:
	_player_name = player_name
	_hero = {"class_id": class_id, "look": look}


func is_open() -> bool:
	return visible


func push(dialog_id: String) -> void:
	for line in Story.DIALOGS.get(dialog_id, []):
		_lines.append(line)
	if not visible and not _lines.is_empty():
		_show_next()


func _show_next() -> void:
	if _lines.is_empty():
		visible = false
		return
	var line: Array = _lines.pop_front()
	var who := str(line[0])
	var is_hero := who == "{name}"
	_name.text = _player_name if is_hero else who
	_text.set_meta("full", str(line[1]).replace("{name}", _player_name))
	_shown = 0.0
	_auto_t = 0.0
	_portrait.hero = _hero if is_hero else {}
	_portrait.sprite = PORTRAITS.get(who, "")
	visible = true
	_layout()


func _layout() -> void:
	reset_size()
	var vp := get_viewport_rect().size
	position = Vector2((vp.x - size.x) / 2.0, vp.y - size.y - 110.0)


func _process(delta: float) -> void:
	if not visible:
		return
	var full := str(_text.get_meta("full", ""))
	_shown += delta * CHARS_PER_SEC
	_text.text = full.substr(0, mini(full.length(), int(_shown)))
	if auto_advance:
		_auto_t += delta
		if _auto_t > 0.4:
			_shown = 9999.0
			advance()


func advance() -> void:
	var full := str(_text.get_meta("full", ""))
	if int(_shown) < full.length():
		_shown = full.length()
	else:
		_show_next()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		advance()
		accept_event()


func _unhandled_input(event: InputEvent) -> void:
	if visible and event is InputEventKey and event.pressed and not event.echo and event.keycode in [KEY_SPACE, KEY_ENTER, KEY_KP_ENTER]:
		advance()
		get_viewport().set_input_as_handled()
