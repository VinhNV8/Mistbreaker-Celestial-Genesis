extends RefCounted
## AR-44: hiệu ứng kỹ năng cắt từ sprite sheet 5 lớp (env "fx-sheet-*", tools/art/class_sheet.py FX).
## Chỉ vẽ — không đổi logic. Thiếu hình thì mọi hàm trả false / không vẽ để world_view vẽ kiểu cũ.

const SpriteLib = preload("res://scripts/view/sprite_lib.gd")
const Skills2 = preload("res://scripts/core/skills2.gd")


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
const SHOT_LOOK := {"phikiem": [Color(0.8, 0.9, 1.0), 0.8], "thanhkiem": [Color(1.0, 0.86, 0.45), 1.35]}


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
	"kiemvuc": {"at": "self", "r": 100.0, "dur": 4.0, "aura": true},
	"huyetbao": {"at": "self", "r": 90.0, "dur": 0.5, "charge": 0.1},
	"huyetanh": {"at": "dir", "r": 60.0, "dur": 0.75, "fwd": 30.0},
	"nhatkiem": {"at": "dir", "r": 140.0, "dur": 0.95, "fwd": 170.0, "charge": 0.5, "rot": 0.709},
}


## Ghi một hiệu ứng thi triển vào danh sách của world_view (nếu kỹ năng có keyframe).
static func on_cast(list: Array, world, sk: Dictionary) -> void:
	var id := str(sk.get("id", ""))
	if not CAST_FX.has(id) or not SpriteLib.has_env("vfx-" + id):
		return
	list.append({"id": id, "t": 0.0, "ang": float(world.player.facing)})


static func cast_alive(f) -> bool:
	return f.t < float(CAST_FX[f.id].dur)


## charge → cast → impact: tụ lực nhỏ + nhấp nháy, bung đủ cỡ, rồi mờ dần (vùng kéo dài: mờ + xoay chậm). Tối đa 85% đậm để thấy quái phía sau.
static func draw_casts(ci: CanvasItem, world, list: Array) -> void:
	var p = world.player
	var base := 2.0 / (32.0 * SpriteLib.scale())
	for f in list:
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
		elif q.kind == "tt_ice" and q.t < Skills2.TTN_GAP and SpriteLib.has_env("fx-sheet-meteor-ice"):
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
