extends RefCounted
## Mô phỏng thế giới: di chuyển, combat, AI quái, boss, EXP.
## Logic thuần, không vẽ gì, không phụ thuộc Node — test được ở chế độ headless.

const Config = preload("res://scripts/core/config.gd")
const Explore = preload("res://scripts/core/explore.gd")
const Formulas = preload("res://scripts/core/formulas.gd")
const Stats = preload("res://scripts/core/stats.gd")
const Talents = preload("res://scripts/data/talents.gd")
const Monsters = preload("res://scripts/data/monsters.gd")
const Items = preload("res://scripts/core/items.gd")
const ItemData = preload("res://scripts/data/items.gd")

const WORLD_SIZE := Vector2(2600, 1600)
const VILLAGE_POS := Vector2(230, 800)
const VILLAGE_R := 170.0
const ARENA_POS := Vector2(2290, 800)
const ARENA_R := 270.0
## Bức tường sương mù chắn lối vào hang Sói Chúa khi chưa đủ điều kiện.
const GATE_X := 2290.0 - 270.0 - 60.0

const PLAYER_RADIUS := 16.0
const SLASH_RANGE := 80.0
const SLASH_ARC := PI / 3.0
const SLASH_INTERVAL := 0.5
const SPIN_RANGE := 125.0
const SPIN_MUL := 1.8
const POUNCE_RADIUS := 80.0
const DODGE_CD := 3.0
## Né lăn: 0,3 giây bất tử (tài liệu mục 5).
const DODGE_TIME := 0.3
const DODGE_SPEED := 760.0
const FREEZE_TIME := 3.0
const RESPAWN_TIME := 2.5
const COMBO_TIMEOUT := 5.0
const BOSS_LEVEL := 6
const BOSS_POISE := 600.0
const BOSS_STUN := 5.0
const BOSS_EXP := 1500
const BOSS_GOLD := 300
## EQ-07: Sói Chúa hồi sinh sau 10 phút chơi để cày đồ.
const BOSS_RESPAWN_SEC := 600.0
## EQ-16: Nanh Sói Chúa — đòn chém thứ 3 gây thêm 60% sát thương.
const FANG_EVERY := 3
const FANG_MUL := 1.6

# --- MVP M2: Thiên phú (docs/03-mvp-spec.md, mục 4)
## TL-S2: bình máu, thảo dược.
const POTION_CD := 8.0
const POTION_HEAL := 0.35
const POTION_MAX := 5
const HERBS_PER_POTION := 2
const HERB_NODES := 8
const HERB_RESPAWN := 60.0
## TL-S1: rương ẩn. 1 m = 10 đơn vị.
const CHESTS := 6
const CHEST_OPEN_R := 24.0
const CHEST_SENSE_R := 300.0
## Chân Không Biết Mỏi: "không giao chiến" = 3 giây không đánh, không trúng đòn.
const OUT_OF_COMBAT := 3.0
const LIFESTEAL := 0.08
## TL-S4: đồng minh.
const TAME_HP := 0.1
const PET_MAX := 2
const SHADOW_MAX := 10
const SHADOW_CHANCE := 0.15
const SHADOW_TTL := 60.0
const SHADOW_ATK := 0.3
const ALLY_RANGE := 260.0
const ALLY_SPEED := 210.0
## Ngũ Hành Bộc Phá.
const BURST_WINDOW := 2.0
const BURST_RANGE := 160.0
## Đạo Tặc — Vồ Mồi (kỹ năng sao chép của Sói Chúa).
const LEAP_DIST := 300.0
const LEAP_RADIUS := 90.0
const LEAP_MUL := 2.5
const ESSENCE_PER_BOSS := 3


class PlayerState:
	var pos := Vector2.ZERO
	var hp := 0.0
	var facing := 0.0
	var attack_cd := 0.0
	var skill_cd := 0.0
	var talent_cd := 0.0
	var potion_cd := 0.0
	var dodge_cd := 0.0
	var dodge_time := 0.0
	var dodge_dir := Vector2.RIGHT
	var swing := 0.0
	var swing_kind := "slash"
	var hits := 0
	var hurt := 0.0
	var dead_timer := 0.0


class Enemy:
	var id := 0
	var kind := ""
	## "field" | "nestGuard" | "nestMinion" | "bossMinion" | "boss"
	var role := "field"
	var name := ""
	var level := 1
	var elite := false
	var pos := Vector2.ZERO
	var home := Vector2.ZERO
	var wander := Vector2.ZERO
	var hp := 0.0
	var max_hp := 0.0
	var atk := 0.0
	var def := 0.0
	var speed := 0.0
	var radius := 0.0
	var attack_range := 0.0
	## "idle" | "chase" | "windup" | "recover" | "stunned"
	var state := "idle"
	var timer := 0.0
	var windup_total := 1.0
	## "melee" | "spore" | "pounce"
	var attack_kind := "melee"
	var target := Vector2.ZERO
	var hit_flash := 0.0
	var dead := false
	var nest_tile_id := -1
	var poise := 0.0
	var max_poise := 0.0
	var broken := false
	var phase := 1
	var pounce_cd := 4.0
	var color := Color.WHITE


class Projectile:
	var pos := Vector2.ZERO
	var vel := Vector2.ZERO
	var ttl := 0.0
	var atk := 0.0
	var radius := 8.0


class Pickup:
	var pos := Vector2.ZERO
	## "gold" | "orb" | "stone" | "item"
	var kind := "gold"
	var value := 0.0
	var item := {}
	var ttl := 30.0


## Thú cưng (Thuần Thú Sư) hoặc lính bóng tối (Bầy Đàn Bóng Tối).
class Ally:
	var pos := Vector2.ZERO
	## "pet" | "shadow"
	var kind := "pet"
	var monster := "wolf"
	var level := 1
	var atk := 0.0
	var radius := 14.0
	var ttl := -1.0
	var attack_cd := 0.0
	var color := Color.WHITE
	var dead := false


class Herb:
	var pos := Vector2.ZERO
	var respawn := 0.0


class Chest:
	var pos := Vector2.ZERO
	var opened := false


class FloatText:
	var pos := Vector2.ZERO
	var text := ""
	var color := Color.WHITE
	var ttl := 0.8
	var big := false


var profile
var player := PlayerState.new()
var enemies: Array = []
var projectiles: Array = []
var pickups: Array = []
var texts: Array = []
var allies: Array = []
var herbs: Array = []
var chests: Array = []
var stats: Dictionary = {}
var freeze_timer := 0.0
var combo := 0
var time := 0.0

var _events: Array = []
var _combo_timer := 0.0
var _next_id := 1
var _spawn_timer := 0.0
var _gate_msg_cd := 0.0
var _passive_msg_cd := 0.0
var _rng: Callable
var _aim := Vector2.ZERO
var _last_combat := -99.0
var _super_slash := false
var _element_switch_at := -99.0


func _init(p, rng: Callable) -> void:
	profile = p
	_rng = rng
	stats = _derive()
	player.pos = VILLAGE_POS + Vector2(60, 0)
	player.hp = stats.max_hp
	for _i in Config.MAX_FIELD_MOBS:
		_spawn_field_mob()
	for _i in HERB_NODES:
		var h := Herb.new()
		h.pos = _random_field_pos()
		herbs.append(h)
	for _i in CHESTS:
		var c := Chest.new()
		c.pos = _random_field_pos()
		chests.append(c)
	for pet in profile.pets:
		_add_ally("pet", str(pet.kind), int(pet.level), player.pos)


static func zone_level(x: float) -> int:
	return clampi(1 + int(floor((x - 450.0) / 260.0)), 1, 6)


func talent() -> Dictionary:
	return Talents.get_talent(profile.talent)


func explored() -> float:
	return Explore.explored_ratio(profile.tiles)


func boss_unlocked() -> bool:
	return profile.boss_defeated or (profile.level >= Config.BOSS_LEVEL_REQ and explored() >= Config.EXPLORE_REQ)


func boss() -> Enemy:
	for e in enemies:
		if e.role == "boss" and not e.dead:
			return e
	return null


func drain_events() -> Array:
	var out := _events
	_events = []
	return out


## Sói Chúa giai đoạn 2 ẩn trong sương mù, chỉ lộ khi vung đòn, bị choáng hoặc ở rất gần.
func is_hidden(e: Enemy) -> bool:
	if e.role != "boss" or e.phase < 2:
		return false
	if e.state == "windup" or e.state == "stunned":
		return false
	return e.pos.distance_to(player.pos) > 140.0


# ------------------------------------------------------------------ vòng lặp


## input: {move: Vector2, aim: Vector2, attack, skill, talent, dodge: bool}
func update(dt: float, input: Dictionary) -> void:
	time += dt
	profile.play_seconds += dt
	_tick_texts(dt)
	Explore.tick_production(profile, dt)
	if Explore.regen_torches(profile, dt) > 0:
		_message("+1 Đuốc Khai Giới đã hồi.", "info")
	for key in Explore.tick_build_clock(profile, dt):
		_on_built(key)

	var p := player
	if p.dead_timer > 0.0:
		p.dead_timer -= dt
		if p.dead_timer <= 0.0:
			_respawn()
		return

	p.attack_cd -= dt
	p.skill_cd -= dt
	p.talent_cd -= dt
	p.potion_cd -= dt
	p.dodge_cd -= dt
	p.swing -= dt
	p.hurt -= dt
	_gate_msg_cd -= dt
	_passive_msg_cd -= dt
	_combo_timer -= dt
	if _combo_timer <= 0.0:
		combo = 0

	var aim: Vector2 = input.aim
	_aim = aim
	if aim.distance_to(p.pos) > 0.5:
		p.facing = (aim - p.pos).angle()
	_move_player(dt, input)
	if input.attack and p.attack_cd <= 0.0 and p.dodge_time <= 0.0:
		_slash()
	if input.skill and p.skill_cd <= 0.0 and p.dodge_time <= 0.0:
		_spin()
	if input.talent:
		_use_talent()
	if input.get("potion", false):
		drink_potion()

	if freeze_timer > 0.0:
		freeze_timer -= dt
	else:
		for e in enemies:
			if not e.dead:
				_update_enemy(e, dt)
		_separate_enemies()
		_update_projectiles(dt)
	_update_allies(dt)
	_update_pickups(dt)
	_update_herbs(dt)
	_update_chests()
	_update_spawning(dt)
	enemies = enemies.filter(func(e): return not e.dead)
	allies = allies.filter(func(a): return not a.dead)


# ------------------------------------------------------------------ người chơi


func _move_player(dt: float, input: Dictionary) -> void:
	var p := player
	var move: Vector2 = input.move
	if input.dodge and p.dodge_cd <= 0.0 and p.dodge_time <= 0.0:
		p.dodge_dir = move.normalized() if move.length() > 0.01 else Vector2.from_angle(p.facing)
		p.dodge_time = DODGE_TIME
		p.dodge_cd = DODGE_CD

	var vel := Vector2.ZERO
	if p.dodge_time > 0.0:
		p.dodge_time -= dt
		vel = p.dodge_dir * DODGE_SPEED
	elif move.length() > 0.0:
		vel = move / maxf(1.0, move.length()) * move_speed()
	p.pos = (p.pos + vel * dt).clamp(Vector2.ONE * PLAYER_RADIUS, WORLD_SIZE - Vector2.ONE * PLAYER_RADIUS)
	_enforce_gate()

	if boss_available() and boss() == null and p.pos.distance_to(ARENA_POS) < ARENA_R:
		var b := spawn_enemy("boss", BOSS_LEVEL, ARENA_POS + Vector2(120, 0), {"role": "boss"})
		b.state = "chase"
		_message("Sói Chúa Hư Vô xuất hiện! Đánh vào thanh Phá Thế để làm nó choáng.", "bad")


## Chân Không Biết Mỏi: +10% tốc chạy khi không giao chiến.
func move_speed() -> float:
	var v := float(stats.move_speed)
	if profile.talent == "chan-khong" and time - _last_combat > OUT_OF_COMBAT:
		v *= 1.1
	return v


func _enforce_gate() -> void:
	var p := player
	if not boss_unlocked() and p.pos.x > GATE_X:
		p.pos.x = GATE_X
		if _gate_msg_cd <= 0.0:
			_message(
				"Sương mù Hư Vô chặn đường: cần cấp %d và khai phá %d%% vùng đất (phím M)."
				% [Config.BOSS_LEVEL_REQ, int(Config.EXPLORE_REQ * 100)],
				"bad"
			)
			_gate_msg_cd = 4.0


## Lần đầu: chưa hạ. Sau đó: hồi sinh khi đủ 10 phút chơi (EQ-07).
func boss_available() -> bool:
	return not profile.boss_defeated or profile.play_seconds >= profile.boss_respawn_at


func _slash() -> void:
	var p := player
	p.attack_cd = SLASH_INTERVAL / float(stats.atk_speed)
	p.swing = 0.16
	p.swing_kind = "slash"
	p.hits += 1
	var double: bool = profile.talent == "kiem-tam" and p.hits % 5 == 0
	if double:
		_text(p.pos + Vector2(0, -34), "Kiếm Tâm!", Color("#5bd16a"), true)
	var fang: bool = has_unique("wolf_fang") and p.hits % FANG_EVERY == 0
	var mul := (2.0 if double else 1.0) * (FANG_MUL if fang else 1.0)
	# Kiếm Tâm — Nhất Kiếm Đoạn: đòn chém kế tiếp ×3, chắc chắn chí mạng.
	var empowered := _super_slash
	_super_slash = false
	if empowered:
		mul *= 3.0
	for e in enemies:
		if e.dead:
			continue
		var to_e: Vector2 = e.pos - p.pos
		var d := to_e.length()
		if d > SLASH_RANGE + e.radius:
			continue
		var in_arc := absf(angle_difference(p.facing, to_e.angle())) <= SLASH_ARC
		if not in_arc and d > e.radius + PLAYER_RADIUS:
			continue
		_hit_enemy(e, mul, empowered)


func _spin() -> void:
	var p := player
	p.skill_cd = skill_cd()
	p.swing = 0.3
	p.swing_kind = "spin"
	# Ngũ Hành Bộc Phá: Xoáy Kiếm trong 2 giây sau khi đổi hệ.
	var burst: bool = profile.talent == "ngu-hanh" and time - _element_switch_at <= BURST_WINDOW
	var radius := BURST_RANGE if burst else SPIN_RANGE
	if burst:
		_element_switch_at = -99.0
		_text(p.pos + Vector2(0, -40), "Ngũ Hành Bộc Phá!", Color(Monsters.ELEMENT_HEX[profile.element]), true)
	for e in enemies:
		if not e.dead and e.pos.distance_to(p.pos) <= radius + e.radius:
			_hit_enemy(e, SPIN_MUL * (2.0 if burst else 1.0))


func _use_talent() -> void:
	var t := talent()
	if not Talents.has_skill(t):
		if _passive_msg_cd <= 0.0:
			_message("%s là Thiên phú bị động — luôn có hiệu lực." % t.name, "info")
			_passive_msg_cd = 3.0
		return
	if player.talent_cd > 0.0:
		return
	var p := player
	var used := true
	match t.id:
		"kiem-tam":
			_super_slash = true
			_text(p.pos + Vector2(0, -40), "Nhất Kiếm Đoạn!", Color("#5bd16a"), true)
		"thao-duoc":
			var heal := float(stats.max_hp) * 0.3
			p.hp = minf(float(stats.max_hp), p.hp + heal)
			_text(p.pos + Vector2(0, -40), "Linh Dược +%d HP" % roundi(heal), Color("#5bd16a"), true)
		"trai-tim":
			var key := Explore.finish_now(profile)
			if key == "":
				_message("Hiệu Triệu: không có công trình nào đang xây.", "info")
				used = false
			else:
				_message("Hiệu Triệu: %s hoàn thành ngay!" % Explore.building_name(key), "good")
				_on_built(key)
		"ngu-hanh":
			var order: Array = Monsters.ELEMENT_ORDER
			profile.element = order[(order.find(profile.element) + 1) % order.size()]
			_element_switch_at = time
			_text(p.pos + Vector2(0, -40), "Hệ %s" % Monsters.ELEMENT_NAMES[profile.element], Color(Monsters.ELEMENT_HEX[profile.element]), true)
		"thoi-gian-ngung-dong":
			freeze_timer = FREEZE_TIME + (1.0 if Talents.has_sub(profile.talent, profile.talent_level, "control", 2) else 0.0)
			_text(p.pos + Vector2(0, -40), "Thời Gian Ngưng Đọng!", Color("#b36bff"), true)
		"bay-dan":
			var n := 0
			for i in 3:
				if _ally_count("shadow") < ally_cap("shadow"):
					_add_ally("shadow", "wolf", profile.level, p.pos + Vector2.from_angle(i / 3.0 * TAU) * 50.0)
					n += 1
			_text(p.pos + Vector2(0, -40), "Bóng Tối Trỗi Dậy +%d" % n, Color("#b36bff"), true)
			used = n > 0
		"dao-tac":
			if profile.copied_skills.is_empty():
				_message("Đạo Tặc chưa sao chép kỹ năng nào — hãy hạ một boss.", "info")
				used = false
			else:
				_leap()
	if used:
		p.talent_cd = talent_skill_cd()


## Hồi chiêu kỹ năng L sau các hiệu ứng phụ (Điều khiển/Phép thuật/Đặc biệt).
func talent_skill_cd() -> float:
	var t := talent()
	if not Talents.has_skill(t):
		return 0.0
	var cd := float(t.skill.cd)
	var lv: int = profile.talent_level
	if Talents.has_sub(t.id, lv, "control", 1):
		cd *= 0.85
	if Talents.has_sub(t.id, lv, "magic", 2):
		cd *= 0.8
	if Talents.has_sub(t.id, lv, "special", 2):
		cd *= 0.75
	return cd


## Tên kỹ năng L hiển thị trên HUD.
func talent_skill_name() -> String:
	var t := talent()
	if not Talents.has_skill(t):
		return ""
	if t.id == "dao-tac":
		return "Vồ Mồi" if "pounce" in profile.copied_skills else "Chưa sao chép"
	if t.id == "ngu-hanh":
		return "Đổi hệ (%s)" % Monsters.ELEMENT_NAMES[profile.element]
	return t.skill.name


## Đạo Tặc — Vồ Mồi: lao tới điểm ngắm, gây sát thương diện rộng.
func _leap() -> void:
	var p := player
	var dest := p.pos + (_aim - p.pos).limit_length(LEAP_DIST)
	p.pos = dest.clamp(Vector2.ONE * PLAYER_RADIUS, WORLD_SIZE - Vector2.ONE * PLAYER_RADIUS)
	_enforce_gate()
	p.swing = 0.3
	p.swing_kind = "spin"
	var mul := LEAP_MUL * (1.2 if Talents.has_sub(profile.talent, profile.talent_level, "special", 1) else 1.0)
	_text(p.pos + Vector2(0, -40), "Vồ Mồi!", Color("#ff5470"), true)
	for e in enemies:
		if not e.dead and e.pos.distance_to(p.pos) <= LEAP_RADIUS + e.radius:
			_hit_enemy(e, mul)


## TL-S2: phím Q.
func drink_potion() -> void:
	var p := player
	if profile.talent == "hap-huyet":
		if _passive_msg_cd <= 0.0:
			_message("Hấp Huyết: không dùng được bình máu.", "bad")
			_passive_msg_cd = 3.0
		return
	if p.potion_cd > 0.0 or p.hp >= float(stats.max_hp):
		return
	if profile.potions <= 0:
		if _passive_msg_cd <= 0.0:
			_message("Hết bình máu — hái thảo dược để chế thêm.", "bad")
			_passive_msg_cd = 3.0
		return
	var heal := potion_heal()
	profile.potions -= 1
	p.potion_cd = POTION_CD
	p.hp = minf(float(stats.max_hp), p.hp + heal)
	_text(p.pos + Vector2(0, -30), "+%d HP" % roundi(heal), Color("#5bd16a"), true)


func potion_heal() -> float:
	return float(stats.max_hp) * POTION_HEAL * (1.3 if profile.talent == "thao-duoc" else 1.0)


## Đền Thiên Phú: luyện cấp Thiên phú bằng Tinh Hoa (TL-10…13).
func level_talent() -> Dictionary:
	var res := {"ok": false, "message": ""}
	if not Explore.is_built(profile, "temple"):
		res.message = "Cần xây Đền Thiên Phú trước (Bản đồ khai phá, phím M)."
	elif profile.talent_level >= Talents.MAX_TALENT_LEVEL:
		res.message = "Thiên phú đã đạt cấp tối đa."
	elif profile.essence < Talents.level_cost(profile.talent_level):
		res.message = "Cần %d Thiên Phú Tinh Hoa (rơi từ Sói Chúa)." % Talents.level_cost(profile.talent_level)
	else:
		profile.essence -= Talents.level_cost(profile.talent_level)
		profile.talent_level += 1
		_refresh_stats()
		res.ok = true
		res.message = "%s lên cấp %d!" % [talent().name, profile.talent_level]
		if profile.talent_level % 5 == 0:
			var sub: String = Talents.GROUP_SUB[talent().group][profile.talent_level / 5 - 1]
			res.message += " Mở hiệu ứng phụ: %s." % sub
	_message(res.message, "good" if res.ok else "bad")
	return res


func allocate(stat: String) -> void:
	if profile.unspent <= 0:
		return
	profile.points[stat] += 1
	profile.unspent -= 1
	_refresh_stats()


## Tẩy điểm miễn phí trước cấp 30 (tài liệu mục 4).
func respec() -> bool:
	if profile.level >= Config.FREE_RESPEC_LEVEL:
		return false
	var pts: Dictionary = profile.points
	profile.unspent += int(pts.str) + int(pts.agi) + int(pts.vit)
	profile.points = {"str": 0, "agi": 0, "vit": 0}
	_refresh_stats()
	return true


func _derive(equipment = null) -> Dictionary:
	var bonus := Items.equipment_bonus(profile.equipment if equipment == null else equipment)
	bonus["dragon"] = dragon_active()
	return Stats.derive(profile.level, profile.points, profile.talent, bonus, profile.talent_level)


## Long Mạch Đàn đã xây xong (TL-S7).
func dragon_active() -> bool:
	return profile.talent == "long-mach" and Explore.is_built(profile, "dragon")


## EQ-11: đổi chỉ số giữ nguyên tỉ lệ HP hiện tại.
func _refresh_stats() -> void:
	var ratio := clampf(player.hp / maxf(1.0, float(stats.max_hp)), 0.0, 1.0)
	stats = _derive()
	player.hp = ratio * float(stats.max_hp)


func skill_cd() -> float:
	return float(stats.spin_cd)


func has_unique(id: String) -> bool:
	return id in stats.uniques


func combat_power() -> int:
	return Items.combat_power(stats)


## Lực chiến nếu mặc thêm món này (để so sánh trong túi đồ).
func power_if_equipped(item: Dictionary) -> int:
	var eq: Dictionary = profile.equipment.duplicate()
	eq[item.slot] = item
	return Items.combat_power(_derive(eq))


func add_exp(amount: float, from_combat: bool) -> void:
	var gain := amount
	if from_combat and Explore.has_wonder(profile.tiles):
		gain *= 1.1
	profile.xp += int(round(gain))
	while profile.level < Config.MAX_LEVEL and profile.xp >= Formulas.exp_to_next(profile.level):
		profile.xp -= Formulas.exp_to_next(profile.level)
		profile.level += 1
		profile.unspent += Config.POINTS_PER_LEVEL
		profile.torches = mini(Explore.torch_max(profile), profile.torches + 1)
		_refresh_stats()
		player.hp = stats.max_hp
		_events.append({"type": "levelup", "level": profile.level})
		_message(
			"Lên cấp %d! +%d điểm tiềm năng (C), +1 Đuốc Khai Giới." % [profile.level, Config.POINTS_PER_LEVEL], "good"
		)


func _damage_player(atk: float, mul: float) -> void:
	var p := player
	if p.dead_timer > 0.0:
		return
	if p.dodge_time > 0.0:
		_text(p.pos + Vector2(0, -28), "Né!", Color("#9de0e6"), false)
		return
	var dmg := maxi(1, int(round(Formulas.compute_damage(atk, stats.def, mul))))
	_last_combat = time
	p.hp -= dmg
	p.hurt = 0.2
	combo = 0
	_text(p.pos + Vector2(0, -26), "-%d" % dmg, Color("#ff5470"), false)
	if p.hp <= 0.0:
		_die()


func _die() -> void:
	player.hp = 0.0
	player.dead_timer = RESPAWN_TIME
	_events.append({"type": "death"})
	_message("Bạn đã gục ngã… hồi sinh tại Làng Thanh Thạch.", "bad")
	if boss() != null:
		for e in enemies:
			if e.role == "boss" or e.role == "bossMinion":
				e.dead = true
		_message("Sói Chúa Hư Vô rút về hang, hồi phục toàn bộ sinh lực.", "bad")


func _respawn() -> void:
	player.pos = VILLAGE_POS + Vector2(60, 0)
	player.hp = stats.max_hp
	player.dodge_time = 0.0
	for e in enemies:
		if e.role == "field" and e.pos.distance_to(VILLAGE_POS) < VILLAGE_R + 220.0:
			e.dead = true
	projectiles = []


# ------------------------------------------------------------------ quái


func _hit_enemy(e: Enemy, skill_mul: float, force_crit := false) -> void:
	var talent_bonus := 0.2 if profile.talent == "huyet-chien" and player.hp < float(stats.max_hp) * 0.3 else 0.0
	var crit := force_crit or _r() < float(stats.crit)
	var mul := skill_mul * ((1.0 + float(stats.crit_dmg)) if crit else 1.0) * (1.5 if e.broken else 1.0)
	var raw := Formulas.compute_damage(stats.atk, e.def, mul, element_bonus(e), talent_bonus) * (0.9 + _r() * 0.2)
	var dmg := maxi(1, int(round(raw)))
	_last_combat = time
	combo += 1
	_combo_timer = COMBO_TIMEOUT
	# Hấp Huyết: 8% sát thương thành máu.
	if profile.talent == "hap-huyet":
		player.hp = minf(float(stats.max_hp), player.hp + dmg * LIFESTEAL)
	# Thuần Thú Sư: đòn làm quái thường tụt dưới 10% HP thì thu phục.
	if profile.talent == "thuan-thu" and e.role == "field" and not e.elite and e.hp - dmg > 0.0 \
			and e.hp - dmg < e.max_hp * TAME_HP and _ally_count("pet") < ally_cap("pet"):
		_tame(e)
		return
	_apply_damage(e, dmg, crit, true)


## TL-S6: Ngũ Hành Linh Căn đánh hệ khắc +30% (Phép thuật cấp 5: +40%).
func element_bonus(e: Enemy) -> float:
	if profile.talent != "ngu-hanh":
		return 0.0
	if not Monsters.counters(profile.element, Monsters.DEFS[e.kind].element):
		return 0.0
	return Monsters.COUNTER_BONUS + (0.1 if Talents.has_sub(profile.talent, profile.talent_level, "magic", 1) else 0.0)


func _apply_damage(e: Enemy, dmg: int, crit: bool, by_player: bool) -> void:
	e.hp -= dmg
	e.hit_flash = 0.12
	var color := (Color("#ffc940") if crit else Color.WHITE) if by_player else Color("#c9b6ff")
	_text(e.pos + Vector2(0, -e.radius - 8), ("%d!" if crit else "%d") % dmg, color, crit)
	if e.state == "idle":
		e.state = "chase"

	if e.role == "boss":
		_damage_poise(e, dmg)
	elif by_player and e.state != "windup":
		e.pos += (e.pos - player.pos).normalized() * 10.0

	if e.hp <= 0.0:
		_kill_enemy(e)
	elif e.role == "boss" and e.phase == 1 and e.hp <= e.max_hp * 0.5:
		_boss_phase_two(e)


func _damage_poise(e: Enemy, dmg: float) -> void:
	if e.broken or e.state == "stunned":
		return
	e.poise -= dmg
	if e.poise <= 0.0:
		e.poise = 0.0
		e.broken = true
		e.state = "stunned"
		e.timer = BOSS_STUN
		_message("Phá Thế! Sói Chúa choáng 5 giây và nhận thêm 50% sát thương.", "good")


func _boss_phase_two(e: Enemy) -> void:
	e.phase = 2
	for i in 3:
		var offset := Vector2.from_angle(i / 3.0 * TAU) * 90.0
		var wolf := spawn_enemy("wolf", 5, e.pos + offset, {"role": "bossMinion"})
		wolf.state = "chase"
	_message("Sói Chúa hú gọi bầy sói và ẩn mình vào sương mù!", "bad")


func _kill_enemy(e: Enemy) -> void:
	e.dead = true
	profile.kills += 1
	var is_boss := e.role == "boss"
	var base := float(BOSS_EXP) if is_boss else float(Formulas.mob_exp(e.level, e.elite))
	add_exp(base * Formulas.combo_exp_multiplier(combo), true)

	var pk := Pickup.new()
	pk.pos = e.pos
	pk.kind = "gold"
	pk.value = float(BOSS_GOLD) if is_boss else round(e.level * 3 * (4 if e.elite else 1) * (0.8 + _r() * 0.4))
	pickups.append(pk)
	if e.elite or _r() < 0.15:
		var orb := Pickup.new()
		orb.pos = e.pos + Vector2(14, -10)
		orb.kind = "orb"
		orb.value = 0.2
		pickups.append(orb)

	_drop_loot(e)
	# Bầy Đàn Bóng Tối: 15% quái bị hạ đứng dậy làm lính bóng tối.
	if profile.talent == "bay-dan" and not is_boss and _r() < SHADOW_CHANCE and _ally_count("shadow") < ally_cap("shadow"):
		_add_ally("shadow", e.kind, e.level, e.pos)
	if e.elite and profile.torches < Explore.torch_max(profile):
		profile.torches += 1
		_message("Hạ %s: +1 Đuốc Khai Giới." % e.name, "good")
	if e.nest_tile_id >= 0 and Explore.conquer_tile(profile, e.nest_tile_id):
		_events.append({"type": "tile", "tile_id": e.nest_tile_id})
		_message("Đã chiếm Ổ quái! Lãnh địa mở rộng thêm một ô.", "good")
	if is_boss:
		var first_kill: bool = not profile.boss_defeated
		profile.boss_defeated = true
		profile.boss_respawn_at = profile.play_seconds + BOSS_RESPAWN_SEC
		for m in enemies:
			if m.role == "bossMinion":
				m.dead = true
		_message("Sói Chúa Hư Vô đã ngã xuống! Nó sẽ trở lại sau 10 phút.", "good")
		profile.essence += ESSENCE_PER_BOSS
		profile.tinh_kim += 1
		_message("+%d Thiên Phú Tinh Hoa, +1 Tinh Kim." % ESSENCE_PER_BOSS, "good")
		if profile.talent == "dao-tac" and not ("pounce" in profile.copied_skills):
			profile.copied_skills.append("pounce")
			_message("Đạo Tặc sao chép kỹ năng của Sói Chúa: Vồ Mồi (phím L).", "good")
		if first_kill:
			_events.append({"type": "victory"})


## EQ-04/05/06: rơi trang bị và Đá Cường Hoá.
func _drop_loot(e: Enemy) -> void:
	if e.role == "boss":
		_drop_item(e.pos, e.level, "purple")
		if _r() < ItemData.BOSS_UNIQUE_CHANCE:
			_drop_item(e.pos + Vector2(20, 0), e.level, "orange", ItemData.BOSS_UNIQUE)
		return
	if e.elite:
		_drop_item(e.pos, e.level, Items.roll_rarity("elite", _rng))
		return
	# May Mắn Nhỏ: +5 điểm % rơi đồ và rơi đá (Q7).
	var luck := 0.05 if profile.talent == "may-man" else 0.0
	if _r() < ItemData.FIELD_ITEM_CHANCE + luck:
		_drop_item(e.pos, e.level, Items.roll_rarity("field", _rng))
	if _r() < ItemData.FIELD_STONE_CHANCE + luck:
		var st := Pickup.new()
		st.pos = e.pos + Vector2(-12, 8)
		st.kind = "stone"
		st.value = 1.0
		pickups.append(st)


func _drop_item(pos: Vector2, level: int, rarity: String, unique := "") -> void:
	var set_id := ""
	if rarity == "purple" and unique == "" and _r() < ItemData.SET_CHANCE:
		set_id = ItemData.REGION_SET
	var pk := Pickup.new()
	pk.pos = pos + Vector2(_r() - 0.5, _r() - 0.5) * 24.0
	pk.kind = "item"
	pk.item = Items.new_item(profile, level, rarity, _rng, "", set_id, unique)
	pickups.append(pk)


func _update_enemy(e: Enemy, dt: float) -> void:
	var def: Dictionary = Monsters.DEFS[e.kind]
	var p := player
	if e.hit_flash > 0.0:
		e.hit_flash -= dt
	var alive := p.dead_timer <= 0.0
	var d := e.pos.distance_to(p.pos)
	# Quái thường không theo vào làng; quái ngoài hang không theo vào hang Sói Chúa.
	var outsider := e.role != "boss" and e.role != "bossMinion"
	var player_safe := (
		p.pos.distance_to(VILLAGE_POS) < VILLAGE_R or (outsider and p.pos.distance_to(ARENA_POS) < ARENA_R)
	)

	match e.state:
		"stunned":
			e.timer -= dt
			if e.timer <= 0.0:
				e.state = "chase"
				e.broken = false
				e.poise = e.max_poise
		"idle":
			e.timer -= dt
			if e.pos.distance_to(e.wander) < 8.0 or e.timer <= 0.0:
				e.wander = (e.home + Vector2(_r() - 0.5, _r() - 0.5) * 240.0).clamp(
					Vector2(40, 40), WORLD_SIZE - Vector2(40, 40)
				)
				e.timer = 2.0 + _r() * 3.0
			else:
				_move_toward(e, e.wander, e.speed * 0.35, dt)
			var aggro := 2000.0 if e.role == "boss" else 260.0
			if alive and not player_safe and d < aggro:
				e.state = "chase"
		"chase":
			var leash := e.role != "boss" and (d > 560.0 or player_safe)
			if not alive or leash:
				e.state = "idle"
				e.home = e.pos
				e.timer = 0.0
				return
			if e.role == "boss":
				e.pounce_cd -= dt
				if e.pounce_cd <= 0.0 and d > 150.0:
					_begin_attack(e, "pounce", 0.85)
					e.pounce_cd = 5.0
					return
			if d <= e.radius + e.attack_range + PLAYER_RADIUS:
				_begin_attack(e, def.attack, def.windup)
				return
			_move_toward(e, p.pos, e.speed, dt)
		"windup":
			e.timer -= dt
			if e.timer <= 0.0:
				_perform_attack(e)
				e.state = "recover"
				e.timer = def.recover
		"recover":
			e.timer -= dt
			if e.timer <= 0.0:
				e.state = "chase"


func _begin_attack(e: Enemy, kind: String, windup: float) -> void:
	e.state = "windup"
	e.attack_kind = kind
	e.timer = windup
	e.windup_total = windup
	e.target = player.pos
	if e.role == "boss":
		e.target = _clamp_to_arena(e.target, e.radius)


func _perform_attack(e: Enemy) -> void:
	var p := player
	match e.attack_kind:
		"melee":
			if e.pos.distance_to(p.pos) <= e.radius + e.attack_range + PLAYER_RADIUS + 12.0:
				_damage_player(e.atk, 1.0)
		"spore":
			var pr := Projectile.new()
			pr.pos = e.pos
			pr.vel = (e.target - e.pos).normalized() * 280.0
			pr.ttl = 1.6
			pr.atk = e.atk
			projectiles.append(pr)
		"pounce":
			e.pos = e.target
			if e.target.distance_to(p.pos) <= POUNCE_RADIUS + PLAYER_RADIUS:
				_damage_player(e.atk, 2.0)


func _move_toward(e: Enemy, target: Vector2, speed: float, dt: float) -> void:
	var d := e.pos.distance_to(target)
	if d < 1.0:
		return
	e.pos = e.pos.move_toward(target, speed * dt)
	if e.role == "boss":
		e.pos = _clamp_to_arena(e.pos, e.radius)


func _clamp_to_arena(pos: Vector2, radius: float) -> Vector2:
	var limit := ARENA_R - radius
	var off := pos - ARENA_POS
	return pos if off.length() <= limit else ARENA_POS + off.normalized() * limit


func _separate_enemies() -> void:
	for i in enemies.size():
		var a: Enemy = enemies[i]
		if a.dead:
			continue
		for j in range(i + 1, enemies.size()):
			var b: Enemy = enemies[j]
			if b.dead:
				continue
			var off := b.pos - a.pos
			var d := off.length()
			var min_d := a.radius + b.radius
			if d >= min_d or d < 0.001:
				continue
			var push := off / d * ((min_d - d) / 2.0)
			if a.role != "boss":
				a.pos -= push
			if b.role != "boss":
				b.pos += push


func _update_projectiles(dt: float) -> void:
	for pr in projectiles:
		pr.pos += pr.vel * dt
		pr.ttl -= dt
		if pr.ttl > 0.0 and pr.pos.distance_to(player.pos) <= pr.radius + PLAYER_RADIUS:
			_damage_player(pr.atk, 1.0)
			pr.ttl = 0.0
	projectiles = projectiles.filter(func(pr): return pr.ttl > 0.0)


func _update_pickups(dt: float) -> void:
	var p := player
	for pk in pickups:
		pk.ttl -= dt
		var d: float = pk.pos.distance_to(p.pos)
		if d < 130.0:
			pk.pos = pk.pos.move_toward(p.pos, 380.0 * dt)
		if d < 22.0:
			pk.ttl = 0.0
			if pk.kind == "gold":
				var gold: float = pk.value * (1.1 if Talents.has_sub(profile.talent, profile.talent_level, "economy", 1) else 1.0)
				profile.gold += gold
				_text(p.pos + Vector2(0, -30), "+%d vàng" % int(gold), Color("#ffc940"), false)
			elif pk.kind == "stone":
				profile.stones += int(pk.value)
				_text(p.pos + Vector2(0, -30), "+1 Đá Cường Hoá", Color("#9ec8ff"), false)
			elif pk.kind == "item":
				var res := Items.add_item(profile, pk.item)
				_text(p.pos + Vector2(0, -44), Items.display_name(pk.item), Items.rarity_color(pk.item), true)
				_events.append({"type": "item", "text": res.message, "rarity": pk.item.rarity})
			else:
				var heal := int(round(float(stats.max_hp) * pk.value))
				p.hp = minf(float(stats.max_hp), p.hp + heal)
				_text(p.pos + Vector2(0, -30), "+%d HP" % heal, Color("#5bd16a"), false)
	pickups = pickups.filter(func(pk): return pk.ttl > 0.0)


func _update_spawning(dt: float) -> void:
	_spawn_timer -= dt
	if _spawn_timer > 0.0:
		return
	_spawn_timer = 1.2
	var field := 0
	for e in enemies:
		if not e.dead and e.role == "field":
			field += 1
	if field < Config.MAX_FIELD_MOBS:
		_spawn_field_mob()


func _pick_kind(level: int) -> String:
	var r := _r()
	if level <= 2:
		return "mushroom" if level == 2 and r < 0.3 else "wolf"
	if level <= 4:
		return "wolf" if r < 0.5 else "mushroom"
	if r < 0.6:
		return "wisp"
	return "mushroom" if r < 0.8 else "wolf"


func _random_field_pos() -> Vector2:
	for _attempt in 20:
		var pos := Vector2(480.0 + _r() * (GATE_X - 520.0), 80.0 + _r() * (WORLD_SIZE.y - 160.0))
		if pos.distance_to(VILLAGE_POS) > VILLAGE_R + 120.0:
			return pos
	return Vector2(900, 400)


func _spawn_field_mob() -> void:
	for _attempt in 12:
		var pos := Vector2(480.0 + _r() * (GATE_X - 520.0), 80.0 + _r() * (WORLD_SIZE.y - 160.0))
		if pos.distance_to(player.pos) < 450.0:
			continue
		if pos.distance_to(VILLAGE_POS) < VILLAGE_R + 150.0:
			continue
		var level := zone_level(pos.x)
		spawn_enemy(_pick_kind(level), level, pos, {"elite": _r() < 0.06})
		return


## opts: {elite: bool, role: String, nest_tile_id: int}
func spawn_enemy(kind: String, level: int, pos: Vector2, opts: Dictionary = {}) -> Enemy:
	var def: Dictionary = Monsters.DEFS[kind]
	var elite: bool = opts.get("elite", false)
	var is_boss := kind == "boss"
	var e := Enemy.new()
	e.id = _next_id
	_next_id += 1
	e.kind = kind
	e.role = opts.get("role", "field")
	e.name = ("%s Tinh Anh" % def.name) if elite else def.name
	e.level = level
	e.elite = elite
	e.pos = pos
	e.home = pos
	e.wander = pos
	e.max_hp = def.hp if is_boss else round(def.hp * (1.0 + 0.35 * (level - 1)) * (2.2 if elite else 1.0))
	e.hp = e.max_hp
	e.atk = def.atk if is_boss else def.atk * (1.0 + 0.25 * (level - 1)) * (1.5 if elite else 1.0)
	e.def = def.def + (0 if is_boss else level)
	e.speed = def.speed
	e.radius = def.radius * (1.3 if elite else 1.0)
	e.attack_range = def.range
	e.windup_total = def.windup
	e.attack_kind = def.attack
	e.nest_tile_id = opts.get("nest_tile_id", -1)
	e.poise = BOSS_POISE if is_boss else 0.0
	e.max_poise = e.poise
	e.color = Color(def.color)
	enemies.append(e)
	return e


# ------------------------------------------------------------------ khai phá


func reveal_tile(id: int) -> Dictionary:
	var res := Explore.reveal_tile(profile, id)
	if res.ok and res.exp > 0:
		add_exp(res.exp, false)
	_message(res.message, "good" if res.ok else "bad")
	return res


func claim_tile(id: int) -> Dictionary:
	if nest_active(id):
		var busy := {"ok": false, "message": "Quái tinh anh của ổ này vẫn đang chờ bạn ngoài Rừng Sương.", "start_nest": false}
		_message(busy.message, "info")
		return busy
	var tile := Explore.find_tile(profile, id)
	var is_relic: bool = not tile.is_empty() and tile.event == "relic"
	var res := Explore.claim_tile(profile, id)
	if res.ok and res.exp > 0:
		add_exp(res.exp, false)
	if res.ok and is_relic:
		# EQ-08: rương Di tích tặng 1 món Xanh dương, vào thẳng túi.
		var gift := Items.new_item(profile, maxi(1, profile.level), "blue", _rng)
		_events.append({"type": "item", "text": Items.add_item(profile, gift).message, "rarity": "blue"})
	if res.ok and res.start_nest:
		_start_nest(id)
	elif res.ok:
		_events.append({"type": "tile", "tile_id": id})
	_message(res.message, "good" if res.ok else "bad")
	return res


func nest_active(tile_id: int) -> bool:
	for e in enemies:
		if not e.dead and e.nest_tile_id == tile_id:
			return true
	return false


# ------------------------------------------------------------------ trang bị


func equip(item_id: int) -> Dictionary:
	return _item_action(Items.equip(profile, item_id), true)


func unequip(slot: String) -> Dictionary:
	return _item_action(Items.unequip(profile, slot), true)


func enhance(item_id: int) -> Dictionary:
	var res := Items.enhance(profile, item_id, _rng)
	_message(res.message, "good" if res.get("success", false) else "bad")
	if res.ok:
		_refresh_stats()
	return res


func salvage(item_id: int) -> Dictionary:
	return _item_action(Items.salvage(profile, item_id, _rng), false)


func _item_action(res: Dictionary, restat: bool) -> Dictionary:
	_message(res.message, "good" if res.ok else "bad")
	if res.ok and restat:
		_refresh_stats()
	return res


func build(kind: String) -> Dictionary:
	var res := Explore.build(profile, kind)
	_message(res.message, "good" if res.ok else "bad")
	return res


func _on_built(key: String) -> void:
	_message("Xây xong %s." % Explore.building_name(key), "good")
	if key == "dragon":
		_refresh_stats()


func upgrade_camp() -> Dictionary:
	var res := Explore.upgrade_camp(profile)
	_message(res.message, "good" if res.ok else "bad")
	return res


func _start_nest(tile_id: int) -> void:
	var level := clampi(maxi(2, profile.level), 1, 8)
	var pos := (player.pos + Vector2.from_angle(player.facing) * 280.0).clamp(
		Vector2(120, 120), Vector2(GATE_X - 40.0, WORLD_SIZE.y - 120.0)
	)
	if pos.distance_to(VILLAGE_POS) < VILLAGE_R + 80.0:
		pos = VILLAGE_POS + Vector2(VILLAGE_R + 300.0, 0)
	var kind := _pick_kind(level)
	var guard := spawn_enemy(kind, level, pos, {"elite": true, "role": "nestGuard", "nest_tile_id": tile_id})
	guard.name = "Thủ lĩnh %s" % Monsters.DEFS[kind].name
	for i in 3:
		spawn_enemy(_pick_kind(level), level, pos + Vector2.from_angle(i / 3.0 * TAU) * 70.0, {"role": "nestMinion"})


# ------------------------------------------------------------------ tiện ích


func _r() -> float:
	return float(_rng.call())


func _message(text: String, tone: String) -> void:
	_events.append({"type": "message", "text": text, "tone": tone})


func _text(pos: Vector2, text: String, color: Color, big: bool) -> void:
	var t := FloatText.new()
	t.pos = pos + Vector2((_r() - 0.5) * 16.0, 0)
	t.text = text
	t.color = color
	t.ttl = 1.1 if big else 0.8
	t.big = big
	texts.append(t)


func _tick_texts(dt: float) -> void:
	for t in texts:
		t.ttl -= dt
		t.pos.y -= 38.0 * dt
	texts = texts.filter(func(t): return t.ttl > 0.0)


# ------------------------------------------------------------------ đồng minh (TL-S4)


func ally_cap(kind: String) -> int:
	var base := PET_MAX if kind == "pet" else SHADOW_MAX
	return base + (1 if Talents.has_sub(profile.talent, profile.talent_level, "summon", 2) else 0)


func _ally_count(kind: String) -> int:
	var n := 0
	for a in allies:
		if not a.dead and a.kind == kind:
			n += 1
	return n


func _add_ally(kind: String, monster: String, level: int, pos: Vector2) -> Ally:
	var def: Dictionary = Monsters.DEFS[monster]
	var a := Ally.new()
	a.kind = kind
	a.monster = monster
	a.level = level
	a.pos = pos
	a.radius = float(def.radius)
	if kind == "pet":
		a.atk = def.atk * (1.0 + 0.25 * (level - 1))
		a.color = Color(def.color)
	else:
		a.atk = float(stats.atk) * SHADOW_ATK
		a.ttl = SHADOW_TTL
		a.color = Color("#3a2a5a")
	allies.append(a)
	return a


func _tame(e: Enemy) -> void:
	e.dead = true
	profile.kills += 1
	add_exp(Formulas.mob_exp(e.level, false), true)
	profile.pets.append({"kind": e.kind, "level": e.level})
	_add_ally("pet", e.kind, e.level, e.pos)
	_message("Thuần Thú Sư: thu phục %s cấp %d làm thú cưng (%d/%d)." % [e.name, e.level, _ally_count("pet"), ally_cap("pet")], "good")


func ally_damage_mult() -> float:
	var m := 1.2 if Talents.has_sub(profile.talent, profile.talent_level, "summon", 1) else 1.0
	return m * (1.1 if dragon_active() else 1.0)


func _update_allies(dt: float) -> void:
	for a in allies:
		if a.dead:
			continue
		if a.ttl > 0.0:
			a.ttl -= dt
			if a.ttl <= 0.0:
				a.dead = true
				continue
		a.attack_cd -= dt
		var target: Enemy = null
		var best := ALLY_RANGE
		for e in enemies:
			if e.dead or is_hidden(e):
				continue
			var d: float = e.pos.distance_to(player.pos)
			if d < best:
				best = d
				target = e
		if target == null:
			if a.pos.distance_to(player.pos) > 70.0:
				a.pos = a.pos.move_toward(player.pos, ALLY_SPEED * dt)
			continue
		if a.pos.distance_to(target.pos) > a.radius + target.radius + 8.0:
			a.pos = a.pos.move_toward(target.pos, ALLY_SPEED * dt)
		elif a.attack_cd <= 0.0:
			a.attack_cd = 1.0
			var dmg := maxi(1, int(round(Formulas.compute_damage(a.atk, target.def) * ally_damage_mult())))
			_apply_damage(target, dmg, false, false)


# ------------------------------------------------------------------ thảo dược, rương (TL-S1, TL-S2)


func _update_herbs(dt: float) -> void:
	for h in herbs:
		if h.respawn > 0.0:
			h.respawn -= dt
			if h.respawn <= 0.0:
				h.pos = _random_field_pos()
			continue
		if h.pos.distance_to(player.pos) < 22.0:
			var gain := 2 if profile.talent == "thao-duoc" else 1
			profile.herbs += gain
			h.respawn = HERB_RESPAWN
			_text(player.pos + Vector2(0, -30), "+%d Thảo dược" % gain, Color("#5bd16a"), false)
			while profile.herbs >= HERBS_PER_POTION and profile.potions < POTION_MAX:
				profile.herbs -= HERBS_PER_POTION
				profile.potions += 1
				_message("Chế được 1 bình máu (%d/%d)." % [profile.potions, POTION_MAX], "good")


func chest_visible(c: Chest) -> bool:
	return not c.opened and profile.talent == "khuu-giac" and c.pos.distance_to(player.pos) <= CHEST_SENSE_R


func _update_chests() -> void:
	for c in chests:
		if c.opened or c.pos.distance_to(player.pos) > CHEST_OPEN_R:
			continue
		c.opened = true
		var gold: int = 10 * int(profile.level)
		profile.gold += gold
		profile.stones += 2
		var text := "Tìm thấy rương ẩn: +%d vàng, +2 Đá Cường Hoá" % gold
		if _r() < 0.3:
			var item := Items.new_item(profile, maxi(1, zone_level(c.pos.x)), "green" if _r() < 0.5 else "blue", _rng)
			text += ", " + str(Items.add_item(profile, item).message).trim_suffix(".")
		_message(text + ".", "good")
