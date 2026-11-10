extends Node
## C1-40, C1-41: phát hiệu ứng âm thanh (sfx do tools/audio/gen_audio.py sinh) và nhạc nền.
## Logic game chỉ ghi id âm thanh vào GameWorld.sfx; main.gd chuyển sang đây mỗi khung hình.
## MU-1 (docs/46): nhạc nền thế hệ 2 (OGG stereo, tools/audio/songs2.py) —
##   S2 bài khám phá phát 1 lượt rồi nghỉ REST_MIN…REST_MAX giây (chỉ còn âm môi trường) rồi vào lại; LOOP_IDS lặp liền;
##   S3 âm môi trường theo vùng (bus "Ambient", luôn lặp, đổi thì mờ chéo);
##   S5 nhạc báo (stinger) — nhạc nền hạ DUCK_DB trong lúc phát; gặp boss tự phát "st_boss".
##   S4 (đợt 2) tầng chiến đấu — bài có file <id>_combat.ogg phát cùng bài chính trong 1 AudioStreamSynchronized
##   (cùng nhịp, cùng độ dài); set_combat(true) → tầng dâng lên trong COMBAT_IN giây, hết đánh → lắng trong COMBAT_OUT;
##   đang nghỉ (S2) mà vào trận → bài vào luôn.

const Settings = preload("res://scripts/core/settings.gd")
const SFX_DIR := "res://assets/audio/sfx/"
const MUSIC_DIR := "res://assets/audio/music/"
const STINGER_DIR := "res://assets/audio/stinger/"
const AMBIENT_DIR := "res://assets/audio/ambient/"
## Bài lặp liền (không nghỉ): làng, hang / Lõi Sương, boss.
const LOOP_IDS := ["village", "core", "boss", "boss_final"]
const BOSS_IDS := ["boss", "boss_final"]
## S2: khoảng nghỉ sau mỗi lượt bài khám phá (giây), thời gian mờ vào khi bài trở lại.
const REST_MIN := 30.0
const REST_MAX := 90.0
const FADE_IN_BACK := 3.0
## Đổi bài: mờ ra / vào (giây).
const SWITCH_FADE := 0.6
## S5: nhạc nền hạ bao nhiêu dB khi nhạc báo đang phát.
const DUCK_DB := -8.0
## Âm sfx được nhạc báo thay (đã có nhạc báo thì không phát sfx trùng ý).
const SFX_BY_STINGER := {"levelup": "st_levelup"}
## S4: tầng chiến đấu — hậu tố file, thời gian dâng / lắng (giây), mờ vào bài khi vào trận lúc đang nghỉ.
const COMBAT_SUFFIX := "_combat"
const COMBAT_IN := 1.5
const COMBAT_OUT := 4.0
const COMBAT_WAKE_FADE := 1.5
const VOICES := 10
## Cùng một âm không phát lại trong khoảng này (giây) — tránh rè khi trúng nhiều quái một lúc.
const MIN_GAP := 0.05

var _cache := {}
var _voices: Array = []
var _next := 0
var _last := {}
var _music: AudioStreamPlayer
var _music_id := ""
## Bài đang chờ vào (đang mờ bài cũ ra); "" = không chờ.
var _pending := ""
var _switching := false
## Hệ số âm lượng nhạc (0…1) hiện tại / đích / tốc độ (đơn vị / giây) — tự lerp trong _process (không dùng tween,
## để mờ và hạ khi nhạc báo cộng dồn được).
var _fade := 0.0
var _fade_to := 0.0
var _fade_speed := 1.0 / SWITCH_FADE
var _duck := 1.0
## S2: còn bao nhiêu giây nghỉ (≥ 0 = đang nghỉ); -1 = không nghỉ.
var rest_left := -1.0
var _ambient: AudioStreamPlayer
var _ambient_old: AudioStreamPlayer
var _ambient_id := ""
var _stinger: AudioStreamPlayer
var _stinger_id := ""
## S4: đang chiến đấu (main.gd gán mỗi khung qua set_combat), mức tầng chiến đấu hiện tại 0…1, bài hiện tại có tầng không.
var _combat_on := false
var combat_level := 0.0
var _layered := false


func _ready() -> void:
	Settings.load_settings()
	for i in VOICES:
		var p := AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		_voices.append(p)
	_music = AudioStreamPlayer.new()
	_music.bus = "Music"
	_music.volume_db = -80.0
	add_child(_music)
	_stinger = AudioStreamPlayer.new()
	_stinger.bus = "Music"
	add_child(_stinger)
	_ambient = AudioStreamPlayer.new()
	_ambient.bus = "Ambient"
	add_child(_ambient)
	_ambient_old = AudioStreamPlayer.new()
	_ambient_old.bus = "Ambient"
	add_child(_ambient_old)


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
	if SFX_BY_STINGER.has(id) and has_stream(STINGER_DIR, str(SFX_BY_STINGER[id])):
		return
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


## Có file âm thanh <dir><id>.ogg.
static func has_stream(dir: String, id: String) -> bool:
	return id != "" and ResourceLoader.exists(dir + id + ".ogg")


static func is_loop(id: String) -> bool:
	return id in LOOP_IDS


## S2: độ dài khoảng nghỉ sau 1 lượt bài khám phá.
static func rest_seconds(r: float) -> float:
	return lerpf(REST_MIN, REST_MAX, clampf(r, 0.0, 1.0))


func _ogg(dir: String, id: String, loop: bool) -> AudioStream:
	if not has_stream(dir, id):
		return null
	var s := _load(dir + id + ".ogg")
	if s is AudioStreamOggVorbis:
		(s as AudioStreamOggVorbis).loop = loop
	return s


## Đổi nhạc nền (mờ ra SWITCH_FADE giây rồi vào bài mới). id rỗng = tắt. Vào trận boss: phát nhạc báo st_boss.
func music(id: String) -> void:
	if id == _music_id:
		return
	if id in BOSS_IDS and not (_music_id in BOSS_IDS):
		stinger("st_boss")
	_music_id = id
	_pending = id
	_switching = true
	rest_left = -1.0
	_fade_to = 0.0
	_fade_speed = 1.0 / SWITCH_FADE


func _start_pending() -> void:
	_switching = false
	var s := _ogg(MUSIC_DIR, _pending, is_loop(_pending)) if _pending != "" else null
	# S4: có tầng chiến đấu → phát đồng bộ 2 file, tầng ở mức combat_level
	_layered = false
	if s != null and has_stream(MUSIC_DIR, _pending + COMBAT_SUFFIX):
		var sync := AudioStreamSynchronized.new()
		sync.stream_count = 2
		sync.set_sync_stream(0, s)
		sync.set_sync_stream(1, _ogg(MUSIC_DIR, _pending + COMBAT_SUFFIX, is_loop(_pending)))
		sync.set_sync_stream_volume(1, layer_db(combat_level))
		s = sync
		_layered = true
	_pending = ""
	_music.stream = s
	if s != null:
		_music.play()
		_fade_to = 1.0
		_fade_speed = 1.0 / SWITCH_FADE
	else:
		_music.stop()


func current_music() -> String:
	return _music_id


## S4: main.gd gọi mỗi khung với GameWorld.in_combat().
func set_combat(on: bool) -> void:
	_combat_on = on


func has_combat_layer() -> bool:
	return _layered


## S4: mức tầng (0…1) → dB của luồng tầng trong AudioStreamSynchronized.
static func layer_db(level: float) -> float:
	return linear_to_db(maxf(0.0001, level))


## S5: phát nhạc báo (nhạc nền hạ DUCK_DB trong lúc phát). Không có file → bỏ qua.
func stinger(id: String) -> void:
	var s := _ogg(STINGER_DIR, id, false)
	if s == null:
		return
	_stinger_id = id
	_stinger.stream = s
	_stinger.play()


func current_stinger() -> String:
	return _stinger_id if _stinger.playing else ""


## S3: âm môi trường theo vùng (lặp), đổi thì mờ chéo 1,5 giây. id rỗng = tắt.
func ambient(id: String) -> void:
	if id == _ambient_id:
		return
	_ambient_id = id
	var old := _ambient
	_ambient = _ambient_old
	_ambient_old = old
	if _ambient_old.playing:
		var fading := _ambient_old
		var tw := create_tween()
		tw.tween_property(fading, "volume_db", -60.0, 1.5)
		tw.tween_callback(fading.stop)
	var s := _ogg(AMBIENT_DIR, id, true)
	_ambient.stream = s
	if s != null:
		_ambient.volume_db = -60.0
		_ambient.play()
		create_tween().tween_property(_ambient, "volume_db", 0.0, 1.5)


func current_ambient() -> String:
	return _ambient_id


func _process(delta: float) -> void:
	step(delta)


## Một bước của bộ phát nhạc (tách riêng để test gọi trực tiếp).
func step(delta: float) -> void:
	# đổi bài: mờ hết rồi mới vào bài mới
	if _switching and _fade <= 0.001:
		_start_pending()
	# S2: bài khám phá hết lượt → nghỉ → vào lại (mờ vào chậm)
	if not _switching and _music.stream != null and not is_loop(_music_id):
		if not _music.playing and rest_left < 0.0:
			rest_left = rest_seconds(randf())
			_fade = 0.0
		elif rest_left >= 0.0:
			rest_left -= delta
			# S4: đang nghỉ mà vào trận → bài (có tầng chiến đấu) vào luôn
			var wake := _combat_on and _layered
			if wake:
				rest_left = -1.0
			if rest_left < 0.0:
				rest_left = -1.0
				_fade = 0.0
				_fade_to = 1.0
				_fade_speed = 1.0 / (COMBAT_WAKE_FADE if wake else FADE_IN_BACK)
				_music.play()
	_fade = move_toward(_fade, _fade_to, delta * _fade_speed)
	var duck_to := db_to_linear(DUCK_DB) if _stinger.playing else 1.0
	_duck = move_toward(_duck, duck_to, delta * 4.0)
	_music.volume_db = linear_to_db(maxf(0.0001, _fade * _duck))
	# S4: tầng chiến đấu dâng / lắng
	combat_level = move_toward(combat_level, 1.0 if _combat_on else 0.0, delta / (COMBAT_IN if _combat_on else COMBAT_OUT))
	if _layered and _music.stream is AudioStreamSynchronized:
		(_music.stream as AudioStreamSynchronized).set_sync_stream_volume(1, layer_db(combat_level))
