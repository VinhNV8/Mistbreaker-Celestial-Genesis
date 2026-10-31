extends RefCounted
## M10 (docs/16): vẽ vùng 7 Quần Đảo Thiên Không — trời mây giữa các đảo, đảo + mép mây, cầu gió (nhấp nháy khi sắp tắt),
## đảo vụn, Đá Neo, Trụ Gió, Bia Đá gốc, nền đấu trường Cự Thần (hố, cung vỡ, cung sắp vỡ), vòng báo, vệt sấm,
## hiệu ứng rơi / Lông Vũ Gió. world_view.gd chỉ gọi draw_ground / draw_arena / draw_over / decor_id.

const SpriteLib = preload("res://scripts/view/sprite_lib.gd")
const Ch7 = preload("res://scripts/core/chapter7.gd")

const SKY_TOP := Color("#6ea4e8")
const SKY_LOW := Color("#bcdcff")


## Trời phủ cả map, rồi vẽ lại đảo + cầu + đảo vụn lên trên (sau nền đất, trước vật thể).
static func draw_ground(ci: CanvasItem, world, view: Rect2, art: bool) -> void:
	if not Ch7.in_region(world):
		return
	var m: Dictionary = world.map
	var t: float = world.time
	var sz: Vector2 = world.world_size
	ci.draw_polygon(PackedVector2Array([Vector2.ZERO, Vector2(sz.x, 0), sz, Vector2(0, sz.y)]),
		PackedColorArray([SKY_TOP, SKY_TOP, SKY_LOW, SKY_LOW]))
	# mây trôi bên dưới
	for i in 40:
		var cp := Vector2(fposmod(i * 397.0 + t * (12.0 + (i % 5) * 4.0), sz.x + 400.0) - 200.0, fposmod(i * 263.0, sz.y))
		if view.grow(120.0).has_point(cp):
			ci.draw_circle(cp, 40.0 + (i % 4) * 14.0, Color(1, 1, 1, 0.22))
	var tile: String = str(m.get("ground", "tile-sky-grass"))
	var islands: Array = m.get("islands", [])
	for it in islands:
		_island(ci, it[0], float(it[1]), tile, view, art, t)
	for c in world.ch7.crumble:
		if c.r > 0.0:
			_island(ci, c.pos, c.r, "tile-marble", view, art, t)
			var a: float = clampf(c.acc / Ch7.CRUMBLE_EVERY, 0.0, 1.0)
			ci.draw_arc(c.pos, c.r, 0.0, TAU, 32, Color(1.0, 0.45, 0.3, 0.3 + 0.5 * a), 3.0, true)
	# cầu gió
	for i in m.get("bridges", []).size():
		var seg := Ch7.bridge_seg(m, i)
		var left := Ch7.bridge_left(world, i)
		var on := left > 0.0
		var warn: bool = on and left <= Ch7.BRIDGE_WARN
		var alpha := 0.75
		if not on:
			alpha = 0.08
		elif warn:
			alpha = 0.3 + 0.45 * absf(sin(t * 14.0))
		var col := Color(0.55, 0.85, 1.0, alpha) if left < INF else Color(1.0, 0.92, 0.6, 0.8)
		ci.draw_line(seg[0], seg[1], col, Ch7.BRIDGE_HALF * 2.0)
		ci.draw_line(seg[0], seg[1], Color(1, 1, 1, alpha * 0.6), 3.0)
		var d: Vector2 = (seg[1] - seg[0])
		var n := d.orthogonal().normalized() * Ch7.BRIDGE_HALF
		for k in 2:
			var s := (1 if k == 0 else -1)
			ci.draw_line(seg[0] + n * s, seg[1] + n * s, Color(0.85, 0.95, 1.0, alpha * 0.8), 2.0)
	# Đá Neo
	var got: Array = world.profile.anchor_stones.get(world.map_id, [])
	var an: Array = m.get("anchors", [])
	for i in an.size():
		var lit: bool = (i + 1) in got
		_env(ci, "anchor-stone-lit" if lit else "anchor-stone", an[i], art, Color("#7ae0ff") if lit else Color("#a4a4b4"))
	# Trụ Gió
	var pl: Array = m.get("pillars", [])
	for i in pl.size():
		var lit2: bool = i in world.profile.quest.get("pillars7", [])
		_env(ci, "wind-pillar-lit" if lit2 else "wind-pillar", pl[i], art, Color("#bcdcff"))
		var pt: float = float(world.ch7.pillar_t.get(i, 0.0))
		if pt > 0.0 and not lit2:
			ci.draw_arc(pl[i], Ch7.PILLAR_R, -PI / 2.0, -PI / 2.0 + TAU * pt / Ch7.PILLAR_TIME, 32, Color("#bcdcff"), 4.0, true)


static func _island(ci: CanvasItem, c: Vector2, r: float, tile: String, view: Rect2, art: bool, t: float) -> void:
	if not view.grow(r + 60.0).has_point(c) and not Rect2(c - Vector2(r, r), Vector2(r, r) * 2.0).intersects(view):
		return
	# vách đá dưới đảo (bóng 3/4)
	ci.draw_set_transform(c + Vector2(0, r * 0.18), 0.0, Vector2(1.0, 1.0))
	ci.draw_circle(Vector2.ZERO, r * 0.96, Color("#5a4a3a"))
	ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var pts := _circle(c, r, 56)
	if not (art and SpriteLib.fill_polygon(ci, pts, tile)):
		SpriteLib.poly(ci, pts, Color("#5aa45a"))
	ci.draw_arc(c, r, 0.0, TAU, 56, Color(1, 1, 1, 0.55), 6.0, true)
	# mép mây
	var n := maxi(6, int(r / 40.0))
	for k in n:
		var a := TAU * k / n + t * 0.05
		ci.draw_circle(c + Vector2.from_angle(a) * r, 18.0 + 6.0 * sin(k * 1.7), Color(1, 1, 1, 0.75))


static func _env(ci: CanvasItem, id: String, pos: Vector2, art: bool, fallback: Color) -> void:
	if art and SpriteLib.has_env(id):
		SpriteLib.draw_env(ci, id, pos, Color.WHITE, 1.4)
	else:
		ci.draw_rect(Rect2(pos + Vector2(-8, -40), Vector2(16, 40)), fallback)


static func _circle(c: Vector2, r: float, n: int) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in n:
		pts.append(c + Vector2.from_angle(TAU * i / n) * r)
	return pts


## Sau khi world_view vẽ nền đấu trường: hố Đấm đất, cung vành ngoài đã vỡ / sắp vỡ, vết nứt, Bia Đá gốc.
static func draw_arena(ci: CanvasItem, world, art: bool) -> void:
	if world.map_id != "7-3" or world.map.arena == null:
		return
	var st = world.ch7
	var c: Vector2 = world.arena_pos
	var r: float = world.arena_r
	var t: float = world.time
	for i in 4:
		var a0 := i * TAU / 4.0
		var a1 := a0 + TAU / 4.0
		if st.broken[i]:
			_ring_sector(ci, c, Ch7.CORE_R, r + 4.0, a0, a1, SKY_LOW)
		elif st.sector_warn == i:
			_ring_sector(ci, c, Ch7.CORE_R, r, a0, a1, Color(1.0, 0.3, 0.2, 0.25 + 0.3 * absf(sin(t * 10.0))))
	ci.draw_arc(c, Ch7.CORE_R, 0.0, TAU, 64, Color(1, 1, 1, 0.25), 2.0, true)
	for h in st.holes:
		ci.draw_circle(h.pos, h.r, SKY_LOW)
		ci.draw_arc(h.pos, h.r, 0.0, TAU, 24, Color(1, 1, 1, 0.7), 3.0, true)
	for k in st.cracks:
		for j in 5:
			var a := j * TAU / 5.0
			ci.draw_line(k.pos, k.pos + Vector2.from_angle(a) * 60.0, Color(0.25, 0.2, 0.15, 0.6), 2.0)
	if world.is_boss_defeated("cu-than") and world.boss() == null:
		_env(ci, "stele-root", c, art, Color("#f4f4fa"))
		ci.draw_arc(c, Ch7.STELE_R, 0.0, TAU, 32, Color(1.0, 0.95, 0.7, 0.4 + 0.3 * sin(t * 3.0)), 2.0, true)


static func _ring_sector(ci: CanvasItem, c: Vector2, r0: float, r1: float, a0: float, a1: float, col: Color) -> void:
	var pts := PackedVector2Array()
	var n := 16
	for i in n + 1:
		pts.append(c + Vector2.from_angle(lerpf(a0, a1, float(i) / n)) * r1)
	for i in range(n, -1, -1):
		pts.append(c + Vector2.from_angle(lerpf(a0, a1, float(i) / n)) * r0)
	SpriteLib.poly(ci, pts, col)


## Lớp phủ: vòng báo (mưa đá, sấm sét), vệt sấm Kỳ Lân, Khiên trời, vòng báo đòn Cự Thần, rơi / Lông Vũ Gió.
static func draw_over(ci: CanvasItem, world, view: Rect2, _art: bool) -> void:
	if not Ch7.in_region(world):
		return
	var st = world.ch7
	var t: float = world.time
	for mk in st.marks:
		var k: float = 1.0 - mk.t / maxf(0.01, mk.total)
		ci.draw_circle(mk.pos, mk.r, Color(1.0, 0.95, 0.85, 0.12 + 0.2 * k))
		ci.draw_arc(mk.pos, mk.r * k, 0.0, TAU, 24, Color(1.0, 0.4, 0.3, 0.8), 2.0, true)
		ci.draw_arc(mk.pos, mk.r, 0.0, TAU, 24, Color(1.0, 0.9, 0.7, 0.8), 1.5, true)
	for tr in st.trails:
		var a: float = clampf(tr.ttl / Ch7.KY_TRAIL_TTL, 0.0, 1.0)
		ci.draw_circle(tr.pos, Ch7.KY_TRAIL_R, Color(0.6, 0.85, 1.0, 0.25 * a))
		ci.draw_line(tr.pos + Vector2(-10, -10), tr.pos + Vector2(6, 0), Color(0.9, 0.97, 1.0, 0.8 * a), 2.0)
		ci.draw_line(tr.pos + Vector2(6, 0), tr.pos + Vector2(-4, 12), Color(0.9, 0.97, 1.0, 0.8 * a), 2.0)
	for e in world.enemies:
		if e.dead:
			continue
		if float(st.shield_until.get(e.id, -1.0)) > t:
			ci.draw_arc(e.pos, e.radius + 10.0, PI, TAU, 20, Color(1.0, 0.9, 0.5, 0.85), 3.0, true)
		if e.kind == "cu-than" and e.state == "windup":
			var k2: float = 1.0 - e.timer / maxf(0.01, e.windup_total)
			match e.attack_kind:
				"slam":
					ci.draw_circle(e.target, Ch7.SLAM_R, Color(1.0, 0.3, 0.2, 0.18 + 0.25 * k2))
					ci.draw_arc(e.target, Ch7.SLAM_R * k2, 0.0, TAU, 32, Color(1.0, 0.3, 0.2, 0.9), 2.5, true)
				"hammer":
					ci.draw_circle(e.pos, Ch7.HAMMER_R, Color(0.8, 0.1, 0.05, 0.2 + 0.3 * k2))
					ci.draw_arc(e.pos, Ch7.HAMMER_R * k2, 0.0, TAU, 40, Color(1.0, 0.2, 0.1, 0.95), 3.0, true)
		if e.state == "windup" and e.attack_kind in ["lance", "clouddash"]:
			var len: float = Ch7.LANCE_LEN if e.attack_kind == "lance" else Ch7.DASH_LEN
			ci.draw_line(e.pos, e.pos + (e.target - e.pos).normalized() * len, Color(1.0, 0.35, 0.3, 0.45), Ch7.LANCE_HALF * 2.0)
		if e.state == "windup" and e.attack_kind == "rootlash":
			ci.draw_arc(e.pos, Ch7.ROOT_R + e.radius, 0.0, TAU, 32, Color(0.6, 1.0, 0.5, 0.8), 2.5, true)
	var p = world.player
	if st.hover > 0.0:
		ci.draw_arc(p.pos + Vector2(0, 8), 26.0, 0.0, TAU, 24, Color(0.85, 0.95, 1.0, 0.8), 2.0, true)
		for k in 3:
			var a2 := t * 6.0 + k * TAU / 3.0
			ci.draw_circle(p.pos + Vector2.from_angle(a2) * 24.0, 3.0, Color(1, 1, 1, 0.9))
	if st.fall_t > 0.0:
		var k3: float = 1.0 - st.fall_t / Ch7.FALL_TIME
		for j in 8:
			var a3 := j * TAU / 8.0 + k3 * 3.0
			ci.draw_circle(p.pos + Vector2.from_angle(a3) * (30.0 + k3 * 60.0) + Vector2(0, -k3 * 80.0), 16.0, Color(1, 1, 1, 0.85))


## Cây cảnh vùng 7: rừng treo / cột Thiên Cung.
static func decor_id(variant: int, ruins: bool) -> String:
	var ids: Array = ["sky-pillar-0", "tree-hanging-0", "sky-pillar-1", "cloud-puff-0", "tree-hanging-1"] if ruins \
		else ["tree-hanging-0", "cloud-puff-0", "tree-hanging-1", "tree-hanging-0", "cloud-puff-1"]
	var id: String = ids[variant % ids.size()]
	return id if SpriteLib.has_env(id) else "tree-pine"
