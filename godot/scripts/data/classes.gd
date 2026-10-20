extends RefCounted
## M3 (03-mvp-spec mục 5.2, 5.4): lớp nhân vật và 4 kỹ năng mỗi lớp.
## Kỹ năng: cd (giây), mp, mul (hệ số sát thương), icon (assets/icons/skill-<icon>.png).

const ORDER := ["kiem-khach", "tho-san", "phap-su"]

const DEFS := {
	"kiem-khach": {
		"name": "Kiếm Khách",
		"role": "Cận chiến cân bằng",
		"main": "STR",
		"sprite": "hero-kiem-khach",
		"description": "Chém vòng cung trước mặt, trúng nhiều quái một lúc. Máu dày, lao vào giữa bầy quái.",
		"basic": {"name": "Chém", "icon": "slash"},
		"skills": [
			{"id": "spin", "name": "Xoáy Kiếm", "cd": 6.0, "mp": 15, "mul": 1.8, "icon": "spin",
				"text": "Chém vòng quanh 12,5 m, ×1,8 sát thương."},
			{"id": "dash", "name": "Đột Kích", "cd": 8.0, "mp": 20, "mul": 1.5, "icon": "dash",
				"text": "Lao 18 m theo hướng ngắm, chém mọi quái trên đường ×1,5; bất tử khi lao."},
			{"id": "wave", "name": "Kiếm Khí", "cd": 5.0, "mp": 15, "mul": 2.0, "icon": "wave",
				"text": "Luồng kiếm khí bay thẳng 40 m, xuyên mọi quái, ×2,0."},
			{"id": "guard", "name": "Thiết Bích", "cd": 20.0, "mp": 25, "mul": 0.0, "icon": "guard",
				"text": "4 giây giảm 50% sát thương nhận vào; đòn đánh +50% vào thanh Phá Thế."},
		],
	},
	"tho-san": {
		"name": "Thợ Săn",
		"role": "Đánh xa, cơ động",
		"main": "AGI",
		"sprite": "hero-tho-san",
		"description": "Bắn tên từ xa 45 m, né tránh cao hơn. Máu mỏng, phải giữ khoảng cách.",
		"basic": {"name": "Bắn", "icon": "shot"},
		"skills": [
			{"id": "rain", "name": "Mưa Tên", "cd": 8.0, "mp": 25, "mul": 0.6, "icon": "rain",
				"text": "Vùng 9 m tại điểm ngắm: 5 đợt tên trong 1,5 giây, mỗi đợt ×0,6."},
			{"id": "pierce", "name": "Tên Xuyên Phá", "cd": 6.0, "mp": 15, "mul": 2.5, "icon": "pierce",
				"text": "Một mũi tên xuyên mọi quái, bay 60 m, ×2,5."},
			{"id": "trap", "name": "Bẫy Gai", "cd": 10.0, "mp": 20, "mul": 2.0, "icon": "trap",
				"text": "Đặt bẫy (tối đa 2). Quái chạm vào: nổ 6 m ×2,0 và bị trói 2 giây."},
			{"id": "eagle", "name": "Ưng Nhãn", "cd": 25.0, "mp": 30, "mul": 0.0, "icon": "eagle",
				"text": "6 giây: +30% tốc đánh, +15% chí mạng."},
		],
	},
	## SN-01…04 (đợt SN2, Spec_Notes S1): kịch bản mục 4 — sát thương phép diện rộng, chỉ số chính Trí tuệ.
	"phap-su": {
		"name": "Pháp Sư",
		"role": "Phép diện rộng, khống chế",
		"main": "INT",
		"sprite": "hero-phap-su",
		"description": "Ném Hỏa Cầu nổ lan, sét nảy qua nhiều quái, gọi thiên thạch. Máu mỏng nhất — dùng Băng Ngục trói quái và Pháp Thuẫn để sống sót.",
		"basic": {"name": "Hỏa Cầu", "icon": "fireball"},
		"skills": [
			{"id": "chain", "name": "Lôi Xích", "cd": 6.0, "mp": 15, "mul": 1.6, "icon": "chain",
				"text": "Sét đánh quái gần nhất trong 35 m, nảy sang tối đa 4 quái kế tiếp (mỗi bước ≤ 15 m), mỗi quái ×1,6."},
			{"id": "nova", "name": "Băng Ngục", "cd": 9.0, "mp": 20, "mul": 1.4, "icon": "nova",
				"text": "Băng nổ quanh mình 11 m, ×1,4, trói quái 2 giây."},
			{"id": "meteor", "name": "Thiên Thạch", "cd": 10.0, "mp": 30, "mul": 3.0, "icon": "meteor",
				"text": "Vòng báo hiệu 10 m tại điểm ngắm; 0,8 giây sau thiên thạch rơi ×3,0."},
			{"id": "barrier", "name": "Pháp Thuẫn", "cd": 20.0, "mp": 25, "mul": 0.0, "icon": "barrier",
				"text": "Khiên 6 giây hút sát thương tới 30% HP tối đa."},
		],
	},
}


static func get_class_def(class_id: String) -> Dictionary:
	return DEFS.get(class_id, DEFS["kiem-khach"])


static func skill(class_id: String, index: int) -> Dictionary:
	return get_class_def(class_id).skills[index]
