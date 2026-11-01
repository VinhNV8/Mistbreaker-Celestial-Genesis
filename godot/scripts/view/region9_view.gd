extends RefCounted
## M12 (docs/18): vẽ vùng 9 Cổng Thiên Đạo — màu trời từng tầng theo hệ tầng, Cửa Tầng (đóng: hàng rào ánh sáng; mở: mờ),
## bệ Ấn Hệ, đấu trường Thiên Đạo Chi Môn (vành ngoài vỡ / sắp vỡ, 5 Đá Nổi, 3 Đèn Tinh Quang, dung nham, vòng báo,
## bóng thật của Ma Tôn khi phân thân, Giấc mơ), sương Hư Ảnh, vòng Thần Vực (endgame). world_view gọi draw_ground / draw_arena / draw_over.

const SpriteLib = preload("res://scripts/view/sprite_lib.gd")
const Ch9 = preload("res://scripts/core/chapter9.gd")
const Ch8 = preload("res://scripts/core/chapter8.gd")
const Endgame = preload("res://scripts/core/endgame.gd")
const Monsters = preload("res://scripts/data/monsters.gd")


static func draw_ground(ci: CanvasItem, world, view: Rect2, art: bool) -> void:
	if not Ch9.in_region(world):
		return
	var m: Dictionary = world.map
	var sz: Vector2 = world.world_size
	var doors: Array = m.get("doors9", [])
	var xs: Array = [0.0]
	for d in doors:
		xs.append(float(d.x))
	xs.append(sz.x)
	var base: int = Ch9.MAPS.find(world.map_id) * 3
	for i in xs.size() - 1:
		var el: String = Ch9.floor_element(world, base + i + 1)
		if el == "":
			continue
		var r := Rect2(Vector2(float(xs[i]), 0), Vector2(float(xs[i + 1]) - float(xs[i]), sz.y)).intersection(view.grow(20.0))
		if r.size.x > 0.0:
			ci.draw_rect(r, Color(Color(Monsters.ELEMENT_HEX[el]), 0.08))
	var t: float = world.time
	for i in doors.size():
		var dx: float = float(doors[i].x)
		if dx < view.position.x - 40.0 or dx > view.end.x + 40.0:
			continue
		var open: bool = Ch9.door_open(world, base + i + 1)
		var col := Color(1.0, 0.94, 0.7, 0.18) if open else Color(1.0, 0.85, 0.4, 0.55 + 0.15 * sin(t * 4.0))
		ci.draw_line(Vector2(dx, view.position.y), Vector2(dx, view.end.y), col, 10.0 if not open else 3.0)
		var gate: Vector2 = Vector2(dx, float(doors[i].y))
		if view.grow(80.0).has_point(gate):
			ci.draw_rect(Rect2(gate + Vector2(-14, -70), Vector2(28, 140)), Color(0.9, 0.8, 0.5, 0.35 if open else 0.8))
			ci.draw_string(ThemeDB.fallback_font, gate + Vector2(-60, -84), "Cửa Tầng %d%s" % [base + i + 1, "" if open else " — đóng"],
				HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(1, 0.95, 0.8))
	var seals: Array = m.get("seals9", [])
	for i in seals.size():
		var sp: Vector2 = seals[i]
		if not view.grow(60.0).has_point(sp):
			continue
		var ready: bool = Ch9.seal_ready(world, i)
		ci.draw_circle(sp + Vector2(0, 6), 22.0, Color(0, 0, 0, 0.3))
		ci.draw_rect(Rect2(sp + Vector2(-16, -14), Vector2(32, 18)), Color("#c8b88a"))
		if ready:
			var el: String = Ch9.floor_element(world, base + i + 1)
			var c := Color(Monsters.ELEMENT_HEX.get(el, "#fff0b0"))
			ci.draw_circle(sp + Vector2(0, -26 + 3.0 * sin(t * 3.0)), 10.0, c)
			ci.draw_arc(sp, Ch9.SEAL_PICK_R, 0.0, TAU, 24, Color(c, 0.5), 1.5, true)


static func draw_arena(ci: CanvasItem, world, art: bool) -> void:
	if not Ch9.in_region(world) or world.map.arena == null:
		return
	var st = world.ch9
	var c: Vector2 = world.arena_pos
	var r: float = world.arena_r
	var t: float = world.time
	for i in 4:
		var a0 := i * TAU / 4.0
		var a1 := a0 + TAU / 4.0
		if st.broken[i]:
			_ring_sector(ci, c, Ch9.CORE_R, r + 4.0, a0, a1, Color(0.05, 0.03, 0.08, 0.95))
		elif st.sector_warn == i:
			_ring_sector(ci, c, Ch9.CORE_R, r, a0, a1, Color(1.0, 0.3, 0.2, 0.25 + 0.3 * absf(sin(t * 10.0))))
	if st.lava_warn > 0.0:
		ci.draw_circle(c, r, Color(1.0, 0.4, 0.1, 0.10 + 0.12 * absf(sin(t * 8.0))))
	elif st.lava_t > 0.0:
		ci.draw_circle(c, r, Color(1.0, 0.35, 0.05, 0.45))
	for s in st.stones:
		ci.draw_circle(s, Ch9.STONE_R, Color("#5a4a3a"))
		ci.draw_arc(s, Ch9.STONE_R, 0.0, TAU, 20, Color("#c8a878"), 2.0, true)
	for l in st.lamps:
		if l.lit:
			ci.draw_circle(l.pos, Ch8.LAMP_R, Color(1.0, 0.95, 0.65, 0.12))
			ci.draw_arc(l.pos, Ch8.LAMP_R, 0.0, TAU, 32, Color(1.0, 0.92, 0.6, 0.5), 1.5, true)
		var id := "lamp-tinh-quang-lit" if l.lit else "lamp-tinh-quang"
		if art and SpriteLib.has_env(id):
			SpriteLib.draw_env(ci, id, l.pos, Color.WHITE, 1.4)
		else:
			ci.draw_circle(l.pos + Vector2(0, -40), 10.0, Color("#fff2b0") if l.lit else Color("#3a3448"))


static func draw_over(ci: CanvasItem, world, view: Rect2, _art: bool) -> void:
	var p = world.player
	var t: float = world.time
	var eg = world.eg
	if eg.tower:
		ci.draw_arc(eg.center, Endgame.TOWER_R, 0.0, TAU, 64, Color(1.0, 0.92, 0.6, 0.7), 3.0, true)
	if not Ch9.in_region(world):
		return
	var st = world.ch9
	for mk in st.marks:
		var k: float = 1.0 - mk.t / maxf(0.01, mk.total)
		var col := Color(str(mk.get("color", "#fff0b0")))
		ci.draw_circle(mk.pos, mk.r, Color(col, 0.12 + 0.2 * k))
		ci.draw_arc(mk.pos, mk.r * k, 0.0, TAU, 24, Color(1.0, 0.4, 0.3, 0.85), 2.0, true)
		ci.draw_arc(mk.pos, mk.r, 0.0, TAU, 24, Color(col, 0.8), 1.5, true)
	var b = Ch9._boss(world)
	if b != null:
		if st.clone_on:
			# chỉ bản thật có bóng (F1)
			ci.draw_circle(b.pos + Vector2(0, b.radius * 0.6), b.radius * 0.9, Color(0, 0, 0, 0.55))
		if st.dream_t > 0.0:
			var k2: float = 1.0 - st.dream_t / Ch9.DREAM_WINDUP
			ci.draw_arc(p.pos, 60.0 - 30.0 * k2, 0.0, TAU, 32, Color(0.7, 0.4, 1.0, 0.9), 3.0, true)
		if st.chan_t > 0.0:
			ci.draw_line(b.pos, p.pos, Color(0.85, 0.45, 1.0, 0.5 + 0.4 * sin(t * 20.0)), 5.0)
		if b.state == "windup" and b.attack_kind == "pounce9":
			ci.draw_circle(b.target, Ch9.POUNCE_R, Color(1.0, 0.3, 0.2, 0.25))
	if st.reverse_t > 0.0:
		ci.draw_arc(p.pos, 26.0, 0.0, TAU, 24, Color(0.7, 0.4, 1.0, 0.9), 2.5, true)
	for e in world.enemies:
		if e.dead or not view.grow(200.0).has_point(e.pos):
			continue
		if e.state == "windup":
			var k3: float = 1.0 - e.timer / maxf(0.01, e.windup_total)
			match e.attack_kind:
				"elemlance", "gallop", "dash9":
					var len: float = Ch9.GALLOP_LEN if e.attack_kind != "elemlance" else Ch9.LANCE_LEN + e.radius
					ci.draw_line(e.pos, e.pos + (e.target - e.pos).normalized() * len, Color(1.0, 0.35, 0.3, 0.3 + 0.3 * k3), 20.0)
				"roar9", "spin9":
					var rr: float = Ch9.ROAR_R if e.attack_kind == "roar9" else 90.0
					ci.draw_arc(e.pos, rr * k3, 0.0, TAU, 32, Color(1.0, 0.85, 0.4, 0.9), 2.5, true)
		if e.kind == "tan-hon" and e.elite and e.has_meta("swap_next"):
			ci.draw_arc(e.pos, e.radius + 12.0, 0.0, TAU, 24, Color(Monsters.ELEMENT_HEX[str(e.get_meta("swap_next"))]), 3.0, true)
	if Ch9.hu_anh_fog(world):
		var outer := view.grow(40.0)
		ci.draw_rect(outer, Color(0.9, 0.9, 1.0, 0.22))


static func _ring_sector(ci: CanvasItem, c: Vector2, r0: float, r1: float, a0: float, a1: float, col: Color) -> void:
	var pts := PackedVector2Array()
	var n := 16
	for i in n + 1:
		pts.append(c + Vector2.from_angle(lerpf(a0, a1, float(i) / n)) * r1)
	for i in range(n, -1, -1):
		pts.append(c + Vector2.from_angle(lerpf(a0, a1, float(i) / n)) * r0)
	SpriteLib.poly(ci, pts, col)


## Cây cảnh vùng 9: cột ngọc, mây vàng.
static func decor_id(variant: int) -> String:
	var id: String = ["heaven-pillar-0", "cloud-puff-0", "heaven-pillar-1", "cloud-puff-1"][variant % 4]
	return id if SpriteLib.has_env(id) else "bush"
