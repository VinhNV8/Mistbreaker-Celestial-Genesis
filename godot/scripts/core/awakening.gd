extends RefCounted
## Lễ Thức Tỉnh: 1 lần quay + 3 lần quay lại miễn phí; người chơi chọn bất kỳ kết quả nào.
## Bảo hiểm: nếu cả 4 lần đều dưới hạng B, lần cuối được nâng lên hạng B.

const Talents = preload("res://scripts/data/talents.gd")
const RngUtil = preload("res://scripts/core/rng_util.gd")

const MAX_REROLLS := 3
const MAX_ROLLS := MAX_REROLLS + 1

var rolls: Array = []
## CR-02: vị trí lượt gift code trong `rolls` (-1 = chưa dùng mã). Mỗi nhân vật tối đa 1 mã (GC-04).
var gift_index := -1
var gift_serial := ""
## GC-03: chỉ hạng A trở lên, giữ tỉ lệ tương đối của kịch bản.
const GIFT_MIN_RANK := "A"
var _rng: Callable
var _pool: Array


func _init(rng: Callable, pool: Array = []) -> void:
	_rng = rng
	_pool = pool if not pool.is_empty() else Talents.LIST


func can_roll() -> bool:
	return normal_rolls() < MAX_ROLLS


func rerolls_left() -> int:
	return mini(MAX_REROLLS, MAX_ROLLS - normal_rolls())


func gift_used() -> bool:
	return gift_index >= 0


## CR-02: lượt quay thêm từ gift code — không tốn lượt quay lại (GC-02).
func gift_roll(serial := "") -> Dictionary:
	if gift_used():
		return {}
	var min_rank := Talents.rank_index(GIFT_MIN_RANK)
	var pool := _pool.filter(func(t): return Talents.rank_index(t.rank) >= min_rank)
	var talent: Dictionary = RngUtil.pick_weighted(pool, func(t): return Talents.roll_weight(t), _rng)
	rolls.append(talent)
	gift_index = rolls.size() - 1
	gift_serial = serial
	return talent


## Số lượt quay thường đã dùng (không tính lượt gift code).
func normal_rolls() -> int:
	return rolls.size() - (1 if gift_used() else 0)


## Trả về Thiên phú vừa quay, hoặc Dictionary rỗng nếu đã hết lượt.
func roll() -> Dictionary:
	if not can_roll():
		return {}
	var talent: Dictionary = RngUtil.pick_weighted(_pool, func(t): return Talents.roll_weight(t), _rng)
	var min_rank := Talents.rank_index("B")
	var is_last := normal_rolls() == MAX_ROLLS - 1
	var all_below := true
	for i in rolls.size():
		if i == gift_index:
			continue
		var t: Dictionary = rolls[i]
		if Talents.rank_index(t.rank) >= min_rank:
			all_below = false
	if is_last and all_below and Talents.rank_index(talent.rank) < min_rank:
		var rank_b := _pool.filter(func(t): return t.rank == "B")
		if not rank_b.is_empty():
			talent = rank_b[int(float(_rng.call()) * rank_b.size()) % rank_b.size()]
	rolls.append(talent)
	return talent
