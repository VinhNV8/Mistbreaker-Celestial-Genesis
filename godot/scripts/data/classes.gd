extends RefCounted
## M3 (03-mvp-spec mục 5.2, 5.4): lớp nhân vật và 4 kỹ năng mỗi lớp.
## Kỹ năng: cd (giây), mp, mul (hệ số sát thương), icon (assets/icons/skill-<icon>.png).

## LH1 (docs/19): Hộ Vệ — lớp thứ 4 của kịch bản mục 4. LH2: Triệu Hồi Sư — lớp thứ 5 (CR-03).
const ORDER := ["kiem-khach", "tho-san", "phap-su", "ho-ve", "trieu-hoi-su"]

const DEFS := {
	"kiem-khach": {
		"name": "Kiếm Khách",
		"role": "Cận chiến · Chí mạng",
		"main": "STR",
		"sprite": "hero-kiem-khach",
		"description": "Chém vòng cung trước mặt, trúng nhiều quái một lúc. Máu dày, lao vào giữa bầy quái.",
		## D51: "melee" | "ranged" — bot, Tự đánh, tầm với của boss đọc từ đây (GameWorld.is_ranged).
		"range": "melee",
		## C1-34: Tự cộng điểm — lặp mẫu này.
		"auto": ["str", "str", "vit", "str", "agi"],
		"auto_text": "3 STR : 2 VIT",
		"basic": {"name": "Chém", "icon": "slash", "kind": "slash"},
		"skills": [
			{"id": "spin", "unlock": 1, "name": "Xoáy Kiếm", "cd": 6.0, "mp": 15, "mul": 1.8, "icon": "spin",
				"text": "Chém vòng quanh 12,5 m, ×1,8 sát thương."},
			{"id": "dash", "unlock": 1, "name": "Đột Kích", "cd": 8.0, "mp": 20, "mul": 1.5, "icon": "dash",
				"text": "Lao 18 m theo hướng ngắm, chém mọi quái trên đường ×1,5; bất tử khi lao."},
			# CL1 (docs/21): Kiếm Khí → Trảm Phong; Thiết Bích → Kiếm Ý (id "kiemy", điểm của "guard" chuyển sang)
			{"id": "wave", "unlock": 4, "name": "Trảm Phong", "cd": 4.0, "mp": 15, "mul": 1.6, "icon": "wave",
				"text": "Chém luồng kiếm khí thẳng phía trước 40 m, xuyên mọi quái, ×1,6."},
			{"id": "kiemy", "unlock": 8, "name": "Kiếm Ý", "cd": 20.0, "mp": 25, "mul": 0.0, "icon": "kiemy", "replaces": "guard",
				"text": "8 giây: +20% tỉ lệ chí mạng (trần 60%), +15% tốc đánh."},
			# SK2 (docs/13 mục 4.1)
			{"id": "lientram", "unlock": 15, "name": "Nguyệt Ảnh Liên Trảm", "cd": 10.0, "mp": 20, "mul": 1.15, "icon": "lientram",
				"text": "Lướt tới quái gần nhất trong 15 m rồi chém 3 nhát liên tiếp (nón 90°, 7 m), mỗi nhát ×1,15."},
			{"id": "hongkiem", "unlock": 22, "name": "Hống Kiếm", "cd": 12.0, "mp": 25, "mul": 1.0, "icon": "hongkiem",
				"text": "Gầm vòng 8 m ×1,0, quái thường choáng 1,2 giây; boss/tinh anh nhận gấp đôi vào thanh Phá Thế."},
			{"id": "kiemvu", "unlock": 30, "job": true, "name": "Kiếm Vũ", "cd": 10.0, "mp": 30, "mul": 0.45, "icon": "kiemvu",
				"text": "(Kiếm Sư) Xoay kiếm 2 giây quanh mình 10 m, 8 lần ×0,45."},
			{"id": "phikiem", "unlock": 30, "job": true, "name": "Phi Kiếm", "cd": 6.0, "mp": 20, "mul": 1.2, "icon": "phikiem",
				"text": "(Kiếm Sư) Phóng 3 thanh kiếm toả 30°, xuyên quái, mỗi thanh ×1,2."},
			# SK3 (docs/13 mục 4.1): tối thượng cấp 45 + kỹ năng nhánh chuyển chức 2 (cấp 60, chỉ nhánh đã chọn)
			{"id": "vankiem", "unlock": 45, "ultimate": true, "name": "Vạn Kiếm Quy Tông", "cd": 60.0, "mp": 50, "mul": 0.67, "icon": "vankiem",
				"text": "(Tối thượng) 3 giây mưa kiếm quanh mình 15 m, 12 đợt ×0,67 (tổng 800%)."},
			{"id": "thanhkiem", "unlock": 60, "job2": "kiem-thanh", "name": "Thánh Kiếm Trảm", "cd": 9.0, "mp": 30, "mul": 3.0, "icon": "thanhkiem",
				"text": "(Kiếm Thánh) Đường kiếm thánh 50 m, xuyên mọi quái, ×3,0."},
			{"id": "kiemvuc", "unlock": 60, "job2": "kiem-thanh", "name": "Kiếm Vực", "cd": 14.0, "mp": 35, "mul": 0.35, "icon": "kiemvuc",
				"text": "(Kiếm Thánh) Kiếm vực 10 m quanh mình 4 giây, ×0,35 mỗi 0,5 giây, làm chậm quái."},
			{"id": "huyetbao", "unlock": 60, "job2": "huyet-kiem", "name": "Huyết Bạo", "cd": 10.0, "mp": 20, "mul": 2.5, "icon": "huyetbao",
				"text": "(Huyết Kiếm) Đốt 10% HP hiện có, nổ máu 9 m ×2,5, hút lại 20% sát thương."},
			{"id": "huyetanh", "unlock": 60, "job2": "huyet-kiem", "name": "Huyết Ảnh", "cd": 8.0, "mp": 25, "mul": 1.2, "icon": "huyetanh",
				"text": "(Huyết Kiếm) Lao 2 lần liên tiếp về phía quái gần nhất, mỗi lần ×1,2."},
			# J3 (docs/23): Thần Kỹ — mở khi đã chuyển chức 3 (cấp 90)
			{"id": "nhatkiem", "unlock": 90, "job3": true, "name": "Nhất Kiếm Khai Thiên", "cd": 30.0, "mp": 40, "mul": 5.0, "icon": "nhatkiem",
				"text": "(Thần Kỹ · Kiếm Thần) Vung 0,5 giây rồi chém vệt thẳng 40 m rộng 5 m ×5,0; gấp đôi lên quái đang vỡ Phá Thế."},
		],
	},
	"tho-san": {
		"name": "Thợ Săn",
		"role": "Đánh xa, cơ động",
		"main": "DEX · AGI",
		"sprite": "hero-tho-san",
		"description": "Bắn tên từ xa 45 m, né tránh cao hơn. Máu mỏng, phải giữ khoảng cách.",
		"range": "ranged",
		"auto": ["dex", "agi", "dex", "agi", "vit"],
		"auto_text": "3 AGI : 1 VIT : 1 LUK",
		"basic": {"name": "Bắn", "icon": "shot", "kind": "shot"},
		"skills": [
			# CL1 (docs/21): Vũ Tiễn, Xuyên Tâm Tiễn (xuyên 3 quái), Lộn Nhào mở ở cấp 4 (đổi chỗ với Bẫy Gai)
			{"id": "rain", "unlock": 1, "name": "Vũ Tiễn", "cd": 8.0, "mp": 25, "mul": 0.5, "icon": "rain",
				"text": "Mưa tên vùng 9 m tại điểm ngắm: 5 đợt trong 1,5 giây, mỗi đợt ×0,5 (tổng 250%)."},
			{"id": "pierce", "unlock": 1, "name": "Xuyên Tâm Tiễn", "cd": 5.0, "mp": 15, "mul": 1.8, "icon": "pierce",
				"text": "Một mũi tên bay 60 m, xuyên tối đa 3 quái, ×1,8."},
			{"id": "lanban", "unlock": 4, "name": "Lộn Nhào", "cd": 8.0, "mp": 20, "mul": 0.8, "icon": "lanban",
				"text": "Lộn lùi khỏi hướng ngắm (bất tử khi lộn) rồi bắn 3 mũi toả 24°, mỗi mũi ×0,8; 3 giây sau đó +50% né tránh (trần 60%)."},
			{"id": "eagle", "unlock": 8, "name": "Ưng Nhãn", "cd": 25.0, "mp": 30, "mul": 0.0, "icon": "eagle",
				"text": "6 giây: +30% tốc đánh, +15% chí mạng."},
			{"id": "tennay", "unlock": 15, "name": "Tên Nảy", "cd": 6.0, "mp": 18, "mul": 1.1, "icon": "tennay",
				"text": "Mũi tên trúng quái nảy sang tối đa 4 quái kế tiếp (mỗi bước ≤ 15 m), mỗi lần ×1,1."},
			{"id": "trap", "unlock": 22, "name": "Bẫy Gai", "cd": 10.0, "mp": 20, "mul": 2.0, "icon": "trap",
				"text": "Đặt bẫy (tối đa 2). Quái chạm vào: nổ 6 m ×2,0 và bị trói 2 giây."},
			{"id": "lienxa", "unlock": 30, "job": true, "name": "Liên Xạ", "cd": 9.0, "mp": 30, "mul": 0.6, "icon": "lienxa",
				"text": "(Xạ Thủ) 1,5 giây bắn liên tục 8 mũi vào quái gần nhất, mỗi mũi ×0,6; vẫn di chuyển được."},
			{"id": "tendoc", "unlock": 30, "job": true, "name": "Tên Độc", "cd": 7.0, "mp": 20, "mul": 1.0, "icon": "tendoc",
				"text": "(Xạ Thủ) Mũi tên xuyên ×1,0, quái trúng bị độc cộng dồn (×0,2 mỗi giây, 4 giây, tối đa 3 lần)."},
			{"id": "thientien", "unlock": 45, "ultimate": true, "name": "Thiên Tiễn Vũ", "cd": 60.0, "mp": 50, "mul": 0.7, "icon": "thientien",
				"text": "(Tối thượng) Mưa tên vùng 20 m tại điểm ngắm, 10 đợt ×0,7."},
			{"id": "phakhong", "unlock": 60, "job2": "than-tien", "name": "Phá Không Tiễn", "cd": 10.0, "mp": 30, "mul": 4.0, "icon": "phakhong",
				"text": "(Thần Tiễn) 1 mũi xuyên 70 m, luôn chí mạng, ×4,0."},
			{"id": "tamlien", "unlock": 60, "job2": "than-tien", "name": "Tam Liên Thần Tiễn", "cd": 8.0, "mp": 25, "mul": 1.5, "icon": "tamlien",
				"text": "(Thần Tiễn) 3 mũi xuyên liên tiếp, mỗi mũi ×1,5."},
			{"id": "baimin", "unlock": 60, "job2": "tho-bay", "name": "Bãi Mìn", "cd": 14.0, "mp": 30, "mul": 1.2, "icon": "baimin",
				"text": "(Thợ Bẫy) Rải 5 bẫy nổ quanh mình (không tính giới hạn bẫy), mỗi bẫy ×1,2."},
			{"id": "luoibay", "unlock": 60, "job2": "tho-bay", "name": "Lưới Bẫy", "cd": 10.0, "mp": 25, "mul": 0.8, "icon": "luoibay",
				"text": "(Thợ Bẫy) Ném lưới 8 m tại điểm ngắm ×0,8, trói quái 3 giây."},
			# J3 (docs/23): Thần Kỹ — mở khi đã chuyển chức 3 (cấp 90)
			{"id": "tinhvu", "unlock": 90, "job3": true, "name": "Thiên Lạc Tinh Vũ", "cd": 30.0, "mp": 40, "mul": 0.7, "icon": "tinhvu",
				"text": "(Thần Kỹ · Thiên Lạc Xạ Thủ) 8 mũi tên sao rơi lên 8 quái nhiều HP nhất trong 25 m (ít quái thì dồn vào con nhiều HP nhất), mỗi mũi ×0,7."},
		],
	},
	## SN-01…04 (đợt SN2, Spec_Notes S1): kịch bản mục 4 — sát thương phép diện rộng, chỉ số chính Trí tuệ.
	"phap-su": {
		"name": "Pháp Sư",
		"role": "Phép diện rộng, khống chế",
		"main": "INT",
		"sprite": "hero-phap-su",
		"description": "Ném Hỏa Cầu nổ lan, sét nảy qua nhiều quái, gọi thiên thạch. Máu mỏng nhất — dùng Băng Ngục trói quái và Pháp Thuẫn để sống sót.",
		"range": "ranged",
		"auto": ["int", "int", "vit", "int", "wis"],
		"auto_text": "3 INT : 2 VIT",
		"basic": {"name": "Hỏa Cầu", "icon": "fireball", "kind": "fireball"},
		"skills": [
			# CL1 (docs/21): Sét Chuỗi; Băng Lao (mới, id "banglao", điểm của "dichchuyen" chuyển sang) ở ô cấp 1;
			# Băng Ngục xuống ô cấp 22 thay Dịch Chuyển; Thiên Hoả Phần Thế → Thiên Tai Nguyên Tố
			{"id": "chain", "unlock": 1, "name": "Sét Chuỗi", "cd": 5.0, "mp": 15, "mul": 1.2, "icon": "chain",
				"text": "Sét đánh quái gần nhất trong 35 m, nảy sang tối đa 4 quái kế tiếp (5 mục tiêu, mỗi bước ≤ 15 m), mỗi quái ×1,2."},
			{"id": "banglao", "unlock": 1, "name": "Băng Lao", "cd": 6.0, "mp": 15, "mul": 1.5, "icon": "banglao", "replaces": "dichchuyen",
				"text": "Mũi băng bay thẳng 40 m, xuyên quái, ×1,5, làm chậm quái 3 giây."},
			{"id": "meteor", "unlock": 4, "name": "Thiên Thạch", "cd": 10.0, "mp": 30, "mul": 3.0, "icon": "meteor",
				"text": "Vòng báo hiệu 10 m tại điểm ngắm; 0,8 giây sau thiên thạch rơi ×3,0."},
			{"id": "barrier", "unlock": 8, "name": "Pháp Thuẫn", "cd": 20.0, "mp": 25, "mul": 0.0, "icon": "barrier",
				"text": "Khiên 6 giây hút sát thương tới 30% HP tối đa."},
			{"id": "hoatuong", "unlock": 15, "name": "Hoả Tường", "cd": 10.0, "mp": 25, "mul": 0.4, "icon": "hoatuong",
				"text": "Dựng tường lửa dài 12 m tại điểm ngắm, 4 giây; quái trong tường ×0,4 mỗi 0,5 giây."},
			{"id": "nova", "unlock": 22, "name": "Băng Ngục", "cd": 9.0, "mp": 20, "mul": 1.4, "icon": "nova",
				"text": "Băng nổ quanh mình 11 m, ×1,4, trói quái 2 giây."},
			{"id": "muabang", "unlock": 30, "job": true, "name": "Mưa Băng", "cd": 9.0, "mp": 30, "mul": 0.5, "icon": "muabang",
				"text": "(Pháp Sư Nguyên Tố) Mưa băng 9 m tại điểm ngắm, 5 đợt ×0,5, làm chậm quái."},
			{"id": "causam", "unlock": 30, "job": true, "name": "Cầu Sấm", "cd": 11.0, "mp": 35, "mul": 0.5, "icon": "causam",
				"text": "(Pháp Sư Nguyên Tố) Quả cầu sấm bay chậm 25 m, phóng sét quái trong 8 m mỗi 0,3 giây ×0,5, cuối đường nổ ×1,5."},
			{"id": "thienhoa", "unlock": 45, "ultimate": true, "name": "Thiên Tai Nguyên Tố", "cd": 60.0, "mp": 50, "mul": 1.0, "icon": "thienhoa",
				"text": "(Tối thượng) Lửa, băng, sét lần lượt giáng xuống điểm ngắm: thiên thạch vòng 12 m ×4,0 → băng nổ ×3,0 làm chậm → sét nảy 5 quái ×3,0 (tổng 1000%)."},
			{"id": "thienloi", "unlock": 60, "job2": "dai-phap-su", "name": "Thiên Lôi", "cd": 10.0, "mp": 35, "mul": 2.0, "icon": "thienloi",
				"text": "(Đại Pháp Sư) Sét trời đánh tối đa 6 quái trong 40 m, mỗi quái ×2,0."},
			{"id": "bangphong", "unlock": 60, "job2": "dai-phap-su", "name": "Băng Phong Thiên Hạ", "cd": 14.0, "mp": 35, "mul": 1.5, "icon": "bangphong",
				"text": "(Đại Pháp Sư) Băng nổ 14 m quanh mình ×1,5, trói quái 3 giây."},
			{"id": "trieuhoi", "unlock": 60, "job2": "tu-linh-su", "name": "Triệu Hồi Xương", "cd": 20.0, "mp": 40, "mul": 0.0, "icon": "trieuhoi",
				"text": "(Tử Linh Sư) Gọi 3 Xương Nô chiến đấu 15 giây (ngoài giới hạn 3 của Tử Linh)."},
			{"id": "khidoc", "unlock": 60, "job2": "tu-linh-su", "name": "Khí Độc Tử Vong", "cd": 12.0, "mp": 30, "mul": 0.25, "icon": "khidoc",
				"text": "(Tử Linh Sư) Vùng khí độc 10 m tại điểm ngắm 5 giây, ×0,25 mỗi 0,5 giây + độc cộng dồn."},
			# J3 (docs/23): Thần Kỹ — mở khi đã chuyển chức 3 (cấp 90)
			{"id": "nguhanh", "unlock": 90, "job3": true, "name": "Ngũ Hành Luân Chuyển", "cd": 30.0, "mp": 40, "mul": 0.75, "icon": "nguhanh",
				"text": "(Thần Kỹ · Hiền Giả) 6 giây: 5 cầu Kim, Mộc, Thủy, Hỏa, Thổ quay 5 m quanh quái gần điểm ngắm (30 m), chạm quái ×0,75 (mỗi quái 0,5 giây một lần); cầu khắc hệ quái +30%."},
		],
	},
	## LH1 (docs/19 mục 2): kịch bản mục 4 — đỡ đòn, hỗ trợ, chỉ số chính Thể lực.
	"ho-ve": {
		"name": "Hộ Vệ",
		"role": "Đỡ đòn, hỗ trợ",
		"main": "VIT · STR",
		"sprite": "hero-ho-ve",
		"description": "Chùy và khiên: máu dày nhất, nhận ít hơn 15% sát thương. Kéo quái về mình, choáng và phản đòn.",
		"range": "melee",
		"auto": ["vit", "str", "vit", "str", "vit"],
		"auto_text": "3 VIT : 2 STR",
		"basic": {"name": "Đập Khiên", "icon": "bash", "kind": "slash"},
		"skills": [
			{"id": "khienchan", "unlock": 1, "name": "Khiên Chấn", "cd": 5.0, "mp": 15, "mul": 2.2, "icon": "khienchan",
				"text": "Đập khiên nón 90° 9 m ×2,2, choáng quái thường 1 giây."},
			{"id": "khieukhich", "unlock": 1, "name": "Khiêu Khích", "cd": 9.0, "mp": 20, "mul": 1.5, "icon": "khieukhich",
				"text": "Gầm vòng 12 m ×1,5, kéo quái thường về sát mình; boss/tinh anh nhận gấp đôi vào thanh Phá Thế."},
			{"id": "laokhien", "unlock": 4, "name": "Lao Khiên", "cd": 8.0, "mp": 20, "mul": 1.8, "icon": "laokhien",
				"text": "Lao 18 m theo hướng ngắm ×1,8 mọi quái trên đường, đẩy lùi 4 m; bất tử khi lao."},
			# CL2 (docs/21 mục 6, charactors.md): Khiên Thép, Chấn Địa choáng, Thành Bất Diệt
			{"id": "khienthep", "unlock": 8, "name": "Khiên Thép", "cd": 20.0, "mp": 25, "mul": 0.0, "icon": "khienthep",
				"text": "10 giây: +30% Phòng thủ."},
			{"id": "chandia", "unlock": 15, "name": "Chấn Địa", "cd": 8.0, "mp": 20, "mul": 1.5, "icon": "chandia",
				"text": "Đập khiên xuống đất vòng 10 m ×1,5, choáng quái thường 2 giây; boss/tinh anh nhận gấp đôi vào thanh Phá Thế."},
			{"id": "phanthuan", "unlock": 22, "name": "Phi Thuẫn", "cd": 7.0, "mp": 20, "mul": 1.1, "icon": "phanthuan",
				"text": "Ném khiên xuyên 30 m rồi bay về, mỗi lượt ×1,1."},
			{"id": "phanquyet", "unlock": 30, "job": true, "name": "Phán Quyết", "cd": 9.0, "mp": 25, "mul": 2.4, "icon": "phanquyet",
				"text": "(Hiệp Sĩ) Búa ánh sáng giáng xuống điểm ngắm, vòng 8 m ×2,4."},
			{"id": "xungphong", "unlock": 30, "job": true, "name": "Xung Phong", "cd": 10.0, "mp": 25, "mul": 1.6, "icon": "xungphong",
				"text": "(Hiệp Sĩ) Lao 25 m ×1,6, quái thường trúng choáng 1,5 giây."},
			{"id": "thanhbatdiet", "unlock": 45, "ultimate": true, "name": "Thành Bất Diệt", "cd": 60.0, "mp": 50, "mul": 0.3, "icon": "thanhbatdiet",
				"text": "(Tối thượng) 8 giây: nhận ít hơn 80% sát thương, hào quang 12 m ×0,3 mỗi 0,5 giây."},
			{"id": "thanhquang", "unlock": 60, "job2": "thanh-ky-si", "name": "Thánh Quang Trảm", "cd": 9.0, "mp": 30, "mul": 3.0, "icon": "thanhquang",
				"text": "(Thánh Kỵ Sĩ) Nón ánh sáng 120° 11 m ×3,0, hồi HP bằng 15% sát thương gây ra."},
			{"id": "thanhvuc", "unlock": 60, "job2": "thanh-ky-si", "name": "Thánh Vực", "cd": 14.0, "mp": 35, "mul": 0.4, "icon": "thanhvuc",
				"text": "(Thánh Kỵ Sĩ) Vùng 10 m đi theo mình 5 giây, ×0,4 mỗi 0,5 giây, mỗi nhịp hồi 1,5% HP."},
			{"id": "thietchuy", "unlock": 60, "job2": "thiet-ve", "name": "Thiết Chuỳ Phá Địa", "cd": 10.0, "mp": 30, "mul": 2.6, "icon": "thietchuy",
				"text": "(Thiết Vệ) Đập đất vòng 12 m ×2,6, choáng quái thường 1,5 giây."},
			{"id": "thanhdong", "unlock": 60, "job2": "thiet-ve", "name": "Thành Đồng", "cd": 14.0, "mp": 35, "mul": 1.8, "icon": "thanhdong",
				"text": "(Thiết Vệ) Nổ khiên vòng 9 m ×1,8 + khiên chắn 20% HP tối đa trong 6 giây."},
			# J3 (docs/23): Thần Kỹ — mở khi đã chuyển chức 3 (cấp 90)
			{"id": "thienthuan", "unlock": 90, "job3": true, "name": "Thiên Thuẫn Giáng Thế", "cd": 30.0, "mp": 40, "mul": 5.5, "icon": "thienthuan",
				"text": "(Thần Kỹ · Thủ Hộ Thần) Khiên thần giáng xuống vòng 12 m ×5,5, choáng 2 giây (boss: vào thanh Phá Thế ×2); sau đó khiên chắn 30% HP tối đa trong 6 giây."},
		],
	},
	## LH2 (docs/19 mục 3, CR-03): đánh xa, linh thú gây phần lớn sát thương. Kỹ năng gọi linh thú: mul = hệ số
	## Tấn công của linh thú so với người chơi.
	"trieu-hoi-su": {
		"name": "Triệu Hồi Sư",
		"role": "Triệu hồi linh thú",
		"main": "INT",
		"sprite": "hero-trieu-hoi-su",
		"description": "Luôn có Linh Hồ đi cùng; gọi Sói Bóng, Tiểu Quỷ, Thạch Quỷ chiến đấu thay mình. Máu mỏng — đứng xa và tăng sức cho linh thú.",
		"range": "ranged",
		"auto": ["int", "int", "vit", "int", "wis"],
		"auto_text": "3 INT : 2 VIT",
		"basic": {"name": "Linh Cầu", "icon": "spiritorb", "kind": "spirit"},
		"skills": [
			{"id": "soibong", "unlock": 1, "name": "Triệu Hồi Sói Bóng", "cd": 20.0, "mp": 20, "mul": 0.9, "icon": "soibong",
				"text": "Gọi 1 Sói Bóng chiến đấu 20 giây, Tấn công ×0,9."},
			{"id": "linhtien", "unlock": 1, "name": "Linh Tiễn", "cd": 5.0, "mp": 15, "mul": 0.45, "icon": "linhtien",
				"text": "5 tia linh hồn toả 40°, bay 35 m, mỗi tia ×0,7."},
			{"id": "tieuquy", "unlock": 4, "name": "Triệu Hồi Tiểu Quỷ", "cd": 16.0, "mp": 20, "mul": 0.4, "icon": "tieuquy",
				"text": "Gọi 3 Tiểu Quỷ đánh xa 20 m trong 12 giây, Tấn công ×0,4."},
			{"id": "lienket", "unlock": 8, "name": "Liên Kết Linh Hồn", "cd": 20.0, "mp": 25, "mul": 0.0, "icon": "lienket",
				"text": "8 giây: linh thú +40% sát thương, mình +20% sát thương."},
			{"id": "thachquy", "unlock": 15, "name": "Gọi Thạch Quỷ", "cd": 20.0, "mp": 30, "mul": 1.4, "icon": "thachquy",
				"text": "Gọi 1 Thạch Quỷ 15 giây, Tấn công ×1,4, mỗi đòn nổ lan 5 m."},
			{"id": "hoadieu", "unlock": 22, "name": "Hoả Điểu", "cd": 7.0, "mp": 20, "mul": 1.8, "icon": "hoadieu",
				"text": "Chim lửa bay thẳng 40 m xuyên quái ×1,8, thiêu 3 giây."},
			{"id": "linhtran", "unlock": 30, "job": true, "name": "Linh Trận", "cd": 10.0, "mp": 30, "mul": 0.45, "icon": "linhtran",
				"text": "(Linh Sư) Trận 9 m tại điểm ngắm 4 giây, ×0,45 mỗi 0,5 giây; linh thú trong trận +30% sát thương."},
			{"id": "linhung", "unlock": 30, "job": true, "name": "Gọi Linh Ưng", "cd": 16.0, "mp": 25, "mul": 0.7, "icon": "linhung",
				"text": "(Linh Sư) Gọi 2 Linh Ưng đánh xa 25 m trong 12 giây, Tấn công ×0,7."},
			{"id": "quandoan", "unlock": 45, "ultimate": true, "name": "Quân Đoàn Linh Hồn", "cd": 60.0, "mp": 50, "mul": 0.45, "icon": "quandoan",
				"text": "(Tối thượng) Gọi 10 linh hồn chiến đấu 15 giây, Tấn công ×0,45 (tối đa 12 linh thú cùng lúc)."},
			{"id": "aulong", "unlock": 60, "job2": "ngu-long-su", "name": "Gọi Ấu Long", "cd": 24.0, "mp": 40, "mul": 1.8, "icon": "aulong",
				"text": "(Ngự Long Sư) Gọi Ấu Long 18 giây: phun lửa xa 22 m, Tấn công ×1,8, nổ lan 6 m."},
			{"id": "longhong", "unlock": 60, "job2": "ngu-long-su", "name": "Long Hống", "cd": 10.0, "mp": 30, "mul": 2.4, "icon": "longhong",
				"text": "(Ngự Long Sư) Rồng gầm vòng 12 m quanh mình ×2,4; có Ấu Long thì nó gầm thêm 1 lần tại chỗ nó."},
			{"id": "loidodang", "unlock": 60, "job2": "do-dang-su", "name": "Lôi Đồ Đằng", "cd": 12.0, "mp": 30, "mul": 0.5, "icon": "loidodang",
				"text": "(Đồ Đằng Sư) Cắm cột tại điểm ngắm 10 giây, sét quái gần nhất trong 15 m mỗi 0,5 giây ×0,5."},
			{"id": "phongdodang", "unlock": 60, "job2": "do-dang-su", "name": "Phong Đồ Đằng", "cd": 14.0, "mp": 30, "mul": 0.35, "icon": "phongdodang",
				"text": "(Đồ Đằng Sư) Cột 8 giây vòng 10 m: ×0,35 mỗi 0,5 giây, làm chậm quái; linh thú trong vòng +40% tốc đánh."},
			# J3 (docs/23): Thần Kỹ — mở khi đã chuyển chức 3 (cấp 90)
			{"id": "kylan", "unlock": 90, "job3": true, "name": "Kỳ Lân Giáng Thế", "cd": 30.0, "mp": 40, "mul": 1.4, "icon": "kylan",
				"text": "(Thần Kỹ · Vạn Linh Chi Chủ) Gọi Kỳ Lân Thần Thú 12 giây: đánh xa 25 m, nổ lan 7 m, ×1,4, không tính vào giới hạn; hồi đầy máu mọi linh thú."},
		],
	},
}


## C3-43, C3-44 (M6, docs/10): chuyển chức 1 ở cấp 30. Mọi chức +10% HP và Tấn công.
const JOB_LEVEL := 30
const JOB_BONUS := 0.10
const JOBS := {
	"kiem-khach": {"id": "kiem-su", "name": "Kiếm Sư",
		"text": "Đòn chém thứ 4 phóng kiếm khí ×0,8 (bay 25 m, xuyên); Xoáy Kiếm +30% bán kính."},
	"tho-san": {"id": "xa-thu", "name": "Xạ Thủ",
		"text": "Mỗi phát bắn thêm 1 mũi tên phụ ×0,5 vào quái gần thứ 2; Tên Xuyên Phá hồi chiêu 6 → 4 giây."},
	"phap-su": {"id": "phap-su-nguyen-to", "name": "Pháp Sư Nguyên Tố",
		"text": "Hỏa Cầu tự đổi sang hệ khắc mục tiêu (+30%); Lôi Xích nảy thêm 2 lần."},
	"ho-ve": {"id": "hiep-si", "name": "Hiệp Sĩ",
		"text": "Mỗi đòn thứ 4 phóng sóng khiên 25 m xuyên quái ×0,8 và choáng quái thường trước mặt 0,8 giây."},
	"trieu-hoi-su": {"id": "linh-su", "name": "Linh Sư",
		"text": "Thêm 1 Linh Hồ thường trực; linh thú +20% sát thương."},
}


## C5-45, C5-46 (M8): chuyển chức 2 — chọn 1 trong 2 nhánh (kịch bản mục 4, Q51). Lưu ở profile.job2.
const JOB2_LEVEL := 60
const JOB2_BONUS := 0.10
const JOB2_CRYSTAL := 30
const JOBS2 := {
	"kiem-khach": [
		{"id": "kiem-thanh", "name": "Kiếm Thánh", "color": "#ffd76a",
			"text": "Mỗi đòn chém thứ 3 phóng thêm kiếm khí ×1,0; sát thương vào thanh Phá Thế +40%."},
		{"id": "huyet-kiem", "name": "Huyết Kiếm", "color": "#ff4a5a",
			"text": "Hút máu 6% sát thương gây ra; dưới 50% HP +20% sát thương."},
	],
	"tho-san": [
		{"id": "than-tien", "name": "Thần Tiễn", "color": "#8fd8ff",
			"text": "+10% chí mạng, sát thương chí mạng ×1,2; Tên Xuyên Phá hồi chiêu thêm −1 giây."},
		{"id": "tho-bay", "name": "Thợ Bẫy", "color": "#9ad46a",
			"text": "Đặt tối đa 4 bẫy, bẫy tồn tại 40 giây; bẫy khi kích nổ thêm vòng 4 m ×1,5."},
	],
	"phap-su": [
		{"id": "dai-phap-su", "name": "Đại Pháp Sư", "color": "#c89aff",
			"text": "Thiên Thạch rơi 2 viên (viên thứ 2 ×0,6); +30% hồi MP."},
		{"id": "tu-linh-su", "name": "Tử Linh Sư", "color": "#9a8a6a",
			"text": "Quái thường bị hạ 20% dựng thành Xương Nô 12 giây (tối đa 3); mỗi Xương Nô +5% sát thương."},
	],
	"ho-ve": [
		{"id": "thanh-ky-si", "name": "Thánh Kỵ Sĩ", "color": "#ffe9a0",
			"text": "Hút máu 5% sát thương gây ra; HP trên 70% thì +15% sát thương."},
		{"id": "thiet-ve", "name": "Thiết Vệ", "color": "#a8b4c4",
			"text": "Nhận ít hơn thêm 15% sát thương; phản 30% sát thương bị đánh lên quái đánh mình."},
	],
	"trieu-hoi-su": [
		{"id": "ngu-long-su", "name": "Ngự Long Sư", "color": "#ff7a3a",
			"text": "Linh Hồ hoá Hoả Hồ: mỗi đòn nổ lan 4 m; linh thú +20% sát thương."},
		{"id": "do-dang-su", "name": "Đồ Đằng Sư", "color": "#7ad0a0",
			"text": "Đồ đằng tồn tại lâu hơn 50%; đứng trong 12 m quanh đồ đằng: hồi 2% HP và 2% MP mỗi giây."},
	],
}


## J3 (docs/23, 17 C8-45): chuyển chức 3 — hai nhánh chức 2 hợp về một chức. Lưu ở profile.job3.
## Bản tạm khi chưa có chương 8 (Q140): cấp 90 + chức 2 + 50 Tinh Thạch ở Liệt Diễm.
## M11 (docs/17 C8-45): bật JOB3_NEED_CH8 — thêm hạ Giáo Chủ Hư Vô + 3 Lõi Hư Vô, chuyển chức ở 5 Tổ Sư (Cổng Phá Vây).
const JOB3_LEVEL := 90
const JOB3_BONUS := 0.10
const JOB3_CRYSTAL := 50
const JOB3_NEED_CH8 := true
const JOB3_CORES := 3
## C8-45: Tổ Sư của từng lớp (id NPC ở 8-3, tên).
const JOB3_MASTERS := {"kiem-khach": ["to-su-kiem", "Kiếm Tổ Vô Danh"], "tho-san": ["to-su-tien", "Tiễn Tổ Lạc Nhật"],
	"phap-su": ["to-su-phap", "Pháp Tổ Huyền Cơ"], "ho-ve": ["to-su-thuan", "Thuẫn Tổ Bàn Thạch"], "trieu-hoi-su": ["to-su-linh", "Linh Tổ Vạn Hồn"]}
const JOBS3 := {
	"kiem-khach": {"id": "kiem-than", "name": "Kiếm Thần", "color": "#f2f6ff", "skill": "nhatkiem",
		"effects": ["Kỹ năng gây sát thương +15%.", "Vỡ Phá Thế: boss choáng 6 giây (thay 5) và nhận thêm 70% sát thương (thay 50%)."]},
	"tho-san": {"id": "thien-lac", "name": "Thiên Lạc Xạ Thủ", "color": "#f2f6ff", "skill": "tinhvu",
		"effects": ["Cứ phát bắn thường thứ 5 gọi thêm 1 mũi tên sao rơi xuống mục tiêu ×0,5.", "+10% chí mạng lên boss, boss hiếm, tinh anh."]},
	"phap-su": {"id": "hien-gia", "name": "Hiền Giả", "color": "#f2f6ff", "skill": "nguhanh",
		"effects": ["+30% hồi MP; phép vùng +15% bán kính.", "Cứ 3 lần dùng kỹ năng: kỹ năng kế tiếp không tốn MP, hồi chiêu −50%."]},
	"ho-ve": {"id": "thu-ho-than", "name": "Thủ Hộ Thần", "color": "#f2f6ff", "skill": "thienthuan",
		"effects": ["Bất Khuất: nhận ít hơn thêm 10%; HP dưới 30% → hồi 30% HP và miễn sát thương 2 giây (mỗi 60 giây).",
			"Thần Uy: mỗi đòn trúng 20% choáng quái thường 1 giây; sát thương vào thanh Phá Thế +50%."]},
	"trieu-hoi-su": {"id": "van-linh", "name": "Vạn Linh Chi Chủ", "color": "#f2f6ff", "skill": "kylan",
		"effects": ["Vạn Linh: tối đa linh thú +2; linh thú gọi bằng kỹ năng tồn tại lâu hơn 30%.",
			"Linh Hồn Bất Diệt: linh thú +15% sát thương, +50% HP; gục hoặc hết giờ thì nổ linh hồn 5 m ×0,3."]},
}


static func job3_def(class_id: String) -> Dictionary:
	return JOBS3.get(class_id, {})


static func job2_defs(class_id: String) -> Array:
	return JOBS2.get(class_id, [])


static func job2_def(class_id: String, job2: String) -> Dictionary:
	for j in job2_defs(class_id):
		if j.id == job2:
			return j
	return {}


## SK1 (docs/13): hệ kỹ năng — mở theo cấp, Điểm Kỹ Năng (1/cấp), cấp kỹ năng 1–10, 4 ô lắp.
## SN12-02 (docs/31): 7 ô kỹ năng — ô 0–3 phím 1–4; ô 4 phím 5 (mở khi chuyển chức 1); ô 5 phím 6 (chuyển chức 2);
## ô 6 = ô Tuyệt kỹ phím G (cấp 45), chỉ lắp Tối thượng hoặc Thần Kỹ. Ô trống = "".
const SKILL_SLOTS := 7
## Số ô bộ lắp mặc định / bộ cũ (save < v27).
const BASE_SLOTS := 4
const SLOT_ULT := 6
const ULT_SLOT_LEVEL := 45
const SLOT_KEYS := ["1", "2", "3", "4", "5", "6", "G"]
const SKILL_MAX_LEVEL := 10
## Kỹ năng gây sát thương: +8% hệ số mỗi cấp. Kỹ năng hỗ trợ (mul = 0): −4% hồi chiêu mỗi cấp.
const SKILL_LEVEL_MUL := 0.08
const SKILL_LEVEL_CD := 0.04


static func skills_of(class_id: String) -> Array:
	return get_class_def(class_id).skills


static func skill_by_id(class_id: String, id: String) -> Dictionary:
	for sk in skills_of(class_id):
		if sk.id == id:
			return sk
	return {}


## Thứ tự lắp mặc định = 4 kỹ năng đầu trong dữ liệu; ô 5, 6, Tuyệt kỹ để trống (SN12-02).
static func default_loadout(class_id: String) -> Array:
	var out: Array = []
	for sk in skills_of(class_id):
		if out.size() < BASE_SLOTS:
			out.append(str(sk.id))
	while out.size() < SKILL_SLOTS:
		out.append("")
	return out


## SN12-02: kỹ năng lắp được vào ô Tuyệt kỹ (Tối thượng, Thần Kỹ).
static func is_ult(sk: Dictionary) -> bool:
	return bool(sk.get("ultimate", false)) or bool(sk.get("job3", false))


static func job_def(class_id: String) -> Dictionary:
	return JOBS.get(class_id, {})


## Tên hiển thị: tên chức 3 / chức 2 / chức 1 nếu đã chuyển, không thì tên lớp.
static func title(class_id: String, job: String, job2 := "", job3 := "") -> String:
	var j3 := job3_def(class_id)
	if job3 != "" and not j3.is_empty() and j3.id == job3:
		return str(j3.name)
	var j2 := job2_def(class_id, job2)
	if not j2.is_empty():
		return str(j2.name)
	var j := job_def(class_id)
	if job != "" and not j.is_empty() and j.id == job:
		return str(j.name)
	return str(get_class_def(class_id).name)


## D51: lớp đánh xa (bot giữ khoảng cách, Tự đánh lùi lại, boss xét tầm với xa).
static func is_ranged(class_id: String) -> bool:
	return str(get_class_def(class_id).get("range", "melee")) == "ranged"


static func get_class_def(class_id: String) -> Dictionary:
	return DEFS.get(class_id, DEFS["kiem-khach"])


static func skill(class_id: String, index: int) -> Dictionary:
	return get_class_def(class_id).skills[index]
