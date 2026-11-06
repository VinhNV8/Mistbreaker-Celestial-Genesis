extends RefCounted
## AR-30: nạp hình do tools/art/build_all.py sinh ra (assets/art_manifest.json) và vẽ frame.
## Logic game không phụ thuộc file này; thiếu hình thì world_view vẽ hình khối tạm như cũ.
## UI-40 (docs/35): lớp phủ HD — manifest["hd"] {sprites, env, icons} đè lên mục cùng id khi bật Đồ hoạ HD
## (Settings "hd_art"). Mục HD có "px" (px ảnh / px logic): vẽ chia tỉ lệ cho px nên kích thước trong game giữ
## nguyên; texture HD nạp kèm mipmap, lọc Linear (CanvasTexture) — hình pixel cũ vẫn lọc Nearest như trước.

const MANIFEST := "res://assets/art_manifest.json"

static var _data: Dictionary = {}
static var _loaded := false
static var _tex: Dictionary = {}
static var _hd := true


static func data() -> Dictionary:
	if not _loaded:
		_loaded = true
		_data = {}
		var f := FileAccess.open(MANIFEST, FileAccess.READ)
		if f:
			var parsed = JSON.parse_string(f.get_as_text())
			if parsed is Dictionary:
				_data = parsed
				if _hd and parsed.has("hd"):
					_data = parsed.duplicate(true)
					for sec in ["sprites", "env", "icons"]:
						var over: Dictionary = parsed.hd.get(sec, {})
						for id in over:
							_data[sec][id] = over[id]
	return _data


## UI-40: bật / tắt hình HD (Cài đặt) — nạp lại manifest.
static func set_hd(on: bool) -> void:
	if on == _hd and _loaded:
		return
	_hd = on
	_loaded = false
	_tex = {}


static func hd_enabled() -> bool:
	return _hd


## px ảnh trên 1 px logic của mục sprite / env (1 = hình pixel).
static func px_of(entry: Dictionary) -> float:
	return maxf(1.0, float(entry.get("px", 1.0)))


## Kích thước logic (px pixel art) của sprite id — ô chân dung, khung mục tiêu… tính như hình pixel.
static func logical_size(id: String) -> Vector2:
	var s: Dictionary = data().get("sprites", {}).get(id, {})
	if s.is_empty():
		return Vector2.ZERO
	return Vector2(float(s.w), float(s.h)) / px_of(s)


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
	if t != null and path.begins_with("res://assets/hd/"):
		t = _smooth(t)
	_tex[path] = t
	return t


## UI-40: hình HD thu nhỏ nhiều lần khi vẽ → mipmap + lọc Linear (không phụ thuộc lọc Nearest của node vẽ).
static func _smooth(t: Texture2D) -> Texture2D:
	var img := t.get_image()
	if img == null:
		return t
	if img.is_compressed():
		img.decompress()
	img.generate_mipmaps()
	var ct := CanvasTexture.new()
	ct.diffuse_texture = ImageTexture.create_from_image(img)
	ct.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	return ct


static func has_sprite(id: String) -> bool:
	return data().get("sprites", {}).has(id)


static func icon(id: String) -> Texture2D:
	var path: String = data().get("icons", {}).get(id, "")
	return texture(path) if path != "" else null


static func item_icon(item: Dictionary) -> Texture2D:
	var unique := str(item.get("unique", ""))
	if unique != "" and data().get("icons", {}).has("item-" + unique):
		return icon("item-" + unique)
	var eq := eq_icon_id(item)
	if eq != "" and data().get("icons", {}).has(eq):
		return icon(eq)
	return icon("item-" + str(item.get("slot", "")))


## EQ-HD (docs/40): icon HD theo món — dáng = kiểu vũ khí của lớp (item.style: bow / staff / mace / orb; trống = kiếm)
## hoặc ô trang bị; chủ đề = bộ (item.set) nếu có, không thì phẩm chất; biến thể = id % 2 (túi đồ không lặp một hình).
## Chỉ có khi bật Đồ hoạ HD (lớp phủ manifest.hd.icons); tắt HD → icon ô cũ.
const EQ_VARIANTS := 2


static func eq_icon_id(item: Dictionary) -> String:
	var slot := str(item.get("slot", ""))
	if slot == "":
		return ""
	var fam := slot
	if slot == "weapon":
		var st := str(item.get("style", ""))
		fam = st if st != "" else "sword"
	var theme := str(item.get("set", ""))
	if theme == "":
		theme = str(item.get("rarity", "white"))
	return "eq-%s-%d-%s" % [fam, posmod(int(item.get("id", 0)), EQ_VARIANTS), theme]


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


## squash / lean (FX-1 §9.13): co giãn và nghiêng quanh chân (tư thế lấy đà của quái); mặc định không đổi.
static func draw_frame(ci: CanvasItem, id: String, anim: String, frame: int, pos: Vector2, flip := false,
		modulate := Color.WHITE, size_mul := 1.0, squash := Vector2.ONE, lean := 0.0) -> void:
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
	var k := scale() * size_mul * float(s.get("size_mul", 1.0)) / px_of(s)
	ci.draw_set_transform(pos, lean, Vector2((-k if flip else k) * squash.x, k * squash.y))
	ci.draw_texture_rect_region(tex, Rect2(-Vector2(s.origin[0], s.origin[1]), Vector2(w, h)), region, modulate)
	ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


## AR-44: sprite thân nhân vật đang dùng (để tính số frame): pc-<lớp> cắt từ sprite sheet 5 lớp (tools/art/class_sheet.py)
## nếu có và ngoại hình chọn kiểu "Hình lớp"; không thì thân theo ngoại hình (C1-02); không nữa thì hero-<lớp>.
static func hero_sprite(class_id: String, look: Dictionary) -> String:
	var Looks = load("res://scripts/data/looks.gd")
	if Looks.uses_sheet(look) and has_sprite("pc-" + class_id):
		return "pc-" + class_id
	var base: String = Looks.base_sprite(class_id, look)
	return base if has_sprite(base) else "hero-" + class_id


## C1-02: vẽ nhân vật theo ngoại hình (thân + tóc tô màu). Thiếu hình ghép thì dùng hero-<lớp>.
## AR-44: kiểu "Hình lớp" + có pc-<lớp> thì vẽ hình đó (đã có tóc/trang phục riêng của lớp, không ghép tóc).
static func draw_hero(ci: CanvasItem, class_id: String, look: Dictionary, anim: String, frame: int, pos: Vector2,
		flip := false, modulate := Color.WHITE, size_mul := 1.0) -> void:
	if hero_sprite(class_id, look) == "pc-" + class_id:
		var pc: Dictionary = data().sprites["pc-" + class_id]
		var n := int(pc.anims.get(anim, pc.anims.idle).frames)
		draw_frame(ci, "pc-" + class_id, anim, clampi(frame, 0, n - 1), pos, flip, modulate, size_mul)
		return
	var Looks = load("res://scripts/data/looks.gd")
	var base: String = Looks.base_sprite(class_id, look)
	if not has_sprite(base):
		draw_frame(ci, "hero-" + class_id, anim, frame, pos, flip, modulate, size_mul)
		return
	draw_frame(ci, base, anim, frame, pos, flip, modulate, size_mul)
	var hair: String = Looks.hair_sprite(class_id, look)
	if has_sprite(hair):
		draw_frame(ci, hair, anim, frame, pos, flip, modulate * Looks.hair_color(look), size_mul)


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
	var k := scale() * size_mul / px_of(e)
	ci.draw_set_transform(pos, rotation, Vector2(-k if flip else k, k))
	ci.draw_texture(tex, -Vector2(e.origin[0], e.origin[1]), modulate)
	ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


## Tô một đa giác bằng ô đất lặp lại (cần texture_repeat bật trên CanvasItem).
static func fill_polygon(ci: CanvasItem, points: PackedVector2Array, tile_id: String, modulate := Color.WHITE) -> bool:
	var tex := env_texture(tile_id)
	if tex == null:
		return false
	var span := float(tex.get_width()) / px_of(data().env[tile_id]) * scale()
	var uvs := PackedVector2Array()
	for p in points:
		uvs.append(p / span)
	ci.draw_colored_polygon(points, modulate, uvs, tex)
	return true


## SN11-03: đa giác màu vẽ quanh gốc rồi dời tới vị trí. Map ×√3 có toạ độ tới ~7000 px — Godot tam giác hoá theo
## toạ độ tuyệt đối (float), hình nhỏ ở xa gốc báo "Invalid polygon data, triangulation failed".
static func poly(ci: CanvasItem, pts: PackedVector2Array, col: Color) -> void:
	if pts.size() < 3:
		return
	var o := pts[0]
	var local := PackedVector2Array()
	for p in pts:
		local.append(p - o)
	ci.draw_set_transform(o, 0.0, Vector2.ONE)
	ci.draw_colored_polygon(local, col)
	ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
