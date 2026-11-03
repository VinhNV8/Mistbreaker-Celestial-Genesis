extends RefCounted
## TP-05 / TP-13 / TP-44 / TP-14 (docs/33): Thiên phú chính + tối đa 2 Thiên phú phụ, cộng hưởng, tẩy Thiên phú.
## Mọi chỗ kiểm "có Thiên phú X" đi qua đây (chỉ cần profile) — GameWorld.has_talent / tvt bọc thêm hiệu lực Thiên phú
## (Suy Thiên chương 8). profile.subs = [{"id", "level"}]; ô 2 mở khi chuyển chức 1, ô 3 khi chuyển chức 2.

const Talents = preload("res://scripts/data/talents.gd")

const MAX_SUBS := 2
## Đạo Tặc (SSS ẩn, độc nhất) không ra ở lễ ô phụ và khi tẩy; không tẩy được.
const NO_ROLL := ["dao-tac"]
## TP13-01: cộng hưởng chung — phần thưởng của hiệu ứng chính ×1,1.
const GENERAL_K := 1.1
## TP13-02: 9 cặp đặc biệt (docs/05 mục 4) — khoá = 2 id xếp theo bảng chữ cái nối "|".
const SPECIAL := {
	"khuu-giac|mat-ung": {"id": "di-tich", "name": "Thợ Săn Di Tích", "text": "Mọi ô Di tích hiện trên bản đồ khai phá dù còn sương.", "known": true},
	"hap-huyet|huyet-chien": {"id": "huyet-than", "name": "Huyết Chiến Thần", "text": "HP dưới 30%: hút máu ×2."},
	"kiem-tam|tay-nhanh": {"id": "lien-hoan", "name": "Liên Hoàn Kiếm", "text": "Đòn mạnh của Kiếm Tâm ở đòn thứ 4 thay vì thứ 5."},
	"huyet-chien|than-the": {"id": "bat-khuat", "name": "Bất Khuất", "text": "Mỗi 60 giây, lần đầu HP về 0 thì giữ lại 1 HP."},
	"ban-tay-vang|may-man": {"id": "phu-quy", "name": "Phú Quý", "text": "Quái tinh anh 5% rơi 1 Tinh Kim."},
	"thao-duoc|tho-ren": {"id": "luyen-kim", "name": "Luyện Kim Sư", "text": "Cường hoá khi có ≥ 2 bình máu: dùng 2 bình làm Dầu Rèn, +10% tỉ lệ lần đó."},
	"long-mach|trai-tim": {"id": "long-de", "name": "Long Đế", "text": "Long Mạch Đàn xây xong ngay; buff Long Mạch +5%."},
	"bay-dan|thuan-thu": {"id": "chua-te", "name": "Chúa Tể Bầy Đàn", "text": "Lính bóng tối không hết thời gian khi còn thú cưng sống."},
	"chan-khong|thien-menh": {"id": "lu-khach", "name": "Lữ Khách Thiên Mệnh", "text": "+3 Đuốc tối đa."},
}


## Mọi Thiên phú đang có (chính trước).
static func ids(p) -> Array:
	var out: Array = []
	if str(p.talent) != "":
		out.append(str(p.talent))
	for s in p.subs:
		out.append(str(s.id))
	return out


static func has(p, id: String) -> bool:
	if str(p.talent) == id:
		return true
	for s in p.subs:
		if str(s.id) == id:
			return true
	return false


## Cấp dùng cho hiệu ứng: Thiên phú chính = cấp hiệu dụng (có tiến hoá); phụ = cấp riêng 1–10.
static func level_of(p, id: String) -> int:
	if str(p.talent) == id:
		return int(p.talent_level)
	for s in p.subs:
		if str(s.id) == id:
			return int(s.level)
	return 1


static func _key(a: String, b: String) -> String:
	return (a + "|" + b) if a < b else (b + "|" + a)


## Các cặp đặc biệt đang kích hoạt (id cộng hưởng → dữ liệu).
static func specials(p) -> Dictionary:
	var out := {}
	var all := ids(p)
	for i in all.size():
		for j in range(i + 1, all.size()):
			var k := _key(str(all[i]), str(all[j]))
			if SPECIAL.has(k):
				out[str(SPECIAL[k].id)] = SPECIAL[k]
	return out


static func has_special(p, special_id: String) -> bool:
	return specials(p).has(special_id)


## TP13-01: Thiên phú id có cùng nhóm với Thiên phú khác (không phải cặp đặc biệt) → ×1,1.
static func general_k(p, id: String) -> float:
	if not has(p, id):
		return 1.0
	var g: String = Talents.get_talent(id).group
	for o in ids(p):
		if o == id:
			continue
		if Talents.get_talent(o).group == g and not SPECIAL.has(_key(id, o)):
			return GENERAL_K
	return 1.0


## Giá trị hiệu ứng chính theo cấp + cộng hưởng chung (chưa nhân hiệu lực Thiên phú chương 8).
## v1 ≥ 1: hệ số (×2,0 …) → phần trên 1 nhân k; còn lại nhân thẳng.
static func value(p, id: String, v1: float, v10: float) -> float:
	var v := Talents.lv_value(v1, v10, level_of(p, id))
	var k := general_k(p, id)
	if is_equal_approx(k, 1.0):
		return v
	return 1.0 + (v - 1.0) * k if v1 >= 1.0 else v * k


## Hiệu ứng phụ nhóm (cấp 5 / 10) từ bất kỳ Thiên phú nào đang có.
static func has_group_sub(p, group: String, tier: int) -> bool:
	for id in ids(p):
		if Talents.has_sub(id, level_of(p, id), group, tier):
			return true
	return false


## TP5-01: số ô phụ đã mở (chuyển chức 1, chuyển chức 2).
static func sub_slots_open(p) -> int:
	return (1 if str(p.job) != "" else 0) + (1 if str(p.job2) != "" else 0)


## Số ô phụ đang chờ Lễ Thức Tỉnh.
static func pending(p) -> int:
	return maxi(0, mini(MAX_SUBS, sub_slots_open(p)) - p.subs.size())


## Bể quay lễ ô phụ / tẩy: 20 Thiên phú trừ Thiên phú đang có và Đạo Tặc.
static func sub_pool(p, keep := "") -> Array:
	var have := ids(p)
	return Talents.LIST.filter(func(t): return not (str(t.id) in NO_ROLL) and (str(t.id) == keep or not (str(t.id) in have)))


## TP44-01: dòng cộng hưởng cho bảng Thiên phú — [tên, mô tả, đang kích hoạt].
## Cặp đặc biệt chưa kích hoạt lần nào: "???" + gợi ý nhóm (khi đang có 1 trong 2), trừ cặp "known".
static func resonance_rows(p) -> Array:
	var out: Array = []
	var all := ids(p)
	var act := specials(p)
	for sid in act:
		out.append([str(act[sid].name), str(act[sid].text), true])
	var seen_groups := {}
	for i in all.size():
		for j in range(i + 1, all.size()):
			var a: String = all[i]
			var b: String = all[j]
			if SPECIAL.has(_key(a, b)):
				continue
			var g: String = Talents.get_talent(a).group
			if Talents.get_talent(b).group == g and not seen_groups.has(g):
				seen_groups[g] = true
				out.append(["Cộng hưởng %s" % Talents.GROUP_NAMES[g], "Hiệu ứng chính của 2 Thiên phú nhóm %s +10%%." % Talents.GROUP_NAMES[g], true])
	for k in SPECIAL:
		var sp: Dictionary = SPECIAL[k]
		if act.has(str(sp.id)):
			continue
		var pair: Array = str(k).split("|")
		if not (has(p, pair[0]) or has(p, pair[1])):
			continue
		var known: bool = bool(sp.get("known", false)) or bool(p.resonance_seen.get(str(sp.id), false))
		var other: String = pair[1] if has(p, pair[0]) else pair[0]
		var hint := "Cần thêm 1 Thiên phú nhóm %s." % Talents.GROUP_NAMES[Talents.get_talent(other).group]
		out.append([str(sp.name) if known else "???", (str(sp.text) + " " + ("Cần thêm %s." % Talents.get_talent(other).name)) if known else hint, false])
	return out
