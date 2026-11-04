"""UI-40 G0: cảnh Rừng Sương HD — nền cỏ / đất lặp liền mạch, cây tán tròn, thông, bụi, đá, cỏ cao (cel-shade)."""
import math
import random

from PIL import Image, ImageDraw, ImageFilter

from vec import Canvas, Tone, bezier, hexc, mix

PX = 4
OUTLINE = "#1d2a22"

LEAF = [Tone("#4f9a4a", "#2f6a3a", "#9bd36d"), Tone("#3f8a55", "#245f40", "#86c97a"), Tone("#5aa448", "#367233", "#b2df72")]
PINE = Tone("#2f7a52", "#1c5238", "#69b37c")
TRUNK = Tone("#7a5236", "#4f321f", "#a77a52")
ROCK = Tone("#9aa3ae", "#66707e", "#d3dae2")
BUSH = Tone("#4c9446", "#2c6233", "#94cf68")


def _tile(w, base, blobs, strokes, seed, flowers=0):
    """Ô lặp liền mạch w×w px: mảng màu mềm + nét cỏ, vẽ lặp ở 9 vị trí để nối mép."""
    rnd = random.Random(seed)
    ss = 2
    W = w * ss
    img = Image.new("RGBA", (W, W), hexc(base))
    layer = Image.new("RGBA", (W, W), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    for col, n, rmin, rmax, a in blobs:
        for _ in range(n):
            x, y = rnd.random() * W, rnd.random() * W
            rx, ry = rnd.uniform(rmin, rmax) * ss, rnd.uniform(rmin, rmax) * ss * 0.6
            for ox in (-W, 0, W):
                for oy in (-W, 0, W):
                    d.ellipse([x + ox - rx, y + oy - ry, x + ox + rx, y + oy + ry], fill=hexc(col, a))
    layer = layer.filter(ImageFilter.GaussianBlur(6 * ss))
    img.alpha_composite(layer)
    st = Image.new("RGBA", (W, W), (0, 0, 0, 0))
    d = ImageDraw.Draw(st)
    for col, n, ln, a in strokes:
        for _ in range(n):
            x, y = rnd.random() * W, rnd.random() * W
            lean = rnd.uniform(-0.5, 0.5)
            L = rnd.uniform(ln * 0.6, ln) * ss
            for ox in (-W, 0, W):
                for oy in (-W, 0, W):
                    d.polygon([(x + ox - 1.6 * ss, y + oy), (x + ox + lean * L, y + oy - L), (x + ox + 1.6 * ss, y + oy)], fill=hexc(col, a))
    for _ in range(flowers):
        x, y = rnd.random() * W, rnd.random() * W
        col = rnd.choice(["#fff4d6", "#ffd1e0", "#d8ecff"])
        for ox in (-W, 0, W):
            for oy in (-W, 0, W):
                for k in range(5):
                    a = math.tau * k / 5
                    d.ellipse([x + ox + math.cos(a) * 2.6 * ss - 1.8 * ss, y + oy + math.sin(a) * 2.6 * ss - 1.8 * ss,
                               x + ox + math.cos(a) * 2.6 * ss + 1.8 * ss, y + oy + math.sin(a) * 2.6 * ss + 1.8 * ss], fill=hexc(col, 230))
                d.ellipse([x + ox - 1.4 * ss, y + oy - 1.4 * ss, x + ox + 1.4 * ss, y + oy + 1.4 * ss], fill=hexc("#f2b632"))
    st = st.filter(ImageFilter.GaussianBlur(0.5 * ss))
    img.alpha_composite(st)
    return img.resize((w, w), Image.LANCZOS)


def grass(i):
    base = ["#4b7d3c", "#4f8240", "#477638"][i]
    return _tile(256, base,
                 [("#3b6a33", 14, 18, 40, 150), ("#69a04c", 12, 14, 34, 120), ("#2f5a2c", 6, 10, 24, 120)],
                 [("#2e5c2b", 90, 9, 170), ("#7fb85a", 60, 7, 150), ("#5c9445", 80, 8, 140)], seed=10 + i, flowers=3 + i)


def dirt():
    return _tile(256, "#8a6a48", [("#73563a", 14, 16, 36, 160), ("#a58460", 12, 12, 30, 130)],
                 [("#5f4630", 60, 4, 150), ("#b8976e", 40, 3, 150)], seed=5)


# ---------------------------------------------------------------- vật thể


def tree(variant):
    w, h = 160, 208
    c = Canvas(w, h)
    ox, oy = 80, 192
    rnd = random.Random(20 + variant)
    c.flat(lambda d: c.ellipse(d, ox + 6, oy, 46, 10), (10, 20, 12, 255), alpha=60, blur=2.5)
    leaf = LEAF[variant % 3]
    # thân + rễ
    c.part(lambda d: (c.poly(d, [(ox - 9, oy), (ox - 6, oy - 70), (ox + 6, oy - 70), (ox + 9, oy)]),
                      c.poly(d, [(ox - 9, oy), (ox - 18, oy + 2), (ox - 6, oy - 10)]),
                      c.poly(d, [(ox + 9, oy), (ox + 19, oy + 1), (ox + 6, oy - 12)]),
                      c.capsule(d, (ox, oy - 62), (ox - 22, oy - 92), 4, 2.5),
                      c.capsule(d, (ox + 2, oy - 66), (ox + 24, oy - 96), 4, 2.5)), TRUNK, shade_d=4)
    # tán: các cụm tròn chồng nhau
    clusters = [(-30, -100, 30), (30, -104, 30), (0, -128, 36), (-18, -150, 28), (20, -152, 26), (0, -170, 22)]
    if variant == 1:
        clusters = [(-34, -96, 26), (34, -98, 26), (-12, -124, 32), (16, -128, 32), (0, -158, 30)]
    if variant == 2:
        clusters = [(-26, -108, 34), (28, -106, 32), (0, -140, 40), (0, -172, 20)]
    def canopy(d):
        for x, y, r in clusters:
            c.circle(d, ox + x, oy + y, r)
            for k in range(7):
                a = math.tau * k / 7 + rnd.random()
                c.circle(d, ox + x + math.cos(a) * r * 0.8, oy + y + math.sin(a) * r * 0.8, r * 0.38)
    m = c.part(canopy, leaf, shade_d=12, light_d=5)
    # đốm sáng trong tán
    for x, y, r in clusters:
        c.flat(lambda d, x=x, y=y, r=r: c.ellipse(d, ox + x - r * 0.3, oy + y - r * 0.35, r * 0.35, r * 0.22), leaf.light, alpha=150, blur=1.5)
    if variant == 0:
        for k in range(6):
            fx, fy = rnd.uniform(-40, 40), rnd.uniform(-160, -96)
            c.flat(lambda d, fx=fx, fy=fy: c.circle(d, ox + fx, oy + fy, 3.2), "#f6c84a")
    return c.render(outline=OUTLINE, width=2.4), [ox, oy]


def pine():
    w, h = 160, 208
    c = Canvas(w, h)
    ox, oy = 80, 192
    c.flat(lambda d: c.ellipse(d, ox + 6, oy, 34, 8), (10, 20, 12, 255), alpha=60, blur=2.5)
    c.part(lambda d: c.poly(d, [(ox - 6, oy), (ox - 4, oy - 40), (ox + 4, oy - 40), (ox + 6, oy)]), TRUNK, shade_d=3)
    def layers(d):
        for i, (yb, half, ht) in enumerate([(-30, 50, 60), (-70, 42, 56), (-106, 32, 50), (-138, 22, 44)]):
            pts = [(ox - half, oy + yb)]
            for k in range(1, 6):
                t = k / 6
                pts.append((ox - half + 2 * half * t, oy + yb + (6 if k % 2 else -2)))
            pts.append((ox + half, oy + yb))
            pts.append((ox, oy + yb - ht))
            c.poly(d, pts)
    c.part(layers, PINE, shade_d=12, light_d=4)
    return c.render(outline=OUTLINE, width=2.4), [ox, oy]


def bush():
    c = Canvas(96, 72)
    ox, oy = 48, 60
    c.flat(lambda d: c.ellipse(d, ox + 3, oy + 2, 36, 6), (10, 20, 12, 255), alpha=80, blur=1.5)
    c.part(lambda d: (c.circle(d, ox - 18, oy - 16, 16), c.circle(d, ox + 16, oy - 16, 17), c.circle(d, ox, oy - 26, 20),
                      c.ellipse(d, ox, oy - 10, 34, 12)), BUSH, shade_d=7, light_d=3)
    for x, y in ((-8, -30), (14, -24), (-22, -18)):
        c.flat(lambda d, x=x, y=y: c.ellipse(d, ox + x, oy + y, 6, 3.5), BUSH.light, alpha=160, blur=1)
    return c.render(outline=OUTLINE, width=2.2), [ox, oy]


def rock(variant):
    c = Canvas(112, 80)
    ox, oy = 56, 64
    c.flat(lambda d: c.ellipse(d, ox + 4, oy + 2, 44, 7), (10, 20, 12, 255), alpha=80, blur=1.5)
    if variant == 0:
        pts = [(ox - 40, oy), (ox - 34, oy - 22), (ox - 14, oy - 40), (ox + 12, oy - 42), (ox + 34, oy - 26), (ox + 42, oy)]
    else:
        pts = [(ox - 34, oy), (ox - 30, oy - 30), (ox - 6, oy - 48), (ox + 20, oy - 34), (ox + 38, oy - 14), (ox + 36, oy)]
    c.part(lambda d: c.poly(d, pts), ROCK, shade_d=9, light_d=3)
    # mặt cắt sáng + rêu
    c.flat(lambda d: c.poly(d, [pts[1], pts[2], pts[3], (pts[3][0] - 6, pts[3][1] + 12), (pts[1][0] + 8, pts[1][1] + 6)]), ROCK.light, alpha=120)
    c.part(lambda d: c.ellipse(d, ox - 8, oy - 3, 22, 5), Tone("#5f9a48", "#3e6e33", "#8fc66a"), shade_d=1.5)
    return c.render(outline=OUTLINE, width=2.2), [ox, oy]


def tall_grass():
    c = Canvas(80, 72)
    ox, oy = 40, 60
    rnd = random.Random(3)
    def blades(d):
        for k in range(9):
            x = ox - 22 + k * 5.5
            h = rnd.uniform(28, 46)
            lean = rnd.uniform(-10, 10)
            c.ribbon(d, bezier((x, oy), (x + lean * 0.3, oy - h * 0.5), (x + lean, oy - h), n=8), [6.0 - 0.7 * i for i in range(9)])
    c.part(blades, Tone("#5ea94a", "#346f30", "#a3dc72"), shade_d=3, light_d=1.4)
    return c.render(outline=OUTLINE, width=1.8), [ox, oy]


def build():
    """{id: (Image, origin, logic w, logic h)}"""
    out = {}
    for i in range(3):
        out["tile-grass-%d" % i] = (grass(i), [0, 0])
    out["tile-dirt"] = (dirt(), [0, 0])
    for v in range(3):
        out["tree-%d" % v] = tree(v)
    out["tree-pine"] = pine()
    out["bush"] = bush()
    out["rock-0"] = rock(0)
    out["rock-1"] = rock(1)
    out["tall-grass"] = tall_grass()
    return out


if __name__ == "__main__":
    import os
    res = build()
    prev = Image.new("RGBA", (900, 520), hexc("#4b7d3c"))
    g = res["tile-grass-0"][0]
    for x in range(0, 900, 256):
        for y in range(0, 520, 256):
            prev.alpha_composite(g, (x, y))
    x = 10
    for k in ["tree-0", "tree-1", "tree-2", "tree-pine", "bush", "rock-0", "rock-1", "tall-grass"]:
        im, o = res[k]
        prev.alpha_composite(im, (x, 300 - o[1] + 100))
        x += im.size[0] - 10
    prev.save(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "_preview", "hd-forest.png"))
    print("ok")
