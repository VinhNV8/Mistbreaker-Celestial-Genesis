extends RefCounted
## M11 (docs/17): vẽ vùng 8 Vực Hư Vô — nền tối + sương tím, Cột Đá Hư Vô, Đèn Tinh Quang (vòng sáng 6 m, đèn tắt, tiến độ
## thắp / hồi), đèn Điện Giáo Chủ và ổ Hư Vô Thú, vòng báo, Tia hư vô / Tia nhìn, dây Hút Thiên phú, hướng mặt Quái Vật
## Không Mặt, mũi tên chỉ đèn khi Suy Thiên ≥ 30%. world_view.gd chỉ gọi draw_ground / draw_over.

const SpriteLib = preload("res://scripts/view/sprite_lib.gd")
const Ch8 = preload("res://scripts/core/chapter8.gd")

const LAMP_GLOW := Color(1.0, 0.95, 0.65, 0.10)
const LAMP_RING := Color(1.0, 0.92, 0.6, 0.45)
const VOID := Color(0.55, 0.3, 0.9)


static func draw_ground(ci: CanvasItem, world, view: Rect2, art: bool) -> void:
	if not Ch8.in_region(world):
		return
	var t: float = world.time
	# sương tím trôi sát nền
	for i in 36:
		var cp := view.position + Vector2(fposmod(i * 331.0 + t * (6.0 + (i % 4) * 3.0), view.size.x + 300.0) - 150.0, fposmod(i * 197.0, view.size.y))
		ci.draw_circle(cp, 50.0 + (i % 3) * 20.0, Color(0.35, 0.2, 0.55, 0.10))
	for s in world.map.get("stones8", []):
		_stone(ci, s, view, art)
	var ls: Array = Ch8.lamps(world)
	var st = world.ch8
	var quest_lamps: bool = world.map_id == "8-2" and Ch8.step(world) == Ch8.S_LAMPS
	for i in ls.size():
		var lp: Vector2 = ls[i]
		if not view.grow(Ch8.LAMP_R + 60.0).has_point(lp):
			continue
		var on: bool = Ch8.lamp_lit(world, i)
		_lamp(ci, lp, on, art, t)
		if not on and quest_lamps and i in world.map.get("lamps_off", []):
			var prog: float = clampf(float(st.light_t.get(i, 0.0)) / Ch8.LAMP_LIGHT, 0.0, 1.0)
			ci.draw_arc(lp, Ch8.LAMP_R, 0.0, TAU, 32, Color(1.0, 0.95, 0.7, 0.35), 1.5, true)
			if prog > 0.0:
				ci.draw_arc(lp, Ch8.LAMP_R, -PI / 2.0, -PI / 2.0 + TAU * prog, 32, Color(1.0, 0.95, 0.6, 0.95), 4.0, true)
	for l in st.lair:
		_lamp(ci, l.pos, l.lit, art, t)


static func _stone(ci: CanvasItem, s: Array, view: Rect2, art: bool) -> void:
	var c: Vector2 = s[0]
	var r: float = float(s[1])
	if not view.grow(r + 60.0).has_point(c):
		return
	ci.draw_circle(c + Vector2(6, 10), r, Color(0, 0, 0, 0.35))
	if art and SpriteLib.has_env("void-stone"):
		SpriteLib.draw_env(ci, "void-stone", c, Color.WHITE, r / 26.0)
	else:
		ci.draw_circle(c, r, Color("#2a2238"))
		ci.draw_arc(c, r, 0.0, TAU, 24, Color("#6a4a9a"), 2.0, true)


## Sau nền đấu trường: 4 Cột Đá và 4 Đèn Tinh Quang của Điện Giáo Chủ (không bị nền đấu trường phủ).
static func draw_arena(ci: CanvasItem, world, art: bool) -> void:
	if not Ch8.in_region(world) or world.map.arena == null:
		return
	var view := Rect2(world.arena_pos - Vector2.ONE * (world.arena_r + 100.0), Vector2.ONE * (world.arena_r + 100.0) * 2.0)
	for s in world.ch8.arena_stones:
		_stone(ci, s, view, art)
	for l in world.ch8.arena_lamps:
		_lamp(ci, l.pos, l.lit, art, world.time)


static func _lamp(ci: CanvasItem, pos: Vector2, on: bool, art: bool, t: float) -> void:
	if on:
		ci.draw_circle(pos, Ch8.LAMP_R, Color(LAMP_GLOW, LAMP_GLOW.a + 0.03 * sin(t * 3.0 + pos.x)))
		ci.draw_arc(pos, Ch8.LAMP_R, 0.0, TAU, 32, LAMP_RING, 1.5, true)
	var id := "lamp-tinh-quang-lit" if on else "lamp-tinh-quang"
	if art and SpriteLib.has_env(id):
		SpriteLib.draw_env(ci, id, pos, Color.WHITE, 1.4)
	else:
		ci.draw_rect(Rect2(pos + Vector2(-6, -44), Vector2(12, 44)), Color("#6a6070"))
		ci.draw_circle(pos + Vector2(0, -50), 11.0, Color("#fff2b0") if on else Color("#3a3448"))


static func draw_over(ci: CanvasItem, world, view: Rect2, _art: bool) -> void:
	if not Ch8.in_region(world):
		return
	var st = world.ch8
	var p = world.player
	var t: float = world.time
	for mk in st.marks:
		var k: float = 1.0 - mk.t / maxf(0.01, mk.total)
		ci.draw_circle(mk.pos, mk.r, Color(VOID, 0.12 + 0.2 * k))
		ci.draw_arc(mk.pos, mk.r * k, 0.0, TAU, 24, Color(0.9, 0.4, 1.0, 0.85), 2.0, true)
	for b in st.beams:
		ci.draw_line(b.from, b.to, Color(0.85, 0.5, 1.0, clampf(b.t / 0.3, 0.0, 1.0)), 8.0)
	for e in world.enemies:
		if e.dead or not view.grow(300.0).has_point(e.pos):
			continue
		if e.state == "windup":
			var k2: float = 1.0 - e.timer / maxf(0.01, e.windup_total)
			match e.attack_kind:
				"seal":
					ci.draw_circle(e.target, Ch8.SEAL_R, Color(VOID, 0.15 + 0.25 * k2))
					ci.draw_arc(e.target, Ch8.SEAL_R * k2, 0.0, TAU, 32, Color(0.9, 0.4, 1.0, 0.95), 2.5, true)
				"voidbeam":
					ci.draw_line(e.pos, e.pos + (e.target - e.pos).normalized() * Ch8.BEAM_LEN, Color(0.9, 0.4, 1.0, 0.3 + 0.3 * k2), Ch8.BEAM_HALF * 2.0)
				"heavycleave":
					_cone(ci, e.pos, e.face, Ch8.CLEAVE_ARC, Ch8.CLEAVE_R + e.radius, Color(1.0, 0.3, 0.4, 0.2 + 0.25 * k2))
				"jaw":
					_cone(ci, e.pos, e.face, Ch8.JAW_ARC, Ch8.JAW_R + e.radius, Color(1.0, 0.3, 0.4, 0.2 + 0.25 * k2))
				"sacrifice":
					ci.draw_arc(e.pos, Ch8.SACRIFICE_R * k2, 0.0, TAU, 32, Color(1.0, 0.35, 0.5, 0.9), 3.0, true)
				"devour":
					ci.draw_circle(e.pos, e.radius + 30.0 * k2, Color(0.1, 0.0, 0.2, 0.5))
		if e.kind == "mat-hu-vo":
			var g: Dictionary = Ch8.gaze_of(world, e)
			if float(g.get("lock", 0.0)) > 0.0:
				ci.draw_line(e.pos, p.pos, Color(1.0, 0.4, 0.9, 0.5), 1.5)
			elif float(g.get("beam", 0.0)) > 0.0:
				var to: Vector2 = p.pos
				if Ch8.blocked(world, e.pos, p.pos):
					to = e.pos + (p.pos - e.pos).normalized() * 40.0
				ci.draw_line(e.pos, to, Color(1.0, 0.35, 0.85, 0.85), 6.0)
		if e.kind == "giap-si-hu-vo" and e.elite:
			var f: float = float(e.get_meta("face8", 0.0))
			_cone(ci, e.pos, f, Ch8.FACELESS_FRONT, e.radius + 26.0, Color(0.8, 0.8, 0.9, 0.18))
		if e.has_meta("rage_until"):
			ci.draw_arc(e.pos, e.radius + 8.0, 0.0, TAU, 20, Color(1.0, 0.3, 0.5, 0.8), 2.0, true)
	var b2 = Ch8._boss(world)
	if b2 != null and st.chan_t > 0.0:
		var k3: float = 1.0 - st.chan_t / Ch8.DRAIN_CHANNEL
		ci.draw_line(b2.pos, p.pos, Color(0.85, 0.45, 1.0, 0.5 + 0.4 * sin(t * 20.0)), 3.0 + 4.0 * k3)
	if st.drain_t > 0.0:
		ci.draw_arc(p.pos + Vector2(0, 6), 22.0, 0.0, TAU, 20, Color(0.6, 0.3, 0.9, 0.8), 2.0, true)
	if st.lantern_t > 0.0:
		ci.draw_circle(p.pos, 30.0, Color(1.0, 0.95, 0.6, 0.12))
	# C8-11: mũi tên nhỏ chỉ đèn gần nhất khi Suy Thiên ≥ 30%
	if st.decay >= 0.3 and st.drain_t <= 0.0:
		var l: Vector2 = Ch8.nearest_lamp(world, p.pos)
		if l != Vector2.INF and l.distance_to(p.pos) > Ch8.LAMP_R:
			var dir: Vector2 = (l - p.pos).normalized()
			var tip: Vector2 = p.pos + dir * 56.0
			var n := dir.orthogonal() * 7.0
			SpriteLib.poly(ci, PackedVector2Array([tip, tip - dir * 14.0 + n, tip - dir * 14.0 - n]), Color(1.0, 0.92, 0.55, 0.9))


static func _cone(ci: CanvasItem, c: Vector2, ang: float, half: float, r: float, col: Color) -> void:
	var pts := PackedVector2Array([c])
	for i in 9:
		pts.append(c + Vector2.from_angle(ang - half + 2.0 * half * i / 8.0) * r)
	SpriteLib.poly(ci, pts, col)


## Cây cảnh vùng 8: cây chết, đá vụn (vực tối, không cây xanh).
static func decor_id(variant: int) -> String:
	var id: String = ["dead-tree-0", "rock-0", "dead-tree-1", "rock-1"][variant % 4]
	return id if SpriteLib.has_env(id) else "bush"
