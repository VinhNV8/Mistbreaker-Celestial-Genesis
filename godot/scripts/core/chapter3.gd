extends RefCounted
## M6 — Chương 3 Sa Mạc Lãng Quên (docs/10-chuong-3.md). Hàm static nhận GameWorld `w`;
## GameWorld chỉ gọi vào đây ở vài chỗ móc (tìm "Ch3." trong game_world.gd).
## Gồm: môi trường sa mạc (ngày/đêm, nắng gắt, ốc đảo, bóng râm, bão cát), quái vùng 3, Bọ Cạp Sa Hoàng,
## Nhân Sư Đá, Đuôi Sa Hoàng, Mắt Nhân Sư, Bộ Sa Hành Giả, Độn Thổ (Đạo Tặc), nhiệm vụ chương 3, chuyển chức 1.

const Maps = preload("res://scripts/data/maps.gd")
const Monsters = preload("res://scripts/data/monsters.gd")
const Classes = preload("res://scripts/data/classes.gd")
const Story = preload("res://scripts/data/story.gd")
const ItemData = preload("res://scripts/data/items.gd")
const Items = preload("res://scripts/core/items.gd")
const Formulas = preload("res://scripts/core/formulas.gd")
const RngUtil = preload("res://scripts/core/rng_util.gd")

# ---------------------------------------------------------------- C3-10…13: môi trường
const DAY_LEN := 240.0
const NIGHT_LEN := 120.0
const NIGHT_ATK := 0.15
const HEAT_TICK := 5.0
const HEAT_PCT := 0.01
const WATER_TIME := 60.0
const DRINK_TIME := 1.0
const SHADE_R := 50.0
const ROCKS_PER_MAP := 34
const STORM_MIN := 180.0
const STORM_MAX := 300.0
const STORM_TIME := 30.0
const STORM_WARN := 5.0
## Bão cát: đạn bay chậm 30%.
const STORM_SHOT := 0.7
# ---------------------------------------------------------------- C3-20…25: quái
const PACK := 5
const BURROW_TIME := 1.5
const BURROW_WARN := 0.5
const BURROW_CD := 6.0
const BURROW_R := 30.0
const BURROW_MUL := 1.4
const CURSE_TIME := 6.0
const CURSE_CUT := 0.2
const VORTEX_R := 70.0
const SLOW_PCT := 0.4
const SLOW_TIME := 3.0
const ROLL_CD := 9.0
const ROLL_DIST := 200.0
const ROLL_MUL := 1.8
const ROLL_WINDUP := 0.8
const REVIVE_CD := 20.0
const REVIVE_R := 150.0
const REVIVE_WINDOW := 15.0
# ---------------------------------------------------------------- C3-30: Bọ Cạp Sa Hoàng
const CLAW_MUL := 1.3
const HOLD_TIME := 1.0
const TAIL_CD := 4.0
const TAIL_WINDUP := 0.9
const TAIL_R := 80.0
const TAIL_MUL := 1.5
const VENOM_TIME := 5.0
const DIVE_CD := 8.0
const DIVE_TIME := 3.0
const DIVE_WARN := 1.2
const DIVE_R := 70.0
const DIVE_MUL := 2.2
# ---------------------------------------------------------------- C3-33: Nhân Sư Đá
const PUZZLE_TIME := 4.0
const PILLAR_R := 45.0
const PILLAR_GAP := 160.0
const PUZZLE_MUL := 3.0
const GAZE_CD := 6.0
const GAZE_WINDUP := 1.0
const GAZE_R := 140.0
const GAZE_HALF := deg_to_rad(22.5)
const GAZE_STONE := 1.5
# ---------------------------------------------------------------- đồ, bộ, Độn Thổ
const VENOM_MUL := 0.2
const VENOM_DUR := 4.0
const VENOM_STACK := 3
const EYE_CRIT := 0.10
const EYE_MUL := 1.2
const TRAIL_TTL := 4.0
const COPY_REACH := 150.0
const COPY_R := 70.0
const COPY_MUL := 2.0
const COPY_TIME := 1.5
# ---------------------------------------------------------------- chuyển chức (C3-44)
const KS_EVERY := 4
const KS_MUL := 0.8
const KS_RANGE := 250.0
const SPIN_BONUS := 1.3
const XT_MUL := 0.5
const XT_PIERCE_CD := 4.0
const NT_MUL := 1.3
const NT_JUMPS := 2


## Trạng thái chương 3 của GameWorld (không lưu: đồng hồ ngày/đêm chạy theo giờ chơi).
class State:
	var heat_acc := 0.0
	var drink := 0.0
	var storm_next := 240.0
	var storm_left := 0.0
	var oasis_idx := -1
	## Xác Ướp vừa ngã: [{pos, level, t}] — Thủ Lĩnh Xác Ướp dựng lại.
	var fallen: Array = []
	## Lốc cát của Bộ Sa Hành Giả: [{pos, r, ttl}]
	var trails: Array = []
	## Cột đá Câu Đố Nhân Sư: [{pos, element}]
	var pillars: Array = []
	var puzzle_left := 0.0
	var rocks_map := ""
	var rocks: Array = []


## Hồ sơ/test cũ có thể thiếu khoá chương 3 trong profile.quest.
static func ensure(w) -> void:
	var q: Dictionary = w.profile.quest
	if not q.has("ch3"):
		q["ch3"] = 0
	if not q.has("kills3"):
		q["kills3"] = 0
	if not q.has("oases"):
		q["oases"] = []


static func is_desert(w) -> bool:
	return bool(w.map.get("desert", false))


# ================================================================ môi trường


## Giây trong chu kỳ 6 phút (0–240 ngày, 240–360 đêm), theo giờ chơi.
static func cycle_t(w) -> float:
	return fposmod(float(w.profile.play_seconds), DAY_LEN + NIGHT_LEN)


static func is_night(w) -> bool:
	return is_desert(w) and cycle_t(w) >= DAY_LEN


static func night_mult(w) -> float:
	return 1.0 + NIGHT_ATK if is_night(w) else 1.0


static func storm_on(w) -> bool:
	if not is_desert(w):
		return false
	if w.ch3.storm_left > 0.0:
		return true
	var b = w.boss()
	return b != null and b.kind == "sa-hoang" and b.phase >= 2


static func shot_mult(w) -> float:
	return STORM_SHOT if storm_on(w) else 1.0


## Tảng đá lớn cho bóng râm (C3-11): sinh cố định theo map (view vẽ đúng các vị trí này).
static func rocks(w) -> Array:
	var st = w.ch3
	if st.rocks_map == w.map_id:
		return st.rocks
	st.rocks_map = w.map_id
	st.rocks = []
	if not is_desert(w):
		return st.rocks
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("rocks-" + w.map_id)
	var tries := 0
	while st.rocks.size() < ROCKS_PER_MAP and tries < 400:
		tries += 1
		var pos := Vector2(rng.randf_range(300.0, w.world_size.x - 200.0), rng.randf_range(160.0, w.world_size.y - 160.0))
		if pos.distance_to(w.safe_pos) < w.safe_r + 120.0:
			continue
		if w.map.arena != null and pos.distance_to(w.arena_pos) < w.arena_r + 80.0:
			continue
		if oasis_at(w, pos) >= 0:
			continue
		st.rocks.append(pos)
	return st.rocks


static func oases(w) -> Array:
	return w.map.get("oases", [])


static func oasis_at(w, pos: Vector2) -> int:
	var list := oases(w)
	for i in list.size():
		if pos.distance_to(list[i][0]) <= float(list[i][1]):
			return i
	return -1


static func in_shade(w, pos: Vector2) -> bool:
	for r in rocks(w):
		if pos.distance_to(r) <= SHADE_R:
			return true
	return false


static func heat_immune(w) -> bool:
	if float(w.profile.play_seconds) < float(w.profile.heat_free_until):
		return true
	return int(Items.equipment_bonus(w.profile.equipment).sets.get(ItemData.SA_HANH, 0)) >= 2


## Đang chịu Nắng gắt (để HUD báo).
static func heat_active(w) -> bool:
	var p = w.player
	return is_desert(w) and not is_night(w) and not heat_immune(w) and oasis_at(w, p.pos) < 0 and not in_shade(w, p.pos) \
		and p.pos.distance_to(w.safe_pos) > w.safe_r


static func on_load(w) -> void:
	ensure(w)
	var st = w.ch3
	st.storm_left = 0.0
	st.storm_next = STORM_MIN + w._r() * (STORM_MAX - STORM_MIN)
	st.pillars = []
	st.puzzle_left = 0.0
	st.trails = []
	st.fallen = []
	if int(w.map.get("region", 1)) == 3 and int(w.profile.quest.ch3) == 0:
		w.profile.quest.ch3 = 1
		w.say("r3_arrive")


static func tick(w, dt: float) -> void:
	ensure(w)
	var st = w.ch3
	var p = w.player
	p.curse_timer -= dt
	p.slow_timer -= dt
	p.hold_timer -= dt
	for t in st.trails:
		t.ttl -= dt
		for e in w.enemies:
			if not e.dead and e.pos.distance_to(t.pos) <= t.r + e.radius:
				e.slow_t = 0.3
	st.trails = st.trails.filter(func(t): return t.ttl > 0.0)
	if not is_desert(w):
		return
	# Bão cát
	if st.storm_left > 0.0:
		st.storm_left -= dt
	else:
		st.storm_next -= dt
		if absf(st.storm_next - STORM_WARN) < dt * 0.5 + 0.0001:
			w._message("Bão cát sắp tới — 5 giây nữa!", "bad")
		if st.storm_next <= 0.0:
			st.storm_left = STORM_TIME
			st.storm_next = STORM_MIN + w._r() * (STORM_MAX - STORM_MIN)
			w._message("Bão cát! Tầm nhìn giảm, đạn bay chậm 30% trong 30 giây.", "bad")
	# Ốc đảo: đứng trong hồ 1 giây = uống nước
	var oi := oasis_at(w, p.pos)
	if oi >= 0 and p.dead_timer <= 0.0:
		st.drink += dt
		if st.drink >= DRINK_TIME and (st.oasis_idx != oi or float(w.profile.heat_free_until) - float(w.profile.play_seconds) < WATER_TIME - 5.0):
			st.oasis_idx = oi
			w.profile.heat_free_until = float(w.profile.play_seconds) + WATER_TIME
			w._text(p.pos + Vector2(0, -40), "Uống nước — miễn nắng 60 giây", Color("#7ac0f0"), true)
			if w.map_id == "3-2" and int(w.profile.quest.ch3) == 3 and not (oi in w.profile.quest.oases):
				w.profile.quest.oases.append(oi)
				w._message("Ốc đảo %d/3: nước có ký ức — bạn thấy thêm một đoạn đường tới Di tích." % w.profile.quest.oases.size(), "good")
	else:
		st.drink = 0.0
		if oi < 0:
			st.oasis_idx = -1
	# Nắng gắt: −1% HP mỗi 5 giây, không làm gục (Q52)
	if heat_active(w) and p.dead_timer <= 0.0:
		st.heat_acc += dt
		if st.heat_acc >= HEAT_TICK:
			st.heat_acc -= HEAT_TICK
			var loss := float(w.stats.max_hp) * HEAT_PCT
			p.hp = maxf(1.0, p.hp - loss)
			w._text(p.pos + Vector2(0, -26), "Nắng -%d" % roundi(loss), Color("#ff9a3c"), false)
	else:
		st.heat_acc = 0.0


static func env_text(w) -> String:
	if not is_desert(w):
		return ""
	var parts := PackedStringArray()
	var t := cycle_t(w)
	if t < DAY_LEN:
		parts.append("Ngày · còn %d:%02d" % [int((DAY_LEN - t) / 60.0), int(DAY_LEN - t) % 60])
	else:
		parts.append("Đêm · quái +15%% Tấn công · còn %d:%02d" % [int((DAY_LEN + NIGHT_LEN - t) / 60.0), int(DAY_LEN + NIGHT_LEN - t) % 60])
	if storm_on(w):
		parts.append("BÃO CÁT")
	elif w.ch3.storm_next <= STORM_WARN:
		parts.append("Bão cát sắp tới")
	if heat_active(w):
		parts.append("Nắng gắt — tìm bóng râm / ốc đảo")
	elif heat_immune(w) and not is_night(w):
		var left: float = float(w.profile.heat_free_until) - float(w.profile.play_seconds)
		parts.append("Miễn nắng" + (" %d giây" % ceili(left) if left > 0.0 else ""))
	return "   ·   ".join(parts)


## Tầm nhìn 0–1 cho view: đêm 70%, bão cát 40%.
static func vision(w) -> float:
	if not is_desert(w):
		return 1.0
	if storm_on(w):
		return 0.4
	return 0.7 if is_night(w) else 1.0


# ================================================================ quái


static func heal_mult(w) -> float:
	return 1.0 - CURSE_CUT if w.player.curse_timer > 0.0 else 1.0


static func after_spawn(w, e) -> void:
	# C3-20: Bọ Cát đi bầy 5 con.
	if e.kind == "bo-cat" and not e.elite and e.role == "field":
		for i in PACK - 1:
			var m = w.spawn_enemy("bo-cat", e.level, e.pos + Vector2.from_angle(i * TAU / 4.0 + 0.4) * 36.0, {"role": "pack"})
			m.home = e.home


## Bất tử khi chui cát / đang ra Câu Đố. Khiên trước của Bọ Hung (giảm 70% từ phía trước).
static func adjust_damage(w, e, dmg: int, by_player: bool) -> int:
	if e.burrow_t > 0.0 or e.puzzle_t > 0.0:
		return 0
	if by_player and e.kind == "bo-cat" and e.elite and e.state != "stunned" \
			and absf(angle_difference(e.face, (w.player.pos - e.pos).angle())) <= w.SHIELD_ARC:
		w._text(e.pos + Vector2(0, -e.radius - 22), "Chặn!", Color("#e0a630"), false)
		return maxi(1, roundi(dmg * w.SHIELD_REDUCE))
	return dmg


static func is_hidden(e) -> bool:
	return e.burrow_t > 0.0 and e.state != "windup"


## Gọi đầu _update_enemy. true = đã xử lý xong khung hình này.
static func update_enemy(w, e, dt: float) -> bool:
	e.slow_t -= dt
	# Đuôi Sa Hoàng: độc cộng dồn
	if e.venom_timer > 0.0:
		e.venom_timer -= dt
		e.venom_tick += dt
		if e.venom_tick >= 1.0:
			e.venom_tick -= 1.0
			var dmg: int = maxi(1, roundi(Formulas.compute_damage(w.stats.atk, e.def, VENOM_MUL) * e.venom_stacks))
			w._apply_damage(e, dmg, false, false)
			if e.dead:
				return true
		if e.venom_timer <= 0.0:
			e.venom_stacks = 0
	if e.puzzle_t > 0.0:
		_update_puzzle(w, e, dt)
		return true
	if e.burrow_t > 0.0:
		e.burrow_t -= dt
		if e.state == "windup":
			return false
		# Đi ngầm dưới cát về phía người chơi, gần hết giờ thì vòng báo hiệu rồi trồi lên.
		var warn: float = DIVE_WARN if e.kind == "sa-hoang" else BURROW_WARN
		e.pos = e.pos.move_toward(w.player.pos, e.speed * 1.3 * dt)
		if e.role == "boss":
			e.pos = w._clamp_to_arena(e.pos, e.radius)
		if e.burrow_t <= warn:
			w._begin_attack(e, "sdive" if e.kind == "sa-hoang" else "emerge", warn)
		return true
	return false


## Kỹ năng khi đuổi (trạng thái chase). true = đã bắt đầu đòn.
static func chase(w, e, d: float, dt: float) -> bool:
	var def: Dictionary = Monsters.DEFS[e.kind]
	if def.get("burrow", false):
		e.burrow_cd -= dt
		if e.burrow_cd <= 0.0 and d > 70.0 and d < 280.0:
			e.burrow_cd = BURROW_CD
			e.burrow_t = BURROW_TIME
			return true
	match e.kind:
		"sa-hoang":
			e.skill_cd -= dt
			e.pounce_cd -= dt
			if e.phase >= 2 and e.pounce_cd <= 0.0:
				e.pounce_cd = DIVE_CD
				e.burrow_t = DIVE_TIME
				w._text(e.pos + Vector2(0, -e.radius - 26), "Chui xuống cát!", Color("#d6a865"), true)
				return true
			if e.skill_cd <= 0.0 and d > 60.0:
				e.skill_cd = TAIL_CD
				w._begin_attack(e, "tail", TAIL_WINDUP)
				return true
		"nhan-su":
			e.skill_cd -= dt
			if e.skill_cd <= 0.0 and d < GAZE_R + 40.0:
				e.skill_cd = GAZE_CD
				w._begin_attack(e, "gaze", GAZE_WINDUP)
				return true
	return false


static func elite_skill(w, e, kind: String) -> bool:
	match kind:
		"roll":
			e.skill_cd = ROLL_CD
			w._begin_attack(e, "roll", ROLL_WINDUP)
			e.target = (e.pos + (w.player.pos - e.pos).normalized() * ROLL_DIST).clamp(Vector2(40, 40), w.world_size - Vector2(40, 40))
			w._text(e.pos + Vector2(0, -e.radius - 24), "Lăn cầu!", Color("#e0a630"), true)
			return true
		"revive":
			e.skill_cd = REVIVE_CD
			var st = w.ch3
			var n := 0
			var keep: Array = []
			for f in st.fallen:
				if n < 2 and float(w.time) - float(f.t) <= REVIVE_WINDOW and e.pos.distance_to(f.pos) <= REVIVE_R:
					var m = w.spawn_enemy("xac-uop", int(f.level), f.pos, {"role": "summon"})
					m.state = "chase"
					w._blast(f.pos, 30.0, Color("#b36bff"))
					n += 1
				else:
					keep.append(f)
			st.fallen = keep
			if n > 0:
				w._text(e.pos + Vector2(0, -e.radius - 24), "Hồi sinh!", Color("#b36bff"), true)
			else:
				e.skill_cd = 3.0
			return true
	return false


## Đòn của quái/boss vùng 3. true nếu là kiểu đòn của chương 3.
static func perform(w, e) -> bool:
	var p = w.player
	match e.attack_kind:
		"curse":
			if e.pos.distance_to(p.pos) <= e.radius + e.attack_range + w.PLAYER_RADIUS + 12.0:
				if w._damage_player(e.atk, 1.0):
					p.curse_timer = CURSE_TIME
					w._text(p.pos + Vector2(0, -40), "Nguyền rủa: −20% hồi máu", Color("#b36bff"), false)
		"sandvortex":
			w._blast(e.target, VORTEX_R, Color("#d6a865"))
			if e.target.distance_to(p.pos) <= VORTEX_R + w.PLAYER_RADIUS:
				if w._damage_player(e.atk, 1.0):
					p.slow_timer = SLOW_TIME
		"emerge":
			e.burrow_t = 0.0
			e.pos = e.target
			w._blast(e.pos, BURROW_R, Color("#d6a865"))
			if e.pos.distance_to(p.pos) <= BURROW_R + w.PLAYER_RADIUS:
				w._damage_player(e.atk, BURROW_MUL)
		"roll":
			var from: Vector2 = e.pos
			e.pos = e.target
			if Geometry2D.get_closest_point_to_segment(p.pos, from, e.pos).distance_to(p.pos) <= e.radius + w.PLAYER_RADIUS:
				w._damage_player(e.atk, ROLL_MUL)
		"claw":
			if e.pos.distance_to(p.pos) <= e.radius + e.attack_range + w.PLAYER_RADIUS + 12.0:
				if w._damage_player(e.atk, CLAW_MUL):
					p.hold_timer = HOLD_TIME
					w._text(p.pos + Vector2(0, -40), "Bị kìm kẹp!", Color("#d6a865"), true)
		"tail":
			w._blast(e.target, TAIL_R, Color("#8cff5a"))
			if e.target.distance_to(p.pos) <= TAIL_R + w.PLAYER_RADIUS:
				if w._damage_player(e.atk, TAIL_MUL):
					p.poison_timer = VENOM_TIME
		"sdive":
			e.burrow_t = 0.0
			e.pos = w._clamp_to_arena(e.target, e.radius)
			w._blast(e.pos, DIVE_R, Color("#c0843c"))
			w._sfx("explode")
			if e.pos.distance_to(p.pos) <= DIVE_R + w.PLAYER_RADIUS:
				w._damage_player(e.atk, DIVE_MUL)
		"gaze":
			var dir: Vector2 = (e.target - e.pos).normalized()
			var to_p: Vector2 = p.pos - e.pos
			w._blast(e.pos + dir * GAZE_R * 0.55, GAZE_R * 0.45, Color("#4fc3ff"))
			if to_p.length() <= GAZE_R + e.radius + w.PLAYER_RADIUS and absf(angle_difference(dir.angle(), to_p.angle())) <= GAZE_HALF \
					and p.dodge_time <= 0.0 and p.dead_timer <= 0.0:
				if w._damage_player(e.atk, 0.8):
					p.stun_timer = GAZE_STONE
					w._text(p.pos + Vector2(0, -40), "Hoá đá!", Color("#a9adb9"), true)
		_:
			return false
	return true


## Giai đoạn 2 của boss chương 3 (thay cho giai đoạn 2 của Sói Chúa). true = đã xử lý.
static func boss_phase_two(w, e) -> bool:
	if e.kind != "sa-hoang":
		return false
	e.phase = 2
	e.pounce_cd = 1.5
	w._message("Sa Hoàng gầm lên, bão cát nổi dậy! Nó sẽ chui xuống cát — nhìn vết cát mà né.", "bad")
	w._sfx("boss_roar")
	return true


static func on_kill(w, e) -> void:
	ensure(w)
	if e.kind == "xac-uop" and not e.elite:
		w.ch3.fallen.append({"pos": e.pos, "level": e.level, "t": w.time})
		if w.ch3.fallen.size() > 6:
			w.ch3.fallen.pop_front()
	if int(w.map.get("region", 1)) == 3 and int(w.profile.quest.ch3) == 2:
		w.profile.quest.kills3 = int(w.profile.quest.kills3) + 1


# ---------------------------------------------------------------- Nhân Sư Đá


static func update_sphinx(w, e, dt: float) -> void:
	# Mỗi lần mất 25% HP: Câu Đố Nhân Sư (75% / 50% / 25%).
	var mark: float = 1.0 - 0.25 * e.phase
	if e.phase <= 3 and e.hp <= e.max_hp * mark and e.puzzle_t <= 0.0:
		e.phase += 1
		_start_puzzle(w, e)


static func _start_puzzle(w, e) -> void:
	var st = w.ch3
	e.puzzle_t = PUZZLE_TIME
	e.state = "idle"
	var others: Array = ["kim", "thuy", "hoa", "tho"]
	others = RngUtil.shuffle(others, w._rng)
	var elems: Array = RngUtil.shuffle(["moc", others[0], others[1]], w._rng)
	st.pillars = []
	var base: Vector2 = w.player.pos
	for i in 3:
		var pos: Vector2 = (base + Vector2.from_angle(TAU * i / 3.0 + 0.5) * PILLAR_GAP).clamp(Vector2(80, 80), w.world_size - Vector2(80, 80))
		st.pillars.append({"pos": pos, "element": elems[i]})
	w._message("Câu Đố Nhân Sư: đứng vào cột mang hệ KHẮC Thổ trong 4 giây!", "bad")
	w.say("rare_nhan_su")


static func _update_puzzle(w, e, dt: float) -> void:
	var st = w.ch3
	e.puzzle_t -= dt
	if e.puzzle_t > 0.0:
		return
	var p = w.player
	var safe := false
	for pl in st.pillars:
		if p.pos.distance_to(pl.pos) <= PILLAR_R + w.PLAYER_RADIUS and Monsters.counters(str(pl.element), "tho"):
			safe = true
	for pl in st.pillars:
		w._blast(pl.pos, PILLAR_R, Color(Monsters.ELEMENT_HEX[pl.element]))
	if safe:
		w._message("Đúng! Mộc khắc Thổ — Nhân Sư lùi lại.", "good")
	elif p.dead_timer <= 0.0:
		w._incoming_el = "tho"
		w._damage_player(e.atk, PUZZLE_MUL)
		w._message("Sai cột — Nhân Sư trừng phạt ×3!", "bad")
	st.pillars = []
	e.state = "chase"


# ================================================================ người chơi: đồ, bộ, chuyển chức


static func job(w) -> String:
	return str(w.profile.job)


## Bonus vào _derive (trước Stats.derive).
static func derive_bonus(w, bonus: Dictionary) -> void:
	if job(w) != "":
		bonus.max_hp_pct += Classes.JOB_BONUS
		bonus.atk_pct += Classes.JOB_BONUS
	if "nhan_su_eye" in bonus.uniques:
		bonus.flat["crit"] = float(bonus.flat.get("crit", 0.0)) + EYE_CRIT


## Sau Stats.derive: Bộ Sa Hành Giả 4 món +10% Phòng thủ.
static func derive_after(bonus: Dictionary, st: Dictionary) -> void:
	if int(bonus.sets.get(ItemData.SA_HANH, 0)) >= 4:
		st.def = float(st.def) * 1.1


## Hệ số thêm khi người chơi đánh trúng: Mắt Nhân Sư (chí mạng vào quái bị khắc ×1,2).
static func hit_mult(w, e, crit: bool) -> float:
	if crit and w.has_unique("nhan_su_eye") and Monsters.counters(str(w.profile.element), str(Monsters.DEFS[e.kind].element)):
		return EYE_MUL
	return 1.0


## Sau mỗi đòn trúng: Đuôi Sa Hoàng gây độc cộng dồn.
static func on_player_hit(w, e) -> void:
	if e.dead or not w.has_unique("sa_hoang_tail"):
		return
	e.venom_stacks = mini(VENOM_STACK, e.venom_stacks + 1)
	if e.venom_timer <= 0.0:
		e.venom_tick = 0.0
	e.venom_timer = VENOM_DUR


## Bộ Sa Hành Giả 6 món: Xoáy Kiếm / Mưa Tên / Băng Ngục để lại lốc cát làm chậm quái.
static func sand_trail(w, pos: Vector2, r: float) -> void:
	if int(Items.equipment_bonus(w.profile.equipment).sets.get(ItemData.SA_HANH, 0)) >= 6:
		w.ch3.trails.append({"pos": pos, "r": r, "ttl": TRAIL_TTL})


## Đạo Tặc — Độn Thổ: chui đất 1,5 giây (bất tử), trồi lên tại điểm ngắm vòng 7 m ×2,0.
static func copy_burrow(w) -> void:
	var p = w.player
	var to: Vector2 = p.pos + (w._aim - p.pos).limit_length(COPY_REACH)
	p.dash_time = 0.0
	w._text(p.pos + Vector2(0, -40), "Độn Thổ!", Color("#d6a865"), true)
	p.pos = to.clamp(Vector2.ONE * w.PLAYER_RADIUS, w.world_size - Vector2.ONE * w.PLAYER_RADIUS)
	p.burrow_t = COPY_TIME
	w._blast(p.pos, COPY_R, Color("#d6a865"))
	for e in w.enemies:
		if not e.dead and e.pos.distance_to(p.pos) <= COPY_R + e.radius:
			w._hit_enemy(e, COPY_MUL)


## Kiếm Sư: đòn chém thứ 4 phóng kiếm khí ×0,8.
static func after_slash(w) -> void:
	if job(w) == "kiem-su" and w.player.hits % KS_EVERY == 0:
		w._fire(w.WAVE_SPEED, KS_RANGE, KS_MUL, true, "wave", false, 18.0)


static func spin_mult(w) -> float:
	return SPIN_BONUS if job(w) == "kiem-su" else 1.0


## Xạ Thủ: mũi tên phụ ×0,5 vào quái gần thứ 2.
static func after_shot(w, mul: float) -> void:
	if job(w) != "xa-thu":
		return
	var p = w.player
	var first = w._nearest_enemy(p.pos, w.SHOT_RANGE)
	if first == null:
		return
	var second = w._nearest_enemy(p.pos, w.SHOT_RANGE, {first.id: true})
	if second == null:
		return
	var keep: float = p.facing
	p.facing = (second.pos - p.pos).angle()
	w._fire(w.SHOT_SPEED, w.SHOT_RANGE, mul * XT_MUL, false, "arrow")
	p.facing = keep


static func pierce_cd(w, cd: float) -> float:
	return XT_PIERCE_CD if job(w) == "xa-thu" else cd


static func fireball_mult(w) -> float:
	return NT_MUL if job(w) == "phap-su-nguyen-to" else 1.0


static func chain_jumps(w) -> int:
	return NT_JUMPS if job(w) == "phap-su-nguyen-to" else 0


static func can_job(w) -> String:
	if job(w) != "":
		return "Đã chuyển chức."
	if not w.is_boss_defeated("sa-hoang"):
		return "Hạ Bọ Cạp Sa Hoàng trước."
	if int(w.profile.level) < Classes.JOB_LEVEL:
		return "Cần cấp %d." % Classes.JOB_LEVEL
	return ""


static func do_job(w) -> bool:
	if can_job(w) != "":
		return false
	var j := Classes.job_def(str(w.profile.class_id))
	w.profile.job = str(j.id)
	w._refresh_stats()
	w.player.hp = w.stats.max_hp
	w._events.append({"type": "job", "job": j.id, "name": j.name})
	w._message("Chuyển chức: %s! +10%% HP và Tấn công. %s" % [j.name, j.text], "good")
	w._text(w.player.pos + Vector2(0, -50), j.name + "!", Color("#ffc940"), true)
	w._sfx("levelup")
	return true


# ================================================================ nhiệm vụ chương 3 (C3-41)


static func quest(w) -> Dictionary:
	ensure(w)
	return Story.quest3(int(w.profile.quest.ch3))


static func quest_status(w) -> Array:
	var q := quest(w)
	if q.is_empty():
		return [0, 0]
	match str(q.type):
		"kills3":
			return [mini(int(w.profile.quest.kills3), int(q.need)), int(q.need)]
		"oases":
			return [mini(w.profile.quest.oases.size(), 3), 3]
	return [0, int(q.need)]


static func near_stele(w) -> bool:
	return w.map_id == "3-3" and w.map.has("stele3") and w.player.pos.distance_to(w.map.stele3) <= 90.0


static func check_quest(w) -> void:
	var q := quest(w)
	if q.is_empty():
		return
	var done := false
	match str(q.type):
		"kills3":
			done = int(w.profile.quest.kills3) >= int(q.need)
		"oases":
			done = w.profile.quest.oases.size() >= 3
		"stele3":
			done = near_stele(w) and w.explore_ratio("3-3") >= 0.4
		"boss3":
			done = w.is_boss_defeated("sa-hoang")
		"job":
			done = job(w) != ""
	if done:
		advance(w)


static func advance(w) -> void:
	var q := quest(w)
	if q.is_empty():
		return
	var r: Dictionary = q.reward
	w.profile.gold += float(r.get("gold", 0))
	w.profile.stones += int(r.get("stones", 0))
	w.profile.potions = mini(w.POTION_MAX, int(w.profile.potions) + int(r.get("potions", 0)))
	var rt := Story.reward_text(r)
	w._message("Nhiệm vụ chương 3 hoàn thành: %s%s" % [q.title, (". Thưởng: " + rt) if rt != "" else ""], "good")
	var step := int(w.profile.quest.ch3)
	w.profile.quest.ch3 = step + 1
	w._events.append({"type": "quest_done", "step": step, "chapter": 3})
	if r.has("exp"):
		w.add_exp(float(r.exp), false)
	match step:
		1:
			w.say("salao_q2")
		2:
			w.say("salao_q3")
		3:
			w.say("salao_q4")
		4:
			w._force_say("stele3_read")
			w.say("salao_q5")
		5:
			w.say("sa_hoang_down")
		6:
			w.say("job_done")
			w.say("ch3_done")
			w._events.append({"type": "chapter_end", "chapter": 3})


## NPC Trại Cát Đỏ. Trả về "shop" để mở cửa hàng.
static func talk(w, npc_id: String) -> String:
	ensure(w)
	var step := int(w.profile.quest.ch3)
	match npc_id:
		"sa-lao":
			if step == 1:
				w._force_say("salao_meet")
				advance(w)
			else:
				w._force_say(["", "salao_meet", "salao_q2", "salao_q3", "salao_q4", "salao_q5", "sa_hoang_down", "ch3_done"][clampi(step, 0, 7)])
			return ""
		"a-moc":
			w._force_say("amoc_shop")
			return "shop"
		"thach-thu":
			if do_job(w):
				return ""
			w._force_say("thach_wait" if job(w) == "" else "job_done")
			return ""
	return ""
