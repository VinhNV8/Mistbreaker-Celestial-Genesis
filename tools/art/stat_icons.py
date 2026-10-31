"""UI-21: icon trang Chỉ số / Nhân vật — 5 chỉ số gốc, chỉ số chiến đấu, nút Tẩy điểm / Tự cộng, huy hiệu bộ đồ.
Không có nền ô (giao diện vẽ khung). icons.py gọi register(STATS) rồi build_all() ghi ra "stat-<id>"."""
import math

from pixel import R, hexc, mix


def _star(cv, cx, cy, r_out, r_in, rmp, n=5, rot=-math.pi / 2):
    pts = []
    for i in range(n * 2):
        r = r_out if i % 2 == 0 else r_in
        a = rot + i * math.pi / n
        pts.append((cx + math.cos(a) * r, cy + math.sin(a) * r))
    cv.shade_poly(pts, rmp)


def _heart(cv, cx, cy, s, rmp):
    cv.shade_ellipse(cx - 4.5 * s, cy - 3 * s, 5.2 * s, 5.2 * s, rmp)
    cv.shade_ellipse(cx + 4.5 * s, cy - 3 * s, 5.2 * s, 5.2 * s, rmp)
    cv.shade_poly([(cx - 9.4 * s, cy - 1.5 * s), (cx + 9.4 * s, cy - 1.5 * s), (cx, cy + 10 * s)], rmp)
    cv.ellipse(cx - 6 * s, cy - 5 * s, 1.6 * s, 1.6 * s, (255, 255, 255, 200))


def _shield(cv, rmp, rim):
    cv.shade_poly([(6, 6), (16, 3), (26, 6), (25, 18), (16, 28), (7, 18)], rim)
    cv.shade_poly([(9, 8), (16, 6), (23, 8), (22, 17), (16, 24.5), (10, 17)], rmp)


# ---------------------------------------------------------------- 5 chỉ số gốc
def g_str(cv):
    """STR: nắm đấm đỏ."""
    rmp = R["cloth_red"]
    cv.shade_poly([(9, 14), (23, 12), (25, 22), (21, 28), (11, 28), (8, 22)], rmp)
    for i in range(4):
        cv.shade_ellipse(10.5 + i * 3.8, 11.5, 2.4, 3.2, rmp)
    cv.shade_poly([(6, 17), (11, 15), (13, 20), (8, 22)], rmp)
    for i in range(3):
        cv.line(12.4 + i * 3.8, 9.5, 12.4 + i * 3.8, 13.5, rmp[0])
    cv.line(10, 5, 8, 2, hexc("#ffd877"), 1.2)
    cv.line(16, 4, 16, 1, hexc("#ffd877"), 1.2)
    cv.line(22, 5, 24, 2, hexc("#ffd877"), 1.2)


def g_agi(cv):
    """AGI: giày xanh lá có cánh/vệt gió."""
    rmp = R["cloth_green"]
    for i, y in enumerate((9, 14, 19)):
        cv.line(2 + i, y, 9 + i, y, hexc("#bff5c8", 120 + i * 40), 1.2)
    cv.shade_poly([(12, 5), (19, 5), (19, 17), (27, 20), (28, 26), (11, 26), (11, 16)], rmp)
    cv.rect(10.5, 24, 28, 27, R["leather"][1])
    cv.line(12, 10, 19, 10, rmp[3])


def g_int(cv):
    """INT: sách phép xanh lam."""
    rmp = R["crystal"]
    cv.shade_poly([(6, 7), (22, 4), (26, 24), (10, 28)], rmp)
    cv.shade_poly([(9, 26), (25, 23), (26, 25), (10, 28.5)], R["white"])
    cv.line(7.5, 8, 11, 27.5, rmp[0], 1.4)
    cv.line(13, 11, 21, 9.5, rmp[3], 1.0)
    cv.line(14, 15, 22, 13.5, rmp[3], 1.0)
    _star(cv, 18, 19, 3.2, 1.3, R["gold"])


def g_vit(cv):
    """VIT: khiên vàng."""
    _shield(cv, R["gold"], R["leather"])
    cv.line(16, 8, 16, 22, R["gold"][0], 1.0)
    cv.ellipse(16, 14, 2.4, 2.4, R["blood"][2])


def g_luk(cv):
    """LUK: cỏ bốn lá tím."""
    rmp = R["purple"]
    for (x, y) in ((11.5, 11.5), (20.5, 11.5), (11.5, 20.5), (20.5, 20.5)):
        cv.shade_ellipse(x, y, 5.2, 5.2, rmp)
    cv.ellipse(16, 16, 2.2, 2.2, rmp[3])
    cv.line(19, 21, 25, 29, R["leaf"][2], 1.6)


# ---------------------------------------------------------------- chỉ số chiến đấu
def g_atk(cv):
    from icons import g_sword
    g_sword(cv, 0.95)


def g_def(cv):
    _shield(cv, R["cloth_blue"], R["steel"])
    cv.line(11, 10, 21, 10, R["cloth_blue"][3], 1.0)


def g_hp(cv):
    _heart(cv, 16, 15, 1.0, R["blood"])


def g_mp(cv):
    rmp = R["crystal"]
    cv.shade_ellipse(16, 20, 7.5, 7.5, rmp)
    cv.shade_poly([(16, 3), (22.6, 16.5), (9.4, 16.5)], rmp)
    cv.ellipse(13, 19, 1.8, 2.6, (255, 255, 255, 200))


def g_aspd(cv):
    """Tốc đánh: ba vệt gió + mũi lao."""
    for i, (y, l) in enumerate(((9, 18), (16, 24), (23, 16))):
        cv.line(4, y, 4 + l, y, hexc("#9ad7ff", 150 + i * 30), 2.2)
        cv.line(4, y, 4 + l, y, hexc("#ffffff", 220), 0.8)
    cv.arc(22, 16, 6, math.radians(-80), math.radians(80), hexc("#c8e6ff"), 1.6)


def g_crit(cv):
    _star(cv, 16, 17, 12.5, 5.2, R["gold"])
    cv.ellipse(12.5, 13, 1.4, 1.4, (255, 255, 255, 230))


def g_critdmg(cv):
    """ST chí mạng: tia nổ đỏ cam."""
    _star(cv, 16, 16, 13, 5.5, R["fire"], n=8, rot=0.2)
    _star(cv, 16, 16, 6.5, 3.0, R["blood"], n=8, rot=0.6)
    cv.ellipse(16, 16, 2.0, 2.0, (255, 245, 210, 255))


def g_eva(cv):
    """Né tránh: chiếc lá/cánh xanh lướt."""
    rmp = R["leaf_light"]
    cv.shade_poly([(5, 25), (11, 12), (22, 5), (27, 6), (23, 16), (12, 24)], rmp)
    cv.line(7, 24, 24, 7, rmp[0], 1.0)
    for i in range(3):
        cv.line(3 + i * 2, 13 + i * 5, 7 + i * 2, 12 + i * 5, hexc("#d8ffd8", 170), 1.0)


def g_regen(cv):
    """MP mỗi giây: giọt + mũi tên vòng."""
    rmp = R["crystal"]
    cv.shade_ellipse(14, 19, 6, 6, rmp)
    cv.shade_poly([(14, 6), (19.3, 17), (8.7, 17)], rmp)
    cv.arc(16, 16, 12, math.radians(-60), math.radians(60), hexc("#c4e4ff"), 1.6)
    cv.shade_poly([(25, 22), (29, 24), (24, 27)], R["white"])


def g_skill(cv):
    """Sát thương kỹ năng: tia lửa phép tím."""
    _star(cv, 16, 16, 12, 3.2, R["purple"], n=4, rot=0)
    _star(cv, 16, 16, 7, 2.2, R["white"], n=4, rot=math.pi / 4)


def g_drop(cv):
    """Rơi đồ: túi vàng."""
    cv.shade_ellipse(16, 20, 9, 8, R["leather"])
    cv.shade_poly([(11, 9), (21, 9), (19, 13), (13, 13)], R["leather"])
    cv.line(12, 13, 20, 13, R["gold"][2], 1.6)
    cv.ellipse(16, 20, 3, 3, R["gold"][3])


def g_move(cv):
    """Tốc chạy: giày nâu + vệt."""
    from icons import g_wing_boot
    g_wing_boot(cv)


def g_res(cv):
    """Kháng hệ: vòng ngũ hành."""
    for i, h in enumerate(("#e2e6ee", "#5fa84c", "#58a0f0", "#ff9a3c", "#d6a865")):
        a = -math.pi / 2 + i * 2 * math.pi / 5
        cv.shade_ellipse(16 + math.cos(a) * 9, 16 + math.sin(a) * 9, 3.6, 3.6,
                         [mix(hexc(h), (0, 0, 0, 255), 0.5), hexc(h), hexc(h), mix(hexc(h), (255, 255, 255, 255), 0.4)])


# ---------------------------------------------------------------- nút + huy hiệu
def g_respec(cv):
    """Tẩy điểm: hai mũi tên vòng."""
    c = R["gold"]
    cv.arc(16, 16, 9, math.radians(200), math.radians(340), c[2], 2.6)
    cv.arc(16, 16, 9, math.radians(20), math.radians(160), c[2], 2.6)
    cv.shade_poly([(24.5, 7), (27.5, 14), (20, 13)], c)
    cv.shade_poly([(7.5, 25), (4.5, 18), (12, 19)], c)


def g_auto(cv):
    """Tự cộng: ba nút nối nhau."""
    c = R["wood"]
    for a, b in (((16, 8), (8, 23)), ((16, 8), (24, 23)), ((8, 23), (24, 23))):
        cv.line(*a, *b, c[1], 2.0)
    for (x, y) in ((16, 8), (8, 23), (24, 23)):
        cv.shade_ellipse(x, y, 4.2, 4.2, R["leather"])


def g_set(cv):
    """Huy hiệu bộ đồ: lá lục giác xanh."""
    rmp = R["leaf_light"]
    for i in range(6):
        a = i * math.pi / 3
        cv.shade_ellipse(16 + math.cos(a) * 7, 16 + math.sin(a) * 7, 4.6, 4.6, rmp)
    cv.shade_ellipse(16, 16, 5.5, 5.5, R["leaf"])
    cv.ellipse(16, 16, 2, 2, R["gold"][3])


# ---------------------------------------------------------------- CS (docs/26): WIS, DEX
def g_wis(cv):
    """WIS: hoa sen tím nở trên giọt nước (tinh thần)."""
    rmp = R["purple"]
    cv.shade_ellipse(16, 24, 9, 3.2, R["wisp"])
    for dx, h in ((-7, 8), (7, 8), (-3.5, 11), (3.5, 11)):
        cv.shade_poly([(16 + dx * 0.4, 23), (16 + dx - 2.5, 23 - h * 0.55), (16 + dx, 23 - h), (16 + dx + 2.5, 23 - h * 0.55)], rmp)
    cv.shade_poly([(16, 23), (13, 15), (16, 8), (19, 15)], R["mush_cap"])
    cv.ellipse(16, 6, 1.6, 1.6, hexc("#e8d0ff", 230))
    cv.line(16, 2, 16, 4, hexc("#e8d0ff", 180), 1.0)


def g_dex(cv):
    """DEX: hồng tâm vàng có mũi tên cắm giữa (khéo léo, chính xác)."""
    cv.shade_ellipse(15, 17, 11, 11, R["cloth_red"])
    cv.shade_ellipse(15, 17, 7.6, 7.6, R["white"])
    cv.shade_ellipse(15, 17, 4.2, 4.2, R["gold"])
    cv.line(15, 17, 27, 5, R["wood"][2], 1.6)
    cv.shade_poly([(15, 17), (19, 15.5), (16.5, 13.5)], R["steel"])
    cv.shade_poly([(24, 4), (29, 3), (28, 8), (26, 6)], R["leaf_light"])


# ---------------------------------------------------------------- UI-26: nhãn "Thuộc tính chính"
def g_main(cv):
    """Vương miện vàng 3 chóp, đính ngọc đỏ."""
    rmp = R["gold"]
    cv.shade_poly([(5, 24), (5, 10), (11, 17), (16, 7), (21, 17), (27, 10), (27, 24)], rmp)
    cv.shade_poly([(5, 23), (27, 23), (27, 27), (5, 27)], rmp)
    for x, y in ((5, 9), (16, 6), (27, 9)):
        cv.ellipse(x, y, 1.8, 1.8, rmp[3])
    cv.shade_ellipse(16, 18, 2.4, 2.4, R["cloth_red"])


STATS = {"str": g_str, "agi": g_agi, "int": g_int, "vit": g_vit, "luk": g_luk, "wis": g_wis, "dex": g_dex,
         "atk": g_atk, "def": g_def, "hp": g_hp, "mp": g_mp, "aspd": g_aspd, "crit": g_crit, "critdmg": g_critdmg,
         "eva": g_eva, "regen": g_regen, "skill": g_skill, "drop": g_drop, "move": g_move, "res": g_res,
         "respec": g_respec, "auto": g_auto, "set": g_set, "main": g_main}


def register(target):
    target.update(STATS)
