extends RefCounted
## NV-D (docs/41): Uỷ thác hằng ngày — 3 việc mỗi ngày (đổi lúc 0 giờ giờ máy), làm ở đâu cũng tính, **nhận thưởng ở khu
## an toàn** (Sổ nhiệm vụ → tab Uỷ thác). Mỗi việc: EXP ≈ 6% EXP lên cấp + 1 Đuốc + 10 Điểm Uỷ Thác; nhận đủ 3 việc:
## rương ngày (vàng, Đá Cường Hoá, Tinh Hoa) và +1 chuỗi ngày (bỏ 1 ngày không mất chuỗi); chuỗi 7 ngày: 1 món Tím
## theo lớp. Đổi được 1 việc / ngày. Điểm Uỷ Thác đổi đồ ở tab Uỷ thác.
## Trạng thái ở profile.daily (save v30): {day, tasks [{t, kind, need, n, claimed}], swapped, full, streak, last_full, points}.

const Maps = preload("res://scripts/data/maps.gd")
const Monsters = preload("res://scripts/data/monsters.gd")
const Formulas = preload("res://scripts/core/formulas.gd")
const Explore = preload("res://scripts/core/explore.gd")
const Items = preload("res://scripts/core/items.gd")
const Gear = preload("res://scripts/core/gear.gd")
const GearData = preload("res://scripts/data/gear_data.gd")

const PER_DAY := 3
const TASK_EXP := 0.06
const TASK_POINTS := 10
## Mẫu việc: [t, tên mẫu, need]. "hunt" = săn 1 loài quái của vùng; "gate" chỉ khi đã hạ Sói Chúa (cổng bắt đầu mở).
const TEMPLATES := [["hunt", "Săn quái", 15], ["elite", "Hạ tinh anh", 2], ["cave", "Dọn hang phụ", 1],
	["gate", "Dọn cổng dungeon", 1], ["herb", "Hái thảo dược", 6]]
const STREAK_GOAL := 7
## Cửa hàng Điểm Uỷ Thác: [id, tên, giá].
const SHOP := [["stones", "5 Đá Cường Hoá", 30], ["essence", "1 Thiên Phú Tinh Hoa", 60], ["purple", "1 món Tím theo lớp", 120]]


## Ngày (số ngày từ 1970, theo giờ máy). Test đặt w.debug_now → tính từ đó.
static func day_num(w) -> int:
	var unix: float = w.now_unix()
	var bias := 0
	if w.debug_now < 0.0:
		bias = int(Time.get_time_zone_from_system().get("bias", 0))
	return int(floor((unix + bias * 60.0) / 86400.0))


## Sang ngày mới → bốc 3 việc mới (giữ chuỗi, điểm).
static func ensure_day(w) -> void:
	var d: Dictionary = w.profile.daily
	var today := day_num(w)
	if int(d.get("day", -1)) == today and not (d.get("tasks", []) as Array).is_empty():
		return
	d["day"] = today
	d["swapped"] = false
	d["full"] = false
	d["tasks"] = _roll(w, today, [])
	for k in ["streak", "last_full", "points"]:
		if not d.has(k):
			d[k] = 0 if k != "last_full" else -99
	w.profile.daily = d


static func _templates(w) -> Array:
	return TEMPLATES.filter(func(t): return t[0] != "gate" or bool(w.profile.boss_defeated))


static func _roll(w, today: int, exclude: Array) -> Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("daily:%d:%s:%s" % [today, str(w.profile.name), str(w.profile.class_id)]) + exclude.size() * 7919
	var pool: Array = _templates(w).filter(func(t): return not (t[0] in exclude))
	var out: Array = []
	var n := PER_DAY - exclude.size() if exclude.size() < PER_DAY else 1
	while out.size() < n and not pool.is_empty():
		var t: Array = pool.pop_at(rng.randi() % pool.size())
		out.append(_task(w, t, rng))
	return out


static func _task(w, t: Array, rng: RandomNumberGenerator) -> Dictionary:
	var task := {"t": str(t[0]), "kind": "", "need": int(t[2]), "n": 0, "claimed": false, "region": int(w.map.get("region", 1))}
	if task.t == "hunt":
		task.kind = _hunt_kind(w, rng)
		if task.kind == "":
			task.t = "elite"
			task.need = 2
	return task


## Loài quái để săn: bảng quái của các map trong vùng đang đứng, hợp cấp người chơi.
static func _hunt_kind(w, rng: RandomNumberGenerator) -> String:
	var reg := int(w.map.get("region", 1))
	var lv := int(w.profile.level)
	var opts: Array = []
	for id in Maps.region(reg).maps:
		if not Maps.MAPS.has(id):
			continue
		var table = Maps.MAPS[id].get("mobs", "legacy")
		if table is Array:
			for row in table:
				if int(row[1]) <= lv + 3 and not (str(row[0]) in opts) and Monsters.DEFS.has(str(row[0])):
					opts.append(str(row[0]))
	if opts.is_empty():
		opts = ["wolf", "mushroom"] if reg == 1 else []
	return "" if opts.is_empty() else str(opts[rng.randi() % opts.size()])


static func tasks(w) -> Array:
	ensure_day(w)
	return w.profile.daily.tasks


static func task_title(t: Dictionary) -> String:
	match str(t.t):
		"hunt":
			return "Săn %d %s" % [int(t.need), str(Monsters.DEFS.get(str(t.kind), {}).get("name", t.kind))]
		"elite":
			return "Hạ %d tinh anh" % int(t.need)
		"cave":
			return "Dọn 1 hang phụ (hạ Chúa Hang)"
		"gate":
			return "Dọn 1 cổng dungeon (hạ Chúa Cổng)"
		"herb":
			return "Hái %d thảo dược" % int(t.need)
	return str(t.t)


static func task_hint(t: Dictionary) -> String:
	match str(t.t):
		"hunt":
			return "Quái ngoài đồng vùng %s." % Maps.region(int(t.get("region", 1))).name
		"elite":
			return "Tinh anh (bảng tên vàng) ở bãi quái, ổ quái, hang phụ."
		"cave":
			return "Cửa hang (cam) có ở mỗi map ngoài trời."
		"gate":
			return "Cổng dungeon hạng E → S mở ngẫu nhiên trên map đã tới (xem bản đồ lục địa, N)."
		"herb":
			return "Thảo dược mọc rải rác ngoài đồng."
	return ""


## Mục tiêu cho QuestLog (chỉ đường).
static func task_goal(t: Dictionary) -> Dictionary:
	match str(t.t):
		"hunt":
			return {"region": int(t.get("region", 1)), "kind": str(t.kind)}
		"elite":
			return {"elite": true}
		"cave":
			return {"portal": "cave"}
		"gate":
			return {"portal": "dgate"}
		"herb":
			return {"herb": true}
	return {}


static func done(t: Dictionary) -> bool:
	return int(t.n) >= int(t.need)


static func reward_exp(w) -> int:
	return roundi(Formulas.exp_to_next(int(w.profile.level)) * TASK_EXP)


# ---------------------------------------------------------------- tiến độ


static func _bump(w, pred: Callable, amount := 1) -> void:
	for t in tasks(w):
		if done(t) or not pred.call(t):
			continue
		t.n = mini(int(t.need), int(t.n) + amount)
		if done(t):
			w._message("Uỷ thác hoàn thành: %s — về khu an toàn, mở Sổ nhiệm vụ (O) để nhận thưởng." % task_title(t), "good")
			w._events.append({"type": "daily_done", "title": task_title(t)})


static func on_kill(w, e) -> void:
	if e.role in ["summon", "bossClone", "anchor"]:
		return
	_bump(w, func(t):
		match str(t.t):
			"hunt":
				return e.kind == str(t.kind)
			"elite":
				return e.elite and not e.cave_boss
			"cave":
				return e.cave_boss and not e.gate_boss
			"gate":
				return e.gate_boss
		return false)


static func on_herb(w, amount: int) -> void:
	_bump(w, func(t): return str(t.t) == "herb", amount)


# ---------------------------------------------------------------- nhận thưởng, đổi việc, cửa hàng


## Lý do không nhận được ("" = nhận được).
static func claim_blocker(w, i: int) -> String:
	var ts := tasks(w)
	if i < 0 or i >= ts.size():
		return "Không có uỷ thác này."
	if bool(ts[i].claimed):
		return "Đã nhận thưởng."
	if not done(ts[i]):
		return "Chưa xong."
	if not w.in_safe_zone():
		return "Về khu an toàn (làng / thành / trại) để nhận thưởng."
	return ""


static func claim(w, i: int) -> Dictionary:
	var why := claim_blocker(w, i)
	if why != "":
		return {"ok": false, "message": why}
	var p = w.profile
	var t: Dictionary = tasks(w)[i]
	t.claimed = true
	var xp := reward_exp(w)
	p.torches = mini(Explore.torch_max(p), int(p.torches) + 1)
	p.daily.points = int(p.daily.get("points", 0)) + TASK_POINTS
	w.add_exp(float(xp), false)
	var msg := "Nhận thưởng uỷ thác: +%d EXP, +1 Đuốc, +%d Điểm Uỷ Thác" % [xp, TASK_POINTS]
	if tasks(w).all(func(x): return bool(x.claimed)) and not bool(p.daily.get("full", false)):
		msg += ". " + _full_bonus(w)
	w._message(msg, "good")
	return {"ok": true, "message": msg}


## Đủ 3 việc trong ngày: rương ngày + chuỗi ngày (bỏ 1 ngày không mất chuỗi).
static func _full_bonus(w) -> String:
	var p = w.profile
	var d: Dictionary = p.daily
	d.full = true
	var gold := 50 * int(p.level)
	p.gold += gold
	p.stones += 3
	p.essence += 1
	var today := int(d.day)
	d.streak = int(d.get("streak", 0)) + 1 if today - int(d.get("last_full", -99)) <= 2 else 1
	d.last_full = today
	var txt := "Rương ngày: +%d vàng, +3 Đá Cường Hoá, +1 Thiên Phú Tinh Hoa · chuỗi %d/%d ngày" % [gold, int(d.streak), STREAK_GOAL]
	# NL-1 (docs/47 §3.A): rương ngày thêm 1 viên ngọc cấp 2 (khi đã mở Khảm ngọc).
	var gk := Gear.grant_random(p, GearData.GEM_DAILY_LV, w._loot_rng.randf)
	if gk != "":
		txt += ", +1 " + Gear.gem_name(gk)
	if int(d.streak) >= STREAK_GOAL:
		d.streak = 0
		txt += ". Chuỗi 7 ngày: " + _give_purple(w)
	return txt


static func _give_purple(w) -> String:
	var it: Dictionary = Items.new_item(w.profile, maxi(1, int(w.profile.level)), "purple", w._loot_rng.randf)
	return str(Items.add_item(w.profile, it).message)


static func can_swap(w, i: int) -> bool:
	var ts := tasks(w)
	return i >= 0 and i < ts.size() and not bool(w.profile.daily.get("swapped", false)) and not done(ts[i])


## Đổi 1 việc / ngày sang mẫu khác chưa có trong ngày.
static func swap(w, i: int) -> bool:
	if not can_swap(w, i):
		return false
	var ts := tasks(w)
	var have: Array = ts.map(func(t): return str(t.t))
	var fresh := _roll(w, int(w.profile.daily.day), have)
	if fresh.is_empty():
		return false
	ts[i] = fresh[0]
	w.profile.daily.swapped = true
	return true


static func buy(w, id: String) -> Dictionary:
	var p = w.profile
	var row: Array = []
	for r in SHOP:
		if r[0] == id:
			row = r
	if row.is_empty():
		return {"ok": false, "message": "Không có món này."}
	ensure_day(w)
	if int(p.daily.get("points", 0)) < int(row[2]):
		return {"ok": false, "message": "Thiếu Điểm Uỷ Thác (cần %d)." % int(row[2])}
	p.daily.points = int(p.daily.points) - int(row[2])
	var msg := "Đổi được " + str(row[1])
	match id:
		"stones":
			p.stones += 5
		"essence":
			p.essence += 1
		"purple":
			msg = _give_purple(w)
	w._message(msg, "good")
	return {"ok": true, "message": msg}


## Số việc đã xong mà chưa nhận thưởng.
static func unclaimed(w) -> int:
	return tasks(w).filter(func(t): return done(t) and not bool(t.claimed)).size()


# ================================================================ NV-C (docs/41): nhiệm vụ phụ theo NPC
## profile.side = {id: {step, n, state "active" | "reward" | "done"}}. Nhận: E cạnh NPC có "!" vàng. Xong bước cuối →
## "reward": về gặp người giao ("?" vàng), E → Sổ nhiệm vụ tab Phụ để chọn 1 trong 3 phần thưởng.

const SideQuests = preload("res://scripts/data/side_quests.gd")
const Caves = preload("res://scripts/core/caves.gd")


static func side_state(w, id: String) -> Dictionary:
	return w.profile.side.get(id, {})


static func side_available(w, q: Dictionary) -> bool:
	if not side_state(w, str(q.id)).is_empty():
		return false
	var u: Dictionary = q.unlock
	if int(w.profile.level) < int(u.get("level", 1)):
		return false
	if u.has("ch"):
		var ch := int(u.ch[0])
		var at := int(w.profile.quest_step) if ch == 1 else int(w.profile.quest.get("ch%d" % ch, 0))
		if at < int(u.ch[1]):
			return false
	if u.has("boss") and not w.is_boss_defeated(str(u.boss)):
		return false
	return true


## Chuỗi phụ NPC này đang có để nhận.
static func side_offers(w, npc_id: String) -> Array:
	return SideQuests.SIDE.filter(func(q): return str(q.giver) == npc_id and side_available(w, q))


## Chuỗi phụ đã xong, chờ trả ở NPC này.
static func side_turnins(w, npc_id: String) -> Array:
	return SideQuests.SIDE.filter(func(q): return str(q.giver) == npc_id and str(side_state(w, str(q.id)).get("state", "")) == "reward")


## Dấu trên đầu NPC: "?" (có việc chờ trả) · "!" (có việc mới) · "".
static func npc_mark(w, npc_id: String) -> String:
	if not side_turnins(w, npc_id).is_empty():
		return "?"
	if not side_offers(w, npc_id).is_empty():
		return "!"
	return ""


static func side_accept(w, id: String) -> bool:
	var q := SideQuests.by_id(id)
	if q.is_empty() or not side_available(w, q):
		return false
	w.profile.side[id] = {"step": 0, "n": 0, "state": "active"}
	w._message("Nhận nhiệm vụ phụ: %s — %s" % [q.title, q.steps[0].text], "good")
	w._events.append({"type": "side_accept", "id": id, "title": str(q.title)})
	# ghim ngay nếu còn chỗ
	if w.profile.tracked.size() < 2:
		w.profile.tracked.append("side:" + id)
	return true


## E cạnh NPC: trả việc trước, rồi nhận việc mới. {"action": "reward"|"accepted", "id"} hoặc {}.
static func on_talk(w, npc_id: String) -> Dictionary:
	var ti := side_turnins(w, npc_id)
	if not ti.is_empty():
		return {"action": "reward", "id": str(ti[0].id)}
	var of := side_offers(w, npc_id)
	if not of.is_empty() and side_accept(w, str(of[0].id)):
		return {"action": "accepted", "id": str(of[0].id)}
	return {}


static func _rare_map(kind: String) -> String:
	var rb: Dictionary = load("res://scripts/core/game_world.gd").RARE_BOSSES
	for m in rb:
		if str(rb[m].kind) == kind:
			return str(m)
	return ""


## Mục tiêu (cho QuestLog) của một bước.
static func step_goal(q: Dictionary, st: Dictionary) -> Dictionary:
	match str(st.type):
		"kill":
			return {"region": int(q.region), "kind": str(st.kind)}
		"elite":
			return {"elite": true}
		"herb":
			return {"herb": true}
		"cave":
			return {"map": str(st.map), "at": "cave"}
		"gate":
			return {"portal": "dgate"}
		"visit":
			return {"map": str(st.map), "at": "safe"}
		"rare":
			return {"map": _rare_map(str(st.kind)), "rare": str(st.kind)}
	return {}


## Bước đang làm của nhiệm vụ phụ id: {title, goal, n, need, done} ({} nếu không có / đã xong).
static func side_entry(w, id: String) -> Dictionary:
	var q := SideQuests.by_id(id)
	var s := side_state(w, id)
	if q.is_empty() or s.is_empty():
		return {}
	match str(s.state):
		"active":
			var st: Dictionary = q.steps[int(s.step)]
			return {"title": "%s: %s" % [q.title, st.text], "goal": step_goal(q, st), "n": int(s.n), "need": int(st.need), "done": false}
		"reward":
			return {"title": "%s: về gặp người giao nhận thưởng" % q.title, "goal": {"npc": str(q.giver)}, "n": 0, "need": 1, "done": false}
	return {}


static func _side_bump(w, pred: Callable, amount := 1) -> void:
	for id in w.profile.side:
		# "_main" = tiến độ NV-B (core/main_variants.gd), không phải nhiệm vụ phụ
		if str(id).begins_with("_"):
			continue
		var s: Dictionary = w.profile.side[id]
		if str(s.get("state", "")) != "active":
			continue
		var q := SideQuests.by_id(str(id))
		if q.is_empty():
			continue
		var st: Dictionary = q.steps[int(s.step)]
		if not pred.call(st):
			continue
		s.n = mini(int(st.need), int(s.n) + amount)
		if int(s.n) >= int(st.need):
			_side_next(w, q, s)


static func _side_next(w, q: Dictionary, s: Dictionary) -> void:
	s.step = int(s.step) + 1
	s.n = 0
	if int(s.step) >= q.steps.size():
		s.state = "reward"
		w._message("Nhiệm vụ phụ \"%s\" xong — về gặp người giao (dấu ? vàng) để chọn thưởng." % q.title, "good")
		w._events.append({"type": "side_ready", "id": str(q.id), "title": str(q.title)})
	else:
		w._message("%s: %s" % [q.title, q.steps[int(s.step)].text], "info")


static func side_on_kill(w, e) -> void:
	_side_bump(w, func(st):
		match str(st.type):
			"kill":
				return e.kind == str(st.kind) and not (e.role in ["summon", "bossClone"])
			"elite":
				return e.elite and not e.cave_boss
			"cave":
				return e.cave_boss and not e.gate_boss and Caves.parent(w.map_id) == str(st.map)
			"gate":
				return e.gate_boss
			"rare":
				return e.role == "rare" and e.kind == str(st.kind)
		return false)


static func side_on_herb(w, amount: int) -> void:
	_side_bump(w, func(st): return str(st.type) == "herb", amount)


## Bước "tới nơi": đứng trong khu an toàn của map đó.
static func side_tick(w) -> void:
	if w.profile.side.is_empty():
		return
	_side_bump(w, func(st): return str(st.type) == "visit" and str(st.map) == w.map_id and w.in_safe_zone())


## Chọn phần thưởng thứ k (0…2) của chuỗi đã xong.
static func side_claim(w, id: String, k: int) -> Dictionary:
	var q := SideQuests.by_id(id)
	var s := side_state(w, id)
	if q.is_empty() or str(s.get("state", "")) != "reward":
		return {"ok": false, "message": "Chưa có thưởng để nhận."}
	var r: Dictionary = q.reward
	var ch: Array = r.choices[clampi(k, 0, r.choices.size() - 1)]
	var p = w.profile
	var xp := roundi(Formulas.exp_to_next(int(p.level)) * float(r.exp))
	var lv := int(p.level)
	var got := str(ch[0])
	match str(ch[1]):
		"item":
			var it: Dictionary = Items.new_item(p, maxi(1, lv), "purple" if int(ch[2]) >= 2 else "blue", w._loot_rng.randf)
			got = str(Items.add_item(p, it).message)
		"potions":
			p.potions = int(p.potions) + int(ch[2])
		"mp_potions":
			p.mp_potions = int(p.mp_potions) + int(ch[2])
		"stones":
			p.stones += int(ch[2])
		"gold":
			p.gold += float(int(ch[2]) * lv)
			got = "%d vàng" % (int(ch[2]) * lv)
		"essence":
			p.essence += int(ch[2])
		"torches":
			p.torches = mini(Explore.torch_max(p), int(p.torches) + int(ch[2]))
	s.state = "done"
	p.tracked.erase("side:" + id)
	var msg := "Hoàn thành nhiệm vụ phụ \"%s\": +%d EXP, %s" % [q.title, xp, got]
	if r.has("title") and not (str(r.title) in p.titles):
		p.titles.append(str(r.title))
		if str(p.title) == "":
			p.title = str(r.title)
		msg += ", danh hiệu \"%s\"" % r.title
	w.add_exp(float(xp), false)
	w._message(msg, "good")
	w._events.append({"type": "side_done", "id": id, "title": str(q.title)})
	return {"ok": true, "message": msg}
