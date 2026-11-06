extends Control
## EN-1 (docs/43 §5–6, hướng D): hiệu ứng đồ cường hoá đặt trên ô đồ (túi, đang mặc, Lò Rèn, thẻ thông tin).
## Khung ô giữ màu phẩm chất; hiệu ứng mang màu bậc cường hoá (Items.enhance_color: bạc → lam băng → vàng kim → huyết hồng).
##   +4…+12 "ánh kim": viền sáng theo dáng món (thở nhẹ), vệt sáng trắng lướt chéo mỗi 2 giây, sao lấp lánh;
##           +10…+12 thêm quầng sáng sau món.
##   +13…+15 "linh hoả": lửa linh khí bốc lên từ món đồ + tàn lửa bay; +15 viền cầu vồng xoay.
##   Quanh viền ô: vệt sáng sao chổi chạy theo chiều kim đồng hồ (1 vòng / 2 giây; +10 có 2 vệt; +13 chạy nhanh gấp đôi).
##   Mọi cấp > 0: tấm "+N" góc dưới phải.
## Cấu trúc: node này vẽ vệt viền + sao + tấm "+N"; con `Glow` (show_behind_parent, shader cộng sáng) vẽ phần bám dáng món
## đồ bằng cách đọc kênh alpha của chính icon. Đặt phủ toàn ô (PRESET_FULL_RECT), bỏ qua chuột.

const Items = preload("res://scripts/core/items.gd")
const UiTheme = preload("res://scripts/ui/ui_theme.gd")

const SHADER_CODE := """
shader_type canvas_item;
render_mode blend_add;
uniform int tier = 0;
uniform bool rainbow = false;
uniform vec4 tcol : source_color = vec4(1.0);
uniform vec2 ioff = vec2(0.05);
uniform vec2 iscale = vec2(0.9);
uniform float phase = 0.0;
uniform sampler2D icon_tex : filter_linear_mipmap, repeat_disable;

float A(vec2 uv) {
	vec2 q = (uv - ioff) / iscale;
	if (q.x < 0.0 || q.y < 0.0 || q.x > 1.0 || q.y > 1.0) return 0.0;
	return texture(icon_tex, q).a;
}
float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float vnoise(vec2 p) {
	vec2 i = floor(p); vec2 f = fract(p); f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1, 0)), f.x), mix(hash(i + vec2(0, 1)), hash(i + vec2(1, 1)), f.x), f.y);
}
float ring_max(vec2 uv, float r) {
	float m = 0.0;
	for (int i = 0; i < 12; i++) {
		float an = 6.2831853 * float(i) / 12.0;
		m = max(m, A(uv + vec2(cos(an), sin(an)) * r));
	}
	return m;
}
void fragment() {
	vec2 uv = UV;
	float t = TIME + phase;
	float a = A(uv);
	vec3 col = vec3(0.0);
	float ft = float(tier);
	if (tier >= 3) {
		float s = 0.0;
		for (int i = 0; i < 16; i++) {
			float an = 6.2831853 * float(i) / 16.0;
			s += A(uv + vec2(cos(an), sin(an)) * 0.07) + A(uv + vec2(cos(an), sin(an)) * 0.035);
		}
		s /= 32.0;
		col += tcol.rgb * s * (1.0 - a) * (tier >= 4 ? 0.55 : 0.9);
	}
	if (tier <= 3) {
		float edge = ring_max(uv, 0.008 + 0.006 * ft) * (1.0 - a);
		float soft = ring_max(uv, 0.02 + 0.006 * ft) * (1.0 - a);
		float breathe = 0.82 + 0.18 * sin(t * 3.14159);
		col += tcol.rgb * (edge * (0.55 + 0.15 * ft) + soft * 0.25) * breathe;
	} else {
		float f = 0.0;
		for (int k = 1; k <= 12; k++) {
			float fk = float(k) / 12.0;
			float wob = (vnoise(vec2(uv.x * 9.0, uv.y * 5.0 + t * 2.6)) - 0.5) * 0.07 * fk;
			f = max(f, A(uv + vec2(wob, fk * 0.24)) * (1.0 - fk));
		}
		f *= smoothstep(0.15, 0.85, vnoise(uv * vec2(11.0, 7.0) + vec2(0.0, t * 3.2)) * 1.35);
		f *= (1.0 - a * 0.93);
		col += tcol.rgb * f * 1.15 + vec3(1.0, 0.9, 0.8) * pow(f, 2.5) * 0.6;
	}
	float cyc = fract(t * 0.5);
	if (cyc < 0.4) {
		float pos = mix(-0.25, 2.25, cyc / 0.4);
		float band = exp(-pow((uv.x + uv.y - pos) / (0.05 + 0.008 * ft), 2.0));
		col += vec3(1.0) * band * a * (0.2 + 0.05 * ft);
	}
	if (rainbow) {
		float r2 = ring_max(uv, 0.03);
		float r1 = ring_max(uv, 0.018);
		float ring = clamp(r2 - r1, 0.0, 1.0);
		float hue = atan(uv.y - 0.5, uv.x - 0.5) / 6.2831853 + t * 0.5;
		col += (0.5 + 0.5 * cos(6.2831853 * (hue + vec3(0.0, 0.33, 0.67)))) * ring * 0.9;
	}
	COLOR = vec4(col, 1.0);
}
"""

const CYCLE := 2.0          # giây / vòng (vệt viền, vệt lướt)

static var _shader: Shader
static var _points := {}    # instance_id của texture → điểm đặc trên icon (UV 0..1), để đặt sao lấp lánh

var plus := 0
var tex: Texture2D
var inset := 3.0            # lề từ mép node tới icon (SlotBox content margin = 3)
var radius := 7.0           # bo góc khung ô (cho vệt chạy viền)
var badge := true
var seed := 0
var glow: Control


## Tạo hiệu ứng phủ lên ô `host` cho món `item` (icon `tex`). Luôn trả về node (cấp 0 chỉ không vẽ gì).
static func attach(host: Control, item: Dictionary, tex: Texture2D, inset := 3.0, radius := 7.0) -> Control:
	var fx = load("res://scripts/ui/enhance_fx.gd").new()
	fx.name = "EnhanceFx"
	fx.plus = int(item.get("plus", 0))
	fx.tex = tex
	fx.inset = inset
	fx.radius = radius
	fx.seed = int(item.get("id", 0))
	fx.mouse_filter = MOUSE_FILTER_IGNORE
	fx.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	host.add_child(fx)
	fx._build()
	return fx


func tier() -> int:
	return Items.enhance_tier(plus)


func _ready() -> void:
	_build()


func _build() -> void:
	if glow != null:
		return
	var t := tier()
	set_process(t > 0)
	if t > 0 and tex != null:
		if _shader == null:
			_shader = Shader.new()
			_shader.code = SHADER_CODE
		glow = Control.new()
		glow.name = "Glow"
		glow.show_behind_parent = true
		glow.mouse_filter = MOUSE_FILTER_IGNORE
		glow.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
		var m := ShaderMaterial.new()
		m.shader = _shader
		m.set_shader_parameter("tier", t)
		m.set_shader_parameter("rainbow", plus >= 15)
		m.set_shader_parameter("tcol", Items.enhance_color(plus))
		m.set_shader_parameter("phase", float(seed % 7) * 0.37)
		var src := tex
		if tex is CanvasTexture and (tex as CanvasTexture).diffuse_texture != null:
			src = (tex as CanvasTexture).diffuse_texture
		m.set_shader_parameter("icon_tex", src)
		glow.material = m
		glow.draw.connect(_draw_glow)
		glow.resized.connect(_update_uv)
		add_child(glow)
		_update_uv()


func _process(_delta: float) -> void:
	queue_redraw()


## Rect icon trong node: hình vuông giữa phần trong lề (giống Button expand_icon giữ tỉ lệ).
func icon_rect() -> Rect2:
	var inner := Rect2(Vector2.ONE * inset, size - Vector2.ONE * inset * 2.0)
	var s := minf(inner.size.x, inner.size.y)
	return Rect2(inner.position + (inner.size - Vector2(s, s)) / 2.0, Vector2(s, s))


func _update_uv() -> void:
	if glow == null or size.x <= 0.0:
		return
	var r := icon_rect()
	var m: ShaderMaterial = glow.material
	m.set_shader_parameter("ioff", r.position / size)
	m.set_shader_parameter("iscale", r.size / size)


func _draw_glow() -> void:
	# shader nhận UV phủ toàn node; icon nằm trong [ioff, ioff + iscale] → lửa / quầng tràn ra ngoài icon được
	glow.draw_texture_rect(tex, Rect2(Vector2.ZERO, size), false)


func _now() -> float:
	return Time.get_ticks_msec() / 1000.0


func _draw() -> void:
	var t := tier()
	var k := size.x / 112.0
	if t > 0:
		var col := Items.enhance_color(plus)
		_draw_sparkles(t, col, k)
		if t >= 4:
			_draw_embers(col, k)
		var u := fmod(_now() / CYCLE * (2.0 if t >= 4 else 1.0), 1.0)
		_draw_runner(u, t, col, k)
		if t >= 3:
			_draw_runner(u + 0.5, t, col, k)
	if badge and plus > 0:
		_draw_badge(t, k)


## Điểm trên viền ô bo góc; u ∈ [0, 1) bắt đầu ở góc trên-trái, đi theo chiều kim đồng hồ.
func perimeter_point(u: float) -> Vector2:
	var a := 1.5
	var w := size.x - 1.0 - a
	var h := size.y - 1.0 - a
	var r := minf(radius, minf(size.x, size.y) / 3.0)
	var lx := w - a - 2.0 * r
	var ly := h - a - 2.0 * r
	var arc := PI * r / 2.0
	var total := 2.0 * lx + 2.0 * ly + 4.0 * arc
	var d := fposmod(u, 1.0) * total
	var segs := [[lx, Vector2(a + r, a), Vector2(w - r, a)], [arc, Vector2(w - r, a + r), -90.0],
		[ly, Vector2(w, a + r), Vector2(w, h - r)], [arc, Vector2(w - r, h - r), 0.0],
		[lx, Vector2(w - r, h), Vector2(a + r, h)], [arc, Vector2(a + r, h - r), 90.0],
		[ly, Vector2(a, h - r), Vector2(a, a + r)], [arc, Vector2(a + r, a + r), 180.0]]
	for s in segs:
		var ln: float = s[0]
		if d <= ln:
			var q := d / maxf(ln, 0.001)
			if s[2] is Vector2:
				return (s[1] as Vector2).lerp(s[2], q)
			var ang := deg_to_rad(float(s[2]) + 90.0 * q)
			return (s[1] as Vector2) + Vector2(cos(ang), sin(ang)) * r
		d -= ln
	return Vector2(a + r, a)


func _draw_runner(u: float, t: int, col: Color, k: float) -> void:
	var tail := 0.16 + 0.04 * t
	var steps := 28
	var bright := col.lerp(Color.WHITE, 0.55)
	for pass_i in 2:   # lượt 0: quầng mờ to; lượt 1: lõi sáng
		for i in steps:
			var q := float(i) / steps
			var p := perimeter_point(u - q * tail)
			var fade := pow(1.0 - q, 1.6)
			var w := (2.2 + 0.35 * t) * (1.0 - q * 0.55) * k
			if pass_i == 0:
				draw_circle(p, w * 2.6, Color(col, 0.10 * fade))
			else:
				draw_circle(p, w, Color(col.lerp(bright, 1.0 - q), 0.9 * fade))
	_star(perimeter_point(u), (4.0 + t) * k, col, 1.0)


func _star(c: Vector2, r: float, col: Color, a: float) -> void:
	if r < 0.5 or a <= 0.02:
		return
	var w := r * 0.22
	var pts := PackedVector2Array([c + Vector2(0, -r), c + Vector2(w, -w), c + Vector2(r, 0), c + Vector2(w, w),
		c + Vector2(0, r), c + Vector2(-w, w), c + Vector2(-r, 0), c + Vector2(-w, -w)])
	draw_circle(c, r * 0.9, Color(col, 0.18 * a))
	draw_colored_polygon(pts, Color(col, a))
	draw_circle(c, r * 0.28, Color(1, 1, 1, a))


func _draw_sparkles(t: int, col: Color, k: float) -> void:
	var pts := _icon_points()
	if pts.is_empty():
		return
	var r := icon_rect()
	var n := t + (1 if t >= 3 else 0)
	var now := _now() / CYCLE
	for i in n:
		var uv: Vector2 = pts[(seed * 7 + i * 5) % pts.size()]
		var ph := fmod(float(seed % 11) * 0.13 + i * 0.37, 1.0)
		var a := maxf(0.0, sin((now + ph) * TAU))
		if a > 0.05:
			var c := r.position + uv * r.size
			_star(c, (4.0 + t) * k * (0.5 + 0.5 * a), col, a)
			_star(c, (2.5 + t * 0.4) * k * a, Color.WHITE, a)


func _draw_embers(col: Color, k: float) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var now := _now() / CYCLE
	var hot := col.lightened(0.3)
	for i in 12:
		var x0 := rng.randf_range(0.12, 0.88) * size.x
		var sp := rng.randf_range(0.6, 1.2)
		var life := fmod(now * sp + rng.randf(), 1.0)
		var p := Vector2(x0 + 4.0 * k * sin(life * 6.0 + i), size.y * 0.7 - life * size.y * 0.65)
		draw_circle(p, (2.2 * (1.0 - life) + 0.6) * k, Color(hot, 0.95 * (1.0 - life)))


func _draw_badge(t: int, k: float) -> void:
	var f := UiTheme.bold_font()
	var fs := int(clampf(round(18.0 * k), 10.0, 20.0))
	var txt := "+%d" % plus
	var tw := f.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	var pad := maxf(3.0, 5.0 * k)
	var h := fs + 4.0
	var rect := Rect2(size - Vector2(tw + pad * 2.0 + 3.0, h + 3.0), Vector2(tw + pad * 2.0, h))
	var col := Items.enhance_color(plus) if t > 0 else Color(0.94, 0.94, 0.94)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.055, 0.04, 0.03, 0.9)
	sb.set_corner_radius_all(int(maxf(3.0, 5.0 * k)))
	sb.set_border_width_all(1 if k < 0.7 else 2)
	sb.border_color = col if t > 0 else Color(0.47, 0.43, 0.37)
	draw_style_box(sb, rect)
	draw_string(f, Vector2(rect.position.x + pad, rect.position.y + h - 4.0 - (fs * 0.08)), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, col)


## Điểm đặc (alpha > 0.9) trên icon, cache theo texture — chỗ đặt sao lấp lánh.
func _icon_points() -> Array:
	if tex == null:
		return []
	var key := tex.get_instance_id()
	if _points.has(key):
		return _points[key]
	var img: Image = null
	if tex is CanvasTexture and (tex as CanvasTexture).diffuse_texture != null:
		img = (tex as CanvasTexture).diffuse_texture.get_image()
	else:
		img = tex.get_image()
	var out := []
	if img != null:
		if img.is_compressed():
			img = img.duplicate()
			img.decompress()
		var w := img.get_width()
		var h := img.get_height()
		var step := maxi(1, w / 16)
		for y in range(step / 2, h, step):
			for x in range(step / 2, w, step):
				if img.get_pixel(x, y).a > 0.9:
					out.append(Vector2(float(x) / w, float(y) / h))
	_points[key] = out
	return out
