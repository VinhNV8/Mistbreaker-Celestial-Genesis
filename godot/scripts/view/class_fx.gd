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


static func draw_shot(ci: CanvasItem, s) -> bool:
	var id := shot_sprite(s)
	if id == "" or not SpriteLib.has_env(id):
		return false
	SpriteLib.draw_env(ci, id, s.pos, Color.WHITE, 1.0, false, s.vel.angle())
	return true


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
