extends RefCounted
## BD-11 / KP-10 / NV-23 (docs/34): Dungeon cổng ngẫu nhiên hạng E → S.
## Cổng mở ngẫu nhiên trên map ngoài trời đã đặt chân (profile.unlocked_maps), tồn tại LIFE giây chơi (2 giờ),
## tối đa MAX_OPEN cổng cùng lúc, mỗi map 1 cổng. Dọn sương một ô khai phá có FOG_CHANCE (7%, kịch bản mục 7)
## lộ ra Cổng dungeon trên map đang đứng. Bước vào cổng → bản đồ trong cổng (dùng chung khung hang phụ
## core/caves.gd: không sương, không quái ngoài đồng, cổng ra; id `gate-<hạng>-<map cha>` để Maps.get_map dựng được từ id) — 3 khu quái theo hạng + Chúa Cổng. Hạ Chúa Cổng →
## thưởng EXP / vàng / đồ theo hạng, cổng đóng. Hết giờ khi đang ở trong: đánh tiếp được, ra thì cổng mất.
## Lưu: profile.gates {map cha: {"rank", "until" (giây chơi), "x", "y"}} (save v29).

const Maps = preload("res://scripts/data/maps.gd")
const Monsters = preload("res://scripts/data/monsters.gd")
const ItemData = preload("res://scripts/data/items.gd")
const Gear = preload("res://scripts/core/gear.gd")
const GearData = preload("res://scripts/data/gear_data.gd")
const Formulas = preload("res://scripts/core/formulas.gd")

const PREFIX := "gate-"
const LIFE := 7200.0
const MAX_OPEN := 2
## Mỗi ROLL_EVERY giây chơi: ROLL_CHANCE mở 1 cổng mới (nếu còn chỗ) trên 1 map ngẫu nhiên đã đặt chân.
const ROLL_EVERY := 300.0
const ROLL_CHANCE := 0.5
## Cổng chỉ bắt đầu mở sau khi hạ Sói Chúa (chương 1 — lúc đó người chơi đã quen hang phụ).
const MIN_LEVEL := 6
const FOG_CHANCE := 0.07
const RANKS := ["E", "D", "C", "B", "A", "S"]
const WEIGHT := {"E": 40, "D": 28, "C": 18, "B": 9, "A": 4, "S": 1}
## Theo hạng: lệch cấp so với cấp cao nhất của map cha, HP ×, Tấn công ×, số quái thêm mỗi khu, HP Chúa Cổng ×,
## EXP thưởng (× EXP 1 quái tinh anh cùng cấp), vàng ×, Thiên Phú Tinh Hoa, đồ rơi.
const RANK := {
	"E": {"lv": -3, "hp": 1.0, "atk": 1.0, "extra": 0, "boss": 4.0, "exp": 10, "gold": 1.0, "ess": 0, "items": ["blue"]},
	"D": {"lv": -1, "hp": 1.1, "atk": 1.05, "extra": 1, "boss": 5.0, "exp": 15, "gold": 1.5, "ess": 0, "items": ["blue", "blue"]},
	"C": {"lv": 1, "hp": 1.25, "atk": 1.12, "extra": 1, "boss": 6.0, "exp": 22, "gold": 2.0, "ess": 1, "items": ["purple"]},
	"B": {"lv": 3, "hp": 1.45, "atk": 1.2, "extra": 2, "boss": 7.0, "exp": 32, "gold": 3.0, "ess": 1, "items": ["purple", "blue"]},
	"A": {"lv": 5, "hp": 1.7, "atk": 1.3, "extra": 2, "boss": 8.0, "exp": 45, "gold": 4.0, "ess": 2, "items": ["purple", "purple"]},
	"S": {"lv": 8, "hp": 2.0, "atk": 1.45, "extra": 3, "boss": 10.0, "exp": 65, "gold": 6.0, "ess": 3, "items": ["orange", "purple"]},
}
const COLORS := {"E": Color("#9aa4ad"), "D": Color("#5bd16a"), "C": Color("#4aa8ff"), "B": Color("#b46bff"), "A": Color("#ffb020"), "S": Color("#ff4d4d")}
## Khu quái: [tâm x, số quái thường, số tinh anh] (như hang phụ); khu cuối có Chúa Cổng.
const ZONES := [[900.0, 4, 1], [1600.0, 5, 1], [2250.0, 2, 1]]
const BOSS_X := 2300.0
const BOSS_ATK := 1.3
const BOSS_SIZE := 1.5
## Khoảng cách tối thiểu từ cổng tới vùng an toàn / cổng khác khi chọn chỗ đặt.
const KEEP_OUT := 260.0

static var _cache := {}


static func is_gate(id: String) -> bool:
	return id.begins_with(PREFIX)


static func gate_id(parent_id: String, rank: String) -> String:
	return "%s%s-%s" % [PREFIX, rank, parent_id]


static func parent(id: String) -> String:
	return id.substr(PREFIX.length() + 2) if is_gate(id) else id


static func rank_in(id: String) -> String:
	return id.substr(PREFIX.length(), 1) if is_gate(id) else ""


static func rank_of(p, parent_id: String) -> String:
	return str(p.gates.get(parent_id, {}).get("rank", ""))


## Giây chơi còn lại của cổng trên map cha (0 = không có / đã hết).
static func left(p, parent_id: String) -> float:
	if not p.gates.has(parent_id):
		return 0.0
	return maxf(0.0, float(p.gates[parent_id].until) - float(p.play_seconds))


static func level_range(parent_id: String, rank: String) -> Array:
	var pm: Dictionary = Maps.MAPS.get(parent_id, Maps.MAPS["1-1"])
	var lv := clampi(int(pm.levels[1]) + int(RANK[rank].lv), 1, 110)
	return [lv, lv + 1]


## Bản đồ trong cổng (cùng khoá với map thường / hang để GameWorld, world_view dùng chung). Cache theo id + hạng.
static func build_map(id: String) -> Dictionary:
	if _cache.has(id):
		return _cache[id]
	var rank := rank_in(id)
	if not RANK.has(rank):
		rank = "E"
	var pid := parent(id)
	var pm: Dictionary = Maps.MAPS.get(pid, Maps.MAPS["1-1"])
	var cave: Vector2 = load("res://scripts/core/caves.gd").SIZE
	var m := {
		"region": int(pm.get("region", 1)),
		"name": "Cổng hạng %s · %s" % [rank, str(pm.name)],
		"size": cave,
		"levels": level_range(pid, rank),
		"zone_x": [2100.0, 400.0],
		"safe": {"pos": Vector2(200, 550), "r": 90.0, "name": "Lối vào cổng", "kind": "cave"},
		"arena": null,
		"gate": false,
		"mobs": pm.get("mobs", "legacy"),
		"ground": pm.get("ground", "tile-grass-0"),
		"fog": 0.7,
		"tint": COLORS[rank].darkened(0.85),
		"wind": 0.0,
		"trees": 0,
		"decor": "cave",
		"cave": true,
		"parent": pid,
		"gate_rank": rank,
	}
	_cache[id] = m
	return m


## Lý do không vào được cổng; "" nếu được.
static func blocker(w, id: String) -> String:
	var pid := parent(id)
	if not Maps.MAPS.has(pid) or left(w.profile, pid) <= 0.0:
		return "Cổng đã đóng."
	if w.map_id == id:
		return "Bạn đang ở trong cổng."
	if rank_of(w.profile, pid) != rank_in(id):
		return "Cổng đã đóng."
	return ""


## Cổng đặt trên map cha (thêm vào w.portals lúc nạp map / lúc cổng mở trên map đang đứng).
static func portal_of(p, parent_id: String) -> Dictionary:
	var g: Dictionary = p.gates.get(parent_id, {})
	if g.is_empty():
		return {}
	return {"kind": "dgate", "to": gate_id(parent_id, str(g.rank)), "pos": Vector2(float(g.x), float(g.y)), "rank": str(g.rank)}


static func roll_rank(rng: RandomNumberGenerator) -> String:
	var total := 0
	for r in RANKS:
		total += int(WEIGHT[r])
	var x := rng.randi_range(1, total)
	for r in RANKS:
		x -= int(WEIGHT[r])
		if x <= 0:
			return r
	return "E"


## Chỗ đặt cổng trên map cha: điểm ngẫu nhiên trên đất đi được, xa vùng an toàn, hang boss và các cổng khác.
static func _place(w, parent_id: String, rng: RandomNumberGenerator) -> Vector2:
	var m: Dictionary = Maps.get_map(parent_id)
	var size: Vector2 = m.size
	var blocks: Array = [m.safe.pos]
	for pt in load("res://scripts/core/portals.gd").list(parent_id):
		blocks.append(pt.pos)
	var best := Vector2(size.x * 0.5, size.y * 0.5)
	var best_d := -1.0
	for i in 24:
		var c := Vector2(size.x * (0.15 + 0.7 * rng.randf()), size.y * (0.2 + 0.6 * rng.randf()))
		if m.arena != null and c.distance_to(m.arena.pos) < float(m.arena.r) + KEEP_OUT:
			continue
		if not _on_land(m, c):
			continue
		var dmin := INF
		for b in blocks:
			dmin = minf(dmin, c.distance_to(b))
		if dmin >= KEEP_OUT * 2.0:
			return c
		if dmin > best_d:
			best_d = dmin
			best = c
	return best


## Map đảo bay (chương 7): cổng phải nằm trên đảo.
static func _on_land(m: Dictionary, c: Vector2) -> bool:
	var isl: Array = m.get("islands", [])
	if isl.is_empty():
		return true
	for it in isl:
		if c.distance_to(it[0]) <= float(it[1]) - 80.0:
			return true
	return false


## Mở 1 cổng hạng rank (rỗng = quay) trên map cha; trả về hạng ("" nếu không mở được).
static func open_gate(w, parent_id: String, rng: RandomNumberGenerator, rank := "") -> String:
	var p = w.profile
	if not Maps.MAPS.has(parent_id) or p.gates.has(parent_id):
		return ""
	var r := rank if rank != "" else roll_rank(rng)
	var pos := _place(w, parent_id, rng)
	p.gates[parent_id] = {"rank": r, "until": float(p.play_seconds) + LIFE, "x": pos.x, "y": pos.y}
	if w.map_id == parent_id:
		w.portals.append(portal_of(p, parent_id))
	var lv: Array = level_range(parent_id, r)
	w._message("Cổng dungeon hạng %s mở ở %s (cấp %d) — tồn tại 2 giờ chơi." % [r, str(Maps.MAPS[parent_id].name), int(lv[0])], "good")
	w._events.append({"type": "gate_open", "map_id": parent_id, "rank": r})
	return r


## Gọi mỗi khung hình (GameWorld.update): cổng hết giờ thì đóng; tới lượt quay thì có thể mở cổng mới.
static func tick(w, dt: float) -> void:
	var p = w.profile
	for pid in p.gates.keys():
		if left(p, pid) <= 0.0 and not (is_gate(w.map_id) and parent(w.map_id) == pid):
			p.gates.erase(pid)
			if w.map_id == pid:
				w.portals = w.portals.filter(func(pt): return str(pt.get("kind", "")) != "dgate")
				w.portal_inside = -1
				w._message("Cổng dungeon ở đây đã đóng.", "info")
	if int(p.level) < MIN_LEVEL:
		return
	w._gate_clock += dt
	if w._gate_clock < ROLL_EVERY:
		return
	w._gate_clock = 0.0
	if p.gates.size() >= MAX_OPEN or w._gate_rng.randf() >= ROLL_CHANCE:
		return
	var cands: Array = []
	for id in p.unlocked_maps:
		if Maps.MAPS.has(str(id)) and not p.gates.has(str(id)):
			cands.append(str(id))
	if cands.is_empty():
		return
	open_gate(w, str(cands[w._gate_rng.randi() % cands.size()]), w._gate_rng)


## KP-10: dọn sương 1 ô khai phá → FOG_CHANCE lộ Cổng dungeon trên map ngoài trời đang đứng.
static func on_reveal(w) -> void:
	var p = w.profile
	if w.in_cave() or not Maps.MAPS.has(w.map_id) or p.gates.has(w.map_id) or p.gates.size() >= MAX_OPEN + 1:
		return
	if w._gate_rng.randf() < FOG_CHANCE:
		open_gate(w, w.map_id, w._gate_rng)


## Sinh quái 3 khu + Chúa Cổng khi vào cổng (gọi cuối _load_map, thay cho Caves.populate).
static func populate(w) -> void:
	var rank := str(w.map.get("gate_rank", "E"))
	var rd: Dictionary = RANK[rank]
	var lv := int(w.map.levels[0])
	var size: Vector2 = w.map.size
	for z in ZONES:
		var cx: float = z[0]
		var zl := lv + (1 if cx >= 2100.0 else 0)
		for i in int(z[1]) + int(rd.extra):
			_buff(_spawn(w, w._pick_kind(zl), zl, _zone_pos(w, cx, size), false), rd)
		for i in int(z[2]):
			var ek: String = w._elite_kind(zl)
			_buff(_spawn(w, ek if ek != "" else w._pick_kind(zl), zl, _zone_pos(w, cx, size), ek != ""), rd)
	var bk: String = w._elite_kind(lv + 1)
	var boss = _spawn(w, bk if bk != "" else w._pick_kind(lv + 1), lv + 1, Vector2(BOSS_X, size.y / 2.0), true)
	_buff(boss, rd)
	boss.cave_boss = true
	boss.gate_boss = true
	boss.name = str(Monsters.DEFS[boss.kind].name)
	boss.max_hp *= float(rd.boss)
	boss.hp = boss.max_hp
	boss.atk *= BOSS_ATK
	boss.radius *= BOSS_SIZE
	boss.max_poise *= float(rd.boss)
	boss.poise = boss.max_poise


static func _buff(e, rd: Dictionary) -> void:
	e.max_hp *= float(rd.hp)
	e.hp = e.max_hp
	e.atk *= float(rd.atk)


static func _zone_pos(w, cx: float, size: Vector2) -> Vector2:
	return Vector2(cx + (float(w._rng.call()) - 0.5) * 360.0, 200.0 + float(w._rng.call()) * (size.y - 400.0))


static func _spawn(w, kind: String, level: int, pos: Vector2, elite: bool):
	return w.spawn_with_hooks(kind, level, pos, {"elite": elite})


## NV-23: EXP thưởng khi dọn cổng.
static func clear_exp(rank: String, level: int) -> int:
	return int(RANK[rank].exp) * Formulas.mob_exp(level, true)


## Hạ Chúa Cổng: thưởng theo hạng, cổng đóng, cổng ra tại chỗ.
static func on_kill(w, e) -> void:
	if not e.gate_boss:
		return
	var pid := parent(w.map_id)
	var rank := str(w.map.get("gate_rank", "E"))
	var rd: Dictionary = RANK[rank]
	var lv := int(e.level)
	var p = w.profile
	var i := 0
	for rarity in rd.items:
		var uq := ""
		if rarity == "orange":
			var keys: Array = ItemData.UNIQUES.keys()
			uq = str(keys[w._gate_rng.randi() % keys.size()])
		w._drop_item(e.pos + Vector2(-30 + 30 * i, 0), lv, rarity, uq)
		i += 1
	w.add_pickup(e.pos + Vector2(-18, 18), "gold", 40.0 * lv * float(rd.gold))
	w.add_pickup(e.pos + Vector2(18, 18), "stone", float(2 + lv / 10) * float(rd.gold))
	if int(rd.ess) > 0:
		p.essence = int(p.essence) + int(rd.ess)
	var xp := clear_exp(rank, lv)
	w.add_exp(xp, false)
	p.gates.erase(pid)
	p.gates_cleared = int(p.gates_cleared) + 1
	var best := str(p.gate_best)
	if best == "" or RANKS.find(rank) > RANKS.find(best):
		p.gate_best = rank
	w.portals.append({"kind": "exit", "to": pid, "pos": e.pos + Vector2(0, -20)})
	if w.player.pos.distance_to(e.pos + Vector2(0, -20)) <= 44.0:
		w.portal_inside = w.portals.size() - 1
	var ess_txt := (", +%d Thiên Phú Tinh Hoa" % int(rd.ess)) if int(rd.ess) > 0 else ""
	# NL-1 (docs/47 §3.A): cổng hạng C trở lên cho 1–3 viên ngọc (C/B 1 viên, A 2, S 3), cấp theo hạng.
	var glv := int(GearData.GEM_GATE_LV.get(rank, 0))
	if glv > 0:
		var gn: int = int({"C": 1, "B": 1, "A": 2, "S": 3}.get(rank, 1))
		var got: Array = []
		for _i in gn:
			var gk := Gear.grant_random(p, glv, w._gate_rng.randf)
			if gk != "":
				got.append(Gear.gem_name(gk))
		if not got.is_empty():
			ess_txt += ", " + ", ".join(got)
	w._message("Dọn Cổng hạng %s! +%d EXP%s. Cổng ra đã mở." % [rank, xp, ess_txt], "good")
	w._text(e.pos + Vector2(0, -60), "Cổng hạng %s đã dọn!" % rank, COLORS[rank].lightened(0.3), true)
	w._events.append({"type": "gate_clear", "rank": rank})
