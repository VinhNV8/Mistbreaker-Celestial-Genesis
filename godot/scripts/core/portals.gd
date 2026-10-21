extends RefCounted
## MP-09 (Spec_Notes đợt 6): cổng dịch chuyển đặt sẵn trên map thay cho việc mở bản đồ lục địa để chọn.
## Mỗi map có tối đa 3 cổng, sinh từ dữ liệu map (không cần khai báo tay):
##   "next"     — rìa phải (trên cao, trước tường sương nếu có): sang map kế tiếp theo thứ tự REGIONS.
##   "back"     — rìa trái, ngang vùng an toàn: về map trước.
##   "waypoint" — Cổng Dịch Chuyển trong vùng an toàn: chọn nhanh một map đã mở (bảng lục địa).
##   "cave"     — cửa hang phụ (HP-01, docs/15) → bản đồ hang `cave-<id>`.
##   "exit"     — trong hang: cổng ra về map cha (cạnh cửa vào; thêm 1 cổng khi hạ Chúa Hang).
## Bước vào cổng next/back thì gọi GameWorld.travel() — chưa đủ điều kiện thì báo lý do (travel_blocker).

const Maps = preload("res://scripts/data/maps.gd")
const Caves = preload("res://scripts/core/caves.gd")

const RADIUS := 44.0
## Khoảng cách đặt nhân vật cạnh cổng khi tới nơi bằng cổng (về phía giữa map).
const ARRIVE_OFFSET := 110.0


## Thứ tự map đã làm: theo REGIONS, bỏ id chưa có dữ liệu.
static func chain() -> Array:
	var out: Array = []
	for r in Maps.REGIONS:
		for m in r.maps:
			if Maps.MAPS.has(m):
				out.append(m)
	return out


## [{kind, to, pos}] của map id.
static func list(id: String) -> Array:
	if Caves.is_cave(id):
		return [{"kind": "exit", "to": Caves.parent(id), "pos": Caves.MOUTH + Vector2(-110, 0)}]
	var m: Dictionary = Maps.get_map(id)
	var ids := chain()
	var i := ids.find(id)
	var out: Array = []
	var size: Vector2 = m.size
	var safe_pos: Vector2 = m.safe.pos
	var safe_r := float(m.safe.r)
	if i > 0:
		out.append({"kind": "back", "to": ids[i - 1], "pos": Vector2(110.0, safe_pos.y)})
	if i >= 0 and i < ids.size() - 1:
		var x := size.x - 260.0
		if m.get("gate", false) and m.arena != null:
			x = minf(x, float(m.arena.pos.x) - float(m.arena.r) - 260.0)
		out.append({"kind": "next", "to": ids[i + 1], "pos": Vector2(x, size.y * 0.18)})
	out.append({"kind": "waypoint", "to": "", "pos": safe_pos + waypoint_offset(m)})
	if Maps.MAPS.has(id):
		out.append({"kind": "cave", "to": Caves.cave_id(id), "pos": Caves.entrance(id)})
	return out


## Cổng Dịch Chuyển: chọn trong vài vị trí ứng viên (vòng 0,55 bán kính vùng an toàn) chỗ xa nhà, NPC,
## tâm (bia đá / lửa trại) và điểm xuất hiện (+60, 0) nhất.
static func waypoint_offset(m: Dictionary) -> Vector2:
	var r := float(m.safe.r)
	var blocks: Array = [Vector2.ZERO, Vector2(60, 0)]
	for b in Maps.safe_buildings(m):
		blocks.append(b[0])
	for n in m.get("npcs", []):
		blocks.append(n[2])
	var best := Vector2(0, r * 0.55)
	var best_d := -1.0
	for i in 16:
		var cand := Vector2.from_angle(TAU * i / 16.0) * r * 0.58
		var dmin := INF
		for b in blocks:
			dmin = minf(dmin, cand.distance_to(b))
		if dmin > best_d:
			best_d = dmin
			best = cand
	return best


## Cổng (trong `portals`) dẫn tới map `to`; {} nếu không có.
static func find_to(portals: Array, to: String) -> Dictionary:
	for pt in portals:
		if str(pt.to) == to:
			return pt
	return {}


## Vị trí xuất hiện cạnh cổng: lệch về phía giữa map để không đứng ngay trong cổng.
static func arrive_pos(pt: Dictionary, size: Vector2) -> Vector2:
	var p: Vector2 = pt.pos
	var dir := (size / 2.0 - p).normalized()
	return p + dir * ARRIVE_OFFSET
