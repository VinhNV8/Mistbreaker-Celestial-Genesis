extends RefCounted
## Lưới khai phá lục giác, sự kiện ô đất, công trình và sản lượng lãnh địa.
## Mỗi ô là Dictionary {id, q, r, event, status}; status: "fog" | "revealed" | "owned".
## Các hàm nhận `p` là Profile (không khai báo kiểu để tránh preload vòng tròn).

const Config = preload("res://scripts/core/config.gd")
const Formulas = preload("res://scripts/core/formulas.gd")
const RngUtil = preload("res://scripts/core/rng_util.gd")
const Talents = preload("res://scripts/data/talents.gd")
## TP-05 (docs/33): Thiên phú chính + phụ, cộng hưởng.
const TalentSlots = preload("res://scripts/core/talent_slots.gd")

const EVENT_INFO := {
	"camp": {"name": "Trại Khai Giới", "short": "Trại", "desc": "Trung tâm lãnh địa của bạn.", "color": "#c9a45c"},
	"resource": {
		"name": "Rừng gỗ",
		"short": "Gỗ",
		"desc": "Xây Xưởng Gỗ để khai thác gỗ và vàng, kể cả khi offline (tối đa 12 giờ).",
		"color": "#4f9a5b",
	},
	"nest": {"name": "Ổ quái", "short": "Ổ quái", "desc": "Quái tinh anh canh giữ. Hạ nó để chiếm ô đất.", "color": "#b8484f"},
	"relic": {"name": "Di tích", "short": "Di tích", "desc": "Rương báu và một trang sách cốt truyện.", "color": "#c08a3e"},
	"survivor": {"name": "Người sống sót", "short": "Dân", "desc": "Gia nhập lãnh địa: +10% sản lượng.", "color": "#5a8fd0"},
	"wonder": {"name": "Suối Linh Khí", "short": "Kỳ quan", "desc": "Kỳ quan: +10% EXP nhận được từ chiến đấu.", "color": "#9b6be0"},
	## M4.3 (KP-06): núi đá → Mỏ (Đá, Sắt); suối → Bến Cá (+3% HP tối đa mỗi Bến Cá, tối đa +15%).
	"mine": {"name": "Núi đá", "short": "Mỏ", "desc": "Xây Mỏ: 4 Đá và 2 Sắt mỗi phút, kể cả khi offline.", "color": "#8c8f99"},
	"fishery": {"name": "Suối", "short": "Suối", "desc": "Xây Bến Cá: +3% HP tối đa (cộng dồn tối đa +15%).", "color": "#4a9df8"},
	## C8-03 (M11): vùng 8 không có tài nguyên thường — ô Tài nguyên thành Mạch Tinh Thạch.
	"vein": {"name": "Mạch Tinh Thạch", "short": "Mạch", "desc": "Chiếm ô: +10 Tinh Thạch một lần (không xây công trình).", "color": "#b48af0"},
	"merchant": {
		"name": "Thương nhân lữ hành",
		"short": "Thương nhân",
		"desc": "Mời thương nhân về trại: bán đồ Xanh dương/Tím trong 1 giờ (phím E ở làng).",
		"color": "#e0b040",
	},
}

## C1-21: 3 map con của vùng 1 trên cùng một lưới (zone 1–3). Zone 3 = Lõi Sương, khoá tới khi hạ Sói Chúa.
const ZONE_NAMES := {1: "Bìa Rừng Sương", 2: "Rừng Sương Sâu", 3: "Lõi Sương"}
const ZONE_NAMES_R2 := {1: "Cửa Gió", 2: "Thảo Nguyên Hú", 3: "Mắt Bão"}
const REGION_ZONE_NAMES := {
	1: {1: "Bìa Rừng Sương", 2: "Rừng Sương Sâu", 3: "Lõi Sương"},
	2: {1: "Cửa Gió", 2: "Thảo Nguyên Hú", 3: "Mắt Bão"},
	3: {1: "Rìa Cát Đỏ", 2: "Ốc Đảo Lãng Quên", 3: "Di Tích Khai Giới Giả"},
	4: {1: "Bãi Lau Mù", 2: "Đầm Sâu", 3: "Cung Mộng"},
	5: {1: "Chân Núi Tro", 2: "Sườn Dung Nham", 3: "Miệng Núi Lửa"},
	6: {1: "Đồng Tuyết", 2: "Rừng Băng", 3: "Đỉnh Cực Quang"},
	7: {1: "Đảo Mây Trôi", 2: "Đảo Rừng Treo", 3: "Thiên Cung Đổ Nát"},
	8: {1: "Rìa Vực", 2: "Đáy Vực", 3: "Sào Huyệt Hư Vô"},
	9: {1: "Tầng 1–3", 2: "Tầng 4–6", 3: "Tầng 7–9"},
}
## C8-03: vùng 8 — chiếm ô Mạch Tinh Thạch +10, mọi ô khác +3 Tinh Thạch.
const VEIN_CRYSTAL := 10
const VOID_TILE_CRYSTAL := 3


static func zone_name(region: int, zone: int) -> String:
	if REGION_ZONE_NAMES.has(region):
		return str(REGION_ZONE_NAMES[region].get(zone, ""))
	return str((ZONE_NAMES_R2 if region == 2 else ZONE_NAMES).get(zone, ""))
const ZONE2_EVENTS := ["resource", "resource", "resource", "resource", "resource", "resource", "nest", "nest", "nest", "nest",
	"relic", "relic", "survivor", "survivor", "merchant"]
const ZONE3_EVENTS := ["resource", "resource", "resource", "resource", "resource", "resource", "nest", "nest", "nest", "nest", "nest",
	"relic", "survivor", "merchant", "merchant"]
## Khứu Giác Kho Báu: số ô Tài nguyên ở zone 2, 3 đổi thành Di tích (8/40 = 20%, kịch bản mục 7).
const SCENT_RELICS := [2, 1]
const HEX_DIRS := [[1, 0], [1, -1], [0, -1], [-1, 0], [-1, 1], [0, 1]]

## Lưới 10 ô của Chương 1: vòng 1 (6 ô) + 4 ô vòng 2, quanh Trại Khai Giới.
const RING1 := [[1, 0], [1, -1], [0, -1], [-1, 0], [-1, 1], [0, 1]]
const RING2 := [[2, 0], [-1, -1], [-2, 2], [1, 1]]
const RING1_EVENTS := ["resource", "resource", "resource", "relic", "survivor", "nest"]
const RING2_EVENTS := ["resource", "nest", "relic", "wonder"]

const RELIC_LORE := [
	"Trang sách cũ: “Ngày trời nứt làm chín, Khai Giới Giả mạnh nhất đã đứng trước Bia Đá và vươn tay đoạt lấy ánh sáng…”",
	"Trang sách cũ: “Kẻ không mặt ấy không còn Thiên phú của riêng mình. Hắn sẽ quay lại, tìm mảnh linh hồn đã đánh mất.”",
]

## TL-S3: công trình. time = giây xây; Trái Tim Lãnh Chúa ×0,75.
const BUILDINGS := {
	"lumber": {"name": "Xưởng Gỗ", "time": 60.0},
	"camp2": {"name": "Nâng Trại thành Thôn", "time": 180.0, "gold": 100, "wood": 100},
	"temple": {"name": "Đền Thiên Phú", "time": 120.0, "gold": 80, "wood": 60},
	"dragon": {"name": "Long Mạch Đàn", "time": 120.0, "gold": 150, "wood": 100},
	"forge": {"name": "Xưởng Rèn", "time": 120.0, "gold": 150, "wood": 80},
	"mine": {"name": "Mỏ", "time": 90.0, "gold": 40, "wood": 40},
	"fishery": {"name": "Bến Cá", "time": 60.0, "gold": 30, "wood": 30},
	"garden": {"name": "Vườn Thảo Dược", "time": 90.0, "gold": 60, "wood": 60},
	# C7-02 (docs/16): nâng trung tâm lãnh địa Trấn → Thành → Hoàng Thành — cần số ô đã chiếm (mọi vùng) + tài nguyên.
	"camp3": {"name": "Nâng Thôn thành Trấn", "time": 600.0, "gold": 2000, "wood": 400, "ore": 300, "iron": 150, "tiles": 40, "needs": "camp2"},
	"camp4": {"name": "Nâng Trấn thành Thành", "time": 1200.0, "gold": 6000, "wood": 800, "ore": 600, "iron": 400, "crystal": 40, "tiles": 80, "needs": "camp3"},
	"camp5": {"name": "Nâng Thành thành Hoàng Thành", "time": 2400.0, "gold": 15000, "wood": 1200, "ore": 1000, "iron": 700, "crystal": 100, "tiles": 120, "needs": "camp4"},
	# C7-04: Cảng Khí Cầu (KP-18) — chỉ xây khi trung tâm cấp 5; mở Bến Khí Cầu 6-3 → 7-1.
	"port": {"name": "Cảng Khí Cầu", "time": 1200.0, "gold": 5000, "wood": 400, "iron": 300, "crystal": 60, "needs": "camp5"},
	# C9-52 (M12): Tái Thiết Lục Địa — 1 công trình mỗi vùng k (giá theo k; k ≥ 8 thêm 2 Lõi Hư Vô), chỉ sau kết thúc Hiến tế.
	"rebuild1": {"name": "Tháp Sương Tan", "time": 600.0, "gold": 2000, "wood": 200, "ore": 150, "iron": 100, "crystal": 20},
	"rebuild2": {"name": "Phong Đài", "time": 600.0, "gold": 4000, "wood": 400, "ore": 300, "iron": 200, "crystal": 40},
	"rebuild3": {"name": "Giếng Sa Mạc", "time": 600.0, "gold": 6000, "wood": 600, "ore": 450, "iron": 300, "crystal": 60},
	"rebuild4": {"name": "Vườn Mộng", "time": 600.0, "gold": 8000, "wood": 800, "ore": 600, "iron": 400, "crystal": 80},
	"rebuild5": {"name": "Lò Rèn Viêm Long", "time": 600.0, "gold": 10000, "wood": 1000, "ore": 750, "iron": 500, "crystal": 100},
	"rebuild6": {"name": "Đài Cực Quang", "time": 600.0, "gold": 12000, "wood": 1200, "ore": 900, "iron": 600, "crystal": 120},
	"rebuild7": {"name": "Cảng Thiên Không", "time": 600.0, "gold": 14000, "wood": 1400, "ore": 1050, "iron": 700, "crystal": 140},
	"rebuild8": {"name": "Đèn Tinh Quang Vĩnh Cửu", "time": 600.0, "gold": 16000, "wood": 1600, "ore": 1200, "iron": 800, "crystal": 160, "cores": 2},
	"rebuild9": {"name": "Đền Thiên Đạo", "time": 600.0, "gold": 18000, "wood": 1800, "ore": 1350, "iron": 900, "crystal": 180, "cores": 2},
}
## C7-02: tên trung tâm theo cấp và % sản lượng cộng thêm.
const CAMP_NAMES := ["", "Trại Khai Giới", "Thôn", "Trấn", "Thành", "Hoàng Thành"]
const CAMP_BONUS := [0.0, 0.0, 0.2, 0.3, 0.4, 0.5]
## Thứ tự khoá tài nguyên khi hiện / trừ giá.
const COST_KEYS := [["gold", "vàng"], ["wood", "Gỗ"], ["ore", "Đá"], ["iron", "Sắt"], ["crystal", "Tinh Thạch"]]
## C1-31: Vườn Thảo Dược sinh 1 thảo dược mỗi 3 phút.
const GARDEN_PERIOD := 180.0
const HERB_CAP := 99


## talent: Khứu Giác Kho Báu đổi thêm Di tích ở zone 2, 3.
static func create_tiles(rng: Callable, talent := "") -> Array:
	var tiles: Array = [{"id": 0, "q": 0, "r": 0, "event": "camp", "status": "owned", "zone": 1}]
	var ring1 := RngUtil.shuffle(RING1_EVENTS, rng)
	var ring2 := RngUtil.shuffle(RING2_EVENTS, rng)
	for i in RING1.size():
		tiles.append({"id": tiles.size(), "q": RING1[i][0], "r": RING1[i][1], "event": ring1[i], "status": "fog", "zone": 1})
	for i in RING2.size():
		tiles.append({"id": tiles.size(), "q": RING2[i][0], "r": RING2[i][1], "event": ring2[i], "status": "fog", "zone": 1})
	upgrade_region1(tiles, talent, rng)
	return tiles


## M4.3 (KP-01, KP-11): lưới vùng 2 — 45 ô (vòng 1–3 = 36 ô + 9 ô vòng 4), tâm là Thành Biên Đài.
## Tỉ lệ kịch bản 35/25/12/10/8/7/3; Cổng dungeon (7%) chưa có → tính là Tài nguyên (Q41).
## Tài nguyên chia Rừng thưa (Xưởng Gỗ), Núi đá (Mỏ), Suối (Bến Cá).
const REGION2_EVENTS := {"resource": 7, "mine": 6, "fishery": 6, "nest": 11, "relic": 5, "survivor": 5, "merchant": 4, "wonder": 1}


static func create_region_tiles(region: int, rng: Callable, talent := "") -> Array:
	if region <= 1:
		return create_tiles(rng, talent)
	var events: Array = []
	for ev in REGION2_EVENTS:
		for _i in int(REGION2_EVENTS[ev]):
			events.append(ev)
	# TP-26: Khứu Giác Kho Báu — Di tích 12% → 20% (đổi 4 ô Tài nguyên).
	if talent == "khuu-giac":
		for _i in 4:
			events[events.find("resource")] = "relic"
	if region == 8:
		for i in events.size():
			if events[i] in ["resource", "mine", "fishery"]:
				events[i] = "vein"
	# C9-04: vùng 9 không có tài nguyên thường — ô Tài nguyên thành Kỳ quan nhỏ hoặc Ổ quái.
	if region == 9:
		var flip := false
		for i in events.size():
			if events[i] in ["resource", "mine", "fishery"]:
				events[i] = "wonder" if flip else "nest"
				flip = not flip
	events = RngUtil.shuffle(events, rng)
	var coords: Array = ring(1) + ring(2) + ring(3)
	var r4: Array = ring(4)
	r4.sort_custom(func(a, b): return int(a[0]) * 2 + int(a[1]) > int(b[0]) * 2 + int(b[1]))
	coords += r4.slice(0, 9)
	var tiles: Array = [{"id": 0, "q": 0, "r": 0, "event": "camp", "status": "owned", "zone": 1}]
	for i in coords.size():
		var c: Array = coords[i]
		var rr := hex_distance({"q": c[0], "r": c[1]}, {"q": 0, "r": 0})
		tiles.append({"id": tiles.size(), "q": c[0], "r": c[1], "event": events[i], "status": "fog", "zone": clampi(rr - 1, 1, 3)})
	# C9-04: 45 ô = 9 tầng × 5 ô (tầng theo thứ tự vòng từ trong ra)
	if region == 9:
		for i in range(1, tiles.size()):
			tiles[i]["floor"] = (i - 1) / 5 + 1
	return tiles


## C9-04: chiếm đủ 5 ô của một tầng vùng 9 → 1 Tinh Hoa Tiến Hoá (mỗi tầng 1 lần). Trả về số tầng vừa đủ (0 nếu không).
static func floor_reward(p, tile: Dictionary) -> int:
	var f := int(tile.get("floor", 0))
	if f <= 0:
		return 0
	var done: Array = p.quest.get("tiles9", [])
	if f in done:
		return 0
	for t in p.tiles:
		if int(t.get("floor", 0)) == f and str(t.status) != "owned":
			return 0
	done.append(f)
	p.quest["tiles9"] = done
	p.evo_essence = int(p.evo_essence) + 1
	return f


## Khoá công trình trên ô: vùng 1 giữ dạng cũ "lumber_<id>", vùng khác "lumber_r<vùng>_<id>" (id ô trùng giữa các vùng).
static func tile_key(kind: String, tile: Dictionary, region: int) -> String:
	return "%s_%d" % [kind, int(tile.id)] if region <= 1 else "%s_r%d_%d" % [kind, region, int(tile.id)]


## [[vùng, lưới], …] — mọi lưới đã có (vùng đang đứng + đã cất).
static func region_grids(p) -> Array:
	var out: Array = [[int(p.tiles_region), p.tiles]]
	for rid in p.grids:
		if int(rid) != int(p.tiles_region):
			out.append([int(rid), p.grids[rid]])
	return out


static func count_built(p, kind: String) -> int:
	var n := 0
	for rg in region_grids(p):
		for t in rg[1]:
			if t.status == "owned" and is_built(p, tile_key(kind, t, rg[0])):
				n += 1
	return n


static func ring(radius: int) -> Array:
	var out: Array = []
	var q := -radius
	var r := radius
	for d in 6:
		for _i in radius:
			out.append([q, r])
			q += HEX_DIRS[d][0]
			r += HEX_DIRS[d][1]
	return out


## Lưới vùng 1 của save cũ chỉ có 10 ô (zone 1).
static func needs_region1_upgrade(tiles: Array) -> bool:
	return not tiles.is_empty() and tiles.size() <= 11


## C1-21: thêm 15 ô Rừng Sâu (zone 2) và 15 ô Lõi Sương (zone 3). Lõi Sương ở phía đông (q lớn).
static func upgrade_region1(tiles: Array, talent: String, rng: Callable) -> void:
	var used := {}
	for t in tiles:
		used["%d,%d" % [int(t.q), int(t.r)]] = true
		if not t.has("zone"):
			t["zone"] = 1
	var by_east := func(a, b): return int(a[0]) * 2 + int(a[1]) > int(b[0]) * 2 + int(b[1])
	var r2: Array = ring(2).filter(func(c): return not used.has("%d,%d" % [c[0], c[1]]))
	var r3: Array = ring(3)
	r3.sort_custom(by_east)
	var r4: Array = ring(4)
	r4.sort_custom(by_east)
	var zone3: Array = r3.slice(0, 11) + r4.slice(0, 4)
	var zone2: Array = r2 + r3.slice(11)
	var e2: Array = ZONE2_EVENTS.duplicate()
	var e3: Array = ZONE3_EVENTS.duplicate()
	if talent == "khuu-giac":
		for pair in [[e2, SCENT_RELICS[0]], [e3, SCENT_RELICS[1]]]:
			var arr: Array = pair[0]
			for _i in int(pair[1]):
				arr[arr.find("resource")] = "relic"
	e2 = RngUtil.shuffle(e2, rng)
	e3 = RngUtil.shuffle(e3, rng)
	for i in zone2.size():
		tiles.append({"id": tiles.size(), "q": zone2[i][0], "r": zone2[i][1], "event": e2[i], "status": "fog", "zone": 2})
	for i in zone3.size():
		tiles.append({"id": tiles.size(), "q": zone3[i][0], "r": zone3[i][1], "event": e3[i], "status": "fog", "zone": 3})


static func zone_of(tile: Dictionary) -> int:
	return int(tile.get("zone", 1))


static func zone_owned(tiles: Array, zone: int) -> int:
	var n := 0
	for t in tiles:
		if t.event != "camp" and t.status == "owned" and zone_of(t) == zone:
			n += 1
	return n


static func hex_distance(a: Dictionary, b: Dictionary) -> int:
	var dq: int = int(a.q) - int(b.q)
	var dr: int = int(a.r) - int(b.r)
	return int((absi(dq) + absi(dr) + absi(dq + dr)) / 2.0)


static func distance_to_owned(tiles: Array, tile: Dictionary) -> int:
	var best := 1_000_000
	for t in tiles:
		if t.status == "owned":
			best = mini(best, hex_distance(t, tile))
	return best


static func owned_count(tiles: Array) -> int:
	var n := 0
	for t in tiles:
		if t.event != "camp" and t.status == "owned":
			n += 1
	return n


static func explore_total(tiles: Array) -> int:
	var n := 0
	for t in tiles:
		if t.event != "camp":
			n += 1
	return n


static func explored_ratio(tiles: Array) -> float:
	var total := explore_total(tiles)
	return 0.0 if total == 0 else float(owned_count(tiles)) / total


static func count_owned(tiles: Array, event: String) -> int:
	var n := 0
	for t in tiles:
		if t.event == event and t.status == "owned":
			n += 1
	return n


static func has_wonder(tiles: Array) -> bool:
	return count_owned(tiles, "wonder") > 0


## Thiên phú Mắt Ưng nhìn xuyên sương mù các ô cách lãnh địa tối đa 2 ô.
static func is_event_visible(tiles: Array, tile: Dictionary, talent: String) -> bool:
	if tile.status != "fog":
		return true
	return talent == "mat-ung" and distance_to_owned(tiles, tile) <= 2


## TP-05 (docs/33): như is_event_visible nhưng theo mọi Thiên phú của hồ sơ; TP13 Thợ Săn Di Tích → mọi ô Di tích hiện.
static func event_visible(p, tile: Dictionary) -> bool:
	if tile.status != "fog":
		return true
	if tile.event == "relic" and TalentSlots.has_special(p, "di-tich"):
		return true
	return TalentSlots.has(p, "mat-ung") and distance_to_owned(p.tiles, tile) <= 2


# ------------------------------------------------------------------ Đuốc


## Khai phá cấp 5: +1 Đuốc tối đa.
static func torch_max(p) -> int:
	var n := 0
	for slot in p.equipment:
		if str(p.equipment[slot].get("set", "")) == "phong_hanh":
			n += 1
	# TB-05: Bộ Phong Hành ≥ 4 món + Thiên phú nhóm Khai phá → +1 Đuốc tối đa.
	var resonance := 1 if n >= 4 and TalentSlots.ids(p).any(func(id): return str(Talents.get_talent(id).group) == "explore") else 0
	# TP13 Lữ Khách Thiên Mệnh (Chân Không Biết Mỏi + Thiên Mệnh Khai Giới): +3 Đuốc tối đa.
	var traveler := 3 if TalentSlots.has_special(p, "lu-khach") else 0
	# C9-52: Giếng Sa Mạc (Tái Thiết vùng 3) +1 Đuốc tối đa.
	var well := 1 if is_built(p, "rebuild3") else 0
	return Config.TORCH_MAX + (1 if TalentSlots.has_group_sub(p, "explore", 1) else 0) + resonance + well + traveler


## Khai phá cấp 10: Đuốc hồi nhanh hơn 20%.
static func torch_regen_sec(p) -> float:
	return Config.TORCH_REGEN_SEC * (0.8 if TalentSlots.has_group_sub(p, "explore", 2) else 1.0) * (0.8 if is_built(p, "rebuild3") else 1.0)


## Lý do không thể dùng Đuốc lên ô này, hoặc chuỗi rỗng nếu được phép.
static func reveal_blocker(p, tile: Dictionary) -> String:
	if tile.status != "fog":
		return "Ô đất đã được dọn sương."
	if zone_of(tile) == 3 and not p.boss_defeated:
		return "Lõi Sương bị sương Hư Vô dày đặc phong toả — hạ Sói Chúa Hư Vô trước."
	if distance_to_owned(p.tiles, tile) > 1:
		return "Chỉ dọn được ô kề lãnh địa."
	if p.torches <= 0:
		return "Hết Đuốc Khai Giới — đợi hồi hoặc hạ quái tinh anh."
	return ""


## Lý do chưa thể chiếm ô đất (thiếu tài nguyên / vàng / gỗ); "" nếu đủ điều kiện.
static func claim_blocker(p, tile: Dictionary) -> String:
	if tile.is_empty() or tile.status != "revealed":
		return "Ô đất này chưa thể chiếm."
	match tile.event:
		"resource":
			if p.gold < Config.LUMBER_COST_GOLD:
				return "Cần %d vàng để xây Xưởng Gỗ (hiện có %d vàng)." % [Config.LUMBER_COST_GOLD, int(p.gold)]
		"mine":
			var def: Dictionary = BUILDINGS["mine"]
			if p.gold < def.gold or p.wood < def.wood:
				return "Cần %d vàng và %d Gỗ để xây Mỏ (hiện có %d vàng, %d Gỗ)." % [int(def.gold), int(def.wood), int(p.gold), int(p.wood)]
		"fishery":
			var def: Dictionary = BUILDINGS["fishery"]
			if p.gold < def.gold or p.wood < def.wood:
				return "Cần %d vàng và %d Gỗ để xây Bến Cá (hiện có %d vàng, %d Gỗ)." % [int(def.gold), int(def.wood), int(p.gold), int(p.wood)]
	return ""


static func find_tile(p, id: int) -> Dictionary:
	for t in p.tiles:
		if int(t.id) == id:
			return t
	return {}


static func _result(ok: bool, message: String, exp_gain := 0, start_nest := false) -> Dictionary:
	return {"ok": ok, "message": message, "exp": exp_gain, "start_nest": start_nest}


static func reveal_tile(p, id: int) -> Dictionary:
	var tile := find_tile(p, id)
	if tile.is_empty():
		return _result(false, "Không tìm thấy ô đất.")
	var blocker := reveal_blocker(p, tile)
	if blocker != "":
		return _result(false, blocker)
	p.torches -= 1
	tile.status = "revealed"
	var names := [EVENT_INFO[tile.event].name]
	# Thiên Mệnh Khai Giới: dọn thêm tối đa 2 ô sương kề ô vừa dọn.
	if TalentSlots.has(p, "thien-menh"):
		var extra := 0
		for t in p.tiles:
			if extra >= 2:
				break
			if t.status == "fog" and hex_distance(t, tile) == 1 and (zone_of(t) != 3 or p.boss_defeated):
				t.status = "revealed"
				names.append(EVENT_INFO[t.event].name)
				extra += 1
	var exp_gain: int = Formulas.explore_exp(int(p.level)) * names.size()
	return _result(true, "Sương mù tan: phát hiện %s." % ", ".join(names), exp_gain)


## bonus: ô Di tích mở bằng cách giải câu đố (M5-04) — thưởng gấp đôi + 1 Đá Cường Hoá.
static func claim_tile(p, id: int, bonus := false) -> Dictionary:
	var res := _claim_tile(p, id, bonus)
	var tile := find_tile(p, id)
	if res.ok and int(p.tiles_region) == 8 and not tile.is_empty() and tile.status == "owned" and tile.event != "vein":
		p.crystal += VOID_TILE_CRYSTAL
		res.message = str(res.message) + " +%d Tinh Thạch." % VOID_TILE_CRYSTAL
	if res.ok and not tile.is_empty() and tile.status == "owned" and floor_reward(p, tile) > 0:
		res.message = str(res.message) + " Đủ 5 ô tầng %d: +1 Tinh Hoa Tiến Hoá." % int(tile.floor)
	return res


static func _claim_tile(p, id: int, bonus := false) -> Dictionary:
	var tile := find_tile(p, id)
	if tile.is_empty() or tile.status != "revealed":
		return _result(false, "Ô đất này chưa thể chiếm.")
	match tile.event:
		"vein":
			tile.status = "owned"
			p.crystal += VEIN_CRYSTAL
			return _result(true, "Chiếm Mạch Tinh Thạch: +%d Tinh Thạch." % VEIN_CRYSTAL)
		"resource":
			if p.gold < Config.LUMBER_COST_GOLD:
				return _result(false, "Cần %d vàng để xây Xưởng Gỗ." % Config.LUMBER_COST_GOLD)
			p.gold -= Config.LUMBER_COST_GOLD
			tile.status = "owned"
			start_building(p, tile_key("lumber", tile, int(p.tiles_region)))
			return _result(true, "Bắt đầu xây Xưởng Gỗ (%d giây)." % roundi(build_time(p, "lumber")))
		"mine", "fishery":
			var def: Dictionary = BUILDINGS[tile.event]
			if p.gold < def.gold or p.wood < def.wood:
				return _result(false, "Cần %d vàng và %d gỗ để xây %s." % [def.gold, def.wood, def.name])
			p.gold -= def.gold
			p.wood -= def.wood
			tile.status = "owned"
			start_building(p, tile_key(tile.event, tile, int(p.tiles_region)))
			return _result(true, "Bắt đầu xây %s (%d giây)." % [def.name, roundi(build_time(p, tile.event))])
		"relic":
			var opened := count_owned(p.tiles, "relic")
			var mult := 2 if bonus else 1
			var gold := 80 * mult
			p.gold += gold
			if bonus:
				p.stones += 1
			tile.status = "owned"
			var head := ("Giải được câu đố! Rương mở: +%d vàng, +1 Đá Cường Hoá." % gold) if bonus else ("Phá khoá rương: +%d vàng." % gold)
			# M5-02: EXP theo cấp (cũ: cố định 150).
			return _result(true, "%s %s" % [head, RELIC_LORE[opened % RELIC_LORE.size()]], Formulas.explore_exp(int(p.level)) * 2 * mult)
		"survivor":
			tile.status = "owned"
			return _result(true, "Một người sống sót gia nhập Trại Khai Giới: +10% sản lượng.")
		"wonder":
			tile.status = "owned"
			return _result(true, "Chiếm Suối Linh Khí: +10% EXP từ chiến đấu.")
		"merchant":
			tile.status = "owned"
			return _result(true, "Thương nhân lữ hành dựng lều ở Làng Thanh Thạch trong 1 giờ (phím E khi ở làng).", 60)
		"nest":
			return _result(true, "Quái tinh anh xuất hiện phía trước! Hạ nó để chiếm Ổ quái.", 0, true)
	return _result(false, "Đây đã là trại của bạn.")


static func conquer_tile(p, id: int) -> bool:
	var tile := find_tile(p, id)
	if tile.is_empty() or tile.status == "owned":
		return false
	tile.status = "owned"
	floor_reward(p, tile)
	return true


# ------------------------------------------------------------------ công trình


static func _kind(key: String) -> String:
	for k in ["lumber", "mine", "fishery"]:
		if key.begins_with(k + "_"):
			return k
	return key


static func build_time(p, kind: String) -> float:
	# TP13 Long Đế (Trái Tim Lãnh Chúa + Long Mạch): Long Mạch Đàn xây xong ngay.
	if kind == "dragon" and TalentSlots.has_special(p, "long-de"):
		return 0.0
	return float(BUILDINGS[kind].time) * ((1.0 - TalentSlots.value(p, "trai-tim", 0.25, 0.375)) if TalentSlots.has(p, "trai-tim") else 1.0)


static func start_building(p, key: String) -> void:
	p.buildings[key] = p.build_clock + build_time(p, _kind(key))


static func is_started(p, key: String) -> bool:
	return p.buildings.has(key)


static func is_built(p, key: String) -> bool:
	return p.buildings.has(key) and p.build_clock >= float(p.buildings[key])


static func remaining(p, key: String) -> float:
	if not p.buildings.has(key):
		return 0.0
	return maxf(0.0, float(p.buildings[key]) - p.build_clock)


## Tiến đồng hồ xây; trả về danh sách công trình vừa xong.
static func tick_build_clock(p, seconds: float) -> Array:
	var before: Array = []
	for key in p.buildings:
		if not is_built(p, key):
			before.append(key)
	p.build_clock += seconds
	var done: Array = []
	for key in before:
		if is_built(p, key):
			done.append(key)
	_sync_camp(p)
	return done


## C7-02: cấp trung tâm = cấp nâng cao nhất đã xây xong.
static func _sync_camp(p) -> void:
	var lv := 1
	for k in range(2, 6):
		if is_built(p, "camp%d" % k):
			lv = k
	p.camp_level = maxi(int(p.camp_level), lv)


static func camp_name(p) -> String:
	return "%s · cấp %d" % [CAMP_NAMES[clampi(int(p.camp_level), 1, 5)], int(p.camp_level)]


## Tổng ô đã chiếm mọi vùng (không tính Trại).
static func total_owned(p) -> int:
	var n := 0
	for rg in region_grids(p):
		n += owned_count(rg[1])
	return n


## "2000 vàng · 400 Gỗ · …" theo giá công trình.
static func cost_text(kind: String) -> String:
	var def: Dictionary = BUILDINGS[kind]
	var parts: Array = []
	for ck in COST_KEYS:
		if int(def.get(ck[0], 0)) > 0:
			parts.append("%d %s" % [int(def[ck[0]]), ck[1]])
	return " · ".join(parts)


## Lý do chưa xây được (thiếu cấp trước / ô / tài nguyên); "" nếu được.
static func build_blocker(p, kind: String) -> String:
	var def: Dictionary = BUILDINGS[kind]
	if def.has("needs") and not is_built(p, str(def.needs)):
		return "Cần xây xong %s trước." % BUILDINGS[str(def.needs)].name
	if int(def.get("tiles", 0)) > total_owned(p):
		return "Cần chiếm %d ô (đang %d)." % [int(def.tiles), total_owned(p)]
	for ck in COST_KEYS:
		if float(p.get(ck[0])) < float(def.get(ck[0], 0)):
			return "Cần " + cost_text(kind) + "."
	return ""


static func building_name(key: String) -> String:
	return BUILDINGS[_kind(key)].name


## Trái Tim Lãnh Chúa — Hiệu Triệu: xong ngay công trình đang xây còn lâu nhất.
static func finish_now(p) -> String:
	var best := ""
	var best_left := 0.0
	for key in p.buildings:
		var left := remaining(p, key)
		if left > best_left:
			best_left = left
			best = key
	if best != "":
		p.buildings[best] = p.build_clock
		_sync_camp(p)
	return best


## Xây Đền Thiên Phú / Long Mạch Đàn / nâng Thôn.
static func build(p, kind: String) -> Dictionary:
	if is_started(p, kind):
		return _result(false, "%s đã xây hoặc đang xây." % BUILDINGS[kind].name)
	if kind == "dragon" and not TalentSlots.has(p, "long-mach"):
		return _result(false, "Chỉ người mang Thiên phú Long Mạch mới xây được Long Mạch Đàn.")
	var def: Dictionary = BUILDINGS[kind]
	var block := build_blocker(p, kind)
	if block != "":
		return _result(false, block)
	if kind.begins_with("rebuild"):
		if str(p.ending) != "hien-te":
			return _result(false, "Tái Thiết Lục Địa mở sau kết thúc Hiến tế.")
		if int(p.void_cores) < int(def.get("cores", 0)):
			return _result(false, "Cần %d Lõi Hư Vô." % int(def.cores))
		p.void_cores = int(p.void_cores) - int(def.get("cores", 0))
	for ck in COST_KEYS:
		var cost := float(def.get(ck[0], 0))
		if cost > 0.0:
			p.set(ck[0], float(p.get(ck[0])) - cost)
	start_building(p, kind)
	return _result(true, "Bắt đầu xây %s (%d giây)." % [def.name, roundi(build_time(p, kind))])


static func upgrade_camp(p) -> Dictionary:
	return build(p, "camp2")


# ------------------------------------------------------------------ sản lượng


## Sản lượng cộng mọi vùng (M4.3): Xưởng Gỗ vùng 1 vẫn chạy khi đang ở vùng 2.
static func production_per_minute(p) -> Dictionary:
	var lumber := count_built(p, "lumber")
	var mines := count_built(p, "mine")
	# M8 (C5-03), M9 (C6-03): Mỏ vùng 5–6 là Mỏ Tinh Thạch (+1/phút), không cho Đá/Sắt; đột kích thua thì ngừng 30 phút.
	var crystal_mines := 0
	for key in p.buildings:
		if (str(key).begins_with("mine_r5_") or str(key).begins_with("mine_r6_") or str(key).begins_with("mine_r7_")) and is_built(p, str(key)):
			crystal_mines += 1
	mines -= crystal_mines
	if float(p.get("build_clock")) < float(p.get("raid_penalty_until")):
		crystal_mines = 0
	var survivors := 0
	for rg in region_grids(p):
		survivors += count_owned(rg[1], "survivor")
	# C7-02: Thôn +20%, Trấn +30%, Thành +40%, Hoàng Thành +50%.
	var mult: float = 1.0 + 0.1 * survivors + float(CAMP_BONUS[clampi(int(p.camp_level), 1, 5)])
	if TalentSlots.has(p, "thien-menh"):
		mult += TalentSlots.value(p, "thien-menh", 0.2, 0.3)
	if TalentSlots.has_group_sub(p, "territory", 1):
		mult += 0.1
	# C9-50 / C9-46 (M12): Điểm Thiên Đạo nhánh lãnh địa +1%/điểm; kết thúc Hiến tế +30% (Endgame.territory_bonus).
	mult += int(p.divine_points.get("terr", 0)) * 0.01 + (0.3 if str(p.ending) == "hien-te" else 0.0)
	return {"gold": lumber * 3.0 * mult, "wood": lumber * 6.0 * mult, "ore": mines * 4.0 * mult, "iron": mines * 2.0 * mult,
		"crystal": crystal_mines * 1.0 * mult}


static func tick_production(p, seconds: float) -> Dictionary:
	var rate := production_per_minute(p)
	var gold: float = rate.gold * seconds / 60.0
	var wood: float = rate.wood * seconds / 60.0
	p.gold += gold
	p.wood += wood
	var ore: float = rate.ore * seconds / 60.0
	var iron: float = rate.iron * seconds / 60.0
	p.ore += ore
	p.iron += iron
	var crystal: float = rate.crystal * seconds / 60.0
	p.crystal += crystal
	return {"gold": gold, "wood": wood, "ore": ore, "iron": iron, "crystal": crystal}


## KP-06: Bến Cá +3% HP tối đa mỗi cái, tối đa +15% (Q26).
static func fishery_hp_pct(p) -> float:
	return minf(0.15, 0.03 * count_built(p, "fishery"))


## NV-24: EXP offline — mỗi công trình sản xuất (Xưởng Gỗ, Mỏ) cho 1 × cấp EXP mỗi phút (Q42).
static func offline_exp_per_minute(p) -> float:
	return float(count_built(p, "lumber") + count_built(p, "mine")) * float(p.level)


## C1-31: Vườn Thảo Dược; trả về số thảo dược vừa sinh.
static func tick_garden(p, seconds: float) -> int:
	if not is_built(p, "garden"):
		p.herb_timer = 0.0
		return 0
	p.herb_timer += seconds
	var n := int(floor(p.herb_timer / GARDEN_PERIOD))
	p.herb_timer -= n * GARDEN_PERIOD
	p.herbs = mini(HERB_CAP, int(p.herbs) + n)
	return n


## Lãnh địa cấp 10: thu hoạch offline tối đa 16 giờ.
static func offline_cap(p) -> float:
	return 16.0 * 3600.0 if TalentSlots.has_group_sub(p, "territory", 2) else Config.OFFLINE_CAP_SEC


## Hồi Đuốc theo thời gian; trả về số Đuốc vừa hồi.
static func regen_torches(p, seconds: float) -> int:
	var cap := torch_max(p)
	if p.torches >= cap:
		p.torch_timer = 0.0
		return 0
	var period := torch_regen_sec(p)
	p.torch_timer += seconds
	var gained := mini(cap - int(p.torches), int(floor(p.torch_timer / period)))
	p.torches += gained
	if p.torches >= cap:
		p.torch_timer = 0.0
	else:
		p.torch_timer -= gained * period
	return gained
