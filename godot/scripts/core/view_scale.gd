extends RefCounted
## VS-1 (docs/44): tỷ lệ khung nhìn theo độ phân giải.
## Khung gốc 1366×768 (stretch canvas_items) — Godot phóng cả cảnh theo s = min(cửa sổ / gốc). Trước VS-1 màn hình to chỉ
## làm mọi thứ to ra, không thấy thêm map. Giờ:
##  • Cỡ giao diện u (Window.content_scale_factor): tự động 100% / 90% / 85% theo s, hoặc người chơi chọn 80–110%.
##  • Camera thế giới zoom ra theo s (nhân vật ≈ 7–7,5% chiều cao màn hình ở 1080p trở lên), nhân hệ số "Tầm nhìn".
##    content_scale_factor phóng cả lớp thế giới nên camera chia lại cho u: zoom camera = z_mục_tiêu / u.
##  • Chữ vẽ trong thế giới (tên, số sát thương…) nhân text_k = 1 / zoom camera → cỡ trên màn hình bằng chữ giao diện.
## Hàm thuần (không đụng Node) để test được.

const BASE := Vector2(1366, 768)
## Q206: số mũ zoom tự động — 1080p ≈ 0,81, 1440p ≈ 0,69.
const ZOOM_POW := 0.6
const ZOOM_MIN := 0.65
## Q207: Tầm nhìn Gần / Vừa / Xa (hệ số nhân zoom; Xa tối đa ×0,88 để không thấy quái quá xa).
const RANGES := [["near", "Gần"], ["mid", "Vừa"], ["far", "Xa"]]
const RANGE_K := {"near": 1.1, "mid": 1.0, "far": 0.88}
## Q208: cỡ giao diện. 0 = tự động.
const UI_SCALES := [[0.0, "Tự động"], [0.8, "80%"], [0.9, "90%"], [1.0, "100%"], [1.1, "110%"]]
## Giao diện thiết kế cho khung cao 768 — cỡ giao diện lớn không được làm vùng giao diện thấp hơn chừng này (bảng bị cắt).
const MIN_UI_HEIGHT := 700.0

## Hệ số nhân cỡ chữ vẽ trong thế giới (WorldView, QuestView đọc).
static var text_k := 1.0


## Hệ số Godot đang phóng khung gốc lên cửa sổ (aspect = expand).
static func stretch(win: Vector2) -> float:
	if win.x <= 0.0 or win.y <= 0.0:
		return 1.0
	return minf(win.x / BASE.x, win.y / BASE.y)


static func auto_ui(s: float) -> float:
	if s < 1.17:
		return 1.0
	if s < 1.6:
		return 0.9
	return 0.85


## Cỡ giao diện thực dùng: pick = 0 → tự động; giới hạn trên để vùng giao diện cao ≥ MIN_UI_HEIGHT.
static func ui_scale(pick: float, win: Vector2) -> float:
	var s := stretch(win)
	var u := auto_ui(s) if pick <= 0.0 else pick
	if win.y > 0.0:
		u = minf(u, maxf(0.5, win.y / (s * MIN_UI_HEIGHT)))
	return u


## Zoom mục tiêu của thế giới so với khung gốc (1 = như trước VS-1).
static func world_zoom(range_id: String, win: Vector2) -> float:
	var s := stretch(win)
	var z := clampf(pow(maxf(s, 1.0), -ZOOM_POW), ZOOM_MIN, 1.0)
	return z * float(RANGE_K.get(range_id, 1.0))


## Zoom đặt cho Camera2D (đã bù cỡ giao diện u vì content_scale_factor phóng cả thế giới).
static func camera_zoom(range_id: String, win: Vector2, u: float) -> float:
	return world_zoom(range_id, win) / maxf(0.01, u)
