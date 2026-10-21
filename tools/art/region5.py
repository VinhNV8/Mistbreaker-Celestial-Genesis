"""M8 (docs/12): hình vùng 5 Núi Viêm Long — quái, boss, NPC, đồ Cam, tài nguyên, môi trường.

Tách riêng khỏi catalog.py / icons.py / env.py để các chương làm song song không sửa cùng file.
catalog.py, icons.py, env.py chỉ gọi register_*() ở cuối file.
Hệ Hỏa: đỏ cam, đá đen, tro xám.
"""
import math
import random

from pixel import Canvas, R, OUTLINE, glow, hexc, mix, ramp

# Dải màu riêng vùng 5 (thêm vào R để builder/icon dùng được bằng tên).
PALETTE = {
    "lava": ramp("#5a1408", "#b3300c", "#ff7a1a", "#ffd23c"),
    "basalt": ramp("#14121a", "#2a2630", "#45404c", "#6a6470"),
    "ash": ramp("#3a3638", "#5c5658", "#868082", "#b4aeac"),
    "ember": ramp("#6a1a10", "#a8321c", "#e0562a", "#ff9a5a"),
    "bone": ramp("#6e6658", "#a49a86", "#d2c8b2", "#f4ecd8"),
}


def register_palette():
    for k, v in PALETTE.items():
        R.setdefault(k, v)


register_palette()


# ====================================================================== builder: rồng có cánh
def dragon(spec):
    """Rồng (Viêm Long, Rồng Non Lửa): thân thú 4 chân + đôi cánh vẽ phía sau thân.
    spec như quadruped + wing (dải màu), wing_span (hệ số, mặc định 1)."""
    from builders import quadruped
    size = spec.get("size", 48)
    s = size / 24.0
    wing = R[spec.get("wing", "ember")]
    span = spec.get("wing_span", 1.0)
    rows = quadruped(spec)
    out = []
    for name, frames in rows:
        new_frames = []
        for i, fr in enumerate(frames):
            flap = (1.5 if i % 2 else 0.0) if name in ("idle", "run") else (2.5 if name == "attack" else 0.5)
            cv = Canvas(fr.w, fr.h)
            S = lambda v: v * s
            # gốc cánh ở lưng (bx≈11, by≈13 theo khung 24 của quadruped)
            root = (S(10.5), S(10.5))
            f = flap * 0.5
            tips = [(S(10.5 - 8.5 * span), S(2.5 + f)), (S(10.5 - 4.5 * span), S(0.5 + f)), (S(10.5 + 1.5 * span), S(0.2 + f)),
                    (S(10.5 + 5.5 * span), S(2.0 + f))]
            dips = [(S(10.5 - 6.5 * span), S(6.0 + f)), (S(10.5 - 2.5 * span), S(4.8 + f)), (S(10.5 + 2.5 * span), S(5.0 + f))]
            pts = [root, tips[0], dips[0], tips[1], dips[1], tips[2], dips[2], tips[3], (S(13.5), S(10))]
            cv.shade_poly(pts, wing)
            for t in tips:
                cv.line(*root, *t, wing[0], S(0.55))
            cv.outline(OUTLINE)
            cv.paste(fr)
            new_frames.append(cv)
        out.append((name, new_frames))
    return out


def phoenix(spec):
    """Phượng Hoàng: chim lửa (builder bird) + hào quang + đuôi lửa dài phía sau."""
    from builders import bird
    rows = bird(spec)
    out = []
    for name, frames in rows:
        new_frames = []
        for i, fr in enumerate(frames):
            cv = Canvas(fr.w, fr.h)
            glow(cv, fr.w / 2, fr.h / 2 - 2, fr.w / 2 - 1, hexc("#ff7a1a"), 70)
            wave = 1.0 if i % 2 else 0.0
            for k, (dy, col) in enumerate(((0.0, R["lava"][2]), (1.6, R["fire"][3]), (-1.4, R["ember"][2]))):
                cv.line(fr.w * 0.38, fr.h * 0.52, 1.0, fr.h * 0.62 + dy + wave * (k - 1), col, 1.4 - 0.3 * k)
            cv.paste(fr)
            new_frames.append(cv)
        out.append((name, new_frames))
    return out


def register_builders():
    from builders import BUILDERS
    BUILDERS.setdefault("dragon", dragon)
    BUILDERS.setdefault("phoenix", phoenix)


# ====================================================================== sprite
SPRITES5 = {
    # quái thường
    "than-lan-lua": {"builder": "quadruped", "name": "Thằn Lằn Lửa", "size_mul": 0.9,
                     "spec": {"size": 24, "fur": "ember", "mane": "lava", "eye": "#ffd23c"}},
    "nguoi-da": {"builder": "humanoid", "name": "Người Đá Dung Nham", "size_mul": 1.4,
                 "spec": {"skin": "basalt", "cloth": "basalt", "pants": "basalt", "boots": "basalt", "hair_style": "none",
                          "trim": "lava", "weapon": "none", "collar": "lava"}},
    "manh-da": {"builder": "insect", "name": "Mảnh Đá", "size_mul": 0.7,
                "spec": {"shell": "basalt", "leg": "ash", "eye": "#ff9a3c"}},
    "linh-hon-lua": {"builder": "wisp", "name": "Linh Hồn Lửa", "spec": {"body": "lava", "glow": "#ff9a3c"}},
    "phap-su-hoa-diem": {"builder": "humanoid", "name": "Pháp Sư Hoả Diệm",
                         "spec": {"cloth": "ember", "pants": "basalt", "hood": True, "trim": "gold", "weapon": "staff",
                                  "robe": True, "orb": "fire", "skin": "skin_dark"}},
    # tinh anh
    "rong-non": {"builder": "dragon", "name": "Rồng Non Lửa", "size_mul": 0.8,
                 "spec": {"size": 48, "fur": "ember", "mane": "lava", "eye": "#ffd23c", "wing": "lava", "wing_span": 0.8}},
    "tho-ren-hu-vo": {"builder": "humanoid", "name": "Thợ Rèn Hư Vô", "size_mul": 1.25,
                      "spec": {"cloth": "basalt", "pants": "leather", "skin": "skin_dark", "hair": "hair_dark", "trim": "void",
                               "weapon": "sword", "cape": "void"}},
    # Công Trại: lính Thương hội Kim Luân
    "linh-kim-luan": {"builder": "humanoid", "name": "Lính Kim Luân",
                      "spec": {"cloth": "gold", "pants": "steel", "hood": True, "trim": "cloth_red", "weapon": "sword"}},
    "doi-truong-kim-luan": {"builder": "humanoid", "name": "Đội Trưởng Kim Luân", "size_mul": 1.25,
                            "spec": {"cloth": "gold", "pants": "cloth_red", "hair": "hair_dark", "trim": "steel", "weapon": "sword",
                                     "cape": "cloth_red"}},
    # boss
    "vien-long": {"builder": "dragon", "name": "Viêm Long", "size_mul": 2.0,
                  "spec": {"size": 48, "fur": "ember", "mane": "lava", "eye": "#ffd23c", "aura": "#ff7a1a", "wing": "basalt",
                           "wing_span": 1.15, "stripes": "#5a1408"}},
    "phuong-hoang": {"builder": "phoenix", "name": "Phượng Hoàng Tro", "size_mul": 2.2,
                     "spec": {"body": "lava", "wing": "ember", "beak": "#ffd23c", "eye": "#4fc3ff"}},
    # Tử Linh Sư: Xương Nô (đồng minh)
    "xuong-no": {"builder": "humanoid", "name": "Xương Nô",
                 "spec": {"skin": "bone", "cloth": "bone", "pants": "bone", "boots": "bone", "hair_style": "none",
                          "trim": "void", "weapon": "sword"}},
    # NPC Trại Tro Hồng
    "npc-xich-dong": {"builder": "humanoid", "name": "Trưởng tộc Xích Đồng",
                      "spec": {"skin": "skin_dark", "hair": "white", "hair_style": "bui", "cloth": "leather", "pants": "basalt",
                               "trim": "lava", "weapon": "none", "gender": "nam"}},
    "npc-kim-phu": {"builder": "humanoid", "name": "Chưởng quỹ Kim Phú",
                    "spec": {"skin": "skin_light", "cloth": "gold", "pants": "cloth_red", "hood": True, "trim": "gold",
                             "weapon": "none", "gender": "nam"}},
    "npc-liet-dien": {"builder": "humanoid", "name": "Kiếm khách Liệt Diễm",
                      "spec": {"skin": "skin", "hair": "cloth_red", "hair_style": "duoi", "cloth": "basalt", "pants": "leather",
                               "trim": "lava", "weapon": "sword", "cape": "ember"}},
    "npc-tieu-hoa": {"builder": "humanoid", "name": "Tiểu Hoả",
                     "spec": {"skin": "skin_dark", "hair": "hair_brown", "hair_style": "ngan", "cloth": "ember", "pants": "leather",
                              "trim": "gold", "weapon": "none", "gender": "nu"}},
}


def register_sprites(sprites):
    register_builders()
    for k, v in SPRITES5.items():
        sprites.setdefault(k, v)


# ====================================================================== icon
def g_long_tam(cv):
    """Long Tâm (nhẫn Cam): nhẫn đá đen, ngọc lửa."""
    glow(cv, 16, 16, 15, hexc("#ff9a3c"), 70)
    cv.arc(16, 18, 8, 0, math.tau, R["basalt"][2], 2.4)
    cv.arc(16, 18, 8, math.radians(200), math.radians(340), R["gold"][3], 1.0)
    cv.shade_ellipse(16, 10, 4.5, 4.5, R["lava"])
    cv.set(15, 9, (255, 255, 255, 255))


def g_long_phuong(cv):
    """Lông Phượng (bùa Cam): chiếc lông lửa."""
    glow(cv, 16, 16, 15, hexc("#ff9a3c"), 70)
    cv.shade_poly([(9, 27), (12, 19), (17, 10), (23, 4), (22, 12), (17, 20), (12, 26)], R["lava"])
    cv.line(9, 27, 22, 6, R["gold"][3], 1.0)
    for t in (0.35, 0.55, 0.75):
        x, y = 9 + 13 * t, 27 - 21 * t
        cv.line(x, y, x - 3, y - 1, R["ember"][1], 0.8)


def g_crystal_res(cv):
    """Tinh Thạch: cụm tinh thể đỏ cam."""
    for (x, h, w) in ((11, 14, 4), (17, 18, 5), (22, 11, 3.5)):
        cv.shade_poly([(x - w, 26), (x - w * 0.6, 26 - h), (x, 26 - h - 3), (x + w * 0.6, 26 - h), (x + w, 26)], R["lava"])
        cv.line(x, 26 - h - 2, x, 25, R["lava"][3])
    cv.rect(6, 25, 27, 28, R["basalt"][2])


def g_holy_water(cv):
    """Bình Nước Thánh: lọ nước xanh có ánh sáng."""
    glow(cv, 16, 18, 12, hexc("#4fc3ff"), 60)
    cv.rect(13, 5, 19, 9, R["wood"][2])
    cv.shade_poly([(12, 9), (20, 9), (25, 18), (22, 27), (10, 27), (7, 18)], R["crystal"])
    cv.line(10, 17, 22, 17, (255, 255, 255, 160))
    cv.set(12, 13, (255, 255, 255, 255))


def g_skill_breath(cv):
    """Long Tức (Đạo Tặc sao chép từ Viêm Long)."""
    from icons import _skill_bg
    _skill_bg(cv, "#3a1408")
    cv.shade_ellipse(9, 16, 4, 4, R["basalt"])
    pts = [(12, 14), (27, 6), (29, 16), (27, 26), (12, 18)]
    cv.shade_poly(pts, R["lava"])
    cv.shade_poly([(13, 15), (24, 11), (25, 16), (24, 21), (13, 17)], R["fire"])


ITEMS5 = {"long_tam": g_long_tam, "long_phuong": g_long_phuong}
RESOURCES5 = {"crystal": g_crystal_res, "holy_water": g_holy_water}
SKILLS5 = {"breath": g_skill_breath}


def register_icons(items, resources, skills):
    for src, dst in ((ITEMS5, items), (RESOURCES5, resources), (SKILLS5, skills)):
        for k, v in src.items():
            dst.setdefault(k, v)


# ====================================================================== môi trường
def lava_tile(seed):
    rnd = random.Random(seed)
    cv = Canvas(32, 32)
    lv = R["lava"]
    cv.rect(0, 0, 32, 32, lv[1])
    for _ in range(14):
        x, y = rnd.uniform(0, 32), rnd.uniform(0, 32)
        cv.ellipse(x, y, rnd.uniform(2, 5), rnd.uniform(1.5, 3), lv[2])
    for _ in range(10):
        cv.set(rnd.randrange(32), rnd.randrange(32), lv[3])
    for _ in range(6):
        x, y = rnd.uniform(0, 32), rnd.uniform(0, 32)
        cv.line(x, y, x + rnd.uniform(-6, 6), y + rnd.uniform(-3, 3), lv[0], 1.0)
    return cv


def ash_tile(seed):
    from env import tile
    return tile(R["ash"], seed, tufts=False)


def basalt_tile(seed):
    from env import tile
    return tile(R["basalt"], seed, tufts=False)


def lava_rock(seed):
    """Tảng đá đen có khe dung nham."""
    rnd = random.Random(seed)
    cv = Canvas(30, 22)
    from pixel import shadow
    shadow(cv, 15, 19, 13, 2.5, 100)
    cv.shade_poly([(3, 18), (5, 9), (11, 4), (21, 4), (27, 10), (26, 18)], R["basalt"])
    for _ in range(2):
        x = rnd.uniform(9, 21)
        cv.line(x, 6, x + rnd.uniform(-4, 4), 16, R["lava"][2], 1.0)
    cv.outline(OUTLINE)
    return cv, [15, 18]


def floating_rock():
    """Đá Nổi trong Long Huyệt (an toàn khi dung nham dâng): phiến đá bằng, viền sáng."""
    cv = Canvas(42, 24)
    glow(cv, 21, 13, 20, hexc("#ff7a1a"), 60)
    cv.ellipse(21, 13, 19, 8.5, R["lava"][2])
    cv.shade_ellipse(21, 12.5, 18, 7.5, R["basalt"])
    cv.shade_ellipse(21, 10.5, 14.5, 5, R["ash"])
    cv.outline(OUTLINE)
    return cv, [21, 12]


def ash_tree(seed):
    """Cây chết cháy đen."""
    rnd = random.Random(seed)
    cv = Canvas(26, 40)
    from pixel import shadow
    shadow(cv, 13, 37, 8, 2, 90)
    cv.line(13, 37, 13, 12, R["basalt"][1], 3.0)
    for _ in range(4):
        y = rnd.uniform(12, 26)
        d = rnd.choice((-1, 1))
        cv.line(13, y, 13 + d * rnd.uniform(5, 9), y - rnd.uniform(4, 8), R["basalt"][2], 1.4)
    cv.set(13, 30, R["lava"][2])
    cv.outline(OUTLINE)
    return cv, [13, 37]


def vent():
    """Miệng phun nhỏ bốc khói (trang trí)."""
    cv = Canvas(24, 18)
    cv.shade_ellipse(12, 12, 10, 5, R["basalt"])
    cv.shade_ellipse(12, 11, 5, 2.5, R["lava"])
    glow(cv, 12, 9, 7, hexc("#ff7a1a"), 80)
    cv.outline(OUTLINE)
    return cv, [12, 12]


def forge():
    """Lò rèn của tộc Hỏa Sơn ở Trại Tro Hồng."""
    cv = Canvas(36, 34)
    from pixel import shadow
    shadow(cv, 18, 31, 15, 3, 100)
    cv.shade_poly([(5, 31), (5, 14), (18, 6), (31, 14), (31, 31)], R["stone"])
    cv.rect(13, 20, 23, 31, R["basalt"][0])
    cv.shade_ellipse(18, 26, 4, 3.5, R["lava"])
    glow(cv, 18, 26, 8, hexc("#ff9a3c"), 90)
    cv.rect(24, 2, 29, 12, R["stone"][1])
    cv.outline(OUTLINE)
    return cv, [18, 31]


def meteor_fx():
    """Thiên thạch núi lửa (đang rơi)."""
    cv = Canvas(16, 24)
    cv.shade_poly([(6, 0), (10, 0), (13, 16), (3, 16)], R["fire"])
    cv.shade_poly([(7, 2), (9, 2), (10.5, 15), (5.5, 15)], [hexc("#fff2c8")] * 4)
    cv.shade_ellipse(8, 18, 5, 5, R["basalt"])
    cv.ellipse(8, 18, 2.5, 2.5, R["lava"][3])
    cv.outline(OUTLINE)
    return cv, [8, 18]


def register_env(out):
    """Thêm môi trường vùng 5 vào dict env.build_all() (giá trị: (Canvas, origin))."""
    for i in range(2):
        out.setdefault("tile-lava-%d" % i, (lava_tile(600 + i), [0, 0]))
    out.setdefault("tile-ash", (ash_tile(610), [0, 0]))
    out.setdefault("tile-basalt", (basalt_tile(611), [0, 0]))
    for i in range(2):
        out.setdefault("rock-lava-%d" % i, lava_rock(620 + i))
        out.setdefault("tree-ash-%d" % i, ash_tree(630 + i))
    out.setdefault("floating-rock", floating_rock())
    out.setdefault("vent", vent())
    out.setdefault("forge", forge())
    out.setdefault("fx-meteor", meteor_fx())
