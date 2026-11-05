"""MD-1 (docs/39): bộ dựng quái dáng người HD — lính, pháp sư, cung thủ, xác ướp, xương, người đá / tuyết, bóng, boss.

Tỉ lệ "chunky" theo ảnh mẫu: đầu ≈ 1/3 chiều cao, vai rộng, bàn tay / ủng to, chân ngắn. Quay mặt phải (3/4).
Tham số spec (mọi khoá đều tuỳ chọn trừ L):
  body: normal | brute (người đá / tuyết / cự thần: thân to, tay to, đầu thấp) | thin (xương, pháp sư gầy)
  h, bulk          — hệ số chiều cao / bề ngang
  skin, cloth, pants, boots, trim, collar  — tên dải màu (mon_kit.PAL) hoặc hex
  head: human | hood | helm | skull | mummy | stone | snow | shadow | faceless
  hair, hair_style (none | short | long), beard, horns (tone), crown (tone), eye (hex)
  robe, cape (tone), pauldron (tone), belt (tone), shield (tone mặt khiên), emblem (hex)
  weapon: sword | axe | spear | staff | bow | hammer | claws | dagger | none;  orb (hex, đầu trượng)
  wrap (băng vải), ribs (xương sườn), cracks (hex: vết nứt phát sáng), rocks (tone: tảng đá trên vai)
  aura (hex), hover (đơn vị bay), ghost (alpha thân 0..1)
"""
import math

from mon_kit import Frame, attack_k, cyc, darker, tone
from vec import polar

DARK = "#140c1c"


def _g(spec, k, d=None):
    return spec.get(k, d)


def draw(spec, pose):
    anim, i, ph = pose
    L = spec["L"]
    body = _g(spec, "body", "normal")
    h = _g(spec, "h", 1.0) * (0.92 if body == "brute" else 1.0)
    bulk = _g(spec, "bulk", 1.0) * (1.45 if body == "brute" else (0.82 if body == "thin" else 1.0))
    limb = 1.55 if body == "brute" else (0.62 if body == "thin" else 1.0)
    hover = _g(spec, "hover", 0.0)
    k = attack_k(anim, i)
    # ---- tư thế
    bob = 0.0
    lean = 0.0
    dx = 0.0
    step = 0.0
    if anim == "idle":
        bob = cyc(ph) * 0.9
        if hover:
            bob = cyc(ph) * 2.2
    elif anim == "run":
        step = cyc(ph)
        bob = -abs(cyc(ph, 0.25)) * 1.8 + 0.6
        lean = 4.0
    elif anim == "attack":
        lean = [-7.0, 9.0, 3.0][i]
        dx = [-2.0, 4.0, 1.5][i]
        bob = [0.8, -0.6, 0.2][i]
    elif anim == "hurt":
        lean = -10.0 + i * 5
        dx = -3.0 + i * 1.5
    f = Frame(L, dx=dx, dy=-hover)
    skin = tone(_g(spec, "skin", "skin"))
    cloth = tone(_g(spec, "cloth", "cloth_red"))
    pants = tone(_g(spec, "pants", "leather"))
    boots = tone(_g(spec, "boots", "leather"))
    trim = tone(_g(spec, "trim", "gold"))
    eye = _g(spec, "eye", "#ffd23c")
    alpha = int(255 * _g(spec, "ghost", 1.0))
    la = math.radians(lean)

    def T(x, y):
        """Điểm trên thân, nghiêng quanh hông theo lean."""
        hy = -17 * h
        yy = y - hy
        return (x + math.sin(la) * -yy, hy + yy * math.cos(la) + bob)

    hip_y = -17 * h
    sh_y = -41 * h
    head_c = T(2.5, (-53 if body != "brute" else -47) * h)
    head_r = 10.5 * (0.78 if body == "brute" else 1.0) * _g(spec, "head_k", 1.0)

    # ---- hào quang phía sau + bóng
    if _g(spec, "aura"):
        au = spec["aura"]
        f.glow(lambda g: g.ellipse(0, -30 * h, 22 * bulk, 34 * h), au, radius=7, alpha=95)
        f.glow(lambda g: g.ellipse(0, 0, 20 * bulk, 4.5), au, radius=2.5, alpha=120)

        def wisps(g):
            for j in range(4):
                bx = -14 * bulk + j * 9 * bulk
                t = (ph + j * 0.31) % 1.0
                g.ribbon([(bx, -10 * h), (bx - 3, -26 * h - t * 6), (bx + 2, -44 * h - t * 8), (bx - 1, -58 * h - t * 10)],
                         [4.2, 3.4, 2.2, 0.6])
        f.glow(wisps, au, radius=1.8, alpha=110)
    if not _g(spec, "no_shadow"):
        f.shadow(15 * bulk, 3.6 * bulk, k=1.0 if not hover else 0.75)
    if _g(spec, "wings"):
        wt = tone(spec["wings"])
        fl = cyc(ph) * 0.18 + (0.25 if anim == "run" else 0)
        for side, kk in ((-1, 0.8), (1, 1.0)):
            r0 = T(-4 + side * 2, sh_y + 2)
            f.part(lambda g, r0=r0, kk=kk: (g.ellipse(r0[0] - 9 * kk, r0[1] - 9 * kk, 12 * kk, 6 * kk, -0.9 - fl),
                                            g.ellipse(r0[0] - 7 * kk, r0[1] + 4 * kk, 8 * kk, 4.5 * kk, 0.5 + fl)),
                   wt if side > 0 else darker(wt, 0.2), sd=1.0, alpha=175)

    # ---- áo choàng (sau lưng)
    if _g(spec, "cape"):
        fl = cyc(ph) * 2 + (4 if anim == "run" else 0) + (3 if k > 0 else 0)
        f.part(lambda g: g.ribbon([T(-5, sh_y + 1), T(-10, sh_y + 12), T(-14 - fl * 0.6, -14 * h), T(-17 - fl, -2 * h)],
                                  [16 * bulk, 19 * bulk, 22 * bulk, 22 * bulk]), darker(spec["cape"], 0.18), sd=3.5, alpha=alpha)

    # ---- tay sau (+ khiên)
    sh_back = T(-11 * bulk, sh_y + 3)
    sh_front = T(12 * bulk, sh_y + 3)
    if anim == "run":
        ab = (-8 + 30 * step, -10)
        af = (10 - 30 * step, -30)
    elif anim == "attack":
        ab = ([-30, 20, 5][i], [-20, -15, -15][i])
        af = ([-150, 60, 40][i], [-30, -20, -40][i])
    elif anim == "hurt":
        ab, af = (-30, -10), (-40, -30)
    else:
        ab = (-6 + cyc(ph) * 3, -14)
        af = (16 + cyc(ph) * 3, -48)
    if _g(spec, "weapon") in ("staff", "spear") and anim in ("idle", "run"):
        af = (40 + cyc(ph) * 2, 52)
    if _g(spec, "weapon") == "bow" and anim != "hurt":
        af = (68, 22)
    ur, fr, hr = 4.2 * limb, 3.5 * limb, 3.6 * (1.25 if body == "brute" else 1.0)
    arm_len = 9.5 * h * (1.1 if body == "brute" else 1.0)
    sleeve = cloth if not _g(spec, "bare_arms") else skin
    ctb = darker(sleeve, 0.22)
    elb = polar(sh_back, arm_len, ab[0])
    hb = polar(elb, arm_len, ab[0] + ab[1])
    f.part(lambda g: g.capsule(sh_back, elb, ur, fr * 0.95), ctb, sd=1.6, alpha=alpha)
    f.part(lambda g: g.capsule(elb, hb, fr * 0.95, fr * 0.85), darker(skin if _g(spec, "bare_arms") else sleeve, 0.22), sd=1.4,
           alpha=alpha)
    f.part(lambda g: g.circle(hb[0], hb[1], hr), darker(_g(spec, "glove", skin), 0.22), sd=1.2, alpha=alpha)
    if _g(spec, "shield"):
        st = tone(spec["shield"])
        sx, sy = hb[0] + 1, hb[1] - 4
        f.part(lambda g: g.poly([(sx - 9, sy - 11), (sx + 9, sy - 11), (sx + 9, sy + 2), (sx, sy + 12), (sx - 9, sy + 2)]), trim, sd=1.4)
        f.part(lambda g: g.poly([(sx - 6.5, sy - 8.5), (sx + 6.5, sy - 8.5), (sx + 6.5, sy + 1.5), (sx, sy + 9), (sx - 6.5, sy + 1.5)]),
               st, sd=2.0)
        em = _g(spec, "emblem", "#fff4c0")
        f.flat(lambda g: g.poly([(sx, sy - 6), (sx + 3.5, sy - 1), (sx, sy + 5), (sx - 3.5, sy - 1)]), em, alpha=220)

    # ---- chân
    def leg(x0, foot_dx, lift, front):
        hipp = (x0 * bulk, hip_y + bob)
        foot = (x0 * bulk + foot_dx, -lift)
        knee = ((hipp[0] + foot[0]) / 2 + 2.5, (hipp[1] + foot[1]) / 2 - lift * 0.3)
        tp = pants if front else darker(pants, 0.25)
        tb = boots if front else darker(boots, 0.25)
        lr = 4.6 * limb * (0.9 if body == "brute" else 1.0)
        f.part(lambda g: g.capsule(hipp, knee, lr, lr * 0.85), tp, sd=1.6, alpha=alpha)
        f.part(lambda g: g.capsule(knee, (foot[0], foot[1] - 2.5), lr * 0.85, lr * 0.8), tb, sd=1.4, alpha=alpha)
        f.part(lambda g: g.ellipse(foot[0] + 2.2, foot[1] - 1.6, 5.2 * (1.2 if body == "brute" else 1.0), 2.9), tb, sd=1.0,
               alpha=alpha)
        if _g(spec, "wrap"):
            f.flat(lambda g: [g.line([(knee[0] - 4, knee[1] + j * 3 - 3), (knee[0] + 4, knee[1] + j * 3 - 1)], 0.7)
                              for j in range(3)], darker(pants, 0.35).shade, alpha=200)

    robe = _g(spec, "robe")
    if not hover:
        lift_b = max(0.0, -step) * 5 if anim == "run" else 0
        lift_f = max(0.0, step) * 5 if anim == "run" else 0
        sb = -7 * step if anim == "run" else ([-2, -5, -3][i] if anim == "attack" else 0)
        sf = 7 * step if anim == "run" else ([1, 6, 3][i] if anim == "attack" else 0)
        leg(-5.0, sb - 1.5, lift_b, False)
        if not robe:
            leg(5.0, sf + 1, lift_f, True)

    # ---- thân
    def torso(g):
        g.ellipse(*T(0, -32 * h), 13.5 * bulk, 11.5 * h)
        g.ellipse(*T(0, -24 * h), 11 * bulk, 8.5 * h)
        g.ellipse(*T(0, hip_y - 2), 9.5 * bulk, 5.5)
    if robe:
        sway = cyc(ph) * 1.5 + (3 if anim == "run" else 0)
        rt = tone(robe if isinstance(robe, str) else cloth)
        hem = -0.5 if not hover else 4.0

        def skirt(g):
            g.poly([T(-10 * bulk, -26 * h), T(10 * bulk, -26 * h), (16 * bulk + sway + dx * 0, hem), (-15 * bulk + sway * 0.5, hem)])
            g.ellipse(sway * 0.7, hem, 15.5 * bulk, 3.0)
        f.part(skirt, rt, sd=3.0, alpha=alpha)
        f.flat(lambda g: g.line([T(2.5, -24 * h), (4 + sway, hem + 1)], 1.6), trim.base, alpha=220)
        if hover:
            f.glow(lambda g: g.ellipse(sway, hem + 2, 14 * bulk, 4), _g(spec, "aura", "#c8e0ff"), radius=3, alpha=130)
    if _g(spec, "tunic", body == "normal" and not robe and not _g(spec, "wrap")):
        tt = darker(cloth, 0.12)
        f.part(lambda g: g.poly([T(-11 * bulk, -22 * h), T(11.5 * bulk, -22 * h), T(12.5 * bulk, -10 * h), T(6, -11.5 * h), T(2, -9 * h),
                                 T(-3, -11.5 * h), T(-11.5 * bulk, -10 * h)]), tt, sd=2.0, alpha=alpha)
    f.part(torso, cloth, sd=3.6, ld=1.6, alpha=alpha)
    # ngực / bụng sáng hơn, đai lưng
    f.flat(lambda g: g.ellipse(*T(-1.5, -35 * h), 7.5 * bulk, 4.5 * h), cloth.light, alpha=int(alpha * 0.42), blur=2.2)
    if _g(spec, "ribs"):
        f.flat(lambda g: [g.line([T(-6 * bulk, (-36 + j * 4) * h), T(0, (-34 + j * 4) * h), T(8 * bulk, (-36 + j * 4) * h)], 1.1)
                          for j in range(4)], DARK, alpha=200)
        f.flat(lambda g: g.line([T(1, -40 * h), T(1, -21 * h)], 1.4), DARK, alpha=160)
    if _g(spec, "wrap"):
        f.flat(lambda g: [g.line([T(-12 * bulk, (-38 + j * 5) * h), T(12 * bulk, (-35 + j * 5) * h)], 0.8) for j in range(5)],
               darker(cloth, 0.35).shade, alpha=180)
    belt = _g(spec, "belt", _g(spec, "trim", "leather"))
    if belt and not _g(spec, "ribs"):
        f.part(lambda g: g.ribbon([T(-10.5 * bulk, -20 * h), T(0, -18.5 * h), T(10.5 * bulk, -20 * h)], [4, 4.4, 4]), belt, sd=0.8,
               alpha=alpha)
        f.part(lambda g: g.ellipse(*T(3, -18.8 * h), 2.6, 2.4), "gold", sd=0.5)
    if _g(spec, "cracks"):
        cc = spec["cracks"]

        def cr(g):
            g.line([T(-6, -36 * h), T(-1, -30 * h), T(-4, -25 * h), T(2, -20 * h)], 1.4)
            g.line([T(6, -38 * h), T(3, -31 * h), T(8, -26 * h)], 1.2)
        f.glow(cr, cc, radius=1.6, alpha=200, front=True)
        f.fx(cr, cc)
    if robe is None and not hover:
        pass
    if robe and not hover:
        pass
    # chân trước vẽ sau thân (dáng 3/4)
    # ---- vai: giáp vai / đá
    if _g(spec, "rocks"):
        rt = tone(spec["rocks"])
        f.part(lambda g: g.poly([T(-16 * bulk, sh_y + 2), T(-12 * bulk, sh_y - 9), T(-4, sh_y - 5), T(-6, sh_y + 4)]), rt, sd=1.8)
    pd = _g(spec, "pauldron", _g(spec, "collar"))
    if pd:
        pt = tone(pd)
        f.part(lambda g: g.ellipse(*T(-10 * bulk, sh_y + 1.5), 7 * bulk, 5.2), darker(pt, 0.2), sd=1.6, alpha=alpha)

    if _g(spec, "head") == "hood" and _g(spec, "mantle", True):
        mt = tone(_g(spec, "hood_tone", _g(spec, "cloth", "purple")))
        f.part(lambda g: (g.ellipse(*T(0.5, sh_y + 3), 15 * bulk, 6.5), g.poly([T(-14 * bulk, sh_y + 3), T(-4, sh_y + 12), T(4, sh_y + 9),
                                                                              T(15 * bulk, sh_y + 3)])), darker(mt, 0.1), sd=2.0, alpha=alpha)
        f.flat(lambda g: g.ribbon([T(-12 * bulk, sh_y + 5), T(0, sh_y + 10), T(13 * bulk, sh_y + 5)], [1.4, 1.6, 1.4]), trim.base, alpha=220)
    # ---- đầu
    neck = T(1.5, -43 * h)
    if body != "brute":
        f.part(lambda g: g.capsule(neck, (neck[0] + 0.5, neck[1] - 4), 4.2, 4.0), skin, sd=1.0, alpha=alpha)
    _head(f, spec, head_c, head_r, eye, ph, anim, alpha)

    if pd:
        f.part(lambda g: g.ellipse(*T(11 * bulk, sh_y + 1.5), 7.4 * bulk, 5.6), pt, sd=1.6, alpha=alpha)
        f.flat(lambda g: g.line([T(6 * bulk, sh_y + 4.5), T(11 * bulk, sh_y + 6), T(17 * bulk, sh_y + 4.5)], 1.2), trim.base, alpha=230)
    if _g(spec, "rocks"):
        f.part(lambda g: g.poly([T(8 * bulk, sh_y + 3), T(11 * bulk, sh_y - 8), T(19 * bulk, sh_y - 4), T(18 * bulk, sh_y + 4)]),
               spec["rocks"], sd=1.8)

    # ---- tay trước + vũ khí
    elf = polar(sh_front, arm_len, af[0])
    hf = polar(elf, arm_len, af[0] + af[1])
    weapon = _g(spec, "weapon", "none")
    wang = {"idle": 160 + cyc(ph) * 4, "run": 120 - step * 10, "hurt": 200}.get(anim, 0)
    if anim == "attack":
        wang = [200, 40, 70][i]
    if weapon in ("staff", "spear"):
        wang = [170, 70, 110][i] if anim == "attack" else 178 + cyc(ph) * 2
    if weapon == "bow":
        wang = 180
    _weapon_back(f, spec, weapon, hf, wang, trim, ph)
    f.part(lambda g: g.capsule(sh_front, elf, ur, fr), sleeve, sd=1.6, alpha=alpha)
    f.part(lambda g: g.capsule(elf, hf, fr, fr * 0.9), skin if _g(spec, "bare_arms") else sleeve, sd=1.4, alpha=alpha)
    if _g(spec, "cuff"):
        f.part(lambda g: g.capsule(polar(elf, arm_len * 0.55, af[0] + af[1]), polar(elf, arm_len * 0.8, af[0] + af[1]), fr * 1.15),
               spec["cuff"], sd=0.8)
    f.part(lambda g: g.circle(hf[0], hf[1], hr), _g(spec, "glove", skin), sd=1.2, alpha=alpha)
    _weapon_front(f, spec, weapon, hf, wang, trim, ph, anim, i)
    return f


def _head(f, spec, c, r, eye, ph, anim, alpha):
    kind = _g(spec, "head", "human")
    x, y = c
    skin = tone(_g(spec, "skin", "skin"))
    if kind in ("human",):
        hair = _g(spec, "hair")
        if hair and _g(spec, "hair_style") == "long":
            sw = cyc(ph) * 1.2
            f.part(lambda g: g.ribbon([(x - 3, y - 6), (x - 9, y + 4), (x - 10 - sw, y + 16), (x - 8 - sw, y + 24)], [14, 13, 10, 4]),
                   darker(hair, 0.15), sd=1.6)
        f.part(lambda g: (g.circle(x, y, r), g.ellipse(x + 3, y + 5, r * 0.75, r * 0.6)), skin, sd=2.6, ld=1.2, alpha=alpha)
        f.flat(lambda g: g.ellipse(x + 7.5, y + 3.5, 2.2, 1.4), "#e07a6a", alpha=110)
        if hair:
            from PIL import ImageChops
            hm = f.mask(lambda g: (g.ellipse(x - 2.5, y - 4.0, r * 1.06, r * 0.86), g.poly([(x - r - 0.5, y - 2), (x - r - 1.5, y + 7), (x - 4, y + 2)])))
            face = f.mask(lambda g: g.ellipse(x + 5.5, y + 2.2, r * 0.66, r * 0.62))
            fr_ = f.mask(lambda g: g.poly([(x - 1, y - r - 1), (x + r + 1.5, y - 5.5), (x + 3, y - 3.5)]))
            f.c.fill(ImageChops.lighter(ImageChops.subtract(hm, face), fr_), tone(hair), 1.8 * f.u, 1.4 * f.u)
        if _g(spec, "beard"):
            f.part(lambda g: g.poly([(x - 1, y + 3), (x + 9, y + 4), (x + 5, y + 15), (x + 1, y + 11)]), spec["beard"], sd=1.2)
        if _g(spec, "glow_eyes"):
            f.eyes([(x + 3.5, y + 0.5), (x + 8.2, y)], eye, r=1.3)
        else:
            f.flat(lambda g: [g.ellipse(ex, ey, 1.25, 1.7) for ex, ey in ((x + 3.5, y + 0.5), (x + 8.2, y))], DARK)
            f.flat(lambda g: g.line([(x + 1.5, y - 3), (x + 5, y - 3.6)], 0.9), DARK, alpha=200)
            f.flat(lambda g: g.line([(x + 7, y - 4), (x + 10, y - 3.2)], 0.9), DARK, alpha=200)
    elif kind == "hood":
        ht = tone(_g(spec, "hood_tone", _g(spec, "cloth", "purple")))
        f.part(lambda g: (g.circle(x - 0.5, y - 0.5, r + 1.5), g.poly([(x - r - 1, y - 2), (x - r - 6, y + 10), (x - 4, y + 6)]),
                          g.poly([(x - 5, y - r - 1), (x - 9, y - r - 6), (x + 2, y - r)])), ht, sd=2.6)
        f.flat(lambda g: g.ellipse(x + 4.2, y + 1.5, r * 0.62, r * 0.72), DARK)
        if _g(spec, "mask"):
            f.part(lambda g: g.poly([(x - 0.5, y + 3.2), (x + r * 0.95, y + 2.4), (x + r * 0.8, y + 7.5), (x + 2, y + 8.5)]), spec["mask"], sd=0.6)
        f.eyes([(x + 3.0, y + 0.5), (x + 7.0, y + 0.2)], eye, r=1.25, slit=True)
    elif kind == "helm":
        mt = tone(_g(spec, "helm", "steel"))
        f.part(lambda g: (g.circle(x, y, r), g.poly([(x - r, y), (x - r + 1, y + 9), (x + r, y + 9), (x + r, y)])), mt, sd=2.6)
        f.part(lambda g: g.ribbon([(x - 8, y - 7), (x, y - r - 3), (x + 7, y - 8)], [3, 4, 3]), _g(spec, "trim", "gold"), sd=0.8)
        if _g(spec, "plume"):
            f.part(lambda g: g.ribbon([(x - 2, y - r - 1), (x - 8, y - r - 6), (x - 16, y - r - 2), (x - 20, y - r + 6)], [5, 7, 6, 2]),
                   spec["plume"], sd=1.4)
        f.flat(lambda g: g.poly([(x - 1, y - 1), (x + r + 0.5, y - 2), (x + r + 0.5, y + 1.8), (x - 1, y + 1.8)]), DARK)
        f.flat(lambda g: g.line([(x + 5, y + 1.8), (x + 5, y + 8)], 1.2), DARK, alpha=220)
        f.eyes([(x + 3.0, y), (x + 7.5, y - 0.2)], eye, r=1.05)
    elif kind == "skull":
        f.part(lambda g: (g.circle(x, y, r * 0.95), g.poly([(x - 2, y + 4), (x + 9, y + 4), (x + 8, y + 10), (x - 1, y + 9)])),
               "bone", sd=2.2)
        f.flat(lambda g: [g.circle(ex, y + 0.5, 2.4) for ex in (x + 2.5, x + 7.5)], DARK)
        f.flat(lambda g: g.poly([(x + 5, y + 3), (x + 6.2, y + 5.6), (x + 3.8, y + 5.6)]), DARK)
        f.flat(lambda g: [g.line([(x + 1 + j * 2, y + 6.5), (x + 1 + j * 2, y + 9)], 0.7) for j in range(5)], DARK, alpha=200)
        f.eyes([(x + 2.7, y + 0.8), (x + 7.6, y + 0.8)], eye, r=0.95)
    elif kind == "mummy":
        bt = tone("bandage")
        f.part(lambda g: g.circle(x, y, r), bt, sd=2.4)
        f.flat(lambda g: [g.line([(x - r, y - 7 + j * 3.4), (x + r, y - 5 + j * 3.4 - (j % 2) * 2)], 0.8) for j in range(6)],
               bt.shade, alpha=220)
        f.flat(lambda g: g.ellipse(x + 5, y + 0.5, 4.2, 1.8), DARK)
        f.eyes([(x + 6.0, y + 0.5)], eye, r=1.3)
    elif kind == "stone":
        st = tone(_g(spec, "skin", "stone"))
        f.part(lambda g: g.poly([(x - r, y + 2), (x - r * 0.7, y - r * 0.9), (x + r * 0.5, y - r), (x + r * 1.1, y - 1), (x + r * 0.8, y + r * 0.8),
                                 (x - r * 0.4, y + r)]), st, sd=2.4)
        f.flat(lambda g: g.line([(x + 0.5, y - 1.5), (x + r * 1.0, y - 2.5)], 2.6), DARK)
        f.eyes([(x + 3.5, y - 1.6), (x + 7.6, y - 2.1)], eye, r=1.15)
    elif kind == "snow":
        f.part(lambda g: g.circle(x, y, r), "snow", sd=2.4)
        f.part(lambda g: [g.poly([(x - 6 + j * 4.5, y - r + 2), (x - 5 + j * 4.5 + (j - 1) * 1.5, y - r - 7 + abs(j - 1) * 2),
                                  (x - 3 + j * 4.5, y - r + 2)]) for j in range(3)], "ice", sd=0.8)
        f.flat(lambda g: [g.circle(ex, y, 1.6) for ex in (x + 3.0, x + 7.5)], "#1a2a40")
        f.eyes([(x + 3.0, y), (x + 7.5, y)], eye, r=0.8)
        f.flat(lambda g: g.ribbon([(x + 2, y + 5), (x + 5.5, y + 6.5), (x + 9, y + 5)], [1, 1.4, 1]), "#1a2a40")
    elif kind in ("shadow", "faceless"):
        st = tone(_g(spec, "skin", "shadow"))
        f.part(lambda g: (g.circle(x, y, r), g.ellipse(x + 3, y + 5, r * 0.7, r * 0.55)), st, sd=2.4)
        if kind == "shadow":
            f.eyes([(x + 3.2, y + 0.5), (x + 7.6, y)], eye, r=1.3, slit=True)
            f.fx(lambda g: g.ribbon([(x + 1, y + 6), (x + 5, y + 7.5), (x + 9, y + 5.5)], [0.8, 1.4, 0.8]), eye, alpha=200)
        else:
            f.flat(lambda g: g.ribbon([(x + 1, y - 6), (x + 3, y), (x + 1.5, y + 7)], [0.6, 1.0, 0.6]), DARK, alpha=160)
            f.glow(lambda g: g.circle(x + 4, y - 3, 2.6), eye, radius=1.6, alpha=170, front=True)
    if _g(spec, "horns"):
        ht = spec["horns"]
        f.part(lambda g: (g.ribbon([(x - 3, y - r + 2), (x - 7, y - r - 5), (x - 4, y - r - 11), (x - 0.5, y - r - 13)], [4.5, 3.6, 2.2, 0.4]),
                          g.ribbon([(x + 4, y - r + 2), (x + 7, y - r - 5), (x + 12, y - r - 9), (x + 15, y - r - 9)], [4.5, 3.6, 2.2, 0.4])),
               ht, sd=1.0)
    if _g(spec, "crown"):
        ct = spec["crown"]
        f.part(lambda g: g.poly([(x - 8, y - r + 3), (x - 7, y - r - 5), (x - 3.5, y - r - 1), (x, y - r - 7), (x + 3.5, y - r - 1),
                                 (x + 7, y - r - 5), (x + 8.5, y - r + 3)]), ct, sd=0.9)
        f.fx(lambda g: g.circle(x, y - r - 1, 1.3), _g(spec, "eye", "#ff5a7a"))


def _weapon_back(f, spec, weapon, hand, ang, trim, ph):
    """Phần vũ khí nằm sau bàn tay (cán trượng, cung)."""
    if weapon in ("staff", "spear"):
        top = polar(hand, 30, ang)
        bot = polar(hand, 17, ang + 180)
        f.part(lambda g: g.capsule(bot, top, 1.8, 1.6), _g(spec, "shaft", "wood"), sd=0.6)


def _weapon_front(f, spec, weapon, hand, ang, trim, ph, anim, i):
    blade = tone(_g(spec, "blade", "steel"))
    if weapon == "sword":
        tip = polar(hand, 29, ang)
        base = polar(hand, 3, ang)
        f.part(lambda g: g.capsule(polar(hand, -4, ang), base, 1.4), "leather", sd=0.4)
        f.part(lambda g: g.ribbon([base, polar(hand, 17, ang), tip], [5.2, 4.6, 0.6]), blade, sd=1.0, ld=0.8)
        f.flat(lambda g: g.line([polar(hand, 5, ang), polar(hand, 22, ang)], 0.8), blade.light, alpha=200)
        f.part(lambda g: g.capsule(polar(base, 4.5, ang + 90), polar(base, 4.5, ang - 90), 1.6), trim, sd=0.5)
        if anim == "attack" and i == 1:
            f.glow(lambda g: g.ribbon([polar(hand, 26, ang - 70), polar(hand, 28, ang - 35), polar(hand, 26, ang)], [1, 4, 1]),
                   _g(spec, "slash", "#ffffff"), radius=1.4, alpha=180, front=True)
    elif weapon == "bow":
        pull = 4.0 if anim == "attack" and i == 0 else 0.0
        pts = [(hand[0] + 1 + 7 * math.cos(math.pi * (j / 8.0 - 0.5)), hand[1] - 19 + j * 4.75) for j in range(9)]
        f.flat(lambda g: g.line([pts[0], (hand[0] - 5 - pull, hand[1]), pts[-1]], 0.7), "#f4eedc", alpha=235)
        f.part(lambda g: g.ribbon(pts, [1.2, 2.2, 2.8, 3.2, 3.4, 3.2, 2.8, 2.2, 1.2]), _g(spec, "shaft", "wood"), sd=0.6)
        f.part(lambda g: g.capsule((hand[0] + 6, hand[1] - 3), (hand[0] + 6, hand[1] + 3), 1.6), trim, sd=0.3)
        if anim == "attack" and i < 2:
            f.part(lambda g: g.line([(hand[0] - 5 - pull, hand[1]), (hand[0] + 16, hand[1])], 0.9), "wood", sd=0)
            f.fx(lambda g: g.poly([(hand[0] + 16, hand[1] - 1.8), (hand[0] + 20, hand[1]), (hand[0] + 16, hand[1] + 1.8)]),
                 _g(spec, "orb", "#e8e8f0"))
    elif weapon == "dagger":
        f.part(lambda g: g.ribbon([polar(hand, 2, ang), polar(hand, 8, ang), polar(hand, 13, ang)], [3.2, 2.8, 0.4]), blade, sd=0.6)
    elif weapon == "axe":
        head = polar(hand, 20, ang)
        f.part(lambda g: g.capsule(polar(hand, -4, ang), head, 1.7), "wood", sd=0.5)
        f.part(lambda g: g.poly([polar(head, 2, ang - 90), polar(head, 12, ang - 55), polar(head, 12, ang - 135), polar(head, 2, ang - 150)]),
               blade, sd=1.2)
    elif weapon == "hammer":
        head = polar(hand, 15, ang)
        f.part(lambda g: g.capsule(polar(hand, -4, ang), head, 1.7), "wood", sd=0.5)
        f.part(lambda g: g.capsule(polar(head, 6, ang - 90), polar(head, 6, ang + 90), 5.0), blade, sd=1.6)
        f.flat(lambda g: g.line([polar(head, 6, ang - 90), polar(head, 6, ang + 90)], 1.4), trim.base, alpha=220)
    elif weapon == "claws":
        for j in (-25, 0, 25):
            f.part(lambda g, j=j: g.ribbon([polar(hand, 2, ang + j), polar(hand, 7, ang + j * 0.8), polar(hand, 11, ang + j * 0.6)],
                                           [2.0, 1.4, 0.3]), blade, sd=0.4)
    elif weapon == "spear":
        tip = polar(hand, 30, ang)
        f.part(lambda g: g.poly([polar(tip, 3, ang + 90), polar(tip, 11, ang), polar(tip, 3, ang - 90)]), blade, sd=0.8)
        f.part(lambda g: g.capsule(polar(tip, 2.5, ang + 90), polar(tip, 2.5, ang - 90), 1.3), trim, sd=0.4)
    elif weapon == "staff":
        top = polar(hand, 30, ang)
        orb = _g(spec, "orb", "#8ad8ff")
        f.part(lambda g: g.ribbon([polar(top, 4, ang + 120), polar(top, 3, ang + 60), polar(top, 6, ang), polar(top, 3, ang - 60),
                                   polar(top, 4, ang - 120)], [2, 2, 2, 2, 2]), trim, sd=0.5)
        o = polar(top, 4.5, ang)
        pulse = 1.0 + 0.12 * cyc(ph) + (0.35 if anim == "attack" and i == 1 else 0)
        f.glow(lambda g: g.circle(o[0], o[1], 7 * pulse), orb, radius=3.0, alpha=170, front=True)
        f.fx(lambda g: g.circle(o[0], o[1], 3.6 * pulse), orb)
        f.fx(lambda g: g.circle(o[0] - 1, o[1] - 1.2, 1.3), "#ffffff", alpha=220)
