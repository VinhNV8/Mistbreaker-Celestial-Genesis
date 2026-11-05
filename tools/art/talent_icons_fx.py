"""IC-2 (docs/37 §7): vẽ lại 20 icon Thiên phú theo ngôn ngữ IC-1 / FX-1, HD 128×128.

    python tools/art/talent_icons_fx.py            # bản duyệt docs/design/skill-icons/thien-phu-so-sanh.png
    python tools/art/talent_icons_fx.py --apply    # ghi godot/assets/hd/icons/talent-<id>.png + manifest["hd"]["icons"]

Giữ cấu trúc huy hiệu tròn của bộ cũ (tools/art/icons.py): nền theo NHÓM Thiên phú, viền theo màu HẠNG (F xám … SSS hồng,
SS / SSS có thêm 8 sao trên viền). Biểu tượng giữa vẽ bằng dải màu + glow cộng như icon kỹ năng IC-1. Ngoài huy hiệu trong suốt.
"""
import json
import math
import os
import random
import sys

import numpy as np
from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from skill_fx_kit import Scene, hx, pal  # noqa: E402
import skill_fx_design as design  # noqa: E402
from passive_icons_fx import _heart  # noqa: E402

ROOT = os.path.dirname(os.path.dirname(HERE))
OUT = os.path.join(ROOT, "docs", "design", "skill-icons")
ASSETS = os.path.join(ROOT, "godot", "assets")
P = design.P
U, K, SIZE = 64, 4, 128
C = (32, 32)
BADGE_R = 31.0

RANK_HEX = {"F": "#9aa0a6", "C": "#f1f3f4", "B": "#5bd16a", "A": "#4a9df8", "S": "#b36bff", "SS": "#ffc940", "SSS": "#ff5470"}
GROUP_BG = {"combat": "#5a1e26", "economy": "#5a4512", "explore": "#163e4a", "craft": "#4a3220", "territory": "#2a3a1a",
            "summon": "#33204e", "magic": "#1e2c5a", "control": "#16384a", "special": "#3a0e1e"}
GOLD = pal("#fffbe8", "#ffe28a", "#e8a830", "#6a3c0c")
BLOOD = P["kk_blood"]
LEAF = P["wood"]
STEEL = P["metal"]
SHADOW = pal("#f2e8ff", "#b890ff", "#6a3ac8", "#1c0c3a")
MASK = pal("#6a3a5c", "#44203c", "#2a1226", "#ff6a98")
# vật đặc (kim loại, vàng, lá…): lõi không trắng để đọc ra chất liệu, glow chỉ điểm xuyết
STEEL_S = pal("#f4f8ff", "#c8d2e0", "#7c8aa0", "#262c3c")
GOLD_S = pal("#fff4c0", "#f2c450", "#b07818", "#3e2208")
LEAF_S = pal("#d8ffc0", "#78d860", "#2e8a30", "#0c3010")
JADE = pal("#e0fff0", "#70e8b8", "#1e9a6e", "#08362a")


def _mix(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))


def rank_pal(rank):
    c = hx(RANK_HEX[rank])
    return (_mix(c, (255, 255, 255), 0.85), _mix(c, (255, 255, 255), 0.45), c, _mix(c, (0, 0, 0), 0.62))


def _background(S, group, seed):
    """Nền huy hiệu: màu nhóm sáng ở giữa, tối dần ra viền + vài tia sáng mờ (như nền icon kỹ năng IC-1)."""
    n = U * K
    yy, xx = np.mgrid[:n, :n].astype(np.float32) / K
    d = np.sqrt((xx - 32) ** 2 + (yy - 30) ** 2) / 31.0
    bg = np.array(hx(GROUP_BG[group]), np.float32)
    inner = np.minimum(bg * 1.35 + 8, 255)
    outer = bg * 0.42
    t = np.clip(d, 0, 1)[..., None]
    rgb = inner * (1 - t) + outer * t
    rnd = random.Random(seed)
    ang = np.arctan2(yy - 30, xx - 32)
    for _ in range(5):
        a0 = rnd.uniform(-math.pi, math.pi)
        w = rnd.uniform(0.08, 0.16)
        m = np.clip(1 - np.abs(((ang - a0 + math.pi) % (2 * math.pi)) - math.pi) / w, 0, 1) * np.clip(1 - d, 0, 1)
        rgb += m[..., None] * inner * 0.18
    S.base = Image.fromarray(np.clip(rgb, 0, 255).astype(np.uint8), "RGB").convert("RGBA")


def _rim(S, rank):
    rp = rank_pal(rank)
    S.ring(C, BADGE_R - 2.2, 3.4, rp, squash=1.0, where="fx", glow=0.7)
    if rank in ("SS", "SSS"):
        for k in range(8):
            a = k * math.pi / 4 - math.pi / 2
            S.star((32 + math.cos(a) * (BADGE_R - 2.2), 32 + math.sin(a) * (BADGE_R - 2.2)), 3.2, 4, rp, glow=0.9,
                   rot=a, inner=0.4)


def badge(tid, rank, group, draw, seed=0):
    S = Scene(size=(U, U), k=K, out=(SIZE, SIZE))
    _background(S, group, seed)
    draw(S)
    S.glow *= 0.6
    _rim(S, rank)
    img = S.render().convert("RGBA")
    # cắt tròn (siêu mẫu ×4 rồi thu nhỏ cho mép mịn)
    m = Image.new("L", (SIZE * 4, SIZE * 4))
    r = BADGE_R / U * SIZE * 4
    ImageDraw.Draw(m).ellipse((SIZE * 2 - r, SIZE * 2 - r, SIZE * 2 + r, SIZE * 2 + r), fill=255)
    img.putalpha(m.resize((SIZE, SIZE), Image.LANCZOS))
    return img


# ---------------------------------------------------------------- biểu tượng (khung 64, tâm 32,32, vùng vẽ ~ bán kính 20)
def _bar(S, p0, p1, w, p, glow=1.0, tail=1.0):
    """Nét đều bề rộng (streak của kit mặc định vuốt nhọn về đuôi)."""
    S.streak(p0, p1, w, p, glow=glow, tail=tail)


def _plus(S, c, s, p):
    _bar(S, (c[0] - s, c[1]), (c[0] + s, c[1]), s * 0.55, p, glow=1.0)
    _bar(S, (c[0], c[1] - s), (c[0], c[1] + s), s * 0.55, p, glow=1.0)


def _drop(S, c, s, p, glow=1.0):
    pts = [(c[0], c[1] - s * 1.3)]
    for i in range(13):
        a = math.pi * i / 12
        pts.append((c[0] + math.cos(a) * s * 0.75, c[1] + math.sin(a) * s * 0.75))
    S.poly(pts[:1] + pts[1:][::-1][::-1], p, glow=glow)


def than_the(S):  # Thân Thể Cường Tráng: khiên + dấu cộng
    S.shield((32, 30), 16, STEEL_S, glow=0.4)
    _plus(S, (32, 31), 7.0, P["kk"])


def tay_nhanh(S):  # Tay Nhanh: tia chớp
    p = P["ts_gold"]
    S.poly([(37, 9), (20, 35), (30, 35), (25, 56), (45, 27), (34, 27), (41, 9)], p, glow=1.6)
    S.sparks((32, 32), 0.5, 10, 17, p, seed=3, size=1.2)


def may_man(S):  # May Mắn Nhỏ: cỏ bốn lá
    _bar(S, (32, 33), (40, 54), 2.4, LEAF_S, glow=0.3)
    for k in range(4):
        a = k * math.pi / 2 + math.pi / 4
        _heart_leaf(S, (32 + math.cos(a) * 10, 31 + math.sin(a) * 10), a, LEAF_S)
    S.star((32, 31), 4.5, 4, GOLD, glow=1.2)


def _heart_leaf(S, c, a, p):
    pts = []
    for i in range(24):
        t = i / 24 * math.tau
        x = 16 * math.sin(t) ** 3
        y = -(13 * math.cos(t) - 5 * math.cos(2 * t) - 2 * math.cos(3 * t) - math.cos(4 * t))
        # trái tim úp vào tâm: xoay theo hướng a
        x, y = x * 0.55, y * 0.55
        ca, sa = math.cos(a - math.pi / 2), math.sin(a - math.pi / 2)
        pts.append((c[0] + x * ca - y * sa, c[1] + x * sa + y * ca))
    S.poly(pts, p, glow=0.4)


def chan_khong(S):  # Chân Không Biết Mỏi: giày có cánh
    S.poly([(22, 18), (34, 18), (35, 40), (48, 44), (49, 52), (21, 52)], P["earth"], glow=0.6)
    _bar(S, (21, 50), (50, 50), 3.2, STEEL, glow=0.3)
    for k in range(3):
        S.crescent((16 + k * 1.5, 28 + k * 4), 10 - k * 2, math.pi * 0.95, math.pi * 1.65, 3.2, P["ice"], glow=0.9)
    _bar(S, (50, 30), (60, 30), 1.6, P["ice"], glow=0.8)
    _bar(S, (50, 37), (58, 37), 1.4, P["ice"], glow=0.8)


def _blade(S, tip, base, w, p, glow=0.5):
    """Kiếm đặc cho icon: lưỡi rộng w, chắn kiếm vàng, chuôi, núm."""
    dx, dy = tip[0] - base[0], tip[1] - base[1]
    ln = math.hypot(dx, dy)
    ux, uy = dx / ln, dy / ln
    nx, ny = -uy, ux
    S.poly([tip, (base[0] + nx * w + ux * ln * 0.12, base[1] + ny * w + uy * ln * 0.12), (base[0] + nx * w, base[1] + ny * w),
            (base[0] - nx * w, base[1] - ny * w), (base[0] - nx * w + ux * ln * 0.12, base[1] - ny * w + uy * ln * 0.12)], p, glow=glow)
    _bar(S, (base[0] + nx * w * 2.4, base[1] + ny * w * 2.4), (base[0] - nx * w * 2.4, base[1] - ny * w * 2.4), w * 0.9, GOLD_S, glow=0.3)
    grip = (base[0] - ux * ln * 0.3, base[1] - uy * ln * 0.3)
    _bar(S, base, grip, w * 0.8, P["earth"], glow=0.1)
    S.disc(grip, w * 0.9, GOLD_S, glow=0.3)


def huyet_chien(S):  # Huyết Chiến: kiếm nhỏ máu
    _blade(S, (48, 12), (24, 40), 4.2, STEEL_S)
    _bar(S, (44, 18), (30, 34), 1.8, BLOOD, glow=1.0, tail=0.0)
    for c, sz in (((46, 40), 3.8), ((52, 50), 2.8), ((40, 52), 2.4)):
        _drop(S, c, sz, BLOOD, glow=1.0)


def tho_ren(S):  # Thợ Rèn Bẩm Sinh: búa trên đe + tia lửa
    S.poly([(12, 40), (46, 40), (42, 47), (37, 47), (40, 56), (20, 56), (23, 47), (16, 47)], STEEL_S, glow=0.2)
    S.poly([(46, 40), (56, 38), (46, 45)], STEEL_S, glow=0.1)
    _bar(S, (46, 10), (28, 34), 2.6, P["earth"], glow=0.1)
    S.poly([(38, 6), (54, 18), (48, 25), (32, 13)], STEEL_S, glow=0.4)
    S.sparks((28, 38), 0.55, 14, 16, P["fire"], seed=5, size=1.4, up=True)
    S.star((28, 38), 5, 6, P["fire"], glow=1.2)


def khuu_giac(S):  # Khứu Giác Kho Báu: kính lúp soi đồng vàng
    for c in ((22, 48), (32, 50), (42, 48), (27, 43), (37, 43)):
        S.disc(c, 5, GOLD_S, glow=0.3)
    _bar(S, (38, 34), (52, 50), 4.0, P["earth"], glow=0.1)
    S.disc((28, 24), 11, pal("#e8fbff", "#a8e6ff", "#4aa8d8", "#123a5a"), glow=0.3, alpha=150)
    S.ring((28, 24), 12, 3.4, GOLD_S, squash=1.0, where="fx", glow=0.4)
    S.star((24, 20), 3.5, 4, pal("#ffffff", "#ffffff", "#e8f8ff", "#80a0c0"), glow=0.8)


def kiem_tam(S):  # Kiếm Tâm: kiếm dựng giữa vòng khí
    p = P["kk_god"]
    S.crescent((32, 33), 20, 0.2, 2.9, 3.0, p, glow=0.8)
    S.crescent((32, 33), 20, 3.4, 6.1, 3.0, p, glow=0.8)
    _blade(S, (32, 8), (32, 44), 4.4, STEEL_S)
    S.star((32, 9), 6, 8, p, glow=1.5)


def thao_duoc(S):  # Nhà Thảo Dược: bình thuốc + lá
    S.disc((32, 40), 13, pal("#ffffff", "#e6f2f8", "#a9bccd", "#3a4a5a"), glow=0.2, alpha=180)
    S.disc((32, 42), 10.5, pal("#ffe8ec", "#ff7a8a", "#d8263a", "#5a0814"), glow=1.0)
    S.poly([(27, 18), (37, 18), (37, 28), (27, 28)], pal("#ffffff", "#e6f2f8", "#a9bccd", "#3a4a5a"), glow=0.2)
    S.poly([(26, 14), (38, 14), (37, 19), (27, 19)], P["earth"], glow=0.1)
    S.poly([(38, 20), (52, 8), (54, 22), (42, 26)], LEAF, glow=0.9)
    _bar(S, (38, 22), (51, 11), 0.9, pal("#ffffff", "#e8ffd0", "#b0e070", "#305010"), glow=0.2)


def trai_tim(S):  # Trái Tim Lãnh Chúa: tim đội vương miện
    _heart(S, (32, 38), 15, P["kk"])
    S.poly([(20, 22), (24, 12), (28, 19), (32, 9), (36, 19), (40, 12), (44, 22)], GOLD, glow=1.2)
    for x in (24, 32, 40):
        S.disc((x, 12 if x != 32 else 9), 1.8, P["ice"], glow=1.0)


def thuan_thu(S):  # Thuần Thú Sư: dấu chân thú
    p = P["th"] if "th" in P else P["earth"]
    S.disc((32, 40), 10, p, glow=1.0)
    for x, y in ((20, 26), (27, 18), (37, 18), (44, 26)):
        S.disc((x, y), 5, p, glow=1.0)


def mat_ung(S):  # Mắt Ưng: mắt ưng vàng + vệt cánh
    S.crescent((32, 32), 22, math.pi * 1.1, math.pi * 1.9, 5, P["ts"], glow=0.8)
    S.poly([(10, 32), (22, 22), (42, 22), (54, 32), (42, 42), (22, 42)], pal("#ffffff", "#f6fbff", "#c8d6e6", "#3a4a5a"), glow=0.4)
    S.disc((32, 32), 9, P["ts_gold"], glow=1.3)
    S.disc((32, 32), 4, pal("#3a2a10", "#1a1206", "#0a0602", "#000000"), glow=0.0)
    S.disc((29, 29), 1.6, pal("#ffffff", "#ffffff", "#ffffff", "#c0c0c0"), glow=0.6)


def hap_huyet(S):  # Hấp Huyết: răng nanh + giọt máu
    w = pal("#ffffff", "#f8f4f0", "#d8ccc0", "#5a4a40")
    S.crescent((32, 14), 20, math.pi * 0.15, math.pi * 0.85, 5, BLOOD, glow=0.6)
    S.poly([(20, 22), (28, 22), (24, 44)], w, glow=0.6)
    S.poly([(36, 22), (44, 22), (40, 44)], w, glow=0.6)
    _drop(S, (24, 50), 3.2, BLOOD, glow=1.3)
    _drop(S, (40, 52), 2.6, BLOOD, glow=1.3)


def ban_tay_vang(S):  # Bàn Tay Vàng: bàn tay vàng toả tiền
    S.poly([(20, 34), (44, 34), (46, 48), (40, 58), (24, 58), (19, 46)], GOLD_S, glow=0.5)
    for x0, top in ((23, 18), (29, 14), (35, 14), (41, 18)):
        _bar(S, (x0, 36), (x0, top), 5.0, GOLD_S, glow=0.5)
    _bar(S, (20, 44), (12, 34), 5.0, GOLD_S, glow=0.5)
    for c in ((12, 16), (50, 10), (54, 24)):
        S.disc(c, 4, GOLD, glow=1.0)


def ngu_hanh(S):  # Ngũ Hành Linh Căn: 5 cầu ngũ hành quanh tâm
    keys = ["metal", "wood", "ice", "fire", "earth"]
    pts = []
    for k, key in enumerate(keys):
        a = -math.pi / 2 + k * math.tau / 5
        pts.append((32 + math.cos(a) * 16, 33 + math.sin(a) * 16))
    for i in range(5):
        _bar(S, pts[i], pts[(i + 2) % 5], 0.9, P["arcane"], glow=0.7)
    for c, key in zip(pts, keys):
        S.orb(c, 5.5, P[key], glow=1.3)
    S.star((32, 33), 4, 6, P["arcane"], glow=1.4)


def thoi_gian(S):  # Thời Gian Ngưng Đọng: đồng hồ cát giữa vòng số
    p = P["ice"]
    S.ring((32, 32), 22, 2.2, p, squash=1.0, where="fx", glow=0.8)
    for k in range(12):
        a = k * math.pi / 6
        _bar(S, (32 + math.cos(a) * 18, 32 + math.sin(a) * 18), (32 + math.cos(a) * 21, 32 + math.sin(a) * 21), 1.0, p, glow=0.4)
    S.poly([(22, 14), (42, 14), (33, 32), (42, 50), (22, 50), (31, 32)], pal("#ffffff", "#f0f8ff", "#b8d4e8", "#3a5a7a"), glow=0.5, alpha=200)
    S.poly([(25, 17), (39, 17), (32, 29)], GOLD, glow=1.0)
    S.poly([(32, 38), (39, 47), (25, 47)], GOLD, glow=1.0)
    _bar(S, (20, 13), (44, 13), 2.0, P["earth"], glow=0.2)
    _bar(S, (20, 51), (44, 51), 2.0, P["earth"], glow=0.2)


def bay_dan(S, silhouette):  # Bầy Đàn Bóng Tối: bầy sói bóng
    silhouette(S, "wolf", (20, 50), 20, SHADOW, glow=1.0)
    silhouette(S, "wolf", (44, 50), 20, SHADOW, glow=1.0)
    silhouette(S, "wolf", (32, 46), 28, SHADOW, glow=1.4)


def thien_menh(S):  # Thiên Mệnh Khai Giới: la bàn sao
    S.ring((32, 32), 19, 2.6, GOLD_S, squash=1.0, where="fx", glow=0.5)
    S.star((32, 32), 22, 4, GOLD_S, glow=0.7, inner=0.22)
    S.star((32, 32), 13, 4, P["kk_god"], glow=0.7, inner=0.3, rot=math.pi / 4)
    S.poly([(32, 12), (35, 32), (29, 32)], P["kk"], glow=0.6)
    S.disc((32, 32), 3, GOLD, glow=1.2)


def long_mach(S):  # Long Mạch: rồng cuộn quanh ngọc
    p = JADE
    pts = []
    for i in range(30):
        t = i / 29
        a = t * math.pi * 2.2 - math.pi * 0.35
        r = 19 - t * 7
        pts.append((32 + math.cos(a) * r, 34 + math.sin(a) * r * 0.9))
    for i in range(len(pts) - 1):
        _bar(S, pts[i], pts[i + 1], 6.0 - i * 0.12, p, glow=0.35)
    for i in range(2, len(pts) - 2, 3):
        S.disc(pts[i], 1.0, GOLD, glow=0.6)
    hx0, hy0 = pts[0]
    S.poly([(hx0 - 6, hy0 - 4), (hx0 + 3, hy0 - 9), (hx0 + 12, hy0 - 4), (hx0 + 9, hy0 + 3), (hx0 - 2, hy0 + 5)], p, glow=0.5)
    S.disc((hx0 + 4, hy0 - 4), 1.5, GOLD, glow=1.4)
    _bar(S, (hx0 - 2, hy0 - 6), (hx0 - 6, hy0 - 15), 1.4, GOLD_S, glow=0.4)
    _bar(S, (hx0 + 2, hy0 - 8), (hx0 + 2, hy0 - 16), 1.4, GOLD_S, glow=0.4)
    S.orb((32, 34), 5, GOLD, glow=1.4)


def dao_tac(S):  # Đạo Tặc: mặt nạ đạo tặc, mắt rực
    S.poly([(6, 26), (18, 18), (32, 23), (46, 18), (58, 26), (54, 40), (40, 42), (32, 35), (24, 42), (10, 40)], MASK, glow=0.4)
    for x in (21, 43):
        S.poly([(x - 8, 30), (x, 26), (x + 8, 30), (x, 34)], pal("#ffffff", "#fff4b0", "#ffd040", "#806010"), glow=1.6)
    _bar(S, (52, 34), (60, 50), 2.4, MASK, glow=0.3)
    _bar(S, (12, 34), (6, 50), 2.4, MASK, glow=0.3)


TALENTS = [
    ("than-the", "F", "combat", than_the), ("tay-nhanh", "F", "combat", tay_nhanh),
    ("may-man", "F", "economy", may_man), ("chan-khong", "F", "explore", chan_khong),
    ("huyet-chien", "C", "combat", huyet_chien), ("tho-ren", "C", "craft", tho_ren),
    ("khuu-giac", "C", "explore", khuu_giac), ("kiem-tam", "B", "combat", kiem_tam),
    ("thao-duoc", "B", "craft", thao_duoc), ("trai-tim", "B", "territory", trai_tim),
    ("thuan-thu", "A", "summon", thuan_thu), ("mat-ung", "A", "explore", mat_ung),
    ("hap-huyet", "A", "combat", hap_huyet), ("ban-tay-vang", "A", "economy", ban_tay_vang),
    ("ngu-hanh", "S", "magic", ngu_hanh), ("thoi-gian-ngung-dong", "S", "control", thoi_gian),
    ("bay-dan", "S", "summon", bay_dan), ("thien-menh", "SS", "explore", thien_menh),
    ("long-mach", "SS", "territory", long_mach), ("dao-tac", "SSS", "special", dao_tac),
]


def build():
    """{"talent-<id>": ảnh RGBA 128×128}."""
    import skill_icons_fx  # bóng sói từ sprite thật (chỉ lấy dáng)
    out = {}
    for n, (tid, rank, group, fn) in enumerate(TALENTS):
        draw = (lambda S, fn=fn: fn(S, skill_icons_fx.silhouette)) if fn is bay_dan else fn
        out["talent-" + tid] = badge(tid, rank, group, draw, seed=200 + n)
    return out


def review(icons, path=None):
    S2 = 96
    m = json.load(open(os.path.join(ASSETS, "art_manifest.json"), encoding="utf-8"))["icons"]
    sheet = Image.new("RGB", (10 * (S2 + 8) + 8, 4 * (S2 + 22) + 30), (14, 16, 26))
    d = ImageDraw.Draw(sheet)
    d.text((8, 4), "Thien phu - hang 1/3: icon cu, hang 2/4: IC-2", fill=(235, 235, 240))
    for i, (k, img) in enumerate(icons.items()):
        row, col = divmod(i, 10)
        x, y = 8 + col * (S2 + 8), 22 + row * 2 * (S2 + 22)
        old = Image.open(m[k].replace("res://", os.path.join(ROOT, "godot") + "/")).convert("RGBA").resize((S2, S2), Image.NEAREST)
        sheet.paste(old, (x, y), old)
        new = img.resize((S2, S2), Image.LANCZOS)
        sheet.paste(new, (x, y + S2 + 4), new)
        d.text((x, y + 2 * S2 + 6), k[7:][:15], fill=(120, 170, 255))
    sheet.save(path or os.path.join(OUT, "thien-phu-so-sanh.png"))


def apply(icons):
    dst = os.path.join(ASSETS, "hd", "icons")
    os.makedirs(dst, exist_ok=True)
    path = os.path.join(ASSETS, "art_manifest.json")
    m = json.load(open(path, encoding="utf-8"))
    hd = m.setdefault("hd", {}).setdefault("icons", {})
    for k, img in icons.items():
        img.save(os.path.join(dst, k + ".png"), optimize=True)
        hd[k] = "res://assets/hd/icons/%s.png" % k
    with open(path, "w", encoding="utf-8", newline=chr(10)) as f:
        json.dump(m, f, ensure_ascii=False, indent=1)


if __name__ == "__main__":
    icons = build()
    out = None
    for a in sys.argv:
        if a.startswith("--out="):
            out = a[6:]
    review(icons, out)
    if "--apply" in sys.argv:
        apply(icons)
    print("ok: %d icon Thien phu%s" % (len(icons), " (applied)" if "--apply" in sys.argv else ""))
