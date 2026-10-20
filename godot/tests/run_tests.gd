extends SceneTree
## Chạy: Godot --headless --path godot --script res://tests/run_tests.gd
## Thoát với mã 1 nếu có test hỏng (dùng được trong CI).

const Awakening = preload("res://scripts/core/awakening.gd")
const Config = preload("res://scripts/core/config.gd")
const Explore = preload("res://scripts/core/explore.gd")
const Formulas = preload("res://scripts/core/formulas.gd")
const GameWorld = preload("res://scripts/core/game_world.gd")
const Profile = preload("res://scripts/core/profile.gd")
const RngUtil = preload("res://scripts/core/rng_util.gd")
const SaveSystem = preload("res://scripts/core/save_system.gd")
const Talents = preload("res://scripts/data/talents.gd")
const Items = preload("res://scripts/core/items.gd")
const ItemData = preload("res://scripts/data/items.gd")
const Monsters = preload("res://scripts/data/monsters.gd")
const SpriteLib = preload("res://scripts/view/sprite_lib.gd")
const Classes = preload("res://scripts/data/classes.gd")
const Stats = preload("res://scripts/core/stats.gd")
const Looks = preload("res://scripts/data/looks.gd")

var _total := 0
var _failed: Array[String] = []
var _current := ""


func _init() -> void:
	_run("EXP theo tài liệu và luôn tăng dần", _test_exp)
	_run("công thức sát thương và combo", _test_damage)
	_run("Lễ Thức Tỉnh: 1 lần quay + 3 lần quay lại", _test_awakening_limits)
	_run("Lễ Thức Tỉnh: bảo hiểm hạng B", _test_awakening_pity)
	_run("Lễ Thức Tỉnh: tỉ lệ quay", _test_awakening_rates)
	_run("khai phá: lưới 10 ô, cơ cấu sự kiện", _test_tiles)
	_run("khai phá: chỉ dọn ô kề lãnh địa, tốn Đuốc", _test_reveal)
	_run("khai phá: Xưởng Gỗ cần vàng, có sản lượng", _test_lumber)
	_run("khai phá: Ổ quái phải hạ tinh anh", _test_nest)
	_run("khai phá: Mắt Ưng nhìn xuyên sương", _test_eagle_eye)
	_run("thu hoạch offline tối đa 12 giờ", _test_offline)
	_run("lưu/nạp hồ sơ qua JSON", _test_save_roundtrip)
	_run("thế giới: bot đánh quái, lên cấp", _test_world_bot)
	_run("thế giới: sương mù chặn lối vào hang", _test_gate)
	_run("thế giới: quái thường không đuổi vào hang", _test_arena_leash)
	_run("thế giới: cấp 5 hạ được Sói Chúa", _test_boss)
	# MVP M1 — trang bị (docs/03-mvp-spec.md, mục 3.11)
	_run("M1-1 sinh đồ: đúng số affix, không trùng", _test_item_generation)
	_run("M1-2 cường hoá: +1…+7 luôn thành công, +8 ≈ 80%, thất bại giữ nguyên", _test_enhance_rates)
	_run("M1-3 cường hoá thiếu nguyên liệu bị từ chối", _test_enhance_blocked)
	_run("M1-4 mặc/tháo cộng trừ đúng chỉ số", _test_equip)
	_run("M1-5 hiệu ứng bộ ở 2/4/6 món", _test_set_bonus)
	_run("M1-6 phân rã", _test_salvage)
	_run("M1-7 quái tinh anh luôn rơi Xanh dương/Tím", _test_elite_drop)
	_run("M1-8 túi đầy thì tự phân rã", _test_bag_full)
	_run("M1-9 chuyển đổi save v1 → v2, lưu/nạp đồ", _test_save_v2)
	_run("M1-10 bot 15 phút đầu nhặt được đồ Xanh lá trở lên", _test_early_loot)
	_run("M1-11 Sói Chúa hồi sinh sau 10 phút", _test_boss_respawn)
	_run("M1-12 cấp 5 + đồ rơi tự nhiên: boss vẫn là thử thách", _test_boss_with_loot)
	# MVP M2 — 20 Thiên phú (docs/03-mvp-spec.md, mục 4.9)
	_run("TL-B cân bằng: 20 Thiên phú đều hạ được boss, F và S chênh ≤ 25%", _test_talent_balance)
	_run("TL-C hiệu ứng chính: chỉ số, rơi đồ, tốc chạy, cường hoá", _test_effects_basic)
	_run("TL-C hiệu ứng chính: Hấp Huyết, Bàn Tay Vàng, Ngũ Hành", _test_effects_combat)
	_run("TL-C hiệu ứng chính: Thuần Thú Sư, Bầy Đàn Bóng Tối", _test_effects_summon)
	_run("TL-C hiệu ứng chính: Thiên Mệnh, Long Mạch, Đạo Tặc", _test_effects_rare)
	_run("TL-D kỹ năng L của 7 Thiên phú có kỹ năng", _test_talent_skills)
	_run("TL-E rương ẩn, thảo dược, bình máu", _test_chests_herbs_potions)
	_run("TL-F thời gian xây công trình", _test_buildings)
	_run("TL-G luyện cấp Thiên phú", _test_talent_leveling)
	_run("TL-H chuyển đổi save v2 → v3", _test_save_v3)
	# Đồ hoạ G1 (docs/07-do-hoa-ke-hoach.md)
	_run("AR-35 mọi quái, Thiên phú, ô đồ, đồ Cam đều có hình", _test_art_coverage)
	# MVP M3 — lớp, kỹ năng, chiến đấu (docs/03-mvp-spec.md, mục 5.10)
	_run("CL-T1 chỉ số theo lớp, INT, LUK, né tránh", _test_class_stats)
	_run("CL-T2 Thợ Săn bắn tên, vũ khí tên Cung", _test_hunter_shot)
	_run("CL-T3 8 kỹ năng: hồi chiêu, MP, xuyên, bẫy, Thiết Bích", _test_class_skills)
	_run("CL-T4 né tránh 30% (2.000 đòn)", _test_evasion)
	_run("CL-T5 chuyển đổi save v3 → v4", _test_save_v4)
	_run("CB-T1 chỉ số quái khớp tài liệu 06", _test_mob_formula)
	_run("CB-T3 né Hoàn hảo làm chậm 1 giây", _test_perfect_dodge)
	_run("CB-T4 Phá Thế tinh anh", _test_elite_poise)
	_run("CB-T5 Hú gọi, Sinh sôi, Nấm Con nổ", _test_elite_skills)
	_run("CB-T6 Mộc Tinh từ cấp 6, Dậm đất", _test_moc_tinh)
	_run("TP-T1 hiệu ứng Thiên phú mạnh dần theo cấp", _test_talent_levels)
	_run("TP-T2 Thuần Thú thu phục quái Ổ quái", _test_tame_nest)
	_run("TP-T3 Đạo Tặc cướp thuộc tính", _test_thief_steal)
	# Đợt C1 — hoàn chỉnh Chương 1 (docs/08-chuong-1-hoan-chinh.md, mục 3.4)
	_run("C1-T1 hướng đánh: quái sau lưng, tự xoay, Thợ Săn tự ngắm", _test_c1_facing)
	_run("C1-T2 save v6: tên, ngoại hình, nhiệm vụ, lưới 40 ô", _test_c1_save_v6)
	_run("C1-T6 lưới 40 ô: 3 map con, Lõi Sương khoá, Khứu Giác", _test_c1_grid40)

	print("")
	if _failed.is_empty():
		print("TẤT CẢ %d TEST QUA" % _total)
	else:
		print("%d/%d TEST HỎNG:" % [_failed.size(), _total])
		for f in _failed:
			print("  - " + f)
	quit(1 if not _failed.is_empty() else 0)


## Chạy một phần: godot --headless --path godot --script res://tests/run_tests.gd -- --only=TL-B
func _only() -> String:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--only="):
			return a.substr(7)
	return ""


func _run(test_name: String, fn: Callable) -> void:
	var only := _only()
	if only != "" and not test_name.contains(only):
		return
	_total += 1
	_current = test_name
	var before := _failed.size()
	fn.call()
	print(("  ok   " if _failed.size() == before else "  FAIL ") + test_name)


func _check(cond: bool, what: String) -> void:
	if not cond:
		_failed.append("%s — %s" % [_current, what])


func _profile(talent: String, seed_value := 7) -> Profile:
	var p := Profile.new()
	p.setup(talent, RngUtil.make(seed_value), 0.0)
	return p


func _ring(p: Profile, ring: int) -> Array:
	var origin := {"q": 0, "r": 0}
	return p.tiles.filter(func(t): return Explore.hex_distance(t, origin) == ring)


# ------------------------------------------------------------------ công thức


func _test_exp() -> void:
	_check(Formulas.exp_to_next(1) == 100, "EXP cấp 1 = 100")
	_check(Formulas.exp_to_next(10) == int(floor(100.0 * pow(10, 2.2) + 500.0)), "EXP cấp 10")
	for l in range(1, 100):
		if Formulas.exp_to_next(l + 1) <= Formulas.exp_to_next(l):
			_check(false, "EXP không tăng ở cấp %d" % l)
			return


func _test_damage() -> void:
	_check(Formulas.compute_damage(0, 10) == 0.0, "ATK 0")
	_check(is_equal_approx(Formulas.compute_damage(20, 20), 10.0), "20 vs 20 = 10")
	_check(is_equal_approx(Formulas.compute_damage(20, 20, 2, 0.3, 0.2), 10.0 * 2 * 1.3 * 1.2), "đủ hệ số")
	_check(Formulas.combo_exp_multiplier(0) == 1.0, "combo 0")
	_check(is_equal_approx(Formulas.combo_exp_multiplier(100), 1.2), "combo 100")
	_check(is_equal_approx(Formulas.combo_exp_multiplier(500), 1.2), "combo trần")


# ------------------------------------------------------------------ Lễ Thức Tỉnh


func _test_awakening_limits() -> void:
	var a := Awakening.new(RngUtil.make(1))
	_check(a.rerolls_left() == 3, "ban đầu 3 lần quay lại")
	a.roll()
	_check(a.rerolls_left() == 3, "sau lần đầu vẫn 3")
	a.roll()
	a.roll()
	a.roll()
	_check(a.rerolls_left() == 0 and not a.can_roll(), "hết lượt sau 4 lần")
	_check(a.roll().is_empty(), "lần thứ 5 không quay được")


func _test_awakening_pity() -> void:
	var a := Awakening.new(func() -> float: return 0.0)  # luôn ra hạng F đầu bảng
	for i in 3:
		_check(a.roll().rank == "F", "lần %d ra F" % (i + 1))
	_check(a.roll().rank == "B", "lần cuối được nâng lên B")


## TL-A: tỉ lệ theo hạng đúng bảng kịch bản (200.000 lần, lệch < 0,5 điểm %).
func _test_awakening_rates() -> void:
	var rng := RngUtil.make(42)
	var counts := {}
	var n := 200000
	for i in n:
		var t := Awakening.new(rng).roll()
		counts[t.rank] = counts.get(t.rank, 0) + 1
	_check(Talents.LIST.size() == 20, "đủ 20 Thiên phú")
	for r in Talents.RANK_ORDER:
		var got: float = counts.get(r, 0) / float(n)
		var want: float = Talents.RANK_WEIGHT[r] / 100.0
		_check(absf(got - want) < 0.005, "hạng %s: %.4f (cần %.4f)" % [r, got, want])


# ------------------------------------------------------------------ khai phá


func _test_tiles() -> void:
	var p := _profile("kiem-tam")
	# C1-21: vùng 1 = 40 ô (+ trại); Bìa Rừng (zone 1) giữ cơ cấu 10 ô như prototype.
	_check(p.tiles.size() == 41, "41 ô (40 + trại)")
	_check(Explore.owned_count(p.tiles) == 0, "chưa chiếm ô nào")
	var counts := {}
	for t in p.tiles:
		if Explore.zone_of(t) == 1 and t.event != "camp":
			counts[t.event] = counts.get(t.event, 0) + 1
	_check(counts.resource == 4 and counts.nest == 2 and counts.relic == 2, "4 gỗ, 2 ổ quái, 2 di tích")
	_check(counts.survivor == 1 and counts.wonder == 1, "1 người sống sót, 1 kỳ quan")


func _test_reveal() -> void:
	var p := _profile("kiem-tam")
	_check(Explore.reveal_blocker(p, _ring(p, 2)[0]) != "", "ô vòng 2 chưa dọn được")
	var ring1 := _ring(p, 1)
	_check(Explore.reveal_tile(p, ring1[0].id).ok, "dọn ô vòng 1")
	_check(p.torches == 2, "tốn 1 Đuốc")
	p.torches = 0
	_check(not Explore.reveal_tile(p, ring1[1].id).ok, "hết Đuốc thì không dọn được")


func _test_lumber() -> void:
	var p := _profile("kiem-tam")
	var res: Dictionary = _ring(p, 1).filter(func(t): return t.event == "resource")[0]
	Explore.reveal_tile(p, res.id)
	_check(not Explore.claim_tile(p, res.id).ok, "thiếu vàng")
	p.gold = 50
	_check(Explore.claim_tile(p, res.id).ok, "đủ vàng thì xây được")
	_check(is_equal_approx(p.gold, 20.0), "trừ 30 vàng")
	_check(Explore.production_per_minute(p).wood == 0.0, "đang xây thì chưa sản xuất (TL-S3)")
	Explore.tick_build_clock(p, 60.0)
	_check(Explore.production_per_minute(p).wood > 0.0, "xây xong thì có sản lượng gỗ")
	_check(is_equal_approx(Explore.explored_ratio(p.tiles), 1.0 / 40.0), "khai phá 1/40 ô")


func _test_nest() -> void:
	var p := _profile("kiem-tam")
	var nest: Dictionary = p.tiles.filter(func(t): return t.event == "nest")[0]
	nest.status = "revealed"
	_check(Explore.claim_tile(p, nest.id).start_nest, "phải gọi quái tinh anh")
	_check(nest.status == "revealed", "chưa chiếm ngay")
	_check(Explore.conquer_tile(p, nest.id) and nest.status == "owned", "hạ tinh anh thì chiếm được")


func _test_eagle_eye() -> void:
	var p := _profile("kiem-tam")
	var fog: Dictionary = p.tiles.filter(func(t): return t.status == "fog")[0]
	_check(not Explore.is_event_visible(p.tiles, fog, "kiem-tam"), "Thiên phú khác không thấy")
	_check(Explore.is_event_visible(p.tiles, fog, "mat-ung"), "Mắt Ưng thấy")


func _test_offline() -> void:
	var p := _profile("kiem-tam")
	var lumber: Dictionary = p.tiles.filter(func(t): return t.event == "resource")[0]
	lumber.status = "owned"
	p.buildings["lumber_%d" % lumber.id] = 0.0
	p.torches = 0
	var out := SaveSystem.apply_offline(p, 48.0 * 3600.0)
	_check(is_equal_approx(out.seconds, 12.0 * 3600.0), "giới hạn 12 giờ")
	_check(is_equal_approx(out.wood, 6.0 * 12.0 * 60.0), "gỗ = 6/phút × 12 giờ")
	_check(p.torches == Config.TORCH_MAX, "Đuốc hồi đầy")


func _test_save_roundtrip() -> void:
	var p := _profile("mat-ung")
	p.level = 4
	p.points.str = 3
	p.gold = 12.5
	p.tiles[3].status = "revealed"
	var back := Profile.new()
	_check(back.load_dict(JSON.parse_string(JSON.stringify(p.to_dict()))), "nạp được")
	_check(back.level == 4 and back.points.str == 3 and typeof(back.level) == TYPE_INT, "giữ cấp và điểm, đúng kiểu int")
	_check(is_equal_approx(back.gold, 12.5) and back.tiles[3].status == "revealed", "giữ vàng và ô đất")


# ------------------------------------------------------------------ thế giới


## Bot đơn giản: lao vào quái gần nhất (Thợ Săn: giữ khoảng cách 18–30 m), đánh liên tục,
## dùng 4 kỹ năng khi hồi xong, né khi quái sắp đánh trúng.
func _bot(w: GameWorld) -> Dictionary:
	var p := w.player
	var target = null
	var best := INF
	for e in w.enemies:
		var d: float = e.pos.distance_to(p.pos)
		if d < best:
			best = d
			target = e
	if target == null:
		return {"move": Vector2.RIGHT, "aim": p.pos + Vector2.RIGHT * 100.0, "attack": false, "skill": false, "talent": false, "dodge": false}
	# Đang đánh boss thì nhắm boss (quái thường lảng vảng không kéo bot đi xa).
	var b = w.boss()
	if b != null and best > 70.0:
		target = b
		best = b.pos.distance_to(p.pos)
	var threat := false
	for e in w.enemies:
		if e.state == "windup" and e.timer < 0.2 and e.pos.distance_to(p.pos) < 140.0:
			threat = true
	var dir: Vector2 = (target.pos - p.pos).sign()
	if w.is_hunter():
		var gap: float = best - target.radius
		var mv := Vector2.ZERO
		if gap < 180.0:
			mv = -dir
		elif gap > 300.0:
			mv = dir
		return {
			"move": mv, "aim": target.pos, "attack": true,
			"skill_1": gap < 380.0, "skill_2": gap < 500.0, "skill_3": gap < 120.0, "skill_4": true,
			"talent": true, "dodge": threat,
		}
	var close: bool = best < 60.0 + target.radius
	return {
		"move": Vector2.ZERO if close else dir,
		"aim": target.pos,
		"attack": true,
		"skill": best < 120.0,
		"skill_2": best < 200.0 and best > 90.0,
		"skill_3": best < 380.0,
		"skill_4": best < 160.0,
		"talent": true,
		"dodge": threat,
	}


## Bộ đồ chuẩn cấp 5 (vũ khí Xanh dương, áo + mũ Xanh lá) — như người chơi cày tới boss
## (M1-12 trung bình mặc 3 món). Công thức chỉ số quái giả định người chơi mặc đồ đúng vùng (03 mục 5.6).
func _standard_kit(w: GameWorld) -> void:
	var p = w.profile
	var rng := RngUtil.make(77)
	for pair in [["weapon", "blue"], ["armor", "green"], ["helm", "green"]]:
		var it := Items.new_item(p, 5, pair[1], rng, pair[0])
		Items.add_item(p, it)
		w.equip(int(it.id))
	w.player.hp = w.stats.max_hp


func _class_points(class_id: String) -> Dictionary:
	if class_id == "tho-san":
		return {"str": 0, "agi": 12, "int": 0, "vit": 8, "luk": 0}
	return {"str": 12, "agi": 0, "int": 0, "vit": 8, "luk": 0}


func _idle(w: GameWorld, move := Vector2.ZERO) -> Dictionary:
	return {"move": move, "aim": w.player.pos + Vector2.RIGHT, "attack": false, "skill": false, "talent": false, "dodge": false}


func _test_world_bot() -> void:
	var p := _profile("kiem-tam", 3)
	var w := GameWorld.new(p, RngUtil.make(11))
	w.player.pos.x = 700.0
	for i in 180 * 60:
		w.update(1.0 / 60.0, _bot(w))
	_check(p.kills > 10, "hạ hơn 10 quái (được %d)" % p.kills)
	_check(p.level > 1, "lên cấp")
	_check(is_finite(w.player.pos.x) and is_finite(w.player.hp), "không có NaN")


func _test_gate() -> void:
	var w := GameWorld.new(_profile("tay-nhanh", 3), RngUtil.make(1))
	w.enemies = []
	w.player.pos.x = GameWorld.GATE_X - 50.0
	for i in 120:
		w.update(1.0 / 60.0, _idle(w, Vector2.RIGHT))
	_check(w.player.pos.x <= GameWorld.GATE_X, "không qua được sương mù")
	_check(w.boss() == null, "boss chưa xuất hiện")


func _test_arena_leash() -> void:
	var p := _profile("tay-nhanh", 3)
	p.boss_defeated = true
	var w := GameWorld.new(p, RngUtil.make(2))
	w.enemies = []
	w.player.pos = GameWorld.ARENA_POS
	var wolf := w.spawn_enemy("wolf", 3, GameWorld.ARENA_POS - Vector2(GameWorld.ARENA_R + 40.0, 0))
	wolf.state = "chase"
	for i in 60:
		w.update(1.0 / 60.0, _idle(w))
	_check(wolf.state == "idle", "sói bỏ đuổi")


func _test_boss() -> void:
	var p := _profile("kiem-tam", 3)
	p.level = 5
	p.points = {"str": 12, "agi": 0, "vit": 8}
	for i in range(1, 7):
		p.tiles[i].status = "owned"
	var w := GameWorld.new(p, RngUtil.make(5))
	_standard_kit(w)
	w.enemies = []
	w.player.hp = w.stats.max_hp
	w.player.pos = GameWorld.ARENA_POS - Vector2(100, 0)
	var deaths := 0
	var seconds := 0.0
	while seconds < 600.0 and not p.boss_defeated:
		for ev in w.drain_events():
			if ev.type == "death":
				deaths += 1
		if w.boss() == null and w.player.dead_timer <= 0.0:
			w.player.pos = GameWorld.ARENA_POS - Vector2(100, 0)
		w.update(1.0 / 60.0, _bot(w))
		seconds += 1.0 / 60.0
	print("       (bot hạ boss sau %.1f giây, chết %d lần)" % [seconds, deaths])
	_check(p.boss_defeated, "hạ được boss")
	_check(deaths < 4, "không chết quá 3 lần")


# ------------------------------------------------------------------ MVP M1: trang bị


func _rich_profile() -> Profile:
	var p := _profile("kiem-tam", 9)
	p.gold = 1_000_000.0
	p.stones = 1_000_000
	return p


func _test_item_generation() -> void:
	var rng := RngUtil.make(21)
	for rarity in ItemData.RARITY_ORDER:
		for i in 1000:
			var item := Items.create(i, 1 + i % 10, rarity, rng)
			var stats := {}
			for af in item.affixes:
				stats[af.stat] = true
			if item.affixes.size() != int(ItemData.RARITIES[rarity].affixes) or stats.size() != item.affixes.size():
				_check(false, "%s: sai số affix hoặc trùng" % rarity)
				return
			if Items.base_value(item) <= 0.0:
				_check(false, "%s: chỉ số gốc ≤ 0" % rarity)
				return
	var low := Items.create(1, 1, "white", rng, "weapon")
	var high := Items.create(2, 10, "white", rng, "weapon")
	_check(Items.base_value(high) > Items.base_value(low), "đồ cấp cao mạnh hơn")


func _test_enhance_rates() -> void:
	var p := _rich_profile()
	var rng := RngUtil.make(3)
	var item := Items.new_item(p, 5, "blue", rng, "weapon")
	p.inventory.append(item)
	for i in 7:
		var res := Items.enhance(p, int(item.id), rng)
		_check(res.ok and res.success, "lên +%d phải thành công" % (i + 1))
	_check(int(item.plus) == 7, "đạt +7")
	var wins := 0
	var trials := 10000
	for i in trials:
		item.plus = 7
		p.gold = 1_000_000.0
		p.stones = 1_000_000
		var res := Items.enhance(p, int(item.id), rng)
		if not res.ok:
			_check(false, "lần thử %d bị từ chối: %s" % [i, res.message])
			return
		if res.success:
			wins += 1
		elif int(item.plus) != 7 or Items.find_item(p, int(item.id)).is_empty():
			_check(false, "thất bại làm mất đồ hoặc tụt cấp")
			return
	_check(absf(wins / float(trials) - 0.8) < 0.02, "tỉ lệ +8 ≈ 80%% (được %.3f)" % (wins / float(trials)))


func _test_enhance_blocked() -> void:
	var p := _profile("kiem-tam")
	var item := Items.new_item(p, 3, "green", RngUtil.make(1), "helm")
	p.inventory.append(item)
	p.gold = 0.0
	p.stones = 5
	var res := Items.enhance(p, int(item.id), RngUtil.make(1))
	_check(not res.ok, "thiếu vàng bị từ chối")
	_check(p.stones == 5 and int(item.plus) == 0, "không trừ gì")


func _test_equip() -> void:
	var p := _profile("kiem-tam")
	var w := GameWorld.new(p, RngUtil.make(4))
	var atk_before: float = w.stats.atk
	var a := Items.new_item(p, 5, "white", RngUtil.make(1), "weapon")
	var b := Items.new_item(p, 5, "white", RngUtil.make(2), "weapon")
	p.inventory.append_array([a, b])
	_check(w.equip(int(a.id)).ok, "mặc được")
	_check(is_equal_approx(w.stats.atk, atk_before + Items.base_value(a)), "cộng đúng tấn công")
	w.equip(int(b.id))
	_check(Items.find_in_bag(p, int(a.id)) >= 0 and int(p.equipment.weapon.id) == int(b.id), "đồ cũ về túi")
	_check(w.unequip("weapon").ok and is_equal_approx(w.stats.atk, atk_before), "tháo ra trả lại chỉ số")


func _test_set_bonus() -> void:
	var rng := RngUtil.make(5)
	var eq := {}
	var slots: Array = ItemData.SLOT_ORDER
	for n in range(1, 7):
		eq[slots[n - 1]] = Items.create(n, 5, "purple", rng, slots[n - 1], "frost_hunter")
		var bonus := Items.equipment_bonus(eq)
		_check(is_equal_approx(bonus.max_hp_pct, 0.08 if n >= 2 else 0.0), "HP%% ở %d món" % n)
		_check(is_equal_approx(bonus.atk_pct, 0.10 if n >= 4 else 0.0), "ATK%% ở %d món" % n)
		_check(is_equal_approx(bonus.spin_cd, 2.0 if n >= 6 else 0.0), "hồi chiêu ở %d món" % n)


func _test_salvage() -> void:
	var p := _profile("kiem-tam")
	var item := Items.new_item(p, 5, "purple", RngUtil.make(1), "ring")
	item.plus = 5
	p.inventory.append(item)
	_check(Items.salvage_value(item) == 5 + 2, "Tím +5 = 7 đá")
	p.equipment["ring"] = p.inventory.pop_back()
	_check(not Items.salvage(p, int(item.id)).ok, "đồ đang mặc không phân rã được")
	p.inventory.append(p.equipment["ring"])
	p.equipment.erase("ring")
	_check(Items.salvage(p, int(item.id)).ok and p.stones == 7 and p.inventory.is_empty(), "phân rã ra đá, mất món")


func _test_elite_drop() -> void:
	var p := _profile("kiem-tam")
	var w := GameWorld.new(p, RngUtil.make(6))
	for i in 200:
		w.enemies = []
		w.pickups = []
		var e := w.spawn_enemy("wolf", 3, Vector2(900, 400), {"elite": true})
		w._kill_enemy(e)
		var items := w.pickups.filter(func(pk): return pk.kind == "item")
		if items.size() != 1 or not (items[0].item.rarity in ["blue", "purple"]):
			_check(false, "lần %d không rơi đúng" % i)
			return


func _test_bag_full() -> void:
	var p := _profile("kiem-tam")
	var rng := RngUtil.make(7)
	for i in ItemData.BAG_SIZE:
		Items.add_item(p, Items.new_item(p, 1, "white", rng))
	var extra := Items.new_item(p, 1, "blue", rng)
	var res := Items.add_item(p, extra)
	_check(res.salvaged and p.inventory.size() == ItemData.BAG_SIZE, "món thứ 31 tự phân rã")
	_check(p.stones == 3, "nhận 3 đá từ đồ Xanh dương")


func _test_save_v2() -> void:
	var p := _profile("mat-ung")
	var v1 := p.to_dict()
	for k in ["inventory", "equipment", "stones", "next_item_id", "boss_respawn_at"]:
		v1.erase(k)
	v1.version = 1
	var old := Profile.new()
	_check(old.load_dict(JSON.parse_string(JSON.stringify(v1))), "nạp được save v1")
	_check(old.inventory.is_empty() and old.stones == 0 and old.next_item_id == 1, "v1 nhận giá trị mặc định")

	var rng := RngUtil.make(8)
	var a := Items.new_item(p, 4, "orange", rng, "", "", "wolf_fang")
	a.plus = 3
	p.equipment["weapon"] = a
	p.inventory.append(Items.new_item(p, 2, "purple", rng, "helm", "frost_hunter"))
	p.stones = 12
	var back := Profile.new()
	_check(back.load_dict(JSON.parse_string(JSON.stringify(p.to_dict()))), "nạp được save v2")
	_check(back.equipment.weapon.unique == "wolf_fang" and int(back.equipment.weapon.plus) == 3, "giữ đồ đang mặc")
	_check(back.inventory[0].set == "frost_hunter" and back.stones == 12 and back.next_item_id == p.next_item_id, "giữ túi đồ và đá")
	_check(typeof(back.equipment.weapon.level) == TYPE_INT, "ép lại kiểu int")


func _test_early_loot() -> void:
	var p := _profile("kiem-tam", 3)
	var w := GameWorld.new(p, RngUtil.make(13))
	w.player.pos.x = 700.0
	for i in 15 * 60 * 60:
		w.update(1.0 / 60.0, _bot(w))
	var good := p.inventory.filter(func(it): return it.rarity != "white")
	print("       (15 phút: %d quái, %d món, %d món Xanh lá trở lên, %d đá)" % [p.kills, p.inventory.size(), good.size(), p.stones])
	_check(good.size() >= 1, "có ít nhất 1 món Xanh lá trở lên")



func _test_boss_respawn() -> void:
	var p := _profile("kiem-tam", 3)
	var w := GameWorld.new(p, RngUtil.make(2))
	w.enemies = []
	var b := w.spawn_enemy("boss", 6, GameWorld.ARENA_POS, {"role": "boss"})
	w._kill_enemy(b)
	var victories := w.drain_events().filter(func(ev): return ev.type == "victory").size()
	_check(victories == 1 and not w.boss_available(), "lần đầu: thắng chương, boss chưa hồi")
	_check(w.pickups.filter(func(pk): return pk.kind == "item" and pk.item.rarity == "purple").size() >= 1, "rơi đồ Tím")
	p.play_seconds += GameWorld.BOSS_RESPAWN_SEC
	_check(w.boss_available(), "sau 10 phút boss hồi sinh")
	var b2 := w.spawn_enemy("boss", 6, GameWorld.ARENA_POS, {"role": "boss"})
	w._kill_enemy(b2)
	_check(w.drain_events().filter(func(ev): return ev.type == "victory").is_empty(), "hạ lại không hiện màn hình kết chương")


## Cộng điểm như người chơi (60% STR, 40% VIT) và mặc món tốt nhất cho từng ô.
func _gear_up(w: GameWorld) -> void:
	var p = w.profile
	while p.unspent > 0:
		w.allocate("str" if p.unspent % 5 < 3 else "vit")
	for slot in ItemData.SLOT_ORDER:
		var best_id := -1
		var best_power := w.combat_power()
		for it in p.inventory:
			if it.slot == slot and w.power_if_equipped(it) > best_power:
				best_power = w.power_if_equipped(it)
				best_id = int(it.id)
		if best_id >= 0:
			w.equip(best_id)


## Đánh boss tới khi thắng hoặc hết giờ; trả về [giây, số lần chết].
func _boss_fight(w: GameWorld, limit := 600.0) -> Array:
	w.drain_events()
	w.enemies = []
	w.player.hp = w.stats.max_hp
	w.player.pos = GameWorld.ARENA_POS - Vector2(100, 0)
	var deaths := 0
	var seconds := 0.0
	while seconds < limit and not w.profile.boss_defeated:
		for ev in w.drain_events():
			if ev.type == "death":
				deaths += 1
		if w.boss() == null and w.player.dead_timer <= 0.0:
			w.player.pos = GameWorld.ARENA_POS - Vector2(100, 0)
		w.update(1.0 / 60.0, _bot(w))
		seconds += 1.0 / 60.0
	return [seconds, deaths]


## 3.11-11: trang bị không được làm boss chương 1 thành quá dễ ở đúng cấp dự kiến (cấp 5).
func _test_boss_with_loot() -> void:
	var p := _profile("kiem-tam", 3)
	var w := GameWorld.new(p, RngUtil.make(13))
	w.player.pos.x = 700.0
	var farm := 0.0
	while p.level < Config.BOSS_LEVEL_REQ and farm < 1800.0:
		w.update(1.0 / 60.0, _bot(w))
		farm += 1.0 / 60.0
	w.player.dead_timer = 0.0
	_gear_up(w)
	for i in range(1, 7):
		p.tiles[i].status = "owned"  # bot không mở bản đồ; giả lập đã khai phá 6/10 ô
	var res := _boss_fight(w)
	print("       (cày %.0f giây tới cấp %d, mặc %d món, Lực chiến %d → boss %.1f giây, chết %d lần)" % [
		farm, p.level, p.equipment.size(), w.combat_power(), res[0], res[1]])
	_check(p.boss_defeated, "hạ được boss")
	_check(res[0] > 20.0, "boss không quá dễ (> 20 giây)")


# ------------------------------------------------------------------ MVP M2: Thiên phú


func _world(talent: String, seed_value := 5) -> GameWorld:
	var p := _profile(talent, 3)
	var w := GameWorld.new(p, RngUtil.make(seed_value))
	w.enemies = []
	return w


func _tick(w: GameWorld, input := {}, frames := 1) -> void:
	var base := _idle(w)
	base.merge(input, true)
	for i in frames:
		w.update(1.0 / 60.0, base)


## TL-B: nguyên tắc kịch bản — "chênh lệch sức mạnh giữa F và S ở cùng cấp không quá 25%".
## M3: chạy cho 2 lớp × 20 Thiên phú; F/S chênh ≤ 25% trong từng lớp, 2 lớp chênh nhau ≤ 25%.
func _test_talent_balance() -> void:
	var avg := func(arr: Array) -> float:
		var sum := 0.0
		for x in arr:
			sum += x
		return sum / arr.size()
	var class_avg := {}
	for class_id in Classes.ORDER:
		var by_rank := {}
		var all: Array = []
		var lines := PackedStringArray()
		for t in Talents.LIST:
			var p := _profile(t.id, 3)
			p.class_id = class_id
			p.level = 5
			p.points = _class_points(class_id)
			for i in range(1, 7):
				p.tiles[i].status = "owned"
			var w := GameWorld.new(p, RngUtil.make(5))
			_standard_kit(w)
			var res := _boss_fight(w)
			lines.append("%s %s %.0fs/%d" % [t.rank, t.name, res[0], res[1]])
			_check(p.boss_defeated, "%s · %s hạ được boss" % [class_id, t.name])
			if not by_rank.has(t.rank):
				by_rank[t.rank] = []
			by_rank[t.rank].append(res[0])
			all.append(res[0])
		print("       [%s] (" % class_id + " · ".join(lines) + ")")
		var f: float = avg.call(by_rank.F)
		var s_: float = avg.call(by_rank.S)
		class_avg[class_id] = avg.call(all)
		print("       [%s] F %.1f giây, S %.1f giây, chênh %.0f%%; trung bình %.1f giây" % [
			class_id, f, s_, absf(f - s_) / maxf(f, s_) * 100.0, class_avg[class_id]])
		_check(absf(f - s_) / maxf(f, s_) <= 0.25, "%s: F và S chênh ≤ 25%%" % class_id)
	var a: float = class_avg["kiem-khach"]
	var b: float = class_avg["tho-san"]
	print("       (2 lớp chênh %.0f%%)" % (absf(a - b) / maxf(a, b) * 100.0))
	_check(absf(a - b) / maxf(a, b) <= 0.25, "2 lớp chênh ≤ 25%")


func _test_effects_basic() -> void:
	# Thân Thể Cường Tráng +8% HP
	var base := _world("tay-nhanh")
	var tough := _world("than-the")
	_check(tough.stats.max_hp == int(round(100 * 1.08)), "Thân Thể Cường Tráng: HP %d" % tough.stats.max_hp)
	# May Mắn Nhỏ: 6% → 11%
	for pair in [["tay-nhanh", 0.06], ["may-man", 0.11]]:
		var w := _world(pair[0])
		var e := w.spawn_enemy("wolf", 1, Vector2(900, 400))
		var drops := 0
		var n := 20000
		for i in n:
			w.pickups = []
			w._drop_loot(e)
			drops += w.pickups.filter(func(pk): return pk.kind == "item").size()
		_check(absf(drops / float(n) - pair[1]) < 0.006, "%s rơi đồ %.3f" % [pair[0], drops / float(n)])
	# Chân Không Biết Mỏi: +10% khi không giao chiến
	var runner := _world("chan-khong")
	runner.time = 10.0
	_check(is_equal_approx(runner.move_speed(), base.move_speed() * 1.1), "Chân Không: +10% khi không giao chiến")
	runner._last_combat = 9.0
	_check(is_equal_approx(runner.move_speed(), base.move_speed()), "Chân Không: không cộng khi đang giao chiến")
	# Thợ Rèn Bẩm Sinh: +10% cường hoá
	var smith := _profile("tho-ren")
	var item := Items.create(1, 5, "blue", RngUtil.make(1), "weapon")
	item.plus = 7
	_check(is_equal_approx(Items.enhance_rate(item, smith), 0.9), "Thợ Rèn: +7 → +8 là 90%")
	_check(is_equal_approx(Items.enhance_rate(item, _profile("tay-nhanh")), 0.8), "Thiên phú khác: 80%")


func _test_effects_combat() -> void:
	# Hấp Huyết: hút máu, không uống được bình máu
	var w := _world("hap-huyet")
	w.player.hp = 50.0
	var e := w.spawn_enemy("boss", 6, w.player.pos + Vector2(30, 0), {"role": "boss"})
	w._hit_enemy(e, 1.0)
	_check(w.player.hp > 50.0, "Hấp Huyết hồi máu khi đánh")
	var potions: int = w.profile.potions
	w.drink_potion()
	_check(w.profile.potions == potions, "Hấp Huyết không dùng được bình máu")
	# Bàn Tay Vàng: 20% Tinh Kim
	var p := _profile("ban-tay-vang")
	var rng := RngUtil.make(4)
	var n := 3000
	for i in n:
		var it := Items.new_item(p, 1, "white", rng)
		p.inventory = [it]
		Items.salvage(p, int(it.id), rng)
	_check(absf(p.tinh_kim / float(n) - 0.2) < 0.03, "Bàn Tay Vàng %.3f" % (p.tinh_kim / float(n)))
	# Ngũ Hành: Kim khắc Mộc (Sói Sương), không khắc Thổ (Nấm Độc)
	var nh := _world("ngu-hanh")
	nh.profile.element = "kim"
	var wolf := nh.spawn_enemy("wolf", 1, Vector2(900, 400))
	var shroom := nh.spawn_enemy("mushroom", 1, Vector2(900, 500))
	_check(is_equal_approx(nh.element_bonus(wolf), 0.3) and nh.element_bonus(shroom) == 0.0, "khắc hệ +30%")
	_check(_world("kiem-tam").element_bonus(wolf) == 0.0, "Thiên phú khác không có khắc hệ")


func _test_effects_summon() -> void:
	# Thuần Thú Sư: tụt dưới 10% HP thì thu phục
	var w := _world("thuan-thu")
	var e := w.spawn_enemy("wolf", 6, w.player.pos + Vector2(30, 0))
	e.hp = 15.0
	w._hit_enemy(e, 1.0)
	_check(e.dead and w.profile.pets.size() == 1 and w.allies.size() == 1, "thu phục được thú cưng (hp %.1f/%.1f)" % [e.hp, e.max_hp])
	# Bầy Đàn Bóng Tối: 15% quái bị hạ đứng dậy
	var b := _world("bay-dan")
	var raised := 0
	var n := 4000
	for i in n:
		b.allies = []
		var m := b.spawn_enemy("wolf", 1, Vector2(900, 400))
		b._kill_enemy(m)
		raised += b.allies.size()
	_check(absf(raised / float(n) - 0.15) < 0.02, "lính bóng tối %.3f" % (raised / float(n)))


func _test_effects_rare() -> void:
	# Thiên Mệnh Khai Giới: 1 Đuốc dọn 3 ô
	var p := _profile("thien-menh")
	var res := Explore.reveal_tile(p, _ring(p, 1)[0].id)
	var revealed := p.tiles.filter(func(t): return t.status == "revealed").size()
	_check(res.ok and revealed == 3 and p.torches == 2, "Thiên Mệnh dọn %d ô, tốn 1 Đuốc" % revealed)
	_check(Explore.reveal_blocker(_profile("tay-nhanh"), _ring(p, 2)[0]) != "" , "đối chứng")
	# Long Mạch: Long Mạch Đàn +10% tấn công khi xây xong
	var w := _world("long-mach")
	var atk: float = w.stats.atk
	w.profile.gold = 500.0
	w.profile.wood = 500.0
	_check(w.build("dragon").ok, "xây được Long Mạch Đàn")
	_check(not _world("tay-nhanh").build("dragon").ok, "Thiên phú khác không xây được")
	_tick(w, {}, 60 * 121)
	_check(is_equal_approx(w.stats.atk, atk * 1.1), "Long Mạch +10% tấn công")
	# Đạo Tặc: hạ boss thì học Vồ Mồi, dùng L để lao tới
	var d := _world("dao-tac")
	var boss := d.spawn_enemy("boss", 6, GameWorld.ARENA_POS, {"role": "boss"})
	d._kill_enemy(boss)
	_check("pounce" in d.profile.copied_skills, "sao chép Vồ Mồi")
	var start := d.player.pos
	_tick(d, {"talent": true, "aim": start + Vector2(500, 0)})
	_check(d.player.pos.distance_to(start) > 250.0, "Vồ Mồi lao tới điểm ngắm")


## TL-D: mỗi Thiên phú có kỹ năng L dùng được và vào hồi chiêu đúng.
func _test_talent_skills() -> void:
	for t in Talents.LIST:
		if not Talents.has_skill(t):
			continue
		var w := _world(t.id)
		w.player.hp = 50.0
		if t.id == "trai-tim":
			w.profile.gold = 500.0
			w.profile.wood = 500.0
			w.build("temple")
		if t.id == "dao-tac":
			w.profile.copied_skills = ["pounce"]
		_tick(w, {"talent": true})
		_check(is_equal_approx(w.player.talent_cd, w.talent_skill_cd() - 1.0 / 60.0) or w.player.talent_cd > w.talent_skill_cd() - 0.05,
			"%s vào hồi chiêu" % t.name)
		match t.id:
			"kiem-tam":
				_check(w._super_slash, "Nhất Kiếm Đoạn sẵn sàng")
			"thao-duoc":
				_check(w.player.hp > 50.0, "Linh Dược hồi máu")
			"trai-tim":
				_check(Explore.is_built(w.profile, "temple"), "Hiệu Triệu xong ngay Đền")
			"ngu-hanh":
				_check(w.profile.element == "moc", "đổi hệ Kim → Mộc")
			"thoi-gian-ngung-dong":
				_check(w.freeze_timer > 2.9, "ngưng thời gian")
			"bay-dan":
				_check(w.allies.size() == 3, "gọi 3 lính bóng tối")
	# Thiên phú bị động: bấm L không lỗi, không vào hồi chiêu
	var passive := _world("tay-nhanh")
	_tick(passive, {"talent": true})
	_check(passive.player.talent_cd <= 0.0, "Thiên phú bị động không có hồi chiêu")


func _test_chests_herbs_potions() -> void:
	var w := _world("khuu-giac")
	var c: GameWorld.Chest = w.chests[0]
	c.pos = w.player.pos + Vector2(300, 0)
	_check(w.chest_visible(c), "Khứu Giác thấy rương trong 30 m")
	_check(not _world("tay-nhanh").chest_visible(c), "Thiên phú khác không thấy rương")
	c.pos = w.player.pos
	var stones: int = w.profile.stones
	_tick(w)
	_check(c.opened and w.profile.stones == stones + 2, "đi sát thì mở rương")
	# Thảo dược → bình máu; Nhà Thảo Dược hái ×2
	for pair in [["tay-nhanh", 1], ["thao-duoc", 2]]:
		var h := _world(pair[0])
		h.profile.potions = 0
		h.herbs[0].pos = h.player.pos
		_tick(h)
		var got: int = h.profile.herbs + h.profile.potions * GameWorld.HERBS_PER_POTION
		_check(got == pair[1], "%s hái được %d thảo dược" % [pair[0], got])
	# Bình máu hồi 35% (Nhà Thảo Dược 45,5%)
	for pair in [["tay-nhanh", 0.35], ["thao-duoc", 0.455]]:
		var q := _world(pair[0])
		q.player.hp = 1.0
		q.drink_potion()
		_check(is_equal_approx(q.player.hp, 1.0 + q.stats.max_hp * pair[1]), "%s bình máu hồi %.1f%%" % [pair[0], pair[1] * 100])


func _test_buildings() -> void:
	var p := _profile("trai-tim")
	p.gold = 500.0
	var lumber: Dictionary = p.tiles.filter(func(t): return t.event == "resource")[0]
	lumber.status = "revealed"
	Explore.claim_tile(p, lumber.id)
	var key := "lumber_%d" % lumber.id
	_check(is_equal_approx(Explore.remaining(p, key), 45.0), "Trái Tim Lãnh Chúa: 60 → 45 giây")
	Explore.tick_build_clock(p, 44.0)
	_check(not Explore.is_built(p, key), "chưa xong ở giây 44")
	Explore.tick_build_clock(p, 1.0)
	_check(Explore.is_built(p, key), "xong ở giây 45")
	# Đồng hồ xây chạy khi offline
	var q := _profile("tay-nhanh")
	q.gold = 500.0
	q.wood = 500.0
	Explore.build(q, "temple")
	q.last_seen = 0.0
	SaveSystem.apply_offline(q, 3600.0)
	_check(Explore.is_built(q, "temple"), "Đền xây xong trong lúc offline")


func _test_talent_leveling() -> void:
	var w := _world("tay-nhanh")
	var atk1: float = w.stats.atk
	w.profile.essence = 25
	_check(not w.level_talent().ok, "chưa có Đền thì không luyện được")
	w.profile.gold = 500.0
	w.profile.wood = 500.0
	w.build("temple")
	Explore.tick_build_clock(w.profile, 120.0)
	for i in 9:
		_check(w.level_talent().ok, "lên cấp %d" % (i + 2))
	_check(w.profile.talent_level == 10 and w.profile.essence == 0, "cấp 10 tốn đúng 25 Tinh Hoa")
	_check(not w.level_talent().ok, "cấp 10 là tối đa")
	_check(is_equal_approx(w.stats.atk, atk1 * 1.18), "cấp 10: +18% tấn công")
	_check(Talents.has_sub("tay-nhanh", 5, "combat", 1) and not Talents.has_sub("tay-nhanh", 4, "combat", 1), "hiệu ứng phụ mở ở cấp 5")
	_check(w.stats.crit > _world("tay-nhanh").stats.crit, "Chiến đấu cấp 5: +5% chí mạng")
	# Tinh Hoa rơi từ boss
	var b := _world("tay-nhanh")
	b._kill_enemy(b.spawn_enemy("boss", 6, GameWorld.ARENA_POS, {"role": "boss"}))
	_check(b.profile.essence == 3 and b.profile.tinh_kim == 1, "boss rơi 3 Tinh Hoa, 1 Tinh Kim")


func _test_save_v3() -> void:
	var p := _profile("thuan-thu")
	var lumber: Dictionary = p.tiles.filter(func(t): return t.event == "resource")[0]
	lumber.status = "owned"
	var v2 := p.to_dict()
	for k in ["talent_level", "essence", "tinh_kim", "potions", "herbs", "pets", "copied_skills", "element", "buildings", "build_clock"]:
		v2.erase(k)
	v2.version = 2
	var old := Profile.new()
	_check(old.load_dict(JSON.parse_string(JSON.stringify(v2))), "nạp được save v2")
	_check(old.talent_level == 1 and old.potions == 2 and old.pets.is_empty(), "v2 nhận mặc định")
	_check(Explore.production_per_minute(old).wood > 0.0, "Xưởng Gỗ cũ vẫn sản xuất")

	p.pets = [{"kind": "wolf", "level": 4}]
	p.copied_skills = ["pounce"]
	p.talent_level = 6
	p.buildings["temple"] = 99.0
	p.build_clock = 12.5
	var back := Profile.new()
	_check(back.load_dict(JSON.parse_string(JSON.stringify(p.to_dict()))), "nạp được save v3")
	_check(back.pets[0].kind == "wolf" and int(back.pets[0].level) == 4 and back.copied_skills == ["pounce"], "giữ thú cưng, kỹ năng sao chép")
	_check(back.talent_level == 6 and is_equal_approx(back.buildings.temple, 99.0) and is_equal_approx(back.build_clock, 12.5), "giữ cấp Thiên phú, công trình")
	var w := GameWorld.new(back, RngUtil.make(1))
	_check(w.allies.size() == 1, "thú cưng xuất hiện lại khi vào game")


func _test_art_coverage() -> void:
	_check(SpriteLib.has_sprite("hero-kiem-khach"), "có sprite Kiếm Khách")
	for kind in Monsters.DEFS:
		_check(SpriteLib.has_sprite(kind), "có sprite quái %s" % kind)
		var s: Dictionary = SpriteLib.data().sprites.get(kind, {})
		for anim in ["idle", "run", "attack", "hurt", "death"]:
			_check(s.get("anims", {}).has(anim), "%s có hoạt ảnh %s" % [kind, anim])
		_check(SpriteLib.texture(s.get("path", "")) != null, "nạp được ảnh %s" % kind)
	for t in Talents.LIST:
		_check(SpriteLib.talent_icon(t.id) != null, "có icon Thiên phú %s" % t.id)
	for slot in ItemData.SLOTS:
		_check(SpriteLib.icon("item-" + slot) != null, "có icon ô đồ %s" % slot)
	for u in ItemData.UNIQUES:
		_check(SpriteLib.icon("item-" + u) != null, "có icon đồ Cam %s" % u)
	for id in ["slash", "spin", "dodge", "potion"]:
		_check(SpriteLib.icon("skill-" + id) != null, "có icon kỹ năng %s" % id)
	for id in ["tile-grass-0", "tile-dirt", "tile-village", "tile-void", "hut", "stele", "chest", "herb", "fx-spore"]:
		_check(SpriteLib.has_env(id), "có hình môi trường %s" % id)


# ------------------------------------------------------------------ MVP M3 (docs/03-mvp-spec.md, mục 5.10)


func _m3_world(class_id: String, talent := "tay-nhanh", seed_value := 5) -> GameWorld:
	var p := _profile(talent, 3)
	p.class_id = class_id
	var w := GameWorld.new(p, RngUtil.make(seed_value))
	w.enemies = []
	return w


## Quái đứng yên (choáng dài) để kiểm đạn/kỹ năng.
func _dummy(w: GameWorld, kind: String, level: int, pos: Vector2) -> GameWorld.Enemy:
	var e := w.spawn_enemy(kind, level, pos)
	e.max_hp = 100000.0
	e.hp = e.max_hp
	e.state = "stunned"
	e.timer = 999.0
	return e


func _test_class_stats() -> void:
	var sw := _m3_world("kiem-khach")
	var hu := _m3_world("tho-san")
	_check(sw.stats.max_hp == 100 and hu.stats.max_hp == 90, "HP gốc 100 / 90")
	_check(is_zero_approx(sw.stats.evasion) and is_equal_approx(hu.stats.evasion, 0.05), "né gốc 0% / 5%")
	hu.profile.points.agi = 10
	hu._refresh_stats()
	sw.profile.points.agi = 10
	sw._refresh_stats()
	_check(is_equal_approx(hu.stats.atk, 30.0), "Thợ Săn: AGI +2 Tấn công (%.1f)" % hu.stats.atk)
	_check(is_equal_approx(sw.stats.atk, 10.0), "Kiếm Khách: AGI không cộng Tấn công")
	_check(is_equal_approx(hu.stats.evasion, 0.08), "AGI +0,3% né")
	sw.profile.points.int = 10
	sw.profile.points.luk = 10
	sw._refresh_stats()
	_check(int(sw.stats.max_mp) == 110 and is_equal_approx(sw.stats.skill_mul, 1.05), "INT: MP 110, kỹ năng ×1,05")
	_check(is_equal_approx(sw.stats.crit, 0.05 + 0.05 + 0.03), "LUK +0,3% chí mạng")
	hu.profile.points.agi = 100
	hu._refresh_stats()
	_check(is_equal_approx(hu.stats.evasion, 0.3), "né tránh trần 30%")


func _test_hunter_shot() -> void:
	var w := _m3_world("tho-san")
	var p := w.player
	p.pos = Vector2(800, 800)
	var near := _dummy(w, "wolf", 1, p.pos + Vector2(300, 0))
	var far := _dummy(w, "wolf", 1, p.pos + Vector2(340, 0))
	var behind := _dummy(w, "wolf", 1, p.pos + Vector2(-200, 0))
	w._shoot()
	_tick(w, {}, 60)
	_check(near.hp < near.max_hp, "tên trúng quái đầu tiên ở 30 m")
	_check(is_equal_approx(far.hp, far.max_hp), "tên không xuyên quái")
	_check(is_equal_approx(behind.hp, behind.max_hp), "không trúng quái sau lưng")
	var bow := Items.new_item(w.profile, 3, "white", RngUtil.make(4), "weapon")
	_check(Items.display_name(bow).begins_with("Cung"), "vũ khí Thợ Săn tên Cung: %s" % Items.display_name(bow))


func _test_class_skills() -> void:
	for class_id in Classes.ORDER:
		var w := _m3_world(class_id)
		for i in 4:
			var p := w.player
			p.mp = w.stats.max_mp
			var mp_before := p.mp
			_check(w.use_skill(i), "%s kỹ năng %d dùng được" % [class_id, i + 1])
			_check(is_equal_approx(p.skill_cds[i], w.skill_cd_of(i)), "%s kỹ năng %d đúng hồi chiêu" % [class_id, i + 1])
			_check(is_equal_approx(mp_before - p.mp, w.skill_mp(i)), "%s kỹ năng %d trừ MP" % [class_id, i + 1])
			_check(not w.use_skill(i), "%s kỹ năng %d đang hồi thì bị từ chối" % [class_id, i + 1])
			p.skill_cds[i] = 0.0
			p.mp = 0.0
			_check(not w.use_skill(i), "%s kỹ năng %d thiếu MP bị từ chối" % [class_id, i + 1])
			p.dash_time = 0.0
			w.shots = []
			w.traps = []
			w.rains = []
	# Kiếm Khí và Tên Xuyên Phá xuyên quái
	for pair in [["kiem-khach", 2], ["tho-san", 1]]:
		var w := _m3_world(pair[0])
		w.player.pos = Vector2(800, 800)
		w.player.mp = 999.0
		var a := _dummy(w, "wolf", 1, w.player.pos + Vector2(150, 0))
		var b := _dummy(w, "wolf", 1, w.player.pos + Vector2(250, 0))
		w.use_skill(pair[1])
		_tick(w, {}, 60)
		_check(a.hp < a.max_hp and b.hp < b.max_hp, "%s: đạn kỹ năng xuyên 2 quái" % pair[0])
	# Bẫy Gai trói
	var hw := _m3_world("tho-san")
	hw.player.pos = Vector2(800, 800)
	hw.player.mp = 999.0
	hw.use_skill(2)
	var wolf := hw.spawn_enemy("wolf", 1, hw.player.pos + Vector2(20, 0))
	wolf.max_hp = 100000.0
	wolf.hp = wolf.max_hp
	_tick(hw, {}, 1)
	_check(wolf.root_timer > 1.5 and wolf.hp < wolf.max_hp, "Bẫy Gai nổ và trói 2 giây")
	# Thiết Bích giảm 50%
	var gw := _m3_world("kiem-khach")
	gw.player.hp = 1000.0
	gw._damage_player(40.0, 1.0)
	var d1 := 1000.0 - gw.player.hp
	gw.player.hp = 1000.0
	gw.player.mp = 999.0
	gw.use_skill(3)
	gw._damage_player(40.0, 1.0)
	var d2 := 1000.0 - gw.player.hp
	_check(absf(d2 - d1 * 0.5) <= 1.0, "Thiết Bích: %d → %d" % [d1, d2])


func _test_evasion() -> void:
	var w := _m3_world("tho-san")
	w.profile.points.agi = 100
	w._refresh_stats()
	var dodged := 0
	var n := 2000
	for i in n:
		w.player.hp = 1.0e9
		w._damage_player(20.0, 1.0)
		if w.player.hp >= 1.0e9:
			dodged += 1
	var rate := dodged / float(n)
	print("       (né %.3f, mục tiêu 0,300)" % rate)
	_check(absf(rate - 0.3) < 0.03, "né tránh 30% ± 3 điểm")


func _test_save_v4() -> void:
	var p := _profile("dao-tac")
	var d := p.to_dict()
	d.version = 3
	d.erase("class_id")
	d.erase("stolen")
	d.points = {"str": 2, "agi": 1, "vit": 3}
	var old := Profile.new()
	_check(old.load_dict(JSON.parse_string(JSON.stringify(d))), "nạp được save v3")
	_check(old.class_id == "kiem-khach" and int(old.points.int) == 0 and int(old.points.luk) == 0 and old.stolen.is_empty(), "v3 → Kiếm Khách, INT/LUK = 0")
	p.class_id = "tho-san"
	p.stolen = ["agi", "str"]
	p.points.luk = 4
	var back := Profile.new()
	_check(back.load_dict(JSON.parse_string(JSON.stringify(p.to_dict()))), "nạp được save v4")
	_check(back.class_id == "tho-san" and back.stolen == ["agi", "str"] and int(back.points.luk) == 4, "v4 giữ lớp, điểm cướp, LUK")


func _test_mob_formula() -> void:
	var w1 := Formulas.mob_stats(1, "thuong", "nhanh")
	var w7 := Formulas.mob_stats(7, "thuong", "nhanh")
	var bs := Formulas.mob_stats(6, "boss", "boss", 5, Formulas.boss_hits(1))
	_check(int(w1.hp) == 18 and int(w1.atk) == 8, "Sói Sương cấp 1: %d HP / %d ATK" % [w1.hp, w1.atk])
	_check(int(w7.hp) == 188 and int(w7.atk) == 36, "Sói Sương cấp 7: %d HP / %d ATK" % [w7.hp, w7.atk])
	_check(int(bs.hp) == 4023 and int(bs.atk) == 43 and int(bs.def) == 24, "Sói Chúa: %d / %d / %d" % [bs.hp, bs.atk, bs.def])
	var w := _m3_world("kiem-khach")
	var boss := w.spawn_enemy("boss", GameWorld.BOSS_LEVEL, GameWorld.ARENA_POS, {"role": "boss"})
	_check(int(boss.max_hp) == 4023 and is_equal_approx(boss.max_poise, boss.max_hp / 6.0), "boss sinh ra đúng HP, Phá Thế = HP/6")
	_check(GameWorld.boss_exp() == 1545, "EXP boss 1.545")


func _test_perfect_dodge() -> void:
	var w := _m3_world("kiem-khach")
	w.player.hp = 100.0
	w.player.dodge_time = GameWorld.DODGE_TIME - 0.05
	w._damage_player(20.0, 1.0)
	_check(w.slowmo_timer > 0.9 and is_equal_approx(w.player.hp, 100.0), "chặn đòn trong 0,15 giây đầu → Hoàn hảo")
	var late := _m3_world("kiem-khach")
	late.player.dodge_time = GameWorld.DODGE_TIME - 0.25
	late._damage_player(20.0, 1.0)
	_check(late.slowmo_timer <= 0.0, "né muộn thì không Hoàn hảo")


func _test_elite_poise() -> void:
	var w := _m3_world("kiem-khach")
	var e := w.spawn_enemy("wolf", 5, Vector2(900, 400), {"elite": true})
	_check(e.name == "Sói Đầu Đàn", "tinh anh Sói Sương = Sói Đầu Đàn")
	_check(is_equal_approx(e.max_poise, e.max_hp * 0.3), "Phá Thế tinh anh = 30% HP")
	w._apply_damage(e, int(e.max_poise) + 1, false, true)
	_check(e.state == "stunned" and is_equal_approx(e.timer, GameWorld.ELITE_STUN) and e.broken, "phá thanh → choáng 3 giây, nhận +50%")


func _test_elite_skills() -> void:
	var w := _m3_world("kiem-khach")
	var leader := w.spawn_enemy("wolf", 5, w.player.pos + Vector2(200, 0), {"elite": true})
	w._elite_skill(leader, "howl")
	var summons := w.enemies.filter(func(m): return m.role == "summon")
	_check(summons.size() == 2 and summons[0].kind == "wolf", "Hú gọi: 2 Sói Sương")
	var w2 := _m3_world("kiem-khach")
	w2.player.pos = Vector2(900, 800)
	var mother := w2.spawn_enemy("mushroom", 5, w2.player.pos + Vector2(300, 0), {"elite": true})
	_check(mother.name == "Nấm Mẹ", "tinh anh Nấm Độc = Nấm Mẹ")
	w2._elite_skill(mother, "spawn")
	var kids := w2.enemies.filter(func(m): return m.kind == "nam-con")
	_check(kids.size() == 2 and kids[0].fuse > 0.0, "Sinh sôi: 2 Nấm Con có ngòi nổ")
	w2.enemies = [kids[0]]
	kids[0].pos = w2.player.pos + Vector2(20, 0)
	var hp0 := w2.player.hp
	for i in 300:
		_tick(w2)
		if kids[0].dead:
			break
	_check(kids[0].dead and w2.player.hp < hp0, "Nấm Con nổ trúng người đứng gần")


func _test_moc_tinh() -> void:
	var w := _m3_world("kiem-khach")
	var seen5 := 0
	var seen6 := 0
	for i in 2000:
		if w._pick_kind(5) == "moc-tinh":
			seen5 += 1
		if w._pick_kind(6) == "moc-tinh":
			seen6 += 1
	_check(seen5 == 0 and seen6 > 300, "Mộc Tinh chỉ từ cấp 6 (%d/2000)" % seen6)
	w.player.pos = Vector2(900, 800)
	var m := w.spawn_enemy("moc-tinh", 6, w.player.pos + Vector2(45, 0))
	m.state = "chase"
	var hp0 := w.player.hp
	for i in 240:
		_tick(w)
	_check(w.player.hp < hp0, "Dậm đất trúng người đứng trong 6 m")


func _test_talent_levels() -> void:
	var w := _world("than-the")
	w.profile.talent_level = 10
	w._refresh_stats()
	_check(int(w.stats.max_hp) == 130, "Thân Thể Lv10: +12%% + 18%% = 130 HP (%d)" % w.stats.max_hp)
	var f := _world("thoi-gian-ngung-dong")
	f.profile.talent_level = 10
	f._use_talent()
	_check(is_equal_approx(f.freeze_timer, 4.5 + 1.0), "Ngưng Đọng Lv10: 4,5 giây + 1 (hiệu ứng phụ)")
	_check(Talents.main_effect_text("than-the", 10) == "+12% HP tối đa", "bảng Thiên phú hiện giá trị Lv10")


func _test_tame_nest() -> void:
	var w := _world("thuan-thu")
	var e := w.spawn_enemy("wolf", 2, w.player.pos + Vector2(30, 0), {"role": "nestMinion"})
	e.max_hp = 1000.0
	e.hp = 105.0
	w._hit_enemy(e, 1.0)
	_check(w.profile.pets.size() == 1, "thu phục được quái Ổ quái")


func _test_thief_steal() -> void:
	var w := _world("dao-tac")
	var p = w.profile
	p.level = 5
	w._refresh_stats()
	var boss := w.spawn_enemy("boss", GameWorld.BOSS_LEVEL, GameWorld.ARENA_POS, {"role": "boss"})
	w._kill_enemy(boss)
	_check(p.stolen.size() == 3, "boss cho 3 điểm (%d)" % p.stolen.size())
	var first: String = p.stolen[0]
	for i in 3:
		var g := w.spawn_enemy("wolf", 5, Vector2(900, 400), {"elite": true, "role": "nestGuard"})
		w._kill_enemy(g)
	_check(p.stolen.size() == p.level, "giới hạn 1 × cấp (%d/%d)" % [p.stolen.size(), p.level])
	var before: Array = p.stolen.duplicate()
	var low := w.spawn_enemy("wolf", 1, Vector2(900, 400), {"elite": true, "role": "nestGuard"})
	p.level = 7
	w._kill_enemy(low)
	_check(p.stolen == before, "quái thấp hơn 6 cấp không cướp được")
	p.unspent = 0
	w.respec()
	_check(p.stolen == before, "tẩy điểm không mất điểm cướp")
	var total := Stats.total_points(p.points, p.stolen)
	var sum := 0
	for k in total:
		sum += int(total[k])
	_check(sum == p.stolen.size() and first != "", "điểm cướp cộng vào chỉ số")


# ------------------------------------------------------------------ Đợt C1 (docs/08-chuong-1-hoan-chinh.md, mục 3.4)


## Spec_Notes N5: quái đứng sau lưng — đứng yên bấm đánh vẫn trúng (tự xoay mặt).
func _test_c1_facing() -> void:
	var w := _m3_world("kiem-khach")
	w.player.pos = Vector2(900, 800)
	w.player.facing = 0.0
	var behind := _dummy(w, "wolf", 1, w.player.pos + Vector2(-55, 0))
	# input aim vẫn chỉ sang phải (chơi bàn phím, hướng cũ) — đòn đánh phải tự quay lại
	_tick(w, {"aim": w.player.pos + Vector2(100, 0), "attack": true}, 2)
	_check(behind.hp < behind.max_hp, "Kiếm Khách chém trúng quái sau lưng khi đứng yên")
	_check(cos(w.player.facing) < 0.0, "nhân vật quay mặt về quái")
	var far := _m3_world("kiem-khach")
	far.player.pos = Vector2(900, 800)
	var out := _dummy(far, "wolf", 1, far.player.pos + Vector2(-300, 0))
	_tick(far, {"aim": far.player.pos + Vector2(100, 0), "attack": true}, 2)
	_check(is_equal_approx(out.hp, out.max_hp), "quái ngoài tầm chém thì không tự xoay")
	var h := _m3_world("tho-san")
	h.player.pos = Vector2(900, 800)
	var target := _dummy(h, "wolf", 1, h.player.pos + Vector2(-250, 40))
	_tick(h, {"aim": h.player.pos + Vector2(100, 0), "attack": true}, 60)
	_check(target.hp < target.max_hp, "Thợ Săn tự ngắm quái phía sau")


func _test_c1_save_v6() -> void:
	var p := _profile("kiem-tam")
	var d := p.to_dict()
	d.version = 5
	for k in ["name", "look", "quest_step", "quest_progress", "seen_dialogs", "rare_boss_at", "evo_essence", "herb_timer", "merchant"]:
		d.erase(k)
	# save cũ chỉ có lưới 10 ô
	d.tiles = d.tiles.slice(0, 11)
	for t in d.tiles:
		t.erase("zone")
	var old := Profile.new()
	_check(old.load_dict(JSON.parse_string(JSON.stringify(d))), "nạp được save v5")
	_check(old.name == "Khai Giới Giả" and old.look.gender == "nam", "v5 → tên, ngoại hình mặc định")
	_check(old.quest_step == 5, "v5 chưa hạ boss → nhiệm vụ bước 5")
	_check(old.tiles.size() == 41 and Explore.zone_of(old.tiles[40]) == 3, "lưới 10 ô được bù thành 40 ô")
	p.name = "Lâm Phong"
	p.look = {"gender": "nu", "skin": 2, "hair_style": "bui", "hair_color": 4}
	p.quest_step = 7
	p.seen_dialogs = ["intro"]
	var back := Profile.new()
	_check(back.load_dict(JSON.parse_string(JSON.stringify(p.to_dict()))), "nạp được save v6")
	_check(back.name == "Lâm Phong" and back.look.hair_style == "bui" and int(back.look.hair_color) == 4, "giữ tên, ngoại hình")
	_check(back.quest_step == 7 and back.seen_dialogs == ["intro"], "giữ nhiệm vụ, thoại đã xem")
	_check(Looks.clean_name("  Lâm   Phong ") == "Lâm Phong" and Looks.clean_name("A") == "", "chuẩn hoá tên")


func _test_c1_grid40() -> void:
	var p := _profile("kiem-tam")
	var by_zone := {1: 0, 2: 0, 3: 0}
	var ev := {}
	var keys := {}
	for t in p.tiles:
		keys["%d,%d" % [t.q, t.r]] = true
		if t.event == "camp":
			continue
		by_zone[Explore.zone_of(t)] += 1
		ev[t.event] = ev.get(t.event, 0) + 1
	_check(by_zone[1] == 10 and by_zone[2] == 15 and by_zone[3] == 15, "10 + 15 + 15 ô")
	_check(keys.size() == 41, "không trùng toạ độ")
	_check(ev.resource == 16 and ev.nest == 11 and ev.relic == 5 and ev.survivor == 4 and ev.merchant == 3 and ev.wonder == 1, "cơ cấu sự kiện bảng 3.2: %s" % str(ev))
	var z3: Dictionary = p.tiles.filter(func(t): return Explore.zone_of(t) == 3)[0]
	for t in p.tiles:
		t.status = "owned" if Explore.zone_of(t) != 3 else "fog"
	p.torches = 5
	_check(Explore.reveal_blocker(p, z3).contains("Lõi Sương"), "Lõi Sương khoá khi chưa hạ boss")
	p.boss_defeated = true
	var adj: Array = p.tiles.filter(func(t): return Explore.zone_of(t) == 3 and Explore.distance_to_owned(p.tiles, t) == 1)
	_check(not adj.is_empty() and Explore.reveal_blocker(p, adj[0]) == "", "hạ boss rồi thì dọn được ô Lõi Sương kề lãnh địa")
	var scent := _profile("khuu-giac")
	var relics := scent.tiles.filter(func(t): return t.event == "relic").size()
	_check(relics == 8, "Khứu Giác Kho Báu: Di tích 8/40 = 20%% (%d)" % relics)
	var w := _world("kiem-tam")
	w.profile.level = 5
	for i in range(1, 7):
		w.profile.tiles[i].status = "owned"
	_check(w.boss_unlocked(), "cấp 5 + 6 ô là mở hang")
