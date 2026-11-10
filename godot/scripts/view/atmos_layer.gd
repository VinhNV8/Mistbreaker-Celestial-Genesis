extends Control
## VS-1 B4 + B5 (docs/44): lớp không khí + tiền cảnh, vẽ trong không gian màn hình giữa thế giới và vignette / HUD.
##  B4: cụm sương trôi chậm (neo theo thế giới), hạt bay theo vùng (lá, bụi, tuyết, tàn lửa, đom đóm…).
##  B5: tán lá / cành / đá mờ ở mép DƯỚI màn hình (phía gần camera của góc nhìn 3/4), trôi nhanh hơn nền
##      (thị sai ×FG_PARALLAX) → cảm giác có lớp ở gần camera. Độ đục ≤ FG_MAX_A, tự mờ khi người chơi / quái ở dưới (Q210).
## PF-02 (08/11, docs/44 §7): bỏ dải sương cố định ở mép trên, tia nắng xiên và tiền cảnh ở mép trên / nửa trên hai bên —
## người chơi thấy như "vệt mờ trên màn hình"; bỏ quầng mờ to sau mỗi mảng tiền cảnh (vừa nhoè vừa tốn tô điểm ảnh).
## Không cần hình: mọi thứ vẽ bằng ellipse / đa giác mềm theo bảng màu vùng (THEMES).
## main.gd gán world + cam (tâm camera, px thế giới) + zoom (camera) mỗi khung rồi queue_redraw().

const Settings = preload("res://scripts/core/settings.gd")
const SpriteLib = preload("res://scripts/view/sprite_lib.gd")

const FG_PARALLAX := 1.3
const MIST_PARALLAX := 1.12
const EDGE_BAND := 150.0
const FG_MAX_A := 0.5
## PF-02: tiền cảnh ở hai mép bên chỉ được xuống từ tỷ lệ chiều cao này trở xuống (nửa trên là phía "xa").
const FG_SIDE_FROM := 0.62

## mist: cụm sương; mote: [kiểu hạt, màu, số hạt]; fg: kiểu tiền cảnh + màu.
const THEMES := {
	"forest": {"mist": Color(0.85, 0.95, 0.92, 0.07), "mote": ["leaf", Color("#cfe39a"), 26], "fg": ["leaves", Color("#0b1f14")]},
	"plains": {"mist": Color(1, 1, 0.92, 0.05), "mote": ["seed", Color("#fff6d0"), 22], "fg": ["grass", Color("#16260f")]},
	"swamp": {"mist": Color(0.75, 0.88, 0.78, 0.10), "mote": ["firefly", Color("#d8ff7a"), 22], "fg": ["reeds", Color("#0d1a10")]},
	"desert": {"mist": Color(1.0, 0.88, 0.7, 0.06), "mote": ["dust", Color("#f3d9a8"), 30], "fg": ["rock", Color("#2a1a10")]},
	"ruins": {"mist": Color(1.0, 0.88, 0.7, 0.06), "mote": ["dust", Color("#f3d9a8"), 26], "fg": ["rock", Color("#2a1a10")]},
	"volcano": {"mist": Color(0.35, 0.3, 0.3, 0.10), "mote": ["ember", Color("#ffa040"), 30], "fg": ["rock", Color("#140806")]},
	"tundra": {"mist": Color(0.95, 0.98, 1.0, 0.09), "mote": ["snow", Color("#ffffff"), 40], "fg": ["pine", Color("#0c1820")]},
	"sky": {"mist": Color(1, 1, 1, 0.10), "mote": ["petal", Color("#ffd6e8"), 20], "fg": ["cloud", Color(1, 1, 1)]},
	"heaven": {"mist": Color(1, 0.97, 0.85, 0.09), "mote": ["spark", Color("#ffe39a"), 24], "fg": ["cloud", Color(1, 0.98, 0.9)]},
	"void": {"mist": Color(0.5, 0.35, 0.7, 0.10), "mote": ["mote", Color("#c9a8ff"), 26], "fg": ["rock", Color("#0c0614")]},
	"cave": {"mist": Color(0.6, 0.6, 0.7, 0.05), "mote": ["dust", Color("#c8c0b0"), 18], "fg": ["rock", Color("#08070a")]},
}

var world
## Tâm camera (px thế giới) và zoom camera — main gán mỗi khung.
var cam := Vector2.ZERO
var zoom := 1.0
var time := 0.0
var _blob: Texture2D


func _init() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)


func _process(delta: float) -> void:
	time += delta


static func theme_id(map: Dictionary) -> String:
	if bool(map.get("cave", false)):
		return "cave"
	if bool(map.get("desert", false)):
		return "desert" if str(map.get("decor", "")) != "ruins" else "ruins"
	var d := str(map.get("decor", "forest"))
	if d == "sky_ruins":
		return "sky"
	return d if THEMES.has(d) else "forest"


static func enabled() -> bool:
	return SpriteLib.hd_enabled() and bool(Settings.values.get("depth_fx", true))


## Điểm thế giới → toạ độ lớp này (1 px thế giới = zoom px giao diện).
func to_screen(p: Vector2, parallax := 1.0) -> Vector2:
	return (p - cam) * zoom * parallax + size / 2.0


func _draw() -> void:
	if world == null or not enabled() or world.travel_timer > 0.0:
		return
	if _blob == null:
		_blob = load("res://scripts/view/world_view.gd")._soft_blob()
	var th: Dictionary = THEMES[theme_id(world.map)]
	_draw_mist(th.mist)
	_draw_motes(th.mote)
	_draw_foreground(th.fg)


## Cụm sương lớn trôi chậm theo gió, neo theo thế giới với thị sai MIST_PARALLAX (lặp lại theo ô).
func _draw_mist(c: Color) -> void:
	if c.a <= 0.0:
		return
	var tile := Vector2(1400, 1000)
	var drift := Vector2(time * 9.0, time * 2.0)
	for i in 7:
		var base := Vector2(fposmod(i * 523.7, tile.x), fposmod(i * 311.3 + i * i * 37.0, tile.y))
		var sp := (base + drift - cam * zoom * MIST_PARALLAX)
		sp = Vector2(fposmod(sp.x, tile.x), fposmod(sp.y, tile.y)) - tile * 0.15
		var r := Vector2(260.0 + 60.0 * (i % 3), 110.0 + 30.0 * (i % 2))
		for ox in [0.0, tile.x]:
			for oy in [0.0, tile.y]:
				var p: Vector2 = sp + Vector2(ox, oy)
				if p.x + r.x < 0.0 or p.x - r.x > size.x or p.y + r.y < 0.0 or p.y - r.y > size.y:
					continue
				var k := 0.7 + 0.3 * sin(time * 0.5 + i)
				draw_texture_rect(_blob, Rect2(p - r, r * 2.0), false, Color(c, c.a * k))


## Hạt bay theo vùng (thị sai 1,1 — trôi ở trên mặt đất).
func _draw_motes(m: Array) -> void:
	var kind: String = m[0]
	var col: Color = m[1]
	var n: int = m[2]
	var area := size + Vector2(80, 80)
	for i in n:
		var sd := float(i) * 12.9898
		var bx := fposmod(sin(sd) * 43758.5453, 1.0) * area.x
		var by := fposmod(sin(sd * 1.7) * 24634.6345, 1.0) * area.y
		var spd := 0.6 + fposmod(sin(sd * 3.1) * 9631.1, 1.0) * 0.8
		var v := _mote_vel(kind) * spd
		var wob := Vector2(sin(time * 1.3 + i) * 10.0, cos(time * 0.9 + i * 0.7) * 6.0)
		var p := Vector2(bx, by) + v * time + wob - cam * zoom * 1.1
		p = Vector2(fposmod(p.x, area.x), fposmod(p.y, area.y)) - Vector2(40, 40)
		var tw := 0.55 + 0.45 * sin(time * 2.0 + i * 1.3)
		match kind:
			"leaf", "petal":
				var a := time * 1.5 + i
				var d := Vector2.from_angle(a) * 3.5
				draw_colored_polygon(PackedVector2Array([p - d, p + Vector2(-d.y, d.x) * 0.5, p + d, p - Vector2(-d.y, d.x) * 0.5]), Color(col, 0.55))
			"snow":
				draw_circle(p, 1.4 + spd, Color(col, 0.75))
			"ember", "firefly", "spark", "mote":
				draw_texture_rect(_blob, Rect2(p - Vector2(6, 6), Vector2(12, 12)), false, Color(col, 0.35 * tw))
				draw_circle(p, 1.3, Color(col.lightened(0.4), 0.9 * tw))
			_:
				draw_circle(p, 1.2, Color(col, 0.35 * tw))


static func _mote_vel(kind: String) -> Vector2:
	match kind:
		"snow":
			return Vector2(-14, 38)
		"ember":
			return Vector2(8, -30)
		"spark", "mote", "firefly":
			return Vector2(4, -8)
		"dust", "seed":
			return Vector2(34, 4)
	return Vector2(22, 14)


## B5: tiền cảnh ở dải mép màn hình, neo theo thế giới (lặp ô) với thị sai FG_PARALLAX.
func _draw_foreground(fg: Array) -> void:
	var kind: String = fg[0]
	var col: Color = fg[1]
	var tile := Vector2(1100, 820)
	var focus: Array = _focus_points()
	for i in 6:
		var base := Vector2(fposmod(i * 377.0 + 90.0, tile.x), fposmod(i * 251.0 + i * i * 53.0, tile.y))
		var sp := base - cam * zoom * FG_PARALLAX
		sp = Vector2(fposmod(sp.x, tile.x), fposmod(sp.y, tile.y))
		for ox in [-tile.x, 0.0, tile.x]:
			for oy in [-tile.y, 0.0, tile.y]:
				var p: Vector2 = sp + Vector2(ox, oy)
				var edge := fg_edge(p, size)
				if edge > EDGE_BAND * 0.5 or edge < -120.0:
					continue
				# đậm nhất sát mép, mờ dần khi vào trong
				var a := FG_MAX_A * clampf(0.75 - edge / EDGE_BAND, 0.0, 1.0)
				for f in focus:
					if p.distance_to(f) < 170.0:
						a *= 0.35
						break
				if a > 0.02:
					_fg_piece(kind, p, col, a, i)


## PF-02: khoảng cách tới mép được phép có tiền cảnh — mép dưới, và hai mép bên chỉ ở phần dưới (y > FG_SIDE_FROM·cao).
## Mép trên là phía "xa" của góc nhìn 3/4: không bao giờ có tiền cảnh (trước đây chùm lá tối ở đó trông như vệt mờ).
static func fg_edge(p: Vector2, sz: Vector2) -> float:
	var edge := sz.y - p.y
	if p.y > sz.y * FG_SIDE_FROM:
		edge = minf(edge, minf(p.x, sz.x - p.x))
	return edge


## Điểm không được che: người chơi + quái gần (toạ độ màn hình).
func _focus_points() -> Array:
	var out: Array = [to_screen(world.player.pos)]
	for e in world.enemies:
		if e.dead:
			continue
		var s := to_screen(e.pos)
		if s.x > -50.0 and s.y > -50.0 and s.x < size.x + 50.0 and s.y < size.y + 50.0:
			out.append(s)
	return out


func _fg_piece(kind: String, p: Vector2, col: Color, a: float, i: int) -> void:
	var sway := sin(time * 0.8 + i) * 0.05
	match kind:
		"leaves":
			# chùm lá rộng: 13 lá nhọn xoè quanh gốc, 2 tông
			for k in 13:
				var ang := TAU * float(k) / 13.0 + float(i) * 0.7 + sway
				var ln := 70.0 + 28.0 * float((k * 5 + i) % 3)
				var c := col.lightened(0.07) if k % 3 == 0 else col
				_leaf(p + Vector2.from_angle(ang) * 26.0, ang, ln, ln * 0.36, Color(c, a))
		"pine":
			for k in 11:
				var ang := -PI * 0.5 + (float(k) / 10.0 - 0.5) * 2.6 + sway
				_leaf(p, ang, 110.0, 14.0, Color(col, a))
				for j in 4:
					var q := p + Vector2.from_angle(ang) * (30.0 + j * 20.0)
					_leaf(q, ang + 0.6, 26.0, 5.0, Color(col, a))
					_leaf(q, ang - 0.6, 26.0, 5.0, Color(col, a))
		"reeds", "grass":
			for k in 12:
				var ang := -PI * 0.5 + (float(k) / 11.0 - 0.5) * 1.1 + sway * 2.0
				var ln := 120.0 + 50.0 * float((k * 7 + i) % 3)
				_leaf(p + Vector2((k - 6) * 9.0, 30), ang, ln, 9.0 if kind == "reeds" else 7.0, Color(col, a))
		"rock":
			var pts := PackedVector2Array()
			for k in 9:
				var ang := TAU * float(k) / 9.0
				var r := 95.0 + 35.0 * sin(k * 2.3 + i)
				pts.append(p + Vector2(cos(ang) * r * 1.3, sin(ang) * r * 0.85))
			draw_colored_polygon(pts, Color(col, a * 0.9))
		"cloud":
			for k in 4:
				var o := Vector2(cos(k * 1.9 + i) * 70.0, sin(k * 1.3 + i) * 30.0) + Vector2(sway * 40.0, 0)
				var r := Vector2(110.0, 60.0) * (0.8 + 0.1 * k)
				draw_texture_rect(_blob, Rect2(p + o - r, r * 2.0), false, Color(col, a * 0.55))


## Một lá nhọn hai đầu từ gốc `at` theo góc `ang`, dài ln, rộng w.
func _leaf(at: Vector2, ang: float, ln: float, w: float, c: Color) -> void:
	var d := Vector2.from_angle(ang)
	var n := Vector2(-d.y, d.x)
	var pts := PackedVector2Array([at, at + d * ln * 0.25 + n * w * 0.42, at + d * ln * 0.55 + n * w * 0.5,
		at + d * ln, at + d * ln * 0.55 - n * w * 0.5, at + d * ln * 0.25 - n * w * 0.42])
	draw_colored_polygon(pts, c)
