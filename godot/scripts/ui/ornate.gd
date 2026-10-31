extends RefCounted
## UI-27: mảnh trang trí cắt từ ảnh mẫu bảng Nhân vật (tools/art/ui_cut.py → assets/ui/).
## Đây là ảnh vẽ (không phải pixel art) nên lọc Linear; icon pixel đặt bên trong vẫn tự đặt Nearest (UiTheme.icon_rect).

const UiTheme = preload("res://scripts/ui/ui_theme.gd")
const SpriteLib = preload("res://scripts/view/sprite_lib.gd")

const DIR := "res://assets/ui/"


static func tex(id: String) -> Texture2D:
	return SpriteLib.texture(DIR + id + ".png")


## Ảnh vẽ phải lọc Linear (dự án mặc định Nearest cho pixel art).
static func linear(c: CanvasItem) -> void:
	c.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR


static func style(id: String, l: float, t: float, r: float, b: float, pad := Vector4(10, 8, 10, 8)) -> StyleBoxTexture:
	var sb := StyleBoxTexture.new()
	sb.texture = tex(id)
	sb.texture_margin_left = l
	sb.texture_margin_top = t
	sb.texture_margin_right = r
	sb.texture_margin_bottom = b
	sb.content_margin_left = pad.x
	sb.content_margin_top = pad.y
	sb.content_margin_right = pad.z
	sb.content_margin_bottom = pad.w
	return sb


## Khung cột: viền vàng mảnh, góc hoa văn chữ X, nền tối.
static func panel_style(pad := 16.0) -> StyleBoxTexture:
	return style("ui-panel", 32, 32, 32, 32, Vector4(pad, pad - 2, pad, pad - 2))


## Nền một hàng thuộc tính (viền vàng bo góc).
static func row_style() -> StyleBoxTexture:
	return style("ui-row", 18, 16, 18, 16, Vector4(10, 4, 12, 4))


## Nút vẽ: kind = "gold" (nút chính) | "dark" (nút phụ, ô chọn) | "plus" (nút + vuông).
static func button(b: Button, kind: String) -> void:
	var base: StyleBoxTexture
	match kind:
		"gold":
			base = style("ui-btn-gold", 37, 22, 37, 22, Vector4(18, 6, 18, 6))
		"plus":
			base = style("ui-btn-plus", 0, 0, 0, 0, Vector4(0, 0, 0, 0))
		_:
			base = style("ui-btn-dark", 14, 14, 14, 14, Vector4(12, 4, 12, 4))
	var hover := base.duplicate() as StyleBoxTexture
	hover.modulate_color = Color(1.18, 1.12, 1.0)
	var pressed := base.duplicate() as StyleBoxTexture
	pressed.modulate_color = Color(0.82, 0.78, 0.72)
	var disabled := base.duplicate() as StyleBoxTexture
	disabled.modulate_color = Color(0.45, 0.42, 0.4, 0.85)
	for e in [["normal", base], ["hover", hover], ["pressed", pressed], ["disabled", disabled], ["focus", StyleBoxEmpty.new()],
			["hover_pressed", pressed]]:
		b.add_theme_stylebox_override(e[0], e[1])
	var fc := Color("#2a1806") if kind == "gold" else Color("#e8d6a8")
	b.add_theme_color_override("font_color", fc)
	b.add_theme_color_override("font_hover_color", Color("#140a02") if kind == "gold" else Color.WHITE)
	b.add_theme_color_override("font_pressed_color", fc)
	b.add_theme_color_override("font_disabled_color", Color(fc, 0.55))
	b.add_theme_font_override("font", UiTheme.bold_font())
	linear(b)


## UI-28: nút là nguyên một ảnh vẽ (nút quay lại, X, + của thanh tiêu đề) — rê chuột sáng lên, bấm tối đi.
static func image_button(id: String, w: float, h: float) -> Button:
	var b := Button.new()
	b.focus_mode = Control.FOCUS_NONE
	b.custom_minimum_size = Vector2(w, h)
	b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var base := style(id, 0, 0, 0, 0, Vector4.ZERO)
	var hover := base.duplicate() as StyleBoxTexture
	hover.modulate_color = Color(1.3, 1.22, 1.08)
	var pressed := base.duplicate() as StyleBoxTexture
	pressed.modulate_color = Color(0.78, 0.74, 0.7)
	for e in [["normal", base], ["hover", hover], ["pressed", pressed], ["hover_pressed", pressed], ["focus", StyleBoxEmpty.new()]]:
		b.add_theme_stylebox_override(e[0], e[1])
	linear(b)
	return b


## Ảnh vẽ cỡ cố định (icon thuộc tính, nhãn Chính, nút i).
static func image(id: String, w: float, h: float) -> TextureRect:
	var r := TextureRect.new()
	r.texture = tex(id)
	r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	r.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	r.custom_minimum_size = Vector2(w, h)
	r.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	r.mouse_filter = Control.MOUSE_FILTER_PASS
	linear(r)
	return r


## Số có dấu chấm ngăn nghìn: 5938 → "5.938".
static func group(n: int) -> String:
	var s := str(absi(n))
	var out := ""
	while s.length() > 3:
		out = "." + s.right(3) + out
		s = s.left(s.length() - 3)
	return ("-" if n < 0 else "") + s + out


## Biển vẽ có chữ do game in đè: dòng tiêu đề nhỏ + số lớn, toạ độ theo tỉ lệ ảnh (ô Lực chiến, ô Điểm thuộc tính).
class Plate:
	extends Control
	var texture: Texture2D
	var title := ""
	var value := ""
	var title_y := 0.5
	var value_y := 0.72
	var title_size := 15
	var value_size := 34
	## Tương thích test UI-21 (PowerBanner.power).
	var power := 0

	func _init(tex_id: String, w: float) -> void:
		texture = SpriteLib.texture(DIR + tex_id + ".png")
		var ar: float = float(texture.get_height()) / float(texture.get_width()) if texture else 0.5
		custom_minimum_size = Vector2(w, roundf(w * ar))
		size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		size_flags_vertical = Control.SIZE_SHRINK_CENTER
		mouse_filter = Control.MOUSE_FILTER_PASS
		texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR

	func _draw() -> void:
		if texture:
			draw_texture_rect(texture, Rect2(Vector2.ZERO, size), false)
		var f := UiTheme.bold_font()
		_line(f, title, title_y, UiTheme.fs(title_size), Color("#ead8a8"))
		_line(f, value, value_y, UiTheme.fs(value_size), Color("#ffe39a"))

	func _line(f: Font, t: String, y_rel: float, sz: int, c: Color) -> void:
		if t == "":
			return
		var y := y_rel * size.y + (f.get_ascent(sz) - f.get_descent(sz)) / 2.0
		draw_string(f, Vector2(0, y + 2), t, HORIZONTAL_ALIGNMENT_CENTER, size.x, sz, Color(0, 0, 0, 0.6))
		draw_string(f, Vector2(0, y), t, HORIZONTAL_ALIGNMENT_CENTER, size.x, sz, c)

