extends RefCounted
## M5-04 (KP-04): câu đố ở ô Di tích — kịch bản mục 7 "hạ quái canh giữ hoặc giải câu đố để chiếm ô".
## Hai loại, sinh cố định theo (nhân vật, vùng, ô) nên mở lại vẫn là câu cũ, không cần lưu save:
## - "lights": Trận Đèn Cổ 3 × 3 — bấm 1 bùa thì nó và các bùa kề đảo sáng/tối; thắp đủ 9 bùa là giải được.
## - "riddle": câu hỏi cổ thư, 3 lựa chọn.

const SIZE := 3
const SCRAMBLE := 3
## Trả lời sai: rương khoá lại 30 giây.
const WRONG_LOCK := 30.0

## a[0] là đáp án đúng; region = vùng nhỏ nhất được hỏi (câu về chương 2 chỉ hỏi ở vùng 2).
## Ngũ hành theo Monsters.COUNTERS: Kim khắc Mộc, Mộc khắc Thổ, Thổ khắc Thủy, Thủy khắc Hỏa, Hỏa khắc Kim.
const RIDDLES := [
	{"q": "Vật gì xua tan được sương mù Hư Vô?", "a": ["Đuốc Khai Giới", "Đá Cường Hoá", "Tinh Kim"], "region": 1},
	{"q": "Theo ngũ hành, Kim khắc hệ nào?", "a": ["Mộc", "Thủy", "Thổ"], "region": 1},
	{"q": "Theo ngũ hành, Mộc khắc hệ nào?", "a": ["Thổ", "Kim", "Hỏa"], "region": 1},
	{"q": "Theo ngũ hành, Thổ khắc hệ nào?", "a": ["Thủy", "Mộc", "Kim"], "region": 1},
	{"q": "Theo ngũ hành, Thủy khắc hệ nào?", "a": ["Hỏa", "Thổ", "Mộc"], "region": 1},
	{"q": "Theo ngũ hành, Hỏa khắc hệ nào?", "a": ["Kim", "Thủy", "Thổ"], "region": 1},
	{"q": "Kẻ cầm đầu bầy sói Rừng Sương là ai?", "a": ["Sói Chúa Hư Vô", "Lão Thụ Sương Mù", "Bạch Hổ Phong Vân"], "region": 1},
	{"q": "Đánh vỡ thanh nào thì boss bị choáng?", "a": ["Phá Thế", "Lực chiến", "Kinh nghiệm"], "region": 1},
	{"q": "Né lăn đúng khoảnh khắc đòn tới gọi là gì?", "a": ["Né Hoàn hảo", "Thiết Bích", "Đột Kích"], "region": 1},
	{"q": "Ai chỉ huy Liên minh Khai Giới ở Thành Biên Đài?", "a": ["Lạc Phong", "Mạc Tam", "Thiết Ngưu"], "region": 2},
	{"q": "Bản thật của Huyền Ảnh khác bản sao ở điểm nào?", "a": ["Có bóng", "Cầm khiên", "Biết bay"], "region": 2},
	{"q": "Lính Đánh Thuê mang khiên nên đánh từ đâu?", "a": ["Bên hông hoặc sau lưng", "Chính diện", "Đứng yên chờ nó"], "region": 2},
	{"q": "Thợ rèn nào đổi Đá và Sắt thành Tinh Kim?", "a": ["Thiết Ngưu", "Thạch Lão", "Lạc Phong"], "region": 2},
]


static func _rng(owner: String, region: int, tile_id: int) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash([owner, region, tile_id, "relic-puzzle"])
	return rng


## Câu đố của một ô Di tích. owner: tên nhân vật (mỗi nhân vật một bộ câu đố).
static func make(owner: String, region: int, tile_id: int) -> Dictionary:
	var rng := _rng(owner, region, tile_id)
	if rng.randi() % 2 == 0:
		return _make_lights(rng)
	return _make_riddle(rng, region)


static func _make_lights(rng: RandomNumberGenerator) -> Dictionary:
	var pz := {"kind": "lights", "cells": [], "moves": 0}
	for i in SIZE * SIZE:
		pz.cells.append(true)
	# Bấm SCRAMBLE bùa khác nhau từ trạng thái đã giải: ma trận Lights Out 3 × 3 khả nghịch
	# nên không bao giờ quay lại trạng thái đã giải, và luôn giải được trong ≤ SCRAMBLE bước.
	var picks: Array = []
	while picks.size() < SCRAMBLE:
		var i := rng.randi_range(0, SIZE * SIZE - 1)
		if not (i in picks):
			picks.append(i)
	for i in picks:
		_toggle(pz, i)
	return pz


static func _make_riddle(rng: RandomNumberGenerator, region: int) -> Dictionary:
	var pool := RIDDLES.filter(func(r): return int(r.region) <= region)
	var r: Dictionary = pool[rng.randi_range(0, pool.size() - 1)]
	var order := [0, 1, 2]
	for i in range(order.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp = order[i]
		order[i] = order[j]
		order[j] = tmp
	var options: Array = []
	for k in order:
		options.append(r.a[k])
	return {"kind": "riddle", "q": r.q, "options": options, "answer": order.find(0)}


static func _toggle(pz: Dictionary, i: int) -> void:
	var x := i % SIZE
	var y := i / SIZE
	for d in [Vector2i(0, 0), Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		var nx: int = x + d.x
		var ny: int = y + d.y
		if nx >= 0 and ny >= 0 and nx < SIZE and ny < SIZE:
			pz.cells[ny * SIZE + nx] = not pz.cells[ny * SIZE + nx]


## Trận Đèn Cổ: bấm bùa i.
static func press(pz: Dictionary, i: int) -> void:
	_toggle(pz, i)
	pz.moves = int(pz.moves) + 1


static func solved(pz: Dictionary) -> bool:
	if pz.kind != "lights":
		return false
	for c in pz.cells:
		if not c:
			return false
	return true
