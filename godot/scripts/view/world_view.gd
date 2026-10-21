extends Node2D
## Vẽ thế giới. Có hình pixel art (assets/, sinh bằng tools/art) thì vẽ sprite; thiếu hình thì vẽ hình khối tạm.
## Chỉ đọc trạng thái GameWorld, không đổi logic (technical spec D2, D6).

const GameWorld = preload("res://scripts/core/game_world.gd")
const Talents = preload("res://scripts/data/talents.gd")
const UiTheme = preload("res://scripts/ui/ui_theme.gd")
const Items = preload("res://scripts/core/items.gd")
const Monsters = preload("res://scripts/data/monsters.gd")
const SpriteLib = preload("res://scripts/view/sprite_lib.gd")

const HERO_SPRITE := "hero-kiem-khach"
const Classes = preload("res://scripts/data/classes.gd")
const Looks = preload("res://scripts/data/looks.gd")
const CORPSE_TIME := 0.6
const Ch3 = preload("res://scripts/core/chapter3.gd")
const Ch4 = preload("res://scripts/core/chapter4.gd")
const R5View = preload("res://scripts/view/region5_view.gd")
const HIT_FX_TIME := 0.25

var world: GameWorld
var camera: Camera2D

var _trees: Array = []
var _patches: Array = []
var _decor_map := ""
## M6: cảnh sa mạc [{pos, id, scale, flip}] (xương rồng, cọ quanh ốc đảo, cột di tích)
var _desert: Array = []
var _font: Font
var _art := false
## Theo dõi từng thực thể giữa các frame: vị trí cũ (để biết đang chạy), hướng, lúc đổi hoạt ảnh.
var _track: Dictionary = {}
var _corpses: Array = []
var _hit_fx: Array = []
var _fog_layer: FogLayer


## SN-31: lớp sương che vẽ trên cùng thế giới. Texture 1 điểm ảnh / ô, lọc tuyến tính nên mép sương mờ dần.
class FogLayer:
	extends Node2D
	const COLOR := Color(0.02, 0.025, 0.035)
	const ALPHA := 0.94
	var world
	var _tex: ImageTexture
	var _img: Image
	var _version := -1
	var _fog = null

	func _ready() -> void:
		texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		z_index = 50

	func _process(_delta: float) -> void:
		if world == null:
			return
		var f = world.fog
		if f != _fog or f.version != _version:
			_rebuild(f)
		queue_redraw()

	func _rebuild(f) -> void:
		_fog = f
		_version = f.version
		if f.w <= 0 or f.h <= 0:
			_tex = null
			return
		if _img == null or _img.get_width() != f.w or _img.get_height() != f.h:
			_img = Image.create(f.w, f.h, false, Image.FORMAT_RGBA8)
		var open := Color(COLOR, 0.0)
		var shut := Color(COLOR, ALPHA)
		for y in f.h:
			for x in f.w:
				_img.set_pixel(x, y, open if f.cells[y * f.w + x] == 1 else shut)
		if _tex == null or _tex.get_width() != f.w or _tex.get_height() != f.h:
			_tex = ImageTexture.create_from_image(_img)
		else:
			_tex.update(_img)

	func _draw() -> void:
		if _tex == null or world == null or world.travel_timer > 0.0:
			return
		var f = world.fog
		draw_texture_rect(_tex, Rect2(Vector2.ZERO, Vector2(f.w, f.h) * f.CELL), false)


func _ready() -> void:
	_font = UiTheme.font()
	_art = SpriteLib.has_sprite(HERO_SPRITE)
	texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	_fog_layer = FogLayer.new()
	add_child(_fog_layer)


## M4: cây cối, mảng cỏ sinh lại theo từng map (cùng map luôn ra cùng một cảnh).
func _build_decor() -> void:
	_decor_map = world.map_id
	_trees = []
	_patches = []
	var rng := RandomNumberGenerator.new()
	rng.seed = 20261019 if world.map_id == "1-1" else hash(world.map_id)
	var size: Vector2 = world.world_size
	var safe: Vector2 = world.safe_pos
	var path_end: float = world.arena_pos.x if world.map.arena != null else size.x
	var want: int = int(world.map.get("trees", 240))
	var attempts := 0
	while _trees.size() < want and attempts < want * 3:
		attempts += 1
		var pos := Vector2(rng.randf() * size.x, rng.randf() * size.y)
		if pos.distance_to(safe) < world.safe_r + 70.0:
			continue
		if world.map.arena != null and pos.distance_to(world.arena_pos) < world.arena_r + 60.0:
			continue
		if absf(pos.y - safe.y) < 90.0 and pos.x > safe.x and pos.x < path_end:
			continue
		_trees.append({"pos": pos, "r": 16.0 + rng.randf() * 22.0, "shade": rng.randf(), "variant": rng.randi() % 4})
	_desert = []
	if bool(world.map.get("desert", false)):
		var n_cactus := roundi(55 * world.area_factor())
		for i in n_cactus:
			var cp := Vector2(rng.randf() * size.x, rng.randf() * size.y)
			if cp.distance_to(safe) < world.safe_r + 60.0 or Ch3.oasis_at(world, cp) >= 0:
				continue
			_desert.append({"pos": cp, "id": "cactus-%d" % (rng.randi() % 2), "scale": 1.0 + rng.randf() * 0.4, "flip": rng.randf() < 0.5})
		for o in Ch3.oases(world):
			for k in 5:
				var a := TAU * k / 5.0 + rng.randf() * 0.5
				_desert.append({"pos": o[0] + Vector2.from_angle(a) * (float(o[1]) + 18.0), "id": "palm", "scale": 1.0 + rng.randf() * 0.3, "flip": rng.randf() < 0.5})
		if str(world.map.get("decor", "")) == "ruins":
			for i in roundi(30 * world.area_factor()):
				var pp := Vector2(rng.randf() * size.x, rng.randf() * size.y)
				if pp.distance_to(safe) < world.safe_r + 80.0 or (world.map.arena != null and pp.distance_to(world.arena_pos) < world.arena_r + 60.0):
					continue
				_desert.append({"pos": pp, "id": "pillar-%d" % (rng.randi() % 2), "scale": 1.0 + rng.randf() * 0.5, "flip": false})
	for i in roundi(160 * world.area_factor()):
		_patches.append({"pos": Vector2(rng.randf() * size.x, rng.randf() * size.y), "r": 40.0 + rng.randf() * 110.0, "shade": rng.randf()})


func _process(delta: float) -> void:
	for c in _corpses:
		c.t += delta
	_corpses = _corpses.filter(func(c): return c.t < CORPSE_TIME)
	for f in _hit_fx:
		f.t += delta
	_hit_fx = _hit_fx.filter(func(f): return f.t < HIT_FX_TIME)
	queue_redraw()


func _view_rect() -> Rect2:
	var size := get_viewport_rect().size
	var center := camera.get_screen_center_position() if camera else world.player.pos
	return Rect2(center - size / 2.0, size)


func _draw() -> void:
	if world == null:
		return
	if _fog_layer.world != world:
		_fog_layer.world = world
	if _decor_map != world.map_id:
		_build_decor()
		_track = {}
		_corpses = []
	if world.travel_timer > 0.0:
		return
	var view := _view_rect().grow(120.0)
	_draw_ground(view)
	_draw_village_ground()
	if world.map.arena != null:
		_draw_arena()
		R5View.draw_arena(self, world, _art)
	if _art:
		_draw_sorted(view)
	else:
		_draw_village()
		_draw_trees(view)
	_draw_pickups()
	if not _art:
		_draw_herbs_chests()
	for e in world.enemies:
		_draw_telegraph(e)
	if not _art:
		for a in world.allies:
			_draw_ally(a)
		for e in world.enemies:
			_draw_enemy(e)
	_draw_player_skills()
	_draw_wind()
	# Ảo ảnh hút đòn (Mặt Nạ Huyền Ảnh, Phân Thân)
	for dc in world.decoys:
		var a: float = clampf(dc.ttl, 0.0, 1.0)
		SpriteLib.draw_hero(self, world.profile.class_id, world.profile.look, "idle", int(world.time * 3.0) % 2,
			_feet(dc.pos, GameWorld.PLAYER_RADIUS), false, Color(0.7, 0.5, 1.0, 0.55 * a))
	# C1-24: vũng độc Nấm Độc
	for hz in world.hazards:
		var a: float = clampf(hz.ttl, 0.0, 1.0)
		draw_circle(hz.pos, hz.radius, Color(0.55, 0.85, 0.3, 0.25 * a))
		draw_arc(hz.pos, hz.radius, 0.0, TAU, 32, Color(0.7, 0.4, 0.9, 0.6 * a), 2.0, true)
	for pr in world.projectiles:
		if _art:
			SpriteLib.draw_env(self, "fx-spore", pr.pos)
		else:
			draw_circle(pr.pos, pr.radius, Color(0.75, 0.43, 0.94, 0.9))
	if not _art:
		_draw_player()
	_draw_player_fx()
	for e in world.enemies:
		_draw_enemy_overlay(e)
	for f in _hit_fx:
		SpriteLib.draw_env(self, "fx-hit-%d" % mini(2, int(f.t / HIT_FX_TIME * 3.0)), f.pos)
	if not world.boss_unlocked():
		_draw_gate()
	_draw_desert_overlay(view)
	R5View.draw_over(self, world, view, _art)
	_draw_texts()
	_update_tracking()


# ---------------------------------------------------------------- nền
## M7 (C4-11, C4-30, C4-33): mưa độc, gốc đầu Thất Đầu, vòng sáng Phệ mộng, giấc mơ đảo điều khiển.
func _draw_swamp_overlay(view: Rect2) -> void:
	var st = world.ch4
	for r in st.rains:
		var a: float = clampf(r.ttl / Ch4.TOXRAIN_TIME, 0.0, 1.0)
		draw_circle(r.pos, Ch4.TOXRAIN_R, Color(0.45, 0.85, 0.35, 0.16 * a))
		draw_arc(r.pos, Ch4.TOXRAIN_R, 0.0, TAU, 40, Color(0.55, 0.95, 0.45, 0.7 * a), 2.0, true)
		for i in 8:
			var dp: Vector2 = r.pos + Vector2(fposmod(i * 37.0 + world.time * 60.0, 180.0) - 90.0, fposmod(i * 53.0 + world.time * 140.0, 180.0) - 90.0)
			if dp.distance_to(r.pos) < Ch4.TOXRAIN_R:
				draw_line(dp, dp + Vector2(-2, 8), Color(0.6, 1.0, 0.5, 0.7 * a), 2.0)
	for sp in st.stumps:
		var burn := (Ch4.REGROW - float(sp.t)) < Ch4.BURN_WINDOW
		draw_circle(sp.pos, 16.0, Color("#1f5a9a"))
		draw_arc(sp.pos, 22.0, -PI / 2.0, -PI / 2.0 + TAU * (1.0 - float(sp.t) / Ch4.REGROW), 24, Color(0.4, 0.7, 1.0, 0.9), 3.0, true)
		if burn:
			draw_arc(sp.pos, 28.0, 0.0, TAU, 24, Color(1.0, 0.55, 0.2, 0.5 + 0.4 * sin(world.time * 10.0)), 2.0, true)
			_label("Đốt bằng hệ Hỏa / Q", sp.pos + Vector2(0, -36), Color("#ff9a3c"), 11)
	var b = world.boss()
	if b != null and b.kind == "nu-vuong" and b.phase >= 3:
		var pulse := 0.5 + 0.5 * sin(world.time * 3.0)
		draw_circle(st.light_pos, Ch4.LIGHT_R, Color(1.0, 0.95, 0.7, 0.18 + 0.08 * pulse))
		draw_arc(st.light_pos, Ch4.LIGHT_R, 0.0, TAU, 40, Color(1.0, 0.95, 0.7, 0.9), 2.5, true)
		draw_arc(b.pos, Ch4.DRAIN_R, 0.0, TAU, 48, Color(0.7, 0.3, 1.0, 0.35), 2.0, true)
	if st.dream_t > 0.0:
		draw_rect(view, Color(0.35, 0.12, 0.5, 0.28 + 0.06 * sin(world.time * 2.0)))
		for i in 18:
			var sp2 := view.position + Vector2(fposmod(i * 173.0 + world.time * 25.0, view.size.x), fposmod(i * 97.0 + world.time * 15.0, view.size.y))
			draw_circle(sp2, 2.0 + fposmod(i * 1.7, 3.0), Color(1.0, 0.85, 1.0, 0.5))


## M6 (C3-10, C3-12): đêm tối viền, bão cát phủ cát + vệt gió; lốc cát của Bộ Sa Hành Giả.
func _draw_desert_overlay(view: Rect2) -> void:
	for t in world.ch3.trails:
		var a: float = clampf(t.ttl / Ch3.TRAIL_TTL, 0.0, 1.0)
		for k in 3:
			var ang: float = world.time * 3.0 + k * TAU / 3.0
			draw_arc(t.pos, t.r * (0.5 + 0.2 * k), ang, ang + 2.0, 16, Color(0.84, 0.66, 0.4, 0.5 * a), 2.0, true)
	_draw_swamp_overlay(view)
	if not Ch3.is_desert(world):
		return
	var vis := Ch3.vision(world)
	if Ch3.is_night(world):
		var c := world.player.pos
		var inner: float = 520.0 * vis
		draw_rect(view, Color(0.02, 0.03, 0.08, 0.35))
		for i in 6:
			draw_arc(c, inner + i * 60.0, 0.0, TAU, 64, Color(0.02, 0.03, 0.08, 0.12 + i * 0.05), 60.0, false)
	if Ch3.storm_on(world):
		draw_rect(view, Color(0.78, 0.55, 0.3, 0.38))
		for i in 40:
			var sx := fposmod(world.time * 900.0 + i * 197.0, view.size.x + 200.0) - 100.0
			var sy := fposmod(i * 131.0 + world.time * 60.0, view.size.y)
			var a := view.position + Vector2(sx, sy)
			draw_line(a, a + Vector2(-60, 8), Color(0.95, 0.8, 0.55, 0.45), 2.0)


func _draw_ground(view: Rect2) -> void:
	var size: Vector2 = world.world_size
	var whole := PackedVector2Array([Vector2.ZERO, Vector2(size.x, 0), size, Vector2(0, size.y)])
	if not (_art and SpriteLib.fill_polygon(self, whole, str(world.map.get("ground", "tile-grass-0")))):
		draw_rect(Rect2(Vector2.ZERO, size), Color("#1c3226"))
	for p in _patches:
		if view.has_point(p.pos):
			if _art and bool(world.map.get("desert", false)):
				# M6: sa mạc — gợn cát sáng/đỏ nhạt thay cho mảng cỏ tối
				draw_circle(p.pos, p.r, Color(1.0, 0.9, 0.65, 0.07) if p.shade > 0.5 else Color(0.6, 0.3, 0.15, 0.07))
			elif _art:
				draw_circle(p.pos, p.r, Color(0.35, 0.55, 0.3, 0.07) if p.shade > 0.5 else Color(0.02, 0.06, 0.04, 0.16))
			else:
				draw_circle(p.pos, p.r, Color(0.27, 0.43, 0.27, 0.18) if p.shade > 0.5 else Color(0.04, 0.1, 0.07, 0.25))
	# lối mòn từ làng tới hang
	var v: Vector2 = world.safe_pos
	var path_end: float = world.arena_pos.x if world.map.arena != null else size.x
	var path := Rect2(v.x, v.y - 45.0, path_end - v.x, 90.0)
	var path_pts := PackedVector2Array([path.position, Vector2(path.end.x, path.position.y), path.end, Vector2(path.position.x, path.end.y)])
	var path_tile := "tile-sand-red" if bool(world.map.get("desert", false)) and SpriteLib.has_env("tile-sand-red") else "tile-dirt"
	if not (_art and SpriteLib.fill_polygon(self, path_pts, path_tile, Color(1, 1, 1, 0.55))):
		draw_rect(path, Color(0.47, 0.39, 0.27, 0.22))
	# M7 (C4-10): nước đầm — map mặc định là nước thì phủ nước rồi vẽ cồn đất; ngược lại vẽ các hồ nước.
	var wd = world.map.get("water", null)
	if wd != null:
		var water := Color(0.08, 0.2, 0.26, 0.78)
		var land := Color("#3a4a2c")
		if bool(wd.default):
			draw_rect(Rect2(Vector2.ZERO, size), water)
			for z in wd.zones:
				if view.grow(float(z[1])).has_point(z[0]):
					if not (_art and SpriteLib.fill_polygon(self, _circle_points(z[0], float(z[1])), "tile-swamp")):
						draw_circle(z[0], float(z[1]), land)
					draw_arc(z[0], float(z[1]), 0.0, TAU, 48, Color(0.35, 0.45, 0.3, 0.6), 3.0, true)
		else:
			for z in wd.zones:
				if view.grow(float(z[1])).has_point(z[0]):
					draw_circle(z[0], float(z[1]), water)
					draw_arc(z[0], float(z[1]), 0.0, TAU, 48, Color(0.4, 0.6, 0.55, 0.5), 3.0, true)
		# gợn nước
		for i in 24:
			var rp := view.position + Vector2(fposmod(i * 211.0 + world.time * 8.0, view.size.x), fposmod(i * 137.0, view.size.y))
			if Ch4.in_water(world, rp):
				draw_arc(rp, 6.0 + fposmod(world.time * 4.0 + i, 8.0), PI * 1.1, PI * 1.9, 8, Color(0.7, 0.9, 1.0, 0.25), 1.0)
	# M8: dung nham, Đá Nổi, vệt lửa (region5_view.gd)
	R5View.draw_ground(self, world, view, _art)
	# M6: ốc đảo (C3-13) và bóng râm dưới tảng đá (C3-11)
	for o in Ch3.oases(world):
		var oc: Vector2 = o[0]
		var orr: float = float(o[1])
		if view.grow(orr).has_point(oc):
			if _art and SpriteLib.has_env("oasis"):
				SpriteLib.draw_env(self, "oasis", oc, Color.WHITE, orr / 92.0)
			else:
				draw_circle(oc, orr, Color("#3a86c8"))
			draw_arc(oc, orr, 0.0, TAU, 48, Color(0.5, 0.85, 1.0, 0.35), 2.0, true)
	for r in Ch3.rocks(world):
		if view.has_point(r):
			draw_set_transform(r + Vector2(10, 6), 0.0, Vector2(1.0, 0.5))
			draw_circle(Vector2.ZERO, Ch3.SHADE_R, Color(0.1, 0.05, 0.02, 0.28))
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	# sương mù dày dần về phía đông
	var tint: Color = world.map.get("tint", Color(0.16, 0.08, 0.27))
	var clear := Color(tint, 0.0)
	var dense := Color(tint, float(world.map.get("fog", 0.45)))
	draw_polygon(whole, PackedColorArray([clear, dense, dense, clear]))


func _circle_points(c: Vector2, r: float, n := 48) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in n:
		pts.append(c + Vector2.from_angle(TAU * i / n) * r)
	return pts


func _draw_village_ground() -> void:
	var c: Vector2 = world.safe_pos
	var r: float = world.safe_r
	var kind: String = world.map.safe.kind
	var tile := "tile-town" if kind == "town" and SpriteLib.has_env("tile-town") else "tile-village"
	if bool(world.map.get("desert", false)) and SpriteLib.has_env("tile-sand-red"):
		tile = "tile-sand-red"
	if not (_art and SpriteLib.fill_polygon(self, _circle_points(c, r), tile)):
		draw_circle(c, r, Color("#4a3b2a"))
	draw_arc(c, r, 0.0, TAU, 64, Color("#9aa0a6") if kind == "town" else Color("#7a5f3e"), 7.0 if kind == "town" else 5.0, true)
	_label(str(world.map.safe.name), c + Vector2(0, -r - 12.0), Color("#f3e3c3"), 16)


## Vị trí nhà trong vùng an toàn theo loại.
func _safe_buildings() -> Array:
	var kind: String = world.map.safe.kind
	if bool(world.map.get("desert", false)) and kind == "camp":
		return [[Vector2(-60, -50), "tent"], [Vector2(-110, 40), "tent"], [Vector2(20, -110), "tent"]]
	if kind == "camp":
		return [[Vector2(-50, -40), "hut"]]
	if kind == "town":
		return [[Vector2(-150, -120), "house-stone"], [Vector2(-170, 30), "house-stone"], [Vector2(-60, 150), "house-stone"],
			[Vector2(70, -170), "house-stone"], [Vector2(130, 120), "tower"], [Vector2(-40, -200), "tower"]]
	return [[Vector2(-90, -70), "hut"], [Vector2(-110, 40), "hut"], [Vector2(-30, 100), "hut"], [Vector2(60, -105), "hut"]]


func _draw_village() -> void:
	var c: Vector2 = world.safe_pos
	for b in _safe_buildings():
		var t: Vector2 = c + b[0]
		draw_colored_polygon(PackedVector2Array([t + Vector2(0, -26), t + Vector2(-24, 16), t + Vector2(24, 16)]), Color("#b08d57"))
	_draw_stele_fallback()


func _draw_stele_fallback() -> void:
	if world.map.safe.kind != "village":
		return
	var c: Vector2 = world.safe_pos
	var glow := 0.5 + 0.5 * sin(world.time * 2.0)
	draw_circle(c, 46.0, Color(1.0, 0.86, 0.55, 0.12 + glow * 0.12))
	draw_rect(Rect2(c + Vector2(-12, -34), Vector2(24, 50)), Color("#8c8f99"))
	draw_rect(Rect2(c + Vector2(-3, -24), Vector2(6, 26)), Color(1.0, 0.9, 0.63, 0.5 + glow * 0.5))


func _draw_arena() -> void:
	var c: Vector2 = world.arena_pos
	var r: float = world.arena_r
	var arena_tile := "tile-sand-red" if bool(world.map.get("desert", false)) else ("tile-basalt" if str(world.map.get("decor", "")) == "volcano" else "tile-void")
	if not (_art and SpriteLib.fill_polygon(self, _circle_points(c, r, 64), arena_tile, Color(1, 1, 1, 0.85))):
		draw_circle(c, r, Color("#251d33"))
	var locked: bool = world.boss() != null
	draw_arc(c, r, 0.0, TAU, 96, Color(1.0, 0.33, 0.44, 0.7) if locked else Color(0.63, 0.51, 0.86, 0.35), 5.0 if locked else 3.0, true)
	var name: String = world.map.arena.name
	var title := ("%s (đã chinh phục)" % name) if world.is_boss_defeated(world.arena_boss()) else name
	_label(title, c + Vector2(0, -r - 12.0), Color("#d8c8ff"), 16)


func _draw_trees(view: Rect2) -> void:
	for t in _trees:
		if not view.has_point(t.pos):
			continue
		draw_circle(t.pos + Vector2(6, 8), t.r, Color(0, 0, 0, 0.25))
		draw_circle(t.pos, t.r, Color("#244a32") if t.shade > 0.5 else Color("#1e3e2b"))
		draw_circle(t.pos - Vector2.ONE * t.r * 0.3, t.r * 0.5, Color(0.47, 0.67, 0.43, 0.12))


# ---------------------------------------------------------------- sắp xếp theo chiều sâu (AR-31, AR-32)
func _draw_sorted(view: Rect2) -> void:
	var items: Array = []
	for t in _trees:
		if view.has_point(t.pos):
			items.append([t.pos.y + t.r * 0.6, _draw_tree_sprite.bind(t)])
	var c: Vector2 = world.safe_pos
	for b in _safe_buildings():
		var at: Vector2 = c + b[0] + Vector2(0, 16)
		var id: String = b[1] if SpriteLib.has_env(b[1]) else "hut"
		items.append([at.y, _draw_env_at.bind(id, at)])
	if world.map.safe.kind == "village":
		items.append([c.y + 16.0, _draw_stele.bind(c + Vector2(0, 16))])
	# M6: sa mạc
	for d in _desert:
		if view.has_point(d.pos):
			items.append([d.pos.y, _draw_env_scaled.bind(d.id, d.pos, d.scale, d.flip)])
	for r in Ch3.rocks(world):
		if view.has_point(r):
			items.append([r.y, _draw_env_scaled.bind("rock-desert-%d" % (int(r.x) % 2), r, 1.6, int(r.y) % 2 == 0)])
	if world.map.has("stele3") and view.has_point(world.map.stele3):
		items.append([world.map.stele3.y, _draw_stele.bind(world.map.stele3)])
	for pl in world.ch3.pillars:
		items.append([pl.pos.y, _draw_puzzle_pillar.bind(pl)])
	# M7: Bọc Mộng (nhiệm vụ chương 4 bước 3)
	var pods: Array = world.map.get("pods", [])
	var got: Array = world.profile.quest.get("orbs4", [])
	if int(world.profile.quest.get("ch4", 0)) == 3:
		for i in pods.size():
			if not (i in got) and view.has_point(pods[i]):
				items.append([pods[i].y, _draw_env_scaled.bind("dream-pod", pods[i], 1.4, false)])

	for h in world.herbs:
		if h.respawn <= 0.0:
			items.append([h.pos.y, _draw_env_at.bind("herb", h.pos)])
	for ch in world.chests:
		if world.chest_visible(ch):
			items.append([ch.pos.y, _draw_chest.bind(ch)])
	for a in world.allies:
		items.append([a.pos.y, _draw_ally_sprite.bind(a)])
	for e in world.enemies:
		items.append([e.pos.y, _draw_enemy_sprite.bind(e)])
	for k in _corpses:
		items.append([k.pos.y - 1.0, _draw_corpse.bind(k)])
	# C1-11, M4.3: NPC của map (dữ liệu maps.gd), bấm E khi đứng gần
	for npc in world.npcs():
		items.append([npc.pos.y, _draw_npc.bind(npc.sprite, npc.pos, npc.name)])
	items.append([world.player.pos.y, _draw_player_sprite])
	items.sort_custom(func(a, b): return a[0] < b[0])
	for it in items:
		it[1].call()


func _draw_npc(id: String, at: Vector2, label: String) -> void:
	if not SpriteLib.has_sprite(id):
		return
	SpriteLib.draw_frame(self, id, "idle", int(world.time * 3.0) % 2, at, at.x > world.player.pos.x)
	_label(label, at + Vector2(0, -70), Color("#f3e3c3"), 11)


func _draw_env_at(id: String, at: Vector2) -> void:
	SpriteLib.draw_env(self, id, at)


func _draw_env_scaled(id: String, at: Vector2, k: float, flip: bool) -> void:
	SpriteLib.draw_env(self, id, at, Color.WHITE, k, flip)


## C3-33: cột đá Câu Đố Nhân Sư — vòng màu theo hệ, cột Mộc là cột an toàn.
func _draw_puzzle_pillar(pl: Dictionary) -> void:
	var col := Color(Monsters.ELEMENT_HEX[pl.element])
	var pulse := 0.5 + 0.5 * sin(world.time * 6.0)
	draw_circle(pl.pos, Ch3.PILLAR_R, Color(col, 0.18 + 0.1 * pulse))
	draw_arc(pl.pos, Ch3.PILLAR_R, 0.0, TAU, 40, Color(col, 0.9), 3.0, true)
	if SpriteLib.has_env("pillar-0"):
		SpriteLib.draw_env(self, "pillar-0", pl.pos, col.lerp(Color.WHITE, 0.5), 1.4)
	_label(Monsters.ELEMENT_NAMES[pl.element], pl.pos + Vector2(0, -80), col, 15)


func _feet(pos: Vector2, r: float) -> Vector2:
	return pos + Vector2(0, r * 0.6)


func _draw_tree_sprite(t: Dictionary) -> void:
	var base: Vector2 = t.pos + Vector2(0, t.r * 0.6)
	# M7: đầm lầy — cây chết, lau sậy, lá súng (trên nước), bụi.
	if str(world.map.get("decor", "forest")) == "swamp":
		var wet := Ch4.in_water(world, t.pos)
		var sid: String = ("lily" if wet else ["dead-tree-0", "reeds-0", "dead-tree-1", "reeds-1"][t.variant])
		if not SpriteLib.has_env(sid):
			sid = "bush"
		SpriteLib.draw_env(self, sid, base, Color.WHITE, 1.0 if t.r < 28.0 else 1.3, t.shade > 0.5)
		return
	# M8: núi lửa — đá dung nham, cây cháy, miệng phun.
	if str(world.map.get("decor", "forest")) == "volcano":
		SpriteLib.draw_env(self, R5View.decor_id(t.variant), base, Color.WHITE, 1.0 if t.r < 28.0 else 1.4, t.shade > 0.5)
		return
	# M4.2: thảo nguyên — đá, cỏ cao, bụi thay cho cây rừng.
	if str(world.map.get("decor", "forest")) == "plains":
		var pid: String = ["rock-0", "tall-grass", "rock-1", "bush"][t.variant]
		SpriteLib.draw_env(self, pid if SpriteLib.has_env(pid) else "bush", base, Color.WHITE, 1.0 if t.r < 28.0 else 1.4, t.shade > 0.5)
		return
	if t.r < 20.0:
		SpriteLib.draw_env(self, "bush", base, Color.WHITE, 1.0, t.shade > 0.5)
		return
	var id: String = ["tree-0", "tree-1", "tree-2", "tree-pine"][t.variant]
	var tint := Color(0.85, 0.9, 0.85) if t.shade > 0.5 else Color.WHITE
	SpriteLib.draw_env(self, id, base, tint, 1.0 if t.r < 32.0 else 1.5, t.shade > 0.7)


func _draw_stele(at: Vector2) -> void:
	var glow := 0.5 + 0.5 * sin(world.time * 2.0)
	draw_circle(at + Vector2(0, -30), 46.0, Color(1.0, 0.86, 0.55, 0.08 + glow * 0.1))
	SpriteLib.draw_env(self, "stele", at, Color(1, 1, 1).lerp(Color(1.0, 0.95, 0.8), glow))


func _draw_chest(c) -> void:
	var pulse := 0.5 + 0.5 * sin(world.time * 4.0)
	draw_circle(c.pos, 20.0 + pulse * 6.0, Color(1.0, 0.85, 0.3, 0.15))
	SpriteLib.draw_env(self, "chest", c.pos)


## Hoạt ảnh: trả về [tên, thời gian trong hoạt ảnh]; đổi tên thì tính lại từ 0.
func _anim_time(key: int, anim: String) -> float:
	var tr: Dictionary = _track.get(key, {})
	if tr.get("anim", "") != anim:
		tr["anim"] = anim
		tr["since"] = world.time
		_track[key] = tr
	return world.time - float(tr.since)


func _moving(key: int, pos: Vector2) -> bool:
	var tr: Dictionary = _track.get(key, {})
	return tr.has("pos") and (tr.pos as Vector2).distance_squared_to(pos) > 0.04


func _facing_left(key: int, pos: Vector2, fallback: bool) -> bool:
	var tr: Dictionary = _track.get(key, {})
	if tr.has("pos"):
		var dx: float = pos.x - (tr.pos as Vector2).x
		if absf(dx) > 0.2:
			tr["left"] = dx < 0.0
	return tr.get("left", fallback)


func _update_tracking() -> void:
	var alive := {}
	for e in world.enemies:
		alive[e.id] = true
		var tr: Dictionary = _track.get(e.id, {})
		tr["pos"] = e.pos
		tr["kind"] = e.kind
		tr["hp"] = e.hp
		tr["flash"] = e.hit_flash
		tr["mul"] = _enemy_size(e)
		tr["feet"] = _feet(e.pos, e.radius)
		_track[e.id] = tr
	# quái vừa biến mất mà hết máu → để lại hoạt ảnh chết
	for key in _track.keys():
		if key is int and key >= 0 and not alive.has(key):
			var tr: Dictionary = _track[key]
			if tr.has("kind") and float(tr.get("hp", 1.0)) <= 0.0 and SpriteLib.has_sprite(tr.kind):
				_corpses.append({"kind": tr.kind, "pos": tr.feet, "left": tr.get("left", false), "mul": tr.get("mul", 1.0), "t": 0.0})
			_track.erase(key)
	var pt: Dictionary = _track.get(-1, {})
	pt["pos"] = world.player.pos
	_track[-1] = pt
	for i in world.allies.size():
		var a = world.allies[i]
		var key: int = -100 - a.get_instance_id() % 100000
		var at: Dictionary = _track.get(key, {})
		at["pos"] = a.pos
		_track[key] = at


func _enemy_size(e) -> float:
	var def_r: float = Monsters.DEFS[e.kind].radius
	return clampf(e.radius / def_r, 0.75, 2.0)


func _draw_enemy_sprite(e) -> void:
	if e.burrow_t > 0.0 and e.state != "windup":
		var wob := sin(world.time * 14.0) * 3.0
		draw_set_transform(e.pos + Vector2(0, e.radius * 0.6), 0.0, Vector2(1.0, 0.45))
		draw_circle(Vector2.ZERO, e.radius + 6.0 + wob, Color("#a87a44"))
		draw_circle(Vector2(-3, -4), e.radius * 0.6, Color("#d6a865"))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		return
	if not SpriteLib.has_sprite(e.kind):
		_draw_enemy(e)
		return
	# M4.2: tinh anh vùng 2 có hình riêng (Đội Trưởng, Phù Thuỷ Gió).
	var sid: String = e.kind
	if e.elite:
		var es: String = str(Monsters.DEFS[e.kind].get("elite_sprite", e.kind))
		if SpriteLib.has_sprite(es):
			sid = es
	var hidden := world.is_hidden(e)
	var anim := "idle"
	var frame := 0
	if e.state == "windup":
		anim = "attack"
		frame = SpriteLib.frame_progress(sid, anim, 1.0 - maxf(0.0, e.timer) / e.windup_total)
	elif e.state == "stunned" or e.hit_flash > 0.0:
		anim = "hurt"
	else:
		anim = "run" if _moving(e.id, e.pos) else "idle"
		frame = SpriteLib.frame_at(sid, anim, _anim_time(e.id, anim))
	if anim != "idle" and anim != "run":
		_anim_time(e.id, anim)
	var left: bool = world.player.pos.x < e.pos.x if e.state in ["windup", "chase"] else _facing_left(e.id, e.pos, false)
	var mod := Color.WHITE
	if e.role == "boss" and e.phase >= 2:
		mod = Color(1.25, 0.8, 0.85)
	if e.elite:
		mod = Color(1.15, 1.08, 0.85)
	if e.illusion:
		mod = Color(0.85, 0.9, 1.0, 0.6 + 0.15 * sin(world.time * 6.0 + e.id))
	if e.charm_t > 0.0:
		mod = Color(1.2, 0.8, 1.3)
	if e.hit_flash > 0.0:
		mod = Color(1.6, 1.6, 1.6)
	if world.freeze_timer > 0.0:
		mod = mod * Color(0.7, 0.85, 1.3)
	mod.a = 0.15 if hidden else 1.0
	# C1-22: Lõi Sương — quái ở xa bị sương che mờ
	if world.map_id == "1-3" and not hidden and e.pos.distance_to(world.player.pos) > GameWorld.FOG_SIGHT:
		mod.a = 0.5
	# Huyền Ảnh không có vòng chân: chỉ bóng phân biệt bản thật (kịch bản).
	if (e.elite or e.role == "boss") and e.kind != "huyen-anh":
		var ring := Color("#ff5470") if e.role == "boss" else Color("#ffc940")
		_ground_ring(_feet(e.pos, e.radius), e.radius + 4.0, Color(ring, 0.8 * mod.a))
	# M4.2: khiên chặn phía trước
	if Monsters.DEFS[e.kind].get("shield", false) and not hidden:
		draw_arc(e.pos, e.radius + 9.0, e.face - GameWorld.SHIELD_ARC, e.face + GameWorld.SHIELD_ARC, 16, Color(0.8, 0.85, 0.95, 0.75), 4.0, true)
	SpriteLib.draw_frame(self, sid, anim, frame, _feet(e.pos, e.radius), left, mod, _enemy_size(e))


func _draw_corpse(k: Dictionary) -> void:
	var frame := SpriteLib.frame_at(k.kind, "death", k.t)
	SpriteLib.draw_frame(self, k.kind, "death", frame, k.pos, k.left, Color(1, 1, 1, 1.0 - k.t / CORPSE_TIME * 0.5), k.mul)


func _draw_ally_sprite(a) -> void:
	if not SpriteLib.has_sprite(a.monster):
		_draw_ally(a)
		return
	var key: int = -100 - a.get_instance_id() % 100000
	var anim := "run" if _moving(key, a.pos) else "idle"
	var frame := SpriteLib.frame_at(a.monster, anim, world.time)
	var shadow: bool = a.kind == "shadow"
	var mod := Color(0.55, 0.35, 0.95, 0.8) if shadow else Color.WHITE
	_ground_ring(_feet(a.pos, a.radius), a.radius + 3.0, Color("#b36bff") if shadow else Color("#5bd16a"))
	SpriteLib.draw_frame(self, a.monster, anim, frame, _feet(a.pos, a.radius), _facing_left(key, a.pos, false), mod, clampf(a.radius / 16.0, 0.75, 1.25))


## Sprite để tính số frame (thân theo ngoại hình; thiếu thì hình mặc định của lớp).
func _hero() -> String:
	var base: String = Looks.base_sprite(world.profile.class_id, world.profile.look)
	if SpriteLib.has_sprite(base):
		return base
	var id: String = Classes.get_class_def(world.profile.class_id).sprite
	return id if SpriteLib.has_sprite(id) else HERO_SPRITE


func _draw_player_sprite() -> void:
	var hs := _hero()
	var p := world.player
	var anim := "idle"
	var frame := 0
	if p.dead_timer > 0.0:
		anim = "death"
		frame = SpriteLib.frame_at(hs, anim, GameWorld.RESPAWN_TIME - p.dead_timer)
	elif p.swing > 0.0 and p.swing_kind in ["slash", "shot", "dash", "cast"]:
		anim = "attack"
		frame = SpriteLib.frame_progress(hs, anim, 1.0 - clampf(p.swing / (0.25 if p.swing_kind == "cast" else 0.16), 0.0, 1.0))
	elif p.hurt > 0.0:
		anim = "hurt"
	else:
		anim = "run" if _moving(-1, p.pos) else "idle"
		frame = SpriteLib.frame_at(hs, anim, _anim_time(-1, anim))
	var left := cos(p.facing) < 0.0
	var alpha := 0.55 if p.dodge_time > 0.0 or p.dash_time > 0.0 else 1.0
	var rank_color := Talents.rank_color(world.talent().rank)
	_ground_ring(_feet(p.pos, GameWorld.PLAYER_RADIUS), GameWorld.PLAYER_RADIUS + 6.0, Color(rank_color, 0.7 * alpha))
	var mod := Color(1, 1, 1, alpha)
	if p.swing > 0.0 and p.swing_kind == "spin":
		# Xoáy Kiếm: xoay nhanh, nháy sáng
		left = int(p.swing * 40.0) % 2 == 0
		mod = Color(1.25, 1.3, 1.45, alpha)
		frame = 1
		anim = "attack"
	if p.eagle_time > 0.0:
		mod = mod * Color(1.2, 1.15, 0.85)
	if p.poison_timer > 0.0:
		mod = mod * Color(0.75, 1.15, 0.7)
	# Spec_Notes N8: vũ khí cường hoá cao toả hào quang quanh nhân vật.
	var wpn: Dictionary = world.profile.equipment.get("weapon", {})
	var plus: int = int(wpn.get("plus", 0))
	var tier := Items.enhance_tier(plus)
	if tier > 0 and p.dead_timer <= 0.0:
		var gc := Items.enhance_color(plus)
		var mid := p.pos + Vector2(0, -6)
		draw_circle(mid, 26.0 + tier * 3.0, Color(gc, 0.06 + 0.03 * tier + 0.03 * sin(world.time * 3.0)))
		for k in tier * 2:
			var ang := world.time * (1.2 + 0.2 * tier) + k * TAU / (tier * 2)
			var rr := 22.0 + 6.0 * sin(world.time * 2.0 + k)
			draw_circle(mid + Vector2(cos(ang) * rr, sin(ang) * rr * 0.55), 1.5 + 0.4 * tier, Color(gc, 0.9))
	if p.root_timer > 0.0:
		var feet := _feet(p.pos, GameWorld.PLAYER_RADIUS)
		for k in 5:
			var a := TAU * k / 5.0 + 0.3
			draw_line(feet + Vector2.from_angle(a) * 20.0, feet + Vector2(0, -18) + Vector2.from_angle(a) * 6.0, Color("#674a32"), 4.0, true)
	SpriteLib.draw_hero(self, world.profile.class_id, world.profile.look, anim, frame, _feet(p.pos, GameWorld.PLAYER_RADIUS), left, mod)
	# C1-02: tên trên đầu
	if p.dead_timer <= 0.0:
		_label(str(world.profile.name), p.pos + Vector2(0, -GameWorld.PLAYER_RADIUS - 46.0), Color(1, 1, 1, 0.85), 12)
	# SN-04 Pháp Thuẫn: vòng tím, dày theo lượng khiên còn lại
	if p.shield > 0.0:
		var k := clampf(p.shield / maxf(1.0, float(world.stats.max_hp) * GameWorld.BARRIER_PCT), 0.0, 1.0)
		var a2 := 0.35 + 0.15 * sin(world.time * 6.0)
		draw_circle(p.pos, GameWorld.PLAYER_RADIUS + 16.0, Color(0.7, 0.45, 1.0, a2 * 0.35))
		for i in 6:
			var ang := world.time * 1.5 + TAU * i / 6.0
			draw_arc(p.pos, GameWorld.PLAYER_RADIUS + 16.0, ang, ang + 0.7, 8, Color(0.85, 0.7, 1.0, 0.5 + 0.4 * k), 1.5 + 2.0 * k, true)
	# Thiết Bích: vòng khiên
	if p.guard_time > 0.0:
		var a := 0.35 + 0.15 * sin(world.time * 8.0)
		draw_circle(p.pos, GameWorld.PLAYER_RADIUS + 14.0, Color(0.6, 0.8, 1.0, a * 0.4))
		draw_arc(p.pos, GameWorld.PLAYER_RADIUS + 14.0, 0.0, TAU, 40, Color(0.8, 0.92, 1.0, a + 0.3), 2.5, true)


func _ground_ring(pos: Vector2, r: float, c: Color) -> void:
	draw_set_transform(pos, 0.0, Vector2(1.0, 0.45))
	draw_arc(Vector2.ZERO, r, 0.0, TAU, 40, c, 2.5, true)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


## M4.2: vệt gió chạy theo hướng gió.
func _draw_wind() -> void:
	if world.wind_dir == Vector2.ZERO:
		return
	var view := _view_rect()
	var d: Vector2 = world.wind_dir
	var power: float = world.wind_power()
	for i in 46:
		var seed_x := float((i * 7919) % 1000) / 1000.0
		var seed_y := float((i * 104729) % 1000) / 1000.0
		var travel := fposmod(world.time * 420.0 * power + i * 173.0, view.size.x + view.size.y)
		var start := view.position + Vector2(seed_x * view.size.x, seed_y * view.size.y)
		var at := start + d * travel
		at = Vector2(view.position.x + fposmod(at.x - view.position.x, view.size.x), view.position.y + fposmod(at.y - view.position.y, view.size.y))
		draw_line(at, at + d * (26.0 + 14.0 * power), Color(1, 1, 1, 0.12 * power), 1.5, true)


## M3: tên bay, kiếm khí, mưa tên, bẫy, vòng nổ.
func _draw_player_skills() -> void:
	for t in world.traps:
		if _art and SpriteLib.has_env("fx-trap"):
			SpriteLib.draw_env(self, "fx-trap", t.pos)
		else:
			draw_circle(t.pos, 10.0, Color("#9ba8bc"))
		draw_arc(t.pos, GameWorld.TRAP_TRIGGER, 0.0, TAU, 24, Color(1, 0.8, 0.3, 0.25), 1.5, true)
	for z in world.rains:
		var pulse := 0.5 + 0.5 * sin(world.time * 12.0)
		draw_circle(z.pos, z.radius, Color(1, 0.33, 0.44, 0.10 + 0.05 * pulse))
		draw_arc(z.pos, z.radius, 0.0, TAU, 40, Color(1, 0.5, 0.5, 0.6), 2.0, true)
		for i in 6:
			var ang := float(i) * 1.7 + world.time * 3.0
			var at: Vector2 = z.pos + Vector2(cos(ang), sin(ang * 1.3)) * z.radius * 0.6
			var fall := fposmod(world.time * 4.0 + i * 0.37, 1.0)
			var from := at + Vector2(-12, -60) * (1.0 - fall)
			if _art:
				SpriteLib.draw_env(self, "fx-arrow", from, Color(1, 1, 1, 0.9), 1.0, false, Vector2(12, 60).angle())
			else:
				draw_line(from, from + Vector2(4, 20), Color.WHITE, 2.0)
	# SN-04: Thiên Thạch — vòng báo hiệu co dần, thiên thạch rơi chéo xuống
	for m in world.meteors:
		var k: float = 1.0 - m.timer / GameWorld.METEOR_DELAY
		draw_circle(m.pos, m.radius, Color(1, 0.45, 0.15, 0.08 + 0.12 * k))
		draw_arc(m.pos, m.radius, 0.0, TAU, 40, Color(1, 0.6, 0.25, 0.8), 2.0, true)
		draw_arc(m.pos, m.radius * k, 0.0, TAU, 40, Color(1, 0.8, 0.4, 0.9), 2.0, true)
		var rock: Vector2 = m.pos + Vector2(-140, -260) * (1.0 - k)
		draw_line(rock, rock + Vector2(-50, -90), Color(1, 0.55, 0.2, 0.5), 8.0, true)
		draw_circle(rock, 16.0, Color(1, 0.5, 0.15, 0.45))
		draw_circle(rock, 10.0, Color("#6a4a3a"))
		draw_circle(rock + Vector2(-3, -3), 4.0, Color("#ffe08a"))
	# SN-04: Lôi Xích — tia sét gấp khúc
	for b in world.bolts:
		var a: float = clampf(b.ttl / 0.3, 0.0, 1.0)
		for i in b.points.size() - 1:
			var p0: Vector2 = b.points[i]
			var p1: Vector2 = b.points[i + 1]
			var pts := PackedVector2Array([p0])
			var n := (p1 - p0).orthogonal().normalized()
			for j in range(1, 5):
				pts.append(p0.lerp(p1, j / 5.0) + n * randf_range(-9.0, 9.0))
			pts.append(p1)
			draw_polyline(pts, Color(0.6, 0.8, 1.0, 0.5 * a), 7.0, true)
			draw_polyline(pts, Color(1, 1, 1, a), 2.0, true)
			draw_circle(p1, 10.0, Color(0.7, 0.85, 1.0, 0.4 * a))
	for s in world.shots:
		if s.kind == "fireball":
			draw_circle(s.pos - s.vel.normalized() * 10.0, 9.0, Color(1, 0.45, 0.1, 0.35))
			draw_circle(s.pos, 11.0, Color(1, 0.5, 0.15, 0.5))
			draw_circle(s.pos, 7.0, Color("#ff9a3c"))
			draw_circle(s.pos + Vector2(1.5, -1.5), 3.5, Color("#ffe08a"))
			continue
		var id: String = {"arrow": "fx-arrow", "wave": "fx-wave", "pierce": "fx-pierce"}.get(s.kind, "fx-arrow")
		if _art and SpriteLib.has_env(id):
			SpriteLib.draw_env(self, id, s.pos, Color.WHITE, 1.0, false, s.vel.angle())
		else:
			draw_circle(s.pos, s.radius, Color("#c8e6ff"))
	for b in world.blasts:
		var k: float = 1.0 - b.ttl / 0.35
		draw_circle(b.pos, b.radius * (0.6 + 0.4 * k), Color(b.color, 0.35 * (1.0 - k)))
		draw_arc(b.pos, b.radius * (0.6 + 0.4 * k), 0.0, TAU, 40, Color(b.color, 0.9 * (1.0 - k)), 3.0, true)


## Hiệu ứng chém/Xoáy Kiếm (vector) vẽ trên cùng.
func _draw_player_fx() -> void:
	var p := world.player
	if p.swing <= 0.0:
		return
	if p.swing_kind == "shot" or p.swing_kind == "cast":
		return
	if p.swing_kind == "dash":
		var back := p.pos - p.dash_dir * 60.0
		draw_line(back, p.pos, Color(1, 0.9, 0.85, 0.5), 18.0, true)
		return
	if p.swing_kind == "slash":
		var pts := PackedVector2Array([p.pos])
		for i in 13:
			var a := p.facing - GameWorld.SLASH_ARC + (2.0 * GameWorld.SLASH_ARC) * i / 12.0
			pts.append(p.pos + Vector2.from_angle(a) * GameWorld.SLASH_RANGE)
		draw_colored_polygon(pts, Color(1, 1, 1, 0.25 * minf(1.0, p.swing / 0.16)))
	else:
		var r := GameWorld.SPIN_RANGE * (1.0 - p.swing / 0.6)
		draw_arc(p.pos, r, 0.0, TAU, 48, Color(0.78, 0.9, 1.0, 0.7 * minf(1.0, p.swing / 0.3)), 10.0, true)


## Thanh máu, nhãn tên/hệ, choáng — vẽ trên mọi sprite.
func _draw_enemy_overlay(e) -> void:
	if not _art:
		return
	var hidden := world.is_hidden(e)
	var top_y: float = e.pos.y - e.radius * 2.2
	if e.state == "stunned":
		_label("✦ choáng ✦", Vector2(e.pos.x, top_y - 14.0), Color("#ffc940"), 13)
	if e.hit_flash > 0.0 and not _flashed(e):
		_hit_fx.append({"pos": e.pos + Vector2(randf_range(-6, 6), -e.radius + randf_range(-6, 6)), "t": 0.0})
	if e.role == "boss" or hidden:
		return
	if e.hp < e.max_hp or e.elite:
		var w: float = e.radius * 2.0
		var top := Vector2(e.pos.x - w / 2.0, top_y)
		draw_rect(Rect2(top, Vector2(w, 4)), Color(0, 0, 0, 0.6))
		draw_rect(Rect2(top, Vector2(w * maxf(0.0, e.hp) / e.max_hp, 4)), Color("#ff5470"))
		# CB-07: thanh Phá Thế của tinh anh
		if e.max_poise > 0.0:
			draw_rect(Rect2(top + Vector2(0, 5), Vector2(w, 3)), Color(0, 0, 0, 0.6))
			draw_rect(Rect2(top + Vector2(0, 5), Vector2(w * maxf(0.0, e.poise) / e.max_poise, 3)), Color("#ffc940"))
	if e.elite:
		_label("%s · Lv%d" % [e.name, e.level], Vector2(e.pos.x, top_y - 6.0), Color("#ffd877"), 12)
	var el: String = Monsters.DEFS[e.kind].element
	_label(Monsters.ELEMENT_NAMES[el], Vector2(e.pos.x + e.radius + 14.0, top_y + 10.0), Color(Monsters.ELEMENT_HEX[el], 0.8), 10)


## Chỉ sinh tia trúng đòn ở frame đầu của mỗi lần nháy.
func _flashed(e) -> bool:
	var tr: Dictionary = _track.get(e.id, {})
	return float(tr.get("flash", 0.0)) > 0.0


# ---------------------------------------------------------------- hình khối tạm (khi chưa có hình)
func _draw_gate() -> void:
	if world.gate_x == INF:
		return
	var x: float = world.gate_x
	var h: float = world.world_size.y
	var a := Color(0.47, 0.35, 0.78, 0.0)
	var b := Color(0.47, 0.35, 0.78, 0.55)
	var c := Color(0.16, 0.1, 0.27, 0.92)
	draw_polygon(PackedVector2Array([Vector2(x - 40, 0), Vector2(x + 25, 0), Vector2(x + 25, h), Vector2(x - 40, h)]), PackedColorArray([a, b, b, a]))
	draw_polygon(PackedVector2Array([Vector2(x + 25, 0), Vector2(x + 140, 0), Vector2(x + 140, h), Vector2(x + 25, h)]), PackedColorArray([b, c, c, b]))
	for i in 14:
		var y := fposmod(i * 131.0 + world.time * 30.0, h)
		draw_circle(Vector2(x + 30.0 + sin(world.time + i) * 20.0, y), 50.0, Color(0.75, 0.67, 1.0, 0.12))
	_label("Sương mù Hư Vô", Vector2(x + 50.0, world.safe_pos.y - 70.0), Color("#e6dcff"), 15)


func _draw_pickups() -> void:
	for pk in world.pickups:
		var bob := sin(world.time * 6.0 + pk.pos.x) * 2.0
		var at: Vector2 = pk.pos + Vector2(0, bob)
		match pk.kind:
			"gold":
				if _art:
					SpriteLib.draw_env(self, "pickup-gold", at)
				else:
					draw_circle(at, 5.0, Color("#ffc940"))
			"stone":
				if _art:
					SpriteLib.draw_env(self, "pickup-stone", at)
				else:
					draw_rect(Rect2(at - Vector2(5, 5), Vector2(10, 10)), Color("#9ec8ff"))
			"item":
				var c := Items.rarity_color(pk.item)
				draw_circle(at, 18.0, Color(c, 0.22))
				var tex := SpriteLib.item_icon(pk.item) if _art else null
				if tex:
					draw_arc(at, 17.0, 0.0, TAU, 32, Color(c, 0.8), 2.0, true)
					draw_texture_rect(tex, Rect2(at - Vector2(16, 16), Vector2(32, 32)), false)
				else:
					draw_colored_polygon(PackedVector2Array([at + Vector2(0, -10), at + Vector2(8, 0), at + Vector2(0, 10), at + Vector2(-8, 0)]), c)
			_:
				if _art:
					SpriteLib.draw_env(self, "pickup-orb", at)
				else:
					draw_circle(at, 7.0, Color("#5bd16a"))


func _draw_herbs_chests() -> void:
	for h in world.herbs:
		if h.respawn > 0.0:
			continue
		for i in 3:
			var leaf: Vector2 = h.pos + Vector2.from_angle(i * TAU / 3.0 + 0.4) * 6.0
			draw_circle(leaf, 6.0, Color("#6fdc7a"))
		draw_circle(h.pos, 3.0, Color("#e8f7a0"))
	for c in world.chests:
		if not world.chest_visible(c):
			continue
		var pulse := 0.5 + 0.5 * sin(world.time * 4.0)
		draw_circle(c.pos, 20.0 + pulse * 6.0, Color(1.0, 0.85, 0.3, 0.15))
		draw_rect(Rect2(c.pos - Vector2(10, 7), Vector2(20, 14)), Color("#a8752f"))
		draw_rect(Rect2(c.pos - Vector2(10, 7), Vector2(20, 4)), Color("#ffc940"))


func _draw_ally(a) -> void:
	var alpha := 0.75 if a.kind == "shadow" else 1.0
	draw_circle(a.pos + Vector2(3, 5), a.radius, Color(0, 0, 0, 0.25))
	draw_circle(a.pos, a.radius, Color(a.color, alpha))
	draw_arc(a.pos, a.radius + 3.0, 0.0, TAU, 32, Color("#5bd16a") if a.kind == "pet" else Color("#b36bff"), 2.0, true)


func _draw_telegraph(e: GameWorld.Enemy) -> void:
	if e.state != "windup":
		return
	var progress := 1.0 - maxf(0.0, e.timer) / e.windup_total
	match e.attack_kind:
		"pounce":
			draw_circle(e.target, GameWorld.POUNCE_RADIUS, Color(1, 0.24, 0.31, 0.15))
			draw_circle(e.target, GameWorld.POUNCE_RADIUS * progress, Color(1, 0.24, 0.31, 0.35))
		"spore":
			draw_dashed_line(e.pos, e.target, Color(0.78, 0.47, 1.0, 0.25 + progress * 0.5), 2.0, 6.0)
		"dive":
			draw_circle(e.target, GameWorld.DIVE_R, Color(1, 1, 1, 0.12))
			draw_circle(e.target, GameWorld.DIVE_R * progress, Color(1, 1, 1, 0.3))
		"volley", "darts", "dart1":
			var ang: float = (e.target - e.pos).angle()
			var spread: float = deg_to_rad(15.0 if e.attack_kind == "volley" else 20.0)
			for k in [-1, 0, 1]:
				draw_line(e.pos, e.pos + Vector2.from_angle(ang + k * spread) * 220.0, Color(1, 0.6, 0.3, 0.15 + progress * 0.4), 2.0, true)
		"pull":
			draw_circle(e.pos, GameWorld.PULL_R, Color(0.85, 0.9, 1.0, 0.08 + 0.06 * sin(world.time * 10.0)))
			draw_arc(e.pos, GameWorld.PULL_R * (1.0 - progress * 0.6), 0.0, TAU, 32, Color(0.9, 0.95, 1.0, 0.7), 2.0, true)
		"blink":
			draw_circle(e.pos, 60.0, Color(0.7, 0.4, 1.0, 0.12 + progress * 0.25))
		"tiger":
			# M5-01: Hổ Vồ — vòng 6 m ở chỗ sẽ vồ tới, vạch nối từ hổ
			draw_line(e.pos, e.target, Color(0.95, 0.95, 0.9, 0.15 + progress * 0.3), 3.0, true)
			draw_circle(e.target, GameWorld.TIGER_R, Color(1, 0.24, 0.31, 0.12))
			draw_circle(e.target, GameWorld.TIGER_R * progress, Color(1, 0.24, 0.31, 0.32))
			draw_arc(e.target, GameWorld.TIGER_R, 0.0, TAU, 40, Color(1, 0.24, 0.31, 0.7), 2.0, true)
		"roar":
			draw_circle(e.pos, GameWorld.ROAR_R, Color(0.86, 0.9, 0.95, 0.08 + progress * 0.12))
			draw_arc(e.pos, GameWorld.ROAR_R * progress, 0.0, TAU, 48, Color(0.86, 0.9, 0.95, 0.7), 3.0, true)
			draw_arc(e.pos, GameWorld.ROAR_R, 0.0, TAU, 48, Color(0.86, 0.9, 0.95, 0.5), 2.0, true)
		"roots":
			for k in 3:
				var c: Vector2 = e.target + Vector2.from_angle(k * TAU / 3.0) * GameWorld.ROOT_R * 0.9
				draw_circle(c, GameWorld.ROOT_R, Color(0.6, 0.4, 0.2, 0.15))
				draw_circle(c, GameWorld.ROOT_R * progress, Color(0.6, 0.4, 0.2, 0.35))
		"leaf":
			var dir: float = (e.target - e.pos).angle()
			var pts := PackedVector2Array([e.pos])
			for i in 9:
				pts.append(e.pos + Vector2.from_angle(dir - GameWorld.LEAF_ARC + 2.0 * GameWorld.LEAF_ARC * i / 8.0) * (GameWorld.LEAF_RANGE + e.radius))
			draw_colored_polygon(pts, Color(0.4, 0.85, 0.45, 0.12 + progress * 0.25))
		"dash":
			draw_line(e.pos, e.pos + (e.target - e.pos).limit_length(150.0), Color(0.6, 0.9, 1.0, 0.2 + progress * 0.5), 6.0, true)
		"stomp", "explode":
			var r: float = GameWorld.STOMP_R if e.attack_kind == "stomp" else GameWorld.EXPLODE_R
			draw_circle(e.pos, r, Color(1, 0.4, 0.2, 0.12))
			draw_circle(e.pos, r * progress, Color(1, 0.4, 0.2, 0.3))
			draw_arc(e.pos, r, 0.0, TAU, 40, Color(1, 0.4, 0.2, 0.7), 2.0, true)
		"emerge", "sdive", "tail", "sandvortex":
			# M6: vòng cát / đuôi độc tại chỗ đánh dấu
			var rr: float = {"emerge": Ch3.BURROW_R, "sdive": Ch3.DIVE_R, "tail": Ch3.TAIL_R, "sandvortex": Ch3.VORTEX_R}[e.attack_kind]
			var cc := Color(0.55, 1.0, 0.35) if e.attack_kind == "tail" else Color(0.85, 0.6, 0.3)
			draw_circle(e.target, rr, Color(cc, 0.12))
			draw_circle(e.target, rr * progress, Color(cc, 0.32))
			draw_arc(e.target, rr, 0.0, TAU, 40, Color(cc, 0.8), 2.0, true)
		"roll":
			draw_line(e.pos, e.target, Color(1, 0.8, 0.3, 0.2 + progress * 0.5), e.radius * 1.6, true)
		"gaze":
			var gd: float = (e.target - e.pos).angle()
			var gp := PackedVector2Array([e.pos])
			for i in 9:
				gp.append(e.pos + Vector2.from_angle(gd - Ch3.GAZE_HALF + 2.0 * Ch3.GAZE_HALF * i / 8.0) * (Ch3.GAZE_R + e.radius))
			draw_colored_polygon(gp, Color(0.3, 0.75, 1.0, 0.12 + progress * 0.25))
		_:
			draw_arc(e.pos, e.radius + e.attack_range * progress, 0.0, TAU, 40, Color(1, 0.24, 0.31, 0.2 + progress * 0.6), 3.0, true)


func _draw_enemy(e: GameWorld.Enemy) -> void:
	var hidden := world.is_hidden(e)
	var alpha := 0.15 if hidden else 1.0
	draw_circle(e.pos + Vector2(4, 6), e.radius, Color(0, 0, 0, 0.3 * alpha))
	var body: Color = Color.WHITE if e.hit_flash > 0.0 else e.color
	draw_circle(e.pos, e.radius, Color(body, alpha))
	if e.elite or e.role == "boss":
		var ring := Color("#ff5470") if e.role == "boss" else Color("#ffc940")
		draw_arc(e.pos, e.radius + 3.0, 0.0, TAU, 40, Color(ring, alpha), 3.0, true)
	if world.freeze_timer > 0.0:
		draw_circle(e.pos, e.radius, Color(0.55, 0.78, 1.0, 0.45))
	# mắt nhìn về phía người chơi
	var look: float = (world.player.pos - e.pos).angle()
	var eye := Color("#ff3b4e") if (e.role == "boss" or e.elite) else Color("#1a1a1a")
	for side in [-0.45, 0.45]:
		draw_circle(e.pos + Vector2.from_angle(look + side) * e.radius * 0.55, maxf(2.0, e.radius * 0.12), Color(eye, alpha))
	if e.state == "stunned":
		_label("✦ choáng ✦", e.pos + Vector2(0, -e.radius - 14.0), Color("#ffc940"), 13)
	if e.role != "boss" and not hidden:
		if e.hp < e.max_hp:
			var w: float = e.radius * 2.0
			var top: Vector2 = e.pos + Vector2(-w / 2.0, -e.radius - 10.0)
			draw_rect(Rect2(top, Vector2(w, 4)), Color(0, 0, 0, 0.6))
			draw_rect(Rect2(top, Vector2(w * maxf(0.0, e.hp) / e.max_hp, 4)), Color("#ff5470"))
		if e.elite:
			_label("%s · Lv%d" % [e.name, e.level], e.pos + Vector2(0, -e.radius - 16.0), Color("#ffd877"), 12)
		# TL-S6: hệ ngũ hành của quái.
		var el: String = Monsters.DEFS[e.kind].element
		_label(Monsters.ELEMENT_NAMES[el], e.pos + Vector2(e.radius + 14.0, -e.radius), Color(Monsters.ELEMENT_HEX[el], 0.8), 10)


func _draw_player() -> void:
	var p := world.player
	var alpha := 0.3 if p.dead_timer > 0.0 else (0.55 if p.dodge_time > 0.0 else 1.0)
	var rank_color := Talents.rank_color(world.talent().rank)
	draw_arc(p.pos, GameWorld.PLAYER_RADIUS + 6.0, 0.0, TAU, 40, Color(rank_color, 0.6 * alpha), 2.0, true)
	draw_circle(p.pos + Vector2(4, 6), GameWorld.PLAYER_RADIUS, Color(0, 0, 0, 0.3 * alpha))
	var body := Color("#ff8a8a") if p.hurt > 0.0 else Color("#e8d9a8")
	draw_circle(p.pos, GameWorld.PLAYER_RADIUS, Color(body, alpha))
	draw_arc(p.pos, GameWorld.PLAYER_RADIUS, 0.0, TAU, 32, Color(0.23, 0.18, 0.12, alpha), 2.0, true)
	var dir := Vector2.from_angle(p.facing)
	draw_line(p.pos + dir * (GameWorld.PLAYER_RADIUS - 2.0), p.pos + dir * (GameWorld.PLAYER_RADIUS + 26.0), Color(0.81, 0.89, 1.0, alpha), 4.0, true)


func _draw_texts() -> void:
	# SN5-10: dòng nhặt đồ xếp chồng trên đầu nhân vật (mới nhất ở dưới), không đè nhau.
	var notes: Array = world.pickup_notes
	for i in notes.size():
		var n = notes[i]
		var row := notes.size() - 1 - i
		var at: Vector2 = world.player.pos + Vector2(0, -96.0 - row * 20.0)
		_label(n.text, at, Color(n.color, minf(1.0, n.ttl * 2.0)), 16 if n.big else 14, true)
	# SN5-01: điểm đến khi bấm bản đồ nhỏ
	if world.has_move_target():
		var tp: Vector2 = world.move_target
		var k := 0.5 + 0.5 * sin(world.time * 6.0)
		draw_arc(tp, 14.0 + 4.0 * k, 0.0, TAU, 24, Color(1, 0.85, 0.3, 0.8), 2.0, true)
		draw_line(tp, tp + Vector2(0, -26), Color("#ffc940"), 2.0)
		draw_colored_polygon(PackedVector2Array([tp + Vector2(0, -26), tp + Vector2(14, -21), tp + Vector2(0, -16)]), Color("#ffc940"))
	for t in world.texts:
		var size := 19 if t.big else 15
		var c: Color = t.color
		_label(t.text, t.pos, Color(c, minf(1.0, t.ttl * 2.0)), size, true)


func _label(text: String, pos: Vector2, color: Color, size: int, bold := false) -> void:
	var f := UiTheme.bold_font() if bold else _font
	var w := 400.0
	var at := pos - Vector2(w / 2.0, 0)
	draw_string_outline(f, at, text, HORIZONTAL_ALIGNMENT_CENTER, w, size, 4, Color(0, 0, 0, 0.75 * color.a))
	draw_string(f, at, text, HORIZONTAL_ALIGNMENT_CENTER, w, size, color)
