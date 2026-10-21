extends RefCounted
## M8 (docs/12): vẽ vùng 5 Núi Viêm Long — dung nham, núi lửa phun, Đá Nổi, vệt lửa, cột lửa, phun lửa, vòng lửa,
## mưa lông lửa, Cổng Trại. world_view.gd chỉ gọi draw_ground / draw_over / decor_id.

const SpriteLib = preload("res://scripts/view/sprite_lib.gd")
const Ch5 = preload("res://scripts/core/chapter5.gd")


static func _circle(c: Vector2, r: float, n := 28) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in n:
		pts.append(c + Vector2.from_angle(TAU * i / n) * r)
	return pts


## Lớp nền: hồ dung nham (sau nền đất, trước vật thể).
static func draw_ground(ci: CanvasItem, world, view: Rect2, art: bool) -> void:
	if not Ch5.in_region(world):
		return
	var t: float = world.time
	for z in world.map.get("lava", []):
		var c: Vector2 = z[0]
		var r: float = float(z[1])
		if not view.grow(r + Ch5.HEAT_R).has_point(c):
			continue
		ci.draw_circle(c, r + Ch5.HEAT_R, Color(1.0, 0.45, 0.1, 0.06))
		if not (art and SpriteLib.fill_polygon(ci, _circle(c, r), "tile-lava-%d" % (int(c.x) % 2))):
			ci.draw_circle(c, r, Color("#b3300c"))
		ci.draw_arc(c, r, 0.0, TAU, 40, Color(1.0, 0.8, 0.3, 0.55 + 0.2 * sin(t * 3.0 + c.x)), 3.0, true)
		# bọt dung nham
		for k in 4:
			var a: float = c.x * 0.01 + k * 1.7
			var bp: Vector2 = c + Vector2.from_angle(a) * r * (0.3 + 0.15 * k)
			var s: float = fposmod(t * 0.8 + k * 0.37, 1.0)
			ci.draw_circle(bp, 3.0 + 5.0 * s, Color(1.0, 0.85, 0.4, 0.6 * (1.0 - s)))
	# vệt lửa Thằn Lằn
	for tr in world.ch5.trails:
		var a3: float = clampf(tr.ttl / Ch5.TRAIL_TTL, 0.0, 1.0)
		ci.draw_circle(tr.pos, Ch5.TRAIL_R * (0.7 + 0.1 * sin(t * 9.0 + tr.pos.x)), Color(1.0, 0.5, 0.15, 0.35 * a3))
	# vòng lửa Bộ Hoả Ngục
	for g in world.ch5.rings:
		var a4: float = clampf(g.ttl / Ch5.RING_TTL, 0.0, 1.0)
		ci.draw_circle(g.pos, g.r, Color(1.0, 0.4, 0.1, 0.12 * a4))
		ci.draw_arc(g.pos, g.r, t * 2.0, t * 2.0 + TAU * 0.85, 32, Color(1.0, 0.6, 0.2, 0.7 * a4), 2.5, true)


## Long Huyệt (vẽ ngay sau nền hang): nền đỏ dần khi dung nham sắp dâng, ngập khi dâng; Đá Nổi.
static func draw_arena(ci: CanvasItem, world, art: bool) -> void:
	var t: float = world.time
	var b = world.boss()
	if world.map.arena != null and b != null and b.kind == "vien-long" and b.phase == 2:
		var warn: bool = Ch5.flood_warning(world)
		var flood: bool = world.ch5.flooding
		if warn or flood:
			var a2: float = 0.55 if flood else 0.15 + 0.15 * sin(t * 8.0)
			if not (art and flood and SpriteLib.fill_polygon(ci, _circle(world.arena_pos, world.arena_r, 48), "tile-lava-0", Color(1, 1, 1, 0.9))):
				ci.draw_circle(world.arena_pos, world.arena_r, Color(1.0, 0.35, 0.1, a2))
	if world.map.arena != null and world.map.arena.boss == "vien-long":
		for rp in Ch5.rocks(world):
			if art and SpriteLib.has_env("floating-rock"):
				SpriteLib.draw_env(ci, "floating-rock", rp, Color.WHITE, 1.5)
			else:
				ci.draw_circle(rp, Ch5.ROCK_R, Color("#45404c"))
			ci.draw_arc(rp, Ch5.ROCK_R, 0.0, TAU, 24, Color(1.0, 0.9, 0.6, 0.35), 1.5, true)


## Cây cối kiểu núi lửa: đá dung nham, cây cháy, miệng phun.
static func decor_id(variant: int) -> String:
	var id: String = ["rock-lava-0", "tree-ash-0", "rock-lava-1", "tree-ash-1", "vent"][variant % 5]
	return id if SpriteLib.has_env(id) else "rock-0"


## Lớp phủ: vòng báo thiên thạch, cột lửa, mưa lông lửa, phun lửa, Cổng Trại, cảnh báo.
static func draw_over(ci: CanvasItem, world, view: Rect2, art: bool) -> void:
	var st = world.ch5
	var t: float = world.time
	for m in st.meteors:
		var k: float = clampf(1.0 - m.t / Ch5.METEOR_WARN, 0.0, 1.0)
		ci.draw_circle(m.pos, Ch5.METEOR_R, Color(1.0, 0.25, 0.1, 0.12))
		ci.draw_circle(m.pos, Ch5.METEOR_R * k, Color(1.0, 0.3, 0.1, 0.3))
		ci.draw_arc(m.pos, Ch5.METEOR_R, 0.0, TAU, 32, Color(1.0, 0.4, 0.2, 0.8), 2.0, true)
		if m.t < 0.6:
			var fall: Vector2 = m.pos + Vector2(-40, -260) * (m.t / 0.6)
			if art and SpriteLib.has_env("fx-meteor"):
				SpriteLib.draw_env(ci, "fx-meteor", fall, Color.WHITE, 1.4)
			else:
				ci.draw_circle(fall, 8.0, Color("#ff9a3c"))
	for pl in st.pillars:
		var k2: float = clampf(1.0 - pl.t / (Ch5.PILLAR_GAP * Ch5.PILLARS), 0.0, 1.0)
		ci.draw_circle(pl.pos, Ch5.PILLAR_R, Color(1.0, 0.35, 0.1, 0.15 + 0.3 * k2))
		ci.draw_arc(pl.pos, Ch5.PILLAR_R, 0.0, TAU, 20, Color(1.0, 0.5, 0.2, 0.8), 2.0, true)
	for f in st.feathers:
		var k3: float = clampf(1.0 - f.t / Ch5.FEATHER_WARN, 0.0, 1.0)
		ci.draw_circle(f.pos, Ch5.FEATHER_R * k3, Color(1.0, 0.7, 0.3, 0.3))
		ci.draw_arc(f.pos, Ch5.FEATHER_R, 0.0, TAU, 20, Color(1.0, 0.7, 0.3, 0.7), 1.5, true)
	for br in st.breaths:
		var origin: Vector2 = world.player.pos
		if not br.player:
			var src = Ch5._enemy_by_id(world, int(br.id))
			if src == null:
				continue
			origin = src.pos
		var pts := PackedVector2Array([origin])
		for i in 9:
			pts.append(origin + Vector2.from_angle(float(br.ang) - float(br.arc) + 2.0 * float(br.arc) * i / 8.0) * float(br.range))
		ci.draw_colored_polygon(pts, Color(1.0, 0.45 + 0.15 * sin(t * 20.0), 0.1, 0.35))
	# Cổng Trại + thanh bền
	if st.siege:
		var g: Vector2 = Ch5.gate_pos(world)
		ci.draw_rect(Rect2(g + Vector2(-10, -60), Vector2(20, 120)), Color("#6a4a2a"))
		ci.draw_rect(Rect2(g + Vector2(-10, -60), Vector2(20, 120)), Color("#d4a83a"), false, 2.0)
		var pct: float = clampf(st.gate_hp / maxf(1.0, st.gate_max), 0.0, 1.0)
		ci.draw_rect(Rect2(g + Vector2(-40, -78), Vector2(80, 8)), Color(0, 0, 0, 0.6))
		ci.draw_rect(Rect2(g + Vector2(-40, -78), Vector2(80 * pct, 8)), Color("#ff9a3c") if pct > 0.3 else Color("#ff4a4a"))
	# trứng lửa Phượng Hoàng
	var r = world.rare_boss()
	if r != null and r.kind == "phuong-hoang" and st.egg_t > 0.0:
		ci.draw_circle(r.pos, 30.0 + 4.0 * sin(t * 10.0), Color(1.0, 0.5, 0.1, 0.5))
	# telegraph cho đòn riêng vùng 5
	for e in world.enemies:
		if e.dead or e.state != "windup":
			continue
		var prog: float = 1.0 - maxf(0.0, e.timer) / maxf(0.01, e.windup_total)
		match e.attack_kind:
			"fireburst":
				ci.draw_circle(e.pos, Ch5.BURST_R * prog, Color(1, 0.4, 0.1, 0.3))
				ci.draw_arc(e.pos, Ch5.BURST_R, 0.0, TAU, 32, Color(1, 0.4, 0.1, 0.8), 2.0, true)
			"hammer":
				ci.draw_circle(e.pos, Ch5.HAMMER_R * prog, Color(1, 0.3, 0.2, 0.3))
				ci.draw_arc(e.pos, Ch5.HAMMER_R, 0.0, TAU, 32, Color(1, 0.3, 0.2, 0.8), 2.0, true)
			"pdive", "firepillar":
				ci.draw_line(e.pos, e.pos + (e.target - e.pos).normalized() * (Ch5.DIVE_LEN if e.attack_kind == "pdive" else e.pos.distance_to(e.target)),
					Color(1, 0.5, 0.2, 0.25 + 0.5 * prog), 6.0, true)
			"dbreath":
				ci.draw_arc(e.pos, Ch5.DRAGON_BREATH_RANGE * prog, 0.0, TAU, 40, Color(1, 0.4, 0.1, 0.5), 2.0, true)
