extends "res://scripts/ui/modal.gd"
## M12.4 (docs/18 C9-50): Điểm Thiên Đạo — cấp sau 100 (Thần Vực N / Khai Thế N), 5 nhánh, tẩy điểm ở vùng an toàn.
## Mở bằng phím E với Vân Hạc ở Thiên Thê Đài I sau khi đã chọn kết thúc. Kèm tóm tắt Thần Vực / Tái Thiết.

const Endgame = preload("res://scripts/core/endgame.gd")
const Explore = preload("res://scripts/core/explore.gd")

const GOLD := Color("#fff0b0")


func _render(content: VBoxContainer) -> void:
	var p = world.profile
	content.custom_minimum_size.x = 620
	var end_name := "Hợp nhất — Thiên Đạo mới" if str(p.ending) == "hop-nhat" else "Hiến tế — sương mù tan"
	_header(content, "Thiên Đạo · " + end_name, "Đóng (Esc)")
	var title: String = Endgame.divine_title(world)
	var need := Endgame.divine_need(int(p.divine_level))
	content.add_child(UiTheme.label("%s · EXP tới cấp kế: %d / %d" % [title if title != "" else "Cấp 100", int(p.xp), need] if int(p.level) >= 100
		else "Cấp sau 100 mở khi đạt cấp 100.", "Muted", 600))
	var pts := UiTheme.strong("Điểm Thiên Đạo còn lại: %d" % Endgame.unspent(world), 16, GOLD)
	pts.name = "DivineUnspent"
	content.add_child(pts)
	for b in Endgame.BRANCHES:
		var row := UiTheme.hbox(10)
		var n := Endgame.points(world, b)
		var eff: String
		match b:
			"cd":
				eff = "−%.1f%% (trần −15%%)" % (minf(Endgame.CD_CAP, n * Endgame.BRANCHES.cd) * 100.0)
			_:
				eff = "+%.1f%%" % (n * float(Endgame.BRANCHES[b]) * 100.0)
		row.add_child(UiTheme.label("%s · %d điểm · %s" % [Endgame.BRANCH_NAMES[b], n, eff], "", 430))
		var btn := UiTheme.button("+1")
		btn.name = "Divine_" + b
		btn.disabled = Endgame.unspent(world) <= 0
		btn.pressed.connect(func():
			var r := Endgame.allocate(world, b)
			world._message(r.message, "good" if r.ok else "bad")
			refresh())
		row.add_child(btn)
		content.add_child(row)
	var reset := UiTheme.button("Tẩy điểm (miễn phí, ở vùng an toàn)")
	reset.pressed.connect(func():
		var r := Endgame.respec(world)
		world._message(r.message, "good" if r.ok else "bad")
		refresh())
	content.add_child(reset)
	content.add_child(HSeparator.new())
	if str(p.ending) == "hop-nhat":
		content.add_child(UiTheme.label("Thần Vực: bấm E ở Cổng Thần Vực (Thiên Thê Đài I). Kỷ lục: tầng %d." % int(p.tower_best), "Small", 600))
	else:
		content.add_child(UiTheme.label("Tái Thiết Lục Địa: %d/9 công trình (bảng Khai phá — phím M, ở vùng tương ứng)." % Endgame.rebuilt_count(p), "Small", 600))
		for k in range(1, 10):
			var done: bool = Explore.is_built(p, "rebuild%d" % k)
			content.add_child(UiTheme.label("%s Vùng %d · %s — %s" % ["✓" if done else "·", k, Endgame.REBUILD_NAMES[k], Endgame.REBUILD_TEXT[k]], "Small", 600))
