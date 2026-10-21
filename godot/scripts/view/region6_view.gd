extends RefCounted
## M9 (docs/14): vẽ vùng 6 Băng Nguyên Bắc Cực — lửa trại, Đèn Cực Quang, chậu lửa, mặt băng đóng, Bão tuyết, vòng báo,
## Đập băng, Bản Ngã Bóng Tối (bóng của người chơi), Gương Băng, đêm dài, viền băng giá, viền Ám Khí.
## world_view.gd chỉ gọi draw_ground / draw_props / draw_over / draw_enemy / decor_id.

const SpriteLib = preload("res://scripts/view/sprite_lib.gd")
const Ch6 = preload("res://scripts/core/chapter6.gd")


## Lớp nền (sau nền đất, trước vật thể): lửa, đèn, mặt băng, bão tuyết.
static func draw_ground(ci: CanvasItem, world, view: Rect2, art: bool) -> void:
	if not Ch6.in_region(world):
		return
	var t: float = world.time
	var st = world.ch6
	for g in st.patches:
		var a: float = clampf(g.ttl / Ch6.PATCH_TTL, 0.0, 1.0)
		ci.draw_circle(g.pos, Ch6.PATCH_R, Color(0.7, 0.9, 1.0, 0.35 * a))
		ci.draw_arc(g.pos, Ch6.PATCH_R, 0.0, TAU, 24, Color(0.9, 0.97, 1.0, 0.7 * a), 2.0, true)
	for b in st.blizzards:
		var a2: float = clampf(b.ttl, 0.0, 1.0)
		ci.draw_circle(b.pos, Ch6.BLIZZARD_R, Color(0.85, 0.92, 1.0, 0.12 * a2))
		ci.draw_arc(b.pos, Ch6.BLIZZARD_R, t * 2.0, t * 2.0 + TAU * 0.8, 40, Color(0.95, 0.98, 1.0, 0.6 * a2), 2.0, true)
		for k in 10:
			var ang: float = t * 3.0 + k * TAU / 10.0
			var rr: float = Ch6.BLIZZARD_R * fposmod(k * 0.37 + t * 0.4, 1.0)
			ci.draw_circle(b.pos + Vector2.from_angle(ang) * rr, 2.5, Color(1, 1, 1, 0.7 * a2))
	# bóng thật của Bản Ngã khi ẩn trong gương (chỉ tấm thật có bóng)
	var bn = Ch6._boss(world)
	if bn != null and bn.phase == 2:
		ci.draw_set_transform(bn.pos + Vector2(0, bn.radius * 0.9), 0.0, Vector2(1.0, 0.4))
		ci.draw_circle(Vector2.ZERO, bn.radius * 1.3, Color(0.05, 0.0, 0.1, 0.75))
		ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


## Lửa trại, chậu lửa, Đèn Cực Quang — vẽ sau nền trại (không bị nền trại che).
static func draw_props(ci: CanvasItem, world, view: Rect2, art: bool) -> void:
	if not Ch6.in_region(world):
		return
	var t: float = world.time
	var st = world.ch6
	for f in Ch6.fires(world):
		if not view.grow(Ch6.FIRE_R).has_point(f):
			continue
		ci.draw_circle(f, Ch6.FIRE_R, Color(1.0, 0.6, 0.2, 0.08 + 0.02 * sin(t * 5.0 + f.x)))
		ci.draw_arc(f, Ch6.FIRE_R, 0.0, TAU, 40, Color(1.0, 0.7, 0.3, 0.25), 1.5, true)
		if art and SpriteLib.has_env("campfire"):
			SpriteLib.draw_env(ci, "campfire", f, Color.WHITE, 1.2)
		else:
			ci.draw_circle(f, 10.0, Color("#ff9a3c"))
			ci.draw_circle(f + Vector2(0, -4), 6.0 + 2.0 * sin(t * 12.0), Color("#ffe08a"))
	var bs: Array = world.map.get("beacons", [])
	var lit: Array = world.profile.quest.get("beacons6", [])
	for i in bs.size():
		var bp: Vector2 = bs[i]
		if not view.grow(100.0).has_point(bp):
			continue
		var on: bool = i in lit
		var id := "beacon-lit" if on else "beacon"
		if art and SpriteLib.has_env(id):
			SpriteLib.draw_env(ci, id, bp, Color.WHITE, 1.4)
		else:
			ci.draw_rect(Rect2(bp + Vector2(-8, -40), Vector2(16, 40)), Color("#5a6a7a"))
			ci.draw_circle(bp + Vector2(0, -46), 10.0, Color("#7affc8") if on else Color("#3a4a5a"))
		if on:
			ci.draw_circle(bp, Ch6.FIRE_R, Color(0.45, 1.0, 0.8, 0.07))
		else:
			var prog: float = clampf(float(st.beacon_t.get(i, 0.0)) / Ch6.BEACON_TIME, 0.0, 1.0)
			ci.draw_arc(bp, Ch6.BEACON_R, 0.0, TAU, 32, Color(0.45, 1.0, 0.8, 0.35), 1.5, true)
			if prog > 0.0:
				ci.draw_arc(bp, Ch6.BEACON_R, -PI / 2.0, -PI / 2.0 + TAU * prog, 32, Color(0.45, 1.0, 0.8, 0.9), 4.0, true)


## Cây cối kiểu băng nguyên: thông phủ tuyết, đá băng, gò tuyết.
static func decor_id(variant: int) -> String:
	var id: String = ["tree-pine-snow-0", "rock-ice-0", "tree-pine-snow-1", "snow-mound", "rock-ice-1"][variant % 5]
	return id if SpriteLib.has_env(id) else "tree-pine"


## Bản Ngã: bóng của nhân vật (dáng lớp người chơi, đen tím, không mặt); Gương Băng. true = đã vẽ.
static func draw_enemy(ci, world, e) -> bool:
	if e.kind != "ban-nga" and e.kind != "guong-bang":
		return false
	var feet: Vector2 = ci._feet(e.pos, e.radius)
	var t: float = world.time
	var mirror: bool = e.kind == "guong-bang" or (e.phase == 2 and world.ch6.mirror_on)
	if mirror:
		var flash: float = 0.3 if e.hit_flash > 0.0 else 0.0
		if SpriteLib.has_env("ice-mirror"):
			SpriteLib.draw_env(ci, "ice-mirror", feet, Color(1.0 + flash, 1.0 + flash, 1.0 + flash), 1.6)
		else:
			ci.draw_rect(Rect2(e.pos + Vector2(-16, -34), Vector2(32, 56)), Color(0.75, 0.88, 1.0, 0.85))
			ci.draw_rect(Rect2(e.pos + Vector2(-16, -34), Vector2(32, 56)), Color("#e8f6ff"), false, 2.0)
		# bóng tối mờ thấp thoáng trong mọi tấm gương (khó phân biệt — chỉ nhìn bóng dưới chân)
		ci.draw_circle(e.pos + Vector2(0, -8), 9.0 + 1.5 * sin(t * 4.0 + e.id), Color(0.2, 0.05, 0.35, 0.55))
		return true
	var mod := Color(0.16, 0.08, 0.28, 0.95)
	if e.hit_flash > 0.0:
		mod = Color(0.6, 0.45, 0.85, 1.0)
	if world.ch6.shield_t > 0.0:
		ci.draw_arc(e.pos, e.radius + 10.0, 0.0, TAU, 32, Color(0.7, 0.45, 1.0, 0.8), 3.0, true)
	ci._ground_ring(feet, e.radius + 4.0, Color("#ff5470", 0.8))
	var anim := "attack" if e.state == "windup" else ("hurt" if e.state == "stunned" else "idle")
	SpriteLib.draw_hero(ci, world.profile.class_id, world.profile.look, anim, int(t * 3.0) % 2, feet, world.player.pos.x < e.pos.x, mod)
	# khói đen bốc lên
	for k in 4:
		var s: float = fposmod(t * 0.7 + k * 0.25, 1.0)
		ci.draw_circle(e.pos + Vector2(sin(k * 2.1 + t) * 10.0, -10.0 - 40.0 * s), 6.0 * (1.0 - s) + 2.0, Color(0.15, 0.05, 0.25, 0.5 * (1.0 - s)))
	return true


## Lớp phủ: vòng báo, Đập băng, cầu tuyết / Băng trụ, hơi thở, đêm, viền băng giá, viền Ám Khí.
static func draw_over(ci: CanvasItem, world, view: Rect2, _art: bool) -> void:
	if not Ch6.in_region(world):
		return
	var st = world.ch6
	var t: float = world.time
	for m in st.marks:
		var col := Color(m.get("color", "#9ad8ff"))
		var warn: float = 1.5
		var k: float = clampf(1.0 - m.t / warn, 0.0, 1.0)
		ci.draw_circle(m.pos, m.r, Color(col, 0.12))
		ci.draw_circle(m.pos, m.r * k, Color(col, 0.3))
		ci.draw_arc(m.pos, m.r, 0.0, TAU, 28, Color(col, 0.85), 2.0, true)
	for e in world.enemies:
		if e.dead or e.state != "windup":
			continue
		var prog: float = 1.0 - maxf(0.0, e.timer) / maxf(0.01, e.windup_total)
		match e.attack_kind:
			"snowball":
				ci.draw_circle(e.target, Ch6.SNOW_R * prog, Color(0.9, 0.95, 1.0, 0.35))
				ci.draw_arc(e.target, Ch6.SNOW_R, 0.0, TAU, 24, Color(0.9, 0.95, 1.0, 0.85), 2.0, true)
			"icepillar":
				ci.draw_circle(e.target, Ch6.PILLAR_R * prog, Color(0.45, 0.8, 1.0, 0.35))
				ci.draw_arc(e.target, Ch6.PILLAR_R, 0.0, TAU, 24, Color(0.45, 0.8, 1.0, 0.85), 2.0, true)
			"icecrack":
				for seg in Ch6.crack_lines(e):
					ci.draw_line(seg[0], seg[1], Color(0.75, 0.9, 1.0, 0.25 + 0.5 * prog), Ch6.CRACK_HALF * 2.0, true)
			"frostbreath":
				var a: float = (e.target - e.pos).angle()
				var pts := PackedVector2Array([e.pos])
				for i in 9:
					pts.append(e.pos + Vector2.from_angle(a - Ch6.ICE_BREATH_ARC + 2.0 * Ch6.ICE_BREATH_ARC * i / 8.0) * Ch6.ICE_BREATH_RANGE)
				ci.draw_colored_polygon(pts, Color(0.6, 0.85, 1.0, 0.15 + 0.25 * prog))
			"m_spin":
				ci.draw_circle(e.pos, (Ch6.M_SPIN_R + e.radius) * prog, Color(0.4, 0.2, 0.65, 0.3))
				ci.draw_arc(e.pos, Ch6.M_SPIN_R + e.radius, 0.0, TAU, 32, Color(0.7, 0.45, 1.0, 0.85), 2.0, true)
			"m_dash", "m_bolt":
				var to: Vector2 = e.pos + (e.target - e.pos).limit_length(Ch6.M_DASH_LEN if e.attack_kind == "m_dash" else 300.0)
				ci.draw_line(e.pos, to, Color(0.7, 0.45, 1.0, 0.25 + 0.5 * prog), 8.0 if e.attack_kind == "m_dash" else 4.0, true)
	# Đêm dài: tối quanh người chơi theo tầm nhìn 60%.
	var c: Vector2 = world.player.pos
	if Ch6.is_night(world):
		var inner: float = 520.0 * Ch6.vision(world)
		ci.draw_rect(view, Color(0.02, 0.04, 0.12, 0.3))
		for i in 6:
			ci.draw_arc(c, inner + i * 60.0, 0.0, TAU, 64, Color(0.02, 0.04, 0.12, 0.14 + i * 0.06), 60.0, false)
		# cực quang trên Đỉnh Cực Quang
		if world.map_id == "6-3":
			for k in 3:
				var y: float = view.position.y + 40.0 + k * 26.0
				var pts2 := PackedVector2Array()
				for i in 24:
					var x: float = view.position.x + view.size.x * i / 23.0
					pts2.append(Vector2(x, y + sin(x * 0.004 + t * 0.6 + k) * 22.0))
				ci.draw_polyline(pts2, Color(0.4, 1.0, 0.7, 0.18), 14.0, true)
	# viền băng giá theo tầng
	if st.frost > 0:
		var a3: float = 0.06 * st.frost
		for i in 4:
			ci.draw_rect(view.grow(-i * 22.0), Color(0.75, 0.9, 1.0, a3 * (1.0 - i * 0.22)), false, 22.0)
	# Ám Khí: viền tím khi sắp / đang mất kiểm soát; vòng tối quanh người chơi khi Ám Hoá
	if st.lost_t > 0.0 or st.dark_warn >= 0.0:
		var a4: float = 0.25 + 0.1 * sin(t * 10.0)
		for i in 4:
			ci.draw_rect(view.grow(-i * 26.0), Color(0.35, 0.1, 0.55, a4 * (1.0 - i * 0.2)), false, 26.0)
	if st.lost_t > 0.0 or st.ascend_t > 0.0:
		ci.draw_arc(c, 34.0 + 3.0 * sin(t * 8.0), 0.0, TAU, 32, Color(0.6, 0.25, 0.95, 0.8), 3.0, true)
