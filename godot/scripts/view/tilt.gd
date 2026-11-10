extends RefCounted
## GN-1 P1 (docs/45): nghiêng phối cảnh nhẹ — mép trên màn hình (phía xa trong góc nhìn 3/4) nhỏ hơn mép dưới.
## Làm bằng 1 lớp shader đọc ảnh thế giới đã vẽ (hint_screen_texture) rồi biến dạng hình thang:
##   điểm ra (u, v) ∈ [0,1]² lấy mẫu ở  d = 1 + g·v,  x = 0,5 + (u − 0,5) / d,  y = (1 + g)·v / d
## (phép chiếu phối cảnh của mặt đất: hàng trên giữ nguyên bề ngang, hàng dưới chỉ lấy (1 − 2k) bề ngang → phóng to;
##  theo chiều dọc phía trên bị nén, phía dưới giãn). g = 2k / (1 − 2k). Luôn lấy mẫu trong màn hình → không cần vẽ thêm.
## Camera zoom ra thêm 1 / center_scale để vật ở giữa màn hình giữ cỡ như khi tắt.
## Hàm thuần để test được; main.gd dựng lớp phủ và đổi ngược toạ độ chuột qua src_uv().

## Q218: Tắt / Nhẹ (mặc định) / Vừa — k = phần bề ngang mỗi bên bị cắt ở mép dưới.
const MODES := [["off", "Tắt"], ["low", "Nhẹ"], ["mid", "Vừa"]]
const K := {"off": 0.0, "low": 0.05, "mid": 0.08}

const SHADER := """
shader_type canvas_item;
uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;
uniform float g = 0.0;
void fragment() {
	vec2 uv = SCREEN_UV;
	float d = 1.0 + g * uv.y;
	vec2 s = vec2(0.5 + (uv.x - 0.5) / d, (1.0 + g) * uv.y / d);
	COLOR = vec4(textureLod(screen_tex, s, 0.0).rgb, 1.0);
}
"""


static func g_of(mode: String) -> float:
	var k := float(K.get(mode, 0.0))
	return 2.0 * k / (1.0 - 2.0 * k)


## Điểm trên màn hình (uv, đã chuẩn hoá) → điểm ảnh thế giới gốc (uv) mà nó hiển thị.
static func src_uv(uv: Vector2, g: float) -> Vector2:
	var d := 1.0 + g * uv.y
	return Vector2(0.5 + (uv.x - 0.5) / d, (1.0 + g) * uv.y / d)


## Ngược lại: điểm ảnh thế giới gốc (uv) → chỗ nó hiện trên màn hình (vẽ mũi tên / chữ ở lớp không biến dạng).
static func dst_uv(s: Vector2, g: float) -> Vector2:
	# y = (1+g)v / (1+gv)  →  v = y / (1 + g − g·y)
	var v := s.y / (1.0 + g - g * s.y)
	var d := 1.0 + g * v
	return Vector2(0.5 + (s.x - 0.5) * d, v)


## Độ phóng ngang ở giữa màn hình (nhân vật đứng gần giữa) — camera chia cho số này để giữ cỡ nhân vật.
static func center_scale(g: float) -> float:
	return 1.0 + g * 0.5
