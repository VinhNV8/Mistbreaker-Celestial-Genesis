extends Control
## GN-3 (docs/45 Q223): bộ đếm combo lớn kiểu ARPG — số to viền tối + chữ "Combo" ở mép trái giữa màn hình, nảy lên mỗi lần
## tăng, mờ dần khi đứt chuỗi; dòng nhỏ "+n% EXP" bên dưới. Không nhận chuột. Hiện từ MIN_SHOW combo (như dòng cũ UI-54).
## Cài đặt → Hiển thị → "Bộ đếm combo": Lớn (mặc định) / Nhỏ (dòng chữ cũ trên cụm nút) / Tắt.

const UiTheme = preload("res://scripts/ui/ui_theme.gd")

const MIN_SHOW := 5
const POP_TIME := 0.18
const POP_SCALE := 1.35
const FADE_TIME := 0.45
const NUM_SIZE := 54
const WORD_SIZE := 22

var combo := 0
var exp_pct := 0
var _pop := 0.0
var _alpha := 0.0
var _last := 0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(240, 96)
	size = custom_minimum_size


## Gọi mỗi khung từ HUD.
func set_combo(n: int, pct: int, delta: float) -> void:
	if n > _last and n >= MIN_SHOW:
		_pop = POP_TIME
	_last = n
	if n >= MIN_SHOW:
		combo = n
		exp_pct = pct
		_alpha = 1.0
	else:
		_alpha = maxf(0.0, _alpha - delta / FADE_TIME)
	_pop = maxf(0.0, _pop - delta)
	visible = _alpha > 0.0
	if visible:
		queue_redraw()


## Hệ số phóng hiện tại của con số (1 khi đứng yên) — test đọc.
func pop_scale() -> float:
	var t := _pop / POP_TIME
	return 1.0 + (POP_SCALE - 1.0) * t * t


func _draw() -> void:
	var font := UiTheme.bold_font()
	var a := _alpha
	var num := str(combo)
	var ns := UiTheme.fs(NUM_SIZE)
	var ws := UiTheme.fs(WORD_SIZE)
	var k := pop_scale()
	var num_w := font.get_string_size(num, HORIZONTAL_ALIGNMENT_LEFT, -1, ns).x
	var base := Vector2(8, ns * 0.95)
	# số: nảy quanh tâm của chính nó
	var c := base + Vector2(num_w * 0.5, -ns * 0.35)
	draw_set_transform(c, -0.06, Vector2(k, k))
	var o := -c + base
	var hot := clampf(float(combo - MIN_SHOW) / 60.0, 0.0, 1.0)
	var fill := Color("#fff4d6").lerp(Color("#ffb347"), hot)
	draw_string_outline(font, o, num, HORIZONTAL_ALIGNMENT_LEFT, -1, ns, 10, Color(0.08, 0.05, 0.03, 0.85 * a))
	draw_string(font, o, num, HORIZONTAL_ALIGNMENT_LEFT, -1, ns, Color(fill, a))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var wp := base + Vector2(num_w + 10.0, -4.0)
	draw_string_outline(font, wp, "Combo", HORIZONTAL_ALIGNMENT_LEFT, -1, ws, 6, Color(0.08, 0.05, 0.03, 0.8 * a))
	draw_string(font, wp, "Combo", HORIZONTAL_ALIGNMENT_LEFT, -1, ws, Color(UiTheme.GOLD, 0.95 * a))
	if exp_pct > 0:
		var ep := base + Vector2(4, ws + 8.0)
		var t := "+%d%% EXP" % exp_pct
		draw_string_outline(font, ep, t, HORIZONTAL_ALIGNMENT_LEFT, -1, UiTheme.fs(14), 5, Color(0.05, 0.04, 0.03, 0.75 * a))
		draw_string(font, ep, t, HORIZONTAL_ALIGNMENT_LEFT, -1, UiTheme.fs(14), Color(0.86, 0.95, 0.78, 0.9 * a))
