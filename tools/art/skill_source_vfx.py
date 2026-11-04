"""AR-46: visual source assets for the first five skill vertical-slice effects.

Each skill owns three 64px frames (charge, cast, impact). These are runtime
effects, not review cards: every silhouette is drawn for its actual mechanic.
"""
import math
import os
import sys

from pixel import Canvas, OUTLINE, R, glow, hexc


HERE = os.path.dirname(os.path.abspath(__file__))


def _finish(cv):
    return cv.outline(OUTLINE).to_image()


def _dash(phase):
    cv = Canvas(64, 64)
    col = hexc("#ff6870")
    if phase == 0:
        glow(cv, 25, 38, 17, col, 100)
        cv.arc(27, 38, 15, math.radians(155), math.radians(330), col, 2.5)
        cv.line(16, 49, 35, 29, R["steel"][3], 3.0)
    elif phase == 1:
        for offset, alpha, width in ((-8, 75, 8.0), (-3, 135, 5.0), (1, 220, 2.5)):
            cv.line(5, 53 + offset, 53, 17 + offset, hexc("#ff6870", alpha), width)
        cv.line(23, 47, 57, 14, R["steel"][3], 3.0)
        cv.arc(48, 25, 16, math.radians(105), math.radians(290), hexc("#ffd6d8"), 2.5)
    else:
        glow(cv, 48, 27, 22, col, 125)
        cv.shade_ellipse(48, 29, 11, 11, R["blood"])
        for angle in range(0, 360, 45):
            a = math.radians(angle)
            cv.line(48, 29, 48 + math.cos(a) * 22, 29 + math.sin(a) * 18, hexc("#ffd6d8"), 1.8)
        cv.arc(43, 31, 22, math.radians(155), math.radians(335), col, 3.0)
    return _finish(cv)


def _bounce_arrow(phase):
    cv = Canvas(64, 64)
    pale = hexc("#dff6ff")
    gold = R["gold"][3]
    if phase == 0:
        glow(cv, 24, 35, 15, pale, 80)
        cv.line(9, 43, 37, 27, pale, 2.0)
        cv.shade_poly([(43, 23), (34, 24), (38, 31)], R["steel"])
        cv.arc(26, 34, 18, math.radians(190), math.radians(340), gold, 1.2)
    elif phase == 1:
        glow(cv, 39, 27, 22, pale, 105)
        for x, y, dx, dy in ((7, 45, 28, -18), (35, 27, 19, 17)):
            cv.line(x, y, x + dx, y + dy, pale, 2.0)
            cv.shade_poly([(x + dx + 5, y + dy - 3), (x + dx - 3, y + dy - 3), (x + dx, y + dy + 4)], R["steel"])
        cv.shade_ellipse(35, 27, 5, 5, R["white"])
    else:
        glow(cv, 49, 42, 18, gold, 115)
        cv.shade_ellipse(49, 42, 7, 7, R["gold"])
        for angle in range(0, 360, 60):
            a = math.radians(angle)
            cv.line(49, 42, 49 + math.cos(a) * 16, 42 + math.sin(a) * 13, pale, 1.4)
        cv.line(9, 20, 45, 39, hexc("#dff6ff", 140), 1.6)
    return _finish(cv)


def _meteor(phase):
    cv = Canvas(64, 64)
    fire = R["fire"][3]
    if phase == 0:
        cv.arc(35, 45, 22, 0, math.tau, hexc("#ffb35a"), 1.6)
        cv.arc(35, 45, 14, math.radians(195), math.radians(345), fire, 2.0)
        for x, y in ((22, 42), (35, 34), (48, 43)):
            cv.set(x, y, hexc("#fff0b0"))
    elif phase == 1:
        glow(cv, 35, 25, 24, fire, 120)
        cv.line(15, 5, 32, 24, hexc("#ffb35a", 145), 5.0)
        cv.shade_ellipse(37, 28, 13, 13, R["fire"])
        cv.shade_poly([(28, 24), (39, 10), (50, 25), (44, 37), (29, 35)], R["fire"])
        cv.set(33, 22, hexc("#fff0b0"))
    else:
        glow(cv, 34, 39, 29, fire, 150)
        cv.shade_ellipse(34, 39, 17, 12, R["fire"])
        for angle in range(0, 360, 30):
            a = math.radians(angle)
            cv.line(34, 39, 34 + math.cos(a) * 29, 39 + math.sin(a) * 20, hexc("#ffcf70"), 2.2)
        cv.arc(34, 43, 27, math.radians(185), math.radians(355), hexc("#9b351d"), 3.0)
    return _finish(cv)


def _hammer(phase):
    cv = Canvas(64, 64)
    steel = R["steel"][3]
    if phase == 0:
        glow(cv, 34, 31, 17, hexc("#b9d1e6"), 75)
        cv.line(22, 51, 41, 18, R["leather"][3], 5.0)
        cv.shade_poly([(32, 10), (49, 15), (46, 26), (29, 22)], R["steel"])
        cv.arc(33, 47, 18, math.radians(185), math.radians(330), hexc("#c8d6e4"), 1.5)
    elif phase == 1:
        glow(cv, 39, 39, 24, hexc("#c8d6e4"), 115)
        cv.line(27, 11, 41, 42, R["leather"][3], 6.0)
        cv.shade_poly([(31, 36), (51, 33), (54, 46), (34, 50)], R["steel"])
        cv.line(11, 53, 55, 53, hexc("#e9f4ff"), 2.0)
    else:
        glow(cv, 35, 47, 28, hexc("#b9d1e6"), 125)
        cv.shade_ellipse(35, 49, 16, 8, R["steel"])
        for angle in range(195, 346, 25):
            a = math.radians(angle)
            cv.line(35, 47, 35 + math.cos(a) * 30, 47 + math.sin(a) * 20, hexc("#e9f4ff"), 2.4)
        for x, y in ((15, 45), (24, 55), (48, 55), (57, 43)):
            cv.shade_poly([(x, y), (x + 4, y - 5), (x + 7, y + 2)], R["stone"])
    return _finish(cv)


def _dragon(phase):
    cv = Canvas(64, 64)
    cyan = R["crystal"][3]
    if phase == 0:
        glow(cv, 33, 43, 24, cyan, 95)
        cv.arc(33, 45, 22, 0, math.tau, hexc("#a8e8ff"), 1.8)
        for x in (20, 33, 46):
            cv.line(x, 49, x, 25, hexc("#dffaff", 170), 1.5)
    elif phase == 1:
        glow(cv, 35, 31, 29, cyan, 125)
        cv.shade_ellipse(34, 34, 17, 12, R["crystal"])
        cv.shade_poly([(26, 31), (11, 21), (20, 42)], R["crystal"])
        cv.shade_poly([(42, 30), (57, 16), (50, 42)], R["crystal"])
        cv.shade_poly([(39, 28), (54, 31), (43, 37)], R["white"])
        cv.line(32, 21, 36, 12, R["gold"][3], 2.0)
        cv.set(39, 31, hexc("#ffe9a0"))
    else:
        glow(cv, 37, 35, 30, cyan, 140)
        cv.shade_ellipse(37, 37, 20, 14, R["crystal"])
        cv.shade_poly([(29, 34), (8, 21), (22, 47)], R["crystal"])
        cv.shade_poly([(43, 33), (61, 19), (52, 48)], R["crystal"])
        cv.shade_poly([(43, 31), (58, 35), (45, 41)], R["white"])
        for x, y in ((24, 50), (36, 54), (49, 49)):
            cv.line(x, y, x + 3, y - 9, hexc("#dffaff"), 1.5)
    return _finish(cv)


DRAWERS = {"dash": _dash, "tennay": _bounce_arrow, "meteor": _meteor, "thietchuy": _hammer, "aulong": _dragon}


def build_all():
    out = {}
    for skill_id, draw in DRAWERS.items():
        for phase in range(3):
            image = draw(phase)
            out["fx-skill-%s-p%d" % (skill_id, phase)] = (image, [32, 52])
    return out


def main():
    sys.path.insert(0, HERE)
    from build_all import contact
    assets = build_all()
    contact("skill-source-vfx", [(asset_id, image) for asset_id, (image, _origin) in assets.items()], scale=3, cols=3)
    print("ok: %d source VFX frames" % len(assets))


if __name__ == "__main__":
    main()