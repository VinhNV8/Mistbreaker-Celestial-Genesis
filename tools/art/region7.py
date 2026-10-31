"""M10 (chương 7): hình vùng 7 Quần Đảo Thiên Không — quái, tinh anh, boss, boss hiếm, đồ Cam, môi trường.

Tách riêng như region5.py / region6.py: catalog.py, icons.py, env.py chỉ gọi register_*() ở cuối file.
Hệ Kim + Mộc: trắng mây, xanh trời, vàng kim, xanh lá non. Danh sách quái theo docs/06 §Vùng 7.
"""
import random

from pixel import Canvas, R, OUTLINE, glow, hexc, ramp, shadow

PALETTE = {
    "cloud": ramp("#8a9ab8", "#c4d0e4", "#e8eef8", "#ffffff"),
    "sky": ramp("#1e3a6e", "#3a6ab4", "#6ea4e8", "#bcdcff"),
    "sky_gold": ramp("#7a5418", "#c08a2a", "#f0c050", "#fff0b0"),
    "marble": ramp("#6a6a7a", "#a4a4b4", "#d4d4e0", "#f4f4fa"),
    "colossus": ramp("#2a2e3a", "#4a5264", "#7a8498", "#b4bccc"),
    "leaf_sky": ramp("#2a6a3a", "#4aa45a", "#86d47a", "#c8f4a8"),
}


def register_palette():
    for k, v in PALETTE.items():
        R.setdefault(k, v)


register_palette()


# ====================================================================== builder: Thiên Không Cự Thần
def colossus(spec):
    """Người khổng lồ đá – kim loại 48×48 cầm chuỳ: chân cột, thân giáp, lõi vàng sáng giữa ngực, mắt xanh.
    attack = giơ chuỳ → nện xuống. spec: size (48), body, trim, core (hex), eye (hex)."""
    size = spec.get("size", 48)
    s = size / 48.0
    body = R[spec.get("body", "colossus")]
    trim = R[spec.get("trim", "sky_gold")]
    core = hexc(spec.get("core", "#ffd86a"))
    eye = hexc(spec.get("eye", "#7ae0ff"))
    far = [tuple(max(0, int(c * 0.72)) if i < 3 else c for i, c in enumerate(col)) for col in body]

    def frame(bob=0.0, step=0.0, hammer=0.0, smash=0.0, alpha=1.0):
        cv = Canvas(size, size)
        S = lambda v: v * s
        shadow(cv, S(24), S(44.5), S(15), S(3), 100)
        y = bob + smash * 1.5
        # chân (cột đá)
        cv.shade_poly([(S(15 + step), S(44)), (S(16 + step), S(32 + y)), (S(22), S(32 + y)), (S(22 - step * 0.5), S(44))], far)
        cv.shade_poly([(S(26 - step * 0.5), S(44)), (S(26), S(32 + y)), (S(32 - step), S(32 + y)), (S(33 - step), S(44))], body)
        # tay xa
        cv.shade_poly([(S(12), S(20 + y)), (S(8), S(32 + y)), (S(12), S(34 + y)), (S(16), S(22 + y))], far)
        # thân giáp
        cv.shade_poly([(S(13), S(33 + y)), (S(11), S(17 + y)), (S(17), S(12 + y)), (S(31), S(12 + y)), (S(37), S(17 + y)), (S(35), S(33 + y))], body)
        cv.shade_poly([(S(13), S(33 + y)), (S(35), S(33 + y)), (S(34), S(30 + y)), (S(14), S(30 + y))], trim)
        cv.line(S(14), S(17 + y), S(34), S(17 + y), trim[1], S(1.2))
        # lõi vàng
        glow(cv, S(24), S(23 + y), S(6), core, 150)
        cv.shade_ellipse(S(24), S(23 + y), S(3.2), S(3.2), [core] * 4)
        cv.set(S(23), S(22 + y), (255, 255, 240, 255))
        # đầu + mắt
        cv.shade_poly([(S(19), S(13 + y)), (S(19), S(6 + y)), (S(24), S(3 + y)), (S(29), S(6 + y)), (S(29), S(13 + y))], body)
        cv.shade_poly([(S(19), S(7 + y)), (S(24), S(4 + y)), (S(29), S(7 + y)), (S(24), S(5.5 + y))], trim)
        glow(cv, S(26), S(9 + y), S(3), eye, 160)
        cv.rect(S(24), S(8.5 + y), S(28.5), S(10 + y), eye)
        # tay gần + chuỳ: hammer 0 = cầm ngang hông, 1 = giơ cao, smash 1 = nện xuống trước mặt
        if smash > 0.0:
            hx, hy = S(40), S(38)
        elif hammer > 0.0:
            hx, hy = S(36 + hammer * 2), S(18 - hammer * 4 + y)
        else:
            hx, hy = S(40), S(28 + y)
        cv.shade_poly([(S(34), S(18 + y)), (S(38), S(18 + y)), (hx + S(1), hy), (hx - S(3), hy)], body)
        cv.line(hx - S(1), hy, hx + S(5), hy - S(8) if smash == 0 else hy + S(2), R["wood"][1], S(2.0))
        hhx, hhy = (hx + S(5), hy - S(10)) if smash == 0 else (hx + S(3), hy + S(3))
        cv.shade_poly([(hhx - S(5), hhy - S(3)), (hhx + S(5), hhy - S(3)), (hhx + S(5), hhy + S(4)), (hhx - S(5), hhy + S(4))], body)
        cv.rect(hhx - S(5), hhy - S(1), hhx + S(5), hhy + S(0.8), trim[2])
        cv.outline(OUTLINE)
        if smash > 0.6:
            glow(cv, S(43), S(43), S(6), core, 120)
        if alpha < 1.0:
            cv = cv.fade(alpha)
        return cv

    return [
        ("idle", [frame(0), frame(0.8)]),
        ("run", [frame(0, 1.5), frame(0.8, 0), frame(0, -1.5), frame(0.8, 0)]),
        ("attack", [frame(0, hammer=0.6), frame(-1, hammer=1.0), frame(1, smash=1.0)]),
        ("hurt", [frame(1.5)]),
        ("death", [frame(1.5, alpha=0.85), frame(3, smash=1.0, alpha=0.6), frame(5, smash=1.0, alpha=0.35)]),
    ]


# ====================================================================== builder: Neo Hư Vô
def void_pylon(spec):
    """Neo Hư Vô: cột pha lê tím cắm xuống đất, xích đen, nhịp sáng (đứng yên)."""
    size = spec.get("size", 32)

    def frame(pulse=0.0, crack=0, alpha=1.0):
        cv = Canvas(size, size)
        shadow(cv, 16, 29.5, 8, 1.8, 80)
        glow(cv, 16, 14, 10 + pulse * 2, hexc("#9b6ee0"), 90)
        cv.shade_poly([(12, 29), (13, 10), (16, 2), (19, 10), (20, 29)], R["purple"])
        cv.shade_poly([(14, 26), (14.5, 11), (16, 5), (17.5, 11), (18, 26)], R["void"])
        for y in (14, 21):
            cv.line(9, y, 23, y + 2, R["colossus"][0], 1.2)
        for k in range(crack):
            cv.line(16, 12, 13 + k * 3, 24, (255, 255, 255, 180), 0.6)
        cv.outline(OUTLINE)
        return cv.fade(alpha) if alpha < 1.0 else cv

    return [
        ("idle", [frame(0.0), frame(1.0)]),
        ("run", [frame(0.0), frame(0.5), frame(1.0), frame(0.5)]),
        ("attack", [frame(1.0), frame(1.0), frame(0.0)]),
        ("hurt", [frame(0.5, crack=2)]),
        ("death", [frame(0.5, crack=3, alpha=0.8), frame(0, crack=3, alpha=0.5), frame(0, crack=3, alpha=0.25)]),
    ]


def register_builders():
    from builders import BUILDERS
    BUILDERS.setdefault("colossus", colossus)
    BUILDERS.setdefault("void_pylon", void_pylon)


# ====================================================================== sprite
SPRITES7 = {
    # quái thường (docs/06 §Vùng 7)
    "dai-bang-may": {"builder": "bird", "name": "Đại Bàng Mây", "size_mul": 1.25,
                     "spec": {"body": "cloud", "wing": "sky", "beak": "#f0c050", "eye": "#ffd86a"}},
    "nguoi-go-dao": {"builder": "treant", "name": "Người Gỗ Đảo Bay", "size_mul": 1.45,
                     "spec": {"bark": "wood", "leaf": "leaf_sky", "eye": "#c8f4a8"}},
    "tien-gio": {"builder": "humanoid", "name": "Tiên Gió",
                 "spec": {"skin": "skin_light", "hair": "leaf_light", "hair_style": "dai", "cloth": "leaf_sky", "pants": "cloud",
                          "trim": "sky_gold", "weapon": "staff", "robe": True, "orb": "leaf_light", "gender": "nu", "aura": "#a8f0c0"}},
    "hiep-si-thien-khong": {"builder": "humanoid", "name": "Hiệp Sĩ Thiên Không",
                            "spec": {"skin": "skin", "cloth": "steel", "pants": "sky", "boots": "steel", "hood": True,
                                     "trim": "sky_gold", "weapon": "staff", "orb": "steel", "cape": "sky", "collar": "sky_gold"}},
    # tinh anh
    "thu-ho-dao": {"builder": "humanoid", "name": "Thủ Hộ Đảo", "size_mul": 1.45,
                   "spec": {"skin": "skin", "cloth": "marble", "pants": "steel", "boots": "steel", "hood": True,
                            "trim": "sky_gold", "weapon": "sword", "cape": "sky_gold", "aura": "#fff0b0", "collar": "sky_gold"}},
    "rong-may": {"builder": "dragon", "name": "Rồng Mây", "size_mul": 1.0,
                 "spec": {"size": 48, "fur": "leaf_sky", "mane": "cloud", "eye": "#ffffff", "aura": "#c8f4a8", "wing": "cloud",
                          "wing_span": 1.0, "stripes": "#3a6ab4"}},
    # Neo Hư Vô (nhiệm vụ bước 4)
    "neo-hu-vo": {"builder": "void_pylon", "name": "Neo Hư Vô", "size_mul": 1.4, "spec": {"size": 32}},
    # NPC Bến Mây (Tuyết Nga dùng lại npc-tuyet-nga vùng 6)
    "npc-van-hac": {"builder": "humanoid", "name": "Lão đạo Vân Hạc",
                    "spec": {"skin": "skin_light", "hair": "white", "hair_style": "bui", "cloth": "cloud", "pants": "sky",
                             "trim": "sky_gold", "weapon": "staff", "robe": True, "orb": "sky_gold", "gender": "nam"}},
    "npc-phong-linh": {"builder": "humanoid", "name": "Thuyền trưởng Phong Linh",
                       "spec": {"skin": "skin", "hair": "hair_brown", "hair_style": "dai", "cloth": "cloth_red", "pants": "leather",
                                "trim": "sky_gold", "weapon": "none", "cape": "sky", "gender": "nu"}},
    # boss chương 7
    "cu-than": {"builder": "colossus", "name": "Thiên Không Cự Thần", "size_mul": 2.3, "spec": {"size": 48}},
    # boss hiếm
    "ky-lan-may": {"builder": "quadruped", "name": "Kỳ Lân Mây", "size_mul": 1.25,
                   "spec": {"size": 48, "fur": "leaf_sky", "mane": "sky_gold", "eye": "#bcdcff", "aura": "#9ad8ff", "stripes": "#f0c050"}},
}


def register_sprites(sprites):
    import region5  # noqa: F401 — builder dragon
    region5.register_builders()
    register_builders()
    for k, v in SPRITES7.items():
        sprites.setdefault(k, v)


# ====================================================================== icon
def g_bua_cu_than(cv):
    """Búa Cự Thần (vũ khí Cam): chuỳ đá – kim loại, sóng chấn vàng."""
    glow(cv, 16, 16, 15, hexc("#ffd86a"), 60)
    cv.line(9, 27, 19, 13, R["wood"][1], 2.4)
    cv.shade_poly([(14, 6), (25, 9), (23, 18), (12, 15)], R["colossus"])
    cv.shade_poly([(13.5, 10), (24.5, 13), (24, 14.5), (13, 11.5)], R["sky_gold"])
    cv.shade_ellipse(19, 12, 1.6, 1.6, [hexc("#ffd86a")] * 4)
    for x0 in (5, 8):
        cv.line(x0, 29, x0 + 4, 25, (255, 230, 150, 160), 1.0)


def g_sung_ky_lan(cv):
    """Sừng Kỳ Lân (dây chuyền Cam): sừng xoắn treo dây vàng, tia sấm."""
    glow(cv, 16, 18, 14, hexc("#9ad8ff"), 60)
    for i in range(9):
        x = 6 + i * 2.5
        cv.set(x, 6 + abs(i - 4) * 1.4, R["sky_gold"][2])
    cv.shade_poly([(13, 12), (19, 12), (16.5, 28), (15.5, 28)], R["cloud"])
    for y in (15, 19, 23):
        cv.line(13.8, y, 18.2, y + 1.5, R["sky_gold"][1], 0.8)
    cv.line(22, 14, 24, 18, (200, 240, 255, 220), 1.0)
    cv.line(24, 18, 22.5, 19, (200, 240, 255, 220), 1.0)
    cv.line(22.5, 19, 25, 24, (200, 240, 255, 220), 1.0)


def g_feather(cv):
    """Lông Vũ Gió: chiếc lông trắng xanh, vệt gió."""
    glow(cv, 16, 16, 13, hexc("#bcdcff"), 60)
    cv.shade_poly([(8, 27), (11, 18), (16, 9), (23, 4), (21, 12), (16, 20), (10, 26)], R["cloud"])
    cv.line(8, 27, 22, 6, R["sky"][1], 1.0)
    for x in (5, 9):
        cv.line(x, 12, x + 6, 10, (190, 230, 255, 170), 1.0)


ITEMS7 = {"bua_cu_than": g_bua_cu_than, "sung_ky_lan": g_sung_ky_lan}
RESOURCES7 = {"feather": g_feather}


def register_icons(items, resources, skills):
    for k, v in ITEMS7.items():
        items.setdefault(k, v)
    for k, v in RESOURCES7.items():
        resources.setdefault(k, v)


# ====================================================================== môi trường
def cloud_grass_tile(seed):
    from env import tile
    return tile(R["leaf_sky"], seed, tufts=True)


def marble_tile(seed):
    rnd = random.Random(seed)
    cv = Canvas(32, 32)
    m = R["marble"]
    cv.rect(0, 0, 32, 32, m[2])
    for (x, y) in ((0, 0), (16, 0), (8, 16), (24, 16)):
        cv.line(x, y + 15.5, x + 16, y + 15.5, m[1], 0.8)
        cv.line(x + 15.5, y, x + 15.5, y + 16, m[1], 0.8)
    for _ in range(6):
        x, y = rnd.uniform(0, 32), rnd.uniform(0, 32)
        cv.line(x, y, x + rnd.uniform(-5, 5), y + rnd.uniform(-3, 3), m[0], 0.6)
    return cv


def cloud_puff(seed):
    """Cụm mây ở mép đảo (vẽ chồng quanh mép đảo bay)."""
    rnd = random.Random(seed)
    cv = Canvas(40, 22)
    for _ in range(6):
        cv.shade_ellipse(rnd.uniform(9, 31), rnd.uniform(10, 14), rnd.uniform(6, 9), rnd.uniform(4, 6), R["cloud"])
    return cv, [20, 14]


def hanging_tree(seed):
    """Cây rừng treo: tán tròn xanh non, dây leo rủ xuống."""
    rnd = random.Random(seed)
    cv = Canvas(34, 48)
    shadow(cv, 17, 45, 11, 2.5, 90)
    cv.rect(15, 28, 19, 45, R["bark"][1])
    cv.shade_ellipse(17, 18, 14, 11, R["leaf_sky"])
    cv.shade_ellipse(11, 15, 6, 5, R["leaf_sky"])
    for _ in range(5):
        x = rnd.uniform(6, 28)
        cv.line(x, 22, x + rnd.uniform(-1, 1), 22 + rnd.uniform(8, 16), R["leaf"][1], 1.0)
    for _ in range(4):
        cv.set(rnd.randrange(8, 26), rnd.randrange(10, 22), R["leaf_sky"][3])
    cv.outline(OUTLINE)
    return cv, [17, 45]


def sky_pillar(seed):
    """Cột Thiên Cung đổ nát: cột đá cẩm thạch gãy, đường viền vàng."""
    rnd = random.Random(seed)
    h = rnd.randrange(30, 44)
    cv = Canvas(22, 50)
    shadow(cv, 11, 47, 8, 2, 90)
    cv.rect(3, 42, 19, 47, R["marble"][1])
    top = 47 - h
    cv.shade_poly([(6, 42), (6, top + 3), (9, top), (13, top + 2), (16, top), (16, 42)], R["marble"])
    for x in (9, 13):
        cv.line(x, top + 4, x, 41, R["marble"][1], 0.8)
    cv.line(5, 40, 17, 40, R["sky_gold"][1], 1.0)
    cv.outline(OUTLINE)
    return cv, [11, 47]


def airship_dock():
    """Cảng Khí Cầu: bến gỗ, khí cầu nhỏ buộc dây."""
    cv = Canvas(48, 56)
    shadow(cv, 24, 53, 18, 3, 90)
    cv.shade_poly([(4, 52), (6, 44), (42, 44), (44, 52)], R["wood"])
    for x in (8, 20, 32, 40):
        cv.rect(x, 44, x + 2, 53, R["wood"][0])
    cv.line(24, 44, 24, 26, R["leather"][1], 0.8)
    cv.shade_ellipse(24, 14, 13, 11, R["cloth_red"])
    cv.line(13, 14, 35, 14, R["sky_gold"][2], 1.0)
    cv.shade_poly([(19, 26), (29, 26), (28, 31), (20, 31)], R["wood"])
    cv.outline(OUTLINE)
    return cv, [24, 52]


def wind_bridge():
    """Cầu gió: dải ánh sáng xanh trời có vân (vẽ lặp theo chiều dài cầu)."""
    cv = Canvas(32, 32)
    for y in range(32):
        a = 120 + int(60 * (1 - abs(y - 16) / 16))
        cv.line(0, y + 0.5, 32, y + 0.5, (110, 190, 255, a), 1.0)
    for x in (4, 14, 24):
        cv.line(x, 6, x + 6, 26, (220, 245, 255, 200), 1.0)
    return cv


def anchor_stone(lit):
    """Đá Neo: cột đá có dây xích, sáng xanh khi đã chạm."""
    cv = Canvas(24, 44)
    shadow(cv, 12, 41, 8, 2, 90)
    if lit:
        glow(cv, 12, 14, 11, hexc("#7ae0ff"), 110)
    cv.shade_poly([(6, 41), (7, 12), (12, 6), (17, 12), (18, 41)], R["marble"])
    for y in (18, 26, 34):
        cv.line(4, y, 20, y + 2, R["colossus"][1], 1.2)
    cv.shade_ellipse(12, 13, 2.6, 2.6, R["sky"] if lit else R["stone"])
    cv.outline(OUTLINE)
    return cv, [12, 41]


def wind_pillar(lit):
    """Trụ Gió: cột cẩm thạch, vòng gió xoáy quanh đỉnh khi đã kích."""
    cv = Canvas(30, 56)
    shadow(cv, 15, 53, 9, 2.2, 90)
    cv.shade_poly([(9, 53), (10, 14), (20, 14), (21, 53)], R["marble"])
    cv.rect(7, 10, 23, 15, R["sky_gold"][2])
    if lit:
        glow(cv, 15, 8, 13, hexc("#bcdcff"), 120)
        for k in range(3):
            cv.line(4 + k * 2, 8 - k * 2, 26 - k * 2, 4 + k * 2, (220, 245, 255, 200), 1.0)
    else:
        cv.shade_ellipse(15, 7, 3, 2.4, R["stone"])
    cv.outline(OUTLINE)
    return cv, [15, 53]


def stele_root():
    """Bia Đá gốc: bia đá lớn có hoa văn vàng, ánh sáng trắng."""
    cv = Canvas(36, 56)
    shadow(cv, 18, 53, 13, 2.6, 100)
    glow(cv, 18, 22, 16, hexc("#fff0b0"), 90)
    cv.shade_poly([(6, 53), (7, 12), (12, 5), (24, 5), (29, 12), (30, 53)], R["marble"])
    for y in (16, 24, 32, 40):
        cv.line(11, y, 25, y, R["sky_gold"][1], 1.0)
    cv.shade_ellipse(18, 11, 3.2, 3.2, [hexc("#fff0b0")] * 4)
    cv.rect(3, 49, 33, 54, R["marble"][1])
    cv.outline(OUTLINE)
    return cv, [18, 53]


def camp_center(level):
    """C7-03: trung tâm lãnh địa theo cấp — 1 lều · 2 nhà gỗ · 3 tường gỗ · 4 tường đá · 5 cung điện."""
    cv = Canvas(56, 52)
    shadow(cv, 28, 49, 22, 3, 100)
    if level >= 3:
        wall = R["wood"] if level == 3 else R["stone"]
        cv.shade_poly([(2, 49), (2, 34), (54, 34), (54, 49)], wall)
        for x in range(4, 54, 6):
            cv.rect(x, 31, x + 3, 35, wall[2])
    if level == 1:
        cv.shade_poly([(14, 46), (28, 20), (42, 46)], R["cloth_red"])
        cv.shade_poly([(25, 46), (28, 38), (31, 46)], R["leather"])
    elif level == 2:
        cv.shade_poly([(14, 46), (14, 30), (42, 30), (42, 46)], R["wood"])
        cv.shade_poly([(10, 31), (28, 18), (46, 31)], R["bark"])
        cv.rect(25, 38, 31, 46, R["leather"][0])
    elif level in (3, 4):
        cv.shade_poly([(16, 44), (16, 24), (40, 24), (40, 44)], R["wood"] if level == 3 else R["stone"])
        cv.shade_poly([(12, 25), (28, 12), (44, 25)], R["cloth_red"])
        cv.rect(25, 36, 31, 44, R["leather"][0])
    else:
        cv.shade_poly([(12, 44), (12, 22), (44, 22), (44, 44)], R["marble"])
        cv.shade_poly([(8, 23), (28, 8), (48, 23)], R["sky_gold"])
        for x in (8, 44):
            cv.shade_poly([(x - 4, 44), (x - 4, 16), (x + 4, 16), (x + 4, 44)], R["marble"])
            cv.shade_poly([(x - 6, 17), (x, 8), (x + 6, 17)], R["sky_gold"])
        cv.rect(24, 34, 32, 44, R["sky"][0])
        glow(cv, 28, 15, 5, hexc("#fff0b0"), 120)
    cv.outline(OUTLINE)
    return cv, [28, 49]


def register_env(out):
    """Thêm môi trường vùng 7 vào dict env.build_all() (giá trị: (Canvas, origin))."""
    out.setdefault("tile-sky-grass", (cloud_grass_tile(770), [0, 0]))
    out.setdefault("tile-marble", (marble_tile(771), [0, 0]))
    out.setdefault("tile-wind-bridge", (wind_bridge(), [0, 0]))
    for i in range(2):
        out.setdefault("cloud-puff-%d" % i, cloud_puff(780 + i))
        out.setdefault("tree-hanging-%d" % i, hanging_tree(790 + i))
        out.setdefault("sky-pillar-%d" % i, sky_pillar(795 + i))
    out.setdefault("airship-dock", airship_dock())
    out.setdefault("anchor-stone", anchor_stone(False))
    out.setdefault("anchor-stone-lit", anchor_stone(True))
    out.setdefault("wind-pillar", wind_pillar(False))
    out.setdefault("wind-pillar-lit", wind_pillar(True))
    out.setdefault("stele-root", stele_root())
    for lv in range(1, 6):
        out.setdefault("camp-center-%d" % lv, camp_center(lv))
