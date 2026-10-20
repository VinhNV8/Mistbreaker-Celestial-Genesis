extends RefCounted
## AR-30: nạp hình do tools/art/build_all.py sinh ra (assets/art_manifest.json) và vẽ frame.
## Logic game không phụ thuộc file này; thiếu hình thì world_view vẽ hình khối tạm như cũ.

const MANIFEST := "res://assets/art_manifest.json"

static var _data: Dictionary = {}
static var _loaded := false
static var _tex: Dictionary = {}


static func data() -> Dictionary:
	if not _loaded:
		_loaded = true
		var f := FileAccess.open(MANIFEST, FileAccess.READ)
		if f:
			var parsed = JSON.parse_string(f.get_as_text())
			if parsed is Dictionary:
				_data = parsed
	return _data


static func scale() -> float:
	return float(data().get("scale", 2))


static func texture(path: String) -> Texture2D:
	if _tex.has(path):
		return _tex[path]
	var t: Texture2D = null
	if ResourceLoader.exists(path):
		t = load(path) as Texture2D
	if t == null and FileAccess.file_exists(path):
		# Chưa chạy import (ví dụ vừa sinh hình xong): đọc thẳng file PNG.
		var img := Image.load_from_file(ProjectSettings.globalize_path(path))
		if img:
			t = ImageTexture.create_from_image(img)
	_tex[path] = t
	return t


static func has_sprite(id: String) -> bool:
	return data().get("sprites", {}).has(id)


static func icon(id: String) -> Texture2D:
	var path: String = data().get("icons", {}).get(id, "")
	return texture(path) if path != "" else null


static func item_icon(item: Dictionary) -> Texture2D:
	var unique := str(item.get("unique", ""))
	if unique != "" and data().get("icons", {}).has("item-" + unique):
		return icon("item-" + unique)
	return icon("item-" + str(item.get("slot", "")))


static func talent_icon(talent_id: String) -> Texture2D:
	return icon("talent-" + talent_id)


## Số frame của hoạt ảnh tại thời điểm t (giây kể từ khi bắt đầu hoạt ảnh).
static func frame_at(id: String, anim: String, t: float) -> int:
	var s: Dictionary = data().sprites[id]
	var a: Dictionary = s.anims.get(anim, s.anims.idle)
	var n := int(a.frames)
	var idx := int(floor(maxf(0.0, t) * float(a.fps)))
	return idx % n if a.loop else mini(idx, n - 1)


## Frame theo tiến độ 0..1 (dùng cho đòn đánh có thời lượng cố định).
static func frame_progress(id: String, anim: String, progress: float) -> int:
	var s: Dictionary = data().sprites[id]
	var a: Dictionary = s.anims.get(anim, s.anims.idle)
	return clampi(int(progress * float(a.frames)), 0, int(a.frames) - 1)


static func draw_frame(ci: CanvasItem, id: String, anim: String, frame: int, pos: Vector2, flip := false,
		modulate := Color.WHITE, size_mul := 1.0) -> void:
	var s: Dictionary = data().sprites.get(id, {})
	if s.is_empty():
		return
	var tex := texture(s.path)
	if tex == null:
		return
	var a: Dictionary = s.anims.get(anim, s.anims.idle)
	var w := float(s.w)
	var h := float(s.h)
	var region := Rect2(frame * w, float(a.row) * h, w, h)
	var k := scale() * size_mul * float(s.get("size_mul", 1.0))
	ci.draw_set_transform(pos, 0.0, Vector2(-k if flip else k, k))
	ci.draw_texture_rect_region(tex, Rect2(-Vector2(s.origin[0], s.origin[1]), Vector2(w, h)), region, modulate)
	ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


static func has_env(id: String) -> bool:
	return data().get("env", {}).has(id)


static func env_texture(id: String) -> Texture2D:
	var e: Dictionary = data().get("env", {}).get(id, {})
	return texture(e.path) if not e.is_empty() else null


static func draw_env(ci: CanvasItem, id: String, pos: Vector2, modulate := Color.WHITE, size_mul := 1.0, flip := false, rotation := 0.0) -> void:
	var e: Dictionary = data().get("env", {}).get(id, {})
	if e.is_empty():
		return
	var tex := texture(e.path)
	if tex == null:
		return
	var k := scale() * size_mul
	ci.draw_set_transform(pos, rotation, Vector2(-k if flip else k, k))
	ci.draw_texture(tex, -Vector2(e.origin[0], e.origin[1]), modulate)
	ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


## Tô một đa giác bằng ô đất lặp lại (cần texture_repeat bật trên CanvasItem).
static func fill_polygon(ci: CanvasItem, points: PackedVector2Array, tile_id: String, modulate := Color.WHITE) -> bool:
	var tex := env_texture(tile_id)
	if tex == null:
		return false
	var span := float(tex.get_width()) * scale()
	var uvs := PackedVector2Array()
	for p in points:
		uvs.append(p / span)
	ci.draw_colored_polygon(points, modulate, uvs, tex)
	return true
