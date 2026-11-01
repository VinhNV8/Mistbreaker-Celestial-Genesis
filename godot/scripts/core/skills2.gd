extends RefCounted
## SK2 (docs/13 mục 4): 12 kỹ năng mới (cấp 15/22 + chuyển chức 1) và biến thể kỹ năng 3 tầng.
## GameWorld chỉ gọi: cast (kỹ năng mới), tick, source / crit_bonus / hit_mult / def_mult / after_hit (khi trúng đòn),
## cost_mult (MP, hồi chiêu), after_cast (kỹ năng hỗ trợ). Trạng thái riêng ở `w.sk2` (State).

const Classes = preload("res://scripts/data/classes.gd")
const Monsters = preload("res://scripts/data/monsters.gd")
const Formulas = preload("res://scripts/core/formulas.gd")
const Classes2 = preload("res://scripts/core/classes2.gd")

# ---------------------------------------------------------------- biến thể (docs/13 mục 4.3, 4.4)
## Tầng mở ở cấp kỹ năng 4 / 7 / 10.
const TIER_LEVELS := [4, 7, 10]
const ELEMENTS := ["hoa", "thuy", "moc", "kim", "tho"]
const ELEMENT_NAMES := {"hoa": "Hỏa", "thuy": "Thủy", "moc": "Mộc", "kim": "Kim", "tho": "Thổ"}
## [id, tên, mô tả]
## Lựa chọn ✦ có cờ "book" (SK3): BK (docs/29) mở bằng STAR_COST Điểm Kỹ Năng (secret_books).
const TIER_DAMAGE := [
	[["mp", "Tiết Kiệm", "−20% MP"], ["cd", "Thần Tốc", "−15% hồi chiêu"], ["song", "Song Phát", "✦ 25% hồi chiêu ngay sau khi dùng", "book"]],
	[["hoa", "Hỏa", "Thiêu đốt 3 giây (15% Tấn công/giây)"], ["thuy", "Thủy", "Làm chậm 2 giây"],
		["moc", "Mộc", "Hút máu 4% sát thương"], ["kim", "Kim", "Bỏ qua 25% Phòng thủ"], ["tho", "Thổ", "+50% vào thanh Phá Thế"],
		["amduong", "Âm Dương", "✦ luôn đổi sang hệ khắc quái trúng (+30%)", "book"]],
	[["dmg", "Bạo Lực", "+25% sát thương"], ["crit", "Chí Mạng", "+20% tỉ lệ chí mạng"], ["vosong", "Vô Song", "✦ +40% sát thương lên boss và tinh anh", "book"]],
]
const TIER_UTILITY := [
	[["mp", "Tiết Kiệm", "−20% MP"], ["cd", "Thần Tốc", "−15% hồi chiêu"], ["song", "Song Phát", "✦ 25% hồi chiêu ngay sau khi dùng", "book"]],
	[["long", "Bền Bỉ", "Hiệu lực dài thêm 30%"], ["heal", "Hồi Phục", "Dùng kỹ năng hồi 10% HP"], ["thanhtam", "Thanh Tâm", "✦ dùng kỹ năng hồi 20% MP", "book"]],
	[["cd2", "Tinh Thông", "−20% hồi chiêu"], ["mp0", "Vô Ngã", "Không tốn MP"], ["kienco", "Kiên Cố", "✦ 2 giây giảm 50% sát thương nhận vào", "book"]],
]
const SONG_CHANCE := 0.25
const VOSONG := 0.4
const THANHTAM := 0.2
const KIENCO_TIME := 2.0
## BK (docs/29): Bí Kíp rơi = +1 Điểm Kỹ Năng — tinh anh 5%, boss vùng 40%, Chúa Hang 25%, boss hiếm 100%,
## ô Di tích giải câu đố 30%. Biến thể ✦ (lựa chọn có cờ "book") mở bằng STAR_COST Điểm Kỹ Năng, lưu ở secret_books.
const BOOK_ELITE := 0.05
const BOOK_BOSS := 0.4
const BOOK_CAVE := 0.25
const BOOK_RELIC := 0.3
const STAR_COST := 2
## Save cũ (< v22): 5 Mảnh Bí Kíp = 1 Bí Kíp = 1 điểm (làm tròn lên).
const SHARDS_PER_POINT := 5
const TIER_NAMES := ["I", "II", "III"]
const COUNTER_BONUS := 1.3
const BURN_TIME := 3.0
const BURN_MUL := 0.15
const SLOW_TIME := 2.0
const LEECH := 0.04
const KIM_DEF := 0.75
const THO_POISE := 0.5
const DMG_BONUS := 0.25
const CRIT_BONUS := 0.2
const LONG_MUL := 1.3
const HEAL_PCT := 0.1

# ---------------------------------------------------------------- kỹ năng mới
const LT_STRIKES := 3
const LT_GAP := 0.2
const LT_RANGE := 70.0
const LT_ARC := deg_to_rad(45.0)
const HK_R := 80.0
const HK_STUN := 1.2
const KV_TICKS := 8
const KV_GAP := 0.25
const KV_R := 100.0
const PK_SPREAD := deg_to_rad(15.0)
const TN_RANGE := 380.0
const TN_HOP := 150.0
const TN_JUMPS := 4
## Không còn quái khác để nảy: mũi tên dội lại chính mục tiêu, ×0,35 mỗi lần (đánh boss đơn lẻ vẫn có ích).
const TN_ECHO := 0.35
const LB_SPREAD := deg_to_rad(12.0)
const LX_SHOTS := 8
const LX_GAP := 0.18
const TD_STACKS := 3
const TD_TIME := 4.0
const HT_RANGE := 250.0
const HT_LEN := 120.0
const HT_THICK := 30.0
const HT_TIME := 4.0
const HT_TICK := 0.5
const DC_DIST := 150.0
const DC_R := 60.0
const MB_RANGE := 300.0
const MB_R := 90.0
const MB_TICKS := 5
const MB_GAP := 0.4
const CS_SPEED := 105.0
const CS_TIME := 2.4
const CS_ZAP_R := 80.0
const CS_ZAP_GAP := 0.3
const CS_END_R := 70.0
const CS_END_MUL := 3.0
const VK_TICKS := 12
const VK_GAP := 0.25
const VK_R := 150.0
const TT_R := 200.0
const TT_TICKS := 10
const TH_COUNT := 5
const TH_SPREAD := 120.0
const KVU_R := 100.0
const KVU_TICKS := 8
const HB_COST := 0.1
const HB_R := 90.0
const HB_LEECH := 0.2
const HA_DASHES := 2
const HA_GAP := 0.35
const PK_RANGE := 700.0
# CL1 (docs/21): Kiếm Ý, Nguyệt Ảnh Liên Trảm, Lộn Nhào, Xuyên Tâm Tiễn, Băng Lao, Thiên Tai Nguyên Tố
const KY_TIME := 8.0
const KY_CRIT := 0.2
const KY_SPEED := 0.15
const CRIT_CAP := 0.6
const NA_REACH := 150.0
const LN_TIME := 3.0
const LN_EVASION := 0.5
const LN_CAP := 0.6
const XT_MAX_HITS := 3
const BL_RANGE := 400.0
const BL_SLOW := 3.0
## Băng Lao làm chậm 50% (quái còn 50% tốc chạy).
const BL_SLOW_MUL := 0.5
## Thiên Tai Nguyên Tố: hệ từng đợt — thiên thạch Hỏa, băng Thủy, sét Kim.
const TTN_ELEMENTS := ["hoa", "thuy", "kim"]
const TTN_FIRE_R := 120.0
const TTN_FIRE := 4.0
const TTN_ICE := 3.0
const TTN_BOLT := 3.0
const TTN_GAP := 0.7
const TTN_JUMPS := 4
## Kỹ năng thay thế ô cũ: điểm / biến thể / Bí Kíp của id cũ chuyển sang id mới khi tải save cũ.
const REPLACED := {"kiemy": "guard", "banglao": "dichchuyen"}
const TL_SHOTS := 3
const TL_GAP := 0.15
const BM_MINES := 5
const BM_R := 70.0
const LB_R := 80.0
const LB_ROOT := 3.0
const TLO_RANGE := 400.0
const TLO_TARGETS := 6
const BP_R := 140.0
const BP_ROOT := 3.0
const TH_BONES := 3
const TH_BONE_TTL := 15.0
const KD_R := 100.0
const KD_TICKS := 10
const KD_GAP := 0.5
## Mũi tên / đạn của kỹ năng → id kỹ năng khi trúng (GameWorld.hit_source).
const SOURCE_SKILL := {"meteor": "meteor", "nova": "nova"}


class State:
	## [{t, skill, kind, mul, n}] — đòn trễ (Liên Trảm, Kiếm Vũ, Liên Xạ)
	var queue: Array = []
	## [{a, b, ttl, acc, mul, skill}] — Hoả Tường
	var walls: Array = []
	## [{pos, r, ticks, timer, mul, skill}] — Mưa Băng
	var ice: Array = []
	## [{pos, vel, ttl, zap, mul, skill}] — Cầu Sấm
	var orbs: Array = []
	## CL1: thời gian còn lại của Kiếm Ý / Lộn Nhào (giây)
	var kiemy_t := 0.0
	var lonnhao_t := 0.0
	## CL1: hệ của đợt Thiên Tai Nguyên Tố đang đánh ("" = Hỏa, đợt thiên thạch)
	var wave_el := ""


static func is_utility(sk: Dictionary) -> bool:
	return float(sk.get("mul", 0.0)) <= 0.0


static func tiers_for(sk: Dictionary) -> Array:
	return TIER_UTILITY if is_utility(sk) else TIER_DAMAGE


# ================================================================ biến thể


static func variant(w, id: String, tier: int) -> String:
	var v: Array = w.profile.variants.get(id, [])
	if tier >= v.size():
		return ""
	# Chỉ có hiệu lực khi kỹ năng đã đạt cấp mở tầng.
	return str(v[tier]) if w.skill_level(id) >= TIER_LEVELS[tier] else ""


static func element_of(w, id: String) -> String:
	# CL1 Thiên Tai Nguyên Tố: mỗi đợt mang hệ riêng (thiên thạch = Hỏa; băng, sét đặt tạm wave_el lúc đánh).
	if id == "thienhoa":
		return w.sk2.wave_el if w.sk2.wave_el != "" else TTN_ELEMENTS[0]
	var el := variant(w, id, 1)
	return el if el in ELEMENTS else ""


## Biến thể ✦ của kỹ năng id ở tầng tier đã mở chưa (secret_books, tên trường giữ từ SK3).
static func has_book(w, id: String, tier: int) -> bool:
	var b: Array = w.profile.secret_books.get(id, [])
	return tier < b.size() and bool(b[tier])


## Lựa chọn ✦ của kỹ năng sk ở tầng tier: [id, tên, mô tả, "book"].
static func star_of(sk: Dictionary, tier: int) -> Array:
	return tiers_for(sk)[tier].filter(func(o): return o.size() > 3)[0]


## Lý do chưa mở được ✦ ("" = mở được).
static func can_unlock_star(w, id: String, tier: int) -> String:
	var sk: Dictionary = Classes.skill_by_id(w.profile.class_id, id)
	if sk.is_empty() or tier < 0 or tier > 2:
		return "Không có biến thể này."
	if has_book(w, id, tier):
		return "Đã mở."
	if not w.skill_unlocked(sk) or w.skill_level(id) < TIER_LEVELS[tier]:
		return "%s cần cấp %d để mở tầng %s." % [sk.name, TIER_LEVELS[tier], TIER_NAMES[tier]]
	if int(w.profile.skill_points) < STAR_COST:
		return "Cần %d Điểm Kỹ Năng (còn %d). Nhặt Bí Kíp hoặc lên cấp để có thêm." % [STAR_COST, int(w.profile.skill_points)]
	return ""


## BK: mở biến thể ✦ bằng STAR_COST Điểm Kỹ Năng (mở ở mọi nơi; chọn biến thể vẫn ở vùng an toàn).
static func unlock_star(w, id: String, tier: int) -> Dictionary:
	var why := can_unlock_star(w, id, tier)
	if why != "":
		return _res(w, false, why)
	var sk: Dictionary = Classes.skill_by_id(w.profile.class_id, id)
	w.profile.skill_points = int(w.profile.skill_points) - STAR_COST
	var b: Array = w.profile.secret_books.get(id, [false, false, false]).duplicate()
	while b.size() < 3:
		b.append(false)
	b[tier] = true
	w.profile.secret_books[id] = b
	return _res(w, true, "Mở biến thể ✦ %s của %s (−%d Điểm Kỹ Năng)." % [star_of(sk, tier)[1], sk.name, STAR_COST])


## Tẩy điểm: khoá lại mọi ✦, bỏ chọn ✦ đang dùng; trả về số điểm hoàn.
static func reset_stars(p) -> int:
	var n := 0
	for id in p.secret_books:
		for got in p.secret_books[id]:
			if bool(got):
				n += 1
	p.secret_books = {}
	for id in p.variants:
		var v: Array = p.variants[id]
		for t in v.size():
			if str(v[t]) in STAR_IDS:
				v[t] = ""
	return n * STAR_COST


## Id các lựa chọn ✦ (để bỏ chọn khi khoá lại).
const STAR_IDS := ["song", "amduong", "vosong", "thanhtam", "kienco"]


## BK: nhặt Bí Kíp = +1 Điểm Kỹ Năng.
static func drop_book(w) -> void:
	w.profile.skill_points = int(w.profile.skill_points) + 1
	w._pickup_note("book", "✦ +%d Điểm Kỹ Năng", 1.0, Color("#ffc940"), true)
	w._message("Nhặt Bí Kíp: +1 Điểm Kỹ Năng (bảng Kỹ năng, phím U).", "good")
	w._sfx("pickup_item")


## Rơi Bí Kíp khi hạ quái (GameWorld._kill_enemy).
static func on_kill(w, e) -> void:
	# C9-52: Đèn Tinh Quang Vĩnh Cửu (Tái Thiết vùng 8) +10% tỉ lệ rơi Bí Kíp.
	var k: float = w.Endgame.book_mult(w.profile)
	if e.role == "rare":
		drop_book(w)
	elif e.role == "boss":
		if w._r() < BOOK_BOSS * k:
			drop_book(w)
	elif "cave_boss" in e and bool(e.get("cave_boss")):
		if w._r() < BOOK_CAVE * k:
			drop_book(w)
	elif e.elite and w._r() < BOOK_ELITE * k:
		drop_book(w)


## Giải câu đố ô Di tích.
static func on_relic(w) -> void:
	if w._r() < BOOK_RELIC:
		drop_book(w)


## Đổi biến thể chỉ ở vùng an toàn (như đổi ô kỹ năng).
static func set_variant(w, id: String, tier: int, opt: String) -> Dictionary:
	var sk: Dictionary = Classes.skill_by_id(w.profile.class_id, id)
	if sk.is_empty() or tier < 0 or tier > 2:
		return {"ok": false, "message": "Không có biến thể này."}
	if not w.in_safe_zone():
		return _res(w, false, "Đổi biến thể ở vùng an toàn (làng, trại, thành).")
	if w.skill_level(id) < TIER_LEVELS[tier]:
		return _res(w, false, "%s cần cấp %d để mở tầng %d." % [sk.name, TIER_LEVELS[tier], tier + 1])
	var ok := false
	var name := ""
	var book := false
	for o in tiers_for(sk)[tier]:
		if o[0] == opt:
			ok = true
			name = str(o[1])
			book = o.size() > 3
	if not ok:
		return _res(w, false, "Biến thể không hợp lệ.")
	if book and not has_book(w, id, tier):
		return _res(w, false, "%s chưa mở — cần %d Điểm Kỹ Năng." % [name, STAR_COST])
	var v: Array = w.profile.variants.get(id, ["", "", ""]).duplicate()
	while v.size() < 3:
		v.append("")
	v[tier] = opt
	w.profile.variants[id] = v
	return _res(w, true, "%s · tầng %d: %s." % [sk.name, tier + 1, name])


static func _res(w, ok: bool, msg: String) -> Dictionary:
	w._message(msg, "good" if ok else "bad")
	return {"ok": ok, "message": msg}


## Nhân MP ("mp") / hồi chiêu ("cd") theo biến thể.
static func cost_mult(w, id: String, what: String) -> float:
	var t1 := variant(w, id, 0)
	var t3 := variant(w, id, 2)
	if what == "mp":
		if t3 == "mp0":
			return 0.0
		return 0.8 if t1 == "mp" else 1.0
	var k := 0.85 if t1 == "cd" else 1.0
	return k * (0.8 if t3 == "cd2" else 1.0)


## Sau khi dùng kỹ năng ở ô slot: Song Phát (mọi kỹ năng); kỹ năng hỗ trợ: kéo dài / hồi máu / hồi MP / Kiên Cố.
static func after_cast(w, id: String, slot := -1) -> void:
	var p = w.player
	if slot >= 0 and variant(w, id, 0) == "song" and w._r() < SONG_CHANCE:
		p.skill_cds[slot] = 0.0
		w._text(p.pos + Vector2(0, -52), "Song Phát!", Color("#ffc940"), true)
	var sk: Dictionary = Classes.skill_by_id(w.profile.class_id, id)
	if sk.is_empty() or not is_utility(sk):
		return
	match variant(w, id, 1):
		"long":
			p.guard_time *= LONG_MUL
			p.eagle_time *= LONG_MUL
			p.shield_time *= LONG_MUL
			if id == "kiemy":
				w.sk2.kiemy_t *= LONG_MUL
		"heal":
			p.hp = minf(float(w.stats.max_hp), p.hp + float(w.stats.max_hp) * HEAL_PCT)
		"thanhtam":
			p.mp = minf(float(w.stats.max_mp), p.mp + float(w.stats.max_mp) * THANHTAM)
	if variant(w, id, 2) == "kienco":
		p.guard_time = maxf(p.guard_time, KIENCO_TIME)


# ================================================================ khi trúng đòn


## Kỹ năng gây ra đòn đang tính (GameWorld.skill_ctx hoặc hit_source của đạn/thiên thạch).
static func source(w) -> String:
	if str(w.skill_ctx) != "":
		return str(w.skill_ctx)
	return str(SOURCE_SKILL.get(str(w.hit_source), ""))


static func crit_bonus(w, id: String) -> float:
	var b := CRIT_BONUS if id != "" and variant(w, id, 2) == "crit" else 0.0
	# CL1 Kiếm Ý: +20% chí mạng cho mọi đòn, không vượt trần 60%.
	if w.sk2.kiemy_t > 0.0:
		b += clampf(CRIT_CAP - float(w.stats.crit), 0.0, KY_CRIT)
	return b


## CL1 Kiếm Ý: hệ số tốc đánh.
static func speed_mult(w) -> float:
	return 1.0 + KY_SPEED if w.sk2.kiemy_t > 0.0 else 1.0


## CL1 Lộn Nhào: né tránh hiệu lực (+50% trong 3 giây, trần 60%).
static func evasion_of(w) -> float:
	var ev := float(w.stats.evasion)
	if w.sk2.lonnhao_t > 0.0:
		ev = minf(LN_CAP, ev + LN_EVASION)
	return ev


## CL1: save cũ còn điểm / biến thể / Bí Kíp của kỹ năng đã bị thay (Thiết Bích, Dịch Chuyển) → chuyển sang kỹ năng mới cùng ô.
static func migrate_replaced(p) -> void:
	for new_id in REPLACED:
		var old: String = REPLACED[new_id]
		if Classes.skill_by_id(str(p.class_id), new_id).is_empty():
			continue
		for dict_name in ["skill_levels", "variants", "secret_books"]:
			var d: Dictionary = p.get(dict_name)
			if d.has(old):
				if not d.has(new_id):
					d[new_id] = d[old]
				d.erase(old)


static func hit_mult(w, e, id: String) -> float:
	if id == "":
		return 1.0
	var k := 1.0 + (DMG_BONUS if variant(w, id, 2) == "dmg" else 0.0)
	if variant(w, id, 2) == "vosong" and (e.elite or e.role in ["boss", "rare"]):
		k *= 1.0 + VOSONG
	var el := element_of(w, id)
	if variant(w, id, 1) == "amduong" and w.el_of(e) != "":
		k *= COUNTER_BONUS
	elif el != "" and Monsters.counters(el, w.el_of(e)):
		k *= COUNTER_BONUS
	return k


static func def_mult(w, id: String) -> float:
	return KIM_DEF if id != "" and element_of(w, id) == "kim" else 1.0


static func after_hit(w, e, id: String, dmg: int) -> void:
	if id == "" or e.dead:
		return
	if id == "huyetbao":
		w.player.hp = minf(float(w.stats.max_hp), w.player.hp + dmg * HB_LEECH)
	if id == "banglao":
		e.slow_t = maxf(e.slow_t, BL_SLOW)
		e.slow_mul = BL_SLOW_MUL
	if id == "tendoc" or id == "khidoc":
		e.venom_stacks = mini(TD_STACKS, e.venom_stacks + 1)
		if e.venom_timer <= 0.0:
			e.venom_tick = 0.0
		e.venom_timer = TD_TIME
	match element_of(w, id):
		"hoa":
			if e.bleed_timer <= 0.0:
				e.bleed_tick = 0.0
			e.bleed_timer = maxf(e.bleed_timer, BURN_TIME)
			e.bleed_dmg = maxf(e.bleed_dmg, Formulas.compute_damage(w.stats.atk, e.def, BURN_MUL))
		"thuy":
			e.slow_t = maxf(e.slow_t, SLOW_TIME)
		"moc":
			w.player.hp = minf(float(w.stats.max_hp), w.player.hp + dmg * LEECH)
		"tho":
			if e.max_poise > 0.0:
				w._damage_poise(e, dmg * THO_POISE)


# ================================================================ kỹ năng mới


## Thi triển kỹ năng SK2. true = đã xử lý.
static func cast(w, id: String, mul: float) -> bool:
	var p = w.player
	match id:
		"lientram":
			# CL1 Nguyệt Ảnh Liên Trảm: lướt tới quái gần nhất trong 15 m, rồi 3 nhát.
			var tg = w._nearest_enemy(p.pos, NA_REACH)
			if tg != null:
				var from: Vector2 = p.pos
				var to_t: Vector2 = tg.pos - p.pos
				var gap: float = tg.radius + w.PLAYER_RADIUS + 6.0
				if to_t.length() > gap:
					p.pos = tg.pos - to_t.normalized() * gap
					w._enforce_gate()
					w._enforce_arena_lock()
					w._blast(from.lerp(p.pos, 0.5), 30.0, Color("#c8b0ff"))
				p.facing = (tg.pos - p.pos).angle()
			for k in LT_STRIKES:
				w.sk2.queue.append({"t": 0.05 + LT_GAP * k, "skill": id, "kind": "cone", "mul": mul})
			p.swing = LT_GAP * LT_STRIKES
			p.swing_kind = "slash"
		"hongkiem":
			w._blast(p.pos, HK_R, Color("#ffd76a"))
			w._sfx("boss_roar")
			for e in w.enemies:
				if e.dead or e.pos.distance_to(p.pos) > HK_R + e.radius:
					continue
				w._hit_enemy(e, mul, false, true)
				if e.dead:
					continue
				if e.role in ["boss", "rare"] or e.elite:
					w._damage_poise(e, Formulas.compute_damage(w.stats.atk, e.def, mul))
				elif e.state != "stunned":
					e.state = "stunned"
					e.timer = HK_STUN
			p.swing = 0.3
			p.swing_kind = "spin"
		"kiemvu":
			for k in KV_TICKS:
				w.sk2.queue.append({"t": KV_GAP * k, "skill": id, "kind": "whirl", "mul": mul})
			p.swing = KV_GAP * KV_TICKS
			p.swing_kind = "spin"
		"phikiem":
			w._auto_face(w.WAVE_RANGE, deg_to_rad(20.0))
			var keep: float = p.facing
			for k in [-1, 0, 1]:
				p.facing = keep + k * PK_SPREAD
				w._fire(w.WAVE_SPEED, w.WAVE_RANGE, mul, true, "wave", false, 18.0)
			p.facing = keep
			p.swing = 0.16
			p.swing_kind = "slash"
		"tennay":
			_bounce(w, id, mul)
			p.swing = 0.16
			p.swing_kind = "shot"
		"lanban":
			var dir: Vector2 = (w._aim - p.pos).normalized() if w._aim.distance_to(p.pos) > 1.0 else Vector2.from_angle(p.facing)
			p.facing = dir.angle()
			var keep2: float = p.facing
			for k in [-1, 0, 1]:
				p.facing = keep2 + k * LB_SPREAD
				w._fire(w.SHOT_SPEED, w.SHOT_RANGE, mul, false, "arrow")
			p.facing = keep2
			p.dodge_dir = -dir
			p.dodge_time = w.DODGE_TIME
			p.perfect_used = false
			# CL1 Lộn Nhào: +50% né tránh trong 3 giây sau khi lộn.
			w.sk2.lonnhao_t = w.DODGE_TIME + LN_TIME
			p.swing = 0.16
			p.swing_kind = "shot"
		"lienxa":
			for k in LX_SHOTS:
				w.sk2.queue.append({"t": LX_GAP * k, "skill": id, "kind": "volley", "mul": mul})
		"tendoc":
			w._soft_lock(w.PIERCE_RANGE)
			w._fire(w.PIERCE_SPEED, w.PIERCE_RANGE, mul, true, "pierce", false, 12.0)
			p.swing = 0.16
			p.swing_kind = "shot"
		"hoatuong":
			var c: Vector2 = p.pos + (w._aim - p.pos).limit_length(HT_RANGE)
			var fwd: Vector2 = (c - p.pos).normalized() if c.distance_to(p.pos) > 1.0 else Vector2.from_angle(p.facing)
			var side: Vector2 = fwd.orthogonal() * HT_LEN * 0.5
			w.sk2.walls.append({"a": c - side, "b": c + side, "ttl": HT_TIME, "acc": HT_TICK, "mul": mul, "skill": id})
			p.swing = 0.25
			p.swing_kind = "cast"
		"dichchuyen":
			var from: Vector2 = p.pos
			var d2: Vector2 = (w._aim - p.pos).normalized() if w._aim.distance_to(p.pos) > 1.0 else Vector2.from_angle(p.facing)
			p.pos = (p.pos + d2 * DC_DIST).clamp(Vector2.ONE * w.PLAYER_RADIUS, w.world_size - Vector2.ONE * w.PLAYER_RADIUS)
			w._enforce_gate()
			w._enforce_arena_lock()
			w._blast(from, DC_R, Color("#9de0ff"))
			for e in w.enemies:
				if not e.dead and e.pos.distance_to(from) <= DC_R + e.radius:
					w._hit_enemy(e, mul, false, true)
					e.slow_t = maxf(e.slow_t, SLOW_TIME)
			p.swing = 0.2
			p.swing_kind = "cast"
		"muabang":
			var at: Vector2 = p.pos + (w._aim - p.pos).limit_length(MB_RANGE)
			var n = w._nearest_enemy(at, MB_R)
			if n == null:
				n = w._nearest_enemy(p.pos, MB_RANGE)
				if n != null:
					at = n.pos
			w.sk2.ice.append({"pos": at, "r": MB_R, "ticks": MB_TICKS, "timer": 0.0, "mul": mul, "skill": id})
			p.swing = 0.25
			p.swing_kind = "cast"
		"causam":
			var d3: Vector2 = (w._aim - p.pos).normalized() if w._aim.distance_to(p.pos) > 1.0 else Vector2.from_angle(p.facing)
			w.sk2.orbs.append({"pos": p.pos + d3 * 20.0, "vel": d3 * CS_SPEED, "ttl": CS_TIME, "zap": 0.0, "mul": mul, "skill": id})
			p.swing = 0.25
			p.swing_kind = "cast"
		"vankiem":
			for k in VK_TICKS:
				w.sk2.queue.append({"t": VK_GAP * k, "skill": id, "kind": "whirl", "mul": mul, "r": VK_R})
			w._text(p.pos + Vector2(0, -60), "Vạn Kiếm Quy Tông!", Color("#ffd76a"), true)
			p.swing = VK_GAP * VK_TICKS
			p.swing_kind = "spin"
		"thientien":
			var z = w.RainZone.new()
			z.pos = p.pos + (w._aim - p.pos).limit_length(w.RAIN_RANGE)
			var n0 = w._nearest_enemy(z.pos, TT_R)
			if n0 == null:
				n0 = w._nearest_enemy(p.pos, w.RAIN_RANGE)
				if n0 != null:
					z.pos = n0.pos
			z.radius = TT_R
			z.mul = mul
			z.ticks = TT_TICKS
			z.timer = 0.0
			z.skill = id
			w.rains.append(z)
			w._text(p.pos + Vector2(0, -60), "Thiên Tiễn Vũ!", Color("#9ad46a"), true)
			p.swing = 0.25
			p.swing_kind = "shot"
		"thienhoa":
			# CL1 Thiên Tai Nguyên Tố: lửa (thiên thạch) → băng → sét, cùng một điểm.
			var c0: Vector2 = p.pos + (w._aim - p.pos).limit_length(w.METEOR_RANGE)
			var n1 = w._nearest_enemy(c0, TTN_FIRE_R)
			if n1 == null:
				n1 = w._nearest_enemy(p.pos, w.METEOR_RANGE)
				if n1 != null:
					c0 = n1.pos
			var m = w.Meteor.new()
			m.pos = c0
			m.timer = w.METEOR_DELAY
			m.radius = TTN_FIRE_R
			m.mul = mul * TTN_FIRE
			m.skill = id
			w.meteors.append(m)
			w.sk2.queue.append({"t": w.METEOR_DELAY + TTN_GAP, "skill": id, "kind": "tt_ice", "mul": mul * TTN_ICE, "pos": c0})
			w.sk2.queue.append({"t": w.METEOR_DELAY + TTN_GAP * 2.0, "skill": id, "kind": "tt_bolt", "mul": mul * TTN_BOLT, "pos": c0})
			w._text(p.pos + Vector2(0, -60), "Thiên Tai Nguyên Tố!", Color("#ff7a1a"), true)
			p.swing = 0.3
			p.swing_kind = "cast"
		"kiemy":
			w.sk2.kiemy_t = KY_TIME
			w._blast(p.pos, 40.0, Color("#ff5a50"))
			w._text(p.pos + Vector2(0, -40), "Kiếm Ý!", Color("#ff7a6a"), true)
		"banglao":
			w._soft_lock(BL_RANGE)
			w._fire(w.PIERCE_SPEED, BL_RANGE, mul, true, "pierce", false, 14.0)
			p.swing = 0.2
			p.swing_kind = "cast"
		"thanhkiem":
			w._auto_face(w.WAVE_RANGE, deg_to_rad(15.0))
			w._fire(w.WAVE_SPEED, 500.0, mul, true, "wave", false, 30.0)
			p.swing = 0.2
			p.swing_kind = "slash"
		"kiemvuc":
			w.sk2.ice.append({"pos": p.pos, "r": KVU_R, "ticks": KVU_TICKS, "timer": 0.0, "mul": mul, "skill": id, "gap": 0.5, "follow": true})
			p.swing = 0.3
			p.swing_kind = "spin"
		"huyetbao":
			p.hp = maxf(1.0, p.hp - p.hp * HB_COST)
			w._blast(p.pos, HB_R, Color("#ff4a5a"))
			w._sfx("explode")
			for e in w.enemies:
				if not e.dead and e.pos.distance_to(p.pos) <= HB_R + e.radius:
					w._hit_enemy(e, mul, false, true)
			p.swing = 0.3
			p.swing_kind = "spin"
		"huyetanh":
			for k in HA_DASHES:
				w.sk2.queue.append({"t": HA_GAP * k, "skill": id, "kind": "dash", "mul": mul})
		"phakhong":
			w._soft_lock(PK_RANGE)
			w._fire(w.PIERCE_SPEED * 1.2, PK_RANGE, mul, true, "pierce", true, 14.0)
			p.swing = 0.2
			p.swing_kind = "shot"
		"tamlien":
			for k in TL_SHOTS:
				w.sk2.queue.append({"t": TL_GAP * k, "skill": id, "kind": "pierce", "mul": mul})
		"baimin":
			for k in BM_MINES:
				var t = w.Trap.new()
				t.pos = p.pos + Vector2.from_angle(TAU * k / BM_MINES) * BM_R
				t.ttl = w.TRAP_TTL
				t.mul = mul
				t.skill = id
				w.traps.append(t)
		"luoibay":
			var at2: Vector2 = p.pos + (w._aim - p.pos).limit_length(250.0)
			w._blast(at2, LB_R, Color("#9ad46a"))
			for e in w.enemies:
				if not e.dead and e.pos.distance_to(at2) <= LB_R + e.radius:
					w._hit_enemy(e, mul, false, true)
					e.root_timer = maxf(e.root_timer, LB_ROOT)
			p.swing = 0.2
			p.swing_kind = "shot"
		"thienloi":
			var hit2 := {}
			for k in TLO_TARGETS:
				var t2 = w._nearest_enemy(p.pos, TLO_RANGE, hit2)
				if t2 == null:
					break
				hit2[t2.id] = true
				var b2 = w.Bolt.new()
				b2.points.append(t2.pos + Vector2(10, -260))
				b2.points.append(t2.pos + Vector2(-8, -120))
				b2.points.append(t2.pos)
				w.bolts.append(b2)
				w._hit_enemy(t2, mul, false, true)
			p.swing = 0.25
			p.swing_kind = "cast"
		"bangphong":
			w._blast(p.pos, BP_R, Color("#9de0ff"))
			w._sfx("explode")
			for e in w.enemies:
				if not e.dead and e.pos.distance_to(p.pos) <= BP_R + e.radius:
					e.root_timer = maxf(e.root_timer, BP_ROOT)
					w._hit_enemy(e, mul, false, true)
			p.swing = 0.25
			p.swing_kind = "cast"
		"trieuhoi":
			for k in TH_BONES:
				var a = w._add_ally("shadow", "xuong-no", int(w.profile.level), p.pos + Vector2.from_angle(TAU * k / TH_BONES) * 40.0)
				a.kind = "bone"
				a.atk = float(w.stats.atk) * 0.5
				a.ttl = TH_BONE_TTL
				a.color = Color("#d2c8b2")
			w._text(p.pos + Vector2(0, -50), "Triệu Hồi Xương!", Color("#d2c8b2"), true)
		"khidoc":
			var at3: Vector2 = p.pos + (w._aim - p.pos).limit_length(300.0)
			var n2 = w._nearest_enemy(at3, KD_R)
			if n2 == null:
				n2 = w._nearest_enemy(p.pos, 300.0)
				if n2 != null:
					at3 = n2.pos
			w.sk2.ice.append({"pos": at3, "r": KD_R, "ticks": KD_TICKS, "timer": 0.0, "mul": mul, "skill": id, "gap": KD_GAP, "poison": true})
			p.swing = 0.25
			p.swing_kind = "cast"
		_:
			# LH1 / LH2: kỹ năng của Hộ Vệ, Triệu Hồi Sư (docs/19).
			return Classes2.cast(w, id, mul)
	return true


## Tên Nảy: trúng quái gần nhất theo hướng ngắm, nảy tối đa 4 lần.
static func _bounce(w, id: String, mul: float) -> void:
	var p = w.player
	w._soft_lock(TN_RANGE)
	var first = null
	var dir := Vector2.from_angle(p.facing)
	var bd := INF
	for e in w.enemies:
		if e.dead or w.is_hidden(e):
			continue
		var to_e: Vector2 = e.pos - p.pos
		var d: float = to_e.length() - e.radius
		if d <= TN_RANGE and absf(angle_difference(dir.angle(), to_e.angle())) <= deg_to_rad(25.0) and d < bd:
			bd = d
			first = e
	if first == null:
		first = w._nearest_enemy(p.pos, TN_RANGE)
	var b = w.Bolt.new()
	b.points.append(p.pos)
	if first == null:
		return
	var hit := {}
	var cur = first
	var k := 1.0
	for _i in TN_JUMPS + 1:
		hit[cur.id] = true
		b.points.append(cur.pos)
		w._hit_enemy(cur, mul * k)
		if cur.dead:
			break
		var nxt = w._nearest_enemy(cur.pos, TN_HOP, hit)
		if nxt == null:
			k = TN_ECHO
			continue
		cur = nxt
		k = 1.0
	w.bolts.append(b)


static func tick(w, dt: float) -> void:
	var st = w.sk2
	var p = w.player
	st.kiemy_t = maxf(0.0, st.kiemy_t - dt)
	st.lonnhao_t = maxf(0.0, st.lonnhao_t - dt)
	# đòn trễ
	for q in st.queue:
		q.t -= dt
		if q.t > 0.0 or p.dead_timer > 0.0:
			continue
		w.skill_ctx = str(q.skill)
		match str(q.kind):
			"cone":
				var dir := Vector2.from_angle(p.facing)
				w._blast(p.pos + dir * LT_RANGE * 0.6, LT_RANGE * 0.5, Color("#e8eef6"))
				w._sfx("slash")
				for e in w.enemies:
					if e.dead:
						continue
					var to_e: Vector2 = e.pos - p.pos
					if to_e.length() <= LT_RANGE + e.radius and absf(angle_difference(dir.angle(), to_e.angle())) <= LT_ARC:
						w._hit_enemy(e, float(q.mul))
			"whirl":
				var rr: float = float(q.get("r", KV_R))
				w._blast(p.pos, rr, Color("#c8d6e4"))
				for e in w.enemies:
					if not e.dead and e.pos.distance_to(p.pos) <= rr + e.radius:
						w._hit_enemy(e, float(q.mul), false, true)
			"dash":
				var tg = w._nearest_enemy(p.pos, 260.0)
				var dd: Vector2 = (tg.pos - p.pos).normalized() if tg != null else Vector2.from_angle(p.facing)
				p.dash_dir = dd
				p.dash_time = w.DASH_TIME
				p.dash_mul = float(q.mul)
				p.dash_hit = {}
				p.dash_skill = str(q.skill)
				p.dash_dist = w.DASH_DIST
				p.swing = w.DASH_TIME + 0.05
				p.swing_kind = "dash"
			"pierce":
				w._soft_lock(w.PIERCE_RANGE)
				var ps = w._fire(w.PIERCE_SPEED, w.PIERCE_RANGE, float(q.mul), true, "pierce", false, 12.0)
				if str(q.skill) == "pierce":
					ps.max_hits = XT_MAX_HITS
			"tt_ice":
				st.wave_el = TTN_ELEMENTS[1]
				var ic: Vector2 = q.pos
				w._blast(ic, TTN_FIRE_R, Color("#9de0ff"))
				w._sfx("explode")
				for e in w.enemies:
					if not e.dead and e.pos.distance_to(ic) <= TTN_FIRE_R + e.radius:
						w._hit_enemy(e, float(q.mul), false, true)
						if not e.dead:
							e.slow_t = maxf(e.slow_t, BL_SLOW)
				st.wave_el = ""
			"tt_bolt":
				st.wave_el = TTN_ELEMENTS[2]
				var hit := {}
				var cur = w._nearest_enemy(q.pos, TTN_FIRE_R + 40.0)
				var b = w.Bolt.new()
				b.points.append(Vector2(q.pos) + Vector2(0, -260))
				for _i in TTN_JUMPS + 1:
					if cur == null:
						break
					hit[cur.id] = true
					b.points.append(cur.pos)
					w._hit_enemy(cur, float(q.mul), false, true)
					cur = w._nearest_enemy(cur.pos, w.CHAIN_HOP, hit)
				if b.points.size() > 1:
					w.bolts.append(b)
				st.wave_el = ""
			"volley":
				var tgt = w._nearest_enemy(p.pos, w.SHOT_RANGE)
				if tgt != null:
					var keep: float = p.facing
					p.facing = (tgt.pos - p.pos).angle()
					w._fire(w.SHOT_SPEED, w.SHOT_RANGE, float(q.mul), false, "arrow")
					p.facing = keep
		w.skill_ctx = ""
	st.queue = st.queue.filter(func(q): return q.t > 0.0 and p.dead_timer <= 0.0)
	# Hoả Tường
	for wl in st.walls:
		wl.ttl -= dt
		wl.acc += dt
		if wl.acc < HT_TICK:
			continue
		wl.acc -= HT_TICK
		w.skill_ctx = str(wl.skill)
		for e in w.enemies:
			if not e.dead and Geometry2D.get_closest_point_to_segment(e.pos, wl.a, wl.b).distance_to(e.pos) <= HT_THICK + e.radius:
				w._hit_enemy(e, float(wl.mul), false, true)
		w.skill_ctx = ""
	st.walls = st.walls.filter(func(wl): return wl.ttl > 0.0)
	# Mưa Băng / Kiếm Vực (đi theo người chơi) / Khí Độc (độc, không làm chậm)
	for z in st.ice:
		if z.get("follow", false):
			z.pos = p.pos
		z.timer -= dt
		if z.timer > 0.0 or z.ticks <= 0:
			continue
		z.timer = float(z.get("gap", MB_GAP))
		z.ticks -= 1
		w.skill_ctx = str(z.skill)
		for e in w.enemies:
			if not e.dead and e.pos.distance_to(z.pos) <= float(z.r) + e.radius:
				w._hit_enemy(e, float(z.mul), false, true)
				if not z.get("poison", false):
					e.slow_t = maxf(e.slow_t, 1.0)
		# LH1: Thánh Vực hồi HP mỗi nhịp.
		if z.has("heal"):
			p.hp = minf(float(w.stats.max_hp), p.hp + float(w.stats.max_hp) * float(z.heal))
		w.skill_ctx = ""
	st.ice = st.ice.filter(func(z): return z.ticks > 0 or z.timer > 0.0)
	# Cầu Sấm
	for o in st.orbs:
		o.ttl -= dt
		o.pos += o.vel * dt
		o.zap -= dt
		w.skill_ctx = str(o.skill)
		if o.zap <= 0.0:
			o.zap = CS_ZAP_GAP
			var t = w._nearest_enemy(o.pos, CS_ZAP_R)
			if t != null:
				var b = w.Bolt.new()
				b.points.append(o.pos)
				b.points.append(t.pos)
				w.bolts.append(b)
				w._hit_enemy(t, float(o.mul), false, true)
		if o.ttl <= 0.0:
			w._blast(o.pos, CS_END_R, Color("#b3a6ff"))
			w._sfx("explode")
			for e in w.enemies:
				if not e.dead and e.pos.distance_to(o.pos) <= CS_END_R + e.radius:
					w._hit_enemy(e, float(o.mul) * CS_END_MUL, false, true)
		w.skill_ctx = ""
	st.orbs = st.orbs.filter(func(o): return o.ttl > 0.0)
