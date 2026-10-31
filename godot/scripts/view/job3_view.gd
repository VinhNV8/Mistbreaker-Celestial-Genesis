extends RefCounted
## J3 (docs/23): vẽ chuyển chức 3 — hào quang trắng bạc dưới chân (J3-UI4), Nhất Kiếm (vệt báo trước + vệt chém),
## mũi tên sao, 5 cầu Ngũ Hành, khiên Bất Khuất. SH: thanh máu linh thú khi bị mất máu (SH-06).

const Job3 = preload("res://scripts/core/job3.gd")

const SILVER := Color("#f2f6ff")
const ORB_COLORS := [Color("#dce6f2"), Color("#6fdc7a"), Color("#4a9df8"), Color("#ff7a3a"), Color("#c9a45c")]


## Vẽ dưới nhân vật.
static func draw_under(ci: CanvasItem, world) -> void:
	if str(world.profile.job3) == "" or world.player.dead_timer > 0.0:
		return
	var pp: Vector2 = world.player.pos
	var k := 0.5 + 0.5 * sin(world.time * 2.5)
	ci.draw_circle(pp + Vector2(0, 8), 22.0 + 2.0 * k, Color(SILVER, 0.10))
	ci.draw_arc(pp + Vector2(0, 8), 22.0 + 2.0 * k, 0.0, TAU, 32, Color(SILVER, 0.35 + 0.2 * k), 1.5, true)


## Vẽ trên quái / nhân vật.
static func draw(ci: CanvasItem, world) -> void:
	var st = world.j3
	var p = world.player
	var t: float = world.time
	# Nhất Kiếm: vệt báo trước khi vung, vệt chém sáng khi xong.
	if not st.slash.is_empty():
		var to: Vector2 = p.pos + st.slash.dir * Job3.NK_LEN
		var prog: float = 1.0 - float(st.slash.t) / Job3.NK_WINDUP
		ci.draw_line(p.pos, to, Color(SILVER, 0.15 + 0.25 * prog), Job3.NK_HALF * 2.0, true)
		ci.draw_line(p.pos, p.pos + st.slash.dir * Job3.NK_LEN * prog, Color(SILVER, 0.7), 2.0, true)
	if not st.flash.is_empty():
		var a: float = clampf(float(st.flash.t) / 0.3, 0.0, 1.0)
		ci.draw_line(st.flash.from, st.flash.to, Color(SILVER, 0.35 * a), Job3.NK_HALF * 2.4, true)
		ci.draw_line(st.flash.from, st.flash.to, Color(1, 1, 1, 0.95 * a), 6.0, true)
	# Mũi tên sao đang rơi: vệt sáng từ trên xuống mục tiêu.
	for s in st.stars:
		var e = s.target
		if e == null or e.dead:
			continue
		var h: float = clampf(float(s.t) / Job3.STAR_FALL, 0.0, 1.5) * 160.0
		var head: Vector2 = e.pos + Vector2(-h * 0.35, -h)
		ci.draw_line(head + Vector2(-14, -40), head, Color(0.77, 0.89, 1.0, 0.6), 2.0, true)
		ci.draw_circle(head, 4.0, SILVER)
	# Ngũ Hành Luân Chuyển
	if st.orbs_t > 0.0:
		ci.draw_arc(p.pos, Job3.NH_R, 0.0, TAU, 40, Color(SILVER, 0.25), 1.2, true)
		for k in 5:
			var at: Vector2 = Job3.orb_pos(world, k)
			ci.draw_circle(at, Job3.NH_ORB + 3.0, Color(ORB_COLORS[k], 0.3))
			ci.draw_circle(at, Job3.NH_ORB * 0.7, ORB_COLORS[k])
			ci.draw_circle(at + Vector2(-3, -3), 2.5, Color(1, 1, 1, 0.9))
	# Bất Khuất: vòng trắng khi đang miễn sát thương.
	if world.cl2.immune_t > 0.0:
		ci.draw_arc(p.pos, 30.0 + 3.0 * sin(t * 12.0), 0.0, TAU, 32, Color(SILVER, 0.9), 3.0, true)
	# SH: thanh máu linh thú (chỉ khi mất máu)
	for a in world.allies:
		if a.dead or a.kind != "summon" or a.max_hp <= 0.0 or a.hp >= a.max_hp:
			continue
		var w := 26.0
		var at2: Vector2 = a.pos + Vector2(-w / 2.0, -a.radius * 2.0 - 14.0)
		ci.draw_rect(Rect2(at2, Vector2(w, 4)), Color(0, 0, 0, 0.6))
		ci.draw_rect(Rect2(at2, Vector2(w * clampf(a.hp / a.max_hp, 0.0, 1.0), 4)), Color("#5bd16a"))
