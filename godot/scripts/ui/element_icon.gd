extends RefCounted
## UI-13 (Spec_Notes đợt 6): biểu tượng ngũ hành vẽ bằng code, thay chữ "Mộc", "Kim"… (quái, khung nhân vật).
## Kim = thỏi bạc hình thoi · Mộc = lá xanh · Thủy = giọt nước · Hỏa = ngọn lửa · Thổ = núi đất.
## Dùng: ElementIcon.draw(canvas_item, tâm, "moc", bán_kính).

const HEX := {"kim": "#e8e2c8", "moc": "#5bd16a", "thuy": "#4a9df8", "hoa": "#ff6a3c", "tho": "#c9a45c"}


static func color(el: String) -> Color:
	return Color(HEX.get(el, "#ffffff"))


## Huy hiệu tròn: nền tối, viền màu hệ, hình hệ ở giữa. `alpha` để làm mờ (quái ở xa…).
static func draw(ci: CanvasItem, c: Vector2, el: String, r: float, alpha := 1.0) -> void:
	if not HEX.has(el):
		return
	var col := color(el)
	ci.draw_circle(c, r + 1.5, Color(0, 0, 0, 0.75 * alpha))
	ci.draw_circle(c, r, Color(col.darkened(0.75), 0.95 * alpha))
	ci.draw_arc(c, r, 0, TAU, 24, Color(col, alpha), maxf(1.0, r * 0.16), true)
	var s := r * 0.62
	var fill := Color(col, alpha)
	var light := Color(col.lightened(0.55), alpha)
	match el:
		"kim":
			var pts := PackedVector2Array([c + Vector2(0, -s), c + Vector2(s * 0.8, 0), c + Vector2(0, s), c + Vector2(-s * 0.8, 0)])
			ci.draw_colored_polygon(pts, fill)
			ci.draw_colored_polygon(PackedVector2Array([c + Vector2(0, -s), c + Vector2(s * 0.8, 0), c]), light)
		"moc":
			var pts := PackedVector2Array()
			for i in 9:
				var t := float(i) / 8.0
				pts.append(c + Vector2(-s * 0.7, s * 0.7).lerp(Vector2(s * 0.7, -s * 0.7), t) + Vector2(1, 1).normalized() * s * 0.55 * sin(t * PI))
			for i in range(7, 0, -1):
				var t := float(i) / 8.0
				pts.append(c + Vector2(-s * 0.7, s * 0.7).lerp(Vector2(s * 0.7, -s * 0.7), t) - Vector2(1, 1).normalized() * s * 0.55 * sin(t * PI))
			ci.draw_colored_polygon(pts, fill)
			ci.draw_line(c + Vector2(-s * 0.8, s * 0.8), c + Vector2(s * 0.6, -s * 0.6), Color(col.darkened(0.5), alpha), maxf(1.0, r * 0.1), true)
		"thuy":
			var pts := PackedVector2Array([c + Vector2(0, -s * 1.05)])
			for i in 13:
				var a := -PI * 0.15 + PI * 1.3 * i / 12.0
				pts.append(c + Vector2(0, s * 0.25) + Vector2.from_angle(a) * s * 0.68)
			ci.draw_colored_polygon(pts, fill)
			ci.draw_circle(c + Vector2(-s * 0.22, s * 0.15), s * 0.16, light)
		"hoa":
			var outer := PackedVector2Array([c + Vector2(0, -s * 1.1), c + Vector2(s * 0.35, -s * 0.35), c + Vector2(s * 0.7, -s * 0.1),
				c + Vector2(s * 0.6, s * 0.5), c + Vector2(0, s * 0.9), c + Vector2(-s * 0.6, s * 0.5), c + Vector2(-s * 0.65, -s * 0.2), c + Vector2(-s * 0.3, -s * 0.1)])
			ci.draw_colored_polygon(outer, fill)
			ci.draw_colored_polygon(PackedVector2Array([c + Vector2(0, -s * 0.3), c + Vector2(s * 0.35, s * 0.4), c + Vector2(0, s * 0.75), c + Vector2(-s * 0.35, s * 0.4)]),
				Color(1.0, 0.92, 0.5, alpha))
		"tho":
			ci.draw_colored_polygon(PackedVector2Array([c + Vector2(-s, s * 0.7), c + Vector2(-s * 0.25, -s * 0.75), c + Vector2(s * 0.3, s * 0.7)]), fill)
			ci.draw_colored_polygon(PackedVector2Array([c + Vector2(-s * 0.1, s * 0.7), c + Vector2(s * 0.45, -s * 0.3), c + Vector2(s, s * 0.7)]), Color(col.darkened(0.25), alpha))
			ci.draw_colored_polygon(PackedVector2Array([c + Vector2(-s * 0.25, -s * 0.75), c + Vector2(0, -s * 0.3), c + Vector2(-s * 0.5, -s * 0.3)]), light)
