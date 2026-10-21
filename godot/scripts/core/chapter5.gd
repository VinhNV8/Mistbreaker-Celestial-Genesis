extends RefCounted
## M8 — Chương 5 Núi Lửa Phẫn Nộ (docs/12-chuong-5.md). Gắn vào GameWorld qua core/chapters.gd (D38).
## Gồm: dung nham, núi lửa phun, nhiệt; quái vùng 5; Viêm Long (bay lên, dung nham dâng theo lượt, Đá Nổi, cuồng nộ);
## Phượng Hoàng Tro (Niết bàn, Bình Nước Thánh); Bộ Hoả Ngục, Long Tâm, Lông Phượng, Long Tức (Đạo Tặc);
## Thương hội Kim Luân phản bội + Công Trại / đột kích định kỳ; Tinh Thạch; nhiệm vụ chương 5; chuyển chức 2.

const Monsters = preload("res://scripts/data/monsters.gd")
const Classes = preload("res://scripts/data/classes.gd")
const Story = preload("res://scripts/data/story.gd")
const Items = preload("res://scripts/core/items.gd")
const Explore = preload("res://scripts/core/explore.gd")
const Formulas = preload("res://scripts/core/formulas.gd")
const Ch3 = preload("res://scripts/core/chapter3.gd")
const Ch4 = preload("res://scripts/core/chapter4.gd")

const MAPS := ["5-1", "5-2", "5-3"]
const NPCS := ["xich-dong", "kim-phu", "liet-dien", "tieu-hoa"]
const HOOKS := ["on_load", "tick", "check_quest", "on_kill", "on_player_hit", "vanish", "update_enemy", "chase", "perform",
	"elite_skill", "update_rare", "boss_phase_two", "copy_skill", "adjust_damage", "hit_mult", "derive_bonus", "derive_after",
	"skill_trail", "after_slash", "pierce_cd", "drink", "player_hurt", "enemy_avoid", "safe_blocked", "is_hidden",
	"map_requirement", "gate_open", "env_text", "env_alert", "quest_hud", "poise_mult", "trap_extra", "trap_triggered", "meteor_extra", "npc_visible"]

# ---------------------------------------------------------------- C5-10…13: môi trường
const LAVA_PCT := 0.05
const HEAT_R := 50.0
const HEAT_SPEED := 0.10
const ERUPT_PERIOD := 45.0
const ERUPT_WARN := 3.0
const ERUPT_COUNT := 8
const ERUPT_SPREAD := 250.0
const METEOR_WARN := 1.5
const METEOR_R := 40.0
const METEOR_PCT := 0.25
# ---------------------------------------------------------------- C5-20…26: quái
const TRAIL_EVERY := 0.4
const TRAIL_TTL := 3.0
const TRAIL_R := 22.0
const TRAIL_MUL := 0.1
const PUNCH_MUL := 1.3
const SHARDS := 3
const SHARD_HP := 0.15
const BURST_R := 50.0
const PILLARS := 3
const PILLAR_GAP := 0.3
const PILLAR_R := 25.0
const PILLAR_MUL := 1.2
const BREATH_CD := 10.0
const BREATH_TIME := 2.0
const BREATH_TICK := 0.2
const BREATH_RANGE := 120.0
const BREATH_ARC := deg_to_rad(30.0)
const BREATH_TURN := deg_to_rad(60.0)
const BREATH_MUL := 0.5
const HAMMER_CD := 12.0
const HAMMER_R := 60.0
const HAMMER_MUL := 2.0
const HAMMER_BUFF_R := 100.0
const HAMMER_BUFF := 1.2
const HAMMER_TIME := 8.0
# ---------------------------------------------------------------- C5-30: Viêm Long
const CLAW_MUL := 1.5
const DRAGON_BREATH_CD := 6.0
const DRAGON_BREATH_TIME := 2.5
const DRAGON_BREATH_TICK := 0.25
const DRAGON_BREATH_RANGE := 180.0
const DRAGON_BREATH_ARC := deg_to_rad(35.0)
const DRAGON_BREATH_TURN := deg_to_rad(45.0)
const DRAGON_BREATH_MUL := 0.6
## Giai đoạn 2: bay (báo 3 s + ngập 6 s) → đáp xuống tới khi mất 15% HP hoặc 10 giây → bay lại.
## (Đáp theo lượng sát thương thay vì thời gian cố định: thời gian giai đoạn 2 tỉ lệ với sát thương, không nhảy bậc theo chu kỳ.)
const FLOOD_WARN := 3.0
const FLOOD_TIME := 6.0
const LAND_TIME := 10.0
const LAND_DAMAGE := 0.15
const FLOOD_PCT := 0.08
const ROCKS := 5
const ROCK_R := 30.0
const RAGE_BREATH_CD := 8.0
const LAND_GAP := 80.0
const LAND_BREATH_DELAY := 3.0
# ---------------------------------------------------------------- C5-33: Phượng Hoàng Tro
const FEATHER_CD := 6.0
const FEATHERS := 12
const FEATHER_R := 30.0
const FEATHER_SPREAD := 150.0
const FEATHER_WARN := 1.2
const DIVE_CD := 9.0
const DIVE_LEN := 200.0
const DIVE_MUL := 1.6
const REBIRTH_TIME := 3.0
const REBIRTH_HP := 0.5
const WATER_WINDOW := 5.0
const HOLY_LOW := 0.15
# ---------------------------------------------------------------- đồ, bộ, chuyển chức 2
const HOA_NGUC := "hoa_nguc"
const HOA_NGUC_RES := 0.3
const RING_TTL := 5.0
const RING_MUL := 0.3
const LONG_TAM_FIRE := 0.2
const LONG_TAM_IMMUNE := 2.0
const FEATHER_REVIVE := 0.3
const FEATHER_CD_TIME := 300.0
const COPY_BREATH_TIME := 2.0
const COPY_BREATH_TICK := 0.25
const COPY_BREATH_RANGE := 120.0
const COPY_BREATH_MUL := 0.5
const KT_EVERY := 3
const KT_MUL := 1.0
const KT_POISE := 1.4
const HK_LEECH := 0.06
const HK_LOW := 0.5
const HK_MUL := 1.2
const TT_CRIT := 0.10
const TT_CRIT_MUL := 1.2
const TT_PIERCE := 1.0
const TB_TRAPS := 2
const TB_TTL := 40.0
const TB_R := 40.0
const TB_MUL := 1.5
const DPS_MP := 1.3
const DPS_METEOR_MUL := 0.6
const TL_CHANCE := 0.2
const TL_MAX := 3
const TL_TTL := 12.0
const TL_ATK := 0.5
const TL_BONUS := 0.05
# ---------------------------------------------------------------- C5-42, C5-43: Công Trại, đột kích
const SIEGE_WAVES := [[["linh-kim-luan", 6]], [["linh-kim-luan", 8], ["nguoi-da*", 1]], [["linh-kim-luan", 6], ["doi-truong-kim-luan*", 1]]]
const GATE_HP_PER_LEVEL := 200.0
const GATE_HIT := 0.5
const GATE_HIT_CD := 1.5
const SIEGE_AGGRO := 160.0
const WAVE_GAP := 3.0
const RAID_EVERY := 1800.0
const RAID_WARN := 60.0
const RAID_TIME := 180.0
const RAID_PENALTY := 1800.0
const SHOP_HOLY := 80
const CRYSTAL_PER_KIM := 5


class State:
	var erupt_t := ERUPT_PERIOD
	## [{pos, t}] — thiên thạch núi lửa, t = giây còn lại tới khi rơi
	var meteors: Array = []
	var heat := false
	var lava_immune := 0.0
	## [{pos, ttl, atk, acc}] — vệt lửa Thằn Lằn
	var trails: Array = []
	## [{pos, t, atk}] — Cột lửa đang chờ bùng
	var pillars: Array = []
	## [{id, t, ang, acc, range, arc, turn, mul, tick, player}] — phun lửa (Rồng Non, Viêm Long, Long Tức)
	var breaths: Array = []
	## id quái → [giây còn, Tấn công gốc] — Búa rèn +20%
	var buffs := {}
	## [{pos, r, ttl, acc}] — vòng lửa Bộ Hoả Ngục 6 món
	var rings: Array = []
	## Viêm Long
	var fly := false
	## thời gian trong lượt bay hiện tại (giai đoạn 2); landed = đang đáp, land_t/land_taken = thời gian/sát thương lần đáp này
	var flood_t := 0.0
	var flooding := false
	var landed := false
	var land_t := 0.0
	var land_taken := 0.0
	## Phượng Hoàng
	var water_t := -99.0
	var reborn := false
	var egg_t := 0.0
	## [{pos, t, atk}] — Mưa lông lửa
	var feathers: Array = []
	var feather_ready := 0.0
	## Công Trại
	var siege := false
	var siege_raid := false
	var wave := 0
	var wave_gap := 0.0
	var gate_hp := 0.0
	var gate_max := 0.0
	var siege_time := 0.0
	var gate_hit := {}
	var raid_warn := -1.0
	var tl_boosted := {}
	## id Thằn Lằn → giây tích luỹ tới vệt lửa kế tiếp
	var trail_acc := {}


static func ensure(w) -> void:
	var q: Dictionary = w.profile.quest
	for k in ["ch5", "kills5"]:
		if not q.has(k):
			q[k] = 0
	if not q.has("raid_won"):
		q["raid_won"] = false


static func in_region(w) -> bool:
	return int(w.map.get("region", 1)) == 5


# ================================================================ môi trường


## C5-10: dung nham — map có `lava` = [[tâm, r], …].
static func in_lava(w, pos: Vector2) -> bool:
	for z in w.map.get("lava", []):
		if pos.distance_to(z[0]) <= float(z[1]):
			return true
	return false


## C5-12: trong 5 m quanh dung nham (không đứng trong).
static func near_lava(w, pos: Vector2) -> bool:
	for z in w.map.get("lava", []):
		var d: float = pos.distance_to(z[0])
		if d > float(z[1]) and d <= float(z[1]) + HEAT_R:
			return true
	return false


static func rocks(w) -> Array:
	var out: Array = []
	for i in ROCKS:
		out.append(w.arena_pos + Vector2.from_angle(TAU * i / ROCKS + 0.3) * (w.arena_r * 0.62))
	return out


static func on_rock(w, pos: Vector2) -> bool:
	for r in rocks(w):
		if pos.distance_to(r) <= ROCK_R + w.PLAYER_RADIUS:
			return true
	return false


## Sát thương môi trường hệ Hỏa (dung nham, thiên thạch, ngập dung nham): bỏ qua Phòng thủ, Kháng Hỏa giảm được.
static func _fire_pct(w, pct: float) -> float:
	var res: float = float(w.stats.get("res", {}).get("hoa", 0.0))
	return float(w.stats.max_hp) * pct * (1.0 - clampf(res, 0.0, 0.9))


## Không gục dưới 1 HP (Q60) — trừ ngập dung nham trong Long Huyệt.
static func _env_hurt(w, amount: float, can_kill := false) -> void:
	var p = w.player
	if p.dead_timer > 0.0 or amount <= 0.0:
		return
	p.hp -= amount
	w._last_combat = w.time
	if p.hp <= 0.0:
		if can_kill and not _feather_revive(w):
			w._die()
		elif not can_kill:
			p.hp = 1.0


static func on_load(w) -> void:
	ensure(w)
	var st = w.ch5
	st.meteors = []
	st.trails = []
	st.pillars = []
	st.breaths = []
	st.buffs = {}
	st.rings = []
	st.feathers = []
	st.trail_acc = {}
	st.fly = false
	st.flooding = false
	st.flood_t = 0.0
	st.landed = false
	st.reborn = false
	st.egg_t = 0.0
	st.erupt_t = ERUPT_PERIOD
	st.raid_warn = -1.0
	if st.siege:
		_end_siege(w, false, true)
	if in_region(w) and int(w.profile.quest.ch5) == 0:
		w.profile.quest.ch5 = 1
		w.say("r5_arrive")


static func tick(w, dt: float) -> void:
	ensure(w)
	var st = w.ch5
	var p = w.player
	if p.dodge_time > 0.0 and w.has_unique("long_tam"):
		st.lava_immune = LONG_TAM_IMMUNE
	st.lava_immune -= dt
	_tick_rings(w, dt)
	_tick_breaths(w, dt)
	_tick_buffs(w, dt)
	_tick_traps(w)
	if not in_region(w):
		if st.heat:
			st.heat = false
			w._refresh_stats()
		return
	var alive: bool = p.dead_timer <= 0.0
	# Dung nham
	if alive and in_lava(w, p.pos) and p.dodge_time <= 0.0 and st.lava_immune <= 0.0:
		_env_hurt(w, _fire_pct(w, LAVA_PCT) * dt)
	# Nhiệt
	var heat: bool = alive and near_lava(w, p.pos)
	if heat != st.heat:
		st.heat = heat
		w._refresh_stats()
	# Núi lửa phun
	if bool(w.map.get("eruption", false)):
		st.erupt_t -= dt
		if st.erupt_t <= 0.0:
			st.erupt_t = ERUPT_PERIOD
			for i in ERUPT_COUNT:
				var pos: Vector2 = p.pos + Vector2.from_angle(w._r() * TAU) * (w._r() * ERUPT_SPREAD)
				st.meteors.append({"pos": pos.clamp(Vector2(40, 40), w.world_size - Vector2(40, 40)), "t": METEOR_WARN + i * 0.15})
			w._sfx("explode")
	for m in st.meteors:
		m.t -= dt
		if m.t <= 0.0:
			w._blast(m.pos, METEOR_R, Color("#ff7a1a"))
			if alive and p.pos.distance_to(m.pos) <= METEOR_R + w.PLAYER_RADIUS and p.dodge_time <= 0.0:
				_env_hurt(w, _fire_pct(w, METEOR_PCT))
				w._text(p.pos + Vector2(0, -36), "Thiên thạch!", Color("#ff7a1a"), true)
	st.meteors = st.meteors.filter(func(m): return m.t > 0.0)
	# Vệt lửa, Cột lửa, Mưa lông lửa
	for t in st.trails:
		t.ttl -= dt
		t.acc += dt
		if t.acc >= 0.5:
			t.acc -= 0.5
			if alive and p.pos.distance_to(t.pos) <= TRAIL_R + w.PLAYER_RADIUS and p.dodge_time <= 0.0:
				w._incoming_el = "hoa"
				w._damage_player(t.atk, TRAIL_MUL)
	st.trails = st.trails.filter(func(t): return t.ttl > 0.0)
	for pl in st.pillars:
		pl.t -= dt
		if pl.t <= 0.0:
			w._blast(pl.pos, PILLAR_R, Color("#ff5a1a"))
			if alive and p.pos.distance_to(pl.pos) <= PILLAR_R + w.PLAYER_RADIUS:
				w._incoming_el = "hoa"
				w._damage_player(pl.atk, PILLAR_MUL)
	st.pillars = st.pillars.filter(func(pl): return pl.t > 0.0)
	for f in st.feathers:
		f.t -= dt
		if f.t <= 0.0:
			w._blast(f.pos, FEATHER_R, Color("#ffb347"))
			if alive and p.pos.distance_to(f.pos) <= FEATHER_R + w.PLAYER_RADIUS:
				w._incoming_el = "hoa"
				w._damage_player(f.atk, 1.0)
	st.feathers = st.feathers.filter(func(f): return f.t > 0.0)
	_tick_dragon(w, dt)
	_tick_siege(w, dt)
	_tick_raid(w, dt)


# ================================================================ quái


static func enemy_avoid(w, e, pos: Vector2) -> bool:
	# C5-10: quái không bước vào dung nham (trừ Linh Hồn Lửa — nó tắt trong đó, và boss bay).
	if not in_region(w) or e.kind == "linh-hon-lua" or e.role == "boss" or e.role == "rare":
		return false
	return in_lava(w, pos) and not in_lava(w, e.pos)


static func is_hidden(e) -> bool:
	return e.kind == "vien-long" and e.fly_t > 0.0


static func update_enemy(w, e, dt: float) -> bool:
	var st = w.ch5
	# Linh Hồn Lửa lạc vào dung nham thì tắt (C5-22).
	if e.kind == "linh-hon-lua" and in_lava(w, e.pos):
		e.dead = true
		w._text(e.pos + Vector2(0, -20), "Tắt lửa", Color("#868082"), false)
		return true
	# Thằn Lằn chạy để lại vệt lửa.
	if e.kind == "than-lan-lua" and e.state == "chase":
		var acc: float = float(st.trail_acc.get(e.id, 0.0)) + dt
		if acc >= TRAIL_EVERY:
			acc = 0.0
			st.trails.append({"pos": e.pos, "ttl": TRAIL_TTL, "atk": e.atk, "acc": 0.0})
		st.trail_acc[e.id] = acc
	# Phun lửa đang diễn ra: đứng yên.
	for b in st.breaths:
		if int(b.id) == e.id:
			return true
	if e.kind == "vien-long" and e.role == "boss":
		return _update_dragon(w, e, dt)
	if e.kind == "phuong-hoang" and st.egg_t > 0.0:
		return true
	if e.role == "siege":
		return _update_siege_mob(w, e, dt)
	return false


static func chase(w, e, d: float, dt: float) -> bool:
	match e.kind:
		"vien-long":
			e.skill_cd -= dt
			if e.skill_cd <= 0.0 and d < DRAGON_BREATH_RANGE + 40.0:
				e.skill_cd = RAGE_BREATH_CD if e.phase >= 3 else DRAGON_BREATH_CD
				w._begin_attack(e, "dbreath", 0.8)
				return true
		"phuong-hoang":
			e.skill_cd -= dt
			e.pounce_cd -= dt
			if e.pounce_cd <= 0.0 and d < DIVE_LEN:
				e.pounce_cd = DIVE_CD
				w._begin_attack(e, "pdive", 0.8)
				return true
			if e.skill_cd <= 0.0:
				e.skill_cd = FEATHER_CD
				var atk: float = e.atk
				for i in FEATHERS:
					var pos: Vector2 = w.player.pos + Vector2.from_angle(w._r() * TAU) * (w._r() * FEATHER_SPREAD)
					w.ch5.feathers.append({"pos": pos, "t": FEATHER_WARN, "atk": atk})
				w._text(e.pos + Vector2(0, -e.radius - 24), "Mưa lông lửa!", Color("#ffb347"), true)
	return false


static func elite_skill(w, e, kind: String) -> bool:
	match kind:
		"flamebreath":
			e.skill_cd = BREATH_CD
			_start_breath(w, e, BREATH_TIME, BREATH_RANGE, BREATH_ARC, BREATH_TURN, BREATH_MUL, BREATH_TICK)
			w._text(e.pos + Vector2(0, -e.radius - 24), "Phun lửa!", Color("#ff7a1a"), true)
			return true
		"forgehammer":
			e.skill_cd = HAMMER_CD
			w._begin_attack(e, "hammer", 0.8)
			return true
	return false


static func perform(w, e) -> bool:
	var p = w.player
	var reach: float = e.radius + e.attack_range + w.PLAYER_RADIUS + 10.0
	match e.attack_kind:
		"punch":
			if e.pos.distance_to(p.pos) <= reach:
				w._damage_player(e.atk, PUNCH_MUL)
		"fireburst":
			w._blast(e.pos, BURST_R, Color("#ff7a1a"))
			w._sfx("explode")
			if e.pos.distance_to(p.pos) <= BURST_R + w.PLAYER_RADIUS:
				w._incoming_el = "hoa"
				w._damage_player(e.atk, 1.0)
			e.dead = true
		"firepillar":
			var dir: Vector2 = (e.target - e.pos).normalized() if e.target.distance_to(e.pos) > 1.0 else Vector2.RIGHT
			var dist: float = e.pos.distance_to(e.target)
			for k in PILLARS:
				var at: Vector2 = e.pos + dir * dist * float(k + 1) / float(PILLARS)
				w.ch5.pillars.append({"pos": at, "t": PILLAR_GAP * k + 0.05, "atk": e.atk})
		"hammer":
			w._blast(e.pos, HAMMER_R, Color("#b36b3a"))
			if e.pos.distance_to(p.pos) <= HAMMER_R + w.PLAYER_RADIUS:
				w._damage_player(e.atk, HAMMER_MUL)
			for o in w.enemies:
				if not o.dead and o != e and o.pos.distance_to(e.pos) <= HAMMER_BUFF_R and not w.ch5.buffs.has(o.id):
					w.ch5.buffs[o.id] = [HAMMER_TIME, o.atk]
					o.atk *= HAMMER_BUFF
			w._text(e.pos + Vector2(0, -e.radius - 24), "Búa rèn! Quái quanh +20% Tấn công", Color("#ff5470"), true)
		"claw":
			if e.pos.distance_to(p.pos) <= reach:
				w._incoming_el = "hoa"
				w._damage_player(e.atk, CLAW_MUL)
		"dbreath":
			_start_breath(w, e, DRAGON_BREATH_TIME, DRAGON_BREATH_RANGE, DRAGON_BREATH_ARC, DRAGON_BREATH_TURN,
				DRAGON_BREATH_MUL, DRAGON_BREATH_TICK)
		"featherbolt":
			w._enemy_shot(e, (e.target - e.pos).angle(), 1.0, 380.0)
		"pdive":
			var from: Vector2 = e.pos
			var to: Vector2 = (e.pos + (e.target - e.pos).normalized() * DIVE_LEN).clamp(Vector2(30, 30), w.world_size - Vector2(30, 30))
			e.pos = to
			if Geometry2D.get_closest_point_to_segment(p.pos, from, to).distance_to(p.pos) <= e.radius + w.PLAYER_RADIUS:
				w._incoming_el = "hoa"
				w._damage_player(e.atk, DIVE_MUL)
		_:
			return false
	return true


static func _start_breath(w, e, time: float, reach: float, arc: float, turn: float, mul: float, tick_every: float) -> void:
	w.ch5.breaths.append({"id": e.id, "t": time, "ang": (w.player.pos - e.pos).angle(), "acc": 0.0, "range": reach,
		"arc": arc, "turn": turn, "mul": mul, "tick": tick_every, "player": false})


static func _tick_breaths(w, dt: float) -> void:
	var st = w.ch5
	var p = w.player
	for b in st.breaths:
		b.t -= dt
		b.acc += dt
		if b.player:
			if b.acc >= b.tick:
				b.acc -= b.tick
				for e in w.enemies:
					var off: Vector2 = e.pos - p.pos
					if not e.dead and off.length() <= b.range + e.radius and absf(angle_difference(b.ang, off.angle())) <= b.arc:
						w._hit_enemy(e, b.mul)
			continue
		var src = _enemy_by_id(w, int(b.id))
		if src == null or src.dead or src.state == "stunned":
			b.t = 0.0
			continue
		b.ang = rotate_toward(float(b.ang), (p.pos - src.pos).angle(), float(b.turn) * dt)
		src.face = b.ang
		if b.acc >= b.tick:
			b.acc -= b.tick
			var off2: Vector2 = p.pos - src.pos
			if off2.length() <= float(b.range) + src.radius + w.PLAYER_RADIUS and absf(angle_difference(float(b.ang), off2.angle())) <= float(b.arc):
				w._incoming_el = "hoa"
				w._damage_player(src.atk, float(b.mul))
	st.breaths = st.breaths.filter(func(b): return b.t > 0.0)


static func _tick_buffs(w, dt: float) -> void:
	var st = w.ch5
	for id in st.buffs.keys():
		var b: Array = st.buffs[id]
		b[0] = float(b[0]) - dt
		if float(b[0]) <= 0.0:
			var e = _enemy_by_id(w, int(id))
			if e != null:
				e.atk = float(b[1])
			st.buffs.erase(id)


static func _enemy_by_id(w, id: int):
	for e in w.enemies:
		if e.id == id:
			return e
	return null


## Người Đá vỡ thành Mảnh Đá; Mảnh Đá và lính đột kích không tính EXP/đồ theo cách thường.
static func vanish(w, e) -> bool:
	if e.kind == "manh-da":
		w._blast(e.pos, 18.0, Color("#6a6470"))
		return true
	return false


static func on_kill(w, e) -> void:
	ensure(w)
	var p = w.profile
	if e.kind == "nguoi-da" and not e.elite and e.role != "siege":
		for i in SHARDS:
			var s = w.spawn_enemy("manh-da", e.level, e.pos + Vector2.from_angle(TAU * i / SHARDS) * 24.0, {"role": "summon"})
			s.max_hp = maxf(1.0, e.max_hp * SHARD_HP)
			s.hp = s.max_hp
			s.state = "chase"
	if in_region(w) and int(p.quest.ch5) == 2 and e.role in ["field", "nestMinion", "nestGuard"]:
		p.quest.kills5 = int(p.quest.kills5) + 1
	# Tử Linh Sư: dựng Xương Nô.
	if job2(w) == "tu-linh-su" and e.role == "field" and not e.elite and w._r() < TL_CHANCE and _bones(w) < TL_MAX:
		var a = w._add_ally("shadow", "xuong-no", e.level, e.pos)
		a.kind = "bone"
		a.atk = float(w.stats.atk) * TL_ATK
		a.ttl = TL_TTL
		a.color = Color("#d2c8b2")
		w._text(e.pos + Vector2(0, -24), "Xương Nô!", Color("#d2c8b2"), false)


static func _bones(w) -> int:
	var n := 0
	for a in w.allies:
		if not a.dead and a.kind == "bone":
			n += 1
	return n


static func on_player_hit(w, e) -> void:
	if e.dead:
		return
	if e.kind == "phuong-hoang" and _water_hit(w):
		w.ch5.water_t = w.time
		w._text(e.pos + Vector2(0, -e.radius - 30), "Hệ Thủy!", Color("#4fc3ff"), false)


## Đòn hệ Thủy: Băng Ngục, Ngũ Hành hệ Thủy, Hỏa Cầu của Pháp Sư Nguyên Tố (tự đổi sang hệ khắc Hỏa = Thủy).
static func _water_hit(w) -> bool:
	var src := str(w.hit_source)
	if src == "nova":
		return true
	if src == "fireball" and str(w.profile.job) == "phap-su-nguyen-to":
		return true
	return str(w.profile.talent) == "ngu-hanh" and str(w.profile.element) == "thuy"


static func adjust_damage(w, e, dmg: int, by_player: bool) -> int:
	var st = w.ch5
	if e.kind == "vien-long" and e.fly_t > 0.0:
		return 0
	if e.kind == "vien-long" and st.landed:
		st.land_taken += dmg
	if e.kind == "phuong-hoang":
		if st.egg_t > 0.0:
			return 0
		if not st.reborn and e.hp - dmg <= 0.0:
			if w.time - st.water_t <= WATER_WINDOW:
				w._message("Nước Thánh dập tắt ngọn lửa — Phượng Hoàng không thể tái sinh!", "good")
				return dmg
			st.reborn = true
			st.egg_t = REBIRTH_TIME
			e.state = "idle"
			w._message("Niết bàn! Phượng Hoàng hoá trứng lửa và sẽ tái sinh — lần sau đánh hệ Thủy trước khi hạ nó!", "bad")
			return maxi(0, int(e.hp) - 1)
	# Khiên phía trước: Thợ Rèn Hư Vô, 1/3 Lính Kim Luân.
	if by_player and e.state != "stunned" and ((e.kind == "nguoi-da" and e.elite) or (e.kind == "linh-kim-luan" and e.id % 3 == 0)) \
			and absf(angle_difference(e.face, (w.player.pos - e.pos).angle())) <= w.SHIELD_ARC:
		w._text(e.pos + Vector2(0, -e.radius - 22), "Chặn!", Color("#9ba8bc"), false)
		dmg = maxi(1, roundi(dmg * w.SHIELD_REDUCE))
	# Huyết Kiếm: hút máu.
	if by_player and job2(w) == "huyet-kiem":
		w.player.hp = minf(float(w.stats.max_hp), w.player.hp + dmg * HK_LEECH)
	return dmg


static func hit_mult(w, e, crit: bool) -> float:
	var k := 1.0
	if w.has_unique("long_tam") and Ch4._fire_hit(w):
		k *= 1.0 + LONG_TAM_FIRE
	match job2(w):
		"huyet-kiem":
			if w.player.hp < float(w.stats.max_hp) * HK_LOW:
				k *= HK_MUL
		"than-tien":
			if crit:
				k *= TT_CRIT_MUL
		"tu-linh-su":
			k *= 1.0 + TL_BONUS * _bones(w)
	return k


static func boss_phase_two(w, e) -> bool:
	return e.kind == "vien-long"


# ---------------------------------------------------------------- Viêm Long


static func _update_dragon(w, e, dt: float) -> bool:
	var st = w.ch5
	if e.phase == 1 and e.hp <= e.max_hp * 0.6:
		e.phase = 2
		st.flood_t = 0.0
		st.landed = false
		w.say("boss5_flood")
		w._message("Viêm Long bay lên! Dung nham sẽ dâng theo lượt — đứng trên Đá Nổi khi nền đỏ rực.", "bad")
	if e.phase == 2 and e.hp <= e.max_hp * 0.2:
		e.phase = 3
		e.fly_t = 0.0
		st.flooding = false
		st.landed = false
		e.haste_timer = 9999.0
		e.skill_cd = 0.5
		w._message("Viêm Long rơi xuống — Cuồng nộ! Tốc đánh +30%, Long tức liên tục.", "bad")
	if e.phase != 2:
		st.flooding = false
		st.landed = false
		return false
	if st.landed:
		st.land_t += dt
		if st.land_t >= LAND_TIME or st.land_taken >= e.max_hp * LAND_DAMAGE:
			st.landed = false
			st.flood_t = 0.0
			e.fly_t = 1.0
			w._text(e.pos + Vector2(0, -e.radius - 30), "Viêm Long bay lên!", Color("#ff9a3c"), true)
			return true
		return false
	st.flood_t += dt
	st.flooding = st.flood_t >= FLOOD_WARN and st.flood_t < FLOOD_WARN + FLOOD_TIME
	var landed: bool = st.flood_t >= FLOOD_WARN + FLOOD_TIME
	e.fly_t = 0.0 if landed else 1.0
	# Đáp xuống ngay cạnh người chơi (lớp cận chiến không phải chạy theo từ Đá Nổi).
	if landed:
		st.landed = true
		st.flooding = false
		st.land_t = 0.0
		st.land_taken = 0.0
		var pp: Vector2 = w.player.pos
		var toward: Vector2 = (w.arena_pos - pp).normalized() if pp.distance_to(w.arena_pos) > 1.0 else Vector2.RIGHT
		e.pos = w._clamp_to_arena(pp + toward * LAND_GAP, e.radius)
		e.state = "chase"
		# vừa đáp không phun Long tức ngay (người chơi kịp đổi vị trí)
		e.skill_cd = maxf(e.skill_cd, LAND_BREATH_DELAY)
		w._blast(e.pos, e.radius + 20.0, Color("#ff7a1a"))
		w._text(e.pos + Vector2(0, -e.radius - 30), "Viêm Long đáp xuống!", Color("#ff9a3c"), true)
		return false
	if not landed:
		e.state = "idle"
		e.pos = e.pos.move_toward(w.arena_pos, 60.0 * dt)
		return true
	return false


static func flood_warning(w) -> bool:
	var b = w.boss()
	if b == null or b.kind != "vien-long" or b.phase != 2 or w.ch5.landed:
		return false
	return w.ch5.flood_t < FLOOD_WARN


static func _tick_dragon(w, dt: float) -> void:
	var st = w.ch5
	var p = w.player
	if not st.flooding:
		return
	var b = w.boss()
	if b == null or b.kind != "vien-long" or b.phase != 2:
		st.flooding = false
		return
	if p.dead_timer <= 0.0 and p.pos.distance_to(w.arena_pos) < w.arena_r and not on_rock(w, p.pos) and st.lava_immune <= 0.0:
		_env_hurt(w, _fire_pct(w, FLOOD_PCT) * dt, true)


# ---------------------------------------------------------------- Phượng Hoàng Tro


static func update_rare(w, e, dt: float) -> bool:
	if e.kind != "phuong-hoang":
		return false
	var st = w.ch5
	if st.egg_t > 0.0:
		st.egg_t -= dt
		e.state = "idle"
		if st.egg_t <= 0.0:
			e.hp = e.max_hp * REBIRTH_HP
			e.state = "chase"
			w._blast(e.pos, 80.0, Color("#ff7a1a"))
			w._message("Phượng Hoàng Tro tái sinh với 50% HP!", "bad")
	return true


## Phím Q: Bình Nước Thánh khi Phượng Hoàng dưới 15% HP và ở gần.
static func drink(w) -> bool:
	var p = w.profile
	if int(p.holy_water) <= 0:
		return false
	var r = w.rare_boss()
	if r == null or r.kind != "phuong-hoang" or r.hp > r.max_hp * HOLY_LOW or r.pos.distance_to(w.player.pos) > 300.0:
		return false
	p.holy_water = int(p.holy_water) - 1
	w.ch5.water_t = w.time
	w._blast(r.pos, 60.0, Color("#4fc3ff"))
	w._text(r.pos + Vector2(0, -40), "Nước Thánh!", Color("#4fc3ff"), true)
	return true


# ---------------------------------------------------------------- Đạo Tặc — Long Tức


static func copy_skill(w, id: String) -> bool:
	if id != "breath":
		return false
	var p = w.player
	w.ch5.breaths.append({"id": -1, "t": COPY_BREATH_TIME, "ang": p.facing, "acc": 0.0, "range": COPY_BREATH_RANGE,
		"arc": deg_to_rad(30.0), "turn": 0.0, "mul": COPY_BREATH_MUL, "tick": COPY_BREATH_TICK, "player": true})
	w._text(p.pos + Vector2(0, -40), "Long Tức!", Color("#ff7a1a"), true)
	return true


# ================================================================ người chơi: đồ, bộ, chuyển chức 2


static func job2(w) -> String:
	return str(w.profile.job2)


static func derive_bonus(w, bonus: Dictionary) -> void:
	if job2(w) != "":
		bonus.max_hp_pct += Classes.JOB2_BONUS
		bonus.atk_pct += Classes.JOB2_BONUS
	if job2(w) == "than-tien":
		bonus.flat["crit"] = float(bonus.flat.get("crit", 0.0)) + TT_CRIT
	if int(bonus.sets.get(HOA_NGUC, 0)) >= 2:
		bonus.flat["res_hoa"] = float(bonus.flat.get("res_hoa", 0.0)) + HOA_NGUC_RES
	if w.ch5.heat:
		bonus.atk_speed_pct += HEAT_SPEED


static func derive_after(w, _bonus: Dictionary, st: Dictionary) -> void:
	if job2(w) == "dai-phap-su":
		st.mp_regen = float(st.mp_regen) * DPS_MP


static func skill_trail(w, pos: Vector2, r: float) -> void:
	if int(Items.equipment_bonus(w.profile.equipment).sets.get(HOA_NGUC, 0)) >= 6:
		w.ch5.rings.append({"pos": pos, "r": r, "ttl": RING_TTL, "acc": 0.0})


static func _tick_rings(w, dt: float) -> void:
	var st = w.ch5
	for g in st.rings:
		g.ttl -= dt
		g.acc += dt
		if g.acc >= 1.0:
			g.acc -= 1.0
			for e in w.enemies:
				if not e.dead and e.pos.distance_to(g.pos) <= float(g.r) + e.radius:
					w._hit_enemy(e, RING_MUL, false, true)
	st.rings = st.rings.filter(func(g): return g.ttl > 0.0)


static func after_slash(w) -> void:
	if job2(w) == "kiem-thanh" and w.player.hits % KT_EVERY == 0:
		w._fire(w.WAVE_SPEED, Ch3.KS_RANGE, KT_MUL, true, "wave", false, 18.0)


static func pierce_cd(w, cd: float) -> float:
	return maxf(1.0, cd - TT_PIERCE) if job2(w) == "than-tien" else cd


static func poise_mult(w, _e) -> float:
	return KT_POISE if job2(w) == "kiem-thanh" else 1.0


static func trap_extra(w) -> int:
	return TB_TRAPS if job2(w) == "tho-bay" else 0


## Thợ Bẫy: bẫy mới đặt sống 40 giây.
static func _tick_traps(w) -> void:
	if job2(w) != "tho-bay":
		return
	var st = w.ch5
	for t in w.traps:
		var k: int = t.get_instance_id()
		if not st.tl_boosted.has(k):
			st.tl_boosted[k] = true
			t.ttl += TB_TTL - w.TRAP_TTL


static func trap_triggered(w, pos: Vector2, mul: float) -> void:
	if job2(w) != "tho-bay":
		return
	w._blast(pos, TB_R, Color("#9ad46a"))
	for e in w.enemies:
		if not e.dead and e.pos.distance_to(pos) <= TB_R + e.radius:
			w._hit_enemy(e, mul * TB_MUL, false, true)


## Đại Pháp Sư: Thiên Thạch rơi thêm 1 viên lệch 3 m, ×0,6. Trả về [[vị trí, hệ số], …] để GameWorld tạo.
static func meteor_extra(w, pos: Vector2, mul: float) -> Array:
	if job2(w) != "dai-phap-su":
		return []
	return [[pos + Vector2.from_angle(w._r() * TAU) * 30.0, mul * DPS_METEOR_MUL]]


## C5-34 Lông Phượng: lần đầu bị hạ thì hồi sinh tại chỗ 30% HP (hồi 5 phút).
static func player_hurt(w, _dmg: float, _element: String) -> void:
	if w.player.hp <= 0.0:
		_feather_revive(w)


static func _feather_revive(w) -> bool:
	var st = w.ch5
	if not w.has_unique("long_phuong") or w.time < st.feather_ready:
		return false
	st.feather_ready = w.time + FEATHER_CD_TIME
	w.player.hp = float(w.stats.max_hp) * FEATHER_REVIVE
	w._blast(w.player.pos, 70.0, Color("#ff9a3c"))
	w._text(w.player.pos + Vector2(0, -50), "Lông Phượng — hồi sinh!", Color("#ffb347"), true)
	return true


static func can_job2(w) -> String:
	var p = w.profile
	if job2(w) != "":
		return "Đã chuyển chức lần 2."
	if str(p.job) == "":
		return "Cần chuyển chức lần 1 trước."
	if not w.is_boss_defeated("vien-long"):
		return "Hạ Viêm Long trước."
	if int(p.level) < Classes.JOB2_LEVEL:
		return "Cần cấp %d (đang %d)." % [Classes.JOB2_LEVEL, int(p.level)]
	if float(p.crystal) < Classes.JOB2_CRYSTAL:
		return "Cần %d Tinh Thạch (có %d)." % [Classes.JOB2_CRYSTAL, int(p.crystal)]
	return ""


static func do_job2(w, id: String) -> bool:
	var why := can_job2(w)
	var j := Classes.job2_def(str(w.profile.class_id), id)
	if why != "" or j.is_empty():
		w._message(why if why != "" else "Nhánh không hợp lệ.", "bad")
		return false
	w.profile.crystal = float(w.profile.crystal) - Classes.JOB2_CRYSTAL
	w.profile.job2 = id
	w._refresh_stats()
	w.player.hp = w.stats.max_hp
	w._events.append({"type": "job", "job": id, "name": j.name})
	w._message("Chuyển chức lần 2: %s! +10%% HP và Tấn công. %s" % [j.name, j.text], "good")
	w._text(w.player.pos + Vector2(0, -50), str(j.name) + "!", Color(j.color), true)
	w._sfx("levelup")
	return true


# ================================================================ Công Trại, đột kích (C5-42, C5-43)


static func gate_pos(w) -> Vector2:
	return w.safe_pos + Vector2(w.safe_r, 0)


static func safe_blocked(w) -> bool:
	return w.ch5.siege


static func start_siege(w, raid := false) -> void:
	var st = w.ch5
	if st.siege:
		return
	st.siege = true
	st.siege_raid = raid
	st.wave = 0
	st.wave_gap = 0.5
	st.siege_time = 0.0
	st.gate_max = GATE_HP_PER_LEVEL * int(w.profile.level)
	st.gate_hp = st.gate_max
	st.gate_hit = {}
	w._message(("Đột kích Kim Luân! " if raid else "Công Trại! ") + "Giữ Cổng Trại qua %d đợt lính." % (1 if raid else SIEGE_WAVES.size()), "bad")
	w._sfx("boss_roar")


static func _spawn_wave(w) -> void:
	var st = w.ch5
	var waves: Array = [[["linh-kim-luan", 8], ["nguoi-da*", 1]]] if st.siege_raid else SIEGE_WAVES
	var groups: Array = waves[st.wave]
	var lv: int = int(w.profile.level)
	var dirs := [Vector2(620, -220), Vector2(260, 560)]
	var n := 0
	for g in groups:
		var kind: String = str(g[0])
		var elite: bool = kind.ends_with("*")
		kind = kind.trim_suffix("*")
		for i in int(g[1]):
			var base: Vector2 = w.safe_pos + dirs[n % 2]
			var pos: Vector2 = (base + Vector2(w._r() - 0.5, w._r() - 0.5) * 160.0).clamp(Vector2(40, 40), w.world_size - Vector2(40, 40))
			var e = w.spawn_enemy(kind, lv, pos, {"role": "siege", "elite": elite and kind == "nguoi-da"})
			if kind == "doi-truong-kim-luan":
				e.max_poise = e.max_hp * w.ELITE_POISE
				e.poise = e.max_poise
				e.elite = true
				e.max_hp *= 3.0
				e.hp = e.max_hp
			e.state = "chase"
			n += 1
	st.wave += 1
	w._message("Đợt %d/%d!" % [st.wave, waves.size()], "bad")


static func _tick_siege(w, dt: float) -> void:
	var st = w.ch5
	if not st.siege:
		return
	st.siege_time += dt
	if w.player.dead_timer > 0.0 or st.gate_hp <= 0.0 or (st.siege_raid and st.siege_time > RAID_TIME):
		_end_siege(w, false)
		return
	var alive: int = w.enemies.filter(func(e): return not e.dead and e.role == "siege").size()
	var total: int = 1 if st.siege_raid else SIEGE_WAVES.size()
	if alive == 0:
		if st.wave >= total:
			_end_siege(w, true)
			return
		st.wave_gap -= dt
		if st.wave_gap <= 0.0:
			st.wave_gap = WAVE_GAP
			_spawn_wave(w)


static func _update_siege_mob(w, e, dt: float) -> bool:
	var st = w.ch5
	if not st.siege:
		return false
	if e.pos.distance_to(w.player.pos) < SIEGE_AGGRO or e.state in ["windup", "recover", "stunned"]:
		return false
	var g := gate_pos(w)
	if e.pos.distance_to(g) > e.radius + 30.0:
		w._move_toward(e, g, e.speed, dt)
		e.face = (g - e.pos).angle()
		return true
	var cd: float = float(st.gate_hit.get(e.id, 0.0)) - dt
	if cd <= 0.0:
		cd = GATE_HIT_CD
		st.gate_hp = maxf(0.0, st.gate_hp - e.atk * GATE_HIT)
		w._text(g + Vector2(0, -40), "Cổng -%d" % roundi(e.atk * GATE_HIT), Color("#ff9a3c"), false)
	st.gate_hit[e.id] = cd
	return true


static func _end_siege(w, won: bool, silent := false) -> void:
	var st = w.ch5
	var raid: bool = st.siege_raid
	st.siege = false
	st.siege_raid = false
	for e in w.enemies:
		if e.role == "siege":
			e.dead = true
	if silent:
		return
	var p = w.profile
	if raid:
		if won:
			var gold := roundi(300.0 * float(p.level) / 50.0)
			p.gold += gold
			p.crystal = float(p.crystal) + 3.0
			w._message("Đẩy lui đột kích! +%d vàng, +3 Tinh Thạch." % gold, "good")
		else:
			p.raid_penalty_until = float(p.build_clock) + RAID_PENALTY
			w._message("Đột kích thắng thế — công trình vùng 5 ngừng sản xuất 30 phút.", "bad")
		return
	if won:
		p.quest.raid_won = true
		w._message("Cổng Trại đứng vững! Lính Kim Luân tháo chạy.", "good")
	else:
		w.say("siege_lost")
		w._message("Công Trại thất bại — nói với Xích Đồng (E) để đánh lại.", "bad")


static func _tick_raid(w, dt: float) -> void:
	var st = w.ch5
	var p = w.profile
	if int(p.quest.ch5) < Story.DONE5 or st.siege:
		return
	p.raid_play = float(p.raid_play) + dt
	if p.raid_play >= RAID_EVERY - RAID_WARN and st.raid_warn < 0.0:
		st.raid_warn = RAID_WARN
		w._force_say("raid_warn")
	if st.raid_warn >= 0.0:
		st.raid_warn -= dt
		if st.raid_warn <= 0.0:
			st.raid_warn = -1.0
			p.raid_play = 0.0
			start_siege(w, true)


## Tinh Thạch / Mỏ vùng 5 đang bị phạt ngừng sản xuất.
static func raid_penalty(p) -> bool:
	return float(p.build_clock) < float(p.raid_penalty_until)


# ================================================================ nhiệm vụ chương 5 (C5-41)


static func quest(w) -> Dictionary:
	ensure(w)
	return Story.quest5(int(w.profile.quest.ch5))


static func _grid5(w) -> Array:
	var p = w.profile
	return p.tiles if int(p.tiles_region) == 5 else p.grid_of(5)


static func quest_status(w) -> Array:
	var q := quest(w)
	if q.is_empty():
		return [0, 0]
	match str(q.type):
		"kills5":
			return [mini(int(w.profile.quest.kills5), int(q.need)), int(q.need)]
		"tiles5":
			return [mini(Explore.owned_count(_grid5(w)), int(q.need)), int(q.need)]
	return [0, int(q.need)]


static func check_quest(w) -> void:
	var q := quest(w)
	if q.is_empty():
		return
	var done := false
	match str(q.type):
		"kills5":
			done = int(w.profile.quest.kills5) >= int(q.need)
		"tiles5":
			var g := _grid5(w)
			done = Explore.owned_count(g) >= int(q.need) and g.any(func(t): return t.event == "mine" and t.status == "owned")
		"siege5":
			done = bool(w.profile.quest.raid_won)
		"explore5":
			done = w.map_id == "5-3" and w.explore_ratio("5-3") >= 0.4
		"boss5":
			done = w.is_boss_defeated("vien-long")
		"job2":
			done = job2(w) != ""
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
	p.holy_water = int(p.holy_water) + int(r.get("holy_water", 0))
	var rt := Story.reward_text(r)
	w._message("Nhiệm vụ chương 5 hoàn thành: %s%s" % [q.title, (". Thưởng: " + rt) if rt != "" else ""], "good")
	var step := int(p.quest.ch5)
	p.quest.ch5 = step + 1
	w._events.append({"type": "quest_done", "step": step, "chapter": 5})
	if r.has("exp"):
		w.add_exp(float(r.exp), false)
	match step:
		1:
			w.say("kim_task")
		2:
			w.say("xich_land")
		3:
			w.say("kim_betray")
		4:
			w.say("siege_won")
		5:
			w.say("dragon_gate")
		6:
			w.say("dragon_down")
		7:
			w.say("ch5_done")
			w._events.append({"type": "chapter_end", "chapter": 5})


## Bấm E. Trả về "shop" (mở cửa hàng), "job2" (mở bảng chọn nhánh chuyển chức 2) hoặc "".
static func talk(w, npc_id: String) -> String:
	ensure(w)
	var step := int(w.profile.quest.ch5)
	match npc_id:
		"xich-dong":
			if step == 1:
				w._force_say("xich_meet")
				advance(w)
				return ""
			if step == 4 and not w.ch5.siege:
				w._force_say("siege_start")
				start_siege(w)
				return ""
			w._force_say("xich_crater" if step == 5 else "xich_idle")
			return ""
		"kim-phu":
			w._force_say("kim_task" if step == 2 else "kim_shop")
			return "shop"
		"tieu-hoa":
			w._force_say("tieu_hoa_shop")
			return "shop"
		"liet-dien":
			if can_job2(w) == "":
				w._force_say("liet_job")
				return "job2"
			w._force_say("liet_wait" if job2(w) == "" else "ch5_done")
			return ""
	return ""


## Kim Phú bỏ trốn sau bước 4, Tiểu Hoả bán thay (C5-40).
static func npc_visible(w, npc_id: String) -> bool:
	ensure(w)
	var step := int(w.profile.quest.ch5)
	match npc_id:
		"kim-phu":
			return step <= 4 and not bool(w.profile.quest.raid_won)
		"tieu-hoa":
			return step > 4 or bool(w.profile.quest.raid_won)
	return true


static func map_requirement(w, id: String) -> String:
	match id:
		"5-1":
			# C5-01: tiến hoá 1 lần + hạ Nữ Vương + cấp 44.
			if not w.is_boss_defeated("nu-vuong"):
				return "Hạ Nữ Vương Phệ Mộng trước."
			if not Ch4.evolved_once(w.profile):
				return "Cần tiến hoá Thiên phú lần 1 (Tinh Quang Sứ ở Làng Chài Lau)."
			if int(w.profile.level) < 44:
				return "Cần cấp 44."
		"5-2":
			return "" if "5-1" in w.profile.unlocked_maps else "Tới Chân Núi Tro trước."
		"5-3":
			return "" if "5-2" in w.profile.unlocked_maps else "Tới Sườn Dung Nham trước."
	return ""


static func gate_open(w, id: String) -> bool:
	ensure(w)
	if id == "5-3":
		return int(w.profile.quest.ch5) >= 6 or w.is_boss_defeated("vien-long")
	return true


static func env_text(w) -> String:
	if not in_region(w):
		return ""
	var st = w.ch5
	var parts := PackedStringArray()
	if st.siege:
		parts.append("%s · đợt %d/%d · Cổng %d%%" % ["Đột kích" if st.siege_raid else "Công Trại", st.wave, 1 if st.siege_raid else SIEGE_WAVES.size(),
			roundi(st.gate_hp / maxf(1.0, st.gate_max) * 100.0)])
	elif st.raid_warn >= 0.0:
		parts.append("Lính Kim Luân đột kích sau %d giây — về trại!" % ceili(st.raid_warn))
	if flood_warning(w):
		parts.append("DUNG NHAM SẮP DÂNG — lên Đá Nổi!")
	elif st.flooding:
		parts.append("Dung nham ngập Long Huyệt — đứng trên Đá Nổi")
	if bool(w.map.get("eruption", false)):
		parts.append(("Núi lửa SẮP PHUN!" if st.erupt_t <= ERUPT_WARN else "Núi lửa phun sau %d:%02d" % [int(st.erupt_t) / 60, int(st.erupt_t) % 60]))
	if st.heat:
		parts.append("Gần dung nham: +10% tốc đánh")
	if in_lava(w, w.player.pos) and st.lava_immune <= 0.0:
		parts.append("ĐANG ĐỨNG TRONG DUNG NHAM")
	var r = w.rare_boss()
	if r != null and r.kind == "phuong-hoang" and int(w.profile.holy_water) > 0 and r.hp <= r.max_hp * HOLY_LOW:
		parts.append("Q: Bình Nước Thánh (%d)" % int(w.profile.holy_water))
	return "   ·   ".join(parts)


static func env_alert(w) -> bool:
	var st = w.ch5
	return in_region(w) and (st.siege or st.erupt_t <= ERUPT_WARN or flood_warning(w) or st.flooding or (in_lava(w, w.player.pos) and st.lava_immune <= 0.0))


static func quest_hud(w) -> Dictionary:
	ensure(w)
	var q := quest(w)
	if not q.is_empty():
		var st := quest_status(w)
		var rt := Story.reward_text(q.reward)
		return {"active": true, "title": "CHƯƠNG 5 · NHIỆM VỤ %d/%d" % [int(w.profile.quest.ch5), Story.QUESTS5.size()],
			"lines": [["◆ " + str(q.title) + ("  (%d/%d)" % st if int(st[1]) > 1 else ""), "gold"], [str(q.hint), "text"],
				[("Thưởng: " + rt) if rt != "" else "", "muted"]]}
	if int(w.profile.quest.ch5) >= Story.DONE5:
		return {"done": true, "title": "CHƯƠNG 5 · HOÀN THÀNH ✓",
			"lines": [["Chức: %s" % Classes.title(str(w.profile.class_id), str(w.profile.job), str(w.profile.job2)), "text"],
				["Săn boss hiếm Phượng Hoàng Tro ở Miệng Núi Lửa — 2 lần mỗi ngày", "muted"],
				["Chương 6: Băng Nguyên Bắc Cực — sắp mở", "muted"]]}
	return {}
