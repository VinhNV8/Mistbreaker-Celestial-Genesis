extends RefCounted
## LH1 / LH2 (docs/19): vẽ hiệu ứng của Hộ Vệ, Triệu Hồi Sư — Phi Thuẫn, Phán Quyết, Khiên Thép, Thành Bất Diệt.
## (Thánh Vực, hào quang Thành Bất Diệt dùng vùng `sk2.ice` có "color" — skills2_view vẽ.)

const Classes2 = preload("res://scripts/core/classes2.gd")
const SpriteLib = preload("res://scripts/view/sprite_lib.gd")
const Fx1 = preload("res://scripts/view/fx1.gd")


static func draw(ci: CanvasItem, world) -> void:
	var st = world.cl2
	var t: float = world.time
	var pp: Vector2 = world.player.pos
	# Khiên Thép: vòng thép quanh người; Thành Bất Diệt: đôi cánh sáng sau lưng.
	if st.steel_t > 0.0 and not Fx1.active("khienthep"):
		var k := 0.5 + 0.5 * sin(t * 8.0)
		ci.draw_arc(pp, 26.0 + 2.0 * k, 0.0, TAU, 32, Color(0.78, 0.84, 0.9, 0.8), 2.5, true)
		ci.draw_circle(pp, 26.0, Color(0.78, 0.84, 0.9, 0.12))
		# khiên vàng cắt từ ảnh thiết kế của chủ dự án (game-5f), nếu có
		if SpriteLib.has_env("fx-sheet-khienthep"):
			SpriteLib.draw_env(ci, "fx-sheet-khienthep", pp + Vector2(0, -24 - 2.0 * k))
	if st.angel_t > 0.0 and not Fx1.active("thanhbatdiet"):
		for side in [-1.0, 1.0]:
			for i in 4:
				var a: float = deg_to_rad(-100.0 + side * (35.0 + i * 14.0) + 4.0 * sin(t * 6.0 + i))
				var base: Vector2 = pp + Vector2(0, -14)
				ci.draw_line(base, base + Vector2.from_angle(a) * (34.0 - i * 4.0), Color(1.0, 0.95, 0.7, 0.8 - i * 0.15), 3.0, true)
		ci.draw_arc(pp + Vector2(0, -40), 9.0, 0.0, TAU, 20, Color(1.0, 0.88, 0.45, 0.9), 2.0, true)
	# Phi Thuẫn: khiên tròn xoay bay.
	for s in st.shields:
		if Fx1.painter and Fx1.draw_disk(Fx1.painter, world, s):
			continue
		var r := 11.0
		ci.draw_circle(s.pos, r, Color("#e0a630"))
		ci.draw_circle(s.pos, r - 3.0, Color("#2f4a84"))
		var a2: float = t * 20.0
		ci.draw_line(s.pos + Vector2.from_angle(a2) * (r - 3.0), s.pos - Vector2.from_angle(a2) * (r - 3.0), Color("#9ba8bc"), 2.0)
	# Đồ đằng: cột gỗ khắc + vòng tầm (Lôi tím-trắng, Phong xanh lá).
	for tt in st.totems:
		if Fx1.painter and Fx1.draw_totem(Fx1.painter, world, tt):
			continue
		var col := Color("#d8c8ff") if tt.kind == "loi" else Color("#7ad0a0")
		var r: float = Classes2.LDD_R if tt.kind == "loi" else Classes2.PDD_R
		ci.draw_circle(tt.pos, r, Color(col.r, col.g, col.b, 0.07))
		ci.draw_arc(tt.pos, r, 0.0, TAU, 40, Color(col.r, col.g, col.b, 0.45), 1.5, true)
		ci.draw_rect(Rect2(tt.pos + Vector2(-6, -44), Vector2(12, 44)), Color("#6a4a2a"))
		ci.draw_rect(Rect2(tt.pos + Vector2(-8, -50), Vector2(16, 10)), col)
		ci.draw_circle(tt.pos + Vector2(0, -24), 3.0, col)
	if st.link_t > 0.0 and not Fx1.active("lienket"):
		for a in world.allies:
			if not a.dead and a.kind == "summon":
				ci.draw_line(pp + Vector2(0, -16), a.pos + Vector2(0, -8), Color(0.75, 0.38, 0.94, 0.35), 2.0, true)
	# Phán Quyết: vòng báo + cột sáng đang giáng xuống.
	for m in st.slams:
		if Fx1.painter and Fx1.draw_slam(Fx1.painter, world, m, Classes2.PQ_DELAY):
			continue
		var f: float = 1.0 - clampf(float(m.t) / Classes2.PQ_DELAY, 0.0, 1.0)
		ci.draw_circle(m.pos, float(m.r), Color(1.0, 0.9, 0.5, 0.12 + 0.18 * f))
		ci.draw_arc(m.pos, float(m.r), 0.0, TAU, 36, Color(1.0, 0.9, 0.5, 0.8), 2.0, true)
		var top: Vector2 = m.pos + Vector2(0, -220.0 * (1.0 - f) - 30.0)
		ci.draw_line(top, m.pos + Vector2(0, -10), Color(1.0, 0.95, 0.75, 0.35 + 0.5 * f), 10.0 * f + 2.0, true)
