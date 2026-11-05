extends Control
## PF-01 (04/11, "di chuyển giật"): lớp vẽ con chỉ vẽ lại khi được gọi queue_redraw() — phần trang trí tĩnh của HUD
## (khung đồng, rồng, vành nút…) tách ra đây để không chạy lại code vẽ GDScript mỗi khung hình.
## paint: Callable(cv: CanvasItem) — vẽ bằng cv.draw_* / cv.get_canvas_item(), toạ độ cục bộ của node cha.
## behind = true: vẽ sau lưng node cha (show_behind_parent); false: vẽ đè lên phần cha vẽ.
## bake = true: vẽ một lần vào SubViewport (đúng độ phân giải màn hình) rồi mỗi khung chỉ vẽ 1 ảnh — hàng trăm lệnh
## vẽ (cung, đa giác, chữ) thành 1 draw call. Ảnh trong suốt ghép bằng premultiplied alpha nên viền mờ / bóng giữ đúng màu.
## Nướng lại khi queue_redraw() (rebake()) hoặc khi tỉ lệ màn hình đổi (đổi cỡ cửa sổ).

## Phần vẽ tràn ra ngoài khung node cha (đầu rồng, gai, nhãn phím…) — px mỗi phía.
const MARGIN := 96.0

var paint: Callable
var bake := false
var _vp: SubViewport
var _painter: Node2D
var _k := 0.0
var _box := Rect2()
var _ready_tex := false
## Đã nướng xong ít nhất một lần (ảnh trong SubViewport dùng được).
var _has_tex := false
var _premult: CanvasItemMaterial


func _init(p: Callable = Callable(), behind := false, baked := false) -> void:
	paint = p
	show_behind_parent = behind
	mouse_filter = MOUSE_FILTER_IGNORE
	bake = baked
	if bake:
		_premult = CanvasItemMaterial.new()
		_premult.blend_mode = CanvasItemMaterial.BLEND_MODE_PREMULT_ALPHA
		material = _premult
		set_process(true)


## Vẽ lại (bản nướng: nướng lại ảnh).
func rebake() -> void:
	_ready_tex = false
	queue_redraw()


func _process(_delta: float) -> void:
	if bake and is_visible_in_tree() and absf(_scale() - _k) > 0.01:
		rebake()


func _scale() -> float:
	return (get_viewport().get_final_transform() * get_global_transform_with_canvas()).get_scale().x if is_inside_tree() else 1.0


func _draw() -> void:
	if not paint.is_valid():
		return
	if not bake:
		paint.call(self)
		return
	if _ready_tex and _vp != null:
		draw_texture_rect(_vp.get_texture(), _box, false)
		return
	_bake()
	if _vp != null and _has_tex:
		# Đã có ảnh: SubViewport vẽ lại ngay trên ảnh đó → vẫn vẽ ảnh (không có khung vẽ thẳng nào chen vào —
		# vẽ thẳng qua chế độ trộn premultiplied sáng hơn → chớp sáng mỗi lần nướng lại).
		draw_texture_rect(_vp.get_texture(), _box, false)
	else:
		# Lần nướng đầu: chưa có ảnh — vẽ thẳng 1 khung với chế độ trộn thường.
		material = null
		paint.call(self)


func _bake() -> void:
	var owner_size: Vector2 = (get_parent() as Control).size if get_parent() is Control else size
	_k = maxf(0.25, _scale())
	_box = Rect2(-Vector2.ONE * MARGIN, owner_size + Vector2.ONE * MARGIN * 2.0)
	if _vp == null:
		_vp = SubViewport.new()
		_vp.transparent_bg = true
		_vp.disable_3d = true
		_vp.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_LINEAR
		_painter = Node2D.new()
		_painter.draw.connect(func(): paint.call(_painter))
		_vp.add_child(_painter)
		add_child(_vp)
	var want := Vector2i(ceili(_box.size.x * _k), ceili(_box.size.y * _k))
	if _vp.size != want:
		_vp.size = want
	_painter.position = Vector2.ONE * MARGIN * _k
	_painter.scale = Vector2.ONE * _k
	_painter.queue_redraw()
	_vp.render_target_update_mode = SubViewport.UPDATE_ONCE
	if not RenderingServer.frame_post_draw.is_connected(_on_baked):
		RenderingServer.frame_post_draw.connect(_on_baked, CONNECT_ONE_SHOT)


func _on_baked() -> void:
	if not is_instance_valid(self):
		return
	_ready_tex = true
	_has_tex = true
	if material == null:
		material = _premult
	queue_redraw()
