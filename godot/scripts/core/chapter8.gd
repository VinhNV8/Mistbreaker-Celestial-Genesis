extends RefCounted
## M11 — Chương 8 Vực Hư Vô (docs/17-chuong-8.md, rà lại 31/10 mục 0b). Gắn vào GameWorld qua core/chapters.gd (D38).
## Gồm: Suy Thiên (hook mới talent_mult / talent_cd_mult — D70), Đèn Tinh Quang, Cột Đá Hư Vô chặn tia/đạn, không hệ,
## Đèn Lồng Tinh Quang (phím Q); quái vùng 8 (Bóng Hư Vô tàng hình + Đâm lén, Kẻ Nuốt xoá buff, Giáp Sĩ Chém nặng,
## Mắt Hư Vô Tia nhìn, Tư Tế Tế lễ, Quái Vật Không Mặt miễn nón trước); Giáo Chủ Hư Vô (3 giai đoạn, Hút Thiên phú, đèn chặn);
## Hư Vô Thú; Bộ Tinh Quang, Ấn Hư Vô, Nanh Hư Vô, Hút Thiên Phú (Đạo Tặc); nhiệm vụ chương 8 (7 bước), Tổng tấn công,
## Phản công Hư Vô; Lõi Hư Vô + 5 Tổ Sư cho chuyển chức 3 (job3.gd).
## Đơn vị: 1 m = 10 điểm ảnh. Vị trí trên map đọc từ w.map (đã nhân MAP_SCALE).

const Story = preload("res://scripts/data/story.gd")
const Talents = preload("res://scripts/data/talents.gd")
const Classes = preload("res://scripts/data/classes.gd")
const Ch7 = preload("res://scripts/core/chapter7.gd")

const MAPS := ["8-1", "8-2", "8-3"]
const NPCS := ["lac-phong-8", "tuyet-nga-8", "mac-tam-8", "lac-phong-8c", "to-su-kiem", "to-su-tien", "to-su-phap", "to-su-thuan", "to-su-linh"]
const HOOKS := ["on_load", "tick", "check_quest", "after_spawn", "on_kill", "is_hidden", "update_enemy", "chase", "perform", "elite_skill",
	"boss_phase_two", "update_rare", "copy_skill", "adjust_damage", "enemy_avoid", "vanish", "player_hurt", "safe_blocked", "drink",
	"derive_bonus", "derive_after", "map_requirement", "gate_open", "env_text", "env_alert", "quest_hud", "talk", "npc_visible",
	"talent_mult", "talent_cd_mult"]

# ---------------------------------------------------------------- C8-10…15: Suy Thiên, đèn, cột đá
const DECAY_STEP := 0.10
const DECAY_MAX := 0.50
const DECAY_EVERY := 60.0
const LAMP_R := 60.0
const LAMP_RESET := 5.0
const LAMP_LIGHT := 3.0
const LANTERN_TIME := 45.0
const SHOP_LANTERN := 150
const DARK_ON_DRAIN := 25.0
## Kẻ Nuốt Thiên Phú: đạn đánh dấu bằng hệ giả này (player_hurt nhận lại) — kháng hệ không có khoá này nên = 0.
const NUOT_EL := "nuot"
const NUOT_DECAY := 0.05
# ---------------------------------------------------------------- C8-20…25: quái
const STEALTH_STILL := 1.0
const STEALTH_REVEAL := 50.0
const BACKSTAB_MUL := 1.8
const BACK_ARC := deg_to_rad(60.0)
const VOIDBOLT_SPEED := 360.0
const CLEAVE_CD := 6.0
const CLEAVE_R := 50.0
const CLEAVE_ARC := deg_to_rad(45.0)
const CLEAVE_MUL := 1.6
const GAZE_LOCK := 1.0
const GAZE_TIME := 3.0
const GAZE_TICK := 0.2
const GAZE_MUL := 0.3
const GAZE_CD := 6.0
const SACRIFICE_CD := 15.0
const SACRIFICE_WINDUP := 1.5
const SACRIFICE_R := 120.0
const SACRIFICE_HEAL := 0.30
const SACRIFICE_ATK := 1.30
const SACRIFICE_TIME := 10.0
const FACELESS_TURN := deg_to_rad(90.0)
const FACELESS_FRONT := deg_to_rad(60.0)
const FACELESS_STILL := 1.5
## Đòn vùng có điểm rơi (Q84): nhận 50% từ nón trước của Quái Vật Không Mặt.
const AOE_SKILLS := ["rain", "meteor", "trap", "hoatuong", "muabang", "thientien", "thienhoa", "tinhvu", "chandia", "phanquyet", "thietchuy",
	"linhtran", "quandoan", "loidodang", "phongdodang", "kylan", "thienthuan", "baimin", "luoibay", "thienloi", "bangphong"]
const OBJECTS := ["long-hu-vo", "tru-phong-an"]
# ---------------------------------------------------------------- C8-30: Giáo Chủ Hư Vô
const SEAL_CD := 8.0
const SEAL_WINDUP := 1.0
const SEAL_R := 100.0
const SEAL_MUL := 1.8
const BEAM_CD := 5.0
const BEAM_WINDUP := 0.6
const BEAM_LEN := 250.0
const BEAM_HALF := 20.0
const BEAM_MUL := 1.2
const STAFF_MUL := 1.0
const DRAIN_EVERY := 30.0
const DRAIN_CHANNEL := 1.5
const DRAIN_TIME := 10.0
const DRAIN_TIME_RING := 5.0
const DRAIN_ATK := 0.15
const DRAIN_SET_CD := 60.0
const PRIEST_RAGE := 0.10
const PRIEST_RAGE_MAX := 0.50
const FOLLOWER_EVERY := 10.0
## Chuyển giai đoạn (60%, 25%): 6 giây trung lập — không nhận, không gây sát thương (bài học chương 6–7: thời lượng cố định
## cộng như nhau cho mọi lớp, thu hẹp chênh lệch).
## (Thử cho Giáo Chủ miễn sát thương lúc kênh: Pháp Sư mất phép rơi chậm, chậm thêm 35% — bỏ.)
const PHASE_INTRO := 6.0
# ---------------------------------------------------------------- C8-33: Hư Vô Thú
const DEVOUR_EVERY := 20.0
const DEVOUR_WINDUP := 1.0
const JAW_CD := 7.0
const JAW_WINDUP := 0.8
const JAW_R := 100.0
const JAW_ARC := deg_to_rad(30.0)
const JAW_MUL := 2.0
const LAIR_R := 180.0
# ---------------------------------------------------------------- đồ
const TINH_QUANG := "tinh_quang"
const AN_HU_VO := "an_hu_vo"
const NANH := "nanh_hu_vo"
const NANH_PEN := 0.30
const STEAL_R := 120.0
const STEAL_TIME := 6.0
const STEAL_HP := 0.10
const STEAL_HP_BOSS := 0.02
# ---------------------------------------------------------------- nhiệm vụ (profile.quest.ch8)
const S_TALK := 1
const S_KILLS := 2
const S_LAMPS := 3
const S_CAGES := 4
const S_ASSAULT := 5
const S_BOSS := 6
const S_JOB3 := 7
const CAGE_HP := 7.0
const SEAL_HP := 12.0
const GUARDS := 4
const WAVE_MOBS := 8
const SOLDIERS := 4
const SOLDIER_HP := 0.40
const SOLDIER_ATK := 0.30
const ASSAULT_R := 900.0
const RAID_EVERY := 1800.0
const RAID_WARN := 60.0
const RAID_LIMIT := 120.0
const RAID_OFF := 1800.0
const RAID_CRYSTAL := 15


class State:
	var decay := 0.0
	var decay_t := 0.0
	var lamp_t := 0.0
	var lantern_t := 0.0
	var drain_t := 0.0
	var set_cd := 0.0
	var k_last := 1.0
	var msg_cd := 0.0
	## thắp đèn nhiệm vụ: chỉ số đèn → giây đã đứng cạnh
	var light_t := {}
	## vòng báo [{pos, r, t, total, atk, mul}] · tia vẽ [{from, to, t}]
	var marks: Array = []
	var beams: Array = []
	## Mắt Hư Vô: id → {lock, beam, tick}
	var gaze := {}
	## Cột Đá trong đấu trường (thêm vào cột đá của map): [[tâm, bán kính]]
	var arena_stones: Array = []
	var arena_lamps: Array = []
	## Giáo Chủ
	var chan_t := 0.0
	var drain_cd := 0.0
	var seal_cd := 3.0
	var beam_cd := 1.5
	var intro_t := 0.0
	var rage := 0.0
	var buff_t := 0.0
	var follower_cd := 0.0
	var base_atk := 0.0
	## Hư Vô Thú: đèn quanh ổ [{pos, lit}]
	var lair: Array = []
	var devour_cd := DEVOUR_EVERY
	var jaw_cd := 3.0
	## Tổng tấn công
	var assault := false
	var soldier_hit := 0.0
	## Phản công Hư Vô: {} hoặc {lamp, warn, t, ids}
	var raid := {}
	var miss_text_t := 0.0


static func ensure(w) -> void:
	var q: Dictionary = w.profile.quest
	for k in ["ch8", "kills8"]:
		if not q.has(k):
			q[k] = 0
	for k in ["lamps8", "cages8", "pillars8"]:
		if not q.has(k):
			q[k] = []
	if int(q.ch8) == 0 and int(q.get("ch7", 0)) >= Story.DONE7:
		q.ch8 = S_TALK


static func step(w) -> int:
	ensure(w)
	return int(w.profile.quest.ch8)


static func chapter_done(w) -> bool:
	return step(w) >= Story.DONE8


## Đang ở vùng 8 ngoài trời (Suy Thiên không áp trong hang phụ — HP-10).
static func in_region(w) -> bool:
	return int(w.map.get("region", 1)) == 8 and not w.in_cave()


# ================================================================ Suy Thiên (C8-10, D70)


## Hiệu lực Thiên phú: 0 khi bị Hút, (1 − Suy Thiên) ở vùng 8.
static func talent_mult(w) -> float:
	var st = w.ch8
	if st.drain_t > 0.0:
		return 0.0
	return 1.0 - st.decay


## Hồi chiêu phím L × (1 + Suy Thiên).
static func talent_cd_mult(w) -> float:
	return 1.0 + w.ch8.decay


static func immune_decay(w) -> bool:
	# C9-46: kết thúc Hiến tế (Tinh Quang Thủ Hộ) miễn Suy Thiên.
	return w.has_unique(AN_HU_VO) or w.ch8.lantern_t > 0.0 or str(w.profile.ending) == "hien-te"


static func _apply_k(w) -> void:
	var st = w.ch8
	var k := talent_mult(w)
	Talents.suppressed = k <= 0.5
	if not is_equal_approx(k, st.k_last):
		st.k_last = k
		w._refresh_stats()


static func lamps(w) -> Array:
	return w.map.get("lamps", [])


## Đèn của map đang sáng? (đèn tắt chờ thắp ở bước 3; đèn bị Phản công làm tắt 30 phút)
static func lamp_lit(w, i: int) -> bool:
	if i in w.map.get("lamps_off", []) and not (i in w.profile.quest.lamps8):
		return false
	return float(w.profile.lamp_off_until.get("%s:%d" % [w.map_id, i], 0.0)) <= float(w.profile.play_seconds)


## Mọi đèn đang sáng quanh đây: đèn map + 4 đèn Điện Giáo Chủ + đèn quanh ổ Hư Vô Thú. [[pos, nguồn, chỉ số]]
static func lit_lamps(w) -> Array:
	var out: Array = []
	var ls := lamps(w)
	for i in ls.size():
		if lamp_lit(w, i):
			out.append([ls[i], "map", i])
	var st = w.ch8
	for i in st.arena_lamps.size():
		if st.arena_lamps[i].lit:
			out.append([st.arena_lamps[i].pos, "arena", i])
	for i in st.lair.size():
		if st.lair[i].lit:
			out.append([st.lair[i].pos, "lair", i])
	return out


static func lamp_near(w, pos: Vector2) -> Array:
	for l in lit_lamps(w):
		if pos.distance_to(l[0]) <= LAMP_R + w.PLAYER_RADIUS:
			return l
	return []


static func nearest_lamp(w, pos: Vector2) -> Vector2:
	var best := Vector2.INF
	for l in lit_lamps(w):
		if best == Vector2.INF or pos.distance_to(l[0]) < pos.distance_to(best):
			best = l[0]
	return best


static func _tick_decay(w, dt: float) -> void:
	var st = w.ch8
	var p = w.player
	if not lamp_near(w, p.pos).is_empty():
		st.lamp_t += dt
		if st.lamp_t >= LAMP_RESET and st.decay > 0.0:
			st.decay = 0.0
			st.decay_t = 0.0
			w._text(p.pos + Vector2(0, -44), "Thiên phú hồi phục", Color("#fff2b0"), true)
		return
	st.lamp_t = 0.0
	if immune_decay(w) or (p.pos.distance_to(w.safe_pos) < w.safe_r and not safe_blocked(w)):
		return
	var rate := 0.5 if int(w.equip_set_count(TINH_QUANG)) >= 2 else 1.0
	var rb = w.rare_boss()
	if rb != null and rb.kind == "hu-vo-thu" and rb.pos.distance_to(p.pos) < 700.0:
		rate *= 2.0
	st.decay_t += dt * rate
	if st.decay_t >= DECAY_EVERY:
		st.decay_t -= DECAY_EVERY
		if st.decay < DECAY_MAX - 0.001:
			add_decay(w, DECAY_STEP)


static func add_decay(w, v: float) -> void:
	var st = w.ch8
	if immune_decay(w):
		return
	st.decay = minf(DECAY_MAX, st.decay + v)
	w._text(w.player.pos + Vector2(0, -44), "Suy Thiên %d%%" % roundi(st.decay * 100.0), Color("#b46bff"), false)


# ================================================================ nạp map, khung hình


static func on_load(w) -> void:
	ensure(w)
	var st = w.ch8
	# cờ tĩnh có thể còn từ world trước (test, đổi nhân vật) — đặt lại rồi tính lại chỉ số
	if Talents.suppressed:
		Talents.suppressed = false
		w._refresh_stats()
	st.marks = []
	st.beams = []
	st.gaze = {}
	st.light_t = {}
	st.chan_t = 0.0
	st.intro_t = 0.0
	st.rage = 0.0
	st.buff_t = 0.0
	st.lair = []
	st.assault = false
	st.raid = {}
	st.arena_stones = []
	st.arena_lamps = []
	if not in_region(w):
		st.decay = 0.0
		st.decay_t = 0.0
		st.drain_t = 0.0
		Talents.suppressed = false
		_apply_k(w)
		return
	var m: Dictionary = w.map
	if m.arena != null:
		for i in 4:
			st.arena_stones.append([w.arena_pos + Vector2.from_angle(i * PI / 2.0) * w.arena_r * 0.5, 26.0])
			st.arena_lamps.append({"pos": w.arena_pos + Vector2.from_angle(PI / 4.0 + i * PI / 2.0) * w.arena_r * 0.72, "lit": true})
	var lv: int = int(m.levels[0]) + 1
	# C8-41 bước 4: Lồng Hư Vô ở 8-2 (1 Tư Tế + 4 quái canh)
	if w.map_id == "8-2" and step(w) >= S_CAGES:
		var cs: Array = m.get("cages", [])
		for i in cs.size():
			if i in w.profile.quest.cages8:
				continue
			_spawn_object(w, "long-hu-vo", lv, cs[i], CAGE_HP, "cage_idx", i)
			_spawn_guards(w, lv, cs[i])
	# C8-42: Trụ Phong Ấn ở 8-3
	if w.map_id == "8-3" and step(w) == S_ASSAULT:
		var ss: Array = m.get("seals", [])
		for i in ss.size():
			if i in w.profile.quest.pillars8:
				continue
			_spawn_object(w, "tru-phong-an", lv + 1, ss[i], SEAL_HP, "seal_idx", i)
			_spawn_guards(w, lv + 1, ss[i])
	if w.map_id == "8-1" and step(w) == S_TALK:
		w.say("r8_arrive")
	_apply_k(w)


static func _spawn_object(w, kind: String, lv: int, pos: Vector2, hp_mul: float, key: String, i: int):
	var a = w.spawn_enemy(kind, lv, pos, {"role": "anchor"})
	a.max_hp = float(w.Formulas.mob_stats(lv, "thuong", "li").hp) * hp_mul
	a.hp = a.max_hp
	a.home = pos
	a.set_meta(key, i)
	return a


static func _spawn_guards(w, lv: int, at: Vector2) -> void:
	for k in GUARDS:
		w.spawn_enemy(w._pick_kind(lv), lv, at + Vector2.from_angle(k * TAU / GUARDS) * 100.0, {"role": "pack"})
	w.spawn_enemy("ke-nuot", lv, at + Vector2(0, 130), {"role": "pack", "elite": true})


static func tick(w, dt: float) -> void:
	ensure(w)
	var st = w.ch8
	var p = w.player
	st.lantern_t -= dt
	st.set_cd -= dt
	st.msg_cd -= dt
	st.miss_text_t -= dt
	if st.drain_t > 0.0:
		st.drain_t -= dt
		if st.drain_t <= 0.0:
			w._message("Thiên phú đã trở lại.", "info")
	if not in_region(w):
		st.decay = 0.0
		st.lamp_t = 0.0
		_apply_k(w)
		return
	_tick_stones(w)
	_tick_marks(w, dt)
	_tick_buffs(w)
	if p.dead_timer <= 0.0:
		_tick_decay(w, dt)
		_tick_stealth(w, dt)
		_tick_faceless(w, dt)
		_tick_light(w, dt)
	_tick_assault(w, dt)
	_tick_raid(w, dt)
	_tick_boss(w, dt)
	_apply_k(w)


# ================================================================ Cột Đá Hư Vô (C8-13)


static func stones(w) -> Array:
	return Array(w.map.get("stones8", [])) + w.ch8.arena_stones


## Đoạn a → b bị một Cột Đá che?
static func blocked(w, a: Vector2, b: Vector2) -> bool:
	for s in stones(w):
		if Geometry2D.get_closest_point_to_segment(s[0], a, b).distance_to(s[0]) < float(s[1]):
			return true
	return false


static func in_stone(w, pos: Vector2, pad := 0.0) -> bool:
	for s in stones(w):
		if pos.distance_to(s[0]) < float(s[1]) + pad:
			return true
	return false


static func _tick_stones(w) -> void:
	var ss := stones(w)
	if ss.is_empty():
		return
	var p = w.player
	for s in ss:
		var c: Vector2 = s[0]
		var r: float = float(s[1]) + w.PLAYER_RADIUS
		if p.pos.distance_to(c) < r:
			p.pos = c + (p.pos - c).normalized() * r
	for pr in w.projectiles:
		if in_stone(w, pr.pos):
			pr.ttl = 0.0
	for sh in w.shots:
		if in_stone(w, sh.pos):
			sh.ttl = 0.0


static func enemy_avoid(w, e, pos: Vector2) -> bool:
	if not in_region(w) or e.speed <= 0.0:
		return false
	return in_stone(w, pos, e.radius)


# ================================================================ quái


static func after_spawn(w, e) -> void:
	if not in_region(w):
		return
	if e.role != "boss" and in_stone(w, e.pos, e.radius):
		for s in stones(w):
			if e.pos.distance_to(s[0]) < float(s[1]) + e.radius:
				e.pos = s[0] + (e.pos - s[0]).normalized() * (float(s[1]) + e.radius + 4.0)
		e.home = e.pos
		e.wander = e.pos
	if e.kind == "giap-si-hu-vo" and e.elite:
		e.set_meta("face8", (w.player.pos - e.pos).angle())
	if e.kind == "giao-chu":
		w.ch8.base_atk = e.atk


static func is_hidden(e) -> bool:
	return e.has_meta("stealth") and bool(e.get_meta("stealth"))


## C8-20: Bóng Hư Vô đứng yên > 1 giây thì tàng hình; hiện khi đi, khi trúng đòn, khi người chơi trong 5 m, hoặc có Mắt Ưng.
static func _tick_stealth(w, dt: float) -> void:
	var p = w.player
	var eagle: bool = str(w.profile.talent) == "mat-ung" and talent_mult(w) > 0.5
	for e in w.enemies:
		if e.dead or e.kind != "bong-hu-vo":
			continue
		var last: Vector2 = e.get_meta("last8", e.pos)
		var still: float = float(e.get_meta("still8", 0.0))
		still = still + dt if last.distance_to(e.pos) < 0.5 else 0.0
		e.set_meta("last8", e.pos)
		e.set_meta("still8", still)
		var show: bool = eagle or e.has_meta("follower") or e.hit_flash > 0.0 or e.state in ["windup", "stunned"] \
			or e.pos.distance_to(p.pos) <= STEALTH_REVEAL
		e.set_meta("stealth", still >= STEALTH_STILL and not show)


## C8-25: Quái Vật Không Mặt quay mặt 90°/giây về người chơi; đứng yên 1,5 giây sau mỗi đòn.
static func _tick_faceless(w, dt: float) -> void:
	for e in w.enemies:
		if e.dead or e.kind != "giap-si-hu-vo" or not e.elite:
			continue
		var f: float = float(e.get_meta("face8", 0.0))
		if e.state != "recover" and e.state != "windup" and e.state != "stunned":
			f = rotate_toward(f, (w.player.pos - e.pos).angle(), FACELESS_TURN * dt)
		e.set_meta("face8", f)


static func faceless_front(w, e) -> bool:
	var f: float = float(e.get_meta("face8", 0.0))
	return absf(angle_difference(f, (w.player.pos - e.pos).angle())) <= FACELESS_FRONT


static func chase(w, e, d: float, dt: float) -> bool:
	if e.kind != "giap-si-hu-vo":
		return false
	e.skill_cd -= dt
	if e.skill_cd <= 0.0 and d <= CLEAVE_R + e.radius + w.PLAYER_RADIUS:
		e.skill_cd = CLEAVE_CD
		w._begin_attack(e, "heavycleave", 1.0)
		w._text(e.pos + Vector2(0, -e.radius - 22), "Chém nặng!", Color("#c8a0ff"), false)
		return true
	return false


static func perform(w, e) -> bool:
	var p = w.player
	match e.attack_kind:
		"backstab":
			if e.pos.distance_to(p.pos) <= e.radius + e.attack_range + w.PLAYER_RADIUS + 12.0:
				var behind: bool = absf(angle_difference(p.facing, (e.pos - p.pos).angle())) > BACK_ARC
				w._damage_player(e.atk, BACKSTAB_MUL if behind else 1.0)
				if behind:
					w._text(p.pos + Vector2(0, -40), "Đâm lén!", Color("#b46bff"), false)
		"voidbolt":
			var pr = w.Projectile.new()
			pr.pos = e.pos
			pr.vel = Vector2.from_angle((e.target - e.pos).angle()) * VOIDBOLT_SPEED
			pr.ttl = (e.attack_range + 20.0) / VOIDBOLT_SPEED
			pr.atk = e.atk
			pr.element = NUOT_EL
			w.projectiles.append(pr)
		"heavycleave":
			var off: Vector2 = p.pos - e.pos
			w._blast(e.pos + Vector2.from_angle(e.face) * 30.0, CLEAVE_R, Color("#9a6ae0"))
			if off.length() <= CLEAVE_R + e.radius + w.PLAYER_RADIUS and absf(angle_difference(e.face, off.angle())) <= CLEAVE_ARC:
				w._damage_player(e.atk, CLEAVE_MUL)
		"sacrifice":
			_sacrifice(w, e)
		"seal":
			w._blast(e.target, SEAL_R, Color("#b46bff"))
			if p.pos.distance_to(e.target) <= SEAL_R + w.PLAYER_RADIUS:
				w._damage_player(e.atk, SEAL_MUL)
		"voidbeam":
			var to: Vector2 = e.pos + (e.target - e.pos).normalized() * BEAM_LEN
			w.ch8.beams.append({"from": e.pos, "to": to, "t": 0.3})
			if Geometry2D.get_closest_point_to_segment(p.pos, e.pos, to).distance_to(p.pos) <= BEAM_HALF + w.PLAYER_RADIUS \
					and not blocked(w, e.pos, p.pos):
				w._damage_player(e.atk, BEAM_MUL)
		"staff":
			if e.pos.distance_to(p.pos) <= e.radius + e.attack_range + w.PLAYER_RADIUS + 10.0:
				w._damage_player(e.atk, STAFF_MUL)
		"devour":
			_devour(w, e)
		"jaw":
			var off2: Vector2 = p.pos - e.pos
			w._blast(e.pos + off2.normalized() * 50.0, JAW_R * 0.6, Color("#6a3aa8"))
			if off2.length() <= JAW_R + e.radius + w.PLAYER_RADIUS and absf(angle_difference(e.face, off2.angle())) <= JAW_ARC:
				w._damage_player(e.atk, JAW_MUL)
		_:
			return false
	return true


static func elite_skill(w, e, kind: String) -> bool:
	match kind:
		"none":
			e.skill_cd = 999.0
			return true
		"sacrifice":
			if _victim(w, e) == null:
				e.skill_cd = 3.0
				return true
			e.skill_cd = SACRIFICE_CD
			w._begin_attack(e, "sacrifice", SACRIFICE_WINDUP)
			w._text(e.pos + Vector2(0, -e.radius - 24), "Tế lễ!", Color("#ff5a7a"), true)
			return true
	return false


static func _victim(w, e):
	var best = null
	var bd := SACRIFICE_R
	for o in w.enemies:
		if o == e or o.dead or o.elite or o.role in ["boss", "rare", "anchor"] or o.kind in OBJECTS:
			continue
		var d: float = o.pos.distance_to(e.pos)
		if d < bd:
			bd = d
			best = o
	return best


## C8-24: hiến 1 quái thường gần nhất (không EXP) → đồng bọn trong 12 m hồi 30% HP + 30% Tấn công 10 giây.
## Trong trận Giáo Chủ (C8-30c): Giáo Chủ +10% Tấn công mỗi lần (tối đa +50%).
static func _sacrifice(w, e) -> void:
	var v = _victim(w, e)
	if v == null:
		return
	v.set_meta("sacrificed", true)
	w._blast(v.pos, 40.0, Color("#ff5a7a"))
	w._kill_enemy(v)
	w._blast(e.pos, SACRIFICE_R, Color(1.0, 0.3, 0.5, 0.6))
	for o in w.enemies:
		if o.dead or o.kind in OBJECTS or o.pos.distance_to(e.pos) > SACRIFICE_R:
			continue
		if o.role == "boss":
			continue
		o.hp = minf(o.max_hp, o.hp + o.max_hp * SACRIFICE_HEAL)
		if not o.has_meta("base_atk8"):
			o.set_meta("base_atk8", o.atk)
			o.atk *= SACRIFICE_ATK
		o.set_meta("rage_until", w.time + SACRIFICE_TIME)
	var b = _boss(w)
	if b != null and e.role == "bossMinion":
		w.ch8.rage = minf(PRIEST_RAGE_MAX, w.ch8.rage + PRIEST_RAGE)
		w._text(b.pos + Vector2(0, -60), "Giáo Chủ +%d%% Tấn công" % roundi(w.ch8.rage * 100.0), Color("#ff5a7a"), true)


static func _clear_rage(o) -> void:
	if o.has_meta("base_atk8"):
		o.atk = float(o.get_meta("base_atk8"))
		o.remove_meta("base_atk8")
	if o.has_meta("rage_until"):
		o.remove_meta("rage_until")


static func _tick_buffs(w) -> void:
	for o in w.enemies:
		if o.has_meta("rage_until") and float(o.get_meta("rage_until")) <= w.time:
			_clear_rage(o)


## C8-23: Mắt Hư Vô — khoá 1 giây (tia mảnh báo), rồi chiếu 3 giây ×0,3 mỗi 0,2 giây; Cột Đá chặn tia. Đứng yên.
static func _update_eye(w, e, dt: float) -> bool:
	var st = w.ch8
	var p = w.player
	var g: Dictionary = st.gaze.get(e.id, {"lock": 0.0, "beam": 0.0, "tick": 0.0})
	st.gaze[e.id] = g
	e.face = (p.pos - e.pos).angle()
	var d: float = e.pos.distance_to(p.pos)
	if float(g.beam) > 0.0:
		g.beam = float(g.beam) - dt
		g.tick = float(g.tick) + dt
		if float(g.tick) >= GAZE_TICK:
			g.tick = float(g.tick) - GAZE_TICK
			if d <= e.attack_range + 80.0 and not blocked(w, e.pos, p.pos):
				w._incoming_el = ""
				w._damage_player(e.atk, GAZE_MUL)
		return true
	if float(g.lock) > 0.0:
		g.lock = float(g.lock) - dt
		if float(g.lock) <= 0.0:
			g.beam = GAZE_TIME
			g.tick = 0.0
		return true
	e.skill_cd -= dt
	var safe: bool = p.pos.distance_to(w.safe_pos) < w.safe_r and not safe_blocked(w)
	if p.dead_timer <= 0.0 and not safe and d <= e.attack_range and e.skill_cd <= 0.0:
		g.lock = GAZE_LOCK
		e.skill_cd = GAZE_CD
	return true


static func gaze_of(w, e) -> Dictionary:
	return w.ch8.gaze.get(e.id, {})


static func on_kill(w, e) -> void:
	ensure(w)
	var q: Dictionary = w.profile.quest
	var p = w.profile
	if in_region(w) and step(w) == S_KILLS and e.role in ["field", "pack", "nestMinion", "nestGuard"] and not e.has_meta("sacrificed"):
		pass  # NV-B (docs/41): bước này nay theo mục tiêu riêng — core/main_variants.gd ghi tiến độ
	if e.has_meta("cage_idx"):
		var i: int = int(e.get_meta("cage_idx"))
		if not (i in q.cages8):
			q.cages8.append(i)
			w.say("cage8_broken")
	if e.has_meta("seal_idx"):
		var j: int = int(e.get_meta("seal_idx"))
		if not (j in q.pillars8):
			q.pillars8.append(j)
			w._message("Trụ Phong Ấn đổ (%d/3)! Hư Vô Giáo phản công!" % q.pillars8.size(), "bad")
			_wave(w, e.pos, e.level)
	if e.kind == "giao-chu":
		var first: bool = int(q.get("cores8_first", 0)) == 0
		var n := 3 if first else 1
		q["cores8_first"] = 1
		p.void_cores = int(p.void_cores) + n
		p.crystal = float(p.crystal) + 15.0
		w._message("+%d Lõi Hư Vô, +15 Tinh Thạch." % n, "good")
		for m in w.enemies:
			if m.role == "bossMinion":
				m.dead = true
		w.ch8.rage = 0.0
		w.ch8.chan_t = 0.0
	if e.kind == "hu-vo-thu":
		p.void_cores = int(p.void_cores) + 1
		w._message("+1 Lõi Hư Vô.", "good")
		w.ch8.lair = []


## Đợt phản công: 8 quái vùng 8 + 1 tinh anh, lao vào người chơi.
static func _wave(w, at: Vector2, lv: int) -> void:
	for k in WAVE_MOBS:
		var m = w.spawn_enemy(w._pick_kind(lv), lv, at + Vector2.from_angle(k * TAU / WAVE_MOBS) * 160.0, {"role": "pack"})
		m.state = "chase"
	var ek: String = w._elite_kind(lv)
	if ek != "":
		var el = w.spawn_enemy(ek, lv, at + Vector2(0, 180), {"role": "pack", "elite": true})
		el.state = "chase"


## Vật thể (Lồng, Trụ) và quái bị hiến tế không cho EXP / đồ.
static func vanish(w, e) -> bool:
	if e.kind in OBJECTS:
		w._blast(e.pos, 60.0, Color("#b46bff"))
		on_kill(w, e)
		return true
	if e.has_meta("sacrificed"):
		return true
	return false


## Chặn sát thương: chuyển cảnh Giáo Chủ; Quái Vật Không Mặt (nón trước).
static func adjust_damage(w, e, dmg: int, by_player: bool) -> int:
	if e.kind == "giao-chu" and w.ch8.intro_t > 0.0:
		_miss(w, e, "Miễn sát thương")
		return 0
	if e.kind == "giap-si-hu-vo" and e.elite and e.state != "stunned":
		if not by_player:
			return maxi(1, dmg / 2)
		if faceless_front(w, e):
			if str(w.skill_ctx) in AOE_SKILLS:
				return maxi(1, dmg / 2)
			_miss(w, e, "Vô hiệu")
			return 0
	return dmg


static func _miss(w, e, text: String) -> void:
	if w.ch8.miss_text_t <= 0.0:
		w.ch8.miss_text_t = 0.4
		w._text(e.pos + Vector2(0, -e.radius - 20), text, Color("#c8c0d8"), false)


## C8-21: trúng đạn Kẻ Nuốt → xoá 1 hiệu ứng có lợi + Suy Thiên +5%.
static func player_hurt(w, _dmg: float, element: String) -> void:
	if element != NUOT_EL:
		return
	var p = w.player
	var lost := ""
	if p.guard_time > 0.0:
		p.guard_time = 0.0
		lost = "Thiết Bích"
	elif p.shield > 0.0:
		p.shield = 0.0
		p.shield_time = 0.0
		lost = "Khiên"
	elif p.eagle_time > 0.0:
		p.eagle_time = 0.0
		lost = "Ưng Nhãn"
	elif w.ch6.ascend_t > 0.0:
		w.ch6.ascend_t = 0.0
		lost = "Ám Hoá"
	if lost != "":
		w._text(p.pos + Vector2(0, -52), "Mất %s!" % lost, Color("#b46bff"), false)
	if in_region(w):
		add_decay(w, NUOT_DECAY)


# ================================================================ Giáo Chủ Hư Vô (C8-30)


static func _boss(w):
	var b = w.boss()
	return b if b != null and b.kind == "giao-chu" else null


static func boss_phase_two(_w, e) -> bool:
	return e.kind == "giao-chu"


static func update_enemy(w, e, dt: float) -> bool:
	if e.dead:
		return false
	if e.kind == "mat-hu-vo" and e.state != "stunned":
		return _update_eye(w, e, dt)
	if e.kind == "hu-vo-thu" and e.state != "stunned":
		return _update_beast(w, e, dt)
	if e.kind != "giao-chu" or e.state == "stunned":
		return false
	var st = w.ch8
	var p = w.player
	_phase(w, e)
	if st.base_atk <= 0.0:
		st.base_atk = e.atk
	e.atk = st.base_atk * (1.0 + st.rage) * ((1.0 + DRAIN_ATK) if st.buff_t > 0.0 else 1.0)
	if st.intro_t > 0.0:
		e.state = "chase"
		return true
	st.seal_cd -= dt
	st.beam_cd -= dt
	st.drain_cd -= dt
	if st.chan_t > 0.0:
		st.chan_t -= dt
		e.face = (p.pos - e.pos).angle()
		if st.chan_t <= 0.0:
			_drain(w, e)
		return true
	if e.state == "windup":
		e.timer -= dt
		if e.timer <= 0.0:
			perform(w, e)
			e.state = "recover"
			e.timer = 0.8
		return true
	if e.state == "recover":
		e.timer -= dt
		if e.timer <= 0.0:
			e.state = "chase"
		return true
	if p.dead_timer > 0.0:
		return true
	e.face = (p.pos - e.pos).angle()
	if e.phase >= 2 and st.drain_cd <= 0.0:
		st.drain_cd = DRAIN_EVERY
		st.chan_t = DRAIN_CHANNEL
		w._text(e.pos + Vector2(0, -70), "Hút Thiên phú!", Color("#d080ff"), true)
		w._message("Giáo Chủ kênh Hút Thiên phú — đứng vào vòng một Đèn Tinh Quang còn sáng!", "bad")
		return true
	if st.seal_cd <= 0.0:
		st.seal_cd = SEAL_CD
		w._begin_attack(e, "seal", SEAL_WINDUP)
		return true
	var d: float = e.pos.distance_to(p.pos)
	if st.beam_cd <= 0.0 and d > 80.0:
		st.beam_cd = BEAM_CD
		w._begin_attack(e, "voidbeam", BEAM_WINDUP)
		return true
	if d <= e.radius + e.attack_range + w.PLAYER_RADIUS:
		w._begin_attack(e, "staff", 0.6)
		return true
	w._move_toward(e, p.pos, e.speed, dt)
	return true


static func _phase(w, e) -> void:
	var st = w.ch8
	if e.phase == 1 and e.hp <= e.max_hp * 0.6:
		e.phase = 2
		st.intro_t = PHASE_INTRO
		st.drain_cd = PHASE_INTRO + 2.0
		w._text(e.pos + Vector2(0, -80), "Hư Vô nuốt trọn!", Color("#b46bff"), true)
		w._message("Giáo Chủ bắt đầu Hút Thiên phú mỗi 30 giây — 4 Đèn Tinh Quang chặn được 4 lần.", "bad")
	elif e.phase == 2 and e.hp <= e.max_hp * 0.25:
		e.phase = 3
		st.intro_t = PHASE_INTRO
		st.follower_cd = PHASE_INTRO + 2.0
		for i in 4:
			# 4 hướng chính — giữa các đèn (đèn ở 4 góc chéo), không đè lên chỗ người chơi tránh Hút Thiên phú
			var pos: Vector2 = w.arena_pos + Vector2.from_angle(i * PI / 2.0) * w.arena_r * 0.85
			var t = w.spawn_enemy("ke-nuot", 92, pos, {"role": "bossMinion", "elite": true})
			t.state = "chase"
			t.skill_cd = 6.0 + i
		w._text(e.pos + Vector2(0, -80), "Tín đồ, hiến thân!", Color("#ff5a7a"), true)
		w._message("4 Tư Tế Hư Vô — mỗi lần Tế lễ Giáo Chủ mạnh thêm 10%. Choáng để cắt Tế lễ!", "bad")


## Hút Thiên phú (C8-30b): đứng trong vòng một đèn đấu trường còn sáng → đèn chặn rồi tắt vĩnh viễn trong trận.
static func _drain(w, e) -> void:
	var st = w.ch8
	var p = w.player
	var near := lamp_near(w, p.pos)
	if not near.is_empty() and near[1] == "arena":
		st.arena_lamps[int(near[2])].lit = false
		w._blast(near[0], LAMP_R, Color("#fff2b0"))
		w._text(p.pos + Vector2(0, -50), "Đèn Tinh Quang chặn!", Color("#fff2b0"), true)
		return
	if p.dead_timer > 0.0:
		return
	if int(w.equip_set_count(TINH_QUANG)) >= 6 and st.set_cd <= 0.0:
		st.set_cd = DRAIN_SET_CD
		w._text(p.pos + Vector2(0, -50), "Tinh Quang hộ thể!", Color("#fff2b0"), true)
		return
	drain_talent(w, DRAIN_TIME_RING if w.has_unique(AN_HU_VO) else DRAIN_TIME)
	st.buff_t = DRAIN_TIME
	w.ch8.beams.append({"from": e.pos, "to": p.pos, "t": 0.5})


## Vô hiệu Thiên phú `t` giây (dùng lại ở Ma Tôn chương 9). Ám Khí +25 (C8-15).
static func drain_talent(w, t: float) -> void:
	var st = w.ch8
	var p = w.player
	st.drain_t = maxf(st.drain_t, t)
	w._text(p.pos + Vector2(0, -50), "THIÊN PHÚ BỊ HÚT!", Color("#d080ff"), true)
	w._message("Thiên phú bị vô hiệu %d giây." % roundi(t), "bad")
	var c6 = w.ch6
	c6.dark = minf(100.0, c6.dark + DARK_ON_DRAIN)
	if c6.dark >= 100.0:
		c6.dark = 0.0
		c6.ascend_t = 6.0
		w._text(p.pos + Vector2(0, -66), "Ám Hoá! +20% Tấn công", Color("#b36bff"), true)
	_apply_k(w)


static func _tick_boss(w, dt: float) -> void:
	var st = w.ch8
	st.buff_t -= dt
	for b in st.beams:
		b.t -= dt
	st.beams = st.beams.filter(func(b): return b.t > 0.0)
	var b = _boss(w)
	if b == null:
		st.chan_t = 0.0
		for l in st.arena_lamps:
			l.lit = true
		return
	_phase(w, b)
	if st.intro_t > 0.0:
		st.intro_t -= dt
		if b.state == "stunned":
			b.state = "chase"
			b.broken = false
	if b.phase >= 3 and st.intro_t <= 0.0:
		st.follower_cd -= dt
		if st.follower_cd <= 0.0:
			st.follower_cd = FOLLOWER_EVERY
			for k in 2:
				var f = w.spawn_enemy("bong-hu-vo", 92, b.pos + Vector2.from_angle(w._r() * TAU) * 120.0, {"role": "bossMinion"})
				f.set_meta("follower", true)
				f.state = "chase"


static func add_mark(w, pos: Vector2, r: float, t: float, atk: float, mul: float) -> void:
	w.ch8.marks.append({"pos": pos, "r": r, "t": t, "total": t, "atk": atk, "mul": mul})


static func _tick_marks(w, dt: float) -> void:
	var keep: Array = []
	for mk in w.ch8.marks:
		mk.t -= dt
		if mk.t > 0.0:
			keep.append(mk)
			continue
		w._blast(mk.pos, mk.r, Color("#b46bff"))
		if w.player.pos.distance_to(mk.pos) <= mk.r + w.PLAYER_RADIUS:
			w._damage_player(mk.atk, mk.mul)
	w.ch8.marks = keep


# ================================================================ Hư Vô Thú (C8-33)


## Chặn nhánh boss hiếm chung của GameWorld._update_rare (Lão Thụ gọi Mộc Tinh ở 40%) khi Hư Vô Thú ở xa.
static func update_rare(_w, e, _dt: float) -> bool:
	return e.kind == "hu-vo-thu"


## Gọi từ update_enemy (không qua update_rare: GameWorld vẫn chạy máy trạng thái chung sau update_rare).
static func _update_beast(w, e, dt: float) -> bool:
	var st = w.ch8
	var p = w.player
	if st.lair.is_empty():
		for i in 4:
			st.lair.append({"pos": e.home + Vector2.from_angle(PI / 4.0 + i * PI / 2.0) * LAIR_R, "lit": true})
	st.devour_cd -= dt
	st.jaw_cd -= dt
	if e.state == "windup":
		e.timer -= dt
		if e.timer <= 0.0:
			perform(w, e)
			e.state = "recover"
			var dark: bool = st.lair.filter(func(l): return l.lit).is_empty()
			e.timer = 0.9 / (1.2 if dark else 1.0)
		return true
	if e.state == "recover":
		e.timer -= dt
		if e.timer <= 0.0:
			e.state = "chase"
		return true
	if p.dead_timer > 0.0:
		return true
	e.face = (p.pos - e.pos).angle()
	var d: float = e.pos.distance_to(p.pos)
	if d > 900.0:
		return false
	e.state = "chase"
	if st.devour_cd <= 0.0 and not st.lair.filter(func(l): return l.lit).is_empty():
		st.devour_cd = DEVOUR_EVERY
		w._begin_attack(e, "devour", DEVOUR_WINDUP)
		w._text(e.pos + Vector2(0, -e.radius - 24), "Nuốt ánh sáng!", Color("#b46bff"), true)
		return true
	if st.jaw_cd <= 0.0 and d <= JAW_R + e.radius:
		st.jaw_cd = JAW_CD
		w._begin_attack(e, "jaw", JAW_WINDUP)
		return true
	if d <= e.radius + e.attack_range + w.PLAYER_RADIUS:
		w._begin_attack(e, "melee", 0.6)
		return true
	w._move_toward(e, p.pos, e.speed, dt)
	return true


static func _devour(w, _e) -> void:
	var st = w.ch8
	var best := -1
	for i in st.lair.size():
		if st.lair[i].lit and (best < 0 or w.player.pos.distance_to(st.lair[i].pos) < w.player.pos.distance_to(st.lair[best].pos)):
			best = i
	if best >= 0:
		st.lair[best].lit = false
		w._blast(st.lair[best].pos, LAMP_R, Color("#3a1a5a"))
		if st.lair.filter(func(l): return l.lit).is_empty():
			w._message("Ổ Hư Vô tối hẳn — Hư Vô Thú đánh nhanh hơn!", "bad")


# ================================================================ người chơi, đồ


## Đèn Lồng Tinh Quang tự giành phím Q khi Suy Thiên ≥ 20% (C8-14); còn lại phím Q là bình máu.
static func drink(w) -> bool:
	var st = w.ch8
	if int(w.profile.lanterns) <= 0 or not in_region(w) or st.lantern_t > 0.0 or st.decay < 0.2:
		return false
	w.profile.lanterns = int(w.profile.lanterns) - 1
	st.decay = 0.0
	st.decay_t = 0.0
	st.lantern_t = LANTERN_TIME
	w._text(w.player.pos + Vector2(0, -40), "Đèn Lồng Tinh Quang!", Color("#fff2b0"), true)
	_apply_k(w)
	return true


## Hiệu lực Thiên phú vào Stats.derive (bonus.talent_k) — Suy Thiên, Hút Thiên phú.
static func derive_bonus(w, bonus: Dictionary) -> void:
	bonus["talent_k"] = float(bonus.get("talent_k", 1.0)) * talent_mult(w)


static func derive_after(_w, _bonus: Dictionary, st: Dictionary) -> void:
	if NANH in st.get("uniques", []):
		st["armor_pen"] = minf(0.7, float(st.get("armor_pen", 0.0)) + NANH_PEN)


## C8-32 Hút Thiên Phú (Đạo Tặc): quái trong 12 m mất tăng cường 6 giây, hút 10% HP hiện tại (boss 2%), hồi cho người chơi.
static func copy_skill(w, id: String) -> bool:
	if id != "hut_thien":
		return false
	var p = w.player
	var healed := 0.0
	w._blast(p.pos, STEAL_R, Color("#d080ff"))
	w._text(p.pos + Vector2(0, -40), "Hút Thiên Phú!", Color("#d080ff"), true)
	for e in w.enemies:
		if e.dead or e.pos.distance_to(p.pos) > STEAL_R + e.radius:
			continue
		_clear_rage(e)
		w.ch7.shield_until.erase(e.id)
		if e.kind == "giao-chu":
			w.ch8.rage = 0.0
			w.ch8.buff_t = 0.0
		var big: bool = e.role in ["boss", "rare"]
		var take: float = e.hp * (STEAL_HP_BOSS if big else STEAL_HP)
		e.hp = maxf(1.0, e.hp - take)
		healed += take
	p.hp = minf(float(w.stats.max_hp), p.hp + healed)
	return true


# ================================================================ thắp đèn, Tổng tấn công, Phản công


static func _tick_light(w, dt: float) -> void:
	if w.map_id != "8-2" or step(w) != S_LAMPS:
		return
	var st = w.ch8
	var q: Dictionary = w.profile.quest
	var ls := lamps(w)
	for i in w.map.get("lamps_off", []):
		if i in q.lamps8:
			continue
		if w.player.pos.distance_to(ls[i]) <= LAMP_R + w.PLAYER_RADIUS:
			st.light_t[i] = float(st.light_t.get(i, 0.0)) + dt
			if st.light_t[i] >= LAMP_LIGHT:
				q.lamps8.append(i)
				w._blast(ls[i], LAMP_R, Color("#fff2b0"))
				w.say("lamp8_lit")
				var lv: int = int(w.map.levels[0]) + 1
				for k in 5:
					var m = w.spawn_enemy("bong-hu-vo", lv, ls[i] + Vector2.from_angle(k * TAU / 5.0) * 220.0, {"role": "pack"})
					m.state = "chase"
		else:
			st.light_t[i] = 0.0


static func soldiers(w) -> Array:
	return w.allies.filter(func(a): return not a.dead and a.kind == "soldier")


static func _tick_assault(w, dt: float) -> void:
	var st = w.ch8
	var p = w.player
	if w.map_id != "8-3" or step(w) != S_ASSAULT:
		if st.assault:
			_end_assault(w)
		return
	# thua: người chơi gục (hồi sinh ở Cổng Phá Vây) hoặc bỏ chạy xa mọi trụ còn lại
	var near_seal := false
	for e in w.enemies:
		if e.has_meta("seal_idx") and not e.dead and e.pos.distance_to(p.pos) <= ASSAULT_R * 1.6:
			near_seal = true
	if st.assault and (p.dead_timer > 0.0 or not near_seal):
		_end_assault(w)
		for e in w.enemies:
			if e.has_meta("seal_idx") and not e.dead:
				e.hp = e.max_hp
		w.say("assault8_lost")
		w._message("Tổng tấn công thất bại — trụ đã phá vẫn đổ. Quay lại gần trụ để công tiếp.", "bad")
		return
	if not st.assault:
		if p.dead_timer > 0.0:
			return
		for e in w.enemies:
			if e.has_meta("seal_idx") and not e.dead and e.pos.distance_to(p.pos) <= ASSAULT_R:
				_start_assault(w)
				break
		return
	# quân ta mất máu khi quái đứng sát (D: khung linh thú có máu — quái thường đánh quân ta mỗi giây)
	st.soldier_hit += dt
	if st.soldier_hit >= 1.0:
		st.soldier_hit -= 1.0
		for a in soldiers(w):
			for e in w.enemies:
				if e.dead or e.kind in OBJECTS or e.role == "boss" or e.pos.distance_to(a.pos) > e.radius + a.radius + 30.0:
					continue
				a.hp -= maxf(1.0, w.Formulas.compute_damage(e.atk, float(w.stats.def)) * 0.5)
				a.hurt_t = 3.0
			if a.hp <= 0.0:
				a.dead = true
				w._text(a.pos + Vector2(0, -30), "Lính Liên minh gục", Color("#c8c0d8"), false)


static func _start_assault(w) -> void:
	var st = w.ch8
	st.assault = true
	st.soldier_hit = 0.0
	w.say("assault8_start")
	for k in SOLDIERS:
		var a = w._add_ally("soldier", "linh-danh-thue", int(w.profile.level), w.player.pos + Vector2.from_angle(k * TAU / SOLDIERS) * 50.0)
		a.atk = float(w.stats.atk) * SOLDIER_ATK
		a.ttl = -1.0
		a.max_hp = float(w.stats.max_hp) * SOLDIER_HP
		a.hp = a.max_hp
		a.color = Color("#c8d8ec")


static func _end_assault(w) -> void:
	w.ch8.assault = false
	for a in soldiers(w):
		a.dead = true


## C8-43 Phản công Hư Vô: sau chương, mỗi 30 phút chơi ở vùng 8, một nhóm Hư Vô đánh một đèn (báo trước 60 giây).
static func _tick_raid(w, dt: float) -> void:
	var st = w.ch8
	var p = w.profile
	if not chapter_done(w) or lamps(w).is_empty():
		return
	if st.raid.is_empty():
		p.assault_play = float(p.assault_play) + dt
		if float(p.assault_play) < RAID_EVERY:
			return
		p.assault_play = 0.0
		var lit: Array = []
		for i in lamps(w).size():
			if lamp_lit(w, i):
				lit.append(i)
		if lit.is_empty():
			return
		st.raid = {"lamp": int(lit[int(w._r() * lit.size()) % lit.size()]), "warn": RAID_WARN, "t": 0.0, "ids": []}
		w.say("raid8_warn")
		w._message("Phản công Hư Vô! Một Đèn Tinh Quang bị tấn công sau 60 giây.", "bad")
		return
	var r: Dictionary = st.raid
	var at: Vector2 = lamps(w)[int(r.lamp)]
	if float(r.warn) > 0.0:
		r.warn = float(r.warn) - dt
		if float(r.warn) <= 0.0:
			var lv: int = int(w.map.levels[1])
			for k in WAVE_MOBS:
				var m = w.spawn_enemy(w._pick_kind(lv), lv, at + Vector2.from_angle(k * TAU / WAVE_MOBS) * 140.0, {"role": "pack"})
				r.ids.append(m.id)
			var pr = w.spawn_enemy("ke-nuot", lv, at + Vector2(0, 160), {"role": "pack", "elite": true})
			r.ids.append(pr.id)
		return
	r.t = float(r.t) + dt
	var alive := 0
	for e in w.enemies:
		if not e.dead and e.id in r.ids:
			alive += 1
	if alive == 0:
		p.crystal = float(p.crystal) + RAID_CRYSTAL
		w._message("Giữ được Đèn Tinh Quang! +%d Tinh Thạch." % RAID_CRYSTAL, "good")
		st.raid = {}
	elif float(r.t) >= RAID_LIMIT:
		p.lamp_off_until["%s:%d" % [w.map_id, int(r.lamp)]] = float(p.play_seconds) + RAID_OFF
		w._message("Đèn Tinh Quang bị dập tắt 30 phút.", "bad")
		st.raid = {}


# ================================================================ nhiệm vụ chương 8 (C8-41)


static func quest(w) -> Dictionary:
	return Story.quest8(step(w))


static func quest_status(w) -> Array:
	var q := quest(w)
	if q.is_empty():
		return [0, 0]
	var qd: Dictionary = w.profile.quest
	match str(q.type):
		"kills8":
			return [mini(int(qd.kills8), int(q.need)), int(q.need)]
		"lamps8":
			return [mini(qd.lamps8.size(), int(q.need)), int(q.need)]
		"cages8":
			return [mini(qd.cages8.size(), int(q.need)), int(q.need)]
		"assault8":
			return [mini(qd.pillars8.size(), int(q.need)), int(q.need)]
	return [0, int(q.need)]


static func check_quest(w) -> void:
	var q := quest(w)
	if q.is_empty():
		return
	var qd: Dictionary = w.profile.quest
	var done := false
	match str(q.type):
		"kills8":
			done = int(qd.kills8) >= int(q.need)
		"lamps8":
			done = qd.lamps8.size() >= int(q.need)
		"cages8":
			done = qd.cages8.size() >= int(q.need)
		"assault8":
			done = qd.pillars8.size() >= int(q.need)
		"boss8":
			done = w.is_boss_defeated("giao-chu")
		"job3":
			done = str(w.profile.job3) != ""
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
	p.lanterns = int(p.lanterns) + int(r.get("lanterns", 0))
	var rt := Story.reward_text(r)
	w._message("Nhiệm vụ chương 8 hoàn thành: %s%s" % [q.title, (". Thưởng: " + rt) if rt != "" else ""], "good")
	var s := step(w)
	p.quest.ch8 = s + 1
	w._events.append({"type": "quest_done", "step": s, "chapter": 8})
	if r.has("exp"):
		w.add_exp(float(r.exp), false)
	match s:
		S_TALK:
			w.say("lac8_kills")
		S_KILLS:
			w.say("nga8_lamps")
		S_LAMPS:
			w.say("lac8_cages")
		S_CAGES:
			w.say("mac8_rescued")
		S_ASSAULT:
			_end_assault(w)
			w.say("assault8_done")
		S_BOSS:
			w.say("ch8_end")
			w.say("lam8_letter")
		S_JOB3:
			w._events.append({"type": "chapter_end", "chapter": 8})


## Bấm E. Trả về "shop", "job3" hoặc "".
static func talk(w, npc_id: String) -> String:
	var s := step(w)
	match npc_id:
		"lac-phong-8", "lac-phong-8c":
			if s == S_TALK:
				w._force_say("lac8_meet")
				advance(w)
				return ""
			w._force_say("ch8_done" if chapter_done(w) else "lac8_idle")
			return ""
		"tuyet-nga-8":
			w._force_say("nga8_shop")
			return "shop"
		"mac-tam-8":
			w._force_say("mac8_idle")
			return ""
	for cid in Classes.JOB3_MASTERS:
		if Classes.JOB3_MASTERS[cid][0] == npc_id:
			if str(w.profile.class_id) != cid:
				w._force_say("to_su_wrong")
				return ""
			if str(w.profile.job3) != "":
				w._force_say("ch8_done")
				return ""
			return "job3"
	return ""


static func npc_visible(w, npc_id: String) -> bool:
	match npc_id:
		"mac-tam-8":
			return step(w) > S_CAGES
		"lac-phong-8c":
			return step(w) > S_ASSAULT
	if npc_id.begins_with("to-su-"):
		return w.is_boss_defeated("giao-chu")
	return true


## C8-01: điều kiện mở vùng 8 (mỗi điều kiện một dòng).
static func region_blockers(w) -> Array:
	var p = w.profile
	var out: Array = []
	if not Ch7.evolved_twice(p):
		out.append("Thiên phú tiến hoá 2 lần (Bia Đá gốc)")
	if not w.is_boss_defeated("cu-than"):
		out.append("Hạ Thiên Không Cự Thần")
	if int(p.level) < 83:
		out.append("Cấp 83 (đang %d)" % int(p.level))
	return out


static func map_requirement(w, id: String) -> String:
	match id:
		"8-1":
			var b := region_blockers(w)
			return "" if b.is_empty() else " · ".join(b)
		"8-2":
			return "" if "8-1" in w.profile.unlocked_maps else "Tới Rìa Vực trước."
		"8-3":
			return "" if "8-2" in w.profile.unlocked_maps else "Tới Đáy Vực trước."
	return ""


## Điện Giáo Chủ mở sau Tổng tấn công (bước 6).
static func gate_open(w, id: String) -> bool:
	if id == "8-3":
		return step(w) >= S_BOSS or w.is_boss_defeated("giao-chu")
	return true


## C8-42: Cổng Phá Vây chỉ là vùng an toàn sau Tổng tấn công.
static func safe_blocked(w) -> bool:
	return w.map_id == "8-3" and step(w) <= S_ASSAULT


static func env_text(w) -> String:
	if not in_region(w):
		return ""
	var st = w.ch8
	var p = w.player
	var parts := PackedStringArray()
	if st.drain_t > 0.0:
		parts.append("THIÊN PHÚ BỊ HÚT %.0f giây" % ceilf(st.drain_t))
	elif st.lantern_t > 0.0:
		parts.append("Đèn Lồng %d giây" % ceili(st.lantern_t))
	elif w.has_unique(AN_HU_VO):
		parts.append("Ấn Hư Vô: miễn Suy Thiên")
	else:
		var l := nearest_lamp(w, p.pos)
		var far := "" if l == Vector2.INF else " · đèn gần nhất %d m" % roundi(p.pos.distance_to(l) / 10.0)
		parts.append("Thiên phú −%d%%%s" % [roundi(st.decay * 100.0), far])
	if st.lamp_t > 0.0 and st.decay > 0.0:
		parts.append("Hồi Thiên phú %.0f/5 giây" % st.lamp_t)
	if st.chan_t > 0.0:
		parts.append("GIÁO CHỦ ĐANG HÚT THIÊN PHÚ — vào vòng đèn!")
	var b = _boss(w)
	if b != null and st.intro_t > 0.0:
		parts.append("Giáo Chủ hoá thân (%.1f giây)" % st.intro_t)
	if b != null and st.rage > 0.0:
		parts.append("Giáo Chủ +%d%% Tấn công" % roundi(st.rage * 100.0))
	if st.assault:
		parts.append("Tổng tấn công · trụ %d/3 · quân ta %d/%d" % [w.profile.quest.pillars8.size(), soldiers(w).size(), SOLDIERS])
	if not st.raid.is_empty():
		parts.append("Phản công Hư Vô %s" % ("sau %d giây" % ceili(float(st.raid.warn)) if float(st.raid.warn) > 0.0 else "— giữ đèn!"))
	if int(w.profile.lanterns) > 0:
		parts.append("Q: Đèn Lồng (%d)" % int(w.profile.lanterns))
	return "   ·   ".join(parts)


static func env_alert(w) -> bool:
	if not in_region(w):
		return false
	var st = w.ch8
	return st.chan_t > 0.0 or st.drain_t > 0.0 or st.decay >= DECAY_MAX - 0.001 or (not st.raid.is_empty() and float(st.raid.warn) > 0.0)


static func quest_hud(w) -> Dictionary:
	var q := quest(w)
	if not q.is_empty():
		var qs := quest_status(w)
		var rt := Story.reward_text(q.reward)
		return {"active": true, "title": "CHƯƠNG 8 · NHIỆM VỤ %d/%d" % [step(w), Story.QUESTS8.size()],
			"lines": [["◆ " + str(q.title) + ("  (%d/%d)" % qs if int(qs[1]) > 1 else ""), "gold"], [str(q.hint), "text"],
				[("Thưởng: " + rt) if rt != "" else "", "muted"]]}
	if chapter_done(w):
		return {"done": true, "title": "CHƯƠNG 8 · HOÀN THÀNH ✓",
			"lines": [["Thiên phú bị nuốt đã trở về chủ cũ", "text"],
				["Săn Hư Vô Thú ở Sào Huyệt Hư Vô", "muted"],
				["Chương 9: Cổng Thiên Đạo — sắp mở", "muted"]]}
	return {}
