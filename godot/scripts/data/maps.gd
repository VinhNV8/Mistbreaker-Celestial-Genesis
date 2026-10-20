extends RefCounted
## M4 (03-mvp-spec mục 6): 9 vùng của lục địa Huyền Thổ và các map con đã làm.
## Một map là dữ liệu: kích thước, cấp quái theo vị trí, vùng an toàn, hang boss, tường sương mù, bảng quái, môi trường.
##
## level_at(x) = clamp(levels[0] + floor((x - zone_x0) / zone_dx), levels[0], levels[1])
## mobs: [[loại quái, cấp tối thiểu, trọng số], ...] — "legacy" = giữ cách chọn quái của prototype (map 1-1).
## safe.kind: "village" | "town" | "camp". arena: hang boss (null nếu không có); gate: tường sương mù trước hang.

const REGIONS := [
	{"id": 1, "name": "Làng Thanh Thạch & Rừng Sương", "levels": [1, 10], "element": "moc", "maps": ["1-1", "1-3"]},
	{"id": 2, "name": "Đồng Bằng Gió Hú", "levels": [10, 20], "element": "kim", "maps": [], "unlock": "Hạ Sói Chúa · cấp 10 · khai phá vùng 1 ≥ 60%"},
	{"id": 3, "name": "Sa Mạc Xích Sa", "levels": [20, 32], "element": "tho", "maps": [], "unlock": "Lực chiến 5.000 (Alpha)"},
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
		"size": Vector2(2600, 1600),
		"levels": [1, 6],
		"zone_x": [450.0, 260.0],
		"safe": {"pos": Vector2(230, 800), "r": 170.0, "name": "Làng Thanh Thạch", "kind": "village"},
		"arena": {"pos": Vector2(2290, 800), "r": 270.0, "boss": "boss", "level": 6, "chapter": 1, "name": "Hang Sói Chúa"},
		"gate": true,
		"mobs": "legacy",
		"ground": "tile-grass-0",
		"fog": 0.45,
		"tint": Color(0.16, 0.08, 0.27),
		"wind": 0.0,
		"trees": 240,
	},
	## Map 1-3: mở sau khi hạ Sói Chúa (Q25). Không có boss chương (boss hiếm Lão Thụ ở M5).
	"1-3": {
		"region": 1,
		"name": "Lõi Sương",
		"size": Vector2(2400, 1500),
		"levels": [7, 10],
		"zone_x": [500.0, 450.0],
		"safe": {"pos": Vector2(220, 750), "r": 140.0, "name": "Trạm Gác Lõi Sương", "kind": "camp"},
		"arena": null,
		"gate": false,
		"mobs": [["wolf", 7, 25], ["wisp", 7, 35], ["moc-tinh", 7, 30], ["mushroom", 7, 10]],
		"ground": "tile-grass-2",
		"fog": 0.6,
		"tint": Color(0.18, 0.1, 0.3),
		"wind": 0.0,
		"trees": 300,
	},
}

## Thứ tự để hiển thị và kiểm điều kiện "đã tới map trước".
const ORDER := ["1-1", "1-3"]


static func get_map(map_id: String) -> Dictionary:
	return MAPS.get(map_id, MAPS["1-1"])


static func region(region_id: int) -> Dictionary:
	return REGIONS[clampi(region_id, 1, REGIONS.size()) - 1]


static func level_at(m: Dictionary, x: float) -> int:
	var z: Array = m.zone_x
	return clampi(int(m.levels[0]) + int(floor((x - float(z[0])) / float(z[1]))), int(m.levels[0]), int(m.levels[1]))
