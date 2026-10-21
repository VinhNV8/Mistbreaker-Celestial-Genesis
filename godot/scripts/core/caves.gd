extends RefCounted
## HP-01…10 (docs/15): hang phụ trong từng map. Mỗi map ngoài trời có 1 cửa hang (cổng "cave"); hang là bản đồ
## nhỏ tối `cave-<map cha>` sinh từ dữ liệu map cha (không khai báo tay), 3 khu: 2 khu quái + tinh anh, khu cuối
## có Chúa Hang. Hạ Chúa Hang → thưởng, cổng ra tại chỗ, hang đóng COOLDOWN giây chơi (profile.caves).

const Maps = preload("res://scripts/data/maps.gd")
const Monsters = preload("res://scripts/data/monsters.gd")

const PREFIX := "cave-"
const SIZE := Vector2(2600, 1100)
const MOUTH := Vector2(200, 550)
const MOUTH_R := 90.0
const COOLDOWN := 1200.0
const TRAVEL_TIME := 1.5
## Khu quái: [tâm x, số quái thường, số tinh anh]; khu cuối thêm Chúa Hang.
const ZONES := [[900.0, 5, 1], [1600.0, 6, 1], [2250.0, 2, 0]]
const BOSS_X := 2300.0
const BOSS_HP := 5.0
const BOSS_ATK := 1.3
const BOSS_SIZE := 1.4
const PURPLE_CHANCE := 0.25
const NAMES := {1: "Hang Sương Mù", 2: "Hang Gió Lốc", 3: "Hầm Cát Cổ", 4: "Hang Bùn Lầy", 5: "Hang Dung Nham", 6: "Hang Băng Vĩnh Cửu"}

static var _cache := {}


static func is_cave(id: String) -> bool:
	return id.begins_with(PREFIX)


static func parent(id: String) -> String:
	return id.substr(PREFIX.length()) if is_cave(id) else id


static func cave_id(parent_id: String) -> String:
	return PREFIX + parent_id


static func name_of(parent_id: String) -> String:
	return str(NAMES.get(int(Maps.MAPS[parent_id].get("region", 1)), "Hang Sâu"))


## Cửa hang trên map cha (giữa phía dưới).
static func entrance(parent_id: String) -> Vector2:
	var size: Vector2 = Maps.MAPS[parent_id].size
	return Vector2(size.x * 0.5, size.y * 0.82)


## Dữ liệu bản đồ hang (cùng khoá với map thường để GameWorld/world_view dùng như mọi map).
static func build_map(id: String) -> Dictionary:
	if _cache.has(id):
		return _cache[id]
	var pid := parent(id)
	var pm: Dictionary = Maps.MAPS.get(pid, Maps.MAPS["1-1"])
	var top := int(pm.levels[1])
	var m := {
		"region": int(pm.get("region", 1)),
		"name": name_of(pid) if Maps.MAPS.has(pid) else "Hang Sâu",
		"size": SIZE,
		"levels": [top, top + 1],
		"zone_x": [2100.0, 400.0],
		"safe": {"pos": MOUTH, "r": MOUTH_R, "name": "Cửa hang", "kind": "cave"},
		"arena": null,
		"gate": false,
		"mobs": pm.get("mobs", "legacy"),
		"ground": pm.get("ground", "tile-grass-0"),
		"fog": 0.85,
		"tint": Color(0.05, 0.03, 0.09),
		"wind": 0.0,
		"trees": 0,
		"decor": "cave",
		"cave": true,
		"parent": pid,
	}
	_cache[id] = m
	return m


## Giây chơi còn lại trước khi hang mở lại (0 = đang mở).
static func reopen_in(w, parent_id: String) -> float:
	return maxf(0.0, float(w.profile.caves.get(parent_id, 0.0)) - float(w.profile.play_seconds))


## Lý do không vào được hang; "" nếu được.
static func blocker(w, id: String) -> String:
	var pid := parent(id)
	if not Maps.MAPS.has(pid):
		return "Hang này chưa mở."
	if w.map_id == id:
		return "Bạn đang ở trong hang."
	var left := reopen_in(w, pid)
	if left > 0.0:
		var s := ceili(left)
		return "Hang đã dọn — mở lại sau %d:%02d" % [s / 60, s % 60]
	return ""


## Sinh quái 3 khu khi vào hang (gọi cuối _load_map).
static func populate(w) -> void:
	var lv := int(w.map.levels[0])
	for z in ZONES:
		var cx: float = z[0]
		var zl := lv + (1 if cx >= 2100.0 else 0)
		for i in int(z[1]):
			_spawn(w, w._pick_kind(zl), zl, _zone_pos(w, cx), false)
		for i in int(z[2]):
			var ek: String = w._elite_kind(zl)
			_spawn(w, ek if ek != "" else w._pick_kind(zl), zl, _zone_pos(w, cx), ek != "")
	var bk: String = w._elite_kind(lv + 1)
	var boss = _spawn(w, bk if bk != "" else w._pick_kind(lv + 1), lv + 1, Vector2(BOSS_X, SIZE.y / 2.0), true)
	boss.cave_boss = true
	# Bảng tên hiện "Chúa Hang · <tên quái> · Lv" (world_view._enemy_nameplate).
	boss.name = str(Monsters.DEFS[boss.kind].name)
	boss.max_hp *= BOSS_HP
	boss.hp = boss.max_hp
	boss.atk *= BOSS_ATK
	boss.radius *= BOSS_SIZE
	boss.max_poise *= BOSS_HP
	boss.poise = boss.max_poise


static func _zone_pos(w, cx: float) -> Vector2:
	return Vector2(cx + (float(w._rng.call()) - 0.5) * 360.0, 200.0 + float(w._rng.call()) * (SIZE.y - 400.0))


static func _spawn(w, kind: String, level: int, pos: Vector2, elite: bool):
	return w.spawn_with_hooks(kind, level, pos, {"elite": elite})


## Hạ Chúa Hang: thưởng, cổng ra tại chỗ, đóng hang.
static func on_kill(w, e) -> void:
	if not e.cave_boss:
		return
	var pid := parent(w.map_id)
	var lv := int(e.level)
	w._drop_item(e.pos, lv, "purple" if float(w._rng.call()) < PURPLE_CHANCE else "blue")
	w.add_pickup(e.pos + Vector2(-18, 10), "gold", 40.0 * lv)
	w.add_pickup(e.pos + Vector2(18, 10), "stone", float(2 + lv / 10))
	w.profile.caves[pid] = float(w.profile.play_seconds) + COOLDOWN
	w.portals.append({"kind": "exit", "to": pid, "pos": e.pos + Vector2(0, -20)})
	if w.player.pos.distance_to(e.pos + Vector2(0, -20)) <= 44.0:
		w.portal_inside = w.portals.size() - 1
	w._message("Hang đã dọn! Cổng ra đã mở. Hang mở lại sau %d phút." % roundi(COOLDOWN / 60.0), "good")
	w._text(e.pos + Vector2(0, -60), "Hang đã dọn!", Color("#ffc940"), true)
