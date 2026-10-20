"""Icon 32×32: trang bị, tài nguyên, kỹ năng, Thiên phú (AR-04).

Thêm icon mới: viết 1 hàm vẽ `def g_<tên>(cv)` lên Canvas 32×32 rồi thêm vào bảng tương ứng ở cuối file.
Icon trang bị không tô màu phẩm chất (giao diện vẽ khung theo phẩm chất).
"""
import math
from pixel import Canvas, R, OUTLINE, glow, hexc, mix

RANK_HEX = {"F": "#9aa0a6", "C": "#f1f3f4", "B": "#5bd16a", "A": "#4a9df8", "S": "#b36bff", "SS": "#ffc940", "SSS": "#ff5470"}
GROUP_BG = {"combat": "#5a1e26", "economy": "#5a4512", "explore": "#163e4a", "craft": "#4a3220", "territory": "#2a3a1a",
            "summon": "#33204e", "magic": "#1e2c5a", "control": "#16384a", "special": "#3a0e1e"}

# (id, hạng, nhóm, hàm vẽ biểu tượng) — khớp godot/scripts/data/talents.gd
TALENTS = [
    ("than-the", "F", "combat", "g_shield_plus"), ("tay-nhanh", "F", "combat", "g_bolt"),
    ("may-man", "F", "economy", "g_clover"), ("chan-khong", "F", "explore", "g_wing_boot"),
    ("huyet-chien", "C", "combat", "g_blood_sword"), ("tho-ren", "C", "craft", "g_hammer"),
    ("khuu-giac", "C", "explore", "g_magnifier"), ("kiem-tam", "B", "combat", "g_sword_aura"),
    ("thao-duoc", "B", "craft", "g_leaf_potion"), ("trai-tim", "B", "territory", "g_crown_heart"),
    ("thuan-thu", "A", "summon", "g_paw"), ("mat-ung", "A", "explore", "g_eye"),
    ("hap-huyet", "A", "combat", "g_fang_drop"), ("ban-tay-vang", "A", "economy", "g_gold_hand"),
    ("ngu-hanh", "S", "magic", "g_five_elements"), ("thoi-gian-ngung-dong", "S", "control", "g_hourglass"),
    ("bay-dan", "S", "summon", "g_shadow_pack"), ("thien-menh", "SS", "explore", "g_compass"),
    ("long-mach", "SS", "territory", "g_dragon"), ("dao-tac", "SSS", "special", "g_mask"),
]


def _new():
    return Canvas(32, 32)


def _done(cv):
    return cv.outline(OUTLINE)


# ====================================================================== trang bị
def g_sword(cv, s=1.0, ox=0, oy=0):
    P = lambda x, y: (ox + 16 + (x - 16) * s, oy + 16 + (y - 16) * s)
    a, b = P(8, 24), P(25, 7)
    cv.line(*P(10.5, 21.5), *b, R["steel"][2], 2.6 * s)
    cv.line(*P(12, 19.5), *P(24, 7.5), R["steel"][3], 1.0)
    cv.line(*P(7, 19), *P(13, 25), R["gold"][2], 2.0 * s)
    cv.line(*a, *P(10, 22), R["leather"][2], 2.0 * s)
    cv.ellipse(*P(6.5, 25.5), 1.6 * s, 1.6 * s, R["gold"][3])


def g_helm(cv):
    cv.shade_ellipse(16, 16, 10, 9, R["steel"])
    cv.clear(0, 18, 32, 32)
    cv.shade_poly([(6, 17), (26, 17), (25, 25), (20, 25), (19, 21), (13, 21), (12, 25), (7, 25)], R["steel"])
    cv.rect(10, 18.5, 22, 20, R["steel"][0])
    cv.rect(15, 5, 17, 17, R["gold"][2])
    cv.shade_poly([(14, 5), (18, 5), (20, 1), (12, 1)], R["cloth_red"])


def g_armor(cv):
    cv.shade_poly([(8, 7), (13, 5), (19, 5), (24, 7), (27, 13), (23, 14), (23, 27), (9, 27), (9, 14), (5, 13)], R["steel"])
    cv.rect(15, 6, 17, 27, R["steel"][1])
    cv.rect(9, 20, 23, 22, R["leather"][1])
    cv.rect(15, 20, 17, 22, R["gold"][3])
    cv.line(13, 5, 16, 10, R["steel"][0])
    cv.line(19, 5, 16, 10, R["steel"][0])


def g_gloves(cv):
    cv.shade_poly([(9, 27), (9, 16), (11, 8), (14, 8), (14, 14), (15, 6), (18, 6), (18, 13), (19, 7), (22, 7), (22, 14), (24, 12), (26, 14), (23, 22), (22, 27)], R["leather"])
    cv.rect(8, 24, 23, 28, R["steel"][2])
    cv.line(14, 14, 14, 18, R["leather"][0])
    cv.line(18, 13, 18, 18, R["leather"][0])


def g_boots(cv):
    cv.shade_poly([(10, 4), (18, 4), (18, 19), (26, 22), (27, 27), (8, 27), (9, 17)], R["leather"])
    cv.rect(8, 25, 27, 28, R["leather"][0])
    cv.rect(10, 7, 18, 9, R["gold"][2])
    cv.line(11, 12, 17, 12, R["leather"][1])


def g_necklace(cv):
    cv.arc(16, 9, 10, math.radians(20), math.radians(160), R["gold"][2], 1.6)
    for a in range(25, 160, 22):
        cv.set(16 + math.cos(math.radians(a)) * 10, 9 + math.sin(math.radians(a)) * 10, R["gold"][3])
    cv.shade_poly([(16, 17), (21, 22), (16, 29), (11, 22)], R["crystal"])
    cv.set(14, 21, (255, 255, 255, 255))


def g_ring(cv):
    cv.arc(16, 19, 8, 0, math.tau, R["gold"][1], 3.4)
    cv.arc(16, 19, 8, math.radians(190), math.radians(300), R["gold"][3], 1.2)
    cv.shade_poly([(16, 4), (21, 9), (16, 14), (11, 9)], R["blood"])
    cv.set(14, 7, (255, 255, 255, 255))


def g_amulet(cv):
    cv.line(10, 3, 16, 10, R["leather"][2], 1.2)
    cv.line(22, 3, 16, 10, R["leather"][2], 1.2)
    cv.shade_ellipse(16, 19, 8, 9, R["wood"])
    cv.shade_ellipse(16, 19, 5, 6, R["leaf_light"])
    cv.line(16, 14, 16, 24, R["gold"][3])
    cv.line(12.5, 19, 19.5, 19, R["gold"][3])


def g_wolf_fang(cv):
    glow(cv, 16, 16, 15, hexc("#ff9a3c"), 70)
    cv.shade_poly([(7, 26), (10, 20), (15, 13), (22, 6), (27, 4), (24, 10), (18, 18), (12, 24)], R["white"])
    cv.line(9, 23, 24, 7, R["white"][3])
    cv.shade_poly([(4, 27), (9, 21), (12, 24), (7, 29)], R["fur_void"])
    cv.set(25, 6, hexc("#ff3b4e"))


# ====================================================================== tài nguyên
def g_gold(cv):
    for (x, y) in ((11, 21), (20, 22), (15, 14)):
        cv.shade_ellipse(x, y, 6.5, 5, R["gold"])
        cv.ellipse(x, y, 3, 2.2, R["gold"][1])
        cv.set(x - 2, y - 2, R["gold"][3])


def g_wood(cv):
    for (y, x0, x1) in ((20, 5, 25), (13, 8, 28)):
        cv.shade_poly([(x0, y - 4), (x1, y - 4), (x1, y + 4), (x0, y + 4)], R["wood"])
        cv.shade_ellipse(x1, y, 3, 4, R["dirt"])
        cv.ellipse(x1, y, 1.4, 2, R["wood"][1])
        cv.line(x0 + 3, y - 1, x1 - 6, y - 1, R["wood"][1])


def g_stone(cv):
    """Đá Cường Hoá."""
    glow(cv, 16, 17, 13, R["crystal"][2], 70)
    cv.shade_poly([(16, 3), (24, 12), (21, 28), (11, 28), (8, 12)], R["crystal"])
    cv.line(16, 3, 16, 28, R["crystal"][3])
    cv.line(8, 12, 24, 12, R["crystal"][1])


def g_essence(cv):
    """Thiên Phú Tinh Hoa."""
    glow(cv, 16, 16, 15, R["gold"][3], 110)
    cv.shade_ellipse(16, 16, 8, 8, R["gold"])
    for a in range(0, 360, 90):
        r = math.radians(a)
        cv.line(16, 16, 16 + math.cos(r) * 12, 16 + math.sin(r) * 12, R["gold"][3])
    cv.ellipse(16, 16, 3, 3, (255, 255, 255, 255))


def g_tinh_kim(cv):
    cv.shade_poly([(5, 24), (9, 15), (25, 15), (28, 24)], R["steel"])
    cv.shade_poly([(9, 15), (12, 9), (22, 9), (25, 15)], R["white"])
    cv.line(12, 11, 20, 11, (255, 255, 255, 255))
    glow(cv, 21, 10, 3, (255, 255, 255, 255), 200)


def g_torch(cv):
    cv.shade_poly([(14, 15), (18, 15), (17, 29), (15, 29)], R["wood"])
    cv.rect(13, 14, 19, 17, R["leather"][1])
    glow(cv, 16, 9, 10, R["fire"][2], 110)
    cv.shade_poly([(16, 1), (20, 8), (19, 13), (13, 13), (12, 8)], R["fire"])
    cv.shade_poly([(16, 6), (18, 10), (16, 13), (14, 10)], [R["fire"][3]] * 4)


def g_herb(cv):
    cv.line(16, 28, 16, 12, R["leaf"][2], 1.4)
    for (x, y, rx, ry) in ((10, 17, 5, 3), (22, 14, 5, 3), (11, 9, 4, 2.5), (20, 22, 4, 2.5)):
        cv.shade_ellipse(x, y, rx, ry, R["leaf_light"])
    cv.ellipse(16, 8, 2.4, 2.4, hexc("#e8f7a0"))


def g_potion(cv):
    cv.rect(13, 3, 19, 7, R["wood"][2])
    cv.shade_poly([(13, 7), (19, 7), (19, 12), (25, 18), (25, 26), (21, 29), (11, 29), (7, 26), (7, 18), (13, 12)], [hexc("#9aa8c0", 255)] * 4)
    cv.shade_poly([(8, 19), (24, 19), (24, 26), (21, 28), (11, 28), (8, 26)], R["blood"])
    cv.set(10, 20, (255, 255, 255, 255))
    cv.line(10, 14, 12, 12, (255, 255, 255, 180))


# ====================================================================== kỹ năng
def _skill_bg(cv, hex_bg):
    cv.shade_poly([(2, 4), (4, 2), (28, 2), (30, 4), (30, 28), (28, 30), (4, 30), (2, 28)],
                  [mix(hexc(hex_bg), (0, 0, 0, 255), 0.5), hexc(hex_bg), mix(hexc(hex_bg), (255, 255, 255, 255), 0.15), mix(hexc(hex_bg), (255, 255, 255, 255), 0.25)])


def g_skill_slash(cv):
    _skill_bg(cv, "#3a3550")
    cv.arc(10, 22, 16, math.radians(-80), math.radians(5), (255, 255, 255, 120), 4)
    cv.arc(10, 22, 16, math.radians(-75), math.radians(0), (255, 255, 255, 255), 1.4)
    g_sword(cv, 0.7, 2, 2)


def g_skill_spin(cv):
    _skill_bg(cv, "#28405a")
    for i in range(3):
        a0 = math.radians(i * 120)
        cv.arc(16, 16, 10, a0, a0 + math.radians(85), hexc("#c8e6ff"), 2.2)
        cv.arc(16, 16, 6, a0 + 0.6, a0 + math.radians(70) + 0.6, hexc("#ffffff"), 1.2)
    cv.ellipse(16, 16, 2, 2, (255, 255, 255, 255))


def g_skill_dodge(cv):
    _skill_bg(cv, "#2c4a3a")
    for i, y in enumerate((10, 16, 22)):
        cv.line(4 + i * 2, y, 15 + i, y, (220, 255, 230, 140 + i * 30), 1.4)
    cv.shade_poly([(16, 9), (22, 9), (22, 17), (27, 19), (27, 23), (15, 23)], R["leather"])
    cv.rect(15, 21.5, 27, 23.5, R["leather"][0])


def g_skill_potion(cv):
    _skill_bg(cv, "#4a2430")
    tmp = _new()
    g_potion(tmp)
    cv.paste(tmp, 0, 0)


# ====================================================================== biểu tượng Thiên phú
def g_shield_plus(cv):
    cv.shade_poly([(9, 8), (16, 5), (23, 8), (22, 18), (16, 25), (10, 18)], R["steel"])
    cv.rect(15, 9, 17, 21, R["blood"][2])
    cv.rect(11, 14, 21, 16, R["blood"][2])


def g_bolt(cv):
    cv.shade_poly([(18, 4), (10, 17), (15, 17), (13, 27), (22, 13), (17, 13), (20, 4)], R["gold"])


def g_clover(cv):
    for (x, y) in ((12.5, 12.5), (19.5, 12.5), (12.5, 19.5), (19.5, 19.5)):
        cv.shade_ellipse(x, y, 4.2, 4.2, R["leaf_light"])
    cv.line(17, 18, 22, 26, R["leaf"][2], 1.4)


def g_wing_boot(cv):
    cv.shade_poly([(4, 10), (12, 13), (6, 16), (12, 17), (8, 20)], R["white"])
    cv.shade_poly([(12, 7), (18, 7), (18, 18), (25, 20), (25, 25), (11, 25), (12, 16)], R["leather"])
    cv.rect(11, 23, 25, 25.5, R["leather"][0])


def g_blood_sword(cv):
    g_sword(cv, 0.85)
    cv.shade_ellipse(23, 22, 3.4, 4, R["blood"])
    cv.shade_poly([(23, 15), (26, 21), (20, 21)], R["blood"])


def g_hammer(cv):
    cv.shade_poly([(6, 24), (26, 24), (24, 27), (8, 27)], R["stone"])
    cv.rect(10, 21, 22, 24, R["stone"][1])
    cv.line(10, 18, 21, 6, R["wood"][2], 2.2)
    cv.shade_poly([(16, 4), (22, 2), (26, 8), (20, 10)], R["steel"])


def g_magnifier(cv):
    cv.shade_ellipse(18, 21, 5, 3.5, R["gold"])
    cv.arc(13, 13, 7, 0, math.tau, R["wood"][2], 2.2)
    cv.ellipse(13, 13, 5.4, 5.4, (180, 220, 255, 110))
    cv.line(18, 18, 25, 25, R["wood"][2], 2.6)


def g_sword_aura(cv):
    glow(cv, 16, 16, 14, hexc("#c8e6ff"), 120)
    cv.line(16, 4, 16, 22, R["steel"][2], 2.6)
    cv.line(16, 5, 16, 21, R["steel"][3])
    cv.line(11, 21, 21, 21, R["gold"][2], 1.8)
    cv.line(16, 22, 16, 27, R["leather"][2], 2)


def g_leaf_potion(cv):
    tmp = _new()
    g_potion(tmp)
    small = Canvas(32, 32)
    for y in range(0, 32, 1):
        for x in range(0, 32, 1):
            p = tmp.get(x, y)
            if p:
                small.set(6 + x * 0.65, 9 + y * 0.65, p)
    cv.paste(small)
    cv.shade_ellipse(22, 9, 5, 3, R["leaf_light"])
    cv.line(17, 13, 25, 6, R["leaf"][1])


def g_crown_heart(cv):
    cv.shade_poly([(8, 12), (11, 5), (14, 10), (16, 4), (18, 10), (21, 5), (24, 12)], R["gold"])
    cv.shade_ellipse(12.5, 18, 4.2, 3.8, R["blood"])
    cv.shade_ellipse(19.5, 18, 4.2, 3.8, R["blood"])
    cv.shade_poly([(8.5, 19), (23.5, 19), (16, 27)], R["blood"])


def g_paw(cv):
    cv.shade_ellipse(16, 20, 6, 5, R["dirt"])
    for (x, y) in ((9, 13), (13.5, 9), (18.5, 9), (23, 13)):
        cv.shade_ellipse(x, y, 2.6, 3, R["dirt"])


def g_eye(cv):
    cv.shade_poly([(4, 16), (10, 10), (22, 10), (28, 16), (22, 22), (10, 22)], R["white"])
    cv.shade_ellipse(16, 16, 5, 5, R["gold"])
    cv.ellipse(16, 16, 2, 3, (20, 14, 24, 255))
    cv.set(14, 14, (255, 255, 255, 255))


def g_fang_drop(cv):
    cv.shade_poly([(10, 5), (16, 5), (14, 22)], R["white"])
    cv.shade_poly([(17, 5), (23, 5), (19, 18)], R["white"])
    cv.shade_ellipse(21, 24, 3.4, 3.6, R["blood"])
    cv.shade_poly([(21, 17), (24, 23), (18, 23)], R["blood"])


def g_gold_hand(cv):
    cv.shade_poly([(9, 27), (8, 16), (10, 14), (11, 18), (11, 7), (14, 7), (14, 15), (15, 5), (18, 5), (18, 15), (19, 7), (22, 7), (22, 16), (24, 13), (26, 15), (22, 27)], R["gold"])
    glow(cv, 16, 16, 14, R["gold"][3], 60)


def g_five_elements(cv):
    cols = ["#e6e6e6", "#5bd16a", "#4a9df8", "#ff7040", "#c89650"]
    for i, c in enumerate(cols):
        a = math.radians(-90 + i * 72)
        x, y = 16 + math.cos(a) * 9, 16 + math.sin(a) * 9
        cv.shade_ellipse(x, y, 3.6, 3.6, [mix(hexc(c), (0, 0, 0, 255), 0.5), mix(hexc(c), (0, 0, 0, 255), 0.25), hexc(c), mix(hexc(c), (255, 255, 255, 255), 0.4)])
    cv.ellipse(16, 16, 2, 2, (255, 255, 255, 255))


def g_hourglass(cv):
    cv.rect(8, 4, 24, 7, R["wood"][2])
    cv.rect(8, 25, 24, 28, R["wood"][2])
    cv.shade_poly([(10, 7), (22, 7), (17, 16), (22, 25), (10, 25), (15, 16)], [hexc("#a8c8e8")] * 4)
    cv.shade_poly([(12, 9), (20, 9), (16, 15)], R["gold"])
    cv.shade_poly([(16, 19), (21, 24), (11, 24)], R["gold"])


def g_shadow_pack(cv):
    for (x, y, k) in ((9, 16, 0.85), (23, 16, 0.85), (16, 18, 1.0)):
        cv.shade_ellipse(x, y, 5 * k, 5 * k, R["void"])
        cv.shade_poly([(x - 4 * k, y - 3 * k), (x - 2.5 * k, y - 8 * k), (x - 0.5 * k, y - 4 * k)], R["void"])
        cv.shade_poly([(x + 0.5 * k, y - 4 * k), (x + 2.5 * k, y - 8 * k), (x + 4 * k, y - 3 * k)], R["void"])
        cv.set(x - 2, y, hexc("#ff3b4e"))
        cv.set(x + 2, y, hexc("#ff3b4e"))


def g_compass(cv):
    cv.shade_ellipse(16, 16, 11, 11, R["gold"])
    cv.ellipse(16, 16, 8.5, 8.5, hexc("#1e2c4a"))
    cv.shade_poly([(16, 6), (18.5, 16), (16, 26), (13.5, 16)], R["white"])
    cv.shade_poly([(16, 6), (18.5, 16), (13.5, 16)], R["blood"])
    for (x, y) in ((10, 10), (22, 11), (21, 22)):
        cv.set(x, y, (255, 255, 200, 255))


def g_dragon(cv):
    pts = []
    for i in range(40):
        t = i / 39
        pts.append((6 + t * 18, 22 - math.sin(t * math.pi * 1.6) * 7))
    for i in range(len(pts) - 1):
        w = 4.2 - 2.4 * (i / len(pts))
        cv.line(*pts[i], *pts[i + 1], R["leaf_light"][2] if i % 6 < 3 else R["leaf_light"][1], w)
    cv.shade_ellipse(25, 11, 4, 3.4, R["leaf_light"])
    cv.shade_poly([(23, 8), (21, 3), (26, 8)], R["gold"])
    cv.set(26, 10, hexc("#ff3b4e"))
    cv.line(28, 12, 31, 14, R["gold"][3])


def g_mask(cv):
    cv.shade_poly([(4, 12), (10, 9), (16, 11), (22, 9), (28, 12), (26, 19), (19, 20), (16, 17), (13, 20), (6, 19)], R["void"])
    cv.ellipse(10.5, 14.5, 2.5, 1.8, hexc("#ff3b4e"))
    cv.ellipse(21.5, 14.5, 2.5, 1.8, hexc("#ff3b4e"))
    cv.line(4, 14, 1, 22, R["void"][2], 1.4)
    cv.line(28, 14, 31, 22, R["void"][2], 1.4)


def talent_icon(glyph, rank, group):
    cv = _new()
    bg = hexc(GROUP_BG[group])
    cv.shade_ellipse(16, 16, 15, 15, [mix(bg, (0, 0, 0, 255), 0.4), bg, mix(bg, (255, 255, 255, 255), 0.12), mix(bg, (255, 255, 255, 255), 0.22)])
    rc = hexc(RANK_HEX[rank])
    cv.arc(16, 16, 14.2, 0, math.tau, rc, 1.6)
    inner = _new()
    globals()[glyph](inner)
    # thu nhỏ biểu tượng còn 78% vào giữa huy hiệu
    inner2 = _new()
    for y in range(32):
        for x in range(32):
            sx, sy = round(16 + (x - 16) / 0.78), round(16 + (y - 16) / 0.78)
            p = inner.get(sx, sy)
            if p and math.hypot(x - 16, y - 16) < 13.5:
                inner2.set(x, y, p)
    inner2.outline(OUTLINE)
    cv.paste(inner2)
    if rank in ("SS", "SSS"):
        for a in range(0, 360, 45):
            r = math.radians(a)
            cv.set(16 + math.cos(r) * 14.2, 16 + math.sin(r) * 14.2, (255, 255, 255, 255))
    return cv


def g_bark(cv):
    """Vỏ Lão Thụ (bùa Cam, C1-23)."""
    glow(cv, 16, 16, 15, hexc("#ff9a3c"), 60)
    cv.line(10, 3, 16, 9, R["leather"][2], 1.2)
    cv.line(22, 3, 16, 9, R["leather"][2], 1.2)
    cv.shade_poly([(9, 10), (23, 10), (25, 22), (16, 29), (7, 22)], R["bark"])
    for x in (12, 16, 20):
        cv.line(x, 12, x - 1, 25, R["bark"][0])
    cv.shade_ellipse(16, 17, 3.2, 3.2, R["purple"])
    cv.set(15, 16, (255, 255, 255, 255))


def g_huyen_mask(cv):
    """Mặt Nạ Huyền Ảnh (mũ Cam, M4.2)."""
    glow(cv, 16, 16, 15, hexc("#ff9a3c"), 60)
    cv.shade_poly([(6, 9), (16, 5), (26, 9), (25, 20), (16, 28), (7, 20)], R["void"])
    cv.shade_poly([(9, 13), (14, 12), (14, 16), (9, 16)], [hexc("#140a22")] * 4)
    cv.shade_poly([(18, 12), (23, 13), (23, 16), (18, 16)], [hexc("#140a22")] * 4)
    cv.set(11, 14, hexc("#ff3b4e"))
    cv.set(21, 14, hexc("#ff3b4e"))
    cv.line(16, 5, 16, 26, R["gold"][2])
    cv.line(8, 22, 24, 22, R["gold"][1])


ITEMS = {"weapon": g_sword, "helm": g_helm, "armor": g_armor, "gloves": g_gloves, "boots": g_boots,
         "necklace": g_necklace, "ring": g_ring, "amulet": g_amulet, "wolf_fang": g_wolf_fang, "lao_thu_bark": g_bark, "huyen_anh_mask": g_huyen_mask}
RESOURCES = {"gold": g_gold, "wood": g_wood, "stone": g_stone, "essence": g_essence, "tinh_kim": g_tinh_kim,
             "torch": g_torch, "herb": g_herb, "potion": g_potion}
# ---------------------------------------------------------------------- kỹ năng M3 (03-mvp-spec mục 5.4)
def _bow(cv, ox=0, oy=0, pull=0.0):
    cv.arc(13 + ox, 16 + oy, 11, math.radians(-75), math.radians(75), R["wood"][2], 2.0)
    top = (13 + ox + math.cos(math.radians(-75)) * 11, 16 + oy + math.sin(math.radians(-75)) * 11)
    bot = (13 + ox + math.cos(math.radians(75)) * 11, 16 + oy + math.sin(math.radians(75)) * 11)
    mid = (13 + ox - pull, 16 + oy)
    cv.line(*top, *mid, (235, 235, 225, 255))
    cv.line(*bot, *mid, (235, 235, 225, 255))


def _arrow(cv, x0, y0, x1, y1, shaft=None, head=None):
    shaft = shaft or R["wood"][3]
    head = head or R["steel"][3]
    cv.line(x0, y0, x1, y1, shaft, 1.2)
    a = math.atan2(y1 - y0, x1 - x0)
    for side in (2.5, -2.5):
        cv.line(x1, y1, x1 - math.cos(a + side * 0.3) * 4, y1 - math.sin(a + side * 0.3) * 4, head, 1.2)
    cv.line(x0, y0, x0 - math.cos(a + 0.6) * 3, y0 - math.sin(a + 0.6) * 3, hexc("#c84040"))
    cv.line(x0, y0, x0 - math.cos(a - 0.6) * 3, y0 - math.sin(a - 0.6) * 3, hexc("#c84040"))


def g_skill_shot(cv):
    _skill_bg(cv, "#3a4a2c")
    _bow(cv, -2, 0, 4)
    _arrow(cv, 7, 16, 27, 16)


def g_skill_dash(cv):
    _skill_bg(cv, "#4a2c2c")
    for i, y in enumerate((9, 14, 19, 24)):
        cv.line(3 + i, y, 12 + i * 2, y, (255, 220, 200, 120 + i * 30), 1.2)
    g_sword(cv, 0.75, 4, 0)


def g_skill_wave(cv):
    _skill_bg(cv, "#28405a")
    for i, r in enumerate((11, 8, 5)):
        cv.arc(8 + i * 3, 16, r, math.radians(-70), math.radians(70), hexc("#c8e6ff") if i else hexc("#ffffff"), 2.4 - i * 0.5)
    cv.line(4, 16, 10, 16, (200, 230, 255, 160), 1.2)


def g_skill_guard(cv):
    _skill_bg(cv, "#3a3a4a")
    cv.shade_poly([(8, 7), (16, 4), (24, 7), (23, 18), (16, 27), (9, 18)], R["steel"])
    cv.shade_poly([(12, 9), (16, 7.5), (20, 9), (19.5, 17), (16, 22), (12.5, 17)], R["crystal"])
    cv.line(16, 8, 16, 21, (255, 255, 255, 200))


def g_skill_rain(cv):
    _skill_bg(cv, "#2c3a4a")
    for (x, y) in ((7, 5), (14, 3), (21, 6), (10, 13), (18, 12), (25, 14)):
        _arrow(cv, x + 2, y, x - 1, y + 9)
    cv.shade_ellipse(16, 26, 11, 2.5, [hexc("#ff5470", 160)] * 4)


def g_skill_pierce(cv):
    _skill_bg(cv, "#3a2c4a")
    glow(cv, 16, 16, 12, hexc("#c28af0"), 90)
    _arrow(cv, 3, 25, 28, 6, R["purple"][3], (255, 255, 255, 255))
    for (x, y) in ((11, 19), (19, 13)):
        cv.ellipse(x, y, 2.4, 2.4, (255, 255, 255, 110))


def g_skill_trap(cv):
    _skill_bg(cv, "#4a3a20")
    cv.shade_ellipse(16, 20, 11, 5, R["steel"])
    for i in range(7):
        x = 7 + i * 3
        cv.shade_poly([(x - 1.4, 19), (x, 10 + (i % 2) * 3), (x + 1.4, 19)], R["white"])
    cv.ellipse(16, 21, 3, 1.4, R["blood"][2])


def g_skill_eagle(cv):
    _skill_bg(cv, "#4a3a12")
    glow(cv, 16, 16, 13, R["gold"][3], 80)
    g_eye(cv)


SKILLS = {"slash": g_skill_slash, "spin": g_skill_spin, "dodge": g_skill_dodge, "potion": g_skill_potion,
          "shot": g_skill_shot, "dash": g_skill_dash, "wave": g_skill_wave, "guard": g_skill_guard,
          "rain": g_skill_rain, "pierce": g_skill_pierce, "trap": g_skill_trap, "eagle": g_skill_eagle}


def build_all():
    out = {}
    for k, fn in ITEMS.items():
        cv = _new(); fn(cv); out["item-" + k] = _done(cv).to_image()
    for k, fn in RESOURCES.items():
        cv = _new(); fn(cv); out["res-" + k] = _done(cv).to_image()
    for k, fn in SKILLS.items():
        cv = _new(); fn(cv); out["skill-" + k] = _done(cv).to_image()
    for tid, rank, group, glyph in TALENTS:
        out["talent-" + tid] = talent_icon(glyph, rank, group).to_image()
    return out
