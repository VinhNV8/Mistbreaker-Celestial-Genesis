"""J3 (docs/23): icon 5 Thần Kỹ của chuyển chức 3 — viền bạc (C8-46).
icons.py chỉ gọi register(SKILLS) ở cuối file."""
import math

from pixel import R, hexc


def _thanky(cv, hex_bg):
    """Nền kỹ năng + viền bạc đôi."""
    from icons import _skill_bg
    _skill_bg(cv, hex_bg)
    for (x0, y0, x1, y1) in ((1, 1, 31, 1), (1, 31, 31, 31), (1, 1, 1, 31), (31, 1, 31, 31)):
        cv.line(x0, y0, x1, y1, R["white"][3], 1.2)
    for (x0, y0, x1, y1) in ((3, 3, 29, 3), (3, 29, 29, 29), (3, 3, 3, 29), (29, 3, 29, 29)):
        cv.line(x0, y0, x1, y1, R["white"][1], 0.8)


def g_nhatkiem(cv):
    """Nhất Kiếm Khai Thiên: vệt chém thẳng xẻ đôi bầu trời."""
    _thanky(cv, "#1c2236")
    cv.line(5, 27, 27, 5, hexc("#ffffff", 90), 4.0)
    cv.line(5, 27, 27, 5, hexc("#ffffff"), 1.6)
    cv.line(9, 25, 13, 21, R["steel"][3], 2.0)
    cv.line(7, 19, 13, 25, R["gold"][2], 1.4)


def g_tinhvu(cv):
    """Thiên Lạc Tinh Vũ: mũi tên sao rơi."""
    _thanky(cv, "#141c3a")
    for (x, y) in ((8, 8), (16, 12), (24, 7), (11, 19), (22, 18)):
        cv.line(x - 3, y - 6, x, y, hexc("#c4e4ff", 150), 1.2)
        cv.ellipse(x, y, 1.8, 1.8, hexc("#ffffff"))
    for a in range(0, 360, 72):
        t = math.radians(a - 90)
        cv.line(16, 25, 16 + math.cos(t) * 4, 25 + math.sin(t) * 4, hexc("#fff6a0"), 1.0)


def g_nguhanh(cv):
    """Ngũ Hành Luân Chuyển: 5 cầu ngũ hành quanh một vòng."""
    _thanky(cv, "#1e1a30")
    cv.arc(16, 16, 9, 0, math.tau, hexc("#f2f6ff", 120), 1.0)
    for k, c in enumerate(("#dce6f2", "#6fdc7a", "#4a9df8", "#ff7a3a", "#c9a45c")):
        t = math.radians(-90 + k * 72)
        cv.ellipse(16 + math.cos(t) * 9, 16 + math.sin(t) * 9, 3.2, 3.2, hexc(c))
        cv.set(16 + math.cos(t) * 9 - 1, 16 + math.sin(t) * 9 - 1, (255, 255, 255, 255))


def g_thienthuan(cv):
    """Thiên Thuẫn Giáng Thế: khiên thần giáng xuống, vòng sóng."""
    _thanky(cv, "#2a2a3a")
    for r, a in ((13, 80), (10, 140)):
        cv.arc(16, 22, r, math.radians(180), math.radians(360), hexc("#ffe9a0", a), 1.4)
    cv.shade_ellipse(16, 14, 7, 8, R["white"])
    cv.shade_ellipse(16, 14, 5, 6, R["gold"])
    cv.shade_ellipse(16, 14, 1.6, 1.6, R["white"])
    cv.line(16, 2, 16, 6, hexc("#ffffff", 180), 1.2)


def g_kylan(cv):
    """Kỳ Lân Giáng Thế: đầu kỳ lân trắng, sừng vàng."""
    _thanky(cv, "#1a2c3a")
    cv.ellipse(16, 18, 12, 9, hexc("#f2f6ff", 50))
    cv.shade_ellipse(14, 18, 7, 6, R["white"])
    cv.shade_poly([(18, 16), (26, 19), (18, 22)], R["white"])
    cv.shade_poly([(11, 13), (13, 4), (15, 13)], R["gold"])
    cv.line(8, 14, 6, 22, R["gold"][2], 1.6)
    cv.set(17, 16, hexc("#4a9df8"))


SKILLS_J3 = {"nhatkiem": g_nhatkiem, "tinhvu": g_tinhvu, "nguhanh": g_nguhanh, "thienthuan": g_thienthuan, "kylan": g_kylan}


def register(skills):
    for k, v in SKILLS_J3.items():
        skills.setdefault(k, v)
