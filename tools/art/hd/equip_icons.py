"""EQ-HD (docs/40): icon trang bị HD 128 × 128 — 12 dáng × 2 biến thể × 14 chủ đề (5 phẩm chất + 9 bộ).

    python tools/art/hd/equip_icons.py            → godot/assets/hd/icons/eq-*.png + manifest["hd"]["icons"]
                                                    + ảnh duyệt docs/design/equipment/*.png
    python tools/art/hd/equip_icons.py --preview  → chỉ ảnh duyệt

id icon: eq-<dáng>-<biến thể>-<chủ đề>, ví dụ eq-sword-0-purple, eq-helm-1-hoa_nguc.
Dáng: sword bow staff mace orb (vũ khí theo lớp — item.style), helm armor gloves boots necklace ring amulet.
Game (SpriteLib.item_icon): chủ đề = item.set nếu có, không thì item.rarity; biến thể = item.id % 2.
Đồ độc nhất (item.unique) giữ icon riêng như cũ.
"""
import json
import math
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(HERE)))

from PIL import Image, ImageDraw  # noqa: E402

from equip_kit import (BONE, GOLD, IRON, LEATHER, RARITY_KEYS, SILVER, STEEL, THEMES, WOOD, T, along, arc, aura,  # noqa: E402
                       bezier, gem, glow_bg, glow_fg, hexc, new, render, rivets, sparkle, spec)


# ================================================================== vũ khí
def sword(th, v):
    c = new()
    aura(c, th)
    base, tip = (34, 98), (104, 22)
    p, L = along(base, tip)
    w = 10.5 + th.orn * 0.7
    if v == 0:  # kiếm thẳng hai lưỡi, mũi nhọn
        blade = [p(4, w), p(L - 18, w), p(L, 0), p(L - 18, -w), p(4, -w)]
    else:  # đao cong một lưỡi (sống dày, lưỡi cong về phía trước)
        spine = bezier(p(4, 0), p(L * 0.55, w * 1.6), p(L * 0.95, w * 0.2), p(L + 2, -w * 1.2), n=24)
        widths = [w * 2.0 - (w * 1.95) * (i / 24) ** 1.6 for i in range(25)]
        blade = None
    if blade is not None:
        c.part(lambda d: c.poly(d, blade), th.metal, shade_d=3, light_d=1.4)
    else:
        c.part(lambda d: c.ribbon(d, spine, widths), th.metal, shade_d=3, light_d=1.4)
    if blade is not None:
        c.flat(lambda d: c.poly(d, [p(8, -1.2), p(L - 22, -1.2), p(L - 12, 0), p(L - 22, 1.2), p(8, 1.2)]), th.metal.shade, alpha=200)
        spec(c, [p(10, -w + 2.2), p(L * 0.5, -w + 2.4), p(L - 20, -w + 2.6)], 2.0, 210)
    else:
        spec(c, [(x, y) for (x, y) in spine[2:20]], 1.8, 200)
    if th.orn >= 3:  # văn khắc / rãnh phát sáng dọc lưỡi
        col = th.glow or th.gem
        c.flat(lambda d: c.ribbon(d, [p(14, 0), p(L * 0.45, 0), p(L - 26, 0)], [0.5, 1.6, 0.5]), col, alpha=230)
    # chắn tay
    g = 15 + th.orn * 3
    if th.orn >= 3:
        guard = [p(-4, g), p(4, g * 0.55), p(6, 0), p(4, -g * 0.55), p(-4, -g), p(-1, -g * 0.35), p(-6, 0), p(-1, g * 0.35)]
    else:
        guard = [p(-3, g), p(3, g), p(3, -g), p(-3, -g)]
    c.part(lambda d: c.poly(d, guard), th.trim, shade_d=2, light_d=1)
    gem(c, *p(0, 0), 3.4 + th.orn * 0.4, th.gem)
    # chuôi + núm
    c.part(lambda d: c.capsule(d, p(-6, 0), p(-24, 0), 4.6), th.leather, shade_d=1.6, light_d=0.6)
    for k in range(4):
        t = -9 - k * 4
        c.flat(lambda d, t=t: c.capsule(d, p(t, -4.4), p(t - 2.5, 4.4), 0.8), th.leather.shade, alpha=230)
    c.part(lambda d: c.circle(d, *p(-29, 0), 6 + th.orn * 0.4), th.trim, shade_d=2, light_d=1)
    gem(c, *p(-29, 0), 2.6 + th.orn * 0.3, th.gem, glow=False)
    if th.orn >= 4:
        sparkle(c, *p(L - 6, -10), 7)
    return render(c)


def bow(th, v):
    c = new()
    aura(c, th)
    limb = th.metal if th.orn >= 3 else WOOD
    if v == 0:  # cung cánh cong kép (recurve)
        pts = bezier((34, 12), (98, 8), (112, 70), (70, 116), n=30)
    else:  # cung dài một nhịp
        pts = bezier((22, 22), (92, 6), (122, 74), (100, 112), n=30)
    widths = [3] + [7 + 4 * math.sin(math.pi * i / 30) for i in range(1, 30)] + [3]
    c.part(lambda d: c.ribbon(d, pts, widths), limb, shade_d=2.6, light_d=1.3)
    spec(c, pts[4:14], 1.6, 180)
    mid = pts[15]
    c.part(lambda d: c.capsule(d, pts[12], pts[18], 6.5), th.leather, shade_d=1.4, light_d=0.6)
    for t in (0, 30):
        x, y = pts[t]
        c.part(lambda d, x=x, y=y: c.circle(d, x, y, 4 + th.orn * 0.6), th.trim, shade_d=1.4, light_d=0.7)
    if th.orn >= 2:
        for t in (6, 24):
            x, y = pts[t]
            c.part(lambda d, x=x, y=y: c.poly(d, [(x - 6, y - 2), (x + 2, y - 8), (x + 6, y + 4), (x - 2, y + 6)]), th.trim, shade_d=1.2)
    gem(c, mid[0], mid[1], 3.6 + th.orn * 0.4, th.gem)
    c.flat(lambda d: c.capsule(d, pts[0], pts[-1], 0.9), "#f4ead0")
    # mũi tên chéo
    a, b = (16, 116), (100, 34)
    c.part(lambda d: c.capsule(d, a, b, 2.2), WOOD, shade_d=1)
    c.part(lambda d: c.poly(d, [(110, 24), (92, 32), (102, 42)]), STEEL, shade_d=1.6, light_d=0.8)
    for k in range(2):
        o = 6 + k * 7
        col = th.trim
        c.part(lambda d, o=o: c.poly(d, [(a[0] + o, a[1] - o), (a[0] + o - 12, a[1] - o - 3), (a[0] + o - 7, a[1] - o + 3)]), col, shade_d=1)
        c.part(lambda d, o=o: c.poly(d, [(a[0] + o, a[1] - o), (a[0] + o + 3, a[1] - o + 12), (a[0] + o - 3, a[1] - o + 7)]), col, shade_d=1)
    return render(c)


def staff(th, v):
    c = new()
    aura(c, th, 82, 40, 34)
    base, tip = (22, 116), (86, 40)
    p, L = along(base, tip)
    shaft = th.metal if th.orn >= 3 else WOOD
    c.part(lambda d: c.capsule(d, p(0, 0), p(L, 0), 4.6, 5.6), shaft, shade_d=1.8, light_d=0.9)
    for t in (L * 0.35, L * 0.7):
        c.part(lambda d, t=t: c.capsule(d, p(t - 4, 0), p(t + 4, 0), 7), th.trim, shade_d=1.4, light_d=0.7)
    c.part(lambda d: c.circle(d, *p(0, 0), 4.5), th.trim, shade_d=1)
    hx, hy = 90, 36
    if v == 0:  # móng vuốt / trăng khuyết ôm ngọc cầu
        claw = arc(hx, hy, 25, 25, math.radians(110), math.radians(400), 30)
        c.part(lambda d: c.ribbon(d, claw, [3] + [8 + th.orn * 0.7] * 29 + [3]), th.trim, shade_d=2, light_d=1)
        gem(c, hx, hy, 14 + th.orn * 0.6, th.gem or "#8ad8ff")
    else:  # cụm pha lê
        for ang, ln, w in ((-80, 36, 9), (-40, 28, 7.5), (-120, 27, 7.5), (-10, 19, 6)):
            a = math.radians(ang)
            ex, ey = hx + math.cos(a) * ln, hy + math.sin(a) * ln
            nx, ny = -math.sin(a) * w, math.cos(a) * w
            crystal = [(hx + nx, hy + ny), (ex + nx * 0.6, ey + ny * 0.6), (ex + math.cos(a) * 6, ey + math.sin(a) * 6),
                       (ex - nx * 0.6, ey - ny * 0.6), (hx - nx, hy - ny)]
            col = th.gem or "#8ad8ff"
            tone = T(col, None, None)
            glow_fg(c, lambda d, crystal=crystal: c.poly(d, crystal), col, 4, 100)
            c.part(lambda d, crystal=crystal: c.poly(d, crystal), tone, shade_d=2, light_d=1)
        c.part(lambda d: c.ellipse(d, hx, hy + 6, 12, 6), th.trim, shade_d=1.6, light_d=0.8)
    if th.orn >= 3:
        sparkle(c, hx + 18, hy - 18, 6)
    return render(c)


def mace(th, v):
    c = new()
    aura(c, th, 80, 46, 36)
    base, tip = (22, 114), (74, 50)
    p, L = along(base, tip)
    c.part(lambda d: c.capsule(d, p(0, 0), p(L, 0), 5.6), th.leather if v else WOOD, shade_d=1.6, light_d=0.7)
    for k in range(4):
        t = 6 + k * 5
        c.flat(lambda d, t=t: c.capsule(d, p(t, -4), p(t + 2.5, 4), 0.8), "#2a1810", alpha=220)
    c.part(lambda d: c.circle(d, *p(-2, 0), 6), th.trim, shade_d=1.4)
    hx, hy = 80, 44
    if v == 0:  # chùy cánh (flanged)
        for k in range(6):
            a = k * math.pi / 3 + 0.3
            fl = [(hx + math.cos(a - 0.3) * 12, hy + math.sin(a - 0.3) * 12), (hx + math.cos(a) * (32 + th.orn), hy + math.sin(a) * (32 + th.orn)),
                  (hx + math.cos(a + 0.3) * 12, hy + math.sin(a + 0.3) * 12)]
            c.part(lambda d, fl=fl: c.poly(d, fl), th.metal, shade_d=2, light_d=1)
        c.part(lambda d: c.circle(d, hx, hy, 17), th.trim, shade_d=2.6, light_d=1.3)
    else:  # quả cầu gai
        c.part(lambda d: c.circle(d, hx, hy, 25), th.metal, shade_d=3.4, light_d=1.6)
        for k in range(8):
            a = k * math.pi / 4
            sp = [(hx + math.cos(a - 0.25) * 22, hy + math.sin(a - 0.25) * 22), (hx + math.cos(a) * 36, hy + math.sin(a) * 36),
                  (hx + math.cos(a + 0.25) * 22, hy + math.sin(a + 0.25) * 22)]
            c.part(lambda d, sp=sp: c.poly(d, sp), th.trim, shade_d=1.4, light_d=0.7)
        spec(c, arc(hx, hy, 19, 19, math.radians(200), math.radians(250), 8), 2.2, 200)
    gem(c, hx, hy, 6.5 + th.orn * 0.6, th.gem)
    return render(c)


def orb(th, v):
    c = new()
    aura(c, th, 64, 50, 40)
    col = th.gem or "#a0a8c0"
    glow_bg(c, lambda d: c.circle(d, 64, 50, 34), col, 10, 170)
    # đế / giá đỡ
    c.part(lambda d: c.poly(d, [(40, 104), (88, 104), (78, 88), (50, 88)]), th.trim, shade_d=2, light_d=1)
    c.part(lambda d: c.ellipse(d, 64, 106, 28, 7), th.metal, shade_d=1.6, light_d=0.8)
    tone = T(col, None, None)
    c.part(lambda d: c.circle(d, 64, 52, 28), tone, shade_d=7, light_d=3)
    c.flat(lambda d: c.ribbon(d, arc(64, 52, 16, 16, math.radians(200), math.radians(470), 40),
                              [1 + 3.5 * math.sin(math.pi * i / 40) for i in range(41)]), "#ffffff", alpha=170)
    c.flat(lambda d: c.circle(d, 64, 52, 7), "#ffffff", alpha=220)
    c.flat(lambda d: c.ellipse(d, 52, 38, 9, 5, -0.6), "#ffffff", alpha=170)
    if v == 0:  # móng đỡ 3 nhánh
        for sx in (-1, 0, 1):
            claw = bezier((64 + sx * 10, 90), (64 + sx * 34, 76), (64 + sx * 30, 40), (64 + sx * 18, 30), n=12)
            if sx == 0:
                claw = [(64, 90), (64, 82)]
            c.part(lambda d, claw=claw: c.ribbon(d, claw, [5] + [4] * (len(claw) - 2) + [1.5]), th.trim, shade_d=1.4, light_d=0.7)
    else:  # vòng xoay quanh cầu
        ring = arc(64, 52, 40, 11, 0, math.tau, 48)
        c.part(lambda d: c.ribbon(d, ring, [4] * 49), th.trim, shade_d=1.2, light_d=0.6)
        c.part(lambda d: c.ribbon(d, arc(64, 52, 40, 11, 0.1, math.pi - 0.1, 24), [4.5] * 25), th.trim, shade_d=1.2, light_d=0.6)
    sparkle(c, 98, 24, 6)
    return render(c)


# ================================================================== giáp
def helm(th, v):
    c = new()
    aura(c, th)
    if v == 0:  # mũ hiệp sĩ có tấm che mặt, khe mắt
        c.part(lambda d: (c.circle(d, 64, 60, 36), c.poly(d, [(28, 60), (100, 60), (94, 104), (34, 104)])), th.metal, shade_d=5, light_d=2)
        c.part(lambda d: c.poly(d, [(36, 62), (92, 62), (88, 98), (64, 108), (40, 98)]), th.metal, shade_d=3, light_d=1.4)
        c.flat(lambda d: c.poly(d, [(42, 70), (86, 70), (84, 76), (44, 76)]), "#140d18")
        c.flat(lambda d: c.capsule(d, (64, 80), (64, 100), 1.6), "#140d18", alpha=220)
        c.part(lambda d: c.ribbon(d, [(64, 22), (64, 40), (64, 64), (64, 104)], [4, 6, 6, 4]), th.trim, shade_d=1.4, light_d=0.7)
    else:  # mũ mở, má che, sừng / cánh
        c.part(lambda d: c.circle(d, 64, 62, 34), th.metal, shade_d=5, light_d=2)
        c.part(lambda d: c.poly(d, [(30, 62), (98, 62), (96, 74), (32, 74)]), th.trim, shade_d=1.6, light_d=0.8)
        c.flat(lambda d: c.poly(d, [(40, 74), (88, 74), (84, 102), (44, 102)]), "#1c1622")
        for sx in (-1, 1):
            c.part(lambda d, sx=sx: c.poly(d, [(64 + sx * 34, 72), (64 + sx * 26, 72), (64 + sx * 24, 104), (64 + sx * 34, 96)]), th.metal,
                   shade_d=2, light_d=1)
        horn = th.trim if th.orn >= 2 else BONE
        for sx in (-1, 1):
            pts = bezier((64 + sx * 26, 50), (64 + sx * 48, 44), (64 + sx * 54, 24), (64 + sx * 46, 10), n=14)
            c.part(lambda d, pts=pts: c.ribbon(d, pts, [9 - 7 * i / 14 for i in range(15)]), horn, shade_d=1.6, light_d=0.8)
    spec(c, arc(64, 60, 28, 28, math.radians(205), math.radians(250), 10), 2.6, 200)
    if th.orn >= 1:
        rivets(c, [(38, 66), (90, 66)] if v == 0 else [(40, 68), (88, 68)], 2.2, th.trim)
    gem(c, 64, 46 if v == 0 else 68, 4 + th.orn * 0.6, th.gem)
    if th.orn >= 3 and v == 0:  # chỏm lông / mào
        plume = bezier((64, 26), (80, 4), (104, 4), (116, 20), n=14)
        c.part(lambda d: c.ribbon(d, plume, [8 - 5 * i / 14 for i in range(15)]), th.cloth, shade_d=1.6, light_d=0.8)
    return render(c)


def armor(th, v):
    c = new()
    aura(c, th)
    if v == 0:  # giáp tấm + giáp vai
        c.part(lambda d: c.poly(d, [(40, 30), (88, 30), (96, 70), (88, 112), (40, 112), (32, 70)]), th.metal, shade_d=5, light_d=2)
        c.flat(lambda d: c.poly(d, [(64, 34), (66, 108), (62, 108)]), th.metal.shade, alpha=180)
        for sx in (-1, 1):
            c.part(lambda d, sx=sx: c.ellipse(d, 64 + sx * 34, 40, 20, 14, sx * 0.35), th.trim if th.orn >= 2 else th.metal, shade_d=3, light_d=1.4)
        c.part(lambda d: c.poly(d, [(46, 22), (82, 22), (76, 34), (52, 34)]), th.leather, shade_d=1.4)
        c.part(lambda d: c.poly(d, [(38, 84), (90, 84), (90, 92), (38, 92)]), th.leather, shade_d=1.2, light_d=0.6)
        rivets(c, [(48, 88), (80, 88)], 2.2, th.trim)
        spec(c, [(44, 44), (48, 64), (46, 80)], 2.6, 190)
        gem(c, 64, 56, 5 + th.orn * 0.7, th.gem, cut="diamond")
    else:  # áo choàng / áo bào có cổ và đai
        c.part(lambda d: c.poly(d, [(38, 28), (90, 28), (104, 112), (24, 112)]), th.cloth, shade_d=5, light_d=2)
        for k in range(3):
            x = 46 + k * 18
            c.flat(lambda d, x=x: c.ribbon(d, [(x, 64), (x - 3, 88), (x - 5, 110)], [0.5, 2.2, 0.5]), th.cloth.shade, alpha=200)
        c.part(lambda d: c.poly(d, [(40, 26), (64, 56), (88, 26), (80, 22), (64, 44), (48, 22)]), th.trim, shade_d=1.6, light_d=0.8)
        c.part(lambda d: c.poly(d, [(30, 70), (98, 70), (98, 80), (30, 80)]), th.leather, shade_d=1.4, light_d=0.6)
        c.part(lambda d: c.circle(d, 64, 75, 7), th.trim, shade_d=1.4, light_d=0.7)
        gem(c, 64, 75, 3.6 + th.orn * 0.5, th.gem)
        for sx in (-1, 1):
            c.part(lambda d, sx=sx: c.ellipse(d, 64 + sx * 30, 34, 14, 9, sx * 0.4), th.metal, shade_d=2, light_d=1)
    if th.orn >= 3:
        sparkle(c, 98, 26, 6)
    return render(c)


def gloves(th, v):
    c = new()
    aura(c, th)
    if v == 0:  # găng giáp tấm
        c.part(lambda d: c.poly(d, [(30, 76), (64, 66), (74, 112), (36, 116)]), th.leather, shade_d=2, light_d=1)
        c.part(lambda d: c.poly(d, [(28, 70), (66, 60), (70, 76), (32, 86)]), th.trim, shade_d=1.6, light_d=0.8)
        c.part(lambda d: c.poly(d, [(46, 22), (86, 30), (92, 64), (60, 70), (40, 58)]), th.metal, shade_d=4, light_d=1.6)
        for k in range(4):
            x = 52 + k * 10
            c.part(lambda d, x=x: c.capsule(d, (x, 28 - k), (x + 6, 6 + k * 3), 4.4), th.metal, shade_d=1.6, light_d=0.8)
        c.part(lambda d: c.capsule(d, (88, 48), (104, 30), 5), th.metal, shade_d=1.6, light_d=0.8)
        spec(c, [(50, 30), (56, 50), (58, 62)], 2.2, 190)
        gem(c, 66, 46, 4.6 + th.orn * 0.6, th.gem)
    else:  # găng da cổ loe
        c.part(lambda d: c.poly(d, [(26, 76), (72, 64), (82, 114), (30, 120)]), th.cloth, shade_d=2.4, light_d=1)
        c.part(lambda d: c.poly(d, [(40, 26), (84, 30), (90, 66), (54, 74), (36, 60)]), th.leather, shade_d=3.4, light_d=1.4)
        for k in range(4):
            x = 46 + k * 10
            c.part(lambda d, x=x: c.capsule(d, (x, 30), (x + 4, 10 + k * 2), 4.6), th.leather, shade_d=1.4, light_d=0.7)
        c.part(lambda d: c.capsule(d, (86, 50), (102, 36), 5), th.leather, shade_d=1.4, light_d=0.7)
        c.part(lambda d: c.poly(d, [(30, 70), (76, 60), (78, 70), (32, 80)]), th.trim, shade_d=1.2, light_d=0.6)
        rivets(c, [(42, 74), (56, 70), (70, 66)], 2.0, th.trim)
        gem(c, 62, 48, 3.6 + th.orn * 0.5, th.gem, glow=th.orn >= 3)
    return render(c)


def boots(th, v):
    c = new()
    aura(c, th)
    if v == 0:  # ủng giáp
        c.part(lambda d: c.poly(d, [(42, 14), (78, 14), (80, 76), (110, 92), (110, 112), (38, 112)]), th.leather, shade_d=3, light_d=1.2)
        c.part(lambda d: c.poly(d, [(40, 20), (80, 20), (82, 70), (40, 74)]), th.metal, shade_d=4, light_d=1.6)
        c.part(lambda d: c.poly(d, [(56, 82), (104, 90), (112, 106), (60, 104)]), th.metal, shade_d=2.4, light_d=1.2)
        c.part(lambda d: c.poly(d, [(36, 10), (84, 10), (84, 22), (36, 22)]), th.trim, shade_d=1.6, light_d=0.8)
        spec(c, [(46, 28), (48, 50), (48, 66)], 2.4, 190)
        gem(c, 61, 44, 4.4 + th.orn * 0.6, th.gem, cut="diamond")
    else:  # ủng da có viền lông / dây buộc
        c.part(lambda d: c.poly(d, [(44, 20), (76, 20), (78, 78), (112, 94), (110, 114), (40, 114)]), th.leather, shade_d=3.4, light_d=1.4)
        c.part(lambda d: (c.ellipse(d, 60, 20, 22, 9),), th.cloth if th.motif != "fur" else th.leather, shade_d=1.6, light_d=0.8)
        for k in range(4):
            y = 34 + k * 11
            c.flat(lambda d, y=y: c.capsule(d, (46, y), (74, y + 4), 1.3), th.trim.base, alpha=230)
        c.part(lambda d: c.poly(d, [(40, 108), (112, 108), (112, 116), (40, 116)]), th.trim, shade_d=1, light_d=0.5)
        gem(c, 60, 22, 3.4 + th.orn * 0.5, th.gem, glow=th.orn >= 3)
    if th.orn >= 3:  # cánh nhỏ ở cổ chân
        c.part(lambda d: c.poly(d, [(80, 50), (106, 30), (100, 46), (112, 44), (96, 60), (80, 62)]), th.trim, shade_d=1.4, light_d=0.7)
    return render(c)


# ================================================================== trang sức
def necklace(th, v):
    c = new()
    aura(c, th, 64, 82, 30)
    chain = arc(64, 30, 40, 44, math.radians(10), math.radians(170), 30)
    metal = th.trim if th.orn >= 1 else IRON
    for i in range(0, len(chain) - 1, 2):
        x, y = chain[i]
        c.part(lambda d, x=x, y=y: c.ellipse(d, x, y, 3.6, 2.6), metal, shade_d=0.8, light_d=0.4)
    if v == 0:  # mặt tròn khảm ngọc
        c.part(lambda d: c.circle(d, 64, 86, 18 + th.orn), metal, shade_d=3, light_d=1.4)
        if th.orn >= 2:
            for k in range(8):
                a = k * math.pi / 4
                c.part(lambda d, a=a: c.circle(d, 64 + math.cos(a) * (20 + th.orn), 86 + math.sin(a) * (20 + th.orn), 3), metal,
                       shade_d=0.8)
        gem(c, 64, 86, 11 + th.orn * 0.4, th.gem or "#c0c4cc")
    else:  # mặt giọt nước + cánh
        if th.orn >= 2:
            for sx in (-1, 1):
                c.part(lambda d, sx=sx: c.poly(d, [(64 + sx * 8, 72), (64 + sx * 34, 62), (64 + sx * 26, 78), (64 + sx * 10, 84)]), metal,
                       shade_d=1.4, light_d=0.7)
        c.part(lambda d: c.poly(d, [(64, 64)] + arc(64, 92, 16, 16, -0.2, math.pi + 0.2, 20)[::-1]), metal, shade_d=2.4, light_d=1.2)
        gem(c, 64, 90, 10, th.gem or "#c0c4cc", cut="drop")
    c.part(lambda d: c.circle(d, 64, 70 if v == 0 else 62, 4), metal, shade_d=1)
    return render(c)


def ring(th, v):
    c = new()
    aura(c, th, 64, 60, 36)
    metal = th.trim if th.orn >= 1 else IRON
    band_back = arc(64, 76, 34, 22, math.pi, math.tau, 30)
    band_front = arc(64, 76, 34, 22, 0, math.pi, 30)
    c.part(lambda d: c.ribbon(d, band_back, [7] * 31), metal, shade_d=2, light_d=0.8)
    c.part(lambda d: c.ribbon(d, band_front, [10] * 31), metal, shade_d=2.4, light_d=1.2)
    spec(c, band_front[18:28], 2.2, 200)
    if v == 0:  # ổ ngọc lớn có chấu
        c.part(lambda d: c.ellipse(d, 64, 50, 18, 12), metal, shade_d=2, light_d=1)
        for k in range(4):
            a = k * math.pi / 2 + math.pi / 4
            c.part(lambda d, a=a: c.capsule(d, (64 + math.cos(a) * 12, 52 + math.sin(a) * 6), (64 + math.cos(a) * 15, 40 + math.sin(a) * 9), 2.2),
                   metal, shade_d=0.8)
        gem(c, 64, 42, 11 + th.orn * 0.5, th.gem or "#c0c4cc")
    else:  # 3 ngọc nhỏ trên mặt nhẫn
        c.part(lambda d: c.ellipse(d, 64, 54, 24, 10), metal, shade_d=2, light_d=1)
        for k, x in enumerate((46, 64, 82)):
            gem(c, x, 52 - (6 if k == 1 else 0), 5.5 if k == 1 else 4.2, th.gem or "#c0c4cc", glow=k == 1)
    if th.orn >= 3:
        sparkle(c, 96, 22, 6)
    return render(c)


def amulet(th, v):
    c = new()
    aura(c, th)
    if v == 0:  # ngọc bội tròn có lỗ + tua rua
        jade = T(th.gem or "#a8c0a0", None, None)
        c.part(lambda d: c.capsule(d, (64, 10), (64, 26), 2), th.cloth, shade_d=0.6)
        c.part(lambda d: c.circle(d, 64, 54, 30), jade, shade_d=5, light_d=2.4)
        c.flat(lambda d: c.circle(d, 64, 54, 9), "#140d18")
        c.part(lambda d: c.ribbon(d, arc(64, 54, 20, 20, math.radians(200), math.radians(340), 16), [3] * 17), th.trim, shade_d=1, light_d=0.5)
        c.part(lambda d: c.circle(d, 64, 90, 6), th.trim, shade_d=1.4)
        for k in range(5):
            x = 56 + k * 4
            c.part(lambda d, x=x: c.capsule(d, (64, 92), (x, 120), 1.6), th.cloth, shade_d=0.6, light_d=0.3)
    else:  # bùa giấy / thẻ bài kim loại có ký tự
        c.part(lambda d: c.poly(d, [(40, 20), (88, 20), (92, 104), (64, 118), (36, 104)]), th.metal if th.orn >= 2 else T("#e8d8a8", "#a8946a", "#fff4d0"),
               shade_d=3.4, light_d=1.4)
        c.part(lambda d: c.poly(d, [(46, 28), (82, 28), (84, 98), (64, 108), (44, 98)]), th.cloth, shade_d=2, light_d=0.8)
        ink = th.glow or "#c0302a"
        c.flat(lambda d: c.ribbon(d, [(64, 38), (60, 56), (68, 66), (58, 82), (64, 96)], [2, 4, 3, 4, 2]), ink, alpha=240)
        c.flat(lambda d: c.capsule(d, (52, 52), (76, 48), 2), ink, alpha=240)
        c.part(lambda d: c.circle(d, 64, 22, 6), th.trim, shade_d=1.2)
        gem(c, 64, 22, 3.2 + th.orn * 0.4, th.gem, glow=th.orn >= 3)
    return render(c)


FAMILIES = {"sword": sword, "bow": bow, "staff": staff, "mace": mace, "orb": orb, "helm": helm, "armor": armor,
            "gloves": gloves, "boots": boots, "necklace": necklace, "ring": ring, "amulet": amulet}
VARIANTS = 2


def build():
    out = {}
    for fam, fn in FAMILIES.items():
        for v in range(VARIANTS):
            for key, th in THEMES.items():
                out["eq-%s-%d-%s" % (fam, v, key)] = fn(th, v)
    return out


# ------------------------------------------------------------------ ảnh duyệt
def _font(sz):
    from PIL import ImageFont
    try:
        return ImageFont.truetype(os.path.join(ROOT, "godot", "assets", "fonts", "BeVietnamPro-Medium.ttf"), sz)
    except OSError:
        return None


def _sheet(rows, cols_keys, title_of):
    cell = 112
    f = _font(13)
    img = Image.new("RGBA", (cell * len(cols_keys) + 120, cell * len(rows) + 30), hexc("#1d1712"))
    d = ImageDraw.Draw(img)
    for ci, k in enumerate(cols_keys):
        d.text((120 + ci * cell + 6, 8), title_of(k), fill=(230, 210, 170, 255), font=f)
    for ri, (label, ims) in enumerate(rows):
        y = 30 + ri * cell
        d.text((6, y + cell // 2 - 6), label, fill=(230, 210, 170, 255), font=f)
        for ci, im in enumerate(ims):
            x = 120 + ci * cell
            d.rounded_rectangle([x + 3, y + 3, x + cell - 3, y + cell - 3], 10, fill=hexc("#2a2018"), outline=hexc("#6a5030"))
            img.alpha_composite(im.resize((cell - 12, cell - 12), Image.LANCZOS), (x + 6, y + 6))
    return img


def previews(res, out_dir):
    os.makedirs(out_dir, exist_ok=True)
    rk = RARITY_KEYS
    rows = []
    for fam in FAMILIES:
        for v in range(VARIANTS):
            rows.append(("%s %d" % (fam, v), [res["eq-%s-%d-%s" % (fam, v, k)] for k in rk]))
    _sheet(rows, rk, lambda k: THEMES[k].name).convert("RGB").save(os.path.join(out_dir, "pham-chat.png"))
    sk = [k for k in THEMES if k not in rk]
    rows = []
    for fam in FAMILIES:
        rows.append((fam, [res["eq-%s-0-%s" % (fam, k)] for k in sk]))
    _sheet(rows, sk, lambda k: THEMES[k].name).convert("RGB").save(os.path.join(out_dir, "bo-trang-bi.png"))


def save_all(write_manifest=True):
    res = build()
    previews(res, os.path.join(ROOT, "docs", "design", "equipment"))
    if not write_manifest:
        return res
    dst = os.path.join(ROOT, "godot", "assets", "hd", "icons")
    os.makedirs(dst, exist_ok=True)
    for k, im in res.items():
        im.save(os.path.join(dst, k + ".png"), optimize=True)
    man = os.path.join(ROOT, "godot", "assets", "art_manifest.json")
    with open(man, encoding="utf-8") as f:
        m = json.load(f)
    icons = m.setdefault("hd", {}).setdefault("icons", {})
    for k in list(icons):
        if k.startswith("eq-"):
            del icons[k]
    for k in res:
        icons[k] = "res://assets/hd/icons/%s.png" % k
    with open(man, "w", encoding="utf-8", newline=chr(10)) as f:
        json.dump(m, f, ensure_ascii=False, indent=1)
    return res


if __name__ == "__main__":
    r = save_all(write_manifest="--preview" not in sys.argv)
    print("eq icons:", len(r))
