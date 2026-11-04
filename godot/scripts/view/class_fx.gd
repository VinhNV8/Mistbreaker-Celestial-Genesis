extends RefCounted
## AR-44: hiệu ứng kỹ năng cắt từ sprite sheet 5 lớp (env "fx-sheet-*", tools/art/class_sheet.py FX).
## Chỉ vẽ — không đổi logic. Thiếu hình thì mọi hàm trả false / không vẽ để world_view vẽ kiểu cũ.

const SpriteLib = preload("res://scripts/view/sprite_lib.gd")
const Skills2 = preload("res://scripts/core/skills2.gd")
const Fx1 = preload("res://scripts/view/fx1.gd")


## Hình cho đạn của người chơi ("" = vẽ kiểu cũ). Hình hướng sang phải, xoay theo vận tốc.
static func shot_sprite(s) -> String:
	if s.kind == "fireball":
		return "fx-sheet-fireball"
	match str(s.skill):
		"wave":
			return "fx-sheet-tramphong"
		"pierce":
			return "fx-sheet-xuyentam"
		"banglao":
			return "fx-sheet-banglao"
	return ""


## Phi Kiếm / Thánh Kiếm Trảm bắn đạn "wave" mang skill riêng: dùng chung trăng khuyết Trảm Phong, tô màu + cỡ theo kỹ năng.
const SHOT_LOOK := {"phikiem": [Color(1.0, 0.88, 0.88), 0.8], "thanhkiem": [Color(1.0, 0.86, 0.45), 1.35]}


static func draw_shot(ci: CanvasItem, s) -> bool:
	var id := shot_sprite(s)
	var look: Array = SHOT_LOOK.get(str(s.skill), [Color.WHITE, 1.0])
	if id == "" and SHOT_LOOK.has(str(s.skill)):
		id = "fx-sheet-tramphong"
	if id == "" or not SpriteLib.has_env(id):
		return false
	SpriteLib.draw_env(ci, id, s.pos, look[0], look[1], false, s.vel.angle())
	return true


## AR-45b: keyframe "vfx-<kỹ năng>" (tools/art/skill_vfx.py, duyệt ở docs/design/skills/kiem-khach) vẽ khi thi triển.
## at: "self" = tâm người chơi, "dir" = phía trước theo hướng nhìn. r = bán kính phủ (px) để chọn cỡ.
## charge = thời gian tụ lực (hình nhỏ, nhấp nháy) trước khi bung; dur = tổng thời gian; aura = vùng kéo dài (mờ, xoay).
## rot = góc lệch để trục chính của hình trùng hướng nhìn. Trảm Phong / Kiếm Ý / Vạn Kiếm đã có hình riêng (fx-sheet-*).
const CAST_FX := {
	"spin": {"at": "self", "r": 125.0, "dur": 0.45},
	"dash": {"at": "dir", "r": 55.0, "dur": 0.4, "fwd": 30.0},
	"lientram": {"at": "dir", "r": 70.0, "dur": 0.7, "fwd": 35.0},
	"hongkiem": {"at": "self", "r": 80.0, "dur": 0.5, "charge": 0.12},
	"kiemvu": {"at": "self", "r": 100.0, "dur": 2.0, "aura": true},
	"phikiem": {"at": "dir", "r": 45.0, "dur": 0.3, "fwd": 40.0},
	"thanhkiem": {"at": "dir", "r": 70.0, "dur": 0.4, "fwd": 50.0},
	"kiemvuc": {"at": "self", "r": 100.0, "dur": 0.5},
	"huyetbao": {"at": "self", "r": 90.0, "dur": 0.5, "charge": 0.1},
	"huyetanh": {"at": "dir", "r": 60.0, "dur": 0.75, "fwd": 30.0},
	"nhatkiem": {"at": "dir", "r": 140.0, "dur": 0.95, "fwd": 170.0, "charge": 0.5, "rot": 0.709},
}

## AR-46: bộ asset nguồn ba pha, mỗi visual gắn với một mechanic thật thay vì tô màu lại FX khác.
const SOURCE_PHASED := {
	"dash": {"at": "dir", "dur": 0.4, "fwd": 30.0, "scale": 0.62},
	"tennay": {"at": "dir", "dur": 0.35, "fwd": 42.0, "scale": 0.52},
	"thietchuy": {"at": "self", "dur": 0.45, "scale": 0.78},
	"aulong": {"at": "self", "dur": 0.7, "scale": 0.82},
}

## AR-45d (03/11/2026): 10 kỹ năng Kiếm Khách dàn dựng chuyển động theo cơ chế thật (vùng đánh, đường lao, thời gian)
## bằng chính các mảnh hình gốc mà bộ review docs/design/skills/kiem-khach ghép từ master sheet: trăng khuyết Trảm Phong
## (T), vụ nổ Kiếm Ý (K), thanh kiếm Vạn Kiếm (V) — thay cho 3 ảnh tĩnh của storyboard (AR-45c, không giống ra chiêu).
## Trảm Phong, Kiếm Ý, Nguyệt Ảnh Liên Trảm, Vạn Kiếm Quy Tông giữ hình cũ.
const CHOREO := ["spin", "hongkiem", "kiemvu", "phikiem", "thanhkiem", "kiemvuc", "huyetbao", "huyetanh", "nhatkiem"]
const T := "fx-sheet-tramphong"
const K := "fx-sheet-kiemy"
const V := "fx-sheet-vankiem"
const BLOOD := Color(1.0, 0.55, 0.62)
const HOLY := Color(1.0, 0.9, 0.55)
## Mảnh hình T / K cỡ gốc (px) để quy bán kính kỹ năng ra size_mul.
const T_W := 37.0
const K_W := 35.0


## Ghi một hiệu ứng thi triển vào danh sách của world_view (nếu kỹ năng có keyframe).
static func on_cast(list: Array, world, sk: Dictionary) -> void:
	var id := str(sk.get("id", ""))
	if SOURCE_PHASED.has(id):
		if not SpriteLib.has_env("fx-skill-%s-p0" % id):
			return
	elif not CAST_FX.has(id):
		return
	if id in CHOREO:
		if not SpriteLib.has_env(T):
			return
	elif not SpriteLib.has_env("vfx-" + id):
		return
	list.append({"id": id, "t": 0.0, "ang": float(world.player.facing), "start": world.player.pos, "path": [world.player.pos]})


static func cast_alive(f) -> bool:
	var source: Dictionary = SOURCE_PHASED.get(f.id, {})
	return f.t < float(source.get("dur", CAST_FX.get(f.id, {}).get("dur", 0.0)))


## charge → cast → impact: tụ lực nhỏ + nhấp nháy, bung đủ cỡ, rồi mờ dần (vùng kéo dài: mờ + xoay chậm). Tối đa 85% đậm để thấy quái phía sau.
static func draw_casts(ci: CanvasItem, world, list: Array) -> void:
	var p = world.player
	var base := 2.0 / (32.0 * SpriteLib.scale())
	for f in list:
		if f.id in CHOREO:
			_choreo(ci, world, f)
			continue
		if f.id in SOURCE_PHASED:
			_draw_source_phase(ci, world, f)
			continue
		var c: Dictionary = CAST_FX[f.id]
		var t: float = f.t
		var dur: float = c.dur
		var charge: float = c.get("charge", 0.06)
		var k: float = float(c.r) * base
		var a := 0.85
		if t < charge:
			k *= lerpf(0.3, 0.6, t / charge)
			a = 0.45 + 0.25 * sin(t * 40.0)
		else:
			var u := (t - charge) / maxf(0.01, dur - charge)
			k *= minf(1.0, 0.75 + u * 2.5)
			a = 0.85 * clampf((1.0 - u) / 0.4, 0.0, 1.0)
			if c.get("aura", false):
				a *= 0.45
		var rot: float = float(f.ang) + float(c.get("rot", 0.0))
		var at: Vector2 = p.pos
		if c.at == "dir":
			at += Vector2.from_angle(f.ang) * float(c.get("fwd", 0.0)) * (0.35 if t < charge else 1.0)
		elif c.get("aura", false):
			rot = t * 2.0
		else:
			rot = 0.0
			a *= 0.75  # vòng quanh thân: nhạt hơn để vẫn thấy nhân vật ở giữa
		SpriteLib.draw_env(ci, "vfx-" + f.id, at, Color(1, 1, 1, a), k, false, rot)


static func _draw_source_phase(ci: CanvasItem, world, f) -> void:
	var spec: Dictionary = SOURCE_PHASED[f.id]
	var dur: float = spec.dur
	var phase := mini(2, int(f.t / maxf(0.01, dur) * 3.0))
	var at: Vector2 = world.player.pos
	if spec.at == "dir":
		at += Vector2.from_angle(f.ang) * float(spec.get("fwd", 0.0))
	var fade := clampf((dur - f.t) / (dur * 0.28), 0.0, 1.0)
	var rot: float = f.ang if spec.at == "dir" else 0.0
	SpriteLib.draw_env(ci, "fx-skill-%s-p%d" % [f.id, phase], at, Color(1, 1, 1, 0.9 * fade), float(spec.scale), false, rot)


## Tên Nảy: điểm hit lấy từ Bolt gameplay thật, giữ đường nảy vector và thêm marker asset ở các mục tiêu.
static func draw_bolt_accents(ci: CanvasItem, bolt) -> void:
	if str(bolt.skill) != "tennay" or not SpriteLib.has_env("fx-skill-tennay-p2"):
		return
	for index in range(1, bolt.points.size()):
		var alpha := 0.8 - float(index - 1) * 0.11
		SpriteLib.draw_env(ci, "fx-skill-tennay-p2", bolt.points[index], Color(1, 1, 1, maxf(0.3, alpha)), 0.24)


## Thiên Thạch: telegraph, vật thể rơi và impact đều bám đúng Meteor gameplay tại điểm ngắm.
static func draw_source_meteor(ci: CanvasItem, m) -> bool:
	if str(m.skill) != "meteor" or not SpriteLib.has_env("fx-skill-meteor-p0"):
		return false
	var k: float = 1.0 - float(m.timer) / 0.8
	SpriteLib.draw_env(ci, "fx-skill-meteor-p0", m.pos, Color(1, 1, 1, 0.7), 2.0)
	var rock: Vector2 = m.pos + Vector2(-140, -260) * (1.0 - k)
	SpriteLib.draw_env(ci, "fx-skill-meteor-p1", rock, Color(1, 1, 1, 0.95), 0.7)
	if k > 0.82:
		SpriteLib.draw_env(ci, "fx-skill-meteor-p2", m.pos, Color(1, 1, 1, (k - 0.82) / 0.18), 1.6)
	return true


## AR-45d: vẽ 1 khung của chiêu f (t giây sau khi ra chiêu). Toạ độ thế giới, bám theo người chơi.
static func _choreo(ci: CanvasItem, world, f) -> void:
	var p = world.player
	var t: float = f.t
	var dur: float = CAST_FX[f.id].dur
	var fade := clampf((dur - t) / (dur * 0.35), 0.0, 1.0)
	var dir := Vector2.from_angle(f.ang)
	# đường lao (Đột Kích, Huyết Ảnh): ghi vị trí người chơi theo khung hình
	var path: Array = f.path
	if p.pos.distance_to(path[-1]) > 6.0:
		path.append(p.pos)
	match f.id:
		"spin":
			# 4 trăng khuyết xoay 2 vòng quanh người, nở từ sát thân ra đủ 12,5 m
			if t < 0.08:
				_piece(ci, K, p.pos, 0.45 + 0.2 * sin(t * 60.0), 0.0, Color(1, 1, 1, 0.8))
				return
			var u := (t - 0.08) / (dur - 0.08)
			var r := lerpf(28.0, 112.0, minf(1.0, u * 1.6))
			for i in 4:
				var a: float = f.ang + i * TAU / 4.0 + u * TAU * 2.0
				_piece(ci, T, p.pos + Vector2.from_angle(a) * r, lerpf(0.7, 1.15, u), a + PI / 2.0, Color(1, 1, 1, 0.9 * fade))
		"dash", "huyetanh":
			# vệt trăng khuyết nối dài theo đường lao thật, mờ dần theo tuổi
			var col := BLOOD if f.id == "huyetanh" else Color.WHITE
			var n: int = path.size()
			for i in range(1, n):
				var a2: Vector2 = path[i - 1]
				var b2: Vector2 = path[i]
				var seg := b2 - a2
				var steps := maxi(1, int(seg.length() / 48.0))
				for s in steps:
					var q := a2 + seg * (float(s) + 0.5) / steps
					var age := float(n - i) / float(n)
					_piece(ci, T, q, 0.8, seg.angle(), Color(col, 0.85 * fade * (1.0 - 0.6 * age)))
			if path.size() < 2 and t < 0.15:
				_piece(ci, K, p.pos + dir * 20.0, 0.5, 0.0, Color(col, 0.8))
		"hongkiem", "huyetbao":
			# tụ lực ở giữa rồi nổ: vụ nổ phủ bán kính + 8 trăng khuyết bắn toả ra ngoài
			var col2 := BLOOD if f.id == "huyetbao" else Color.WHITE
			var ch: float = CAST_FX[f.id].charge
			var R: float = CAST_FX[f.id].r
			if t < ch:
				_piece(ci, K, p.pos, lerpf(1.1, 0.45, t / ch), t * 9.0, Color(col2, 0.6 + 0.3 * sin(t * 50.0)))
				return
			var v := (t - ch) / (dur - ch)
			_piece(ci, K, p.pos, 2.0 * R / (K_W * SpriteLib.scale()) * minf(1.0, 0.3 + v * 2.0), v * 2.0, Color(col2, 0.55 * fade))
			for i in 8:
				var a3 := i * TAU / 8.0 + 0.2
				_piece(ci, T, p.pos + Vector2.from_angle(a3) * lerpf(18.0, R, minf(1.0, v * 2.5)), 0.75, a3, Color(col2, 0.85 * fade))
		"kiemvu":
			# 4 thanh kiếm bay quanh người 10 m, mỗi nhịp (0,25 giây) loé 1 nhát chém trên vòng
			for i in 4:
				var a4 := t * 7.0 + i * TAU / 4.0
				var at4: Vector2 = p.pos + Vector2(cos(a4), sin(a4) * 0.7) * 72.0
				_piece(ci, V, at4, 0.75, a4 + PI, Color(1, 1, 1, 0.9 * fade))
			var tick := fposmod(t, 0.25) / 0.25
			var ta: float = floorf(t / 0.25) * 2.3 + f.ang
			_piece(ci, T, p.pos + Vector2.from_angle(ta) * 80.0, 0.9, ta + PI / 2.0, Color(1, 1, 1, 0.85 * (1.0 - tick) * fade))
		"phikiem", "thanhkiem":
			# loé lực ở mũi kiếm khi phóng (kiếm bay do draw_shot vẽ)
			var col3 := HOLY if f.id == "thanhkiem" else Color.WHITE
			var w2 := t / dur
			_piece(ci, K, p.pos + dir * lerpf(16.0, 34.0, w2), lerpf(0.45, 0.95, w2), t * 6.0, Color(col3, 0.85 * (1.0 - w2)))
		"kiemvuc":
			# mở vực: vụ nổ lan ra 10 m (vùng kéo dài do draw_domain vẽ)
			_piece(ci, K, p.pos, lerpf(0.5, 2.0 * 100.0 / (K_W * SpriteLib.scale()), minf(1.0, t / dur * 1.5)), t * 3.0, Color(1, 1, 1, 0.7 * fade))
		"nhatkiem":
			# tụ lực 0,5 giây ở mũi kiếm, rồi chuỗi trăng khuyết chạy dọc vệt chém 40 m
			var ch2: float = CAST_FX.nhatkiem.charge
			var d2: Vector2 = Vector2.from_angle(f.ang)
			if t < ch2:
				var g := t / ch2
				_piece(ci, K, p.pos + d2 * 26.0, lerpf(0.35, 1.15, g), t * 12.0, Color(1, 1, 1, 0.55 + 0.4 * g * absf(sin(t * 28.0))))
				return
			var v2 := (t - ch2) / (dur - ch2)
			var n2 := 11
			for i in n2:
				var appear := float(i) / n2 * 0.35
				if v2 < appear:
					break
				var life := clampf((v2 - appear) / 0.65, 0.0, 1.0)
				_piece(ci, T, p.pos + d2 * (30.0 + i * 36.0), 1.0, f.ang, Color(1, 1, 1, 0.92 * (1.0 - life * life)))


## Vẽ 1 mảnh hình gốc (T / K / V) ở pos, cỡ size_mul, xoay rot (T hướng phải, V mũi xuống).
static func _piece(ci: CanvasItem, id: String, pos: Vector2, k: float, rot: float, col: Color) -> void:
	if col.a <= 0.01:
		return
	SpriteLib.draw_env(ci, id, pos, col, k, false, rot)


## AR-45d: Kiếm Vực (vùng 10 m đi theo người, 4 giây, đánh mỗi 0,5 giây) — vòng vực + kiếm cắm quanh mép + kiếm rơi
## cắm xuống ở mỗi nhịp đánh (thay cho kiểu vẽ Mưa Băng dùng chung danh sách vùng).
static func draw_domain(ci: CanvasItem, world, z) -> void:
	var t: float = world.time
	var a := clampf(float(z.ticks) / 2.0 + 0.3, 0.0, 1.0)
	ci.draw_circle(z.pos, z.r, Color(1.0, 0.25, 0.3, 0.08 * a))
	ci.draw_arc(z.pos, z.r, 0.0, TAU, 48, Color(1.0, 0.35, 0.4, 0.6 * a), 2.0, true)
	if not SpriteLib.has_env(V):
		return
	for i in 8:
		var ang := i * TAU / 8.0 + t * 0.6
		_piece(ci, V, z.pos + Vector2(cos(ang), sin(ang) * 0.75) * z.r * 0.9, 0.55, 0.0, Color(1, 1, 1, 0.75 * a))
	var fall := 1.0 - clampf(float(z.timer) / float(z.get("gap", 0.5)), 0.0, 1.0)
	var h := int(z.ticks) * 47 + 13
	var at: Vector2 = z.pos + Vector2(cos(h * 0.7), sin(h * 0.7) * 0.75) * z.r * (0.25 + float(h % 50) / 100.0)
	_piece(ci, V, at + Vector2(0, -90.0 * (1.0 - fall)), 0.9, 0.0, Color(1, 1, 1, (0.4 + 0.6 * fall) * a))


## Thiên Tiễn: mũi tên trời rơi thẳng xuống (fall 0..1).
static func draw_rain_drop(ci: CanvasItem, z, at: Vector2, fall: float) -> bool:
	if str(z.skill) != "thientien" or not SpriteLib.has_env("fx-sheet-thientien"):
		return false
	SpriteLib.draw_env(ci, "fx-sheet-thientien", at + Vector2(0, -90) * (1.0 - fall), Color(1, 1, 1, 0.4 + 0.6 * fall))
	return true


## Thiên Thạch / đợt lửa Thiên Tai: thiên thạch lửa ở vị trí rock (đầu thiên thạch = gốc hình).
static func draw_meteor_rock(ci: CanvasItem, rock: Vector2) -> bool:
	if not SpriteLib.has_env("fx-sheet-meteor-fire"):
		return false
	SpriteLib.draw_env(ci, "fx-sheet-meteor-fire", rock, Color.WHITE, 1.4)
	return true


## Vẽ phủ: hào quang Kiếm Ý, kiếm khí Vạn Kiếm Quy Tông cắm quanh người, đợt băng Thiên Tai rơi xuống.
static func draw_over(ci: CanvasItem, world) -> void:
	var st = world.sk2
	var p = world.player
	var t: float = world.time
	if st.kiemy_t > 0.0 and SpriteLib.has_env("fx-sheet-kiemy"):
		var k := 0.85 + 0.15 * sin(t * 8.0)
		SpriteLib.draw_env(ci, "fx-sheet-kiemy", p.pos + Vector2(0, -22), Color(1, 1, 1, 0.45 * minf(1.0, st.kiemy_t)), k, false, t * 1.5)
	var vk := false
	for q in st.queue:
		if q.skill == "vankiem":
			vk = true
		elif q.kind == "tt_ice" and q.t < Skills2.TTN_GAP and SpriteLib.has_env("fx-sheet-meteor-ice") and not Fx1.active("thienhoa"):
			var k2: float = 1.0 - q.t / Skills2.TTN_GAP
			SpriteLib.draw_env(ci, "fx-sheet-meteor-ice", q.pos + Vector2(-140, -260) * (1.0 - k2), Color.WHITE, 1.4)
	if vk and SpriteLib.has_env("fx-sheet-vankiem"):
		for i in 8:
			var fall := fposmod(t * 3.0 + i * 0.37, 1.0)
			var h := int(t * 3.0 + i * 0.37) * 31 + i * 17
			var ang := float(h % 360) * PI / 180.0
			var r := Skills2.VK_R * (0.25 + 0.7 * float((h * 7) % 100) / 100.0)
			var at: Vector2 = p.pos + Vector2(cos(ang) * r, sin(ang) * r * 0.6)
			SpriteLib.draw_env(ci, "fx-sheet-vankiem", at + Vector2(0, -80) * (1.0 - minf(1.0, fall * 2.5)),
					Color(1, 1, 1, 1.0 - fall * 0.8), 1.2)
