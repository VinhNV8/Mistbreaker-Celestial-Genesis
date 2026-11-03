extends RefCounted
## M12.4 — Endgame tối thiểu (docs/18 mục 6, C9-50…53). Module của Chapters (D38).
## - Cấp sau 100 (Thần Vực N / Khai Thế N): mở khi đã chọn kết thúc; EXP ở cấp 100 (profile.xp) chuyển dần thành cấp mới;
##   mỗi cấp +1 Điểm Thiên Đạo vào 5 nhánh; tẩy điểm miễn phí ở vùng an toàn.
## - Thần Vực (Hợp nhất): tháp thử luyện vô tận ở Thiên Thê Đài I — 90 giây mỗi tầng, cấp quái 100 + 2 × tầng, cứ 5 tầng 1 Thần Tướng.
## - Tái Thiết Lục Địa (Hiến tế): 9 công trình (Explore.BUILDINGS rebuild1…9) + buff vĩnh viễn + Triều Hư Vô tàn dư mỗi 30 phút.

const Explore = preload("res://scripts/core/explore.gd")
const Formulas = preload("res://scripts/core/formulas.gd")
const ItemData = preload("res://scripts/data/items.gd")

const MAPS := []
const NPCS := ["than-vuc"]
const HOOKS := ["on_load", "tick", "derive_bonus", "heal_mult", "talk", "env_text", "on_kill", "after_exp"]

const MAX_LEVEL := 100
## C9-50: mỗi điểm — Tấn công +0,5% · HP +0,8% · Chí mạng +0,2% · Hồi chiêu −0,3% (trần −15%) · Sản lượng lãnh địa +1%.
const BRANCHES := {"atk": 0.005, "hp": 0.008, "crit": 0.002, "cd": 0.003, "terr": 0.01}
const BRANCH_NAMES := {"atk": "Tấn công", "hp": "HP", "crit": "Chí mạng", "cd": "Hồi chiêu kỹ năng", "terr": "Sản lượng lãnh địa"}
const CD_CAP := 0.15
# ---------------------------------------------------------------- Thần Vực
const TOWER_TIME := 90.0
const TOWER_R := 300.0
const TOWER_OFFSET := Vector2(700, 0)
const TOWER_NEXT := 3.0
const TOWER_HEAL := 0.30
const TOWER_KINDS := ["thien-binh", "tan-hon", "thien-ma", "linh-thu-ngu-hanh"]
## TL-B9b (01/11): cấp quái 100 + 2·tầng tăng quá chậm (bot leo 44–118 tầng) → thêm hệ số mỗi tầng (luỹ thừa) cho HP và
## Tấn công quái tháp, để người chơi cấp 100 chưa có Điểm Thiên Đạo dừng ở tầng 10–20.
const TOWER_HP_GROWTH := 1.14
const TOWER_ATK_GROWTH := 1.05
## Thần Tướng (cứ 5 tầng): HP × TOWER_GUARD_HP (spec ×8; TL-B9b: ×8 thành bức tường hết giờ với Triệu Hồi Sư).
const TOWER_GUARD_HP := 3.0
# ---------------------------------------------------------------- Tái Thiết
const REBUILD_NAMES := {1: "Tháp Sương Tan", 2: "Phong Đài", 3: "Giếng Sa Mạc", 4: "Vườn Mộng", 5: "Lò Rèn Viêm Long", 6: "Đài Cực Quang",
	7: "Cảng Thiên Không", 8: "Đèn Tinh Quang Vĩnh Cửu", 9: "Đền Thiên Đạo"}
const REBUILD_TEXT := {1: "+10% EXP", 2: "+10% tốc chạy", 3: "+1 Đuốc tối đa, Đuốc hồi nhanh 20%", 4: "Bình máu hồi +20%",
	5: "Cường hoá +5% tỉ lệ thành công", 6: "+10% vàng", 7: "Đi đường qua cổng nhanh 50%", 8: "+10% tỉ lệ rơi Bí Kíp", 9: "+5% HP và Tấn công"}
const REBUILD_CORES := 2
const RAID_EVERY := 1800.0
const RAID_LIMIT := 120.0
const RAID_OFF := 1800.0
const RAID_MOBS := 8


class State:
	var tower := false
	var floor := 0
	var tower_t := 0.0
	var next_t := 0.0
	var center := Vector2.ZERO
	var ids: Array = []
	var spawn_was := true
	## Triều tàn dư: {} hoặc {region, t, ids}
	var raid := {}


static func ending(w) -> String:
	return str(w.profile.ending)


# ================================================================ cấp sau 100 (C9-50)


static func divine_title(w) -> String:
	if int(w.profile.divine_level) <= 0:
		return ""
	return ("Thần Vực %d" if ending(w) == "hop-nhat" else "Khai Thế %d") % int(w.profile.divine_level)


## EXP cho cấp sau 100 thứ N+1: EXP(100) × (1 + 0,02·N).
static func divine_need(n: int) -> int:
	return roundi(float(Formulas.exp_to_next(MAX_LEVEL - 1)) * (1.0 + 0.02 * n))


## Sau mỗi lần cộng EXP: ở cấp 100 và đã chọn kết thúc thì EXP tích luỹ (profile.xp) chuyển thành cấp sau 100.
static func after_exp(w) -> void:
	var p = w.profile
	if int(p.level) < MAX_LEVEL or ending(w) == "":
		return
	var up := 0
	while int(p.xp) >= divine_need(int(p.divine_level)):
		p.xp = int(p.xp) - divine_need(int(p.divine_level))
		p.divine_level = int(p.divine_level) + 1
		up += 1
	if up > 0:
		w._message("%s! +%d Điểm Thiên Đạo (nói chuyện với Vân Hạc ở Thiên Thê Đài I)." % [divine_title(w), up], "good")
		w._events.append({"type": "levelup", "level": int(p.level), "growth": divine_title(w)})


static func spent(w) -> int:
	var n := 0
	for k in w.profile.divine_points:
		n += int(w.profile.divine_points[k])
	return n


static func unspent(w) -> int:
	return int(w.profile.divine_level) - spent(w)


static func allocate(w, branch: String) -> Dictionary:
	if not BRANCHES.has(branch):
		return {"ok": false, "message": "Không có nhánh này."}
	if unspent(w) <= 0:
		return {"ok": false, "message": "Không còn Điểm Thiên Đạo."}
	if branch == "cd" and float(w.profile.divine_points.get("cd", 0)) * BRANCHES.cd >= CD_CAP - 0.0001:
		return {"ok": false, "message": "Hồi chiêu đã tới trần −15%."}
	w.profile.divine_points[branch] = int(w.profile.divine_points.get(branch, 0)) + 1
	w._refresh_stats()
	return {"ok": true, "message": "+1 %s" % BRANCH_NAMES[branch]}


static func respec(w) -> Dictionary:
	if not w.in_safe_zone():
		return {"ok": false, "message": "Tẩy Điểm Thiên Đạo ở vùng an toàn."}
	w.profile.divine_points = {}
	w._refresh_stats()
	return {"ok": true, "message": "Đã tẩy Điểm Thiên Đạo."}


static func points(w, branch: String) -> int:
	return int(w.profile.divine_points.get(branch, 0))


## Hồi chiêu kỹ năng (GameWorld.skill_cd_of): −0,3% mỗi điểm nhánh Hồi chiêu, trần −15%.
static func skill_cd_mult(w) -> float:
	return 1.0 - minf(CD_CAP, points(w, "cd") * BRANCHES.cd)


## Sản lượng lãnh địa cộng thêm (Explore.production_per_minute): Điểm Thiên Đạo + Hiến tế +30%.
static func territory_bonus(p) -> float:
	return int(p.divine_points.get("terr", 0)) * BRANCHES.terr + (0.3 if str(p.ending) == "hien-te" else 0.0)


static func derive_bonus(w, bonus: Dictionary) -> void:
	bonus.atk_pct += points(w, "atk") * BRANCHES.atk
	bonus.max_hp_pct += points(w, "hp") * BRANCHES.hp
	bonus.flat["crit"] = float(bonus.flat.get("crit", 0.0)) + points(w, "crit") * BRANCHES.crit
	if rebuilt(w.profile, 9):
		bonus.atk_pct += 0.05
		bonus.max_hp_pct += 0.05
	if rebuilt(w.profile, 2):
		bonus.move_pct = float(bonus.get("move_pct", 0.0)) + 0.10


# ================================================================ Tái Thiết Lục Địa (C9-52)


## Công trình vùng k đã xây xong và buff đang bật (Triều tàn dư thua → tắt 30 phút).
static func rebuilt(p, k: int) -> bool:
	if not Explore.is_built(p, "rebuild%d" % k):
		return false
	return float(p.rebuild_raid.get(str(k), 0.0)) <= float(p.play_seconds)


static func rebuilt_count(p) -> int:
	var n := 0
	for k in range(1, 10):
		if Explore.is_built(p, "rebuild%d" % k):
			n += 1
	return n


static func exp_mult(p) -> float:
	return 1.1 if rebuilt(p, 1) else 1.0


static func heal_mult(_w) -> float:
	return 1.0


static func potion_mult(p) -> float:
	return 1.2 if rebuilt(p, 4) else 1.0


static func enhance_bonus(p) -> float:
	return 0.05 if rebuilt(p, 5) else 0.0


static func gold_mult(p) -> float:
	return 1.1 if rebuilt(p, 6) else 1.0


static func travel_mult(p) -> float:
	return 0.5 if rebuilt(p, 7) else 1.0


static func book_mult(p) -> float:
	return 1.1 if rebuilt(p, 8) else 1.0


static func torch_bonus(p) -> int:
	return 1 if rebuilt(p, 3) else 0


static func torch_regen_mult(p) -> float:
	return 0.8 if rebuilt(p, 3) else 1.0


# ================================================================ khung hình


static func on_load(w) -> void:
	var st = w.eg
	if st.tower:
		_end_tower(w, false)
	st.raid = {}


static func tick(w, dt: float) -> void:
	_tick_tower(w, dt)
	_tick_raid(w, dt)


static func talk(w, npc_id: String) -> String:
	if npc_id != "than-vuc":
		return ""
	if ending(w) != "hop-nhat":
		w._force_say("than_vuc_locked")
		return ""
	if w.eg.tower:
		return ""
	start_tower(w)
	return ""


# ---------------------------------------------------------------- Thần Vực (C9-51)


static func start_tower(w) -> void:
	var st = w.eg
	st.tower = true
	st.floor = 0
	st.center = w.safe_pos + TOWER_OFFSET
	st.spawn_was = w.field_spawn
	w.field_spawn = false
	for e in w.enemies:
		if not e.dead and e.role == "field" and e.pos.distance_to(st.center) < TOWER_R + 400.0:
			e.dead = true
	w.player.pos = st.center
	w._message("Thần Vực: mỗi tầng 90 giây — hạ hết quái để lên tầng kế. Kỷ lục: tầng %d." % int(w.profile.tower_best), "info")
	_next_floor(w)


static func _next_floor(w) -> void:
	var st = w.eg
	st.floor += 1
	st.tower_t = TOWER_TIME
	st.ids = []
	var lv: int = MAX_LEVEL + 2 * st.floor
	var n: int = mini(14, 6 + st.floor / 2)
	for i in n:
		var kind: String = TOWER_KINDS[i % TOWER_KINDS.size()]
		var e = w.spawn_enemy(kind, lv, st.center + Vector2.from_angle(i * TAU / n) * (TOWER_R - 60.0), {"role": "pack"})
		_tower_scale(e, st.floor)
		e.state = "chase"
		st.ids.append(e.id)
	if st.floor % 5 == 0:
		var g = w.spawn_enemy("thien-binh", lv, st.center + Vector2(0, -TOWER_R + 80.0), {"role": "pack", "elite": true})
		g.name = "Thần Tướng"
		_tower_scale(g, st.floor)
		g.max_hp *= TOWER_GUARD_HP
		g.hp = g.max_hp
		g.state = "chase"
		st.ids.append(g.id)
	w._text(w.player.pos + Vector2(0, -60), "Thần Vực · Tầng %d" % st.floor, Color("#fff0b0"), true)


## TL-B9b: quái tầng f mạnh thêm TOWER_HP_GROWTH^f (HP) và TOWER_ATK_GROWTH^f (Tấn công).
static func _tower_scale(e, f: int) -> void:
	e.max_hp *= pow(TOWER_HP_GROWTH, f)
	e.hp = e.max_hp
	e.atk *= pow(TOWER_ATK_GROWTH, f)


static func _tick_tower(w, dt: float) -> void:
	var st = w.eg
	if not st.tower:
		return
	var p = w.player
	if p.dead_timer > 0.0 or w.map_id != "9-1":
		_end_tower(w, false)
		return
	var off: Vector2 = p.pos - st.center
	if off.length() > TOWER_R:
		p.pos = st.center + off.normalized() * TOWER_R
	if st.next_t > 0.0:
		st.next_t -= dt
		if st.next_t <= 0.0:
			_next_floor(w)
		return
	st.tower_t -= dt
	var alive := 0
	for e in w.enemies:
		if not e.dead and e.id in st.ids:
			alive += 1
	if alive == 0:
		var pr = w.profile
		pr.tower_best = maxi(int(pr.tower_best), st.floor)
		var ess: int = st.floor / 5 + 1
		pr.essence = int(pr.essence) + ess
		p.hp = minf(float(w.stats.max_hp), p.hp + float(w.stats.max_hp) * TOWER_HEAL)
		var msg := "Thần Vực tầng %d xong: +%d Thiên Phú Tinh Hoa" % [st.floor, ess]
		if st.floor % 10 == 0:
			var keys: Array = ItemData.UNIQUES.keys()
			w._drop_item(p.pos + Vector2(30, 0), MAX_LEVEL, "orange", str(keys[(st.floor / 10) % keys.size()]))
			msg += ", 1 đồ Cam"
		w._message(msg + ".", "good")
		st.next_t = TOWER_NEXT
		return
	if st.tower_t <= 0.0:
		_end_tower(w, false)


static func _end_tower(w, _won: bool) -> void:
	var st = w.eg
	if not st.tower:
		return
	st.tower = false
	for e in w.enemies:
		if e.id in st.ids:
			e.dead = true
	w.field_spawn = st.spawn_was
	var best: int = maxi(int(w.profile.tower_best), st.floor - 1)
	w.profile.tower_best = best
	w._message("Rời Thần Vực ở tầng %d. Kỷ lục: tầng %d." % [st.floor, best], "info")


# ---------------------------------------------------------------- Triều Hư Vô tàn dư (C9-52)


static func _tick_raid(w, dt: float) -> void:
	var st = w.eg
	var p = w.profile
	var k: int = int(w.map.get("region", 1))
	if w.in_cave() or not Explore.is_built(p, "rebuild%d" % k):
		if not st.raid.is_empty():
			_lose_raid(w)
		return
	if st.raid.is_empty():
		var key := str(k)
		var t: float = float(p.rebuild_raid.get("t" + key, 0.0)) + dt
		p.rebuild_raid["t" + key] = t
		if t < RAID_EVERY:
			return
		p.rebuild_raid["t" + key] = 0.0
		st.raid = {"region": k, "t": 0.0, "ids": []}
		var at: Vector2 = w.safe_pos + Vector2(w.safe_r + 260.0, 0)
		for i in RAID_MOBS:
			var e = w.spawn_enemy(w._pick_kind(MAX_LEVEL), MAX_LEVEL, at + Vector2.from_angle(i * TAU / RAID_MOBS) * 120.0, {"role": "pack"})
			e.state = "chase"
			st.raid.ids.append(e.id)
		w._message("Triều Hư Vô tàn dư đánh vào %s! Giữ trong 120 giây." % str(REBUILD_NAMES.get(k, "công trình")), "bad")
		return
	st.raid.t = float(st.raid.t) + dt
	var alive := 0
	for e in w.enemies:
		if not e.dead and e.id in st.raid.ids:
			alive += 1
	if alive == 0:
		p.essence = int(p.essence) + 2
		p.crystal = float(p.crystal) + 10.0
		w._message("Đẩy lùi Triều tàn dư: +2 Thiên Phú Tinh Hoa, +10 Tinh Thạch.", "good")
		st.raid = {}
	elif float(st.raid.t) >= RAID_LIMIT:
		_lose_raid(w)


static func _lose_raid(w) -> void:
	var st = w.eg
	var k := int(st.raid.get("region", 0))
	w.profile.rebuild_raid[str(k)] = float(w.profile.play_seconds) + RAID_OFF
	w._message("Triều tàn dư phá %s — buff tắt 30 phút." % str(REBUILD_NAMES.get(k, "công trình")), "bad")
	st.raid = {}


static func on_kill(_w, _e) -> void:
	pass


static func env_text(w) -> String:
	var st = w.eg
	var parts := PackedStringArray()
	if st.tower:
		parts.append(("Thần Vực · tầng %d · %d giây" % [st.floor, ceili(st.tower_t)]) if st.next_t <= 0.0 else "Thần Vực · tầng %d xong!" % st.floor)
	if not st.raid.is_empty():
		parts.append("Triều tàn dư · %d giây" % ceili(RAID_LIMIT - float(st.raid.t)))
	return "   ·   ".join(parts)
