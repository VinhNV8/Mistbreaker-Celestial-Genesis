extends RefCounted
## GN-4 E6 (docs/45 §9): cao độ địa hình (chỉ hình — không đổi đường đi / va chạm).
##  • Vách đá bao quanh mép bản đồ: mép trên (phía xa) là vách đứng nhìn thấy mặt đá + mặt bằng cao phía sau; hai mép bên
##    là mặt bằng cao có viền đá; mép dưới là gờ vực đổ xuống tối dần. Camera được nhìn ra ngoài mép map (MARGIN) để thấy vách
##    khi đi sát mép — người chơi vẫn bị chặn ở mép map như cũ (chân vách = ranh giới cũ).
##  • Thành hồ / hố: hồ nước (vùng 4) và hố dung nham (vùng 5) có thành đất / đá ở mép XA (nửa trên, phía trong); cồn đất giữa
##    nước (map ngập 4-2) có mặt đất đổ xuống ở mép GẦN (nửa dưới, phía ngoài).
## Vùng 7 (đảo mây — đã có vách đảo), hang, dungeon: không có vách viền.

const SpriteLib = preload("res://scripts/view/sprite_lib.gd")
const Maps = preload("res://scripts/data/maps.gd")

const ROCK := {1: "cliff-rock", 2: "cliff-rock", 3: "cliff-sand", 4: "cliff-rock", 5: "cliff-basalt", 6: "cliff-ice",
	8: "cliff-void", 9: "cliff-marble"}
## Camera nhìn ra ngoài mép map: trên (vách + mặt bằng), hai bên, dưới (gờ vực).
const MARGIN_TOP := 170.0
const MARGIN_SIDE := 90.0
const MARGIN_BOTTOM := 110.0
const FACE_H := 112.0
const CHUNK := 400.0
## Thành hồ / hố: cao tối đa (px) ở giữa cung xa.
const BANK_H := 28.0


static func rock_of(world) -> String:
	return str(ROCK.get(int(world.map.get("region", 1)), ""))


static func enabled(world) -> bool:
	return rock_of(world) != "" and not bool(world.map.get("cave", false)) and Maps.MAPS.has(str(world.map_id)) \
		and SpriteLib.hd_enabled() and SpriteLib.has_env(rock_of(world))


## [trên, bên, dưới] camera được nhìn ra ngoài map (0 khi không có vách).
static func margins(world) -> Vector3:
	if not enabled(world):
		return Vector3.ZERO
	return Vector3(MARGIN_TOP, MARGIN_SIDE, MARGIN_BOTTOM)


## Mép lượn (cùng hình mỗi khung).
static func _wob(x: float, seed: float) -> float:
	return 7.0 * sin(x * 0.011 + seed) + 4.0 * sin(x * 0.037 + seed * 2.3) + 2.0 * sin(x * 0.091 + seed * 0.7)


static func draw_border(ci: CanvasItem, world, view: Rect2) -> void:
	if not enabled(world):
		return
	var size: Vector2 = world.world_size
	var rock := rock_of(world)
	var ground := str(world.map.get("ground", "tile-grass-0"))
	var high := Color(0.62, 0.62, 0.66)
	# hai bên: mặt bằng cao (tối hơn) + viền đá
	for side in [0, 1]:
		var x_edge := 0.0 if side == 0 else size.x
		var out := -1.0 if side == 0 else 1.0
		var band := Rect2(x_edge - MARGIN_SIDE if side == 0 else x_edge, -MARGIN_TOP, MARGIN_SIDE, size.y + MARGIN_TOP + MARGIN_BOTTOM)
		if not view.intersects(band):
			continue
		var y0 := maxf(band.position.y, view.position.y - CHUNK)
		var y1 := minf(band.end.y, view.end.y + CHUNK)
		var y := floorf(y0 / CHUNK) * CHUNK
		while y < y1:
			var e := PackedVector2Array()
			var n := 10
			for i in n + 1:
				var yy := y + CHUNK * i / n
				e.append(Vector2(x_edge + out * (8.0 + _wob(yy, 1.7 + side)), yy))
			var poly := PackedVector2Array([Vector2(x_edge + out * MARGIN_SIDE * 1.5, y)]) + e 				+ PackedVector2Array([Vector2(x_edge + out * MARGIN_SIDE * 1.5, y + CHUNK)])
			SpriteLib.fill_polygon(ci, poly, ground, high)
			# viền đá (mặt vách bên lộ một dải mỏng)
			var rim := PackedVector2Array(e)
			var inner := PackedVector2Array()
			for p in e:
				inner.append(p + Vector2(out * 14.0, 0))
			inner.reverse()
			SpriteLib.fill_polygon(ci, rim + inner, rock, Color(0.85, 0.85, 0.85))
			ci.draw_polyline(e, Color(0.05, 0.04, 0.03, 0.45), 3.0, true)
			y += CHUNK
	# mép trên: mặt bằng cao + vách đứng
	var top_band := Rect2(-MARGIN_SIDE, -MARGIN_TOP, size.x + 2.0 * MARGIN_SIDE, MARGIN_TOP + 30.0)
	if view.intersects(top_band):
		var x := floorf(maxf(-MARGIN_SIDE, view.position.x - CHUNK) / CHUNK) * CHUNK
		var x1 := minf(size.x + MARGIN_SIDE, view.end.x + CHUNK)
		while x < x1:
			var lip := PackedVector2Array()
			var foot := PackedVector2Array()
			var n := 16
			for i in n + 1:
				var xx := x + CHUNK * i / n
				lip.append(Vector2(xx, -FACE_H + 2.4 * _wob(xx, 0.4)))
				foot.append(Vector2(xx, 2.0 + 0.5 * _wob(xx, 3.1)))
			var plate := PackedVector2Array([Vector2(x, -MARGIN_TOP * 1.6)]) + lip + PackedVector2Array([Vector2(x + CHUNK, -MARGIN_TOP * 1.6)])
			plate.reverse()
			SpriteLib.fill_polygon(ci, plate, ground, high)
			var rf := PackedVector2Array(foot)
			rf.reverse()
			SpriteLib.fill_polygon(ci, lip + rf, rock)
			# mặt vách tối dần xuống chân (khuất nắng) + đọng bóng chân vách
			var cols := PackedColorArray()
			for i in lip.size():
				cols.append(Color(0, 0, 0, 0.0))
			for i in rf.size():
				cols.append(Color(0.02, 0.02, 0.04, 0.42))
			ci.draw_polygon(lip + rf, cols)
			var ao := PackedVector2Array(foot)
			var ao2 := PackedVector2Array()
			for p in foot:
				ao2.append(p + Vector2(0, 26))
			ao2.reverse()
			var acols := PackedColorArray()
			for i in foot.size():
				acols.append(Color(0.02, 0.02, 0.04, 0.32))
			for i in ao2.size():
				acols.append(Color(0.02, 0.02, 0.04, 0.0))
			ci.draw_polygon(ao + ao2, acols)
			# gờ mép trên: viền tối + vệt sáng nắng
			ci.draw_polyline(lip, Color(0.05, 0.04, 0.03, 0.55), 4.0, true)
			var hl := PackedVector2Array()
			for p in lip:
				hl.append(p + Vector2(0, 3))
			ci.draw_polyline(hl, Color(1.0, 0.96, 0.85, 0.28), 2.0, true)
			x += CHUNK
	# mép dưới: gờ vực đổ xuống, tối dần
	var bot_band := Rect2(-MARGIN_SIDE, size.y - 10.0, size.x + 2.0 * MARGIN_SIDE, MARGIN_BOTTOM + 20.0)
	if view.intersects(bot_band):
		var x := floorf(maxf(-MARGIN_SIDE, view.position.x - CHUNK) / CHUNK) * CHUNK
		var x1 := minf(size.x + MARGIN_SIDE, view.end.x + CHUNK)
		while x < x1:
			var edge := PackedVector2Array()
			var n := 16
			for i in n + 1:
				var xx := x + CHUNK * i / n
				edge.append(Vector2(xx, size.y - 4.0 + 0.6 * _wob(xx, 2.2)))
			var lip_in := PackedVector2Array()
			for p in edge:
				lip_in.append(p + Vector2(0, 22))
			lip_in.reverse()
			SpriteLib.fill_polygon(ci, edge + lip_in, rock, Color(0.7, 0.7, 0.72))
			var deep := PackedVector2Array()
			for p in edge:
				deep.append(Vector2(p.x, size.y + MARGIN_BOTTOM * 1.6))
			deep.reverse()
			var lip_out := PackedVector2Array(lip_in)
			lip_out.reverse()
			var cols := PackedColorArray()
			for i in lip_out.size():
				cols.append(Color(0.03, 0.03, 0.05, 0.75))
			for i in deep.size():
				cols.append(Color(0.02, 0.02, 0.03, 1.0))
			ci.draw_polygon(lip_out + deep, cols)
			ci.draw_polyline(edge, Color(1.0, 0.96, 0.85, 0.22), 2.0, true)
			x += CHUNK


## Thành hồ nước / hố dung nham / mặt đất đổ xuống của cồn giữa nước.
static func draw_banks(ci: CanvasItem, world, view: Rect2) -> void:
	if not (SpriteLib.hd_enabled() and Maps.MAPS.has(str(world.map_id))):
		return
	var wd = world.map.get("water", null)
	if wd != null:
		var earth := "cliff-rock" if SpriteLib.has_env("cliff-rock") else ""
		for z in wd.zones:
			var c: Vector2 = z[0]
			var r := float(z[1])
			if earth == "" or not view.grow(r + 40.0).has_point(c):
				continue
			if bool(wd.default):
				_crescent(ci, c, r, false, earth, Color(0.62, 0.58, 0.5))
			else:
				_crescent(ci, c, r, true, earth, Color(0.7, 0.66, 0.58))
	if SpriteLib.has_env("cliff-basalt"):
		for z in world.map.get("lava", []):
			var c: Vector2 = z[0]
			var r := float(z[1])
			if view.grow(r + 40.0).has_point(c):
				_crescent(ci, c, r, true, "cliff-basalt", Color.WHITE, Color(1.0, 0.5, 0.15, 0.7))


## Lưỡi liềm thành hố: far = true → nửa trên phía trong (thành xa của hố); false → nửa dưới phía ngoài (mặt đổ của cồn).
static func _crescent(ci: CanvasItem, c: Vector2, r: float, far: bool, tile: String, tint: Color, rim := Color(0, 0, 0, 0)) -> void:
	var h := minf(BANK_H, r * 0.14)
	var n := 28
	var outer := PackedVector2Array()
	var inner := PackedVector2Array()
	for i in n + 1:
		var a := (PI + PI * i / n) if far else (PI * i / n)
		var p := c + Vector2(cos(a), sin(a)) * r
		var k := absf(sin(a))
		outer.append(p)
		inner.append(p + Vector2(0, h * k))
	var rev := PackedVector2Array(inner)
	rev.reverse()
	var poly := outer + rev
	# Godot tam giác hoá theo toạ độ tuyệt đối — dời về gốc như SpriteLib.poly
	ci.draw_set_transform(c, 0.0, Vector2.ONE)
	var local := PackedVector2Array()
	for p in poly:
		local.append(p - c)
	var tex := SpriteLib.env_texture(tile)
	if tex != null:
		var span := float(tex.get_width()) / SpriteLib.px_of(SpriteLib.data().env[tile]) * SpriteLib.scale()
		var uvs := PackedVector2Array()
		for p in poly:
			uvs.append(p / span)
		ci.draw_colored_polygon(local, tint, uvs, tex)
	var cols := PackedColorArray()
	for i in outer.size():
		cols.append(Color(0, 0, 0, 0.0 if far else 0.15))
	for i in rev.size():
		cols.append(Color(0.02, 0.02, 0.04, 0.4 if far else 0.55))
	ci.draw_polygon(local, cols)
	var edge := PackedVector2Array()
	for p in (rev if far else outer):
		edge.append(p - c)
	ci.draw_polyline(edge, rim if rim.a > 0.0 else Color(0.05, 0.04, 0.03, 0.5), 2.0, true)
	ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
