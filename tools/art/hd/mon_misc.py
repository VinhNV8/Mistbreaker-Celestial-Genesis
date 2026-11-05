"""MD-1 (docs/39): các dáng quái HD còn lại.

  spirit   — linh hồn / hồn ma / lửa / tinh thể băng / lốc xoáy / ngọc / tiểu quỷ   (form)
  mushroom — nấm có mặt, chân ngắn                                                (cap, spots, spore)
  treant   — người cây: thân gỗ có mặt, tay cành, tán lá, rễ chân                  (bark, leaf, eye, moss)
  bird     — chim / phượng hoàng (phoenix=True: đuôi lửa, mào, hào quang)           (body, wing, beak, eye)
  bug      — bọ / bọ hung / mảnh đá; scorpion=True thêm càng + đuôi độc            (shell, leg, horn, sting)
  serpent  — rắn hổ mang / đỉa / đầu thuỷ quái; heads=N → thuỷ quái nhiều đầu       (body, belly, hood, fins)
  frog     — ếch độc                                                               (skin, belly, spots)
  mirror / pylon / eye — vật thể (gương băng, neo / lồng / trụ phong ấn Hư Vô, mắt Hư Vô)
"""
import math

from mon_kit import Frame, Pen, attack_k, cyc, darker, tone
from vec import bezier, polar

DARK = "#140c1c"


def _g(s, k, d=None):
    return s.get(k, d)


def _dx(anim, i):
    if anim == "attack":
        return [-2.0, 4.0, 2.0][i]
    if anim == "hurt":
        return -3.0 + i * 1.5
    return 0.0


# ------------------------------------------------------------------ linh hồn
def spirit(spec, pose):
    anim, i, ph = pose
    k = attack_k(anim, i)
    form = _g(spec, "form", "wisp")
    bob = cyc(ph) * 2.4 + (cyc(ph, 0.25) * 1.5 if anim == "run" else 0)
    f = Frame(spec["L"], dx=_dx(anim, i), dy=-bob)
    body = tone(_g(spec, "body", "wisp"))
    glow = _g(spec, "glow", "#9de0e6")
    eye = _g(spec, "eye", "#ffffff")
    cy = -30.0
    sc = _g(spec, "scale", 1.0) * (1.12 if k > 0 else (0.94 if k < 0 else 1.0))
    f.shadow(12 * sc, 3.0, k=0.8)
    f.glow(lambda g: g.circle(0, cy, 20 * sc), glow, radius=7, alpha=120)
    lean = 4 if anim == "run" else (k * 4)
    if form in ("wisp", "ghost", "imp"):
        sw = cyc(ph) * 3

        def b(g):
            g.circle(lean * 0.3, cy - 2, 13 * sc)
            g.ribbon([(lean * 0.3 - 2, cy + 4), (-6 + sw * 0.4, cy + 14 * sc), (-10 + sw, cy + 22 * sc), (-14 + sw * 1.4, cy + 26 * sc)],
                     [24 * sc, 18 * sc, 9 * sc, 1.5])
            if form == "ghost":
                g.ribbon([(lean * 0.3 + 6, cy + 4), (6 - sw * 0.4, cy + 16 * sc), (2 - sw, cy + 24 * sc)], [12 * sc, 9 * sc, 1.2])
        f.part(b, body, sd=3.0, ld=1.6, alpha=_g(spec, "alpha", 235))
        if form == "imp":
            f.part(lambda g: (g.poly([(-6, cy - 12), (-10, cy - 24), (-1, cy - 13)]), g.poly([(4, cy - 13), (8, cy - 25), (10, cy - 10)])),
                   darker(body, 0.15), sd=0.6)
            f.part(lambda g: g.ribbon([(-12, cy + 2), (-22, cy - 4 + sw), (-24, cy - 12)], [2.2, 1.6, 0.4]), darker(body, 0.2), sd=0.4)
        if form == "ghost":
            f.flat(lambda g: g.ellipse(lean * 0.3 + 5, cy + 3, 4.5, 6 + k * 2), DARK, alpha=230)
        if _g(spec, "helm"):
            hx = lean * 0.3
            f.part(lambda g: (g.ellipse(hx, cy - 8, 13.5 * sc, 8 * sc), g.poly([(hx - 13 * sc, cy - 7), (hx + 13 * sc, cy - 7), (hx + 11 * sc, cy - 2), (hx - 12 * sc, cy - 2)])),
                   spec["helm"], sd=1.6)
            f.part(lambda g: g.ribbon([(hx - 4, cy - 15 * sc), (hx - 2, cy - 22 * sc), (hx - 9, cy - 27 * sc)], [3, 2.4, 0.6]), _g(spec, "plume", "heaven_gold"), sd=0.6)
        f.eyes([(lean * 0.3 + 1.5, cy - 4), (lean * 0.3 + 8, cy - 4.5)], eye, r=1.9 if form != "imp" else 1.5,
               slit=form == "imp")
        if form == "wisp":
            f.flat(lambda g: g.ribbon([(lean * 0.3 + 2, cy + 3), (lean * 0.3 + 5, cy + 4.5), (lean * 0.3 + 8, cy + 3)], [0.8, 1.4, 0.8]),
                   DARK, alpha=200)
    elif form == "flame":
        fl = cyc(ph)

        def b(g):
            g.circle(0, cy + 3, 12 * sc)
            g.poly([(-11 * sc, cy + 1), (-6 + fl * 2, cy - 22 * sc), (-2, cy - 8), (3 - fl * 2, cy - 28 * sc), (6, cy - 9),
                    (11 + fl, cy - 18 * sc), (12 * sc, cy + 2)])
        f.part(b, body, sd=2.4, ld=1.8)
        f.part(lambda g: (g.circle(1, cy + 5, 7 * sc), g.poly([(-5, cy + 3), (0 - fl, cy - 12 * sc), (5, cy + 3)])), "#ffe080", sd=0.8)
        f.glow(b, glow, radius=3, alpha=140, front=True)
        f.eyes([(-1.5, cy + 2), (5, cy + 1.5)], "#ffffff", r=1.6)
        f.flat(lambda g: g.ellipse(2, cy + 7, 2.6, 1.6 + max(k, 0) * 1.6), "#7a1a10")
    elif form == "crystal":
        def b(g):
            g.poly([(-4, cy + 14), (-11 * sc, cy - 2), (-3, cy - 22 * sc), (6, cy - 4), (2, cy + 14)])
            g.poly([(2, cy + 12), (4, cy - 14 * sc), (12 * sc, cy - 26 * sc), (14 * sc, cy - 4), (8, cy + 12)])
            g.poly([(-12 * sc, cy + 6), (-17 * sc, cy - 8), (-8, cy + 2)])
        f.part(b, body, sd=2.6, ld=2.0, alpha=225)
        f.flat(lambda g: (g.line([(-3, cy - 18), (-1, cy + 8)], 1.0), g.line([(10, cy - 20), (8, cy + 6)], 1.0)), "#ffffff", alpha=170)
        f.eyes([(0, cy - 2), (6, cy - 3)], eye, r=1.6)
    elif form == "tornado":
        def b(g):
            for q in range(6):
                t = q / 5
                w = (6 + 22 * t) * sc
                x = math.sin(math.tau * (ph + t * 0.6)) * 3 * (1 - t)
                g.ellipse(x, cy + 16 - t * 36 * sc, w / 2 + 2, 3.8 + t * 2)
        f.part(b, body, sd=2.0, ld=1.4, alpha=220)
        f.flat(lambda g: [g.ribbon([(-10 + q * 6, cy + 6 - q * 7), (q * 4, cy + 3 - q * 7), (10 - q * 2, cy + 6 - q * 7)], [0.8, 1.4, 0.8])
                          for q in range(4)], darker(body, 0.3).shade, alpha=170)
        f.eyes([(-1, cy - 6), (6, cy - 6.5)], eye, r=1.6, slit=True)
    elif form == "orb":
        f.part(lambda g: g.circle(0, cy, 14 * sc), body, sd=3.2, ld=2.0, alpha=230)
        f.flat(lambda g: g.ribbon(bezier((-9, cy + 4), (-3, cy - 12), (8, cy + 10), (10, cy - 6), 12), [1.6] * 13), "#ffffff", alpha=150)
        f.flat(lambda g: g.circle(-5, cy - 6, 3.2), "#ffffff", alpha=190)
        f.eyes([(3, cy + 1)], eye, r=2.4)
    # hạt sáng bay quanh
    f.glow(lambda g: [g.circle(math.cos(math.tau * (ph + q / 3)) * 16, cy + math.sin(math.tau * (ph + q / 3)) * 8 - 6, 1.6)
                      for q in range(3)], glow, radius=1.2, alpha=200, front=True)
    return f


# ------------------------------------------------------------------ nấm
def mushroom(spec, pose):
    anim, i, ph = pose
    k = attack_k(anim, i)
    sq = cyc(ph) * 0.05 + (0.12 if k < 0 else (-0.1 if k > 0 else 0)) + (abs(cyc(ph)) * 0.08 if anim == "run" else 0)
    f = Frame(spec["L"], dx=_dx(anim, i))
    cap = tone(_g(spec, "cap", "purple"))
    stem = tone(_g(spec, "stem", "bone"))
    f.shadow(17, 4)
    step = cyc(ph) * 3 if anim == "run" else 0
    for x, s_ in ((-5, -step), (6, step)):
        f.part(lambda g, x=x, s_=s_: g.ellipse(x + s_, -2.5, 5.0, 3.2), darker(stem, 0.15), sd=0.8)
    hgt = 18 * (1 - sq)
    f.part(lambda g: g.ellipse(0, -hgt / 2 - 3, 10 * (1 + sq), hgt / 2 + 2), stem, sd=2.6)
    # mặt trên thân
    f.flat(lambda g: [g.ellipse(x, -12 * (1 - sq), 1.5, 2.1) for x in (1.5, 6.5)], DARK)
    f.flat(lambda g: g.ellipse(4, -8 * (1 - sq), 2.4, 1.0 + max(k, 0) * 1.6), DARK, alpha=220)
    cy = -hgt - 8
    cw = 20 * (1 + sq * 0.6)

    def cp(g):
        g.ellipse(0, cy, cw, 12 * (1 - sq * 0.5))
        g.ellipse(0, cy + 6, cw * 0.95, 4.5)
    f.part(cp, cap, sd=3.4, ld=1.8)
    f.flat(lambda g: g.ellipse(0, cy + 8.5, cw * 0.8, 2.2), darker(cap, 0.4).shade, alpha=220)
    sp = _g(spec, "spots", "#fff2c8")
    f.flat(lambda g: [g.ellipse(x, cy + y, r, r * 0.8) for x, y, r in ((-9, -2, 3.2), (2, -7, 3.6), (11, -1, 2.6), (-2, 2, 2.0))], sp)
    if anim == "attack" and i >= 1 or anim == "idle" and i == 2:
        spc = _g(spec, "spore", "#c8ff7a")
        f.glow(lambda g: [g.circle(x, cy - 12 - y, 2.2) for x, y in ((-6, 2), (4, 6), (10, 1), (-1, 10))], spc, radius=1.4, alpha=210,
               front=True)
    return f


# ------------------------------------------------------------------ người cây
def treant(spec, pose):
    anim, i, ph = pose
    k = attack_k(anim, i)
    f = Frame(spec["L"], dx=_dx(anim, i))
    bark = tone(_g(spec, "bark", "bark"))
    leaf = tone(_g(spec, "leaf", "leaf"))
    eye = _g(spec, "eye", "#c8ff7a")
    bob = cyc(ph) * 0.8
    step = cyc(ph) * 4 if anim == "run" else 0
    lean = 5 if anim == "run" else k * 6
    f.shadow(20, 5)
    # rễ chân
    for x, s_ in ((-7, -step), (7, step)):
        f.part(lambda g, x=x, s_=s_: (g.ribbon([(x * 0.6, -14), (x + s_, -4), (x + s_ + 5, 0)], [7, 6, 2]),
                                      g.ribbon([(x * 0.6, -12), (x + s_ - 4, -2), (x + s_ - 7, 0)], [5, 4, 1.4])), darker(bark, 0.15), sd=1.2)
    # tay sau
    ab = (-12, -30 + bob)
    f.part(lambda g: g.ribbon([ab, (-20, -22 - k * 6), (-24, -14 - k * 10), (-27, -12 - k * 10)], [7, 5, 3, 1]), darker(bark, 0.2), sd=1.0)

    def trunk(g):
        g.poly([(-12, -10), (-13 + lean * 0.3, -38 + bob), (12 + lean * 0.5, -40 + bob), (12, -10)])
        g.ellipse(0, -10, 13, 5)
    bm = f.part(trunk, bark, sd=3.6, ld=1.4)
    f.flat(lambda g: [g.line([(-8 + q * 6, -12), (-9 + q * 6 + lean * 0.3, -36 + bob)], 1.1) for q in range(4)], bark.shade, alpha=200)
    if _g(spec, "moss"):
        f.part(lambda g: g.ellipse(-6, -14, 7, 3), spec["moss"], sd=0.6, clip=bm)
    # mặt: hốc mắt + miệng
    fx_, fy = 4 + lean * 0.4, -28 + bob
    f.flat(lambda g: [g.ellipse(fx_ + x, fy, 2.6, 2.0) for x in (-2, 5)], DARK)
    f.eyes([(fx_ - 2, fy), (fx_ + 5, fy)], eye, r=1.3)
    f.flat(lambda g: g.poly([(fx_ - 3, fy + 6), (fx_ + 7, fy + 5.5), (fx_ + 5, fy + 8.5 + max(k, 0) * 3), (fx_ - 1, fy + 9 + max(k, 0) * 3)]),
           DARK)
    # tán lá
    cw = _g(spec, "crown", 1.0)

    def crown(g):
        for x, y, r in ((-12, -44, 10), (0, -50, 12), (12, -45, 10), (-4, -40, 9), (8, -39, 8)):
            g.circle(x * cw + lean * 0.6, y + bob - (cw - 1) * 6, r * cw)
    f.part(crown, leaf, sd=3.6, ld=1.6)
    f.flat(lambda g: [g.circle((x + lean * 0.6) * cw, (y + bob) - (cw - 1) * 6, 1.6) for x, y in ((-8, -50), (6, -55), (14, -46), (-14, -42))],
           leaf.light, alpha=220)
    if _g(spec, "fruit"):
        f.fx(lambda g: [g.circle(x * cw + lean * 0.6, y + bob - (cw - 1) * 6, 1.8) for x, y in ((-10, -40), (4, -46), (12, -40))], spec["fruit"])
    # tay trước (cành)
    af = (12 + lean * 0.5, -32 + bob)
    tip = (24 + k * 6, -22 - k * 12)
    f.part(lambda g: (g.ribbon([af, (19, -26 - k * 6), tip], [7, 5, 2.5]), g.ribbon([(19, -26 - k * 6), (22, -34 - k * 8)], [2.6, 0.8]),
                      g.ribbon([tip, (tip[0] + 5, tip[1] + 1)], [2.2, 0.6]), g.ribbon([tip, (tip[0] + 3, tip[1] + 5)], [2.2, 0.6])), bark, sd=1.2)
    return f


# ------------------------------------------------------------------ chim / phượng hoàng
def bird(spec, pose):
    anim, i, ph = pose
    k = attack_k(anim, i)
    flap = cyc(ph) if anim != "attack" else [1.0, -1.0, 0.2][i]
    if anim == "hurt":
        flap = 0.6
    hover = 14 + cyc(ph) * 2.5
    f = Frame(spec["L"], dx=_dx(anim, i), dy=-hover + (6 if k > 0 else 0))
    body = tone(_g(spec, "body", "white"))
    wing = tone(_g(spec, "wing", "steel"))
    phoenix = _g(spec, "phoenix", False)
    glow = _g(spec, "glow", "#ff9a3c")
    # bóng dưới đất (không theo độ cao bay)
    f.back.flat(lambda d: Pen(f, d).ellipse(-f.dx, hover - 1, 13, 3), (12, 8, 22, 255), alpha=70, blur=1.6 * f.u)
    dive = 10 if k > 0 else 0
    cx, cy = 0, -26 + dive * 0.3
    if phoenix:
        f.glow(lambda g: g.circle(cx, cy, 24), glow, radius=8, alpha=120)

    def wingshape(g, back):
        s = 0.8 if back else 1.0
        rx, ry = cx - 2 - (3 if back else 0), cy - 4
        up = -flap * 16 * s
        tip = (rx - 20 * s, ry - 10 * s + up)
        g.poly([(rx + 4, ry), (rx - 6 * s, ry - 6 * s + up * 0.6), tip, (tip[0] - 2, tip[1] + 6), (rx - 16 * s, ry + 4 + up * 0.3),
                (rx - 12 * s, ry + 8), (rx - 6, ry + 7)])
        for q in range(4):
            fx_ = tip[0] + 3 + q * 4.2
            fy_ = tip[1] + 4 + q * (ry + 6 - tip[1]) / 4.5
            g.poly([(fx_ - 1.5, fy_ - 1.5), (fx_ - 4, fy_ + 6), (fx_ + 2, fy_ + 1)])
    f.part(lambda g: wingshape(g, True), darker(wing, 0.3), sd=2.0)
    # đuôi
    if phoenix:
        def tl(g):
            for q in range(3):
                g.ribbon(bezier((cx - 8, cy + 4), (cx - 16, cy + 6 + q * 3), (cx - 24 - q * 3, cy + 2 + q * 6 + flap * 2),
                                (cx - 32 - q * 2, cy + 10 + q * 7), 10), [5 * (1 - j / 11) + 0.6 for j in range(11)])
        f.part(tl, wing, sd=1.2)
        f.glow(tl, glow, radius=2.0, alpha=150, front=True)
    else:
        f.part(lambda g: g.poly([(cx - 8, cy + 2), (cx - 20, cy + 4), (cx - 21, cy + 9), (cx - 8, cy + 7)]), darker(wing, 0.1), sd=1.0)
    f.part(lambda g: (g.ellipse(cx, cy, 11, 8, -0.25 - dive * 0.02), g.circle(cx + 8, cy - 7, 6.4)), body, sd=2.6)
    f.part(lambda g: g.ellipse(cx + 3, cy + 3, 7, 4), tone(_g(spec, "belly", "white")), sd=0.8)
    # mỏ + mắt + mào
    bk = _g(spec, "beak", "#f0c050")
    f.part(lambda g: g.poly([(cx + 12.5, cy - 9), (cx + 19, cy - 6), (cx + 13, cy - 4.5)]), bk, sd=0.4)
    if phoenix or _g(spec, "crest"):
        f.part(lambda g: [g.poly([(cx + 4 + q * 2, cy - 12), (cx + q * 3 - 2, cy - 21 + q * 2), (cx + 7 + q * 2, cy - 11)]) for q in range(3)],
               _g(spec, "crest", wing), sd=0.6)
    f.eyes([(cx + 10.5, cy - 8)], _g(spec, "eye", "#ff5470"), r=1.4, slit=True)
    # chân quặp
    f.part(lambda g: (g.capsule((cx + 1, cy + 6), (cx + 2 + dive * 0.3, cy + 11 + dive * 0.4), 1.2),
                      g.capsule((cx + 4, cy + 6), (cx + 6 + dive * 0.3, cy + 11 + dive * 0.4), 1.2)), "#d8a040", sd=0.3)
    f.part(lambda g: wingshape(g, False), wing, sd=2.2)
    if phoenix:
        f.glow(lambda g: [g.circle(cx - 14 + q * 9 + math.sin(ph * 6 + q) * 2, cy + 14 + (q % 2) * 4, 1.4) for q in range(4)], glow,
               radius=1.2, alpha=200, front=True)
    return f


# ------------------------------------------------------------------ bọ / bọ cạp
def bug(spec, pose):
    anim, i, ph = pose
    k = attack_k(anim, i)
    f = Frame(spec["L"], dx=_dx(anim, i))
    shell = tone(_g(spec, "shell", "chitin"))
    legt = tone(_g(spec, "leg", "chitin"))
    eye = _g(spec, "eye", "#ffd23c")
    scorp = _g(spec, "scorpion", False)
    s = _g(spec, "scale", 1.0)
    bob = cyc(ph) * 0.6
    f.shadow(22 * s, 5 * s)
    cy = -9 * s + bob
    # chân
    def legs(back):
        for q in range(3):
            x = (-8 + q * 8) * s
            st = cyc(ph, q * 0.33 + (0.5 if back else 0)) * (4 if anim == "run" else 0.6)
            kn = (x + (2 if back else 4) * s + st * 0.4, cy - (4 if back else 2) * s)
            ft = (x + (7 if back else 9) * s + st, 0 if not back else -1.5)
            f.part(lambda g, x=x, kn=kn, ft=ft: (g.capsule((x, cy + 1), kn, 1.7 * s, 1.5 * s), g.capsule(kn, ft, 1.5 * s, 0.7 * s)),
                   darker(legt, 0.3) if back else legt, sd=0.5)
    legs(True)
    if scorp:
        tl = bezier((-12 * s, cy - 3 * s), (-26 * s, cy - 10 * s), (-24 * s - k * 2, cy - 34 * s - k * 3),
                    (-4 * s + k * 16, cy - 30 * s + k * 4), 7)
        f.part(lambda g: (g.ribbon(tl, [7 * s - q * 0.5 * s for q in range(len(tl))]),
                          [g.circle(x, y, (4.6 - q * 0.38) * s) for q, (x, y) in enumerate(tl)]), shell, sd=1.8)
        st_ = tl[-1]
        f.part(lambda g: g.poly([(st_[0] - 3 * s, st_[1] - 2 * s), (st_[0] + 7 * s, st_[1] + 3 * s), (st_[0] + 1 * s, st_[1] + 4 * s)]),
               "bone", sd=0.4)
        f.glow(lambda g: g.circle(st_[0] + 6 * s, st_[1] + 3 * s, 2.4 * s), _g(spec, "sting", "#8cff5a"), radius=1.6, alpha=220,
               front=True)
    # thân
    def sh(g):
        g.ellipse(-2 * s, cy - 4 * s, 15 * s, 10 * s)
        g.ellipse(11 * s, cy - 2 * s, 7 * s, 6 * s)
    bm = f.part(sh, shell, sd=3.0, ld=2.0)
    if not _g(spec, "rock"):
        f.flat(lambda g: g.ribbon([(-15 * s, cy - 5 * s), (-2 * s, cy - 13 * s), (6 * s, cy - 6 * s)], [1.0, 1.4, 1.0]), DARK, alpha=200)
        f.flat(lambda g: g.ellipse(-6 * s, cy - 9 * s, 5 * s, 2.2 * s), shell.light, alpha=200)
    else:
        f.flat(lambda g: (g.line([(-10 * s, cy - 10 * s), (-4 * s, cy - 4 * s), (2 * s, cy - 9 * s)], 1.2)), DARK, alpha=220)
        if _g(spec, "cracks"):
            f.glow(lambda g: g.line([(-12 * s, cy - 2 * s), (-4 * s, cy - 7 * s), (4 * s, cy - 3 * s)], 1.4), spec["cracks"], radius=1.4,
                   alpha=200, front=True)
    if _g(spec, "horn"):
        f.part(lambda g: g.ribbon([(14 * s, cy - 6 * s), (19 * s, cy - 13 * s), (17 * s, cy - 20 * s)], [4 * s, 2.6 * s, 0.4]), shell, sd=0.6)
    # càng / hàm
    if scorp:
        for back in (True, False):
            cl = (18 * s + (k * 8 if not back else k * 4), cy - (2 if back else -2) * s)
            tn = darker(shell, 0.3) if back else shell
            f.part(lambda g, cl=cl: (g.capsule((12 * s, cy), cl, 2.4 * s, 2.0 * s),
                                     g.ellipse(cl[0] + 4 * s, cl[1], 5.2 * s, 3.6 * s)), tn, sd=1.0)
            op = 2 + max(k, 0) * 3
            f.flat(lambda g, cl=cl: g.poly([(cl[0] + 3 * s, cl[1]), (cl[0] + 10 * s, cl[1] - op * s), (cl[0] + 10 * s, cl[1] + op * 0.3 * s)]),
                   DARK)
    else:
        op = 1.5 + max(k, 0) * 2.5
        f.part(lambda g: (g.ribbon([(16 * s, cy - 3 * s), (21 * s, cy - 4 * s - op), (23 * s, cy - 1 * s)], [2.2 * s, 1.6 * s, 0.4]),
                          g.ribbon([(16 * s, cy + 1 * s), (21 * s, cy + 2 * s + op), (23 * s, cy)], [2.2 * s, 1.6 * s, 0.4])),
               darker(shell, 0.2), sd=0.3)
    legs(False)
    f.eyes([(13 * s, cy - 4 * s), (16.5 * s, cy - 4.5 * s)], eye, r=1.3)
    return f


# ------------------------------------------------------------------ rắn / đỉa / thuỷ quái
def serpent(spec, pose):
    anim, i, ph = pose
    k = attack_k(anim, i)
    f = Frame(spec["L"], dx=_dx(anim, i))
    body = tone(_g(spec, "body", "sand_red"))
    belly = tone(_g(spec, "belly", "sand"))
    eye = _g(spec, "eye", "#ffd23c")
    heads = _g(spec, "heads", 1)
    leech = _g(spec, "leech", False)
    w = cyc(ph) * (3 if anim == "run" else 1.2)
    if heads == 1 and not leech:
        f.dy = 0
    f.shadow(24 if heads == 1 else 30, 5)
    if heads > 1:
        # thân chìm trong vòng nước + nhiều cổ
        f.part(lambda g: g.ellipse(0, -6, 26, 9), body, sd=3.0)
        f.flat(lambda g: g.ellipse(0, -2, 30, 5), "#5aa8c8", alpha=150)
        order = sorted(range(heads), key=lambda q: abs(q - (heads - 1) / 2), reverse=True)
        for q in order:
            t = q / max(1, heads - 1)
            bx = -22 + t * 44
            ang = -40 + t * 80
            sway = cyc(ph, q * 0.17) * 3
            top = (bx + math.sin(math.radians(ang)) * 18 + sway, -50 + abs(t - 0.5) * 24 - (k * 6 if q == heads // 2 else 0))
            nk = bezier((bx * 0.6, -8), (bx * 0.8, -20), (top[0] - 4, top[1] + 10), top, 10)
            dk = 0.25 * abs(t - 0.5) * 2
            f.part(lambda g, nk=nk: g.ribbon(nk, [9 - j * 0.35 for j in range(11)]), darker(body, dk), sd=1.6)
            _snake_head(f, top, body if dk < 0.1 else darker(body, dk), belly, eye, k if q == heads // 2 else 0, spec, s=1.0)
        return f
    if not leech:
        # rắn hổ mang: 2 vòng cuộn dưới đất + cổ ngẩng cao + mang bành
        f.part(lambda g: g.ribbon(bezier((-8, -4), (-22, -3), (-28 + w, -8), (-34 + w * 1.5, -4), 10), [10 - j * 0.9 for j in range(11)]),
               darker(body, 0.15), sd=1.4)
        f.part(lambda g: g.ellipse(-3, -6, 17, 6.5), darker(body, 0.1), sd=2.4)
        f.part(lambda g: g.ellipse(-1, -12, 13, 5.5), body, sd=2.2)
        f.flat(lambda g: [g.ellipse(x, y, 2.2, 1.4) for x, y in ((-12, -7), (-4, -4), (5, -6), (-8, -13), (1, -15))], body.shade, alpha=200)
        lean = k * 7 + (2 if anim == "run" else 0)
        top = (12 + lean, -38 + cyc(ph) * 1.2 + max(k, 0) * 6)
        nk = bezier((4, -13), (14, -18), (4 + lean * 0.5, -30), top, 12)
        f.part(lambda g: g.ribbon(nk, [11 - j * 0.3 for j in range(13)]), body, sd=2.0, ld=1.4)
        f.flat(lambda g: g.ribbon([(x + 2.5, y) for x, y in nk[2:]], [4.2 - j * 0.1 for j in range(11)]), belly.base, alpha=230)
        f.flat(lambda g: [g.line([(x, y), (x + 4.5, y)], 0.6) for x, y in nk[3::2]], belly.shade, alpha=200)
        _snake_head(f, top, body, belly, eye, k, dict(spec, hood=_g(spec, "hood", True)), s=1.25)
        return f
    rise = 0
    pts = bezier((-26, -5 + w * 0.3), (-14, -1 - w), (-2, -12 + w), (8 + k * 6, -14 - rise), 16)
    if leech:
        pts = bezier((-22, -6 + w * 0.5), (-10, -12 - w), (4, -6 + w), (16 + k * 6, -10 - k * 3), 16)
    widths = [3 + 9 * math.sin(math.pi * min(1, (j + 2) / 15)) for j in range(17)] if not leech else \
        [5 + 9 * math.sin(math.pi * (j / 16) * 0.9 + 0.15) for j in range(17)]
    bm = f.part(lambda g: g.ribbon(pts, widths), body, sd=2.8, ld=1.6)
    f.flat(lambda g: g.ribbon([(x, y + wd * 0.32) for (x, y), wd in zip(pts, widths)], [wd * 0.32 for wd in widths]), belly.base, alpha=220)
    f.flat(lambda g: [g.ellipse(x, y - wd * 0.15, wd * 0.18, wd * 0.12) for j, ((x, y), wd) in enumerate(zip(pts, widths)) if j % 3 == 1],
           body.shade, alpha=200)
    if leech:
        hd = pts[-1]
        op = 2.2 + max(k, 0) * 2
        f.part(lambda g: g.circle(hd[0] + 2, hd[1], 6.5), body, sd=1.4)
        f.flat(lambda g: g.circle(hd[0] + 5, hd[1] + 0.5, op), DARK)
        f.flat(lambda g: [g.circle(hd[0] + 5 + math.cos(a) * op * 0.7, hd[1] + 0.5 + math.sin(a) * op * 0.7, 0.5)
                          for a in [q * math.tau / 6 for q in range(6)]], "#ffd8d8")
        f.eyes([(hd[0] - 1, hd[1] - 4.5)], eye, r=1.0)
        return f


def _snake_head(f, p, body, belly, eye, k, spec, s=1.0):
    x, y = p
    if _g(spec, "hood"):
        f.part(lambda g: g.ellipse(x - 3 * s, y + 6 * s, 8.5 * s, 11 * s), darker(body, 0.1), sd=1.6)
        f.flat(lambda g: (g.ellipse(x - 5 * s, y + 4 * s, 2.4 * s, 2.0 * s), g.ellipse(x - 1.5 * s, y + 3.6 * s, 2.4 * s, 2.0 * s)),
               _g(spec, "hood_mark", "#1c1726"), alpha=200)
    if _g(spec, "fins"):
        f.part(lambda g: g.poly([(x - 4 * s, y - 2 * s), (x - 12 * s, y - 10 * s), (x - 9 * s, y), (x - 13 * s, y + 4 * s), (x - 3 * s, y + 3 * s)]),
               spec["fins"], sd=0.8)
    op = max(k, 0) * 4 * s
    if op > 0:
        f.flat(lambda g: g.poly([(x + 2 * s, y + 1 * s), (x + 12 * s, y + 1 * s + op * 0.3), (x + 10 * s, y + 3 * s + op), (x + 2 * s, y + 3 * s)]),
               "#5a1f2e")
        f.flat(lambda g: g.poly([(x + 8 * s, y + 1.5 * s), (x + 8.8 * s, y + 4 * s), (x + 9.6 * s, y + 1.5 * s)]), "#ffffff")
    f.part(lambda g: (g.ellipse(x + 2 * s, y - 1 * s, 7.6 * s, 5.2 * s), g.capsule((x + 3 * s, y), (x + 10 * s, y + 0.6 * s), 3.6 * s, 2.6 * s)),
           body, sd=1.6)
    f.eyes([(x + 4.5 * s, y - 2.6 * s)], eye, r=1.4 * s, slit=True)
    if k > 0:
        f.fx(lambda g: g.ribbon([(x + 11 * s, y + 1 * s), (x + 15 * s, y + 0.5 * s), (x + 16 * s, y - 1 * s)], [0.9, 0.7, 0.3]), "#ff4a6a")


# ------------------------------------------------------------------ ếch
def frog(spec, pose):
    anim, i, ph = pose
    k = attack_k(anim, i)
    hop = max(0.0, cyc(ph)) * 7 if anim == "run" else 0
    f = Frame(spec["L"], dx=_dx(anim, i), dy=-hop)
    skin = tone(_g(spec, "skin", "toad"))
    belly = tone(_g(spec, "belly", "sand"))
    f.shadow(17, 4)
    sq = cyc(ph) * 0.04 + (0.1 if k < 0 else 0)
    f.part(lambda g: g.ellipse(-9, -5, 8, 6), darker(skin, 0.2), sd=1.4)  # đùi sau
    f.part(lambda g: (g.ellipse(-1, -11, 15 * (1 + sq), 10 * (1 - sq), -0.18), g.circle(9, -16, 8.5)), skin, sd=3.0, ld=1.6)
    f.part(lambda g: g.ellipse(4, -7, 9, 5), belly, sd=0.8)
    # túi hơi cổ
    sac = 1.0 + 0.25 * max(0, cyc(ph)) + (0.4 if k < 0 else 0)
    f.part(lambda g: g.circle(13, -9, 4.0 * sac), "#f6d080" if not _g(spec, "sac") else spec["sac"], sd=0.6)
    f.part(lambda g: g.ellipse(-8, -2, 7, 3), skin, sd=0.8)
    f.part(lambda g: g.ellipse(9, -2, 5, 2.6), skin, sd=0.8)
    sp = _g(spec, "spots", "#2a4a8a")
    f.flat(lambda g: [g.ellipse(x, y, r, r * 0.8) for x, y, r in ((-8, -15, 2.6), (-2, -18, 2.0), (-12, -9, 1.8), (2, -12, 1.4))], sp, alpha=230)
    # mắt lồi
    for x, tn in ((6, darker(skin, 0.2)), (12, skin)):
        f.part(lambda g, x=x, tn=tn: g.circle(x, -24, 4.2), tn, sd=0.8)
    f.eyes([(7, -24.5), (13, -24.5)], _g(spec, "eye", "#ffd23c"), r=1.8, slit=True)
    f.flat(lambda g: g.ribbon([(11, -13), (15, -12), (18, -14)], [1.0, 1.2, 0.8]), DARK, alpha=220)
    if anim == "attack" and i == 1:
        f.part(lambda g: g.ribbon([(17, -13), (26, -13), (34, -14)], [2.4, 2.0, 1.6]), "pink", sd=0.4)
        f.part(lambda g: g.circle(35, -14, 2.8), "pink", sd=0.4)
    return f


# ------------------------------------------------------------------ vật thể
def mirror(spec, pose):
    anim, i, ph = pose
    k = attack_k(anim, i)
    f = Frame(spec["L"], dx=_dx(anim, i) * 0.3)
    frame_t = tone(_g(spec, "frame", "ice"))
    f.shadow(16, 4)
    f.glow(lambda g: g.ellipse(0, -30, 18, 26), "#8ad8ff", radius=6, alpha=90 + int(30 * cyc(ph)))
    f.part(lambda g: (g.ellipse(0, -30, 14, 24), g.poly([(-8, -4), (8, -4), (12, 0), (-12, 0)])), frame_t, sd=2.4)
    f.part(lambda g: g.ellipse(0, -30, 10, 19.5), "#2a4a7a", sd=0.0)
    f.flat(lambda g: g.ellipse(-1, -31, 9, 18), "#5a8ac0", alpha=200)
    f.flat(lambda g: (g.ribbon([(-6, -42), (-1, -38), (3, -22)], [1.6, 2.4, 1.0]), g.ribbon([(2, -46), (6, -36)], [1.0, 0.6])), "#e6f6ff",
           alpha=200 + int(40 * max(0, k)))
    for x, y, h in ((-14, -14, 14), (13, -12, 12), (-12, -48, 9), (11, -50, 11), (0, -56, 10)):
        f.part(lambda g, x=x, y=y, h=h: g.poly([(x - 3, y + 2), (x, y - h), (x + 3, y + 2)]), "ice", sd=0.6)
    if k > 0:
        f.glow(lambda g: g.ellipse(0, -30, 10, 19), "#ffffff", radius=3, alpha=170, front=True)
    return f


def pylon(spec, pose):
    anim, i, ph = pose
    kind = _g(spec, "kind", "anchor")
    f = Frame(spec["L"])
    stone = tone(_g(spec, "stone", "abyss"))
    rune = _g(spec, "rune", "#c080ff")
    pulse = 0.5 + 0.5 * cyc(ph)
    f.shadow(17, 4.2)
    f.glow(lambda g: g.ellipse(0, -2, 22, 6), rune, radius=3, alpha=90 + int(50 * pulse))
    if kind == "cage":
        f.part(lambda g: g.ellipse(0, -4, 17, 5), stone, sd=1.4)
        f.part(lambda g: g.ellipse(0, -52, 15, 5), stone, sd=1.4)
        f.glow(lambda g: g.circle(0, -28, 9), rune, radius=4, alpha=150 + int(60 * pulse))
        f.fx(lambda g: g.circle(0, -28, 4.5), "#ffffff", alpha=200)
        f.part(lambda g: [g.capsule((x, -6), (x * 0.9, -50), 1.6) for x in (-14, -7, 0, 7, 14)], darker(stone, 0.0), sd=0.6)
    elif kind == "seal":
        f.part(lambda g: g.poly([(-12, 0), (-10, -54), (0, -60), (10, -54), (12, 0)]), _g(spec, "stone2", "marble"), sd=3.0)
        f.flat(lambda g: [g.line([(-6, -12 - q * 12), (6, -16 - q * 12)], 1.6) for q in range(4)], rune, alpha=150 + int(100 * pulse))
        f.glow(lambda g: [g.line([(-6, -12 - q * 12), (6, -16 - q * 12)], 1.6) for q in range(4)], rune, radius=1.6, alpha=160, front=True)
        f.part(lambda g: g.ribbon([(-14, -30), (0, -26), (14, -34)], [2.4, 2.6, 2.4]), "iron", sd=0.4)
        f.part(lambda g: g.ribbon([(-14, -42), (0, -46), (14, -40)], [2.4, 2.6, 2.4]), "iron", sd=0.4)
    else:  # anchor: cột đá đen lơ lửng, mảnh vỡ quay quanh
        fl = cyc(ph) * 2
        f.part(lambda g: g.poly([(-9, -6 + fl), (-6, -46 + fl), (0, -54 + fl), (6, -46 + fl), (9, -6 + fl), (0, 0 + fl)]), stone, sd=2.6)
        f.flat(lambda g: g.line([(0, -48 + fl), (-2, -32 + fl), (2, -20 + fl), (0, -8 + fl)], 1.4), rune, alpha=230)
        f.glow(lambda g: g.line([(0, -48 + fl), (-2, -32 + fl), (2, -20 + fl), (0, -8 + fl)], 1.4), rune, radius=1.8, alpha=200, front=True)
        for q in range(3):
            a = math.tau * (ph + q / 3)
            x, y = math.cos(a) * 15, -30 + math.sin(a) * 5
            f.part(lambda g, x=x, y=y: g.poly([(x - 2.5, y), (x, y - 4), (x + 2.5, y + 0.5), (x, y + 3)]), stone, sd=0.8)
    return f


def eye(spec, pose):
    anim, i, ph = pose
    k = attack_k(anim, i)
    bob = cyc(ph) * 2.5
    f = Frame(spec["L"], dx=_dx(anim, i) * 0.4, dy=-bob)
    flesh = tone(_g(spec, "flesh", "abyss"))
    iris = _g(spec, "iris", "#ff5ad0")
    cy = -32
    f.shadow(12, 3, k=0.8)
    f.glow(lambda g: g.circle(0, cy, 18), iris, radius=6, alpha=90)
    # xúc tu
    for q in range(5):
        a = -0.9 + q * 0.45
        sw = cyc(ph, q * 0.2) * 3

        def tt(g, a=a, sw=sw):
            b = (math.sin(a) * 9, cy + 8)
            g.ribbon(bezier(b, (b[0] + math.sin(a) * 6 + sw, cy + 16), (b[0] + math.sin(a) * 10 - sw, cy + 22), (b[0] + math.sin(a) * 12 + sw, cy + 28), 10),
                     [4 * (1 - j / 11) + 0.4 for j in range(11)])
        f.part(tt, darker(flesh, 0.2), sd=0.8)
    f.part(lambda g: g.circle(0, cy, 13), flesh, sd=3.0)
    f.part(lambda g: g.ellipse(2, cy, 9.5, 8.5 - (2 if k < 0 else 0)), "white", sd=1.6)
    f.flat(lambda g: g.circle(4 + k * 1.5, cy, 4.6), iris)
    f.flat(lambda g: g.ellipse(4 + k * 1.5, cy, 1.4, 3.6), DARK)
    f.flat(lambda g: g.circle(2.5, cy - 2.4, 1.2), "#ffffff", alpha=230)
    f.flat(lambda g: (g.ribbon([(-7, cy - 9), (3, cy - 10.5), (11, cy - 6)], [1.6, 2.4, 1.2]),), DARK, alpha=230)
    if k > 0:
        f.glow(lambda g: g.ribbon([(10, cy), (26, cy - 1), (40, cy - 2)], [5, 3, 1]), iris, radius=2.2, alpha=220, front=True)
    return f


BUILDERS = {"spirit": spirit, "mushroom": mushroom, "treant": treant, "bird": bird, "bug": bug, "serpent": serpent, "frog": frog,
            "mirror": mirror, "pylon": pylon, "eye": eye}
