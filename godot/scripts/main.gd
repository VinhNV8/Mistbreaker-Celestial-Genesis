extends Node
## Điểm vào của game: dựng cây node, đọc điều khiển, điều phối màn hình, tự lưu.
## Chạy với `-- --smoke=<thư mục>` để tự chơi qua các màn hình và chụp ảnh (kiểm tra tự động).

const GameWorld = preload("res://scripts/core/game_world.gd")
const Profile = preload("res://scripts/core/profile.gd")
const RngUtil = preload("res://scripts/core/rng_util.gd")
const SaveSystem = preload("res://scripts/core/save_system.gd")
const Explore = preload("res://scripts/core/explore.gd")
const WorldView = preload("res://scripts/view/world_view.gd")
const Hud = preload("res://scripts/ui/hud.gd")
const StatsPanel = preload("res://scripts/ui/stats_panel.gd")
const MapPanel = preload("res://scripts/ui/map_panel.gd")
const InventoryPanel = preload("res://scripts/ui/inventory_panel.gd")
const TalentPanel = preload("res://scripts/ui/talent_panel.gd")
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
	"talent": [KEY_L],
	"dodge": [KEY_SPACE],
	"toggle_stats": [KEY_C],
	"toggle_map": [KEY_M, KEY_TAB],
	"toggle_inventory": [KEY_I, KEY_B],
	"toggle_talent": [KEY_T],
	"toggle_world": [KEY_N],
	"interact": [KEY_E],
	"auto_fight": [KEY_Z],
	"toggle_minimap": [KEY_V],
	"potion": [KEY_Q],
	"close_panel": [KEY_ESCAPE],
}
const MOUSE_ACTIONS := {"attack": MOUSE_BUTTON_LEFT, "skill": MOUSE_BUTTON_RIGHT}

var world: GameWorld
var hud: Hud
var stats_panel: StatsPanel
var map_panel: MapPanel
var inventory_panel: InventoryPanel
var talent_panel: TalentPanel
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
		if shop_panel.is_open():
			shop_panel.close()
		elif not npc.is_empty() and world.talk(str(npc.id)) != "shop":
			pass
		elif world.in_village():
			for panel in _panels():
				panel.close()
			shop_panel.open(world)
		else:
			hud.log_message("Cửa hàng ở Làng Thanh Thạch — đứng trong làng rồi bấm E.", "info")
		get_viewport().set_input_as_handled()
		return
	for pair in [["toggle_stats", stats_panel], ["toggle_map", map_panel], ["toggle_inventory", inventory_panel], ["toggle_talent", talent_panel], ["toggle_world", world_panel]]:
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


func _panels() -> Array:
	return [stats_panel, map_panel, inventory_panel, talent_panel, world_panel, shop_panel]


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
	if kb_aim:
		aim = world.player.pos + _kb_dir * 100.0
	return {
		"move": move,
		"aim": aim,
		"kb_aim": kb_aim,
		"attack": Input.is_action_pressed("attack"),
		"skill": Input.is_action_just_pressed("skill"),
		"skill_1": Input.is_action_just_pressed("skill_1"),
		"skill_2": Input.is_action_just_pressed("skill_2"),
		"skill_3": Input.is_action_just_pressed("skill_3"),
		"skill_4": Input.is_action_just_pressed("skill_4"),
		"talent": Input.is_action_just_pressed("talent"),
		"dodge": Input.is_action_just_pressed("dodge"),
		"potion": Input.is_action_just_pressed("potion"),
	}


func _handle_event(ev: Dictionary) -> void:
	match ev.type:
		"message":
			hud.log_message(ev.text, ev.tone)
		"levelup":
			hud.banner("Lên cấp %d!" % ev.level)
			_persist()
		"tile":
			_persist()
		"map":
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
		"victory":
			_persist()
			_victory = Screens.victory(world, _after_victory, _go_title, str(ev.get("boss", "boss")))
			_ui.add_child(_victory)


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
	_set_screen(Screens.title(SaveSystem.has_save(), _on_new_game, _on_continue, _open_settings))
	audio.music("village")


func _on_new_game() -> void:
	if not SaveSystem.has_save():
		_start_awakening()
		return
	var dlg := ConfirmationDialog.new()
	dlg.title = "Hành trình mới"
	dlg.dialog_text = "Hành trình mới sẽ xoá tiến trình đang lưu. Tiếp tục?"
	dlg.ok_button_text = "Xoá và bắt đầu"
	dlg.cancel_button_text = "Huỷ"
	dlg.confirmed.connect(_start_awakening)
	dlg.visibility_changed.connect(func():
		if not dlg.visible:
			dlg.queue_free())
	_ui.add_child(dlg)
	dlg.popup_centered()


## Kịch bản mục 9: Mở đầu (C1-10) → Tạo nhân vật (C1-02) → Lễ Thức Tỉnh.
var _pending_hero := {}


func _start_awakening() -> void:
	SaveSystem.clear_save()
	_set_screen(IntroScreen.new(_on_intro_done))


func _on_intro_done() -> void:
	_set_screen(CreateScreen.new(_on_hero_created))


func _on_hero_created(hero: Dictionary) -> void:
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
	_start_world(p)


func _on_continue() -> void:
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
	stats_panel = StatsPanel.new()
	_ui.add_child(stats_panel)
	map_panel = MapPanel.new()
	_ui.add_child(map_panel)
	inventory_panel = InventoryPanel.new()
	_ui.add_child(inventory_panel)
	talent_panel = TalentPanel.new()
	_ui.add_child(talent_panel)
	world_panel = WorldMapPanel.new()
	_ui.add_child(world_panel)
	shop_panel = ShopPanel.new()
	_ui.add_child(shop_panel)
	dialog = DialogBox.new()
	_ui.add_child(dialog)
	dialog.setup(p.name, p.class_id, p.look)
	# Thoại phát lúc tạo thế giới (bước nhiệm vụ đầu) nằm trong hàng sự kiện, _process sẽ xử lý.
	_fit_camera()
	map_panel.nest_started.connect(func(): hud.log_message("Thủ lĩnh ổ quái đã xuất hiện trước mặt bạn!", "bad"))
	_camera.position = world.player.pos
	_camera.reset_smoothing()


func _end_session() -> void:
	_close_victory()
	for n in [hud, stats_panel, map_panel, inventory_panel, talent_panel, world_panel, dialog, shop_panel]:
		if n != null:
			n.queue_free()
	hud = null
	stats_panel = null
	map_panel = null
	inventory_panel = null
	talent_panel = null
	world_panel = null
	dialog = null
	shop_panel = null
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
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(dir.path_join(file + ".png"))
	print("SMOKE shot ", file)


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
	SaveSystem.save_path = "user://smoke_save.json"
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
	world.profile.class_id = "kiem-khach"
	world._refresh_stats()

	var first: Dictionary = world.profile.tiles.filter(func(t): return Explore.hex_distance(t, {"q": 0, "r": 0}) == 1)[0]
	map_panel.open(world)
	map_panel._selected = int(first.id)
	world.reveal_tile(int(first.id))
	map_panel.refresh()
	await _wait(0.3)
	await _shot(dir, "04-map")
	map_panel.close()
	stats_panel.open(world)
	await _wait(0.3)
	await _shot(dir, "05-stats")
	stats_panel.close()

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
	inventory_panel.open(world)
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
	inventory_panel._play_burst(true, 10)
	await _wait(0.25)
	await _wait(0.3)
	await _shot(dir, "05c-inventory-equipped")
	inventory_panel.close()

	# Bảng Thiên phú + bản đồ có mục Công trình (M2).
	pp.wood += 200
	world.build("temple")
	pp.essence = 6
	talent_panel.open(world)
	await _wait(0.3)
	await _shot(dir, "05d-talent")
	talent_panel.close()
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
	shop_panel.close()

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
	# M4.3: Thành Biên Đài — NPC, nhiệm vụ chương 2, cửa hàng có thợ rèn
	world.enemies = []
	world.player.pos = world.safe_pos + Vector2(10, -10)
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
	world.player.pos = world.safe_pos + Vector2(10, -10)
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
	world.player.pos = world.safe_pos + Vector2(10, -10)
	await _wait(1.0)
	await _shot(dir, "12b-village4")
	world._load_map("4-2")
	world.player.pos = Vector2(1300, 900)
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
	print("SMOKE done: boss_defeated=%s level=%d kills=%d" % [p.boss_defeated, p.level, p.kills])
	SaveSystem.clear_save()
	get_tree().quit()


# ------------------------------------------------------------------ C1-41, C1-42: nhạc nền, menu tạm dừng, cài đặt


func _music_for(w: GameWorld) -> String:
	if w.big_enemy() != null:
		return "boss"
	if w.map_id == "1-3":
		return "core"
	if int(w.map.get("region", 1)) == 3:
		return "village" if w.player.pos.distance_to(w.safe_pos) < w.safe_r + 250.0 else "core"
	if w.player.pos.distance_to(w.safe_pos) < w.safe_r + 250.0:
		return "village"
	return "forest"


func _open_pause(settings_only := false) -> void:
	if _pause != null:
		return
	_pause = PauseMenu.new()
	_pause.settings_only = settings_only
	_pause.resume.connect(_close_pause)
	_pause.font_scale_changed.connect(func(k: float): _ui.theme = UiTheme.set_font_scale(k))
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
