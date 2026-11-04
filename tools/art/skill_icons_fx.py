"""IC-1 (docs/37): vẽ lại 51 icon kỹ năng (thanh kỹ năng) theo ngôn ngữ FX-1, HD 128×128.

    python tools/art/skill_icons_fx.py            # bản duyệt docs/design/skill-icons
    python tools/art/skill_icons_fx.py --apply    # (sau khi duyệt) ghi godot/assets/hd/icons + lớp phủ manifest["hd"]["icons"]

Giữ nguyên 19 icon vẽ tay của chủ dự án (cắt từ class-skills.png, tools/art/class_skill_icons.py). 51 icon còn lại vẽ
cùng phong cách với 19 icon đó: tranh vuông kín ô, nền tối toả màu của kỹ năng, hình chính sáng rực giữa ô (dải màu +
glow cộng của FX-1), bóng linh thú lấy từ sprite thật (chỉ lấy dáng, không vẽ lại sprite).
"""
import json
import math
import os
import random
import re
import sys

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from skill_fx_kit import Scene, hx, pal, sprite_frame  # noqa: E402
import skill_fx_design as design  # noqa: E402
import passive_icons_fx  # noqa: E402

ROOT = os.path.dirname(os.path.dirname(HERE))
OUT = os.path.join(ROOT, "docs", "design", "skill-icons")
ASSETS = os.path.join(ROOT, "godot", "assets")
P = design.P
U = 64          # khung thiết kế icon (đơn vị)
K = 4           # vẽ ×4 → 256 px rồi thu về 128 px
SIZE = 128
C = (32, 32)


def owner_icons():
    """Icon kỹ năng cắt từ ảnh chủ dự án (giữ nguyên)."""
    src = open(os.path.join(HERE, "class_skill_icons.py"), encoding="utf-8").read()
    return set(re.findall(r'"([a-z0-9]+)"', src))


def skill_icon_ids():
    src = open(os.path.join(ROOT, "godot", "scripts", "data", "classes.gd"), encoding="utf-8").read()
    return dict(re.findall(r'\{"id": "([a-z0-9_]+)".*?"icon": "([a-z0-9_]+)"', src))


# ---------------------------------------------------------------- nền và hoàn thiện
def _background(S, p, seed=0, rays=True):
    """Nền vuông tối toả màu (giữa: pha giữa màu bão hoà và viền tối; mép: gần đen) + tia sáng chéo mờ."""
    n = U * K
    yy, xx = np.mgrid[:n, :n].astype(np.float32) / K
    d = np.sqrt((xx - 32) ** 2 + (yy - 30) ** 2) / 40.0
    mid = np.array(p[2], np.float32)
    deep = np.array(p[3], np.float32)
    inner = mid * 0.55 + deep * 0.45
    outer = deep * 0.28
    t = np.clip(d, 0, 1)[..., None]
    rgb = inner * (1 - t) + outer * t
    if rays:
        rnd = random.Random(seed)
        ang = np.arctan2(yy - 30, xx - 32)
        for _ in range(5):
            a0 = rnd.uniform(-math.pi, math.pi)
            w = rnd.uniform(0.08, 0.16)
            m = np.clip(1 - np.abs(((ang - a0 + math.pi) % (2 * math.pi)) - math.pi) / w, 0, 1) * np.clip(1 - d, 0, 1)
            rgb += m[..., None] * mid * 0.22
    S.base = Image.fromarray(np.clip(rgb, 0, 255).astype(np.uint8), "RGB").convert("RGBA")


def _finish(img):
    """Viền trong tối nhẹ (vignette góc) giống icon vẽ tay."""
    a = np.asarray(img, np.float32)
    n = a.shape[0]
    yy, xx = np.mgrid[:n, :n].astype(np.float32) / n
    edge = np.minimum(np.minimum(xx, 1 - xx), np.minimum(yy, 1 - yy))
    v = np.clip(edge / 0.07, 0, 1) * 0.45 + 0.55
    a = a * v[..., None]
    return Image.fromarray(np.clip(a, 0, 255).astype(np.uint8), "RGB")


def icon(p, draw, seed=0, rays=True):
    S = Scene(size=(U, U), k=K, out=(SIZE, SIZE))
    _background(S, p, seed, rays)
    draw(S)
    return _finish(S.render())


def silhouette(S, sid, foot, height, p, glow=1.2, anim="idle", frame=0):
    """Bóng linh thú từ sprite thật (chỉ lấy dáng): thân rất tối, viền sáng sắc phía trên trái, glow chỉ toả ra NGOÀI
    bóng (giống icon Sói Bóng vẽ tay) — không vẽ lại sprite."""
    img, org = sprite_frame(sid, anim, frame)
    a = img.split()[-1]
    sc = height * K / img.height
    big = a.resize((max(1, int(img.width * sc)), max(1, int(img.height * sc))), Image.LANCZOS)
    big = big.filter(ImageFilter.GaussianBlur(K * 0.6)).point(lambda v: 255 if v > 110 else 0)
    w, h = big.size
    x0, y0 = int(foot[0] * K - org[0] * sc), int(foot[1] * K - org[1] * sc)
    full = Image.new("L", S.fx.size)
    full.paste(big, (x0, y0))
    m = np.asarray(full, np.float32) / 255.0
    gl = np.asarray(full.filter(ImageFilter.GaussianBlur(K * 3.5)), np.float32) / 255.0
    gl = np.where(gl > 0.25, 0.7, np.where(gl > 0.08, 0.35, 0.0)) * (1.0 - m)
    S.glow *= (1.0 - m)[..., None]  # glow của nền / cột sáng không phủ lên bóng
    S.glow += gl[..., None] * np.array(p[2], np.float32) * glow
    er = full.filter(ImageFilter.MinFilter(9))
    sh = Image.new("L", S.fx.size)
    sh.paste(er, (K, K))
    rim = np.clip(np.asarray(full, np.int16) - np.asarray(sh, np.int16), 0, 255).astype(np.uint8)
    body = Image.new("RGBA", S.fx.size, tuple(int(v * 0.3) for v in p[3]) + (255,))
    S.fx.paste(body, (0, 0), full)
    S.fx.paste(Image.new("RGBA", S.fx.size, p[1] + (255,)), (0, 0), Image.fromarray(rim))
    eye = (foot[0] + (height * 0.12), foot[1] - height * 0.62)
    S.disc(eye, 1.3, p, glow=1.0)


def gp(a, sq=0.55):
    return (math.cos(a), math.sin(a) * sq)


# ---------------------------------------------------------------- 51 icon
def _spin(S):
    p = P["kk"]
    for b in range(3):
        a = b * math.tau / 3 + 0.4
        S.crescent((32, 34), 20, a, a + 1.7, 9, p, squash=0.62)
    S.disc((32, 34), 5, p, glow=1.6)
    S.sparks((32, 34), 0.35, 10, 26, p, seed=2)


def _dash(S):
    p = P["kk"]
    for off, w in ((-6, 5), (0, 9), (6, 4)):
        S.streak((6 + off, 58 - off), (44 + off, 20 - off), w, p, tail=0.1)
    S.sword((46, 18), -math.pi / 4, 26, p, glow=1.2)
    S.star((48, 16), 9, 6, p, glow=1.2)


def _hongkiem(S):
    p = P["kk"]
    S.star((32, 32), 15, 12, p, glow=1.8)
    for k in range(8):
        a = k * math.tau / 8 + 0.2
        S.sword((32 + math.cos(a) * 22, 32 + math.sin(a) * 22), a, 13, p, glow=0.6)


def _kiemvu(S):
    p = P["kk"]
    for k in range(4):
        a = k * math.tau / 4 + 0.6
        q = (32 + math.cos(a) * 17, 32 + math.sin(a) * 17)
        S.crescent((32, 32), 17, a - 1.2, a - 0.1, 5, p, glow=0.5, alpha=200)
        S.sword(q, a + math.pi / 2, 30, p, glow=1.3)
    S.disc((32, 32), 4, p, glow=1.4)


def _phikiem(S):
    p = P["kk"]
    for k, da in enumerate((-0.38, 0.0, 0.38)):
        a = -math.pi / 4 + da
        tip = (12 + math.cos(a) * 44, 52 + math.sin(a) * 44)
        S.streak((12, 52), (12 + math.cos(a) * 30, 52 + math.sin(a) * 30), 4, p, alpha=170, glow=0.6)
        S.sword(tip, a, 24, p, glow=1.2)


def _thanhkiem(S):
    p = P["kk_holy"]
    S.streak((4, 60), (60, 6), 14, p, tail=0.6, glow=1.2)
    S.sword((34, 30), -math.pi / 4, 44, p, glow=1.6)
    S.star((50, 14), 8, 8, p, glow=1.3)


def _kiemvuc(S):
    p = P["kk_holy"]
    S.ring((32, 44), 24, 2.4, p, where="fx")
    for k in range(7):
        a = k * math.tau / 7 + 0.3
        S.sword((32 + math.cos(a) * 22, 40 + math.sin(a) * 12), math.pi / 2, 14, p, glow=0.6)
    S.sword((32, 24), math.pi / 2, 30, p, glow=1.6)


def _huyetbao(S):
    p = P["kk_blood"]
    S.star((32, 32), 18, 10, p, glow=1.9)
    S.ring((32, 32), 24, 3, p, squash=1.0, where="fx")
    for k in range(6):
        a = k * math.tau / 6 + 0.5
        S.orb((32 + math.cos(a) * 25, 32 + math.sin(a) * 25), 3, p, glow=0.9)


def _huyetanh(S):
    p = P["kk_blood"]
    S.streak((2, 50), (30, 36), 6, p, alpha=150, tail=0.2)
    S.crescent((34, 30), 20, -2.4, -0.7, 10, p)
    S.crescent((34, 30), 20, 0.7, 2.4, 10, p)
    S.star((34, 30), 8, 6, p, glow=1.4)


def _nhatkiem(S):
    p = P["kk_god"]
    S.streak((0, 64), (64, 0), 20, p, tail=1.0, glow=1.6)
    S.sword((30, 34), -math.pi / 4, 40, p, glow=1.4)
    for k in range(3):
        S.crescent((18 + k * 14, 46 - k * 14), 7, -2.4, -0.7, 4, p, glow=0.6)


def _eagle(S):
    p = P["ts_gold"]
    S.crescent((24, 34), 22, math.radians(190), math.radians(265), 9, p)
    S.crescent((40, 34), 22, math.radians(275), math.radians(350), 9, p)
    d = S.draw("fx")
    d.ellipse((18, 26, 46, 40), fill=p[3] + (255,))
    d.ellipse((20, 27.5, 44, 38.5), fill=p[1] + (255,))
    S.disc((32, 33), 5.5, P["ts"], glow=1.4)
    d.ellipse((30, 31, 34, 35), fill=(20, 20, 20, 255))
    S.glow_dot((32, 33), 18, p[2], 0.8)


def _tennay(S):
    p = P["ts"]
    pts = [(8, 48), (24, 22), (40, 44), (56, 16)]
    for a, b in zip(pts, pts[1:]):
        S.streak(a, b, 3, p, alpha=200, glow=0.7)
    for q in pts[1:-1]:
        S.star(q, 6, 6, p, glow=1.0)
    S.arrow((58, 12), -1.1, 14, p, trail=8)


def _trap(S):
    p = P["ts_trap"]
    S.disc((32, 42), 16, p, squash=0.55, where="fx")
    for k in range(7):
        x = 14 + k * 6
        h = 18 - abs(k - 3) * 3
        S.poly([(x - 3, 44), (x, 44 - h), (x + 3, 44)], P["ts_trap"], glow=0.6)
    S.glyph((32, 52), "chain", 4, P["ts"])


def _lienxa(S):
    p = P["ts"]
    for k in range(4):
        y = 14 + k * 11
        S.arrow((50 - k * 3, y), 0.0, 14, p, trail=18 + k * 4)
    S.star((56, 30), 7, 5, p, glow=1.1)


def _tendoc(S):
    p = P["ts_poison"]
    S.arrow((48, 20), -math.pi / 4, 18, p, trail=26)
    for k, (x, y, r) in enumerate(((22, 44, 7), (34, 50, 5), (14, 34, 4), (42, 40, 4))):
        S.disc((x, y), r, p, glow=0.6, alpha=210)
    S.glyph((46, 48), "poison", 7, p)


def _phakhong(S):
    p = P["ts_star"]
    S.streak((2, 40), (62, 22), 9, p, tail=0.4, glow=1.4)
    for k in range(3):
        S.ring((18 + k * 9, 36 - k * 3), 6 + k * 4, 1.5, p, squash=1.6, where="fx", alpha=220)
    S.arrow((58, 23), -0.29, 14, p)
    S.star((58, 23), 8, 8, p, glow=1.3)


def _tamlien(S):
    for k, key in enumerate(("ts", "ts_gold", "ts_star")):
        y = 18 + k * 13
        S.arrow((54, y), 0.0, 16, P[key], trail=30)


def _baimin(S):
    p = P["ts_trap"]
    for k in range(5):
        a = k * math.tau / 5 - 0.6
        q = (32 + math.cos(a) * 20, 36 + math.sin(a) * 12)
        S.disc(q, 5, p, glow=0.6)
        S.disc((q[0], q[1] - 1.5), 2, (p[0], p[1], (255, 60, 40), p[3]), glow=1.0)
    S.star((32, 32), 13, 10, p, glow=1.6)


def _luoibay(S):
    p = P["ts"]
    d = S.draw("fx")
    for k in range(-4, 5):
        d.line((32 - 24, 30 + k * 3.5 - 6, 32 + 24, 30 + k * 3.5 + 6), fill=p[1] + (230,), width=1)
        d.line((32 + k * 6, 10, 32 + k * 6 - 4, 54), fill=p[1] + (230,), width=1)
    S.ring((32, 34), 24, 2, p, where="fx")
    S.glyph((32, 54), "chain", 4, p)
    S.glow_dot((32, 32), 22, p[2], 0.5)


def _tinhvu(S):
    p = P["ts_star"]
    S.ring((32, 48), 20, 2, p, where="fx")
    for k, (x, y) in enumerate(((18, 30), (34, 20), (48, 36), (26, 46))):
        S.streak((x + 14, y - 22), (x, y), 4, p, alpha=200)
        S.star((x, y), 6, 4, p, glow=1.3, rot=k)
    for k in range(6):
        S.star((8 + k * 10, 6 + (k % 2) * 4), 1.6, 4, p, glow=0.6)


def _meteor(S):
    p = P["fire"]
    S.ring((36, 50), 18, 2.2, p, where="fx")
    S.streak((4, 4), (34, 38), 16, p, tail=0.1)
    S.disc((36, 40), 9, p, glow=1.8)
    S.sparks((36, 44), 0.3, 10, 18, p, seed=3)


def _barrier(S):
    p = P["arcane"]
    S.dome((32, 46), 24, p, 1.4, crack=0, alpha=210)
    S.glow_dot((32, 32), 20, p[2], 0.6)
    S.star((32, 28), 6, 6, p, glow=1.1)


def _hoatuong(S):
    p = P["fire"]
    for k in range(5):
        x = 10 + k * 11
        h = 26 + 10 * abs(math.sin(k * 1.7))
        y = 52 - abs(k - 2) * 2
        S.poly([(x - 6, y), (x - 2, y - h * 0.7), (x, y - h), (x + 3, y - h * 0.6), (x + 6, y)], p, glow=1.1)
    S.sparks((32, 24), 0.4, 10, 20, p, seed=5, up=True)


def _nova(S):
    p = P["ice"]
    S.ring((32, 42), 22, 2.5, p, where="fx")
    for k in range(9):
        a = k * math.tau / 9 + 0.2
        b = (32 + math.cos(a) * 20, 42 + math.sin(a) * 11)
        S.poly([(b[0] - 3, b[1]), (b[0] + 1, b[1] - 16), (b[0] + 3, b[1])], p, glow=0.8)
    S.star((32, 34), 10, 8, p, glow=1.7)


def _muabang(S):
    p = P["ice"]
    S.ring((32, 50), 20, 2, p, where="fx")
    for k, (x, y) in enumerate(((18, 18), (32, 30), (46, 16), (24, 40), (42, 42))):
        S.shard((x, y), math.pi / 2, 14, p)
    S.sparks((32, 50), 0.3, 8, 14, p, seed=2)


def _causam(S):
    p = P["bolt"]
    for k in range(5):
        a = k * math.tau / 5 + 0.3
        S.bolt((32, 32), (32 + math.cos(a) * 28, 32 + math.sin(a) * 28), p, seed=k, w=1.6, branches=1, jag=3)
    S.orb((32, 32), 11, p, glow=1.8)


def _thienloi(S):
    p = P["bolt"]
    S.ring((32, 54), 14, 2, p, where="fx")
    S.bolt((36, -2), (32, 52), p, seed=4, w=3.2, branches=3, jag=6)
    S.bolt((18, -2), (16, 40), p, seed=8, w=1.6, branches=1, jag=4)
    S.star((32, 52), 9, 8, p, glow=1.4)


def _bangphong(S):
    p = P["ice"]
    for k in range(6):
        a = k * math.pi / 3
        S.streak((32, 32), (32 + math.cos(a) * 26, 32 + math.sin(a) * 26), 4, p, tail=1.0, glow=0.8)
    S.star((32, 32), 14, 12, p, glow=1.8)
    S.ring((32, 32), 26, 2, p, squash=1.0, where="fx", alpha=200)


def _trieuhoi(S):
    p = P["necro"]
    S.ring((32, 56), 18, 2.2, p, where="fx")
    S.pillar((32, 58), 24, 54, p, alpha=90)
    silhouette(S, "xuong-no", (32, 56), 40, p)


def _khidoc(S):
    p = P["necro"]
    for k, (x, y, r) in enumerate(((22, 38, 12), (40, 36, 13), (32, 26, 10), (30, 46, 10))):
        S.disc((x, y), r, p, glow=0.7, alpha=200)
    S.sparks((32, 40), 0.5, 10, 22, p, seed=4, up=True, size=2)
    S.glyph((32, 34), "poison", 8, p)


def _nguhanh(S):
    S.ring((32, 32), 22, 2, P["arcane"], squash=1.0, where="fx", alpha=200)
    for k, key in enumerate(("metal", "wood", "ice", "fire", "earth")):
        a = -math.pi / 2 + k * math.tau / 5
        S.orb((32 + math.cos(a) * 21, 32 + math.sin(a) * 21), 6.5, P[key], glow=1.3)
    S.star((32, 32), 9, 10, P["arcane"], glow=1.6)


def _khienchan(S):
    p = P["hv_steel"]
    S.crescent((22, 32), 30, -0.9, 0.9, 12, p, squash=1.0)
    S.shield((24, 30), 13, p, glow=1.2)
    S.glyph((50, 14), "stun", 5, P["hv"])


def _laokhien(S):
    p = P["hv_steel"]
    for off, w in ((-7, 4), (0, 8), (7, 4)):
        S.streak((2, 40 + off), (34, 34 + off), w, p, tail=0.1, alpha=200)
    S.shield((42, 32), 15, p, glow=1.4)


def _phanthuan(S):
    p = P["hv_steel"]
    S.crescent((32, 32), 24, 0.5, 4.0, 5, p, squash=0.7, glow=0.6, alpha=210)
    S.disc((32, 32), 15, p, glow=1.2)
    S.shield((32, 31), 7, p, glow=0.4)
    S.crescent((32, 32), 18, 2.0, 4.4, 4, p, glow=0.8)


def _phanquyet(S):
    p = P["hv"]
    S.ring((32, 54), 18, 2.2, p, where="fx")
    S.pillar((32, 56), 16, 60, p, alpha=170)
    S.hammer((30, 26), math.pi / 2 + 0.55, 44, p, glow=1.6)
    S.star((32, 52), 10, 10, p, glow=1.5)


def _xungphong(S):
    p = P["hv"]
    for off, w in ((-8, 4), (0, 10), (8, 4)):
        S.streak((0, 44 + off), (38, 32 + off), w, p, tail=0.1, alpha=210)
    S.star((44, 30), 12, 8, p, glow=1.6)
    S.glyph((46, 10), "stun", 5, p)


def _thanhquang(S):
    p = P["hv"]
    S.crescent((10, 34), 34, -1.0, 1.0, 16, p, squash=1.0, head=0.5)
    S.sparks((16, 40), 0.45, 10, 18, P_HEAL, seed=2, up=True, size=2)
    S.star((44, 34), 7, 6, p, glow=1.2)


def _thanhvuc(S):
    p = P["hv"]
    S.ring((32, 46), 24, 2.4, p, where="fx")
    for k in range(5):
        a = k * math.tau / 5 + 0.4
        S.pillar((32 + math.cos(a) * 20, 46 + math.sin(a) * 11), 6, 28 + 6 * (k % 2), p, alpha=220, glow=0.9)
    S.sparks((32, 40), 0.5, 10, 20, P_HEAL, seed=3, up=True, size=2)


def _thietchuy(S):
    p = P["hv_earth"]
    d = S.draw("fx")
    for k in range(6):
        a = k * math.tau / 6 + 0.3
        pts = [(32, 48)] + [(32 + math.cos(a + (j % 2) * 0.2) * 26 * j / 3, 48 + math.sin(a + (j % 2) * 0.2) * 12 * j / 3) for j in range(1, 4)]
        d.line(pts, fill=p[3] + (255,), width=3)
        d.line(pts, fill=p[1] + (220,), width=1)
    S.star((32, 46), 12, 8, p, glow=1.6, squash=0.7)
    S.hammer((30, 28), math.pi / 2 + 0.6, 44, P["hv_steel"], glow=1.1)
    S.sparks((32, 46), 0.35, 12, 24, (p[0], (190, 150, 110), (130, 92, 60), (60, 40, 30)), seed=9, grav=0.6, size=2.5)


def _thanhdong(S):
    p = P["hv_steel"]
    S.dome((32, 50), 26, p, 1.4, alpha=200)
    S.shield((32, 32), 12, p, glow=1.4)
    S.ring((32, 50), 26, 2, p, where="fx", alpha=200)


def _thienthuan(S):
    p = P["hv"]
    S.ring((32, 54), 24, 2.4, p, where="fx")
    S.pillar((32, 58), 26, 62, p, alpha=160)
    S.shield((32, 28), 16, p, glow=1.8)
    S.dome((32, 54), 22, p, 0.9, alpha=150)


def _linhtien(S):
    p = P["th_teal"]
    for k in range(5):
        a = -0.55 + k * 0.275
        tip = (12 + math.cos(a) * 44, 44 + math.sin(a) * 44)
        S.streak((12, 44), tip, 3, p, alpha=150, glow=0.4)
        S.orb(tip, 4.5, p, glow=1.2)
    S.disc((12, 44), 5, p, glow=1.2)


def _thachquy(S):
    p = P["hv_earth"]
    S.ring((32, 56), 20, 2.2, p, where="fx")
    S.pillar((32, 58), 26, 56, p, alpha=90)
    silhouette(S, "thach-quy", (32, 57), 44, p)
    S.sparks((32, 54), 0.4, 10, 22, (p[0], (190, 150, 110), (130, 92, 60), (60, 40, 30)), seed=5, grav=0.6, size=2.5)


def _hoadieu(S):
    p = P["th_dragon"]
    S.streak((2, 58), (30, 36), 12, P["fire"], tail=0.1, alpha=220)
    S.crescent((36, 38), 22, math.radians(200), math.radians(285), 9, p)
    S.crescent((36, 26), 22, math.radians(75), math.radians(160), 9, p)
    S.orb((38, 30), 7, p, glow=1.8)


def _linhtran(S):
    p = P["th"]
    S.decal((32, 40), 26, p, rot=0.3, runes=8, alpha=240)
    S.ring((32, 40), 13, 2, p, where="fx")
    for k in range(5):
        a = k * math.tau / 5
        S.disc((32 + math.cos(a) * 16, 34 + math.sin(a) * 9), 2.6, p, glow=0.9)
    S.pillar((32, 42), 10, 36, p, alpha=150)


def _linhung(S):
    p = P["th_teal"]
    S.ring((32, 56), 18, 2, p, where="fx")
    S.pillar((32, 58), 20, 56, p, alpha=90)
    silhouette(S, "linh-ung", (32, 50), 38, p, anim="run", frame=1)  # khung dang cánh — đọc ra là chim


def _aulong(S):
    p = P["th_dragon"]
    S.ring((32, 56), 20, 2.2, p, where="fx")
    S.pillar((32, 58), 24, 58, p, alpha=90)
    # cánh + sừng + lửa phun để bóng thú bốn chân đọc ra là rồng
    S.crescent((24, 34), 16, math.radians(200), math.radians(300), 7, p, glow=0.9)
    S.crescent((36, 34), 16, math.radians(220), math.radians(320), 7, p, glow=0.9)
    silhouette(S, "au-long", (28, 56), 34, p)
    S.poly([(38, 30), (42, 20), (41, 31)], p, glow=0.6)
    S.streak((44, 40), (62, 46), 9, P["fire"], tail=0.2)
    S.star((60, 46), 6, 6, P["fire"], glow=1.2)


def _longhong(S):
    p = P["th_dragon"]
    for k in range(3):
        S.crescent((20, 34), 12 + k * 9, -0.9, 0.9, 5, p, alpha=255 - k * 50)
    silhouette(S, "au-long", (20, 50), 30, p, glow=0.8)
    S.star((46, 34), 8, 8, p, glow=1.3)


def _totem(S, p, top):
    d = S.draw("fx")
    d.rectangle((28, 18, 36, 58), fill=p[3] + (255,))
    d.rectangle((29.5, 19, 34.5, 57), fill=top + (255,))
    for y in (24, 34, 44):
        d.rectangle((28.5, y, 35.5, y + 3), fill=p[1] + (255,))


def _loidodang(S):
    p = P["th_storm"]
    S.ring((32, 56), 22, 2, p, where="fx")
    _totem(S, p, (80, 70, 110))
    S.orb((32, 14), 6, p, glow=1.6)
    S.bolt((32, 14), (6, 46), p, seed=3, w=1.6, branches=1, jag=4)
    S.bolt((32, 14), (58, 44), p, seed=7, w=1.6, branches=1, jag=4)


def _phongdodang(S):
    p = P["th_wind"]
    S.ring((32, 56), 22, 2, p, where="fx")
    for k in range(3):
        a = k * math.tau / 3 + 0.3
        S.crescent((32, 42), 22, a, a + 1.5, 6, p, squash=0.55)
    _totem(S, p, (70, 120, 100))
    S.crescent((32, 14), 7, 0.0, 4.5, 3, p, glow=1.0)


def _kylan(S):
    p = P["th_qilin"]
    S.ring((32, 56), 22, 2.4, p, where="fx")
    S.pillar((32, 58), 30, 62, p, alpha=90)
    silhouette(S, "ky-lan", (32, 56), 44, p, glow=1.5)
    S.sparks((32, 50), 0.45, 10, 22, P_HEAL, seed=6, up=True, size=2)


P_HEAL = pal("#f4fff0", "#c8ffb0", "#6ad870", "#1c6a2a")

ICONS = {
    "spin": ("kk", _spin), "dash": ("kk", _dash), "hongkiem": ("kk", _hongkiem), "kiemvu": ("kk", _kiemvu),
    "phikiem": ("kk", _phikiem), "thanhkiem": ("kk_holy", _thanhkiem), "kiemvuc": ("kk_holy", _kiemvuc),
    "huyetbao": ("kk_blood", _huyetbao), "huyetanh": ("kk_blood", _huyetanh), "nhatkiem": ("kk_god", _nhatkiem),
    "eagle": ("ts_gold", _eagle), "tennay": ("ts", _tennay), "trap": ("ts_trap", _trap), "lienxa": ("ts", _lienxa),
    "tendoc": ("ts_poison", _tendoc), "phakhong": ("ts_star", _phakhong), "tamlien": ("ts_star", _tamlien),
    "baimin": ("ts_trap", _baimin), "luoibay": ("ts", _luoibay), "tinhvu": ("ts_star", _tinhvu),
    "meteor": ("fire", _meteor), "barrier": ("arcane", _barrier), "hoatuong": ("fire", _hoatuong), "nova": ("ice", _nova),
    "muabang": ("ice", _muabang), "causam": ("bolt", _causam), "thienloi": ("bolt", _thienloi), "bangphong": ("ice", _bangphong),
    "trieuhoi": ("necro", _trieuhoi), "khidoc": ("necro", _khidoc), "nguhanh": ("arcane", _nguhanh),
    "khienchan": ("hv_steel", _khienchan), "laokhien": ("hv_steel", _laokhien), "phanthuan": ("hv_steel", _phanthuan),
    "phanquyet": ("hv", _phanquyet), "xungphong": ("hv", _xungphong), "thanhquang": ("hv", _thanhquang),
    "thanhvuc": ("hv", _thanhvuc), "thietchuy": ("hv_earth", _thietchuy), "thanhdong": ("hv_steel", _thanhdong),
    "thienthuan": ("hv", _thienthuan),
    "linhtien": ("th_teal", _linhtien), "thachquy": ("hv_earth", _thachquy), "hoadieu": ("th_dragon", _hoadieu),
    "linhtran": ("th", _linhtran), "linhung": ("th_teal", _linhung), "aulong": ("th_dragon", _aulong),
    "longhong": ("th_dragon", _longhong), "loidodang": ("th_storm", _loidodang), "phongdodang": ("th_wind", _phongdodang),
    "kylan": ("th_qilin", _kylan),
}


def build():
    """{icon id: ảnh 128×128}: 51 kỹ năng chủ động không có icon vẽ tay + 20 bị động + icon tab "Bị động" (pv-*)."""
    ids = skill_icon_ids()
    owner = owner_icons()
    out = {}
    for n, (sid, (key, fn)) in enumerate(ICONS.items()):
        ic = ids.get(sid, sid)
        if ic in owner:
            continue
        out[ic] = icon(P[key], fn, seed=n)
    # §6: 20 bị động + icon tab "Bị động" — khoá "pv-<id>" → icon game "skill-pv-<id>"
    for n, (pid, (key, fn)) in enumerate(passive_icons_fx.make(P, silhouette).items()):
        out[pid] = icon(P[key], fn, seed=100 + n)
    return out


def _old_icon(ic):
    m = json.load(open(os.path.join(ASSETS, "art_manifest.json"), encoding="utf-8"))["icons"]
    path = m.get("skill-" + ic, "")
    return Image.open(path.replace("res://", os.path.join(ROOT, "godot") + "/")).convert("RGBA") if path else None


def review(icons):
    """docs/design/skill-icons: <lớp>/<id>.png (128) + <lớp>-so-sanh.png (hàng trên cũ, hàng dưới mới; viền vàng = icon vẽ
    tay giữ nguyên)."""
    ids = skill_icon_ids()
    owner = owner_icons()
    S2 = 96
    for cls, skills in design.SKILLS.items():
        folder = os.path.join(OUT, cls)
        os.makedirs(folder, exist_ok=True)
        sheet = Image.new("RGB", (len(skills) * (S2 + 8) + 8, 2 * (S2 + 22) + 22), (14, 16, 26))
        d = ImageDraw.Draw(sheet)
        d.text((8, 4), "%s - hang tren: icon hien tai / hang duoi: IC-1 (vien vang = icon ve tay giu nguyen)" % design.CLASS_LABEL[cls], fill=(235, 235, 240))
        for c, (sid, name, _fn) in enumerate(skills):
            ic = ids.get(sid, sid)
            x = 8 + c * (S2 + 8)
            old = _old_icon(ic)
            if old is not None:
                o = old.resize((S2, S2), Image.NEAREST if old.width < 64 else Image.LANCZOS)
                sheet.paste(o, (x, 22), o)
            new = icons.get(ic)
            if new is not None:
                new.save(os.path.join(folder, "%s.png" % ic))
                sheet.paste(new.resize((S2, S2), Image.LANCZOS), (x, 22 + S2 + 22))
            elif old is not None:
                sheet.paste(o, (x, 22 + S2 + 22), o)
            col = (255, 200, 90) if ic in owner else (120, 170, 255)
            d.rectangle((x - 1, 22 + S2 + 21, x + S2, 22 + 2 * S2 + 22), outline=col)
            d.text((x, 22 + 2 * S2 + 26), design._ascii(name)[:16], fill=col)
        sheet.save(os.path.join(OUT, cls + "-so-sanh.png"))


def review_passives(icons):
    """docs/design/skill-icons/bi-dong-so-sanh.png: mỗi lớp 4 bị động, hàng trên icon cũ, hàng dưới IC-1."""
    S2 = 96
    sheet = Image.new("RGB", (5 * (4 * (S2 + 8) + 24) + 8, 2 * S2 + 76), (14, 16, 26))
    d = ImageDraw.Draw(sheet)
    d.text((8, 4), "Bi dong - hang tren: icon cu / hang duoi: IC-1", fill=(235, 235, 240))
    os.makedirs(os.path.join(OUT, "bi-dong"), exist_ok=True)
    for ci, (cls, ids) in enumerate(passive_icons_fx.CLASS.items()):
        x0 = 8 + ci * (4 * (S2 + 8) + 24)
        d.text((x0, 20), design.CLASS_LABEL[cls], fill=(255, 210, 120))
        for k, pid in enumerate(ids):
            x = x0 + k * (S2 + 8)
            old = _old_icon("pv-" + pid)
            if old is not None:
                o = old.resize((S2, S2), Image.NEAREST)
                sheet.paste(o, (x, 36), o)
            new = icons.get("pv-" + pid)
            if new is not None:
                new.save(os.path.join(OUT, "bi-dong", "pv-%s.png" % pid))
                sheet.paste(new.resize((S2, S2), Image.LANCZOS), (x, 40 + S2))
            d.text((x, 44 + 2 * S2), pid, fill=(120, 170, 255))
    sheet.save(os.path.join(OUT, "bi-dong-so-sanh.png"))


def apply(icons):
    """Ghi icon HD vào godot/assets/hd/icons/skill-<id>.png và lớp phủ manifest["hd"]["icons"] (icon cũ giữ nguyên;
    tắt Đồ hoạ HD thì về icon cũ)."""
    dst = os.path.join(ASSETS, "hd", "icons")
    os.makedirs(dst, exist_ok=True)
    path = os.path.join(ASSETS, "art_manifest.json")
    m = json.load(open(path, encoding="utf-8"))
    hd = m.setdefault("hd", {}).setdefault("icons", {})
    for ic, img in icons.items():
        img.save(os.path.join(dst, "skill-%s.png" % ic), optimize=True)
        hd["skill-" + ic] = "res://assets/hd/icons/skill-%s.png" % ic
    with open(path, "w", encoding="utf-8", newline=chr(10)) as f:
        json.dump(m, f, ensure_ascii=False, indent=1)


if __name__ == "__main__":
    icons = build()
    review(icons)
    review_passives(icons)
    if "--apply" in sys.argv:
        apply(icons)
    print("ok: %d icon IC-1%s" % (len(icons), " (applied: godot/assets/hd/icons + manifest.hd.icons)" if "--apply" in sys.argv else ""))
