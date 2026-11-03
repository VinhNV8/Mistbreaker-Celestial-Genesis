extends Control
## SN9-09 (Spec_Notes đợt 9: "khi focus vào đánh quái, cần hiển thị đang focus vào quái nào: avatar, thanh máu…").
## Khung mục tiêu ở giữa trên (dưới thanh tài nguyên), kiểu Diablo Immortal / Lost Ark / MU: chân dung quái trong
## khung tròn (viền màu theo loại), "Loại · Tên · Lv N" (màu cấp như UI-15), biểu tượng hệ, thanh máu + số + %,
## thanh Phá Thế (nếu có), hàng trạng thái (Choáng, Chậm, Thiêu, Độc, Trói). Mục tiêu do GameWorld.focus chọn.

const UiTheme = preload("res://scripts/ui/ui_theme.gd")
const SpriteLib = preload("res://scripts/view/sprite_lib.gd")
const Monsters = preload("res://scripts/data/monsters.gd")
const ElementIcon = preload("res://scripts/ui/element_icon.gd")

const W := 340.0
const H := 74.0
const PR := 30.0

var _e = null
var _player_level := 1


func _init() -> void:
	custom_minimum_size = Vector2(W, H)
	size = Vector2(W, H)
	mouse_filter = MOUSE_FILTER_IGNORE
	visible = false


func update_from(w) -> void:
	_e = w.focus
	_player_level = int(w.profile.level)
	visible = _e != null
	if visible:
		queue_redraw()


## [tên loại, màu] như bảng tên quái (UI-15).
static func tier_of(e) -> Array:
	if e.gate_boss:
		return ["Chúa Cổng", Color("#ff4d6a")]
	if e.cave_boss:
		return ["Chúa Hang", Color("#ff7a45")]
	if e.role == "rare":
		return ["Hiếm", Color("#c79bff")]
	if e.role == "nestGuard":
		return ["Thủ lĩnh", Color("#ff9a3c")]
	if e.elite:
		return ["Tinh anh", Color("#ffd877")]
	return ["Thường", Color(0.75, 0.77, 0.8)]


static func level_color(gap: int) -> Color:
	if gap >= 5:
		return Color("#ff5470")
	if gap > 0:
		return Color("#ff9a3c")
	if gap <= -5:
		return Color(0.6, 0.6, 0.62)
	return Color.WHITE


## Trạng thái đang dính: [[chữ, màu]…]
static func statuses(e) -> Array:
	var out: Array = []
	if e.state == "stunned":
		out.append(["Choáng", Color("#ffc940")])
	if e.root_timer > 0.0:
		out.append(["Trói", Color("#9a7a52")])
	if e.slow_t > 0.0:
		out.append(["Chậm", Color("#6fb6ff")])
	if e.bleed_timer > 0.0:
		out.append(["Thiêu", Color("#ff6a3d")])
	if e.venom_timer > 0.0:
		out.append(["Độc ×%d" % maxi(1, int(e.venom_stacks)), Color("#7ad65a")])
	if e.broken:
		out.append(["Vỡ giáp", Color("#ffd877")])
	return out


func _draw() -> void:
	if _e == null:
		return
	var e = _e
	var tier: Array = tier_of(e)
	var accent: Color = tier[1]
	# nền + viền
	var box := Rect2(Vector2(PR, 6), Vector2(W - PR - 4, H - 12))
	draw_rect(box, Color(0.04, 0.03, 0.08, 0.82))
	draw_rect(box, Color(accent, 0.55), false, 1.5)
	# chân dung
	var c := Vector2(PR + 2, H / 2.0)
	draw_circle(c, PR, Color("#0a0710"))
	var sid := str(e.kind)
	if e.elite:
		var es := str(Monsters.DEFS[e.kind].get("elite_sprite", e.kind))
		if SpriteLib.has_sprite(es):
			sid = es
	if SpriteLib.has_sprite(sid):
		var s: Dictionary = SpriteLib.data().sprites[sid]
		var k := (PR * 1.5) / maxf(1.0, float(s.h) * SpriteLib.scale() * float(s.get("size_mul", 1.0)))
		SpriteLib.draw_frame(self, sid, "idle", 0, c + Vector2(0, PR * 0.7), false, Color.WHITE, k)
	else:
		draw_circle(c, PR * 0.5, e.color)
	draw_arc(c, PR, 0.0, TAU, 40, accent, 3.0, true)
	draw_arc(c, PR + 3.0, 0.0, TAU, 40, Color(0, 0, 0, 0.6), 1.5, true)
	# dòng tên: biểu tượng hệ · Loại · Tên · Lv N
	var f := UiTheme.bold_font()
	var fs := UiTheme.fs(14)
	var x := PR * 2.0 + 14.0
	var y := 24.0
	ElementIcon.draw(self, Vector2(x + 6.0, y - 5.0), (e.el_override if e.el_override != "" else str(Monsters.DEFS[e.kind].element)), 7.0, 1.0)
	x += 18.0
	for pt in [[str(tier[0]) + " · ", accent], [str(e.name) + " · ", Color(0.96, 0.94, 0.88)],
			["Lv%d" % int(e.level), level_color(int(e.level) - _player_level)]]:
		draw_string_outline(f, Vector2(x, y), pt[0], HORIZONTAL_ALIGNMENT_LEFT, -1, fs, 3, Color(0, 0, 0, 0.8))
		draw_string(f, Vector2(x, y), pt[0], HORIZONTAL_ALIGNMENT_LEFT, -1, fs, pt[1])
		x += f.get_string_size(pt[0], HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	# thanh máu
	var bx := PR * 2.0 + 14.0
	var bw := W - bx - 14.0
	var hp_ratio := clampf(float(e.hp) / maxf(1.0, float(e.max_hp)), 0.0, 1.0)
	var bar := Rect2(Vector2(bx, 32), Vector2(bw, 14))
	draw_rect(bar, Color(0, 0, 0, 0.7))
	draw_rect(Rect2(bar.position, Vector2(bw * hp_ratio, 14)), Color("#d9364a"))
	draw_rect(Rect2(bar.position, Vector2(bw * hp_ratio, 4)), Color(1, 1, 1, 0.18))
	draw_rect(bar, Color(0, 0, 0, 0.9), false, 1.0)
	var hp_txt := "%s / %s  ·  %d%%" % [_num(maxf(0.0, e.hp)), _num(e.max_hp), ceili(hp_ratio * 100.0)]
	var sfs := UiTheme.fs(11)
	draw_string_outline(f, Vector2(bx, 43), hp_txt, HORIZONTAL_ALIGNMENT_CENTER, bw, sfs, 3, Color(0, 0, 0, 0.9))
	draw_string(f, Vector2(bx, 43), hp_txt, HORIZONTAL_ALIGNMENT_CENTER, bw, sfs, Color.WHITE)
	# thanh Phá Thế
	if e.max_poise > 0.0:
		var pb := Rect2(Vector2(bx, 48), Vector2(bw, 4))
		draw_rect(pb, Color(0, 0, 0, 0.7))
		draw_rect(Rect2(pb.position, Vector2(bw * clampf(e.poise / e.max_poise, 0.0, 1.0), 4)), Color("#ffc940"))
	# trạng thái
	var sx := bx
	for st in statuses(e):
		var tw := f.get_string_size(st[0], HORIZONTAL_ALIGNMENT_LEFT, -1, sfs).x + 10.0
		draw_rect(Rect2(Vector2(sx, 54), Vector2(tw, 14)), Color(st[1], 0.22))
		draw_rect(Rect2(Vector2(sx, 54), Vector2(tw, 14)), Color(st[1], 0.8), false, 1.0)
		draw_string(f, Vector2(sx + 5.0, 65), st[0], HORIZONTAL_ALIGNMENT_LEFT, -1, sfs, st[1])
		sx += tw + 4.0


## 12345 → "12.345"
static func _num(v: float) -> String:
	var s := str(roundi(v))
	var out := ""
	for i in s.length():
		if i > 0 and (s.length() - i) % 3 == 0:
			out += "."
		out += s[i]
	return out
