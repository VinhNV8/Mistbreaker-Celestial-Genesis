"""UI-40c (docs/35 §10): nền + cảnh vật HD vùng 2–9 (đè cùng id bản pixel, cùng kích thước logic: ảnh = pixel × 4).

Không vẽ lại: Gương Băng (ice-mirror — cùng hình quái guong-bang, để đợt quái G3)."""
import math
import random

from PIL import Image, ImageDraw, ImageFilter

from env_forest import _tile
from env_village import OUTLINE, STONE, WOOD, WOOD_DARK, _line, _shadow
from env_camps import BASALT, GOLD, JADE, MARBLE, SNOW, VOID
from vec import Canvas, Tone, bezier, hexc

PX = 4
SAND = Tone("#e0b072", "#b07c44", "#f6d29a")
REDROCK = Tone("#b86a44", "#7c3e26", "#e0946a")
CACTUS = Tone("#5f9a4a", "#3a6a30", "#9acc6a")
PALM = Tone("#4f9a48", "#2e6a32", "#8ed06a")
TRUNK = Tone("#9a7048", "#65462a", "#c49a6a")
DEAD = Tone("#5a5048", "#3a322c", "#857868")
REED = Tone("#a8a060", "#6e6a34", "#d8d08a")
ASH = Tone("#3e3a3c", "#242124", "#625c60")
LAVA = Tone("#ff7a22", "#d8461a", "#ffd060")
ICE = Tone("#a8d8f0", "#6aa0c8", "#e6f6ff")
PINE_SNOW = Tone("#2f6a58", "#1c4638", "#5a9a80")
SKYLEAF = Tone("#6ac25a", "#3e8a3a", "#a8ec7a")
CLOUD = Tone("#ffffff", "#c8d8ee", "#ffffff")
VOIDSTONE = Tone("#2e2640", "#1a1426", "#4e4268")


PAD_X, PAD_Y = 32, 64


def C(w, h):
    """Canvas cỡ ảnh HD cho hình pixel w×h (px logic) + lề (tán lá, lửa, quầng sáng không bị cắt; gốc dời theo lề)."""
    return Canvas(w * PX + 2 * PAD_X, h * PX + PAD_Y)


def O(x, y):
    return x * PX + PAD_X, y * PX + PAD_Y


# ---------------------------------------------------------------- nền (ô lặp 256)


def _slabs(base, cols, mortar, rows=4, per=4, seed=1, moss=None, seams=None, ss=2, jitter=True, crack=0.0, hexes=False):
    W = 256
    img = Image.new("RGBA", (W * ss, W * ss), hexc(mortar))
    d = ImageDraw.Draw(img)
    rnd = random.Random(seed)
    rh = W / rows
    for r in range(rows):
        cw = W / per
        off = (cw / 2) if (r % 2 and jitter) else 0
        for k in range(-1, per + 1):
            x0 = k * cw + off
            g = 3
            box = [(x0 + g) * ss, (r * rh + g) * ss, (x0 + cw - g) * ss, ((r + 1) * rh - g) * ss]
            d.rounded_rectangle(box, radius=6 * ss, fill=hexc(rnd.choice(cols)))
            d.rounded_rectangle([box[0], box[1], box[2], box[1] + 4 * ss], radius=4 * ss, fill=hexc(base, 90))
            if crack and rnd.random() < crack:
                cx, cy = rnd.uniform(box[0], box[2]), rnd.uniform(box[1], box[3])
                pts = [(cx, cy)]
                for _ in range(3):
                    cx += rnd.uniform(-12, 12) * ss
                    cy += rnd.uniform(-8, 8) * ss
                    pts.append((cx, cy))
                d.line(pts, fill=hexc(mortar, 200), width=ss)
    if seams:
        for r in range(rows + 1):
            d.line([0, r * rh * ss, W * ss, r * rh * ss], fill=hexc(seams), width=2 * ss)
    if moss:
        for _ in range(24):
            x, y = rnd.uniform(0, W) * ss, rnd.uniform(0, W) * ss
            d.ellipse([x - 5 * ss, y - 3 * ss, x + 5 * ss, y + 3 * ss], fill=hexc(moss, 90))
    img = img.filter(ImageFilter.GaussianBlur(0.6 * ss))
    return img.resize((W, W), Image.LANCZOS)


def _cobble(base, cols, mortar, seed):
    W, ss = 256, 2
    img = Image.new("RGBA", (W * ss, W * ss), hexc(mortar))
    d = ImageDraw.Draw(img)
    rnd = random.Random(seed)
    n = 9
    step = W / n
    for r in range(n):
        for k in range(-1, n + 1):
            x = (k + (0.5 if r % 2 else 0)) * step + rnd.uniform(-2, 2)
            y = (r + 0.5) * step + rnd.uniform(-2, 2)
            rx, ry = step * 0.44, step * 0.38
            for ox in (-W, 0, W):
                for oy in (-W, 0, W):
                    if -step < x + ox < W + step and -step < y + oy < W + step:
                        col = rnd.choice(cols) if (ox, oy) == (0, 0) else None
                        if col is None:
                            continue
                        d.ellipse([(x + ox - rx) * ss, (y + oy - ry) * ss, (x + ox + rx) * ss, (y + oy + ry) * ss], fill=hexc(col))
                        d.ellipse([(x + ox - rx * 0.7) * ss, (y + oy - ry * 0.9) * ss, (x + ox + rx * 0.5) * ss, (y + oy - ry * 0.2) * ss], fill=hexc(base, 80))
    img = img.filter(ImageFilter.GaussianBlur(0.6 * ss))
    return img.resize((W, W), Image.LANCZOS)


def _speckle(img, cols, n, seed, rmin=1.2, rmax=3.0):
    d = ImageDraw.Draw(img)
    rnd = random.Random(seed)
    for _ in range(n):
        x, y, r = rnd.uniform(0, 256), rnd.uniform(0, 256), rnd.uniform(rmin, rmax)
        col = hexc(rnd.choice(cols))
        for ox in (-256, 0, 256):
            for oy in (-256, 0, 256):
                d.ellipse([x + ox - r, y + oy - r * 0.7, x + ox + r, y + oy + r * 0.7], fill=col)
    return img


def _cracks(img, col, n, seed, glow=None):
    rnd = random.Random(seed)
    layer = Image.new("RGBA", img.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    for _ in range(n):
        x, y = rnd.uniform(0, 256), rnd.uniform(0, 256)
        pts = [(x, y)]
        for _ in range(rnd.randint(3, 6)):
            x += rnd.uniform(-26, 26)
            y += rnd.uniform(-18, 18)
            pts.append((x, y))
        for ox in (-256, 0, 256):
            for oy in (-256, 0, 256):
                d.line([(px + ox, py + oy) for px, py in pts], fill=hexc(col), width=2)
    if glow:
        g = layer.filter(ImageFilter.GaussianBlur(3))
        gl = Image.new("RGBA", img.size, hexc(glow))
        gl.putalpha(g.getchannel("A").point(lambda v: min(255, v * 2)))
        img.alpha_composite(gl)
    img.alpha_composite(layer)
    return img


def tiles():
    t = {}
    t["tile-plain"] = _tile(256, "#7c9a48", [("#6a8a3e", 14, 18, 40, 110), ("#9ab25a", 12, 14, 34, 100), ("#b8a85a", 6, 10, 26, 80)],
                            [("#5a7a34", 90, 9, 160), ("#b8c46a", 60, 7, 150), ("#8aa84a", 80, 8, 140)], seed=61, flowers=2)
    t["tile-town"] = _cobble("#c8c2b4", ["#8f8a80", "#9a958a", "#85807a", "#a39e92", "#7c776e"], "#4e4a44", 62)
    t["tile-sand"] = _speckle(_tile(256, "#e2b878", [("#d0a060", 14, 20, 46, 90), ("#f0cc90", 12, 16, 40, 90)],
                                    [("#c89858", 30, 4, 90)], seed=63), ["#c0905a", "#f4d8a8"], 50, 64)
    t["tile-sand-red"] = _speckle(_tile(256, "#c87a4e", [("#b0643c", 14, 20, 46, 90), ("#de9a68", 12, 16, 40, 90)],
                                        [("#a05a36", 30, 4, 90)], seed=65), ["#9a5232", "#eab08a"], 50, 66)
    ruins = _slabs("#e8d4a8", ["#c8b08a", "#bca47e", "#d2bc94", "#b49c76"], "#d6a868", rows=4, per=3, seed=67, crack=0.5)
    sand = t["tile-sand"].copy()
    m = Image.new("L", (256, 256), 0)
    dm = ImageDraw.Draw(m)
    rnd = random.Random(68)
    for _ in range(9):
        x, y, r = rnd.uniform(0, 256), rnd.uniform(0, 256), rnd.uniform(24, 46)
        for ox in (-256, 0, 256):
            for oy in (-256, 0, 256):
                dm.ellipse([x + ox - r, y + oy - r * 0.7, x + ox + r, y + oy + r * 0.7], fill=255)
    m = m.filter(ImageFilter.GaussianBlur(8))
    ruins.putalpha(Image.eval(m, lambda v: 255 - v))
    sand.alpha_composite(ruins)
    t["tile-ruins"] = sand
    t["tile-swamp"] = _speckle(_tile(256, "#3e5a46", [("#2f4a3a", 14, 18, 40, 110), ("#56704e", 12, 14, 34, 90), ("#4a5a34", 6, 12, 26, 90)],
                                     [("#2a4232", 70, 8, 150), ("#6a8a5a", 50, 6, 130)], seed=69), ["#5a7a4a", "#2a3e30"], 40, 70)
    t["tile-ash"] = _speckle(_tile(256, "#4a4446", [("#3a3436", 14, 18, 40, 110), ("#5e5658", 12, 14, 34, 90)],
                                   [("#2e2a2c", 50, 4, 130), ("#6e6668", 40, 3, 120)], seed=71), ["#ff8a3a", "#8a8080"], 18, 72, 0.8, 1.6)
    bas = _cobble("#6a6268", ["#3e3a3e", "#46424a", "#38343a", "#4a444c", "#423c40"], "#1a161a", 73)
    t["tile-basalt"] = _cracks(bas, "#4a2a22", 2, 74)
    for i in range(2):
        lav = _tile(256, "#e8561a", [("#ff8a2a", 14, 18, 40, 150), ("#b83a12", 12, 14, 34, 120), ("#ffc04a", 6, 10, 22, 130)],
                    [("#ffb040", 30, 6, 120)], seed=75 + i)
        crust = Image.new("RGBA", (256, 256), (0, 0, 0, 0))
        dc = ImageDraw.Draw(crust)
        rnd = random.Random(77 + i)
        for _ in range(10):
            x, y = rnd.uniform(0, 256), rnd.uniform(0, 256)
            pts = [(x + math.cos(a) * rnd.uniform(14, 30), y + math.sin(a) * rnd.uniform(10, 22)) for a in [k * math.tau / 7 for k in range(7)]]
            for ox in (-256, 0, 256):
                for oy in (-256, 0, 256):
                    dc.polygon([(px + ox, py + oy) for px, py in pts], fill=hexc("#3a2420", 235))
        crust = crust.filter(ImageFilter.GaussianBlur(1.2))
        lav.alpha_composite(crust)
        t["tile-lava-%d" % i] = lav
    t["tile-snow"] = _speckle(_tile(256, "#e8f0f8", [("#d8e4f0", 14, 18, 44, 60), ("#f8fcff", 12, 14, 36, 70), ("#ccdaea", 6, 10, 26, 45)],
                                    [("#c8d6e8", 40, 5, 80)], seed=79), ["#ffffff", "#bcd0e6"], 40, 80, 0.8, 2.0)
    ice = _tile(256, "#9ccbe6", [("#b8e0f4", 14, 18, 44, 120), ("#7eb4d8", 12, 14, 36, 110)], [("#d8f0ff", 30, 10, 120)], seed=81)
    t["tile-ice"] = _cracks(ice, "#e8f8ff", 8, 82)
    t["tile-sky-grass"] = _tile(256, "#5eae4c", [("#4e9a40", 14, 18, 40, 110), ("#86c860", 12, 14, 34, 110), ("#9ad46a", 6, 10, 24, 90)],
                                [("#3e8a36", 90, 9, 160), ("#a8e07a", 60, 7, 150), ("#6ab850", 80, 8, 140)], seed=83, flowers=5)
    t["tile-marble"] = _slabs("#ffffff", ["#ece6da", "#e4ddd0", "#f2ede4", "#dcd4c6"], "#c9a24a", rows=4, per=4, seed=84, jitter=False)
    plank = _slabs("#e8f4ff", ["#b89a74", "#a88a66", "#c4a882", "#b09070"], "#5a6a80", rows=8, per=1, seed=85, jitter=False)
    t["tile-wind-bridge"] = plank
    ab = _tile(256, "#2a2238", [("#1e182a", 14, 18, 44, 120), ("#3a2e50", 12, 14, 36, 110), ("#4a2e6a", 6, 10, 26, 80)],
               [("#1a1424", 40, 5, 120)], seed=86)
    ab = _speckle(ab, ["#b48cff", "#e8d8ff", "#6a52a8"], 26, 87, 0.6, 1.4)
    t["tile-abyss"] = _cracks(ab, "#4a3a78", 1, 88)
    t["tile-void"] = _cracks(_slabs("#6a5a8a", ["#3a3050", "#43385c", "#352c4a", "#3e3456"], "#1a1426", rows=4, per=4, seed=89, crack=0.4),
                             "#a07ae8", 3, 90, glow="#b48cff")
    t["tile-heaven"] = _slabs("#ffffff", ["#f2efe6", "#ece8dc", "#e8f0e8", "#f4f0e8"], "#ddd0a8", rows=2, per=2, seed=91, crack=0.3)
    return t


# ---------------------------------------------------------------- đá, cây


def _rock(w, h, ox, oy, pts, tone, moss=None, glow=None, snowcap=False):
    c = C(w, h)
    o = O(ox, oy)
    _shadow(c, o[0] + 4, o[1] + 2, w * PX * 0.42, 7)
    P = [(o[0] + x * PX, o[1] + y * PX) for x, y in pts]
    c.part(lambda d: c.poly(d, P), tone, shade_d=8, light_d=2.4)
    top = sorted(P, key=lambda p: p[1])[:3]
    c.flat(lambda d: c.poly(d, [top[0], top[1], top[2]]), tone.light, alpha=110)
    if moss:
        c.part(lambda d: c.ellipse(d, o[0] - w, o[1] - 10, w * 1.4, 10), moss, shade_d=1.5)
    if glow:
        c.glow(lambda d: c.ellipse(d, o[0], o[1] - h * 1.2, w * 0.9, 8), glow, radius=4, alpha=170)
        _line(c, [(o[0] - w * 0.8, o[1] - h * 1.8), (o[0] - 2, o[1] - h * 1.0), (o[0] + w * 0.6, o[1] - h * 1.6)], glow, 2.4)
    if snowcap:
        cap = [p for p in P if p[1] < o[1] - h * PX * 0.35]
        if len(cap) >= 2:
            c.part(lambda d: c.poly(d, cap + [(cap[-1][0], cap[-1][1] + 14), (cap[0][0], cap[0][1] + 14)]), SNOW, shade_d=2, light_d=1)
    return c.render(outline=OUTLINE, width=2.2), [o[0], o[1]]


def rock_desert(v):
    pts = [(-20, 0), (-18, -14), (-8, -26), (6, -27), (16, -18), (21, 0)] if v == 0 else [(-19, 0), (-17, -20), (-4, -28), (12, -22), (20, -8), (19, 0)]
    img, o = _rock(44, 34, 22, 29, pts, REDROCK)
    return img, o


def rock_lava(v):
    pts = [(-13, 0), (-12, -10), (-4, -17), (7, -16), (13, -7), (14, 0)] if v == 0 else [(-14, 0), (-10, -14), (2, -17), (12, -10), (13, 0)]
    return _rock(30, 22, 15, 18, pts, BASALT, glow="#ff7a22")


def rock_ice(v):
    pts = [(-12, 0), (-11, -10), (-3, -17), (8, -15), (12, -6), (13, 0)] if v == 0 else [(-13, 0), (-8, -15), (3, -17), (12, -8), (12, 0)]
    return _rock(28, 22, 14, 18, pts, ICE, snowcap=True)


def cactus(v):
    c = C(20, 32)
    ox, oy = O(10, 29)
    _shadow(c, ox + 3, oy, 26, 5)

    def body(d):
        c.capsule(d, (ox, oy), (ox, oy - (100 if v == 0 else 80)), 11, 10)
        c.capsule(d, (ox - 10, oy - 46), (ox - 26, oy - 50), 6)
        c.capsule(d, (ox - 26, oy - 50), (ox - 26, oy - 76), 6, 5)
        if v == 0:
            c.capsule(d, (ox + 10, oy - 60), (ox + 24, oy - 62), 6)
            c.capsule(d, (ox + 24, oy - 62), (ox + 24, oy - 86), 6, 5)
    m = c.part(body, CACTUS, shade_d=5, light_d=1.6)
    for x in (ox - 4, ox + 4):
        c.part(lambda d, x=x: d.line([(x * c.ss, (oy - 4) * c.ss), (x * c.ss, (oy - 96) * c.ss)], fill=255, width=c.ss), Tone(CACTUS.shade), clip=m, shade=False, alpha=160)
    if v == 1:
        c.part(lambda d: c.circle(d, ox, oy - 84, 5), Tone("#ff7aa0", "#d04a70", "#ffc0d4"), shade_d=1, light_d=0.6)
    return c.render(outline=OUTLINE, width=2.0), [ox, oy]


def palm():
    c = C(44, 56)
    ox, oy = O(21, 52)
    _shadow(c, ox + 10, oy, 50, 8)
    trunk = bezier((ox, oy), (ox + 6, oy - 90), (ox + 26, oy - 168), n=14)
    c.part(lambda d: c.ribbon(d, trunk, [16 - i * 0.6 for i in range(15)]), TRUNK, shade_d=3, light_d=1)
    for i in range(1, 14, 2):
        x, y = trunk[i]
        _line(c, [(x - 7, y), (x + 7, y - 2)], TRUNK.shade, 1.6, 180)
    top = trunk[-1]
    fronds = [(-80, 20), (-60, -26), (-10, -40), (50, -30), (78, 14), (30, 36), (-30, 34)]

    def leaves(d):
        for fx, fy in fronds:
            pts = bezier(top, (top[0] + fx * 0.5, top[1] + fy * 0.4 - 26), (top[0] + fx, top[1] + fy), n=10)
            c.ribbon(d, pts, [4, 10, 14, 15, 14, 12, 10, 7, 5, 3, 1.5])
    c.part(leaves, PALM, shade_d=4, light_d=1.6)
    for k in range(3):
        c.part(lambda d, k=k: c.circle(d, top[0] - 6 + k * 7, top[1] + 8, 5), Tone("#8a5a2a", "#5a3a1a", "#b88050"), shade_d=1, light_d=0.6)
    return c.render(outline=OUTLINE, width=2.0), [ox, oy]


def oasis():
    c = C(96, 56)
    ox, oy = O(48, 28)
    c.part(lambda d: c.ellipse(d, ox, oy, 184, 100), SAND, shade_d=4, light_d=1)
    c.part(lambda d: c.ellipse(d, ox, oy + 4, 160, 82), Tone("#3a8ab0", "#22608a", "#7ac4e4"), shade_d=8, light_d=0)
    c.flat(lambda d: c.ellipse(d, ox - 40, oy - 24, 70, 18), "#a8e0f4", alpha=110, blur=4)
    for k in range(5):
        a = math.tau * k / 5 + 0.4
        c.part(lambda d, a=a: c.ellipse(d, ox + math.cos(a) * 150, oy + math.sin(a) * 76, 22, 10), Tone("#6aa84a", "#3e7a34", "#a2d872"), shade_d=2, light_d=1)
    return c.render(outline=None), [ox, oy]


def pillar(tone, v, cap=None, broken=False, w=20, h=48, o=(10, 44), gem=None):
    c = C(w, h)
    ox, oy = O(*o)
    hh = (h - 6) * PX - (40 if broken else 0) - v * 18
    cw = w * PX * 0.3
    _shadow(c, ox + 4, oy, cw * 1.6, 7)
    c.part(lambda d: c.poly(d, [(ox - cw - 8, oy - 14), (ox + cw + 8, oy - 14), (ox + cw + 10, oy), (ox - cw - 10, oy)]), tone, shade_d=2, light_d=1)
    if broken:
        top = [(ox - cw, oy - hh), (ox - cw * 0.3, oy - hh - 16), (ox + cw * 0.2, oy - hh - 4), (ox + cw, oy - hh - 22)]
    else:
        top = [(ox - cw, oy - hh), (ox + cw, oy - hh)]
    c.part(lambda d: c.poly(d, [(ox - cw, oy - 14)] + top + [(ox + cw, oy - 14)]), tone, shade_d=5, light_d=1.6)
    for k in (-1, 0, 1):
        _line(c, [(ox + k * cw * 0.55, oy - 18), (ox + k * cw * 0.55, oy - hh + 6)], tone.shade, 1.4, 150)
    if not broken:
        c.part(lambda d: c.poly(d, [(ox - cw - 8, oy - hh - 14), (ox + cw + 8, oy - hh - 14), (ox + cw + 4, oy - hh), (ox - cw - 4, oy - hh)]), cap or tone, shade_d=2, light_d=1)
    if cap and not broken:
        c.part(lambda d: c.poly(d, [(ox - cw - 2, oy - 30), (ox + cw + 2, oy - 30), (ox + cw + 2, oy - 22), (ox - cw - 2, oy - 22)]), cap, shade_d=1, light_d=0.6)
    if gem:
        c.glow(lambda d: c.circle(d, ox, oy - hh - 26, 12), gem, radius=7, alpha=180)
        c.part(lambda d: c.circle(d, ox, oy - hh - 24, 8), Tone(gem), shade_d=2, light_d=1.2)
    return c.render(outline=OUTLINE, width=2.0), [ox, oy]


def dead_tree(v):
    c = C(36, 48)
    ox, oy = O(18, 44)
    _shadow(c, ox + 6, oy, 44, 8)
    rnd = random.Random(90 + v)

    def body(d):
        c.ribbon(d, bezier((ox, oy), (ox - 6, oy - 80), (ox + 4 * (1 if v else -1), oy - 140), n=10), [18 - i * 1.3 for i in range(11)])
        for a, L, y in ((-50, 50, 90), (40, 56, 110), (-30, 40, 130), (60, 34, 70)):
            sx, sy = ox + (2 if a > 0 else -2), oy - y
            ex, ey = sx + math.sin(math.radians(a)) * L, sy - math.cos(math.radians(a)) * L * 0.8
            c.ribbon(d, bezier((sx, sy), ((sx + ex) / 2 + rnd.uniform(-8, 8), (sy + ey) / 2), (ex, ey), n=6), [7, 6, 5, 4, 3, 2, 1])
        c.poly(d, [(ox - 12, oy), (ox - 26, oy + 2), (ox - 6, oy - 14)])
        c.poly(d, [(ox + 12, oy), (ox + 26, oy + 1), (ox + 6, oy - 14)])
    c.part(body, DEAD, shade_d=4, light_d=1.2)
    for k in range(3):
        x, y = ox + rnd.uniform(-40, 40), oy - rnd.uniform(70, 140)
        c.part(lambda d, x=x, y=y: c.ribbon(d, [(x, y), (x + 1, y + 10), (x - 1, y + 22)], [4, 3, 1]), Tone("#6a8a5a", "#465e3a", "#8ab07a"), shade_d=1)
    return c.render(outline=OUTLINE, width=2.0), [ox, oy]


def reeds(v):
    c = C(22, 26)
    ox, oy = O(11, 23)
    rnd = random.Random(30 + v)

    def blades(d):
        for k in range(8):
            x = ox - 30 + k * 8.5
            h = rnd.uniform(56, 88)
            lean = rnd.uniform(-14, 14)
            c.ribbon(d, bezier((x, oy), (x + lean * 0.3, oy - h * 0.5), (x + lean, oy - h), n=8), [6.0 - 0.65 * i for i in range(9)])
    c.part(blades, Tone("#7a9a4a", "#4a6a30", "#b2cc72"), shade_d=3, light_d=1.2)
    for k in range(3):
        x = ox - 18 + k * 18
        h = rnd.uniform(70, 92)
        _line(c, [(x, oy), (x + 2, oy - h)], REED.shade, 2)
        c.part(lambda d, x=x, h=h: c.capsule(d, (x + 2, oy - h), (x + 3, oy - h - 20), 4.5), Tone("#8a5a32", "#5a3a1e", "#b07a4a"), shade_d=1.5, light_d=0.6)
    return c.render(outline=OUTLINE, width=1.8), [ox, oy]


def lily():
    c = C(20, 12)
    ox, oy = O(10, 6)
    for x, y, r in ((-14, 2, 20), (16, -4, 15)):
        c.part(lambda d, x=x, y=y, r=r: c.poly(d, [(ox + x + math.cos(a) * r, oy + y + math.sin(a) * r * 0.55) for a in [k * math.tau / 20 + 0.3 for k in range(18)]] + [(ox + x, oy + y)]),
               Tone("#4e9a4a", "#2e6a32", "#8ad06a"), shade_d=2, light_d=1)
    c.part(lambda d: (c.ellipse(d, ox - 14, oy - 4, 7, 5), c.ellipse(d, ox - 10, oy - 6, 5, 4), c.ellipse(d, ox - 18, oy - 6, 5, 4)), Tone("#ffc4dc", "#e07aa0", "#ffffff"), shade_d=1, light_d=0.6)
    c.flat(lambda d: c.circle(d, ox - 14, oy - 6, 2), "#f6d04a")
    return c.render(outline=OUTLINE, width=1.4), [ox, oy]


def dream_pod():
    c = C(24, 28)
    ox, oy = O(12, 25)
    _shadow(c, ox + 3, oy, 30, 6)
    c.glow(lambda d: c.ellipse(d, ox, oy - 44, 40, 46), "#d88aff", radius=8, alpha=130)
    c.part(lambda d: c.ellipse(d, ox, oy - 44, 34, 42), Tone("#c69ae8", "#8a5ac0", "#f0dcff"), shade_d=6, light_d=2)
    for a in (-0.6, 0.0, 0.6):
        _line(c, bezier((ox + math.sin(a) * 30, oy - 82), (ox + math.sin(a) * 40, oy - 44), (ox + math.sin(a) * 24, oy - 6), n=10), "#8a5ac0", 1.6, 170)
    c.flat(lambda d: c.ellipse(d, ox - 12, oy - 62, 8, 12), "#ffffff", alpha=150)
    c.part(lambda d: c.poly(d, [(ox - 20, oy), (ox - 10, oy - 10), (ox, oy - 2), (ox + 10, oy - 10), (ox + 20, oy)]), Tone("#4e7a4a", "#2e5232", "#7aaa6a"), shade_d=1.5, light_d=0.8)
    return c.render(outline=OUTLINE, width=1.8), [ox, oy]


def tree_ash(v):
    c = C(26, 40)
    ox, oy = O(13, 37)
    _shadow(c, ox + 6, oy, 36, 7)

    def body(d):
        c.ribbon(d, bezier((ox, oy), (ox + 8, oy - 70), (ox - 4, oy - 130), n=10), [16 - i * 1.2 for i in range(11)])
        for a, L, y in ((-55, 36, 80), (45, 40, 100), (-25, 30, 120)):
            sx, sy = ox, oy - y
            c.ribbon(d, [(sx, sy), (sx + math.sin(math.radians(a)) * L * 0.6, sy - L * 0.4), (sx + math.sin(math.radians(a)) * L, sy - L * 0.7)], [6, 4, 2])
    c.part(body, ASH, shade_d=3, light_d=1)
    rnd = random.Random(40 + v)
    for _ in range(4):
        x, y = ox + rnd.uniform(-14, 14), oy - rnd.uniform(20, 110)
        c.glow(lambda d, x=x, y=y: c.circle(d, x, y, 3), "#ff7a22", radius=3, alpha=200)
        _line(c, [(x - 4, y - 6), (x, y), (x + 3, y + 8)], "#ff9a3a", 1.6)
    return c.render(outline=OUTLINE, width=1.8), [ox, oy]


def floating_rock():
    c = C(42, 24)
    ox, oy = O(21, 12)
    c.glow(lambda d: c.ellipse(d, ox, oy + 8, 80, 22), "#ff7a1a", radius=8, alpha=120)
    c.part(lambda d: c.poly(d, [(ox - 76, oy - 8), (ox - 50, oy - 30), (ox + 40, oy - 34), (ox + 78, oy - 6), (ox + 50, oy + 26), (ox - 40, oy + 28)]), BASALT, shade_d=6, light_d=2.4)
    c.part(lambda d: c.poly(d, [(ox - 68, oy - 10), (ox - 46, oy - 28), (ox + 38, oy - 32), (ox + 70, oy - 8), (ox, oy + 4)]), Tone("#6a6266", "#4a4448", "#8e868a"), shade_d=0)
    _line(c, [(ox - 40, oy + 10), (ox - 10, oy + 2), (ox + 30, oy + 14)], "#ff8a2a", 2.4)
    return c.render(outline=OUTLINE, width=2.0), [ox, oy]


def vent():
    c = C(24, 18)
    ox, oy = O(12, 12)
    c.part(lambda d: c.ellipse(d, ox, oy, 42, 20), BASALT, shade_d=4, light_d=1.4)
    c.glow(lambda d: c.ellipse(d, ox, oy - 2, 22, 10), "#ff6a1a", radius=5, alpha=210)
    c.flat(lambda d: c.ellipse(d, ox, oy - 2, 18, 7), "#ffb040")

    def smoke(d):
        for k, (x, y, r) in enumerate(((0, -24, 12), (8, -38, 14), (-2, -52, 12))):
            c.circle(d, ox + x, oy + y, r)
    c.flat(smoke, "#8a8488", alpha=140, blur=2)
    return c.render(outline=OUTLINE, width=1.8), [ox, oy]


def forge_small():
    c = C(36, 34)
    ox, oy = O(18, 31)
    _shadow(c, ox + 4, oy, 60, 8)
    c.part(lambda d: c.poly(d, [(ox - 52, oy - 4), (ox - 46, oy - 70), (ox + 46, oy - 70), (ox + 52, oy - 4)]), BASALT, shade_d=5, light_d=1.6)
    c.part(lambda d: c.poly(d, [(ox + 10, oy - 124), (ox + 34, oy - 124), (ox + 38, oy - 70), (ox + 6, oy - 70)]), BASALT, shade_d=3, light_d=1)
    c.glow(lambda d: c.ellipse(d, ox - 6, oy - 34, 24, 20), "#ff6a1a", radius=8, alpha=210)
    c.part(lambda d: c.ellipse(d, ox - 6, oy - 34, 20, 16), LAVA, shade_d=2, light_d=1)
    return c.render(outline=OUTLINE, width=2.0), [ox, oy]


def pine_snow(v):
    c = C(30, 46)
    ox, oy = O(15, 43)
    _shadow(c, ox + 6, oy, 46, 8)
    c.part(lambda d: c.poly(d, [(ox - 7, oy), (ox - 5, oy - 40), (ox + 5, oy - 40), (ox + 7, oy)]), TRUNK, shade_d=3)
    layers = [(-28, 54, 50), (-62, 44, 48), (-94, 34, 44), (-122, 24, 40)] if v == 0 else [(-26, 50, 54), (-64, 38, 52), (-100, 26, 50)]
    for yb, half, ht in layers:
        pts = [(ox - half, oy + yb)]
        for k in range(1, 6):
            pts.append((ox - half + 2 * half * k / 6, oy + yb + (6 if k % 2 else -2)))
        pts += [(ox + half, oy + yb), (ox, oy + yb - ht)]
        c.part(lambda d, pts=pts: c.poly(d, pts), PINE_SNOW, shade_d=8, light_d=2)
        snow = [(ox - half * 0.7, oy + yb - ht * 0.3), (ox - half * 0.3, oy + yb - ht * 0.24), (ox, oy + yb - ht * 0.36), (ox + half * 0.4, oy + yb - ht * 0.2),
                (ox + half * 0.66, oy + yb - ht * 0.34), (ox, oy + yb - ht)]
        c.part(lambda d, snow=snow: c.poly(d, snow), SNOW, shade_d=2, light_d=1)
    return c.render(outline="#1a2a2a", width=2.2), [ox, oy]


def snow_mound():
    c = C(26, 14)
    ox, oy = O(13, 11)
    _shadow(c, ox + 4, oy, 46, 6, a=50)
    c.part(lambda d: (c.ellipse(d, ox - 12, oy - 14, 34, 18), c.ellipse(d, ox + 18, oy - 10, 28, 14), c.ellipse(d, ox, oy - 4, 46, 10)), SNOW, shade_d=5, light_d=1.6)
    return c.render(outline="#5a6a80", width=1.6), [ox, oy]


def beacon(lit):
    c = C(26, 50)
    ox, oy = O(13, 47)
    img, _ = pillar(STONE, 0, cap=STONE, w=26, h=50, o=(13, 47))
    c.img.paste(img.resize((c.W, c.H), Image.LANCZOS), (0, 0))
    if lit:
        c.glow(lambda d: c.ellipse(d, ox, oy - 186, 30, 36), "#5affb0", radius=10, alpha=200)
        c.part(lambda d: c.poly(d, [(ox - 14, oy - 168), (ox - 8, oy - 192), (ox, oy - 184), (ox + 4, oy - 210), (ox + 10, oy - 186), (ox + 14, oy - 168)]), Tone("#5affb0", "#22c080", "#d8ffe8"), shade_d=2, light_d=1.4)
    return c.render(outline=None), [ox, oy]


def cloud_puff(v):
    c = C(40, 22)
    ox, oy = O(20, 14)
    blobs = [(-44, -10, 30), (0, -26, 38), (42, -12, 30), (-12, 4, 34), (28, 6, 28)] if v == 0 else [(-50, -4, 26), (-14, -22, 32), (24, -18, 34), (54, 0, 24), (0, 6, 32)]
    c.part(lambda d: [c.circle(d, ox + x, oy + y, r) for x, y, r in blobs], CLOUD, shade_d=8, light_d=2)
    return c.render(outline="#8aa0c8", width=1.6), [ox, oy]


def tree_hanging(v):
    c = C(34, 48)
    ox, oy = O(17, 45)
    _shadow(c, ox + 6, oy, 50, 8)
    c.part(lambda d: (c.ribbon(d, bezier((ox, oy), (ox - 4, oy - 60), (ox + 4, oy - 100), n=8), [16, 15, 14, 13, 12, 11, 10, 9, 8]),
                      c.capsule(d, (ox, oy - 90), (ox - 34, oy - 120), 5, 3), c.capsule(d, (ox + 2, oy - 96), (ox + 36, oy - 126), 5, 3)), TRUNK, shade_d=3, light_d=1)
    cl = [(-36, -126, 30), (34, -130, 30), (0, -150, 36), (0, -116, 28)] if v == 0 else [(-30, -132, 34), (30, -136, 34), (0, -160, 28)]
    c.part(lambda d: [c.circle(d, ox + x, oy + y, r) for x, y, r in cl], SKYLEAF, shade_d=10, light_d=4)
    rnd = random.Random(55 + v)

    def vines(d):
        for _ in range(9):
            x = ox + rnd.uniform(-60, 60)
            y0 = oy - rnd.uniform(110, 130)
            L = rnd.uniform(36, 70)
            c.ribbon(d, bezier((x, y0), (x + rnd.uniform(-6, 6), y0 + L * 0.5), (x + rnd.uniform(-8, 8), y0 + L), n=8), [4, 3.6, 3.2, 3, 2.6, 2.2, 2, 1.6, 1.2])
    c.part(vines, Tone("#4e9a4a", "#2e6a32", "#8ad06a"), shade_d=1, light_d=0.6)
    for k in range(4):
        x, y = ox + rnd.uniform(-50, 50), oy - rnd.uniform(110, 160)
        c.flat(lambda d, x=x, y=y: c.circle(d, x, y, 3.4), "#ffe6f2")
    return c.render(outline=OUTLINE, width=2.2), [ox, oy]


def sky_pillar(v):
    return pillar(MARBLE, v, cap=GOLD, broken=True, w=22, h=50, o=(11, 47))


def heaven_pillar(v):
    return pillar(Tone("#f4f2ea", "#c8c4b4", "#ffffff"), v, cap=GOLD, w=22, h=52, o=(11, 49), gem="#8af0d0")


def ruin_pillar(v):
    return pillar(Tone("#d2b88a", "#9e8460", "#ecd6aa"), v, broken=v == 1, w=20, h=48, o=(10, 44))


def anchor_stone(lit):
    c = C(24, 44)
    ox, oy = O(12, 41)
    _shadow(c, ox + 4, oy, 34, 7)
    c.part(lambda d: c.poly(d, [(ox - 30, oy), (ox - 26, oy - 120), (ox - 8, oy - 150), (ox + 18, oy - 140), (ox + 30, oy - 110), (ox + 32, oy)]), STONE, shade_d=8, light_d=2)
    for k in range(6):
        y = oy - 30 - k * 14
        c.part(lambda d, y=y, k=k: c.ellipse(d, ox + (6 if k % 2 else -6), y, 8, 5), Tone("#8a8a92", "#5a5a62", "#c0c0c8"), shade_d=1.5, light_d=0.8)
    if lit:
        c.glow(lambda d: c.ellipse(d, ox, oy - 90, 30, 60), "#6ad8ff", radius=10, alpha=170)
        _line(c, [(ox - 10, oy - 130), (ox + 4, oy - 100), (ox - 6, oy - 60)], "#c8f4ff", 3)
    return c.render(outline=OUTLINE, width=2.0), [ox, oy]


def wind_pillar(lit):
    c = C(30, 56)
    ox, oy = O(15, 53)
    img, _ = pillar(MARBLE, 0, cap=GOLD, w=30, h=56, o=(15, 53))
    c.img.paste(img.resize((c.W, c.H), Image.LANCZOS), (0, 0))
    if lit:
        for k in range(3):
            y = oy - 150 - k * 22
            c.flat(lambda d, y=y, k=k: d.arc([(ox - 40 + k * 4) * c.ss, (y - 10) * c.ss, (ox + 40 - k * 4) * c.ss, (y + 10) * c.ss], 200, 520, fill=255, width=4 * c.ss), "#bff0ff", alpha=220)
        c.glow(lambda d: c.ellipse(d, ox, oy - 170, 40, 40), "#8ae0ff", radius=8, alpha=120)
    return c.render(outline=None), [ox, oy]


def stele_root():
    c = C(36, 56)
    ox, oy = O(18, 53)
    _shadow(c, ox + 4, oy, 64, 10)
    c.part(lambda d: c.poly(d, [(ox - 64, oy - 24), (ox + 64, oy - 24), (ox + 70, oy), (ox - 70, oy)]), MARBLE, shade_d=3, light_d=1.2)
    c.part(lambda d: (c.poly(d, [(ox - 46, oy - 24), (ox + 46, oy - 24), (ox + 42, oy - 180), (ox - 42, oy - 180)]), c.ellipse(d, ox, oy - 180, 42, 20)),
           Tone("#e8e2d4", "#b4ac9a", "#ffffff"), shade_d=8, light_d=2)
    c.glow(lambda d: c.poly(d, [(ox - 26, oy - 160), (ox + 26, oy - 160), (ox + 26, oy - 50), (ox - 26, oy - 50)]), "#fff8d8", radius=8, alpha=140)
    for k in range(6):
        y = oy - 148 + k * 16
        _line(c, [(ox - 20, y), (ox + 20, y)], GOLD.base, 2.4)
        _line(c, [(ox - 8, y - 5), (ox - 8, y + 6)], GOLD.base, 1.8)
    return c.render(outline=OUTLINE, width=2.2), [ox, oy]


def void_stone(v):
    c = C(40, 56)
    ox, oy = O(20, 52)
    _shadow(c, ox + 4, oy, 60, 9)
    pts = [(ox - 54, oy), (ox - 50, oy - 120), (ox - 20, oy - 196), (ox + 18, oy - 180), (ox + 46, oy - 110), (ox + 56, oy)] if v == 0 else \
        [(ox - 50, oy), (ox - 40, oy - 150), (ox, oy - 210), (ox + 30, oy - 140), (ox + 52, oy)]
    c.part(lambda d: c.poly(d, pts), VOIDSTONE, shade_d=10, light_d=2.4)
    c.glow(lambda d: d.line([((ox - 20) * c.ss, (oy - 30) * c.ss), ((ox + 4) * c.ss, (oy - 90) * c.ss), ((ox - 8) * c.ss, (oy - 150) * c.ss)], fill=255, width=6 * c.ss), "#b48cff", radius=5, alpha=200)
    _line(c, [(ox - 20, oy - 30), (ox + 4, oy - 90), (ox - 8, oy - 150)], "#e8d8ff", 2.4)
    _line(c, [(ox + 4, oy - 90), (ox + 30, oy - 110)], "#c8a8ff", 2)
    return c.render(outline="#0e0a16", width=2.2), [ox, oy]


def lamp(lit):
    c = C(24, 56)
    ox, oy = O(12, 53)
    _shadow(c, ox + 3, oy, 30, 6)
    silver = Tone("#c8ccd8", "#8a90a0", "#ffffff")
    c.part(lambda d: c.poly(d, [(ox - 18, oy - 14), (ox + 18, oy - 14), (ox + 22, oy), (ox - 22, oy)]), silver if lit else STONE, shade_d=2, light_d=1)
    c.part(lambda d: c.poly(d, [(ox - 5, oy - 160), (ox + 5, oy - 160), (ox + 6, oy - 14), (ox - 6, oy - 14)]), silver if lit else STONE, shade_d=2, light_d=1)
    if lit:
        c.glow(lambda d: c.circle(d, ox, oy - 182, 34), "#fff0b0", radius=12, alpha=200)
    c.part(lambda d: (c.poly(d, [(ox - 26, oy - 160), (ox + 26, oy - 160), (ox + 18, oy - 200), (ox - 18, oy - 200)]), c.ellipse(d, ox, oy - 204, 18, 6)),
           Tone("#fff4c8", "#e0c070", "#ffffff") if lit else Tone("#7a7a80", "#55555a", "#9a9aa0"), shade_d=3, light_d=1.2)
    return c.render(outline=OUTLINE, width=1.8), [ox, oy]


def airship_dock():
    """Bến khí cầu (Bến Mây): sàn gỗ trên cột, khí cầu nhỏ neo bên trên."""
    c = Canvas(240, 300)
    ox, oy = 120, 288
    _shadow(c, ox + 8, oy - 2, 110, 14)
    for x in (ox - 90, ox - 30, ox + 30, ox + 90):
        c.part(lambda d, x=x: c.poly(d, [(x - 5, oy - 70), (x + 5, oy - 70), (x + 5, oy - 2), (x - 5, oy - 2)]), WOOD_DARK, shade_d=2, light_d=1)
    c.part(lambda d: c.poly(d, [(ox - 104, oy - 82), (ox + 104, oy - 82), (ox + 108, oy - 66), (ox - 108, oy - 66)]), Tone("#b89a74", "#7a6448", "#dcc4a0"), shade_d=2, light_d=1)
    for x in (ox - 96, ox + 96):
        _line(c, [(x, oy - 82), (x, oy - 112)], WOOD.base, 3)
    _line(c, [(ox - 96, oy - 108), (ox + 96, oy - 108)], WOOD.base, 2.4)
    for x in (ox - 40, ox + 40):
        _line(c, [(x, oy - 84), (x + (x - ox) * 0.3, oy - 186)], "#6a5a40", 1.6)
    c.part(lambda d: c.ellipse(d, ox, oy - 226, 92, 48), Tone("#d84a3a", "#9a2a20", "#ff8a70"), shade_d=8, light_d=2.4)
    for k in (-2, -1, 0, 1, 2):
        _line(c, bezier((ox + k * 30, oy - 272), (ox + k * 40, oy - 226), (ox + k * 30, oy - 180), n=10), "#9a2a20", 1.6, 160)
    c.part(lambda d: c.poly(d, [(ox - 40, oy - 168), (ox + 40, oy - 168), (ox + 30, oy - 140), (ox - 30, oy - 140)]), WOOD, shade_d=2, light_d=1)
    _line(c, [(ox - 40, oy - 168), (ox - 60, oy - 186)], "#6a5a40", 1.6)
    _line(c, [(ox + 40, oy - 168), (ox + 60, oy - 186)], "#6a5a40", 1.6)
    return c.render(outline=OUTLINE, width=2.2), [ox, oy]


def build():
    """{id: (Image, origin)}"""
    out = {k: (v, [0, 0]) for k, v in tiles().items()}
    for v in range(2):
        out["rock-desert-%d" % v] = rock_desert(v)
        out["cactus-%d" % v] = cactus(v)
        out["pillar-%d" % v] = ruin_pillar(v)
        out["rock-lava-%d" % v] = rock_lava(v)
        out["tree-ash-%d" % v] = tree_ash(v)
        out["dead-tree-%d" % v] = dead_tree(v)
        out["reeds-%d" % v] = reeds(v)
        out["tree-pine-snow-%d" % v] = pine_snow(v)
        out["rock-ice-%d" % v] = rock_ice(v)
        out["cloud-puff-%d" % v] = cloud_puff(v)
        out["tree-hanging-%d" % v] = tree_hanging(v)
        out["sky-pillar-%d" % v] = sky_pillar(v)
        out["heaven-pillar-%d" % v] = heaven_pillar(v)
    out.update({
        "palm": palm(), "oasis": oasis(), "lily": lily(), "dream-pod": dream_pod(), "floating-rock": floating_rock(), "vent": vent(),
        "forge": forge_small(), "snow-mound": snow_mound(), "beacon": beacon(False), "beacon-lit": beacon(True),
        "anchor-stone": anchor_stone(False), "anchor-stone-lit": anchor_stone(True), "wind-pillar": wind_pillar(False),
        "wind-pillar-lit": wind_pillar(True), "stele-root": stele_root(), "void-stone": void_stone(0),
        "lamp-tinh-quang": lamp(False), "lamp-tinh-quang-lit": lamp(True), "airship-dock": airship_dock(),
    })
    return out


if __name__ == "__main__":
    import os
    res = build()
    W = 1800
    prev = Image.new("RGBA", (W, 1400), hexc("#7a8a6a"))
    x, y = 0, 0
    for k, (im, o) in res.items():
        if k.startswith("tile-"):
            prev.alpha_composite(im.resize((128, 128)), (x, y))
            x += 130
            if x + 128 > W:
                x, y = 0, y + 130
    x, y, rowh = 0, y + 140, 0
    for k, (im, o) in res.items():
        if k.startswith("tile-"):
            continue
        if x + im.size[0] > W:
            x, y, rowh = 0, y + rowh + 6, 0
        prev.alpha_composite(im, (x, y))
        x += im.size[0] + 6
        rowh = max(rowh, im.size[1])
    out = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "_preview", "hd-regions.png")
    prev.save(out)
    print("ok", out, y + rowh)
