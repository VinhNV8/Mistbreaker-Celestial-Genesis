extends RefCounted
## Lễ Thức Tỉnh: 1 lần quay + 3 lần quay lại miễn phí; người chơi chọn bất kỳ kết quả nào.
## Bảo hiểm: nếu cả 4 lần đều dưới hạng B, lần cuối được nâng lên hạng B.

const Talents = preload("res://scripts/data/talents.gd")
const RngUtil = preload("res://scripts/core/rng_util.gd")

const MAX_REROLLS := 3
const MAX_ROLLS := MAX_REROLLS + 1

var rolls: Array = []
var _rng: Callable
var _pool: Array


func _init(rng: Callable, pool: Array = []) -> void:
	_rng = rng
	_pool = pool if not pool.is_empty() else Talents.LIST


func can_roll() -> bool:
	return rolls.size() < MAX_ROLLS


func rerolls_left() -> int:
	return mini(MAX_REROLLS, MAX_ROLLS - rolls.size())


## Trả về Thiên phú vừa quay, hoặc Dictionary rỗng nếu đã hết lượt.
func roll() -> Dictionary:
	if not can_roll():
		return {}
	var talent: Dictionary = RngUtil.pick_weighted(_pool, func(t): return Talents.roll_weight(t), _rng)
	var min_rank := Talents.rank_index("B")
	var is_last := rolls.size() == MAX_ROLLS - 1
	var all_below := true
	for t in rolls:
		if Talents.rank_index(t.rank) >= min_rank:
			all_below = false
	if is_last and all_below and Talents.rank_index(talent.rank) < min_rank:
		var rank_b := _pool.filter(func(t): return t.rank == "B")
		if not rank_b.is_empty():
			talent = rank_b[int(float(_rng.call()) * rank_b.size()) % rank_b.size()]
	rolls.append(talent)
	return talent
