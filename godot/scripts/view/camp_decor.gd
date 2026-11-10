extends RefCounted
## GN-1 E2 / E3 (docs/45) + GN-2 (vùng 2–9): bộ cảnh "trại / bãi chiến" + nguồn sáng điểm.
##  • Đấu trường (vùng có đấu trường vẽ chung: 1, 2, 3, 4, 6): rào / tường dựng ở cung phía XA (mép trên, 205°–335°) làm phông,
##    2 chòi canh hai đầu, cờ vùng, đuốc hai bên lối vào phía tây, giá vũ khí, đồ vương vãi trong sân.
##    Vùng 5, 7, 8, 9 có đấu trường vẽ riêng (dung nham, đảo mây, Hư Vô, Thiên Thê) → không thêm phông.
##  • Bãi trại bỏ hoang rải trên bản đồ: 3 đoạn rào / tường phía bắc, giá vũ khí, đồ vùng (thùng, vò, xe quặng…), đồ vương vãi,
##    có khi có cờ / đèn. Tránh làng, đấu trường, lối mòn, cổng, nước (vùng 4), dung nham (vùng 5), mép đảo (vùng 7) và mọi điểm
##    nhiệm vụ / cơ chế ghi trong dữ liệu map.
## Chỉ là cảnh (không chặn đường đi). RNG riêng theo map → không đổi cây / đá đã sinh; cây đè lên cảnh bị bỏ (clear).
## Hàm thuần (chỉ đọc world.map / vị trí) để test được.

const Maps = preload("res://scripts/data/maps.gd")
const Ch4 = preload("res://scripts/core/chapter4.gd")
const Ch7 = preload("res://scripts/core/chapter7.gd")

## Bộ cảnh theo vùng. wall = đoạn rào / tường; banner; flat = đồ vương vãi; extra = đồ đứng của bãi trại;
## light = đèn ở bãi trại ("" = không); arena = có phông đấu trường; tower / torch = chòi canh / đuốc của đấu trường.
## Vùng 6 không đặt lửa (lửa là cơ chế sưởi ấm — người chơi sẽ tưởng sưởi được).
const THEMES := {
	1: {"ground": "tile-dirt", "wall": "palisade", "banner": "banner-wolf", "flat": ["debris-0", "debris-1", "debris-2"], "extra": ["crates"],
		"light": "", "arena": true, "tower": "watchtower", "torch": "torch-post"},
	2: {"ground": "tile-dirt", "wall": "palisade-plain", "banner": "banner-wind", "flat": ["debris-1", "debris-2", "debris-0"], "extra": ["haystack", "crates"],
		"light": "torch-post", "arena": true, "tower": "watchtower", "torch": "torch-post"},
	3: {"ground": "tile-sand-red", "wall": "wall-sandstone", "banner": "banner-sun", "flat": ["rubble-sand", "debris-0", "debris-1"], "extra": ["jars"],
		"light": "torch-post", "arena": true, "tower": "tower", "torch": "torch-post"},
	4: {"ground": "tile-mud", "wall": "palisade-bamboo", "banner": "banner-leaf", "flat": ["debris-2", "debris-0", "debris-1"], "extra": ["crates"],
		"light": "lantern-post", "arena": true, "tower": "watchtower", "torch": "lantern-post"},
	5: {"ground": "tile-ash", "wall": "wall-basalt", "banner": "banner-flame", "flat": ["rubble-basalt", "debris-1", "debris-0"], "extra": ["ore-cart"],
		"light": "brazier", "arena": false},
	6: {"ground": "tile-dirt", "wall": "palisade-snow", "banner": "banner-snow", "flat": ["rubble-ice", "debris-0", "debris-1"], "extra": ["woodpile", "sled"],
		"light": "", "arena": true, "tower": "watchtower", "torch": ""},
	7: {"ground": "tile-dirt", "wall": "wall-marble", "banner": "banner-cloud", "flat": ["rubble-marble", "debris-1"], "extra": ["crates"],
		"light": "lantern-post", "arena": false},
	8: {"ground": "tile-marble-dark", "wall": "wall-obsidian", "banner": "banner-eye", "flat": ["rubble-void", "debris-0", "debris-1"], "extra": ["void-stone"],
		"light": "", "arena": false},
	9: {"ground": "tile-marble", "wall": "wall-jade", "banner": "banner-lotus", "flat": ["rubble-marble", "debris-1"], "extra": ["incense-burner"],
		"light": "", "arena": false},
}
## GN-3 E1: ground = nền đất mòn dưới bãi trại (vùng 6: đất lộ dưới tuyết bị giẫm; vùng 8 / 9: sàn đá lát).
## Số bãi trại theo diện tích map (map ≈ 7200×4400 → ≈ 12 bãi, cách nhau ≥ 700 px).
const CAMPS_PER_MPX := 0.38
const CAMP_CLEAR := 170.0
## Đồ phẳng sát đất — vẽ cùng lớp nền, không sắp theo chiều sâu, không bóng đổ.
const FLAT := ["debris-0", "debris-1", "debris-2", "rubble-sand", "rubble-basalt", "rubble-marble", "rubble-void", "rubble-ice"]
## Khoảng tránh quanh điểm ghi trong dữ liệu map (Vector2 / [Vector2…] / [[tâm, r]…]).
const MAP_POINT_CLEAR := 260.0
## Khoá dữ liệu map không phải điểm trên bản đồ.
const NOT_POINTS := ["size", "levels", "zone_x", "tint", "islands", "lava"]
## E3: id hình có lửa / đèn → [lệch đầu lửa so với chân (px thế giới, tỉ lệ 1), màu, cỡ quầng].
const LIGHTS := {
	"lantern-post": [Vector2(9, -49), Color(1.0, 0.62, 0.3), 1.0],
	"torch-post": [Vector2(0, -60), Color(1.0, 0.55, 0.22), 1.1],
	"campfire": [Vector2(0, -15), Color(1.0, 0.5, 0.18), 1.5],
	"brazier": [Vector2(0, -40), Color(1.0, 0.5, 0.2), 1.3],
	"watchtower": [Vector2(20, -112), Color(1.0, 0.65, 0.3), 0.7],
}


static func theme(world) -> Dictionary:
	return THEMES.get(int(world.map.get("region", 1)), {})


static func enabled(world) -> bool:
	return not theme(world).is_empty() and not bool(world.map.get("cave", false)) and Maps.MAPS.has(str(world.map_id))


## {"items": [{pos, id, scale, flip}], "flat": [...], "clear": [[tâm, bán kính]], "ground": [[tâm, rx, ry, ô đất]]}
static func build(world) -> Dictionary:
	var out := {"items": [], "flat": [], "clear": [], "ground": []}
	if not enabled(world):
		return out
	var t := theme(world)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(str(world.map_id) + "|camp")
	if world.map.arena != null and bool(t.arena):
		_arena(out, world, rng, t)
	_field_camps(out, world, rng, t)
	return out


static func _add(out: Dictionary, pos: Vector2, id: String, k := 1.0, flip := false) -> void:
	if id == "":
		return
	var it := {"pos": pos, "id": id, "scale": k, "flip": flip}
	if id in FLAT:
		out.flat.append(it)
	else:
		out.items.append(it)


static func _arena(out: Dictionary, world, rng: RandomNumberGenerator, t: Dictionary) -> void:
	var c: Vector2 = world.arena_pos
	var r: float = world.arena_r
	var rr := r + 34.0
	# rào: mỗi đoạn rộng ≈ 56–68 px → bước góc theo độ dài cung
	var a := deg_to_rad(205.0)
	var a1 := deg_to_rad(335.0)
	var step := 52.0 / rr
	while a <= a1:
		_add(out, c + Vector2.from_angle(a) * rr, t.wall, 1.0, rng.randf() < 0.5)
		a += step
	for deg in [198.0, 342.0]:
		_add(out, c + Vector2.from_angle(deg_to_rad(deg)) * (r + 80.0), str(t.get("tower", "")), 1.0, deg > 270.0)
	for deg in [240.0, 300.0]:
		_add(out, c + Vector2.from_angle(deg_to_rad(deg)) * (r + 4.0), t.banner, 1.0, deg > 270.0)
	for deg in [160.0, 200.0]:
		_add(out, c + Vector2.from_angle(deg_to_rad(deg)) * (r + 24.0), str(t.get("torch", "")), 1.0)
	_add(out, c + Vector2.from_angle(deg_to_rad(222.0)) * (r - 10.0), "weapon-rack", 1.0)
	var flat: Array = t.flat
	for i in 7:
		var p := c + Vector2.from_angle(rng.randf() * TAU) * r * (0.3 + rng.randf() * 0.55)
		_add(out, p, flat[i % mini(2, flat.size())], 0.9 + rng.randf() * 0.3, rng.randf() < 0.5)
	out.clear.append([c, r + 140.0])


static func _field_camps(out: Dictionary, world, rng: RandomNumberGenerator, t: Dictionary) -> void:
	var size: Vector2 = world.world_size
	var safe: Vector2 = world.safe_pos
	var path_end: float = world.arena_pos.x if world.map.arena != null else size.x
	var want := maxi(2, roundi(size.x * size.y / 1000000.0 * CAMPS_PER_MPX))
	var blocked := map_points(world.map)
	var spots: Array = []
	var tries := 0
	# map ngập nước (4-2): chỉ đặt trên cồn đất đủ rộng (tâm cồn), không rải ngẫu nhiên
	var wd = world.map.get("water", null)
	var isles: Array = []
	if wd != null and bool(wd.default):
		for z in wd.zones:
			if float(z[1]) >= 160.0:
				isles.append(z[0])
	while spots.size() < want and tries < 400:
		tries += 1
		var p := Vector2(220.0 + rng.randf() * (size.x - 440.0), 260.0 + rng.randf() * (size.y - 480.0))
		if wd != null and bool(wd.default):
			if isles.is_empty():
				break
			p = isles[rng.randi() % isles.size()] + Vector2(0, 30)
		if p.distance_to(safe) < world.safe_r + 420.0:
			continue
		if world.map.arena != null and p.distance_to(world.arena_pos) < world.arena_r + 320.0:
			continue
		if absf(p.y - safe.y) < 200.0 and p.x > safe.x and p.x < path_end:
			continue
		var ok := spot_ok(world, p, blocked)
		for pt in world.portals:
			ok = ok and p.distance_to(pt.pos) > 260.0
		for s in spots:
			ok = ok and p.distance_to(s) > 700.0
		if ok:
			spots.append(p)
	var flat: Array = t.flat
	var extra: Array = t.extra
	for p in spots:
		var flip := rng.randf() < 0.5
		for dx in [-56.0, 0.0, 56.0]:
			_add(out, p + Vector2(dx, -92.0 + absf(dx) * 0.18), t.wall, 1.0, rng.randf() < 0.5)
		_add(out, p + Vector2(-78.0 if flip else 78.0, -30.0), "weapon-rack", 1.0, flip)
		_add(out, p + Vector2(74.0 if flip else -74.0, -16.0), extra[rng.randi() % extra.size()], 0.9, flip)
		_add(out, p + Vector2(10.0, 30.0), flat[rng.randi() % flat.size()], 1.0, flip)
		_add(out, p + Vector2(-40.0 if flip else 40.0, 54.0), flat[rng.randi() % flat.size()], 0.9, not flip)
		if rng.randf() < 0.5:
			_add(out, p + Vector2(96.0 if flip else -96.0, -78.0), t.banner, 0.9, flip)
		elif str(t.light) != "":
			_add(out, p + Vector2(96.0 if flip else -96.0, -60.0), t.light, 1.0, flip)
		out.clear.append([p, CAMP_CLEAR])
		# GN-3 E1: nền đất mòn (elip, mép mềm) — [tâm, bán trục x, bán trục y, id ô đất]
		out.ground.append([p + Vector2(0, -24), 168.0, 104.0, str(t.get("ground", "tile-dirt"))])


## Mọi điểm trong dữ liệu map (cửa tầng, lính gác, ấn, lửa trại, đèn, bia…) → [[tâm, bán kính tránh]].
static func map_points(m: Dictionary) -> Array:
	var out: Array = []
	for k in m:
		if str(k) in NOT_POINTS:
			continue
		var v = m[k]
		if v is Vector2:
			out.append([v, MAP_POINT_CLEAR])
		elif v is Array:
			for e in v:
				if e is Vector2:
					out.append([e, MAP_POINT_CLEAR])
				elif e is Array and e.size() >= 2 and e[0] is Vector2 and (e[1] is float or e[1] is int):
					out.append([e[0], float(e[1]) + 160.0])
				elif e is Array and e.size() >= 2 and e[0] is Vector2 and e[1] is Vector2:
					# đoạn thẳng (cầu gió, đường…): điểm dọc đoạn mỗi 150 px
					var n := maxi(1, ceili(e[0].distance_to(e[1]) / 150.0))
					for i in n + 1:
						out.append([e[0].lerp(e[1], float(i) / n), 200.0])
	return out


## Chỗ đặt bãi trại hợp lệ: không gần điểm dữ liệu map, không trong / sát nước (vùng 4), dung nham (vùng 5), ngoài đảo (vùng 7).
static func spot_ok(world, p: Vector2, blocked: Array) -> bool:
	for b in blocked:
		if p.distance_to(b[0]) < float(b[1]):
			return false
	var probes := [p, p + Vector2(-110, -100), p + Vector2(110, -100), p + Vector2(-110, 60), p + Vector2(110, 60)]
	for q in probes:
		if world.map.get("water", null) != null and Ch4.in_water(world, q):
			return false
		if world.map.has("islands") and not Ch7.on_land_static(world.map, q):
			return false
	# vùng 7: không đè cầu gió (bridges = cặp chỉ số đảo, cầu nối tâm 2 đảo)
	var isl: Array = world.map.get("islands", [])
	for br in world.map.get("bridges", []):
		if int(br[0]) < isl.size() and int(br[1]) < isl.size():
			var q := Geometry2D.get_closest_point_to_segment(p, isl[int(br[0])][0], isl[int(br[1])][0])
			if p.distance_to(q) < 200.0:
				return false
	for z in world.map.get("lava", []):
		if p.distance_to(z[0]) < float(z[1]) + 220.0:
			return false
	return true


## Lọc danh sách cây: bỏ cây nằm trong vùng dọn của cảnh.
static func filter_trees(trees: Array, clear: Array) -> Array:
	if clear.is_empty():
		return trees
	return trees.filter(func(t):
		for c in clear:
			if t.pos.distance_to(c[0]) < float(c[1]):
				return false
		return true)


## E3: danh sách nguồn sáng [vị trí đầu lửa, màu, cỡ, chân] của đồ trong khung nhìn.
static func lights_of(items: Array, out: Array) -> void:
	for it in items:
		var l = LIGHTS.get(str(it.id))
		if l != null:
			var k := float(it.scale)
			var off: Vector2 = l[0] * k
			if bool(it.flip):
				off.x = -off.x
			out.append([it.pos + off, l[1], float(l[2]) * k, it.pos])
