"""UI-40 G0: 10 icon HD 128×128 (cel-shade, nền trong suốt — giao diện vẽ khung màu phẩm chất như cũ)."""
import math

from vec import Canvas, Tone, bezier, hexc

S = 128
OUTLINE = "#1a1424"
STEEL = Tone("#c9d4e2", "#7f8ea6", "#ffffff")
GOLD = Tone("#eab64e", "#a8731d", "#fff1b0")
LEATHER = Tone("#8a5a36", "#5a3820", "#b9875c")
CLOTH = Tone("#3e5a9e", "#283c6e", "#7b98d8")
RED = Tone("#d9343c", "#8e1c26", "#ff8a80")
BLUE = Tone("#3d8ae6", "#1f4f9e", "#9fd0ff")
GLASS = Tone("#e8f1f8", "#a9bccd", "#ffffff")
CORK = Tone("#b07c4c", "#7a522e", "#d9a878")
GEM = Tone("#3fd0c0", "#1a8478", "#b8fff4")


def _c():
    return Canvas(S, S, light=(-1.0, -1.2))


def weapon():
    c = _c()
    a = math.radians(45)
    tip, base = (104, 24), (44, 84)
    nx, ny = math.cos(a + math.pi / 2) * 0.70710678 * 1.414, math.sin(a + math.pi / 2) * 0.70710678 * 1.414
    nx, ny = 0.7071, 0.7071
    c.part(lambda d: c.poly(d, [(base[0] - nx * 7, base[1] - ny * 7 + 0), (tip[0] - 2, tip[1] - 2), (tip[0] + 2, tip[1] + 2),
                                 (base[0] + nx * 7, base[1] + ny * 7)]), STEEL, shade_d=3, light_d=1.5)
    c.flat(lambda d: c.poly(d, [(base[0] - 1, base[1] - 1), (tip[0] - 1, tip[1] - 1), (base[0] - 4, base[1] - 4)]), "#ffffff", alpha=200)
    c.part(lambda d: c.capsule(d, (30, 70), (58, 98), 6, 6), GOLD, shade_d=2)
    c.part(lambda d: c.capsule(d, (44, 84), (22, 106), 5, 5), Tone("#4a3048", "#2a1a2a", "#7a5878"), shade_d=1.6)
    for k in range(3):
        c.flat(lambda d, k=k: c.capsule(d, (38 - k * 6 + 3, 90 + k * 6 - 3), (38 - k * 6 - 3, 90 + k * 6 + 3), 1.2, 1.2), "#2a1a2a")
    c.part(lambda d: c.circle(d, 20, 108, 7), GOLD, shade_d=2)
    c.flat(lambda d: c.circle(d, 20, 108, 3), "#e23a3f")
    return c.render(outline=OUTLINE, width=3)


def helm():
    c = _c()
    c.part(lambda d: (c.ellipse(d, 64, 66, 38, 36), c.poly(d, [(26, 66), (102, 66), (98, 96), (30, 96)])), STEEL, shade_d=7, light_d=3)
    c.part(lambda d: c.poly(d, [(30, 70), (98, 70), (96, 80), (32, 80)]), Tone("#3a3f52", "#22263a", "#5a6078"), shade_d=1)
    c.part(lambda d: c.poly(d, [(58, 30), (70, 30), (72, 96), (56, 96)]), GOLD, shade_d=2)
    c.part(lambda d: c.ribbon(d, bezier((64, 30), (60, 10), (92, 6), (104, 22), 16), [12 - 0.5 * i for i in range(17)]), RED, shade_d=3)
    return c.render(outline=OUTLINE, width=3)


def armor():
    c = _c()
    c.part(lambda d: c.poly(d, [(28, 30), (50, 22), (64, 30), (78, 22), (100, 30), (108, 58), (94, 62), (92, 108), (36, 108),
                                 (34, 62), (20, 58)]), CLOTH, shade_d=8, light_d=3)
    c.part(lambda d: c.poly(d, [(50, 22), (64, 52), (78, 22), (72, 22), (64, 38), (56, 22)]), Tone("#e9e2d2", "#bdb3a0", "#ffffff"), shade_d=1)
    c.part(lambda d: c.poly(d, [(36, 76), (92, 76), (92, 86), (36, 86)]), LEATHER, shade_d=2)
    c.part(lambda d: c.circle(d, 64, 81, 6), GOLD, shade_d=1.5)
    for x in (28, 100):
        c.part(lambda d, x=x: c.ellipse(d, x, 36, 14, 10), STEEL, shade_d=3)
    return c.render(outline=OUTLINE, width=3)


def gloves():
    c = _c()
    c.part(lambda d: (c.poly(d, [(36, 106), (40, 64), (84, 60), (92, 104)]), c.ellipse(d, 64, 56, 28, 20)), LEATHER, shade_d=6, light_d=2.5)
    for k, x in enumerate((44, 56, 68, 80)):
        c.part(lambda d, x=x, k=k: c.capsule(d, (x, 52), (x + 1, 28 + abs(k - 1.5) * 4), 6, 5.5), LEATHER, shade_d=2.5)
    c.part(lambda d: c.capsule(d, (88, 66), (106, 52), 6.5, 5.5), LEATHER, shade_d=2.5)
    c.part(lambda d: c.poly(d, [(34, 92), (94, 90), (96, 110), (32, 112)]), STEEL, shade_d=3, light_d=1.5)
    return c.render(outline=OUTLINE, width=3)


def boots():
    c = _c()
    c.part(lambda d: (c.poly(d, [(40, 18), (76, 18), (78, 80), (108, 88), (110, 106), (36, 106)]), c.ellipse(d, 94, 96, 18, 12)),
           LEATHER, shade_d=7, light_d=2.5)
    c.part(lambda d: c.poly(d, [(36, 100), (112, 100), (112, 110), (36, 110)]), Tone("#3a2a22", "#22180f", "#5e463a"), shade_d=1)
    c.part(lambda d: c.poly(d, [(38, 18), (78, 18), (80, 34), (36, 34)]), STEEL, shade_d=2)
    c.part(lambda d: c.capsule(d, (40, 56), (76, 56), 3, 3), GOLD, shade_d=1)
    return c.render(outline=OUTLINE, width=3)


def necklace():
    c = _c()
    c.part(lambda d: c.ribbon(d, bezier((24, 20), (20, 90), (108, 90), (104, 20), 30), [5] * 31), GOLD, shade_d=1.5)
    c.part(lambda d: c.poly(d, [(64, 70), (84, 88), (64, 116), (44, 88)]), GEM, shade_d=6, light_d=2.5)
    c.flat(lambda d: c.poly(d, [(64, 74), (76, 88), (64, 88)]), "#ffffff", alpha=170)
    c.part(lambda d: c.circle(d, 64, 70, 6), GOLD, shade_d=1.5)
    return c.render(outline=OUTLINE, width=3)


def ring():
    c = _c()
    m = c.part(lambda d: c.ellipse(d, 64, 76, 38, 32), GOLD, shade_d=6, light_d=3)
    c.part(lambda d: c.ellipse(d, 64, 80, 26, 20), Tone("#000000", "#000000", "#000000"), shade=False, alpha=0)
    hole = c.mask()
    from PIL import ImageDraw, ImageChops
    c.ellipse(ImageDraw.Draw(hole), 64, 80, 26, 20)
    c.img.putalpha(ImageChops.subtract(c.img.getchannel("A"), hole))
    c.part(lambda d: c.poly(d, [(64, 22), (86, 42), (64, 60), (42, 42)]), Tone("#e2465a", "#9a1f33", "#ffb0bb"), shade_d=5, light_d=2)
    c.flat(lambda d: c.poly(d, [(64, 28), (78, 42), (64, 42)]), "#ffffff", alpha=170)
    return c.render(outline=OUTLINE, width=3)


def gold():
    c = _c()
    for x, y in ((44, 92), (84, 92), (64, 70), (46, 60), (84, 58)):
        c.part(lambda d, x=x, y=y: c.ellipse(d, x, y, 22, 14), GOLD, shade_d=4, light_d=2)
        c.flat(lambda d, x=x, y=y: c.ellipse(d, x, y, 12, 6.5), "#c48a20", alpha=200)
        c.flat(lambda d, x=x, y=y: c.ellipse(d, x - 6, y - 6, 6, 2.5), "#fff6c8", alpha=220)
    return c.render(outline=OUTLINE, width=3)


def potion(tone, glow):
    c = _c()
    c.glow(lambda d: c.circle(d, 64, 80, 34), glow, radius=8, alpha=110)
    c.part(lambda d: (c.circle(d, 64, 80, 32), c.poly(d, [(52, 36), (76, 36), (78, 56), (50, 56)])), GLASS, shade_d=4, light_d=2)
    c.part(lambda d: (c.circle(d, 64, 84, 27), ), tone, shade_d=6, light_d=3)
    c.flat(lambda d: c.ellipse(d, 64, 64, 26, 6), tone.light, alpha=200)
    c.part(lambda d: c.poly(d, [(50, 24), (78, 24), (76, 40), (52, 40)]), CORK, shade_d=2)
    c.flat(lambda d: c.ellipse(d, 50, 72, 6, 12, 0.4), "#ffffff", alpha=210)
    c.flat(lambda d: c.circle(d, 76, 96, 3), "#ffffff", alpha=160)
    return c.render(outline=OUTLINE, width=3)


def build():
    return {"item-weapon": weapon(), "item-helm": helm(), "item-armor": armor(), "item-gloves": gloves(),
            "item-boots": boots(), "item-necklace": necklace(), "item-ring": ring(), "res-gold": gold(),
            "res-potion": potion(RED, "#ff4050"), "res-mp_potion": potion(BLUE, "#4aa8ff")}


if __name__ == "__main__":
    import os
    from PIL import Image
    res = build()
    prev = Image.new("RGBA", (5 * 140, 2 * 140), hexc("#241c2c"))
    for i, (k, im) in enumerate(res.items()):
        prev.alpha_composite(im, (6 + (i % 5) * 140, 6 + (i // 5) * 140))
    prev.save(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "_preview", "hd-icons.png"))
    print("ok")
