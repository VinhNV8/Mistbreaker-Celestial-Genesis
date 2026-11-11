extends RefCounted
## AF-1 (docs/48): Tự đánh thông minh — chọn kỹ năng theo tình huống thay vì xả mọi kỹ năng vừa hồi xong.
## Mỗi nhịp (GAP giây) chấm điểm từng kỹ năng đang sẵn sàng theo chiến thuật của nó (data/auto_tactics.gd) và
## tình huống (số quái trong vùng chiêu, tinh anh / mục tiêu trâu, máu / MP của mình, quái sắp chết) rồi chỉ tung
## 1 chiêu điểm cao nhất (≥ MIN_SCORE); còn lại đánh thường. Kiểu "full" giữ cách cũ (xả ngay khi hồi xong).
## Logic thuần (không vẽ) — GameWorld._auto_input gọi choose() và potions().

const Tactics = preload("res://scripts/data/auto_tactics.gd")
const Classes = preload("res://scripts/data/classes.gd")

## Giây tối thiểu giữa 2 lần tự ra chiêu.
const GAP := {"smart": 0.45, "save": 0.8, "full": 0.0}
const MIN_SCORE := 20.0
## Thông minh: dưới 30% MP chỉ dùng chiêu điểm ≥ 70 (phòng thủ, tối thượng…). Tiết kiệm: dưới 50%.
const LOW_MP := {"smart": 0.3, "save": 0.5, "full": 0.0}
## Quái tính vào tình huống: trong 45 m quanh mình.
const NEAR := 450.0
## Độ rộng (nửa) đường chiêu thẳng / lao.
const LINE_HALF := 40.0
## Tự uống bình: HP < 35%, MP < 12% khi đang đánh.
const POTION_HP := 0.35
const POTION_MP := 0.12


static func tactic(id: String) -> Dictionary:
	return Tactics.TACTICS.get(id, {"t": "single"})


## Mục tiêu "trâu": tinh anh, thủ lĩnh / boss hang / quái hiếm, hoặc còn nhiều máu (≥ 8 đòn thường).
static func is_big(w, e) -> bool:
	return bool(e.elite) or not (str(e.role) in ["field", "nestMinion", "summon"]) or float(e.hp) > float(w.stats.atk) * 8.0


static func foes(w) -> Array:
	var out: Array = []
	for e in w.enemies:
		if e.dead or w.is_hidden(e):
			continue
		if e.pos.distance_to(w.player.pos) <= NEAR:
			out.append(e)
	return out


static func count_near(list: Array, at: Vector2, r: float) -> int:
	var n := 0
	for e in list:
		if e.pos.distance_to(at) <= r + float(e.radius):
			n += 1
	return n


## Số quái trên đoạn thẳng từ `from` theo hướng `dir`, dài `length`.
static func count_line(list: Array, from: Vector2, dir: Vector2, length: float) -> int:
	var n := 0
	for e in list:
		var v: Vector2 = e.pos - from
		var t := v.dot(dir)
		if t < -float(e.radius) or t > length + float(e.radius):
			continue
		if absf(v.cross(dir)) <= LINE_HALF + float(e.radius):
			n += 1
	return n


## Tâm vùng tốt nhất cho chiêu đặt điểm: quái (trong tầm ném) có nhiều quái quanh nó nhất.
static func best_center(list: Array, from: Vector2, reach: float, r: float, fallback: Vector2) -> Array:
	var best := fallback
	var bn := count_near(list, fallback, r)
	for e in list:
		if e.pos.distance_to(from) > reach:
			continue
		var n := count_near(list, e.pos, r)
		if n > bn:
			bn = n
			best = e.pos
	return [best, bn]


## Chọn kỹ năng cho nhịp này. Trả {slot, aim, id, score} hoặc {} (chỉ đánh thường).
static func choose(w, target, gap: float, mode := "smart") -> Dictionary:
	if mode == "full":
		return _choose_full(w, gap)
	if float(w.time) - float(w._auto_skill_at) < float(GAP.get(mode, 0.45)):
		return {}
	var p = w.player
	var list := foes(w)
	var ranged: bool = w.is_ranged()
	var hp_ratio := float(p.hp) / maxf(1.0, float(w.stats.max_hp))
	var mp_ratio := float(p.mp) / maxf(1.0, float(w.stats.max_mp))
	var big := is_big(w, target)
	var pack := count_near(list, target.pos, 150.0)
	var threat := count_near(list, p.pos, 120.0)
	# 1 quái thường sắp chết → đánh thường là đủ, để dành MP.
	var trivial := list.size() <= 1 and not big and float(target.hp) <= float(w.stats.atk) * 3.0
	var dir: Vector2 = (target.pos - p.pos).normalized()
	var pets := 0
	for a in w.allies:
		if not a.dead:
			pets += 1
	var best := {}
	for i in Classes.SKILL_SLOTS:
		var sk: Dictionary = w.slot_skill(i)
		if sk.is_empty() or not w.skill_unlocked(sk):
			continue
		if float(p.skill_cds[i]) > 0.0 or float(p.mp) < float(sk.mp):
			continue
		var tac := tactic(str(sk.id))
		var t := str(tac.t)
		var score := 0.0
		var aim: Vector2 = target.pos
		var reach := float(tac.get("reach", 380.0 if ranged else 200.0))
		match t:
			"defense":
				if hp_ratio < 0.5:
					score = 100.0
				elif threat >= 3 and hp_ratio < 0.85:
					score = 70.0
				elif bool(tac.get("ult", false)) and threat >= 4:
					score = 75.0
			"escape":
				if gap < 80.0:
					score = 85.0
			"buff":
				if bool(tac.get("need_pets", false)) and pets == 0:
					score = 0.0
				elif gap <= reach and (pack >= 2 or big):
					score = 55.0
			"summon":
				var last := float(w._auto_cast.get(str(sk.id), -999.0))
				if float(w.time) - last < float(tac.get("dur", 12.0)) * 0.9:
					score = 0.0
				elif bool(tac.get("ult", false)):
					score = 90.0 if (list.size() >= 4 or big) else 0.0
				elif gap <= NEAR and not trivial:
					score = 65.0
			"aoe_self":
				var n := count_near(list, p.pos, float(tac.r))
				score = _dmg_score(n, big, trivial)
			"aoe_at", "chain":
				if gap <= reach:
					var bc := best_center(list, p.pos, reach, float(tac.r), target.pos)
					aim = bc[0]
					score = _dmg_score(int(bc[1]), big, trivial)
			"line":
				var len_l := float(tac.get("len", 400.0))
				if gap <= len_l:
					score = _dmg_score(count_line(list, p.pos, dir, len_l), big, trivial, true)
			"dash":
				var len_d := float(tac.get("len", 180.0))
				if not ranged and gap > 70.0 and gap <= len_d and not trivial:
					score = 35.0
				elif gap <= len_d:
					var nd := count_line(list, p.pos, dir, len_d)
					score = _dmg_score(nd, big, trivial) if nd >= 2 else 0.0
			_:
				if gap <= reach and not trivial:
					score = 45.0 if big else 20.0
		if score <= 0.0:
			continue
		if bool(tac.get("hp_cost", false)) and hp_ratio < 0.5:
			continue
		if bool(tac.get("ult", false)) and t != "defense" and t != "summon" and not (list.size() >= 4 or big):
			continue
		if bool(tac.get("ult", false)) and t != "defense" and t != "summon":
			score = maxf(score, 90.0)
		if bool(tac.get("big", false)):
			if not (big or list.size() >= 3):
				continue
			score += 30.0
		# chiêu mạnh hơn (hệ số cao, hồi lâu) được ưu tiên nhẹ khi điểm ngang nhau
		score += float(sk.mul) * 3.0 + float(sk.cd) * 0.3
		if mode == "save" and t in ["aoe_self", "aoe_at", "chain", "line"] and score < 60.0 and not big:
			continue
		if mp_ratio < float(LOW_MP.get(mode, 0.3)) and score < 70.0:
			continue
		if score >= MIN_SCORE and (best.is_empty() or score > float(best.score)):
			best = {"slot": i, "aim": aim, "id": str(sk.id), "score": score}
	return best


## Phần điểm của chiêu gây sát thương: ≥ 2 quái trong vùng mới đáng dùng; 1 quái chỉ khi là mục tiêu trâu.
static func _dmg_score(n: int, big: bool, trivial: bool, line := false) -> float:
	if n <= 0 or trivial:
		return 0.0
	if n >= 2:
		return 30.0 + 15.0 * n
	if big:
		return 30.0
	return 15.0 if line else 0.0


## Kiểu "Xả hết" (cách cũ): tung kỹ năng đầu tiên vừa hồi xong, kể cả buff / khiên / gọi linh thú.
static func _choose_full(w, gap: float) -> Dictionary:
	var ranged: bool = w.is_ranged()
	for i in Classes.SKILL_SLOTS:
		var sk: Dictionary = w.slot_skill(i)
		if sk.is_empty() or not w.skill_unlocked(sk):
			continue
		if float(w.player.skill_cds[i]) <= 0.0 and float(w.player.mp) >= float(sk.mp) + 10.0 and gap < (380.0 if ranged else 160.0):
			return {"slot": i, "aim": null, "id": str(sk.id), "score": 1.0}
	return {}


## Tự uống bình khi Tự đánh: HP < 35% (bình máu), MP < 12% lúc đang đánh (bình MP). Trả {potion, mp_potion}.
static func potions(w, fighting: bool) -> Dictionary:
	var p = w.player
	var out := {}
	if float(p.hp) < float(w.stats.max_hp) * POTION_HP and int(w.profile.potions) > 0 and float(p.potion_cd) <= 0.0:
		out["potion"] = true
	if fighting and float(p.mp) < float(w.stats.max_mp) * POTION_MP and int(w.profile.mp_potions) > 0 and float(p.mp_potion_cd) <= 0.0:
		out["mp_potion"] = true
	return out
