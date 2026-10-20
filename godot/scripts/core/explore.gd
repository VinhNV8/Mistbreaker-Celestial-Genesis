extends RefCounted
## Lưới khai phá lục giác, sự kiện ô đất, công trình và sản lượng lãnh địa.
## Mỗi ô là Dictionary {id, q, r, event, status}; status: "fog" | "revealed" | "owned".
## Các hàm nhận `p` là Profile (không khai báo kiểu để tránh preload vòng tròn).

const Config = preload("res://scripts/core/config.gd")
const RngUtil = preload("res://scripts/core/rng_util.gd")
const Talents = preload("res://scripts/data/talents.gd")

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
}

## Lưới 10 ô của prototype: vòng 1 (6 ô) + 4 ô vòng 2, quanh Trại Khai Giới.
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
}


static func create_tiles(rng: Callable) -> Array:
	var tiles: Array = [{"id": 0, "q": 0, "r": 0, "event": "camp", "status": "owned"}]
	var ring1 := RngUtil.shuffle(RING1_EVENTS, rng)
	var ring2 := RngUtil.shuffle(RING2_EVENTS, rng)
	for i in RING1.size():
		tiles.append({"id": tiles.size(), "q": RING1[i][0], "r": RING1[i][1], "event": ring1[i], "status": "fog"})
	for i in RING2.size():
		tiles.append({"id": tiles.size(), "q": RING2[i][0], "r": RING2[i][1], "event": ring2[i], "status": "fog"})
	return tiles


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


# ------------------------------------------------------------------ Đuốc


## Khai phá cấp 5: +1 Đuốc tối đa.
static func torch_max(p) -> int:
	return Config.TORCH_MAX + (1 if Talents.has_sub(p.talent, p.talent_level, "explore", 1) else 0)


## Khai phá cấp 10: Đuốc hồi nhanh hơn 20%.
static func torch_regen_sec(p) -> float:
	return Config.TORCH_REGEN_SEC * (0.8 if Talents.has_sub(p.talent, p.talent_level, "explore", 2) else 1.0)


## Lý do không thể dùng Đuốc lên ô này, hoặc chuỗi rỗng nếu được phép.
static func reveal_blocker(p, tile: Dictionary) -> String:
	if tile.status != "fog":
		return "Ô đất đã được dọn sương."
	if distance_to_owned(p.tiles, tile) > 1:
		return "Chỉ dọn được ô kề lãnh địa."
	if p.torches <= 0:
		return "Hết Đuốc Khai Giới — đợi hồi hoặc hạ quái tinh anh."
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
	if p.talent == "thien-menh":
		var extra := 0
		for t in p.tiles:
			if extra >= 2:
				break
			if t.status == "fog" and hex_distance(t, tile) == 1:
				t.status = "revealed"
				names.append(EVENT_INFO[t.event].name)
				extra += 1
	var exp_gain: int = 40 * int(p.level) * names.size()
	return _result(true, "Sương mù tan: phát hiện %s." % ", ".join(names), exp_gain)


static func claim_tile(p, id: int) -> Dictionary:
	var tile := find_tile(p, id)
	if tile.is_empty() or tile.status != "revealed":
		return _result(false, "Ô đất này chưa thể chiếm.")
	match tile.event:
		"resource":
			if p.gold < Config.LUMBER_COST_GOLD:
				return _result(false, "Cần %d vàng để xây Xưởng Gỗ." % Config.LUMBER_COST_GOLD)
			p.gold -= Config.LUMBER_COST_GOLD
			tile.status = "owned"
			start_building(p, "lumber_%d" % int(tile.id))
			return _result(true, "Bắt đầu xây Xưởng Gỗ (%d giây)." % roundi(build_time(p, "lumber")))
		"relic":
			var opened := count_owned(p.tiles, "relic")
			p.gold += 80
			tile.status = "owned"
			return _result(true, "Mở rương: +80 vàng. %s" % RELIC_LORE[opened % RELIC_LORE.size()], 150)
		"survivor":
			tile.status = "owned"
			return _result(true, "Một người sống sót gia nhập Trại Khai Giới: +10% sản lượng.")
		"wonder":
			tile.status = "owned"
			return _result(true, "Chiếm Suối Linh Khí: +10% EXP từ chiến đấu.")
		"nest":
			return _result(true, "Quái tinh anh xuất hiện phía trước! Hạ nó để chiếm Ổ quái.", 0, true)
	return _result(false, "Đây đã là trại của bạn.")


static func conquer_tile(p, id: int) -> bool:
	var tile := find_tile(p, id)
	if tile.is_empty() or tile.status == "owned":
		return false
	tile.status = "owned"
	return true


# ------------------------------------------------------------------ công trình


static func _kind(key: String) -> String:
	return "lumber" if key.begins_with("lumber_") else key


static func build_time(p, kind: String) -> float:
	return float(BUILDINGS[kind].time) * ((1.0 - Talents.lv_value(0.25, 0.375, p.talent_level)) if p.talent == "trai-tim" else 1.0)


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
	if is_built(p, "camp2"):
		p.camp_level = 2
	return done


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
		if best == "camp2":
			p.camp_level = 2
	return best


## Xây Đền Thiên Phú / Long Mạch Đàn / nâng Thôn.
static func build(p, kind: String) -> Dictionary:
	if is_started(p, kind):
		return _result(false, "%s đã xây hoặc đang xây." % BUILDINGS[kind].name)
	if kind == "dragon" and p.talent != "long-mach":
		return _result(false, "Chỉ người mang Thiên phú Long Mạch mới xây được Long Mạch Đàn.")
	var def: Dictionary = BUILDINGS[kind]
	if p.gold < def.gold or p.wood < def.wood:
		return _result(false, "Cần %d vàng và %d gỗ." % [def.gold, def.wood])
	p.gold -= def.gold
	p.wood -= def.wood
	start_building(p, kind)
	return _result(true, "Bắt đầu xây %s (%d giây)." % [def.name, roundi(build_time(p, kind))])


static func upgrade_camp(p) -> Dictionary:
	return build(p, "camp2")


# ------------------------------------------------------------------ sản lượng


static func production_per_minute(p) -> Dictionary:
	var lumber := 0
	for t in p.tiles:
		if t.event == "resource" and t.status == "owned" and is_built(p, "lumber_%d" % int(t.id)):
			lumber += 1
	var survivors := count_owned(p.tiles, "survivor")
	var mult := 1.0 + 0.1 * survivors + (0.2 if is_built(p, "camp2") else 0.0)
	if p.talent == "thien-menh":
		mult += Talents.lv_value(0.2, 0.3, p.talent_level)
	if Talents.has_sub(p.talent, p.talent_level, "territory", 1):
		mult += 0.1
	return {"gold": lumber * 3.0 * mult, "wood": lumber * 6.0 * mult}


static func tick_production(p, seconds: float) -> Dictionary:
	var rate := production_per_minute(p)
	var gold: float = rate.gold * seconds / 60.0
	var wood: float = rate.wood * seconds / 60.0
	p.gold += gold
	p.wood += wood
	return {"gold": gold, "wood": wood}


## Lãnh địa cấp 10: thu hoạch offline tối đa 16 giờ.
static func offline_cap(p) -> float:
	return 16.0 * 3600.0 if Talents.has_sub(p.talent, p.talent_level, "territory", 2) else Config.OFFLINE_CAP_SEC


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
