extends RefCounted
## NV-A (docs/41): nhiệm vụ rõ ràng — bước chính đang làm, điểm mục tiêu và đường đi tới nó.
## Dữ liệu mục tiêu nằm ở khoá "goal" của từng bước trong data/story.gd:
##   {"npc": id}                         NPC (map tìm trong Maps.MAPS; "to-su" = Tổ Sư đang hiện)
##   {"map": id, "at": "arena"|"safe"|"field"|"camp"|"explore"|"stele3"}
##   {"map": id, "list": khoá map, "done": khoá profile.quest (chỉ số đã xong), "only": khoá chỉ số được tính}
##   {"region": n, "at": "camp"}         map đang đứng nếu thuộc vùng n, không thì map đầu vùng
##   {"region": n, "enemy": meta/loại}   quái mục tiêu gần nhất (Thủ Tầng "guard9", Tàn Hồn "tan-hon")
##   {"near": "enemy"}                   quái gần nhất (học kỹ năng / né)
##   {"panel": "map"|"bag"|"stats"}      việc làm trong bảng — không có điểm trên bản đồ
##   {"none": "chữ"}                     không chỉ đường
## Mục tiêu ở map khác: chỉ tới cổng sang map đó (cổng trước / sau theo chuỗi map, Cổng Dịch Chuyển nếu map đích
## đã mở và không kề, cửa ra nếu đang trong hang / cổng dungeon).

const Story = preload("res://scripts/data/story.gd")
const Maps = preload("res://scripts/data/maps.gd")
const Portals = preload("res://scripts/core/portals.gd")
const Caves = preload("res://scripts/core/caves.gd")
const Chapters = preload("res://scripts/core/chapters.gd")

## px / mét (Fog.REVEAL_R 360 px = 36 m).
const PX_PER_M := 10.0
## Bảng mở bằng phím — chữ hướng dẫn cho mục tiêu "panel".
const PANELS := {"map": "Mở Bản đồ khai phá (M)", "bag": "Mở Túi đồ (I)", "stats": "Mở bảng Nhân vật (C)"}
## Danh sách nhiệm vụ của từng chương (1…9).
const CHAPTER_NAMES := ["Thức tỉnh", "Đồng Bằng Gió Hú", "Sa Mạc Xích Sa", "Đầm Lầy U Minh", "Núi Viêm Long",
	"Băng Nguyên Bắc Cực", "Quần Đảo Thiên Không", "Vực Hư Vô", "Cổng Thiên Đạo"]
## Một câu dẫn truyện cho mỗi chương (sổ nhiệm vụ).
const CHAPTER_LORE := [
	"Sương Hư Vô tràn về Làng Thanh Thạch. Ngươi thức tỉnh Thiên phú bên Bia Đá — làng cần ngươi dọn đường cho dân.",
	"Liên minh ở Thành Biên Đài đang rối loạn: có gián điệp, quái tràn qua Cửa Gió. Lạc Phong cần một người ngoài cuộc.",
	"Mảnh bản đồ của Khai Giới Giả dẫn vào sa mạc. Sa Lão biết đường tới Di Tích — nếu ngươi sống sót dưới nắng.",
	"Lam Nhi mất trí nhớ giữa đầm lầy. Ký ức của nàng bị Nữ Vương Phệ Mộng giam trong các Bọc Mộng.",
	"Đoàn buôn Kim Luân lên núi lửa — nhưng thương hội có âm mưu riêng. Viêm Long đang thức giấc.",
	"Mảnh thứ hai của Hư Vô nằm dưới băng. Ám Khí trong ngươi bắt đầu thức giấc.",
	"Lãnh địa thành Hoàng Thành, khí cầu đưa ngươi lên các đảo trời. Cự Thần canh giữ Bia Đá gốc.",
	"Dưới đáy vực, Hư Vô Giáo giam giữ những người sống sót. Giáo Chủ hút Thiên phú của kẻ địch.",
	"Thiên Thê dẫn tới Cổng Thiên Đạo. Ma Tôn Vô Diện chờ ở tầng cuối — và một lựa chọn không thể đổi lại.",
]


static func quests_of(ch: int) -> Array:
	match ch:
		1: return Story.QUESTS
		2: return Story.QUESTS2
		3: return Story.QUESTS3
		4: return Story.QUESTS4
		5: return Story.QUESTS5
		6: return Story.QUESTS6
		7: return Story.QUESTS7
		8: return Story.QUESTS8
		9: return Story.QUESTS9
	return []


## Bước đã tới của chương ch (1-based; 0 = chưa tới chương; > số bước = xong).
static func chapter_step(w, ch: int) -> int:
	if ch == 1:
		return int(w.profile.quest_step)
	return int(w.profile.quest.get("ch%d" % ch, 0))


## Bước chính đang làm — cùng thứ tự ưu tiên với khung nhiệm vụ HUD (hud._update_quest).
## {chapter, step, total, q, status [n, need]} hoặc {} khi không có bước nào đang mở.
static func main_step(w) -> Dictionary:
	for i in range(Chapters.MODULES.size() - 1, -1, -1):
		var m = Chapters.MODULES[i]
		if not ("quest_hud" in m.HOOKS) or not m.has_method("quest"):
			continue
		var h: Dictionary = m.quest_hud(w)
		if h.get("active", false):
			var ch := i + 3
			return {"chapter": ch, "step": chapter_step(w, ch), "total": quests_of(ch).size(), "q": m.quest(w), "status": m.quest_status(w)}
	var q: Dictionary = w.quest()
	var q2: Dictionary = w.quest2()
	if not q2.is_empty() and (q.is_empty() or int(w.map.get("region", 1)) == 2):
		return {"chapter": 2, "step": chapter_step(w, 2), "total": Story.QUESTS2.size(), "q": q2, "status": w.quest2_status()}
	if not q.is_empty():
		return {"chapter": 1, "step": chapter_step(w, 1), "total": Story.QUESTS.size(), "q": q, "status": w.quest_status()}
	return {}


## Map chứa NPC id ("" nếu không thấy). "to-su" = bất kỳ Tổ Sư nào.
static func npc_map(npc_id: String) -> String:
	for id in Maps.MAPS:
		for n in Maps.MAPS[id].get("npcs", []):
			if str(n[0]) == npc_id or (npc_id == "to-su" and str(n[0]).begins_with("to-su-")):
				return str(id)
	return ""


static func region_maps(reg: int) -> Array:
	return Maps.region(reg).maps.filter(func(id): return Maps.MAPS.has(id))


## Mục tiêu tuyệt đối của bước q: {map, pos (INF = chưa biết chỗ / ngoài map đang đứng), label, panel, note}.
static func target(w, q: Dictionary) -> Dictionary:
	var g: Dictionary = q.get("goal", {})
	var out := {"map": "", "pos": Vector2.INF, "label": str(q.get("title", "")), "panel": "", "note": ""}
	if g.is_empty():
		return out
	if g.has("none"):
		out.note = str(g.none)
		return out
	# NV-B (docs/41): bước "hạ 30 quái" cũ → mục tiêu riêng (core/main_variants.gd)
	if g.has("variant"):
		return load("res://scripts/core/main_variants.gd").target(w, str(g.variant), out)
	if g.has("panel"):
		out.panel = str(g.panel)
		out.note = str(PANELS.get(out.panel, ""))
		return out
	# NV-D (docs/41): mục tiêu của uỷ thác
	if g.has("elite"):
		out.map = w.map_id
		out.pos = _nearest_enemy(w, func(e): return e.elite and not e.cave_boss)
		out.label = "Tinh anh"
		if out.pos == Vector2.INF:
			out.pos = _nearest_camp(w)
			out.label = "Bãi quái"
		return out
	if g.has("herb"):
		out.map = w.map_id
		var best := INF
		for h in w.herbs:
			if h.respawn <= 0.0 and h.pos.distance_to(w.player.pos) < best:
				best = h.pos.distance_to(w.player.pos)
				out.pos = h.pos
		out.label = "Thảo dược"
		return out
	if g.has("portal"):
		out.map = w.map_id
		var best2 := INF
		for pt in w.portals:
			if pt.kind == str(g.portal) and pt.pos.distance_to(w.player.pos) < best2:
				best2 = pt.pos.distance_to(w.player.pos)
				out.pos = pt.pos
		out.label = "Cửa hang" if str(g.portal) == "cave" else "Cổng dungeon"
		if out.pos == Vector2.INF:
			out.note = "Chưa có cổng dungeon trên map này — xem bản đồ lục địa (N)" if str(g.portal) == "dgate" else "Map này không có hang phụ"
		return out
	if g.has("near"):
		out.map = w.map_id
		out.pos = _nearest_enemy(w, func(e): return e.role in ["field", "pack", "nestMinion"])
		out.note = "Tìm quái gần nhất"
		return out
	if g.has("npc"):
		var id := str(g.npc)
		out.map = npc_map(id)
		# Tổ Sư: đúng người của lớp nhân vật (Classes.JOB3_MASTERS)
		if id == "to-su":
			id = str(w.Classes.JOB3_MASTERS.get(str(w.profile.class_id), ["to-su-kiem"])[0])
		if out.map == w.map_id:
			for n in w.npcs():
				if str(n.id) == id:
					out.pos = n.pos
					out.label = str(n.name).replace(" · E", "")
					break
		# NPC chưa hiện (điều kiện hiện theo bước) / ở map khác: vị trí theo dữ liệu map
		if out.pos == Vector2.INF and out.map != "":
			var m := Maps.get_map(out.map)
			for n in m.get("npcs", []):
				if str(n[0]) == id:
					out.pos = Vector2(m.safe.pos) + Vector2(n[2])
					out.label = str(n[3]).replace(" · E", "")
					break
		# C5-43: đang giữ Cổng Trại → chỉ vào cổng
		if g.get("siege", false) and w.map_id == out.map and bool(w.ch5.siege):
			out.pos = w.Ch5.gate_pos(w)
			out.label = "Cổng Trại"
		return out
	if g.has("region"):
		var reg := int(g.region)
		var maps := region_maps(reg)
		out.map = w.map_id if w.map_id in maps else (maps[0] if not maps.is_empty() else "")
		if out.map == w.map_id:
			if g.has("kind"):
				var kind := str(g.kind)
				out.pos = _nearest_enemy(w, func(e): return e.kind == kind)
				out.label = str(w.Monsters.DEFS.get(kind, {}).get("name", kind))
				if out.pos == Vector2.INF:
					out.pos = _nearest_camp(w)
					out.label = "Bãi quái"
			elif g.has("enemy"):
				var key := str(g.enemy)
				out.pos = _nearest_enemy(w, func(e): return e.has_meta(key) or (e.kind == key and not e.elite))
				out.label = "Thủ Tầng" if key == "guard9" else "Tàn Hồn"
			else:
				out.pos = _nearest_camp(w)
				out.label = "Bãi quái"
		return out
	out.map = str(g.get("map", ""))
	if out.map != w.map_id:
		var m2 := Maps.get_map(out.map) if Maps.MAPS.has(out.map) else {}
		if not m2.is_empty() and str(g.get("at", "")) == "arena" and m2.get("arena") != null:
			out.pos = Vector2(m2.arena.pos)
		elif not m2.is_empty():
			out.pos = Vector2(m2.safe.pos)
		return out
	var mm: Dictionary = w.map
	if g.has("list"):
		var pts: Array = mm.get(str(g.list), [])
		var done: Array = w.profile.quest.get(str(g.get("done", "")), [])
		var only: Array = mm.get(str(g.get("only", "")), []) if g.has("only") else []
		var best := INF
		for i in pts.size():
			if i in done or (g.has("only") and not (i in only)):
				continue
			var p: Vector2 = pts[i][0] if pts[i] is Array else pts[i]
			var d: float = p.distance_to(w.player.pos)
			if d < best:
				best = d
				out.pos = p
		return out
	# NV-C: boss hiếm của bước phụ (đang có mặt → chỗ nó; chưa xuất hiện → khu an toàn map đó)
	if g.has("rare"):
		out.pos = _nearest_enemy(w, func(e): return e.role == "rare" and e.kind == str(g.rare))
		out.label = str(w.Monsters.DEFS.get(str(g.rare), {}).get("name", g.rare))
		if out.pos == Vector2.INF:
			out.pos = w.safe_pos
			out.note = "Boss hiếm chưa xuất hiện (2 lần mỗi ngày)"
		return out
	match str(g.get("at", "")):
		"cave":
			for pt in w.portals:
				if pt.kind == "cave":
					out.pos = pt.pos
			out.label = "Cửa hang"
		"arena":
			if mm.get("arena") != null:
				out.pos = w.arena_pos
				out.label = str(mm.arena.get("name", out.label))
		"safe":
			out.pos = w.safe_pos
			out.label = str(mm.safe.get("name", out.label))
		"field":
			out.pos = w.safe_pos + Vector2(w.safe_r + 300.0, 0)
		"camp":
			out.pos = _nearest_camp(w)
			out.label = "Bãi quái"
		"stele3":
			out.pos = mm.get("stele3", Vector2.INF)
			out.label = "Bia Khai Giới Giả"
		"explore":
			out.pos = _nearest_fog(w)
			out.label = "Vùng chưa khám phá"
	return out


## Điểm cần đi tới NGAY trên map đang đứng: chính mục tiêu, hoặc cổng dẫn sang map mục tiêu.
## {pos, label, final (đúng mục tiêu), panel, note} — pos = INF khi không có chỗ để chỉ.
static func route(w, t: Dictionary) -> Dictionary:
	var out := {"pos": Vector2.INF, "label": str(t.label), "final": true, "panel": str(t.panel), "note": str(t.note)}
	var dest := str(t.map)
	if dest == "" or dest == w.map_id:
		out.pos = t.pos
		return out
	out.final = false
	var dest_name := str(Maps.get_map(dest).get("name", dest)) if Maps.MAPS.has(dest) else dest
	if Caves.is_cave(w.map_id):
		for pt in w.portals:
			if pt.kind == "exit":
				out.pos = pt.pos
				out.label = "Cửa ra"
		return out
	var ids := Portals.chain()
	var here := ids.find(w.map_id)
	var there := ids.find(dest)
	if here < 0 or there < 0:
		return out
	var kind := "next" if there > here else "back"
	# map đích đã mở và không kề → Cổng Dịch Chuyển nhanh hơn
	if absi(there - here) > 1 and dest in w.profile.unlocked_maps:
		kind = "waypoint"
	for pt in w.portals:
		if pt.kind == kind:
			out.pos = pt.pos
			out.label = ("Cổng Dịch Chuyển → %s" if kind == "waypoint" else "Cổng → %s") % dest_name
	return out


## Bước đang làm + đường đi: {main (main_step), target, route} hoặc {} nếu không có.
static var _guide_cache := {}


static func guide(w) -> Dictionary:
	# thế giới, bản đồ nhỏ, HUD cùng gọi trong một khung hình → tính 1 lần / khung (test gọi liên tiếp: khoá theo time)
	var key := "%d|%s|%f" % [Engine.get_process_frames(), w.map_id, w.time]
	if _guide_cache.get("key", "") == key and _guide_cache.get("w") == w:
		return _guide_cache.val
	var val := _guide(w)
	_guide_cache = {"key": key, "w": w, "val": val}
	return val


static func _guide(w) -> Dictionary:
	var ms := main_step(w)
	if ms.is_empty():
		return {}
	var t := target(w, ms.q)
	return {"main": ms, "target": t, "route": route(w, t)}


## Dòng chỉ đường: "➜ 85 m · Bãi quái" / "➜ 1240 m · Cổng → Mắt Bão" / "➜ Mở Bản đồ khai phá (M)"; "" nếu không có.
static func guide_text(w) -> String:
	var g := guide(w)
	if g.is_empty():
		return ""
	var r: Dictionary = g.route
	if r.pos != Vector2.INF:
		return "➜ %d m · %s" % [meters(w.player.pos, r.pos), str(r.label)]
	if str(r.note) != "":
		return "➜ " + str(r.note)
	return ""


static func meters(a: Vector2, b: Vector2) -> int:
	return roundi(a.distance_to(b) / PX_PER_M)


# ---------------------------------------------------------------- tìm điểm


static func _nearest_enemy(w, pred: Callable) -> Vector2:
	var best := INF
	var at := Vector2.INF
	for e in w.enemies:
		if e.dead or not pred.call(e):
			continue
		var d: float = e.pos.distance_to(w.player.pos)
		if d < best:
			best = d
			at = e.pos
	return at


## Bãi quái gần nhất hợp cấp (cấp bãi ≤ cấp người chơi + 2), không có thì bãi gần nhất.
static func _nearest_camp(w) -> Vector2:
	var best := INF
	var at := Vector2.INF
	var lv := int(w.profile.level)
	for pass_i in 2:
		for c in w.camps:
			if pass_i == 0 and int(c.level) > lv + 2:
				continue
			var d: float = c.pos.distance_to(w.player.pos)
			if d < best:
				best = d
				at = c.pos
		if at != Vector2.INF:
			break
	return at


## Ô sương chưa mở gần nhất (tâm ô) — bước "khám phá ≥ 40%". Tính lại tối đa 1 lần / giây.
static var _fog_cache := {}


static func _nearest_fog(w) -> Vector2:
	var f = w.fog
	var key := "%s|%d|%d|%d" % [w.map_id, f.version, int(w.player.pos.x / 200.0), int(w.player.pos.y / 200.0)]
	if _fog_cache.get("key", "") == key:
		return _fog_cache.pos
	var best := INF
	var at := Vector2.INF
	var pc := Vector2(w.player.pos / f.CELL)
	for cy in f.h:
		for cx in f.w:
			if f.cells[cy * f.w + cx] == 1:
				continue
			var d := Vector2(cx, cy).distance_squared_to(pc)
			if d < best:
				best = d
				at = Vector2((cx + 0.5) * f.CELL, (cy + 0.5) * f.CELL)
	_fog_cache = {"key": key, "pos": at}
	return at


# ---------------------------------------------------------------- việc đang ghim (NV-A4: theo dõi tối đa 2 việc ngoài chính tuyến)

const MAX_TRACKED := 2
const Quests = preload("res://scripts/core/quests.gd")


## Bước dạng {title, goal, n, need} của khoá "daily:<i>" / "side:<id>" ({} nếu không còn).
static func entry(w, key: String) -> Dictionary:
	if key.begins_with("daily:"):
		var i := int(key.substr(6))
		var ts: Array = Quests.tasks(w)
		if i < 0 or i >= ts.size() or bool(ts[i].claimed):
			return {}
		var t: Dictionary = ts[i]
		return {"title": Quests.task_title(t), "goal": Quests.task_goal(t), "n": int(t.n), "need": int(t.need), "done": Quests.done(t)}
	if key.begins_with("side:"):
		return Quests.side_entry(w, key.substr(5))
	return {}


static func is_tracked(w, key: String) -> bool:
	return key in w.profile.tracked


## Ghim / bỏ ghim; quá 2 việc thì bỏ việc ghim lâu nhất.
static func toggle_track(w, key: String) -> void:
	var tr: Array = w.profile.tracked
	if key in tr:
		tr.erase(key)
		return
	tr.append(key)
	while tr.size() > MAX_TRACKED:
		tr.pop_front()


## [{key, title, n, need, done, route}] các việc đang ghim còn hiệu lực (bỏ khoá hết hạn).
static func tracked(w) -> Array:
	var out: Array = []
	var keep: Array = []
	# NV-E: sự kiện trên đường đang diễn ra luôn đứng đầu (không chiếm chỗ ghim)
	if not w.road_event.is_empty():
		var rt: Dictionary = w.RoadEvents.target(w)
		out.append({"key": "road", "title": "⚑ " + str(w.RoadEvents.NAMES.get(str(w.road_event.kind), "")), "n": 0, "need": 1, "done": false,
			"route": {"pos": rt.get("pos", Vector2.INF), "label": str(rt.get("label", "")), "final": true, "panel": "", "note": ""}})
	for key in w.profile.tracked:
		var e := entry(w, str(key))
		if e.is_empty():
			continue
		keep.append(key)
		var t := target(w, e)
		out.append({"key": key, "title": e.title, "n": e.n, "need": e.need, "done": e.done, "route": route(w, t)})
	w.profile.tracked = keep
	return out


## Điểm cần tới của việc ghim (khoá rỗng = nhiệm vụ chính).
static func route_of(w, key: String) -> Dictionary:
	if key == "road":
		var rt: Dictionary = w.RoadEvents.target(w)
		return {} if rt.is_empty() else {"pos": rt.pos, "label": rt.label, "final": true, "panel": "", "note": ""}
	if key == "":
		var g := guide(w)
		return g.get("route", {})
	var e := entry(w, key)
	return {} if e.is_empty() else route(w, target(w, e))
