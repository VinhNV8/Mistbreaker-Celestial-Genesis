extends RefCounted
## J3 (docs/23, 17 C8-45/46): chuyển chức 3 — điều kiện, +10% HP/Tấn công, hiệu ứng và Thần Kỹ của Kiếm Thần,
## Thiên Lạc Xạ Thủ, Hiền Giả. Thủ Hộ Thần và Vạn Linh Chi Chủ nằm ở core/classes2.gd (D50).
## Là một module của Chapters (D38): khai báo HOOKS; trạng thái ở GameWorld.j3.

const Classes = preload("res://scripts/data/classes.gd")
const Monsters = preload("res://scripts/data/monsters.gd")
const Formulas = preload("res://scripts/core/formulas.gd")

const MAPS := []
const NPCS := []
const HOOKS := ["on_load", "tick", "derive_bonus", "derive_after", "after_shot", "hit_mult", "poise_mult"]

## Kiếm Thần: kỹ năng +15%; vỡ Phá Thế boss choáng thêm 1 giây, nhận +70% (thay +50%).
const KT_SKILL := 0.15
const KT_STUN := 1.0
const KT_BROKEN := 1.7 / 1.5
## Nhất Kiếm Khai Thiên: vung 0,5 giây, vệt 40 m rộng 5 m, gấp đôi lên quái vỡ Phá Thế.
const NK_WINDUP := 0.5
const NK_LEN := 400.0
const NK_HALF := 25.0
const NK_BROKEN := 2.0
## Thiên Lạc Xạ Thủ: phát bắn thường thứ 5 → mũi tên sao ×0,5 (cân bằng TL-J3; spec 17: ×1,0); +10% chí mạng lên boss / boss hiếm / tinh anh.
const TL_EVERY := 5
const TL_STAR := 0.5
const TL_CRIT := 0.10
const STAR_FALL := 0.25
const STAR_R := 30.0
## Thiên Lạc Tinh Vũ: 8 mũi lên 8 quái nhiều HP nhất trong 25 m, mỗi mũi cách 0,1 giây.
const TV_COUNT := 8
const TV_REACH := 250.0
const TV_GAP := 0.1
## Hiền Giả: +30% hồi MP, phép vùng +15% bán kính; 3 kỹ năng → kỹ năng kế tiếp miễn MP, hồi chiêu −50%.
const HG_MP := 1.3
const HG_AREA := 1.15
const HG_EVERY := 3
const HG_CD := 0.5
## Ngũ Hành Luân Chuyển: 6 giây, 5 cầu quay bán kính 5 m quanh quái gần điểm ngắm (trong 30 m; không có thì quanh mình) —
## cân bằng TL-J3: Pháp Sư đứng xa nên cầu quanh mình không chạm boss. Mỗi quái nhận tối đa 1 đòn mỗi 0,5 giây; cầu khắc hệ +30%.
const NH_TIME := 6.0
const NH_R := 50.0
const NH_ORB := 14.0
const NH_SPIN := 3.0
const NH_GAP := 0.5
const NH_COUNTER := 1.3
const NH_ELEMENTS := ["kim", "moc", "thuy", "hoa", "tho"]
const NH_REACH := 300.0


class State:
	## Phát bắn thường đã bắn (Thiên Lạc)
	var shots := 0
	## Hiền Giả: số kỹ năng đã dùng từ lần miễn phí trước, kỹ năng kế tiếp miễn phí
	var casts := 0
	var free := false
	## [{t, target, mul, skill}] — mũi tên sao đang rơi
	var stars: Array = []
	## Nhất Kiếm đang vung: {t, dir, mul} (rỗng = không)
	var slash := {}
	## Vệt chém vừa xong (để vẽ): {from, to, t}
	var flash := {}
	## Ngũ Hành: giây còn lại, hệ số, góc quay, {id quái * 5 + cầu: giây được chạm lại}
	var orbs_t := 0.0
	var orbs_mul := 0.0
	var orbs_angle := 0.0
	var orb_next := {}
	## Quái cầu đang quay quanh (null = quanh người chơi)
	var orbs_target = null


static func job3(w) -> String:
	return str(w.profile.job3)


static func can_job3(w) -> String:
	var p = w.profile
	if job3(w) != "":
		return "Đã chuyển chức lần 3."
	if Classes.job3_def(str(p.class_id)).is_empty():
		return "Lớp này chưa có chuyển chức 3."
	if str(p.job2) == "":
		return "Cần chuyển chức lần 2 trước."
	if int(p.level) < Classes.JOB3_LEVEL:
		return "Cần cấp %d (đang %d)." % [Classes.JOB3_LEVEL, int(p.level)]
	if Classes.JOB3_NEED_CH8:
		if not w.is_boss_defeated("giao-chu"):
			return "Cần hạ Giáo Chủ Hư Vô (Điện Giáo Chủ, Sào Huyệt Hư Vô)."
		if int(p.void_cores) < Classes.JOB3_CORES:
			return "Cần %d Lõi Hư Vô (có %d)." % [Classes.JOB3_CORES, int(p.void_cores)]
	if float(p.crystal) < Classes.JOB3_CRYSTAL:
		return "Cần %d Tinh Thạch (có %d)." % [Classes.JOB3_CRYSTAL, int(p.crystal)]
	return ""


static func do_job3(w) -> bool:
	var why := can_job3(w)
	if why != "":
		w._message(why, "bad")
		return false
	var j := Classes.job3_def(str(w.profile.class_id))
	w.profile.crystal = float(w.profile.crystal) - Classes.JOB3_CRYSTAL
	if Classes.JOB3_NEED_CH8:
		w.profile.void_cores = int(w.profile.void_cores) - Classes.JOB3_CORES
	w.profile.job3 = str(j.id)
	w._refresh_stats()
	w.player.hp = w.stats.max_hp
	w.player.mp = w.stats.max_mp
	var sk: Dictionary = Classes.skill_by_id(str(w.profile.class_id), str(j.skill))
	w._events.append({"type": "job", "job": str(j.id), "name": j.name})
	w._message("Chuyển chức lần 3: %s! +10%% HP và Tấn công. Mở Thần Kỹ %s (bảng Kỹ năng, phím U)." % [j.name, sk.get("name", "")], "good")
	w._text(w.player.pos + Vector2(0, -50), str(j.name) + "!", Color(str(j.color)), true)
	w._sfx("levelup")
	return true


# ------------------------------------------------------------------ hook (Chapters)


static func on_load(w) -> void:
	w.j3 = State.new()


static func derive_bonus(w, bonus: Dictionary) -> void:
	if job3(w) != "":
		bonus.max_hp_pct += Classes.JOB3_BONUS
		bonus.atk_pct += Classes.JOB3_BONUS


static func derive_after(w, _bonus: Dictionary, st: Dictionary) -> void:
	if job3(w) == "hien-gia":
		st.mp_regen = float(st.mp_regen) * HG_MP


static func hit_mult(w, e, _crit: bool) -> float:
	if job3(w) != "kiem-than":
		return 1.0
	var k := KT_BROKEN if e.broken else 1.0
	if w.Skills2.source(w) != "":
		k *= 1.0 + KT_SKILL
	return k


static func poise_mult(w, _e) -> float:
	return 1.5 if job3(w) == "thu-ho-than" else 1.0


## Phát bắn thường của Thợ Săn (GameWorld._shoot).
static func after_shot(w, mul: float) -> void:
	if job3(w) != "thien-lac":
		return
	w.j3.shots += 1
	if w.j3.shots % TL_EVERY != 0:
		return
	var e = w._nearest_enemy(w.player.pos + Vector2.from_angle(w.player.facing) * 120.0, w.SHOT_RANGE)
	if e != null:
		w.j3.stars.append({"t": STAR_FALL, "target": e, "mul": mul * TL_STAR, "skill": ""})


# ------------------------------------------------------------------ hook gọi thẳng từ GameWorld


## Cộng vào tỉ lệ chí mạng của đòn đánh quái e.
static func crit_bonus(w, e) -> float:
	if job3(w) == "thien-lac" and (e.role in ["boss", "rare"] or e.elite):
		return TL_CRIT
	return 0.0


## Giây choáng thêm khi boss vỡ Phá Thế.
static func break_extra(w) -> float:
	return KT_STUN if job3(w) == "kiem-than" else 0.0


## Hệ số bán kính phép vùng (Bạo Phát, Thiên Thạch, vùng của kỹ năng).
static func area(w) -> float:
	return HG_AREA if job3(w) == "hien-gia" else 1.0


## Hiền Giả: kỹ năng này có miễn phí không (gọi trước khi trừ MP).
static func is_free(w) -> bool:
	return job3(w) == "hien-gia" and w.j3.free


## Sau khi dùng kỹ năng: đếm cho Hiền Giả.
static func after_cast(w, was_free: bool) -> void:
	if job3(w) != "hien-gia":
		return
	var st = w.j3
	if was_free:
		st.free = false
		st.casts = 0
		return
	st.casts += 1
	if st.casts >= HG_EVERY:
		st.free = true
		w._text(w.player.pos + Vector2(0, -52), "Hiền Giả: kỹ năng kế tiếp miễn phí", Color("#f2f6ff"), false)


# ------------------------------------------------------------------ Thần Kỹ (Skills2.cast → Classes2.cast → đây)


static func cast(w, id: String, mul: float) -> bool:
	var p = w.player
	match id:
		"nhatkiem":
			w._auto_face(NK_LEN, deg_to_rad(20.0))
			w.j3.slash = {"t": NK_WINDUP, "dir": Vector2.from_angle(p.facing), "mul": mul}
			p.swing = NK_WINDUP
			p.swing_kind = "cast"
			p.root_timer = maxf(p.root_timer, NK_WINDUP)
		"tinhvu":
			var pool: Array = w.enemies.filter(func(e): return not e.dead and not w.is_hidden(e) and e.pos.distance_to(p.pos) <= TV_REACH + e.radius)
			pool.sort_custom(func(a, b): return a.hp > b.hp)
			if pool.is_empty():
				return true
			for k in TV_COUNT:
				var e = pool[k] if k < pool.size() else pool[0]
				w.j3.stars.append({"t": STAR_FALL + TV_GAP * k, "target": e, "mul": mul, "skill": id})
			w._text(p.pos + Vector2(0, -60), "Thiên Lạc Tinh Vũ!", Color("#f2f6ff"), true)
			p.swing = 0.2
			p.swing_kind = "shot"
		"nguhanh":
			w.j3.orbs_t = NH_TIME
			w.j3.orbs_mul = mul
			w.j3.orb_next = {}
			w.j3.orbs_target = w._nearest_enemy(p.pos + (w._aim - p.pos).limit_length(NH_REACH), NH_REACH)
			w._text(p.pos + Vector2(0, -60), "Ngũ Hành Luân Chuyển!", Color("#f2f6ff"), true)
			p.swing = 0.25
			p.swing_kind = "cast"
		_:
			return false
	return true


static func orb_center(w) -> Vector2:
	var t = w.j3.orbs_target
	return t.pos if t != null and not t.dead else w.player.pos


static func orb_pos(w, k: int) -> Vector2:
	return orb_center(w) + Vector2.from_angle(w.j3.orbs_angle + TAU * k / 5.0) * NH_R


static func tick(w, dt: float) -> void:
	var st = w.j3
	var p = w.player
	if p.dead_timer > 0.0:
		st.slash = {}
		st.orbs_t = 0.0
	if not st.flash.is_empty():
		st.flash.t -= dt
		if st.flash.t <= 0.0:
			st.flash = {}
	# Nhất Kiếm Khai Thiên
	if not st.slash.is_empty():
		st.slash.t -= dt
		if st.slash.t <= 0.0:
			var dir: Vector2 = st.slash.dir
			var from: Vector2 = p.pos
			var to: Vector2 = p.pos + dir * NK_LEN
			w.skill_ctx = "nhatkiem"
			w._sfx("slash")
			for e in w.enemies:
				if e.dead:
					continue
				var c: Vector2 = Geometry2D.get_closest_point_to_segment(e.pos, from, to)
				if c.distance_to(e.pos) <= NK_HALF + e.radius:
					w._hit_enemy(e, float(st.slash.mul) * (NK_BROKEN if e.broken else 1.0), false, true)
			w.skill_ctx = ""
			st.flash = {"from": from, "to": to, "t": 0.3}
			st.slash = {}
	# Mũi tên sao
	for s in st.stars:
		s.t -= dt
		if s.t > 0.0:
			continue
		var e = s.target
		if e == null or e.dead:
			continue
		w._blast(e.pos, STAR_R, Color("#f2f6ff"))
		w.skill_ctx = str(s.skill)
		w._hit_enemy(e, float(s.mul), false, true)
		w.skill_ctx = ""
	st.stars = st.stars.filter(func(s): return s.t > 0.0 and s.target != null and not s.target.dead)
	# Ngũ Hành Luân Chuyển
	if st.orbs_t > 0.0:
		st.orbs_t -= dt
		st.orbs_angle = fmod(st.orbs_angle + NH_SPIN * dt, TAU)
		if st.orbs_target != null and st.orbs_target.dead:
			st.orbs_target = w._nearest_enemy(p.pos, NH_REACH)
		w.skill_ctx = "nguhanh"
		for e in w.enemies:
			if e.dead or w.time < float(st.orb_next.get(e.id, -1.0)):
				continue
			# cầu chạm quái: lấy cầu tốt nhất (khắc hệ +30%)
			var best := 0.0
			var el: String = str(Monsters.DEFS[e.kind].get("element", ""))
			for k in 5:
				if e.pos.distance_to(orb_pos(w, k)) <= NH_ORB + e.radius:
					best = maxf(best, NH_COUNTER if Monsters.counters(NH_ELEMENTS[k], el) else 1.0)
			if best <= 0.0:
				continue
			st.orb_next[e.id] = w.time + NH_GAP
			w._hit_enemy(e, st.orbs_mul * best, false, true)
		w.skill_ctx = ""
