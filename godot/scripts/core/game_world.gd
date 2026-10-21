extends RefCounted
## Mô phỏng thế giới: di chuyển, combat, AI quái, boss, EXP.
## Logic thuần, không vẽ gì, không phụ thuộc Node — test được ở chế độ headless.

const Config = preload("res://scripts/core/config.gd")
const Explore = preload("res://scripts/core/explore.gd")
const Formulas = preload("res://scripts/core/formulas.gd")
const Puzzle = preload("res://scripts/core/puzzle.gd")
const Stats = preload("res://scripts/core/stats.gd")
const Talents = preload("res://scripts/data/talents.gd")
const Monsters = preload("res://scripts/data/monsters.gd")
const Items = preload("res://scripts/core/items.gd")
const ItemData = preload("res://scripts/data/items.gd")
const Classes = preload("res://scripts/data/classes.gd")
const RngUtil = preload("res://scripts/core/rng_util.gd")
const Maps = preload("res://scripts/data/maps.gd")
const Story = preload("res://scripts/data/story.gd")
const Fog = preload("res://scripts/core/fog.gd")
## M6: chương 3 Sa Mạc Lãng Quên (docs/10) — logic trong core/chapter3.gd, ở đây chỉ có các dòng móc "Ch3.".
const Ch3 = preload("res://scripts/core/chapter3.gd")

## Toạ độ map 1-1 (Rừng Sương). Code dùng các biến theo map (world_size, safe_pos, …); hằng số giữ cho test và tham chiếu.
## SN-30: ×1,6 so với M4 — phải khớp maps.gd "1-1".
const WORLD_SIZE := Vector2(4160, 2560)
const VILLAGE_POS := Vector2(368, 1280)
const VILLAGE_R := 170.0
const ARENA_POS := Vector2(3664, 1280)
const ARENA_R := 270.0
## Bức tường sương mù chắn lối vào hang Sói Chúa khi chưa đủ điều kiện.
const GATE_X := 3664.0 - 270.0 - 60.0
## SN-30: diện tích map chuẩn (map M4) để nhân số quái/thảo dược/rương theo diện tích.
const BASE_AREA := 2600.0 * 1600.0
const FIELD_MOBS_CAP := 40

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
const BOSS_STUN := 5.0
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
## SN-05: phép diện rộng của Pháp Sư hút máu 50%.
const AOE_LIFESTEAL := 0.5
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

# --- MVP M3: lớp, kỹ năng, chiến đấu (docs/03-mvp-spec.md, mục 5)
const SHOT_INTERVAL := 0.6
const SHOT_RANGE := 450.0
const SHOT_SPEED := 700.0
const DASH_TIME := 0.2
const DASH_DIST := 180.0
const DASH_HIT_R := 40.0
const WAVE_RANGE := 400.0
const WAVE_SPEED := 600.0
const PIERCE_RANGE := 600.0
const PIERCE_SPEED := 900.0
const GUARD_TIME := 4.0
const GUARD_REDUCE := 0.5
const GUARD_POISE := 1.5
const RAIN_RANGE := 400.0
const RAIN_RADIUS := 90.0
const RAIN_TICKS := 5
const RAIN_INTERVAL := 0.3
const RAIN_BURST_K := 0.6
const TRAP_MAX := 2
const TRAP_TTL := 20.0
const TRAP_TRIGGER := 24.0
const TRAP_RADIUS := 60.0
const TRAP_ROOT := 2.0
const EAGLE_TIME := 6.0
const EAGLE_SPEED := 0.3
const EAGLE_CRIT := 0.15
## SN-03/04 (đợt SN2): Pháp Sư.
const FIRE_INTERVAL := 0.6
const FIRE_RANGE := 400.0
const FIRE_SPEED := 560.0
const FIRE_SPLASH := 40.0
const FIRE_SPLASH_MUL := 0.5
const CHAIN_RANGE := 350.0
const CHAIN_HOP := 150.0
const CHAIN_JUMPS := 4
const NOVA_RADIUS := 110.0
const NOVA_ROOT := 2.0
const METEOR_RANGE := 420.0
const METEOR_RADIUS := 100.0
const METEOR_DELAY := 0.8
const BARRIER_TIME := 6.0
const BARRIER_PCT := 0.3
## CB-04: né Hoàn hảo.
const PERFECT_WINDOW := 0.15
const SLOWMO_TIME := 1.0
const SLOWMO_SCALE := 0.3
## CB-07, CB-12: tinh anh.
const ELITE_POISE := 0.3
const ELITE_STUN := 3.0
const HOWL_CD := 15.0
const SPAWN_CD := 8.0
const HASTE_TIME := 6.0
const NAM_CON_FUSE := 3.0
const EXPLODE_R := 30.0
const STOMP_R := 60.0
const MAX_SUMMONS := 6
## TP-40 (CR-01): tỉ lệ cướp thuộc tính khi hạ quái.
const STEAL_FIELD := 0.03
const STEAL_ELITE := 0.30
const STEAL_LEVEL_GAP := 5
const STEAL_BOSS_POINTS := 3
const STEAL_RARE_POINTS := 5
# --- Đợt C1 phần C
const ROOT_TIME := 1.5
const ROOT_R := 30.0
const LEAF_RANGE := 110.0
const LEAF_ARC := PI / 6.0
const POISON_TIME := 4.0
const POISON_PCT := 0.02
const PUDDLE_R := 30.0
const PUDDLE_TIME := 3.0
const RARE_HEAL := 0.01
const RARE_SKILL_CD := 3.5
## M5-01: boss hiếm theo map (06 vùng 1–2). after = boss vùng phải ngã trước; purple = có rơi thêm 1 đồ Tím.
const RARE_BOSSES := {
	"1-3": {"kind": "lao-thu", "level": 9, "after": "boss", "unique": "lao_thu_bark", "purple": true,
		"say": "rare_boss", "down": "rare_boss_down", "intro": "Lão Thụ Sương Mù thức giấc giữa Lõi Sương! (boss hiếm)"},
	"2-3": {"kind": "bach-ho", "level": 20, "after": "huyen-anh", "unique": "bach_ho_claw", "purple": false,
		"say": "rare_bach_ho", "down": "rare_bach_ho_down", "intro": "Bạch Hổ Phong Vân lao ra từ Mắt Bão! (boss hiếm)"},
	"3-3": {"kind": "nhan-su", "level": 32, "after": "sa-hoang", "unique": "nhan_su_eye", "purple": false,
		"say": "rare_nhan_su", "down": "rare_nhan_su_down", "intro": "Nhân Sư Đá thức giấc giữa Di Tích! (boss hiếm)"},
}
## Bạch Hổ: Hổ Vồ (chuỗi 3 cú, vòng 6 m ×1,4), Gầm Gió (vòng 10 m: đẩy 8 m, choáng 1 giây), dưới 50% Cưỡi Gió (tốc ×1,5).
const TIGER_SKILL_CD := 4.0
const ROAR_CD := 9.0
const TIGER_WINDUP := 0.7
const TIGER_GAP := 0.4
const TIGER_CHAIN := 3
const TIGER_R := 60.0
const TIGER_MUL := 1.4
const TIGER_REACH := 220.0
const ROAR_WINDUP := 0.8
const ROAR_R := 100.0
const ROAR_PUSH := 80.0
const ROAR_STUN := 1.0
const RIDE_SPEED := 1.5
## Vuốt Bạch Hổ: chí mạng gây chảy máu ×0,3 mỗi giây trong 4 giây.
const BLEED_TIME := 4.0
const BLEED_MUL := 0.3
const BARK_STILL := 1.0
const BARK_REGEN := 0.02
const FOG_SIGHT := 200.0
# --- M4.2: vùng 2 (03-mvp-spec mục 6.3)
## GI-01…04: gió đẩy 6 m/giây, ngược gió −30%, xuôi gió +20%, đạn lệch tối đa 15°.
const WIND_PUSH := 60.0
const WIND_WARN := 2.0
const WIND_BEND := deg_to_rad(15.0)
const SHIELD_ARC := deg_to_rad(60.0)
const SHIELD_REDUCE := 0.3
## M5-02: lính khiên quay người tối đa 120°/giây — chạy vòng thì đánh được vào hông (lời Lạc Phong).
const SHIELD_TURN := deg_to_rad(120.0)
const DIVE_R := 30.0
const PULL_R := 80.0
const PULL_SPEED := 30.0
const PULL_BLAST := 40.0
const WHIRL_R := 50.0
const GALE_TIME := 6.0
const DECOY_RANGE := 300.0
const MASK_DECOY := 2.0
const CLONE_DECOY := 6.0
const CLONE_HP := 0.08
const CLONE_ATK := 0.5
const CLONE_BLAST := 40.0
const SWAP_PERIOD := 6.0
const BLINK_CD := 6.0
const DARTS_CD := 3.0

# --- MVP M4: nhiều bản đồ (03-mvp-spec mục 6.2)
## MP-03: thời gian đi đường giữa 2 map.
const TRAVEL_TIME := 4.0
## MP-05: thử thách vượt ải.
const CHALLENGE_GAP := 5
## NV-25: quái thấp hơn từ 10 cấp chỉ cho 10% EXP.
const LOW_LEVEL_GAP := 10
const LOW_LEVEL_EXP := 0.1
## C3-01: điều kiện mở vùng 3.
const REGION3_POWER := 5000
const REGION3_LEVEL := 18


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
	# M3
	var mp := 0.0
	var skill_cds := [0.0, 0.0, 0.0, 0.0]
	var dash_time := 0.0
	var dash_dir := Vector2.RIGHT
	var dash_mul := 1.0
	var dash_hit := {}
	# C1-23: Rễ Trói, Lá Độc
	var root_timer := 0.0
	var poison_timer := 0.0
	## M5-01: Gầm Gió — choáng: không đi, không đánh, không né.
	var stun_timer := 0.0
	var still := 0.0
	var guard_time := 0.0
	var eagle_time := 0.0
	var perfect_used := false
	# SN-04: Pháp Thuẫn
	var shield := 0.0
	var shield_time := 0.0
	# M6: Nguyền rủa, Lốc cát (chậm), Kìm kẹp (giữ chân), Độn Thổ (bất tử)
	var curse_timer := 0.0
	var slow_timer := 0.0
	var hold_timer := 0.0
	var burrow_t := 0.0


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
	# M3
	var root_timer := 0.0
	var haste_timer := 0.0
	var skill_cd := 4.0
	var fuse := -1.0
	## M4.2: hướng nhìn (khiên chặn); đứng yên khi đang vung đòn.
	var face := 0.0
	## M5-01: số cú Hổ Vồ còn lại trong chuỗi; chảy máu (Vuốt Bạch Hổ).
	var chain_left := 0
	var bleed_timer := 0.0
	var bleed_dmg := 0.0
	var bleed_tick := 0.0
	# M6: chui cát, Câu Đố Nhân Sư, độc Đuôi Sa Hoàng, lốc cát làm chậm
	var burrow_t := 0.0
	var burrow_cd := 2.0
	var puzzle_t := 0.0
	var venom_stacks := 0
	var venom_timer := 0.0
	var venom_tick := 0.0
	var slow_t := 0.0


## Đạn của người chơi: tên, kiếm khí, tên xuyên phá.
class PlayerShot:
	var pos := Vector2.ZERO
	var vel := Vector2.ZERO
	var ttl := 0.0
	var mul := 1.0
	var radius := 10.0
	var pierce := false
	var force_crit := false
	## "arrow" | "wave" | "pierce" | "fireball"
	var kind := "arrow"
	var hit := {}
	## SN-03: nổ lan khi trúng (Hỏa Cầu): bán kính, hệ số cho quái xung quanh.
	var splash := 0.0
	var splash_mul := 0.0


## SN-04: Thiên Thạch rơi sau METEOR_DELAY giây.
class Meteor:
	var pos := Vector2.ZERO
	var timer := 0.8
	var radius := 100.0
	var mul := 3.0


## SN-04: tia sét Lôi Xích (chỉ để vẽ).
class Bolt:
	var points := PackedVector2Array()
	var ttl := 0.3


## Mưa Tên.
class RainZone:
	var pos := Vector2.ZERO
	var radius := 90.0
	var mul := 0.6
	var ticks := 5
	var timer := 0.0


class Trap:
	var pos := Vector2.ZERO
	var ttl := 20.0
	var mul := 2.0


## C1-24: vũng độc Nấm Độc để lại khi chết.
class Hazard:
	var pos := Vector2.ZERO
	var radius := 30.0
	var ttl := 3.0


## Vòng nổ chỉ để vẽ (Bẫy Gai, Dậm đất, Nấm Con).
class Blast:
	var pos := Vector2.ZERO
	var radius := 30.0
	var ttl := 0.35
	var color := Color.WHITE


class Projectile:
	## Hệ của đạn (kháng hệ, M4.2).
	var element := ""
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
var slowmo_timer := 0.0
var shots: Array = []
var rains: Array = []
var traps: Array = []
var blasts: Array = []
var meteors: Array = []
var bolts: Array = []
var hazards: Array = []
## M4.2: gió (vector đơn vị, ZERO = không gió), hướng sắp đổi, đồng hồ, gió mạnh ×2 (Nghịch Phong).
var wind_dir := Vector2.ZERO
var wind_next := Vector2.ZERO
var wind_timer := 0.0
var wind_strong := 0.0
## Ảo ảnh hút đòn (Mặt Nạ Huyền Ảnh, Đạo Tặc — Phân Thân): [{pos, ttl}]
var decoys: Array = []
## Chém xoáy của Đội Trưởng: [{e, left, wait}]
var whirls: Array = []
var _incoming_el := ""
var _swap_timer := SWAP_PERIOD
## Giờ Unix (test đặt để giả lập thời gian thực; < 0 = đồng hồ máy).
var debug_now := -1.0
## C1-33: tự đánh (phím Z).
var auto_fight := false
## C1-40: id âm thanh phát trong khung hình này (main.gd chuyển cho AudioManager rồi xoá).
var sfx: Array = []
var combo := 0
var time := 0.0
## Sinh lại quái thường ngoài đồng. Test cân bằng boss (TL-B, TL-B2) tắt để chỉ đo trận boss (SN2).
var field_spawn := true
## SN-31: sương che của map hiện tại.
var fog = Fog.new()
var ch3 = Ch3.State.new()
var _fog_timer := 0.0
## Phiên bản sương đã lưu vào hồ sơ (đổi thì lưu lại + kiểm thưởng).
var _fog_saved := -1

# M4: map hiện tại
var map_id := "1-1"
var map: Dictionary = {}
var world_size := WORLD_SIZE
var safe_pos := VILLAGE_POS
var safe_r := VILLAGE_R
var arena_pos := ARENA_POS
var arena_r := ARENA_R
## Không có tường thì INF.
var gate_x := GATE_X
## MP-03: đang đi đường tới travel_target (giây còn lại).
var travel_timer := 0.0
var travel_target := ""

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
var _face_lock := 0.0
var _quest_poll := 0.0
## Đòn bắn vừa tự nhắm (N9) — ngắm bù gió, chỉ lệch 1/3 (5°).
var _auto_aimed := false
## Người chơi đang dùng bàn phím (chuột đứng yên) — main.gd gửi qua input "kb_aim".
var _kb_aim := false
const AUTO_AIM_BEND := 1.0 / 3.0


func _init(p, rng: Callable) -> void:
	profile = p
	_rng = rng
	stats = _derive()
	player.hp = stats.max_hp
	player.mp = stats.max_mp
	_load_map(profile.map_id if Maps.MAPS.has(profile.map_id) else "1-1")
	_begin_quest_step()


## Dựng map: vị trí, quái, thảo dược, rương, thú cưng (MP-01, MP-07).
func _load_map(id: String) -> void:
	map_id = id
	map = Maps.get_map(id)
	profile.map_id = id
	# M4.3 (KP-01): mỗi vùng một lưới khai phá; `tiles` luôn là lưới của vùng đang đứng.
	var region := int(map.get("region", 1))
	if region != int(profile.tiles_region) or profile.tiles.is_empty():
		profile.switch_grid(region, func(r): return Explore.create_region_tiles(r, _rng, profile.talent))
	if region == 2 and int(profile.quest.ch2) == 0:
		profile.quest.ch2 = 1
		say("r2_arrive")
	if not (id in profile.unlocked_maps):
		profile.unlocked_maps.append(id)
	world_size = map.size
	safe_pos = map.safe.pos
	safe_r = float(map.safe.r)
	if map.arena != null:
		arena_pos = map.arena.pos
		arena_r = float(map.arena.r)
	else:
		arena_pos = Vector2(-99999, -99999)
		arena_r = 0.0
	gate_x = (arena_pos.x - arena_r - 60.0) if map.gate else INF
	enemies = []
	projectiles = []
	shots = []
	rains = []
	traps = []
	blasts = []
	meteors = []
	bolts = []
	hazards = []
	decoys = []
	whirls = []
	pickups = []
	_init_wind()
	allies = []
	herbs = []
	chests = []
	freeze_timer = 0.0
	slowmo_timer = 0.0
	player.pos = safe_pos + Vector2(60, 0)
	# SN-31: nạp sương của map; vùng an toàn luôn mở sẵn.
	fog.setup(world_size, str(profile.fog.get(id, "")))
	fog.reveal(safe_pos, safe_r + 260.0)
	fog.reveal(player.pos, Fog.REVEAL_R)
	profile.fog[id] = fog.encode()
	for _i in field_mob_cap():
		_spawn_field_mob()
	for _i in roundi(HERB_NODES * area_factor()):
		var h := Herb.new()
		h.pos = _random_field_pos()
		herbs.append(h)
	for _i in roundi(CHESTS * area_factor()):
		var c := Chest.new()
		c.pos = _random_field_pos()
		chests.append(c)
	for pet in profile.pets:
		_add_ally("pet", str(pet.kind), int(pet.level), player.pos)
	Ch3.on_load(self)


## Cấp quái theo vị trí trên map hiện tại.
func level_at(x: float) -> int:
	return Maps.level_at(map, x)


## Cấp quái theo vị trí trên map 1-1 (giữ cho test cũ).
static func zone_level(x: float) -> int:
	return Maps.level_at(Maps.get_map("1-1"), x)


## SN-31/32: mở sương quanh nhân vật 5 lần/giây; đủ mốc 50% / 90% thì thưởng (1 lần mỗi map).
func _update_fog(dt: float) -> void:
	_fog_timer -= dt
	if _fog_timer > 0.0:
		return
	_fog_timer = 0.2
	fog.reveal(player.pos, Fog.REVEAL_R)
	if fog.version == _fog_saved:
		return
	_fog_saved = fog.version
	profile.fog[map_id] = fog.encode()
	_check_fog_rewards()


func _check_fog_rewards() -> void:
	var got: Array = profile.fog_rewards.get(map_id, [])
	var pct := fog.ratio() * 100.0
	for mark in Fog.REWARD_MARKS:
		if pct < mark or mark in got:
			continue
		got.append(mark)
		profile.fog_rewards[map_id] = got
		if mark == 50:
			profile.torches = mini(Explore.torch_max(profile), profile.torches + 1)
			_message("Khám phá 50%% %s: +1 Đuốc Khai Giới." % map.name, "good")
		else:
			var gold := 100 * int(map.get("region", 1))
			profile.essence += 1
			profile.gold += gold
			_message("Khám phá trọn %s! +1 Thiên Phú Tinh Hoa, +%d vàng." % [map.name, gold], "good")
			_sfx("levelup")


## % khám phá của một map (0–1).
func explore_ratio(id: String) -> float:
	if id == map_id:
		return fog.ratio()
	return Fog.ratio_of(str(profile.fog.get(id, "")), Maps.get_map(id).size)


## SN-30: diện tích map hiện tại so với map chuẩn M4.
func area_factor() -> float:
	return world_size.x * world_size.y / BASE_AREA


func field_mob_cap() -> int:
	return mini(FIELD_MOBS_CAP, roundi(Config.MAX_FIELD_MOBS * area_factor()))


func talent() -> Dictionary:
	return Talents.get_talent(profile.talent)


func class_def() -> Dictionary:
	return Classes.get_class_def(profile.class_id)


func is_hunter() -> bool:
	return profile.class_id == "tho-san"


func is_mage() -> bool:
	return profile.class_id == "phap-su"


## Lớp đánh xa (Thợ Săn, Pháp Sư): tự nhắm, bot giữ khoảng cách.
func is_ranged() -> bool:
	return is_hunter() or is_mage()


## TP-41: giá trị hiệu ứng chính theo cấp Thiên phú.
func tv(v1: float, v10: float) -> float:
	return Talents.lv_value(v1, v10, profile.talent_level)


func explored() -> float:
	return Explore.explored_ratio(profile.tiles)


## Tường sương mù trước hang boss đã mở chưa (map không có tường thì luôn mở).
func boss_unlocked() -> bool:
	if not map.gate:
		return true
	if map_id == "1-1":
		return profile.boss_defeated or (profile.level >= Config.BOSS_LEVEL_REQ and Explore.owned_count(profile.tiles) >= Config.BOSS_TILES_REQ)
	return gate_open(map_id)


## Điều kiện mở tường các map sau. Mắt Bão: lật mặt Mạc Tam (nhiệm vụ chương 2 bước 5) hoặc đã hạ Huyền Ảnh.
func gate_open(id: String) -> bool:
	if id == "3-3":
		return int(profile.quest.ch3) >= 5 or is_boss_defeated("sa-hoang")
	if id == "2-3":
		return int(profile.quest.ch2) >= 5 or is_boss_defeated("huyen-anh")
	return true


func arena_boss() -> String:
	return str(map.arena.boss) if map.arena != null else ""


func is_boss_defeated(boss_id: String) -> bool:
	return profile.boss_defeated if boss_id == "boss" else bool(profile.bosses.get(boss_id, false))


# ------------------------------------------------------------------ M4.1: di chuyển giữa map (MP-02…05)


## Lý do không vào được map; "" nếu được. Map đã mở điểm dịch chuyển thì luôn vào được.
func travel_blocker(id: String) -> String:
	if not Maps.MAPS.has(id):
		return "Vùng đất này chưa mở trong bản thử nghiệm."
	if id == map_id:
		return "Bạn đang ở đây."
	if id in profile.unlocked_maps:
		return ""
	var m: Dictionary = Maps.MAPS[id]
	var req := map_requirement(id)
	if req != "":
		return req
	if profile.level + CHALLENGE_GAP < int(m.levels[0]):
		return "Cần cấp %d (vượt ải cho phép thấp hơn tối đa %d cấp)." % [int(m.levels[0]) - CHALLENGE_GAP, CHALLENGE_GAP]
	return ""


## Điều kiện cốt truyện để mở map lần đầu.
func map_requirement(id: String) -> String:
	match id:
		"1-3":
			return "" if profile.boss_defeated else "Hạ Sói Chúa Hư Vô để mở Lõi Sương."
		"2-1":
			# Kịch bản mục 6: hạ boss vùng + khai phá ≥ 60% vùng 1 (cấp: thử thách vượt ải ≤ 5 cấp).
			if not profile.boss_defeated:
				return "Hạ Sói Chúa Hư Vô trước."
			if Explore.explored_ratio(profile.grid_of(1)) < Config.EXPLORE_REQ:
				return "Khai phá ≥ %d%% vùng 1 (đang %d%%)." % [roundi(Config.EXPLORE_REQ * 100), roundi(Explore.explored_ratio(profile.grid_of(1)) * 100)]
		"2-2":
			return "" if "2-1" in profile.unlocked_maps else "Tới Cửa Gió trước."
		"2-3":
			return "" if "2-2" in profile.unlocked_maps else "Tới Thảo Nguyên Hú trước."
		"3-1":
			# C3-01 (docs/10, Q53): hạ Huyền Ảnh + Lực chiến ≥ 5.000 + cấp ≥ 18.
			if not is_boss_defeated("huyen-anh"):
				return "Hạ Tướng Gián Điệp Huyền Ảnh trước."
			if combat_power() < REGION3_POWER:
				return "Cần Lực chiến %d (đang %d)." % [REGION3_POWER, combat_power()]
			if profile.level < REGION3_LEVEL:
				return "Cần cấp %d." % REGION3_LEVEL
		"3-2":
			return "" if "3-1" in profile.unlocked_maps else "Tới Rìa Cát Đỏ trước."
		"3-3":
			return "" if "3-2" in profile.unlocked_maps else "Tới Ốc Đảo Lãng Quên trước."
	return ""


## Cảnh báo thử thách vượt ải (MP-05); "" nếu đủ cấp.
func challenge_warning(id: String) -> String:
	if not Maps.MAPS.has(id):
		return ""
	var lo: int = int(Maps.MAPS[id].levels[0])
	if profile.level < lo:
		return "Thử thách vượt ải: quái ở đây mạnh hơn bạn tới %d cấp. Hạ quái cao hơn bạn từ %d cấp được EXP ×2." % [lo - profile.level, CHALLENGE_GAP]
	return ""


func in_combat() -> bool:
	return time - _last_combat < OUT_OF_COMBAT


func travel_seconds() -> float:
	# TP-23: Chân Không Biết Mỏi đi đường nhanh hơn 10% → 15%.
	return TRAVEL_TIME * ((1.0 - tv(0.1, 0.15)) if profile.talent == "chan-khong" else 1.0)


func travel(id: String) -> Dictionary:
	var res := {"ok": false, "message": ""}
	var block := travel_blocker(id)
	if block == "" and boss() != null:
		block = "Không thể rời đi khi boss đang ở trước mặt."
	elif block == "" and in_combat():
		block = "Đang giao chiến — thoát khỏi quái 3 giây rồi mới lên đường."
	elif block == "" and player.dead_timer > 0.0:
		block = "Đợi hồi sinh đã."
	if block != "":
		res.message = block
		_message(block, "bad")
		return res
	travel_target = id
	travel_timer = travel_seconds()
	res.ok = true
	res.message = "Lên đường tới %s…" % Maps.MAPS[id].name
	_message(res.message, "info")
	return res


func _arrive() -> void:
	var id := travel_target
	travel_target = ""
	travel_timer = 0.0
	var first: bool = not (id in profile.unlocked_maps)
	_load_map(id)
	_events.append({"type": "map", "map_id": id, "first": first})
	if id == "1-3":
		say("core")
	_message("Đã tới %s (cấp %d–%d).%s" % [map.name, map.levels[0], map.levels[1], " Mở điểm dịch chuyển." if first else ""], "good")
	var warn := challenge_warning(id)
	if warn != "":
		_message(warn, "bad")


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
	if Ch3.is_hidden(e):
		return true
	# C1-22: sương Lõi Sương — Tinh Linh Sương ở xa hơn 20 m thì tàng hình.
	if map_id == "1-3" and e.kind == "wisp" and e.state != "windup" and e.state != "stunned" \
			and e.pos.distance_to(player.pos) > FOG_SIGHT:
		return true
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
	if Explore.tick_garden(profile, dt) > 0:
		_text(player.pos + Vector2(0, -30), "Vườn Thảo Dược +1", Color("#5bd16a"), false)
		_brew_potions()
	for key in Explore.tick_build_clock(profile, dt):
		_on_built(key)

	# MP-03: đang đi đường thì thế giới đứng yên.
	if travel_timer > 0.0:
		travel_timer -= dt
		if travel_timer <= 0.0:
			_arrive()
		return
	_update_fog(dt)
	var p := player
	if p.dead_timer > 0.0:
		p.dead_timer -= dt
		if p.dead_timer <= 0.0:
			_respawn()
		return

	p.attack_cd -= dt
	p.skill_cd -= dt
	for i in 4:
		p.skill_cds[i] -= dt
	p.guard_time -= dt
	p.eagle_time -= dt
	p.shield_time -= dt
	if p.shield_time <= 0.0:
		p.shield = 0.0
	_update_wind(dt)
	Ch3.tick(self, dt)
	player.burrow_t -= dt
	for dc in decoys:
		dc.ttl -= dt
	decoys = decoys.filter(func(dc): return dc.ttl > 0.0)
	_update_whirls(dt)
	_update_player_effects(dt, input)
	p.mp = minf(float(stats.max_mp), p.mp + float(stats.mp_regen) * dt)
	p.talent_cd -= dt
	p.potion_cd -= dt
	p.dodge_cd -= dt
	p.swing -= dt
	p.hurt -= dt
	_gate_msg_cd -= dt
	_quest_poll -= dt
	if _quest_poll <= 0.0:
		_quest_poll = 0.5
		_check_quest_state()
		_check_quest2()
		Ch3.check_quest(self)
		_check_rare_boss()
	_passive_msg_cd -= dt
	_combo_timer -= dt
	if _combo_timer <= 0.0:
		combo = 0

	input = _auto_input(input)
	_kb_aim = bool(input.get("kb_aim", false))
	var aim: Vector2 = input.aim
	_aim = aim
	_face_lock -= dt
	# Sau khi tự xoay mặt (C1-01) giữ hướng đó hết đòn đánh rồi mới theo lại hướng ngắm.
	if aim.distance_to(p.pos) > 0.5 and _face_lock <= 0.0:
		p.facing = (aim - p.pos).angle()
	_move_player(dt, input)
	var busy := p.dodge_time > 0.0 or p.dash_time > 0.0 or p.stun_timer > 0.0
	if input.attack and p.attack_cd <= 0.0 and not busy:
		_basic_attack()
	for i in 4:
		# K / chuột phải ("skill") là kỹ năng 1 (Q29).
		if not busy and (input.get("skill_%d" % (i + 1), false) or (i == 0 and input.get("skill", false))):
			use_skill(i)
	if input.talent and p.stun_timer <= 0.0:
		_use_talent()
	if input.get("potion", false):
		drink_potion()

	if freeze_timer > 0.0:
		freeze_timer -= dt
	else:
		# CB-04: sau né Hoàn hảo, quái và đạn chậm còn 30%.
		var edt := dt * (SLOWMO_SCALE if slowmo_timer > 0.0 else 1.0)
		for e in enemies:
			if not e.dead:
				_update_enemy(e, edt)
		_separate_enemies()
		_update_projectiles(edt)
	slowmo_timer -= dt
	_update_shots(dt)
	_update_rains(dt)
	_update_traps(dt)
	_update_mage(dt)
	for b in blasts:
		b.ttl -= dt
	blasts = blasts.filter(func(b): return b.ttl > 0.0)
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
	if input.dodge and p.dodge_cd <= 0.0 and p.dodge_time <= 0.0 and p.root_timer <= 0.0 and p.stun_timer <= 0.0:
		p.dodge_dir = move.normalized() if move.length() > 0.01 else Vector2.from_angle(p.facing)
		p.dodge_time = DODGE_TIME
		quest_event("dodge")
		_sfx("dodge")
		p.dodge_cd = float(stats.get("dodge_cd", DODGE_CD))
		# Mặt Nạ Huyền Ảnh: né lăn để lại phân thân hút đòn.
		if has_unique("huyen_anh_mask"):
			_add_decoy(p.pos, MASK_DECOY)
		p.perfect_used = false

	var vel := Vector2.ZERO
	if p.root_timer > 0.0 or p.stun_timer > 0.0:
		p.dodge_time = 0.0
		p.dash_time = 0.0
	elif p.dash_time > 0.0:
		p.dash_time -= dt
		vel = p.dash_dir * (DASH_DIST / DASH_TIME)
	elif p.dodge_time > 0.0:
		p.dodge_time -= dt
		vel = p.dodge_dir * DODGE_SPEED
	elif move.length() > 0.0 and p.hold_timer <= 0.0:
		vel = move / maxf(1.0, move.length()) * move_speed() * wind_factor(move)
	# GI-02/04: gió đẩy (không đẩy khi né lăn, Đột Kích, bị trói).
	if wind_dir != Vector2.ZERO and p.dodge_time <= 0.0 and p.dash_time <= 0.0 and p.root_timer <= 0.0 and p.stun_timer <= 0.0:
		vel += wind_dir * WIND_PUSH * wind_power()
	p.pos = (p.pos + vel * dt).clamp(Vector2.ONE * PLAYER_RADIUS, world_size - Vector2.ONE * PLAYER_RADIUS)
	_enforce_gate()
	_enforce_arena_lock()
	if p.swing_kind == "dash" and p.swing > 0.0:
		_dash_hits()

	if map.arena != null and boss_available() and boss() == null and p.pos.distance_to(arena_pos) < arena_r:
		var b := spawn_enemy(arena_boss(), int(map.arena.level), arena_pos + Vector2(120, 0), {"role": "boss"})
		b.state = "chase"
		_message("%s xuất hiện! Đánh vào thanh Phá Thế để làm nó choáng." % b.name, "bad")
		if b.kind == "boss":
			_sfx("boss_roar")
			say("boss")


## Chân Không Biết Mỏi: +10% tốc chạy khi không giao chiến.
func move_speed() -> float:
	var v := float(stats.move_speed)
	if player.slow_timer > 0.0:
		v *= 1.0 - Ch3.SLOW_PCT
	if profile.talent == "chan-khong" and time - _last_combat > OUT_OF_COMBAT:
		v *= 1.0 + tv(0.1, 0.15)
	return v


func _enforce_gate() -> void:
	var p := player
	if not boss_unlocked() and p.pos.x > gate_x:
		p.pos.x = gate_x
		if _gate_msg_cd <= 0.0:
			_message(
				("Sương mù Hư Vô chặn đường: cần cấp %d và chiếm %d ô đất (phím M)." % [Config.BOSS_LEVEL_REQ, Config.BOSS_TILES_REQ])
				if map_id == "1-1" else "Bão cát chắn lối vào Phủ Huyền Ảnh — hoàn thành nhiệm vụ Liên minh ở Thành Biên Đài trước.",
				"bad"
			)
			_gate_msg_cd = 4.0


## CB-23 (M3): boss đã xuất hiện thì lối ra hang đóng lại tới khi boss chết hoặc người chơi gục
## (không cho đánh xa từ ngoài hang trong khi boss bị giữ trong hang).
func _enforce_arena_lock() -> void:
	if boss() == null:
		return
	var p := player
	var off := p.pos - arena_pos
	var limit := arena_r - PLAYER_RADIUS
	if off.length() > limit:
		p.pos = arena_pos + off.normalized() * limit


## Lần đầu: chưa hạ. Sau đó: hồi sinh khi đủ 10 phút chơi (EQ-07).
func boss_available() -> bool:
	var id := arena_boss()
	if id == "":
		return false
	if id == "boss":
		return not profile.boss_defeated or profile.play_seconds >= profile.boss_respawn_at
	return not is_boss_defeated(id) or profile.play_seconds >= float(profile.boss_respawn.get(id, 0.0))


func atk_speed() -> float:
	return float(stats.atk_speed) * (1.0 + EAGLE_SPEED if player.eagle_time > 0.0 else 1.0)


func _basic_attack() -> void:
	if is_hunter():
		_shoot()
	elif is_mage():
		_cast_fireball()
	else:
		_slash()


## SN-03: Hỏa Cầu — tự nhắm như Thợ Săn, nổ lan 4 m khi trúng quái đầu tiên.
func _cast_fireball() -> void:
	var p := player
	_soft_lock(FIRE_RANGE)
	p.attack_cd = FIRE_INTERVAL / atk_speed()
	p.swing = 0.18
	p.swing_kind = "cast"
	_sfx("shot")
	var m := _basic_mul()
	var s := _fire(FIRE_SPEED, FIRE_RANGE, m[0] * Ch3.fireball_mult(self), false, "fireball", m[1], 12.0)
	s.splash = FIRE_SPLASH
	s.splash_mul = FIRE_SPLASH_MUL


## Hệ số đòn đánh thường (chém hoặc bắn): Kiếm Tâm, Nanh Sói Chúa, Nhất Kiếm Đoạn. Trả về [hệ số, chắc chí mạng].
func _basic_mul() -> Array:
	var p := player
	p.hits += 1
	var double: bool = profile.talent == "kiem-tam" and p.hits % 5 == 0
	if double:
		_text(p.pos + Vector2(0, -34), "Kiếm Tâm!", Color("#5bd16a"), true)
	var fang: bool = has_unique("wolf_fang") and p.hits % FANG_EVERY == 0
	var mul := (tv(2.0, 2.5) if double else 1.0) * (FANG_MUL if fang else 1.0)
	# Kiếm Tâm — Nhất Kiếm Đoạn: đòn kế tiếp ×3 (Lv10 ×3,5), chắc chắn chí mạng.
	var empowered := _super_slash
	_super_slash = false
	if empowered:
		mul *= tv(3.0, 3.5)
	return [mul, empowered]


## Thợ Săn: bắn tên 45 m, trúng quái đầu tiên.
## C1-01: hướng đang ngắm không có quái (trong cung/nón `half_arc`, tầm `reach`) mà vẫn có quái trong tầm
## → quay mặt về quái gần nhất. Trả về true nếu đã xoay.
func _auto_face(reach: float, half_arc: float) -> bool:
	var p := player
	var nearest: Enemy = null
	var best := INF
	for e in enemies:
		if e.dead or world_hidden(e):
			continue
		var to_e: Vector2 = e.pos - p.pos
		var d := to_e.length()
		if d > reach + e.radius:
			continue
		if absf(angle_difference(p.facing, to_e.angle())) <= half_arc or d <= e.radius + PLAYER_RADIUS:
			return false
		if d < best:
			best = d
			nearest = e
	if nearest == null:
		return false
	p.facing = (nearest.pos - p.pos).angle()
	_face_lock = 0.35
	return true


## Spec_Notes N9: Thợ Săn luôn bắn quái gần nhất trong tầm (kể cả khi đang chạy, không cần ngắm).
func _face_nearest(reach: float) -> bool:
	var p := player
	var nearest: Enemy = null
	var best := INF
	for e in enemies:
		if e.dead or is_hidden(e):
			continue
		var d: float = e.pos.distance_to(p.pos) - e.radius
		if d <= reach and d < best:
			best = d
			nearest = e
	if nearest == null:
		return false
	p.facing = (nearest.pos - p.pos).angle()
	_face_lock = 0.35
	_auto_aimed = true
	return true


## Khoá mục tiêu mềm: dùng chuột → quái gần nhất trong hướng ngắm (±15°); bàn phím hoặc hướng ngắm trống → quái gần nhất.
## Đòn đã khoá được ngắm bù gió (chỉ lệch 1/3).
func _soft_lock(reach: float) -> bool:
	if not _kb_aim:
		var best: Enemy = null
		var bd := INF
		for e in enemies:
			if e.dead or is_hidden(e):
				continue
			var to_e: Vector2 = e.pos - player.pos
			var d: float = to_e.length()
			if d <= reach + e.radius and absf(angle_difference(player.facing, to_e.angle())) <= deg_to_rad(15.0) and d < bd:
				bd = d
				best = e
		if best != null:
			player.facing = (best.pos - player.pos).angle()
			_face_lock = 0.35
			_auto_aimed = true
			return true
	return _face_nearest(reach)


func world_hidden(e: Enemy) -> bool:
	return is_hidden(e)


func _shoot() -> void:
	var p := player
	# N9: chơi bàn phím → luôn bắn quái gần nhất; dùng chuột → quái trong hướng ngắm (±15°) trước,
	# không có mới bắn quái gần nhất (để chủ động nhắm được bản thật của Huyền Ảnh).
	_soft_lock(SHOT_RANGE)
	p.attack_cd = SHOT_INTERVAL / atk_speed()
	p.swing = 0.16
	p.swing_kind = "shot"
	_sfx("shot")
	var m := _basic_mul()
	_fire(SHOT_SPEED, SHOT_RANGE, m[0], false, "arrow", m[1])
	Ch3.after_shot(self, m[0])


func _fire(speed: float, reach: float, mul: float, pierce: bool, kind: String, force_crit := false, radius := 10.0) -> PlayerShot:
	var p := player
	var dir := wind_bend(Vector2.from_angle(p.facing), AUTO_AIM_BEND if _auto_aimed else 1.0)
	_auto_aimed = false
	var s := PlayerShot.new()
	s.pos = p.pos + dir * PLAYER_RADIUS
	s.vel = dir * speed
	s.ttl = reach / speed
	s.mul = mul
	s.pierce = pierce
	s.kind = kind
	s.force_crit = force_crit
	s.radius = radius
	shots.append(s)
	return s


func _update_shots(dt: float) -> void:
	# M6: bão cát — đạn bay chậm 30% (tầm giữ nguyên).
	var sm := Ch3.shot_mult(self)
	for s in shots:
		s.pos += s.vel * dt * sm
		s.ttl -= dt * sm
		if s.ttl <= 0.0:
			continue
		for e in enemies:
			if e.dead or s.hit.has(e.id):
				continue
			if s.pos.distance_to(e.pos) <= s.radius + e.radius:
				s.hit[e.id] = true
				_hit_enemy(e, s.mul, s.force_crit)
				if s.splash > 0.0:
					_splash(s, e)
				if not s.pierce:
					s.ttl = 0.0
					break
	shots = shots.filter(func(s): return s.ttl > 0.0)


## SN-03: nổ lan của Hỏa Cầu — quái khác trong bán kính nhận s.mul × splash_mul.
func _splash(s: PlayerShot, center: Enemy) -> void:
	_blast(center.pos, s.splash, Color("#ff7a3c"))
	for o in enemies:
		if o.dead or o == center:
			continue
		if o.pos.distance_to(center.pos) <= s.splash + o.radius:
			_hit_enemy(o, s.mul * s.splash_mul, false, true)


## Quái còn sống gần `from` nhất trong tầm, bỏ qua các id trong `skip`.
func _nearest_enemy(from: Vector2, reach: float, skip := {}) -> Enemy:
	var best: Enemy = null
	var bd := INF
	for e in enemies:
		if e.dead or is_hidden(e) or skip.has(e.id):
			continue
		var d: float = e.pos.distance_to(from) - e.radius
		if d <= reach and d < bd:
			bd = d
			best = e
	return best


## SN-04 Lôi Xích: sét đánh quái gần nhất (ưu tiên theo hướng ngắm), nảy tối đa CHAIN_JUMPS lần.
func _chain(mul: float) -> void:
	var p := player
	_soft_lock(CHAIN_RANGE)
	var first: Enemy = null
	var dir := Vector2.from_angle(p.facing)
	var bd := INF
	for e in enemies:
		if e.dead or is_hidden(e):
			continue
		var to_e: Vector2 = e.pos - p.pos
		var d: float = to_e.length() - e.radius
		if d <= CHAIN_RANGE and absf(angle_difference(dir.angle(), to_e.angle())) <= deg_to_rad(20.0) and d < bd:
			bd = d
			first = e
	if first == null:
		first = _nearest_enemy(p.pos, CHAIN_RANGE)
	p.swing = 0.2
	p.swing_kind = "cast"
	var b := Bolt.new()
	b.points.append(p.pos)
	if first == null:
		b.points.append(p.pos + dir * CHAIN_RANGE * 0.5)
		bolts.append(b)
		return
	var hit := {}
	var cur := first
	for _i in CHAIN_JUMPS + Ch3.chain_jumps(self) + 1:
		hit[cur.id] = true
		b.points.append(cur.pos)
		_hit_enemy(cur, mul, false, true)
		var nxt := _nearest_enemy(cur.pos, CHAIN_HOP, hit)
		if nxt == null:
			break
		cur = nxt
	bolts.append(b)


## SN-04 Băng Ngục: nổ băng quanh mình, trói quái. Ngũ Hành Bộc Phá: vòng lớn hơn, sát thương cao hơn.
func _nova(mul: float) -> void:
	var p := player
	var burst := _consume_burst()
	var radius := maxf(BURST_RANGE, NOVA_RADIUS * 1.3) if burst else NOVA_RADIUS
	var m := mul * ((1.0 + tv(1.0, 1.5)) if burst else 1.0)
	_blast(p.pos, radius, Color("#9de0ff"))
	Ch3.sand_trail(self, p.pos, radius)
	_sfx("explode")
	p.swing = 0.25
	p.swing_kind = "cast"
	for e in enemies:
		if not e.dead and e.pos.distance_to(p.pos) <= radius + e.radius:
			e.root_timer = maxf(e.root_timer, NOVA_ROOT)
			_hit_enemy(e, m, false, true)


## SN-04 Thiên Thạch: vòng báo hiệu tại điểm ngắm (không có quái thì quái gần nhất trong tầm).
func _meteor(mul: float) -> void:
	var p := player
	var pos := p.pos + (_aim - p.pos).limit_length(METEOR_RANGE)
	var any_near := false
	for e in enemies:
		if not e.dead and e.pos.distance_to(pos) <= METEOR_RADIUS + e.radius:
			any_near = true
			break
	if not any_near:
		var n := _nearest_enemy(p.pos, METEOR_RANGE)
		if n != null:
			pos = n.pos
	var m := Meteor.new()
	m.pos = pos
	m.timer = METEOR_DELAY
	m.radius = METEOR_RADIUS
	m.mul = mul
	meteors.append(m)
	p.swing = 0.3
	p.swing_kind = "cast"


func _update_mage(dt: float) -> void:
	for m in meteors:
		m.timer -= dt
		if m.timer > 0.0:
			continue
		_blast(m.pos, m.radius, Color("#ff9a3c"))
		_sfx("explode")
		for e in enemies:
			if not e.dead and e.pos.distance_to(m.pos) <= m.radius + e.radius:
				_hit_enemy(e, m.mul, false, true)
	meteors = meteors.filter(func(m): return m.timer > 0.0)
	for b in bolts:
		b.ttl -= dt
	bolts = bolts.filter(func(b): return b.ttl > 0.0)


func _slash() -> void:
	var p := player
	_auto_face(SLASH_RANGE, SLASH_ARC)
	p.attack_cd = SLASH_INTERVAL / atk_speed()
	p.swing = 0.16
	p.swing_kind = "slash"
	_sfx("slash")
	var m := _basic_mul()
	var mul: float = m[0]
	var empowered: bool = m[1]
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
	Ch3.after_slash(self)


## Dùng kỹ năng i (0–3) của lớp. Trả về true nếu dùng được.
func use_skill(i: int) -> bool:
	var p := player
	var sk: Dictionary = Classes.skill(profile.class_id, i)
	if p.skill_cds[i] > 0.0 or p.dead_timer > 0.0:
		return false
	if p.mp < float(sk.mp):
		if _passive_msg_cd <= 0.0:
			_text(p.pos + Vector2(0, -40), "Thiếu MP", Color("#4a9df8"), false)
			_passive_msg_cd = 1.0
		return false
	p.mp -= float(sk.mp)
	p.skill_cds[i] = skill_cd_of(i)
	if i == 0:
		p.skill_cd = p.skill_cds[0]
	var mul := float(sk.mul) * float(stats.skill_mul)
	match sk.id:
		"spin":
			_spin(mul)
		"dash":
			var dir := _aim - p.pos
			p.dash_dir = dir.normalized() if dir.length() > 1.0 else Vector2.from_angle(p.facing)
			p.dash_time = DASH_TIME
			p.dash_mul = mul
			p.dash_hit = {}
			p.swing = DASH_TIME + 0.05
			p.swing_kind = "dash"
		"wave":
			_auto_face(WAVE_RANGE, deg_to_rad(15.0))
			_fire(WAVE_SPEED, WAVE_RANGE, mul, true, "wave", false, 22.0)
			p.swing = 0.16
			p.swing_kind = "slash"
		"guard":
			p.guard_time = GUARD_TIME
			_text(p.pos + Vector2(0, -40), "Thiết Bích!", Color("#c8e6ff"), true)
		"rain":
			_rain(mul)
		"pierce":
			_soft_lock(PIERCE_RANGE)
			_fire(PIERCE_SPEED, PIERCE_RANGE, mul, true, "pierce", false, 12.0)
			p.swing = 0.16
			p.swing_kind = "shot"
		"trap":
			var t := Trap.new()
			t.pos = p.pos
			t.ttl = TRAP_TTL
			t.mul = mul
			traps.append(t)
			while traps.size() > TRAP_MAX:
				traps.pop_front()
		"chain":
			_chain(mul)
		"nova":
			_nova(mul)
		"meteor":
			_meteor(mul)
		"barrier":
			p.shield = float(stats.max_hp) * BARRIER_PCT
			p.shield_time = BARRIER_TIME
			_text(p.pos + Vector2(0, -40), "Pháp Thuẫn!", Color("#b36bff"), true)
		"eagle":
			p.eagle_time = EAGLE_TIME
			_text(p.pos + Vector2(0, -40), "Ưng Nhãn!", Color("#ffc940"), true)
	quest_event("skill")
	_sfx("skill")
	return true


func skill_cd_of(i: int) -> float:
	if i == 0 and profile.class_id == "kiem-khach":
		return float(stats.spin_cd)
	var sk: Dictionary = Classes.skill(profile.class_id, i)
	if sk.id == "pierce":
		return Ch3.pierce_cd(self, float(sk.cd))
	return float(sk.cd)


func skill_mp(i: int) -> float:
	return float(Classes.skill(profile.class_id, i).mp)


## Ngũ Hành Bộc Phá: kỹ năng 1 trong 2 giây sau khi đổi hệ (+100%, Lv10 +150%). Trả về true nếu kích hoạt.
func _consume_burst() -> bool:
	var burst: bool = profile.talent == "ngu-hanh" and time - _element_switch_at <= BURST_WINDOW
	if burst:
		_element_switch_at = -99.0
		_text(player.pos + Vector2(0, -40), "Ngũ Hành Bộc Phá!", Color(Monsters.ELEMENT_HEX[profile.element]), true)
	return burst


func _spin(mul := SPIN_MUL) -> void:
	var p := player
	p.swing = 0.3
	p.swing_kind = "spin"
	var burst := _consume_burst()
	var radius := (BURST_RANGE if burst else SPIN_RANGE) * Ch3.spin_mult(self)
	for e in enemies:
		if not e.dead and e.pos.distance_to(p.pos) <= radius + e.radius:
			_hit_enemy(e, mul * ((1.0 + tv(1.0, 1.5)) if burst else 1.0))
	Ch3.sand_trail(self, p.pos, radius)


func _dash_hits() -> void:
	var p := player
	for e in enemies:
		if e.dead or p.dash_hit.has(e.id):
			continue
		if e.pos.distance_to(p.pos) <= DASH_HIT_R + e.radius:
			p.dash_hit[e.id] = true
			_hit_enemy(e, p.dash_mul)


func _rain(mul: float) -> void:
	var p := player
	var burst := _consume_burst()
	var z := RainZone.new()
	z.pos = p.pos + (_aim - p.pos).limit_length(RAIN_RANGE)
	# C1-01: điểm ngắm không có quái → rơi vào quái gần nhất trong tầm.
	var any_near := false
	var nearest_pos := z.pos
	var best := INF
	for e in enemies:
		if e.dead:
			continue
		if e.pos.distance_to(z.pos) <= RAIN_RADIUS + e.radius:
			any_near = true
		var d: float = e.pos.distance_to(p.pos)
		if d <= RAIN_RANGE and d < best:
			best = d
			nearest_pos = e.pos
	if not any_near:
		z.pos = nearest_pos
	z.radius = BURST_RANGE if burst else RAIN_RADIUS
	# M6 (TL-B2): Bộc Phá cộng vào mỗi đợt của 5 đợt ×0,6 → tổng thêm bằng Xoáy Kiếm (×1,8) thì hệ số 0,6.
	z.mul = mul * ((1.0 + tv(1.0, 1.5) * RAIN_BURST_K) if burst else 1.0)
	z.ticks = RAIN_TICKS
	z.timer = 0.0
	rains.append(z)
	Ch3.sand_trail(self, z.pos, z.radius)
	p.swing = 0.2
	p.swing_kind = "shot"


func _update_rains(dt: float) -> void:
	for z in rains:
		z.timer -= dt
		if z.timer > 0.0 or z.ticks <= 0:
			continue
		z.timer = RAIN_INTERVAL
		z.ticks -= 1
		for e in enemies:
			if not e.dead and e.pos.distance_to(z.pos) <= z.radius + e.radius:
				_hit_enemy(e, z.mul)
	rains = rains.filter(func(z): return z.ticks > 0 or z.timer > 0.0)


func _update_traps(dt: float) -> void:
	for t in traps:
		t.ttl -= dt
		if t.ttl <= 0.0:
			continue
		var triggered := false
		for e in enemies:
			if not e.dead and e.pos.distance_to(t.pos) <= TRAP_TRIGGER + e.radius:
				triggered = true
				break
		if not triggered:
			continue
		t.ttl = 0.0
		_blast(t.pos, TRAP_RADIUS, Color("#ffc940"))
		_sfx("explode")
		for e in enemies:
			if not e.dead and e.pos.distance_to(t.pos) <= TRAP_RADIUS + e.radius:
				e.root_timer = TRAP_ROOT
				_hit_enemy(e, t.mul)
	traps = traps.filter(func(t): return t.ttl > 0.0)


func _blast(pos: Vector2, radius: float, color: Color) -> void:
	var b := Blast.new()
	b.pos = pos
	b.radius = radius
	b.color = color
	blasts.append(b)


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
			var heal := float(stats.max_hp) * tv(0.3, 0.45)
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
			freeze_timer = tv(FREEZE_TIME, 4.5) + (1.0 if Talents.has_sub(profile.talent, profile.talent_level, "control", 2) else 0.0)
			_text(p.pos + Vector2(0, -40), "Thời Gian Ngưng Đọng!", Color("#b36bff"), true)
		"bay-dan":
			var n := 0
			for i in roundi(tv(3.0, 5.0)):
				if _ally_count("shadow") < ally_cap("shadow"):
					_add_ally("shadow", "wolf", profile.level, p.pos + Vector2.from_angle(i / 3.0 * TAU) * 50.0)
					n += 1
			_text(p.pos + Vector2(0, -40), "Bóng Tối Trỗi Dậy +%d" % n, Color("#b36bff"), true)
			used = n > 0
		"dao-tac":
			if profile.copied_skills.is_empty():
				_message("Đạo Tặc chưa sao chép kỹ năng nào — hãy hạ một boss.", "info")
				used = false
			elif active_copy() == "burrow":
				Ch3.copy_burrow(self)
			elif active_copy() == "clone":
				# Phân Thân: 2 ảo ảnh hút đòn 6 giây.
				for k in 2:
					_add_decoy(p.pos + Vector2.from_angle(k * PI + 0.6) * 60.0, CLONE_DECOY)
				_text(p.pos + Vector2(0, -40), "Phân Thân!", Color("#b36bff"), true)
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
	if t.id == "trai-tim":
		cd = tv(300.0, 200.0)
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
		return str(COPY_NAMES.get(active_copy(), "Chưa sao chép"))
	if t.id == "ngu-hanh":
		return "Đổi hệ (%s)" % Monsters.ELEMENT_NAMES[profile.element]
	return t.skill.name


## Đạo Tặc — Vồ Mồi: lao tới điểm ngắm, gây sát thương diện rộng.
func _leap() -> void:
	var p := player
	var dest := p.pos + (_aim - p.pos).limit_length(LEAP_DIST)
	p.pos = dest.clamp(Vector2.ONE * PLAYER_RADIUS, world_size - Vector2.ONE * PLAYER_RADIUS)
	_enforce_gate()
	p.swing = 0.3
	p.swing_kind = "spin"
	var mul := LEAP_MUL * (1.0 + tv(0.0, 0.3)) * (1.2 if Talents.has_sub(profile.talent, profile.talent_level, "special", 1) else 1.0)
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
	_sfx("heal")
	p.potion_cd = POTION_CD
	p.hp = minf(float(stats.max_hp), p.hp + heal)
	_text(p.pos + Vector2(0, -30), "+%d HP" % roundi(heal), Color("#5bd16a"), true)


func potion_heal() -> float:
	return float(stats.max_hp) * POTION_HEAL * ((1.0 + tv(0.3, 0.45)) if profile.talent == "thao-duoc" else 1.0) * Ch3.heal_mult(self)


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
	profile.points[stat] = int(profile.points.get(stat, 0)) + 1
	profile.unspent -= 1
	_refresh_stats()


## Tẩy điểm miễn phí trước cấp 30 (tài liệu mục 4).
func respec() -> bool:
	if profile.level >= Config.FREE_RESPEC_LEVEL:
		return false
	# ST-05: trả lại cả INT, LUK. Điểm Đạo Tặc cướp không bị tẩy (DT-06).
	for k in Stats.STATS:
		profile.unspent += int(profile.points.get(k, 0))
	profile.points = {"str": 0, "agi": 0, "int": 0, "vit": 0, "luk": 0}
	_refresh_stats()
	return true


func _derive(equipment = null) -> Dictionary:
	var bonus := Items.equipment_bonus(profile.equipment if equipment == null else equipment)
	bonus["dragon"] = dragon_active()
	# KP-06: Bến Cá +3% HP tối đa mỗi cái (tối đa +15%).
	bonus.max_hp_pct += Explore.fishery_hp_pct(profile)
	# TB-05: bộ cộng hưởng Thiên phú ("Người Khai Hoang") — ≥ 4 món của bộ + Thiên phú đúng nhóm.
	var group := str(talent().group)
	if int(bonus.sets.get("frost_hunter", 0)) >= 4 and group == "combat":
		bonus.flat["crit"] = float(bonus.flat.get("crit", 0.0)) + 0.05
	if int(bonus.sets.get("phong_hanh", 0)) >= 4 and group == "explore":
		bonus.move_pct += 0.10
	Ch3.derive_bonus(self, bonus)
	var st := Stats.derive(profile.level, profile.points, profile.talent, bonus, profile.talent_level, profile.class_id, profile.stolen)
	Ch3.derive_after(bonus, st)
	return st


## Long Mạch Đàn đã xây xong (TL-S7).
func dragon_active() -> bool:
	return profile.talent == "long-mach" and Explore.is_built(profile, "dragon")


## EQ-11: đổi chỉ số giữ nguyên tỉ lệ HP hiện tại.
func _refresh_stats() -> void:
	var ratio := clampf(player.hp / maxf(1.0, float(stats.max_hp)), 0.0, 1.0)
	var mp_ratio := clampf(player.mp / maxf(1.0, float(stats.max_mp)), 0.0, 1.0)
	stats = _derive()
	player.hp = ratio * float(stats.max_hp)
	player.mp = mp_ratio * float(stats.max_mp)


## Hồi chiêu kỹ năng 1 (giữ cho HUD/test cũ).
func skill_cd() -> float:
	return skill_cd_of(0)


func has_unique(id: String) -> bool:
	return id in stats.uniques


func combat_power() -> int:
	return Items.combat_power(stats)


## Lực chiến nếu mặc thêm món này (để so sánh trong túi đồ).
## SN-20: tính cả cấp cường hoá được chuyển từ đồ đang mặc.
func power_if_equipped(item: Dictionary) -> int:
	var eq: Dictionary = profile.equipment.duplicate()
	var it := item.duplicate()
	it.plus = Items.plus_after_equip(profile, item)
	eq[item.slot] = it
	return Items.combat_power(_derive(eq))


# ------------------------------------------------------------------ SN-10…12: phân rã / bán nhanh

func bulk_filter() -> Dictionary:
	return Items.normalize_filter(profile.bulk_filter)


func set_bulk_filter(f: Dictionary) -> void:
	profile.bulk_filter = Items.normalize_filter(f)


## Món trong túi khớp bộ lọc đang lưu.
func bulk_list() -> Array:
	var now := combat_power()
	return Items.bulk_candidates(profile, bulk_filter(), func(item): return power_if_equipped(item) < now)


func salvage_many(items: Array) -> Dictionary:
	var n := 0
	var stones0: int = profile.stones
	var tk0: int = profile.tinh_kim
	for item in items:
		if Items.salvage(profile, int(item.id), _rng).ok:
			n += 1
	if n == 0:
		return _shop_result(false, "Không có món nào khớp bộ lọc.")
	var msg := "Phân rã nhanh %d món: +%d Đá Cường Hoá." % [n, profile.stones - stones0]
	if profile.tinh_kim > tk0:
		msg += " Bàn Tay Vàng: +%d Tinh Kim!" % (profile.tinh_kim - tk0)
	return _shop_result(true, msg)


func sell_many(items: Array) -> Dictionary:
	var n := 0
	var gold := 0
	for item in items:
		var i := Items.find_in_bag(profile, int(item.id))
		if i < 0:
			continue
		var price := sell_price(profile.inventory[i])
		profile.inventory.remove_at(i)
		profile.gold += price
		gold += price
		n += 1
	if n == 0:
		return _shop_result(false, "Không có món nào khớp bộ lọc.")
	return _shop_result(true, "Bán nhanh %d món: +%d vàng." % [n, gold])


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
		player.mp = stats.max_mp
		_events.append({"type": "levelup", "level": profile.level})
		_sfx("levelup")
		_message(
			"Lên cấp %d! +%d điểm tiềm năng (C), +1 Đuốc Khai Giới." % [profile.level, Config.POINTS_PER_LEVEL], "good"
		)


## Trả về true nếu đòn trúng (không bị né).
func _damage_player(atk: float, mul: float) -> bool:
	var p := player
	if p.dead_timer > 0.0:
		return false
	if p.dash_time > 0.0 or p.burrow_t > 0.0:
		return false
	atk *= Ch3.night_mult(self)
	if p.dodge_time > 0.0:
		# CB-04: chặn đòn trong 0,15 giây đầu của né lăn = Hoàn hảo.
		if not p.perfect_used and DODGE_TIME - p.dodge_time <= PERFECT_WINDOW:
			p.perfect_used = true
			_sfx("perfect")
			slowmo_timer = SLOWMO_TIME
			_text(p.pos + Vector2(0, -40), "Hoàn hảo!", Color("#ffc940"), true)
		else:
			_text(p.pos + Vector2(0, -28), "Né!", Color("#9de0e6"), false)
		return false
	# ST-04: né tránh.
	if _r() < float(stats.evasion):
		_text(p.pos + Vector2(0, -28), "Né!", Color("#9de0e6"), false)
		return false
	# NV-17: kháng hệ của đòn (quái đánh mang hệ của nó).
	var res: float = float(stats.get("res", {}).get(_incoming_el, 0.0))
	_incoming_el = ""
	var dmg := maxi(1, int(round(Formulas.compute_damage(atk, stats.def, mul) * (GUARD_REDUCE if p.guard_time > 0.0 else 1.0) * (1.0 - res))))
	_last_combat = time
	# SN-04: Pháp Thuẫn hút sát thương trước.
	if p.shield > 0.0:
		var absorbed := minf(p.shield, float(dmg))
		p.shield -= absorbed
		dmg -= int(absorbed)
		if p.shield <= 0.0:
			p.shield_time = 0.0
			_text(p.pos + Vector2(0, -40), "Khiên vỡ", Color("#b36bff"), false)
		if dmg <= 0:
			_text(p.pos + Vector2(0, -26), "Hút", Color("#b36bff"), false)
			return true
	p.hp -= dmg
	p.hurt = 0.2
	_sfx("player_hurt")
	combo = 0
	_text(p.pos + Vector2(0, -26), "-%d" % dmg, Color("#ff5470"), false)
	if p.hp <= 0.0:
		_die()
	return true


func _die() -> void:
	player.hp = 0.0
	player.dead_timer = RESPAWN_TIME
	_events.append({"type": "death"})
	_message("Bạn đã gục ngã… hồi sinh tại %s." % str(map.safe.name), "bad")
	# Gục trước boss hiếm: nó hồi đầy máu, ở lại chờ (C1-23).
	for e in enemies:
		if e.role == "rare":
			e.hp = e.max_hp
			e.poise = e.max_poise
			e.state = "idle"
		if e.role == "rareMinion" or e.kind == "goc-re":
			e.dead = true
	var fled := boss()
	if fled != null:
		for e in enemies:
			if e.role == "boss" or e.role == "bossMinion":
				e.dead = true
		_message("%s rút về hang, hồi phục toàn bộ sinh lực." % fled.name, "bad")


func _respawn() -> void:
	player.pos = safe_pos + Vector2(60, 0)
	player.hp = stats.max_hp
	player.mp = stats.max_mp
	player.dodge_time = 0.0
	player.dash_time = 0.0
	for e in enemies:
		if e.role == "summon" or (e.role == "field" and e.pos.distance_to(safe_pos) < safe_r + 220.0):
			e.dead = true
	projectiles = []


# ------------------------------------------------------------------ quái


## aoe: đòn phép diện rộng của Pháp Sư — Hấp Huyết chỉ hút 50% (SN-05, 05 mục 5).
func _hit_enemy(e: Enemy, skill_mul: float, force_crit := false, aoe := false) -> void:
	var talent_bonus := tv(0.2, 0.3) if profile.talent == "huyet-chien" and player.hp < float(stats.max_hp) * 0.3 else 0.0
	var crit := force_crit or _r() < float(stats.crit) + (EAGLE_CRIT if player.eagle_time > 0.0 else 0.0)
	var mul := skill_mul * ((1.0 + float(stats.crit_dmg)) if crit else 1.0) * (1.5 if e.broken else 1.0) * Ch3.hit_mult(self, e, crit)
	var raw := Formulas.compute_damage(stats.atk, e.def, mul, element_bonus(e), talent_bonus) * (0.9 + _r() * 0.2)
	var dmg := maxi(1, int(round(raw)))
	_last_combat = time
	combo += 1
	_combo_timer = COMBO_TIMEOUT
	# Hấp Huyết: 8% sát thương thành máu.
	if profile.talent == "hap-huyet":
		player.hp = minf(float(stats.max_hp), player.hp + dmg * tv(LIFESTEAL, 0.12) * (AOE_LIFESTEAL if aoe else 1.0) * Ch3.heal_mult(self))
	# Thuần Thú Sư: đòn làm quái thường hoặc quái Ổ quái (TP-30) tụt dưới 10% (Lv10 15%) HP thì thu phục.
	if profile.talent == "thuan-thu" and e.role in ["field", "nestMinion"] and not e.elite and e.kind != "nam-con" \
			and e.hp - dmg > 0.0 and e.hp - dmg < e.max_hp * tv(TAME_HP, 0.15) and _ally_count("pet") < ally_cap("pet"):
		_tame(e)
		return
	_apply_damage(e, dmg, crit, true)
	# M5-01: Vuốt Bạch Hổ — chí mạng gây chảy máu.
	if crit and not e.dead and has_unique("bach_ho_claw"):
		if e.bleed_timer <= 0.0:
			e.bleed_tick = 0.0
		e.bleed_timer = BLEED_TIME
		e.bleed_dmg = Formulas.compute_damage(stats.atk, e.def, BLEED_MUL)
	Ch3.on_player_hit(self, e)


## TL-S6: Ngũ Hành Linh Căn đánh hệ khắc +30% (Phép thuật cấp 5: +40%).
func element_bonus(e: Enemy) -> float:
	if profile.talent != "ngu-hanh":
		return 0.0
	if not Monsters.counters(profile.element, Monsters.DEFS[e.kind].element):
		return 0.0
	return tv(Monsters.COUNTER_BONUS, 0.4) + (0.1 if Talents.has_sub(profile.talent, profile.talent_level, "magic", 1) else 0.0)


func _apply_damage(e: Enemy, dmg: int, crit: bool, by_player: bool) -> void:
	dmg = Ch3.adjust_damage(self, e, dmg, by_player)
	if dmg <= 0:
		return
	# M4.2: Khiên chặn — giảm 70% sát thương đến từ phía trước (±60° hướng nhìn).
	if by_player and Monsters.DEFS[e.kind].get("shield", false) and e.state != "stunned" \
			and absf(angle_difference(e.face, (player.pos - e.pos).angle())) <= SHIELD_ARC:
		dmg = maxi(1, roundi(dmg * SHIELD_REDUCE))
		_text(e.pos + Vector2(0, -e.radius - 22), "Chặn!", Color("#9ba8bc"), false)
	e.hp -= dmg
	e.hit_flash = 0.12
	var color := (Color("#ffc940") if crit else Color.WHITE) if by_player else Color("#c9b6ff")
	_text(e.pos + Vector2(0, -e.radius - 8), ("%d!" if crit else "%d") % dmg, color, crit)
	if by_player:
		_sfx("crit" if crit else "hit")
	if e.state == "idle":
		e.state = "chase"

	# CB-07: boss và tinh anh có thanh Phá Thế; Thiết Bích +50% vào thanh.
	if e.max_poise > 0.0:
		_damage_poise(e, dmg * (GUARD_POISE if by_player and player.guard_time > 0.0 else 1.0))
	if e.role != "boss" and by_player and e.state != "windup":
		e.pos += (e.pos - player.pos).normalized() * 10.0

	if e.hp <= 0.0:
		_kill_enemy(e)
	elif e.role == "boss" and e.kind == "huyen-anh":
		_huyen_phase(e)
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
		e.chain_left = 0
		if e.role == "boss":
			e.timer = BOSS_STUN
			_message("Phá Thế! %s choáng 5 giây và nhận thêm 50%% sát thương." % e.name, "good")
		else:
			e.timer = ELITE_STUN
			_text(e.pos + Vector2(0, -e.radius - 24), "Phá Thế!", Color("#ffc940"), true)


func _boss_phase_two(e: Enemy) -> void:
	if Ch3.boss_phase_two(self, e):
		return
	e.phase = 2
	say("boss2")
	for i in 3:
		var offset := Vector2.from_angle(i / 3.0 * TAU) * 90.0
		var wolf := spawn_enemy("wolf", 5, e.pos + offset, {"role": "bossMinion"})
		wolf.state = "chase"
	_message("Sói Chúa hú gọi bầy sói và ẩn mình vào sương mù!", "bad")


func _kill_enemy(e: Enemy) -> void:
	e.dead = true
	_sfx("enemy_die")
	if e.role == "bossClone":
		# Bản sao Huyền Ảnh bị hạ: nổ vòng 4 m ×0,8, không cho EXP/đồ.
		_blast(e.pos, CLONE_BLAST, Color("#b36bff"))
		if e.pos.distance_to(player.pos) <= CLONE_BLAST + PLAYER_RADIUS:
			_incoming_el = "kim"
			_damage_player(e.atk, 0.8)
		return
	profile.kills += 1
	if e.role == "quest":
		quest_event("kill_quest")
	if int(map.get("region", 1)) == 2 and int(profile.quest.ch2) == 2:
		profile.quest.kills2 = int(profile.quest.kills2) + 1
	Ch3.on_kill(self, e)
	var is_boss := e.role == "boss"
	var base := float(boss_exp(e.level)) if is_boss else float(Formulas.mob_exp(e.level, e.elite))
	if e.role == "rare":
		base = float(roundi(0.5 * Formulas.exp_to_next(e.level)))
	elif e.role == "rareMinion" or e.kind == "goc-re":
		base *= 0.5
	add_exp(base * Formulas.combo_exp_multiplier(combo) * exp_level_mult(e.level), true)

	var pk := Pickup.new()
	pk.pos = e.pos
	pk.kind = "gold"
	pk.value = float(BOSS_GOLD) if is_boss else round(e.level * 3 * (4 if e.elite else 1) * (0.8 + _r() * 0.4))
	if e.role == "rare":
		pk.value = 80.0 * e.level
	# C1-24: Nấm Độc chết để lại vũng độc.
	if e.kind == "mushroom":
		var hz := Hazard.new()
		hz.pos = e.pos
		hz.radius = PUDDLE_R
		hz.ttl = PUDDLE_TIME
		hazards.append(hz)
	if e.role == "rare":
		_on_rare_killed(e)
	pickups.append(pk)
	if e.elite or _r() < 0.15:
		var orb := Pickup.new()
		orb.pos = e.pos + Vector2(14, -10)
		orb.kind = "orb"
		orb.value = 0.2
		pickups.append(orb)

	_drop_loot(e)
	# Bầy Đàn Bóng Tối: 15% quái bị hạ đứng dậy làm lính bóng tối.
	if profile.talent == "dao-tac":
		_try_steal(e)
	if profile.talent == "bay-dan" and not is_boss and _r() < tv(SHADOW_CHANCE, 0.225) and _ally_count("shadow") < ally_cap("shadow"):
		_add_ally("shadow", e.kind, e.level, e.pos)
	if e.elite and profile.torches < Explore.torch_max(profile):
		profile.torches += 1
		_message("Hạ %s: +1 Đuốc Khai Giới." % e.name, "good")
	if e.nest_tile_id >= 0 and Explore.conquer_tile(profile, e.nest_tile_id):
		_events.append({"type": "tile", "tile_id": e.nest_tile_id})
		_message("Đã chiếm Ổ quái! Lãnh địa mở rộng thêm một ô.", "good")
	if is_boss and e.kind != "boss":
		_on_boss_killed(e)
	elif is_boss:
		var first_kill: bool = not profile.boss_defeated
		profile.boss_defeated = true
		profile.boss_respawn_at = profile.play_seconds + BOSS_RESPAWN_SEC
		if not ("1-3" in profile.unlocked_maps):
			profile.unlocked_maps.append("1-3")
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


## CB-22: EXP boss = 0,3 × EXP lên cấp của boss.
## M5-02: boss chương = 60% EXP cấp của boss (cũ 30%) — boss + boss hiếm ≈ 20% EXP mỗi chương.
static func boss_exp(level := BOSS_LEVEL) -> int:
	return roundi(0.6 * Formulas.exp_to_next(level))


## MP-05: quái cao hơn từ 5 cấp → EXP ×2. NV-25: quái thấp hơn từ 10 cấp → 10% EXP.
func exp_level_mult(mob_level: int) -> float:
	if mob_level >= profile.level + CHALLENGE_GAP:
		return 2.0
	if mob_level <= profile.level - LOW_LEVEL_GAP:
		return LOW_LEVEL_EXP
	return 1.0


## TP-40 (CR-01): Đạo Tặc cướp thuộc tính khi hạ quái.
func _try_steal(e: Enemy) -> void:
	var is_boss := e.role == "boss" or e.role == "rare"
	if not is_boss and e.level < profile.level - STEAL_LEVEL_GAP:
		return
	var rate := 1.0 if (is_boss or e.role == "nestGuard") else (STEAL_ELITE if e.elite else STEAL_FIELD)
	if _r() >= minf(1.0, rate * tv(1.0, 1.5)):
		return
	var table: Dictionary = Monsters.DEFS[e.kind].steal
	var gained: Array = []
	for _i in (STEAL_RARE_POINTS if e.role == "rare" else (STEAL_BOSS_POINTS if is_boss else 1)):
		var stat: String = RngUtil.pick_weighted(table.keys(), func(k): return float(table[k]), _rng)
		profile.stolen.append(stat)
		gained.append(Monsters.STAT_NAMES[stat])
		# DT-03/04: giới hạn 1 × cấp, đầy thì bỏ điểm cũ nhất.
		while profile.stolen.size() > profile.level:
			profile.stolen.pop_front()
	_refresh_stats()
	var label := ", ".join(gained.map(func(x): return "+1 " + x))
	_message("Đạo Tặc: cướp %s từ %s (%d/%d)." % [label, e.name, profile.stolen.size(), profile.level], "good")
	_text(e.pos + Vector2(0, -e.radius - 30), label, Color("#ff5470"), true)


## Boss các chương sau (M4.2+).
func _on_boss_killed(e: Enemy) -> void:
	var first: bool = not is_boss_defeated(e.kind)
	profile.bosses[e.kind] = true
	profile.boss_respawn[e.kind] = profile.play_seconds + BOSS_RESPAWN_SEC
	for m in enemies:
		if m.role == "bossMinion" or m.role == "bossClone":
			m.dead = true
	profile.essence += ESSENCE_PER_BOSS
	profile.tinh_kim += 1
	_message("%s đã ngã xuống! +%d Thiên Phú Tinh Hoa, +1 Tinh Kim." % [e.name, ESSENCE_PER_BOSS], "good")
	# TP-39: Đạo Tặc sao chép kỹ năng boss.
	var copy: String = {"huyen-anh": "clone", "sa-hoang": "burrow"}.get(e.kind, "")
	if profile.talent == "dao-tac" and copy != "" and not (copy in profile.copied_skills):
		profile.copied_skills.append(copy)
		profile.active_copy = copy
		_message("Đạo Tặc sao chép kỹ năng của %s: %s (phím L; đổi ở bảng Thiên phú)." % [e.name, COPY_NAMES[copy]], "good")
	if first:
		_events.append({"type": "victory", "boss": e.kind})


## EQ-04/05/06: rơi trang bị và Đá Cường Hoá.
func _drop_loot(e: Enemy) -> void:
	if e.role == "rare":
		var rd := _rare_def(e.kind)
		if rd.get("purple", true):
			_drop_item(e.pos, e.level, "purple")
		_drop_item(e.pos + Vector2(24, 0), e.level, "orange", str(rd.get("unique", "lao_thu_bark")))
		return
	if e.role == "boss":
		_drop_item(e.pos, e.level, "purple")
		if _r() < ItemData.BOSS_UNIQUE_CHANCE:
			_drop_item(e.pos + Vector2(20, 0), e.level, "orange", str(ItemData.BOSS_UNIQUES.get(e.kind, ItemData.BOSS_UNIQUE)))
		return
	if e.elite:
		_drop_item(e.pos, e.level, Items.roll_rarity("elite", _rng))
		return
	# May Mắn Nhỏ: +5 điểm % rơi đồ và rơi đá (Q7).
	var luck := tv(0.05, 0.075) if profile.talent == "may-man" else 0.0
	# ST-02: LUK cộng tỉ lệ rơi đồ.
	if _r() < ItemData.FIELD_ITEM_CHANCE + luck + float(stats.drop_bonus):
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
		set_id = str(ItemData.REGION_SETS.get(int(map.get("region", 1)), ItemData.REGION_SET))
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
	e.root_timer -= dt
	e.haste_timer -= dt
	if e.bleed_timer > 0.0:
		e.bleed_timer -= dt
		e.bleed_tick += dt
		if e.bleed_tick >= 1.0:
			e.bleed_tick -= 1.0
			_apply_damage(e, maxi(1, roundi(e.bleed_dmg)), false, false)
			if e.dead:
				return
	if Ch3.update_enemy(self, e, dt):
		return
	if e.role == "rare":
		_update_rare(e, dt)
	# M4.2: hướng nhìn (khiên chặn) — không quay người khi đang vung đòn.
	if e.state != "windup" and e.state != "stunned":
		var want := (p.pos - e.pos).angle()
		if def.get("shield", false):
			e.face = rotate_toward(e.face, want, SHIELD_TURN * dt)
		else:
			e.face = want
	# Ảo ảnh hút đòn: quái trong 30 m quay sang đánh ảo ảnh gần nhất.
	var dc := _nearest_decoy(e.pos)
	if not dc.is_empty() and e.state in ["idle", "chase"] and e.kind != "goc-re":
		e.state = "chase"
		e.face = (dc.pos - e.pos).angle()
		if e.pos.distance_to(dc.pos) > e.radius + 24.0:
			_move_toward(e, dc.pos, e.speed, dt)
		return
	if e.kind == "huyen-anh" and e.role == "boss":
		_update_huyen_anh(e, dt)
	if e.state == "windup" and e.attack_kind == "pull" and e.pos.distance_to(p.pos) <= PULL_R + PLAYER_RADIUS and p.dodge_time <= 0.0:
		p.pos = p.pos.move_toward(e.pos, PULL_SPEED * dt)
	# Nấm Con tự nổ sau 3 giây.
	if e.fuse > 0.0:
		e.fuse -= dt
		if e.fuse <= 0.0 and e.state in ["idle", "chase", "recover"]:
			_begin_attack(e, "explode", def.windup)
			return
	# Quái thường không theo vào làng; quái ngoài hang không theo vào hang Sói Chúa.
	var outsider := e.role != "boss" and e.role != "bossMinion"
	var player_safe := (
		p.pos.distance_to(safe_pos) < safe_r or (outsider and p.pos.distance_to(arena_pos) < arena_r) \
			or (outsider and Ch3.oasis_at(self, p.pos) >= 0)
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
					Vector2(40, 40), world_size - Vector2(40, 40)
				)
				e.timer = 2.0 + _r() * 3.0
			else:
				_move_toward(e, e.wander, e.speed * 0.35, dt)
			var aggro := 2000.0 if e.role == "boss" else (700.0 if e.role == "rare" else 260.0)
			if alive and not player_safe and d < aggro:
				e.state = "chase"
		"chase":
			var leash := e.role != "boss" and (d > (900.0 if e.role == "rare" else 560.0) or player_safe)
			if not alive or leash:
				e.state = "idle"
				e.home = e.pos
				e.timer = 0.0
				return
			if e.role == "boss" and e.kind == "huyen-anh":
				e.skill_cd -= dt
				e.pounce_cd -= dt
				if e.pounce_cd <= 0.0:
					# Thoắt ẩn: ra sau lưng người chơi rồi chém.
					e.pos = _clamp_to_arena(p.pos - Vector2.from_angle(p.facing) * 70.0, e.radius)
					_begin_attack(e, "blink", 0.4)
					e.pounce_cd = BLINK_CD
					return
				if e.skill_cd <= 0.0 and d > 110.0:
					_begin_attack(e, "darts", 0.5)
					e.skill_cd = DARTS_CD
					return
			if e.role == "boss" and e.kind == "boss":
				e.pounce_cd -= dt
				if e.pounce_cd <= 0.0 and d > 150.0:
					_begin_attack(e, "pounce", 0.85)
					e.pounce_cd = 5.0
					return
			if e.role == "rare" and e.kind == "bach-ho":
				e.skill_cd -= dt
				e.pounce_cd -= dt
				# Đứng sát thì thỉnh thoảng Gầm Gió hất ra (hồi 9 giây); còn lại Hổ Vồ đuổi theo.
				if e.pounce_cd <= 0.0 and d < ROAR_R:
					e.pounce_cd = ROAR_CD
					_begin_attack(e, "roar", ROAR_WINDUP)
					return
				if e.skill_cd <= 0.0:
					e.skill_cd = TIGER_SKILL_CD
					e.chain_left = TIGER_CHAIN
					_begin_attack(e, "tiger", TIGER_WINDUP)
					return
			if e.role == "rare" and e.kind == "lao-thu":
				e.skill_cd -= dt
				if e.skill_cd <= 0.0:
					e.skill_cd = RARE_SKILL_CD
					if d < LEAF_RANGE + e.radius:
						_begin_attack(e, "leaf", 0.8)
					else:
						_begin_attack(e, "roots", 1.2)
					return
			if Ch3.chase(self, e, d, dt):
				return
			if e.elite and def.has("elite_skill"):
				e.skill_cd -= dt
				if e.skill_cd <= 0.0:
					_elite_skill(e, def.elite_skill)
			if d <= e.radius + e.attack_range + PLAYER_RADIUS:
				_begin_attack(e, def.attack, def.windup)
				return
			_move_toward(e, p.pos, e.speed, dt)
		"windup":
			e.timer -= dt
			if e.timer <= 0.0:
				_perform_attack(e)
				if e.chain_left > 0 and not e.dead and e.state == "windup":
					_begin_attack(e, e.attack_kind, TIGER_GAP)
				else:
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
	if kind == "tiger":
		e.target = (e.pos + (e.target - e.pos).limit_length(TIGER_REACH)).clamp(Vector2(40, 40), world_size - Vector2(40, 40))


func _perform_attack(e: Enemy) -> void:
	var p := player
	var def: Dictionary = Monsters.DEFS[e.kind]
	_incoming_el = str(def.element)
	match e.attack_kind:
		"melee":
			if e.pos.distance_to(p.pos) <= e.radius + e.attack_range + PLAYER_RADIUS + 12.0:
				_damage_player(e.atk, float(def.get("melee_mul", 1.0)))
		"dive":
			# Ưng Gió — Bổ nhào: lao xuống chỗ đã đánh dấu.
			e.pos = e.target
			_blast(e.target, DIVE_R, Color("#e8e2c8"))
			if e.target.distance_to(p.pos) <= DIVE_R + PLAYER_RADIUS:
				_damage_player(e.atk, 1.3)
		"volley":
			# Cung Thủ — Bắn ba mũi, nón 30°, mỗi mũi ×0,7.
			for k in [-1, 0, 1]:
				_enemy_shot(e, (e.target - e.pos).angle() + k * deg_to_rad(15.0), 0.7, 300.0)
		"darts":
			# Huyền Ảnh — Ám tiễn: 3 phi tiêu nón 40°, mỗi phi tiêu ×0,8.
			for k in [-1, 0, 1]:
				_enemy_shot(e, (e.target - e.pos).angle() + k * deg_to_rad(20.0), 0.8, 340.0)
		"dart1":
			# Bản sao: 1 phi tiêu (đánh ×0,5 qua chỉ số).
			_enemy_shot(e, (e.target - e.pos).angle(), 1.0, 320.0)
		"blink":
			_blast(e.pos, 60.0, Color("#b36bff"))
			if e.pos.distance_to(p.pos) <= 60.0 + PLAYER_RADIUS:
				_damage_player(e.atk, 1.5)
		"pull":
			# Lốc Xoáy — Hút xong thì nổ.
			_blast(e.pos, PULL_BLAST, Color("#e2e6ee"))
			if e.pos.distance_to(p.pos) <= PULL_BLAST + PLAYER_RADIUS:
				_damage_player(e.atk, 1.5)
		"spore":
			var pr := Projectile.new()
			pr.pos = e.pos
			pr.vel = wind_bend((e.target - e.pos).normalized()) * 280.0
			pr.ttl = 1.6
			pr.atk = e.atk
			pr.element = str(def.element)
			projectiles.append(pr)
		"pounce":
			e.pos = e.target
			if e.target.distance_to(p.pos) <= POUNCE_RADIUS + PLAYER_RADIUS:
				_damage_player(e.atk, 2.0)
		"stomp":
			_blast(e.pos, STOMP_R, Color("#c9a45c"))
			if e.pos.distance_to(p.pos) <= STOMP_R + PLAYER_RADIUS:
				_damage_player(e.atk, 1.4)
		"dash":
			# C1-24: Lao sương
			var from := e.pos
			var to: Vector2 = (e.pos + (e.target - e.pos).limit_length(float(Monsters.DEFS[e.kind].get("dash", 150.0)))).clamp(
				Vector2(20, 20), world_size - Vector2(20, 20))
			e.pos = to
			if Geometry2D.get_closest_point_to_segment(p.pos, from, to).distance_to(p.pos) <= e.radius + PLAYER_RADIUS:
				_incoming_el = str(def.element)
				_damage_player(e.atk, 1.0)
		"roots":
			for k in 3:
				var c: Vector2 = e.target + Vector2.from_angle(k * TAU / 3.0) * ROOT_R * 0.9
				_blast(c, ROOT_R, Color("#7a5a32"))
			for k in 3:
				var c2: Vector2 = e.target + Vector2.from_angle(k * TAU / 3.0) * ROOT_R * 0.9
				if c2.distance_to(p.pos) <= ROOT_R + PLAYER_RADIUS:
					if _damage_player(e.atk, 1.2):
						p.root_timer = ROOT_TIME
						_text(p.pos + Vector2(0, -40), "Bị rễ trói!", Color("#c9a45c"), true)
					break
		"leaf":
			var dir: Vector2 = (e.target - e.pos).normalized()
			var to_p := p.pos - e.pos
			_blast(e.pos + dir * LEAF_RANGE * 0.6, LEAF_RANGE * 0.5, Color("#6fdc7a"))
			if to_p.length() <= LEAF_RANGE + e.radius + PLAYER_RADIUS and absf(angle_difference(dir.angle(), to_p.angle())) <= LEAF_ARC:
				if _damage_player(e.atk, 1.0):
					p.poison_timer = POISON_TIME
		"tiger":
			# Bạch Hổ — Hổ Vồ: vồ tới chỗ đánh dấu, vòng 6 m ×1,4.
			e.pos = e.target
			e.chain_left -= 1
			_blast(e.pos, TIGER_R, Color("#e8e6dc"))
			if e.pos.distance_to(p.pos) <= TIGER_R + PLAYER_RADIUS:
				_incoming_el = "kim"
				_damage_player(e.atk, TIGER_MUL)
		"roar":
			# Bạch Hổ — Gầm Gió: vòng 10 m, đẩy lùi 8 m, choáng 1 giây (né lăn tránh được).
			_blast(e.pos, ROAR_R, Color("#dce6f2"))
			_sfx("boss_roar")
			if e.pos.distance_to(p.pos) <= ROAR_R + PLAYER_RADIUS and p.dodge_time <= 0.0 and p.dash_time <= 0.0 and p.dead_timer <= 0.0:
				var away := (p.pos - e.pos).normalized() if p.pos.distance_to(e.pos) > 1.0 else Vector2.RIGHT
				p.pos = (p.pos + away * ROAR_PUSH).clamp(Vector2.ONE * PLAYER_RADIUS, world_size - Vector2.ONE * PLAYER_RADIUS)
				_enforce_gate()
				_enforce_arena_lock()
				p.stun_timer = ROAR_STUN
				_last_combat = time
				_text(p.pos + Vector2(0, -40), "Choáng!", Color("#dce6f2"), true)
		"curse", "sandvortex", "emerge", "roll", "claw", "tail", "sdive", "gaze":
			Ch3.perform(self, e)
		"none":
			pass
		"explode":
			_blast(e.pos, EXPLODE_R, Color("#ff9a3c"))
			_sfx("explode")
			if e.pos.distance_to(p.pos) <= EXPLODE_R + PLAYER_RADIUS:
				_damage_player(e.atk, 1.5)
			# Tự nổ: chết, không cho EXP/đồ.
			e.dead = true


## CB-12: Hú gọi (Sói Đầu Đàn), Sinh sôi (Nấm Mẹ).
func _elite_skill(e: Enemy, kind: String) -> void:
	if _elite_skill_m42(e, kind):
		return
	if Ch3.elite_skill(self, e, kind):
		return
	var summons := 0
	for m in enemies:
		if not m.dead and m.role == "summon":
			summons += 1
	if summons >= MAX_SUMMONS:
		e.skill_cd = 3.0
		return
	match kind:
		"howl":
			e.skill_cd = HOWL_CD
			e.haste_timer = HASTE_TIME
			for i in 2:
				var w := spawn_enemy("wolf", e.level, e.pos + Vector2.from_angle(_r() * TAU) * 50.0, {"role": "summon"})
				w.state = "chase"
				w.haste_timer = HASTE_TIME
			_text(e.pos + Vector2(0, -e.radius - 24), "Hú gọi!", Color("#ff5470"), true)
		"spawn":
			e.skill_cd = SPAWN_CD
			for i in 2:
				var c := spawn_enemy("nam-con", e.level, e.pos + Vector2.from_angle(_r() * TAU) * 40.0, {"role": "summon"})
				c.state = "chase"
			_text(e.pos + Vector2(0, -e.radius - 24), "Sinh sôi!", Color("#dc86c6"), true)


func _move_toward(e: Enemy, target: Vector2, speed: float, dt: float) -> void:
	var d := e.pos.distance_to(target)
	if d < 1.0 or e.root_timer > 0.0:
		return
	if e.haste_timer > 0.0:
		speed *= 1.2
	e.pos = e.pos.move_toward(target, speed * dt)
	if e.role == "boss":
		e.pos = _clamp_to_arena(e.pos, e.radius)


func _clamp_to_arena(pos: Vector2, radius: float) -> Vector2:
	var limit := arena_r - radius
	var off := pos - arena_pos
	return pos if off.length() <= limit else arena_pos + off.normalized() * limit


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
	var sm := Ch3.shot_mult(self)
	for pr in projectiles:
		pr.pos += pr.vel * dt * sm
		pr.ttl -= dt * sm
		if pr.ttl > 0.0 and pr.pos.distance_to(player.pos) <= pr.radius + PLAYER_RADIUS:
			_incoming_el = pr.element
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
				_sfx("pickup_gold")
			elif pk.kind == "stone":
				profile.stones += int(pk.value)
				_text(p.pos + Vector2(0, -30), "+1 Đá Cường Hoá", Color("#9ec8ff"), false)
			elif pk.kind == "item":
				var res := Items.add_item(profile, pk.item)
				_text(p.pos + Vector2(0, -44), Items.display_name(pk.item), Items.rarity_color(pk.item), true)
				_sfx("pickup_item")
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
	if field < field_mob_cap() and field_spawn:
		_spawn_field_mob()


## Mép phải vùng sinh quái: trước tường sương mù/hang, hoặc sát mép map.
func _field_right() -> float:
	if gate_x < INF:
		return gate_x
	if map.arena != null:
		return arena_pos.x - arena_r - 60.0
	return world_size.x - 80.0


func _pick_kind(level: int) -> String:
	var table = map.get("mobs", "legacy") if not map.is_empty() else "legacy"
	if table is Array:
		var opts: Array = table.filter(func(row): return level >= int(row[1]))
		if opts.is_empty():
			opts = table
		return str(RngUtil.pick_weighted(opts, func(row): return float(row[2]), _rng)[0])
	var r := _r()
	if level <= 2:
		return "mushroom" if level == 2 and r < 0.3 else "wolf"
	if level <= 4:
		return "wolf" if r < 0.5 else "mushroom"
	if level >= 6:
		# MC-01: Mộc Tinh từ cấp 6.
		if r < 0.4:
			return "wisp"
		if r < 0.65:
			return "moc-tinh"
		return "mushroom" if r < 0.85 else "wolf"
	if r < 0.6:
		return "wisp"
	return "mushroom" if r < 0.8 else "wolf"


## CB-13: loại có tinh anh ở cấp này (Sói Đầu Đàn từ cấp 3, Nấm Mẹ từ cấp 5); "" nếu không có.
func _elite_kind(level: int) -> String:
	var opts: Array = []
	var kinds: Array = ["wolf", "mushroom"]
	var table = map.get("mobs", "legacy") if not map.is_empty() else "legacy"
	if table is Array:
		kinds = table.map(func(row): return str(row[0]))
	for k in kinds:
		if Monsters.elite_capable(k, level):
			opts.append(k)
	if opts.is_empty():
		return ""
	return opts[int(_r() * opts.size()) % opts.size()]


func _random_field_pos() -> Vector2:
	for _attempt in 20:
		var pos := Vector2(480.0 + _r() * (_field_right() - 520.0), 80.0 + _r() * (world_size.y - 160.0))
		if pos.distance_to(safe_pos) > safe_r + 120.0:
			return pos
	return safe_pos + Vector2(safe_r + 400.0, 0)


func _spawn_field_mob() -> void:
	for _attempt in 12:
		var pos := Vector2(480.0 + _r() * (_field_right() - 520.0), 80.0 + _r() * (world_size.y - 160.0))
		if pos.distance_to(player.pos) < 450.0:
			continue
		if pos.distance_to(safe_pos) < safe_r + 150.0:
			continue
		var level := level_at(pos.x)
		var kind := _pick_kind(level)
		var elite := false
		if _r() < 0.06:
			var ek := _elite_kind(level)
			if ek != "":
				kind = ek
				elite = true
		Ch3.after_spawn(self, spawn_enemy(kind, level, pos, {"elite": elite}))
		return


## opts: {elite: bool, role: String, nest_tile_id: int}
func spawn_enemy(kind: String, level: int, pos: Vector2, opts: Dictionary = {}) -> Enemy:
	var def: Dictionary = Monsters.DEFS[kind]
	var elite: bool = opts.get("elite", false)
	var is_boss: bool = opts.get("role", "") == "boss" or kind == "boss"
	var e := Enemy.new()
	e.id = _next_id
	_next_id += 1
	e.kind = kind
	e.role = opts.get("role", "field")
	e.name = str(def.get("elite_name", "%s Tinh Anh" % def.name)) if elite else def.name
	e.level = level
	e.elite = elite
	e.pos = pos
	e.home = pos
	e.wander = pos
	# CB-21, CB-22: chỉ số theo công thức tài liệu 06 mục 1.
	var tier := "boss" if is_boss else ("tinhanh" if elite else "thuong")
	if opts.get("role", "") == "rare":
		tier = "hiem"
	var arch: String = def.get("elite_arch", def.arch) if elite else def.arch
	var chapter: int = int(map.arena.chapter) if is_boss and map.arena != null else 1
	var ms := Formulas.mob_stats(level, tier, arch, level - 1 if is_boss else 0, Formulas.boss_hits(chapter) if is_boss else 0)
	e.max_hp = ms.hp
	e.hp = e.max_hp
	e.atk = ms.atk
	e.def = ms.def
	e.speed = def.speed
	e.radius = def.radius * (1.3 if elite else 1.0)
	e.attack_range = def.range
	e.windup_total = def.windup
	e.attack_kind = def.attack
	e.nest_tile_id = opts.get("nest_tile_id", -1)
	# Phá Thế: boss = HP/6 (06 mục 1.2), tinh anh = 30% HP (CB-07).
	e.poise = e.max_hp / 6.0 if (is_boss or opts.get("role", "") == "rare") else (e.max_hp * ELITE_POISE if elite else 0.0)
	e.max_poise = e.poise
	if kind == "nam-con":
		e.fuse = NAM_CON_FUSE
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


func claim_tile(id: int, bonus := false) -> Dictionary:
	if nest_active(id):
		var busy := {"ok": false, "message": "Quái tinh anh của ổ này vẫn đang chờ bạn ngoài Rừng Sương.", "start_nest": false}
		_message(busy.message, "info")
		return busy
	var tile := Explore.find_tile(profile, id)
	var is_relic: bool = not tile.is_empty() and tile.event == "relic"
	var is_merchant: bool = not tile.is_empty() and tile.event == "merchant"
	var res := Explore.claim_tile(profile, id, bonus)
	if res.ok and is_merchant:
		_open_merchant()
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


# ------------------------------------------------------------------ M5-04 (KP-04): câu đố Di tích

## Trạng thái câu đố đang giải dở (chỉ trong phiên chơi; câu đố sinh lại giống hệt từ tên nhân vật + ô).
var relic_puzzles := {}
## Giờ Unix hết khoá sau khi trả lời sai.
var relic_lock := {}


func _relic_key(id: int) -> String:
	return "%d_%d" % [int(profile.tiles_region), id]


func relic_puzzle(id: int) -> Dictionary:
	var key := _relic_key(id)
	if not relic_puzzles.has(key):
		relic_puzzles[key] = Puzzle.make(str(profile.name), int(profile.tiles_region), id)
	return relic_puzzles[key]


func relic_locked(id: int) -> float:
	return maxf(0.0, float(relic_lock.get(_relic_key(id), 0.0)) - now_unix())


## Trận Đèn Cổ: bấm bùa i; thắp đủ 9 bùa thì mở rương (thưởng câu đố).
func relic_press(id: int, i: int) -> Dictionary:
	var pz := relic_puzzle(id)
	if pz.kind != "lights" or Puzzle.solved(pz):
		return {"ok": false, "solved": false}
	Puzzle.press(pz, i)
	if not Puzzle.solved(pz):
		return {"ok": false, "solved": false}
	relic_puzzles.erase(_relic_key(id))
	var res := claim_tile(id, true)
	res["solved"] = true
	return res


## Câu hỏi cổ thư: chọn đáp án; sai thì rương khoá 30 giây.
func relic_answer(id: int, choice: int) -> Dictionary:
	var pz := relic_puzzle(id)
	if pz.kind != "riddle":
		return {"ok": false, "solved": false}
	if relic_locked(id) > 0.0:
		_message("Rương còn khoá %d giây." % ceili(relic_locked(id)), "bad")
		return {"ok": false, "solved": false}
	if choice != int(pz.answer):
		relic_lock[_relic_key(id)] = now_unix() + Puzzle.WRONG_LOCK
		_message("Sai rồi — cơ quan rương khoá lại %d giây." % roundi(Puzzle.WRONG_LOCK), "bad")
		return {"ok": false, "solved": false}
	relic_puzzles.erase(_relic_key(id))
	var res := claim_tile(id, true)
	res["solved"] = true
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
		var found := Items.find_item(profile, item_id)
		var plus: int = int(found.item.plus) if not found.is_empty() else 0
		_events.append({"type": "enhance", "success": res.get("success", false), "plus": plus, "item_id": item_id})
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
		Vector2(120, 120), Vector2(_field_right() - 40.0, world_size.y - 120.0)
	)
	if pos.distance_to(safe_pos) < safe_r + 80.0:
		pos = safe_pos + Vector2(safe_r + 300.0, 0)
	# CB-13: thủ lĩnh là Sói Đầu Đàn hoặc Nấm Mẹ.
	var kind := "mushroom" if level >= 5 and _r() < 0.5 else "wolf"
	var guard := spawn_enemy(kind, level, pos, {"elite": true, "role": "nestGuard", "nest_tile_id": tile_id})
	guard.name = "Thủ lĩnh %s" % Monsters.DEFS[kind].elite_name
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
		a.atk = float(Formulas.mob_stats(level, "thuong", def.arch).atk) * tv(1.0, 1.5)
		a.color = Color(def.color)
	else:
		a.atk = float(stats.atk) * tv(SHADOW_ATK, 0.45)
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
	return m * ((1.0 + tv(0.1, 0.15)) if dragon_active() else 1.0)


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
			_brew_potions()


func _brew_potions() -> void:
	while profile.herbs >= HERBS_PER_POTION and profile.potions < POTION_MAX:
		profile.herbs -= HERBS_PER_POTION
		profile.potions += 1
		_message("Chế được 1 bình máu (%d/%d)." % [profile.potions, POTION_MAX], "good")


func chest_visible(c: Chest) -> bool:
	return not c.opened and profile.talent == "khuu-giac" and c.pos.distance_to(player.pos) <= CHEST_SENSE_R * tv(1.0, 1.5)


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
			var item := Items.new_item(profile, maxi(1, level_at(c.pos.x)), "green" if _r() < 0.5 else "blue", _rng)
			text += ", " + str(Items.add_item(profile, item).message).trim_suffix(".")
		_message(text + ".", "good")


# ------------------------------------------------------------------ C1-11, C1-12: thoại và nhiệm vụ chương 1


## Phát thoại (mỗi mốc 1 lần). Trả về true nếu là lần đầu.
func say(id: String) -> bool:
	if id in profile.seen_dialogs or not Story.DIALOGS.has(id):
		return false
	profile.seen_dialogs.append(id)
	_events.append({"type": "dialog", "id": id})
	return true


func quest() -> Dictionary:
	return Story.quest(profile.quest_step)


## Tiến độ của bước hiện tại để hiển thị: [hiện có, cần].
func quest_status() -> Array:
	var q := quest()
	if q.is_empty():
		return [0, 0]
	var need := int(q.need)
	match str(q.type):
		"level":
			return [mini(profile.level, need), need]
		"reveal":
			return [mini(_revealed_count(), need), need]
	return [mini(profile.quest_progress, need), need]


func _revealed_count() -> int:
	var n := 0
	for t in profile.tiles:
		if t.event != "camp" and t.status != "fog":
			n += 1
	return n


## Bắt đầu bước hiện tại: thoại, sinh quái nhiệm vụ, quà.
func _begin_quest_step() -> void:
	var step: int = profile.quest_step
	if step > Story.QUESTS.size():
		return
	var first := say("q%d" % step)
	match step:
		1:
			# Quái Sương tấn công làng: 3 Sói Sương cấp 1 ngay cổng làng (đủ số còn thiếu).
			if map_id == "1-1":
				for i in maxi(0, 3 - profile.quest_progress):
					var wolf := spawn_enemy("wolf", 1, safe_pos + Vector2(safe_r + 70.0, -70.0 + i * 70.0), {"role": "quest"})
					wolf.state = "idle"
		4:
			if first:
				# Quà của Trưởng làng: vũ khí Xanh lá theo lớp (phát hiện F8).
				var gift := Items.new_item(profile, maxi(1, profile.level), "green", _rng, "weapon")
				_events.append({"type": "item", "text": Items.add_item(profile, gift).message, "rarity": "green"})
	_check_quest_state()


## Sự kiện đếm (hạ quái nhiệm vụ, dùng kỹ năng, né).
func quest_event(kind: String, n := 1) -> void:
	var q := quest()
	if q.is_empty() or str(q.type) != kind:
		return
	profile.quest_progress += n
	_check_quest_state()


func _check_quest_state() -> void:
	var q := quest()
	if q.is_empty():
		return
	var need := int(q.need)
	var done := false
	match str(q.type):
		"kill_quest", "skill", "dodge":
			done = profile.quest_progress >= need
		"equip_weapon":
			done = profile.equipment.has("weapon")
		"level":
			done = profile.level >= need
		"spend_points":
			done = profile.unspent == 0
		"reveal":
			done = _revealed_count() >= need
		"build":
			for key in profile.buildings:
				if Explore.is_built(profile, key):
					done = true
					break
		"boss_unlocked":
			done = boss_unlocked()
		"boss":
			done = profile.boss_defeated
		"enter_map":
			done = map_id == "1-3"
	if done:
		_complete_quest(q)


func _complete_quest(q: Dictionary) -> void:
	var r: Dictionary = q.reward
	profile.gold += float(r.get("gold", 0))
	profile.potions = mini(POTION_MAX, int(profile.potions) + int(r.get("potions", 0)))
	profile.torches = mini(Explore.torch_max(profile), int(profile.torches) + int(r.get("torches", 0)))
	profile.stones += int(r.get("stones", 0))
	var rt := Story.reward_text(r)
	_message("Hoàn thành nhiệm vụ: %s%s" % [q.title, (". Thưởng: " + rt) if rt != "" else ""], "good")
	_events.append({"type": "quest_done", "step": profile.quest_step})
	profile.quest_step += 1
	profile.quest_progress = 0
	if r.has("exp"):
		add_exp(float(r.exp), false)
	if profile.quest_step >= Story.DONE_STEP:
		say("done")
		return
	_begin_quest_step()


# ------------------------------------------------------------------ C1-22…24: Lõi Sương, boss hiếm, hiệu ứng


func now_unix() -> float:
	return debug_now if debug_now >= 0.0 else Time.get_unix_time_from_system()


## Boss chương hoặc boss hiếm đang có mặt (thanh máu lớn trên HUD).
func big_enemy() -> Enemy:
	var b := boss()
	if b != null:
		return b
	for e in enemies:
		if e.role == "rare" and not e.dead:
			return e
	return null


func rare_boss() -> Enemy:
	for e in enemies:
		if e.role == "rare" and not e.dead:
			return e
	return null


func _rare_def(kind: String) -> Dictionary:
	for m in RARE_BOSSES:
		if RARE_BOSSES[m].kind == kind:
			return RARE_BOSSES[m]
	return {}


func _boss_down(kind: String) -> bool:
	return bool(profile.bosses.get(kind, false)) or (kind == "boss" and profile.boss_defeated)


## Lần đầu vào map boss hiếm (sau khi boss vùng đã ngã), sau đó mỗi 12 giờ thực (2 lần/ngày).
func rare_boss_ready() -> bool:
	if not RARE_BOSSES.has(map_id):
		return false
	var rd: Dictionary = RARE_BOSSES[map_id]
	return _boss_down(str(rd.after)) and now_unix() >= float(profile.rare_at.get(rd.kind, 0.0))


func _check_rare_boss() -> void:
	if not rare_boss_ready() or rare_boss() != null:
		return
	var rd: Dictionary = RARE_BOSSES[map_id]
	var pos := (player.pos + Vector2(520, 0)).clamp(Vector2(400, 200), world_size - Vector2(200, 200))
	if map.arena != null and pos.distance_to(arena_pos) < arena_r + 150.0:
		pos = (player.pos - Vector2(520, 0)).clamp(Vector2(200, 200), world_size - Vector2(200, 200))
	var b := spawn_enemy(str(rd.kind), int(rd.level), pos, {"role": "rare"})
	b.skill_cd = 2.0
	_message(str(rd.intro), "bad")
	say(str(rd.say))
	_sfx("boss_roar")


func _update_rare(e: Enemy, dt: float) -> void:
	if e.kind == "nhan-su":
		Ch3.update_sphinx(self, e, dt)
		return
	if e.kind == "bach-ho":
		# Dưới 50% HP: Cưỡi Gió — tốc ×1,5.
		if e.phase == 1 and e.hp <= e.max_hp * 0.5:
			e.phase = 2
			e.speed *= RIDE_SPEED
			_message("Bạch Hổ Cưỡi Gió — nhanh hơn hẳn! Canh vòng báo trước mà né lăn.", "bad")
		return
	# Dưới 40% HP: Rừng Thức Tỉnh — gọi 2 Mộc Tinh + 3 Gốc Rễ.
	if e.phase == 1 and e.hp <= e.max_hp * 0.4:
		e.phase = 2
		for i in 2:
			var m := spawn_enemy("moc-tinh", e.level, e.pos + Vector2.from_angle(i * PI + 0.5) * 90.0, {"role": "rareMinion"})
			m.state = "chase"
		for i in 3:
			var r := spawn_enemy("goc-re", e.level, e.pos + Vector2.from_angle(i * TAU / 3.0) * 150.0, {"role": "rareMinion"})
			r.max_hp = roundf(e.max_hp * 0.04)
			r.hp = r.max_hp
		_message("Rừng Thức Tỉnh! Lão Thụ hồi máu khi còn Gốc Rễ — phá 3 Gốc Rễ!", "bad")
	if e.phase == 2 and e.hp < e.max_hp:
		for m in enemies:
			if m.kind == "goc-re" and not m.dead:
				e.hp = minf(e.max_hp, e.hp + e.max_hp * RARE_HEAL * dt)
				break


func _on_rare_killed(e: Enemy) -> void:
	var rd := _rare_def(e.kind)
	profile.rare_at[e.kind] = now_unix() + Config.RARE_BOSS_PERIOD
	profile.essence += 5
	profile.evo_essence += 1
	for m in enemies:
		if m.role == "rareMinion":
			m.dead = true
	_message("%s đã ngã! +5 Thiên Phú Tinh Hoa, +1 Tinh Hoa Tiến Hoá. Nó sẽ trở lại sau 12 giờ." % e.name, "good")
	say(str(rd.get("down", "rare_boss_down")))
	_events.append({"type": "rare_boss", "kind": e.kind})


func _update_player_effects(dt: float, input: Dictionary) -> void:
	var p := player
	p.root_timer -= dt
	p.stun_timer -= dt
	var max_hp := float(stats.max_hp)
	var hurt := 0.0
	if p.poison_timer > 0.0:
		p.poison_timer -= dt
		hurt += POISON_PCT * max_hp * dt
	for hz in hazards:
		hz.ttl -= dt
		if hz.pos.distance_to(p.pos) <= hz.radius + PLAYER_RADIUS:
			hurt += POISON_PCT * max_hp * dt
	hazards = hazards.filter(func(h): return h.ttl > 0.0)
	if hurt > 0.0 and p.dodge_time <= 0.0:
		p.hp -= hurt
		_last_combat = time
		if p.hp <= 0.0:
			_die()
			return
	# Vỏ Lão Thụ: đứng yên 1 giây thì hồi 2% HP mỗi giây.
	var mv: Vector2 = input.get("move", Vector2.ZERO)
	if mv.length() < 0.01 and not input.get("attack", false):
		p.still += dt
	else:
		p.still = 0.0
	if has_unique("lao_thu_bark") and p.still >= BARK_STILL:
		p.hp = minf(max_hp, p.hp + BARK_REGEN * max_hp * dt)


# ------------------------------------------------------------------ C1-30…34: cửa hàng, thương nhân, Xưởng Rèn, tự đánh, tự cộng điểm

const SHOP_POTION := 30
const SHOP_STONE := 25
const SELL_MULT := {"white": 1, "green": 2, "blue": 4, "purple": 8, "orange": 20}
const MERCHANT_TIME := 3600.0
const FORGE_STONES := 3
const FORGE_RATES := {"green": 60.0, "blue": 35.0, "purple": 5.0}
const AUTO_RANGE := 400.0


func in_village() -> bool:
	return (map_id == "1-1" or map_id == "2-1") and player.pos.distance_to(safe_pos) < safe_r + 20.0


func _shop_result(ok: bool, msg: String) -> Dictionary:
	_message(msg, "good" if ok else "bad")
	return {"ok": ok, "message": msg}


func shop_buy(kind: String) -> Dictionary:
	match kind:
		"potion":
			if profile.potions >= POTION_MAX:
				return _shop_result(false, "Đã mang tối đa %d bình máu." % POTION_MAX)
			if profile.gold < SHOP_POTION:
				return _shop_result(false, "Cần %d vàng." % SHOP_POTION)
			profile.gold -= SHOP_POTION
			profile.potions += 1
			return _shop_result(true, "Mua 1 bình máu (%d/%d)." % [profile.potions, POTION_MAX])
		"stone":
			if profile.gold < SHOP_STONE:
				return _shop_result(false, "Cần %d vàng." % SHOP_STONE)
			profile.gold -= SHOP_STONE
			profile.stones += 1
			return _shop_result(true, "Mua 1 Đá Cường Hoá.")
	return _shop_result(false, "Không có món này.")


static func sell_price(item: Dictionary) -> int:
	return 5 * maxi(1, int(item.level)) * int(SELL_MULT.get(item.rarity, 1)) * (1 + int(item.plus) / 3)


func sell_item(item_id: int) -> Dictionary:
	var i := Items.find_in_bag(profile, item_id)
	if i < 0:
		return _shop_result(false, "Chỉ bán được đồ trong túi (tháo ra trước).")
	var item: Dictionary = profile.inventory[i]
	var price := sell_price(item)
	profile.inventory.remove_at(i)
	profile.gold += price
	return _shop_result(true, "Bán %s: +%d vàng." % [Items.display_name(item), price])


## C1-32: Thương nhân lữ hành — 3 món Xanh dương/Tím trong 1 giờ thực.
func _open_merchant() -> void:
	var items: Array = []
	for r in ["blue", "blue", "purple"]:
		var it := Items.new_item(profile, maxi(1, profile.level), r, _rng)
		it["price"] = sell_price(it) * 4
		items.append(it)
	profile.merchant = {"until": now_unix() + MERCHANT_TIME, "items": items}
	say("merchant")


func merchant_active() -> bool:
	return profile.merchant.has("until") and now_unix() < float(profile.merchant.until) and not profile.merchant.items.is_empty()


func merchant_left() -> float:
	return maxf(0.0, float(profile.merchant.get("until", 0.0)) - now_unix())


func buy_merchant(index: int) -> Dictionary:
	if not merchant_active():
		return _shop_result(false, "Thương nhân lữ hành đã rời đi.")
	var items: Array = profile.merchant.items
	if index < 0 or index >= items.size():
		return _shop_result(false, "Không có món này.")
	var it: Dictionary = items[index]
	if profile.gold < int(it.price):
		return _shop_result(false, "Cần %d vàng." % int(it.price))
	if profile.inventory.size() >= ItemData.BAG_SIZE:
		return _shop_result(false, "Túi đồ đã đầy.")
	profile.gold -= int(it.price)
	items.remove_at(index)
	var item := it.duplicate()
	item.erase("price")
	Items.add_item(profile, item)
	return _shop_result(true, "Mua %s." % Items.display_name(item))


## C1-30: Xưởng Rèn — chế 1 món cho ô chọn, cấp = cấp nhân vật.
func forge_cost() -> int:
	return 60 + 15 * profile.level


func forge_craft(slot: String) -> Dictionary:
	if not Explore.is_built(profile, "forge"):
		return _shop_result(false, "Cần xây Xưởng Rèn trước (Bản đồ khai phá, phím M).")
	if profile.gold < forge_cost() or profile.stones < FORGE_STONES:
		return _shop_result(false, "Cần %d vàng và %d Đá Cường Hoá." % [forge_cost(), FORGE_STONES])
	if profile.inventory.size() >= ItemData.BAG_SIZE:
		return _shop_result(false, "Túi đồ đã đầy.")
	profile.gold -= forge_cost()
	profile.stones -= FORGE_STONES
	var rarity: String = RngUtil.pick_weighted(FORGE_RATES.keys(), func(k): return FORGE_RATES[k], _rng)
	var item := Items.new_item(profile, maxi(1, profile.level), rarity, _rng, slot)
	Items.add_item(profile, item)
	_events.append({"type": "item", "text": "Xưởng Rèn: chế được %s." % Items.display_name(item), "rarity": rarity})
	return {"ok": true, "message": Items.display_name(item), "item": item}


## C1-34: tự cộng điểm theo lớp (Kiếm Khách 3 STR : 2 VIT; Thợ Săn 3 AGI : 1 VIT : 1 LUK; Pháp Sư 3 INT : 2 VIT).
func auto_allocate() -> int:
	var pattern: Array = ["agi", "agi", "agi", "vit", "luk"] if is_hunter() else (
		["int", "int", "int", "vit", "vit"] if is_mage() else ["str", "str", "str", "vit", "vit"])
	var n := 0
	while profile.unspent > 0:
		allocate(pattern[n % pattern.size()])
		n += 1
	if n > 0:
		_message("Tự cộng %d điểm tiềm năng." % n, "good")
	return n


func toggle_auto() -> void:
	if not auto_fight and auto_blocked() != "":
		_message(auto_blocked(), "bad")
		return
	auto_fight = not auto_fight
	_message("Tự đánh: BẬT (Z để tắt; di chuyển để tạm nhường)." if auto_fight else "Tự đánh: TẮT.", "info")


## Kịch bản mục 5: boss luôn phải đánh tay.
func auto_blocked() -> String:
	if boss() != null or rare_boss() != null:
		return "Boss phải đánh tay — Tự đánh tắt."
	if map.arena != null and player.pos.distance_to(arena_pos) < arena_r:
		return "Trong hang boss không dùng được Tự đánh."
	return ""


func _auto_input(input: Dictionary) -> Dictionary:
	if not auto_fight:
		return input
	if auto_blocked() != "":
		auto_fight = false
		_message(auto_blocked(), "bad")
		return input
	var mv: Vector2 = input.get("move", Vector2.ZERO)
	if mv.length() > 0.01 or player.dead_timer > 0.0:
		return input
	var target: Enemy = null
	var best := INF
	for e in enemies:
		if e.dead or is_hidden(e):
			continue
		var d: float = e.pos.distance_to(player.pos)
		if d < AUTO_RANGE and d < best:
			best = d
			target = e
	var out := input.duplicate()
	if target == null:
		return out
	var gap: float = best - target.radius
	var dir: Vector2 = (target.pos - player.pos).normalized()
	if is_ranged():
		out.move = -dir if gap < 150.0 else (dir if gap > 320.0 else Vector2.ZERO)
	else:
		out.move = Vector2.ZERO if gap < 50.0 else dir
	out.aim = target.pos
	out.attack = true
	for i in 4:
		var key := "skill_%d" % (i + 1)
		var sk: Dictionary = Classes.skill(profile.class_id, i)
		var useful: bool = sk.mul > 0.0 and gap < (380.0 if is_ranged() else 160.0)
		if useful and player.skill_cds[i] <= 0.0 and player.mp >= float(sk.mp) + 10.0:
			out[key] = true
			break
	return out


func _sfx(id: String) -> void:
	if sfx.size() < 32:
		sfx.append(id)


# ------------------------------------------------------------------ M4.2: gió, quái vùng 2, Huyền Ảnh, ảo ảnh

const COPY_NAMES := {"pounce": "Vồ Mồi", "clone": "Phân Thân", "burrow": "Độn Thổ"}
const WIND_DIRS := [Vector2(1, 0), Vector2(1, 1), Vector2(0, 1), Vector2(-1, 1), Vector2(-1, 0), Vector2(-1, -1), Vector2(0, -1), Vector2(1, -1)]


func active_copy() -> String:
	if profile.active_copy in profile.copied_skills:
		return profile.active_copy
	return str(profile.copied_skills[-1]) if not profile.copied_skills.is_empty() else ""


func set_active_copy(id: String) -> void:
	if id in profile.copied_skills:
		profile.active_copy = id


func wind_period() -> float:
	return float(map.get("wind", 0.0)) if not map.is_empty() else 0.0


func _init_wind() -> void:
	wind_strong = 0.0
	wind_next = Vector2.ZERO
	if wind_period() <= 0.0:
		wind_dir = Vector2.ZERO
		return
	wind_dir = WIND_DIRS[int(_r() * 8) % 8].normalized()
	wind_timer = wind_period()


func _pick_wind() -> Vector2:
	for _i in 10:
		var d: Vector2 = WIND_DIRS[int(_r() * 8) % 8].normalized()
		if d.dot(wind_dir) < 0.9:
			return d
	return -wind_dir


## GI-01: đổi hướng theo chu kỳ, báo trước 2 giây (HUD đọc wind_next).
func _update_wind(dt: float) -> void:
	wind_strong -= dt
	if wind_dir == Vector2.ZERO:
		return
	wind_timer -= dt
	if wind_timer <= WIND_WARN and wind_next == Vector2.ZERO:
		wind_next = _pick_wind()
	if wind_timer <= 0.0:
		wind_dir = wind_next if wind_next != Vector2.ZERO else _pick_wind()
		wind_next = Vector2.ZERO
		wind_timer = wind_period()


func wind_power() -> float:
	return 2.0 if wind_strong > 0.0 else 1.0


## GI-02: ngược gió −30%, xuôi gió +20% (theo độ lệch giữa hướng chạy và hướng gió).
func wind_factor(move: Vector2) -> float:
	if wind_dir == Vector2.ZERO or move.length() < 0.01:
		return 1.0
	var dot: float = move.normalized().dot(wind_dir)
	return 1.0 + (0.2 * dot if dot > 0.0 else 0.3 * dot)


## GI-03: đạn lệch tối đa 15° về hướng gió.
## strength < 1: đòn tự nhắm (Thợ Săn, N9) đã ngắm bù gió một phần.
func wind_bend(dir: Vector2, strength := 1.0) -> Vector2:
	if wind_dir == Vector2.ZERO:
		return dir
	var diff := angle_difference(dir.angle(), wind_dir.angle())
	return dir.rotated(clampf(diff, -WIND_BEND * strength, WIND_BEND * strength))


func _enemy_shot(e: Enemy, angle: float, mul: float, speed: float) -> void:
	var pr := Projectile.new()
	pr.pos = e.pos
	pr.vel = wind_bend(Vector2.from_angle(angle)) * speed
	pr.ttl = 1.6
	pr.atk = e.atk * mul
	pr.element = str(Monsters.DEFS[e.kind].element)
	projectiles.append(pr)


func _add_decoy(pos: Vector2, ttl: float) -> void:
	decoys.append({"pos": pos, "ttl": ttl})


func _nearest_decoy(pos: Vector2) -> Dictionary:
	var best := {}
	var bd := DECOY_RANGE
	for dc in decoys:
		var d: float = pos.distance_to(dc.pos)
		if d < bd:
			bd = d
			best = dc
	return best


## Tinh anh vùng 2: Chém xoáy (Đội Trưởng), Nghịch Phong (Phù Thuỷ Gió).
func _update_whirls(dt: float) -> void:
	for w in whirls:
		w.wait -= dt
		if w.wait > 0.0:
			continue
		var e: Enemy = w.e
		if e.dead:
			w.left = 0
			continue
		_blast(e.pos, WHIRL_R + e.radius, Color("#ff9a3c"))
		if e.pos.distance_to(player.pos) <= WHIRL_R + e.radius + PLAYER_RADIUS:
			_incoming_el = "kim"
			_damage_player(e.atk, 1.6)
		w.left -= 1
		w.wait = 0.5
	whirls = whirls.filter(func(w): return w.left > 0)


func _elite_skill_m42(e: Enemy, kind: String) -> bool:
	match kind:
		"whirl":
			e.skill_cd = 10.0
			whirls.append({"e": e, "left": 3, "wait": 0.0})
			_text(e.pos + Vector2(0, -e.radius - 24), "Chém xoáy!", Color("#ff9a3c"), true)
			return true
		"gale":
			e.skill_cd = 14.0
			if wind_dir != Vector2.ZERO:
				wind_dir = _pick_wind()
				wind_next = Vector2.ZERO
				wind_timer = wind_period()
				wind_strong = GALE_TIME
			_text(e.pos + Vector2(0, -e.radius - 24), "Nghịch Phong!", Color("#e8e2c8"), true)
			return true
	return false


## Huyền Ảnh: 60% → 2 bản sao; 25% → 4 bản sao; giai đoạn 3 đổi chỗ mỗi 6 giây.
func _huyen_phase(e: Enemy) -> void:
	if e.phase == 1 and e.hp <= e.max_hp * 0.6:
		e.phase = 2
		_spawn_clones(e, 2)
		_message("Huyền Ảnh phân thân! Chỉ bản thật có bóng.", "bad")
	elif e.phase == 2 and e.hp <= e.max_hp * 0.25:
		e.phase = 3
		_spawn_clones(e, 4)
		_swap_timer = SWAP_PERIOD
		_message("Vạn Ảnh! Bản thật và bản sao đổi chỗ cho nhau.", "bad")


func _spawn_clones(e: Enemy, want: int) -> void:
	var have := 0
	for m in enemies:
		if m.role == "bossClone" and not m.dead:
			have += 1
	for i in maxi(0, want - have):
		var c := spawn_enemy("huyen-anh-ao", e.level, _clamp_to_arena(e.pos + Vector2.from_angle(_r() * TAU) * 120.0, e.radius), {"role": "bossClone"})
		c.name = e.name
		c.max_hp = roundf(e.max_hp * CLONE_HP)
		c.hp = c.max_hp
		c.atk = e.atk * CLONE_ATK
		c.poise = 0.0
		c.max_poise = 0.0
		c.state = "chase"


func clones() -> Array:
	return enemies.filter(func(m): return m.role == "bossClone" and not m.dead)


func _update_huyen_anh(e: Enemy, dt: float) -> void:
	if e.phase < 3:
		return
	_swap_timer -= dt
	if _swap_timer > 0.0:
		return
	_swap_timer = SWAP_PERIOD
	var cs := clones()
	if cs.is_empty():
		return
	var c: Enemy = cs[int(_r() * cs.size()) % cs.size()]
	var tmp := e.pos
	e.pos = c.pos
	c.pos = tmp


# ------------------------------------------------------------------ M4.3: Thành Biên Đài, NPC, nhiệm vụ chương 2, thợ rèn

const NPC_RANGE := 70.0
const SMITH_STONE_ORE := 10
const SMITH_KIM_ORE := 20
const SMITH_KIM_IRON := 10
const RANKS := [[0, "Đồng"], [10, "Bạc"], [25, "Vàng"]]


## NPC của map hiện tại: [{id, sprite, pos, name}]. Mạc Tam biến mất sau khi lộ mặt (CT-07).
func npcs() -> Array:
	var out: Array = []
	for n in map.get("npcs", []):
		if n[0] == "mac-tam" and int(profile.quest.ch2) >= 5:
			continue
		out.append({"id": n[0], "sprite": n[1], "pos": safe_pos + n[2], "name": n[3]})
	return out


func nearest_npc() -> Dictionary:
	var best := {}
	var bd := NPC_RANGE
	for n in npcs():
		var d: float = n.pos.distance_to(player.pos)
		if d < bd:
			bd = d
			best = n
	return best


## Bấm E cạnh NPC. Trả về hành động cho giao diện: "shop" (mở cửa hàng) hoặc "" (chỉ thoại).
func talk(npc_id: String) -> String:
	var step: int = int(profile.quest.ch2)
	match npc_id:
		"lac-phong":
			if step == 1:
				_advance_quest2()
			else:
				_force_say(["", "lac_join", "lac_q2", "lac_q3", "lac_q4", "lac_q5"][clampi(step, 0, 5)] if step <= 5 else "ch2_done")
			return ""
		"mac-tam":
			if step == 4:
				_advance_quest2()
				return ""
			_force_say("mac_greet")
			return "shop"
		"thiet-nguu":
			_force_say("smith")
			return "shop"
		"merchant":
			return "shop"
		"sa-lao", "a-moc", "thach-thu":
			return Ch3.talk(self, npc_id)
		"elder":
			_force_say("q%d" % profile.quest_step if profile.quest_step <= Story.QUESTS.size() else "done")
			return ""
	return ""


## Thoại lặp lại được (NPC nói lại khi bấm E), không ghi vào seen_dialogs.
func _force_say(id: String) -> void:
	if Story.DIALOGS.has(id):
		_events.append({"type": "dialog", "id": id})


func quest2() -> Dictionary:
	return Story.quest2(int(profile.quest.ch2))


func quest2_status() -> Array:
	var q := quest2()
	if q.is_empty():
		return [0, 0]
	match str(q.type):
		"kills2":
			return [mini(int(profile.quest.kills2), int(q.need)), int(q.need)]
		"tiles2":
			return [mini(Explore.owned_count(profile.grid_of(2)), int(q.need)), int(q.need)]
	return [0, int(q.need)]


func _check_quest2() -> void:
	var q := quest2()
	if q.is_empty():
		return
	var done := false
	match str(q.type):
		"kills2":
			done = int(profile.quest.kills2) >= int(q.need)
		"tiles2":
			done = Explore.owned_count(profile.grid_of(2)) >= int(q.need)
		"boss2":
			done = is_boss_defeated("huyen-anh")
	if done:
		_advance_quest2()


func _advance_quest2() -> void:
	var q := quest2()
	if q.is_empty():
		return
	var r: Dictionary = q.reward
	profile.gold += float(r.get("gold", 0))
	profile.stones += int(r.get("stones", 0))
	var rt := Story.reward_text(r)
	_message("Nhiệm vụ chương 2 hoàn thành: %s%s" % [q.title, (". Thưởng: " + rt) if rt != "" else ""], "good")
	var step: int = int(profile.quest.ch2)
	if step == 2:
		var gift := Items.new_item(profile, maxi(1, profile.level), "blue", _rng)
		_events.append({"type": "item", "text": Items.add_item(profile, gift).message, "rarity": "blue"})
	profile.quest.ch2 = step + 1
	_events.append({"type": "quest_done", "step": step, "chapter": 2})
	if r.has("exp"):
		add_exp(float(r.exp), false)
	match step:
		1:
			say("lac_join")
			say("lac_q2")
		2:
			say("lac_q3")
		3:
			say("lac_q4")
		4:
			say("mac_reveal")
			_message("Mạc Tam là gián điệp Hư Vô Giáo! Hắn chạy về Phủ Huyền Ảnh ở Mắt Bão.", "bad")
		5:
			say("ch2_done")


## CT-04: hạng Khai Giới Giả theo số ô chiếm ở vùng 2 (0 / 10 / 25).
func alliance_rank() -> String:
	var n := Explore.owned_count(profile.grid_of(2))
	var name := ""
	for r in RANKS:
		if n >= int(r[0]):
			name = r[1]
	return name


## TB-11: thợ rèn Thiết Ngưu đổi Đá/Sắt.
func smith_trade(kind: String) -> Dictionary:
	match kind:
		"stone":
			if profile.ore < SMITH_STONE_ORE:
				return _shop_result(false, "Cần %d Đá." % SMITH_STONE_ORE)
			profile.ore -= SMITH_STONE_ORE
			profile.stones += 1
			return _shop_result(true, "Thiết Ngưu rèn được 1 Đá Cường Hoá.")
		"tinh_kim":
			if profile.ore < SMITH_KIM_ORE or profile.iron < SMITH_KIM_IRON:
				return _shop_result(false, "Cần %d Đá và %d Sắt." % [SMITH_KIM_ORE, SMITH_KIM_IRON])
			profile.ore -= SMITH_KIM_ORE
			profile.iron -= SMITH_KIM_IRON
			profile.tinh_kim += 1
			return _shop_result(true, "Thiết Ngưu luyện được 1 Tinh Kim.")
	return _shop_result(false, "Không có việc này.")
