extends Control
## Bảng phủ giữa màn hình (Chỉ số, Bản đồ khai phá). Lớp con dựng nội dung trong _render().

const UiTheme = preload("res://scripts/ui/ui_theme.gd")

var world
var box: PanelContainer
var _dim: ColorRect


func _ready() -> void:
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	visible = false
	_dim = ColorRect.new()
	_dim.color = Color(0.02, 0.03, 0.04, 0.6)
	_dim.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	_dim.gui_input.connect(_on_dim_input)
	add_child(_dim)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	center.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(center)
	box = PanelContainer.new()
	box.theme_type_variation = "SolidPanel"
	center.add_child(box)


func _on_dim_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		close()


func is_open() -> bool:
	return visible


func open(w) -> void:
	world = w
	visible = true
	refresh()


func close() -> void:
	visible = false


func toggle(w) -> void:
	if visible:
		close()
	else:
		open(w)


## Dựng lại toàn bộ nội dung bảng.
func refresh() -> void:
	for c in box.get_children():
		box.remove_child(c)
		c.queue_free()
	var content := UiTheme.vbox(10)
	box.add_child(content)
	_render(content)


func _render(_content: VBoxContainer) -> void:
	pass


func _header(content: VBoxContainer, title: String, close_label: String) -> void:
	var row := UiTheme.hbox()
	row.add_child(UiTheme.label(title, "Heading"))
	row.add_child(UiTheme.spacer())
	var b := UiTheme.button(close_label)
	b.pressed.connect(close)
	row.add_child(b)
	content.add_child(row)
