"""AR-45: keyframe VFX 32x32 cho 39 kỹ năng lớp đang chạy.

Mỗi ảnh là hình nhận diện của một kỹ năng tại khoảnh khắc mạnh nhất. Runtime có
thể dùng ảnh trực tiếp hoặc tiếp tục vẽ các hiệu ứng chuyển động bằng vector.

    python tools/art/skill_vfx.py
"""
import math
import os
import sys

from pixel import Canvas, OUTLINE, R, glow, hexc, shadow


HERE = os.path.dirname(os.path.abspath(__file__))


def _new():
    return Canvas(32, 32)


def _finish(cv):
    return cv.outline(OUTLINE)


def _sword_arc(color, count=1, ring=False):
    cv = _new()
    glow(cv, 16, 16, 15, color, 90)
    for index in range(count):
        start = math.radians(-135 + index * 115 / max(1, count - 1))
        cv.arc(14, 18, 12 - index, start, start + math.radians(92), color, 2.4)
    if ring:
        cv.arc(16, 16, 12, 0, math.tau, color, 1.4)
    cv.line(12, 23, 23, 9, R["steel"][3], 2.0)
    cv.line(10, 23, 17, 26, R["gold"][2], 1.5)
    return _finish(cv)


def _sword_rain(gold=False):
    cv = _new()
    color = R["gold"][3] if gold else hexc("#ff6870")
    glow(cv, 16, 15, 15, color, 100)
    for index in range(7):
        x = 4 + index * 4
        y = 5 + (index % 3) * 3
        cv.line(x + 4, y, x - 1, y + 13, R["steel"][3], 1.4)
        cv.set(x - 1, y + 13, color)
    cv.arc(16, 22, 10, 0, math.tau, color, 1.2)
    return _finish(cv)


def _blood_burst(dash=False):
    cv = _new()
    glow(cv, 16, 16, 15, R["blood"][3], 110)
    if dash:
        for index in range(2):
            cv.line(3 + index * 7, 24 - index * 9, 23 + index * 3, 10 - index * 6, hexc("#ff5a6a", 170), 3.0)
        cv.line(16, 22, 27, 8, R["steel"][3], 1.6)
    else:
        for index in range(10):
            angle = index * math.tau / 10
            cv.line(16, 16, 16 + math.cos(angle) * 13, 16 + math.sin(angle) * 13, R["blood"][3], 1.5)
        cv.shade_ellipse(16, 16, 6, 6, R["blood"])
    return _finish(cv)


def _heaven_split():
    """Nhất Kiếm Khai Thiên: đường chém bạc xẻ trời, lõi trắng và mảnh vàng vỡ ở điểm chạm."""
    cv = _new()
    for offset, alpha, width in ((-3, 70, 5.0), (3, 100, 3.0), (0, 180, 2.0)):
        cv.line(2, 28 + offset, 30, 4 + offset, hexc("#c4e4ff", alpha), width)
    cv.line(2, 28, 30, 4, R["white"][3], 1.4)
    cv.line(5, 28, 28, 6, hexc("#ffffff"), 0.9)
    for x, y, dx, dy in ((26, 7, 4, -4), (25, 10, 5, 1), (22, 8, 1, -5), (28, 12, 3, 4)):
        cv.line(x, y, x + dx, y + dy, R["gold"][3], 1.1)
    return _finish(cv)


def _starfall():
    """Thiên Lạc Tinh Vũ: nhiều mũi tên sao rơi riêng lẻ, khác với vùng mưa tên."""
    cv = _new()
    for x, y, length in ((6, 8, 12), (15, 5, 15), (25, 10, 11), (10, 18, 8), (23, 21, 7)):
        cv.line(x - 4, y - length, x, y, hexc("#c4e4ff", 135), 1.8)
        cv.line(x - 2, y - length + 4, x, y, hexc("#ffffff"), 0.9)
        cv.shade_ellipse(x, y, 2.2, 2.2, R["white"])
        cv.line(x - 3, y, x + 3, y, R["gold"][3], 0.9)
        cv.line(x, y - 3, x, y + 3, R["gold"][3], 0.9)
    return _finish(cv)


def _five_elements():
    """Ngũ Hành Luân Chuyển: năm cầu nguyên tố quay trên một quỹ đạo bạc."""
    cv = _new()
    cv.arc(16, 16, 11, 0, math.tau, hexc("#dce6f2", 135), 1.0)
    colors = (R["white"][3], R["leaf_light"][3], R["crystal"][3], R["fire"][3], R["sand"][3])
    for index, color in enumerate(colors):
        a = math.radians(-90 + index * 72)
        x, y = 16 + math.cos(a) * 11, 16 + math.sin(a) * 11
        glow(cv, x, y, 4, color, 70)
        cv.shade_ellipse(x, y, 3.2, 3.2, [color, color, color, R["white"][3]])
        cv.set(x - 1, y - 1, hexc("#ffffff"))
    return _finish(cv)


def _divine_shield():
    """Thiên Thuẫn Giáng Thế: khiên thần hạ xuống cùng hai vòng sóng bảo hộ."""
    cv = _new()
    for r, alpha in ((14, 70), (10, 125)):
        cv.arc(16, 23, r, math.radians(190), math.radians(350), hexc("#ffe9a0", alpha), 1.4)
    glow(cv, 16, 14, 13, R["gold"][3], 90)
    cv.shade_poly([(16, 3), (25, 8), (23, 21), (16, 28), (9, 21), (7, 8)], R["white"])
    cv.shade_poly([(16, 6), (21, 10), (20, 19), (16, 24), (12, 19), (11, 10)], R["gold"])
    cv.line(16, 0, 16, 5, hexc("#ffffff"), 1.2)
    return _finish(cv)


def _qilin_descent():
    """Kỳ Lân Giáng Thế: kỳ lân trắng, sừng vàng và hỏa tinh rơi xuống."""
    cv = _new()
    glow(cv, 16, 18, 15, R["crystal"][3], 85)
    cv.shade_ellipse(15, 19, 9, 7, R["white"])
    cv.shade_poly([(18, 16), (29, 20), (20, 23)], R["white"])
    cv.shade_poly([(11, 15), (14, 3), (17, 15)], R["gold"])
    cv.line(10, 15, 6, 24, R["gold"][2], 1.5)
    cv.set(18, 17, R["crystal"][3])
    for x, y in ((5, 6), (25, 5), (28, 12)):
        cv.line(x, y - 4, x, y + 2, hexc("#fff6a0", 170), 1.0)
    return _finish(cv)


def _arrow_fan(count=3, poison=False, beam=False):
    cv = _new()
    color = hexc("#7ae07a") if poison else R["white"][3]
    glow(cv, 16, 16, 15, color, 75)
    for index in range(count):
        y = 7 + index * 18 / max(1, count - 1)
        if beam:
            cv.line(2, y, 29, y - 6, hexc("#8fd8ff", 180), 2.6)
        else:
            cv.line(4, 16, 25, y, color, 1.3)
            cv.shade_poly([(29, y), (23, y - 2.5), (24, y + 2.5)], R["steel"])
    return _finish(cv)


def _arrow_rain(large=False):
    cv = _new()
    glow(cv, 16, 17, 15, hexc("#e8f7a0"), 75)
    for index in range(8 if large else 5):
        x = 4 + index * (24 / (7 if large else 4))
        y = 3 + (index % 3) * 3
        cv.line(x + 2, y, x - 2, 24 + (index % 2) * 3, R["white"][3], 1.2)
    cv.arc(16, 25, 12, math.radians(195), math.radians(345), R["gold"][2], 1.2)
    return _finish(cv)


def _trap(net=False, field=False):
    cv = _new()
    if net:
        for index in range(5):
            p = 4 + index * 6
            cv.line(3, p, 29, p - 5, R["leather"][3], 1.0)
            cv.line(p, 3, p - 5, 29, R["leather"][2], 1.0)
        cv.arc(16, 16, 13, 0, math.tau, R["leather"][3], 1.2)
    else:
        for index in range(5 if field else 1):
            angle = index * math.tau / 5 - math.pi / 2 if field else 0
            x, y = 16 + math.cos(angle) * 9, 16 + math.sin(angle) * 8
            shadow(cv, x, y + 3, 4, 1.5)
            cv.shade_ellipse(x, y, 4, 3, R["steel"])
            cv.set(x, y - 1, hexc("#ff5a3a"))
    return _finish(cv)


def _ice(lance=False, rain=False, wave=False):
    cv = _new()
    glow(cv, 16, 16, 15, hexc("#9de0ff"), 115)
    if lance:
        cv.shade_poly([(3, 20), (26, 6), (29, 10), (8, 24)], R["crystal"])
    elif rain:
        for index in range(6):
            x, y = 5 + index * 4, 5 + (index % 2) * 4
            cv.shade_poly([(x, y), (x + 3, y + 10), (x - 2, y + 10)], R["crystal"])
    else:
        for index in range(8):
            angle = index * math.tau / 8
            x, y = 16 + math.cos(angle) * 10, 16 + math.sin(angle) * 10
            cv.line(16, 16, x, y, R["crystal"][3], 2.0 if wave else 1.4)
        cv.shade_ellipse(16, 16, 4, 4, R["crystal"])
    return _finish(cv)


def _lightning(orb=False, sky=False):
    cv = _new()
    glow(cv, 16, 16, 15, hexc("#e8d0ff"), 120)
    if orb:
        cv.shade_ellipse(16, 16, 6, 6, R["purple"])
        for index in range(5):
            angle = index * math.tau / 5
            cv.line(16, 16, 16 + math.cos(angle) * 13, 16 + math.sin(angle) * 13, hexc("#fff6a0"), 1.3)
    else:
        columns = (8, 16, 24) if sky else (16,)
        for x in columns:
            points = [(x, 2), (x - 4, 11), (x + 2, 13), (x - 3, 29)]
            for a, b in zip(points, points[1:]):
                cv.line(*a, *b, hexc("#fff6a0"), 2.0)
    return _finish(cv)


def _fire(kind="meteor"):
    cv = _new()
    glow(cv, 16, 17, 15, R["fire"][2], 120)
    if kind == "wall":
        for x in range(5, 29, 6):
            cv.shade_poly([(x - 3, 27), (x, 7 + (x % 3)), (x + 3, 27)], R["fire"])
    else:
        cv.shade_ellipse(16, 17, 10, 10, R["fire"])
        cv.shade_poly([(16, 4), (23, 15), (16, 25), (9, 15)], R["fire"])
        for index in range(4):
            angle = index * math.tau / 4
            cv.line(16, 17, 16 + math.cos(angle) * 14, 17 + math.sin(angle) * 12, R["fire"][3], 1.4)
    return _finish(cv)


def _barrier():
    cv = _new()
    glow(cv, 16, 16, 15, hexc("#b69cff"), 90)
    cv.arc(16, 18, 12, math.pi, math.tau, hexc("#c8b8ff"), 2.0)
    cv.arc(16, 18, 8, math.pi, math.tau, hexc("#ffffff", 180), 1.0)
    for x in (10, 16, 22):
        cv.line(x, 12, x, 22, hexc("#9d80ff", 150), 1.0)
    return _finish(cv)


def _summon(poison=False):
    cv = _new()
    if poison:
        for x, y, r in ((10, 19, 6), (20, 15, 7), (17, 24, 5)):
            cv.ellipse(x, y, r, r * 0.75, hexc("#7ae07a", 145))
        cv.shade_ellipse(16, 11, 3, 3, R["purple"])
    else:
        glow(cv, 16, 17, 15, R["purple"][3], 105)
        for x in (9, 16, 23):
            cv.shade_ellipse(x, 11, 3, 3, R["white"])
            cv.line(x, 14, x, 24, R["white"][2], 1.4)
        cv.arc(16, 23, 12, 0, math.tau, R["purple"][3], 1.2)
    return _finish(cv)


SKILLS = {
    "spin": lambda: _sword_arc(hexc("#ff6870"), 3, True), "dash": lambda: _sword_arc(hexc("#ff6870"), 1),
    "wave": lambda: _sword_arc(hexc("#ff6870"), 1), "kiemy": lambda: _sword_arc(hexc("#ff6870"), 1, True),
    "lientram": lambda: _sword_arc(hexc("#ff9da0"), 3), "hongkiem": lambda: _sword_arc(R["gold"][3], 1, True),
    "kiemvu": lambda: _sword_arc(hexc("#c8e6ff"), 4, True), "phikiem": lambda: _sword_rain(),
    "vankiem": lambda: _sword_rain(True), "thanhkiem": lambda: _sword_arc(R["gold"][3], 1),
    "kiemvuc": lambda: _sword_rain(), "huyetbao": lambda: _blood_burst(), "huyetanh": lambda: _blood_burst(True),
    "nhatkiem": _heaven_split,
    "rain": lambda: _arrow_rain(), "pierce": lambda: _arrow_fan(1), "lanban": lambda: _arrow_fan(3),
    "eagle": lambda: _arrow_fan(2, beam=True), "tennay": lambda: _arrow_fan(4), "trap": lambda: _trap(),
    "lienxa": lambda: _arrow_fan(5), "tendoc": lambda: _arrow_fan(1, poison=True), "thientien": lambda: _arrow_rain(True),
    "phakhong": lambda: _arrow_fan(1, beam=True), "tamlien": lambda: _arrow_fan(3), "baimin": lambda: _trap(field=True),
    "luoibay": lambda: _trap(net=True), "tinhvu": _starfall,
    "chain": lambda: _lightning(), "banglao": lambda: _ice(lance=True), "meteor": lambda: _fire(),
    "barrier": _barrier, "hoatuong": lambda: _fire("wall"), "nova": lambda: _ice(wave=True),
    "muabang": lambda: _ice(rain=True), "causam": lambda: _lightning(orb=True), "thienhoa": lambda: _fire(),
    "thienloi": lambda: _lightning(sky=True), "bangphong": lambda: _ice(wave=True),
    "trieuhoi": _summon, "khidoc": lambda: _summon(poison=True), "nguhanh": _five_elements,
    "thienthuan": _divine_shield, "kylan": _qilin_descent,
}


def build_all():
    return {"vfx-" + skill_id: (draw(), [16, 16]) for skill_id, draw in SKILLS.items()}


def register_env(out):
    out.update(build_all())


def main():
    sys.path.insert(0, HERE)
    from build_all import contact
    contact("skill-vfx", [(skill_id, image.to_image()) for skill_id, (image, _origin) in build_all().items()], scale=3, cols=13)
    print("ok: %d skill VFX" % len(SKILLS))


if __name__ == "__main__":
    main()