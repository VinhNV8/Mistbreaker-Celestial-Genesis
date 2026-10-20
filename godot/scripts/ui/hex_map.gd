extends Control
## Lưới khai phá lục giác: vẽ bằng _draw, bấm chuột để chọn ô.

signal tile_pressed(id: int)

const Explore = preload("res://scripts/core/explore.gd")
const UiTheme = preload("res://scripts/ui/ui_theme.gd")

const HEX := 46.0
const BASE := Vector2(440, 330)

var profile
var selected := 0


func _init() -> void:
	custom_minimum_size = BASE
	mouse_filter = MOUSE_FILTER_STOP


func _origin() -> Vector2:
	return (size - BASE) / 2.0


func _center(t: Dictionary) -> Vector2:
	return _origin() + Vector2(220.0 + HEX * sqrt(3.0) * (t.q + t.r / 2.0), 130.0 + HEX * 1.5 * t.r)


func _points(c: Vector2, radius: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in 6:
		pts.append(c + Vector2.from_angle(deg_to_rad(60.0 * i - 30.0)) * radius)
	return pts


func _draw() -> void:
	if profile == null:
		return
	var font := UiTheme.bold_font()
	for t in profile.tiles:
		var c := _center(t)
		var pts := _points(c, HEX - 3.0)
		var info: Dictionary = Explore.EVENT_INFO[t.event]
		var seen := Explore.is_event_visible(profile.tiles, t, profile.talent)
		var revealable: bool = t.status == "fog" and Explore.reveal_blocker(profile, t) == ""
		var fill: Color
		var border := Color(1, 1, 1, 0.12)
		match t.status:
			"fog":
				fill = Color("#3a4152") if revealable else Color("#232731")
				if revealable:
					border = Color("#9aa7ff")
			"revealed":
				fill = Color(Color(info.color), 0.5)
				border = Color(1, 1, 1, 0.55)
			_:
				fill = Color(info.color)
				border = UiTheme.GOLD
		if int(t.id) == selected:
			border = Color.WHITE
		draw_colored_polygon(pts, fill)
		var closed := pts.duplicate()
		closed.append(pts[0])
		draw_polyline(closed, border, 3.5 if int(t.id) == selected else 2.0, true)
		var text: String = info.short if seen else "?"
		var color := UiTheme.TEXT if t.status != "fog" else (Color("#9ec8ff") if seen else UiTheme.MUTED)
		draw_string(font, c + Vector2(-HEX, 5), text, HORIZONTAL_ALIGNMENT_CENTER, HEX * 2.0, 14, color)


func _gui_input(event: InputEvent) -> void:
	if profile == null:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		for t in profile.tiles:
			if Geometry2D.is_point_in_polygon(event.position, _points(_center(t), HEX - 3.0)):
				tile_pressed.emit(int(t.id))
				accept_event()
				return
