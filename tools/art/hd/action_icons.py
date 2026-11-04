"""UI-41d (03/11, chủ dự án: icon cụm nút góc phải "xấu quá"): bộ icon HD 128×128 riêng cho cụm nút
(ui/action_cluster.gd) theo ảnh concept — hình khối lớn, cel-shade 3 tông + viền tối mềm (vec.py, như icon HD
UI-40) + quầng sáng màu phía sau, đốm lấp lánh. Nền trong suốt (cụm nút vẽ đĩa tối + vành đồng).

    python tools/art/hd/action_icons.py      → godot/assets/hd/icons/act-*.png + docs/design/ui-cluster/icons.png

Nút Đánh dùng icon theo đòn đánh thường của lớp (Classes.basic.icon): slash, shot, fireball, bash, spiritorb.
Chỉ dùng trong cụm nút — icon kỹ năng gốc ở thanh kỹ năng / bảng kỹ năng không đổi (keep-owner-art).
"""
import math
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(HERE)))

from PIL import Image  # noqa: E402

from vec import Canvas, Tone, bezier, hexc  # noqa: E402

S = 128
OUTLINE = "#140e1c"
STEEL = Tone("#d2dae6", "#7d8aa0", "#ffffff")
GOLD = Tone("#eab64e", "#a06a18", "#fff1b0")
GRIP = Tone("#6a3e2a", "#3e2216", "#9a6448")
WOOD = Tone("#a8743e", "#6a4520", "#e0b070")
GLASS = Tone("#e6eef6", "#9fb2c6", "#ffffff")
CORK = Tone("#b07c4c", "#7a522e", "#e0b080")
RED = Tone("#e0303c", "#8a1424", "#ff9a8a")
BLUE = Tone("#3a86ee", "#1a3f9a", "#a8d8ff")
FEATHER = Tone("#4fc46a", "#23743a", "#b4f5c0")
SKIN = Tone("#e8dcc0", "#a89878", "#fffaf0")
VIOLET = Tone("#9a5cf0", "#4a2290", "#e0c4ff")


def _c():
    return Canvas(S, S, light=(-1.0, -1.2))


def _sparkle(c, x, y, r, col="#ffffff", alpha=230):
    k = r * 0.28
    c.flat(lambda d: c.poly(d, [(x, y - r), (x + k, y - k), (x + r, y), (x + k, y + k), (x, y + r), (x - k, y + k),
                                (x - r, y), (x - k, y - k)]), col, alpha=alpha)


def _arc_pts(cx, cy, r, a0, a1, n=40):
    return [(cx + math.cos(a0 + (a1 - a0) * i / n) * r, cy + math.sin(a0 + (a1 - a0) * i / n) * r) for i in range(n + 1)]


def _sword(c, tip, base, half=8.0, guard=20.0, grip=20.0, scale=1.0):
    """Kiếm thẳng từ chuôi base tới mũi tip: lưỡi thép có rãnh máu, chắn tay vàng, chuôi da quấn, núm vàng ngọc đỏ."""
    dx, dy = tip[0] - base[0], tip[1] - base[1]
    L = math.hypot(dx, dy)
    ux, uy = dx / L, dy / L
    nx, ny = -uy, ux
    h = half * scale
    p = lambda t, s=0.0: (base[0] + ux * t + nx * s, base[1] + uy * t + ny * s)  # noqa: E731
    blade = [p(0, h), p(L - h * 2.2, h), p(L, 0), p(L - h * 2.2, -h), p(0, -h)]
    c.part(lambda d: c.poly(d, blade), STEEL, shade_d=3, light_d=1.5)
    c.flat(lambda d: c.poly(d, [p(4, -1.2 * scale), p(L - h * 2.6, -1.2 * scale), p(L - h * 1.2, 0), p(4, 1.2 * scale)]),
           "#6f7c92", alpha=200)
    c.flat(lambda d: c.poly(d, [p(2, -h + 1), p(L - h * 2.2, -h + 1), p(L - 2, 0), p(L - h * 2.2, -h + 3.2), p(2, -h + 3.2)]),
           "#ffffff", alpha=190)
    g = guard * scale
    c.part(lambda d: c.capsule(d, p(-2, g), p(-2, -g), 4.5 * scale, 4.5 * scale), GOLD, shade_d=2, light_d=1.2)
    c.flat(lambda d: c.circle(d, *p(-2, 0), 3.2 * scale), "#3fb4e8")
    gl = grip * scale
    c.part(lambda d: c.capsule(d, p(-6, 0), p(-6 - gl, 0), 4.6 * scale, 4.2 * scale), GRIP, shade_d=1.6)
    for k in range(4):
        t = -9 - k * gl / 4.2
        c.flat(lambda d, t=t: c.capsule(d, p(t, -4.4 * scale), p(t - 3 * scale, 4.4 * scale), 0.9 * scale, 0.9 * scale),
               "#2a160e", alpha=220)
    c.part(lambda d: c.circle(d, *p(-10 - gl, 0), 6.5 * scale), GOLD, shade_d=2)
    c.flat(lambda d: c.circle(d, *p(-10 - gl, 0), 2.8 * scale), "#e2343c")


# ------------------------------------------------------------------ nút Đánh theo lớp


def slash():
    """Kiếm Khách: kiếm lớn chéo (mũi trên trái) + vệt chém trắng xanh."""
    c = _c()
    # vệt chém hình trăng khuyết bên phải lưỡi kiếm (không chạm mũi — tránh trông như cuốc chim)
    sweep = _arc_pts(56, 64, 50, math.radians(-62), math.radians(48), n=40)
    c.glow(lambda d: c.ribbon(d, sweep, [2] + [10] * 39 + [2]), "#7fd0ff", radius=6, alpha=140)
    c.flat(lambda d: c.ribbon(d, sweep, [1 + 7 * math.sin(math.pi * i / 40) for i in range(41)]), "#e8f8ff", alpha=210)
    _sword(c, (22, 22), (90, 90), half=9.5, guard=17, grip=15)
    _sparkle(c, 28, 48, 7)
    _sparkle(c, 108, 50, 5, alpha=200)
    return c.render(outline=OUTLINE, width=3)


def shot():
    """Thợ Săn: cung gỗ viền vàng + mũi tên lông xanh chéo, quầng xanh lá."""
    c = _c()
    c.glow(lambda d: c.circle(d, 64, 64, 36), "#5aff8a", radius=10, alpha=80)
    bow = bezier((30, 18), (98, 10), (118, 76), (110, 110), n=28)
    c.part(lambda d: c.ribbon(d, bow, [4] + [9 + 3 * math.sin(math.pi * i / 28) for i in range(1, 28)] + [4]), WOOD,
           shade_d=2.5, light_d=1.4)
    for t in (0, 14, 28):
        x, y = bow[t]
        c.part(lambda d, x=x, y=y: c.circle(d, x, y, 5), GOLD, shade_d=1.5)
    c.flat(lambda d: c.capsule(d, bow[0], bow[-1], 0.9), "#f4ead0")
    # mũi tên: thân, đầu thép, lông xanh
    a, b = (18, 110), (98, 30)
    c.part(lambda d: c.capsule(d, a, b, 2.6), WOOD, shade_d=1.2)
    c.part(lambda d: c.poly(d, [(108, 20), (88, 30), (98, 40)]), STEEL, shade_d=2, light_d=1)
    for k in range(3):
        o = 6 + k * 6
        c.part(lambda d, o=o: c.poly(d, [(a[0] + o, a[1] - o), (a[0] + o - 12, a[1] - o - 4), (a[0] + o - 8, a[1] - o + 2)]),
               FEATHER, shade_d=1.2, light_d=0.8)
        c.part(lambda d, o=o: c.poly(d, [(a[0] + o, a[1] - o), (a[0] + o + 4, a[1] - o + 12), (a[0] + o - 2, a[1] - o + 8)]),
               FEATHER, shade_d=1.2, light_d=0.8)
    _sparkle(c, 104, 24, 8)
    return c.render(outline=OUTLINE, width=3)


def _flame(c, cx, cy, s, layers):
    for i, (col, k) in enumerate(layers):
        r = 30 * s * k
        top = cy - 58 * s * k
        pts = bezier((cx, top), (cx + r * 0.2, cy - r * 1.2), (cx + r * 1.25, cy - r * 0.6), (cx + r * 0.95, cy + r * 0.1), n=14)
        pts += _arc_pts(cx, cy + r * 0.1, r * 0.95, 0, math.pi, n=20)[1:]
        pts += bezier((cx - r * 0.95, cy + r * 0.1), (cx - r * 1.2, cy - r * 0.7), (cx - r * 0.1, cy - r * 0.9),
                      (cx - r * 0.35, cy - r * 1.7), n=10)[1:]
        pts += bezier((cx - r * 0.35, cy - r * 1.7), (cx - r * 0.1, cy - r * 1.3), (cx + r * 0.1, cy - r * 1.6), (cx, top), n=8)[1:]
        if i == 0:
            c.part(lambda d, pts=pts: c.poly(d, pts), Tone(col, "#a8200c", "#ffb060"), shade_d=3, light_d=0)
        else:
            c.flat(lambda d, pts=pts: c.poly(d, pts), col)


def fireball():
    """Pháp Sư: ngọn lửa lớn nhiều lớp (đỏ cam → vàng → lõi trắng) như concept."""
    c = _c()
    c.glow(lambda d: c.circle(d, 64, 70, 42), "#ff6a20", radius=10, alpha=130)
    _flame(c, 64, 86, 1.38, [("#f0501c", 1.0), ("#ff9a2a", 0.74), ("#ffd650", 0.5), ("#fff6d8", 0.26)])
    for x, y, r in ((30, 40, 3), (100, 50, 2.5), (92, 22, 2)):
        c.flat(lambda d, x=x, y=y, r=r: c.circle(d, x, y, r), "#ffc040")
    return c.render(outline=OUTLINE, width=3)


def bash():
    """Hộ Vệ: khiên thép viền vàng, huy hiệu sư tử giản lược + tia va chạm."""
    c = _c()
    c.glow(lambda d: c.circle(d, 64, 64, 40), "#ffd27a", radius=10, alpha=90)
    for ang in (-150, -120, -60, -30):
        a = math.radians(ang)
        c.flat(lambda d, a=a: c.poly(d, [(64 + math.cos(a) * 46, 66 + math.sin(a) * 46),
                                         (64 + math.cos(a + 0.12) * 60, 66 + math.sin(a + 0.12) * 60),
                                         (64 + math.cos(a - 0.12) * 60, 66 + math.sin(a - 0.12) * 60)]), "#fff1b0", alpha=230)
    shield = [(64, 112)] + bezier((64, 112), (30, 96), (24, 60), (26, 26), n=14)[1:] + \
        bezier((26, 26), (46, 30), (56, 22), (64, 16), n=8)[1:] + bezier((64, 16), (72, 22), (82, 30), (102, 26), n=8)[1:] + \
        bezier((102, 26), (104, 60), (98, 96), (64, 112), n=14)[1:]
    c.part(lambda d: c.poly(d, shield), GOLD, shade_d=3, light_d=1.5)
    inner = [(64 + (x - 64) * 0.82, 62 + (y - 62) * 0.82) for x, y in shield]
    c.part(lambda d: c.poly(d, inner), Tone("#4a6ab0", "#26386e", "#8aa8e8"), shade_d=5, light_d=2)
    c.part(lambda d: c.poly(d, [(64, 34), (82, 48), (80, 74), (64, 92), (48, 74), (46, 48)]), STEEL, shade_d=2.5, light_d=1.2)
    c.flat(lambda d: c.poly(d, [(64, 44), (72, 54), (64, 80), (56, 54)]), "#e2343c")
    c.flat(lambda d: c.poly(d, [(36, 30), (50, 28), (36, 64)]), "#ffffff", alpha=90)
    _sparkle(c, 98, 30, 7)
    return c.render(outline=OUTLINE, width=3)


def spiritorb():
    """Triệu Hồi Sư: cầu linh hồn tím có xoáy sáng + 2 đốm linh hồn bay quanh."""
    c = _c()
    c.glow(lambda d: c.circle(d, 64, 64, 40), "#b070ff", radius=10, alpha=140)
    c.part(lambda d: c.circle(d, 64, 64, 32), VIOLET, shade_d=6, light_d=3)
    c.flat(lambda d: c.ribbon(d, _arc_pts(64, 64, 20, math.radians(200), math.radians(470)),
                              [1 + 4 * math.sin(math.pi * i / 40) for i in range(41)]), "#f0dcff", alpha=220)
    c.flat(lambda d: c.circle(d, 64, 64, 9), "#ffffff", alpha=230)
    c.flat(lambda d: c.ellipse(d, 52, 48, 9, 5, -0.6), "#ffffff", alpha=170)
    for x, y, r in ((24, 34, 7), (104, 92, 6)):
        c.glow(lambda d, x=x, y=y, r=r: c.circle(d, x, y, r), "#d0a0ff", radius=3, alpha=200)
        c.flat(lambda d, x=x, y=y, r=r: c.circle(d, x, y, r * 0.55), "#ffffff")
    _sparkle(c, 100, 30, 6)
    return c.render(outline=OUTLINE, width=3)


# ------------------------------------------------------------------ bình thuốc, né, tự đánh


def potion(tone, glow, sparkle_col):
    """Bình cầu thuỷ tinh: chất lỏng có mặt nước sáng, bọt, nút bần, dây buộc vàng, phản quang + lấp lánh."""
    c = _c()
    c.glow(lambda d: c.circle(d, 64, 78, 40), glow, radius=10, alpha=120)
    c.part(lambda d: (c.circle(d, 64, 80, 34), c.poly(d, [(52, 30), (76, 30), (78, 54), (50, 54)])), GLASS,
           shade_d=4, light_d=2, alpha=235)
    c.part(lambda d: (c.circle(d, 64, 82, 29),), tone, shade_d=7, light_d=3)
    c.flat(lambda d: c.ellipse(d, 64, 62, 27, 6), tone.light, alpha=230)
    for x, y, r in ((54, 84, 4), (72, 94, 3), (66, 74, 2.4), (80, 80, 2)):
        c.flat(lambda d, x=x, y=y, r=r: c.circle(d, x, y, r), "#ffffff", alpha=150)
    c.part(lambda d: c.capsule(d, (49, 34), (79, 34), 4), GOLD, shade_d=1.5)
    c.part(lambda d: c.poly(d, [(51, 12), (77, 12), (75, 32), (53, 32)]), CORK, shade_d=2, light_d=1)
    c.flat(lambda d: c.ellipse(d, 46, 76, 6, 15, 0.35), "#ffffff", alpha=200)
    c.flat(lambda d: c.capsule(d, (56, 40), (56, 52), 2), "#ffffff", alpha=170)
    _sparkle(c, 100, 44, 8, sparkle_col)
    _sparkle(c, 26, 102, 5, sparkle_col, alpha=200)
    return c.render(outline=OUTLINE, width=3)


def dodge():
    """Né lăn: dáng người chạy lướt (màu ngà như concept) + 3 vệt gió + bụi dưới chân."""
    c = _c()
    c.glow(lambda d: c.circle(d, 70, 60, 34), "#6ff0d0", radius=10, alpha=90)
    for y, x0, w in ((46, 8, 4), (64, 2, 5), (82, 12, 4)):
        c.flat(lambda d, y=y, x0=x0, w=w: c.capsule(d, (x0, y), (x0 + 34, y), w * 0.4, w), "#bff8ea", alpha=200)
    # thân nghiêng về trước
    c.part(lambda d: c.capsule(d, (66, 70), (82, 42), 10, 9), SKIN, shade_d=3, light_d=1.4)
    c.part(lambda d: c.circle(d, 92, 28, 11), SKIN, shade_d=3, light_d=1.4)
    # tay: trước vươn, sau vung
    c.part(lambda d: (c.capsule(d, (80, 46), (100, 58), 5, 4.5), c.capsule(d, (100, 58), (112, 48), 4.5, 4)), SKIN, shade_d=2)
    c.part(lambda d: (c.capsule(d, (74, 48), (56, 44), 5, 4.5), c.capsule(d, (56, 44), (44, 54), 4.5, 4)), SKIN, shade_d=2)
    # chân: trước co, sau duỗi
    c.part(lambda d: (c.capsule(d, (68, 72), (90, 84), 7, 6), c.capsule(d, (90, 84), (88, 106), 6, 5)), SKIN, shade_d=2.5)
    c.part(lambda d: (c.capsule(d, (64, 74), (48, 92), 7, 6), c.capsule(d, (48, 92), (24, 98), 6, 5)), SKIN, shade_d=2.5)
    for x, r in ((86, 6), (100, 4.5), (74, 3.5)):
        c.flat(lambda d, x=x, r=r: c.circle(d, x, 112, r), "#d8f8ee", alpha=170)
    return c.render(outline=OUTLINE, width=3)


def auto():
    """Tự đánh: 2 kiếm chéo + vòng mũi tên quay vàng (lặp lại)."""
    c = _c()
    c.glow(lambda d: c.circle(d, 64, 64, 42), "#ffd27a", radius=8, alpha=80)
    ring = _arc_pts(64, 64, 48, math.radians(-60), math.radians(230), n=48)
    c.part(lambda d: c.ribbon(d, ring, [3] + [8] * 47 + [8]), GOLD, shade_d=2, light_d=1.2)
    end = ring[-1]
    a = math.radians(230)
    tx, ty = -math.sin(a), math.cos(a)
    c.part(lambda d: c.poly(d, [(end[0] + math.cos(a) * 10, end[1] + math.sin(a) * 10),
                                (end[0] - math.cos(a) * 10, end[1] - math.sin(a) * 10),
                                (end[0] + tx * 16, end[1] + ty * 16)]), GOLD, shade_d=2)
    _sword(c, (34, 30), (92, 92), half=6, guard=11, grip=9, scale=0.8)
    _sword(c, (94, 30), (36, 92), half=6, guard=11, grip=9, scale=0.8)
    return c.render(outline=OUTLINE, width=3)


def build():
    return {"act-slash": slash(), "act-shot": shot(), "act-fireball": fireball(), "act-bash": bash(),
            "act-spiritorb": spiritorb(),
            "act-potion": potion(RED, "#ff4050", "#ffd0d0"), "act-mp_potion": potion(BLUE, "#4aa8ff", "#d0ecff"),
            "act-dodge": dodge(), "act-auto": auto()}


def preview(res):
    """Bảng xem trước: mỗi icon trên đĩa tối viền đồng (gần giống trong game) + bản nền trong."""
    from PIL import ImageDraw
    cell = 150
    out = Image.new("RGBA", (len(res) * cell, cell * 2), hexc("#1c2420"))
    d = ImageDraw.Draw(out)
    for i, (k, im) in enumerate(res.items()):
        x = i * cell
        d.ellipse([x + 8, 8, x + cell - 8, cell - 8], fill=hexc("#2a1c0e"))
        d.ellipse([x + 13, 13, x + cell - 13, cell - 13], fill=hexc("#8a6636"))
        d.ellipse([x + 19, 19, x + cell - 19, cell - 19], fill=hexc("#12161a"))
        out.alpha_composite(im.resize((112, 112), Image.LANCZOS), (x + 19, 19))
        out.alpha_composite(im, (x + 11, cell + 11))
    return out


def save_all():
    dst = os.path.join(ROOT, "godot", "assets", "hd", "icons")
    os.makedirs(dst, exist_ok=True)
    res = build()
    for k, im in res.items():
        im.save(os.path.join(dst, k + ".png"), optimize=True)
    prev_dir = os.path.join(ROOT, "docs", "design", "ui-cluster")
    os.makedirs(prev_dir, exist_ok=True)
    preview(res).save(os.path.join(prev_dir, "icons.png"))
    return res


if __name__ == "__main__":
    print("act icons:", len(save_all()))
