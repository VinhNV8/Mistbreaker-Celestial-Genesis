extends RefCounted
## WB-1 (docs/48 §B): lời chào khi người chơi chọn nhân vật cũ và vào lại game — chào theo buổi + tên, đã vắng bao lâu,
## lần trước dừng ở đâu / nhiệm vụ đang làm, lãnh địa thu hoạch khi vắng mặt, việc nên làm ngay (uỷ thác, điểm tiềm năng,
## tăng Lực chiến). Logic thuần — ui/welcome_panel.gd vẽ, main.gd (_on_continue) mở.

const Classes = preload("res://scripts/data/classes.gd")
const QuestLog = preload("res://scripts/core/quest_log.gd")
const Quests = preload("res://scripts/core/quests.gd")
const Gear = preload("res://scripts/core/gear.gd")

## Vắng ≥ 3 ngày: thêm câu "lâu rồi mới gặp".
const LONG_AWAY := 3.0 * 86400.0


static func greeting(hour: int) -> String:
	if hour >= 5 and hour < 11:
		return "Chào buổi sáng"
	if hour >= 11 and hour < 14:
		return "Chào buổi trưa"
	if hour >= 14 and hour < 18:
		return "Chào buổi chiều"
	return "Chào buổi tối"


## 93784 → "1 ngày 2 giờ"; 5400 → "1 giờ 30 phút"; 300 → "5 phút"; < 60 → "vài giây".
static func away_text(seconds: float) -> String:
	var s := int(maxf(0.0, seconds))
	var d := s / 86400
	var h := (s % 86400) / 3600
	var m := (s % 3600) / 60
	if d > 0:
		return "%d ngày%s" % [d, (" %d giờ" % h) if h > 0 else ""]
	if h > 0:
		return "%d giờ%s" % [h, (" %d phút" % m) if m > 0 else ""]
	if m > 0:
		return "%d phút" % m
	return "vài giây"


## {title, subtitle, sections: [{head, lines: [[icon, text, tone]]}]}. tone: "" | "good" | "todo".
## off = SaveSystem.apply_offline (+ "exp"); away = giây thật kể từ lần thoát (chưa cắt theo giới hạn lãnh địa).
static func build(w, away: float, off: Dictionary, hour: int) -> Dictionary:
	var p = w.profile
	var out := {
		"title": "%s, %s!" % [greeting(hour), str(p.name)],
		"subtitle": "Chào mừng trở lại · %s · Cấp %d" % [Classes.title(str(p.class_id), str(p.job), str(p.job2), str(p.job3)), int(p.level)],
		"sections": [],
	}
	var where: Array = []
	var gone := "Bạn đã rời đi %s." % away_text(away)
	if away >= LONG_AWAY:
		gone = "Lâu rồi mới gặp lại — bạn đã rời đi %s, vùng đất vẫn đang chờ." % away_text(away)
	where.append(["stat-move", gone, ""])
	where.append(["stat-main", "Lần trước dừng ở: %s." % str(w.map.get("name", "")), ""])
	var ms: Dictionary = QuestLog.main_step(w)
	if not ms.is_empty():
		var q: Dictionary = ms.get("q", {})
		where.append(["stat-auto", "Nhiệm vụ chương %d (%d/%d): %s — %s" % [int(ms.chapter), int(ms.step), int(ms.total), str(q.get("title", "")), str(q.get("hint", ""))], ""])
	out.sections.append({"head": "LẦN TRƯỚC", "lines": where})
	var got: Array = []
	if float(off.get("exp", 0.0)) >= 1.0:
		got.append(["res-essence", "+%d EXP từ lãnh địa" % int(off.exp), "good"])
	var res := PackedStringArray()
	for pair in [["gold", "vàng"], ["wood", "gỗ"], ["ore", "Đá"], ["iron", "Sắt"]]:
		if float(off.get(pair[0], 0.0)) >= 1.0:
			res.append("+%d %s" % [int(off[pair[0]]), pair[1]])
	if int(off.get("torches", 0)) > 0:
		res.append("+%d Đuốc" % int(off.torches))
	if int(off.get("herbs", 0)) > 0:
		res.append("+%d thảo dược" % int(off.herbs))
	if not res.is_empty():
		got.append(["res-gold", "Lãnh địa thu hoạch: " + ", ".join(res), "good"])
	if not got.is_empty():
		out.sections.append({"head": "TRONG LÚC VẮNG MẶT", "lines": got})
	var todo: Array = []
	var tasks: Array = Quests.tasks(w)
	var left := tasks.filter(func(t): return not bool(t.get("claimed", false))).size()
	if left > 0:
		todo.append(["res-torch", "Uỷ thác hôm nay còn %d / %d việc (phím O)." % [left, tasks.size()], "todo"])
	if int(p.unspent) > 0:
		todo.append(["stat-str", "Còn %d điểm tiềm năng chưa cộng (phím C)." % int(p.unspent), "todo"])
	if int(p.skill_points) > 0:
		todo.append(["stat-skill", "Còn %d Điểm Kỹ Năng chưa dùng (phím U)." % int(p.skill_points), "todo"])
	var tips: int = Gear.suggestions(p).size()
	if tips > 0:
		todo.append(["stat-atk", "Có %d việc tăng Lực chiến làm được ngay — bấm huy hiệu Lực chiến." % tips, "todo"])
	if not todo.is_empty():
		out.sections.append({"head": "NÊN LÀM NGAY", "lines": todo})
	return out
