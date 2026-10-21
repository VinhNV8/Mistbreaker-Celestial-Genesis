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
	{"id": 4, "name": "Đầm Lầy U Minh", "levels": [32, 45], "element": "thuy", "maps": [], "unlock": "Chuyển chức 1 (Alpha)"},
	{"id": 5, "name": "Núi Viêm Long", "levels": [45, 60], "element": "hoa", "maps": [], "unlock": "Thiên phú tiến hoá 1 lần (Alpha)"},
	{"id": 6, "name": "Băng Nguyên Bắc Cực", "levels": [60, 72], "element": "thuy", "maps": [], "unlock": "Chuyển chức 2 (Beta)"},
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
	}
}

## Thứ tự để hiển thị và kiểm điều kiện "đã tới map trước".
const ORDER := ["1-1", "1-3", "2-1", "2-2", "2-3", "3-1", "3-2", "3-3"]


static func get_map(map_id: String) -> Dictionary:
	return MAPS.get(map_id, MAPS["1-1"])


static func region(region_id: int) -> Dictionary:
	return REGIONS[clampi(region_id, 1, REGIONS.size()) - 1]


static func level_at(m: Dictionary, x: float) -> int:
	var z: Array = m.zone_x
	return clampi(int(m.levels[0]) + int(floor((x - float(z[0])) / float(z[1]))), int(m.levels[0]), int(m.levels[1]))
