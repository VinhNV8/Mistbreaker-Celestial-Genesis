extends RefCounted
## PV (docs/27): kỹ năng bị động — mỗi lớp 4 bị động mở ở cấp 10 / 20 / 35 / 50, cấp 0–5, nâng bằng Điểm Kỹ Năng
## (dùng chung với kỹ năng chủ động). Bị động luôn có tác dụng, không chiếm ô 1–4. Lưu ở profile.passive_levels {id: cấp}.
## Là một module của Chapters (D38): hook derive_bonus / derive_after / hit_mult / tick; các hook còn lại
## gọi thẳng từ GameWorld (speed_mult, on_evade, absorb, after_hit) và Classes2 (taken_mult, reflect, ally_mult).

const Monsters = preload("res://scripts/data/monsters.gd")

const MAPS := []
const NPCS := []
const HOOKS := ["derive_bonus", "derive_after", "hit_mult", "tick"]

const MAX_LEVEL := 5
const UNLOCKS := [10, 20, 35, 50]
## Ưng Mục: quái xa hơn 15 m. Săn Mồi: quái dưới 50% HP. Chiến Ý: HP dưới 40%. Dồi Dào: MP trên 70%.
const FAR := 150.0
const PREY_HP := 0.5
const RAGE_HP := 0.4
const FULL_MP := 0.7
## Phản Kích: né được đòn → 3 giây tăng sát thương.
const COUNTER_TIME := 3.0
## Linh Hộ: tính tối đa 3 linh thú.
const GUARD_PETS := 3
## Tên Tẩm Độc: dùng tầng độc của Tên Độc (Skills2 TD_STACKS / TD_TIME).
const VENOM_STACKS := 3
const VENOM_TIME := 4.0

## Mỗi bị động: id, tên, icon (assets/icons/<icon>.png), cấp mở, per = giá trị mỗi cấp (mảng), text = mô tả với {0} {1}
## thay bằng per × cấp (phần trăm). Thứ tự trong mảng = thứ tự UNLOCKS.
const DEFS := {
	"kiem-khach": [
		{"id": "thietcot", "name": "Thiết Cốt", "icon": "skill-pv-thietcot", "per": [0.03], "text": "+{0}% HP tối đa."},
		{"id": "kiemtam", "name": "Kiếm Tâm", "icon": "skill-pv-kiemtam", "per": [0.05], "text": "+{0}% sát thương chí mạng."},
		{"id": "phankich", "name": "Phản Kích", "icon": "skill-pv-phankich", "per": [0.06],
			"text": "Né được đòn (né lăn hoặc né tránh): 3 giây sau đó +{0}% sát thương."},
		{"id": "chieny", "name": "Chiến Ý", "icon": "skill-pv-chieny", "per": [0.04, 0.03],
			"text": "HP dưới 40%: +{0}% sát thương và +{1}% tốc đánh."},
	],
	"tho-san": [
		{"id": "ungmuc", "name": "Ưng Mục", "icon": "skill-pv-ungmuc", "per": [0.04], "text": "Quái cách xa hơn 15 m: +{0}% sát thương."},
		{"id": "sanmoi", "name": "Săn Mồi", "icon": "skill-pv-sanmoi", "per": [0.04], "text": "Quái dưới 50% HP: +{0}% sát thương."},
		{"id": "buocgio", "name": "Bước Gió", "icon": "skill-pv-buocgio", "per": [0.02, 0.01],
			"text": "+{0}% tốc chạy, +{1}% né tránh (không vượt trần né của lớp)."},
		{"id": "tamdoc", "name": "Tên Tẩm Độc", "icon": "skill-pv-tamdoc", "per": [0.05],
			"text": "Mỗi đòn trúng có {0}% tỉ lệ thêm 1 tầng độc: mỗi tầng 20% Tấn công mỗi giây, tối đa 3 tầng, 4 giây."},
	],
	"phap-su": [
		{"id": "minhtuong", "name": "Minh Tưởng", "icon": "skill-pv-minhtuong", "per": [0.06], "text": "+{0}% hồi MP."},
		{"id": "nguyento", "name": "Tinh Thông Nguyên Tố", "icon": "skill-pv-nguyento", "per": [0.05],
			"text": "Đòn khắc hệ quái: +{0}% sát thương."},
		{"id": "doidao", "name": "Pháp Lực Dồi Dào", "icon": "skill-pv-doidao", "per": [0.04], "text": "MP trên 70%: +{0}% sát thương."},
		{"id": "hothe", "name": "Hộ Thể Pháp Lực", "icon": "skill-pv-hothe", "per": [0.04],
			"text": "{0}% sát thương nhận vào trừ vào MP thay cho HP (khi còn MP)."},
	],
	"ho-ve": [
		{"id": "kienthu", "name": "Kiên Thủ", "icon": "skill-pv-kienthu", "per": [0.04], "text": "+{0}% Phòng thủ."},
		{"id": "ychisat", "name": "Ý Chí Sắt", "icon": "skill-pv-ychisat", "per": [0.002], "text": "Hồi {0}% HP tối đa mỗi giây."},
		{"id": "phanchan", "name": "Phản Chấn", "icon": "skill-pv-phanchan", "per": [0.06],
			"text": "Bị đánh trúng: phản {0}% sát thương nhận vào lên quái đánh mình."},
		{"id": "uyap", "name": "Uy Áp", "icon": "skill-pv-uyap", "per": [0.03],
			"text": "+{0}% sát thương lên boss, boss hiếm, tinh anh."},
	],
	"trieu-hoi-su": [
		{"id": "linhkhe", "name": "Linh Khế", "icon": "skill-pv-linhkhe", "per": [0.04], "text": "Linh thú +{0}% sát thương."},
		{"id": "linhthe", "name": "Linh Thể", "icon": "skill-pv-linhthe", "per": [0.08], "text": "Linh thú +{0}% HP (tính lúc gọi)."},
		{"id": "linhho", "name": "Linh Hộ", "icon": "skill-pv-linhho", "per": [0.01],
			"text": "Mỗi linh thú đang sống (tối đa 3): nhận ít hơn {0}% sát thương."},
		{"id": "honluc", "name": "Hồn Lực", "icon": "skill-pv-honluc", "per": [0.03], "text": "Sát thương của bản thân +{0}%."},
	],
}

## Đặc tính lớp (docs/26 mục 3.1) — chỉ để hiện ở tab Bị động; số thật nằm ở Stats.CLASS và GameWorld.
const TRAITS := {
	"kiem-khach": "+15% tốc chạy · +10% né tránh · +20% sát thương chí mạng. Kiếm thế: mỗi đòn trúng liên tiếp trong 2 giây +2% tốc đánh (tối đa +20%), mất khi bị trúng đòn.",
	"tho-san": "+25% tầm đánh · +15% chí mạng · +10% xuyên giáp. Thân pháp: né thành công giảm 20% hồi chiêu né lăn.",
	"phap-su": "+20% sát thương kỹ năng · +15% xuyên kháng phép · MP khởi đầu gấp đôi.",
	"ho-ve": "+30% Phòng thủ · +25% kháng hiệu ứng · Khiên: nhận ít hơn 15% sát thương.",
	"trieu-hoi-su": "Tối đa 3 linh thú chủ lực · linh thú +20% HP và nhận 40% chỉ số chủ. Gắn kết: mỗi linh thú đang sống +4% hồi MP (tối đa 3).",
}


class State:
	## Phản Kích: còn bao nhiêu giây tăng sát thương
	var counter_t := 0.0


# ------------------------------------------------------------------ dữ liệu


static func defs_of(class_id: String) -> Array:
	var out: Array = []
	var arr: Array = DEFS.get(class_id, [])
	for i in arr.size():
		var d: Dictionary = arr[i].duplicate()
		d["unlock"] = UNLOCKS[i]
		out.append(d)
	return out


static func def_of(class_id: String, id: String) -> Dictionary:
	for d in defs_of(class_id):
		if str(d.id) == id:
			return d
	return {}


## Cấp bị động id của hồ sơ p (0 = chưa học).
static func level_of(p, id: String) -> int:
	return clampi(int(p.passive_levels.get(id, 0)), 0, MAX_LEVEL)


## Mô tả ở cấp lv (lv = 0 thì dùng cấp 1 để người chơi biết bị động làm gì).
static func describe(d: Dictionary, lv: int) -> String:
	var t := str(d.text)
	var per: Array = d.per
	for k in per.size():
		t = t.replace("{%d}" % k, _pct(float(per[k]) * maxi(1, lv)))
	return t


## 0,035 → "3,5"; 0,04 → "4".
static func _pct(x: float) -> String:
	var s := "%.1f" % (x * 100.0)
	if s.ends_with(".0"):
		s = s.substr(0, s.length() - 2)
	return s.replace(".", ",")


## Lý do chưa nâng được ("" = nâng được).
static func can_upgrade(p, id: String) -> String:
	var d := def_of(str(p.class_id), id)
	if d.is_empty():
		return "Không có bị động này."
	if int(p.level) < int(d.unlock):
		return "%s mở ở cấp %d." % [d.name, int(d.unlock)]
	if level_of(p, id) >= MAX_LEVEL:
		return "%s đã đạt cấp tối đa." % d.name
	if int(p.skill_points) <= 0:
		return "Không còn Điểm Kỹ Năng (mỗi lần lên cấp +1)."
	return ""


static func upgrade(p, id: String) -> Dictionary:
	var why := can_upgrade(p, id)
	if why != "":
		return {"ok": false, "msg": why}
	p.skill_points = int(p.skill_points) - 1
	p.passive_levels[id] = level_of(p, id) + 1
	var d := def_of(str(p.class_id), id)
	return {"ok": true, "msg": "%s lên cấp %d." % [d.name, level_of(p, id)]}


## Tẩy điểm: trả về số điểm hoàn lại.
static func reset(p) -> int:
	var n := 0
	for id in p.passive_levels:
		n += maxi(0, int(p.passive_levels[id]))
	p.passive_levels = {}
	return n


## Bị động vừa mở đúng cấp lv (để báo khi lên cấp).
static func unlocked_at(class_id: String, lv: int) -> Array:
	return defs_of(class_id).filter(func(d): return int(d.unlock) == lv)


# ------------------------------------------------------------------ giá trị đang có


## per[k] × cấp của bị động id nếu id thuộc lớp đang chơi (0 nếu chưa học).
static func val(w, id: String, k := 0) -> float:
	var lv := level_of(w.profile, id)
	if lv <= 0:
		return 0.0
	var d := def_of(str(w.profile.class_id), id)
	if d.is_empty():
		return 0.0
	return float(d.per[k]) * lv


static func _alive_summons(w) -> int:
	var n := 0
	for a in w.allies:
		if not a.dead and a.kind == "summon":
			n += 1
	return n


# ------------------------------------------------------------------ hook qua Chapters


static func derive_bonus(w, bonus: Dictionary) -> void:
	bonus.max_hp_pct += val(w, "thietcot")
	bonus.move_pct += val(w, "buocgio", 0)


static func derive_after(w, _bonus: Dictionary, st: Dictionary) -> void:
	st.crit_dmg = float(st.crit_dmg) + val(w, "kiemtam")
	st.mp_regen = float(st.mp_regen) * (1.0 + val(w, "minhtuong"))
	st.def = float(st.def) * (1.0 + val(w, "kienthu"))
	st.pet_hp_pct = float(st.get("pet_hp_pct", 0.0)) + val(w, "linhthe")
	var eva := val(w, "buocgio", 1)
	if eva > 0.0:
		var cid := str(st.get("class", w.profile.class_id))
		var cap := float(w.Stats.CLASS.get(cid, {}).get("eva_cap", w.Stats.EVASION_CAP))
		st.evasion = minf(cap, float(st.evasion) + eva)


## Nhân vào mọi đòn người chơi đánh quái e.
static func hit_mult(w, e, _crit: bool) -> float:
	var k := 1.0
	var pl = w.player
	var max_hp := float(w.stats.max_hp)
	if pl.hp < max_hp * RAGE_HP:
		k += val(w, "chieny", 0)
	if w.pv.counter_t > 0.0:
		k += val(w, "phankich")
	if e.pos.distance_to(pl.pos) > FAR:
		k += val(w, "ungmuc")
	if e.hp < e.max_hp * PREY_HP:
		k += val(w, "sanmoi")
	if pl.mp > float(w.stats.max_mp) * FULL_MP:
		k += val(w, "doidao")
	if e.role in ["boss", "rare"] or e.elite:
		k += val(w, "uyap")
	k += val(w, "honluc")
	var tt := val(w, "nguyento")
	if tt > 0.0:
		var el_sk: String = w.Skills2.element_of(w, w.Skills2.source(w))
		if w.element_bonus(e) > 0.0 or (el_sk != "" and Monsters.counters(el_sk, w.el_of(e))):
			k += tt
	return k


static func tick(w, dt: float) -> void:
	w.pv.counter_t -= dt
	var regen := val(w, "ychisat")
	var pl = w.player
	if regen > 0.0 and pl.hp > 0.0 and pl.dead_timer <= 0.0:
		pl.hp = minf(float(w.stats.max_hp), pl.hp + float(w.stats.max_hp) * regen * dt)


# ------------------------------------------------------------------ hook gọi thẳng


## Nhân vào tốc đánh (GameWorld.atk_speed).
static func speed_mult(w) -> float:
	if w.player.hp < float(w.stats.max_hp) * RAGE_HP:
		return 1.0 + val(w, "chieny", 1)
	return 1.0


## Người chơi vừa né được một đòn (né lăn hoặc né tránh).
static func on_evade(w) -> void:
	if val(w, "phankich") > 0.0:
		w.pv.counter_t = COUNTER_TIME


## Hộ Thể Pháp Lực: phần sát thương trừ vào MP; trả về phần còn trừ vào HP.
static func absorb(w, dmg: int) -> int:
	var pct := val(w, "hothe")
	if pct <= 0.0 or dmg <= 0:
		return dmg
	var part := minf(float(dmg) * pct, w.player.mp)
	w.player.mp -= part
	return dmg - int(part)


## Sau mỗi đòn người chơi trúng quái (GameWorld._hit_enemy).
static func after_hit(w, e, _dmg: int) -> void:
	var ch := val(w, "tamdoc")
	if ch <= 0.0 or e.dead or w._r() >= ch:
		return
	e.venom_stacks = mini(VENOM_STACKS, e.venom_stacks + 1)
	if e.venom_timer <= 0.0:
		e.venom_tick = 0.0
	e.venom_timer = VENOM_TIME


## Nhân vào sát thương người chơi nhận (Classes2.taken_mult).
static func taken_mult(w) -> float:
	var per := val(w, "linhho")
	if per <= 0.0:
		return 1.0
	return 1.0 - per * mini(GUARD_PETS, _alive_summons(w))


## Phản Chấn: phần sát thương phản lại (Classes2.on_player_hit).
static func reflect(w) -> float:
	return val(w, "phanchan")


## Linh Khế: cộng vào hệ số sát thương linh thú (Classes2.ally_mult).
static func ally_bonus(w) -> float:
	return val(w, "linhkhe")
