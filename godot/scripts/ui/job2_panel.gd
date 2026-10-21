extends "res://scripts/ui/modal.gd"
## C5-45, C5-47 (M8): chọn 1 trong 2 nhánh chuyển chức 2 (Liệt Diễm ở Trại Tro Hồng, phím E).

const Classes = preload("res://scripts/data/classes.gd")
const Ch5 = preload("res://scripts/core/chapter5.gd")


func _render(content: VBoxContainer) -> void:
	var p = world.profile
	content.custom_minimum_size.x = 760
	_header(content, "Chuyển chức lần 2 · %s" % Classes.title(str(p.class_id), str(p.job)), "Đóng (Esc)")
	var why: String = Ch5.can_job2(world)
	content.add_child(UiTheme.label("Chọn 1 trong 2 nhánh — không đổi được sau khi chọn. Mỗi nhánh: +10%% HP và Tấn công, giữ 2 hiệu ứng của chức 1, thêm 2 hiệu ứng mới. Tốn %d Tinh Thạch (có %d)." % [Classes.JOB2_CRYSTAL, int(p.crystal)], "Muted", 720))
	if why != "":
		var warn := UiTheme.label(why, "", 720)
		warn.add_theme_color_override("font_color", Color("#ffb27a"))
		content.add_child(warn)
	var row := UiTheme.hbox(16)
	content.add_child(row)
	for j in Classes.job2_defs(str(p.class_id)):
		var card := PanelContainer.new()
		card.custom_minimum_size = Vector2(350, 0)
		var v := UiTheme.vbox(8)
		card.add_child(v)
		var name := UiTheme.label(str(j.name), "Heading")
		name.add_theme_color_override("font_color", Color(j.color))
		v.add_child(name)
		v.add_child(UiTheme.label(str(j.text), "", 320))
		var b := UiTheme.button("Chọn %s" % j.name, true)
		b.name = "Job2_" + str(j.id)
		b.disabled = why != ""
		var id: String = j.id
		b.pressed.connect(func():
			if Ch5.do_job2(world, id):
				close())
		v.add_child(b)
		row.add_child(card)
