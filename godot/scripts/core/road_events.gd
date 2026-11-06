extends RefCounted
## NV-E (docs/41): sự kiện trên đường — đi ngoài trời, mỗi ~5 phút 25% gặp 1 việc ngắn (1–2 phút) cạnh một bãi quái
## gần đó, có dấu "!" trên bản đồ nhỏ và mũi tên chỉ đường:
##   ambush   — đoàn buôn bị phục kích: hạ 5 tên cướp quanh xe hàng
##   survivor — người sống sót bị thương: tới chỗ người đó, rồi đưa về khu an toàn (người sống sót gia nhập lãnh địa)
##   chest    — rương bị canh: hạ 3 lính canh, rương tự mở
##   elite    — tinh anh đi lạc: hạ nó trong 90 giây trước khi nó bỏ đi
## Thưởng: ≈ 3% EXP lên cấp + vàng + 1 Đuốc. Hết 120 giây (tinh anh: 90) chưa xong → sự kiện tan. Trạng thái nằm ở
## GameWorld.road_event (không lưu save). Tắt khi field_spawn = false (test, hang, cổng).

const PERIOD := 300.0
const CHANCE := 0.25
const TTL := 120.0
const ELITE_TTL := 90.0
const NEAR := 70.0
const KINDS := ["ambush", "survivor", "chest", "elite"]
const NAMES := {"ambush": "Đoàn buôn bị phục kích", "survivor": "Người sống sót bị thương", "chest": "Rương bị canh",
	"elite": "Tinh anh đi lạc"}
const EXP_PCT := 0.03

static var _rng := RandomNumberGenerator.new()


static func _can_roll(w) -> bool:
	return w.field_spawn and not w.map.get("cave", false) and w.map.get("safe") != null and w.player.dead_timer <= 0.0 \
		and w.big_enemy() == null and not w.in_safe_zone() and not w.camps.is_empty()


static func tick(w, dt: float) -> void:
	var ev: Dictionary = w.road_event
	if not ev.is_empty():
		_tick_event(w, ev, dt)
		return
	if not _can_roll(w):
		return
	w.road_t -= dt
	if w.road_t > 0.0:
		return
	w.road_t = PERIOD
	if _rng.randf() < CHANCE:
		start(w, KINDS[_rng.randi() % KINDS.size()])


## Bắt đầu sự kiện kind cạnh bãi quái cách người chơi 400–1200 px (gần nhất trong dải).
static func start(w, kind: String) -> bool:
	var best := INF
	var at := Vector2.INF
	for c in w.camps:
		var d: float = c.pos.distance_to(w.player.pos)
		if d >= 400.0 and d <= 1200.0 and d < best:
			best = d
			at = c.pos
	if at == Vector2.INF:
		for c in w.camps:
			var d2: float = c.pos.distance_to(w.player.pos)
			if d2 < best:
				best = d2
				at = c.pos
	if at == Vector2.INF:
		return false
	at += Vector2(0, -70)
	var lv := int(w.map.levels[1]) if w.map.has("levels") else int(w.profile.level)
	var ev := {"kind": kind, "pos": at, "t": ELITE_TTL if kind == "elite" else TTL, "map": w.map_id, "stage": 0}
	var mob: String = w._pick_kind(lv)
	match kind:
		"ambush", "chest":
			var n := 5 if kind == "ambush" else 3
			for i in n:
				var e = w.spawn_enemy(mob, lv, at + Vector2.from_angle(TAU * i / n) * 90.0, {"role": "field", "elite": kind == "chest" and i == 0})
				e.set_meta("road", true)
				e.state = "chase" if kind == "ambush" else "idle"
		"elite":
			var e2 = w.spawn_enemy(mob, lv, at, {"role": "field", "elite": true})
			e2.set_meta("road", true)
	w.road_event = ev
	w._message("Sự kiện: %s — xem dấu ! trên bản đồ nhỏ." % NAMES[kind], "info")
	w._events.append({"type": "road_event", "kind": kind, "title": NAMES[kind]})
	return true


static func _alive(w) -> Array:
	return w.enemies.filter(func(e): return not e.dead and e.has_meta("road"))


static func _tick_event(w, ev: Dictionary, dt: float) -> void:
	ev.t = float(ev.t) - dt
	if w.map_id != str(ev.map) and str(ev.kind) != "survivor":
		_end(w, false)
		return
	match str(ev.kind):
		"ambush", "chest", "elite":
			if _alive(w).is_empty():
				_end(w, true)
				return
		"survivor":
			if int(ev.stage) == 0 and w.map_id == str(ev.map) and w.player.pos.distance_to(ev.pos) <= NEAR:
				ev.stage = 1
				ev.t = maxf(float(ev.t), 90.0)
				w._message("Người sống sót: \"Cảm ơn… đưa ta về khu an toàn với!\"", "info")
			elif int(ev.stage) == 1 and w.in_safe_zone():
				_end(w, true)
				return
	if float(ev.t) <= 0.0:
		_end(w, false)


static func _end(w, ok: bool) -> void:
	var ev: Dictionary = w.road_event
	w.road_event = {}
	for e in _alive(w):
		e.dead = true
	if not ok:
		w._message("Sự kiện \"%s\" đã kết thúc." % NAMES.get(str(ev.get("kind", "")), ""), "info")
		return
	var p = w.profile
	var xp := roundi(w.Formulas.exp_to_next(int(p.level)) * EXP_PCT)
	var gold := 20 * int(p.level)
	p.gold += gold
	p.torches = mini(w.Explore.torch_max(p), int(p.torches) + 1)
	var extra := ""
	if str(ev.kind) == "chest":
		p.stones += 2
		extra = ", +2 Đá Cường Hoá"
	elif str(ev.kind) == "survivor":
		extra = " — người sống sót gia nhập lãnh địa của bạn"
	w.add_exp(float(xp), false)
	w._message("Xong \"%s\": +%d EXP, +%d vàng, +1 Đuốc%s." % [NAMES[ev.kind], xp, gold, extra], "good")
	w._events.append({"type": "road_done", "kind": str(ev.kind)})


## Mục tiêu chỉ đường: chỗ sự kiện (người sống sót đã đi theo → khu an toàn).
static func target(w) -> Dictionary:
	var ev: Dictionary = w.road_event
	if ev.is_empty():
		return {}
	if str(ev.kind) == "survivor" and int(ev.stage) == 1:
		return {"pos": w.safe_pos, "label": "Khu an toàn (đưa người sống sót về)"}
	if w.map_id != str(ev.map):
		return {}
	var al := _alive(w)
	if not al.is_empty():
		return {"pos": al[0].pos, "label": NAMES[ev.kind]}
	return {"pos": ev.pos, "label": NAMES[ev.kind]}
