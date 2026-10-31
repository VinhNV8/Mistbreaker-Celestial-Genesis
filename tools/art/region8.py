"""M11 (chương 8): hình vùng 8 Vực Hư Vô — quái, tinh anh, boss, boss hiếm, NPC Tổ Sư, đồ Cam, môi trường.

Tách riêng như region7.py: catalog.py, icons.py, env.py chỉ gọi register_*() ở cuối file.
Hệ Hư Vô (không hệ): tím đen, bạc, đốm sáng Thiên phú. Danh sách quái theo docs/06 §Vùng 8, docs/17 C8-20…34.
"""
import random

from pixel import Canvas, R, OUTLINE, glow, hexc, ramp, shadow

PALETTE = {
    "abyss": ramp("#0c0814", "#1e1430", "#3a2858", "#6a4a9a"),
    "silver": ramp("#4a4a5a", "#8a8aa0", "#c4c4d8", "#f0f0fa"),
    "starlight": ramp("#7a6a2a", "#c0a84a", "#f0dc8a", "#fff8d8"),
}


def register_palette():
    for k, v in PALETTE.items():
        R.setdefault(k, v)


register_palette()


# ====================================================================== builder: Mắt Hư Vô
def void_eye(spec):
    """Con mắt khổng lồ lơ lửng 24×24: nhãn cầu tím, đồng tử sáng, xúc tu bóng phía dưới.
    attack = mở to, đồng tử sáng rực. spec: body (dải), iris (hex)."""
    body = R[spec.get("body", "abyss")]
    iris = hexc(spec.get("iris", "#ff5ad0"))

    def frame(bob=0.0, wide=0.0, sway=0.0, alpha=1.0):
        cv = Canvas(24, 24)
        shadow(cv, 12, 21.5, 5, 1.2, 70)
        cy = 10 + bob
        for k in range(3):
            x = 8 + k * 4
            cv.line(x, cy + 4, x + sway * (1 if k % 2 else -1), cy + 10, body[1], 1.2)
        cv.shade_ellipse(12, cy, 7, 6, body)
        cv.shade_ellipse(12.5, cy, 5, 3.4 + wide * 1.4, R["silver"])
        glow(cv, 13, cy, 3 + wide * 2, iris, 120 + round(wide * 80))
        cv.shade_ellipse(13, cy, 1.8 + wide * 0.6, 1.8 + wide * 0.6, [iris] * 4)
        cv.set(12.5, cy - 1, (255, 255, 255, 255))
        cv.outline(OUTLINE)
        return cv.fade(alpha) if alpha < 1.0 else cv

    return [
        ("idle", [frame(0.0), frame(-1.0, sway=1.0)]),
        ("run", [frame(0.0), frame(-0.5, sway=1.0), frame(-1.0, sway=0.0), frame(-0.5, sway=-1.0)]),
        ("attack", [frame(0.0, 0.5), frame(-1.0, 1.0), frame(0.0, 0.3)]),
        ("hurt", [frame(0.5, 0.0, 1.0)]),
        ("death", [frame(0.0, 0.0, alpha=0.8), frame(1.0, alpha=0.5), frame(2.0, alpha=0.25)]),
    ]


def register_builders():
    from builders import BUILDERS
    BUILDERS.setdefault("void_eye", void_eye)


# ====================================================================== sprite
SPRITES8 = {
    # quái thường (docs/06 §Vùng 8)
    "bong-hu-vo": {"builder": "humanoid", "name": "Bóng Hư Vô", "size_mul": 0.9,
                   "spec": {"skin": "shadow", "cloth": "abyss", "pants": "abyss", "boots": "abyss", "hair_style": "none",
                            "hood": True, "trim": "purple", "weapon": "sword", "cape": "abyss", "eye": "none"}},
    "ke-nuot": {"builder": "humanoid", "name": "Kẻ Nuốt Thiên Phú",
                "spec": {"skin": "skin_light", "hair": "white", "hair_style": "none", "hood": True, "cloth": "purple", "pants": "abyss",
                         "trim": "silver", "weapon": "staff", "robe": True, "orb": "void", "aura": "#8a5ad0"}},
    "giap-si-hu-vo": {"builder": "humanoid", "name": "Giáp Sĩ Hư Vô", "size_mul": 1.15,
                      "spec": {"skin": "skin_dark", "cloth": "abyss", "pants": "steel", "boots": "steel", "hood": True,
                               "trim": "purple", "weapon": "sword", "shield": True, "shield_face": "void", "collar": "silver"}},
    "mat-hu-vo": {"builder": "void_eye", "name": "Mắt Hư Vô", "size_mul": 1.25, "spec": {}},
    # tinh anh
    "tu-te-hu-vo": {"builder": "humanoid", "name": "Tư Tế Hư Vô", "size_mul": 1.35,
                    "spec": {"skin": "skin_light", "hair": "white", "hair_style": "dai", "hood": True, "cloth": "blood", "pants": "abyss",
                             "trim": "gold", "weapon": "staff", "robe": True, "orb": "blood", "aura": "#ff5a7a", "collar": "gold"}},
    "khong-mat": {"builder": "humanoid", "name": "Quái Vật Không Mặt", "size_mul": 1.5,
                  "spec": {"skin": "silver", "cloth": "abyss", "pants": "abyss", "boots": "steel", "hair_style": "none",
                           "trim": "silver", "weapon": "sword", "shield": True, "shield_face": "silver", "eye": "none", "aura": "#c8c0d8"}},
    # vật thể nhiệm vụ
    "long-hu-vo": {"builder": "void_pylon", "name": "Lồng Hư Vô", "size_mul": 1.5, "spec": {"size": 32}},
    "tru-phong-an": {"builder": "void_pylon", "name": "Trụ Phong Ấn", "size_mul": 1.8, "spec": {"size": 32}},
    # boss chương 8 — người cao gầy áo choàng đen viền vàng, mặt nạ bạc, đốm sáng Thiên phú (hào quang vàng)
    "giao-chu": {"builder": "humanoid", "name": "Giáo Chủ Hư Vô", "size_mul": 1.9,
                 "spec": {"skin": "silver", "hair_style": "none", "hood": True, "cloth": "abyss", "pants": "abyss", "boots": "abyss",
                          "trim": "gold", "weapon": "staff", "robe": True, "orb": "starlight", "cape": "abyss", "collar": "gold",
                          "aura": "#f0dc8a", "eye": "none"}},
    # boss hiếm
    "hu-vo-thu": {"builder": "quadruped", "name": "Hư Vô Thú", "size_mul": 1.3,
                  "spec": {"size": 48, "fur": "fur_void", "mane": "abyss", "eye": "#ff5ad0", "aura": "#6a3aa8", "stripes": "#c04ad0"}},
    # NPC: 5 Tổ Sư (tàn hồn Khai Giới Giả đời đầu) dùng chung một hình
    "npc-to-su": {"builder": "humanoid", "name": "Tổ Sư",
                  "spec": {"skin": "wisp", "hair": "white", "hair_style": "bui", "cloth": "white", "pants": "silver",
                           "trim": "starlight", "weapon": "staff", "robe": True, "orb": "starlight", "aura": "#e2fbf6"}},
}


def register_sprites(sprites):
    import region7  # noqa: F401 — builder void_pylon
    region7.register_builders()
    register_builders()
    for k, v in SPRITES8.items():
        sprites.setdefault(k, v)


# ====================================================================== icon
def g_an_hu_vo(cv):
    """Ấn Hư Vô (nhẫn Cam): vòng bạc, mặt ấn tím có ngôi sao vàng."""
    glow(cv, 16, 16, 14, hexc("#9b6ee0"), 70)
    for i in range(24):
        import math
        a = i / 24 * math.tau
        cv.set(16 + math.cos(a) * 9, 18 + math.sin(a) * 6, R["silver"][2])
    cv.shade_ellipse(16, 11, 6, 5, R["void"])
    cv.shade_ellipse(16, 11, 2.2, 2.2, [hexc("#f0dc8a")] * 4)
    cv.set(15, 10, (255, 255, 240, 255))


def g_nanh_hu_vo(cv):
    """Nanh Hư Vô (vũ khí Cam): nanh cong tím đen như lưỡi kiếm, cán bạc."""
    glow(cv, 17, 14, 14, hexc("#c04ad0"), 60)
    cv.shade_poly([(8, 27), (12, 22), (20, 10), (26, 4), (24, 12), (16, 22), (11, 28)], R["fur_void"])
    cv.line(10, 25, 24, 7, R["purple"][3], 0.8)
    cv.line(6, 29, 11, 24, R["silver"][2], 2.4)


def g_lantern(cv):
    """Đèn Lồng Tinh Quang: đèn lồng bạc, ánh sáng vàng trắng."""
    glow(cv, 16, 18, 14, hexc("#fff2b0"), 90)
    cv.line(16, 3, 16, 7, R["silver"][1], 1.0)
    cv.shade_poly([(11, 8), (21, 8), (23, 13), (21, 26), (11, 26), (9, 13)], R["silver"])
    cv.shade_ellipse(16, 17, 4, 6, [hexc("#fff2b0")] * 4)
    cv.rect(10, 26, 22, 28, R["silver"][0])


def g_void_core(cv):
    """Lõi Hư Vô: viên tinh thể đen tím, vân bạc."""
    glow(cv, 16, 16, 13, hexc("#9b6ee0"), 80)
    cv.shade_poly([(16, 4), (24, 13), (20, 27), (12, 27), (8, 13)], R["void"])
    cv.line(16, 4, 16, 27, R["silver"][1], 0.7)
    cv.line(8, 13, 24, 13, R["silver"][1], 0.7)


ITEMS8 = {"an_hu_vo": g_an_hu_vo, "nanh_hu_vo": g_nanh_hu_vo}
RESOURCES8 = {"lantern": g_lantern, "void_core": g_void_core}


def register_icons(items, resources, skills):
    for k, v in ITEMS8.items():
        items.setdefault(k, v)
    for k, v in RESOURCES8.items():
        resources.setdefault(k, v)


# ====================================================================== môi trường
def abyss_tile(seed):
    rnd = random.Random(seed)
    cv = Canvas(32, 32)
    a = R["abyss"]
    cv.rect(0, 0, 32, 32, a[1])
    for _ in range(10):
        x, y = rnd.uniform(0, 32), rnd.uniform(0, 32)
        cv.line(x, y, x + rnd.uniform(-6, 6), y + rnd.uniform(-3, 3), a[0], 0.8)
    for _ in range(4):
        cv.set(rnd.randrange(0, 32), rnd.randrange(0, 32), a[2])
    return cv


def void_stone(seed):
    """Cột Đá Hư Vô: khối đá đen tím cao, vân nứt sáng tím."""
    rnd = random.Random(seed)
    cv = Canvas(40, 56)
    shadow(cv, 20, 52, 16, 3, 110)
    cv.shade_poly([(6, 52), (8, 18), (14, 6), (24, 4), (32, 14), (34, 52)], R["abyss"])
    for _ in range(3):
        x = rnd.uniform(12, 28)
        cv.line(x, 14, x + rnd.uniform(-5, 5), 44, R["void"][3], 0.8)
    cv.outline(OUTLINE)
    return cv, [20, 52]


def lamp(lit):
    """Đèn Tinh Quang: cột bạc, chao đèn trắng vàng (tắt: đá xám)."""
    cv = Canvas(24, 56)
    shadow(cv, 12, 53, 7, 2, 90)
    if lit:
        glow(cv, 12, 12, 12, hexc("#fff2b0"), 140)
    cv.shade_poly([(10, 53), (10.5, 18), (13.5, 18), (14, 53)], R["silver"])
    cv.rect(6, 50, 18, 54, R["silver"][1])
    cv.shade_poly([(6, 18), (8, 8), (16, 8), (18, 18)], R["silver"])
    cv.shade_ellipse(12, 13, 3.4, 4, [hexc("#fff2b0")] * 4 if lit else R["stone"])
    cv.outline(OUTLINE)
    return cv, [12, 53]


def register_env(out):
    """Thêm môi trường vùng 8 vào dict env.build_all() (giá trị: (Canvas, origin))."""
    out.setdefault("tile-abyss", (abyss_tile(880), [0, 0]))
    out.setdefault("void-stone", void_stone(881))
    out.setdefault("lamp-tinh-quang", lamp(False))
    out.setdefault("lamp-tinh-quang-lit", lamp(True))
