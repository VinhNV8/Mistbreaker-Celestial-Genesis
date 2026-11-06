"""EQ-HD (docs/40): bộ nguyên tố vẽ icon trang bị HD kiểu "MMORPG châu Á" (ảnh mẫu Pinterest 811773901563380624).

Quy chuẩn rút từ ảnh mẫu (docs/40 §2):
  E1 góc 3/4, vật nghiêng chéo, chiếm 80–90% ô; nguồn sáng trên-trái.
  E2 chất liệu có dải 3 tông + **vệt bóng loáng** (specular) sắc trên kim loại; vải có nếp; da có đường may.
  E3 **ngọc khảm** là điểm nhấn (mặt cắt nhiều mặt + chấm sáng trắng).
  E4 bậc phẩm chất = bậc chất liệu + độ cầu kỳ: Trắng sắt cũ trơn → Lục thép + viền → Lam bạc + ngọc → Tím
     thép tối viền vàng + hoa văn → Cam vàng ròng + ngọc lớn + cánh / gai + hào quang.
  E5 đồ trong bộ (set) dùng chung **bảng màu + hoạ tiết** của bộ.
  E6 viền tối mảnh (không dày như quái) để giữ chất "tranh vẽ".

Vẽ bằng vec.Canvas (siêu mẫu ×4, Lanczos). Toạ độ trong ô 128 × 128.
"""
import math

from vec import Canvas, Tone, bezier, hexc, mix  # noqa: F401

S = 128
OUTLINE = "#140d18"


def T(base, shade, light):
    return Tone(base, shade, light)


# ------------------------------------------------------------------ chất liệu
IRON = T("#8d929a", "#4f535c", "#c9ced6")
STEEL = T("#b9c4d2", "#66728a", "#f2f6ff")
SILVER = T("#dfe6f0", "#8a97b0", "#ffffff")
GOLD = T("#e8b648", "#9a6416", "#fff2b8")
DARK = T("#4c4766", "#24203a", "#8a84b0")
LEATHER = T("#86563a", "#4e2e1c", "#bf8a62")
LEATHER_D = T("#5e3c2a", "#331e14", "#8e6448")
WOOD = T("#9a6a3c", "#5a3a1c", "#d4a066")
BONE = T("#e6dcc4", "#a39478", "#fffaf0")


# ------------------------------------------------------------------ chủ đề (phẩm chất + bộ)
class Theme:
    def __init__(self, key, name, metal, trim, cloth, leather, gem, glow, orn, aura=False, motif=""):
        self.key, self.name = key, name
        self.metal, self.trim, self.cloth, self.leather = metal, trim, cloth, leather
        self.gem, self.glow, self.orn, self.aura, self.motif = gem, glow, orn, aura, motif


THEMES = {
    # phẩm chất (đồ không thuộc bộ)
    "white": Theme("white", "Trắng", IRON, IRON, T("#8c8070", "#585046", "#b8ac98"), LEATHER_D, None, None, 0),
    "green": Theme("green", "Xanh lá", STEEL, T("#4fae5c", "#25652e", "#9be8a2"), T("#4f7a4a", "#2c4a2a", "#86b07e"),
                   LEATHER, "#5bd16a", None, 1),
    "blue": Theme("blue", "Xanh dương", SILVER, T("#3d7ee0", "#1d3f8a", "#9ac4ff"), T("#2f5a9e", "#1a3266", "#6a96d8"),
                  LEATHER, "#4aa0ff", "#4aa0ff", 2),
    "purple": Theme("purple", "Tím", DARK, GOLD, T("#6a3aa8", "#3a1a66", "#a87ae0"), LEATHER_D, "#b46bff", "#a35cff", 3),
    "orange": Theme("orange", "Cam", GOLD, T("#d84a2a", "#7e1e12", "#ff9a7a"), T("#b0301e", "#661410", "#e86a4a"),
                    LEATHER, "#ff6a2a", "#ffae40", 4, aura=True),
    # bộ (set) — bảng màu + hoạ tiết riêng
    "frost_hunter": Theme("frost_hunter", "Thợ Săn Sương", STEEL, T("#e8f2ff", "#9ab4d0", "#ffffff"), T("#5a8ab8", "#2e4e74", "#9ccaf0"),
                          T("#d8d2c4", "#988e7c", "#fffaf0"), "#8ad8ff", "#8ad8ff", 3, motif="fur"),
    "phong_hanh": Theme("phong_hanh", "Phong Hành", SILVER, T("#5ac8a0", "#22785a", "#aef5d8"), T("#3a9a7a", "#1c5a44", "#7ad8b4"),
                        LEATHER, "#7affd0", "#7affd0", 3, motif="feather"),
    "u_minh": Theme("u_minh", "U Minh", T("#5a6a58", "#2c3a2c", "#92a68e"), T("#8a6ad0", "#46308a", "#c4a8ff"),
                    T("#3e4a36", "#20281a", "#6e7e5e"), LEATHER_D, "#9aff5a", "#c28af0", 3, motif="swamp"),
    "hoa_nguc": Theme("hoa_nguc", "Hoả Ngục", T("#4a3a36", "#221816", "#7e6660"), GOLD, T("#a8261a", "#5a0e08", "#e8583a"),
                      LEATHER_D, "#ff8a2a", "#ff6a1a", 4, aura=True, motif="flame"),
    "cuc_quang": Theme("cuc_quang", "Cực Quang", SILVER, T("#5ae0e8", "#1e8090", "#b8fbff"), T("#3a6aa8", "#1c3466", "#7aa8e8"),
                       T("#e6eef8", "#a0b0c4", "#ffffff"), "#7affff", "#9affee", 4, aura=True, motif="ice"),
    "thien_phong": Theme("thien_phong", "Thiên Phong", T("#f0f4fa", "#a4b4cc", "#ffffff"), GOLD, T("#3a7ae0", "#1a3e8a", "#8ac0ff"),
                         LEATHER, "#9ad8ff", "#fff0b0", 4, aura=True, motif="wing"),
    "tinh_quang": Theme("tinh_quang", "Tinh Quang", T("#3a3470", "#1a1640", "#7a70c0"), SILVER, T("#4a2a8a", "#24104e", "#8a6ad8"),
                        LEATHER_D, "#e0b0ff", "#c890ff", 4, aura=True, motif="star"),
    "thien_dao": Theme("thien_dao", "Thiên Đạo", T("#f4f0e4", "#b4aa90", "#ffffff"), GOLD, T("#3aa88a", "#1a6450", "#7ae0c4"),
                       T("#f0e8d4", "#b0a488", "#ffffff"), "#7ad0ff", "#fff0b0", 4, aura=True, motif="jade"),
    "sa_hanh": Theme("sa_hanh", "Sa Hành Giả", GOLD, T("#2aa8a0", "#126460", "#7ae8e0"), T("#c89a5a", "#86602e", "#f0cc8e"),
                     LEATHER, "#3ad8d0", "#ffd27a", 3, motif="sand"),
}
RARITY_KEYS = ["white", "green", "blue", "purple", "orange"]


# ------------------------------------------------------------------ hình học
def rot(p, c, a):
    dx, dy = p[0] - c[0], p[1] - c[1]
    return (c[0] + dx * math.cos(a) - dy * math.sin(a), c[1] + dx * math.sin(a) + dy * math.cos(a))


def along(base, tip):
    """Hàm p(t, s): điểm cách base t đơn vị theo hướng base→tip, lệch ngang s."""
    dx, dy = tip[0] - base[0], tip[1] - base[1]
    L = math.hypot(dx, dy)
    ux, uy = dx / L, dy / L
    nx, ny = -uy, ux
    return (lambda t, s=0.0: (base[0] + ux * t + nx * s, base[1] + uy * t + ny * s)), L


def arc(cx, cy, rx, ry, a0, a1, n=32):
    return [(cx + math.cos(a0 + (a1 - a0) * i / n) * rx, cy + math.sin(a0 + (a1 - a0) * i / n) * ry) for i in range(n + 1)]


def new():
    return Canvas(S, S, light=(-1.0, -1.25))


def glow_bg(c, fn, col, radius, alpha):
    """Quầng sáng SAU vật, không viền tối (viền của Canvas.render tính theo alpha — quầng vẽ chung lớp sẽ thành đĩa tối)."""
    if not hasattr(c, "bg"):
        c.bg = new()
    c.bg.glow(fn, col, radius=radius, alpha=alpha)


def glow_fg(c, fn, col, radius, alpha):
    """Quầng sáng TRƯỚC vật (ngọc, pha lê), không viền tối, phủ sau lớp tranh vẽ."""
    if not hasattr(c, "fg"):
        c.fg = new()
    c.fg.glow(fn, col, radius=radius, alpha=alpha)


# ------------------------------------------------------------------ chi tiết dùng chung
def spec(c, pts, w=2.4, alpha=200):
    """Vệt bóng loáng sắc trên kim loại (E2): dải trắng mảnh dọc theo pts."""
    c.flat(lambda d: c.ribbon(d, pts, [w * 0.3] + [w] * (len(pts) - 2) + [w * 0.3]), "#ffffff", alpha=alpha)


def sparkle(c, x, y, r, col="#ffffff", alpha=235):
    k = r * 0.25
    c.flat(lambda d: c.poly(d, [(x, y - r), (x + k, y - k), (x + r, y), (x + k, y + k), (x, y + r), (x - k, y + k),
                                (x - r, y), (x - k, y - k)]), col, alpha=alpha)


def gem(c, x, y, r, col, cut="round", glow=True):
    """Ngọc khảm (E3): ổ viền tối, mặt cắt 3 tông, mặt trên sáng, chấm sáng trắng."""
    if col is None:
        return
    base = hexc(col)
    tone = Tone(col, mix(base, (20, 10, 40, 255), 0.55), mix(base, (255, 255, 255, 255), 0.55))
    if glow:
        glow_fg(c, lambda d: c.circle(d, x, y, r * 1.6), col, r * 0.5, 120)
    if cut == "round":
        shape = lambda d: c.circle(d, x, y, r)  # noqa: E731
    elif cut == "drop":
        shape = lambda d: c.poly(d, [(x, y - r * 1.35)] + arc(x, y + r * 0.15, r, r, -0.15 * math.pi, 1.15 * math.pi, 16)[::-1])  # noqa: E731
    else:  # "diamond"
        shape = lambda d: c.poly(d, [(x, y - r * 1.25), (x + r, y), (x, y + r * 1.25), (x - r, y)])  # noqa: E731
    c.part(shape, tone, shade_d=r * 0.35, light_d=r * 0.18)
    c.flat(lambda d: c.poly(d, [(x - r * 0.55, y - r * 0.15), (x, y - r * 0.7), (x + r * 0.55, y - r * 0.15), (x, y + r * 0.2)]),
           tone.light, alpha=170)
    c.flat(lambda d: c.circle(d, x - r * 0.35, y - r * 0.4, max(1.0, r * 0.22)), "#ffffff", alpha=240)


def rivets(c, pts, r=1.8, tone=None):
    tone = tone or GOLD
    for (x, y) in pts:
        c.part(lambda d, x=x, y=y: c.circle(d, x, y, r), tone, shade_d=r * 0.5, light_d=r * 0.25)


def aura(c, th, cx=64, cy=64, r=44):
    """Hào quang sau vật (đồ Cam / bộ cao cấp) + hoạ tiết nền của bộ (E5) — vẽ trước vật, nằm sau vật."""
    if th.aura and th.glow:
        glow_bg(c, lambda d: c.circle(d, cx, cy, r), th.glow, 12, 150)
    backdrop(c, th, cx, cy, r)


def backdrop(c, th, cx, cy, r):
    """Hoạ tiết nền theo bộ: cánh, lửa, băng, lông vũ, sao, vòng ngọc, bọt độc, cát xoáy. Mờ hơn vật chính."""
    m = th.motif
    if m == "wing":
        for sx in (-1, 1):
            for k in range(4):
                ang = math.radians(-90 + sx * (28 + k * 16))
                ln = r * (1.05 - k * 0.12)
                tip = (cx + math.cos(ang) * ln, cy + math.sin(ang) * ln)
                root = (cx + sx * 6, cy - 4)
                c.part(lambda d, tip=tip, root=root: c.capsule(d, root, tip, 7 - k, 3), SILVER, shade_d=1.2, light_d=0.6, alpha=200)
    elif m == "flame":
        for k in range(7):
            ang = math.radians(-160 + k * 23)
            bx, by = cx + math.cos(ang) * r * 0.55, cy + math.sin(ang) * r * 0.55
            tx, ty = cx + math.cos(ang) * r * 1.05, cy + math.sin(ang) * r * 1.05 - 6
            nx, ny = -math.sin(ang) * 7, math.cos(ang) * 7
            c.flat(lambda d, bx=bx, by=by, tx=tx, ty=ty, nx=nx, ny=ny: c.poly(d, [(bx + nx, by + ny), (tx, ty), (bx - nx, by - ny)]),
                   "#ff6a1a", alpha=150)
            c.flat(lambda d, bx=bx, by=by, tx=tx, ty=ty, nx=nx, ny=ny: c.poly(d, [(bx + nx * 0.5, by + ny * 0.5), ((bx + tx) / 2, (by + ty) / 2),
                                                                                   (bx - nx * 0.5, by - ny * 0.5)]), "#ffd040", alpha=170)
    elif m == "ice":
        for k in range(6):
            ang = math.radians(-150 + k * 24)
            tip = (cx + math.cos(ang) * r * 1.05, cy + math.sin(ang) * r * 1.05)
            nx, ny = -math.sin(ang) * 6, math.cos(ang) * 6
            bx, by = cx + math.cos(ang) * r * 0.5, cy + math.sin(ang) * r * 0.5
            c.part(lambda d, tip=tip, nx=nx, ny=ny, bx=bx, by=by: c.poly(d, [(bx + nx, by + ny), tip, (bx - nx, by - ny)]),
                   T("#bff8ff", "#5ab8d0", "#ffffff"), shade_d=1.2, light_d=0.6, alpha=170)
    elif m == "feather":
        for sx in (-1, 1):
            pts = bezier((cx - sx * 6, cy + r * 0.7), (cx + sx * r * 0.3, cy), (cx + sx * r * 0.8, cy - r * 0.6), n=14)
            c.part(lambda d, pts=pts: c.ribbon(d, pts, [2] + [12 - 6 * i / 14 for i in range(1, 14)] + [1]), th.trim, shade_d=1.4,
                   light_d=0.7, alpha=190)
            c.flat(lambda d, pts=pts: c.ribbon(d, pts, [0.8] * 15), "#ffffff", alpha=150)
    elif m == "star":
        for k in range(6):
            ang = math.radians(k * 60 + 15)
            sparkle(c, cx + math.cos(ang) * r * 0.95, cy + math.sin(ang) * r * 0.95, 5 + (k % 2) * 3, "#f0d8ff", alpha=210)
        c.flat(lambda d: c.ribbon(d, arc(cx, cy, r * 0.95, r * 0.95, 0, math.tau, 60), [1.2] * 61), "#c890ff", alpha=120)
    elif m == "jade":
        c.part(lambda d: c.ribbon(d, arc(cx, cy, r * 0.92, r * 0.92, 0, math.tau, 60), [5] * 61), T("#5ad0a8", "#1e7a5a", "#c0ffe8"),
               shade_d=1.2, light_d=0.6, alpha=170)
    elif m == "swamp":
        glow_bg(c, lambda d: c.circle(d, cx, cy + r * 0.3, r * 0.8), "#6a3aa8", 10, 130)
        for k in range(6):
            ang = math.radians(150 + k * 45)
            c.flat(lambda d, ang=ang, k=k: c.circle(d, cx + math.cos(ang) * r * 0.9, cy + math.sin(ang) * r * 0.9, 2.5 + (k % 3)),
                   "#9aff5a", alpha=190)
    elif m == "sand":
        c.flat(lambda d: c.ribbon(d, arc(cx, cy, r, r * 0.55, math.radians(150), math.radians(400), 40),
                                  [1 + 5 * math.sin(math.pi * i / 40) for i in range(41)]), "#f0c870", alpha=150)
    elif m == "fur":
        glow_bg(c, lambda d: c.circle(d, cx, cy, r * 0.8), "#cfe6ff", 10, 90)


def motif(c, th, x, y, s=1.0):
    """Hoạ tiết nhỏ của bộ (E5), đặt ở chỗ trống của icon."""
    m = th.motif
    if m == "fur":
        for k in range(5):
            c.part(lambda d, k=k: c.ellipse(d, x - 10 * s + k * 5 * s, y, 4 * s, 6 * s), th.leather, shade_d=1, light_d=0.5)
    elif m == "feather":
        pts = bezier((x - 12 * s, y + 8 * s), (x - 4 * s, y - 6 * s), (x + 10 * s, y - 10 * s), n=12)
        c.part(lambda d: c.ribbon(d, pts, [1] + [7 * s] * 11 + [1]), th.trim, shade_d=1.2, light_d=0.6)
        c.flat(lambda d: c.ribbon(d, pts, [0.6] * 13), "#ffffff", alpha=170)
    elif m == "flame":
        c.flat(lambda d: c.poly(d, [(x, y - 12 * s), (x + 6 * s, y), (x + 2 * s, y + 6 * s), (x - 6 * s, y + 4 * s), (x - 4 * s, y - 4 * s)]),
               "#ff8a2a", alpha=230)
        c.flat(lambda d: c.poly(d, [(x, y - 5 * s), (x + 3 * s, y + 2 * s), (x - 3 * s, y + 3 * s)]), "#fff0a0", alpha=230)
    elif m == "ice":
        for a in range(3):
            ang = a * math.pi / 3
            p0 = (x + math.cos(ang) * 8 * s, y + math.sin(ang) * 8 * s)
            p1 = (x - math.cos(ang) * 8 * s, y - math.sin(ang) * 8 * s)
            c.flat(lambda d, p0=p0, p1=p1: c.capsule(d, p0, p1, 1.4 * s), "#e8ffff", alpha=230)
    elif m == "wing":
        for k in range(3):
            c.part(lambda d, k=k: c.ellipse(d, x - 2 * s + k * 5 * s, y - k * 3 * s, 9 * s - k * 2 * s, 3.2 * s, -0.6), SILVER,
                   shade_d=0.8, light_d=0.5)
    elif m == "star":
        sparkle(c, x, y, 8 * s, "#f0d8ff")
        sparkle(c, x + 9 * s, y + 7 * s, 4 * s, "#ffffff")
    elif m == "jade":
        c.part(lambda d: c.circle(d, x, y, 7 * s), T("#5ad0a8", "#1e7a5a", "#c0ffe8"), shade_d=1.6, light_d=0.8)
        c.flat(lambda d: c.circle(d, x, y, 2.5 * s), "#1e5a46")
    elif m == "swamp":
        for k in range(3):
            c.flat(lambda d, k=k: c.circle(d, x - 6 * s + k * 6 * s, y + (k % 2) * 4 * s, 2.6 * s), "#9aff5a", alpha=200)
    elif m == "sand":
        c.part(lambda d: c.poly(d, [(x - 8 * s, y + 6 * s), (x, y - 8 * s), (x + 8 * s, y + 6 * s)]), T("#e0b060", "#8a6420", "#fff0b8"),
               shade_d=1.4, light_d=0.6)
        c.flat(lambda d: c.circle(d, x, y + 1 * s, 2.4 * s), "#3ad8d0")


def render(c):
    from PIL import Image
    item = paint_pass(c.render(outline=OUTLINE, width=2.0))
    out = Image.new("RGBA", item.size, (0, 0, 0, 0))
    if hasattr(c, "bg"):
        out.alpha_composite(c.bg.img.resize(item.size, Image.LANCZOS))
    out.alpha_composite(item)
    if hasattr(c, "fg"):
        out.alpha_composite(c.fg.img.resize(item.size, Image.LANCZOS))
    return out


def paint_pass(img):
    """EQ-HD v2 (docs/42 §4): lớp "tranh vẽ" sau khi dựng — kéo icon từ "phẳng" về gần icon MMORPG vẽ tay:
    ánh sáng chéo (trên-trái sáng, dưới-phải tối) trên toàn vật, viền sáng ở mép đón sáng, bóng lõm ở mép khuất,
    hạt vân chất liệu rất nhẹ, tăng tương phản + độ bão hoà. Chỉ tác động phần vật đặc (alpha cao), không đụng glow."""
    import numpy as np
    from PIL import Image, ImageEnhance, ImageFilter
    a = np.asarray(img).astype(np.float32)
    rgb, al = a[..., :3], a[..., 3] / 255.0
    h, w = al.shape
    solid = np.clip((al - 0.55) / 0.35, 0.0, 1.0)
    yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
    diag = (xx / w + yy / h) / 2.0                       # 0 trên-trái → 1 dưới-phải
    light = 1.16 - 0.36 * diag                            # +16% … −20%
    m = Image.fromarray((solid * 255).astype(np.uint8))
    blur = np.asarray(m.filter(ImageFilter.GaussianBlur(2.2))).astype(np.float32) / 255.0
    # mép đón sáng: phần vật mà điểm lệch về trên-trái là nền → viền sáng; ngược lại → bóng lõm
    sh_tl = np.roll(np.roll(blur, 3, axis=0), 3, axis=1)
    sh_br = np.roll(np.roll(blur, -3, axis=0), -3, axis=1)
    rim = np.clip(blur - sh_tl, 0.0, 1.0) * solid
    occ = np.clip(blur - sh_br, 0.0, 1.0) * solid
    rng = np.random.default_rng(7)
    grain = 1.0 + (rng.random((h, w)).astype(np.float32) - 0.5) * 0.07
    k = (light * grain)[..., None]
    out = rgb * (1.0 + (k - 1.0) * solid[..., None])
    out = out + (np.array([255, 246, 225], np.float32) - out) * (rim * 0.55)[..., None]
    out = out * (1.0 - occ * 0.45)[..., None]
    res = Image.fromarray(np.dstack([np.clip(out, 0, 255), a[..., 3]]).astype(np.uint8), "RGBA")
    rgb_img = res.convert("RGB")
    rgb_img = ImageEnhance.Contrast(rgb_img).enhance(1.08)
    rgb_img = ImageEnhance.Color(rgb_img).enhance(1.14)
    res = Image.merge("RGBA", (*rgb_img.split(), res.getchannel("A")))
    return res
