extends RefCounted
## Logic trang bị: sinh đồ, tính chỉ số, mặc/tháo, cường hoá, phân rã (đặc tả MVP M1).
## Một món đồ là Dictionary:
## {id, slot, rarity, level, plus, set, unique, affixes: [{stat, value}]}
## Các hàm nhận `p` là Profile (không khai báo kiểu để tránh preload vòng tròn).

const ItemData = preload("res://scripts/data/items.gd")
const RngUtil = preload("res://scripts/core/rng_util.gd")
const Talents = preload("res://scripts/data/talents.gd")

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


## Tổng chỉ số một món: {stat: value}.
static func item_stats(item: Dictionary) -> Dictionary:
	var out := {base_stat(item): base_value(item)}
	for af in item.affixes:
		out[af.stat] = out.get(af.stat, 0.0) + float(af.value)
	return out


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
		"move_pct": 0.0, "atk_speed_pct": 0.0, "dodge_cd": 0.0}
	for set_id in sets:
		for tier in ItemData.SETS[set_id].tiers:
			if sets[set_id] >= tier.count:
				for k in tier.bonus:
					bonus[k] += tier.bonus[k]
	return bonus


## 3.8: Lực chiến.
static func combat_power(stats: Dictionary) -> int:
	return int(round(
		stats.atk * 10.0 + stats.max_hp + stats.def * 8.0 + stats.crit * 1000.0
		+ stats.crit_dmg * 300.0 + (stats.atk_speed - 1.0) * 800.0
	))


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
static func add_item(p, item: Dictionary) -> Dictionary:
	if p.inventory.size() >= ItemData.BAG_SIZE:
		var stones := salvage_value(item, p)
		p.stones += stones
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
	var b := Talents.lv_value(0.1, 0.15, p.talent_level) if p.talent == "tho-ren" else 0.0
	if Talents.has_sub(p.talent, p.talent_level, "craft", 2):
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
	if p != null and Talents.has_sub(p.talent, p.talent_level, "craft", 1):
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
		return _result(true, "Cường hoá thành công: %s." % display_name(item), {"success": true})
	return _result(true, "Cường hoá thất bại (%d%%). Món đồ vẫn giữ nguyên +%d." % [roundi(rate * 100.0), int(item.plus)], {"success": false})


## 3.6: đá theo phẩm chất + ⌊cấp cường hoá / 2⌋; nhóm Kinh tế cấp 10 +1.
static func salvage_value(item: Dictionary, p = null) -> int:
	var extra := 1 if p != null and Talents.has_sub(p.talent, p.talent_level, "economy", 2) else 0
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
	var stones := salvage_value(item, p)
	p.inventory.remove_at(i)
	p.stones += stones
	var msg := "Phân rã %s: +%d Đá Cường Hoá." % [display_name(item), stones]
	if p.talent == "ban-tay-vang" and rng.is_valid() and float(rng.call()) < Talents.lv_value(GOLDEN_HAND_CHANCE, 0.3, p.talent_level):
		p.tinh_kim += 1
		msg += " Bàn Tay Vàng: +1 Tinh Kim!"
	return _result(true, msg)


# ------------------------------------------------------------------ hiển thị


## Spec_Notes N8: bậc hiệu ứng theo cấp cường hoá — 0 (+0…+3) · 1 (+4…+6) · 2 (+7…+9) · 3 (+10…+12) · 4 (+13…+15).
const ENHANCE_TIER_HEX := ["", "#4a9df8", "#b36bff", "#ffc940", "#ff5470"]


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


static func stat_text(stat: String, value: float) -> String:
	var label: String = ItemData.AFFIXES[stat].name
	if stat in ItemData.PERCENT_STATS:
		return "+%.1f%% %s" % [value * 100.0, label]
	return "+%d %s" % [roundi(value), label]
