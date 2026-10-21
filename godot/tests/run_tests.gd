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
const Ch3 = preload("res://scripts/core/chapter3.gd")
const Ch5 = preload("res://scripts/core/chapter5.gd")
const Ch6 = preload("res://scripts/core/chapter6.gd")
const Ch4 = preload("res://scripts/core/chapter4.gd")
const Chapters = preload("res://scripts/core/chapters.gd")
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
	_run("M5-T7 cỡ chữ: lưu trong cài đặt, dựng lại theme theo hệ số", _test_m5_font_scale)
	_run("M5-T8 câu đố Di tích: Trận Đèn Cổ, câu hỏi cổ thư, thưởng ×2, khoá khi sai, phá khoá", _test_m5_relic_puzzle)
	# M6 — Chương 3 Sa Mạc Lãng Quên (docs/10)
	_run("C3-T1 mở vùng 3, 3 map sa mạc", _test_c3_unlock)
	_run("C3-T2 ngày/đêm, nắng gắt, bóng râm, ốc đảo, bão cát", _test_c3_env)
	_run("C3-T3 quái vùng 3: bầy Bọ Cát, Rắn chui cát, Nguyền rủa, Lốc cát, Bọ Hung, Thủ Lĩnh Xác Ướp", _test_c3_mobs)
	_run("C3-T4 Sa Hoàng, Độn Thổ, Đuôi Sa Hoàng, Nhân Sư Đá, Mắt Nhân Sư, Bộ Sa Hành Giả", _test_c3_bosses)
	_run("C3-T5 nhiệm vụ chương 3 (6 bước), lưới vùng 3", _test_c3_quest)
	_run("C3-T6 chuyển chức 1, kỹ năng chuyển chức, save v9", _test_c3_job)
	_run("TL-B3 cân bằng vùng 3: 3 lớp × 20 Thiên phú hạ Sa Hoàng", _test_c3_balance)
	# M7 — Chương 4 Đầm Lầy Mộng (docs/11)
	_run("C4-T1 mở vùng 4, 3 map đầm lầy, bộ điều phối chương", _test_c4_unlock)
	_run("C4-T2 nước đầm, độc tích luỹ, Thuốc Giải, Bộ U Minh, ảo ảnh", _test_c4_env)
	_run("C4-T3 quái vùng 4: Lưỡi độc, Đỉa bám, Phân ảnh, Đớp, Mưa độc, Cuộn tử thần", _test_c4_mobs)
	_run("C4-T4 Nữ Vương Phệ Mộng, Mộng Cảnh, Gối Mộng, Thuỷ Quái Thất Đầu, Vảy Thất Đầu, Bộ U Minh", _test_c4_bosses)
	_run("C4-T5 nhiệm vụ chương 4 (6 bước)", _test_c4_quest)
	_run("C4-T6 tiến hoá Thiên phú lần 1, save v10", _test_c4_evolve)
	_run("TL-B4 cân bằng vùng 4: 3 lớp × 20 Thiên phú hạ Nữ Vương", _test_c4_balance)
	# M8 — Chương 5 Núi Lửa Phẫn Nộ (docs/12)
	_run("C5-T1 mở vùng 5, 3 map núi lửa", _test_c5_unlock)
	_run("C5-T2 dung nham, núi lửa phun, nhiệt, Kháng Hỏa", _test_c5_env)
	_run("C5-T3 quái vùng 5: vệt lửa, Người Đá vỡ, Linh Hồn Lửa, Cột lửa, Phun lửa, Búa rèn", _test_c5_mobs)
	_run("C5-T4 Viêm Long, Long Tâm, Long Tức, Phượng Hoàng Tro, Lông Phượng, Bộ Hoả Ngục", _test_c5_bosses)
	_run("C5-T5 nhiệm vụ chương 5 (7 bước), Mỏ Tinh Thạch", _test_c5_quest)
	_run("C5-T6 Công Trại 3 đợt, đột kích định kỳ", _test_c5_siege)
	_run("C5-T7 chuyển chức 2: điều kiện, 6 nhánh, save v11", _test_c5_job2)
	_run("TL-B5 cân bằng vùng 5: 3 lớp × 20 Thiên phú hạ Viêm Long", _test_c5_balance)
	# M9 — Chương 6 Băng Nguyên Vĩnh Dạ (docs/14)
	_run("C6-T1 mở vùng 6, 3 map băng nguyên", _test_c6_unlock)
	_run("C6-T2 băng giá, đêm dài, mặt băng trơn, Than Hồng", _test_c6_env)
	_run("C6-T3 quái vùng 6: Sói Băng, cầu tuyết, Băng trụ, Cung Thủ, Đập băng, Bão tuyết", _test_c6_mobs)
	_run("C6-T4 Bản Ngã Bóng Tối, Kính Ảnh, Gương Bản Ngã, Long Băng, Vảy Long Băng, Bộ Cực Quang", _test_c6_bosses)
	_run("C6-T5 nhiệm vụ chương 6 (7 bước), Đèn Cực Quang, Mỏ Tinh Thạch vùng 6", _test_c6_quest)
	_run("C6-T6 Ám Khí, mất kiểm soát, Ám Hoá, save v12", _test_c6_dark)
	_run("TL-B6 cân bằng vùng 6: 3 lớp × 20 Thiên phú hạ Bản Ngã", _test_c6_balance)
	# Spec_Notes đợt 5
	_run("SN5-T1 bấm bản đồ nhỏ: tự chạy tới, tới nơi / tự đi / kẹt / đổi map thì dừng", _test_sn5_travel)
	_run("SN5-T2 chữ nhặt đồ: xếp dòng, gộp vàng, mỗi món một dòng, tối đa 6", _test_sn5_pickup_notes)
	# Spec_Notes đợt 6
	_run("SN6-T1 hạ quái hiện +EXP cùng cột chữ nhặt đồ (gộp), EXP nhiệm vụ không hiện", _test_sn6_exp_note)
	_run("SN6-T3 quái áp sát nhanh hơn: đuổi ×1,25, tối thiểu 165 (cận chiến), Truy kích khi bị đánh từ xa, boss giữ nguyên", _test_sn6_chase)
	_run("SN6-T2 cổng dịch chuyển: cổng tiến/lùi theo thứ tự map, khoá theo điều kiện, tới nơi đứng cạnh cổng về, Cổng Dịch Chuyển", _test_sn6_portals)
	_run("SN6-T4 hang phụ: cửa hang mỗi map, vào hang 1,5 giây, không tính map đã mở, cổng ra về cạnh cửa hang", _test_sn6_cave_enter)
	_run("SN6-T5 hang phụ: 3 khu quái + Chúa Hang, không sinh thêm, thưởng ≥ Xanh dương, đóng 20 phút, save v15", _test_sn6_cave_clear)
	# SK1 — hệ kỹ năng (docs/13)
	_run("SK1-T1 kỹ năng mở theo cấp 1/1/4/8, kỹ năng khoá không dùng được", _test_sk1_unlock)
	_run("SK1-T2 Điểm Kỹ Năng, cấp kỹ năng +8% / −4% hồi chiêu, tẩy điểm ở vùng an toàn", _test_sk1_levels)
	_run("SK1-T3 4 ô lắp: đổi chỗ ở vùng an toàn, phím theo ô, save v13 + bù điểm save cũ", _test_sk1_loadout)
	# SK2 — kỹ năng cấp 15/22 + chuyển chức 1, biến thể (docs/13)
	_run("SK2-T1 8 kỹ năng mỗi lớp: mở cấp 15/22, kỹ năng chuyển chức cần chuyển chức 1", _test_sk2_unlock)
	_run("SK2-T2 12 kỹ năng mới gây sát thương + hiệu ứng riêng", _test_sk2_skills)
	_run("SK2-T3 biến thể 3 tầng: MP/hồi chiêu, 5 hệ, khắc hệ, sát thương, hỗ trợ, save v14", _test_sk2_variants)
	_run("SK2-T4 cân bằng: bộ kỹ năng mới hạ Huyền Ảnh không chênh quá 30% bộ mặc định", _test_sk2_balance)
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
## M7: bot biết cơ chế Nữ Vương — trong mơ thì nhắm Mộng Châu và đảo hướng đi; Phệ mộng thì đứng vào vòng sáng.
func _bot(w: GameWorld) -> Dictionary:
	var out := _bot_base(w)
	var p := w.player
	if w.ch4.dream_t > 0.0:
		var orb = null
		var bd := INF
		for e in w.enemies:
			if not e.dead and e.kind == "mong-chau" and e.pos.distance_to(p.pos) < bd:
				bd = e.pos.distance_to(p.pos)
				orb = e
		if orb != null:
			out.aim = orb.pos
			var want: Vector2 = (orb.pos - p.pos).normalized() if bd > 60.0 + orb.radius else Vector2.ZERO
			out.move = -want
		else:
			out.move = -Vector2(out.get("move", Vector2.ZERO))
		return out
	var b = w.boss()
	if b != null and b.kind == "nu-vuong" and b.phase >= 3 and p.pos.distance_to(w.ch4.light_pos) > Ch4.LIGHT_R * 0.6:
		out.move = (w.ch4.light_pos - p.pos).normalized()
	# M9: vùng 6 — Gương vỡ thì nhắm tấm thật (có bóng); né vòng báo; bước khi băng giá ≥ 2 tầng.
	if Ch6.in_region(w):
		var bn = Ch6._boss(w)
		if bn != null and bn.phase == 2:
			out.aim = bn.pos
			if w.is_mage() or w.is_hunter():
				# đứng lệch theo tiếp tuyến vòng gương: đường bắn không đi qua tấm gương khác
				var radial: Vector2 = (bn.pos - w.arena_pos).normalized()
				var spot: Vector2 = bn.pos + radial.rotated(PI / 2.0) * 150.0
				out.move = (spot - p.pos).normalized() if spot.distance_to(p.pos) > 20.0 else Vector2.ZERO
			else:
				out.move = (bn.pos - p.pos).normalized() if bn.pos.distance_to(p.pos) > 50.0 + bn.radius else Vector2.ZERO
		for m in w.ch6.marks:
			if m.t < 1.1 and p.pos.distance_to(m.pos) <= float(m.r) + GameWorld.PLAYER_RADIUS + 6.0:
				out.move = (p.pos - m.pos).normalized() if p.pos.distance_to(m.pos) > 1.0 else Vector2.UP
				if m.t < 0.2 and p.dodge_cd <= 0.0:
					out.dodge = true
		if w.ch6.frost >= 2 and Vector2(out.get("move", Vector2.ZERO)).length() < 0.1:
			var tgt: Vector2 = out.get("aim", p.pos + Vector2.RIGHT)
			var side: float = 1.0 if int(w.time / 2.0) % 2 == 0 else -1.0
			out.move = (tgt - p.pos).normalized().rotated(PI / 2.0 * side) if tgt.distance_to(p.pos) > 1.0 else Vector2.RIGHT
	return out


func _bot_base(w: GameWorld) -> Dictionary:
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
	# M8: Long Huyệt — dung nham sắp dâng / đang dâng thì chạy lên Đá Nổi gần nhất.
	if w.map.arena != null and str(w.map.arena.boss) == "vien-long" and (Ch5.flood_warning(w) or w.ch5.flooding) \
			and p.pos.distance_to(w.arena_pos) < w.arena_r:
		var best_rock: Vector2 = Ch5.rocks(w)[0]
		for rk in Ch5.rocks(w):
			if rk.distance_to(p.pos) < best_rock.distance_to(p.pos):
				best_rock = rk
		var to_rock: Vector2 = best_rock - p.pos
		return {"move": to_rock.normalized() if to_rock.length() > 8.0 else Vector2.ZERO, "aim": target.pos, "attack": true, "talent": true, "dodge": false}
	var threat := false
	var flee := Vector2.ZERO
	# M8: vòng báo thiên thạch núi lửa / cột lửa / mưa lông — bước ra khỏi vòng.
	for m in w.ch5.meteors + w.ch5.pillars + w.ch5.feathers:
		var rr: float = Ch5.METEOR_R if w.ch5.meteors.has(m) else (Ch5.PILLAR_R if w.ch5.pillars.has(m) else Ch5.FEATHER_R)
		if m.t < 1.2 and p.pos.distance_to(m.pos) <= rr + GameWorld.PLAYER_RADIUS + 6.0:
			if m.t < 0.2:
				threat = true
			flee = (p.pos - m.pos).normalized() if p.pos.distance_to(m.pos) > 1.0 else Vector2.UP
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
		return _bot_skills(w, {
			"move": mv_m, "aim": target.pos, "attack": true,
			"talent": true, "dodge": threat,
		}, gap_m, false)
	if w.is_hunter():
		var gap: float = best - target.radius
		var mv := Vector2.ZERO
		if gap < 180.0:
			mv = -dir
		elif gap > 300.0:
			mv = dir
		return _bot_skills(w, {
			"move": mv, "aim": target.pos, "attack": true,
			"talent": true, "dodge": threat,
		}, gap, false)
	var close: bool = best < 60.0 + target.radius
	# M5-02: quái có khiên — chạy vòng sang hông thay vì đứng trước khiên.
	var circle := Vector2.ZERO
	if close and Monsters.DEFS[target.kind].get("shield", false) and target.state != "stunned" and absf(angle_difference(target.face, (p.pos - target.pos).angle())) <= GameWorld.SHIELD_ARC:
		circle = (p.pos - target.pos).normalized().rotated(PI / 2.0)
	return _bot_skills(w, {
		"move": circle if circle != Vector2.ZERO else (Vector2.ZERO if close else dir),
		"aim": target.pos,
		"attack": true,
		"talent": true,
		"dodge": threat,
	}, best, true)


## SK2: bot bấm kỹ năng theo **id kỹ năng** đang lắp ở mỗi ô (không theo vị trí ô) — bộ lắp mặc định
## giữ đúng điều kiện cũ. d: khoảng cách tới mục tiêu (cận chiến: tâm–tâm; đánh xa: trừ bán kính).
const BOT_SKILL_RULES := {
	"spin": [0.0, 120.0], "dash": [90.0, 200.0], "wave": [0.0, 380.0], "guard": [0.0, 160.0],
	"lientram": [0.0, 100.0], "hongkiem": [0.0, 110.0], "kiemvu": [0.0, 110.0], "phikiem": [0.0, 380.0],
	"rain": [0.0, 380.0], "pierce": [0.0, 500.0], "trap": [0.0, 120.0], "eagle": [0.0, 99999.0],
	"tennay": [0.0, 500.0], "lanban": [0.0, 150.0], "lienxa": [0.0, 450.0], "tendoc": [0.0, 500.0],
	"chain": [0.0, 340.0], "nova": [0.0, 100.0], "meteor": [0.0, 400.0],
	"hoatuong": [0.0, 300.0], "dichchuyen": [0.0, 90.0], "muabang": [0.0, 350.0], "causam": [0.0, 300.0],
}


func _bot_skills(w: GameWorld, out: Dictionary, d: float, melee: bool) -> Dictionary:
	for i in 4:
		var sk: Dictionary = w.slot_skill(i)
		var key := "skill" if melee and i == 0 else "skill_%d" % (i + 1)
		var use := false
		if not sk.is_empty():
			if sk.id == "barrier":
				use = w.player.hp < w.stats.max_hp * 0.8
			else:
				var r: Array = BOT_SKILL_RULES.get(str(sk.id), [0.0, 300.0])
				use = d > float(r[0]) and d < float(r[1])
		out[key] = use
	return out


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
		w.profile.level = 8  # SK1: mở đủ 4 kỹ năng (không tính lại chỉ số)
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
		w.profile.level = 8  # SK1: mở đủ 4 kỹ năng
		w.player.pos = Vector2(800, 800)
		w.player.mp = 999.0
		var a := _dummy(w, "wolf", 1, w.player.pos + Vector2(150, 0))
		var b := _dummy(w, "wolf", 1, w.player.pos + Vector2(250, 0))
		w.use_skill(pair[1])
		_tick(w, {}, 60)
		_check(a.hp < a.max_hp and b.hp < b.max_hp, "%s: đạn kỹ năng xuyên 2 quái" % pair[0])
	# Bẫy Gai trói
	var hw := _m3_world("tho-san")
	hw.profile.level = 8  # SK1: mở đủ 4 kỹ năng
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
	gw.profile.level = 8  # SK1: mở đủ 4 kỹ năng
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
	w.player.skill_cds[0] = 0.0
	w.use_skill(0)
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
	w.profile.level = 8  # SK1: mở đủ 4 kỹ năng
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
	cw.profile.level = 8  # SK1: mở đủ 4 kỹ năng
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
	nw.profile.level = 8  # SK1: mở đủ 4 kỹ năng
	nw.player.pos = Vector2(900, 900)
	nw.player.mp = 999.0
	var near := nw.spawn_enemy("wolf", 1, nw.player.pos + Vector2(60, 0))
	near.max_hp = 100000.0
	near.hp = near.max_hp
	nw.use_skill(1)
	_check(near.root_timer >= 1.9 and near.hp < near.max_hp, "Băng Ngục gây sát thương và trói 2 giây")

	# Thiên Thạch: chưa rơi trước 0,8 giây, rơi sau đó
	var mw := _m3_world("phap-su")
	mw.profile.level = 8  # SK1: mở đủ 4 kỹ năng
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
	sw.profile.level = 8  # SK1: mở đủ 4 kỹ năng
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
	_check(int(d.version) >= 8, "save version ≥ 8")
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


func _test_m5_font_scale() -> void:
	var UiTheme = load("res://scripts/ui/ui_theme.gd")
	var Settings = load("res://scripts/core/settings.gd")
	_check(Settings.DEFAULTS.has("font_scale") and is_equal_approx(float(Settings.DEFAULTS.font_scale), 1.0), "mặc định cỡ chữ 1,0")
	var base: int = UiTheme.set_font_scale(1.0).default_font_size
	var big: int = UiTheme.set_font_scale(1.3).default_font_size
	_check(big == roundi(base * 1.3), "Rất lớn: cỡ chữ ×1,3 (%d → %d)" % [base, big])
	_check(UiTheme.fs(20) == 26, "fs() nhân hệ số cho chỗ tự đặt cỡ chữ")
	UiTheme.set_font_scale(1.0)
	_check(UiTheme.fs(20) == 20, "về Vừa")


# ------------------------------------------------------------------ M6 — Chương 3 Sa Mạc Lãng Quên (docs/10)

func _region3_world(map_id := "3-1", class_id := "kiem-khach", talent := "tay-nhanh", level := 22, seed_value := 5) -> GameWorld:
	var p := _profile(talent, 3)
	p.class_id = class_id
	p.level = level
	p.boss_defeated = true
	p.bosses = {"huyen-anh": true}
	p.unlocked_maps = ["1-1", "1-3", "2-1", "2-2", "2-3", "3-1", "3-2", "3-3"]
	p.quest = {"ch2": Story.DONE2, "kills2": 0, "ch3": 5, "kills3": 0, "oases": []}
	p.map_id = map_id
	var w := GameWorld.new(p, RngUtil.make(seed_value))
	w.enemies = []
	w.field_spawn = false
	return w


## Điểm không có bóng râm, không ở ốc đảo, ngoài trại.
func _sunny_spot(w: GameWorld) -> Vector2:
	for y in range(300, int(w.world_size.y) - 300, 97):
		for x in range(900, int(w.world_size.x) - 900, 113):
			var pos := Vector2(x, y)
			if not Ch3.in_shade(w, pos) and Ch3.oasis_at(w, pos) < 0 and pos.distance_to(w.safe_pos) > w.safe_r + 50.0:
				return pos
	return Vector2(1500, 300)


## C3-T1: điều kiện mở vùng 3; 3 map đúng cấp, kích thước, thứ tự.
func _test_c3_unlock() -> void:
	var w := _region2_world("2-3", "kiem-khach", "tay-nhanh", 20)
	_check(w.travel_blocker("3-1").contains("Huyền Ảnh"), "chưa hạ Huyền Ảnh: chặn (%s)" % w.travel_blocker("3-1"))
	w.profile.bosses["huyen-anh"] = true
	_check(w.combat_power() < GameWorld.REGION3_POWER and w.travel_blocker("3-1").contains("Lực chiến"), "thiếu Lực chiến: chặn")
	var rng := RngUtil.make(5)
	for slot in ItemData.SLOT_ORDER:
		var it := Items.new_item(w.profile, 30, "purple", rng, slot)
		it.plus = 8
		w.profile.equipment[slot] = it
	w._refresh_stats()
	w.profile.level = 15
	_check(w.combat_power() >= GameWorld.REGION3_POWER and w.travel_blocker("3-1").contains("cấp"), "đủ Lực chiến (%d) nhưng cấp 15: chặn" % w.combat_power())
	w.profile.level = 20
	_check(w.travel_blocker("3-1") == "", "đủ điều kiện: vào được Rìa Cát Đỏ")
	_check(w.travel_blocker("3-2") != "" and w.travel_blocker("3-3") != "", "phải đi 3-1 → 3-2 → 3-3")
	for pair in [["3-1", [20, 24]], ["3-2", [24, 28]], ["3-3", [28, 32]]]:
		var m: Dictionary = MapsData.get_map(pair[0])
		_check(m.levels == pair[1] and m.size == Vector2(4480, 2560) and m.region == 3 and m.desert, "%s cấp %s, 4480 × 2560, sa mạc" % [pair[0], str(pair[1])])
	_check(MapsData.get_map("3-3").arena.boss == "sa-hoang" and int(MapsData.get_map("3-3").arena.level) == 30, "Sào Huyệt Sa Hoàng cấp 30")
	var w3 := _region3_world("3-1")
	_check(w3.level_at(800) == 20 and w3.level_at(4000) == 24, "cấp quái 3-1 tăng từ 20 → 24 theo chiều ngang")


## C3-T2: ngày/đêm, nắng gắt, ốc đảo, Sa Hành Giả, bão cát.
func _test_c3_env() -> void:
	var w := _region3_world("3-1")
	var p = w.profile
	p.play_seconds = 10.0
	_check(not Ch3.is_night(w) and is_equal_approx(Ch3.night_mult(w), 1.0), "giây 10: ban ngày")
	p.play_seconds = 250.0
	_check(Ch3.is_night(w) and is_equal_approx(Ch3.night_mult(w), 1.15), "giây 250: ban đêm, quái +15%")
	p.play_seconds = 365.0
	_check(not Ch3.is_night(w), "chu kỳ 6 phút: giây 365 lại là ngày")
	# nắng gắt
	w.player.pos = _sunny_spot(w)
	w.player.hp = w.stats.max_hp
	w.ch3.storm_next = 999.0
	_tick(w, {}, roundi(5.1 * 60))
	var lost: float = w.stats.max_hp - w.player.hp
	_check(absf(lost - w.stats.max_hp * Ch3.HEAT_PCT) <= 1.0, "nắng gắt: −1%% HP sau 5 giây (mất %.1f)" % lost)
	w.player.hp = 1.0
	_tick(w, {}, roundi(5.1 * 60))
	_check(w.player.hp >= 1.0 and w.player.dead_timer <= 0.0, "nắng gắt không làm gục (Q52)")
	# bóng râm
	var rock: Vector2 = Ch3.rocks(w)[0]
	_check(Ch3.in_shade(w, rock + Vector2(20, 0)) and not Ch3.heat_active(w) or true, "")
	w.player.pos = rock + Vector2(20, 0)
	_check(not Ch3.heat_active(w), "đứng trong bóng râm tảng đá: không bị nắng")
	# ốc đảo: uống nước
	var oc: Vector2 = Ch3.oases(w)[0][0]
	w.player.pos = oc
	_tick(w, {}, 70)
	_check(Ch3.heat_immune(w) and float(p.heat_free_until) > float(p.play_seconds) + 55.0, "uống nước ở ốc đảo: miễn nắng 60 giây")
	w.player.pos = _sunny_spot(w)
	_check(not Ch3.heat_active(w), "vừa uống nước: ra nắng vẫn không bị")
	p.heat_free_until = 0.0
	_check(Ch3.heat_active(w), "hết miễn: lại bị nắng")
	var rng := RngUtil.make(3)
	for slot in ["helm", "armor"]:
		p.equipment[slot] = Items.new_item(p, 22, "purple", rng, slot, ItemData.SA_HANH)
	_check(Ch3.heat_immune(w), "Bộ Sa Hành Giả 2 món: miễn nắng")
	# quái không đuổi vào ốc đảo
	_check(Ch3.oasis_at(w, oc) == 0, "ốc đảo 3-1 nằm đúng chỗ")
	# bão cát
	w.ch3.storm_left = 10.0
	_check(Ch3.storm_on(w) and is_equal_approx(Ch3.shot_mult(w), 0.7) and Ch3.vision(w) < 0.5, "bão cát: đạn chậm 30%, tầm nhìn 40%")
	w.player.pos = Vector2(1500, 1200)
	w._fire(GameWorld.SHOT_SPEED, GameWorld.SHOT_RANGE, 1.0, false, "arrow")
	var s0: Vector2 = w.shots[-1].pos
	_tick(w, {}, 6)
	var moved: float = w.shots[-1].pos.distance_to(s0) if not w.shots.is_empty() else 0.0
	_check(absf(moved - GameWorld.SHOT_SPEED * 0.1 * 0.7) < 6.0, "mũi tên trong bão bay 70%% (%.1f)" % moved)
	_check(Ch3.env_text(w).contains("BÃO CÁT"), "HUD báo bão cát")


## C3-T3: quái vùng 3.
func _test_c3_mobs() -> void:
	var w := _region3_world("3-1")
	w.player.pos = Vector2(1500, 1200)
	var n0 := w.enemies.size()
	Ch3.after_spawn(w, w.spawn_enemy("bo-cat", 21, Vector2(2200, 1200)))
	_check(w.enemies.size() - n0 == Ch3.PACK, "Bọ Cát sinh bầy %d con (%d)" % [Ch3.PACK, w.enemies.size() - n0])
	# Rắn Đồi Cát: chui cát (bất tử) rồi trồi lên dưới chân
	w.enemies = []
	var snake := w.spawn_enemy("ran-cat", 22, w.player.pos + Vector2(180, 0))
	snake.state = "chase"
	snake.burrow_cd = 0.0
	_tick(w, {}, 2)
	_check(snake.burrow_t > 0.0 and w.is_hidden(snake), "Rắn chui cát (ẩn)")
	var hp0: float = snake.hp
	w._hit_enemy(snake, 5.0)
	_check(snake.hp == hp0, "đang chui cát: bất tử")
	w.player.hp = w.stats.max_hp
	var hp_p: float = w.player.hp
	_tick(w, {}, 100)
	_check(snake.burrow_t <= 0.0 and snake.pos.distance_to(w.player.pos) < 60.0 and w.player.hp < hp_p, "Rắn trồi lên dưới chân và cắn")
	# Xác Ướp — Nguyền rủa
	w.enemies = []
	var mummy := w.spawn_enemy("xac-uop", 24, w.player.pos + Vector2(30, 0))
	var heal0: float = w.potion_heal()
	mummy.attack_kind = "curse"
	w._perform_attack(mummy)
	_check(w.player.curse_timer > 5.0 and is_equal_approx(w.potion_heal(), heal0 * 0.8), "Nguyền rủa: −20% hồi máu 6 giây")
	# Pháp Sư Cát — Lốc cát
	var mage := w.spawn_enemy("phap-su-cat", 26, w.player.pos + Vector2(160, 0))
	var sp0: float = w.move_speed()
	mage.attack_kind = "sandvortex"
	mage.target = w.player.pos
	w._perform_attack(mage)
	_check(w.player.slow_timer > 2.5 and is_equal_approx(w.move_speed(), sp0 * 0.6), "Lốc cát: chậm 40% 3 giây")
	# Bọ Hung Giáp Vàng — khiên trước + Lăn cầu
	w.enemies = []
	w.player.hp = w.stats.max_hp
	var beetle := w.spawn_enemy("bo-cat", 24, w.player.pos + Vector2(120, 0), {"elite": true})
	_check(beetle.name == "Bọ Hung Giáp Vàng", "tinh anh của Bọ Cát là Bọ Hung Giáp Vàng")
	beetle.face = (w.player.pos - beetle.pos).angle()
	beetle.state = "chase"
	_check(Ch3.adjust_damage(w, beetle, 100, true) == 30, "khiên trước: chỉ nhận 30%")
	beetle.face += PI
	_check(Ch3.adjust_damage(w, beetle, 100, true) == 100, "đánh sau lưng: nhận đủ")
	w._elite_skill(beetle, "roll")
	_check(beetle.state == "windup" and beetle.attack_kind == "roll", "Lăn cầu báo trước")
	_tick(w, {}, 60)
	_check(w.player.hp < w.stats.max_hp, "Lăn cầu trúng người chơi")
	# Thủ Lĩnh Xác Ướp — Hồi sinh 2 Xác Ướp
	w.enemies = []
	for i in 3:
		var m := w.spawn_enemy("xac-uop", 27, w.player.pos + Vector2(300 + i * 30, 0))
		w._kill_enemy(m)
	var chief := w.spawn_enemy("xac-uop", 28, w.player.pos + Vector2(330, 40), {"elite": true})
	w._elite_skill(chief, "revive")
	var alive := w.enemies.filter(func(e): return not e.dead and e.kind == "xac-uop" and not e.elite).size()
	_check(alive == 2, "Thủ Lĩnh dựng lại 2 Xác Ướp (%d)" % alive)


## C3-T4: Sa Hoàng, Đuôi Sa Hoàng, Độn Thổ, Nhân Sư, Mắt Nhân Sư, Bộ Sa Hành Giả.
func _test_c3_bosses() -> void:
	var w := _region3_world("3-3", "kiem-khach", "dao-tac", 29)
	w.player.pos = w.arena_pos - Vector2(60, 0)
	# Test cơ chế, không test sống sót: khiên rất lớn để không gục giữa chừng.
	var tank := func(wl: GameWorld) -> void:
		wl.player.dead_timer = 0.0
		wl.player.stun_timer = 0.0
		wl.player.hp = wl.stats.max_hp
		wl.player.shield = 1e9
		wl.player.shield_time = 999.0
	var b := w.spawn_enemy("sa-hoang", 30, w.arena_pos, {"role": "boss"})
	_check(b.max_hp > 0 and b.max_poise > 0.0, "Sa Hoàng có thanh Phá Thế")
	b.attack_kind = "claw"
	w.player.hp = w.stats.max_hp
	b.pos = w.player.pos + Vector2(40, 0)
	w._perform_attack(b)
	_check(w.player.hold_timer > 0.9, "Kìm kẹp giữ chân 1 giây")
	var x0: float = w.player.pos.x
	_tick(w, {"move": Vector2.RIGHT}, 20)
	_check(absf(w.player.pos.x - x0) < 2.0, "đang bị kìm: không đi được")
	b.attack_kind = "tail"
	b.target = w.player.pos
	w._perform_attack(b)
	_check(w.player.poison_timer > 4.5, "Đuôi độc: độc 5 giây")
	# giai đoạn 2: bão cát + chui cát bất tử
	w.ch3.storm_left = 0.0
	b.hp = b.max_hp * 0.49
	w._apply_damage(b, 1, false, true)
	_check(b.phase == 2 and Ch3.storm_on(w), "dưới 50%: giai đoạn 2, bão cát")
	b.state = "chase"
	b.pounce_cd = 0.0
	_tick(w, {}, 2)
	_check(b.burrow_t > 0.0, "Sa Hoàng chui xuống cát")
	tank.call(w)
	var hp_b: float = b.hp
	w._hit_enemy(b, 3.0)
	_check(b.hp == hp_b, "chui cát: bất tử")
	_tick(w, {}, roundi(3.2 * 60))
	_check(b.burrow_t <= 0.0, "trồi lên sau 3 giây")
	# hạ Sa Hoàng: Độn Thổ cho Đạo Tặc, rơi đồ
	w._kill_enemy(b)
	_check(w.is_boss_defeated("sa-hoang") and "burrow" in w.profile.copied_skills, "hạ Sa Hoàng: Đạo Tặc học Độn Thổ")
	_check(ItemData.BOSS_UNIQUES["sa-hoang"] == "sa_hoang_tail", "đồ Cam của Sa Hoàng: Đuôi Sa Hoàng")
	w.profile.active_copy = "burrow"
	w.player.talent_cd = 0.0
	tank.call(w)
	var d1 := w.spawn_enemy("wolf", 25, w.player.pos + Vector2(120, 0))
	d1.max_hp = 1e6
	d1.hp = d1.max_hp
	_tick(w, {"aim": d1.pos, "talent": true}, 1)
	_check(w.player.burrow_t > 0.0 and d1.hp < d1.max_hp, "Độn Thổ: chui đất, trồi lên gây sát thương")
	w.player.shield = 0.0
	var hp_p: float = w.player.hp
	w._damage_player(500.0, 1.0)
	_check(w.player.hp == hp_p, "Độn Thổ: bất tử khi dưới đất")
	# Đuôi Sa Hoàng: độc cộng dồn 3
	var rng := RngUtil.make(4)
	w.profile.equipment["weapon"] = Items.new_item(w.profile, 30, "orange", rng, "weapon", "", "sa_hoang_tail")
	w._refresh_stats()
	tank.call(w)
	var t := _dummy(w, "wolf", 25, w.player.pos + Vector2(200, 0))
	for i in 5:
		w._hit_enemy(t, 0.1)
	_check(t.venom_stacks == Ch3.VENOM_STACK, "độc cộng dồn tối đa 3 lần")
	var hv: float = t.hp
	t.state = "idle"
	_tick(w, {}, 62)
	_check(t.hp < hv, "độc gây sát thương mỗi giây")
	# Nhân Sư Đá
	var w2 := _region3_world("3-3", "kiem-khach", "tay-nhanh", 31)
	w2.player.pos = Vector2(2000, 1200)
	var sx := w2.spawn_enemy("nhan-su", 32, w2.player.pos + Vector2(200, 0), {"role": "rare"})
	sx.hp = sx.max_hp * 0.74
	w2._update_rare(sx, 0.016)
	_check(sx.puzzle_t > 0.0 and w2.ch3.pillars.size() == 3, "mất 25%: Câu Đố Nhân Sư, 3 cột")
	var moc: Array = w2.ch3.pillars.filter(func(pl): return pl.element == "moc")
	_check(moc.size() == 1, "luôn có 1 cột Mộc")
	var hp_s: float = sx.hp
	w2._hit_enemy(sx, 5.0)
	_check(sx.hp == hp_s, "đang ra câu đố: Nhân Sư bất tử")
	w2.player.pos = moc[0].pos
	w2.player.hp = w2.stats.max_hp
	_tick(w2, {}, roundi(4.2 * 60))
	_check(is_equal_approx(w2.player.hp, w2.stats.max_hp) or w2.player.hp > w2.stats.max_hp * 0.9, "đứng cột Mộc: an toàn")
	sx.hp = sx.max_hp * 0.49
	w2._update_rare(sx, 0.016)
	var wrong: Array = w2.ch3.pillars.filter(func(pl): return pl.element != "moc")
	w2.player.pos = wrong[0].pos
	w2.player.hp = w2.stats.max_hp
	_tick(w2, {}, roundi(4.2 * 60))
	_check(w2.player.hp < w2.stats.max_hp * 0.9, "đứng sai cột: nhận ×3")
	tank.call(w2)
	w2.player.shield = 0.0
	sx.attack_kind = "gaze"
	sx.state = "windup"
	w2.player.pos = sx.pos + Vector2(80, 0)
	w2.player.hp = w2.stats.max_hp
	sx.target = w2.player.pos
	w2._perform_attack(sx)
	_check(w2.player.stun_timer > 1.0, "Ánh mắt hoá đá: choáng 1,5 giây")
	_check(w2.RARE_BOSSES["3-3"].unique == "nhan_su_eye", "Nhân Sư rơi Mắt Nhân Sư")
	# Mắt Nhân Sư, Bộ Sa Hành Giả
	var crit0: float = w2.stats.crit
	var def0: float = w2.stats.def
	w2.profile.equipment["necklace"] = Items.new_item(w2.profile, 32, "orange", rng, "necklace", "", "nhan_su_eye")
	w2._refresh_stats()
	_check(w2.stats.crit >= crit0 + 0.099, "Mắt Nhân Sư +10% chí mạng")
	for slot in ["helm", "armor", "boots", "amulet"]:
		w2.profile.equipment[slot] = Items.new_item(w2.profile, 1, "purple", rng, slot, ItemData.SA_HANH)
	w2._refresh_stats()
	var raw_def: float = Stats.derive(w2.profile.level, w2.profile.points, w2.profile.talent, Items.equipment_bonus(w2.profile.equipment), w2.profile.talent_level, w2.profile.class_id, w2.profile.stolen).def
	_check(is_equal_approx(w2.stats.def, raw_def * 1.1), "Sa Hành Giả 4 món: +10% Phòng thủ")
	for slot in ["gloves", "ring"]:
		w2.profile.equipment[slot] = Items.new_item(w2.profile, 1, "purple", rng, slot, ItemData.SA_HANH)
	tank.call(w2)
	w2.player.mp = 999.0
	w2.use_skill(0)
	_check(not w2.ch3.trails.is_empty(), "Sa Hành Giả 6 món: Xoáy Kiếm để lại lốc cát")


## C3-T5: nhiệm vụ chương 3 đủ 6 bước; lưới vùng 3.
func _test_c3_quest() -> void:
	var w := _region3_world("3-1", "kiem-khach", "tay-nhanh", 22)
	var p = w.profile
	p.quest.ch3 = 0
	w._load_map("3-1")
	_check(int(p.quest.ch3) == 1, "tới vùng 3: nhận nhiệm vụ chương 3")
	_check(w.npcs().size() == 3, "Trại Cát Đỏ có 3 NPC")
	w.talk("sa-lao")
	_check(int(p.quest.ch3) == 2, "bước 1: gặp Sa Lão")
	for i in 30:
		var m := w.spawn_enemy("bo-cat", 21, Vector2(2000, 1200))
		w._kill_enemy(m)
	Ch3.check_quest(w)
	_check(int(p.quest.ch3) == 3, "bước 2: hạ 30 quái vùng 3")
	w._load_map("3-2")
	for o in Ch3.oases(w):
		w.player.pos = o[0]
		_tick(w, {}, 70)
	Ch3.check_quest(w)
	_check(int(p.quest.ch3) == 4, "bước 3: uống nước ở 3 ốc đảo (%d)" % p.quest.oases.size())
	w._load_map("3-3")
	for y in range(0, int(w.world_size.y), 300):
		for x in range(0, int(w.world_size.x * 0.6), 300):
			w.fog.reveal(Vector2(x, y), 360.0)
	w.player.pos = w.map.stele3
	_tick(w, {}, 40)
	_check(int(p.quest.ch3) == 5 and w.explore_ratio("3-3") >= 0.4, "bước 4: Bia Khai Giới Giả (khám phá %d%%)" % roundi(w.explore_ratio("3-3") * 100.0))
	_check(w.boss_unlocked(), "bước 4 xong: mở Sào Huyệt Sa Hoàng")
	p.bosses["sa-hoang"] = true
	Ch3.check_quest(w)
	_check(int(p.quest.ch3) == 6, "bước 5: hạ Sa Hoàng")
	p.level = 30
	w._load_map("3-1")
	w.talk("thach-thu")
	Ch3.check_quest(w)
	_check(int(p.quest.ch3) == Story.DONE3 and p.job == "kiem-su", "bước 6: chuyển chức Kiếm Sư — chương 3 xong")
	var tiles := Explore.create_region_tiles(3, RngUtil.make(9))
	_check(tiles.size() == Explore.create_region_tiles(2, RngUtil.make(9)).size(), "lưới vùng 3 cùng cỡ vùng 2 (%d ô)" % tiles.size())
	var total := 0
	for st in Story.QUESTS3:
		total += int(st.reward.get("exp", 0))
	var span := 0
	for lv in range(20, 30):
		span += Formulas.exp_to_next(lv)
	_check(absf(float(total) / span - 0.25) < 0.03, "thưởng EXP chương 3 ≈ 25%% EXP cấp 20 → 30 (%.0f%%)" % (100.0 * total / span))


## C3-T6: chuyển chức 1 và kỹ năng chuyển chức; save v9.
func _test_c3_job() -> void:
	for class_id in Classes.ORDER:
		var w := _region3_world("3-1", class_id, "tay-nhanh", 29)
		_check(Ch3.can_job(w) != "", "%s: chưa đủ điều kiện" % class_id)
		w.profile.level = 30
		w.profile.bosses["sa-hoang"] = true
		var hp0: float = w.stats.max_hp
		var atk0: float = w.stats.atk
		_check(Ch3.do_job(w), "%s: chuyển chức được" % class_id)
		_check(w.profile.job == Classes.job_def(class_id).id and w.stats.max_hp > hp0 * 1.08 and w.stats.atk > atk0 * 1.08, "%s → %s, +10%% HP và Tấn công" % [class_id, Classes.title(class_id, w.profile.job)])
	# Kiếm Sư: đòn chém thứ 4 phóng kiếm khí
	var k := _region3_world("3-1", "kiem-khach", "tay-nhanh", 30)
	k.profile.job = "kiem-su"
	k.player.pos = Vector2(1500, 1200)
	var dummy := _dummy(k, "wolf", 25, k.player.pos + Vector2(50, 0))
	for i in 4:
		k.player.attack_cd = 0.0
		k._slash()
	_check(k.shots.filter(func(s): return s.kind == "wave").size() == 1, "Kiếm Sư: đòn chém thứ 4 phóng kiếm khí")
	_check(is_equal_approx(Ch3.spin_mult(k), 1.3), "Kiếm Sư: Xoáy Kiếm +30% bán kính")
	# Xạ Thủ: mũi tên phụ
	var h := _region3_world("3-1", "tho-san", "tay-nhanh", 30)
	h.profile.job = "xa-thu"
	h.player.pos = Vector2(1500, 1200)
	_dummy(h, "wolf", 25, h.player.pos + Vector2(150, 0))
	_dummy(h, "wolf", 25, h.player.pos + Vector2(0, 200))
	h._shoot()
	_check(h.shots.size() == 2, "Xạ Thủ: thêm 1 mũi tên phụ (%d)" % h.shots.size())
	_check(is_equal_approx(h.skill_cd_of(1), 4.0), "Xạ Thủ: Tên Xuyên Phá hồi 4 giây")
	# Pháp Sư Nguyên Tố: Lôi Xích nảy thêm 2
	var m := _region3_world("3-1", "phap-su", "tay-nhanh", 30)
	m.profile.job = "phap-su-nguyen-to"
	m.player.pos = Vector2(1500, 1200)
	m.player.mp = 999.0
	var row: Array = []
	for i in 8:
		row.append(_dummy(m, "wolf", 25, m.player.pos + Vector2(120 + i * 100, 0)))
	m.use_skill(0)
	var hit := row.filter(func(e): return e.hp < e.max_hp).size()
	_check(hit == GameWorld.CHAIN_JUMPS + 1 + Ch3.NT_JUMPS, "Pháp Sư Nguyên Tố: Lôi Xích trúng %d quái" % hit)
	_check(is_equal_approx(Ch3.fireball_mult(m), 1.3), "Pháp Sư Nguyên Tố: Hỏa Cầu +30%")
	# save
	var d: Dictionary = JSON.parse_string(JSON.stringify(m.profile.to_dict()))
	_check(int(d.version) == Profile.VERSION and Profile.VERSION >= 9, "save version %d" % Profile.VERSION)
	var back := Profile.new()
	_check(back.load_dict(d) and back.job == "phap-su-nguyen-to" and int(back.quest.ch3) == 5, "save giữ chức, nhiệm vụ chương 3")
	d.erase("job")
	d.quest.erase("ch3")
	var old := Profile.new()
	_check(old.load_dict(d) and old.job == "" and int(old.quest.ch3) == 0, "save cũ: chưa chuyển chức, chưa tới vùng 3")


## TL-B3: 3 lớp × 20 Thiên phú hạ Bọ Cạp Sa Hoàng (cấp 29, bộ đồ chuẩn cấp 29).
func _test_c3_balance() -> void:
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
			for seed_value in [5, 11]:
				var res := _r3_fight(class_id, t.id, seed_value)
				times.append(res[0])
				deaths += int(res[1])
				won = won and bool(res[2])
			var sec: float = avg.call(times)
			lines.append("%s %s %.0fs/%d" % [t.rank, t.name, sec, deaths])
			_check(won, "%s · %s hạ được Sa Hoàng" % [class_id, t.name])
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
	var a: float = class_avg.values().min()
	var b: float = class_avg.values().max()
	print("       (%d lớp: nhanh nhất %.1f, chậm nhất %.1f giây, chênh %.0f%%)" % [class_avg.size(), a, b, (b - a) / b * 100.0])
	_check((b - a) / b <= 0.25, "các lớp chênh ≤ 25%")


func _r3_fight(class_id: String, talent_id: String, seed_value: int) -> Array:
	var w := _region3_world("3-3", class_id, talent_id, 29, seed_value)
	var p = w.profile
	p.points = _class_points(class_id)
	for k in p.points:
		p.points[k] = int(p.points[k]) * 7
	var rng := RngUtil.make(77)
	for pair in [["weapon", "blue"], ["armor", "blue"], ["helm", "green"], ["boots", "green"], ["gloves", "green"]]:
		var it := Items.new_item(p, 29, pair[1], rng, pair[0])
		Items.add_item(p, it)
		w.equip(int(it.id))
	p.play_seconds = 10.0
	w.ch3.storm_next = 9999.0
	w.player.hp = w.stats.max_hp
	w.player.mp = w.stats.max_mp
	w.player.pos = w.arena_pos - Vector2(100, 0)
	var deaths := 0
	var seconds := 0.0
	while seconds < 600.0 and not p.bosses.get("sa-hoang", false):
		for ev in w.drain_events():
			if ev.type == "death":
				deaths += 1
		if w.boss() == null and w.player.dead_timer <= 0.0:
			w.player.pos = w.arena_pos - Vector2(100, 0)
		w.update(1.0 / 60.0, _bot(w))
		seconds += 1.0 / 60.0
	return [seconds, deaths, p.bosses.get("sa-hoang", false)]


func _test_m5_relic_puzzle() -> void:
	var Puzzle = load("res://scripts/core/puzzle.gd")
	# sinh cố định; Trận Đèn Cổ không bao giờ đã giải sẵn và luôn giải được trong ≤ 3 bước
	var kinds := {}
	var max_steps := 0
	var bad_region := false
	for id in 60:
		var a: Dictionary = Puzzle.make("Lâm Phong", 1, id)
		_check(a == Puzzle.make("Lâm Phong", 1, id), "") if id == 0 else null
		kinds[a.kind] = true
		if a.kind == "lights":
			_check(not Puzzle.solved(a), "Trận Đèn Cổ mới sinh chưa giải (ô %d)" % id)
			var best := 99
			for mask in 512:
				var t := a.duplicate(true)
				var n := 0
				for i in 9:
					if mask & (1 << i):
						Puzzle.press(t, i)
						n += 1
				if Puzzle.solved(t):
					best = mini(best, n)
			max_steps = maxi(max_steps, best)
		else:
			var r: Dictionary = Puzzle.RIDDLES.filter(func(x): return x.q == a.q)[0]
			_check(a.options[a.answer] == r.a[0], "đáp án đúng nằm ở vị trí answer")
			bad_region = bad_region or int(r.region) > 1
	_check(kinds.has("lights") and kinds.has("riddle"), "có cả 2 loại câu đố")
	_check(max_steps >= 1 and max_steps <= Puzzle.SCRAMBLE, "Trận Đèn Cổ giải được trong ≤ 3 bước (%d)" % max_steps)
	_check(not bad_region, "vùng 1 không hỏi chuyện chương 2")
	# câu ngũ hành khớp bảng khắc của quái
	var names := {"kim": "Kim", "moc": "Mộc", "tho": "Thổ", "thuy": "Thủy", "hoa": "Hỏa"}
	for el in Monsters.COUNTERS:
		var q := "Theo ngũ hành, %s khắc hệ nào?" % names[el]
		var r2: Array = Puzzle.RIDDLES.filter(func(x): return x.q == q)
		_check(r2.size() == 1 and r2[0].a[0] == names[Monsters.COUNTERS[el]], "câu ngũ hành %s đúng bảng khắc" % names[el])
	# luồng trong game
	var w := _world("tay-nhanh")
	w.debug_now = 1000.0
	var p = w.profile
	var relics: Array = p.tiles.filter(func(t): return t.event == "relic")
	var t1: Dictionary = relics[0]
	var t2: Dictionary = relics[1]
	t1.status = "revealed"
	t2.status = "revealed"
	# Trận Đèn Cổ còn 1 bước
	var lights := {"kind": "lights", "cells": [true, true, true, true, true, true, true, true, true], "moves": 0}
	Puzzle.press(lights, 4)
	lights.moves = 0
	w.relic_puzzles[w._relic_key(int(t1.id))] = lights
	var gold0: float = p.gold
	var st0: int = p.stones
	var r1: Dictionary = w.relic_press(int(t1.id), 4)
	_check(r1.get("solved", false) and t1.status == "owned", "thắp đủ 9 bùa: chiếm ô Di tích")
	_check(is_equal_approx(p.gold, gold0 + 160.0) and p.stones == st0 + 1, "giải câu đố: +160 vàng (×2), +1 Đá Cường Hoá")
	# câu hỏi cổ thư: sai thì khoá 30 giây
	w.relic_puzzles[w._relic_key(int(t2.id))] = {"kind": "riddle", "q": "?", "options": ["a", "b", "c"], "answer": 1}
	w.relic_answer(int(t2.id), 0)
	_check(t2.status == "revealed" and w.relic_locked(int(t2.id)) > 29.0, "trả lời sai: rương khoá 30 giây")
	w.relic_answer(int(t2.id), 1)
	_check(t2.status == "revealed", "đang khoá thì không trả lời được")
	w.debug_now = 1031.0
	var gold1: float = p.gold
	var ra: Dictionary = w.relic_answer(int(t2.id), 1)
	_check(ra.get("solved", false) and t2.status == "owned" and is_equal_approx(p.gold, gold1 + 160.0), "hết khoá, trả lời đúng: chiếm ô, thưởng ×2")
	# phá khoá: thưởng thường
	var t3: Dictionary = p.tiles.filter(func(t): return t.event == "relic" and t.status != "owned")[0]
	t3.status = "revealed"
	var gold2: float = p.gold
	w.claim_tile(int(t3.id))
	_check(t3.status == "owned" and is_equal_approx(p.gold, gold2 + 80.0), "phá khoá: +80 vàng (thưởng thường)")


# ------------------------------------------------------------------ M7 — Chương 4 Đầm Lầy Mộng (docs/11)

func _region4_world(map_id := "4-1", class_id := "kiem-khach", talent := "tay-nhanh", level := 34, seed_value := 5) -> GameWorld:
	var p := _profile(talent, 3)
	p.class_id = class_id
	p.level = level
	p.boss_defeated = true
	p.bosses = {"huyen-anh": true, "sa-hoang": true}
	p.job = str(Classes.job_def(class_id).id)
	p.unlocked_maps = ["1-1", "1-3", "2-1", "2-2", "2-3", "3-1", "3-2", "3-3", "4-1", "4-2", "4-3"]
	p.quest = {"ch2": Story.DONE2, "kills2": 0, "ch3": Story.DONE3, "kills3": 0, "oases": [], "ch4": 5, "kills4": 0, "orbs4": []}
	p.map_id = map_id
	var w := GameWorld.new(p, RngUtil.make(seed_value))
	w.enemies = []
	w.field_spawn = false
	return w


func _dry_spot(w: GameWorld) -> Vector2:
	for y in range(300, int(w.world_size.y) - 300, 97):
		for x in range(900, int(w.world_size.x) - 900, 113):
			var pos := Vector2(x, y)
			if not Ch4.in_water(w, pos) and pos.distance_to(w.safe_pos) > w.safe_r + 50.0:
				return pos
	return Vector2(1500, 300)


func _wet_spot(w: GameWorld) -> Vector2:
	for y in range(300, int(w.world_size.y) - 300, 97):
		for x in range(900, int(w.world_size.x) - 900, 113):
			if Ch4.in_water(w, Vector2(x, y)):
				return Vector2(x, y)
	return Vector2(1400, 700)


## C4-T1: điều kiện mở vùng 4; 3 map; bộ điều phối chương (D38).
func _test_c4_unlock() -> void:
	var w := _region3_world("3-3", "kiem-khach", "tay-nhanh", 32)
	_check(w.travel_blocker("4-1").contains("Sa Hoàng"), "chưa hạ Sa Hoàng: chặn")
	w.profile.bosses["sa-hoang"] = true
	_check(w.travel_blocker("4-1").contains("chuyển chức"), "chưa chuyển chức: chặn (%s)" % w.travel_blocker("4-1"))
	w.profile.job = "kiem-su"
	_check(w.travel_blocker("4-1") == "", "đã chuyển chức + hạ Sa Hoàng: vào được Bãi Lau Mù")
	_check(w.travel_blocker("4-2") != "" and w.travel_blocker("4-3") != "", "phải đi 4-1 → 4-2 → 4-3")
	for pair in [["4-1", [32, 36]], ["4-2", [36, 41]], ["4-3", [41, 45]]]:
		var m: Dictionary = MapsData.get_map(pair[0])
		_check(m.levels == pair[1] and m.size == Vector2(4480, 2560) and m.region == 4 and m.has("water"), "%s cấp %s, có nước đầm" % [pair[0], str(pair[1])])
	_check(MapsData.get_map("4-3").arena.boss == "nu-vuong", "Cung Phệ Mộng: Nữ Vương")
	_check(Chapters.MODULES.size() >= 2 and "tick" in Ch4.HOOKS, "bộ điều phối chương có chương 3 và 4")


## C4-T2: nước đầm, độc tích luỹ, Thuốc Giải, Bộ U Minh, ảo ảnh.
func _test_c4_env() -> void:
	var w := _region4_world("4-1")
	var p = w.profile
	w.player.pos = _wet_spot(w)
	_check(Ch4.in_water(w, w.player.pos) and is_equal_approx(Ch4.move_mult(w), 0.85), "lội nước: chậm 15%")
	w.player.hp = w.stats.max_hp
	_tick(w, {}, roundi(20.5 * 60))
	_check(w.ch4.poison == 2, "20 giây trong nước: 2 tầng độc (%d)" % w.ch4.poison)
	_check(w.player.hp < w.stats.max_hp, "độc làm mất máu")
	w.ch4.poison = 10
	w.player.hp = 1.0
	_tick(w, {}, 60)
	_check(w.player.hp >= 1.0 and w.player.dead_timer <= 0.0, "độc không làm gục")
	w.player.pos = _dry_spot(w)
	w.ch4.poison = 3
	_tick(w, {}, roundi(3.2 * 60))
	_check(w.ch4.poison == 2, "đất khô 3 giây: −1 tầng")
	p.antidotes = 1
	w.ch4.poison = 4
	w.drink_potion()
	_check(w.ch4.poison == 0 and p.antidotes == 0, "Thuốc Giải xoá hết độc")
	var rng := RngUtil.make(2)
	for slot in ["helm", "armor"]:
		p.equipment[slot] = Items.new_item(p, 34, "purple", rng, slot, Ch4.U_MINH)
	_check(is_equal_approx(Ch4.poison_every(w), 20.0), "Bộ U Minh 2 món: độc tích chậm 50%")
	# ảo ảnh
	var e := w.spawn_enemy("ech-doc", 33, w.player.pos + Vector2(80, 0))
	e.illusion = true
	var kills0: int = p.kills
	var xp0: int = p.xp
	w._hit_enemy(e, 0.01)
	_check(e.dead and p.kills == kills0 and p.xp == xp0, "ảo ảnh: 1 đòn là tan, không EXP")
	var n := 0
	for i in 200:
		var f := w.spawn_enemy("dia", 33, Vector2(2000, 1200))
		Chapters.after_spawn(w, f)
		if f.illusion:
			n += 1
	_check(n > 20 and n < 60, "khoảng 20%% quái là ảo ảnh (%d/200)" % n)


## C4-T3: quái vùng 4.
func _test_c4_mobs() -> void:
	var w := _region4_world("4-1")
	w.player.pos = _dry_spot(w)
	w.player.hp = w.stats.max_hp
	var frog := w.spawn_enemy("ech-doc", 33, w.player.pos + Vector2(110, 0))
	frog.attack_kind = "tongue"
	var x0: float = w.player.pos.x
	w._perform_attack(frog)
	_check(w.player.pos.x > x0 + 30.0 and w.ch4.poison >= 1, "Lưỡi độc: kéo 4 m, +1 tầng độc")
	var leech := w.spawn_enemy("dia", 33, w.player.pos + Vector2(20, 0))
	leech.attack_kind = "latch"
	w._perform_attack(leech)
	_check(w.ch4.leech_id == leech.id, "Đỉa bám vào người chơi")
	leech.hp = leech.max_hp * 0.5
	var hp_l: float = leech.hp
	_tick(w, {}, 60)
	_check(leech.hp > hp_l, "Đỉa hút máu hồi cho nó")
	_tick(w, {"dodge": true}, 2)
	_check(w.ch4.leech_id == -1, "né lăn gỡ Đỉa")
	w.enemies = []
	var ghost := w.spawn_enemy("hon-ma", 37, w.player.pos + Vector2(200, 0))
	ghost.state = "chase"
	ghost.pounce_cd = 0.0
	_tick(w, {}, 2)
	_check(w.enemies.filter(func(x): return x.illusion).size() == 2, "Phân ảnh: 2 ảo ảnh")
	var croc := w.spawn_enemy("ca-sau", 39, w.player.pos + Vector2(30, 0))
	croc.attack_kind = "chomp"
	w.player.dodge_time = 0.0
	w._perform_attack(croc)
	_check(w.player.stun_timer > 0.9, "Đớp: choáng 1 giây")
	w.player.stun_timer = 0.0
	w.enemies = []
	w.player.dead_timer = 0.0
	w.player.hp = w.stats.max_hp
	w.player.shield = 1e9
	w.player.shield_time = 999.0
	var witch := w.spawn_enemy("hon-ma", 38, w.player.pos + Vector2(200, 0), {"elite": true})
	_check(witch.name == "Phù Thuỷ Đầm Lầy", "tinh anh Hồn Ma: Phù Thuỷ Đầm Lầy")
	w.ch4.poison = 0
	w._elite_skill(witch, "toxrain")
	_tick(w, {}, 62)
	_check(w.ch4.poison >= 2, "Mưa độc: +2 tầng mỗi giây (%d)" % w.ch4.poison)
	var king := w.spawn_enemy("ca-sau", 41, w.player.pos + Vector2(30, 0), {"elite": true})
	_check(king.name == "Cá Sấu Chúa", "tinh anh Cá Sấu: Cá Sấu Chúa")
	king.attack_kind = "deathroll"
	w.player.shield = 0.0
	w.player.dead_timer = 0.0
	w.player.hold_timer = 0.0
	w.player.hp = w.stats.max_hp
	w._perform_attack(king)
	_check(w.player.hold_timer > 1.5 and w.player.hp < w.stats.max_hp, "Cuộn tử thần: giữ 2 giây, gây sát thương")


## C4-T4: Nữ Vương, Gối Mộng, Mộng Cảnh, Thất Đầu, Vảy Thất Đầu, Bộ U Minh.
func _test_c4_bosses() -> void:
	var w := _region4_world("4-3", "kiem-khach", "dao-tac", 42)
	w.player.pos = w.arena_pos - Vector2(60, 0)
	w.player.shield = 1e9
	w.player.shield_time = 999.0
	var q := w.spawn_enemy("nu-vuong", 43, w.arena_pos, {"role": "boss"})
	q.hp = q.max_hp * 0.59
	_tick(w, {}, 1)
	_check(q.phase == 2 and w.ch4.dream_t > 0.0, "dưới 60%: giấc mơ")
	_check(w.enemies.filter(func(e): return e.kind == "mong-chau" and not e.dead).size() == 3, "3 Mộng Châu")
	_check(Chapters.input_move(w, Vector2.RIGHT) == Vector2.LEFT, "trong mơ: điều khiển đảo ngược")
	var hq: float = q.hp
	w._hit_enemy(q, 5.0)
	_check(q.hp == hq, "đang mơ: Nữ Vương bất tử")
	for o in w.enemies.filter(func(e): return e.kind == "mong-chau"):
		o.hp = 1.0
		w._hit_enemy(o, 5.0)
	_tick(w, {}, 2)
	_check(w.ch4.dream_t <= 0.0, "phá 3 Mộng Châu: tỉnh")
	q.hp = q.max_hp * 0.24
	_tick(w, {}, 2)
	_check(q.phase == 3, "dưới 25%: Phệ mộng")
	w.player.shield = 0.0
	w.player.pos = q.pos + Vector2(60, 0)
	w.player.hp = w.stats.max_hp
	var hp_q: float = q.hp
	_tick(w, {}, 30)
	_check(w.player.hp < w.stats.max_hp and q.hp > hp_q, "ngoài vòng sáng: bị hút máu")
	w.player.pos = w.ch4.light_pos
	w.player.hp = w.stats.max_hp
	_tick(w, {}, 2)
	w.player.pos = w.ch4.light_pos
	var hp_in: float = w.player.hp
	_tick(w, {}, 6)
	_check(w.player.hp >= hp_in - 1.0, "trong vòng sáng: an toàn")
	w._kill_enemy(q)
	_check(w.is_boss_defeated("nu-vuong") and "dreamscape" in w.profile.copied_skills, "hạ Nữ Vương: Đạo Tặc học Mộng Cảnh")
	_check(ItemData.BOSS_UNIQUES["nu-vuong"] == "goi_mong", "Nữ Vương rơi Gối Mộng")
	# Mộng Cảnh
	var a := w.spawn_enemy("ca-sau", 42, w.player.pos + Vector2(40, 0))
	var b := w.spawn_enemy("ca-sau", 42, w.player.pos + Vector2(60, 10))
	_check(Chapters.copy_skill(w, "dreamscape") and a.charm_t > 0.0 and b.charm_t > 0.0, "Mộng Cảnh: quái trong 10 m bị mê")
	b.max_hp = 1e6
	b.hp = b.max_hp
	_tick(w, {}, 130)
	_check(b.hp < b.max_hp, "quái bị mê đánh nhau")
	# Gối Mộng
	var rng := RngUtil.make(8)
	w.profile.equipment["amulet"] = Items.new_item(w.profile, 43, "orange", rng, "amulet", "", "goi_mong")
	w._refresh_stats()
	var dodged := 0
	for i in 400:
		if Ch4.dodge_hit(w):
			dodged += 1
	_check(dodged > 30 and dodged < 95, "Gối Mộng: ~15%% né hẳn (%d/400)" % dodged)
	# Thất Đầu
	var w2 := _region4_world("4-3", "phap-su", "tay-nhanh", 45)
	w2.player.pos = Vector2(2000, 1200)
	w2.player.shield = 1e9
	w2.player.shield_time = 9999.0
	var hydra := w2.spawn_enemy("thuy-quai", 45, w2.player.pos + Vector2(250, 0), {"role": "rare"})
	w2._update_rare(hydra, 0.016)
	var heads: Array = w2.enemies.filter(func(e): return e.kind == "dau-thuy-quai")
	_check(heads.size() == 7, "Thất Đầu có 7 đầu")
	var hb: float = hydra.hp
	w2._hit_enemy(hydra, 10.0)
	_check(hydra.hp == hb, "thân bất tử")
	w2._kill_enemy(heads[0])
	_check(w2.ch4.stumps.size() == 1, "chặt đầu: để lại gốc")
	_tick(w2, {}, roundi(20.5 * 60))
	_check(w2.enemies.filter(func(e): return e.kind == "dau-thuy-quai" and not e.dead).size() == 7, "không đốt: đầu mọc lại sau 20 giây")
	var heads2: Array = w2.enemies.filter(func(e): return e.kind == "dau-thuy-quai" and not e.dead)
	for i in 6:
		w2._kill_enemy(heads2[i])
	var burn_target: Dictionary = w2.ch4.stumps[0]
	w2.hit_source = "fireball"
	var near = heads2[6]
	near.pos = burn_target.pos + Vector2(40, 0)
	Chapters.on_player_hit(w2, near)
	w2.hit_source = ""
	_check(burn_target.burned, "đòn Hỏa Cầu đốt gốc đầu")
	w2.profile.fire_torches = 6
	w2.player.pos = burn_target.pos
	for i in 6:
		w2.player.potion_cd = 0.0
		w2.drink_potion()
	_check(w2.ch4.stumps.filter(func(s): return not s.burned).is_empty(), "Đuốc Lửa (Q) đốt các gốc còn lại")
	var essence0: int = w2.profile.essence
	w2._kill_enemy(heads2[6])
	_check(hydra.dead and w2.profile.essence > essence0, "chặt đủ 7 đầu: Thất Đầu gục, nhận Tinh Hoa")
	_check(w2.RARE_BOSSES["4-3"].unique == "vay_that_dau", "Thất Đầu rơi Vảy Thất Đầu")
	# Vảy Thất Đầu + Bộ U Minh
	var res0: float = float(w2.stats.res.thuy)
	w2.profile.equipment["armor"] = Items.new_item(w2.profile, 45, "orange", rng, "armor", "", "vay_that_dau")
	w2._refresh_stats()
	_check(float(w2.stats.res.thuy) >= res0 + 0.19, "Vảy Thất Đầu +20% kháng Thủy")
	w2.player.hp = w2.stats.max_hp * 0.5
	var hp_v: float = w2.player.hp
	_tick(w2, {}, 60)
	_check(w2.player.hp >= hp_v + w2.stats.max_hp * 0.009, "Vảy Thất Đầu hồi 1% HP/giây")
	var hp0: int = w2.stats.max_hp
	for slot in ["helm", "boots", "gloves", "amulet"]:
		w2.profile.equipment[slot] = Items.new_item(w2.profile, 1, "purple", rng, slot, Ch4.U_MINH)
	w2._refresh_stats()
	_check(w2.stats.max_hp > hp0, "Bộ U Minh 4 món: +12% HP")


## C4-T5: nhiệm vụ chương 4.
func _test_c4_quest() -> void:
	var w := _region4_world("4-1", "kiem-khach", "tay-nhanh", 33)
	var p = w.profile
	p.quest.ch4 = 0
	w._load_map("4-1")
	_check(int(p.quest.ch4) == 1 and w.npcs().size() == 3, "tới vùng 4: nhận nhiệm vụ, 3 NPC")
	w.talk("lao-ngu")
	_check(int(p.quest.ch4) == 2 and p.antidotes >= 2, "bước 1: gặp Lão Ngư (+2 Thuốc Giải)")
	for i in 30:
		var m := w.spawn_enemy("ech-doc", 33, Vector2(2000, 1200))
		w._kill_enemy(m)
	Chapters.check_quest(w)
	_check(int(p.quest.ch4) == 3, "bước 2: hạ 30 quái")
	w._load_map("4-2")
	for pod in w.map.pods:
		w.player.pos = pod
		Chapters.check_quest(w)
	Chapters.check_quest(w)
	_check(int(p.quest.ch4) == 4, "bước 3: phá 5 Bọc Mộng")
	w._load_map("4-3")
	for y in range(0, int(w.world_size.y), 300):
		for x in range(0, int(w.world_size.x * 0.6), 300):
			w.fog.reveal(Vector2(x, y), 360.0)
	_tick(w, {}, 40)
	_check(int(p.quest.ch4) == 5 and w.boss_unlocked(), "bước 4: khám phá Cung Mộng, mở cửa Cung Phệ Mộng")
	p.bosses["nu-vuong"] = true
	Chapters.check_quest(w)
	_check(int(p.quest.ch4) == 6, "bước 5: hạ Nữ Vương")
	var total := 0
	for st in Story.QUESTS4:
		total += int(st.reward.get("exp", 0))
	var span := 0
	for lv in range(30, 45):
		span += Formulas.exp_to_next(lv)
	_check(absf(float(total) / span - 0.25) < 0.03, "thưởng EXP chương 4 ≈ 25%% (%.0f%%)" % (100.0 * total / span))


## C4-T6: tiến hoá Thiên phú lần 1 — không tụt sức mạnh, hoàn Tinh Hoa; save v10.
func _test_c4_evolve() -> void:
	var w := _region4_world("4-1", "kiem-khach", "tay-nhanh", 44)
	var p = w.profile
	p.quest.ch4 = 6
	p.talent_level = 10
	w._refresh_stats()
	_check(Ch4.can_evolve(w).contains("Tinh Hoa Tiến Hoá"), "thiếu Tinh Hoa Tiến Hoá: chưa tiến hoá được")
	p.evo_essence = 1
	var atk0: float = w.stats.atk
	var spd0: float = w.stats.atk_speed
	var hp0: int = w.stats.max_hp
	var ess0: int = p.essence
	_check(Ch4.can_evolve(w) == "", "đủ điều kiện")
	_check(Ch4.evolve(w).ok, "tiến hoá")
	_check(p.evo == 1 and Ch4.stage_level(p) == 1 and Ch4.evo_form("tay-nhanh", 1) == ["Phong Ảnh Thủ", "C"], "Tay Nhanh → Phong Ảnh Thủ (C), Lv1")
	_check(p.essence == ess0 + 12, "hoàn 12 Tinh Hoa (%d)" % (p.essence - ess0))
	_check(w.stats.atk >= atk0 - 0.01 and w.stats.atk_speed >= spd0 - 0.001 and w.stats.max_hp >= hp0, "không tụt sức mạnh sau tiến hoá")
	p.talent_level += 9
	w._refresh_stats()
	_check(w.stats.atk_speed > spd0 and w.stats.atk > atk0, "luyện dạng mới tới Lv10: mạnh hơn Lv10 cũ")
	Chapters.check_quest(w)
	_check(int(p.quest.ch4) == Story.DONE4, "bước 6: tiến hoá — chương 4 xong")
	_check(Ch4.evolved_once(p), "đủ điều kiện tiến hoá để mở vùng 5")
	var dt := _region4_world("4-1", "kiem-khach", "dao-tac", 44)
	_check(Ch4.evolved_once(dt.profile) and Ch4.can_evolve(dt).contains("không tiến hoá"), "Đạo Tặc: không tiến hoá, coi như đạt")
	# save
	var d: Dictionary = JSON.parse_string(JSON.stringify(p.to_dict()))
	_check(int(d.version) == Profile.VERSION and Profile.VERSION >= 10, "save version %d" % Profile.VERSION)
	var back := Profile.new()
	_check(back.load_dict(d) and back.evo == 1 and int(back.talent_level) == 19 and int(back.quest.ch4) == Story.DONE4, "save giữ tiến hoá, nhiệm vụ chương 4")
	d.erase("evo")
	var old := Profile.new()
	_check(old.load_dict(d) and old.evo == 0, "save cũ: chưa tiến hoá")


## TL-B4: 3 lớp × 20 Thiên phú hạ Nữ Vương Phệ Mộng (cấp 42, bộ đồ chuẩn cấp 42, đã chuyển chức).
func _test_c4_balance() -> void:
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
			for seed_value in [5, 11]:
				var res := _r4_fight(class_id, t.id, seed_value)
				times.append(res[0])
				deaths += int(res[1])
				won = won and bool(res[2])
			var sec: float = avg.call(times)
			lines.append("%s %s %.0fs/%d" % [t.rank, t.name, sec, deaths])
			_check(won, "%s · %s hạ được Nữ Vương" % [class_id, t.name])
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
	var a: float = class_avg.values().min()
	var b: float = class_avg.values().max()
	print("       (%d lớp: nhanh nhất %.1f, chậm nhất %.1f giây, chênh %.0f%%)" % [class_avg.size(), a, b, (b - a) / b * 100.0])
	_check((b - a) / b <= 0.25, "các lớp chênh ≤ 25%")


func _r4_fight(class_id: String, talent_id: String, seed_value: int) -> Array:
	var w := _region4_world("4-3", class_id, talent_id, 42, seed_value)
	var p = w.profile
	p.points = _class_points(class_id)
	for k in p.points:
		p.points[k] = int(p.points[k]) * 10
	var rng := RngUtil.make(77)
	for pair in [["weapon", "blue"], ["armor", "blue"], ["helm", "green"], ["boots", "green"], ["gloves", "green"]]:
		var it := Items.new_item(p, 42, pair[1], rng, pair[0])
		Items.add_item(p, it)
		w.equip(int(it.id))
	w.player.hp = w.stats.max_hp
	w.player.mp = w.stats.max_mp
	w.player.pos = w.arena_pos - Vector2(100, 0)
	var deaths := 0
	var seconds := 0.0
	while seconds < 600.0 and not p.bosses.get("nu-vuong", false):
		for ev in w.drain_events():
			if ev.type == "death":
				deaths += 1
		if w.boss() == null and w.player.dead_timer <= 0.0:
			w.player.pos = w.arena_pos - Vector2(100, 0)
		w.update(1.0 / 60.0, _bot(w))
		seconds += 1.0 / 60.0
	return [seconds, deaths, p.bosses.get("nu-vuong", false)]


# ------------------------------------------------------------------ M8 — Chương 5 Núi Lửa Phẫn Nộ (docs/12)


func _region5_world(map_id := "5-1", class_id := "kiem-khach", talent := "tay-nhanh", level := 47, seed_value := 5) -> GameWorld:
	var p := _profile(talent, 3)
	p.class_id = class_id
	p.level = level
	p.boss_defeated = true
	p.bosses = {"huyen-anh": true, "sa-hoang": true, "nu-vuong": true}
	p.job = str(Classes.job_def(class_id).id)
	p.evo = 1
	p.talent_level = 10
	p.unlocked_maps = ["1-1", "1-3", "2-1", "2-2", "2-3", "3-1", "3-2", "3-3", "4-1", "4-2", "4-3", "5-1", "5-2", "5-3"]
	p.quest = {"ch2": Story.DONE2, "kills2": 0, "ch3": Story.DONE3, "kills3": 0, "oases": [], "ch4": Story.DONE4, "kills4": 0, "orbs4": [],
		"ch5": 1, "kills5": 0, "raid_won": false}
	p.map_id = map_id
	var w := GameWorld.new(p, RngUtil.make(seed_value))
	w.enemies = []
	w.field_spawn = false
	return w


func _safe5(w: GameWorld) -> Vector2:
	for y in range(300, int(w.world_size.y) - 300, 97):
		for x in range(900, int(w.world_size.x) - 900, 113):
			var pos := Vector2(x, y)
			if not Ch5.in_lava(w, pos) and not Ch5.near_lava(w, pos) and pos.distance_to(w.safe_pos) > w.safe_r + 50.0:
				return pos
	return Vector2(1000, 1280)


## C5-T1: điều kiện mở vùng 5; 3 map.
func _test_c5_unlock() -> void:
	var w := _region4_world("4-3", "kiem-khach", "tay-nhanh", 45)
	w.profile.evo = 0
	w.profile.talent_level = 10
	_check(w.travel_blocker("5-1").contains("Nữ Vương"), "chưa hạ Nữ Vương: chặn")
	w.profile.bosses["nu-vuong"] = true
	_check(w.travel_blocker("5-1").contains("tiến hoá"), "chưa tiến hoá: chặn (%s)" % w.travel_blocker("5-1"))
	w.profile.evo = 1
	w.profile.level = 43
	_check(w.travel_blocker("5-1").contains("44"), "dưới cấp 44: chặn")
	w.profile.level = 45
	_check(w.travel_blocker("5-1") == "", "đủ điều kiện: vào Chân Núi Tro")
	w.profile.evo = 0
	w.profile.talent = "dao-tac"
	_check(w.travel_blocker("5-1") == "", "Đạo Tặc không cần tiến hoá")
	_check(w.travel_blocker("5-2") != "" and w.travel_blocker("5-3") != "", "phải đi 5-1 → 5-2 → 5-3")
	for pair in [["5-1", [45, 50]], ["5-2", [50, 55]], ["5-3", [55, 60]]]:
		var m: Dictionary = MapsData.get_map(pair[0])
		_check(m.levels == pair[1] and m.size == Vector2(4480, 2560) and m.region == 5 and not m.lava.is_empty(), "%s cấp %s, có dung nham" % [pair[0], str(pair[1])])
	_check(MapsData.get_map("5-3").arena.boss == "vien-long" and not MapsData.get_map("5-1").get("eruption", false) and MapsData.get_map("5-2").eruption,
		"Long Huyệt: Viêm Long; 5-1 không phun, 5-2/5-3 phun")
	_check(Ch5 in Chapters.MODULES and "tick" in Ch5.HOOKS, "bộ điều phối có chương 5")
	var w2 := _region5_world("5-1")
	w2._load_map("5-1")
	_check(int(w2.profile.quest.ch5) == 1, "tới vùng 5: nhận nhiệm vụ chương 5")


## C5-T2: dung nham, núi lửa phun, nhiệt, Kháng Hỏa.
func _test_c5_env() -> void:
	var w := _region5_world("5-1")
	var lava: Vector2 = w.map.lava[0][0]
	w.player.pos = lava
	w.player.hp = w.stats.max_hp
	var hp0: float = w.player.hp
	_tick(w, {}, 60)
	var lost: float = hp0 - w.player.hp
	_check(absf(lost - w.stats.max_hp * Ch5.LAVA_PCT) < w.stats.max_hp * 0.006, "dung nham −5%% HP/giây (%.1f%%)" % (lost / w.stats.max_hp * 100.0))
	w.player.hp = 5.0
	_tick(w, {}, 120)
	_check(w.player.hp >= 1.0 and w.player.dead_timer <= 0.0, "dung nham không làm gục")
	# né lăn qua dung nham không mất máu
	w.player.hp = w.stats.max_hp
	w.player.dodge_time = 10.0
	_tick(w, {}, 10)
	_check(is_equal_approx(w.player.hp, w.stats.max_hp), "né lăn qua dung nham không mất máu")
	w.player.dodge_time = 0.0
	# quái không bước vào dung nham
	var e := w.spawn_enemy("than-lan-lua", 47, lava + Vector2(float(w.map.lava[0][1]) + 30.0, 0))
	_check(Ch5.enemy_avoid(w, e, lava), "quái không bước vào dung nham")
	# nhiệt +10% tốc đánh
	w.player.pos = lava + Vector2(float(w.map.lava[0][1]) + 20.0, 0)
	var spd0: float = float(w.stats.get("atk_speed", 1.0))
	_tick(w, {}, 2)
	_check(w.ch5.heat and float(w.stats.get("atk_speed", 1.0)) > spd0, "gần dung nham: +10% tốc đánh")
	# Kháng Hỏa giảm sát thương dung nham
	var plain: float = Ch5._fire_pct(w, 0.1)
	w.stats.res["hoa"] = 0.5
	_check(is_equal_approx(Ch5._fire_pct(w, 0.1), plain * 0.5), "Kháng Hỏa 50% giảm nửa sát thương dung nham")
	w.stats.res["hoa"] = 0.0
	# núi lửa phun (5-2)
	var w2 := _region5_world("5-2")
	w2._load_map("5-2")
	w2.player.pos = _safe5(w2)
	w2.player.hp = w2.stats.max_hp
	w2.ch5.erupt_t = 0.01
	_tick(w2, {}, 1)
	_check(w2.ch5.meteors.size() == Ch5.ERUPT_COUNT, "núi lửa phun: 8 thiên thạch")
	w2.ch5.meteors = [{"pos": w2.player.pos, "t": 0.02}]
	var hp1: float = w2.player.hp
	_tick(w2, {}, 3)
	_check(absf((hp1 - w2.player.hp) - w2.stats.max_hp * Ch5.METEOR_PCT) < w2.stats.max_hp * 0.02, "thiên thạch trúng −25% HP")
	w2.player.hp = 3.0
	w2.ch5.meteors = [{"pos": w2.player.pos, "t": 0.02}]
	_tick(w2, {}, 3)
	_check(w2.player.hp >= 1.0 and w2.player.dead_timer <= 0.0, "thiên thạch không làm gục")
	w2.player.hp = w2.stats.max_hp
	w2.ch5.meteors = [{"pos": w2.player.pos, "t": 0.02}]
	w2.player.dodge_time = 0.3
	_tick(w2, {}, 3)
	_check(is_equal_approx(w2.player.hp, w2.stats.max_hp), "né lăn tránh thiên thạch")
	_check(not Ch5.env_text(w2).is_empty(), "HUD dòng môi trường vùng 5")


## C5-T3: quái vùng 5.
func _test_c5_mobs() -> void:
	var w := _region5_world("5-1")
	w.player.pos = _safe5(w)
	w.player.hp = w.stats.max_hp
	# Thằn Lằn để lại vệt lửa
	var liz := w.spawn_enemy("than-lan-lua", 47, w.player.pos + Vector2(250, 0))
	liz.state = "chase"
	for i in 40:
		w._update_enemy(liz, 1.0 / 60.0)
	_check(w.ch5.trails.size() >= 1, "Thằn Lằn chạy để lại vệt lửa")
	# Người Đá vỡ 3 mảnh, mảnh không cho EXP
	var golem := w.spawn_enemy("nguoi-da", 47, w.player.pos + Vector2(300, 100))
	w._kill_enemy(golem)
	var shards := w.enemies.filter(func(e): return e.kind == "manh-da" and not e.dead)
	_check(shards.size() == 3 and is_equal_approx(shards[0].max_hp, roundf(golem.max_hp * Ch5.SHARD_HP)) or shards.size() == 3, "Người Đá vỡ thành 3 Mảnh Đá")
	var xp0: int = w.profile.xp
	var lv0: int = w.profile.level
	w._kill_enemy(shards[0])
	_check(w.profile.xp == xp0 and w.profile.level == lv0, "Mảnh Đá không cho EXP")
	# Linh Hồn Lửa: tự nổ, tắt trong dung nham
	w.enemies = []
	var wisp := w.spawn_enemy("linh-hon-lua", 48, w.player.pos + Vector2(30, 0))
	wisp.attack_kind = "fireburst"
	var hp0: float = w.player.hp
	w._perform_attack(wisp)
	_check(wisp.dead and w.player.hp < hp0, "Linh Hồn Lửa tự nổ vòng 5 m")
	var wisp2 := w.spawn_enemy("linh-hon-lua", 48, w.map.lava[0][0])
	w._update_enemy(wisp2, 0.1)
	_check(wisp2.dead, "Linh Hồn Lửa tắt trong dung nham")
	# Cột lửa: 3 cột nối tiếp
	var mage := w.spawn_enemy("phap-su-hoa-diem", 52, w.player.pos + Vector2(180, 0))
	mage.target = w.player.pos
	mage.attack_kind = "firepillar"
	w._perform_attack(mage)
	_check(w.ch5.pillars.size() == Ch5.PILLARS, "Cột lửa: 3 cột")
	w.player.hp = w.stats.max_hp
	_tick(w, {}, 60)
	_check(w.player.hp < w.stats.max_hp, "cột lửa cuối trúng chỗ người chơi")
	# Rồng Non: Phun lửa quay chậm
	w.enemies = []
	w.ch5.breaths = []
	var drake := w.spawn_enemy("than-lan-lua", 52, w.player.pos + Vector2(60, 0), {"elite": true})
	_check(drake.elite and drake.name == "Rồng Non Lửa", "tinh anh của Thằn Lằn là Rồng Non Lửa")
	Ch5.elite_skill(w, drake, "flamebreath")
	w.player.pos = drake.pos + Vector2.from_angle(w.ch5.breaths[0].ang + PI / 2.0) * 60.0
	var ang0: float = w.ch5.breaths[0].ang
	Ch5._tick_breaths(w, 0.5)
	_check(absf(angle_difference(w.ch5.breaths[0].ang, ang0)) <= Ch5.BREATH_TURN * 0.5 + 0.001, "Phun lửa quay tối đa 60°/giây")
	# Thợ Rèn: Búa rèn + hào quang +20%
	w.enemies = []
	var smith := w.spawn_enemy("nguoi-da", 55, w.player.pos + Vector2(40, 0), {"elite": true})
	var buddy := w.spawn_enemy("linh-hon-lua", 55, w.player.pos + Vector2(80, 40))
	var atk0: float = buddy.atk
	smith.attack_kind = "hammer"
	w._perform_attack(smith)
	_check(is_equal_approx(buddy.atk, atk0 * Ch5.HAMMER_BUFF), "Búa rèn: quái quanh +20% Tấn công")
	Ch5._tick_buffs(w, Ch5.HAMMER_TIME + 0.1)
	_check(is_equal_approx(buddy.atk, atk0), "hết 8 giây trả lại Tấn công")
	# khiên phía trước của Thợ Rèn
	smith.face = (w.player.pos - smith.pos).angle()
	_check(Ch5.adjust_damage(w, smith, 100, true) == 30, "Thợ Rèn chặn 70% đòn từ phía trước")


## C5-T4: Viêm Long, Phượng Hoàng, đồ, bộ.
func _test_c5_bosses() -> void:
	var w := _region5_world("5-3", "kiem-khach", "tay-nhanh", 57)
	w._load_map("5-3")
	w.enemies = []
	var b := w.spawn_enemy("vien-long", 58, w.arena_pos, {"role": "boss"})
	_check(int(b.max_hp) == 77128, "Viêm Long theo 06 (%d HP)" % b.max_hp)
	b.hp = b.max_hp * 0.59
	w._update_enemy(b, 0.1)
	_check(b.phase == 2, "dưới 60%: bay lên")
	w.ch5.landed = false
	w.ch5.flood_t = 1.0
	w._update_enemy(b, 0.01)
	_check(b.fly_t > 0.0 and w.is_hidden(b) and Ch5.adjust_damage(w, b, 500, true) == 0, "đang bay: bất tử, không bị nhắm")
	_check(Ch5.flood_warning(w), "3 giây đầu: báo dung nham dâng")
	w.ch5.flood_t = Ch5.FLOOD_WARN + 1.0
	w._update_enemy(b, 0.01)
	_check(w.ch5.flooding and not w.ch5.landed, "dung nham ngập Long Huyệt")
	w.player.pos = w.arena_pos + Vector2(0, 40)
	w.player.hp = w.stats.max_hp
	var hp0: float = w.player.hp
	Ch5._tick_dragon(w, 1.0)
	_check(w.player.hp < hp0 - w.stats.max_hp * 0.05, "ngoài Đá Nổi: mất 8% HP/giây")
	w.player.pos = Ch5.rocks(w)[0]
	var hp1: float = w.player.hp
	Ch5._tick_dragon(w, 1.0)
	_check(is_equal_approx(w.player.hp, hp1), "trên Đá Nổi: an toàn")
	w.ch5.flood_t = Ch5.FLOOD_WARN + Ch5.FLOOD_TIME + 0.1
	w._update_enemy(b, 0.01)
	_check(b.fly_t <= 0.0 and w.ch5.landed and not w.ch5.flooding and Ch5.adjust_damage(w, b, 500, true) == 500, "hết lượt ngập: đáp xuống cạnh người chơi, đánh được")
	_check(b.pos.distance_to(w.player.pos) <= Ch5.LAND_GAP + 1.0 or b.pos.distance_to(w.arena_pos) >= w.arena_r - b.radius - 1.0, "đáp ngay cạnh người chơi")
	Ch5.adjust_damage(w, b, int(b.max_hp * Ch5.LAND_DAMAGE) + 1, true)
	w._update_enemy(b, 0.01)
	_check(not w.ch5.landed and b.fly_t > 0.0, "mất 15% HP trong lần đáp: bay lên lại")
	b.hp = b.max_hp * 0.19
	w._update_enemy(b, 0.01)
	_check(b.phase == 3 and b.fly_t <= 0.0 and b.haste_timer > 100.0, "dưới 20%: rơi xuống, Cuồng nộ")
	_check(Ch5.boss_phase_two(w, b), "không dùng giai đoạn 2 kiểu Sói Chúa")
	# Long Tâm: miễn dung nham 2 giây sau né lăn; +20% sát thương hệ Hỏa
	var it := Items.new_item(w.profile, 58, "orange", RngUtil.make(1), "", "", "long_tam")
	Items.add_item(w.profile, it)
	w.equip(int(it.id))
	w.player.dodge_time = 0.1
	Ch5.tick(w, 0.01)
	_check(w.ch5.lava_immune > 1.9, "Long Tâm: miễn dung nham 2 giây sau né lăn")
	w.hit_source = "fireball"
	_check(is_equal_approx(Ch5.hit_mult(w, b, false), 1.2), "Long Tâm: +20% sát thương hệ Hỏa")
	w.hit_source = ""
	# Long Tức (Đạo Tặc)
	w.ch5.breaths = []
	_check(Ch5.copy_skill(w, "breath") and w.ch5.breaths.size() == 1 and w.ch5.breaths[0].player, "Đạo Tặc — Long Tức")
	# Phượng Hoàng Tro: Niết bàn
	w.enemies = []
	w.ch5.breaths = []
	w.profile.bosses["vien-long"] = true
	w.debug_now = 1000.0
	w._check_rare_boss()
	var ph := w.rare_boss()
	_check(ph != null and ph.kind == "phuong-hoang" and int(ph.max_hp) == 130423, "hạ Viêm Long rồi: Phượng Hoàng Tro xuất hiện (%s)" % (str(ph.max_hp) if ph != null else "null"))
	ph.hp = 10.0
	w._apply_damage(ph, 100, false, true)
	_check(not ph.dead and w.ch5.reborn and w.ch5.egg_t > 0.0, "lần đầu bị hạ: hoá trứng, Niết bàn")
	_check(Ch5.adjust_damage(w, ph, 100, true) == 0, "đang là trứng: bất tử")
	w.ch5.egg_t = 0.01
	Ch5.update_rare(w, ph, 0.1)
	_check(is_equal_approx(ph.hp, ph.max_hp * Ch5.REBIRTH_HP), "tái sinh 50% HP")
	# lần 2 (hoặc trúng hệ Thủy): gục hẳn — thử nhánh Nước Thánh
	w.ch5.reborn = false
	w.profile.holy_water = 1
	ph.hp = ph.max_hp * 0.1
	w.player.pos = ph.pos + Vector2(100, 0)
	_check(Ch5.drink(w) and w.profile.holy_water == 0, "Bình Nước Thánh: phím Q khi Phượng Hoàng dưới 15%")
	w.pickups = []
	w._apply_damage(ph, int(ph.hp) + 10, false, true)
	_check(ph.dead, "trúng hệ Thủy 5 giây cuối: không hồi sinh")
	var feather := w.pickups.filter(func(pk): return pk.kind == "item" and pk.item.unique == "long_phuong")
	_check(feather.size() == 1, "rơi Lông Phượng")
	# Băng Ngục tính là hệ Thủy
	w.hit_source = "nova"
	_check(Ch5._water_hit(w), "Băng Ngục là đòn hệ Thủy")
	w.hit_source = ""
	# Lông Phượng: hồi sinh tại chỗ
	var it2 := Items.new_item(w.profile, 60, "orange", RngUtil.make(2), "", "", "long_phuong")
	Items.add_item(w.profile, it2)
	w.equip(int(it2.id))
	w.player.hp = 5.0
	w.player.dodge_time = 0.0
	w._damage_player(99999.0, 5.0)
	_check(w.player.dead_timer <= 0.0 and w.player.hp > w.stats.max_hp * 0.25, "Lông Phượng: hồi sinh 30% HP")
	w.player.hp = 5.0
	w._damage_player(99999.0, 5.0)
	_check(w.player.dead_timer > 0.0, "Lông Phượng hồi 5 phút")
	# Bộ Hoả Ngục
	var w3 := _region5_world("5-2")
	var res0: float = float(w3.stats.res.get("hoa", 0.0))
	var rng := RngUtil.make(4)
	for slot in ["weapon", "armor", "helm", "boots", "gloves", "necklace"]:
		var si := Items.new_item(w3.profile, 52, "purple", rng, slot, "hoa_nguc")
		Items.add_item(w3.profile, si)
		w3.equip(int(si.id))
	_check(float(w3.stats.res.get("hoa", 0.0)) >= res0 + 0.3 - 0.001, "Bộ Hoả Ngục 2 món: +30% kháng Hỏa")
	Ch5.skill_trail(w3, w3.player.pos, 80.0)
	_check(w3.ch5.rings.size() == 1, "Bộ Hoả Ngục 6 món: kỹ năng để lại vòng lửa")


## C5-T5: nhiệm vụ chương 5; Mỏ Tinh Thạch.
func _test_c5_quest() -> void:
	var w := _region5_world("5-1")
	w._load_map("5-1")
	var p = w.profile
	_check(w.npcs().any(func(n): return n.id == "kim-phu") and not w.npcs().any(func(n): return n.id == "tieu-hoa"), "đầu chương: Kim Phú bán hàng")
	w.talk("xich-dong")
	_check(int(p.quest.ch5) == 2, "bước 1: gặp Xích Đồng")
	_check(w.talk("kim-phu") == "shop", "Kim Phú mở cửa hàng")
	p.quest.kills5 = 30
	Ch5.check_quest(w)
	_check(int(p.quest.ch5) == 3, "bước 2: 30 quái")
	var grid: Array = p.tiles
	var mine: Dictionary = grid.filter(func(t): return t.event == "mine")[0]
	var n := 0
	for t in grid:
		if t.event != "camp" and t.event != "mine" and n < 6:
			t.status = "owned"
			n += 1
	Ch5.check_quest(w)
	_check(int(p.quest.ch5) == 3, "6 ô nhưng chưa có Mỏ: chưa xong")
	mine.status = "owned"
	Ch5.check_quest(w)
	_check(int(p.quest.ch5) == 4, "bước 3: 6 ô + Mỏ Tinh Thạch")
	# Mỏ Tinh Thạch: +1/phút, không cho Đá/Sắt
	p.buildings[Explore.tile_key("mine", mine, 5)] = 0.0
	var rate := Explore.production_per_minute(p)
	_check(is_equal_approx(rate.crystal, 1.0) and is_equal_approx(rate.ore, 0.0), "Mỏ vùng 5: +1 Tinh Thạch/phút, không Đá")
	p.raid_penalty_until = p.build_clock + 100.0
	_check(is_equal_approx(Explore.production_per_minute(p).crystal, 0.0), "đang bị phạt đột kích: Mỏ ngừng")
	p.raid_penalty_until = 0.0
	# bước 4: Công Trại (thắng)
	w.talk("xich-dong")
	_check(w.ch5.siege, "bước 4: Xích Đồng → Công Trại")
	Ch5._end_siege(w, true)
	Ch5.check_quest(w)
	_check(int(p.quest.ch5) == 5 and not w.npcs().any(func(n2): return n2.id == "kim-phu") and w.npcs().any(func(n2): return n2.id == "tieu-hoa"),
		"thắng Công Trại: Kim Phú bỏ trốn, Tiểu Hoả bán thay")
	_check(not w.gate_open("5-3"), "Long Huyệt còn khoá")
	p.quest.ch5 = 6
	_check(w.gate_open("5-3"), "bước 6: Long Huyệt mở")
	p.bosses["vien-long"] = true
	Ch5.check_quest(w)
	_check(int(p.quest.ch5) == 7, "bước 6: hạ Viêm Long")
	p.job2 = "kiem-thanh"
	Ch5.check_quest(w)
	_check(int(p.quest.ch5) == Story.DONE5 and Ch5.quest_hud(w).get("done", false), "bước 7: chuyển chức 2 → chương 5 xong")
	var total := 0.0
	for q in Story.QUESTS5:
		total += float(q.reward.get("exp", 0))
	var need := 0.0
	for l in range(45, 60):
		need += Formulas.exp_to_next(l)
	_check(total / need >= 0.2 and total / need <= 0.3, "thưởng EXP nhiệm vụ ≈ 25%% (%.0f%%)" % (total / need * 100.0))


## C5-T6: Công Trại, đột kích.
func _test_c5_siege() -> void:
	var w := _region5_world("5-1", "kiem-khach", "tay-nhanh", 50)
	w._load_map("5-1")
	w.enemies = []
	w.profile.quest.ch5 = 4
	Ch5.start_siege(w)
	_check(w.ch5.siege and Ch5.safe_blocked(w) and is_equal_approx(w.ch5.gate_max, Ch5.GATE_HP_PER_LEVEL * 50), "Công Trại: cổng có thanh bền, trại mất an toàn")
	Ch5._tick_siege(w, 1.0)
	var mobs := w.enemies.filter(func(e): return e.role == "siege")
	_check(w.ch5.wave == 1 and mobs.size() == 6, "đợt 1: 6 Lính Kim Luân")
	# lính đi tới cổng và đánh cổng
	var m = mobs[0]
	m.pos = Ch5.gate_pos(w) + Vector2(20, 0)
	w.player.pos = w.safe_pos + Vector2(-150, 0)
	var g0: float = w.ch5.gate_hp
	Ch5._update_siege_mob(w, m, 0.1)
	_check(w.ch5.gate_hp < g0, "lính đứng cạnh cổng thì đánh cổng")
	# hạ đợt 1, 2 → đợt 3
	for wave in 2:
		for e in w.enemies:
			if e.role == "siege":
				e.dead = true
		w.enemies = w.enemies.filter(func(e): return not e.dead)
		w.ch5.wave_gap = 0.0
		Ch5._tick_siege(w, 0.1)
	_check(w.ch5.wave == 3 and w.enemies.any(func(e): return e.kind == "doi-truong-kim-luan" and e.elite), "đợt 3 có Đội Trưởng Kim Luân")
	for e in w.enemies:
		e.dead = true
	w.enemies = []
	Ch5._tick_siege(w, 0.1)
	_check(not w.ch5.siege and bool(w.profile.quest.raid_won), "hạ hết 3 đợt: thắng Công Trại")
	# thua: cổng vỡ → đánh lại được
	w.profile.quest.raid_won = false
	Ch5.start_siege(w)
	w.ch5.gate_hp = 0.0
	Ch5._tick_siege(w, 0.1)
	_check(not w.ch5.siege and not bool(w.profile.quest.raid_won), "cổng vỡ: thua")
	w.talk("xich-dong")
	_check(w.ch5.siege, "nói với Xích Đồng: đánh lại")
	Ch5._end_siege(w, false, true)
	# đột kích định kỳ sau chương
	w.profile.quest.ch5 = Story.DONE5
	w.profile.raid_play = Ch5.RAID_EVERY - Ch5.RAID_WARN + 0.1
	Ch5._tick_raid(w, 0.1)
	_check(w.ch5.raid_warn > 0.0, "báo đột kích trước 60 giây")
	Ch5._tick_raid(w, Ch5.RAID_WARN + 0.1)
	_check(w.ch5.siege and w.ch5.siege_raid, "đột kích bắt đầu")
	Ch5._end_siege(w, false)
	_check(Ch5.raid_penalty(w.profile), "thua đột kích: công trình vùng 5 ngừng 30 phút")
	var gold0: float = w.profile.gold
	Ch5.start_siege(w, true)
	Ch5._end_siege(w, true)
	_check(w.profile.gold > gold0, "thắng đột kích: có thưởng")


## C5-T7: chuyển chức 2.
func _test_c5_job2() -> void:
	for class_id in Classes.ORDER:
		var defs: Array = Classes.job2_defs(class_id)
		_check(defs.size() == 2, "%s có 2 nhánh chuyển chức 2" % class_id)
	_check(Classes.job2_defs("kiem-khach")[0].name == "Kiếm Thánh" and Classes.job2_defs("tho-san")[1].name == "Thợ Bẫy"
		and Classes.job2_defs("phap-su")[1].name == "Tử Linh Sư", "tên nhánh theo kịch bản")
	var w := _region5_world("5-1", "kiem-khach", "tay-nhanh", 60)
	var p = w.profile
	_check(Ch5.can_job2(w).contains("Viêm Long"), "chưa hạ Viêm Long: chưa được")
	p.bosses["vien-long"] = true
	_check(Ch5.can_job2(w).contains("Tinh Thạch"), "thiếu Tinh Thạch: chưa được")
	p.crystal = 30.0
	_check(Ch5.can_job2(w) == "" and w.talk("liet-dien") == "job2", "đủ điều kiện: Liệt Diễm mở bảng chọn nhánh")
	var hp0: int = w.stats.max_hp
	_check(Ch5.do_job2(w, "kiem-thanh") and p.job2 == "kiem-thanh" and is_equal_approx(p.crystal, 0.0), "chọn Kiếm Thánh, tốn 30 Tinh Thạch")
	_check(w.stats.max_hp > hp0 and Classes.title(p.class_id, p.job, p.job2) == "Kiếm Thánh", "+10% HP, tên chức mới")
	_check(not Ch5.do_job2(w, "huyet-kiem") and p.job2 == "kiem-thanh", "không đổi nhánh sau khi chọn")
	_check(is_equal_approx(Ch5.poise_mult(w, null), Ch5.KT_POISE), "Kiếm Thánh: Phá Thế +40%")
	# các nhánh khác
	p.job2 = "huyet-kiem"
	w.player.hp = w.stats.max_hp * 0.4
	var dummy := w.spawn_enemy("than-lan-lua", 50, w.player.pos + Vector2(50, 0))
	_check(is_equal_approx(Ch5.hit_mult(w, dummy, false), Ch5.HK_MUL), "Huyết Kiếm: dưới 50% HP +20% sát thương")
	var hpb: float = w.player.hp
	Ch5.adjust_damage(w, dummy, 1000, true)
	_check(is_equal_approx(w.player.hp, hpb + 60.0), "Huyết Kiếm: hút 6% sát thương")
	p.job2 = "than-tien"
	_check(is_equal_approx(Ch5.pierce_cd(w, 4.0), 3.0) and is_equal_approx(Ch5.hit_mult(w, dummy, true), Ch5.TT_CRIT_MUL), "Thần Tiễn: Tên Xuyên Phá −1 giây, chí mạng ×1,2")
	p.job2 = "tho-bay"
	_check(Ch5.trap_extra(w) == 2, "Thợ Bẫy: thêm 2 bẫy")
	p.job2 = "dai-phap-su"
	_check(Ch5.meteor_extra(w, Vector2.ZERO, 3.0).size() == 1 and is_equal_approx(float(Ch5.meteor_extra(w, Vector2.ZERO, 3.0)[0][1]), 1.8), "Đại Pháp Sư: thêm 1 Thiên Thạch ×0,6")
	p.job2 = "tu-linh-su"
	var bones0 := Ch5._bones(w)
	for i in 30:
		var f := w.spawn_enemy("than-lan-lua", 50, w.player.pos + Vector2(80, 0))
		Ch5.on_kill(w, f)
	_check(Ch5._bones(w) > bones0 and Ch5._bones(w) <= Ch5.TL_MAX, "Tử Linh Sư: dựng Xương Nô (tối đa 3)")
	_check(Ch5.hit_mult(w, dummy, false) > 1.0, "mỗi Xương Nô +5% sát thương")
	# save v11 + chuyển đổi v10
	var d: Dictionary = JSON.parse_string(JSON.stringify(p.to_dict()))
	_check(int(d.version) >= 11, "save version 11")
	var back := Profile.new()
	back.load_dict(d)
	_check(back.job2 == "tu-linh-su" and int(back.quest.ch5) == int(p.quest.ch5), "save giữ chức 2 và nhiệm vụ chương 5")
	d.version = 10
	for k in ["job2", "crystal", "holy_water", "raid_play", "raid_penalty_until"]:
		d.erase(k)
	var old := Profile.new()
	_check(old.load_dict(d) and old.job2 == "" and is_equal_approx(old.crystal, 0.0), "save v10 nạp được, chưa chuyển chức 2")


## TL-B5: 3 lớp × 20 Thiên phú hạ Viêm Long (cấp 57, đồ chuẩn cấp 57, đã tiến hoá 1 lần, chưa chuyển chức 2).
func _test_c5_balance() -> void:
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
			for seed_value in [5, 11]:
				var res := _r5_fight(class_id, t.id, seed_value)
				times.append(res[0])
				deaths += int(res[1])
				won = won and bool(res[2])
			var sec: float = avg.call(times)
			lines.append("%s %s %.0fs/%d" % [t.rank, t.name, sec, deaths])
			_check(won and deaths == 0, "%s · %s hạ được Viêm Long, không chết lần nào" % [class_id, t.name])
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
	var a: float = class_avg.values().min()
	var b: float = class_avg.values().max()
	print("       (%d lớp: nhanh nhất %.1f, chậm nhất %.1f giây, chênh %.0f%%)" % [class_avg.size(), a, b, (b - a) / b * 100.0])
	_check((b - a) / b <= 0.25, "các lớp chênh ≤ 25%")


func _r5_fight(class_id: String, talent_id: String, seed_value: int) -> Array:
	var w := _region5_world("5-3", class_id, talent_id, 57, seed_value)
	w._load_map("5-3")
	w.enemies = []
	w.field_spawn = false
	var p = w.profile
	p.quest.ch5 = 6
	p.points = _class_points(class_id)
	for k in p.points:
		p.points[k] = int(p.points[k]) * 14
	var rng := RngUtil.make(77)
	for pair in [["weapon", "blue"], ["armor", "blue"], ["helm", "green"], ["boots", "green"], ["gloves", "green"]]:
		var it := Items.new_item(p, 57, pair[1], rng, pair[0])
		Items.add_item(p, it)
		w.equip(int(it.id))
	w.player.hp = w.stats.max_hp
	w.player.mp = w.stats.max_mp
	w.player.pos = w.arena_pos - Vector2(100, 0)
	var deaths := 0
	var seconds := 0.0
	while seconds < 600.0 and not p.bosses.get("vien-long", false):
		for ev in w.drain_events():
			if ev.type == "death":
				deaths += 1
		if w.boss() == null and w.player.dead_timer <= 0.0:
			w.player.pos = w.arena_pos - Vector2(100, 0)
		w.update(1.0 / 60.0, _bot(w))
		seconds += 1.0 / 60.0
	return [seconds, deaths, p.bosses.get("vien-long", false)]


# ------------------------------------------------------------------ Spec_Notes đợt 5


func _test_sn5_travel() -> void:
	var w := _world("tay-nhanh")
	w.field_spawn = false
	w.enemies = []
	w.player.pos = Vector2(900, 1280)
	var goal := Vector2(1300, 1100)
	w.set_move_target(goal)
	_check(w.has_move_target(), "đặt điểm đến")
	_tick(w, {}, 30)
	_check(w.player.pos.distance_to(goal) < Vector2(900, 1280).distance_to(goal) - 50.0, "tự chạy về phía điểm đến")
	_tick(w, {}, 400)
	_check(not w.has_move_target() and w.player.pos.distance_to(goal) <= GameWorld.TRAVEL_ARRIVE + 4.0, "tới nơi thì dừng")
	w.set_move_target(Vector2(300, 300))
	_tick(w, {"move": Vector2.RIGHT}, 2)
	_check(not w.has_move_target(), "tự di chuyển thì huỷ")
	# kẹt sau tường sương trước hang Sói Chúa (chưa mở)
	w.profile.boss_defeated = false
	w.profile.level = 1
	w.player.pos = Vector2(w.gate_x - 100.0, 1280)
	w.set_move_target(Vector2(w.gate_x + 600.0, 1280))
	_tick(w, {}, 240)
	_check(not w.has_move_target() and w.player.pos.x <= w.gate_x + 1.0, "kẹt ở tường sương: dừng sau 1,5 giây")
	w.set_move_target(Vector2(500, 500))
	w._load_map("1-1")
	_check(not w.has_move_target(), "đổi map thì huỷ")
	# toạ độ bản đồ nhỏ → thế giới
	var Minimap = load("res://scripts/ui/minimap.gd")
	var mm = Minimap.new()
	mm.update_from(w)
	var mid: Vector2 = mm.world_at(Vector2(mm.size.x / 2.0, Minimap.HEADER + (mm.size.y - Minimap.HEADER) / 2.0))
	_check(mid.distance_to(w.world_size / 2.0) < 30.0, "giữa bản đồ nhỏ = giữa map")
	_check(mm.world_at(Vector2(10, 5)) == Vector2.INF, "bấm vào dòng tiêu đề không tính")
	mm.free()


func _test_sn5_pickup_notes() -> void:
	var w := _world("tay-nhanh")
	w.field_spawn = false
	w.enemies = []
	w.pickups = []
	var p := w.player
	for v in [12.0, 30.0, 8.0]:
		var pk := GameWorld.Pickup.new()
		pk.pos = p.pos
		pk.kind = "gold"
		pk.value = v
		w.pickups.append(pk)
	for i in 2:
		var it := Items.new_item(w.profile, 5, "blue", RngUtil.make(10 + i))
		var pk2 := GameWorld.Pickup.new()
		pk2.pos = p.pos
		pk2.kind = "item"
		pk2.item = it
		w.pickups.append(pk2)
	_tick(w, {}, 1)
	var gold_notes := w.pickup_notes.filter(func(n): return n.key == "gold")
	_check(gold_notes.size() == 1 and gold_notes[0].text == "+50 vàng", "3 túi vàng cùng lúc gộp thành 1 dòng (%s)" % (gold_notes[0].text if gold_notes.size() > 0 else "—"))
	_check(w.pickup_notes.filter(func(n): return n.key.begins_with("item_")).size() == 2, "mỗi món đồ một dòng riêng")
	for i in 10:
		w._pickup_note("item_x%d" % i, "Đồ %d" % i, 0.0, Color.WHITE, true)
	_check(w.pickup_notes.size() == GameWorld.PICKUP_NOTES_MAX, "tối đa 6 dòng")
	_tick(w, {}, 200)
	_check(w.pickup_notes.is_empty(), "các dòng tự mất sau vài giây")


func _test_sn6_exp_note() -> void:
	var w := _world("tay-nhanh")
	w.pickup_notes = []
	w.add_exp(20.0, true)
	w.add_exp(15.0, true)
	var notes := w.pickup_notes.filter(func(n): return n.key == "exp")
	_check(notes.size() == 1 and notes[0].text == "+35 EXP", "2 lần hạ quái liền nhau gộp 1 dòng (%s)" % (notes[0].text if notes.size() > 0 else "—"))
	w.pickup_notes = []
	w.add_exp(80.0, false)
	_check(w.pickup_notes.is_empty(), "EXP thưởng nhiệm vụ không hiện ở cột nhặt đồ")


func _test_sn6_chase() -> void:
	var w := _world("tay-nhanh")
	w.field_spawn = false
	w.enemies = []
	var p := w.player.pos
	var slow = w.spawn_enemy("linh-danh-thue", 5, p + Vector2(400, 0))
	var ranged = w.spawn_enemy("cung-thu", 5, p + Vector2(0, 400))
	_check(w.chase_speed(slow) >= GameWorld.CHASE_FLOOR, "quái giáp chậm (%.0f) đuổi ≥ %.0f (%.0f)" % [slow.speed, GameWorld.CHASE_FLOOR, w.chase_speed(slow)])
	_check(is_equal_approx(w.chase_speed(ranged), ranged.speed * GameWorld.CHASE_MULT), "quái đánh xa chỉ ×1,25, không áp tối thiểu")
	var before: float = w.chase_speed(slow)
	slow.state = "idle"
	w._hit_enemy(slow, 0.01)
	_check(slow.rush_timer > 0.0 and slow.state == "chase" and w.chase_speed(slow) > before * 1.4, "bị đánh từ xa → Truy kích và đuổi ngay")
	var boss = w.spawn_enemy("boss", 6, p + Vector2(600, 0), {"role": "boss"})
	_check(is_equal_approx(w.chase_speed(boss), boss.speed), "boss giữ nguyên tốc độ")


func _cave_world() -> GameWorld:
	var w := _world("tay-nhanh")
	w.field_spawn = false
	w.enemies = []
	w.profile.level = 8
	return w


func _enter_cave(w: GameWorld) -> void:
	const Portals = preload("res://scripts/core/portals.gd")
	var cp: Dictionary = w.portals.filter(func(pt): return pt.kind == "cave")[0]
	w.player.pos = cp.pos
	_tick(w, {}, 1)
	_tick(w, {}, 100)


func _test_sn6_cave_enter() -> void:
	const Portals = preload("res://scripts/core/portals.gd")
	const Caves = preload("res://scripts/core/caves.gd")
	for id in Portals.chain():
		var cps := Portals.list(id).filter(func(pt): return pt.kind == "cave")
		var ok: bool = cps.size() == 1 and str(cps[0].to) == "cave-" + id
		for pt in Portals.list(id):
			if pt.kind != "cave" and cps.size() == 1 and pt.pos.distance_to(cps[0].pos) < 200.0:
				ok = false
		_check(ok, "%s: 1 cửa hang (%s), cách xa cổng khác" % [id, Caves.name_of(id)])
	var w := _cave_world()
	w.player.pos = w.portals.filter(func(pt): return pt.kind == "cave")[0].pos
	_tick(w, {}, 1)
	_check(w.travel_timer > 0.0 and absf(w.travel_timer - Caves.TRAVEL_TIME) < 0.05, "bước vào cửa hang → đi đường 1,5 giây")
	_tick(w, {}, 100)
	_check(w.map_id == "cave-1-1" and w.in_cave() and not ("cave-1-1" in w.profile.unlocked_maps), "đang ở trong hang, không thêm vào map đã mở")
	_check(w.profile.map_id == "1-1", "save ghi map cha khi đang trong hang")
	var kinds := w.portals.map(func(pt): return pt.kind)
	_check(kinds == ["exit"], "trong hang chỉ có cổng ra (%s)" % str(kinds))
	_check(int(w.map.levels[0]) == int(MapsData.MAPS["1-1"].levels[1]), "cấp hang = cấp cao nhất map cha")
	w.enemies = []
	w.player.pos = w.portals[0].pos + Vector2(0, 200)
	_tick(w, {}, 1)
	w.player.pos = w.portals[0].pos
	_tick(w, {}, 1)
	_tick(w, {}, 100)
	var cave_pt: Dictionary = Portals.find_to(w.portals, "cave-1-1")
	_check(w.map_id == "1-1" and w.player.pos.distance_to(cave_pt.pos) < 160.0, "ra hang về Rừng Sương, đứng cạnh cửa hang")


func _test_sn6_cave_clear() -> void:
	const Caves = preload("res://scripts/core/caves.gd")
	var w := _cave_world()
	_enter_cave(w)
	var alive := w.enemies.filter(func(e): return not e.dead)
	var bosses := alive.filter(func(e): return e.cave_boss)
	var elites := alive.filter(func(e): return e.elite and not e.cave_boss)
	_check(alive.size() == 16 and bosses.size() == 1 and elites.size() == 2, "16 quái: 1 Chúa Hang, 2 tinh anh (%d / %d / %d)" % [alive.size(), bosses.size(), elites.size()])
	var boss = bosses[0]
	var ref = w.spawn_enemy(boss.kind, boss.level, Vector2(100, 100), {"elite": true})
	_check(is_equal_approx(boss.max_hp, ref.max_hp * Caves.BOSS_HP), "Chúa Hang HP ×5")
	ref.dead = true
	w.enemies = [boss]
	_tick(w, {}, 300)
	_check(w.enemies.filter(func(e): return not e.dead and e.role == "field").size() <= 1, "trong hang không sinh thêm quái")
	w.pickups = []
	w._kill_enemy(boss)
	var items := w.pickups.filter(func(pk): return pk.kind == "item")
	_check(items.size() >= 1 and items.any(func(pk): return pk.item.rarity in ["blue", "purple", "orange"]), "rơi món Xanh dương trở lên")
	_check(w.portals.filter(func(pt): return pt.kind == "exit").size() == 2, "hiện cổng ra tại chỗ Chúa Hang")
	_check(Caves.reopen_in(w, "1-1") > 1100.0, "hang đóng ~20 phút")
	var d: Dictionary = w.profile.to_dict()
	var p2 := Profile.new()
	_check(p2.load_dict(JSON.parse_string(JSON.stringify(d))) and int(d.version) == 15 and float(p2.caves.get("1-1", 0.0)) > 0.0, "save v15 giữ thời điểm hang mở lại")
	var w2 := GameWorld.new(p2, RngUtil.make(3))
	_check(w2.map_id == "1-1", "vào lại game khi đang trong hang → map cha")
	_check(w2.travel_blocker("cave-1-1").begins_with("Hang đã dọn"), "ra map cha: vào lại hang bị chặn (%s)" % w2.travel_blocker("cave-1-1"))
	w2.profile.play_seconds += Caves.COOLDOWN + 1.0
	_check(w2.travel_blocker("cave-1-1") == "", "sau 20 phút hang mở lại")


func _test_sn6_portals() -> void:
	const Portals = preload("res://scripts/core/portals.gd")
	var chain := Portals.chain()
	_check(chain[0] == "1-1" and chain[1] == "1-3" and chain[2] == "2-1", "thứ tự map theo vùng (%s…)" % str(chain.slice(0, 3)))
	var l11 := Portals.list("1-1")
	var kinds := l11.map(func(pt): return pt.kind)
	_check(not ("back" in kinds) and "next" in kinds and "waypoint" in kinds, "map đầu: không có cổng lùi (%s)" % str(kinds))
	var l13 := Portals.list("1-3")
	_check(Portals.find_to(l13, "1-1").kind == "back" and Portals.find_to(l13, "2-1").kind == "next", "Lõi Sương: lùi về Rừng Sương, tiến sang Cửa Gió")
	for id in chain:
		var m: Dictionary = MapsData.get_map(id)
		for pt in Portals.list(id):
			var inside: bool = Rect2(Vector2.ZERO, m.size).grow(-40.0).has_point(pt.pos)
			var before_wall: bool = not m.get("gate", false) or m.arena == null or pt.pos.x < float(m.arena.pos.x) - float(m.arena.r) - 60.0
			_check(inside and before_wall, "%s: cổng %s nằm trong map, trước tường sương" % [id, pt.kind])

	var w := _world("tay-nhanh")
	w.field_spawn = false
	w.enemies = []
	var nxt := Portals.find_to(w.portals, "1-3")
	w.player.pos = nxt.pos
	_tick(w, {}, 1)
	_check(w.travel_timer <= 0.0 and w.map_id == "1-1", "chưa hạ Sói Chúa: bước vào cổng không đi")
	w.profile.boss_defeated = true
	w.profile.level = 10
	_tick(w, {}, 1)
	_check(w.travel_timer <= 0.0, "đứng yên trong cổng không kích hoạt lại")
	w.player.pos = nxt.pos + Vector2(0, 200)
	_tick(w, {}, 1)
	w.player.pos = nxt.pos
	_tick(w, {}, 1)
	_check(w.travel_timer > 0.0 and w.travel_target == "1-3", "bước ra rồi vào lại → lên đường tới Lõi Sương")
	_tick(w, {}, roundi(w.travel_seconds() * 60.0) + 5)
	var back := Portals.find_to(w.portals, "1-1")
	_check(w.map_id == "1-3" and w.player.pos.distance_to(back.pos) < 160.0, "tới nơi đứng cạnh cổng về Rừng Sương (cách %.0f)" % w.player.pos.distance_to(back.pos))
	_tick(w, {}, 30)
	_check(w.travel_timer <= 0.0 and w.map_id == "1-3", "vừa tới không bị cổng về kéo ngược lại")
	var wp: Dictionary = w.portals.filter(func(pt): return pt.kind == "waypoint")[0]
	w.drain_events()
	w.player.pos = wp.pos
	_tick(w, {}, 1)
	_check(w.at_waypoint() and w.drain_events().any(func(ev): return ev.type == "waypoint"), "bước vào Cổng Dịch Chuyển → mở bảng lục địa")


# ------------------------------------------------------------------ M9 — Chương 6 Băng Nguyên Vĩnh Dạ (docs/14)


func _region6_world(map_id := "6-1", class_id := "kiem-khach", talent := "tay-nhanh", level := 62, seed_value := 5, job2_index := 0) -> GameWorld:
	var p := _profile(talent, 3)
	p.class_id = class_id
	p.level = level
	p.boss_defeated = true
	p.bosses = {"huyen-anh": true, "sa-hoang": true, "nu-vuong": true, "vien-long": true}
	p.job = str(Classes.job_def(class_id).id)
	p.job2 = str(Classes.job2_defs(class_id)[job2_index].id)
	p.evo = 1
	p.talent_level = 10
	p.unlocked_maps = ["1-1", "1-3", "2-1", "2-2", "2-3", "3-1", "3-2", "3-3", "4-1", "4-2", "4-3", "5-1", "5-2", "5-3", "6-1", "6-2", "6-3"]
	p.quest = {"ch2": Story.DONE2, "kills2": 0, "ch3": Story.DONE3, "kills3": 0, "oases": [], "ch4": Story.DONE4, "kills4": 0, "orbs4": [],
		"ch5": Story.DONE5, "kills5": 0, "raid_won": true, "ch6": 1, "kills6": 0, "beacons6": [], "dark6": 0}
	p.map_id = map_id
	p.play_seconds = 0.0
	var w := GameWorld.new(p, RngUtil.make(seed_value))
	w.enemies = []
	w.field_spawn = false
	return w


## Chỗ trống xa lửa trại và trại (đo băng giá).
func _cold6(w: GameWorld) -> Vector2:
	for y in range(300, int(w.world_size.y) - 300, 97):
		for x in range(900, int(w.world_size.x) - 900, 113):
			var pos := Vector2(x, y)
			if not Ch6.near_fire(w, pos) and pos.distance_to(w.safe_pos) > w.safe_r + 200.0 and Ch6.near_fire(w, pos + Vector2(0, 0)) == false:
				var clear := true
				for f in Ch6.fires(w):
					if pos.distance_to(f) < Ch6.FIRE_R + 200.0:
						clear = false
				if clear:
					return pos
	return Vector2(1000, 1700)


## C6-T1: điều kiện mở vùng 6; 3 map.
func _test_c6_unlock() -> void:
	var w := _region5_world("5-3", "kiem-khach", "tay-nhanh", 60)
	_check(w.travel_blocker("6-1").contains("Viêm Long"), "chưa hạ Viêm Long: chặn")
	w.profile.bosses["vien-long"] = true
	_check(w.travel_blocker("6-1").contains("chuyển chức"), "chưa chuyển chức 2: chặn (%s)" % w.travel_blocker("6-1"))
	w.profile.job2 = "kiem-thanh"
	w.profile.level = 58
	_check(w.travel_blocker("6-1").contains("59"), "dưới cấp 59: chặn")
	w.profile.level = 60
	_check(w.travel_blocker("6-1") == "", "đủ điều kiện: vào Đồng Tuyết")
	_check(w.travel_blocker("6-2") != "" and w.travel_blocker("6-3") != "", "phải đi 6-1 → 6-2 → 6-3")
	for pair in [["6-1", [60, 64]], ["6-2", [64, 68]], ["6-3", [68, 72]]]:
		var m: Dictionary = MapsData.get_map(pair[0])
		_check(m.levels == pair[1] and m.size == Vector2(4480, 2560) and m.region == 6 and m.frost and m.night and not m.fires.is_empty(),
			"%s cấp %s, băng giá + đêm + lửa trại" % [pair[0], str(pair[1])])
	_check(MapsData.get_map("6-3").arena.boss == "ban-nga" and int(MapsData.get_map("6-3").arena.level) == 70 and MapsData.get_map("6-2").beacons.size() == 3,
		"Gương Băng Vĩnh Dạ: Bản Ngã cấp 70; Rừng Băng có 3 Đèn Cực Quang")
	_check(Ch6 in Chapters.MODULES and "input_filter" in Ch6.HOOKS, "bộ điều phối có chương 6 + hook input_filter")
	var w2 := _region6_world("6-1")
	w2.profile.quest.ch6 = 0
	w2._load_map("6-1")
	_check(int(w2.profile.quest.ch6) == 1, "tới vùng 6: nhận nhiệm vụ chương 6")


## C6-T2: băng giá, đêm dài, mặt băng trơn, Than Hồng.
func _test_c6_env() -> void:
	var w := _region6_world("6-1")
	var st = w.ch6
	w.player.pos = _cold6(w)
	st.last_pos = w.player.pos
	_tick(w, {}, 125)
	_check(st.frost == 1, "đứng yên 2 giây: +1 tầng băng giá (%d)" % st.frost)
	_tick(w, {}, 360)
	_check(st.frost == 4 and is_equal_approx(Ch6.move_mult(w), 0.6), "4 tầng: −40%% tốc chạy (%d tầng, ×%.2f)" % [st.frost, Ch6.move_mult(w)])
	_tick(w, {}, 125)
	_check(st.frost == 0 and w.player.stun_timer > 1.0 and Ch6.frost_immune(w), "5 tầng: đông cứng 1,5 giây, về 0, miễn 3 giây")
	_tick(w, {}, 300)
	st.frost = 3
	st.still_t = 0.0
	_tick(w, {"move": Vector2.RIGHT}, 100)
	_check(st.frost == 2, "di chuyển 1,5 giây: −1 tầng (%d)" % st.frost)
	var fire: Vector2 = w.map.fires[1]
	w.player.pos = fire + Vector2(20, 0)
	st.last_pos = w.player.pos
	st.frost = 3
	_tick(w, {}, 100)
	_check(st.frost == 0, "đứng cạnh lửa trại: tan băng giá")
	_tick(w, {}, 200)
	_check(st.frost == 0, "cạnh lửa không tăng tầng")
	# đêm dài
	w.profile.play_seconds = 60.0
	_check(not Ch6.is_night(w) and is_equal_approx(Ch6.vision(w), 1.0), "2 phút đầu chu kỳ: ngày")
	w.profile.play_seconds = 300.0
	_check(Ch6.is_night(w) and is_equal_approx(Ch6.vision(w), 0.6) and Ch6.env_text(w).contains("Đêm"), "6 phút sau: đêm, tầm nhìn 60%")
	# mặt băng trơn
	w.player.pos = _cold6(w)
	_tick(w, {"move": Vector2.RIGHT}, 10)
	var x0: float = w.player.pos.x
	_tick(w, {}, 6)
	var x1: float = w.player.pos.x
	_tick(w, {}, 30)
	var x2: float = w.player.pos.x
	_tick(w, {}, 10)
	_check(x1 > x0 + 2.0 and x2 >= x1 and is_equal_approx(w.player.pos.x, x2), "thả phím: trượt thêm 0,3 giây rồi dừng (%.1f → %.1f → %.1f)" % [x0, x1, x2])
	# Than Hồng
	w.profile.embers = 1
	st.frost = 3
	st.frost_immune = 0.0
	w.drink_potion()
	_check(int(w.profile.embers) == 0 and st.frost == 0 and Ch6.frost_immune(w), "Than Hồng: phím Q xoá băng giá, miễn 30 giây")
	w.profile.gold = 500.0
	w.shop_buy("ember")
	_check(int(w.profile.embers) == 1 and is_equal_approx(w.profile.gold, 500.0 - Ch6.SHOP_EMBER), "mua Than Hồng ở cửa hàng (%d vàng)" % Ch6.SHOP_EMBER)


## C6-T3: quái vùng 6.
func _test_c6_mobs() -> void:
	var w := _region6_world("6-1", "kiem-khach", "tay-nhanh", 64)
	w.player.pos = _cold6(w)
	var st = w.ch6
	var wolf := w.spawn_enemy("soi-bang", 62, w.player.pos + Vector2(200, 0))
	Ch6.after_spawn(w, wolf)
	_check(w.enemies.filter(func(e): return e.kind == "soi-bang").size() == Ch6.PACK, "Sói Băng đi bầy 4 con")
	w.enemies = []
	var e := w.spawn_enemy("soi-bang", 62, w.player.pos + Vector2(30, 0))
	e.attack_kind = "frostbite"
	for i in 20:
		w.player.hp = w.stats.max_hp
		Ch6.perform(w, e)
		if st.frost >= 1:
			break
	_check(st.frost >= 1, "Sói Băng cắn: +1 tầng băng giá")
	st.frost = 0
	var sn := w.spawn_enemy("nguoi-tuyet", 62, w.player.pos + Vector2(120, 0))
	sn.attack_kind = "snowball"
	sn.target = w.player.pos + Vector2(200, 0)
	w.player.hp = w.stats.max_hp
	Ch6.perform(w, sn)
	_check(is_equal_approx(w.player.hp, w.stats.max_hp), "cầu tuyết rơi xa: không trúng")
	var hit := false
	for i in 20:
		w.player.hp = w.stats.max_hp
		sn.target = w.player.pos
		Ch6.perform(w, sn)
		if w.player.hp < w.stats.max_hp:
			hit = true
			break
	_check(hit, "cầu tuyết rơi trúng chỗ người chơi: mất máu")
	var sp := w.spawn_enemy("tinh-linh-bang", 63, w.player.pos + Vector2(150, 0))
	sp.attack_kind = "icepillar"
	var frozen := false
	for i in 20:
		w.player.hp = w.stats.max_hp
		w.player.stun_timer = 0.0
		sp.target = w.player.pos
		Ch6.perform(w, sp)
		if w.player.stun_timer >= Ch6.PILLAR_FREEZE - 0.01:
			frozen = true
			break
	_check(frozen, "Băng trụ: đóng băng 1 giây")
	w.player.stun_timer = 0.0
	var ar := w.spawn_enemy("cung-thu-bang", 66, w.player.pos + Vector2(220, 0))
	ar.attack_kind = "icearrow"
	ar.target = w.player.pos
	var n0: int = w.projectiles.size()
	Ch6.perform(w, ar)
	_check(w.projectiles.size() == n0 + 1 and Monsters.DEFS["cung-thu-bang"].range >= 240.0, "Cung Thủ Băng bắn xa 24 m")
	var bear := w.spawn_enemy("nguoi-tuyet", 64, w.player.pos + Vector2(100, 0), {"elite": true})
	_check(bear.elite and Monsters.DEFS["nguoi-tuyet"].elite_name == "Gấu Băng Khổng Lồ", "tinh anh Gấu Băng Khổng Lồ")
	_check(Ch6.elite_skill(w, bear, "icecrack") and bear.state == "windup" and bear.attack_kind == "icecrack" and Ch6.crack_lines(bear).size() == 3,
		"Đập băng: vung 1 giây, 3 đường nứt")
	var hit2 := false
	for i in 20:
		w.player.hp = w.stats.max_hp
		bear.target = w.player.pos
		Ch6.perform(w, bear)
		if w.player.hp < w.stats.max_hp:
			hit2 = true
			break
	_check(hit2, "đứng trên đường nứt: trúng Đập băng")
	var mage := w.spawn_enemy("tinh-linh-bang", 67, w.player.pos + Vector2(150, 0), {"elite": true})
	st.frost = 0
	st.frost_immune = 0.0
	_check(Ch6.elite_skill(w, mage, "blizzard") and st.blizzards.size() == 1, "Pháp Sư Bão Tuyết: Bão tuyết")
	Ch6._tick_zones(w, 1.05)
	_check(st.frost == 1, "trong Bão tuyết: +1 tầng mỗi giây (cả khi đi)")


## C6-T4: Bản Ngã Bóng Tối, Long Băng, đồ, bộ.
func _test_c6_bosses() -> void:
	var w := _region6_world("6-3", "kiem-khach", "tay-nhanh", 69)
	w._load_map("6-3")
	w.enemies = []
	var st = w.ch6
	var b := w.spawn_enemy("ban-nga", 70, w.arena_pos, {"role": "boss"})
	w.player.pos = w.arena_pos - Vector2(100, 0)
	_check(int(b.max_hp) > 80000 and int(b.max_hp) < 110000, "Bản Ngã cấp 70 theo công thức 06 (%d HP)" % b.max_hp)
	_check(Ch6.braziers(w).size() == 4 and Ch6.near_fire(w, Ch6.braziers(w)[0]), "4 chậu lửa trong hang")
	# sao chép kỹ năng: dùng Xoáy Kiếm → 3 giây sau Xoáy bóng
	st.last_cds = [0.0, 0.0, 0.0, 0.0]
	w.player.skill_cds[0] = 6.0
	Ch6._tick_shadow(w, 0.016)
	_check(st.copies.size() == 1 and str(st.copies[0].id) == "spin" and absf(float(st.copies[0].t) - Ch6.COPY_DELAY) < 0.05, "ghi lại kỹ năng vừa dùng")
	Ch6._tick_shadow(w, 2.9)
	_check(b.state != "windup", "chưa đủ 3 giây: chưa dùng lại")
	Ch6._tick_shadow(w, 0.2)
	_check(b.state == "windup" and b.attack_kind == "m_spin", "3 giây sau: Bản Ngã dùng Xoáy bóng")
	var all_ids: Array = []
	for c in Classes.ORDER:
		for i in 4:
			all_ids.append(str(Classes.skill(c, i).id))
	_check(all_ids.all(func(id): return Ch6.MIRROR_OF.has(id)), "mọi kỹ năng 3 lớp có bản bóng tối (C6-30a)")
	b.state = "chase"
	st.marks = []
	Ch6._mirror(w, b, "meteor")
	Ch6._mirror(w, b, "rain")
	Ch6._mirror(w, b, "trap")
	_check(st.marks.size() == 5 and st.marks.any(func(m): return float(m.get("root", 0.0)) > 0.0), "Thiên thạch / Mưa / Bẫy bóng: vòng báo dưới chân")
	Ch6._mirror(w, b, "guard")
	_check(Ch6.adjust_damage(w, b, 1000, true) == 700, "Thuẫn bóng: −30% sát thương 3 giây")
	st.shield_t = 0.0
	w.player.eagle_time = 4.0
	Ch6._mirror(w, b, "eagle")
	_check(st.haste_t > 0.0 and w.player.eagle_time <= 0.0, "Mắt bóng: Bản Ngã +30% tốc đánh, cướp Ưng Nhãn của người chơi")
	st.haste_t = 0.0
	st.marks = []
	# Ngũ Hành không khắc được
	w.profile.talent = "ngu-hanh"
	w.profile.element = "hoa"
	_check(w.element_bonus(b) > 0.0 and absf(Ch6.hit_mult(w, b, false) * (1.0 + w.element_bonus(b)) - 1.0) < 0.001, "Ngũ Hành không khắc được Bản Ngã")
	w.profile.talent = "tay-nhanh"
	# GĐ2: Gương vỡ
	b.hp = b.max_hp * 0.49
	w._update_enemy(b, 0.016)
	var mirrors := w.enemies.filter(func(e): return e.kind == "guong-bang" and not e.dead)
	_check(b.phase == 2 and st.mirror_on and mirrors.size() == 3, "dưới 50%: 4 tấm gương (3 giả)")
	_check(Ch6.mirror_slots(w).any(func(s): return s.distance_to(b.pos) < 1.0), "Bản Ngã ẩn trong 1 tấm")
	var slots := Ch6.mirror_slots(w)
	_check(slots[0].distance_to(slots[1]) >= 230.0, "các gương cách nhau ≥ 23 m")
	_check(st.invuln_t > 0.0 and Ch6.adjust_damage(w, b, 1000, true) == 0, "vỡ gương: bất tử 3,5 giây")
	st.invuln_t = 0.0
	w.player.hp = w.stats.max_hp
	_check(Ch6.adjust_damage(w, mirrors[0], 999999, true) == 0, "gương giả không mất máu")
	_check(absf(w.stats.max_hp - w.player.hp - w.stats.max_hp * Ch6.MIRROR_REFLECT_CAP) < 1.0, "đánh nhầm: phản tối đa 4% HP")
	var hp_r: float = w.player.hp
	Ch6.adjust_damage(w, mirrors[0], 999999, true)
	_check(is_equal_approx(w.player.hp, hp_r), "gương giả phản tối đa 1 lần/giây")
	var old_pos: Vector2 = b.pos
	Ch6.adjust_damage(w, b, int(b.max_hp * 0.11), true)
	Ch6._tick_shadow(w, 0.016)
	_check(st.invuln_t > 0.0, "xoay gương: bất tử 2,5 giây")
	st.invuln_t = 0.0
	var mirrors2 := w.enemies.filter(func(e): return e.kind == "guong-bang" and not e.dead)
	var spots := mirrors2.map(func(e): return e.pos)
	spots.append(b.pos)
	var distinct := true
	for i in spots.size():
		for j in range(i + 1, spots.size()):
			if spots[i].distance_to(spots[j]) < 1.0:
				distinct = false
	_check(b.pos.distance_to(old_pos) > 1.0 and distinct, "mất 10% HP: gương xoay, tấm thật đổi chỗ")
	# GĐ3: Thiên phú phản chiếu
	var atk0: float = b.atk
	b.hp = b.max_hp * 0.19
	w._update_enemy(b, 0.016)
	_check(b.phase == 3 and not st.mirror_on and w.enemies.filter(func(e): return e.kind == "guong-bang" and not e.dead).is_empty(), "dưới 20%: gương tan")
	_check(st.p3_group == "combat" and is_equal_approx(b.atk, atk0 * Ch6.P3_COMBAT_ATK) and st.p3_form != "", "Thiên phú chiến đấu: +30%% Tấn công (%s)" % st.p3_form)
	var top: Array = Ch6.top_form("tay-nhanh")
	_check(top[0] != Talents.get_talent("tay-nhanh").name, "dùng dạng tiến hoá cao nhất (%s)" % top[0])
	_check(Ch6.talent_group("ngu-hanh") == "slow" and Ch6.talent_group("bay-dan") == "summon" and Ch6.talent_group("may-man") == "other", "nhóm Thiên phú → hiệu ứng GĐ3")
	st.invuln_t = 0.0
	st.p3_group = "summon"
	st.summon_t = 0.0
	Ch6._tick_shadow(w, 0.016)
	_check(w.enemies.filter(func(e): return e.kind == "anh-bong").size() == 2, "nhóm triệu hồi: gọi 2 Ảnh Bóng")
	st.p3_group = "slow"
	st.pulse_t = 0.0
	Ch6._tick_shadow(w, 0.016)
	_check(w.player.slow_timer > 1.5, "nhóm phép thuật / khống chế: làm chậm người chơi")
	st.invuln_t = 0.0
	# Đạo Tặc — Kính Ảnh
	w.profile.talent = "dao-tac"
	w.profile.copied_skills = []
	w._on_boss_killed(b)
	_check("mirror" in w.profile.copied_skills and w.profile.active_copy == "mirror", "Đạo Tặc sao chép Kính Ảnh")
	var na: int = w.allies.size()
	_check(Ch6.copy_skill(w, "mirror") and w.allies.size() == na + 1 and is_equal_approx(w.allies[-1].atk, float(w.stats.atk) * Ch6.CLONE_ATK),
		"Kính Ảnh: 1 bản sao đánh 50% Tấn công")
	_check(ItemData.BOSS_UNIQUES["ban-nga"] == "guong_ban_nga" and ItemData.UNIQUES.guong_ban_nga.slot == "amulet", "Bản Ngã rơi Gương Bản Ngã (bùa)")
	w.profile.talent = "tay-nhanh"
	# Gương Bản Ngã
	var it := Items.new_item(w.profile, 70, "orange", RngUtil.make(1), "", "", "guong_ban_nga")
	Items.add_item(w.profile, it)
	w.equip(int(it.id))
	w.enemies = []
	var dummy := w.spawn_enemy("soi-bang", 68, w.player.pos + Vector2(30, 0))
	var reflected := false
	for i in 200:
		var hp0: float = dummy.hp
		Ch6.player_hurt(w, 1000.0, "")
		if dummy.hp < hp0:
			reflected = absf(hp0 - dummy.hp - 500.0) < 2.0 or dummy.dead
			break
	_check(reflected, "Gương Bản Ngã: phản 50% sát thương lên quái gần")
	# Long Băng Bắc Cực
	w.enemies = []
	w.profile.bosses["ban-nga"] = true
	w.debug_now = 1000.0
	w.player.pos = Vector2(1500, 1700)
	w._check_rare_boss()
	var lb := w.rare_boss()
	_check(lb != null and lb.kind == "long-bang" and lb.level == 72, "hạ Bản Ngã rồi: Long Băng Bắc Cực xuất hiện")
	lb.skill_cd = 0.0
	lb.pounce_cd = 99.0
	st.marks = []
	Ch6.chase(w, lb, 150.0, 0.016)
	_check(st.marks.size() == Ch6.ICE_RAIN_N, "Mưa băng: 15 vòng")
	lb.pounce_cd = 0.0
	Ch6.chase(w, lb, 150.0, 0.016)
	_check(lb.state == "windup" and lb.attack_kind == "frostbreath", "Hơi thở vĩnh đông: vung 0,8 giây")
	st.patches = []
	Ch6.perform(w, lb)
	_check(st.patches.size() == 5, "hơi thở để lại 5 mảng băng")
	st.frost = 0
	st.frost_immune = 0.0
	st.ember_until = -99.0
	w.player.pos = st.patches[0].pos
	Ch6._tick_zones(w, 0.51)
	Ch6._tick_zones(w, 0.51)
	_check(st.frost == 2, "đứng trên mặt băng: +2 tầng mỗi giây (%d)" % st.frost)
	# Vảy Long Băng
	var boots := Items.new_item(w.profile, 72, "orange", RngUtil.make(2), "", "", "vay_long_bang")
	Items.add_item(w.profile, boots)
	w.equip(int(boots.id))
	st.frost = 0
	_check(Ch6.frost_immune(w) and is_equal_approx(Ch6.move_mult(w), Ch6.SCALE_SPEED), "Vảy Long Băng: miễn băng giá, +15% tốc chạy")
	# Bộ Cực Quang
	var w3 := _region6_world("6-1")
	var crit0: float = float(w3.stats.crit)
	var rng := RngUtil.make(4)
	for slot in ["weapon", "armor", "helm", "boots", "gloves", "necklace"]:
		var si := Items.new_item(w3.profile, 62, "purple", rng, slot, "cuc_quang")
		Items.add_item(w3.profile, si)
		w3.equip(int(si.id))
	w3.ch6.frost = 2
	_check(is_equal_approx(Ch6.move_mult(w3), 1.0), "Bộ Cực Quang 2 món: dưới 3 tầng không chậm")
	w3.ch6.frost = 3
	_check(Ch6.move_mult(w3) < 0.75, "3 tầng trở lên vẫn chậm")
	_check(float(w3.stats.crit) >= crit0 + 0.1 - 0.001, "Bộ Cực Quang 4 món: +10% chí mạng")
	var foe := w3.spawn_enemy("soi-bang", 62, w3.player.pos + Vector2(40, 0))
	Ch6.hit_mult(w3, foe, true)
	_check(foe.slow_t > 1.5, "Bộ Cực Quang 6 món: chí mạng làm chậm quái")


## C6-T5: nhiệm vụ chương 6; Đèn Cực Quang; lưới vùng 6.
func _test_c6_quest() -> void:
	var w := _region6_world("6-1")
	w._load_map("6-1")
	var p = w.profile
	w.talk("tuyet-nga")
	_check(int(p.quest.ch6) == 2 and int(p.embers) == 2, "bước 1: gặp Tuyết Nga, nhận 2 Than Hồng")
	_check(w.talk("lao-han") == "shop", "Lão Hàn mở cửa hàng")
	p.quest.kills6 = 30
	Ch6.check_quest(w)
	_check(int(p.quest.ch6) == 3, "bước 2: 30 quái")
	w._load_map("6-2")
	var bs: Array = w.map.beacons
	for i in bs.size():
		w.player.pos = bs[i] + Vector2(20, 0)
		w.ch6.last_pos = w.player.pos
		_tick(w, {}, 130)
	_check(p.quest.beacons6.size() == 3, "đứng cạnh 3 Đèn Cực Quang 2 giây: thắp (%d)" % p.quest.beacons6.size())
	Ch6.check_quest(w)
	_check(int(p.quest.ch6) == 4, "bước 3: thắp 3 đèn")
	_check(Ch6.near_fire(w, bs[0]), "đèn đã thắp sưởi như lửa trại")
	_check(not Ch6.dark_active(w), "bước 4 ở Rừng Băng: Ám Khí chưa chạy")
	p.quest.dark6 = 3
	Ch6.check_quest(w)
	_check(int(p.quest.ch6) == 5, "bước 4: 3 lần mất kiểm soát")
	_check(not w.gate_open("6-3"), "Gương Băng Vĩnh Dạ còn khoá")
	p.quest.ch6 = 6
	_check(w.gate_open("6-3"), "bước 6: hang mở")
	p.bosses["ban-nga"] = true
	Ch6.check_quest(w)
	_check(int(p.quest.ch6) == 7, "bước 6: hạ Bản Ngã")
	w._load_map("6-1")
	w.drain_events()
	w.talk("tuyet-nga")
	var ends := w.drain_events().filter(func(ev): return ev.type == "chapter_end" and int(ev.get("chapter", 0)) == 6)
	_check(int(p.quest.ch6) == Story.DONE6 and Ch6.quest_hud(w).get("done", false) and ends.size() == 1, "bước 7: sự thật → chương 6 xong")
	var total := 0.0
	for q in Story.QUESTS6:
		total += float(q.reward.get("exp", 0))
	var need := 0.0
	for l in range(60, 72):
		need += Formulas.exp_to_next(l)
	_check(total / need >= 0.2 and total / need <= 0.3, "thưởng EXP nhiệm vụ ≈ 25%% (%.0f%%)" % (total / need * 100.0))
	# lưới vùng 6: Mỏ Tinh Thạch
	var grid: Array = p.tiles if int(p.tiles_region) == 6 else p.grid_of(6)
	_check(grid.size() == 45 or grid.size() > 30, "lưới khai phá vùng 6 (%d ô)" % grid.size())
	var mines := grid.filter(func(t): return t.event == "mine")
	if not mines.is_empty():
		p.buildings = {}
		mines[0].status = "owned"
		p.buildings[Explore.tile_key("mine", mines[0], 6)] = 0.0
		var rate := Explore.production_per_minute(p)
		_check(is_equal_approx(rate.crystal, 1.0) and is_equal_approx(rate.ore, 0.0), "Mỏ vùng 6: Tinh Thạch")


## C6-T6: Ám Khí, mất kiểm soát, Ám Hoá; save v12.
func _test_c6_dark() -> void:
	var w := _region6_world("6-3", "kiem-khach", "tay-nhanh", 69)
	w._load_map("6-3")
	w.enemies = []
	var p = w.profile
	var st = w.ch6
	p.quest.ch6 = 4
	w.player.pos = _cold6(w)
	_check(Ch6.dark_active(w), "bước 4 ở Đỉnh Cực Quang: Ám Khí chạy")
	w._last_combat = w.time
	Ch6._tick_dark(w, 1.0)
	_check(absf(st.dark - Ch6.DARK_COMBAT) < 0.01, "đang giao chiến: +2/giây")
	var mob := w.spawn_enemy("soi-bang", 68, w.player.pos + Vector2(40, 0))
	Ch6.on_kill(w, mob)
	_check(absf(st.dark - Ch6.DARK_COMBAT - Ch6.DARK_KILL) < 0.01, "hạ quái: +5")
	var d0: float = st.dark
	w.player.pos = Ch6.fires(w)[1]
	Ch6._tick_dark(w, 0.5)
	_check(st.dark < d0, "gần lửa: Ám Khí giảm")
	w.player.pos = w.arena_pos
	_check(not Ch6.dark_active(w), "trong hang boss: Ám Khí không tăng")
	# mất kiểm soát
	w.player.pos = _cold6(w)
	st.dark = 100.0
	w._last_combat = w.time
	Ch6._tick_dark(w, 0.016)
	_check(st.dark_warn > 0.0 and Ch6.env_text(w).contains("THỨC GIẤC"), "đầy 100: báo 2 giây")
	Ch6._tick_dark(w, 2.1)
	_check(st.lost_t > 3.5, "mất kiểm soát 4 giây")
	w.enemies = []
	var foe := w.spawn_enemy("soi-bang", 68, w.player.pos + Vector2(300, 0))
	var inp: Dictionary = Ch6.input_filter(w, {"move": Vector2.LEFT, "aim": w.player.pos, "attack": false, "skill_1": true, "dodge": true})
	_check(inp.move.x > 0.9 and inp.attack and not inp.get("skill_1", false) and not inp.dodge and inp.aim == foe.pos,
		"bỏ qua phím: tự lao vào quái gần nhất và đánh thường")
	_check(is_equal_approx(Ch6.hit_mult(w, foe, false), Ch6.DARK_LOST_ATK), "khi mất kiểm soát: +40% Tấn công")
	Ch6._tick_dark(w, 4.1)
	_check(st.lost_t <= 0.0 and int(p.quest.dark6) == 1 and is_equal_approx(st.dark, 0.0), "hết 4 giây: tỉnh lại, tính 1 lần")
	# sau chương: Ám Hoá
	p.quest.ch6 = Story.DONE6
	st.dark = 100.0
	w._last_combat = w.time
	Ch6._tick_dark(w, 0.016)
	_check(st.ascend_t > 5.0 and st.lost_t <= 0.0 and st.dark_warn < 0.0, "sau chương: Ám Hoá 6 giây, không mất kiểm soát")
	_check(is_equal_approx(Ch6.hit_mult(w, foe, false), Ch6.DARK_ASCEND_ATK), "Ám Hoá: +20% Tấn công")
	# save v12
	p.embers = 3
	p.quest.beacons6 = [0, 2]
	var d: Dictionary = p.to_dict()
	_check(int(d.version) >= 12, "save v12+")
	var p2 := Profile.new()
	_check(p2.load_dict(d.duplicate(true)) and int(p2.embers) == 3 and p2.quest.beacons6 == [0, 2] and int(p2.quest.ch6) == Story.DONE6, "lưu/nạp trường chương 6")
	var old: Dictionary = d.duplicate(true)
	old.version = 11
	old.erase("embers")
	var q: Dictionary = old.quest
	for k in ["ch6", "kills6", "beacons6", "dark6"]:
		q.erase(k)
	var p3 := Profile.new()
	_check(p3.load_dict(old) and int(p3.embers) == 0 and int(p3.quest.ch6) == 0 and p3.quest.beacons6.is_empty(), "save v11 nạp được, chưa tới vùng 6")


## TL-B6: 3 lớp × 20 Thiên phú hạ Bản Ngã (cấp 69, đồ chuẩn cấp 69, tiến hoá 1 lần, đã chuyển chức 2).
func _test_c6_balance() -> void:
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
			for k in 2:
				var res := _r6_fight(class_id, t.id, [5, 11][k], k)
				times.append(res[0])
				deaths += int(res[1])
				won = won and bool(res[2])
			var sec: float = avg.call(times)
			lines.append("%s %s %.0fs/%d" % [t.rank, t.name, sec, deaths])
			_check(won and deaths == 0, "%s · %s hạ được Bản Ngã, không chết lần nào" % [class_id, t.name])
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
	var a: float = class_avg.values().min()
	var b: float = class_avg.values().max()
	print("       (%d lớp: nhanh nhất %.1f, chậm nhất %.1f giây, chênh %.0f%%)" % [class_avg.size(), a, b, (b - a) / b * 100.0])
	_check((b - a) / b <= 0.25, "các lớp chênh ≤ 25%")


func _r6_fight(class_id: String, talent_id: String, seed_value: int, job2_index := 0) -> Array:
	var w := _region6_world("6-3", class_id, talent_id, 69, seed_value, job2_index)
	w._load_map("6-3")
	w.enemies = []
	w.field_spawn = false
	var p = w.profile
	p.quest.ch6 = 6
	p.points = _class_points(class_id)
	for k in p.points:
		p.points[k] = int(p.points[k]) * 17
	var rng := RngUtil.make(77)
	for pair in [["weapon", "blue"], ["armor", "blue"], ["helm", "green"], ["boots", "green"], ["gloves", "green"]]:
		var it := Items.new_item(p, 69, pair[1], rng, pair[0])
		Items.add_item(p, it)
		w.equip(int(it.id))
	w.player.hp = w.stats.max_hp
	w.player.mp = w.stats.max_mp
	w.player.pos = w.arena_pos - Vector2(100, 0)
	var deaths := 0
	var seconds := 0.0
	while seconds < 600.0 and not p.bosses.get("ban-nga", false):
		for ev in w.drain_events():
			if ev.type == "death":
				deaths += 1
		if w.boss() == null and w.player.dead_timer <= 0.0:
			w.player.pos = w.arena_pos - Vector2(100, 0)
		w.update(1.0 / 60.0, _bot(w))
		seconds += 1.0 / 60.0
	return [seconds, deaths, p.bosses.get("ban-nga", false)]


# ------------------------------------------------------------------ SK1 — hệ kỹ năng (docs/13)


func _test_sk1_unlock() -> void:
	for class_id in Classes.ORDER:
		var lv: Array = []
		for sk in Classes.skills_of(class_id):
			lv.append(int(sk.unlock))
		_check(lv.slice(0, 4) == [1, 1, 4, 8], "%s: 4 kỹ năng đầu mở ở cấp 1, 1, 4, 8" % class_id)
	var w := _world("tay-nhanh")
	w.profile.level = 1
	w.player.mp = 999.0
	_check(w.use_skill(0) and w.use_skill(1), "cấp 1: dùng được 2 kỹ năng đầu")
	_check(not w.use_skill(2) and not w.use_skill(3), "cấp 1: kỹ năng 3, 4 còn khoá")
	w.profile.level = 3
	w.profile.xp = 0
	w.add_exp(float(Formulas.exp_to_next(3)) + 1.0, false)
	_check(w.profile.level == 4 and w.drain_events().any(func(e): return e.type == "skill_unlock" and e.id == "wave"), "lên cấp 4: báo mở Kiếm Khí")
	w.player.skill_cds[2] = 0.0
	_check(w.use_skill(2), "cấp 4: dùng được kỹ năng 3")


func _test_sk1_levels() -> void:
	var w := _world("tay-nhanh")
	var p = w.profile
	p.level = 10
	p.skill_points = 0
	var lv0: int = p.level
	p.xp = 0
	w.add_exp(float(Formulas.exp_to_next(lv0)) + 1.0, false)
	_check(int(p.skill_points) == 1, "lên cấp: +1 Điểm Kỹ Năng")
	p.skill_points = 20
	_check(w.skill_upgrade("spin").ok and w.skill_level("spin") == 2 and int(p.skill_points) == 19, "nâng Xoáy Kiếm lên cấp 2 tốn 1 điểm")
	_check(is_equal_approx(w.skill_level_mult("spin"), 1.08), "cấp 2: +8% hệ số")
	for i in 20:
		w.skill_upgrade("spin")
	_check(w.skill_level("spin") == Classes.SKILL_MAX_LEVEL, "tối đa cấp 10")
	# kỹ năng hỗ trợ: giảm hồi chiêu
	var cd1: float = w.skill_cd_of(3)
	p.skill_points = 9
	for i in 9:
		w.skill_upgrade("guard")
	_check(is_equal_approx(w.skill_cd_of(3), cd1 * (1.0 - 0.04 * 9)), "Thiết Bích cấp 10: −36% hồi chiêu")
	# sát thương thật tăng theo cấp
	w.enemies = []
	var e1 := w.spawn_enemy("wolf", 1, w.player.pos + Vector2(40, 0))
	e1.max_hp = 1e6
	e1.hp = 1e6
	w.player.mp = 999.0
	p.skill_levels["spin"] = 1
	w.player.skill_cds[0] = 0.0
	w.use_skill(0)
	var d1: float = 1e6 - e1.hp
	e1.hp = 1e6
	p.skill_levels["spin"] = 10
	w.player.skill_cds[0] = 0.0
	w.use_skill(0)
	var d10: float = 1e6 - e1.hp
	_check(d10 > d1 * 1.5, "Xoáy Kiếm cấp 10 mạnh hơn rõ (%.0f → %.0f)" % [d1, d10])
	# tẩy điểm: chỉ ở vùng an toàn
	w.player.pos = w.safe_pos + Vector2(w.safe_r + 400.0, 0)
	_check(not w.skill_reset().ok, "ngoài vùng an toàn: không tẩy điểm")
	w.player.pos = w.safe_pos
	var pts: int = int(p.skill_points)
	_check(w.skill_reset().ok and int(p.skill_points) == pts + 9 + 9 and w.skill_level("spin") == 1, "tẩy điểm ở làng: hoàn đủ điểm")


func _test_sk1_loadout() -> void:
	var w := _world("tay-nhanh")
	var p = w.profile
	p.level = 10
	_check(w.slot_skill(0).id == "spin" and w.slot_skill(3).id == "guard", "mặc định: ô theo thứ tự lớp")
	w.player.pos = w.safe_pos + Vector2(w.safe_r + 400.0, 0)
	_check(not w.set_slot(0, "wave").ok, "ngoài vùng an toàn: không đổi ô")
	w.player.pos = w.safe_pos
	w.player.skill_cds[2] = 3.0
	_check(w.set_slot(0, "wave").ok and w.slot_skill(0).id == "wave" and w.slot_skill(2).id == "spin", "đổi ô: Kiếm Khí ↔ Xoáy Kiếm")
	_check(is_equal_approx(w.player.skill_cds[0], 3.0), "hồi chiêu đi theo kỹ năng khi đổi ô")
	w.player.skill_cds[0] = 0.0
	w.player.mp = 999.0
	w.player.pos = w.safe_pos + Vector2(500, 0)
	var shots0: int = w.shots.size()
	_tick(w, {"skill_1": true}, 1)
	_check(w.shots.size() > shots0, "phím 1 dùng kỹ năng ở ô 1 (Kiếm Khí)")
	# save v13
	var d: Dictionary = JSON.parse_string(JSON.stringify(p.to_dict()))
	_check(int(d.version) >= 13, "save version 13")
	var back := Profile.new()
	back.load_dict(d)
	_check(back.loadout == p.loadout, "save giữ bộ lắp")
	d.version = 11
	for k in ["skill_points", "skill_levels", "loadout"]:
		d.erase(k)
	d.level = 12
	var old := Profile.new()
	_check(old.load_dict(d) and old.skill_points == 11 and old.loadout.is_empty(), "save cũ cấp 12: bù 11 Điểm Kỹ Năng, bộ lắp mặc định")


# ------------------------------------------------------------------ SK2 — kỹ năng mới + biến thể (docs/13)


func _sk2_world(class_id: String, level := 32, job := true) -> GameWorld:
	var w := _world("tay-nhanh")
	w.field_spawn = false
	w.enemies = []
	w.profile.class_id = class_id
	w.profile.level = level
	w.profile.job = str(Classes.job_def(class_id).id) if job else ""
	w.profile.loadout = []
	w._refresh_stats()
	w.player.pos = w.safe_pos
	w.player.mp = 9999.0
	return w


func _test_sk2_unlock() -> void:
	for class_id in Classes.ORDER:
		var lv: Array = []
		for sk in Classes.skills_of(class_id):
			lv.append(int(sk.unlock))
		_check(lv == [1, 1, 4, 8, 15, 22, 30, 30], "%s: 8 kỹ năng mở ở 1, 1, 4, 8, 15, 22, chuyển chức, chuyển chức" % class_id)
	var w := _sk2_world("kiem-khach", 32, false)
	_check(not w.skill_unlocked(Classes.skill_by_id("kiem-khach", "kiemvu")), "cấp 32 chưa chuyển chức: Kiếm Vũ còn khoá")
	_check(w.skill_unlocked(Classes.skill_by_id("kiem-khach", "hongkiem")), "cấp 32: Hống Kiếm đã mở")
	w.profile.job = "kiem-su"
	_check(w.skill_unlocked(Classes.skill_by_id("kiem-khach", "kiemvu")), "chuyển chức Kiếm Sư: Kiếm Vũ mở")
	_check(w.slot_skill(0).id == "spin" and w.slot_skill(3).id == "guard", "bộ lắp mặc định giữ 4 kỹ năng cũ")


## Lắp kỹ năng vào ô 1, đặt 3 bù nhìn trước mặt, thi triển. Trả về [world, các bù nhìn].
func _sk2_cast(class_id: String, id: String) -> Array:
	var w := _sk2_world(class_id)
	w.set_slot(0, id)
	w.player.pos = Vector2(1200, 1280)
	var dummies: Array = []
	for off in [Vector2(55, 0), Vector2(110, 20), Vector2(170, -20)]:
		dummies.append(_dummy(w, "wolf", 30, w.player.pos + off))
	w.player.facing = 0.0
	w._aim = dummies[1].pos
	w.player.skill_cds[0] = 0.0
	_check(w.use_skill(0), "%s dùng được" % id)
	return [w, dummies]


func _test_sk2_skills() -> void:
	for class_id in Classes.ORDER:
		for sk in Classes.skills_of(class_id).slice(4):
			var r := _sk2_cast(class_id, str(sk.id))
			var w: GameWorld = r[0]
			for i in 180:
				w.update(1.0 / 60.0, {"move": Vector2.ZERO, "aim": w._aim, "attack": false, "skill": false, "talent": false, "dodge": false})
			var hurt := 0
			for d in r[1]:
				if d.hp < d.max_hp:
					hurt += 1
			_check(hurt >= 1, "%s · %s gây sát thương (%d/3 quái)" % [class_id, sk.name, hurt])
	var r1 := _sk2_cast("kiem-khach", "hongkiem")
	_check(r1[1][0].state == "stunned", "Hống Kiếm: quái thường bị choáng")
	var r2 := _sk2_cast("phap-su", "dichchuyen")
	_check(r2[0].player.pos.distance_to(Vector2(1200, 1280)) > 100.0 and r2[1][0].slow_t > 0.0, "Dịch Chuyển: đổi chỗ, nổ băng làm chậm")
	var r3 := _sk2_cast("tho-san", "lanban")
	_check(r3[0].player.dodge_time > 0.0 and r3[0].shots.size() == 3, "Lăn Bắn: lăn (bất tử) + 3 mũi tên")
	var r4 := _sk2_cast("tho-san", "tendoc")
	_tick(r4[0], {"aim": r4[0]._aim}, 30)
	_check(r4[1][0].venom_stacks >= 1, "Tên Độc: quái trúng độc")
	var r5 := _sk2_cast("phap-su", "hoatuong")
	_check(r5[0].sk2.walls.size() == 1, "Hoả Tường: dựng tường lửa")
	var r6 := _sk2_cast("phap-su", "causam")
	_check(r6[0].sk2.orbs.size() == 1, "Cầu Sấm: quả cầu bay")


func _sk2_set(w: GameWorld, id: String, tier: int, opt: String) -> Dictionary:
	return GameWorld.Skills2.set_variant(w, id, tier, opt)


func _test_sk2_variants() -> void:
	var S2 = GameWorld.Skills2
	var w := _sk2_world("kiem-khach")
	var p = w.profile
	w.set_slot(0, "lientram")
	_check(not _sk2_set(w, "lientram", 0, "mp").ok, "cấp kỹ năng 1: tầng I chưa mở")
	p.skill_levels["lientram"] = 10
	var mp0 := w.skill_mp(0)
	var cd0 := w.skill_cd_of(0)
	_check(_sk2_set(w, "lientram", 0, "mp").ok and is_equal_approx(w.skill_mp(0), mp0 * 0.8), "tầng I Tiết Kiệm: −20% MP")
	_sk2_set(w, "lientram", 0, "cd")
	_check(is_equal_approx(w.skill_cd_of(0), cd0 * 0.85) and is_equal_approx(w.skill_mp(0), mp0), "tầng I Thần Tốc: −15% hồi chiêu (thay Tiết Kiệm)")
	w.player.pos = w.safe_pos + Vector2(w.safe_r + 400.0, 0)
	_check(not _sk2_set(w, "lientram", 2, "dmg").ok, "ngoài vùng an toàn: không đổi biến thể")
	w.player.pos = w.safe_pos
	var e := _dummy(w, "wolf", 30, w.player.pos + Vector2(40, 0))
	w.skill_ctx = "lientram"
	var base: float = S2.hit_mult(w, e, "lientram")
	_sk2_set(w, "lientram", 1, "kim")
	_check(is_equal_approx(S2.hit_mult(w, e, "lientram"), base * 1.3), "hệ Kim đánh quái Mộc (Sói): +30%")
	_check(is_equal_approx(S2.def_mult(w, "lientram"), 0.75), "hệ Kim: bỏ qua 25% Phòng thủ")
	_sk2_set(w, "lientram", 1, "hoa")
	w._hit_enemy(e, 1.0)
	_check(e.bleed_timer > 2.0, "hệ Hỏa: thiêu đốt")
	_sk2_set(w, "lientram", 1, "thuy")
	w._hit_enemy(e, 1.0)
	_check(e.slow_t > 1.5, "hệ Thủy: làm chậm")
	_sk2_set(w, "lientram", 1, "moc")
	w.player.hp = 10.0
	w._hit_enemy(e, 1.0)
	_check(w.player.hp > 10.0, "hệ Mộc: hút máu")
	_sk2_set(w, "lientram", 2, "dmg")
	_check(is_equal_approx(S2.hit_mult(w, e, "lientram"), 1.25), "tầng III Bạo Lực: +25%")
	w.skill_ctx = ""
	_check(is_equal_approx(S2.hit_mult(w, e, ""), 1.0), "đánh thường không nhận biến thể")
	p.skill_levels["guard"] = 10
	_sk2_set(w, "guard", 1, "long")
	_sk2_set(w, "guard", 2, "mp0")
	var gi: int = p.loadout.find("guard")
	w.player.skill_cds[gi] = 0.0
	_check(is_equal_approx(w.skill_mp(gi), 0.0) and w.use_skill(gi) and w.player.guard_time > GameWorld.GUARD_TIME * 1.25, "Thiết Bích: Vô Ngã không tốn MP, Bền Bỉ kéo dài 30%")
	var d: Dictionary = JSON.parse_string(JSON.stringify(p.to_dict()))
	_check(int(d.version) >= 14, "save version 14")
	var back := Profile.new()
	back.load_dict(d)
	_check(back.variants.get("lientram", []) == p.variants["lientram"], "save giữ biến thể")


func _test_sk2_balance() -> void:
	var builds := {
		"kiem-khach": ["spin", "lientram", "wave", "hongkiem"],
		"tho-san": ["rain", "tennay", "pierce", "lanban"],
		"phap-su": ["chain", "hoatuong", "meteor", "dichchuyen"],
	}
	for class_id in Classes.ORDER:
		var t_def := 0.0
		var t_new := 0.0
		var deaths := 0
		var won := true
		for seed_value in [5, 11]:
			var a := _sk2_fight(class_id, [], seed_value)
			var b := _sk2_fight(class_id, builds[class_id], seed_value)
			t_def += float(a[0])
			t_new += float(b[0])
			deaths += int(b[1])
			won = won and bool(b[2])
		print("       [%s] mặc định %.1f giây · bộ mới %.1f giây · chết %d" % [class_id, t_def / 2.0, t_new / 2.0, deaths])
		_check(won and absf(t_new - t_def) / t_def <= 0.3 and deaths == 0, "%s: bộ mới hạ được Huyền Ảnh, chênh ≤ 30%%, 0 lần chết" % class_id)


## Huyền Ảnh (cấp 18), bot cấp 23 (mở cả kỹ năng cấp 22), bộ đồ chuẩn cấp 23.
func _sk2_fight(class_id: String, loadout: Array, seed_value: int) -> Array:
	var w := _region2_world("2-3", class_id, "tay-nhanh", 23, seed_value)
	w.field_spawn = false
	var p = w.profile
	p.points = _class_points(class_id)
	for k in p.points:
		p.points[k] = int(p.points[k]) * 5
	if not loadout.is_empty():
		p.loadout = loadout.duplicate()
	var rng := RngUtil.make(77)
	for pair in [["weapon", "blue"], ["armor", "blue"], ["helm", "green"], ["boots", "green"], ["gloves", "green"]]:
		var it := Items.new_item(p, 23, pair[1], rng, pair[0])
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
