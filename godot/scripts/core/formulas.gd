extends RefCounted


## EXP cần để lên cấp tiếp theo: EXP(L) = 100·L^2.2 + 500·⌊L/10⌋³ (tài liệu mục 4).
static func exp_to_next(level: int) -> int:
	return int(floor(100.0 * pow(level, 2.2) + 500.0 * pow(floor(level / 10.0), 3.0)))


static func mob_exp(level: int, elite: bool) -> int:
	return int(round(30.0 * pow(level, 1.5) * (3.0 if elite else 1.0)))


## DMG = ATK · HệSốKỹNăng · ATK/(ATK+DEF) · (1+KhắcHệ) · (1+ThiênPhú) (tài liệu mục 5).
static func compute_damage(atk: float, def: float, skill_mul := 1.0, element_bonus := 0.0, talent_bonus := 0.0) -> float:
	if atk <= 0.0:
		return 0.0
	return atk * skill_mul * (atk / (atk + maxf(0.0, def))) * (1.0 + element_bonus) * (1.0 + talent_bonus)


## Combo không bị trúng đòn: tối đa +20% EXP ở 100 combo.
static func combo_exp_multiplier(combo: int) -> float:
	return 1.0 + clampf(combo, 0.0, 100.0) / 100.0 * 0.2


# ------------------------------------------------------------------ CB-21: chỉ số quái (tài liệu 06 mục 1)
# Giống hệt tools/gen_world_doc.py. Sửa ở đây thì sửa cả script đó rồi sinh lại tài liệu 06.

## Bậc: [số đòn để hạ, % HP người chơi mỗi đòn của quái, hệ số phòng thủ]
const MOB_TIERS := {
	"thuong": [3, 0.06, 1.0],
	"tinhanh": [12, 0.09, 1.5],
	"boss": [130, 0.10, 2.0],
	"hiem": [200, 0.12, 2.0],
}
## Loại quái: [hệ số HP, hệ số Tấn công, hệ số Phòng thủ]
const MOB_ARCH := {
	"nhanh": [0.8, 0.9, 0.8],
	"bay": [0.5, 0.6, 0.6],
	"li": [1.4, 0.9, 1.3],
	"giap": [1.2, 1.0, 2.0],
	"xa": [0.9, 0.9, 0.8],
	"phep": [0.9, 1.2, 0.8],
	"tu_no": [0.6, 2.5, 0.5],
	"boss": [1.0, 1.0, 1.0],
}


## Người chơi chuẩn mà quái được cân theo (mặc đồ đúng vùng).
static func standard_player(level: int) -> Dictionary:
	return {"atk": 10.0 + 13.0 * (level - 1), "hp": 100.0 + 50.0 * (level - 1), "def": 5.0 + 3.5 * (level - 1)}


## Q23: boss chương 1 = 90 đòn, chương 2–3 = 110, chương 4+ = 130.
static func boss_hits(chapter: int) -> int:
	return 90 if chapter == 1 else (110 if chapter <= 3 else 130)


## ref_level: cấp người chơi dùng để cân (boss: thấp hơn boss 1 cấp). hits: ghi đè số đòn của bậc.
static func mob_stats(level: int, tier: String, arch: String, ref_level := 0, hits := 0) -> Dictionary:
	var t: Array = MOB_TIERS[tier]
	var a: Array = MOB_ARCH[arch]
	var n: float = float(hits if hits > 0 else t[0])
	var pl := standard_player(ref_level if ref_level > 0 else level)
	var dfn: float = (3.0 + 1.5 * level) * float(t[2]) * float(a[2])
	var dmg_p: float = pl.atk * pl.atk / (pl.atk + dfn)
	# Boss hiếm: loại quái chỉ đổi Tấn công/Phòng thủ, HP không nhân theo loại.
	var hp: float = n * dmg_p * (1.0 if tier == "hiem" else float(a[0]))
	var k: float = float(t[1]) * pl.hp
	var atk: float = (k + sqrt(k * k + 4.0 * k * pl.def)) / 2.0 * float(a[1])
	return {"hp": float(roundi(hp)), "atk": float(roundi(atk)), "def": float(roundi(dfn))}
