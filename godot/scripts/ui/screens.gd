extends RefCounted
## Dựng các màn hình toàn trang: tiêu đề, Lễ Thức Tỉnh, chiến thắng.

const Awakening = preload("res://scripts/core/awakening.gd")
const GiftCode = preload("res://scripts/core/gift_code.gd")
const Explore = preload("res://scripts/core/explore.gd")
const Talents = preload("res://scripts/data/talents.gd")
const UiTheme = preload("res://scripts/ui/ui_theme.gd")
const Classes = preload("res://scripts/data/classes.gd")
const SpriteLib = preload("res://scripts/view/sprite_lib.gd")
const Bronze = preload("res://scripts/ui/bronze.gd")
const FrameBox = preload("res://scripts/ui/frame_box.gd")
const CharSelect = preload("res://scripts/ui/char_select.gd")

## UI-17: bảng phím đầy đủ — dùng ở màn hình tiêu đề và bảng Trợ giúp (F1).
const CONTROLS := [
	["W A S D", "Di chuyển"],
	["Chuột", "Ngắm hướng đánh"],
	["Chuột trái / J", "Đánh thường (giữ để đánh liên tục)"],
	["1 · 2 · 3 · 4", "4 kỹ năng đang lắp (tốn MP); K / chuột phải = kỹ năng 1"],
	["5 · 6 · G", "Ô 5 (mở khi chuyển chức 1), ô 6 (chuyển chức 2), ô Tuyệt kỹ G (cấp 45)"],
	["X", "Đổi Bộ kỹ năng 1 / 2 (ngoài giao tranh)"],
	["Space", "Né lăn — bất tử 0,3 giây"],
	["L", "Kỹ năng Thiên phú (nếu có)"],
	["Q", "Uống bình máu"],
	["F", "Uống bình MP"],
	["Z", "Bật / tắt Tự đánh (hoặc bấm nút cạnh thanh kỹ năng)"],
	["C · I", "Nhân vật: tab Chỉ số · tab Túi đồ"],
	["U · T", "Kỹ năng · Thiên phú"],
	["M · N", "Khai phá (lưới ô) · Bản đồ lục địa (chỉ xem)"],
	["V", "Phóng to / thu nhỏ bản đồ nhỏ (bấm bản đồ nhỏ để tự chạy tới)"],
	["E", "Nói chuyện / cửa hàng (đứng cạnh NPC trong làng)"],
	["O", "Sổ nhiệm vụ — bấm khung nhiệm vụ để tự chạy tới mục tiêu"],
	["R", "Lò Rèn: cường hoá, chế tạo, luyện nguyên liệu, phân rã"],
	["F1 · H", "Trợ giúp"],
	["Esc", "Đóng bảng · Tạm dừng"],
]

## C1-13: lục địa Huyền Thổ vỡ 9 mảnh quanh lõi Hư Vô; vùng 1 đã sáng, vùng 2 nhấp nháy.
class Continent:
	extends Control
	const NAMES := ["Rừng Sương", "Gió Hú", "Xích Sa", "U Minh", "Viêm Long", "Bắc Cực", "Thiên Không", "Vực Hư Vô", "Thiên Đạo"]
	const POS := [Vector2(-230, 40), Vector2(-120, 70), Vector2(0, 80), Vector2(120, 60), Vector2(230, 30),
		Vector2(170, -60), Vector2(40, -80), Vector2(-90, -60), Vector2(0, -10)]
	var t := 0.0
	var chapter := 1

	func _process(delta: float) -> void:
		t = minf(t + delta, 99.0)
		queue_redraw()

	func _draw() -> void:
		var c := size / 2.0
		var font := UiTheme.font()
		for i in 9:
			var p: Vector2 = c + POS[i]
			var reveal := clampf(t * 1.5 - i * 0.15, 0.0, 1.0)
			var col := Color(0.18, 0.16, 0.26, 0.9 * reveal)
			if i < chapter:
				col = Color(0.36, 0.82, 0.42, 0.9 * reveal)
			elif i == chapter:
				col = Color(1.0, 0.8, 0.3, (0.5 + 0.4 * sin(t * 4.0)) * reveal)
			elif i == 8:
				col = Color(0.6, 0.4, 1.0, 0.5 * reveal)
			var r := 34.0 if i < 8 else 26.0
			var pts := PackedVector2Array()
			for k in 7:
				var a := TAU * k / 7.0 + i
				pts.append(p + Vector2.from_angle(a) * r * (0.8 + 0.25 * sin(i * 3.1 + k * 1.7)))
			draw_colored_polygon(pts, col)
			pts.append(pts[0])
			draw_polyline(pts, Color(0, 0, 0, 0.6 * reveal), 2.0, true)
			draw_string(font, p + Vector2(-50, r + 16), "%d. %s" % [i + 1, NAMES[i]], HORIZONTAL_ALIGNMENT_CENTER, 100, 12, Color(1, 1, 1, 0.8 * reveal))


## C1-15: Bia Đá Thiên Đạo phát sáng theo màu hạng (S trở lên có tia sáng).
class SteleGlow:
	extends Control
	var rank := ""
	var t := 0.0

	func _process(delta: float) -> void:
		t += delta
		queue_redraw()

	func _draw() -> void:
		var base := Vector2(size.x / 2.0, size.y - 20.0)
		var c := Talents.rank_color(rank) if rank != "" else Color(1.0, 0.86, 0.55)
		var strength := 0.25 if rank == "" else 0.45 + 0.1 * Talents.rank_index(rank)
		var pulse := 0.5 + 0.5 * sin(t * (2.0 + Talents.rank_index(rank) if rank != "" else 2.0))
		for i in 4:
			draw_circle(base + Vector2(0, -60), 30.0 + i * 16.0, Color(c, strength * (0.25 - i * 0.05) * (0.7 + 0.3 * pulse)))
		if rank != "" and Talents.rank_index(rank) >= Talents.rank_index("S"):
			for i in 10:
				var a := TAU * i / 10.0 + t * 0.6
				draw_line(base + Vector2(0, -60), base + Vector2(0, -60) + Vector2.from_angle(a) * (90.0 + 20.0 * pulse), Color(c, 0.35), 3.0, true)
		SpriteLib.draw_env(self, "stele", base, Color(1, 1, 1).lerp(c, 0.35 * strength + 0.1 * pulse), 2.0)


## UI-57 (docs/38): cảnh nền màn tiêu đề / chọn nhân vật, vẽ bằng code (không cần tranh): trời đêm xanh rêu,
## 2 lớp núi xa, rừng thông hai bên, Bia Đá Thiên Đạo giữa phát sáng xanh có cột sáng, sương trôi ngang, đốm sáng
## bay lên, viền tối. dim = phủ tối thêm (màn chọn nhân vật cần nền dịu hơn).
class Backdrop:
	extends Control
	var t := 0.0
	var dim := 0.0
	## CR-06: vị trí ngang của Bia Đá (tỉ lệ bề ngang) — màn Chọn nhân vật dời sang trái để nhân vật đứng trước bia.
	var stele_x := 0.5

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	func _process(delta: float) -> void:
		t += delta
		queue_redraw()

	func _ridge(y0: float, amp: float, seed: float, col: Color) -> void:
		var pts := PackedVector2Array([Vector2(0, size.y)])
		for i in 49:
			var x := size.x * i / 48.0
			var y := y0 - amp * (0.55 * sin(x * 0.006 + seed) + 0.3 * sin(x * 0.017 + seed * 2.3) + 0.15 * sin(x * 0.041 + seed * 0.7))
			pts.append(Vector2(x, y))
		pts.append(Vector2(size.x, size.y))
		draw_colored_polygon(pts, col)

	func _pine(base: Vector2, h: float, col: Color) -> void:
		var w := h * 0.36
		for k in 3:
			var y := base.y - h * (0.3 + 0.27 * k)
			var ww := w * (1.0 - 0.25 * k)
			draw_colored_polygon(PackedVector2Array([Vector2(base.x - ww, y + h * 0.3), Vector2(base.x, y - h * 0.22), Vector2(base.x + ww, y + h * 0.3)]), col)
		draw_rect(Rect2(base.x - h * 0.03, base.y - h * 0.12, h * 0.06, h * 0.12), col)

	func _draw() -> void:
		var s := size
		var top := Color("#0a1220")
		var mid := Color("#16262a")
		var low := Color("#0d1712")
		draw_polygon(PackedVector2Array([Vector2.ZERO, Vector2(s.x, 0), Vector2(s.x, s.y * 0.55), Vector2(0, s.y * 0.55)]), PackedColorArray([top, top, mid, mid]))
		draw_polygon(PackedVector2Array([Vector2(0, s.y * 0.55), Vector2(s.x, s.y * 0.55), Vector2(s.x, s.y), Vector2(0, s.y)]), PackedColorArray([mid, mid, low, low]))
		var c := Vector2(s.x * stele_x, s.y * 0.66)
		var pulse := 0.5 + 0.5 * sin(t * 1.3)
		# quầng sáng sau Bia Đá + cột sáng lên trời
		for i in 6:
			draw_circle(c + Vector2(0, -70), 60.0 + i * 46.0, Color(0.35, 0.85, 0.8, (0.06 - i * 0.008) * (0.8 + 0.2 * pulse)))
		draw_polygon(PackedVector2Array([c + Vector2(-26, -60), c + Vector2(26, -60), c + Vector2(60, -s.y), c + Vector2(-60, -s.y)]),
			PackedColorArray([Color(0.6, 1.0, 0.95, 0.16), Color(0.6, 1.0, 0.95, 0.16), Color(0.6, 1.0, 0.95, 0.0), Color(0.6, 1.0, 0.95, 0.0)]))
		_ridge(s.y * 0.52, 70.0, 1.3, Color("#1a2a33"))
		_ridge(s.y * 0.62, 50.0, 4.1, Color("#142219"))
		# sương xa
		for i in 5:
			var x := fposmod(i * 330.0 + t * (10.0 + i * 3.0), s.x + 600.0) - 300.0
			draw_set_transform(Vector2(x, s.y * (0.6 + 0.04 * (i % 3))), 0.0, Vector2(1.0, 0.22))
			draw_circle(Vector2.ZERO, 260.0, Color(0.75, 0.9, 0.9, 0.045))
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		# mặt đất + Bia Đá
		draw_polygon(PackedVector2Array([Vector2(0, s.y * 0.7), Vector2(s.x, s.y * 0.7), Vector2(s.x, s.y), Vector2(0, s.y)]),
			PackedColorArray([Color(low, 0.0), Color(low, 0.0), Color("#070c09"), Color("#070c09")]))
		draw_set_transform(c + Vector2(0, 6), 0.0, Vector2(1.0, 0.3))
		draw_circle(Vector2.ZERO, 120.0, Color(0.4, 0.95, 0.85, 0.12 + 0.05 * pulse))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		SpriteLib.draw_env(self, "stele", c, Color(1, 1, 1).lerp(Color("#9ff5e6"), 0.25 + 0.15 * pulse), 3.0)
		# rừng thông hai bên (gần: to, tối)
		var dark := Color("#08100b")
		for i in 9:
			var k := i / 8.0
			_pine(Vector2(s.x * (0.02 + 0.2 * k), s.y * (0.88 + 0.05 * sin(i * 2.1))), 150.0 + 150.0 * (1.0 - k), dark)
			_pine(Vector2(s.x * (0.98 - 0.2 * k), s.y * (0.88 + 0.05 * cos(i * 1.7))), 150.0 + 150.0 * (1.0 - k), dark)
		# đốm sáng bay lên
		for i in 46:
			var sx := fposmod(i * 97.3, s.x)
			var y := s.y - fposmod(t * (14.0 + (i % 7) * 4.0) + i * 53.0, s.y * 0.9)
			var x := sx + 14.0 * sin(t * 0.8 + i)
			var a := 0.35 + 0.35 * sin(t * 2.0 + i * 1.3)
			var col := Color(1.0, 0.86, 0.5, a) if i % 3 else Color(0.6, 1.0, 0.95, a)
			draw_circle(Vector2(x, y), 1.6 + (i % 3) * 0.6, col)
		# sương gần
		for i in 4:
			var x := fposmod(i * 470.0 - t * (16.0 + i * 5.0), s.x + 800.0) - 400.0
			draw_set_transform(Vector2(x, s.y * (0.82 + 0.05 * i)), 0.0, Vector2(1.0, 0.18))
			draw_circle(Vector2.ZERO, 420.0, Color(0.8, 0.92, 0.9, 0.05))
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		# viền tối trên / dưới + phủ tối
		var v := Color(0, 0, 0, 0.55)
		var cl := Color(0, 0, 0, 0)
		var e := s.y * 0.22
		draw_polygon(PackedVector2Array([Vector2.ZERO, Vector2(s.x, 0), Vector2(s.x, e), Vector2(0, e)]), PackedColorArray([v, v, cl, cl]))
		draw_polygon(PackedVector2Array([Vector2(0, s.y - e), Vector2(s.x, s.y - e), Vector2(s.x, s.y), Vector2(0, s.y)]), PackedColorArray([cl, cl, v, v]))
		if dim > 0.0:
			draw_rect(Rect2(Vector2.ZERO, s), Color(0.02, 0.03, 0.03, dim))


## Nền + cột nội dung căn giữa. Trả về [màn hình, cột].
## UI-50 / 59 (docs/38): framed = cột nằm trong khung đồng (SolidPanel) như các bảng khác; backdrop = cảnh nền Backdrop.
static func _page(bg_alpha := 1.0, width := 640.0, framed := false, backdrop := false, dim := 0.0) -> Array:
	var screen := ColorRect.new()
	screen.color = Color(UiTheme.BG, bg_alpha)
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if backdrop:
		var bd := Backdrop.new()
		bd.dim = dim
		screen.add_child(bd)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen.add_child(center)
	var col := UiTheme.vbox(14)
	col.custom_minimum_size.x = width
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	if framed:
		var panel := PanelContainer.new()
		panel.theme_type_variation = "SolidPanel"
		panel.add_child(col)
		center.add_child(panel)
	else:
		center.add_child(col)
	return [screen, col]


## Tiêu đề chữ cổ vàng (Cormorant SC) có viền nâu — dùng chung cho màn tiêu đề / kết chương / kết thúc.
static func _title_label(text: String, size := 44) -> Label:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_override("font", Bronze.title_font())
	l.add_theme_font_size_override("font_size", UiTheme.fs(size))
	l.add_theme_color_override("font_color", Bronze.GOLD_TEXT)
	l.add_theme_color_override("font_outline_color", Color("#1a0f05"))
	l.add_theme_constant_override("outline_size", maxi(6, size / 6))
	l.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	l.add_theme_constant_override("shadow_offset_y", 3)
	return l


## Thẻ khung đồng nhỏ (FrameBox kiểu HUD).
static func _bronze_card(margin := 14) -> PanelContainer:
	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", FrameBox.new().setup(Color(Bronze.MOSS, 0.94), margin, "small"))
	return card


## Ô số liệu nhỏ: số to + nhãn nhỏ (màn kết chương).
static func _stat_tile(value: String, caption: String) -> PanelContainer:
	var card := _bronze_card(10)
	card.custom_minimum_size = Vector2(112, 0)
	var v := UiTheme.vbox(0)
	var n := _centered(value)
	n.add_theme_font_override("font", UiTheme.bold_font())
	n.add_theme_font_size_override("font_size", UiTheme.fs(18))
	n.add_theme_color_override("font_color", Bronze.GOLD_TEXT)
	v.add_child(n)
	v.add_child(_centered(caption, "Small"))
	card.add_child(v)
	return card


static func _centered(text: String, variation := "", wrap := 0.0) -> Label:
	var l := UiTheme.label(text, variation, wrap)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return l


static func _buttons(col: VBoxContainer) -> HBoxContainer:
	var row := UiTheme.hbox(12)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_child(row)
	return row


## UI-57 (docs/38): cảnh nền vẽ bằng code + logo chữ cổ vàng + cột nút đồng lớn; bỏ bảng 20 phím tắt (đã có ở
## Trợ giúp F1 và Cài đặt → Điều khiển), chỉ còn một dòng gợi ý dưới đáy.
static func title(has_save: bool, on_new: Callable, on_continue: Callable, on_settings := Callable()) -> Control:
	var screen := ColorRect.new()
	screen.color = UiTheme.BG
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen.add_child(Backdrop.new())
	var top := UiTheme.vbox(2)
	top.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	top.offset_top = 48
	var eb := _centered("MISTBREAKER  ·  CELESTIAL GENESIS", "Eyebrow")
	eb.add_theme_color_override("font_color", Bronze.BR_LIGHT)
	top.add_child(eb)
	top.add_child(_title_label("Thiên Phú Khai Giới", 72))
	var tag := _centered("Nhận Thiên phú từ Bia Đá, xua tan sương mù Hư Vô.")
	tag.add_theme_color_override("font_color", Color("#d8e4dc"))
	tag.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	tag.add_theme_constant_override("outline_size", 4)
	top.add_child(tag)
	screen.add_child(top)
	var col := UiTheme.vbox(10)
	col.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	col.offset_left = -150
	col.offset_right = 150
	col.offset_top = -230
	col.offset_bottom = -56
	col.alignment = BoxContainer.ALIGNMENT_END
	screen.add_child(col)
	var row := col
	# SN9-02: có nhân vật rồi thì nút chính mở màn Chọn nhân vật (tối đa 5)
	var b_new := UiTheme.button("Chọn nhân vật" if has_save else "Hành trình mới", true)
	b_new.name = "NewButton"
	b_new.pressed.connect(on_new)
	row.add_child(b_new)
	var b_cont := UiTheme.button("Tiếp tục")
	b_cont.name = "ContinueButton"
	b_cont.disabled = not has_save
	b_cont.pressed.connect(on_continue)
	row.add_child(b_cont)
	if on_settings.is_valid():
		var b_set := UiTheme.button("Cài đặt")
		b_set.name = "SettingsButton"
		b_set.pressed.connect(on_settings)
		row.add_child(b_set)
	for b in row.get_children():
		(b as Button).custom_minimum_size = Vector2(300, 44)
		(b as Button).add_theme_font_size_override("font_size", UiTheme.fs(17))
	# chưa có nhân vật: ẩn "Tiếp tục" thay vì nút xám không bấm được (T6 — nút khoá phải có lý do)
	b_cont.visible = has_save
	var hint := _centered("F1 · Trợ giúp và phím tắt     Esc · Tạm dừng     Đổi phím: Cài đặt → Điều khiển", "Small")
	hint.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	hint.offset_top = -30
	hint.offset_bottom = -10
	hint.add_theme_color_override("font_color", Color("#b9ab8c"))
	screen.add_child(hint)
	return screen


## SN9-02 (Spec_Notes đợt 9): màn Chọn nhân vật (slots = SaveSystem.list_slots()).
## CR-06: bố cục kiểu ARPG cổ điển — nhân vật đang chọn đứng to giữa cảnh, danh sách bên phải (ui/char_select.gd).
## on_play(n), on_delete(n), on_new(), on_back(); selected = ô chọn sẵn (0 = ô có nhân vật đầu tiên).
## CR-06b: on_settings / on_quit (tuỳ chọn) → nút Cài đặt / Thoát game góc trái dưới (màn này là màn đầu khi mở game).
static func slots(slots_info: Array, on_play: Callable, on_delete: Callable, on_new: Callable, on_back: Callable, selected := 0,
		on_settings := Callable(), on_quit := Callable()) -> Control:
	var bd := Backdrop.new()
	bd.dim = 0.2
	bd.stele_x = CharSelect.HERO_X
	return CharSelect.new(slots_info, on_play, on_delete, on_new, on_back, selected, bd, on_settings, on_quit)


## Lễ Thức Tỉnh. on_accept nhận id Thiên phú đã chọn.
static func awakening(rng: Callable, on_accept: Callable, player_name := "") -> Control:
	var page := _page()
	var screen: Control = page[0]
	var col: VBoxContainer = page[1]
	var state := {"aw": Awakening.new(rng), "selected": -1, "rolling": null}

	col.add_child(_centered("LỄ THỨC TỈNH · LÀNG THANH THẠCH", "Eyebrow"))
	var heading := _centered("Bia Đá Thiên Đạo", "Heading")
	heading.add_theme_font_size_override("font_size", 34)
	col.add_child(heading)
	var speech := _centered("Trưởng làng Thạch Lão: “%sĐặt tay lên Bia Đá, để Thiên Đạo phán xét con.”" % (player_name + ", " if player_name != "" else ""))
	speech.add_theme_color_override("font_color", Color("#e4d4ae"))
	col.add_child(speech)

	var card_holder := CenterContainer.new()
	col.add_child(card_holder)
	var history := HFlowContainer.new()
	history.alignment = FlowContainer.ALIGNMENT_CENTER
	col.add_child(history)
	var row := _buttons(col)
	var b_roll := UiTheme.button("Chạm Bia Đá", true)
	b_roll.name = "RollButton"
	row.add_child(b_roll)
	var b_accept := UiTheme.button("Nhận Thiên phú này")
	b_accept.name = "AcceptButton"
	row.add_child(b_accept)

	# TL-03: tỉ lệ theo hạng.
	var rates := PackedStringArray()
	for r in Talents.RANK_ORDER:
		rates.append("%s %s%%" % [r, str(Talents.RANK_WEIGHT[r])])
	col.add_child(_centered(
		"Có thể chọn lại bất kỳ lần quay nào. Bảo hiểm: nếu cả 4 lần đều dưới hạng B, lần cuối được nâng lên hạng B.\nTỉ lệ theo hạng: %s. Bể quay gồm 20 Thiên phú. Mọi Thiên phú đều dùng được với cả hai lớp." % " · ".join(rates),
		"Small", 600
	))

	# CR-02 (GC-01): ô nhập gift code của nhà phát hành.
	var gift_row := _buttons(col)
	var gift_edit := LineEdit.new()
	gift_edit.name = "GiftEdit"
	gift_edit.placeholder_text = "Gift code: TPKG-XXXX-XXXX-XXXX"
	gift_edit.custom_minimum_size.x = 300
	gift_edit.max_length = 24
	gift_row.add_child(gift_edit)
	var b_gift := UiTheme.button("Đổi mã")
	b_gift.name = "GiftButton"
	gift_row.add_child(b_gift)
	var gift_note := _centered("Có gift code? Nhập để Bia Đá quay thêm 1 lần chỉ ra hạng A, S, SS hoặc SSS (không tốn lượt quay lại).", "Small", 600)
	gift_note.name = "GiftNote"
	col.add_child(gift_note)

	var render := func() -> void:
		var aw = state.aw
		for holder in [card_holder, history]:
			for old in holder.get_children():
				holder.remove_child(old)
				old.queue_free()
		var shown = state.rolling if state.rolling != null else (aw.rolls[state.selected] if state.selected >= 0 else null)
		# C1-15 (TP-04): Bia Đá toả sáng theo màu hạng vừa quay.
		var pair := UiTheme.hbox(24)
		var stele := SteleGlow.new()
		stele.custom_minimum_size = Vector2(140, 230)
		stele.rank = "" if shown == null or state.rolling != null else str(shown.rank)
		pair.add_child(stele)
		pair.add_child(_card(shown, state.rolling != null))
		card_holder.add_child(pair)
		for i in aw.rolls.size():
			var t: Dictionary = aw.rolls[i]
			var label := ("★ Gift code: %s · %s" % [t.rank, t.name]) if i == aw.gift_index else ("Lần %d: %s · %s" % [i + 1 - (1 if aw.gift_used() and i > aw.gift_index else 0), t.rank, t.name])
			var chip := UiTheme.button(label)
			var c := Talents.rank_color(t.rank)
			chip.add_theme_stylebox_override("normal", UiTheme.box(Color(c, 0.25 if i == state.selected else 0.04), 999, 1, c, 8))
			chip.add_theme_stylebox_override("hover", UiTheme.box(Color(c, 0.3), 999, 1, c, 8))
			var idx: int = i
			chip.pressed.connect(func():
				state.selected = idx
				screen.get_meta("render").call())
			history.add_child(chip)
		var rolling: bool = state.rolling != null
		b_roll.text = "Chạm Bia Đá" if aw.rolls.is_empty() else "Quay lại (còn %d lần)" % aw.rerolls_left()
		b_roll.disabled = rolling or not aw.can_roll()
		b_accept.disabled = rolling or state.selected < 0
		gift_edit.editable = not aw.gift_used() and not rolling
		b_gift.disabled = aw.gift_used() or rolling
	screen.set_meta("render", render)

	var redeem := func(code: String) -> void:
		var aw = state.aw
		if aw.gift_used():
			gift_note.text = "Mỗi nhân vật chỉ dùng được 1 gift code."
			return
		if state.rolling != null:
			return
		var res := GiftCode.validate(code)
		if not res.ok:
			gift_note.text = res.message
			gift_note.add_theme_color_override("font_color", UiTheme.BAD)
			return
		GiftCode.mark_redeemed(res.serial)
		gift_note.text = "Mã hợp lệ! Bia Đá rực sáng…"
		gift_note.add_theme_color_override("font_color", UiTheme.GOLD)
		var started := Time.get_ticks_msec()
		var rare: Array = Talents.LIST.filter(func(x): return Talents.rank_index(x.rank) >= Talents.rank_index("A") and not x.get("hidden", false))
		while Time.get_ticks_msec() - started < 1400:
			state.rolling = rare[randi() % rare.size()]
			render.call()
			await screen.get_tree().create_timer(0.08).timeout
		state.rolling = null
		var t: Dictionary = aw.gift_roll(res.serial, str(res.get("talent", "")))
		state.selected = aw.gift_index
		gift_note.text = "Gift code: nhận %s · %s. Vẫn có thể chọn lượt quay khác." % [t.rank, t.name]
		render.call()
	b_gift.pressed.connect(func(): redeem.call(gift_edit.text))
	gift_edit.text_submitted.connect(func(txt): redeem.call(txt))
	screen.set_meta("redeem", redeem)

	b_roll.pressed.connect(func():
		var aw = state.aw
		if not aw.can_roll() or state.rolling != null:
			return
		var started := Time.get_ticks_msec()
		while Time.get_ticks_msec() - started < 1100:
			# Hiệu ứng quay chỉ lướt qua Thiên phú không ẩn (TL-03: SSS chỉ lộ khi trúng).
			var visible_pool: Array = Talents.LIST.filter(func(x): return not x.get("hidden", false))
			state.rolling = visible_pool[randi() % visible_pool.size()]
			render.call()
			await screen.get_tree().create_timer(0.08).timeout
		state.rolling = null
		aw.roll()
		state.selected = aw.rolls.size() - 1
		render.call())
	b_accept.pressed.connect(func():
		if state.selected >= 0:
			on_accept.call(state.aw.rolls[state.selected].id, state.aw.gift_serial))
	render.call()
	return screen


## CL-01: chọn lớp sau Lễ Thức Tỉnh. on_choose nhận id lớp.
static func class_select(talent_name: String, on_choose: Callable) -> Control:
	var page := _page(1.0, 900.0)
	var col: VBoxContainer = page[1]
	col.add_child(_centered("TẠO NHÂN VẬT", "Eyebrow"))
	var heading := _centered("Chọn con đường của con", "Heading")
	heading.add_theme_font_size_override("font_size", 34)
	col.add_child(heading)
	col.add_child(_centered("Thiên phú: %s. Mọi Thiên phú đều dùng được với cả hai lớp." % talent_name, "Muted"))
	var row := UiTheme.hbox(20)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_child(row)
	for cid in Classes.ORDER:
		var c: Dictionary = Classes.DEFS[cid]
		var card := PanelContainer.new()
		card.custom_minimum_size = Vector2(420, 0)
		card.add_theme_stylebox_override("panel", UiTheme.box(UiTheme.PANEL_SOLID, 14, 2, UiTheme.LINE, 18))
		var v := UiTheme.vbox(8)
		card.add_child(v)
		var top := UiTheme.hbox(14)
		var portrait := _portrait(c.sprite)
		top.add_child(portrait)
		var head := UiTheme.vbox(2)
		head.add_child(UiTheme.label(c.name, "Heading"))
		head.add_child(UiTheme.label("%s · Chỉ số chính %s" % [c.role, c.main], "Small"))
		top.add_child(head)
		v.add_child(top)
		v.add_child(UiTheme.label(c.description, "Muted", 380))
		for i in 4:
			var sk: Dictionary = c.skills[i]
			var line := UiTheme.hbox(8)
			var ic := TextureRect.new()
			ic.texture = SpriteLib.icon("skill-" + str(sk.icon))
			ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			ic.custom_minimum_size = Vector2(32, 32)
			line.add_child(ic)
			line.add_child(UiTheme.label("%d · %s%s — %s" % [i + 1, sk.name, (" (cấp %d)" % int(sk.unlock)) if int(sk.get("unlock", 1)) > 1 else "", sk.text], "Small", 330))
			v.add_child(line)
		var b := UiTheme.button("Chọn %s" % c.name, cid == "kiem-khach")
		b.name = "Class_" + cid
		var id: String = cid
		b.pressed.connect(func(): on_choose.call(id))
		v.add_child(b)
		row.add_child(card)
	return page[0]


## Khung chân dung: frame đứng của sprite, phóng ×3.
static func _portrait(sprite_id: String) -> Control:
	var holder := TextureRect.new()
	holder.custom_minimum_size = Vector2(96, 96)
	holder.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	holder.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var s: Dictionary = SpriteLib.data().get("sprites", {}).get(sprite_id, {})
	if not s.is_empty():
		var at := AtlasTexture.new()
		at.atlas = SpriteLib.texture(s.path)
		at.region = Rect2(0, 0, float(s.w), float(s.h))
		holder.texture = at
	return holder


static func _card(t, spinning: bool) -> Control:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(340, 220)
	var v := UiTheme.vbox(6)
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	card.add_child(v)
	if t == null:
		card.add_theme_stylebox_override("panel", UiTheme.box(UiTheme.PANEL_SOLID, 14, 2, UiTheme.LINE, 18))
		var q := _centered("?", "Title")
		q.add_theme_color_override("font_color", UiTheme.MUTED)
		v.add_child(q)
		v.add_child(_centered("Bia Đá đang chờ bàn tay của con.", "Muted"))
		return card
	var c := Talents.rank_color(t.rank)
	card.add_theme_stylebox_override("panel", UiTheme.box(Color(c.darkened(0.82), 1.0), 14, 2, c, 18))
	var rank := _centered(t.rank, "Title")
	rank.add_theme_color_override("font_color", c)
	v.add_child(rank)
	var name_l := _centered(t.name, "Heading")
	v.add_child(name_l)
	var kind := ("Kỹ năng L: %s" % t.skill.name) if Talents.has_skill(t) else "Bị động"
	v.add_child(_centered("%s · %s" % [Talents.group_name(t), kind], "Small"))
	v.add_child(_centered("…" if spinning else t.description, "", 300))
	return card


## Màn kết chương theo boss chương (MP-06). [chương, tiêu đề, lời kể (%s = tên nhân vật), dòng gợi ý].
const VICTORY := {
	"boss": [1, "Sói Chúa Hư Vô đã ngã xuống",
		"Ánh sáng từ Bia Đá lan tới tận hang sói. Phía đông, Đồng Bằng Gió Hú đang chờ… và Thiên phú trong %s khẽ rung động, như có một mảnh thứ hai đang thức giấc.",
		"Lõi Sương (cấp 7–10) đã mở; Đồng Bằng Gió Hú mở khi đạt cấp 10 và khai phá 60% vùng 1 — xem bản đồ lục địa (phím N)."],
	"huyen-anh": [2, "Tướng Gián Điệp Huyền Ảnh đã ngã xuống",
		"Gió ở Đồng Bằng lặng đi. Liên minh Khai Giới đã sạch bóng gián điệp — nhưng lời thì thầm “mảnh linh hồn của Chủ nhân” vẫn vang trong đầu %s. Phía nam, Sa Mạc Xích Sa đang chờ…",
		"Sa Mạc Xích Sa mở khi đạt Lực chiến 5.000 và cấp 18 — xem bản đồ lục địa (phím N)."],
	"sa-hoang": [3, "Bọ Cạp Sa Hoàng đã ngã xuống",
		"Cát lắng xuống trên Di Tích Khai Giới Giả. Bia đá cổ chờ %s đọc nốt câu chuyện về Thiên Liệt…",
		"Gặp Thạch Thủ ở Trại Cát Đỏ để chuyển chức lần 1 (cấp 30). Đầm Lầy U Minh mở sau chuyển chức."],
	"nu-vuong": [4, "Nữ Vương Phệ Mộng đã ngã xuống",
		"Giấc mơ tan. Lam Nhi tỉnh lại, Thiên phú trở về — nhưng Nữ Vương chỉ là tay sai của “kẻ không có Thiên phú”. %s cảm thấy mảnh thứ hai trong ngực đang lớn dần.",
		"Tiến hoá Thiên phú với Tinh Quang Sứ ở Làng Chài Lau. Núi Viêm Long mở sau tiến hoá lần 1."],
	"vien-long": [5, "Viêm Long đã ngã xuống",
		"Núi lửa ngừng gầm. Long Tâm nóng rực trong tay %s — và trong ánh lửa, cái bóng của chính mình hiện lên… không có mặt.",
		"Gặp Liệt Diễm ở Trại Tro Hồng để chuyển chức lần 2 (cấp 60, 30 Tinh Thạch). Băng Nguyên Bắc Cực mở sau chuyển chức 2."],
	"ban-nga": [6, "Bản Ngã Bóng Tối đã tan",
		"Gương Băng vỡ vụn. Cái bóng không mặt tan thành khói đen và chui vào ngực %s — lạnh buốt, rồi im lặng. Tuyết Nga đang chờ ở Trạm Tuyết Bạc với sự thật về thân phận.",
		"Về Trạm Tuyết Bạc nói với Tuyết Nga. Quần Đảo Thiên Không mở khi lãnh địa thành Hoàng Thành và xây Cảng Khí Cầu."],
	"cu-than": [7, "Thiên Không Cự Thần đã quỳ xuống",
		"Ấn Hư Vô trên trán Cự Thần vỡ vụn. Người khổng lồ tỉnh lại, quỳ trước Bia Đá gốc rồi hoá đá. Bia Đá gốc rung lên khi %s bước tới gần…",
		"Chạm Bia Đá gốc ở Đài Cự Thần (E) để làm nghi thức Nghịch Thiên Cải Mệnh — tiến hoá Thiên phú lần 2."],
	"giao-chu": [8, "Giáo Chủ Hư Vô đã ngã xuống",
		"Mặt nạ bạc vỡ đôi. Thiên phú bị nuốt bay về chủ cũ khắp lục địa — và từ trên cao, Ma Tôn gọi đúng tên %s.",
		"Mang 3 Lõi Hư Vô tới Tổ Sư ở Cổng Phá Vây để chuyển chức lần 3. Cổng Thiên Đạo mở sau chuyển chức 3."],
	"ma-ton": [9, "Ma Tôn Vô Diện đã tan",
		"Khoảng trống xoáy sương tan biến. Mảnh thứ hai bừng sáng trong ngực %s — Ấn Phong Thiên mở ra trước Cổng Thiên Đạo.",
		"Hãy chọn số phận của mảnh thứ hai."],
}

## C9-44: 2 thẻ kết thúc — [id, tên, mô tả, hệ quả].
const ENDINGS := [
	["hop-nhat", "Hợp nhất", "Hấp thụ mảnh thứ hai, trở thành Thiên Đạo mới.",
		"Sương mù còn, nhưng nghe lệnh bạn · Ám Khí thành Thiên Đạo Lực (đầy → Thần Hoá 10 giây: +30% Tấn công, +15% tốc đánh, đòn khắc hệ) · Endgame: Thần Vực (tháp vô tận) · Cấp sau 100: Thần Vực 1, 2, 3…"],
	["hien-te", "Hiến tế", "Trả mảnh thứ hai cho Bia Đá — sương mù tan.",
		"Sương bản đồ vùng 1–9 mở hết, ô khai phá lộ sự kiện · Ám Khí biến mất · Thiên phú +20%, lãnh địa +30%, miễn Suy Thiên · Endgame: Tái Thiết Lục Địa (9 công trình) · Cấp sau 100: Khai Thế 1, 2, 3…"],
]


## C9-44: màn lựa chọn kết thúc — chọn 1 thẻ rồi xác nhận lần 2 ("Lựa chọn này không thể đổi lại.").
static func ending_choice(on_pick: Callable) -> Control:
	# UI-59 (docs/38): khung đồng + tiêu đề chữ cổ như các bảng khác.
	var page := _page(0.95, 900.0, true)
	var col: VBoxContainer = page[1]
	col.add_child(_centered("CHƯƠNG 9 · LỰA CHỌN", "Eyebrow"))
	col.add_child(_title_label("Số phận của mảnh thứ hai", 44))
	var row := UiTheme.hbox(24)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_child(row)
	var confirm := _centered("", "", 860)
	var confirm_row := _buttons(col)
	col.add_child(confirm)
	var chosen := [""]
	for e in ENDINGS:
		var card := _bronze_card(18)
		card.name = "Ending_" + str(e[0])
		card.custom_minimum_size = Vector2(400, 260)
		var sb := {"border_color": Color("#fff0b0") if e[0] == "hop-nhat" else Color("#9de0e6")}
		var v := UiTheme.vbox(10)
		card.add_child(v)
		var h := UiTheme.label(str(e[1]), "Heading")
		h.add_theme_color_override("font_color", sb.border_color)
		v.add_child(h)
		v.add_child(UiTheme.label(str(e[2]), "", 360))
		v.add_child(UiTheme.label(str(e[3]), "Small", 360))
		var b := UiTheme.button("Chọn %s" % e[1], true)
		b.name = "Pick_" + str(e[0])
		b.pressed.connect(func():
			chosen[0] = str(e[0])
			confirm.text = "Chọn %s? Lựa chọn này không thể đổi lại." % e[1]
			confirm_row.visible = true)
		v.add_child(b)
		row.add_child(card)
	confirm_row.visible = false
	var yes := UiTheme.button("Xác nhận", true)
	yes.name = "EndingConfirm"
	yes.pressed.connect(func():
		if chosen[0] != "":
			on_pick.call(chosen[0]))
	confirm_row.add_child(yes)
	var no := UiTheme.button("Nghĩ lại")
	no.pressed.connect(func():
		chosen[0] = ""
		confirm.text = ""
		confirm_row.visible = false)
	confirm_row.add_child(no)
	return page[0]


## C9-47: bảng tổng kết hành trình + danh đề.
static func credits(world, on_close: Callable) -> Control:
	var page := _page(0.97, 700.0, true)
	var col: VBoxContainer = page[1]
	var p = world.profile
	var t: Dictionary = world.talent()
	var end_name := "Hợp nhất" if str(p.ending) == "hop-nhat" else "Hiến tế"
	col.add_child(_centered("HÀNH TRÌNH HOÀN THÀNH · %s" % end_name.to_upper(), "Eyebrow"))
	col.add_child(_title_label(str(p.name), 56))
	var bosses := 0
	for k in p.bosses:
		if bool(p.bosses[k]) and k != "ending9":
			bosses += 1
	var tiles := 0
	for rg in Explore.region_grids(p):
		tiles += Explore.owned_count(rg[1])
	col.add_child(_centered("Thời gian chơi %d giờ %d phút  ·  Cấp %d  ·  Quái đã hạ %d  ·  Boss %d  ·  Ô đã chiếm %d" % [
		int(p.play_seconds) / 3600, (int(p.play_seconds) % 3600) / 60, p.level, p.kills, bosses + (1 if p.boss_defeated else 0), tiles], "", 680))
	col.add_child(_centered("Thiên phú cuối: %s · %s  ·  Chức: %s" % [t.rank, t.name,
		Classes.title(str(p.class_id), str(p.job), str(p.job2), str(p.job3))], "", 680))
	var roll := _centered("THIÊN PHÚ KHAI GIỚI — MISTBREAKER: CELESTIAL GENESIS\n\nKịch bản, thiết kế, chỉ đạo: vinhnv\nLập trình, đồ hoạ sinh bằng code, cân bằng: các phiên Claude\nĐộng cơ: Godot 4 · Font: Be Vietnam Pro (OFL)\n\nCảm ơn bạn đã đi hết hành trình qua chín vùng đất của Huyền Thổ.", "Muted", 640)
	col.add_child(roll)
	var row := _buttons(col)
	var b := UiTheme.button("Về Thiên Thê Đài", true)
	b.name = "CreditsClose"
	b.pressed.connect(on_close)
	row.add_child(b)
	return page[0]


static func victory(world, on_continue: Callable, on_title: Callable, boss_id := "boss") -> Control:
	# R1 (docs/19 RS-UI05): nền gần kín (0,82 → 0,95) — chữ "Lên cấp", Bí Kíp, số sát thương phía sau không lộ qua.
	# UI-59 (docs/38): khung đồng, tiêu đề chữ cổ, số liệu thành các ô nhỏ (thay một dòng dài).
	var page := _page(0.95, 680.0, true)
	var col: VBoxContainer = page[1]
	var p = world.profile
	var t: Dictionary = world.talent()
	var v: Array = VICTORY.get(boss_id, VICTORY["boss"])
	col.add_child(_centered("CHƯƠNG %d HOÀN THÀNH" % int(v[0]), "Eyebrow"))
	var h := _title_label(str(v[1]), 40)
	h.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	h.custom_minimum_size.x = 660
	col.add_child(h)
	col.add_child(_centered(str(v[2]) % p.name, "Muted", 580))
	# C1-13 (TN-09): bản đồ lục địa hiện ra, vùng đã qua sáng, vùng kế tiếp nhấp nháy.
	var art := Continent.new()
	art.chapter = int(v[0])
	art.custom_minimum_size = Vector2(620, 250)
	art.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	col.add_child(art)
	var tiles := UiTheme.hbox(8)
	tiles.alignment = BoxContainer.ALIGNMENT_CENTER
	for pair in [["%d phút" % roundi(p.play_seconds / 60.0), "Thời gian chơi"], ["%d" % int(p.level), "Cấp"],
			["%d" % int(p.kills), "Quái đã hạ"], ["%d/%d" % [Explore.owned_count(p.tiles), Explore.explore_total(p.tiles)], "Khai phá"],
			["%s · %s" % [t.rank, t.name], "Thiên phú"]]:
		tiles.add_child(_stat_tile(pair[0], pair[1]))
	col.add_child(tiles)
	col.add_child(_centered(str(v[3]), "Small", 580))
	var row := _buttons(col)
	var b1 := UiTheme.button("Tiếp tục khám phá", true)
	b1.pressed.connect(on_continue)
	row.add_child(b1)
	var b2 := UiTheme.button("Về màn hình chính")
	b2.pressed.connect(on_title)
	row.add_child(b2)
	return page[0]
