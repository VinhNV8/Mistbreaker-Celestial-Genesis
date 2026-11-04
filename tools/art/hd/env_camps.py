"""UI-40c (docs/35 §10): khu an toàn HD của 8 vùng còn lại — nhà / lều / chòi / đình theo vùng, cọc rào, đồ vật,
nền sân (cel-shade như env_village). Gốc mọi hình = giữa chân (điểm chạm đất phía trước)."""
import math
import random

from PIL import Image, ImageDraw, ImageFilter

from env_forest import _tile
from env_village import OUTLINE, PAPER, PLANK, ROOFS, STONE, THATCH, WOOD, WOOD_DARK, _line, _shadow, _thatch_roof, _tile_roof
from vec import Canvas, Tone, bezier, hexc

PLASTER = Tone("#e8e0cc", "#b8ad94", "#fbf6e8")
BASALT = Tone("#4a4448", "#2c282c", "#6e676c")
LOGS = Tone("#8a5c3a", "#5a3a22", "#b07c52")
MARBLE = Tone("#ece6da", "#bdb4a4", "#ffffff")
JADE = Tone("#6fc4a0", "#3f8a6e", "#a8ecc8")
GOLD = Tone("#d9b04a", "#9a7428", "#f6dc8a")
VOID = Tone("#5a4a8a", "#352a5c", "#8c7ac8")
SNOW = Tone("#f2f6fb", "#c4d2e2", "#ffffff")
IRON = Tone("#55555e", "#33333a", "#86868f")
CLAY = Tone("#b8693e", "#7e4224", "#e0946a")
FIRE = "#ffb347"


# ---------------------------------------------------------------- nhà khung chung


def building(wall="plank", roof="tile-gray", door=True, snow=False, raise_y=0, w=240, h=232):
    """Nhà một gian 3/4: nền, tường (plank / plaster / basalt / logs), cột, cửa, 2 cửa sổ, mái (tile-* / thatch / slate)."""
    c = Canvas(w, h + raise_y)
    ox, oy = w // 2, h - 14
    if raise_y:
        _stilts(c, ox, oy + raise_y)
    c2 = c
    _shadow(c2, ox + 8, oy + raise_y - 2, 112, 16) if not raise_y else None
    wt = {"plank": PLANK, "plaster": PLASTER, "basalt": BASALT, "logs": LOGS, "marble": MARBLE}[wall]
    base = BASALT if wall == "basalt" else STONE
    if not raise_y:
        c.part(lambda d: c.poly(d, [(ox - 94, oy - 20), (ox + 94, oy - 20), (ox + 98, oy), (ox - 98, oy)]), base, shade_d=3, light_d=1.2)
        _line(c, [(ox - 96, oy - 10), (ox + 96, oy - 10)], base.shade, 1.0, 160)
    c.part(lambda d: c.poly(d, [(ox - 86, oy - 98), (ox + 86, oy - 98), (ox + 86, oy - 20), (ox - 86, oy - 20)]), wt, shade_d=5, light_d=1.2)
    if wall == "plank":
        for k in range(1, 22):
            _line(c, [(ox - 86 + k * 8, oy - 96), (ox - 86 + k * 8, oy - 21)], wt.shade, 0.9, 150)
    elif wall == "logs":
        for k in range(10):
            y = oy - 94 + k * 8
            c.part(lambda d, y=y: c.capsule(d, (ox - 90, y), (ox + 90, y), 4), wt, shade_d=1.6, light_d=0.8)
            c.flat(lambda d, y=y: (c.circle(d, ox - 90, y, 3.2), c.circle(d, ox + 90, y, 3.2)), "#c89a6a")
    elif wall == "basalt":
        rnd = random.Random(3)
        for r in range(5):
            y = oy - 96 + r * 16
            for k in range(7):
                x = ox - 86 + k * 28 + (r % 2) * 14
                _line(c, [(x, y), (x, y + 15)], BASALT.shade, 1.4, 220)
            _line(c, [(ox - 86, y), (ox + 86, y)], BASALT.shade, 1.4, 220)
        for _ in range(5):
            x, y = rnd.uniform(ox - 80, ox + 80), rnd.uniform(oy - 90, oy - 30)
            c.glow(lambda d, x=x, y=y: c.circle(d, x, y, 2), "#ff7a2a", radius=2, alpha=150)
    else:
        # vách trát + khung gỗ
        for x in (ox - 60, ox + 60):
            _line(c, [(x, oy - 96), (x, oy - 21)], WOOD_DARK.base, 3)
        _line(c, [(ox - 86, oy - 60), (ox - 34, oy - 60)], WOOD_DARK.base, 3)
        _line(c, [(ox + 34, oy - 60), (ox + 86, oy - 60)], WOOD_DARK.base, 3)
    post = GOLD if wall == "marble" else WOOD_DARK
    for x in (ox - 86, ox - 36, ox + 36, ox + 86):
        c.part(lambda d, x=x: c.poly(d, [(x - 5, oy - 104), (x + 5, oy - 104), (x + 5, oy - 20), (x - 5, oy - 20)]), post, shade_d=2.5, light_d=1)
    c.part(lambda d: c.poly(d, [(ox - 90, oy - 104), (ox + 90, oy - 104), (ox + 90, oy - 96), (ox - 90, oy - 96)]), post, shade_d=2, light_d=1)
    if door:
        c.part(lambda d: c.poly(d, [(ox - 20, oy - 78), (ox + 20, oy - 78), (ox + 20, oy - 20), (ox - 20, oy - 20)]), WOOD_DARK, shade_d=2, light_d=0)
        c.flat(lambda d: c.poly(d, [(ox - 3, oy - 74), (ox + 3, oy - 74), (ox + 3, oy - 21), (ox - 3, oy - 21)]), PAPER, alpha=220)
        c.glow(lambda d: c.poly(d, [(ox - 4, oy - 70), (ox + 4, oy - 70), (ox + 4, oy - 22), (ox - 4, oy - 22)]), "#ffcf6a", radius=4, alpha=120)
    for wx in (ox - 62, ox + 62):
        c.part(lambda d, wx=wx: c.poly(d, [(wx - 15, oy - 84), (wx + 15, oy - 84), (wx + 15, oy - 54), (wx - 15, oy - 54)]), WOOD_DARK, shade_d=1.5, light_d=0)
        c.flat(lambda d, wx=wx: c.poly(d, [(wx - 11, oy - 80), (wx + 11, oy - 80), (wx + 11, oy - 58), (wx - 11, oy - 58)]), PAPER)
        c.glow(lambda d, wx=wx: c.poly(d, [(wx - 11, oy - 80), (wx + 11, oy - 80), (wx + 11, oy - 58), (wx - 11, oy - 58)]), "#ffc04a", radius=5, alpha=110)
        _line(c, [(wx, oy - 80), (wx, oy - 58)], WOOD_DARK.base, 1.3)
        _line(c, [(wx - 11, oy - 69), (wx + 11, oy - 69)], WOOD_DARK.base, 1.3)
    if roof == "thatch":
        _thatch_roof(c, ox, oy)
    else:
        tone = {"tile-gray": ROOFS[0], "tile-red": ROOFS[1], "slate": BASALT, "jade": JADE, "sky": Tone("#4f7fc0", "#2f5490", "#8ab4ec"),
                "void": VOID}[roof]
        _tile_roof(c, ox, oy, tone)
    if snow:
        _snow_cap(c, ox, oy)
    return c, ox, oy


def _snow_cap(c, ox, oy):
    top, bot = oy - 196, oy - 98

    def shape(d):
        pts = [(ox - 74, top - 4), (ox + 74, top - 4), (ox + 92, top + 40)]
        for k in range(13):
            t = k / 12
            x = ox + 104 - 208 * t
            pts.append((x, top + 52 + (8 if k % 2 else 0) + 10 * math.sin(math.pi * t)))
        pts.append((ox - 92, top + 40))
        c.poly(d, pts)
    c.part(shape, SNOW, shade_d=3, light_d=1)
    for x in (ox - 70, ox - 20, ox + 30, ox + 76):
        c.part(lambda d, x=x: c.capsule(d, (x, bot - 2), (x, bot + 10), 3.2, 1.4), Tone("#d8ecff", "#9cc0e2", "#ffffff"), shade_d=1, light_d=0.5)
    c.part(lambda d: c.ribbon(d, bezier((ox - 112, bot + 2), (ox, bot + 14), (ox + 112, bot + 2), n=16), [7] * 17), SNOW, shade_d=1.5, light_d=1)


def _stilts(c, ox, oy):
    """Chân sàn tre trên nước: 6 cột, sàn ván, thang."""
    c.flat(lambda d: c.ellipse(d, ox + 6, oy - 2, 116, 14), "#1f3a3a", alpha=90, blur=3)
    for x in (ox - 92, ox - 46, ox, ox + 46, ox + 92):
        c.part(lambda d, x=x: c.poly(d, [(x - 4, oy - 62), (x + 4, oy - 62), (x + 4, oy - 2), (x - 4, oy - 2)]), WOOD_DARK, shade_d=2, light_d=0.8)
        c.flat(lambda d, x=x: c.ellipse(d, x, oy - 2, 9, 3), "#9fc6c0", alpha=120)
    _line(c, [(ox - 92, oy - 30), (ox + 92, oy - 50)], WOOD_DARK.base, 2.4)
    _line(c, [(ox - 92, oy - 50), (ox + 92, oy - 30)], WOOD_DARK.base, 2.4)
    c.part(lambda d: c.poly(d, [(ox - 104, oy - 70), (ox + 104, oy - 70), (ox + 108, oy - 58), (ox - 108, oy - 58)]), PLANK, shade_d=2, light_d=1)
    for k in range(1, 14):
        _line(c, [(ox - 104 + k * 16, oy - 70), (ox - 104 + k * 16, oy - 58)], PLANK.shade, 1, 160)
    for x in (ox - 26, ox + 26):
        _line(c, [(x, oy - 58), (x + (x - ox) * 0.2, oy)], WOOD.base, 3)
    for k in range(5):
        y = oy - 50 + k * 11
        _line(c, [(ox - 26 - k * 1, y), (ox + 26 + k * 1, y)], WOOD.base, 2.4)


def house_stone(red):
    c, ox, oy = building("plaster", "tile-red" if red else "tile-gray")
    return c.render(outline=OUTLINE, width=2.4), [ox, oy]


def hut_volcano():
    c, ox, oy = building("basalt", "slate")
    return c.render(outline=OUTLINE, width=2.4), [ox, oy]


def cabin_snow(b):
    c, ox, oy = building("logs", "tile-red" if b else "tile-gray", snow=True)
    # khói ống khói
    c.part(lambda d: c.poly(d, [(ox + 40, oy - 210), (ox + 56, oy - 210), (ox + 56, oy - 176), (ox + 40, oy - 176)]), STONE, shade_d=2, light_d=1)
    return c.render(outline=OUTLINE, width=2.4), [ox, oy]


def stilt_house(b):
    raise_y = 60
    c, ox, oy = building("plank", "thatch" if not b else "tile-gray", raise_y=0, h=232)
    house = c.render(outline=OUTLINE, width=2.4)
    base = Canvas(240, 232 + raise_y)
    _stilts(base, 120, 232 + raise_y - 14)
    img = base.render(outline=OUTLINE, width=2.0)
    img.alpha_composite(house.crop((0, 0, 240, 232 - 10)), (0, 0))
    return img, [120, 232 + raise_y - 14]


# ---------------------------------------------------------------- đình / miếu


def pavilion(roof_tone, col_tone, base_tone, crystal=None):
    """Đình mở 4 cột, mái ngói cong, nền bậc đá; crystal = màu tinh thể phát sáng giữa đình."""
    c = Canvas(240, 240)
    ox, oy = 120, 226
    _shadow(c, ox + 8, oy - 2, 112, 16)
    c.part(lambda d: c.poly(d, [(ox - 100, oy - 24), (ox + 100, oy - 24), (ox + 106, oy), (ox - 106, oy)]), base_tone, shade_d=3, light_d=1.4)
    c.part(lambda d: c.poly(d, [(ox - 86, oy - 34), (ox + 86, oy - 34), (ox + 92, oy - 24), (ox - 92, oy - 24)]), base_tone, shade_d=2, light_d=1)
    c.part(lambda d: c.poly(d, [(ox - 30, oy - 6), (ox + 30, oy - 6), (ox + 34, oy + 2), (ox - 34, oy + 2)]), base_tone, shade_d=2, light_d=1)
    if crystal:
        c.glow(lambda d: c.circle(d, ox, oy - 70, 26), crystal, radius=10, alpha=170)
        c.part(lambda d: c.poly(d, [(ox, oy - 104), (ox + 14, oy - 70), (ox, oy - 40), (ox - 14, oy - 70)]), Tone(crystal), shade_d=4, light_d=2)
        c.flat(lambda d: c.poly(d, [(ox - 3, oy - 96), (ox + 4, oy - 74), (ox - 3, oy - 60)]), "#ffffff", alpha=170)
    else:
        c.part(lambda d: c.poly(d, [(ox - 18, oy - 54), (ox + 18, oy - 54), (ox + 14, oy - 34), (ox - 14, oy - 34)]), GOLD, shade_d=2, light_d=1)
    for x in (ox - 82, ox - 34, ox + 34, ox + 82):
        c.part(lambda d, x=x: c.poly(d, [(x - 6, oy - 112), (x + 6, oy - 112), (x + 6, oy - 34), (x - 6, oy - 34)]), col_tone, shade_d=3, light_d=1.2)
        c.part(lambda d, x=x: c.poly(d, [(x - 9, oy - 40), (x + 9, oy - 40), (x + 9, oy - 34), (x - 9, oy - 34)]), GOLD, shade_d=1, light_d=0.6)
    c.part(lambda d: c.poly(d, [(ox - 90, oy - 116), (ox + 90, oy - 116), (ox + 90, oy - 106), (ox - 90, oy - 106)]), col_tone, shade_d=2, light_d=1)
    _line(c, [(ox - 34, oy - 104), (ox + 34, oy - 104)], GOLD.base, 3)
    _tile_roof(c, ox, oy - 12, roof_tone)
    return c.render(outline=OUTLINE, width=2.4), [ox, oy]


def forge_hall():
    """Lò rèn mở: mái đá phiến trên 4 cột, lò lửa + ống khói, đe sắt."""
    c = Canvas(240, 250)
    ox, oy = 120, 236
    _shadow(c, ox + 8, oy - 2, 112, 16)
    c.part(lambda d: c.poly(d, [(ox - 98, oy - 18), (ox + 98, oy - 18), (ox + 102, oy), (ox - 102, oy)]), BASALT, shade_d=3, light_d=1.2)
    # lò + ống khói
    c.part(lambda d: c.poly(d, [(ox + 14, oy - 236), (ox + 40, oy - 236), (ox + 46, oy - 120), (ox + 10, oy - 120)]), BASALT, shade_d=4, light_d=1)
    c.part(lambda d: (c.poly(d, [(ox - 6, oy - 120), (ox + 76, oy - 120), (ox + 80, oy - 18), (ox - 10, oy - 18)])), BASALT, shade_d=5, light_d=1.4)
    c.glow(lambda d: c.ellipse(d, ox + 35, oy - 50, 26, 22), "#ff6a1a", radius=9, alpha=210)
    c.part(lambda d: c.ellipse(d, ox + 35, oy - 50, 22, 18), Tone("#ffb040", "#ff6a1a", "#fff0a0"), shade_d=3, light_d=1)
    for x in (ox - 88, ox - 30, ox + 88):
        c.part(lambda d, x=x: c.poly(d, [(x - 5, oy - 128), (x + 5, oy - 128), (x + 5, oy - 18), (x - 5, oy - 18)]), WOOD_DARK, shade_d=2.5, light_d=1)
    # đe + búa
    c.part(lambda d: (c.poly(d, [(ox - 70, oy - 46), (ox - 30, oy - 46), (ox - 36, oy - 38), (ox - 64, oy - 38)]),
                      c.poly(d, [(ox - 58, oy - 38), (ox - 42, oy - 38), (ox - 40, oy - 18), (ox - 60, oy - 18)])), IRON, shade_d=2, light_d=1)
    _line(c, [(ox - 40, oy - 50), (ox - 24, oy - 66)], WOOD.base, 3)
    _tile_roof(c, ox, oy - 26, BASALT)
    return c.render(outline=OUTLINE, width=2.4), [ox, oy]


def void_shrine():
    return pavilion(VOID, Tone("#3e3650", "#24202f", "#62587a"), Tone("#4a4458", "#2c2838", "#6e6880"), crystal="#b48cff")


# ---------------------------------------------------------------- lều


def tent_canvas(pal):
    """Lều chữ A nhìn 3/4: mái 2 mảng, cửa tam giác tối, dây néo + cọc. pal: canvas / ash / fur / void."""
    tones = {"canvas": Tone("#d8c8a0", "#a8946c", "#f2e6c4"), "ash": Tone("#8a4a3a", "#5a2c22", "#b8705a"),
             "fur": Tone("#9a7650", "#6a4e32", "#c49c70"), "void": Tone("#4c3e78", "#2c2450", "#7c6cb8")}
    tone = tones[pal]
    c = Canvas(224, 168)
    ox, oy = 112, 156
    _shadow(c, ox + 8, oy - 2, 100, 13)
    # dây néo
    for sx in (-1, 1):
        _line(c, [(ox + sx * 60, oy - 92), (ox + sx * 104, oy - 2)], "#6a5a40", 1.4)
        c.part(lambda d, sx=sx: c.poly(d, [(ox + sx * 104 - 2, oy - 8), (ox + sx * 104 + 2, oy - 8), (ox + sx * 104, oy + 2)]), WOOD, shade_d=0)
    # mảng mái trái (tối) + phải (sáng), nóc
    c.part(lambda d: c.poly(d, [(ox - 10, oy - 138), (ox - 92, oy - 6), (ox + 6, oy - 6)]), Tone(tone.shade, None, tone.base), shade_d=2, light_d=1)
    c.part(lambda d: c.poly(d, [(ox - 10, oy - 138), (ox + 30, oy - 138), (ox + 96, oy - 6), (ox + 6, oy - 6)]), tone, shade_d=4, light_d=1.4)
    # cửa
    c.flat(lambda d: c.poly(d, [(ox - 10, oy - 100), (ox - 46, oy - 6), (ox + 4, oy - 6)]), "#2a1e14")
    c.glow(lambda d: c.poly(d, [(ox - 12, oy - 60), (ox - 30, oy - 8), (ox - 2, oy - 8)]), "#ffb04a", radius=5, alpha=90)
    c.part(lambda d: c.poly(d, [(ox - 10, oy - 100), (ox + 4, oy - 6), (ox + 18, oy - 6), (ox + 2, oy - 96)]), tone, shade_d=1.5, light_d=1)
    for k in range(1, 5):
        _line(c, [(ox - 10 + k * 8, oy - 138), (ox + 6 + k * 18, oy - 6)], tone.shade, 1.1, 120)
    if pal == "fur":
        c.part(lambda d: c.poly(d, [(ox - 10, oy - 140), (ox + 30, oy - 140), (ox + 52, oy - 96), (ox + 20, oy - 104), (ox - 30, oy - 100)]), SNOW, shade_d=2, light_d=1)
    if pal == "void":
        _line(c, [(ox - 10, oy - 138), (ox - 92, oy - 6)], "#c8a8ff", 2.2)
        _line(c, [(ox + 30, oy - 138), (ox + 96, oy - 6)], "#c8a8ff", 2.2)
    _line(c, [(ox - 10, oy - 138), (ox - 10, oy - 152)], WOOD_DARK.base, 2.4)
    c.part(lambda d: c.poly(d, [(ox - 10, oy - 152), (ox + 12, oy - 146), (ox - 10, oy - 140)]), Tone("#d8483a") if pal != "void" else Tone("#b48cff"), shade_d=0)
    return c.render(outline=OUTLINE, width=2.2), [ox, oy]


def tent_desert(b):
    """Lều Xích Sa: lều tròn sọc đỏ / kem đỉnh nhọn (b=False) hoặc mái che vải căng trên cột + thảm (b=True)."""
    c = Canvas(224, 184)
    ox, oy = 112, 172
    _shadow(c, ox + 8, oy - 2, 100, 13)
    red = Tone("#c0503a", "#86301f", "#e8806a")
    cream = Tone("#efe0bc", "#c2ae86", "#fff6dc")
    if not b:
        def body(d):
            c.poly(d, [(ox - 92, oy - 6), (ox - 84, oy - 70), (ox, oy - 156), (ox + 84, oy - 70), (ox + 92, oy - 6)])
        m = c.part(body, cream, shade_d=6, light_d=1.4)
        for k in range(-3, 4, 2):
            c.part(lambda d, k=k: c.poly(d, [(ox, oy - 156), (ox + k * 26 - 10, oy - 6), (ox + k * 26 + 12, oy - 6)]), red, clip=m, shade=False)
        c.part(lambda d: c.ribbon(d, bezier((ox - 90, oy - 66), (ox, oy - 52), (ox + 90, oy - 66), n=12), [8] * 13), Tone("#d9b04a"), shade_d=1, light_d=0.6)
        c.flat(lambda d: c.poly(d, [(ox - 16, oy - 60), (ox + 16, oy - 60), (ox + 22, oy - 6), (ox - 22, oy - 6)]), "#2a1a12")
        c.glow(lambda d: c.poly(d, [(ox - 10, oy - 40), (ox + 10, oy - 40), (ox + 14, oy - 8), (ox - 14, oy - 8)]), "#ffb04a", radius=5, alpha=90)
        _line(c, [(ox, oy - 156), (ox, oy - 172)], WOOD_DARK.base, 2.4)
        c.part(lambda d: c.poly(d, [(ox, oy - 172), (ox + 18, oy - 166), (ox, oy - 160)]), red, shade_d=0)
    else:
        c.part(lambda d: c.poly(d, [(ox - 84, oy - 20), (ox + 84, oy - 20), (ox + 92, oy), (ox - 92, oy)]), Tone("#9a3a2e", "#6a2018", "#c8604a"), shade_d=2, light_d=1)
        for k in range(5):
            _line(c, [(ox - 80 + k * 40, oy - 18), (ox - 84 + k * 42, oy - 2)], "#e8c070", 1.6, 180)
        for x in (ox - 80, ox + 80, ox - 70, ox + 70):
            c.part(lambda d, x=x: c.poly(d, [(x - 3, oy - 112), (x + 3, oy - 112), (x + 3, oy - 10), (x - 3, oy - 10)]), WOOD, shade_d=1.5, light_d=0.6)
        def canopy(d):
            pts = [(ox - 96, oy - 112), (ox + 96, oy - 112), (ox + 100, oy - 96)]
            for k in range(9):
                t = k / 8
                pts.append((ox + 100 - 200 * t, oy - 92 + (8 if k % 2 else 0)))
            c.poly(d, pts)
        m = c.part(canopy, cream, shade_d=4, light_d=1.4)
        for k in range(-4, 5, 2):
            c.part(lambda d, k=k: c.poly(d, [(ox + k * 22 - 10, oy - 116), (ox + k * 22 + 10, oy - 116), (ox + k * 22 + 10, oy - 80), (ox + k * 22 - 10, oy - 80)]), red, clip=m, shade=False)
        c.part(lambda d: c.poly(d, [(ox - 90, oy - 150), (ox + 90, oy - 150), (ox + 96, oy - 112), (ox - 96, oy - 112)]), Tone(cream.light, cream.base, None), shade_d=2, light_d=0)
        for k in range(3):
            c.part(lambda d, k=k: c.ellipse(d, ox - 40 + k * 40, oy - 30, 14, 10), CLAY, shade_d=3, light_d=1)
    return c.render(outline=OUTLINE, width=2.2), [ox, oy]


def watchtower():
    """Chòi canh gỗ 4 chân, sàn, lan can, mái tranh nhỏ, thang."""
    c = Canvas(160, 300)
    ox, oy = 80, 288
    _shadow(c, ox + 6, oy - 2, 62, 11)
    for x0, x1 in ((ox - 56, ox - 40), (ox + 56, ox + 40)):
        c.part(lambda d, x0=x0, x1=x1: c.poly(d, [(x0 - 5, oy), (x0 + 5, oy), (x1 + 5, oy - 170), (x1 - 5, oy - 170)]), WOOD, shade_d=2.5, light_d=1)
    _line(c, [(ox - 52, oy - 30), (ox + 46, oy - 120)], WOOD_DARK.base, 3)
    _line(c, [(ox + 52, oy - 30), (ox - 46, oy - 120)], WOOD_DARK.base, 3)
    _line(c, [(ox - 50, oy - 76), (ox + 50, oy - 76)], WOOD_DARK.base, 3)
    for k in range(10):
        y = oy - 14 - k * 15
        _line(c, [(ox - 12, y), (ox + 12, y)], WOOD.light, 2.2)
    _line(c, [(ox - 12, oy), (ox - 12, oy - 168)], WOOD.base, 3)
    _line(c, [(ox + 12, oy), (ox + 12, oy - 168)], WOOD.base, 3)
    c.part(lambda d: c.poly(d, [(ox - 62, oy - 182), (ox + 62, oy - 182), (ox + 62, oy - 168), (ox - 62, oy - 168)]), PLANK, shade_d=2, light_d=1)
    c.part(lambda d: c.poly(d, [(ox - 58, oy - 214), (ox + 58, oy - 214), (ox + 58, oy - 182), (ox - 58, oy - 182)]), PLANK, shade_d=3, light_d=1)
    for k in range(1, 8):
        _line(c, [(ox - 58 + k * 14.5, oy - 212), (ox - 58 + k * 14.5, oy - 184)], PLANK.shade, 1.2, 170)
    for x in (ox - 54, ox + 54):
        _line(c, [(x, oy - 214), (x, oy - 250)], WOOD_DARK.base, 3.4)
    c.part(lambda d: c.poly(d, [(ox - 76, oy - 238), (ox, oy - 290), (ox + 76, oy - 238), (ox + 66, oy - 230), (ox - 66, oy - 230)]), THATCH, shade_d=5, light_d=1.6)
    c.glow(lambda d: c.circle(d, ox + 40, oy - 224, 8), "#ffb04a", radius=6, alpha=140)
    return c.render(outline=OUTLINE, width=2.2), [ox, oy]


def tower_stone():
    """Tháp canh đá Thành Biên Đài: thân tròn đá, lỗ châu mai, mái nón ngói, cờ."""
    c = Canvas(144, 320)
    ox, oy = 72, 308
    _shadow(c, ox + 6, oy - 2, 58, 11)
    c.part(lambda d: (c.ellipse(d, ox, oy - 8, 46, 10), c.poly(d, [(ox - 46, oy - 8), (ox - 40, oy - 200), (ox + 40, oy - 200), (ox + 46, oy - 8)])), STONE, shade_d=8, light_d=1.6)
    for r in range(11):
        y = oy - 20 - r * 17
        _line(c, bezier((ox - 44 + r * 0.5, y), (ox, y + 6), (ox + 44 - r * 0.5, y), n=10), STONE.shade, 1.2, 170)
        for k in range(4):
            x = ox - 34 + k * 22 + (r % 2) * 11
            _line(c, [(x, y - 16), (x, y)], STONE.shade, 1.1, 150)
    c.flat(lambda d: c.poly(d, [(ox - 6, oy - 150), (ox + 6, oy - 150), (ox + 6, oy - 124), (ox - 6, oy - 124)]), "#2a2420")
    c.glow(lambda d: c.poly(d, [(ox - 4, oy - 146), (ox + 4, oy - 146), (ox + 4, oy - 128), (ox - 4, oy - 128)]), "#ffc04a", radius=4, alpha=150)
    c.part(lambda d: c.poly(d, [(ox - 18, oy - 50), (ox + 18, oy - 50), (ox + 18, oy - 8), (ox - 18, oy - 8)]), WOOD_DARK, shade_d=2, light_d=0)
    c.part(lambda d: c.poly(d, [(ox - 52, oy - 214), (ox + 52, oy - 214), (ox + 52, oy - 196), (ox - 52, oy - 196)]), STONE, shade_d=2, light_d=1)
    for k in range(5):
        x = ox - 48 + k * 22
        c.part(lambda d, x=x: c.poly(d, [(x, oy - 228), (x + 12, oy - 228), (x + 12, oy - 212), (x, oy - 212)]), STONE, shade_d=1.5, light_d=1)
    c.part(lambda d: c.poly(d, [(ox - 58, oy - 222), (ox, oy - 292), (ox + 58, oy - 222), (ox + 48, oy - 216), (ox - 48, oy - 216)]), ROOFS[1], shade_d=5, light_d=1.6)
    _line(c, [(ox, oy - 292), (ox, oy - 316)], WOOD_DARK.base, 2.4)
    c.part(lambda d: c.poly(d, [(ox, oy - 316), (ox + 26, oy - 310), (ox + 20, oy - 304), (ox, oy - 302)]), Tone("#3a78c8", "#24508a", "#6aa4ec"), shade_d=0)
    return c.render(outline=OUTLINE, width=2.2), [ox, oy]


# ---------------------------------------------------------------- cọc rào


def post(kind):
    c = Canvas(32, 72)
    ox, oy = 16, 66
    _shadow(c, ox + 2, oy - 1, 10, 3, a=60)
    if kind == "wall-post":
        c.part(lambda d: c.poly(d, [(ox - 9, oy - 44), (ox + 9, oy - 44), (ox + 9, oy - 2), (ox - 9, oy - 2)]), STONE, shade_d=3, light_d=1)
        c.part(lambda d: c.poly(d, [(ox - 11, oy - 50), (ox + 11, oy - 50), (ox + 11, oy - 42), (ox - 11, oy - 42)]), STONE, shade_d=1.5, light_d=1)
        _line(c, [(ox - 9, oy - 22), (ox + 9, oy - 22)], STONE.shade, 1.2, 180)
    elif kind == "stake-post":
        c.part(lambda d: c.poly(d, [(ox - 4, oy - 40), (ox, oy - 52), (ox + 4, oy - 40), (ox + 4, oy - 2), (ox - 4, oy - 2)]), Tone("#c49a68", "#8a6640", "#e6c08c"), shade_d=2, light_d=0.8)
        _line(c, [(ox - 5, oy - 30), (ox + 5, oy - 28)], "#7a5a3a", 1.6)
    elif kind == "bamboo-post":
        bam = Tone("#b8b060", "#7c7a36", "#e2dc8c")
        c.part(lambda d: c.poly(d, [(ox - 4, oy - 48), (ox + 4, oy - 48), (ox + 4, oy - 2), (ox - 4, oy - 2)]), bam, shade_d=2, light_d=0.8)
        for y in (oy - 36, oy - 20):
            _line(c, [(ox - 4, y), (ox + 4, y)], bam.shade, 1.6)
    elif kind == "iron-post":
        c.part(lambda d: c.poly(d, [(ox - 4, oy - 42), (ox, oy - 54), (ox + 4, oy - 42), (ox + 4, oy - 2), (ox - 4, oy - 2)]), IRON, shade_d=2, light_d=0.8)
        c.glow(lambda d: c.circle(d, ox, oy - 50, 3), "#ff7a2a", radius=3, alpha=150)
    elif kind == "fence-post-snow":
        c.part(lambda d: c.poly(d, [(ox - 4, oy - 38), (ox, oy - 46), (ox + 4, oy - 38), (ox + 4, oy - 2), (ox - 4, oy - 2)]), WOOD, shade_d=2, light_d=0.8)
        c.part(lambda d: c.ellipse(d, ox, oy - 42, 6, 4), SNOW, shade_d=1, light_d=0.5)
    elif kind == "marble-post":
        c.part(lambda d: c.poly(d, [(ox - 6, oy - 40), (ox + 6, oy - 40), (ox + 6, oy - 2), (ox - 6, oy - 2)]), MARBLE, shade_d=2.5, light_d=1)
        c.part(lambda d: c.circle(d, ox, oy - 44, 6), MARBLE, shade_d=1.5, light_d=1)
    elif kind == "jade-post":
        c.part(lambda d: c.poly(d, [(ox - 6, oy - 40), (ox + 6, oy - 40), (ox + 6, oy - 2), (ox - 6, oy - 2)]), JADE, shade_d=2.5, light_d=1)
        c.part(lambda d: c.poly(d, [(ox - 8, oy - 42), (ox + 8, oy - 42), (ox, oy - 54)]), GOLD, shade_d=1, light_d=0.8)
    elif kind == "ward-post":
        c.part(lambda d: c.poly(d, [(ox - 7, oy - 30), (ox + 7, oy - 30), (ox + 7, oy - 2), (ox - 7, oy - 2)]), Tone("#3e3650", "#24202f", "#62587a"), shade_d=2, light_d=1)
        c.glow(lambda d: c.circle(d, ox, oy - 40, 8), "#b48cff", radius=5, alpha=180)
        c.part(lambda d: c.poly(d, [(ox, oy - 54), (ox + 6, oy - 40), (ox, oy - 30), (ox - 6, oy - 40)]), Tone("#b48cff", "#7a52d0", "#e8d8ff"), shade_d=1.5, light_d=1)
    return c.render(outline=OUTLINE, width=1.6), [ox, oy]


# ---------------------------------------------------------------- đồ vật


def campfire():
    c = Canvas(112, 128)
    ox, oy = 56, 104
    _shadow(c, ox + 2, oy, 40, 9)
    for k in range(9):
        a = math.tau * k / 9
        c.part(lambda d, a=a: c.ellipse(d, ox + math.cos(a) * 32, oy - 6 + math.sin(a) * 12, 8, 6), STONE, shade_d=2, light_d=1)
    c.part(lambda d: (c.capsule(d, (ox - 24, oy - 2), (ox + 20, oy - 14), 5), c.capsule(d, (ox + 24, oy - 2), (ox - 20, oy - 14), 5)), WOOD, shade_d=2, light_d=1)
    c.glow(lambda d: c.ellipse(d, ox, oy - 30, 26, 30), "#ff8a2a", radius=10, alpha=170)
    c.part(lambda d: c.poly(d, [(ox - 20, oy - 10), (ox - 14, oy - 40), (ox - 4, oy - 30), (ox, oy - 66), (ox + 8, oy - 34), (ox + 16, oy - 46), (ox + 20, oy - 10)]),
           Tone("#ff7a22", "#d84a12", "#ffd060"), shade_d=3, light_d=2)
    c.flat(lambda d: c.poly(d, [(ox - 8, oy - 12), (ox - 2, oy - 36), (ox + 4, oy - 26), (ox + 8, oy - 12)]), "#fff2a0", alpha=230)
    return c.render(outline=OUTLINE, width=2.0), [ox, oy]


def torch_post():
    c = Canvas(56, 168)
    ox, oy = 28, 158
    _shadow(c, ox + 2, oy - 1, 12, 4)
    c.part(lambda d: c.poly(d, [(ox - 4, oy - 104), (ox + 4, oy - 104), (ox + 3, oy - 2), (ox - 3, oy - 2)]), WOOD, shade_d=2, light_d=0.8)
    c.part(lambda d: c.poly(d, [(ox - 8, oy - 110), (ox + 8, oy - 110), (ox + 5, oy - 98), (ox - 5, oy - 98)]), IRON, shade_d=1.5, light_d=0.6)
    c.glow(lambda d: c.ellipse(d, ox, oy - 120, 14, 18), "#ff8a2a", radius=8, alpha=170)
    c.part(lambda d: c.poly(d, [(ox - 8, oy - 110), (ox - 4, oy - 126), (ox, oy - 120), (ox + 2, oy - 138), (ox + 6, oy - 122), (ox + 8, oy - 110)]), Tone("#ff7a22", "#d84a12", "#ffd060"), shade_d=2, light_d=1.5)
    return c.render(outline=OUTLINE, width=1.8), [ox, oy]


def brazier():
    c = Canvas(80, 140)
    ox, oy = 40, 130
    _shadow(c, ox + 2, oy - 1, 22, 5)
    c.part(lambda d: c.poly(d, [(ox - 10, oy - 50), (ox + 10, oy - 50), (ox + 14, oy - 2), (ox - 14, oy - 2)]), BASALT, shade_d=2.5, light_d=1)
    c.part(lambda d: (c.ellipse(d, ox, oy - 54, 26, 9), c.poly(d, [(ox - 26, oy - 54), (ox + 26, oy - 54), (ox + 16, oy - 66), (ox - 16, oy - 66)])), IRON, shade_d=2, light_d=1)
    c.glow(lambda d: c.ellipse(d, ox, oy - 80, 22, 24), "#ff7a1a", radius=9, alpha=180)
    c.part(lambda d: c.poly(d, [(ox - 18, oy - 62), (ox - 10, oy - 84), (ox - 2, oy - 76), (ox + 2, oy - 104), (ox + 10, oy - 80), (ox + 18, oy - 62)]), Tone("#ff7a22", "#d84a12", "#ffd060"), shade_d=2.5, light_d=1.5)
    return c.render(outline=OUTLINE, width=1.8), [ox, oy]


def jars():
    c = Canvas(112, 88)
    ox, oy = 56, 80
    _shadow(c, ox + 3, oy - 1, 44, 7)
    for x, y, s in ((-24, -2, 1.0), (16, -4, 1.2), (-2, 2, 0.8)):
        c.part(lambda d, x=x, y=y, s=s: (c.ellipse(d, ox + x, oy + y - 20 * s, 16 * s, 20 * s), c.poly(d, [(ox + x - 7 * s, oy + y - 46 * s), (ox + x + 7 * s, oy + y - 46 * s), (ox + x + 9 * s, oy + y - 36 * s), (ox + x - 9 * s, oy + y - 36 * s)])),
               CLAY, shade_d=4, light_d=1.4)
        _line(c, [(ox + x - 14 * s, oy + y - 24 * s), (ox + x + 14 * s, oy + y - 24 * s)], "#e8c070", 1.6, 200)
    return c.render(outline=OUTLINE, width=1.8), [ox, oy]


def net_rack():
    c = Canvas(160, 128)
    ox, oy = 80, 118
    _shadow(c, ox + 4, oy - 1, 62, 8)
    for x in (ox - 56, ox + 56):
        c.part(lambda d, x=x: c.poly(d, [(x - 3, oy - 96), (x + 3, oy - 96), (x + 3, oy - 2), (x - 3, oy - 2)]), Tone("#b8b060", "#7c7a36", "#e2dc8c"), shade_d=1.5, light_d=0.6)
    _line(c, [(ox - 60, oy - 92), (ox + 60, oy - 92)], "#7c7a36", 3)

    def net(d):
        s = c.ss
        for k in range(12):
            x = ox - 52 + k * 9.5
            d.line([(x * s, (oy - 90) * s), ((x + 4) * s, (oy - 30 - 8 * math.sin(k / 11 * math.pi)) * s)], fill=255, width=int(0.9 * s))
        for r in range(6):
            y = oy - 84 + r * 10
            d.line([((ox - 52) * s, y * s), ((ox + 54) * s, (y + 4 * math.sin(r)) * s)], fill=255, width=int(0.9 * s))
    c.flat(net, "#5a5a4a", alpha=200)
    for k, x in enumerate((ox - 30, ox - 6, ox + 22)):
        c.part(lambda d, x=x: c.ellipse(d, x, oy - 52, 5, 13), Tone("#9ab0c0", "#6a8090", "#d0e0ea"), shade_d=1.5, light_d=1)
    return c.render(outline=OUTLINE, width=1.8), [ox, oy]


def boat():
    c = Canvas(176, 72)
    ox, oy = 88, 60
    c.flat(lambda d: c.ellipse(d, ox + 4, oy, 80, 9), "#1f3a3a", alpha=90, blur=2)
    c.part(lambda d: c.poly(d, [(ox - 82, oy - 30), (ox + 82, oy - 30), (ox + 62, oy - 4), (ox - 62, oy - 4)]), WOOD, shade_d=3, light_d=1.2)
    c.flat(lambda d: c.poly(d, [(ox - 72, oy - 30), (ox + 72, oy - 30), (ox + 60, oy - 22), (ox - 60, oy - 22)]), "#4a3020")
    for x in (ox - 30, ox + 20):
        _line(c, [(x, oy - 30), (x, oy - 22)], PLANK.base, 4)
    _line(c, [(ox - 40, oy - 24), (ox + 70, oy - 54)], WOOD_DARK.base, 2.4)
    return c.render(outline=OUTLINE, width=1.8), [ox, oy]


def ore_cart():
    c = Canvas(128, 96)
    ox, oy = 64, 86
    _shadow(c, ox + 3, oy - 1, 50, 7)
    c.part(lambda d: c.poly(d, [(ox - 46, oy - 52), (ox + 46, oy - 52), (ox + 38, oy - 16), (ox - 38, oy - 16)]), WOOD_DARK, shade_d=3, light_d=1)
    for k in range(-2, 3):
        c.part(lambda d, k=k: c.circle(d, ox + k * 16, oy - 56, 10), BASALT, shade_d=2, light_d=1)
    for k in (-1, 1):
        c.glow(lambda d, k=k: c.circle(d, ox + k * 18, oy - 60, 4), "#ff8a2a", radius=3, alpha=170)
    for x in (ox - 26, ox + 26):
        c.part(lambda d, x=x: c.circle(d, x, oy - 12, 11), IRON, shade_d=2, light_d=1)
    return c.render(outline=OUTLINE, width=1.8), [ox, oy]


def woodpile():
    c = Canvas(128, 88)
    ox, oy = 64, 80
    _shadow(c, ox + 3, oy - 1, 52, 7)
    for r, n in ((0, 5), (1, 4), (2, 3)):
        for k in range(n):
            x = ox - (n - 1) * 11 + k * 22
            y = oy - 10 - r * 18
            c.part(lambda d, x=x, y=y: c.circle(d, x, y, 10), LOGS, shade_d=2, light_d=1)
            c.flat(lambda d, x=x, y=y: c.circle(d, x, y, 6), "#d8a878")
            c.flat(lambda d, x=x, y=y: c.circle(d, x, y, 2.5), "#a87848")
    c.part(lambda d: c.ellipse(d, ox, oy - 54, 28, 7), SNOW, shade_d=1, light_d=0.5)
    return c.render(outline=OUTLINE, width=1.8), [ox, oy]


def sled():
    c = Canvas(144, 72)
    ox, oy = 72, 64
    _shadow(c, ox + 3, oy - 1, 58, 6)
    _line(c, [(ox - 60, oy - 6), (ox + 52, oy - 6)], IRON.base, 3)
    c.flat(lambda d: d.arc([(ox + 40) * c.ss, (oy - 26) * c.ss, (ox + 68) * c.ss, (oy - 2) * c.ss], 270, 90, fill=255, width=3 * c.ss), IRON.base)
    for x in (ox - 44, ox, ox + 40):
        _line(c, [(x, oy - 6), (x, oy - 18)], WOOD_DARK.base, 3)
    c.part(lambda d: c.poly(d, [(ox - 58, oy - 26), (ox + 50, oy - 26), (ox + 50, oy - 16), (ox - 58, oy - 16)]), PLANK, shade_d=2, light_d=1)
    c.part(lambda d: (c.ellipse(d, ox - 20, oy - 36, 22, 12), c.ellipse(d, ox + 16, oy - 34, 18, 10)), Tone("#8a6a4a", "#5a4430", "#b89470"), shade_d=2, light_d=1)
    return c.render(outline=OUTLINE, width=1.8), [ox, oy]


def incense_burner():
    c = Canvas(96, 144)
    ox, oy = 48, 134
    _shadow(c, ox + 3, oy - 1, 34, 7)
    c.part(lambda d: c.poly(d, [(ox - 30, oy - 12), (ox + 30, oy - 12), (ox + 34, oy), (ox - 34, oy)]), MARBLE, shade_d=2, light_d=1)
    for x in (ox - 22, ox + 22):
        _line(c, [(x, oy - 12), (x - (x - ox) * 0.2, oy - 34)], GOLD.shade, 4)
    c.part(lambda d: (c.ellipse(d, ox, oy - 46, 32, 18), c.ellipse(d, ox, oy - 62, 30, 7)), Tone("#b08a3a", "#7a5a20", "#e2c070"), shade_d=4, light_d=1.4)
    for sx in (-1, 1):
        c.part(lambda d, sx=sx: c.ellipse(d, ox + sx * 32, oy - 62, 6, 8), GOLD, shade_d=1, light_d=0.6)
    for k, x in enumerate((ox - 8, ox, ox + 8)):
        _line(c, [(x, oy - 62), (x, oy - 84)], "#8a3a2a", 1.6)
        c.glow(lambda d, x=x: c.circle(d, x, oy - 85, 2), "#ff8a3a", radius=2, alpha=200)

    def smoke(d):
        s = c.ss
        pts = bezier((ox, oy - 88), (ox - 14, oy - 106), (ox + 12, oy - 124), (ox - 4, oy - 142), n=20)
        d.line([(x * s, y * s) for x, y in pts], fill=255, width=int(3 * s), joint="curve")
    c.flat(smoke, "#f0f0f6", alpha=110, blur=1.2)
    return c.render(outline=OUTLINE, width=1.8), [ox, oy]


# ---------------------------------------------------------------- nền


def mud():
    return _tile(256, "#5f5a40", [("#57523a", 14, 16, 38, 60), ("#6a6448", 12, 12, 30, 55), ("#4a5440", 6, 14, 30, 50)],
                 [("#3f3c2a", 50, 4, 120), ("#8a8460", 30, 3, 110)], seed=51)


def boardwalk():
    W, ss = 256, 2
    img = Image.new("RGBA", (W * ss, W * ss), hexc("#3e2e1e"))
    d = ImageDraw.Draw(img)
    rnd = random.Random(52)
    for r in range(16):
        y0 = r * 16
        col = rnd.choice(["#9a6e46", "#8c6440", "#a87a50", "#94683f"])
        d.rectangle([0, (y0 + 1) * ss, W * ss, (y0 + 15) * ss], fill=hexc(col))
        d.line([0, (y0 + 2) * ss, W * ss, (y0 + 2) * ss], fill=hexc("#c49a6a", 120), width=ss)
        for _ in range(3):
            x = rnd.uniform(0, W)
            d.line([x * ss, (y0 + 1) * ss, x * ss, (y0 + 15) * ss], fill=hexc("#3e2e1e"), width=2 * ss)
        for _ in range(4):
            x = rnd.uniform(0, W)
            d.ellipse([(x - 1.5) * ss, (y0 + 7) * ss, (x + 1.5) * ss, (y0 + 9) * ss], fill=hexc("#5a4030"))
    img = img.filter(ImageFilter.GaussianBlur(0.5 * ss))
    return img.resize((W, W), Image.LANCZOS)


def marble_dark():
    from env_village import plaza
    img = plaza()
    px = img.load()
    for y in range(img.size[1]):
        for x in range(img.size[0]):
            r, g, b, a = px[x, y]
            lum = (r + g + b) / 3
            px[x, y] = (int(lum * 0.45 + 18), int(lum * 0.38 + 12), int(lum * 0.6 + 34), a)
    return img


def build():
    """{id: (Image, origin)}"""
    out = {
        "house-stone": house_stone(True), "house-stone-b": house_stone(False), "tower": tower_stone(),
        "watchtower": watchtower(), "tent-canvas": tent_canvas("canvas"), "tent-ash": tent_canvas("ash"),
        "tent-fur": tent_canvas("fur"), "tent-void": tent_canvas("void"), "tent": tent_desert(False), "tent-desert-b": tent_desert(True),
        "stilt-house": stilt_house(False), "stilt-house-b": stilt_house(True), "hut-volcano": hut_volcano(), "forge-hall": forge_hall(),
        "cabin-snow": cabin_snow(False), "cabin-snow-b": cabin_snow(True),
        "pavilion-sky": pavilion(Tone("#4f7fc0", "#2f5490", "#8ab4ec"), MARBLE, MARBLE),
        "pavilion-jade": pavilion(JADE, MARBLE, MARBLE), "pavilion-jade-b": pavilion(GOLD, Tone("#c84a3a", "#8a2a20", "#ec7a64"), MARBLE),
        "void-shrine": void_shrine(),
        "campfire": campfire(), "torch-post": torch_post(), "brazier": brazier(), "jars": jars(), "net-rack": net_rack(), "boat": boat(),
        "ore-cart": ore_cart(), "woodpile": woodpile(), "sled": sled(), "incense-burner": incense_burner(),
        "tile-mud": (mud(), [0, 0]), "tile-boardwalk": (boardwalk(), [0, 0]), "tile-marble-dark": (marble_dark(), [0, 0]),
    }
    for k in ("wall-post", "stake-post", "bamboo-post", "iron-post", "fence-post-snow", "marble-post", "jade-post", "ward-post"):
        out[k] = post(k)
    return out


if __name__ == "__main__":
    import os
    res = build()
    keys = [k for k in res if not k.startswith("tile-")]
    W = 1800
    prev = Image.new("RGBA", (W, 1100), hexc("#6a8a5a"))
    x, y, rowh = 10, 10, 0
    for k in keys:
        im, o = res[k]
        if x + im.size[0] > W:
            x, y, rowh = 10, y + rowh + 10, 0
        prev.alpha_composite(im, (x, y))
        x += im.size[0] + 6
        rowh = max(rowh, im.size[1])
    for i, k in enumerate(["tile-mud", "tile-boardwalk", "tile-marble-dark"]):
        prev.alpha_composite(res[k][0], (W - 800 + i * 264, 1100 - 260))
    out = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "_preview", "hd-camps.png")
    prev.save(out)
    print("ok", out)
