extends SceneTree
## Đo độ mượt khi đi: chạy game có cửa sổ, nhân vật tự đi vòng, ghi thời gian khung hình + bước nhân vật / camera.
## godot --path godot --script res://tests/perf_walk.gd -- [--map=1-1] [--secs=12]
const Profile = preload("res://scripts/core/profile.gd")
const RngUtil = preload("res://scripts/core/rng_util.gd")

var main
var frames: Array = []
var flick: Array = []
var t := 0.0
var started := false
var secs := 12.0
var map_id := "1-1"
var off := ""
var prev_p := Vector2.ZERO
var prev_c := Vector2.ZERO
var prev_screen := Vector2.ZERO


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--secs="):
			secs = float(a.substr(7))
		if a.begins_with("--off="):
			off = a.substr(6)
		if a.begins_with("--map="):
			map_id = a.substr(6)
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)


func _process(delta: float) -> bool:
	if not started:
		if Engine.get_process_frames() < 5:
			return false
		var p := Profile.new()
		p.setup("tay-nhanh", RngUtil.make(3), 0.0)
		p.quest_step = 12
		p.class_id = "kiem-khach"
		p.level = 30
		p.map_id = map_id
		main._start_world(p)
		if not OS.get_cmdline_user_args().has("--mobs"):
			main.world.field_spawn = false
			main.world.enemies = []
		main.world.player.pos = main.world.safe_pos + Vector2(700, 0)
		var explore := OS.get_cmdline_user_args().has("--explore")
		if not explore:
			main.world.fog.reveal(main.world.player.pos, 2000.0)
		main.bot = func(w): return {"move": Vector2(1, 0.35 * sin(w.time * 0.5)) if explore else Vector2.from_angle(w.time * 0.6), "aim": w.player.pos + Vector2.RIGHT, "attack": false, "skill": false, "talent": false, "dodge": false}
		for o in off.split(",", false):
			match o:
				"hud": main.hud.visible = false
				"view": main._view.visible = false
				"fog": main._view._fog_layer.visible = false
				"fx": main._fx.visible = false
				"nohd": main._view.SpriteLib.set_hd(false)
				"noart": main._view._art = false
				_:
					if o.begins_with("only:"):
						for ch in main.hud.get_children():
							var sp: String = ch.get_script().resource_path if ch.get_script() else ""
							ch.set_process(sp.contains(o.substr(5)))
					if o == "freeze":
						for ch in main.hud.get_children():
							ch.set_process(false)
					if o.begins_with("h:"):
						for ch in main.hud.get_children():
							if ch.name.contains(o.substr(2)) or ch.get_class().contains(o.substr(2)) or str(ch.get_script().resource_path if ch.get_script() else "").contains(o.substr(2)):
								ch.visible = false
		if off == "list":
			for ch in main.hud.get_children():
				print("HUDCHILD ", ch.name, " ", ch.get_class(), " ", ch.get_script().resource_path if ch.get_script() else "")
		started = true
		return false
	t += delta
	var w = main.world
	var cam: Camera2D = main._camera
	var c: Vector2 = cam.get_screen_center_position()
	var screen: Vector2 = w.player.pos - c
	if t > 1.0:
		frames.append({"dt": delta, "dp": w.player.pos.distance_to(prev_p), "dc": c.distance_to(prev_c), "ds": screen.distance_to(prev_screen)})
	if OS.get_cmdline_user_args().has("--flick") and t > 1.0:
		var img := root.get_viewport().get_texture().get_image()
		var sum := 0.0
		for y in range(20, 240, 4):
			for x in range(10, 300, 4):
				var px := img.get_pixel(x, y)
				sum += px.r + px.g + px.b
		flick.append(sum)
	prev_p = w.player.pos
	prev_c = c
	prev_screen = screen
	if t > 1.0 and frames.size() % 20 == 0:
		var t0 := Time.get_ticks_usec()
		main.hud.update_from(w)
		var t1 := Time.get_ticks_usec()
		w.update(0.0001, {"move": Vector2.ZERO, "aim": w.player.pos, "attack": false, "skill": false, "talent": false, "dodge": false})
		var t2 := Time.get_ticks_usec()
		var vr := Rect2(c - Vector2(683, 384), Vector2(1366, 768))
		print("MOBS total %d in view %d" % [w.enemies.size(), w.enemies.filter(func(e): return vr.has_point(e.pos)).size()])
		print("TIMING hud.update_from %.2f ms  world.update %.2f ms" % [(t1 - t0) / 1000.0, (t2 - t1) / 1000.0])
	if t > secs + 1.0:
		_report()
		for a in OS.get_cmdline_user_args():
			if a.begins_with("--shot="):
				root.get_viewport().get_texture().get_image().save_png(a.substr(7))
		return true
	return false


func _report() -> void:
	if not flick.is_empty():
		var jumps := 0
		var big := 0.0
		for i in range(1, flick.size()):
			var d: float = absf(flick[i] - flick[i - 1]) / maxf(1.0, flick[i - 1])
			big = maxf(big, d)
			if d > 0.01:
				jumps += 1
		print("FLICK frames %d  brightness jumps >1%%: %d  max jump %.2f%%" % [flick.size(), jumps, big * 100.0])
	var dts: Array = frames.map(func(f): return f.dt * 1000.0)
	dts.sort()
	var n := dts.size()
	var mean := 0.0
	for d in dts:
		mean += d
	mean /= n
	var spikes := dts.filter(func(d): return d > mean * 1.5).size()
	# Độ đều bước: tốc độ nhân vật (px/giây) theo từng khung — nếu dt đều mà bước lệch → giật do logic.
	var speeds: Array = frames.map(func(f): return f.dp / maxf(0.0001, f.dt))
	var sp_mean := 0.0
	for s in speeds:
		sp_mean += s
	sp_mean /= n
	var sp_dev := 0.0
	for s in speeds:
		sp_dev += absf(s - sp_mean)
	sp_dev /= n
	# Nhân vật trên màn hình: camera smoothing làm nó trôi — đo độ lắc khung-khung.
	var ds_mean := 0.0
	for f in frames:
		ds_mean += f.ds
	ds_mean /= n
	var zero_c := frames.filter(func(f): return f.dc < 0.01 and f.dp > 0.5).size()
	print("PERF map=%s frames=%d fps≈%.1f  dt ms: mean %.2f  p50 %.2f  p95 %.2f  p99 %.2f  max %.2f  spikes(>1.5x) %d" % [map_id, n, 1000.0 / mean, mean, dts[n / 2], dts[int(n * 0.95)], dts[int(n * 0.99)], dts[n - 1], spikes])
	print("PERF off=%s proc %.1f ms  draw calls %d  objects %d  primitives %d" % [off, Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0, Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME), Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME), Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)])
	print("PERF speed px/s mean %.1f  mean abs dev %.1f  | screen jitter px/frame %.2f | frames camera still while player moved: %d" % [sp_mean, sp_dev, ds_mean, zero_c])
