"""UI-40 (docs/35, hướng B): thư viện vẽ vector cel-shade cho bộ hình HD.

Vẽ ở độ phân giải siêu mẫu (SS lần kích thước ra) rồi thu nhỏ LANCZOS → cạnh mượt, không răng cưa.
Mỗi "phần" (đầu, thân, tay…) là một mặt nạ: tô màu nền, đổ bóng cel (phần mặt nạ không trùng với chính nó dời
về phía nguồn sáng trên-trái), viền sáng mảnh; toàn bộ hình có viền tối mềm (giãn mặt nạ silhouette).

    c = Canvas(168, 200)
    c.part(lambda d: c.circle(d, 84, 60, 22), SKIN)
    img = c.render(outline=OUTLINE)
"""
import math

from PIL import Image, ImageChops, ImageDraw, ImageFilter

SS = 4


def hexc(s, a=255):
    s = s.lstrip("#")
    return (int(s[0:2], 16), int(s[2:4], 16), int(s[4:6], 16), a)


def mix(c1, c2, t):
    return tuple(int(round(c1[i] + (c2[i] - c1[i]) * t)) for i in range(4))


class Tone:
    """Bộ 3 màu cel: nền, bóng, sáng."""

    def __init__(self, base, shade=None, light=None):
        self.base = hexc(base) if isinstance(base, str) else base
        self.shade = (hexc(shade) if isinstance(shade, str) else shade) or mix(self.base, (20, 14, 40, 255), 0.42)
        self.light = (hexc(light) if isinstance(light, str) else light) or mix(self.base, (255, 250, 235, 255), 0.35)


class Canvas:
    def __init__(self, w, h, ss=SS, light=(-1.0, -1.3)):
        self.w, self.h, self.ss = w, h, ss
        self.W, self.H = w * ss, h * ss
        self.img = Image.new("RGBA", (self.W, self.H), (0, 0, 0, 0))
        lx, ly = light
        n = math.hypot(lx, ly)
        self.light = (lx / n, ly / n)

    # ---- toạ độ ra (px ảnh cuối) → siêu mẫu
    def p(self, x, y):
        return (x * self.ss, y * self.ss)

    def mask(self):
        return Image.new("L", (self.W, self.H), 0)

    # ---- hình cơ bản (vẽ lên ImageDraw của mặt nạ, toạ độ ảnh cuối)
    def circle(self, d, x, y, r):
        s = self.ss
        d.ellipse([(x - r) * s, (y - r) * s, (x + r) * s, (y + r) * s], fill=255)

    def ellipse(self, d, x, y, rx, ry, rot=0.0):
        if abs(rot) < 1e-3:
            s = self.ss
            d.ellipse([(x - rx) * s, (y - ry) * s, (x + rx) * s, (y + ry) * s], fill=255)
            return
        pts = []
        for i in range(48):
            a = math.tau * i / 48
            px, py = rx * math.cos(a), ry * math.sin(a)
            pts.append((x + px * math.cos(rot) - py * math.sin(rot), y + px * math.sin(rot) + py * math.cos(rot)))
        self.poly(d, pts)

    def poly(self, d, pts):
        d.polygon([self.p(x, y) for x, y in pts], fill=255)

    def capsule(self, d, a, b, ra, rb=None):
        """Đoạn dày đầu tròn từ a (bán kính ra) tới b (rb)."""
        rb = ra if rb is None else rb
        self.circle(d, a[0], a[1], ra)
        self.circle(d, b[0], b[1], rb)
        dx, dy = b[0] - a[0], b[1] - a[1]
        L = math.hypot(dx, dy) or 1e-6
        nx, ny = -dy / L, dx / L
        self.poly(d, [(a[0] + nx * ra, a[1] + ny * ra), (b[0] + nx * rb, b[1] + ny * rb),
                      (b[0] - nx * rb, b[1] - ny * rb), (a[0] - nx * ra, a[1] - ny * ra)])

    def ribbon(self, d, pts, widths):
        """Dải cong qua các điểm (đã nội suy), độ dày theo từng điểm — khăn, tóc, đuôi."""
        left, right = [], []
        n = len(pts)
        for i, (x, y) in enumerate(pts):
            ax, ay = pts[max(0, i - 1)]
            bx, by = pts[min(n - 1, i + 1)]
            dx, dy = bx - ax, by - ay
            L = math.hypot(dx, dy) or 1e-6
            nx, ny = -dy / L, dx / L
            w = widths[i] / 2.0
            left.append((x + nx * w, y + ny * w))
            right.append((x - nx * w, y - ny * w))
        self.poly(d, left + right[::-1])

    # ---- tô một phần: mặt nạ → nền + bóng cel + viền sáng
    def part(self, draw_fn, tone, shade_d=4.0, light_d=1.6, clip=None, shade=True, alpha=255):
        m = self.mask()
        draw_fn(ImageDraw.Draw(m))
        if clip is not None:
            m = ImageChops.multiply(m, clip)
        self.fill(m, tone, shade_d, light_d, shade, alpha)
        return m

    def fill(self, m, tone, shade_d=4.0, light_d=1.6, shade=True, alpha=255):
        if isinstance(tone, str):
            tone = Tone(tone)
        lx, ly = self.light
        self._paint(m, tone.base, alpha)
        if shade and shade_d > 0:
            sh = m.transform(m.size, Image.AFFINE, (1, 0, -lx * shade_d * self.ss, 0, 1, -ly * shade_d * self.ss))
            sm = ImageChops.subtract(m, sh)
            self._paint(sm, tone.shade, alpha)
        if shade and light_d > 0:
            li = m.transform(m.size, Image.AFFINE, (1, 0, lx * light_d * self.ss, 0, 1, ly * light_d * self.ss))
            lm = ImageChops.subtract(m, li)
            lm = lm.filter(ImageFilter.GaussianBlur(self.ss * 0.35))
            lm = ImageChops.multiply(lm, m)
            self._paint(lm, tone.light, alpha)

    def _paint(self, m, col, alpha=255):
        if alpha < 255:
            m = m.point(lambda v: v * alpha // 255)
        layer = Image.new("RGBA", m.size, col[:3] + (255,))
        layer.putalpha(ImageChops.multiply(m, Image.new("L", m.size, col[3])))
        self.img.alpha_composite(layer)

    def flat(self, draw_fn, col, alpha=255, blur=0.0):
        """Tô phẳng (mắt, vệt sáng, hiệu ứng) — không bóng."""
        m = self.mask()
        draw_fn(ImageDraw.Draw(m))
        if blur > 0:
            m = m.filter(ImageFilter.GaussianBlur(blur * self.ss))
        self._paint(m, hexc(col) if isinstance(col, str) else col, alpha)

    def glow(self, draw_fn, col, radius=6.0, alpha=160):
        m = self.mask()
        draw_fn(ImageDraw.Draw(m))
        m = m.filter(ImageFilter.GaussianBlur(radius * self.ss))
        self._paint(m, hexc(col) if isinstance(col, str) else col, alpha)

    # ---- ra ảnh: viền tối mềm quanh silhouette + thu nhỏ
    def render(self, outline="#1a1424", width=2.2, shadow=None):
        out = self.img
        if outline:
            a = out.getchannel("A").point(lambda v: 255 if v > 40 else 0)
            k = int(round(width * self.ss)) | 1
            grown = a.filter(ImageFilter.MaxFilter(k if k <= 31 else 31))
            if k > 31:
                for _ in range((k - 31) // 30 + 1):
                    grown = grown.filter(ImageFilter.MaxFilter(31))
            grown = grown.filter(ImageFilter.GaussianBlur(self.ss * 0.4))
            base = Image.new("RGBA", out.size, (0, 0, 0, 0))
            if shadow is not None:
                base.alpha_composite(shadow)
            ol = Image.new("RGBA", out.size, hexc(outline)[:3] + (255,))
            ol.putalpha(grown)
            base.alpha_composite(ol)
            base.alpha_composite(out)
            out = base
        return out.resize((self.w, self.h), Image.LANCZOS)


def rot(cx, cy, x, y, a):
    """Xoay (x, y) quanh (cx, cy) góc a (radian)."""
    dx, dy = x - cx, y - cy
    return (cx + dx * math.cos(a) - dy * math.sin(a), cy + dx * math.sin(a) + dy * math.cos(a))


def polar(o, length, ang_deg):
    """Điểm cách o một đoạn length theo góc (độ, 0 = xuống dưới, dương = về phía trước/phải)."""
    a = math.radians(ang_deg)
    return (o[0] + math.sin(a) * length, o[1] + math.cos(a) * length)


def bezier(p0, p1, p2, p3=None, n=16):
    pts = []
    for i in range(n + 1):
        t = i / n
        if p3 is None:
            x = (1 - t) ** 2 * p0[0] + 2 * (1 - t) * t * p1[0] + t * t * p2[0]
            y = (1 - t) ** 2 * p0[1] + 2 * (1 - t) * t * p1[1] + t * t * p2[1]
        else:
            x = (1 - t) ** 3 * p0[0] + 3 * (1 - t) ** 2 * t * p1[0] + 3 * (1 - t) * t * t * p2[0] + t ** 3 * p3[0]
            y = (1 - t) ** 3 * p0[1] + 3 * (1 - t) ** 2 * t * p1[1] + 3 * (1 - t) * t * t * p2[1] + t ** 3 * p3[1]
        pts.append((x, y))
    return pts


def sheet(frames_by_row, fw, fh):
    """Ghép các hàng frame (list[list[Image]]) thành sprite sheet."""
    cols = max(len(r) for r in frames_by_row)
    out = Image.new("RGBA", (cols * fw, len(frames_by_row) * fh), (0, 0, 0, 0))
    for ri, row in enumerate(frames_by_row):
        for ci, im in enumerate(row):
            out.alpha_composite(im, (ci * fw, ri * fh))
    return out
