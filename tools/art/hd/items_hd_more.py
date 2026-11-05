"""IC-2 (docs/37 §7): 18 icon trang bị HD 128×128 còn thiếu — Bùa hộ mệnh + 17 món độc nhất của boss.

Cùng bộ vẽ và phong cách với 7 icon UI-40 ở icons_hd.py (cel-shade, viền #1a1424 dày 3, nền trong suốt — giao diện vẽ
khung màu phẩm chất). KHÔNG sửa 7 icon đó; chỉ thêm khoá mới vào manifest["hd"]["icons"].

    python tools/art/hd/items_hd_more.py            # ảnh duyệt docs/design/skill-icons/trang-bi-so-sanh.png
    python tools/art/hd/items_hd_more.py --apply    # ghi godot/assets/hd/icons/item-<id>.png + manifest
"""
import json
import math
import os
import sys

from PIL import Image, ImageDraw

from vec import Canvas, Tone, bezier, hexc

S = 128
OUTLINE = "#1a1424"
STEEL = Tone("#c9d4e2", "#7f8ea6", "#ffffff")
GOLD = Tone("#eab64e", "#a8731d", "#fff1b0")
LEATHER = Tone("#8a5a36", "#5a3820", "#b9875c")
RED = Tone("#d9343c", "#8e1c26", "#ff8a80")
BONE = Tone("#efe6d2", "#b9a98a", "#ffffff")
BARK = Tone("#7a5634", "#4e341e", "#a47a50")
MOSS = Tone("#5aa84a", "#2e6a2a", "#9ad87a")
VOID = Tone("#7a4ac8", "#3e1e7a", "#c8a0ff")
VOID_DARK = Tone("#2e1e44", "#170e26", "#5a4280")
ICE = Tone("#9fd8ff", "#4a8ac8", "#e8f8ff")
TEAL = Tone("#2fa89a", "#17645c", "#7ae0d0")
SAND = Tone("#c89a52", "#8a6430", "#ecc888")
VENOM = Tone("#8ae04a", "#3e8a1c", "#d0ff9a")
FIRE = Tone("#ff7a2a", "#c03a10", "#ffd08a")
JADE = Tone("#4ac890", "#1e7a52", "#a8f8d0")
SILK = Tone("#8a5ac8", "#55308a", "#c8a8f0")
STONE = Tone("#8a8a96", "#55556a", "#c0c0cc")
BLACK = Tone("#2a2432", "#141018", "#4a4256")


def _c():
    return Canvas(S, S, light=(-1.0, -1.2))


def _done(c):
    return c.render(outline=OUTLINE, width=3)


def amulet():  # Bùa hộ mệnh: dây đỏ, ngọc bích tròn có lỗ, tua
    c = _c()
    c.part(lambda d: c.ribbon(d, bezier((40, 12), (30, 40), (98, 40), (88, 12), 24), [3.5] * 25), RED, shade_d=1.2)
    c.part(lambda d: c.circle(d, 64, 66, 28), JADE, shade_d=6, light_d=2.5)
    c.part(lambda d: c.circle(d, 64, 66, 9), Tone("#0f3a28", "#0a2418", "#1e5a40"), shade=False)
    c.flat(lambda d: c.ellipse(d, 52, 54, 8, 4, 0.6), "#ffffff", alpha=170)
    c.part(lambda d: c.capsule(d, (64, 94), (64, 102), 5, 5), GOLD, shade_d=1.5)
    for dx in (-6, 0, 6):
        c.part(lambda d, dx=dx: c.capsule(d, (64 + dx * 0.4, 104), (64 + dx, 122), 2.6, 2), RED, shade_d=1)
    return _done(c)


def wolf_fang():  # Nanh Sói Chúa: lưỡi nanh cong + chuôi da
    c = _c()
    blade = bezier((40, 92), (40, 50), (70, 18), (104, 14), 20)
    c.part(lambda d: c.ribbon(d, blade, [14 - 0.68 * i for i in range(21)]), BONE, shade_d=5, light_d=2)
    c.flat(lambda d: c.ribbon(d, bezier((44, 84), (46, 52), (72, 24), (100, 16), 16), [2.5] * 17), "#ffffff", alpha=170)
    c.part(lambda d: c.capsule(d, (24, 92), (56, 92), 6, 6), GOLD, shade_d=2)
    c.part(lambda d: c.capsule(d, (40, 96), (30, 120), 6, 5), LEATHER, shade_d=2)
    for k in range(3):
        c.flat(lambda d, k=k: c.capsule(d, (31 + k * 3, 100 + k * 6), (41 + k * 3, 102 + k * 6), 1.2), "#3a2414")
    c.part(lambda d: c.circle(d, 29, 121, 5), GOLD, shade_d=1.5)
    return _done(c)


def lao_thu_bark():  # Vỏ Lão Thụ: mảnh vỏ cây + rêu + ngọc tím
    c = _c()
    c.part(lambda d: c.poly(d, [(36, 14), (92, 14), (102, 40), (96, 92), (64, 118), (32, 92), (26, 40)]), BARK, shade_d=7, light_d=2.5)
    for x in (46, 62, 78):
        c.flat(lambda d, x=x: c.ribbon(d, bezier((x, 20), (x - 6, 50), (x + 6, 80), (x, 104), 12), [2.2] * 13), "#3e2814", alpha=200)
    c.part(lambda d: (c.ellipse(d, 44, 22, 16, 8), c.ellipse(d, 86, 96, 12, 7)), MOSS, shade_d=2)
    c.glow(lambda d: c.circle(d, 64, 60, 12), "#b070ff", radius=8, alpha=140)
    c.part(lambda d: c.poly(d, [(64, 46), (76, 60), (64, 74), (52, 60)]), VOID, shade_d=4, light_d=2)
    c.flat(lambda d: c.poly(d, [(64, 50), (71, 60), (64, 60)]), "#ffffff", alpha=170)
    return _done(c)


def huyen_anh_mask():  # Mặt Nạ Huyền Ảnh: mặt nạ tím, khe mắt, đường vàng giữa
    c = _c()
    c.part(lambda d: c.poly(d, [(26, 30), (64, 16), (102, 30), (100, 74), (82, 104), (64, 112), (46, 104), (28, 74)]), VOID, shade_d=7, light_d=3)
    for x in (46, 82):
        c.part(lambda d, x=x: c.ellipse(d, x, 56, 12, 5, 0.25 if x < 64 else -0.25), VOID_DARK, shade=False)
    c.glow(lambda d: (c.ellipse(d, 46, 56, 8, 3, 0.25), c.ellipse(d, 82, 56, 8, 3, -0.25)), "#e0a0ff", radius=5, alpha=200)
    c.part(lambda d: c.poly(d, [(62, 16), (66, 16), (66, 112), (62, 112)]), GOLD, shade_d=1)
    c.part(lambda d: c.poly(d, [(26, 30), (102, 30), (100, 38), (28, 38)]), GOLD, shade_d=1.5)
    return _done(c)


def bach_ho_claw():  # Vuốt Bạch Hổ: găng lông trắng sọc đen, 3 vuốt
    c = _c()
    fur = Tone("#f2f0ea", "#b8b4ac", "#ffffff")
    c.part(lambda d: (c.poly(d, [(34, 118), (36, 70), (92, 64), (96, 116)]), c.ellipse(d, 64, 64, 32, 22)), fur, shade_d=7, light_d=2.5)
    for k, x in enumerate((40, 58, 76)):
        c.part(lambda d, x=x: c.poly(d, [(x, 50), (x + 14, 50), (x + 16, 10), (x + 9, 20)]), STEEL, shade_d=3, light_d=1.5)
    for y in (78, 92, 106):
        c.flat(lambda d, y=y: c.poly(d, [(38, y), (60, y - 4), (56, y + 3)]), "#2a2430")
        c.flat(lambda d, y=y: c.poly(d, [(92, y - 2), (70, y - 6), (74, y + 2)]), "#2a2430")
    c.part(lambda d: c.poly(d, [(34, 108), (96, 104), (98, 120), (32, 122)]), GOLD, shade_d=2)
    return _done(c)


def sa_hoang_tail():  # Đuôi Sa Hoàng: roi đuôi bọ cạp nhiều đốt, kim độc
    c = _c()
    pts = bezier((22, 118), (18, 60), (64, 14), (104, 40), 11)
    for i, (x, y) in enumerate(pts[:-1]):
        r = 12.5 - i * 0.65
        c.part(lambda d, x=x, y=y, r=r: c.circle(d, x, y, r), SAND, shade_d=3, light_d=1.5)
        c.flat(lambda d, x=x, y=y, r=r: c.ellipse(d, x - r * 0.3, y - r * 0.35, r * 0.4, r * 0.18), "#fff0c8", alpha=160)
    x, y = pts[-1]
    c.glow(lambda d: c.circle(d, x + 6, y + 14, 10), "#9aff5a", radius=7, alpha=140)
    c.part(lambda d: c.poly(d, [(x - 8, y - 4), (x + 8, y - 2), (x + 10, y + 30), (x + 2, y + 10)]), VENOM, shade_d=3, light_d=1.5)
    c.part(lambda d: c.capsule(d, (20, 108), (26, 124), 7, 7), LEATHER, shade_d=2)
    return _done(c)


def nhan_su_eye():  # Mắt Nhân Sư: mặt dây vàng hình mắt, tròng xanh
    c = _c()
    c.part(lambda d: c.ribbon(d, bezier((22, 14), (20, 70), (108, 70), (106, 14), 30), [4] * 31), GOLD, shade_d=1.5)
    c.part(lambda d: c.poly(d, [(20, 78), (44, 58), (84, 58), (108, 78), (84, 98), (44, 98)]), GOLD, shade_d=5, light_d=2)
    c.part(lambda d: c.poly(d, [(30, 78), (48, 64), (80, 64), (98, 78), (80, 92), (48, 92)]), Tone("#f4f0e4", "#c8c0a8", "#ffffff"), shade_d=2)
    c.glow(lambda d: c.circle(d, 64, 78, 12), "#4ad0ff", radius=6, alpha=160)
    c.part(lambda d: c.circle(d, 64, 78, 12), Tone("#2a9ae0", "#14508e", "#9ae4ff"), shade_d=3)
    c.part(lambda d: c.ellipse(d, 64, 78, 3, 9), BLACK, shade=False)
    c.flat(lambda d: c.circle(d, 59, 73, 3), "#ffffff", alpha=220)
    c.part(lambda d: c.capsule(d, (64, 98), (64, 116), 4, 2), GOLD, shade_d=1)
    return _done(c)


def long_tam():  # Long Tâm: nhẫn đen, tim rồng rực lửa
    c = _c()
    c.part(lambda d: c.ellipse(d, 64, 82, 38, 30), BLACK, shade_d=6, light_d=2.5)
    _hole(c, 64, 86, 26, 18)
    for a in (-0.9, 0.9):
        c.part(lambda d, a=a: c.poly(d, [(64 + 28 * math.sin(a), 56), (64 + 40 * math.sin(a), 40), (64 + 16 * math.sin(a), 50)]), GOLD, shade_d=1.5)
    c.glow(lambda d: c.circle(d, 64, 46, 20), "#ff7a2a", radius=10, alpha=170)
    c.part(lambda d: c.circle(d, 64, 46, 17), FIRE, shade_d=5, light_d=3)
    c.flat(lambda d: c.poly(d, [(64, 34), (72, 48), (64, 60), (56, 48)]), "#ffe8a0", alpha=230)
    c.flat(lambda d: c.circle(d, 58, 40, 3), "#ffffff", alpha=210)
    return _done(c)


def _hole(c, x, y, rx, ry):
    from PIL import ImageChops
    hole = c.mask()
    c.ellipse(ImageDraw.Draw(hole), x, y, rx, ry)
    c.img.putalpha(ImageChops.subtract(c.img.getchannel("A"), hole))


def long_phuong():  # Lông Phượng: lông vũ lửa
    c = _c()
    c.glow(lambda d: c.ellipse(d, 66, 58, 22, 46, -0.6), "#ff8a2a", radius=10, alpha=130)
    vane = [(30, 112)] + bezier((36, 100), (40, 40), (80, 12), (104, 10), 14) + bezier((104, 10), (100, 46), (70, 92), (40, 106), 14)
    c.part(lambda d: c.poly(d, vane), FIRE, shade_d=6, light_d=3)
    c.part(lambda d: c.poly(d, [(56, 70), (88, 22), (98, 18), (92, 32), (62, 76)]), Tone("#ffd84a", "#e09a1a", "#fff4b0"), shade_d=2)
    for k in range(5):
        t = 0.2 + k * 0.14
        x, y = 34 + 66 * t, 104 - 92 * t
        c.flat(lambda d, x=x, y=y: c.capsule(d, (x, y), (x - 12, y - 4), 1.2), "#a8280a", alpha=200)
    c.part(lambda d: c.ribbon(d, bezier((24, 120), (40, 92), (70, 46), (102, 12), 20), [2.4] * 21), GOLD, shade_d=1)
    return _done(c)


def goi_mong():  # Gối Mộng: gối lụa tím + tua vàng + sao
    c = _c()
    c.part(lambda d: c.poly(d, [(20, 52), (40, 40), (88, 40), (108, 52), (108, 84), (88, 96), (40, 96), (20, 84)]), SILK, shade_d=8, light_d=3)
    c.part(lambda d: c.poly(d, [(26, 66), (102, 66), (102, 72), (26, 72)]), GOLD, shade_d=1.5)
    for x, y in ((20, 52), (108, 52), (20, 84), (108, 84)):
        c.part(lambda d, x=x, y=y: c.capsule(d, (x, y), (x + (-6 if x < 64 else 6), y + 14), 3.5, 2), GOLD, shade_d=1)
    for x, y, r in ((50, 54, 4), (80, 82, 3), (86, 54, 2.5)):
        c.flat(lambda d, x=x, y=y, r=r: c.poly(d, [(x, y - r * 2), (x + r * 0.6, y - r * 0.6), (x + r * 2, y), (x + r * 0.6, y + r * 0.6),
                                                    (x, y + r * 2), (x - r * 0.6, y + r * 0.6), (x - r * 2, y), (x - r * 0.6, y - r * 0.6)]), "#fff6c0")
    c.glow(lambda d: c.circle(d, 50, 54, 5), "#fff0a0", radius=5, alpha=150)
    return _done(c)


def vay_that_dau():  # Vảy Thất Đầu: giáp vảy xanh ngọc
    c = _c()
    c.part(lambda d: c.poly(d, [(28, 30), (50, 20), (64, 28), (78, 20), (100, 30), (108, 60), (94, 64), (92, 110), (36, 110),
                                 (34, 64), (20, 60)]), TEAL, shade_d=8, light_d=3)
    for row in range(5):
        y = 44 + row * 13
        for k in range(5 - (row % 2)):
            x = 42 + k * 11 + (row % 2) * 5.5
            c.flat(lambda d, x=x, y=y: c.poly(d, [(x - 5, y), (x + 5, y), (x, y + 8)]), "#0e4a44", alpha=170)
            c.flat(lambda d, x=x, y=y: c.capsule(d, (x - 3, y + 1), (x + 3, y + 1), 0.9), "#9af0e0", alpha=170)
    c.part(lambda d: c.poly(d, [(50, 20), (64, 46), (78, 20), (72, 20), (64, 34), (56, 20)]), GOLD, shade_d=1)
    for x in (28, 100):
        c.part(lambda d, x=x: c.ellipse(d, x, 36, 14, 10), TEAL, shade_d=3)
    return _done(c)


def guong_ban_nga():  # Gương Bản Ngã: gương tròn khung bạc, mặt gương băng phản chiếu
    c = _c()
    c.part(lambda d: c.capsule(d, (64, 100), (64, 122), 6, 8), STEEL, shade_d=2)
    c.part(lambda d: c.circle(d, 64, 56, 44), STEEL, shade_d=6, light_d=2.5)
    c.part(lambda d: c.circle(d, 64, 56, 35), ICE, shade_d=8, light_d=4)
    c.flat(lambda d: c.ellipse(d, 64, 60, 12, 18), "#3a5a8a", alpha=150)
    c.flat(lambda d: c.circle(d, 64, 42, 7), "#3a5a8a", alpha=150)
    c.flat(lambda d: c.poly(d, [(40, 40), (52, 28), (58, 32), (44, 48)]), "#ffffff", alpha=200)
    c.flat(lambda d: c.poly(d, [(76, 80), (86, 70), (88, 74), (80, 84)]), "#ffffff", alpha=170)
    return _done(c)


def vay_long_bang():  # Vảy Long Băng: giày vảy băng
    c = _c()
    c.part(lambda d: (c.poly(d, [(40, 18), (76, 18), (78, 80), (108, 88), (110, 106), (36, 106)]), c.ellipse(d, 94, 96, 18, 12)),
           ICE, shade_d=7, light_d=3)
    for row in range(4):
        for k in range(3):
            x, y = 46 + k * 11 + (row % 2) * 5, 30 + row * 13
            c.flat(lambda d, x=x, y=y: c.poly(d, [(x - 5, y), (x + 5, y), (x, y + 8)]), "#3a72b0", alpha=170)
    c.part(lambda d: c.poly(d, [(36, 100), (112, 100), (112, 110), (36, 110)]), STEEL, shade_d=1)
    for x, h in ((46, 16), (60, 22), (74, 14)):
        c.part(lambda d, x=x, h=h: c.poly(d, [(x - 5, 20), (x + 5, 20), (x, 20 - h)]), Tone("#e8f8ff", "#9fd8ff", "#ffffff"), shade_d=2)
    return _done(c)


def bua_cu_than():  # Búa Cự Thần: búa đá khổng lồ, đai vàng, cán gỗ
    c = _c()
    c.part(lambda d: c.capsule(d, (38, 120), (78, 52), 6, 6), BARK, shade_d=2)
    c.part(lambda d: c.capsule(d, (40, 116), (46, 106), 7, 7), LEATHER, shade_d=1.5)
    head = [(44, 30), (88, 6), (116, 52), (72, 76)]
    c.part(lambda d: c.poly(d, head), STONE, shade_d=8, light_d=3)
    c.part(lambda d: c.poly(d, [(60, 22), (72, 16), (100, 64), (88, 70)]), GOLD, shade_d=2)
    c.glow(lambda d: c.circle(d, 80, 42, 6), "#7ad8ff", radius=6, alpha=170)
    c.part(lambda d: c.poly(d, [(80, 34), (86, 42), (80, 50), (74, 42)]), ICE, shade_d=2)
    return _done(c)


def sung_ky_lan():  # Sừng Kỳ Lân: sừng xoắn trắng vàng + tia sét, dây đeo
    c = _c()
    c.part(lambda d: c.ribbon(d, bezier((20, 30), (24, 80), (64, 96), (104, 70), 24), [3] * 25), LEATHER, shade_d=1)
    horn = [(46, 104), (82, 104), (70, 10)]
    c.glow(lambda d: c.poly(d, horn), "#a8d8ff", radius=8, alpha=120)
    c.part(lambda d: c.poly(d, horn), Tone("#f6f0e0", "#c8b890", "#ffffff"), shade_d=6, light_d=2.5)
    for k in range(5):
        y = 92 - k * 17
        w = 16 - k * 3
        c.flat(lambda d, y=y, w=w: c.capsule(d, (64 - w + 4, y + 4), (64 + w - 2, y - 4), 1.6), "#c8a050", alpha=220)
    c.part(lambda d: c.capsule(d, (44, 106), (84, 106), 5, 5), GOLD, shade_d=1.5)
    c.flat(lambda d: c.poly(d, [(92, 30), (84, 48), (92, 48), (86, 66), (100, 42), (92, 42), (98, 30)]), "#9ae0ff")
    return _done(c)


def an_hu_vo():  # Ấn Hư Vô: nhẫn ấn đen, ngọc hư vô tím
    c = _c()
    c.part(lambda d: c.ellipse(d, 64, 82, 36, 30), VOID_DARK, shade_d=5, light_d=2)
    _hole(c, 64, 86, 24, 18)
    c.part(lambda d: c.poly(d, [(38, 30), (90, 30), (98, 56), (30, 56)]), BLACK, shade_d=3, light_d=1.5)
    c.glow(lambda d: c.circle(d, 64, 42, 14), "#b070ff", radius=10, alpha=200)
    c.part(lambda d: c.circle(d, 64, 42, 12), VOID, shade_d=4, light_d=2.5)
    c.flat(lambda d: c.circle(d, 64, 42, 5), "#1a0a30")
    c.flat(lambda d: c.circle(d, 59, 37, 2.5), "#ffffff", alpha=200)
    return _done(c)


def nanh_hu_vo():  # Nanh Hư Vô: dao găm tinh thể hư vô
    c = _c()
    tip, base = (108, 18), (52, 74)
    c.glow(lambda d: c.poly(d, [tip, (46, 66), (60, 80)]), "#b070ff", radius=8, alpha=150)
    c.part(lambda d: c.poly(d, [tip, (44, 64), (52, 74), (62, 82)]), VOID, shade_d=4, light_d=2)
    c.flat(lambda d: c.poly(d, [tip, (50, 70), (54, 72)]), "#e8d0ff", alpha=200)
    c.part(lambda d: c.capsule(d, (36, 64), (62, 90), 5, 5), VOID_DARK, shade_d=1.5)
    c.part(lambda d: c.capsule(d, (48, 78), (24, 102), 5.5, 5), BLACK, shade_d=1.5)
    c.part(lambda d: c.circle(d, 22, 104, 6), VOID, shade_d=1.5)
    return _done(c)


def mat_na_vo_dien():  # Mặt Nạ Vô Diện: mặt nạ đen trơn, không nét mặt, viền tím
    c = _c()
    c.glow(lambda d: c.ellipse(d, 64, 64, 40, 50), "#9a5aff", radius=9, alpha=150)
    c.part(lambda d: c.ellipse(d, 64, 64, 38, 50), BLACK, shade_d=8, light_d=3)
    c.part(lambda d: c.poly(d, [(40, 34), (88, 34), (84, 40), (44, 40)]), VOID, shade_d=1)
    c.flat(lambda d: c.ellipse(d, 50, 44, 8, 16, 0.3), "#6a5a80", alpha=150)
    c.flat(lambda d: c.capsule(d, (64, 20), (64, 108), 1.2), "#7a4ac8", alpha=150)
    return _done(c)


ITEMS = {
    "item-amulet": amulet, "item-wolf_fang": wolf_fang, "item-lao_thu_bark": lao_thu_bark, "item-huyen_anh_mask": huyen_anh_mask,
    "item-bach_ho_claw": bach_ho_claw, "item-sa_hoang_tail": sa_hoang_tail, "item-nhan_su_eye": nhan_su_eye,
    "item-long_tam": long_tam, "item-long_phuong": long_phuong, "item-goi_mong": goi_mong, "item-vay_that_dau": vay_that_dau,
    "item-guong_ban_nga": guong_ban_nga, "item-vay_long_bang": vay_long_bang, "item-bua_cu_than": bua_cu_than,
    "item-sung_ky_lan": sung_ky_lan, "item-an_hu_vo": an_hu_vo, "item-nanh_hu_vo": nanh_hu_vo,
    "item-mat_na_vo_dien": mat_na_vo_dien,
}

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(HERE)))
ASSETS = os.path.join(ROOT, "godot", "assets")


def build():
    return {k: fn() for k, fn in ITEMS.items()}


def review(icons, path=None):
    S2 = 96
    m = json.load(open(os.path.join(ASSETS, "art_manifest.json"), encoding="utf-8"))["icons"]
    sheet = Image.new("RGBA", (9 * (S2 + 10) + 10, 4 * (S2 + 22) + 30), hexc("#241c2c"))
    d = ImageDraw.Draw(sheet)
    d.text((8, 4), "Trang bi - hang 1/3: icon cu, hang 2/4: IC-2 (HD)", fill=(235, 235, 240))
    for i, (k, img) in enumerate(icons.items()):
        row, col = divmod(i, 9)
        x, y = 10 + col * (S2 + 10), 22 + row * 2 * (S2 + 22)
        old = Image.open(m[k].replace("res://", os.path.join(ROOT, "godot") + "/")).convert("RGBA").resize((S2, S2), Image.NEAREST)
        sheet.alpha_composite(old, (x, y))
        sheet.alpha_composite(img.resize((S2, S2), Image.LANCZOS), (x, y + S2 + 4))
        d.text((x, y + 2 * S2 + 6), k[5:][:16], fill=(120, 170, 255))
    sheet.convert("RGB").save(path or os.path.join(ROOT, "docs", "design", "skill-icons", "trang-bi-so-sanh.png"))


def apply(icons):
    dst = os.path.join(ASSETS, "hd", "icons")
    path = os.path.join(ASSETS, "art_manifest.json")
    m = json.load(open(path, encoding="utf-8"))
    hd = m.setdefault("hd", {}).setdefault("icons", {})
    for k, img in icons.items():
        assert k not in ("item-weapon", "item-helm", "item-armor", "item-gloves", "item-boots", "item-necklace", "item-ring")
        img.save(os.path.join(dst, k + ".png"), optimize=True)
        hd[k] = "res://assets/hd/icons/%s.png" % k
    with open(path, "w", encoding="utf-8", newline=chr(10)) as f:
        json.dump(m, f, ensure_ascii=False, indent=1)


if __name__ == "__main__":
    icons = build()
    out = None
    for a in sys.argv:
        if a.startswith("--out="):
            out = a[6:]
    review(icons, out)
    if "--apply" in sys.argv:
        apply(icons)
    print("ok: %d icon trang bi%s" % (len(icons), " (applied)" if "--apply" in sys.argv else ""))
