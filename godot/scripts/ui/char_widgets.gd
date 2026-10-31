extends RefCounted
## UI-21: các mảnh vẽ tay của bảng Nhân vật (Chỉ số / Túi đồ / Tài nguyên): chân dung trên bệ đá giữa rừng,
## huy hiệu hạng Thiên phú, hàng sao, bảng Lực chiến, cảnh lửa trại kèm câu dẫn. Chỉ vẽ — không giữ trạng thái game.

const UiTheme = preload("res://scripts/ui/ui_theme.gd")
const SpriteLib = preload("res://scripts/view/sprite_lib.gd")


## Chân dung: nền rừng đêm, hai đuốc lập loè, bệ đá tròn, nhân vật thở (idle) và thỉnh thoảng vung đòn.
class ScenePortrait:
	extends Control
	var class_id := "kiem-khach"
	var look := {}
	var t := 0.0

	func _init() -> void:
		clip_contents = true
		mouse_filter = MOUSE_FILTER_IGNORE

	func _process(delta: float) -> void:
		t += delta
		queue_redraw()

	func _draw() -> void:
		var w := size.x
		var h := size.y
		# trời → đất
		for i in 12:
			var k := i / 12.0
			draw_rect(Rect2(0, h * k, w, h / 12.0 + 1), Color("#0b1410").lerp(Color("#1b2a1d"), k))
		# hàng cây xa (tối) rồi gần
		var trees := ["tree-pine", "tree-0", "tree-1", "tree-pine", "tree-2"]
		for i in trees.size():
			SpriteLib.draw_env(self, trees[i], Vector2(w * (i + 0.2) / 4.4, h * 0.52), Color(0.3, 0.42, 0.36, 0.95), 0.9, i % 2 == 1)
		for i in 2:
			SpriteLib.draw_env(self, "tree-pine", Vector2(-6 + i * (w + 12), h * 0.7), Color(0.3, 0.4, 0.33), 1.1, i == 1)
		# sương mỏng
		draw_rect(Rect2(0, h * 0.5, w, h * 0.5), Color(0.55, 0.7, 0.6, 0.06))
		# đuốc hai bên
		for side: float in [-1.0, 1.0]:
			var base := Vector2(w / 2.0 + side * w * 0.36, h * 0.86)
			draw_line(base, base + Vector2(0, -34), Color("#3a2614"), 4.0)
			var fl := 1.0 + 0.18 * sin(t * 9.0 + side * 2.0) + 0.08 * sin(t * 23.0)
			var top := base + Vector2(0, -38)
			draw_circle(top, 22.0 * fl, Color(1.0, 0.55, 0.15, 0.10))
			draw_circle(top, 11.0 * fl, Color(1.0, 0.6, 0.2, 0.25))
			draw_circle(top, 4.5 * fl, Color(1.0, 0.82, 0.4, 0.95))
			draw_circle(top + Vector2(0, -3), 2.5 * fl, Color(1, 0.97, 0.8))
		# bệ đá
		var c := Vector2(w / 2.0, h * 0.83)
		draw_set_transform(c + Vector2(0, 10), 0.0, Vector2(1.0, 0.32))
		draw_circle(Vector2.ZERO, w * 0.36, Color("#2c2a28"))
		draw_set_transform(c, 0.0, Vector2(1.0, 0.32))
		draw_circle(Vector2.ZERO, w * 0.36, Color("#5d5a54"))
		draw_circle(Vector2.ZERO, w * 0.30, Color("#6f6b63"))
		draw_arc(Vector2.ZERO, w * 0.30, 0, TAU, 40, Color("#4a4742"), 2.0)
		draw_arc(Vector2.ZERO, w * 0.36, PI, TAU, 30, Color(1, 0.9, 0.7, 0.25), 2.0)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		# ánh đuốc hắt lên bệ
		draw_circle(c, w * 0.2, Color(1, 0.7, 0.3, 0.05))
		# nhân vật
		var phase := fmod(t, 6.0)
		var anim := "attack" if phase > 5.0 else "idle"
		var id := SpriteLib.hero_sprite(class_id, look)
		if SpriteLib.has_sprite(id):
			var frame := SpriteLib.frame_at(id, anim, phase - 5.0 if anim == "attack" else phase)
			SpriteLib.draw_hero(self, class_id, look, anim, frame, c + Vector2(0, 2), false, Color.WHITE, 2.1)


## Huy hiệu hạng Thiên phú: khiên lục giác màu hạng, chữ hạng ở giữa.
class RankBadge:
	extends Control
	var rank := "F"
	var color := Color.WHITE
	var t := 0.0

	func _init() -> void:
		custom_minimum_size = Vector2(76, 84)
		mouse_filter = MOUSE_FILTER_IGNORE

	func _process(delta: float) -> void:
		t += delta
		queue_redraw()

	func _draw() -> void:
		var c := size / 2.0
		var r := minf(size.x, size.y) * 0.46
		var pts := PackedVector2Array()
		for i in 6:
			var a := -PI / 2.0 + i * TAU / 6.0
			pts.append(c + Vector2(cos(a), sin(a)) * r)
		draw_circle(c, r * 1.05, Color(color, 0.12 + 0.06 * sin(t * 2.0)))
		draw_colored_polygon(pts, Color("#7a5a2a"))
		var inner := PackedVector2Array()
		for p in pts:
			inner.append(c + (p - c) * 0.84)
		draw_colored_polygon(inner, color.darkened(0.72))
		var loop := inner.duplicate()
		loop.append(inner[0])
		draw_polyline(loop, Color(color, 0.85), 2.0)
		var f := UiTheme.bold_font()
		var fs := 38 if rank.length() == 1 else (28 if rank.length() == 2 else 21)
		var y := c.y + fs * 0.36
		draw_string_outline(f, Vector2(0, y), rank, HORIZONTAL_ALIGNMENT_CENTER, size.x, fs, 6, Color(0, 0, 0, 0.9))
		draw_string(f, Vector2(0, y), rank, HORIZONTAL_ALIGNMENT_CENTER, size.x, fs, color.lightened(0.25))
		for k in 3:
			var a := t * 0.8 + k * TAU / 3.0
			draw_circle(c + Vector2(cos(a), sin(a)) * r * 0.98, 1.6, Color(1, 0.95, 0.7, 0.8))


## Hàng sao: filled trên total (sao rỗng tối).
class Stars:
	extends Control
	var filled := 0
	var total := 5

	func _init() -> void:
		custom_minimum_size = Vector2(5 * 20, 18)
		mouse_filter = MOUSE_FILTER_PASS

	func _draw() -> void:
		for i in total:
			var c := Vector2(9 + i * 20, 9)
			var pts := PackedVector2Array()
			for k in 10:
				var rr := 8.0 if k % 2 == 0 else 3.4
				var a := -PI / 2.0 + k * PI / 5.0
				pts.append(c + Vector2(cos(a), sin(a)) * rr)
			draw_colored_polygon(pts, Color("#ffc940") if i < filled else Color(1, 1, 1, 0.14))


## Bảng Lực chiến: tấm biển giữa hai cờ đỏ, hai thanh kiếm chéo, số lớn màu vàng.
class PowerBanner:
	extends Control
	var power := 0
	var t := 0.0

	func _init() -> void:
		custom_minimum_size = Vector2(300, 136)
		mouse_filter = MOUSE_FILTER_PASS

	func _process(delta: float) -> void:
		t += delta
		queue_redraw()

	func _draw() -> void:
		var w := size.x
		var cx := w / 2.0
		# cờ hai bên
		for side: float in [-1.0, 1.0]:
			var x := cx + side * (w / 2.0 - 30.0)
			var flag := PackedVector2Array([Vector2(x - 16, 36), Vector2(x + 16, 36), Vector2(x + 16, 118), Vector2(x, 106), Vector2(x - 16, 118)])
			draw_colored_polygon(flag, Color("#6e1a1e"))
			draw_polyline(PackedVector2Array([flag[0], flag[1], flag[2], flag[3], flag[4], flag[0]]), Color("#c9a45c"), 2.0)
			draw_line(Vector2(x - 20, 34), Vector2(x + 20, 34), Color("#7a5a2a"), 4.0)
			UiTheme.FrameBox._diamond(get_canvas_item(), Vector2(x, 68), 6.0, Color("#c9a45c"))
		# tấm biển có góc vát
		var r := Rect2(cx - 92, 46, 184, 86)
		var plate := PackedVector2Array([r.position + Vector2(14, 0), Vector2(r.end.x - 14, r.position.y), Vector2(r.end.x, r.position.y + 14),
			Vector2(r.end.x, r.end.y - 14), Vector2(r.end.x - 14, r.end.y), Vector2(r.position.x + 14, r.end.y),
			Vector2(r.position.x, r.end.y - 14), Vector2(r.position.x, r.position.y + 14)])
		draw_colored_polygon(plate, Color("#1a120b"))
		var loop := plate.duplicate()
		loop.append(plate[0])
		draw_polyline(loop, Color("#c9a45c"), 2.5)
		var inner := PackedVector2Array()
		for p in plate:
			inner.append(r.get_center() + (p - r.get_center()) * Vector2(0.94, 0.88))
		inner.append(inner[0])
		draw_polyline(inner, Color(0.79, 0.64, 0.36, 0.4), 1.0)
		UiTheme.FrameBox._diamond(get_canvas_item(), Vector2(cx, r.end.y), 6.0, Color("#f3d27a"))
		# chóp nhỏ giữa mép trên tấm biển + 2 kiếm nhỏ bắt chéo ngay trên chóp (không đè chữ)
		var crest := PackedVector2Array([Vector2(cx - 26, r.position.y + 1), Vector2(cx - 12, r.position.y - 12), Vector2(cx + 12, r.position.y - 12), Vector2(cx + 26, r.position.y + 1)])
		draw_colored_polygon(crest, Color("#1a120b"))
		draw_polyline(crest, Color("#c9a45c"), 2.0)
		var sword := SpriteLib.icon("stat-atk")
		if sword != null:
			var k := 1.6
			var o := Vector2(16, 16) * k
			var at := Vector2(cx, r.position.y - 14)
			draw_set_transform(at - o, 0.0, Vector2(k, k))
			draw_texture(sword, Vector2.ZERO)
			draw_set_transform(at + Vector2(o.x, -o.y), 0.0, Vector2(-k, k))
			draw_texture(sword, Vector2.ZERO)
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		var f := UiTheme.bold_font()
		draw_string(f, Vector2(r.position.x, r.position.y + 30), "LỰC CHIẾN", HORIZONTAL_ALIGNMENT_CENTER, r.size.x, 17, Color("#f3d27a"))
		var glow := 0.5 + 0.5 * sin(t * 2.2)
		var num := str(power)
		var fs := 40 if num.length() <= 5 else 32
		draw_string_outline(f, Vector2(r.position.x, r.end.y - 16), num, HORIZONTAL_ALIGNMENT_CENTER, r.size.x, fs, 8, Color(0.4, 0.22, 0.02, 0.5 + 0.3 * glow))
		draw_string(f, Vector2(r.position.x, r.end.y - 16), num, HORIZONTAL_ALIGNMENT_CENTER, r.size.x, fs, Color("#ffd877").lerp(Color("#fff1c0"), glow * 0.4))


## Cảnh lửa trại nhỏ ở cuối cột phải (lửa lập loè, cây hai bên, biển gỗ).
class CampScene:
	extends Control
	var t := 0.0

	func _init() -> void:
		clip_contents = true
		custom_minimum_size = Vector2(300, 84)
		mouse_filter = MOUSE_FILTER_IGNORE

	func _process(delta: float) -> void:
		t += delta
		queue_redraw()

	func _draw() -> void:
		var w := size.x
		var h := size.y
		for i in 10:
			var k := i / 10.0
			draw_rect(Rect2(0, h * k, w, h / 10.0 + 1), Color("#0d1512").lerp(Color("#2a2216"), k))
		for i in 4:
			SpriteLib.draw_env(self, "tree-pine" if i % 2 == 0 else "tree-1", Vector2(w * (i * 0.33), h * 0.66), Color(0.28, 0.36, 0.3), 0.85, i % 2 == 1)
		draw_set_transform(Vector2(w / 2.0, h * 0.86), 0.0, Vector2(1.0, 0.3))
		draw_circle(Vector2.ZERO, w * 0.42, Color("#3a2e1e"))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		var fire := Vector2(w / 2.0, h * 0.82)
		var fl := 1.0 + 0.15 * sin(t * 8.0) + 0.07 * sin(t * 19.0)
		draw_circle(fire + Vector2(0, -14), 60.0 * fl, Color(1, 0.55, 0.15, 0.08))
		draw_circle(fire + Vector2(0, -14), 30.0 * fl, Color(1, 0.6, 0.2, 0.14))
		if SpriteLib.has_env("campfire"):
			SpriteLib.draw_env(self, "campfire", fire, Color.WHITE, 1.0)
		else:
			draw_circle(fire + Vector2(0, -8), 8.0 * fl, Color(1, 0.7, 0.25))
		for k in 4:
			var life := fmod(t * 0.7 + k * 0.25, 1.0)
			draw_circle(fire + Vector2(sin(t * 2.0 + k) * 8.0, -20 - life * 50), 1.6 * (1.0 - life), Color(1, 0.8, 0.4, 1.0 - life))
		# biển gỗ bên phải
		var sx := w * 0.84
		draw_line(Vector2(sx, h * 0.9), Vector2(sx, h * 0.42), Color("#4a3320"), 4.0)
		draw_rect(Rect2(sx - 16, h * 0.38, 32, 16), Color("#6a4a2c"))
		draw_rect(Rect2(sx - 16, h * 0.38, 32, 16), Color("#2e1f12"), false, 1.5)
