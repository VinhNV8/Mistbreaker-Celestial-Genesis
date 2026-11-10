extends RefCounted
## NL-1 (docs/47): các đường tăng Lực chiến cho trang bị ngoài cường hoá — logic thuần (test headless được).
## A Khảm Ngọc Ngũ Hành · B Tẩy Luyện · C Thăng Phẩm · D Luyện Cấp đồ Cam / bộ · E Thức Tỉnh · F Bảo Giám.
## Chỉ số ngọc / ấn hệ / Thức Tỉnh cộng vào nhân vật ở Items.item_stats + Items.equipment_bonus → GameWorld._derive.
## Mọi thao tác luôn thành công (không phạt — EQ-12), thiếu nguyên liệu thì từ chối và không trừ gì.
## Các hàm nhận `p` là Profile.

const ItemData = preload("res://scripts/data/items.gd")
const GearData = preload("res://scripts/data/gear_data.gd")
const Items = preload("res://scripts/core/items.gd")
const Talents = preload("res://scripts/data/talents.gd")
const TalentSlots = preload("res://scripts/core/talent_slots.gd")
const RngUtil = preload("res://scripts/core/rng_util.gd")


static func _result(ok: bool, message: String, extra := {}) -> Dictionary:
	var r := {"ok": ok, "message": message}
	r.merge(extra)
	return r


# ------------------------------------------------------------------ mở khoá (Q230)


## Vùng cao nhất đã mở (unlocked_maps dạng "R-x").
static func max_region(p) -> int:
	var best := 1
	for m in p.unlocked_maps:
		var head := str(m).split("-")[0]
		if head.is_valid_int():
			best = maxi(best, int(head))
	return best


static func unlocked(p, feature: String) -> bool:
	if feature == "awaken":
		return str(p.job3) != ""
	if feature == "codex":
		return true
	return max_region(p) >= int(GearData.UNLOCK_REGION.get(feature, 1))


static func lock_text(feature: String) -> String:
	if feature == "awaken":
		return "Mở sau khi chuyển chức 3."
	return "Mở khi tới chương %d." % int(GearData.UNLOCK_REGION.get(feature, 1))


# ------------------------------------------------------------------ A. Ngọc Ngũ Hành


static func gem_name(key: String) -> String:
	var pr := Items.gem_parse(key)
	return "%s cấp %d" % [GearData.GEM_NAMES.get(pr[0], pr[0]), int(pr[1])]


## Icon: cấp 1–3 tròn, 4–6 lục lăng, 7–10 giọt nước.
static func gem_icon_id(key: String) -> String:
	var pr := Items.gem_parse(key)
	return "gem-%s-%d" % [pr[0], 1 if int(pr[1]) <= 3 else (2 if int(pr[1]) <= 6 else 3)]


static func gem_count(p, key: String) -> int:
	return int(p.gem_bag.get(key, 0))


static func gem_add(p, key: String, n := 1) -> void:
	var c := gem_count(p, key) + n
	if c > 0:
		p.gem_bag[key] = c
	else:
		p.gem_bag.erase(key)
	if n > 0:
		var pr := Items.gem_parse(key)
		if GearData.CODEX_GEM.has(int(pr[1])):
			Items.codex_add(p, "g:%s:%d" % [pr[0], int(pr[1])])


## Danh sách ngọc trong túi, sắp theo hệ rồi cấp giảm dần: [[key, count], …].
static func gem_list(p) -> Array:
	var out: Array = []
	for k in p.gem_bag:
		if int(p.gem_bag[k]) > 0:
			out.append([str(k), int(p.gem_bag[k])])
	out.sort_custom(func(a, b):
		var pa := Items.gem_parse(a[0])
		var pb := Items.gem_parse(b[0])
		var ea := GearData.ELEMENTS.find(pa[0])
		var eb := GearData.ELEMENTS.find(pb[0])
		return ea < eb or (ea == eb and int(pa[1]) > int(pb[1])))
	return out


static func gem_total(p) -> int:
	var n := 0
	for k in p.gem_bag:
		n += int(p.gem_bag[k])
	return n


## Ghép 3 viên cùng loại cùng cấp → 1 viên cấp sau.
static func combine(p, key: String) -> Dictionary:
	var pr := Items.gem_parse(key)
	if int(pr[1]) >= GearData.GEM_MAX_LV:
		return _result(false, "Ngọc đã đạt cấp tối đa.")
	if gem_count(p, key) < GearData.GEM_COMBINE:
		return _result(false, "Cần %d viên %s." % [GearData.GEM_COMBINE, gem_name(key)])
	gem_add(p, key, -GearData.GEM_COMBINE)
	var nk := Items.gem_key(pr[0], int(pr[1]) + 1)
	gem_add(p, nk, 1)
	return _result(true, "Ghép thành công: %s." % gem_name(nk), {"gem": nk})


## Ghép tất cả từ cấp thấp lên (một lượt tới khi không ghép được nữa).
static func combine_all(p) -> Dictionary:
	var made := 0
	for lv in range(1, GearData.GEM_MAX_LV):
		for el in GearData.ELEMENTS:
			var k := Items.gem_key(el, lv)
			while gem_count(p, k) >= GearData.GEM_COMBINE:
				combine(p, k)
				made += 1
	if made == 0:
		return _result(false, "Chưa có bộ 3 viên cùng loại cùng cấp nào.")
	return _result(true, "Ghép %d lần." % made, {"count": made})


## Số lần ghép làm được ngay.
static func combinable(p) -> int:
	var n := 0
	for k in p.gem_bag:
		if int(Items.gem_parse(str(k))[1]) < GearData.GEM_MAX_LV:
			n += int(int(p.gem_bag[k]) / GearData.GEM_COMBINE)
	return n


static func free_sockets(item: Dictionary) -> int:
	return maxi(0, int(item.get("sockets", 0)) - Array(item.get("gems", [])).size())


static func socket_blocker(p, item: Dictionary, key: String) -> String:
	if not unlocked(p, "gems"):
		return lock_text("gems")
	if free_sockets(item) <= 0:
		return "Món này không còn lỗ trống (đục thêm lỗ ở dưới)."
	if gem_count(p, key) <= 0:
		return "Không có %s trong Túi Ngọc." % gem_name(key)
	return ""


static func socket(p, id: int, key: String) -> Dictionary:
	var found := Items.find_item(p, id)
	if found.is_empty():
		return _result(false, "Không tìm thấy món đồ.")
	var item: Dictionary = found.item
	var b := socket_blocker(p, item, key)
	if b != "":
		return _result(false, b)
	gem_add(p, key, -1)
	item.gems.append(key)
	var msg := "Khảm %s vào %s." % [gem_name(key), Items.display_name(item)]
	if item.slot == "weapon":
		var seal := Items.weapon_seal({"weapon": item})
		if seal != "":
			msg += " Ấn hệ %s!" % GearData.GEM_NAMES[seal].replace(" Ngọc", "")
	return _result(true, msg)


static func unsocket_cost(key: String) -> int:
	return GearData.UNSOCKET_GOLD * int(Items.gem_parse(key)[1])


static func unsocket(p, id: int, idx: int) -> Dictionary:
	var found := Items.find_item(p, id)
	if found.is_empty():
		return _result(false, "Không tìm thấy món đồ.")
	var item: Dictionary = found.item
	if idx < 0 or idx >= item.gems.size():
		return _result(false, "Lỗ này trống.")
	var key := str(item.gems[idx])
	var cost := unsocket_cost(key)
	if p.gold < cost:
		return _result(false, "Cần %d vàng để tháo." % cost)
	p.gold -= cost
	item.gems.remove_at(idx)
	gem_add(p, key, 1)
	return _result(true, "Tháo %s về Túi Ngọc (−%d vàng). Ngọc không vỡ." % [gem_name(key), cost])


static func punch_cost(item: Dictionary) -> Dictionary:
	return {"gold": GearData.PUNCH_GOLD * (int(item.get("sockets", 0)) + 1), "tinh_kim": GearData.PUNCH_TINH_KIM}


static func punch_blocker(p, item: Dictionary) -> String:
	if not unlocked(p, "gems"):
		return lock_text("gems")
	if int(item.get("sockets", 0)) >= GearData.MAX_SOCKETS:
		return "Đã đủ %d lỗ." % GearData.MAX_SOCKETS
	var c := punch_cost(item)
	if p.gold < c.gold:
		return "Cần %d vàng." % c.gold
	if p.tinh_kim < c.tinh_kim:
		return "Cần %d Tinh Kim." % c.tinh_kim
	return ""


static func punch(p, id: int) -> Dictionary:
	var found := Items.find_item(p, id)
	if found.is_empty():
		return _result(false, "Không tìm thấy món đồ.")
	var item: Dictionary = found.item
	var b := punch_blocker(p, item)
	if b != "":
		return _result(false, b)
	var c := punch_cost(item)
	p.gold -= c.gold
	p.tinh_kim -= c.tinh_kim
	item.sockets = int(item.get("sockets", 0)) + 1
	return _result(true, "Đục thêm lỗ: %s có %d lỗ ngọc." % [Items.display_name(item), int(item.sockets)])


## Rơi ngọc khi hạ quái (gọi từ GameWorld._drop_loot). role: field / elite / boss / rare. Trả về danh sách key.
static func roll_drop(p, el: String, role: String, elite: bool, rng: Callable) -> Array:
	if not unlocked(p, "gems") or not (el in GearData.ELEMENTS):
		return []
	var out: Array = []
	if role == "boss" or role == "rare":
		out.append(Items.gem_key(el, GearData.GEM_BOSS_LV))
		out.append(Items.gem_key(GearData.ELEMENTS[int(float(rng.call()) * 5.0) % 5], 1))
	elif elite:
		if float(rng.call()) < GearData.GEM_DROP_ELITE:
			out.append(Items.gem_key(el, 1 if float(rng.call()) < 0.6 else 2))
	elif float(rng.call()) < GearData.GEM_DROP_FIELD:
		out.append(Items.gem_key(el, 1))
	for k in out:
		gem_add(p, k, 1)
	return out


## Phần thưởng ngọc ngẫu nhiên hệ (cổng dungeon, rương uỷ thác). Trả về key hoặc "".
static func grant_random(p, lv: int, rng: Callable) -> String:
	if not unlocked(p, "gems") or lv <= 0:
		return ""
	var k := Items.gem_key(GearData.ELEMENTS[int(float(rng.call()) * 5.0) % 5], lv)
	gem_add(p, k, 1)
	return k


# ------------------------------------------------------------------ B. Tẩy Luyện


static func reforge_mult(item: Dictionary) -> float:
	return minf(GearData.REFORGE_GROWTH_MAX, pow(GearData.REFORGE_GROWTH, int(item.get("reforges", 0))))


static func reforge_cost(item: Dictionary, mode: String) -> Dictionary:
	var c: Dictionary = GearData.REFORGE[mode]
	var k := reforge_mult(item)
	return {
		"gold": roundi(float(c.gold) * maxi(1, int(item.level)) * k),
		"crystal": ceili(float(c.crystal) * k) if int(c.crystal) > 0 else 0,
		"tinh_kim": ceili(float(c.tinh_kim) * k) if int(c.tinh_kim) > 0 else 0,
	}


## Dòng tẩy được: dòng đã tẩy (cố định, Q232) hoặc mọi dòng nếu chưa tẩy lần nào.
static func reforge_allowed(item: Dictionary, idx: int) -> bool:
	var r := int(item.get("reforged", -1))
	return idx >= 0 and idx < item.affixes.size() and (r < 0 or r == idx)


static func reforge_blocker(p, item: Dictionary, idx: int, mode: String) -> String:
	if not unlocked(p, "reforge"):
		return lock_text("reforge")
	if item.affixes.is_empty():
		return "Món này không có dòng phụ."
	if not reforge_allowed(item, idx):
		return "Mỗi món chỉ tẩy được 1 dòng — dòng ✦ đã chọn trước đó."
	if mode == "swap" and _swap_pool(item, idx).is_empty():
		return "Không còn loại dòng nào khác cho ô này."
	var c := reforge_cost(item, mode)
	if p.gold < c.gold:
		return "Cần %d vàng." % c.gold
	if float(p.crystal) < c.crystal:
		return "Cần %d Tinh Thạch." % c.crystal
	if p.tinh_kim < c.tinh_kim:
		return "Cần %d Tinh Kim." % c.tinh_kim
	return ""


static func _swap_pool(item: Dictionary, idx: int) -> Array:
	var used: Array = item.affixes.map(func(a): return str(a.stat))
	var slot := str(item.slot)
	return ItemData.AFFIXES.keys().filter(func(k): return not (k in used) and slot in ItemData.AFFIXES[k].get("slots", [slot]))


static func affix_roll(stat: String, level: int, rng: Callable) -> float:
	var a: Dictionary = ItemData.AFFIXES[stat]
	return (float(a.a) + float(a.b) * level) * (0.8 + float(rng.call()) * 0.4)


## Quay 1 dòng. Kết quả chờ người chơi chọn: item["reforge_pending"] = {idx, af}; gọi reforge_keep để chốt.
static func reforge(p, id: int, idx: int, mode: String, rng: Callable) -> Dictionary:
	var found := Items.find_item(p, id)
	if found.is_empty():
		return _result(false, "Không tìm thấy món đồ.")
	var item: Dictionary = found.item
	var b := reforge_blocker(p, item, idx, mode)
	if b != "":
		return _result(false, b)
	var c := reforge_cost(item, mode)
	p.gold -= c.gold
	p.crystal = float(p.crystal) - c.crystal
	p.tinh_kim -= c.tinh_kim
	item.reforged = idx
	item.reforges = int(item.get("reforges", 0)) + 1
	var stat := str(item.affixes[idx].stat)
	if mode == "swap":
		var pool := RngUtil.shuffle(_swap_pool(item, idx), rng)
		stat = str(pool[0])
	var af := {"stat": stat, "value": affix_roll(stat, int(item.level), rng)}
	item["reforge_pending"] = {"idx": idx, "af": af}
	return _result(true, "Dòng mới: %s — giữ dòng cũ hay lấy dòng mới?" % Items.stat_text(stat, af.value), {"old": item.affixes[idx], "new": af})


## Chốt lần tẩy: take_new = lấy dòng mới; false = giữ dòng cũ (chỉ mất nguyên liệu).
static func reforge_keep(p, id: int, take_new: bool) -> Dictionary:
	var found := Items.find_item(p, id)
	if found.is_empty():
		return _result(false, "Không tìm thấy món đồ.")
	var item: Dictionary = found.item
	var pend: Dictionary = item.get("reforge_pending", {})
	if pend.is_empty():
		return _result(false, "Không có kết quả tẩy nào đang chờ.")
	item.erase("reforge_pending")
	if take_new:
		item.affixes[int(pend.idx)] = pend.af
		return _result(true, "Đã lấy dòng mới: %s." % Items.stat_text(pend.af.stat, pend.af.value))
	return _result(true, "Giữ dòng cũ.")


# ------------------------------------------------------------------ C. Thăng Phẩm


static func can_ascend_rarity(item: Dictionary) -> bool:
	return GearData.ASCEND.has(str(item.rarity)) and str(item.get("set", "")) == "" and str(item.get("unique", "")) == ""


## Món trong túi làm nguyên liệu được: cùng ô, cùng phẩm chất, cấp ≥ L − 5, không khoá, không phải chính nó.
static func ascend_materials(p, item: Dictionary) -> Array:
	return p.inventory.filter(func(x): return int(x.id) != int(item.id) and str(x.slot) == str(item.slot) \
		and str(x.rarity) == str(item.rarity) and int(x.level) >= int(item.level) - GearData.ASCEND_GAP and not Items.is_locked(x))


static func ascend_cost(item: Dictionary) -> Dictionary:
	var c: Dictionary = GearData.ASCEND.get(str(item.rarity), {})
	if c.is_empty():
		return {}
	return {"gold": int(c.gold) * maxi(1, int(item.level)), "crystal": int(c.crystal), "tinh_kim": int(c.tinh_kim), "to": str(c.to)}


static func ascend_blocker(p, item: Dictionary, mat_id := -1) -> String:
	if not unlocked(p, "ascend"):
		return lock_text("ascend")
	if str(item.rarity) == "purple" or str(item.rarity) == "orange":
		return "Đã ở bậc cao nhất có thể thăng (Tím). Đồ Cam chỉ rơi từ boss."
	if str(item.get("set", "")) != "":
		return "Đồ bộ không thăng phẩm."
	if not can_ascend_rarity(item):
		return "Đồ Trắng không thăng phẩm được."
	var mats := ascend_materials(p, item)
	if mats.is_empty():
		return "Cần 1 món %s cùng ô %s, cấp ≥ %d trong túi (không khoá)." % [ItemData.RARITIES[item.rarity].name,
			ItemData.SLOTS[item.slot].name, maxi(1, int(item.level) - GearData.ASCEND_GAP)]
	if mat_id >= 0 and mats.filter(func(x): return int(x.id) == mat_id).is_empty():
		return "Món nguyên liệu không hợp lệ."
	var c := ascend_cost(item)
	if p.gold < c.gold:
		return "Cần %d vàng." % c.gold
	if float(p.crystal) < c.crystal:
		return "Cần %d Tinh Thạch." % c.crystal
	if p.tinh_kim < c.tinh_kim:
		return "Cần %d Tinh Kim." % c.tinh_kim
	return ""


## Thăng phẩm: hút mat_id, món chính lên 1 bậc, thêm 1 dòng ngẫu nhiên + lỗ ngọc theo bảng. Giữ cường hoá, ngọc, dòng cũ.
## take_plus: món nguyên liệu cường hoá cao hơn thì chuyển +N sang món chính (giống SN-20).
static func ascend(p, id: int, mat_id: int, rng: Callable, take_plus := true) -> Dictionary:
	var found := Items.find_item(p, id)
	if found.is_empty():
		return _result(false, "Không tìm thấy món đồ.")
	var item: Dictionary = found.item
	var b := ascend_blocker(p, item, mat_id)
	if b != "":
		return _result(false, b)
	var c := ascend_cost(item)
	var mi := Items.find_in_bag(p, mat_id)
	var mat: Dictionary = p.inventory[mi]
	p.inventory.remove_at(mi)
	p.gold -= c.gold
	p.crystal = float(p.crystal) - c.crystal
	p.tinh_kim -= c.tinh_kim
	var back := Items.strip_gems(p, mat)
	var moved := 0
	if take_plus and int(mat.plus) > int(item.plus):
		moved = int(mat.plus)
		item.plus = moved
	var old_rarity := str(item.rarity)
	item.rarity = str(c.to)
	var pool := RngUtil.shuffle(_swap_pool(item, -1), rng)
	if not pool.is_empty():
		var stat := str(pool[0])
		item.affixes.append({"stat": stat, "value": affix_roll(stat, int(item.level), rng)})
	var want := int(GearData.SOCKETS.get(item.rarity, 0)) - int(GearData.SOCKETS.get(old_rarity, 0))
	item.sockets = mini(GearData.MAX_SOCKETS, int(item.get("sockets", 0)) + maxi(0, want))
	var msg := "Thăng phẩm thành công: %s." % Items.display_name(item)
	if moved > 0:
		msg += " Nhận +%d từ món nguyên liệu." % moved
	if back > 0:
		msg += " %d viên ngọc của món nguyên liệu về Túi Ngọc." % back
	return _result(true, msg)


# ------------------------------------------------------------------ D. Luyện Cấp đồ Cam / đồ bộ


static func can_levelup_kind(item: Dictionary) -> bool:
	return str(item.rarity) == "orange" or str(item.get("set", "")) != ""


static func levelup_cost(item: Dictionary) -> Dictionary:
	var L := maxi(1, int(item.level))
	return {"gold": GearData.LEVELUP_GOLD * L, "tinh_kim": 1 + int(L / GearData.LEVELUP_TK_PER)}


static func levelup_target(p, item: Dictionary) -> int:
	return mini(int(p.level), int(item.level) + GearData.LEVELUP_STEP)


static func levelup_blocker(p, item: Dictionary) -> String:
	if not unlocked(p, "levelup"):
		return lock_text("levelup")
	if not can_levelup_kind(item):
		return "Chỉ luyện cấp được đồ Cam và đồ bộ."
	if int(item.level) >= int(p.level):
		return "Món đã bằng cấp nhân vật (%d)." % int(p.level)
	var c := levelup_cost(item)
	if p.gold < c.gold:
		return "Cần %d vàng." % c.gold
	if p.tinh_kim < c.tinh_kim:
		return "Cần %d Tinh Kim." % c.tinh_kim
	return ""


## Nâng cấp đồ +5 (tối đa cấp nhân vật): chỉ số gốc + dòng phụ tính lại theo cấp mới, giữ hệ số ngẫu nhiên đã quay.
static func levelup(p, id: int) -> Dictionary:
	var found := Items.find_item(p, id)
	if found.is_empty():
		return _result(false, "Không tìm thấy món đồ.")
	var item: Dictionary = found.item
	var b := levelup_blocker(p, item)
	if b != "":
		return _result(false, b)
	var c := levelup_cost(item)
	p.gold -= c.gold
	p.tinh_kim -= c.tinh_kim
	var L0 := int(item.level)
	var L1 := levelup_target(p, item)
	for af in item.affixes:
		var a: Dictionary = ItemData.AFFIXES.get(str(af.stat), {})
		if a.is_empty():
			continue
		var base0 := float(a.a) + float(a.b) * L0
		var roll := float(af.value) / base0 if base0 > 0.0 else 1.0
		af.value = roll * (float(a.a) + float(a.b) * L1)
	item.level = L1
	return _result(true, "Luyện cấp: %s lên cấp %d." % [Items.display_name(item), L1])


# ------------------------------------------------------------------ E. Thức Tỉnh


static func _groups(p) -> Array:
	return TalentSlots.ids(p).map(func(id): return str(Talents.get_talent(id).group))


## Bể dòng theo lớp + nhóm Thiên phú (dòng chung luôn có).
static func awaken_pool(p) -> Array:
	var groups := _groups(p)
	var cls := str(p.class_id)
	var out: Array = []
	for id in GearData.AWAKEN_LINES:
		var ln: Dictionary = GearData.AWAKEN_LINES[id]
		var cs: Array = ln.get("classes", [])
		var gs: Array = ln.get("groups", [])
		if cs.is_empty() and gs.is_empty():
			out.append(id)
		elif cls in cs or gs.any(func(g): return g in groups):
			out.append(id)
	return out


static func awaken_next_cost(item: Dictionary) -> Dictionary:
	var aw: Dictionary = item.get("awaken", {})
	var t := int(aw.get("tier", 0)) if str(aw.get("id", "")) != "" else 0
	if t >= GearData.AWAKEN_MAX_TIER:
		return {}
	return {"essence": int(GearData.AWAKEN_ESSENCE[t]), "void": int(GearData.AWAKEN_VOID[t])}


static func awaken_blocker(p, item: Dictionary) -> String:
	if not unlocked(p, "awaken"):
		return lock_text("awaken")
	if not (str(item.rarity) in GearData.AWAKEN_RARITIES):
		return "Chỉ đồ Tím / Cam thức tỉnh được."
	if int(item.plus) < GearData.AWAKEN_MIN_PLUS:
		return "Cần cường hoá +%d trở lên." % GearData.AWAKEN_MIN_PLUS
	var c := awaken_next_cost(item)
	if c.is_empty():
		return "Đã đạt bậc %d tối đa." % GearData.AWAKEN_MAX_TIER
	if not Array(item.get("awaken", {}).get("offer", [])).is_empty():
		return "Hãy chọn 1 dòng Thức Tỉnh trước."
	if int(p.essence) < c.essence:
		return "Cần %d Thiên Phú Tinh Hoa." % c.essence
	if int(p.void_cores) < c.void:
		return "Cần %d Lõi Hư Vô." % c.void
	return ""


static func _offer(p, exclude: String, rng: Callable) -> Array:
	var pool := awaken_pool(p).filter(func(x): return x != exclude)
	pool = RngUtil.shuffle(pool, rng)
	return pool.slice(0, GearData.AWAKEN_OFFER)


## Mở (bậc 0 → chọn 1 trong 3) hoặc nâng bậc. Trả về {ok, offer?}.
static func awaken(p, id: int, rng: Callable) -> Dictionary:
	var found := Items.find_item(p, id)
	if found.is_empty():
		return _result(false, "Không tìm thấy món đồ.")
	var item: Dictionary = found.item
	var b := awaken_blocker(p, item)
	if b != "":
		return _result(false, b)
	var c := awaken_next_cost(item)
	p.essence -= c.essence
	p.void_cores -= c.void
	var aw: Dictionary = item.get("awaken", {})
	if aw.is_empty() or str(aw.get("id", "")) == "":
		item.awaken = {"id": "", "tier": 0, "spent": int(c.essence), "offer": _offer(p, "", rng)}
		return _result(true, "Thức Tỉnh %s — chọn 1 trong %d dòng." % [Items.display_name(item), item.awaken.offer.size()], {"offer": item.awaken.offer})
	aw.tier = int(aw.tier) + 1
	aw.spent = int(aw.get("spent", 0)) + int(c.essence)
	return _result(true, "Thức Tỉnh bậc %d: %s." % [int(aw.tier), Items.awaken_text(str(aw.id), int(aw.tier))])


## Chọn dòng trong lượt rút đang chờ. Lần đầu → bậc 1; đổi dòng → giữ bậc.
static func awaken_choose(p, id: int, line: String) -> Dictionary:
	var found := Items.find_item(p, id)
	if found.is_empty():
		return _result(false, "Không tìm thấy món đồ.")
	var aw: Dictionary = found.item.get("awaken", {})
	var offer: Array = aw.get("offer", [])
	if not (line in offer):
		return _result(false, "Dòng này không có trong lượt rút.")
	aw.id = line
	aw.tier = maxi(1, int(aw.get("tier", 0)))
	aw.offer = []
	return _result(true, "Thức Tỉnh: %s." % Items.awaken_text(line, int(aw.tier)))


static func awaken_reroll_cost(item: Dictionary) -> int:
	return ceili(float(item.get("awaken", {}).get("spent", 0)) * GearData.AWAKEN_REROLL_PCT)


static func awaken_reroll(p, id: int, rng: Callable) -> Dictionary:
	var found := Items.find_item(p, id)
	if found.is_empty():
		return _result(false, "Không tìm thấy món đồ.")
	var item: Dictionary = found.item
	var aw: Dictionary = item.get("awaken", {})
	if str(aw.get("id", "")) == "":
		return _result(false, "Món chưa có dòng Thức Tỉnh.")
	if not Array(aw.get("offer", [])).is_empty():
		return _result(false, "Hãy chọn 1 dòng trong lượt rút đang chờ.")
	var cost := awaken_reroll_cost(item)
	if int(p.essence) < cost:
		return _result(false, "Cần %d Thiên Phú Tinh Hoa." % cost)
	p.essence -= cost
	aw.offer = _offer(p, str(aw.id), rng)
	aw.offer.append(str(aw.id))
	return _result(true, "Đổi dòng Thức Tỉnh — chọn dòng mới (hoặc giữ dòng cũ), bậc giữ nguyên.", {"offer": aw.offer})


# ------------------------------------------------------------------ F. Bảo Giám


## Danh mục: [{key, kind, name, points, have}] — kind: set / unique / plus / gem.
static func codex_entries(p) -> Array:
	var out: Array = []
	for set_id in ItemData.SETS:
		for slot in ItemData.SLOT_ORDER:
			var k := "s:%s:%s" % [set_id, slot]
			out.append({"key": k, "kind": "set", "group": set_id, "slot": slot, "name": "%s · %s" % [ItemData.SETS[set_id].name, ItemData.SLOTS[slot].name],
				"points": GearData.CODEX_SET_PIECE, "have": p.codex.has(k)})
	for u in ItemData.UNIQUES:
		var k := "u:%s" % u
		out.append({"key": k, "kind": "unique", "group": u, "slot": str(ItemData.UNIQUES[u].slot), "name": str(ItemData.UNIQUES[u].name),
			"points": GearData.CODEX_UNIQUE, "have": p.codex.has(k)})
	for slot in ItemData.SLOT_ORDER:
		for t in GearData.CODEX_PLUS:
			var k := "p:%s:%d" % [slot, int(t)]
			out.append({"key": k, "kind": "plus", "group": slot, "slot": slot, "name": "%s +%d" % [ItemData.SLOTS[slot].name, int(t)],
				"points": int(GearData.CODEX_PLUS[t]), "have": p.codex.has(k)})
	for el in GearData.ELEMENTS:
		for lv in GearData.CODEX_GEM:
			var k := "g:%s:%d" % [el, int(lv)]
			out.append({"key": k, "kind": "gem", "group": el, "slot": "", "name": "%s cấp %d" % [GearData.GEM_NAMES[el], int(lv)],
				"points": int(GearData.CODEX_GEM[lv]), "have": p.codex.has(k)})
	return out


## Số ô khác nhau đã ghi danh của một bộ.
static func codex_set_count(p, set_id: String) -> int:
	var n := 0
	for slot in ItemData.SLOT_ORDER:
		if p.codex.has("s:%s:%s" % [set_id, slot]):
			n += 1
	return n


## Tính thẳng từ khoá đã ghi danh (không dựng danh mục) + nhớ đệm theo số mục — GameWorld._derive gọi rất thường xuyên.
static var _pts_cache := {}


static func codex_points(p) -> int:
	var key: int = p.get_instance_id()
	var n: int = p.codex.size()
	var hit: Array = _pts_cache.get(key, [])
	if not hit.is_empty() and int(hit[0]) == n:
		return int(hit[1])
	var pts := 0
	var per_set := {}
	for k in p.codex:
		var parts := str(k).split(":")
		match parts[0]:
			"s":
				if ItemData.SETS.has(parts[1]):
					pts += GearData.CODEX_SET_PIECE
					per_set[parts[1]] = int(per_set.get(parts[1], 0)) + 1
			"u":
				if ItemData.UNIQUES.has(parts[1]):
					pts += GearData.CODEX_UNIQUE
			"p":
				pts += int(GearData.CODEX_PLUS.get(int(parts[2]), 0)) if parts.size() > 2 else 0
			"g":
				pts += int(GearData.CODEX_GEM.get(int(parts[2]), 0)) if parts.size() > 2 else 0
	for s in per_set:
		if int(per_set[s]) >= GearData.CODEX_SET_FULL_N:
			pts += GearData.CODEX_SET_FULL
	_pts_cache[key] = [n, pts]
	return pts


static func codex_max_points() -> int:
	var pts := 0
	for set_id in ItemData.SETS:
		pts += ItemData.SLOT_ORDER.size() * GearData.CODEX_SET_PIECE + GearData.CODEX_SET_FULL
	pts += ItemData.UNIQUES.size() * GearData.CODEX_UNIQUE
	for t in GearData.CODEX_PLUS:
		pts += ItemData.SLOT_ORDER.size() * int(GearData.CODEX_PLUS[t])
	for lv in GearData.CODEX_GEM:
		pts += GearData.ELEMENTS.size() * int(GearData.CODEX_GEM[lv])
	return pts


## Thưởng vĩnh viễn theo mốc: {max_hp_pct, atk_pct, def_pct}.
static func codex_bonus(p) -> Dictionary:
	var pts := codex_points(p)
	var out := {"max_hp_pct": 0.0, "atk_pct": 0.0, "def_pct": 0.0}
	for m in GearData.CODEX_MILESTONES:
		if pts >= int(m.at):
			for k in m.bonus:
				out[k] = float(out.get(k, 0.0)) + float(m.bonus[k])
	return out


## Cấp danh hiệu khi đạt mốc (gọi sau mỗi lần ghi danh). Trả về danh hiệu mới hoặc "".
static func codex_titles(p) -> String:
	var pts := codex_points(p)
	for m in GearData.CODEX_MILESTONES:
		if pts >= int(m.at) and m.has("title") and not (str(m.title) in p.titles):
			p.titles.append(str(m.title))
			return str(m.title)
	return ""


# ------------------------------------------------------------------ Gợi ý tăng Lực chiến (docs/47 §5)


## Việc làm được ngay để tăng Lực chiến: [{text, tab, id}] (tab = tab Lò Rèn; id = món liên quan, -1 = không).
static func suggestions(p, limit := 6) -> Array:
	var out: Array = []
	var slots: Array = ItemData.SLOT_ORDER
	if unlocked(p, "gems"):
		# gộp mọi món còn lỗ trống thành 1 dòng
		var names := PackedStringArray()
		var first := -1
		var free_n := 0
		if gem_total(p) > 0:
			for slot in slots:
				var it: Dictionary = p.equipment.get(slot, {})
				if not it.is_empty() and free_sockets(it) > 0:
					names.append(str(ItemData.SLOTS[slot].name))
					free_n += free_sockets(it)
					if first < 0:
						first = int(it.id)
		if first >= 0:
			out.append({"text": "Còn %d lỗ ngọc trống (%s) — Túi Ngọc có %d viên." % [free_n, ", ".join(names), gem_total(p)], "tab": "gems", "id": first})
		var cb := combinable(p)
		if cb > 0:
			out.append({"text": "Ghép được %d lần ngọc (3 viên → 1 viên cấp cao hơn)." % cb, "tab": "gems", "id": -1})
	for slot in slots:
		var it: Dictionary = p.equipment.get(slot, {})
		if it.is_empty():
			continue
		if int(it.plus) < ItemData.MAX_PLUS and Items.enhance_blocker(p, it) == "":
			out.append({"text": "Cường hoá %s lên +%d (đủ nguyên liệu)." % [ItemData.SLOTS[slot].name, int(it.plus) + 1], "tab": "enhance", "id": int(it.id)})
		if unlocked(p, "ascend") and can_ascend_rarity(it) and ascend_blocker(p, it) == "":
			out.append({"text": "%s đủ điều kiện Thăng phẩm lên %s." % [ItemData.SLOTS[slot].name, ItemData.RARITIES[GearData.ASCEND[it.rarity].to].name], "tab": "ascend", "id": int(it.id)})
		if unlocked(p, "levelup") and can_levelup_kind(it) and int(it.level) <= int(p.level) - GearData.LEVELUP_STEP and levelup_blocker(p, it) == "":
			out.append({"text": "Luyện cấp %s (cấp %d → %d)." % [Items.display_name(it), int(it.level), levelup_target(p, it)], "tab": "ascend", "id": int(it.id)})
		if unlocked(p, "awaken") and awaken_blocker(p, it) == "":
			out.append({"text": "%s đủ điều kiện Thức Tỉnh." % ItemData.SLOTS[slot].name, "tab": "awaken", "id": int(it.id)})
		if unlocked(p, "reforge") and int(it.get("reforged", -1)) < 0 and not it.affixes.is_empty() and str(it.rarity) in ["purple", "orange"] \
				and reforge_blocker(p, it, 0, "value") == "":
			out.append({"text": "%s chưa tẩy luyện dòng phụ nào." % ItemData.SLOTS[slot].name, "tab": "reforge", "id": int(it.id)})
	return out.slice(0, limit)
