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
	{"id": 7, "name": "Quần Đảo Thiên Không", "levels": [72, 84], "element": "kim", "maps": [], "unlock": "Lãnh địa cấp 5 (Beta)"},
	{"id": 8, "name": "Vực Hư Vô", "levels": [84, 95], "element": "", "maps": [], "unlock": "Thiên phú tiến hoá 2 lần (Beta)"},
	{"id": 9, "name": "Cổng Thiên Đạo", "levels": [95, 100], "element": "", "maps": [], "unlock": "Chuyển chức 3 (Beta)"},
]

const MAPS := {
	## Map của prototype — giữ nguyên toạ độ (Q35: gộp Bìa Rừng + Rừng Sâu).
	"1-1": {
		"region": 1,
		"name": "Rừng Sương",
		"size": Vector2(4160, 2560),
		"levels": [1, 6],
		"zone_x": [720.0, 416.0],
		"safe": {"pos": Vector2(368, 1280), "r": 170.0, "name": "Làng Thanh Thạch", "kind": "village"},
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
	}
}

## Thứ tự để hiển thị và kiểm điều kiện "đã tới map trước".
const ORDER := ["1-1", "1-3", "2-1", "2-2", "2-3", "3-1", "3-2", "3-3", "4-1", "4-2", "4-3", "5-1", "5-2", "5-3", "6-1", "6-2", "6-3"]


## Vị trí nhà trong vùng an toàn theo loại: [[lệch so với tâm, id hình], ...] (world_view vẽ, portals tránh).
static func safe_buildings(m: Dictionary) -> Array:
	var kind: String = m.safe.kind
	if kind == "cave":
		return []
	if bool(m.get("desert", false)) and kind == "camp":
		return [[Vector2(-60, -50), "tent"], [Vector2(-110, 40), "tent"], [Vector2(20, -110), "tent"]]
	if kind == "camp":
		return [[Vector2(-50, -40), "hut"]]
	if kind == "town":
		return [[Vector2(-150, -120), "house-stone"], [Vector2(-170, 30), "house-stone"], [Vector2(-60, 150), "house-stone"],
			[Vector2(70, -170), "house-stone"], [Vector2(130, 120), "tower"], [Vector2(-40, -200), "tower"]]
	return [[Vector2(-90, -70), "hut"], [Vector2(-110, 40), "hut"], [Vector2(-30, 100), "hut"], [Vector2(60, -105), "hut"]]


static func get_map(map_id: String) -> Dictionary:
	# HP (docs/15): bản đồ hang "cave-<map cha>" sinh từ map cha (nạp muộn để tránh preload vòng).
	if map_id.begins_with("cave-"):
		return load("res://scripts/core/caves.gd").build_map(map_id)
	return MAPS.get(map_id, MAPS["1-1"])


static func region(region_id: int) -> Dictionary:
	return REGIONS[clampi(region_id, 1, REGIONS.size()) - 1]


static func level_at(m: Dictionary, x: float) -> int:
	var z: Array = m.zone_x
	return clampi(int(m.levels[0]) + int(floor((x - float(z[0])) / float(z[1]))), int(m.levels[0]), int(m.levels[1]))
