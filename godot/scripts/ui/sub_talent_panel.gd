extends "res://scripts/ui/modal.gd"
## TP5-02 (docs/33): Lễ Thức Tỉnh cho ô Thiên phú phụ — mở sau khi chuyển chức 1 / 2, hoặc từ bảng Thiên phú.
## Quay như lễ đầu (1 + 3 lần quay lại, bảo hiểm hạng B, chọn bất kỳ lần nào); bể không có Thiên phú đang có và Đạo Tặc.
## Lượt đã quay giữ ở GameWorld.sub_aw tới khi nhận (đóng bảng làm sau được).

const Talents = preload("res://scripts/data/talents.gd")
const TalentSlots = preload("res://scripts/core/talent_slots.gd")
const Screens = preload("res://scripts/ui/screens.gd")

var _selected := -1


func open(w) -> void:
	_selected = -1
	super.open(w)


func _render(content: VBoxContainer) -> void:
	content.add_theme_constant_override("separation", 10)
	var p = world.profile
	var aw = world.sub_ritual()
	var head := UiTheme.hbox(12)
	var title := UiTheme.strong("Lễ Thức Tỉnh · Thiên phú phụ", 24, UiTheme.GOLD)
	head.add_child(title)
	head.add_child(UiTheme.spacer())
	var close_b := UiTheme.button("Để sau (Esc)")
	close_b.name = "SubClose"
	close_b.pressed.connect(close)
	head.add_child(close_b)
	content.add_child(head)
	if aw == null:
		content.add_child(UiTheme.label("Chưa có ô Thiên phú phụ trống — ô 2 mở khi chuyển chức 1 (cấp 30), ô 3 khi chuyển chức 2 (cấp 60).", "", 560))
		return
	content.add_child(UiTheme.label("Ô Thiên phú thứ %d. Chạm Bia Đá để nhận Thiên phú phụ — có cấp riêng (luyện ở Đền Thiên Phú), hiệu ứng bị động; 2 Thiên phú cùng nhóm tạo Cộng hưởng." % (p.subs.size() + 2), "Muted", 640))
	if _selected < 0 and not aw.rolls.is_empty():
		_selected = aw.rolls.size() - 1
	var shown = aw.rolls[_selected] if _selected >= 0 and _selected < aw.rolls.size() else null
	var center := CenterContainer.new()
	center.add_child(Screens._card(shown, false))
	content.add_child(center)
	var chips := HFlowContainer.new()
	chips.alignment = FlowContainer.ALIGNMENT_CENTER
	for i in aw.rolls.size():
		var t: Dictionary = aw.rolls[i]
		var chip := UiTheme.button("Lần %d: %s · %s" % [i + 1, t.rank, t.name], i == _selected)
		chip.name = "SubRoll_%d" % i
		var idx: int = i
		chip.pressed.connect(func():
			_selected = idx
			refresh())
		chips.add_child(chip)
	content.add_child(chips)
	var row := UiTheme.hbox(10)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	var roll := UiTheme.button("Chạm Bia Đá" if aw.rolls.is_empty() else "Quay lại (còn %d lần)" % aw.rerolls_left(), true)
	roll.name = "SubRollButton"
	roll.disabled = not aw.can_roll()
	roll.pressed.connect(func():
		aw.roll()
		_selected = aw.rolls.size() - 1
		refresh())
	row.add_child(roll)
	var accept := UiTheme.button("Nhận Thiên phú này")
	accept.name = "SubAcceptButton"
	accept.disabled = shown == null
	accept.pressed.connect(func():
		if shown != null and bool(world.accept_sub(str(shown.id)).ok):
			close())
	row.add_child(accept)
	content.add_child(row)
	var rates := PackedStringArray()
	for r in Talents.RANK_ORDER:
		if r != "SSS":
			rates.append("%s %s%%" % [r, str(Talents.RANK_WEIGHT[r])])
	content.add_child(UiTheme.label("Bể quay: %d Thiên phú (không gồm Thiên phú đang có, không có Đạo Tặc). Tỉ lệ theo hạng: %s. Bảo hiểm: cả 4 lần dưới hạng B thì lần cuối lên hạng B." % [TalentSlots.sub_pool(p).size(), " · ".join(rates)], "Small", 640))
