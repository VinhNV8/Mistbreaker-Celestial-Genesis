"""EQ-HD v2 (docs/42 §6, Q203): vẽ lại 17 icon ĐỒ ĐỘC NHẤT (rơi từ boss) cùng phong cách icon trang bị mới —
khối 3/4, kim loại có vệt bóng, ngọc khảm, quầng màu theo boss (tách lớp, không viền), lớp "tranh vẽ" (paint_pass).
Mỗi món một hình riêng kể chuyện boss rơi ra nó; bậc trang trí luôn cao nhất (đồ độc nhất = Cam).

    python tools/art/hd/equip_unique.py            → ảnh duyệt docs/design/equipment/doc-nhat.png (cũ / mới)
    python tools/art/hd/equip_unique.py --apply    → ghi godot/assets/hd/icons/item-<id>.png + manifest["hd"]["icons"]

Thay bản phẳng IC-2 (items_hd_more.py, giữ nguyên file đó); build_hd.py chạy module này SAU items_hd_more.
"""
import json
import math
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(HERE)))

from PIL import Image, ImageDraw  # noqa: E402

from equip_kit import (BONE, DARK, GOLD, LEATHER, SILVER, STEEL, WOOD, T, along, arc, bezier, gem, glow_bg,  # noqa: E402
                       glow_fg, hexc, new, render, rivets, sparkle, spec)

VOID = T("#6a3ac0", "#2e1470", "#c8a0ff")
VOID_D = T("#2a1c40", "#120a22", "#5a4280")
ICE = T("#9fd8ff", "#3e7ec0", "#f0fbff")
TEAL = T("#2fa89a", "#145a52", "#8ae8d8")
FIRE = T("#ff7a2a", "#a8260e", "#ffd27a")
BARK = T("#7a5634", "#43291a", "#b0845a")
MOSS = T("#5aa84a", "#2a5e24", "#a8e08a")
SAND = T("#d8aa66", "#8a6230", "#fbe0a8")
CHITIN = T("#b8442a", "#5e1a10", "#f08a5a")
PORCELAIN = T("#f2ece0", "#a8a094", "#ffffff")
SILK = T("#9a6ad8", "#5a2e9a", "#d8b8ff")
FUR_W = T("#f4f0e8", "#b8b0a4", "#ffffff")
STONE = T("#8a8478", "#4e4a42", "#c4beb0")


def halo(c, col, cx=64, cy=64, r=46, a=150):
    glow_bg(c, lambda d: c.circle(d, cx, cy, r), col, 12, a)


# ------------------------------------------------------------------ vũ khí
def wolf_fang():
    """Nanh Sói Chúa (Rừng Sương): lưỡi nanh ngà cong, chuôi quấn lông sói xám, ngọc Hư Vô tím ở chắn tay."""
    c = new()
    halo(c, "#a070ff")
    base, tip = (34, 100), (104, 18)
    p, L = along(base, tip)
    spine = bezier(p(6, 0), p(L * 0.5, 12), p(L * 0.85, 8), p(L + 2, -4), n=24)
    c.part(lambda d: c.ribbon(d, spine, [22 - 21 * (i / 24) ** 1.3 for i in range(25)]), BONE, shade_d=3.4, light_d=1.6)
    for k in range(4):  # vân ngà
        t0 = 0.2 + k * 0.17
        q = spine[int(t0 * 24)]
        c.flat(lambda d, q=q: c.ellipse(d, q[0], q[1], 6, 1.4, -0.9), "#b8a98a", alpha=170)
    spec(c, spine[3:16], 2.0, 200)
    c.part(lambda d: c.poly(d, [p(-4, 16), p(6, 10), p(8, 0), p(6, -10), p(-4, -16), p(-1, 0)]), DARK, shade_d=2, light_d=1)
    gem(c, *p(1, 0), 6.5, "#b46bff")
    # chuôi quấn lông sói
    for k in range(4):
        q = p(-10 - k * 6, 0)
        c.part(lambda d, q=q: c.ellipse(d, q[0], q[1], 7, 5.5, -0.8), T("#8a8e98", "#4e5260", "#c8ccd6"), shade_d=1.2, light_d=0.6)
    c.part(lambda d: c.circle(d, *p(-36, 0), 6.5), SILVER, shade_d=1.6, light_d=0.8)
    glow_fg(c, lambda d: c.ribbon(d, spine[2:20], [3] * 18), "#c8a0ff", 4, 110)
    sparkle(c, *p(L - 4, -12), 7, "#e8d8ff")
    return render(c)


def bua_cu_than():
    """Búa Cự Thần (Thiên Không): đầu búa đá trắng khổng lồ vuông góc cán, đai vàng, rune trời phát sáng lam, cán gỗ bọc vàng."""
    c = new()
    halo(c, "#8ad0ff", 72, 46, 46)
    base, tip = (20, 118), (76, 50)
    p, L = along(base, tip)
    c.part(lambda d: c.capsule(d, p(0, 0), p(L + 4, 0), 6), WOOD, shade_d=1.8, light_d=0.8)
    for t in (12, 30):
        c.part(lambda d, t=t: c.capsule(d, p(t - 3, 0), p(t + 3, 0), 7.5), GOLD, shade_d=1.4, light_d=0.7)
    c.part(lambda d: c.circle(d, *p(-3, 0), 7.5), GOLD, shade_d=1.4)
    gem(c, *p(-3, 0), 3.5, "#7ad0ff", glow=False)
    hc = p(L + 6, 0)
    # trục đầu búa vuông góc với cán
    hx, hy = p(1, 0)[0] - p(0, 0)[0], p(1, 0)[1] - p(0, 0)[1]
    ux, uy = -hy, hx
    nx, ny = hx, hy

    def pt(s_, t_):
        return (hc[0] + ux * s_ + nx * t_, hc[1] + uy * s_ + ny * t_)
    head = [pt(-38, -20), pt(38, -20), pt(44, -12), pt(44, 12), pt(38, 20), pt(-38, 20), pt(-44, 12), pt(-44, -12)]
    c.part(lambda d: c.poly(d, head), PORCELAIN, shade_d=5, light_d=2.2)
    for s0 in (-28, 28):
        band = [pt(s0 - 6, -21), pt(s0 + 6, -21), pt(s0 + 6, 21), pt(s0 - 6, 21)]
        c.part(lambda d, band=band: c.poly(d, band), GOLD, shade_d=1.6, light_d=0.8)
    for s0 in (-46, 46):  # mặt búa
        face = [pt(s0 - 3 * (1 if s0 > 0 else -1), -14), pt(s0, -12), pt(s0, 12), pt(s0 - 3 * (1 if s0 > 0 else -1), 14)]
        c.part(lambda d, face=face: c.poly(d, face), STONE, shade_d=1, light_d=0.5)
    rune = [pt(-14, -8), pt(-5, 8), pt(5, -8), pt(14, 8)]
    glow_fg(c, lambda d: c.ribbon(d, rune, [3] * 4), "#8ad8ff", 4, 160)
    c.flat(lambda d: c.ribbon(d, rune, [2.4] * 4), "#e8fbff", alpha=240)
    spec(c, [pt(-36, -16), pt(0, -17), pt(36, -16)], 2.4, 190)
    rivets(c, [pt(-28, -15), pt(-28, 15), pt(28, -15), pt(28, 15)], 2.0, SILVER)
    sparkle(c, 108, 18, 7, "#e8fbff")
    return render(c)

def nanh_hu_vo():
    """Nanh Hư Vô (Hư Vô Thú): dao găm tinh thể đen răng cưa, vết nứt hồng tím phát sáng."""
    c = new()
    halo(c, "#ff5ad0")
    base, tip = (36, 98), (102, 20)
    p, L = along(base, tip)
    blade = [p(4, 12), p(L * 0.25, 15), p(L * 0.3, 9), p(L * 0.5, 13), p(L * 0.55, 7), p(L * 0.75, 9), p(L, 0),
             p(L * 0.7, -8), p(L * 0.4, -11), p(4, -11)]
    c.part(lambda d: c.poly(d, blade), VOID_D, shade_d=3.4, light_d=1.6)
    crack = [p(10, 0), p(L * 0.3, 3), p(L * 0.5, -2), p(L * 0.75, 2), p(L - 8, 0)]
    glow_fg(c, lambda d: c.ribbon(d, crack, [3] * 5), "#ff5ad0", 4, 170)
    c.flat(lambda d: c.ribbon(d, crack, [1.6] * 5), "#ffd0f4", alpha=240)
    spec(c, [p(8, -9), p(L * 0.4, -9.5), p(L * 0.68, -6.5)], 1.6, 160)
    c.part(lambda d: c.poly(d, [p(-3, 16), p(4, 6), p(4, -6), p(-3, -16), p(0, 0)]), VOID, shade_d=1.6, light_d=0.8)
    c.part(lambda d: c.capsule(d, p(-4, 0), p(-26, 0), 5), VOID_D, shade_d=1.4)
    for k in range(3):
        q = p(-8 - k * 6, 0)
        c.flat(lambda d, q=q: c.capsule(d, (q[0] - 3, q[1] - 3), (q[0] + 3, q[1] + 3), 1.0), "#c080ff", alpha=200)
    gem(c, *p(-31, 0), 6, "#ff5ad0")
    return render(c)


def sa_hoang_tail():
    """Đuôi Sa Hoàng (Xích Sa): roi đuôi bọ cạp nhiều đốt vỏ đỏ viền vàng, kim độc nhỏ giọt lục."""
    c = new()
    halo(c, "#9aff5a", 70, 56, 44, 120)
    spine = bezier((20, 112), (10, 40), (70, 6), (104, 40), n=10)
    for i, (x, y) in enumerate(spine[:-1]):
        r = 12 - i * 0.55
        c.part(lambda d, x=x, y=y, r=r: c.circle(d, x, y, r), CHITIN, shade_d=2.4, light_d=1.2)
        c.part(lambda d, x=x, y=y, r=r: c.ribbon(d, arc(x, y, r * 0.9, r * 0.9, math.radians(200), math.radians(340), 8), [2] * 9), GOLD,
               shade_d=0.6, light_d=0.3)
    sx, sy = spine[-1]
    sting = bezier((sx - 8, sy - 6), (sx + 10, sy - 4), (sx + 18, sy + 14), (sx + 10, sy + 30), n=12)
    c.part(lambda d: c.ribbon(d, sting, [14 - 13 * i / 12 for i in range(13)]), T("#e0c070", "#8a6a28", "#fff0c0"), shade_d=2, light_d=1)
    tipx, tipy = sting[-1]
    glow_fg(c, lambda d: c.circle(d, tipx, tipy + 6, 6), "#9aff5a", 4, 170)
    c.part(lambda d: c.poly(d, [(tipx - 3, tipy + 2), (tipx + 3, tipy + 2), (tipx, tipy + 12)]), T("#7aff4a", "#2a8a1a", "#d8ffb8"), shade_d=1)
    c.part(lambda d: c.capsule(d, (14, 116), (26, 104), 7), LEATHER, shade_d=1.4)
    gem(c, 20, 110, 4.5, "#9aff5a")
    return render(c)


# ------------------------------------------------------------------ mũ / mặt nạ
def huyen_anh_mask():
    """Mặt Nạ Huyền Ảnh: mặt nạ bạc nửa mặt, nửa kia tan thành bóng tím (phân thân), khe mắt sáng."""
    c = new()
    halo(c, "#b070ff")
    face = [(64, 18), (94, 30), (100, 62), (90, 96), (64, 112), (38, 96), (28, 62), (34, 30)]
    c.part(lambda d: c.poly(d, face), SILVER, shade_d=5, light_d=2)
    # nửa phải tan thành bóng tím
    c.part(lambda d: c.poly(d, [(64, 18), (94, 30), (100, 62), (90, 96), (64, 112), (70, 80), (60, 56), (68, 34)]), VOID, shade_d=3, light_d=1.2)
    for k in range(4):
        c.flat(lambda d, k=k: c.ellipse(d, 104 + k * 4, 40 + k * 18, 8 - k, 4, 0.4), "#9a6ad8", alpha=170 - k * 30)
    for sx in (-1, 1):
        eye = [(64 + sx * 10, 58), (64 + sx * 28, 52), (64 + sx * 24, 64), (64 + sx * 12, 66)]
        c.flat(lambda d, eye=eye: c.poly(d, eye), "#140d18")
    glow_fg(c, lambda d: c.ellipse(d, 82, 59, 8, 4), "#e0b0ff", 3, 200)
    c.part(lambda d: c.ribbon(d, [(64, 20), (64, 50), (64, 108)], [4, 5, 3]), GOLD, shade_d=1, light_d=0.5)
    gem(c, 64, 34, 6, "#c890ff", cut="diamond")
    spec(c, [(40, 36), (36, 60), (42, 86)], 2.4, 190)
    return render(c)


def mat_na_vo_dien():
    """Mặt Nạ Vô Diện (Ma Tôn): mặt nạ sứ trắng trơn không nét mặt, vương miện đen gắn 5 ngọc ngũ hành."""
    c = new()
    halo(c, "#c080ff")
    c.part(lambda d: c.ellipse(d, 64, 70, 34, 42), PORCELAIN, shade_d=6, light_d=2.4)
    c.flat(lambda d: c.ellipse(d, 64, 74, 22, 30), "#ddd6c8", alpha=120)
    crown = [(26, 44), (34, 14), (46, 34), (56, 6), (64, 30), (72, 6), (82, 34), (94, 14), (102, 44), (64, 38)]
    c.part(lambda d: c.poly(d, crown), VOID_D, shade_d=2.4, light_d=1.2)
    c.part(lambda d: c.ribbon(d, arc(64, 70, 36, 32, math.radians(200), math.radians(340), 20), [6] * 21), GOLD, shade_d=1.6, light_d=0.8)
    for (x, y), col in zip([(34, 20), (48, 32), (64, 24), (80, 32), (94, 20)], ["#ff6a3a", "#3ad06a", "#4aa0ff", "#e8e8e8", "#e0b050"]):
        gem(c, x, y, 4.6, col, glow=False)
    # vết nứt Hư Vô loang từ giữa mặt (không có nét mặt — "vô diện")
    for path in ([(64, 60), (58, 72), (62, 84), (54, 98)], [(64, 60), (72, 70), (68, 80), (76, 92)], [(64, 60), (64, 48)]):
        glow_fg(c, lambda d, path=path: c.ribbon(d, path, [3] * len(path)), "#c080ff", 3, 150)
        c.flat(lambda d, path=path: c.ribbon(d, path, [2.2] + [1.4] * (len(path) - 2) + [0.4]), "#2a0e40", alpha=240)
    c.flat(lambda d: c.ellipse(d, 64, 60, 5, 3), "#2a0e40", alpha=240)
    spec(c, [(42, 56), (38, 76), (44, 96)], 3, 200)
    return render(c)


# ------------------------------------------------------------------ giáp / giày / găng
def vay_that_dau():
    """Vảy Thất Đầu (Thuỷ Quái): áo giáp vảy ngọc lam xếp lớp, cổ 7 nanh nhỏ, giọt nước, ngọc thuỷ giữa ngực."""
    c = new()
    halo(c, "#4ad8d0")
    c.part(lambda d: c.poly(d, [(38, 26), (90, 26), (100, 64), (92, 112), (36, 112), (28, 64)]), TEAL, shade_d=5, light_d=2)
    for row in range(6):
        for col in range(5):
            x = 40 + col * 12 + (6 if row % 2 else 0)
            y = 40 + row * 12
            if x > 92 or (row == 0 and col in (0, 4)):
                continue
            c.part(lambda d, x=x, y=y: c.poly(d, [(x - 6, y - 3), (x + 6, y - 3), (x + 4, y + 4), (x, y + 7), (x - 4, y + 4)]),
                   T("#3ac0b0", "#146a62", "#9af4e8"), shade_d=1, light_d=0.6)
    for sx in (-1, 1):
        c.part(lambda d, sx=sx: c.ellipse(d, 64 + sx * 34, 34, 18, 12, sx * 0.35), T("#2a8a80", "#104a44", "#7ad8cc"), shade_d=2.4, light_d=1.2)
    for k in range(7):
        x = 44 + k * 6.6
        c.part(lambda d, x=x: c.poly(d, [(x - 2.5, 24), (x + 2.5, 24), (x, 16 + (k % 2) * 3)]), BONE, shade_d=0.6)
    gem(c, 64, 62, 8, "#4ad8ff")
    for x, y in ((102, 92), (24, 98), (98, 20)):
        c.part(lambda d, x=x, y=y: c.poly(d, [(x, y - 7)] + arc(x, y, 4, 4, -0.3, math.pi + 0.3, 10)[::-1]), ICE, shade_d=0.8)
    return render(c)


def vay_long_bang():
    """Vảy Long Băng (Long Băng Bắc Cực): ủng phủ vảy băng xanh, gai băng ở cổ, sương lạnh."""
    c = new()
    halo(c, "#8ad8ff")
    c.part(lambda d: c.poly(d, [(42, 18), (78, 18), (80, 76), (112, 92), (112, 114), (38, 114)]), T("#4a6a9a", "#22345a", "#8aaad8"), shade_d=3.4, light_d=1.4)
    for row in range(5):
        for col in range(3):
            x = 48 + col * 11 + (5 if row % 2 else 0)
            y = 26 + row * 11
            c.part(lambda d, x=x, y=y: c.poly(d, [(x - 6, y - 3), (x + 6, y - 3), (x, y + 7)]), ICE, shade_d=1, light_d=0.6)
    for k in range(3):
        x = 84 + k * 9
        c.part(lambda d, x=x: c.poly(d, [(x - 4, 98), (x + 4, 98), (x + 2, 108), (x - 2, 108)]), ICE, shade_d=0.8)
    for k, (x, y) in enumerate(((40, 18), (54, 10), (68, 14), (80, 20))):
        c.part(lambda d, x=x, y=y: c.poly(d, [(x - 5, y + 10), (x + 1, y - 10), (x + 6, y + 10)]), ICE, shade_d=1.2, light_d=0.6)
    c.part(lambda d: c.poly(d, [(36, 108), (114, 108), (114, 116), (36, 116)]), SILVER, shade_d=1, light_d=0.5)
    gem(c, 62, 60, 6, "#bff4ff", cut="diamond")
    sparkle(c, 100, 34, 7, "#e8fbff")
    spec(c, [(46, 30), (48, 52), (48, 72)], 2.2, 180)
    return render(c)


def bach_ho_claw():
    """Vuốt Bạch Hổ (Bạch Hổ Phong Vân): găng lông trắng sọc đen nắm lại, 3 vuốt thép dài cong vút lên từ đốt tay, gió lam."""
    c = new()
    halo(c, "#9ae8ff")
    for k in range(2):
        c.flat(lambda d, k=k: c.ribbon(d, arc(64, 78, 50 + k * 8, 34 + k * 6, math.radians(190), math.radians(290), 14),
                                       [1] + [3] * 13 + [1]), "#c8f4ff", alpha=150)
    # cổ găng (dưới) + nắm tay (trên)
    c.part(lambda d: c.poly(d, [(30, 84), (78, 80), (84, 118), (34, 122)]), FUR_W, shade_d=2.6, light_d=1)
    c.part(lambda d: c.poly(d, [(28, 80), (80, 76), (82, 86), (30, 90)]), GOLD, shade_d=1.4, light_d=0.7)
    c.part(lambda d: (c.ellipse(d, 56, 60, 30, 22),), FUR_W, shade_d=4, light_d=1.6)
    for k in range(4):  # sọc hổ
        x = 36 + k * 12
        c.flat(lambda d, x=x: c.poly(d, [(x, 44 + k), (x + 6, 46 + k), (x + 2, 70), (x - 2, 66)]), "#1c1820", alpha=230)
        c.flat(lambda d, x=x: c.poly(d, [(x - 2, 96), (x + 5, 94), (x + 2, 110)]), "#1c1820", alpha=220)
    for k in range(3):  # 3 vuốt thép từ đốt tay
        x0, y0 = 44 + k * 13, 44 - k * 2
        claw = bezier((x0, y0), (x0 + 2, y0 - 18), (x0 + 14, y0 - 34), (x0 + 28, y0 - 38), n=14)
        c.part(lambda d, claw=claw: c.ribbon(d, claw, [9 - 8.6 * i / 14 for i in range(15)]), STEEL, shade_d=1.6, light_d=0.8)
        spec(c, claw[1:9], 1.2, 210)
        c.part(lambda d, x0=x0, y0=y0: c.circle(d, x0, y0 + 2, 4.5), GOLD, shade_d=1)
    gem(c, 56, 84, 5, "#7ad8ff")
    return render(c)

def _chain(c, cx=64, cy=30, rx=40, ry=44, tone=GOLD):
    for i, (x, y) in enumerate(arc(cx, cy, rx, ry, math.radians(10), math.radians(170), 30)):
        if i % 2 == 0:
            c.part(lambda d, x=x, y=y: c.ellipse(d, x, y, 3.4, 2.4), tone, shade_d=0.8, light_d=0.4)


def long_tam():
    """Long Tâm (Viêm Long): nhẫn đen bọc móng rồng vàng, ôm tim rồng nham thạch rực cháy."""
    c = new()
    halo(c, "#ff7a2a", 64, 48, 42, 170)
    band = arc(64, 80, 32, 20, 0, math.pi, 30)
    c.part(lambda d: c.ribbon(d, arc(64, 80, 32, 20, math.pi, math.tau, 30), [7] * 31), DARK, shade_d=1.6)
    c.part(lambda d: c.ribbon(d, band, [11] * 31), DARK, shade_d=2.4, light_d=1.2)
    spec(c, band[18:28], 2, 180)
    c.part(lambda d: c.circle(d, 64, 44, 22), FIRE, shade_d=6, light_d=2.4)
    for k in range(5):  # vân nham
        a = k * 1.25
        c.flat(lambda d, a=a: c.ribbon(d, [(64, 44), (64 + math.cos(a) * 12, 44 + math.sin(a) * 12), (64 + math.cos(a + 0.4) * 19, 44 + math.sin(a + 0.4) * 19)],
                                       [2.4, 1.6, 0.6]), "#fff0a0", alpha=230)
    glow_fg(c, lambda d: c.circle(d, 64, 44, 14), "#ffd040", 6, 150)
    for sx in (-1, 1):  # móng rồng ôm tim
        claw = bezier((64 + sx * 16, 68), (64 + sx * 30, 52), (64 + sx * 26, 28), (64 + sx * 12, 22), n=12)
        c.part(lambda d, claw=claw: c.ribbon(d, claw, [7] + [5] * 11 + [1.5]), GOLD, shade_d=1.4, light_d=0.7)
    sparkle(c, 98, 22, 7, "#fff0b0")
    return render(c)


def an_hu_vo():
    """Ấn Hư Vô (Giáo Chủ Hư Vô): nhẫn ấn bạc đen, mặt ấn khắc mắt Hư Vô phát sáng hồng tím."""
    c = new()
    halo(c, "#ff5ad0", 64, 48, 40)
    band = arc(64, 82, 30, 18, 0, math.pi, 30)
    c.part(lambda d: c.ribbon(d, arc(64, 82, 30, 18, math.pi, math.tau, 30), [7] * 31), SILVER, shade_d=1.6)
    c.part(lambda d: c.ribbon(d, band, [10] * 31), SILVER, shade_d=2.4, light_d=1.2)
    c.part(lambda d: c.ellipse(d, 64, 48, 28, 22), VOID_D, shade_d=4, light_d=1.6)
    c.part(lambda d: c.ribbon(d, arc(64, 48, 28, 22, 0, math.tau, 40), [5] * 41), SILVER, shade_d=1.2, light_d=0.6)
    c.flat(lambda d: c.ellipse(d, 64, 48, 16, 8), "#ffd0f4", alpha=230)
    glow_fg(c, lambda d: c.ellipse(d, 64, 48, 16, 9), "#ff5ad0", 5, 170)
    c.flat(lambda d: c.circle(d, 64, 48, 5.5), "#1a0820")
    c.flat(lambda d: c.circle(d, 62, 46, 1.6), "#ffffff")
    for k in range(6):
        a = k * math.pi / 3
        c.flat(lambda d, a=a: c.circle(d, 64 + math.cos(a) * 23, 48 + math.sin(a) * 17, 1.6), "#ff8ae0", alpha=220)
    spec(c, band[18:27], 2, 190)
    return render(c)


def sung_ky_lan():
    """Sừng Kỳ Lân (Kỳ Lân Mây): mặt dây là sừng xoắn trắng ngà viền vàng, mây cuộn, quầng lục hồi máu."""
    c = new()
    halo(c, "#8affb0", 64, 80, 36)
    _chain(c)
    base, tip = (64, 66), (68, 124)
    p, L = along(base, tip)
    horn = [p(0, 13), p(L, 0), p(0, -13)]
    c.part(lambda d: c.poly(d, horn), BONE, shade_d=3, light_d=1.4)
    for k in range(5):
        t = 6 + k * 9
        c.flat(lambda d, t=t: c.ribbon(d, [p(t, 13 - t * 0.22), p(t + 7, -(13 - t * 0.22))], [1.8, 1.8]), "#d8b860", alpha=230)
    c.part(lambda d: c.ellipse(d, 64, 64, 16, 7), GOLD, shade_d=1.4, light_d=0.7)
    for sx in (-1, 1):  # mây cuộn
        c.part(lambda d, sx=sx: c.ribbon(d, arc(64 + sx * 18, 62, 8, 6, 0 if sx > 0 else math.pi, (math.tau * 0.8) * sx + (0 if sx > 0 else math.pi), 16),
                                        [3] * 17), T("#e8f4ff", "#a8b8d0", "#ffffff"), shade_d=0.8, light_d=0.4)
    gem(c, 64, 62, 4.6, "#6aff9a")
    glow_fg(c, lambda d: c.ribbon(d, [p(4, 0), p(L - 6, 0)], [3, 2]), "#bfffd8", 4, 120)
    sparkle(c, 98, 92, 6, "#d8ffe8")
    return render(c)


def nhan_su_eye():
    """Mắt Nhân Sư (Nhân Sư Đá): huy chương đá sa thạch viền vàng, con mắt hổ phách phát sáng, ngọc lam hai bên."""
    c = new()
    halo(c, "#ffc040", 64, 82, 34)
    _chain(c)
    c.part(lambda d: c.circle(d, 64, 84, 28), GOLD, shade_d=3, light_d=1.4)
    c.part(lambda d: c.circle(d, 64, 84, 22), SAND, shade_d=4, light_d=1.6)
    eye = [(42, 84), (52, 74), (64, 70), (76, 74), (86, 84), (76, 94), (64, 98), (52, 94)]
    c.flat(lambda d: c.poly(d, eye), "#2a1a10")
    c.part(lambda d: c.circle(d, 64, 84, 9), T("#ffb030", "#a85a10", "#fff0a0"), shade_d=2, light_d=1)
    glow_fg(c, lambda d: c.circle(d, 64, 84, 9), "#ffc040", 5, 150)
    c.flat(lambda d: c.ellipse(d, 64, 84, 2.2, 7), "#2a1a10")
    c.flat(lambda d: c.circle(d, 61, 81, 1.8), "#ffffff")
    for sx in (-1, 1):
        gem(c, 64 + sx * 25, 84, 4, "#3ad8d0", glow=False)
    c.part(lambda d: c.circle(d, 64, 56, 5), GOLD, shade_d=1)
    return render(c)


def long_phuong():
    """Lông Phượng (Phượng Hoàng Tro): lông vũ lửa lớn đỏ → cam → vàng, đốm than hồng bay lên."""
    c = new()
    halo(c, "#ff8a2a", 64, 60, 46, 160)
    shaft = bezier((26, 118), (40, 80), (70, 40), (104, 12), n=20)
    left = [(x - 14 * math.sin(math.pi * i / 20) - 2, y - 10 * math.sin(math.pi * i / 20)) for i, (x, y) in enumerate(shaft)]
    right = [(x + 12 * math.sin(math.pi * i / 20) + 2, y + 12 * math.sin(math.pi * i / 20)) for i, (x, y) in enumerate(shaft)]
    vane = left[3:] + right[3:][::-1]
    c.part(lambda d: c.poly(d, vane), T("#e8401a", "#8a140a", "#ff9a5a"), shade_d=4, light_d=1.6)
    inner_l = [(x * 0.6 + sx * 0.4, y * 0.6 + sy * 0.4) for (x, y), (sx, sy) in zip(left[3:], shaft[3:])]
    inner_r = [(x * 0.6 + sx * 0.4, y * 0.6 + sy * 0.4) for (x, y), (sx, sy) in zip(right[3:], shaft[3:])]
    c.flat(lambda d: c.poly(d, inner_l + inner_r[::-1]), "#ffb040", alpha=230)
    for i in range(5, 18, 3):  # vân lông
        x, y = shaft[i]
        c.flat(lambda d, x=x, y=y: c.ribbon(d, [(x, y), (x - 12, y - 2)], [1.2, 0.4]), "#7a1608", alpha=200)
        c.flat(lambda d, x=x, y=y: c.ribbon(d, [(x, y), (x + 4, y + 12)], [1.2, 0.4]), "#7a1608", alpha=200)
    c.part(lambda d: c.ribbon(d, shaft, [4] * 6 + [2.6] * 15), GOLD, shade_d=0.8, light_d=0.4)
    c.flat(lambda d: c.poly(d, [shaft[16], shaft[20], (shaft[18][0] + 4, shaft[18][1] + 6)]), "#fff4b0", alpha=220)
    for x, y, r in ((96, 40, 3), (104, 58, 2.4), (86, 24, 2), (110, 30, 1.8)):
        glow_fg(c, lambda d, x=x, y=y, r=r: c.circle(d, x, y, r * 2), "#ff8a2a", 3, 170)
        c.flat(lambda d, x=x, y=y, r=r: c.circle(d, x, y, r), "#fff0a0")
    return render(c)


def goi_mong():
    """Gối Mộng (Nữ Vương Phệ Mộng): gối lụa tím căng phồng, trăng khuyết vàng thêu, 4 tua, sao mộng hồng."""
    c = new()
    halo(c, "#e090ff")
    pil = [(22, 54), (40, 36), (88, 32), (108, 50), (106, 84), (88, 98), (38, 100), (20, 84)]
    c.part(lambda d: c.poly(d, pil), SILK, shade_d=6, light_d=2.4)
    for p0, p1 in (((40, 40), (38, 96)), ((88, 36), (90, 94))):
        c.flat(lambda d, p0=p0, p1=p1: c.ribbon(d, [p0, ((p0[0] + p1[0]) / 2 + 4, (p0[1] + p1[1]) / 2), p1], [0.6, 2, 0.6]), "#5a2e9a", alpha=200)
    moon = arc(64, 66, 16, 16, math.radians(60), math.radians(300), 20)
    c.part(lambda d: c.ribbon(d, moon, [2] + [6] * 19 + [2]), GOLD, shade_d=1, light_d=0.6)
    for x, y in ((22, 54), (108, 50), (106, 84), (20, 84)):
        c.part(lambda d, x=x, y=y: c.circle(d, x, y, 4), GOLD, shade_d=1)
        c.part(lambda d, x=x, y=y: c.poly(d, [(x - 3, y + 2), (x + 3, y + 2), (x + 1, y + 16), (x - 1, y + 16)]), T("#e8b0ff", "#9a5ad0", "#ffffff"), shade_d=0.6)
    gem(c, 80, 60, 4.5, "#ff9ae8")
    for x, y, r in ((30, 24, 6), (100, 22, 5), (112, 104, 4)):
        sparkle(c, x, y, r, "#ffd0f8")
    spec(c, [(40, 44), (64, 40), (86, 42)], 2.4, 160)
    return render(c)


def guong_ban_nga():
    """Gương Bản Ngã (Bản Ngã Bóng Tối): gương tay khung bạc chạm băng, mặt gương tối phản chiếu bóng không mặt."""
    c = new()
    halo(c, "#7ad0ff")
    c.part(lambda d: c.capsule(d, (64, 92), (64, 120), 6), SILVER, shade_d=1.6, light_d=0.8)
    c.part(lambda d: c.circle(d, 64, 120, 6), SILVER, shade_d=1)
    c.part(lambda d: c.circle(d, 64, 52, 38), SILVER, shade_d=4, light_d=2)
    for k in range(10):  # gai băng chạm khắc quanh khung
        a = k * math.tau / 10
        c.part(lambda d, a=a: c.poly(d, [(64 + math.cos(a - 0.12) * 36, 52 + math.sin(a - 0.12) * 36), (64 + math.cos(a) * 46, 52 + math.sin(a) * 46),
                                         (64 + math.cos(a + 0.12) * 36, 52 + math.sin(a + 0.12) * 36)]), ICE, shade_d=1, light_d=0.5)
    c.part(lambda d: c.circle(d, 64, 52, 30), T("#1e2a44", "#0c1222", "#3e5a88"), shade_d=4, light_d=1)
    c.flat(lambda d: c.poly(d, [(50, 82), (52, 56), (64, 42), (76, 56), (78, 82)]), "#060810", alpha=230)   # bóng người
    c.flat(lambda d: c.circle(d, 64, 46, 9), "#060810", alpha=240)
    glow_fg(c, lambda d: c.circle(d, 64, 46, 10), "#7ad0ff", 4, 90)
    c.flat(lambda d: c.poly(d, [(40, 34), (54, 26), (44, 50)]), "#ffffff", alpha=110)
    gem(c, 64, 12, 5, "#9ae8ff", cut="diamond")
    return render(c)


def lao_thu_bark():
    """Vỏ Lão Thụ (Lão Thụ Sương Mù): mảnh vỏ cây cổ thụ khắc rune lục phát sáng, rêu, mầm lá non, dây leo buộc."""
    c = new()
    halo(c, "#9aff6a")
    bark = [(36, 20), (86, 16), (98, 52), (92, 110), (40, 114), (28, 66)]
    c.part(lambda d: c.poly(d, bark), BARK, shade_d=5, light_d=2)
    for k in range(5):  # thớ vỏ
        x = 42 + k * 11
        c.flat(lambda d, x=x: c.ribbon(d, [(x, 22), (x - 3, 64), (x + 2, 108)], [0.6, 2.2, 0.6]), "#3a2414", alpha=210)
    rune = [(54, 46), (70, 40), (62, 60), (76, 74), (58, 90)]
    glow_fg(c, lambda d: c.ribbon(d, rune, [3] * 5), "#9aff6a", 5, 170)
    c.flat(lambda d: c.ribbon(d, rune, [2.4] * 5), "#e8ffd0", alpha=240)
    for x, y, r in ((36, 96, 10), (90, 30, 8), (46, 24, 6)):
        c.part(lambda d, x=x, y=y, r=r: c.ellipse(d, x, y, r, r * 0.6), MOSS, shade_d=1.4, light_d=0.7)
    sprout = bezier((86, 20), (90, 6), (100, 4), (106, 10), n=8)
    c.part(lambda d: c.ribbon(d, sprout, [2] * 9), MOSS, shade_d=0.6)
    for (x, y, rot) in ((98, 6, -0.6), (106, 14, 0.5)):
        c.part(lambda d, x=x, y=y, rot=rot: c.ellipse(d, x, y, 7, 3.5, rot), T("#7ad85a", "#2e7a22", "#c8ff9a"), shade_d=0.8, light_d=0.5)
    c.part(lambda d: c.ribbon(d, arc(64, 64, 36, 10, math.radians(10), math.radians(170), 20), [3] * 21), T("#6a8a3a", "#34501a", "#a8c870"), shade_d=0.8)
    gem(c, 64, 74, 5, "#c8ff7a", glow=False)
    return render(c)


BUILDERS = {"wolf_fang": wolf_fang, "lao_thu_bark": lao_thu_bark, "huyen_anh_mask": huyen_anh_mask, "bach_ho_claw": bach_ho_claw,
            "sa_hoang_tail": sa_hoang_tail, "nhan_su_eye": nhan_su_eye, "long_tam": long_tam, "long_phuong": long_phuong,
            "goi_mong": goi_mong, "vay_that_dau": vay_that_dau, "guong_ban_nga": guong_ban_nga, "vay_long_bang": vay_long_bang,
            "bua_cu_than": bua_cu_than, "sung_ky_lan": sung_ky_lan, "an_hu_vo": an_hu_vo, "nanh_hu_vo": nanh_hu_vo,
            "mat_na_vo_dien": mat_na_vo_dien}


def build():
    return {"item-" + k: fn() for k, fn in BUILDERS.items()}


def review(res):
    """Ảnh duyệt: mỗi món 2 ô — icon cũ (IC-2, phẳng) và icon mới — trên nền ô Cam như trong game."""
    from equip_icons import _font
    f = _font(12)
    cell = 120
    cols = 6
    rows = (len(res) + cols - 1) // cols
    img = Image.new("RGBA", (cols * cell * 2 + 20, rows * (cell + 22) + 10), hexc("#1d1712"))
    d = ImageDraw.Draw(img)
    for i, (k, im) in enumerate(res.items()):
        x = 10 + (i % cols) * cell * 2
        y = 6 + (i // cols) * (cell + 22)
        old_p = os.path.join(ROOT, "godot", "assets", "hd", "icons", k + ".png")
        for j, src in enumerate((old_p, None)):
            bx = x + j * cell
            d.rounded_rectangle([bx + 3, y + 3, bx + cell - 3, y + cell - 3], 10, fill=hexc("#3a2214"), outline=hexc("#ff9a3c"), width=2)
            pic = Image.open(src).convert("RGBA") if src and os.path.exists(src) else im
            img.alpha_composite(pic.resize((cell - 14, cell - 14), Image.LANCZOS), (bx + 7, y + 7))
        d.text((x + 6, y + cell + 2), "%s  (cũ | mới)" % k[5:], fill=(230, 210, 170, 255), font=f)
    return img


def apply(res):
    dst = os.path.join(ROOT, "godot", "assets", "hd", "icons")
    for k, im in res.items():
        im.save(os.path.join(dst, k + ".png"), optimize=True)
    man = os.path.join(ROOT, "godot", "assets", "art_manifest.json")
    with open(man, encoding="utf-8") as fh:
        m = json.load(fh)
    icons = m.setdefault("hd", {}).setdefault("icons", {})
    for k in res:
        icons[k] = "res://assets/hd/icons/%s.png" % k
    with open(man, "w", encoding="utf-8", newline=chr(10)) as fh:
        json.dump(m, fh, ensure_ascii=False, indent=1)


if __name__ == "__main__":
    r = build()
    out = os.path.join(ROOT, "docs", "design", "equipment")
    os.makedirs(out, exist_ok=True)
    review(r).convert("RGB").save(os.path.join(out, "doc-nhat.png"))
    if "--apply" in sys.argv:
        apply(r)
    print("unique icons:", len(r))
