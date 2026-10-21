extends RefCounted
## D38 (M7): bộ điều phối logic theo chương. GameWorld chỉ gọi `Chapters.<hook>(self, …)`; mỗi file
## chapterN.gd khai báo `const HOOKS := [...]` (các hàm móc nó có) và `const MAPS := [...]` (map nó quản).
## Thêm chương mới: viết chapterN.gd + thêm vào MODULES — không phải sửa game_world.gd.
##
## Chữ ký hook (mọi hàm static, tham số đầu là GameWorld `w`):
##   on_load(w) · tick(w, dt) · check_quest(w) · after_spawn(w, e) · on_kill(w, e) · on_player_hit(w, e)
##   is_hidden(e) -> bool · update_enemy(w, e, dt) -> bool (true = đã xử lý xong khung hình)
##   chase(w, e, d, dt) -> bool · perform(w, e) -> bool · elite_skill(w, e, kind) -> bool
##   update_rare(w, e, dt) -> bool · boss_phase_two(w, e) -> bool · copy_skill(w, id) -> bool
##   adjust_damage(w, e, dmg, by_player) -> int · dodge_hit(w) -> bool (true = người chơi né hẳn đòn)
##   atk_mult(w) · heal_mult(w) · shot_mult(w) · move_mult(w) · hit_mult(w, e, crit) -> float (nhân dồn)
##   derive_bonus(w, bonus) · derive_after(w, bonus, st) · skill_trail(w, pos, r)
##   safe_zone(w, pos) -> bool · drink(w) -> bool (phím Q: true = đã dùng vật phẩm chương thay bình máu)
##   talk(w, npc_id) -> String (chỉ gọi chương có npc_id trong const NPCS)
##   map_requirement(w, id) -> String · gate_open(w, id) -> bool (chỉ gọi chương có id trong MAPS)
##   env_text(w) -> String · env_alert(w) -> bool · quest_hud(w) -> Dictionary (xem chapter3.gd)
##   Kỹ năng chuyển chức: fireball_mult, spin_mult (nhân) · chain_jumps (cộng) · pierce_cd(w, cd) · after_shot(w, mul) · after_slash(w)
##   vanish(w, e) -> bool (true = quái biến mất không cho EXP/đồ: ảo ảnh, Mộng Châu…) · input_move(w, v) -> Vector2
##   enemy_avoid(w, e, pos) -> bool (true = quái không được bước tới pos, ví dụ dung nham)
##   player_hurt(w, dmg, element) (sau khi người chơi mất máu vì đòn quái) · safe_blocked(w) -> bool (vùng an toàn tạm mất tác dụng)

const Ch3 = preload("res://scripts/core/chapter3.gd")
const Ch4 = preload("res://scripts/core/chapter4.gd")
const MODULES := [Ch3, Ch4]


## Danh sách chương có hook, tính 1 lần rồi giữ lại (hook được gọi nhiều lần mỗi khung hình cho từng quái).
static var _cache := {}


static func _with(hook: String) -> Array:
	var got = _cache.get(hook)
	if got == null:
		got = MODULES.filter(func(m): return hook in m.HOOKS)
		_cache[hook] = got
	return got


static func _owner(id: String):
	for m in MODULES:
		if id in m.MAPS:
			return m
	return null


# ---------------------------------------------------------------- gọi tất cả


static func on_load(w) -> void:
	for m in _with("on_load"):
		m.on_load(w)


static func tick(w, dt: float) -> void:
	for m in _with("tick"):
		m.tick(w, dt)


static func check_quest(w) -> void:
	for m in _with("check_quest"):
		m.check_quest(w)


static func after_spawn(w, e) -> void:
	for m in _with("after_spawn"):
		m.after_spawn(w, e)


static func on_kill(w, e) -> void:
	for m in _with("on_kill"):
		m.on_kill(w, e)


static func on_player_hit(w, e) -> void:
	for m in _with("on_player_hit"):
		m.on_player_hit(w, e)


static func derive_bonus(w, bonus: Dictionary) -> void:
	for m in _with("derive_bonus"):
		m.derive_bonus(w, bonus)


static func derive_after(w, bonus: Dictionary, st: Dictionary) -> void:
	for m in _with("derive_after"):
		m.derive_after(w, bonus, st)


static func skill_trail(w, pos: Vector2, r: float) -> void:
	for m in _with("skill_trail"):
		m.skill_trail(w, pos, r)


static func after_shot(w, mul: float) -> void:
	for m in _with("after_shot"):
		m.after_shot(w, mul)


static func after_slash(w) -> void:
	for m in _with("after_slash"):
		m.after_slash(w)


# ---------------------------------------------------------------- true ở chương đầu tiên xử lý


static func is_hidden(e) -> bool:
	for m in _with("is_hidden"):
		if m.is_hidden(e):
			return true
	return false


static func update_enemy(w, e, dt: float) -> bool:
	for m in _with("update_enemy"):
		if m.update_enemy(w, e, dt):
			return true
	return false


static func chase(w, e, d: float, dt: float) -> bool:
	for m in _with("chase"):
		if m.chase(w, e, d, dt):
			return true
	return false


static func perform(w, e) -> bool:
	for m in _with("perform"):
		if m.perform(w, e):
			return true
	return false


static func elite_skill(w, e, kind: String) -> bool:
	for m in _with("elite_skill"):
		if m.elite_skill(w, e, kind):
			return true
	return false


static func update_rare(w, e, dt: float) -> bool:
	for m in _with("update_rare"):
		if m.update_rare(w, e, dt):
			return true
	return false


static func boss_phase_two(w, e) -> bool:
	for m in _with("boss_phase_two"):
		if m.boss_phase_two(w, e):
			return true
	return false


static func copy_skill(w, id: String) -> bool:
	for m in _with("copy_skill"):
		if m.copy_skill(w, id):
			return true
	return false


static func dodge_hit(w) -> bool:
	for m in _with("dodge_hit"):
		if m.dodge_hit(w):
			return true
	return false


static func safe_zone(w, pos: Vector2) -> bool:
	for m in _with("safe_zone"):
		if m.safe_zone(w, pos):
			return true
	return false


static func drink(w) -> bool:
	for m in _with("drink"):
		if m.drink(w):
			return true
	return false


static func vanish(w, e) -> bool:
	for m in _with("vanish"):
		if m.vanish(w, e):
			return true
	return false


static func enemy_avoid(w, e, pos: Vector2) -> bool:
	for m in _with("enemy_avoid"):
		if m.enemy_avoid(w, e, pos):
			return true
	return false


static func safe_blocked(w) -> bool:
	for m in _with("safe_blocked"):
		if m.safe_blocked(w):
			return true
	return false


static func player_hurt(w, dmg: float, element: String) -> void:
	for m in _with("player_hurt"):
		m.player_hurt(w, dmg, element)


static func input_move(w, v: Vector2) -> Vector2:
	for m in _with("input_move"):
		v = m.input_move(w, v)
	return v


static func env_alert(w) -> bool:
	for m in _with("env_alert"):
		if m.env_alert(w):
			return true
	return false


# ---------------------------------------------------------------- nhân / cộng / nối


static func adjust_damage(w, e, dmg: int, by_player: bool) -> int:
	for m in _with("adjust_damage"):
		dmg = m.adjust_damage(w, e, dmg, by_player)
		if dmg <= 0:
			return 0
	return dmg


static func _product(hook: String, w) -> float:
	var k := 1.0
	for m in _with(hook):
		k *= float(m.call(hook, w))
	return k


static func atk_mult(w) -> float:
	return _product("atk_mult", w)


static func heal_mult(w) -> float:
	return _product("heal_mult", w)


static func shot_mult(w) -> float:
	return _product("shot_mult", w)


static func move_mult(w) -> float:
	return _product("move_mult", w)


static func fireball_mult(w) -> float:
	return _product("fireball_mult", w)


static func spin_mult(w) -> float:
	return _product("spin_mult", w)


static func hit_mult(w, e, crit: bool) -> float:
	var k := 1.0
	for m in _with("hit_mult"):
		k *= float(m.hit_mult(w, e, crit))
	return k


static func chain_jumps(w) -> int:
	var n := 0
	for m in _with("chain_jumps"):
		n += int(m.chain_jumps(w))
	return n


static func pierce_cd(w, cd: float) -> float:
	for m in _with("pierce_cd"):
		cd = float(m.pierce_cd(w, cd))
	return cd


static func env_text(w) -> String:
	var parts := PackedStringArray()
	for m in _with("env_text"):
		var t: String = m.env_text(w)
		if t != "":
			parts.append(t)
	return "   ·   ".join(parts)


# ---------------------------------------------------------------- theo chủ sở hữu (map / NPC)


static func talk(w, npc_id: String) -> String:
	for m in MODULES:
		if npc_id in m.NPCS:
			return m.talk(w, npc_id)
	return ""


static func owns_npc(npc_id: String) -> bool:
	for m in MODULES:
		if npc_id in m.NPCS:
			return true
	return false


static func map_requirement(w, id: String) -> String:
	var m = _owner(id)
	return m.map_requirement(w, id) if m != null and "map_requirement" in m.HOOKS else ""


static func gate_open(w, id: String) -> bool:
	var m = _owner(id)
	return m.gate_open(w, id) if m != null and "gate_open" in m.HOOKS else true


## Nhiệm vụ chương đang làm cho HUD: chương có nhiệm vụ đang mở (ưu tiên chương mới nhất), nếu không thì
## dòng "hoàn thành" của chương mới nhất đã xong. {} nếu chưa tới chương nào. Xem Ch3.quest_hud.
static func quest_hud(w) -> Dictionary:
	var done := {}
	for i in range(MODULES.size() - 1, -1, -1):
		var m = MODULES[i]
		if not ("quest_hud" in m.HOOKS):
			continue
		var h: Dictionary = m.quest_hud(w)
		if h.get("active", false):
			return h
		if h.get("done", false) and done.is_empty():
			done = h
	return done
