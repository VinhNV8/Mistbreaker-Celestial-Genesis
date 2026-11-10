extends RefCounted
## Logic trang bị: sinh đồ, tính chỉ số, mặc/tháo, cường hoá, phân rã (đặc tả MVP M1).
## Một món đồ là Dictionary:
## {id, slot, rarity, level, plus, set, unique, affixes: [{stat, value}], locked (CR-04, thiếu = false),
##  NL-1 (docs/47): sockets (số lỗ ngọc), gems ["kim:3", …], reforged (chỉ số dòng đã tẩy, -1 = chưa),
##  reforges (số lần tẩy), awaken {id, tier, spent, offer} (Thức Tỉnh; {} = chưa)}
## Các hàm nhận `p` là Profile (không khai báo kiểu để tránh preload vòng tròn).

const ItemData = preload("res://scripts/data/items.gd")
const RngUtil = preload("res://scripts/core/rng_util.gd")
const Talents = preload("res://scripts/data/talents.gd")
const TalentSlots = preload("res://scripts/core/talent_slots.gd")
const GearData = preload("res://scripts/data/gear_data.gd")

## TL-S5: cường hoá lên +10 trở lên cần thêm 1 Tinh Kim mỗi lần.
const TINH_KIM_FROM_PLUS := 9
## Bàn Tay Vàng: 20% nhận thêm 1 Tinh Kim khi phân rã.
const GOLDEN_HAND_CHANCE := 0.2


# ------------------------------------------------------------------ sinh đồ


## EQ-02/03: sinh một món. slot rỗng = ngẫu nhiên; unique ép ô theo món Cam đó.
static func create(id: int, level: int, rarity: String, rng: Callable, slot := "", set_id := "", unique := "") -> Dictionary:
	if unique != "":
		slot = ItemData.UNIQUES[unique].slot
	if slot == "":
		slot = ItemData.SLOT_ORDER[int(float(rng.call()) * ItemData.SLOT_ORDER.size()) % ItemData.SLOT_ORDER.size()]
	var pool := RngUtil.shuffle(ItemData.AFFIXES.keys().filter(func(k): return slot in ItemData.AFFIXES[k].get("slots", [slot])), rng)
	var affixes: Array = []
	var count: int = ItemData.RARITIES[rarity].affixes
	for i in count:
		var stat: String = pool[i]
		var a: Dictionary = ItemData.AFFIXES[stat]
		var value: float = (a.a + a.b * level) * (0.8 + float(rng.call()) * 0.4)
		affixes.append({"stat": stat, "value": value})
	return {
		"id": id,
		"slot": slot,
		"rarity": rarity,
		"level": level,
		"plus": 0,
		"set": set_id,
		"unique": unique,
		"affixes": affixes,
		"style": "",
		"sockets": int(GearData.SOCKETS.get(rarity, 0)),
		"gems": [],
		"reforged": -1,
		"reforges": 0,
		"awaken": {},
	}


## Sinh đồ và cấp id tăng dần từ hồ sơ.
static func new_item(p, level: int, rarity: String, rng: Callable, slot := "", set_id := "", unique := "") -> Dictionary:
	var item := create(p.next_item_id, level, rarity, rng, slot, set_id, unique)
	p.next_item_id += 1
	# CL-05: vũ khí sinh ra khi đang là Thợ Săn là Cung, Pháp Sư là Trượng (SN-01) — chỉ số như Kiếm.
	if item.slot == "weapon" and unique == "":
		match str(p.get("class_id")):
			"tho-san":
				item["style"] = "bow"
			"phap-su":
				item["style"] = "staff"
			"ho-ve":
				item["style"] = "mace"
			"trieu-hoi-su":
				item["style"] = "orb"
	return item


static func roll_rarity(table_name: String, rng: Callable) -> String:
	var table: Dictionary = ItemData.DROP_TABLES[table_name]
	return RngUtil.pick_weighted(table.keys(), func(k): return table[k], rng)


# ------------------------------------------------------------------ chỉ số


static func base_stat(item: Dictionary) -> String:
	return ItemData.SLOTS[item.slot].base


## 3.3: (a + b·L) × hệ số phẩm chất × (1 + 0,1 × cấp cường hoá).
static func base_value(item: Dictionary, plus := -1) -> float:
	var s: Dictionary = ItemData.SLOTS[item.slot]
	var p: int = int(item.plus) if plus < 0 else plus
	return (s.a + s.b * int(item.level)) * float(ItemData.RARITIES[item.rarity].mult) * (1.0 + 0.1 * p)


## Tổng chỉ số một món: {stat: value} (gốc + cường hoá + dòng phụ + ngọc).
static func item_stats(item: Dictionary) -> Dictionary:
	var out := {base_stat(item): base_value(item)}
	for af in item.affixes:
		out[af.stat] = out.get(af.stat, 0.0) + float(af.value)
	var gs := gem_stats(item)
	for k in gs:
		out[k] = out.get(k, 0.0) + gs[k]
	return out


# ------------------------------------------------------------------ NL-1: ngọc trên món (docs/47 §3.A)


## "kim:3" → ["kim", 3].
static func gem_parse(key: String) -> Array:
	var parts := key.split(":")
	return [parts[0], int(parts[1]) if parts.size() > 1 else 1]


static func gem_key(el: String, lv: int) -> String:
	return "%s:%d" % [el, lv]


## Chỉ số của 1 viên ngọc khảm trên ô `slot`.
static func gem_value(el: String, lv: int, slot: String) -> Dictionary:
	var lv_i := clampi(lv, 1, GearData.GEM_MAX_LV)
	var out := {str(GearData.GEM_STAT[el]): float(GearData.GEM_VALUES[el][lv_i - 1])}
	if slot in ItemData.RES_SLOTS:
		out["res_" + el] = GearData.GEM_RES_PER_LV * lv_i
	return out


static func gem_stats(item: Dictionary) -> Dictionary:
	var out := {}
	for g in item.get("gems", []):
		var pr := gem_parse(str(g))
		var gv := gem_value(pr[0], pr[1], str(item.slot))
		for k in gv:
			out[k] = out.get(k, 0.0) + gv[k]
	return out


## Ấn hệ vũ khí: hệ có ≥ 2 viên trên vũ khí (hoà thì tổng cấp cao hơn, rồi theo thứ tự ngũ hành); "" = không.
static func weapon_seal(equipment: Dictionary) -> String:
	var w: Dictionary = equipment.get("weapon", {})
	if w.is_empty():
		return ""
	var n := {}
	var lv := {}
	for g in w.get("gems", []):
		var pr := gem_parse(str(g))
		n[pr[0]] = int(n.get(pr[0], 0)) + 1
		lv[pr[0]] = int(lv.get(pr[0], 0)) + int(pr[1])
	var best := ""
	for el in GearData.ELEMENTS:
		if int(n.get(el, 0)) < GearData.SEAL_MIN:
			continue
		if best == "" or int(n[el]) > int(n[best]) or (int(n[el]) == int(n[best]) and int(lv[el]) > int(lv[best])):
			best = el
	return best


## Trả ngọc trên món về Túi Ngọc (phân rã / bán / làm nguyên liệu Thăng phẩm). Trả số viên.
static func strip_gems(p, item: Dictionary) -> int:
	var gems: Array = item.get("gems", [])
	var n := gems.size()
	if n > 0 and "gem_bag" in p:
		for g in gems:
			p.gem_bag[str(g)] = int(p.gem_bag.get(str(g), 0)) + 1
		item["gems"] = []
	return n


# ------------------------------------------------------------------ NL-1: Thức Tỉnh (docs/47 §3.E)


## Các món đang mặc có Thức Tỉnh hiệu lực: tối đa 4, ưu tiên bậc cao rồi theo thứ tự ô.
static func active_awakens(equipment: Dictionary) -> Array:
	var list: Array = []
	for slot in ItemData.SLOT_ORDER:
		var it: Dictionary = equipment.get(slot, {})
		var aw: Dictionary = it.get("awaken", {}) if not it.is_empty() else {}
		if str(aw.get("id", "")) != "" and int(aw.get("tier", 0)) > 0:
			list.append({"slot": slot, "id": str(aw.id), "tier": int(aw.tier)})
	list.sort_custom(func(a, b): return a.tier > b.tier or (a.tier == b.tier and ItemData.SLOT_ORDER.find(a.slot) < ItemData.SLOT_ORDER.find(b.slot)))
	return list.slice(0, GearData.AWAKEN_MAX_ACTIVE)


static func awaken_value(line_id: String, tier: int) -> float:
	var ln: Dictionary = GearData.AWAKEN_LINES.get(line_id, {})
	if ln.is_empty() or tier <= 0:
		return 0.0
	return float(ln.v[clampi(tier, 1, GearData.AWAKEN_MAX_TIER) - 1])


static func awaken_text(line_id: String, tier: int) -> String:
	var ln: Dictionary = GearData.AWAKEN_LINES.get(line_id, {})
	if ln.is_empty():
		return ""
	var v := awaken_value(line_id, maxi(1, tier))
	var vs := ("%s%%" % num_text(v * 100.0)) if bool(ln.pct) else num_text(v)
	return str(ln.text) % vs


## Số gọn kiểu Việt: 4 → "4", 1,5 → "1,5".
static func num_text(v: float) -> String:
	return str(roundi(v)) if absf(v - roundf(v)) < 0.05 else ("%.1f" % v).replace(".", ",")


# ------------------------------------------------------------------ NL-1: Bảo Giám (docs/47 §3.F)


## Ghi danh một món (lần đầu sở hữu đồ bộ / đồ Cam / mốc cường hoá). Trả về số mục mới.
static func codex_item(p, item: Dictionary) -> int:
	if p == null or item.is_empty() or not ("codex" in p):
		return 0
	var n := 0
	if str(item.get("set", "")) != "":
		n += codex_add(p, "s:%s:%s" % [item.set, item.slot])
	if str(item.get("unique", "")) != "":
		n += codex_add(p, "u:%s" % item.unique)
	for t in GearData.CODEX_PLUS:
		if int(item.get("plus", 0)) >= int(t):
			n += codex_add(p, "p:%s:%d" % [item.slot, int(t)])
	return n


static func codex_add(p, key: String) -> int:
	if p.codex.has(key):
		return 0
	p.codex[key] = true
	return 1


## Cộng toàn bộ đồ đang mặc + hiệu ứng bộ + hiệu ứng riêng. Kết quả đưa vào Stats.derive().
static func equipment_bonus(equipment: Dictionary) -> Dictionary:
	var flat := {}
	var sets := {}
	var uniques: Array = []
	for slot in equipment:
		var item: Dictionary = equipment[slot]
		var st := item_stats(item)
		for k in st:
			flat[k] = flat.get(k, 0.0) + st[k]
		if item.set != "":
			sets[item.set] = sets.get(item.set, 0) + 1
		if item.unique != "":
			uniques.append(item.unique)
	var bonus := {"flat": flat, "sets": sets, "uniques": uniques, "max_hp_pct": 0.0, "atk_pct": 0.0, "spin_cd": 0.0,
		"move_pct": 0.0, "atk_speed_pct": 0.0, "dodge_cd": 0.0,
		# NL-1 (docs/47): Thức Tỉnh + ấn hệ vũ khí. GameWorld._derive chép sang stats.
		"boss_dmg": 0.0, "skill_dmg": 0.0, "lifesteal": 0.0, "counter_dmg": 0.0, "def_pct": 0.0, "pet_hp_pct": 0.0,
		"seal": weapon_seal(equipment), "awakens": []}
	for set_id in sets:
		for tier in ItemData.SETS[set_id].tiers:
			if sets[set_id] >= tier.count:
				for k in tier.bonus:
					bonus[k] += tier.bonus[k]
	for aw in active_awakens(equipment):
		var key := str(GearData.AWAKEN_LINES[aw.id].key)
		var v := awaken_value(aw.id, aw.tier)
		if key == "crit_dmg":
			flat["crit_dmg"] = float(flat.get("crit_dmg", 0.0)) + v
		else:
			bonus[key] = float(bonus.get(key, 0.0)) + v
		bonus.awakens.append(aw.slot)
	return bonus


## 3.8: Lực chiến.
## NL-1: cp_extra = phần Lực chiến của hiệu ứng Thức Tỉnh không phải chỉ số (sát thương boss, kỹ năng, hút máu…).
static func combat_power(stats: Dictionary) -> int:
	return int(round(
		stats.atk * 10.0 + stats.max_hp + stats.def * 8.0 + stats.crit * 1000.0
		+ stats.crit_dmg * 300.0 + (stats.atk_speed - 1.0) * 800.0 + float(stats.get("cp_extra", 0.0))
	))


## NL-1 (docs/47 §5): Lực chiến của một nhóm chỉ số phẳng (cùng trọng số combat_power; kháng / tốc chạy không tính).
const STAT_POWER := {"atk": 10.0, "max_hp": 1.0, "def": 8.0, "crit": 1000.0, "crit_dmg": 300.0, "atk_speed": 800.0}


static func stats_power(st: Dictionary) -> int:
	var t := 0.0
	for k in st:
		t += float(st[k]) * float(STAT_POWER.get(k, 0.0))
	return roundi(t)


## Lực chiến món này tách theo nguồn: {base, plus, affix, gem, total} (chỉ phần chỉ số phẳng).
static func item_power_parts(item: Dictionary) -> Dictionary:
	var stat := base_stat(item)
	var b0 := base_value(item, 0)
	var af := {}
	for a in item.affixes:
		af[a.stat] = af.get(a.stat, 0.0) + float(a.value)
	var parts := {
		"base": stats_power({stat: b0}),
		"plus": stats_power({stat: base_value(item) - b0}),
		"affix": stats_power(af),
		"gem": stats_power(gem_stats(item)),
	}
	parts["total"] = int(parts.base) + int(parts.plus) + int(parts.affix) + int(parts.gem)
	return parts


# ------------------------------------------------------------------ túi đồ


static func _result(ok: bool, message: String, extra := {}) -> Dictionary:
	var r := {"ok": ok, "message": message}
	r.merge(extra)
	return r


static func find_in_bag(p, id: int) -> int:
	for i in p.inventory.size():
		if int(p.inventory[i].id) == id:
			return i
	return -1


## Tìm món ở túi hoặc trên người. Trả về {item, where: "bag" | tên ô} hoặc {}.
static func find_item(p, id: int) -> Dictionary:
	var i := find_in_bag(p, id)
	if i >= 0:
		return {"item": p.inventory[i], "where": "bag"}
	for slot in p.equipment:
		if int(p.equipment[slot].id) == id:
			return {"item": p.equipment[slot], "where": slot}
	return {}


## EQ-09: túi đầy thì tự phân rã thành Đá Cường Hoá.
## CR-04 (Q214): đồ Cam tự khoá khi vào tay.
static func add_item(p, item: Dictionary) -> Dictionary:
	if str(item.rarity) == "orange" and not item.has("locked"):
		item["locked"] = true
	codex_item(p, item)
	if p.inventory.size() >= ItemData.BAG_SIZE:
		var stones := salvage_value(item, p)
		p.stones += stones
		strip_gems(p, item)
		return _result(true, "Túi đầy: %s tự phân rã thành %d Đá Cường Hoá." % [display_name(item), stones], {"salvaged": true})
	p.inventory.append(item)
	return _result(true, "Nhặt được %s." % display_name(item), {"salvaged": false})


## SN-20: cấp cường hoá món `item` nhận được khi mặc (đổi cấp với đồ đang mặc nếu đồ đó cao hơn).
static func plus_after_equip(p, item: Dictionary) -> int:
	var worn: Dictionary = p.equipment.get(item.slot, {})
	if worn.is_empty() or int(worn.id) == int(item.id):
		return int(item.plus)
	return maxi(int(item.plus), int(worn.plus))


## EQ-10: mặc đồ, đồ cũ cùng ô về túi. SN-20: đồ cũ cường hoá cao hơn thì 2 món đổi cấp cho nhau.
static func equip(p, id: int) -> Dictionary:
	var i := find_in_bag(p, id)
	if i < 0:
		return _result(false, "Món đồ không có trong túi.")
	var item: Dictionary = p.inventory[i]
	p.inventory.remove_at(i)
	var msg := "Đã mặc %s." % display_name(item)
	if p.equipment.has(item.slot):
		var old: Dictionary = p.equipment[item.slot]
		if int(old.plus) > int(item.plus):
			var moved := int(old.plus)
			old.plus = int(item.plus)
			item.plus = moved
			msg = "Chuyển +%d từ %s sang %s." % [moved, display_name(old), display_name(item)]
		p.inventory.append(old)
	p.equipment[item.slot] = item
	return _result(true, msg, {"transferred": msg.begins_with("Chuyển")})


static func unequip(p, slot: String) -> Dictionary:
	if not p.equipment.has(slot):
		return _result(false, "Ô này đang trống.")
	if p.inventory.size() >= ItemData.BAG_SIZE:
		return _result(false, "Túi đầy, không tháo được.")
	var item: Dictionary = p.equipment[slot]
	p.equipment.erase(slot)
	p.inventory.append(item)
	return _result(true, "Đã tháo %s." % display_name(item))


# ------------------------------------------------------------------ cường hoá, phân rã


## Thợ Rèn Bẩm Sinh +10%; nhóm Chế tạo cấp 10 +5%.
static func talent_rate_bonus(p) -> float:
	if p == null:
		return 0.0
	var b := TalentSlots.value(p, "tho-ren", 0.1, 0.15) if TalentSlots.has(p, "tho-ren") else 0.0
	if TalentSlots.has_group_sub(p, "craft", 2):
		b += 0.05
	return b


## p (tuỳ chọn) để cộng thưởng tỉ lệ từ Thiên phú.
static func enhance_rate(item: Dictionary, p = null, extra := 0.0) -> float:
	if int(item.plus) >= ItemData.MAX_PLUS:
		return 0.0
	return minf(1.0, float(ItemData.ENHANCE_RATES[int(item.plus)]) + talent_rate_bonus(p) + extra)


## 3.5: vàng = round(10·(n+1)^1,6·(1 + L/10)); đá = 1 + ⌊n/3⌋; từ +9 lên +10 trở đi thêm 1 Tinh Kim.
## Nhóm Chế tạo cấp 5: rẻ hơn 10% vàng.
static func enhance_cost(item: Dictionary, p = null) -> Dictionary:
	var n: int = int(item.plus)
	var gold := 10.0 * pow(n + 1, 1.6) * (1.0 + int(item.level) / 10.0)
	if p != null and TalentSlots.has_group_sub(p, "craft", 1):
		gold *= 0.9
	return {
		"gold": int(round(gold)),
		"stones": 1 + int(n / 3.0),
		"tinh_kim": 1 if n >= TINH_KIM_FROM_PLUS else 0,
	}


## Lý do không cường hoá được, hoặc chuỗi rỗng.
static func enhance_blocker(p, item: Dictionary) -> String:
	if int(item.plus) >= ItemData.MAX_PLUS:
		return "Đã đạt +%d tối đa." % ItemData.MAX_PLUS
	var cost := enhance_cost(item, p)
	if p.gold < cost.gold:
		return "Cần %d vàng." % cost.gold
	if p.stones < cost.stones:
		return "Cần %d Đá Cường Hoá." % cost.stones
	if p.tinh_kim < cost.tinh_kim:
		return "Cần %d Tinh Kim (rơi từ Sói Chúa, hoặc Thiên phú Bàn Tay Vàng)." % cost.tinh_kim
	return ""


## EQ-12/13: thất bại không mất đồ, không tụt cấp, chỉ mất nguyên liệu.
static func enhance(p, id: int, rng: Callable, rate_bonus := 0.0) -> Dictionary:
	var found := find_item(p, id)
	if found.is_empty():
		return _result(false, "Không tìm thấy món đồ.")
	var item: Dictionary = found.item
	var blocker := enhance_blocker(p, item)
	if blocker != "":
		return _result(false, blocker)
	var cost := enhance_cost(item, p)
	var rate := enhance_rate(item, p, rate_bonus)
	p.gold -= cost.gold
	p.stones -= cost.stones
	p.tinh_kim -= cost.tinh_kim
	if float(rng.call()) < rate:
		item.plus = int(item.plus) + 1
		codex_item(p, item)
		return _result(true, "Cường hoá thành công: %s." % display_name(item), {"success": true})
	return _result(true, "Cường hoá thất bại (%d%%). Món đồ vẫn giữ nguyên +%d." % [roundi(rate * 100.0), int(item.plus)], {"success": false})


## 3.6: đá theo phẩm chất + ⌊cấp cường hoá / 2⌋; nhóm Kinh tế cấp 10 +1.
static func salvage_value(item: Dictionary, p = null) -> int:
	var extra := 1 if p != null and TalentSlots.has_group_sub(p, "economy", 2) else 0
	return int(ItemData.RARITIES[item.rarity].salvage) + int(int(item.plus) / 2.0) + extra


# ------------------------------------------------------------------ SN-10: bộ lọc phân rã / bán nhanh

static func default_filter() -> Dictionary:
	return {"rarities": ["white", "green", "blue"], "keep_plus": true, "keep_set": true, "only_weaker": true}


## Đọc bộ lọc từ save (thiếu khoá thì lấy mặc định).
static func normalize_filter(f) -> Dictionary:
	var out := default_filter()
	if f is Dictionary:
		for k in out:
			if f.has(k):
				out[k] = f[k]
	var rs: Array = []
	for r in out.rarities:
		if str(r) in ItemData.RARITY_ORDER:
			rs.append(str(r))
	out.rarities = rs
	return out


## Món trong túi khớp bộ lọc. weaker: Callable(item) -> bool (Lực chiến khi mặc < hiện tại); bỏ trống = bỏ qua điều kiện.
static func bulk_candidates(p, f: Dictionary, weaker := Callable()) -> Array:
	var out: Array = []
	for item in p.inventory:
		if is_locked(item):
			continue
		if not (str(item.rarity) in f.rarities):
			continue
		if f.keep_plus and int(item.plus) > 0:
			continue
		if f.keep_set and str(item.get("set", "")) != "":
			continue
		if f.only_weaker and weaker.is_valid() and not bool(weaker.call(item)):
			continue
		out.append(item)
	return out


static func salvage(p, id: int, rng := Callable()) -> Dictionary:
	var i := find_in_bag(p, id)
	if i < 0:
		return _result(false, "Chỉ phân rã được đồ trong túi (tháo ra trước).")
	var item: Dictionary = p.inventory[i]
	if is_locked(item):
		return _result(false, LOCKED_MSG)
	p.inventory.remove_at(i)
	var gems_back := strip_gems(p, item)
	var g := salvage_gain(p, item, rng)
	var msg := "Phân rã %s: +%d Đá Cường Hoá." % [display_name(item), int(g.stones)]
	if gems_back > 0:
		msg += " %d viên ngọc về Túi Ngọc." % gems_back
	if str(g.get("gem", "")) != "":
		var gp := gem_parse(str(g.gem))
		msg += " +1 %s cấp %d!" % [GearData.GEM_NAMES[gp[0]], int(gp[1])]
	if int(g.tinh_kim) > 0:
		msg += " Bàn Tay Vàng: +1 Tinh Kim!"
	if int(g.essence) > 0:
		msg += " Thần Tài: +1 Thiên Phú Tinh Hoa!"
	return _result(true, msg)


## Cộng phần thưởng phân rã của một món (đã rời túi hoặc chưa từng vào túi — CR-04 tự phân rã khi nhặt).
static func salvage_gain(p, item: Dictionary, rng := Callable()) -> Dictionary:
	var stones := salvage_value(item, p)
	p.stones += stones
	var tk := 0
	if TalentSlots.has(p, "ban-tay-vang") and rng.is_valid() and float(rng.call()) < TalentSlots.value(p, "ban-tay-vang", GOLDEN_HAND_CHANCE, 0.3):
		p.tinh_kim += 1
		tk = 1
	# CR-04 R5: Thần Tài (Bàn Tay Vàng tiến hoá 2) — phân rã 10% ra 1 Thiên Phú Tinh Hoa.
	var ess := 0
	if golden_form(p) >= 2 and rng.is_valid() and float(rng.call()) < GOD_OF_WEALTH_ESSENCE:
		p.essence += 1
		ess = 1
	# NL-1 (docs/47 §3.A): phân rã đồ Cam → 1 viên ngọc cấp 2 ngẫu nhiên.
	var gem := ""
	if str(item.get("rarity", "")) == "orange" and rng.is_valid() and "gem_bag" in p:
		var el: String = GearData.ELEMENTS[int(float(rng.call()) * GearData.ELEMENTS.size()) % GearData.ELEMENTS.size()]
		gem = gem_key(el, GearData.GEM_SALVAGE_ORANGE_LV)
		p.gem_bag[gem] = int(p.gem_bag.get(gem, 0)) + 1
	return {"stones": stones, "tinh_kim": tk, "essence": ess, "gem": gem}


const GOD_OF_WEALTH_ESSENCE := 0.1


## Dạng tiến hoá của Bàn Tay Vàng khi là Thiên phú chính: 0 = không / chưa tiến hoá, 1 = Điểm Kim, 2 = Thần Tài.
static func golden_form(p) -> int:
	return int(p.evo) if str(p.talent) == "ban-tay-vang" else 0


# ------------------------------------------------------------------ CR-04: khoá đồ, tự xử lý đồ theo quy tắc

const LOCKED_MSG := "Món này đã khoá — mở khoá trước (phím L)."
## Hành động theo phẩm chất. Cam không có trong bảng: luôn giữ (Q214).
const LOOT_ACTIONS := ["keep", "sell", "salvage"]
const LOOT_ACTION_NAMES := {"keep": "Giữ", "sell": "Bán", "salvage": "Phân rã"}
const LOOT_MODES := ["off", "pickup", "full"]
const LOOT_MODE_NAMES := {"off": "Tắt", "pickup": "Khi nhặt", "full": "Khi túi đầy"}
const LOOT_RARITIES := ["white", "green", "blue", "purple"]
## Mẫu cấu hình sẵn: [tên, {phẩm chất: hành động}].
const LOOT_PRESETS := {
	"gold": ["Cày vàng", {"white": "sell", "green": "sell", "blue": "sell", "purple": "keep"}],
	"stone": ["Cày đá", {"white": "salvage", "green": "salvage", "blue": "salvage", "purple": "keep"}],
	"balanced": ["Cân bằng", {"white": "sell", "green": "sell", "blue": "salvage", "purple": "keep"}],
}
## "Giữ đồ cấp ≥ cấp nhân vật − N": N trong 0…10; −1 = tắt.
const LOOT_GAP_MAX := 10


static func is_locked(item: Dictionary) -> bool:
	return bool(item.get("locked", false))


## CR-04 R1: món không bao giờ tự phân rã khi túi đầy (đồ Cam, món đã khoá).
static func must_keep(item: Dictionary) -> bool:
	return str(item.rarity) == "orange" or is_locked(item)


## Bật/tắt khoá một món (túi hoặc đang mặc).
static func toggle_lock(p, id: int) -> Dictionary:
	var f := find_item(p, id)
	if f.is_empty():
		return _result(false, "Không tìm thấy món đồ.")
	var item: Dictionary = f.item
	item["locked"] = not is_locked(item)
	return _result(true, ("Đã khoá %s." if item.locked else "Đã mở khoá %s.") % display_name(item))


## TD-17 (U3): ghi đè theo ô — "rule" = theo bảng phẩm chất.
const LOOT_SLOT_ACTIONS := ["rule", "keep", "sell", "salvage"]


static func default_rules() -> Dictionary:
	var by_slot := {}
	for sl in ItemData.SLOT_ORDER:
		by_slot[sl] = "rule"
	return {"mode": "off", "by_rarity": {"white": "keep", "green": "keep", "blue": "keep", "purple": "keep"},
		"keep_plus": true, "keep_set": true, "keep_better": true, "keep_level_gap": -1,
		"by_slot": by_slot, "keep_stats": []}


## Đọc quy tắc từ save (thiếu / sai khoá thì lấy mặc định).
static func normalize_rules(r) -> Dictionary:
	var out := default_rules()
	if not (r is Dictionary):
		return out
	if str(r.get("mode", "")) in LOOT_MODES:
		out.mode = str(r.mode)
	var br = r.get("by_rarity", {})
	if br is Dictionary:
		for k in LOOT_RARITIES:
			if str(br.get(k, "")) in LOOT_ACTIONS:
				out.by_rarity[k] = str(br[k])
	for k in ["keep_plus", "keep_set", "keep_better"]:
		if r.has(k):
			out[k] = bool(r[k])
	if r.has("keep_level_gap"):
		out.keep_level_gap = clampi(int(r.keep_level_gap), -1, LOOT_GAP_MAX)
	var bs = r.get("by_slot", {})
	if bs is Dictionary:
		for sl in ItemData.SLOT_ORDER:
			if str(bs.get(sl, "")) in LOOT_SLOT_ACTIONS:
				out.by_slot[sl] = str(bs[sl])
	var ks = r.get("keep_stats", [])
	if ks is Array:
		for st in ks:
			if ItemData.AFFIXES.has(str(st)) and not (str(st) in out.keep_stats):
				out.keep_stats.append(str(st))
	return out


## Số quy tắc nâng cao đang bật (ô ghi đè + dòng chỉ số luôn giữ).
static func rules_advanced_count(r: Dictionary) -> int:
	var n: int = r.keep_stats.size()
	for sl in r.by_slot:
		if str(r.by_slot[sl]) != "rule":
			n += 1
	return n


## Hạng so sánh món cùng loại: phẩm chất → cấp → cường hoá.
static func _rank(item: Dictionary) -> Array:
	return [ItemData.RARITY_ORDER.find(str(item.rarity)), int(item.level), int(item.plus)]


## TD-16 (U2): đã có món khác cùng bộ + cùng ô mà hạng ≥ món này (bằng nhau thì món id nhỏ hơn được giữ).
static func set_duplicate(p, item: Dictionary) -> bool:
	var sid := str(item.get("set", ""))
	if sid == "":
		return false
	var others: Array = p.inventory.duplicate()
	others.append_array(p.equipment.values())
	var me := _rank(item)
	for o in others:
		if int(o.id) == int(item.id) or str(o.get("set", "")) != sid or str(o.slot) != str(item.slot):
			continue
		var ro := _rank(o)
		if ro > me or (ro == me and int(o.id) < int(item.id)):
			return true
	return false


## TD-15 (U1): sắp xếp túi. mode: "rarity" (phẩm chất cao trước) | "slot" (theo ô) | "power" (power: Callable(item) -> int,
## Lực chiến khi mặc, cao trước). Món khoá luôn đứng đầu; hoà thì theo id.
const SORT_MODES := {"rarity": "Phẩm chất", "slot": "Ô trang bị", "power": "Lực chiến"}


static func sort_bag(p, mode: String, power := Callable()) -> void:
	var pw := {}
	if mode == "power" and power.is_valid():
		for it in p.inventory:
			pw[int(it.id)] = int(power.call(it))
	var key := func(it: Dictionary) -> Array:
		var rar := -ItemData.RARITY_ORDER.find(str(it.rarity))
		var slot := ItemData.SLOT_ORDER.find(str(it.slot))
		var k: Array = [0 if is_locked(it) else 1]
		match mode:
			"slot":
				k.append_array([slot, rar, -int(it.level)])
			"power":
				k.append_array([-int(pw.get(int(it.id), 0)), rar, slot])
			_:
				k.append_array([rar, slot, -int(it.level)])
		k.append_array([-int(it.plus), int(it.id)])
		return k
	p.inventory.sort_custom(func(a, b): return key.call(a) < key.call(b))


## Mẫu đang khớp với bảng phẩm chất ("" = tuỳ chỉnh).
static func rules_preset(r: Dictionary) -> String:
	for k in LOOT_PRESETS:
		if LOOT_PRESETS[k][1] == r.by_rarity:
			return k
	return ""


static func rules_all_keep(r: Dictionary) -> bool:
	for k in LOOT_RARITIES:
		if str(r.by_rarity.get(k, "keep")) != "keep":
			return false
	return true


## CR-04.3: "keep" | "sell" | "salvage" cho một món. better: Callable(item) -> bool (mặc vào Lực chiến tăng);
## bỏ trống = bỏ qua điều kiện "giữ đồ mạnh hơn". Thứ tự: khoá / Cam → bảng phẩm chất → các ngoại lệ luôn giữ.
static func decide(p, item: Dictionary, r: Dictionary, better := Callable()) -> String:
	if is_locked(item) or not (str(item.rarity) in LOOT_RARITIES):
		return "keep"
	# TD-17 (U3): luôn giữ đồ có dòng chỉ số đã chọn; ô ghi đè bảng phẩm chất.
	for af in item.get("affixes", []):
		if str(af.stat) in r.get("keep_stats", []):
			return "keep"
	var act := str(r.get("by_slot", {}).get(str(item.slot), "rule"))
	if act == "rule":
		act = str(r.by_rarity.get(str(item.rarity), "keep"))
	if act == "keep":
		return "keep"
	if r.keep_plus and int(item.plus) > 0:
		return "keep"
	# TD-16 (U2): giữ đồ bộ — trừ khi đã có món cùng bộ, cùng ô, tốt hơn hoặc bằng (túi / đang mặc).
	if r.keep_set and str(item.get("set", "")) != "" and not set_duplicate(p, item):
		return "keep"
	if int(r.keep_level_gap) >= 0 and int(item.level) >= int(p.level) - int(r.keep_level_gap):
		return "keep"
	if r.keep_better and better.is_valid() and bool(better.call(item)):
		return "keep"
	return act


# ------------------------------------------------------------------ hiển thị


## Spec_Notes N8: bậc hiệu ứng theo cấp cường hoá — 0 (+0…+3) · 1 (+4…+6) · 2 (+7…+9) · 3 (+10…+12) · 4 (+13…+15).
## EN-1 (docs/43): bạc → lam băng → vàng kim → huyết hồng — tách khỏi thang màu phẩm chất (lam / tím cũ dễ nhầm)
const ENHANCE_TIER_HEX := ["", "#cde4ff", "#5ad2ff", "#ffce50", "#ff4660"]


static func enhance_tier(plus: int) -> int:
	return clampi(int((plus - 1) / 3), 0, 4) if plus >= 4 else 0


static func enhance_color(plus: int) -> Color:
	var t := enhance_tier(plus)
	return Color(ENHANCE_TIER_HEX[t]) if t > 0 else Color(1, 1, 1, 0)


static func _type_name(item: Dictionary) -> String:
	match str(item.get("style", "")):
		"bow":
			return "Cung"
		"staff":
			return "Trượng"
		"mace":
			return "Chùy"
		"orb":
			return "Linh Châu"
	return str(ItemData.SLOTS[item.slot].item)


static func display_name(item: Dictionary) -> String:
	var name: String
	if item.unique != "":
		name = ItemData.UNIQUES[item.unique].name
	elif item.set != "":
		name = "%s %s" % [_type_name(item), ItemData.SETS[item.set].suffix]
	else:
		name = "%s %s" % [_type_name(item), ItemData.RARITIES[item.rarity].prefix]
	if int(item.plus) > 0:
		name += " +%d" % int(item.plus)
	return name


static func rarity_color(item: Dictionary) -> Color:
	return Color(ItemData.RARITIES[item.rarity].color)


## SN9-07 (Spec_Notes đợt 9: "9 + 15 Tấn công (gốc)"): chỉ số gốc tách phần gốc và phần cường hoá.
## plus < 0 = cấp cường hoá hiện tại của món. Đồ +0: "+9 Tấn công". Phần "+ 15" tô xanh khi bbcode = true.
static func base_text(item: Dictionary, plus := -1, bbcode := false) -> String:
	var p: int = int(item.plus) if plus < 0 else plus
	var stat := base_stat(item)
	var raw := base_value(item, 0)
	var bonus := base_value(item, p) - raw
	if p <= 0:
		return stat_text(stat, raw)
	var label: String = ItemData.AFFIXES[stat].name
	var pct: bool = stat in ItemData.PERCENT_STATS
	var a := ("+%.1f%%" % (raw * 100.0)) if pct else ("+%d" % roundi(raw))
	var b := ("%.1f%%" % (bonus * 100.0)) if pct else ("%d" % (roundi(base_value(item, p)) - roundi(raw)))
	if bbcode:
		return "%s [color=#5bd16a]+ %s[/color] %s" % [a, b, label]
	return "%s + %s %s" % [a, b, label]


static func stat_text(stat: String, value: float) -> String:
	var label: String = ItemData.AFFIXES[stat].name
	if stat in ItemData.PERCENT_STATS:
		return "+%.1f%% %s" % [value * 100.0, label]
	return "+%d %s" % [roundi(value), label]
