extends RefCounted
## Bộ sinh số ngẫu nhiên dạng Callable trả về float trong [0, 1).
## Logic nhận Callable thay vì gọi randf() trực tiếp để test lặp lại được.


static func make(seed_value: int) -> Callable:
	var r := RandomNumberGenerator.new()
	r.seed = seed_value
	return func() -> float: return r.randf()


static func pick_weighted(items: Array, weight: Callable, rng: Callable) -> Variant:
	var total := 0.0
	for item in items:
		total += float(weight.call(item))
	var roll: float = float(rng.call()) * total
	for item in items:
		roll -= float(weight.call(item))
		if roll < 0.0:
			return item
	return items[items.size() - 1]


static func shuffle(items: Array, rng: Callable) -> Array:
	var out := items.duplicate()
	for i in range(out.size() - 1, 0, -1):
		var j := int(float(rng.call()) * (i + 1))
		var tmp: Variant = out[i]
		out[i] = out[j]
		out[j] = tmp
	return out
