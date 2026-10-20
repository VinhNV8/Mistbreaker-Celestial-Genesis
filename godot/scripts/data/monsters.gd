extends RefCounted
## Chỉ số gốc ở cấp 1; quái thường được nhân theo cấp khi sinh ra (xem GameWorld.spawn_enemy).
## windup = thời gian vung đòn (có vòng báo hiệu) — cửa sổ để người chơi né.
## element: hệ ngũ hành (TL-S6). Rừng Sương hệ chủ đạo Mộc (kịch bản mục 6).

const ELEMENT_ORDER := ["kim", "moc", "thuy", "hoa", "tho"]
const ELEMENT_NAMES := {"kim": "Kim", "moc": "Mộc", "thuy": "Thủy", "hoa": "Hỏa", "tho": "Thổ"}
const ELEMENT_HEX := {"kim": "#e8e2c8", "moc": "#5bd16a", "thuy": "#4a9df8", "hoa": "#ff6a3c", "tho": "#c9a45c"}
## Hệ tấn công → hệ bị khắc: Kim → Mộc → Thổ → Thủy → Hỏa → Kim (kịch bản mục 5).
const COUNTERS := {"kim": "moc", "moc": "tho", "tho": "thuy", "thuy": "hoa", "hoa": "kim"}
const COUNTER_BONUS := 0.3


static func counters(attacker: String, defender: String) -> bool:
	return COUNTERS.get(attacker, "") == defender

const DEFS := {
	"wolf": {
		"element": "moc",
		"name": "Sói Sương",
		"hp": 40.0,
		"atk": 8.0,
		"def": 3.0,
		"speed": 150.0,
		"radius": 16.0,
		"range": 34.0,
		"windup": 0.45,
		"recover": 0.6,
		"attack": "melee",
		"color": "#8fa3b8",
	},
	"mushroom": {
		"element": "tho",
		"name": "Nấm Độc",
		"hp": 55.0,
		"atk": 7.0,
		"def": 4.0,
		"speed": 70.0,
		"radius": 18.0,
		"range": 240.0,
		"windup": 0.7,
		"recover": 1.3,
		"attack": "spore",
		"color": "#b86fd6",
	},
	"wisp": {
		"element": "thuy",
		"name": "Tinh Linh Sương",
		"hp": 70.0,
		"atk": 12.0,
		"def": 6.0,
		"speed": 115.0,
		"radius": 15.0,
		"range": 30.0,
		"windup": 0.35,
		"recover": 0.5,
		"attack": "melee",
		"color": "#9de0e6",
	},
	"boss": {
		"element": "moc",
		"name": "Sói Chúa Hư Vô",
		"hp": 3600.0,
		"atk": 27.0,
		"def": 12.0,
		"speed": 175.0,
		"radius": 40.0,
		"range": 58.0,
		"windup": 0.55,
		"recover": 0.8,
		"attack": "melee",
		"color": "#6a5a92",
	},
}
