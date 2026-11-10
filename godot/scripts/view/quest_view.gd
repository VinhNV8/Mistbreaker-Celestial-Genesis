extends RefCounted
## NV-A1 / A2 (docs/41): chỉ đường nhiệm vụ trong thế giới — mũi tên vàng quanh chân nhân vật chỉ hướng điểm cần tới
## (mục tiêu, hoặc cổng sang map mục tiêu) kèm khoảng cách; vòng vàng nhấp nháy tại điểm đó khi trong khung nhìn;
## dấu "!" vàng trên đầu NPC cần gặp. world_view gọi draw() sau lớp nhân vật / quái.

const QuestLog = preload("res://scripts/core/quest_log.gd")
const UiTheme = preload("res://scripts/ui/ui_theme.gd")
const Quests = preload("res://scripts/core/quests.gd")

const GOLD := Color("#ffd257")
const GOLD_DARK := Color("#6b4a12")
## Bán kính vòng mũi tên quanh nhân vật (px thế giới).
const ARROW_R := 62.0
## Gần hơn khoảng này thì không vẽ mũi tên (đã tới nơi).
const NEAR := 90.0


static func draw(ci: CanvasItem, w, view: Rect2, font: Font) -> void:
	var g := QuestLog.guide(w)
	if g.is_empty() or w.travel_timer > 0.0:
		return
	var r: Dictionary = g.route
	var t: float = w.time
	_npc_marks(ci, w, g, t, font)
	_variant_marks(ci, w, g, t, view)
	var at: Vector2 = r.pos
	if at == Vector2.INF:
		return
	var pp: Vector2 = w.player.pos
	var d: float = pp.distance_to(at)
	# vòng đánh dấu tại điểm cần tới
	if view.grow(40.0).has_point(at) and not _is_npc_goal(g):
		var k := 0.5 + 0.5 * sin(t * 4.0)
		ci.draw_circle(at, 30.0 + 6.0 * k, Color(GOLD, 0.10 + 0.08 * k))
		ci.draw_arc(at, 30.0 + 6.0 * k, 0.0, TAU, 40, Color(GOLD, 0.85), 2.5, true)
		ci.draw_arc(at, 18.0, 0.0, TAU, 32, Color(GOLD, 0.5), 1.5, true)
		var top := at + Vector2(0, -50.0 - 4.0 * sin(t * 3.0))
		_diamond(ci, top, 9.0)
		_text(ci, font, str(r.label), at + Vector2(0, -66), 13, GOLD)
	if d < NEAR:
		return
	# mũi tên quanh chân nhân vật + khoảng cách
	var dir := (at - pp).normalized()
	var c := pp + Vector2(0, 6) + dir * ARROW_R
	var bob := 3.0 * sin(t * 5.0)
	var tip := c + dir * (12.0 + bob)
	var n := dir.orthogonal()
	var base := c - dir * (8.0 - bob * 0.3)
	var pts := PackedVector2Array([tip, base + n * 11.0, c - dir * 2.0, base - n * 11.0])
	ci.draw_colored_polygon(pts, GOLD)
	pts.append(pts[0])
	ci.draw_polyline(pts, GOLD_DARK, 2.0, true)
	var txt := "%d m" % QuestLog.meters(pp, at)
	if not bool(r.final):
		txt += " · " + str(r.label)
	# VS-1 (docs/44): chữ dài căn giữa ở một điểm sẽ chìa ngược về phía nhân vật khi mũi tên chỉ ngang (chữ giữ cỡ khi
	# camera zoom ra còn to hơn) → đặt MÉP GẦN của chữ ngay sau đầu mũi tên; vẫn chạm thân nhân vật thì đưa xuống dưới chân.
	var tk: float = preload("res://scripts/core/view_scale.gd").text_k
	var fs := roundi(12 * tk)
	var tw := UiTheme.bold_font().get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	var th := float(fs)
	var mid := tip + dir * 6.0 * tk + Vector2(dir.x * tw * 0.5, dir.y * th * 0.7)
	var box := Rect2(mid - Vector2(tw * 0.5, th * 0.65), Vector2(tw, th * 1.3))
	var body := Rect2(pp + Vector2(-24, -64), Vector2(48, 84))
	if box.intersects(body):
		mid = pp + Vector2(0, 26.0 + th)
	_text(ci, font, txt, mid + Vector2(0, th * 0.35), 12, GOLD)


## Dấu trên đầu NPC: "!" vàng = mục tiêu bước chính đang làm hoặc có nhiệm vụ phụ mới; "?" vàng = nhiệm vụ phụ chờ trả.
static func _npc_marks(ci: CanvasItem, w, g: Dictionary, t: float, font: Font) -> void:
	var main_at := Vector2.INF
	if _is_npc_goal(g) and bool(g.route.final):
		main_at = g.route.pos
		if main_at != Vector2.INF:
			_mark(ci, main_at, "!", t)
	for n in w.npcs():
		if n.pos == main_at:
			continue
		var m: String = Quests.npc_mark(w, str(n.id))
		if m != "":
			_mark(ci, n.pos, m, t)


## NV-B: dấu vết chưa tìm (đốm sáng lấp lánh) / vòng điểm giữ (nét đứt) của bước chính đang làm.
static func _variant_marks(ci: CanvasItem, w, g: Dictionary, t: float, view: Rect2) -> void:
	var MV = load("res://scripts/core/main_variants.gd")
	var type := str(g.main.q.get("type", ""))
	if not MV.VARIANTS.has(type):
		return
	var v: Dictionary = MV.VARIANTS[type]
	match str(v.mech):
		"clues":
			var s: Dictionary = MV.state(w, type)
			var pts: Array = MV.clue_points(w, v)
			for i in pts.size():
				if i in s.clues or not view.has_point(pts[i]):
					continue
				var k := 0.5 + 0.5 * sin(t * 5.0 + i)
				ci.draw_circle(pts[i], 16.0 + 4.0 * k, Color(GOLD, 0.18))
				for j in 4:
					var a := t * 1.5 + j * PI / 2.0
					ci.draw_line(pts[i] + Vector2.from_angle(a) * 4.0, pts[i] + Vector2.from_angle(a) * (12.0 + 6.0 * k), Color(GOLD, 0.9), 2.0, true)
		"defend":
			if w.map_id == str(v.map):
				var at: Vector2 = MV.defend_point(w)
				for j in 24:
					var a0 := TAU * j / 24.0 + t * 0.2
					ci.draw_arc(at, MV.DEFEND_R, a0, a0 + TAU / 48.0, 4, Color(GOLD, 0.7), 2.5, true)


static func _mark(ci: CanvasItem, at: Vector2, sym: String, t: float) -> void:
	var p := at + Vector2(0, -96.0 - 5.0 * sin(t * 3.0))
	ci.draw_circle(p, 13.0, Color(0, 0, 0, 0.45))
	ci.draw_circle(p, 11.0, GOLD)
	ci.draw_arc(p, 11.0, 0.0, TAU, 28, GOLD_DARK, 2.0, true)
	var f := UiTheme.bold_font()
	ci.draw_string(f, p + Vector2(-4.5 if sym == "!" else -5.5, 6), sym, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#3a2408"))


static func _is_npc_goal(g: Dictionary) -> bool:
	return g.main.q.get("goal", {}).has("npc")


static func _diamond(ci: CanvasItem, p: Vector2, s: float) -> void:
	var pts := PackedVector2Array([p + Vector2(0, -s), p + Vector2(s * 0.7, 0), p + Vector2(0, s), p + Vector2(-s * 0.7, 0)])
	ci.draw_colored_polygon(pts, GOLD)
	pts.append(pts[0])
	ci.draw_polyline(pts, GOLD_DARK, 1.5, true)


static func _text(ci: CanvasItem, font: Font, s: String, pos: Vector2, size: int, col: Color) -> void:
	if s == "":
		return
	var f := UiTheme.bold_font()
	# VS-1 (docs/44): giữ cỡ chữ trên màn hình khi camera zoom ra.
	size = roundi(size * preload("res://scripts/core/view_scale.gd").text_k)
	var w := 300.0 * preload("res://scripts/core/view_scale.gd").text_k
	var at := pos - Vector2(w / 2.0, 0)
	ci.draw_string_outline(f, at, s, HORIZONTAL_ALIGNMENT_CENTER, w, size, 4, Color(0, 0, 0, 0.8))
	ci.draw_string(f, at, s, HORIZONTAL_ALIGNMENT_CENTER, w, size, col)
