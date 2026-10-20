"""Môi trường và vật thể nhỏ (AR-05): ô đất, cây, nhà, Bia Đá, rương, thảo dược, vật rơi, hiệu ứng.

Mỗi hình trả về (Image, origin): origin là điểm ảnh đặt vào toạ độ thực thể trong game
(chân với vật đứng, tâm với vật rơi/hiệu ứng).
"""
import math
import random
from pixel import Canvas, R, OUTLINE, shadow, glow, hexc, mix


def tile(base, seed, tufts=True):
    rnd = random.Random(seed)
    cv = Canvas(32, 32)
    cv.rect(0, 0, 32, 32, base[1])
    for _ in range(70):
        x, y = rnd.randrange(32), rnd.randrange(32)
        cv.set(x, y, base[rnd.choice((0, 2, 2))])
    if tufts:
        for _ in range(5):
            x, y = rnd.randrange(2, 30), rnd.randrange(3, 31)
            cv.set(x, y, base[3]); cv.set(x - 1, y + 1, base[2]); cv.set(x + 1, y + 1, base[2])
    return cv


def tree(seed, kind="round"):
    rnd = random.Random(seed)
    cv = Canvas(40, 52)
    shadow(cv, 20, 48.5, 13, 3.2, 100)
    cv.shade_poly([(17, 34), (23, 34), (24, 49), (16, 49)], R["bark"])
    cv.line(19, 36, 19, 47, R["bark"][0])
    leaf = R["leaf"]
    if kind == "pine":
        for i, (y, w) in enumerate(((10, 7), (20, 11), (30, 15))):
            cv.shade_poly([(20, y - 9), (20 + w, y + 7), (20 - w, y + 7)], leaf)
    else:
        blobs = [(20, 22, 14, 12), (12, 26, 8, 7), (28, 26, 8, 7), (20, 14, 9, 8)]
        for (x, y, rx, ry) in blobs:
            cv.shade_ellipse(x + rnd.uniform(-1, 1), y + rnd.uniform(-1, 1), rx, ry, leaf)
        for _ in range(10):
            cv.set(rnd.uniform(10, 28), rnd.uniform(10, 24), leaf[3])
    cv.outline(OUTLINE)
    return cv, [20, 48]


def bush(seed):
    rnd = random.Random(seed)
    cv = Canvas(24, 18)
    shadow(cv, 12, 15.5, 9, 2)
    for (x, y, r) in ((8, 10, 5), (16, 10, 5), (12, 7, 5)):
        cv.shade_ellipse(x, y, r, r * 0.85, R["leaf_light"])
    for _ in range(3):
        cv.set(rnd.uniform(6, 18), rnd.uniform(5, 12), hexc("#f4d070"))
    cv.outline(OUTLINE)
    return cv, [12, 15]


def hut():
    cv = Canvas(48, 44)
    shadow(cv, 24, 40.5, 20, 3.5, 100)
    cv.shade_poly([(8, 22), (40, 22), (40, 40), (8, 40)], R["wood"])
    for x in range(10, 40, 5):
        cv.line(x, 23, x, 39, R["wood"][1])
    cv.rect(20, 29, 28, 40, R["bark"][0])
    cv.rect(31, 27, 37, 32, hexc("#ffd877"))
    cv.line(34, 27, 34, 32, R["wood"][0])
    cv.shade_poly([(24, 3), (46, 23), (2, 23)], R["dirt"])
    for i in range(5):
        y = 8 + i * 3.4
        cv.line(24 - (y - 3) * 1.05, y, 24 + (y - 3) * 1.05, y, R["dirt"][1])
    cv.outline(OUTLINE)
    return cv, [24, 40]


def stele():
    cv = Canvas(24, 40)
    shadow(cv, 12, 36.5, 10, 2.5, 100)
    cv.shade_poly([(4, 33), (20, 33), (21, 37), (3, 37)], R["stone"])
    cv.shade_poly([(6, 6), (12, 2), (18, 6), (18, 33), (6, 33)], R["stone"])
    for y in range(9, 31, 4):
        cv.line(9, y, 15, y, R["gold"][2])
    cv.outline(OUTLINE)
    glow(cv, 12, 18, 11, R["gold"][3], 60)
    return cv, [12, 36]


def chest():
    cv = Canvas(24, 20)
    shadow(cv, 12, 17.5, 10, 2)
    cv.shade_poly([(3, 8), (21, 8), (21, 17), (3, 17)], R["wood"])
    cv.shade_ellipse(12, 8, 9, 4.5, R["wood"])
    cv.clear(0, 8.5, 24, 9.5)
    cv.rect(3, 8.5, 21, 10, R["gold"][1])
    cv.rect(10.5, 7.5, 13.5, 12, R["gold"][2])
    cv.set(12, 10, R["gold"][0])
    cv.rect(3, 15, 21, 16, R["gold"][1])
    cv.outline(OUTLINE)
    return cv, [12, 13]


def herb():
    cv = Canvas(16, 16)
    shadow(cv, 8, 13.5, 5, 1.4)
    cv.line(8, 13, 8, 6, R["leaf"][2])
    for (x, y) in ((5, 9), (11, 8), (6, 5.5), (10.5, 11)):
        cv.shade_ellipse(x, y, 2.8, 1.8, R["leaf_light"])
    cv.ellipse(8, 4.5, 1.6, 1.6, hexc("#e8f7a0"))
    cv.outline(OUTLINE)
    return cv, [8, 10]


def coin():
    cv = Canvas(10, 10)
    cv.shade_ellipse(5, 5, 3.6, 3.6, R["gold"])
    cv.set(4, 4, (255, 255, 255, 255))
    cv.outline(OUTLINE)
    return cv, [5, 5]


def heal_orb():
    cv = Canvas(14, 14)
    glow(cv, 7, 7, 7, hexc("#5bd16a"), 120)
    cv.shade_ellipse(7, 7, 3.6, 3.6, R["leaf_light"])
    cv.rect(6.5, 5, 7.5, 9, (255, 255, 255, 255))
    cv.rect(5, 6.5, 9, 7.5, (255, 255, 255, 255))
    return cv, [7, 7]


def stone_pickup():
    cv = Canvas(12, 12)
    cv.shade_poly([(6, 1), (10, 5), (8, 11), (4, 11), (2, 5)], R["crystal"])
    cv.outline(OUTLINE)
    return cv, [6, 6]


def spore():
    cv = Canvas(12, 12)
    glow(cv, 6, 6, 6, hexc("#c878ff"), 160)
    cv.shade_ellipse(6, 6, 2.8, 2.8, R["purple"])
    return cv, [6, 6]


def hit_spark(frame):
    cv = Canvas(16, 16)
    r = 3 + frame * 2.5
    a = 255 - frame * 70
    for i in range(6):
        ang = math.radians(i * 60 + frame * 15)
        cv.line(8 + math.cos(ang) * (r - 2.5), 8 + math.sin(ang) * (r - 2.5), 8 + math.cos(ang) * r, 8 + math.sin(ang) * r, (255, 240, 200, a))
    if frame == 0:
        cv.ellipse(8, 8, 2, 2, (255, 255, 255, 255))
    return cv, [8, 8]


# ------------------------------------------------------------ đạn, bẫy của người chơi (M3) — vẽ hướng sang phải, game xoay
def fx_arrow():
    cv = Canvas(20, 8)
    cv.line(2, 4, 16, 4, R["wood"][3], 1.2)
    cv.shade_poly([(15, 1.5), (19.5, 4), (15, 6.5)], R["steel"])
    cv.line(1, 2, 4, 4, hexc("#c84040"))
    cv.line(1, 6, 4, 4, hexc("#c84040"))
    cv.outline(OUTLINE)
    return cv, [10, 4]


def fx_pierce():
    cv = Canvas(28, 12)
    glow(cv, 16, 6, 9, hexc("#c28af0"), 140)
    cv.line(2, 6, 22, 6, R["purple"][3], 1.6)
    cv.shade_poly([(20, 2.5), (27, 6), (20, 9.5)], R["white"])
    cv.outline(OUTLINE)
    return cv, [14, 6]


def fx_wave():
    cv = Canvas(24, 32)
    glow(cv, 12, 16, 12, hexc("#c8e6ff"), 120)
    for i, r in enumerate((13, 10)):
        cv.arc(2 + i * 2, 16, r, math.radians(-65), math.radians(65), hexc("#ffffff") if i == 0 else hexc("#9ec8ff"), 3.0 - i)
    return cv, [12, 16]


def fx_trap():
    cv = Canvas(18, 14)
    shadow(cv, 9, 10, 8, 2.5)
    cv.shade_ellipse(9, 9, 7.5, 3.5, R["steel"])
    for i in range(5):
        x = 4 + i * 2.5
        cv.shade_poly([(x - 1, 9), (x, 3 + (i % 2) * 2), (x + 1, 9)], R["white"])
    cv.outline(OUTLINE)
    return cv, [9, 9]


# ------------------------------------------------------------ M4: Đồng Bằng Gió Hú, Thành Biên Đài
def rock(seed):
    rnd = random.Random(seed)
    cv = Canvas(28, 20)
    shadow(cv, 14, 17, 12, 2.5, 90)
    cv.shade_poly([(3, 16), (6, 8), (12, 4), (20, 5), (25, 11), (24, 16)], R["stone"])
    for _ in range(3):
        x = rnd.uniform(8, 20)
        cv.line(x, 7, x + rnd.uniform(-3, 3), 14, R["stone"][0])
    cv.outline(OUTLINE)
    return cv, [14, 16]


def tall_grass(seed):
    rnd = random.Random(seed)
    cv = Canvas(20, 18)
    shadow(cv, 10, 15.5, 8, 1.6, 60)
    for i in range(9):
        x = 3 + i * 1.8 + rnd.uniform(-0.6, 0.6)
        top = rnd.uniform(2, 7)
        cv.line(x, 15, x + rnd.uniform(1.5, 3.5), top, R["leaf_light"][rnd.choice((1, 2, 3))], 1.2)
    return cv, [10, 15]


def house_stone():
    cv = Canvas(48, 46)
    shadow(cv, 24, 42.5, 21, 3.5, 100)
    cv.shade_poly([(7, 20), (41, 20), (41, 42), (7, 42)], R["stone"])
    for y in (25, 31, 37):
        cv.line(8, y, 40, y, R["stone"][0])
    for x, y0 in ((14, 20), (24, 25), (33, 31), (19, 31), (29, 37)):
        cv.line(x, y0, x, y0 + 5, R["stone"][0])
    cv.rect(20, 31, 28, 42, R["wood"][1])
    cv.rect(10, 24, 15, 29, hexc("#ffd877"))
    cv.rect(33, 24, 38, 29, hexc("#ffd877"))
    cv.shade_poly([(24, 4), (45, 21), (3, 21)], R["cloth_red"])
    cv.outline(OUTLINE)
    return cv, [24, 42]


def tower():
    cv = Canvas(32, 64)
    shadow(cv, 16, 60.5, 13, 3, 100)
    cv.shade_poly([(7, 18), (25, 18), (24, 60), (8, 60)], R["stone"])
    for y in range(22, 58, 6):
        cv.line(8, y, 24, y, R["stone"][0])
    cv.rect(13, 30, 19, 38, hexc("#2a2430"))
    for x in (5, 11, 17, 23):
        cv.rect(x, 12, x + 4, 18, R["stone"][2])
    cv.rect(15, 2, 16, 12, R["wood"][1])
    cv.shade_poly([(16, 2), (24, 5), (16, 8)], R["cloth_blue"])
    cv.outline(OUTLINE)
    return cv, [16, 60]


def build_all():
    out = {}
    for i in range(3):
        out["tile-grass-%d" % i] = (tile(R["grass"], 100 + i), [0, 0])
    out["tile-dirt"] = (tile(R["dirt"], 200, tufts=False), [0, 0])
    out["tile-village"] = (tile([mix(c, (0, 0, 0, 255), 0.15) for c in R["dirt"]], 201, tufts=False), [0, 0])
    out["tile-void"] = (tile(R["void"], 300, tufts=False), [0, 0])
    out["tile-plain"] = (tile([hexc("#3e4a24"), hexc("#55642e"), hexc("#6a7a38"), hexc("#8a9a4a")], 400), [0, 0])
    out["tile-town"] = (tile(R["stone"], 401, tufts=False), [0, 0])
    for i in range(3):
        out["tree-%d" % i] = tree(10 + i)
    out["tree-pine"] = tree(20, "pine")
    out["bush"] = bush(30)
    for i in range(2):
        out["rock-%d" % i] = rock(40 + i)
    out["tall-grass"] = tall_grass(50)
    out["house-stone"] = house_stone()
    out["tower"] = tower()
    out["hut"] = hut()
    out["stele"] = stele()
    out["chest"] = chest()
    out["herb"] = herb()
    out["pickup-gold"] = coin()
    out["pickup-orb"] = heal_orb()
    out["pickup-stone"] = stone_pickup()
    out["fx-spore"] = spore()
    for f in range(3):
        out["fx-hit-%d" % f] = hit_spark(f)
    out["fx-arrow"] = fx_arrow()
    out["fx-pierce"] = fx_pierce()
    out["fx-wave"] = fx_wave()
    out["fx-trap"] = fx_trap()
    return {k: (cv.to_image(), origin) for k, (cv, origin) in out.items()}
