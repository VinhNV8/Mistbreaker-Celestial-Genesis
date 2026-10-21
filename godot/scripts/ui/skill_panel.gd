extends "res://scripts/ui/modal.gd"
## SK1 (docs/13): bảng Kỹ năng (phím U) — danh sách kỹ năng của lớp, cấp kỹ năng, Điểm Kỹ Năng,
## lắp vào 4 ô (chỉ ở vùng an toàn), tẩy điểm miễn phí ở vùng an toàn.

const Classes = preload("res://scripts/data/classes.gd")
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
	for sk in Classes.skills_of(str(p.class_id)):
		content.add_child(_row(sk, safe))
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
	var h := UiTheme.hbox(12)
	card.add_child(h)
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
		title = "%s · mở ở cấp %d" % [sk.name, int(sk.unlock)]
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
	return card
