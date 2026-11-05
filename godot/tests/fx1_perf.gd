extends SceneTree
## FX-1 (docs/36 §9.7): đo thời gian CPU dựng hiệu ứng mỗi khung trong tình huống nặng — thi triển cả 70 kỹ năng cùng lúc
## + 10 linh thú vừa gọi + vùng / mưa / thiên thạch. Painter không vẽ (ci = null) để chỉ đo phần dựng hình của FX-1.
##   Godot_console.exe --headless --path godot --script res://tests/fx1_perf.gd

const GameWorld = preload("res://scripts/core/game_world.gd")
const Profile = preload("res://scripts/core/profile.gd")
const RngUtil = preload("res://scripts/core/rng_util.gd")
const Fx1 = preload("res://scripts/view/fx1.gd")
const Kit = preload("res://scripts/view/fx1_kit.gd")


func _initialize() -> void:
	var p := Profile.new()
	p.setup("tay-nhanh", RngUtil.make(7), 0.0)
	p.quest_step = 12
	var w := GameWorld.new(p, RngUtil.make(5))
	w.enemies = []
	for i in 8:
		w.spawn_enemy("wolf", 30, w.player.pos + Vector2(120 + i * 20, -60 + i * 15))
	Fx1.set_mode("fx1")
	for id in Fx1.SK:
		Fx1.on_cast(w, {"id": id})
	for i in 10:
		var a := w.Ally.new()
		a.kind = "summon"
		a.monster = "linh-hon"
		a.skill = "quandoan"
		a.pos = w.player.pos + Vector2(i * 12, 30)
		w.allies.append(a)
	for i in 4:
		w.sk2.ice.append({"pos": w.player.pos + Vector2(i * 60, 0), "r": 100.0, "ticks": 8, "timer": 0.2, "skill": ["muabang", "khidoc", "thanhvuc", "linhtran"][i], "gap": 0.5})
	var frames := 60
	var worst := 0.0
	var total := 0.0
	var polys := 0
	for k in frames:
		var t0 := Time.get_ticks_usec()
		var pa = Kit.Painter.new()
		pa.strict = false  # như trong game (Painter có CanvasItem)
		Fx1.draw(pa, w)
		for z in w.sk2.ice:
			Fx1.draw_zone(pa, w, z)
		var dt := float(Time.get_ticks_usec() - t0) / 1000.0
		total += dt
		worst = maxf(worst, dt)
		polys = maxi(polys, pa.n)
		Fx1.tick(w, 1.0 / 60.0)
	# tình huống thực tế: 7 ô của một lớp (Pháp Sư) cùng lúc + 10 linh thú + 4 vùng
	Fx1.casts = []
	for id in ["chain", "meteor", "nova", "muabang", "thienhoa", "bangphong", "thienloi"]:
		Fx1.on_cast(w, {"id": id})
	var t7 := 0.0
	var w7 := 0.0
	for k in frames:
		var t1 := Time.get_ticks_usec()
		var pb = Kit.Painter.new()
		pb.strict = false
		Fx1.draw(pb, w)
		for z in w.sk2.ice:
			Fx1.draw_zone(pb, w, z)
		var d7 := float(Time.get_ticks_usec() - t1) / 1000.0
		t7 += d7
		w7 = maxf(w7, d7)
		Fx1.tick(w, 1.0 / 60.0)
	print("FX1 perf (7 ô 1 lớp + 10 linh thú + 4 vùng): avg %.2f ms, worst %.2f ms" % [t7 / frames, w7])
	# §9.12 cảnh báo kiểu tự nhiên: 20 quái lấy đà cùng lúc (8 tinh anh / boss có vết + 12 quái thường), gồm vòng / dải / nón
	var kinds := ["stomp", "pounce", "roar", "roots", "volley", "leaf", "explode", "dash", "tiger", "spore"]
	var foes: Array = []
	for i in 20:
		var fe := w.spawn_enemy("wolf", 30, w.player.pos + Vector2(-400 + (i % 5) * 200, -300 + (i / 5) * 160))
		fe.state = "windup"
		fe.attack_kind = kinds[i % kinds.size()]
		fe.elite = i < 8
		fe.windup_total = 1.0
		fe.timer = 0.3
		fe.target = fe.pos + Vector2(120, 40)
		foes.append(fe)
	var tn := 0.0
	var wn := 0.0
	for k in frames:
		var t2 := Time.get_ticks_usec()
		var pn = Kit.Painter.new()
		pn.strict = false
		Fx1.painter = pn
		Fx1.flush_ground(pn, w)
		for fe in foes:
			Fx1.windup_cue(pn, w, fe, 0.7)
			Fx1.danger_zone(w, fe.target, 70.0, Fx1.P_DANGER, 0.7, fe)
		Fx1.danger_line(w, w.player.pos, w.player.pos + Vector2(300, 0), 15.0, Fx1.P_FIRE, 0.7)
		Fx1.danger_cone(w, w.player.pos, 0.5, 0.6, 180.0, Fx1.P_FIRE, 0.7)
		var dn := float(Time.get_ticks_usec() - t2) / 1000.0
		tn += dn
		wn = maxf(wn, dn)
	print("FX1 perf cảnh báo tự nhiên (20 quái lấy đà + dải + nón): avg %.2f ms, worst %.2f ms" % [tn / frames, wn])
	print("FX1 perf: 70 casts + 10 summons + 4 zones — avg %.2f ms, worst %.2f ms, <= %d draw calls / frame" % [total / frames, worst, polys])
	quit()
