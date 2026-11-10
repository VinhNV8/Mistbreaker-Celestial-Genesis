"""GN-4 E6 (docs/45 §9): ô lặp mặt vách đá cho viền bản đồ + thành hồ / hố dung nham. Ô 256×256 px lặp liền mạch
cả 2 chiều: 4 tầng đá (mỗi tầng 64 px) mép lượn, khối nứt dọc so le, mép trên mỗi khối sáng (nắng trên-trái), khe tối.
Gốc [0, 0] như mọi ô nền (fill_polygon lấy UV theo toạ độ thế giới)."""
import random

from PIL import Image, ImageDraw, ImageFilter

from vec import hexc

W = 256
SS = 2

# id: (nền, khe tối, mép sáng, đốm điểm xuyết, alpha đốm)
ROCKS = {
    "cliff-rock": ("#6e665c", "#3a342e", "#a39a8c", "#5a7a44", 90),
    "cliff-sand": ("#b88a56", "#7a5430", "#e0b884", "#c9a070", 0),
    "cliff-basalt": ("#3e383c", "#1c181c", "#6a6266", "#ff6a1a", 60),
    "cliff-ice": ("#8fb4cc", "#4e7490", "#d6ecf8", "#ffffff", 120),
    "cliff-void": ("#3a2e50", "#1a1428", "#6e5c98", "#b48cff", 80),
    "cliff-marble": ("#d8d0c2", "#9a9284", "#f6f0e6", "#8fd8b8", 70),
}


def cliff(base, crack, light, speck, speck_a, seed):
    rnd = random.Random(seed)
    S = W * SS
    img = Image.new("RGBA", (S, S), hexc(base))
    d = ImageDraw.Draw(img)
    layers = 4
    lh = W / layers
    for L in range(layers):
        y0 = L * lh
        # khối trong tầng: bề rộng ngẫu nhiên, tổng = W (liền mạch ngang)
        xs = [0.0]
        while xs[-1] < W - 40:
            xs.append(xs[-1] + rnd.uniform(34, 70))
        xs[-1] = W
        off = rnd.uniform(0, W)
        for i in range(len(xs) - 1):
            a, b = xs[i] + off, xs[i + 1] + off
            tone = rnd.uniform(-0.12, 0.1)
            col = hexc(base)
            col = tuple(max(0, min(255, int(c * (1 + tone)))) for c in col[:3]) + (255,)
            for ox in (-W, 0, W):
                xa, xb = a + ox, b + ox
                top = y0 + rnd.uniform(2, 6)
                bot = y0 + lh - rnd.uniform(2, 5)
                poly = [(xa + 3, top), (xb - 3, top + rnd.uniform(-2, 2)), (xb - 2, bot), (xa + 2, bot)]
                for oy in (-W, 0, W):
                    d.polygon([(x * SS, (y + oy) * SS) for x, y in poly], fill=col)
                    # mép trên sáng + mép trái sáng nhẹ (nắng trên-trái)
                    d.line([((xa + 4) * SS, (top + 2 + oy) * SS), ((xb - 4) * SS, (top + 2 + oy) * SS)], fill=hexc(light, 170), width=3 * SS)
                    d.line([((xa + 3) * SS, (top + 3 + oy) * SS), ((xa + 3) * SS, (bot - 4 + oy) * SS)], fill=hexc(light, 70), width=2 * SS)
                    # đáy khối tối (khe giữa tầng)
                    d.line([((xa + 2) * SS, (bot + oy) * SS), ((xb - 2) * SS, (bot + oy) * SS)], fill=hexc(crack, 220), width=3 * SS)
                    # vết nứt nhỏ
                    if rnd.random() < 0.5:
                        cx = rnd.uniform(xa + 8, xb - 8)
                        d.line([(cx * SS, (top + 8 + oy) * SS), ((cx + rnd.uniform(-6, 6)) * SS, (top + rnd.uniform(18, 40) + oy) * SS)],
                               fill=hexc(crack, 150), width=SS)
    if speck_a > 0:
        for _ in range(30):
            x, y = rnd.uniform(0, W), rnd.uniform(0, W)
            for ox in (-W, 0, W):
                for oy in (-W, 0, W):
                    d.ellipse([(x + ox - 4) * SS, (y + oy - 2) * SS, (x + ox + 4) * SS, (y + oy + 2) * SS], fill=hexc(speck, speck_a))
    img = img.filter(ImageFilter.GaussianBlur(0.5 * SS))
    return img.resize((W, W), Image.LANCZOS)


def build():
    """{id: (Image, origin)}"""
    return {k: (cliff(*v, seed=i * 7 + 3), [0, 0]) for i, (k, v) in enumerate(ROCKS.items())}


if __name__ == "__main__":
    import os
    res = build()
    prev = Image.new("RGBA", (len(res) * 270, 540), (40, 40, 40, 255))
    for i, (k, (im, o)) in enumerate(res.items()):
        for r in range(2):
            prev.alpha_composite(im, (i * 270, r * 256))
    out = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "_preview", "hd-cliffs.png")
    prev.save(out)
    print("ok", out)
