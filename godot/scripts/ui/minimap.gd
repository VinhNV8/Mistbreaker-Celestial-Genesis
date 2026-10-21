extends Control
## M5-03 (Spec_Notes đợt 3): bản đồ nhỏ theo thời gian thực ở góc phải HUD.
## Đất đã khám phá (sương che SN-31), làng/thành, hang boss, tường sương, NPC, quái trong vùng đã thấy,
## boss và boss hiếm, nhân vật (mũi tên theo hướng nhìn). Phím V: đổi cỡ nhỏ / lớn.

const UiTheme = preload("res://scripts/ui/ui_theme.gd")
const GameWorld = preload("res://scripts/core/game_world.gd")

const SMALL_W := 230.0
const LARGE_W := 460.0
const HEADER := 18.0
## Màu đất theo vùng (vùng 1 rừng, vùng 2 thảo nguyên).
const GROUND := {1: Color("#2f4a34"), 2: Color("#6b6340"), 3: Color("#a87a44")}
const FOG_COLOR := Color("#0b0d14")

var large := false
var _world: GameWorld
var _fog_tex: ImageTexture
var _fog_version := -1
var _fog_map := ""


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	_resize()


func toggle_size() -> void:
	large = not large
	_resize()


func _resize() -> void:
	var w := LARGE_W if large else SMALL_W
	var aspect := 2560.0 / 4480.0
	if _world != null and _world.world_size.x > 0.0:
		aspect = _world.world_size.y / _world.world_size.x
	custom_minimum_size = Vector2(w, w * aspect + HEADER)
	size = custom_minimum_size


func update_from(w: GameWorld) -> void:
	var map_changed := _world == null or _fog_map != w.map_id
	_world = w
	if map_changed:
		_resize()
	if map_changed or _fog_version != w.fog.version:
		_rebuild_fog()
	queue_redraw()


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


func _to_map(pos: Vector2, rect: Rect2) -> Vector2:
	return rect.position + pos / _world.world_size * rect.size


func _draw() -> void:
	if _world == null:
		return
	var w := _world
	var rect := Rect2(Vector2(0, HEADER), size - Vector2(0, HEADER))
	var k := rect.size.x / w.world_size.x
	# khung + tiêu đề
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.04, 0.05, 0.08, 0.82))
	var font := UiTheme.bold_font()
	var title := "%s · %d%%" % [str(w.map.name), roundi(w.fog.ratio() * 100.0)]
	draw_string(font, Vector2(6, 13), title, HORIZONTAL_ALIGNMENT_LEFT, size.x - 40.0, 11, UiTheme.GOLD)
	draw_string(font, Vector2(size.x - 18, 13), "V", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, UiTheme.MUTED)
	# đất
	draw_rect(rect, GROUND.get(int(w.map.get("region", 1)), GROUND[1]))
	# làng / thành
	if w.map.get("safe") != null:
		draw_circle(_to_map(w.safe_pos, rect), maxf(3.0, w.safe_r * k), Color(0.85, 0.7, 0.35, 0.45))
	# hang boss
	if w.map.get("arena") != null:
		var ac := _to_map(w.arena_pos, rect)
		draw_circle(ac, maxf(3.0, w.arena_r * k), Color(0.75, 0.2, 0.25, 0.35))
		draw_arc(ac, maxf(3.0, w.arena_r * k), 0.0, TAU, 24, Color(1, 0.33, 0.4, 0.8), 1.0, true)
	# tường sương trước hang (chưa mở)
	if w.map.get("gate", false) and not w.boss_unlocked():
		var gx := rect.position.x + w.gate_x * k
		draw_line(Vector2(gx, rect.position.y), Vector2(gx, rect.end.y), Color(0.7, 0.55, 1.0, 0.8), 2.0)
	# sương che
	if _fog_tex != null:
		draw_texture_rect(_fog_tex, rect, false)
	# NPC
	for npc in w.npcs():
		draw_circle(_to_map(npc.pos, rect), 2.5, UiTheme.GOLD)
	# quái: chỉ ở chỗ đã khám phá, không hiện quái đang tàng hình
	var pulse := 0.5 + 0.5 * sin(Time.get_ticks_msec() / 160.0)
	for e in w.enemies:
		if e.dead or w.is_hidden(e) or not w.fog.is_open_at(e.pos):
			continue
		var mp := _to_map(e.pos, rect)
		if e.role == "boss" or e.role == "rare":
			draw_circle(mp, 4.5 + pulse * 1.5, Color(1, 0.25, 0.3, 0.9))
			draw_arc(mp, 7.0, 0.0, TAU, 16, Color(1, 0.85, 0.3, 0.6 + 0.4 * pulse), 1.2, true)
		elif e.elite:
			draw_circle(mp, 2.6, Color("#ffb347"))
		else:
			draw_circle(mp, 1.6, Color("#ff5a5a"))
	# nhân vật: mũi tên theo hướng nhìn
	var pp := _to_map(w.player.pos, rect)
	var dir := Vector2.from_angle(w.player.facing)
	var s := 6.0 if large else 5.0
	var tri := PackedVector2Array([pp + dir * s, pp + dir.rotated(2.5) * s * 0.8, pp + dir.rotated(-2.5) * s * 0.8])
	draw_colored_polygon(tri, Color.WHITE)
	draw_polyline(PackedVector2Array([tri[0], tri[1], tri[2], tri[0]]), Color(0, 0, 0, 0.8), 1.0, true)
	draw_rect(Rect2(Vector2.ZERO, size), Color(UiTheme.GOLD, 0.5), false, 1.0)
