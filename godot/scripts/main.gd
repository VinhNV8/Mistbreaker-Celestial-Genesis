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
var _save_timer := 0.0
var _last_mouse_move := 0


func _ready() -> void:
	_setup_input()
	RenderingServer.set_default_clear_color(UiTheme.BG)

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
	_ui.theme = UiTheme.get_theme()
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
		for panel in _panels():
			panel.close()


func _panels() -> Array:
	return [stats_panel, map_panel, inventory_panel, talent_panel, world_panel]


func _any_panel_open() -> bool:
	for panel in _panels():
		if panel.is_open():
			return true
	return false


func _process(delta: float) -> void:
	if world == null:
		return
	var dt := minf(delta, 0.05)
	var paused := _victory != null or _any_panel_open()
	if not paused:
		world.update(dt, bot.call(world) if bot.is_valid() else _read_input())
	for ev in world.drain_events():
		_handle_event(ev)
	_camera.position = world.player.pos
	_vignette.modulate.a = 0.45 + 0.35 * world.player.pos.x / world.world_size.x
	_freeze_tint.visible = world.freeze_timer > 0.0
	hud.update_from(world)
	_save_timer += delta
	if _save_timer > 5.0:
		_save_timer = 0.0
		_persist()


func _read_input() -> Dictionary:
	var move := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var aim := _view.get_global_mouse_position()
	# Chơi chỉ bằng bàn phím: chuột đứng yên lâu thì chém theo hướng di chuyển.
	if move != Vector2.ZERO and Time.get_ticks_msec() - _last_mouse_move > 1500:
		aim = world.player.pos + move * 100.0
	return {
		"move": move,
		"aim": aim,
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
		"victory":
			_persist()
			_victory = Screens.victory(world, _after_victory, _go_title)
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
	_set_screen(Screens.title(SaveSystem.has_save(), _on_new_game, _on_continue))


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


func _start_awakening() -> void:
	SaveSystem.clear_save()
	_set_screen(Screens.awakening(RngUtil.make(randi()), _on_talent_chosen))


func _on_talent_chosen(talent_id: String) -> void:
	_set_screen(Screens.class_select(Talents.get_talent(talent_id).name, func(class_id): _on_class_chosen(talent_id, class_id)))


func _on_class_chosen(talent_id: String, class_id: String) -> void:
	var p := Profile.new()
	p.setup(talent_id, RngUtil.make(randi()), _now(), class_id)
	SaveSystem.save_profile(p)
	_start_world(p)
	hud.log_message("Quái Sương đang tràn vào Rừng Sương. Hãy đánh chúng, lên cấp và khai phá vùng đất (phím M).")


func _on_continue() -> void:
	var p := SaveSystem.load_profile()
	if p == null:
		return
	var off := SaveSystem.apply_offline(p, _now())
	_start_world(p)
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
	_fit_camera()
	map_panel.nest_started.connect(func(): hud.log_message("Thủ lĩnh ổ quái đã xuất hiện trước mặt bạn!", "bad"))
	_camera.position = world.player.pos
	_camera.reset_smoothing()


func _end_session() -> void:
	_close_victory()
	for n in [hud, stats_panel, map_panel, inventory_panel, talent_panel, world_panel]:
		if n != null:
			n.queue_free()
	hud = null
	stats_panel = null
	map_panel = null
	inventory_panel = null
	talent_panel = null
	world_panel = null
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
	SaveSystem.clear_save()
	_go_title()
	await _wait(0.5)
	await _shot(dir, "01-title")

	_on_new_game()
	await _wait(0.3)
	_press("RollButton")
	await _wait(1.5)
	_press("RollButton")
	await _wait(1.5)
	await _shot(dir, "02-awakening")
	_press("AcceptButton")
	await _wait(0.5)
	await _shot(dir, "02b-class")
	_press("Class_kiem-khach")
	await _wait(0.5)

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
	inventory_panel._selected_id = int(fang.id)
	inventory_panel.refresh()
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
	print("SMOKE done: boss_defeated=%s level=%d kills=%d" % [p.boss_defeated, p.level, p.kills])
	SaveSystem.clear_save()
	get_tree().quit()
