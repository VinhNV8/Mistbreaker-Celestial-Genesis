"""UI-40b (docs/35 §9): Làng Thanh Thạch HD — nhà gỗ mái ngói / mái tranh, giếng, đống rơm, thùng hàng, cột đèn lồng,
cọc rào, luống rau, nền sân đất nện + sân lát đá, bia đá (cel-shade như env_forest)."""
import math
import random

from PIL import Image, ImageDraw, ImageFilter

from env_forest import _tile
from vec import Canvas, Tone, bezier, hexc

PX = 4
OUTLINE = "#22180f"

WOOD = Tone("#8a5a36", "#5e3a20", "#b58358")
WOOD_DARK = Tone("#5f3d24", "#3c2614", "#86603c")
PLANK = Tone("#a8774a", "#7a5232", "#cfa070")
STONE = Tone("#9a9890", "#6c6a64", "#cfccc2")
THATCH = Tone("#c9a45c", "#94733a", "#ead08c")
ROOFS = [Tone("#56606e", "#363d48", "#8792a2"), Tone("#a2533a", "#6e3324", "#d07c5a"), THATCH]
PAPER = "#ffd98a"


def _shadow(c, x, y, rx, ry, a=70):
    c.flat(lambda d: c.ellipse(d, x, y, rx, ry), (12, 10, 6, 255), alpha=a, blur=3)


def _line(c, pts, col, w, alpha=255):
    s = c.ss
    c.flat(lambda d: d.line([(x * s, y * s) for x, y in pts], fill=255, width=max(1, int(w * s)), joint="curve"), col, alpha=alpha)


# ---------------------------------------------------------------- nhà


def house(variant):
    """0: mái ngói xám, 1: mái ngói đỏ, 2: mái tranh. Gốc = giữa chân tường trước."""
    w, h = 240, 232
    c = Canvas(w, h)
    ox, oy = 120, 218
    _shadow(c, ox + 8, oy - 2, 112, 16)
    # nền đá
    c.part(lambda d: c.poly(d, [(ox - 94, oy - 20), (ox + 94, oy - 20), (ox + 98, oy), (ox - 98, oy)]), STONE, shade_d=3, light_d=1.2)
    for k in range(7):
        x = ox - 94 + k * 28 + (k % 2) * 8
        _line(c, [(x, oy - 19), (x, oy - 1)], STONE.shade, 1.2, 200)
    _line(c, [(ox - 96, oy - 10), (ox + 96, oy - 10)], STONE.shade, 1.0, 160)
    # tường ván
    c.part(lambda d: c.poly(d, [(ox - 86, oy - 98), (ox + 86, oy - 98), (ox + 86, oy - 20), (ox - 86, oy - 20)]), PLANK, shade_d=5, light_d=1.2)
    for k in range(1, 22):
        x = ox - 86 + k * 8
        _line(c, [(x, oy - 96), (x, oy - 21)], PLANK.shade, 0.9, 150)
    # cột + xà
    for x in (ox - 86, ox - 36, ox + 36, ox + 86):
        c.part(lambda d, x=x: c.poly(d, [(x - 5, oy - 104), (x + 5, oy - 104), (x + 5, oy - 20), (x - 5, oy - 20)]), WOOD_DARK, shade_d=2.5, light_d=1)
    c.part(lambda d: c.poly(d, [(ox - 90, oy - 104), (ox + 90, oy - 104), (ox + 90, oy - 96), (ox - 90, oy - 96)]), WOOD_DARK, shade_d=2, light_d=1)
    # cửa (2 cánh, hé mở → ánh đèn trong nhà)
    c.part(lambda d: c.poly(d, [(ox - 20, oy - 78), (ox + 20, oy - 78), (ox + 20, oy - 20), (ox - 20, oy - 20)]), WOOD_DARK, shade_d=2, light_d=0)
    c.flat(lambda d: c.poly(d, [(ox - 3, oy - 74), (ox + 3, oy - 74), (ox + 3, oy - 21), (ox - 3, oy - 21)]), PAPER, alpha=220)
    c.glow(lambda d: c.poly(d, [(ox - 4, oy - 70), (ox + 4, oy - 70), (ox + 4, oy - 22), (ox - 4, oy - 22)]), "#ffcf6a", radius=4, alpha=120)
    for sx in (-1, 1):
        for k in range(3):
            y = oy - 72 + k * 18
            _line(c, [(ox + sx * 17, y), (ox + sx * 6, y)], WOOD.light, 1.1, 170)
    # bậc thềm
    c.part(lambda d: c.poly(d, [(ox - 28, oy - 6), (ox + 28, oy - 6), (ox + 30, oy + 2), (ox - 30, oy + 2)]), STONE, shade_d=2, light_d=1)
    # cửa sổ song gỗ, giấy sáng đèn
    for wx in (ox - 62, ox + 62):
        c.part(lambda d, wx=wx: c.poly(d, [(wx - 17, oy - 84), (wx + 17, oy - 84), (wx + 17, oy - 52), (wx - 17, oy - 52)]), WOOD_DARK, shade_d=1.5, light_d=0)
        c.flat(lambda d, wx=wx: c.poly(d, [(wx - 13, oy - 80), (wx + 13, oy - 80), (wx + 13, oy - 56), (wx - 13, oy - 56)]), PAPER)
        c.glow(lambda d, wx=wx: c.poly(d, [(wx - 13, oy - 80), (wx + 13, oy - 80), (wx + 13, oy - 56), (wx - 13, oy - 56)]), "#ffc04a", radius=5, alpha=110)
        for k in range(1, 4):
            _line(c, [(wx - 13 + k * 6.5, oy - 80), (wx - 13 + k * 6.5, oy - 56)], WOOD_DARK.base, 1.3)
        _line(c, [(wx - 13, oy - 68), (wx + 13, oy - 68)], WOOD_DARK.base, 1.3)
    roof = ROOFS[variant]
    if variant < 2:
        _tile_roof(c, ox, oy, roof)
    else:
        _thatch_roof(c, ox, oy)
    if variant == 0:
        # đèn lồng đỏ treo hiên
        for lx in (ox - 70, ox + 70):
            _line(c, [(lx, oy - 112), (lx, oy - 100)], WOOD_DARK.shade, 1.2)
            c.glow(lambda d, lx=lx: c.circle(d, lx, oy - 92, 9), "#ff7a3a", radius=6, alpha=130)
            c.part(lambda d, lx=lx: c.ellipse(d, lx, oy - 92, 7, 9), Tone("#d83a2a", "#8e2018", "#ff8a62"), shade_d=2.5, light_d=1)
            _line(c, [(lx - 4, oy - 100), (lx + 4, oy - 100)], "#e8b84a", 2)
            _line(c, [(lx - 4, oy - 84), (lx + 4, oy - 84)], "#e8b84a", 2)
    if variant == 1:
        # chum nước + chổi cạnh cửa
        c.part(lambda d: c.ellipse(d, ox + 40, oy - 12, 11, 12), Tone("#7a4a2e", "#4e2d1a", "#a8714a"), shade_d=3, light_d=1.2)
        c.flat(lambda d: c.ellipse(d, ox + 40, oy - 22, 8, 3), "#2b3b44")
        _line(c, [(ox - 40, oy - 2), (ox - 30, oy - 52)], WOOD.base, 2.2)
        c.part(lambda d: c.poly(d, [(ox - 46, oy + 2), (ox - 34, oy + 2), (ox - 36, oy - 14), (ox - 42, oy - 14)]), THATCH, shade_d=1.5, light_d=0.6)
    return c.render(outline=OUTLINE, width=2.4), [ox, oy]


def _tile_roof(c, ox, oy, roof):
    top, bot = oy - 196, oy - 98
    tl, tr = ox - 70, ox + 70
    bl, br = ox - 112, ox + 112

    def shape(d):
        # mái chính: hình thang nhìn từ trên-trước, mép dưới võng nhẹ, 2 góc đao cong vút
        pts = [(tl, top)]
        pts += bezier((tr, top), (tr + 4, top), (tr + 4, top))[:1]
        pts += [(br - 6, bot - 4), (br + 10, bot - 22), (br + 4, bot + 2)]
        pts += [(x, y) for x, y in bezier((br - 4, bot + 2), (ox, bot + 12), (bl + 4, bot + 2), n=12)]
        pts += [(bl - 4, bot + 2), (bl - 10, bot - 22), (bl + 6, bot - 4)]
        c.poly(d, pts)
    m = c.part(shape, roof, shade_d=6, light_d=1.6)
    # hàng ngói: rãnh dọc hội tụ lên nóc + gờ ngang
    n = 15
    for k in range(1, n):
        t = k / n
        x0 = tl + (tr - tl) * t
        x1 = bl + (br - bl) * t
        _line(c, [(x0, top + 4), (x1, bot - 2 + 8 * math.sin(math.pi * t))], roof.shade, 2.2, 200)
        _line(c, [(x0 + 3, top + 4), (x1 + 4, bot - 4 + 8 * math.sin(math.pi * t))], roof.light, 0.9, 110)
    for r in range(1, 6):
        y = top + (bot - top) * r / 6
        t = r / 6
        xl = tl + (bl - tl) * t
        xr = tr + (br - tr) * t
        _line(c, bezier((xl + 2, y), (ox, y + 6 * t), (xr - 2, y), n=10), roof.shade, 1.2, 140)
    # gờ mép mái (ngói ống tròn)
    c.part(lambda d: c.ribbon(d, bezier((bl - 2, bot + 1), (ox, bot + 13), (br + 2, bot + 1), n=16), [6] * 17), roof, shade_d=2, light_d=1.2)
    # nóc mái + 2 đầu đao
    c.part(lambda d: (c.poly(d, [(tl - 8, top - 6), (tr + 8, top - 6), (tr + 8, top + 6), (tl - 8, top + 6)]),
                      c.ribbon(d, bezier((tl - 6, top), (tl - 18, top + 2), (tl - 22, top - 14), n=8), [9, 8, 7, 6, 5, 4, 3.5, 3, 2.5]),
                      c.ribbon(d, bezier((tr + 6, top), (tr + 18, top + 2), (tr + 22, top - 14), n=8), [9, 8, 7, 6, 5, 4, 3.5, 3, 2.5])),
           Tone(roof.shade, None, roof.base), shade_d=2, light_d=1.2)
    c.part(lambda d: c.circle(d, ox, top - 2, 7), Tone("#c9a24a", "#8a6a28", "#f2d47a"), shade_d=2, light_d=1)


def _thatch_roof(c, ox, oy):
    top, bot = oy - 194, oy - 96
    rnd = random.Random(7)

    def shape(d):
        pts = [(x, y) for x, y in bezier((ox - 116, bot + 4), (ox - 104, top + 10), (ox - 40, top - 4), n=12)]
        pts += [(x, y) for x, y in bezier((ox + 40, top - 4), (ox + 104, top + 10), (ox + 116, bot + 4), n=12)]
        pts += [(x, y) for x, y in bezier((ox + 116, bot + 4), (ox, bot + 16), (ox - 116, bot + 4), n=14)]
        c.poly(d, pts)
    roof = c.part(shape, THATCH, shade_d=7, light_d=2)
    # lớp rơm chồng: các dải mép răng cưa
    for r in range(4):
        y = top + 24 + r * 22
        half = 70 + r * 12
        pts = []
        for k in range(0, 2 * half + 1, 6):
            pts.append((ox - half + k, y + (4 if (k // 6) % 2 else 0) + 6 * math.sin(math.pi * k / (2 * half))))
        c.part(lambda d, pts=pts: d.line([(x * c.ss, y * c.ss) for x, y in pts], fill=255, width=int(1.6 * c.ss)), Tone(THATCH.shade), clip=roof, shade=False, alpha=190)
    def straws(d):
        s = c.ss
        for _ in range(140):
            x = rnd.uniform(ox - 104, ox + 104)
            y = rnd.uniform(top + 8, bot)
            L = rnd.uniform(6, 14)
            d.line([(x * s, y * s), ((x + (x - ox) * 0.03) * s, (y + L) * s)], fill=255, width=int(0.8 * s))
    c.part(straws, Tone(THATCH.shade), clip=roof, shade=False, alpha=130)
    rnd2 = random.Random(9)
    def straws_l(d):
        s = c.ss
        for _ in range(90):
            x = rnd2.uniform(ox - 100, ox + 100)
            y = rnd2.uniform(top + 6, bot - 6)
            d.line([(x * s, y * s), (x * s, (y + rnd2.uniform(5, 10)) * s)], fill=255, width=int(0.7 * s))
    c.part(straws_l, Tone(THATCH.light), clip=roof, shade=False, alpha=150)
    # nóc buộc tre
    c.part(lambda d: c.ribbon(d, bezier((ox - 48, top + 2), (ox, top - 10), (ox + 48, top + 2), n=12), [9] * 13), WOOD, shade_d=2, light_d=1)
    for k in range(-2, 3):
        _line(c, [(ox + k * 18, top - 6 + abs(k) * 2), (ox + k * 18, top + 8 + abs(k) * 2)], WOOD_DARK.base, 1.6)


# ---------------------------------------------------------------- vật dụng


def well():
    c = Canvas(128, 152)
    ox, oy = 64, 140
    _shadow(c, ox + 4, oy - 2, 50, 10)
    # thành giếng đá
    c.part(lambda d: (c.ellipse(d, ox, oy - 14, 42, 13), c.poly(d, [(ox - 42, oy - 40), (ox + 42, oy - 40), (ox + 42, oy - 14), (ox - 42, oy - 14)]),
                      c.ellipse(d, ox, oy - 40, 42, 13)), STONE, shade_d=4, light_d=1.4)
    for k in range(5):
        x = ox - 34 + k * 17
        _line(c, [(x, oy - 36), (x + 2, oy - 18)], STONE.shade, 1.1, 180)
    _line(c, bezier((ox - 42, oy - 27), (ox, oy - 14), (ox + 42, oy - 27), n=10), STONE.shade, 1.1, 170)
    c.flat(lambda d: c.ellipse(d, ox, oy - 41, 34, 9), "#1e3540")
    c.flat(lambda d: c.ellipse(d, ox - 8, oy - 43, 12, 3), "#5f8ea0", alpha=150)
    # khung gỗ + mái nhỏ + tời
    for x in (ox - 40, ox + 40):
        c.part(lambda d, x=x: c.poly(d, [(x - 4, oy - 112), (x + 4, oy - 112), (x + 4, oy - 34), (x - 4, oy - 34)]), WOOD, shade_d=2, light_d=1)
    c.part(lambda d: c.capsule(d, (ox - 40, oy - 92), (ox + 40, oy - 92), 4), WOOD_DARK, shade_d=1.5, light_d=1)
    _line(c, [(ox + 6, oy - 92), (ox + 6, oy - 60)], "#d8c79a", 1.2)
    c.part(lambda d: c.poly(d, [(ox, oy - 62), (ox + 12, oy - 62), (ox + 10, oy - 48), (ox + 2, oy - 48)]), WOOD, shade_d=1.5, light_d=0.8)
    c.part(lambda d: c.poly(d, [(ox - 56, oy - 104), (ox, oy - 140), (ox + 56, oy - 104), (ox + 50, oy - 98), (ox, oy - 128), (ox - 50, oy - 98)]),
           ROOFS[1], shade_d=3, light_d=1.2)
    return c.render(outline=OUTLINE, width=2.2), [ox, oy]


def haystack():
    c = Canvas(112, 104)
    ox, oy = 56, 94
    rnd = random.Random(4)
    _shadow(c, ox + 4, oy - 2, 46, 9)
    c.part(lambda d: (c.ellipse(d, ox, oy - 30, 44, 30), c.ellipse(d, ox, oy - 54, 30, 30), c.ellipse(d, ox, oy - 12, 46, 12)), THATCH, shade_d=8, light_d=2)
    def straws(d):
        s = c.ss
        for _ in range(120):
            a = rnd.uniform(math.pi * 1.05, math.pi * 1.95)
            rr = rnd.uniform(8, 40)
            x, y = ox + math.cos(a) * rr, oy - 34 + math.sin(a) * rr * 0.9 + 24
            d.line([(x * s, y * s), ((x + math.cos(a) * 6) * s, (y + 5) * s)], fill=255, width=int(0.8 * s))
    c.flat(straws, THATCH.shade, alpha=150)
    _line(c, bezier((ox - 30, oy - 54), (ox, oy - 42), (ox + 30, oy - 54), n=10), WOOD_DARK.base, 2)
    _line(c, [(ox, oy - 84), (ox + 2, oy - 98)], WOOD.base, 2.4)
    return c.render(outline=OUTLINE, width=2.2), [ox, oy]


def crates():
    c = Canvas(136, 112)
    ox, oy = 68, 100
    _shadow(c, ox + 4, oy - 2, 58, 9)
    def box(x, y, s):
        c.part(lambda d: c.poly(d, [(x - s, y - 2 * s), (x + s, y - 2 * s), (x + s, y), (x - s, y)]), PLANK, shade_d=3, light_d=1.2)
        c.part(lambda d: c.poly(d, [(x - s, y - 2 * s), (x + s, y - 2 * s), (x + s - 4, y - 2 * s - 9), (x - s + 4, y - 2 * s - 9)]), Tone(PLANK.light, PLANK.base, None), shade_d=0)
        _line(c, [(x - s + 2, y - 2), (x + s - 2, y - 2 * s + 2)], WOOD_DARK.base, 2)
        _line(c, [(x - s + 2, y - 2 * s + 2), (x + s - 2, y - 2)], WOOD_DARK.base, 2)
        for yy in (y - 2 * s + 2, y - 2):
            _line(c, [(x - s, yy), (x + s, yy)], WOOD_DARK.base, 2.4)
    box(ox - 30, oy - 2, 18)
    box(ox - 24, oy - 40, 14)
    # thùng gỗ đai sắt
    bx = ox + 30
    c.part(lambda d: (c.ellipse(d, bx, oy - 6, 20, 7), c.poly(d, [(bx - 20, oy - 48), (bx + 20, oy - 48), (bx + 22, oy - 28), (bx + 20, oy - 6), (bx - 20, oy - 6), (bx - 22, oy - 28)])),
           WOOD, shade_d=4, light_d=1.4)
    for yy in (oy - 40, oy - 16):
        _line(c, [(bx - 21, yy), (bx + 21, yy)], "#3d3d44", 2.4)
    c.part(lambda d: c.ellipse(d, bx, oy - 48, 20, 7), Tone(WOOD.light, WOOD.base, None), shade_d=0)
    # bao tải
    c.part(lambda d: (c.ellipse(d, ox + 2, oy - 10, 14, 11), c.circle(d, ox + 2, oy - 24, 8)), Tone("#cdb88a", "#94815a", "#ecdcb4"), shade_d=3, light_d=1)
    _line(c, [(ox - 4, oy - 28), (ox + 8, oy - 28)], WOOD_DARK.base, 1.6)
    return c.render(outline=OUTLINE, width=2.2), [ox, oy]


def lantern_post():
    c = Canvas(64, 152)
    ox, oy = 32, 142
    _shadow(c, ox + 3, oy - 1, 16, 5)
    c.part(lambda d: c.poly(d, [(ox - 10, oy - 8), (ox + 10, oy - 8), (ox + 12, oy), (ox - 12, oy)]), STONE, shade_d=2, light_d=1)
    c.part(lambda d: c.poly(d, [(ox - 4, oy - 128), (ox + 4, oy - 128), (ox + 4, oy - 6), (ox - 4, oy - 6)]), WOOD_DARK, shade_d=2, light_d=1)
    c.part(lambda d: c.capsule(d, (ox - 4, oy - 124), (ox + 22, oy - 124), 3), WOOD_DARK, shade_d=1, light_d=0.6)
    _line(c, [(ox + 18, oy - 122), (ox + 18, oy - 112)], WOOD_DARK.shade, 1.2)
    c.glow(lambda d: c.circle(d, ox + 18, oy - 98, 14), "#ffb04a", radius=8, alpha=150)
    c.part(lambda d: c.ellipse(d, ox + 18, oy - 98, 9, 12), Tone("#e04a2c", "#9a2a1a", "#ff9a6a"), shade_d=3, light_d=1)
    c.flat(lambda d: c.ellipse(d, ox + 16, oy - 100, 3, 5), "#ffe2a0", alpha=200)
    _line(c, [(ox + 13, oy - 109), (ox + 23, oy - 109)], "#e8b84a", 2.2)
    _line(c, [(ox + 13, oy - 87), (ox + 23, oy - 87)], "#e8b84a", 2.2)
    return c.render(outline=OUTLINE, width=2.0), [ox, oy]


def fence_post():
    c = Canvas(24, 56)
    ox, oy = 12, 50
    _shadow(c, ox + 2, oy - 1, 8, 3, a=60)
    c.part(lambda d: c.poly(d, [(ox - 4, oy - 38), (ox, oy - 46), (ox + 4, oy - 38), (ox + 4, oy - 2), (ox - 4, oy - 2)]), WOOD, shade_d=2, light_d=0.8)
    return c.render(outline=OUTLINE, width=1.6), [ox, oy]


def garden():
    """Luống rau (phẳng, vẽ dưới cùng). Gốc = tâm."""
    c = Canvas(176, 104)
    ox, oy = 88, 52
    c.part(lambda d: c.poly(d, [(ox - 82, oy - 44), (ox + 82, oy - 44), (ox + 84, oy + 46), (ox - 84, oy + 46)]), WOOD, shade_d=2, light_d=1)
    c.part(lambda d: c.poly(d, [(ox - 76, oy - 38), (ox + 76, oy - 38), (ox + 78, oy + 40), (ox - 78, oy + 40)]), Tone("#6b4a30", "#4a321f", "#86603e"), shade_d=0)
    rnd = random.Random(12)
    for r in range(4):
        y = oy - 26 + r * 20
        c.part(lambda d, y=y: c.capsule(d, (ox - 70, y), (ox + 70, y), 6), Tone("#7c5636", "#553820", "#9a7048"), shade_d=2, light_d=1)
        leaf = Tone("#5fae4a", "#357a2e", "#a2df72") if r % 2 == 0 else Tone("#7cc25a", "#4a8a36", "#c2ec8a")
        for k in range(9):
            x = ox - 64 + k * 16 + rnd.uniform(-2, 2)
            c.part(lambda d, x=x, y=y: (c.ellipse(d, x - 4, y - 5, 5, 3, 0.6), c.ellipse(d, x + 4, y - 5, 5, 3, -0.6), c.circle(d, x, y - 7, 3.4)),
                   leaf, shade_d=1.2, light_d=0.6)
    return c.render(outline=OUTLINE, width=1.6), [ox, oy]


def stele():
    """Bia đá Thanh Thạch (cùng kích thước logic với bản pixel 24×40, gốc 12,36)."""
    c = Canvas(96, 160)
    ox, oy = 48, 144
    _shadow(c, ox + 4, oy, 40, 9)
    c.part(lambda d: c.poly(d, [(ox - 40, oy - 18), (ox + 40, oy - 18), (ox + 44, oy + 2), (ox - 44, oy + 2)]), STONE, shade_d=3, light_d=1.2)
    slab = Tone("#8f97a3", "#5f6672", "#c8d0da")
    c.part(lambda d: (c.poly(d, [(ox - 28, oy - 18), (ox + 28, oy - 18), (ox + 26, oy - 118), (ox - 26, oy - 118)]),
                      c.ellipse(d, ox, oy - 118, 26, 14)), slab, shade_d=7, light_d=1.6)
    c.flat(lambda d: c.poly(d, [(ox - 14, oy - 104), (ox + 14, oy - 104), (ox + 14, oy - 34), (ox - 14, oy - 34)]), slab.shade, alpha=200)
    c.glow(lambda d: c.poly(d, [(ox - 5, oy - 96), (ox + 5, oy - 96), (ox + 5, oy - 42), (ox - 5, oy - 42)]), "#ffd36a", radius=6, alpha=170)
    for k in range(5):
        y = oy - 94 + k * 12
        _line(c, [(ox - 6, y), (ox + 6, y)], "#ffe7a6", 2.2)
        _line(c, [(ox, y - 3), (ox, y + 4)], "#ffe7a6", 1.6)
    return c.render(outline=OUTLINE, width=2.2), [ox, oy]


# ---------------------------------------------------------------- nền


def yard():
    """Đất nện sân làng (ô lặp 256)."""
    img = _tile(256, "#9a7a52", [("#8e7250", 14, 16, 38, 70), ("#a98a62", 12, 12, 30, 60)],
                [("#7a6040", 50, 4, 110), ("#b89a72", 34, 3, 110)], seed=31)
    d = ImageDraw.Draw(img)
    rnd = random.Random(32)
    for _ in range(40):
        x, y, r = rnd.uniform(0, 256), rnd.uniform(0, 256), rnd.uniform(1.5, 3.5)
        for ox in (-256, 0, 256):
            for oy in (-256, 0, 256):
                d.ellipse([x + ox - r, y + oy - r * 0.7, x + ox + r, y + oy + r * 0.7], fill=hexc(rnd.choice(["#c4b49a", "#7f725e", "#a89a82"])))
    return img


def plaza():
    """Sân lát đá phiến (ô lặp 256, 4 hàng × 4 phiến so le)."""
    W = 256
    ss = 2
    img = Image.new("RGBA", (W * ss, W * ss), hexc("#5a564e"))
    d = ImageDraw.Draw(img)
    rnd = random.Random(41)
    rows = 4
    rh = W / rows
    for r in range(rows):
        cols = 4
        cw = W / cols
        off = (cw / 2) if r % 2 else 0
        for k in range(-1, cols + 1):
            x0 = k * cw + off
            col = rnd.choice(["#8d877a", "#837d70", "#958f82", "#7c766a", "#8a8578"])
            g = 4
            box = [(x0 + g) * ss, (r * rh + g) * ss, (x0 + cw - g) * ss, ((r + 1) * rh - g) * ss]
            d.rounded_rectangle(box, radius=7 * ss, fill=hexc(col))
            d.rounded_rectangle([box[0], box[1], box[2], box[1] + 5 * ss], radius=5 * ss, fill=hexc("#aaa498", 110))
            d.line([box[0] + 6 * ss, box[3] - 2 * ss, box[2] - 6 * ss, box[3] - 2 * ss], fill=hexc("#6e6a62", 160), width=2 * ss)
            for _ in range(2):
                cx, cy = rnd.uniform(box[0], box[2]), rnd.uniform(box[1], box[3])
                d.line([cx, cy, cx + rnd.uniform(-14, 14) * ss, cy + rnd.uniform(-8, 8) * ss], fill=hexc("#77736a", 150), width=ss)
    for _ in range(26):
        x, y = rnd.uniform(0, W) * ss, rnd.uniform(0, W) * ss
        d.ellipse([x - 5 * ss, y - 3 * ss, x + 5 * ss, y + 3 * ss], fill=hexc("#5f8a45", 90))
    img = img.filter(ImageFilter.GaussianBlur(0.6 * ss))
    return img.resize((W, W), Image.LANCZOS)


def build():
    """{id: (Image, origin)}"""
    out = {}
    for v in range(3):
        out["house-village-%d" % v] = house(v)
    out["village-well"] = well()
    out["haystack"] = haystack()
    out["crates"] = crates()
    out["lantern-post"] = lantern_post()
    out["fence-post"] = fence_post()
    out["garden"] = garden()
    out["stele"] = stele()
    out["tile-village"] = (yard(), [0, 0])
    out["tile-plaza"] = (plaza(), [0, 0])
    return out


if __name__ == "__main__":
    import os
    res = build()
    prev = Image.new("RGBA", (1500, 560), hexc("#4b7d3c"))
    t = res["tile-village"][0]
    for x in range(0, 1500, 256):
        for y in range(0, 300, 256):
            prev.alpha_composite(t, (x, y))
    prev.alpha_composite(res["tile-plaza"][0], (840, 300))
    x = 10
    for k in ["house-village-0", "house-village-1", "house-village-2", "village-well", "haystack", "crates", "lantern-post", "fence-post", "stele"]:
        im, o = res[k]
        if x + im.size[0] > 1500:
            break
        prev.alpha_composite(im, (x, 260 - o[1]))
        x += im.size[0]
    prev.alpha_composite(res["garden"][0], (10, 300))
    out = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "_preview", "hd-village.png")
    os.makedirs(os.path.dirname(out), exist_ok=True)
    prev.save(out)
    print("ok", out)
