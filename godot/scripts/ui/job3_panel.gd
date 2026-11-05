extends "res://scripts/ui/modal.gd"
## J3 (docs/23 J3-UI1, 17 C8-47): chuyển chức 3 — 1 thẻ (hai nhánh chức 2 hợp về một chức). Bản tạm Q140: Liệt Diễm, phím E.

const Classes = preload("res://scripts/data/classes.gd")
const Job3 = preload("res://scripts/core/job3.gd")
const SpriteLib = preload("res://scripts/view/sprite_lib.gd")

const SILVER := Color("#f2f6ff")


func _render(content: VBoxContainer) -> void:
	var p = world.profile
	var cid := str(p.class_id)
	var j := Classes.job3_def(cid)
	content.custom_minimum_size.x = 640
	_header(content, "Chuyển chức lần 3 · %s" % Classes.title(cid, str(p.job), str(p.job2)), "Đóng (Esc)")
	if j.is_empty():
		content.add_child(UiTheme.label("Lớp này chưa có chuyển chức 3.", "Muted", 600))
		return
	var why: String = Job3.can_job3(world)
	content.add_child(UiTheme.label("Hai nhánh chức 2 hợp về một chức. +10%% HP và Tấn công (tổng +30%%), giữ mọi hiệu ứng và kỹ năng của chức 1, chức 2, thêm 2 hiệu ứng và 1 Thần Kỹ. Cần cấp %d, tốn %d Tinh Thạch (có %d)." % [Classes.JOB3_LEVEL, Classes.JOB3_CRYSTAL, int(p.crystal)], "Muted", 600))
	if why != "":
		var warn := UiTheme.label(why, "", 600)
		warn.add_theme_color_override("font_color", Color("#ffb27a"))
		content.add_child(warn)
	var card := PanelContainer.new()
	card.name = "Job3Card"
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.14, 0.15, 0.2, 0.95)
	sb.border_color = SILVER
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(10)
	sb.shadow_color = Color(SILVER, 0.35)
	sb.shadow_size = 14
	sb.set_content_margin_all(18)
	card.add_theme_stylebox_override("panel", sb)
	content.add_child(card)
	var v := UiTheme.vbox(10)
	card.add_child(v)
	var name := UiTheme.label(str(j.name), "Heading")
	name.add_theme_color_override("font_color", SILVER)
	v.add_child(name)
	for k in (j.effects as Array).size():
		v.add_child(UiTheme.label("Hiệu ứng %d · %s" % [k + 1, j.effects[k]], "", 580))
	var sk: Dictionary = Classes.skill_by_id(cid, str(j.skill))
	if not sk.is_empty():
		var row := UiTheme.hbox(12)
		var tex := SpriteLib.icon("skill-" + str(sk.icon))
		if tex != null:
			row.add_child(UiTheme.icon_rect(tex, 48))
		var sv := UiTheme.vbox(4)
		var sn := UiTheme.strong("Thần Kỹ · %s  (hồi %d giây · %d MP)" % [sk.name, int(sk.cd), int(sk.mp)], 16, SILVER)
		sv.add_child(sn)
		sv.add_child(UiTheme.label(str(sk.text), "Muted", 500))
		row.add_child(sv)
		v.add_child(row)
	var b := UiTheme.button("Chuyển chức %s" % j.name, true)
	b.name = "Job3_" + str(j.id)
	b.disabled = why != ""
	if why != "":
		b.tooltip_text = why  # UI-62: lý do khoá
	b.pressed.connect(func():
		if Job3.do_job3(world):
			close())
	v.add_child(b)
