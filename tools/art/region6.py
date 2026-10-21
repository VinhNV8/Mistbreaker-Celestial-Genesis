"""M9 (docs/14): hình vùng 6 Băng Nguyên Bắc Cực — quái, boss, NPC, đồ Cam, tài nguyên, môi trường.

Tách riêng như region4.py / region5.py: catalog.py, icons.py, env.py chỉ gọi register_*() ở cuối file.
Hệ Thủy + Kim: trắng tuyết, xanh băng, bạc; Bản Ngã Bóng Tối: đen tím.
"""
import math
import random

from pixel import Canvas, R, OUTLINE, glow, hexc, ramp, shadow

PALETTE = {
    "snow": ramp("#8a9cb4", "#bccbdc", "#e4ecf4", "#ffffff"),
    "ice": ramp("#2a5a8a", "#4a8ac0", "#8ac8f0", "#d8f2ff"),
    "frost": ramp("#1a2a4a", "#2a4a7a", "#4a7ab0", "#8ab4e0"),
    "shadow": ramp("#0a0612", "#1a0e2a", "#2a1a42", "#4a3270"),
    "aurora": ramp("#1a5a4a", "#2a9a7a", "#5ae0b0", "#b4ffe0"),
    "fur_snow": ramp("#7a8494", "#b0bac8", "#dce2ea", "#f8fbff"),
}


def register_palette():
    for k, v in PALETTE.items():
        R.setdefault(k, v)


register_palette()


# ====================================================================== builder: Gương Băng
def mirror(spec):
    """Gương Băng: tấm băng đứng có khung bạc, ánh lấp lánh (không có chân). 5 hoạt ảnh đủ số frame."""
    size = spec.get("size", 32)
    s = size / 32.0

    def frame(shine=0.0, crack=0, tilt=0.0, alpha=255):
        cv = Canvas(size, size)
        S = lambda v: v * s
        shadow(cv, S(16), S(29.5), S(8), S(1.8), 70)
        frame_pts = [(S(9 + tilt), S(29)), (S(8 + tilt), S(8)), (S(16), S(2)), (S(24 - tilt), S(8)), (S(23 - tilt), S(29))]
        cv.shade_poly(frame_pts, R["steel"])
        glass = [(S(10.5 + tilt), S(27.5)), (S(10 + tilt), S(9)), (S(16), S(4.2)), (S(22 - tilt), S(9)), (S(21.5 - tilt), S(27.5))]
        cv.shade_poly(glass, R["ice"])
        cv.line(S(12 + shine * 6), S(25), S(15 + shine * 6), S(8), (255, 255, 255, 170), S(1.0))
        for k in range(crack):
            cv.line(S(16), S(16), S(16 + (k - 1) * 4), S(26 - k * 5), R["frost"][0], S(0.7))
        cv.outline(OUTLINE)
        return cv

    return [
        ("idle", [frame(0.0), frame(0.4)]),
        ("run", [frame(0.0), frame(0.2), frame(0.4), frame(0.6)]),
        ("attack", [frame(0.2), frame(0.6, tilt=0.4), frame(0.9, tilt=0.8)]),
        ("hurt", [frame(0.5, crack=2)]),
        ("death", [frame(0.5, crack=2), frame(0.5, crack=3, tilt=1.0), frame(0.5, crack=3, tilt=2.0)]),
    ]


def register_builders():
    from builders import BUILDERS
    BUILDERS.setdefault("mirror", mirror)


# ====================================================================== sprite
SPRITES6 = {
    # quái thường
    "soi-bang": {"builder": "quadruped", "name": "Sói Băng",
                 "spec": {"size": 24, "fur": "fur_snow", "mane": "ice", "eye": "#4fc3ff"}},
    "nguoi-tuyet": {"builder": "humanoid", "name": "Người Tuyết", "size_mul": 1.35,
                    "spec": {"skin": "snow", "cloth": "snow", "pants": "snow", "boots": "snow", "hair_style": "none",
                             "trim": "ice", "weapon": "none", "collar": "ice"}},
    "tinh-linh-bang": {"builder": "wisp", "name": "Tinh Linh Băng", "spec": {"body": "ice", "glow": "#8ad8ff"}},
    "cung-thu-bang": {"builder": "humanoid", "name": "Cung Thủ Băng",
                      "spec": {"cloth": "frost", "pants": "steel", "hood": True, "trim": "ice", "weapon": "bow", "skin": "skin_light"}},
    # tinh anh
    "gau-bang": {"builder": "quadruped", "name": "Gấu Băng Khổng Lồ", "size_mul": 1.6,
                 "spec": {"size": 48, "fur": "fur_snow", "mane": "snow", "eye": "#4fc3ff", "stripes": "#8ac8f0"}},
    "phap-su-bao-tuyet": {"builder": "humanoid", "name": "Pháp Sư Bão Tuyết", "size_mul": 1.2,
                          "spec": {"cloth": "ice", "pants": "frost", "hood": True, "trim": "white", "weapon": "staff",
                                   "robe": True, "orb": "ice", "skin": "skin_light", "cape": "snow"}},
    # boss: Bản Ngã Bóng Tối (game vẽ bằng dáng lớp người chơi tô đen; hình này dùng khi thiếu hình lớp)
    "ban-nga": {"builder": "humanoid", "name": "Bản Ngã Bóng Tối", "size_mul": 1.3,
                "spec": {"skin": "shadow", "cloth": "shadow", "pants": "shadow", "boots": "shadow", "hair": "shadow",
                         "hair_style": "ngan", "trim": "purple", "weapon": "sword", "cape": "shadow", "aura": "#6a3aa8", "eye": "none"}},
    "guong-bang": {"builder": "mirror", "name": "Gương Băng", "size_mul": 1.4, "spec": {"size": 32}},
    "anh-bong": {"builder": "humanoid", "name": "Ảnh Bóng", "size_mul": 0.85,
                 "spec": {"skin": "shadow", "cloth": "shadow", "pants": "shadow", "boots": "shadow", "hair_style": "none",
                          "trim": "purple", "weapon": "sword"}},
    "long-bang": {"builder": "dragon", "name": "Long Băng Bắc Cực", "size_mul": 2.1,
                  "spec": {"size": 48, "fur": "ice", "mane": "snow", "eye": "#d8f2ff", "aura": "#8ad8ff", "wing": "frost",
                           "wing_span": 1.2, "stripes": "#2a5a8a"}},
    # NPC Trạm Tuyết Bạc (Lam Nhi dùng lại npc-lam-nhi của vùng 4)
    "npc-tuyet-nga": {"builder": "humanoid", "name": "Nữ tư tế Tuyết Nga",
                      "spec": {"skin": "skin_light", "hair": "white", "hair_style": "dai", "cloth": "white", "pants": "ice",
                               "trim": "aurora", "weapon": "staff", "robe": True, "orb": "ice", "gender": "nu"}},
    "npc-lao-han": {"builder": "humanoid", "name": "Thợ săn Lão Hàn",
                    "spec": {"skin": "skin", "hair": "white", "hair_style": "bui", "cloth": "fur_snow", "pants": "leather",
                             "trim": "leather", "weapon": "bow", "hood": True, "gender": "nam"}},
}


def register_sprites(sprites):
    import region5  # noqa: F401 — builder dragon
    region5.register_builders()
    register_builders()
    for k, v in SPRITES6.items():
        sprites.setdefault(k, v)


# ====================================================================== icon
def g_guong_ban_nga(cv):
    """Gương Bản Ngã (bùa Cam): gương tròn khung bạc, trong gương là bóng không mặt."""
    glow(cv, 16, 16, 15, hexc("#b36bff"), 60)
    cv.shade_ellipse(16, 15, 10, 11, R["steel"])
    cv.shade_ellipse(16, 15, 8, 9, R["ice"])
    cv.shade_ellipse(16, 13, 3.2, 3.4, R["shadow"])
    cv.shade_poly([(10.5, 23), (12, 17.5), (20, 17.5), (21.5, 23)], R["shadow"])
    cv.line(11, 10, 13, 7, (255, 255, 255, 200), 1.0)
    cv.rect(14.5, 26, 17.5, 30, R["steel"][1])


def g_vay_long_bang(cv):
    """Vảy Long Băng (giày Cam): ủng băng có vảy."""
    glow(cv, 16, 16, 15, hexc("#8ad8ff"), 60)
    cv.shade_poly([(9, 6), (18, 6), (18, 20), (26, 22), (26, 27), (8, 27)], R["ice"])
    for (x, y) in ((11, 10), (15, 10), (11, 15), (15, 15), (13, 20), (19, 23)):
        cv.shade_ellipse(x, y, 2.2, 1.6, R["frost"])
    cv.rect(8, 26, 27, 28, R["snow"][1])


def g_ember(cv):
    """Than Hồng: cục than đỏ trong túi da."""
    glow(cv, 16, 17, 12, hexc("#ff9a3c"), 70)
    cv.shade_poly([(8, 26), (7, 16), (12, 9), (20, 9), (25, 16), (24, 26)], R["leather"])
    cv.line(11, 10, 21, 10, R["leather"][0], 1.2)
    cv.shade_ellipse(16, 18, 5, 4, R["fire"])
    cv.set(15, 17, (255, 240, 180, 255))


def g_skill_mirror(cv):
    """Kính Ảnh (Đạo Tặc sao chép từ Bản Ngã): bóng và bản sao."""
    from icons import _skill_bg
    _skill_bg(cv, "#1a0e2a")
    for (x, col) in ((12, R["purple"]), (20, R["shadow"])):
        cv.shade_ellipse(x, 11, 3.2, 3.2, col)
        cv.shade_poly([(x - 5, 26), (x - 4, 16), (x + 4, 16), (x + 5, 26)], col)
    cv.line(16, 5, 16, 28, (190, 230, 255, 170), 1.0)


ITEMS6 = {"guong_ban_nga": g_guong_ban_nga, "vay_long_bang": g_vay_long_bang}
RESOURCES6 = {"ember": g_ember}
SKILLS6 = {"mirror": g_skill_mirror}


def register_icons(items, resources, skills):
    for src, dst in ((ITEMS6, items), (RESOURCES6, resources), (SKILLS6, skills)):
        for k, v in src.items():
            dst.setdefault(k, v)


# ====================================================================== môi trường
def snow_tile(seed):
    from env import tile
    return tile(R["snow"], seed, tufts=False)


def ice_tile(seed):
    rnd = random.Random(seed)
    cv = Canvas(32, 32)
    ic = R["ice"]
    cv.rect(0, 0, 32, 32, ic[2])
    for _ in range(8):
        x, y = rnd.uniform(0, 32), rnd.uniform(0, 32)
        cv.line(x, y, x + rnd.uniform(-8, 8), y + rnd.uniform(-5, 5), ic[1], 0.8)
    for _ in range(10):
        cv.set(rnd.randrange(32), rnd.randrange(32), ic[3])
    return cv


def snow_pine(seed):
    """Thông phủ tuyết."""
    rnd = random.Random(seed)
    cv = Canvas(30, 46)
    shadow(cv, 15, 43, 10, 2.5, 90)
    cv.rect(13.5, 34, 16.5, 43, R["bark"][1])
    for k, (y, w) in enumerate(((34, 13), (26, 10.5), (18, 8), (10, 5))):
        cv.shade_poly([(15 - w, y), (15, y - 11), (15 + w, y)], R["leaf"])
        cv.shade_poly([(15 - w * 0.75, y - 2), (15, y - 11), (15 + w * 0.6, y - 3.5)], R["snow"])
    for _ in range(3):
        cv.set(rnd.randrange(6, 24), rnd.randrange(10, 34), R["snow"][3])
    cv.outline(OUTLINE)
    return cv, [15, 43]


def ice_rock(seed):
    """Tảng đá phủ băng."""
    rnd = random.Random(seed)
    cv = Canvas(28, 22)
    shadow(cv, 14, 19, 12, 2.5, 90)
    cv.shade_poly([(3, 18), (5, 10), (10, 5), (19, 4), (25, 10), (25, 18)], R["stone"])
    cv.shade_poly([(5, 11), (10, 5), (19, 4), (24, 9), (15, 10)], R["snow"])
    x = rnd.uniform(10, 18)
    cv.shade_poly([(x, 18), (x + 2, 11), (x + 5, 18)], R["ice"])
    cv.outline(OUTLINE)
    return cv, [14, 18]


def snow_mound():
    cv = Canvas(26, 14)
    shadow(cv, 13, 12, 11, 2, 70)
    cv.shade_ellipse(13, 9, 11, 4.5, R["snow"])
    cv.outline(OUTLINE)
    return cv, [13, 11]


def campfire():
    """Lửa trại: củi xếp + ngọn lửa + hào quang ấm."""
    cv = Canvas(28, 28)
    glow(cv, 14, 16, 13, hexc("#ff9a3c"), 80)
    for (a, b) in (((5, 23), (23, 18)), ((5, 18), (23, 23))):
        cv.line(a[0], a[1], b[0], b[1], R["wood"][1], 2.4)
    cv.shade_poly([(8, 21), (10, 12), (14, 5), (18, 12), (20, 21)], R["fire"])
    cv.shade_poly([(11, 21), (13, 14), (14, 10), (16, 14), (17, 21)], [hexc("#fff2c8")] * 4)
    cv.outline(OUTLINE)
    return cv, [14, 22]


def beacon(lit):
    """Đèn Cực Quang: cột đá cổ, đỉnh có ngọn lửa xanh lục khi đã thắp."""
    cv = Canvas(26, 50)
    shadow(cv, 13, 47, 9, 2.2, 90)
    cv.shade_poly([(8, 47), (9, 16), (17, 16), (18, 47)], R["stone"])
    cv.rect(6, 12, 20, 17, R["stone"][2])
    for y in (24, 33, 41):
        cv.line(9.5, y, 16.5, y, R["aurora"][0] if lit else R["stone"][0], 1.0)
    if lit:
        glow(cv, 13, 8, 12, hexc("#7affc8"), 110)
        cv.shade_poly([(9, 12), (11, 5), (13, 1), (15, 5), (17, 12)], R["aurora"])
    else:
        cv.shade_ellipse(13, 10, 3.5, 2.2, R["frost"])
    cv.outline(OUTLINE)
    return cv, [13, 47]


def ice_mirror():
    """Gương Băng (vật thể khi vẽ ở cảnh — cùng hình với sprite guong-bang)."""
    rows = mirror({"size": 32})
    return rows[0][1][0], [16, 29]


def register_env(out):
    """Thêm môi trường vùng 6 vào dict env.build_all() (giá trị: (Canvas, origin))."""
    out.setdefault("tile-snow", (snow_tile(700), [0, 0]))
    out.setdefault("tile-ice", (ice_tile(701), [0, 0]))
    for i in range(2):
        out.setdefault("tree-pine-snow-%d" % i, snow_pine(710 + i))
        out.setdefault("rock-ice-%d" % i, ice_rock(720 + i))
    out.setdefault("snow-mound", snow_mound())
    out.setdefault("campfire", campfire())
    out.setdefault("beacon", beacon(False))
    out.setdefault("beacon-lit", beacon(True))
    out.setdefault("ice-mirror", ice_mirror())
