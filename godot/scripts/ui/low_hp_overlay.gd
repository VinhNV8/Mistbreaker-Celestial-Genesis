extends Control
## UI-55 (docs/38): cảnh báo máu thấp — HP < THRESHOLD: viền màn hình đỏ đập theo nhịp tim (nhanh dần khi máu càng
## thấp), không che giữa màn hình. Tắt được ở Cài đặt → Trợ năng ("low_hp_warn"). HUD gọi update_hp(hp, max_hp, dt).

const Settings = preload("res://scripts/core/settings.gd")

const THRESHOLD := 0.3
const EDGE := 90.0

var level := 0.0
var _t := 0.0


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)


## level 0..1: 0 = máu ≥ 30%, 1 = sắp chết.
static func level_of(hp: float, max_hp: float) -> float:
	if max_hp <= 0.0 or hp <= 0.0:
		return 0.0
	var r := hp / max_hp
	return 0.0 if r >= THRESHOLD else clampf(1.0 - r / THRESHOLD, 0.0, 1.0) * 0.7 + 0.3


func update_hp(hp: float, max_hp: float, dt: float) -> void:
	var on := bool(Settings.values.get("low_hp_warn", true))
	level = level_of(hp, max_hp) if on else 0.0
	_t += dt * (1.6 + 1.6 * level)
	visible = level > 0.0
	if visible:
		queue_redraw()


func _draw() -> void:
	# nhịp tim: 2 đập ngắn rồi nghỉ
	var ph := fposmod(_t, 1.0)
	var beat := maxf(exp(-pow((ph - 0.08) / 0.06, 2.0)), 0.7 * exp(-pow((ph - 0.3) / 0.06, 2.0)))
	var a := (0.18 + 0.32 * beat) * (0.5 + 0.5 * level)
	var red := Color(0.75, 0.04, 0.06, a)
	var clear := Color(0.75, 0.04, 0.06, 0.0)
	var s := size
	var e := EDGE * (0.8 + 0.4 * level)
	# 4 dải gradient từ mép vào trong
	draw_polygon(PackedVector2Array([Vector2(0, 0), Vector2(s.x, 0), Vector2(s.x, e), Vector2(0, e)]), PackedColorArray([red, red, clear, clear]))
	draw_polygon(PackedVector2Array([Vector2(0, s.y - e), Vector2(s.x, s.y - e), Vector2(s.x, s.y), Vector2(0, s.y)]), PackedColorArray([clear, clear, red, red]))
	draw_polygon(PackedVector2Array([Vector2(0, 0), Vector2(e, 0), Vector2(e, s.y), Vector2(0, s.y)]), PackedColorArray([red, clear, clear, red]))
	draw_polygon(PackedVector2Array([Vector2(s.x - e, 0), Vector2(s.x, 0), Vector2(s.x, s.y), Vector2(s.x - e, s.y)]), PackedColorArray([clear, red, red, clear]))
