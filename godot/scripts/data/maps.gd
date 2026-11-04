extends RefCounted
## M4 (03-mvp-spec mục 6): 9 vùng của lục địa Huyền Thổ và các map con đã làm.
## SN-30: mọi map ×1,6 mỗi chiều so với M4 (Spec_Notes S6) — kích thước, vị trí làng/hang, zone_x, số cây.
## Một map là dữ liệu: kích thước, cấp quái theo vị trí, vùng an toàn, hang boss, tường sương mù, bảng quái, môi trường.
##
## level_at(x) = clamp(levels[0] + floor((x - zone_x0) / zone_dx), levels[0], levels[1])
## mobs: [[loại quái, cấp tối thiểu, trọng số], ...] — "legacy" = giữ cách chọn quái của prototype (map 1-1).
## safe.kind: "village" | "town" | "camp". arena: hang boss (null nếu không có); gate: tường sương mù trước hang.

const REGIONS := [
	{"id": 1, "name": "Làng Thanh Thạch & Rừng Sương", "levels": [1, 10], "element": "moc", "maps": ["1-1", "1-3"]},
	{"id": 2, "name": "Đồng Bằng Gió Hú", "levels": [10, 20], "element": "kim", "maps": ["2-1", "2-2", "2-3"], "unlock": "Hạ Sói Chúa · cấp 10 · khai phá vùng 1 ≥ 60%"},
	{"id": 3, "name": "Sa Mạc Xích Sa", "levels": [20, 32], "element": "tho", "maps": ["3-1", "3-2", "3-3"], "unlock": "Hạ Huyền Ảnh · Lực chiến 5.000 · cấp 18"},
	{"id": 4, "name": "Đầm Lầy U Minh", "levels": [32, 45], "element": "thuy", "maps": ["4-1", "4-2", "4-3"], "unlock": "Hạ Sa Hoàng · chuyển chức 1"},
	{"id": 5, "name": "Núi Viêm Long", "levels": [45, 60], "element": "hoa", "maps": ["5-1", "5-2", "5-3"], "unlock": "Hạ Nữ Vương · Thiên phú tiến hoá 1 lần · cấp 44"},
	{"id": 6, "name": "Băng Nguyên Bắc Cực", "levels": [60, 72], "element": "thuy", "maps": ["6-1", "6-2", "6-3"], "unlock": "Chuyển chức 2 · hạ Viêm Long · cấp 59"},
	{"id": 7, "name": "Quần Đảo Thiên Không", "levels": [72, 84], "element": "kim", "maps": ["7-1", "7-2", "7-3"], "unlock": "Hoàng Thành + Cảng Khí Cầu · hạ Bản Ngã · cấp 71"},
	{"id": 8, "name": "Vực Hư Vô", "levels": [84, 95], "element": "", "maps": ["8-1", "8-2", "8-3"], "unlock": "Thiên phú tiến hoá 2 lần · hạ Cự Thần · cấp 83"},
	{"id": 9, "name": "Cổng Thiên Đạo", "levels": [95, 100], "element": "", "maps": ["9-1", "9-2", "9-3"], "unlock": "Chuyển chức 3 · hạ Giáo Chủ Hư Vô · cấp 94"},
]

const MAPS := {
	## Map của prototype — giữ nguyên toạ độ (Q35: gộp Bìa Rừng + Rừng Sâu).
	"1-1": {
		"region": 1,
		"name": "Rừng Sương",
		"size": Vector2(4160, 2560),
		"levels": [1, 6],
		"zone_x": [720.0, 416.0],
		"safe": {"pos": Vector2(368, 1280), "r": 170.0, "name": "Làng Thanh Thạch", "kind": "village", "waypoint": Vector2(105, 88)},
		## NPC: [id, sprite, vị trí so với tâm vùng an toàn, tên hiển thị]
		"npcs": [["elder", "npc-elder", Vector2(48, 30), "Thạch Lão"], ["merchant", "npc-merchant", Vector2(-70, 70), "Thương nhân · E"]],
		"arena": {"pos": Vector2(3664, 1280), "r": 270.0, "boss": "boss", "level": 6, "chapter": 1, "name": "Hang Sói Chúa"},
		"gate": true,
		"mobs": "legacy",
		"ground": "tile-grass-0",
		"fog": 0.45,
		"tint": Color(0.16, 0.08, 0.27),
		"wind": 0.0,
		"trees": 614,
	},
	## Map 1-3: mở sau khi hạ Sói Chúa (Q25). Không có boss chương (boss hiếm Lão Thụ ở M5).
	"1-3": {
		"region": 1,
		"name": "Lõi Sương",
		"size": Vector2(3840, 2400),
		"levels": [7, 10],
		"zone_x": [800.0, 720.0],
		"safe": {"pos": Vector2(352, 1200), "r": 140.0, "name": "Trạm Gác Lõi Sương", "kind": "camp"},
		"arena": null,
		"gate": false,
		"mobs": [["wolf", 7, 25], ["wisp", 7, 35], ["moc-tinh", 7, 30], ["mushroom", 7, 10]],
		"ground": "tile-grass-2",
		"fog": 0.6,
		"tint": Color(0.18, 0.1, 0.3),
		"wind": 0.0,
		"trees": 768,
	},
	## M4.2: vùng 2 Đồng Bằng Gió Hú (06 vùng 2). wind = chu kỳ đổi hướng gió (giây), 0 = không gió.
	"2-1": {
		"region": 2,
		"name": "Cửa Gió",
		"size": Vector2(4480, 2560),
		"levels": [10, 13],
		"zone_x": [800.0, 960.0],
		"safe": {"pos": Vector2(480, 1280), "r": 230.0, "name": "Thành Biên Đài", "kind": "town"},
		"npcs": [["lac-phong", "npc-lac-phong", Vector2(40, -40), "Lạc Phong · E"], ["thiet-nguu", "npc-thiet-nguu", Vector2(-90, 60), "Thiết Ngưu · E"],
			["mac-tam", "npc-mac-tam", Vector2(70, 90), "Mạc Tam · E"]],
		"arena": null,
		"gate": false,
		"mobs": [["ung-gio", 10, 40], ["linh-danh-thue", 11, 35], ["cung-thu", 12, 25]],
		"ground": "tile-plain",
		"fog": 0.15,
		"tint": Color(0.3, 0.26, 0.08),
		"wind": 12.0,
		"trees": 282,
		"decor": "plains",
	},
	"2-2": {
		"region": 2,
		"name": "Thảo Nguyên Hú",
		"size": Vector2(4480, 2560),
		"levels": [13, 17],
		"zone_x": [720.0, 800.0],
		"safe": {"pos": Vector2(352, 1280), "r": 140.0, "name": "Trạm Gió", "kind": "camp"},
		"arena": null,
		"gate": false,
		"mobs": [["ung-gio", 13, 25], ["linh-danh-thue", 13, 25], ["cung-thu", 13, 30], ["loc-xoay", 14, 20]],
		"ground": "tile-plain",
		"fog": 0.2,
		"tint": Color(0.3, 0.26, 0.08),
		"wind": 12.0,
		"trees": 307,
		"decor": "plains",
	},
	"2-3": {
		"region": 2,
		"name": "Mắt Bão",
		"size": Vector2(4480, 2560),
		"levels": [17, 20],
		"zone_x": [720.0, 880.0],
		"safe": {"pos": Vector2(352, 1280), "r": 140.0, "name": "Trạm Mắt Bão", "kind": "camp"},
		"arena": {"pos": Vector2(3872, 1280), "r": 280.0, "boss": "huyen-anh", "level": 18, "chapter": 2, "name": "Phủ Huyền Ảnh"},
		"gate": true,
		"mobs": [["ung-gio", 17, 20], ["linh-danh-thue", 17, 25], ["cung-thu", 17, 25], ["loc-xoay", 17, 30]],
		"ground": "tile-plain",
		"fog": 0.35,
		"tint": Color(0.22, 0.2, 0.3),
		"wind": 8.0,
		"trees": 230,
		"decor": "plains",
	},
	## M6 (docs/10): vùng 3 Sa Mạc Xích Sa. oases: [[tâm, bán kính], …] — ốc đảo an toàn khỏi nắng, quái không đuổi vào.
	## desert: bật ngày/đêm, nắng gắt, bão cát (core/chapter3.gd).
	"3-1": {
		"region": 3,
		"name": "Rìa Cát Đỏ",
		"size": Vector2(4480, 2560),
		"levels": [20, 24],
		"zone_x": [720.0, 700.0],
		"safe": {"pos": Vector2(420, 1280), "r": 200.0, "name": "Trại Cát Đỏ", "kind": "camp"},
		"npcs": [["sa-lao", "npc-sa-lao", Vector2(40, -40), "Sa Lão · E"], ["a-moc", "npc-a-moc", Vector2(-80, 60), "A Mộc · E"],
			["thach-thu", "npc-thach-thu", Vector2(80, 80), "Thạch Thủ · E"]],
		"arena": null,
		"gate": false,
		"mobs": [["bo-cat", 20, 45], ["ran-cat", 21, 40], ["xac-uop", 23, 15]],
		"ground": "tile-sand",
		"fog": 0.08,
		"tint": Color(0.4, 0.22, 0.08),
		"wind": 0.0,
		"trees": 0,
		"decor": "desert",
		"desert": true,
		"oases": [[Vector2(2400, 700), 110.0]],
	},
	"3-2": {
		"region": 3,
		"name": "Ốc Đảo Lãng Quên",
		"size": Vector2(4480, 2560),
		"levels": [24, 28],
		"zone_x": [720.0, 700.0],
		"safe": {"pos": Vector2(352, 1280), "r": 140.0, "name": "Trạm Ốc Đảo", "kind": "camp"},
		"arena": null,
		"gate": false,
		"mobs": [["bo-cat", 24, 25], ["ran-cat", 24, 30], ["xac-uop", 24, 30], ["phap-su-cat", 26, 15]],
		"ground": "tile-sand",
		"fog": 0.1,
		"tint": Color(0.4, 0.22, 0.08),
		"wind": 0.0,
		"trees": 0,
		"decor": "desert",
		"desert": true,
		"oases": [[Vector2(1300, 600), 120.0], [Vector2(2600, 1950), 120.0], [Vector2(3700, 900), 120.0]],
	},
	"3-3": {
		"region": 3,
		"name": "Di Tích Khai Giới Giả",
		"size": Vector2(4480, 2560),
		"levels": [28, 32],
		"zone_x": [720.0, 560.0],
		"safe": {"pos": Vector2(352, 1280), "r": 140.0, "name": "Cổng Di Tích", "kind": "camp"},
		"arena": {"pos": Vector2(3872, 1280), "r": 280.0, "boss": "sa-hoang", "level": 30, "chapter": 3, "name": "Sào Huyệt Sa Hoàng"},
		"gate": true,
		"mobs": [["ran-cat", 28, 20], ["xac-uop", 28, 35], ["phap-su-cat", 28, 30], ["bo-cat", 28, 15]],
		"ground": "tile-ruins",
		"fog": 0.12,
		"tint": Color(0.3, 0.16, 0.1),
		"wind": 0.0,
		"trees": 0,
		"decor": "ruins",
		"desert": true,
		"oases": [[Vector2(1800, 1900), 100.0]],
		## C3-41 bước 4: Bia Khai Giới Giả
		"stele3": Vector2(2100, 900),
	},
	## M7 (docs/11): vùng 4 Đầm Lầy U Minh. water: {default: map mặc định là nước?, zones: [[tâm, r], …] chỗ ngược lại}.
	## pods: Bọc Mộng của nhiệm vụ chương 4 bước 3 (4-2).
	"4-1": {
		"region": 4,
		"name": "Bãi Lau Mù",
		"size": Vector2(4480, 2560),
		"levels": [32, 36],
		"zone_x": [720.0, 700.0],
		"safe": {"pos": Vector2(420, 1280), "r": 200.0, "name": "Làng Chài Lau", "kind": "camp"},
		"npcs": [["lao-ngu", "npc-lao-ngu", Vector2(40, -40), "Lão Ngư · E"], ["lam-nhi", "npc-lam-nhi", Vector2(-80, 60), "Lam Nhi · E"],
			["tinh-quang", "npc-tinh-quang", Vector2(80, 80), "Tinh Quang Sứ · E"]],
		"arena": null,
		"gate": false,
		"mobs": [["ech-doc", 32, 40], ["dia", 33, 40], ["hon-ma", 35, 20]],
		"ground": "tile-swamp",
		"fog": 0.3,
		"tint": Color(0.12, 0.22, 0.2),
		"wind": 0.0,
		"trees": 260,
		"decor": "swamp",
		"water": {"default": false, "zones": [[Vector2(1400, 700), 180.0], [Vector2(2200, 1700), 220.0], [Vector2(3100, 900), 200.0],
			[Vector2(3600, 1900), 180.0], [Vector2(900, 1950), 150.0], [Vector2(2700, 420), 140.0]]},
	},
	"4-2": {
		"region": 4,
		"name": "Đầm Sâu",
		"size": Vector2(4480, 2560),
		"levels": [36, 41],
		"zone_x": [720.0, 600.0],
		"safe": {"pos": Vector2(352, 1280), "r": 150.0, "name": "Cồn Lau", "kind": "camp"},
		"arena": null,
		"gate": false,
		"mobs": [["ech-doc", 36, 25], ["dia", 36, 30], ["hon-ma", 36, 25], ["ca-sau", 38, 20]],
		"ground": "tile-swamp",
		"fog": 0.4,
		"tint": Color(0.1, 0.2, 0.22),
		"wind": 0.0,
		"trees": 200,
		"decor": "swamp",
		"water": {"default": true, "zones": [[Vector2(1000, 800), 170.0], [Vector2(1800, 1600), 200.0], [Vector2(2600, 700), 180.0],
			[Vector2(3300, 1500), 190.0], [Vector2(3900, 900), 160.0], [Vector2(700, 1950), 150.0], [Vector2(2300, 2150), 160.0]]},
		"pods": [Vector2(1000, 800), Vector2(1800, 1600), Vector2(2600, 700), Vector2(3300, 1500), Vector2(3900, 900)],
	},
	"4-3": {
		"region": 4,
		"name": "Cung Mộng",
		"size": Vector2(4480, 2560),
		"levels": [41, 45],
		"zone_x": [720.0, 560.0],
		"safe": {"pos": Vector2(352, 1280), "r": 140.0, "name": "Bờ Mộng", "kind": "camp"},
		"arena": {"pos": Vector2(3872, 1280), "r": 280.0, "boss": "nu-vuong", "level": 43, "chapter": 4, "name": "Cung Phệ Mộng"},
		"gate": true,
		"mobs": [["dia", 41, 20], ["hon-ma", 41, 35], ["ca-sau", 41, 35], ["ech-doc", 41, 10]],
		"ground": "tile-swamp",
		"fog": 0.5,
		"tint": Color(0.2, 0.12, 0.3),
		"wind": 0.0,
		"trees": 220,
		"decor": "swamp",
		"water": {"default": false, "zones": [[Vector2(1200, 600), 260.0], [Vector2(1500, 2000), 240.0], [Vector2(2400, 1300), 220.0],
			[Vector2(3000, 500), 200.0]]},
	},
	# ---------------------------------------------------------------- M8: vùng 5 Núi Viêm Long (06 vùng 5, docs/12)
	## lava: [[tâm, bán kính], …] — hồ dung nham (C5-10); "eruption": true — núi lửa phun (C5-11).
	"5-1": {
		"region": 5,
		"name": "Chân Núi Tro",
		"size": Vector2(4480, 2560),
		"levels": [45, 50],
		"zone_x": [720.0, 700.0],
		"safe": {"pos": Vector2(420, 1280), "r": 200.0, "name": "Trại Tro Hồng", "kind": "camp"},
		"npcs": [["xich-dong", "npc-xich-dong", Vector2(40, -40), "Xích Đồng · E"], ["kim-phu", "npc-kim-phu", Vector2(-80, 60), "Kim Phú · E"],
			["tieu-hoa", "npc-tieu-hoa", Vector2(-80, 60), "Tiểu Hoả · E"],
			["liet-dien", "npc-liet-dien", Vector2(80, 80), "Liệt Diễm · E"]],
		"arena": null,
		"gate": false,
		"mobs": [["than-lan-lua", 45, 45], ["nguoi-da", 47, 35], ["linh-hon-lua", 48, 20]],
		"ground": "tile-ash",
		"fog": 0.12,
		"tint": Color(0.3, 0.12, 0.08),
		"wind": 0.0,
		"trees": 140,
		"decor": "volcano",
		"lava": [[Vector2(1500, 700), 120.0], [Vector2(2300, 1900), 150.0], [Vector2(3200, 900), 130.0], [Vector2(3800, 1800), 110.0]],
	},
	"5-2": {
		"region": 5,
		"name": "Sườn Dung Nham",
		"size": Vector2(4480, 2560),
		"levels": [50, 55],
		"zone_x": [720.0, 600.0],
		"safe": {"pos": Vector2(352, 1280), "r": 150.0, "name": "Trạm Đá Đen", "kind": "camp"},
		"arena": null,
		"gate": false,
		"mobs": [["than-lan-lua", 50, 30], ["nguoi-da", 50, 30], ["linh-hon-lua", 51, 20], ["phap-su-hoa-diem", 52, 20]],
		"ground": "tile-basalt",
		"fog": 0.2,
		"tint": Color(0.32, 0.1, 0.06),
		"wind": 0.0,
		"trees": 110,
		"decor": "volcano",
		"eruption": true,
		## 2 dòng dung nham cắt ngang (chuỗi hồ nối nhau), chừa cầu đá ở giữa và trên lối mòn.
		"lava": [[Vector2(1600, 300), 120.0], [Vector2(1650, 560), 120.0], [Vector2(1700, 820), 110.0], [Vector2(1650, 1780), 110.0],
			[Vector2(1600, 2040), 120.0], [Vector2(1650, 2300), 120.0], [Vector2(3000, 300), 120.0], [Vector2(2950, 560), 120.0],
			[Vector2(2900, 830), 110.0], [Vector2(2950, 1760), 110.0], [Vector2(3000, 2020), 120.0], [Vector2(3050, 2290), 120.0]],
	},
	"5-3": {
		"region": 5,
		"name": "Miệng Núi Lửa",
		"size": Vector2(4480, 2560),
		"levels": [55, 60],
		"zone_x": [720.0, 560.0],
		"safe": {"pos": Vector2(352, 1280), "r": 140.0, "name": "Đỉnh Khói", "kind": "camp"},
		"arena": {"pos": Vector2(3872, 1280), "r": 280.0, "boss": "vien-long", "level": 58, "chapter": 5, "name": "Long Huyệt"},
		"gate": true,
		"mobs": [["than-lan-lua", 55, 25], ["nguoi-da", 55, 30], ["linh-hon-lua", 56, 20], ["phap-su-hoa-diem", 56, 25]],
		"ground": "tile-basalt",
		"fog": 0.3,
		"tint": Color(0.38, 0.08, 0.04),
		"wind": 0.0,
		"trees": 90,
		"decor": "volcano",
		"eruption": true,
		"lava": [[Vector2(1300, 600), 200.0], [Vector2(1400, 2000), 190.0], [Vector2(2400, 400), 170.0], [Vector2(2500, 2150), 170.0],
			[Vector2(3100, 1280), 150.0]],
	},
	# ---------------------------------------------------------------- M9: vùng 6 Băng Nguyên Bắc Cực (06 vùng 6, docs/14)
	## frost: băng giá + mặt băng trơn (C6-10, C6-12); night: đêm dài (C6-11); fires: lửa trại sưởi băng giá;
	## beacons: Đèn Cực Quang (nhiệm vụ bước 3, thắp rồi sưởi như lửa).
	"6-1": {
		"region": 6,
		"name": "Đồng Tuyết",
		"size": Vector2(4480, 2560),
		"levels": [60, 64],
		"zone_x": [720.0, 700.0],
		"safe": {"pos": Vector2(420, 1280), "r": 200.0, "name": "Trạm Tuyết Bạc", "kind": "camp"},
		"npcs": [["tuyet-nga", "npc-tuyet-nga", Vector2(40, -40), "Tuyết Nga · E"], ["lao-han", "npc-lao-han", Vector2(-80, 60), "Lão Hàn · E"],
			["lam-nhi-6", "npc-lam-nhi", Vector2(80, 80), "Lam Nhi · E"]],
		"arena": null,
		"gate": false,
		"mobs": [["soi-bang", 60, 45], ["nguoi-tuyet", 61, 35], ["tinh-linh-bang", 63, 20]],
		"ground": "tile-snow",
		"fog": 0.15,
		"tint": Color(0.16, 0.22, 0.32),
		"wind": 0.0,
		"trees": 170,
		"decor": "tundra",
		"frost": true,
		"night": true,
		"fires": [Vector2(370, 1330), Vector2(1500, 700), Vector2(2300, 1900), Vector2(3200, 900), Vector2(3900, 1700)],
	},
	"6-2": {
		"region": 6,
		"name": "Rừng Băng",
		"size": Vector2(4480, 2560),
		"levels": [64, 68],
		"zone_x": [720.0, 600.0],
		"safe": {"pos": Vector2(352, 1280), "r": 150.0, "name": "Lều Thợ Săn", "kind": "camp"},
		"arena": null,
		"gate": false,
		"mobs": [["soi-bang", 64, 30], ["nguoi-tuyet", 64, 30], ["tinh-linh-bang", 64, 20], ["cung-thu-bang", 65, 20]],
		"ground": "tile-snow",
		"fog": 0.25,
		"tint": Color(0.12, 0.2, 0.3),
		"wind": 0.0,
		"trees": 300,
		"decor": "tundra",
		"frost": true,
		"night": true,
		"fires": [Vector2(310, 1320), Vector2(2200, 1300)],
		"beacons": [Vector2(1500, 600), Vector2(2900, 2000), Vector2(3900, 900)],
	},
	"6-3": {
		"region": 6,
		"name": "Đỉnh Cực Quang",
		"size": Vector2(4480, 2560),
		"levels": [68, 72],
		"zone_x": [720.0, 560.0],
		"safe": {"pos": Vector2(352, 1280), "r": 140.0, "name": "Đài Cực Quang", "kind": "camp"},
		"arena": {"pos": Vector2(3872, 1280), "r": 280.0, "boss": "ban-nga", "level": 70, "chapter": 6, "name": "Gương Băng Vĩnh Dạ"},
		"gate": true,
		"mobs": [["soi-bang", 68, 25], ["nguoi-tuyet", 68, 25], ["tinh-linh-bang", 68, 25], ["cung-thu-bang", 68, 25]],
		"ground": "tile-ice",
		"fog": 0.3,
		"tint": Color(0.18, 0.14, 0.34),
		"wind": 0.0,
		"trees": 150,
		"decor": "tundra",
		"frost": true,
		"night": true,
		"fires": [Vector2(310, 1320), Vector2(1600, 600), Vector2(1700, 2000), Vector2(2800, 1280)],
	},
	## ---------------------------------------------------------------- M10 chương 7 (docs/16 C7-05…14)
	## islands: [[tâm, bán kính], …] (đảo đầu = đảo chính có trạm) · bridges: [[đảo a, đảo b], …] cầu gió rộng 6 m nối tâm 2 đảo,
	## tắt 5 giây mỗi 30 giây (lệch nhau theo thứ tự) · anchors: Đá Neo (điểm lưu; trạm luôn là Đá Neo) ·
	## pillars: Trụ Gió (7-2) · void_anchors: Neo Hư Vô (7-3) · crumble: đảo vụn sụp mép 1 m mỗi 10 giây (7-3) ·
	## solid: chỉ số cầu không bao giờ tắt (cầu vào đấu trường).
	"7-1": {
		"region": 7,
		"name": "Đảo Mây Trôi",
		"size": Vector2(4480, 2560),
		"levels": [72, 76],
		"zone_x": [900.0, 700.0],
		"safe": {"pos": Vector2(420, 1280), "r": 200.0, "name": "Bến Mây", "kind": "camp"},
		"npcs": [["van-hac", "npc-van-hac", Vector2(40, -40), "Vân Hạc · E"], ["phong-linh", "npc-phong-linh", Vector2(-80, 60), "Phong Linh · E"],
			["tuyet-nga-7", "npc-tuyet-nga", Vector2(80, 80), "Tuyết Nga · E"]],
		"arena": null,
		"gate": false,
		"mobs": [["dai-bang-may", 72, 40], ["nguoi-go-dao", 73, 35], ["tien-gio", 75, 25]],
		"ground": "tile-sky-grass",
		"fog": 0.12,
		"tint": Color(0.3, 0.42, 0.62),
		"wind": 0.0,
		"trees": 140,
		"decor": "sky",
		"islands": [[Vector2(520, 1280), 560.0], [Vector2(1420, 640), 360.0], [Vector2(1420, 1920), 360.0], [Vector2(2220, 1280), 440.0],
			[Vector2(3000, 640), 360.0], [Vector2(3000, 1920), 360.0], [Vector2(3720, 1280), 420.0], [Vector2(4180, 520), 260.0]],
		"bridges": [[0, 1], [0, 2], [1, 3], [2, 3], [3, 4], [3, 5], [4, 6], [5, 6], [6, 7]],
		"anchors": [Vector2(1420, 640), Vector2(2220, 1280), Vector2(3000, 1920), Vector2(3720, 1280)],
	},
	"7-2": {
		"region": 7,
		"name": "Đảo Rừng Treo",
		"size": Vector2(4480, 2560),
		"levels": [76, 80],
		"zone_x": [900.0, 650.0],
		"safe": {"pos": Vector2(352, 1280), "r": 150.0, "name": "Tổ Hạc Cổ", "kind": "camp"},
		"arena": null,
		"gate": false,
		"mobs": [["dai-bang-may", 76, 30], ["nguoi-go-dao", 76, 30], ["tien-gio", 76, 25], ["hiep-si-thien-khong", 78, 15]],
		"ground": "tile-sky-grass",
		"fog": 0.2,
		"tint": Color(0.24, 0.4, 0.42),
		"wind": 0.0,
		"trees": 260,
		"decor": "sky",
		"islands": [[Vector2(450, 1280), 480.0], [Vector2(1250, 1280), 330.0], [Vector2(1900, 560), 330.0], [Vector2(1900, 2000), 330.0],
			[Vector2(2600, 1280), 400.0], [Vector2(3300, 600), 330.0], [Vector2(3300, 1960), 330.0], [Vector2(3950, 1280), 380.0],
			[Vector2(4200, 520), 250.0]],
		"bridges": [[0, 1], [1, 2], [1, 3], [2, 4], [3, 4], [4, 5], [4, 6], [5, 7], [6, 7], [7, 8]],
		"anchors": [Vector2(1250, 1280), Vector2(2600, 1280), Vector2(3950, 1280)],
		"pillars": [Vector2(1900, 560), Vector2(1900, 2000), Vector2(3300, 600)],
	},
	"7-3": {
		"region": 7,
		"name": "Thiên Cung Đổ Nát",
		"size": Vector2(4480, 2560),
		"levels": [80, 84],
		"zone_x": [900.0, 560.0],
		"safe": {"pos": Vector2(352, 1280), "r": 140.0, "name": "Thiên Môn Đài", "kind": "camp"},
		"arena": {"pos": Vector2(3872, 1280), "r": 300.0, "boss": "cu-than", "level": 82, "chapter": 7, "name": "Đài Cự Thần"},
		"gate": true,
		"mobs": [["dai-bang-may", 80, 25], ["nguoi-go-dao", 80, 25], ["tien-gio", 80, 25], ["hiep-si-thien-khong", 80, 25]],
		"ground": "tile-marble",
		"fog": 0.25,
		"tint": Color(0.36, 0.3, 0.5),
		"wind": 0.0,
		"trees": 90,
		"decor": "sky_ruins",
		"islands": [[Vector2(430, 1280), 450.0], [Vector2(1150, 700), 320.0], [Vector2(1150, 1860), 320.0], [Vector2(1900, 1280), 380.0],
			[Vector2(2550, 700), 300.0], [Vector2(2550, 1860), 300.0], [Vector2(3150, 1280), 330.0], [Vector2(3872, 1280), 300.0],
			[Vector2(3500, 470), 230.0]],
		## M11: đảo 8 = Bến Khe Vực (cổng "next" sang Vực Hư Vô 8-1), cầu 9 nối từ đảo 6.
		"bridges": [[0, 1], [0, 2], [1, 3], [2, 3], [3, 4], [3, 5], [4, 6], [5, 6], [6, 7], [6, 8]],
		"solid": [8],
		"anchors": [Vector2(1900, 1280), Vector2(2550, 700), Vector2(3420, 1280)],
		"void_anchors": [Vector2(1150, 700), Vector2(2550, 1860), Vector2(3150, 1100)],
		"crumble": [[Vector2(1520, 1000), 90.0], [Vector2(1520, 1560), 90.0], [Vector2(2230, 960), 80.0], [Vector2(2230, 1600), 80.0],
			[Vector2(2850, 1000), 80.0], [Vector2(2850, 1560), 80.0]],
	},
	## ---------------------------------------------------------------- M11 chương 8 (docs/17 C8-02…13)
	## lamps: Đèn Tinh Quang (vòng 6 m) · lamps_off: chỉ số đèn tắt chờ thắp ở bước 3 (8-2) · stones8: Cột Đá Hư Vô [tâm, bán kính]
	## (chặn tia/đạn, bán kính giữ nguyên khi nhân map) · cages: Lồng Hư Vô (8-2) · seals: Trụ Phong Ấn (8-3).
	"8-1": {
		"region": 8,
		"name": "Rìa Vực",
		"size": Vector2(4480, 2560),
		"levels": [84, 88],
		"zone_x": [900.0, 800.0],
		"safe": {"pos": Vector2(400, 1280), "r": 180.0, "name": "Tiền Đồn Tinh Quang", "kind": "camp"},
		"npcs": [["lac-phong-8", "npc-lac-phong", Vector2(40, -40), "Lạc Phong · E"], ["tuyet-nga-8", "npc-tuyet-nga", Vector2(-80, 60), "Tuyết Nga · E"],
			["mac-tam-8", "npc-mac-tam", Vector2(80, 80), "Mạc Tam · E"]],
		"arena": null,
		"gate": false,
		"mobs": [["bong-hu-vo", 84, 40], ["ke-nuot", 84, 30], ["giap-si-hu-vo", 85, 30], ["mat-hu-vo", 86, 20]],
		"ground": "tile-abyss",
		"fog": 0.35,
		"tint": Color(0.12, 0.08, 0.2),
		"wind": 0.0,
		"trees": 60,
		"decor": "void",
		"lamps": [Vector2(620, 1180), Vector2(1100, 700), Vector2(1100, 1900), Vector2(1600, 1280), Vector2(2000, 600), Vector2(2000, 2000),
			Vector2(2500, 1280), Vector2(2900, 700), Vector2(2900, 1900), Vector2(3400, 1280), Vector2(3900, 700), Vector2(3900, 1900)],
		"stones8": [[Vector2(1350, 1000), 30.0], [Vector2(1350, 1600), 30.0], [Vector2(1800, 950), 26.0], [Vector2(2250, 1500), 32.0],
			[Vector2(2700, 1000), 28.0], [Vector2(3150, 1600), 30.0], [Vector2(3650, 1000), 28.0], [Vector2(3650, 1600), 26.0]],
	},
	"8-2": {
		"region": 8,
		"name": "Đáy Vực",
		"size": Vector2(4480, 2560),
		"levels": [88, 92],
		"zone_x": [900.0, 750.0],
		"safe": {"pos": Vector2(352, 1280), "r": 150.0, "name": "Hố Lửa Thánh", "kind": "camp"},
		"arena": null,
		"gate": false,
		"mobs": [["bong-hu-vo", 88, 30], ["ke-nuot", 88, 25], ["giap-si-hu-vo", 88, 25], ["mat-hu-vo", 88, 20]],
		"ground": "tile-abyss",
		"fog": 0.4,
		"tint": Color(0.1, 0.06, 0.18),
		"wind": 0.0,
		"trees": 50,
		"decor": "void",
		"lamps": [Vector2(560, 1180), Vector2(1300, 800), Vector2(1700, 1900), Vector2(2300, 1100), Vector2(2800, 2000), Vector2(3200, 700),
			Vector2(3700, 1500), Vector2(4100, 900)],
		"lamps_off": [2, 4, 5, 7],
		"cages": [Vector2(1500, 1500), Vector2(2700, 900), Vector2(3800, 2000)],
		"stones8": [[Vector2(1000, 1300), 30.0], [Vector2(1550, 1100), 28.0], [Vector2(2000, 1600), 32.0], [Vector2(2500, 1400), 28.0],
			[Vector2(2900, 1500), 30.0], [Vector2(3350, 1150), 28.0], [Vector2(3500, 1800), 26.0], [Vector2(3950, 1300), 30.0],
			[Vector2(4200, 1800), 28.0]],
	},
	"8-3": {
		"region": 8,
		"name": "Sào Huyệt Hư Vô",
		"size": Vector2(4480, 2560),
		"levels": [92, 95],
		"zone_x": [900.0, 700.0],
		"safe": {"pos": Vector2(352, 1280), "r": 150.0, "name": "Cổng Phá Vây", "kind": "camp"},
		"npcs": [["lac-phong-8c", "npc-lac-phong", Vector2(40, -40), "Lạc Phong · E"],
			["to-su-kiem", "npc-to-su", Vector2(-90, -60), "Kiếm Tổ Vô Danh · E"], ["to-su-tien", "npc-to-su", Vector2(-110, 10), "Tiễn Tổ Lạc Nhật · E"],
			["to-su-phap", "npc-to-su", Vector2(-90, 80), "Pháp Tổ Huyền Cơ · E"], ["to-su-thuan", "npc-to-su", Vector2(0, 100), "Thuẫn Tổ Bàn Thạch · E"],
			["to-su-linh", "npc-to-su", Vector2(80, 70), "Linh Tổ Vạn Hồn · E"]],
		"arena": {"pos": Vector2(3872, 1280), "r": 280.0, "boss": "giao-chu", "level": 93, "chapter": 8, "name": "Điện Giáo Chủ"},
		"gate": true,
		"mobs": [["bong-hu-vo", 92, 25], ["ke-nuot", 92, 25], ["giap-si-hu-vo", 92, 25], ["mat-hu-vo", 92, 25]],
		"ground": "tile-abyss",
		"fog": 0.45,
		"tint": Color(0.14, 0.05, 0.16),
		"wind": 0.0,
		"trees": 40,
		"decor": "void",
		"lamps": [Vector2(560, 1180), Vector2(1400, 1900), Vector2(2100, 700), Vector2(2700, 1900), Vector2(3200, 900)],
		"seals": [Vector2(1500, 900), Vector2(2200, 1500), Vector2(2900, 1100)],
		"stones8": [[Vector2(1100, 1300), 30.0], [Vector2(1700, 1300), 28.0], [Vector2(1900, 2000), 30.0], [Vector2(2500, 900), 28.0],
			[Vector2(2600, 1600), 32.0], [Vector2(3100, 1500), 28.0], [Vector2(3300, 2000), 30.0], [Vector2(3400, 600), 26.0]],
	},
	## ---------------------------------------------------------------- M12 chương 9 (docs/18 C9-02…12)
	## Mỗi map 3 tầng theo chiều ngang, ngăn bởi Cửa Tầng (doors9: điểm có x = ranh giới tầng) · guards9: chỗ Thủ Tầng của 3 tầng
	## (tầng thứ 3 canh lối sang map sau / cửa Thiên Đạo Chi Môn) · seals9: bệ Ấn Hệ của 3 tầng. Cấp quái theo tầng (zone_x = bề rộng tầng).
	"9-1": {
		"region": 9,
		"name": "Thiên Thê · Tầng 1–3",
		"size": Vector2(4480, 2560),
		"levels": [95, 97],
		"zone_x": [1493.0, 1494.0],
		"safe": {"pos": Vector2(352, 1280), "r": 160.0, "name": "Thiên Thê Đài I", "kind": "camp"},
		"npcs": [["van-hac-9", "npc-van-hac", Vector2(40, -40), "Vân Hạc · E"], ["tuyet-nga-9", "npc-tuyet-nga", Vector2(-80, 60), "Tuyết Nga · E"],
			["lam-nhi-9", "npc-lam-nhi", Vector2(80, 80), "Lam Nhi · E"], ["than-vuc", "npc-to-su", Vector2(-40, -110), "Cổng Thần Vực · E"]],
		"arena": null,
		"gate": false,
		"mobs": [["thien-binh", 95, 30], ["tan-hon", 95, 25], ["thien-ma", 95, 25], ["linh-thu-ngu-hanh", 96, 20]],
		"ground": "tile-heaven",
		"fog": 0.2,
		"tint": Color(0.3, 0.26, 0.18),
		"wind": 0.0,
		"trees": 60,
		"decor": "heaven",
		"doors9": [Vector2(1493, 1280), Vector2(2987, 1280)],
		"guards9": [Vector2(1330, 1280), Vector2(2820, 1280), Vector2(4080, 640)],
		"seals9": [Vector2(900, 700), Vector2(2240, 1900), Vector2(3700, 1100)],
	},
	"9-2": {
		"region": 9,
		"name": "Thiên Thê · Tầng 4–6",
		"size": Vector2(4480, 2560),
		"levels": [97, 99],
		"zone_x": [1493.0, 1494.0],
		"safe": {"pos": Vector2(352, 1280), "r": 150.0, "name": "Thiên Thê Đài II", "kind": "camp"},
		"arena": null,
		"gate": false,
		"mobs": [["thien-binh", 97, 25], ["tan-hon", 97, 25], ["thien-ma", 97, 25], ["linh-thu-ngu-hanh", 97, 25]],
		"ground": "tile-heaven",
		"fog": 0.25,
		"tint": Color(0.28, 0.22, 0.2),
		"wind": 0.0,
		"trees": 50,
		"decor": "heaven",
		"doors9": [Vector2(1493, 1280), Vector2(2987, 1280)],
		"guards9": [Vector2(1330, 1280), Vector2(2820, 1280), Vector2(4080, 640)],
		"seals9": [Vector2(950, 1900), Vector2(2240, 700), Vector2(3700, 1700)],
	},
	"9-3": {
		"region": 9,
		"name": "Thiên Thê · Tầng 7–9",
		"size": Vector2(4480, 2560),
		"levels": [99, 100],
		"zone_x": [2987.0, 1494.0],
		"safe": {"pos": Vector2(352, 1280), "r": 150.0, "name": "Thiên Thê Đài III", "kind": "camp"},
		"arena": {"pos": Vector2(3872, 1280), "r": 320.0, "boss": "ma-ton", "level": 100, "chapter": 9, "name": "Thiên Đạo Chi Môn"},
		"gate": true,
		"mobs": [["thien-binh", 99, 25], ["tan-hon", 99, 25], ["thien-ma", 99, 25], ["linh-thu-ngu-hanh", 99, 25]],
		"ground": "tile-heaven",
		"fog": 0.3,
		"tint": Color(0.32, 0.24, 0.16),
		"wind": 0.0,
		"trees": 40,
		"decor": "heaven",
		"doors9": [Vector2(1493, 1280), Vector2(2987, 1280)],
		"guards9": [Vector2(1330, 1280), Vector2(2820, 1280), Vector2(3330, 1280)],
		"seals9": [Vector2(900, 1800), Vector2(2240, 900), Vector2(3300, 2100)],
	},
}

## Thứ tự để hiển thị và kiểm điều kiện "đã tới map trước".
const ORDER := ["1-1", "1-3", "2-1", "2-2", "2-3", "3-1", "3-2", "3-3", "4-1", "4-2", "4-3", "5-1", "5-2", "5-3", "6-1", "6-2", "6-3"]


## Vị trí nhà trong vùng an toàn: [[lệch so với tâm, id hình HD, id hình pixel dự phòng], ...] (world_view vẽ, portals tránh).
## UI-40c (docs/35 §10): theo chủ đề vùng (safe_theme); tắt HD / thiếu hình HD thì world_view vẽ id pixel.
static func safe_buildings(m: Dictionary) -> Array:
	return safe_theme(m).get("buildings", [])


## Đồ trang trí khu an toàn (chỉ bản HD): [lệch so với tâm (chân hình), id, tỉ lệ]. Không chặn đường đi;
## cổng dịch chuyển tránh các món trong vùng an toàn. Món ngoài bán kính (ruộng, thuyền, cây cọ…) là cảnh quanh trại.
static func safe_props(m: Dictionary) -> Array:
	return safe_theme(m).get("props", [])


## UI-40b / UI-40c: chủ đề khu an toàn HD theo vùng — nền sân (yard), sân lát giữa (plaza), cọc rào (post) + màu thanh
## ngang (rail), nhà, đồ trang trí. {} = không vẽ kiểu HD (hang, cổng dungeon).
static func safe_theme(m: Dictionary) -> Dictionary:
	var kind: String = m.safe.kind
	if kind == "cave":
		return {}
	var reg := int(m.get("region", 1))
	var r := float(m.safe.r)
	var k := clampf(r / 150.0, 0.93, 1.35)
	if kind == "village":
		return {"yard": "tile-village", "plaza": "tile-plaza", "post": "fence-post", "rail": Color("#9a6a40"),
			"buildings": [[Vector2(-85, -95), "house-village-0", "hut"], [Vector2(55, -110), "house-village-1", "hut"],
				[Vector2(-125, 25), "house-village-2", "hut"], [Vector2(10, 125), "house-village-2", "hut"]],
			"props": [[Vector2(-52, -18), "village-well", 1.0], [Vector2(-118, 100), "crates", 1.0],
				[Vector2(150, -52), "lantern-post", 1.0], [Vector2(150, 52), "lantern-post", 1.0],
				[Vector2(-40, 225), "garden", 1.0], [Vector2(55, 225), "garden", 1.0], [Vector2(-225, -40), "garden", 1.0],
				[Vector2(135, 205), "haystack", 0.9]]}
	if kind == "town":
		return {"yard": "tile-town", "plaza": "tile-plaza", "post": "wall-post", "rail": Color("#8d8a82"), "rails": 3, "waypoint": Vector2(55, 150),
			"buildings": [[Vector2(-150, -120), "house-stone", "house-stone"], [Vector2(-175, 30), "house-stone-b", "house-stone"],
				[Vector2(-60, 160), "house-stone", "house-stone"], [Vector2(70, -170), "house-stone-b", "house-stone"],
				[Vector2(150, 120), "tower", "tower"], [Vector2(-40, -205), "tower", "tower"]],
			"props": [[Vector2(-40, 20), "village-well", 1.0], [Vector2(205, -62), "lantern-post", 1.0], [Vector2(205, 62), "lantern-post", 1.0],
				[Vector2(-160, 120), "crates", 1.0], [Vector2(120, -60), "crates", 0.9], [Vector2(20, -110), "lantern-post", 1.0]]}
	# trại: 2–3 nhà quanh mép bắc / tây, đống lửa giữa, đèn 2 bên cổng đông, đồ đạc phía nam; cảnh quanh ngoài rào.
	var t: Dictionary = CAMP_THEMES.get(reg, CAMP_THEMES[1])
	if bool(m.get("desert", false)) and reg != 3:
		t = CAMP_THEMES[3]
	var bl: Array = t.buildings
	# Cổng Dịch Chuyển cố định ở khoảng trống phía nam (nhà ở mép bắc / tây che mất nếu để tự tính).
	var out := {"yard": t.yard, "plaza": t.get("plaza", ""), "post": t.post, "rail": t.rail, "rails": int(t.get("rails", 2)), "buildings": [], "props": [],
		"waypoint": Vector2(4, 0.6 * r)}
	var spots := [Vector2(-92, -80), Vector2(80, -112), Vector2(-128, 22)]
	for i in mini(bl.size(), 3 if r >= 175.0 else 2):
		out.buildings.append([spots[i] * k, bl[i][0], bl[i][1]])
	if t.get("center", "") != "":
		out.props.append([Vector2(-6, 4) * k, t.center, 1.0])
	if t.get("light", "") != "":
		out.props.append([Vector2(r - 18.0, -0.3 * r), t.light, 1.0])
		out.props.append([Vector2(r - 18.0, 0.3 * r), t.light, 1.0])
	for pr in t.get("props", []):
		out.props.append([pr[0] * k, pr[1], float(pr[2])])
	for pr in t.get("outside", []):
		out.props.append([Vector2.from_angle(deg_to_rad(float(pr[0]))) * (r + float(pr[1])), pr[2], float(pr[3])])
	# chỗ cổng mặc định có NPC / đồ đứng → thử chỗ trống khác
	for cand in [Vector2(4, 0.6 * r), Vector2(0.62 * r, 0.4 * r), Vector2(-0.32 * r, 0.66 * r), Vector2(0.66 * r, -0.12 * r), Vector2(0.67 * r, 0.03 * r)]:
		var ok := true
		for n in m.get("npcs", []):
			ok = ok and cand.distance_to(n[2]) > 55.0
		for pr in out.props:
			ok = ok and cand.distance_to(pr[0]) > 50.0
		if ok:
			out.waypoint = cand
			break
	return out


## Chủ đề trại theo vùng. buildings: [id HD, id pixel]; props: [lệch (×bán kính/150), id, tỉ lệ];
## outside: [góc (độ, 0 = đông, 90 = nam), cách mép rào (px), id, tỉ lệ].
const CAMP_THEMES := {
	1: {"yard": "tile-village", "post": "fence-post", "rail": Color("#9a6a40"), "center": "campfire", "light": "lantern-post",
		"buildings": [["watchtower", "hut"], ["tent-canvas", "hut"], ["house-village-2", "hut"]],
		"props": [[Vector2(-100, 85), "crates", 1.0]], "outside": [[200, 46, "haystack", 0.9], [120, 50, "garden", 1.0]]},
	2: {"yard": "tile-village", "post": "fence-post", "rail": Color("#9a6a40"), "center": "campfire", "light": "lantern-post",
		"buildings": [["tent-canvas", "hut"], ["watchtower", "hut"], ["house-village-1", "hut"]],
		"props": [[Vector2(-100, 85), "crates", 1.0]], "outside": [[200, 46, "haystack", 1.0], [235, 40, "haystack", 0.8], [120, 50, "garden", 1.0]]},
	3: {"yard": "tile-sand-red", "post": "stake-post", "rail": Color("#c9a774"), "center": "campfire", "light": "torch-post",
		"buildings": [["tent", "tent"], ["tent-desert-b", "tent"], ["tent", "tent"]],
		"props": [[Vector2(-100, 85), "jars", 1.0], [Vector2(-62, 118), "crates", 0.9]],
		"outside": [[205, 40, "palm", 1.3], [250, 46, "palm", 1.1], [125, 44, "palm", 1.2]]},
	4: {"yard": "tile-mud", "plaza": "tile-boardwalk", "post": "bamboo-post", "rail": Color("#a99a5a"), "center": "net-rack", "light": "lantern-post",
		"buildings": [["stilt-house", "hut"], ["stilt-house-b", "hut"], ["stilt-house", "hut"]],
		"props": [[Vector2(-100, 85), "crates", 1.0]], "outside": [[110, 40, "boat", 1.0], [200, 36, "reeds-0", 1.3], [240, 40, "reeds-1", 1.3]]},
	5: {"yard": "tile-ash", "plaza": "tile-basalt", "post": "iron-post", "rail": Color("#5a4a46"), "center": "brazier", "light": "brazier",
		"buildings": [["hut-volcano", "hut"], ["forge-hall", "hut"], ["tent-ash", "hut"]],
		"props": [[Vector2(-100, 85), "ore-cart", 1.0], [Vector2(-62, 118), "crates", 0.9]],
		"outside": [[200, 40, "rock-lava-0", 1.5], [125, 46, "rock-lava-1", 1.4]]},
	6: {"yard": "tile-snow", "post": "fence-post-snow", "rail": Color("#8a6a50"), "center": "campfire", "light": "lantern-post",
		"buildings": [["cabin-snow", "hut"], ["cabin-snow-b", "hut"], ["tent-fur", "hut"]],
		"props": [[Vector2(-100, 85), "woodpile", 1.0], [Vector2(-62, 118), "sled", 1.0]],
		"outside": [[200, 40, "tree-pine-snow-0", 1.3], [125, 44, "snow-mound", 1.4], [240, 46, "tree-pine-snow-1", 1.2]]},
	7: {"yard": "tile-sky-grass", "plaza": "tile-marble", "post": "marble-post", "rail": Color("#e4ddd0"), "center": "", "light": "lantern-post",
		"buildings": [["pavilion-sky", "hut"], ["airship-dock", "hut"], ["tent-canvas", "hut"]],
		"props": [[Vector2(-100, 85), "crates", 1.0]], "outside": [[200, 44, "cloud-puff-0", 1.4], [130, 40, "cloud-puff-1", 1.3]]},
	8: {"yard": "tile-abyss", "plaza": "tile-marble-dark", "post": "ward-post", "rail": Color(0.62, 0.52, 0.95, 0.75), "center": "", "light": "lamp-tinh-quang-lit",
		"buildings": [["void-shrine", "hut"], ["tent-void", "hut"], ["tent-void", "hut"]],
		"props": [[Vector2(-100, 85), "crates", 1.0]], "outside": [[200, 40, "void-stone", 1.2], [125, 44, "void-stone", 1.0]]},
	9: {"yard": "tile-heaven", "plaza": "tile-marble", "post": "jade-post", "rail": Color("#c9e8d8"), "center": "incense-burner", "light": "lantern-post",
		"buildings": [["pavilion-jade", "hut"], ["pavilion-jade-b", "hut"], ["pavilion-jade", "hut"]],
		"props": [], "outside": [[200, 40, "heaven-pillar-0", 1.2], [125, 40, "heaven-pillar-1", 1.2]]},
}


## SN11-03 (Spec_Notes đợt 11, chủ dự án 31/10: "bản đồ rộng gấp 3 lần"): diện tích ×3 → mỗi chiều ×√3.
## Dữ liệu MAPS giữ toạ độ cũ; get_map trả bản đã nhân (vị trí, kích thước, zone_x, đảo, vùng nước) — mọi code đọc map
## qua get_map / GameWorld.map. Bán kính vùng an toàn, hang boss, hồ dung nham, ốc đảo, chỗ đất sụt giữ nguyên;
## đảo bay và vùng nước nhân theo (là địa hình). Số cây ×3 (mật độ giữ nguyên). Hang phụ không đổi.
const MAP_SCALE := 1.7320508
## Khoá là mảng điểm tuyệt đối trên map.
const POINT_LISTS := ["anchors", "beacons", "fires", "pillars", "pods", "void_anchors", "lamps", "cages", "seals", "doors9", "guards9", "seals9"]
## Khoá là mảng [tâm, bán kính]; true = bán kính cũng nhân (địa hình), false = giữ bán kính.
const CIRCLE_LISTS := {"islands": true, "crumble": false, "lava": false, "oases": false, "stones8": false}
static var _scaled := {}


static func get_map(map_id: String) -> Dictionary:
	# HP (docs/15): bản đồ hang "cave-<map cha>" sinh từ map cha (nạp muộn để tránh preload vòng).
	if map_id.begins_with("cave-"):
		return load("res://scripts/core/caves.gd").build_map(map_id)
	# BD-11 (docs/34): bản đồ trong Cổng dungeon "gate-<hạng>-<map cha>".
	if map_id.begins_with("gate-"):
		return load("res://scripts/core/gates.gd").build_map(map_id)
	var id := map_id if MAPS.has(map_id) else "1-1"
	if not _scaled.has(id):
		_scaled[id] = scaled(MAPS[id], MAP_SCALE)
	return _scaled[id]


## Bản sao map với toạ độ nhân k (xem MAP_SCALE).
static func scaled(src: Dictionary, k: float) -> Dictionary:
	var m: Dictionary = src.duplicate(true)
	m.size = Vector2(src.size) * k
	m.zone_x = [float(src.zone_x[0]) * k, float(src.zone_x[1]) * k]
	m.trees = roundi(int(src.get("trees", 0)) * k * k)
	m.safe.pos = Vector2(src.safe.pos) * k
	if src.arena != null:
		m.arena.pos = Vector2(src.arena.pos) * k
	if src.has("stele3"):
		m.stele3 = Vector2(src.stele3) * k
	for key in POINT_LISTS:
		if src.has(key):
			m[key] = src[key].map(func(v): return Vector2(v) * k)
	for key in CIRCLE_LISTS:
		if src.has(key):
			var rk: float = k if CIRCLE_LISTS[key] else 1.0
			m[key] = src[key].map(func(c): return [Vector2(c[0]) * k, float(c[1]) * rk])
	if src.has("water"):
		m.water.zones = src.water.zones.map(func(c): return [Vector2(c[0]) * k, float(c[1]) * k])
	return m


static func region(region_id: int) -> Dictionary:
	return REGIONS[clampi(region_id, 1, REGIONS.size()) - 1]


static func level_at(m: Dictionary, x: float) -> int:
	var z: Array = m.zone_x
	return clampi(int(m.levels[0]) + int(floor((x - float(z[0])) / float(z[1]))), int(m.levels[0]), int(m.levels[1]))
