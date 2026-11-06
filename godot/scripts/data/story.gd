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
## M9 (docs/14): Trạm Tuyết Bạc
const NGA := "Nữ tư tế Tuyết Nga"
const HAN := "Thợ săn Lão Hàn"
const SHADOW := "Bản Ngã Bóng Tối"
## M10 chương 7 (docs/16 C7-40)
const VANHAC := "Lão đạo Vân Hạc"
const PHONG := "Thuyền trưởng Phong Linh"
const GIAOCHU := "Giáo Chủ Hư Vô"
const CUTHAN := "Thiên Không Cự Thần"

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
	# ---------------------------------------------------------------- chương 7 (docs/16 C7-40…42)
	"r7_port": [[NGA, "Bia Đá gốc nằm trên Quần Đảo Thiên Không, giữa mây. Muốn lên đó phải có khí cầu — nâng lãnh địa thành Hoàng Thành rồi xây Cảng Khí Cầu."]],
	"r7_port_done": [[NGA, "Cảng Khí Cầu đã xong! Khí cầu đang đợi ở Đỉnh Cực Quang — tìm Bến Khí Cầu ở rìa phải."]],
	"r7_arrive": [
		["{name}", "Mặt đất ở dưới chân… chỉ là một hòn đảo trôi giữa mây."],
		["{name}", "(Rơi khỏi mép đảo sẽ về Đá Neo gần nhất và mất 10% HP. Chạm Đá Neo để lưu. Cầu gió tắt 5 giây mỗi 30 giây — nhìn nó nhấp nháy là chạy.)"],
	],
	"van_meet": [
		[VANHAC, "Khai Giới Giả… lão đã đợi ngươi ba trăm năm. Lão là người cuối cùng của Thánh Đường đời đầu, giữ Thiên Cung này."],
		[VANHAC, "Bia Đá gốc ở Đài Cự Thần, phía đông Thiên Cung Đổ Nát. Nhưng Hư Vô Giáo đã tới trước — chúng khắc ấn lên người khổng lồ canh Bia."],
		[NGA, "Bản dập Bia Băng ta mang theo khớp với chữ trên cột Thiên Cung. Đi thôi, {name}."],
	],
	"van_birds": [[VANHAC, "Bầy chim trời phát điên từ khi ấn Hư Vô xuất hiện. Dẹp chúng đi — cẩn thận Đại Bàng Mây, chúng quạt người ta khỏi mép đảo."]],
	"van_pillars": [[VANHAC, "Đảo Rừng Treo có 3 Trụ Gió cổ. Đứng cạnh mỗi trụ 2 giây để kích — cầu gió gần trụ sẽ không tắt nữa."]],
	"pillar_lit": [["{name}", "(Trụ Gió ngân lên. Cây cầu gió gần đó sáng ổn định — không còn chập chờn.)"]],
	"van_anchors": [[VANHAC, "Hư Vô Giáo cắm 3 Neo Hư Vô quanh Thiên Cung, kéo cả hòn đảo rơi xuống. Phá chúng trước khi quá muộn!"]],
	"anchor_broken": [["{name}", "(Neo Hư Vô vỡ tan. Thiên Cung rung nhẹ rồi nổi cao lên một chút.)"]],
	"cu_than_gate": [[VANHAC, "Đài Cự Thần ở tận cùng phía đông. Cự Thần đánh rất nặng — đứng trên nền còn nguyên, vành ngoài sẽ vỡ dần."]],
	"stele_rite": [
		[CUTHAN, "…Bia… Đá… Ta… đã canh nó… ba trăm năm… (Người khổng lồ quỳ xuống và hoá đá.)"],
		["Bia Đá gốc", "Mảnh thứ hai đang lớn trong ngươi. Chỉ ở Cổng Thiên Đạo mới phong ấn lại được — và phải mang Thiên phú đã tiến hoá hai lần."],
		[VANHAC, "Nghịch Thiên Cải Mệnh… nghi thức cổ của Thánh Đường. Đặt tay lên Bia, Khai Giới Giả."],
	],
	"stele_wait": [[VANHAC, "Bia Đá gốc đòi Thiên phú Lv10 và 1 Tinh Hoa Tiến Hoá (boss hiếm rơi). Chuẩn bị xong hãy quay lại."]],
	"ch7_end": [
		["{name}", "(Ánh sáng từ Bia tràn vào ngực. Thiên phú bùng lên một hình dạng mới.)"],
		[GIAOCHU, "Cảm ơn, Khai Giới Giả. Ngươi đã đánh thức Bia giúp ta."],
		["{name}", "(Một bóng đen khoác áo choàng rút đi một mảnh vỡ từ Bia Đá gốc rồi tan vào hư không.)"],
		[VANHAC, "Giáo Chủ Hư Vô! Hắn dùng mảnh Bia để mở Cổng Thiên Đạo cho Ma Tôn… Hắn đã rút về Vực Hư Vô."],
	],
	"ch7_done": [[VANHAC, "Bia Đá gốc giờ là nơi đổi tiến hoá. Vực Hư Vô ở dưới tầng mây — chương sau ngươi sẽ phải xuống đó."]],
	"vanhac_idle": [[VANHAC, "Đá Neo là bạn của người đi trên mây. Chạm vào chúng mỗi khi đi qua."]],
	"phong_shop": [[PHONG, "Lông Vũ Gió đây! Bấm Q để lơ lửng 2 giây — lướt qua khe hay lỡ chân đều cứu được."]],
	"nga7_idle": [[NGA, "Chữ trên Bia Băng và cột Thiên Cung là cùng một thứ tiếng… tiếng của người đầu tiên chạm vào Thiên phú."]],
	"rare_ky_lan": [["Kỳ Lân Mây", "(Tiếng sấm rền giữa trời quang. Một con kỳ lân xanh lục phi vòng quanh đảo, để lại vệt sét.)"]],
	"rare_ky_lan_down": [["{name}", "(Kỳ Lân Mây ngã xuống, chỉ còn chiếc sừng xoắn lấp lánh tia điện.)"]],
	# ---------------------------------------------------------------- chương 6 (docs/14 C6-40…44)
	"r6_arrive": [
		["{name}", "Gió buốt tới tận xương. Ở đây đêm dài hơn ngày…"],
		["{name}", "(Đứng yên lâu sẽ bị đóng băng — cứ di chuyển, hoặc sưởi bên lửa trại. Mặt băng trơn: thả phím vẫn trượt thêm một chút.)"],
	],
	"nga_meet": [
		[NGA, "Khai Giới Giả… Thánh Đường đã báo trước ngươi sẽ tới. Ta là Tuyết Nga, người giữ Bia Băng của Băng Nguyên."],
		[NGA, "Cái bóng của ngươi — ngươi đã thấy nó trong ánh Long Tâm, phải không? Ở phương bắc này, bóng tối biết nói tiếng người."],
		[LAM, "{name}! Ta theo dấu ngươi suốt từ Đầm Lầy. Lần này để ta đi cùng."],
	],
	"han_task": [[HAN, "Đàn Sói Băng đói rét kéo xuống tận trạm. Hạ 30 con quái quanh đây — rồi ta mới yên tâm cho ngươi lên rừng."]],
	"nga_beacons": [[NGA, "Rừng Băng có 3 Đèn Cực Quang cổ. Thắp lại chúng — ánh sáng ấy giữ được tâm trí người đi đêm."]],
	"beacon_lit": [["{name}", "(Ngọn đèn bừng sáng sắc xanh lục. Hơi ấm lan ra, và tiếng thì thầm trong đầu im bặt một lúc.)"]],
	"awaken": [
		["???", "…Cuối cùng. Cuối cùng ngươi cũng tới đủ gần."],
		["{name}", "Ai…? Giọng nói này… phát ra từ chính trong ngực ta?"],
		["???", "Ta là phần của ngươi mà ngươi không biết. Để ta ra ngoài — chỉ một lát thôi…"],
		[LAM, "Mắt ngươi… chuyển sang màu đen! {name}, tỉnh lại! Đứng gần lửa!"],
		["{name}", "(Thanh Ám Khí: đầy thì mất kiểm soát vài giây. Lửa và Đèn Cực Quang làm nó dịu đi.)"],
	],
	"dark_lost": [["???", "Đúng rồi… cứ để ta. Ta biết cách giết nhanh hơn ngươi."]],
	"dark_done": [
		["{name}", "(Ba lần. Mỗi lần tỉnh lại, quanh mình chỉ còn xác quái… và một cảm giác thèm khát không phải của mình.)"],
		[LAM, "Có một hang gương băng trên đỉnh núi. Tuyết Nga nói thứ đó đang gọi ngươi — tìm ra nó."],
	],
	"mirror_gate": [[NGA, "Gương Băng Vĩnh Dạ. Ở trong đó, bóng của ngươi sẽ tách ra thành một kẻ thù. Nó biết mọi chiêu thức của ngươi — vì nó LÀ ngươi."]],
	"boss6": [[SHADOW, "Ngươi dùng chiêu gì, ta dùng lại chiêu ấy. Ngươi có Thiên phú gì — ta có nó, ở dạng mà ngươi chưa bao giờ chạm tới."]],
	"boss6_mirror": [[SHADOW, "Tìm ta đi. Trong bốn tấm gương, chỉ ta có bóng… còn ngươi thì sao?"]],
	"boss6_talent": [[SHADOW, "Đây là Thiên phú của ngươi — khi nó trọn vẹn!"]],
	"shadow_down": [
		[SHADOW, "Ngươi thắng… nhưng ta không biến mất. Ta chỉ trở về… nơi ta thuộc về."],
		["{name}", "(Cái bóng tan thành khói đen và chui vào ngực. Lạnh buốt. Rồi im lặng.)"],
		[LAM, "Về Trạm Tuyết Bạc. Tuyết Nga biết điều gì đó — ta thấy bà ấy run khi nhìn ngươi."],
	],
	"truth": [
		[NGA, "Một nghìn năm trước, Ma Tôn Vô Diện cố đoạt Thiên phú của chính Thiên Đạo. Lục địa vỡ thành chín mảnh — đó là Thiên Liệt."],
		[NGA, "Nhưng hắn cũng mất một thứ: một mảnh linh hồn văng ra. Thánh Đường đã phong ấn nó trong Bia Đá ở làng Thanh Thạch."],
		[NGA, "Mười sáu năm trước, Bia Đá nứt. Mảnh linh hồn ấy tìm một thân xác mới — một đứa bé vừa chào đời trong làng."],
		["{name}", "…Là ta."],
		[NGA, "Phải. Ma Tôn săn ngươi không phải vì Thiên phú của ngươi — mà vì ngươi là phần còn thiếu của hắn."],
		[LAM, "Vậy thì sao? Ngươi vẫn là {name}. Ta biết điều đó."],
		[NGA, "Muốn phong ấn lại, phải tìm Bia Đá gốc — nơi Thiên Đạo lần đầu giáng xuống. Nó ở Quần Đảo Thiên Không, trên những hòn đảo bay giữa trời."],
	],
	"ch6_done": [[NGA, "Ám Khí giờ là của ngươi để điều khiển, không còn điều khiển ngươi. Hãy dùng nó — nhưng đừng để nó lớn quá."]],
	"nga_idle": [[NGA, "Bia Băng vẫn lạnh. Đi đi, Khai Giới Giả — và đừng đứng yên quá lâu ngoài kia."]],
	"nga_wait": [[NGA, "Bản Ngã còn chờ ngươi trong Gương Băng Vĩnh Dạ, phía đông Đỉnh Cực Quang."]],
	"han_shop": [[HAN, "Than Hồng ủ trong túi da — bấm Q khi tay chân bắt đầu cứng lại. Băng giá tan ngay."]],
	"lam6_idle": [[LAM, "Ta ở đây. Nếu bóng tối trong ngươi trỗi dậy, ta sẽ gọi tên ngươi."]],
	"rare_long_bang": [["Long Băng Bắc Cực", "Hơi thở của ta đã đóng băng biển phương bắc. Ngươi chỉ là một đốm lửa nhỏ."]],
	"rare_long_bang_down": [["{name}", "(Con rồng băng vỡ tan như một khối pha lê khổng lồ. Giữa đống băng vụn, một mảnh vảy vẫn còn lạnh buốt.)"]],
	# ---------------------------------------------------------------- chương 8 (docs/17 C8-40…44)
	"liet_job3_ch8": [[LIET, "Chức thứ ba không ai dạy được ở đây. Tổ Sư của các lớp bị Hư Vô Giáo giam dưới Vực — hạ Giáo Chủ, mang 3 Lõi Hư Vô tới Cổng Phá Vây."]],
	"r8_arrive": [
		["{name}", "Dưới tầng mây… là một vực tối không đáy. Thiên phú trong người cứ nhạt dần."],
		["{name}", "(Suy Thiên: ở ngoài vùng an toàn, Thiên phú yếu đi 10% mỗi phút, tối đa 50%. Đứng trong vòng Đèn Tinh Quang 5 giây để hồi lại.)"],
	],
	"lac8_meet": [
		[LAC, "Lại gặp nhau rồi, {name}. Liên minh Khai Giới đã dựng tiền đồn này để công Sào Huyệt Hư Vô."],
		[LAC, "Bọn giáo đồ nuốt Thiên phú của người ta để thành thần. Lam Nhi năm xưa cũng bị chúng hút như thế."],
		[NGA, "Đèn Tinh Quang là thứ duy nhất giữ được Thiên phú dưới này. Đừng đi quá xa ánh đèn."],
	],
	"lac8_kills": [[LAC, "Mở đường xuống Đáy Vực trước đã. Cẩn thận Bóng Hư Vô — đứng yên là chúng tàng hình, và chúng thích đâm sau lưng."]],
	"nga8_lamps": [[NGA, "Ở Đáy Vực có 4 Đèn Tinh Quang đã tắt. Đứng cạnh mỗi đèn 3 giây để thắp lại — bóng tối sẽ kéo tới, chuẩn bị đi."]],
	"lamp8_lit": [["{name}", "(Đèn Tinh Quang bừng sáng. Từ trong bóng tối, những cái bóng lặng lẽ trườn tới.)"]],
	"lac8_cages": [[LAC, "Thám báo thấy 3 Lồng Hư Vô ở Đáy Vực — chúng nhốt người làm vật tế. Phá lồng, cứu người!"]],
	"cage8_broken": [["{name}", "(Lồng Hư Vô vỡ. Người bên trong ngã xuống, thở hổn hển.)"]],
	"mac8_rescued": [
		[MAC, "…Là ngươi? Ha… Giáo phái hứa cho ta Thiên phú, rồi nhốt ta làm vật tế."],
		[LAC, "Mạc Tam. Ngươi lừa cả đội ta ở Biên Đài."],
		[MAC, "Ta biết đường vào Sào Huyệt. 3 Trụ Phong Ấn giữ cổng — phá được thì cả Liên minh tràn vào."],
		[LAC, "…Được. Lần này ta tin ngươi một lần. {name}, chuẩn bị Tổng tấn công."],
	],
	"assault8_start": [[LAC, "Quân ta theo ngươi! Phá 3 Trụ Phong Ấn — mỗi trụ đổ, bọn chúng sẽ phản công."]],
	"assault8_lost": [[LAC, "Rút! Trụ đã phá vẫn đổ — gặp ta ở Cổng Phá Vây (E) để công lại."]],
	"assault8_done": [[LAC, "Cổng Sào Huyệt đã mở! Điện Giáo Chủ ở phía đông. Ta giữ Cổng Phá Vây cho ngươi."]],
	"giao_chu_gate": [[GIAOCHU, "Khai Giới Giả. Thiên phú của ngươi thơm như mùi trái chín. Vào đây."]],
	"ch8_end": [
		["{name}", "(Mặt nạ bạc vỡ đôi. Hàng ngàn đốm sáng Thiên phú bay khỏi áo choàng, toả đi khắp lục địa.)"],
		[GIAOCHU, "Trả về chủ cũ… vô ích. Ma Tôn đã dùng mảnh Bia mở Cổng Thiên Đạo. Hắn đang gọi — cái thứ trong ngực ngươi đáp lời rồi đấy."],
		["{name}", "(Mảnh thứ hai nhói lên. Một giọng nói lạnh lẽo gọi đúng tên mình.)"],
		["Tổ Sư", "Chúng ta là Khai Giới Giả đời đầu, bị giam ở đây ba trăm năm. Mang Lõi Hư Vô tới Cổng Phá Vây — ta sẽ truyền chức thứ ba."],
	],
	"lam8_letter": [[LAM, "(Thư Lam Nhi) Sáng nay mình thấy một đốm sáng bay về… Thiên phú của mình! Cảm ơn cậu."]],
	"to_su_wrong": [["Tổ Sư", "Ta không truyền đạo cho lớp của ngươi. Tìm Tổ Sư của ngươi."]],
	"to_su_wait": [["Tổ Sư", "Cấp 90, chức thứ hai, 3 Lõi Hư Vô và 50 Tinh Thạch. Đủ rồi hãy tới."]],
	"ch8_done": [[LAC, "Sào Huyệt đã sụp. Cổng Thiên Đạo ở phía trên — chương sau ngươi phải lên đó."]],
	"lac8_idle": [[LAC, "Giữ ánh đèn bên mình. Dưới này, mất Thiên phú là mất mạng."]],
	"nga8_shop": [[NGA, "Đèn Lồng Tinh Quang — bấm Q để xoá Suy Thiên và giữ Thiên phú 45 giây. Bình máu, bình MP cũng có."]],
	"mac8_idle": [[MAC, "Lối tắt qua Sào Huyệt ta đều biết. Lần này ta đứng về phía các ngươi."]],
	"raid8_warn": [[LAC, "Hư Vô Giáo phản công một Đèn Tinh Quang! Giữ đèn trong 60 giây tới!"]],
	"rare_hu_vo_thu": [["Hư Vô Thú", "(Một tiếng gầm không âm thanh. Ánh đèn quanh ổ run lên rồi mờ dần.)"]],
	"rare_hu_vo_thu_down": [["{name}", "(Con thú tan thành sương đen. Một chiếc nanh tím vẫn còn lại trên nền đá.)"]],
	# ---------------------------------------------------------------- chương 9 (docs/18 C9-40…47)
	"r9_arrive": [
		["{name}", "Cầu thang ánh sáng dẫn lên… mỗi tầng một màu trời khác."],
		["{name}", "(Mỗi tầng mang một hệ, đổi mỗi lần bước vào. Nhặt Ấn Hệ trên bệ đá để đòn đánh khắc hệ tầng 60 giây. Hạ Thủ Tầng để mở Cửa Tầng.)"],
	],
	"van9_meet": [
		[VANHAC, "Đây là Thiên Thê — chín tầng tới Cổng Thiên Đạo. Ma Tôn đang ở trên cùng, dùng mảnh Bia mở cổng."],
		[LAM, "Mình đi cùng cậu tới cuối, {name}. Lần này tới lượt mình gọi tên cậu."],
		[NGA, "Thiên binh canh từng tầng. Cứ đi, ta giữ hàng ở đây."],
	],
	"van9_kills": [[VANHAC, "Dẹp thiên binh quanh đài trước đã. Rồi mở Cửa Tầng — hạ Thủ Tầng đứng canh mỗi cửa."]],
	"van9_floors": [[VANHAC, "Lên tới tầng 6. Mỗi Cửa Tầng mở ra, ngươi sẽ thấy ký ức của hắn — hãy nhìn cho kỹ."]],
	"van9_souls": [
		[VANHAC, "Những Tàn Hồn kia là Khai Giới Giả bị Ma Tôn cướp Thiên phú một nghìn năm trước. Giải thoát chín hồn — mỗi hồn để lại một Ánh Hồn."],
		[VANHAC, "Chín Ánh Hồn đủ vá mảnh Bia Đá gốc thành Ấn Phong Thiên — thứ duy nhất khép được Cổng."],
	],
	"van9_seal": [[VANHAC, "Ấn Phong Thiên đã thành. Lên tầng 9, tìm Thiên Đạo Chi Môn. Lão sẽ theo sau."]],
	"floor9_1": [["Ký ức", "(Một thiếu niên đứng trước Bia Đá. Ánh sáng không đến. \"Thiên Đạo chọn người khác.\")"]],
	"floor9_2": [["Ký ức", "(Cậu ta vẫn luyện kiếm mỗi đêm. Không Thiên phú — nhưng mạnh hơn mọi Khai Giới Giả cùng tuổi.)"]],
	"floor9_3": [["Ký ức", "(Cậu ta cứu cả một làng khỏi bầy quái. Dân làng cảm ơn người có Thiên phú đứng cạnh.)"]],
	"floor9_4": [["Ký ức", "(\"Nếu Thiên Đạo không cho, ta sẽ tự lấy.\" Lần đầu tiên, cậu ta chạm vào Thiên phú của người khác.)"]],
	"floor9_5": [["Ký ức", "(Thiên phú thứ hai, thứ mười, thứ trăm. Khuôn mặt cậu ta mờ dần sau mỗi lần nuốt.)"]],
	"floor9_6": [["Ký ức", "(Hắn trèo lên Thiên Thê. Thiên Đạo từ chối hắn lần thứ hai — và hắn đập vỡ Bia Đá.)"]],
	"floor9_7": [["Ký ức", "(Thiên Liệt. Sương mù tràn khắp lục địa. Hắn không còn mặt — chỉ còn khoảng trống xoáy sương.)"]],
	"floor9_8": [["Ký ức", "(Các Tổ Sư phong ấn hắn. Trước khi chìm, hắn xé linh hồn mình làm đôi và ném một nửa vào luân hồi.)"]],
	"floor9_9": [["Ký ức", "(Nửa linh hồn ấy rơi vào một đứa trẻ sinh ra ở làng Thanh Thạch, mười sáu năm trước.)"]],
	"floor9_locked": [["{name}", "(Cửa Tầng đóng chặt. Thủ Tầng vẫn đứng canh phía trước.)"]],
	"ma_ton_gate": [
		["Ma Tôn Vô Diện", "Ngươi tới rồi. Mười sáu năm qua, ngươi là ta — ta nhìn qua mắt ngươi, ta lớn lên cùng ngươi."],
		["Ma Tôn Vô Diện", "Trả lại nửa kia đi. Rồi ta sẽ cho ngươi xem Thiên Đạo trông như thế nào từ phía bên kia."],
		[LAM, "Đừng nghe hắn, {name}! Mình ở đây!"],
	],
	"ma_ton_shard": [["Ma Tôn Vô Diện", "Trả lại… phần của ta!"], ["{name}", "(Mảnh thứ hai trong ngực bùng cháy — nhưng nó không bay về phía hắn.)"]],
	"ch9_choice": [
		["{name}", "(Ma Tôn tan thành sương. Mảnh thứ hai sáng rực trong ngực. Ấn Phong Thiên mở ra trước Cổng Thiên Đạo.)"],
		[VANHAC, "Lựa chọn là của ngươi, Khai Giới Giả. Không ai có thể chọn thay."],
	],
	"end_hop_nhat": [
		["{name}", "(Mình hấp thụ mảnh thứ hai. Sương mù khắp lục địa… lặng xuống, như chờ lệnh.)"],
		["{name}", "(Cổng Thiên Đạo mở ra trong mình. Mình nhìn thấy từng Thiên phú như những vì sao.)"],
		[LAM, "Cậu vẫn là cậu chứ?"],
		["{name}", "Vẫn là mình. Chỉ là… giờ mình nghe được tiếng của cả lục địa."],
		[VANHAC, "Một Thiên Đạo có khuôn mặt. Ba trăm năm, lão chưa từng nghĩ sẽ thấy ngày này."],
		["{name}", "(Thần Vực mở ra phía trên Thiên Thê Đài — nơi Thiên Đạo mới thử thách chính mình.)"],
	],
	"end_hien_te": [
		["{name}", "(Mình đặt tay lên Ấn Phong Thiên. Mảnh thứ hai rời khỏi ngực, bay về phía Bia Đá.)"],
		["{name}", "(…)"],
		[ELDER, "Tỉnh rồi à? Ngủ ba ngày ba đêm đấy, cháu."],
		["{name}", "(Làng Thanh Thạch. Bia Đá liền lại. Ngoài cửa sổ — không còn sương mù.)"],
		[LAM, "Sương tan khắp lục địa rồi. Giờ thì xây lại thôi, {name}."],
		["{name}", "(Tái Thiết Lục Địa: mỗi vùng chờ một công trình mới.)"],
	],
	"van9_idle": [[VANHAC, "Ánh Hồn, Cửa Tầng, rồi Cổng. Từng bước một, Khai Giới Giả."]],
	"ch9_done": [[VANHAC, "Lục địa có một tương lai mới. Ngươi viết nó, không phải Thiên Đạo."]],
	"nga9_shop": [[NGA, "Đồ tiêu hao của mọi chương đều có — bình máu, bình MP, Đèn Lồng, Lông Vũ Gió, Than Hồng."]],
	"lam9_idle": [[LAM, "Thiên phú của mình đã về. Lần này, mình sẽ dùng nó để đứng cạnh cậu."]],
	"than_vuc_locked": [["Cổng Thần Vực", "(Cổng im lặng. Chỉ Thiên Đạo mới bước qua được.)"]],
	"rare_hu_anh": [["Thiên Đạo Hư Ảnh", "Ta là cái bóng của mọi Thiên phú từng được ban xuống. Ngươi muốn biết mình xứng đáng không?"]],
	"rare_hu_anh_down": [["{name}", "(Hư Ảnh tan thành vô số đốm sáng, mỗi đốm mang hình một Thiên phú, rồi lặng lẽ tắt.)"]],
}


## Nhiệm vụ chính chương 2 (03 mục 6.4). Bước lưu ở profile.quest.ch2 (0 = chưa tới vùng 2, 6 = xong).
const QUESTS2 := [
	{"title": "Gia nhập Liên minh", "hint": "Tới Thành Biên Đài, đứng cạnh Lạc Phong bấm E.", "type": "talk_lac", "goal": {"npc": "lac-phong"}, "need": 1, "reward": {"exp": 5000, "gold": 200}},
	{"title": "Dẹp loạn Cửa Gió", "hint": "Hạ 10 quái ở Cửa Gió rồi hạ Đội trưởng Lính Thuê (tinh anh có tên).", "type": "kills2", "goal": {"variant": "kills2"}, "need": 11, "reward": {"exp": 15000}},
	{"title": "Lãnh địa đầu tiên", "hint": "M mở Bản đồ khai phá vùng 2, chiếm 6 ô đất.", "type": "tiles2", "goal": {"panel": "map"}, "need": 6, "reward": {"exp": 20000, "stones": 5}},
	{"title": "Tin đồn trong thành", "hint": "Hỏi Thương nhân Mạc Tam (E) về gián điệp.", "type": "talk_mac", "goal": {"npc": "mac-tam"}, "need": 1, "reward": {"exp": 25000}},
	{"title": "Phủ Huyền Ảnh", "hint": "Tới Mắt Bão (theo mũi tên vàng). Hạ Tướng Gián Điệp Huyền Ảnh — chỉ bản thật có bóng.", "type": "boss2", "goal": {"map": "2-3", "at": "arena"}, "need": 1, "reward": {"exp": 30000}},
]
const DONE2 := 6

## M7 (docs/11 C4-41): nhiệm vụ chính chương 4. Bước lưu ở profile.quest.ch4 (0 = chưa tới vùng 4, 7 = xong).
## Thưởng EXP ≈ 25% EXP từ cấp 30 lên 45 (4,6 triệu × 25% ≈ 1,15 triệu).
const QUESTS4 := [
	{"title": "Làng Chài Lau", "hint": "Tới Làng Chài Lau (Bãi Lau Mù), đứng cạnh Lão Ngư bấm E.", "type": "talk_ngu", "goal": {"npc": "lao-ngu"}, "need": 1, "reward": {"exp": 40000, "gold": 500, "antidotes": 2}},
	{"title": "Tiếng hát trong lau", "hint": "Cùng Lam Nhi lần 3 dấu vết ảo ảnh ở Bãi Lau Mù, rồi hạ Ảo Ảnh Gọi Tên.", "type": "kills4", "goal": {"variant": "kills4"}, "need": 4, "reward": {"exp": 120000}},
	{"title": "Ký ức của Lam Nhi", "hint": "Tới Đầm Sâu (theo mũi tên vàng). Phá 5 Bọc Mộng trên các cồn đất (đi tới chạm vào).", "type": "pods4", "goal": {"map": "4-2", "list": "pods", "done": "orbs4"}, "need": 5, "reward": {"exp": 180000, "stones": 8}},
	{"title": "Cung Mộng", "hint": "Tới Cung Mộng (theo mũi tên vàng). Khám phá ≥ 40% map để tìm cửa Cung Phệ Mộng.", "type": "explore4", "goal": {"map": "4-3", "at": "explore"}, "need": 1, "reward": {"exp": 230000}},
	{"title": "Nữ Vương Phệ Mộng", "hint": "Hạ Nữ Vương ở phía đông Cung Mộng. Trong mơ: phá 3 Mộng Châu.", "type": "boss4", "goal": {"map": "4-3", "at": "arena"}, "need": 1, "reward": {"exp": 280000}},
	{"title": "Tiến hoá Thiên phú", "hint": "Thiên phú Lv10 + 1 Tinh Hoa Tiến Hoá → gặp Tinh Quang Sứ (E) hoặc bảng Thiên phú (T).", "type": "evolve", "goal": {"npc": "tinh-quang"}, "need": 1, "reward": {"exp": 300000, "gold": 2000}},
]
const DONE4 := 7


static func quest4(step: int) -> Dictionary:
	return QUESTS4[step - 1] if step >= 1 and step <= QUESTS4.size() else {}


## M8 (docs/12 C5-41): nhiệm vụ chính chương 5. Bước lưu ở profile.quest.ch5 (0 = chưa tới vùng 5, 8 = xong).
## Thưởng EXP ≈ 25% EXP từ cấp 45 lên 60 (9,8 triệu × 25% ≈ 2,45 triệu).
const QUESTS5 := [
	{"title": "Trại Tro Hồng", "hint": "Tới Trại Tro Hồng (Chân Núi Tro), đứng cạnh Xích Đồng bấm E.", "type": "talk_xich", "goal": {"npc": "xich-dong"}, "need": 1, "reward": {"exp": 100000, "gold": 800, "holy_water": 1}},
	{"title": "Dọn đường cho đoàn buôn", "hint": "Nhặt 8 Than Đá Đỏ rơi từ Thằn Lằn Lửa / Người Đá cho Kim Phú. Tránh dung nham.", "type": "kills5", "goal": {"variant": "kills5"}, "need": 8, "reward": {"exp": 250000}},
	{"title": "Đất dưới chân núi", "hint": "M mở Bản đồ khai phá vùng 5: chiếm 6 ô, có ít nhất 1 Mỏ Tinh Thạch.", "type": "tiles5", "goal": {"panel": "map"}, "need": 6, "reward": {"exp": 300000, "stones": 8}},
	{"title": "Thương hội phản bội", "hint": "Về Trại Tro Hồng, nói với Xích Đồng (E) rồi giữ Cổng Trại qua 3 đợt lính Kim Luân.", "type": "siege5", "goal": {"npc": "xich-dong", "siege": true}, "need": 1, "reward": {"exp": 400000, "gold": 2000}},
	{"title": "Miệng Núi Lửa", "hint": "Tới Miệng Núi Lửa (theo mũi tên vàng). Khám phá ≥ 40% map để tìm lối vào Long Huyệt.", "type": "explore5", "goal": {"map": "5-3", "at": "explore"}, "need": 1, "reward": {"exp": 400000}},
	{"title": "Viêm Long", "hint": "Hạ Viêm Long ở Long Huyệt (phía đông). Khi dung nham dâng: đứng trên Đá Nổi.", "type": "boss5", "goal": {"map": "5-3", "at": "arena"}, "need": 1, "reward": {"exp": 450000, "crystal": 10}},
	{"title": "Chuyển chức lần 2", "hint": "Cấp 60 + 30 Tinh Thạch → gặp Liệt Diễm (E) ở Trại Tro Hồng, chọn 1 trong 2 nhánh.", "type": "job2", "goal": {"npc": "liet-dien"}, "need": 1, "reward": {"exp": 550000, "gold": 3000}},
]
const DONE5 := 8


static func quest5(step: int) -> Dictionary:
	return QUESTS5[step - 1] if step >= 1 and step <= QUESTS5.size() else {}


## M9 (docs/14 C6-41): nhiệm vụ chính chương 6. Bước lưu ở profile.quest.ch6 (0 = chưa tới vùng 6, 8 = xong).
## Thưởng EXP ≈ 25% EXP từ cấp 60 lên 72 (13,3 triệu × 25% ≈ 3,34 triệu).
const QUESTS6 := [
	{"title": "Trạm Tuyết Bạc", "hint": "Tới Trạm Tuyết Bạc (Đồng Tuyết), đứng cạnh Tuyết Nga bấm E.", "type": "talk_nga", "goal": {"npc": "tuyet-nga"}, "need": 1, "reward": {"exp": 120000, "gold": 1000, "embers": 2}},
	{"title": "Đàn sói đói", "hint": "Giữ điểm phía đông Trạm Tuyết Bạc qua 3 đợt sói đói (đừng rời xa).", "type": "kills6", "goal": {"variant": "kills6"}, "need": 3, "reward": {"exp": 300000}},
	{"title": "Thắp Đèn Cực Quang", "hint": "Tới Rừng Băng (theo mũi tên vàng). Đứng cạnh 3 Đèn Cực Quang 2 giây để thắp.", "type": "beacons6", "goal": {"map": "6-2", "list": "beacons", "done": "beacons6"}, "need": 3, "reward": {"exp": 400000, "stones": 8}},
	{"title": "Mảnh thứ hai thức giấc", "hint": "Tới Đỉnh Cực Quang (theo mũi tên vàng). Trải qua 3 lần mất kiểm soát (thanh Ám Khí đầy). Lửa làm Ám Khí dịu đi.", "type": "dark6", "goal": {"map": "6-3", "at": "camp"}, "need": 3, "reward": {"exp": 450000}},
	{"title": "Gương Băng Vĩnh Dạ", "hint": "Khám phá ≥ 40% Đỉnh Cực Quang để tìm cửa hang gương.", "type": "explore6", "goal": {"map": "6-3", "at": "explore"}, "need": 1, "reward": {"exp": 550000}},
	{"title": "Bản Ngã Bóng Tối", "hint": "Hạ Bản Ngã ở phía đông Đỉnh Cực Quang. Nó dùng lại kỹ năng của ngươi 3 giây sau; trong 4 gương chỉ tấm thật có bóng.", "type": "boss6", "goal": {"map": "6-3", "at": "arena"}, "need": 1, "reward": {"exp": 700000, "crystal": 10}},
	{"title": "Sự thật", "hint": "Về Trạm Tuyết Bạc, nói với Tuyết Nga (E).", "type": "truth6", "goal": {"npc": "tuyet-nga"}, "need": 1, "reward": {"exp": 820000, "gold": 4000}},
]
const DONE6 := 8


static func quest6(step: int) -> Dictionary:
	return QUESTS6[step - 1] if step >= 1 and step <= QUESTS6.size() else {}


## M12 (docs/18 C9-41): nhiệm vụ chính chương 9. Bước lưu ở profile.quest.ch9: 0 = chưa xong chương 8, 1…7 = bước 1…7, 8 = xong.
## Thưởng EXP ≈ 25% EXP cấp 95 → 100 ≈ 3,39 triệu.
const QUESTS9 := [
	{"title": "Thiên Thê", "hint": "Tới Thiên Thê Đài, gặp Vân Hạc", "type": "talk_van9", "goal": {"npc": "van-hac-9"}, "need": 1, "reward": {"exp": 200000, "gold": 5000}},
	{"title": "Thiên binh", "hint": "Hạ 10 quái Thiên Thê rồi hạ Thiên Binh Thống Lĩnh", "type": "kills9", "goal": {"variant": "kills9"}, "need": 11, "reward": {"exp": 350000}},
	{"title": "Vượt tầng", "hint": "Mở Cửa Tầng tới tầng 6", "type": "floors9", "goal": {"region": 9, "enemy": "guard9"}, "need": 5, "reward": {"exp": 450000, "stones": 12}},
	{"title": "Ánh Hồn", "hint": "Giải thoát 9 Tàn Hồn Khai Giới Giả", "type": "souls9", "goal": {"region": 9, "enemy": "tan-hon"}, "need": 9, "reward": {"exp": 500000, "crystal": 15}},
	{"title": "Thiên Đạo Chi Môn", "hint": "Mở tới tầng 9, tìm Cổng (40% map)", "type": "explore9", "goal": {"map": "9-3", "at": "explore"}, "need": 1, "reward": {"exp": 550000}},
	{"title": "Ma Tôn Vô Diện", "hint": "Hạ Ma Tôn ở Thiên Đạo Chi Môn", "type": "boss9", "goal": {"map": "9-3", "at": "arena"}, "need": 1, "reward": {"exp": 600000, "crystal": 20}},
	{"title": "Lựa chọn", "hint": "Chọn số phận của mảnh thứ hai", "type": "ending9", "goal": {"none": "Chọn kết thúc ở bảng hiện ra sau trận Ma Tôn"}, "need": 1, "reward": {"exp": 740000, "gold": 10000}},
]
const DONE9 := 8


static func quest9(step: int) -> Dictionary:
	return QUESTS9[step - 1] if step >= 1 and step <= QUESTS9.size() else {}


## M11 (docs/17 C8-41): nhiệm vụ chính chương 8. Bước lưu ở profile.quest.ch8: 0 = chưa xong chương 7, 1…7 = bước 1…7, 8 = xong.
## Thưởng EXP ≈ 25% EXP cấp 84 → 95 ≈ 6,19 triệu, tăng dần theo bước.
const QUESTS8 := [
	{"title": "Xuống vực", "hint": "Tới Tiền Đồn Tinh Quang, gặp Lạc Phong", "type": "talk_lac8", "goal": {"npc": "lac-phong-8"}, "need": 1, "reward": {"exp": 300000, "lanterns": 2}},
	{"title": "Mở đường", "hint": "Nhặt 8 Mảnh Phong Ấn từ Kẻ Nuốt / Bóng Hư Vô", "type": "kills8", "goal": {"variant": "kills8"}, "need": 8, "reward": {"exp": 600000}},
	{"title": "Thắp đèn", "hint": "Thắp 4 Đèn Tinh Quang ở Đáy Vực", "type": "lamps8", "goal": {"map": "8-2", "list": "lamps", "only": "lamps_off", "done": "lamps8"}, "need": 4, "reward": {"exp": 800000, "stones": 10}},
	{"title": "Lồng Hư Vô", "hint": "Phá 3 Lồng Hư Vô ở Đáy Vực", "type": "cages8", "goal": {"map": "8-2", "list": "cages", "done": "cages8"}, "need": 3, "reward": {"exp": 900000, "crystal": 10}},
	{"title": "Tổng tấn công", "hint": "Phá 3 Trụ Phong Ấn ở Sào Huyệt", "type": "assault8", "goal": {"map": "8-3", "list": "seals", "done": "pillars8"}, "need": 3, "reward": {"exp": 1000000, "gold": 6000}},
	{"title": "Giáo Chủ Hư Vô", "hint": "Hạ Giáo Chủ ở Điện Giáo Chủ", "type": "boss8", "goal": {"map": "8-3", "at": "arena"}, "need": 1, "reward": {"exp": 1200000, "crystal": 15}},
	{"title": "Chuyển chức lần 3", "hint": "Gặp Tổ Sư ở Cổng Phá Vây", "type": "job3", "goal": {"npc": "to-su"}, "need": 1, "reward": {"exp": 1390000, "gold": 8000}},
]
const DONE8 := 8


static func quest8(step: int) -> Dictionary:
	return QUESTS8[step - 1] if step >= 1 and step <= QUESTS8.size() else {}


## M10 (docs/16 C7-41): nhiệm vụ chính chương 7. Bước lưu ở profile.quest.ch7: 0 = chưa xong chương 6, 1 = Dựng Cảng Khí Cầu
## (bước 0 của spec), 2…8 = bước 1…7, 9 = xong. Thưởng EXP ≈ 25% EXP cấp 72 → 84 ≈ 4,91 triệu, tăng dần theo bước.
## Mục tiêu ≤ 30 ký tự, gợi ý ≤ 40 ký tự (UI-16).
const QUESTS7 := [
	{"title": "Dựng Cảng Khí Cầu", "hint": "Nâng lãnh địa lên Hoàng Thành, xây Cảng", "type": "port7", "goal": {"panel": "map"}, "need": 1, "reward": {"exp": 200000, "gold": 3000}},
	{"title": "Lên đảo", "hint": "Tới Bến Mây, nói chuyện với Vân Hạc", "type": "talk_vanhac", "goal": {"npc": "van-hac"}, "need": 1, "reward": {"exp": 350000, "feathers": 3}},
	{"title": "Bầy chim dữ", "hint": "Giữ điểm đông Bến Mây qua 3 đợt chim", "type": "kills7", "goal": {"variant": "kills7"}, "need": 3, "reward": {"exp": 500000}},
	{"title": "Nối cầu gió", "hint": "Kích 3 Trụ Gió ở Đảo Rừng Treo", "type": "pillars7", "goal": {"map": "7-2", "list": "pillars", "done": "pillars7"}, "need": 3, "reward": {"exp": 600000, "stones": 10}},
	{"title": "Neo Hư Vô", "hint": "Phá 3 Neo Hư Vô ở Thiên Cung", "type": "anchors7", "goal": {"map": "7-3", "list": "void_anchors", "done": "anchors7"}, "need": 3, "reward": {"exp": 700000}},
	{"title": "Tìm Đài Cự Thần", "hint": "Khám phá 40% Thiên Cung Đổ Nát", "type": "explore7", "goal": {"map": "7-3", "at": "explore"}, "need": 1, "reward": {"exp": 750000}},
	{"title": "Thiên Không Cự Thần", "hint": "Hạ Cự Thần ở Đài Cự Thần", "type": "boss7", "goal": {"map": "7-3", "at": "arena"}, "need": 1, "reward": {"exp": 850000, "crystal": 12}},
	{"title": "Nghịch Thiên Cải Mệnh", "hint": "Chạm Bia Đá gốc, tiến hoá lần 2", "type": "evo7", "goal": {"map": "7-3", "at": "arena"}, "need": 1, "reward": {"exp": 960000, "gold": 6000}},
]
const DONE7 := 9


static func quest7(step: int) -> Dictionary:
	return QUESTS7[step - 1] if step >= 1 and step <= QUESTS7.size() else {}


## M6 (docs/10 C3-41): nhiệm vụ chính chương 3. Bước lưu ở profile.quest.ch3 (0 = chưa tới vùng 3, 7 = xong).
## Thưởng EXP ≈ 25% EXP từ cấp 20 lên 30 (M5-02: 1,2 triệu × 25% ≈ 300.000).
const QUESTS3 := [
	{"title": "Học giả sa mạc", "hint": "Tới Trại Cát Đỏ (Rìa Cát Đỏ), đứng cạnh Sa Lão bấm E.", "type": "talk_salao", "goal": {"npc": "sa-lao"}, "need": 1, "reward": {"exp": 15000, "gold": 300}},
	{"title": "Mảnh bản đồ", "hint": "Tìm 3 Mảnh bản đồ phát sáng quanh Rìa Cát Đỏ, rồi hạ Xác Ướp Giữ Bản Đồ.", "type": "kills3", "goal": {"variant": "kills3"}, "need": 4, "reward": {"exp": 35000}},
	{"title": "Ba ốc đảo", "hint": "Tới Ốc Đảo Lãng Quên (theo mũi tên vàng). Uống nước ở cả 3 ốc đảo (đứng trong hồ 1 giây).", "type": "oases", "goal": {"map": "3-2", "list": "oases", "done": "oases"}, "need": 3, "reward": {"exp": 45000, "potions": 2}},
	{"title": "Bia Khai Giới Giả", "hint": "Tới Di Tích Khai Giới Giả (theo mũi tên vàng). Khám phá ≥ 40% map và tới Bia Khai Giới Giả.", "type": "stele3", "goal": {"map": "3-3", "at": "stele3"}, "need": 1, "reward": {"exp": 55000, "stones": 6}},
	{"title": "Sào Huyệt Sa Hoàng", "hint": "Hạ Bọ Cạp Sa Hoàng ở phía đông Di tích. Né vết cát khi nó chui xuống.", "type": "boss3", "goal": {"map": "3-3", "at": "arena"}, "need": 1, "reward": {"exp": 70000}},
	{"title": "Thử Thách Chuyển Chức", "hint": "Đạt cấp 30, gặp Thạch Thủ ở Trại Cát Đỏ (E) để chuyển chức.", "type": "job", "goal": {"npc": "thach-thu"}, "need": 1, "reward": {"exp": 80000, "gold": 1000}},
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
	{"title": "Quái Sương tấn công làng!", "hint": "Ra cổng làng. Chuột trái / J để đánh.", "type": "kill_quest", "goal": {"map": "1-1", "at": "field"}, "need": 3,
		"reward": {"exp": 80, "gold": 20}},
	{"title": "Học kỹ năng", "hint": "Phím 1–4 dùng kỹ năng (tốn MP).", "type": "skill", "goal": {"near": "enemy"}, "need": 2, "reward": {"exp": 100}},
	{"title": "Học né", "hint": "Space né lăn; né đúng lúc đòn tới = Hoàn hảo.", "type": "dodge", "goal": {"near": "enemy"}, "need": 1, "reward": {"exp": 120}},
	{"title": "Món quà của Trưởng làng", "hint": "I mở túi đồ, chọn vũ khí, bấm Mặc.", "type": "equip_weapon", "goal": {"panel": "bag"}, "need": 1, "reward": {"exp": 150}},
	{"title": "Vào Rừng Sương", "hint": "Đánh quái phía đông làng để lên cấp.", "type": "level", "goal": {"map": "1-1", "at": "camp"}, "need": 3, "reward": {"exp": 300, "gold": 100}},
	{"title": "Cộng điểm tiềm năng", "hint": "C mở Chỉ số — cộng hết điểm (hoặc Tự cộng điểm).", "type": "spend_points", "goal": {"panel": "stats"}, "need": 1,
		"reward": {"exp": 300, "potions": 2}},
	{"title": "Dọn sương", "hint": "M mở Bản đồ khai phá, dùng Đuốc lên ô kề lãnh địa.", "type": "reveal", "goal": {"panel": "map"}, "need": 3,
		"reward": {"torches": 1, "exp": 600}},
	{"title": "Xây công trình đầu tiên", "hint": "Chiếm Rừng gỗ (30 vàng) — Xưởng Gỗ tự xây.", "type": "build", "goal": {"panel": "map"}, "need": 1,
		"reward": {"exp": 800, "gold": 150}},
	{"title": "Chuẩn bị đánh boss", "hint": "Đạt cấp 5 và chiếm 6 ô đất.", "type": "boss_unlocked", "goal": {"map": "1-1", "at": "camp"}, "need": 1, "reward": {"exp": 1200, "stones": 3}},
	{"title": "Sói Chúa Hư Vô", "hint": "Vào hang phía đông. Phá thanh Phá Thế để boss choáng.", "type": "boss", "goal": {"map": "1-1", "at": "arena"}, "need": 1, "reward": {"exp": 2500}},
	{"title": "Lõi Sương", "hint": "Đi tới Lõi Sương theo mũi tên vàng (Cổng Dịch Chuyển hoặc cổng vàng cuối map).", "type": "enter_map", "goal": {"map": "1-3", "at": "safe"}, "need": 1, "reward": {"exp": 3500}},
]
const DONE_STEP := 12


static func quest(step: int) -> Dictionary:
	return QUESTS[step - 1] if step >= 1 and step <= QUESTS.size() else {}


static func reward_text(r: Dictionary) -> String:
	var parts := PackedStringArray()
	for pair in [["exp", "%d EXP"], ["gold", "%d vàng"], ["potions", "%d bình máu"], ["torches", "%d Đuốc"], ["stones", "%d Đá Cường Hoá"],
			["crystal", "%d Tinh Thạch"], ["holy_water", "%d Bình Nước Thánh"], ["embers", "%d Than Hồng"], ["feathers", "%d Lông Vũ Gió"], ["lanterns", "%d Đèn Lồng Tinh Quang"]]:
		if r.has(pair[0]):
			parts.append(pair[1] % int(r[pair[0]]))
	return ", ".join(parts)
