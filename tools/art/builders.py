"""Bộ dựng nhân vật và quái theo tham số (AR-02, AR-03).

Mỗi builder nhận `spec` (dict tham số) và trả về danh sách hàng hoạt ảnh
[(tên, [Canvas, ...]), ...] cho pixel.sheet(). Hình luôn quay mặt sang phải;
game lật ngang khi đi sang trái.
"""
import math
from pixel import Canvas, R, OUTLINE, shadow, glow, mix, hexc

ANIMS = ("idle", "run", "attack", "hurt", "death")


def _ramp(spec, key, default):
    v = spec.get(key, default)
    return R[v] if isinstance(v, str) else v


def _darker(rmp):
    """Dải màu cho chi phía xa (tối hơn 1 bậc)."""
    return [mix(c, (0, 0, 0, 255), 0.28) for c in rmp]


def _finish(cv, outline=OUTLINE):
    cv.outline(outline)
    return cv


def _hurt(frame_fn):
    cv = frame_fn()
    shifted = Canvas(cv.w, cv.h).paste(cv, -1, 0)
    return shifted.tint((255, 70, 80, 255), 0.35)


def _death(frame_fn, pivot, direction=1):
    base = frame_fn()
    out = []
    for deg, a in ((35, 1.0), (70, 0.85), (90, 0.6)):
        out.append(base.rotated(deg * direction, pivot).fade(a))
    return out


# ====================================================================== người
HAIR_STYLES = ("ngan", "dai", "bui", "duoi")
## Tóc vẽ bằng dải xám để game tô màu (modulate) theo màu tóc người chơi chọn (C1-02).
HAIR_GREY = [(70, 70, 76, 255), (120, 120, 126, 255), (178, 178, 184, 255), (236, 236, 240, 255)]


def humanoid(spec):
    """Nhân vật hình người 32×32. spec: skin, hair, cloth, pants, boots, weapon ('sword'|'bow'),
    hood (bool), cape, collar, gender ('nam'|'nu'), hair_style (HAIR_STYLES | 'none'),
    layer: 'full' (mặc định) | 'base' (không tóc) | 'hair' (chỉ tóc, dải xám, đã khoét chỗ tay/vũ khí che)."""
    skin = _ramp(spec, "skin", "skin")
    layer = spec.get("layer", "full")
    hair = HAIR_GREY if layer == "hair" else _ramp(spec, "hair", "hair_dark")
    cloth = _ramp(spec, "cloth", "cloth_blue")
    pants = _ramp(spec, "pants", "leather")
    boots = _ramp(spec, "boots", "leather")
    cape = spec.get("cape")
    cape = R[cape] if isinstance(cape, str) else cape
    weapon = spec.get("weapon", "sword")
    hood = spec.get("hood", False) and layer == "full"
    trim = _ramp(spec, "trim", "gold")
    female = spec.get("gender", "nam") == "nu"
    style = spec.get("hair_style", "ngan")
    collar = spec.get("collar")
    collar = R[collar] if isinstance(collar, str) else collar

    def draw_hair(cv, hy):
        if style == "none":
            return
        if style == "dai":
            cv.shade_poly([(10.3, hy - 2), (15, hy - 2), (14.6, hy + 9), (12.5, hy + 10), (9.8, hy + 7.5)], hair)
        if style == "duoi":
            cv.shade_poly([(11.6, hy - 3), (13.8, hy - 1.2), (11.2, hy + 6), (8.2, hy + 8.5), (9.4, hy + 3)], hair)
        cv.shade_ellipse(15.6, hy - 2.4, 5.5, 3.0, hair)
        cv.shade_poly([(10.8, hy - 2), (14.6, hy - 2), (13.6, hy + 4), (11, hy + 3)], hair)
        cv.set(18, hy - 1, hair[1])
        cv.set(20.5, hy - 2.5, hair[2])
        if style == "bui":
            cv.shade_ellipse(13.6, hy - 6.0, 2.7, 2.3, hair)
            cv.set(13.4, hy - 4.0, hair[0])

    def frame(bob=0, legs=((0, 0), (0, 0)), arm=60, wpn=-60, draw_pull=0.0, smear=False):
        cv = Canvas(32, 32)
        b = bob
        hy = 9.5 + b
        sx, sy = 17.5, 15.5 + b
        a = math.radians(arm)
        hx, hy2 = sx + math.cos(a) * 4.5, sy + math.sin(a) * 4.5

        def draw_front(c):
            """Tay gần + vũ khí (vẽ trên đầu)."""
            if weapon == "sword":
                w = math.radians(wpn)
                tip = (hx + math.cos(w) * 12, hy2 + math.sin(w) * 12)
                if smear:
                    c.arc(sx, sy, 12, math.radians(-110), math.radians(30), (230, 240, 255, 120), 2.2)
                c.line(hx, hy2, tip[0], tip[1], R["steel"][2], 1.8)
                c.line(hx + math.cos(w) * 2, hy2 + math.sin(w) * 2 - 0.5, tip[0], tip[1] - 0.5, R["steel"][3])
                pw = w + math.pi / 2
                c.line(hx + math.cos(pw) * 2.2, hy2 + math.sin(pw) * 2.2,
                       hx - math.cos(pw) * 2.2, hy2 - math.sin(pw) * 2.2, trim[2], 1.4)
                c.set(hx - math.cos(w) * 2, hy2 - math.sin(w) * 2, trim[1])
            c.line(sx, sy, hx, hy2, cloth[2], 2.4)
            c.ellipse(hx, hy2, 1.3, 1.3, skin[2])
            if weapon == "bow":
                bx = hx + 1
                c.arc(bx - 2, hy2, 7, math.radians(-75), math.radians(75), R["wood"][2], 1.6)
                top = (bx - 2 + math.cos(math.radians(-75)) * 7, hy2 + math.sin(math.radians(-75)) * 7)
                bot = (bx - 2 + math.cos(math.radians(75)) * 7, hy2 + math.sin(math.radians(75)) * 7)
                mid = (bx - 2 - draw_pull, hy2)
                c.line(top[0], top[1], mid[0], mid[1], (230, 230, 220, 255))
                c.line(bot[0], bot[1], mid[0], mid[1], (230, 230, 220, 255))
                if draw_pull > 0:
                    c.line(mid[0], hy2, bx + 6, hy2, R["wood"][3])
                    c.set(bx + 6, hy2, R["steel"][3])

        if layer == "hair":
            draw_hair(cv, hy)
            # khoét chỗ tay/vũ khí nằm trước tóc (tính cả viền)
            mask = Canvas(32, 32)
            draw_front(mask)
            mask.outline((0, 0, 0, 255))
            for y in range(32):
                for x in range(32):
                    if mask.px[y][x] is not None and mask.px[y][x][3] >= 200:
                        cv.px[y][x] = None
            return _finish(cv)

        if not spec.get("no_shadow"):
            shadow(cv, 16, 29.5, 7, 2)
        if cape:
            cv.shade_poly([(12, 14 + b), (16, 14 + b), (14, 26 + b), (9, 25 + b)], cape)
        if weapon == "bow":
            cv.rect(10, 12 + b, 13, 20 + b, R["leather"][1])
            for i, x in enumerate((10.5, 12)):
                cv.set(x, 11 + b - i, R["steel"][3])
        (fx, fl), (nx, nl) = legs

        def leg(x0, dx, lift, rp, bp):
            top = 21 + b
            foot = 28 - lift
            cv.line(x0, top, x0 + dx, foot - 1, rp[1], 2.6)
            cv.rect(x0 + dx - 1.2, foot - 1.5, x0 + dx + 2.2, foot + 0.5, bp[1])
        leg(14.5, fx, fl, _darker(pants), _darker(boots))
        cv.line(14, 15 + b, 13 + math.cos(math.radians(arm + 40)) * 3, 19 + b, _darker(cloth)[1], 2.2)
        # thân: nữ vai hẹp hơn, vạt áo xoè
        if female:
            cv.shade_poly([(12.2, 14 + b), (19.8, 14 + b), (19.4, 19 + b), (20.8, 24 + b), (11.4, 24 + b), (12.8, 19 + b)], cloth)
            cv.rect(12.8, 19 + b, 19.4, 20 + b, trim[1])
            cv.set(16, 19 + b, trim[3])
        else:
            cv.shade_poly([(11.5, 14 + b), (20.5, 14 + b), (19.5, 22.5 + b), (12.5, 22.5 + b)], cloth)
            cv.rect(12.5, 21 + b, 19.5, 22 + b, trim[1])
            cv.set(16, 21 + b, trim[3])
        if collar:
            cv.shade_poly([(11.5, 13.5 + b), (20.5, 13.5 + b), (19, 16.5 + b), (13, 16.5 + b)], collar)
        leg(17, nx, nl, pants, boots)
        cv.shade_ellipse(16.5, hy, 5.0 if female else 5.2, 4.6 if female else 4.8, skin,
                         light=(0.35, -0.5), bands=(0.5, 0.95, 1.4))
        if hood:
            cv.shade_ellipse(15.6, hy - 2.0, 5.8, 3.6, cloth)
            cv.shade_poly([(10.5, hy - 1), (14, hy - 1), (14.5, hy + 4.5), (11, hy + 3)], cloth)
        elif layer == "full":
            draw_hair(cv, hy)
        cv.rect(18.6, hy, 19.6, hy + 1.6, (30, 24, 36, 255))   # mắt
        cv.set(18.6, hy, (255, 255, 255, 255))
        if female:
            cv.set(19.6, hy - 1, (30, 24, 36, 255))             # mi mắt
            cv.set(20.2, hy + 3, (200, 110, 110, 255))          # môi
        cv.set(20.8, hy + 2.2, skin[1])                        # mũi
        draw_front(cv)
        return _finish(cv)

    idle = [frame(0), frame(1)]
    run_legs = [((2, 0), (-2, 2)), ((0, 1), (0, 0)), ((-2, 2), (2, 0)), ((0, 0), (0, 1))]
    run = [frame(i % 2, run_legs[i], arm=50 + (i % 2) * 20) for i in range(4)]
    if weapon == "sword":
        atk = [frame(0, arm=-100, wpn=-130), frame(0, ((1, 0), (2, 0)), arm=-15, wpn=-5, smear=True),
               frame(1, ((1, 0), (2, 0)), arm=45, wpn=55)]
    else:
        atk = [frame(0, arm=0, draw_pull=2), frame(0, arm=0, draw_pull=4), frame(0, arm=0, draw_pull=0)]
    if layer == "hair":
        hurt = [Canvas(32, 32).paste(frame(0, arm=80, wpn=-20), -1, 0)]
    else:
        hurt = [_hurt(lambda: frame(0, arm=80, wpn=-20))]
    death = _death(lambda: frame(0), (16, 29))
    return [("idle", idle), ("run", run), ("attack", atk), ("hurt", hurt), ("death", death)]


# ====================================================================== thú 4 chân
def quadruped(spec):
    """Thú 4 chân (sói…). spec: size (24 hoặc 48), fur, eye (hex), mane (dải màu hoặc None), aura (hex hoặc None)."""
    size = spec.get("size", 24)
    s = size / 24.0
    fur = _ramp(spec, "fur", "fur_grey")
    far = _darker(fur)
    eye = hexc(spec.get("eye", "#ffd23c"))
    mane = spec.get("mane")
    mane = R[mane] if isinstance(mane, str) else mane
    aura = spec.get("aura")

    def frame(bob=0.0, legs=(0, 0, 0, 0), crouch=0.0, lunge=0.0, mouth=False, tail=0.0):
        cv = Canvas(size, size)
        S = lambda v: v * s
        shadow(cv, S(12), S(21.5), S(9), S(2))
        if aura:
            glow(cv, S(12), S(13), S(11), hexc(aura), 60)
        by = 13.5 + bob + crouch
        bx = 11 + lunge
        # đuôi
        cv.line(S(bx - 6), S(by - 1), S(bx - 9.5), S(by - 4 - tail), fur[1], S(2.2))
        cv.line(S(bx - 9.5), S(by - 4 - tail), S(bx - 10), S(by - 5.5 - tail), fur[3], S(1.4))
        # chân xa
        def leg(x, phase, rp):
            top = by + 2
            foot = 21 - max(0.0, phase) * 1.5
            cv.line(S(x), S(top), S(x + phase * 1.2 + lunge * 0.3), S(foot), rp[1], S(1.9))
            cv.set(S(x + phase * 1.2 + lunge * 0.3), S(foot), rp[0])
        leg(bx - 3.5, legs[0], far)
        leg(bx + 3.5, legs[2], far)
        # thân
        cv.shade_ellipse(S(bx), S(by), S(7.2 + lunge * 0.25), S(4.2 - crouch * 0.3), fur)
        cv.shade_ellipse(S(bx + 0.5), S(by + 2.2), S(5.5), S(1.4), [fur[2]] * 4)
        if mane:
            for i in range(5):
                x = bx + 2 - i * 2.2
                cv.shade_poly([(S(x - 1.4), S(by - 3)), (S(x - 0.2), S(by - 7 + i * 0.5)), (S(x + 1.2), S(by - 3))], mane)
        # chân gần
        leg(bx - 5.5, legs[1], fur)
        leg(bx + 5, legs[3], fur)
        # đầu
        hx, hy = bx + 7 + lunge * 0.4, by - 3.5 + crouch * 0.6
        cv.shade_poly([(S(hx - 1.5), S(hy - 3.2)), (S(hx - 0.2), S(hy - 6.5)), (S(hx + 1.2), S(hy - 2.8))], fur)
        cv.shade_ellipse(S(hx), S(hy), S(3.8), S(3.3), fur)
        cv.shade_poly([(S(hx + 1), S(hy - 1)), (S(hx + 6), S(hy + 0.8)), (S(hx + 5.6), S(hy + 2.6)), (S(hx + 0.8), S(hy + 2.6))], fur)
        cv.set(S(hx + 5.6), S(hy + 0.8), (30, 24, 36, 255))     # mũi
        if mouth:
            cv.line(S(hx + 1.5), S(hy + 2.6), S(hx + 5), S(hy + 3.6), (120, 20, 30, 255), S(1.2))
            cv.set(S(hx + 4), S(hy + 3), (255, 255, 255, 255))
        if aura:
            glow(cv, S(hx + 1.6), S(hy - 0.6), S(2.6), eye, 140)
        cv.rect(S(hx + 1.2), S(hy - 1.2), S(hx + 1.2) + max(1, round(s)), S(hy - 1.2) + max(1, round(s)), eye)
        return _finish(cv)

    idle = [frame(0, tail=0), frame(0.5, tail=1)]
    run = [frame(0, (1, -1, -1, 1)), frame(-0.6, (0, 0, 0, 0), tail=1), frame(0, (-1, 1, 1, -1)), frame(-0.6, (0, 0, 0, 0), tail=1)]
    atk = [frame(0, crouch=1.5), frame(-1, (1.5, 1.5, -1.5, -1.5), lunge=2.5, mouth=True), frame(0, mouth=True)]
    hurt = [_hurt(lambda: frame(0, crouch=0.5))]
    death = [frame(0, crouch=1.5).tint((0, 0, 0, 255), 0.15), frame(0, crouch=3).fade(0.8), frame(0, crouch=4).fade(0.5)]
    return [("idle", idle), ("run", run), ("attack", atk), ("hurt", hurt), ("death", death)]


# ====================================================================== nấm
def mushroom(spec):
    """Quái nấm 24×24. spec: cap, stem, spots (hex), spore (hex)."""
    cap = _ramp(spec, "cap", "mush_cap")
    stem = _ramp(spec, "stem", "mush_stem")
    spot = hexc(spec.get("spots", "#f4e8ff"))
    spore = hexc(spec.get("spore", "#c878ff"))

    def frame(squash=0.0, step=0, puff=0):
        cv = Canvas(24, 24)
        shadow(cv, 12, 21.5, 6.5, 1.8)
        # chân
        cv.rect(8.5 + step, 19.5, 10.5 + step, 21, stem[0])
        cv.rect(13.5 - step, 19.5, 15.5 - step, 21, stem[0])
        # mũ nấm
        cy = 10.5 + squash
        cv.shade_ellipse(12, cy, 8.5 + squash * 0.6, 5.2 - squash * 0.5, cap)
        cv.clear(3, cy + 2.6, 21, cy + 6)
        for (x, y, r) in ((9, cy - 2, 1.4), (14, cy - 3, 1.1), (16.5, cy - 0.5, 1.0), (7, cy + 0.5, 0.9)):
            cv.ellipse(x, y, r, r, spot)
        cv.rect(4.5, cy + 1.8, 19.5, cy + 2.6, cap[0])
        # thân + mặt
        sy = 16.8 + squash * 0.5
        cv.shade_ellipse(12, sy, 4.2 + squash * 0.4, 3.8 - squash * 0.3, stem)
        cv.rect(12, sy - 1, 13, sy + 0.6, (40, 20, 40, 255))
        cv.rect(14.5, sy - 1, 15.5, sy + 0.6, (40, 20, 40, 255))
        cv.set(13.5, sy + 1.6, (120, 40, 70, 255))
        c = _finish(cv)
        for i in range(puff):
            a = i * 2.1
            glow(c, 12 + math.cos(a) * (6 + puff), cy - 3 + math.sin(a) * 3 - puff, 1.8, spore, 200)
        return c

    idle = [frame(0), frame(0.6)]
    run = [frame(0, 1), frame(0.5, 0), frame(0, -1), frame(0.5, 0)]
    atk = [frame(1.2), frame(-0.8, puff=3), frame(0, puff=5)]
    hurt = [_hurt(lambda: frame(1.0))]
    death = [frame(1.5).fade(0.9), frame(2.5).fade(0.7), frame(3.2).fade(0.45)]
    return [("idle", idle), ("run", run), ("attack", atk), ("hurt", hurt), ("death", death)]


# ====================================================================== hồn bay
def wisp(spec):
    """Tinh linh bay 24×24. spec: body (dải màu), glow (hex)."""
    body = _ramp(spec, "body", "wisp")
    gl = hexc(spec.get("glow", "#9de0e6"))

    def frame(bob=0.0, flick=0.0, bright=0.0, scale=1.0):
        cv = Canvas(24, 24)
        shadow(cv, 12, 21.5, 4, 1.2, 60)
        cy = 11 + bob
        glow(cv, 12, cy, 9 * scale + bright * 2, gl, 70 + round(bright * 60))
        cv.shade_poly([(8.5, cy - 1), (5 - flick, cy - 7), (7.5, cy - 4.5), (9 + flick * 0.5, cy - 8.5), (11, cy - 4), (15, cy - 2), (12, cy + 4)], body)
        cv.shade_ellipse(12.5, cy + 0.5, 4.6 * scale, 4.4 * scale, body)
        cv.rect(13.5, cy - 0.5, 14.5, cy + 1.5, (20, 40, 60, 255))
        cv.rect(15.5, cy - 0.5, 16.5, cy + 1.5, (20, 40, 60, 255))
        c = _finish(cv, mix(body[0], (0, 0, 0, 255), 0.4))
        for i in range(3):
            glow(c, 7 - i * 1.5 + flick, cy + 4 + i * 1.6, 1.0, gl, 160 - i * 40)
        return c

    idle = [frame(0, 0), frame(-1, 1)]
    run = [frame(0, 0), frame(-0.5, 1), frame(-1, 2), frame(-0.5, 1)]
    atk = [frame(0, 1, 0.5, 1.05), frame(-1, 2, 1.0, 1.15), frame(0, 0, 0.3)]
    hurt = [_hurt(lambda: frame(0, 0))]
    death = [frame(0, 0, 0.5, 0.9).fade(0.8), frame(-1, 1, 0.8, 0.7).fade(0.55), frame(-2, 2, 1.0, 0.5).fade(0.3)]
    return [("idle", idle), ("run", run), ("attack", atk), ("hurt", hurt), ("death", death)]


# ====================================================================== cây tinh
def treant(spec):
    """Mộc Tinh 24×24 — thân gỗ, tán lá, mắt sáng. spec: bark, leaf, eye."""
    bark = _ramp(spec, "bark", "bark")
    leaf = _ramp(spec, "leaf", "leaf_light")
    eye = hexc(spec.get("eye", "#ffe27a"))

    def frame(bob=0.0, step=0, arm=0.0, lean=0.0):
        cv = Canvas(24, 24)
        shadow(cv, 12, 21.5, 6.5, 1.8)
        cv.line(10 + step, 18, 8.5 + step, 21, bark[1], 1.8)       # rễ
        cv.line(14 - step, 18, 15.5 - step, 21, bark[1], 1.8)
        cv.line(9, 13 + bob, 5.5 - arm, 10 + bob - arm, _darker(bark)[1], 1.6)   # cành xa
        cv.shade_poly([(9 + lean, 10 + bob), (15 + lean, 10 + bob), (15.5, 19), (8.5, 19)], bark)
        cv.line(11, 12 + bob, 11.5, 18, bark[0])
        glow(cv, 14 + lean, 13.5 + bob, 2.4, eye, 200)
        cv.rect(12.5 + lean, 12.5 + bob, 13.5 + lean, 14 + bob, eye)
        cv.rect(15 + lean, 12.5 + bob, 16 + lean, 14 + bob, eye)
        cv.set(13 + lean, 13 + bob, eye)
        cv.set(15 + lean, 13 + bob, eye)
        cv.line(15 + lean, 14 + bob, 19 + arm, 11 + bob - arm, bark[2], 1.6)    # cành gần
        cv.shade_ellipse(19.5 + arm, 10.5 + bob - arm, 1.8, 1.6, leaf)
        cv.shade_ellipse(12 + lean, 6.5 + bob, 7, 4.8, leaf)
        cv.shade_ellipse(8.5 + lean, 8 + bob, 3.5, 2.8, leaf)
        cv.set(14 + lean, 4 + bob, leaf[3])
        cv.set(10 + lean, 5 + bob, leaf[3])
        return _finish(cv)

    idle = [frame(0), frame(0.6)]
    run = [frame(0, 1), frame(0.5, 0), frame(0, -1), frame(0.5, 0)]
    atk = [frame(0, arm=-2, lean=-1), frame(0, arm=3, lean=1.5), frame(0.5, arm=1)]
    hurt = [_hurt(lambda: frame(0))]
    death = _death(lambda: frame(0), (12, 21))
    return [("idle", idle), ("run", run), ("attack", atk), ("hurt", hurt), ("death", death)]


# ====================================================================== chim
def bird(spec):
    """Chim săn 24×24 (Ưng Gió, M4.2). spec: body, wing, beak (hex), eye (hex)."""
    body = _ramp(spec, "body", "white")
    wing = _ramp(spec, "wing", "stone")
    beak = hexc(spec.get("beak", "#ffc940"))
    eye = hexc(spec.get("eye", "#ff5470"))

    def frame(flap=0.0, lift=0.0, dive=0.0):
        cv = Canvas(24, 24)
        shadow(cv, 12, 21.5, 5 + lift * 0.3, 1.4, 70)
        cy = 11 - lift + dive
        # cánh xa
        cv.shade_poly([(11, cy), (5, cy - 5 - flap * 4), (3, cy - 2 - flap * 3), (9, cy + 2)], _darker(wing))
        # thân
        cv.shade_ellipse(12, cy + 1, 5.2, 3.2, body)
        cv.shade_poly([(7, cy + 1), (3.5, cy + 3), (4, cy - 0.5)], wing)          # đuôi
        # đầu + mỏ
        cv.shade_ellipse(17, cy - 1, 2.8, 2.6, body)
        cv.shade_poly([(19, cy - 1.5), (22.5, cy), (19, cy + 0.6)], [beak] * 4)
        cv.set(17.6, cy - 1.8, eye)
        # cánh gần
        cv.shade_poly([(12, cy), (16, cy - 6 - flap * 4), (19, cy - 4 - flap * 3), (14, cy + 2)], wing)
        cv.line(10, cy + 4, 9.5, cy + 6, beak)
        cv.line(13, cy + 4, 13.5, cy + 6, beak)
        return _finish(cv)

    idle = [frame(0.0), frame(1.0)]
    run = [frame(0.0), frame(1.0), frame(0.5), frame(-0.3)]
    atk = [frame(1.0, lift=4), frame(0.6, lift=6), frame(-0.5, dive=2)]
    hurt = [_hurt(lambda: frame(0.5))]
    death = [frame(0.0, dive=2).fade(0.85), frame(0.0, dive=5).fade(0.6), frame(0.0, dive=7).fade(0.35)]
    return [("idle", idle), ("run", run), ("attack", atk), ("hurt", hurt), ("death", death)]


BUILDERS = {"humanoid": humanoid, "quadruped": quadruped, "mushroom": mushroom, "wisp": wisp, "treant": treant, "bird": bird}
