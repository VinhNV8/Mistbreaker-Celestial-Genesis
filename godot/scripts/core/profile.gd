extends RefCounted
## Tiến trình được lưu lại giữa các lần chơi.

const Config = preload("res://scripts/core/config.gd")
const Explore = preload("res://scripts/core/explore.gd")

## v1: prototype Chương 1. v2: MVP M1 thêm trang bị (EQ-20). v3: MVP M2 thêm Thiên phú, công trình (mục 4.8).
## v4: MVP M3 thêm lớp nhân vật, INT/LUK, điểm Đạo Tặc cướp (mục 5.9).
## v5: MVP M4 thêm nhiều bản đồ, lưới từng vùng, boss theo id, Đá/Sắt, nhiệm vụ chương 2 (mục 6.5).
## v6: đợt C1 thêm tên, ngoại hình, nhiệm vụ/thoại chương 1, lưới vùng 1 40 ô, boss hiếm, công trình mới (08 mục 3.3).
## v7: đợt SN2 thêm sương che bản đồ, thưởng khám phá, bộ lọc phân rã/bán nhanh (09 mục 3).
## v9: M6 chương 3 — chuyển chức 1 (job), nhiệm vụ chương 3 (quest.ch3/kills3/oases), miễn nắng (docs/10 mục 6).
## v10: M7 chương 4 — tiến hoá Thiên phú (evo), nhiệm vụ chương 4, Thuốc Giải, Đuốc Lửa (docs/11 mục 6).
const VERSION := 10

var talent := ""
var level := 1
var xp := 0
var points := {"str": 0, "agi": 0, "int": 0, "vit": 0, "luk": 0}
var unspent := 0
var gold := 0.0
var wood := 0.0
var torches := Config.START_TORCHES
var torch_timer := 0.0
var tiles: Array = []
var camp_level := 1
var boss_defeated := false
var kills := 0
var play_seconds := 0.0
## Thời điểm (giây Unix) lần cuối lưu, dùng để tính thu hoạch offline.
var last_seen := 0.0

# --- v2: trang bị
var inventory: Array = []
## {ô: món đồ}
var equipment := {}
var stones := 0
var next_item_id := 1
## Sói Chúa hồi sinh khi play_seconds >= mốc này (EQ-07).
var boss_respawn_at := 0.0

# --- v3: Thiên phú và lãnh địa
var talent_level := 1
var essence := 0
var tinh_kim := 0
var potions := 2
var herbs := 0
## Thú cưng của Thuần Thú Sư: [{kind, level}]
var pets: Array = []
## Kỹ năng boss Đạo Tặc đã sao chép, ví dụ ["pounce"]
var copied_skills: Array = []
var element := "kim"
## {khoá công trình: thời điểm xong theo build_clock}; khoá: lumber_<id ô>, camp2, temple, dragon
var buildings := {}
## Đồng hồ xây (giây), chạy cả khi offline (TL-S3).
var build_clock := 0.0

# --- v4: lớp nhân vật, Đạo Tặc cướp thuộc tính
var class_id := "kiem-khach"
## Thuộc tính Đạo Tặc cướp được, cũ → mới (DT-04: đầy thì bỏ phần tử đầu).
var stolen: Array = []

# --- v5: nhiều bản đồ (M4)
var map_id := "1-1"
## Map đã mở điểm dịch chuyển (MP-04).
var unlocked_maps: Array = ["1-1"]
## Lưới khai phá của các vùng KHÔNG đang đứng: {"<vùng>": [ô]}. `tiles` luôn là lưới của vùng hiện tại.
var grids := {}
## Vùng của lưới `tiles` hiện tại.
var tiles_region := 1
## Boss đã hạ (ngoài Sói Chúa dùng boss_defeated): {id: true}; mốc hồi sinh {id: play_seconds}.
var bosses := {}
var boss_respawn := {}
var ore := 0.0
var iron := 0.0
## Nhiệm vụ chính chương 2: bước (0 = chưa nhận), số quái vùng 2 đã hạ.
var quest := {"ch2": 0, "kills2": 0, "ch3": 0, "kills3": 0, "oases": [], "ch4": 0, "kills4": 0, "orbs4": []}
## Kỹ năng sao chép đang dùng (Đạo Tặc, TP-39).
var active_copy := ""

# --- v6: đợt C1 (docs/08-chuong-1-hoan-chinh.md mục 3.3)
var name := "Khai Giới Giả"
## {gender, skin, hair_style, hair_color} — xem scripts/data/looks.gd
var look := {"gender": "nam", "skin": 1, "hair_style": "ngan", "hair_color": 0}
## Chuỗi nhiệm vụ chương 1: bước hiện tại (1–11; 12 = xong), tiến độ của bước.
var quest_step := 1
var quest_progress := 0
## Mốc thoại đã xem (không lặp lại).
var seen_dialogs: Array = []
## M5-01: boss hiếm → giờ Unix xuất hiện lần tới (thiếu = xuất hiện ngay lần đầu vào map). Save v7 trở về trước: rare_boss_at của Lão Thụ.
var rare_at := {}

# --- v9: M6 chương 3
## Chức sau chuyển chức 1 ("" = chưa chuyển) — Classes.JOBS.
var job := ""
## Uống nước ốc đảo: miễn Nắng gắt tới mốc play_seconds này (C3-11).
var heat_free_until := 0.0

# --- v10: M7 chương 4
## Số lần tiến hoá Thiên phú. talent_level là cấp hiệu dụng = Lv + 9 × evo (C4-44).
var evo := 0
var antidotes := 0
var fire_torches := 0
var evo_essence := 0
## Vườn Thảo Dược: giây tích luỹ tới thảo dược kế tiếp.
var herb_timer := 0.0
## Thương nhân lữ hành: {"until": giờ Unix, "items": [món đồ có "price"]}.
var merchant := {}
## CR-02 (GC-08): seri gift code đã dùng khi thức tỉnh ("" = không dùng).
var gift_code := ""

# --- v7: đợt SN2 (docs/09-spec-notes-dot-2.md mục 3)
## Sương che: {map_id: base64 của bitset ô 64 px đã mở} (SN-31).
var fog := {}
## Mốc thưởng khám phá đã nhận: {map_id: [50, 90]} (SN-32).
var fog_rewards := {}
## Bộ lọc phân rã/bán nhanh (SN-10); null = mặc định.
var bulk_filter := {}


func setup(talent_id: String, rng: Callable, now: float, class_name_id := "kiem-khach") -> void:
	talent = talent_id
	class_id = class_name_id
	tiles = Explore.create_tiles(rng, talent_id)
	last_seen = now


func to_dict() -> Dictionary:
	return {
		"version": VERSION,
		"talent": talent,
		"level": level,
		"xp": xp,
		"points": points,
		"unspent": unspent,
		"gold": gold,
		"wood": wood,
		"torches": torches,
		"torch_timer": torch_timer,
		"tiles": tiles,
		"camp_level": camp_level,
		"boss_defeated": boss_defeated,
		"kills": kills,
		"play_seconds": play_seconds,
		"last_seen": last_seen,
		"inventory": inventory,
		"equipment": equipment,
		"stones": stones,
		"next_item_id": next_item_id,
		"boss_respawn_at": boss_respawn_at,
		"talent_level": talent_level,
		"essence": essence,
		"tinh_kim": tinh_kim,
		"potions": potions,
		"herbs": herbs,
		"pets": pets,
		"copied_skills": copied_skills,
		"element": element,
		"buildings": buildings,
		"build_clock": build_clock,
		"class_id": class_id,
		"stolen": stolen,
		"map_id": map_id,
		"unlocked_maps": unlocked_maps,
		"grids": grids,
		"tiles_region": tiles_region,
		"bosses": bosses,
		"boss_respawn": boss_respawn,
		"ore": ore,
		"iron": iron,
		"quest": quest,
		"active_copy": active_copy,
		"name": name,
		"look": look,
		"quest_step": quest_step,
		"quest_progress": quest_progress,
		"seen_dialogs": seen_dialogs,
		"rare_at": rare_at,
		"job": job,
		"heat_free_until": heat_free_until,
		"evo": evo,
		"antidotes": antidotes,
		"fire_torches": fire_torches,
		"evo_essence": evo_essence,
		"herb_timer": herb_timer,
		"merchant": merchant,
		"gift_code": gift_code,
		"fog": fog,
		"fog_rewards": fog_rewards,
		"bulk_filter": bulk_filter,
	}


## Nạp save v1 hoặc v2. JSON trả số dạng float nên phải ép kiểu lại.
func load_dict(d: Dictionary) -> bool:
	var version := int(d.get("version", 0))
	if version < 1 or version > VERSION:
		return false
	talent = str(d.talent)
	level = int(d.level)
	xp = int(d.xp)
	points = {
		"str": int(d.points.str), "agi": int(d.points.agi), "int": int(d.points.get("int", 0)),
		"vit": int(d.points.vit), "luk": int(d.points.get("luk", 0)),
	}
	unspent = int(d.unspent)
	gold = float(d.gold)
	wood = float(d.wood)
	torches = int(d.torches)
	torch_timer = float(d.torch_timer)
	tiles = []
	for t in d.tiles:
		tiles.append(_load_tile(t))
	camp_level = int(d.camp_level)
	boss_defeated = bool(d.boss_defeated)
	kills = int(d.kills)
	play_seconds = float(d.play_seconds)
	last_seen = float(d.last_seen)

	# v1 không có các trường dưới đây: giữ giá trị mặc định (chuyển đổi save cũ).
	inventory = []
	for item in d.get("inventory", []):
		inventory.append(_load_item(item))
	equipment = {}
	var eq: Dictionary = d.get("equipment", {})
	for slot in eq:
		equipment[str(slot)] = _load_item(eq[slot])
	stones = int(d.get("stones", 0))
	next_item_id = int(d.get("next_item_id", 1))
	boss_respawn_at = float(d.get("boss_respawn_at", 0.0))

	# v3 — save v2 không có: dùng mặc định, và đánh dấu công trình cũ là đã xây xong.
	talent_level = int(d.get("talent_level", 1))
	essence = int(d.get("essence", 0))
	tinh_kim = int(d.get("tinh_kim", 0))
	potions = int(d.get("potions", 2))
	herbs = int(d.get("herbs", 0))
	pets = []
	for pet in d.get("pets", []):
		pets.append({"kind": str(pet.kind), "level": int(pet.level)})
	copied_skills = []
	for sk in d.get("copied_skills", []):
		copied_skills.append(str(sk))
	element = str(d.get("element", "kim"))
	build_clock = float(d.get("build_clock", 0.0))
	buildings = {}
	if d.has("buildings"):
		var b: Dictionary = d.buildings
		for k in b:
			buildings[str(k)] = float(b[k])
	else:
		for t in tiles:
			if t.event == "resource" and t.status == "owned":
				buildings["lumber_%d" % t.id] = 0.0
		if camp_level > 1:
			buildings["camp2"] = 0.0

	# v4 — save v3 trở xuống: Kiếm Khách, chưa cướp điểm nào.
	class_id = str(d.get("class_id", "kiem-khach"))
	stolen = []
	for k in d.get("stolen", []):
		stolen.append(str(k))

	# v5 — save v4 trở xuống: đang ở Rừng Sương; Lõi Sương mở nếu đã hạ Sói Chúa.
	map_id = str(d.get("map_id", "1-1"))
	unlocked_maps = []
	for m in d.get("unlocked_maps", ["1-1"]):
		unlocked_maps.append(str(m))
	if boss_defeated and not ("1-3" in unlocked_maps) and not d.has("unlocked_maps"):
		unlocked_maps.append("1-3")
	grids = {}
	var g: Dictionary = d.get("grids", {})
	for rid in g:
		var arr: Array = []
		for t in g[rid]:
			arr.append(_load_tile(t))
		grids[str(rid)] = arr
	tiles_region = int(d.get("tiles_region", 1))
	bosses = {}
	var bd: Dictionary = d.get("bosses", {})
	for k in bd:
		bosses[str(k)] = bool(bd[k])
	boss_respawn = {}
	var br: Dictionary = d.get("boss_respawn", {})
	for k in br:
		boss_respawn[str(k)] = float(br[k])
	ore = float(d.get("ore", 0.0))
	iron = float(d.get("iron", 0.0))
	var q: Dictionary = d.get("quest", {})
	# v9 — save v8 trở xuống: chưa tới vùng 3.
	var oases: Array = []
	for o in q.get("oases", []):
		oases.append(int(o))
	var orbs4: Array = []
	for o in q.get("orbs4", []):
		orbs4.append(int(o))
	quest = {"ch2": int(q.get("ch2", 0)), "kills2": int(q.get("kills2", 0)), "ch3": int(q.get("ch3", 0)), "kills3": int(q.get("kills3", 0)), "oases": oases,
		"ch4": int(q.get("ch4", 0)), "kills4": int(q.get("kills4", 0)), "orbs4": orbs4}
	# v10 — save v9 trở xuống: chưa tiến hoá.
	evo = int(d.get("evo", 0))
	antidotes = int(d.get("antidotes", 0))
	fire_torches = int(d.get("fire_torches", 0))
	job = str(d.get("job", ""))
	heat_free_until = float(d.get("heat_free_until", 0.0))
	active_copy = str(d.get("active_copy", ""))

	# v6 — save v5 trở xuống (08 mục 3.3).
	var Looks = load("res://scripts/data/looks.gd")
	name = str(d.get("name", Looks.DEFAULT_NAME))
	look = Looks.sanitize(d.get("look", null))
	if d.has("quest_step"):
		quest_step = int(d.quest_step)
	else:
		# Người chơi cũ đã qua phần hướng dẫn: hạ boss rồi → đã xong chương; chưa → vào thẳng bước 5.
		quest_step = 12 if boss_defeated else 5
	quest_progress = int(d.get("quest_progress", 0))
	seen_dialogs = []
	for k in d.get("seen_dialogs", []):
		seen_dialogs.append(str(k))
	rare_at = {}
	var ra: Dictionary = d.get("rare_at", {})
	for k in ra:
		rare_at[str(k)] = float(ra[k])
	if d.has("rare_boss_at") and float(d.rare_boss_at) > 0.0:
		rare_at["lao-thu"] = float(d.rare_boss_at)
	evo_essence = int(d.get("evo_essence", 0))
	gift_code = str(d.get("gift_code", ""))
	herb_timer = float(d.get("herb_timer", 0.0))
	merchant = {}
	var mc = d.get("merchant", {})
	if mc is Dictionary and mc.has("until"):
		var items: Array = []
		for it in mc.get("items", []):
			var item := _load_item(it)
			item["price"] = int(it.get("price", 0))
			items.append(item)
		merchant = {"until": float(mc.until), "items": items}
	# v7 — save v6 trở xuống: mọi map phủ sương, chưa nhận thưởng, bộ lọc mặc định.
	fog = {}
	var fd: Dictionary = d.get("fog", {})
	for k in fd:
		fog[str(k)] = str(fd[k])
	fog_rewards = {}
	var fr: Dictionary = d.get("fog_rewards", {})
	for k in fr:
		var arr: Array = []
		for v in fr[k]:
			arr.append(int(v))
		fog_rewards[str(k)] = arr
	var bf = d.get("bulk_filter", {})
	bulk_filter = bf.duplicate(true) if bf is Dictionary else {}
	# C1-21: lưới vùng 1 cũ 10 ô → thêm 30 ô của Rừng Sâu và Lõi Sương.
	var g1 := grid_of(1)
	if Explore.needs_region1_upgrade(g1):
		Explore.upgrade_region1(g1, talent, load("res://scripts/core/rng_util.gd").make(int(play_seconds) + 17))
	return true


## Lưới của một vùng (vùng hiện tại là `tiles`).
func grid_of(region_id: int) -> Array:
	if region_id == tiles_region:
		return tiles
	return grids.get(str(region_id), [])


## Mọi lưới, để tính sản lượng lãnh địa cả các vùng không đang đứng.
func all_grids() -> Array:
	var out: Array = [tiles]
	for rid in grids:
		if int(rid) != tiles_region:
			out.append(grids[rid])
	return out


## Đổi lưới hiện tại sang vùng khác (cất lưới cũ vào grids).
func switch_grid(region_id: int, make_grid: Callable) -> void:
	if region_id == tiles_region:
		return
	grids[str(tiles_region)] = tiles
	if grids.has(str(region_id)):
		tiles = grids[str(region_id)]
		grids.erase(str(region_id))
	else:
		tiles = make_grid.call(region_id)
	tiles_region = region_id


static func _load_tile(t: Dictionary) -> Dictionary:
	return {"id": int(t.id), "q": int(t.q), "r": int(t.r), "event": str(t.event), "status": str(t.status), "zone": int(t.get("zone", 1))}


static func _load_item(d: Dictionary) -> Dictionary:
	var affixes: Array = []
	for af in d.affixes:
		affixes.append({"stat": str(af.stat), "value": float(af.value)})
	return {
		"id": int(d.id),
		"slot": str(d.slot),
		"rarity": str(d.rarity),
		"level": int(d.level),
		"plus": int(d.plus),
		"set": str(d.get("set", "")),
		"unique": str(d.get("unique", "")),
		"affixes": affixes,
		"style": str(d.get("style", "")),
	}
