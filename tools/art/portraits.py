"""UI-22: chân dung lớn cho màn chọn lớp — 64×72, chibi đầu to, tư thế chiến đấu, quay 3/4 sang phải.
Chỉ dùng ở giao diện (không thay sprite 32×32 trong trận). Ghi ra icon "portrait-<lớp>"; icons.py gọi build()."""
import math

from pixel import Canvas, R, OUTLINE, glow, hexc, mix, ramp

W, H = 64, 72

P = {
    "armor_dark": ramp("#1c1e26", "#2e3240", "#474d60", "#6b7388"),
    "robe_purple": ramp("#1a1030", "#2e1c52", "#48307a", "#6a4aa6"),
    "robe_void": ramp("#140c22", "#261640", "#3e2464", "#5c3a8c"),
    "hair_silver": ramp("#6e7088", "#a4a8c0", "#d0d4e6", "#f2f4ff"),
    "hair_blond": ramp("#8a5a1e", "#c08a32", "#e6bc5a", "#fae08e"),
    "hair_black": ramp("#0e0e16", "#1c1c2a", "#2e2e44", "#46465e"),
    "plate": ramp("#3a3e48", "#6a707e", "#a2a8b4", "#dfe4ec"),
    "plate_gold": ramp("#5a3e12", "#9a6c20", "#d6a232", "#ffe07a"),
    "glow_red": ramp("#7a0e14", "#d02030", "#ff5a50", "#ffd0b0"),
    "glow_green": ramp("#1a5a20", "#3aa83c", "#7ee860", "#e4ffc8"),
    "glow_purple": ramp("#3a1470", "#7a38d0", "#b878ff", "#f0dcff"),
}


def _face(cv, cx, cy, eye=(40, 34, 60, 255), skin=None):
    skin = skin or R["skin_light"]
    cv.shade_ellipse(cx, cy, 10.5, 11, skin, light=(-0.15, -0.35), bands=(0.55, 1.05, 1.45))
    for ex in (cx + 0.5, cx + 6):
        cv.rect(ex, cy + 0.5, ex + 2.5, cy + 5, (24, 18, 30, 255))
        cv.rect(ex, cy + 2.5, ex + 2.5, cy + 5, eye)
        cv.set(ex + 1, cy + 1, (255, 255, 255, 255))
    cv.rect(cx - 1, cy + 5, cx + 1, cy + 6, (232, 140, 130, 150))
    cv.rect(cx + 8, cy + 5, cx + 9.5, cy + 6, (232, 140, 130, 150))
    cv.set(cx + 4, cy + 7, (150, 80, 70, 255))


def _legs(cv, pants, boots, back=(24, 52), front=(35, 52), spread=4):
    bx, by = back
    fx, fy = front
    cv.shade_poly([(bx - 3, by), (bx + 3, by), (bx - spread + 3, 63), (bx - spread - 3, 63)], [mix(c, (0, 0, 0, 255), 0.25) for c in pants])
    cv.shade_poly([(fx - 3, fy), (fx + 3, fy), (fx + spread + 3, 63), (fx + spread - 3, 63)], pants)
    cv.shade_poly([(bx - spread - 4, 61), (bx - spread + 3, 61), (bx - spread + 4, 68), (bx - spread - 5, 68)], boots)
    cv.shade_poly([(fx + spread - 3, 61), (fx + spread + 4, 61), (fx + spread + 6, 68), (fx + spread - 4, 68)], boots)


def _done(cv):
    return cv.outline(OUTLINE)


# ---------------------------------------------------------------- Kiếm Khách
def kiem_khach():
    cv = Canvas(W, H)
    # áo choàng đỏ phía sau
    cv.shade_poly([(21, 33), (38, 33), (30, 50), (12, 64), (8, 58), (16, 44)], R["cloth_red"])
    _legs(cv, P["armor_dark"], R["leather"], back=(25, 52), front=(35, 52), spread=5)
    # thân giáp tối
    cv.shade_poly([(22, 33), (40, 33), (42, 53), (21, 53)], P["armor_dark"])
    cv.rect(21, 49, 42, 52, R["leather"][1])
    cv.rect(30, 49, 33, 52, R["gold"][2])
    cv.line(31, 35, 31, 48, P["armor_dark"][3], 1.0)
    # vai giáp
    cv.shade_ellipse(23, 35, 5, 4, R["steel"])
    cv.shade_ellipse(39, 35, 5.5, 4.2, R["steel"])
    # khăn quàng đỏ
    cv.shade_ellipse(31, 32.5, 9, 3.2, R["cloth_red"])
    cv.shade_poly([(24, 32), (28, 33), (20, 42), (17, 40)], R["cloth_red"])
    # tay trước cầm kiếm thấp, lưỡi đỏ rực chĩa xuống phải
    cv.line(40, 37, 45, 46, P["armor_dark"][2], 4.0)
    glow(cv, 54, 56, 14, (255, 80, 60), 90)
    cv.line(45, 47, 61, 63, P["glow_red"][1], 3.4)
    cv.line(46, 47, 61, 62, P["glow_red"][3], 1.2)
    cv.line(41, 44, 48, 50, R["gold"][2], 2.0)
    cv.shade_ellipse(45, 46.5, 2.6, 2.6, R["skin"])
    # đầu + tóc đen nhọn
    _face(cv, 31, 21)
    hair = P["hair_black"]
    cv.shade_poly([(19, 22), (20, 12), (26, 7), (36, 6), (42, 11), (43, 19), (38, 14), (33, 16), (27, 13), (23, 18)], hair)
    for sp in ([(20, 14), (13, 10), (22, 9)], [(25, 8), (22, 1), (30, 6)], [(31, 6), (34, 0), (37, 6)], [(38, 8), (45, 4), (42, 12)],
               [(19, 20), (14, 22), (20, 25)]):
        cv.shade_poly(sp, hair)
    # tóc mái lởm chởm che trán
    cv.shade_poly([(20, 18), (22, 13), (41, 12), (42, 17), (39, 16), (37, 20), (35, 16), (32, 19), (30, 15), (27, 19), (25, 15), (22, 20)], hair)
    return _done(cv)


# ---------------------------------------------------------------- Thợ Săn
def tho_san():
    cv = Canvas(W, H)
    green = R["cloth_green"]
    # áo choàng xanh phía sau
    cv.shade_poly([(19, 26), (38, 28), (36, 50), (16, 64), (12, 50)], [mix(c, (0, 0, 0, 255), 0.2) for c in green])
    _legs(cv, R["leather"], R["leather"], back=(25, 52), front=(34, 52), spread=3)
    # thân áo da + đai
    cv.shade_poly([(23, 34), (38, 34), (39, 53), (22, 53)], green)
    cv.line(24, 35, 37, 51, R["leather"][2], 1.8)
    cv.rect(22, 49, 39, 51.5, R["leather"][1])
    # bao tên sau lưng
    cv.shade_poly([(17, 30), (22, 28), (25, 44), (20, 46)], R["leather"])
    for i in range(3):
        cv.line(18 + i * 1.5, 30, 16 + i * 1.5, 24, R["white"][3], 1.0)
    # cung + tên phát sáng (kéo căng sang phải)
    glow(cv, 52, 40, 12, (120, 255, 100), 80)
    cv.arc(44, 40, 13, math.radians(-70), math.radians(70), R["wood"][2], 2.2)
    cv.line(48.5, 28, 41, 40, (230, 230, 210, 255), 1.0)
    cv.line(41, 40, 48.5, 52, (230, 230, 210, 255), 1.0)
    cv.line(36, 40, 62, 40, P["glow_green"][2], 1.6)
    cv.poly([(63, 40), (59, 37.5), (59, 42.5)], P["glow_green"][3])
    # tay
    cv.line(37, 37, 42, 40, green[2], 3.0)
    cv.shade_ellipse(42, 40, 2.2, 2.2, R["skin"])
    cv.line(36, 38, 56, 40, green[1], 2.6)
    cv.shade_ellipse(56, 40, 2.2, 2.2, R["skin"])
    # đầu: mũ trùm xanh, tóc vàng lộ trước trán
    cv.shade_ellipse(30, 21, 13.5, 13, green, light=(-0.3, -0.7))
    _face(cv, 31, 22)
    cv.shade_poly([(21, 18), (25, 12), (34, 11), (41, 15), (37, 16), (31, 14), (26, 18), (22, 22)], P["hair_blond"])
    cv.shade_poly([(18, 18), (24, 9), (34, 7), (43, 13), (39, 13), (30, 10), (23, 15)], green)
    cv.shade_poly([(17, 22), (20, 34), (25, 31)], green)
    return _done(cv)


# ---------------------------------------------------------------- Pháp Sư
def phap_su():
    cv = Canvas(W, H)
    robe = P["robe_purple"]
    # tóc bạc dài phía sau
    cv.shade_poly([(19, 20), (27, 18), (25, 46), (15, 44)], P["hair_silver"])
    # áo choàng dài
    cv.shade_poly([(22, 33), (39, 33), (45, 66), (16, 66)], robe)
    cv.line(30, 34, 30, 66, robe[0], 1.0)
    cv.rect(22, 44, 41, 46.5, R["gold"][1])
    cv.shade_poly([(19, 64), (42, 64), (45, 68), (16, 68)], [mix(c, (0, 0, 0, 255), 0.3) for c in robe])
    # trượng + quả cầu tím
    cv.line(46, 26, 42, 66, R["wood"][2], 2.2)
    cv.arc(46, 22, 5, math.radians(110), math.radians(430), R["gold"][2], 1.2)
    glow(cv, 46, 21, 13, (190, 120, 255), 110)
    cv.shade_ellipse(46, 21, 3.6, 3.6, P["glow_purple"])
    # tay
    cv.line(37, 37, 44, 40, robe[2], 3.4)
    cv.shade_ellipse(44.5, 40, 2.2, 2.2, R["skin"])
    # đầu + tóc bạc + mũ phù thuỷ
    _face(cv, 30, 24, eye=(90, 50, 140, 255))
    cv.shade_poly([(19, 22), (22, 16), (33, 15), (40, 19), (34, 19), (27, 18), (22, 26)], P["hair_silver"])
    cv.shade_ellipse(30, 15, 17, 3.6, robe)
    cv.shade_poly([(21, 15), (39, 15), (36, 6), (44, -1), (30, 2), (24, 8)], robe)
    cv.rect(21.5, 12.5, 38.5, 14.5, R["gold"][2])
    return _done(cv)


# ---------------------------------------------------------------- Hộ Vệ
def ho_ve():
    cv = Canvas(W, H)
    plate = P["plate"]
    _legs(cv, plate, plate, back=(24, 52), front=(33, 52), spread=4)
    # áo choàng lam sau lưng
    cv.shade_poly([(19, 34), (37, 34), (32, 60), (14, 62)], R["cloth_blue"])
    # thân giáp tấm
    cv.shade_poly([(20, 32), (39, 32), (41, 54), (19, 54)], plate)
    cv.rect(19, 49, 41, 52, R["leather"][1])
    cv.line(29.5, 34, 29.5, 48, plate[3], 1.0)
    cv.shade_ellipse(21, 34, 6, 5, plate)
    cv.shade_ellipse(38, 34, 6, 5, plate)
    # chuỳ (tay sau)
    cv.line(16, 44, 10, 30, R["wood"][1], 2.2)
    cv.shade_ellipse(10, 28, 4.4, 4.4, R["steel"])
    for a in range(0, 360, 60):
        cv.set(10 + math.cos(math.radians(a)) * 5.5, 28 + math.sin(math.radians(a)) * 5.5, R["steel"][3])
    # đầu: mũ trụ kín
    cv.shade_ellipse(29, 20, 11, 11.5, plate, light=(-0.3, -0.6))
    cv.rect(25, 18, 39, 21, (20, 16, 24, 255))
    cv.rect(32, 21, 34, 28, (20, 16, 24, 230))
    cv.shade_poly([(28, 9), (31, 2), (33, 9)], R["cloth_red"])
    cv.line(29, 9, 29, 30, plate[3], 1.0)
    # khiên lớn phía trước, viền vàng, chữ thập
    cv.shade_poly([(34, 30), (58, 30), (58, 50), (46, 66), (34, 50)], R["gold"])
    cv.shade_poly([(36.5, 32.5), (55.5, 32.5), (55.5, 49), (46, 62), (36.5, 49)], plate)
    cv.rect(44.8, 35, 47.4, 58, R["gold"][2])
    cv.rect(39, 41, 53, 43.5, R["gold"][2])
    cv.set(40, 34, (255, 255, 255, 255))
    return _done(cv)


# ---------------------------------------------------------------- Triệu Hồi Sư
def trieu_hoi():
    cv = Canvas(W, H)
    robe = P["robe_void"]
    cv.shade_poly([(18, 20), (27, 18), (26, 50), (14, 48)], P["hair_silver"])
    cv.shade_poly([(22, 33), (39, 33), (44, 66), (17, 66)], robe)
    cv.rect(22, 44, 40, 46.5, R["purple"][2])
    cv.line(30, 34, 30, 66, R["purple"][1], 1.0)
    # linh thú: dơi tím trên vai trái, sói nhỏ dưới chân phải
    glow(cv, 12, 14, 9, (200, 120, 255), 90)
    cv.shade_ellipse(12, 15, 3.6, 3.2, R["purple"])
    cv.shade_poly([(9, 14), (1, 8), (4, 17)], R["purple"])
    cv.shade_poly([(15, 14), (23, 8), (20, 17)], R["purple"])
    cv.set(11, 14, (255, 230, 120, 255)); cv.set(13, 14, (255, 230, 120, 255))
    # sói linh hồn nhỏ ngồi cạnh chân
    fur = R["fur_grey"]
    glow(cv, 53, 61, 11, (150, 170, 255), 70)
    cv.shade_poly([(46, 62), (41, 56), (44, 56), (48, 60)], fur)
    cv.shade_ellipse(51, 63, 6, 3.6, fur)
    cv.rect(47, 64, 49, 68, fur[1]); cv.rect(53, 64, 55, 68, fur[1])
    cv.shade_ellipse(57, 57.5, 3.8, 3.4, fur)
    cv.shade_poly([(59, 56.5), (64, 58), (59.5, 60)], fur)
    cv.shade_poly([(54.5, 55.5), (55, 50.5), (57.5, 55)], fur)
    cv.shade_poly([(57.5, 55), (59, 50.5), (60, 56)], fur)
    cv.set(58, 57, (120, 210, 255, 255))
    # trượng + quả cầu
    cv.line(44, 24, 41, 64, R["bark"][2], 2.0)
    glow(cv, 44, 21, 12, (190, 110, 255), 110)
    cv.shade_ellipse(44, 21, 3.4, 3.4, P["glow_purple"])
    cv.line(37, 37, 43, 40, robe[2], 3.4)
    cv.shade_ellipse(43, 40, 2.2, 2.2, R["skin"])
    _face(cv, 30, 24, eye=(110, 40, 150, 255))
    cv.shade_poly([(19, 26), (21, 15), (30, 12), (40, 16), (41, 22), (35, 18), (27, 17), (22, 22)], P["hair_silver"])
    cv.shade_poly([(19, 16), (23, 12), (21, 26)], P["hair_silver"])
    return _done(cv)


PORTRAITS = {"kiem-khach": kiem_khach, "tho-san": tho_san, "phap-su": phap_su, "ho-ve": ho_ve, "trieu-hoi-su": trieu_hoi}


def build():
    return {"portrait-" + k: fn().to_image() for k, fn in PORTRAITS.items()}
