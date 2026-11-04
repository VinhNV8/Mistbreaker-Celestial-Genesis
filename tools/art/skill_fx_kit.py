"""FX-1 (docs/36): bộ nguyên tố vẽ VFX kỹ năng theo ngôn ngữ "cel-shaded 2D FX".

Rút ra từ board tham khảo (docs/36 §2): mỗi hình hiệu ứng gồm 4 dải màu cứng
(viền tối → màu bão hoà → màu sáng → lõi trắng) + một lớp glow cộng (additive)
đã lượng tử hoá thành 2–3 bậc để giữ chất pixel. Nhịp: vào nhanh → giữ khung va
chạm → tan chậm bằng khói/tia lửa.

Module này chỉ vẽ hiệu ứng. Sprite nhân vật / linh thú / quái được dán nguyên
bản từ `godot/assets/sprites` làm ngữ cảnh — không vẽ lại (xem keep-owner-art).
"""
import json
import math
import os
import random

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
ASSETS = os.path.join(ROOT, "godot", "assets")

W, H = 192, 112          # khung cảnh gốc (đơn vị toạ độ thiết kế)
SCALE = 3                # cỡ xuất = W×SCALE
HD = 6                   # Q182: vẽ ở W×HD rồi thu về W×SCALE (khử răng cưa) — bản HD; HD = 1 → bản pixel cũ
SQ = 0.55                # nén trục y cho hình nằm trên mặt đất (góc nhìn 3/4)
BANDS = (1.0, 0.72, 0.46, 0.2)


def hx(h):
    h = h.lstrip("#")
    return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4))


def pal(core, light, mid, deep):
    """Dải 4 màu: lõi, sáng, bão hoà (cũng là màu glow), viền tối."""
    return [hx(core), hx(light), hx(mid), hx(deep)]


def lerp(a, b, t):
    return a + (b - a) * t


def ease_out(t):
    t = max(0.0, min(1.0, t))
    return 1 - (1 - t) ** 3


def ease_in(t):
    t = max(0.0, min(1.0, t))
    return t * t * t


def seg(f, a, b):
    """Tiến độ 0..1 của khung f trong đoạn [a, b]; None nếu ngoài đoạn."""
    if f < a or f > b:
        return None
    return 0.0 if b == a else (f - a) / float(b - a)


_SPRITES = None


def _manifest():
    global _SPRITES
    if _SPRITES is None:
        with open(os.path.join(ASSETS, "art_manifest.json"), encoding="utf-8") as fh:
            _SPRITES = json.load(fh)["sprites"]
    return _SPRITES


_SHEETS = {}


def sprite_frame(sid, anim="idle", k=0):
    """Một khung sprite nguyên bản (RGBA) + gốc chân."""
    spec = _manifest()[sid]
    if sid not in _SHEETS:
        path = spec["path"].replace("res://assets/", "")
        _SHEETS[sid] = Image.open(os.path.join(ASSETS, path)).convert("RGBA")
    a = spec["anims"].get(anim) or spec["anims"]["idle"]
    k = min(k, a["frames"] - 1)
    w, h = spec["w"], spec["h"]
    return _SHEETS[sid].crop((k * w, a["row"] * h, (k + 1) * w, (a["row"] + 1) * h)), spec["origin"]


def _sc(xy, k):
    """Nhân toạ độ (list điểm, tuple phẳng hoặc hộp) với k."""
    if isinstance(xy, (list, tuple)) and xy and isinstance(xy[0], (list, tuple)):
        return [(x * k, y * k) for x, y in xy]
    return [v * k for v in xy]


class SDraw:
    """ImageDraw nhận toạ độ thiết kế, vẽ lên ảnh độ phân giải ×k (bản HD)."""

    def __init__(self, img, k):
        self.d = ImageDraw.Draw(img)
        self.k = k

    def _w(self, width):
        return max(1, int(round(width * self.k)))

    def polygon(self, pts, fill=None):
        self.d.polygon(_sc(list(pts), self.k), fill=fill)

    def line(self, xy, fill=None, width=1, joint=None):
        self.d.line(_sc(list(xy), self.k), fill=fill, width=self._w(width), joint=joint)

    def ellipse(self, box, fill=None, outline=None, width=1):
        self.d.ellipse(_sc(list(box), self.k), fill=fill, outline=outline, width=self._w(width))

    def rectangle(self, box, fill=None, outline=None, width=1):
        b = _sc(list(box), self.k)
        self.d.rectangle((b[0], b[1], max(b[0], b[2] + self.k - 1), max(b[1], b[3] + self.k - 1)), fill=fill, outline=outline)

    def point(self, xy, fill=None):
        x, y = xy[0] * self.k, xy[1] * self.k
        self.d.rectangle((x, y, x + self.k - 1, y + self.k - 1), fill=fill)

    def arc(self, box, start, end, fill=None, width=1):
        self.d.arc(_sc(list(box), self.k), start, end, fill=fill, width=self._w(width))

    def chord(self, box, start, end, fill=None):
        self.d.chord(_sc(list(box), self.k), start, end, fill=fill)


class Scene:
    """Một khung hình: nền → decal mặt đất → bóng/sprite → FX → glow cộng → chớp."""

    def __init__(self, ground=((22, 24, 36), (34, 36, 50)), seed=0, k=None, size=None, out=None):
        """size = (rộng, cao) khung thiết kế (mặc định W×H cảnh); out = cỡ ảnh xuất (mặc định W×SCALE).
        IC-1 (icon kỹ năng) dùng khung 64×64 → xuất 128×128."""
        self.k = k = HD if k is None else k
        self.W, self.H = size or (W, H)
        self.out = out or (self.W * SCALE, self.H * SCALE)
        Wd, Hd = self.W, self.H
        self.base = Image.new("RGBA", (Wd * k, Hd * k), ground[0] + (255,))
        d = SDraw(self.base, k)
        rnd = random.Random(seed)
        if size is None:
            for y in range(40, Hd):  # mặt đất có vân tối nhẹ
                t = (y - 40) / (Hd - 40)
                c = tuple(int(lerp(ground[0][i], ground[1][i], t)) for i in range(3))
                d.line((0, y, Wd, y), fill=c + (255,))
            for _ in range(70):
                x, y = rnd.randrange(Wd), rnd.randrange(44, Hd)
                d.point((x, y), fill=tuple(min(255, v + 10) for v in ground[1]) + (255,))
        self.ground = Image.new("RGBA", (Wd * k, Hd * k))
        self.fx = Image.new("RGBA", (Wd * k, Hd * k))
        self.back = Image.new("RGBA", (Wd * k, Hd * k))
        self.glow = np.zeros((Hd * k, Wd * k, 3), np.float32)
        self.sprites = []
        self.flash_col = None
        self.dim_a = 0.0

    # ---------- lớp tiện ích ----------
    def _layer(self, where):
        return {"ground": self.ground, "fx": self.fx, "back": self.back}[where]

    def draw(self, where="fx"):
        return SDraw(self._layer(where), self.k)

    def _glow_mask(self, draw_fn, col, amount, blur=2.6):
        if amount <= 0:
            return
        m = Image.new("L", (self.W * self.k, self.H * self.k))
        draw_fn(SDraw(m, self.k), 1.35, 255)
        m = m.filter(ImageFilter.GaussianBlur(blur * self.k))
        a = np.asarray(m, np.float32) / 255.0
        a = np.where(a > 0.5, 0.62, np.where(a > 0.22, 0.36, np.where(a > 0.06, 0.16, 0.0)))
        self.glow += a[..., None] * np.array(col, np.float32)[None, None, :] * amount

    def banded(self, draw_fn, p, where="fx", glow=1.0, alpha=255, bands=BANDS):
        """draw_fn(draw, scale, fill): vẽ hình ở độ dày/bán kính tỉ lệ `scale`."""
        self._glow_mask(draw_fn, p[2], glow * alpha / 255.0)
        d = self.draw(where)
        cols = [p[3], p[2], p[1], p[0]]
        for s, c in zip(bands, cols):
            if s > 0:
                draw_fn(d, s, c + (alpha,))

    # ---------- nguyên tố hình ----------
    def crescent(self, c, r, a0, a1, th, p, squash=1.0, glow=1.0, where="fx", head=0.65, alpha=255):
        """Vệt chém trăng khuyết: dày nhất ở `head` (0..1 dọc cung), nhọn hai đầu."""
        cx, cy = c
        n = max(8, int(abs(a1 - a0) * r / 2))

        def prof(u):
            if u < head:
                return math.sin(u / head * math.pi / 2) ** 0.8
            return math.cos((u - head) / (1 - head) * math.pi / 2) ** 0.6

        def fn(d, s, fill):
            out, inn = [], []
            for i in range(n + 1):
                u = i / n
                a = a0 + (a1 - a0) * u
                t = th * s * prof(u)
                ro, ri = r + t * 0.5, r - t * 0.5
                out.append((cx + math.cos(a) * ro, cy + math.sin(a) * ro * squash))
                inn.append((cx + math.cos(a) * ri, cy + math.sin(a) * ri * squash))
            d.polygon(out + inn[::-1], fill=fill)

        self.banded(fn, p, where, glow, alpha)

    def streak(self, p0, p1, w, p, glow=1.0, where="fx", alpha=255, tail=0.0):
        """Vệt thẳng: rộng `w` ở đầu p1, thon về đuôi p0 (rộng `tail`·w)."""
        dx, dy = p1[0] - p0[0], p1[1] - p0[1]
        L = math.hypot(dx, dy) or 1
        nx, ny = -dy / L, dx / L

        def fn(d, s, fill):
            hw, tw = w * s * 0.5, w * s * 0.5 * tail
            hx_ = p1[0] + dx / L * w * s * 0.6
            hy_ = p1[1] + dy / L * w * s * 0.6
            d.polygon([(p0[0] + nx * tw, p0[1] + ny * tw), (p1[0] + nx * hw, p1[1] + ny * hw), (hx_, hy_),
                       (p1[0] - nx * hw, p1[1] - ny * hw), (p0[0] - nx * tw, p0[1] - ny * tw)], fill=fill)

        self.banded(fn, p, where, glow, alpha)

    def star(self, c, r, n, p, rot=0.0, inner=0.32, glow=1.2, seed=0, where="fx", alpha=255, squash=1.0):
        """Sao va chạm nhiều gai (impact burst)."""
        rnd = random.Random(seed)
        jit = [rnd.uniform(0.7, 1.15) for _ in range(n)]

        def fn(d, s, fill):
            pts = []
            for i in range(n * 2):
                a = rot + i * math.pi / n
                rr = r * s * (jit[i // 2] if i % 2 == 0 else inner)
                pts.append((c[0] + math.cos(a) * rr, c[1] + math.sin(a) * rr * squash))
            d.polygon(pts, fill=fill)

        self.banded(fn, p, where, glow, alpha)

    def ring(self, c, r, w, p, squash=SQ, glow=1.0, where="ground", alpha=255):
        def fn(d, s, fill):
            ww = max(1, int(round(w * s)))
            d.ellipse((c[0] - r, c[1] - r * squash, c[0] + r, c[1] + r * squash), outline=fill, width=ww)

        self.banded(fn, p, where, glow, alpha, bands=(1.0, 0.66, 0.34, 0.0))

    def disc(self, c, r, p, squash=1.0, glow=1.0, where="fx", alpha=255):
        def fn(d, s, fill):
            rr = r * s
            d.ellipse((c[0] - rr, c[1] - rr * squash, c[0] + rr, c[1] + rr * squash), fill=fill)

        self.banded(fn, p, where, glow, alpha)

    def poly(self, pts, p, glow=0.8, where="fx", alpha=255):
        cx = sum(x for x, _ in pts) / len(pts)
        cy = sum(y for _, y in pts) / len(pts)

        def fn(d, s, fill):
            d.polygon([(cx + (x - cx) * s, cy + (y - cy) * s) for x, y in pts], fill=fill)

        self.banded(fn, p, where, glow, alpha, bands=(1.0, 0.78, 0.5, 0.22))

    def decal(self, c, r, p, rot=0.0, runes=8, alpha=200, inner=True):
        """Vòng trận / vòng cảnh báo trên mặt đất: 2 vòng + vạch + ký hiệu."""
        self.ring(c, r, 1.6, p, alpha=alpha, glow=0.6)
        if inner:
            self.ring(c, r * 0.72, 1.0, p, alpha=int(alpha * 0.8), glow=0.3)
        d = self.draw("ground")
        for i in range(runes):
            a = rot + i * math.tau / runes
            x = c[0] + math.cos(a) * r * 0.86
            y = c[1] + math.sin(a) * r * 0.86 * SQ
            d.rectangle((x - 1, y - 1, x + 1, y), fill=p[1] + (alpha,))
            d.point((x, y - 2), fill=p[0] + (alpha,))

    def bolt(self, p0, p1, p, seed=0, w=2.4, glow=1.4, branches=2, jag=6.0, where="fx", alpha=255):
        rnd = random.Random(seed)
        dx, dy = p1[0] - p0[0], p1[1] - p0[1]
        L = math.hypot(dx, dy) or 1
        n = max(3, int(L / 7))
        nx, ny = -dy / L, dx / L
        pts = [p0]
        for i in range(1, n):
            t = i / n
            o = rnd.uniform(-jag, jag)
            pts.append((p0[0] + dx * t + nx * o, p0[1] + dy * t + ny * o))
        pts.append(p1)
        brs = []
        for _ in range(branches):
            k = rnd.randrange(1, n)
            bx, by = pts[k]
            a = math.atan2(dy, dx) + rnd.choice((-1, 1)) * rnd.uniform(0.5, 1.1)
            ln = rnd.uniform(6, 14)
            brs.append([(bx, by), (bx + math.cos(a) * ln * 0.5 + rnd.uniform(-2, 2), by + math.sin(a) * ln * 0.5),
                        (bx + math.cos(a) * ln, by + math.sin(a) * ln)])

        def fn(d, s, fill):
            d.line(pts, fill=fill, width=max(1, int(round(w * s * 1.4))), joint="curve")
            for b in brs:
                d.line(b, fill=fill, width=max(1, int(round(w * s * 0.8))))

        self.banded(fn, p, where, glow, alpha, bands=(1.0, 0.7, 0.4, 0.0))

    def sparks(self, c, t, n, dist, p, seed=0, grav=0.0, up=False, size=1.5, spread=(0, math.tau), where="fx"):
        """Tia lửa bay ra rồi tắt; t = tiến độ 0..1."""
        if t is None:
            return
        rnd = random.Random(seed)
        d = self.draw(where)
        for _ in range(n):
            a = rnd.uniform(*spread)
            sp = rnd.uniform(0.45, 1.0) * dist
            e = ease_out(t)
            x = c[0] + math.cos(a) * sp * e
            y = c[1] + math.sin(a) * sp * e * (0.7 if not up else 1.0) + grav * t * t * 20
            if up:
                y = c[1] - abs(math.sin(a)) * sp * e
            if t > rnd.uniform(0.7, 1.0):
                continue
            col = p[0] if t < 0.3 else (p[1] if t < 0.6 else p[2])
            sz = max(0.5, size * (1 - t * 0.6))
            tx, ty = x - math.cos(a) * 3 * (1 - t), y - math.sin(a) * 2 * (1 - t)
            d.line((tx, ty, x, y), fill=p[2] + (200,), width=1)
            d.rectangle((x - sz / 2, y - sz / 2, x + sz / 2, y + sz / 2), fill=col + (255,))
        self.glow_dot(c, dist * 0.5 * (1 - t), p[2], 0.25 * (1 - t))

    def smoke(self, c, t, n, r, col=(120, 118, 130), seed=0, rise=10.0, spread=16.0):
        """Khói/bụi tan (pha dissipate): cụm tròn 2 tông, phình rồi teo."""
        if t is None:
            return
        rnd = random.Random(seed)
        d = self.draw("fx")
        dark = tuple(int(v * 0.62) for v in col)
        for _ in range(n):
            a = rnd.uniform(0, math.tau)
            ox, oy = math.cos(a) * spread * rnd.uniform(0.3, 1), math.sin(a) * spread * 0.5 * rnd.uniform(0.3, 1)
            e = ease_out(t)
            x, y = c[0] + ox * (0.5 + e), c[1] + oy * (0.5 + e) - rise * e
            rr = r * rnd.uniform(0.6, 1.1) * (math.sin(min(1, t * 1.25) * math.pi) * 0.9 + 0.1)
            if rr < 0.8:
                continue
            al = int(230 * (1 - t * 0.7))
            d.ellipse((x - rr, y - rr, x + rr, y + rr), fill=dark + (al,))
            d.ellipse((x - rr * 0.8 - 0.5, y - rr - 0.5, x + rr * 0.55, y + rr * 0.3), fill=col + (al,))

    def pillar(self, c, w, h, p, glow=1.3, alpha=255, where="fx"):
        """Cột sáng thẳng đứng (triệu hồi, giáng thánh)."""
        def fn(d, s, fill):
            ww = w * s * 0.5
            d.polygon([(c[0] - ww, c[1]), (c[0] - ww * 0.7, c[1] - h), (c[0] + ww * 0.7, c[1] - h), (c[0] + ww, c[1])], fill=fill)
            d.ellipse((c[0] - ww, c[1] - ww * SQ, c[0] + ww, c[1] + ww * SQ), fill=fill)

        self.banded(fn, p, where, glow, alpha)

    def dome(self, c, r, p, t=1.0, crack=0, alpha=170, hexes=True):
        """Bán cầu khiên: viền 3 dải + lưới lục giác mờ + vệt phản quang."""
        d = self.draw("fx")
        top = c[1] - r * t
        box = (c[0] - r, top - 2, c[0] + r, c[1] + r * SQ)
        self._glow_mask(lambda dd, s, f: dd.ellipse(box, outline=f, width=3), p[2], 0.9)
        d.chord(box, 180, 360, fill=p[2] + (int(alpha * 0.28),))
        if hexes:
            for yy in range(int(top) + 3, int(c[1]), 5):
                for xx in range(int(c[0] - r) + (yy // 5 % 2) * 3, int(c[0] + r), 6):
                    if ((xx - c[0]) / r) ** 2 + ((yy - c[1]) / max(1, r * t)) ** 2 < 0.9:
                        d.point((xx, yy), fill=p[1] + (int(alpha * 0.7),))
        d.arc(box, 180, 360, fill=p[3] + (255,), width=3)
        d.arc(box, 185, 355, fill=p[1] + (255,), width=1)
        d.arc((box[0] + 4, box[1] + 3, box[2] - 6, box[3]), 205, 245, fill=p[0] + (255,), width=2)
        rnd = random.Random(crack)
        for k in range(crack):
            a = rnd.uniform(math.pi * 1.1, math.pi * 1.9)
            x, y = c[0] + math.cos(a) * r * 0.9, c[1] + math.sin(a) * r * t * 0.9
            d.line((x, y, x + rnd.uniform(-5, 5), y + rnd.uniform(3, 7), x + rnd.uniform(-7, 7), y + rnd.uniform(6, 11)),
                   fill=p[0] + (255,), width=1)

    # ---------- biểu tượng / đạn ----------
    def sword(self, c, ang, ln, p, glow=1.0, alpha=255):
        ca, sa = math.cos(ang), math.sin(ang)
        nx, ny = -sa, ca
        tip = (c[0] + ca * ln * 0.6, c[1] + sa * ln * 0.6)
        base = (c[0] - ca * ln * 0.25, c[1] - sa * ln * 0.25)
        bw = max(1.5, ln * 0.09)
        self.poly([tip, (base[0] + nx * bw, base[1] + ny * bw), (base[0] - nx * bw, base[1] - ny * bw)], p, glow, alpha=alpha)
        d = self.draw("fx")
        g = bw * 2.2
        d.line((base[0] + nx * g, base[1] + ny * g, base[0] - nx * g, base[1] - ny * g), fill=p[3] + (alpha,), width=2)
        d.line((base[0], base[1], base[0] - ca * ln * 0.18, base[1] - sa * ln * 0.18), fill=p[3] + (alpha,), width=2)

    def arrow(self, c, ang, ln, p, glow=1.0, trail=0, alpha=255):
        ca, sa = math.cos(ang), math.sin(ang)
        if trail:
            self.streak((c[0] - ca * (ln + trail), c[1] - sa * (ln + trail)), (c[0] - ca * ln * 0.3, c[1] - sa * ln * 0.3), 3, p, glow * 0.7, alpha=int(alpha * 0.8))
        d = self.draw("fx")
        tail = (c[0] - ca * ln, c[1] - sa * ln)
        d.line((tail[0], tail[1], c[0], c[1]), fill=p[3] + (alpha,), width=1)
        nx, ny = -sa, ca
        d.polygon([(c[0] + ca * 3, c[1] + sa * 3), (c[0] + nx * 2, c[1] + ny * 2), (c[0] - nx * 2, c[1] - ny * 2)], fill=p[0] + (alpha,))
        d.line((tail[0], tail[1], tail[0] - ca * 2 + nx * 2, tail[1] - sa * 2 + ny * 2), fill=p[1] + (alpha,))
        d.line((tail[0], tail[1], tail[0] - ca * 2 - nx * 2, tail[1] - sa * 2 - ny * 2), fill=p[1] + (alpha,))
        self.glow_dot(c, 4, p[2], 0.6 * glow)

    def shard(self, c, ang, ln, p, glow=1.0, alpha=255):
        ca, sa = math.cos(ang), math.sin(ang)
        nx, ny = -sa, ca
        w = ln * 0.28
        self.poly([(c[0] + ca * ln * 0.6, c[1] + sa * ln * 0.6), (c[0] + nx * w, c[1] + ny * w),
                   (c[0] - ca * ln * 0.4, c[1] - sa * ln * 0.4), (c[0] - nx * w, c[1] - ny * w)], p, glow, alpha=alpha)

    def shield(self, c, s, p, glow=1.0, alpha=255):
        x, y = c
        self.poly([(x - s, y - s), (x + s, y - s), (x + s, y + s * 0.2), (x, y + s * 1.25), (x - s, y + s * 0.2)], p, glow, alpha=alpha)
        d = self.draw("fx")
        d.line((x, y - s * 0.7, x, y + s * 0.8), fill=p[0] + (alpha,), width=1)
        d.line((x - s * 0.6, y - s * 0.2, x + s * 0.6, y - s * 0.2), fill=p[0] + (alpha,), width=1)

    def orb(self, c, r, p, glow=1.4, alpha=255):
        self.disc(c, r, p, 1.0, glow, alpha=alpha)
        d = self.draw("fx")
        d.point((c[0] - r * 0.35, c[1] - r * 0.35), fill=(255, 255, 255, alpha))

    def hammer(self, c, ang, ln, p, glow=1.0, alpha=255):
        ca, sa = math.cos(ang), math.sin(ang)
        d = self.draw("fx")
        hd = (c[0] + ca * ln * 0.5, c[1] + sa * ln * 0.5)
        d.line((c[0] - ca * ln * 0.5, c[1] - sa * ln * 0.5, hd[0], hd[1]), fill=p[3] + (alpha,), width=2)
        nx, ny = -sa, ca
        hw, hl = ln * 0.32, ln * 0.18
        self.poly([(hd[0] + nx * hw - ca * hl, hd[1] + ny * hw - sa * hl), (hd[0] + nx * hw + ca * hl, hd[1] + ny * hw + sa * hl),
                   (hd[0] - nx * hw + ca * hl, hd[1] - ny * hw + sa * hl), (hd[0] - nx * hw - ca * hl, hd[1] - ny * hw - sa * hl)], p, glow, alpha=alpha)

    def glyph(self, c, kind, s, p, alpha=255):
        """Ký hiệu nhỏ trên đầu (buff/debuff): kiếm, mắt, khiên, sao choáng, độc, xích."""
        d = self.draw("fx")
        x, y = c
        f = p[0] + (alpha,)
        g = p[2] + (alpha,)
        if kind == "eye":
            d.ellipse((x - s, y - s * 0.5, x + s, y + s * 0.5), outline=g, width=1)
            d.ellipse((x - s * 0.35, y - s * 0.35, x + s * 0.35, y + s * 0.35), fill=f)
        elif kind == "stun":
            for k in range(3):
                a = k * math.tau / 3
                self.star((x + math.cos(a) * s, y + math.sin(a) * s * 0.4), 2.2, 4, p, glow=0.4)
        elif kind == "poison":
            d.polygon([(x, y - s), (x + s * 0.7, y + s * 0.3), (x, y + s * 0.8), (x - s * 0.7, y + s * 0.3)], fill=g)
            d.point((x - 1, y), fill=f)
        elif kind == "chain":
            for k in range(-2, 3):
                d.ellipse((x + k * 3 - 2, y - 1.5, x + k * 3 + 2, y + 1.5), outline=g)
        self.glow_dot(c, s * 1.5, p[2], 0.4)

    def glow_dot(self, c, r, col, amount):
        if r <= 0 or amount <= 0:
            return
        k = self.k
        yy, xx = np.ogrid[:self.H * k, :self.W * k]
        dd = ((xx / k - c[0]) ** 2 + ((yy / k - c[1]) / 0.8) ** 2) / (r * r)
        a = np.where(dd < 0.35, 0.6, np.where(dd < 1.0, 0.3, np.where(dd < 2.0, 0.12, 0.0)))
        self.glow += a[..., None].astype(np.float32) * np.array(col, np.float32) * amount

    # ---------- sprite & hậu kỳ ----------
    def put(self, sid, foot, anim="idle", k=0, flip=False, white=0.0, alpha=1.0, shake=0, scale=1.0):
        img, org = sprite_frame(sid, anim, k)
        scale *= self.k  # sprite gốc chỉ phóng to (Nearest), không vẽ lại
        img = img.resize((max(1, int(img.width * scale)), max(1, int(img.height * scale))), Image.NEAREST)
        org = (org[0] * scale, org[1] * scale)
        if flip:
            img = img.transpose(Image.FLIP_LEFT_RIGHT)
            org = (img.width - org[0], org[1])
        if white > 0:
            a = np.asarray(img, np.float32)
            a[..., :3] = a[..., :3] * (1 - white) + 255 * white
            img = Image.fromarray(a.astype(np.uint8), "RGBA")
        if alpha < 1:
            a = np.asarray(img, np.float32)
            a[..., 3] *= alpha
            img = Image.fromarray(a.astype(np.uint8), "RGBA")
        self.sprites.append((foot[1], img, (int(foot[0] * self.k - org[0] + shake * self.k), int(foot[1] * self.k - org[1]))))
        sh = self.draw("ground")
        rw = img.width / self.k * 0.3
        sh.ellipse((foot[0] - rw, foot[1] - 2, foot[0] + rw, foot[1] + 2), fill=(0, 0, 0, int(90 * alpha)))

    def flash(self, col, a):
        self.flash_col = (col, a)

    def dim(self, a):
        self.dim_a = max(self.dim_a, a)

    def render(self):
        img = self.base.copy()
        if self.dim_a > 0:
            img = Image.blend(img, Image.new("RGBA", img.size, (6, 6, 14, 255)), self.dim_a)
        img.alpha_composite(self.ground)
        img.alpha_composite(self.back)
        for _, spr, pos in sorted(self.sprites, key=lambda s: s[0]):
            img.alpha_composite(spr, pos)
        img.alpha_composite(self.fx)
        a = np.asarray(img.convert("RGB"), np.float32) + self.glow
        if self.flash_col:
            col, k = self.flash_col
            a = a + np.array(col, np.float32) * k * 0.32  # chớp kiểu cộng sáng, không phủ xám
        out = Image.fromarray(np.clip(a, 0, 255).astype(np.uint8), "RGB")
        if out.size != self.out:
            out = out.resize(self.out, Image.LANCZOS if out.size[0] > self.out[0] else Image.NEAREST)
        return out
