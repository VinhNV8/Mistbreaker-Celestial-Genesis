"""SK2 (docs/13): icon 12 kỹ năng mới — cấp 15/22 và chuyển chức 1 của 3 lớp.
icons.py chỉ gọi register(SKILLS) ở cuối file."""
import math

from pixel import R, hexc, mix


def _bg(cv, hex_bg):
    from icons import _skill_bg
    _skill_bg(cv, hex_bg)


def _sword(cv, s=0.7, ox=0, oy=0):
    from icons import g_sword
    g_sword(cv, s, ox, oy)


# ---------------------------------------------------------------- Kiếm Khách
def g_lientram(cv):
    """Liên Trảm: 3 vệt chém song song."""
    _bg(cv, "#3a3550")
    for k in range(3):
        y = 9 + k * 7
        cv.arc(8, y + 10, 14, math.radians(-70), math.radians(-10), (255, 255, 255, 110 + k * 50), 2.4)
    _sword(cv, 0.55, 8, 4)


def g_hongkiem(cv):
    """Hống Kiếm: sóng âm toả tròn quanh thanh kiếm cắm đất."""
    _bg(cv, "#4a3a20")
    for r, a in ((13, 90), (10, 150), (7, 220)):
        cv.arc(16, 18, r, math.radians(200), math.radians(340), hexc("#ffd76a", a), 1.6)
    cv.line(16, 6, 16, 27, R["steel"][3], 2.0)
    cv.line(12, 10, 20, 10, R["gold"][2], 1.6)


def g_kiemvu(cv):
    """Kiếm Vũ: lốc nhiều thanh kiếm."""
    _bg(cv, "#28405a")
    for i in range(4):
        a = math.radians(i * 90 + 20)
        x, y = 16 + math.cos(a) * 9, 16 + math.sin(a) * 9
        cv.line(16 + math.cos(a) * 3, 16 + math.sin(a) * 3, x, y, R["steel"][3], 1.6)
        cv.arc(16, 16, 12, a, a + math.radians(55), hexc("#c8e6ff", 160), 1.4)
    cv.ellipse(16, 16, 2.5, 2.5, (255, 255, 255, 255))


def g_phikiem(cv):
    """Phi Kiếm: 3 thanh kiếm bay toả quạt."""
    _bg(cv, "#30405a")
    for k in (-1, 0, 1):
        a = math.radians(-40 + k * 18)
        x0, y0 = 7, 25
        x1, y1 = x0 + math.cos(a) * 19, y0 + math.sin(a) * 19
        cv.line(x0, y0, x1, y1, R["steel"][3], 1.8)
        cv.line(x0, y0, x0 + math.cos(a) * 5, y0 + math.sin(a) * 5, R["gold"][2], 2.2)


# ---------------------------------------------------------------- Thợ Săn
def g_tennay(cv):
    """Tên Nảy: mũi tên gấp khúc qua 3 điểm."""
    _bg(cv, "#2c4a3a")
    pts = [(5, 24), (13, 9), (20, 22), (27, 8)]
    for a, b in zip(pts, pts[1:]):
        cv.line(*a, *b, hexc("#d8ffd0"), 1.4)
    for p in pts[1:]:
        cv.ellipse(*p, 2, 2, hexc("#ff7a5a"))
    cv.shade_poly([(27, 8), (22, 9), (25, 12)], R["steel"])


def g_lanban(cv):
    """Lăn Bắn: vệt lăn + 3 mũi tên."""
    _bg(cv, "#2c4a3a")
    for i in range(3):
        cv.line(4, 20 + i * 2, 11, 20 + i * 2, (220, 255, 230, 120 + i * 40), 1.2)
    for k in (-1, 0, 1):
        cv.line(13, 16, 27, 16 + k * 6, hexc("#f0e6c8"), 1.3)
        cv.set(27, 16 + k * 6, R["steel"][3])


def g_lienxa(cv):
    """Liên Xạ: chuỗi mũi tên nối đuôi."""
    _bg(cv, "#304a2c")
    for i in range(4):
        x = 5 + i * 6
        cv.line(x, 22 - i * 3, x + 8, 18 - i * 3, hexc("#f0e6c8"), 1.3)
        cv.shade_poly([(x + 8, 18 - i * 3), (x + 5, 17 - i * 3), (x + 6, 20 - i * 3)], R["steel"])


def g_tendoc(cv):
    """Tên Độc: mũi tên xanh độc nhỏ giọt."""
    _bg(cv, "#2a4a2a")
    cv.line(5, 26, 25, 8, hexc("#f0e6c8"), 1.5)
    cv.shade_poly([(25, 8), (19, 9), (23, 13)], [hexc("#2f6a2f"), hexc("#4fb04f"), hexc("#7ae07a"), hexc("#b8ffb0")])
    for x, y in ((14, 20), (18, 24), (10, 24)):
        cv.ellipse(x, y, 1.5, 2, hexc("#7ae07a"))


# ---------------------------------------------------------------- Pháp Sư
def g_hoatuong(cv):
    """Hoả Tường: dãy ngọn lửa thẳng hàng."""
    _bg(cv, "#4a2418")
    for i in range(4):
        x = 6 + i * 6.5
        cv.shade_poly([(x - 3, 25), (x, 11 + (i % 2) * 3), (x + 3, 25)], R["fire"])
        cv.shade_poly([(x - 1.4, 25), (x, 17 + (i % 2) * 2), (x + 1.4, 25)], [hexc("#fff2c8")] * 4)
    cv.rect(3, 25, 29, 27, R["stone"][1])


def g_dichchuyen(cv):
    """Dịch Chuyển: 2 vòng xoáy nối mũi tên."""
    _bg(cv, "#28304a")
    for cx in (9, 23):
        cv.arc(cx, 16, 6, 0, math.tau, hexc("#9de0ff"), 1.6)
        cv.arc(cx, 16, 3, 0, math.tau, hexc("#ffffff", 180), 1.0)
    cv.line(13, 16, 19, 16, hexc("#ffffff"), 1.4)
    cv.shade_poly([(19, 13), (22, 16), (19, 19)], [hexc("#ffffff")] * 4)


def g_muabang(cv):
    """Mưa Băng: mây + tinh thể băng rơi."""
    _bg(cv, "#24384a")
    cv.shade_ellipse(16, 9, 10, 4.5, R["white"])
    for x, y in ((9, 18), (16, 22), (23, 18), (12, 26), (21, 26)):
        cv.line(x, y - 3, x, y + 3, hexc("#9de0ff"), 1.4)
        cv.line(x - 2, y, x + 2, y, hexc("#9de0ff"), 1.0)


def g_causam(cv):
    """Cầu Sấm: quả cầu tím toả tia sét."""
    _bg(cv, "#2e2450")
    for i in range(6):
        a = math.radians(i * 60 + 15)
        x, y = 16 + math.cos(a) * 12, 16 + math.sin(a) * 12
        mx, my = 16 + math.cos(a + 0.3) * 8, 16 + math.sin(a + 0.3) * 8
        cv.line(16, 16, mx, my, hexc("#e8d0ff"), 1.0)
        cv.line(mx, my, x, y, hexc("#e8d0ff"), 1.0)
    cv.shade_ellipse(16, 16, 5.5, 5.5, R["purple"])
    cv.set(14, 14, (255, 255, 255, 255))


# ---------------------------------------------------------------- SK3: tối thượng (viền vàng) + kỹ năng nhánh chuyển chức 2
def _ult(cv, hex_bg):
    _bg(cv, hex_bg)
    for (x0, y0, x1, y1) in ((2, 2, 30, 2), (2, 30, 30, 30), (2, 2, 2, 30), (30, 2, 30, 30)):
        cv.line(x0, y0, x1, y1, R["gold"][3], 1.2)


def g_vankiem(cv):
    _ult(cv, "#3a2a10")
    for i in range(8):
        a = math.radians(i * 45)
        x, y = 16 + math.cos(a) * 11, 16 + math.sin(a) * 11
        cv.line(16 + math.cos(a) * 4, 16 + math.sin(a) * 4, x, y, R["steel"][3], 1.4)
    cv.ellipse(16, 16, 3, 3, R["gold"][3])


def g_thientien(cv):
    _ult(cv, "#203a1a")
    for i in range(7):
        x = 5 + i * 3.6
        cv.line(x, 4 + (i % 2) * 3, x - 3, 22 + (i % 3) * 2, hexc("#f0e6c8"), 1.1)
    cv.shade_ellipse(16, 26, 11, 2.5, R["dirt"])


def g_thienhoa(cv):
    _ult(cv, "#3a1408")
    for (x, y, r) in ((10, 20, 4.5), (21, 14, 3.5), (18, 25, 3)):
        cv.line(x + 6, y - 9, x, y, R["fire"][3], 2.0)
        cv.shade_ellipse(x, y, r, r, R["fire"])


def g_thanhkiem(cv):
    _bg(cv, "#4a4020")
    cv.line(4, 28, 28, 4, hexc("#fff2c8", 140), 5)
    cv.line(4, 28, 28, 4, hexc("#ffffff"), 1.6)
    _sword(cv, 0.6, 6, 6)


def g_kiemvuc(cv):
    _bg(cv, "#30405a")
    cv.arc(16, 16, 12, 0, math.tau, hexc("#c8e6ff", 200), 1.4)
    for i in range(6):
        a = math.radians(i * 60)
        x, y = 16 + math.cos(a) * 9, 16 + math.sin(a) * 9
        cv.line(x, y - 4, x, y + 3, R["steel"][3], 1.2)


def g_huyetbao(cv):
    _bg(cv, "#4a1420")
    for i in range(8):
        a = math.radians(i * 45 + 10)
        cv.line(16, 16, 16 + math.cos(a) * 12, 16 + math.sin(a) * 12, hexc("#ff4a5a"), 1.4)
    cv.shade_ellipse(16, 16, 5, 5, R["blood"])


def g_huyetanh(cv):
    _bg(cv, "#3a1420")
    for k, a in enumerate((90, 180)):
        x0 = 4 + k * 6
        cv.line(x0, 24 - k * 8, x0 + 16, 18 - k * 8, hexc("#ff4a5a", a), 2.0)
    _sword(cv, 0.55, 10, 2)


def g_phakhong(cv):
    _bg(cv, "#1a3a4a")
    cv.line(3, 26, 29, 6, hexc("#8fd8ff", 120), 4)
    cv.line(3, 26, 29, 6, hexc("#ffffff"), 1.4)
    cv.shade_poly([(29, 6), (23, 7), (27, 11)], R["steel"])


def g_tamlien(cv):
    _bg(cv, "#1a3a4a")
    for k in range(3):
        y = 9 + k * 7
        cv.line(4, y, 26, y, hexc("#f0e6c8"), 1.3)
        cv.shade_poly([(28, y), (24, y - 2), (24, y + 2)], R["steel"])


def g_baimin(cv):
    _bg(cv, "#2c4a2c")
    for i in range(5):
        a = math.radians(i * 72 - 90)
        x, y = 16 + math.cos(a) * 9, 16 + math.sin(a) * 9
        cv.shade_ellipse(x, y, 3, 2.2, R["steel"])
        cv.set(x, y - 1, hexc("#ff5a3a"))


def g_luoibay(cv):
    _bg(cv, "#2c4a2c")
    for k in range(-2, 3):
        cv.line(6, 16 + k * 4, 26, 16 + k * 4, R["leather"][2], 1.0)
        cv.line(16 + k * 4, 6, 16 + k * 4, 26, R["leather"][2], 1.0)
    cv.arc(16, 16, 11, 0, math.tau, R["leather"][3], 1.2)


def g_thienloi(cv):
    _bg(cv, "#24204a")
    for x0 in (8, 16, 24):
        pts = [(x0 + 2, 3), (x0 - 2, 12), (x0 + 2, 14), (x0 - 1, 27)]
        for a, b in zip(pts, pts[1:]):
            cv.line(*a, *b, hexc("#fff6a0"), 1.3)


def g_bangphong(cv):
    _bg(cv, "#1a304a")
    for i in range(6):
        a = math.radians(i * 60)
        cv.line(16, 16, 16 + math.cos(a) * 12, 16 + math.sin(a) * 12, hexc("#9de0ff"), 1.6)
        cv.line(16 + math.cos(a) * 7, 16 + math.sin(a) * 7, 16 + math.cos(a + 0.4) * 9, 16 + math.sin(a + 0.4) * 9, hexc("#ffffff"), 1.0)


def g_trieuhoi(cv):
    _bg(cv, "#2a2620")
    for x in (9, 16, 23):
        cv.shade_ellipse(x, 12, 3, 3, R["white"])
        cv.line(x, 15, x, 24, R["white"][2], 1.4)
        cv.line(x - 3, 19, x + 3, 19, R["white"][2], 1.0)


def g_khidoc(cv):
    _bg(cv, "#20381e")
    for (x, y, r) in ((11, 18, 6), (20, 15, 7), (16, 23, 5)):
        cv.ellipse(x, y, r, r * 0.8, hexc("#7ae07a", 120))
    cv.shade_ellipse(16, 12, 3, 3, R["white"])
    cv.set(15, 12, (20, 20, 20, 255))
    cv.set(17, 12, (20, 20, 20, 255))


SKILLS2 = {"lientram": g_lientram, "hongkiem": g_hongkiem, "kiemvu": g_kiemvu, "phikiem": g_phikiem,
           "tennay": g_tennay, "lanban": g_lanban, "lienxa": g_lienxa, "tendoc": g_tendoc,
           "hoatuong": g_hoatuong, "dichchuyen": g_dichchuyen, "muabang": g_muabang, "causam": g_causam,
           "vankiem": g_vankiem, "thientien": g_thientien, "thienhoa": g_thienhoa,
           "thanhkiem": g_thanhkiem, "kiemvuc": g_kiemvuc, "huyetbao": g_huyetbao, "huyetanh": g_huyetanh,
           "phakhong": g_phakhong, "tamlien": g_tamlien, "baimin": g_baimin, "luoibay": g_luoibay,
           "thienloi": g_thienloi, "bangphong": g_bangphong, "trieuhoi": g_trieuhoi, "khidoc": g_khidoc}


def register(skills):
    for k, v in SKILLS2.items():
        skills.setdefault(k, v)
