extends RefCounted
## C1-11, C1-12: thoại và chuỗi nhiệm vụ chương 1 (docs/08-chuong-1-hoan-chinh.md mục 3.1).
## "{name}" trong lời thoại được thay bằng tên nhân vật; người nói "{name}" là nhân vật chính.

const ELDER := "Trưởng làng Thạch Lão"
const LAC := "Đội trưởng Lạc Phong"
const MAC := "Thương nhân Mạc Tam"
const SMITH := "Thợ rèn Thiết Ngưu"

## id → [[người nói, lời], ...]
const DIALOGS := {
	"q1": [
		[ELDER, "Quái Sương tràn tới cổng làng! {name}, Thiên phú của con vừa thức tỉnh — ra cổng đánh lui chúng!"],
		["{name}", "Con đi ngay!"],
	],
	"q2": [[ELDER, "Khá lắm. Giờ thử dùng kỹ năng — phím 1 đến 4. Kỹ năng tốn MP, MP tự hồi theo thời gian."]],
	"q3": [[ELDER, "Quái vung đòn luôn có vòng đỏ báo trước. Bấm Space để né lăn. Né đúng khoảnh khắc đòn tới là né Hoàn hảo — thời gian như chậm lại."]],
	"q4": [
		[ELDER, "Cầm lấy món này, của ta thời còn trẻ. Mở túi đồ (phím I) mà mặc vào."],
		["{name}", "Đa tạ Trưởng làng!"],
	],
	"q5": [[ELDER, "Rừng Sương phía đông đầy quái. Đánh chúng để mạnh lên — nhưng càng đi sâu về phía đông, quái càng mạnh."]],
	"q6": [[ELDER, "Mỗi lần lên cấp con được 5 điểm tiềm năng. Nhấn C để cộng, hoặc bấm Tự cộng điểm nếu chưa biết chọn gì."]],
	"q7": [[ELDER, "Đuốc Khai Giới xua được sương Hư Vô. Mở bản đồ khai phá (phím M) và dọn sương những ô đất quanh làng."]],
	"q8": [[ELDER, "Đất đã chiếm phải dựng công trình mới sinh lợi. Chiếm một Rừng gỗ và xây Xưởng Gỗ — gỗ và vàng sẽ về đều, kể cả khi con nghỉ ngơi."]],
	"q9": [[ELDER, "Kẻ cầm đầu bầy sói là Sói Chúa Hư Vô, ở hang phía đông. Đạt cấp 5 và chiếm 6 ô đất, sương chắn hang sẽ yếu đi."]],
	"q10": [
		[ELDER, "Sương trước hang đã mỏng! Nhớ lời ta: đánh vào thanh Phá Thế, khi nó vỡ con thú sẽ choáng."],
		["{name}", "Lần này con sẽ không lùi bước."],
	],
	"boss": [
		["Sói Chúa Hư Vô", "Grừừ… mùi Thiên phú còn non… Ta sẽ nuốt trọn nó!"],
	],
	"boss2": [["Sói Chúa Hư Vô", "Sương ơi, che ta đi! Bầy con đâu, xé xác nó!"]],
	"q11": [
		[ELDER, "Con đã cứu cả làng. Nhưng sâu trong Lõi Sương, sương còn dày đặc… Mở bản đồ lục địa (phím N) mà tới đó."],
		[ELDER, "…Lạ thật. Ánh sáng quanh con vừa rung lên như có hai Thiên phú cùng thở."],
		["{name}", "(Trong ngực, có thứ gì đó khẽ động đậy.)"],
	],
	"core": [["{name}", "Sương ở đây đặc quá… Có thứ gì đó cổ xưa đang thở giữa rừng."]],
	"rare_boss": [["Lão Thụ Sương Mù", "Kẻ… nào… dám giẫm lên… rễ của ta?"]],
	"rare_boss_down": [["Lão Thụ Sương Mù", "Rễ… khô rồi… Hạt giống… trao cho… kẻ mạnh…"]],
	"rare_bach_ho": [["Bạch Hổ Phong Vân", "Gràoo! Gió Mắt Bão là của ta — kẻ yếu bị thổi bay như lá!"]],
	"rare_bach_ho_down": [["Bạch Hổ Phong Vân", "Gió… đã đổi chiều… Ngươi… xứng với nanh vuốt của ta…"]],
	"merchant": [["Thương nhân lữ hành", "Ha ha, khách quý! Lều ta dựng ở làng một canh giờ thôi, hàng tốt không chờ ai đâu."]],
	"done": [[ELDER, "Chương 1 khép lại. Đồng Bằng Gió Hú đang chờ — nhưng hãy cứ luyện thêm ở Lõi Sương đã."]],
	# ---------------------------------------------------------------- chương 2 (03-mvp-spec mục 6.4)
	"r2_arrive": [["{name}", "Gió ở đây thổi như muốn hất văng người. Thành Biên Đài ở ngay phía tây — tới gặp Liên minh thôi."]],
	"lac_join": [
		[LAC, "Khai Giới Giả từ Thanh Thạch? Tin con hạ Sói Chúa đã tới tận đây. Liên minh Khai Giới chào đón con."],
		[LAC, "Vùng đất quanh thành là lãnh địa đầu tiên của con. Dọn sương, dựng mỏ, đánh lui lũ đánh thuê Hư Vô."],
	],
	"lac_q2": [[LAC, "Lũ lính đánh thuê mang khiên — đánh từ bên hông hoặc sau lưng chúng. Hạ 30 tên cho ta xem."]],
	"lac_q3": [[LAC, "Giỏi. Giờ chiếm lấy 6 ô đất quanh thành (phím M). Hạng Khai Giới Giả của con sẽ lên theo đất chiếm được."]],
	"lac_q4": [[LAC, "Có tin đồn gián điệp Hư Vô Giáo trà trộn trong thành… Hỏi thử Mạc Tam — hắn buôn bán khắp nơi, nghe được nhiều chuyện."]],
	"mac_greet": [[MAC, "Hàng tốt, giá mềm! Khách quý cứ xem tự nhiên."]],
	"mac_reveal": [
		["{name}", "Mạc Tam, ông có nghe tin gì về gián điệp Hư Vô Giáo không?"],
		[MAC, "…Ha. Ngươi hỏi nhiều quá rồi, Khai Giới Giả."],
		[MAC, "Chủ nhân Huyền Ảnh sẽ rất vui khi nhận được Thiên phú của ngươi. Hẹn gặp ở Mắt Bão!"],
		[LAC, "Hắn chạy về Phủ Huyền Ảnh ở Mắt Bão! Đuổi theo — kẻ đứng sau là Tướng Gián Điệp Huyền Ảnh."],
	],
	"lac_q5": [[LAC, "Phủ Huyền Ảnh ở cuối Mắt Bão. Nhớ lời ta: chỉ bản thật mới có bóng."]],
	"ch2_done": [
		[LAC, "Huyền Ảnh đã ngã! Liên minh nợ con một ân lớn."],
		["{name}", "(Khi Huyền Ảnh tan biến, hắn thì thầm: “Mảnh linh hồn… của Chủ nhân…” Thiên phú trong ngực lại rung lên.)"],
	],
	"smith": [[SMITH, "Đá với Sắt từ mỏ của ngươi ấy hả? Mang tới đây, ta rèn thành Đá Cường Hoá, cả Tinh Kim nữa."]],
}


## Nhiệm vụ chính chương 2 (03 mục 6.4). Bước lưu ở profile.quest.ch2 (0 = chưa tới vùng 2, 6 = xong).
const QUESTS2 := [
	{"title": "Gia nhập Liên minh", "hint": "Tới Thành Biên Đài, đứng cạnh Lạc Phong bấm E.", "type": "talk_lac", "need": 1, "reward": {"gold": 200}},
	{"title": "Dẹp loạn Cửa Gió", "hint": "Hạ quái ở vùng 2. Lính khiên: đánh từ bên hông hoặc sau lưng.", "type": "kills2", "need": 30, "reward": {"exp": 3000}},
	{"title": "Lãnh địa đầu tiên", "hint": "M mở Bản đồ khai phá vùng 2, chiếm 6 ô đất.", "type": "tiles2", "need": 6, "reward": {"stones": 5}},
	{"title": "Tin đồn trong thành", "hint": "Hỏi Thương nhân Mạc Tam (E) về gián điệp.", "type": "talk_mac", "need": 1, "reward": {}},
	{"title": "Phủ Huyền Ảnh", "hint": "N → Mắt Bão. Hạ Tướng Gián Điệp Huyền Ảnh — chỉ bản thật có bóng.", "type": "boss2", "need": 1, "reward": {}},
]
const DONE2 := 6


static func quest2(step: int) -> Dictionary:
	return QUESTS2[step - 1] if step >= 1 and step <= QUESTS2.size() else {}

## type: kill_quest (hạ quái nhiệm vụ) · skill · dodge · equip_weapon · level · spend_points · reveal · build ·
## boss_unlocked · boss · enter_map. need = số cần đạt (với kiểu đếm).
## reward: {exp, gold, potions, torches, stones}
const QUESTS := [
	{"title": "Quái Sương tấn công làng!", "hint": "Ra cổng làng. Chuột trái / J để đánh.", "type": "kill_quest", "need": 3,
		"reward": {"exp": 60, "gold": 20}},
	{"title": "Học kỹ năng", "hint": "Phím 1–4 dùng kỹ năng (tốn MP).", "type": "skill", "need": 2, "reward": {"exp": 40}},
	{"title": "Học né", "hint": "Space né lăn; né đúng lúc đòn tới = Hoàn hảo.", "type": "dodge", "need": 1, "reward": {"exp": 40}},
	{"title": "Món quà của Trưởng làng", "hint": "I mở túi đồ, chọn vũ khí, bấm Mặc.", "type": "equip_weapon", "need": 1, "reward": {}},
	{"title": "Vào Rừng Sương", "hint": "Đánh quái phía đông làng để lên cấp.", "type": "level", "need": 3, "reward": {"gold": 100}},
	{"title": "Cộng điểm tiềm năng", "hint": "C mở Chỉ số — cộng hết điểm (hoặc Tự cộng điểm).", "type": "spend_points", "need": 1,
		"reward": {"potions": 2}},
	{"title": "Dọn sương", "hint": "M mở Bản đồ khai phá, dùng Đuốc lên ô kề lãnh địa.", "type": "reveal", "need": 3,
		"reward": {"torches": 1, "exp": 80}},
	{"title": "Xây công trình đầu tiên", "hint": "Chiếm Rừng gỗ (30 vàng) — Xưởng Gỗ tự xây.", "type": "build", "need": 1,
		"reward": {"gold": 150}},
	{"title": "Chuẩn bị đánh boss", "hint": "Đạt cấp 5 và chiếm 6 ô đất.", "type": "boss_unlocked", "need": 1, "reward": {"stones": 3}},
	{"title": "Sói Chúa Hư Vô", "hint": "Vào hang phía đông. Phá thanh Phá Thế để boss choáng.", "type": "boss", "need": 1, "reward": {}},
	{"title": "Lõi Sương", "hint": "N mở bản đồ lục địa → Lõi Sương → Lên đường.", "type": "enter_map", "need": 1, "reward": {"exp": 200}},
]
const DONE_STEP := 12


static func quest(step: int) -> Dictionary:
	return QUESTS[step - 1] if step >= 1 and step <= QUESTS.size() else {}


static func reward_text(r: Dictionary) -> String:
	var parts := PackedStringArray()
	for pair in [["exp", "%d EXP"], ["gold", "%d vàng"], ["potions", "%d bình máu"], ["torches", "%d Đuốc"], ["stones", "%d Đá Cường Hoá"]]:
		if r.has(pair[0]):
			parts.append(pair[1] % int(r[pair[0]]))
	return ", ".join(parts)
