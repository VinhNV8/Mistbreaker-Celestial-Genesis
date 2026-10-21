extends RefCounted
## SK2 (docs/13 mục 4): 12 kỹ năng mới (cấp 15/22 + chuyển chức 1) và biến thể kỹ năng 3 tầng.
## GameWorld chỉ gọi: cast (kỹ năng mới), tick, source / crit_bonus / hit_mult / def_mult / after_hit (khi trúng đòn),
## cost_mult (MP, hồi chiêu), after_cast (kỹ năng hỗ trợ). Trạng thái riêng ở `w.sk2` (State).

const Classes = preload("res://scripts/data/classes.gd")
const Monsters = preload("res://scripts/data/monsters.gd")
const Formulas = preload("res://scripts/core/formulas.gd")

# ---------------------------------------------------------------- biến thể (docs/13 mục 4.3, 4.4)
## Tầng mở ở cấp kỹ năng 4 / 7 / 10.
const TIER_LEVELS := [4, 7, 10]
const ELEMENTS := ["hoa", "thuy", "moc", "kim", "tho"]
const ELEMENT_NAMES := {"hoa": "Hỏa", "thuy": "Thủy", "moc": "Mộc", "kim": "Kim", "tho": "Thổ"}
## [id, tên, mô tả]
const TIER_DAMAGE := [
	[["mp", "Tiết Kiệm", "−20% MP"], ["cd", "Thần Tốc", "−15% hồi chiêu"]],
	[["hoa", "Hỏa", "Thiêu đốt 3 giây (15% Tấn công/giây)"], ["thuy", "Thủy", "Làm chậm 2 giây"],
		["moc", "Mộc", "Hút máu 4% sát thương"], ["kim", "Kim", "Bỏ qua 25% Phòng thủ"], ["tho", "Thổ", "+50% vào thanh Phá Thế"]],
	[["dmg", "Bạo Lực", "+25% sát thương"], ["crit", "Chí Mạng", "+20% tỉ lệ chí mạng"]],
]
const TIER_UTILITY := [
	[["mp", "Tiết Kiệm", "−20% MP"], ["cd", "Thần Tốc", "−15% hồi chiêu"]],
	[["long", "Bền Bỉ", "Hiệu lực dài thêm 30%"], ["heal", "Hồi Phục", "Dùng kỹ năng hồi 10% HP"]],
	[["cd2", "Tinh Thông", "−20% hồi chiêu"], ["mp0", "Vô Ngã", "Không tốn MP"]],
]
const COUNTER_BONUS := 1.3
const BURN_TIME := 3.0
const BURN_MUL := 0.15
const SLOW_TIME := 2.0
const LEECH := 0.04
const KIM_DEF := 0.75
const THO_POISE := 0.5
const DMG_BONUS := 0.25
const CRIT_BONUS := 0.2
const LONG_MUL := 1.3
const HEAL_PCT := 0.1

# ---------------------------------------------------------------- kỹ năng mới
const LT_STRIKES := 3
const LT_GAP := 0.2
const LT_RANGE := 70.0
const LT_ARC := deg_to_rad(45.0)
const HK_R := 80.0
const HK_STUN := 1.2
const KV_TICKS := 8
const KV_GAP := 0.25
const KV_R := 100.0
const PK_SPREAD := deg_to_rad(15.0)
const TN_RANGE := 380.0
const TN_HOP := 150.0
const TN_JUMPS := 4
## Không còn quái khác để nảy: mũi tên dội lại chính mục tiêu, ×0,35 mỗi lần (đánh boss đơn lẻ vẫn có ích).
const TN_ECHO := 0.35
const LB_SPREAD := deg_to_rad(12.0)
const LX_SHOTS := 8
const LX_GAP := 0.18
const TD_STACKS := 3
const TD_TIME := 4.0
const HT_RANGE := 250.0
const HT_LEN := 120.0
const HT_THICK := 30.0
const HT_TIME := 4.0
const HT_TICK := 0.5
const DC_DIST := 150.0
const DC_R := 60.0
const MB_RANGE := 300.0
const MB_R := 90.0
const MB_TICKS := 5
const MB_GAP := 0.4
const CS_SPEED := 105.0
const CS_TIME := 2.4
const CS_ZAP_R := 80.0
const CS_ZAP_GAP := 0.3
const CS_END_R := 70.0
const CS_END_MUL := 3.0
## Mũi tên / đạn của kỹ năng → id kỹ năng khi trúng (GameWorld.hit_source).
const SOURCE_SKILL := {"meteor": "meteor", "nova": "nova"}


class State:
	## [{t, skill, kind, mul, n}] — đòn trễ (Liên Trảm, Kiếm Vũ, Liên Xạ)
	var queue: Array = []
	## [{a, b, ttl, acc, mul, skill}] — Hoả Tường
	var walls: Array = []
	## [{pos, r, ticks, timer, mul, skill}] — Mưa Băng
	var ice: Array = []
	## [{pos, vel, ttl, zap, mul, skill}] — Cầu Sấm
	var orbs: Array = []


static func is_utility(sk: Dictionary) -> bool:
	return float(sk.get("mul", 0.0)) <= 0.0


static func tiers_for(sk: Dictionary) -> Array:
	return TIER_UTILITY if is_utility(sk) else TIER_DAMAGE


# ================================================================ biến thể


static func variant(w, id: String, tier: int) -> String:
	var v: Array = w.profile.variants.get(id, [])
	if tier >= v.size():
		return ""
	# Chỉ có hiệu lực khi kỹ năng đã đạt cấp mở tầng.
	return str(v[tier]) if w.skill_level(id) >= TIER_LEVELS[tier] else ""


static func element_of(w, id: String) -> String:
	var el := variant(w, id, 1)
	return el if el in ELEMENTS else ""


## Đổi biến thể chỉ ở vùng an toàn (như đổi ô kỹ năng).
static func set_variant(w, id: String, tier: int, opt: String) -> Dictionary:
	var sk: Dictionary = Classes.skill_by_id(w.profile.class_id, id)
	if sk.is_empty() or tier < 0 or tier > 2:
		return {"ok": false, "message": "Không có biến thể này."}
	if not w.in_safe_zone():
		return _res(w, false, "Đổi biến thể ở vùng an toàn (làng, trại, thành).")
	if w.skill_level(id) < TIER_LEVELS[tier]:
		return _res(w, false, "%s cần cấp %d để mở tầng %d." % [sk.name, TIER_LEVELS[tier], tier + 1])
	var ok := false
	var name := ""
	for o in tiers_for(sk)[tier]:
		if o[0] == opt:
			ok = true
			name = str(o[1])
	if not ok:
		return _res(w, false, "Biến thể không hợp lệ.")
	var v: Array = w.profile.variants.get(id, ["", "", ""]).duplicate()
	while v.size() < 3:
		v.append("")
	v[tier] = opt
	w.profile.variants[id] = v
	return _res(w, true, "%s · tầng %d: %s." % [sk.name, tier + 1, name])


static func _res(w, ok: bool, msg: String) -> Dictionary:
	w._message(msg, "good" if ok else "bad")
	return {"ok": ok, "message": msg}


## Nhân MP ("mp") / hồi chiêu ("cd") theo biến thể.
static func cost_mult(w, id: String, what: String) -> float:
	var t1 := variant(w, id, 0)
	var t3 := variant(w, id, 2)
	if what == "mp":
		if t3 == "mp0":
			return 0.0
		return 0.8 if t1 == "mp" else 1.0
	var k := 0.85 if t1 == "cd" else 1.0
	return k * (0.8 if t3 == "cd2" else 1.0)


## Kỹ năng hỗ trợ: kéo dài / hồi máu ngay sau khi dùng.
static func after_cast(w, id: String) -> void:
	var p = w.player
	match variant(w, id, 1):
		"long":
			p.guard_time *= LONG_MUL
			p.eagle_time *= LONG_MUL
			p.shield_time *= LONG_MUL
		"heal":
			p.hp = minf(float(w.stats.max_hp), p.hp + float(w.stats.max_hp) * HEAL_PCT)


# ================================================================ khi trúng đòn


## Kỹ năng gây ra đòn đang tính (GameWorld.skill_ctx hoặc hit_source của đạn/thiên thạch).
static func source(w) -> String:
	if str(w.skill_ctx) != "":
		return str(w.skill_ctx)
	return str(SOURCE_SKILL.get(str(w.hit_source), ""))


static func crit_bonus(w, id: String) -> float:
	return CRIT_BONUS if id != "" and variant(w, id, 2) == "crit" else 0.0


static func hit_mult(w, e, id: String) -> float:
	if id == "":
		return 1.0
	var k := 1.0 + (DMG_BONUS if variant(w, id, 2) == "dmg" else 0.0)
	var el := element_of(w, id)
	if el != "" and Monsters.counters(el, str(Monsters.DEFS[e.kind].element)):
		k *= COUNTER_BONUS
	return k


static func def_mult(w, id: String) -> float:
	return KIM_DEF if id != "" and element_of(w, id) == "kim" else 1.0


static func after_hit(w, e, id: String, dmg: int) -> void:
	if id == "" or e.dead:
		return
	if id == "tendoc":
		e.venom_stacks = mini(TD_STACKS, e.venom_stacks + 1)
		if e.venom_timer <= 0.0:
			e.venom_tick = 0.0
		e.venom_timer = TD_TIME
	match element_of(w, id):
		"hoa":
			if e.bleed_timer <= 0.0:
				e.bleed_tick = 0.0
			e.bleed_timer = maxf(e.bleed_timer, BURN_TIME)
			e.bleed_dmg = maxf(e.bleed_dmg, Formulas.compute_damage(w.stats.atk, e.def, BURN_MUL))
		"thuy":
			e.slow_t = maxf(e.slow_t, SLOW_TIME)
		"moc":
			w.player.hp = minf(float(w.stats.max_hp), w.player.hp + dmg * LEECH)
		"tho":
			if e.max_poise > 0.0:
				w._damage_poise(e, dmg * THO_POISE)


# ================================================================ kỹ năng mới


## Thi triển kỹ năng SK2. true = đã xử lý.
static func cast(w, id: String, mul: float) -> bool:
	var p = w.player
	match id:
		"lientram":
			for k in LT_STRIKES:
				w.sk2.queue.append({"t": LT_GAP * k, "skill": id, "kind": "cone", "mul": mul})
			p.swing = LT_GAP * LT_STRIKES
			p.swing_kind = "slash"
		"hongkiem":
			w._blast(p.pos, HK_R, Color("#ffd76a"))
			w._sfx("boss_roar")
			for e in w.enemies:
				if e.dead or e.pos.distance_to(p.pos) > HK_R + e.radius:
					continue
				w._hit_enemy(e, mul, false, true)
				if e.dead:
					continue
				if e.role in ["boss", "rare"] or e.elite:
					w._damage_poise(e, Formulas.compute_damage(w.stats.atk, e.def, mul))
				elif e.state != "stunned":
					e.state = "stunned"
					e.timer = HK_STUN
			p.swing = 0.3
			p.swing_kind = "spin"
		"kiemvu":
			for k in KV_TICKS:
				w.sk2.queue.append({"t": KV_GAP * k, "skill": id, "kind": "whirl", "mul": mul})
			p.swing = KV_GAP * KV_TICKS
			p.swing_kind = "spin"
		"phikiem":
			w._auto_face(w.WAVE_RANGE, deg_to_rad(20.0))
			var keep: float = p.facing
			for k in [-1, 0, 1]:
				p.facing = keep + k * PK_SPREAD
				w._fire(w.WAVE_SPEED, w.WAVE_RANGE, mul, true, "wave", false, 18.0)
			p.facing = keep
			p.swing = 0.16
			p.swing_kind = "slash"
		"tennay":
			_bounce(w, id, mul)
			p.swing = 0.16
			p.swing_kind = "shot"
		"lanban":
			var dir: Vector2 = (w._aim - p.pos).normalized() if w._aim.distance_to(p.pos) > 1.0 else Vector2.from_angle(p.facing)
			p.facing = dir.angle()
			var keep2: float = p.facing
			for k in [-1, 0, 1]:
				p.facing = keep2 + k * LB_SPREAD
				w._fire(w.SHOT_SPEED, w.SHOT_RANGE, mul, false, "arrow")
			p.facing = keep2
			p.dodge_dir = -dir
			p.dodge_time = w.DODGE_TIME
			p.perfect_used = false
			p.swing = 0.16
			p.swing_kind = "shot"
		"lienxa":
			for k in LX_SHOTS:
				w.sk2.queue.append({"t": LX_GAP * k, "skill": id, "kind": "volley", "mul": mul})
		"tendoc":
			w._soft_lock(w.PIERCE_RANGE)
			w._fire(w.PIERCE_SPEED, w.PIERCE_RANGE, mul, true, "pierce", false, 12.0)
			p.swing = 0.16
			p.swing_kind = "shot"
		"hoatuong":
			var c: Vector2 = p.pos + (w._aim - p.pos).limit_length(HT_RANGE)
			var fwd: Vector2 = (c - p.pos).normalized() if c.distance_to(p.pos) > 1.0 else Vector2.from_angle(p.facing)
			var side: Vector2 = fwd.orthogonal() * HT_LEN * 0.5
			w.sk2.walls.append({"a": c - side, "b": c + side, "ttl": HT_TIME, "acc": HT_TICK, "mul": mul, "skill": id})
			p.swing = 0.25
			p.swing_kind = "cast"
		"dichchuyen":
			var from: Vector2 = p.pos
			var d2: Vector2 = (w._aim - p.pos).normalized() if w._aim.distance_to(p.pos) > 1.0 else Vector2.from_angle(p.facing)
			p.pos = (p.pos + d2 * DC_DIST).clamp(Vector2.ONE * w.PLAYER_RADIUS, w.world_size - Vector2.ONE * w.PLAYER_RADIUS)
			w._enforce_gate()
			w._enforce_arena_lock()
			w._blast(from, DC_R, Color("#9de0ff"))
			for e in w.enemies:
				if not e.dead and e.pos.distance_to(from) <= DC_R + e.radius:
					w._hit_enemy(e, mul, false, true)
					e.slow_t = maxf(e.slow_t, SLOW_TIME)
			p.swing = 0.2
			p.swing_kind = "cast"
		"muabang":
			var at: Vector2 = p.pos + (w._aim - p.pos).limit_length(MB_RANGE)
			var n = w._nearest_enemy(at, MB_R)
			if n == null:
				n = w._nearest_enemy(p.pos, MB_RANGE)
				if n != null:
					at = n.pos
			w.sk2.ice.append({"pos": at, "r": MB_R, "ticks": MB_TICKS, "timer": 0.0, "mul": mul, "skill": id})
			p.swing = 0.25
			p.swing_kind = "cast"
		"causam":
			var d3: Vector2 = (w._aim - p.pos).normalized() if w._aim.distance_to(p.pos) > 1.0 else Vector2.from_angle(p.facing)
			w.sk2.orbs.append({"pos": p.pos + d3 * 20.0, "vel": d3 * CS_SPEED, "ttl": CS_TIME, "zap": 0.0, "mul": mul, "skill": id})
			p.swing = 0.25
			p.swing_kind = "cast"
		_:
			return false
	return true


## Tên Nảy: trúng quái gần nhất theo hướng ngắm, nảy tối đa 4 lần.
static func _bounce(w, id: String, mul: float) -> void:
	var p = w.player
	w._soft_lock(TN_RANGE)
	var first = null
	var dir := Vector2.from_angle(p.facing)
	var bd := INF
	for e in w.enemies:
		if e.dead or w.is_hidden(e):
			continue
		var to_e: Vector2 = e.pos - p.pos
		var d: float = to_e.length() - e.radius
		if d <= TN_RANGE and absf(angle_difference(dir.angle(), to_e.angle())) <= deg_to_rad(25.0) and d < bd:
			bd = d
			first = e
	if first == null:
		first = w._nearest_enemy(p.pos, TN_RANGE)
	var b = w.Bolt.new()
	b.points.append(p.pos)
	if first == null:
		return
	var hit := {}
	var cur = first
	var k := 1.0
	for _i in TN_JUMPS + 1:
		hit[cur.id] = true
		b.points.append(cur.pos)
		w._hit_enemy(cur, mul * k)
		if cur.dead:
			break
		var nxt = w._nearest_enemy(cur.pos, TN_HOP, hit)
		if nxt == null:
			k = TN_ECHO
			continue
		cur = nxt
		k = 1.0
	w.bolts.append(b)


static func tick(w, dt: float) -> void:
	var st = w.sk2
	var p = w.player
	# đòn trễ
	for q in st.queue:
		q.t -= dt
		if q.t > 0.0 or p.dead_timer > 0.0:
			continue
		w.skill_ctx = str(q.skill)
		match str(q.kind):
			"cone":
				var dir := Vector2.from_angle(p.facing)
				w._blast(p.pos + dir * LT_RANGE * 0.6, LT_RANGE * 0.5, Color("#e8eef6"))
				w._sfx("slash")
				for e in w.enemies:
					if e.dead:
						continue
					var to_e: Vector2 = e.pos - p.pos
					if to_e.length() <= LT_RANGE + e.radius and absf(angle_difference(dir.angle(), to_e.angle())) <= LT_ARC:
						w._hit_enemy(e, float(q.mul))
			"whirl":
				w._blast(p.pos, KV_R, Color("#c8d6e4"))
				for e in w.enemies:
					if not e.dead and e.pos.distance_to(p.pos) <= KV_R + e.radius:
						w._hit_enemy(e, float(q.mul), false, true)
			"volley":
				var tgt = w._nearest_enemy(p.pos, w.SHOT_RANGE)
				if tgt != null:
					var keep: float = p.facing
					p.facing = (tgt.pos - p.pos).angle()
					w._fire(w.SHOT_SPEED, w.SHOT_RANGE, float(q.mul), false, "arrow")
					p.facing = keep
		w.skill_ctx = ""
	st.queue = st.queue.filter(func(q): return q.t > 0.0 and p.dead_timer <= 0.0)
	# Hoả Tường
	for wl in st.walls:
		wl.ttl -= dt
		wl.acc += dt
		if wl.acc < HT_TICK:
			continue
		wl.acc -= HT_TICK
		w.skill_ctx = str(wl.skill)
		for e in w.enemies:
			if not e.dead and Geometry2D.get_closest_point_to_segment(e.pos, wl.a, wl.b).distance_to(e.pos) <= HT_THICK + e.radius:
				w._hit_enemy(e, float(wl.mul), false, true)
		w.skill_ctx = ""
	st.walls = st.walls.filter(func(wl): return wl.ttl > 0.0)
	# Mưa Băng
	for z in st.ice:
		z.timer -= dt
		if z.timer > 0.0 or z.ticks <= 0:
			continue
		z.timer = MB_GAP
		z.ticks -= 1
		w.skill_ctx = str(z.skill)
		for e in w.enemies:
			if not e.dead and e.pos.distance_to(z.pos) <= float(z.r) + e.radius:
				w._hit_enemy(e, float(z.mul), false, true)
				e.slow_t = maxf(e.slow_t, 1.0)
		w.skill_ctx = ""
	st.ice = st.ice.filter(func(z): return z.ticks > 0 or z.timer > 0.0)
	# Cầu Sấm
	for o in st.orbs:
		o.ttl -= dt
		o.pos += o.vel * dt
		o.zap -= dt
		w.skill_ctx = str(o.skill)
		if o.zap <= 0.0:
			o.zap = CS_ZAP_GAP
			var t = w._nearest_enemy(o.pos, CS_ZAP_R)
			if t != null:
				var b = w.Bolt.new()
				b.points.append(o.pos)
				b.points.append(t.pos)
				w.bolts.append(b)
				w._hit_enemy(t, float(o.mul), false, true)
		if o.ttl <= 0.0:
			w._blast(o.pos, CS_END_R, Color("#b3a6ff"))
			w._sfx("explode")
			for e in w.enemies:
				if not e.dead and e.pos.distance_to(o.pos) <= CS_END_R + e.radius:
					w._hit_enemy(e, float(o.mul) * CS_END_MUL, false, true)
		w.skill_ctx = ""
	st.orbs = st.orbs.filter(func(o): return o.ttl > 0.0)
