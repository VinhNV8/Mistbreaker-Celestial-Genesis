extends RefCounted
## FX-1 (docs/36): bộ nguyên tố vẽ VFX kỹ năng kiểu cel-shade, bản GDScript của tools/art/skill_fx_kit.py.
## Vẽ vector ở toạ độ thế giới nên nét theo độ phân giải màn hình (HD, Q182). Mỗi hình vẽ 4 dải màu
## (viền tối → bão hoà → sáng → lõi) ở tỉ lệ BANDS; glow là 2 bậc phóng to (×1,35 / ×1,7) ghi vào
## Painter.glow để node lớp glow vẽ với BLEND_MODE_ADD. Painter có ci = null thì chỉ đếm lệnh (test headless).

const SpriteLib = preload("res://scripts/view/sprite_lib.gd")

const BANDS := [1.0, 0.72, 0.46, 0.2]
## Mặt đất góc nhìn 3/4: vòng / vòng trận nén trục y như bản thiết kế (skill_fx_kit.py SQ = 0.55).
const SQ := 0.55
const GLOW := [[1.35, 0.30], [1.75, 0.13]]


class Painter:
	var ci: CanvasItem = null
	var glow: Array = []   # [kind, data..., Color] — vẽ ở lớp cộng sáng
	var n := 0             # số lệnh vẽ (test)
	var bad := 0           # số đa giác lỗi (test)
	var tri_fix := 0       # số đa giác tự cắt đã thay bằng bao lồi (test)
	## Kiểm tra tam giác hoá từng đa giác (đắt: ~5 ms/khung khi 70 chiêu cùng lúc). Chỉ bật khi test (ci = null);
	## trong game các nguyên tố tự bảo đảm không tự cắt (trăng khuyết giới hạn độ dày) — §9.7.
	var strict := false

	func _init(canvas: CanvasItem = null) -> void:
		ci = canvas
		strict = canvas == null

	func poly(pts: PackedVector2Array, col: Color) -> void:
		if col.a <= 0.004:
			return
		if pts.size() < 3:
			bad += 1
			return
		if strict:
			for q in pts:
				if not (is_finite(q.x) and is_finite(q.y)):
					bad += 1
					return
		pts = fix_poly(pts)
		if pts.is_empty():
			return
		n += 1
		if ci:
			SpriteLib.poly(ci, pts, col)

	## Hình suy biến (diện tích ≈ 0, ví dụ cung độ dài 0 ở khung đầu) → bỏ; đa giác tự cắt (trăng khuyết quá dày,
	## gai sát nhau) Godot không tam giác hoá được → thay bằng bao lồi.
	func fix_poly(pts: PackedVector2Array) -> PackedVector2Array:
		var area := 0.0
		for i in pts.size():
			var a := pts[i]
			var b := pts[(i + 1) % pts.size()]
			area += a.x * b.y - b.x * a.y
		if absf(area) < 2.0:
			return PackedVector2Array()
		if strict and Geometry2D.triangulate_polygon(pts).is_empty():
			tri_fix += 1
			pts = Geometry2D.convex_hull(pts)
			if pts.size() < 4 or Geometry2D.triangulate_polygon(pts).is_empty():
				bad += 1
				return PackedVector2Array()
		return pts

	func line(a: Vector2, b: Vector2, col: Color, w: float) -> void:
		if col.a <= 0.004:
			return
		n += 1
		if ci:
			ci.draw_line(a, b, col, maxf(1.0, w), true)

	func polyline(pts: PackedVector2Array, col: Color, w: float) -> void:
		if col.a <= 0.004 or pts.size() < 2:
			return
		n += 1
		if ci:
			ci.draw_polyline(pts, col, maxf(1.0, w), true)

	func circle(c: Vector2, r: float, col: Color) -> void:
		if col.a <= 0.004 or r <= 0.3:
			return
		n += 1
		if ci:
			ci.draw_circle(c, r, col)

	func arc(c: Vector2, r: float, a0: float, a1: float, col: Color, w: float) -> void:
		if col.a <= 0.004 or r <= 0.5:
			return
		n += 1
		if ci:
			ci.draw_arc(c, r, a0, a1, maxi(12, int(r * absf(a1 - a0) / 6.0)), col, maxf(1.0, w), true)

	func gpoly(pts: PackedVector2Array, col: Color) -> void:
		if col.a > 0.004 and pts.size() >= 3:
			pts = fix_poly(pts)
			if not pts.is_empty():
				glow.append(["poly", pts, col])

	func gcircle(c: Vector2, r: float, col: Color) -> void:
		if col.a > 0.004 and r > 0.5:
			glow.append(["circle", c, r, col])

	func garc(c: Vector2, r: float, w: float, col: Color) -> void:
		if col.a > 0.004 and r > 0.5:
			glow.append(["arc", c, r, w, col])

	func gline(pts: PackedVector2Array, w: float, col: Color) -> void:
		if col.a > 0.004 and pts.size() >= 2:
			glow.append(["line", pts, w, col])


## Vẽ danh sách glow lên node lớp cộng sáng (material BLEND_MODE_ADD) rồi xoá.
static func flush_glow(ci: CanvasItem, glow: Array) -> void:
	for g in glow:
		match g[0]:
			"poly":
				SpriteLib.poly(ci, g[1], g[2])
			"circle":
				ci.draw_circle(g[1], g[2], g[3])
			"arc":
				ci.draw_arc(g[1], g[2], 0.0, TAU, maxi(16, int(g[2] / 3.0)), g[4], g[3], true)
			"line":
				ci.draw_polyline(g[1], g[3], g[2], true)
	glow.clear()


## Dải màu: [lõi, sáng, bão hoà (= màu glow), viền tối].
static func pal(core: String, light: String, mid: String, deep: String) -> Array:
	return [Color(core), Color(light), Color(mid), Color(deep)]


static func _a(c: Color, a: float) -> Color:
	return Color(c.r, c.g, c.b, c.a * clampf(a, 0.0, 1.0))


static func ease_out(t: float) -> float:
	t = clampf(t, 0.0, 1.0)
	return 1.0 - pow(1.0 - t, 3.0)


static func ease_in(t: float) -> float:
	t = clampf(t, 0.0, 1.0)
	return t * t * t


## Tiến độ 0..1 của khung f trong đoạn [a, b]; -1 nếu ngoài đoạn.
static func seg(f: float, a: float, b: float) -> float:
	if f < a or f > b:
		return -1.0
	return 0.0 if b == a else (f - a) / (b - a)


## Vẽ hình theo 4 dải + glow. gen(scale) trả PackedVector2Array của hình ở tỉ lệ đó.
static func banded(pa: Painter, gen: Callable, p: Array, alpha := 1.0, glow := 1.0, bands := BANDS) -> void:
	if alpha <= 0.01:
		return
	if glow > 0.0:
		for g in GLOW:
			pa.gpoly(gen.call(g[0]), _a(p[2], g[1] * glow * alpha))
	var cols := [p[3], p[2], p[1], p[0]]
	for i in 4:
		if bands[i] > 0.0:
			pa.poly(gen.call(bands[i]), _a(cols[i], alpha))


# ---------------------------------------------------------------- nguyên tố hình

## Vệt chém trăng khuyết: dày nhất ở `head` (0..1 dọc cung), nhọn hai đầu. squash nén trục y.
static func crescent(pa: Painter, c: Vector2, r: float, a0: float, a1: float, th: float, p: Array, alpha := 1.0,
		squash := 1.0, head := 0.65, glow := 1.0) -> void:
	if alpha <= 0.01:
		return
	var n := clampi(int(absf(a1 - a0) * r / 6.0), 8, 32)
	# hình dạng tính một lần: hướng (đã nén) + độ dày tương đối; các dải màu / glow chỉ đổi hệ số độ dày
	var dirs := PackedVector2Array()
	var prof := PackedFloat32Array()
	dirs.resize(n + 1)
	prof.resize(n + 1)
	for i in n + 1:
		var u := float(i) / n
		var a := lerpf(a0, a1, u)
		dirs[i] = Vector2(cos(a), sin(a) * squash)
		prof[i] = pow(sin(u / head * PI / 2.0), 0.8) if u < head else pow(maxf(0.0, cos((u - head) / (1.0 - head) * PI / 2.0)), 0.6)
	var gen := func(s: float) -> PackedVector2Array:
		var pts := PackedVector2Array()
		pts.resize(2 * n + 2)
		for i in n + 1:
			var t: float = minf(th * s * prof[i], r * 1.8) * 0.5  # vành trong luôn > 0 → không tự cắt
			pts[i] = c + dirs[i] * (r + t)
			pts[2 * n + 1 - i] = c + dirs[i] * (r - t)
		return pts
	banded(pa, gen, p, alpha, glow)


## Vệt thẳng: rộng w ở đầu p1, thon về đuôi p0 (rộng tail·w).
static func streak(pa: Painter, p0: Vector2, p1: Vector2, w: float, p: Array, alpha := 1.0, tail := 0.0, glow := 1.0) -> void:
	var d := p1 - p0
	if d.length() < 1.0:
		return
	var u := d.normalized()
	var nv := u.orthogonal()
	var gen := func(s: float) -> PackedVector2Array:
		var hw := w * s * 0.5
		var tw := hw * tail
		return PackedVector2Array([p0 + nv * tw, p1 + nv * hw, p1 + u * w * s * 0.6, p1 - nv * hw, p0 - nv * tw])
	banded(pa, gen, p, alpha, glow)


## Sao va chạm nhiều gai không đều.
static func star(pa: Painter, c: Vector2, r: float, n: int, p: Array, rot := 0.0, inner := 0.32, alpha := 1.0, seed := 0,
		glow := 1.2, squash := 1.0) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed * 7919 + 13
	var jit: Array = []
	for i in n:
		jit.append(rng.randf_range(0.7, 1.15))
	var gen := func(s: float) -> PackedVector2Array:
		var pts := PackedVector2Array()
		for i in n * 2:
			var a := rot + i * PI / n
			var rr: float = r * s * (jit[i / 2] if i % 2 == 0 else inner)
			pts.append(c + Vector2(cos(a) * rr, sin(a) * rr * squash))
		return pts
	banded(pa, gen, p, alpha, glow)


## Vòng xung kích / vòng đất (tròn như vùng gameplay).
static func ring(pa: Painter, c: Vector2, r: float, w: float, p: Array, alpha := 1.0, glow := 1.0, squash := SQ) -> void:
	if alpha <= 0.01 or r <= 1.0:
		return
	var pts := ellipse(c, r, squash)
	if glow > 0.0:
		pa.gline(pts, w * 3.0, _a(p[2], 0.28 * glow * alpha))
	pa.polyline(pts, _a(p[3], alpha), w)
	pa.polyline(pts, _a(p[2], alpha), w * 0.66)
	pa.polyline(pts, _a(p[1], alpha), maxf(1.0, w * 0.34))


## Điểm của elip khép kín (mặt đất 3/4).
static func ellipse(c: Vector2, r: float, squash := SQ) -> PackedVector2Array:
	var n := clampi(int(r / 4.0), 16, 64)
	var pts := PackedVector2Array()
	for i in n + 1:
		var a := TAU * i / n
		pts.append(c + Vector2(cos(a) * r, sin(a) * r * squash))
	return pts


## Hướng trên mặt đất (vector đơn vị nén trục y).
static func gp(a: float, squash := SQ) -> Vector2:
	return Vector2(cos(a), sin(a) * squash)


static func disc(pa: Painter, c: Vector2, r: float, p: Array, alpha := 1.0, glow := 1.0) -> void:
	if alpha <= 0.01 or r <= 0.5:
		return
	if glow > 0.0:
		pa.gcircle(c, r * 1.4, _a(p[2], 0.3 * glow * alpha))
		pa.gcircle(c, r * 1.9, _a(p[2], 0.12 * glow * alpha))
	var cols := [p[3], p[2], p[1], p[0]]
	for i in 4:
		pa.circle(c, r * BANDS[i], _a(cols[i], alpha))


static func poly(pa: Painter, pts: PackedVector2Array, p: Array, alpha := 1.0, glow := 0.8) -> void:
	var cen := Vector2.ZERO
	for q in pts:
		cen += q
	cen /= maxf(1.0, pts.size())
	var gen := func(s: float) -> PackedVector2Array:
		var out := PackedVector2Array()
		for q in pts:
			out.append(cen + (q - cen) * s)
		return out
	banded(pa, gen, p, alpha, glow, [1.0, 0.78, 0.5, 0.22])


## Vòng trận / vòng cảnh báo: 2 vòng + ký hiệu quanh vành.
static func decal(pa: Painter, c: Vector2, r: float, p: Array, rot := 0.0, runes := 8, alpha := 0.8, inner := true) -> void:
	ring(pa, c, r, 3.0, p, alpha, 0.6)
	if inner:
		ring(pa, c, r * 0.72, 1.8, p, alpha * 0.8, 0.3)
	for i in runes:
		var a := rot + i * TAU / runes
		var q := c + gp(a) * r * 0.86
		pa.poly(PackedVector2Array([q + Vector2(0, -4), q + Vector2(3, 0), q + Vector2(0, 4), q + Vector2(-3, 0)]), _a(p[1], alpha))
		pa.circle(q, 1.4, _a(p[0], alpha))


## Tia sét gãy khúc có nhánh phụ.
static func bolt(pa: Painter, p0: Vector2, p1: Vector2, p: Array, seed := 0, w := 4.0, alpha := 1.0, branches := 2, jag := 10.0) -> void:
	var d := p1 - p0
	var L := d.length()
	if L < 2.0 or alpha <= 0.01:
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = seed * 104729 + 7
	var nv := d.orthogonal().normalized()
	var n := maxi(3, int(L / 14.0))
	var pts := PackedVector2Array([p0])
	for i in range(1, n):
		pts.append(p0 + d * (float(i) / n) + nv * rng.randf_range(-jag, jag))
	pts.append(p1)
	var brs: Array = []
	for b in branches:
		var k := rng.randi_range(1, n - 1)
		var a := d.angle() + (1.0 if rng.randf() < 0.5 else -1.0) * rng.randf_range(0.5, 1.1)
		var ln := rng.randf_range(10.0, 26.0)
		brs.append(PackedVector2Array([pts[k], pts[k] + Vector2.from_angle(a) * ln * 0.5 + nv * rng.randf_range(-3, 3), pts[k] + Vector2.from_angle(a) * ln]))
	pa.gline(pts, w * 3.2, _a(p[2], 0.35 * alpha))
	var cols := [p[3], p[2], p[0]]
	var ws := [1.4, 0.95, 0.45]
	for i in 3:
		pa.polyline(pts, _a(cols[i], alpha), w * ws[i])
		for br in brs:
			pa.polyline(br, _a(cols[i], alpha), w * ws[i] * 0.55)


## Tia lửa bay ra rồi tắt; t = tiến độ 0..1 (âm = không vẽ).
static func sparks(pa: Painter, c: Vector2, t: float, n: int, dist: float, p: Array, seed := 0, up := false, grav := 0.0, size := 2.5) -> void:
	if t < 0.0 or t > 1.0:
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = seed * 31337 + 5
	var e := ease_out(t)
	for i in n:
		var a := rng.randf_range(0.0, TAU)
		var sp := rng.randf_range(0.45, 1.0) * dist
		var die := rng.randf_range(0.7, 1.0)
		var dir := Vector2(cos(a), sin(a) * 0.75)
		if up:
			dir = Vector2(cos(a) * 0.5, -absf(sin(a)) - 0.4)
		if t > die:
			continue
		var q := c + dir * sp * e + Vector2(0, grav * t * t * 40.0)
		var col: Color = p[0] if t < 0.3 else (p[1] if t < 0.6 else p[2])
		var sz := maxf(1.0, size * (1.0 - t * 0.6))
		pa.line(q - dir.normalized() * 6.0 * (1.0 - t), q, _a(p[2], 0.8), maxf(1.0, sz * 0.5))
		pa.poly(PackedVector2Array([q + Vector2(0, -sz), q + Vector2(sz, 0), q + Vector2(0, sz), q + Vector2(-sz, 0)]), col)
	pa.gcircle(c, dist * 0.5 * (1.0 - t), _a(p[2], 0.18 * (1.0 - t)))


## Khói / bụi tan: cụm tròn 2 tông, phình rồi teo.
static func smoke(pa: Painter, c: Vector2, t: float, n: int, r: float, col := Color(0.49, 0.45, 0.41), seed := 0,
		spread := 30.0, rise := 18.0) -> void:
	if t < 0.0 or t > 1.0:
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = seed * 7717 + 3
	var dark := Color(col.r * 0.62, col.g * 0.62, col.b * 0.62)
	var e := ease_out(t)
	for i in n:
		var a := rng.randf_range(0.0, TAU)
		var o := Vector2(cos(a), sin(a) * 0.5) * spread * rng.randf_range(0.3, 1.0)
		var q := c + o * (0.5 + e) + Vector2(0, -rise * e)
		var rr := r * rng.randf_range(0.6, 1.1) * (sin(minf(1.0, t * 1.25) * PI) * 0.9 + 0.1)
		if rr < 1.0:
			continue
		var al := 0.85 * (1.0 - t * 0.7)
		pa.circle(q, rr, Color(dark, al))
		pa.circle(q + Vector2(-rr * 0.18, -rr * 0.2), rr * 0.72, Color(col, al))


## Cột sáng thẳng đứng (triệu hồi, giáng thánh, buff).
static func pillar(pa: Painter, c: Vector2, w: float, h: float, p: Array, alpha := 1.0, glow := 1.3) -> void:
	var gen := func(s: float) -> PackedVector2Array:
		var ww := w * s * 0.5
		return PackedVector2Array([c + Vector2(-ww, 0), c + Vector2(-ww * 0.7, -h), c + Vector2(ww * 0.7, -h), c + Vector2(ww, 0),
			c + Vector2(ww * 0.6, ww * 0.4), c + Vector2(-ww * 0.6, ww * 0.4)])
	banded(pa, gen, p, alpha, glow)


## Khiên vòm: viền 3 dải + lưới lục giác + vệt phản quang + vết nứt.
static func dome(pa: Painter, c: Vector2, r: float, p: Array, k := 1.0, crack := 0, alpha := 0.7) -> void:
	var h := r * k
	var pts := PackedVector2Array()
	for i in 25:
		var a := PI + PI * i / 24.0
		pts.append(c + Vector2(cos(a) * r, sin(a) * h))
	for i in 13:
		var a := PI * i / 12.0
		pts.append(c + Vector2(cos(a) * r, -sin(a) * -r * 0.35))
	pa.gpoly(pts, _a(p[2], 0.5 * alpha))  # vòm sáng rõ như bản thiết kế (glow 0,9 + nền 0,28)
	pa.poly(pts, _a(p[2], 0.3 * alpha))
	var rim := pts.slice(0, 25)
	pa.polyline(rim, _a(p[3], alpha), 5.0)
	pa.polyline(rim, _a(p[1], alpha), 2.5)
	var hl := PackedVector2Array()
	for i in 6:
		var a := PI * 1.15 + PI * 0.25 * i / 5.0
		hl.append(c + Vector2(cos(a) * r * 0.82, sin(a) * h * 0.82))
	pa.polyline(hl, _a(p[0], alpha), 3.0)
	var step := maxf(9.0, r / 4.0)
	var y := c.y - h + step
	var row := 0
	while y < c.y:
		var x := c.x - r + (step * 0.5 if row % 2 else 0.0)
		while x < c.x + r:
			if pow((x - c.x) / r, 2) + pow((y - c.y) / maxf(1.0, h), 2) < 0.85:
				pa.circle(Vector2(x, y), 1.3, _a(p[1], alpha * 0.8))
			x += step
		y += step * 0.8
		row += 1
	var rng := RandomNumberGenerator.new()
	rng.seed = crack + 11
	for i in crack:
		var a := rng.randf_range(PI * 1.1, PI * 1.9)
		var q := c + Vector2(cos(a) * r * 0.9, sin(a) * h * 0.9)
		pa.polyline(PackedVector2Array([q, q + Vector2(rng.randf_range(-8, 8), rng.randf_range(5, 12)),
			q + Vector2(rng.randf_range(-12, 12), rng.randf_range(12, 20))]), _a(p[0], alpha), 1.5)


# ---------------------------------------------------------------- biểu tượng / đạn

static func sword(pa: Painter, c: Vector2, ang: float, ln: float, p: Array, alpha := 1.0, glow := 1.0) -> void:
	var u := Vector2.from_angle(ang)
	var nv := u.orthogonal()
	var tip := c + u * ln * 0.6
	var base := c - u * ln * 0.25
	var bw := maxf(2.0, ln * 0.09)
	poly(pa, PackedVector2Array([tip, base + nv * bw, base - nv * bw]), p, alpha, glow)
	pa.line(base + nv * bw * 2.2, base - nv * bw * 2.2, _a(p[3], alpha), 3.0)
	pa.line(base, base - u * ln * 0.18, _a(p[3], alpha), 3.0)


static func arrow(pa: Painter, c: Vector2, ang: float, ln: float, p: Array, alpha := 1.0, trail := 0.0, glow := 1.0) -> void:
	var u := Vector2.from_angle(ang)
	var nv := u.orthogonal()
	if trail > 0.0:
		streak(pa, c - u * (ln + trail), c - u * ln * 0.3, 5.0, p, alpha * 0.8, 0.0, glow * 0.7)
	var tail := c - u * ln
	pa.line(tail, c, _a(p[3], alpha), 2.0)
	pa.poly(PackedVector2Array([c + u * 6.0, c + nv * 3.5, c - nv * 3.5]), _a(p[0], alpha))
	pa.line(tail, tail - u * 4.0 + nv * 4.0, _a(p[1], alpha), 1.6)
	pa.line(tail, tail - u * 4.0 - nv * 4.0, _a(p[1], alpha), 1.6)
	pa.gcircle(c, 8.0, _a(p[2], 0.35 * glow * alpha))


static func shard(pa: Painter, c: Vector2, ang: float, ln: float, p: Array, alpha := 1.0, glow := 1.0) -> void:
	var u := Vector2.from_angle(ang)
	var nv := u.orthogonal()
	var w := ln * 0.28
	poly(pa, PackedVector2Array([c + u * ln * 0.6, c + nv * w, c - u * ln * 0.4, c - nv * w]), p, alpha, glow)


static func shield(pa: Painter, c: Vector2, s: float, p: Array, alpha := 1.0, glow := 1.0) -> void:
	poly(pa, PackedVector2Array([c + Vector2(-s, -s), c + Vector2(s, -s), c + Vector2(s, s * 0.2), c + Vector2(0, s * 1.25),
		c + Vector2(-s, s * 0.2)]), p, alpha, glow)
	pa.line(c + Vector2(0, -s * 0.7), c + Vector2(0, s * 0.8), _a(p[0], alpha), 1.5)
	pa.line(c + Vector2(-s * 0.6, -s * 0.2), c + Vector2(s * 0.6, -s * 0.2), _a(p[0], alpha), 1.5)


static func orb(pa: Painter, c: Vector2, r: float, p: Array, alpha := 1.0, glow := 1.4) -> void:
	disc(pa, c, r, p, alpha, glow)
	pa.circle(c + Vector2(-r * 0.35, -r * 0.35), maxf(1.0, r * 0.18), Color(1, 1, 1, alpha))


static func hammer(pa: Painter, c: Vector2, ang: float, ln: float, p: Array, alpha := 1.0, glow := 1.0) -> void:
	var u := Vector2.from_angle(ang)
	var nv := u.orthogonal()
	var hd := c + u * ln * 0.5
	pa.line(c - u * ln * 0.5, hd, _a(p[3], alpha), 3.5)
	var hw := ln * 0.32
	var hl := ln * 0.18
	poly(pa, PackedVector2Array([hd + nv * hw - u * hl, hd + nv * hw + u * hl, hd - nv * hw + u * hl, hd - nv * hw - u * hl]), p, alpha, glow)


## Ký hiệu trên đầu: "eye" (ngắm / khiêu khích), "stun" (choáng), "poison" (độc), "chain" (trói).
static func glyph(pa: Painter, c: Vector2, kind: String, s: float, p: Array, alpha := 1.0, spin := 0.0) -> void:
	match kind:
		"eye":
			pa.arc(c, s, PI * 1.15, PI * 1.85, _a(p[2], alpha), 2.0)
			pa.arc(c, s, PI * 0.15, PI * 0.85, _a(p[2], alpha), 2.0)
			pa.circle(c, s * 0.38, _a(p[0], alpha))
		"stun":
			for k in 3:
				var a := spin + k * TAU / 3.0
				star(pa, c + Vector2(cos(a) * s, sin(a) * s * 0.4), s * 0.42, 4, p, spin, 0.35, alpha, k, 0.4)
		"poison":
			pa.poly(PackedVector2Array([c + Vector2(0, -s), c + Vector2(s * 0.7, s * 0.3), c + Vector2(0, s * 0.8),
				c + Vector2(-s * 0.7, s * 0.3)]), _a(p[2], alpha))
			pa.circle(c + Vector2(-s * 0.2, 0), s * 0.2, _a(p[0], alpha))
		"chain":
			for k in range(-2, 3):
				pa.arc(c + Vector2(k * s * 0.55, 0), s * 0.35, 0.0, TAU, _a(p[2], alpha), 1.5)
	pa.gcircle(c, s * 1.6, _a(p[2], 0.3 * alpha))


static func glow_dot(pa: Painter, c: Vector2, r: float, col: Color, amount: float) -> void:
	if r <= 0.5 or amount <= 0.0:
		return
	pa.gcircle(c, r * 0.6, _a(col, 0.45 * amount))
	pa.gcircle(c, r, _a(col, 0.22 * amount))
	pa.gcircle(c, r * 1.4, _a(col, 0.09 * amount))
