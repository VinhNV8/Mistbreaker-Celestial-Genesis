"""MD-1 (docs/39): bộ khung vẽ quái HD theo phong cách "cartoon vẽ tay" (ảnh mẫu Pinterest, docs/39 §2).

Mọi bộ dựng quái (mon_biped / mon_beast / mon_misc) vẽ trong KHÔNG GIAN THIẾT KẾ 96 × 96 đơn vị, gốc toạ độ
ở điểm chân (giữa bóng), y âm là lên trên, quái quay mặt sang PHẢI. Kích thước logic L (24 / 32 / 48 như hình
pixel cũ) chỉ quyết định độ phân giải: ảnh ra L×4 px, 1 đơn vị = L/24 px.

Ba lớp mỗi frame:
  back  — hào quang, khói phía sau (không viền)
  body  — thân quái: tô cel (nền / bóng / sáng) + chuyển sáng dọc (đầu sáng, chân tối) + viền sáng ngược (rim)
          + viền tối dày quanh silhouette
  front — mắt phát sáng, tia lửa, hạt phép (không viền)

Hoạt ảnh chuẩn: idle 4 · run 4 · attack 3 · hurt 2 · death 3. Bộ dựng chỉ cần vẽ 1 tư thế từ `pose`
(anim, i, ph); hurt / death do khung này dựng chung (giật lùi + nháy sáng, ngã / tan biến).
"""
import math
import os
import sys

from PIL import Image, ImageChops, ImageDraw, ImageFilter

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from vec import Canvas, Tone, bezier, hexc, mix  # noqa: E402,F401

PX = 4
DESIGN = 96.0
OX, OY = 48.0, 88.0
OUTLINE = "#1b1022"
ORDER = ["idle", "run", "attack", "hurt", "death"]
COUNT = {"idle": 4, "run": 4, "attack": 3, "hurt": 2, "death": 3}
FPS = {"idle": 4, "run": 9, "attack": 9, "hurt": 8, "death": 6}
LOOP = {"idle": True, "run": True, "attack": False, "hurt": False, "death": False}

# Dải màu dùng chung (nền, bóng, sáng). Bóng ngả tím lạnh, sáng ngả kem ấm — như ảnh mẫu.
PAL = {
    # da / thịt
    "skin": ("#e0a882", "#a8665a", "#f6d2b4"), "skin_light": ("#f0c7a6", "#b88078", "#fde6d2"),
    "skin_dark": ("#a8704e", "#6a3c36", "#d09a72"), "orc": ("#7fae4e", "#3f6a3a", "#b6dc7a"),
    "bone": ("#e6dcc0", "#9a8a78", "#fffbea"), "bandage": ("#d8c8a0", "#8e7a62", "#f6ecd0"),
    "shadow": ("#3a2c56", "#1c1430", "#6a58a0"), "void_black": ("#2a2038", "#120c1e", "#54467a"),
    "spirit": ("#bcd8f0", "#7090c0", "#f2faff"), "silver": ("#c8c4d4", "#7c7890", "#f4f2fa"),
    # vải / giáp
    "steel": ("#8c9ab0", "#4e5870", "#d0dcec"), "iron": ("#6a7286", "#383e52", "#a8b2c8"),
    "gold": ("#e0b040", "#966a1e", "#ffe48a"), "heaven_gold": ("#f0c860", "#a8782a", "#fff0b0"),
    "leather": ("#8a5a3a", "#523222", "#b8865a"), "wood": ("#9a6a42", "#5a3a26", "#c89a66"),
    "bark": ("#6a4a34", "#3a281e", "#9a7656"), "cloth_red": ("#c03a3a", "#701e2e", "#ee7060"),
    "blood": ("#a0203a", "#5a1028", "#e05068"), "cloth_blue": ("#3a6ac0", "#22366e", "#78a8ee"),
    "purple": ("#7a4ab8", "#3e2470", "#b48ae8"), "void": ("#5a3a96", "#2c1a5a", "#9a74d8"),
    "abyss": ("#3a2a5e", "#1a1234", "#6a54a0"), "leaf": ("#5a9a3a", "#2e5a2a", "#9ad06a"),
    "leaf_dark": ("#3a6a34", "#1e3a24", "#6a9a52"), "leaf_sky": ("#6ac08a", "#2e7458", "#b0eec0"),
    "swamp": ("#4a6a38", "#24381e", "#7a9a5a"), "jade": ("#3aa88a", "#1a6050", "#7ae0c0"),
    "sand": ("#d8b070", "#946a3a", "#f6dca0"), "sand_red": ("#c06a3a", "#7a3622", "#ec9a62"),
    "stone": ("#8a8a94", "#4c4c5a", "#c0c0ca"), "basalt": ("#4a3e44", "#261e26", "#7a6a70"),
    "marble": ("#e4e0d8", "#9e98a4", "#ffffff"), "snow": ("#eef4fa", "#a0b4cc", "#ffffff"),
    "ice": ("#8ad0f0", "#3a7ab4", "#d4f4ff"), "frost": ("#5a8ac0", "#2a4a7a", "#a0caf0"),
    "sky": ("#5aa0e0", "#2a5a9a", "#a0d4ff"), "cloud": ("#e8f0fa", "#9aaccc", "#ffffff"),
    "fire": ("#f0702a", "#a02a1a", "#ffc060"), "ember": ("#c84a2a", "#6e1e1a", "#f08a4a"),
    "lava": ("#ff8a2a", "#c03a10", "#ffe080"), "white": ("#eeeaf2", "#a8a2b8", "#ffffff"),
    "chitin": ("#5a3a2a", "#2a1a14", "#8a6248"), "fur_grey": ("#aebdd1", "#6c7d98", "#eef4fb"),
    "fur_snow": ("#e8eef6", "#9aaac4", "#ffffff"), "fur_void": ("#3f3657", "#231d35", "#6f6296"),
    "wisp": ("#9de0e6", "#4a94b4", "#e6fcff"), "crystal": ("#a8d8ff", "#5a8ad0", "#eaf6ff"),
    "slime": ("#7adc5a", "#3a8a3a", "#c8ff9a"), "toad": ("#6ab84a", "#2e6a34", "#aee87a"),
    "mud": ("#6a5a3a", "#3a3020", "#9a8658"), "leech": ("#6e2a3a", "#3a1222", "#a84e62"),
    "sea": ("#2a6a8a", "#143a52", "#5aa8c8"), "pink": ("#e080b8", "#984a7a", "#ffc0e0"),
    "sky_gold": ("#f0c050", "#a87a2a", "#ffe8a0"), "starlight": ("#fff0b0", "#c8a860", "#ffffff"),
    "hair_dark": ("#3a2a2e", "#1c1218", "#6a4e50"), "hair_brown": ("#7a4a2a", "#46281a", "#a87248"),
    "leaf_light": ("#a8e070", "#5a9a3a", "#e0ffb0"), "ash": ("#6a5e60", "#3a3236", "#9a8e90"),
}


def tone(name_or_hex, light=None):
    """Tone từ tên dải màu trong PAL hoặc mã hex (tự sinh bóng / sáng)."""
    if isinstance(name_or_hex, Tone):
        return name_or_hex
    if name_or_hex in PAL:
        b, s, l = PAL[name_or_hex]
        return Tone(b, s, l)
    return Tone(name_or_hex)


def darker(t, k=0.28):
    t = tone(t)
    return Tone(mix(t.base, (24, 16, 40, 255), k), mix(t.shade, (16, 10, 28, 255), k), mix(t.light, t.base, 0.5))


class Pen:
    """Vẽ trên mặt nạ bằng toạ độ thiết kế (gốc = chân, đơn vị 96-không-gian)."""

    def __init__(self, f, d):
        self.f, self.d = f, d

    def P(self, x, y):
        return self.f.P(x, y)

    def circle(self, x, y, r):
        X, Y = self.P(x, y)
        self.f.c.circle(self.d, X, Y, r * self.f.u)

    def ellipse(self, x, y, rx, ry, rot=0.0):
        X, Y = self.P(x, y)
        self.f.c.ellipse(self.d, X, Y, rx * self.f.u, ry * self.f.u, rot)

    def poly(self, pts):
        self.f.c.poly(self.d, [self.P(x, y) for x, y in pts])

    def capsule(self, a, b, ra, rb=None):
        rb = ra if rb is None else rb
        self.f.c.capsule(self.d, self.P(*a), self.P(*b), ra * self.f.u, rb * self.f.u)

    def ribbon(self, pts, widths):
        self.f.c.ribbon(self.d, [self.P(x, y) for x, y in pts], [w * self.f.u for w in widths])

    def line(self, pts, w):
        self.ribbon(pts, [w] * len(pts))


class Frame:
    """Một frame quái: 3 lớp Canvas cùng cỡ, toạ độ thiết kế."""

    def __init__(self, L, dx=0.0, dy=0.0):
        self.L = L
        self.u = L * PX / DESIGN
        self.size = int(L * PX)
        self.dx, self.dy = dx, dy
        self.c = Canvas(self.size, self.size)
        self.back = Canvas(self.size, self.size)
        self.front = Canvas(self.size, self.size)

    def P(self, x, y):
        return ((OX + x + self.dx) * self.u, (OY + y + self.dy) * self.u)

    # ---- thân (có bóng cel, được viền)
    def part(self, fn, t, sd=3.0, ld=1.4, clip=None, shade=True, alpha=255):
        return self.c.part(lambda d: fn(Pen(self, d)), tone(t), shade_d=sd * self.u, light_d=ld * self.u, clip=clip,
                           shade=shade, alpha=alpha)

    def flat(self, fn, col, alpha=255, blur=0.0, layer=None):
        cv = layer or self.c
        cv.flat(lambda d: fn(Pen(self, d)), col, alpha=alpha, blur=blur * self.u)

    def mask(self, fn):
        m = self.c.mask()
        fn(Pen(self, ImageDraw.Draw(m)))
        return m

    # ---- lớp hiệu ứng (không viền)
    def glow(self, fn, col, radius=4.0, alpha=150, front=False):
        cv = self.front if front else self.back
        cv.glow(lambda d: fn(Pen(self, d)), col, radius=radius * self.u, alpha=alpha)

    def fx(self, fn, col, alpha=255, blur=0.0):
        self.front.flat(lambda d: fn(Pen(self, d)), col, alpha=alpha, blur=blur * self.u)

    def shadow(self, rx, ry=None, k=1.0):
        ry = ry if ry is not None else rx * 0.24
        self.back.flat(lambda d: Pen(self, d).ellipse(-self.dx, 0.6 - self.dy, rx * k, ry * k), (12, 8, 22, 255), alpha=86,
                       blur=1.2 * self.u)

    def eyes(self, pts, col, r=1.6, glow=True, slit=False):
        """Mắt phát sáng (lớp front): pts = [(x, y)], quầng sáng + lòng mắt + đốm trắng."""
        if glow:
            self.glow(lambda g: [g.circle(x, y, r * 1.9) for x, y in pts], col, radius=r * 1.2, alpha=170, front=True)
        if slit:
            self.fx(lambda g: [g.ellipse(x, y, r * 1.25, r * 0.6, -0.3) for x, y in pts], col)
        else:
            self.fx(lambda g: [g.circle(x, y, r) for x, y in pts], col)
        self.fx(lambda g: [g.circle(x + r * 0.3, y - r * 0.35, r * 0.38) for x, y in pts], "#ffffff", alpha=230)

    # ---- hoàn thiện
    def render(self, outline=OUTLINE, width=2.4, rim="#cfe4ff", rim_alpha=120, grad=0.22, fade=1.0, flash=0.0):
        c = self.c
        img = c.img
        a = img.getchannel("A")
        solid = a.point(lambda v: 255 if v > 200 else 0)
        S = c.ss
        # chuyển sáng dọc: nửa dưới tối dần (chân tối, đầu sáng) như ảnh mẫu
        if grad > 0:
            g = Image.linear_gradient("L").resize(img.size)
            m = ImageChops.multiply(g.point(lambda v: int(grad * 255 * max(0.0, (v / 255.0 - 0.35) / 0.65))), a)
            img = Image.alpha_composite(img, _with_alpha(Image.new("RGBA", img.size, (20, 12, 36, 255)), m))
            img.putalpha(a)
        # viền sáng ngược phía dưới-phải (ánh trời / phép phản chiếu)
        if rim and rim_alpha > 0:
            sh = int(round(1.6 * self.u * S))
            moved = ImageChops.offset(solid, -sh, -sh)
            edge = ImageChops.subtract(solid, moved).filter(ImageFilter.GaussianBlur(S * 0.5 * self.u))
            edge = ImageChops.multiply(edge, solid)
            layer = Image.new("RGBA", img.size, hexc(rim)[:3] + (255,))
            layer.putalpha(edge.point(lambda v: v * rim_alpha // 255))
            img = Image.alpha_composite(img, layer)
        if flash > 0:
            wl = Image.new("RGBA", img.size, (255, 240, 240, 255))
            wl.putalpha(a.point(lambda v: int(v * flash)))
            img = Image.alpha_composite(img, wl)
        c.img = img
        body = c.render(outline=outline, width=width * self.u)
        out = self.back.render(outline=None)
        out.alpha_composite(body)
        out.alpha_composite(self.front.render(outline=None))
        if fade < 1.0:
            out.putalpha(out.getchannel("A").point(lambda v: int(v * fade)))
        return out


def _with_alpha(img, a):
    img = img.copy()
    img.putalpha(a)
    return img


# ------------------------------------------------------------------ hoạt ảnh chung
def poses():
    """(anim, i, ph) cho mọi frame theo ORDER."""
    out = []
    for a in ORDER:
        n = COUNT[a]
        out.append([(a, i, i / n) for i in range(n)])
    return out


def _transform_death(img, L, i, style):
    """Ngã sang trái quanh chân (fall), tan biến (fade) hoặc vỡ sụp (crumble)."""
    size = img.size[0]
    ox, oy = OX * L * PX / DESIGN, OY * L * PX / DESIGN
    out = Image.new("RGBA", img.size, (0, 0, 0, 0))
    if style == "fade":
        k = [1.08, 1.2, 1.35][i]
        w = int(size * k)
        im = img.resize((w, w), Image.LANCZOS)
        out.alpha_composite(im, (int(ox - ox * k), int(oy - oy * k)))
        out.putalpha(out.getchannel("A").point(lambda v: int(v * [0.75, 0.45, 0.2][i])))
        return out
    if style == "crumble":
        sy = [0.86, 0.62, 0.4][i]
        sx = [1.06, 1.14, 1.22][i]
        im = img.resize((int(size * sx), max(1, int(size * sy))), Image.LANCZOS)
        out.alpha_composite(im, (int(ox - ox * sx), int(oy - oy * sy)))
        out.putalpha(out.getchannel("A").point(lambda v: int(v * [1.0, 0.85, 0.55][i])))
        return out
    ang = [18, 46, 66][i]
    im = img.rotate(ang, resample=Image.BICUBIC, center=(ox, oy))
    u = L * PX / DESIGN
    out.alpha_composite(im, (int([3, 10, 16][i] * u), int([0, 2, 3][i] * u)))
    out.putalpha(out.getchannel("A").point(lambda v: int(v * [1.0, 0.9, 0.6][i])))
    return out


def build(spec, draw):
    """draw(spec, pose) -> Frame đã vẽ (chưa render). Trả về (sheet, meta)."""
    L = spec["L"]
    rows = []
    for row in poses():
        imgs = []
        for anim, i, ph in row:
            if anim == "hurt":
                f = draw(spec, ("hurt", i, ph))
                imgs.append(f.render(flash=[0.45, 0.15][i], **spec.get("render", {})))
            elif anim == "death":
                f = draw(spec, ("hurt", 0, 0.0))
                im = f.render(**spec.get("render", {}))
                imgs.append(_transform_death(im, L, i, spec.get("death", "fall")))
            else:
                imgs.append(draw(spec, (anim, i, ph)).render(**spec.get("render", {})))
        rows.append(imgs)
    size = int(L * PX)
    cols = max(len(r) for r in rows)
    sheet = Image.new("RGBA", (cols * size, len(rows) * size), (0, 0, 0, 0))
    for ri, r in enumerate(rows):
        for ci, im in enumerate(r):
            sheet.alpha_composite(im, (ci * size, ri * size))
    meta = {"w": size, "h": size, "origin": [round(OX * size / DESIGN), round(OY * size / DESIGN)], "px": PX,
            "name": spec["name"], "size_mul": spec["size_mul"],
            "anims": {a: {"row": k, "frames": COUNT[a], "fps": FPS[a], "loop": LOOP[a]} for k, a in enumerate(ORDER)}}
    return sheet, meta


# ------------------------------------------------------------------ tiện ích tư thế
def cyc(ph, off=0.0):
    return math.sin(math.tau * (ph + off))


def attack_k(anim, i):
    """0 = bình thường, -1 = lấy đà (frame 0), +1 = ra đòn (frame 1), 0.4 = thu đòn (frame 2)."""
    if anim != "attack":
        return 0.0
    return [-1.0, 1.0, 0.4][i]
