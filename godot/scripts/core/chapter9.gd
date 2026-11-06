extends RefCounted
## M12 — Chương 9 Thiên Đạo Chi Môn (docs/18-chuong-9.md, rà lại 31/10 mục 0b). Gắn vào GameWorld qua core/chapters.gd (D38).
## Gồm: 9 tầng (3 tầng mỗi map, Cửa Tầng mở khi hạ Thủ Tầng — profile.floors9), hệ tầng đổi mỗi lần bước vào tầng
## (Enemy.el_override), Ấn Hệ, mật độ quái theo tầng; quái vùng 9 (Kích ngũ hành, Tàn Hồn mang Thiên phú, Phi nước đại,
## Gầm ngũ hành, Thiên phạt, Ngũ Hành Sứ Giả đổi hệ); Ma Tôn Vô Diện (3 giai đoạn dùng lại cơ chế boss chương 1–8 viết gọn,
## mảnh thứ hai dưới 10%); Thiên Đạo Hư Ảnh; Bộ Thiên Đạo, Mặt Nạ Vô Diện, Vô Diện (Đạo Tặc); nhiệm vụ chương 9, 9 dòng
## ký ức, lựa chọn kết thúc (choose_ending) + hiệu ứng hai kết thúc (Thiên Đạo Lực / Thần Hoá; Hiến tế: sương tan,
## +20% Thiên phú, +30% lãnh địa). Endgame (cấp sau 100, Thần Vực, Tái Thiết) ở core/endgame.gd.
## Đơn vị: 1 m = 10 điểm ảnh. Vị trí trên map đọc từ w.map (đã nhân MAP_SCALE).

const Story = preload("res://scripts/data/story.gd")
const Talents = preload("res://scripts/data/talents.gd")
const Monsters = preload("res://scripts/data/monsters.gd")
const Maps = preload("res://scripts/data/maps.gd")
const ItemData = preload("res://scripts/data/items.gd")
const Explore = preload("res://scripts/core/explore.gd")
const Fog = preload("res://scripts/core/fog.gd")
const Ch6 = preload("res://scripts/core/chapter6.gd")
const Ch8 = preload("res://scripts/core/chapter8.gd")

const MAPS := ["9-1", "9-2", "9-3"]
const NPCS := ["van-hac-9", "tuyet-nga-9", "lam-nhi-9"]
const HOOKS := ["on_load", "tick", "check_quest", "after_spawn", "on_kill", "on_player_hit", "is_hidden", "update_enemy", "update_rare",
	"chase", "perform", "elite_skill", "boss_phase_two", "copy_skill", "adjust_damage", "vanish", "input_filter", "hit_mult", "dodge_hit",
	"derive_bonus", "map_requirement", "gate_open", "env_text", "env_alert", "quest_hud", "talk", "npc_visible", "talent_mult", "talent_cd_mult"]

const ELEMENTS := ["kim", "moc", "thuy", "hoa", "tho"]
# ---------------------------------------------------------------- C9-10…12: tầng, Ấn Hệ
const SEAL_TIME := 60.0
const SEAL_TIME_NGU_HANH := 120.0
const SEAL_RESPAWN := 90.0
const SEAL_PICK_R := 40.0
const COUNTER := 0.30
const SET4_COUNTER := 1.5 / 1.3
const DENSITY_STEP := 0.05
const DENSITY_EVERY := 3.0
const DOOR_PUSH := 30.0
# ---------------------------------------------------------------- C9-20…25: quái
const LANCE_CD := 6.0
const LANCE_LEN := 60.0
const LANCE_HALF := 14.0
const LANCE_MUL := 1.4
const GALLOP_CD := 7.0
const GALLOP_LEN := 200.0
const GALLOP_MUL := 1.5
const ROAR_CD := 10.0
const ROAR_R := 80.0
const ROAR_MUL := 1.2
const NOCOUNTER_TIME := 5.0
const THUNDER_CD := 12.0
const THUNDER_N := 5
const THUNDER_R := 40.0
const THUNDER_RING := 50.0
const THUNDER_WARN := 1.2
const THUNDER_MUL := 1.6
const SWAP_EVERY := 8.0
const SWAP_WARN := 1.0
const ENVOY_TAKEN := 0.25
const SOUL_SLOW_EVERY := 8.0
const SOUL_SUMMON_EVERY := 12.0
const SOUL_COPY_EVERY := 10.0
# ---------------------------------------------------------------- C9-30: Ma Tôn Vô Diện
## Chuyển giai đoạn 66% / 33%: 6 giây trung lập (bài học chương 6–8); mảnh thứ hai (10%): 3 giây.
const PHASE_INTRO := 6.0
const SHARD_INTRO := 3.0
const CORE_R := 240.0
const POUNCE_CD := 9.0
const POUNCE_WINDUP := 0.8
const POUNCE_REACH := 300.0
const POUNCE_R := 90.0
const POUNCE_MUL := 2.0
const CLONE_HP := 0.12
const CLONE_TIME := 8.0
const CLONE_HITS := 3
const BURROW_CD := 20.0
const BURROW_TIME := 1.5
const BURROW_R := 70.0
const BURROW_MUL := 2.0
const STAFF_MUL := 1.0
const DREAM_CD := 25.0
const DREAM_WINDUP := 1.5
const DREAM_TIME := 4.0
const LAVA_CD := 25.0
const LAVA_WARN := 3.0
const LAVA_TIME := 5.0
const LAVA_HP := 0.08
const STONE_R := 30.0
const COPY_DELAY := 3.0
const SECTOR_HP := 0.08
const SECTOR_TIME := 20.0
const SECTOR_WARN := 3.0
const FALL_HP := 0.10
const FALL_HEAL := 0.03
const DRAIN_EVERY := 30.0
const DRAIN_CHANNEL := 1.5
const ELEMENT_EVERY := 10.0
const DARK_RATE := 10.0
# ---------------------------------------------------------------- C9-33: Thiên Đạo Hư Ảnh
const HA_MECHS := ["ngu-hanh", "thoi-gian-ngung-dong", "bay-dan", "thien-menh", "long-mach", "dao-tac"]
# ---------------------------------------------------------------- đồ, kết thúc
const THIEN_DAO := "thien_dao"
const MASK := "mat_na_vo_dien"
const MASK_EVERY := 30.0
const MASK_TIME := 10.0
const BOOST_MUL := 1.5
const DIVINE_FORCE_MAX := 100.0
const GODFORM_TIME := 10.0
const GODFORM_ATK := 1.3
const GODFORM_ASPD := 0.15
const SACRIFICE_TALENT := 1.2
# ---------------------------------------------------------------- nhiệm vụ (profile.quest.ch9)
const S_TALK := 1
const S_KILLS := 2
const S_FLOORS := 3
const S_SOULS := 4
const S_EXPLORE := 5
const S_BOSS := 6
const S_ENDING := 7


class State:
	var rng := RandomNumberGenerator.new()
	## tầng → hệ đang có / hệ lần trước
	var floor_el := {}
	var last_el := {}
	var cur_floor := 0
	var seal_t := 0.0
	var seal_cd := {}
	var nocounter_t := 0.0
	var density_t := 0.0
	var door_msg := 0.0
	var marks: Array = []
	var mask_t := 0.0
	var boost_t := 0.0
	var miss_text_t := 0.0
	## Ma Tôn
	var intro_t := 0.0
	var pounce_cd := 4.0
	var burrow_cd := BURROW_CD
	var burrow_t := 0.0
	var burrow_at := Vector2.ZERO
	var clone_on := false
	var clone_t := 0.0
	var clone_hits := 0
	var clone_mark := 0.0
	var dream_cd := 0.0
	var dream_t := 0.0
	var dream_dodged := false
	var reverse_t := 0.0
	var lava_cd := 0.0
	var lava_warn := 0.0
	var lava_t := 0.0
	var lava_tick := 0.0
	var copies: Array = []
	var last_cds: Array = [0.0, 0.0, 0.0, 0.0]
	var broken := [false, false, false, false]
	var sector_warn := -1
	var sector_warn_t := 0.0
	var sector_t := 0.0
	var sector_mark := 0.0
	var fall_t := 0.0
	var drain_cd := 0.0
	var chan_t := 0.0
	var el_cd := 0.0
	var el_next := ""
	var shard := false
	var lamps: Array = []
	var stones: Array = []
	var gate_said := false
	## Thiên Đạo Hư Ảnh
	var ha_mechs: Array = []
	var ha_t := {}
	var ha_phase := 0
	## Hợp nhất
	var force := 0.0
	var godform_t := 0.0


static func ensure(w) -> void:
	var q: Dictionary = w.profile.quest
	for k in ["ch9", "kills9", "souls9"]:
		if not q.has(k):
			q[k] = 0
	if int(q.ch9) == 0 and int(q.get("ch8", 0)) >= Story.DONE8:
		q.ch9 = S_TALK


static func step(w) -> int:
	ensure(w)
	return int(w.profile.quest.ch9)


static func chapter_done(w) -> bool:
	return step(w) >= Story.DONE9


static func in_region(w) -> bool:
	return int(w.map.get("region", 1)) == 9 and not w.in_cave()


static func ending(w) -> String:
	return str(w.profile.ending)


# ================================================================ tầng (C9-02…12)


## Tầng toàn cục 1…9 của một điểm trên map vùng 9 (0 nếu không ở vùng 9).
static func floor_of(w, pos: Vector2) -> int:
	if int(w.map.get("region", 1)) != 9 or w.in_cave():
		return 0
	var doors: Array = w.map.get("doors9", [])
	var base: int = (MAPS.find(w.map_id)) * 3
	var local := 0
	for d in doors:
		if pos.x >= float(d.x):
			local += 1
	return base + local + 1


static func door_open(w, f: int) -> bool:
	return f in w.profile.floors9


static func floor_element(w, f: int) -> String:
	return str(w.ch9.floor_el.get(f, ""))


## C9-10: bước vào tầng → rút hệ mới (không trùng lần trước), quái trong tầng đổi theo.
static func _enter_floor(w, f: int) -> void:
	var st = w.ch9
	st.cur_floor = f
	if f <= 0:
		return
	var pool: Array = ELEMENTS.filter(func(x): return x != str(st.last_el.get(f, "")))
	var el: String = pool[st.rng.randi() % pool.size()]
	st.floor_el[f] = el
	st.last_el[f] = el
	for e in w.enemies:
		if not e.dead and _floor_bound(e) and floor_of(w, e.pos) == f:
			e.el_override = el
	var counter := ""
	for a in Monsters.COUNTERS:
		if Monsters.COUNTERS[a] == el:
			counter = a
	w._text(w.player.pos + Vector2(0, -60), "Tầng %d · %s" % [f, Monsters.ELEMENT_NAMES[el]], Color(Monsters.ELEMENT_HEX[el]), true)
	if counter != "":
		w._message("Tầng %d · hệ %s — khắc bằng %s (Ấn Hệ trên bệ đá)." % [f, Monsters.ELEMENT_NAMES[el], Monsters.ELEMENT_NAMES[counter]], "info")


## Quái mang hệ tầng (trừ Ma Tôn, phân thân, Hư Ảnh và Ngũ Hành Sứ Giả — có hệ riêng).
static func _floor_bound(e) -> bool:
	return not (e.kind in ["ma-ton", "ma-ton-ao", "thien-dao-hu-anh"]) and not (e.kind == "tan-hon" and e.elite)


static func _tick_floors(w, dt: float) -> void:
	var st = w.ch9
	var p = w.player
	var f := floor_of(w, p.pos)
	# Cửa Tầng đóng: không qua ranh giới sang tầng kế
	var doors: Array = w.map.get("doors9", [])
	var base: int = MAPS.find(w.map_id) * 3
	for i in doors.size():
		var dx: float = float(doors[i].x)
		if not door_open(w, base + i + 1) and p.pos.x > dx - 6.0 and p.pos.x < dx + 120.0:
			p.pos.x = dx - DOOR_PUSH
			w.move_target = Vector2.INF
			st.door_msg -= dt
			if st.door_msg <= 0.0:
				st.door_msg = 4.0
				w._force_say("floor9_locked")
	f = floor_of(w, p.pos)
	if f != st.cur_floor:
		_enter_floor(w, f)
	# Ấn Hệ
	var seals: Array = w.map.get("seals9", [])
	for i in seals.size():
		var sf: int = base + i + 1
		st.seal_cd[sf] = float(st.seal_cd.get(sf, 0.0)) - dt
		if float(st.seal_cd[sf]) <= 0.0 and p.pos.distance_to(seals[i]) <= SEAL_PICK_R + w.PLAYER_RADIUS:
			st.seal_cd[sf] = SEAL_RESPAWN
			st.seal_t = SEAL_TIME_NGU_HANH if str(w.profile.talent) == "ngu-hanh" else SEAL_TIME
			w._blast(seals[i], 50.0, Color("#fff0b0"))
			w._text(p.pos + Vector2(0, -50), "Ấn Hệ! Khắc hệ tầng %d giây" % roundi(st.seal_t), Color("#fff0b0"), true)
	# C9-12: tầng càng cao quái càng đông
	if w.field_spawn and f > 0:
		st.density_t -= dt
		if st.density_t <= 0.0:
			st.density_t = DENSITY_EVERY
			var n := 0
			for e in w.enemies:
				if not e.dead and e.role == "field":
					n += 1
			if n < mini(40, roundi(w.field_mob_cap() * (1.0 + DENSITY_STEP * f))) and n >= w.field_mob_cap():
				w._spawn_field_mob()


## Ấn Hệ hiển thị cho từng bệ: giây còn lại tới khi hồi (≤ 0 = sẵn sàng).
static func seal_ready(w, i: int) -> bool:
	return float(w.ch9.seal_cd.get(MAPS.find(w.map_id) * 3 + i + 1, 0.0)) <= 0.0


## Người chơi đang khắc hệ con quái này? (Ngũ Hành Linh Căn, kỹ năng hệ, Âm Dương, Ấn Hệ, Mặt Nạ, Thần Hoá)
static func player_counters(w, e) -> bool:
	var st = w.ch9
	var el: String = w.el_of(e)
	if el == "" or st.nocounter_t > 0.0:
		return false
	if st.seal_t > 0.0 or mask_on(w) or st.godform_t > 0.0:
		return true
	if w.element_bonus(e) > 0.0:
		return true
	var sid: String = str(w.skill_ctx)
	if sid != "":
		var sk_el: String = w.Skills2.element_of(w, sid)
		if sk_el != "" and Monsters.counters(sk_el, el):
			return true
		if w.Skills2.variant(w, sid, 1) == "amduong":
			return true
	return false


static func mask_on(w) -> bool:
	return w.has_unique(MASK) and w.ch9.mask_t > MASK_EVERY - MASK_TIME


# ================================================================ nạp map, khung hình


static func on_load(w) -> void:
	ensure(w)
	var st = w.ch9
	st.rng.seed = hash("ch9:" + str(w.map_id) + ":" + str(w.profile.name))
	st.cur_floor = 0
	st.marks = []
	st.intro_t = 0.0
	st.clone_on = false
	st.burrow_t = 0.0
	st.reverse_t = 0.0
	st.lava_t = 0.0
	st.lava_warn = 0.0
	st.copies = []
	st.broken = [false, false, false, false]
	st.sector_warn = -1
	st.chan_t = 0.0
	st.shard = false
	st.gate_said = false
	st.ha_mechs = []
	st.ha_t = {}
	st.ha_phase = 0
	st.lamps = []
	st.stones = []
	if not in_region(w):
		return
	var m: Dictionary = w.map
	if m.arena != null:
		for i in 3:
			st.lamps.append({"pos": w.arena_pos + Vector2.from_angle(PI / 6.0 + i * TAU / 3.0) * w.arena_r * 0.45, "lit": true})
		for i in 5:
			st.stones.append(w.arena_pos + Vector2.from_angle(i * TAU / 5.0) * w.arena_r * 0.6)
	# C9-03: Thủ Tầng cho các Cửa Tầng chưa mở
	var base: int = MAPS.find(w.map_id) * 3
	var gs: Array = m.get("guards9", [])
	for i in gs.size():
		var f: int = base + i + 1
		if door_open(w, f):
			continue
		var lv: int = w.level_at(float(gs[i].x))
		var kinds: Array = ["thien-binh", "tan-hon"] if f == 9 else (["thien-binh"] if f % 2 == 1 else ["tan-hon"])
		for k in kinds.size():
			var g = w.spawn_enemy(kinds[k], lv, gs[i] + Vector2(0, 60.0 * k), {"role": "pack", "elite": true})
			g.set_meta("guard9", f)
			g.name = "Thủ Tầng · " + str(g.name)
	if w.map_id == "9-1" and step(w) == S_TALK:
		w.say("r9_arrive")


static func tick(w, dt: float) -> void:
	ensure(w)
	var st = w.ch9
	st.seal_t -= dt
	st.nocounter_t -= dt
	st.boost_t -= dt
	st.miss_text_t -= dt
	st.reverse_t -= dt
	if w.has_unique(MASK):
		st.mask_t = fposmod(st.mask_t + dt, MASK_EVERY)
	_tick_godform(w, dt)
	if not in_region(w):
		return
	_tick_marks(w, dt)
	if w.player.dead_timer <= 0.0:
		_tick_floors(w, dt)
	_tick_mobs(w, dt)
	_tick_boss(w, dt)
	_tick_hu_anh(w, dt)


static func _tick_godform(w, dt: float) -> void:
	var st = w.ch9
	if st.godform_t > 0.0:
		st.godform_t -= dt
		if st.godform_t <= 0.0:
			w._refresh_stats()


# ================================================================ quái vùng 9 (C9-20…25)


static func after_spawn(w, e) -> void:
	if not in_region(w):
		return
	if _floor_bound(e):
		e.el_override = floor_element(w, floor_of(w, e.pos))
	if e.kind == "tan-hon" and not e.elite:
		var t: Dictionary = Talents.LIST[w.ch9.rng.randi() % Talents.LIST.size()]
		e.set_meta("talent9", str(t.id))
		e.set_meta("group9", str(t.group))
		e.set_meta("soul_t", 4.0)
		match str(t.group):
			"combat":
				e.atk *= 1.3
				e.speed *= 1.2
			"explore", "economy", "craft", "territory":
				e.speed *= 1.25
	if e.kind == "tan-hon" and e.elite:
		e.el_override = ELEMENTS[w.ch9.rng.randi() % ELEMENTS.size()]
		e.set_meta("swap_t", SWAP_EVERY)


static func talent_name(e) -> String:
	if not e.has_meta("talent9"):
		return ""
	return str(Talents.get_talent(str(e.get_meta("talent9"))).get("name", ""))


## Tàn Hồn theo nhóm Thiên phú (C9-21), Ngũ Hành Sứ Giả đổi hệ (C9-25).
static func _tick_mobs(w, dt: float) -> void:
	var p = w.player
	for e in w.enemies:
		if e.dead:
			continue
		if e.kind == "tan-hon" and e.elite:
			var s: float = float(e.get_meta("swap_t", SWAP_EVERY)) - dt
			if s <= SWAP_WARN and not e.has_meta("swap_next"):
				var pool: Array = ELEMENTS.filter(func(x): return x != w.el_of(e))
				e.set_meta("swap_next", pool[w.ch9.rng.randi() % pool.size()])
			if s <= 0.0:
				e.el_override = str(e.get_meta("swap_next", "kim"))
				e.remove_meta("swap_next")
				s = SWAP_EVERY
				w._text(e.pos + Vector2(0, -e.radius - 24), "Hệ %s" % Monsters.ELEMENT_NAMES[e.el_override], Color(Monsters.ELEMENT_HEX[e.el_override]), false)
			e.set_meta("swap_t", s)
			continue
		if e.kind != "tan-hon" or e.state == "idle" or e.state == "stunned":
			continue
		var t: float = float(e.get_meta("soul_t", 0.0)) - dt
		if t > 0.0:
			e.set_meta("soul_t", t)
			continue
		match str(e.get_meta("group9", "")):
			"magic", "control":
				e.set_meta("soul_t", SOUL_SLOW_EVERY)
				if e.pos.distance_to(p.pos) <= 300.0 and p.dash_time <= 0.0:
					p.slow_timer = maxf(p.slow_timer, 2.0)
					w._text(p.pos + Vector2(0, -40), "Chậm!", Color("#b36bff"), false)
			"summon":
				e.set_meta("soul_t", SOUL_SUMMON_EVERY)
				for k in 2:
					var m = w.spawn_enemy("anh-bong", e.level, e.pos + Vector2.from_angle(k * PI + 0.4) * 50.0, {"role": "summon"})
					m.max_hp = e.max_hp * 0.3
					m.hp = m.max_hp
					m.state = "chase"
			"special":
				e.set_meta("soul_t", SOUL_COPY_EVERY)
				w._enemy_shot(e, (p.pos - e.pos).angle(), 1.5, 360.0)
				w._text(e.pos + Vector2(0, -e.radius - 20), "Đạo Tặc!", Color("#ffd23c"), false)
			_:
				e.set_meta("soul_t", 999.0)


static func chase(w, e, d: float, dt: float) -> bool:
	match e.kind:
		"thien-binh":
			e.set_meta("lance_cd", float(e.get_meta("lance_cd", 2.0)) - dt)
			if float(e.get_meta("lance_cd")) <= 0.0 and d <= LANCE_LEN + e.radius + 30.0:
				e.set_meta("lance_cd", LANCE_CD)
				w._begin_attack(e, "elemlance", 0.8)
				return true
		"thien-ma":
			e.set_meta("gallop_cd", float(e.get_meta("gallop_cd", 2.0)) - dt)
			if float(e.get_meta("gallop_cd")) <= 0.0 and d <= GALLOP_LEN + 40.0 and d > 60.0:
				e.set_meta("gallop_cd", GALLOP_CD)
				w._begin_attack(e, "gallop", 0.6)
				return true
		"linh-thu-ngu-hanh":
			e.set_meta("roar_cd", float(e.get_meta("roar_cd", 3.0)) - dt)
			if float(e.get_meta("roar_cd")) <= 0.0 and d <= ROAR_R + e.radius:
				e.set_meta("roar_cd", ROAR_CD)
				w._begin_attack(e, "roar9", 0.9)
				return true
	return false


static func perform(w, e) -> bool:
	var p = w.player
	match e.attack_kind:
		"elemlance":
			var to: Vector2 = e.pos + (e.target - e.pos).normalized() * (LANCE_LEN + e.radius)
			if Geometry2D.get_closest_point_to_segment(p.pos, e.pos, to).distance_to(p.pos) <= LANCE_HALF + w.PLAYER_RADIUS:
				w._damage_player(e.atk, LANCE_MUL)
		"gallop":
			var from: Vector2 = e.pos
			var dest: Vector2 = (e.pos + (e.target - e.pos).normalized() * GALLOP_LEN).clamp(Vector2.ONE * 40.0, w.world_size - Vector2.ONE * 40.0)
			e.pos = dest
			if Geometry2D.get_closest_point_to_segment(p.pos, from, dest).distance_to(p.pos) <= e.radius + w.PLAYER_RADIUS:
				w._damage_player(e.atk, GALLOP_MUL)
		"roar9":
			w._blast(e.pos, ROAR_R, Color(Monsters.ELEMENT_HEX.get(w.el_of(e), "#ffffff")))
			if e.pos.distance_to(p.pos) <= ROAR_R + w.PLAYER_RADIUS and w._damage_player(e.atk, ROAR_MUL):
				w.ch9.nocounter_t = NOCOUNTER_TIME
				w._text(p.pos + Vector2(0, -50), "Mất khắc hệ 5 giây", Color("#c8c0a0"), false)
		"volley1":
			w._enemy_shot(e, (e.target - e.pos).angle(), 1.0, 340.0)
		"pounce9":
			var dest2: Vector2 = e.pos + (e.target - e.pos).limit_length(POUNCE_REACH)
			e.pos = w._clamp_to_arena(dest2, e.radius)
			w._blast(e.pos, POUNCE_R, Color("#6a5a92"))
			if e.pos.distance_to(p.pos) <= POUNCE_R + w.PLAYER_RADIUS:
				w._damage_player(e.atk, POUNCE_MUL)
		"staff9":
			if e.pos.distance_to(p.pos) <= e.radius + e.attack_range + w.PLAYER_RADIUS + 10.0:
				w._damage_player(e.atk, STAFF_MUL)
		"dash9":
			var from2: Vector2 = e.pos
			var dest3: Vector2 = w._clamp_to_arena(e.pos + (e.target - e.pos).normalized() * 220.0, e.radius)
			e.pos = dest3
			if Geometry2D.get_closest_point_to_segment(p.pos, from2, dest3).distance_to(p.pos) <= e.radius + w.PLAYER_RADIUS:
				w._damage_player(e.atk, 1.3)
		"spin9":
			w._blast(e.pos, 90.0, Color("#6a5a92"))
			if e.pos.distance_to(p.pos) <= 90.0 + w.PLAYER_RADIUS:
				w._damage_player(e.atk, 1.2)
		_:
			return false
	return true


static func elite_skill(w, e, kind: String) -> bool:
	if kind != "thienphat":
		return false
	e.skill_cd = THUNDER_CD
	var p = w.player
	for i in THUNDER_N:
		add_mark(w, p.pos + Vector2.from_angle(i * TAU / THUNDER_N + w.ch9.rng.randf()) * THUNDER_RING, THUNDER_R, THUNDER_WARN, e.atk, THUNDER_MUL)
	w._text(e.pos + Vector2(0, -e.radius - 24), "Thiên phạt!", Color("#fff0b0"), true)
	return true


static func add_mark(w, pos: Vector2, r: float, t: float, atk: float, mul: float, opts := {}) -> void:
	var mk := {"pos": pos, "r": r, "t": t, "total": t, "atk": atk, "mul": mul}
	mk.merge(opts)
	w.ch9.marks.append(mk)


static func _tick_marks(w, dt: float) -> void:
	var keep: Array = []
	for mk in w.ch9.marks:
		mk.t -= dt
		if mk.t > 0.0:
			keep.append(mk)
			continue
		w._blast(mk.pos, mk.r, Color(str(mk.get("color", "#fff0b0"))))
		if mk.has("boss_to"):
			var b = _boss(w)
			if b != null:
				b.pos = mk.pos
		if w.player.pos.distance_to(mk.pos) <= mk.r + w.PLAYER_RADIUS:
			if mk.get("stop", false):
				if w.player.dodge_time <= 0.0:
					w.player.stun_timer = maxf(w.player.stun_timer, 1.5)
					w._text(w.player.pos + Vector2(0, -50), "Thời gian ngưng đọng!", Color("#b36bff"), true)
			else:
				w._damage_player(mk.atk, mk.mul)
	w.ch9.marks = keep


static func on_kill(w, e) -> void:
	ensure(w)
	var q: Dictionary = w.profile.quest
	var p = w.profile
	if in_region(w) and step(w) == S_KILLS and e.role in ["field", "pack", "nestMinion", "nestGuard"]:
		pass  # NV-B (docs/41): bước này nay theo mục tiêu riêng — core/main_variants.gd ghi tiến độ
	if e.kind == "tan-hon" and not e.elite and step(w) == S_SOULS:
		q.souls9 = int(q.souls9) + 1
		w._text(e.pos + Vector2(0, -40), "Ánh Hồn %d/9" % mini(9, int(q.souls9)), Color("#bcd8f0"), true)
	if e.has_meta("guard9"):
		var f: int = int(e.get_meta("guard9"))
		var left := 0
		for o in w.enemies:
			if o != e and not o.dead and o.has_meta("guard9") and int(o.get_meta("guard9")) == f:
				left += 1
		if left == 0 and not (f in p.floors9):
			p.floors9.append(f)
			w._message("Cửa Tầng %d mở!" % f, "good")
			w._force_say("floor9_%d" % f)
	if e.kind == "ma-ton":
		var first: bool = not bool(p.bosses.get("ma-ton", false)) and int(q.get("mask9", 0)) == 0
		if first:
			q["mask9"] = 1
			w._drop_item(e.pos + Vector2(-30, 0), 100, "orange", MASK)
		for m in w.enemies:
			if m.kind == "ma-ton-ao":
				m.dead = true
		_reset_boss(w)
	if e.kind == "thien-dao-hu-anh":
		p.evo_essence = int(p.evo_essence) + 2
		p.essence = int(p.essence) + 5
		var keys: Array = ItemData.UNIQUES.keys()
		w._drop_item(e.pos + Vector2(30, 20), 100, "orange", str(keys[w.ch9.rng.randi() % keys.size()]))
		w._message("Thiên Đạo Hư Ảnh: +3 Tinh Hoa Tiến Hoá, +10 Thiên Phú Tinh Hoa (tính cả phần boss hiếm), 1 đồ Cam ngẫu nhiên.", "good")


## Phân thân Ma Tôn tan khi trúng đòn (không phạt, không EXP/đồ — F1).
static func vanish(w, e) -> bool:
	if e.kind == "ma-ton-ao":
		w._blast(e.pos, 40.0, Color("#6a5a92"))
		return true
	return false


static func is_hidden(e) -> bool:
	return e.has_meta("hide9") and bool(e.get_meta("hide9"))


## Thiên Đạo Lực (Hợp nhất): +1 mỗi 2% HP quái mất.
static func on_player_hit(w, e) -> void:
	if ending(w) != "hop-nhat":
		return
	var st = w.ch9
	var last: float = float(e.get_meta("hp9", e.max_hp))
	var lost: float = maxf(0.0, last - e.hp)
	e.set_meta("hp9", e.hp)
	if st.godform_t > 0.0 or lost <= 0.0:
		return
	st.force = minf(DIVINE_FORCE_MAX, st.force + lost / maxf(1.0, e.max_hp) * 50.0)
	if st.force >= DIVINE_FORCE_MAX:
		st.force = 0.0
		st.godform_t = GODFORM_TIME
		w._refresh_stats()
		w._text(w.player.pos + Vector2(0, -56), "THẦN HOÁ!", Color("#fff0b0"), true)


static func hit_mult(w, e, _crit: bool) -> float:
	var st = w.ch9
	var k := 1.0
	if st.boost_t > 0.0:
		k *= BOOST_MUL
	if st.godform_t > 0.0:
		k *= GODFORM_ATK
	if st.nocounter_t > 0.0 and w.element_bonus(e) > 0.0:
		k /= 1.0 + w.element_bonus(e)
	var el: String = w.el_of(e)
	if el != "" and st.nocounter_t <= 0.0 and w.element_bonus(e) <= 0.0:
		if (st.seal_t > 0.0 and in_region(w)) or mask_on(w) or st.godform_t > 0.0:
			k *= 1.0 + COUNTER
	if int(w.equip_set_count(THIEN_DAO)) >= 4 and player_counters(w, e):
		k *= SET4_COUNTER
	return k


## Ngũ Hành Sứ Giả: chỉ hệ khắc nhận đủ (Q90: hệ khác 25%); Ma Tôn chuyển cảnh / độn thổ; phân thân đếm đòn vào bản thật.
static func adjust_damage(w, e, dmg: int, by_player: bool) -> int:
	var st = w.ch9
	if e.kind == "tan-hon" and e.elite and not player_counters(w, e):
		return maxi(1, roundi(dmg * ENVOY_TAKEN))
	if e.kind == "ma-ton":
		if st.intro_t > 0.0 or st.burrow_t > 0.0:
			_miss(w, e, "Miễn sát thương")
			return 0
		if st.clone_on and by_player:
			st.clone_hits += 1
	return dmg


static func _miss(w, e, text: String) -> void:
	if w.ch9.miss_text_t <= 0.0:
		w.ch9.miss_text_t = 0.4
		w._text(e.pos + Vector2(0, -e.radius - 20), text, Color("#c8c0d8"), false)


## C9-30b Giấc mơ: đảo ngược điều khiển 4 giây.
static func input_filter(w, input: Dictionary) -> Dictionary:
	if w.ch9.reverse_t <= 0.0:
		return input
	var out := input.duplicate()
	out.move = -Vector2(input.get("move", Vector2.ZERO))
	return out


static func dodge_hit(w) -> bool:
	return w.ch9.fall_t > 0.0


static func derive_bonus(w, bonus: Dictionary) -> void:
	if w.ch9.godform_t > 0.0:
		bonus["atk_speed_pct"] = float(bonus.get("atk_speed_pct", 0.0)) + GODFORM_ASPD


## Hiến tế: Tinh Quang Thủ Hộ +20% hiệu lực Thiên phú (C9-46).
static func talent_mult(w) -> float:
	return SACRIFICE_TALENT if ending(w) == "hien-te" else 1.0


## Bộ Thiên Đạo 6 món: kỹ năng L hồi nhanh 30%.
static func talent_cd_mult(w) -> float:
	return 0.7 if int(w.equip_set_count(THIEN_DAO)) >= 6 else 1.0


## C9-32 Vô Diện (Đạo Tặc): dùng ngẫu nhiên 1 kỹ năng boss đã sao chép, ×1,5 sát thương.
static func copy_skill(w, id: String) -> bool:
	if id != "vo_dien":
		return false
	var pool: Array = Array(w.profile.copied_skills).filter(func(x): return x != "vo_dien")
	if pool.size() < 2:
		w._message("Vô Diện cần ít nhất 2 kỹ năng boss đã sao chép.", "info")
		return true
	var pick: String = pool[w.ch9.rng.randi() % pool.size()]
	w.ch9.boost_t = 0.8
	w._text(w.player.pos + Vector2(0, -56), "Vô Diện → %s" % str(w.COPY_NAMES.get(pick, pick)), Color("#fff0b0"), true)
	match pick:
		"pounce":
			w._leap()
		"clone":
			for k in 2:
				w._add_decoy(w.player.pos + Vector2.from_angle(k * PI + 0.6) * 60.0, 6.0)
		_:
			w.Chapters.copy_skill(w, pick)
	return true


# ================================================================ Ma Tôn Vô Diện (C9-30)


static func _boss(w):
	var b = w.boss()
	return b if b != null and b.kind == "ma-ton" else null


static func boss_phase_two(_w, e) -> bool:
	return e.kind == "ma-ton"


static func _reset_boss(w) -> void:
	var st = w.ch9
	st.intro_t = 0.0
	st.clone_on = false
	st.burrow_t = 0.0
	st.reverse_t = 0.0
	st.lava_t = 0.0
	st.lava_warn = 0.0
	st.chan_t = 0.0
	st.copies = []
	st.broken = [false, false, false, false]
	st.sector_warn = -1
	st.shard = false
	for l in st.lamps:
		l.lit = true


static func update_enemy(w, e, dt: float) -> bool:
	if e.kind == "ma-ton-ao":
		e.state = "idle"
		return true
	if e.kind != "ma-ton" or e.dead or e.state == "stunned":
		return false
	var st = w.ch9
	var p = w.player
	_phase(w, e)
	if st.intro_t > 0.0 or st.burrow_t > 0.0:
		e.state = "chase"
		return true
	if st.chan_t > 0.0:
		st.chan_t -= dt
		if st.chan_t <= 0.0:
			_drain(w)
		return true
	if st.dream_t > 0.0:
		st.dream_t -= dt
		if p.dodge_time > 0.0:
			st.dream_dodged = true
		if st.dream_t <= 0.0:
			if st.dream_dodged:
				w._text(p.pos + Vector2(0, -50), "Né được Giấc mơ!", Color("#9de0e6"), false)
			else:
				st.reverse_t = DREAM_TIME
				w._text(p.pos + Vector2(0, -50), "Giấc mơ! Điều khiển đảo ngược", Color("#b46bff"), true)
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
	st.pounce_cd -= dt
	st.burrow_cd -= dt
	st.dream_cd -= dt
	st.drain_cd -= dt
	var d: float = e.pos.distance_to(p.pos)
	match e.phase:
		1:
			if st.burrow_cd <= 0.0 and not st.clone_on:
				st.burrow_cd = BURROW_CD
				st.burrow_t = BURROW_TIME
				e.set_meta("hide9", true)
				add_mark(w, p.pos, BURROW_R, BURROW_TIME, e.atk, BURROW_MUL, {"color": "#a87a44", "boss_to": true})
				w._text(e.pos + Vector2(0, -60), "Độn thổ!", Color("#c9a45c"), true)
				return true
			if st.pounce_cd <= 0.0 and d > 120.0:
				st.pounce_cd = POUNCE_CD
				w._begin_attack(e, "pounce9", POUNCE_WINDUP)
				return true
		2:
			if st.dream_cd <= 0.0:
				st.dream_cd = DREAM_CD
				st.dream_t = DREAM_WINDUP
				st.dream_dodged = false
				w._text(e.pos + Vector2(0, -60), "Giấc mơ…", Color("#b46bff"), true)
				return true
		_:
			if not st.shard and st.drain_cd <= 0.0:
				st.drain_cd = DRAIN_EVERY
				st.chan_t = DRAIN_CHANNEL
				w._text(e.pos + Vector2(0, -60), "Hút Thiên phú!", Color("#d080ff"), true)
				return true
	if d <= e.radius + e.attack_range + w.PLAYER_RADIUS:
		w._begin_attack(e, "staff9", 0.6)
		return true
	w._move_toward(e, p.pos, e.speed, dt)
	return true


static func _phase(w, e) -> void:
	var st = w.ch9
	if e.phase == 1 and e.hp <= e.max_hp * 0.66:
		e.phase = 2
		_end_clones(w, e)
		st.intro_t = PHASE_INTRO
		st.dream_cd = PHASE_INTRO + 3.0
		st.lava_cd = PHASE_INTRO + 15.0
		w._text(e.pos + Vector2(0, -80), "Ký ức chương 4–6", Color("#b46bff"), true)
		w._message("Ma Tôn dùng Giấc mơ (né lăn khi hắn vung), Dung nham (đứng trên Đá Nổi) và sao chép kỹ năng của ngươi.", "bad")
	elif e.phase == 2 and e.hp <= e.max_hp * 0.33:
		e.phase = 3
		st.intro_t = PHASE_INTRO
		st.lava_t = 0.0
		st.lava_warn = 0.0
		st.reverse_t = 0.0
		st.drain_cd = PHASE_INTRO + 2.0
		st.el_cd = PHASE_INTRO
		st.sector_t = 0.0
		st.sector_mark = e.hp
		w._text(e.pos + Vector2(0, -80), "VÔ DIỆN", Color("#fff0b0"), true)
		w._message("Vô Diện: đấu trường vỡ dần, Hút Thiên phú (3 Đèn Tinh Quang chặn được), đổi hệ mỗi 10 giây.", "bad")
	elif e.phase == 3 and not st.shard and e.hp <= e.max_hp * 0.10:
		st.shard = true
		st.intro_t = SHARD_INTRO
		st.chan_t = 0.0
		w._force_say("ma_ton_shard")


static func _end_clones(w, e) -> void:
	var st = w.ch9
	st.clone_on = false
	e.set_meta("hide9", false)
	for m in w.enemies:
		if m.kind == "ma-ton-ao" and not m.dead:
			m.dead = true


## Hút Thiên phú (C9-30c): 3 Đèn Tinh Quang của đấu trường chặn, mỗi đèn 1 lần — dùng lại Ch8.drain_talent.
static func _drain(w) -> void:
	var st = w.ch9
	var p = w.player
	for l in st.lamps:
		if l.lit and p.pos.distance_to(l.pos) <= Ch8.LAMP_R + w.PLAYER_RADIUS:
			l.lit = false
			w._blast(l.pos, Ch8.LAMP_R, Color("#fff2b0"))
			w._text(p.pos + Vector2(0, -50), "Đèn Tinh Quang chặn!", Color("#fff2b0"), true)
			return
	if p.dead_timer <= 0.0:
		Ch8.drain_talent(w, Ch8.DRAIN_TIME_RING if w.has_unique(Ch8.AN_HU_VO) else Ch8.DRAIN_TIME)


static func _tick_boss(w, dt: float) -> void:
	var st = w.ch9
	var p = w.player
	st.fall_t -= dt
	var b = _boss(w)
	if b == null:
		if st.clone_on or st.intro_t > 0.0 or st.lava_t > 0.0:
			_reset_boss(w)
		st.gate_said = false
		return
	if not st.gate_said:
		st.gate_said = true
		w._force_say("ma_ton_gate")
	_phase(w, b)
	if st.intro_t > 0.0:
		st.intro_t -= dt
		if b.state == "stunned":
			b.state = "chase"
			b.broken = false
	if st.burrow_t > 0.0:
		st.burrow_t -= dt
		if st.burrow_t <= 0.0:
			b.set_meta("hide9", false)
	if st.intro_t > 0.0:
		return
	match b.phase:
		1:
			_tick_clones(w, b, dt)
		2:
			_tick_lava(w, b, dt)
			_tick_copy(w, b, dt)
		_:
			_tick_sectors(w, b, dt)
			_tick_element(w, b, dt)
	if st.shard:
		var c6 = w.ch6
		c6.dark = minf(100.0, c6.dark + DARK_RATE * dt)
		if c6.dark >= 100.0:
			c6.dark = 0.0
			c6.ascend_t = 6.0
			w._text(p.pos + Vector2(0, -56), "Ám Hoá! +20% Tấn công", Color("#b36bff"), true)


## GĐ1 Phân thân: mỗi khi mất 12% HP tách 3 bản (1 thật); mọi bản không bị tự ngắm; hết khi bản thật trúng 3 đòn hoặc 8 giây.
static func _tick_clones(w, b, dt: float) -> void:
	var st = w.ch9
	if st.clone_on:
		st.clone_t -= dt
		if st.clone_hits >= CLONE_HITS or st.clone_t <= 0.0:
			_end_clones(w, b)
		return
	if st.clone_mark <= 0.0 or st.clone_mark > b.max_hp:
		st.clone_mark = b.max_hp
	if st.burrow_t > 0.0 or st.clone_mark - b.hp < b.max_hp * CLONE_HP:
		return
	st.clone_mark = b.hp
	st.clone_on = true
	st.clone_t = CLONE_TIME
	st.clone_hits = 0
	var slots: Array = []
	for i in 3:
		slots.append(w.arena_pos + Vector2.from_angle(i * TAU / 3.0 + st.rng.randf()) * w.arena_r * 0.5)
	var real: int = st.rng.randi() % 3
	for i in 3:
		if i == real:
			b.pos = slots[i]
			b.set_meta("hide9", true)
			continue
		var c = w.spawn_enemy("ma-ton-ao", b.level, slots[i], {"role": "bossClone"})
		c.max_hp = 1.0
		c.hp = 1.0
		c.set_meta("hide9", true)
	w._text(b.pos + Vector2(0, -70), "Phân thân!", Color("#b36bff"), true)
	w._message("Phân thân — chỉ bản thật có bóng. Đánh trúng bản thật 3 lần để phá.", "bad")


## GĐ2 Dung nham dâng: báo 3 giây, ngập 5 giây; ngoài 5 Đá Nổi mất 8% HP mỗi giây; Ma Tôn vẫn đánh được (D41).
static func _tick_lava(w, _b, dt: float) -> void:
	var st = w.ch9
	var p = w.player
	st.lava_cd -= dt
	if st.lava_warn > 0.0:
		st.lava_warn -= dt
		if st.lava_warn <= 0.0:
			st.lava_t = LAVA_TIME
			st.lava_tick = 0.0
		return
	if st.lava_t > 0.0:
		st.lava_t -= dt
		st.lava_tick += dt
		if st.lava_tick >= 1.0:
			st.lava_tick -= 1.0
			if not on_stone(w, p.pos) and p.dead_timer <= 0.0 and p.dash_time <= 0.0:
				p.hp = maxf(1.0, p.hp - float(w.stats.max_hp) * LAVA_HP)
				w._text(p.pos + Vector2(0, -30), "−8% HP (dung nham)", Color("#ff6a3c"), false)
		return
	if st.lava_cd <= 0.0:
		st.lava_cd = LAVA_CD
		st.lava_warn = LAVA_WARN
		w._text(w.arena_pos + Vector2(0, -w.arena_r * 0.8), "Dung nham dâng! Lên Đá Nổi!", Color("#ff6a3c"), true)


static func on_stone(w, pos: Vector2) -> bool:
	for s in w.ch9.stones:
		if pos.distance_to(s) <= STONE_R + 6.0:
			return true
	return false


## GĐ2 Sao chép (Bản Ngã): dùng lại kỹ năng người chơi vừa dùng sau 3 giây, theo nhóm của Ch6.MIRROR_OF.
static func _tick_copy(w, b, dt: float) -> void:
	var st = w.ch9
	var p = w.player
	for i in p.skill_cds.size():
		var cd: float = float(p.skill_cds[i])
		if i < st.last_cds.size():
			if cd > float(st.last_cds[i]) + 0.5:
				var sk = w.slot_skill(i)
				var id: String = str(sk.get("id", "")) if sk is Dictionary else ""
				st.copies.append({"id": id, "t": COPY_DELAY})
			st.last_cds[i] = cd
	for c in st.copies:
		c.t -= dt
	var due: Array = st.copies.filter(func(c): return c.t <= 0.0)
	st.copies = st.copies.filter(func(c): return c.t > 0.0)
	for c in due:
		var kind: String = str(Ch6.MIRROR_OF.get(str(c.id), "m_bolt"))
		match kind:
			"m_spin":
				if b.state != "windup":
					w._begin_attack(b, "spin9", 0.6)
			"m_dash":
				if b.state != "windup":
					w._begin_attack(b, "dash9", 0.6)
			"m_bolt":
				w._enemy_shot(b, (p.pos - b.pos).angle(), 1.0, 380.0)
			"m_rain", "m_meteor", "m_trap":
				add_mark(w, p.pos, 70.0, 1.0, b.atk, 1.4, {"color": "#6a3aa8"})
		w._text(b.pos + Vector2(0, -b.radius - 28), "Sao chép!", Color("#b36bff"), false)


## GĐ3 Chiến trường thu nhỏ (Cự Thần): một cung vành ngoài vỡ sau mỗi 8% HP hoặc 20 giây; rơi → mép lõi, −10% HP, Ma Tôn +3%.
static func _tick_sectors(w, b, dt: float) -> void:
	var st = w.ch9
	var p = w.player
	var off: Vector2 = p.pos - w.arena_pos
	if off.length() > CORE_R and st.broken[sector_of(off)] and st.fall_t <= 0.0 and p.dead_timer <= 0.0:
		st.fall_t = 1.0
		p.pos = w.arena_pos + off.normalized() * (CORE_R - 40.0)
		p.hp = maxf(1.0, p.hp - float(w.stats.max_hp) * FALL_HP)
		b.hp = minf(b.max_hp, b.hp + b.max_hp * FALL_HEAL)
		w._text(p.pos + Vector2(0, -40), "Rơi! −10% HP", Color("#ff5470"), true)
	if not (false in st.broken):
		return
	if st.sector_warn >= 0:
		st.sector_warn_t -= dt
		if st.sector_warn_t <= 0.0:
			st.broken[st.sector_warn] = true
			st.sector_warn = -1
		return
	st.sector_t += dt
	if st.sector_mark - b.hp >= b.max_hp * SECTOR_HP or st.sector_t >= SECTOR_TIME:
		st.sector_t = 0.0
		st.sector_mark = b.hp
		var pick := -1
		var best := INF
		for i in 4:
			if st.broken[i]:
				continue
			var mid: Vector2 = w.arena_pos + Vector2.from_angle((i + 0.5) * TAU / 4.0) * (CORE_R + 40.0)
			if mid.distance_to(p.pos) < best:
				best = mid.distance_to(p.pos)
				pick = i
		st.sector_warn = pick
		st.sector_warn_t = SECTOR_WARN
		w._text(w.arena_pos + Vector2(0, -CORE_R), "Vành Cổng nứt!", Color("#ff7a45"), true)


static func sector_of(off: Vector2) -> int:
	return clampi(int(fposmod(off.angle(), TAU) / (TAU / 4.0)), 0, 3)


## GĐ3 Vô Diện: đổi hệ mỗi 10 giây (báo 1 giây trước).
static func _tick_element(w, b, dt: float) -> void:
	var st = w.ch9
	st.el_cd -= dt
	if st.el_cd <= 1.0 and st.el_next == "":
		var pool: Array = ELEMENTS.filter(func(x): return x != w.el_of(b))
		st.el_next = pool[st.rng.randi() % pool.size()]
	if st.el_cd <= 0.0:
		st.el_cd = ELEMENT_EVERY
		b.el_override = st.el_next if st.el_next != "" else "kim"
		st.el_next = ""
		w._text(b.pos + Vector2(0, -80), "Hệ %s" % Monsters.ELEMENT_NAMES[b.el_override], Color(Monsters.ELEMENT_HEX[b.el_override]), true)


# ================================================================ Thiên Đạo Hư Ảnh (C9-33)


static func update_rare(_w, e, _dt: float) -> bool:
	return e.kind == "thien-dao-hu-anh"


static func _hu_anh(w):
	var r = w.rare_boss()
	return r if r != null and r.kind == "thien-dao-hu-anh" else null


static func _tick_hu_anh(w, dt: float) -> void:
	var st = w.ch9
	var h = _hu_anh(w)
	if h == null:
		st.ha_mechs = []
		st.ha_phase = 0
		return
	var want: int = 1 if h.hp > h.max_hp * 0.66 else (2 if h.hp > h.max_hp * 0.33 else 3)
	while st.ha_phase < want:
		st.ha_phase += 1
		var pool: Array = HA_MECHS.filter(func(x): return not (x in st.ha_mechs))
		var m: String = pool[st.rng.randi() % pool.size()]
		st.ha_mechs.append(m)
		st.ha_t[m] = 3.0
		w._text(h.pos + Vector2(0, -70), "Hư Ảnh: %s" % str(Talents.get_talent(m).get("name", m)), Color("#fff0b0"), true)
	for m in st.ha_mechs:
		st.ha_t[m] = float(st.ha_t.get(m, 0.0)) - dt
		if float(st.ha_t[m]) > 0.0:
			continue
		var pick: String = m
		if m == "dao-tac":
			var others: Array = HA_MECHS.filter(func(x): return x != "dao-tac" and x != "thien-menh")
			pick = others[st.rng.randi() % others.size()]
		st.ha_t[m] = _ha_action(w, h, pick)
		if m == "dao-tac":
			st.ha_t[m] = 12.0


## Một lượt cơ chế Hư Ảnh; trả về giây tới lượt sau.
static func _ha_action(w, h, m: String) -> float:
	var p = w.player
	match m:
		"ngu-hanh":
			var pool: Array = ELEMENTS.filter(func(x): return x != w.el_of(h))
			h.el_override = pool[w.ch9.rng.randi() % pool.size()]
			add_mark(w, h.pos, 60.0, 0.8, h.atk, 1.5, {"color": Monsters.ELEMENT_HEX[h.el_override]})
			return 6.0
		"thoi-gian-ngung-dong":
			add_mark(w, p.pos, 50.0, 1.0, h.atk, 0.0, {"color": "#b36bff", "stop": true})
			return 20.0
		"bay-dan":
			for k in 4:
				var s = w.spawn_enemy("anh-bong", h.level, h.pos + Vector2.from_angle(k * TAU / 4.0) * 70.0, {"role": "rareMinion"})
				s.max_hp = h.max_hp * 0.02
				s.hp = s.max_hp
				s.state = "chase"
			return 15.0
		"long-mach":
			var dir: Vector2 = (p.pos - h.pos).normalized()
			for k in 6:
				add_mark(w, h.pos + dir * (60.0 + k * 70.0), 40.0, 1.5, h.atk, 1.5, {"color": "#ffd86a"})
			return 25.0
	return 999.0


static func hu_anh_fog(w) -> bool:
	return "thien-menh" in w.ch9.ha_mechs and _hu_anh(w) != null


# ================================================================ nhiệm vụ chương 9 (C9-41)


static func quest(w) -> Dictionary:
	return Story.quest9(step(w))


static func quest_status(w) -> Array:
	var q := quest(w)
	if q.is_empty():
		return [0, 0]
	var qd: Dictionary = w.profile.quest
	match str(q.type):
		"kills9":
			return [mini(int(qd.kills9), int(q.need)), int(q.need)]
		"floors9":
			return [mini(w.profile.floors9.filter(func(f): return int(f) <= 5).size(), int(q.need)), int(q.need)]
		"souls9":
			return [mini(int(qd.souls9), int(q.need)), int(q.need)]
	return [0, int(q.need)]


static func check_quest(w) -> void:
	var q := quest(w)
	if q.is_empty():
		return
	var qd: Dictionary = w.profile.quest
	var done := false
	match str(q.type):
		"kills9":
			done = int(qd.kills9) >= int(q.need)
		"floors9":
			done = w.profile.floors9.filter(func(f): return int(f) <= 5).size() >= int(q.need)
		"souls9":
			done = int(qd.souls9) >= int(q.need)
		"explore9":
			done = 8 in w.profile.floors9 and w.map_id == "9-3" and w.explore_ratio("9-3") >= 0.4
		"boss9":
			done = w.is_boss_defeated("ma-ton")
		"ending9":
			done = ending(w) != ""
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
	var rt := Story.reward_text(r)
	w._message("Nhiệm vụ chương 9 hoàn thành: %s%s" % [q.title, (". Thưởng: " + rt) if rt != "" else ""], "good")
	var s := step(w)
	p.quest.ch9 = s + 1
	w._events.append({"type": "quest_done", "step": s, "chapter": 9})
	if r.has("exp"):
		w.add_exp(float(r.exp), false)
	match s:
		S_TALK:
			w.say("van9_kills")
		S_KILLS:
			w.say("van9_floors")
		S_FLOORS:
			w.say("van9_souls")
		S_SOULS:
			w.say("van9_seal")
		S_BOSS:
			w.say("ch9_choice")
			w._events.append({"type": "ending_choice"})
		S_ENDING:
			w._events.append({"type": "chapter_end", "chapter": 9})


## C9-44…46: chọn kết thúc (không đổi lại). id: "hop-nhat" | "hien-te".
static func choose_ending(w, id: String) -> Dictionary:
	var p = w.profile
	if ending(w) != "":
		return {"ok": false, "message": "Đã chọn kết thúc."}
	if not (id in ["hop-nhat", "hien-te"]) or step(w) != S_ENDING:
		return {"ok": false, "message": "Chưa tới lúc chọn."}
	p.ending = id
	# Thiên Đạo Hư Ảnh xuất hiện sau khi chọn kết thúc (RARE_BOSSES["9-3"].after = "ending9")
	p.bosses["ending9"] = true
	w.ch6.dark = 0.0
	w.ch6.ascend_t = 0.0
	if id == "hien-te":
		_clear_all_fog(w)
	w.say("end_" + id.replace("-", "_"))
	advance(w)
	w._refresh_stats()
	w._events.append({"type": "ending", "id": id})
	w.Chapters.after_exp(w)
	return {"ok": true, "message": "Hợp nhất" if id == "hop-nhat" else "Hiến tế"}


## Hiến tế (C9-46): sương bản đồ vùng 1–9 mở hết, mọi ô khai phá chưa mở lộ sự kiện (vẫn phải chiếm).
static func _clear_all_fog(w) -> void:
	var p = w.profile
	for id in Maps.MAPS:
		var f = Fog.new()
		f.setup(Maps.get_map(id).size)
		for i in f.cells.size():
			f.cells[i] = 1
		f.opened = f.cells.size()
		p.fog[id] = f.encode()
	for i in w.fog.cells.size():
		w.fog.cells[i] = 1
	w.fog.opened = w.fog.cells.size()
	w.fog.version += 1
	for rg in Explore.region_grids(p):
		for t in rg[1]:
			if str(t.status) == "fog":
				t.status = "revealed"


static func talk(w, npc_id: String) -> String:
	var s := step(w)
	match npc_id:
		"van-hac-9":
			if s == S_TALK:
				w._force_say("van9_meet")
				advance(w)
				return ""
			if s == S_ENDING and ending(w) == "":
				w._force_say("ch9_choice")
				w._events.append({"type": "ending_choice"})
				return ""
			if ending(w) != "":
				w._force_say("ch9_done")
				return "divine"
			w._force_say("van9_idle")
			return ""
		"tuyet-nga-9":
			w._force_say("nga9_shop")
			return "shop"
		"lam-nhi-9":
			w._force_say("lam9_idle")
			return ""
	return ""


static func npc_visible(_w, _npc_id: String) -> bool:
	return true


## C9-01: điều kiện mở vùng 9.
static func region_blockers(w) -> Array:
	var p = w.profile
	var out: Array = []
	if str(p.job3) == "":
		out.append("Chuyển chức lần 3")
	if not w.is_boss_defeated("giao-chu"):
		out.append("Hạ Giáo Chủ Hư Vô")
	if int(p.level) < 94:
		out.append("Cấp 94 (đang %d)" % int(p.level))
	return out


static func map_requirement(w, id: String) -> String:
	match id:
		"9-1":
			var b := region_blockers(w)
			return "" if b.is_empty() else " · ".join(b)
		"9-2":
			return "" if 3 in w.profile.floors9 else "Mở Cửa Tầng 3 (hạ Thủ Tầng tầng 3)."
		"9-3":
			return "" if 6 in w.profile.floors9 else "Mở Cửa Tầng 6 (hạ Thủ Tầng tầng 6)."
	return ""


## Thiên Đạo Chi Môn mở khi Thủ Tầng tầng 9 đã ngã và tới bước 6.
static func gate_open(w, id: String) -> bool:
	if id == "9-3":
		return w.is_boss_defeated("ma-ton") or (9 in w.profile.floors9 and step(w) >= S_BOSS)
	return true


static func env_text(w) -> String:
	if not in_region(w):
		return ""
	var st = w.ch9
	var parts := PackedStringArray()
	var f := floor_of(w, w.player.pos)
	var el := floor_element(w, f)
	if f > 0 and el != "":
		var counter := ""
		for a in Monsters.COUNTERS:
			if Monsters.COUNTERS[a] == el:
				counter = a
		parts.append("Tầng %d · %s · khắc: %s" % [f, Monsters.ELEMENT_NAMES[el], Monsters.ELEMENT_NAMES.get(counter, "?")])
	if st.seal_t > 0.0:
		parts.append("Ấn Hệ %d giây" % ceili(st.seal_t))
	if st.nocounter_t > 0.0:
		parts.append("Mất khắc hệ %d giây" % ceili(st.nocounter_t))
	if st.reverse_t > 0.0:
		parts.append("GIẤC MƠ — điều khiển đảo ngược %d giây" % ceili(st.reverse_t))
	if st.dream_t > 0.0:
		parts.append("Ma Tôn gieo Giấc mơ — NÉ LĂN!")
	if st.lava_warn > 0.0:
		parts.append("DUNG NHAM DÂNG sau %d giây — lên Đá Nổi!" % ceili(st.lava_warn))
	elif st.lava_t > 0.0:
		parts.append("Dung nham %d giây" % ceili(st.lava_t))
	if st.chan_t > 0.0:
		parts.append("MA TÔN HÚT THIÊN PHÚ — vào vòng đèn!")
	if st.sector_warn >= 0:
		parts.append("VÀNH CỔNG SẮP VỠ — vào gần tâm!")
	var b = _boss(w)
	if b != null and st.intro_t > 0.0:
		parts.append("Ma Tôn chuyển giai đoạn (%.1f giây)" % st.intro_t)
	if b != null and st.clone_on:
		parts.append("Phân thân — đánh bản có bóng (%d/%d)" % [st.clone_hits, CLONE_HITS])
	if mask_on(w):
		parts.append("Mặt Nạ Vô Diện: khắc hệ")
	if st.godform_t > 0.0:
		parts.append("THẦN HOÁ %d giây" % ceili(st.godform_t))
	return "   ·   ".join(parts)


static func env_alert(w) -> bool:
	if not in_region(w):
		return false
	var st = w.ch9
	return st.dream_t > 0.0 or st.lava_warn > 0.0 or st.chan_t > 0.0 or st.sector_warn >= 0 or st.reverse_t > 0.0


static func quest_hud(w) -> Dictionary:
	var q := quest(w)
	if not q.is_empty():
		var qs := quest_status(w)
		var rt := Story.reward_text(q.reward)
		return {"active": true, "title": "CHƯƠNG 9 · NHIỆM VỤ %d/%d" % [step(w), Story.QUESTS9.size()],
			"lines": [["◆ " + str(q.title) + ("  (%d/%d)" % qs if int(qs[1]) > 1 else ""), "gold"], [str(q.hint), "text"],
				[("Thưởng: " + rt) if rt != "" else "", "muted"]]}
	if chapter_done(w):
		var e := ending(w)
		return {"done": true, "title": "HÀNH TRÌNH HOÀN THÀNH ✓",
			"lines": [["Kết thúc: " + ("Hợp nhất — Thiên Đạo mới" if e == "hop-nhat" else "Hiến tế — sương mù tan"), "text"],
				["Săn Thiên Đạo Hư Ảnh ở tầng 7–9", "muted"],
				[("Thần Vực ở Thiên Thê Đài I" if e == "hop-nhat" else "Tái Thiết Lục Địa ở trạm mỗi vùng"), "muted"]]}
	return {}
