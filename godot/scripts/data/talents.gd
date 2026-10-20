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
		"description": "Mỗi lần hạ boss, sao chép 1 kỹ năng của boss đó.",
		"skill": {"name": "Kỹ năng sao chép", "cd": 8.0, "text": "Dùng kỹ năng boss đã sao chép."}},
]


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
