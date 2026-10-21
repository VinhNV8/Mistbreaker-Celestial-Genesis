extends RefCounted
## M7 — Chương 4 Đầm Lầy Mộng (docs/11-chuong-4.md). Gắn vào GameWorld qua core/chapters.gd (D38).
## Gồm: nước đầm + độc tích luỹ + Thuốc Giải, ảo ảnh, quái vùng 4, Nữ Vương Phệ Mộng (giấc mơ đảo điều khiển,
## Mộng Châu, vòng sáng), Thuỷ Quái Thất Đầu (7 đầu, đốt bằng hệ Hỏa / Đuốc Lửa), Bộ U Minh, Gối Mộng, Vảy Thất Đầu,
## Mộng Cảnh (Đạo Tặc), nhiệm vụ chương 4, tiến hoá Thiên phú lần 1.

const Monsters = preload("res://scripts/data/monsters.gd")
const Classes = preload("res://scripts/data/classes.gd")
const Story = preload("res://scripts/data/story.gd")
const ItemData = preload("res://scripts/data/items.gd")
const Items = preload("res://scripts/core/items.gd")
const Formulas = preload("res://scripts/core/formulas.gd")
const Talents = preload("res://scripts/data/talents.gd")

const MAPS := ["4-1", "4-2", "4-3"]
const NPCS := ["lao-ngu", "lam-nhi", "tinh-quang"]
const HOOKS := ["on_load", "tick", "check_quest", "after_spawn", "on_kill", "on_player_hit", "vanish", "update_enemy", "chase",
	"perform", "elite_skill", "update_rare", "boss_phase_two", "copy_skill", "adjust_damage", "dodge_hit", "heal_mult",
	"move_mult", "derive_bonus", "input_move", "drink", "map_requirement", "gate_open", "env_text", "env_alert", "quest_hud"]

# ---------------------------------------------------------------- C4-10…12: môi trường
const WATER_SLOW := 0.15
const POISON_EVERY := 10.0
const POISON_MAX := 10
const POISON_PCT := 0.003
const DRY_CLEAR := 3.0
const ILLUSION_CHANCE := 0.2
# ---------------------------------------------------------------- C4-20…25: quái
const TONGUE_PULL := 40.0
const TONGUE_R := 140.0
const LEECH_PCT := 0.01
const SPLIT_CD := 12.0
const WAIL_R := 80.0
const WAIL_MUL := 1.1
const CHOMP_MUL := 1.8
const CHOMP_STUN := 1.0
const TOXRAIN_CD := 12.0
const TOXRAIN_R := 100.0
const TOXRAIN_TIME := 5.0
const ROLL_CD := 14.0
const ROLL_HOLD := 2.0
const ROLL_MUL := 0.6
# ---------------------------------------------------------------- C4-30: Nữ Vương Phệ Mộng
const LULLABY_R := 120.0
const LULLABY_SLOW := 3.0
const SPIKE_MUL := 1.4
const QUEEN_SKILL_CD := 3.5
const DREAM_TIME := 12.0
const ORB_HP := 0.03
const DRAIN_R := 150.0
const DRAIN_PCT := 0.02
const LIGHT_R := 60.0
const LIGHT_SPEED := 0.25
# ---------------------------------------------------------------- C4-33: Thuỷ Quái Thất Đầu
const HEADS := 7
const HEAD_RING := 95.0
const REGROW := 20.0
const BURN_WINDOW := 5.0
const JET_CD := 4.0
const JET_MUL := 1.2
# ---------------------------------------------------------------- đồ, bộ, Mộng Cảnh
const PILLOW_DODGE := 0.15
const SCALE_REGEN := 0.01
const SCALE_RES := 0.2
const U_MINH := "u_minh"
const SWAMP_CHANCE := 0.15
const SWAMP_PCT := 0.003
const CHARM_R := 100.0
const CHARM_TIME := 4.0
# ---------------------------------------------------------------- tiến hoá (C4-43, C4-44)
const EVO_LEVEL_STEP := 9
const EVO_REFUND := 0.5
const SHOP_ANTIDOTE := 40
const SHOP_TORCH := 60


class State:
	var poison := 0
	var water_acc := 0.0
	var dry_acc := 0.0
	var leech_id := -1
	var dream_t := 0.0
	var light_ang := 0.0
	var light_pos := Vector2.ZERO
	## Bọc cắt đầu Thất Đầu: [{pos, t, burned}] — t = giây còn lại tới khi đầu mọc lại.
	var stumps: Array = []
	## Mưa độc của Phù Thuỷ: [{pos, ttl}]
	var rains: Array = []


static func ensure(w) -> void:
	var q: Dictionary = w.profile.quest
	for k in ["ch4", "kills4"]:
		if not q.has(k):
			q[k] = 0
	if not q.has("orbs4"):
		q["orbs4"] = []


static func in_region(w) -> bool:
	return int(w.map.get("region", 1)) == 4


# ================================================================ môi trường


## Nước: map có `water` = {"default": bool, "zones": [[tâm, r], …]} — zones là chỗ NGƯỢC với mặc định.
static func in_water(w, pos: Vector2) -> bool:
	var wd = w.map.get("water", null)
	if wd == null:
		return false
	if pos.distance_to(w.safe_pos) <= w.safe_r:
		return false
	var flip := false
	for z in wd.zones:
		if pos.distance_to(z[0]) <= float(z[1]):
			flip = true
			break
	return bool(wd.default) != flip


static func move_mult(w) -> float:
	return 1.0 - WATER_SLOW if in_region(w) and in_water(w, w.player.pos) and w.player.dodge_time <= 0.0 else 1.0


static func poison_every(w) -> float:
	var sets := int(Items.equipment_bonus(w.profile.equipment).sets.get(U_MINH, 0))
	return POISON_EVERY * (2.0 if sets >= 2 else 1.0)


static func on_load(w) -> void:
	ensure(w)
	var st = w.ch4
	st.leech_id = -1
	st.dream_t = 0.0
	st.stumps = []
	st.rains = []
	if in_region(w) and int(w.profile.quest.ch4) == 0:
		w.profile.quest.ch4 = 1
		w.say("r4_arrive")


static func tick(w, dt: float) -> void:
	ensure(w)
	var st = w.ch4
	var p = w.player
	# Vảy Thất Đầu: hồi 1% HP/giây
	if w.has_unique("vay_that_dau") and p.dead_timer <= 0.0:
		p.hp = minf(float(w.stats.max_hp), p.hp + float(w.stats.max_hp) * SCALE_REGEN * dt)
	# Mưa độc
	for r in st.rains:
		r.ttl -= dt
		r.acc = float(r.get("acc", 0.0)) + dt
		if r.acc >= 0.5:
			r.acc -= 0.5
			if p.pos.distance_to(r.pos) <= TOXRAIN_R + w.PLAYER_RADIUS:
				add_poison(w, 1)
	st.rains = st.rains.filter(func(r): return r.ttl > 0.0)
	# Đỉa bám: hút máu, né lăn để gỡ
	if st.leech_id >= 0:
		var lee = _enemy_by_id(w, st.leech_id)
		if lee == null or lee.dead or p.dodge_time > 0.0 or p.dead_timer > 0.0:
			if lee != null and not lee.dead:
				lee.state = "recover"
				lee.timer = 1.0
				lee.pos = p.pos + Vector2(40, 0)
			st.leech_id = -1
		else:
			lee.pos = p.pos + Vector2(12, -6)
			var drain: float = float(w.stats.max_hp) * LEECH_PCT * dt
			p.hp = maxf(1.0, p.hp - drain)
			lee.hp = minf(lee.max_hp, lee.hp + drain)
	# Giấc mơ / vòng sáng của Nữ Vương
	if st.dream_t > 0.0:
		st.dream_t -= dt
		var orbs: Array = w.enemies.filter(func(e): return not e.dead and e.kind == "mong-chau")
		if orbs.is_empty() or st.dream_t <= 0.0:
			st.dream_t = 0.0
			for o in orbs:
				o.dead = true
			w._message("Bạn tỉnh khỏi giấc mơ!", "good")
	var b = w.boss()
	if b != null and b.kind == "nu-vuong" and b.phase >= 3:
		st.light_ang += LIGHT_SPEED * dt
		st.light_pos = w.arena_pos + Vector2.from_angle(st.light_ang) * (w.arena_r * 0.55)
		if p.pos.distance_to(b.pos) <= DRAIN_R and p.pos.distance_to(st.light_pos) > LIGHT_R and p.dead_timer <= 0.0:
			p.hp -= float(w.stats.max_hp) * DRAIN_PCT * dt
			b.hp = minf(b.max_hp, b.hp + float(w.stats.max_hp) * DRAIN_PCT * dt)
			if p.hp <= 0.0:
				w._die()
	# Thất Đầu: đầu mọc lại
	for s in st.stumps:
		s.t -= dt
		if s.t <= 0.0 and not s.burned:
			var body = w.rare_boss()
			if body != null and body.kind == "thuy-quai":
				_spawn_head(w, body, s.pos)
				w._text(s.pos + Vector2(0, -30), "Đầu mọc lại!", Color("#4a9df8"), true)
	st.stumps = st.stumps.filter(func(s): return s.t > 0.0 and not s.burned)
	if not in_region(w):
		st.poison = 0
		return
	# Độc tích luỹ
	if in_water(w, p.pos) and p.dead_timer <= 0.0:
		st.dry_acc = 0.0
		st.water_acc += dt
		if st.water_acc >= poison_every(w):
			st.water_acc -= poison_every(w)
			add_poison(w, 1)
	else:
		st.water_acc = 0.0
		if st.poison > 0:
			st.dry_acc += dt
			if st.dry_acc >= DRY_CLEAR:
				st.dry_acc = 0.0
				st.poison -= 1
	if st.poison > 0 and p.dead_timer <= 0.0:
		p.hp = maxf(1.0, p.hp - float(w.stats.max_hp) * POISON_PCT * st.poison * dt)


static func add_poison(w, n: int) -> void:
	var st = w.ch4
	st.poison = mini(POISON_MAX, st.poison + n)


static func _enemy_by_id(w, id: int):
	for e in w.enemies:
		if e.id == id:
			return e
	return null


## Phím Q: Thuốc Giải khi có ≥ 3 tầng độc; Đuốc Lửa khi cạnh đầu Thất Đầu vừa bị chặt.
static func drink(w) -> bool:
	var st = w.ch4
	var p = w.profile
	if int(p.fire_torches) > 0:
		for s in st.stumps:
			if not s.burned and w.player.pos.distance_to(s.pos) <= 220.0:
				s.burned = true
				p.fire_torches = int(p.fire_torches) - 1
				w._blast(s.pos, 40.0, Color("#ff7a3c"))
				w._text(s.pos + Vector2(0, -30), "Đốt cháy — không mọc lại!", Color("#ff9a3c"), true)
				return true
	if st.poison >= 3 and int(p.antidotes) > 0:
		st.poison = 0
		p.antidotes = int(p.antidotes) - 1
		w._text(w.player.pos + Vector2(0, -36), "Thuốc Giải: hết độc", Color("#5bd16a"), true)
		w._sfx("heal")
		return true
	return false


static func env_text(w) -> String:
	if not in_region(w):
		return ""
	var parts := PackedStringArray()
	var st = w.ch4
	if st.dream_t > 0.0:
		parts.append("ĐANG MƠ — điều khiển đảo ngược (%d giây) · phá 3 Mộng Châu" % ceili(st.dream_t))
	if st.poison > 0:
		parts.append("Độc %d/%d (−%.1f%% HP/giây)%s" % [st.poison, POISON_MAX, POISON_PCT * 100.0 * st.poison,
			" · Q: Thuốc Giải" if st.poison >= 3 and int(w.profile.antidotes) > 0 else ""])
	if in_water(w, w.player.pos):
		parts.append("Đang lội nước đầm")
	if st.leech_id >= 0:
		parts.append("Đỉa bám — né lăn để gỡ")
	return "   ·   ".join(parts)


static func env_alert(w) -> bool:
	return w.ch4.dream_t > 0.0 or w.ch4.poison >= 5 or w.ch4.leech_id >= 0


static func input_move(w, v: Vector2) -> Vector2:
	return -v if w.ch4.dream_t > 0.0 else v


# ================================================================ quái


static func after_spawn(w, e) -> void:
	# C4-12: 20% quái thường vùng 4 là ảo ảnh.
	if in_region(w) and e.role == "field" and not e.elite and w._r() < ILLUSION_CHANCE:
		e.illusion = true


## Ảo ảnh / Mộng Châu / đầu Thất Đầu: hạ không cho EXP/đồ theo cách thường. true = GameWorld bỏ qua phần thưởng.
static func vanish(w, e) -> bool:
	if e.illusion:
		w._blast(e.pos, 26.0, Color("#b4bac8"))
		w._text(e.pos + Vector2(0, -24), "Ảo ảnh tan biến", Color("#b4bac8"), false)
		return true
	if e.kind == "mong-chau":
		w._blast(e.pos, 30.0, Color("#c28af0"))
		return true
	if e.kind == "dau-thuy-quai":
		w.ch4.stumps.append({"pos": e.pos, "t": REGROW, "cut": BURN_WINDOW, "burned": false})
		w._text(e.pos + Vector2(0, -30), "Chặt đầu! Đốt bằng hệ Hỏa trong 5 giây", Color("#ff9a3c"), true)
		var body = w.rare_boss()
		if body != null and body.kind == "thuy-quai":
			var left: int = w.enemies.filter(func(h): return not h.dead and h.kind == "dau-thuy-quai" and h != e).size()
			if left == 0:
				body.hp = 1.0
				body.puzzle_t = 0.0
				w._apply_damage(body, 1, false, true)
		return true
	return false


static func adjust_damage(w, e, dmg: int, by_player: bool) -> int:
	if by_player and e.illusion:
		return maxi(dmg, int(ceil(e.hp)))
	if e.kind == "nu-vuong" and w.ch4.dream_t > 0.0:
		return 0
	if e.kind == "thuy-quai" and e.hp > 1.0:
		return 0
	return dmg


static func update_enemy(w, e, dt: float) -> bool:
	# Bộ U Minh 6 món: độc trên quái
	if e.swamp_stacks > 0:
		e.swamp_tick += dt
		if e.swamp_tick >= 1.0:
			e.swamp_tick -= 1.0
			w._apply_damage(e, maxi(1, roundi(e.max_hp * SWAMP_PCT * e.swamp_stacks)), false, false)
			if e.dead:
				return true
	# Mộng Cảnh: đánh quái gần nhất, bỏ qua người chơi
	if e.charm_t > 0.0:
		e.charm_t -= dt
		e.skill_cd -= dt
		var other = null
		var bd := INF
		for o in w.enemies:
			if o == e or o.dead:
				continue
			var d: float = o.pos.distance_to(e.pos)
			if d < bd:
				bd = d
				other = o
		if other != null:
			if bd > e.radius + other.radius + 8.0:
				w._move_toward(e, other.pos, e.speed, dt)
			elif e.skill_cd <= 0.0:
				e.skill_cd = 1.0
				w._apply_damage(other, maxi(1, roundi(Formulas.compute_damage(e.atk, other.def, 1.0))), false, false)
		return true
	if e.kind == "nu-vuong" and e.role == "boss":
		if e.phase == 1 and e.hp <= e.max_hp * 0.6:
			_queen_dream(w, e)
		elif e.phase == 2 and e.hp <= e.max_hp * 0.25 and w.ch4.dream_t <= 0.0:
			e.phase = 3
			w.ch4.light_ang = 0.0
			w._message("Phệ mộng! Đứng trong vòng sáng để không bị hút máu.", "bad")
	if e.kind == "mong-chau" or e.kind == "thuy-quai":
		return true
	return false


static func _queen_dream(w, e) -> void:
	e.phase = 2
	w.ch4.dream_t = DREAM_TIME
	for i in 3:
		var pos: Vector2 = w.arena_pos + Vector2.from_angle(TAU * i / 3.0 + 0.4) * (w.arena_r * 0.7)
		var o = w.spawn_enemy("mong-chau", e.level, pos, {"role": "bossMinion"})
		o.max_hp = maxf(1.0, e.max_hp * ORB_HP)
		o.hp = o.max_hp
	w._message("Giấc mơ! Điều khiển bị đảo ngược — phá 3 Mộng Châu để tỉnh.", "bad")
	w._sfx("boss_roar")


static func chase(w, e, d: float, dt: float) -> bool:
	match e.kind:
		"hon-ma":
			if not e.illusion and not e.elite:
				e.pounce_cd -= dt
				if e.pounce_cd <= 0.0:
					e.pounce_cd = SPLIT_CD
					for k in 2:
						var c = w.spawn_enemy("hon-ma", e.level, e.pos + Vector2.from_angle(k * PI + 0.7) * 50.0, {"role": "summon"})
						c.illusion = true
						c.max_hp = 1.0
						c.hp = 1.0
						c.state = "chase"
					w._text(e.pos + Vector2(0, -e.radius - 24), "Phân ảnh!", Color("#b4bac8"), true)
		"nu-vuong":
			e.skill_cd -= dt
			if e.skill_cd <= 0.0:
				e.skill_cd = QUEEN_SKILL_CD
				w._begin_attack(e, "lullaby" if d < LULLABY_R + 20.0 else "spikes", 1.0 if d < LULLABY_R + 20.0 else 0.6)
				return true
		"dau-thuy-quai":
			e.skill_cd -= dt
			if e.skill_cd <= 0.0 and d < 320.0:
				e.skill_cd = JET_CD + w._r() * 1.5
				w._begin_attack(e, "jet", 0.8)
				return true
			return true
	return false


static func elite_skill(w, e, kind: String) -> bool:
	match kind:
		"toxrain":
			e.skill_cd = TOXRAIN_CD
			w.ch4.rains.append({"pos": w.player.pos, "ttl": TOXRAIN_TIME, "acc": 0.0})
			w._text(e.pos + Vector2(0, -e.radius - 24), "Mưa độc!", Color("#7ae07a"), true)
			return true
		"deathroll":
			e.skill_cd = ROLL_CD
			w._begin_attack(e, "deathroll", 0.8)
			return true
	return false


static func perform(w, e) -> bool:
	var p = w.player
	match e.attack_kind:
		"tongue":
			if e.pos.distance_to(p.pos) <= TONGUE_R + w.PLAYER_RADIUS and p.dodge_time <= 0.0:
				if w._damage_player(e.atk, 0.8):
					p.pos = p.pos.move_toward(e.pos, TONGUE_PULL)
					add_poison(w, 1)
					w._text(p.pos + Vector2(0, -36), "Lưỡi độc!", Color("#7ae07a"), false)
		"latch":
			if e.pos.distance_to(p.pos) <= e.radius + e.attack_range + w.PLAYER_RADIUS + 10.0 and p.dodge_time <= 0.0 and w.ch4.leech_id < 0:
				if w._damage_player(e.atk, 0.6):
					w.ch4.leech_id = e.id
					w._text(p.pos + Vector2(0, -36), "Đỉa bám! Né lăn để gỡ", Color("#ff5470"), true)
		"wail":
			w._blast(e.pos, WAIL_R, Color("#b4bac8"))
			if e.pos.distance_to(p.pos) <= WAIL_R + w.PLAYER_RADIUS:
				w._damage_player(e.atk, WAIL_MUL)
		"chomp":
			if e.pos.distance_to(p.pos) <= e.radius + e.attack_range + w.PLAYER_RADIUS + 12.0:
				if w._damage_player(e.atk, CHOMP_MUL):
					p.stun_timer = CHOMP_STUN
					w._text(p.pos + Vector2(0, -36), "Bị kéo xuống nước!", Color("#4a9df8"), true)
		"deathroll":
			if e.pos.distance_to(p.pos) <= e.radius + e.attack_range + w.PLAYER_RADIUS + 12.0 and p.dodge_time <= 0.0:
				p.hold_timer = ROLL_HOLD
				p.stun_timer = ROLL_HOLD
				for k in 4:
					w._damage_player(e.atk, ROLL_MUL)
				w._text(p.pos + Vector2(0, -36), "Cuộn tử thần!", Color("#ff5470"), true)
		"lullaby":
			w._blast(e.pos, LULLABY_R, Color("#c28af0"))
			if e.pos.distance_to(p.pos) <= LULLABY_R + w.PLAYER_RADIUS:
				if w._damage_player(e.atk, 1.0):
					p.slow_timer = LULLABY_SLOW
		"spikes":
			for k in [-1, 0, 1]:
				w._enemy_shot(e, (e.target - e.pos).angle() + k * deg_to_rad(15.0), SPIKE_MUL, 360.0)
		"jet":
			w._enemy_shot(e, (e.target - e.pos).angle(), JET_MUL, 420.0)
		_:
			return false
	return true


## Nữ Vương có ngưỡng giai đoạn riêng (60% / 25%) — chặn giai đoạn 2 kiểu Sói Chúa ở 50%.
static func boss_phase_two(w, e) -> bool:
	return e.kind == "nu-vuong"


static func on_kill(w, e) -> void:
	ensure(w)
	if in_region(w) and int(w.profile.quest.ch4) == 2 and not e.illusion:
		w.profile.quest.kills4 = int(w.profile.quest.kills4) + 1
	if w.ch4.leech_id == e.id:
		w.ch4.leech_id = -1


static func on_player_hit(w, e) -> void:
	if e.dead:
		return
	# Thất Đầu: đòn hệ Hỏa đốt gốc đầu vừa chặt (Hỏa Cầu, Thiên Thạch, Ngũ Hành hệ Hỏa)
	if _fire_hit(w):
		for s in w.ch4.stumps:
			if not s.burned and s.t > REGROW - BURN_WINDOW and e.pos.distance_to(s.pos) <= 140.0:
				s.burned = true
				w._text(s.pos + Vector2(0, -30), "Đốt cháy!", Color("#ff9a3c"), true)
	if int(Items.equipment_bonus(w.profile.equipment).sets.get(U_MINH, 0)) >= 6 and w._r() < SWAMP_CHANCE:
		e.swamp_stacks = mini(POISON_MAX, e.swamp_stacks + 1)


static func _fire_hit(w) -> bool:
	if str(w.hit_source) in ["fireball", "meteor"]:
		return true
	return str(w.profile.talent) == "ngu-hanh" and str(w.profile.element) == "hoa"


static func dodge_hit(w) -> bool:
	if w.has_unique("goi_mong") and w._r() < PILLOW_DODGE:
		w._text(w.player.pos + Vector2(0, -28), "Mộng né!", Color("#c28af0"), false)
		return true
	return false


static func heal_mult(_w) -> float:
	return 1.0


static func derive_bonus(w, bonus: Dictionary) -> void:
	if "vay_that_dau" in bonus.uniques:
		bonus.flat["res_thuy"] = float(bonus.flat.get("res_thuy", 0.0)) + SCALE_RES


# ---------------------------------------------------------------- Thuỷ Quái Thất Đầu


static func update_rare(w, e, dt: float) -> bool:
	if e.kind != "thuy-quai":
		return false
	if e.phase == 1:
		e.phase = 2
		for i in HEADS:
			_spawn_head(w, e, e.pos + Vector2.from_angle(TAU * i / HEADS) * HEAD_RING)
		w._message("Thuỷ Quái Thất Đầu! Chặt đủ 7 đầu cùng lúc — đốt gốc đầu bằng hệ Hỏa (hoặc Đuốc Lửa, phím Q) để không mọc lại.", "bad")
	return true


static func _spawn_head(w, body, pos: Vector2) -> void:
	var h = w.spawn_enemy("dau-thuy-quai", body.level, pos, {"role": "rareMinion"})
	h.max_hp = maxf(1.0, body.max_hp / HEADS)
	h.hp = h.max_hp
	h.atk = body.atk
	h.def = body.def
	h.state = "chase"
	h.skill_cd = 1.0 + w._r() * 2.0


# ---------------------------------------------------------------- Đạo Tặc — Mộng Cảnh


static func copy_skill(w, id: String) -> bool:
	if id != "dreamscape":
		return false
	var n := 0
	for e in w.enemies:
		if not e.dead and e.role != "boss" and e.role != "rare" and e.pos.distance_to(w.player.pos) <= CHARM_R + e.radius:
			e.charm_t = CHARM_TIME
			e.skill_cd = 0.0
			n += 1
	w._blast(w.player.pos, CHARM_R, Color("#c28af0"))
	w._text(w.player.pos + Vector2(0, -40), "Mộng Cảnh! (%d quái)" % n, Color("#c28af0"), true)
	return true


# ================================================================ tiến hoá Thiên phú (C4-43…45)


## Cấp của dạng hiện tại (1–10); `profile.talent_level` là cấp hiệu dụng = Lv + 9 × số lần tiến hoá (C4-44).
static func stage_level(p) -> int:
	return int(p.talent_level) - EVO_LEVEL_STEP * int(p.get("evo"))


## [tên, hạng] dạng hiện tại của Thiên phú.
static func evo_form(talent_id: String, evo: int) -> Array:
	var t := Talents.get_talent(talent_id)
	var tree: Array = Talents.EVOLUTION.get(talent_id, [])
	if evo <= 0 or tree.is_empty():
		return [str(t.name), str(t.rank)]
	var f: Array = tree[mini(evo, tree.size()) - 1]
	return [str(f[0]), str(f[1])]


static func can_evolve(w) -> String:
	var p = w.profile
	var tree: Array = Talents.EVOLUTION.get(str(p.talent), [])
	if int(p.evo) >= tree.size():
		return "Thiên phú này không tiến hoá thêm." if not tree.is_empty() else "Đạo Tặc không tiến hoá."
	if stage_level(p) < Talents.MAX_TALENT_LEVEL:
		return "Cần Thiên phú Lv%d (đang Lv%d)." % [Talents.MAX_TALENT_LEVEL, stage_level(p)]
	if int(p.evo_essence) < 1:
		return "Cần 1 Tinh Hoa Tiến Hoá (rơi từ boss hiếm)."
	ensure(w)
	if int(p.evo) == 0 and int(p.quest.ch4) < 6:
		return "Hoàn thành nhiệm vụ chương 4 tới bước Tiến hoá (gặp Tinh Quang Sứ ở Làng Chài Lau)."
	return ""


## Đã tiến hoá đủ để mở vùng 5 (Đạo Tặc không tiến hoá — coi như đạt).
static func evolved_once(p) -> bool:
	return int(p.evo) >= 1 or Talents.EVOLUTION.get(str(p.talent), []).is_empty()


static func evolve(w) -> Dictionary:
	var why := can_evolve(w)
	if why != "":
		w._message(why, "bad")
		return {"ok": false, "message": why}
	var p = w.profile
	var before := evo_form(str(p.talent), int(p.evo))
	p.evo_essence = int(p.evo_essence) - 1
	# Q18: hoàn 50% Tinh Hoa đã luyện dạng cũ (25 → 12).
	var spent := 0
	for lv in range(1, Talents.MAX_TALENT_LEVEL):
		spent += Talents.level_cost(lv)
	var refund := int(spent * EVO_REFUND)
	p.essence = int(p.essence) + refund
	p.evo = int(p.evo) + 1
	# Cấp hiệu dụng giữ nguyên → dạng mới Lv1 = dạng cũ Lv10 (không tụt sức mạnh).
	w._refresh_stats()
	var after := evo_form(str(p.talent), int(p.evo))
	var msg := "Tiến hoá! %s (%s) → %s (%s). Thiên phú về Lv1, hoàn %d Thiên Phú Tinh Hoa." % [before[0], before[1], after[0], after[1], refund]
	w._message(msg, "good")
	w._events.append({"type": "evolve", "name": after[0], "rank": after[1]})
	w._sfx("levelup")
	return {"ok": true, "message": msg}


# ================================================================ nhiệm vụ chương 4 (C4-41)


static func quest(w) -> Dictionary:
	ensure(w)
	return Story.quest4(int(w.profile.quest.ch4))


static func quest_status(w) -> Array:
	var q := quest(w)
	if q.is_empty():
		return [0, 0]
	match str(q.type):
		"kills4":
			return [mini(int(w.profile.quest.kills4), int(q.need)), int(q.need)]
		"pods4":
			return [mini(w.profile.quest.orbs4.size(), int(q.need)), int(q.need)]
	return [0, int(q.need)]


static func check_quest(w) -> void:
	var q := quest(w)
	if q.is_empty():
		return
	# Bọc Mộng ở Đầm Sâu (bước 3)
	if w.map_id == "4-2" and str(q.type) == "pods4":
		var pods: Array = w.map.get("pods", [])
		for i in pods.size():
			if not (i in w.profile.quest.orbs4) and w.player.pos.distance_to(pods[i]) <= 60.0:
				w.profile.quest.orbs4.append(i)
				w._blast(pods[i], 40.0, Color("#c28af0"))
				w._message("Bọc Mộng %d/%d vỡ — một mảnh ký ức của Lam Nhi." % [w.profile.quest.orbs4.size(), pods.size()], "good")
	var done := false
	match str(q.type):
		"kills4":
			done = int(w.profile.quest.kills4) >= int(q.need)
		"pods4":
			done = w.profile.quest.orbs4.size() >= int(q.need)
		"explore4":
			done = w.map_id == "4-3" and w.explore_ratio("4-3") >= 0.4
		"boss4":
			done = w.is_boss_defeated("nu-vuong")
		"evolve":
			done = int(w.profile.evo) >= 1 or Talents.EVOLUTION.get(str(w.profile.talent), []).is_empty()
	if done:
		advance(w)


static func advance(w) -> void:
	var q := quest(w)
	if q.is_empty():
		return
	var r: Dictionary = q.reward
	w.profile.gold += float(r.get("gold", 0))
	w.profile.stones += int(r.get("stones", 0))
	w.profile.antidotes = int(w.profile.antidotes) + int(r.get("antidotes", 0))
	var rt := Story.reward_text(r)
	w._message("Nhiệm vụ chương 4 hoàn thành: %s%s" % [q.title, (". Thưởng: " + rt) if rt != "" else ""], "good")
	var step := int(w.profile.quest.ch4)
	w.profile.quest.ch4 = step + 1
	w._events.append({"type": "quest_done", "step": step, "chapter": 4})
	if r.has("exp"):
		w.add_exp(float(r.exp), false)
	match step:
		1:
			w.say("lam_meet")
		2:
			w.say("lam_taken")
		3:
			w.say("pods_done")
		4:
			w.say("queen_gate")
		5:
			w.say("lam_saved")
		6:
			w.say("ch4_done")
			w._events.append({"type": "chapter_end", "chapter": 4})


static func talk(w, npc_id: String) -> String:
	ensure(w)
	var step := int(w.profile.quest.ch4)
	match npc_id:
		"lao-ngu":
			if step == 1:
				w._force_say("ngu_meet")
				advance(w)
				return ""
			w._force_say("ngu_shop")
			return "shop"
		"lam-nhi":
			w._force_say("lam_hint" if step < 6 else "lam_after")
			return ""
		"tinh-quang":
			if step >= 6 or int(w.profile.evo) >= 1:
				var res := evolve(w)
				if not res.ok:
					w._force_say("tq_wait")
				return ""
			w._force_say("tq_intro")
			return ""
	return ""


static func map_requirement(w, id: String) -> String:
	match id:
		"4-1":
			# C4-01: chuyển chức 1 + hạ Sa Hoàng (kịch bản mục 6).
			if not w.is_boss_defeated("sa-hoang"):
				return "Hạ Bọ Cạp Sa Hoàng trước."
			if str(w.profile.job) == "":
				return "Cần chuyển chức lần 1 (Thạch Thủ ở Trại Cát Đỏ, cấp 30)."
		"4-2":
			return "" if "4-1" in w.profile.unlocked_maps else "Tới Bãi Lau Mù trước."
		"4-3":
			return "" if "4-2" in w.profile.unlocked_maps else "Tới Đầm Sâu trước."
	return ""


static func gate_open(w, id: String) -> bool:
	ensure(w)
	if id == "4-3":
		return int(w.profile.quest.ch4) >= 5 or w.is_boss_defeated("nu-vuong")
	return true


static func quest_hud(w) -> Dictionary:
	ensure(w)
	var q := quest(w)
	if not q.is_empty():
		var st := quest_status(w)
		var rt := Story.reward_text(q.reward)
		return {"active": true, "title": "CHƯƠNG 4 · NHIỆM VỤ %d/%d" % [int(w.profile.quest.ch4), Story.QUESTS4.size()],
			"lines": [["◆ " + str(q.title) + ("  (%d/%d)" % st if int(st[1]) > 1 else ""), "gold"], [str(q.hint), "text"],
				[("Thưởng: " + rt) if rt != "" else "", "muted"]]}
	if int(w.profile.quest.ch4) >= Story.DONE4:
		var f := evo_form(str(w.profile.talent), int(w.profile.evo))
		return {"done": true, "title": "CHƯƠNG 4 · HOÀN THÀNH ✓",
			"lines": [["Thiên phú: %s (%s)" % [f[0], f[1]], "text"],
				["Săn boss hiếm Thuỷ Quái Thất Đầu ở Cung Mộng — 2 lần mỗi ngày", "muted"],
				["Chương 5: Núi Viêm Long — sắp mở", "muted"]]}
	return {}
