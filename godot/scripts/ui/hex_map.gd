extends Control
## Lưới khai phá lục giác: vẽ bằng _draw, bấm chuột để chọn ô.
## C1-21 / Spec_Notes N10: lưới 40 ô tự co cỡ ô cho vừa khung (trước đây cỡ ô cố định nên tràn ra ngoài bảng).

signal tile_pressed(id: int)

const Explore = preload("res://scripts/core/explore.gd")
const UiTheme = preload("res://scripts/ui/ui_theme.gd")

const BASE := Vector2(470, 440)
## Màu nền ô sương theo map con (zone 1–3).
const ZONE_FOG := {1: Color("#3a4152"), 2: Color("#334a3e"), 3: Color("#3c3352")}

var profile
var selected := 0
var _hex := 30.0
var _offset := Vector2.ZERO


func _init() -> void:
	custom_minimum_size = BASE
	mouse_filter = MOUSE_FILTER_STOP


static func _unit(t: Dictionary) -> Vector2:
	return Vector2(sqrt(3.0) * (t.q + t.r / 2.0), 1.5 * t.r)


## Tính cỡ ô và độ lệch để toàn bộ lưới nằm gọn trong khung.
func _fit() -> void:
	var lo := Vector2(INF, INF)
	var hi := Vector2(-INF, -INF)
	for t in profile.tiles:
		var u := _unit(t)
		lo = Vector2(minf(lo.x, u.x), minf(lo.y, u.y))
		hi = Vector2(maxf(hi.x, u.x), maxf(hi.y, u.y))
	var span := hi - lo + Vector2(sqrt(3.0), 2.0)
	_hex = minf((size.x - 8.0) / span.x, (size.y - 8.0) / span.y)
	var used := (hi - lo) * _hex
	_offset = (size - used) / 2.0 - lo * _hex


func _center(t: Dictionary) -> Vector2:
	return _offset + _unit(t) * _hex


func _points(c: Vector2, radius: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in 6:
		pts.append(c + Vector2.from_angle(deg_to_rad(60.0 * i - 30.0)) * radius)
	return pts


func _draw() -> void:
	if profile == null:
		return
	_fit()
	var font := UiTheme.bold_font()
	var fsize := clampi(int(_hex * 0.36), 9, 14)
	for t in profile.tiles:
		var c := _center(t)
		var pts := _points(c, _hex - 2.0)
		var info: Dictionary = Explore.EVENT_INFO[t.event]
		var seen := Explore.is_event_visible(profile.tiles, t, profile.talent)
		var zone := Explore.zone_of(t)
		var locked: bool = zone == 3 and not profile.boss_defeated and t.status == "fog"
		var revealable: bool = t.status == "fog" and Explore.reveal_blocker(profile, t) == ""
		var fill: Color
		var border := Color(1, 1, 1, 0.12)
		match t.status:
			"fog":
				fill = ZONE_FOG[zone].lightened(0.12) if revealable else ZONE_FOG[zone].darkened(0.35 if locked else 0.15)
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
		draw_polyline(closed, border, 3.0 if int(t.id) == selected else 1.5, true)
		var text: String = info.short if seen else ("—" if locked else "?")
		var color := UiTheme.TEXT if t.status != "fog" else (Color("#9ec8ff") if seen else UiTheme.MUTED)
		draw_string(font, c + Vector2(-_hex, fsize * 0.35), text, HORIZONTAL_ALIGNMENT_CENTER, _hex * 2.0, fsize, color)


func _gui_input(event: InputEvent) -> void:
	if profile == null:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_fit()
		for t in profile.tiles:
			if Geometry2D.is_point_in_polygon(event.position, _points(_center(t), _hex - 2.0)):
				tile_pressed.emit(int(t.id))
				accept_event()
				return
