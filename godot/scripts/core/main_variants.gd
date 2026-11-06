extends RefCounted
## NV-B (docs/41): 8 bước "hạ 30 quái vùng" của chính tuyến (kills2…kills9) đổi thành 4 kiểu mục tiêu khác nhau:
##   named   — hạ N quái vùng + 1 tinh anh có tên (sinh ở bãi quái gần khu an toàn)            chương 2, 9
##   clues   — tìm 3 dấu vết (đi tới chỗ phát sáng) → kẻ canh xuất hiện ở dấu vết cuối, hạ nó  chương 3, 4
##   collect — nhặt N vật rơi từ loài quái chỉ định (tỉ lệ rơi)                                 chương 5, 8
##   defend  — tới điểm giữ, đứng vững qua 3 đợt quái (rời xa quá thì đợt đang đánh mất)       chương 6, 7
## Tiến độ ở profile.side["_main"][loại bước] (save v30). Mỗi lần GameWorld kiểm nhiệm vụ (0,5 giây): sinh / kiểm vật,
## rồi ghi profile.quest[loại bước] = max(đang có, tiến độ) — chương tự chuyển bước khi đủ `need` (story.gd), không
## sửa logic chương. Bước cũ đang làm dở: quy đổi theo % (kills cũ / 30 × need).

const VARIANTS := {
	"kills2": {"mech": "named", "map": "2-1", "kind": "linh-danh-thue", "kills": 10, "name": "Đội trưởng Lính Thuê"},
	"kills3": {"mech": "clues", "map": "3-1", "guard": "xac-uop", "clue": "Mảnh bản đồ", "guard_name": "Xác Ướp Giữ Bản Đồ"},
	"kills4": {"mech": "clues", "map": "4-1", "guard": "hon-ma", "clue": "Dấu vết ảo ảnh", "guard_name": "Ảo Ảnh Gọi Tên"},
	"kills5": {"mech": "collect", "kinds": ["than-lan-lua", "nguoi-da"], "item": "Than Đá Đỏ", "need": 8, "chance": 0.5},
	"kills6": {"mech": "defend", "map": "6-1", "kind": "soi-bang", "waves": 3},
	"kills7": {"mech": "defend", "map": "7-1", "kind": "dai-bang-may", "waves": 3},
	"kills8": {"mech": "collect", "kinds": ["ke-nuot", "bong-hu-vo"], "item": "Mảnh Phong Ấn", "need": 8, "chance": 0.5},
	"kills9": {"mech": "named", "map": "9-1", "kind": "thien-binh", "kills": 10, "name": "Thiên Binh Thống Lĩnh"},
}
const OLD_NEED := 30
const CLUE_R := 70.0
const DEFEND_R := 260.0
const DEFEND_LEAVE := 700.0
const WAVE_R := 280.0
const Quests = preload("res://scripts/core/quests.gd")


static func _ql():
	return load("res://scripts/core/quest_log.gd")


static func need(type: String) -> int:
	var v: Dictionary = VARIANTS.get(type, {})
	match str(v.get("mech", "")):
		"named":
			return int(v.kills) + 1
		"clues":
			return 4
		"collect":
			return int(v.need)
		"defend":
			return int(v.waves)
	return OLD_NEED


static func _active_type(w) -> String:
	var ms = _ql().main_step(w)
	if ms.is_empty():
		return ""
	var t := str(ms.q.get("type", ""))
	return t if VARIANTS.has(t) else ""


static func state(w, type: String) -> Dictionary:
	var side: Dictionary = w.profile.side
	if not side.has("_main"):
		side["_main"] = {}
	var all: Dictionary = side["_main"]
	if not all.has(type):
		# bước cũ đang làm dở: quy đổi theo %
		var old := int(w.profile.quest.get(type, 0))
		var p := mini(need(type) - 1, int(floor(float(old) / OLD_NEED * need(type)))) if old > 0 else 0
		all[type] = {"p": p, "kills": 0, "named": false, "clues": [], "guard": false, "wave": 0, "wave_on": false}
	return all[type]


## Gọi mỗi lần GameWorld kiểm nhiệm vụ (0,5 giây), trước Chapters.check_quest.
static func tick(w) -> void:
	var type := _active_type(w)
	if type == "":
		return
	var v: Dictionary = VARIANTS[type]
	var s := state(w, type)
	match str(v.mech):
		"named":
			_tick_named(w, v, s)
		"clues":
			_tick_clues(w, v, s)
		"defend":
			_tick_defend(w, v, s)
	w.profile.quest[type] = maxi(int(w.profile.quest.get(type, 0)), int(s.p))


static func _level(w) -> int:
	return int(w.map.levels[1]) if w.map.has("levels") else int(w.profile.level)


static func _find(w, meta: String):
	for e in w.enemies:
		if not e.dead and e.has_meta(meta):
			return e
	return null


## Bãi quái gần khu an toàn nhất (chỗ đặt tinh anh có tên / dấu vết).
static func _camps_by_dist(w) -> Array:
	var cs: Array = w.camps.duplicate()
	cs.sort_custom(func(a, b): return a.pos.distance_to(w.safe_pos) < b.pos.distance_to(w.safe_pos))
	return cs


static func _tick_named(w, v: Dictionary, s: Dictionary) -> void:
	if w.map_id != str(v.map) or bool(s.named) or _find(w, "nv_named") != null:
		return
	var cs := _camps_by_dist(w)
	var at: Vector2 = cs[0].pos if not cs.is_empty() else w.safe_pos + Vector2(w.safe_r + 400.0, 0)
	var e = w.spawn_enemy(str(v.kind), _level(w), at, {"role": "field", "elite": true})
	e.set_meta("nv_named", true)
	e.name = str(v.name)


static func clue_points(w, v: Dictionary) -> Array:
	if w.map_id != str(v.map):
		return []
	var cs := _camps_by_dist(w)
	var out: Array = []
	for i in mini(3, cs.size()):
		out.append(cs[i].pos + Vector2(0, -90))
	return out


static func _tick_clues(w, v: Dictionary, s: Dictionary) -> void:
	var pts := clue_points(w, v)
	for i in pts.size():
		if i in s.clues or w.player.pos.distance_to(pts[i]) > CLUE_R:
			continue
		s.clues.append(i)
		s.p = s.clues.size()
		w._blast(pts[i], 40.0, Color("#ffd257"))
		w._message("%s %d/3." % [str(v.clue), s.clues.size()], "good")
		if s.clues.size() >= 3:
			w._message("%s xuất hiện ở dấu vết cuối cùng!" % str(v.guard_name), "bad")
	if s.clues.size() >= 3 and int(s.p) < 4 and not pts.is_empty() and _find(w, "nv_guard") == null:
		var e = w.spawn_enemy(str(v.guard), _level(w), pts[int(s.clues[-1])], {"role": "field", "elite": true})
		e.set_meta("nv_guard", true)
		e.name = str(v.guard_name)
		e.state = "chase"


static func defend_point(w) -> Vector2:
	var p: Vector2 = w.safe_pos + Vector2(w.safe_r + 280.0, 0)
	if w.map.has("islands"):
		p = w.Ch7.land_point(w.map, p)
	return p


static func _tick_defend(w, v: Dictionary, s: Dictionary) -> void:
	if w.map_id != str(v.map):
		s.wave_on = false
		return
	var at := defend_point(w)
	var d: float = w.player.pos.distance_to(at)
	if bool(s.wave_on):
		var alive: Array = w.enemies.filter(func(e): return not e.dead and e.has_meta("nv_wave"))
		if d > DEFEND_LEAVE:
			for e in alive:
				e.dead = true
			s.wave_on = false
			w._message("Rời điểm giữ — đợt %d bị bỏ dở, quay lại để đánh lại." % (int(s.wave) + 1), "bad")
		elif alive.is_empty():
			s.wave = int(s.wave) + 1
			s.p = s.wave
			s.wave_on = false
			w._message("Giữ vững đợt %d/%d!" % [s.wave, int(v.waves)], "good")
		return
	if int(s.wave) < int(v.waves) and d <= DEFEND_R:
		var n := 4 + int(s.wave)
		for i in n:
			var pos: Vector2 = at + Vector2.from_angle(TAU * i / n) * WAVE_R
			if w.map.has("islands"):
				pos = w.Ch7.land_point(w.map, pos)
			var e = w.spawn_enemy(str(v.kind), _level(w), pos, {"role": "field"})
			e.set_meta("nv_wave", true)
			e.state = "chase"
		s.wave_on = true
		w._message("Đợt %d/%d tràn tới — giữ điểm!" % [int(s.wave) + 1, int(v.waves)], "bad")


static func on_kill(w, e) -> void:
	var type := _active_type(w)
	if type == "":
		return
	var v: Dictionary = VARIANTS[type]
	var s := state(w, type)
	match str(v.mech):
		"named":
			if e.has_meta("nv_named"):
				s.named = true
				w._message("%s đã gục!" % str(v.name), "good")
			elif e.role in ["field", "pack", "nestMinion", "nestGuard"] and int(w.map.get("region", 0)) == int(str(v.map)[0]):
				s.kills = mini(int(v.kills), int(s.kills) + 1)
			s.p = int(s.kills) + (1 if bool(s.named) else 0)
		"clues":
			if e.has_meta("nv_guard"):
				s.p = 4
		"collect":
			if e.kind in v.kinds and not e.has_meta("nv_wave") and int(s.p) < int(v.need) and w._loot_rng.randf() < float(v.chance):
				s.p = int(s.p) + 1
				w._text(e.pos + Vector2(0, -40), "+1 %s (%d/%d)" % [str(v.item), int(s.p), int(v.need)], Color("#ffd257"), true)
	w.profile.quest[type] = maxi(int(w.profile.quest.get(type, 0)), int(s.p))


## Mục tiêu chỉ đường (QuestLog): tinh anh có tên / dấu vết chưa tìm / kẻ canh / điểm giữ / quái rơi vật.
static func target(w, type: String, out: Dictionary) -> Dictionary:
	var v: Dictionary = VARIANTS.get(type, {})
	if v.is_empty():
		return out
	var s := state(w, type)
	var mp := str(v.get("map", ""))
	if str(v.mech) == "collect":
		out.map = w.map_id
		var kinds: Array = v.kinds
		var best := INF
		for e in w.enemies:
			if not e.dead and e.kind in kinds and e.pos.distance_to(w.player.pos) < best:
				best = e.pos.distance_to(w.player.pos)
				out.pos = e.pos
		out.label = str(Quests.Monsters.DEFS.get(str(kinds[0]), {}).get("name", "Quái"))
		return out
	out.map = mp
	if mp != w.map_id:
		var m := Quests.Maps.get_map(mp)
		out.pos = Vector2(m.safe.pos)
		return out
	match str(v.mech):
		"named":
			var e = _find(w, "nv_named")
			if e != null and int(s.kills) >= int(v.kills):
				out.pos = e.pos
				out.label = str(v.name)
			else:
				out.pos = _ql()._nearest_camp(w)
				out.label = "Bãi quái"
		"clues":
			var g = _find(w, "nv_guard")
			if g != null:
				out.pos = g.pos
				out.label = str(v.guard_name)
			else:
				var pts := clue_points(w, v)
				var best2 := INF
				for i in pts.size():
					if not (i in s.clues) and pts[i].distance_to(w.player.pos) < best2:
						best2 = pts[i].distance_to(w.player.pos)
						out.pos = pts[i]
				out.label = str(v.clue)
		"defend":
			out.pos = defend_point(w)
			out.label = "Điểm giữ"
	return out
