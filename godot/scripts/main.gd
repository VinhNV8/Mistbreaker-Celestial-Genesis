extends Node
## Điểm vào của game: dựng cây node, đọc điều khiển, điều phối màn hình, tự lưu.
## Chạy với `-- --smoke=<thư mục>` để tự chơi qua các màn hình và chụp ảnh (kiểm tra tự động).

const Maps = preload("res://scripts/data/maps.gd")
const GameWorld = preload("res://scripts/core/game_world.gd")
const Profile = preload("res://scripts/core/profile.gd")
const RngUtil = preload("res://scripts/core/rng_util.gd")
const SaveSystem = preload("res://scripts/core/save_system.gd")
const Explore = preload("res://scripts/core/explore.gd")
const WorldView = preload("res://scripts/view/world_view.gd")
const Hud = preload("res://scripts/ui/hud.gd")
const MapPanel = preload("res://scripts/ui/map_panel.gd")
const InventoryPanel = preload("res://scripts/ui/inventory_panel.gd")
const TalentPanel = preload("res://scripts/ui/talent_panel.gd")
const SkillPanel = preload("res://scripts/ui/skill_panel.gd")
const HelpPanel = preload("res://scripts/ui/help_panel.gd")
const WorldMapPanel = preload("res://scripts/ui/world_map_panel.gd")
const Talents = preload("res://scripts/data/talents.gd")
const Items = preload("res://scripts/core/items.gd")
const Screens = preload("res://scripts/ui/screens.gd")
const UiTheme = preload("res://scripts/ui/ui_theme.gd")
const IntroScreen = preload("res://scripts/ui/intro_screen.gd")
const CreateScreen = preload("res://scripts/ui/create_screen.gd")
const DialogBox = preload("res://scripts/ui/dialog_box.gd")
const GiftCode = preload("res://scripts/core/gift_code.gd")
const ShopPanel = preload("res://scripts/ui/shop_panel.gd")
const ForgePanel = preload("res://scripts/ui/forge_panel.gd")
const Job2Panel = preload("res://scripts/ui/job2_panel.gd")
## TP5-02 (docs/33): Lễ Thức Tỉnh ô Thiên phú phụ.
const SubTalentPanel = preload("res://scripts/ui/sub_talent_panel.gd")
const Job3Panel = preload("res://scripts/ui/job3_panel.gd")
const DivinePanel = preload("res://scripts/ui/divine_panel.gd")
const PauseMenu = preload("res://scripts/ui/pause_menu.gd")
const Settings = preload("res://scripts/core/settings.gd")
const AudioManager = preload("res://scripts/audio/audio_manager.gd")

## Phím mặc định. Nếu đã khai báo action cùng tên trong Project Settings > Input Map thì dùng bản đó.
const KEY_ACTIONS := {
	"move_left": [KEY_A, KEY_LEFT],
	"move_right": [KEY_D, KEY_RIGHT],
	"move_up": [KEY_W, KEY_UP],
	"move_down": [KEY_S, KEY_DOWN],
	"attack": [KEY_J],
	"skill": [KEY_K],
	"skill_1": [KEY_1],
	"skill_2": [KEY_2],
	"skill_3": [KEY_3],
	"skill_4": [KEY_4],
	# SN12-02 (docs/31): ô 5 (chuyển chức 1), ô 6 (chuyển chức 2), ô Tuyệt kỹ G (cấp 45); X đổi Bộ kỹ năng 1 / 2.
	"skill_5": [KEY_5],
	"skill_6": [KEY_6],
	"skill_7": [KEY_G],
	"swap_loadout": [KEY_X],
	"talent": [KEY_L],
	"dodge": [KEY_SPACE],
	"toggle_stats": [KEY_C],
	"toggle_map": [KEY_M, KEY_TAB],
	"toggle_inventory": [KEY_I, KEY_B],
	"toggle_talent": [KEY_T],
	"toggle_skills": [KEY_U],
	"toggle_world": [KEY_N],
	"interact": [KEY_E],
	"auto_fight": [KEY_Z],
	"toggle_minimap": [KEY_V],
	"toggle_help": [KEY_F1, KEY_H],
	"toggle_forge": [KEY_R],
	"potion": [KEY_Q],
	"mp_potion": [KEY_F],
	"close_panel": [KEY_ESCAPE],
}
const MOUSE_ACTIONS := {"attack": MOUSE_BUTTON_LEFT, "skill": MOUSE_BUTTON_RIGHT}

var world: GameWorld
var hud: Hud
var map_panel: MapPanel
var inventory_panel: InventoryPanel
var talent_panel: TalentPanel
var skill_panel: SkillPanel
## UI-17: bảng Trợ giúp (F1 / H).
var help_panel: HelpPanel
var world_panel: WorldMapPanel
## Smoke test gắn bot vào đây để thay cho bàn phím/chuột.
var bot := Callable()

var _view: WorldView
var _camera: Camera2D
var _fx: CanvasLayer
var _vignette: TextureRect
var _freeze_tint: ColorRect
var _ui: Control
var _screen: Control
var _victory: Control
var dialog: DialogBox
var shop_panel: ShopPanel
var forge_panel: ForgePanel
var job2_panel: Job2Panel
var sub_panel: SubTalentPanel
var job3_panel: Job3Panel
var divine_panel: DivinePanel
## M12 (C9-47): bảng tổng kết + danh đề chờ hết thoại kết thúc rồi mới hiện.
var _pending_credits := false
var audio: AudioManager
var _pause: PauseMenu
## Sau khi đóng thoại, bỏ qua phím 0,2 giây (Space vừa dùng để tắt thoại không thành né lăn).
var _dialog_cool := 0.0
var _save_timer := 0.0
var _last_mouse_move := -100000
## C1-01: hướng di chuyển cuối cùng — chơi bàn phím giữ hướng này cả khi đã dừng.
var _kb_dir := Vector2.RIGHT


func _ready() -> void:
	_setup_input()
	RenderingServer.set_default_clear_color(UiTheme.BG)
	# C1-40/41/42: âm thanh + cài đặt
	audio = AudioManager.new()
	add_child(audio)
	get_tree().node_added.connect(func(n):
		if n is BaseButton:
			(n as BaseButton).pressed.connect(func(): audio.play("ui_click", 0.0)))

	_view = WorldView.new()
	_view.visible = false
	add_child(_view)
	_camera = Camera2D.new()
	_camera.limit_left = 0
	_camera.limit_top = 0
	_camera.limit_right = int(GameWorld.WORLD_SIZE.x)
	_camera.limit_bottom = int(GameWorld.WORLD_SIZE.y)
	_camera.position_smoothing_enabled = true
	_camera.position_smoothing_speed = 10.0
	_view.add_child(_camera)
	_view.camera = _camera

	_fx = CanvasLayer.new()
	_fx.layer = 1
	_fx.visible = false
	add_child(_fx)
	_vignette = TextureRect.new()
	_vignette.texture = _vignette_texture()
	_vignette.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_vignette.stretch_mode = TextureRect.STRETCH_SCALE
	_vignette.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fx.add_child(_vignette)
	_freeze_tint = ColorRect.new()
	_freeze_tint.color = Color(0.47, 0.67, 1.0, 0.12)
	_freeze_tint.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_freeze_tint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fx.add_child(_freeze_tint)

	var ui_layer := CanvasLayer.new()
	ui_layer.layer = 2
	add_child(ui_layer)
	_ui = Control.new()
	# M5-05: cỡ chữ người chơi chọn (settings.cfg) áp ngay từ đầu.
	Settings.load_settings()
	_ui.theme = UiTheme.set_font_scale(float(Settings.values.get("font_scale", 1.0)))
	_ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_layer.add_child(_ui)

	var smoke := _smoke_dir()
	if smoke != "":
		_run_smoke(smoke)
	else:
		_go_title()


func _setup_input() -> void:
	for action in KEY_ACTIONS:
		if InputMap.has_action(action):
			continue
		InputMap.add_action(action)
		for code in KEY_ACTIONS[action]:
			var ev := InputEventKey.new()
			ev.physical_keycode = code
			InputMap.action_add_event(action, ev)
		if MOUSE_ACTIONS.has(action):
			var mb := InputEventMouseButton.new()
			mb.button_index = MOUSE_ACTIONS[action]
			InputMap.action_add_event(action, mb)


func _vignette_texture() -> GradientTexture2D:
	var dark := Color(0.05, 0.06, 0.09)
	var grad := Gradient.new()
	grad.set_color(0, Color(dark, 0.0))
	grad.set_color(1, Color(dark, 1.0))
	grad.add_point(0.4, Color(dark, 0.0))
	var tex := GradientTexture2D.new()
	tex.gradient = grad
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(1.0, 1.0)
	tex.width = 256
	tex.height = 256
	return tex


# ------------------------------------------------------------------ vòng lặp


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_last_mouse_move = Time.get_ticks_msec()
	if world == null or _victory != null:
		return
	if _pause != null and not event.is_action_pressed("close_panel"):
		return
	if event.is_action_pressed("auto_fight") and not _any_panel_open():
		world.toggle_auto()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("toggle_minimap") and not _any_panel_open():
		hud.toggle_minimap()
		get_viewport().set_input_as_handled()
		return
	# C1-32, M4.3: phím E — nói chuyện với NPC gần nhất, hoặc mở cửa hàng khi đứng trong làng/thành.
	if event.is_action_pressed("interact"):
		var npc := world.nearest_npc()
		var act := ""
		if shop_panel.is_open():
			shop_panel.close()
		elif forge_panel.is_open():
			forge_panel.close()
		elif job2_panel.is_open():
			job2_panel.close()
		elif job3_panel.is_open():
			job3_panel.close()
		elif divine_panel.is_open():
			divine_panel.close()
		else:
			act = world.talk(str(npc.id)) if not npc.is_empty() else ""
			if act == "shop" or (npc.is_empty() and world.in_village()):
				for panel in _panels():
					panel.close()
				shop_panel.open(world)
			elif act == "forge":
				_open_forge("refine")
			elif act == "job2":
				for panel in _panels():
					panel.close()
				job2_panel.open(world)
			elif act == "job3":
				for panel in _panels():
					panel.close()
				job3_panel.open(world)
			elif act == "divine":
				for panel in _panels():
					panel.close()
				divine_panel.open(world)
			elif npc.is_empty():
				hud.log_message("Cửa hàng ở Làng Thanh Thạch — đứng trong làng rồi bấm E.", "info")
		get_viewport().set_input_as_handled()
		return
	# UI-11: C và I cùng mở Túi đồ (C vào thẳng tab Chỉ số, I vào tab Túi đồ).
	for pair in [["toggle_stats", "stats"], ["toggle_inventory", "bag"]]:
		if event.is_action_pressed(pair[0]):
			for panel in _panels():
				if panel != inventory_panel:
					panel.close()
			inventory_panel.toggle_tab(world, pair[1])
			get_viewport().set_input_as_handled()
			return
	for pair in [["toggle_map", map_panel], ["toggle_talent", talent_panel], ["toggle_world", world_panel], ["toggle_skills", skill_panel], ["toggle_help", help_panel], ["toggle_forge", forge_panel]]:
		if event.is_action_pressed(pair[0]):
			var target = pair[1]
			for panel in _panels():
				if panel != target:
					panel.close()
			target.toggle(world)
			get_viewport().set_input_as_handled()
			return
	if event.is_action_pressed("close_panel"):
		if _pause != null:
			_close_pause()
		elif _any_panel_open():
			for panel in _panels():
				panel.close()
		else:
			_open_pause()
		get_viewport().set_input_as_handled()


## UI-25: Lò Rèn (phím R, nút ở Cửa hàng, Thợ rèn Thiết Ngưu).
## UI-28b: chuyển giữa các tab của nhóm Nhân vật — stats / bag / res là tab Túi đồ, skills / talent là bảng riêng.
func _open_char_tab(id: String) -> void:
	for panel in [inventory_panel, skill_panel, talent_panel]:
		panel.close()
	match id:
		"sub_ritual":
			sub_panel.open(world)
		"skills":
			skill_panel.open(world)
		"talent":
			talent_panel.open(world)
		_:
			inventory_panel._tab = id
			inventory_panel.open(world)


func _open_forge(tab := "") -> void:
	for panel in _panels():
		panel.close()
	if tab != "":
		forge_panel.tab = tab
	forge_panel.open(world)


func _panels() -> Array:
	return [map_panel, inventory_panel, talent_panel, world_panel, shop_panel, forge_panel, job2_panel, job3_panel, divine_panel, skill_panel, help_panel, sub_panel]


func _any_panel_open() -> bool:
	for panel in _panels():
		if panel.is_open():
			return true
	return false


func _process(delta: float) -> void:
	if world == null:
		return
	var dt := minf(delta, 0.05)
	dialog.auto_advance = bot.is_valid()
	dialog.hold = _any_panel_open() or _victory != null
	if dialog.is_open():
		_dialog_cool = 0.2
	else:
		_dialog_cool -= delta
	var paused := _victory != null or _any_panel_open() or dialog.is_open() or _dialog_cool > 0.0 or _pause != null
	if not paused:
		world.update(dt, bot.call(world) if bot.is_valid() else _read_input())
	for ev in world.drain_events():
		_handle_event(ev)
	if _pending_credits and _victory == null and not dialog.is_open():
		_pending_credits = false
		_victory = Screens.credits(world, _after_credits)
		_ui.add_child(_victory)
	_camera.position = world.player.pos
	_vignette.modulate.a = 0.45 + 0.35 * world.player.pos.x / world.world_size.x
	_freeze_tint.visible = world.freeze_timer > 0.0
	hud.update_from(world)
	for id in world.sfx:
		audio.play(str(id))
	world.sfx.clear()
	audio.music(_music_for(world))
	_save_timer += delta
	if _save_timer > 5.0:
		_save_timer = 0.0
		_persist()


func _read_input() -> Dictionary:
	var move := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var aim := _view.get_global_mouse_position()
	if move != Vector2.ZERO:
		_kb_dir = move.normalized()
	# C1-01: chuột không di chuyển trong 1,5 giây = chơi bàn phím → đánh theo hướng di chuyển cuối cùng,
	# kể cả khi đã dừng (trước đây dừng lại thì hướng nhảy về chỗ con trỏ chuột).
	var kb_aim := Time.get_ticks_msec() - _last_mouse_move > 1500
	# SN9-09: quái dưới con trỏ chuột thành mục tiêu của khung mục tiêu
	world.hover_pos = Vector2.INF if kb_aim else aim
	if kb_aim:
		aim = world.player.pos + _kb_dir * 100.0
	# SN5-01: chuột đang ở trên giao diện nhận chuột (bản đồ nhỏ…) thì nút chuột không đánh / không dùng kỹ năng.
	var over_ui := get_viewport().gui_get_hovered_control() != null
	var mouse_attack := Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not Input.is_physical_key_pressed(KEY_J)
	var mouse_skill := Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) and not Input.is_physical_key_pressed(KEY_K)
	return {
		"move": move,
		"aim": aim,
		"kb_aim": kb_aim,
		"attack": Input.is_action_pressed("attack") and not (over_ui and mouse_attack),
		"skill": Input.is_action_just_pressed("skill") and not (over_ui and mouse_skill),
		"skill_1": Input.is_action_just_pressed("skill_1"),
		"skill_2": Input.is_action_just_pressed("skill_2"),
		"skill_3": Input.is_action_just_pressed("skill_3"),
		"skill_4": Input.is_action_just_pressed("skill_4"),
		"skill_5": Input.is_action_just_pressed("skill_5"),
		"skill_6": Input.is_action_just_pressed("skill_6"),
		"skill_7": Input.is_action_just_pressed("skill_7"),
		"swap_loadout": Input.is_action_just_pressed("swap_loadout"),
		"talent": Input.is_action_just_pressed("talent"),
		"dodge": Input.is_action_just_pressed("dodge"),
		"potion": Input.is_action_just_pressed("potion"),
		"mp_potion": Input.is_action_just_pressed("mp_potion"),
	}


func _handle_event(ev: Dictionary) -> void:
	match ev.type:
		"message":
			hud.log_message(ev.text, ev.tone)
		"levelup":
			hud.banner("Lên cấp %d!" % ev.level, str(ev.get("growth", "")))
			_persist()
		"tile":
			_persist()
		"map":
			# Rà soát 01/11: bảng lục địa mở từ Cổng Dịch Chuyển không ở lại với nội dung của map cũ.
			if world_panel.is_open():
				world_panel.close()
			_fit_camera()
			_camera.position = world.player.pos
			_camera.reset_smoothing()
			_persist()
		"item":
			hud.log_message(ev.text, "good" if ev.rarity in ["blue", "purple", "orange"] else "info")
		"dialog":
			dialog.push(str(ev.id))
		"quest_done":
			_persist()
		"sub_ritual":
			# TP5-02 (docs/33): chuyển chức xong → Lễ Thức Tỉnh ô Thiên phú phụ.
			for panel in _panels():
				panel.close()
			sub_panel.open(world)
		"waypoint":
			# MP-09: bước vào Cổng Dịch Chuyển → bảng lục địa để chọn map đã mở.
			for panel in _panels():
				panel.close()
			world_panel.open(world)
		"victory":
			_persist()
			_victory = Screens.victory(world, _after_victory, _go_title, str(ev.get("boss", "boss")))
			_ui.add_child(_victory)
		"ending_choice":
			# C9-44: màn lựa chọn kết thúc (thay màn chiến thắng của Ma Tôn nếu đang mở)
			_close_victory()
			_victory = Screens.ending_choice(_pick_ending)
			_ui.add_child(_victory)
		"ending":
			_persist()
			_pending_credits = true


## C9-47: sau danh đề về Thiên Thê Đài I.
func _after_credits() -> void:
	_close_victory()
	if world.map_id != "9-1":
		world._load_map("9-1")
	world.player.pos = world.safe_pos + Vector2(60, 40)
	_persist()


func _pick_ending(id: String) -> void:
	_close_victory()
	world.Ch9.choose_ending(world, id)


## MP-06: cảnh kết chương — mở bản đồ lục địa, vùng tiếp theo sáng lên.
func _after_victory() -> void:
	_close_victory()
	world_panel.intro = "Ánh sáng từ Bia Đá lan khắp Rừng Sương. Phía đông, Đồng Bằng Gió Hú đang chờ… Lõi Sương đã mở."
	world_panel.open(world)


func _fit_camera() -> void:
	_camera.limit_right = int(world.world_size.x)
	_camera.limit_bottom = int(world.world_size.y)


func _close_victory() -> void:
	if _victory != null:
		_victory.queue_free()
		_victory = null


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_persist()


# ------------------------------------------------------------------ màn hình


func _now() -> float:
	return Time.get_unix_time_from_system()


func _persist() -> void:
	if world == null:
		return
	world.profile.last_seen = _now()
	SaveSystem.save_profile(world.profile)


func _set_screen(c: Control) -> void:
	if _screen != null:
		_screen.queue_free()
	_screen = c
	if c != null:
		_ui.add_child(c)


func _go_title() -> void:
	_persist()
	_end_session()
	var any := SaveSystem.any_save()
	_set_screen(Screens.title(any, _open_slots if any else _on_new_game, _continue_last, _open_settings))
	audio.music("village")


## SN9-02: nút "Tiếp tục" ở màn tiêu đề — vào ngay nhân vật chơi gần nhất.
func _continue_last() -> void:
	var last := SaveSystem.last_slot()
	if last == 0:
		return
	SaveSystem.select_slot(last)
	_on_continue()


## SN9-02 (Spec_Notes đợt 9): màn Chọn nhân vật — 5 ô.
func _open_slots() -> void:
	_set_screen(Screens.slots(SaveSystem.list_slots(), _play_slot, _ask_delete_slot, _on_new_game, _go_title))


func _play_slot(n: int) -> void:
	SaveSystem.select_slot(n)
	SaveSystem.remember_slot(n)
	_on_continue()


## Q154: xoá nhân vật phải gõ lại đúng tên.
func _ask_delete_slot(n: int) -> void:
	var s := SaveSystem.slot_summary(n)
	if s.is_empty():
		return
	var dlg := ConfirmationDialog.new()
	dlg.title = "Xoá nhân vật"
	dlg.dialog_text = "Xoá vĩnh viễn \"%s\" (Lv %d)? Không khôi phục được.\nGõ lại tên nhân vật để xác nhận:" % [s.name, int(s.level)]
	dlg.ok_button_text = "Xoá"
	dlg.cancel_button_text = "Huỷ"
	var edit := LineEdit.new()
	edit.name = "ConfirmName"
	edit.placeholder_text = str(s.name)
	dlg.add_child(edit)
	dlg.register_text_enter(edit)
	dlg.confirmed.connect(func():
		if edit.text.strip_edges() == str(s.name).strip_edges():
			SaveSystem.delete_slot(n)
			_open_slots())
	dlg.visibility_changed.connect(func():
		if not dlg.visible:
			dlg.queue_free())
	_ui.add_child(dlg)
	dlg.popup_centered(Vector2i(460, 0))
	edit.grab_focus()


## Tạo nhân vật mới ở ô trống đầu tiên; đủ 5 nhân vật thì báo và mở màn Chọn nhân vật.
func _on_new_game() -> void:
	var n := SaveSystem.first_empty()
	if n == 0:
		_open_slots()
		var dlg := AcceptDialog.new()
		dlg.title = "Đã đủ %d nhân vật" % SaveSystem.MAX_SLOTS
		dlg.dialog_text = "Xoá bớt một nhân vật để tạo nhân vật mới."
		dlg.visibility_changed.connect(func():
			if not dlg.visible:
				dlg.queue_free())
		_ui.add_child(dlg)
		dlg.popup_centered()
		return
	SaveSystem.select_slot(n)
	_start_awakening()


## Kịch bản mục 9: Mở đầu (C1-10) → Tạo nhân vật (C1-02) → Lễ Thức Tỉnh.
var _pending_hero := {}


func _start_awakening() -> void:
	SaveSystem.clear_save()
	_set_screen(IntroScreen.new(_on_intro_done))


func _on_intro_done() -> void:
	_set_screen(CreateScreen.new(_on_hero_created))


func _on_hero_created(hero: Dictionary) -> void:
	# Q153: tên không trùng giữa các ô nhân vật — ở lại màn tạo nhân vật để đổi tên.
	if SaveSystem.name_taken(str(hero.get("name", "")), SaveSystem.slot):
		var dlg := AcceptDialog.new()
		dlg.title = "Tên đã được dùng"
		dlg.dialog_text = "Đã có nhân vật tên \"%s\". Hãy chọn tên khác." % str(hero.get("name", ""))
		dlg.visibility_changed.connect(func():
			if not dlg.visible:
				dlg.queue_free())
		_ui.add_child(dlg)
		dlg.popup_centered()
		return
	_pending_hero = hero
	_set_screen(Screens.awakening(RngUtil.make(randi()), _on_talent_chosen, str(hero.name)))


func _on_talent_chosen(talent_id: String, gift_serial := "") -> void:
	var hero := _pending_hero
	var p := Profile.new()
	p.setup(talent_id, RngUtil.make(randi()), _now(), str(hero.get("class_id", "kiem-khach")))
	p.name = str(hero.get("name", p.name))
	if hero.has("look"):
		p.look = hero.look
	p.gift_code = gift_serial
	SaveSystem.save_profile(p)
	SaveSystem.remember_slot(SaveSystem.slot)
	_start_world(p)


func _on_continue() -> void:
	# SN9-02: ô đã được chọn trước (_continue_last / _play_slot).
	var p := SaveSystem.load_profile()
	if p == null:
		return
	var off := SaveSystem.apply_offline(p, _now())
	_start_world(p)
	if float(off.get("exp", 0.0)) >= 1.0:
		world.add_exp(float(off.exp), false)
		hud.log_message("Lãnh địa vận hành khi bạn vắng mặt: +%d EXP." % int(off.exp), "good")
	if off.seconds > 60.0 and (off.gold >= 1.0 or off.wood >= 1.0 or off.torches > 0):
		hud.log_message(
			"Lãnh địa thu hoạch khi bạn vắng mặt: +%d gỗ, +%d vàng, +%d Đuốc." % [int(off.wood), int(off.gold), off.torches], "good"
		)


func _start_world(p: Profile) -> void:
	_set_screen(null)
	_end_session()
	world = GameWorld.new(p, RngUtil.make(randi()))
	_view.world = world
	_view.visible = true
	_fx.visible = true
	hud = Hud.new()
	_ui.add_child(hud)
	hud.auto_toggled.connect(func(): world.toggle_auto())
	map_panel = MapPanel.new()
	_ui.add_child(map_panel)
	inventory_panel = InventoryPanel.new()
	_ui.add_child(inventory_panel)
	talent_panel = TalentPanel.new()
	_ui.add_child(talent_panel)
	skill_panel = SkillPanel.new()
	_ui.add_child(skill_panel)
	help_panel = HelpPanel.new()
	_ui.add_child(help_panel)
	world_panel = WorldMapPanel.new()
	_ui.add_child(world_panel)
	shop_panel = ShopPanel.new()
	_ui.add_child(shop_panel)
	forge_panel = ForgePanel.new()
	_ui.add_child(forge_panel)
	shop_panel.open_forge.connect(_open_forge)
	inventory_panel.open_forge.connect(func():
		forge_panel.select_item(inventory_panel._selected_id)
		_open_forge("enhance"))
	# UI-28b: 3 bảng nhóm Nhân vật (Túi đồ, Kỹ năng, Thiên phú) dùng chung thanh tab — bấm tab nào cũng chuyển được
	for panel in [inventory_panel, skill_panel, talent_panel]:
		panel.open_panel.connect(_open_char_tab)
	job2_panel = Job2Panel.new()
	_ui.add_child(job2_panel)
	sub_panel = SubTalentPanel.new()
	_ui.add_child(sub_panel)
	job3_panel = Job3Panel.new()
	_ui.add_child(job3_panel)
	divine_panel = DivinePanel.new()
	_ui.add_child(divine_panel)
	dialog = DialogBox.new()
	_ui.add_child(dialog)
	dialog.setup(p.name, p.class_id, p.look)
	# Thoại phát lúc tạo thế giới (bước nhiệm vụ đầu) nằm trong hàng sự kiện, _process sẽ xử lý.
	_fit_camera()
	map_panel.nest_started.connect(func(): hud.log_message("Thủ lĩnh ổ quái đã xuất hiện trước mặt bạn!", "bad"))
	# UI-17: gợi ý một lần mỗi phiên (phím tắt không còn ghi trong khung nhiệm vụ).
	hud.log_message("Nhấn F1 để xem phím tắt và mẹo chơi.", "info")
	_camera.position = world.player.pos
	_camera.reset_smoothing()


func _end_session() -> void:
	_close_victory()
	for n in [hud, map_panel, inventory_panel, talent_panel, world_panel, dialog, shop_panel, forge_panel, job2_panel, job3_panel, divine_panel, skill_panel, help_panel, sub_panel]:
		if n != null:
			n.queue_free()
	hud = null
	map_panel = null
	inventory_panel = null
	talent_panel = null
	skill_panel = null
	help_panel = null
	world_panel = null
	dialog = null
	shop_panel = null
	forge_panel = null
	job2_panel = null
	sub_panel = null
	job3_panel = null
	divine_panel = null
	world = null
	_view.world = null
	_view.visible = false
	_fx.visible = false


# ------------------------------------------------------------------ smoke test


func _smoke_dir() -> String:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--smoke="):
			return a.substr(8)
	return ""


func _shot(dir: String, file: String) -> void:
	# Rà soát 01/11: smoke đặt nhân vật / nạp map trực tiếp có thể đứng trúng Cổng Dịch Chuyển → bảng lục địa tự mở và che
	# mọi ảnh sau (không ảnh nào cố ý chụp bảng này).
	if world_panel != null and world_panel.is_open():
		world_panel.close()
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(dir.path_join(file + ".png"))
	print("SMOKE shot ", file)


## Smoke (rà soát 01/11): chỗ đứng trong làng / thành / trại tránh Cổng Dịch Chuyển — đứng trúng cổng là bảng lục địa
## tự mở và che các ảnh sau.
func _smoke_town_pos() -> Vector2:
	var pos: Vector2 = world.safe_pos + Vector2(10, -10)
	for _i in 8:
		var near := false
		for pt in world.portals:
			if pos.distance_to(pt.pos) <= world.Portals.RADIUS + 40.0:
				near = true
		if not near:
			break
		pos += Vector2(70, 30)
	return pos


## Smoke: đóng hết thoại đang chờ (ảnh chụp không bị hộp thoại che).
func _skip_dialog() -> void:
	for i in 60:
		if not dialog.is_open():
			return
		dialog.advance()


func _wait(seconds: float) -> void:
	await get_tree().create_timer(seconds, true, false, true).timeout


func _press(button_name: String) -> void:
	var b := _screen.find_child(button_name, true, false) as Button
	if b == null or b.disabled:
		push_error("SMOKE: không bấm được %s" % button_name)
		return
	b.pressed.emit()


func _smoke_bot(w: GameWorld) -> Dictionary:
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
	var threat := false
	for e in w.enemies:
		if e.state == "windup" and e.timer < 0.2 and e.pos.distance_to(p.pos) < 140.0:
			threat = true
	var close: bool = best < 60.0 + target.radius
	return {
		"move": Vector2.ZERO if close else (target.pos - p.pos).normalized(),
		"aim": target.pos,
		"attack": true,
		"skill": best < 120.0,
		"skill_2": best < 200.0 and best > 90.0,
		"skill_3": best < 380.0,
		"skill_4": best < 160.0,
		"talent": Talents.has_skill(w.talent()),
		"dodge": threat,
	}


func _run_smoke(dir: String) -> void:
	DirAccess.make_dir_recursive_absolute(dir)
	# SN9-02: ô nhân vật của smoke test là file riêng (smoke_save.json, smoke_save_2.json…)
	SaveSystem.prefix = "user://smoke_save"
	SaveSystem.slots_cfg = "user://smoke_slots.cfg"
	for n in range(1, SaveSystem.MAX_SLOTS + 1):
		SaveSystem.delete_slot(n)
	SaveSystem.select_slot(1)
	GiftCode.store_path = "user://smoke_redeemed_codes.cfg"
	if FileAccess.file_exists(GiftCode.store_path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(GiftCode.store_path))
	SaveSystem.clear_save()
	_go_title()
	await _wait(0.5)
	await _shot(dir, "01-title")

	_on_new_game()
	await _wait(0.6)
	(_screen as IntroScreen).jump(1)
	await _wait(0.4)
	await _shot(dir, "01b-intro")
	_press("SkipButton")
	await _wait(0.3)
	var cs := _screen as CreateScreen
	cs.set_name_for_test("Lâm Phong")
	cs._look = {"gender": "nu", "skin": 1, "hair_style": "duoi", "hair_color": 2}
	cs._refresh()
	await _wait(1.0)
	await _shot(dir, "02-create")
	_press("CreateButton")
	await _wait(0.3)
	_press("RollButton")
	await _wait(1.5)
	_press("RollButton")
	await _wait(1.5)
	# CR-02: nhập gift code
	(_screen.find_child("GiftEdit", true, false) as LineEdit).text = GiftCode.make("SMOKE001")
	_press("GiftButton")
	await _wait(1.8)
	await _shot(dir, "02b-awakening")
	_press("AcceptButton")
	await _wait(0.15)
	await _shot(dir, "02c-dialog")
	await _wait(1.5)

	bot = _smoke_bot
	world.player.pos.x = 600.0
	await _wait(5.0)
	await _shot(dir, "03-combat")
	# M3: chụp Thợ Săn (đổi lớp tạm thời chỉ trong smoke test).
	world.profile.class_id = "tho-san"
	world._refresh_stats()
	world.player.mp = world.stats.max_mp
	await _wait(4.0)
	await _shot(dir, "03b-hunter")
	# SN-01: chụp Pháp Sư
	world.profile.class_id = "phap-su"
	world._refresh_stats()
	world.player.mp = world.stats.max_mp
	await _wait(4.0)
	await _shot(dir, "03c-mage")
	# LH1 (docs/19): chụp Hộ Vệ
	world.profile.class_id = "ho-ve"
	world._refresh_stats()
	world.player.mp = world.stats.max_mp
	await _wait(4.0)
	await _shot(dir, "03d-guard")
	world.profile.class_id = "kiem-khach"
	world._refresh_stats()
	# AR-45b: hình thi triển Kiếm Khách — Xoáy Kiếm qua use_skill thật (world_view nhận ra lúc thi triển), Nhất Kiếm Khai Thiên ghi thẳng.
	world.profile.loadout = []  # bộ đang lắp là của Hộ Vệ (ảnh trước) → về bộ mặc định Kiếm Khách
	world.slot_skill(0)
	await _wait(0.1)  # world_view ghi nhận bộ mới trước (đổi bộ cùng khung với thi triển thì không vẽ)
	var spin_slot: int = world.profile.loadout.find("spin")
	if spin_slot >= 0:
		world.player.skill_cds[spin_slot] = 0.0
		world.player.mp = world.stats.max_mp
		world.use_skill(spin_slot)
		await _wait(0.15)
		await _shot(dir, "03e-kiem-vfx-spin")
	world.player.facing = -0.4
	_view.ClassFx.on_cast(_view._cast_fx, world, {"id": "nhatkiem"})
	await _wait(0.6)
	await _shot(dir, "03f-kiem-vfx-nhatkiem")

	var first: Dictionary = world.profile.tiles.filter(func(t): return Explore.hex_distance(t, {"q": 0, "r": 0}) == 1)[0]
	map_panel.open(world)
	map_panel._selected = int(first.id)
	world.reveal_tile(int(first.id))
	map_panel.refresh()
	await _wait(0.3)
	await _shot(dir, "04-map")
	map_panel.close()
	inventory_panel.toggle_tab(world, "stats")
	await _wait(0.3)
	await _shot(dir, "05-stats")
	inventory_panel.close()
	help_panel.open(world)
	await _wait(0.3)
	await _shot(dir, "05a-help")
	help_panel.close()

	# Túi đồ: thêm vài món mẫu (gồm đồ bộ và Nanh Sói Chúa) để chụp giao diện.
	var rng := RngUtil.make(99)
	var pp = world.profile
	pp.stones += 20
	pp.gold += 500
	for r in ["white", "green", "blue", "purple"]:
		Items.add_item(pp, Items.new_item(pp, 4, r, rng))
	Items.add_item(pp, Items.new_item(pp, 5, "purple", rng, "helm", "frost_hunter"))
	var fang := Items.new_item(pp, 6, "orange", rng, "", "", "wolf_fang")
	Items.add_item(pp, fang)
	world.equip(int(fang.id))
	inventory_panel.toggle_tab(world, "bag")
	inventory_panel._selected_id = int(pp.inventory[pp.inventory.size() - 1].id)
	inventory_panel.refresh()
	await _wait(0.3)
	await _shot(dir, "05b-inventory")
	world.enhance(int(fang.id))
	# N8: cho Nanh Sói Chúa lên +10 để chụp hiệu ứng theo cấp cường hoá.
	Items.find_item(pp, int(fang.id)).item.plus = 10
	world._refresh_stats()
	inventory_panel._selected_id = int(fang.id)
	inventory_panel.refresh()
	inventory_panel._play_burst(true, 10, Items.display_name(Items.find_item(pp, int(fang.id)).item))
	await _wait(0.25)
	await _wait(0.3)
	await _shot(dir, "05c-inventory-equipped")
	# SN11: thẻ so sánh khi rê chuột lên món vũ khí trong túi (đặt cạnh ô túi đầu tiên).
	var bag_weapon: Array = pp.inventory.filter(func(it): return str(it.slot) == "weapon")
	if not bag_weapon.is_empty():
		await _wait(1.6)
		inventory_panel._show_tip(bag_weapon[0], true)
		var cell = inventory_panel.find_child("Bag_0", true, false)
		if cell != null:
			inventory_panel._tip.place(cell.get_global_rect().get_center())
		await _wait(0.2)
		await _shot(dir, "05c2-item-compare")
	inventory_panel.close()

	# Bảng Thiên phú + bản đồ có mục Công trình (M2).
	pp.wood += 200
	world.build("temple")
	pp.essence = 6
	talent_panel.open(world)
	await _wait(0.3)
	await _shot(dir, "05d-talent")
	talent_panel.close()
	skill_panel.open(world)
	await _wait(0.3)
	await _shot(dir, "05g-skills")
	# PV (docs/27): tab Bị động — tạm cấp 22, Thiết Cốt cấp 2 để chụp, xong trả lại.
	var lv_before := int(pp.level)
	pp.level = 22
	pp.passive_levels = {"thietcot": 2}
	skill_panel._tab = "passive"
	skill_panel._sel = "thietcot"
	skill_panel.refresh()
	await _wait(0.3)
	await _shot(dir, "05g2-skills-passive")
	pp.level = lv_before
	pp.passive_levels = {}
	world._refresh_stats()
	skill_panel._tab = "base"
	skill_panel.close()
	map_panel.open(world)
	await _wait(0.3)
	await _shot(dir, "05e-map-buildings")
	map_panel.close()
	# C1-32: cửa hàng làng + Thương nhân lữ hành + Xưởng Rèn
	pp.buildings["forge"] = 0.0
	world._open_merchant()
	await _wait(1.0)
	world.player.pos = world.safe_pos
	shop_panel.open(world)
	await _wait(0.3)
	await _shot(dir, "05f-shop")
	shop_panel.tab = "sell"
	shop_panel.refresh()
	await _wait(0.2)
	await _shot(dir, "05f2-shop-sell")
	shop_panel.tab = "buy"
	shop_panel.close()
	# UI-25: Lò Rèn — cường hoá (chi phí cần/có + bảng mọi cấp) và chế tạo
	pp.gold += 500
	pp.stones += 6
	_open_forge("enhance")
	await _wait(0.3)
	await _shot(dir, "05h-forge")
	_open_forge("craft")
	await _wait(0.2)
	await _shot(dir, "05h2-forge-craft")
	forge_panel.tab = "enhance"
	forge_panel.close()

	var p = world.profile
	p.level = 5
	p.points = {"str": 12, "agi": 0, "vit": 8}
	for i in range(1, 7):
		p.tiles[i].status = "owned"
	world._refresh_stats()
	world.player.hp = world.stats.max_hp
	world.player.pos = GameWorld.ARENA_POS - Vector2(150, 0)
	await _wait(4.0)
	await _shot(dir, "06-boss")

	Engine.time_scale = 3.0
	var waited := 0.0
	while not p.boss_defeated and waited < 240.0:
		if world.boss() == null and world.player.dead_timer <= 0.0:
			world.player.pos = GameWorld.ARENA_POS - Vector2(100, 0)
		await _wait(0.5)
		waited += 0.5
	Engine.time_scale = 1.0
	await _wait(0.5)
	await _shot(dir, "07-victory")
	_close_victory()
	_open_pause()
	_pause.show_settings()
	await _wait(0.3)
	await _shot(dir, "08-settings")
	_close_pause()
	print("SMOKE audio music=%s" % audio.current_music())
	# M4.2: vùng 2 Cửa Gió (gió, quái mới, Thành Biên Đài)
	p.level = 12
	world._refresh_stats()
	world._load_map("2-1")
	world.player.pos = world.safe_pos + Vector2(420, 0)
	for k in ["ung-gio", "linh-danh-thue", "cung-thu", "loc-xoay"]:
		world.spawn_enemy(k, 12, world.player.pos + Vector2(220 + randf() * 200, randf() * 300 - 150))
	await _wait(3.0)
	await _shot(dir, "09-region2")
	# MP-09: nhân vật đứng cạnh cổng lùi (về Lõi Sương) — cổng không che nhân vật.
	world.enemies = []
	var back_pt: Dictionary = world.portals.filter(func(pt): return pt.kind == "back")[0]
	world.player.pos = back_pt.pos + Vector2(0, 20)
	world.portal_inside = world.portals.find(back_pt)
	await _wait(0.5)
	await _shot(dir, "09a-portal")
	# HP (docs/15): trong hang phụ — đi tới khu 1, quái + tinh anh; rồi về lại Cửa Gió.
	world._load_map("cave-2-1")
	world.player.pos = Vector2(700, 550) * Maps.MAP_SCALE
	await _wait(1.2)
	await _shot(dir, "09a2-cave")
	world._load_map("2-1")
	# BD-11 (docs/34): Cổng dungeon hạng B trên Cửa Gió + bên trong cổng.
	world.enemies = []
	GameWorld.Gates.open_gate(world, "2-1", world._gate_rng, "B")
	var gate_pt: Dictionary = world.portals.filter(func(pt): return pt.kind == "dgate")[0]
	world.player.pos = gate_pt.pos + Vector2(-90, 40)
	await _wait(0.8)
	await _shot(dir, "09a3-gate")
	world._load_map(str(gate_pt.to))
	world.player.pos = Vector2(760, 550)
	await _wait(1.2)
	await _shot(dir, "09a4-gate-inside")
	p.gates = {}
	world._load_map("2-1")
	# M4.3: Thành Biên Đài — NPC, nhiệm vụ chương 2, cửa hàng có thợ rèn
	world.enemies = []
	world.player.pos = _smoke_town_pos()
	p.ore = 25.0
	p.iron = 12.0
	await _wait(1.0)
	await _shot(dir, "09b-town")
	shop_panel.open(world)
	await _wait(0.3)
	await _shot(dir, "09c-town-shop")
	shop_panel.close()
	# M6 (docs/10): vùng 3 Sa Mạc Xích Sa — trại, ngày có nắng; đêm + bão cát; Sào Huyệt Sa Hoàng
	p.bosses["huyen-anh"] = true
	if not ("3-1" in p.unlocked_maps):
		p.unlocked_maps.append_array(["3-1", "3-2", "3-3"])
	p.level = maxi(p.level, 22)
	world._refresh_stats()
	world._load_map("3-1")
	p.play_seconds = 30.0
	world.player.pos = _smoke_town_pos()
	await _wait(1.0)
	await _shot(dir, "10b-camp")
	world.player.pos = world.safe_pos + Vector2(900, 0)
	for k in ["bo-cat", "ran-cat", "xac-uop", "phap-su-cat"]:
		var ne = world.spawn_enemy(k, 22, world.player.pos + Vector2(220 + randf() * 200, randf() * 300 - 150))
		world.Ch3.after_spawn(world, ne)
	await _wait(3.0)
	await _shot(dir, "10-region3")
	p.play_seconds = 250.0
	world.ch3.storm_left = 20.0
	await _wait(1.5)
	await _shot(dir, "10c-night-storm")
	world.ch3.storm_left = 0.0
	p.play_seconds = 30.0
	p.quest.ch3 = 5
	world._load_map("3-3")
	world.player.pos = world.arena_pos - Vector2(120, 0)
	# chỉ để chụp ảnh boss: khiên lớn để nhân vật cấp thấp không gục ngay
	world.player.shield = 1e9
	world.player.shield_time = 999.0
	await _wait(1.6)
	await _shot(dir, "11-sa-hoang")
	world.player.shield = 0.0
	# M7 (docs/11): vùng 4 Đầm Lầy U Minh — làng chài, đầm lầy có quái, giấc mơ của Nữ Vương, tiến hoá
	world.enemies = []
	p.bosses["sa-hoang"] = true
	p.job = str(world.Ch3.Classes.job_def(str(p.class_id)).id)
	if not ("4-1" in p.unlocked_maps):
		p.unlocked_maps.append_array(["4-1", "4-2", "4-3"])
	p.level = maxi(p.level, 34)
	world._refresh_stats()
	world._load_map("4-1")
	world.player.pos = _smoke_town_pos()
	await _wait(1.0)
	await _shot(dir, "12b-village4")
	world._load_map("4-2")
	world.player.pos = Vector2(1300, 900) * Maps.MAP_SCALE
	world.ch4.poison = 4
	for k in ["ech-doc", "dia", "hon-ma", "ca-sau"]:
		var ne = world.spawn_enemy(k, 37, world.player.pos + Vector2(200 + randf() * 200, randf() * 300 - 150))
		ne.illusion = k == "hon-ma"
	await _wait(2.5)
	await _shot(dir, "12-region4")
	p.quest.ch4 = 5
	world._load_map("4-3")
	world.player.pos = world.arena_pos - Vector2(120, 0)
	world.player.shield = 1e9
	world.player.shield_time = 999.0
	await _wait(1.0)
	var q = world.boss()
	if q != null:
		q.hp = q.max_hp * 0.55
	await _wait(1.2)
	await _shot(dir, "12c-dream")
	world.player.shield = 0.0
	world.ch4.dream_t = 0.0
	p.talent_level = 10
	p.evo_essence = 1
	p.quest.ch4 = 6
	talent_panel.open(world)
	await _wait(0.3)
	await _shot(dir, "12d-talent-evo")
	talent_panel.close()
	# M8: chương 5 Núi Viêm Long
	p.evo = maxi(1, int(p.evo))
	p.bosses["nu-vuong"] = true
	p.level = maxi(p.level, 50)
	world._refresh_stats()
	world._load_map("5-1")
	world.player.pos = world.safe_pos + Vector2(60, 40)
	await _wait(1.0)
	await _shot(dir, "13b-camp5")
	world._load_map("5-2")
	world.player.pos = Vector2(1300, 1280) * Maps.MAP_SCALE
	world.player.shield = 1e9
	world.player.shield_time = 999.0
	for k in ["than-lan-lua", "nguoi-da", "linh-hon-lua", "phap-su-hoa-diem"]:
		world.spawn_enemy(k, 52, world.player.pos + Vector2(200 + randf() * 200, randf() * 300 - 150))
	world.ch5.erupt_t = 0.5
	await _wait(1.6)
	await _shot(dir, "13-region5")
	p.quest.ch5 = 6
	world._load_map("5-3")
	world.player.pos = world.arena_pos - Vector2(120, 0)
	await _wait(1.0)
	var vl = world.boss()
	if vl != null:
		vl.hp = vl.max_hp * 0.55
		await _wait(0.3)
		world.ch5.flood_t = GameWorld.Ch5.FLOOD_WARN + 1.0
	await _wait(1.0)
	await _shot(dir, "13c-vien-long")
	world.player.shield = 0.0
	world._load_map("5-1")
	world.player.pos = world.safe_pos + Vector2(80, 80)
	p.level = 60
	p.crystal = 30.0
	p.bosses["vien-long"] = true
	if str(p.job) == "":
		p.job = str(GameWorld.Classes.job_def(str(p.class_id)).id)
	job2_panel.open(world)
	await _wait(0.3)
	await _shot(dir, "14b-job2")
	job2_panel.close()
	# J3 (docs/23): bảng chuyển chức 3 (cấp 90, sau chức 2) — trả lại trạng thái cho các ảnh sau
	p.job2 = str(GameWorld.Classes.job2_defs(str(p.class_id))[0].id)
	p.level = 90
	p.crystal = 50.0
	job3_panel.open(world)
	await _wait(0.3)
	await _shot(dir, "20b-job3")
	job3_panel.close()
	p.job2 = ""
	p.level = 60
	p.crystal = 30.0
	world._refresh_stats()
	# SK2: bảng Kỹ năng cấp 60 — 8 kỹ năng, biến thể
	p.skill_levels["spin"] = 10
	p.skill_levels["lientram"] = 7
	p.variants["spin"] = ["cd", "hoa", "dmg"]
	skill_panel.open(world)
	await _wait(0.3)
	await _shot(dir, "14c-skills")
	skill_panel.close()
	# TP-05 (docs/33): Lễ Thức Tỉnh ô Thiên phú phụ (đã chuyển chức 1 + 2 → 2 ô chờ), rồi bảng Thiên phú có ô phụ.
	sub_panel.open(world)
	world.sub_ritual().roll()
	world.sub_ritual().roll()
	sub_panel.refresh()
	await _wait(0.3)
	await _shot(dir, "14d-sub-ritual")
	world.accept_sub(str(world.sub_ritual().rolls[0].id))
	sub_panel.close()
	talent_panel.open(world)
	await _wait(0.3)
	await _shot(dir, "14e-talent-subs")
	talent_panel.close()
	p.quest.ch5 = 4
	world.ch5.siege = false
	GameWorld.Ch5.start_siege(world)
	await _wait(4.0)
	await _shot(dir, "13d-siege")
	GameWorld.Ch5._end_siege(world, false, true)
	# M9: chương 6 Băng Nguyên Bắc Cực
	p.quest.ch5 = GameWorld.Story.DONE5
	p.job2 = str(GameWorld.Classes.job2_defs(str(p.class_id))[0].id)
	p.level = maxi(p.level, 62)
	world._refresh_stats()
	world._load_map("6-1")
	world.player.pos = world.safe_pos + Vector2(60, 40)
	await _wait(1.0)
	await _shot(dir, "15c-camp6")
	world._load_map("6-2")
	world.player.pos = Vector2(1300, 1280) * Maps.MAP_SCALE
	world.player.shield = 1e9
	world.player.shield_time = 999.0
	for k in ["soi-bang", "nguoi-tuyet", "tinh-linh-bang", "cung-thu-bang"]:
		world.spawn_enemy(k, 65, world.player.pos + Vector2(200 + randf() * 200, randf() * 300 - 150))
	world.ch6.frost = 3
	await _wait(1.6)
	await _shot(dir, "15-region6")
	p.play_seconds = float(int(p.play_seconds / GameWorld.Ch6.CYCLE) + 1) * GameWorld.Ch6.CYCLE + 200.0
	await _wait(0.5)
	await _shot(dir, "15b-night6")
	p.quest.ch6 = 6
	world._load_map("6-3")
	world.player.pos = world.arena_pos - Vector2(120, 0)
	await _wait(1.0)
	var bn = world.boss()
	if bn != null:
		bn.hp = bn.max_hp * 0.45
	await _wait(1.2)
	await _shot(dir, "15d-ban-nga")
	world.player.shield = 0.0
	# M10: chương 7 Thiên Không Đảo — lãnh địa Hoàng Thành, Bến Mây, đảo bay, Cự Thần, kết chương
	for panel in _panels():
		panel.close()
	p.bosses["ban-nga"] = true
	p.quest.ch6 = GameWorld.Story.DONE6
	p.camp_level = 5
	for k in ["camp2", "camp3", "camp4", "camp5", "port"]:
		p.buildings[k] = 0.0
	p.level = maxi(p.level, 76)
	world._refresh_stats()
	world._load_map("1-1")
	map_panel.open(world)
	await _wait(0.3)
	_skip_dialog()
	await _wait(0.3)
	await _shot(dir, "17b-territory5")
	map_panel.close()
	world._load_map("7-1")
	world.player.pos = world.safe_pos + Vector2(60, 40)
	await _wait(1.0)
	_skip_dialog()
	await _wait(0.3)
	await _shot(dir, "17c-camp7")
	world.player.pos = Vector2(1500, 900) * Maps.MAP_SCALE
	world.player.shield = 1e9
	world.player.shield_time = 999.0
	for k in ["dai-bang-may", "nguoi-go-dao", "tien-gio", "hiep-si-thien-khong"]:
		world.spawn_with_hooks(k, 76, world.player.pos + Vector2(150 + randf() * 200, randf() * 200 - 100))
	await _wait(1.6)
	_skip_dialog()
	await _wait(0.3)
	await _shot(dir, "17-region7")
	p.quest.ch7 = GameWorld.Ch7.S_BOSS
	world._load_map("7-3")
	world.player.pos = world.arena_pos - Vector2(120, 0)
	await _wait(1.0)
	var ct = world.boss()
	if ct != null:
		ct.hp = ct.max_hp * 0.5
		world.ch7.broken[1] = true
		world.ch7.sector_warn = 2
		world.ch7.sector_warn_t = 3.0
	await _wait(1.2)
	_skip_dialog()
	await _wait(0.3)
	await _shot(dir, "17d-cu-than")
	world.player.shield = 0.0
	if ct != null:
		ct.dead = true
	world.enemies = []
	p.bosses["cu-than"] = true
	world.player.pos = world.arena_pos + Vector2(0, 90)
	await _wait(0.8)
	_skip_dialog()
	await _wait(0.3)
	await _shot(dir, "18-chapter7-end")
	p.evo = 2
	p.talent_level = 19
	world._refresh_stats()
	talent_panel.open(world)
	await _wait(0.3)
	await _shot(dir, "18b-talent-evo2")
	talent_panel.close()
	# M11: chương 8 Vực Hư Vô — Tiền Đồn Tinh Quang, Suy Thiên + đèn + Cột Đá, Giáo Chủ Hư Vô
	p.quest.ch7 = GameWorld.Story.DONE7
	p.level = maxi(p.level, 88)
	world._refresh_stats()
	world._load_map("8-1")
	world.player.pos = world.safe_pos + Vector2(60, 40)
	await _wait(1.0)
	_skip_dialog()
	await _wait(0.3)
	await _shot(dir, "19c-camp8")
	var lamp8: Vector2 = GameWorld.Ch8.lamps(world)[3]
	world.player.pos = lamp8 + Vector2(220, 60)
	world.ch8.decay = 0.3
	world.player.shield = 1e9
	world.player.shield_time = 999.0
	for k in ["bong-hu-vo", "ke-nuot", "giap-si-hu-vo", "mat-hu-vo"]:
		world.spawn_with_hooks(k, 86, world.player.pos + Vector2(150 + randf() * 200, randf() * 200 - 100))
	world.spawn_with_hooks("giap-si-hu-vo", 90, world.player.pos + Vector2(-160, 80), {"elite": true})
	await _wait(1.6)
	_skip_dialog()
	await _wait(0.3)
	await _shot(dir, "19-region8")
	p.quest.ch8 = GameWorld.Ch8.S_BOSS
	world._load_map("8-3")
	world.player.pos = world.arena_pos - Vector2(120, 0)
	await _wait(1.0)
	var gc = world.boss()
	if gc != null:
		gc.hp = gc.max_hp * 0.5
		gc.phase = 2
		world.ch8.chan_t = 1.0
	await _wait(0.6)
	_skip_dialog()
	await _wait(0.3)
	await _shot(dir, "19d-giao-chu")
	world.enemies = []
	# M12: chương 9 Thiên Đạo Chi Môn — tầng + hệ tầng, Ma Tôn, màn lựa chọn, danh đề
	p.bosses["giao-chu"] = true
	p.job3 = str(GameWorld.Classes.job3_def(str(p.class_id)).id)
	p.quest.ch8 = GameWorld.Story.DONE8
	p.level = maxi(p.level, 97)
	world._refresh_stats()
	world._load_map("9-1")
	world.player.pos = world.safe_pos + Vector2(60, 40)
	await _wait(1.0)
	_skip_dialog()
	await _wait(0.3)
	await _shot(dir, "21c-camp9")
	world.player.pos = Vector2(1000, 1100) * Maps.MAP_SCALE
	for k in ["thien-binh", "tan-hon", "thien-ma", "linh-thu-ngu-hanh"]:
		world.spawn_with_hooks(k, 95, world.player.pos + Vector2(150 + randf() * 200, randf() * 200 - 100))
	await _wait(1.4)
	_skip_dialog()
	await _wait(0.3)
	await _shot(dir, "21-region9")
	p.floors9 = [1, 2, 3, 4, 5, 6, 7, 8, 9]
	p.quest.ch9 = GameWorld.Ch9.S_BOSS
	world._load_map("9-3")
	world.player.pos = world.arena_pos - Vector2(120, 0)
	await _wait(1.0)
	var mt = world.boss()
	if mt != null:
		mt.hp = mt.max_hp * 0.3
	await _wait(0.6)
	_skip_dialog()
	await _wait(0.3)
	await _shot(dir, "21d-ma-ton")
	if mt != null:
		world._kill_enemy(mt)
	world.enemies = []
	world.Ch9.check_quest(world)
	await _wait(0.8)
	_skip_dialog()
	await _wait(0.3)
	await _shot(dir, "22-ending-choice")
	_close_victory()
	world.Ch9.choose_ending(world, "hien-te")
	await _wait(0.5)
	while dialog.is_open():
		_skip_dialog()
		await _wait(0.1)
	await _wait(0.5)
	await _shot(dir, "22d-credits")
	_close_victory()
	# SN9-02: màn Chọn nhân vật (ô 1 = nhân vật smoke, thêm 1 nhân vật mẫu ở ô 3)
	_persist()
	var p3 := Profile.new()
	p3.setup("mat-ung", RngUtil.make(3), _now(), "phap-su")
	p3.name = "Lam Vân"
	p3.level = 34
	SaveSystem.select_slot(3)
	SaveSystem.save_profile(p3)
	SaveSystem.select_slot(1)
	_end_session()
	_open_slots()
	await _wait(0.4)
	await _shot(dir, "00-slots")
	SaveSystem.delete_slot(3)
	print("SMOKE done: boss_defeated=%s level=%d kills=%d" % [p.boss_defeated, p.level, p.kills])
	SaveSystem.clear_save()
	get_tree().quit()


# ------------------------------------------------------------------ C1-41, C1-42: nhạc nền, menu tạm dừng, cài đặt


## Rà soát 01/11: nhạc theo vùng (tools/audio/music.py) — vùng 2–9 có bản riêng; boss vùng 7–9 dùng "boss_final";
## hang phụ dùng "core" (u ám); vùng an toàn dùng "village".
const REGION_MUSIC := {1: "forest", 2: "plains", 3: "desert", 4: "swamp", 5: "volcano", 6: "tundra", 7: "sky", 8: "void", 9: "heaven"}


func _music_for(w: GameWorld) -> String:
	var region := int(w.map.get("region", 1))
	if w.big_enemy() != null:
		return "boss_final" if region >= 7 else "boss"
	if w.map_id == "1-3" or w.in_cave():
		return "core"
	if w.player.pos.distance_to(w.safe_pos) < w.safe_r + 250.0:
		return "village"
	return str(REGION_MUSIC.get(region, "forest"))


func _open_pause(settings_only := false) -> void:
	if _pause != null:
		return
	_pause = PauseMenu.new()
	_pause.settings_only = settings_only
	_pause.resume.connect(_close_pause)
	_pause.font_scale_changed.connect(func(k: float): _ui.theme = UiTheme.set_font_scale(k))
	_pause.help.connect(func():
		_close_pause()
		if help_panel != null and world != null:
			help_panel.open(world))
	_pause.quit_to_title.connect(func():
		_close_pause()
		_go_title())
	_ui.add_child(_pause)


func _open_settings() -> void:
	_open_pause(true)


func _close_pause() -> void:
	if _pause != null:
		_pause.queue_free()
		_pause = null
