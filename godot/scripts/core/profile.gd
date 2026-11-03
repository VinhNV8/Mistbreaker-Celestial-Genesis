extends RefCounted
## Tiến trình được lưu lại giữa các lần chơi.

const Config = preload("res://scripts/core/config.gd")
const Explore = preload("res://scripts/core/explore.gd")
const RngUtil = preload("res://scripts/core/rng_util.gd")

## v1: prototype Chương 1. v2: MVP M1 thêm trang bị (EQ-20). v3: MVP M2 thêm Thiên phú, công trình (mục 4.8).
## v4: MVP M3 thêm lớp nhân vật, INT/LUK, điểm Đạo Tặc cướp (mục 5.9).
## v5: MVP M4 thêm nhiều bản đồ, lưới từng vùng, boss theo id, Đá/Sắt, nhiệm vụ chương 2 (mục 6.5).
## v6: đợt C1 thêm tên, ngoại hình, nhiệm vụ/thoại chương 1, lưới vùng 1 40 ô, boss hiếm, công trình mới (08 mục 3.3).
## v7: đợt SN2 thêm sương che bản đồ, thưởng khám phá, bộ lọc phân rã/bán nhanh (09 mục 3).
## v9: M6 chương 3 — chuyển chức 1 (job), nhiệm vụ chương 3 (quest.ch3/kills3/oases), miễn nắng (docs/10 mục 6).
## v10: M7 chương 4 — tiến hoá Thiên phú (evo), nhiệm vụ chương 4, Thuốc Giải, Đuốc Lửa (docs/11 mục 6).
## v11: M8 chương 5 — chuyển chức 2 (job2), Tinh Thạch, Bình Nước Thánh, đột kích Kim Luân (docs/12 mục 6).
## v12: M9 chương 6 — nhiệm vụ chương 6, Than Hồng (docs/14 mục 6).
## v13: SK1 hệ kỹ năng — Điểm Kỹ Năng, cấp kỹ năng, 4 ô lắp (docs/13).
## v14: SK2 — biến thể kỹ năng {id: [tầng I, II, III]} (docs/13).
## v15: hang phụ — caves {map cha: giây chơi khi hang mở lại} (docs/15).
## v16: SK3 — Bí Kíp {id kỹ năng: [tầng I, II, III]}, Mảnh Bí Kíp (docs/13).
## v17: M10 chương 7 — feathers (Lông Vũ Gió), anchor_stones {map: [chỉ số Đá Neo đã chạm]}, quest.ch7/kills7/pillars7/anchors7,
## camp3–5 + port trong buildings (docs/16 mục 7).
## v18: J3 — chuyển chức 3 (job3) (docs/23).
## v19: CS (docs/26) — 7 thuộc tính (thêm wis, dex); save cũ được tẩy điểm miễn phí 1 lần (Q152).
## v20: Đạo Tặc — Túi Tang Vật (steal_bag), Sổ Đạo Tặc {loài: điểm đã cướp} (steal_log) (03 CR-01.1 DT-16…19).
## v21: PV — cấp kỹ năng bị động (passive_levels) (docs/27).
## v22: SN10-02 — bình MP (mp_potions).
## v23: SN11-03 — map ×3 diện tích: lưới sương mù đổi kích thước → save cũ phủ sương lại (giữ thưởng khai phá đã nhận).
## v24: BK — Bí Kíp rơi = +1 Điểm Kỹ Năng; Mảnh Bí Kíp bỏ (save cũ: 5 Mảnh = 1 điểm, làm tròn lên); biến thể ✦ mở bằng điểm (docs/29).
## v25: M11 chương 8 — void_cores (Lõi Hư Vô), lanterns (Đèn Lồng Tinh Quang), lamp_off_until {"map:đèn": giây chơi},
## assault_play (giây chơi tới Phản công Hư Vô), quest.ch8/kills8/lamps8/cages8/pillars8 (docs/17 mục 6).
## v26: M12 chương 9 + endgame — floors9 (Cửa Tầng đã mở), ending ("" | hop-nhat | hien-te), divine_level, divine_points
## {nhánh: điểm}, tower_best (tầng Thần Vực), rebuild_raid {vùng: giây chơi buff tắt tới, "t<vùng>": giây tới Triều kế},
## quest.ch9/kills9/souls9 (docs/18 mục 7). EXP tích luỹ ở cấp 100 dùng chính profile.xp (thay trường exp_bank của spec).
## v27: SN12-02 — 7 ô kỹ năng (loadout 7 phần tử, "" = trống; save cũ 4 ô được thêm 3 ô trống), bộ kỹ năng thứ 2
## (loadout_alt), bộ đang dùng (loadout_set 0 / 1) (docs/31).
## v28: TP-05/13/14 (docs/33) — Thiên phú phụ (subs [{id, level}]), Nước Thánh Tinh Quang (starwater),
## cộng hưởng đặc biệt đã kích hoạt (resonance_seen). Save cũ: chưa có Thiên phú phụ (ô đã mở theo chuyển chức).
## v29: BD-11 (docs/34) — Cổng dungeon đang mở gates {map cha: {rank, until (giây chơi), x, y}}, số cổng đã dọn
## (gates_cleared), hạng cao nhất đã dọn (gate_best). Save cũ: chưa có cổng nào.
const VERSION := 29

var talent := ""
var level := 1
var xp := 0
var points := {"str": 0, "agi": 0, "vit": 0, "int": 0, "wis": 0, "dex": 0, "luk": 0}
var unspent := 0
## CS: vừa tẩy điểm miễn phí khi nạp save < v19 (chỉ trong phiên, không lưu) — GameWorld báo cho người chơi.
var cs_refunded := 0
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
## SN10-02: bình MP (phím F).
var mp_potions := 2
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
## v20 (DT-17): điểm cướp chờ khi giới hạn đã đầy (tối đa GameWorld.STEAL_BAG_MAX), tự cộng khi có chỗ.
var steal_bag: Array = []
## v20 (DT-19): Sổ Đạo Tặc — {loại quái: số điểm đã cướp từ loài đó (gồm cả điểm trong túi)}.
var steal_log := {}

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
var quest := {"ch2": 0, "kills2": 0, "ch3": 0, "kills3": 0, "oases": [], "ch4": 0, "kills4": 0, "orbs4": [], "ch5": 0, "kills5": 0, "raid_won": false,
	"ch6": 0, "kills6": 0, "beacons6": [], "dark6": 0}
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
## M8: chức 2 ("" = chưa), Tinh Thạch, Bình Nước Thánh, giây chơi ở vùng 5 từ lần đột kích trước, phạt ngừng sản xuất tới (giây chơi).
var job2 := ""
## J3 (docs/23): chức 3 — "" hoặc id trong Classes.JOBS3.
var job3 := ""
## SK1: Điểm Kỹ Năng chưa dùng, {id kỹ năng: cấp 1–10}, id kỹ năng ở 4 ô (rỗng = mặc định theo lớp).
var skill_points := 0
var skill_levels := {}
## PV (docs/27, v21): cấp kỹ năng bị động {id: 0–5}
var passive_levels := {}
var loadout: Array = []
## SN12-02 (v27): bộ kỹ năng còn lại (đổi bằng phím X) và bộ đang dùng (0 = Bộ 1, 1 = Bộ 2).
var loadout_alt: Array = []
var loadout_set := 0
var variants := {}
## HP-07: hang đã dọn → mở lại khi play_seconds ≥ giá trị (docs/15).
var caves := {}
var secret_books := {}
var crystal := 0.0
var holy_water := 0
## v28 (docs/33): Thiên phú phụ [{"id", "level"}] (tối đa 2), Nước Thánh Tinh Quang (tẩy Thiên phú), cộng hưởng đã thấy {id: true}.
var subs: Array = []
var starwater := 0
var resonance_seen := {}
## v29 (docs/34): Cổng dungeon.
var gates := {}
var gates_cleared := 0
var gate_best := ""
var raid_play := 0.0
var raid_penalty_until := 0.0
## M9: Than Hồng (phím Q xoá băng giá).
var embers := 0
## C7-15: Lông Vũ Gió · C7-12: Đá Neo đã chạm theo map.
var feathers := 0
var anchor_stones := {}
## M12 (v26)
var floors9: Array = []
var ending := ""
var divine_level := 0
var divine_points := {}
var tower_best := 0
var rebuild_raid := {}
## M11 (v25)
var void_cores := 0
var lanterns := 0
var lamp_off_until := {}
var assault_play := 0.0
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
		"mp_potions": mp_potions,
		"herbs": herbs,
		"pets": pets,
		"copied_skills": copied_skills,
		"element": element,
		"buildings": buildings,
		"build_clock": build_clock,
		"class_id": class_id,
		"stolen": stolen,
		"steal_bag": steal_bag,
		"steal_log": steal_log,
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
		"job2": job2,
		"job3": job3,
		"skill_points": skill_points,
		"skill_levels": skill_levels,
		"passive_levels": passive_levels,
		"loadout": loadout,
		"loadout_alt": loadout_alt,
		"loadout_set": loadout_set,
		"variants": variants,
		"caves": caves,
		"secret_books": secret_books,
		"crystal": crystal,
		"holy_water": holy_water,
		"subs": subs,
		"starwater": starwater,
		"resonance_seen": resonance_seen,
		"gates": gates,
		"gates_cleared": gates_cleared,
		"gate_best": gate_best,
		"raid_play": raid_play,
		"raid_penalty_until": raid_penalty_until,
		"embers": embers,
		"feathers": feathers,
		"anchor_stones": anchor_stones,
		"floors9": floors9,
		"ending": ending,
		"divine_level": divine_level,
		"divine_points": divine_points,
		"tower_best": tower_best,
		"rebuild_raid": rebuild_raid,
		"void_cores": void_cores,
		"lanterns": lanterns,
		"lamp_off_until": lamp_off_until,
		"assault_play": assault_play,
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
	points = {}
	for k in ["str", "agi", "vit", "int", "wis", "dex", "luk"]:
		points[k] = int(d.points.get(k, 0))
	unspent = int(d.unspent)
	# CS (v19): hệ số thuộc tính đổi hẳn → trả lại toàn bộ điểm đã cộng để người chơi phân bổ lại (điểm Đạo Tặc cướp giữ nguyên).
	cs_refunded = 0
	if version < 19:
		for k in points:
			cs_refunded += int(points[k])
			points[k] = 0
		unspent += cs_refunded
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
	mp_potions = int(d.get("mp_potions", 2))
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
	# v20 — save cũ: túi rỗng, sổ trống (điểm đã cướp trước đó chỉ tính vào giới hạn tổng).
	steal_bag = []
	for k in d.get("steal_bag", []):
		steal_bag.append(str(k))
	steal_log = {}
	var log_d = d.get("steal_log", {})
	if log_d is Dictionary:
		for k in log_d:
			steal_log[str(k)] = int(log_d[k])

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
	var beacons6: Array = []
	for o in q.get("beacons6", []):
		beacons6.append(int(o))
	quest = {"ch2": int(q.get("ch2", 0)), "kills2": int(q.get("kills2", 0)), "ch3": int(q.get("ch3", 0)), "kills3": int(q.get("kills3", 0)), "oases": oases,
		"ch4": int(q.get("ch4", 0)), "kills4": int(q.get("kills4", 0)), "orbs4": orbs4,
		"ch5": int(q.get("ch5", 0)), "kills5": int(q.get("kills5", 0)), "raid_won": bool(q.get("raid_won", false)),
		"ch6": int(q.get("ch6", 0)), "kills6": int(q.get("kills6", 0)), "beacons6": beacons6, "dark6": int(q.get("dark6", 0))}
	# v10 — save v9 trở xuống: chưa tiến hoá.
	evo = int(d.get("evo", 0))
	antidotes = int(d.get("antidotes", 0))
	fire_torches = int(d.get("fire_torches", 0))
	job2 = str(d.get("job2", ""))
	job3 = str(d.get("job3", ""))
	# SK1: save cũ chưa có Điểm Kỹ Năng → bù 1 điểm cho mỗi cấp đã lên.
	skill_points = int(d.get("skill_points", maxi(0, level - 1)))
	skill_levels = {}
	var sl: Dictionary = d.get("skill_levels", {})
	for k in sl:
		skill_levels[str(k)] = int(sl[k])
	# PV (v21): save cũ chưa có bị động → chưa học bị động nào.
	passive_levels = {}
	var pl: Dictionary = d.get("passive_levels", {})
	for k in pl:
		passive_levels[str(k)] = int(pl[k])
	loadout = []
	for k in d.get("loadout", []):
		loadout.append(str(k))
	# v27: 4 ô cũ → 7 ô (GameWorld._ensure_loadout thêm ô trống); chưa có bộ 2 → để trống, lần đổi bộ đầu tiên chép bộ 1.
	loadout_alt = []
	for k in d.get("loadout_alt", []):
		loadout_alt.append(str(k))
	loadout_set = clampi(int(d.get("loadout_set", 0)), 0, 1)
	caves = {}
	var cv: Dictionary = d.get("caves", {})
	for k in cv:
		caves[str(k)] = float(cv[k])
	variants = {}
	var vr: Dictionary = d.get("variants", {})
	for k in vr:
		var arr: Array = []
		for x in vr[k]:
			arr.append(str(x))
		variants[str(k)] = arr
	secret_books = {}
	var sb: Dictionary = d.get("secret_books", {})
	for k in sb:
		var arr2: Array = []
		for x in sb[k]:
			arr2.append(bool(x))
		secret_books[str(k)] = arr2
	# BK (v24, docs/29): bỏ Mảnh Bí Kíp — 5 Mảnh = 1 Điểm Kỹ Năng (làm tròn lên). Biến thể ✦ đã có giữ nguyên.
	if version < 24:
		skill_points += ceili(int(d.get("book_shards", 0)) / 5.0)
	crystal = float(d.get("crystal", 0.0))
	holy_water = int(d.get("holy_water", 0))
	subs = []
	for sd in d.get("subs", []):
		if sd is Dictionary and str(sd.get("id", "")) != "":
			subs.append({"id": str(sd.id), "level": clampi(int(sd.get("level", 1)), 1, 10)})
	starwater = int(d.get("starwater", 0))
	resonance_seen = {}
	var rs: Dictionary = d.get("resonance_seen", {})
	for k in rs:
		resonance_seen[str(k)] = true
	gates = {}
	var gd: Dictionary = d.get("gates", {})
	for k in gd:
		var gv = gd[k]
		if gv is Dictionary and str(gv.get("rank", "")) in ["E", "D", "C", "B", "A", "S"]:
			gates[str(k)] = {"rank": str(gv.rank), "until": float(gv.get("until", 0.0)), "x": float(gv.get("x", 0.0)), "y": float(gv.get("y", 0.0))}
	gates_cleared = int(d.get("gates_cleared", 0))
	gate_best = str(d.get("gate_best", ""))
	raid_play = float(d.get("raid_play", 0.0))
	raid_penalty_until = float(d.get("raid_penalty_until", 0.0))
	# v12 — save v11 trở xuống: chưa tới vùng 6.
	embers = int(d.get("embers", 0))
	feathers = int(d.get("feathers", 0))
	anchor_stones = {}
	var an: Dictionary = d.get("anchor_stones", {})
	for k in an:
		var arr: Array = []
		for x in an[k]:
			arr.append(int(x))
		anchor_stones[str(k)] = arr
	# v26 — save v25 trở xuống: chưa tới vùng 9.
	floors9 = []
	for f in d.get("floors9", []):
		floors9.append(int(f))
	ending = str(d.get("ending", ""))
	divine_level = int(d.get("divine_level", 0))
	divine_points = {}
	var dp: Dictionary = d.get("divine_points", {})
	for k in dp:
		divine_points[str(k)] = int(dp[k])
	tower_best = int(d.get("tower_best", 0))
	rebuild_raid = {}
	var rr: Dictionary = d.get("rebuild_raid", {})
	for k in rr:
		rebuild_raid[str(k)] = float(rr[k])
	# v25 — save v24 trở xuống: chưa tới vùng 8.
	void_cores = int(d.get("void_cores", 0))
	lanterns = int(d.get("lanterns", 0))
	assault_play = float(d.get("assault_play", 0.0))
	lamp_off_until = {}
	var lo: Dictionary = d.get("lamp_off_until", {})
	for k in lo:
		lamp_off_until[str(k)] = float(lo[k])
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
	var fd: Dictionary = d.get("fog", {}) if version >= 23 else {}
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
	# Khôi phục lưới khai phá nếu bị rỗng do save cũ hoặc lỗi dữ liệu
	if tiles.is_empty():
		var seed_val := int(play_seconds) + int(level) * 31 + kills
		tiles = Explore.create_region_tiles(tiles_region, RngUtil.make(seed_val), talent)
	# C1-21: lưới vùng 1 cũ 10 ô → thêm 30 ô của Rừng Sâu và Lõi Sương.
	var g1 := grid_of(1)
	if Explore.needs_region1_upgrade(g1):
		Explore.upgrade_region1(g1, talent, RngUtil.make(int(play_seconds) + 17))
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
	if region_id == tiles_region and not tiles.is_empty():
		return
	if not tiles.is_empty():
		grids[str(tiles_region)] = tiles
	if grids.has(str(region_id)) and not grids[str(region_id)].is_empty():
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
