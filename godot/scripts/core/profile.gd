extends RefCounted
## Tiến trình được lưu lại giữa các lần chơi.

const Config = preload("res://scripts/core/config.gd")
const Explore = preload("res://scripts/core/explore.gd")

## v1: prototype Chương 1. v2: MVP M1 thêm trang bị (EQ-20). v3: MVP M2 thêm Thiên phú, công trình (mục 4.8).
## v4: MVP M3 thêm lớp nhân vật, INT/LUK, điểm Đạo Tặc cướp (mục 5.9).
## v5: MVP M4 thêm nhiều bản đồ, lưới từng vùng, boss theo id, Đá/Sắt, nhiệm vụ chương 2 (mục 6.5).
const VERSION := 5

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
var quest := {"ch2": 0, "kills2": 0}
## Kỹ năng sao chép đang dùng (Đạo Tặc, TP-39).
var active_copy := ""


func setup(talent_id: String, rng: Callable, now: float, class_name_id := "kiem-khach") -> void:
	talent = talent_id
	class_id = class_name_id
	tiles = Explore.create_tiles(rng)
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
		tiles.append({"id": int(t.id), "q": int(t.q), "r": int(t.r), "event": str(t.event), "status": str(t.status)})
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
			arr.append({"id": int(t.id), "q": int(t.q), "r": int(t.r), "event": str(t.event), "status": str(t.status)})
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
	quest = {"ch2": int(q.get("ch2", 0)), "kills2": int(q.get("kills2", 0))}
	active_copy = str(d.get("active_copy", ""))
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
