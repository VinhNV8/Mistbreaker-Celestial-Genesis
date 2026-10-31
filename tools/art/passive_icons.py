"""PV (docs/27): icon 20 kỹ năng bị động (5 lớp × 4) + icon tab Bị động.
Nền kỹ năng thường + viền trong xanh lục (phân biệt với kỹ năng chủ động).
icons.py chỉ gọi register(SKILLS) ở cuối file → id "skill-pv-<tên>"."""
import math

from pixel import R, hexc

GREEN = "#9ad46a"


def _pv(cv, hex_bg):
    from icons import _skill_bg
    _skill_bg(cv, hex_bg)
    for (x0, y0, x1, y1) in ((4, 4, 28, 4), (4, 28, 28, 28), (4, 4, 4, 28), (28, 4, 28, 28)):
        cv.line(x0, y0, x1, y1, hexc(GREEN, 170), 0.9)


def _sword(cv, x0, y0, x1, y1, w=2.0):
    cv.line(x0, y0, x1, y1, R["steel"][3], w)
    t = 0.22
    hx, hy = x0 + (x1 - x0) * t, y0 + (y1 - y0) * t
    dx, dy = (y1 - y0), -(x1 - x0)
    n = math.hypot(dx, dy) or 1
    cv.line(hx - dx / n * 4, hy - dy / n * 4, hx + dx / n * 4, hy + dy / n * 4, R["gold"][2], 1.6)


def _shield(cv, cx, cy, s, rmp):
    pts = [(cx - 7 * s, cy - 8 * s), (cx + 7 * s, cy - 8 * s), (cx + 7 * s, cy + 1 * s), (cx, cy + 9 * s), (cx - 7 * s, cy + 1 * s)]
    cv.shade_poly(pts, rmp)


def _arrow(cv, x0, y0, x1, y1, c=None):
    c = c or R["wood"][3]
    cv.line(x0, y0, x1, y1, c, 1.4)
    a = math.atan2(y1 - y0, x1 - x0)
    for d in (2.6, -2.6):
        cv.line(x1, y1, x1 - math.cos(a + d / 6) * 4, y1 - math.sin(a + d / 6) * 4, R["steel"][3], 1.4)
    for d in (0.5, -0.5):
        cv.line(x0, y0, x0 - math.cos(a + d) * 3, y0 - math.sin(a + d) * 3, hexc("#e0e0e0"), 1.0)


def _heart(cv, cx, cy, s, rmp):
    cv.shade_ellipse(cx - 3 * s, cy - 2 * s, 3.4 * s, 3.4 * s, rmp)
    cv.shade_ellipse(cx + 3 * s, cy - 2 * s, 3.4 * s, 3.4 * s, rmp)
    cv.shade_poly([(cx - 6.3 * s, cy - 1 * s), (cx + 6.3 * s, cy - 1 * s), (cx, cy + 7 * s)], rmp)


# ---------------------------------------------------------------- tab
def g_tab(cv):
    """Tab Bị động: vòng xanh lục quanh ngôi sao (luôn có tác dụng)."""
    _pv(cv, "#1e3020")
    cv.arc(16, 16, 10, 0, math.tau, hexc(GREEN, 220), 1.6)
    pts = []
    for k in range(10):
        r = 6.5 if k % 2 == 0 else 2.8
        t = math.radians(-90 + k * 36)
        pts.append((16 + math.cos(t) * r, 16 + math.sin(t) * r))
    cv.shade_poly(pts, R["gold"])


# ---------------------------------------------------------------- Kiếm Khách
def g_thietcot(cv):
    """Thiết Cốt: trái tim bọc giáp thép."""
    _pv(cv, "#3a2a2a")
    _heart(cv, 16, 15, 1.4, R["blood"])
    cv.line(9, 15, 23, 15, R["steel"][2], 1.6)
    cv.line(16, 8, 16, 24, R["steel"][2], 1.2)


def g_kiemtam(cv):
    """Kiếm Tâm: mũi kiếm toả tia chí mạng."""
    _pv(cv, "#3a3550")
    for a in range(0, 360, 45):
        t = math.radians(a)
        cv.line(22 + math.cos(t) * 3, 10 + math.sin(t) * 3, 22 + math.cos(t) * 6, 10 + math.sin(t) * 6, hexc("#ffe07a"), 1.0)
    _sword(cv, 8, 25, 22, 10)


def g_phankich(cv):
    """Phản Kích: mũi tên vòng ngược + kiếm."""
    _pv(cv, "#28405a")
    cv.arc(16, 16, 9, math.radians(150), math.radians(390), hexc("#9de0e6", 220), 1.8)
    cv.line(7, 13, 8, 19, hexc("#9de0e6"), 1.8)
    cv.line(8, 19, 3.5, 17, hexc("#9de0e6"), 1.8)
    _sword(cv, 12, 22, 22, 9, 1.6)


def g_chieny(cv):
    """Chiến Ý: kiếm rực lửa đỏ."""
    _pv(cv, "#4a1a1a")
    for (x, y, r) in ((14, 20, 6), (18, 14, 5), (13, 11, 3.5)):
        cv.ellipse(x, y, r, r, hexc("#ff6a3d", 110))
    _sword(cv, 9, 26, 23, 7)


# ---------------------------------------------------------------- Thợ Săn
def g_ungmuc(cv):
    """Ưng Mục: mắt chim ưng nhìn xa."""
    _pv(cv, "#20384a")
    cv.shade_ellipse(16, 16, 10, 6, R["sand"])
    cv.shade_ellipse(16, 16, 4.5, 4.5, R["gold"])
    cv.ellipse(16, 16, 2, 2, (20, 16, 10, 255))
    cv.set(14, 14, (255, 255, 255, 255))
    cv.line(5, 10, 27, 10, R["leather"][1], 1.6)


def g_sanmoi(cv):
    """Săn Mồi: tâm ngắm + giọt máu."""
    _pv(cv, "#3a2a20")
    cv.arc(16, 16, 9, 0, math.tau, hexc("#ff5a6a"), 1.4)
    for (x0, y0, x1, y1) in ((16, 4, 16, 10), (16, 22, 16, 28), (4, 16, 10, 16), (22, 16, 28, 16)):
        cv.line(x0, y0, x1, y1, hexc("#ff5a6a"), 1.4)
    cv.shade_ellipse(16, 17, 2.6, 2.6, R["blood"])
    cv.shade_poly([(14, 16), (18, 16), (16, 12)], R["blood"])


def g_buocgio(cv):
    """Bước Gió: vệt gió dưới chiếc ủng."""
    _pv(cv, "#1e3a3a")
    for k, y in enumerate((11, 16, 21)):
        cv.line(4 + k * 2, y, 14 + k * 2, y, hexc("#c4e4ff", 200 - k * 40), 1.4)
    cv.shade_poly([(14, 8), (21, 8), (21, 19), (27, 21), (27, 25), (14, 25)], R["leather"])


def g_tamdoc(cv):
    """Tên Tẩm Độc: mũi tên nhỏ giọt độc xanh."""
    _pv(cv, "#20381e")
    _arrow(cv, 6, 26, 24, 8)
    cv.shade_ellipse(25, 14, 2.4, 2.4, R["leaf_light"])
    cv.shade_ellipse(21, 20, 1.8, 1.8, R["leaf_light"])


# ---------------------------------------------------------------- Pháp Sư
def g_minhtuong(cv):
    """Minh Tưởng: người ngồi thiền, vòng MP xanh."""
    _pv(cv, "#1e2a4a")
    cv.arc(16, 15, 10, 0, math.tau, hexc("#58a0f0", 200), 1.4)
    cv.shade_ellipse(16, 10, 3, 3, R["skin"])
    cv.shade_poly([(12, 13), (20, 13), (21, 20), (11, 20)], R["cloth_blue"])
    cv.shade_ellipse(16, 22, 7, 2.6, R["cloth_blue"])


def g_nguyento(cv):
    """Tinh Thông Nguyên Tố: ngũ giác 5 màu hệ."""
    _pv(cv, "#2a2040")
    for k, c in enumerate(("#dce6f2", "#6fdc7a", "#4a9df8", "#ff7a3a", "#c9a45c")):
        t = math.radians(-90 + k * 72)
        t2 = math.radians(-90 + (k + 1) * 72)
        cv.line(16 + math.cos(t) * 9, 16 + math.sin(t) * 9, 16 + math.cos(t2) * 9, 16 + math.sin(t2) * 9, hexc(c), 1.2)
        cv.ellipse(16 + math.cos(t) * 9, 16 + math.sin(t) * 9, 2.4, 2.4, hexc(c))
    cv.shade_ellipse(16, 16, 3, 3, R["white"])


def g_doidao(cv):
    """Pháp Lực Dồi Dào: bình MP đầy tràn."""
    _pv(cv, "#1e2a4a")
    cv.shade_ellipse(16, 19, 7, 7, R["crystal"])
    cv.rect(13, 8, 19, 13, R["crystal"][1])
    cv.rect(12, 6, 20, 8, R["wood"][2])
    for (x, y) in ((10, 7), (23, 9), (24, 15)):
        cv.ellipse(x, y, 1.4, 1.4, hexc("#c4e4ff"))


def g_hothe(cv):
    """Hộ Thể Pháp Lực: khiên phép tím quanh người."""
    _pv(cv, "#2a1e40")
    cv.ellipse(16, 16, 11, 11, hexc("#b36bff", 70))
    cv.arc(16, 16, 11, 0, math.tau, hexc("#c28af0"), 1.4)
    cv.shade_ellipse(16, 12, 3, 3, R["skin"])
    cv.shade_poly([(12, 15), (20, 15), (21, 24), (11, 24)], R["purple"])


# ---------------------------------------------------------------- Hộ Vệ
def g_kienthu(cv):
    """Kiên Thủ: khiên thép lớn."""
    _pv(cv, "#2a2a3a")
    _shield(cv, 16, 16, 1.05, R["steel"])
    cv.line(16, 9, 16, 24, R["gold"][2], 1.4)
    cv.line(9, 13, 23, 13, R["gold"][2], 1.4)


def g_ychisat(cv):
    """Ý Chí Sắt: tim xanh + dấu cộng hồi máu."""
    _pv(cv, "#1e3a2a")
    _heart(cv, 14, 15, 1.2, R["blood"])
    cv.line(23, 18, 23, 26, hexc("#7ae07a"), 2.2)
    cv.line(19, 22, 27, 22, hexc("#7ae07a"), 2.2)


def g_phanchan(cv):
    """Phản Chấn: khiên bật tia sét ngược."""
    _pv(cv, "#3a2a1a")
    _shield(cv, 13, 17, 0.9, R["steel"])
    for (x0, y0, x1, y1) in ((20, 10, 27, 6), (21, 16, 28, 16), (20, 22, 27, 26)):
        cv.line(x0, y0, x1, y1, hexc("#ffe07a"), 1.4)


def g_uyap(cv):
    """Uy Áp: búa nện vỡ đất."""
    _pv(cv, "#3a2e1e")
    for k in (-1, 1):
        cv.line(16, 24, 16 + k * 10, 27, R["stone"][3], 1.2)
        cv.line(16, 24, 16 + k * 7, 21, R["stone"][3], 1.0)
    cv.line(16, 8, 16, 23, R["wood"][2], 2.0)
    cv.shade_poly([(9, 6), (23, 6), (23, 12), (9, 12)], R["steel"])


# ---------------------------------------------------------------- Triệu Hồi Sư
def g_linhkhe(cv):
    """Linh Khế: bàn tay nối sợi tơ tới linh hồ."""
    _pv(cv, "#1e2a3a")
    cv.line(9, 22, 22, 11, hexc("#9de0ff", 200), 1.2)
    cv.shade_ellipse(9, 23, 3.5, 3, R["skin"])
    cv.shade_ellipse(22, 11, 4.5, 3.6, R["wisp"])
    cv.shade_poly([(19, 8), (21, 4), (22, 8)], R["wisp"])
    cv.shade_poly([(23, 8), (25, 4), (26, 9)], R["wisp"])


def g_linhthe(cv):
    """Linh Thể: linh thú + trái tim."""
    _pv(cv, "#2a1e3a")
    cv.shade_ellipse(14, 18, 7, 5.5, R["fur_void"])
    cv.shade_ellipse(9, 13, 3.5, 3.2, R["fur_void"])
    cv.set(8, 12, (255, 255, 255, 255))
    _heart(cv, 23, 10, 0.8, R["blood"])


def g_linhho(cv):
    """Linh Hộ: 3 đốm linh hồn bao quanh người."""
    _pv(cv, "#1e2a3a")
    cv.shade_ellipse(16, 13, 3, 3, R["skin"])
    cv.shade_poly([(12, 16), (20, 16), (21, 25), (11, 25)], R["cloth_blue"])
    for k in range(3):
        t = math.radians(-90 + k * 120 + 30)
        cv.shade_ellipse(16 + math.cos(t) * 11, 17 + math.sin(t) * 9, 2.4, 2.4, R["wisp"])


def g_honluc(cv):
    """Hồn Lực: cầu linh hồn sáng trong tay."""
    _pv(cv, "#2a1e3a")
    cv.ellipse(16, 13, 8, 8, hexc("#86d8e4", 70))
    cv.shade_ellipse(16, 13, 5, 5, R["wisp"])
    cv.shade_poly([(9, 22), (23, 22), (21, 27), (11, 27)], R["skin"])


PASSIVES = {"pv-tab": g_tab,
            "pv-thietcot": g_thietcot, "pv-kiemtam": g_kiemtam, "pv-phankich": g_phankich, "pv-chieny": g_chieny,
            "pv-ungmuc": g_ungmuc, "pv-sanmoi": g_sanmoi, "pv-buocgio": g_buocgio, "pv-tamdoc": g_tamdoc,
            "pv-minhtuong": g_minhtuong, "pv-nguyento": g_nguyento, "pv-doidao": g_doidao, "pv-hothe": g_hothe,
            "pv-kienthu": g_kienthu, "pv-ychisat": g_ychisat, "pv-phanchan": g_phanchan, "pv-uyap": g_uyap,
            "pv-linhkhe": g_linhkhe, "pv-linhthe": g_linhthe, "pv-linhho": g_linhho, "pv-honluc": g_honluc}


def register(skills):
    for k, v in PASSIVES.items():
        skills.setdefault(k, v)
