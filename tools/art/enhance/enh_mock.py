"""Ảnh mẫu các hướng hiệu ứng cường hoá (docs/43) — chỉ để chủ dự án duyệt."""
import math, random
import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont, ImageChops

ROOT = 'D:/Projects/AI Project/Game/'
ICONS = ROOT + 'godot/assets/hd/icons/'
FONT = ROOT + 'godot/assets/fonts/BeVietnamPro-ExtraBold.ttf'
FONT_M = ROOT + 'godot/assets/fonts/BeVietnamPro-Medium.ttf'
S = 112
TIERS = [(0, 0), (4, 1), (7, 2), (10, 3), (13, 4), (15, 4)]
# bảng màu cường hoá mới: bạc → lam băng → vàng kim → huyết hồng (không trùng thang phẩm chất)
TC = {1: (205, 228, 255), 2: (90, 210, 255), 3: (255, 206, 80), 4: (255, 70, 96)}
RAR = {'purple': (179, 107, 255), 'orange': (255, 150, 40), 'blue': (74, 157, 248)}


def font(sz, med=False):
    return ImageFont.truetype(FONT_M if med else FONT, sz)


def slot_bg(rar):
    im = Image.new('RGBA', (S, S), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    rc = RAR[rar]
    d.rounded_rectangle([1, 1, S - 2, S - 2], 7, fill=(22, 18, 24, 255))
    g = Image.new('RGBA', (S, S), (0, 0, 0, 0))
    ImageDraw.Draw(g).ellipse([10, S * 0.55, S - 10, S + 30], fill=rc + (90,))
    g = g.filter(ImageFilter.GaussianBlur(14))
    im = Image.alpha_composite(im, g)
    d = ImageDraw.Draw(im)
    d.rounded_rectangle([1, 1, S - 2, S - 2], 7, outline=rc + (255,), width=3)
    return im


def load_icon(name):
    ic = Image.open(ICONS + name).convert('RGBA').resize((S - 12, S - 12), Image.LANCZOS)
    full = Image.new('RGBA', (S, S), (0, 0, 0, 0))
    full.paste(ic, (6, 6), ic)
    return full


def mask_of(icon):
    return np.asarray(icon)[..., 3].astype(np.float32) / 255.0


def colored(alpha, col):
    a = np.clip(alpha, 0, 1)
    arr = np.zeros((S, S, 4), np.uint8)
    arr[..., 0], arr[..., 1], arr[..., 2] = col
    arr[..., 3] = (a * 255).astype(np.uint8)
    return Image.fromarray(arr, 'RGBA')


def blur(a, r):
    im = Image.fromarray((np.clip(a, 0, 1) * 255).astype(np.uint8), 'L').filter(ImageFilter.GaussianBlur(r))
    return np.asarray(im).astype(np.float32) / 255.0


def dilate(a, r):
    im = Image.fromarray((a * 255).astype(np.uint8), 'L').filter(ImageFilter.MaxFilter(r * 2 + 1))
    return np.asarray(im).astype(np.float32) / 255.0


def star(d, x, y, r, col, a=255):
    d.polygon([(x, y - r), (x + r * .22, y - r * .22), (x + r, y), (x + r * .22, y + r * .22), (x, y + r),
               (x - r * .22, y + r * .22), (x - r, y), (x - r * .22, y - r * .22)], fill=col + (a,))
    d.ellipse([x - r * .25, y - r * .25, x + r * .25, y + r * .25], fill=(255, 255, 255, a))


def badge(im, plus, tier, style='plaque'):
    if plus <= 0:
        return im
    d = ImageDraw.Draw(im)
    col = TC.get(tier, (235, 235, 235))
    txt = '+%d' % plus
    f = font(19)
    w = d.textlength(txt, font=f)
    x1, y1 = S - 6, S - 6
    x0, y0 = x1 - w - 12, y1 - 24
    if style == 'plaque':
        d.rounded_rectangle([x0, y0, x1, y1], 6, fill=(14, 10, 8, 230), outline=col + (255,) if tier else (120, 110, 95, 255), width=2)
        d.text((x0 + 6, y0 + 1), txt, font=f, fill=col + (255,) if tier else (240, 240, 240, 255), stroke_width=0)
    else:
        d.text((x0 + 6, y0 + 1), txt, font=f, fill=col + (255,) if tier else (240, 240, 240, 255), stroke_width=3, stroke_fill=(0, 0, 0, 255))
    return im


def sweep(m, pos, width, strength):
    yy, xx = np.mgrid[0:S, 0:S].astype(np.float32)
    band = np.exp(-(((xx + yy) - pos) / width) ** 2)
    return band * m * strength


# ---------- Hướng A: Ánh kim trên chính món đồ ----------
def dir_a(name, rar, plus, tier, seed=1):
    bg = slot_bg(rar)
    ic = load_icon(name)
    m = mask_of(ic)
    if tier:
        col = TC[tier]
        if tier >= 3:  # quầng sáng sau món đồ
            halo = blur(dilate(m, 3), 7 + tier * 2) * (0.55 + 0.15 * (tier - 3))
            bg = Image.alpha_composite(bg, colored(halo * 1.4, col))
        edge = np.clip(dilate(m, 1 + tier // 2) - m, 0, 1)
        edge = np.maximum(edge, blur(edge, 2) * 1.5)
        out = Image.alpha_composite(bg, colored(edge * (0.45 + 0.15 * tier), col))
        out = Image.alpha_composite(out, ic)
        out = Image.alpha_composite(out, colored(sweep(m, S * 0.8, 6 + tier, 0.18 + 0.06 * tier), (255, 255, 255)))
        d = ImageDraw.Draw(out)
        rnd = random.Random(seed)
        pts = np.argwhere(m > 0.9)
        for k in range(tier - 1 if tier > 1 else 0):
            y, x = pts[rnd.randrange(len(pts))]
            star(d, x, y, 5 + tier, col, 235)
            star(d, x, y, 3 + tier * 0.5, (255, 255, 255), 255)
        if tier == 4 and plus >= 15:  # +15: viền ánh cầu vồng mảnh
            ring = np.clip(dilate(m, 4) - dilate(m, 3), 0, 1)
            yy, xx = np.mgrid[0:S, 0:S]
            hue = (np.arctan2(yy - S / 2, xx - S / 2) / (2 * np.pi) + 0.5)
            arr = np.zeros((S, S, 4), np.uint8)
            arr[..., 0] = (127 + 127 * np.sin(hue * 6.28)).astype(np.uint8)
            arr[..., 1] = (127 + 127 * np.sin(hue * 6.28 + 2.1)).astype(np.uint8)
            arr[..., 2] = (127 + 127 * np.sin(hue * 6.28 + 4.2)).astype(np.uint8)
            arr[..., 3] = (blur(ring, 1) * 255 * 1.6).clip(0, 255).astype(np.uint8)
            out = Image.alpha_composite(out, Image.fromarray(arr, 'RGBA'))
    else:
        out = Image.alpha_composite(bg, ic)
    return badge(out, plus, tier)


# ---------- Hướng B: Linh hoả bốc lên từ món đồ ----------
def flame_field(m, tier, seed):
    rng = np.random.default_rng(seed)
    base = dilate(m, 2)
    f = np.zeros_like(base)
    # kéo silhouette lên trên (lửa bốc), mỗi bước mờ dần + nhiễu theo cột
    h = 6 + tier * 7
    acc = base.copy()
    for k in range(1, h):
        sh = np.zeros_like(base)
        sh[:-k] = base[k:]
        wob = (np.sin(np.arange(S) / (3.0 + tier * 0.3) + k * 0.35 + seed) * 0.5 + 0.5) ** 2
        f = np.maximum(f, sh * (1 - k / h) * wob[None, :])
    f = blur(f, 1.6)
    noise = blur(rng.random((S, S)).astype(np.float32), 2.2)
    f = np.clip(f * (0.6 + noise * 1.3), 0, 1)
    return f


def dir_b(name, rar, plus, tier, seed=3):
    bg = slot_bg(rar)
    ic = load_icon(name)
    m = mask_of(ic)
    if tier:
        col = TC[tier]
        f = flame_field(m, tier, seed)
        outer = colored(f * (0.55 + 0.1 * tier), col)
        core = colored(np.clip(f - 0.45, 0, 1) * 1.6, tuple(min(255, c + 90) for c in col))
        out = Image.alpha_composite(bg, colored(blur(m, 5) * 0.6, col))
        out = Image.alpha_composite(out, outer)
        out = Image.alpha_composite(out, core)
        out = Image.alpha_composite(out, ic)
        # lớp lửa mỏng phía trước phần trên
        front = f * (1 - m) * 0.35
        out = Image.alpha_composite(out, colored(front, col))
        d = ImageDraw.Draw(out)
        rnd = random.Random(seed)
        for k in range(tier * 3):
            x = rnd.uniform(14, S - 14)
            y = rnd.uniform(6, S * 0.55)
            r = rnd.uniform(1.2, 2.4)
            d.ellipse([x - r, y - r, x + r, y + r], fill=tuple(min(255, c + 60) for c in col) + (230,))
    else:
        out = Image.alpha_composite(bg, ic)
    return badge(out, plus, tier)


def dir_d(name, rar, plus, tier, seed=0):
    return dir_b(name, rar, plus, tier, seed) if tier >= 4 else dir_a(name, rar, plus, tier, seed)


# ---------- Hướng C: Ấn bậc tối giản (đá khảm ở khung + hàng sao) ----------
def dir_c(name, rar, plus, tier, seed=0):
    bg = slot_bg(rar)
    ic = load_icon(name)
    out = Image.alpha_composite(bg, ic)
    d = ImageDraw.Draw(out)
    if plus > 0:
        # 5 ngôi sao trên đỉnh ô: mỗi 3 cấp = 1 sao đầy; màu sao theo bậc
        n_full = plus // 3
        part = plus % 3
        for i in range(5):
            x = S / 2 - 34 + i * 17
            y = 11
            if i < n_full:
                c = TC[min(4, max(1, i))] if i >= 1 else (220, 220, 220)
                star(d, x, y, 7.5, c, 255)
            elif i == n_full and part:
                star(d, x, y, 6, (110, 100, 90), 255)
                d.ellipse([x - 1.6, y - 1.6, x + 1.6, y + 1.6], fill=(240, 230, 200, 255))
            else:
                star(d, x, y, 5.5, (70, 62, 55), 255)
        if tier:
            col = TC[tier]
            for (cx, cy) in [(5, 5), (S - 6, 5), (5, S - 6), (S - 6, S - 6)][:max(2, tier)]:
                d.regular_polygon((cx, cy, 5), 4, rotation=45, fill=col + (255,), outline=(20, 14, 10, 255))
    return badge(out, plus, tier)


def sheet():
    rows = [
        ('A', 'Ánh kim trên món đồ', 'viền sáng theo dáng món + vệt sáng lướt chéo + sao lấp lánh; +10 có quầng; +15 viền cầu vồng', dir_a),
        ('B', 'Linh hoả', 'ngọn lửa linh khí bốc lên từ chính món đồ, cao dần theo bậc, tàn lửa bay', dir_b),
        ('D', 'A + B (em đề xuất)', 'ánh kim A cho +4…+12; từ +13 món đồ bốc linh hoả B — mốc cuối thật sự khác biệt', dir_d),
        ('C', 'Ấn bậc tối giản', 'không phủ hiệu ứng lên hình; 5 sao trên đỉnh ô (3 cấp = 1 sao) + đá khảm góc theo bậc', dir_c),
    ]
    items = [('eq-sword-0-purple.png', 'purple'), ('eq-armor-1-orange.png', 'orange')]
    LW = 250
    pad = 14
    W = LW + len(TIERS) * (S + pad) + pad
    H = 70 + len(rows) * (2 * (S + 10) + 44) + 20
    im = Image.new('RGBA', (W, H), (23, 18, 13, 255))
    d = ImageDraw.Draw(im)
    d.text((pad, 16), 'Hiệu ứng cường hoá — các hướng đề xuất (ảnh tĩnh; trong game có chuyển động)', font=font(20), fill=(255, 220, 140))
    for j, (plus, tier) in enumerate(TIERS):
        d.text((LW + pad + j * (S + pad) + S / 2 - 16, 48), '+%d' % plus, font=font(16), fill=TC.get(tier, (230, 230, 230)))
    y = 76
    for code, title, desc, fn in rows:
        d.text((pad, y + 4), 'Hướng %s' % code, font=font(22), fill=(255, 210, 120))
        d.text((pad, y + 34), title, font=font(17), fill=(240, 236, 226))
        # mô tả xuống dòng
        words, line, ly = desc.split(), '', y + 64
        for w in words:
            t = (line + ' ' + w).strip()
            if d.textlength(t, font=font(13, True)) > LW - 2 * pad:
                d.text((pad, ly), line, font=font(13, True), fill=(190, 182, 168)); ly += 19; line = w
            else:
                line = t
        d.text((pad, ly), line, font=font(13, True), fill=(190, 182, 168))
        for r, (name, rar) in enumerate(items):
            for j, (plus, tier) in enumerate(TIERS):
                cell = fn(name, rar, plus, tier, seed=j + r * 7)
                im.alpha_composite(cell, (LW + pad + j * (S + pad), y + r * (S + 10)))
        y += 2 * (S + 10) + 44
        d.line([(pad, y - 24), (W - pad, y - 24)], fill=(70, 58, 44), width=1)
    return im


if __name__ == '__main__':
    out = ROOT + 'docs/design/enhance/de-xuat-o-do.png'
    sheet().convert('RGB').save(out)
    print(out)
