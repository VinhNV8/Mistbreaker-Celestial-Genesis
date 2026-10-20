extends SceneTree
const SkillBar = preload("res://scripts/ui/skill_bar.gd")
const SpriteLib = preload("res://scripts/view/sprite_lib.gd")
func _initialize() -> void:
	var bg := ColorRect.new()
	bg.color = Color("#2f4a2a")
	bg.size = Vector2(1366, 768)
	root.add_child(bg)
	var b = SkillBar.new()
	b.set_count(8)
	b.position = Vector2(110, 40)
	root.add_child(b)
	var data := [
		{"key": "J", "name": "Chém", "icon": SpriteLib.icon("skill-slash"), "sub": "Đánh thường"},
		{"key": "1", "name": "Lốc Kiếm", "icon": SpriteLib.icon("skill-spin"), "sub": "15 MP"},
		{"key": "2", "name": "Đột Kích", "icon": SpriteLib.icon("skill-dash"), "cd": 0.6, "cd_text": "5", "sub": "20 MP"},
		{"key": "3", "name": "Kiếm Khí", "icon": SpriteLib.icon("skill-wave"), "dim": true, "sub": "Thiếu MP"},
		{"key": "4", "name": "Thiết Bích", "icon": SpriteLib.icon("skill-guard"), "cd": 0.25, "cd_text": "5", "sub": "25 MP"},
		{"key": "Space", "name": "Né lăn", "icon": SpriteLib.icon("skill-dodge")},
		{"key": "L", "name": "Cuồng Nộ Thần Sấm", "icon": SpriteLib.talent_icon("huyet-chien"), "ring": Color("#ff6a3c"), "sub": "Thiên phú"},
		{"key": "Q", "name": "Bình máu", "icon": SpriteLib.icon("skill-potion"), "sub": "×3 · Thảo 1/2"},
	]
	for i in 8:
		b.set_slot(i, data[i])
	for k in 4:
		await process_frame
	root.get_texture().get_image().save_png("res://tests/tmp_sb/bar.png")
	quit()
