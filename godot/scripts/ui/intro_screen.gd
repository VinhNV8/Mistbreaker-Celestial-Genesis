extends ColorRect
## C1-10 (TN-01): cảnh mở đầu 5 trang — chữ hiện dần, hình vẽ bằng code. Space/Enter/chuột sang trang, nút Bỏ qua.

const UiTheme = preload("res://scripts/ui/ui_theme.gd")
const SpriteLib = preload("res://scripts/view/sprite_lib.gd")

const PAGES := [
	"Một nghìn năm trước, Huyền Thổ là một lục địa thống nhất. Bia Đá Thiên Đạo ban Thiên phú cho những ai xứng đáng.",
	"Rồi trời nứt làm chín. Kẻ mạnh nhất thời ấy vươn tay đoạt lấy Thiên phú của chính Thiên Đạo — đại nạn Thiên Liệt xé lục địa thành chín mảnh.",
	"Sương mù Hư Vô tràn ra từ những vết nứt. Trong sương, quái vật sinh sôi không ngừng.",
	"Chỉ những người được Bia Đá ban Thiên phú — Khai Giới Giả — mới đủ sức xua tan sương mù, giành lại từng tấc đất.",
	"Làng Thanh Thạch, ngôi làng cuối cùng bên bờ sương. Hôm nay là Lễ Thức Tỉnh của con.",
]
const CHARS_PER_SEC := 38.0


class Art:
	extends Control
	var page := 0
	var t := 0.0

	func _process(delta: float) -> void:
		t += delta
		queue_redraw()

	func _draw() -> void:
		var c := size / 2.0
		match page:
			0:
				# lục địa nguyên vẹn, Bia Đá ở giữa
				draw_circle(c, 150.0, Color("#2c4a32"))
				draw_circle(c + Vector2(-40, -20), 90.0, Color("#3b6040"))
				draw_circle(c, 60.0, Color(1.0, 0.86, 0.55, 0.15 + 0.08 * sin(t * 2.0)))
				SpriteLib.draw_env(self, "stele", c + Vector2(0, 40), Color.WHITE, 1.5)
			1:
				# chín vết nứt toả ra, trời đỏ
				draw_circle(c, 150.0, Color("#2c3a2a"))
				for i in 9:
					var a := TAU * i / 9.0 + 0.3
					var p0 := c + Vector2.from_angle(a) * 20.0
					var p1 := c + Vector2.from_angle(a + 0.15 * sin(t + i)) * 170.0
					draw_line(p0, p1, Color(1.0, 0.35, 0.25, 0.9), 4.0, true)
				draw_circle(c, 30.0 + 6.0 * sin(t * 6.0), Color(1.0, 0.4, 0.3, 0.5))
			2:
				# sương Hư Vô với mắt quái
				for i in 14:
					var p := c + Vector2(sin(t * 0.5 + i * 1.7) * 200.0, cos(t * 0.4 + i * 2.3) * 110.0)
					draw_circle(p, 60.0, Color(0.45, 0.3, 0.75, 0.12))
				for i in 5:
					var p := c + Vector2(-180 + i * 90, 10.0 * sin(t * 2.0 + i))
					SpriteLib.draw_frame(self, "wolf", "idle", int(t * 3.0) % 2, p + Vector2(0, 40), i % 2 == 0, Color(0.6, 0.45, 1.0, 0.85), 1.4)
			3:
				# Khai Giới Giả trước Bia Đá
				draw_circle(c + Vector2(0, -10), 110.0, Color(1.0, 0.86, 0.55, 0.10 + 0.05 * sin(t * 3.0)))
				SpriteLib.draw_env(self, "stele", c + Vector2(0, 30), Color.WHITE, 1.5)
				SpriteLib.draw_frame(self, "hero-kiem-khach", "idle", int(t * 3.0) % 2, c + Vector2(-110, 70), false, Color.WHITE, 1.6)
				SpriteLib.draw_frame(self, "hero-tho-san", "idle", int(t * 3.0) % 2, c + Vector2(110, 70), true, Color.WHITE, 1.6)
			4:
				# Làng Thanh Thạch bên bờ sương
				draw_rect(Rect2(Vector2(0, c.y + 40), Vector2(size.x, size.y)), Color("#1c3226"))
				for i in 3:
					SpriteLib.draw_env(self, "hut", c + Vector2(-150 + i * 150, 70 - (i % 2) * 20), Color.WHITE, 1.3)
				SpriteLib.draw_env(self, "stele", c + Vector2(0, 110), Color.WHITE, 1.2)
				for i in 6:
					draw_circle(Vector2(size.x - 60.0 - i * 30.0, c.y + 20.0 * sin(t + i)), 80.0, Color(0.45, 0.3, 0.75, 0.10))


var on_done: Callable
var _page := 0
var _shown := 0.0
var _text: Label
var _art: Art
var _counter: Label


func _init(done: Callable) -> void:
	on_done = done


func _ready() -> void:
	color = Color(0.03, 0.03, 0.05)
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	_art = Art.new()
	_art.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	_art.offset_bottom = -200
	_art.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(_art)
	_text = UiTheme.label("", "Heading")
	_text.add_theme_font_size_override("font_size", 22)
	_text.add_theme_color_override("font_color", Color("#efe4c8"))
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_text.set_anchors_and_offsets_preset(PRESET_BOTTOM_WIDE)
	_text.offset_top = -190
	_text.offset_bottom = -70
	_text.offset_left = 160
	_text.offset_right = -160
	add_child(_text)
	_counter = UiTheme.label("", "Small")
	_counter.set_anchors_and_offsets_preset(PRESET_BOTTOM_LEFT)
	_counter.position = Vector2(24, -44)
	add_child(_counter)
	var skip := UiTheme.button("Bỏ qua")
	skip.name = "SkipButton"
	skip.set_anchors_and_offsets_preset(PRESET_TOP_RIGHT)
	skip.position = Vector2(-120, 20)
	skip.pressed.connect(_finish)
	add_child(skip)
	_show(0)


func _show(i: int) -> void:
	_page = i
	_shown = 0.0
	_art.page = i
	_art.t = 0.0
	_counter.text = "%d / %d   ·   Space hoặc nhấp chuột để tiếp" % [i + 1, PAGES.size()]


func _process(delta: float) -> void:
	_shown += delta * CHARS_PER_SEC
	var full: String = PAGES[_page]
	_text.text = full.substr(0, mini(full.length(), int(_shown)))


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_advance()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode in [KEY_SPACE, KEY_ENTER, KEY_KP_ENTER]:
		_advance()
		get_viewport().set_input_as_handled()


func _advance() -> void:
	var full: String = PAGES[_page]
	if int(_shown) < full.length():
		_shown = full.length()
	elif _page + 1 < PAGES.size():
		_show(_page + 1)
	else:
		_finish()


func _finish() -> void:
	if on_done.is_valid():
		var cb := on_done
		on_done = Callable()
		cb.call()


## Smoke test: nhảy tới trang i, hiện đủ chữ.
func jump(i: int) -> void:
	_show(i)
	_shown = 999.0
