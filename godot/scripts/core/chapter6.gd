extends RefCounted
## M9 — Chương 6 Băng Nguyên Vĩnh Dạ (docs/14-chuong-6.md). Gắn vào GameWorld qua core/chapters.gd (D38).
## Gồm: băng giá (tầng, đông cứng), đêm dài, mặt băng trơn, Than Hồng; quái vùng 6; Bản Ngã Bóng Tối (sao chép kỹ năng,
## Gương vỡ, Thiên phú phản chiếu); Long Băng Bắc Cực; Bộ Cực Quang, Gương Bản Ngã, Vảy Long Băng, Kính Ảnh (Đạo Tặc);
## Đèn Cực Quang; Ám Khí — mất kiểm soát / Ám Hoá; nhiệm vụ chương 6.

const Classes = preload("res://scripts/data/classes.gd")
const Story = preload("res://scripts/data/story.gd")
const Talents = preload("res://scripts/data/talents.gd")
const Items = preload("res://scripts/core/items.gd")
const Explore = preload("res://scripts/core/explore.gd")
const Ch4 = preload("res://scripts/core/chapter4.gd")

const MAPS := ["6-1", "6-2", "6-3"]
const NPCS := ["tuyet-nga", "lao-han", "lam-nhi-6"]
const HOOKS := ["on_load", "tick", "check_quest", "after_spawn", "on_kill", "update_enemy", "chase", "perform", "elite_skill",
	"update_rare", "boss_phase_two", "copy_skill", "adjust_damage", "hit_mult", "derive_bonus", "move_mult", "input_move",
	"input_filter", "drink", "player_hurt", "vanish", "is_hidden", "map_requirement", "gate_open", "env_text", "env_alert", "quest_hud"]

# ---------------------------------------------------------------- C6-10…13: môi trường
const FROST_MAX := 5
const FROST_STILL := 2.0
const FROST_MOVE := 1.5
const FROST_WARM := 0.5
const FROST_SLOW := 0.10
const FREEZE_TIME := 1.5
const FREEZE_IMMUNE := 3.0
const FIRE_R := 80.0
const MOVING_SPEED := 20.0
const CYCLE := 480.0
const DAY := 120.0
const NIGHT_VISION := 0.6
const SLIDE_TIME := 0.3
const EMBER_IMMUNE := 30.0
const EMBER_MIN := 2
const SHOP_EMBER := 100
# ---------------------------------------------------------------- C6-20…25: quái
const PACK := 4
const SNOW_R := 30.0
const SNOW_MUL := 1.3
const PILLAR_R := 40.0
const PILLAR_MUL := 1.1
const PILLAR_FREEZE := 1.0
const ARROW_SPEED := 460.0
const CRACK_CD := 10.0
const CRACK_LEN := 150.0
const CRACK_HALF := 12.0
const CRACK_SPREAD := deg_to_rad(25.0)
const CRACK_MUL := 1.8
const BLIZZARD_CD := 15.0
const BLIZZARD_R := 140.0
const BLIZZARD_TIME := 6.0
# ---------------------------------------------------------------- C6-30: Bản Ngã Bóng Tối
const COPY_DELAY := 3.0
const COPY_DELAY_P3 := 2.0
const COPY_WINDUP := 0.6
const M_SPIN_R := 55.0
const M_SPIN_MUL := 1.3
const M_DASH_LEN := 250.0
const M_DASH_MUL := 1.5
const M_BOLT_MUL := 1.2
const M_BOLT_SPEED := 420.0
const M_RAIN_R := 27.5
const M_RAIN_WARN := 1.0
const M_RAIN_MUL := 1.0
const M_METEOR_R := 45.0
const M_METEOR_WARN := 1.2
const M_METEOR_MUL := 1.8
const M_TRAP_R := 20.0
const M_TRAP_WARN := 1.5
const M_TRAP_MUL := 1.0
const M_TRAP_ROOT := 1.0
const M_SHIELD_TIME := 3.0
const M_SHIELD_CUT := 0.3
const M_HASTE_TIME := 5.0
const HASTE_RECOVER := 0.3
## kỹ năng người chơi → bản bóng tối (C6-30a); id lạ = Tia bóng.
const MIRROR_OF := {"spin": "m_spin", "nova": "m_spin", "dash": "m_dash", "wave": "m_bolt", "pierce": "m_bolt", "chain": "m_bolt",
	"fireball": "m_bolt", "rain": "m_rain", "meteor": "m_meteor", "trap": "m_trap", "guard": "m_shield", "barrier": "m_shield",
	"eagle": "m_haste"}
const MIRRORS := 4
const MIRROR_RING := 0.6
const MIRROR_BOLT_CD := 2.5
const MIRROR_BOLT_FAKE := 0.5
const MIRROR_REFLECT := 0.5
const MIRROR_REFLECT_CAP := 0.04
## các gương giả phản tối đa 1 lần mỗi giây (đòn nhiều phát như tên, Mưa Tên, Lôi Xích không dồn chết ngay)
const MIRROR_REFLECT_CD := 1.0
const MIRROR_SHUFFLE := 0.10
## chuyển cảnh bất tử ngắn (cố định — cộng như nhau cho mọi lớp): vỡ gương, mỗi lần xoay gương, vào giai đoạn 3
const SHATTER_TIME := 3.5
const SHUFFLE_TIME := 2.5
const P3_INTRO := 3.0
const P3_COMBAT_ATK := 1.3
const P3_OTHER_ATK := 1.2
const P3_OTHER_SPEED := 1.25
const P3_PULSE := 8.0
const P3_SLOW := 2.0
const P3_SUMMON := 12.0
const P3_SUMMON_HP := 0.08
const BRAZIER_RING := 0.85
# ---------------------------------------------------------------- C6-33: Long Băng
const ICE_BREATH_CD := 9.0
const ICE_BREATH_RANGE := 200.0
const ICE_BREATH_ARC := deg_to_rad(45.0)
const ICE_BREATH_MUL := 0.8
const PATCH_R := 45.0
const PATCH_TTL := 3.0
const PATCH_TICK := 0.5
const ICE_RAIN_CD := 7.0
const ICE_RAIN_N := 15
const ICE_RAIN_R := 30.0
const ICE_RAIN_SPREAD := 160.0
const ICE_RAIN_WARN := 1.2
const ICE_RAIN_MUL := 1.2
const BITE_MUL := 1.2
# ---------------------------------------------------------------- đồ, bộ, Kính Ảnh
const CUC_QUANG := "cuc_quang"
const CQ_CRIT := 0.10
const CQ_SLOW := 2.0
const MIRROR_CHARM_CHANCE := 0.10
const MIRROR_CHARM_PCT := 0.5
const MIRROR_CHARM_R := 60.0
const SCALE_SPEED := 1.15
const CLONE_TTL := 8.0
const CLONE_ATK := 0.5
# ---------------------------------------------------------------- C6-41…43: Đèn Cực Quang, Ám Khí
const BEACON_R := 60.0
const BEACON_TIME := 2.0
const DARK_COMBAT := 2.0
const DARK_KILL := 5.0
const DARK_FIRE := 10.0
const DARK_WARN := 2.0
const DARK_LOST := 4.0
const DARK_LOST_ATK := 1.4
const DARK_ASCEND := 6.0
const DARK_ASCEND_ATK := 1.2
const DARK_STEPS := 3


class State:
	var frost := 0
	var still_t := 0.0
	var move_t := 0.0
	var warm_t := 0.0
	var frost_immune := 0.0
	var ember_until := -99.0
	var last_pos := Vector2.ZERO
	var slide_v := Vector2.ZERO
	var slide_from := -99.0
	## [{pos, r, t, atk, mul, root}] — vòng báo dưới đất (cầu tuyết, Mưa băng, bản bóng tối)
	var marks: Array = []
	## [{pos, ttl, acc}] — Bão tuyết
	var blizzards: Array = []
	## [{pos, ttl, acc}] — mặt băng đóng (Hơi thở vĩnh đông)
	var patches: Array = []
	## Bản Ngã: [{id, t}] kỹ năng chờ dùng lại; hồi chiêu kỹ năng người chơi ở khung trước
	var copies: Array = []
	var last_cds: Array = [0.0, 0.0, 0.0, 0.0]
	var mirror_on := false
	var mirror_slot := 0
	var mirror_taken := 0.0
	var reshuffle := false
	## id quái → giây tới Tia bóng kế tiếp
	var bolt_cd := {}
	## thời điểm gương giả được phản lần kế tiếp
	var reflect_at := -99.0
	var shield_t := 0.0
	var haste_t := 0.0
	## Bản Ngã bất tử trong chuyển cảnh (vỡ gương / xoay gương / Thiên phú phản chiếu)
	var invuln_t := 0.0
	var p3_group := ""
	var p3_form := ""
	var pulse_t := 0.0
	var summon_t := 0.0
	## Đèn Cực Quang: chỉ số đèn → giây đã đứng cạnh
	var beacon_t := {}
	## Ám Khí
	var dark := 0.0
	var dark_warn := -1.0
	var lost_t := 0.0
	var ascend_t := 0.0
	var awaken_said := false


static func ensure(w) -> void:
	var q: Dictionary = w.profile.quest
	for k in ["ch6", "kills6", "dark6"]:
		if not q.has(k):
			q[k] = 0
	if not q.has("beacons6"):
		q["beacons6"] = []


static func in_region(w) -> bool:
	return int(w.map.get("region", 1)) == 6


static func step(w) -> int:
	ensure(w)
	return int(w.profile.quest.ch6)


# ================================================================ môi trường


static func is_night(w) -> bool:
	return in_region(w) and bool(w.map.get("night", false)) and fposmod(float(w.profile.play_seconds), CYCLE) >= DAY


## C6-11: tầm nhìn 0–1 cho view.
static func vision(w) -> float:
	return NIGHT_VISION if is_night(w) else 1.0


static func braziers(w) -> Array:
	var out: Array = []
	if w.map.arena == null or str(w.map.arena.boss) != "ban-nga":
		return out
	for i in 4:
		out.append(w.arena_pos + Vector2.from_angle(TAU * i / 4.0 + PI / 4.0) * (w.arena_r * BRAZIER_RING))
	return out


## Mọi nguồn lửa sưởi: lửa trại của map, Đèn Cực Quang đã thắp, chậu lửa trong hang Bản Ngã.
static func fires(w) -> Array:
	var out: Array = []
	for f in w.map.get("fires", []):
		out.append(f)
	var lit: Array = w.profile.quest.get("beacons6", [])
	var bs: Array = w.map.get("beacons", [])
	for i in bs.size():
		if i in lit:
			out.append(bs[i])
	out.append_array(braziers(w))
	return out


static func near_fire(w, pos: Vector2) -> bool:
	for f in fires(w):
		if pos.distance_to(f) <= FIRE_R:
			return true
	return false


static func frost_immune(w) -> bool:
	var st = w.ch6
	return st.frost_immune > 0.0 or w.time < st.ember_until or w.has_unique("vay_long_bang")


## Cộng tầng băng giá; đủ 5 tầng → đông cứng 1,5 giây rồi miễn 3 giây.
static func add_frost(w, n: int) -> void:
	var st = w.ch6
	var p = w.player
	if frost_immune(w) or p.dead_timer > 0.0 or n <= 0:
		return
	st.frost += n
	if st.frost >= FROST_MAX:
		st.frost = 0
		st.still_t = 0.0
		p.stun_timer = maxf(p.stun_timer, FREEZE_TIME)
		st.frost_immune = FREEZE_TIME + FREEZE_IMMUNE
		w._text(p.pos + Vector2(0, -40), "Đông cứng!", Color("#9ad8ff"), true)
		w._sfx("hit")


static func _set_count(w) -> int:
	return int(Items.equipment_bonus(w.profile.equipment).sets.get(CUC_QUANG, 0))


static func move_mult(w) -> float:
	var k := 1.0
	if w.has_unique("vay_long_bang"):
		k *= SCALE_SPEED
	var st = w.ch6
	if st.frost > 0 and not (st.frost < 3 and _set_count(w) >= 2):
		k *= 1.0 - FROST_SLOW * st.frost
	return k


## C6-12: mặt băng trơn — thả phím vẫn trượt 0,3 giây theo hướng cũ.
static func input_move(w, v: Vector2) -> Vector2:
	if not in_region(w) or not bool(w.map.get("frost", false)):
		return v
	var st = w.ch6
	var p = w.player
	if v.length() > 0.01:
		st.slide_v = v
		st.slide_from = w.time
		return v
	var left: float = SLIDE_TIME - (w.time - st.slide_from)
	if left <= 0.0 or p.dodge_time > 0.0 or p.dash_time > 0.0 or p.root_timer > 0.0 or p.stun_timer > 0.0:
		return v
	return st.slide_v * (left / SLIDE_TIME)


static func on_load(w) -> void:
	ensure(w)
	var st = w.ch6
	st.frost = 0
	st.still_t = 0.0
	st.move_t = 0.0
	st.marks = []
	st.blizzards = []
	st.patches = []
	st.copies = []
	st.bolt_cd = {}
	st.beacon_t = {}
	st.mirror_on = false
	st.reshuffle = false
	st.shield_t = 0.0
	st.haste_t = 0.0
	st.p3_group = ""
	st.dark_warn = -1.0
	st.lost_t = 0.0
	st.last_pos = w.player.pos
	st.awaken_said = false
	if in_region(w) and step(w) == 0:
		w.profile.quest.ch6 = 1
		w.say("r6_arrive")


static func tick(w, dt: float) -> void:
	ensure(w)
	var st = w.ch6
	var p = w.player
	st.frost_immune -= dt
	st.shield_t -= dt
	st.haste_t -= dt
	st.invuln_t -= dt
	st.ascend_t -= dt
	if not in_region(w):
		st.frost = 0
		st.lost_t = 0.0
		st.dark_warn = -1.0
		st.last_pos = p.pos
		return
	var alive: bool = p.dead_timer <= 0.0
	var moved: float = p.pos.distance_to(st.last_pos)
	st.last_pos = p.pos
	if alive and bool(w.map.get("frost", false)):
		_tick_frost(w, dt, moved > MOVING_SPEED * dt or p.dodge_time > 0.0 or p.dash_time > 0.0)
	_tick_marks(w, dt)
	_tick_zones(w, dt)
	_tick_beacons(w, dt)
	_tick_dark(w, dt)
	_tick_shadow(w, dt)


static func _tick_frost(w, dt: float, moving: bool) -> void:
	var st = w.ch6
	if near_fire(w, w.player.pos):
		st.still_t = 0.0
		st.warm_t += dt
		if st.warm_t >= FROST_WARM:
			st.warm_t = 0.0
			st.frost = maxi(0, st.frost - 1)
		return
	st.warm_t = 0.0
	if frost_immune(w):
		st.frost = 0
		st.still_t = 0.0
		return
	if moving:
		st.still_t = 0.0
		st.move_t += dt
		if st.move_t >= FROST_MOVE:
			st.move_t = 0.0
			st.frost = maxi(0, st.frost - 1)
	else:
		st.move_t = 0.0
		st.still_t += dt
		if st.still_t >= FROST_STILL:
			st.still_t -= FROST_STILL
			add_frost(w, 1)


static func _tick_marks(w, dt: float) -> void:
	var st = w.ch6
	var p = w.player
	for m in st.marks:
		m.t -= dt
		if m.t <= 0.0:
			w._blast(m.pos, m.r, Color(m.get("color", "#9ad8ff")))
			if p.dead_timer <= 0.0 and p.pos.distance_to(m.pos) <= float(m.r) + w.PLAYER_RADIUS:
				w._incoming_el = str(m.get("el", "thuy"))
				if w._damage_player(float(m.atk), float(m.mul)):
					if float(m.get("root", 0.0)) > 0.0:
						p.root_timer = maxf(p.root_timer, float(m.root))
					if float(m.get("freeze", 0.0)) > 0.0:
						p.stun_timer = maxf(p.stun_timer, float(m.freeze))
						w._text(p.pos + Vector2(0, -40), "Đóng băng!", Color("#9ad8ff"), true)
	st.marks = st.marks.filter(func(m): return m.t > 0.0)


static func _tick_zones(w, dt: float) -> void:
	var st = w.ch6
	var p = w.player
	for b in st.blizzards:
		b.ttl -= dt
		if p.pos.distance_to(b.pos) <= BLIZZARD_R:
			b.acc += dt
			if b.acc >= 1.0:
				b.acc -= 1.0
				add_frost(w, 1)
	st.blizzards = st.blizzards.filter(func(b): return b.ttl > 0.0)
	for g in st.patches:
		g.ttl -= dt
		if p.pos.distance_to(g.pos) <= PATCH_R + w.PLAYER_RADIUS * 0.5:
			g.acc += dt
			if g.acc >= PATCH_TICK:
				g.acc -= PATCH_TICK
				add_frost(w, 1)
	st.patches = st.patches.filter(func(g): return g.ttl > 0.0)


static func add_mark(w, pos: Vector2, r: float, t: float, atk: float, mul: float, extra := {}) -> void:
	var m := {"pos": pos, "r": r, "t": t, "atk": atk, "mul": mul}
	m.merge(extra)
	w.ch6.marks.append(m)


# ================================================================ quái


static func after_spawn(w, e) -> void:
	# C6-20: Sói Băng đi bầy 4 con.
	if e.kind == "soi-bang" and not e.elite and e.role == "field":
		for i in PACK - 1:
			var m = w.spawn_enemy("soi-bang", e.level, e.pos + Vector2.from_angle(i * TAU / 3.0 + 0.4) * 36.0, {"role": "pack"})
			m.home = e.home


static func perform(w, e) -> bool:
	var p = w.player
	var reach: float = e.radius + e.attack_range + w.PLAYER_RADIUS + 10.0
	match e.attack_kind:
		"frostbite":
			if e.pos.distance_to(p.pos) <= reach and w._damage_player(e.atk, 1.0):
				add_frost(w, 1)
		"icebite":
			if e.pos.distance_to(p.pos) <= reach and w._damage_player(e.atk, BITE_MUL):
				add_frost(w, 1)
		"snowball":
			w._blast(e.target, SNOW_R, Color("#e8eef6"))
			if p.pos.distance_to(e.target) <= SNOW_R + w.PLAYER_RADIUS:
				w._damage_player(e.atk, SNOW_MUL)
		"icepillar":
			w._blast(e.target, PILLAR_R, Color("#7ad0ff"))
			if p.pos.distance_to(e.target) <= PILLAR_R + w.PLAYER_RADIUS and w._damage_player(e.atk, PILLAR_MUL):
				p.stun_timer = maxf(p.stun_timer, PILLAR_FREEZE)
				w._text(p.pos + Vector2(0, -40), "Đóng băng!", Color("#9ad8ff"), true)
		"icearrow":
			w._enemy_shot(e, (e.target - e.pos).angle(), 1.0, ARROW_SPEED)
		"icecrack":
			for seg in crack_lines(e):
				w._blast(seg[1], 22.0, Color("#bfe6ff"))
			for seg in crack_lines(e):
				if Geometry2D.get_closest_point_to_segment(p.pos, seg[0], seg[1]).distance_to(p.pos) <= CRACK_HALF + w.PLAYER_RADIUS:
					w._damage_player(e.atk, CRACK_MUL)
					break
		"frostbreath":
			var dir: float = (e.target - e.pos).angle()
			var off: Vector2 = p.pos - e.pos
			if off.length() <= ICE_BREATH_RANGE + e.radius + w.PLAYER_RADIUS and absf(angle_difference(dir, off.angle())) <= ICE_BREATH_ARC:
				w._damage_player(e.atk, ICE_BREATH_MUL)
			for pair in [[70.0, -0.4], [70.0, 0.4], [140.0, -0.3], [140.0, 0.3], [200.0, 0.0]]:
				w.ch6.patches.append({"pos": e.pos + Vector2.from_angle(dir + float(pair[1])) * float(pair[0]), "ttl": PATCH_TTL, "acc": 0.0})
			w._text(e.pos + Vector2(0, -e.radius - 24), "Hơi thở vĩnh đông!", Color("#9ad8ff"), true)
		"m_spin":
			var r: float = M_SPIN_R + e.radius
			w._blast(e.pos, r, Color("#6a3aa8"))
			if e.pos.distance_to(p.pos) <= r + w.PLAYER_RADIUS:
				w._damage_player(e.atk, M_SPIN_MUL)
		"m_dash":
			var from: Vector2 = e.pos
			var to: Vector2 = w._clamp_to_arena(e.pos + (e.target - e.pos).limit_length(M_DASH_LEN), e.radius)
			e.pos = to
			if Geometry2D.get_closest_point_to_segment(p.pos, from, to).distance_to(p.pos) <= e.radius + w.PLAYER_RADIUS:
				w._damage_player(e.atk, M_DASH_MUL)
		"m_bolt":
			w._enemy_shot(e, (e.target - e.pos).angle(), M_BOLT_MUL, M_BOLT_SPEED)
		_:
			return false
	return true


## Đập băng: 3 đường [điểm đầu, điểm cuối] từ quái về phía điểm đánh dấu, lệch ±25°.
static func crack_lines(e) -> Array:
	var out: Array = []
	var a: float = (e.target - e.pos).angle()
	for k in [-1, 0, 1]:
		out.append([e.pos, e.pos + Vector2.from_angle(a + k * CRACK_SPREAD) * CRACK_LEN])
	return out


static func elite_skill(w, e, kind: String) -> bool:
	match kind:
		"icecrack":
			e.skill_cd = CRACK_CD
			w._begin_attack(e, "icecrack", 1.0)
			w._text(e.pos + Vector2(0, -e.radius - 24), "Đập băng!", Color("#bfe6ff"), true)
			return true
		"blizzard":
			e.skill_cd = BLIZZARD_CD
			w.ch6.blizzards.append({"pos": w.player.pos, "ttl": BLIZZARD_TIME, "acc": 0.0})
			w._text(e.pos + Vector2(0, -e.radius - 24), "Bão tuyết!", Color("#dfefff"), true)
			return true
	return false


static func chase(w, e, d: float, _dt: float) -> bool:
	if e.kind != "long-bang":
		return false
	e.skill_cd -= _dt
	e.pounce_cd -= _dt
	if e.pounce_cd <= 0.0 and d < ICE_BREATH_RANGE + 40.0:
		e.pounce_cd = ICE_BREATH_CD
		w._begin_attack(e, "frostbreath", 0.8)
		return true
	if e.skill_cd <= 0.0:
		e.skill_cd = ICE_RAIN_CD
		for i in ICE_RAIN_N:
			var pos: Vector2 = w.player.pos + Vector2.from_angle(w._r() * TAU) * (w._r() * ICE_RAIN_SPREAD)
			add_mark(w, pos, ICE_RAIN_R, ICE_RAIN_WARN, e.atk, ICE_RAIN_MUL)
		w._text(e.pos + Vector2(0, -e.radius - 24), "Mưa băng!", Color("#9ad8ff"), true)
	return false


static func update_rare(_w, e, _dt: float) -> bool:
	return e.kind == "long-bang"


static func on_kill(w, e) -> void:
	ensure(w)
	if in_region(w) and step(w) == 2 and e.role in ["field", "pack", "nestMinion", "nestGuard"]:
		w.profile.quest.kills6 = int(w.profile.quest.kills6) + 1
	if dark_active(w) and e.role != "bossMinion":
		w.ch6.dark = minf(100.0, w.ch6.dark + DARK_KILL)


## Gương Băng và Ảnh Bóng không cho EXP/đồ.
static func vanish(w, e) -> bool:
	if e.kind == "guong-bang" or e.kind == "anh-bong":
		w._blast(e.pos, 20.0, Color("#6a3aa8"))
		return true
	return false


# ================================================================ Bản Ngã Bóng Tối


## Gương vỡ: cả 4 tấm (kể cả tấm thật) không bị tự ngắm / Lôi Xích / đồng minh chọn — người chơi tự nhìn bóng mà ngắm.
static func is_hidden(e) -> bool:
	return e.kind == "guong-bang" or (e.kind == "ban-nga" and e.phase == 2)


static func boss_phase_two(_w, e) -> bool:
	return e.kind == "ban-nga"


static func _boss(w):
	var b = w.boss()
	return b if b != null and b.kind == "ban-nga" and not b.dead else null


## Kỹ năng ô i người chơi đang gắn (SK1 có slot_skill; trước đó theo lớp).
static func _skill_id(w, i: int) -> String:
	if w.has_method("slot_skill"):
		var sk = w.slot_skill(i)
		if sk is Dictionary:
			return str(sk.get("id", ""))
	return str(Classes.skill(str(w.profile.class_id), i).get("id", ""))


static func _tick_shadow(w, dt: float) -> void:
	var st = w.ch6
	var p = w.player
	var b = _boss(w)
	# Ghi kỹ năng người chơi vừa dùng (hồi chiêu nhảy lên).
	for i in p.skill_cds.size():
		var cd: float = float(p.skill_cds[i])
		if i < st.last_cds.size():
			if cd > float(st.last_cds[i]) + 0.5 and b != null and b.phase != 2:
				st.copies.append({"id": _skill_id(w, i), "t": COPY_DELAY_P3 if b.phase >= 3 else COPY_DELAY})
			st.last_cds[i] = cd
	if b == null:
		st.copies = []
		if st.mirror_on:
			_end_mirrors(w, null)
		return
	# chuyển cảnh: không dùng lại kỹ năng (các kỹ năng chờ lùi lại)
	if st.invuln_t > 0.0:
		return
	for c in st.copies:
		c.t -= dt
	var due: Array = st.copies.filter(func(c): return c.t <= 0.0)
	st.copies = st.copies.filter(func(c): return c.t > 0.0)
	for c in due:
		if b.state == "windup" and str(MIRROR_OF.get(c.id, "m_bolt")) in ["m_spin", "m_dash", "m_bolt"]:
			c.t = 0.3
			st.copies.append(c)
			continue
		_mirror(w, b, str(c.id))
	if st.reshuffle:
		st.reshuffle = false
		_shuffle(w, b)
	if b.phase >= 3:
		match st.p3_group:
			"slow":
				st.pulse_t -= dt
				if st.pulse_t <= 0.0:
					st.pulse_t = P3_PULSE
					p.slow_timer = maxf(p.slow_timer, P3_SLOW)
					w._blast(p.pos, 50.0, Color("#b36bff"))
					w._text(p.pos + Vector2(0, -40), "Ngưng đọng!", Color("#b36bff"), true)
			"summon":
				st.summon_t -= dt
				if st.summon_t <= 0.0:
					st.summon_t = P3_SUMMON
					for k in 2:
						var m = w.spawn_enemy("anh-bong", b.level, b.pos + Vector2.from_angle(k * PI + 0.7) * 60.0, {"role": "bossMinion"})
						m.max_hp = maxf(1.0, b.max_hp * P3_SUMMON_HP)
						m.hp = m.max_hp
						m.atk = b.atk * 0.5
						m.state = "chase"


## Bản Ngã dùng lại một kỹ năng (C6-30a).
static func _mirror(w, b, skill_id: String) -> void:
	var st = w.ch6
	var pp: Vector2 = w.player.pos
	var kind: String = str(MIRROR_OF.get(skill_id, "m_bolt"))
	match kind:
		"m_spin", "m_dash", "m_bolt":
			if b.state == "stunned":
				return
			w._begin_attack(b, kind, COPY_WINDUP)
		"m_rain":
			for k in 3:
				add_mark(w, pp + (Vector2.ZERO if k == 0 else Vector2.from_angle(k * PI + 0.5) * 40.0), M_RAIN_R, M_RAIN_WARN, b.atk, M_RAIN_MUL,
					{"color": "#6a3aa8", "el": "kim"})
		"m_meteor":
			add_mark(w, pp, M_METEOR_R, M_METEOR_WARN, b.atk, M_METEOR_MUL, {"color": "#6a3aa8", "el": "kim"})
		"m_trap":
			add_mark(w, pp, M_TRAP_R, M_TRAP_WARN, b.atk, M_TRAP_MUL, {"color": "#6a3aa8", "el": "kim", "root": M_TRAP_ROOT})
		"m_shield":
			st.shield_t = M_SHIELD_TIME
		"m_haste":
			# Mắt bóng: Bản Ngã cướp Ưng Nhãn — nó nhanh hơn, người chơi mất phần Ưng Nhãn còn lại.
			st.haste_t = M_HASTE_TIME
			w.player.eagle_time = 0.0
	w._text(b.pos + Vector2(0, -b.radius - 28), _mirror_name(kind), Color("#b36bff"), false)


static func _mirror_name(kind: String) -> String:
	return {"m_spin": "Xoáy bóng!", "m_dash": "Lao bóng!", "m_bolt": "Tia bóng!", "m_rain": "Mưa bóng!", "m_meteor": "Thiên thạch bóng!",
		"m_trap": "Bẫy bóng!", "m_shield": "Thuẫn bóng!", "m_haste": "Mắt bóng!"}.get(kind, "Bóng!")


static func mirror_slots(w) -> Array:
	var out: Array = []
	for i in MIRRORS:
		out.append(w.arena_pos + Vector2.from_angle(TAU * i / MIRRORS - PI / 2.0) * (w.arena_r * MIRROR_RING))
	return out


static func _start_mirrors(w, b) -> void:
	var st = w.ch6
	st.mirror_on = true
	st.mirror_taken = 0.0
	st.copies = []
	st.mirror_slot = int(w._r() * MIRRORS) % MIRRORS
	var slots := mirror_slots(w)
	for i in MIRRORS:
		if i == st.mirror_slot:
			continue
		var m = w.spawn_enemy("guong-bang", b.level, slots[i], {"role": "bossMinion"})
		m.max_hp = b.max_hp
		m.hp = m.max_hp
		m.atk = b.atk
		m.state = "idle"
	b.pos = slots[st.mirror_slot]
	b.state = "idle"
	st.invuln_t = SHATTER_TIME
	w.say("boss6_mirror")
	w._message("Gương vỡ! Bản Ngã ẩn trong 1 trong 4 tấm Gương Băng — chỉ tấm thật có bóng. Đánh nhầm gương: phản sát thương.", "bad")


static func _shuffle(w, b) -> void:
	var st = w.ch6
	var slots := mirror_slots(w)
	var old: int = st.mirror_slot
	st.mirror_slot = (old + 1 + int(w._r() * (MIRRORS - 1))) % MIRRORS
	st.mirror_taken = 0.0
	st.invuln_t = SHUFFLE_TIME
	var free: Array = []
	for i in MIRRORS:
		w._blast(slots[i], 40.0, Color("#bfe6ff"))
		if i != st.mirror_slot:
			free.append(slots[i])
	b.pos = slots[st.mirror_slot]
	var k := 0
	for m in w.enemies:
		if m.kind == "guong-bang" and not m.dead and k < free.size():
			m.pos = free[k]
			k += 1
	w._text(b.pos + Vector2(0, -b.radius - 30), "Gương xoay!", Color("#bfe6ff"), true)


static func _end_mirrors(w, b) -> void:
	var st = w.ch6
	st.mirror_on = false
	for m in w.enemies:
		if m.kind == "guong-bang":
			m.dead = true
			w._blast(m.pos, 40.0, Color("#bfe6ff"))
	if b != null:
		b.pos = w.arena_pos
		b.state = "chase"


## Nhóm hiệu ứng GĐ3 theo nhóm Thiên phú (C6-30c).
static func talent_group(talent_id: String) -> String:
	var g: String = str(Talents.get_talent(talent_id).get("group", ""))
	match g:
		"combat":
			return "combat"
		"magic", "control":
			return "slow"
		"summon":
			return "summon"
	return "other"


## Dạng tiến hoá cao nhất của Thiên phú (Đạo Tặc / không có cây tiến hoá: chính nó).
static func top_form(talent_id: String) -> Array:
	var tree: Array = Talents.EVOLUTION.get(talent_id, [])
	if tree.is_empty():
		var t := Talents.get_talent(talent_id)
		return [str(t.name), str(t.rank)]
	var f: Array = tree[tree.size() - 1]
	return [str(f[0]), str(f[1])]


static func _start_phase3(w, b) -> void:
	var st = w.ch6
	_end_mirrors(w, b)
	b.phase = 3
	st.invuln_t = P3_INTRO
	st.p3_group = talent_group(str(w.profile.talent))
	var form := top_form(str(w.profile.talent))
	st.p3_form = "%s (%s)" % [form[0], form[1]]
	st.pulse_t = 2.0
	st.summon_t = 1.0
	match st.p3_group:
		"combat":
			b.atk *= P3_COMBAT_ATK
			st.haste_t = 9999.0
		"other":
			b.atk *= P3_OTHER_ATK
			b.speed *= P3_OTHER_SPEED
	w.say("boss6_talent")
	w._message("Bản Ngã dùng Thiên phú của ngươi ở dạng cao nhất: %s!" % st.p3_form, "bad")


static func update_enemy(w, e, dt: float) -> bool:
	var st = w.ch6
	if e.kind == "guong-bang":
		_mirror_bolt(w, e, dt, MIRROR_BOLT_FAKE)
		return true
	if e.kind != "ban-nga" or e.role != "boss":
		return false
	if e.phase == 1 and e.hp <= e.max_hp * 0.5:
		e.phase = 2
		_start_mirrors(w, e)
	if e.phase == 2 and e.hp <= e.max_hp * 0.2:
		_start_phase3(w, e)
	if e.phase == 2:
		if not st.mirror_on:
			_start_mirrors(w, e)
		if e.state == "stunned":
			return false
		e.state = "idle"
		_mirror_bolt(w, e, dt, 1.0)
		return true
	# Mắt bóng / Thiên phú chiến đấu: hồi đòn nhanh hơn 30%.
	if st.haste_t > 0.0 and e.state == "recover":
		e.timer -= dt * HASTE_RECOVER
	return false


static func _mirror_bolt(w, e, dt: float, mul: float) -> void:
	var st = w.ch6
	if st.invuln_t > 0.0:
		return
	var cd: float = float(st.bolt_cd.get(e.id, MIRROR_BOLT_CD * (0.5 + 0.1 * (e.id % 5)))) - dt
	if cd <= 0.0:
		cd = MIRROR_BOLT_CD
		if w.player.dead_timer <= 0.0:
			w._enemy_shot(e, (w.player.pos - e.pos).angle(), mul, 320.0)
	st.bolt_cd[e.id] = cd


## Ngũ Hành không khắc được Bản Ngã; Gương Bản Ngã; Bộ Cực Quang 6 món; Ám Khí.
static func hit_mult(w, e, crit: bool) -> float:
	var k := 1.0
	if e.kind == "ban-nga":
		k /= 1.0 + w.element_bonus(e)
	if crit and _set_count(w) >= 6:
		e.slow_t = maxf(e.slow_t, CQ_SLOW)
	if w.ch6.lost_t > 0.0:
		k *= DARK_LOST_ATK
	elif w.ch6.ascend_t > 0.0:
		k *= DARK_ASCEND_ATK
	return k


static func adjust_damage(w, e, dmg: int, by_player: bool) -> int:
	var st = w.ch6
	if (e.kind == "guong-bang" or e.kind == "ban-nga") and st.invuln_t > 0.0:
		return 0
	if e.kind == "guong-bang":
		if by_player:
			w._text(e.pos + Vector2(0, -e.radius - 22), "Gương giả!", Color("#bfe6ff"), false)
		if by_player and w.time >= st.reflect_at:
			st.reflect_at = w.time + MIRROR_REFLECT_CD
			var p = w.player
			var back: float = minf(dmg * MIRROR_REFLECT, float(w.stats.max_hp) * MIRROR_REFLECT_CAP)
			p.hp = maxf(1.0, p.hp - back)
			w._last_combat = w.time
			w._text(p.pos + Vector2(0, -36), "Phản -%d" % roundi(back), Color("#bfe6ff"), false)
		return 0
	if e.kind == "ban-nga":
		if st.shield_t > 0.0:
			dmg = maxi(1, roundi(dmg * (1.0 - M_SHIELD_CUT)))
		if e.phase == 2 and st.mirror_on:
			st.mirror_taken += dmg
			if st.mirror_taken >= e.max_hp * MIRROR_SHUFFLE:
				st.reshuffle = true
	return dmg


# ---------------------------------------------------------------- Đạo Tặc — Kính Ảnh


static func copy_skill(w, id: String) -> bool:
	if id != "mirror":
		return false
	var p = w.player
	var a = w._add_ally("shadow", "anh-bong", int(w.profile.level), p.pos + Vector2(30, 0))
	a.kind = "mirror"
	a.atk = float(w.stats.atk) * CLONE_ATK
	a.ttl = CLONE_TTL
	a.color = Color("#6a3aa8")
	w._text(p.pos + Vector2(0, -40), "Kính Ảnh!", Color("#b36bff"), true)
	return true


# ================================================================ người chơi: đồ, bộ, Than Hồng


static func derive_bonus(_w, bonus: Dictionary) -> void:
	if int(bonus.sets.get(CUC_QUANG, 0)) >= 4:
		bonus.flat["crit"] = float(bonus.flat.get("crit", 0.0)) + CQ_CRIT


## Phím Q: Than Hồng khi có ≥ 2 tầng băng giá.
static func drink(w) -> bool:
	var p = w.profile
	var st = w.ch6
	if int(p.embers) <= 0 or not in_region(w) or st.frost < EMBER_MIN:
		return false
	p.embers = int(p.embers) - 1
	st.frost = 0
	st.still_t = 0.0
	st.ember_until = w.time + EMBER_IMMUNE
	w._blast(w.player.pos, 40.0, Color("#ff9a3c"))
	w._text(w.player.pos + Vector2(0, -40), "Than Hồng — ấm lại!", Color("#ffb347"), true)
	return true


## C6-31 Gương Bản Ngã: 10% phản 50% sát thương nhận lên quái gần nhất trong 6 m.
static func player_hurt(w, dmg: float, _element: String) -> void:
	if dmg <= 0.0 or not w.has_unique("guong_ban_nga") or w._r() >= MIRROR_CHARM_CHANCE:
		return
	var best = null
	var bd := INF
	for e in w.enemies:
		var d: float = e.pos.distance_to(w.player.pos) - e.radius
		if not e.dead and d <= MIRROR_CHARM_R and d < bd:
			bd = d
			best = e
	if best != null:
		w._apply_damage(best, maxi(1, roundi(dmg * MIRROR_CHARM_PCT)), false, false)
		w._text(best.pos + Vector2(0, -best.radius - 22), "Phản chiếu!", Color("#bfe6ff"), false)


# ================================================================ Đèn Cực Quang, Ám Khí


static func _tick_beacons(w, dt: float) -> void:
	var st = w.ch6
	var bs: Array = w.map.get("beacons", [])
	if bs.is_empty() or step(w) != 3:
		return
	var lit: Array = w.profile.quest.beacons6
	for i in bs.size():
		if i in lit:
			continue
		if w.player.pos.distance_to(bs[i]) <= BEACON_R:
			st.beacon_t[i] = float(st.beacon_t.get(i, 0.0)) + dt
			if float(st.beacon_t[i]) >= BEACON_TIME:
				lit.append(i)
				w._blast(bs[i], 80.0, Color("#7affc8"))
				w._message("Đèn Cực Quang %d/3 đã thắp." % lit.size(), "good")
				w.say("beacon_lit")
		else:
			st.beacon_t[i] = 0.0


static func chapter_done(w) -> bool:
	return step(w) >= Story.DONE6


## Ám Khí tăng/giảm: từ bước 4 (ở Đỉnh Cực Quang) hoặc từ bước 5 (mọi map vùng 6), trừ trong hang boss.
static func dark_active(w) -> bool:
	if not in_region(w):
		return false
	var s := step(w)
	if s < 4 or (s == 4 and w.map_id != "6-3"):
		return false
	return w.map.arena == null or w.player.pos.distance_to(w.arena_pos) > w.arena_r + 40.0


static func _tick_dark(w, dt: float) -> void:
	var st = w.ch6
	var p = w.player
	if step(w) == 4 and w.map_id == "6-3" and not st.awaken_said:
		st.awaken_said = true
		w._force_say("awaken")
	if st.lost_t > 0.0:
		st.lost_t -= dt
		if st.lost_t <= 0.0 or p.dead_timer > 0.0:
			st.lost_t = 0.0
			st.dark = 0.0
			if step(w) == 4:
				w.profile.quest.dark6 = int(w.profile.quest.dark6) + 1
			w._message("Ngươi giành lại kiểm soát.", "info")
		return
	if st.dark_warn >= 0.0:
		st.dark_warn -= dt
		if st.dark_warn < 0.0:
			st.lost_t = DARK_LOST
			w.say("dark_lost")
			w._text(p.pos + Vector2(0, -50), "MẤT KIỂM SOÁT!", Color("#b36bff"), true)
		return
	if not dark_active(w) or p.dead_timer > 0.0:
		return
	if near_fire(w, p.pos):
		st.dark = maxf(0.0, st.dark - DARK_FIRE * dt)
	elif w.time - w._last_combat < w.OUT_OF_COMBAT:
		st.dark = minf(100.0, st.dark + DARK_COMBAT * dt)
	if st.dark >= 100.0:
		if chapter_done(w):
			st.dark = 0.0
			st.ascend_t = DARK_ASCEND
			w._text(p.pos + Vector2(0, -50), "Ám Hoá! +20% Tấn công", Color("#b36bff"), true)
		elif st.ascend_t <= 0.0:
			st.dark_warn = DARK_WARN
			w._message("Mảnh thứ hai thức giấc!", "bad")


## Mất kiểm soát: bỏ qua phím, tự lao vào quái gần nhất và đánh thường.
static func input_filter(w, input: Dictionary) -> Dictionary:
	if w.ch6.lost_t <= 0.0:
		return input
	var p = w.player
	var best = null
	var bd := 600.0
	for e in w.enemies:
		var d: float = e.pos.distance_to(p.pos)
		if not e.dead and d < bd:
			bd = d
			best = e
	var out := {"move": Vector2.ZERO, "aim": p.pos + Vector2.from_angle(p.facing) * 50.0, "attack": false, "skill": false, "talent": false,
		"dodge": false}
	if best != null:
		out.aim = best.pos
		out.attack = true
		var reach: float = 70.0 if not (w.is_mage() or w.is_hunter()) else 250.0
		if bd > reach + best.radius:
			out.move = (best.pos - p.pos).normalized()
	return out


# ================================================================ nhiệm vụ chương 6 (C6-41)


static func quest(w) -> Dictionary:
	return Story.quest6(step(w))


static func _grid6(w) -> Array:
	var p = w.profile
	return p.tiles if int(p.tiles_region) == 6 else p.grid_of(6)


static func quest_status(w) -> Array:
	var q := quest(w)
	if q.is_empty():
		return [0, 0]
	var p = w.profile
	match str(q.type):
		"kills6":
			return [mini(int(p.quest.kills6), int(q.need)), int(q.need)]
		"beacons6":
			return [mini(p.quest.beacons6.size(), int(q.need)), int(q.need)]
		"dark6":
			return [mini(int(p.quest.dark6), int(q.need)), int(q.need)]
	return [0, int(q.need)]


static func check_quest(w) -> void:
	var q := quest(w)
	if q.is_empty():
		return
	var p = w.profile
	var done := false
	match str(q.type):
		"kills6":
			done = int(p.quest.kills6) >= int(q.need)
		"beacons6":
			done = p.quest.beacons6.size() >= int(q.need)
		"dark6":
			done = int(p.quest.dark6) >= int(q.need)
		"explore6":
			done = w.map_id == "6-3" and w.explore_ratio("6-3") >= 0.4
		"boss6":
			done = w.is_boss_defeated("ban-nga")
	if done:
		advance(w)


static func advance(w) -> void:
	var q := quest(w)
	if q.is_empty():
		return
	var r: Dictionary = q.reward
	var p = w.profile
	p.gold += float(r.get("gold", 0))
	p.stones += int(r.get("stones", 0))
	p.crystal = float(p.crystal) + float(r.get("crystal", 0))
	p.embers = int(p.embers) + int(r.get("embers", 0))
	var rt := Story.reward_text(r)
	w._message("Nhiệm vụ chương 6 hoàn thành: %s%s" % [q.title, (". Thưởng: " + rt) if rt != "" else ""], "good")
	var s := step(w)
	p.quest.ch6 = s + 1
	w._events.append({"type": "quest_done", "step": s, "chapter": 6})
	if r.has("exp"):
		w.add_exp(float(r.exp), false)
	match s:
		1:
			w.say("han_task")
		2:
			w.say("nga_beacons")
		4:
			w.ch6.dark = 0.0
			w.say("dark_done")
		5:
			w.say("mirror_gate")
		6:
			w.say("shadow_down")
		7:
			w.say("ch6_done")
			w._events.append({"type": "chapter_end", "chapter": 6})


## Bấm E. Trả về "shop" (mở cửa hàng) hoặc "".
static func talk(w, npc_id: String) -> String:
	var s := step(w)
	match npc_id:
		"tuyet-nga":
			if s == 1:
				w._force_say("nga_meet")
				advance(w)
				return ""
			if s == 7:
				w._force_say("truth")
				advance(w)
				return ""
			w._force_say("nga_wait" if s == 6 else ("ch6_done" if s >= Story.DONE6 else "nga_idle"))
			return ""
		"lao-han":
			w._force_say("han_task" if s == 2 else "han_shop")
			return "shop"
		"lam-nhi-6":
			w._force_say("lam6_idle")
			return ""
	return ""


static func map_requirement(w, id: String) -> String:
	match id:
		"6-1":
			# C6-01: chuyển chức 2 + hạ Viêm Long + cấp 59.
			if not w.is_boss_defeated("vien-long"):
				return "Hạ Viêm Long trước."
			if str(w.profile.job2) == "":
				return "Cần chuyển chức lần 2 (Liệt Diễm ở Trại Tro Hồng)."
			if int(w.profile.level) < 59:
				return "Cần cấp 59."
		"6-2":
			return "" if "6-1" in w.profile.unlocked_maps else "Tới Đồng Tuyết trước."
		"6-3":
			return "" if "6-2" in w.profile.unlocked_maps else "Tới Rừng Băng trước."
	return ""


static func gate_open(w, id: String) -> bool:
	if id == "6-3":
		return step(w) >= 6 or w.is_boss_defeated("ban-nga")
	return true


static func env_text(w) -> String:
	if not in_region(w):
		return ""
	var st = w.ch6
	var parts := PackedStringArray()
	if st.lost_t > 0.0:
		parts.append("MẤT KIỂM SOÁT %.1f giây" % st.lost_t)
	elif st.dark_warn >= 0.0:
		parts.append("MẢNH THỨ HAI THỨC GIẤC!")
	elif dark_active(w) or st.dark > 0.0:
		parts.append(("Ám Khí %d%%" if not chapter_done(w) else "Ám Khí %d%% (đầy = Ám Hoá)") % roundi(st.dark))
	if st.ascend_t > 0.0:
		parts.append("Ám Hoá %d giây" % ceili(st.ascend_t))
	if frost_immune(w):
		if w.time < st.ember_until:
			parts.append("Than Hồng: miễn băng giá %d giây" % ceili(st.ember_until - w.time))
	elif st.frost > 0:
		parts.append("Băng giá %d/%d · đứng yên sẽ đông cứng" % [st.frost, FROST_MAX])
	if is_night(w):
		var t: float = fposmod(float(w.profile.play_seconds), CYCLE)
		parts.append("Đêm · tầm nhìn 60%% · còn %d:%02d" % [int((CYCLE - t) / 60.0), int(CYCLE - t) % 60])
	if int(w.profile.embers) > 0 and st.frost >= EMBER_MIN:
		parts.append("Q: Than Hồng (%d)" % int(w.profile.embers))
	var b = _boss(w)
	if b != null and st.invuln_t > 0.0:
		parts.append("Gương đang xoay…" if b.phase == 2 else "Bản Ngã đang thay hình…")
	if b != null and b.phase >= 3 and st.p3_form != "":
		parts.append("Bản Ngã: %s" % st.p3_form)
	return "   ·   ".join(parts)


static func env_alert(w) -> bool:
	var st = w.ch6
	return in_region(w) and (st.frost >= 3 or st.lost_t > 0.0 or st.dark_warn >= 0.0)


static func quest_hud(w) -> Dictionary:
	var q := quest(w)
	if not q.is_empty():
		var qs := quest_status(w)
		var rt := Story.reward_text(q.reward)
		return {"active": true, "title": "CHƯƠNG 6 · NHIỆM VỤ %d/%d" % [step(w), Story.QUESTS6.size()],
			"lines": [["◆ " + str(q.title) + ("  (%d/%d)" % qs if int(qs[1]) > 1 else ""), "gold"], [str(q.hint), "text"],
				[("Thưởng: " + rt) if rt != "" else "", "muted"]]}
	if chapter_done(w):
		return {"done": true, "title": "CHƯƠNG 6 · HOÀN THÀNH ✓",
			"lines": [["Sự thật: ngươi mang mảnh linh hồn của Ma Tôn Vô Diện", "text"],
				["Săn boss hiếm Long Băng Bắc Cực ở Đỉnh Cực Quang — 2 lần mỗi ngày", "muted"],
				["Chương 7: Quần Đảo Thiên Không — sắp mở", "muted"]]}
	return {}
