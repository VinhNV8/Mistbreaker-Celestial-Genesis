"""GIF động hướng D + vệt sáng chạy quanh viền ô theo chiều kim đồng hồ (docs/43, chờ duyệt)."""
import math, random, sys
import numpy as np
from PIL import Image, ImageDraw, ImageFilter
sys.path.insert(0, __file__.rsplit('\\', 1)[0].rsplit('/', 1)[0])
from enh_mock import (S, TC, ROOT, font, slot_bg, load_icon, mask_of, colored, blur, dilate, star, badge, sweep)

N = 36          # số khung
DUR = 55        # ms / khung  → vòng lặp ~2 giây
TIERS = [(0, 0), (4, 1), (7, 2), (10, 3), (13, 4), (15, 4)]
ITEMS = [('eq-sword-0-purple.png', 'purple'), ('eq-armor-1-orange.png', 'orange')]


def perimeter_point(u, inset=1.5, r=7):
    """Điểm trên viền ô bo góc, u ∈ [0,1), bắt đầu góc trên-trái, đi theo chiều kim đồng hồ."""
    a, b = inset, S - 1 - inset
    L = b - a
    seg = [L - 2 * r] * 4
    arc = math.pi * r / 2
    total = sum(seg) + 4 * arc
    d = (u % 1.0) * total
    # thứ tự: cạnh trên → góc TR → cạnh phải → góc BR → cạnh dưới → góc BL → cạnh trái → góc TL
    pieces = [
        ('l', (a + r, a), (b - r, a)), ('c', (b - r, a + r), -90), ('l', (b, a + r), (b, b - r)), ('c', (b - r, b - r), 0),
        ('l', (b - r, b), (a + r, b)), ('c', (a + r, b - r), 90), ('l', (a, b - r), (a, a + r)), ('c', (a + r, a + r), 180)]
    for p in pieces:
        ln = (L - 2 * r) if p[0] == 'l' else arc
        if d <= ln:
            k = d / ln
            if p[0] == 'l':
                return (p[1][0] + (p[2][0] - p[1][0]) * k, p[1][1] + (p[2][1] - p[1][1]) * k)
            ang = math.radians(p[2] + 90 * k)
            return (p[1][0] + r * math.cos(ang), p[1][1] + r * math.sin(ang))
        d -= ln
    return (a + r, a)


def border_runner(t, tier):
    """Vệt sáng như sao chổi chạy quanh viền; bậc 3+ có 2 vệt đối nhau."""
    lay = Image.new('RGBA', (S, S), (0, 0, 0, 0))
    if tier <= 0:
        return lay
    col = TC[tier]
    d = ImageDraw.Draw(lay)
    heads = [t] if tier < 3 else [t, t + 0.5]
    tail = 0.16 + 0.04 * tier
    for h in heads:
        steps = 48
        for i in range(steps):
            k = i / steps
            x, y = perimeter_point(h - k * tail)
            a = (1 - k) ** 1.6
            w = (2.6 + 0.4 * tier) * (1 - k * 0.55)
            c = tuple(int(col[j] + (255 - col[j]) * (1 - k) * 0.7) for j in range(3))
            d.ellipse([x - w, y - w, x + w, y + w], fill=c + (int(255 * a),))
    glow = lay.filter(ImageFilter.GaussianBlur(5))
    out = Image.alpha_composite(glow, glow)
    out = Image.alpha_composite(out, glow)
    out = Image.alpha_composite(out, lay)
    # đầu vệt: chớp sao nhỏ
    d2 = ImageDraw.Draw(out)
    for h in heads:
        x, y = perimeter_point(h)
        star(d2, x, y, 5 + tier, col, 255)
    return out


class Cell:
    def __init__(self, name, rar, plus, tier, seed):
        self.plus, self.tier, self.seed = plus, tier, seed
        self.bg = slot_bg(rar)
        self.ic = load_icon(name)
        self.m = mask_of(self.ic)
        m = self.m
        self.base = self.bg
        if 1 <= tier <= 3:
            col = TC[tier]
            if tier >= 3:
                halo = blur(dilate(m, 3), 13) * 0.55
                self.base = Image.alpha_composite(self.base, colored(halo * 1.4, col))
            edge = np.clip(dilate(m, 1 + tier // 2) - m, 0, 1)
            self.edge = np.maximum(edge, blur(edge, 2) * 1.5)
        rnd = random.Random(seed)
        pts = np.argwhere(m > 0.9)
        self.sparks = [(pts[rnd.randrange(len(pts))], rnd.random()) for _ in range(max(0, tier) + 1)]
        if tier >= 4:
            self.dil = dilate(m, 2)
            self.noise = blur(np.random.default_rng(seed).random((S * 2, S)).astype(np.float32), 2.2)

    def flames(self, t):
        tier, base = self.tier, self.dil
        h = 6 + tier * 7
        f = np.zeros_like(base)
        ph = t * 2 * math.pi
        for k in range(1, h):
            sh = np.zeros_like(base)
            sh[:-k] = base[k:]
            wob = (np.sin(np.arange(S) / 4.2 + k * 0.35 + self.seed + ph) * 0.5 + 0.5) ** 2
            f = np.maximum(f, sh * (1 - k / h) * wob[None, :])
        f = blur(f, 1.6)
        off = int(t * S) % S                      # nhiễu cuộn lên trên
        nz = self.noise[S - off: 2 * S - off] if off else self.noise[S:]
        return np.clip(f * (0.6 + nz * 1.3), 0, 1)

    def frame(self, t):
        tier, m, out = self.tier, self.m, self.base
        if tier == 0:
            return badge(Image.alpha_composite(out, self.ic), self.plus, tier)
        col = TC[tier]
        breathe = 0.85 + 0.15 * math.sin(t * 2 * math.pi)
        if tier <= 3:
            out = Image.alpha_composite(out, colored(self.edge * (0.45 + 0.15 * tier) * breathe, col))
            out = Image.alpha_composite(out, self.ic)
        else:
            f = self.flames(t)
            out = Image.alpha_composite(out, colored(blur(m, 5) * 0.6, col))
            out = Image.alpha_composite(out, colored(f * 0.95, col))
            out = Image.alpha_composite(out, colored(np.clip(f - 0.45, 0, 1) * 1.6, tuple(min(255, c + 90) for c in col)))
            out = Image.alpha_composite(out, self.ic)
            out = Image.alpha_composite(out, colored(f * (1 - m) * 0.35, col))
            fx = Image.new('RGBA', (S, S), (0, 0, 0, 0))
            d = ImageDraw.Draw(fx)
            rnd = random.Random(self.seed)
            for k in range(12):                     # tàn lửa bay lên
                x0, sp, ph = rnd.uniform(14, S - 14), rnd.uniform(0.6, 1.2), rnd.random()
                life = (t * sp + ph) % 1.0
                y = S * 0.7 - life * S * 0.65
                x = x0 + 4 * math.sin(life * 6 + k)
                r = 2.2 * (1 - life) + 0.6
                d.ellipse([x - r, y - r, x + r, y + r], fill=tuple(min(255, c + 60) for c in col) + (int(240 * (1 - life)),))
            out = Image.alpha_composite(out, fx)
        # vệt sáng lướt chéo: lướt trong 40% đầu vòng lặp
        sp = t / 0.4
        if sp < 1:
            out = Image.alpha_composite(out, colored(sweep(m, -20 + sp * (S * 2 + 40), 6 + tier, 0.25 + 0.08 * tier), (255, 255, 255)))
        # sao lấp lánh: mỗi sao nhấp nháy lệch pha
        fx = Image.new('RGBA', (S, S), (0, 0, 0, 0))
        d = ImageDraw.Draw(fx)
        for (y, x), ph in self.sparks[: tier + (1 if tier >= 3 else 0)]:
            a = max(0.0, math.sin((t + ph) * 2 * math.pi))
            if a > 0.05:
                star(d, x, y, (4 + tier) * (0.5 + 0.5 * a), col, int(255 * a))
                star(d, x, y, (2.5 + tier * 0.4) * a, (255, 255, 255), int(255 * a))
        out = Image.alpha_composite(out, fx.filter(ImageFilter.GaussianBlur(1.2)))
        out = Image.alpha_composite(out, fx)
        if self.plus >= 15:  # +15: viền ánh cầu vồng xoay
            ring = np.clip(dilate(m, 4) - dilate(m, 3), 0, 1)
            yy, xx = np.mgrid[0:S, 0:S]
            hue = np.arctan2(yy - S / 2, xx - S / 2) / (2 * np.pi) + 0.5 + t
            arr = np.zeros((S, S, 4), np.uint8)
            for j in range(3):
                arr[..., j] = (127 + 127 * np.sin(hue * 6.28 + j * 2.1)).astype(np.uint8)
            arr[..., 3] = (blur(ring, 1) * 255 * 1.4).clip(0, 255).astype(np.uint8)
            out = Image.alpha_composite(out, Image.fromarray(arr, 'RGBA'))
        # vệt sáng chạy quanh viền ô theo chiều kim đồng hồ (1 vòng / 2 giây; bậc 4 nhanh gấp đôi)
        out = Image.alpha_composite(out, border_runner(t * (2 if tier >= 4 else 1), tier))
        return badge(out, self.plus, tier)


def main():
    pad, top, LW = 14, 74, 150
    W = LW + len(TIERS) * (S + pad) + pad
    H = top + len(ITEMS) * (S + 14) + 10
    head = Image.new('RGBA', (W, H), (23, 18, 13, 255))
    d = ImageDraw.Draw(head)
    d.text((pad, 14), 'Hướng D + vệt sáng chạy quanh viền (chiều kim đồng hồ)', font=font(19), fill=(255, 220, 140))
    for j, (plus, tier) in enumerate(TIERS):
        d.text((LW + pad + j * (S + pad) + S / 2 - 16, 46), '+%d' % plus, font=font(16), fill=TC.get(tier, (230, 230, 230)))
    for r, lab in enumerate(['Vũ khí Tím', 'Giáp Cam']):
        d.text((pad, top + r * (S + 14) + S / 2 - 10), lab, font=font(15, True), fill=(220, 212, 196))
    cells = [[Cell(n, rar, p, t, seed=j + r * 7) for j, (p, t) in enumerate(TIERS)] for r, (n, rar) in enumerate(ITEMS)]
    frames = []
    for f in range(N):
        t = f / N
        im = head.copy()
        for r, row in enumerate(cells):
            for j, c in enumerate(row):
                im.alpha_composite(c.frame(t), (LW + pad + j * (S + pad), top + r * (S + 14)))
        frames.append(im.convert('RGB'))
    out = ROOT + 'docs/design/enhance/huong-d.gif'
    pal = frames[N // 4].quantize(colors=255, method=Image.Quantize.MEDIANCUT)
    q = [fr.quantize(palette=pal, dither=Image.Dither.NONE) for fr in frames]
    q[0].save(out, save_all=True, append_images=q[1:], duration=DUR, loop=0, optimize=False, disposal=1)
    # dải khung để kiểm tra
    strip = Image.new('RGB', (W, H * 3))
    for i, k in enumerate([0, 9, 22]):
        strip.paste(frames[k], (0, H * i))
    strip.save(ROOT + "docs/design/enhance/huong-d-khung.png")
    print(out)


if __name__ == '__main__':
    main()
