"""M7 (docs/11): hình vùng 4 Đầm Lầy U Minh — builder ếch, cá sấu; danh mục sprite, cảnh vật, icon đồ Cam.

Đăng ký vào catalog.py / builders.py / env.py / icons.py bằng vài dòng ở cuối các file đó (giống tools/art/region5.py).
"""
import math
from pixel import Canvas, R, OUTLINE, shadow, glow, hexc, mix, ramp


SWAMP = {
    "swamp_green": ramp("#1e2a1a", "#2f4428", "#46603a", "#6a8a52"),
    "frog": ramp("#1f4a1e", "#2f7a2a", "#4aa63a", "#9ade6a"),
    "croc": ramp("#1e2618", "#34442a", "#4e6238", "#6e8450"),
    "leech": ramp("#2a0e16", "#4a1a26", "#6e2a38", "#9a4656"),
    "water": ramp("#0e2a3a", "#1a4a5e", "#2a6a82", "#5aa0b8"),
}


def _finish(cv):
    cv.outline(OUTLINE)
    return cv


def _hurt(fn):
    cv = fn()
    return Canvas(cv.w, cv.h).paste(cv, -1, 0).tint((255, 70, 80, 255), 0.35)


# ====================================================================== ếch
def frog(spec):
    """Ếch 24×24 (Ếch Độc). spec: skin (dải màu), belly (hex), eye (hex)."""
    skin = spec.get("skin", SWAMP["frog"])
    skin = R.get(skin, SWAMP.get(skin)) if isinstance(skin, str) else skin
    belly = hexc(spec.get("belly", "#d8e8a0"))
    eye = hexc(spec.get("eye", "#ffd23c"))

    def frame(hop=0.0, tongue=0.0, squash=0.0):
        cv = Canvas(24, 24)
        shadow(cv, 12, 20.5, 7 - hop * 0.6, 1.6, 80)
        cy = 15 - hop
        cv.shade_ellipse(9, cy + 3, 4, 2.2, [mix(c, (0, 0, 0, 255), 0.25) for c in skin])   # chân sau
        cv.shade_ellipse(12, cy, 6.5, 4.2 - squash, skin)
        cv.shade_ellipse(13, cy + 1.6, 4.2, 1.6, [belly] * 4)
        for ex in (13.5, 17):
            cv.shade_ellipse(ex, cy - 3.6, 1.8, 1.8, skin)
            cv.set(ex + 0.4, cy - 3.8, eye)
        for (x, y) in ((9, 13.5), (12, 12.5)):
            cv.set(x, y - hop, hexc("#ffb03c"))
        cv.line(15, cy + 3, 17, cy + 5, skin[1], 1.4)
        if tongue > 0:
            cv.line(18, cy - 0.5, 18 + tongue, cy - 0.5, hexc("#ff5a8a"), 1.4)
            cv.ellipse(18 + tongue, cy - 0.5, 1.2, 1.2, hexc("#ff5a8a"))
        return _finish(cv)

    idle = [frame(), frame(squash=0.4)]
    run = [frame(0), frame(2.5), frame(3.5), frame(1)]
    atk = [frame(squash=0.6), frame(tongue=4), frame(tongue=6)]
    hurt = [_hurt(lambda: frame())]
    death = [frame().rotated(180, (12, 15)).fade(a) for a in (1.0, 0.75, 0.5)]
    return [("idle", idle), ("run", run), ("attack", atk), ("hurt", hurt), ("death", death)]


# ====================================================================== cá sấu
def croc(spec):
    """Cá sấu nằm dài. spec: size (24|32), hide (dải màu), eye (hex), crown (bool)."""
    size = spec.get("size", 24)
    s = size / 24.0
    hide = spec.get("hide", SWAMP["croc"])
    hide = R.get(hide, SWAMP.get(hide)) if isinstance(hide, str) else hide
    eye = hexc(spec.get("eye", "#ffd23c"))
    crown = spec.get("crown", False)

    def frame(step=0, jaw=0.0, roll=0.0):
        cv = Canvas(size, size)
        S = lambda v: v * s
        shadow(cv, S(12), S(20), S(10), S(1.6), 90)
        cy = 16 - roll * 2
        for i, x in enumerate((7, 14)):
            ph = (step + i) % 2
            cv.line(S(x), S(cy + 1), S(x - 1 + ph * 2), S(19.5), mix(hide[1], (0, 0, 0, 255), 0.3), S(1.6))
        cv.shade_poly([(S(1), S(cy + 1)), (S(5), S(cy - 1.5)), (S(5), S(cy + 2))], hide)                 # đuôi
        cv.shade_ellipse(S(10), S(cy), S(6.5), S(2.8), hide)
        for x in range(4, 16, 2):
            cv.set(S(x), S(cy - 2.4), hide[3])
        # đầu + hàm
        cv.shade_poly([(S(15), S(cy - 2)), (S(23), S(cy - 1 - jaw)), (S(23), S(cy)), (S(15), S(cy + 1))], hide)
        cv.shade_poly([(S(15), S(cy + 0.5)), (S(22.5), S(cy + 0.5 + jaw)), (S(22.5), S(cy + 2 + jaw)), (S(15), S(cy + 2))],
                      [mix(c, (0, 0, 0, 255), 0.2) for c in hide])
        if jaw > 0:
            for x in (17, 19, 21):
                cv.set(S(x), S(cy - 0.6), (240, 240, 230, 255))
        cv.set(S(16.5), S(cy - 2.4), eye)
        if crown:
            cv.shade_poly([(S(15), S(cy - 2.5)), (S(16), S(cy - 5)), (S(17), S(cy - 3)), (S(18), S(cy - 5.5)), (S(19), S(cy - 2.5))], R["gold"])
        for i, x in enumerate((9, 16)):
            ph = (step + i + 1) % 2
            cv.line(S(x), S(cy + 1.5), S(x + 1 - ph * 2), S(20.5), hide[1], S(1.8))
        return _finish(cv)

    idle = [frame(), frame(jaw=0.4)]
    run = [frame(i) for i in range(4)]
    atk = [frame(jaw=0.5), frame(jaw=2.5), frame(jaw=1.0, roll=0.5)]
    hurt = [_hurt(lambda: frame())]
    death = [frame().rotated(180, (12 * s, 16 * s)).fade(a) for a in (1.0, 0.75, 0.5)]
    return [("idle", idle), ("run", run), ("attack", atk), ("hurt", hurt), ("death", death)]


BUILDERS = {"frog": frog, "croc": croc}

SPRITES = {
    "ech-doc": {"builder": "frog", "name": "Ếch Độc", "spec": {}},
    "dia": {"builder": "snake", "name": "Đỉa Hút Máu", "size_mul": 0.7, "spec": {"body": SWAMP["leech"], "belly": SWAMP["leech"], "eye": "#ff5470"}},
    "hon-ma": {"builder": "wisp", "name": "Hồn Ma Đầm", "spec": {"body": "white", "glow": "#9ab8c8"}},
    "phu-thuy-dam": {"builder": "humanoid", "name": "Phù Thuỷ Đầm Lầy", "size_mul": 1.2,
                     "spec": {"cloth": SWAMP["swamp_green"], "pants": "purple", "hood": True, "trim": "leaf", "weapon": "staff", "robe": True,
                              "orb": "leaf", "skin": "skin_light"}},
    "ca-sau": {"builder": "croc", "name": "Cá Sấu Bùn", "spec": {}},
    "ca-sau-chua": {"builder": "croc", "name": "Cá Sấu Chúa", "spec": {"size": 32, "crown": True, "eye": "#ff5470"}},
    "nu-vuong": {"builder": "humanoid", "name": "Nữ Vương Phệ Mộng", "size_mul": 1.5,
                 "spec": {"gender": "nu", "skin": "skin_light", "hair": "white", "hair_style": "dai", "cloth": "purple", "pants": "purple",
                          "trim": "crystal", "weapon": "staff", "orb": "purple", "robe": True, "cape": "void"}},
    "mong-chau": {"builder": "wisp", "name": "Mộng Châu", "spec": {"body": "purple", "glow": "#c28af0"}},
    "thuy-quai": {"builder": "snake", "name": "Thuỷ Quái Thất Đầu", "size_mul": 2.4, "spec": {"body": SWAMP["water"], "belly": "crystal", "eye": "#ff5470"}},
    "dau-thuy-quai": {"builder": "snake", "name": "Đầu Thuỷ Quái", "size_mul": 1.2, "spec": {"body": SWAMP["water"], "belly": "crystal", "eye": "#ffd23c"}},
    "npc-lao-ngu": {"builder": "humanoid", "name": "Trưởng làng Lão Ngư",
                    "spec": {"skin": "skin_dark", "hair": "white", "hair_style": "ngan", "cloth": "leather", "pants": SWAMP["swamp_green"], "trim": "wood",
                             "weapon": "staff", "orb": "leaf"}},
    "npc-lam-nhi": {"builder": "humanoid", "name": "Lam Nhi",
                    "spec": {"gender": "nu", "skin": "skin", "hair": "hair_dark", "hair_style": "duoi", "cloth": "cloth_blue", "pants": "leather",
                             "trim": "crystal", "weapon": "none"}},
    "npc-tinh-quang": {"builder": "humanoid", "name": "Tinh Quang Sứ",
                       "spec": {"skin": "skin_light", "hair": "gold", "hair_style": "dai", "cloth": "white", "pants": "white", "trim": "gold",
                                "weapon": "staff", "orb": "gold", "robe": True}},
}


# ====================================================================== cảnh vật
def dead_tree(seed):
    import random
    rnd = random.Random(seed)
    cv = Canvas(36, 48)
    shadow(cv, 18, 44.5, 10, 2.5, 90)
    cv.shade_poly([(15, 44), (21, 44), (20, 20), (16, 20)], R["bark"])
    for (x0, y0, x1, y1) in ((18, 24, 8, 12), (18, 22, 28, 9), (17, 30, 9, 26), (19, 28, 29, 22)):
        cv.line(x0, y0, x1 + rnd.uniform(-1, 1), y1 + rnd.uniform(-1, 1), R["bark"][1], 1.6)
    for _ in range(5):
        x, y = rnd.uniform(8, 28), rnd.uniform(8, 26)
        cv.line(x, y, x, y + rnd.uniform(3, 7), (120, 150, 110, 180), 0.8)          # rêu treo
    cv.outline(OUTLINE)
    return cv, [18, 44]


def reeds(seed):
    import random
    rnd = random.Random(seed)
    cv = Canvas(22, 26)
    shadow(cv, 11, 23.5, 8, 1.6, 60)
    for i in range(8):
        x = 3 + i * 2.2 + rnd.uniform(-0.5, 0.5)
        top = rnd.uniform(3, 9)
        cv.line(x, 23, x + rnd.uniform(-1, 2), top, SWAMP["swamp_green"][rnd.choice((2, 3))], 1.1)
        if rnd.random() < 0.5:
            cv.ellipse(x + 0.5, top + 1, 0.9, 2.2, R["bark"][2])
    return cv, [11, 23]


def lily(seed):
    cv = Canvas(20, 12)
    cv.shade_ellipse(10, 6, 8, 4, SWAMP["frog"])
    cv.shade_poly([(10, 6), (17, 3), (18, 7)], [hexc("#0e2a3a")] * 4)
    cv.ellipse(7, 5, 1.6, 1.6, hexc("#ffc0e0"))
    return cv, [10, 6]


def pod():
    """Bọc Mộng (nhiệm vụ chương 4 bước 3)."""
    cv = Canvas(24, 28)
    shadow(cv, 12, 25, 7, 1.8, 80)
    glow(cv, 12, 14, 10, hexc("#c28af0"), 90)
    cv.shade_ellipse(12, 14, 7, 9, R["purple"])
    cv.ellipse(10, 11, 2, 3, (255, 255, 255, 120))
    cv.outline(OUTLINE)
    return cv, [12, 25]


def tile_swamp(tile_fn):
    return tile_fn(SWAMP["swamp_green"], 600), [0, 0]


def build_env(tile_fn):
    out = {"tile-swamp": tile_swamp(tile_fn)}
    for i in range(2):
        out["dead-tree-%d" % i] = dead_tree(110 + i)
        out["reeds-%d" % i] = reeds(120 + i)
    out["lily"] = lily(130)
    out["dream-pod"] = pod()
    return out


# ====================================================================== icon đồ Cam
def g_dream_pillow(cv):
    glow(cv, 16, 17, 12, hexc("#c28af0"), 80)
    cv.shade_poly([(5, 14), (9, 9), (24, 9), (28, 14), (25, 23), (8, 23)], R["purple"])
    cv.line(9, 12, 23, 12, R["purple"][3], 1.0)
    for (x, y) in ((11, 17), (16, 15), (21, 18)):
        cv.ellipse(x, y, 1.2, 1.2, (255, 230, 255, 220))
    cv.shade_ellipse(16, 6, 3, 2.4, R["gold"])


def g_hydra_scale(cv):
    cv.shade_poly([(7, 7), (25, 7), (26, 20), (16, 28), (6, 20)], SWAMP["water"])
    for row in range(3):
        for col in range(4):
            x = 9 + col * 4.5 + (row % 2) * 2
            y = 11 + row * 5
            cv.arc(x, y, 2.4, 0, math.pi, R["crystal"][3], 1.0)
    glow(cv, 16, 16, 6, hexc("#4fc3ff"), 70)


ICONS = {"goi_mong": g_dream_pillow, "vay_that_dau": g_hydra_scale}


# ====================================================================== đăng ký (gọi từ catalog.py, env.py, icons.py)
def register_sprites(sprites):
    from builders import BUILDERS as B
    for k, v in BUILDERS.items():
        B.setdefault(k, v)
    for k, v in SPRITES.items():
        sprites.setdefault(k, v)


def register_env(out):
    from env import tile
    for k, v in build_env(tile).items():
        out.setdefault(k, v)


def register_icons(items):
    for k, v in ICONS.items():
        items.setdefault(k, v)
