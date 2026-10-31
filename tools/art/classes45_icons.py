"""LH1 / LH2 (docs/19): icon kỹ năng của lớp thứ 4 Hộ Vệ và lớp thứ 5 Triệu Hồi Sư.
icons.py chỉ gọi register(SKILLS) ở cuối file."""
import math

from pixel import R, hexc


def _bg(cv, hex_bg):
    from icons import _skill_bg
    _skill_bg(cv, hex_bg)


def _ult(cv, hex_bg):
    _bg(cv, hex_bg)
    for (x0, y0, x1, y1) in ((2, 2, 30, 2), (2, 30, 30, 30), (2, 2, 2, 30), (30, 2, 30, 30)):
        cv.line(x0, y0, x1, y1, R["gold"][3], 1.2)


def _shield(cv, x, y, r, rim="gold", face="cloth_blue"):
    """Khiên tròn: mặt màu, viền vàng, đinh giữa."""
    cv.shade_ellipse(x, y, r, r, R[rim])
    cv.shade_ellipse(x, y, r - 1.6, r - 1.6, R[face])
    cv.shade_ellipse(x, y, 1.6, 1.6, R["steel"])


def _mace(cv, x0, y0, x1, y1):
    cv.line(x0, y0, x1, y1, R["wood"][2], 1.8)
    cv.shade_ellipse(x1, y1, 3.2, 3.2, R["steel"])
    for a in range(0, 360, 90):
        r = math.radians(a + 45)
        cv.set(x1 + math.cos(r) * 4, y1 + math.sin(r) * 4, R["steel"][3])


# ---------------------------------------------------------------- Hộ Vệ
def g_bash(cv):
    """Đánh thường Đập Khiên: chùy + khiên."""
    _bg(cv, "#2a3446")
    _shield(cv, 12, 18, 8)
    _mace(cv, 14, 26, 24, 9)


def g_khienchan(cv):
    _bg(cv, "#30405a")
    for r, a in ((13, 80), (10, 150)):
        cv.arc(12, 16, r, math.radians(-50), math.radians(50), hexc("#e8eef6", a), 1.6)
    _shield(cv, 11, 16, 7)


def g_khieukhich(cv):
    _bg(cv, "#4a3a20")
    for r, a in ((13, 90), (9, 160)):
        cv.arc(16, 16, r, 0, math.tau, hexc("#ffd76a", a), 1.4)
    for a in range(0, 360, 60):
        t = math.radians(a)
        cv.line(16 + math.cos(t) * 13, 16 + math.sin(t) * 13, 16 + math.cos(t) * 7, 16 + math.sin(t) * 7, R["gold"][3], 1.0)
    _shield(cv, 16, 16, 4.5)


def g_laokhien(cv):
    _bg(cv, "#2a3446")
    for k in range(3):
        cv.line(3, 12 + k * 4, 14, 12 + k * 4, hexc("#c8d6e4", 90 + k * 40), 1.2)
    _shield(cv, 20, 16, 8)


def g_khienthep(cv):
    _bg(cv, "#4a4020")
    cv.ellipse(16, 16, 13, 13, hexc("#fff2c8", 70))
    _shield(cv, 16, 16, 9, "gold", "white")
    cv.line(16, 10, 16, 22, R["gold"][2], 1.6)
    cv.line(11, 15, 21, 15, R["gold"][2], 1.6)


def g_chandia(cv):
    _bg(cv, "#3a2e22")
    cv.shade_ellipse(16, 24, 13, 4, R["dirt"])
    for x in (6, 11, 21, 26):
        cv.line(16, 24, x, 18 + (x % 3), R["dirt"][3], 1.0)
    _mace(cv, 20, 4, 16, 20)


def g_phanthuan(cv):
    _bg(cv, "#30405a")
    cv.arc(16, 18, 11, math.radians(190), math.radians(350), hexc("#e8eef6", 150), 1.4)
    _shield(cv, 23, 13, 6)
    cv.shade_poly([(6, 18), (10, 15), (10, 21)], R["white"])


def g_phanquyet(cv):
    _bg(cv, "#4a4020")
    cv.line(16, 2, 16, 22, hexc("#fff2c8", 120), 6)
    cv.shade_ellipse(16, 25, 10, 3, R["gold"])
    _mace(cv, 16, 4, 16, 18)


def g_xungphong(cv):
    _bg(cv, "#2a3446")
    for k in range(4):
        cv.line(2, 9 + k * 5, 12 + k, 9 + k * 5, hexc("#ffd76a", 80 + k * 30), 1.4)
    _shield(cv, 22, 16, 7, "gold", "cloth_red")


def g_thanhbatdiet(cv):
    _ult(cv, "#3a3018")
    for side in (-1, 1):
        for k in range(3):
            cv.line(16, 15, 16 + side * (8 + k * 2), 8 + k * 4, hexc("#fff2c8", 200 - k * 40), 1.6)
    cv.ellipse(16, 9, 5, 1.6, hexc("#ffe07a", 220))
    _shield(cv, 16, 20, 5, "gold", "white")


def g_thanhquang(cv):
    _bg(cv, "#4a4020")
    cv.shade_poly([(6, 28), (26, 6), (29, 12)], R["gold"])
    cv.line(6, 28, 27, 8, hexc("#ffffff"), 1.2)
    _shield(cv, 9, 12, 4.5, "gold", "white")


def g_thanhvuc(cv):
    _bg(cv, "#3a3018")
    cv.arc(16, 16, 12, 0, math.tau, hexc("#ffe9a0", 200), 1.4)
    cv.ellipse(16, 16, 10, 10, hexc("#ffe9a0", 60))
    cv.line(16, 9, 16, 23, R["white"][3], 1.8)
    cv.line(10, 15, 22, 15, R["white"][3], 1.8)


def g_thietchuy(cv):
    _bg(cv, "#2c3038")
    cv.shade_ellipse(16, 25, 14, 4, R["stone"])
    for x in (3, 9, 23, 29):
        cv.line(16, 25, x, 21, R["stone"][0], 1.0)
    _mace(cv, 22, 3, 16, 19)
    cv.ellipse(16, 21, 6, 2, hexc("#ffffff", 120))


def g_thanhdong(cv):
    _bg(cv, "#2c3038")
    cv.arc(16, 16, 13, 0, math.tau, R["steel"][3], 1.2)
    cv.ellipse(16, 16, 11, 11, hexc("#9ba8bc", 70))
    _shield(cv, 16, 16, 7, "steel", "stone")


# ---------------------------------------------------------------- Triệu Hồi Sư
def _orb(cv, x, y, r, hex_c="#86d8e4"):
    cv.ellipse(x, y, r + 2.5, r + 2.5, hexc(hex_c, 70))
    cv.shade_ellipse(x, y, r, r, R["wisp"])
    cv.set(x - r * 0.35, y - r * 0.4, (255, 255, 255, 255))


def _beast(cv, x, y, fur, eye="#ffffff", s=1.0):
    """Đầu thú nhìn nghiêng: mõm + tai."""
    cv.shade_ellipse(x, y, 6 * s, 5 * s, R[fur])
    cv.shade_poly([(x + 4 * s, y - 1 * s), (x + 10 * s, y + 1 * s), (x + 4 * s, y + 3.5 * s)], R[fur])
    cv.shade_poly([(x - 3 * s, y - 4 * s), (x - 1 * s, y - 9 * s), (x + 1.5 * s, y - 4 * s)], R[fur])
    cv.set(x + 2.5 * s, y - 1.5 * s, hexc(eye))


def g_spiritorb(cv):
    """Đánh thường Linh Cầu."""
    _bg(cv, "#1a3a44")
    _orb(cv, 16, 16, 6)
    for k in range(3):
        cv.line(6 + k * 2, 22 - k * 4, 12, 18 - k * 2, hexc("#c4f4ff", 110), 1.0)


def g_soibong(cv):
    _bg(cv, "#24183a")
    cv.ellipse(16, 18, 12, 9, hexc("#8a6ae0", 60))
    _beast(cv, 14, 17, "fur_void", "#e080ff", 1.3)


def g_linhtien(cv):
    _bg(cv, "#1a3a44")
    for k in range(5):
        a = math.radians(-20 + k * 10)
        cv.line(5, 16, 5 + math.cos(a) * 22, 16 + math.sin(a) * 22, hexc("#c4f4ff", 200), 1.2)
        cv.ellipse(5 + math.cos(a) * 22, 16 + math.sin(a) * 22, 1.6, 1.6, hexc("#ffffff"))


def g_tieuquy(cv):
    _bg(cv, "#2c1a3a")
    for (x, y) in ((9, 12), (22, 12), (16, 23)):
        cv.ellipse(x, y, 4.5, 4.5, hexc("#e080ff", 90))
        cv.shade_ellipse(x, y, 3, 3, R["purple"])
        cv.set(x + 1, y - 1, (255, 255, 255, 255))


def g_lienket(cv):
    _bg(cv, "#2c1a3a")
    cv.line(9, 22, 23, 10, hexc("#c060f0"), 2.0)
    _orb(cv, 9, 22, 4, "#c060f0")
    _beast(cv, 22, 11, "fur_void", "#e080ff", 0.8)


def g_thachquy(cv):
    _bg(cv, "#2c3038")
    cv.shade_ellipse(16, 18, 9, 10, R["stone"])
    cv.shade_ellipse(16, 9, 5, 4, R["stone"])
    cv.set(14, 9, hexc("#9de0ff"))
    cv.set(18, 9, hexc("#9de0ff"))
    cv.line(12, 20, 20, 16, R["crystal"][3], 1.0)


def g_hoadieu(cv):
    _bg(cv, "#3a1408")
    cv.shade_poly([(26, 14), (12, 6), (15, 15), (6, 20), (16, 18)], R["fire"])
    cv.line(4, 24, 14, 17, hexc("#ff9a3c", 160), 2.0)
    cv.set(23, 13, (255, 255, 255, 255))


def g_linhtran(cv):
    _bg(cv, "#24183a")
    cv.arc(16, 18, 11, 0, math.tau, hexc("#c060f0"), 1.4)
    cv.arc(16, 18, 7, 0, math.tau, hexc("#e080ff", 160), 1.0)
    for a in range(0, 360, 72):
        t = math.radians(a)
        cv.set(16 + math.cos(t) * 9, 18 + math.sin(t) * 9, hexc("#ffffff"))


def g_linhung(cv):
    _bg(cv, "#1a304a")
    cv.shade_poly([(4, 12), (16, 16), (28, 12), (16, 22)], R["wisp"])
    cv.shade_ellipse(16, 16, 3, 3, R["crystal"])
    cv.set(17, 15, (255, 255, 255, 255))


def g_quandoan(cv):
    _ult(cv, "#1a2c3a")
    for (x, y) in ((8, 10), (16, 7), (24, 10), (10, 20), (22, 20), (16, 16)):
        cv.ellipse(x, y, 3.5, 3.5, hexc("#86d8e4", 110))
        cv.ellipse(x, y, 1.8, 1.8, hexc("#ffffff"))


def g_aulong(cv):
    _bg(cv, "#3a1408")
    _beast(cv, 14, 17, "fire", "#ffd23c", 1.3)
    cv.shade_poly([(8, 12), (4, 4), (12, 10)], R["gold"])
    cv.line(24, 18, 29, 17, hexc("#ffe08a"), 1.4)


def g_longhong(cv):
    _bg(cv, "#3a1a10")
    for r, a in ((13, 90), (9, 160)):
        cv.arc(16, 16, r, 0, math.tau, hexc("#ff7a3a", a), 1.6)
    _beast(cv, 15, 16, "fire", "#ffd23c", 0.9)


def g_loidodang(cv):
    _bg(cv, "#24204a")
    cv.rect(13, 10, 19, 28, R["wood"][1])
    cv.rect(11, 6, 21, 11, R["purple"][2])
    cv.line(19, 8, 27, 4, hexc("#fff6a0"), 1.2)
    cv.line(13, 8, 5, 4, hexc("#fff6a0"), 1.2)


def g_phongdodang(cv):
    _bg(cv, "#1e3a2c")
    cv.rect(13, 10, 19, 28, R["wood"][1])
    cv.rect(11, 6, 21, 11, R["leaf_light"][2])
    for k in range(3):
        cv.arc(16, 18, 8 + k * 3, math.radians(200), math.radians(320), hexc("#9ad46a", 160 - k * 40), 1.2)


SKILLS45 = {"bash": g_bash, "khienchan": g_khienchan, "khieukhich": g_khieukhich, "laokhien": g_laokhien,
            "khienthep": g_khienthep, "chandia": g_chandia, "phanthuan": g_phanthuan, "phanquyet": g_phanquyet,
            "xungphong": g_xungphong, "thanhbatdiet": g_thanhbatdiet, "thanhquang": g_thanhquang, "thanhvuc": g_thanhvuc,
            "thietchuy": g_thietchuy, "thanhdong": g_thanhdong,
            "spiritorb": g_spiritorb, "soibong": g_soibong, "linhtien": g_linhtien, "tieuquy": g_tieuquy, "lienket": g_lienket,
            "thachquy": g_thachquy, "hoadieu": g_hoadieu, "linhtran": g_linhtran, "linhung": g_linhung, "quandoan": g_quandoan,
            "aulong": g_aulong, "longhong": g_longhong, "loidodang": g_loidodang, "phongdodang": g_phongdodang}


def register(skills):
    for k, v in SKILLS45.items():
        skills.setdefault(k, v)
