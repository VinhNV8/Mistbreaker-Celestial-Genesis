extends RefCounted
## SN-31…33 (Spec_Notes S7): sương che bản đồ — "đi tới đâu thấy đất tới đó".
## Map chia ô CELL px; ô đã tới mở vĩnh viễn. Lưu save dạng base64 của bitset (1 bit/ô).

const CELL := 64.0
## Bán kính mở sương quanh nhân vật (36 m).
const REVEAL_R := 360.0
## Mốc thưởng khám phá (%).
const REWARD_MARKS := [50, 90]

var w := 0
var h := 0
var cells := PackedByteArray()
var opened := 0
## Tăng mỗi khi có ô mới mở (view dựng lại texture khi số này đổi).
var version := 0


func setup(world_size: Vector2, saved := "") -> void:
	w = ceili(world_size.x / CELL)
	h = ceili(world_size.y / CELL)
	cells = PackedByteArray()
	cells.resize(w * h)
	opened = 0
	if saved != "":
		var bits := Marshalls.base64_to_raw(saved)
		for i in w * h:
			var byte := i >> 3
			if byte < bits.size() and (bits[byte] >> (i & 7)) & 1:
				cells[i] = 1
				opened += 1
	version += 1


func total() -> int:
	return w * h


func ratio() -> float:
	return float(opened) / maxf(1.0, float(total()))


func is_open_at(pos: Vector2) -> bool:
	var cx := int(pos.x / CELL)
	var cy := int(pos.y / CELL)
	if cx < 0 or cy < 0 or cx >= w or cy >= h:
		return false
	return cells[cy * w + cx] == 1


## Mở các ô có tâm nằm trong vòng tròn. Trả về số ô mới mở.
func reveal(center: Vector2, radius: float) -> int:
	var n := 0
	var x0 := maxi(0, int((center.x - radius) / CELL))
	var x1 := mini(w - 1, int((center.x + radius) / CELL))
	var y0 := maxi(0, int((center.y - radius) / CELL))
	var y1 := mini(h - 1, int((center.y + radius) / CELL))
	var r2 := radius * radius
	for cy in range(y0, y1 + 1):
		for cx in range(x0, x1 + 1):
			var i := cy * w + cx
			if cells[i] == 1:
				continue
			var c := Vector2((cx + 0.5) * CELL, (cy + 0.5) * CELL)
			if c.distance_squared_to(center) <= r2:
				cells[i] = 1
				n += 1
	if n > 0:
		opened += n
		version += 1
	return n


func encode() -> String:
	var bits := PackedByteArray()
	bits.resize((w * h + 7) >> 3)
	for i in w * h:
		if cells[i] == 1:
			bits[i >> 3] |= 1 << (i & 7)
	return Marshalls.raw_to_base64(bits)


## % đã mở của một map từ chuỗi save (map không đang đứng).
static func ratio_of(saved: String, world_size: Vector2) -> float:
	if saved == "":
		return 0.0
	var n := 0
	var bits := Marshalls.base64_to_raw(saved)
	var t := ceili(world_size.x / CELL) * ceili(world_size.y / CELL)
	for i in t:
		var byte := i >> 3
		if byte < bits.size() and (bits[byte] >> (i & 7)) & 1:
			n += 1
	return float(n) / maxf(1.0, float(t))
