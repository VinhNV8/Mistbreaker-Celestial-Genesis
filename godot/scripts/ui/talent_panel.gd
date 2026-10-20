extends "res://scripts/ui/modal.gd"
## Bảng Thiên phú (phím T) — TL-15: thẻ, cấp, hiệu ứng, kỹ năng L, hiệu ứng phụ, luyện cấp.

const Explore = preload("res://scripts/core/explore.gd")
const Monsters = preload("res://scripts/data/monsters.gd")
const Talents = preload("res://scripts/data/talents.gd")

const W := 520.0


func _render(content: VBoxContainer) -> void:
	var p = world.profile
	var t: Dictionary = world.talent()
	var color := Talents.rank_color(t.rank)
	content.custom_minimum_size.x = W
	_header(content, "Thiên phú · Cấp %d/%d" % [p.talent_level, Talents.MAX_TALENT_LEVEL], "Đóng (T)")

	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", UiTheme.rank_box(color))
	var row := UiTheme.hbox(14)
	var icon := TextureRect.new()
	icon.texture = preload("res://scripts/view/sprite_lib.gd").talent_icon(t.id)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.custom_minimum_size = Vector2(64, 64)
	row.add_child(icon)
	var rank := UiTheme.label(t.rank, "Heading")
	rank.add_theme_font_size_override("font_size", 40)
	rank.add_theme_color_override("font_color", color)
	row.add_child(rank)
	var col := UiTheme.vbox(2)
	col.add_child(UiTheme.label("%s · %s" % [t.name, Talents.group_name(t)], "Heading"))
	col.add_child(UiTheme.label(t.description, "", W - 120))
	row.add_child(col)
	card.add_child(row)
	content.add_child(card)

	if Talents.has_skill(t):
		content.add_child(UiTheme.label("KỸ NĂNG (PHÍM L)", "Eyebrow"))
		content.add_child(UiTheme.label("%s — %s Hồi chiêu %.1f giây." % [world.talent_skill_name(), t.skill.text, world.talent_skill_cd()], "", W))
	_talent_state(content, p, t)

	content.add_child(UiTheme.label("HIỆU ỨNG THEO CẤP", "Eyebrow"))
	# TP-41: hiệu ứng chính mạnh dần tới Lv10.
	var main_now := Talents.main_effect_text(t.id, p.talent_level)
	if main_now != "":
		var nxt := ""
		if p.talent_level < Talents.MAX_TALENT_LEVEL:
			nxt = "   →   Cấp %d: %s" % [p.talent_level + 1, Talents.main_effect_text(t.id, p.talent_level + 1)]
		content.add_child(UiTheme.label("Hiệu ứng chính cấp %d: %s%s" % [p.talent_level, main_now, nxt], "", W))
	var bonus: int = 2 * (int(p.talent_level) - 1)
	content.add_child(UiTheme.label("Cấp %d: +%d%% Tấn công, +%d%% HP (mỗi cấp +2%%)." % [p.talent_level, bonus, bonus], "Muted", W))
	var subs: Array = Talents.GROUP_SUB[t.group]
	for i in subs.size():
		var need := (i + 1) * 5
		var on: bool = p.talent_level >= need
		var l := UiTheme.label("%s Cấp %d — %s" % ["✓" if on else "○", need, subs[i]], "", W)
		l.add_theme_color_override("font_color", UiTheme.GOOD if on else UiTheme.MUTED)
		content.add_child(l)

	content.add_child(HSeparator.new())
	content.add_child(UiTheme.label("Thiên Phú Tinh Hoa: %d  (rơi từ Sói Chúa, 3 mỗi lần hạ)" % p.essence, "Muted"))
	if p.talent_level >= Talents.MAX_TALENT_LEVEL:
		content.add_child(UiTheme.label("Đã đạt cấp tối đa.", "Muted"))
		return
	var cost := Talents.level_cost(p.talent_level)
	var blocker := ""
	if not Explore.is_built(p, "temple"):
		blocker = "Cần xây Đền Thiên Phú (Bản đồ khai phá, phím M)." if not Explore.is_started(p, "temple") \
			else "Đền Thiên Phú đang xây, còn %d giây." % ceili(Explore.remaining(p, "temple"))
	elif p.essence < cost:
		blocker = "Thiếu Tinh Hoa."
	var b := UiTheme.button("Luyện cấp %d → %d (%d Tinh Hoa)" % [p.talent_level, p.talent_level + 1, cost], true)
	b.size_flags_horizontal = SIZE_SHRINK_BEGIN
	b.disabled = blocker != ""
	b.pressed.connect(func():
		world.level_talent()
		refresh())
	content.add_child(b)
	if blocker != "":
		var w := UiTheme.label(blocker, "", W)
		w.add_theme_color_override("font_color", Color("#ffb27a"))
		content.add_child(w)


## Trạng thái riêng của từng Thiên phú (hệ, thú cưng, kỹ năng sao chép…).
func _talent_state(content: VBoxContainer, p, t: Dictionary) -> void:
	var lines: Array[String] = []
	match t.id:
		"ngu-hanh":
			var e: String = p.element
			lines.append("Hệ đang dùng: %s — khắc %s." % [Monsters.ELEMENT_NAMES[e], Monsters.ELEMENT_NAMES[Monsters.COUNTERS[e]]])
			lines.append("Quái Rừng Sương: Sói Sương và Sói Chúa hệ Mộc, Nấm Độc hệ Thổ, Tinh Linh Sương hệ Thủy.")
		"thuan-thu":
			lines.append("Thú cưng: %d/%d." % [p.pets.size(), world.ally_cap("pet")])
		"bay-dan":
			lines.append("Lính bóng tối tối đa: %d." % world.ally_cap("shadow"))
		"dao-tac":
			lines.append("Đã sao chép: %s." % ("Vồ Mồi (Sói Chúa)" if "pounce" in p.copied_skills else "chưa có"))
		"long-mach":
			var state := "đã xây" if Explore.is_built(p, "dragon") else "chưa xây — xây ở Bản đồ khai phá"
			lines.append("Long Mạch Đàn: %s." % state)
		"thao-duoc", "hap-huyet":
			lines.append("Bình máu: %d · Thảo dược: %d." % [p.potions, p.herbs])
	for line in lines:
		content.add_child(UiTheme.label(line, "Muted", W))
