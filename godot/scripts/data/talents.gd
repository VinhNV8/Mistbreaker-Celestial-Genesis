extends RefCounted
## Dữ liệu Thiên phú — 20 Thiên phú mẫu của kịch bản (mục 3), đặc tả MVP M2 (docs/03-mvp-spec.md, mục 4).

const RANK_ORDER := ["F", "C", "B", "A", "S", "SS", "SSS"]

## Tỉ lệ quay theo hạng (kịch bản mục 3 — Độ hiếm). Trong cùng hạng các Thiên phú chia đều (TL-01).
const RANK_WEIGHT := {"F": 30.0, "C": 28.0, "B": 22.0, "A": 13.0, "S": 5.0, "SS": 1.8, "SSS": 0.2}

const RANK_HEX := {
	"F": "#9aa0a6",
	"C": "#f1f3f4",
	"B": "#5bd16a",
	"A": "#4a9df8",
	"S": "#b36bff",
	"SS": "#ffc940",
	"SSS": "#ff5470",
}

const GROUP_NAMES := {
	"combat": "Chiến đấu",
	"economy": "Kinh tế",
	"explore": "Khai phá",
	"craft": "Chế tạo",
	"territory": "Lãnh địa",
	"summon": "Triệu hồi",
	"magic": "Phép thuật",
	"control": "Điều khiển",
	"special": "Đặc biệt",
}

## TL-14: hiệu ứng phụ mở ở cấp 5 và cấp 10, theo nhóm (mục 4.6).
const GROUP_SUB := {
	"combat": ["+5% chí mạng", "+15% sát thương chí mạng"],
	"economy": ["+10% vàng nhặt được", "Phân rã +1 Đá Cường Hoá"],
	"explore": ["+1 Đuốc tối đa", "Đuốc hồi nhanh hơn 20%"],
	"craft": ["Cường hoá rẻ hơn 10% vàng", "+5% tỉ lệ cường hoá"],
	"territory": ["+10% sản lượng lãnh địa", "Thu hoạch offline tối đa 16 giờ"],
	"summon": ["Đồng minh +20% sát thương", "+1 đồng minh tối đa"],
	"magic": ["Khắc hệ +10% (30% → 40%)", "Kỹ năng L hồi nhanh hơn 20%"],
	"control": ["Kỹ năng L hồi nhanh hơn 15%", "Thời gian hiệu ứng L +1 giây"],
	"special": ["Kỹ năng sao chép +20% sát thương", "Kỹ năng sao chép hồi nhanh hơn 25%"],
}

const MAX_TALENT_LEVEL := 10
## TL-11: Tinh Hoa để lên cấp n → n+1 (chỉ số mảng = n − 1).
const LEVEL_COST := [1, 1, 2, 2, 3, 3, 4, 4, 5]

## skill: kỹ năng phím L (mục 4.3). Không có skill = Thiên phú bị động.
const LIST := [
	{"id": "than-the", "name": "Thân Thể Cường Tráng", "rank": "F", "group": "combat",
		"description": "+8% HP tối đa."},
	{"id": "tay-nhanh", "name": "Tay Nhanh", "rank": "F", "group": "combat",
		"description": "+5% tốc đánh."},
	{"id": "may-man", "name": "May Mắn Nhỏ", "rank": "F", "group": "economy",
		"description": "Quái thường rơi đồ 6% → 11%, rơi Đá Cường Hoá 25% → 30%."},
	{"id": "chan-khong", "name": "Chân Không Biết Mỏi", "rank": "F", "group": "explore",
		"description": "+10% tốc chạy khi không giao chiến (3 giây không đánh, không trúng đòn)."},
	{"id": "huyet-chien", "name": "Huyết Chiến", "rank": "C", "group": "combat",
		"description": "Khi HP dưới 30%: +20% sát thương."},
	{"id": "tho-ren", "name": "Thợ Rèn Bẩm Sinh", "rank": "C", "group": "craft",
		"description": "Cường hoá trang bị +10% tỉ lệ thành công."},
	{"id": "khuu-giac", "name": "Khứu Giác Kho Báu", "rank": "C", "group": "explore",
		"description": "Hiện rương ẩn trong bán kính 30 m."},
	{"id": "kiem-tam", "name": "Kiếm Tâm", "rank": "B", "group": "combat",
		"description": "Mỗi đòn chém thứ 5 gây sát thương chém kép.",
		"skill": {"name": "Nhất Kiếm Đoạn", "cd": 15.0, "text": "Đòn chém tiếp theo ×3 sát thương và chắc chắn chí mạng."}},
	{"id": "thao-duoc", "name": "Nhà Thảo Dược", "rank": "B", "group": "craft",
		"description": "Hái thảo dược ×2; bình máu hồi mạnh hơn 30%.",
		"skill": {"name": "Linh Dược", "cd": 45.0, "text": "Hồi 30% HP ngay, không tốn bình."}},
	{"id": "trai-tim", "name": "Trái Tim Lãnh Chúa", "rank": "B", "group": "territory",
		"description": "Công trình lãnh địa xây nhanh 25%.",
		"skill": {"name": "Hiệu Triệu", "cd": 300.0, "text": "Hoàn thành ngay 1 công trình đang xây."}},
	{"id": "thuan-thu", "name": "Thuần Thú Sư", "rank": "A", "group": "summon",
		"description": "Đòn đánh làm quái thường tụt dưới 10% HP thì thu phục làm thú cưng (tối đa 2)."},
	{"id": "mat-ung", "name": "Mắt Ưng", "rank": "A", "group": "explore",
		"description": "Nhìn xuyên sương mù 2 ô trên bản đồ khai phá; thấy điểm yếu của quái (+10% chí mạng)."},
	{"id": "hap-huyet", "name": "Hấp Huyết", "rank": "A", "group": "combat",
		"description": "8% sát thương gây ra chuyển thành máu; không dùng được bình máu."},
	{"id": "ban-tay-vang", "name": "Bàn Tay Vàng", "rank": "A", "group": "economy",
		"description": "Phân rã trang bị có 20% nhận thêm 1 Tinh Kim (nguyên liệu hiếm)."},
	{"id": "ngu-hanh", "name": "Ngũ Hành Linh Căn", "rank": "S", "group": "magic",
		"description": "Đòn đánh mang hệ Kim/Mộc/Thủy/Hỏa/Thổ; đánh hệ khắc +30% sát thương.",
		"skill": {"name": "Đổi hệ", "cd": 0.5, "text": "Chuyển sang hệ kế tiếp. Xoáy Kiếm trong 2 giây sau khi đổi hệ thành Ngũ Hành Bộc Phá: +100% sát thương, bán kính 16 m."}},
	{"id": "thoi-gian-ngung-dong", "name": "Thời Gian Ngưng Đọng", "rank": "S", "group": "control",
		"description": "Kỹ năng chủ động (phím L) ngưng thời gian của quái.",
		"skill": {"name": "Thời Gian Ngưng Đọng", "cd": 90.0, "text": "Quái và đạn đứng yên 3 giây."}},
	{"id": "bay-dan", "name": "Bầy Đàn Bóng Tối", "rank": "S", "group": "summon",
		"description": "Quái bị hạ có 15% đứng dậy thành lính bóng tối (tối đa 10, tồn tại 60 giây).",
		"skill": {"name": "Bóng Tối Trỗi Dậy", "cd": 60.0, "text": "Gọi ngay 3 lính bóng tối."}},
	{"id": "thien-menh", "name": "Thiên Mệnh Khai Giới", "rank": "SS", "group": "explore",
		"description": "Mỗi Đuốc dọn thêm tối đa 2 ô sương kề bên (×3); sản lượng lãnh địa +20%."},
	{"id": "long-mach", "name": "Long Mạch", "rank": "SS", "group": "territory",
		"description": "Mở công trình Long Mạch Đàn: khi xây xong, +10% Tấn công và HP cho nhân vật và mọi đồng minh."},
	{"id": "dao-tac", "name": "Đạo Tặc", "rank": "SSS", "group": "special", "hidden": true,
		"description": "Hạ quái có tỉ lệ cướp 1 điểm thuộc tính của quái (cộng thẳng vào nhân vật, tối đa 1 × cấp). Hạ boss: cướp 3 điểm và sao chép 1 kỹ năng của boss.",
		"skill": {"name": "Kỹ năng sao chép", "cd": 8.0, "text": "Dùng kỹ năng boss đã sao chép."}},
]


## C1-14 (TP-43, Q20): cây tiến hoá 2 bậc — [tên, hạng, hiệu ứng] (tài liệu 05 mục 3). Tiến hoá làm ở Alpha; hiện chỉ hiển thị.
const EVOLUTION := {
	"than-the": [["Thân Thể Sắt Đá", "C", "+12% HP, +8% Phòng thủ"], ["Kim Cang Bất Hoại", "B", "+16% HP, +12% Phòng thủ; L Kim Cang Thân (40 giây): giảm 50% sát thương nhận 5 giây"]],
	"tay-nhanh": [["Phong Ảnh Thủ", "C", "+10% tốc đánh; né lăn hồi nhanh 20%"], ["Vô Ảnh Kiếm", "B", "+15% tốc đánh; L Vô Ảnh (30 giây): tốc đánh ×2 trong 4 giây"]],
	"may-man": [["Vận May Lớn", "C", "rơi đồ +8 điểm %; 10% đồ rơi được nâng 1 phẩm chất"], ["Thiên Tuyển Chi Nhân", "B", "rơi đồ +10 điểm %; 20% nâng phẩm chất; L Vận Đỏ (300 giây): rơi đồ ×2 trong 30 giây"]],
	"chan-khong": [["Bước Chân Lữ Khách", "C", "+15% tốc chạy bản đồ lục địa; Đuốc hồi nhanh 15%"], ["Thần Hành", "B", "+20% tốc chạy; L Thần Hành Phù (120 giây): dịch chuyển tới cứ điểm bất kỳ đã chiếm"]],
	"huyet-chien": [["Huyết Nộ", "B", "HP < 30%: +30% sát thương, +20% tốc đánh; L Phẫn Huyết (30 giây): mất 20% HP, +40% sát thương 8 giây"], ["Huyết Ma", "A", "HP dưới 50% thì sát thương tăng dần, tối đa +50% ở 10% HP; HP < 30% hút 5% sát thương thành máu"]],
	"tho-ren": [["Bậc Thầy Rèn", "B", "+15% tỉ lệ cường hoá; thất bại 30% hoàn lại đá; L Rèn Nóng (600 giây): lần cường hoá kế tiếp +30%"], ["Thần Tượng", "A", "cường hoá tối đa +18; chế được đồ Cam ở Xưởng Rèn"]],
	"khuu-giac": [["Mũi Chó Săn", "B", "rương ẩn 50 m, Di tích 25%; L Đánh Hơi (120 giây): hiện mọi rương ẩn và Di tích trên bản đồ 20 giây"], ["Thợ Săn Kho Báu", "A", "thêm loại Rương Vàng (30% đồ Tím); rương ẩn mỗi map 6 → 10"]],
	"kiem-tam": [["Kiếm Ý", "A", "đòn thứ 4 ×2; Nhất Kiếm Đoạn ×4"], ["Kiếm Thánh Chi Tâm", "S", "mỗi đòn chém 20% chém kép; L Vạn Kiếm Quy Tông (45 giây): 12 nhát chém diện rộng 12 m trong 1,5 giây, mỗi nhát ×0,8"]],
	"thao-duoc": [["Dược Sư", "A", "bình máu +50%; chế Thuốc Cuồng Nộ (+15% Tấn công 60 giây) từ 3 thảo dược"], ["Thần Y", "S", "hồi máu vượt tối đa thành khiên (tối đa 30% HP); L Hồi Xuân (60 giây): hồi 60% HP, xoá mọi hiệu ứng xấu"]],
	"trai-tim": [["Lãnh Chúa", "A", "+1 hàng chờ xây; xây nhanh 40%"], ["Vương Giả", "S", "sản lượng lãnh địa +25%; L Chiếu Chỉ (600 giây): hoàn thành mọi công trình đang xây"]],
	"thuan-thu": [["Ngự Thú Sư", "S", "3 thú cưng; thu phục được quái tinh anh dưới 10% HP"], ["Vạn Thú Chi Vương", "SS", "4 thú; thu phục được 1 boss hiếm; thú cưng lên cấp theo nhân vật"]],
	"mat-ung": [["Thiên Nhãn", "S", "nhìn xuyên 4 ô; +15% chí mạng; thấy quái tàng hình"], ["Toàn Tri", "SS", "mọi ô trong lưới khai phá lộ sự kiện; chí mạng vào quái đang choáng +30%"]],
	"hap-huyet": [["Huyết Tộc", "S", "hút 12%; máu hút vượt tối đa thành khiên (tối đa 20% HP)"], ["Huyết Đế", "SS", "hút 15%; L Huyết Hải (60 giây): 6 giây mọi sát thương gây ra hồi 50%"]],
	"ban-tay-vang": [["Điểm Kim", "S", "Tinh Kim 30%; bán đồ +50% vàng"], ["Thần Tài", "SS", "phân rã 10% ra 1 Thiên Phú Tinh Hoa; lãnh địa +20% vàng"]],
	"ngu-hanh": [["Ngũ Hành Hợp Nhất", "SS", "khắc hệ +50%; mỗi đòn mang 2 hệ"], ["Hỗn Độn Linh Căn", "SSS", "đòn đánh tự chọn hệ khắc quái; mỗi lần đổi hệ đều kích Bộc Phá"]],
	"thoi-gian-ngung-dong": [["Thời Không Đoạn", "SS", "ngưng 5 giây, hồi 75 giây; quái bị ngưng nhận +20% sát thương"], ["Thời Gian Chi Chủ", "SSS", "thêm Tua Ngược — khi HP về 0, quay về trạng thái 5 giây trước (300 giây hồi)"]],
	"bay-dan": [["Quân Đoàn Bóng Tối", "SS", "20% thành lính, tối đa 15, sống 90 giây"], ["Minh Vương", "SSS", "boss bị hạ có 50% thành lính bóng tối tinh anh giữ 1 kỹ năng của boss, sống tới khi bị hạ"]],
	"thien-menh": [["Khai Thiên Tích Địa", "SSS", "mỗi Đuốc dọn thêm 4 ô; ô chiếm được +40% tài nguyên; lưới khai phá mỗi map thêm 1 vòng"]],
	"long-mach": [["Tổ Long", "SSS", "Long Mạch Đàn +20%; mỗi trận boss gọi 1 lần Long Hồn đánh cùng 20 giây"]],
	"dao-tac": [],
}
## Điều kiện mỗi bậc (05 mục 1.3).
const EVOLUTION_REQ := "Thiên phú Lv10 + nhiệm vụ tiến hoá + 1 Tinh Hoa Tiến Hoá (rơi từ boss hiếm)"
const EVOLUTION_REQ_F := "Thiên phú Lv10 + chuỗi nhiệm vụ “Phế Vật Nghịch Thiên” (Trưởng làng)"


## TP-41: giá trị hiệu ứng chính để hiển thị — [mẫu câu, giá trị Lv1, giá trị Lv10] (tài liệu 05 mục 2.1).
## Code dùng cùng các mốc này qua lv_value() tại chỗ áp dụng (D14).
const MAIN_SCALE := {
	"than-the": ["+%s%% HP tối đa", 8.0, 12.0],
	"tay-nhanh": ["+%s%% tốc đánh", 5.0, 7.5],
	"may-man": ["+%s điểm %% rơi đồ và rơi đá", 5.0, 7.5],
	"chan-khong": ["+%s%% tốc chạy khi không giao chiến", 10.0, 15.0],
	"huyet-chien": ["HP < 30%%: +%s%% sát thương", 20.0, 30.0],
	"tho-ren": ["+%s%% tỉ lệ cường hoá", 10.0, 15.0],
	"khuu-giac": ["Thấy rương ẩn trong %s m", 30.0, 45.0],
	"kiem-tam": ["Đòn thứ 5 ×%s sát thương", 2.0, 2.5],
	"thao-duoc": ["Bình máu hồi thêm %s%%", 30.0, 45.0],
	"trai-tim": ["Xây nhanh %s%%", 25.0, 37.5],
	"thuan-thu": ["Thu phục dưới %s%% HP", 10.0, 15.0],
	"mat-ung": ["+%s%% chí mạng", 10.0, 15.0],
	"hap-huyet": ["%s%% sát thương thành máu", 8.0, 12.0],
	"ban-tay-vang": ["%s%% thêm 1 Tinh Kim khi phân rã", 20.0, 30.0],
	"ngu-hanh": ["Khắc hệ +%s%%", 30.0, 40.0],
	"thoi-gian-ngung-dong": ["Ngưng Đọng %s giây", 3.0, 4.5],
	"bay-dan": ["%s%% quái bị hạ thành lính bóng tối", 15.0, 22.5],
	"thien-menh": ["Sản lượng lãnh địa +%s%%", 20.0, 30.0],
	"long-mach": ["Long Mạch Đàn +%s%% Tấn công và HP", 10.0, 15.0],
	"dao-tac": ["Tỉ lệ cướp thuộc tính ×%s", 1.0, 1.5],
}


static func main_effect_text(talent_id: String, lv: int) -> String:
	if not MAIN_SCALE.has(talent_id):
		return ""
	var m: Array = MAIN_SCALE[talent_id]
	var v := lv_value(m[1], m[2], lv)
	var txt := str(snappedf(v, 0.1)).trim_suffix(".0").replace(".", ",")
	return str(m[0]) % txt


## TP-41 (Q17): hiệu ứng chính nội suy tuyến tính từ giá trị Lv1 tới Lv10 (tài liệu 05 mục 2.1).
static func lv_value(v1: float, v10: float, lv: int) -> float:
	return v1 + (v10 - v1) * float(clampi(lv, 1, MAX_TALENT_LEVEL) - 1) / float(MAX_TALENT_LEVEL - 1)


static func rank_index(rank: String) -> int:
	return RANK_ORDER.find(rank)


static func rank_color(rank: String) -> Color:
	return Color(RANK_HEX[rank])


static func get_talent(id: String) -> Dictionary:
	for t in LIST:
		if t.id == id:
			return t
	push_error("Không có Thiên phú: %s" % id)
	return LIST[0]


static func group_name(t: Dictionary) -> String:
	return GROUP_NAMES[t.group]


static func has_skill(t: Dictionary) -> bool:
	return t.has("skill")


static func count_in_rank(rank: String) -> int:
	var n := 0
	for t in LIST:
		if t.rank == rank:
			n += 1
	return n


## TL-01: trọng số từng Thiên phú = trọng số hạng / số Thiên phú cùng hạng.
static func roll_weight(t: Dictionary) -> float:
	return RANK_WEIGHT[t.rank] / count_in_rank(t.rank)


## TL-14: Thiên phú `talent_id` ở cấp `level` đã mở hiệu ứng phụ `tier` (1 = cấp 5, 2 = cấp 10) của nhóm `group` chưa.
static func has_sub(talent_id: String, level: int, group: String, tier: int) -> bool:
	if talent_id == "":
		return false
	return get_talent(talent_id).group == group and level >= tier * 5


static func level_cost(level: int) -> int:
	if level < 1 or level >= MAX_TALENT_LEVEL:
		return 0
	return LEVEL_COST[level - 1]
