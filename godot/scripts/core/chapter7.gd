extends RefCounted
## M10 — Chương 7 Thiên Không Đảo (docs/16-chuong-7.md). Gắn vào GameWorld qua core/chapters.gd (D38).
## Gồm: đảo bay (rơi khỏi mép → Đá Neo, −10% HP), cầu gió tắt theo chu kỳ, đảo vụn, Lông Vũ Gió; quái vùng 7
## (Quạt cánh đẩy lùi, Rễ quật, Tiên Gió hồi máu, Thương phá, Khiên trời, Rồng Mây); Thiên Không Cự Thần (3 giai đoạn,
## vành ngoài vỡ dần theo lượng sát thương); Kỳ Lân Mây; Bộ Thiên Phong, Búa Cự Thần, Sừng Kỳ Lân, Thiên Chuỳ (Đạo Tặc);
## Trụ Gió, Neo Hư Vô; nhiệm vụ chương 7; tiến hoá Thiên phú lần 2 / Đột Phá.
## Đơn vị: 1 m = 10 điểm ảnh.

const Story = preload("res://scripts/data/story.gd")
const Talents = preload("res://scripts/data/talents.gd")
const Explore = preload("res://scripts/core/explore.gd")
const Ch4 = preload("res://scripts/core/chapter4.gd")

const MAPS := ["7-1", "7-2", "7-3"]
const NPCS := ["van-hac", "phong-linh", "tuyet-nga-7"]
const HOOKS := ["on_load", "tick", "check_quest", "after_spawn", "on_kill", "update_enemy", "chase", "perform", "elite_skill",
	"update_rare", "adjust_damage", "dodge_hit", "derive_bonus", "move_mult", "heal_mult", "input_filter", "drink", "copy_skill",
	"after_slash", "after_shot", "enemy_avoid", "vanish", "map_requirement", "gate_open", "env_text", "env_alert", "quest_hud", "talk"]

# ---------------------------------------------------------------- C7-10…16: đảo bay
const FALL_DELAY := 0.25
const FALL_TIME := 1.0
const FALL_HP := 0.10
const FALL_INVULN := 1.5
const ANCHOR_R := 40.0
const BRIDGE_HALF := 30.0
const BRIDGE_PERIOD := 30.0
const BRIDGE_OFF := 5.0
const BRIDGE_WARN := 2.0
const BRIDGE_STAGGER := 4.3
const CRUMBLE_STEP := 10.0
const CRUMBLE_EVERY := 10.0
const CRUMBLE_REGROW := 60.0
const FEATHER_TIME := 2.0
const FEATHER_SPEED := 1.2
const SHOP_FEATHER := 120
const PILLAR_R := 60.0
const PILLAR_TIME := 2.0
# ---------------------------------------------------------------- C7-20…25: quái
const GUST_RANGE := 60.0
const GUST_ARC := deg_to_rad(30.0)
const GUST_MUL := 0.8
const GUST_PUSH := 50.0
const ROOT_R := 50.0
const ROOT_MUL := 1.3
const WINDBOLT_SPEED := 380.0
const HEAL_EVERY := 2.0
const HEAL_R := 100.0
const HEAL_PCT := 0.05
const LANCE_LEN := 150.0
const LANCE_HALF := 15.0
const LANCE_MUL := 1.6
const SHIELD_CD := 18.0
const SHIELD_R := 100.0
const SHIELD_TIME := 4.0
const DRAGON_ORBIT := 120.0
const DASH_CD := 8.0
const DASH_LEN := 180.0
const DASH_MUL := 2.0
const DASH_PUSH := 30.0
const VOID_GUARDS := 4
# ---------------------------------------------------------------- C7-30: Thiên Không Cự Thần
const CORE_R := 220.0
const SLAM_CD := 7.0
const SLAM_WINDUP := 1.0
const SLAM_R := 80.0
const SLAM_MUL := 2.0
const HOLE_TIME := 10.0
const HAIL_CD := 10.0
const HAIL_CD_P3 := 8.0
const HAIL_N := 10
const HAIL_R := 30.0
const HAIL_SPREAD := 140.0
const HAIL_WARN := 1.2
const HAIL_MUL := 1.0
const SMASH_WINDUP := 0.7
const SMASH_MUL := 1.0
const SECTOR_HP := 0.10
const SECTOR_TIME := 20.0
const SECTOR_WARN := 3.0
const FALL_BOSS_HEAL := 0.05
const HAMMER_CD := 14.0
const HAMMER_WINDUP := 1.2
const HAMMER_R := 120.0
const HAMMER_MUL := 3.0
const HAMMER_HITS := 3
# ---------------------------------------------------------------- C7-33: Kỳ Lân Mây
const KY_LAP := 3.0
const KY_RING := 200.0
const KY_TRAIL_TTL := 3.0
const KY_TRAIL_R := 28.0
const KY_TRAIL_MUL := 0.4
const KY_STOP_HP := 0.12
const KY_STOP_TIME := 6.0
const KY_THUNDER_N := 5
const KY_THUNDER_R := 40.0
const KY_THUNDER_WARN := 1.0
const KY_THUNDER_MUL := 1.5
const KY_RAM_MUL := 1.2
# ---------------------------------------------------------------- đồ, bộ
const THIEN_PHONG := "thien_phong"
const TP_ASPD := 0.10
const TP_FALL_CD := 60.0
const HAMMER_UNIQUE := "bua_cu_than"
const QUAKE_R := 60.0
const QUAKE_MUL := 0.8
const HORN := "sung_ky_lan"
const HORN_HEAL := 1.2
const HORN_EVERY := 10.0
const HORN_PCT := 0.05
const CHUY_R := 100.0
const CHUY_MUL := 3.0
const CHUY_STUN := 1.0
# ---------------------------------------------------------------- nhiệm vụ (profile.quest.ch7)
const S_PORT := 1
const S_TALK := 2
const S_KILLS := 3
const S_PILLARS := 4
const S_ANCHORS := 5
const S_EXPLORE := 6
const S_BOSS := 7
const S_EVO := 8
const STELE_R := 70.0


class State:
	var off_t := 0.0
	var fall_t := 0.0
	var invuln := 0.0
	var hover := 0.0
	var anchor := Vector2.ZERO
	var tp_fall_ready := 0.0
	## đảo vụn: [{pos, base, r, acc, regrow}]
	var crumble: Array = []
	## Trụ Gió: chỉ số → giây đã đứng cạnh
	var pillar_t := {}
	## vòng báo [{pos, r, t, atk, mul}]
	var marks: Array = []
	## vệt sấm Kỳ Lân [{pos, ttl}] + tích luỹ sát thương mỗi giây
	var trails: Array = []
	var trail_acc := 0.0
	var trail_drop := 0.0
	## id quái → thời điểm hết Khiên trời
	var shield_until := {}
	var heal_t := 0.0
	var horn_t := 0.0
	var hits := 0
	var shots := 0
	## Cự Thần
	var holes: Array = []
	var cracks: Array = []
	var broken := [false, false, false, false]
	var sector_warn := -1
	var sector_warn_t := 0.0
	var sector_t := 0.0
	var sector_mark := 0.0
	var slam_cd := 3.0
	var hail_cd := 5.0
	var hammer_cd := 0.0
	var hammer_left := 0
	## Kỳ Lân: "run" | "stop"
	var ky_mode := "run"
	var ky_angle := 0.0
	var ky_t := 0.0
	var ky_mark := 0.0
	var ky_cast := false
	var miss_text_t := 0.0
	var rite_said := false


static func ensure(w) -> void:
	var q: Dictionary = w.profile.quest
	for k in ["ch7", "kills7"]:
		if not q.has(k):
			q[k] = 0
	for k in ["pillars7", "anchors7"]:
		if not q.has(k):
			q[k] = []
	if int(q.ch7) == 0 and int(q.get("ch6", 0)) >= Story.DONE6:
		q.ch7 = S_PORT


static func step(w) -> int:
	ensure(w)
	return int(w.profile.quest.ch7)


## Đang ở vùng 7 ngoài trời (trong hang phụ không có mép — HP-10).
static func in_region(w) -> bool:
	return int(w.map.get("region", 1)) == 7 and not w.in_cave()


static func chapter_done(w) -> bool:
	return step(w) >= Story.DONE7


# ================================================================ đất liền


static func _in_circle(pos: Vector2, c: Vector2, r: float) -> bool:
	return pos.distance_squared_to(c) <= r * r


## Đất tĩnh của map (đảo + mọi cầu) — dùng cho vẽ cây, đặt quái/rương; không xét cầu tắt / nền vỡ.
static func on_land_static(m: Dictionary, pos: Vector2) -> bool:
	var isl: Array = m.get("islands", [])
	if isl.is_empty():
		return true
	for it in isl:
		if _in_circle(pos, it[0], float(it[1])):
			return true
	return false


static func bridge_seg(m: Dictionary, i: int) -> Array:
	var b: Array = m.bridges[i]
	return [m.islands[int(b[0])][0], m.islands[int(b[1])][0]]


## Cầu i đang bật? Cầu "solid" và cầu gần Trụ Gió đã kích không bao giờ tắt.
static func bridge_on(w, i: int) -> bool:
	return bridge_left(w, i) > 0.0


## Giây còn lại trước khi cầu tắt (INF = không tắt; 0 = đang tắt).
static func bridge_left(w, i: int) -> float:
	var m: Dictionary = w.map
	if i in m.get("solid", []) or _bridge_pinned(w, i):
		return INF
	var t: float = fposmod(float(w.time) + i * BRIDGE_STAGGER, BRIDGE_PERIOD)
	return maxf(0.0, (BRIDGE_PERIOD - BRIDGE_OFF) - t)


static func _bridge_pinned(w, i: int) -> bool:
	var pl: Array = w.map.get("pillars", [])
	if pl.is_empty():
		return false
	ensure(w)
	var seg := bridge_seg(w.map, i)
	for k in w.profile.quest.pillars7:
		var pp: Vector2 = pl[int(k)]
		if seg[0].distance_to(pp) < 400.0 or seg[1].distance_to(pp) < 400.0:
			return true
	return false


## Đứng trên đất (đảo, cầu đang bật, đảo vụn còn, nền đấu trường còn nguyên)?
static func on_land(w, pos: Vector2) -> bool:
	var m: Dictionary = w.map
	if not in_region(w) or not m.has("islands"):
		return true
	var st = w.ch7
	if m.arena != null and _in_circle(pos, w.arena_pos, w.arena_r):
		return _arena_floor(w, pos)
	for it in m.islands:
		if _in_circle(pos, it[0], float(it[1])):
			return true
	for c in st.crumble:
		if c.r > 0.0 and _in_circle(pos, c.pos, c.r):
			return true
	for i in m.get("bridges", []).size():
		if not bridge_on(w, i):
			continue
		var seg := bridge_seg(m, i)
		if Geometry2D.get_closest_point_to_segment(pos, seg[0], seg[1]).distance_to(pos) <= BRIDGE_HALF:
			return true
	return false


## Nền đấu trường: lõi 22 m không vỡ thành trời; vành ngoài mất theo cung; hố Đấm đất.
static func _arena_floor(w, pos: Vector2) -> bool:
	var st = w.ch7
	for h in st.holes:
		if _in_circle(pos, h.pos, h.r):
			return false
	var off: Vector2 = pos - w.arena_pos
	if off.length() > CORE_R and st.broken[sector_of(off)]:
		return false
	return true


static func sector_of(off: Vector2) -> int:
	return clampi(int(fposmod(off.angle(), TAU) / (TAU / 4.0)), 0, 3)


## Điểm đất gần nhất (đặt lại quái / rương / chỗ rơi khi không có Đá Neo).
static func land_point(m: Dictionary, pos: Vector2) -> Vector2:
	var best := pos
	var best_d := INF
	for it in m.get("islands", []):
		var c: Vector2 = it[0]
		var r: float = float(it[1]) - 40.0
		var d := maxf(0.0, pos.distance_to(c) - r)
		if d < best_d:
			best_d = d
			best = pos if pos.distance_to(c) <= r else c + (pos - c).normalized() * r
	return best


# ================================================================ nạp map, khung hình


static func on_load(w) -> void:
	ensure(w)
	var st = w.ch7
	st.off_t = 0.0
	st.fall_t = 0.0
	st.hover = 0.0
	st.marks = []
	st.trails = []
	st.holes = []
	st.cracks = []
	st.broken = [false, false, false, false]
	st.sector_warn = -1
	st.shield_until = {}
	st.pillar_t = {}
	st.crumble = []
	st.anchor = w.safe_pos
	if not in_region(w):
		return
	var m: Dictionary = w.map
	for c in m.get("crumble", []):
		st.crumble.append({"pos": c[0], "base": float(c[1]), "r": float(c[1]), "acc": 0.0, "regrow": 0.0})
	# rương / thảo dược / đồng minh không nằm giữa trời
	for h in w.herbs:
		h.pos = land_point(m, h.pos)
	for c in w.chests:
		c.pos = land_point(m, c.pos)
	for a in w.allies:
		a.pos = land_point(m, a.pos)
	# C7-41 bước 4: Neo Hư Vô ở 7-3 (mỗi neo 4 quái + 1 tinh anh canh)
	if w.map_id == "7-3" and step(w) >= S_ANCHORS:
		var va: Array = m.get("void_anchors", [])
		for i in va.size():
			if i in w.profile.quest.anchors7:
				continue
			var lv: int = int(m.levels[0]) + 1
			var a = w.spawn_enemy("neo-hu-vo", lv, va[i], {"role": "anchor"})
			a.max_hp = 20.0 * lv * 40.0
			a.hp = a.max_hp
			a.nest_tile_id = -1
			a.home = va[i]
			a.chain_left = 0
			a.fuse = 0.0
			a.set_meta("anchor_idx", i)
			for k in VOID_GUARDS:
				w.spawn_enemy(w._pick_kind(lv), lv, va[i] + Vector2.from_angle(k * TAU / VOID_GUARDS) * 90.0, {"role": "pack"})
			var ek: String = w._elite_kind(lv)
			if ek != "":
				w.spawn_enemy(ek, lv, va[i] + Vector2(0, 120), {"role": "pack", "elite": true})
	if step(w) == S_TALK - 0 and w.map_id == "7-1":
		w.say("r7_arrive")


static func tick(w, dt: float) -> void:
	ensure(w)
	var st = w.ch7
	var p = w.player
	st.invuln -= dt
	st.hover -= dt
	st.tp_fall_ready -= dt
	st.miss_text_t -= dt
	_tick_horn(w, dt)
	if not in_region(w):
		st.off_t = 0.0
		st.fall_t = 0.0
		return
	if st.fall_t > 0.0:
		st.fall_t -= dt
		if st.fall_t <= 0.0:
			_land(w)
		return
	if p.dead_timer > 0.0:
		return
	_touch_anchors(w)
	if st.hover <= 0.0 and p.dodge_time <= 0.0 and p.dash_time <= 0.0 and not on_land(w, p.pos):
		st.off_t += dt
		if st.off_t >= FALL_DELAY:
			_start_fall(w)
	else:
		st.off_t = 0.0
	_tick_crumble(w, dt)
	_tick_pillars(w, dt)
	_tick_heal(w, dt)
	_tick_marks(w, dt)
	_tick_trails(w, dt)
	_tick_boss(w, dt)
	_tick_stele(w)


static func _touch_anchors(w) -> void:
	var st = w.ch7
	var p = w.player
	var pts: Array = [w.safe_pos] + Array(w.map.get("anchors", []))
	for i in pts.size():
		if p.pos.distance_to(pts[i]) <= ANCHOR_R + w.safe_r * (1.0 if i == 0 else 0.0):
			st.anchor = pts[i]
			if i > 0:
				var got: Array = w.profile.anchor_stones.get(w.map_id, [])
				if not (i in got):
					got.append(i)
					w.profile.anchor_stones[w.map_id] = got
					w._text(pts[i] + Vector2(0, -50), "Đá Neo đã lưu", Color("#7ae0ff"), false)


static func _start_fall(w) -> void:
	var st = w.ch7
	st.fall_t = FALL_TIME
	st.off_t = 0.0
	w.move_target = Vector2.INF
	w._text(w.player.pos + Vector2(0, -40), "Rơi!", Color("#bcdcff"), true)


## Hiện lại ở Đá Neo đã chạm gần nhất (đấu trường: rìa tây lõi), −10% HP tối đa (bỏ qua Phòng thủ, không gục).
static func _land(w) -> void:
	var st = w.ch7
	var p = w.player
	var dest: Vector2 = st.anchor
	var b = _boss(w)
	if b != null:
		dest = w.arena_pos + Vector2(-CORE_R + 60.0, 0)
		b.hp = minf(b.max_hp, b.hp + b.max_hp * FALL_BOSS_HEAL)
		w._text(b.pos + Vector2(0, -60), "+5% HP", Color("#5bd16a"), true)
	else:
		var pts: Array = [w.safe_pos]
		var got: Array = w.profile.anchor_stones.get(w.map_id, [])
		var an: Array = w.map.get("anchors", [])
		for i in got:
			if int(i) - 1 < an.size():
				pts.append(an[int(i) - 1])
		var best: float = INF
		for q in pts:
			if q.distance_to(p.pos) < best:
				best = q.distance_to(p.pos)
				dest = q
	p.pos = dest + Vector2(0, 24)
	st.invuln = FALL_INVULN
	var free: bool = int(w.equip_set_count(THIEN_PHONG)) >= 6 and st.tp_fall_ready <= 0.0
	if free:
		st.tp_fall_ready = TP_FALL_CD
		w._text(p.pos + Vector2(0, -40), "Thiên Phong — không mất HP", Color("#bcdcff"), true)
	else:
		p.hp = maxf(1.0, p.hp - float(w.stats.max_hp) * FALL_HP)
		w._text(p.pos + Vector2(0, -40), "−10% HP", Color("#ff5470"), true)
	for a in w.allies:
		a.pos = p.pos + Vector2(30, 0)


static func _tick_crumble(w, dt: float) -> void:
	var p = w.player
	for c in w.ch7.crumble:
		if c.r <= 0.0:
			c.regrow -= dt
			if c.regrow <= 0.0:
				c.r = c.base
				c.acc = 0.0
			continue
		if _in_circle(p.pos, c.pos, c.r):
			c.acc += dt
			if c.acc >= CRUMBLE_EVERY:
				c.acc -= CRUMBLE_EVERY
				c.r -= CRUMBLE_STEP
				if c.r <= 20.0:
					c.r = 0.0
					c.regrow = CRUMBLE_REGROW


static func _tick_pillars(w, dt: float) -> void:
	var pl: Array = w.map.get("pillars", [])
	var q: Dictionary = w.profile.quest
	for i in pl.size():
		if i in q.pillars7:
			continue
		if w.player.pos.distance_to(pl[i]) <= PILLAR_R:
			w.ch7.pillar_t[i] = float(w.ch7.pillar_t.get(i, 0.0)) + dt
			if w.ch7.pillar_t[i] >= PILLAR_TIME:
				q.pillars7.append(i)
				w.say("pillar_lit")
				w._blast(pl[i], 60.0, Color("#7ae0ff"))
		else:
			w.ch7.pillar_t[i] = 0.0


## C7-22: Tiên Gió hồi 5% HP cho đồng bọn trong 10 m mỗi 2 giây (không tự hồi).
static func _tick_heal(w, dt: float) -> void:
	var st = w.ch7
	st.heal_t -= dt
	if st.heal_t > 0.0:
		return
	st.heal_t = HEAL_EVERY
	for f in w.enemies:
		if f.dead or f.kind != "tien-gio":
			continue
		for e in w.enemies:
			if e == f or e.dead or e.role == "boss" or e.role == "anchor" or e.hp >= e.max_hp:
				continue
			if e.pos.distance_to(f.pos) <= HEAL_R:
				e.hp = minf(e.max_hp, e.hp + e.max_hp * HEAL_PCT)
				w._text(e.pos + Vector2(0, -e.radius - 14), "+", Color("#5bd16a"), false)


static func add_mark(w, pos: Vector2, r: float, t: float, atk: float, mul: float) -> void:
	w.ch7.marks.append({"pos": pos, "r": r, "t": t, "total": t, "atk": atk, "mul": mul})


static func _tick_marks(w, dt: float) -> void:
	var p = w.player
	var keep: Array = []
	for mk in w.ch7.marks:
		mk.t -= dt
		if mk.t > 0.0:
			keep.append(mk)
			continue
		w._blast(mk.pos, mk.r, Color("#dfefff"))
		if p.pos.distance_to(mk.pos) <= mk.r + w.PLAYER_RADIUS:
			w._damage_player(mk.atk, mk.mul)
	w.ch7.marks = keep


static func _tick_trails(w, dt: float) -> void:
	var st = w.ch7
	var p = w.player
	var hot := false
	var atk := 0.0
	for tr in st.trails:
		tr.ttl -= dt
		if tr.ttl > 0.0 and p.pos.distance_to(tr.pos) <= KY_TRAIL_R + w.PLAYER_RADIUS:
			hot = true
			atk = tr.atk
	st.trails = st.trails.filter(func(t): return t.ttl > 0.0)
	if hot:
		st.trail_acc += dt
		if st.trail_acc >= 1.0:
			st.trail_acc -= 1.0
			w._damage_player(atk, KY_TRAIL_MUL)
	else:
		st.trail_acc = 0.0


## C7-34 Sừng Kỳ Lân: mỗi 10 giây hồi 5% HP.
static func _tick_horn(w, dt: float) -> void:
	if not w.has_unique(HORN):
		return
	var st = w.ch7
	st.horn_t += dt
	if st.horn_t >= HORN_EVERY:
		st.horn_t -= HORN_EVERY
		var p = w.player
		if p.dead_timer <= 0.0 and p.hp < float(w.stats.max_hp):
			p.hp = minf(float(w.stats.max_hp), p.hp + float(w.stats.max_hp) * HORN_PCT * heal_mult(w))
			w._text(p.pos + Vector2(0, -36), "Sừng Kỳ Lân +5% HP", Color("#5bd16a"), false)


## C7-41 bước 7 / C7-43: đứng cạnh Bia Đá gốc (tâm Đài Cự Thần) sau khi hạ Cự Thần → tiến hoá lần 2.
static func _tick_stele(w) -> void:
	var st = w.ch7
	if w.map_id != "7-3" or w.map.arena == null or _boss(w) != null:
		return
	if w.player.pos.distance_to(w.arena_pos) > STELE_R:
		st.rite_said = false
		return
	if step(w) != S_EVO or st.rite_said:
		return
	st.rite_said = true
	var why := can_evolve2(w)
	if why != "":
		w._force_say("stele_wait")
		w._message(why, "bad")
		return
	w._force_say("stele_rite")
	evolve2(w)


# ================================================================ quái


static func after_spawn(w, e) -> void:
	if not in_region(w) or e.role == "boss" or e.role == "anchor":
		return
	if not on_land_static(w.map, e.pos):
		e.pos = land_point(w.map, e.pos)
		e.home = e.pos
		e.wander = e.pos


static func enemy_avoid(w, e, pos: Vector2) -> bool:
	if not in_region(w) or e.role == "boss" or e.kind == "ky-lan-may":
		return false
	return not on_land(w, pos)


static func perform(w, e) -> bool:
	var p = w.player
	match e.attack_kind:
		"gust":
			var off: Vector2 = p.pos - e.pos
			if off.length() <= GUST_RANGE + e.radius + w.PLAYER_RADIUS and absf(angle_difference((e.target - e.pos).angle(), off.angle())) <= GUST_ARC:
				if w._damage_player(e.atk, GUST_MUL):
					push(w, off.normalized(), GUST_PUSH)
		"rootlash":
			w._blast(e.pos, ROOT_R + e.radius, Color("#86d47a"))
			if e.pos.distance_to(p.pos) <= ROOT_R + e.radius + w.PLAYER_RADIUS:
				w._damage_player(e.atk, ROOT_MUL)
		"windbolt":
			w._enemy_shot(e, (e.target - e.pos).angle(), 1.0, WINDBOLT_SPEED)
		"lance":
			var to: Vector2 = e.pos + (e.target - e.pos).normalized() * LANCE_LEN
			if Geometry2D.get_closest_point_to_segment(p.pos, e.pos, to).distance_to(p.pos) <= LANCE_HALF + w.PLAYER_RADIUS:
				w._damage_player(e.atk, LANCE_MUL)
		"clouddash":
			var from: Vector2 = e.pos
			var dest: Vector2 = e.pos + (e.target - e.pos).normalized() * DASH_LEN
			if on_land(w, dest):
				e.pos = dest
			if Geometry2D.get_closest_point_to_segment(p.pos, from, dest).distance_to(p.pos) <= e.radius + w.PLAYER_RADIUS:
				if w._damage_player(e.atk, DASH_MUL):
					push(w, (p.pos - from).normalized(), DASH_PUSH)
		"slam":
			_boss_slam(w, e)
		"smash":
			if e.pos.distance_to(p.pos) <= e.radius + e.attack_range + w.PLAYER_RADIUS + 10.0:
				w._damage_player(e.atk, SMASH_MUL)
		"hammer":
			w._blast(e.pos, HAMMER_R, Color("#ffd86a"))
			if e.pos.distance_to(p.pos) <= HAMMER_R + w.PLAYER_RADIUS:
				w._damage_player(e.atk, HAMMER_MUL)
		"ram":
			if e.pos.distance_to(p.pos) <= e.radius + e.attack_range + w.PLAYER_RADIUS + 10.0:
				w._damage_player(e.atk, KY_RAM_MUL)
		_:
			return false
	return true


## C7-16: đẩy lùi người chơi (Bộ Thiên Phong 2 món miễn; khiên / né đã chặn đòn thì không tới đây).
static func push(w, dir: Vector2, dist: float) -> void:
	if int(w.equip_set_count(THIEN_PHONG)) >= 2:
		return
	var p = w.player
	p.pos = (p.pos + dir * dist).clamp(Vector2.ONE * 20.0, w.world_size - Vector2.ONE * 20.0)


static func elite_skill(w, e, kind: String) -> bool:
	match kind:
		"skyshield":
			e.skill_cd = SHIELD_CD
			for o in w.enemies:
				if o != e and not o.dead and o.pos.distance_to(e.pos) <= SHIELD_R:
					w.ch7.shield_until[o.id] = w.time + SHIELD_TIME
			w._blast(e.pos, SHIELD_R, Color("#ffe39a"))
			w._text(e.pos + Vector2(0, -e.radius - 24), "Khiên trời!", Color("#ffe39a"), true)
			return true
		"clouddash":
			e.skill_cd = DASH_CD
			w._begin_attack(e, "clouddash", 0.7)
			w._text(e.pos + Vector2(0, -e.radius - 24), "Lao mây!", Color("#c8f4a8"), true)
			return true
	return false


## C7-25: Rồng Mây bay vòng quanh người chơi bán kính 12 m, tới lượt thì Lao mây.
static func chase(w, e, d: float, dt: float) -> bool:
	if e.kind != "dai-bang-may" or not e.elite:
		return false
	e.skill_cd -= dt
	if e.skill_cd <= 0.0:
		return elite_skill(w, e, "clouddash")
	var p = w.player
	var ang: float = (e.pos - p.pos).angle() + dt * 1.6
	w._move_toward(e, p.pos + Vector2.from_angle(ang) * DRAGON_ORBIT, e.speed, dt)
	return true


static func on_kill(w, e) -> void:
	ensure(w)
	var q: Dictionary = w.profile.quest
	if in_region(w) and step(w) == S_KILLS and e.role in ["field", "pack", "nestMinion", "nestGuard"]:
		q.kills7 = int(q.kills7) + 1
	if e.kind == "neo-hu-vo" and e.has_meta("anchor_idx"):
		var i: int = int(e.get_meta("anchor_idx"))
		if not (i in q.anchors7):
			q.anchors7.append(i)
			w.say("anchor_broken")


## Neo Hư Vô không cho EXP/đồ.
static func vanish(w, e) -> bool:
	if e.kind == "neo-hu-vo":
		w._blast(e.pos, 50.0, Color("#9b6ee0"))
		on_kill(w, e)
		return true
	return false


static func adjust_damage(w, e, dmg: int, by_player: bool) -> int:
	if not by_player:
		return dmg
	if float(w.ch7.shield_until.get(e.id, -1.0)) > w.time:
		_miss(w, e, "Khiên trời")
		return 0
	if e.kind == "ky-lan-may" and w.ch7.ky_mode == "run":
		_miss(w, e, "Trượt!")
		return 0
	return dmg


static func _miss(w, e, text: String) -> void:
	if w.ch7.miss_text_t <= 0.0:
		w.ch7.miss_text_t = 0.4
		w._text(e.pos + Vector2(0, -e.radius - 20), text, Color("#c8d8ec"), false)


# ================================================================ Thiên Không Cự Thần (C7-30)


static func _boss(w):
	var b = w.boss()
	return b if b != null and b.kind == "cu-than" else null


static func update_enemy(w, e, dt: float) -> bool:
	if e.kind != "cu-than" or e.state == "stunned" or e.dead:
		return false
	var st = w.ch7
	var p = w.player
	st.slam_cd -= dt
	st.hail_cd -= dt
	st.hammer_cd -= dt
	_phase(w, e)
	if e.state == "windup":
		e.timer -= dt
		if e.timer <= 0.0:
			perform(w, e)
			if e.attack_kind == "hammer" and st.hammer_left > 1:
				st.hammer_left -= 1
				w._begin_attack(e, "hammer", HAMMER_WINDUP)
			else:
				st.hammer_left = 0
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
	if st.hail_cd <= 0.0:
		st.hail_cd = HAIL_CD_P3 if e.phase >= 3 else HAIL_CD
		for i in HAIL_N:
			var pos: Vector2 = p.pos + Vector2.from_angle(w._r() * TAU) * (w._r() * HAIL_SPREAD)
			add_mark(w, pos, HAIL_R, HAIL_WARN, e.atk, HAIL_MUL)
		w._text(e.pos + Vector2(0, -70), "Mưa đá!", Color("#dfefff"), true)
	if e.phase >= 3 and st.hammer_cd <= 0.0:
		st.hammer_cd = HAMMER_CD
		st.hammer_left = HAMMER_HITS
		w._begin_attack(e, "hammer", HAMMER_WINDUP)
		w._text(e.pos + Vector2(0, -70), "Thiên chuỳ!", Color("#ffd86a"), true)
		return true
	if st.slam_cd <= 0.0:
		st.slam_cd = SLAM_CD
		w._begin_attack(e, "slam", SLAM_WINDUP)
		return true
	var d: float = e.pos.distance_to(p.pos)
	if d <= e.radius + e.attack_range + w.PLAYER_RADIUS:
		w._begin_attack(e, "smash", SMASH_WINDUP)
		return true
	w._move_toward(e, p.pos, e.speed, dt)
	return true


static func _phase(w, e) -> void:
	var st = w.ch7
	if e.phase == 1 and e.hp <= e.max_hp * 0.6:
		e.phase = 2
		st.sector_t = 0.0
		st.sector_mark = e.hp
		w._message("Đảo vỡ dần! Vành ngoài sẽ sụp từng cung — đứng gần tâm.", "bad")
	elif e.phase == 2 and e.hp <= e.max_hp * 0.2:
		e.phase = 3
		st.hammer_cd = 1.5
		w._message("Thiên chuỳ! Cự Thần nện 3 lần vòng 12 m — chạy ra xa.", "bad")


## Đấm đất: vòng 8 m tại điểm đánh dấu; nền vỡ 10 giây (trong lõi ở GĐ2+ chỉ nứt).
static func _boss_slam(w, e) -> void:
	var st = w.ch7
	var p = w.player
	w._blast(e.target, SLAM_R, Color("#c8b48a"))
	if p.pos.distance_to(e.target) <= SLAM_R + w.PLAYER_RADIUS:
		w._damage_player(e.atk, SLAM_MUL)
	if e.phase >= 2 and e.target.distance_to(w.arena_pos) <= CORE_R:
		st.cracks.append({"pos": e.target, "ttl": HOLE_TIME})
	else:
		st.holes.append({"pos": e.target, "r": SLAM_R, "ttl": HOLE_TIME})


static func _tick_boss(w, dt: float) -> void:
	var st = w.ch7
	for h in st.holes:
		h.ttl -= dt
	st.holes = st.holes.filter(func(h): return h.ttl > 0.0)
	for c in st.cracks:
		c.ttl -= dt
	st.cracks = st.cracks.filter(func(c): return c.ttl > 0.0)
	var b = _boss(w)
	if b == null:
		st.broken = [false, false, false, false]
		st.sector_warn = -1
		return
	if b.phase != 2 or not (false in st.broken):
		return
	if st.sector_warn >= 0:
		st.sector_warn_t -= dt
		if st.sector_warn_t <= 0.0:
			st.broken[st.sector_warn] = true
			st.sector_warn = -1
			w._blast(w.arena_pos, 40.0, Color("#c8b48a"))
		return
	st.sector_t += dt
	if st.sector_mark - b.hp >= b.max_hp * SECTOR_HP or st.sector_t >= SECTOR_TIME:
		st.sector_t = 0.0
		st.sector_mark = b.hp
		var pick := -1
		var best: float = INF
		for i in 4:
			if st.broken[i]:
				continue
			var mid: Vector2 = w.arena_pos + Vector2.from_angle((i + 0.5) * TAU / 4.0) * (CORE_R + 40.0)
			if mid.distance_to(w.player.pos) < best:
				best = mid.distance_to(w.player.pos)
				pick = i
		st.sector_warn = pick
		st.sector_warn_t = SECTOR_WARN
		w._text(w.arena_pos + Vector2(0, -CORE_R), "Vành đảo nứt!", Color("#ff7a45"), true)


# ================================================================ Kỳ Lân Mây (C7-33)


static func update_rare(w, e, dt: float) -> bool:
	if e.kind != "ky-lan-may":
		return false
	var st = w.ch7
	var p = w.player
	var home: Vector2 = e.home
	var ring: float = KY_RING
	for it in w.map.get("islands", []):
		if _in_circle(home, it[0], float(it[1])):
			home = it[0]
			ring = minf(KY_RING, float(it[1]) - 60.0)
			break
	if st.ky_mode == "run":
		st.ky_t += dt
		st.ky_angle += TAU / KY_LAP * dt
		e.pos = home + Vector2.from_angle(st.ky_angle) * ring
		e.face = st.ky_angle + PI / 2.0
		e.state = "chase"
		st.trail_drop -= dt
		if st.trail_drop <= 0.0:
			st.trail_drop = 0.12
			st.trails.append({"pos": e.pos, "ttl": KY_TRAIL_TTL, "atk": e.atk})
		if st.ky_t >= KY_LAP:
			st.ky_mode = "stop"
			st.ky_t = 0.0
			st.ky_mark = e.hp
			st.ky_cast = false
		return true
	# dừng: Sấm sét ngay khi dừng, rồi Húc nếu ở gần; chạy tiếp khi mất 12% HP hoặc hết 6 giây (D41)
	st.ky_t += dt
	if not st.ky_cast:
		st.ky_cast = true
		for i in KY_THUNDER_N:
			add_mark(w, p.pos + Vector2.from_angle(i * TAU / KY_THUNDER_N + w._r()) * (w._r() * 80.0), KY_THUNDER_R, KY_THUNDER_WARN, e.atk, KY_THUNDER_MUL)
		w._text(e.pos + Vector2(0, -e.radius - 24), "Sấm sét!", Color("#bcdcff"), true)
	if st.ky_mark - e.hp >= e.max_hp * KY_STOP_HP or st.ky_t >= KY_STOP_TIME:
		st.ky_mode = "run"
		st.ky_t = 0.0
		st.ky_angle = (e.pos - home).angle()
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
	e.face = (p.pos - e.pos).angle()
	if e.pos.distance_to(p.pos) <= e.radius + e.attack_range + w.PLAYER_RADIUS:
		w._begin_attack(e, "ram", 0.5)
	return true


# ================================================================ người chơi


static func dodge_hit(w) -> bool:
	return w.ch7.invuln > 0.0 or w.ch7.fall_t > 0.0


static func derive_bonus(_w, bonus: Dictionary) -> void:
	if int(bonus.sets.get(THIEN_PHONG, 0)) >= 4:
		bonus["atk_speed_pct"] = float(bonus.get("atk_speed_pct", 0.0)) + TP_ASPD


static func move_mult(w) -> float:
	return FEATHER_SPEED if w.ch7.hover > 0.0 else 1.0


static func heal_mult(w) -> float:
	return HORN_HEAL if w.has_unique(HORN) else 1.0


## Đang rơi: bỏ mọi phím.
static func input_filter(w, input: Dictionary) -> Dictionary:
	if w.ch7.fall_t <= 0.0:
		return input
	var out := input.duplicate()
	out.move = Vector2.ZERO
	for k in out.keys():
		if out[k] is bool:
			out[k] = false
	return out


## C7-15 phím Q: Lông Vũ Gió — lơ lửng 2 giây (không rơi), tốc chạy +20%.
static func drink(w) -> bool:
	if int(w.profile.feathers) <= 0 or not in_region(w) or w.ch7.hover > 0.0:
		return false
	w.profile.feathers = int(w.profile.feathers) - 1
	w.ch7.hover = FEATHER_TIME
	w._text(w.player.pos + Vector2(0, -40), "Lông Vũ Gió!", Color("#bcdcff"), true)
	return true


## C7-32 Thiên Chuỳ (Đạo Tặc): nện đất vòng 10 m ×3,0, choáng 1 giây (boss / tinh anh: gấp đôi vào Phá Thế).
static func copy_skill(w, id: String) -> bool:
	if id != "thien_chuy":
		return false
	var p = w.player
	w._blast(p.pos, CHUY_R, Color("#ffd86a"))
	w._text(p.pos + Vector2(0, -40), "Thiên Chuỳ!", Color("#ffd86a"), true)
	for e in w.enemies:
		if e.dead or e.pos.distance_to(p.pos) > CHUY_R + e.radius:
			continue
		var poise_before: float = e.poise
		w._hit_enemy(e, CHUY_MUL, false, true)
		if e.dead:
			continue
		if e.role == "boss" or e.role == "rare" or e.elite:
			e.poise = maxf(0.0, e.poise - (poise_before - e.poise))
		elif e.state != "stunned":
			e.state = "stunned"
			e.timer = CHUY_STUN
	return true


## C7-31 Búa Cự Thần: đòn chém thứ 3 → sóng chấn vòng 6 m ×0,8 trước mặt.
static func after_slash(w) -> void:
	if not w.has_unique(HAMMER_UNIQUE):
		return
	var st = w.ch7
	st.hits += 1
	if st.hits % 3 == 0:
		var p = w.player
		_quake(w, p.pos + Vector2.from_angle(p.facing) * 40.0)


## Bản bắn xa: phát bắn thứ 3 nổ sóng chấn tại điểm ngắm (tối đa 20 m).
static func after_shot(w, _mul: float) -> void:
	if not w.has_unique(HAMMER_UNIQUE):
		return
	var st = w.ch7
	st.shots += 1
	if st.shots % 3 == 0:
		var p = w.player
		_quake(w, p.pos + (w._aim - p.pos).limit_length(200.0))


static func _quake(w, at: Vector2) -> void:
	w._blast(at, QUAKE_R, Color("#ffd86a"))
	for e in w.enemies:
		if not e.dead and e.pos.distance_to(at) <= QUAKE_R + e.radius:
			w._hit_enemy(e, QUAKE_MUL, false, true)


# ================================================================ tiến hoá lần 2 (C7-43, C7-44)


## Thiên phú hết bậc 2 (SS, SSS…) → Đột Phá: giữ tên + hạng, vẫn tính 1 lần tiến hoá.
static func is_breakthrough(talent_id: String, evo: int) -> bool:
	return evo >= 2 and Talents.EVOLUTION.get(talent_id, []).size() < 2


static func form(talent_id: String, evo: int) -> Array:
	if is_breakthrough(talent_id, evo):
		var f := Ch4.evo_form(talent_id, 1)
		return [str(f[0]) + " · Đột Phá", str(f[1])]
	return Ch4.evo_form(talent_id, evo)


static func can_evolve2(w) -> String:
	var p = w.profile
	if Talents.EVOLUTION.get(str(p.talent), []).is_empty():
		return "Đạo Tặc không tiến hoá — coi như đã đạt."
	if int(p.evo) >= 2:
		return "Đã tiến hoá 2 lần."
	if int(p.evo) < 1:
		return "Cần tiến hoá lần 1 trước (Tinh Quang Sứ, Làng Chài Lau)."
	if Ch4.stage_level(p) < Talents.MAX_TALENT_LEVEL:
		return "Cần Thiên phú Lv%d (đang Lv%d)." % [Talents.MAX_TALENT_LEVEL, Ch4.stage_level(p)]
	if int(p.evo_essence) < 1:
		return "Cần 1 Tinh Hoa Tiến Hoá (rơi từ boss hiếm)."
	if step(w) < S_EVO:
		return "Hoàn thành nhiệm vụ chương 7 tới bước Nghịch Thiên Cải Mệnh."
	return ""


## Đã tiến hoá đủ 2 lần (Đạo Tặc coi như đạt) — điều kiện mở vùng 8.
static func evolved_twice(p) -> bool:
	return int(p.evo) >= 2 or Talents.EVOLUTION.get(str(p.talent), []).is_empty()


static func evolve2(w) -> Dictionary:
	var why := can_evolve2(w)
	if why != "":
		return {"ok": false, "message": why}
	var p = w.profile
	var before := form(str(p.talent), int(p.evo))
	p.evo_essence = int(p.evo_essence) - 1
	var spent := 0
	for lv in range(1, Talents.MAX_TALENT_LEVEL):
		spent += Talents.level_cost(lv)
	var refund := int(spent * Ch4.EVO_REFUND)
	p.essence = int(p.essence) + refund
	p.evo = 2
	w._refresh_stats()
	var after := form(str(p.talent), 2)
	var msg := "Nghịch Thiên Cải Mệnh! %s (%s) → %s (%s). Thiên phú về Lv1, hoàn %d Thiên Phú Tinh Hoa." % [before[0], before[1], after[0], after[1], refund]
	w._message(msg, "good")
	w._events.append({"type": "evolve", "name": after[0], "rank": after[1]})
	w._sfx("levelup")
	if step(w) == S_EVO:
		advance(w)
	return {"ok": true, "message": msg}


# ================================================================ nhiệm vụ chương 7 (C7-41)


static func quest(w) -> Dictionary:
	return Story.quest7(step(w))


static func quest_status(w) -> Array:
	var q := quest(w)
	if q.is_empty():
		return [0, 0]
	var qd: Dictionary = w.profile.quest
	match str(q.type):
		"port7":
			return [mini(int(w.profile.camp_level), 5) + (1 if Explore.is_built(w.profile, "port") else 0), 6]
		"kills7":
			return [mini(int(qd.kills7), int(q.need)), int(q.need)]
		"pillars7":
			return [mini(qd.pillars7.size(), int(q.need)), int(q.need)]
		"anchors7":
			return [mini(qd.anchors7.size(), int(q.need)), int(q.need)]
	return [0, int(q.need)]


static func check_quest(w) -> void:
	var q := quest(w)
	if q.is_empty():
		return
	var qd: Dictionary = w.profile.quest
	var done := false
	match str(q.type):
		"port7":
			done = Explore.is_built(w.profile, "port")
		"kills7":
			done = int(qd.kills7) >= int(q.need)
		"pillars7":
			done = qd.pillars7.size() >= int(q.need)
		"anchors7":
			done = qd.anchors7.size() >= int(q.need)
		"explore7":
			done = w.map_id == "7-3" and w.explore_ratio("7-3") >= 0.4
		"boss7":
			done = w.is_boss_defeated("cu-than")
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
	p.feathers = int(p.feathers) + int(r.get("feathers", 0))
	var rt := Story.reward_text(r)
	w._message("Nhiệm vụ chương 7 hoàn thành: %s%s" % [q.title, (". Thưởng: " + rt) if rt != "" else ""], "good")
	var s := step(w)
	p.quest.ch7 = s + 1
	w._events.append({"type": "quest_done", "step": s, "chapter": 7})
	if r.has("exp"):
		w.add_exp(float(r.exp), false)
	match s:
		S_PORT:
			w.say("r7_port_done")
		S_TALK:
			w.say("van_birds")
		S_KILLS:
			w.say("van_pillars")
		S_PILLARS:
			w.say("van_anchors")
		S_EXPLORE:
			w.say("cu_than_gate")
		S_EVO:
			w.say("ch7_end")
			w._events.append({"type": "chapter_end", "chapter": 7})


## Bấm E. Trả về "shop" (mở cửa hàng) hoặc "".
static func talk(w, npc_id: String) -> String:
	var s := step(w)
	match npc_id:
		"van-hac":
			if s == S_TALK:
				w._force_say("van_meet")
				advance(w)
				return ""
			if s == S_EVO:
				w._force_say("stele_wait")
				return ""
			w._force_say("ch7_done" if chapter_done(w) else "vanhac_idle")
			return ""
		"phong-linh":
			w._force_say("phong_shop")
			return "shop"
		"tuyet-nga-7":
			w._force_say("nga7_idle")
			return ""
	return ""


## C7-01: điều kiện mở vùng 7 (mỗi điều kiện một dòng).
static func region_blockers(w) -> Array:
	var p = w.profile
	var out: Array = []
	if int(p.camp_level) < 5:
		out.append("Lãnh địa cấp 5 — Hoàng Thành (đang %s)" % Explore.camp_name(p))
	if not Explore.is_built(p, "port"):
		out.append("Xây Cảng Khí Cầu")
	if not w.is_boss_defeated("ban-nga"):
		out.append("Hạ Bản Ngã Bóng Tối")
	if int(p.level) < 71:
		out.append("Cấp 71 (đang %d)" % int(p.level))
	return out


static func map_requirement(w, id: String) -> String:
	match id:
		"7-1":
			var b := region_blockers(w)
			return "" if b.is_empty() else "Cần: " + " · ".join(b)
		"7-2":
			return "" if "7-1" in w.profile.unlocked_maps else "Tới Đảo Mây Trôi trước."
		"7-3":
			return "" if "7-2" in w.profile.unlocked_maps else "Tới Đảo Rừng Treo trước."
	return ""


static func gate_open(w, id: String) -> bool:
	if id == "7-3":
		return step(w) >= S_BOSS or w.is_boss_defeated("cu-than")
	return true


static func env_text(w) -> String:
	if not in_region(w):
		return ""
	var st = w.ch7
	var p = w.player
	var parts := PackedStringArray()
	if st.fall_t > 0.0:
		parts.append("RƠI KHỎI ĐẢO…")
	if st.hover > 0.0:
		parts.append("Lông Vũ Gió %.1f giây" % st.hover)
	var m: Dictionary = w.map
	for i in m.get("bridges", []).size():
		var seg := bridge_seg(m, i)
		if Geometry2D.get_closest_point_to_segment(p.pos, seg[0], seg[1]).distance_to(p.pos) > BRIDGE_HALF:
			continue
		if on_land_static(m, p.pos):
			continue
		var left := bridge_left(w, i)
		if left < INF:
			parts.append("Cầu gió tắt sau 0:%02d" % ceili(left))
		break
	for c in st.crumble:
		if c.r > 0.0 and _in_circle(p.pos, c.pos, c.r):
			parts.append("Đảo vụn đang sụp")
			break
	var b = _boss(w)
	if b != null and st.sector_warn >= 0:
		parts.append("VÀNH ĐẢO SẮP VỠ — vào gần tâm!")
	if int(w.profile.feathers) > 0:
		parts.append("Q: Lông Vũ Gió (%d)" % int(w.profile.feathers))
	return "   ·   ".join(parts)


static func env_alert(w) -> bool:
	if not in_region(w):
		return false
	var st = w.ch7
	if st.fall_t > 0.0 or st.sector_warn >= 0:
		return true
	var m: Dictionary = w.map
	for i in m.get("bridges", []).size():
		var seg := bridge_seg(m, i)
		if Geometry2D.get_closest_point_to_segment(w.player.pos, seg[0], seg[1]).distance_to(w.player.pos) <= BRIDGE_HALF \
				and not on_land_static(m, w.player.pos) and bridge_left(w, i) <= BRIDGE_WARN:
			return true
	return false


static func quest_hud(w) -> Dictionary:
	var q := quest(w)
	if not q.is_empty():
		var qs := quest_status(w)
		var rt := Story.reward_text(q.reward)
		return {"active": true, "title": "CHƯƠNG 7 · NHIỆM VỤ %d/%d" % [step(w), Story.QUESTS7.size()],
			"lines": [["◆ " + str(q.title) + ("  (%d/%d)" % qs if int(qs[1]) > 1 else ""), "gold"], [str(q.hint), "text"],
				[("Thưởng: " + rt) if rt != "" else "", "muted"]]}
	if chapter_done(w):
		return {"done": true, "title": "CHƯƠNG 7 · HOÀN THÀNH ✓",
			"lines": [["Giáo Chủ Hư Vô mang mảnh Bia về Vực Hư Vô", "text"],
				["Săn Kỳ Lân Mây ở Thiên Cung Đổ Nát", "muted"],
				["Chương 8: Vực Hư Vô — sắp mở", "muted"]]}
	return {}
