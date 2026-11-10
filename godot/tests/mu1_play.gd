extends SceneTree
## MU-1 (docs/46): chạy AudioManager THẬT trong cây scene (headless được) — bài khám phá hết lượt → nghỉ → vào lại,
## gặp boss → nhạc báo st_boss + nhạc nền hạ, đổi âm môi trường. In "MU1 PLAY ok" / "MU1 PLAY FAIL …".
##   Godot_console.exe --headless --path godot --script res://tests/mu1_play.gd

const AudioManager = preload("res://scripts/audio/audio_manager.gd")

var _fails: Array[String] = []


func _check(c: bool, msg: String) -> void:
	print(("  ok   " if c else "  FAIL ") + msg)
	if not c:
		_fails.append(msg)


func _initialize() -> void:
	_run.call_deferred()


func _frames(n: int) -> void:
	for i in n:
		await process_frame


func _run() -> void:
	var am: Node = AudioManager.new()
	root.add_child(am)
	await _frames(2)
	am.music("forest")
	am.ambient("amb_forest")
	await _frames(60)
	_check(am._music.playing and am._music.stream is AudioStreamOggVorbis and not am._music.stream.loop, "forest phát, không lặp trong file")
	_check(am._ambient.playing and am._ambient.stream.loop, "âm rừng phát, lặp")
	# tua tới cuối bài → hết lượt → nghỉ
	am._music.seek(am._music.stream.get_length() - 0.1)
	await _frames(30)
	_check(not am._music.playing and am.rest_left >= 0.0 and am.rest_left <= 90.0, "hết lượt: đang nghỉ (còn %.1f giây)" % am.rest_left)
	am.rest_left = 0.05
	await _frames(20)
	_check(am._music.playing, "hết nghỉ: bài vào lại")
	am.music("boss")
	await _frames(2)
	_check(am.current_stinger() == "st_boss", "vào trận boss: nhạc báo st_boss")
	await _frames(60)
	_check(am._music.playing and am._music.stream.loop and am._duck < 0.7, "boss lặp liền, nhạc nền đang hạ khi nhạc báo phát (%.2f)" % am._duck)
	am.ambient("amb_cave")
	await create_timer(1.8).timeout
	_check(am.current_ambient() == "amb_cave" and am._ambient.playing and not am._ambient_old.playing, "đổi âm môi trường: mờ chéo xong")
	am.stinger("st_levelup")
	am.play("levelup")
	_check(am.current_stinger() == "st_levelup", "lên cấp: nhạc báo (âm levelup cũ bỏ qua)")
	print("MU1 PLAY ok" if _fails.is_empty() else "MU1 PLAY FAIL %s" % str(_fails))
	quit()
