extends Node2D
## Vẽ thế giới. Có hình pixel art (assets/, sinh bằng tools/art) thì vẽ sprite; thiếu hình thì vẽ hình khối tạm.
## Chỉ đọc trạng thái GameWorld, không đổi logic (technical spec D2, D6).

const Maps = preload("res://scripts/data/maps.gd")
## BD-11 (docs/34): Cổng dungeon.
const Gates = preload("res://scripts/core/gates.gd")
const ElementIcon = preload("res://scripts/ui/element_icon.gd")
const GameWorld = preload("res://scripts/core/game_world.gd")
const Talents = preload("res://scripts/data/talents.gd")
const UiTheme = preload("res://scripts/ui/ui_theme.gd")
const Settings = preload("res://scripts/core/settings.gd")
const Items = preload("res://scripts/core/items.gd")
const Monsters = preload("res://scripts/data/monsters.gd")
const SpriteLib = preload("res://scripts/view/sprite_lib.gd")
const QuestView = preload("res://scripts/view/quest_view.gd")
const ViewScale = preload("res://scripts/core/view_scale.gd")

const HERO_SPRITE := "hero-kiem-khach"
const Classes = preload("res://scripts/data/classes.gd")
const Looks = preload("res://scripts/data/looks.gd")
const CORPSE_TIME := 0.6
const Ch3 = preload("res://scripts/core/chapter3.gd")
const Ch4 = preload("res://scripts/core/chapter4.gd")
const R5View = preload("res://scripts/view/region5_view.gd")
const SK2View = preload("res://scripts/view/skills2_view.gd")
const ClassFx = preload("res://scripts/view/class_fx.gd")
## FX-1 (docs/36): hiệu ứng kỹ năng thiết kế lại, vẽ vector HD; lớp glow vẽ cộng sáng ở node con.
const Fx1 = preload("res://scripts/view/fx1.gd")
const Fx1Kit = preload("res://scripts/view/fx1_kit.gd")
const CL2View = preload("res://scripts/view/classes2_view.gd")
const J3View = preload("res://scripts/view/job3_view.gd")
const R6View = preload("res://scripts/view/region6_view.gd")
const R7View = preload("res://scripts/view/region7_view.gd")
const R8View = preload("res://scripts/view/region8_view.gd")
const R9View = preload("res://scripts/view/region9_view.gd")
const Ch7 = preload("res://scripts/core/chapter7.gd")
## GN-1 E2 / E3 (docs/45): bộ cảnh trại / bãi chiến vùng 1 + nguồn sáng điểm.
const CampDecor = preload("res://scripts/view/camp_decor.gd")
## GN-4 E6 (docs/45 §9): vách đá viền map + thành hồ / hố.
const TerrainEdge = preload("res://scripts/view/terrain_edge.gd")
const HIT_FX_TIME := 0.25

var world: GameWorld
var camera: Camera2D

var _trees: Array = []
var _fade_focus: Array = []  # §9.13: điểm cần thấy, cây che thì mờ (khung hiện tại)
var _patches: Array = []
## VS-1 B2 (docs/44): mảng sáng nắng / bóng râm lớn (300–800 px) trên nền.
var _light: Array = []
## PF-02 (docs/44 §7): mảng nắng / bóng râm + lớp hạ tông nướng sẵn thành 1 ảnh thấp (1 điểm ảnh = LIGHT_CELL px thế giới,
## lọc Linear qua CanvasTexture) — trước đây vẽ 15–20 hình mờ cỡ 600–1600 px chồng nhau mỗi khung (tốn tô điểm ảnh GPU).
const LIGHT_CELL := 40.0
var _light_tex: CanvasTexture
var _light_rect := Rect2()
var _decor_map := ""
## M6: cảnh sa mạc [{pos, id, scale, flip}] (xương rồng, cọ quanh ốc đảo, cột di tích)
var _desert: Array = []
## GN-1 E2: cảnh trại (đứng, sắp theo chiều sâu) + đồ vương vãi phẳng (vẽ cùng nền).
var _camp: Array = []
var _camp_flat: Array = []
## GN-3 E1: nền đất mòn dưới bãi trại.
var _camp_ground: Array = []
## GN-1 E3: lớp quầng sáng cộng (đuốc, đèn lồng, lửa trại) — con của WorldView, dưới sương mù chiến tranh.
var _lamp_glow: Node2D
var _font: Font
var _art := false
## Theo dõi từng thực thể giữa các frame: vị trí cũ (để biết đang chạy), hướng, lúc đổi hoạt ảnh.
var _track: Dictionary = {}
var _corpses: Array = []
var _hit_fx: Array = []
## AR-45b: keyframe thi triển kỹ năng (ClassFx.draw_casts); nhận ra lúc thi triển qua bước nhảy hồi chiêu của ô.
var _cast_fx: Array = []
var _cast_watch: Array = []  # [world, hồi chiêu từng ô, id từng ô] của khung trước
var _fog_layer: FogLayer
var _fx1_glow: Fx1Glow
var _pa: Fx1Kit.Painter = Fx1Kit.Painter.new()
## GN-1 P3 (docs/45): camera dẫn hướng — main đặt mỗi khung, cộng với rung.
var cam_lead := Vector2.ZERO
## GN-4 P1-B: hệ số nghiêng phối cảnh (main đặt) — SpriteLib dựng hình đứng thẳng bù lại.
var tilt_g := 0.0
## FX-1 §9.8: rung camera (camera.offset — vị trí camera vẫn do main điều khiển) + khựng đòn (Engine.time_scale ngắn).
var _shake_t := 0.0
var _shake_amp := 0.0
var _stop_prev := -1.0


## FX-1: lớp glow (BLEND_MODE_ADD) vẽ sau mọi thứ của world_view.
class Fx1Glow extends Node2D:
	var glow: Array = []

	func _draw() -> void:
		preload("res://scripts/view/fx1_kit.gd").flush_glow(self, glow)


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

	## V14 (docs/38): rìa sương mềm — làm mờ 5×5 trên GPU (ảnh sương 1 điểm / ô, lọc tuyến tính vẫn thấy
	## bậc thang ô vuông).
	const SOFT_SHADER := """
shader_type canvas_item;
uniform vec2 texel = vec2(0.01);
void fragment() {
	vec4 s = vec4(0.0);
	for (int i = -2; i <= 2; i++) {
		for (int j = -2; j <= 2; j++) {
			s += texture(TEXTURE, UV + vec2(float(i), float(j)) * texel * 0.65);
		}
	}
	COLOR = s / 25.0;
}
"""
	var _mat: ShaderMaterial

	func _ready() -> void:
		texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		z_index = 50
		var sh := Shader.new()
		sh.code = SOFT_SHADER
		_mat = ShaderMaterial.new()
		_mat.shader = sh
		material = _mat

	func _process(_delta: float) -> void:
		if world == null:
			return
		var f = world.fog
		if f != _fog or f.version != _version:
			_rebuild(f)
		queue_redraw()

	func _rebuild(f) -> void:
		if f.w <= 0 or f.h <= 0:
			_fog = f
			_version = f.version
			_tex = null
			return
		if _img == null or _img.get_width() != f.w or _img.get_height() != f.h:
			_img = Image.create(f.w, f.h, false, Image.FORMAT_RGBA8)
			_tex = null
		var open := Color(COLOR, 0.0)
		var shut := Color(COLOR, ALPHA)
		# PF-01: chỉ một lần reveal() kể từ lần trước → cập nhật vùng ô đó; còn lại dựng cả ảnh.
		var area := Rect2i(0, 0, f.w, f.h)
		if f == _fog and _tex != null and f.dirty_version == f.version and _version == f.version - 1:
			area = f.dirty
		_version = f.version
		for y in range(area.position.y, area.end.y):
			for x in range(area.position.x, area.end.x):
				_img.set_pixel(x, y, open if f.cells[y * f.w + x] == 1 else shut)
		if _mat != null:
			_mat.set_shader_parameter("texel", Vector2(1.0 / f.w, 1.0 / f.h))
		_fog = f
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
	_lamp_glow = Node2D.new()
	var lmat := CanvasItemMaterial.new()
	lmat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_lamp_glow.material = lmat
	_lamp_glow.draw.connect(_draw_lamp_glow)
	add_child(_lamp_glow)
	_fog_layer = FogLayer.new()
	add_child(_fog_layer)
	_fx1_glow = Fx1Glow.new()
	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_fx1_glow.material = mat
	add_child(_fx1_glow)


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
		if _near_portal(pos):
			continue
		# M10: cây cảnh vùng 7 chỉ mọc trên đảo
		if world.map.has("islands") and not Ch7.on_land_static(world.map, pos):
			continue
		_trees.append({"pos": pos, "r": 16.0 + rng.randf() * 22.0, "shade": rng.randf(), "variant": rng.randi() % 4})
	_desert = []
	if bool(world.map.get("desert", false)):
		var n_cactus := roundi(55 * world.area_factor())
		for i in n_cactus:
			var cp := Vector2(rng.randf() * size.x, rng.randf() * size.y)
			if cp.distance_to(safe) < world.safe_r + 60.0 or Ch3.oasis_at(world, cp) >= 0 or _near_portal(cp):
				continue
			_desert.append({"pos": cp, "id": "cactus-%d" % (rng.randi() % 2), "scale": 1.0 + rng.randf() * 0.4, "flip": rng.randf() < 0.5})
		for o in Ch3.oases(world):
			for k in 5:
				var a := TAU * k / 5.0 + rng.randf() * 0.5
				_desert.append({"pos": o[0] + Vector2.from_angle(a) * (float(o[1]) + 18.0), "id": "palm", "scale": 1.0 + rng.randf() * 0.3, "flip": rng.randf() < 0.5})
		if str(world.map.get("decor", "")) == "ruins":
			for i in roundi(30 * world.area_factor()):
				var pp := Vector2(rng.randf() * size.x, rng.randf() * size.y)
				if pp.distance_to(safe) < world.safe_r + 80.0 or (world.map.arena != null and pp.distance_to(world.arena_pos) < world.arena_r + 60.0) or _near_portal(pp):
					continue
				_desert.append({"pos": pp, "id": "pillar-%d" % (rng.randi() % 2), "scale": 1.0 + rng.randf() * 0.5, "flip": false})
	# GN-3 (docs/45 §8): xương rồng / cọ không mọc trong sân đấu trường (lọc sau khi sinh — không đổi chỗ các cây khác).
	if world.map.arena != null:
		_desert = _desert.filter(func(d): return d.pos.distance_to(world.arena_pos) >= world.arena_r + 40.0)
	# HP-04: hang phụ — đá rải dày dọc 2 vách trên/dưới, lác đác giữa hang (chừa cửa hang, cổng, khu Chúa Hang).
	if bool(world.map.get("cave", false)):
		var rid: String = {3: "rock-desert", 5: "rock-lava", 6: "rock-ice"}.get(int(world.map.get("region", 1)), "rock")
		for i in 90:
			var edge := i < 70
			var y := (rng.randf() * 150.0 if rng.randf() < 0.5 else size.y - rng.randf() * 150.0) if edge else 260.0 + rng.randf() * (size.y - 520.0)
			var rp := Vector2(rng.randf() * size.x, y)
			if rp.distance_to(safe) < world.safe_r + 80.0 or _near_portal(rp) or rp.distance_to(Vector2(2300, size.y / 2.0)) < 220.0:
				continue
			_desert.append({"pos": rp, "id": "%s-%d" % [rid, rng.randi() % 2], "scale": (1.3 + rng.randf() * 0.8) if edge else (0.9 + rng.randf() * 0.4), "flip": rng.randf() < 0.5})
	for i in roundi(160 * world.area_factor()):
		_patches.append({"pos": Vector2(rng.randf() * size.x, rng.randf() * size.y), "r": 40.0 + rng.randf() * 110.0, "shade": rng.randf()})
	# VS-1 B2: RNG riêng — không đổi cảnh cây / đá đã sinh của các map.
	_light = []
	var lr := RandomNumberGenerator.new()
	lr.seed = hash(str(world.map_id) + "|light")
	for i in roundi(size.x * size.y / 260000.0):
		_light.append({"pos": Vector2(lr.randf() * size.x, lr.randf() * size.y), "r": 300.0 + lr.randf() * 500.0, "sun": lr.randf() < 0.45})
	_bake_light(size)
	# GN-1 E2: cảnh trại vùng 1 (chỉ hình HD) — RNG riêng; cây đè lên cảnh bị bỏ.
	_camp = []
	_camp_flat = []
	_camp_ground = []
	if SpriteLib.hd_enabled() and SpriteLib.has_env("palisade"):
		var cd := CampDecor.build(world)
		_camp = cd.items
		_camp_flat = cd.flat
		_camp_ground = cd.ground
		_trees = CampDecor.filter_trees(_trees, cd.clear)


## MP-09: chừa chỗ quanh cổng dịch chuyển (không mọc cây / đá đè lên cổng).
func _near_portal(pos: Vector2) -> bool:
	for pt in world.portals:
		if pos.distance_to(pt.pos) < 120.0:
			return true
	return false


func _process(delta: float) -> void:
	for c in _corpses:
		c.t += delta
	_corpses = _corpses.filter(func(c): return c.t < CORPSE_TIME)
	for f in _hit_fx:
		f.t += delta
	_hit_fx = _hit_fx.filter(func(f): return f.t < HIT_FX_TIME)
	_watch_casts(delta)
	queue_redraw()


func _watch_casts(delta: float) -> void:
	for f in _cast_fx:
		f.t += delta
	_cast_fx = _cast_fx.filter(ClassFx.cast_alive)
	if world == null:
		return
	Fx1.tick(world, delta)
	_update_shake(delta)
	var cds: Array = world.player.skill_cds.duplicate()
	var ids: Array = []
	for i in cds.size():
		ids.append(str(world.slot_skill(i).get("id", "")))
	# Cùng world, cùng kỹ năng trong ô, hồi chiêu tăng vọt = vừa thi triển (đổi bộ kỹ năng / nạp save thì bỏ qua).
	if _cast_watch.size() == 3 and _cast_watch[0] == world and world.travel_timer <= 0.0:
		for i in mini(cds.size(), _cast_watch[1].size()):
			if ids[i] != "" and ids[i] == _cast_watch[2][i] and float(cds[i]) > float(_cast_watch[1][i]) + 0.05:
				if not Fx1.on_cast(world, world.slot_skill(i)):
					ClassFx.on_cast(_cast_fx, world, world.slot_skill(i))
	_cast_watch = [world, cds, ids]


func _update_shake(delta: float) -> void:
	var s := Fx1.take_shake()
	if s > 0.0:
		_shake_t = 0.22 + 0.1 * s
		_shake_amp = maxf(_shake_amp if _shake_t > 0.0 else 0.0, 3.0 + 7.0 * s)
		if s >= 0.6 and _stop_prev < 0.0 and Engine.time_scale > 0.2:
			_stop_prev = Engine.time_scale  # smoke chạy ×3 → trả đúng giá trị cũ
			Engine.time_scale = 0.08
			get_tree().create_timer(0.045, true, false, true).timeout.connect(func():
				Engine.time_scale = _stop_prev
				_stop_prev = -1.0)
	if camera == null:
		return
	if _shake_t > 0.0:
		_shake_t -= delta / maxf(0.05, Engine.time_scale)
		var k := clampf(_shake_t / 0.3, 0.0, 1.0)
		camera.offset = cam_lead + Vector2(randf_range(-1, 1), randf_range(-1, 1)) * _shake_amp * k
	else:
		camera.offset = cam_lead
		_shake_amp = 0.0


func _view_rect() -> Rect2:
	# VS-1: camera zoom ra → khung nhìn rộng hơn khung viewport (PF-01 chỉ vẽ trong khung nhìn).
	var size := get_viewport_rect().size / (camera.zoom if camera else Vector2.ONE)
	var center := camera.get_screen_center_position() if camera else world.player.pos
	return Rect2(center - size / 2.0, size)


## GN-4 P1-B (docs/45 §9): trong lúc vẽ thế giới, SpriteLib xô ngược từng hình quanh chân để sau lớp biến dạng phối cảnh
## hình đứng thẳng (chân vẫn khớp nền).
func _draw() -> void:
	SpriteLib.upright_begin(get_canvas_transform(), get_viewport_rect().size, tilt_g)
	_draw_world()
	SpriteLib.upright_end()


func _draw_world() -> void:
	if world == null:
		return
	if _fog_layer.world != world:
		_fog_layer.world = world
	if _decor_map != world.map_id:
		_build_decor()
		_track = {}
		_corpses = []
	_pa = Fx1Kit.Painter.new(self)
	Fx1.painter = _pa
	if world.travel_timer > 0.0:
		_fx1_glow.glow = []
		_fx1_glow.queue_redraw()
		return
	var view := _view_rect().grow(120.0)
	_draw_ground(view)
	TerrainEdge.draw_border(self, world, view)
	_draw_village_ground()
	# GN-3 E1: nền đất mòn dưới bãi trại — 2 lớp (viền mờ + lõi) mép lượn
	for g in _camp_ground:
		if view.grow(float(g[1])).has_point(g[0]):
			SpriteLib.fill_polygon(self, _ellipse_blob(g[0], float(g[1]) * 1.25, float(g[2]) * 1.25), str(g[3]), Color(1, 1, 1, 0.2))
			SpriteLib.fill_polygon(self, _ellipse_blob(g[0], float(g[1]), float(g[2])), str(g[3]), Color(1, 1, 1, 0.5))
	for d in _camp_flat:
		if view.has_point(d.pos):
			SpriteLib.draw_env(self, d.id, d.pos, Color.WHITE, float(d.scale), bool(d.flip))
	R6View.draw_props(self, world, view, _art)
	if world.map.arena != null:
		if view.grow(world.arena_r + 40.0).has_point(world.arena_pos):
			_draw_arena()
		R5View.draw_arena(self, world, _art)
		R7View.draw_arena(self, world, _art)
		R8View.draw_arena(self, world, _art)
		R9View.draw_arena(self, world, _art)
	if _depth_on():
		_draw_depth_ground(view)
		_draw_shadows(view)
	_draw_portals(view)
	# FX-1 §9.12: vết cảnh báo kiểu tự nhiên (ghi ở khung trước) nằm DƯỚI quái / cây
	Fx1.flush_ground(_pa, world)
	if _art:
		_draw_sorted(view)
	else:
		_draw_village()
		_draw_trees(view)
	_lamp_view = view
	_lamp_glow.queue_redraw()
	_draw_portal_labels(view)
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
		if _in_view(view, e.pos, e.radius):
			_draw_enemy_overlay(e)
	# NV-A1 / A2 (docs/41): mũi tên + vòng mục tiêu nhiệm vụ, dấu "!" trên NPC cần gặp
	QuestView.draw(self, world, view, _font)
	for f in _hit_fx:
		if Fx1.draw_hit(_pa, world, f.pos, f.t / HIT_FX_TIME):
			continue
		SpriteLib.draw_env(self, "fx-hit-%d" % mini(2, int(f.t / HIT_FX_TIME * 3.0)), f.pos)
	if not world.boss_unlocked():
		_draw_gate(view)
	_draw_desert_overlay(view)
	R5View.draw_over(self, world, view, _art)
	SK2View.draw(self, world)
	if _art:
		ClassFx.draw_over(self, world)
		ClassFx.draw_casts(self, world, _cast_fx)
	Fx1.draw(_pa, world)
	CL2View.draw(self, world)
	J3View.draw(self, world)
	R6View.draw_over(self, world, view, _art)
	R7View.draw_over(self, world, view, _art)
	R8View.draw_over(self, world, view, _art)
	R9View.draw_over(self, world, view, _art)
	_draw_texts()
	_fx1_glow.glow = _pa.glow
	_fx1_glow.modulate.a = 0.55 if Fx1.soft() else 1.0  # §9.8 giảm chớp sáng
	_fx1_glow.queue_redraw()
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
		# Fix 09/11: trước là 6 vòng draw_arc rời → lộ vành tròn quanh nhân vật. Nay dùng gradient mượt chung.
		var inner: float = 520.0 * vis
		SpriteLib.night_dim(self, view, world.player.pos, inner, inner + 360.0, Color(0.02, 0.03, 0.08), 0.35, 0.6)
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
	var soft := _art and SpriteLib.hd_enabled()
	for p in _patches:
		if view.has_point(p.pos):
			if soft:
				# UI-40c: mảng loang mềm thay cho vòng tròn mép cứng. PF-01 (04/11): 1 ô texture gradient tròn (vẽ gộp được)
				# thay cho 4 vòng tròn trong suốt chồng nhau — mảng loang từng chiếm ~40% thời gian khung hình.
				var pc: Color = Color(1.0, 0.95, 0.8, 0.13) if p.shade > 0.5 else Color(0.0, 0.03, 0.02, 0.19)
				draw_texture_rect(_soft_blob(), Rect2(p.pos - Vector2(p.r, p.r), Vector2(p.r, p.r) * 2.0), false, pc)
			elif _art and bool(world.map.get("desert", false)):
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
	var path_tile := "tile-sand-red" if bool(world.map.get("desert", false)) and SpriteLib.has_env("tile-sand-red") else "tile-dirt"
	if _art and SpriteLib.hd_enabled() and SpriteLib.has_env(path_tile):
		# GN-1 E1 (docs/45): lối mòn mép lượn + viền mờ (2 lớp) thay cho dải chữ nhật cứng.
		if view.grow(80.0).intersects(path):
			SpriteLib.fill_polygon(self, _path_points(v, path_end, 64.0), path_tile, Color(1, 1, 1, 0.22))
			SpriteLib.fill_polygon(self, _path_points(v, path_end, 40.0), path_tile, Color(1, 1, 1, 0.6))
	else:
		var path_pts := PackedVector2Array([path.position, Vector2(path.end.x, path.position.y), path.end, Vector2(path.position.x, path.end.y)])
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
	# M9: lửa trại, Đèn Cực Quang, mặt băng, bão tuyết (region6_view.gd)
	R6View.draw_ground(self, world, view, _art)
	# M10: trời mây, đảo bay, cầu gió, Đá Neo, Trụ Gió (region7_view.gd)
	R7View.draw_ground(self, world, view, _art)
	# M11: Cột Đá Hư Vô, Đèn Tinh Quang (region8_view.gd)
	R8View.draw_ground(self, world, view, _art)
	# M12: màu tầng, Cửa Tầng, bệ Ấn Hệ (region9_view.gd)
	R9View.draw_ground(self, world, view, _art)
	# GN-4 E6: thành hồ nước / hố dung nham / mặt đổ của cồn đất
	TerrainEdge.draw_banks(self, world, view)
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
	# HP-04: hang tối đều + 2 vách đá trên/dưới
	if bool(world.map.get("cave", false)):
		var sz: Vector2 = world.world_size
		draw_rect(Rect2(Vector2.ZERO, sz), Color(0.02, 0.01, 0.04, 0.5))
		for band in [Rect2(0, 0, sz.x, 110), Rect2(0, sz.y - 110, sz.x, 110)]:
			draw_rect(band, Color("#1b1620"))
		draw_line(Vector2(0, 110), Vector2(sz.x, 110), Color("#3b3242"), 4.0)
		draw_line(Vector2(0, sz.y - 110), Vector2(sz.x, sz.y - 110), Color("#3b3242"), 4.0)


## GN-1 E3 (docs/45): quầng sáng cộng của đuốc / đèn lồng / lửa trại — vũng sáng ấm trên nền quanh chân + quầng ở đầu lửa,
## nhấp nháy nhẹ (lệch pha theo vị trí). Chỉ khi bật "Bóng đổ và ánh sáng nền" + hình HD.
var _lamp_view := Rect2()


func _draw_lamp_glow() -> void:
	if world == null or not _depth_on() or world.travel_timer > 0.0:
		return
	var lights: Array = []
	var view := _lamp_view.grow(200.0)
	var near: Array = []
	for d in _camp:
		if view.has_point(d.pos):
			near.append(d)
	var c: Vector2 = world.safe_pos
	if _hd_safe(Maps.safe_theme(world.map)):
		for pr in Maps.safe_props(world.map):
			if view.has_point(c + pr[0]):
				near.append({"pos": c + pr[0], "id": pr[1], "scale": float(pr[2]), "flip": false})
	CampDecor.lights_of(near, lights)
	var blob := _soft_blob()
	for l in lights:
		var at: Vector2 = l[0]
		var col: Color = l[1]
		var k: float = l[2]
		var feet: Vector2 = l[3]
		var fl := 0.85 + 0.1 * sin(world.time * 7.3 + at.x * 0.05) + 0.05 * sin(world.time * 13.1 + at.y * 0.07)
		var pool := Vector2(250.0, 120.0) * k
		_lamp_glow.draw_texture_rect(blob, Rect2(feet - pool * 0.5 + Vector2(0, -6), pool), false, Color(col, 0.2 * fl))
		var halo := 96.0 * k
		_lamp_glow.draw_texture_rect(blob, Rect2(at - Vector2(halo, halo) * 0.5, Vector2(halo, halo)), false, Color(col, 0.34 * fl))


## GN-3 E1: elip mép lượn (bán trục rx, ry) — cùng hình mỗi khung.
func _ellipse_blob(c: Vector2, rx: float, ry: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in 40:
		var a := TAU * i / 40.0
		var k := 1.0 + 0.08 * (0.6 * sin(3.0 * a + c.x * 0.01) + 0.4 * sin(5.0 * a + c.y * 0.01))
		pts.append(c + Vector2(cos(a) * rx, sin(a) * ry) * k)
	return pts


## GN-1 E1: đa giác lối mòn từ v tới x = x_end, nửa bề rộng hw dao động ±18%, tâm lượn ±10 px (cùng hình mỗi khung).
func _path_points(v: Vector2, x_end: float, hw: float) -> PackedVector2Array:
	var top := PackedVector2Array()
	var bot := PackedVector2Array()
	var n := maxi(2, ceili((x_end - v.x) / 40.0))
	for i in n + 1:
		var x := lerpf(v.x, x_end, float(i) / n)
		var cy := v.y + 10.0 * sin(x * 0.0041 + 0.7) + 4.0 * sin(x * 0.013)
		var w := hw * (1.0 + 0.18 * sin(x * 0.0097 + 1.9))
		top.append(Vector2(x, cy - w * (1.0 + 0.06 * sin(x * 0.031))))
		bot.append(Vector2(x, cy + w * (1.0 + 0.06 * sin(x * 0.027 + 2.0))))
	bot.reverse()
	top.append_array(bot)
	return top


## PF-01: đốm tròn mờ dần ra mép (alpha 1 ở tâm → 0 ở mép), dùng chung cho mọi mảng loang.
static var _blob_tex: Texture2D


## VS-1 (docs/44): bóng đổ + ánh sáng nền (chỉ khi dùng hình HD; tắt được ở Cài đặt → Hiển thị).
func _depth_on() -> bool:
	return _art and SpriteLib.hd_enabled() and bool(Settings.values.get("depth_fx", true))


## Hướng sáng chung: nắng từ trên-trái → bóng đổ về dưới-phải.
const SHADOW_DIR := Vector2(0.93, 0.36)
## B3: lớp hạ tông nền (tối + bớt rực) để nhân vật / quái / cây nổi khỏi nền.
const GROUND_DIM := Color(0.08, 0.09, 0.13, 0.16)
## GN-1 E5 (docs/45): tông nền theo vùng — vùng 1 nâu-xám ấm, đậm hơn (bớt xanh rực, nhân vật / quái / cảnh nổi lên).
## GN-3: vùng 2–9 — mỗi vùng tông riêng, nhẹ hơn vùng 1 (nền sáng như cát / tuyết / cẩm thạch hạ chói, nền tối giữ màu).
const REGION_DIM := {1: Color(0.13, 0.1, 0.07, 0.22), 2: Color(0.12, 0.1, 0.06, 0.18), 3: Color(0.14, 0.08, 0.04, 0.16),
	4: Color(0.04, 0.08, 0.07, 0.16), 5: Color(0.09, 0.04, 0.04, 0.14), 6: Color(0.1, 0.13, 0.2, 0.2),
	7: Color(0.08, 0.1, 0.14, 0.14), 8: Color(0.06, 0.04, 0.1, 0.12), 9: Color(0.13, 0.11, 0.08, 0.18)}


## B2 + B3: mảng nắng ấm / bóng râm lạnh cỡ lớn rồi phủ lớp hạ tông nền. Vẽ sau nền + khu an toàn + đấu trường,
## trước bóng đổ, cổng, vết cảnh báo và mọi vật thể.
func _draw_depth_ground(_view: Rect2) -> void:
	if _light_tex != null:
		draw_texture_rect(_light_tex, _light_rect, false)


## Độ đậm của hình mờ `_soft_blob` theo khoảng cách chuẩn hoá d (0 = tâm, 1 = mép) — cùng bảng dừng của gradient.
static func blob_falloff(d: float) -> float:
	if d >= 1.0:
		return 0.0
	if d < 0.4:
		return lerpf(1.0, 0.85, d / 0.4)
	if d < 0.7:
		return lerpf(0.85, 0.45, (d - 0.4) / 0.3)
	return lerpf(0.45, 0.0, (d - 0.7) / 0.3)


## Phủ màu c (độ đục a) lên điểm ảnh d theo kiểu "over" (không nhân sẵn alpha) — phủ lần lượt cho cùng kết quả như vẽ lần lượt.
static func over(d: Color, c: Color, a: float) -> Color:
	var oa := a + d.a * (1.0 - a)
	if oa <= 0.0001:
		return Color(0, 0, 0, 0)
	var k := d.a * (1.0 - a)
	return Color((c.r * a + d.r * k) / oa, (c.g * a + d.g * k) / oa, (c.b * a + d.b * k) / oa, oa)


## B2 + B3: nướng `_light` (elip r × 0,8r, màu nắng / râm) rồi phủ GROUND_DIM lên toàn map — 1 lần mỗi map.
func _bake_light(size: Vector2) -> void:
	var dim: Color = GROUND_DIM if bool(world.map.get("cave", false)) else REGION_DIM.get(int(world.map.get("region", 1)), GROUND_DIM)
	var w := ceili(size.x / LIGHT_CELL) + 1
	var h := ceili(size.y / LIGHT_CELL) + 1
	var buf := PackedColorArray()
	buf.resize(w * h)
	buf.fill(Color(0, 0, 0, 0))
	for lp in _light:
		var c: Vector2 = lp.pos
		var rx: float = lp.r
		var ry: float = lp.r * 0.8
		var col := Color(1.0, 0.93, 0.7, 0.13) if lp.sun else Color(0.02, 0.05, 0.1, 0.26)
		for y in range(maxi(0, floori((c.y - ry) / LIGHT_CELL)), mini(h, ceili((c.y + ry) / LIGHT_CELL) + 1)):
			var dy := (y * LIGHT_CELL - c.y) / ry
			for x in range(maxi(0, floori((c.x - rx) / LIGHT_CELL)), mini(w, ceili((c.x + rx) / LIGHT_CELL) + 1)):
				var dx := (x * LIGHT_CELL - c.x) / rx
				var f := blob_falloff(sqrt(dx * dx + dy * dy))
				if f > 0.0:
					buf[y * w + x] = over(buf[y * w + x], col, col.a * f)
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	for y in h:
		for x in w:
			img.set_pixel(x, y, over(buf[y * w + x], dim, dim.a))
	_light_tex = CanvasTexture.new()
	_light_tex.diffuse_texture = ImageTexture.create_from_image(img)
	_light_tex.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	# điểm ảnh i nằm giữa ô → tâm ở i·LIGHT_CELL
	_light_rect = Rect2(-Vector2.ONE * LIGHT_CELL * 0.5, Vector2(w, h) * LIGHT_CELL)


## B1: bóng đổ — vệt tối sát chân (đọng bóng) + bóng kéo dài theo SHADOW_DIR, dài theo chiều cao vật.
## Cây đứng sát nhau chồng bóng → nền rừng tối hơn, tự có "bóng râm dưới tán".
func _draw_shadows(view: Rect2) -> void:
	var blob := _soft_blob()
	var ang := SHADOW_DIR.angle()
	for t in _trees:
		if view.has_point(t.pos):
			var r: float = t.r
			var tall := r >= 20.0 and str(world.map.get("decor", "forest")) in ["forest", ""]
			_shadow_at(blob, ang, t.pos + Vector2(0, r * 0.6), r * 1.7, r * (3.4 if tall else 1.4))
	var c: Vector2 = world.safe_pos
	for b in _safe_buildings():
		var at: Vector2 = c + b[0] + Vector2(0, 16)
		if view.has_point(at):
			var ext := SpriteLib.env_extent(str(b[1]))
			if ext == Vector2.ZERO:
				ext = Vector2(90, 80)
			_shadow_at(blob, ang, at, ext.x * 0.9, ext.y * 0.8)
	for list in [_desert, _camp]:
		for d in list:
			if view.has_point(d.pos):
				var ext := SpriteLib.env_extent(str(d.id), float(d.scale))
				if ext != Vector2.ZERO:
					_shadow_at(blob, ang, d.pos, ext.x * 0.8, ext.y)
	for e in world.enemies:
		if not e.dead and _in_view(view, e.pos, e.radius):
			_shadow_at(blob, ang, _feet(e.pos, e.radius), e.radius * 2.0, e.radius * 2.6, 0.8)
	for a in world.allies:
		if _in_view(view, a.pos, a.radius):
			_shadow_at(blob, ang, _feet(a.pos, a.radius), a.radius * 2.0, a.radius * 2.6, 0.7)
	for npc in world.npcs():
		if view.has_point(npc.pos):
			_shadow_at(blob, ang, npc.pos + Vector2(0, 2), 30.0, 52.0, 0.8)
	var p = world.player
	if p.dead_timer <= 0.0:
		_shadow_at(blob, ang, _feet(p.pos, GameWorld.PLAYER_RADIUS), 32.0, 56.0, 0.85)


## Một bóng: đế tròn dẹt (rộng w) + vệt kéo dài h·1,05 theo hướng sáng. a = độ đậm (vật nhỏ / động nhạt hơn).
func _shadow_at(blob: Texture2D, ang: float, feet: Vector2, w: float, h: float, a := 1.0) -> void:
	draw_texture_rect(blob, Rect2(feet - Vector2(w * 0.55, w * 0.2), Vector2(w * 1.1, w * 0.4)), false, Color(0, 0.02, 0.04, 0.30 * a))
	# GN-1 E4 / C3 (docs/45): lõi tối hẹp sát chân (che khuất môi trường) — vật "đứng trên đất", không lơ lửng.
	draw_texture_rect(blob, Rect2(feet - Vector2(w * 0.32, w * 0.09), Vector2(w * 0.64, w * 0.18)), false, Color(0, 0.01, 0.02, 0.34 * a))
	var ln := h * 1.05
	draw_set_transform(feet + SHADOW_DIR * ln * 0.4, ang, Vector2.ONE)
	draw_texture_rect(blob, Rect2(-Vector2(ln * 0.5, w * 0.32), Vector2(ln, w * 0.64)), false, Color(0, 0.02, 0.05, 0.36 * a))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


static func _soft_blob() -> Texture2D:
	if _blob_tex == null:
		var g := Gradient.new()
		g.offsets = PackedFloat32Array([0.0, 0.4, 0.7, 1.0])
		g.colors = PackedColorArray([Color(1, 1, 1, 1), Color(1, 1, 1, 0.85), Color(1, 1, 1, 0.45), Color(1, 1, 1, 0)])
		var t := GradientTexture2D.new()
		t.gradient = g
		t.fill = GradientTexture2D.FILL_RADIAL
		t.fill_from = Vector2(0.5, 0.5)
		t.fill_to = Vector2(1.0, 0.5)
		t.width = 64
		t.height = 64
		_blob_tex = t
	return _blob_tex


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
	var theme := Maps.safe_theme(world.map)
	if _art and _hd_safe(theme):
		_draw_village_yard(c, r, theme)
		_label(str(world.map.safe.name), c + Vector2(0, -r - 64.0), Color("#f3e3c3"), 16)
		return
	if not (_art and SpriteLib.fill_polygon(self, _circle_points(c, r), tile)):
		draw_circle(c, r, Color("#4a3b2a"))
	draw_arc(c, r, 0.0, TAU, 64, Color("#9aa0a6") if kind == "town" else Color("#7a5f3e"), 7.0 if kind == "town" else 5.0, true)
	_label(str(world.map.safe.name), c + Vector2(0, -r - 12.0), Color("#f3e3c3"), 16)


## UI-40c: khu an toàn vẽ kiểu HD khi có cọc rào HD của chủ đề (tắt HD → vòng tròn + nhà pixel như cũ).
func _hd_safe(theme: Dictionary) -> bool:
	return not theme.is_empty() and SpriteLib.has_env(str(theme.post)) and SpriteLib.hd_enabled()


## Đồ trang trí nằm phẳng trên đất (vẽ cùng lớp nền, không sắp theo chiều sâu).
const FLAT_PROPS := ["garden"]


## UI-40b / UI-40c (docs/35 §9–10): sân khu an toàn HD — mép lượn tự nhiên (không còn vòng tròn cứng), viền mờ hoà
## vào nền vùng, sân lát giữa, lối ra ruộng (làng). Ranh giới vùng an toàn là hàng rào cọc (_draw_sorted).
func _draw_village_yard(c: Vector2, r: float, theme: Dictionary) -> void:
	var tile: String = theme.yard if SpriteLib.has_env(str(theme.yard)) else "tile-village"
	if world.map.safe.kind == "village":
		var lane := PackedVector2Array([c + Vector2(-22, 40), c + Vector2(22, 40), c + Vector2(30, 250), c + Vector2(-14, 250)])
		SpriteLib.fill_polygon(self, lane, "tile-dirt", Color(1, 1, 1, 0.75))
	SpriteLib.fill_polygon(self, _blob_points(c, r + 34.0), tile, Color(1, 1, 1, 0.2))
	SpriteLib.fill_polygon(self, _blob_points(c, r + 14.0), tile)
	var plaza: String = str(theme.get("plaza", ""))
	# GN-3 E1: trại vùng 1–2 chưa có sân lát → sân đá lát nhỏ giữa trại (như ảnh tham khảo)
	if plaza == "" and world.map.safe.kind == "camp" and int(world.map.get("region", 1)) in [1, 2]:
		plaza = "tile-plaza"
	if plaza != "" and SpriteLib.has_env(plaza):
		var pr_r := 66.0 if world.map.safe.kind == "village" else (r * 0.72 if world.map.safe.kind == "town" else 58.0)
		SpriteLib.fill_polygon(self, _blob_points(c, pr_r, 0.04), plaza, Color(1, 1, 1, 0.92))
	for pr in Maps.safe_props(world.map):
		if pr[1] in FLAT_PROPS and SpriteLib.has_env(pr[1]):
			SpriteLib.draw_env(self, pr[1], c + pr[0], Color.WHITE, float(pr[2]))


## Vòng kín mép lượn (bán kính dao động ±amp) — cùng hình mỗi khung.
func _blob_points(c: Vector2, r: float, amp := 0.07) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in 72:
		var a := TAU * i / 72.0
		var k := 1.0 + amp * (0.6 * sin(3.0 * a + 1.3) + 0.4 * sin(7.0 * a + 0.4))
		pts.append(c + Vector2.from_angle(a) * r * k)
	return pts


## UI-40b / UI-40c: cọc rào quanh khu an toàn (bán kính r + 2, ~22 px một cọc), chừa cổng đông (đường tới hang),
## lối tây (cổng về map trước) và lối nam (ra ruộng, chỉ làng).
func _village_fence() -> Array:
	var c: Vector2 = world.safe_pos
	var rr: float = world.safe_r + 2.0
	var village: bool = world.map.safe.kind == "village"
	var out: Array = []
	var n := maxi(36, roundi(TAU * rr / 22.0))
	for i in n:
		var p := c + Vector2.from_angle(TAU * i / n) * rr
		var gap := p.x > c.x and absf(p.y - c.y) < 56.0
		if village:
			gap = gap or (p.y > c.y and absf(p.x - c.x - 8.0) < 36.0)
		else:
			gap = gap or (p.x < c.x and absf(p.y - c.y) < 40.0)
		out.append({"pos": p, "gap": gap})
	return out


func _draw_fence_post(posts: Array, i: int, theme: Dictionary) -> void:
	var a: Dictionary = posts[i]
	var b: Dictionary = posts[(i + 1) % posts.size()]
	var rail: Color = theme.get("rail", Color("#9a6a40"))
	var rails := int(theme.get("rails", 2))
	if not a.gap and not b.gap:
		for j in rails:
			var h := 9.0 + j * (18.0 / maxf(1.0, rails - 1.0)) * (1.0 if rails <= 2 else 0.6)
			draw_line(a.pos - Vector2(0, h), b.pos - Vector2(0, h), Color(rail.darkened(0.65), rail.a), 4.0, true)
			draw_line(a.pos - Vector2(0, h + 0.5), b.pos - Vector2(0, h + 0.5), rail, 2.0, true)
	if not a.gap:
		SpriteLib.draw_env(self, str(theme.post), a.pos)


## Vị trí nhà trong vùng an toàn theo loại.
## MP-09: bố cục chuyển sang Maps.safe_buildings() để cổng dịch chuyển tránh được nhà.
func _safe_buildings() -> Array:
	return Maps.safe_buildings(world.map)


func _draw_village() -> void:
	var c: Vector2 = world.safe_pos
	for b in _safe_buildings():
		var t: Vector2 = c + b[0]
		SpriteLib.poly(self, PackedVector2Array([t + Vector2(0, -26), t + Vector2(-24, 16), t + Vector2(24, 16)]), Color("#b08d57"))
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
	var arena_tile := "tile-sand-red" if bool(world.map.get("desert", false)) else ("tile-basalt" if str(world.map.get("decor", "")) == "volcano" else ("tile-ice" if str(world.map.get("decor", "")) == "tundra" else "tile-void"))
	# GN-3 E1: viền mờ ngoài sân đấu trường (chuyển nền mềm, không còn mép tròn cứng) — chỉ hình HD + chiều sâu
	if _art and _depth_on():
		SpriteLib.fill_polygon(self, _blob_points(c, r + 46.0), arena_tile, Color(1, 1, 1, 0.16))
		SpriteLib.fill_polygon(self, _blob_points(c, r + 20.0), arena_tile, Color(1, 1, 1, 0.3))
	if not (_art and SpriteLib.fill_polygon(self, _circle_points(c, r, 64), arena_tile, Color(1, 1, 1, 0.85))):
		draw_circle(c, r, Color("#251d33"))
	var locked: bool = world.boss() != null
	draw_arc(c, r, 0.0, TAU, 96, Color(1.0, 0.33, 0.44, 0.7) if locked else Color(0.63, 0.51, 0.86, 0.35), 5.0 if locked else 3.0, true)
	var name: String = world.map.arena.name
	var title := ("%s (đã chinh phục)" % name) if world.is_boss_defeated(world.arena_boss()) else name
	# Rà soát 01/11: đang đánh boss thì thanh máu boss (HUD) đã ghi tên — tên đấu trường ở mép trên trùng chỗ thanh máu, ẩn đi.
	if not locked:
		_label(title, c + Vector2(0, -r - 12.0), Color("#d8c8ff"), 16)


func _draw_trees(view: Rect2) -> void:
	for t in _trees:
		if not view.has_point(t.pos):
			continue
		draw_circle(t.pos + Vector2(6, 8), t.r, Color(0, 0, 0, 0.25))
		draw_circle(t.pos, t.r, Color("#244a32") if t.shade > 0.5 else Color("#1e3e2b"))
		draw_circle(t.pos - Vector2.ONE * t.r * 0.3, t.r * 0.5, Color(0.47, 0.67, 0.43, 0.12))


# ---------------------------------------------------------------- sắp xếp theo chiều sâu (AR-31, AR-32)
## PF-02: decor của map đọc một lần mỗi khung (trước đây mỗi cây đọc lại tới 7 lần).
var _decor_now := "forest"


func _draw_sorted(view: Rect2) -> void:
	_fade_focus = _occlusion_focus()
	_decor_now = str(world.map.get("decor", "forest"))
	var items: Array = []
	for t in _trees:
		if view.has_point(t.pos):
			items.append([t.pos.y + t.r * 0.6, _draw_tree_sprite.bind(t)])
	var c: Vector2 = world.safe_pos
	var theme := Maps.safe_theme(world.map)
	var hd_safe := _hd_safe(theme)
	for b in _safe_buildings():
		var at: Vector2 = c + b[0] + Vector2(0, 16)
		var id: String = b[1] if hd_safe and SpriteLib.has_env(b[1]) else (str(b[2]) if b.size() > 2 else "hut")
		if not SpriteLib.has_env(id):
			id = "hut"
		items.append([at.y, _draw_env_at.bind(id, at)])
	if world.map.safe.kind == "village":
		items.append([c.y + 16.0, _draw_stele.bind(c + Vector2(0, 16))])
	# UI-40b / UI-40c: đồ trang trí + hàng rào khu an toàn (chỉ khi có bản HD)
	if hd_safe:
		for pr in Maps.safe_props(world.map):
			if not (pr[1] in FLAT_PROPS) and SpriteLib.has_env(pr[1]) and view.has_point(c + pr[0]):
				items.append([c.y + pr[0].y, _draw_env_scaled.bind(pr[1], c + pr[0], float(pr[2]), false)])
		var posts := _village_fence()
		for i in posts.size():
			# PF-02: cọc (và thanh nối sang cọc kế) trong khung nhìn
			if view.has_point(posts[i].pos) or view.has_point(posts[(i + 1) % posts.size()].pos):
				items.append([posts[i].pos.y, _draw_fence_post.bind(posts, i, theme)])
	# GN-1 E2: cảnh trại vùng 1
	for d in _camp:
		if view.has_point(d.pos):
			items.append([d.pos.y, _draw_env_scaled.bind(d.id, d.pos, d.scale, d.flip)])
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

	# PF-01 (04/11): chỉ vẽ thứ trong khung nhìn — map ×3 có hàng trăm quái, trước đây vẽ cả con ở xa (giật khi đi).
	for h in world.herbs:
		if h.respawn <= 0.0 and view.has_point(h.pos):
			items.append([h.pos.y, _draw_env_at.bind("herb", h.pos)])
	for ch in world.chests:
		if world.chest_visible(ch) and view.has_point(ch.pos):
			items.append([ch.pos.y, _draw_chest.bind(ch)])
	for a in world.allies:
		if _in_view(view, a.pos, a.radius):
			items.append([a.pos.y, _draw_ally_sprite.bind(a)])
	for e in world.enemies:
		if _in_view(view, e.pos, e.radius):
			items.append([e.pos.y, _draw_enemy_sprite.bind(e)])
	for k in _corpses:
		if view.has_point(k.pos):
			items.append([k.pos.y - 1.0, _draw_corpse.bind(k)])
	# C1-11, M4.3: NPC của map (dữ liệu maps.gd), bấm E khi đứng gần
	for npc in world.npcs():
		if view.has_point(npc.pos):
			items.append([npc.pos.y, _draw_npc.bind(npc.sprite, npc.pos, npc.name)])
	items.append([world.player.pos.y, _draw_player_sprite])
	# PF-02: sắp theo khoá số (sắp xếp gốc của PackedFloat64Array) thay cho sort_custom + lambda (~1 ms / 200 vật).
	# khoá = y làm tròn 1/16 px × 65536 + chỉ số → cùng y giữ thứ tự thêm vào.
	var keys := PackedFloat64Array()
	keys.resize(items.size())
	for i in items.size():
		keys[i] = floorf(float(items[i][0]) * 16.0) * 65536.0 + float(i)
	keys.sort()
	for kf in keys:
		items[int(fposmod(kf, 65536.0))][1].call()


## PF-01: điểm có nằm trong khung nhìn (nới theo bán kính — boss / quái to vẽ tràn ra ngoài bán kính va chạm).
func _in_view(view: Rect2, pos: Vector2, radius: float) -> bool:
	return view.grow(radius * 3.0 + 40.0).has_point(pos)


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
	ElementIcon.draw(self, pl.pos + Vector2(0, -84), str(pl.element), 13.0)


func _feet(pos: Vector2, r: float) -> Vector2:
	return pos + Vector2(0, r * 0.6)


## Làm mờ vật che (như Diablo): điểm cần thấy = thân người chơi, boss, điểm rơi đòn của tinh anh / boss đang lấy đà,
## thân mọi quái đang lấy đà trong 300 px (động tác lấy đà là tín hiệu chính ở kiểu tự nhiên).
func _occlusion_focus() -> Array:
	var out: Array = [world.player.pos + Vector2(0, -18)]
	for e in world.enemies:
		if e.dead:
			continue
		if str(e.role) == "boss":
			out.append(e.pos + Vector2(0, -e.radius * 0.5))
		if e.state == "windup" and (e.elite or str(e.role) == "boss"):
			out.append(e.target)
		if e.state == "windup" and e.pos.distance_to(world.player.pos) < 300.0:
			out.append(e.pos + Vector2(0, -e.radius * 0.5))  # quái lấy đà gần (mọi cấp): phải thấy động tác
	return out


## Độ trong của cây: tán che một điểm cần thấy (điểm nằm SAU gốc cây và trong khung hình cây) → mờ dần còn 40%,
## hết che thì hiện lại dần (không bật / tắt đột ngột).
func _tree_fade(t: Dictionary, id: String, base: Vector2, size_mul: float) -> float:
	var target := 1.0
	# PF-02: chỉ tính khung hình cây khi có điểm cần thấy ở gần phía sau gốc (đa số cây không che gì)
	var near := false
	for f in _fade_focus:
		if f.y < base.y - 4.0 and base.y - f.y < 420.0 and absf(f.x - base.x) < 240.0:
			near = true
			break
	var cur0: float = t.get("fade", 1.0)
	if not near and cur0 >= 1.0:
		return 1.0
	var e: Dictionary = SpriteLib.data().get("env", {}).get(id, {}) if near else {}
	if not e.is_empty():
		var tex := SpriteLib.texture(e.path)
		if tex != null:
			var k := SpriteLib.scale() * size_mul / SpriteLib.px_of(e)
			var box := Rect2(base - Vector2(e.origin[0], e.origin[1]) * k, tex.get_size() * k).grow(-6.0)
			for f in _fade_focus:
				if f.y < base.y - 4.0 and box.has_point(f):
					target = 0.4
					break
	var cur: float = t.get("fade", 1.0)
	cur = move_toward(cur, target, 0.08)
	t["fade"] = cur
	return cur


func _draw_tree_sprite(t: Dictionary) -> void:
	var base: Vector2 = t.pos + Vector2(0, t.r * 0.6)
	# M7: đầm lầy — cây chết, lau sậy, lá súng (trên nước), bụi.
	if _decor_now == "swamp":
		var wet := Ch4.in_water(world, t.pos)
		var sid: String = ("lily" if wet else ["dead-tree-0", "reeds-0", "dead-tree-1", "reeds-1"][t.variant])
		if not SpriteLib.has_env(sid):
			sid = "bush"
		SpriteLib.draw_env(self, sid, base, Color(1, 1, 1, _tree_fade(t, sid, base, 1.0 if t.r < 28.0 else 1.3)), 1.0 if t.r < 28.0 else 1.3, t.shade > 0.5)
		return
	# M8: núi lửa — đá dung nham, cây cháy, miệng phun.
	if _decor_now == "volcano":
		var did: String = R5View.decor_id(t.variant)
		SpriteLib.draw_env(self, did, base, Color(1, 1, 1, _tree_fade(t, did, base, 1.0 if t.r < 28.0 else 1.4)), 1.0 if t.r < 28.0 else 1.4, t.shade > 0.5)
		return
	# M10: đảo bay — rừng treo, mây / cột Thiên Cung.
	if _decor_now in ["sky", "sky_ruins"]:
		var did: String = R7View.decor_id(t.variant, _decor_now == "sky_ruins")
		SpriteLib.draw_env(self, did, base, Color(1, 1, 1, _tree_fade(t, did, base, 1.0 if t.r < 28.0 else 1.4)), 1.0 if t.r < 28.0 else 1.4, t.shade > 0.5)
		return
	# M12: Thiên Thê — cột ngọc, mây vàng.
	if _decor_now == "heaven":
		var did: String = R9View.decor_id(t.variant)
		SpriteLib.draw_env(self, did, base, Color(1, 1, 1, _tree_fade(t, did, base, 1.0 if t.r < 28.0 else 1.3)), 1.0 if t.r < 28.0 else 1.3, t.shade > 0.5)
		return
	# M11: vực Hư Vô — cây chết, đá vụn.
	if _decor_now == "void":
		var vid: String = R8View.decor_id(t.variant)
		SpriteLib.draw_env(self, vid, base, Color(0.7, 0.6, 0.85, _tree_fade(t, vid, base, 1.0 if t.r < 28.0 else 1.3)), 1.0 if t.r < 28.0 else 1.3, t.shade > 0.5)
		return
	# M9: băng nguyên — thông phủ tuyết, đá băng, gò tuyết.
	if _decor_now == "tundra":
		var did: String = R6View.decor_id(t.variant)
		SpriteLib.draw_env(self, did, base, Color(1, 1, 1, _tree_fade(t, did, base, 1.0 if t.r < 28.0 else 1.4)), 1.0 if t.r < 28.0 else 1.4, t.shade > 0.5)
		return
	# M4.2: thảo nguyên — đá, cỏ cao, bụi thay cho cây rừng.
	if _decor_now == "plains":
		var pid: String = ["rock-0", "tall-grass", "rock-1", "bush"][t.variant]
		if not SpriteLib.has_env(pid):
			pid = "bush"
		SpriteLib.draw_env(self, pid, base, Color(1, 1, 1, _tree_fade(t, pid, base, 1.0 if t.r < 28.0 else 1.4)), 1.0 if t.r < 28.0 else 1.4, t.shade > 0.5)
		return
	if t.r < 20.0:
		SpriteLib.draw_env(self, "bush", base, Color(1, 1, 1, _tree_fade(t, "bush", base, 1.0)), 1.0, t.shade > 0.5)
		return
	var id: String = ["tree-0", "tree-1", "tree-2", "tree-pine"][t.variant]
	var tint := Color(0.85, 0.9, 0.85) if t.shade > 0.5 else Color.WHITE
	tint.a = _tree_fade(t, id, base, 1.0 if t.r < 32.0 else 1.5)
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
	# M9: Bản Ngã Bóng Tối (bóng của người chơi) và Gương Băng
	if R6View.draw_enemy(self, world, e):
		return
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
	var pose: Array = [Vector2.ONE, 0.0, Vector2.ZERO]
	if e.state == "windup":
		pose = Fx1.windup_pose(world, e, 1.0 - maxf(0.0, e.timer) / e.windup_total)  # §9.13: co người, ngả, run lên
	SpriteLib.draw_frame(self, sid, anim, frame, _feet(e.pos, e.radius) + pose[2], left, mod, _enemy_size(e), pose[0], pose[1])


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
	# LH2: linh thú Triệu Hồi Sư — vòng chân theo màu linh thú, hơi trong suốt khi sắp hết giờ
	if a.kind == "summon":
		mod = Color(1, 1, 1, 0.5 if a.ttl > 0.0 and a.ttl < 1.5 else 0.92)
		_ground_ring(_feet(a.pos, a.radius), a.radius + 3.0, a.color)
	else:
		_ground_ring(_feet(a.pos, a.radius), a.radius + 3.0, Color("#b36bff") if shadow else Color("#5bd16a"))
	# SN16: đang hiện hình → mọc lên từ vòng trận (cao dần, sáng loá rồi dịu), đứng yên
	var squash := Vector2.ONE
	if a.spawn_t > 0.0:
		var k := clampf(1.0 - a.spawn_t / GameWorld.ALLY_SPAWN, 0.0, 1.0)
		var e := 1.0 - pow(1.0 - k, 3.0)
		squash = Vector2(1.25 - 0.25 * e, maxf(0.05, e))
		var glow := 1.0 + 0.9 * (1.0 - k)
		mod = Color(mod.r * glow, mod.g * glow, mod.b * glow, mod.a * minf(1.0, 0.25 + k * 1.2))
		anim = "idle"
		frame = 0
	SpriteLib.draw_frame(self, a.monster, anim, frame, _feet(a.pos, a.radius), _facing_left(key, a.pos, false), mod,
		clampf(a.radius / 16.0, 0.75, 1.25), squash)


## Sprite để tính số frame (thân theo ngoại hình; thiếu thì hình mặc định của lớp).
func _hero() -> String:
	var hs := SpriteLib.hero_sprite(world.profile.class_id, world.profile.look)
	if SpriteLib.has_sprite(hs):
		return hs
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
		frame = SpriteLib.frame_progress(hs, anim, 1.0 - clampf(p.swing / _swing_len(p, 0.25 if p.swing_kind == "cast" else 0.16), 0.0, 1.0))
	elif p.hurt > 0.0:
		anim = "hurt"
	else:
		anim = "run" if _moving(-1, p.pos) else "idle"
		frame = SpriteLib.frame_at(hs, anim, _anim_time(-1, anim))
	var left := cos(p.facing) < 0.0
	var alpha := 0.55 if p.dodge_time > 0.0 or p.dash_time > 0.0 else 1.0
	var rank_color := Talents.rank_color(world.talent().rank)
	_ground_ring(_feet(p.pos, GameWorld.PLAYER_RADIUS), GameWorld.PLAYER_RADIUS + 6.0, Color(rank_color, 0.7 * alpha))
	J3View.draw_under(self, world)
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
	# Spec_Notes N8 → EN-1 (docs/43 §6): vũ khí cường hoá +4 trở lên — vòng ấn xoay dưới chân + hạt sáng bốc lên (màu bậc).
	var plus: int = int(world.profile.equipment.get("weapon", {}).get("plus", 0))
	if Items.enhance_tier(plus) > 0 and p.dead_timer <= 0.0:
		_enhance_aura(_feet(p.pos, GameWorld.PLAYER_RADIUS), plus)
	if p.root_timer > 0.0:
		var feet := _feet(p.pos, GameWorld.PLAYER_RADIUS)
		for k in 5:
			var a := TAU * k / 5.0 + 0.3
			draw_line(feet + Vector2.from_angle(a) * 20.0, feet + Vector2(0, -18) + Vector2.from_angle(a) * 6.0, Color("#674a32"), 4.0, true)
	SpriteLib.draw_hero(self, world.profile.class_id, world.profile.look, anim, frame, _feet(p.pos, GameWorld.PLAYER_RADIUS), left, mod)
	# C1-02: tên trên đầu
	if p.dead_timer <= 0.0:
		# SN9-01: tên + dòng nhỏ chức nghiệp hiện tại (màu tím nhạt)
		var pf = world.profile
		# VS-1: khoảng cách giữa các dòng nhân text_k (chữ to ra khi camera zoom ra), mốc là đỉnh đầu (-R - 40).
		var head := p.pos + Vector2(0, -GameWorld.PLAYER_RADIUS - 40.0)
		var tk := ViewScale.text_k
		_label(str(pf.name), head + Vector2(0, -16.0 * tk), Color(1, 1, 1, 0.9), 12, true)
		# NV-C (docs/41): danh hiệu đang đeo (trang trí) trên tên
		if str(pf.title) != "":
			_label("« %s »" % pf.title, head + Vector2(0, -30.0 * tk), Color("#ffd257"), 10, true)
		_label(Classes.title(str(pf.class_id), str(pf.job), str(pf.job2), str(pf.job3)), head + Vector2(0, -4.0 * tk), Color(0.85, 0.77, 1.0, 0.85), 10)
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


## EN-1 (docs/43 §6): hào quang vũ khí cường hoá. Vòng ấn (vạch cung + hình thoi) xoay chậm theo chiều kim đồng hồ,
## số vạch tăng theo bậc; hạt sáng bốc lên từ chân. Bậc 4 (+13): thêm vòng trong xoay ngược + hạt to, dày hơn.
func _enhance_aura(feet: Vector2, plus: int) -> void:
	var tier := Items.enhance_tier(plus)
	var gc := Items.enhance_color(plus)
	var t := world.time
	var r := GameWorld.PLAYER_RADIUS + 16.0
	var pulse := 0.75 + 0.25 * sin(t * 2.5)
	draw_set_transform(feet, 0.0, Vector2(1.0, 0.45))
	draw_circle(Vector2.ZERO, r + 4.0, Color(gc, 0.07 + 0.02 * tier))
	var n := 2 + tier * 2
	for i in n:
		var a0 := t * 0.8 + TAU * i / n
		draw_arc(Vector2.ZERO, r, a0, a0 + TAU / n * 0.6, 10, Color(gc, 0.8 * pulse), 2.5, true)
		var d := Vector2.from_angle(a0 + TAU / n * 0.8) * r
		draw_colored_polygon(PackedVector2Array([d + Vector2(0, -4), d + Vector2(4, 0), d + Vector2(0, 4), d + Vector2(-4, 0)]), Color(gc.lightened(0.3), 0.9 * pulse))
	if tier >= 4:
		for i in 6:
			var a1 := -t * 1.3 + TAU * i / 6.0
			draw_arc(Vector2.ZERO, r - 8.0, a1, a1 + 0.6, 8, Color(gc.lightened(0.25), 0.7), 2.0, true)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var hot := gc.lightened(0.35)
	for k in 3 + tier * 2:
		var life := fmod(t * (0.45 + 0.07 * (k % 4)) + k * 0.618, 1.0)
		var x := sin(k * 2.4 + life * 3.0) * (12.0 + (k % 3) * 5.0)
		var pos := feet + Vector2(x, -life * (38.0 + tier * 6.0))
		draw_circle(pos, (1.2 + 0.35 * tier) * (1.0 - life * 0.6), Color(hot, 0.85 * (1.0 - life)))


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
		if Fx1.draw_trap(_pa, world, t):
			continue
		if _art and SpriteLib.has_env("fx-trap"):
			SpriteLib.draw_env(self, "fx-trap", t.pos)
		else:
			draw_circle(t.pos, 10.0, Color("#9ba8bc"))
		draw_arc(t.pos, GameWorld.TRAP_TRIGGER, 0.0, TAU, 24, Color(1, 0.8, 0.3, 0.25), 1.5, true)
	for z in world.rains:
		if Fx1.draw_rain(_pa, world, z):
			continue
		var pulse := 0.5 + 0.5 * sin(world.time * 12.0)
		draw_circle(z.pos, z.radius, Color(1, 0.33, 0.44, 0.10 + 0.05 * pulse))
		draw_arc(z.pos, z.radius, 0.0, TAU, 40, Color(1, 0.5, 0.5, 0.6), 2.0, true)
		for i in 6:
			var ang := float(i) * 1.7 + world.time * 3.0
			var at: Vector2 = z.pos + Vector2(cos(ang), sin(ang * 1.3)) * z.radius * 0.6
			var fall := fposmod(world.time * 4.0 + i * 0.37, 1.0)
			var from := at + Vector2(-12, -60) * (1.0 - fall)
			if _art and ClassFx.draw_rain_drop(self, z, at, fall):
				continue
			if _art:
				SpriteLib.draw_env(self, "fx-arrow", from, Color(1, 1, 1, 0.9), 1.0, false, Vector2(12, 60).angle())
			else:
				draw_line(from, from + Vector2(4, 20), Color.WHITE, 2.0)
	# SN-04: Thiên Thạch — vòng báo hiệu co dần, thiên thạch rơi chéo xuống
	for m in world.meteors:
		if Fx1.draw_meteor(_pa, world, m):
			continue
		if _art and ClassFx.draw_source_meteor(self, m):
			continue
		var k: float = 1.0 - m.timer / GameWorld.METEOR_DELAY
		draw_circle(m.pos, m.radius, Color(1, 0.45, 0.15, 0.08 + 0.12 * k))
		draw_arc(m.pos, m.radius, 0.0, TAU, 40, Color(1, 0.6, 0.25, 0.8), 2.0, true)
		draw_arc(m.pos, m.radius * k, 0.0, TAU, 40, Color(1, 0.8, 0.4, 0.9), 2.0, true)
		var rock: Vector2 = m.pos + Vector2(-140, -260) * (1.0 - k)
		if _art and ClassFx.draw_meteor_rock(self, rock):
			continue
		draw_line(rock, rock + Vector2(-50, -90), Color(1, 0.55, 0.2, 0.5), 8.0, true)
		draw_circle(rock, 16.0, Color(1, 0.5, 0.15, 0.45))
		draw_circle(rock, 10.0, Color("#6a4a3a"))
		draw_circle(rock + Vector2(-3, -3), 4.0, Color("#ffe08a"))
	# SN-04: Lôi Xích — tia sét gấp khúc
	for b in world.bolts:
		if Fx1.draw_bolt(_pa, world, b):
			continue
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
		if _art:
			ClassFx.draw_bolt_accents(self, b)
	for s in world.shots:
		if Fx1.draw_shot(_pa, s):
			continue
		# LH2: Linh Cầu / Linh Tiễn (linh hồn ngọc lam), Hoả Điểu (chim lửa)
		if s.kind == "spirit":
			draw_circle(s.pos - s.vel.normalized() * 9.0, 7.0, Color(0.5, 0.85, 0.95, 0.3))
			draw_circle(s.pos, 8.0, Color(0.55, 0.9, 1.0, 0.45))
			draw_circle(s.pos, 5.0, Color("#c4f4ff"))
			continue
		if s.kind == "firebird":
			var dv: Vector2 = s.vel.normalized()
			SpriteLib.poly(self, PackedVector2Array([s.pos + dv * 14.0, s.pos - dv * 8.0 + dv.orthogonal() * 14.0, s.pos - dv * 2.0,
				s.pos - dv * 8.0 - dv.orthogonal() * 14.0]), Color(1, 0.55, 0.15, 0.85))
			draw_circle(s.pos, 6.0, Color("#ffe08a"))
			draw_line(s.pos - dv * 4.0, s.pos - dv * 26.0, Color(1, 0.45, 0.1, 0.5), 6.0, true)
		if _art and ClassFx.draw_shot(self, s):
			continue
		if s.kind == "fireball":
			draw_circle(s.pos - s.vel.normalized() * 10.0, 9.0, Color(1, 0.45, 0.1, 0.35))
			draw_circle(s.pos, 11.0, Color(1, 0.5, 0.15, 0.5))
			draw_circle(s.pos, 7.0, Color("#ff9a3c"))
			draw_circle(s.pos + Vector2(1.5, -1.5), 3.5, Color("#ffe08a"))
			continue
		var id: String = {"arrow": "fx-arrow", "wave": "fx-wave", "pierce": "fx-pierce"}.get(s.kind, "fx-arrow")
		# CL1: kiếm khí Kiếm Khách (Trảm Phong…) màu đỏ; Băng Lao xanh băng.
		var tint := Color.WHITE
		if s.kind == "wave" and world.profile.class_id == "kiem-khach":
			tint = Color(1.0, 0.45, 0.4)
		elif s.skill == "banglao":
			tint = Color(0.6, 0.9, 1.0)
			draw_circle(s.pos, 9.0, Color(0.6, 0.9, 1.0, 0.35))
		if _art and SpriteLib.has_env(id):
			SpriteLib.draw_env(self, id, s.pos, tint, 1.0, false, s.vel.angle())
		else:
			draw_circle(s.pos, s.radius, Color("#c8e6ff"))
	for b in world.blasts:
		if Fx1.owns_burst(world):
			break
		var k: float = 1.0 - b.ttl / 0.35
		draw_circle(b.pos, b.radius * (0.6 + 0.4 * k), Color(b.color, 0.35 * (1.0 - k)))
		draw_arc(b.pos, b.radius * (0.6 + 0.4 * k), 0.0, TAU, 40, Color(b.color, 0.9 * (1.0 - k)), 3.0, true)


## Độ dài hoạt ảnh: đánh thường theo tốc đánh (swing_len); kỹ năng đặt swing dài hơn thì dùng mặc định.
func _swing_len(p, fallback: float) -> float:
	return p.swing_len if p.swing_len > 0.0 and p.swing <= p.swing_len + 0.0001 else fallback


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
		# CL1: vệt chém Kiếm Khách màu đỏ (charactors.md: "kiếm khí màu đỏ").
		var sc := Color(1, 0.3, 0.25) if world.profile.class_id == "kiem-khach" else Color(1, 1, 1)
		SpriteLib.poly(self, pts, Color(sc, 0.3 * minf(1.0, p.swing / _swing_len(p, 0.16))))
		# EN-1 (docs/43 §6): vũ khí +13 trở lên — mép vệt chém mang màu bậc cường hoá
		var wplus: int = int(world.profile.equipment.get("weapon", {}).get("plus", 0))
		if Items.enhance_tier(wplus) >= 4:
			var k := minf(1.0, p.swing / _swing_len(p, 0.16))
			draw_arc(p.pos, GameWorld.SLASH_RANGE, p.facing - GameWorld.SLASH_ARC, p.facing + GameWorld.SLASH_ARC, 24, Color(Items.enhance_color(wplus), 0.85 * k), 5.0, true)
			draw_arc(p.pos, GameWorld.SLASH_RANGE - 3.0, p.facing - GameWorld.SLASH_ARC * 0.8, p.facing + GameWorld.SLASH_ARC * 0.8, 20, Color(1, 1, 1, 0.6 * k), 2.0, true)
	elif not Fx1.owns_burst(world):
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
	# SN9-09: vòng vàng dưới chân quái đang là mục tiêu (khung mục tiêu ở HUD)
	if e == world.focus:
		var pulse := 0.75 + 0.25 * sin(world.time * 6.0)
		draw_set_transform(e.pos + Vector2(0, e.radius * 0.7), 0.0, Vector2(1.0, 0.45))
		draw_arc(Vector2.ZERO, e.radius + 10.0, 0.0, TAU, 32, Color(1.0, 0.82, 0.35, 0.85 * pulse), 2.5, true)
		draw_arc(Vector2.ZERO, e.radius + 15.0, 0.0, TAU, 32, Color(1.0, 0.82, 0.35, 0.3 * pulse), 1.5, true)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if e.hp < e.max_hp or e.elite:
		var w: float = e.radius * 2.0
		var top := Vector2(e.pos.x - w / 2.0, top_y)
		draw_rect(Rect2(top, Vector2(w, 4)), Color(0, 0, 0, 0.6))
		draw_rect(Rect2(top, Vector2(w * maxf(0.0, e.hp) / e.max_hp, 4)), Color("#ff5470"))
		# CB-07: thanh Phá Thế của tinh anh
		if e.max_poise > 0.0:
			draw_rect(Rect2(top + Vector2(0, 5), Vector2(w, 3)), Color(0, 0, 0, 0.6))
			draw_rect(Rect2(top + Vector2(0, 5), Vector2(w * maxf(0.0, e.poise) / e.max_poise, 3)), Color("#ffc940"))
	_enemy_nameplate(e, Vector2(e.pos.x, top_y - 8.0))


## UI-15 (Spec_Notes đợt 6): bảng tên quái "<biểu tượng hệ> Loại · Tên · Lv N" (tâm dưới tại `at`).
## Loại: Thường (xám) · Tinh anh (vàng) · Thủ lĩnh (cam, chủ Ổ quái) · Hiếm (tím). Cấp tô màu theo chênh lệch
## với người chơi: đỏ ≥ +5, cam > 0, trắng ngang, xám thấp hơn ≥ 5. Quái thường chỉ hiện khi ở gần (≤ 420)
## hoặc đã bị đánh, cho đỡ rối màn hình.
const NAMEPLATE_NEAR := 420.0


## UI-53 (docs/38): kiểu bảng tên theo Cài đặt "nameplates" — "smart" (mặc định): quái thường chỉ hiện khi là mục tiêu
## (rê chuột / vừa đánh) hoặc đã mất máu, dạng ngắn "Lv N Tên" (bỏ chữ "Thường"); "always": như UI-15 cũ;
## "off": chỉ tinh anh / thủ lĩnh / hiếm / chúa hang, cổng. Bảng tên không chồng nhau: bảng quái thường trùng chỗ
## bảng đã vẽ thì bỏ qua, bảng quan trọng thì đẩy lên trên. _plates xoá mỗi khung (_draw_texts).
var _plates: Array[Rect2] = []


func _enemy_nameplate(e, at: Vector2) -> void:
	var plain: bool = not e.elite and e.role != "rare" and e.role != "nestGuard" and not e.cave_boss
	var mode := str(Settings.values.get("nameplates", "smart"))
	var focused: bool = e == world.focus
	if plain:
		if mode == "off" and not focused:
			return
		if mode == "always" and e.hp >= e.max_hp and e.pos.distance_to(world.player.pos) > NAMEPLATE_NEAR:
			return
		if mode == "smart" and not focused and e.hp >= e.max_hp:
			return
	var tier := "Thường"
	var tcol := Color(0.75, 0.77, 0.8)
	if e.gate_boss:
		tier = "Chúa Cổng"
		tcol = Color("#ff4d6a")
	elif e.cave_boss:
		tier = "Chúa Hang"
		tcol = Color("#ff7a45")
	elif e.role == "rare":
		tier = "Hiếm"
		tcol = Color("#c79bff")
	elif e.role == "nestGuard":
		tier = "Thủ lĩnh"
		tcol = Color("#ff9a3c")
	elif e.elite:
		tier = "Tinh anh"
		tcol = Color("#ffd877")
	var gap: int = int(e.level) - int(world.profile.level)
	var lcol := Color.WHITE
	if gap >= 5:
		lcol = Color("#ff5470")
	elif gap > 0:
		lcol = Color("#ff9a3c")
	elif gap <= -5:
		lcol = Color(0.6, 0.6, 0.62)
	var f := UiTheme.bold_font()
	var fs := roundi((12 if plain else 13) * ViewScale.text_k)
	var parts := [[tier + " · ", tcol], [str(e.name) + " · ", Color(0.95, 0.93, 0.88)], ["Lv%d" % int(e.level), lcol]]
	if plain and mode != "always":
		parts = [["Lv%d " % int(e.level), lcol], [str(e.name), Color(0.95, 0.93, 0.88)]]
	var total := 0.0
	for pt in parts:
		total += f.get_string_size(pt[0], HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	var icon_w := 16.0 * ViewScale.text_k
	var rect := Rect2(at.x - (total + icon_w) / 2.0 - 2.0, at.y - fs - 1.0, total + icon_w + 4.0, fs + 5.0)
	for k in 4:
		var hit := false
		for pr in _plates:
			if pr.intersects(rect):
				hit = true
				break
		if not hit:
			break
		if plain and not focused:
			return
		rect.position.y -= rect.size.y
		at.y -= rect.size.y
	_plates.append(rect)
	var x := at.x - (total + icon_w) / 2.0
	var el: String = world.el_of(e)
	ElementIcon.draw(self, Vector2(x + 6.0 * ViewScale.text_k, at.y - fs * 0.35), el, 6.5 * ViewScale.text_k, 0.95)
	x += icon_w
	for pt in parts:
		draw_string_outline(f, Vector2(x, at.y), pt[0], HORIZONTAL_ALIGNMENT_LEFT, -1, fs, 4, Color(0, 0, 0, 0.8))
		draw_string(f, Vector2(x, at.y), pt[0], HORIZONTAL_ALIGNMENT_LEFT, -1, fs, pt[1])
		x += f.get_string_size(pt[0], HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x


## Chỉ sinh tia trúng đòn ở frame đầu của mỗi lần nháy.
func _flashed(e) -> bool:
	var tr: Dictionary = _track.get(e.id, {})
	return float(tr.get("flash", 0.0)) > 0.0


# ---------------------------------------------------------------- hình khối tạm (khi chưa có hình)
func _draw_gate(view: Rect2) -> void:
	if world.gate_x == INF:
		return
	var x: float = world.gate_x
	# PF-02: ngoài khung nhìn thì bỏ qua (dải cao cả map + 14 đốm sương)
	if x + 140.0 < view.position.x or x - 40.0 > view.end.x:
		return
	var h: float = world.world_size.y
	var a := Color(0.47, 0.35, 0.78, 0.0)
	var b := Color(0.47, 0.35, 0.78, 0.55)
	var c := Color(0.16, 0.1, 0.27, 0.92)
	draw_polygon(PackedVector2Array([Vector2(x - 40, 0), Vector2(x + 25, 0), Vector2(x + 25, h), Vector2(x - 40, h)]), PackedColorArray([a, b, b, a]))
	draw_polygon(PackedVector2Array([Vector2(x + 25, 0), Vector2(x + 140, 0), Vector2(x + 140, h), Vector2(x + 25, h)]), PackedColorArray([b, c, c, b]))
	for i in 14:
		var y := fposmod(i * 131.0 + world.time * 30.0, h)
		if y < view.position.y - 60.0 or y > view.end.y + 60.0:
			continue
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
					SpriteLib.poly(self, PackedVector2Array([at + Vector2(0, -10), at + Vector2(8, 0), at + Vector2(0, 10), at + Vector2(-8, 0)]), c)
			_:
				if _art:
					SpriteLib.draw_env(self, "pickup-orb", at)
				else:
					draw_circle(at, 7.0, Color("#5bd16a"))


## MP-09 / UI-14: cổng dịch chuyển — vòng phù văn nằm phẳng trên mặt đất (elip), 2 trụ đá có pha lê, cột sáng
## mờ và hạt bay lên. Vẽ TRƯỚC nhân vật/quái (lớp mặt đất) nên nhân vật đứng trong cổng luôn hiện rõ.
## Màu: vàng = cổng tiến đi được, xanh = cổng lùi, tím = Cổng Dịch Chuyển, xám = chưa đủ điều kiện.
const PORTAL_SQUASH := 0.42


func _portal_style(pt: Dictionary) -> Dictionary:
	if pt.kind == "waypoint":
		return {"col": Color("#b46bff"), "title": "Cổng Dịch Chuyển", "sub": "Về nhanh map đã mở", "open": true}
	# BD-11 (docs/34): Cổng dungeon — màu theo hạng, còn bao lâu.
	if pt.kind == "dgate":
		var gm: Dictionary = Maps.get_map(str(pt.to))
		var gb: String = world.travel_blocker(str(pt.to))
		var gl := ceili(Gates.left(world.profile, Gates.parent(str(pt.to))))
		return {"col": Gates.COLORS.get(str(pt.rank), Color.WHITE) if gb == "" else Color(0.58, 0.52, 0.5),
			"title": "Cổng hạng %s" % str(pt.rank),
			"sub": ("Cấp %d · còn %d:%02d" % [int(gm.levels[0]), gl / 3600, (gl / 60) % 60]) if gb == "" else gb, "open": gb == ""}
	if pt.kind == "exit":
		return {"col": Color("#7fe0c0"), "title": "Ra khỏi cổng" if Gates.is_gate(world.map_id) else "Ra khỏi hang", "sub": "Về " + str(Maps.get_map(str(pt.to)).name), "open": true}
	if pt.kind == "cave":
		var cm: Dictionary = Maps.get_map(str(pt.to))
		var cb: String = world.travel_blocker(str(pt.to))
		return {"col": Color("#e08a3c") if cb == "" else Color(0.58, 0.52, 0.5), "title": str(cm.name),
			"sub": ("Cấp %d–%d · Chúa Hang" % [int(cm.levels[0]), int(cm.levels[1])]) if cb == "" else cb, "open": cb == ""}
	var m: Dictionary = Maps.get_map(str(pt.to))
	var block: String = world.travel_blocker(str(pt.to))
	var st := {"title": ("Tới " if pt.kind == "next" else "Về ") + str(m.name), "sub": "Cấp %d–%d" % [int(m.levels[0]), int(m.levels[1])], "open": block == ""}
	# C7-01 / MP-09: cổng 6-3 → 7-1 là Bến Khí Cầu
	if str(pt.to) == "7-1" and pt.kind == "next":
		st.title = "Bến Khí Cầu → " + str(m.name)
	if block != "":
		st.col = Color(0.62, 0.58, 0.66)
		st.sub = block
	else:
		st.col = Color("#ffc940") if pt.kind == "next" else Color("#6fb6ff")
	return st


## PF-02: chỉ vẽ cổng trong khung nhìn (map ×3 có nhiều cổng; trước đây vẽ hết ≈ 1,8 ms/khung).
func _draw_portals(view: Rect2) -> void:
	var t := world.time
	for pt in world.portals:
		if not view.grow(160.0).has_point(pt.pos):
			continue
		var st := _portal_style(pt)
		var col: Color = st.col
		var on: bool = st.open
		var c: Vector2 = pt.pos
		var r := 46.0
		var k := PORTAL_SQUASH
		var glow := 0.75 + 0.25 * sin(t * 2.5)
		# bóng + nền đá elip
		draw_set_transform(c + Vector2(0, 4), 0.0, Vector2(1.0, k))
		draw_circle(Vector2.ZERO, r + 16.0, Color(0, 0, 0, 0.35))
		draw_set_transform(c, 0.0, Vector2(1.0, k))
		draw_circle(Vector2.ZERO, r + 12.0, Color("#3a3444"))
		draw_arc(Vector2.ZERO, r + 12.0, 0, TAU, 48, Color("#1d1924"), 4.0, true)
		draw_arc(Vector2.ZERO, r + 8.0, 0, TAU, 48, Color("#c9a45c"), 3.0, true)
		# phù văn quanh vành: 12 vạch sáng chạy vòng
		for i in 12:
			var a := TAU * i / 12.0 + t * 0.4
			var lit := 0.35 + 0.65 * maxf(0.0, sin(t * 3.0 - i * 0.8))
			var d := Vector2.from_angle(a)
			draw_line(d * (r + 2.0), d * (r + 7.0), Color(col.lightened(0.3), lit if on else 0.25), 2.5, true)
		# lòng cổng: nền tối + xoáy ánh sáng
		draw_circle(Vector2.ZERO, r, Color(col.darkened(0.82), 0.95))
		for j in 4:
			var rr := r * (0.92 - j * 0.2)
			draw_circle(Vector2.ZERO, rr, Color(col, (0.08 + j * 0.05) * (glow if on else 0.4)))
		if on:
			for j in 3:
				var a0 := t * (1.6 + j * 0.5) + j * TAU / 3.0
				draw_arc(Vector2.ZERO, r * (0.3 + j * 0.22), a0, a0 + PI * 1.1, 24, Color(col.lightened(0.45), 0.7 - j * 0.15), 3.0, true)
			draw_circle(Vector2.ZERO, r * 0.16, Color(col.lightened(0.7), glow))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		# cột sáng mờ dâng lên (chỉ khi đi được)
		if on:
			for j in 6:
				var hh := 26.0 + j * 14.0
				var ww := r * (0.85 - j * 0.12)
				draw_rect(Rect2(c + Vector2(-ww, -hh), Vector2(ww * 2.0, 14.0)), Color(col, 0.05 * glow))
			for j in 7:
				var ph := fmod(t * 0.6 + j * 0.37, 1.0)
				var px := sin(j * 2.3 + t) * r * 0.6
				draw_circle(c + Vector2(px, -ph * 90.0), 2.2 * (1.0 - ph) + 0.6, Color(col.lightened(0.6), 0.9 * (1.0 - ph)))
		# 2 trụ đá hai bên + pha lê trên đỉnh
		for side in [-1.0, 1.0]:
			var base := c + Vector2(side * (r + 10.0), 0)
			var pillar := Rect2(base + Vector2(-7, -54), Vector2(14, 56))
			draw_rect(Rect2(base + Vector2(-9, -4), Vector2(18, 8)), Color("#2a2530"))
			draw_rect(pillar, Color("#4a4356"))
			draw_rect(Rect2(pillar.position, Vector2(4, pillar.size.y)), Color("#5e566c"))
			draw_rect(pillar, Color("#c9a45c"), false, 1.5)
			draw_rect(Rect2(base + Vector2(-10, -60), Vector2(20, 7)), Color("#c9a45c"))
			var gem := base + Vector2(0, -72)
			var gs := 7.0 + (1.0 if on else 0.0) * sin(t * 3.0 + side)
			draw_circle(gem, gs + 6.0, Color(col, 0.18 * (glow if on else 0.4)))
			SpriteLib.poly(self, PackedVector2Array([gem + Vector2(0, -gs - 3), gem + Vector2(gs * 0.7, 0), gem + Vector2(0, gs), gem + Vector2(-gs * 0.7, 0)]),
				col if on else col.darkened(0.3))
			SpriteLib.poly(self, PackedVector2Array([gem + Vector2(0, -gs - 3), gem + Vector2(gs * 0.7, 0), gem]), Color(1, 1, 1, 0.45))


## Bảng tên cổng (vẽ sau cùng lớp thế giới để không bị cây che).
func _draw_portal_labels(view: Rect2) -> void:
	var f := UiTheme.bold_font()
	for pt in world.portals:
		if not view.grow(200.0).has_point(pt.pos):
			continue
		var st := _portal_style(pt)
		var col: Color = st.col
		# Rà soát 01/11: Cổng Dịch Chuyển nằm giữa làng (NPC, nhân vật đứng gần) → bảng tên dưới cổng, không đè tên NPC.
		var c: Vector2 = pt.pos + (Vector2(0, 54) if pt.kind == "waypoint" else Vector2(0, -104))
		var title: String = st.title
		# Cổng Dịch Chuyển: bảng 1 dòng (gọn, ít đè tên NPC); dòng giải thích có ở bảng lục địa khi bước vào.
		var sub: String = "" if pt.kind == "waypoint" else str(st.sub)
		var k := ViewScale.text_k
		var tw := f.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, roundi(14 * k)).x
		var sw := _font.get_string_size(sub, HORIZONTAL_ALIGNMENT_LEFT, -1, roundi(11 * k)).x
		var w := maxf(tw, sw) + 28.0 * k
		var rect := Rect2(c - Vector2(w / 2.0, 14 * k), Vector2(w, (34 if sub != "" else 22) * k))
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0.07, 0.05, 0.1, 0.82)
		sb.set_corner_radius_all(8)
		sb.set_border_width_all(1)
		sb.border_color = Color(col, 0.9)
		draw_style_box(sb, rect)
		_diamond_at(Vector2(rect.position.x, rect.get_center().y), 4.0, col)
		_diamond_at(Vector2(rect.end.x, rect.get_center().y), 4.0, col)
		_label(title, c + Vector2(0, 2 * k), col.lightened(0.25), 14, true)
		if sub != "":
			_label(sub, c + Vector2(0, 16 * k), Color(0.88, 0.88, 0.9), 11)


func _diamond_at(p: Vector2, s: float, col: Color) -> void:
	SpriteLib.poly(self, PackedVector2Array([p + Vector2(0, -s), p + Vector2(s, 0), p + Vector2(0, s), p + Vector2(-s, 0)]), col)


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


## Đòn riêng vùng 5–9: view của chương tự vẽ cảnh báo (draw_over) → nhánh mặc định không vẽ thêm vòng đỏ chồng lên.
const REGION_TELEGRAPHS := ["fireburst", "hammer", "pdive", "firepillar", "dbreath", "snowball", "icepillar", "icecrack",
	"frostbreath", "m_spin", "m_dash", "m_bolt", "slam", "lance", "clouddash", "rootlash", "seal", "voidbeam", "heavycleave",
	"jaw", "sacrifice", "devour", "elemlance", "gallop", "dash9", "roar9", "spin9", "pounce9"]


func _draw_telegraph(e: GameWorld.Enemy) -> void:
	if e.state != "windup":
		return
	var progress := 1.0 - maxf(0.0, e.timer) / e.windup_total
	var cue := Fx1.windup_cue(_pa, world, e, progress)  # §9.12: động tác lấy đà (kiểu tự nhiên)
	if _fx1_telegraph(e, progress):
		return
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
			SpriteLib.poly(self, pts, Color(0.4, 0.85, 0.45, 0.12 + progress * 0.25))
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
			SpriteLib.poly(self, gp, Color(0.3, 0.75, 1.0, 0.12 + progress * 0.25))
		_:
			if not cue and not (e.attack_kind in REGION_TELEGRAPHS):
				draw_arc(e.pos, e.radius + e.attack_range * progress, 0.0, TAU, 40, Color(1, 0.24, 0.31, 0.2 + progress * 0.6), 3.0, true)


## FX-1 §9.9 / §9.11: vùng tròn (Fx1.draw_danger), dải và nón (Fx1.danger_line / danger_cone), đúng kích thước gameplay.
func _fx1_telegraph(e: GameWorld.Enemy, progress: float) -> bool:
	var zones: Array = []
	match e.attack_kind:
		"pounce":
			zones = [[e.target, GameWorld.POUNCE_RADIUS, Fx1.P_DANGER]]
		"dive":
			zones = [[e.target, GameWorld.DIVE_R, Fx1.P_FROST]]
		"tiger":
			if not Fx1.tele_natural():
				draw_line(e.pos, e.target, Color(0.95, 0.95, 0.9, 0.15 + progress * 0.3), 3.0, true)
			zones = [[e.target, GameWorld.TIGER_R, Fx1.P_DANGER]]
		"roar":
			zones = [[e.pos, GameWorld.ROAR_R, Fx1.P_FROST]]
		"roots":
			for k in 3:
				zones.append([e.target + Vector2.from_angle(k * TAU / 3.0) * GameWorld.ROOT_R * 0.9, GameWorld.ROOT_R, Fx1.P_SAND])
		"stomp", "explode":
			zones = [[e.pos, GameWorld.STOMP_R if e.attack_kind == "stomp" else GameWorld.EXPLODE_R, Fx1.P_DANGER]]
		"emerge", "sdive", "tail", "sandvortex":
			var rr: float = {"emerge": Ch3.BURROW_R, "sdive": Ch3.DIVE_R, "tail": Ch3.TAIL_R, "sandvortex": Ch3.VORTEX_R}[e.attack_kind]
			zones = [[e.target, rr, Fx1.P_TOXIC if e.attack_kind == "tail" else Fx1.P_SAND]]
		"pull":
			zones = [[e.pos, GameWorld.PULL_R, Fx1.P_FROST]]
		# §9.11: dạng đường / nón — cùng độ dài, bề rộng, góc như kiểu cũ (gameplay)
		"volley", "darts", "dart1":
			var ang: float = (e.target - e.pos).angle()
			var spread: float = deg_to_rad(15.0 if e.attack_kind == "volley" else 20.0)
			var ok := true
			for k in [-1, 0, 1]:
				ok = Fx1.danger_line(world, e.pos, e.pos + Vector2.from_angle(ang + k * spread) * 220.0, 3.0, Fx1.P_FIRE, progress, e) and ok
			return ok
		"spore":
			return Fx1.danger_line(world, e.pos, e.target, 4.0, Fx1.P_TOXIC, progress, e)
		"dash":
			return Fx1.danger_line(world, e.pos, e.pos + (e.target - e.pos).limit_length(150.0), 4.0, Fx1.P_FROST, progress, e)
		"roll":
			return Fx1.danger_line(world, e.pos, e.target, e.radius * 0.8, Fx1.P_SAND, progress, e)
		"leaf":
			return Fx1.danger_cone(world, e.pos, (e.target - e.pos).angle(), GameWorld.LEAF_ARC, GameWorld.LEAF_RANGE + e.radius, Fx1.P_LEAF, progress, e)
		"gaze":
			return Fx1.danger_cone(world, e.pos, (e.target - e.pos).angle(), Ch3.GAZE_HALF, Ch3.GAZE_R + e.radius, Fx1.P_FROST, progress, e)
		_:
			return false
	var ok := true
	for z in zones:
		ok = Fx1.danger_zone(world, z[0], z[1], z[2], progress, e) and ok
	return ok


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
		_enemy_nameplate(e, e.pos + Vector2(0, -e.radius - 18.0))


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


## UI-52 (docs/38): tối đa FLOAT_MAX chữ nổi cùng lúc (mới nhất); chữ trùng chỗ chữ đã vẽ thì đẩy lên trên.
## Dòng nhặt đồ (SN5-10) không còn xếp trên đầu nhân vật — HUD vẽ ở dải nhặt đồ bên trái (ui/pickup_feed.gd).
const FLOAT_MAX := 10


func _draw_texts() -> void:
	_plates.clear()
	# SN5-01: điểm đến khi bấm bản đồ nhỏ
	if world.has_move_target():
		var tp: Vector2 = world.move_target
		var k := 0.5 + 0.5 * sin(world.time * 6.0)
		draw_arc(tp, 14.0 + 4.0 * k, 0.0, TAU, 24, Color(1, 0.85, 0.3, 0.8), 2.0, true)
		draw_line(tp, tp + Vector2(0, -26), Color("#ffc940"), 2.0)
		SpriteLib.poly(self, PackedVector2Array([tp + Vector2(0, -26), tp + Vector2(14, -21), tp + Vector2(0, -16)]), Color("#ffc940"))
	var list: Array = world.texts
	var placed: Array[Rect2] = []
	var f := UiTheme.bold_font()
	for i in range(maxi(0, list.size() - FLOAT_MAX), list.size()):
		var t = list[list.size() - 1 - (i - maxi(0, list.size() - FLOAT_MAX))]
		var size := roundi((19 if t.big else 15) * ViewScale.text_k)
		var c: Color = t.color
		var w := f.get_string_size(t.text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x + 6.0
		var at: Vector2 = t.pos
		var rect := Rect2(at.x - w / 2.0, at.y - size, w, size + 3.0)
		for k in 6:
			var hit := false
			for pr in placed:
				if pr.intersects(rect):
					hit = true
					break
			if not hit:
				break
			rect.position.y -= rect.size.y
		placed.append(rect)
		_label(t.text, Vector2(at.x, rect.end.y - 3.0), Color(c, minf(1.0, t.ttl * 2.0)), size, true, true)


func _label(text: String, pos: Vector2, color: Color, size: int, bold := false, scaled := false) -> void:
	var f := UiTheme.bold_font() if bold else _font
	# VS-1: chữ trong thế giới giữ cỡ trên màn hình khi camera zoom ra (_draw_texts đã nhân sẵn → scaled).
	if not scaled:
		size = roundi(size * ViewScale.text_k)
	var w := 400.0 * ViewScale.text_k
	var at := pos - Vector2(w / 2.0, 0)
	draw_string_outline(f, at, text, HORIZONTAL_ALIGNMENT_CENTER, w, size, 4, Color(0, 0, 0, 0.75 * color.a))
	draw_string(f, at, text, HORIZONTAL_ALIGNMENT_CENTER, w, size, color)
