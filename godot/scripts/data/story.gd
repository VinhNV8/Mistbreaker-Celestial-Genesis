extends RefCounted
## C1-11, C1-12: thoại và chuỗi nhiệm vụ chương 1 (docs/08-chuong-1-hoan-chinh.md mục 3.1).
## "{name}" trong lời thoại được thay bằng tên nhân vật; người nói "{name}" là nhân vật chính.

const ELDER := "Trưởng làng Thạch Lão"
const LAC := "Đội trưởng Lạc Phong"
const MAC := "Thương nhân Mạc Tam"
const SMITH := "Thợ rèn Thiết Ngưu"
## M6 (docs/10): Trại Cát Đỏ
const SALAO := "Học giả Sa Lão"
const AMOC := "Người dẫn đường A Mộc"
const THACH := "Hộ vệ Thạch Thủ"
## M7 (docs/11): Làng Chài Lau
const NGU := "Trưởng làng Lão Ngư"
const LAM := "Lam Nhi"
const TQ := "Tinh Quang Sứ"
const QUEEN := "Nữ Vương Phệ Mộng"
## M8 (docs/12): Trại Tro Hồng
const XICH := "Trưởng tộc Xích Đồng"
const KIMPHU := "Chưởng quỹ Kim Phú"
const LIET := "Kiếm khách Liệt Diễm"
const TIEUHOA := "Tiểu Hoả"
const DRAGON := "Viêm Long"

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
	# ---------------------------------------------------------------- M6: chương 3 Sa Mạc Lãng Quên (docs/10 mục 5)
	"r3_arrive": [
		["{name}", "Nắng như đổ lửa… Lạc Phong nói học giả Sa Lão đang cắm trại ở Rìa Cát Đỏ, ông ấy biết về Khai Giới Giả đời đầu."],
		["{name}", "(Ban ngày nắng gắt rút máu — đứng trong bóng râm của tảng đá lớn, hoặc uống nước ở ốc đảo.)"],
	],
	"salao_meet": [
		[SALAO, "Lại một Khai Giới Giả… Thiên phú trong ngực con đang rung, phải không? Ta đã thấy cảm giác ấy trên những phiến đá cổ."],
		[SALAO, "Di tích của Khai Giới Giả đời đầu nằm sâu trong sa mạc. Nhưng bản đồ đã bị quái cát xé vụn — hạ chúng, gom lại các mảnh."],
	],
	"salao_q2": [[SALAO, "Các mảnh bản đồ nằm trong bụng lũ quái cát. Cẩn thận Rắn Đồi Cát — vệt cát chuyển động là nó sắp trồi lên."]],
	"salao_q3": [
		[SALAO, "Bản đồ chỉ ba ốc đảo ở Ốc Đảo Lãng Quên. Nước ở đó có ký ức — uống ở cả ba, con sẽ thấy đường tới Di tích."],
		[AMOC, "Nước ốc đảo còn che con khỏi nắng một phút. Đừng để đêm xuống giữa đồng cát — quái mạnh hơn hẳn."],
	],
	"salao_q4": [[SALAO, "Ba ốc đảo đều chỉ về một hướng: Di Tích Khai Giới Giả. Tìm Bia Khai Giới Giả ở đó và đọc nó."]],
	"stele3_read": [
		["Bia Khai Giới Giả", "\"Một nghìn năm trước, kẻ mạnh nhất trong chúng ta muốn đoạt chính Thiên phú của Thiên Đạo.\""],
		["Bia Khai Giới Giả", "\"Trời nứt làm chín. Sương Hư Vô tràn ra từ vết nứt — đó là Thiên Liệt. Hắn không chết; hắn mất một mảnh linh hồn.\""],
		["Bia Khai Giới Giả", "\"Kẻ nào mang mảnh ấy trong ngực, hãy cẩn thận: hắn sẽ tới đòi lại.\""],
		["{name}", "(Mảnh thứ hai… trong ngực mình?) Phía đông bia là Sào Huyệt Sa Hoàng — con bọ cạp canh giữ lối ra di tích."],
	],
	"salao_q5": [[SALAO, "Sa Hoàng chui xuống cát khi bị thương nặng. Nhìn vết cát mà né — và đừng đứng yên trước đuôi độc của nó."]],
	"sa_hoang_intro": [["Bọ Cạp Sa Hoàng", "Ssss… Mùi Thiên phú. Ta sẽ chôn ngươi cùng những kẻ đời đầu!"]],
	"sa_hoang_down": [
		[SALAO, "Sa Hoàng đã ngã! Lối ra di tích mở rồi."],
		[THACH, "Ta đã canh di tích này ba mươi năm để chờ một người như con. Khi đủ cấp 30, tới gặp ta — ta sẽ dẫn con qua Thử Thách Chuyển Chức."],
	],
	"thach_wait": [[THACH, "Chưa được. Hạ Bọ Cạp Sa Hoàng và đạt cấp 30 rồi hãy quay lại."]],
	"job_done": [
		[THACH, "Từ hôm nay, con không còn là tân binh. Mang danh xưng mới mà đi tiếp."],
		[SALAO, "Mảnh thứ hai, Thiên Liệt… Hãy tới Đầm Lầy U Minh ở phía nam. Nghe nói có kẻ đang săn Thiên phú của người khác ở đó."],
	],
	"amoc_shop": [[AMOC, "Nước, thuốc, đá cường hoá — sa mạc này không cho không ai cái gì đâu."]],
	"rare_nhan_su": [["Nhân Sư Đá", "Kẻ nào bước vào Di tích phải trả lời câu đố của ta. Sai — hoá đá muôn đời!"]],
	"rare_nhan_su_down": [["{name}", "(Nhân Sư vỡ vụn, để lại một viên đá hình con mắt vẫn còn sáng.)"]],
	"ch3_done": [[SALAO, "Chương sa mạc đã khép lại. Nhưng câu chuyện của Thiên Liệt mới chỉ bắt đầu."]],
	# ---------------------------------------------------------------- M7: chương 4 Đầm Lầy Mộng (docs/11 mục 5)
	"r4_arrive": [
		["{name}", "Sương ở đây ướt và nặng mùi bùn. Sa Lão nói có kẻ đang săn Thiên phú người khác ở Đầm Lầy U Minh…"],
		["{name}", "(Lội nước đầm lâu sẽ trúng độc tích luỹ — đứng trên đất khô để độc tan dần, hoặc mua Thuốc Giải.)"],
	],
	"ngu_meet": [
		[NGU, "Khai Giới Giả! Đã ba đứa trẻ trong làng ngủ mà không tỉnh lại — Thiên phú của chúng biến mất."],
		[LAM, "Ta là Lam Nhi. Thiên phú của ta là Tiếng Gọi Thủy Triều, nghe được đầm lầy thì thầm. Ta sẽ dẫn đường cho ngươi."],
	],
	"ngu_shop": [[NGU, "Thuốc Giải cho độc đầm, Đuốc Lửa cho thứ quái sống dưới nước — mua đi, đừng tiếc vàng."]],
	"lam_meet": [[LAM, "Lũ quái trong lau sậy đều bị một giọng hát điều khiển. Cùng ta dẹp chúng — ta muốn nghe rõ giọng hát đó."]],
	"lam_hint": [[LAM, "Nghe kìa… có tiếng ru từ phía Đầm Sâu. Cẩn thận ảo ảnh — chúng tan ngay khi bị đánh."]],
	"lam_taken": [
		[LAM, "Giọng hát… gần lắm rồi… ta… buồn ngủ quá…"],
		[QUEEN, "Thêm một Thiên phú ngọt ngào. Ngủ đi, bé con — ngươi sẽ mơ mãi mãi."],
		["{name}", "Lam Nhi! (Cô ấy biến mất cùng sương tím. Thiên phú của cô bị đoạt.) Phải tìm dấu vết ở Đầm Sâu!"],
	],
	"pods_done": [[TQ, "Năm Bọc Mộng là ký ức của Lam Nhi. Chúng chỉ về Cung Mộng — Nữ Vương đang giữ cô ở đó."]],
	"queen_gate": [[TQ, "Cửa Cung Phệ Mộng đã mở. Nếu bị kéo vào giấc mơ, hãy phá các Mộng Châu — trong mơ, trái là phải."]],
	"lam_saved": [
		[LAM, "Ta… tỉnh rồi? Thiên phú của ta… đã trở về!"],
		[LAM, "Nữ Vương không phải chủ. Ả phục vụ một kẻ KHÔNG có Thiên phú — hắn cướp Thiên phú của người khác để sống."],
		[TQ, "Ma Tôn Vô Diện… Và Thiên phú trong ngực ngươi, Khai Giới Giả, rung lên vì hắn. Tới gặp ta — đã đến lúc tiến hoá."],
	],
	"tq_intro": [[TQ, "Thánh Đường Tinh Quang có thể giúp Thiên phú vượt giới hạn — khi ngươi đủ Lv10, có Tinh Hoa Tiến Hoá và đã cứu Lam Nhi."]],
	"tq_wait": [[TQ, "Chưa đủ. Thiên phú cần Lv10 và 1 Tinh Hoa Tiến Hoá (rơi từ boss hiếm)."]],
	"lam_after": [[LAM, "Ta sẽ ở lại giữ làng. Nếu tìm ra Ma Tôn Vô Diện — hãy gọi ta."]],
	"ch4_done": [[TQ, "Thiên phú đã tiến hoá. Núi Viêm Long ở phía nam đang bốc cháy — Thương hội có điều gì đó che giấu."]],
	"rare_thuy_quai": [["Thuỷ Quái Thất Đầu", "Bảy cái đầu, bảy cái miệng đói! Chặt một — ta mọc lại hai!"]],
	"rare_thuy_quai_down": [["{name}", "(Bảy cái đầu chìm xuống đầm. Một mảnh vảy sáng xanh nổi lên mặt nước.)"]],
	# ---------------------------------------------------------------- chương 5 (docs/12 C5-40…44)
	"r5_arrive": [
		["{name}", "Không khí bỏng rát, tro bay như tuyết. Núi Viêm Long đang thở…"],
		["{name}", "(Tránh dung nham. Ở Sườn Dung Nham trở lên, núi lửa phun theo chu kỳ — nhìn vòng đỏ dưới đất mà né.)"],
	],
	"xich_meet": [
		[XICH, "Khai Giới Giả! Tộc Hỏa Sơn rèn sắt dưới chân núi này đã ngàn năm. Gần đây Viêm Long thức giấc, núi phun liên tục."],
		[XICH, "May có Thương hội Kim Luân giúp dựng trại, đổi quặng lấy lương thực. Chưởng quỹ Kim Phú đang cần người dọn đường cho đoàn buôn."],
	],
	"kim_task": [[KIMPHU, "Đoàn buôn của ta không qua nổi lũ Thằn Lằn với Người Đá. Dẹp giúp 30 con — Thương hội không quên ân tình đâu."]],
	"xich_land": [[XICH, "Muốn trụ được ở đây phải có đất. Chiếm 6 ô quanh trại, dựng một Mỏ Tinh Thạch — tinh thể lửa này chỉ núi Viêm Long mới có."]],
	"kim_betray": [
		[KIMPHU, "…Ngươi dựng mỏ trên đất của Thương hội à? Tiếc thật. Ta đã định để ngươi sống lâu hơn."],
		[KIMPHU, "Hư Vô Giáo trả giá gấp mười cho vũ khí rèn bằng Tinh Thạch. Còn Long Tâm của Viêm Long — Chủ nhân muốn nó."],
		[XICH, "Kim Phú! Lính Kim Luân đang kéo tới cổng trại! Khai Giới Giả, giữ cổng giúp ta!"],
	],
	"siege_start": [[XICH, "Chúng tới từ hai hướng! Giữ Cổng Trại — đừng để chúng phá cổng!"]],
	"siege_won": [
		[XICH, "Trại vẫn đứng! Kim Phú chạy lên Miệng Núi Lửa rồi — hắn định đoạt Long Tâm trước khi Viêm Long tỉnh hẳn."],
		[TIEUHOA, "Cửa hàng để cháu trông! Bình Nước Thánh với Tinh Thạch vẫn đổi được như cũ."],
	],
	"siege_lost": [[XICH, "Cổng vỡ rồi… Lùi lại! Nói với ta (E) khi sẵn sàng đánh lại."]],
	"xich_crater": [[XICH, "Lối vào Long Huyệt ở sâu trong Miệng Núi Lửa. Khám phá đủ để tìm ra nó — nhanh lên, trước Kim Phú!"]],
	"dragon_gate": [[LIET, "Ta là Liệt Diễm. Ta canh Long Huyệt hai mươi năm. Đánh vào thanh Phá Thế khi nó đáp xuống — khi nó bay, đứng trên Đá Nổi."]],
	"boss5": [[DRAGON, "Kẻ nhỏ bé… mang mùi của kẻ không mặt. Ta sẽ thiêu sạch mảnh linh hồn trong ngực ngươi!"]],
	"boss5_flood": [[DRAGON, "Núi ơi, dâng lên!"]],
	"dragon_down": [
		[KIMPHU, "Long Tâm! Đưa đây — !"],
		[LIET, "Cút đi, chó săn của Hư Vô Giáo. Lần sau ta không tha."],
		["{name}", "(Long Tâm nóng rực trong tay. Trong ánh lửa, bóng của chính mình hiện lên… nhưng cái bóng không có mặt.)"],
	],
	"liet_job": [[LIET, "Ngươi đã đủ sức đi tiếp con đường của mình. Chọn đi — mỗi con đường chỉ đi được một lần."]],
	"liet_wait": [[LIET, "Chưa phải lúc. Cấp 60, đã chuyển chức một lần, hạ Viêm Long và mang 30 Tinh Thạch tới đây."]],
	"ch5_done": [[XICH, "Tộc Hỏa Sơn nợ ngươi. Băng Nguyên Bắc Cực ở phía bắc — nghe nói ở đó, bóng tối biết nói tiếng người."]],
	"xich_idle": [[XICH, "Lò rèn vẫn đỏ. Lính Kim Luân còn lảng vảng — giữ trại cho tốt."]],
	"kim_shop": [[KIMPHU, "Bình Nước Thánh, Tinh Thạch — Thương hội có đủ. Giá cả phải chăng!"]],
	"tieu_hoa_shop": [[TIEUHOA, "Bình Nước Thánh dập được lửa Phượng Hoàng đó! Cần gì cứ bấm E."]],
	"raid_warn": [[XICH, "Lính Kim Luân lại kéo tới! Về trại giữ cổng!"]],
	"rare_phuong_hoang": [["Phượng Hoàng Tro", "Lửa không bao giờ chết. Ta đã tái sinh chín lần trên miệng núi này!"]],
	"rare_phuong_hoang_down": [["{name}", "(Tro tàn rơi lả tả. Lần này ngọn lửa không bùng lên nữa — chỉ còn lại một chiếc lông đỏ rực.)"]],
}


## Nhiệm vụ chính chương 2 (03 mục 6.4). Bước lưu ở profile.quest.ch2 (0 = chưa tới vùng 2, 6 = xong).
const QUESTS2 := [
	{"title": "Gia nhập Liên minh", "hint": "Tới Thành Biên Đài, đứng cạnh Lạc Phong bấm E.", "type": "talk_lac", "need": 1, "reward": {"exp": 5000, "gold": 200}},
	{"title": "Dẹp loạn Cửa Gió", "hint": "Hạ quái ở vùng 2. Lính khiên: đánh từ bên hông hoặc sau lưng.", "type": "kills2", "need": 30, "reward": {"exp": 15000}},
	{"title": "Lãnh địa đầu tiên", "hint": "M mở Bản đồ khai phá vùng 2, chiếm 6 ô đất.", "type": "tiles2", "need": 6, "reward": {"exp": 20000, "stones": 5}},
	{"title": "Tin đồn trong thành", "hint": "Hỏi Thương nhân Mạc Tam (E) về gián điệp.", "type": "talk_mac", "need": 1, "reward": {"exp": 25000}},
	{"title": "Phủ Huyền Ảnh", "hint": "N → Mắt Bão. Hạ Tướng Gián Điệp Huyền Ảnh — chỉ bản thật có bóng.", "type": "boss2", "need": 1, "reward": {"exp": 30000}},
]
const DONE2 := 6

## M7 (docs/11 C4-41): nhiệm vụ chính chương 4. Bước lưu ở profile.quest.ch4 (0 = chưa tới vùng 4, 7 = xong).
## Thưởng EXP ≈ 25% EXP từ cấp 30 lên 45 (4,6 triệu × 25% ≈ 1,15 triệu).
const QUESTS4 := [
	{"title": "Làng Chài Lau", "hint": "Tới Làng Chài Lau (Bãi Lau Mù), đứng cạnh Lão Ngư bấm E.", "type": "talk_ngu", "need": 1, "reward": {"exp": 40000, "gold": 500, "antidotes": 2}},
	{"title": "Tiếng hát trong lau", "hint": "Cùng Lam Nhi hạ 30 quái vùng 4 (ảo ảnh không tính).", "type": "kills4", "need": 30, "reward": {"exp": 120000}},
	{"title": "Ký ức của Lam Nhi", "hint": "N → Đầm Sâu. Phá 5 Bọc Mộng trên các cồn đất (đi tới chạm vào).", "type": "pods4", "need": 5, "reward": {"exp": 180000, "stones": 8}},
	{"title": "Cung Mộng", "hint": "N → Cung Mộng. Khám phá ≥ 40% map để tìm cửa Cung Phệ Mộng.", "type": "explore4", "need": 1, "reward": {"exp": 230000}},
	{"title": "Nữ Vương Phệ Mộng", "hint": "Hạ Nữ Vương ở phía đông Cung Mộng. Trong mơ: phá 3 Mộng Châu.", "type": "boss4", "need": 1, "reward": {"exp": 280000}},
	{"title": "Tiến hoá Thiên phú", "hint": "Thiên phú Lv10 + 1 Tinh Hoa Tiến Hoá → gặp Tinh Quang Sứ (E) hoặc bảng Thiên phú (T).", "type": "evolve", "need": 1, "reward": {"exp": 300000, "gold": 2000}},
]
const DONE4 := 7


static func quest4(step: int) -> Dictionary:
	return QUESTS4[step - 1] if step >= 1 and step <= QUESTS4.size() else {}


## M8 (docs/12 C5-41): nhiệm vụ chính chương 5. Bước lưu ở profile.quest.ch5 (0 = chưa tới vùng 5, 8 = xong).
## Thưởng EXP ≈ 25% EXP từ cấp 45 lên 60 (9,8 triệu × 25% ≈ 2,45 triệu).
const QUESTS5 := [
	{"title": "Trại Tro Hồng", "hint": "Tới Trại Tro Hồng (Chân Núi Tro), đứng cạnh Xích Đồng bấm E.", "type": "talk_xich", "need": 1, "reward": {"exp": 100000, "gold": 800, "holy_water": 1}},
	{"title": "Dọn đường cho đoàn buôn", "hint": "Hạ 30 quái vùng 5 giúp Kim Phú. Tránh dung nham.", "type": "kills5", "need": 30, "reward": {"exp": 250000}},
	{"title": "Đất dưới chân núi", "hint": "M mở Bản đồ khai phá vùng 5: chiếm 6 ô, có ít nhất 1 Mỏ Tinh Thạch.", "type": "tiles5", "need": 6, "reward": {"exp": 300000, "stones": 8}},
	{"title": "Thương hội phản bội", "hint": "Về Trại Tro Hồng, nói với Xích Đồng (E) rồi giữ Cổng Trại qua 3 đợt lính Kim Luân.", "type": "siege5", "need": 1, "reward": {"exp": 400000, "gold": 2000}},
	{"title": "Miệng Núi Lửa", "hint": "N → Miệng Núi Lửa. Khám phá ≥ 40% map để tìm lối vào Long Huyệt.", "type": "explore5", "need": 1, "reward": {"exp": 400000}},
	{"title": "Viêm Long", "hint": "Hạ Viêm Long ở Long Huyệt (phía đông). Khi dung nham dâng: đứng trên Đá Nổi.", "type": "boss5", "need": 1, "reward": {"exp": 450000, "crystal": 10}},
	{"title": "Chuyển chức lần 2", "hint": "Cấp 60 + 30 Tinh Thạch → gặp Liệt Diễm (E) ở Trại Tro Hồng, chọn 1 trong 2 nhánh.", "type": "job2", "need": 1, "reward": {"exp": 550000, "gold": 3000}},
]
const DONE5 := 8


static func quest5(step: int) -> Dictionary:
	return QUESTS5[step - 1] if step >= 1 and step <= QUESTS5.size() else {}


## M6 (docs/10 C3-41): nhiệm vụ chính chương 3. Bước lưu ở profile.quest.ch3 (0 = chưa tới vùng 3, 7 = xong).
## Thưởng EXP ≈ 25% EXP từ cấp 20 lên 30 (M5-02: 1,2 triệu × 25% ≈ 300.000).
const QUESTS3 := [
	{"title": "Học giả sa mạc", "hint": "Tới Trại Cát Đỏ (Rìa Cát Đỏ), đứng cạnh Sa Lão bấm E.", "type": "talk_salao", "need": 1, "reward": {"exp": 15000, "gold": 300}},
	{"title": "Mảnh bản đồ", "hint": "Hạ 30 quái vùng 3. Đứng trong bóng râm tảng đá để tránh nắng.", "type": "kills3", "need": 30, "reward": {"exp": 35000}},
	{"title": "Ba ốc đảo", "hint": "N → Ốc Đảo Lãng Quên. Uống nước ở cả 3 ốc đảo (đứng trong hồ 1 giây).", "type": "oases", "need": 3, "reward": {"exp": 45000, "potions": 2}},
	{"title": "Bia Khai Giới Giả", "hint": "N → Di Tích Khai Giới Giả. Khám phá ≥ 40% map và tới Bia Khai Giới Giả.", "type": "stele3", "need": 1, "reward": {"exp": 55000, "stones": 6}},
	{"title": "Sào Huyệt Sa Hoàng", "hint": "Hạ Bọ Cạp Sa Hoàng ở phía đông Di tích. Né vết cát khi nó chui xuống.", "type": "boss3", "need": 1, "reward": {"exp": 70000}},
	{"title": "Thử Thách Chuyển Chức", "hint": "Đạt cấp 30, gặp Thạch Thủ ở Trại Cát Đỏ (E) để chuyển chức.", "type": "job", "need": 1, "reward": {"exp": 80000, "gold": 1000}},
]
const DONE3 := 7


static func quest3(step: int) -> Dictionary:
	return QUESTS3[step - 1] if step >= 1 and step <= QUESTS3.size() else {}


static func quest2(step: int) -> Dictionary:
	return QUESTS2[step - 1] if step >= 1 and step <= QUESTS2.size() else {}

## type: kill_quest (hạ quái nhiệm vụ) · skill · dodge · equip_weapon · level · spend_points · reveal · build ·
## boss_unlocked · boss · enter_map. need = số cần đạt (với kiểu đếm).
## reward: {exp, gold, potions, torches, stones}
const QUESTS := [
	{"title": "Quái Sương tấn công làng!", "hint": "Ra cổng làng. Chuột trái / J để đánh.", "type": "kill_quest", "need": 3,
		"reward": {"exp": 80, "gold": 20}},
	{"title": "Học kỹ năng", "hint": "Phím 1–4 dùng kỹ năng (tốn MP).", "type": "skill", "need": 2, "reward": {"exp": 100}},
	{"title": "Học né", "hint": "Space né lăn; né đúng lúc đòn tới = Hoàn hảo.", "type": "dodge", "need": 1, "reward": {"exp": 120}},
	{"title": "Món quà của Trưởng làng", "hint": "I mở túi đồ, chọn vũ khí, bấm Mặc.", "type": "equip_weapon", "need": 1, "reward": {"exp": 150}},
	{"title": "Vào Rừng Sương", "hint": "Đánh quái phía đông làng để lên cấp.", "type": "level", "need": 3, "reward": {"exp": 300, "gold": 100}},
	{"title": "Cộng điểm tiềm năng", "hint": "C mở Chỉ số — cộng hết điểm (hoặc Tự cộng điểm).", "type": "spend_points", "need": 1,
		"reward": {"exp": 300, "potions": 2}},
	{"title": "Dọn sương", "hint": "M mở Bản đồ khai phá, dùng Đuốc lên ô kề lãnh địa.", "type": "reveal", "need": 3,
		"reward": {"torches": 1, "exp": 600}},
	{"title": "Xây công trình đầu tiên", "hint": "Chiếm Rừng gỗ (30 vàng) — Xưởng Gỗ tự xây.", "type": "build", "need": 1,
		"reward": {"exp": 800, "gold": 150}},
	{"title": "Chuẩn bị đánh boss", "hint": "Đạt cấp 5 và chiếm 6 ô đất.", "type": "boss_unlocked", "need": 1, "reward": {"exp": 1200, "stones": 3}},
	{"title": "Sói Chúa Hư Vô", "hint": "Vào hang phía đông. Phá thanh Phá Thế để boss choáng.", "type": "boss", "need": 1, "reward": {"exp": 2500}},
	{"title": "Lõi Sương", "hint": "N mở bản đồ lục địa → Lõi Sương → Lên đường.", "type": "enter_map", "need": 1, "reward": {"exp": 3500}},
]
const DONE_STEP := 12


static func quest(step: int) -> Dictionary:
	return QUESTS[step - 1] if step >= 1 and step <= QUESTS.size() else {}


static func reward_text(r: Dictionary) -> String:
	var parts := PackedStringArray()
	for pair in [["exp", "%d EXP"], ["gold", "%d vàng"], ["potions", "%d bình máu"], ["torches", "%d Đuốc"], ["stones", "%d Đá Cường Hoá"],
			["crystal", "%d Tinh Thạch"], ["holy_water", "%d Bình Nước Thánh"]]:
		if r.has(pair[0]):
			parts.append(pair[1] % int(r[pair[0]]))
	return ", ".join(parts)
