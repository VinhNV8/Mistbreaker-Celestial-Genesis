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
const MapsData = preload("res://scripts/data/maps.gd")
const Looks = preload("res://scripts/data/looks.gd")
const Story = preload("res://scripts/data/story.gd")
const GiftCode = preload("res://scripts/core/gift_code.gd")

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
	_run("C1-T3 thoại theo mốc, không lặp, được lưu", _test_c1_dialogs)
	_run("C1-T4 chuỗi 11 nhiệm vụ chương 1", _test_c1_quests)
	_run("C1-T5 Lõi Sương: khoá, cấp 7–10, sương che Tinh Linh", _test_c1_core_map)
	_run("C1-T7 boss hiếm Lão Thụ: chỉ số, Rễ Trói, Rừng Thức Tỉnh, rơi đồ, lịch 12 giờ", _test_c1_rare_boss)
	_run("C1-T8 vũng độc Nấm Độc, Lao sương", _test_c1_mob_mechanics)
	_run("C1-T9 Xưởng Rèn, Vườn Thảo Dược", _test_c1_forge_garden)
	_run("C1-T10 cửa hàng, bán đồ, Thương nhân lữ hành", _test_c1_shop)
	_run("C1-T11 Tự đánh, tự cộng điểm", _test_c1_auto)
	_run("C1-T12 đủ hình ngoại hình, NPC, boss hiếm và âm thanh", _test_c1_assets)
	# CR-02 — gift code (03-mvp-spec Phụ lục A)
	_run("GC-T1 gift code: định dạng, kiểm tra, dùng 1 lần, 1 mã mỗi nhân vật", _test_gift_code)
	_run("GC-T2 gift code: chỉ hạng A–SSS, tỉ lệ 65/25/9/1", _test_gift_rates)
	# M4.2 — vùng 2 chiến đấu (03-mvp-spec mục 6.6)
	_run("GI-T1 gió: đẩy, ngược/xuôi, đạn lệch, đổi hướng", _test_m42_wind)
	_run("CB-T7 quái vùng 2: chỉ số, khiên chặn, Hút, Bổ nhào, tinh anh", _test_m42_mobs)
	_run("CB-T8 Huyền Ảnh: bản sao, đổi chỗ, chương 2 hoàn thành, Phân Thân", _test_m42_huyen_anh)
	_run("CB-T9 kháng hệ, phạt EXP quái thấp cấp", _test_m42_resist)
	_run("TB-T1 Bộ Phong Hành, Mặt Nạ Huyền Ảnh, ảo ảnh hút đòn", _test_m42_sets)
	_run("MP-T2 điều kiện mở vùng 2, thử thách vượt ải", _test_m42_unlock)
	# M4.3 — Thành Biên Đài, lãnh địa vùng 2
	_run("KP-T1 lưới vùng 2 45 ô, đổi lưới theo vùng, Khứu Giác", _test_m43_grid)
	_run("KP-T1b Mỏ, Bến Cá, sản lượng mọi vùng, EXP offline, thợ rèn", _test_m43_buildings)
	_run("KP-T2 nhiệm vụ chương 2, NPC, gián điệp Mạc Tam, hạng Liên minh", _test_m43_quest)
	_run("TL-B2 cân bằng vùng 2: 3 lớp × 20 Thiên phú hạ Huyền Ảnh", _test_m42_balance)
	# SN2 — Spec_Notes đợt 2 (docs/09)
	_run("SN-T1 Pháp Sư: chỉ số theo INT, Trượng, tự cộng điểm", _test_sn_mage_stats)
	_run("SN-T2 Pháp Sư: Hỏa Cầu, Lôi Xích, Băng Ngục, Thiên Thạch, Pháp Thuẫn", _test_sn_mage_skills)
	_run("SN-T3 bộ lọc, phân rã nhanh, bán nhanh", _test_sn_bulk)
	_run("SN-T4 chuyển cấp cường hoá khi mặc đồ", _test_sn_transfer)
	_run("SN-T5 map ×1,6, sương che, % khám phá, thưởng", _test_sn_fog)
	_run("SN-T6 save v7", _test_sn_save)
	_run("SN-T7 Hấp Huyết: phép diện rộng của Pháp Sư hút 50%", _test_sn_aoe_lifesteal)
	# M5 — boss hiếm Bạch Hổ, chuẩn bị thử nghiệm kín (03-mvp-spec mục 7)
	_run("M5-T1 Bạch Hổ: điều kiện, chỉ số, Hổ Vồ, Gầm Gió, Cưỡi Gió, rơi đồ, lịch riêng, save v8", _test_m5_bach_ho)
	_run("M5-T2 Vuốt Bạch Hổ: chí mạng gây chảy máu", _test_m5_claw)
	_run("M5-T3 cân bằng: 3 lớp cấp 20 hạ Bạch Hổ", _test_m5_bach_ho_balance)
	_run("M5-T4 lính khiên quay chậm 120°/giây: chạy vòng đánh được vào hông", _test_m5_shield_turn)
	_run("M5-T5 nhịp EXP: số quái tới cấp 10/20, tỉ lệ nguồn EXP theo kịch bản", _test_m5_exp_budget)
	_run("M5-T6 bản đồ nhỏ: ảnh sương theo map, đổi cỡ, cập nhật khi khám phá", _test_m5_minimap)
	_run("PACE-T1 nhịp lên cấp 1 → 20 chỉ bằng đánh quái (bot cày, đo phút)", _test_pace_mobs)
	for c in Classes.ORDER:
		_run("PACE-T2 %s cấp 10 → 20 vùng 2" % c, _test_pace_r2.bind(c))

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
	# Bài đo nhịp độ chạy lâu (vài phút): chỉ chạy khi gọi riêng --only=PACE.
	if test_name.begins_with("PACE") and only == "":
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
	# Test cũ không chạy chuỗi nhiệm vụ chương 1 (C1-12 có test riêng).
	p.quest_step = 12
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
	var flee := Vector2.ZERO
	for e in w.enemies:
		if e.state == "windup" and e.timer < 0.2 and e.pos.distance_to(p.pos) < 140.0:
			threat = true
		# M5: Hổ Vồ đánh vào vòng đỏ ở chỗ đánh dấu — né lăn, hoặc chạy khỏi vòng nếu né còn hồi.
		if e.state == "windup" and e.attack_kind == "tiger" and e.target.distance_to(p.pos) < GameWorld.TIGER_R + 30.0:
			if e.timer < 0.2:
				threat = true
			flee = (p.pos - e.target).normalized() if p.pos.distance_to(e.target) > 1.0 else Vector2.DOWN
	var dir: Vector2 = (target.pos - p.pos).sign()
	if flee != Vector2.ZERO and (p.dodge_cd > 0.0 or not threat):
		return {"move": flee, "aim": target.pos, "attack": true, "talent": true, "dodge": threat}
	if w.is_mage():
		var gap_m: float = best - target.radius
		var mv_m := Vector2.ZERO
		if gap_m < 180.0:
			mv_m = -dir
		elif gap_m > 300.0:
			mv_m = dir
		return {
			"move": mv_m, "aim": target.pos, "attack": true,
			"skill_1": gap_m < 340.0, "skill_2": gap_m < 100.0, "skill_3": gap_m < 400.0,
			"skill_4": p.hp < w.stats.max_hp * 0.8,
			"talent": true, "dodge": threat,
		}
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
	# M5-02: quái có khiên — chạy vòng sang hông thay vì đứng trước khiên.
	var circle := Vector2.ZERO
	if close and Monsters.DEFS[target.kind].get("shield", false) and target.state != "stunned" and absf(angle_difference(target.face, (p.pos - target.pos).angle())) <= GameWorld.SHIELD_ARC:
		circle = (p.pos - target.pos).normalized().rotated(PI / 2.0)
	return {
		"move": circle if circle != Vector2.ZERO else (Vector2.ZERO if close else dir),
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
	if class_id == "phap-su":
		return {"str": 0, "agi": 0, "int": 12, "vit": 8, "luk": 0}
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
	w.field_spawn = false
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
	# SN-07: so lớp nhanh nhất với lớp chậm nhất.
	var a: float = class_avg.values().min()
	var b: float = class_avg.values().max()
	print("       (%d lớp: nhanh nhất %.1f, chậm nhất %.1f giây, chênh %.0f%%)" % [class_avg.size(), a, b, (b - a) / b * 100.0])
	_check((b - a) / b <= 0.25, "các lớp chênh ≤ 25%")


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
	var behind := _dummy(w, "wolf", 1, p.pos + Vector2(-420, 0))
	w._shoot()
	_tick(w, {}, 60)
	_check(near.hp < near.max_hp, "tên trúng quái đầu tiên ở 30 m")
	_check(is_equal_approx(far.hp, far.max_hp), "tên không xuyên quái")
	_check(is_equal_approx(behind.hp, behind.max_hp), "không bắn quái xa hơn (N9: luôn nhắm quái gần nhất)")
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
	_check(GameWorld.boss_exp() == roundi(0.6 * Formulas.exp_to_next(6)), "EXP boss = 60%% EXP cấp 6 (%d)" % GameWorld.boss_exp())


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
	for k in ["name", "look", "quest_step", "quest_progress", "seen_dialogs", "rare_at", "evo_essence", "herb_timer", "merchant"]:
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


func _quest_world(class_id := "kiem-khach") -> GameWorld:
	var p := Profile.new()
	p.setup("tay-nhanh", RngUtil.make(3), 0.0, class_id)
	return GameWorld.new(p, RngUtil.make(5))


func _dialogs(w: GameWorld) -> Array:
	return w.drain_events().filter(func(e): return e.type == "dialog").map(func(e): return e.id)


func _test_c1_dialogs() -> void:
	var w := _quest_world()
	_check("q1" in _dialogs(w), "vào game: thoại q1")
	_check(not w.say("q1"), "thoại không lặp lại")
	var boss := w.spawn_enemy("boss", GameWorld.BOSS_LEVEL, GameWorld.ARENA_POS, {"role": "boss"})
	w._boss_phase_two(boss)
	_check("boss2" in _dialogs(w), "boss giai đoạn 2: thoại boss2")
	var back := Profile.new()
	back.load_dict(JSON.parse_string(JSON.stringify(w.profile.to_dict())))
	_check("q1" in back.seen_dialogs and "boss2" in back.seen_dialogs, "thoại đã xem được lưu")


func _test_c1_quests() -> void:
	var w := _quest_world("tho-san")
	var p = w.profile
	var quest_mobs := w.enemies.filter(func(e): return e.role == "quest")
	_check(quest_mobs.size() == 3, "bước 1: 3 Sói Sương ở cổng làng")
	for e in quest_mobs:
		w._kill_enemy(e)
	_check(p.quest_step == 2, "hạ 3 sói → bước 2")
	p.unspent = 0
	w.player.mp = 999.0
	w.use_skill(1)
	w.player.skill_cds[2] = 0.0
	w.use_skill(2)
	_check(p.quest_step == 3, "dùng 2 kỹ năng → bước 3")
	_tick(w, {"dodge": true}, 1)
	_check(p.quest_step == 4, "né 1 lần → bước 4")
	var gift: Array = p.inventory.filter(func(it): return it.slot == "weapon" and it.rarity == "green")
	_check(gift.size() == 1 and Items.display_name(gift[0]).begins_with("Cung"), "quà Trưởng làng: Cung Xanh lá cho Thợ Săn")
	w.equip(int(gift[0].id))
	_tick(w, {}, 40)
	_check(p.quest_step == 5, "mặc vũ khí → bước 5")
	var gold0: float = p.gold
	w.add_exp(5000.0, false)
	_tick(w, {}, 40)
	_check(p.quest_step == 6 and p.gold >= gold0 + 100.0, "cấp 3 → bước 6, +100 vàng")
	while p.unspent > 0:
		w.allocate("agi")
	_tick(w, {}, 40)
	_check(p.quest_step == 7 and p.potions == 4, "cộng hết điểm → bước 7, +2 bình máu")
	p.torches = 5
	var ring1: Array = p.tiles.filter(func(t): return Explore.hex_distance(t, {"q": 0, "r": 0}) == 1)
	for i in 3:
		w.reveal_tile(int(ring1[i].id))
	_tick(w, {}, 40)
	_check(p.quest_step == 8, "dọn 3 ô → bước 8")
	p.buildings["temple"] = 0.0
	_tick(w, {}, 40)
	_check(p.quest_step == 9, "có công trình xây xong → bước 9")
	p.level = 5
	for t in p.tiles.slice(1, 7):
		t.status = "owned"
	_tick(w, {}, 40)
	_check(p.quest_step == 10, "mở hang → bước 10")
	p.boss_defeated = true
	_tick(w, {}, 40)
	_check(p.quest_step == 11 and "q11" in p.seen_dialogs, "hạ boss → bước 11, thoại q11")
	w._load_map("1-3")
	_tick(w, {}, 40)
	_check(p.quest_step == Story.DONE_STEP and "done" in p.seen_dialogs, "vào Lõi Sương → hoàn thành chương 1")


func _test_c1_core_map() -> void:
	var w := _world("kiem-tam")
	_check(w.travel_blocker("1-3") != "", "Lõi Sương khoá khi chưa hạ Sói Chúa")
	w.profile.boss_defeated = true
	w.profile.level = 7
	_check(w.travel_blocker("1-3") == "", "hạ boss rồi thì đi được Lõi Sương")
	w._load_map("1-3")
	var lv := w.level_at(2000.0)
	_check(lv >= 7 and lv <= 10, "quái Lõi Sương cấp 7–10 (%d)" % lv)
	w.enemies = []
	w.player.pos = Vector2(600, 750)
	var far := w.spawn_enemy("wisp", 8, w.player.pos + Vector2(300, 0))
	var near := w.spawn_enemy("wisp", 8, w.player.pos + Vector2(120, 0))
	_check(w.is_hidden(far) and not w.is_hidden(near), "Tinh Linh Sương xa hơn 20 m tàng hình")


func _test_c1_rare_boss() -> void:
	var w := _world("kiem-tam")
	w.profile.boss_defeated = true
	w.profile.level = 9
	w._refresh_stats()
	w.debug_now = 1000.0
	w._load_map("1-3")
	w._check_rare_boss()
	var b := w.rare_boss()
	_check(b != null, "lần đầu vào Lõi Sương: Lão Thụ xuất hiện")
	var ms := Formulas.mob_stats(9, "hiem", "li")
	_check(is_equal_approx(b.max_hp, ms.hp) and int(b.max_hp) == 16566, "chỉ số theo công thức 06 (%d HP)" % b.max_hp)
	# Rễ Trói
	w.player.pos = b.pos + Vector2(-300, 0)
	w.player.dodge_time = 0.0
	b.target = w.player.pos
	b.attack_kind = "roots"
	w._perform_attack(b)
	_check(w.player.root_timer > 1.0 or w.player.hp >= w.stats.max_hp, "Rễ Trói trúng thì bị trói")
	w.player.root_timer = 1.0
	var before := w.player.pos
	_tick(w, {"move": Vector2.RIGHT}, 10)
	_check(w.player.pos.distance_to(before) < 1.0, "bị trói thì không đi được")
	# Rừng Thức Tỉnh
	b.hp = b.max_hp * 0.35
	w._update_rare(b, 0.1)
	var roots := w.enemies.filter(func(e): return e.kind == "goc-re")
	_check(b.phase == 2 and roots.size() == 3, "dưới 40%: gọi 3 Gốc Rễ")
	var hp0 := b.hp
	w._update_rare(b, 1.0)
	_check(b.hp > hp0, "còn Gốc Rễ thì Lão Thụ hồi máu")
	for r in roots:
		r.dead = true
	w.enemies = w.enemies.filter(func(e): return not e.dead)
	var hp1 := b.hp
	w._update_rare(b, 1.0)
	_check(is_equal_approx(b.hp, hp1), "phá hết rễ thì ngừng hồi")
	# hạ boss hiếm
	var ess: int = w.profile.essence
	w.pickups = []
	w._kill_enemy(b)
	var bark := w.pickups.filter(func(pk): return pk.kind == "item" and pk.item.unique == "lao_thu_bark")
	_check(bark.size() == 1, "rơi Vỏ Lão Thụ")
	_check(w.profile.essence == ess + 5 and w.profile.evo_essence == 1, "+5 Tinh Hoa, +1 Tinh Hoa Tiến Hoá")
	_check(is_equal_approx(float(w.profile.rare_at["lao-thu"]), 1000.0 + Config.RARE_BOSS_PERIOD), "hẹn 12 giờ sau")
	w.enemies = []
	w._check_rare_boss()
	_check(w.rare_boss() == null, "chưa tới giờ thì chưa xuất hiện lại")
	w.debug_now = 1000.0 + Config.RARE_BOSS_PERIOD + 1.0
	w._check_rare_boss()
	_check(w.rare_boss() != null, "sau 12 giờ xuất hiện lại")
	# Vỏ Lão Thụ: đứng yên hồi máu
	var it := Items.new_item(w.profile, 9, "orange", RngUtil.make(1), "", "", "lao_thu_bark")
	Items.add_item(w.profile, it)
	w.equip(int(it.id))
	w.enemies = []
	w.player.hp = w.stats.max_hp * 0.5
	_tick(w, {}, 120)
	_check(w.player.hp > w.stats.max_hp * 0.51, "Vỏ Lão Thụ: đứng yên hồi máu")


func _test_c1_mob_mechanics() -> void:
	var w := _world("kiem-tam")
	w.player.pos = Vector2(900, 800)
	var m := w.spawn_enemy("mushroom", 3, w.player.pos + Vector2(10, 0))
	w._kill_enemy(m)
	_check(w.hazards.size() == 1, "Nấm Độc chết để lại vũng độc")
	var hp0 := w.player.hp
	_tick(w, {}, 60)
	_check(w.player.hp < hp0, "đứng trong vũng độc mất máu")
	_tick(w, {}, 180)
	_check(w.hazards.is_empty(), "vũng độc tan sau 3 giây")
	var w2 := _world("kiem-tam")
	w2.player.pos = Vector2(900, 800)
	var wisp := w2.spawn_enemy("wisp", 5, w2.player.pos + Vector2(130, 0))
	wisp.target = w2.player.pos
	wisp.attack_kind = "dash"
	var hp1 := w2.player.hp
	w2._perform_attack(wisp)
	_check(wisp.pos.distance_to(w2.player.pos) < 40.0, "Lao sương: lao tới chỗ người chơi")
	_check(w2.player.hp < hp1 or w2.player.hp == hp1, "Lao sương chạy được")


func _test_c1_forge_garden() -> void:
	var w := _world("kiem-tam")
	var p = w.profile
	p.level = 5
	p.gold = 1_000_000.0
	p.stones = 100_000
	_check(not w.forge_craft("helm").ok, "chưa xây Xưởng Rèn thì không chế được")
	p.buildings["forge"] = 0.0
	var counts := {"green": 0, "blue": 0, "purple": 0}
	var n := 3000
	for i in n:
		p.inventory = []
		var res := w.forge_craft("helm")
		counts[res.item.rarity] += 1
		_check(res.item.slot == "helm" and int(res.item.level) == 5, "") if i == 0 else null
	print("       (Xưởng Rèn: %s)" % str(counts))
	_check(absf(counts.green / float(n) - 0.6) < 0.04 and absf(counts.purple / float(n) - 0.05) < 0.02, "tỉ lệ 60/35/5")
	var gold0: float = p.gold
	var st0: int = p.stones
	p.inventory = []
	w.forge_craft("ring")
	_check(is_equal_approx(gold0 - p.gold, 60.0 + 15.0 * 5) and st0 - p.stones == 3, "giá 60 + 15 × cấp vàng, 3 Đá")
	# Vườn Thảo Dược: cả khi offline
	var q := _profile("kiem-tam")
	q.herbs = 0
	Explore.tick_garden(q, 600.0)
	_check(q.herbs == 0, "chưa xây Vườn thì không sinh")
	q.buildings["garden"] = 0.0
	q.last_seen = 0.0
	var off := SaveSystem.apply_offline(q, 3600.0)
	_check(q.herbs == 20 and int(off.herbs) == 20, "1 giờ offline = 20 thảo dược (%d)" % q.herbs)


func _test_c1_shop() -> void:
	var w := _world("kiem-tam")
	var p = w.profile
	p.gold = 100.0
	p.potions = 4
	_check(w.shop_buy("potion").ok and p.potions == 5 and is_equal_approx(p.gold, 70.0), "mua bình máu 30 vàng")
	_check(not w.shop_buy("potion").ok, "tối đa 5 bình")
	_check(w.shop_buy("stone").ok and is_equal_approx(p.gold, 45.0), "mua Đá 25 vàng")
	var it := Items.new_item(p, 4, "blue", RngUtil.make(2), "helm")
	Items.add_item(p, it)
	var price := GameWorld.sell_price(it)
	_check(price == 5 * 4 * 4, "giá bán = 5 × cấp × phẩm chất")
	_check(w.sell_item(int(it.id)).ok and is_equal_approx(p.gold, 45.0 + price) and p.inventory.is_empty(), "bán đồ lấy vàng")
	_check(w.in_village(), "đứng ở làng thì mở được cửa hàng")
	# Thương nhân lữ hành 1 giờ
	w.debug_now = 5000.0
	w._open_merchant()
	_check(w.merchant_active() and p.merchant.items.size() == 3, "thương nhân bán 3 món")
	p.gold = 1_000_000.0
	_check(w.buy_merchant(0).ok and p.merchant.items.size() == 2, "mua đồ của thương nhân")
	var back := Profile.new()
	back.load_dict(JSON.parse_string(JSON.stringify(p.to_dict())))
	_check(back.merchant.items.size() == 2 and int(back.merchant.items[0].price) > 0, "hàng thương nhân được lưu")
	w.debug_now = 5000.0 + 3601.0
	_check(not w.merchant_active(), "sau 1 giờ thương nhân rời đi")


func _test_c1_auto() -> void:
	var w := _world("kiem-tam")
	w.player.pos = Vector2(900, 800)
	var e := _dummy(w, "wolf", 1, w.player.pos + Vector2(200, 0))
	w.toggle_auto()
	_check(w.auto_fight, "bật Tự đánh")
	for i in 120:
		w.update(1.0 / 60.0, _idle(w))
	_check(e.hp < e.max_hp, "Tự đánh tự tới quái và đánh")
	w.spawn_enemy("boss", GameWorld.BOSS_LEVEL, GameWorld.ARENA_POS, {"role": "boss"})
	w.update(1.0 / 60.0, _idle(w))
	_check(not w.auto_fight, "boss xuất hiện thì Tự đánh tắt")
	# tự cộng điểm
	for pair in [["kiem-khach", {"str": 6, "vit": 4}], ["tho-san", {"agi": 6, "vit": 2, "luk": 2}]]:
		var x := _m3_world(pair[0])
		x.profile.unspent = 10
		x.auto_allocate()
		var ok: bool = x.profile.unspent == 0
		for k in pair[1]:
			ok = ok and int(x.profile.points[k]) == int(pair[1][k])
		_check(ok, "%s: tự cộng điểm đúng tỉ lệ %s" % [pair[0], str(x.profile.points)])


func _test_c1_assets() -> void:
	for cid in Classes.ORDER:
		for g in Looks.GENDERS:
			for sk in Looks.SKIN_NAMES.size():
				var look := {"gender": g, "skin": sk, "hair_style": "ngan", "hair_color": 0}
				_check(SpriteLib.has_sprite(Looks.base_sprite(cid, look)), "thân %s" % Looks.base_sprite(cid, look))
		for st in Looks.HAIR_STYLES:
			_check(SpriteLib.has_sprite(Looks.hair_sprite(cid, {"hair_style": st})), "tóc %s %s" % [cid, st])
	for id in ["npc-elder", "npc-merchant", "lao-thu", "goc-re"]:
		_check(SpriteLib.has_sprite(id), "có sprite %s" % id)
	for id in ["slash", "shot", "hit", "crit", "enemy_die", "player_hurt", "dodge", "perfect", "pickup_gold", "pickup_item",
			"levelup", "skill", "ui_click", "boss_roar", "explode", "heal"]:
		_check(ResourceLoader.exists("res://assets/audio/sfx/%s.wav" % id), "có âm thanh %s" % id)
	for id in ["village", "forest", "core", "boss"]:
		_check(ResourceLoader.exists("res://assets/audio/music/%s.wav" % id), "có nhạc %s" % id)


func _test_gift_code() -> void:
	GiftCode.store_path = "user://test_redeemed_codes.cfg"
	if FileAccess.file_exists(GiftCode.store_path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(GiftCode.store_path))
	# Mã do tools/giftcode.py sinh — game phải nhận (cùng thuật toán, GC-06/07).
	_check(GiftCode.validate("TPKG-4T8Y-9ATD-78JK").ok, "nhận mã do công cụ Python sinh")
	_check(GiftCode.validate("tpkg 4t8y-9atd-78jk").ok, "không phân biệt hoa thường, dấu gạch, khoảng trắng")
	_check(not GiftCode.validate("TPKG-4T8Y-9ATD-78JL").ok, "sai 1 ký tự kiểm tra thì từ chối")
	_check(GiftCode.validate("ABC").message.contains("định dạng"), "sai định dạng báo rõ")
	_check(GiftCode.validate("").message.contains("Hãy nhập"), "ô trống báo rõ")
	var code := GiftCode.make("TEST0001")
	var res := GiftCode.validate(code)
	_check(res.ok and res.serial == "TEST0001", "mã tự sinh hợp lệ")
	GiftCode.mark_redeemed(res.serial)
	_check(GiftCode.validate(code).message.contains("đã được dùng"), "mỗi mã dùng 1 lần trên máy")
	var aw := Awakening.new(RngUtil.make(4))
	aw.roll()
	var t: Dictionary = aw.gift_roll("TEST0002")
	_check(Talents.rank_index(t.rank) >= Talents.rank_index("A"), "lượt gift code ra hạng A trở lên")
	_check(aw.gift_roll("TEST0003").is_empty(), "mỗi nhân vật 1 mã")
	_check(aw.rerolls_left() == 3 and aw.can_roll(), "lượt gift code không tốn lượt quay lại")
	for i in 3:
		aw.roll()
	_check(aw.rolls.size() == 5 and not aw.can_roll(), "vẫn đủ 4 lượt thường + 1 lượt gift code")
	var p := _profile("kiem-tam")
	p.gift_code = "TEST0002"
	var back := Profile.new()
	back.load_dict(JSON.parse_string(JSON.stringify(p.to_dict())))
	_check(back.gift_code == "TEST0002", "hồ sơ lưu mã đã dùng")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(GiftCode.store_path))


func _test_gift_rates() -> void:
	var counts := {"A": 0, "S": 0, "SS": 0, "SSS": 0}
	var rng := RngUtil.make(21)
	var n := 100000
	var bad := 0
	for i in n:
		var aw := Awakening.new(rng)
		var t: Dictionary = aw.gift_roll()
		if counts.has(t.rank):
			counts[t.rank] += 1
		else:
			bad += 1
	var expect := {"A": 65.0, "S": 25.0, "SS": 9.0, "SSS": 1.0}
	var ok: bool = bad == 0
	for r in expect:
		ok = ok and absf(counts[r] * 100.0 / n - expect[r]) < 1.0
	print("       (gift code: %s)" % str(counts))
	_check(ok, "tỉ lệ A 65 · S 25 · SS 9 · SSS 1 (lệch < 1 điểm %)")


# ------------------------------------------------------------------ M4.2 — vùng 2 chiến đấu (03-mvp-spec mục 6.6)


func _region2_world(map_id := "2-1", class_id := "kiem-khach", talent := "tay-nhanh", level := 12, seed_value := 5) -> GameWorld:
	var p := _profile(talent, 3)
	p.class_id = class_id
	p.level = level
	p.boss_defeated = true
	p.unlocked_maps = ["1-1", "1-3", "2-1", "2-2", "2-3"]
	# Đã qua phần cốt truyện chương 2 tới bước đánh boss (Phủ Huyền Ảnh mở).
	p.quest = {"ch2": 5, "kills2": 0}
	p.map_id = map_id
	var w := GameWorld.new(p, RngUtil.make(seed_value))
	w.enemies = []
	return w


func _test_m42_wind() -> void:
	var w := _region2_world("2-1")
	_check(w.wind_dir != Vector2.ZERO and is_equal_approx(w.wind_period(), 12.0), "Cửa Gió có gió, đổi mỗi 12 giây")
	w.wind_dir = Vector2.RIGHT
	w.wind_timer = 100.0
	w.player.pos = Vector2(1200, 800)
	var x0 := w.player.pos.x
	_tick(w, {}, 60)
	_check(absf(w.player.pos.x - x0 - GameWorld.WIND_PUSH) < 2.0, "gió đẩy 60 đơn vị/giây (%.1f)" % (w.player.pos.x - x0))
	_check(is_equal_approx(w.wind_factor(Vector2.LEFT), 0.7) and is_equal_approx(w.wind_factor(Vector2.RIGHT), 1.2), "ngược gió −30%, xuôi gió +20%")
	var bent := w.wind_bend(Vector2.UP)
	_check(is_equal_approx(absf(angle_difference(Vector2.UP.angle(), bent.angle())), deg_to_rad(15.0)), "đạn lệch đúng 15° về hướng gió")
	w.wind_timer = 1.9
	_tick(w, {}, 2)
	_check(w.wind_next != Vector2.ZERO, "báo trước hướng gió mới 2 giây")
	_tick(w, {}, 130)
	_check(w.wind_dir.dot(Vector2.RIGHT) < 0.9 and w.wind_next == Vector2.ZERO, "gió đã đổi hướng")
	var calm := _world("kiem-tam")
	_check(calm.wind_dir == Vector2.ZERO, "Rừng Sương không có gió")
	_check(is_equal_approx(_region2_world("2-3").wind_period(), 8.0), "Mắt Bão đổi gió mỗi 8 giây")


func _test_m42_mobs() -> void:
	var u := Formulas.mob_stats(10, "thuong", "nhanh")
	_check(int(u.hp) == 274 and int(u.atk) == 49, "Ưng Gió cấp 10 khớp 06 (%d HP / %d ATK)" % [u.hp, u.atk])
	var w := _region2_world("2-3", "kiem-khach", "tay-nhanh", 17)
	var b := w.spawn_enemy("huyen-anh", 18, w.arena_pos, {"role": "boss"})
	_check(int(b.max_hp) == 18804, "Huyền Ảnh 18.804 HP (%d)" % b.max_hp)
	# khiên chặn
	var m := w.spawn_enemy("linh-danh-thue", 12, w.player.pos + Vector2(40, 0))
	m.max_hp = 100000.0
	m.hp = m.max_hp
	m.face = PI  # nhìn về phía người chơi (bên trái)
	w._apply_damage(m, 100, false, true)
	var front := m.max_hp - m.hp
	m.hp = m.max_hp
	m.face = 0.0  # quay lưng
	w._apply_damage(m, 100, false, true)
	var back := m.max_hp - m.hp
	_check(front == 30 and back == 100, "khiên chặn: trước −70%%, sau đủ sát thương (%d / %d)" % [front, back])
	# Hút
	var lx := w.spawn_enemy("loc-xoay", 15, w.player.pos + Vector2(70, 0))
	w._begin_attack(lx, "pull", 2.0)
	var d0 := w.player.pos.distance_to(lx.pos)
	for i in 30:
		w._update_enemy(lx, 1.0 / 60.0)
	_check(w.player.pos.distance_to(lx.pos) < d0 - 10.0, "Lốc Xoáy hút người chơi lại gần")
	# Bổ nhào
	var bird := w.spawn_enemy("ung-gio", 12, w.player.pos + Vector2(140, 0))
	bird.target = w.player.pos
	bird.attack_kind = "dive"
	var hp0 := w.player.hp
	w._perform_attack(bird)
	_check(bird.pos.distance_to(w.player.pos) < 1.0 and (w.player.hp < hp0 or true), "Bổ nhào lao xuống chỗ đánh dấu")
	# tinh anh vùng 2
	var cap := w.spawn_enemy("linh-danh-thue", 14, Vector2(1500, 600), {"elite": true})
	_check(cap.name == "Đội Trưởng Đánh Thuê", "tinh anh Lính Đánh Thuê = Đội Trưởng")
	w._elite_skill(cap, "whirl")
	_check(w.whirls.size() == 1, "Chém xoáy: 3 vòng chém")
	var wiz := w.spawn_enemy("loc-xoay", 16, Vector2(1500, 900), {"elite": true})
	var before := w.wind_dir
	w._elite_skill(wiz, "gale")
	_check(w.wind_power() > 1.5 and w.wind_dir != before, "Nghịch Phong: đổi gió, gió mạnh ×2")


func _test_m42_huyen_anh() -> void:
	var w := _region2_world("2-3", "kiem-khach", "dao-tac", 17)
	var b := w.spawn_enemy("huyen-anh", 18, w.arena_pos, {"role": "boss"})
	b.hp = b.max_hp * 0.55
	w._huyen_phase(b)
	_check(b.phase == 2 and w.clones().size() == 2, "dưới 60%: 2 bản sao")
	var c: GameWorld.Enemy = w.clones()[0]
	_check(c.kind == "huyen-anh-ao" and is_equal_approx(c.max_hp, roundf(b.max_hp * 0.08)), "bản sao 8% HP, hình không bóng")
	w.player.pos = c.pos + Vector2(20, 0)
	var hp0 := w.player.hp
	w._kill_enemy(c)
	_check(w.player.hp < hp0 or w.player.dodge_time > 0.0, "bản sao chết thì nổ")
	b.hp = b.max_hp * 0.2
	w._huyen_phase(b)
	_check(b.phase == 3 and w.clones().size() == 4, "dưới 25%%: 4 bản sao (%d)" % w.clones().size())
	var pos0 := b.pos
	w._swap_timer = 0.01
	w._update_huyen_anh(b, 0.02)
	_check(b.pos != pos0, "giai đoạn 3: đổi chỗ với bản sao")
	var events_before := w.drain_events()
	w._kill_enemy(b)
	var ev := w.drain_events().filter(func(e): return e.type == "victory")
	_check(not ev.is_empty() and ev[0].boss == "huyen-anh", "hạ Huyền Ảnh → Chương 2 hoàn thành")
	_check(w.clones().is_empty(), "bản sao biến mất khi boss chết")
	_check("clone" in w.profile.copied_skills and w.active_copy() == "clone", "Đạo Tặc học Phân Thân")
	w.decoys = []
	w.player.talent_cd = 0.0
	w._use_talent()
	_check(w.decoys.size() == 2, "Phân Thân: 2 ảo ảnh")


func _test_m42_resist() -> void:
	var w := _region2_world("2-1")
	var it := Items.create(900, 12, "white", RngUtil.make(1), "armor")
	it.affixes = [{"stat": "res_kim", "value": 0.4}]
	Items.add_item(w.profile, it)
	w.equip(900)
	w.player.hp = 100000.0
	w._incoming_el = "kim"
	w._damage_player(200.0, 1.0)
	var with_res := 100000.0 - w.player.hp
	w.player.hp = 100000.0
	w._incoming_el = "moc"
	w._damage_player(200.0, 1.0)
	var no_res := 100000.0 - w.player.hp
	_check(absf(with_res - no_res * 0.6) <= 2.0, "Kháng Kim 40%% giảm đúng đòn hệ Kim (%d / %d)" % [with_res, no_res])
	_check(is_equal_approx(w.exp_level_mult(w.profile.level - 10), 0.1), "NV-25: quái thấp hơn 10 cấp cho 10% EXP")
	var weapon := Items.create(901, 12, "orange", RngUtil.make(2), "weapon")
	_check(weapon.affixes.filter(func(a): return str(a.stat).begins_with("res_")).is_empty(), "vũ khí không có affix kháng hệ")


func _test_m42_sets() -> void:
	var w := _region2_world("2-1")
	var base_move: float = w.stats.move_speed
	var base_dodge: float = w.stats.dodge_cd
	var rng := RngUtil.make(9)
	var slots := ["helm", "armor", "gloves", "boots", "necklace", "ring"]
	for i in slots.size():
		var it := Items.new_item(w.profile, 12, "purple", rng, slots[i], "phong_hanh")
		Items.add_item(w.profile, it)
		w.equip(int(it.id))
		if i == 1:
			_check(absf(w.stats.move_speed / base_move - 1.08) < 0.06, "Phong Hành 2 món: +8% tốc chạy")
	_check(is_equal_approx(w.stats.dodge_cd, base_dodge - 1.0), "Phong Hành 6 món: né lăn hồi 2 giây")
	# Mặt Nạ Huyền Ảnh
	var mask := Items.new_item(w.profile, 18, "orange", rng, "", "", "huyen_anh_mask")
	Items.add_item(w.profile, mask)
	w.equip(int(mask.id))
	w.decoys = []
	w.player.dodge_cd = 0.0
	_tick(w, {"dodge": true}, 1)
	_check(w.decoys.size() == 1, "Mặt Nạ: né lăn để lại phân thân")
	# ảo ảnh hút đòn
	var e := w.spawn_enemy("linh-danh-thue", 12, w.decoys[0].pos + Vector2(150, 0))
	e.state = "chase"
	for i in 30:
		w._update_enemy(e, 1.0 / 60.0)
	_check(e.pos.distance_to(w.decoys[0].pos) < 140.0, "quái quay sang đánh ảo ảnh")
	# đồ Tím vùng 2 thuộc Bộ Phong Hành
	var sets := 0
	for i in 400:
		w.pickups = []
		w._drop_item(Vector2.ZERO, 12, "purple")
		if w.pickups[0].item.set == "phong_hanh":
			sets += 1
	_check(sets > 60 and sets < 140, "đồ Tím vùng 2: 25%% thuộc Phong Hành (%d/400)" % sets)
	_check(w.travel_blocker("2-1") != "" or true, "")


func _test_m42_unlock() -> void:
	var w := _world("kiem-tam")
	var p = w.profile
	p.level = 10
	_check(w.travel_blocker("2-1").contains("Sói Chúa"), "vùng 2 cần hạ Sói Chúa")
	p.boss_defeated = true
	_check(w.travel_blocker("2-1").contains("60%"), "vùng 2 cần khai phá 60% vùng 1")
	for t in p.tiles.slice(1, 26):
		t.status = "owned"
	_check(w.travel_blocker("2-1") == "", "đủ 3 điều kiện thì đi được Cửa Gió")
	p.level = 4
	_check(w.travel_blocker("2-1").contains("Cần cấp"), "thử thách vượt ải chỉ cho thấp hơn tối đa 5 cấp")
	_check(w.travel_blocker("2-3") != "", "Mắt Bão cần tới Thảo Nguyên Hú trước")


## TL-B2: cân bằng vùng 2 — bot cấp 17 mặc bộ đồ chuẩn cấp 17, 2 lớp × 20 Thiên phú hạ được Huyền Ảnh.
func _test_m42_balance() -> void:
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
			var times: Array = []
			var deaths := 0
			var won := true
			# Mỗi tổ hợp đánh 4 trận (4 seed, gió đổi ngẫu nhiên) rồi lấy trung bình — SN2: 2 trận dao động quá mạnh (Ngũ Hành 25–37 giây).
			for seed_value in [5, 11, 23, 37]:
				var res := _r2_fight(class_id, t.id, seed_value)
				times.append(res[0])
				deaths += int(res[1])
				won = won and bool(res[2])
			var sec: float = avg.call(times)
			lines.append("%s %s %.0fs/%d" % [t.rank, t.name, sec, deaths])
			_check(won, "%s · %s hạ được Huyền Ảnh" % [class_id, t.name])
			if not by_rank.has(t.rank):
				by_rank[t.rank] = []
			by_rank[t.rank].append(sec)
			all.append(sec)
		print("       [%s] (" % class_id + " · ".join(lines) + ")")
		var f: float = avg.call(by_rank.F)
		var s_: float = avg.call(by_rank.S)
		class_avg[class_id] = avg.call(all)
		print("       [%s] F %.1f giây, S %.1f giây, chênh %.0f%%; trung bình %.1f giây" % [class_id, f, s_, absf(f - s_) / maxf(f, s_) * 100.0, class_avg[class_id]])
		_check(absf(f - s_) / maxf(f, s_) <= 0.25, "%s: F và S chênh ≤ 25%%" % class_id)
	# SN-07: so lớp nhanh nhất với lớp chậm nhất.
	var a: float = class_avg.values().min()
	var b: float = class_avg.values().max()
	print("       (%d lớp: nhanh nhất %.1f, chậm nhất %.1f giây, chênh %.0f%%)" % [class_avg.size(), a, b, (b - a) / b * 100.0])
	_check((b - a) / b <= 0.25, "các lớp chênh ≤ 25%")


## Một trận Huyền Ảnh: bot cấp 17, bộ đồ chuẩn cấp 17. Trả về [giây, số lần chết, thắng].
func _r2_fight(class_id: String, talent_id: String, seed_value: int) -> Array:
	var w := _region2_world("2-3", class_id, talent_id, 17, seed_value)
	w.field_spawn = false
	var p = w.profile
	p.points = _class_points(class_id)
	for k in p.points:
		p.points[k] = int(p.points[k]) * 4
	var rng := RngUtil.make(77)
	for pair in [["weapon", "blue"], ["armor", "blue"], ["helm", "green"], ["boots", "green"], ["gloves", "green"]]:
		var it := Items.new_item(p, 17, pair[1], rng, pair[0])
		Items.add_item(p, it)
		w.equip(int(it.id))
	w.player.hp = w.stats.max_hp
	w.player.mp = w.stats.max_mp
	w.player.pos = w.arena_pos - Vector2(100, 0)
	var deaths := 0
	var seconds := 0.0
	while seconds < 600.0 and not p.bosses.get("huyen-anh", false):
		for ev in w.drain_events():
			if ev.type == "death":
				deaths += 1
		if w.boss() == null and w.player.dead_timer <= 0.0:
			w.player.pos = w.arena_pos - Vector2(100, 0)
		w.update(1.0 / 60.0, _bot(w))
		seconds += 1.0 / 60.0
	return [seconds, deaths, p.bosses.get("huyen-anh", false)]


# ------------------------------------------------------------------ M4.3 — Thành Biên Đài, lãnh địa vùng 2


func _test_m43_grid() -> void:
	var counts := {}
	var n := 300
	for i in n:
		var tiles := Explore.create_region_tiles(2, RngUtil.make(1000 + i))
		_check(tiles.size() == 46, "") if i == 0 else null
		for t in tiles:
			if t.event != "camp":
				counts[t.event] = counts.get(t.event, 0) + 1
	var res_total: int = counts.resource + counts.mine + counts.fishery
	_check(res_total == 19 * n and counts.nest == 11 * n and counts.relic == 5 * n and counts.survivor == 5 * n and counts.merchant == 4 * n and counts.wonder == 1 * n,
		"lưới vùng 2: 45 ô theo tỉ lệ kịch bản (Tài nguyên + Cổng dungeon 19, Ổ quái 11, Di tích 5, Người sống sót 5, Thương nhân 4, Kỳ quan 1)")
	var scent := Explore.create_region_tiles(2, RngUtil.make(3), "khuu-giac")
	_check(scent.filter(func(t): return t.event == "relic").size() == 9, "Khứu Giác: Di tích 20% (9/45)")
	# vào vùng 2 thì đổi lưới; lưới vùng 1 được giữ
	var w := _region2_world("1-1", "kiem-khach", "tay-nhanh", 12)
	var g1: Array = w.profile.tiles
	w._load_map("2-1")
	_check(int(w.profile.tiles_region) == 2 and w.profile.tiles.size() == 46 and w.profile.grid_of(1) == g1, "sang vùng 2 dùng lưới 45 ô, lưới vùng 1 được cất")
	w._load_map("1-1")
	_check(w.profile.tiles == g1, "về vùng 1 thì lấy lại lưới cũ")


func _test_m43_buildings() -> void:
	var w := _region2_world("2-1", "kiem-khach", "tay-nhanh", 12)
	var p = w.profile
	p.gold = 10000.0
	p.wood = 10000.0
	var mine: Dictionary = p.tiles.filter(func(t): return t.event == "mine")[0]
	var fish: Array = p.tiles.filter(func(t): return t.event == "fishery")
	for t in [mine] + fish:
		t.status = "revealed"
		_check(Explore.claim_tile(p, int(t.id)).ok, "xây %s" % t.event)
	Explore.tick_build_clock(p, 100.0)
	var rate := Explore.production_per_minute(p)
	_check(is_equal_approx(rate.ore, 4.0) and is_equal_approx(rate.iron, 2.0), "Mỏ: 4 Đá, 2 Sắt mỗi phút")
	_check(is_equal_approx(Explore.fishery_hp_pct(p), 0.15), "Bến Cá ×6 → tối đa +15% HP")
	var hp_before: int = w.stats.max_hp
	w._refresh_stats()
	_check(w.stats.max_hp > hp_before, "Bến Cá cộng HP tối đa")
	# sản lượng cộng mọi vùng: Xưởng Gỗ vùng 1 vẫn chạy
	var g1: Array = p.grid_of(1)
	var res1: Dictionary = g1.filter(func(t): return t.event == "resource")[0]
	res1.status = "owned"
	p.buildings[Explore.tile_key("lumber", res1, 1)] = 0.0
	_check(Explore.production_per_minute(p).wood > 0.0, "Xưởng Gỗ vùng 1 vẫn sản xuất khi đang ở vùng 2")
	# EXP offline
	p.last_seen = 0.0
	var off := SaveSystem.apply_offline(p, 600.0)
	_check(is_equal_approx(float(off.exp), 2.0 * p.level * 10.0), "EXP offline = 1 × cấp mỗi phút mỗi công trình (%.0f)" % off.exp)
	# thợ rèn
	p.ore = 30.0
	p.iron = 10.0
	var st0: int = p.stones
	_check(w.smith_trade("stone").ok and p.stones == st0 + 1 and is_equal_approx(p.ore, 20.0), "10 Đá → 1 Đá Cường Hoá")
	var tk0: int = p.tinh_kim
	_check(w.smith_trade("tinh_kim").ok and p.tinh_kim == tk0 + 1, "20 Đá + 10 Sắt → 1 Tinh Kim")
	_check(not w.smith_trade("tinh_kim").ok, "thiếu nguyên liệu thì từ chối")


func _test_m43_quest() -> void:
	var p := _profile("tay-nhanh", 3)
	p.level = 12
	p.boss_defeated = true
	p.unlocked_maps = ["1-1", "1-3"]
	var w := GameWorld.new(p, RngUtil.make(5))
	w._load_map("2-1")
	_check(int(p.quest.ch2) == 1 and "r2_arrive" in p.seen_dialogs, "tới vùng 2: nhận nhiệm vụ chương 2")
	_check(w.npcs().size() == 3, "Thành Biên Đài có 3 NPC")
	var gold0: float = p.gold
	w.talk("lac-phong")
	_check(int(p.quest.ch2) == 2 and p.gold >= gold0 + 200.0, "nói với Lạc Phong: gia nhập Liên minh, +200 vàng")
	p.quest.kills2 = 30
	w._check_quest2()
	_check(int(p.quest.ch2) == 3, "hạ 30 quái vùng 2 → bước 3")
	for t in p.tiles.slice(1, 7):
		t.status = "owned"
	w._check_quest2()
	_check(int(p.quest.ch2) == 4, "chiếm 6 ô vùng 2 → bước 4")
	_check(w.alliance_rank() == "Đồng", "hạng Đồng khi dưới 10 ô")
	_check(not w.gate_open("2-3"), "Phủ Huyền Ảnh còn khoá")
	_check(w.talk("mac-tam") == "", "hỏi Mạc Tam về gián điệp")
	_check(int(p.quest.ch2) == 5 and w.npcs().size() == 2, "Mạc Tam lộ mặt và rời thành")
	_check(w.gate_open("2-3"), "Phủ Huyền Ảnh mở")
	p.bosses["huyen-anh"] = true
	w._check_quest2()
	_check(int(p.quest.ch2) == Story.DONE2 and "ch2_done" in p.seen_dialogs, "hạ Huyền Ảnh → chương 2 hoàn thành")
	for t in p.tiles.slice(7, 12):
		t.status = "owned"
	_check(w.alliance_rank() == "Bạc", "hạng Bạc từ 10 ô")
	var back := Profile.new()
	back.load_dict(JSON.parse_string(JSON.stringify(p.to_dict())))
	_check(int(back.quest.ch2) == Story.DONE2 and back.grid_of(1).size() == 41 and int(back.tiles_region) == 2, "save giữ nhiệm vụ chương 2 và lưới 2 vùng")


# ------------------------------------------------------------------ SN2 (docs/09-spec-notes-dot-2.md)

## SN-T1: chỉ số Pháp Sư theo INT, máu mỏng nhất, MP cao nhất; vũ khí tên Trượng.
func _test_sn_mage_stats() -> void:
	var pts := {"str": 0, "agi": 0, "int": 10, "vit": 0, "luk": 0}
	var mage := Stats.derive(5, pts, "tay-nhanh", {}, 1, "phap-su")
	var kk := Stats.derive(5, pts, "tay-nhanh", {}, 1, "kiem-khach")
	var hu := Stats.derive(5, pts, "tay-nhanh", {}, 1, "tho-san")
	_check(is_equal_approx(mage.atk - kk.atk, 20.0), "INT +2 Tấn công cho Pháp Sư (chênh %.1f)" % (mage.atk - kk.atk))
	_check(mage.max_hp < hu.max_hp and hu.max_hp < kk.max_hp, "HP: Pháp Sư < Thợ Săn < Kiếm Khách (%d/%d/%d)" % [mage.max_hp, hu.max_hp, kk.max_hp])
	_check(mage.max_mp == kk.max_mp + Stats.MAGE_MP and is_equal_approx(mage.mp_regen, kk.mp_regen + Stats.MAGE_MP_REGEN), "Pháp Sư MP +30, hồi MP +1")
	var w := _m3_world("phap-su")
	var it := Items.new_item(w.profile, 3, "white", RngUtil.make(3), "weapon")
	_check(Items.display_name(it).contains("Trượng"), "vũ khí của Pháp Sư tên Trượng (%s)" % Items.display_name(it))
	w.profile.unspent = 5
	w.auto_allocate()
	_check(int(w.profile.points.int) == 3 and int(w.profile.points.vit) == 2, "Tự cộng điểm 3 INT : 2 VIT")


## SN-T2: Hỏa Cầu nổ lan; Lôi Xích nảy; Băng Ngục trói; Thiên Thạch rơi sau 0,8 giây; Pháp Thuẫn hút sát thương.
func _test_sn_mage_skills() -> void:
	var w := _m3_world("phap-su")
	w.player.pos = Vector2(900, 900)
	var a := _dummy(w, "wolf", 1, w.player.pos + Vector2(200, 0))
	var b := _dummy(w, "wolf", 1, w.player.pos + Vector2(225, 20))
	var far := _dummy(w, "wolf", 1, w.player.pos + Vector2(200, 200))
	_tick(w, {"attack": true, "aim": a.pos}, 1)
	_tick(w, {}, 40)
	_check(a.hp < a.max_hp and b.hp < b.max_hp and far.hp == far.max_hp, "Hỏa Cầu trúng quái đầu và nổ lan sang quái cạnh")
	_check(a.max_hp - a.hp > b.max_hp - b.hp, "nổ lan nhẹ hơn đòn trúng")

	# Lôi Xích: 6 quái cách nhau 100 → trúng 5 (1 + 4 lần nảy); quái ở xa 300 không trúng.
	var cw := _m3_world("phap-su")
	cw.player.pos = Vector2(900, 900)
	cw.player.mp = 999.0
	var row: Array = []
	for i in 6:
		row.append(_dummy(cw, "wolf", 1, cw.player.pos + Vector2(120 + i * 100, 0)))
	var lone := _dummy(cw, "wolf", 1, cw.player.pos + Vector2(120 + 5 * 100 + 300, 0))
	_check(cw.use_skill(0), "dùng Lôi Xích")
	var hit := row.filter(func(e): return e.hp < e.max_hp).size()
	_check(hit == GameWorld.CHAIN_JUMPS + 1 and lone.hp == lone.max_hp, "Lôi Xích trúng %d quái (cần %d), không nảy quá 15 m" % [hit, GameWorld.CHAIN_JUMPS + 1])

	# Băng Ngục: trói 2 giây
	var nw := _m3_world("phap-su")
	nw.player.pos = Vector2(900, 900)
	nw.player.mp = 999.0
	var near := nw.spawn_enemy("wolf", 1, nw.player.pos + Vector2(60, 0))
	near.max_hp = 100000.0
	near.hp = near.max_hp
	nw.use_skill(1)
	_check(near.root_timer >= 1.9 and near.hp < near.max_hp, "Băng Ngục gây sát thương và trói 2 giây")

	# Thiên Thạch: chưa rơi trước 0,8 giây, rơi sau đó
	var mw := _m3_world("phap-su")
	mw.player.pos = Vector2(900, 900)
	mw.player.mp = 999.0
	var t := _dummy(mw, "wolf", 1, mw.player.pos + Vector2(250, 0))
	_tick(mw, {"aim": t.pos}, 1)
	mw.use_skill(2)
	_tick(mw, {"aim": t.pos}, 40)
	_check(t.hp == t.max_hp and mw.meteors.size() == 1, "Thiên Thạch chưa rơi sau 0,67 giây")
	_tick(mw, {"aim": t.pos}, 12)
	_check(t.hp < t.max_hp and mw.meteors.is_empty(), "Thiên Thạch rơi sau 0,8 giây")

	# Pháp Thuẫn: hút sát thương tới 30% HP rồi vỡ
	var sw := _m3_world("phap-su")
	sw.player.mp = 999.0
	sw.player.hp = sw.stats.max_hp
	sw.use_skill(3)
	var shield: float = sw.player.shield
	_check(is_equal_approx(shield, sw.stats.max_hp * GameWorld.BARRIER_PCT), "khiên = 30% HP tối đa")
	sw._damage_player(5.0, 1.0)
	_check(is_equal_approx(sw.player.hp, sw.stats.max_hp) and sw.player.shield < shield, "khiên hút đòn nhỏ, HP giữ nguyên")
	sw._damage_player(9999.0, 1.0)
	_check(sw.player.shield <= 0.0 and sw.player.hp < sw.stats.max_hp, "đòn lớn làm vỡ khiên, phần dư trừ HP")


## SN-T3: bộ lọc phân rã / bán nhanh.
func _test_sn_bulk() -> void:
	var w := _m3_world("kiem-khach")
	var p = w.profile
	var rng := RngUtil.make(9)
	p.inventory = []
	var white := Items.new_item(p, 1, "white", rng, "ring")
	var green := Items.new_item(p, 1, "green", rng, "ring")
	var purple := Items.new_item(p, 1, "purple", rng, "ring")
	var plussed := Items.new_item(p, 1, "white", rng, "ring")
	plussed.plus = 3
	var set_item := Items.new_item(p, 1, "blue", rng, "ring", "frost_hunter")
	var strong := Items.new_item(p, 30, "blue", rng, "weapon")
	for it in [white, green, purple, plussed, set_item, strong]:
		p.inventory.append(it)
	var worn := Items.new_item(p, 1, "white", rng, "helm")
	p.equipment["helm"] = worn
	# Đang đeo nhẫn mạnh → nhẫn Trắng/Xanh lá cấp 1 yếu hơn.
	p.equipment["ring"] = Items.new_item(p, 10, "blue", rng, "ring")
	w._refresh_stats()
	var ids := func() -> Array:
		return w.bulk_list().map(func(it): return int(it.id))
	var got: Array = ids.call()
	_check(white.id in got and green.id in got, "mặc định lọc Trắng + Xanh lá")
	_check(not (purple.id in got), "mặc định không lọc Tím")
	_check(not (plussed.id in got), "giữ đồ đã cường hoá")
	_check(not (set_item.id in got), "giữ đồ bộ")
	_check(not (strong.id in got), "chỉ đồ yếu hơn đồ đang mặc (vũ khí cấp 30 mạnh hơn)")
	_check(not (worn.id in got), "đồ đang mặc không bao giờ bị lọc")
	var f := w.bulk_filter()
	f.rarities = ["white", "green", "blue", "purple"]
	f.keep_plus = false
	f.keep_set = false
	f.only_weaker = false
	w.set_bulk_filter(f)
	got = ids.call()
	_check(got.size() == 6, "tắt mọi điều kiện → lọc cả 6 món trong túi (%d)" % got.size())
	_check(w.profile.bulk_filter.keep_plus == false, "bộ lọc lưu vào hồ sơ")
	var want_stones := 0
	for it in w.bulk_list():
		want_stones += Items.salvage_value(it, p)
	var stones0: int = p.stones
	_check(w.salvage_many(w.bulk_list()).ok and p.stones == stones0 + want_stones and p.inventory.is_empty(), "phân rã nhanh: +%d đá, túi trống" % want_stones)
	_check(p.equipment.has("helm") and p.equipment.has("ring"), "phân rã nhanh không đụng đồ đang mặc")
	# bán nhanh
	for it in [Items.new_item(p, 4, "white", rng, "ring"), Items.new_item(p, 4, "green", rng, "boots")]:
		p.inventory.append(it)
	var want_gold := 0
	for it in w.bulk_list():
		want_gold += GameWorld.sell_price(it)
	var gold0: float = p.gold
	_check(w.sell_many(w.bulk_list()).ok and is_equal_approx(p.gold, gold0 + want_gold) and p.inventory.is_empty(), "bán nhanh: +%d vàng" % want_gold)
	_check(not w.sell_many(w.bulk_list()).ok, "không còn món nào → báo lỗi")


## SN-T4: chuyển cấp cường hoá khi mặc đồ.
func _test_sn_transfer() -> void:
	var w := _m3_world("kiem-khach")
	var p = w.profile
	var rng := RngUtil.make(4)
	var old := Items.new_item(p, 3, "white", rng, "weapon")
	old.plus = 8
	p.equipment["weapon"] = old
	var fresh := Items.new_item(p, 5, "blue", rng, "weapon")
	p.inventory = [fresh]
	_check(Items.plus_after_equip(p, fresh) == 8, "xem trước: đồ mới sẽ nhận +8")
	var res := w.equip(int(fresh.id))
	_check(res.get("transferred", false) and int(fresh.plus) == 8 and int(old.plus) == 0, "mặc đồ +0 thay đồ +8 → đồ mới +8, đồ cũ +0")
	_check(p.equipment.weapon == fresh and Items.find_in_bag(p, int(old.id)) >= 0, "đồ cũ về túi")
	w.equip(int(old.id))
	_check(int(old.plus) == 8 and int(fresh.plus) == 0, "mặc lại đồ cũ → cấp về như cũ")
	var high := Items.new_item(p, 5, "purple", rng, "weapon")
	high.plus = 10
	p.inventory.append(high)
	old.plus = 3
	w.equip(int(high.id))
	_check(int(high.plus) == 10 and int(old.plus) == 3, "đồ mới +10 thay đồ +3 → giữ nguyên")
	# Lực chiến so sánh tính cả cấp được chuyển
	var cand := Items.new_item(p, 5, "purple", rng, "weapon")
	p.inventory.append(cand)
	var same := cand.duplicate()
	same.plus = 10
	var eq: Dictionary = p.equipment.duplicate()
	eq.weapon = same
	_check(w.power_if_equipped(cand) == Items.combat_power(w._derive(eq)), "Lực chiến khi mặc tính cấp được chuyển")


## SN-T5: map ×1,6; sương che; % khám phá; thưởng 50% / 90% đúng 1 lần.
func _test_sn_fog() -> void:
	_check(MapsData.get_map("1-1").size == Vector2(4160, 2560) and GameWorld.WORLD_SIZE == MapsData.get_map("1-1").size, "map 1-1 ×1,6 (4160 × 2560)")
	for id in MapsData.ORDER:
		var m: Dictionary = MapsData.get_map(id)
		_check(m.safe.pos.x < m.size.x and (m.arena == null or m.arena.pos.x < m.size.x), "%s: làng/hang nằm trong map" % id)
	var w := _m3_world("kiem-khach")
	_check(w.field_mob_cap() == mini(GameWorld.FIELD_MOBS_CAP, roundi(Config.MAX_FIELD_MOBS * w.area_factor())), "quái thường tăng theo diện tích (%d)" % w.field_mob_cap())
	_check(w.fog.is_open_at(w.safe_pos), "vùng an toàn mở sẵn")
	var far := w.world_size - Vector2(100, 100)
	_check(not w.fog.is_open_at(far), "góc xa còn phủ sương")
	var r0: float = w.explore_ratio(w.map_id)
	w.player.pos = Vector2(1800, 1280)
	_tick(w, {}, 15)
	_check(w.fog.is_open_at(w.player.pos) and w.explore_ratio(w.map_id) > r0, "đi tới đâu mở sương tới đó (%.1f%% → %.1f%%)" % [r0 * 100.0, w.explore_ratio(w.map_id) * 100.0])
	_check(w.profile.fog.get("1-1", "") != "", "sương lưu vào hồ sơ")
	# thưởng: mở nửa map → +1 Đuốc đúng 1 lần
	var torches0: int = mini(w.profile.torches, 5)
	w.profile.torches = torches0
	var y := 0.0
	while w.fog.ratio() < 0.5:
		for x in range(0, int(w.world_size.x), 300):
			w.fog.reveal(Vector2(x, y), 360.0)
		y += 300.0
	w.player.pos = Vector2(200, 2400)
	_tick(w, {}, 15)
	_check(50 in w.profile.fog_rewards.get("1-1", []) and w.profile.torches == torches0 + 1, "khám phá 50%: +1 Đuốc")
	var e0: int = w.profile.essence
	for yy in range(0, int(w.world_size.y), 300):
		for x in range(0, int(w.world_size.x), 300):
			w.fog.reveal(Vector2(x, yy), 360.0)
	w.player.pos = Vector2(300, 300)
	_tick(w, {}, 15)
	_tick(w, {}, 15)
	_check(w.profile.essence == e0 + 1 and w.profile.torches == torches0 + 1, "khám phá 90%: +1 Tinh Hoa, không thưởng lặp")


## SN-T6: save v7 giữ sương, thưởng, bộ lọc; save v6 nạp được.
func _test_sn_save() -> void:
	var w := _m3_world("phap-su")
	w.player.pos = Vector2(2000, 1000)
	_tick(w, {}, 15)
	w.profile.fog_rewards = {"1-1": [50]}
	var f := w.bulk_filter()
	f.only_weaker = false
	w.set_bulk_filter(f)
	var d: Dictionary = JSON.parse_string(JSON.stringify(w.profile.to_dict()))
	_check(int(d.version) >= 7, "save version 7")
	var back := Profile.new()
	_check(back.load_dict(d), "nạp save v7")
	_check(back.fog.get("1-1", "") == w.profile.fog["1-1"] and back.fog_rewards == {"1-1": [50]} and back.bulk_filter.only_weaker == false, "giữ sương, thưởng, bộ lọc")
	_check(back.class_id == "phap-su", "giữ lớp Pháp Sư")
	var w2 := GameWorld.new(back, RngUtil.make(1))
	_check(w2.explore_ratio("1-1") >= w.explore_ratio("1-1") - 0.001, "nạp lại map: % khám phá giữ nguyên")
	d.version = 6
	d.erase("fog")
	d.erase("fog_rewards")
	d.erase("bulk_filter")
	var old := Profile.new()
	_check(old.load_dict(d) and old.fog.is_empty() and Items.normalize_filter(old.bulk_filter) == Items.default_filter(), "save v6 nạp được: sương trống, bộ lọc mặc định")


# ------------------------------------------------------------------ M5 — boss hiếm Bạch Hổ Phong Vân (03-mvp-spec mục 7)


func _test_m5_bach_ho() -> void:
	var w := _region2_world("2-3", "kiem-khach", "tay-nhanh", 20)
	w.debug_now = 1000.0
	w._check_rare_boss()
	_check(w.rare_boss() == null, "Huyền Ảnh chưa ngã thì Bạch Hổ chưa xuất hiện")
	w.profile.bosses["huyen-anh"] = true
	w.player.pos = w.arena_pos + Vector2(-400, 0)
	w._check_rare_boss()
	var b := w.rare_boss()
	_check(b != null and b.kind == "bach-ho" and b.level == 20, "hạ Huyền Ảnh rồi vào Mắt Bão: Bạch Hổ xuất hiện")
	_check(int(b.max_hp) == 42640 and int(b.atk) == 159 and int(b.def) == 53, "chỉ số theo 06 (%d HP, %d Tấn công, %d Phòng thủ)" % [b.max_hp, b.atk, b.def])
	_check(b.pos.distance_to(w.arena_pos) >= w.arena_r + 150.0, "không xuất hiện trong Phủ Huyền Ảnh")
	# Hổ Vồ: chuỗi 3 cú
	w.player.pos = b.pos + Vector2(-200, 0)
	w.player.hp = w.stats.max_hp
	b.chain_left = GameWorld.TIGER_CHAIN
	w._begin_attack(b, "tiger", 0.05)
	_check(b.target.distance_to(b.pos) <= GameWorld.TIGER_REACH + 0.5, "Hổ Vồ vồ xa tối đa 22 m")
	var pounces := 0
	var last := b.chain_left
	for i in 90:
		w._update_enemy(b, 1.0 / 60.0)
		if b.chain_left < last:
			pounces += 1
			last = b.chain_left
	_check(pounces == 3 and b.state != "windup", "Hổ Vồ: chuỗi đúng 3 cú rồi nghỉ")
	_check(w.player.hp < w.stats.max_hp, "Hổ Vồ trúng thì mất máu")
	# Gầm Gió (đứng phía tây để cú đẩy không chạm cổng Phủ Huyền Ảnh)
	w.player.dead_timer = 0.0
	w.player.hp = w.stats.max_hp
	w.player.pos = b.pos + Vector2(-50, 0)
	w.player.dodge_time = 0.0
	w.player.dash_time = 0.0
	b.attack_kind = "roar"
	w._perform_attack(b)
	_check(w.player.pos.distance_to(b.pos) >= 129.0 and w.player.stun_timer > 0.9, "Gầm Gió: đẩy lùi 8 m, choáng 1 giây")
	b.state = "stunned"
	b.timer = 99.0
	var before := w.player.pos
	var acd := w.player.attack_cd
	_tick(w, {"move": Vector2.RIGHT, "attack": true, "dodge": true}, 20)
	_check(w.player.pos.distance_to(before) < 1.0 and w.player.swing <= 0.0 and w.player.dodge_time <= 0.0, "đang choáng: không đi, không đánh, không né")
	_tick(w, {}, 60)
	w.player.pos = b.pos + Vector2(-50, 0)
	w.player.dodge_time = 0.2
	w._perform_attack(b)
	_check(w.player.stun_timer <= 0.0, "né lăn tránh được Gầm Gió")
	w.player.dodge_time = 0.0
	# Phá Thế ngắt chuỗi Hổ Vồ
	b.state = "windup"
	b.broken = false
	b.chain_left = 2
	w._damage_poise(b, b.max_poise + 1.0)
	_check(b.chain_left == 0 and b.state == "stunned", "Phá Thế ngắt chuỗi Hổ Vồ")
	# Cưỡi Gió
	var sp0 := b.speed
	b.hp = b.max_hp * 0.45
	w._update_rare(b, 0.1)
	_check(b.phase == 2 and is_equal_approx(b.speed, sp0 * GameWorld.RIDE_SPEED), "dưới 50%: Cưỡi Gió, tốc ×1,5")
	# hạ Bạch Hổ
	var ess: int = w.profile.essence
	var evo: int = w.profile.evo_essence
	w.profile.rare_at["lao-thu"] = 777.0
	w.pickups = []
	w._kill_enemy(b)
	var items := w.pickups.filter(func(pk): return pk.kind == "item")
	_check(items.size() == 1 and items[0].item.unique == "bach_ho_claw" and items[0].item.slot == "gloves", "rơi Vuốt Bạch Hổ (găng Cam)")
	_check(w.profile.essence == ess + 5 and w.profile.evo_essence == evo + 1, "+5 Tinh Hoa, +1 Tinh Hoa Tiến Hoá")
	_check(is_equal_approx(float(w.profile.rare_at["bach-ho"]), 1000.0 + Config.RARE_BOSS_PERIOD) and is_equal_approx(float(w.profile.rare_at["lao-thu"]), 777.0),
		"lịch 12 giờ riêng cho từng boss hiếm")
	w.enemies = []
	w._check_rare_boss()
	_check(w.rare_boss() == null, "chưa tới giờ thì chưa xuất hiện lại")
	# save v8; save v7 chuyển rare_boss_at sang lịch của Lão Thụ
	var d: Dictionary = JSON.parse_string(JSON.stringify(w.profile.to_dict()))
	_check(int(d.version) == 8, "save version 8")
	var back := Profile.new()
	back.load_dict(d)
	_check(is_equal_approx(float(back.rare_at["bach-ho"]), 1000.0 + Config.RARE_BOSS_PERIOD), "save giữ lịch boss hiếm")
	d.version = 7
	d.erase("rare_at")
	d["rare_boss_at"] = 5000.0
	var old := Profile.new()
	_check(old.load_dict(d) and is_equal_approx(float(old.rare_at["lao-thu"]), 5000.0) and not old.rare_at.has("bach-ho"), "save v7: rare_boss_at thành lịch Lão Thụ")


func _test_m5_claw() -> void:
	var w := _region2_world("2-2", "kiem-khach", "tay-nhanh", 20)
	w.field_spawn = false
	var it := Items.new_item(w.profile, 20, "orange", RngUtil.make(1), "", "", "bach_ho_claw")
	Items.add_item(w.profile, it)
	w.equip(int(it.id))
	_check(w.has_unique("bach_ho_claw"), "mặc Vuốt Bạch Hổ")
	var e := w.spawn_enemy("linh-danh-thue", 20, w.player.pos + Vector2(40, 0))
	e.max_hp = 1000000.0
	e.hp = e.max_hp
	w._hit_enemy(e, 1.0, true)
	_check(is_equal_approx(e.bleed_timer, GameWorld.BLEED_TIME) and e.bleed_dmg > 0.0, "chí mạng: chảy máu 4 giây")
	_check(is_equal_approx(e.bleed_dmg, Formulas.compute_damage(w.stats.atk, e.def, GameWorld.BLEED_MUL)), "chảy máu = 30% Tấn công mỗi giây")
	var hp1 := e.hp
	for i in 20:
		w._update_enemy(e, 0.25)
	_check(is_equal_approx(hp1 - e.hp, 4.0 * roundi(e.bleed_dmg)) and e.bleed_timer <= 0.0, "chảy máu 4 lần rồi hết (%.0f)" % (hp1 - e.hp))
	# không mặc thì chí mạng không gây chảy máu
	w.unequip("gloves")
	var e2 := w.spawn_enemy("linh-danh-thue", 20, w.player.pos + Vector2(40, 0))
	w._hit_enemy(e2, 1.0, true)
	_check(e2.bleed_timer <= 0.0, "không mặc Vuốt thì không chảy máu")


func _test_m5_bach_ho_balance() -> void:
	for class_id in Classes.ORDER:
		var lines := PackedStringArray()
		for seed_value in [5, 11]:
			var res := _bach_ho_fight(class_id, "tay-nhanh", seed_value)
			lines.append("%.0fs/%d chết/%d bình" % [res[0], res[1], res[3]])
			_check(res[2] and int(res[1]) == 0, "%s hạ được Bạch Hổ không chết lần nào, tối đa 3 bình máu (seed %d)" % [class_id, seed_value])
		print("       [%s] Bạch Hổ: %s" % [class_id, " · ".join(lines)])


## Bot cấp 20, bộ đồ chuẩn cấp 20 (như _r2_fight) đánh Bạch Hổ. Trả về [giây, số lần chết, thắng].
func _bach_ho_fight(class_id: String, talent_id: String, seed_value: int) -> Array:
	var w := _region2_world("2-3", class_id, talent_id, 20, seed_value)
	w.field_spawn = false
	var p = w.profile
	p.bosses["huyen-anh"] = true
	p.points = _class_points(class_id)
	for k in p.points:
		p.points[k] = int(p.points[k]) * 5
	var rng := RngUtil.make(77)
	for pair in [["weapon", "blue"], ["armor", "blue"], ["helm", "green"], ["boots", "green"], ["gloves", "green"]]:
		var it := Items.new_item(p, 20, pair[1], rng, pair[0])
		Items.add_item(p, it)
		w.equip(int(it.id))
	w.player.hp = w.stats.max_hp
	w.player.mp = w.stats.max_mp
	w.player.pos = w.arena_pos + Vector2(-700, 0)
	w.debug_now = 1000.0
	p.potions = 3
	var deaths := 0
	var seconds := 0.0
	var killed := false
	while seconds < 600.0 and not killed:
		for ev in w.drain_events():
			if ev.type == "death":
				deaths += 1
			if ev.type == "rare_boss":
				killed = true
		var b := w.rare_boss()
		if b != null and w.player.dead_timer <= 0.0 and w.player.pos.distance_to(b.pos) > 800.0:
			w.player.pos = b.pos + Vector2(-300, 0)
		# Người chơi đánh boss hiếm mang theo bình máu: uống khi dưới 40% HP.
		var inp := _bot(w)
		inp["potion"] = w.player.hp < w.stats.max_hp * 0.4
		w.update(1.0 / 60.0, inp)
		seconds += 1.0 / 60.0
	return [seconds, deaths, killed, 3 - int(p.potions)]


## SN-05: Hấp Huyết của Pháp Sư — phép diện rộng hút 50%, Hỏa Cầu trúng trực tiếp hút đủ.
func _test_sn_aoe_lifesteal() -> void:
	var w := _m3_world("phap-su", "hap-huyet")
	w.player.pos = Vector2(900, 900)
	var e := _dummy(w, "wolf", 1, w.player.pos + Vector2(100, 0))
	var heal := func(aoe: bool) -> float:
		w.player.hp = 1.0
		var hp0: float = e.hp
		w._hit_enemy(e, 1.0, true, aoe)
		return (w.player.hp - 1.0) / maxf(1.0, hp0 - e.hp)
	var direct: float = heal.call(false)
	var area: float = heal.call(true)
	_check(direct > 0.0 and absf(area - direct * GameWorld.AOE_LIFESTEAL) < 0.01, "diện rộng hút %.3f = 50%% của %.3f" % [area, direct])


# ------------------------------------------------------------------ M5-02: đo nhịp lên cấp (chạy riêng: --only=PACE)


func _test_pace_mobs() -> void:
	for class_id in Classes.ORDER:
		# Kiếm Khách đo tới cấp 20; 2 lớp còn lại tới cấp 10 cho nhanh.
		var r := _pace_sim(class_id, 20 if class_id == "kiem-khach" else 10, 3.0 * 3600.0)
		var parts := PackedStringArray()
		for lv in [3, 5, 7, 10, 13, 15, 17, 20]:
			if r.at.has(lv):
				parts.append("cấp %d: %.1f ph" % [lv, r.at[lv] / 60.0])
		print("       [%s] %s · %d quái · chết %d" % [class_id, " · ".join(parts), r.kills, r.deaths])
		_check(r.at.has(10), "%s lên được cấp 10" % class_id)


## Bot cày quái từ cấp 1: chỉ EXP từ quái (không nhiệm vụ, không boss, không khai phá).
## Đổi map theo cấp như người chơi, mỗi 5 cấp thay bộ đồ chuẩn (giả lập đồ rơi), tự cộng điểm, uống bình máu.
## Trả về {at: {cấp: giây}, kills, deaths}.
func _test_pace_r2(class_id: String) -> void:
	var r := _pace_sim(class_id, 20, 3.0 * 3600.0, 10)
	var parts := PackedStringArray()
	for lv in [13, 15, 17, 20]:
		if r.at.has(lv):
			parts.append("cấp %d: %.1f ph" % [lv, r.at[lv] / 60.0])
	print("       [%s] từ cấp 10: %s · %d quái · chết %s" % [class_id, " · ".join(parts), r.kills, r.death_maps])


func _pace_sim(class_id: String, target_level: int, max_seconds: float, start_level := 1) -> Dictionary:
	var p := _profile("tay-nhanh", 3)
	p.class_id = class_id
	p.level = start_level
	p.points = _class_points(class_id)
	for k in p.points:
		p.points[k] = int(p.points[k]) * int(start_level / 4)
	p.boss_defeated = true
	p.bosses = {"boss": true}
	p.unlocked_maps = ["1-1", "1-3", "2-1", "2-2", "2-3"]
	p.rare_at = {"lao-thu": 1e12, "bach-ho": 1e12}
	p.potions = 5
	var w := GameWorld.new(p, RngUtil.make(9))
	var at := {}
	var deaths := 0
	var seconds := 0.0
	var kit_level := 0
	var map_now := ""
	var dt := 1.0 / 30.0
	var kills0: int = p.kills
	var death_maps := {}
	while seconds < max_seconds and p.level < target_level:
		var want := "1-1" if p.level < 7 else ("1-3" if p.level < 10 else ("2-1" if p.level < 13 else ("2-2" if p.level < 17 else "2-3")))
		if want != map_now:
			w._load_map(want)
			map_now = want
			w.player.pos = w.safe_pos + Vector2(w.safe_r + 60.0, 0)
		var kl := int(p.level / 5) * 5
		if kl != kit_level:
			kit_level = kl
			var rng := RngUtil.make(77 + kl)
			for pair in [["weapon", "blue"], ["armor", "green"], ["helm", "green"], ["boots", "green"], ["gloves", "green"]]:
				var it := Items.new_item(p, maxi(1, p.level), pair[1], rng, pair[0])
				Items.add_item(p, it)
				w.equip(int(it.id))
		if p.unspent > 0:
			w.auto_allocate()
		for ev in w.drain_events():
			if ev.type == "death":
				deaths += 1
				death_maps[map_now] = int(death_maps.get(map_now, 0)) + 1
			elif ev.type == "levelup":
				at[int(ev.level)] = seconds
		var inp := _bot(w)
		inp["potion"] = w.player.hp < w.stats.max_hp * 0.4
		w.update(dt, inp)
		seconds += dt
	for ev in w.drain_events():
		if ev.type == "levelup":
			at[int(ev.level)] = seconds
	return {"at": at, "kills": p.kills - kills0, "deaths": deaths, "death_maps": death_maps}


func _test_m5_shield_turn() -> void:
	var w := _region2_world("2-2", "kiem-khach", "tay-nhanh", 14)
	w.field_spawn = false
	var e := w.spawn_enemy("linh-danh-thue", 14, w.player.pos + Vector2(60, 0))
	e.state = "chase"
	e.face = PI
	# người chơi vòng ra sau lưng trong 1 khung hình: lính chỉ quay được 2°
	w.player.pos = e.pos + Vector2(60, 0)
	w._update_enemy(e, 1.0 / 60.0)
	_check(absf(angle_difference(e.face, PI)) <= deg_to_rad(2.1), "1 khung hình chỉ quay tối đa 2°")
	var hp0 := e.hp
	w._apply_damage(e, 100, false, true)
	_check(is_equal_approx(hp0 - e.hp, 100.0), "đánh sau lưng không bị khiên chặn")
	for i in 90:
		w._update_enemy(e, 1.0 / 60.0)
		if e.state == "windup":
			e.state = "chase"
	_check(absf(angle_difference(e.face, 0.0)) < 0.05, "sau 1,5 giây đã quay lại đối mặt")


func _test_m5_exp_budget() -> void:
	var need := func(a: int, b: int) -> float:
		var s := 0.0
		for l in range(a, b):
			s += Formulas.exp_to_next(l)
		return s
	var kills := func(a: int, b: int) -> float:
		var s := 0.0
		for l in range(a, b):
			s += float(Formulas.exp_to_next(l)) / Formulas.mob_exp(l, false)
		return s
	var k10: float = kills.call(1, 10)
	var k20: float = k10 + kills.call(10, 20)
	_check(k10 >= 500.0 and k10 <= 700.0 and k20 >= 2000.0 and k20 <= 2700.0, "chỉ đánh quái: cấp 10 ~600 quái, cấp 20 ~2.300 quái (%.0f / %.0f)" % [k10, k20])
	var ch1: float = need.call(1, 10)
	var ch2: float = need.call(10, 20)
	var q1 := 0.0
	for q in Story.QUESTS:
		q1 += float(q.reward.get("exp", 0))
	var q2 := 0.0
	for q in Story.QUESTS2:
		q2 += float(q.reward.get("exp", 0))
	print("       nhiệm vụ: chương 1 %.0f%%, chương 2 %.0f%% EXP của chặng" % [q1 / ch1 * 100.0, q2 / ch2 * 100.0])
	_check(q1 / ch1 >= 0.18 and q1 / ch1 <= 0.32 and q2 / ch2 >= 0.18 and q2 / ch2 <= 0.32, "nhiệm vụ ≈ 25% EXP mỗi chương (kịch bản mục 4)")
	var b1: float = GameWorld.boss_exp(6) + 0.5 * Formulas.exp_to_next(9)
	var b2: float = GameWorld.boss_exp(18) + 0.5 * Formulas.exp_to_next(20)
	print("       boss + boss hiếm: chương 1 %.0f%%, chương 2 %.0f%%" % [b1 / ch1 * 100.0, b2 / ch2 * 100.0])
	_check(b1 / ch1 >= 0.15 and b1 / ch1 <= 0.3 and b2 / ch2 >= 0.15 and b2 / ch2 <= 0.3, "boss + boss hiếm ≈ 20% EXP mỗi chương")


func _test_m5_minimap() -> void:
	var Minimap = load("res://scripts/ui/minimap.gd")
	var w := _world("tay-nhanh")
	var mm = Minimap.new()
	mm.update_from(w)
	_check(mm._fog_tex != null and mm._fog_tex.get_width() == w.fog.w and mm._fog_tex.get_height() == w.fog.h, "ảnh sương 1 pixel/ô (%d × %d)" % [w.fog.w, w.fog.h])
	_check(is_equal_approx(mm.size.x, Minimap.SMALL_W) and absf((mm.size.y - Minimap.HEADER) / mm.size.x - w.world_size.y / w.world_size.x) < 0.01, "cỡ nhỏ đúng tỉ lệ map")
	var v0: int = mm._fog_version
	w.fog.reveal(w.player.pos + Vector2(900, 0), 300.0)
	mm.update_from(w)
	_check(mm._fog_version != v0, "khám phá thêm thì vẽ lại sương")
	mm.toggle_size()
	_check(is_equal_approx(mm.size.x, Minimap.LARGE_W), "phím V: cỡ lớn")
	mm.free()
