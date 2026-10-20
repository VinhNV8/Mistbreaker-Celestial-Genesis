extends Node
## C1-40, C1-41: phát hiệu ứng âm thanh và nhạc nền (file do tools/audio/gen_audio.py sinh).
## Logic game chỉ ghi id âm thanh vào GameWorld.sfx; main.gd chuyển sang đây mỗi khung hình.

const Settings = preload("res://scripts/core/settings.gd")
const SFX_DIR := "res://assets/audio/sfx/"
const MUSIC_DIR := "res://assets/audio/music/"
const VOICES := 10
## Cùng một âm không phát lại trong khoảng này (giây) — tránh rè khi trúng nhiều quái một lúc.
const MIN_GAP := 0.05

var _cache := {}
var _voices: Array = []
var _next := 0
var _last := {}
var _music: AudioStreamPlayer
var _music_id := ""


func _ready() -> void:
	Settings.load_settings()
	for i in VOICES:
		var p := AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		_voices.append(p)
	_music = AudioStreamPlayer.new()
	_music.bus = "Music"
	add_child(_music)


func _load(path: String) -> AudioStream:
	if _cache.has(path):
		return _cache[path]
	var s: AudioStream = null
	if ResourceLoader.exists(path):
		s = load(path)
	_cache[path] = s
	return s


func has_sfx(id: String) -> bool:
	return ResourceLoader.exists(SFX_DIR + id + ".wav")


func play(id: String, pitch_jitter := 0.06) -> void:
	var now := Time.get_ticks_msec() / 1000.0
	if now - float(_last.get(id, -1.0)) < MIN_GAP:
		return
	_last[id] = now
	var s := _load(SFX_DIR + id + ".wav")
	if s == null:
		return
	var p: AudioStreamPlayer = _voices[_next]
	_next = (_next + 1) % VOICES
	p.stream = s
	p.pitch_scale = 1.0 + randf_range(-pitch_jitter, pitch_jitter)
	p.play()


## Đổi nhạc nền (mờ dần 0,6 giây). id rỗng = tắt.
func music(id: String) -> void:
	if id == _music_id:
		return
	_music_id = id
	var tw := create_tween()
	tw.tween_property(_music, "volume_db", -40.0, 0.6)
	tw.tween_callback(func():
		var s := _load(MUSIC_DIR + id + ".wav") if id != "" else null
		if s is AudioStreamWAV:
			var w := s as AudioStreamWAV
			w.loop_mode = AudioStreamWAV.LOOP_FORWARD
			w.loop_begin = 0
			w.loop_end = int(w.get_length() * w.mix_rate)
		_music.stream = s
		if s != null:
			_music.play()
		else:
			_music.stop())
	tw.tween_property(_music, "volume_db", 0.0, 0.6)


func current_music() -> String:
	return _music_id
