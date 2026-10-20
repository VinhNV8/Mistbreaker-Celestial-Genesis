extends RefCounted
## C1-03 (Spec_Notes N6): 8 loại tài nguyên — tên, icon (assets/icons/res-<icon>.png), chú thích.

const LIST := [
	{"id": "gold", "icon": "gold", "name": "Vàng",
		"desc": "Tiền tệ chính. Rơi từ quái, rương, Xưởng Gỗ. Dùng để xây công trình, cường hoá, mua đồ ở cửa hàng."},
	{"id": "wood", "icon": "wood", "name": "Gỗ",
		"desc": "Xưởng Gỗ trên ô Rừng gỗ sản xuất (cả khi offline, tối đa 12 giờ). Dùng để xây công trình lãnh địa."},
	{"id": "torches", "icon": "torch", "name": "Đuốc Khai Giới",
		"desc": "Dọn sương 1 ô đất trên Bản đồ khai phá (phím M). Tự hồi theo thời gian, tối đa 10; hạ quái tinh anh +1."},
	{"id": "stones", "icon": "stone", "name": "Đá Cường Hoá",
		"desc": "Cường hoá trang bị +1 → +15. Rơi từ quái, rương; phân rã đồ cũ để lấy thêm."},
	{"id": "essence", "icon": "essence", "name": "Thiên Phú Tinh Hoa",
		"desc": "Luyện cấp Thiên phú ở Đền Thiên Phú (phím T). Rơi từ boss (Sói Chúa 3, Lão Thụ 5)."},
	{"id": "tinh_kim", "icon": "tinh_kim", "name": "Tinh Kim",
		"desc": "Kim loại hiếm, cần để cường hoá từ +10 trở lên. Rơi từ boss; Bàn Tay Vàng có khi phân rã."},
	{"id": "herbs", "icon": "herb", "name": "Thảo dược",
		"desc": "Hái ngoài Rừng Sương hoặc từ Vườn Thảo Dược. Đủ 2 thảo dược tự chế 1 bình máu."},
	{"id": "potions", "icon": "potion", "name": "Bình máu",
		"desc": "Phím Q hồi 35% HP, hồi chiêu 8 giây, mang tối đa 5. Mua ở cửa hàng làng (phím E)."},
]


static func value(p, id: String) -> int:
	return int(p.get(id))


static func info(id: String) -> Dictionary:
	for r in LIST:
		if r.id == id:
			return r
	return {}
