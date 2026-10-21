extends "res://scripts/ui/modal.gd"
## SK1 (docs/13): bảng Kỹ năng (phím U) — danh sách kỹ năng của lớp, cấp kỹ năng, Điểm Kỹ Năng,
## lắp vào 4 ô (chỉ ở vùng an toàn), tẩy điểm miễn phí ở vùng an toàn.
## SK2: 8 kỹ năng mỗi lớp (cuộn), biến thể 3 tầng mở ở cấp kỹ năng 4 / 7 / 10 (đổi ở vùng an toàn).

const Classes = preload("res://scripts/data/classes.gd")
const Skills2 = preload("res://scripts/core/skills2.gd")
const SpriteLib = preload("res://scripts/view/sprite_lib.gd")


func _render(content: VBoxContainer) -> void:
	var p = world.profile
	content.custom_minimum_size.x = 780
	_header(content, "Kỹ năng · %s" % Classes.title(str(p.class_id), str(p.job), str(p.job2)), "Đóng (U)")
	var safe: bool = world.in_safe_zone()
	var info := UiTheme.label("Điểm Kỹ Năng: %d  ·  Mỗi lần lên cấp +1  ·  Kỹ năng sát thương +8%%/cấp, kỹ năng hỗ trợ −4%% hồi chiêu/cấp (tối đa cấp %d)" % [
		int(p.skill_points), Classes.SKILL_MAX_LEVEL], "", 760)
	info.add_theme_color_override("font_color", UiTheme.GOLD)
	content.add_child(info)
	content.add_child(UiTheme.label(("Đang ở vùng an toàn: đổi ô và tẩy điểm miễn phí." if safe
		else "Đổi ô kỹ năng và tẩy điểm: về làng / trại / thành (vùng an toàn)."), "Muted", 760))
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(760, 470)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var list := UiTheme.vbox(6)
	list.size_flags_horizontal = SIZE_EXPAND_FILL
	scroll.add_child(list)
	for sk in Classes.skills_of(str(p.class_id)):
		list.add_child(_row(sk, safe))
	content.add_child(scroll)
	var foot := UiTheme.hbox(10)
	var reset := UiTheme.button("Tẩy điểm kỹ năng")
	reset.name = "SkillReset"
	reset.disabled = not safe
	reset.pressed.connect(func():
		world.skill_reset()
		refresh())
	foot.add_child(reset)
	content.add_child(foot)


func _row(sk: Dictionary, safe: bool) -> Control:
	var id: String = sk.id
	var unlocked: bool = world.skill_unlocked(sk)
	var lv: int = world.skill_level(id)
	var card := PanelContainer.new()
	var outer := UiTheme.vbox(4)
	card.add_child(outer)
	var h := UiTheme.hbox(12)
	outer.add_child(h)
	var ic := TextureRect.new()
	ic.texture = SpriteLib.icon("skill-" + str(sk.icon))
	ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	ic.custom_minimum_size = Vector2(44, 44)
	ic.modulate = Color.WHITE if unlocked else Color(1, 1, 1, 0.35)
	h.add_child(ic)
	var v := UiTheme.vbox(2)
	v.size_flags_horizontal = SIZE_EXPAND_FILL
	var slot: int = world.profile.loadout.find(id)
	var title := "%s · cấp %d/%d%s" % [sk.name, lv, Classes.SKILL_MAX_LEVEL, ("  ·  ô %d" % (slot + 1)) if slot >= 0 else ""]
	if not unlocked:
		title = "%s · %s" % [sk.name, "cần chuyển chức 1" if bool(sk.get("job", false)) and str(world.profile.job) == "" else "mở ở cấp %d" % int(sk.unlock)]
	var el := Skills2.element_of(world, id)
	if el != "":
		title += "  ·  hệ %s" % Skills2.ELEMENT_NAMES[el]
	v.add_child(UiTheme.label(title, "Heading" if unlocked else "Muted"))
	v.add_child(UiTheme.label("%s  (%d MP, hồi %.0f giây)" % [sk.text, int(sk.mp), float(sk.cd)], "Small", 470))
	h.add_child(v)
	var up := UiTheme.button("+1 cấp", true)
	up.name = "SkillUp_" + id
	up.disabled = not unlocked or lv >= Classes.SKILL_MAX_LEVEL or int(world.profile.skill_points) <= 0
	up.pressed.connect(func():
		world.skill_upgrade(id)
		refresh())
	h.add_child(up)
	var slots := UiTheme.hbox(4)
	for i in Classes.SKILL_SLOTS:
		var b := UiTheme.button(str(i + 1), slot == i)
		b.name = "Slot_%s_%d" % [id, i]
		b.tooltip_text = "Lắp vào ô %d (phím %d)" % [i + 1, i + 1]
		b.disabled = not safe or slot == i
		var si: int = i
		b.pressed.connect(func():
			world.set_slot(si, id)
			refresh())
		slots.add_child(b)
	h.add_child(slots)
	if unlocked:
		outer.add_child(_variants(sk, safe))
	return card


## SK2: 3 tầng biến thể, mỗi tầng chọn 1 (tầng II: 5 hệ ngũ hành với kỹ năng sát thương).
func _variants(sk: Dictionary, safe: bool) -> Control:
	var id: String = sk.id
	var box := UiTheme.vbox(2)
	var tiers: Array = Skills2.tiers_for(sk)
	var cur: Array = world.profile.variants.get(id, [])
	# Chỉ hiện tầng đã mở; chưa mở tầng nào thì 1 dòng gợi ý (đỡ chiếm chỗ).
	if world.skill_level(id) < Skills2.TIER_LEVELS[0]:
		box.add_child(UiTheme.label("Biến thể mở ở cấp kỹ năng 4 / 7 / 10.", "Small"))
		return box
	for t in 3:
		var row := UiTheme.hbox(4)
		var open: bool = world.skill_level(id) >= Skills2.TIER_LEVELS[t]
		if not open:
			box.add_child(UiTheme.label("Tầng %s mở ở cấp kỹ năng %d." % [["I", "II", "III"][t], Skills2.TIER_LEVELS[t]], "Small"))
			break
		var lab := UiTheme.label("Tầng %s (cấp %d):" % [["I", "II", "III"][t], Skills2.TIER_LEVELS[t]], "Small")
		lab.custom_minimum_size.x = 120
		lab.modulate = Color.WHITE if open else Color(1, 1, 1, 0.45)
		row.add_child(lab)
		for o in tiers[t]:
			var chosen: bool = t < cur.size() and str(cur[t]) == str(o[0])
			var b := UiTheme.button(str(o[1]), chosen)
			b.name = "Var_%s_%d_%s" % [id, t, o[0]]
			b.tooltip_text = str(o[2])
			b.disabled = not open or not safe or chosen
			var tier: int = t
			var opt: String = o[0]
			b.pressed.connect(func():
				Skills2.set_variant(world, id, tier, opt)
				refresh())
			row.add_child(b)
		box.add_child(row)
	return box
