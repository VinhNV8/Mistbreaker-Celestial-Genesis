"""MD-1 (docs/39): bộ dựng thú 4 chân HD — sói, hổ, gấu, thằn lằn, cá sấu, nhân sư, ngựa / kỳ lân, rồng có cánh.

Khung tổng quát hoá từ Sói Sương HD (wolf.py, G0 đã duyệt). Quay mặt phải, chân ở gốc (0, 0).
Tham số spec:
  fur, belly, dark (tone) · eye (hex) · leg (độ dài chân, 1 = sói) · bulk (độ dày thân) · length (độ dài thân)
  head: canine | feline | bear | lizard | croc | horse | dragon
  mane (tone) + mane_style: ruff | lion | spikes | flame · horns: pair | unicorn | antler (+ horn tone)
  stripes (hex) · spikes (tone: gai / tinh thể dọc lưng) · tail: bushy | thin | lizard | tuft | flame | cloud
  wings (tone) + span · aura (hex) · cracks (hex: vân nham thạch) · nemes (tone: khăn nhân sư) · crown (tone)
  breath (hex: hơi thở khi cắn)
"""
import math

from mon_kit import Frame, attack_k, cyc, darker, tone
from vec import bezier, polar

DARK = "#1a1022"


def _g(s, k, d=None):
    return s.get(k, d)


BASE = dict(tilt=0.0, head_dy=0.0, jaw=0.0, ear=0.0, tail=0.0, dy=0.0,
            bb=(-8, 14), fb=(6, 4), bf=(4, 10), ff=(12, -2), flap=0.0)


def _pose(anim, i, ph):
    P = dict(BASE)
    if anim == "idle":
        P.update(dy=0.5 * (1 + cyc(ph)) * 0.6, tail=cyc(ph), head_dy=0.4 * (1 + cyc(ph)), flap=0.2 * cyc(ph))
    elif anim == "run":
        P.update([
            dict(dy=-1.2, tilt=4, bb=(-40, 30), bf=(-30, 26), fb=(40, -10), ff=(52, -24), tail=-1.0, head_dy=-0.5, flap=1.0),
            dict(dy=0.6, tilt=0, bb=(-10, 40), bf=(0, 30), fb=(10, 20), ff=(20, 10), tail=0.0, head_dy=0.3, flap=0.0),
            dict(dy=-0.4, tilt=-4, bb=(34, -6), bf=(44, -16), fb=(-34, 40), ff=(-24, 34), tail=1.0, head_dy=0.6, flap=-1.0),
            dict(dy=0.8, tilt=0, bb=(10, 18), bf=(20, 10), fb=(-10, 36), ff=(0, 30), tail=0.2, head_dy=0.2, flap=0.0),
        ][i])
    elif anim == "attack":
        P.update([
            dict(dy=1.4, tilt=-6, head_dy=1.5, jaw=0.4, ear=-1, bb=(-18, 30), bf=(-10, 26), fb=(-6, 20), ff=(4, 16), tail=1.2, flap=1.0),
            dict(dy=-1.6, tilt=8, head_dy=-1.0, jaw=1.0, ear=-1.5, bb=(-46, 20), bf=(-36, 18), fb=(50, -20), ff=(62, -30), tail=-1.2,
                 flap=-1.0),
            dict(dy=0.0, tilt=3, head_dy=0.6, jaw=0.5, bb=(-24, 20), bf=(-14, 16), fb=(24, 0), ff=(34, -8), tail=-0.4, flap=0.3),
        ][i])
    elif anim == "hurt":
        P.update(dict(tilt=-8 + i * 4, head_dy=-1.2, jaw=0.5, ear=-2, tail=1.5, flap=0.5))
    return P


def draw(spec, pose):
    anim, i, ph = pose
    P = _pose(anim, i, ph)
    dx = {"attack": [-2.0, 4.0, 3.0]}.get(anim, [0, 0, 0])
    dx = dx[i] if anim == "attack" else (-3.0 + i * 1.5 if anim == "hurt" else 0.0)
    f = Frame(spec["L"], dx=dx)
    fur = tone(_g(spec, "fur", "fur_grey"))
    belly = tone(_g(spec, "belly", "white"))
    dark = tone(_g(spec, "dark")) if _g(spec, "dark") else darker(fur, 0.3)
    head_kind = _g(spec, "head", "canine")
    LEG = _g(spec, "leg", 1.0)
    B = _g(spec, "bulk", 1.0)
    LN = _g(spec, "length", 1.0)
    leg = 15 * LEG
    by = -leg - 7 * B + P["dy"]
    tilt = math.radians(P["tilt"])
    hip = (-13 * LN, by + math.sin(tilt) * 13)
    chest = (10 * LN, by - math.sin(tilt) * 10)
    neck_len = 1.25 if head_kind == "horse" else 1.0
    neck = (chest[0] + 6, chest[1] - 7 * neck_len + P["head_dy"])
    head = (neck[0] + 7, neck[1] - 3 * neck_len + P["head_dy"] * 0.5)
    if head_kind == "croc":
        head = (chest[0] + 12, chest[1] - 1 + P["head_dy"] * 0.4)
        neck = (chest[0] + 6, chest[1] - 1)

    if _g(spec, "aura"):
        au = spec["aura"]
        f.glow(lambda g: g.ellipse(0, 0, 26, 5), au, radius=3, alpha=110)

        def wisps(g):
            for j in range(5):
                bx = -16 + j * 8
                t = (ph + j * 0.37) % 1.0
                g.ribbon(bezier((bx, by - 4), (bx - 3, by - 12 - t * 4), (bx + 3, by - 20 - t * 6), n=10),
                         [4.5 * (1 - q / 11) for q in range(11)])
        f.glow(wisps, au, radius=1.6, alpha=120)
    f.shadow(22 * max(B, 0.9) * LN, 4.5 * B)

    # ---- cánh xa (rồng)
    wings = _g(spec, "wings")
    if wings:
        _wing(f, spec, chest, P["flap"], back=True)

    def legs(back):
        sets = [("bb", hip, -3), ("fb", chest, -2)] if back else [("bf", hip, 2), ("ff", chest, 3)]
        tn = dark if back else fur
        for key, o, off in sets:
            a1, a2 = P[key]
            top = (o[0] + off, o[1] + 3)
            knee = polar(top, 8 * LEG, a1)
            paw = polar(knee, 9 * LEG, a1 + a2)
            r1 = 5.6 * B
            f.part(lambda g, top=top, knee=knee: g.capsule(top, knee, r1, 3.8 * B), tn, sd=1.8)
            f.part(lambda g, knee=knee, paw=paw: g.capsule(knee, paw, 3.5 * B, 3.0 * B), tn, sd=1.2)
            f.part(lambda g, paw=paw: g.ellipse(paw[0] + 1.8, paw[1] + 0.4, 4.2 * B, 2.7), tn, sd=0.8)
            if head_kind in ("lizard", "croc", "dragon", "feline", "bear"):
                f.flat(lambda g, paw=paw: [g.poly([(paw[0] + 3 + q * 1.6, paw[1] - 0.6), (paw[0] + 5.6 + q * 1.6, paw[1] + 1.4),
                                                   (paw[0] + 3.4 + q * 1.6, paw[1] + 1.6)]) for q in range(3)], "#f4ecdc", alpha=230)

    legs(True)
    # ---- đuôi
    tb = (hip[0] - 5, hip[1] - 3)
    tw = P["tail"]
    tail_kind = _g(spec, "tail", "bushy")
    if tail_kind in ("lizard", "thin", "tuft"):
        tail = bezier(tb, (tb[0] - 9, tb[1] + 2 - tw * 2), (tb[0] - 17, tb[1] + 8 + tw * 3), (tb[0] - 24, tb[1] + 6 + tw * 5), 14)
        w0 = 9.0 * B if tail_kind == "lizard" else 3.4
        f.part(lambda g: g.ribbon(tail, [w0 * (1 - q / 15) + 0.6 for q in range(15)]), fur, sd=1.6)
        if tail_kind == "tuft":
            f.part(lambda g: g.ellipse(tail[-1][0], tail[-1][1], 4.2, 3.2), _g(spec, "mane", fur), sd=0.8)
    elif tail_kind in ("flame", "cloud"):
        tail = bezier(tb, (tb[0] - 7, tb[1] - 9 - tw * 2), (tb[0] - 15, tb[1] - 6 + tw * 3), (tb[0] - 20, tb[1] - 12 + tw * 2), 14)
        col = _g(spec, "mane", "lava")
        f.part(lambda g: g.ribbon(tail, [12.0 * math.sin(math.pi * (0.25 + 0.7 * q / 14)) for q in range(15)]), col, sd=1.2)
        if tail_kind == "flame":
            f.glow(lambda g: g.ribbon(tail, [10] * 15), _g(spec, "aura", "#ff8a2a"), radius=2.4, alpha=150)
    else:
        tail = bezier(tb, (tb[0] - 7, tb[1] - 7 - tw * 2), (tb[0] - 14, tb[1] - 5 + tw * 3), (tb[0] - 18, tb[1] + 1 + tw * 4), 14)

        def tailf(g):
            g.ribbon(tail, [12.0 * math.sin(math.pi * (0.3 + 0.62 * q / 14)) for q in range(15)])
            for q in range(3, 14, 3):
                x, y = tail[q]
                g.poly([(x - 2, y - 2), (x - 4.5, y - 6 - tw), (x + 1.5, y - 3)])
        f.part(tailf, fur, sd=1.8)
        f.part(lambda g: g.ellipse(tail[-2][0], tail[-2][1], 3.4, 2.6), belly, sd=0.6)

    # ---- thân
    cx, cy = (hip[0] + chest[0]) / 2, (hip[1] + chest[1]) / 2
    shaggy = head_kind in ("canine", "bear")

    def body(g):
        g.ellipse(cx, cy, 17 * LN * max(B, 0.9), 9.5 * B, -tilt)
        g.circle(chest[0] + 1, chest[1] - 1, 10.5 * B)
        g.circle(hip[0], hip[1] - 0.5, 8.8 * B)
        if shaggy:
            for q in range(7):
                t = q / 6
                x = hip[0] - 4 + (chest[0] - hip[0] + 6) * t
                y = hip[1] + (chest[1] - hip[1]) * t - 8.5 * B - 1.5 * math.sin(math.pi * t)
                g.poly([(x - 3, y + 2), (x - 4.5, y - 3.5), (x + 2, y + 1)])
    bm = f.part(body, fur, sd=3.2, ld=1.4)
    f.part(lambda g: g.ellipse(cx + 3, cy + 5.5 * B, 13 * LN, 3.6 * B, -tilt), belly, sd=0.8, clip=bm)
    if _g(spec, "stripes"):
        stc = spec["stripes"]
        f.flat(lambda g: [g.ribbon([(hip[0] + q * 6 * LN, cy - 9 * B), (hip[0] + q * 6 * LN + 2, cy - 3 * B), (hip[0] + q * 6 * LN - 1, cy + 2 * B)],
                                   [3.0, 2.2, 0.4]) for q in range(4)], stc, alpha=230)
    if _g(spec, "cracks"):
        cc = spec["cracks"]

        def cr(g):
            g.line([(hip[0] - 2, cy - 4), (hip[0] + 5, cy - 1), (cx, cy - 5), (cx + 7, cy - 2), (chest[0] + 2, cy - 6)], 1.2)
            g.line([(cx - 2, cy + 3), (cx + 4, cy + 1)], 1.0)
        f.glow(cr, cc, radius=1.6, alpha=190, front=True)
        f.fx(cr, cc)
    if _g(spec, "spikes"):
        sp = tone(spec["spikes"])

        def spk(g):
            for q in range(5):
                t = q / 4
                x = hip[0] - 2 + (chest[0] - hip[0] + 2) * t
                y = hip[1] + (chest[1] - hip[1]) * t - 8.5 * B
                hgt = 6 + 3 * math.sin(math.pi * t)
                g.poly([(x - 3.2, y + 2.5), (x - 0.6, y - hgt), (x + 2.6, y + 2.5)])
        f.part(spk, sp, sd=1.0)

    # ---- bờm
    mane = _g(spec, "mane")
    style = _g(spec, "mane_style", "ruff")
    if mane and style in ("lion", "flame"):
        def mn(g):
            for q in range(8):
                a = math.radians(-160 + q * 24)
                b = (chest[0] + 2 + math.cos(a) * 6, chest[1] - 5 + math.sin(a) * 6)
                t = (chest[0] + 2 + math.cos(a) * 15 - 3, chest[1] - 5 + math.sin(a) * 13 - 2)
                g.poly([(b[0] - 3, b[1]), t, (b[0] + 3, b[1] + 1)])
            g.circle(chest[0] + 2, chest[1] - 4, 9)
        f.part(mn, mane, sd=1.8, ld=1.0)
        if style == "flame":
            f.glow(mn, _g(spec, "aura", "#ff8a2a"), radius=2.0, alpha=120)
    elif mane and style == "spikes":
        def ms(g):
            for q in range(4):
                b = (neck[0] - 4 + q * 3, neck[1] - 3 - q * 2)
                g.poly([(b[0] - 3, b[1] + 2), (b[0] - 6, b[1] - 7), (b[0] + 2, b[1])])
        f.part(ms, mane, sd=0.8)
    elif head_kind in ("canine",):
        def ruff(g):
            for q in range(5):
                a = math.radians(-130 + q * 30)
                b = (chest[0] + math.cos(a) * 5, chest[1] + math.sin(a) * 5)
                t = (chest[0] + math.cos(a) * 10 - 1, chest[1] + math.sin(a) * 9 + 2)
                g.poly([(b[0] - 2, b[1]), t, (b[0] + 2, b[1] + 1)])
        f.part(ruff, mane or belly, sd=1.0)
    if _g(spec, "saddle"):
        f.part(lambda g: g.ellipse(cx + 1, cy - 7 * B, 8, 4, -tilt), spec["saddle"], sd=1.0)
    legs(False)
    if wings:
        _wing(f, spec, chest, P["flap"], back=False)

    # ---- đầu
    _head(f, spec, head_kind, head, neck, P, fur, belly, dark, ph, anim, i)
    return f


def _wing(f, spec, chest, flap, back):
    """Cánh dơi: xương cánh tay → cổ tay → 3 xương ngón, màng lõm giữa các ngón."""
    span = _g(spec, "span", 1.0) * (0.82 if back else 1.0)
    wt = tone(_g(spec, "membrane", spec["wings"]))
    bone = darker(tone(_g(spec, "fur", "ember")), 0.05)
    if back:
        wt, bone = darker(wt, 0.3), darker(bone, 0.3)
    lift = -flap * 7
    root = (chest[0] - 7 + (-4 if back else 0), chest[1] - 7 + (-2 if back else 0))
    S = span
    wrist = (root[0] - 6 * S, root[1] - (22 + lift) * S)
    t1 = (wrist[0] - 20 * S, wrist[1] - (4 - lift * 0.3) * S)
    t2 = (wrist[0] - 24 * S, wrist[1] + 9 * S)
    t3 = (wrist[0] - 16 * S, wrist[1] + 21 * S + lift * 0.2)
    def mid(a, b, k=0.55):
        m = ((a[0] + b[0]) / 2, (a[1] + b[1]) / 2)
        return (m[0] + (wrist[0] - m[0]) * (1 - k) * 0.6, m[1] + (wrist[1] - m[1]) * (1 - k) * 0.6)
    body_end = (root[0] - 12 * S, root[1] + 5 * S)
    pts = [root, wrist, t1, mid(t1, t2), t2, mid(t2, t3), t3, mid(t3, body_end), body_end]
    f.part(lambda g: g.poly(pts), wt, sd=2.4)
    f.part(lambda g: (g.capsule(root, wrist, 2.6 * S, 1.8 * S), g.capsule(wrist, t1, 1.5 * S, 0.5),
                      g.capsule(wrist, t2, 1.3 * S, 0.5), g.capsule(wrist, t3, 1.2 * S, 0.5)), bone, sd=0.6)
    f.part(lambda g: g.poly([(wrist[0] - 1, wrist[1]), (wrist[0] + 2 * S, wrist[1] - 5 * S), (wrist[0] + 2.5 * S, wrist[1] + 0.5)]), "bone", sd=0.3)


def _head(f, spec, kind, head, neck, P, fur, belly, dark, ph, anim, i):
    hx, hy = head
    jaw = P["jaw"]
    eye = _g(spec, "eye", "#ffd23c")
    f.part(lambda g: g.capsule((neck[0] - 2, neck[1] + 3), (hx - 2, hy + 1), 6.2 * _g(spec, "bulk", 1.0), 5.6), fur, sd=1.6)
    if kind in ("canine", "feline", "bear", "horse"):
        ear_l = {"canine": 14, "feline": 9, "bear": 6, "horse": 10}[kind]
        for ex, tn in ((-4.5, dark), (-1.0, fur)):
            if kind == "bear":
                f.part(lambda g, ex=ex: g.circle(hx + ex, hy - 6.5, 3.4), tn, sd=0.8)
            else:
                f.part(lambda g, ex=ex: g.poly([(hx + ex - 3.2, hy - 3.5), (hx + ex - 1.5 + P["ear"], hy - ear_l), (hx + ex + 3.6, hy - 4)]),
                       tn, sd=1.0)
        if kind != "bear":
            f.flat(lambda g: g.poly([(hx - 1.6, hy - 4), (hx - 0.6 + P["ear"], hy - ear_l * 0.68), (hx + 1.4, hy - 4)]), "#e8a3b4", alpha=190)
    _horns(f, spec, hx, hy)
    snout = {"canine": 11, "feline": 7, "bear": 8, "horse": 12, "lizard": 11, "croc": 19, "dragon": 13}[kind]
    sr = {"canine": 4.2, "feline": 4.6, "bear": 5.0, "horse": 4.6, "lizard": 3.8, "croc": 3.6, "dragon": 4.6}[kind]
    skull = {"canine": (8.0, 6.8), "feline": (8.4, 7.4), "bear": (8.8, 7.6), "horse": (7.0, 6.2), "lizard": (6.6, 5.4),
             "croc": (6.4, 4.8), "dragon": (7.6, 6.4)}[kind]
    # hàm dưới
    jaw_a = math.radians(18 * jaw + (4 if kind == "croc" else 0))
    jb = (hx + 2, hy + 3)
    jl = snout - 2
    jt = (jb[0] + math.cos(jaw_a) * jl, jb[1] + math.sin(jaw_a) * jl)
    if jaw > 0:
        f.flat(lambda g: g.poly([(hx + 2, hy + 1), (hx + snout + 1, hy + 2), jt, jb]), "#5a1f2e")
        f.flat(lambda g: [g.poly([(hx + 4 + q * (snout - 4) / 3, hy + 2), (hx + 5 + q * (snout - 4) / 3, hy + 4.2),
                                  (hx + 6 + q * (snout - 4) / 3, hy + 2)]) for q in range(3)], "#ffffff")
        if _g(spec, "breath") and anim == "attack" and i == 1:
            br = spec["breath"]
            f.glow(lambda g: g.ellipse(hx + snout + 10, hy + 4, 10, 5), br, radius=3, alpha=200, front=True)
            f.fx(lambda g: g.ellipse(hx + snout + 7, hy + 3.5, 6, 3), br)
    f.part(lambda g: g.capsule(jb, jt, 2.4, 1.6), belly if kind not in ("croc", "lizard") else fur, sd=0.8)
    # sọ + mõm
    def sk(g):
        g.ellipse(hx, hy - 0.5, *skull)
        g.capsule((hx + 2, hy + 0.5), (hx + snout, hy + 1.5), sr, sr * 0.72)
        if kind in ("canine", "feline"):
            g.poly([(hx - 7, hy - 1), (hx - 11, hy + 4), (hx - 4, hy + 5)])
    f.part(sk, fur, sd=1.8, ld=1.0)
    if _g(spec, "nemes"):
        nt = tone(spec["nemes"])
        nem = [(hx - 7, hy - 9.5), (hx + 4, hy - 9.5), (hx + 6.5, hy - 4), (hx + 0.5, hy - 3.2), (hx - 2.5, hy + 3), (hx - 4, hy + 16),
               (hx - 12, hy + 14), (hx - 11, hy - 3)]
        f.part(lambda g: g.poly(nem), nt, sd=1.6)
        f.flat(lambda g: [g.line([(hx - 11 + q * 2.2, hy + 13.5 - q * 0.4), (hx - 6 + q * 2.6, hy - 8.5)], 1.3) for q in range(4)],
               _g(spec, "nemes2", "#2a5aa8"), alpha=235)
        f.part(lambda g: g.ribbon([(hx - 8, hy - 7.5), (hx - 1, hy - 9), (hx + 5.5, hy - 5.5)], [2.6, 3.0, 2.4]), nt, sd=0.4)
        f.fx(lambda g: g.circle(hx + 4.5, hy - 8.5, 1.6), _g(spec, "eye", "#4fc3ff"))
    if kind in ("canine", "feline", "bear", "horse"):
        f.part(lambda g: g.capsule((hx + 4, hy + 2.6), (hx + snout - 1, hy + 2.8), 1.9, 1.5), belly, sd=0.5)
    if kind in ("croc", "lizard", "dragon"):
        f.flat(lambda g: [g.circle(hx - 3 + q * 3.2, hy - 4.5 + (q % 2), 1.0) for q in range(4)], dark.shade, alpha=200)
        f.part(lambda g: g.ellipse(hx + 1.5, hy - 4.0, 3.2, 2.2), fur, sd=0.6)
        if kind == "croc":
            f.flat(lambda g: [g.poly([(hx + 4 + q * 3, hy + 2.6), (hx + 5 + q * 3, hy + 4.8), (hx + 6 + q * 3, hy + 2.6)]) for q in range(4)],
                   "#fff8e8")
    if kind == "feline" and _g(spec, "stripes"):
        f.flat(lambda g: [g.line([(hx - 4 + q * 3, hy - 6), (hx - 3 + q * 3, hy - 2)], 1.1) for q in range(3)], spec["stripes"], alpha=230)
    f.flat(lambda g: g.ellipse(hx + snout + 0.6, hy + 0.9, 1.9, 1.5), "#1c1726")
    if _g(spec, "crown"):
        ct = spec["crown"]
        f.part(lambda g: g.poly([(hx - 6, hy - 5), (hx - 5, hy - 12), (hx - 2.5, hy - 8), (hx, hy - 13), (hx + 2.5, hy - 8), (hx + 5, hy - 12),
                                 (hx + 6, hy - 5)]), ct, sd=0.8)
    # mắt (phát sáng, xếch)
    ex, ey = hx + 2.8, hy - 1.6
    f.glow(lambda g: g.ellipse(ex, ey, 2.8, 1.8), eye, radius=1.6, alpha=200, front=True)
    f.fx(lambda g: g.poly([(ex - 2.2, ey + 0.4), (ex + 2.0, ey - 1.0), (ex + 1.4, ey + 1.0), (ex - 1.6, ey + 1.2)]), eye)
    f.fx(lambda g: g.circle(ex + 0.8, ey - 0.1, 0.6), "#ffffff")
    f.flat(lambda g: g.line([(ex - 3, ey - 2.2), (ex + 2.6, ey - 2.4)], 1.1), DARK, alpha=220)


def _horns(f, spec, hx, hy):
    h = _g(spec, "horns")
    if not h:
        return
    ht = _g(spec, "horn", "bone")
    if h == "unicorn":
        f.part(lambda g: g.ribbon([(hx + 2, hy - 6), (hx + 5, hy - 12), (hx + 9, hy - 19)], [3.6, 2.4, 0.4]), ht, sd=0.6)
        f.glow(lambda g: g.circle(hx + 8, hy - 17, 2.2), _g(spec, "aura", "#ffffff"), radius=1.4, alpha=160, front=True)
    elif h == "antler":
        for ox, tn in ((-3, darker(tone(ht), 0.2)), (0, tone(ht))):
            f.part(lambda g, ox=ox: (g.ribbon([(hx + ox, hy - 6), (hx + ox - 3, hy - 12), (hx + ox - 1, hy - 19)], [2.4, 1.8, 0.6]),
                                     g.ribbon([(hx + ox - 2, hy - 11), (hx + ox + 3, hy - 15)], [1.6, 0.4]),
                                     g.ribbon([(hx + ox - 2, hy - 15), (hx + ox - 7, hy - 18)], [1.4, 0.4])), tn, sd=0.4)
    else:
        for ox, tn in ((-4, darker(tone(ht), 0.2)), (-0.5, tone(ht))):
            f.part(lambda g, ox=ox: g.ribbon([(hx + ox, hy - 5), (hx + ox - 4, hy - 10), (hx + ox - 10, hy - 12), (hx + ox - 13, hy - 9)],
                                             [3.6, 2.8, 1.6, 0.3]), tn, sd=0.6)
