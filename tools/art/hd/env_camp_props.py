"""GN-1 E2 (docs/45) + GN-2 (vùng 2–9): bộ cảnh "trại / bãi chiến" — hàng rào / tường đổ (đoạn), cờ, giá vũ khí,
đồ vương vãi (xương, vũ khí gãy, khúc gỗ, đá vụn). Cùng phong cách cel-shade env_village / env_camps. Gốc mọi hình = giữa chân.

Tỷ lệ so với nhân vật (cao ≈ 64 px thế giới = 128 px ảnh, ảnh / 2 = thế giới) theo C4:
hàng rào cọc ≈ 1,8× người, cờ ≈ 2×, giá vũ khí ≈ 1,1×, đồ vương vãi sát đất.
GN-2: mỗi vùng 1 bộ theo chất liệu vùng — rào / tường (gỗ, tre, gỗ phủ tuyết, sa thạch, bazan nứt dung nham, đá cẩm thạch,
hắc diện thạch tím, cẩm thạch gờ ngọc), cờ màu + biểu tượng vùng, đá vụn theo chất liệu.
"""
import math
import random

from env_village import OUTLINE, STONE, WOOD, WOOD_DARK, _line, _shadow
from vec import Canvas, Tone

BONE = Tone("#e6dcc4", "#a89c80", "#fffaec")
IRON = Tone("#7a7a84", "#4a4a52", "#b4b4be")
RUST = Tone("#8a5a3a", "#5a3620", "#b07c52")
CLOTH_RED = Tone("#a83a2c", "#6e2018", "#d8644a")
ROPE = "#c8a870"
SNOW = Tone("#f2f6fb", "#c4d2e2", "#ffffff")
BAMBOO = Tone("#b8b060", "#7c7a36", "#e2dc8c")
WOOD_B = Tone("#7e5232", "#563620", "#a87a50")
SANDSTONE = Tone("#d4a86a", "#9a7040", "#f0cc94")
BASALT = Tone("#4a4448", "#2c282c", "#6e676c")
MARBLE = Tone("#ece6da", "#bdb4a4", "#ffffff")
OBSIDIAN = Tone("#3e3156", "#221a34", "#7a64a8")
JADE = Tone("#6fc4a0", "#3f8a6e", "#a8ecc8")
GOLD = Tone("#d9b04a", "#9a7428", "#f6dc8a")


def palisade(a=None, b=None, snow=False, bamboo=False):
    """Đoạn hàng rào 5 cọc vót nhọn, 2 đai dây, cọc chống phía trước. Rộng 112 px ảnh = 56 px thế giới.
    a / b = 2 tông gỗ xen kẽ; snow = phủ tuyết đầu cọc + chân; bamboo = cọc tre có đốt (vùng 4)."""
    a = a or (BAMBOO if bamboo else WOOD)
    b = b or (Tone("#a39a4e", "#6c6a2e", "#d0ca7c") if bamboo else WOOD_B)
    c = Canvas(128, 240)
    ox, oy = 64, 230
    _shadow(c, ox + 6, oy - 2, 60, 9)
    rnd = random.Random(7)
    xs = [-44, -22, 0, 22, 44]
    for i, dx in enumerate(xs):
        top = 200 + rnd.uniform(-14, 10)
        x = ox + dx
        r = 11.5
        c.part(lambda d, x=x, top=top: c.poly(d, [(x - r, oy - 2), (x - r, oy - top + 18), (x, oy - top), (x + r, oy - top + 18), (x + r, oy - 2)]),
               a if i % 2 == 0 else b, shade_d=3.5, light_d=1.4)
        if bamboo:
            for yy in range(int(oy - 40), int(oy - top + 30), -38):
                _line(c, [(x - r, yy), (x + r, yy - 1)], a.shade, 2.2)
        else:
            # vân gỗ + đầu vót sáng
            _line(c, [(x - 3, oy - 20), (x - 2, oy - top + 30)], WOOD_DARK.base, 1.2, 140)
            c.flat(lambda d, x=x, top=top: c.poly(d, [(x - 4, oy - top + 14), (x, oy - top + 2), (x + 2, oy - top + 14)]), "#d8b088", alpha=170)
        if snow:
            c.part(lambda d, x=x, top=top: c.poly(d, [(x - r - 2, oy - top + 22), (x, oy - top + 3), (x + r + 2, oy - top + 22), (x + r, oy - top + 28), (x - r, oy - top + 28)]),
                   SNOW, shade_d=1.5, light_d=0.8)
    for y in (oy - 64, oy - 150):
        _line(c, [(ox - 58, y + 3), (ox + 58, y - 3)], "#4a3220", 5.0)
        _line(c, [(ox - 58, y + 2), (ox + 58, y - 4)], ROPE, 2.6)
    if snow:
        c.part(lambda d: c.ellipse(d, ox, oy - 4, 62, 8), SNOW, shade_d=1.5, light_d=0.6)
    # cọc chống chéo phía trước
    c.part(lambda d: c.capsule(d, (ox + 30, oy - 2), (ox + 12, oy - 112), 4.5), WOOD_DARK, shade_d=1.5, light_d=0.6)
    return c.render(outline=OUTLINE, width=2.2), [ox, oy]


def stone_wall(tone, mortar, cap=None, crack=None, gem=None, shards=False, seed=3):
    """Đoạn tường đổ (khối xếp, mép trên vỡ lởm chởm). cap = tông gờ đá còn sót; crack = màu vết nứt phát sáng;
    gem = màu ngọc khảm; shards = tường mảnh tinh thể nhọn (Hư Vô)."""
    c = Canvas(136, 236)
    ox, oy = 68, 226
    _shadow(c, ox + 6, oy - 2, 64, 9)
    rnd = random.Random(seed)
    if shards:
        if crack:
            c.glow(lambda d: c.ellipse(d, ox, oy - 90, 52, 70), crack, radius=12, alpha=90)
        for dx in (-46, -24, -2, 20, 44):
            h = rnd.uniform(130, 205)
            w = rnd.uniform(10, 15)
            lean = rnd.uniform(-8, 8)
            x = ox + dx
            c.part(lambda d, x=x, h=h, w=w, lean=lean: c.poly(d, [(x - w, oy - 2), (x - w * 0.6 + lean, oy - h + 30), (x + lean, oy - h),
                                                                   (x + w * 0.7 + lean, oy - h + 24), (x + w, oy - 2)]), tone, shade_d=4, light_d=1.6)
            _line(c, [(x + lean * 0.3, oy - 12), (x + lean, oy - h + 14)], tone.light, 1.4, 160)
        return c.render(outline=OUTLINE, width=2.2), [ox, oy]
    top = [(ox - 60, oy - rnd.uniform(110, 140))]
    for k in range(1, 8):
        top.append((ox - 60 + k * 15, oy - rnd.uniform(140, 200) + k * 7))
    top.append((ox + 60, oy - rnd.uniform(80, 110)))
    body = [(ox - 60, oy - 2)] + top + [(ox + 60, oy - 2)]
    m = c.part(lambda d: c.poly(d, body), tone, shade_d=5, light_d=1.8)
    # mạch vữa: hàng khối so le, chỉ trong thân tường
    from PIL import ImageDraw, ImageChops
    lines = c.mask()
    dl = ImageDraw.Draw(lines)
    s = c.ss
    for row in range(10):
        y = oy - 20 - row * 20
        dl.line([((ox - 60) * s, y * s), ((ox + 60) * s, y * s)], fill=255, width=int(1.4 * s))
        for k in range(6):
            x = ox - 60 + k * 26 + (row % 2) * 13
            dl.line([(x * s, y * s), (x * s, (y + 20) * s)], fill=255, width=int(1.2 * s))
    lines = ImageChops.multiply(lines, m)
    c._paint(lines.point(lambda v: v * 160 // 255), Tone(mortar).base)
    if cap is not None:
        c.part(lambda d: c.poly(d, [(ox - 64, oy - 112), (ox - 14, oy - 124), (ox - 12, oy - 112), (ox - 62, oy - 101)]), cap, shade_d=2, light_d=1)
    if crack:
        for pts, wd in (([(ox - 30, oy - 4), (ox - 22, oy - 40), (ox - 30, oy - 70), (ox - 14, oy - 110)], 6),
                        ([(ox + 26, oy - 6), (ox + 34, oy - 46), (ox + 22, oy - 80)], 5)):
            c.glow(lambda d, pts=pts, wd=wd: d.line([c.p(*q) for q in pts], fill=255, width=int(wd * c.ss)), crack, radius=5, alpha=170)
            _line(c, pts, "#ffd27a", 1.8)
    if gem:
        c.glow(lambda d: c.circle(d, ox - 4, oy - 80, 11), gem, radius=6, alpha=150)
        c.part(lambda d: c.poly(d, [(ox - 4, oy - 93), (ox + 6, oy - 80), (ox - 4, oy - 67), (ox - 14, oy - 80)]), Tone(gem), shade_d=1.5, light_d=1)
        _line(c, [(ox - 18, oy - 80), (ox - 14, oy - 80)], GOLD.base, 2.0)
        _line(c, [(ox + 6, oy - 80), (ox + 10, oy - 80)], GOLD.base, 2.0)
    for dx, r in ((-48, 10), (52, 8), (36, 6)):
        c.part(lambda d, dx=dx, r=r: c.ellipse(d, ox + dx, oy - 4, r, r * 0.65), tone, shade_d=2, light_d=1)
    return c.render(outline=OUTLINE, width=2.2), [ox, oy]


def _emblem(c, kind, cx, cy, col, dark):
    if kind == "wolf":
        c.flat(lambda d: c.poly(d, [(cx - 12, cy - 12), (cx - 6, cy - 4), (cx + 6, cy - 4), (cx + 12, cy - 12), (cx + 10, cy + 4),
                                    (cx, cy + 16), (cx - 10, cy + 4)]), col, alpha=235)
        c.flat(lambda d: (c.circle(d, cx - 4, cy + 2, 2), c.circle(d, cx + 4, cy + 2, 2)), dark)
    elif kind == "wind":
        for k in range(3):
            _line(c, [(cx - 12, cy - 8 + k * 9), (cx - 2, cy - 12 + k * 9), (cx + 8, cy - 6 + k * 9), (cx + 12, cy - 10 + k * 9)], col, 2.4)
    elif kind == "sun":
        c.flat(lambda d: c.circle(d, cx, cy, 7), col)
        for k in range(8):
            a = math.tau * k / 8
            _line(c, [(cx + math.cos(a) * 10, cy + math.sin(a) * 10), (cx + math.cos(a) * 15, cy + math.sin(a) * 15)], col, 2.2)
    elif kind == "leaf":
        c.flat(lambda d: c.poly(d, [(cx, cy - 15), (cx + 10, cy - 2), (cx, cy + 14), (cx - 10, cy - 2)]), col)
        _line(c, [(cx, cy - 12), (cx, cy + 12)], dark, 1.4)
    elif kind == "flame":
        c.flat(lambda d: c.poly(d, [(cx - 9, cy + 12), (cx - 10, cy), (cx - 4, cy - 6), (cx - 2, cy - 16), (cx + 5, cy - 6), (cx + 10, cy - 2), (cx + 9, cy + 12)]), col)
        c.flat(lambda d: c.poly(d, [(cx - 4, cy + 10), (cx, cy - 2), (cx + 4, cy + 10)]), dark, alpha=200)
    elif kind == "snow":
        for k in range(3):
            a = math.pi * k / 3
            _line(c, [(cx - math.cos(a) * 13, cy - math.sin(a) * 13), (cx + math.cos(a) * 13, cy + math.sin(a) * 13)], col, 2.4)
    elif kind == "cloud":
        c.flat(lambda d: (c.circle(d, cx - 6, cy + 2, 6), c.circle(d, cx + 2, cy - 3, 8), c.circle(d, cx + 9, cy + 3, 5), c.ellipse(d, cx, cy + 5, 13, 5)), col)
    elif kind == "eye":
        c.flat(lambda d: c.poly(d, [(cx - 14, cy), (cx, cy - 9), (cx + 14, cy), (cx, cy + 9)]), col)
        c.flat(lambda d: c.circle(d, cx, cy, 4), dark)
    else:  # lotus
        for a in (-0.7, 0.0, 0.7):
            c.flat(lambda d, a=a: c.ellipse(d, cx + math.sin(a) * 7, cy - math.cos(a) * 5, 4.5, 10, rot=a), col)
        _line(c, [(cx - 12, cy + 9), (cx + 12, cy + 9)], col, 2.2)


def banner(cloth=CLOTH_RED, emblem="#e8c060", kind="wolf", pole=None):
    """Cột cờ + cờ dài đuôi én có biểu tượng vùng (wolf / wind / sun / leaf / flame / snow / cloud / eye / lotus), chân chèn đá."""
    pole = pole or WOOD_DARK
    c = Canvas(96, 272)
    ox, oy = 40, 262
    _shadow(c, ox + 6, oy - 2, 24, 6)
    c.part(lambda d: c.poly(d, [(ox - 4, oy - 250), (ox + 4, oy - 250), (ox + 5, oy - 4), (ox - 5, oy - 4)]), pole, shade_d=2, light_d=0.8)
    c.part(lambda d: c.capsule(d, (ox - 6, oy - 236), (ox + 44, oy - 236), 3.5), pole, shade_d=1, light_d=0.6)
    c.part(lambda d: c.circle(d, ox, oy - 254, 6), GOLD, shade_d=1.5, light_d=1)
    # cờ rủ, mép dưới xẻ đuôi én, gợn nhẹ
    pts_l = [(ox + 4, oy - 234), (ox + 2, oy - 180), (ox + 6, oy - 120), (ox + 4, oy - 96)]
    pts_r = [(ox + 42, oy - 234), (ox + 46, oy - 180), (ox + 42, oy - 120), (ox + 46, oy - 96)]
    c.part(lambda d: c.poly(d, pts_l + [(ox + 24, oy - 112)] + pts_r[::-1]), cloth, shade_d=4, light_d=1.4)
    for k in range(3):
        y = oy - 216 + k * 40
        _line(c, [(ox + 8, y), (ox + 40, y + 4)], cloth.shade, 1.4, 120)
    _emblem(c, kind, ox + 24, oy - 186, emblem, cloth.shade)
    _line(c, [(ox + 6, oy - 234), (ox + 42, oy - 234)], emblem, 2.4)
    for dx, r in ((-10, 9), (8, 8), (0, 6)):
        c.part(lambda d, dx=dx, r=r: c.ellipse(d, ox + dx, oy - 4, r, r * 0.6), STONE, shade_d=2, light_d=1)
    return c.render(outline=OUTLINE, width=2.0), [ox, oy]


def weapon_rack():
    """Giá vũ khí chữ A: 2 giáo, 1 kiếm, 1 rìu dựng nghiêng, khiên tròn tựa chân."""
    c = Canvas(160, 160)
    ox, oy = 80, 150
    _shadow(c, ox + 6, oy - 2, 66, 9)
    for x0, x1 in ((ox - 60, ox - 50), (ox + 60, ox + 50)):
        c.part(lambda d, x0=x0, x1=x1: c.poly(d, [(x0 - 4, oy - 2), (x0 + 4, oy - 2), (x1 + 4, oy - 96), (x1 - 4, oy - 96)]), WOOD, shade_d=2, light_d=0.8)
    c.part(lambda d: c.capsule(d, (ox - 60, oy - 94), (ox + 60, oy - 94), 4.5), WOOD_DARK, shade_d=1.5, light_d=0.8)
    c.part(lambda d: c.capsule(d, (ox - 56, oy - 30), (ox + 56, oy - 30), 3.5), WOOD_DARK, shade_d=1.2, light_d=0.6)
    # giáo
    for x, lean in ((ox - 36, -6), (ox + 34, 8)):
        _line(c, [(x, oy - 8), (x + lean, oy - 128)], "#6a4428", 3.4)
        c.part(lambda d, x=x, lean=lean: c.poly(d, [(x + lean - 5, oy - 126), (x + lean, oy - 148), (x + lean + 5, oy - 126), (x + lean, oy - 120)]), IRON, shade_d=1.5, light_d=1)
    # kiếm
    c.part(lambda d: c.poly(d, [(ox - 12, oy - 18), (ox - 6, oy - 18), (ox - 4, oy - 116), (ox - 9, oy - 126), (ox - 14, oy - 116)]), IRON, shade_d=1.5, light_d=1.2)
    c.part(lambda d: c.capsule(d, (ox - 20, oy - 16), (ox + 2, oy - 16), 2.6), GOLD, shade_d=0.8, light_d=0.5)
    # rìu
    _line(c, [(ox + 14, oy - 8), (ox + 20, oy - 108)], "#6a4428", 3.6)
    c.part(lambda d: c.poly(d, [(ox + 20, oy - 104), (ox + 40, oy - 116), (ox + 42, oy - 92), (ox + 20, oy - 92)]), IRON, shade_d=2, light_d=1)
    # khiên tròn tựa chân phải
    c.part(lambda d: c.ellipse(d, ox + 52, oy - 22, 20, 22), Tone("#8a5a36", "#5e3a20", "#b58358"), shade_d=3, light_d=1.2)
    c.part(lambda d: c.circle(d, ox + 52, oy - 22, 6), IRON, shade_d=1, light_d=0.8)
    _line(c, [(ox + 33, oy - 22), (ox + 71, oy - 22)], "#3d3d44", 2.2)
    return c.render(outline=OUTLINE, width=2.0), [ox, oy]


def debris(kind):
    """Đồ vương vãi sát đất (vẽ cùng lớp nền): 0 = xương + sọ, 1 = kiếm gãy + khiên vỡ + mũi tên, 2 = khúc gỗ + cành."""
    c = Canvas(144, 72)
    ox, oy = 72, 44
    rnd = random.Random(31 + kind)
    if kind == 0:
        for _ in range(5):
            x, y = ox + rnd.uniform(-52, 52), oy + rnd.uniform(-14, 16)
            a = rnd.uniform(0, math.pi)
            L = rnd.uniform(14, 24)
            p0 = (x - math.cos(a) * L / 2, y - math.sin(a) * L / 4)
            p1 = (x + math.cos(a) * L / 2, y + math.sin(a) * L / 4)
            c.part(lambda d, p0=p0, p1=p1: (c.capsule(d, p0, p1, 2.6), c.circle(d, p0[0], p0[1], 4), c.circle(d, p1[0], p1[1], 4)), BONE, shade_d=1.2, light_d=0.6)
        sx, sy = ox + 14, oy - 6
        c.part(lambda d: (c.ellipse(d, sx, sy, 12, 10), c.poly(d, [(sx - 7, sy + 4), (sx + 7, sy + 4), (sx + 5, sy + 13), (sx - 5, sy + 13)])), BONE, shade_d=2, light_d=1)
        c.flat(lambda d: (c.circle(d, sx - 4, sy + 1, 3), c.circle(d, sx + 4, sy + 1, 3)), "#2a2018")
    elif kind == 1:
        # kiếm gãy nằm chéo
        c.part(lambda d: c.poly(d, [(ox - 50, oy + 8), (ox - 4, oy - 6), (ox - 2, oy - 1), (ox - 48, oy + 13)]), IRON, shade_d=1, light_d=0.8)
        c.part(lambda d: c.capsule(d, (ox - 56, oy + 2), (ox - 48, oy + 20), 2.4), GOLD, shade_d=0.6, light_d=0.4)
        _line(c, [(ox - 58, oy + 12), (ox - 70, oy + 15)], "#5a3a22", 3.4)
        # khiên vỡ nằm nghiêng
        c.part(lambda d: c.poly(d, [(ox + 10, oy - 14), (ox + 46, oy - 18), (ox + 54, oy + 4), (ox + 38, oy + 14), (ox + 30, oy + 2), (ox + 12, oy + 10)]), RUST, shade_d=2, light_d=1)
        c.part(lambda d: c.ellipse(d, ox + 34, oy - 2, 6, 4), IRON, shade_d=0.8, light_d=0.6)
        # 2 mũi tên cắm đất
        for x, y in ((ox - 16, oy + 18), (ox + 2, oy + 22)):
            _line(c, [(x, y), (x + 8, y - 22)], "#7a5a36", 2.0)
            c.flat(lambda d, x=x, y=y: c.poly(d, [(x + 6, y - 22), (x + 12, y - 28), (x + 10, y - 18)]), "#e8e0d0")
    else:
        for (x0, y0, x1, y1, r) in ((-56, 6, 6, -10, 8), (-20, 16, 44, 4, 7)):
            c.part(lambda d, x0=x0, y0=y0, x1=x1, y1=y1, r=r: c.capsule(d, (ox + x0, oy + y0), (ox + x1, oy + y1), r), WOOD, shade_d=2.5, light_d=1)
            c.part(lambda d, x1=x1, y1=y1, r=r: c.ellipse(d, ox + x1, oy + y1, r * 0.7, r), Tone("#d8b088", "#a8804e", "#f0d0a8"), shade_d=1, light_d=0.4)
        for _ in range(4):
            x, y = ox + rnd.uniform(-60, 60), oy + rnd.uniform(-16, 20)
            a = rnd.uniform(-0.6, 0.6)
            _line(c, [(x, y), (x + math.cos(a) * 18, y + math.sin(a) * 8)], WOOD_DARK.base, 2.0)
        c.part(lambda d: c.ellipse(d, ox + 52, oy + 14, 8, 6), STONE, shade_d=1.5, light_d=0.8)
    return c.render(outline=OUTLINE, width=1.6), [ox, oy]


def rubble(tone, glow=None, seed=5):
    """Đá vụn sát đất (vẽ cùng lớp nền): vài khối gãy + sỏi; glow = vệt phát sáng giữa khe (dung nham / tinh thể)."""
    c = Canvas(144, 72)
    ox, oy = 72, 44
    rnd = random.Random(seed)
    if glow:
        c.glow(lambda d: c.ellipse(d, ox - 6, oy + 4, 30, 9), glow, radius=6, alpha=130)
    for (dx, dy, w, h) in ((-34, 4, 22, 13), (6, -6, 18, 11), (34, 10, 14, 9), (-6, 16, 10, 7)):
        x, y = ox + dx, oy + dy
        sk = rnd.uniform(-4, 4)
        c.part(lambda d, x=x, y=y, w=w, h=h, sk=sk: c.poly(d, [(x - w, y + h * 0.5), (x - w + 4 + sk, y - h), (x + w - 2 + sk, y - h + 2), (x + w, y + h * 0.4), (x + 2, y + h * 0.8)]),
               tone, shade_d=2.5, light_d=1)
    for _ in range(7):
        x, y = ox + rnd.uniform(-64, 64), oy + rnd.uniform(-16, 22)
        c.part(lambda d, x=x, y=y: c.ellipse(d, x, y, 3.2, 2.2), tone, shade_d=0.8, light_d=0.4)
    return c.render(outline=OUTLINE, width=1.6), [ox, oy]


def build():
    """{id: (Image, origin)}"""
    out = {"palisade": palisade(), "banner-wolf": banner(), "weapon-rack": weapon_rack()}
    for k in range(3):
        out["debris-%d" % k] = debris(k)
    # GN-2: vùng 2–9
    out["palisade-plain"] = palisade(Tone("#a07048", "#704a2a", "#c8966a"), Tone("#8c6240", "#5e4026", "#b48660"))
    out["banner-wind"] = banner(Tone("#3a6ab0", "#244478", "#6a9ad8"), "#e8f0ff", "wind")
    out["wall-sandstone"] = stone_wall(SANDSTONE, "#9a7040", seed=4)
    out["banner-sun"] = banner(Tone("#d0782a", "#8e4a16", "#f0a050"), "#fff0b0", "sun")
    out["palisade-bamboo"] = palisade(bamboo=True)
    out["banner-leaf"] = banner(Tone("#4a7a3a", "#2c5020", "#78a860"), "#e0f0a0", "leaf", BAMBOO)
    out["wall-basalt"] = stone_wall(BASALT, "#1e1a1e", crack="#ff6a1a", seed=6)
    out["banner-flame"] = banner(Tone("#2e2628", "#181214", "#524648"), "#ff8a2a", "flame", IRON)
    out["palisade-snow"] = palisade(snow=True)
    out["banner-snow"] = banner(Tone("#e8eef6", "#a8b8cc", "#ffffff"), "#4a86c8", "snow")
    out["wall-marble"] = stone_wall(MARBLE, "#b0a898", cap=MARBLE, seed=8)
    out["banner-cloud"] = banner(Tone("#5aa0e0", "#3470b0", "#90c8f4"), "#ffffff", "cloud", MARBLE)
    out["wall-obsidian"] = stone_wall(OBSIDIAN, "#140e20", crack="#b48cff", shards=True, seed=9)
    out["banner-eye"] = banner(Tone("#4a3270", "#2a1a44", "#7a5aa8"), "#d8b8ff", "eye", OBSIDIAN)
    out["wall-jade"] = stone_wall(MARBLE, "#b0a898", cap=JADE, gem="#6fe0b0", seed=10)
    out["banner-lotus"] = banner(GOLD, "#ffffff", "lotus", JADE)
    out["rubble-sand"] = rubble(SANDSTONE, seed=11)
    out["rubble-basalt"] = rubble(BASALT, glow="#ff6a1a", seed=12)
    out["rubble-marble"] = rubble(MARBLE, seed=13)
    out["rubble-void"] = rubble(OBSIDIAN, glow="#b48cff", seed=14)
    out["rubble-ice"] = rubble(Tone("#bfe0f4", "#7aa8cc", "#ffffff"), seed=15)
    return out


if __name__ == "__main__":
    import os
    from PIL import Image
    from vec import hexc
    res = build()
    W = 1500
    prev = Image.new("RGBA", (W, 900), hexc("#5a7048"))
    x, y = 10, 290
    for k, (im, o) in res.items():
        if x + im.size[0] > W:
            x, y = 10, y + 290
        prev.alpha_composite(im, (x, y - im.size[1]))
        x += im.size[0] + 8
    out = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "_preview", "hd-camp-props.png")
    prev.save(out)
    print("ok", out)
