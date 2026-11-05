"""IC-2 (docs/37 §8): 14 icon tài nguyên + 24 icon chỉ số HD 128×128.

Cùng bộ vẽ / phong cách với icon UI-40 (icons_hd.py) và items_hd_more.py: cel-shade, viền #1a1424 dày 3, nền trong suốt.
Giữ ý của icon cũ 32 px (tools/art/icons.py). KHÔNG sửa res-gold / res-potion / res-mp_potion (UI-40). Chân dung
portrait-* là hình nhân vật của chủ dự án → không vẽ lại.

    python tools/art/hd/res_stat_hd.py            # ảnh duyệt docs/design/skill-icons/tai-nguyen-chi-so-so-sanh.png
    python tools/art/hd/res_stat_hd.py --apply    # ghi godot/assets/hd/icons/<id>.png + manifest["hd"]["icons"]
"""
import json
import math
import os
import sys

from PIL import Image, ImageDraw

from vec import Canvas, Tone, bezier, hexc
from items_hd_more import (BARK, BLACK, FIRE, GOLD, ICE, JADE, LEATHER, MOSS, OUTLINE, RED, STEEL, STONE, VOID, VOID_DARK,
                           BONE, _hole)

S = 128
BLUE = Tone("#3d8ae6", "#1f4f9e", "#9fd0ff")
GLASS = Tone("#e8f1f8", "#a9bccd", "#ffffff")
SILVER = Tone("#dfe6ee", "#9aa6b6", "#ffffff")
IRON = Tone("#8a92a0", "#555c6a", "#b8c0cc")
AMBER = Tone("#ff9a2a", "#c0500e", "#ffe08a")
GREEN = Tone("#4cbf5a", "#257a34", "#a8f0a0")
PURPLE = Tone("#9a5ae0", "#5a2a9a", "#d8b0ff")
CRIMSON = Tone("#d8343c", "#8a1820", "#ff9a9a")
WHITE = Tone("#f4f4f8", "#b8bcc8", "#ffffff")
BOOK = Tone("#2f6ad8", "#1a3c8a", "#8ab8ff")
PAPER = Tone("#f2e8d0", "#c8b890", "#ffffff")


def _c():
    return Canvas(S, S, light=(-1.0, -1.2))


def _done(c):
    return c.render(outline=OUTLINE, width=3)


def _star_pts(cx, cy, r, n=5, inner=0.45, rot=-math.pi / 2):
    pts = []
    for i in range(n * 2):
        rr = r if i % 2 == 0 else r * inner
        a = rot + i * math.pi / n
        pts.append((cx + math.cos(a) * rr, cy + math.sin(a) * rr))
    return pts


def _heart_pts(cx, cy, s):
    pts = []
    for i in range(48):
        t = i / 48 * math.tau
        x = 16 * math.sin(t) ** 3
        y = -(13 * math.cos(t) - 5 * math.cos(2 * t) - 2 * math.cos(3 * t) - math.cos(4 * t))
        pts.append((cx + x * s / 16, cy + y * s / 16))
    return pts


def _drop_pts(cx, cy, r):
    pts = [(cx, cy - r * 1.7)]
    for i in range(17):
        a = -0.15 * math.pi + i * (1.3 * math.pi) / 16
        pts.append((cx + math.cos(a) * r, cy + math.sin(a) * r))
    return pts


def _shield_pts(cx, cy, s):
    return [(cx - s, cy - s), (cx, cy - s * 1.2), (cx + s, cy - s), (cx + s * 0.92, cy + s * 0.25), (cx, cy + s * 1.25),
            (cx - s * 0.92, cy + s * 0.25)]


def _sparkle(c, x, y, r, col="#ffffff", alpha=230):
    c.flat(lambda d: c.poly(d, [(x, y - r), (x + r * 0.25, y - r * 0.25), (x + r, y), (x + r * 0.25, y + r * 0.25), (x, y + r),
                                (x - r * 0.25, y + r * 0.25), (x - r, y), (x - r * 0.25, y - r * 0.25)]), col, alpha=alpha)


def _bottle(c, tone, glow):
    c.glow(lambda d: c.circle(d, 64, 80, 32), glow, radius=8, alpha=100)
    c.part(lambda d: (c.circle(d, 64, 80, 30), c.poly(d, [(54, 38), (74, 38), (76, 58), (52, 58)])), GLASS, shade_d=4, light_d=2)
    c.part(lambda d: c.circle(d, 64, 84, 25), tone, shade_d=6, light_d=3)
    c.part(lambda d: c.poly(d, [(52, 26), (76, 26), (74, 40), (54, 40)]), Tone("#b07c4c", "#7a522e", "#d9a878"), shade_d=2)
    c.flat(lambda d: c.ellipse(d, 52, 74, 5, 11, 0.4), "#ffffff", alpha=200)


def _boot(c, tone):
    c.part(lambda d: (c.poly(d, [(46, 22), (78, 22), (80, 78), (106, 86), (108, 104), (42, 104)]), c.ellipse(d, 92, 94, 16, 11)),
           tone, shade_d=7, light_d=2.5)
    c.part(lambda d: c.poly(d, [(42, 98), (110, 98), (110, 108), (42, 108)]), Tone("#3a2a22", "#22180f", "#5e463a"), shade_d=1)


# ================================================================ tài nguyên
def wood():
    c = _c()
    for y, x0 in ((84, 20), (60, 30), (36, 24)):
        c.part(lambda d, y=y, x0=x0: c.capsule(d, (x0 + 10, y), (x0 + 74, y), 13, 13), BARK, shade_d=4, light_d=1.5)
        c.part(lambda d, y=y, x0=x0: c.ellipse(d, x0 + 84, y, 9, 13), Tone("#d8a868", "#a07040", "#f0d0a0"), shade_d=2)
        c.flat(lambda d, y=y, x0=x0: c.ellipse(d, x0 + 84, y, 4, 6), "#8a5a30", alpha=200)
    return _done(c)


def stone():
    c = _c()
    c.part(lambda d: c.poly(d, [(64, 12), (92, 40), (84, 108), (44, 108), (36, 40)]), BLUE, shade_d=7, light_d=3)
    c.flat(lambda d: c.poly(d, [(64, 12), (64, 108), (44, 108), (36, 40)]), "#ffffff", alpha=50)
    c.flat(lambda d: c.poly(d, [(54, 30), (62, 22), (60, 70), (52, 64)]), "#ffffff", alpha=150)
    return _done(c)


def essence():
    c = _c()
    c.glow(lambda d: c.circle(d, 64, 64, 30), "#ffd860", radius=14, alpha=200)
    c.flat(lambda d: c.poly(d, _star_pts(64, 64, 56, 4, 0.12)), "#fff4c0", alpha=230)
    c.part(lambda d: c.circle(d, 64, 64, 18), Tone("#ffe070", "#e0a020", "#ffffff"), shade_d=4, light_d=3)
    c.flat(lambda d: c.circle(d, 64, 64, 9), "#ffffff", alpha=240)
    return _done(c)


def tinh_kim():
    c = _c()
    c.part(lambda d: c.poly(d, [(14, 90), (34, 56), (94, 56), (114, 90)]), SILVER, shade_d=6, light_d=3)
    c.part(lambda d: c.poly(d, [(34, 56), (94, 56), (88, 46), (40, 46)]), Tone("#ffffff", "#cfd8e2", "#ffffff"), shade_d=1)
    c.flat(lambda d: c.capsule(d, (40, 70), (86, 70), 2), "#ffffff", alpha=160)
    _sparkle(c, 98, 40, 9)
    return _done(c)


def torch():
    c = _c()
    c.part(lambda d: c.capsule(d, (64, 52), (60, 120), 7, 5), BARK, shade_d=2)
    c.part(lambda d: c.capsule(d, (54, 52), (74, 52), 5, 5), IRON, shade_d=1.5)
    c.glow(lambda d: c.circle(d, 64, 32, 22), "#ff9a2a", radius=12, alpha=170)
    c.part(lambda d: c.poly(d, [(64, 4), (82, 30), (76, 50), (52, 50), (46, 30), (58, 18)]), AMBER, shade_d=4, light_d=3)
    c.flat(lambda d: c.poly(d, [(64, 22), (72, 36), (64, 48), (57, 36)]), "#fff4b0", alpha=230)
    return _done(c)


def herb():
    c = _c()
    c.part(lambda d: c.ribbon(d, bezier((64, 120), (60, 90), (70, 60), (64, 20), 16), [4] * 17), Tone("#3a8a3a", "#205a22", "#7ad070"), shade_d=1)
    for x, y, a in ((40, 46, 0.5), (88, 40, -0.5), (38, 80, 0.4), (90, 74, -0.4), (64, 18, 0.0)):
        c.part(lambda d, x=x, y=y, a=a: c.ellipse(d, x, y, 18, 9, a), GREEN, shade_d=3, light_d=1.5)
    for x, y in ((64, 18), (40, 46)):
        c.part(lambda d, x=x, y=y: c.circle(d, x, y, 5), Tone("#ffd84a", "#e09a1a", "#fff4b0"), shade_d=1)
    return _done(c)


def ore():
    c = _c()
    for x, y, r in ((40, 80, 24), (86, 82, 22), (62, 54, 24)):
        c.part(lambda d, x=x, y=y, r=r: c.poly(d, [(x - r, y + 4), (x - r * 0.6, y - r * 0.7), (x + r * 0.4, y - r), (x + r, y - r * 0.1),
                                                   (x + r * 0.7, y + r * 0.8), (x - r * 0.5, y + r * 0.8)]), STONE, shade_d=6, light_d=2.5)
    for x, y in ((54, 50), (72, 60), (36, 80), (92, 78)):
        c.flat(lambda d, x=x, y=y: c.circle(d, x, y, 3.2), "#e8a050", alpha=230)
    return _done(c)


def iron():
    c = _c()
    for y, x in ((88, 14), (88, 62), (60, 38)):
        c.part(lambda d, y=y, x=x: c.poly(d, [(x, y), (x + 10, y - 20), (x + 46, y - 20), (x + 54, y)]), IRON, shade_d=5, light_d=2)
        c.part(lambda d, y=y, x=x: c.poly(d, [(x + 10, y - 20), (x + 46, y - 20), (x + 42, y - 26), (x + 14, y - 26)]), SILVER, shade_d=1)
    return _done(c)


def crystal():
    c = _c()
    c.glow(lambda d: c.circle(d, 64, 70, 30), "#ff7a2a", radius=10, alpha=140)
    c.part(lambda d: c.poly(d, [(14, 116), (114, 116), (108, 104), (20, 104)]), STONE, shade_d=2)
    for x, h, w in ((36, 50, 11), (88, 56, 12), (62, 90, 16), (48, 36, 8), (78, 40, 8)):
        c.part(lambda d, x=x, h=h, w=w: c.poly(d, [(x - w, 106), (x - w, 106 - h * 0.7), (x, 106 - h), (x + w, 106 - h * 0.7), (x + w, 106)]),
               FIRE, shade_d=4, light_d=2)
    c.flat(lambda d: c.poly(d, [(58, 30), (62, 24), (62, 90), (58, 90)]), "#fff0b0", alpha=170)
    return _done(c)


def holy_water():
    c = _c()
    _bottle(c, Tone("#7ad0ff", "#2a7ac8", "#d8f4ff"), "#9ae0ff")
    _sparkle(c, 64, 84, 10)
    return _done(c)


def ember():
    c = _c()
    c.part(lambda d: c.poly(d, [(22, 60), (106, 60), (96, 104), (32, 104)]), IRON, shade_d=5, light_d=2)
    c.part(lambda d: c.capsule(d, (24, 60), (104, 60), 5, 5), Tone("#6a6e7a", "#3e424e", "#9aa0ac"), shade_d=1)
    c.glow(lambda d: c.ellipse(d, 64, 54, 34, 14), "#ff6a1a", radius=10, alpha=200)
    for x, y in ((44, 54), (64, 48), (84, 54), (54, 44), (74, 44)):
        c.part(lambda d, x=x, y=y: c.circle(d, x, y, 10), Tone("#3a2a24", "#1e1410", "#6a4a3a"), shade_d=2)
        c.flat(lambda d, x=x, y=y: c.circle(d, x + 2, y + 1, 4.5), "#ff8a2a", alpha=230)
    return _done(c)


def feather():
    c = _c()
    vane = [(28, 112)] + bezier((34, 98), (36, 40), (80, 12), (106, 8), 14) + bezier((106, 8), (102, 48), (70, 94), (38, 104), 14)
    c.part(lambda d: c.poly(d, vane), WHITE, shade_d=6, light_d=3)
    for k in range(5):
        t = 0.2 + k * 0.14
        x, y = 32 + 70 * t, 106 - 96 * t
        c.flat(lambda d, x=x, y=y: c.capsule(d, (x, y), (x - 12, y - 5), 1.1), "#9aa8c0", alpha=180)
    c.part(lambda d: c.ribbon(d, bezier((22, 122), (40, 92), (72, 44), (104, 10), 20), [2.4] * 21), Tone("#c8d4e8", "#8a98b4", "#ffffff"), shade_d=1)
    return _done(c)


def lantern():
    c = _c()
    c.part(lambda d: c.ribbon(d, bezier((50, 22), (50, 4), (78, 4), (78, 22), 12), [3] * 13), IRON, shade_d=1)
    c.glow(lambda d: c.ellipse(d, 64, 70, 26, 34), "#ffe08a", radius=12, alpha=200)
    c.part(lambda d: c.poly(d, [(40, 26), (88, 26), (82, 34), (46, 34)]), IRON, shade_d=1.5)
    c.part(lambda d: c.poly(d, [(46, 34), (82, 34), (86, 102), (42, 102)]), Tone("#fff4c0", "#f0c860", "#ffffff"), shade_d=5, light_d=3)
    c.part(lambda d: c.poly(d, [(38, 102), (90, 102), (86, 114), (42, 114)]), IRON, shade_d=1.5)
    for x in (46, 82):
        c.part(lambda d, x=x: c.capsule(d, (x, 34), (x + (2 if x > 64 else -2), 102), 3, 3), IRON, shade_d=1)
    c.flat(lambda d: c.ellipse(d, 64, 72, 8, 14), "#ffffff", alpha=220)
    return _done(c)


def void_core():
    c = _c()
    c.glow(lambda d: c.circle(d, 64, 64, 34), "#a060ff", radius=12, alpha=180)
    c.part(lambda d: c.poly(d, [(64, 10), (100, 54), (64, 118), (28, 54)]), VOID, shade_d=7, light_d=3)
    c.flat(lambda d: c.poly(d, [(64, 10), (64, 118), (28, 54)]), "#ffffff", alpha=40)
    c.part(lambda d: c.circle(d, 64, 60, 12), VOID_DARK, shade=False)
    c.flat(lambda d: c.circle(d, 64, 60, 5), "#e0c0ff", alpha=230)
    return _done(c)


# ================================================================ chỉ số
def st_str():  # Sức mạnh: nắm đấm đỏ
    c = _c()
    c.part(lambda d: c.poly(d, [(30, 56), (98, 56), (100, 98), (86, 116), (40, 116), (28, 96)]), CRIMSON, shade_d=7, light_d=2.5)
    for k in range(4):
        x = 38 + k * 16
        c.part(lambda d, x=x: c.capsule(d, (x, 44), (x, 62), 9, 9), CRIMSON, shade_d=2.5, light_d=1.5)
    c.part(lambda d: c.capsule(d, (26, 72), (54, 82), 9, 9), CRIMSON, shade_d=2.5)
    c.part(lambda d: c.poly(d, [(38, 104), (90, 104), (88, 120), (40, 120)]), GOLD, shade_d=1.5)
    return _done(c)


def st_agi():  # Nhanh nhẹn: giày + vệt tốc độ
    c = _c()
    for y, x0 in ((40, 6), (58, 0), (76, 10)):
        c.flat(lambda d, y=y, x0=x0: c.capsule(d, (x0, y), (x0 + 30, y), 3), "#9ae0c8", alpha=220)
    _boot(c, Tone("#3e8a5a", "#205a38", "#7ad09a"))
    return _done(c)


def st_int():  # Trí tuệ: sách phép
    c = _c()
    c.part(lambda d: c.poly(d, [(30, 20), (96, 14), (102, 104), (36, 112)]), BOOK, shade_d=6, light_d=2.5)
    c.part(lambda d: c.poly(d, [(36, 112), (102, 104), (104, 112), (38, 120)]), PAPER, shade_d=1)
    c.part(lambda d: c.poly(d, [(30, 20), (38, 18), (44, 114), (36, 112)]), Tone("#1a3c8a", "#0e2050", "#3a6ad8"), shade=False)
    c.glow(lambda d: c.circle(d, 68, 60, 12), "#9ad0ff", radius=6, alpha=160)
    c.flat(lambda d: c.poly(d, _star_pts(68, 60, 14, 4, 0.3)), "#e8f4ff")
    return _done(c)


def st_vit():  # Thể lực: khiên vàng viền đỏ
    c = _c()
    c.part(lambda d: c.poly(d, _shield_pts(64, 56, 42)), GOLD, shade_d=7, light_d=3)
    c.part(lambda d: c.poly(d, _shield_pts(64, 58, 30)), CRIMSON, shade_d=5, light_d=2)
    c.flat(lambda d: c.poly(d, _heart_pts(64, 60, 13)), "#ffd0d0", alpha=230)
    return _done(c)


def st_luk():  # May mắn: chùm cỏ tím
    c = _c()
    c.part(lambda d: c.ribbon(d, bezier((70, 66), (84, 86), (94, 100), (104, 118), 12), [3] * 13), Tone("#4a8a3a", "#2a5a22", "#8ad070"), shade_d=1)
    for x, y in ((48, 36), (76, 32), (40, 62), (70, 60), (56, 86), (90, 50)):
        c.part(lambda d, x=x, y=y: c.circle(d, x, y, 15), PURPLE, shade_d=4, light_d=2)
        c.flat(lambda d, x=x, y=y: c.circle(d, x - 5, y - 5, 3.5), "#ffffff", alpha=180)
    return _done(c)


def st_wis():  # Thông thái: đèn pháp sư tím
    c = _c()
    c.part(lambda d: c.ellipse(d, 64, 104, 40, 12), Tone("#3a6ad8", "#1a3c8a", "#8ab8ff"), shade_d=3)
    c.part(lambda d: c.poly(d, [(46, 100), (82, 100), (74, 64), (54, 64)]), PURPLE, shade_d=4, light_d=2)
    c.glow(lambda d: c.circle(d, 64, 46, 16), "#d8a0ff", radius=10, alpha=200)
    c.part(lambda d: c.poly(d, [(64, 10), (78, 40), (64, 64), (50, 40)]), Tone("#f0d0ff", "#b070f0", "#ffffff"), shade_d=3, light_d=2)
    return _done(c)


def st_dex():  # Khéo léo: bia + mũi tên
    c = _c()
    c.part(lambda d: c.circle(d, 58, 68, 46), WHITE, shade_d=6, light_d=2)
    c.part(lambda d: c.circle(d, 58, 68, 34), CRIMSON, shade_d=4)
    c.part(lambda d: c.circle(d, 58, 68, 22), WHITE, shade_d=2)
    c.part(lambda d: c.circle(d, 58, 68, 11), CRIMSON, shade_d=1.5)
    c.part(lambda d: c.capsule(d, (60, 66), (110, 16), 3, 3), BARK, shade_d=1)
    c.part(lambda d: c.poly(d, [(104, 10), (122, 4), (116, 22)]), GREEN, shade_d=1)
    return _done(c)


def st_atk():  # Công: kiếm
    c = _c()
    c.part(lambda d: c.poly(d, [(36, 84), (102, 18), (110, 26), (44, 92)]), STEEL, shade_d=3, light_d=1.5)
    c.flat(lambda d: c.poly(d, [(40, 86), (104, 22), (106, 24), (42, 88)]), "#ffffff", alpha=200)
    c.part(lambda d: c.capsule(d, (26, 76), (52, 102), 6, 6), GOLD, shade_d=2)
    c.part(lambda d: c.capsule(d, (38, 90), (18, 110), 5, 5), LEATHER, shade_d=1.5)
    c.part(lambda d: c.circle(d, 16, 112, 6), GOLD, shade_d=1.5)
    return _done(c)


def st_def():  # Thủ: khiên thép xanh
    c = _c()
    c.part(lambda d: c.poly(d, _shield_pts(64, 56, 42)), STEEL, shade_d=7, light_d=3)
    c.part(lambda d: c.poly(d, _shield_pts(64, 58, 30)), Tone("#4a7ad8", "#2a4a9a", "#9ac0ff"), shade_d=5, light_d=2)
    c.part(lambda d: c.capsule(d, (64, 34), (64, 86), 3, 3), STEEL, shade_d=1)
    return _done(c)


def st_hp():  # Máu: trái tim
    c = _c()
    c.part(lambda d: c.poly(d, _heart_pts(64, 66, 46)), RED, shade_d=7, light_d=3)
    c.flat(lambda d: c.ellipse(d, 42, 44, 10, 6, -0.6), "#ffffff", alpha=200)
    return _done(c)


def st_mp():  # Pháp lực: giọt xanh
    c = _c()
    c.part(lambda d: c.poly(d, _drop_pts(64, 76, 34)), BLUE, shade_d=7, light_d=3)
    c.flat(lambda d: c.ellipse(d, 52, 72, 6, 12, 0.3), "#ffffff", alpha=200)
    return _done(c)


def st_aspd():  # Tốc đánh: vệt gió + vòng cung
    c = _c()
    for y, x0, ln in ((36, 10, 70), (64, 4, 86), (92, 10, 70)):
        c.part(lambda d, y=y, x0=x0, ln=ln: c.capsule(d, (x0, y), (x0 + ln, y), 4, 6), Tone("#dff4ff", "#9ac8e8", "#ffffff"), shade_d=1.5)
    c.part(lambda d: c.ribbon(d, bezier((92, 18), (130, 40), (130, 88), (92, 110), 20), [3 + i * 0.25 for i in range(21)]), STEEL, shade_d=2)
    return _done(c)


def st_crit():  # Chí mạng: ngôi sao vàng
    c = _c()
    c.glow(lambda d: c.poly(d, _star_pts(64, 66, 48)), "#ffd040", radius=8, alpha=130)
    c.part(lambda d: c.poly(d, _star_pts(64, 66, 50)), GOLD, shade_d=6, light_d=3)
    return _done(c)


def st_critdmg():  # ST chí mạng: tia nổ
    c = _c()
    c.glow(lambda d: c.circle(d, 64, 64, 30), "#ff8a2a", radius=10, alpha=170)
    c.part(lambda d: c.poly(d, _star_pts(64, 64, 56, 8, 0.45, 0.2)), AMBER, shade_d=6, light_d=3)
    c.part(lambda d: c.poly(d, _star_pts(64, 64, 28, 8, 0.5)), Tone("#fff4b0", "#ffd04a", "#ffffff"), shade_d=2)
    c.part(lambda d: c.circle(d, 64, 64, 8), CRIMSON, shade_d=1)
    return _done(c)


def st_eva():  # Né: lá bay
    c = _c()
    for y, x0 in ((80, 6), (98, 18)):
        c.flat(lambda d, y=y, x0=x0: c.capsule(d, (x0, y), (x0 + 30, y - 8), 2.5), "#b8f0c0", alpha=200)
    c.part(lambda d: c.poly(d, [(30, 100)] + bezier((40, 70), (70, 20), (112, 14), (114, 14), 12)[1:] + bezier((114, 14), (100, 60), (70, 100), (30, 100), 12)), GREEN, shade_d=5, light_d=2.5)
    c.part(lambda d: c.ribbon(d, bezier((30, 100), (60, 70), (90, 40), (112, 16), 16), [2] * 17), Tone("#2a7a34", "#185020", "#6ac070"), shade=False)
    return _done(c)


def st_regen():  # Hồi phục: giọt + mũi tên vòng
    c = _c()
    c.part(lambda d: c.poly(d, _drop_pts(54, 78, 26)), BLUE, shade_d=5, light_d=2.5)
    c.part(lambda d: c.ribbon(d, bezier((92, 108), (122, 80), (118, 36), (88, 22), 20), [4] * 21), GREEN, shade_d=1.5)
    c.part(lambda d: c.poly(d, [(80, 10), (98, 16), (86, 34)]), GREEN, shade_d=1)
    return _done(c)


def st_skill():  # Kỹ năng: lấp lánh tím
    c = _c()
    c.glow(lambda d: c.circle(d, 64, 64, 22), "#c890ff", radius=12, alpha=200)
    c.part(lambda d: c.poly(d, _star_pts(64, 64, 54, 4, 0.22)), Tone("#c8a0ff", "#7a4ad0", "#ffffff"), shade_d=5, light_d=3)
    _sparkle(c, 100, 28, 10)
    _sparkle(c, 28, 100, 7)
    return _done(c)


def st_drop():  # Tỉ lệ rơi đồ: túi tiền
    c = _c()
    c.part(lambda d: (c.circle(d, 64, 82, 36), c.poly(d, [(50, 46), (78, 46), (84, 58), (44, 58)])), LEATHER, shade_d=7, light_d=2.5)
    c.part(lambda d: c.poly(d, [(46, 30), (82, 30), (76, 46), (52, 46)]), LEATHER, shade_d=2)
    c.part(lambda d: c.capsule(d, (44, 48), (84, 48), 4, 4), GOLD, shade_d=1)
    c.part(lambda d: c.circle(d, 64, 84, 14), GOLD, shade_d=3, light_d=2)
    c.flat(lambda d: c.poly(d, [(60, 74), (68, 74), (68, 94), (60, 94)]), "#a8731d", alpha=200)
    return _done(c)


def st_move():  # Tốc chạy: giày có cánh
    c = _c()
    _boot(c, LEATHER)
    for k in range(3):
        c.part(lambda d, k=k: c.ellipse(d, 34 - k * 4, 40 + k * 12, 20 - k * 3, 6, -0.5), WHITE, shade_d=2)
    return _done(c)


def st_res():  # Kháng: 5 hạt nguyên tố
    c = _c()
    for (x, y), tone in zip(((64, 22), (104, 54), (88, 102), (40, 102), (24, 54)),
                            (WHITE, JADE, BLUE, Tone("#ff6a2a", "#b0300e", "#ffd08a"), Tone("#c89a52", "#8a6430", "#ecc888"))):
        c.part(lambda d, x=x, y=y, tone=tone: c.circle(d, x, y, 16), tone, shade_d=4, light_d=2)
        c.flat(lambda d, x=x, y=y: c.circle(d, x - 5, y - 5, 4), "#ffffff", alpha=190)
    return _done(c)


def st_respec():  # Tẩy điểm: 2 mũi tên vòng
    c = _c()
    c.part(lambda d: c.ribbon(d, bezier((24, 62), (24, 16), (100, 16), (100, 52), 20), [7] * 21), GOLD, shade_d=2)
    c.part(lambda d: c.poly(d, [(84, 48), (116, 48), (100, 72)]), GOLD, shade_d=1.5)
    c.part(lambda d: c.ribbon(d, bezier((104, 66), (104, 112), (28, 112), (28, 76), 20), [7] * 21), GOLD, shade_d=2)
    c.part(lambda d: c.poly(d, [(12, 80), (44, 80), (28, 56)]), GOLD, shade_d=1.5)
    return _done(c)


def st_auto():  # Tự cộng điểm: 3 nút nối
    c = _c()
    pts = ((64, 22), (106, 98), (22, 98))
    for i in range(3):
        a, b = pts[i], pts[(i + 1) % 3]
        c.part(lambda d, a=a, b=b: c.capsule(d, a, b, 5, 5), BARK, shade_d=1.5)
    for x, y in pts:
        c.part(lambda d, x=x, y=y: c.circle(d, x, y, 15), Tone("#8a5a36", "#5a3820", "#c8986c"), shade_d=4, light_d=2)
    return _done(c)


def st_set():  # Bộ trang bị: chùm ngọc lục
    c = _c()
    for x, y in ((64, 34), (92, 56), (82, 90), (46, 90), (36, 56), (64, 64)):
        c.part(lambda d, x=x, y=y: c.circle(d, x, y, 19), GREEN, shade_d=4, light_d=2)
        c.flat(lambda d, x=x, y=y: c.circle(d, x - 6, y - 6, 4.5), "#e8ffd8", alpha=190)
    return _done(c)


def st_main():  # Chỉ số chính: vương miện
    c = _c()
    c.part(lambda d: c.poly(d, [(16, 96), (22, 40), (44, 68), (64, 24), (84, 68), (106, 40), (112, 96)]), GOLD, shade_d=7, light_d=3)
    c.part(lambda d: c.poly(d, [(16, 92), (112, 92), (110, 110), (18, 110)]), GOLD, shade_d=2)
    for x, tone in ((40, RED), (64, BLUE), (88, RED)):
        c.part(lambda d, x=x, tone=tone: c.circle(d, x, 101, 6), tone, shade_d=1.5)
    for x, y in ((22, 40), (64, 24), (106, 40)):
        c.part(lambda d, x=x, y=y: c.circle(d, x, y, 6), Tone("#ffffff", "#c8d4e8", "#ffffff"), shade_d=1)
    return _done(c)


ICONS = {
    "res-wood": wood, "res-stone": stone, "res-essence": essence, "res-tinh_kim": tinh_kim, "res-torch": torch,
    "res-herb": herb, "res-ore": ore, "res-iron": iron, "res-crystal": crystal, "res-holy_water": holy_water,
    "res-ember": ember, "res-feather": feather, "res-lantern": lantern, "res-void_core": void_core,
    "stat-str": st_str, "stat-agi": st_agi, "stat-int": st_int, "stat-vit": st_vit, "stat-luk": st_luk, "stat-wis": st_wis,
    "stat-dex": st_dex, "stat-atk": st_atk, "stat-def": st_def, "stat-hp": st_hp, "stat-mp": st_mp, "stat-aspd": st_aspd,
    "stat-crit": st_crit, "stat-critdmg": st_critdmg, "stat-eva": st_eva, "stat-regen": st_regen, "stat-skill": st_skill,
    "stat-drop": st_drop, "stat-move": st_move, "stat-res": st_res, "stat-respec": st_respec, "stat-auto": st_auto,
    "stat-set": st_set, "stat-main": st_main,
}
UI40 = ("res-gold", "res-potion", "res-mp_potion")

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(HERE)))
ASSETS = os.path.join(ROOT, "godot", "assets")


def build():
    return {k: fn() for k, fn in ICONS.items()}


def review(icons, path=None):
    S2 = 80
    m = json.load(open(os.path.join(ASSETS, "art_manifest.json"), encoding="utf-8"))["icons"]
    cols = 13
    rows = (len(icons) + cols - 1) // cols
    sheet = Image.new("RGBA", (cols * (S2 + 10) + 10, rows * 2 * (S2 + 18) + 30), hexc("#241c2c"))
    d = ImageDraw.Draw(sheet)
    d.text((8, 4), "Tai nguyen + chi so - hang tren: icon cu, hang duoi: IC-2 (HD)", fill=(235, 235, 240))
    for i, (k, img) in enumerate(icons.items()):
        row, col = divmod(i, cols)
        x, y = 10 + col * (S2 + 10), 22 + row * 2 * (S2 + 18)
        old = Image.open(m[k].replace("res://", os.path.join(ROOT, "godot") + "/")).convert("RGBA").resize((S2, S2), Image.NEAREST)
        sheet.alpha_composite(old, (x, y))
        sheet.alpha_composite(img.resize((S2, S2), Image.LANCZOS), (x, y + S2 + 4))
        d.text((x, y + 2 * S2 + 4), k.split("-", 1)[1][:13], fill=(120, 170, 255))
    sheet.convert("RGB").save(path or os.path.join(ROOT, "docs", "design", "skill-icons", "tai-nguyen-chi-so-so-sanh.png"))


def apply(icons):
    dst = os.path.join(ASSETS, "hd", "icons")
    path = os.path.join(ASSETS, "art_manifest.json")
    m = json.load(open(path, encoding="utf-8"))
    hd = m.setdefault("hd", {}).setdefault("icons", {})
    for k, img in icons.items():
        assert k not in UI40 and not k.startswith("portrait-")
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
    print("ok: %d icon tai nguyen / chi so%s" % (len(icons), " (applied)" if "--apply" in sys.argv else ""))
