extends RefCounted
## AF-1 (docs/48): chiến thuật của từng kỹ năng cho Tự đánh thông minh (core/auto_fight.gd).
## t — loại:
##   "aoe_self" vòng quanh mình bán kính r · "aoe_at" vùng tại điểm ngắm bán kính r (tầm ném reach)
##   "line" đường thẳng dài len (xuyên quái) · "chain" nảy giữa các quái trong r quanh mục tiêu
##   "dash" lao dài len (dùng để áp sát hoặc khi đường lao có ≥ 2 quái) · "single" một mục tiêu
##   "buff" tăng sức mạnh bản thân · "defense" khiên / giảm sát thương · "summon" gọi linh thú (dur giây)
##   "escape" lộn / lùi khỏi quái đang áp sát
## Cờ: big = chiêu mạnh hồi lâu, để dành cho tinh anh / đàn đông; ult = Tối thượng (chỉ đàn ≥ 4 hoặc tinh anh);
## hp_cost = tốn máu (không dùng khi HP < 50%); need_pets = cần linh thú đang sống.
## Đơn vị: điểm ảnh (10 px = 1 m), lấy theo mô tả kỹ năng trong data/classes.gd.

const TACTICS := {
	# --- Kiếm Khách
	"spin": {"t": "aoe_self", "r": 125},
	"dash": {"t": "dash", "len": 180},
	"wave": {"t": "line", "len": 400},
	"kiemy": {"t": "buff"},
	"lientram": {"t": "aoe_at", "r": 70, "reach": 150},
	"hongkiem": {"t": "aoe_self", "r": 80},
	"kiemvu": {"t": "aoe_self", "r": 100},
	"phikiem": {"t": "line", "len": 350},
	"vankiem": {"t": "aoe_self", "r": 150, "ult": true},
	"thanhkiem": {"t": "line", "len": 500},
	"kiemvuc": {"t": "aoe_self", "r": 100},
	"huyetbao": {"t": "aoe_self", "r": 90, "hp_cost": true},
	"huyetanh": {"t": "dash", "len": 150},
	"nhatkiem": {"t": "line", "len": 400, "big": true},
	# --- Thợ Săn
	"rain": {"t": "aoe_at", "r": 90},
	"pierce": {"t": "line", "len": 600},
	"lanban": {"t": "escape"},
	"eagle": {"t": "buff"},
	"tennay": {"t": "chain", "r": 150},
	"trap": {"t": "aoe_at", "r": 60},
	"lienxa": {"t": "single"},
	"tendoc": {"t": "line", "len": 400},
	"thientien": {"t": "aoe_at", "r": 200, "ult": true},
	"phakhong": {"t": "line", "len": 700, "big": true},
	"tamlien": {"t": "line", "len": 500},
	"baimin": {"t": "aoe_self", "r": 120},
	"luoibay": {"t": "aoe_at", "r": 80},
	"tinhvu": {"t": "aoe_self", "r": 250, "big": true},
	# --- Pháp Sư
	"chain": {"t": "chain", "r": 150, "reach": 350},
	"banglao": {"t": "line", "len": 400},
	"meteor": {"t": "aoe_at", "r": 100},
	"barrier": {"t": "defense"},
	"hoatuong": {"t": "aoe_at", "r": 60},
	"nova": {"t": "aoe_self", "r": 110},
	"muabang": {"t": "aoe_at", "r": 90},
	"causam": {"t": "line", "len": 250},
	"thienhoa": {"t": "aoe_at", "r": 120, "ult": true},
	"thienloi": {"t": "aoe_self", "r": 400},
	"bangphong": {"t": "aoe_self", "r": 140},
	"trieuhoi": {"t": "summon", "dur": 15.0},
	"khidoc": {"t": "aoe_at", "r": 100},
	"nguhanh": {"t": "aoe_at", "r": 50, "reach": 300, "big": true},
	# --- Hộ Vệ
	"khienchan": {"t": "aoe_self", "r": 90},
	"khieukhich": {"t": "aoe_self", "r": 120},
	"laokhien": {"t": "dash", "len": 180},
	"khienthep": {"t": "defense"},
	"chandia": {"t": "aoe_self", "r": 100},
	"phanthuan": {"t": "line", "len": 300},
	"phanquyet": {"t": "aoe_at", "r": 80, "reach": 300},
	"xungphong": {"t": "dash", "len": 250},
	"thanhbatdiet": {"t": "defense", "ult": true},
	"thanhquang": {"t": "aoe_self", "r": 110},
	"thanhvuc": {"t": "aoe_self", "r": 100},
	"thietchuy": {"t": "aoe_self", "r": 120},
	"thanhdong": {"t": "aoe_self", "r": 90},
	"thienthuan": {"t": "aoe_self", "r": 120, "big": true},
	# --- Triệu Hồi Sư
	"soibong": {"t": "summon", "dur": 20.0},
	"linhtien": {"t": "line", "len": 350},
	"tieuquy": {"t": "summon", "dur": 12.0},
	"lienket": {"t": "buff", "need_pets": true},
	"thachquy": {"t": "summon", "dur": 15.0},
	"hoadieu": {"t": "line", "len": 400},
	"linhtran": {"t": "aoe_at", "r": 90},
	"linhung": {"t": "summon", "dur": 12.0},
	"quandoan": {"t": "summon", "dur": 15.0, "ult": true},
	"aulong": {"t": "summon", "dur": 18.0},
	"longhong": {"t": "aoe_self", "r": 120},
	"loidodang": {"t": "aoe_at", "r": 150, "dur": 10.0},
	"phongdodang": {"t": "aoe_at", "r": 100, "dur": 8.0},
	"kylan": {"t": "summon", "dur": 12.0, "big": true},
}

## Kiểu Tự đánh dùng kỹ năng (Cài đặt "auto_skills").
const MODES := [["smart", "Thông minh"], ["save", "Tiết kiệm MP"], ["full", "Xả hết"]]
