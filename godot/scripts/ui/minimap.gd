extends Control
## M5-03 (Spec_Notes đợt 3): bản đồ nhỏ theo thời gian thực ở góc phải HUD.
## Đất đã khám phá (sương che SN-31), làng/thành, hang boss, tường sương, NPC, quái trong vùng đã thấy,
## boss và boss hiếm, nhân vật (mũi tên theo hướng nhìn). Phím V: đổi cỡ nhỏ / lớn.
## SN5-01: chuột trái lên bản đồ → nhân vật tự chạy tới điểm đó; chuột phải → huỷ.
## UI-41 (docs/35 §11): cỡ nhỏ = la bàn tròn lấy nhân vật làm tâm (vòng đồng chữ N/E/S/W, nút +/− đổi tầm nhìn,
## biển tên map dưới vòng); cỡ lớn (V) = toàn map chữ nhật trong khung đồng (bấm để tự chạy tới điểm xa).

const Gates = preload("res://scripts/core/gates.gd")
const UiTheme = preload("res://scripts/ui/ui_theme.gd")
const GameWorld = preload("res://scripts/core/game_world.gd")

const Bronze = preload("res://scripts/ui/bronze.gd")
const SMALL_W := 224.0
const LARGE_W := 460.0
const HEADER := 18.0
## UI-41: la bàn tròn — bán kính phần bản đồ, độ dày vành, biển tên, các mức tầm nhìn (bán kính thế giới, px).
const ROUND_R := 88.0
const RING := 16.0
const PLATE_H := 26.0
const ZOOMS := [500.0, 900.0, 1600.0]
## Màu đất theo vùng (vùng 1 rừng, vùng 2 thảo nguyên).
const GROUND := {1: Color("#2f4a34"), 2: Color("#6b6340"), 3: Color("#a87a44"), 4: Color("#2a4a40"), 5: Color("#4a2a22"), 6: Color("#7a8ea8")}
const FOG_COLOR := Color("#0b0d14")

var large := false
var zoom := 1
var _clip: Control
var _content: Control
var _ring: Control
var _world: GameWorld
var _fog_tex: ImageTexture
var _fog_version := -1
var _fog_map := ""


func _init() -> void:
	# lớp cắt (hình tròn / chữ nhật) → nội dung bản đồ; vành la bàn vẽ đè lên trên
	_clip = Layer.new(self, "mask")
	_clip.clip_children = CanvasItem.CLIP_CHILDREN_ONLY
	add_child(_clip)
	_content = Layer.new(self, "content")
	_clip.add_child(_content)
	_ring = Layer.new(self, "ring")
	add_child(_ring)


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	tooltip_text = "Chuột trái: tự chạy tới · chuột phải: huỷ · +/−: tầm nhìn · V: toàn bản đồ"
	_resize()


## Lớp vẽ con: gọi lại hàm vẽ của bản đồ nhỏ theo vai trò (mask / content / ring).
class Layer:
	extends Control
	var host
	var role := ""

	func _init(h, r: String) -> void:
		host = h
		role = r
		mouse_filter = MOUSE_FILTER_IGNORE

	func _draw() -> void:
		host._paint(self, role)


## Tâm la bàn (toạ độ cục bộ, cỡ nhỏ).
func round_center() -> Vector2:
	return Vector2(SMALL_W / 2.0, ROUND_R + RING + 2.0)


## Nút + / − trên vành (cỡ nhỏ).
func zoom_button(plus: bool) -> Vector2:
	return round_center() + Vector2.from_angle(deg_to_rad(-42.0 if plus else 42.0)) * (ROUND_R + RING * 0.5)


## Px bản đồ trên 1 px thế giới ở cỡ nhỏ.
func _round_k() -> float:
	return ROUND_R / float(ZOOMS[zoom])


## Toạ độ thế giới từ toạ độ trên bản đồ nhỏ (chỉ trong khung bản đồ, không tính dòng tiêu đề).
func world_at(local: Vector2) -> Vector2:
	if _world == null:
		return Vector2.INF
	if not large:
		var c := round_center()
		if local.distance_to(c) > ROUND_R:
			return Vector2.INF
		return (_world.player.pos + (local - c) / _round_k()).clamp(Vector2.ZERO, _world.world_size)
	var rect := Rect2(Vector2(0, HEADER), size - Vector2(0, HEADER))
	if not rect.has_point(local):
		return Vector2.INF
	return (local - rect.position) / rect.size * _world.world_size


func _gui_input(event: InputEvent) -> void:
	if _world == null or not (event is InputEventMouseButton) or not event.pressed:
		return
	if event.button_index == MOUSE_BUTTON_LEFT:
		if not large:
			for plus in [true, false]:
				if event.position.distance_to(zoom_button(plus)) <= 11.0:
					zoom = clampi(zoom + (-1 if plus else 1), 0, ZOOMS.size() - 1)
					_redraw()
					accept_event()
					return
		var wp := world_at(event.position)
		if wp != Vector2.INF:
			_world.set_move_target(wp)
			accept_event()
	elif event.button_index == MOUSE_BUTTON_RIGHT:
		_world.clear_move_target()
		accept_event()


func toggle_size() -> void:
	large = not large
	_resize()


func _resize() -> void:
	if not large:
		custom_minimum_size = Vector2(SMALL_W, (ROUND_R + RING) * 2.0 + 4.0 + PLATE_H)
	else:
		var aspect := 2560.0 / 4480.0
		if _world != null and _world.world_size.x > 0.0:
			aspect = _world.world_size.y / _world.world_size.x
		custom_minimum_size = Vector2(LARGE_W, LARGE_W * aspect + HEADER)
	size = custom_minimum_size
	for l in [_clip, _content, _ring]:
		if l != null:
			l.position = Vector2.ZERO
			l.size = size
	_redraw()


func _redraw() -> void:
	queue_redraw()
	for l in [_clip, _content, _ring]:
		if l != null:
			l.queue_redraw()


func update_from(w: GameWorld) -> void:
	var map_changed := _world == null or _fog_map != w.map_id
	_world = w
	if map_changed:
		_resize()
	if map_changed or _fog_version != w.fog.version:
		_rebuild_fog()
	_redraw()


## Ảnh 1 pixel/ô sương: ô đã mở trong suốt, ô chưa mở tối.
func _rebuild_fog() -> void:
	var f = _world.fog
	_fog_version = f.version
	_fog_map = _world.map_id
	if f.w <= 0 or f.h <= 0:
		_fog_tex = null
		return
	var img := Image.create(f.w, f.h, false, Image.FORMAT_RGBA8)
	for cy in f.h:
		for cx in f.w:
			img.set_pixel(cx, cy, Color(0, 0, 0, 0) if f.cells[cy * f.w + cx] == 1 else FOG_COLOR)
	_fog_tex = ImageTexture.create_from_image(img)


## Toạ độ thế giới → bản đồ nhỏ. rect = vùng toàn map (cỡ lớn: khung chữ nhật; cỡ nhỏ: toàn map quy theo tầm nhìn,
## lấy nhân vật làm tâm la bàn — lớp cắt tròn giữ phần trong vòng).
func _to_map(pos: Vector2, rect: Rect2) -> Vector2:
	return rect.position + pos / _world.world_size * rect.size


func _map_rect() -> Rect2:
	if large:
		return Rect2(Vector2(0, HEADER), size - Vector2(0, HEADER))
	var k := _round_k()
	return Rect2(round_center() - _world.player.pos * k, _world.world_size * k)


func _paint(cv: Control, role: String) -> void:
	if _world == null:
		return
	match role:
		"mask":
			if large:
				cv.draw_rect(Rect2(Vector2(0, HEADER), size - Vector2(0, HEADER)), Color.WHITE)
			else:
				cv.draw_circle(round_center(), ROUND_R, Color.WHITE)
		"content":
			_draw_content(cv)
		"ring":
			_draw_ring(cv)


## UI-41: vành la bàn đồng (cỡ nhỏ) hoặc khung đồng + tiêu đề (cỡ lớn).
func _draw_ring(cv: Control) -> void:
	var w := _world
	var ci := cv.get_canvas_item()
	var title := "%s · %d%%" % [str(w.map.name), roundi(w.fog.ratio() * 100.0)]
	if large:
		Bronze.frame(ci, Rect2(Vector2(-6, -6), size + Vector2(12, 12)), 0.7, Color(0, 0, 0, 0), Bronze.GEM_BLUE)
		cv.draw_rect(Rect2(Vector2.ZERO, Vector2(size.x, HEADER)), Color(Bronze.MOSS, 0.95))
		Bronze.title(ci, Vector2(6, 14), title, 14, size.x - 40.0)
		cv.draw_string(UiTheme.bold_font(), Vector2(size.x - 18, 13), "V", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, UiTheme.MUTED)
		return
	var c := round_center()
	var rr := ROUND_R + RING * 0.5
	cv.draw_arc(c, rr, 0.0, TAU, 96, Bronze.BR_DARK, RING + 4.0, true)
	cv.draw_arc(c, rr, 0.0, TAU, 96, Bronze.BR, RING - 1.0, true)
	cv.draw_arc(c, ROUND_R + 1.5, 0.0, TAU, 96, Bronze.BR_DARK, 2.5, true)
	cv.draw_arc(c, ROUND_R + RING - 1.0, PI * 1.05, PI * 1.7, 32, Color(Bronze.BR_LIGHT, 0.7), 1.5, true)
	# vạch chạm khắc
	for i in 48:
		var a := TAU * i / 48.0
		var l := 4.0 if i % 4 == 0 else 2.0
		cv.draw_line(c + Vector2.from_angle(a) * (ROUND_R + 3.0), c + Vector2.from_angle(a) * (ROUND_R + 3.0 + l), Color(Bronze.BR_DARK, 0.75), 1.0, true)
	# chữ N / E / S / W trên tấm đồng nhỏ, kim hướng bắc
	var f := Bronze.title_font()
	for e in [["N", -90.0], ["E", 0.0], ["S", 90.0], ["W", 180.0]]:
		var p := c + Vector2.from_angle(deg_to_rad(float(e[1]))) * rr
		cv.draw_circle(p, 8.5, Bronze.BR_DARK)
		cv.draw_circle(p, 7.0, Color("#3a2a16"))
		var fs := 13
		var tw := f.get_string_size(str(e[0]), HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		cv.draw_string(f, p + Vector2(-tw / 2.0, 4.5), str(e[0]), HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Bronze.GOLD_TEXT)
	var n := c + Vector2(0, -(ROUND_R + RING + 5.0))
	cv.draw_colored_polygon(PackedVector2Array([n + Vector2(0, -6), n + Vector2(5, 2), n + Vector2(-5, 2)]), Bronze.BR_LIGHT)
	for e2 in [45.0, 135.0, 225.0, 315.0]:
		if e2 == 315.0 or e2 == 45.0:
			continue
		Bronze.gem_at(ci, c + Vector2.from_angle(deg_to_rad(e2)) * rr, 2.6, Bronze.GEM_BLUE)
	# nút + / −
	for plus in [true, false]:
		var b := zoom_button(plus)
		var off: bool = (zoom == 0) if plus else (zoom == ZOOMS.size() - 1)
		cv.draw_circle(b, 11.0, Bronze.BR_DARK)
		cv.draw_circle(b, 9.5, Bronze.BR if off else Bronze.BR_MID)
		cv.draw_circle(b, 7.5, Color("#2a2418"))
		var col := Color(0.55, 0.5, 0.42) if off else Bronze.GOLD_TEXT
		cv.draw_line(b + Vector2(-4, 0), b + Vector2(4, 0), col, 2.0)
		if plus:
			cv.draw_line(b + Vector2(0, -4), b + Vector2(0, 4), col, 2.0)
	# biển tên map + % khám phá dưới vòng
	var pr := Rect2(Vector2(10, c.y + ROUND_R + RING - 4.0), Vector2(size.x - 20, PLATE_H))
	Bronze.frame(ci, pr, 0.45, Color(Bronze.MOSS, 0.95), Bronze.GEM_BLUE)
	Bronze.title(ci, pr.position + Vector2(0, 18), title, 14, pr.size.x, HORIZONTAL_ALIGNMENT_CENTER)
	cv.draw_string(UiTheme.bold_font(), Vector2(pr.end.x - 14, pr.position.y + 17), "V", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, UiTheme.MUTED)


func _draw_content(cv: Control) -> void:
	var w := _world
	var rect := _map_rect()
	var k := rect.size.x / w.world_size.x
	if not large:
		cv.draw_circle(round_center(), ROUND_R, FOG_COLOR)
	# đất
	cv.draw_rect(rect, GROUND.get(int(w.map.get("region", 1)), GROUND[1]))
	# làng / thành
	if w.map.get("safe") != null:
		cv.draw_circle(_to_map(w.safe_pos, rect), maxf(3.0, w.safe_r * k), Color(0.85, 0.7, 0.35, 0.45))
	# hang boss
	if w.map.get("arena") != null:
		var ac := _to_map(w.arena_pos, rect)
		cv.draw_circle(ac, maxf(3.0, w.arena_r * k), Color(0.75, 0.2, 0.25, 0.35))
		cv.draw_arc(ac, maxf(3.0, w.arena_r * k), 0.0, TAU, 24, Color(1, 0.33, 0.4, 0.8), 1.0, true)
	# tường sương trước hang (chưa mở)
	if w.map.get("gate", false) and not w.boss_unlocked():
		var gx := rect.position.x + w.gate_x * k
		cv.draw_line(Vector2(gx, rect.position.y), Vector2(gx, rect.end.y), Color(0.7, 0.55, 1.0, 0.8), 2.0)
	# sương che
	if _fog_tex != null:
		cv.draw_texture_rect(_fog_tex, rect, false)
	# MP-09: cổng dịch chuyển (vàng = sang map sau, xanh = về map trước, tím = Cổng Dịch Chuyển)
	for pt in w.portals:
		var pc := _to_map(pt.pos, rect)
		var pcol: Color = {"next": Color("#ffc940"), "back": Color("#6fb6ff"), "cave": Color("#e08a3c"), "exit": Color("#7fe0c0")}.get(pt.kind, Color("#b46bff"))
		# BD-11: Cổng dungeon — chấm to hơn, màu theo hạng
		var big := 1.5 if pt.kind == "dgate" else 0.0
		if pt.kind == "dgate":
			pcol = Gates.COLORS.get(str(pt.get("rank", "E")), pcol)
		cv.draw_circle(pc, 3.5 + big, Color(0, 0, 0, 0.7))
		cv.draw_circle(pc, 2.5 + big, pcol)
	# SN9-06: bãi quái — vòng mờ + số cấp (chỉ bãi đã khám phá)
	for c in w.camps:
		if not w.fog.is_open_at(c.pos):
			continue
		var cc := _to_map(c.pos, rect)
		cv.draw_arc(cc, maxf(4.0, float(c.r) * k), 0.0, TAU, 16, Color(0.95, 0.55, 0.4, 0.55), 1.0, true)
		cv.draw_string(UiTheme.font(), cc + Vector2(-8, 4), str(int(c.level)), HORIZONTAL_ALIGNMENT_CENTER, 16, 9, Color(1, 0.85, 0.7, 0.9))
	# NPC
	for npc in w.npcs():
		cv.draw_circle(_to_map(npc.pos, rect), 2.5, UiTheme.GOLD)
	# quái: chỉ ở chỗ đã khám phá, không hiện quái đang tàng hình
	var pulse := 0.5 + 0.5 * sin(Time.get_ticks_msec() / 160.0)
	for e in w.enemies:
		if e.dead or w.is_hidden(e) or not w.fog.is_open_at(e.pos):
			continue
		var mp := _to_map(e.pos, rect)
		if e.role == "boss" or e.role == "rare":
			cv.draw_circle(mp, 4.5 + pulse * 1.5, Color(1, 0.25, 0.3, 0.9))
			cv.draw_arc(mp, 7.0, 0.0, TAU, 16, Color(1, 0.85, 0.3, 0.6 + 0.4 * pulse), 1.2, true)
		elif e.elite:
			cv.draw_circle(mp, 2.6, Color("#ffb347"))
		else:
			cv.draw_circle(mp, 1.6, Color("#ff5a5a"))
	# điểm đến (SN5-01)
	if w.has_move_target():
		var tp := _to_map(w.move_target, rect)
		cv.draw_line(_to_map(w.player.pos, rect), tp, Color(1, 0.85, 0.3, 0.6), 1.0, true)
		cv.draw_line(tp, tp + Vector2(0, -9), UiTheme.GOLD, 1.5)
		cv.draw_colored_polygon(PackedVector2Array([tp + Vector2(0, -9), tp + Vector2(6, -7), tp + Vector2(0, -5)]), UiTheme.GOLD)
	# nhân vật: mũi tên theo hướng nhìn
	var pp := _to_map(w.player.pos, rect)
	var dir := Vector2.from_angle(w.player.facing)
	var s := 6.0 if large else 5.0
	var tri := PackedVector2Array([pp + dir * s, pp + dir.rotated(2.5) * s * 0.8, pp + dir.rotated(-2.5) * s * 0.8])
	cv.draw_colored_polygon(tri, Color.WHITE)
	cv.draw_polyline(PackedVector2Array([tri[0], tri[1], tri[2], tri[0]]), Color(0, 0, 0, 0.8), 1.0, true)
