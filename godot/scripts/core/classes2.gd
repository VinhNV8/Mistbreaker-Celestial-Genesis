extends RefCounted
## LH1 / LH2 (docs/19, D50): lớp thứ 4 Hộ Vệ, lớp thứ 5 Triệu Hồi Sư — kỹ năng, đặc tính lớp, bị động chuyển chức.
## GameWorld gọi: cast (qua Skills2.cast), tick, taken_mult, def_mult, on_player_hit, hit_mult, after_hit, after_slash,
## after_dash_hit, basic_spirit (đánh thường Triệu Hồi Sư), summon_act (lượt đánh của linh thú).
## J3 (docs/23): chức 3 Thủ Hộ Thần, Vạn Linh Chi Chủ + 2 Thần Kỹ. SH: linh thú có máu — mob_vs_summon, summon_gone, immune.

const Formulas = preload("res://scripts/core/formulas.gd")

# ------------------------------------------------------------------ Hộ Vệ — đặc tính lớp và chuyển chức
## Khiên: nhận ít hơn 15% sát thương.
const GUARD_TAKEN := 0.85
## Hiệp Sĩ: mỗi đòn thứ 4 phóng sóng khiên 25 m xuyên quái ×0,8 (như Kiếm Sư) và choáng quái thường trước mặt 0,8 giây.
const HS_EVERY := 4
const HS_EXTRA := 0.8
const HS_RANGE := 250.0
const HS_STUN := 0.8
## Thánh Kỵ Sĩ: hút máu 5%; HP trên 70% thì +15% sát thương.
const TKS_LEECH := 0.05
const TKS_HP := 0.7
const TKS_BONUS := 0.15
## Thiết Vệ: nhận ít hơn thêm 15%; phản 30% sát thương bị đánh.
const TV_TAKEN := 0.85
const TV_REFLECT := 0.3
## Phản đòn khi không biết quái nào đánh (đòn vùng của boss) → quái gần nhất trong 15 m.
const REFLECT_REACH := 150.0

# ------------------------------------------------------------------ Hộ Vệ — kỹ năng
const KC_RANGE := 90.0
const KC_ARC := deg_to_rad(45.0)
const KC_STUN := 1.0
const KK_R := 120.0
## CS (docs/26 mục 3.3): "+20% thù hận" của CR-001 → Khiêu Khích kéo quái xa hơn 20%.
const KK_THREAT := 1.2
const LK_KNOCK := 40.0
## Khiên Thép (CL2): 10 giây +30% Phòng thủ.
const KT_TIME := 10.0
const KT_DEF := 0.3
const CD_R := 100.0
const CD_STUN := 2.0
const PT_RANGE := 300.0
const PT_SPEED := 650.0
const PT_R := 26.0
const PQ_RANGE := 300.0
const PQ_R := 80.0
const PQ_DELAY := 0.35
const XP_DIST := 250.0
const XP_STUN := 1.5
## Thành Bất Diệt (CL2): 8 giây nhận ít hơn 80%, hào quang 12 m.
const TTH_TIME := 8.0
const TTH_R := 120.0
const TTH_TAKEN := 0.2
const TQ_RANGE := 110.0
const TQ_ARC := deg_to_rad(60.0)
const TQ_HEAL := 0.15
const TV_R := 100.0
const TV_TICKS := 10
const TV_HEAL := 0.015
const TC_R := 120.0
const TC_STUN := 1.5
const TD_R := 90.0
const TD_SHIELD := 0.2
const TD_TIME := 6.0
## J3 Thủ Hộ Thần: nhận ít hơn thêm 10%; Bất Khuất (HP < 30% → hồi 30%, miễn sát thương 2 giây, mỗi 60 giây);
## Thần Uy 20% choáng quái thường 1 giây (thanh Phá Thế +50% ở core/job3.gd poise_mult).
const THT_TAKEN := 0.9
const BK_HP := 0.3
const BK_HEAL := 0.3
const BK_IMMUNE := 2.0
const BK_CD := 60.0
const TU_CHANCE := 0.2
const TU_STUN := 1.0
## Thiên Thuẫn Giáng Thế: vòng 12 m, choáng 2 giây, khiên 30% HP tối đa 6 giây.
const TT_R := 120.0
const TT_STUN := 2.0
const TT_SHIELD := 0.3
const TT_TIME := 6.0

# ------------------------------------------------------------------ Triệu Hồi Sư (LH2, docs/19 mục 3)
## Đánh thường Linh Cầu: 40 m ×0,85, 0,6 giây/đòn.
const SPIRIT_RANGE := 400.0
const SPIRIT_SPEED := 520.0
const SPIRIT_MUL := 0.45
const SPIRIT_INTERVAL := 0.6
## Linh Hồ thường trực: Tấn công 40% người chơi; Linh Sư +1 con; Ngự Long Sư: Hoả Hồ nổ lan 4 m.
const FOX_FACTOR := 0.4
const FOX_SPLASH := 40.0
## Linh thú gọi bằng kỹ năng tối đa 8 cùng lúc; khi có Quân Đoàn Linh Hồn tối đa 12.
const SUMMON_CAP := 8
## CS (docs/26 mục 3.1, CR-001): tối đa 3 linh thú chủ lực gọi bằng kỹ năng cùng lúc (Sói Bóng, Thạch Quỷ, Ấu Long);
## linh thú +20% HP (+0,3% mỗi WIS — Stats pet_hp_pct); mỗi linh thú đang sống +4% hồi MP cho chủ (Gắn kết, tối đa 3).
const Passives = preload("res://scripts/core/passives.gd")
const MAIN_SUMMONS := ["soibong", "thachquy", "aulong"]
const MAIN_CAP := 3
const PET_HP := 1.2
const BOND_REGEN := 0.04
const BOND_MAX := 3
## Linh thú tìm quái trong 45 m quanh người chơi (thú cưng / Xương Nô: 26 m) — Triệu Hồi Sư đứng xa như Pháp Sư.
const SUMMON_REACH := 450.0
## Linh thú ưu tiên quái người chơi đánh trong 3 giây gần nhất.
const FOCUS_TIME := 3.0
const LEGION_CAP := 12
const LS_BONUS := 0.2
const NL_BONUS := 0.2
const SPLASH_MUL := 1.0
## Tấn công linh thú = hệ số kỹ năng × Tấn công người chơi; mỗi đòn gây 50% Tấn công đó (cân bằng LH2: lớp chênh ≤ 25%).
const SUMMON_HIT := 0.7
## Liên Kết Linh Hồn: 8 giây linh thú +40%, mình +20%.
const LK_TIME := 8.0
const LK_ALLY := 0.4
const LK_SELF := 0.2
const LTI_SHOTS := 5
const LTI_STEP := deg_to_rad(10.0)
const LTI_RANGE := 350.0
const HD_RANGE := 400.0
const HD_SPEED := 600.0
const LTR_R := 90.0
const LTR_TICKS := 8
const LTR_BONUS := 0.3
const LH_R := 120.0
## Đồ đằng: Đồ Đằng Sư kéo dài ×1,5; đứng trong 12 m hồi 2% HP và MP mỗi giây.
const TOTEM_EXTRA := 1.5
const DD_R := 120.0
const DD_REGEN := 0.02
const LDD_TIME := 10.0
const LDD_R := 150.0
const PDD_TIME := 8.0
const PDD_R := 100.0
const PDD_HASTE := 0.4
const TOTEM_GAP := 0.5
## J3 Vạn Linh Chi Chủ: tối đa +2, tồn tại +30%, +15% sát thương, +50% HP, gục / hết giờ nổ 5 m ×0,6.
const VL_CAP := 2
const VL_TTL := 1.3
const VL_DMG := 0.15
const VL_HP := 1.5
const VL_BOOM_R := 50.0
const VL_BOOM := 0.3
## Kỳ Lân Giáng Thế: 12 giây, không tính vào giới hạn.
const KL_TIME := 12.0
## SH (docs/23 mục 4): quái thường / tinh anh đánh linh thú trong 8 m nếu linh thú gần quái hơn người chơi
## (Thạch Quỷ: luôn ưu tiên); hồi 5% HP/giây sau 3 giây không bị đánh; Linh Hồ gục → 10 giây mới sinh lại.
const MOB_REACH := 80.0
const SUMMON_HURT := 3.0
const SUMMON_REGEN := 0.05
const FOX_RESPAWN := 10.0
## Linh thú: tên, bán kính, tầm đánh xa (0 = cận chiến), nổ lan, giây mỗi đòn, màu vòng chân, HP (× HP người chơi).
const SUMMONS := {
	"linh-ho": {"name": "Linh Hồ", "radius": 11.0, "range": 0.0, "splash": 0.0, "rate": 1.25, "color": "#9de0ff", "hp": 0.3},
	"hoa-ho": {"name": "Hoả Hồ", "radius": 11.0, "range": 0.0, "splash": 0.0, "rate": 1.25, "color": "#ff9a3c", "hp": 0.3},
	"soi-bong": {"name": "Sói Bóng", "radius": 14.0, "range": 0.0, "splash": 0.0, "rate": 1.25, "color": "#8a6ae0", "hp": 0.4},
	"tieu-quy": {"name": "Tiểu Quỷ", "radius": 9.0, "range": 200.0, "splash": 0.0, "rate": 1.5, "color": "#c060f0", "hp": 0.15},
	"thach-quy": {"name": "Thạch Quỷ", "radius": 20.0, "range": 0.0, "splash": 50.0, "rate": 1.6, "color": "#9ba8bc", "hp": 0.8, "taunt": true},
	"linh-ung": {"name": "Linh Ưng", "radius": 11.0, "range": 250.0, "splash": 0.0, "rate": 1.3, "color": "#c4e4ff", "hp": 0.25},
	"linh-hon": {"name": "Linh Hồn", "radius": 9.0, "range": 0.0, "splash": 0.0, "rate": 1.25, "color": "#86d8e4", "hp": 0.15},
	"au-long": {"name": "Ấu Long", "radius": 18.0, "range": 220.0, "splash": 60.0, "rate": 1.5, "color": "#ff7a3a", "hp": 0.6},
	"ky-lan": {"name": "Kỳ Lân", "radius": 18.0, "range": 250.0, "splash": 70.0, "rate": 1.2, "color": "#f2f6ff", "hp": 1.0},
}


class State:
	## Khiên Thép còn lại (giây)
	var steel_t := 0.0
	## Thành Bất Diệt còn lại (giây)
	var angel_t := 0.0
	## [{pos, dir, dist, back, hit, mul, skill}] — Phi Thuẫn
	var shields: Array = []
	## [{pos, t, r, mul, skill}] — Phán Quyết
	var slams: Array = []
	## Liên Kết Linh Hồn còn lại (giây)
	var link_t := 0.0
	## [{pos, ttl, kind ("loi" | "phong"), mul, skill, acc}] — Lôi / Phong Đồ Đằng
	var totems: Array = []
	## true trong lúc linh thú ra đòn (Liên Kết: "mình +20%" không áp lên linh thú)
	var ally_hit := false
	## Quái người chơi vừa đánh (linh thú đánh theo, kể cả quái ẩn như tấm gương thật của Bản Ngã) và hạn (w.time)
	var focus = null
	var focus_until := 0.0
	## J3 Thủ Hộ Thần: Bất Khuất dùng lại được từ (w.time), miễn sát thương còn lại (giây)
	var bk_ready := 0.0
	var immune_t := 0.0
	## SH: Linh Hồ thường trực sinh lại từ (w.time); {id quái: giây tới đòn kế tiếp vào linh thú}
	var fox_ready := 0.0
	var mob_cd := {}


static func job(w) -> String:
	return str(w.profile.job)


static func job2(w) -> String:
	return str(w.profile.job2)


static func job3(w) -> String:
	return str(w.profile.job3)


## J3 Bất Khuất: đang miễn sát thương.
static func immune(w) -> bool:
	return w.cl2.immune_t > 0.0


## Không bị kéo / đẩy lùi: boss, boss hiếm, tinh anh và quái của trận boss (Mộng Châu, đầu Thuỷ Quái… đứng yên theo cơ chế).
static func immovable(e) -> bool:
	return e.role in ["boss", "rare", "bossMinion", "rareMinion"] or e.elite


static func is_guard(w) -> bool:
	return str(w.profile.class_id) == "ho-ve"


static func is_summoner(w) -> bool:
	return str(w.profile.class_id) == "trieu-hoi-su"


## Choáng quái thường; boss / boss hiếm / tinh anh nhận vào thanh Phá Thế thay vì choáng.
static func stun(w, e, t: float, mul := 1.0) -> void:
	if e.dead:
		return
	if e.role in ["boss", "rare"] or e.elite:
		w._damage_poise(e, Formulas.compute_damage(w.stats.atk, e.def, mul))
	elif e.state != "stunned":
		e.state = "stunned"
		e.timer = t


# ------------------------------------------------------------------ hook từ GameWorld


## Hệ số sát thương người chơi nhận vào (nhân sau Thiết Bích, trước khiên chắn).
static func taken_mult(w) -> float:
	var m := 1.0
	if is_guard(w):
		m *= GUARD_TAKEN
		if job2(w) == "thiet-ve":
			m *= TV_TAKEN
		if job3(w) == "thu-ho-than":
			m *= THT_TAKEN
	if w.cl2.angel_t > 0.0:
		m *= TTH_TAKEN
	return m * Passives.taken_mult(w)


## Phòng thủ dùng khi bị đánh (Khiên Thép +30%).
static func def_mult(w) -> float:
	return 1.0 + KT_DEF if w.cl2.steel_t > 0.0 else 1.0


## Sau khi người chơi mất dmg máu: Bất Khuất (Thủ Hộ Thần, trước khi xét gục), Thiết Vệ phản đòn.
static func on_player_hit(w, dmg: float, src) -> void:
	var pl = w.player
	if job3(w) == "thu-ho-than" and pl.hp < float(w.stats.max_hp) * BK_HP and w.time >= w.cl2.bk_ready:
		pl.hp = maxf(pl.hp, 0.0) + float(w.stats.max_hp) * BK_HEAL
		w.cl2.bk_ready = w.time + BK_CD
		w.cl2.immune_t = BK_IMMUNE
		w._text(pl.pos + Vector2(0, -60), "Bất Khuất!", Color("#f2f6ff"), true)
	var pct := 0.0
	if is_guard(w) and job2(w) == "thiet-ve":
		pct += TV_REFLECT
	pct += Passives.reflect(w)
	if pct <= 0.0 or dmg <= 0.0:
		return
	var e = src
	if e == null or e.dead:
		e = w._nearest_enemy(w.player.pos, REFLECT_REACH)
	if e == null:
		return
	w._apply_damage(e, maxi(1, int(round(dmg * pct))), false, true)


## Nhân vào mọi đòn người chơi đánh quái.
static func hit_mult(w) -> float:
	if is_guard(w) and job2(w) == "thanh-ky-si" and w.player.hp > float(w.stats.max_hp) * TKS_HP:
		return 1.0 + TKS_BONUS
	if is_summoner(w) and w.cl2.link_t > 0.0 and not w.cl2.ally_hit:
		return 1.0 + LK_SELF
	return 1.0


static func after_hit(w, e, sid: String, dmg: int) -> void:
	if not w.cl2.ally_hit and is_summoner(w):
		w.cl2.focus = e
		w.cl2.focus_until = w.time + FOCUS_TIME
	# Hoả Điểu: thiêu 3 giây (cùng cơ chế thiêu của biến thể hệ Hỏa)
	if sid == "hoadieu" and not e.dead:
		if e.bleed_timer <= 0.0:
			e.bleed_tick = 0.0
		e.bleed_timer = maxf(e.bleed_timer, w.Skills2.BURN_TIME)
		e.bleed_dmg = maxf(e.bleed_dmg, Formulas.compute_damage(w.stats.atk, e.def, w.Skills2.BURN_MUL))
	if not is_guard(w):
		return
	# J3 Thần Uy: 20% choáng quái thường 1 giây.
	if job3(w) == "thu-ho-than" and not e.dead and not immovable(e) and e.state != "stunned" and w._r() < TU_CHANCE:
		e.state = "stunned"
		e.timer = TU_STUN
	var heal := 0.0
	if job2(w) == "thanh-ky-si":
		heal += TKS_LEECH
	if sid == "thanhquang":
		heal += TQ_HEAL
	if heal > 0.0:
		w.player.hp = minf(float(w.stats.max_hp), w.player.hp + dmg * heal)


## Sau mỗi đòn chém thường (Hộ Vệ đánh thường bằng chém).
static func after_slash(w) -> void:
	if not is_guard(w) or job(w) != "hiep-si" or w.player.hits % HS_EVERY != 0:
		return
	var p = w.player
	w._blast(p.pos + Vector2.from_angle(p.facing) * 40.0, 36.0, Color("#ffe9a0"))
	for e in w.enemies:
		if e.dead:
			continue
		var to_e: Vector2 = e.pos - p.pos
		if to_e.length() <= w.SLASH_RANGE + e.radius and absf(angle_difference(p.facing, to_e.angle())) <= w.SLASH_ARC:
			stun(w, e, HS_STUN, HS_EXTRA)
	w._fire(w.WAVE_SPEED, HS_RANGE, HS_EXTRA, true, "wave", false, 22.0)


## Mỗi quái trúng đòn lao (Lao Khiên đẩy lùi, Xung Phong choáng).
static func after_dash_hit(w, e, skill: String) -> void:
	if e.dead:
		return
	match skill:
		"laokhien":
			if not immovable(e):
				e.pos += w.player.dash_dir * LK_KNOCK
		"xungphong":
			stun(w, e, XP_STUN, 1.0)


# ------------------------------------------------------------------ kỹ năng


static func cast(w, id: String, mul: float) -> bool:
	var p = w.player
	match id:
		"khienchan":
			w._auto_face(KC_RANGE, KC_ARC)
			w._blast(p.pos + Vector2.from_angle(p.facing) * KC_RANGE * 0.55, KC_RANGE * 0.5, Color("#c8d6e4"))
			w._sfx("slash")
			for e in w.enemies:
				if e.dead:
					continue
				var to_e: Vector2 = e.pos - p.pos
				if to_e.length() <= KC_RANGE + e.radius and absf(angle_difference(p.facing, to_e.angle())) <= KC_ARC:
					w._hit_enemy(e, mul)
					stun(w, e, KC_STUN, mul)
			p.swing = 0.2
			p.swing_kind = "slash"
		"khieukhich":
			w._blast(p.pos, KK_R * KK_THREAT, Color("#ffd76a"))
			w._sfx("boss_roar")
			for e in w.enemies:
				if e.dead or e.pos.distance_to(p.pos) > KK_R * KK_THREAT + e.radius:
					continue
				if immovable(e):
					w._hit_enemy(e, mul, false, true)
					if not e.dead and e.max_poise > 0.0:
						w._damage_poise(e, Formulas.compute_damage(w.stats.atk, e.def, mul))
					continue
				var off: Vector2 = e.pos - p.pos
				e.pos = p.pos + (off.normalized() if off.length() > 1.0 else Vector2.RIGHT) * (w.PLAYER_RADIUS + e.radius + 6.0)
				if e.state == "idle":
					e.state = "chase"
				w._hit_enemy(e, mul, false, true)
			p.swing = 0.3
			p.swing_kind = "spin"
		"laokhien", "xungphong":
			var dir: Vector2 = w._aim - p.pos
			p.dash_dir = dir.normalized() if dir.length() > 1.0 else Vector2.from_angle(p.facing)
			p.dash_time = w.DASH_TIME
			p.dash_mul = mul
			p.dash_hit = {}
			p.dash_skill = id
			p.dash_dist = XP_DIST if id == "xungphong" else w.DASH_DIST
			p.swing = w.DASH_TIME + 0.05
			p.swing_kind = "dash"
		"khienthep":
			w.cl2.steel_t = KT_TIME
			w._text(p.pos + Vector2(0, -40), "Khiên Thép!", Color("#c8d6e4"), true)
		"chandia":
			w._blast(p.pos, CD_R, Color("#b08a5a"))
			w._sfx("explode")
			for e in w.enemies:
				if not e.dead and e.pos.distance_to(p.pos) <= CD_R + e.radius:
					w._hit_enemy(e, mul, false, true)
					stun(w, e, CD_STUN, mul * 2.0)
			p.swing = 0.25
			p.swing_kind = "spin"
		"phanthuan":
			w._soft_lock(PT_RANGE)
			w.cl2.shields.append({"pos": p.pos, "dir": Vector2.from_angle(p.facing), "dist": 0.0, "back": false, "hit": {},
				"mul": mul, "skill": id})
			p.swing = 0.18
			p.swing_kind = "slash"
		"phanquyet":
			var at: Vector2 = p.pos + (w._aim - p.pos).limit_length(PQ_RANGE)
			var n = w._nearest_enemy(at, PQ_R)
			if n == null:
				n = w._nearest_enemy(p.pos, PQ_RANGE)
				if n != null:
					at = n.pos
			w.cl2.slams.append({"pos": at, "t": PQ_DELAY, "r": PQ_R, "mul": mul, "skill": id})
			p.swing = 0.25
			p.swing_kind = "cast"
		"thanhbatdiet":
			w.cl2.angel_t = TTH_TIME
			w.sk2.ice.append({"pos": p.pos, "r": TTH_R, "ticks": int(TTH_TIME / 0.5), "timer": 0.0, "mul": mul, "skill": id,
				"gap": 0.5, "follow": true, "poison": true, "color": "#ffe9a0"})
			w._text(p.pos + Vector2(0, -60), "Thành Bất Diệt!", Color("#ffe9a0"), true)
			p.swing = 0.3
			p.swing_kind = "cast"
		"thanhquang":
			w._auto_face(TQ_RANGE, TQ_ARC)
			w._blast(p.pos + Vector2.from_angle(p.facing) * TQ_RANGE * 0.55, TQ_RANGE * 0.6, Color("#fff2c8"))
			w._sfx("slash")
			for e in w.enemies:
				if e.dead:
					continue
				var to_e2: Vector2 = e.pos - p.pos
				if to_e2.length() <= TQ_RANGE + e.radius and absf(angle_difference(p.facing, to_e2.angle())) <= TQ_ARC:
					w._hit_enemy(e, mul)
			p.swing = 0.2
			p.swing_kind = "slash"
		"thanhvuc":
			w.sk2.ice.append({"pos": p.pos, "r": TV_R, "ticks": TV_TICKS, "timer": 0.0, "mul": mul, "skill": id,
				"gap": 0.5, "follow": true, "heal": TV_HEAL, "color": "#ffe9a0"})
			p.swing = 0.3
			p.swing_kind = "spin"
		"thietchuy":
			w._blast(p.pos, TC_R, Color("#9ba8bc"))
			w._sfx("explode")
			for e in w.enemies:
				if not e.dead and e.pos.distance_to(p.pos) <= TC_R + e.radius:
					w._hit_enemy(e, mul, false, true)
					stun(w, e, TC_STUN, mul)
			p.swing = 0.3
			p.swing_kind = "spin"
		"thanhdong":
			w._blast(p.pos, TD_R, Color("#c8d6e4"))
			w._sfx("explode")
			for e in w.enemies:
				if not e.dead and e.pos.distance_to(p.pos) <= TD_R + e.radius:
					w._hit_enemy(e, mul, false, true)
			p.shield = maxf(p.shield, float(w.stats.max_hp) * TD_SHIELD)
			p.shield_time = maxf(p.shield_time, TD_TIME)
			w._text(p.pos + Vector2(0, -40), "Thành Đồng!", Color("#c8d6e4"), true)
			p.swing = 0.3
			p.swing_kind = "spin"
		"thienthuan":
			# J3 Thần Kỹ Thủ Hộ Thần
			w._blast(p.pos, TT_R, Color("#f2f6ff"))
			w._sfx("explode")
			for e in w.enemies:
				if not e.dead and e.pos.distance_to(p.pos) <= TT_R + e.radius:
					w._hit_enemy(e, mul, false, true)
					stun(w, e, TT_STUN, mul * 2.0)
			p.shield = maxf(p.shield, float(w.stats.max_hp) * TT_SHIELD)
			p.shield_time = maxf(p.shield_time, TT_TIME)
			w._text(p.pos + Vector2(0, -60), "Thiên Thuẫn Giáng Thế!", Color("#f2f6ff"), true)
			p.swing = 0.3
			p.swing_kind = "spin"
		# ---------------------------------------------------------- Triệu Hồi Sư
		"soibong":
			summon(w, "soi-bong", mul, 20.0, id, p.pos + Vector2(30, 0))
			_cast_pose(p)
		"linhtien":
			w._soft_lock(LTI_RANGE)
			var keep: float = p.facing
			for k in LTI_SHOTS:
				p.facing = keep + (k - (LTI_SHOTS - 1) / 2.0) * LTI_STEP
				w._fire(SPIRIT_SPEED, LTI_RANGE, mul, false, "spirit", false, 10.0)
			p.facing = keep
			_cast_pose(p)
		"tieuquy":
			for k in 3:
				summon(w, "tieu-quy", mul, 12.0, id, p.pos + Vector2.from_angle(TAU * k / 3.0) * 28.0)
			_cast_pose(p)
		"lienket":
			w.cl2.link_t = LK_TIME
			w._text(p.pos + Vector2(0, -40), "Liên Kết Linh Hồn!", Color("#c060f0"), true)
		"thachquy":
			summon(w, "thach-quy", mul, 15.0, id, p.pos + Vector2(36, 0))
			_cast_pose(p)
		"hoadieu":
			w._soft_lock(HD_RANGE)
			w._fire(HD_SPEED, HD_RANGE, mul, true, "firebird", false, 18.0)
			_cast_pose(p)
		"linhtran":
			var at: Vector2 = p.pos + (w._aim - p.pos).limit_length(300.0)
			var n = w._nearest_enemy(at, LTR_R)
			if n == null:
				n = w._nearest_enemy(p.pos, 300.0)
				if n != null:
					at = n.pos
			w.sk2.ice.append({"pos": at, "r": LTR_R, "ticks": LTR_TICKS, "timer": 0.0, "mul": mul, "skill": id,
				"gap": 0.5, "poison": true, "boost": true, "color": "#c060f0"})
			_cast_pose(p)
		"linhung":
			for k in 2:
				summon(w, "linh-ung", mul, 12.0, id, p.pos + Vector2(-20 + 40 * k, -30))
			_cast_pose(p)
		"quandoan":
			for k in 10:
				summon(w, "linh-hon", mul, 15.0, id, p.pos + Vector2.from_angle(TAU * k / 10.0) * 46.0)
			w._text(p.pos + Vector2(0, -60), "Quân Đoàn Linh Hồn!", Color("#86d8e4"), true)
			_cast_pose(p)
		"aulong":
			summon(w, "au-long", mul, 18.0, id, p.pos + Vector2(0, -36))
			_cast_pose(p)
		"kylan":
			# J3 Thần Kỹ Vạn Linh Chi Chủ: không tính vào giới hạn, hồi đầy máu mọi linh thú.
			for a in w.allies:
				if not a.dead and a.kind == "summon":
					a.hp = a.max_hp
			summon(w, "ky-lan", mul, KL_TIME, id, p.pos + Vector2(0, -40))
			w._text(p.pos + Vector2(0, -60), "Kỳ Lân Giáng Thế!", Color("#f2f6ff"), true)
			_cast_pose(p)
		"longhong":
			_roar(w, p.pos, mul)
			for a in w.allies:
				if not a.dead and a.monster == "au-long":
					_roar(w, a.pos, mul)
			p.swing = 0.3
			p.swing_kind = "cast"
		"loidodang", "phongdodang":
			var at2: Vector2 = p.pos + (w._aim - p.pos).limit_length(250.0)
			var n2 = w._nearest_enemy(at2, 150.0)
			if n2 == null:
				n2 = w._nearest_enemy(p.pos, 250.0)
				if n2 != null:
					at2 = n2.pos
			var ttl: float = LDD_TIME if id == "loidodang" else PDD_TIME
			if job2(w) == "do-dang-su":
				ttl *= TOTEM_EXTRA
			w.cl2.totems.append({"pos": at2, "ttl": ttl, "kind": "loi" if id == "loidodang" else "phong", "mul": mul,
				"skill": id, "acc": 0.0})
			_cast_pose(p)
		_:
			# J3: Thần Kỹ của 3 lớp cũ (core/job3.gd)
			return w.Job3.cast(w, id, mul)
	return true


static func _cast_pose(p) -> void:
	p.swing = 0.25
	p.swing_kind = "cast"


static func _roar(w, at: Vector2, mul: float) -> void:
	w._blast(at, LH_R, Color("#ff7a3a"))
	w._sfx("boss_roar")
	for e in w.enemies:
		if not e.dead and e.pos.distance_to(at) <= LH_R + e.radius:
			w._hit_enemy(e, mul, false, true)


# ------------------------------------------------------------------ linh thú


## Gọi linh thú (factor = hệ số Tấn công so với người chơi). Vượt giới hạn → con gọi sớm nhất biến mất.
static func summon(w, kind: String, factor: float, ttl: float, skill: String, at: Vector2, perm := false):
	var d: Dictionary = SUMMONS[kind]
	var a = w.Ally.new()
	a.kind = "summon"
	a.monster = kind
	a.level = int(w.profile.level)
	a.pos = at
	a.radius = float(d.radius)
	# linh thú mạnh theo Tấn công (INT ×2) và cấp kỹ năng; không nhân thêm `skill_mul` (INT) lần nữa
	a.factor = factor if perm else factor / maxf(0.01, float(w.stats.skill_mul))
	a.ranged = float(d.range)
	a.splash = float(d.splash)
	a.rate = float(d.rate)
	a.skill = skill
	a.perm = perm
	a.ttl = -1.0 if perm else ttl * (VL_TTL if job3(w) == "van-linh" else 1.0)
	a.color = Color(str(d.color))
	a.max_hp = float(w.stats.max_hp) * float(d.get("hp", 0.3)) * (VL_HP if job3(w) == "van-linh" else 1.0) \
		* PET_HP * (1.0 + float(w.stats.get("pet_hp_pct", 0.0)))
	a.hp = a.max_hp
	# SN16: linh thú gọi bằng kỹ năng hiện hình xong mới lao ra (Linh Hồ thường trực sinh lại ngay)
	a.spawn_t = 0.0 if perm else w.ALLY_SPAWN
	w.allies.append(a)
	if skill in MAIN_SUMMONS:
		var mains: Array = w.allies.filter(func(x): return not x.dead and x.kind == "summon" and x.skill in MAIN_SUMMONS)
		for i in mains.size() - MAIN_CAP:
			mains[i].dead = true
	if not perm and skill != "kylan":
		var called: Array = w.allies.filter(func(x): return not x.dead and x.kind == "summon" and not x.perm and x.skill != "kylan")
		var cap: int = LEGION_CAP if skill == "quandoan" or called.any(func(x): return x.skill == "quandoan") else SUMMON_CAP
		if job3(w) == "van-linh":
			cap += VL_CAP
		var extra: int = called.size() - cap
		for x in called:
			if extra <= 0:
				break
			x.dead = true
			extra -= 1
	return a


## CS Gắn kết: hệ số hồi MP của Triệu Hồi Sư theo số linh thú đang sống (lớp khác 1,0).
static func bond_regen(w) -> float:
	if str(w.profile.class_id) != "trieu-hoi-su":
		return 1.0
	var n := 0
	for a in w.allies:
		if not a.dead and a.kind == "summon":
			n += 1
	return 1.0 + BOND_REGEN * mini(BOND_MAX, n)


## Hệ số sát thương linh thú (cộng dồn): Linh Sư, Ngự Long Sư, Liên Kết, trong Linh Trận.
static func ally_mult(w, a) -> float:
	var m := 1.0
	if job(w) == "linh-su":
		m += LS_BONUS
	if job2(w) == "ngu-long-su":
		m += NL_BONUS
	if w.cl2.link_t > 0.0:
		m += LK_ALLY
	if job3(w) == "van-linh":
		m += VL_DMG
	m += Passives.ally_bonus(w)
	for z in w.sk2.ice:
		if z.get("boost", false) and a.pos.distance_to(z.pos) <= float(z.r):
			m += LTR_BONUS
			break
	return m


static func _haste(w, a) -> float:
	for t in w.cl2.totems:
		if t.kind == "phong" and a.pos.distance_to(t.pos) <= PDD_R:
			return 1.0 + PDD_HASTE
	return 1.0


## Mục tiêu ưu tiên của linh thú: quái người chơi vừa đánh (null = tự chọn quái gần người chơi nhất).
static func focus_target(w):
	var f = w.cl2.focus
	if f == null or f.dead or w.time > w.cl2.focus_until or f.pos.distance_to(w.player.pos) > SUMMON_REACH:
		return null
	return f


## Lượt của linh thú (GameWorld._update_allies, khi đã có mục tiêu): tới tầm rồi đánh — đòn tính như đòn người chơi
## × hệ số linh thú, mang id kỹ năng gọi nó (cấp kỹ năng, biến thể áp lên).
static func summon_act(w, a, target, dt: float) -> void:
	var d: float = a.pos.distance_to(target.pos)
	var reach: float = a.ranged if a.ranged > 0.0 else a.radius + target.radius + 8.0
	if d > reach:
		a.pos = a.pos.move_toward(target.pos, w.ALLY_SPEED * dt)
		return
	if a.attack_cd > 0.0:
		return
	a.attack_cd = a.rate / _haste(w, a)
	if a.ranged > 0.0:
		var b = w.Bolt.new()
		b.points.append(a.pos + Vector2(0, -10))
		b.points.append(target.pos)
		w.bolts.append(b)
	var mul: float = a.factor * w.ally_damage_mult() * ally_mult(w, a) * SUMMON_HIT
	var keep: String = w.skill_ctx
	w.skill_ctx = a.skill
	w.cl2.ally_hit = true
	w._hit_enemy(target, mul, false, a.splash > 0.0)
	if a.splash > 0.0:
		w._blast(target.pos, a.splash, a.color)
		for o in w.enemies:
			if o != target and not o.dead and o.pos.distance_to(target.pos) <= a.splash + o.radius:
				w._hit_enemy(o, mul * SPLASH_MUL, false, true)
	w.cl2.ally_hit = false
	w.skill_ctx = keep


## Linh Hồ thường trực: 1 con (Linh Sư 2); Ngự Long Sư → Hoả Hồ nổ lan. Sinh lại khi thiếu (đổi map, hồi sinh).
static func _ensure_foxes(w) -> void:
	if not is_summoner(w) or w.player.dead_timer > 0.0:
		return
	var want := 2 if job(w) == "linh-su" else 1
	var fire: bool = job2(w) == "ngu-long-su"
	var have := 0
	for a in w.allies:
		if not a.dead and a.kind == "summon" and a.perm:
			have += 1
			a.monster = "hoa-ho" if fire else "linh-ho"
			a.splash = FOX_SPLASH if fire else 0.0
	# SH: Linh Hồ vừa gục → chờ 10 giây
	if have < want and w.time < w.cl2.fox_ready:
		return
	for k in want - have:
		var f = summon(w, "hoa-ho" if fire else "linh-ho", FOX_FACTOR, -1.0, "", w.player.pos + Vector2(-26, 14 + 20 * k), true)
		f.splash = FOX_SPLASH if fire else 0.0


## Đánh thường Linh Cầu.
static func basic_spirit(w) -> void:
	var p = w.player
	w._soft_lock(SPIRIT_RANGE)
	p.attack_cd = SPIRIT_INTERVAL / w.atk_speed()
	w.basic_swing(0.25)
	p.swing_kind = "cast"
	w._sfx("shot")
	var m: Array = w._basic_mul()
	w._fire(SPIRIT_SPEED, SPIRIT_RANGE, float(m[0]) * SPIRIT_MUL, false, "spirit", m[1], 11.0)


# ------------------------------------------------------------------ SH: linh thú có máu (docs/23 mục 4)


## Quái thường / tinh anh: linh thú gần nó hơn người chơi (trong 8 m) → đứng lại đánh linh thú. true = đã xử lý.
## Boss, boss hiếm, quái của trận boss không đánh linh thú (Q143).
static func mob_vs_summon(w, e, dt: float) -> bool:
	if not is_summoner(w) or e.state != "chase" or e.role in ["boss", "rare", "bossMinion", "rareMinion"]:
		return false
	var dp: float = e.pos.distance_to(w.player.pos)
	var best = null
	var bd := MOB_REACH
	for a in w.allies:
		if a.dead or a.kind != "summon" or a.max_hp <= 0.0 or a.spawn_t > 0.0:
			continue
		var d: float = e.pos.distance_to(a.pos) - a.radius
		var taunt: bool = SUMMONS.get(a.monster, {}).get("taunt", false)
		if d < bd and (taunt or d < dp):
			bd = d
			best = a
	if best == null:
		return false
	var def: Dictionary = w.Monsters.DEFS[e.kind]
	e.face = (best.pos - e.pos).angle()
	var reach: float = e.radius + best.radius + maxf(6.0, float(e.attack_range))
	if e.pos.distance_to(best.pos) > reach:
		w._move_toward(e, best.pos, w.chase_speed(e), dt)
		return true
	var cd: float = float(w.cl2.mob_cd.get(e.id, 0.0)) - dt
	if cd <= 0.0:
		cd = float(def.get("windup", 0.5)) + float(def.get("recover", 0.5))
		var dmg: float = maxf(1.0, round(Formulas.compute_damage(e.atk, w.stats.def, float(def.get("melee_mul", 1.0)))))
		damage_summon(w, best, dmg)
	w.cl2.mob_cd[e.id] = cd
	return true


static func damage_summon(w, a, dmg: float) -> void:
	if a.dead:
		return
	a.hp -= dmg
	a.hurt_t = SUMMON_HURT
	w._text(a.pos + Vector2(0, -a.radius - 12), "-%d" % int(dmg), Color("#c9b6ff"), false)
	if a.hp <= 0.0:
		a.dead = true
		w._blast(a.pos, a.radius + 10.0, a.color)
		w._text(a.pos + Vector2(0, -a.radius - 26), "%s gục" % str(SUMMONS.get(a.monster, {}).get("name", "Linh thú")), a.color, false)
		if a.perm:
			w.cl2.fox_ready = w.time + FOX_RESPAWN
		summon_gone(w, a)


## Linh thú gục / hết giờ: Vạn Linh Chi Chủ nổ linh hồn 5 m ×0,6.
static func summon_gone(w, a) -> void:
	if job3(w) != "van-linh":
		return
	w._blast(a.pos, VL_BOOM_R, Color("#f2f6ff"))
	var keep: String = w.skill_ctx
	w.skill_ctx = a.skill
	w.cl2.ally_hit = true
	for e in w.enemies:
		if not e.dead and e.pos.distance_to(a.pos) <= VL_BOOM_R + e.radius:
			w._hit_enemy(e, VL_BOOM, false, true)
	w.cl2.ally_hit = false
	w.skill_ctx = keep


static func _tick_summon_hp(w, dt: float) -> void:
	for a in w.allies:
		if a.dead or a.kind != "summon" or a.max_hp <= 0.0:
			continue
		a.hurt_t -= dt
		var regen := SUMMON_REGEN if a.hurt_t <= 0.0 else 0.0
		if job2(w) == "do-dang-su":
			for t in w.cl2.totems:
				if a.pos.distance_to(t.pos) <= DD_R:
					regen += DD_REGEN
					break
		if regen > 0.0:
			a.hp = minf(a.max_hp, a.hp + a.max_hp * regen * dt)


static func tick(w, dt: float) -> void:
	var st = w.cl2
	var p = w.player
	st.steel_t -= dt
	st.angel_t -= dt
	st.immune_t -= dt
	_tick_summon_hp(w, dt)
	# Phi Thuẫn: bay ra 30 m xuyên quái, rồi bay về tay; mỗi lượt trúng mỗi quái 1 lần.
	for s in st.shields:
		var step: float = PT_SPEED * dt
		if not s.back:
			s.pos += s.dir * step
			s.dist += step
			if s.dist >= PT_RANGE:
				s.back = true
				s.hit = {}
		else:
			var to_p: Vector2 = p.pos - s.pos
			if to_p.length() <= step + 10.0:
				s.done = true
				continue
			s.pos += to_p.normalized() * step
		w.skill_ctx = str(s.skill)
		for e in w.enemies:
			if not e.dead and not s.hit.has(e.id) and e.pos.distance_to(s.pos) <= PT_R + e.radius:
				s.hit[e.id] = true
				w._hit_enemy(e, float(s.mul), false, true)
		w.skill_ctx = ""
	st.shields = st.shields.filter(func(s): return not s.get("done", false) and p.dead_timer <= 0.0)
	# Phán Quyết: búa ánh sáng giáng xuống sau 0,35 giây.
	for m in st.slams:
		m.t -= dt
		if m.t > 0.0:
			continue
		w.skill_ctx = str(m.skill)
		w._blast(m.pos, float(m.r), Color("#ffe9a0"))
		w._sfx("explode")
		for e in w.enemies:
			if not e.dead and e.pos.distance_to(m.pos) <= float(m.r) + e.radius:
				w._hit_enemy(e, float(m.mul), false, true)
		w.skill_ctx = ""
	st.slams = st.slams.filter(func(m): return m.t > 0.0)
	# Triệu Hồi Sư
	st.link_t -= dt
	_ensure_foxes(w)
	var regen := false
	for t in st.totems:
		t.ttl -= dt
		t.acc += dt
		if p.pos.distance_to(t.pos) <= DD_R:
			regen = true
		if t.acc < TOTEM_GAP:
			continue
		t.acc -= TOTEM_GAP
		w.skill_ctx = str(t.skill)
		if t.kind == "loi":
			var e = w._nearest_enemy(t.pos, LDD_R)
			if e != null:
				var b = w.Bolt.new()
				b.points.append(t.pos + Vector2(0, -40))
				b.points.append(e.pos)
				w.bolts.append(b)
				w._hit_enemy(e, float(t.mul), false, true)
		else:
			for e in w.enemies:
				if not e.dead and e.pos.distance_to(t.pos) <= PDD_R + e.radius:
					w._hit_enemy(e, float(t.mul), false, true)
					e.slow_t = maxf(e.slow_t, 1.0)
		w.skill_ctx = ""
	st.totems = st.totems.filter(func(t): return t.ttl > 0.0)
	if regen and job2(w) == "do-dang-su" and p.dead_timer <= 0.0:
		p.hp = minf(float(w.stats.max_hp), p.hp + float(w.stats.max_hp) * DD_REGEN * dt)
		p.mp = minf(float(w.stats.max_mp), p.mp + float(w.stats.max_mp) * DD_REGEN * dt)
