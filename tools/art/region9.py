"""M12 (chương 9): hình vùng 9 Cổng Thiên Đạo — quái, tinh anh, Ma Tôn Vô Diện, Thiên Đạo Hư Ảnh, đồ Cam, môi trường.

Tách riêng như region8.py: catalog.py, icons.py, env.py chỉ gọi register_*() ở cuối file.
Mọi hệ: trắng ngọc, vàng kim, mây; Ma Tôn đen không mặt. Danh sách quái theo docs/06 §Vùng 9, docs/18 C9-20…34.
"""
import random

from pixel import Canvas, R, OUTLINE, glow, hexc, ramp, shadow

PALETTE = {
    "jade": ramp("#6a7a6a", "#a8bca8", "#dce8dc", "#f8fff8"),
    "heaven_gold": ramp("#7a5a1a", "#c0902a", "#f0c850", "#fff4c0"),
    "void_black": ramp("#060408", "#141018", "#2a2232", "#4a3e58"),
    "spirit": ramp("#4a6a8a", "#7aa0c8", "#bcd8f0", "#f0f8ff"),
}


def register_palette():
    for k, v in PALETTE.items():
        R.setdefault(k, v)


register_palette()


SPRITES9 = {
    # quái thường (docs/06 §Vùng 9)
    "thien-binh": {"builder": "humanoid", "name": "Thiên Binh Ngũ Hành",
                   "spec": {"skin": "skin", "cloth": "heaven_gold", "pants": "jade", "boots": "jade", "hood": True,
                            "trim": "white", "weapon": "staff", "orb": "heaven_gold", "collar": "jade"}},
    "tan-hon": {"builder": "wisp", "name": "Tàn Hồn Khai Giới Giả", "size_mul": 1.2, "spec": {"body": "spirit", "glow": "#bcd8f0"}},
    "thien-ma": {"builder": "quadruped", "name": "Thiên Mã", "size_mul": 1.2,
                 "spec": {"size": 24, "fur": "white", "mane": "heaven_gold", "eye": "#7ad0ff", "aura": "#fff4c0"}},
    "linh-thu-ngu-hanh": {"builder": "quadruped", "name": "Ngũ Hành Linh Thú", "size_mul": 1.35,
                          "spec": {"size": 24, "fur": "heaven_gold", "mane": "jade", "eye": "#ff6a3c", "stripes": "#5bd16a"}},
    # tinh anh
    "thien-tuong": {"builder": "humanoid", "name": "Thiên Tướng", "size_mul": 1.45,
                    "spec": {"skin": "skin", "cloth": "heaven_gold", "pants": "steel", "boots": "steel", "hood": True,
                             "trim": "white", "weapon": "sword", "cape": "cloth_red", "aura": "#fff4c0", "collar": "heaven_gold", "shield": True,
                             "shield_face": "heaven_gold"}},
    "ngu-hanh-su-gia": {"builder": "humanoid", "name": "Ngũ Hành Sứ Giả", "size_mul": 1.35,
                        "spec": {"skin": "skin_light", "hair": "white", "hair_style": "dai", "cloth": "jade", "pants": "spirit",
                                 "trim": "heaven_gold", "weapon": "staff", "robe": True, "orb": "crystal", "aura": "#86d8e4"}},
    # boss chương 9 — giáp đen, không mặt (đầu là khoảng trống xoáy sương)
    "ma-ton": {"builder": "humanoid", "name": "Ma Tôn Vô Diện", "size_mul": 2.1,
               "spec": {"skin": "void_black", "cloth": "void_black", "pants": "void_black", "boots": "void_black", "hair_style": "none",
                        "hood": True, "trim": "purple", "weapon": "sword", "cape": "void_black", "collar": "purple", "aura": "#6a3aa8",
                        "eye": "none"}},
    "ma-ton-ao": {"builder": "humanoid", "name": "Ma Tôn Vô Diện", "size_mul": 2.1,
                  "spec": {"skin": "void_black", "cloth": "void_black", "pants": "void_black", "boots": "void_black", "hair_style": "none",
                           "hood": True, "trim": "purple", "weapon": "sword", "cape": "void_black", "collar": "purple", "aura": "#6a3aa8",
                           "eye": "none"}},
    # boss hiếm
    "thien-dao-hu-anh": {"builder": "humanoid", "name": "Thiên Đạo Hư Ảnh", "size_mul": 1.9,
                         "spec": {"skin": "spirit", "hair": "white", "hair_style": "dai", "cloth": "white", "pants": "spirit",
                                  "trim": "heaven_gold", "weapon": "staff", "robe": True, "orb": "heaven_gold", "aura": "#fff4c0"}},
}


def register_sprites(sprites):
    for k, v in SPRITES9.items():
        sprites.setdefault(k, v)


# ====================================================================== icon
def g_mat_na_vo_dien(cv):
    """Mặt Nạ Vô Diện (mũ Cam): mặt nạ đen trơn, khoảng trống xoáy tím giữa mặt, viền vàng."""
    glow(cv, 16, 16, 14, hexc("#6a3aa8"), 70)
    cv.shade_ellipse(16, 16, 9, 11, R["void_black"])
    cv.shade_ellipse(16, 16, 4, 5, R["purple"])
    cv.shade_ellipse(16, 16, 1.6, 2.0, [hexc("#e0c0ff")] * 4)
    for y in (7, 25):
        cv.line(10, y, 22, y, R["heaven_gold"][2], 0.8)


def register_icons(items, resources, skills):
    items.setdefault("mat_na_vo_dien", g_mat_na_vo_dien)


# ====================================================================== môi trường
def heaven_tile(seed):
    rnd = random.Random(seed)
    cv = Canvas(32, 32)
    j = R["jade"]
    cv.rect(0, 0, 32, 32, j[2])
    for (x, y) in ((0, 0), (16, 0), (8, 16), (24, 16)):
        cv.line(x, y + 15.5, x + 16, y + 15.5, j[1], 0.8)
        cv.line(x + 15.5, y, x + 15.5, y + 16, j[1], 0.8)
    for _ in range(4):
        cv.set(rnd.randrange(0, 32), rnd.randrange(0, 32), R["heaven_gold"][3])
    return cv


def heaven_pillar(seed):
    """Cột ngọc Thiên Thê: cột trắng ngọc, đai vàng, đỉnh có ngọc sáng."""
    rnd = random.Random(seed)
    h = rnd.randrange(32, 44)
    cv = Canvas(22, 52)
    shadow(cv, 11, 49, 8, 2, 90)
    top = 49 - h
    cv.shade_poly([(6, 49), (6, top + 3), (16, top + 3), (16, 49)], R["jade"])
    for y in (top + 6, 44):
        cv.line(5, y, 17, y, R["heaven_gold"][2], 1.2)
    glow(cv, 11, top, 6, hexc("#fff4c0"), 120)
    cv.shade_ellipse(11, top, 2.5, 2.5, [hexc("#fff4c0")] * 4)
    cv.outline(OUTLINE)
    return cv, [11, 49]


def register_env(out):
    out.setdefault("tile-heaven", (heaven_tile(990), [0, 0]))
    for i in range(2):
        out.setdefault("heaven-pillar-%d" % i, heaven_pillar(991 + i))
