extends RefCounted
## SK2 (docs/13): vẽ hiệu ứng kỹ năng mới có thời gian tồn tại — Hoả Tường, Mưa Băng, Cầu Sấm.
## (Liên Trảm, Kiếm Vũ, Hống Kiếm, Dịch Chuyển dùng vòng nổ `blasts`; Tên Nảy / Cầu Sấm dùng tia `bolts`.)

const Skills2 = preload("res://scripts/core/skills2.gd")


static func draw(ci: CanvasItem, world) -> void:
	var st = world.sk2
	var t: float = world.time
	for wl in st.walls:
		var a: float = clampf(float(wl.ttl) / Skills2.HT_TIME * 2.0, 0.0, 1.0)
		var dir: Vector2 = (wl.b - wl.a).normalized()
		var n := 7
		for i in n:
			var p: Vector2 = wl.a + (wl.b - wl.a) * (float(i) + 0.5) / n
			var h: float = 18.0 + 8.0 * sin(t * 12.0 + i * 1.7)
			var side: Vector2 = dir * 7.0
			ci.draw_colored_polygon(PackedVector2Array([p - side, p + Vector2(0, -h), p + side]), Color(1.0, 0.45, 0.1, 0.75 * a))
			ci.draw_colored_polygon(PackedVector2Array([p - side * 0.5, p + Vector2(0, -h * 0.55), p + side * 0.5]), Color(1.0, 0.9, 0.5, 0.8 * a))
		ci.draw_line(wl.a, wl.b, Color(1.0, 0.4, 0.1, 0.35 * a), Skills2.HT_THICK, true)
	for z in st.ice:
		ci.draw_circle(z.pos, z.r, Color(0.6, 0.85, 1.0, 0.14))
		ci.draw_arc(z.pos, z.r, 0.0, TAU, 40, Color(0.75, 0.92, 1.0, 0.6), 2.0, true)
		for i in 8:
			var p2: Vector2 = z.pos + Vector2(fposmod(i * 37.0 + t * 90.0, z.r * 2.0) - z.r, fposmod(i * 53.0 + t * 160.0, z.r * 2.0) - z.r) * 0.8
			ci.draw_line(p2, p2 + Vector2(-2, 7), Color(0.85, 0.95, 1.0, 0.8), 1.5)
	for o in st.orbs:
		var k := 0.5 + 0.5 * sin(t * 18.0)
		ci.draw_circle(o.pos, 14.0 + 3.0 * k, Color(0.7, 0.55, 1.0, 0.25))
		ci.draw_circle(o.pos, 8.0, Color(0.85, 0.75, 1.0, 0.95))
		ci.draw_arc(o.pos, Skills2.CS_ZAP_R, 0.0, TAU, 32, Color(0.75, 0.6, 1.0, 0.25), 1.0, true)
