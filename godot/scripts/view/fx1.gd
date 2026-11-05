extends RefCounted
## FX-1 (docs/36): hiệu ứng kỹ năng thiết kế lại cho 70 kỹ năng, vẽ vector HD trong game (Q180–Q183).
## Chỉ vẽ — không đổi logic. Ba phần:
##  1. Dàn cảnh lúc thi triển (casts): tụ lực → phát → va chạm → tan, theo thời gian thật, quanh người /
##     theo hướng / tại điểm ngắm.
##  2. Lớp phủ cho vật thể gameplay có thật: đạn, tia sét, mưa tên, thiên thạch, vùng (sk2.ice), tường lửa,
##     cầu sấm, đồ đằng, bẫy, nghi thức gọi linh thú, sao va chạm khi quái trúng đòn.
##  3. Chính sách song song (Q181): `active(id)` — "auto" giữ hình đã duyệt (APPROVED) trừ khi có trong REPLACE,
##     "fx1" dùng FX-1 cho cả 70, "old" tắt FX-1. Cài đặt "skill_fx".

const Kit = preload("res://scripts/view/fx1_kit.gd")
const SpriteLib = preload("res://scripts/view/sprite_lib.gd")

## Kỹ năng đã có hình runtime được chủ dự án duyệt (AR-44 fx-sheet, AR-45b/45d Kiếm Khách, AR-46 slice).
const APPROVED := ["spin", "dash", "wave", "kiemy", "lientram", "hongkiem", "kiemvu", "phikiem", "vankiem", "thanhkiem",
	"kiemvuc", "huyetbao", "huyetanh", "nhatkiem", "pierce", "thientien", "banglao", "meteor", "thienhoa", "tennay",
	"thietchuy", "aulong"]
## Q181: kỹ năng đã duyệt mà chủ dự án chọn chuyển sang FX-1 ở chế độ "auto" (sửa danh sách này để chọn).
const REPLACE: Array = []
const MODES := [["fx1", "FX-1 (mặc định)"], ["auto", "FX-1, giữ hình đã duyệt"], ["old", "Hình cũ"]]

## "" = theo Cài đặt "skill_fx"; test đặt trực tiếp qua set_mode.
static var mode := ""

# ---------------------------------------------------------------- bảng màu (docs/36 §4)
static var P := {
	"kk": Kit.pal("#fff4ee", "#ffb0a0", "#ff4248", "#7a1028"),
	"kk_holy": Kit.pal("#fffbea", "#ffe89a", "#f2b83a", "#94561a"),
	"kk_blood": Kit.pal("#ffe6e6", "#ff5a66", "#b80c2a", "#3e0412"),
	"kk_god": Kit.pal("#ffffff", "#d6f2ff", "#78c4ff", "#2a56a8"),
	"ts": Kit.pal("#f2fff6", "#aaf8d0", "#2fd090", "#0e5e52"),
	"ts_gold": Kit.pal("#fffbe0", "#ffe070", "#e09a1e", "#74420e"),
	"ts_poison": Kit.pal("#f4ffd6", "#c6f05a", "#62b81c", "#284e0e"),
	"ts_trap": Kit.pal("#fff0d4", "#ffb25a", "#d2581c", "#5a1c0c"),
	"ts_star": Kit.pal("#ffffff", "#fff2b4", "#a4b4ff", "#40329a"),
	"fire": Kit.pal("#fffbe0", "#ffd25a", "#ff6418", "#9a1a06"),
	"ice": Kit.pal("#ffffff", "#c6f2ff", "#54c2ff", "#1a52a2"),
	"bolt": Kit.pal("#ffffff", "#e6d6ff", "#9e6cff", "#38188a"),
	"arcane": Kit.pal("#fff2ff", "#ffb6f0", "#cc4cff", "#4c0e86"),
	"necro": Kit.pal("#f2ffe6", "#b4ff94", "#5ec83e", "#341452"),
	"metal": Kit.pal("#ffffff", "#eef2f8", "#b8c4d4", "#4c5668"),
	"wood": Kit.pal("#f0ffe0", "#a6f07a", "#3eaa38", "#16481c"),
	"earth": Kit.pal("#fff2d8", "#e2b67c", "#a86c3c", "#462c16"),
	"hv": Kit.pal("#fffef0", "#fff09c", "#f0be3a", "#94580e"),
	"hv_steel": Kit.pal("#ffffff", "#dae6f6", "#86a6d0", "#34466c"),
	"hv_earth": Kit.pal("#fff0d6", "#dcb47c", "#a26a3a", "#46301a"),
	"th": Kit.pal("#f8f0ff", "#d6b6ff", "#9868ff", "#38188a"),
	"th_teal": Kit.pal("#e6fffa", "#98f0e0", "#2ebeae", "#0c4e50"),
	"th_dragon": Kit.pal("#fffbe0", "#ffce6a", "#ff7626", "#8a1e0e"),
	"th_storm": Kit.pal("#ffffff", "#ddeeff", "#6caeff", "#283a98"),
	"th_wind": Kit.pal("#f2fff8", "#b6f6da", "#46cfa0", "#145a4a"),
	"th_qilin": Kit.pal("#ffffff", "#fff0b0", "#ffb03c", "#2a8ab0"),
	"heal": Kit.pal("#f4fff0", "#c8ffb0", "#6ad870", "#1c6a2a"),
}
## Nhịp 12 khung của bản thiết kế (docs/36 §3.1, ms): 4 tụ lực · phát · va chạm 190 ms · 6 tan (khung cuối 260 ms).
const DUR_MS := [110, 90, 80, 70, 50, 190, 80, 80, 90, 100, 110, 260]
## Kiểu dàn cảnh chạy theo nhịp thiết kế → khung bắt đầu. Sát thương xảy ra ngay lúc thi triển nên bỏ bớt phần tụ lực
## (bắt đầu ở khung 3 / 2), phần va chạm và tan giữ đúng thời lượng thiết kế.
const DESIGN_TIME := {"spin": 3, "nova": 3, "cone": 3, "dash": 2, "lientram": 2}
const DUST := Color(0.49, 0.45, 0.41)
const FROST := Color(0.77, 0.87, 0.94)

## id → [lớp, bảng màu, kiểu dàn cảnh, thời lượng (giây), tham số]. Bán kính = hằng gameplay (px, 10 px = 1 m).
const SK := {
	# Kiếm Khách
	"spin": ["kiem-khach", "kk", "spin", 0.55, {"r": 125.0}],
	"dash": ["kiem-khach", "kk", "dash", 0.6, {}],
	"wave": ["kiem-khach", "kk", "muzzle", 0.35, {}],
	"kiemy": ["kiem-khach", "kk", "buff", 8.0, {"glyph": "sword", "orbit": 2}],
	"lientram": ["kiem-khach", "kk", "lientram", 0.9, {}],
	"hongkiem": ["kiem-khach", "kk", "nova", 0.7, {"r": 80.0, "swords": 8, "stun": true}],
	"kiemvu": ["kiem-khach", "kk", "orbit", 2.0, {"r": 90.0, "n": 4, "obj": "sword"}],
	"phikiem": ["kiem-khach", "kk", "muzzle", 0.35, {}],
	"vankiem": ["kiem-khach", "kk", "rain_self", 2.4, {"r": 150.0, "obj": "sword", "dim": true}],
	"thanhkiem": ["kiem-khach", "kk_holy", "muzzle", 0.45, {"big": true}],
	"kiemvuc": ["kiem-khach", "kk_holy", "nova", 0.6, {"r": 100.0, "implode": false}],
	"huyetbao": ["kiem-khach", "kk_blood", "nova", 0.8, {"r": 90.0, "leech": true}],
	"huyetanh": ["kiem-khach", "kk_blood", "dash", 0.8, {"x": true}],
	"nhatkiem": ["kiem-khach", "kk_god", "cleave", 1.1, {"len": 400.0, "charge": 0.5, "dim": true}],
	# Thợ Săn
	"rain": ["tho-san", "ts", "muzzle_up", 0.4, {}],
	"pierce": ["tho-san", "ts", "muzzle", 0.3, {}],
	"lanban": ["tho-san", "ts", "roll", 0.6, {}],
	"eagle": ["tho-san", "ts_gold", "buff", 6.0, {"glyph": "eye"}],
	"tennay": ["tho-san", "ts", "muzzle", 0.3, {}],
	"trap": ["tho-san", "ts_trap", "toss", 0.4, {}],
	"lienxa": ["tho-san", "ts", "rapid", 1.5, {"n": 8}],
	"tendoc": ["tho-san", "ts_poison", "muzzle", 0.3, {}],
	"thientien": ["tho-san", "ts", "muzzle_up", 0.6, {"dim": true}],
	"phakhong": ["tho-san", "ts_star", "muzzle", 0.5, {"rings": true}],
	"tamlien": ["tho-san", "ts_star", "rapid", 1.2, {"n": 3}],
	"baimin": ["tho-san", "ts_trap", "toss", 0.5, {"ring": 70.0}],
	"luoibay": ["tho-san", "ts", "point", 1.4, {"sub": "net", "r": 80.0, "range": 300.0}],
	"tinhvu": ["tho-san", "ts_star", "muzzle_up", 1.6, {"dim": true}],
	# Pháp Sư
	"chain": ["phap-su", "bolt", "muzzle", 0.35, {}],
	"banglao": ["phap-su", "ice", "muzzle", 0.35, {}],
	"meteor": ["phap-su", "fire", "muzzle_up", 0.5, {}],
	"barrier": ["phap-su", "arcane", "buff", 6.0, {"dome": true}],
	"hoatuong": ["phap-su", "fire", "muzzle", 0.4, {}],
	"nova": ["phap-su", "ice", "nova", 0.8, {"r": 110.0, "spikes": 10, "root": true, "frost": true}],
	"muabang": ["phap-su", "ice", "muzzle_up", 0.4, {}],
	"causam": ["phap-su", "bolt", "muzzle", 0.4, {}],
	"thienhoa": ["phap-su", "arcane", "muzzle_up", 1.6, {"dim": true}],
	"thienloi": ["phap-su", "bolt", "muzzle_up", 0.6, {"dim": true}],
	"bangphong": ["phap-su", "ice", "nova", 0.9, {"r": 140.0, "spikes": 16, "root": true, "frost": true, "dim": true}],
	"trieuhoi": ["phap-su", "necro", "muzzle", 0.5, {}],
	"khidoc": ["phap-su", "necro", "muzzle", 0.4, {}],
	"nguhanh": ["phap-su", "arcane", "muzzle_up", 0.8, {}],
	# Hộ Vệ
	"khienchan": ["ho-ve", "hv_steel", "cone", 0.6, {"r": 90.0, "arc": 0.8, "shield": true, "stun": true}],
	"khieukhich": ["ho-ve", "hv", "nova", 0.8, {"r": 120.0, "implode": false, "taunt": true}],
	"laokhien": ["ho-ve", "hv_steel", "dash", 0.6, {"shield": true}],
	"khienthep": ["ho-ve", "hv_steel", "buff", 10.0, {"shields": 4}],
	"chandia": ["ho-ve", "hv_earth", "nova", 0.8, {"r": 100.0, "debris": true, "stun": true}],
	"phanthuan": ["ho-ve", "hv_steel", "muzzle", 0.35, {}],
	"phanquyet": ["ho-ve", "hv", "muzzle_up", 0.5, {}],
	"xungphong": ["ho-ve", "hv", "dash", 0.7, {"stun": true}],
	"thanhbatdiet": ["ho-ve", "hv", "buff", 8.0, {"dome": true, "shields": 6}],
	"thanhquang": ["ho-ve", "hv", "cone", 0.7, {"r": 120.0, "arc": 1.05, "heal": true}],
	"thanhvuc": ["ho-ve", "hv", "buff", 1.0, {}],
	"thietchuy": ["ho-ve", "hv_earth", "nova", 0.9, {"r": 120.0, "debris": true, "stun": true, "hammer": true, "cracks": true}],
	"thanhdong": ["ho-ve", "hv_steel", "nova", 0.9, {"r": 90.0, "dome": true}],
	"thienthuan": ["ho-ve", "hv", "point", 1.3, {"sub": "shield", "r": 120.0, "range": 110.0, "dim": true}],
	# Triệu Hồi Sư
	"soibong": ["trieu-hoi-su", "th", "muzzle", 0.5, {}],
	"linhtien": ["trieu-hoi-su", "th_teal", "muzzle", 0.35, {}],
	"tieuquy": ["trieu-hoi-su", "th", "muzzle", 0.5, {}],
	"lienket": ["trieu-hoi-su", "th_teal", "link", 8.0, {}],
	"thachquy": ["trieu-hoi-su", "hv_earth", "muzzle", 0.5, {}],
	"hoadieu": ["trieu-hoi-su", "th_dragon", "muzzle", 0.4, {}],
	"linhtran": ["trieu-hoi-su", "th", "muzzle", 0.4, {}],
	"linhung": ["trieu-hoi-su", "th_teal", "muzzle", 0.5, {}],
	"quandoan": ["trieu-hoi-su", "th", "muzzle_up", 1.0, {"dim": true}],
	"aulong": ["trieu-hoi-su", "th_dragon", "muzzle", 0.5, {}],
	"longhong": ["trieu-hoi-su", "th_dragon", "nova", 0.8, {"r": 120.0, "dragon": true}],
	"loidodang": ["trieu-hoi-su", "th_storm", "muzzle_up", 0.4, {}],
	"phongdodang": ["trieu-hoi-su", "th_wind", "muzzle_up", 0.4, {}],
	"kylan": ["trieu-hoi-su", "th_qilin", "muzzle_up", 1.0, {"dim": true}],
}

## Đạn theo kỹ năng: [hình, bảng màu, cỡ].
const SHOTS := {
	"wave": ["wave", "kk", 1.0], "phikiem": ["sword", "kk", 0.9], "thanhkiem": ["beam", "kk_holy", 1.5],
	"pierce": ["arrow", "ts", 1.3], "lanban": ["arrow", "ts", 1.0], "lienxa": ["arrow", "ts", 0.9], "tendoc": ["arrow", "ts_poison", 1.1],
	"phakhong": ["beam", "ts_star", 1.1], "tamlien": ["arrow", "ts_star", 1.3], "banglao": ["shard", "ice", 1.3],
	"phanthuan": ["disk", "hv_steel", 1.0], "linhtien": ["orb", "th_teal", 0.8], "hoadieu": ["bird", "th_dragon", 1.2],
}
## Vùng sk2.ice theo kỹ năng: [kiểu, bảng màu].
const ZONES := {
	"muabang": ["ice_rain", "ice"], "kiemvuc": ["swords", "kk_holy"], "khidoc": ["poison", "necro"], "thanhvuc": ["holy", "hv"],
	"linhtran": ["spirit", "th"], "thanhbatdiet": ["aura", "hv"],
}

## Trạng thái vẽ (theo world): dàn cảnh đang chạy, vật thể đã thấy (để phát hiện xuất hiện / biến mất).
static var casts: Array = []
static var _world = null
static var _seen_allies := {}
## Vật thể đang theo dõi để nổ khi biến mất: [vật thể, vị trí, bán kính, bảng màu, có đá văng]. Slam / cầu sấm là
## Dictionary đổi nội dung mỗi khung nên không làm khoá được — so tham chiếu bằng is_same.
static var _watch: Array = []
static var _boom: Array = []
static var last_id := ""
## Painter của khung hình hiện tại (world_view đặt mỗi lần vẽ) cho các view khác (skills2_view, classes2_view).
static var painter = null
## §9.8 cảm giác đánh trúng: lực va chạm đang chờ world_view xử lý (rung camera; ≥ 0,6 thì khựng đòn 45 ms).
static var shake := 0.0
## Lực va chạm theo kiểu dàn cảnh, bắn ở khung 5 (va chạm) của nhịp thiết kế.
const IMPACT := {"spin": 0.35, "nova": 0.55, "cone": 0.35, "dash": 0.3, "lientram": 0.3, "cleave": 1.0, "rain_self": 0.6}
const ULTS := ["vankiem", "thientien", "thienhoa", "thanhbatdiet", "quandoan", "nhatkiem", "tinhvu", "nguhanh", "thienthuan", "kylan"]
static var last_t := -99.0


## Khung (0..12) của dàn cảnh f tại thời điểm f.t: theo nhịp thiết kế (DESIGN_TIME) hoặc chia đều thời lượng SK.
static func frame_of(f) -> float:
	var kind: String = SK[f.id][2]
	if not DESIGN_TIME.has(kind):
		return float(f.t) / float(SK[f.id][3]) * 12.0
	var ms: float = float(f.t) * 1000.0
	for i in range(int(DESIGN_TIME[kind]), 12):
		if ms < DUR_MS[i]:
			return float(i) + ms / DUR_MS[i]
		ms -= DUR_MS[i]
	return 12.0


## FX-1 vừa vẽ một kỹ năng có vùng quanh thân / vụ nổ (trong 1,2 giây): world_view bỏ vòng xoay cũ và vòng nổ chung
## (`blasts`) để không chồng lên hình thiết kế.
static func owns_burst(world) -> bool:
	if last_id == "" or not active(last_id) or float(world.time) - last_t > 1.2:
		return false
	return SK[last_id][2] in ["spin", "nova", "cone", "orbit", "rain_self", "lientram", "dash", "cleave"]


## Cài đặt (Settings) — đọc trực tiếp như current_mode.
static func _setting(key: String, def):
	return preload("res://scripts/core/settings.gd").values.get(key, def)


static func soft() -> bool:
	return bool(_setting("fx_soft", false))


static func impact_shake(strength: float) -> void:
	if bool(_setting("fx_shake", true)):
		shake = maxf(shake, strength)


## world_view lấy lực rung đang chờ (rồi xoá).
static func take_shake() -> float:
	var s := shake
	shake = 0.0
	return s


static func set_mode(m: String) -> void:
	mode = m if m in ["", "auto", "fx1", "old"] else "auto"


static func current_mode() -> String:
	if mode != "":
		return mode
	return str(preload("res://scripts/core/settings.gd").values.get("skill_fx", "fx1"))


static func active(id: String) -> bool:
	var m := current_mode()
	if id == "" or not SK.has(id) or m == "old":
		return false
	if m == "fx1":
		return true
	return not (id in APPROVED) or id in REPLACE


static func palette(id: String) -> Array:
	return P[SK[id][1]] if SK.has(id) else P.kk


static func _reset(world) -> void:
	_world = world
	casts = []
	_seen_allies = {}
	_watch = []
	_boom = []
	last_id = ""
	tele_queue = []  # §9.12: vết cảnh báo của map cũ không hiện ở map mới
	_wind_heard = {}


## Gọi khi world_view nhận ra một lần thi triển (bước nhảy hồi chiêu). Trả true nếu FX-1 nhận vẽ kỹ năng này.
static func on_cast(world, sk: Dictionary) -> bool:
	if world != _world:
		_reset(world)
	var id := str(sk.get("id", ""))
	if not active(id):
		return false
	last_id = id
	last_t = float(world.time)
	casts.append({"id": id, "t": 0.0, "ang": float(world.player.facing), "start": world.player.pos, "path": [world.player.pos],
		"at": null})
	return true


static func tick(world, delta: float) -> void:
	if world != _world:
		_reset(world)
	_tele_audio(world)
	for f in casts:
		var before := frame_of(f)
		f.t += delta
		var kind: String = SK[f.id][2]
		if before < 5.0 and frame_of(f) >= 5.0 and (IMPACT.has(kind) or f.id in ULTS):
			var k: float = IMPACT.get(kind, 0.6)
			if f.id in ULTS:
				k = maxf(k, 0.8)
			elif kind == "nova" and float(SK[f.id][4].get("r", 0.0)) >= 120.0:
				k = 0.7
			impact_shake(k)
			if k >= 0.55 and world.has_method("_sfx"):
				world._sfx("explode")  # âm nổ đúng khung va chạm của hình (hàng đợi âm thanh sẵn có, main phát)
	casts = casts.filter(func(f): return frame_of(f) < 12.0)
	for b in _boom:
		b.t += delta
	_boom = _boom.filter(func(b): return b.t < 0.7)


## Điểm ngắm của kỹ năng đặt điểm: quái gần nhất trong tầm theo hướng nhìn, không có thì phía trước.
static func _aim(world, f, rng: float) -> Vector2:
	if f.at != null:
		return f.at
	var p: Vector2 = f.start
	var best := rng
	var at: Vector2 = p + Vector2.from_angle(f.ang) * rng * 0.55
	for e in world.enemies:
		if e.dead:
			continue
		var d: float = e.pos.distance_to(p)
		if d < best:
			best = d
			at = e.pos
	f.at = at
	return at


# ================================================================ vẽ chính

## Vẽ dàn cảnh thi triển + lớp phủ vật thể. pa.glow được node lớp cộng sáng vẽ sau.
static func draw(pa: Kit.Painter, world) -> void:
	if world != _world:
		_reset(world)
	_draw_summons(pa, world)
	for q in world.sk2.queue:
		draw_queue(pa, world, q, 0.7)
	_draw_vanish(pa, world)
	for f in casts:
		_draw_cast(pa, world, f)


static func _draw_cast(pa: Kit.Painter, world, f) -> void:
	var spec: Array = SK[f.id]
	var p: Array = P[spec[1]]
	var prm: Dictionary = spec[4]
	var fr: float = frame_of(f)
	var P0: Vector2 = world.player.pos
	var dir := Vector2.from_angle(f.ang)
	var hand: Vector2 = P0 + Vector2(0, -34) + dir * 16.0
	if prm.get("dim", false) and not soft():
		var k := Kit.seg(fr, 0.0, 12.0)
		pa.circle(P0, 900.0, Color(0.02, 0.02, 0.06, 0.32 * sin(clampf(k, 0.0, 1.0) * PI)))
	match spec[2]:
		"spin":
			_spin(pa, P0, fr, p, prm.r)
		"dash":
			_dash(pa, world, f, fr, p, prm)
		"muzzle":
			_charge(pa, hand, fr, p, 14.0, 3.0)
			if fr >= 3.5 and fr < 6.0:
				Kit.star(pa, hand + dir * 8.0, 16.0 * (1.0 if prm.get("big", false) else 0.7) * (1.0 - (fr - 3.5) / 2.5), 6, p, f.ang, 0.32, 1.0, 1)
			if f.id == "thanhkiem" and fr >= 4.0 and fr < 8.0:
				Kit.sword(pa, hand + dir * 14.0, f.ang, 44.0, p, 1.0, 1.6)
				if fr < 5.5:
					Kit.glow_dot(pa, hand, 50.0, p[2], 0.8)
			if prm.get("rings", false) and fr < 5.0:
				for k in 3:
					Kit.ring(pa, hand + dir * (10.0 + k * 9.0), 6.0 + k * 4.0 + fr * 2.0, 2.0, p, 0.8, 0.4)
		"muzzle_up":
			_charge(pa, hand, fr, p, 14.0, 3.0)
			var tu := Kit.seg(fr, 3.0, 7.0)
			if tu >= 0.0:
				Kit.streak(pa, hand, hand + Vector2(10, -120) * Kit.ease_out(tu), 8.0 * (1.0 - tu) + 2.0, p, 1.0 - tu * 0.5, 0.2)
			var tg := Kit.seg(fr, 0.0, 6.0)
			if tg >= 0.0:
				Kit.ring(pa, P0, 20.0 + 26.0 * Kit.ease_out(tg), 2.5, p, 0.8 * (1.0 - tg), 0.6)
		"buff":
			_buff(pa, world, f, fr, p, prm, P0)
		"nova":
			_nova(pa, P0, fr, p, prm, f)
		"orbit":
			_charge(pa, P0 + Vector2(0, -30), fr, p, 14.0, 1.0)
			for i in int(prm.n):
				var a: float = f.t * 6.5 + i * TAU / prm.n
				var q: Vector2 = P0 + Kit.gp(a) * float(prm.r)
				Kit.sword(pa, q + Vector2(0, -16), a + PI / 2.0, 30.0, p, 1.0)
				Kit.crescent(pa, P0 + Vector2(0, -16), prm.r, a - 0.9, a - 0.05, 7.0, p, 0.6, Kit.SQ, 0.65, 0.4)
			Kit.ring(pa, P0, prm.r + 10.0, 2.0, p, 0.5, 0.4)
		"rain_self":
			_rain(pa, P0, fr, p, prm.r, "sword", f.t)
		"cone":
			_cone(pa, P0, dir, f.ang, fr, p, prm)
		"lientram":
			_charge(pa, P0 + Vector2(0, -30), fr, p, 12.0, 2.0)
			var tgt: Vector2 = _aim(world, f, 160.0)
			for k in 3:
				var t3 := Kit.seg(fr, 3.0 + k * 2.4, 6.0 + k * 2.4)
				if t3 >= 0.0:
					var aa: Array = [[-2.4, -0.4], [0.6, 2.6], [-1.6, 1.2]][k]
					Kit.crescent(pa, tgt + Vector2(0, -24), 34.0 + k * 5.0, aa[0], aa[1], 16.0, p, 1.0 - t3 * 0.6)
			if fr >= 9.5:
				Kit.crescent(pa, tgt + Vector2(0, -26), 46.0, -2.8, -0.2, 9.0, P.kk_god, (12.0 - fr) / 2.5, 1.0, 0.65, 0.8)
		"cleave":
			_cleave(pa, P0, dir, f, fr, p, prm)
		"roll":
			var tr := Kit.seg(fr, 0.0, 5.0)
			if tr >= 0.0:
				Kit.crescent(pa, P0 + Vector2(0, -24), 30.0, f.ang + PI * 0.4, f.ang + PI * 0.4 + 4.2 * tr + 0.3, 9.0, p, 1.0 - tr * 0.4)
			var tw := Kit.seg(fr, 4.0, 12.0)
			if tw >= 0.0:
				for k in 2:
					var a2: float = f.t * 9.0 + k * PI
					Kit.crescent(pa, P0 + Vector2(0, 4), 28.0, a2, a2 + 1.6, 6.0, p, 0.7 * (1.0 - tw), 0.6, 0.65, 0.5)
		"rapid":
			var n: int = prm.n
			for k in n:
				var tk := Kit.seg(fr, 1.0 + k * 10.0 / n, 1.0 + k * 10.0 / n + 1.2)
				if tk >= 0.0:
					var pk: Array = [P.ts, P.ts_gold, P.ts_star][k % 3] if n == 3 else p
					Kit.star(pa, hand + dir * 10.0, (10.0 + (8.0 if n == 3 else 0.0)) * (1.0 - tk), 5, pk, f.ang + k, 0.35, 1.0, k)
		"toss":
			_charge(pa, hand, fr, p, 10.0, 2.0)
			if prm.has("ring"):
				var tt := Kit.seg(fr, 2.0, 8.0)
				if tt >= 0.0:
					for k in 5:
						var a3 := k * TAU / 5.0
						var q2: Vector2 = P0 + Kit.gp(a3) * float(prm.ring) * Kit.ease_out(tt)
						Kit.disc(pa, q2 + Vector2(0, -30.0 * sin(tt * PI)), 4.0, p, 1.0, 0.7)
		"point":
			_point(pa, world, f, fr, p, prm)
		"link":
			_link(pa, world, f, fr, p)


# ---------------------------------------------------------------- dàn cảnh thi triển

static func _charge(pa: Kit.Painter, c: Vector2, fr: float, p: Array, r: float, last: float) -> void:
	var t := Kit.seg(fr, 0.0, last)
	if t < 0.0:
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = 77
	for i in 10:
		var a := rng.randf_range(0.0, TAU)
		var rr := r * 2.4 * (1.0 - Kit.ease_in(t) * 0.85) * rng.randf_range(0.7, 1.1)
		var q := c + Vector2(cos(a), sin(a) * 0.8) * rr
		pa.line(q, q + Vector2(cos(a), sin(a) * 0.8) * 6.0, Kit._a(p[1], 0.85), 1.5)
	Kit.glow_dot(pa, c, r * (0.6 + t * 0.8), p[2], 0.6 + t * 0.4)
	Kit.disc(pa, c, 2.0 + t * 4.0, p, 1.0, 0.6)


static func impact(pa: Kit.Painter, c: Vector2, p: Array, t: float, r := 16.0, seed := 0, smoke := true) -> void:
	if t < 0.0 or t > 1.0:
		return
	if t < 0.35:
		Kit.star(pa, c, r * (0.5 + 0.7 * Kit.ease_out(t / 0.35)), 8, p, seed * 0.7, 0.32, 1.0, seed)
	elif t < 0.55:
		Kit.ring(pa, c, r * 1.4, 2.0, p, 0.8, 0.6)
	Kit.sparks(pa, c, t, 7, r * 1.8, p, seed + 3, false, 0.6)
	if smoke and t > 0.3:
		Kit.smoke(pa, c + Vector2(0, 8), (t - 0.3) / 0.7, 3, r * 0.45, DUST, seed)


## Xoáy Kiếm — bám bản thiết kế a_spin (skill_fx_design.py): bán kính thiết kế 36 → tầm gameplay r, mọi độ dày /
## khoảng cách nhân cùng hệ số k; mặt đất nén SQ; 3 trăng khuyết xoay 1,6 vòng nở 0,55 → 1; vòng đất mờ khi tan.
static func _spin(pa: Kit.Painter, c0: Vector2, fr: float, p: Array, r: float) -> void:
	var k := r / 36.0
	var c := c0 + Vector2(4, -8) * 1.7
	_charge(pa, c0 + Vector2(6, -18) * 1.7, fr, p, 8.0 * 1.7, 3.0)
	if fr < 4.0:
		Kit.crescent(pa, c, 12.0 * 1.7, deg_to_rad(150.0), deg_to_rad(150.0 + 70.0 * fr), (3.0 + fr) * 1.7, p, 1.0, Kit.SQ * 1.4, 0.65, 0.5)
	var t := Kit.seg(fr, 4.0, 9.0)
	if t >= 0.0:
		var base := t * 1.6 * TAU
		var rr := r * (0.55 + 0.45 * Kit.ease_out(t * 1.6))
		for b in 3:
			var a := base + b * TAU / 3.0
			Kit.crescent(pa, c, rr, a, a + 1.6, 9.0 * k * (1.0 - t * 0.5), p, 1.0 - t * 0.3, Kit.SQ)
		Kit.ring(pa, c + Vector2(0, 6) * 1.7, rr, 1.4 * k, p, 150.0 / 255.0)
	var tr := Kit.seg(fr, 8.0, 11.0)
	if tr >= 0.0 and tr < 1.0:
		Kit.ring(pa, c + Vector2(0, 6) * 1.7, r * (0.25 + 0.75 * Kit.ease_out(tr)), 2.2 * k * (1.0 - tr * 0.6), p, 1.0 - tr * 0.5)
	Kit.sparks(pa, c, Kit.seg(fr, 5.0, 11.0), 14, r * 1.2, p, 2, false, 0.0, 1.5 * 1.7)
	Kit.smoke(pa, c + Vector2(0, 8) * 1.7, Kit.seg(fr, 7.0, 11.0), 6, 4.0 * 1.7, DUST, 1, r * 0.7, 10.0 * 1.7)


static func _dash(pa: Kit.Painter, world, f, fr: float, p: Array, prm: Dictionary) -> void:
	var pos: Vector2 = world.player.pos
	var path: Array = f.path
	if pos.distance_to(path[-1]) > 6.0:
		path.append(pos)
	_charge(pa, Vector2(f.start) + Vector2(0, -26), fr, p, 12.0, 2.0)
	var fade := clampf((12.0 - fr) / 6.0, 0.0, 1.0)
	for i in range(1, path.size()):
		var a: Vector2 = path[i - 1]
		var b: Vector2 = path[i]
		Kit.streak(pa, a + Vector2(0, -22), b + Vector2(0, -22), 18.0, p, fade, 0.5)
		Kit.streak(pa, a + Vector2(0, -8), b + Vector2(0, -8), 7.0, p, fade * 0.7, 0.5, 0.4)
	if pa.ci and fr < 7.0 and path.size() > 1:
		for k in 3:
			var q: Vector2 = Vector2(path[0]).lerp(path[-1], (k + 1) / 4.0)
			SpriteLib.draw_hero(pa.ci, world.profile.class_id, world.profile.look, "run", k % 4, q + Vector2(0, 8),
				cos(f.ang) < 0.0, Color(p[1], 0.35 * fade))
	if prm.get("shield", false) and fr < 7.0:
		Kit.shield(pa, pos + Vector2.from_angle(f.ang) * 26.0 + Vector2(0, -28), 13.0, p, 1.0)
	if prm.get("x", false) and fr >= 4.0 and fr < 9.0:
		var c: Vector2 = pos + Vector2.from_angle(f.ang) * 30.0 + Vector2(0, -26)
		Kit.crescent(pa, c, 22.0, -2.4, -0.8, 9.0, p, (9.0 - fr) / 5.0)
		Kit.crescent(pa, c, 22.0, 0.8, 2.4, 9.0, p, (9.0 - fr) / 5.0)
	if prm.get("stun", false):
		impact(pa, pos + Vector2.from_angle(f.ang) * 30.0 + Vector2(0, -16), p, Kit.seg(fr, 5.0, 10.0), 26.0, 4)


static func _buff(pa: Kit.Painter, world, f, fr: float, p: Array, prm: Dictionary, c: Vector2) -> void:
	var t0 := Kit.seg(f.t, 0.0, 0.5)
	if t0 >= 0.0:
		Kit.decal(pa, c, 20.0 + 30.0 * Kit.ease_out(t0), p, f.t * 3.0, 6, 0.9)
	var tp := Kit.seg(f.t, 0.4, 0.75)
	if tp >= 0.0:
		Kit.pillar(pa, c + Vector2(0, 6), 34.0 * (1.0 - tp * 0.6), 120.0, p, 1.0 - tp)
	if f.t < 0.5:
		return
	var dur: float = SK[f.id][3]
	var fade := clampf((dur - f.t) / 0.5, 0.0, 1.0) * minf(1.0, (f.t - 0.5) * 4.0)
	Kit.ring(pa, c + Vector2(0, 8), 30.0, 2.0, p, 0.55 * fade, 0.5)
	Kit.glow_dot(pa, c + Vector2(0, -26), 30.0, p[2], 0.35 * fade)
	if not prm.get("dome", false):
		Kit.sparks(pa, c + Vector2(0, 6), fposmod(f.t * 1.2, 1.0), 8, 46.0, p, int(f.t * 1.2), true)
	for k in int(prm.get("orbit", 0)):
		var a: float = f.t * 2.4 + k * PI
		Kit.sword(pa, c + Vector2(cos(a) * 28.0, -30.0 + sin(a) * 10.0), -PI / 2.0, 22.0, p, fade, 0.7)
	for k in int(prm.get("shields", 0)):
		var a2: float = f.t * 1.6 + k * TAU / prm.shields
		var rs := 54.0 if prm.get("dome", false) else 34.0
		Kit.shield(pa, c + Vector2(cos(a2) * rs, -24.0 + sin(a2) * rs * 0.4), 7.0, p, fade, 0.6)
	if prm.get("dome", false):
		var crack := 0
		if f.id == "barrier":
			crack = clampi(int((f.t - 2.0) / 1.0), 0, 4)
		Kit.dome(pa, c + Vector2(0, 10), 44.0 if f.id == "barrier" else 58.0, p, minf(1.0, (f.t - 0.4) * 3.0), crack, fade)
	var top: Vector2 = c + Vector2(0, -98 - sin(f.t * 3.0) * 3.0)
	match str(prm.get("glyph", "")):
		"sword":
			Kit.sword(pa, top, -PI / 2.0, 30.0, p, fade, 1.2)
		"eye":
			Kit.glyph(pa, top, "eye", 12.0, p, fade)
			Kit.crescent(pa, top + Vector2(-8, 4), 20.0, 3.3, 4.5, 6.0, p, fade, 1.0, 0.65, 0.6)
			Kit.crescent(pa, top + Vector2(8, 4), 20.0, 4.9, 6.1, 6.0, p, fade, 1.0, 0.65, 0.6)


static func _nova(pa: Kit.Painter, c: Vector2, fr: float, p: Array, prm: Dictionary, f) -> void:
	var r: float = prm.r
	var cc := c + Vector2(0, -12)
	if prm.get("implode", true) and fr < 4.0:
		Kit.ring(pa, c, r * (1.0 - fr / 4.0 * 0.8), 2.5, p, 0.6 + fr * 0.1)
		_charge(pa, cc, fr, p, 20.0, 4.0)
	if prm.get("hammer", false) and fr < 5.0:
		Kit.hammer(pa, c + Vector2(14, -60 + fr * 12.0), -PI / 2.0 + fr * 0.5, 48.0, P.hv_steel, 1.0, 0.6 + fr * 0.2)
	if prm.get("leech", false) and fr < 4.0:
		Kit.sparks(pa, c + Vector2(0, -36), fr / 4.0, 8, 26.0, p, 11, true)
	if fr >= 4.0 and fr < 5.0:
		Kit.star(pa, cc, r * 0.55, 12, p, 0.0, 0.32, 1.0, 1, 1.8)
		Kit.glow_dot(pa, cc, r * 1.8, p[0], 1.2)  # chớp sáng khung phát như bản thiết kế (S.flash)
	var t := Kit.seg(fr, 4.0, 10.0)
	if t >= 0.0:
		Kit.ring(pa, c, r * (0.3 + 0.7 * Kit.ease_out(t)), 7.0 * (1.0 - t) + 2.0, p, 1.0 - t * 0.4, 1.2)
		if t < 0.45:
			Kit.disc(pa, cc, r * 0.3 * (1.0 - t), p, 1.0, 1.4)
	var n_sp: int = prm.get("spikes", 0)
	var ts := Kit.seg(fr, 5.0, 12.0)
	if n_sp > 0 and ts >= 0.0:
		for k in n_sp:
			var a := k * TAU / n_sp + 0.2
			var b := c + Kit.gp(a) * r * 0.75
			var h := 30.0 * (Kit.ease_out(minf(1.0, ts * 3.0)) if ts < 0.75 else (1.0 - ts) * 4.0)
			if h > 2.0:
				Kit.poly(pa, PackedVector2Array([b + Vector2(-6, 0), b + Vector2(2, -h), b + Vector2(6, 0)]), p, 1.0, 0.7)
	var n_sw: int = prm.get("swords", 0)
	if n_sw > 0 and t >= 0.0:
		for k in n_sw:
			var a2 := k * TAU / n_sw
			Kit.sword(pa, cc + Kit.gp(a2) * (20.0 + r * 0.8 * Kit.ease_out(t)), a2, 22.0, p, 1.0 - t * 0.6, 0.5)
	if prm.get("debris", false):
		Kit.sparks(pa, c, Kit.seg(fr, 4.0, 12.0), 14, r, [p[0], Color(0.75, 0.6, 0.43), Color(0.5, 0.36, 0.24), Color(0.24, 0.16, 0.12)], 4, false, 1.0, 4.0)
	if prm.get("cracks", false) and t >= 0.0:
		for k in 7:
			var a3 := k * TAU / 7.0 + 0.3
			var L := r * Kit.ease_out(minf(1.0, t * 2.0))
			var pts := PackedVector2Array([c])
			for j in range(1, 5):
				pts.append(c + Kit.gp(a3 + (j % 2) * 0.15) * L * j / 4.0)
			pa.polyline(pts, Kit._a(p[3], 1.0 - t * 0.5), 4.0)
			pa.polyline(pts, Kit._a(p[1], 0.8 - t * 0.5), 1.8)
	if prm.get("dome", false) and fr >= 6.0:
		Kit.dome(pa, c + Vector2(0, 10), r * 0.55, p, minf(1.0, (fr - 6.0) / 2.0), 0, 0.7 * clampf((12.0 - fr) / 3.0, 0.0, 1.0))
	if prm.get("dragon", false):
		for a in (_world.allies if _world else []):
			if not a.dead and a.kind == "summon" and str(a.monster) == "au-long":
				for k in 3:
					var tk := Kit.seg(fr, 5.0 + k, 10.0 + k)
					if tk >= 0.0:
						Kit.ring(pa, a.pos, 20.0 + 70.0 * Kit.ease_out(tk), 3.0, p, 1.0 - tk)
	if prm.get("taunt", false) and fr >= 5.0 and _world:
		for e in _world.enemies:
			if not e.dead and e.pos.distance_to(c) < r * 1.6:
				Kit.glyph(pa, e.pos + Vector2(0, -e.radius * 2.6), "eye", 7.0, P.kk, clampf((12.0 - fr) / 3.0, 0.0, 1.0))
	Kit.sparks(pa, cc, Kit.seg(fr, 4.0, 10.0), 16, r * 0.9, p, 1)
	Kit.smoke(pa, c, Kit.seg(fr, 6.0, 12.0), 8, 10.0, FROST if prm.get("frost", false) else DUST, 2, r * 0.8, 8.0)
	if prm.get("leech", false):
		var tl := Kit.seg(fr, 7.0, 12.0)
		if tl >= 0.0 and _world:
			var k2 := 0
			for e in _world.enemies:
				if not e.dead and e.pos.distance_to(c) < r and k2 < 5:
					Kit.orb(pa, (e.pos + Vector2(0, -20)).lerp(c + Vector2(0, -34), Kit.ease_in(tl)), 5.0, p, 1.0, 0.8)
					k2 += 1


static func _cone(pa: Kit.Painter, c: Vector2, dir: Vector2, ang: float, fr: float, p: Array, prm: Dictionary) -> void:
	_charge(pa, c + Vector2(0, -28) + dir * 18.0, fr, p, 14.0, 3.0)
	var t := Kit.seg(fr, 4.0, 9.0)
	if t >= 0.0:
		var r: float = float(prm.r) * (0.35 + 0.65 * Kit.ease_out(t))
		Kit.crescent(pa, c + Vector2(0, -16), r, ang - prm.arc, ang + prm.arc, 30.0 * (1.0 - t) + 4.0, p, 1.0 - t * 0.5, 0.7, 0.5)
	if prm.get("shield", false) and fr >= 3.0 and fr < 7.0:
		Kit.shield(pa, c + dir * (28.0 + (fr - 3.0) * 10.0) + Vector2(0, -28), 14.0, p, 1.0)
	if prm.get("heal", false):
		Kit.sparks(pa, c + Vector2(0, -10), Kit.seg(fr, 6.0, 12.0), 10, 40.0, P.heal, 2, true)


static func _cleave(pa: Kit.Painter, c: Vector2, dir: Vector2, f, fr: float, p: Array, prm: Dictionary) -> void:
	var ch: float = prm.charge / SK[f.id][3] * 12.0
	var tip: Vector2 = c + Vector2(0, -34) + dir * 20.0
	if fr < ch:
		var g := fr / ch
		_charge(pa, tip, g * 3.0, p, 24.0, 3.0)
		Kit.sword(pa, tip + Vector2(0, -10 - g * 10.0), -PI / 2.0 + 0.3, 30.0 + g * 20.0, p, 1.0, 0.6 + g)
		return
	var t := (fr - ch) / (12.0 - ch)
	var w := 40.0 * (1.0 - Kit.ease_in(t))
	var L: float = prm.len
	if w > 2.0:
		Kit.streak(pa, c + Vector2(0, -20) - dir * 20.0, c + Vector2(0, -20) + dir * L, w, p, 1.0, 1.0)
	for k in 6:
		var appear := k / 6.0 * 0.35
		if t < appear:
			break
		var life := clampf((t - appear) / 0.65, 0.0, 1.0)
		Kit.crescent(pa, c + Vector2(0, -20) + dir * (50.0 + k * L / 6.0), 22.0, f.ang - 1.0, f.ang + 1.0, 12.0, p, 1.0 - life * life)
	Kit.sparks(pa, c + dir * L * 0.5, t, 20, L * 0.5, p, 3)


static func _rain(pa: Kit.Painter, center: Vector2, fr: float, p: Array, r: float, obj: String, time: float) -> void:
	Kit.decal(pa, center, r * (0.6 + 0.4 * Kit.ease_out(minf(1.0, fr / 3.0))), p, time * 0.6, 10, 0.7 * clampf((12.0 - fr) / 2.0, 0.0, 1.0))
	if fr < 2.0 or fr > 11.0:
		return
	for i in 7:
		var u := fposmod(time * 2.2 + i * 0.37, 1.0)
		var h := int(time * 2.2 + i * 0.37) * 31 + i * 17
		var a := float(h % 360) * PI / 180.0
		var rr := r * (0.15 + 0.8 * float((h * 7) % 100) / 100.0)
		var g: Vector2 = center + Kit.gp(a) * rr
		if u < 0.6:
			var k := u / 0.6
			var top: Vector2 = g + Vector2(-20.0 * (1.0 - k), -140.0 * (1.0 - k))
			match obj:
				"sword":
					Kit.sword(pa, top, PI / 2.0, 30.0, p, 1.0, 0.8)
				"arrow":
					Kit.arrow(pa, top, PI / 2.0 + 0.15, 16.0, p, 1.0, 20.0)
				"shard":
					Kit.shard(pa, top, PI / 2.0, 20.0, p)
				"star":
					Kit.star(pa, top, 8.0, 4, p, time * 4.0, 0.35, 1.0, i, 1.2)
					Kit.streak(pa, top + Vector2(-16, -30), top, 4.0, p, 0.7)
		else:
			impact(pa, g, p, (u - 0.6) / 0.4, 14.0, i, (u - 0.6) > 0.1)


static func _point(pa: Kit.Painter, world, f, fr: float, p: Array, prm: Dictionary) -> void:
	var at: Vector2 = _aim(world, f, prm.range)
	var r: float = prm.r
	var hand: Vector2 = world.player.pos + Vector2(0, -34) + Vector2.from_angle(f.ang) * 16.0
	_charge(pa, hand, fr, p, 14.0, 3.0)
	match str(prm.sub):
		"hammer", "shield":
			_drop(pa, at, fr, p, r, prm.sub)
		"net":
			var t := Kit.seg(fr, 1.0, 5.0)
			if t >= 0.0 and t < 1.0:
				var q: Vector2 = hand.lerp(at, Kit.ease_out(t)) + Vector2(0, -80.0 * sin(t * PI))
				_net(pa, q, 8.0 + 50.0 * t, p, 0.9)
			if fr >= 5.0:
				var fade := clampf((12.0 - fr) / 2.0, 0.0, 1.0)
				Kit.decal(pa, at, r, p, 0.0, 12, 0.8 * fade)
				_net(pa, at, r, p, 0.65 * fade)
				impact(pa, at, p, Kit.seg(fr, 5.0, 9.0), 24.0, 2)


static func _drop(pa: Kit.Painter, at: Vector2, fr: float, p: Array, r: float, obj: String) -> void:
	if fr <= 5.0:
		Kit.decal(pa, at, r * (0.5 + 0.5 * Kit.ease_out(minf(1.0, fr / 4.0))), p, fr * 0.3, 10, 0.75)
	var tf := Kit.seg(fr, 2.0, 5.0)
	if tf >= 0.0 and tf < 1.0:
		var e := Kit.ease_in(tf)
		var top: Vector2 = at + Vector2(0, -260.0 * (1.0 - e) - 30.0)
		Kit.pillar(pa, at, 22.0, 260.0 * (1.0 - e) + 30.0, p, 0.5, 0.8)
		if obj == "hammer":
			Kit.hammer(pa, top, PI / 2.0, 52.0, p, 1.0, 1.4)
		else:
			Kit.shield(pa, top, 24.0, p, 1.0, 1.6)
	var ti := Kit.seg(fr, 5.0, 12.0)
	if ti >= 0.0:
		Kit.ring(pa, at, r * (0.35 + 0.9 * Kit.ease_out(ti)), 8.0 * (1.0 - ti) + 2.0, p, 1.0 - ti * 0.6)
		if ti < 0.4:
			Kit.star(pa, at + Vector2(0, -16), r * 0.8 * (1.0 - ti), 12, p, 0.0, 0.32, 1.0, 3, 1.8, 0.75)
		if obj == "shield" and ti > 0.15:
			Kit.shield(pa, at + Vector2(0, -32), 22.0, p, 1.0 - ti * 0.5, 0.8)
			Kit.dome(pa, at + Vector2(0, 10), r * 0.7, p, 1.0, 0, 0.6 * (1.0 - ti * 0.6))
		if obj == "hammer" and ti < 0.6:
			Kit.hammer(pa, at + Vector2(4, -36), PI / 2.0 + 0.1, 52.0, p, 1.0 - ti, 0.8)
		Kit.sparks(pa, at + Vector2(0, -8), ti, 16, r, [p[0], Color(0.75, 0.6, 0.43), Color(0.5, 0.36, 0.24), Color(0.24, 0.16, 0.12)], 9, false, 1.2, 4.0)
		Kit.smoke(pa, at, ti, 8, 12.0, DUST, 5, r * 0.8, 16.0)


static func _net(pa: Kit.Painter, c: Vector2, s: float, p: Array, alpha: float) -> void:
	for k in range(-3, 4):
		var y := c.y + k * s / 3.5
		pa.line(Vector2(c.x - s, y), Vector2(c.x + s, y), Kit._a(p[1], alpha), 1.5)
		var x := c.x + k * s / 3.5
		pa.line(Vector2(x, c.y - s), Vector2(x, c.y + s), Kit._a(p[1], alpha), 1.5)
	pa.gcircle(c, s, Kit._a(p[2], 0.12 * alpha))


static func _link(pa: Kit.Painter, world, f, fr: float, p: Array) -> void:
	var c: Vector2 = world.player.pos + Vector2(0, -30)
	if fr < 4.0:
		_charge(pa, c, fr, p, 12.0, 3.0)
	var dur: float = SK[f.id][3]
	var fade := clampf((dur - f.t) / 0.6, 0.0, 1.0)
	for a in world.allies:
		if a.dead or a.kind != "summon":
			continue
		var b: Vector2 = a.pos + Vector2(0, -12)
		var pts := PackedVector2Array()
		for k in 11:
			var q := c.lerp(b, k / 10.0)
			pts.append(q + (b - c).orthogonal().normalized() * sin(k * 1.2 + f.t * 8.0) * 5.0)
		pa.gline(pts, 10.0, Kit._a(p[2], 0.3 * fade))
		pa.polyline(pts, Kit._a(p[2], fade), 3.5)
		pa.polyline(pts, Kit._a(p[0], fade), 1.5)
		Kit.disc(pa, pts[int(fposmod(f.t * 14.0, 10.0))], 4.0, p, fade, 1.0)
		Kit.ring(pa, a.pos + Vector2(0, 6), 18.0, 2.0, p, 0.7 * fade, 0.5)


# ---------------------------------------------------------------- lớp phủ vật thể gameplay

## Đạn kỹ năng. Trả true nếu đã vẽ (world_view bỏ qua hình cũ).
static func draw_shot(pa: Kit.Painter, s) -> bool:
	var id := str(s.skill)
	if not SHOTS.has(id) or not active(id):
		return false
	var spec: Array = SHOTS[id]
	var p: Array = P[spec[1]]
	var k: float = spec[2]
	var u: Vector2 = s.vel.normalized()
	var ang: float = s.vel.angle()
	var c: Vector2 = s.pos
	match spec[0]:
		"wave":
			Kit.crescent(pa, c - u * 30.0 * k, 30.0 * k, ang - 1.15, ang + 1.15, 14.0 * k, p, 1.0, 1.0, 0.5)
		"sword":
			Kit.sword(pa, c, ang, 36.0 * k, p)
			Kit.streak(pa, c - u * 70.0, c - u * 14.0, 6.0 * k, p, 0.7, 0.0, 0.5)
		"beam":
			Kit.streak(pa, c - u * 90.0 * k, c, 16.0 * k, p, 1.0, 0.3)
			Kit.star(pa, c, 12.0 * k, 6, p, ang, 0.3, 1.0, 1)
		"arrow":
			Kit.arrow(pa, c, ang, 16.0 * k, p, 1.0, 70.0 * k)
		"shard":
			Kit.shard(pa, c, ang, 24.0 * k, p)
			Kit.streak(pa, c - u * 70.0, c - u * 10.0, 6.0 * k, p, 0.6, 0.0, 0.5)
		"orb":
			Kit.orb(pa, c, 8.0 * k, p)
			Kit.streak(pa, c - u * 40.0, c, 7.0 * k, p, 0.6, 0.0, 0.4)
		"disk":
			Kit.disc(pa, c, 13.0 * k, p, 1.0, 1.0)
			var spin: float = float(s.ttl) * 20.0
			Kit.crescent(pa, c, 17.0 * k, spin, spin + 2.2, 5.0, p, 1.0, 1.0, 0.65, 0.6)
		"bird":
			var flap := 0.5 if fposmod(float(s.ttl) * 10.0, 2.0) < 1.0 else -0.2
			Kit.orb(pa, c, 9.0 * k, p)
			Kit.crescent(pa, c - u * 8.0 + u.orthogonal() * 10.0, 22.0 * k, ang + 2.0 + flap, ang + 2.9 + flap, 9.0, p, 1.0, 1.0, 0.65, 0.8)
			Kit.crescent(pa, c - u * 8.0 - u.orthogonal() * 10.0, 22.0 * k, ang - 2.9 - flap, ang - 2.0 - flap, 9.0, p, 1.0, 1.0, 0.65, 0.8)
			Kit.streak(pa, c - u * 60.0, c - u * 8.0, 10.0, P.fire, 0.6, 0.0, 0.6)
	return true


## Tia sét (Sét Chuỗi, Thiên Lôi, Cầu Sấm, Lôi Đồ Đằng, Tên Nảy). Bolt không ghi kỹ năng thì lấy kỹ năng vừa thi triển.
static func draw_bolt(pa: Kit.Painter, world, b) -> bool:
	var id := str(b.skill)
	if id == "":
		if last_id == "" or float(world.time) - last_t > 12.0:
			return false
		id = last_id
	if not active(id):
		return false
	var p: Array = P.bolt if id == "thienhoa" else palette(id)
	if not (id in ["chain", "thienloi", "causam", "loidodang", "tennay", "thienhoa"]):
		p = P.bolt if SK[id][0] == "phap-su" else (P.th_storm if SK[id][0] == "trieu-hoi-su" else p)
	var a: float = clampf(b.ttl / 0.3, 0.0, 1.0)
	for i in b.points.size() - 1:
		var p0: Vector2 = b.points[i]
		var p1: Vector2 = b.points[i + 1]
		if id == "thienloi":
			p0 = p1 + Vector2(10, -280)
		if id == "tennay":
			Kit.streak(pa, p0, p1, 4.0, p, a, 0.3, 0.6)
			Kit.arrow(pa, p1, (p1 - p0).angle(), 14.0, p, a)
		else:
			Kit.bolt(pa, p0, p1, p, int(world.time * 20.0) + i, 5.0, a)
		Kit.star(pa, p1 + Vector2(0, -6), 14.0 * a, 6, p, i, 0.3, a, i)
	return true


## Mưa tên (Vũ Tiễn, Thiên Tiễn Vũ).
static func draw_rain(pa: Kit.Painter, world, z) -> bool:
	var id := str(z.skill)
	if not active(id):
		return false
	_rain(pa, z.pos, 6.0, palette(id), z.radius, "arrow", float(world.time))
	return true


## Thiên Thạch (và các kỹ năng gameplay dùng Meteor): vòng rune → vật thể rơi; nổ khi Meteor biến mất (_draw_vanish).
static func draw_meteor(pa: Kit.Painter, world, m) -> bool:
	var id := str(m.skill)
	if not active(id):
		return false
	var p: Array = P.fire
	var k: float = clampf(1.0 - float(m.timer) / 0.8, 0.0, 1.0)
	Kit.decal(pa, m.pos, m.radius * (0.5 + 0.5 * Kit.ease_out(k)), p, float(world.time) * 1.5, 10, 0.85)
	var e := Kit.ease_in(k)
	var rock: Vector2 = m.pos + Vector2(-90, -260) * (1.0 - e)
	Kit.streak(pa, rock + Vector2(-50, -130), rock, 24.0, p, 1.0, 0.15)
	Kit.disc(pa, rock, 16.0, p, 1.0, 1.6)
	_track(m, m.pos, m.radius, P.fire, true)
	return true


## Vùng sk2.ice có kỹ năng FX-1 (Mưa Băng, Khí Độc, Thánh Vực, Linh Trận, Kiếm Vực).
static func draw_zone(pa: Kit.Painter, world, z) -> bool:
	var id := str(z.get("skill", ""))
	if not ZONES.has(id) or not active(id):
		return false
	var spec: Array = ZONES[id]
	var p: Array = P[spec[1]]
	var t: float = world.time
	var c: Vector2 = z.pos
	var r: float = z.r
	if spec[0] == "aura":  # Thành Bất Diệt: vòm + khiên do dàn cảnh buff vẽ; vùng chỉ còn vòng vàng mảnh trên đất
		Kit.ring(pa, c, r, 2.0, p, 0.45, 0.4)
		return true
	Kit.decal(pa, c, r, p, t * 0.4, 12, 0.7, spec[0] != "ice_rain")
	match spec[0]:
		"ice_rain":
			_rain(pa, c, 6.0, p, r, "shard", t)
		"poison":
			for k in 7:
				var a := k * TAU / 7.0 + t * 0.6
				Kit.disc(pa, c + Kit.gp(a) * r * 0.55 + Vector2(0, -6.0), 16.0 + 4.0 * sin(t * 3.0 + k), p, 0.45, 0.5)
			Kit.sparks(pa, c, fposmod(t, 1.0), 10, r * 0.6, p, int(t), true, 0.0, 3.0)
		"holy":
			for k in 6:
				var a := k * TAU / 6.0 + t * 1.2
				Kit.pillar(pa, c + Kit.gp(a) * r * 0.7, 9.0, 44.0 + 12.0 * sin(t * 4.0 + k), p, 0.7, 0.8)
			Kit.sparks(pa, c, fposmod(t * 1.3, 1.0), 10, r * 0.7, P.heal, int(t * 1.3), true)
		"spirit":
			Kit.ring(pa, c, r * 0.5, 2.0, p, 0.7, 0.4)
			for k in 6:
				var a := t * 1.8 + k * TAU / 6.0
				Kit.disc(pa, c + Kit.gp(a) * r * 0.6 + Vector2(0, -8), 5.0, p, 1.0, 0.8)
			Kit.sparks(pa, c, fposmod(t, 1.0), 8, r * 0.6, p, int(t), true)
		"swords":
			for k in 8:
				var a := k * TAU / 8.0 + t * 0.6
				Kit.sword(pa, c + Kit.gp(a) * r * 0.9 + Vector2(0, -14), PI / 2.0, 26.0, p, 0.9, 0.6)
			var fall := 1.0 - clampf(float(z.timer) / float(z.get("gap", 0.5)), 0.0, 1.0)
			var h := int(z.ticks) * 47 + 13
			var at: Vector2 = c + Kit.gp(h * 0.7) * r * (0.25 + float(h % 50) / 100.0)
			Kit.sword(pa, at + Vector2(0, -100.0 * (1.0 - fall) - 14.0), PI / 2.0, 32.0, p, 0.5 + 0.5 * fall)
	return true


## Hoả Tường: 9 ngọn lửa dao động dọc tường + tàn lửa.
static func draw_wall(pa: Kit.Painter, world, wl) -> bool:
	if not active(str(wl.get("skill", "hoatuong"))):
		return false
	var p: Array = P.fire
	var t: float = world.time
	var a: float = clampf(float(wl.ttl) * 2.0, 0.0, 1.0)
	var d: Vector2 = wl.b - wl.a
	# dải than hồng dọc chân tường (đọc được hướng tường kể cả khi tường dựng dọc màn hình)
	Kit.streak(pa, wl.a, wl.b, 16.0, p, 0.55 * a, 1.0, 0.8)
	var depth := absf(d.normalized().y)  # tường dọc màn hình → lửa so le + nhỏ dần về phía xa (trên)
	var order: Array = []
	for k in 9:
		order.append(k)
	if d.y > 0.0:
		order.reverse()
	for k in order:
		var q: Vector2 = wl.a + d * (k + 0.5) / 9.0 + Vector2((9.0 if k % 2 else -9.0) * depth, 0)
		var far := 1.0 - 0.35 * depth * (1.0 - (q.y - minf(wl.a.y, wl.b.y)) / maxf(1.0, absf(d.y)))
		var side := Vector2(11, 0) * far
		var h := (34.0 + 16.0 * absf(sin(t * 7.0 + k * 1.7))) * far
		Kit.poly(pa, PackedVector2Array([q - side, q - side * 0.4 + Vector2(0, -h * 0.7), q + Vector2(0, -h), q + side * 0.6 + Vector2(0, -h * 0.6), q + side]), p, a, 1.0)
	Kit.sparks(pa, (wl.a + wl.b) / 2.0 + Vector2(0, -20), fposmod(t * 1.5, 1.0), 10, d.length() * 0.4, p, int(t * 1.5), true)
	return true


## Cầu Sấm: cầu điện bay chậm + vòng tầm phóng sét; nổ khi biến mất (_draw_vanish).
static func draw_orb(pa: Kit.Painter, world, o) -> bool:
	if not active(str(o.get("skill", "causam"))):
		return false
	var p: Array = P.bolt
	var c: Vector2 = o.pos
	Kit.orb(pa, c + Vector2(0, -20), 13.0 + 2.0 * sin(float(world.time) * 18.0), p)
	Kit.crescent(pa, c + Vector2(0, -20), 20.0, float(world.time) * 9.0, float(world.time) * 9.0 + 2.0, 4.0, p, 0.8, 1.0, 0.65, 0.5)
	Kit.ring(pa, c, 22.0, 2.0, p, 0.5, 0.3)
	_track(o, c, 70.0, P.bolt, false)
	return true


## Đồ Đằng (Lôi / Phong): cột totem + cầu sấm / trăng khuyết gió + vùng.
static func draw_totem(pa: Kit.Painter, world, tm) -> bool:
	var id := "loidodang" if str(tm.kind) == "loi" else "phongdodang"
	if not active(id):
		return false
	var p: Array = palette(id)
	var t: float = world.time
	var c: Vector2 = tm.pos
	var r := 150.0 if id == "loidodang" else 100.0
	Kit.decal(pa, c, r, p, t * 0.5, 8, 0.55)
	pa.poly(PackedVector2Array([c + Vector2(-8, 0), c + Vector2(-7, -52), c + Vector2(7, -52), c + Vector2(8, 0)]), p[3])
	pa.poly(PackedVector2Array([c + Vector2(-5, -2), c + Vector2(-5, -50), c + Vector2(5, -50), c + Vector2(5, -2)]),
		Color(0.31, 0.27, 0.43) if id == "loidodang" else Color(0.27, 0.47, 0.39))
	for y in [-44, -30, -16]:
		pa.poly(PackedVector2Array([c + Vector2(-4, y), c + Vector2(4, y), c + Vector2(4, y + 4), c + Vector2(-4, y + 4)]), p[1])
	if id == "loidodang":
		Kit.orb(pa, c + Vector2(0, -60), 8.0 + sin(t * 12.0), p)
	else:
		for k in 3:
			var a := t * 4.0 + k * TAU / 3.0
			Kit.crescent(pa, c + Vector2(0, -10), r * 0.7, a, a + 1.4, 9.0, p, 0.7, Kit.SQ, 0.65, 0.5)
		Kit.crescent(pa, c + Vector2(0, -60), 12.0, t * 5.0, t * 5.0 + 4.0, 4.0, p, 1.0)
	return true


## Bẫy / mìn: đĩa nhấp nháy, gai thấp, đèn đỏ của mìn.
static func draw_trap(pa: Kit.Painter, world, tp) -> bool:
	var id := str(tp.skill)
	if not active(id):
		return false
	var p: Array = palette(id)
	var blink := fposmod(float(world.time) * 3.0, 1.0) < 0.5
	var c: Vector2 = tp.pos
	Kit.ring(pa, c, 24.0, 2.0, p, 0.5, 0.3)
	Kit.disc(pa, c, 9.0, p, 1.0, 0.8 if blink else 0.2)
	if id == "baimin":
		Kit.disc(pa, c + Vector2(0, -4), 4.0, [p[0], p[1], Color(1.0, 0.25, 0.15), p[3]], 1.0, 1.0 if blink else 0.0)
	else:
		for dx in [-7.0, 0.0, 7.0]:
			Kit.poly(pa, PackedVector2Array([c + Vector2(dx - 3, 0), c + Vector2(dx, -9), c + Vector2(dx + 3, 0)]), p, 1.0, 0.2)
	return true


## Sao va chạm khi quái trúng đòn, màu theo kỹ năng vừa thi triển (trong 1,5 giây). false = dùng hình cũ.
static func draw_hit(pa: Kit.Painter, world, pos: Vector2, k: float) -> bool:
	if last_id == "" or float(world.time) - last_t > 1.5 or not active(last_id):
		return false
	impact(pa, pos, palette(last_id), k, 12.0, int(pos.x) % 7, false)
	return true


## Nghi thức gọi linh thú: linh thú mới (skill FX-1) → vòng trận xoay, cột sáng, hạt bay lên trong 0,9 giây.
static func _draw_summons(pa: Kit.Painter, world) -> void:
	var now: float = world.time
	var full := 0  # §9.7: tối đa 4 nghi thức đầy đủ mỗi khung (Quân Đoàn gọi 10) — con thứ 5 trở đi chỉ cột sáng + vòng
	for a in world.allies:
		if a.kind != "summon" and a.kind != "bone":
			continue
		if not _seen_allies.has(a):
			_seen_allies[a] = now
		var id := str(a.skill) if a.kind == "summon" else "trieuhoi"  # Xương Nô (kind "bone") không ghi kỹ năng
		if not active(id):
			continue
		var t := (now - float(_seen_allies[a])) / 0.9
		if t > 1.0:
			if id == "kylan" and t < 2.5:
				Kit.sparks(pa, a.pos, (t - 1.0) / 1.5, 10, 40.0, P.heal, 5, true)
			continue
		var p: Array = palette(id)
		var r := 34.0 + float(a.radius)
		full += 1
		var lite := full > 4
		if not lite:
			Kit.decal(pa, a.pos, r * (0.5 + 0.5 * Kit.ease_out(t * 2.0)), p, now * 3.0, 6, 0.9 * (1.0 - t * 0.5))
		if t < 0.6:
			var near: bool = a.pos.distance_to(world.player.pos) < 45.0  # sát người chơi → cột mảnh + nhạt, không che nhân vật
			Kit.pillar(pa, a.pos + Vector2(0, 4), r * (0.45 if near else 0.8) * (1.0 - t), 105.0, p, (0.45 if near else 0.85) * (1.0 - t))
		Kit.ring(pa, a.pos, r * (0.6 + 0.9 * Kit.ease_out(t)), 3.0, p, 1.0 - t)
		if not lite:
			Kit.sparks(pa, a.pos, t, 10, 50.0, p, a.get_instance_id() % 97, true)
	for a in _seen_allies.keys():
		if not is_instance_valid(a) or not world.allies.has(a):
			_seen_allies.erase(a)



## Nổ khi Thiên Thạch / Cầu Sấm biến mất (vật thể gameplay đã nổ).
static func _track(obj, pos: Vector2, r: float, p: Array, rocks: bool, spikes := false) -> void:
	for w in _watch:
		if is_same(w[0], obj):
			w[1] = pos
			return
	_watch.append([obj, pos, r, p, rocks, spikes])


static func _alive(world, obj) -> bool:
	for list in [world.meteors, world.sk2.orbs, world.cl2.slams, world.sk2.queue]:
		for x in list:
			if is_same(x, obj):
				return true
	return false


static func _draw_vanish(pa: Kit.Painter, world) -> void:
	var keep: Array = []
	for w in _watch:
		if _alive(world, w[0]):
			keep.append(w)
		else:
			_boom.append({"pos": w[1], "r": w[2], "p": w[3], "t": 0.0, "rocks": w[4], "spikes": w[5]})
			impact_shake(0.65 if w[4] else 0.4)  # thiên thạch / búa nện / cầu sấm nổ
	_watch = keep
	for b in _boom:
		var ti: float = b.t / 0.7
		var c: Vector2 = b.pos
		if ti <= 1.0 and b.get("spikes", false):
			for k in 10:
				var sb: Vector2 = c + Kit.gp(k * TAU / 10.0 + 0.2) * b.r * 0.75
				var h := 40.0 * (Kit.ease_out(minf(1.0, ti * 3.0)) if ti < 0.75 else (1.0 - ti) * 4.0)
				if h > 2.0:
					Kit.poly(pa, PackedVector2Array([sb + Vector2(-8, 0), sb + Vector2(2, -h), sb + Vector2(8, 0)]), b.p, 1.0, 0.7)
		if ti <= 1.0:
			Kit.ring(pa, c, b.r * (0.35 + 0.9 * Kit.ease_out(ti)), 8.0 * (1.0 - ti) + 2.0, b.p, 1.0 - ti * 0.6)
			if ti < 0.4:
				Kit.star(pa, c + Vector2(0, -16), b.r * 0.8 * (1.0 - ti), 12, b.p, 0.0, 0.32, 1.0, 3, 1.8, 0.75)
			if b.rocks:
				Kit.sparks(pa, c, ti, 16, b.r, [b.p[0], Color(0.75, 0.6, 0.43), Color(0.5, 0.36, 0.24), Color(0.24, 0.16, 0.12)], 9, false, 1.2, 4.0)
			Kit.smoke(pa, c, ti, 8, 12.0, DUST, 5, b.r * 0.8, 16.0)


## Phi Thuẫn: khiên xoay bay (cl2.shields).
static func draw_disk(pa: Kit.Painter, world, sh) -> bool:
	if not active("phanthuan"):
		return false
	var p: Array = P.hv_steel
	var spin: float = float(world.time) * 20.0
	Kit.disc(pa, sh.pos + Vector2(0, -16), 14.0, p, 1.0, 1.0)
	Kit.crescent(pa, sh.pos + Vector2(0, -16), 19.0, spin, spin + 2.2, 5.0, p, 1.0, 1.0, 0.65, 0.6)
	Kit.shield(pa, sh.pos + Vector2(0, -17), 6.0, p, 1.0, 0.0)
	return true


## Phán Quyết: vòng rune → búa ánh sáng giáng theo cột sáng (cl2.slams, m.t đếm ngược tới lúc nện).
static func draw_slam(pa: Kit.Painter, world, m, delay: float) -> bool:
	if not active("phanquyet"):
		return false
	var k: float = 1.0 - clampf(float(m.t) / delay, 0.0, 1.0)
	_drop(pa, m.pos, 5.0 * k, P.hv, float(m.r), "hammer")
	_track(m, m.pos, float(m.r), P.hv, true)
	return true


## Thiên Lạc Tinh Vũ: mũi tên sao rơi chéo xuống đúng mục tiêu (j3.stars, s.t đếm ngược tới lúc chạm).
static func draw_star(pa: Kit.Painter, world, s, fall: float) -> bool:
	if not active("tinhvu"):
		return false
	var e = s.target
	if e == null or e.dead:
		return true
	var p: Array = P.ts_star
	var k: float = clampf(float(s.t) / fall, 0.0, 1.5)
	var head: Vector2 = e.pos + Vector2(70.0, -200.0) * k + Vector2(0, -14)
	Kit.streak(pa, head + Vector2(40, -110), head, 8.0, p, 0.9, 0.0, 0.8)
	Kit.star(pa, head, 12.0, 4, p, float(world.time) * 6.0, 0.35, 1.0, 1, 1.4)
	if k < 0.4:
		Kit.decal(pa, e.pos, 30.0, p, float(world.time), 6, 0.6 * (1.0 - k / 0.4))
	return true


## Ngũ Hành Luân Chuyển: 5 cầu Kim / Mộc / Thuỷ / Hoả / Thổ quay đúng vị trí gameplay (Job3.orb_pos).
static func draw_five(pa: Kit.Painter, world, orb_pos: Callable, center: Vector2, r: float) -> bool:
	if not active("nguhanh"):
		return false
	var keys := ["metal", "wood", "ice", "fire", "earth"]
	Kit.decal(pa, center, r, P.arcane, -float(world.time) * 0.8, 5, 0.6)
	for k in 5:
		var at: Vector2 = orb_pos.call(k)
		var a := (at - center).angle()
		Kit.crescent(pa, center, (at - center).length(), a - 0.7, a - 0.05, 6.0, P[keys[k]], 0.65, 1.0, 0.65, 0.4)
		Kit.orb(pa, at, 11.0, P[keys[k]])
	return true


## Thiên Tai Nguyên Tố, pha 2–3 (sk2.queue "tt_ice" / "tt_bolt"): vòng báo màu Băng / Sét co lại tới lúc nổ; pha Băng nổ
## thành vòng gai băng (_draw_vanish), pha Sét do lớp phủ tia (draw_bolt) vẽ màu Lôi. Trả true = bỏ hình cũ.
static func draw_queue(pa: Kit.Painter, world, q, gap: float) -> bool:
	if str(q.get("skill", "")) != "thienhoa" or not active("thienhoa"):
		return false
	var kind := str(q.get("kind", ""))
	if kind != "tt_ice" and kind != "tt_bolt":
		return false
	var p: Array = P.ice if kind == "tt_ice" else P.bolt
	var k: float = 1.0 - clampf(float(q.t) / maxf(0.01, gap), 0.0, 1.0)
	if float(q.t) < gap:
		Kit.decal(pa, q.pos, 120.0 * (1.0 - 0.3 * k), p, float(world.time) * 2.0, 10, 0.4 + 0.5 * k)
	if kind == "tt_ice":
		_track(q, q.pos, 120.0, p, false, true)
	return true


## §9.9 (bước 8, lát 1): vòng cảnh báo đòn của quái theo ngôn ngữ FX-1 — vùng nguy hiểm giữ ĐÚNG hình tròn gameplay
## (không nén 3/4) để né chính xác; viền 3 dải + glow, 8 vạch chỉ vào tâm, lấp đầy tăng theo tiến độ vung đòn.
## zones: [[tâm, bán kính, bảng màu]]. "old" → false (world_view vẽ kiểu cũ).
static var P_DANGER := Kit.pal("#fff2ee", "#ff9a8a", "#ff3a3a", "#6a0c14")
static var P_SAND := Kit.pal("#fff6e0", "#f2c890", "#d08a3a", "#5a3414")
static var P_TOXIC := Kit.pal("#f4ffe0", "#c0f080", "#62c83a", "#244a10")
static var P_FROST := Kit.pal("#ffffff", "#dceeff", "#9cc4e8", "#3a5a7a")


static func draw_danger(pa: Kit.Painter, world, zones: Array, progress: float) -> bool:
	if current_mode() == "old":
		return false
	var t: float = world.time
	for z in zones:
		var c: Vector2 = z[0]
		var r: float = z[1]
		var p: Array = z[2]
		pa.circle(c, r, Color(p[2], 0.10))
		pa.circle(c, r * clampf(progress, 0.0, 1.0), Color(p[2], 0.22 + 0.1 * progress))
		Kit.ring(pa, c, r, 3.0, p, 0.85, 0.7, 1.0)
		var pulse := 0.5 + 0.5 * sin(t * 14.0)
		for k in 8:
			var a := k * TAU / 8.0 + t * 0.5
			var o := c + Vector2.from_angle(a) * r
			var i := c + Vector2.from_angle(a) * r * (0.86 - 0.04 * pulse)
			pa.line(o, i, Color(p[1], 0.9), 2.0)
		if progress > 0.8:
			pa.gcircle(c, r * 0.9, Color(p[2], 0.18 * (progress - 0.8) / 0.2))
	return true


## §9.11 (bước 8, lát 2): cảnh báo dùng chung cho world_view và region5–9 view, vẽ qua Fx1.painter (world_view gán
## đầu mỗi _draw). Hình giữ ĐÚNG kích thước gameplay: vùng tròn, dải (lao / tia / lăn, nửa bề rộng = half), nón.
## Trả false khi "Hình cũ" hoặc chưa có painter → nơi gọi vẽ kiểu cũ.
static var P_FIRE := Kit.pal("#fff4d0", "#ffc070", "#ff6a1a", "#6a1a08")
static var P_VOID := Kit.pal("#f6ecff", "#d8b0ff", "#9a5ae0", "#34144e")
static var P_GOLD := Kit.pal("#fffbe8", "#ffe7a0", "#e8b040", "#5a3a10")
static var P_LEAF := Kit.pal("#f0ffe8", "#b8f0a0", "#4cbf5a", "#14401c")
## băng đậm cho nền tuyết vùng 6 (P_FROST nhạt chìm vào tuyết)
static var P_ICE := Kit.pal("#ffffff", "#8cc6ff", "#2a78dc", "#0a2868")


## Bảng màu 4 dải từ một màu dữ liệu (vòng báo có màu riêng theo đòn).
static func pal_of(col: Color) -> Array:
	return [col.lerp(Color.WHITE, 0.85), col.lerp(Color.WHITE, 0.45), Color(col, 1.0), col.darkened(0.65)]


static func _danger_on() -> bool:
	return painter != null and current_mode() != "old"


## Vùng tròn nguy hiểm. e = quái đang vung (null = cơ chế của chương: thiên thạch, vòng báo…) để chia cấp ở kiểu tự nhiên.
static func danger_zone(world, c: Vector2, r: float, p: Array, progress: float, e = null) -> bool:
	if not _danger_on():
		return false
	if tele_natural():
		_queue(["zone", c, r, p, clampf(progress, 0.0, 1.0), _nat_alpha(e, progress)])
		return true
	return draw_danger(painter, world, [[c, r, _cb(p)]], progress)


static func danger_line(world, a: Vector2, b: Vector2, half: float, p: Array, progress: float, e = null) -> bool:
	if not _danger_on():
		return false
	if tele_natural():
		_queue(["line", a, b, half, p, clampf(progress, 0.0, 1.0), _nat_alpha(e, progress)])
		return true
	return _clear_line(world, a, b, half, _cb(p), progress)


static func danger_cone(world, c: Vector2, ang: float, half: float, r: float, p: Array, progress: float, e = null) -> bool:
	if not _danger_on():
		return false
	if tele_natural():
		_queue(["cone", c, ang, half, r, p, clampf(progress, 0.0, 1.0), _nat_alpha(e, progress)])
		return true
	return _clear_cone(world, c, ang, half, r, _cb(p), progress)


## Kiểu rõ ràng — dải a → b: nền mờ, phần lấp đầy chạy dọc theo tiến độ, hai mép 3 dải + glow, vạch chặn cuối, mũi tên chạy tới.
static func _clear_line(world, a: Vector2, b: Vector2, half: float, p: Array, progress: float) -> bool:
	var pa: Kit.Painter = painter
	var d := b - a
	var ln := d.length()
	if ln < 2.0:
		return true
	var u := d / ln
	var n := u.orthogonal() * maxf(half, 2.0)
	var pr := clampf(progress, 0.0, 1.0)
	var band := PackedVector2Array([a + n, b + n, b - n, a - n])
	pa.poly(band, Color(p[2], 0.10))
	var m := a + d * pr
	pa.poly(PackedVector2Array([a + n, m + n, m - n, a - n]), Color(p[2], 0.22 + 0.1 * pr))
	for sd in [1.0, -1.0]:
		var e0: Vector2 = a + n * sd
		var e1: Vector2 = b + n * sd
		pa.gline(PackedVector2Array([e0, e1]), 7.0, Color(p[2], 0.22))
		pa.line(e0, e1, Color(p[3], 0.85), 3.0)
		pa.line(e0, e1, Color(p[1], 0.9), 1.2)
	pa.line(b + n, b - n, Color(p[1], 0.9), 2.5)
	var w := clampf(half, 4.0, 14.0)
	var step := maxf(36.0, w * 4.0)
	var x := fmod(float(world.time) * 140.0, step)
	var on := u.orthogonal() * w * 0.75
	while x < ln - 4.0:
		var c := a + u * x
		pa.polyline(PackedVector2Array([c - u * w * 0.6 + on, c, c - u * w * 0.6 - on]), Color(p[1], 0.8), 2.0)
		x += step
	if pr > 0.8:
		pa.gpoly(band, Color(p[2], 0.16 * (pr - 0.8) / 0.2))
	return true


## Kiểu rõ ràng — nón (thở lửa / băng, chém nón, ánh nhìn): tâm c, hướng ang, nửa góc half, tầm r.
static func _clear_cone(world, c: Vector2, ang: float, half: float, r: float, p: Array, progress: float) -> bool:
	var pa: Kit.Painter = painter
	var pr := clampf(progress, 0.0, 1.0)
	var k := clampi(int(half * r / 10.0), 8, 28)
	var rim := PackedVector2Array()
	for i in k + 1:
		rim.append(c + Vector2.from_angle(ang - half + 2.0 * half * i / k) * r)
	var fan := PackedVector2Array([c])
	fan.append_array(rim)
	pa.poly(fan, Color(p[2], 0.10))
	if pr > 0.02:
		var inner := PackedVector2Array([c])
		for q in rim:
			inner.append(c + (q - c) * pr)
		pa.poly(inner, Color(p[2], 0.22 + 0.1 * pr))
	pa.gline(rim, 8.0, Color(p[2], 0.24))
	pa.polyline(rim, Color(p[3], 0.85), 3.0)
	pa.polyline(rim, Color(p[1], 0.9), 1.2)
	for q in [rim[0], rim[k]]:
		pa.line(c, q, Color(p[3], 0.7), 2.4)
		pa.line(c, q, Color(p[1], 0.75), 1.0)
	var pulse := 0.5 + 0.5 * sin(float(world.time) * 14.0)
	for j in 5:
		var a2 := ang - half + 2.0 * half * (j + 0.5) / 5.0
		pa.line(c + Vector2.from_angle(a2) * r, c + Vector2.from_angle(a2) * r * (0.88 - 0.04 * pulse), Color(p[1], 0.9), 2.0)
	if pr > 0.8:
		pa.gpoly(fan, Color(p[2], 0.16 * (pr - 0.8) / 0.2))
	return true


# ================================================================ §9.12 cảnh báo kiểu tự nhiên (mặc định)
## Như ARPG (Diablo / PoE): quái càng mạnh báo càng rõ, và báo bằng thứ có thật trong thế giới (đất nứt, bóng thiên thạch,
## sương giá, hơi nóng, ký tự ấn) thay cho hình học có vạch. Kích thước vẫn ĐÚNG gameplay (mép mờ nhưng có viền nhạt ở
## đúng bán kính / tầm). Vết mặt đất ghi vào tele_queue rồi world_view vẽ ở khung sau, TRƯỚC lớp quái / cây (nằm dưới quái).
const TELE_STYLES := [["natural", "Tự nhiên"], ["clear", "Rõ ràng"]]
## Quái thường: đòn lao / bắn / chém nón chỉ báo bằng động tác (windup_cue) + vệt bụi hướng đòn, không vẽ vùng.
## "dash" (Sói lao) KHÔNG nằm ở đây: PACE-TELE đo được nó gây 56% sát thương ở vùng 1 (vùng người mới học né) → giữ rãnh
## bụi mờ từ 35%. "punch" / "melee" cận chiến: kiểu cũ cũng chỉ có vòng nở quanh quái, Diablo không có gì.
const BODY_ONLY := ["melee", "punch", "pounce", "volley", "darts", "dart1", "spore", "leaf", "gaze", "roll", "tiger", "dive",
	"lance", "clouddash", "pdive", "m_dash", "m_bolt", "elemlance", "gallop", "dash9", "heavycleave", "jaw"]
static var tele_queue: Array = []


static func tele_natural() -> bool:
	return str(_setting("tele_style", "natural")) != "clear"


static func _major(e) -> bool:
	return e == null or bool(e.elite) or str(e.role) == "boss"


## Độ hiện của vết: cơ chế / tinh anh / boss hiện từ 10% thời gian lấy đà; quái thường từ 35% (đòn vùng) hoặc không vẽ
## (đòn lao / bắn). Hiện dần, không bật phụt.
static func _nat_alpha(e, progress: float) -> float:
	if e != null and not _major(e) and str(e.attack_kind) in BODY_ONLY:
		return 0.0
	var start := 0.1 if _major(e) else 0.35
	# boss: đòn nặng nhất → đậm hơn (đo trên ảnh chụp: vết nện của boss chìm dưới tán cây ở mức 1,0)
	var boost := 1.6 if e != null and str(e.role) == "boss" else 1.0
	return smoothstep(start, start + 0.3, progress) * boost


static func _queue(item: Array) -> void:
	if float(item[item.size() - 1]) <= 0.0:
		return
	if tele_queue.size() > 300:
		tele_queue.clear()
	tele_queue.append(item)


## world_view gọi trước lớp quái / cây: vẽ vết ghi ở khung trước (trễ 1 khung ≈ 16 ms, không nhận ra).
static func flush_ground(pa: Kit.Painter, world) -> void:
	var q := tele_queue
	tele_queue = []
	var t: float = world.time
	for it in q:
		match it[0]:
			"zone":
				_nat_zone(pa, t, it[1], it[2], it[3], it[4], it[5])
			"line":
				_nat_line(pa, t, it[1], it[2], it[3], it[4], it[5], it[6])
			"cone":
				_nat_cone(pa, t, it[1], it[2], it[3], it[4], it[5], it[6], it[7])


static func _mat(p: Array) -> String:
	if p == P_FIRE:
		return "fire"
	if p == P_FROST or p == P_ICE:
		return "frost"
	if p == P_SAND:
		return "dust"
	if p == P_VOID or p == P_GOLD:
		return "rune"
	if p == P_TOXIC:
		return "venom"
	if p == P_LEAF:
		return "leaf"
	if p == P_DANGER:
		return "crack"
	return "shadow"


static func _h(c: Vector2, i: int) -> float:
	var v := sin(c.x * 12.9898 + c.y * 78.233 + i * 37.719) * 43758.5453
	return v - floorf(v)


## Viền nhạt ở đúng bán kính, chập chờn từng đoạn (không phải vòng kẻ đều).
static func _rim(pa: Kit.Painter, t: float, c: Vector2, r: float, col: Color, alpha: float, w: float) -> void:
	var n := 18
	for i in n:
		var f := 0.6 + 0.4 * sin(t * 5.0 + i * 1.7 + c.x * 0.01)
		var a0 := TAU * i / n
		# nét sẫm dưới nét màu: nền sáng (cát, mây, đá trắng) vẫn đọc được viền; nền tối thì nét màu nổi
		pa.arc(c, r, a0, a0 + TAU / n * 0.9, Color(0.05, 0.03, 0.02, minf(0.5, alpha * f * 1.1)), w + 1.8)
		pa.arc(c, r, a0, a0 + TAU / n * 0.9, Color(col.lerp(Color.WHITE, 0.35), alpha * f), w)


static func _puffs(pa: Kit.Painter, t: float, c: Vector2, r: float, col: Color, alpha: float) -> void:
	for i in 10:
		var ph := fposmod(t * 1.1 + _h(c, i), 1.0)
		var d := c + Vector2.from_angle(TAU * i / 10.0 + _h(c, i + 30)) * r
		pa.circle(d + Vector2(0, -6.0 * ph), 3.0 + r * 0.05 * ph, Color(col, alpha * (1.0 - ph)))


static func _nat_zone(pa: Kit.Painter, t: float, c: Vector2, r: float, p: Array, k: float, a: float) -> void:
	var mat := _mat(p)
	p = _cb(p)
	var grow := 0.35 + 0.65 * k
	if a > 1.0:
		# boss: quầng sáng nhẹ ở đúng mép trên lớp glow (nằm trên tán cây) — vùng đòn nặng không bị cây che mất
		pa.garc(c, r, 4.0, Color(p[2], 0.22 * k))
	match mat:
		"fire":  # bóng cháy sẫm lớn dần + viền hơi nóng + than hồng rơi
			for j in 4:
				pa.circle(c, r * (1.0 - j * 0.2) * grow, Color(0.12, 0.03, 0.0, 0.11 * a))
			_rim(pa, t, c, r, Color(1.0, 0.5, 0.18), 0.32 * a * (0.4 + 0.6 * k), 2.0)
			if k > 0.55:
				pa.gcircle(c, r * 0.75, Color(1.0, 0.42, 0.1, 0.16 * a * (k - 0.55) / 0.45))
			for i in 7:
				var ph := fposmod(t * 0.9 + _h(c, i), 1.0)
				var at := c + Vector2.from_angle(_h(c, i + 20) * TAU) * r * 0.85 * _h(c, i + 40)
				pa.circle(at + Vector2(-10, -70) * (1.0 - ph), 1.4 + 1.2 * ph, Color(1.0, 0.6 + 0.35 * ph, 0.2, 0.75 * a * k))
		"frost":  # sương giá lan trên đất + gai băng
			for j in 4:
				pa.circle(c, r * (1.0 - j * 0.22) * grow, Color(p[1], 0.08 * a))
			var n := clampi(int(r / 7.0), 10, 26)
			for i in n:
				var ang := TAU * i / n + _h(c, i) * 0.3
				var r0 := r * (0.5 + 0.4 * _h(c, i + 9)) * grow
				var ln := r * (0.1 + 0.12 * _h(c, i + 3))
				var base := c + Vector2.from_angle(ang) * r0
				pa.line(base, c + Vector2.from_angle(ang) * minf(r0 + ln, r), Color(p[2], 0.6 * a), 2.0)
				pa.line(base, base + Vector2.from_angle(ang + 0.6) * ln * 0.5, Color(p[1], 0.5 * a), 1.2)
			_rim(pa, t, c, r, p[2], 0.34 * a * (0.4 + 0.6 * k), 1.6)
		"dust":  # cát xoáy
			for j in 3:
				pa.circle(c, r * (1.0 - j * 0.25), Color(p[3], 0.08 * a))
			for i in 3:
				var a0 := t * 1.6 + i * TAU / 3.0
				pa.arc(c, r * (0.35 + 0.2 * i) * grow, a0, a0 + 2.2, Color(p[3], 0.4 * a), 3.4)
				pa.arc(c, r * (0.35 + 0.2 * i) * grow, a0, a0 + 2.2, Color(p[1], 0.35 * a), 2.0)
			_puffs(pa, t, c, r, Color(p[1]), 0.25 * a * k)
			_rim(pa, t, c, r, p[2], 0.26 * a * k, 1.4)
		"rune":  # vòng ấn: các đoạn ký tự xoay chậm
			pa.circle(c, r * grow, Color(p[3], 0.12 * a))
			var rot := t * 0.4
			for ring in [1.0, 0.8]:
				var seg := 9 if ring == 1.0 else 6
				for i in seg:
					var a0: float = rot * (1.0 if ring == 1.0 else -1.3) + TAU * i / seg
					pa.arc(c, r * ring, a0, a0 + TAU / seg * 0.62, Color(p[1], 0.4 * a * (0.5 + 0.5 * k)), 1.6)
			for i in 6:
				pa.circle(c + Vector2.from_angle(rot + i * TAU / 6.0 + 0.3) * r * 0.9, 2.2, Color(p[0], 0.5 * a))
			if k > 0.6:
				pa.gcircle(c, r * 0.8, Color(p[2], 0.16 * a * (k - 0.6) / 0.4))
		"venom":  # vũng độc sủi bọt
			for j in 4:
				pa.circle(c, r * (1.0 - j * 0.2) * grow, Color(p[2], 0.09 * a))
			for i in 6:
				var ph := fposmod(t * 1.3 + _h(c, i), 1.0)
				var bp := c + Vector2.from_angle(_h(c, i + 5) * TAU) * r * 0.7 * _h(c, i + 11)
				pa.arc(bp, 2.0 + 4.0 * ph, 0.0, TAU, Color(p[1], 0.55 * a * (1.0 - ph)), 1.2)
			_rim(pa, t, c, r, p[2], 0.28 * a * k, 1.6)
		"leaf":  # bóng rễ + dây leo bò vào
			for j in 3:
				pa.circle(c, r * (1.0 - j * 0.25) * grow, Color(0.05, 0.12, 0.04, 0.11 * a))
			for i in 8:
				var ang := TAU * i / 8.0 + _h(c, i) * 0.4
				var pts := PackedVector2Array()
				for s2 in 5:
					var rr := r * (1.0 - 0.5 * k * s2 / 4.0)
					pts.append(c + Vector2.from_angle(ang + sin(s2 * 1.4 + i) * 0.12) * rr)
				pa.polyline(pts, Color(0.06, 0.03, 0.01, 0.45 * a), 4.0)  # rễ nâu: nổi trên cỏ xanh (vùng 7)
				pa.polyline(pts, Color(0.42, 0.27, 0.13, 0.75 * a), 2.2)
			_rim(pa, t, c, r, p[2], 0.28 * a * k, 1.6)
		_:  # "crack": đất nứt toả ra + bụi ở mép; "shadow": bóng vật rơi
			for j in 3:
				pa.circle(c, r * (1.0 - j * 0.25) * grow, Color(0.06, 0.04, 0.03, 0.10 * a))
			if mat == "crack":
				var n := clampi(int(r / 12.0), 6, 11)
				for i in n:
					var ang := TAU * i / n + _h(c, i) * 0.5
					var pts := PackedVector2Array([c])
					for s2 in range(1, 5):
						var rr := r * s2 / 4.0 * clampf(k * 1.25, 0.0, 1.0)
						pts.append(c + Vector2.from_angle(ang + (_h(c, i * 7 + s2) - 0.5) * 0.5) * rr)
					pa.polyline(pts, Color(0.06, 0.03, 0.02, 0.6 * a), 2.6)
					pa.polyline(pts, Color(p[2], 0.35 * a * k), 1.0)
				_puffs(pa, t, c, r, Color(0.78, 0.7, 0.62), 0.2 * a * k)
			_rim(pa, t, c, r, p[2], 0.28 * a * (0.4 + 0.6 * k), 1.8)


static func _mat_col(mat: String, p: Array) -> Color:
	match mat:
		"fire":
			return Color(0.14, 0.03, 0.0)
		"frost", "venom":
			return Color(p[1])
		"rune":
			return Color(p[3])
	return Color(0.08, 0.05, 0.03)


## Dải: rãnh mờ cày dọc đường đòn (lan tới theo tiến độ) + mép nhạt đúng bề rộng + bụi / than / sương trôi về phía trước.
static func _nat_line(pa: Kit.Painter, t: float, a0: Vector2, b0: Vector2, half: float, p: Array, k: float, al: float) -> void:
	var d := b0 - a0
	var ln := d.length()
	if ln < 2.0:
		return
	var u := d / ln
	var n := u.orthogonal()
	var mat := _mat(p)
	p = _cb(p)
	var hw := maxf(half, 3.0)
	var reach := a0 + d * clampf(k * 1.15, 0.0, 1.0)
	var base := _mat_col(mat, p)
	for j in 3:
		var w := hw * (1.0 - j * 0.3)
		pa.poly(PackedVector2Array([a0 + n * w, reach + n * w, reach - n * w, a0 - n * w]), Color(base, 0.1 * al))
	for sd in [1.0, -1.0]:
		var ea := 0.34 * al * (0.4 + 0.6 * k)
		pa.line(a0 + n * hw * sd, b0 + n * hw * sd, Color(0.05, 0.03, 0.02, minf(0.5, ea * 1.1)), 3.0)
		pa.line(a0 + n * hw * sd, b0 + n * hw * sd, Color(p[1], ea), 1.4)
	var cnt := clampi(int(ln / 24.0), 3, 16)
	var col := Color(1.0, 0.6, 0.2) if mat == "fire" else (Color(p[1]) if mat in ["frost", "rune", "venom"] else Color(0.8, 0.72, 0.62))
	for i in cnt:
		var x := fposmod(t * 90.0 + i * ln / cnt, ln)
		var side := (_h(a0, i) - 0.5) * 1.4 * hw
		var ph := x / ln
		pa.circle(a0 + u * x + n * side, 1.8 + 1.6 * ph, Color(col, 0.5 * al * (1.0 - ph * 0.6)))
	if k > 0.75:
		pa.gpoly(PackedVector2Array([a0 + n * hw, b0 + n * hw, b0 - n * hw, a0 - n * hw]), Color(p[2], 0.1 * al * (k - 0.75) / 0.25))


## Nón: hơi nóng / sương / bụi đặc ở gốc, nhạt dần ra xa; viền nhạt chập chờn đúng tầm; hạt trôi ra ngoài.
static func _nat_cone(pa: Kit.Painter, t: float, c: Vector2, ang: float, half: float, r: float, p: Array, k: float, al: float) -> void:
	var mat := _mat(p)
	p = _cb(p)
	var base := Color(p[2]) if mat in ["fire", "frost", "rune", "venom"] else Color(0.1, 0.06, 0.05)
	var nseg := clampi(int(half * r / 12.0), 8, 24)
	for j in 4:
		var rr := r * (1.0 - j * 0.22) * (0.4 + 0.6 * k)
		var fan := PackedVector2Array([c])
		for i in nseg + 1:
			fan.append(c + Vector2.from_angle(ang - half + 2.0 * half * i / nseg) * rr)
		pa.poly(fan, Color(base, 0.07 * al))
	var segs := 7
	for i in segs:
		var f := 0.6 + 0.4 * sin(t * 5.0 + i * 1.9)
		var a1 := ang - half + 2.0 * half * i / segs
		var ra := 0.38 * al * f * (0.4 + 0.6 * k)
		pa.arc(c, r, a1, a1 + 2.0 * half / segs * 0.9, Color(0.05, 0.03, 0.02, minf(0.5, ra * 1.1)), 3.4)
		pa.arc(c, r, a1, a1 + 2.0 * half / segs * 0.9, Color(p[1], ra), 1.6)
	for sd in [-1.0, 1.0]:
		pa.line(c, c + Vector2.from_angle(ang + half * sd) * r, Color(0.05, 0.03, 0.02, minf(0.4, 0.24 * al)), 2.6)
		pa.line(c, c + Vector2.from_angle(ang + half * sd) * r, Color(p[1], 0.26 * al), 1.2)
	for i in 10:
		var ph := fposmod(t * 0.8 + _h(c, i), 1.0)
		var dir := ang + (_h(c, i + 13) - 0.5) * 2.0 * half * 0.9
		pa.circle(c + Vector2.from_angle(dir) * r * ph, 1.8 + 2.4 * ph, Color(p[1], 0.5 * al * (1.0 - ph)))
	if k > 0.7:
		var fan2 := PackedVector2Array([c])
		for i in nseg + 1:
			fan2.append(c + Vector2.from_angle(ang - half + 2.0 * half * i / nseg) * r)
		pa.gpoly(fan2, Color(p[2], 0.12 * al * (k - 0.7) / 0.3))


## Động tác lấy đà (mọi quái, kiểu tự nhiên; vẽ đè lên quái): bụi dưới chân, thân loé ánh ở 30% cuối; quái thường dùng đòn
## lao / bắn thì thêm vệt bụi mờ chỉ hướng đòn từ 45% — đủ để né mà không có hình học.
static func windup_cue(pa: Kit.Painter, world, e, progress: float) -> bool:
	if not _danger_on() or not tele_natural():
		return false
	var k := clampf(progress, 0.0, 1.0)
	var t: float = world.time
	var feet: Vector2 = e.pos + Vector2(0, e.radius * 0.7)
	for i in 3:
		var ph := fposmod(t * 2.2 + i / 3.0, 1.0)
		pa.circle(feet + Vector2((i - 1) * e.radius * 0.6, -ph * 4.0), e.radius * (0.18 + 0.25 * ph), Color(0.8, 0.74, 0.66, 0.3 * k * (1.0 - ph)))
	if k > 0.6:
		# thân loé ánh đỏ cam + ánh kim loé ở đầu (quái nhỏ, đánh nhanh → cần rõ hơn Diablo một bậc)
		var g := (k - 0.6) / 0.4
		pa.gcircle(e.pos, e.radius * (1.1 + 0.3 * g), Color(1.0, 0.5, 0.35, 0.32 * g))
		var gl: Vector2 = e.pos + Vector2(e.radius * 0.5, -e.radius * 0.9)
		var sz := 5.0 + 8.0 * g
		pa.line(gl - Vector2(sz, 0), gl + Vector2(sz, 0), Color(1.0, 1.0, 0.92, g), 2.0)
		pa.line(gl - Vector2(0, sz), gl + Vector2(0, sz), Color(1.0, 1.0, 0.92, g), 2.0)
		pa.gcircle(gl, sz * 0.9, Color(1.0, 0.9, 0.7, 0.5 * g))
	var kind := str(e.attack_kind)
	if not _major(e) and kind in BODY_ONLY and kind != "melee" and k > 0.45:
		var d: Vector2 = (e.target - e.pos).limit_length(260.0)
		if d.length() > 4.0:
			var s := (k - 0.45) / 0.55
			var u := d.normalized()
			for i in 6:
				var f := (i + 1) / 7.0
				if f > s:
					break
				var ph := fposmod(t * 2.0 + i * 0.3, 1.0)
				var at: Vector2 = e.pos + d * f + u.orthogonal() * (ph - 0.5) * 6.0
				pa.circle(at + Vector2(0, 2), 4.5 + 2.0 * ph, Color(0.1, 0.07, 0.04, 0.22))
				pa.circle(at, 3.2 + 2.4 * ph, Color(0.9, 0.84, 0.74, 0.55 * (1.0 - ph * 0.5)))
	return true


## §9.13 tư thế lấy đà (mọi quái, trừ "Hình cũ"): co người + ngả ngược hướng đòn tới 75% thời gian lấy đà, 25% cuối run lên
## vì căng lực rồi mới bật ra — động tác là tín hiệu chính của ARPG. Trả [squash, lean (rad), lệch vị trí].
static func windup_pose(world, e, progress: float) -> Array:
	if current_mode() == "old":
		return [Vector2.ONE, 0.0, Vector2.ZERO]
	var k := clampf(progress, 0.0, 1.0)
	var c := Kit.ease_out(minf(1.0, k / 0.75))
	var dirx := signf(e.target.x - e.pos.x)
	if dirx == 0.0:
		dirx = 1.0
	var off := Vector2.ZERO
	if k > 0.75:
		var tr := (k - 0.75) / 0.25
		off = Vector2(sin(float(world.time) * 70.0 + e.id) * 1.2 * tr, 0.0)
	return [Vector2(1.0 + 0.08 * c, 1.0 - 0.12 * c), -dirx * 0.1 * c, off]


## §9.13 âm báo: tinh anh / boss BẮT ĐẦU lấy đà trong 700 px quanh người chơi → "tele_elite" / "tele_boss" (một lần mỗi đòn).
## Diablo dựa nhiều vào âm thanh; người chơi nhận ra đòn nặng cả khi đang nhìn chỗ khác. "Hình cũ" thì không phát.
static var _wind_heard := {}


static func _tele_audio(world) -> void:
	if current_mode() == "old":
		return
	var seen := {}
	for e in world.enemies:
		if e.dead or e.state != "windup" or not (e.elite or str(e.role) == "boss"):
			continue
		seen[e.id] = true
		if _wind_heard.has(e.id) or e.pos.distance_to(world.player.pos) > 700.0:
			continue
		_wind_heard[e.id] = true
		world._sfx("tele_boss" if str(e.role) == "boss" else "tele_elite")
	for id in _wind_heard.keys():
		if not seen.has(id):
			_wind_heard.erase(id)


## §9.14 người mù màu đỏ – lục (Cài đặt → Trợ năng, quy ước "tốt / xấu = lam / cam" của UiTheme): cảnh báo đỏ → cam,
## xanh lá (độc, rễ) → lam ngọc. Chất liệu (_mat) vẫn tính từ bảng màu gốc, chỉ đổi màu vẽ.
static var P_CB_RED := Kit.pal("#fff4e0", "#ffc88a", "#ff8a1a", "#5a2a06")
static var P_CB_GREEN := Kit.pal("#e8fbff", "#9adcf0", "#2aa0c8", "#0a3a4e")


static func _cb(p: Array) -> Array:
	if not bool(_setting("colorblind", false)):
		return p
	if p == P_DANGER:
		return P_CB_RED
	if p == P_TOXIC or p == P_LEAF:
		return P_CB_GREEN
	return p
