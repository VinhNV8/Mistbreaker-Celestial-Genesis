extends RefCounted
## NL-1 (docs/47): dữ liệu các đường tăng Lực chiến cho trang bị ngoài cường hoá — Khảm Ngọc Ngũ Hành (A),
## Tẩy Luyện (B), Thăng Phẩm (C), Luyện Cấp (D), Thức Tỉnh (E), Bảo Giám (F). Logic ở core/gear.gd.

# ------------------------------------------------------------------ mở khoá (Q230)

## Vùng cao nhất đã mở (unlocked_maps "R-x") tối thiểu để dùng tính năng; Thức Tỉnh cần chuyển chức 3.
const UNLOCK_REGION := {"gems": 2, "reforge": 3, "levelup": 3, "ascend": 4}
const FEATURE_NAMES := {"gems": "Khảm ngọc", "reforge": "Tẩy luyện", "ascend": "Thăng phẩm", "levelup": "Luyện cấp",
	"awaken": "Thức tỉnh", "codex": "Bảo Giám"}

# ------------------------------------------------------------------ A. Ngọc Ngũ Hành

const ELEMENTS := ["kim", "moc", "thuy", "hoa", "tho"]
const GEM_NAMES := {"kim": "Bạch Ngọc", "moc": "Bích Ngọc", "thuy": "Lam Ngọc", "hoa": "Hồng Ngọc", "tho": "Hoàng Ngọc"}
## Chỉ số chính mỗi hệ (tính chất ngũ hành: Kim sắc bén, Mộc sinh trưởng, Thủy linh hoạt, Hỏa bùng nổ, Thổ vững chãi).
const GEM_STAT := {"kim": "atk", "moc": "max_hp", "thuy": "atk_speed", "hoa": "crit_dmg", "tho": "def"}
## Giá trị theo cấp 1…10 — ngân sách docs/47 §4: 24 viên cấp 10 ≈ +30% Lực chiến trang bị cuối game.
const GEM_VALUES := {
	"kim": [2.0, 5.0, 8.0, 12.0, 16.0, 21.0, 26.0, 31.0, 36.0, 42.0],
	"moc": [25.0, 50.0, 80.0, 115.0, 155.0, 200.0, 250.0, 300.0, 360.0, 420.0],
	"thuy": [0.006, 0.012, 0.018, 0.024, 0.03, 0.036, 0.042, 0.048, 0.054, 0.06],
	"hoa": [0.015, 0.03, 0.045, 0.06, 0.07, 0.085, 0.1, 0.115, 0.13, 0.14],
	"tho": [3.0, 6.0, 9.0, 13.0, 18.0, 23.0, 29.0, 35.0, 43.0, 52.0],
}
## Trên đồ phòng thủ (ItemData.RES_SLOTS) ngọc cộng thêm kháng hệ cùng hệ: 0,5% × cấp.
const GEM_RES_PER_LV := 0.005
const GEM_MAX_LV := 10
## Ghép 3 viên cùng loại cùng cấp → 1 viên cấp sau (luôn thành công).
const GEM_COMBINE := 3
## Lỗ ngọc sẵn có theo phẩm chất; đục thêm tối đa 3.
const SOCKETS := {"white": 0, "green": 1, "blue": 1, "purple": 2, "orange": 3}
const MAX_SOCKETS := 3
const PUNCH_TINH_KIM := 1
const PUNCH_GOLD := 500
## Tháo ngọc: 100 × cấp vàng, ngọc không vỡ.
const UNSOCKET_GOLD := 100
## Ấn hệ vũ khí: ≥ 2 viên cùng hệ → đòn mang hệ đó, khắc hệ +15% (Q231; Ngũ Hành Linh Căn giữ +30%).
const SEAL_MIN := 2
const SEAL_BONUS := 0.15
## Rơi ngọc (RNG rơi đồ riêng, không đổi chuỗi trận đánh).
const GEM_DROP_FIELD := 0.02
const GEM_DROP_ELITE := 0.25
const GEM_BOSS_LV := 3
## Cổng dungeon: cấp ngọc theo hạng (C trở lên).
const GEM_GATE_LV := {"C": 2, "B": 2, "A": 3, "S": 4}
## Rương uỷ thác ngày: 1 viên cấp 2; phân rã đồ Cam: 1 viên cấp 2.
const GEM_DAILY_LV := 2
const GEM_SALVAGE_ORANGE_LV := 2

# ------------------------------------------------------------------ B. Tẩy Luyện

## Luyện giá trị: 20 × L vàng + 1 Tinh Thạch; Đổi dòng: 50 × L vàng + 1 Tinh Kim. ×1,25 mỗi lần tẩy (tối đa ×3).
const REFORGE := {
	"value": {"gold": 20, "crystal": 1, "tinh_kim": 0, "name": "Luyện giá trị"},
	"swap": {"gold": 50, "crystal": 0, "tinh_kim": 1, "name": "Đổi dòng"},
}
const REFORGE_GROWTH := 1.25
const REFORGE_GROWTH_MAX := 3.0

# ------------------------------------------------------------------ C. Thăng Phẩm

const ASCEND := {
	"green": {"to": "blue", "crystal": 2, "tinh_kim": 0, "gold": 30},
	"blue": {"to": "purple", "crystal": 5, "tinh_kim": 1, "gold": 60},
}
## Món nguyên liệu: cùng ô, cùng phẩm chất, cấp ≥ L − 5.
const ASCEND_GAP := 5

# ------------------------------------------------------------------ D. Luyện Cấp đồ Cam / đồ bộ

const LEVELUP_STEP := 5
## Tinh Kim = 1 + ⌊L / 20⌋, vàng = 40 × L (L = cấp hiện tại của món).
const LEVELUP_TK_PER := 20
const LEVELUP_GOLD := 40

# ------------------------------------------------------------------ E. Thức Tỉnh

const AWAKEN_MIN_PLUS := 12
const AWAKEN_RARITIES := ["purple", "orange"]
const AWAKEN_MAX_TIER := 5
## Tinh Hoa để lên bậc n (chỉ số = n − 1): mở = bậc 1.
const AWAKEN_ESSENCE := [5, 10, 20, 35, 50]
## Lõi Hư Vô từ bậc 4.
const AWAKEN_VOID := [0, 0, 0, 1, 2]
## Tối đa 4 món đang mặc có hiệu lực (Q234) — ưu tiên bậc cao.
const AWAKEN_MAX_ACTIVE := 4
const AWAKEN_OFFER := 3
## Đổi dòng: 50% Tinh Hoa đã dùng, giữ bậc.
const AWAKEN_REROLL_PCT := 0.5

## Bể dòng Thức Tỉnh. key = khoá bonus (Items.equipment_bonus / GameWorld._derive), v = giá trị bậc 1…5.
## classes / groups rỗng = dòng chung; có thì chỉ ra cho lớp / nhóm Thiên phú đó.
## pct = hiển thị dạng %, unit = hậu tố khác.
const AWAKEN_LINES := {
	"boss": {"text": "Sát thương lên boss +%s", "key": "boss_dmg", "v": [0.02, 0.03, 0.04, 0.05, 0.06], "pct": true},
	"atk": {"text": "Tấn công +%s", "key": "atk_pct", "v": [0.02, 0.03, 0.04, 0.05, 0.06], "pct": true},
	"hp": {"text": "HP tối đa +%s", "key": "max_hp_pct", "v": [0.03, 0.045, 0.06, 0.075, 0.09], "pct": true},
	"leech": {"text": "Hút %s sát thương thành máu", "key": "lifesteal", "v": [0.003, 0.006, 0.009, 0.012, 0.015], "pct": true},
	"counter": {"text": "Đòn khắc hệ +%s sát thương", "key": "counter_dmg", "v": [0.01, 0.02, 0.03, 0.04, 0.05], "pct": true},
	"crit_dmg": {"text": "Sát thương chí mạng +%s", "key": "crit_dmg", "v": [0.04, 0.06, 0.08, 0.10, 0.12], "pct": true,
		"groups": ["combat"]},
	"skill": {"text": "Sát thương kỹ năng +%s", "key": "skill_dmg", "v": [0.03, 0.045, 0.06, 0.08, 0.10], "pct": true,
		"groups": ["magic", "control", "special"], "classes": ["phap-su"]},
	"move": {"text": "Tốc chạy +%s", "key": "move_pct", "v": [0.02, 0.03, 0.04, 0.05, 0.06], "pct": true,
		"groups": ["explore"]},
	"def": {"text": "Phòng thủ +%s", "key": "def_pct", "v": [0.03, 0.045, 0.06, 0.075, 0.09], "pct": true,
		"groups": ["economy", "craft", "territory"], "classes": ["ho-ve"]},
	"spin": {"text": "Xoáy Kiếm hồi chiêu −%s giây", "key": "spin_cd", "v": [0.2, 0.3, 0.4, 0.5, 0.6], "pct": false,
		"classes": ["kiem-khach"]},
	"aspd": {"text": "Tốc đánh +%s", "key": "atk_speed_pct", "v": [0.02, 0.03, 0.04, 0.05, 0.06], "pct": true,
		"classes": ["tho-san"]},
	"pet": {"text": "HP linh thú +%s", "key": "pet_hp_pct", "v": [0.04, 0.06, 0.08, 0.10, 0.12], "pct": true,
		"classes": ["trieu-hoi-su"], "groups": ["summon"]},
}

# ------------------------------------------------------------------ F. Bảo Giám

## Điểm ghi danh lần đầu sở hữu.
const CODEX_SET_PIECE := 2
## Một bộ có ≥ 6 ô khác nhau đã ghi danh: +6.
const CODEX_SET_FULL := 6
const CODEX_SET_FULL_N := 6
const CODEX_UNIQUE := 5
const CODEX_PLUS := {10: 1, 13: 2, 15: 4}
const CODEX_GEM := {7: 3, 10: 6}
## Mốc điểm → thưởng vĩnh viễn (tổng ≈ +5%). title = danh hiệu trang trí.
const CODEX_MILESTONES := [
	{"at": 20, "bonus": {"max_hp_pct": 0.01}, "text": "+1% HP tối đa"},
	{"at": 50, "bonus": {"atk_pct": 0.01}, "text": "+1% Tấn công"},
	{"at": 90, "bonus": {"def_pct": 0.01}, "text": "+1% Phòng thủ"},
	{"at": 140, "bonus": {"atk_pct": 0.01}, "text": "+1% Tấn công"},
	{"at": 200, "bonus": {"max_hp_pct": 0.01}, "text": "+1% HP tối đa, danh hiệu \"Bảo Giám Sư\"", "title": "Bảo Giám Sư"},
]
