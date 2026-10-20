"""Thư viện vẽ pixel art bằng code (AR-01).

Mọi hình trong game được sinh từ các hàm ở đây để giữ đúng một phong cách:
dải màu 4 sắc (tối → sáng), ánh sáng từ trên trái, viền tối 1 px.
Toạ độ là số thực; điểm ảnh (x, y) phủ ô [x, x+1) × [y, y+1).
"""
import math
from PIL import Image

OUTLINE = (24, 18, 30, 255)
CLEAR = None


def hexc(h, a=255):
    h = h.lstrip("#")
    return (int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16), a)


def mix(c1, c2, t):
    return tuple(round(c1[i] + (c2[i] - c1[i]) * t) for i in range(4))


def ramp(*hexes):
    """Dải màu tối → sáng."""
    return [hexc(h) for h in hexes]


# Dải màu vật liệu dùng chung (tối → sáng)
R = {
    "skin": ramp("#8a5a44", "#c48a68", "#e8b38f", "#f7d3b5"),
    "hair_dark": ramp("#1e1a2a", "#352c45", "#4f4263", "#6b5b85"),
    "hair_brown": ramp("#3b2416", "#5e3a22", "#83542f", "#a8723f"),
    "cloth_blue": ramp("#1d2b52", "#2f4a84", "#4a6fb5", "#77a0dc"),
    "cloth_green": ramp("#1c3524", "#2c5236", "#43754b", "#67a065"),
    "cloth_red": ramp("#4a1620", "#7a2430", "#a83a3f", "#d66456"),
    "leather": ramp("#3a2416", "#5c3a22", "#80552f", "#a77442"),
    "steel": ramp("#3c4454", "#68748a", "#9ba8bc", "#dce6f2"),
    "gold": ramp("#6e4a12", "#a8741c", "#e0a630", "#ffe07a"),
    "wood": ramp("#3a2614", "#5a3c20", "#7d5630", "#a07446"),
    "leaf": ramp("#14301e", "#1f4a2c", "#2f6b3c", "#4f9452"),
    "leaf_light": ramp("#26502c", "#3b7a3c", "#5fa84c", "#94d06a"),
    "grass": ramp("#18301f", "#1f3b27", "#27492f", "#335a39"),
    "dirt": ramp("#3e3024", "#54412f", "#6b553d", "#86704f"),
    "stone": ramp("#33343d", "#545663", "#7b7e8c", "#a9adb9"),
    "fur_grey": ramp("#3a4250", "#5f6c7e", "#8fa3b8", "#c8d6e4"),
    "fur_void": ramp("#1c1430", "#352757", "#56428a", "#8270bd"),
    "mush_cap": ramp("#4e1640", "#7f2a6b", "#b04c98", "#dc86c6"),
    "mush_stem": ramp("#6e5f58", "#a8968a", "#d6c6b6", "#f3e8dc"),
    "wisp": ramp("#1f5a6a", "#3f9bb0", "#86d8e4", "#e2fbff"),
    "bark": ramp("#2e2016", "#4a3322", "#674a32", "#86664a"),
    "void": ramp("#140a22", "#2c1648", "#56308a", "#9b6ee0"),
    "blood": ramp("#4a0a14", "#86142a", "#c42840", "#ff5a6a"),
    "crystal": ramp("#173a6e", "#2b64b4", "#58a0f0", "#c4e4ff"),
    "fire": ramp("#7a1e0a", "#d0481a", "#ff9a3c", "#ffe08a"),
    "purple": ramp("#2c1442", "#52287a", "#8248b8", "#c28af0"),
    "white": ramp("#7d8494", "#b4bac8", "#e2e6ee", "#ffffff"),
}


class Canvas:
    def __init__(self, w, h):
        self.w, self.h = w, h
        self.px = [[CLEAR] * w for _ in range(h)]

    # ------------------------------------------------------------ cơ bản
    def set(self, x, y, c):
        x, y = int(math.floor(x)), int(math.floor(y))
        if c is not None and 0 <= x < self.w and 0 <= y < self.h:
            if c[3] < 255 and self.px[y][x] is not None:
                c = blend(self.px[y][x], c)
            self.px[y][x] = c

    def get(self, x, y):
        if 0 <= x < self.w and 0 <= y < self.h:
            return self.px[y][x]
        return None

    def rect(self, x0, y0, x1, y1, c):
        for y in range(int(math.floor(y0)), int(math.ceil(y1))):
            for x in range(int(math.floor(x0)), int(math.ceil(x1))):
                self.set(x, y, c)

    def clear(self, x0, y0, x1, y1):
        for y in range(int(math.floor(y0)), int(math.ceil(y1))):
            for x in range(int(math.floor(x0)), int(math.ceil(x1))):
                if 0 <= x < self.w and 0 <= y < self.h:
                    self.px[y][x] = None

    def ellipse(self, cx, cy, rx, ry, c):
        self.shade_ellipse(cx, cy, rx, ry, [c] * 4)

    def shade_ellipse(self, cx, cy, rx, ry, rmp, light=(-0.45, -0.55), bands=(0.35, 0.75, 1.15)):
        """Elip tô theo dải màu, sáng nhất ở phía nguồn sáng."""
        if rx <= 0 or ry <= 0:
            return
        for y in range(int(math.floor(cy - ry)), int(math.ceil(cy + ry)) + 1):
            for x in range(int(math.floor(cx - rx)), int(math.ceil(cx + rx)) + 1):
                dx, dy = (x + 0.5 - cx) / rx, (y + 0.5 - cy) / ry
                if dx * dx + dy * dy > 1.0:
                    continue
                d = math.hypot(dx - light[0], dy - light[1])
                idx = 3 if d < bands[0] else 2 if d < bands[1] else 1 if d < bands[2] else 0
                self.set(x, y, rmp[idx])

    def poly(self, pts, c):
        """Đa giác lồi hoặc lõm, tô theo quy tắc chẵn lẻ."""
        ys = [p[1] for p in pts]
        for y in range(int(math.floor(min(ys))), int(math.ceil(max(ys))) + 1):
            yc = y + 0.5
            xs = []
            n = len(pts)
            for i in range(n):
                (x1, y1), (x2, y2) = pts[i], pts[(i + 1) % n]
                if (y1 <= yc < y2) or (y2 <= yc < y1):
                    xs.append(x1 + (yc - y1) * (x2 - x1) / (y2 - y1))
            xs.sort()
            for i in range(0, len(xs) - 1, 2):
                for x in range(int(math.floor(xs[i] + 0.5)), int(math.floor(xs[i + 1] + 0.5))):
                    self.set(x, y, c)

    def shade_poly(self, pts, rmp):
        """Đa giác tô theo chiều cao: nửa trên sáng, đáy tối."""
        ys = [p[1] for p in pts]
        top, bot = min(ys), max(ys)
        tmp = Canvas(self.w, self.h)
        tmp.poly(pts, (255, 255, 255, 255))
        for y in range(self.h):
            for x in range(self.w):
                if tmp.px[y][x] is not None:
                    t = (y + 0.5 - top) / max(1e-6, bot - top)
                    idx = 3 if t < 0.2 else 2 if t < 0.55 else 1 if t < 0.85 else 0
                    self.set(x, y, rmp[idx])

    def line(self, x0, y0, x1, y1, c, width=1.0):
        steps = int(max(abs(x1 - x0), abs(y1 - y0)) * 2) + 1
        for i in range(steps + 1):
            t = i / steps
            x, y = x0 + (x1 - x0) * t, y0 + (y1 - y0) * t
            if width <= 1.0:
                self.set(x, y, c)
            else:
                r = width / 2.0
                self.ellipse(x, y, r, r, c)

    def arc(self, cx, cy, r, a0, a1, c, width=1.0):
        steps = int(abs(a1 - a0) * r * 2) + 2
        for i in range(steps + 1):
            a = a0 + (a1 - a0) * i / steps
            x, y = cx + math.cos(a) * r, cy + math.sin(a) * r
            if width <= 1.0:
                self.set(x, y, c)
            else:
                self.ellipse(x, y, width / 2.0, width / 2.0, c)

    # ------------------------------------------------------------ hậu kỳ
    def outline(self, color=OUTLINE, skip_alpha_below=200):
        """Viền tối 1 px quanh mọi điểm ảnh đặc (bỏ qua bóng, hào quang mờ)."""
        solid = [[p is not None and p[3] >= skip_alpha_below for p in row] for row in self.px]
        out = []
        for y in range(self.h):
            for x in range(self.w):
                if solid[y][x]:
                    continue
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    nx, ny = x + dx, y + dy
                    if 0 <= nx < self.w and 0 <= ny < self.h and solid[ny][nx]:
                        out.append((x, y))
                        break
        for x, y in out:
            self.px[y][x] = color if self.px[y][x] is None else blend(self.px[y][x], color)
        return self

    def tint(self, c, t):
        for y in range(self.h):
            for x in range(self.w):
                p = self.px[y][x]
                if p is not None:
                    self.px[y][x] = mix(p, (c[0], c[1], c[2], p[3]), t)
        return self

    def fade(self, a):
        for y in range(self.h):
            for x in range(self.w):
                p = self.px[y][x]
                if p is not None:
                    self.px[y][x] = (p[0], p[1], p[2], round(p[3] * a))
        return self

    def paste(self, other, ox=0, oy=0):
        for y in range(other.h):
            for x in range(other.w):
                p = other.px[y][x]
                if p is not None:
                    self.set(x + ox, y + oy, p)
        return self

    def to_image(self):
        img = Image.new("RGBA", (self.w, self.h), (0, 0, 0, 0))
        img.putdata([p if p is not None else (0, 0, 0, 0) for row in self.px for p in row])
        return img

    @staticmethod
    def from_image(img):
        img = img.convert("RGBA")
        c = Canvas(img.width, img.height)
        data = list(img.getdata())
        for y in range(img.height):
            for x in range(img.width):
                p = data[y * img.width + x]
                c.px[y][x] = p if p[3] > 0 else None
        return c

    def rotated(self, deg, pivot):
        """Xoay quanh điểm pivot (dùng cho hoạt ảnh ngã)."""
        img = self.to_image().rotate(deg, resample=Image.NEAREST, center=pivot)
        return Canvas.from_image(img)


def blend(dst, src):
    a = src[3] / 255.0
    out_a = a + dst[3] / 255.0 * (1 - a)
    if out_a <= 0:
        return None
    rgb = [round((src[i] * a + dst[i] * dst[3] / 255.0 * (1 - a)) / out_a) for i in range(3)]
    return (rgb[0], rgb[1], rgb[2], round(out_a * 255))


def shadow(cv, cx, cy, rx, ry, a=90):
    cv.ellipse(cx, cy, rx, ry, (0, 0, 0, a))


def glow(cv, cx, cy, r, c, a=70):
    """Hào quang mờ dần (không bị viền)."""
    for y in range(int(cy - r) - 1, int(cy + r) + 2):
        for x in range(int(cx - r) - 1, int(cx + r) + 2):
            d = math.hypot(x + 0.5 - cx, y + 0.5 - cy) / r
            if d < 1.0:
                cv.set(x, y, (c[0], c[1], c[2], round(a * (1 - d) ** 1.5)))


def sheet(rows):
    """rows: list[(tên, list[Canvas])] → (Image, {tên: hàng, số frame})."""
    fw, fh = rows[0][1][0].w, rows[0][1][0].h
    cols = max(len(fr) for _, fr in rows)
    img = Image.new("RGBA", (fw * cols, fh * len(rows)), (0, 0, 0, 0))
    meta = {}
    for r, (name, frames) in enumerate(rows):
        for i, f in enumerate(frames):
            img.alpha_composite(f.to_image(), (i * fw, r * fh))
        meta[name] = {"row": r, "frames": len(frames)}
    return img, meta
