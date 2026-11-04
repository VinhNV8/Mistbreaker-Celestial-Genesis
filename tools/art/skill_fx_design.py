"""FX-1 (docs/36): thiết kế lại VFX thi triển cho 70 kỹ năng chủ động của 5 lớp.

    python tools/art/skill_fx_design.py            # xuất toàn bộ
    python tools/art/skill_fx_design.py spin meteor  # chỉ vài kỹ năng

Xuất bản duyệt vào `docs/design/skills-fx/<lop>/NN-<id>.gif` (12 khung, nhịp
anticipation → impact → dissipate) + `NN-<id>.png` (dải 6 khung chính) và
`docs/design/skills-fx/<lop>.png` (bảng tổng lớp). KHÔNG ghi vào godot/assets:
đưa vào game là bước sau khi chủ dự án duyệt (docs/36 §7).
"""
import math
import os
import sys

from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from skill_fx_kit import (SCALE, SQ, Scene, W, H, ease_in, ease_out, lerp, pal, seg)  # noqa: E402

ROOT = os.path.dirname(os.path.dirname(HERE))
OUT = os.path.join(ROOT, "docs", "design", "skills-fx")

NF = 12
# Nhịp chuẩn (ms): 4 khung tụ lực, 1 khung phát, khung va chạm giữ lâu, 6 khung tan.
DUR = [110, 90, 80, 70, 50, 190, 80, 80, 90, 100, 110, 260]
PHASE = ["TU LUC"] * 4 + ["PHAT", "VA CHAM"] + ["TAN"] * 6

C = (46, 86)                     # chân người thi triển
HAND = (C[0] + 10, C[1] - 22)    # điểm phát chiêu
T = [(122, 82), (146, 95), (160, 72), (102, 100), (176, 88)]
MOBS = ["wolf", "mushroom", "wolf", "moc-tinh", "mushroom"]

# ---------------------------------------------------------------- bảng màu
P = {
    # Kiếm Khách — Kiếm Khí đỏ son; nhánh Kiếm Thánh vàng thánh; Huyết Kiếm máu sẫm; Kiếm Thần bạch lam
    "kk": pal("#fff4ee", "#ffb0a0", "#ff4248", "#7a1028"),
    "kk_holy": pal("#fffbea", "#ffe89a", "#f2b83a", "#94561a"),
    "kk_blood": pal("#ffe6e6", "#ff5a66", "#b80c2a", "#3e0412"),
    "kk_god": pal("#ffffff", "#d6f2ff", "#78c4ff", "#2a56a8"),
    # Thợ Săn — Phong Tiễn ngọc bích + vàng ưng; độc; bẫy gỉ sắt; tinh tú
    "ts": pal("#f2fff6", "#aaf8d0", "#2fd090", "#0e5e52"),
    "ts_gold": pal("#fffbe0", "#ffe070", "#e09a1e", "#74420e"),
    "ts_poison": pal("#f4ffd6", "#c6f05a", "#62b81c", "#284e0e"),
    "ts_trap": pal("#fff0d4", "#ffb25a", "#d2581c", "#5a1c0c"),
    "ts_star": pal("#ffffff", "#fff2b4", "#a4b4ff", "#40329a"),
    # Pháp Sư — mỗi hệ một dải
    "fire": pal("#fffbe0", "#ffd25a", "#ff6418", "#9a1a06"),
    "ice": pal("#ffffff", "#c6f2ff", "#54c2ff", "#1a52a2"),
    "bolt": pal("#ffffff", "#e6d6ff", "#9e6cff", "#38188a"),
    "arcane": pal("#fff2ff", "#ffb6f0", "#cc4cff", "#4c0e86"),
    "necro": pal("#f2ffe6", "#b4ff94", "#5ec83e", "#341452"),
    "metal": pal("#ffffff", "#eef2f8", "#b8c4d4", "#4c5668"),
    "wood": pal("#f0ffe0", "#a6f07a", "#3eaa38", "#16481c"),
    "earth": pal("#fff2d8", "#e2b67c", "#a86c3c", "#462c16"),
    # Hộ Vệ — Thánh Thuẫn vàng kim + thép lam + đất đá
    "hv": pal("#fffef0", "#fff09c", "#f0be3a", "#94580e"),
    "hv_steel": pal("#ffffff", "#dae6f6", "#86a6d0", "#34466c"),
    "hv_earth": pal("#fff0d6", "#dcb47c", "#a26a3a", "#46301a"),
    # Triệu Hồi Sư — linh hồn tím + ngọc lam; rồng; lôi; phong; kỳ lân
    "th": pal("#f8f0ff", "#d6b6ff", "#9868ff", "#38188a"),
    "th_teal": pal("#e6fffa", "#98f0e0", "#2ebeae", "#0c4e50"),
    "th_dragon": pal("#fffbe0", "#ffce6a", "#ff7626", "#8a1e0e"),
    "th_storm": pal("#ffffff", "#ddeeff", "#6caeff", "#283a98"),
    "th_wind": pal("#f2fff8", "#b6f6da", "#46cfa0", "#145a4a"),
    "th_qilin": pal("#ffffff", "#fff0b0", "#ffb03c", "#2a8ab0"),
}
DUST = (126, 116, 104)
FROST = (196, 222, 240)
GROUND = {
    "kiem-khach": ((26, 20, 26), (44, 32, 36)),
    "tho-san": ((18, 28, 24), (32, 46, 36)),
    "phap-su": ((20, 20, 36), (34, 32, 54)),
    "ho-ve": ((28, 26, 22), (48, 42, 34)),
    "trieu-hoi-su": ((20, 18, 34), (34, 28, 50)),
}
PC = {"kiem-khach": "pc-kiem-khach", "tho-san": "pc-tho-san", "phap-su": "pc-phap-su",
      "ho-ve": "pc-ho-ve", "trieu-hoi-su": "pc-trieu-hoi-su"}


# ---------------------------------------------------------------- dàn cảnh
def stage(cls, f, hits=None, caster=None, mobs=True, mob_count=4, caster_alpha=1.0, dim=0.0):
    """Nền + người thi triển (sprite gốc, tư thế theo pha) + quái mục tiêu (nháy trắng khi trúng)."""
    S = Scene(GROUND[cls], seed=len(cls))
    S.cls = cls
    if dim:
        S.dim(dim)
    pose = ("attack", 0) if f < 4 else (("attack", min(3, f - 3)) if f < 8 else ("idle", f % 2))
    if caster_alpha > 0:
        S.put(PC[cls], caster or C, pose[0], pose[1], alpha=caster_alpha)
    hits = hits or {}
    if mobs:
        for i in range(mob_count):
            hf = hits.get(i, ())
            w = 0.9 if f in hf else (0.35 if (f - 1) in hf else 0.0)
            sh = (1 if f in hf else (-1 if (f - 1) in hf else 0))
            S.put(MOBS[i], T[i], "hurt" if w else "idle", 0, flip=True, white=w, shake=sh)
    return S


def hit_all(frames, n=4):
    return {i: tuple(frames) for i in range(n)}


def impact(S, c, p, t, r=10, n=8, seed=0, smoke=True, sparks=True):
    """Va chạm chuẩn: sao gai nở nhanh → tia lửa bắn → khói tan."""
    if t is None:
        return
    if t < 0.35:
        k = ease_out(t / 0.35)
        S.star(c, r * (0.5 + 0.7 * k), n, p, rot=seed * 0.7, seed=seed)
    elif t < 0.55:
        S.ring(c, r * 1.4, 1.5, p, squash=0.8, where="fx", glow=0.6, alpha=200)
    if sparks:
        S.sparks(c, t, 7, r * 1.8, p, seed=seed + 3, grav=0.6)
    if smoke and t > 0.3:
        S.smoke((c[0], c[1] + 4), (t - 0.3) / 0.7, 3, r * 0.45, DUST, seed=seed)


def charge(S, c, p, f, r=10, n=10, last=3, seed=0):
    """Tụ lực: hạt bay vào tâm + quầng co lại (pha anticipation)."""
    t = seg(f, 0, last)
    if t is None:
        return
    import random
    rnd = random.Random(seed)
    d = S.draw("fx")
    for _ in range(n):
        a = rnd.uniform(0, math.tau)
        rr = r * 2.2 * (1 - ease_in(t) * 0.85) * rnd.uniform(0.7, 1.1)
        x, y = c[0] + math.cos(a) * rr, c[1] + math.sin(a) * rr * 0.8
        x2, y2 = c[0] + math.cos(a) * (rr + 3), c[1] + math.sin(a) * (rr + 3) * 0.8
        d.line((x, y, x2, y2), fill=p[1] + (220,))
        d.point((x, y), fill=p[0] + (255,))
    S.glow_dot(c, r * (0.4 + t * 0.6), p[2], 0.5 + t * 0.5)
    S.disc(c, 1.5 + t * 2.5, p, glow=0.6)


def ground_ring(S, c, r, p, t, w=2.2):
    if t is not None and t < 1:
        S.ring(c, r * (0.25 + 0.75 * ease_out(t)), w * (1 - t * 0.6), p, alpha=int(255 * (1 - t * 0.5)))


def towards(a, b, t):
    return (lerp(a[0], b[0], t), lerp(a[1], b[1], t))


# ---------------------------------------------------------------- nguyên mẫu (archetype)
def a_spin(cls, p, f, r=34, blades=3, turns=1.6, hits=(5, 7), extra=None):
    S = stage(cls, f, hit_all(hits, 2) if r < 70 else hit_all(hits))
    c = (C[0] + 4, C[1] - 8)
    charge(S, (C[0] + 6, C[1] - 18), p, f, 8)
    if 0 <= f < 4:
        S.crescent(c, 12, math.radians(150), math.radians(150 + 70 * f), 3 + f, p, squash=SQ * 1.4, glow=0.5)
    t = seg(f, 4, 9)
    if t is not None:
        base = t * turns * math.tau
        rr = r * (0.55 + 0.45 * ease_out(t * 1.6))
        for b in range(blades):
            a = base + b * math.tau / blades
            S.crescent(c, rr, a, a + 1.6, 9 * (1 - t * 0.5), p, squash=SQ, alpha=int(255 * (1 - t * 0.3)))
        S.ring((c[0], c[1] + 6), rr, 1.4, p, alpha=150)
    ground_ring(S, (c[0], c[1] + 6), r, p, seg(f, 8, 11))
    S.sparks(c, seg(f, 5, 11), 14, r * 1.2, p, seed=2)
    S.smoke((c[0], c[1] + 8), seg(f, 7, 11), 6, 4, DUST, spread=r * 0.7)
    for i in range(2):
        impact(S, (T[i][0], T[i][1] - 8), p, seg(f, hits[0], hits[0] + 4), 7, seed=i)
    if extra:
        extra(S, f)
    return S


def a_dash(cls, p, f, end=(150, 86), hits=(4,), afterimage=3, mark="slash", twice=False):
    path = [(C, end)] if not twice else [(C, (112, 92)), ((112, 92), (166, 80))]
    if f < 3:
        pos = C
    elif f < 3 + 2 * len(path):
        k = f - 3
        a, b = path[k // 2]
        pos = towards(a, b, 0.5 if k % 2 == 0 else 1.0)
    else:
        pos = path[-1][1]
    S = stage(cls, f, {0: hits, 1: hits, 2: tuple(h + 1 for h in hits)}, caster=pos)
    charge(S, (C[0], C[1] - 12), p, f, 9)
    if f < 3:
        S.streak((C[0] + 10, C[1] - 6), (C[0] + 10 + f * 22, C[1] - 6), 1.2, p, glow=0.4, alpha=140)
    for seg_i, (a, b) in enumerate(path):
        t = seg(f, 3 + seg_i * 2, 9 + seg_i * 2)
        if t is None:
            continue
        reach = min(1.0, (f - 3 - seg_i * 2 + 1) / 2.0)
        tip = towards(a, b, reach)
        alpha = int(255 * (1 - max(0, t - 0.35) / 0.65))
        S.streak((a[0], a[1] - 10), (tip[0], tip[1] - 10), 8, p, alpha=alpha)
        S.streak((a[0], a[1] - 4), (tip[0], tip[1] - 4), 3, p, alpha=int(alpha * 0.7), glow=0.4)
        for k in range(afterimage if t < 0.5 else 0):
            S.put(PC[cls], towards(a, b, (k + 1) / (afterimage + 1) * reach), "run", k % 4, white=0.6, alpha=0.35)
    for i in range(3):
        t = seg(f, hits[0] + (i == 2), hits[0] + 5)
        c = (T[i][0], T[i][1] - 9)
        if t is not None and t < 0.5 and mark == "x":
            S.crescent(c, 9, -2.4, -0.8, 4, p, glow=0.8)
            S.crescent(c, 9, 0.8, 2.4, 4, p, glow=0.8)
        impact(S, c, p, t, 8, seed=i)
        if twice:
            impact(S, c, p, seg(f, hits[0] + 2, hits[0] + 6), 7, seed=i + 5, smoke=False)
    return S


def a_projectile(cls, p, f, kind="wave", length=1.0, hits=None, size=1.0, trail=True, pierce=True, aim=-0.05,
                 count=1, spread=0.0, extra=None):
    hits = hits or {0: (5,), 1: (6,), 2: (7,)}
    S = stage(cls, f, hits)
    charge(S, HAND, p, f, 9 * size)
    for j in range(count):
        ang = aim + (j - (count - 1) / 2) * spread
        t = seg(f, 4, 8)
        if t is None:
            continue
        dist = (W + 20 - HAND[0]) * ease_in(t * 0.6 + 0.4 * t) * length
        tip = (HAND[0] + math.cos(ang) * dist, HAND[1] + math.sin(ang) * dist + 10 * t)
        if kind == "wave":
            S.crescent((tip[0] - 14 * size, tip[1]), 14 * size, -1.15, 1.15, 7 * size, p, head=0.5)
        elif kind == "arrow":
            S.arrow(tip, ang, 9 * size, p, trail=46 * size)
        elif kind == "shard":
            S.shard(tip, ang, 12 * size, p)
            S.streak((tip[0] - 40 * size, tip[1]), (tip[0] - 6, tip[1]), 3 * size, p, alpha=150, glow=0.5)
        elif kind == "sword":
            S.sword(tip, ang, 18 * size, p)
            S.streak((tip[0] - 42, tip[1]), (tip[0] - 8, tip[1]), 3 * size, p, alpha=170)
        elif kind == "beam":
            S.streak(HAND, tip, 10 * size, p, tail=0.8)
        elif kind == "orb":
            S.orb(tip, 4 * size, p)
            S.streak((tip[0] - 30, tip[1]), tip, 4 * size, p, alpha=150, glow=0.4)
        if trail and kind not in ("beam",):
            S.sparks(tip, 0.4, 4, 8, p, seed=f + j)
    if kind == "beam":
        t = seg(f, 6, 11)
        if t is not None:
            S.streak(HAND, (W + 10, HAND[1] + 8), 10 * size * (1 - t), p, tail=0.8, alpha=int(255 * (1 - t)))
    for i, fr in hits.items():
        impact(S, (T[i][0], T[i][1] - 9), p, seg(f, fr[0], fr[0] + 5), 7 * size, seed=i)
    if extra:
        extra(S, f)
    return S


def a_buff(cls, p, f, glyph=None, ring=True, sword_orbit=0, rise=True, dome=False):
    S = stage(cls, f, mobs=True, mob_count=2)
    c = (C[0], C[1] - 16)
    t0 = seg(f, 0, 4)
    if ring and t0 is not None:
        S.decal(C, 10 + 18 * ease_out(t0), p, rot=f * 0.3, runes=6)
    if f == 4:
        S.pillar(C, 18, 60, p, glow=1.6)
        S.flash(p[1], 0.18)
    t = seg(f, 5, 11)
    if t is not None:
        S.ring(C, 18, 1.4, p, alpha=200)
        S.glow_dot(c, 16, p[2], 0.45)
        if rise:
            S.sparks((C[0], C[1] - 2), (f % 4) / 4.0, 8, 26, p, seed=f // 4, up=True)
        for k in range(sword_orbit):
            a = f * 0.9 + k * math.tau / sword_orbit
            S.sword((c[0] + math.cos(a) * 16, c[1] + math.sin(a) * 6), -math.pi / 2, 12, p, glow=0.7)
        if glyph:
            glyph(S, (C[0], C[1] - 52 - math.sin(f) * 1.5), t)
        if dome:
            S.dome((C[0], C[1]), 20, p, 1.0)
    return S


def a_rain(cls, p, f, center=(138, 88), r=34, obj="arrow", waves=6, decal=True, hits=None, dim=0.0, big=False):
    hits = hits if hits is not None else hit_all((5, 7, 9))
    S = stage(cls, f, hits, dim=dim)
    import random
    if f < 3:
        charge(S, HAND, p, f, 7)
        S.streak(HAND, (HAND[0] + 6, HAND[1] - 40), 3, p, alpha=200)
    if decal:
        S.decal(center, r * (0.6 + 0.4 * ease_out(min(1, f / 3.0))), p, rot=f * 0.15, runes=10, alpha=170)
    rnd = random.Random(7)
    drops = [(rnd.uniform(-r, r), rnd.uniform(-r, r) * SQ, rnd.uniform(2, 9.5)) for _ in range(waves * 3)]
    for dx, dy, t0 in drops:
        if (dx / r) ** 2 + (dy / (r * SQ)) ** 2 > 1:
            continue
        t = (f - t0) / 1.6
        gx, gy = center[0] + dx, center[1] + dy
        if -1 < t < 0:
            fy = gy - 60 * (-t)
            if obj == "arrow":
                S.arrow((gx + 4 * t, fy), math.pi / 2 + 0.15, 8, p, trail=10)
            elif obj == "sword":
                S.sword((gx, fy), math.pi / 2, 16 if big else 12, p, glow=0.8)
            elif obj == "shard":
                S.shard((gx, fy), math.pi / 2, 10, p)
            elif obj == "star":
                S.star((gx + 10 * t, fy), 4, 4, p, glow=1.2)
                S.streak((gx + 18 * t - 8, fy - 14), (gx + 10 * t, fy), 2, p, alpha=150)
        elif 0 <= t < 1:
            impact(S, (gx, gy - 2), p, t, 6 if not big else 8, n=6, seed=int(dx), smoke=t > 0.2)
    return S


def a_explode(cls, p, f, r=40, implode=True, spikes=0, debris=False, root=False, stun=False, frost=False,
              hits=None, dim=0.0, star_n=12, leech=False):
    hits = hits if hits is not None else hit_all((5,), 2)
    S = stage(cls, f, hits, dim=dim)
    c = (C[0] + 2, C[1] - 6)
    if implode and f < 4:
        S.ring(C, r * (1 - f / 4.0 * 0.8), 1.5, p, alpha=150 + f * 25)
        charge(S, c, p, f, 12, 16)
    if f == 4:
        S.flash(p[0], 0.35)
        S.star(c, r * 0.6, star_n, p, glow=1.8)
    t = seg(f, 4, 10)
    if t is not None:
        S.ring(C, r * (0.3 + 0.7 * ease_out(t)), 4 * (1 - t) + 1, p, glow=1.2, alpha=int(255 * (1 - t * 0.4)))
        if t < 0.45:
            S.disc(c, r * 0.35 * (1 - t), p, glow=1.4)
    if spikes:
        ts = seg(f, 5, 11)
        if ts is not None:
            for k in range(spikes):
                a = k * math.tau / spikes + 0.2
                base = (C[0] + math.cos(a) * r * 0.75, C[1] + math.sin(a) * r * 0.75 * SQ)
                h = 14 * (ease_out(min(1, ts * 3)) if ts < 0.75 else (1 - ts) * 4)
                if h > 1:
                    S.poly([(base[0] - 3, base[1]), (base[0] + 1, base[1] - h), (base[0] + 3, base[1])], p, glow=0.7)
    if debris:
        S.sparks(C, seg(f, 4, 11), 14, r, (p[0], (180, 150, 110), (120, 90, 60), (60, 40, 30)), seed=4, grav=1.0, size=2.5)
    S.sparks(c, seg(f, 4, 10), 16, r * 0.9, p, seed=1)
    S.smoke(C, seg(f, 6, 11), 8, 5, FROST if frost else DUST, spread=r * 0.8, rise=4)
    for i in hits:
        impact(S, (T[i][0], T[i][1] - 8), p, seg(f, 5, 9), 6, seed=i, smoke=False)
        if (root or stun) and f >= 6:
            if root:
                S.ring((T[i][0], T[i][1]), 8, 2, p, alpha=230)
                S.glyph((T[i][0], T[i][1] - 22), "chain", 3, p)
            else:
                S.glyph((T[i][0], T[i][1] - 24), "stun", 6, p)
    if leech:
        tl = seg(f, 7, 11)
        if tl is not None:
            for i in hits:
                pos = towards((T[i][0], T[i][1] - 10), (C[0], C[1] - 16), ease_in(tl))
                S.orb(pos, 2.5, p, glow=0.8)
    return S


def a_chain(cls, p, f, order=(0, 2, 1, 3), kind="bolt", from_sky=False, hits_start=4, dim=0.0):
    hits = {i: (hits_start + k,) for k, i in enumerate(order)}
    S = stage(cls, f, hits, dim=dim)
    charge(S, HAND, p, f, 9)
    pts = [HAND] + [(T[i][0], T[i][1] - 10) for i in order]
    for k in range(len(order)):
        t = seg(f, hits_start + k, hits_start + k + 2)
        if t is None:
            continue
        a, b = (pts[k], pts[k + 1]) if not from_sky else ((pts[k + 1][0] + 6, -4), pts[k + 1])
        if kind == "bolt":
            S.bolt(a, b, p, seed=f * 7 + k, alpha=int(255 * (1 - t * 0.5)), w=3.0 if from_sky else 2.4)
        else:
            tip = towards(a, b, min(1, t * 2.2))
            S.arrow(tip, math.atan2(b[1] - a[1], b[0] - a[0]), 8, p, trail=18)
            S.streak(a, tip, 1.0, p, alpha=120, glow=0.3)
        if from_sky and t < 0.5:
            S.ring((b[0], b[1] + 10), 10, 2, p, alpha=230)
    for k, i in enumerate(order):
        impact(S, (T[i][0], T[i][1] - 9), p, seg(f, hits_start + k, hits_start + k + 5), 7, seed=i)
    return S


def a_summon(cls, p, f, units, circle_r=18, pillar=True, glow_eyes=True, aura=None):
    """Nghi thức gọi: trận đồ xoay → cột sáng → linh thú hiện từ trắng → sóng xung kích + hạt bay lên."""
    S = stage(cls, f, mob_count=2)
    for k, (sid, pos) in enumerate(units):
        t0 = seg(f, 0 + k * 0.4, 4 + k * 0.4)
        if t0 is not None or f >= 4:
            S.decal(pos, circle_r * (0.5 + 0.5 * ease_out(t0 if t0 is not None else 1)), p, rot=f * 0.45, runes=6,
                    alpha=220 if f < 8 else 140)
        tp = seg(f, 3 + k * 0.5, 6 + k * 0.5)
        if pillar and tp is not None:
            S.pillar(pos, circle_r * 1.1 * (1 - tp * 0.8), 70, p, alpha=int(255 * (1 - tp * 0.6)))
        ts = seg(f, 4 + k * 0.5, 8)
        if ts is not None or f > 8:
            w = 1.0 - ease_out(ts if ts is not None else 1)
            S.put(sid, pos, "idle", f % 2, white=w, alpha=min(1.0, 0.4 + (ts if ts is not None else 1)))
        ground_ring(S, pos, circle_r * 1.5, p, seg(f, 5 + k * 0.5, 9 + k * 0.5))
        S.sparks((pos[0], pos[1] - 2), seg(f, 5, 11), 8, 24, p, seed=k, up=True)
    charge(S, HAND, p, f, 7)
    if aura:
        aura(S, f)
    return S


def a_field(cls, p, f, center, r, kind, hits=None, follow=False):
    hits = hits if hits is not None else hit_all((5, 8, 11) if kind != "wall" else (5, 7, 9, 11), 3)
    S = stage(cls, f, hits)
    import random
    rnd = random.Random(3)
    t_in = seg(f, 0, 4)
    S.decal(center, r * (0.4 + 0.6 * ease_out(t_in if t_in is not None else 1)), p, rot=f * 0.25, runes=12,
            alpha=200, inner=kind != "wall")
    if f < 4:
        charge(S, HAND, p, f, 8)
    if f < 4:
        return S
    if kind == "fire_wall":
        for k in range(9):
            x = center[0] - r + k * r / 4
            y = center[1] + (k - 4) * 2.5
            h = 10 + 8 * abs(math.sin(f * 1.7 + k))
            S.poly([(x - 5, y), (x - 2, y - h * 0.7), (x, y - h), (x + 3, y - h * 0.6), (x + 5, y)], p, glow=1.0)
        S.sparks((center[0], center[1] - 10), (f % 3) / 3.0, 10, 28, p, seed=f, up=True)
    elif kind == "poison":
        for k in range(7):
            a = k * math.tau / 7 + f * 0.12
            pos = (center[0] + math.cos(a) * r * 0.55, center[1] + math.sin(a) * r * 0.3 - 4)
            S.disc(pos, 7 + 2 * math.sin(f + k), p, squash=0.6, glow=0.6, alpha=150)
        S.sparks(center, (f % 4) / 4.0, 10, r * 0.6, p, seed=f, up=True, size=2)
    elif kind == "holy":
        for k in range(6):
            a = k * math.tau / 6 + f * 0.3
            pos = (center[0] + math.cos(a) * r * 0.7, center[1] + math.sin(a) * r * 0.7 * SQ)
            S.pillar(pos, 4, 22 + 6 * math.sin(f + k), p, glow=0.8, alpha=200)
        S.sparks(center, (f % 3) / 3.0, 12, r * 0.8, p, seed=f, up=True)
    elif kind == "swords":
        for k in range(8):
            a = k * math.tau / 8 + f * 0.4
            pos = (center[0] + math.cos(a) * r * 0.85, center[1] + math.sin(a) * r * 0.85 * SQ - 6)
            S.sword(pos, math.pi / 2, 12, p, glow=0.6)
        k = f % 4
        dropx = center[0] + (rnd.uniform(-1, 1) + k - 1.5) * r * 0.3
        S.sword((dropx, center[1] - 30 + k * 6), math.pi / 2, 14, p)
        S.ring(center, r, 2, p, alpha=220)
    elif kind == "wind":
        for k in range(3):
            a = f * 0.8 + k * math.tau / 3
            S.crescent((center[0], center[1] - 8), r * 0.7, a, a + 1.4, 5, p, squash=SQ, alpha=200)
        S.sparks(center, (f % 3) / 3.0, 10, r, p, seed=f, size=1)
    elif kind == "spirit":
        S.ring(center, r * 0.5, 1.2, p, alpha=220)
        for k in range(6):
            a = f * 0.35 + k * math.tau / 6
            S.disc((center[0] + math.cos(a) * r * 0.6, center[1] + math.sin(a) * r * 0.6 * SQ - 4), 2.2, p, glow=0.8)
        S.sparks(center, (f % 4) / 4.0, 8, r * 0.7, p, seed=f, up=True)
    for i in hits:
        for fr in hits[i]:
            impact(S, (T[i][0], T[i][1] - 9), p, seg(f, fr, fr + 2), 5, seed=i + fr, smoke=False)
    return S


def a_meteor(cls, p, f, center=(136, 88), obj="meteor", r=30, hits=None, dim=0.0, rocks=True):
    hits = hits if hits is not None else hit_all((5,))
    S = stage(cls, f, hits, dim=dim)
    t = seg(f, 0, 4)
    if f <= 5:
        S.decal(center, r * (0.5 + 0.5 * ease_out(t if t is not None else 1)), p, rot=f * 0.3, runes=10, alpha=170 + 15 * f)
    charge(S, HAND, p, f, 8)
    tf = seg(f, 2, 5)
    if tf is not None and tf < 1:
        e = ease_in(tf)
        pos = (center[0] - 46 * (1 - e), center[1] - 90 * (1 - e) - 6)
        if obj == "meteor":
            S.streak((pos[0] - 26, pos[1] - 44), pos, 12, p, tail=0.15)
            S.disc(pos, 8, p, glow=1.6)
        elif obj == "hammer":
            S.hammer((center[0], center[1] - 80 * (1 - e) - 14), math.pi / 2, 26, p, glow=1.4)
            S.pillar(center, 10, 90 * (1 - e) + 10, p, alpha=150, glow=0.8)
        elif obj == "shield":
            S.shield((center[0], center[1] - 90 * (1 - e) - 16), 12, p, glow=1.6)
            S.pillar(center, 14, 100, p, alpha=160, glow=0.9)
    if f == 5:
        S.flash(p[0], 0.3)
    ti = seg(f, 5, 11)
    if ti is not None:
        S.ring(center, r * (0.35 + 0.9 * ease_out(ti)), 4 * (1 - ti) + 1, p, alpha=int(255 * (1 - ti * 0.6)))
        if ti < 0.4:
            S.star((center[0], center[1] - 8), r * 0.9 * (1 - ti), 12, p, glow=1.8, squash=0.75)
        if obj == "shield" and ti > 0.15:
            S.shield((center[0], center[1] - 16), 12, p, glow=0.8)
            S.dome(center, r * 0.8, p, 1.0, alpha=140)
        if obj == "hammer" and ti < 0.6:
            S.hammer((center[0] + 2, center[1] - 18), math.pi / 2 + 0.1, 26, p, glow=0.8, alpha=int(255 * (1 - ti)))
        if rocks:
            S.sparks((center[0], center[1] - 4), ti, 16, r, (p[0], (190, 150, 110), (130, 92, 60), (60, 40, 30)),
                     seed=9, grav=1.2, size=2.5)
        S.smoke(center, ti, 8, 6, DUST, spread=r * 0.8, rise=8)
    for i in hits:
        if f >= 5:
            impact(S, (T[i][0], T[i][1] - 9), p, seg(f, 5, 9), 6, seed=i, smoke=False)
    return S


def a_trap(cls, p, f, spots, kind="spike", hits=None):
    hits = hits if hits is not None else {0: (6,), 1: (7,), 3: (8,)}
    S = stage(cls, f, hits)
    for k, s in enumerate(spots):
        land = seg(f, 0 + k * 0.4, 3 + k * 0.4)
        if land is not None and land < 1:
            pos = towards(HAND, s, ease_out(land))
            S.disc((pos[0], pos[1] - 18 * math.sin(land * math.pi)), 2.5, p, glow=0.6)
            continue
        if f < 3:
            continue
        armed = f < 6 + k * 0.6
        if armed:
            blink = (f % 2 == 0)
            S.disc(s, 4, p, squash=SQ, glow=0.8 if blink else 0.3, where="ground")
            if kind == "mine":
                S.disc((s[0], s[1] - 2), 2, (p[0], p[1], (255, 60, 40), p[3]), glow=0.8 if blink else 0.0)
            elif kind == "spike":
                for dx in (-3, 0, 3):
                    S.poly([(s[0] + dx - 1, s[1]), (s[0] + dx, s[1] - 3), (s[0] + dx + 1, s[1])], p, glow=0.2)
        else:
            t = seg(f, 6 + k * 0.6, 11)
            if kind == "spike":
                if t is not None and t < 0.6:
                    for dx in (-6, -3, 0, 3, 6):
                        h = 12 * math.sin(min(1, t * 3) * math.pi / 2)
                        S.poly([(s[0] + dx - 2, s[1]), (s[0] + dx, s[1] - h - abs(dx)), (s[0] + dx + 2, s[1])], p, glow=0.8)
                impact(S, (s[0], s[1] - 6), p, t, 9, seed=k)
                if f >= 8:
                    S.glyph((s[0], s[1] - 26), "chain", 3, P["ts"])
                    S.ring(s, 9, 2, P["ts"], alpha=220)
            else:
                impact(S, (s[0], s[1] - 6), p, t, 12, n=10, seed=k)
    return S


# ---------------------------------------------------------------- 70 kỹ năng
def _glyph(kind, key):
    def g(S, c, t):
        S.glyph(c, kind, 6, P[key])
    return g


def _kiemy_glyph(S, c, t):
    S.sword(c, -math.pi / 2, 14, P["kk"], glow=1.2)


def _eagle_glyph(S, c, t):
    S.glyph(c, "eye", 6, P["ts_gold"])
    S.crescent((c[0] - 4, c[1] + 2), 9, math.radians(190), math.radians(260), 3, P["ts_gold"], glow=0.6)
    S.crescent((c[0] + 4, c[1] + 2), 9, math.radians(280), math.radians(350), 3, P["ts_gold"], glow=0.6)


def _shield_glyph(S, c, t):
    S.shield(c, 6, P["hv_steel"], glow=1.0)


def _link_glyph(S, c, t):
    pass


# Kiếm Khách -----------------------------------------------------------
def kk_spin(f):
    return a_spin("kiem-khach", P["kk"], f, r=36, blades=3)


def kk_dash(f):
    return a_dash("kiem-khach", P["kk"], f)


def kk_wave(f):
    return a_projectile("kiem-khach", P["kk"], f, "wave", size=1.1)


def kk_kiemy(f):
    return a_buff("kiem-khach", P["kk"], f, glyph=_kiemy_glyph, sword_orbit=2)


def kk_lientram(f):
    S = stage("kiem-khach", f, {0: (5, 7, 9)}, caster=C if f < 3 else (106, 84))
    p = P["kk"]
    charge(S, (C[0], C[1] - 12), p, f, 8)
    if f == 3:
        S.streak((C[0], C[1] - 10), (100, 74), 7, p)
        S.put("pc-kiem-khach", (76, 85), "run", 1, white=0.6, alpha=0.4)
    tc = (T[0][0], T[0][1] - 10)
    for k, fr in enumerate((5, 7, 9)):
        t = seg(f, fr - 1, fr + 1)
        if t is not None:
            a = [(-2.4, -0.4), (0.6, 2.6), (-1.6, 1.2)][k]
            S.crescent(tc, 14 + k * 2, a[0], a[1], 7, p, alpha=int(255 * (1 - t * 0.5)))
        impact(S, tc, p, seg(f, fr, fr + 3), 6, seed=k, smoke=k == 2)
    if f >= 9:
        S.crescent((tc[0] - 2, tc[1] - 2), 20, -2.8, -0.2, 4, P["kk_god"], glow=0.8, alpha=180)  # trăng khuyết bạc khép chuỗi
    return S


def kk_hongkiem(f):
    S = a_explode("kiem-khach", P["kk"], f, r=44, stun=True, hits=hit_all((5,), 2))
    t = seg(f, 4, 9)
    if t is not None:
        for k in range(8):
            a = k * math.tau / 8
            rr = 10 + 34 * ease_out(t)
            S.sword((C[0] + math.cos(a) * rr, C[1] - 8 + math.sin(a) * rr * SQ), a, 10, P["kk"], glow=0.5,
                    alpha=int(255 * (1 - t * 0.6)))
    return S


def kk_kiemvu(f):
    S = stage("kiem-khach", f, hit_all((5, 7, 9, 11), 2))
    p = P["kk"]
    charge(S, (C[0], C[1] - 16), p, f, 8)
    t = seg(f, 3, 11)
    if t is not None:
        for k in range(4):
            a = f * 1.1 + k * math.tau / 4
            pos = (C[0] + math.cos(a) * 30, C[1] - 12 + math.sin(a) * 30 * SQ)
            S.sword(pos, a + math.pi / 2, 14, p, glow=0.9)
            S.crescent((C[0], C[1] - 12), 30, a - 0.9, a - 0.05, 4, p, squash=SQ, glow=0.4, alpha=170)
        S.ring(C, 34, 1.2, p, alpha=150)
    for fr in (5, 7, 9, 11):
        for i in range(2):
            impact(S, (T[i][0], T[i][1] - 9), p, seg(f, fr, fr + 1.5), 5, seed=fr + i, smoke=False)
    return S


def kk_phikiem(f):
    return a_projectile("kiem-khach", P["kk"], f, "sword", count=3, spread=0.26, hits={0: (6,), 1: (6,), 2: (6,)})


def kk_vankiem(f):
    S = a_rain("kiem-khach", P["kk"], f, center=(C[0] + 52, C[1] + 2), r=62, obj="sword", waves=8, dim=0.35, big=True,
               hits=hit_all((5, 7, 9, 11)))
    if f < 4:
        for k in range(f * 3):
            S.sword((C[0] - 10 + k * 6, C[1] - 60 - (k % 3) * 4), math.pi / 2, 10, P["kk"], glow=0.5)
    return S


def kk_thanhkiem(f):
    S = a_projectile("kiem-khach", P["kk_holy"], f, "beam", size=1.4, hits={0: (5,), 1: (5,), 2: (6,), 4: (6,)})
    if 4 <= f <= 7:
        S.sword((HAND[0] + 8, HAND[1] - 4), 0.0, 26, P["kk_holy"], glow=1.6)
    if f == 5:
        S.flash(P["kk_holy"][0], 0.2)
    return S


def kk_kiemvuc(f):
    return a_field("kiem-khach", P["kk_holy"], f, (C[0] + 6, C[1]), 48, "swords", hits=hit_all((5, 7, 9, 11), 2))


def kk_huyetbao(f):
    S = a_explode("kiem-khach", P["kk_blood"], f, r=46, leech=True, hits=hit_all((5,), 2), star_n=10)
    if f < 4:  # đốt máu bản thân: giọt máu bốc từ người
        S.sparks((C[0], C[1] - 20), f / 4.0, 8, 14, P["kk_blood"], seed=11, up=True, size=2)
    return S


def kk_huyetanh(f):
    return a_dash("kiem-khach", P["kk_blood"], f, twice=True, mark="x", hits=(4,))


def kk_nhatkiem(f):
    S = stage("kiem-khach", f, {0: (6,), 1: (6,), 2: (6,), 3: (6,)}, dim=0.45 if 2 <= f <= 8 else 0.0)
    p = P["kk_god"]
    charge(S, HAND, p, f, 14, 18, last=4)
    if f < 5:
        S.sword((HAND[0] - 2, HAND[1] - 8 - f * 2), -math.pi / 2 + 0.3, 18 + f * 3, p, glow=0.6 + f * 0.25)
    if f == 5:
        S.flash((255, 255, 255), 0.55)
    t = seg(f, 5, 11)
    if t is not None:
        w = 22 * (1 - ease_in(t))
        if w > 1:
            S.streak((-10, HAND[1] + 8), (W + 10, HAND[1] - 4), w, p, tail=1.0)
        for k in range(5):
            x = 60 + k * 26
            S.crescent((x, HAND[1] + 4), 10, -1.0, 1.0, 5 * (1 - t), p, alpha=int(255 * (1 - t)))
        S.sparks((120, HAND[1] + 2), t, 20, 50, p, seed=3, spread=(-0.4, 0.4))
    for i in range(4):
        impact(S, (T[i][0], T[i][1] - 9), p, seg(f, 6, 10), 8, seed=i)
    return S


# Thợ Săn --------------------------------------------------------------
def ts_rain(f):
    return a_rain("tho-san", P["ts"], f, r=30)


def ts_pierce(f):
    S = a_projectile("tho-san", P["ts"], f, "arrow", size=1.3)
    for i, fr in ((0, 5), (1, 6), (2, 7)):
        t = seg(f, fr, fr + 2)
        if t is not None:
            S.ring((T[i][0], T[i][1] - 10), 6 + 6 * t, 1.5, P["ts_gold"], squash=1.0, where="fx")
    return S


def ts_lanban(f):
    pos = C if f < 2 else ((C[0] - 18, C[1]) if f > 4 else (C[0] - 9, C[1] - 6))
    S = a_projectile("tho-san", P["ts"], f, "arrow", count=3, spread=0.21, hits={0: (6,), 1: (6,), 2: (7,)})
    if 2 <= f <= 4:
        S.crescent((C[0] - 8, C[1] - 12), 12, math.radians(90), math.radians(330), 4, P["ts"], glow=0.6)
    t = seg(f, 5, 11)
    if t is not None:
        for k in range(2):
            a = f * 0.9 + k * math.pi
            S.crescent((pos[0], pos[1] - 4), 12, a, a + 1.6, 3, P["ts"], squash=SQ, glow=0.5, alpha=180)
    return S


def ts_eagle(f):
    return a_buff("tho-san", P["ts_gold"], f, glyph=_eagle_glyph)


def ts_tennay(f):
    return a_chain("tho-san", P["ts"], f, order=(0, 2, 4, 1), kind="arrow")


def ts_trap(f):
    return a_trap("tho-san", P["ts_trap"], f, [(T[0][0] - 4, T[0][1] + 2), (T[1][0] - 2, T[1][1] + 1)], "spike", {0: (6,), 1: (7,)})


def ts_lienxa(f):
    S = stage("tho-san", f, {0: (4, 5, 6, 7, 8, 9, 10, 11)})
    p = P["ts"]
    charge(S, HAND, p, f, 7, last=2)
    for k in range(8):
        t = seg(f, 3 + k, 4.2 + k)
        if t is not None:
            tip = towards(HAND, (T[0][0], T[0][1] - 10), t)
            S.arrow(tip, 0.08, 7, p, trail=14)
        impact(S, (T[0][0], T[0][1] - 10), p, seg(f, 4 + k, 5.5 + k), 4, n=6, seed=k, smoke=False)
    if 3 <= f <= 10:
        S.star((HAND[0] + 4, HAND[1]), 4 + (f % 2) * 2, 5, p, glow=0.7)
    return S


def ts_tendoc(f):
    S = a_projectile("tho-san", P["ts_poison"], f, "arrow", size=1.1)
    for i, fr in ((0, 5), (1, 6), (2, 7)):
        if f >= fr + 1:
            S.disc((T[i][0], T[i][1] - 4), 6, P["ts_poison"], squash=0.5, glow=0.5, alpha=140)
            S.sparks((T[i][0], T[i][1] - 6), ((f - fr) % 3) / 3.0, 4, 10, P["ts_poison"], seed=i, up=True, size=2)
            for k in range(min(3, (f - fr) // 2 + 1)):
                S.glyph((T[i][0] - 5 + k * 5, T[i][1] - 26), "poison", 3, P["ts_poison"])
    return S


def ts_thientien(f):
    return a_rain("tho-san", P["ts"], f, center=(136, 88), r=48, waves=10, dim=0.4, hits=hit_all((5, 6, 7, 8, 9, 10)))


def ts_phakhong(f):
    S = a_projectile("tho-san", P["ts_star"], f, "beam", size=1.1, hits={0: (5,), 1: (5,), 2: (6,), 4: (6,)})
    if 1 <= f <= 4:
        for k in range(3):
            S.ring((HAND[0] + 6, HAND[1]), 4 + k * 5 + f, 1, P["ts_star"], squash=1.6, where="fx", alpha=200)
    if f == 5:
        S.flash(P["ts_star"][0], 0.25)
    if 5 <= f <= 7:
        for i in (0, 1, 2):
            S.glyph((T[i][0], T[i][1] - 24), "eye", 4, P["ts_gold"])
    return S


def ts_tamlien(f):
    S = stage("tho-san", f, {0: (5, 7, 9), 1: (5, 7, 9), 2: (6, 8, 10)})
    pals = [P["ts"], P["ts_gold"], P["ts_star"]]
    charge(S, HAND, P["ts_star"], f, 8, last=3)
    for k in range(3):
        t = seg(f, 4 + 2 * k, 6 + 2 * k)
        if t is not None:
            tip = (HAND[0] + (W - HAND[0]) * ease_in(t * 0.5 + 0.5 * t), HAND[1] + 6 * t)
            S.arrow(tip, 0.06, 10, pals[k], trail=50)
        for i in (0, 1):
            impact(S, (T[i][0], T[i][1] - 9), pals[k], seg(f, 5 + 2 * k, 7 + 2 * k), 6, seed=k + i, smoke=False)
    return S


def ts_baimin(f):
    spots = [(C[0] + math.cos(a) * 34, C[1] + math.sin(a) * 34 * SQ) for a in (0.0, 1.2, 2.4, 3.6, 4.8)]
    spots[0] = (T[3][0], T[3][1] + 2)
    return a_trap("tho-san", P["ts_trap"], f, spots, "mine", {3: (6,)})


def ts_luoibay(f):
    S = stage("tho-san", f, hit_all((6,), 3))
    p = P["ts"]
    center = (140, 86)
    t = seg(f, 2, 6)
    if t is not None and t < 1:
        pos = towards(HAND, center, ease_out(t))
        y = pos[1] - 40 * math.sin(t * math.pi)
        sz = 4 + 20 * t
        d = S.draw("fx")
        for k in range(-2, 3):
            d.line((pos[0] - sz, y + k * sz / 3, pos[0] + sz, y + k * sz / 3), fill=p[1] + (230,))
            d.line((pos[0] + k * sz / 3, y - sz * 0.5, pos[0] + k * sz / 3, y + sz * 0.5), fill=p[1] + (230,))
    if f >= 6:
        S.decal(center, 34, p, runes=12, alpha=200)
        d = S.draw("fx")
        for k in range(-5, 6):
            d.line((center[0] - 34, center[1] - 12 + k * 3, center[0] + 34, center[1] - 4 + k * 3), fill=p[1] + (170,))
            d.line((center[0] + k * 6, center[1] - 30, center[0] + k * 6 - 4, center[1] + 12), fill=p[1] + (170,))
        for i in range(3):
            if f % 2 == 0:
                S.glyph((T[i][0], T[i][1] - 24), "chain", 3, p)
    impact(S, (center[0], center[1] - 8), p, seg(f, 6, 10), 10)
    return S


def ts_tinhvu(f):
    S = a_rain("tho-san", P["ts_star"], f, center=(140, 86), r=44, obj="star", waves=4, dim=0.55,
               hits={0: (6, 9), 2: (7, 10), 1: (8,)})
    if f < 4:
        for k in range(8):
            S.star((30 + k * 20, 8 + (k % 3) * 5), 2 + (f + k) % 2, 4, P["ts_star"], glow=0.8)
    return S


# Pháp Sư --------------------------------------------------------------
def ps_chain(f):
    return a_chain("phap-su", P["bolt"], f, order=(0, 2, 1, 4, 3))


def ps_banglao(f):
    S = a_projectile("phap-su", P["ice"], f, "shard", size=1.3)
    for i, fr in ((0, 5), (1, 6), (2, 7)):
        if f >= fr + 1:
            S.ring((T[i][0], T[i][1]), 9, 2, P["ice"], alpha=200)
            S.poly([(T[i][0] - 7, T[i][1]), (T[i][0] - 5, T[i][1] - 6), (T[i][0] - 2, T[i][1])], P["ice"], glow=0.3)
    return S


def ps_meteor(f):
    return a_meteor("phap-su", P["fire"], f, obj="meteor")


def ps_barrier(f):
    S = a_buff("phap-su", P["arcane"], f, ring=True, rise=False)
    t = seg(f, 4, 11)
    if t is not None:
        S.dome(C, 22, P["arcane"], min(1.0, 0.3 + t * 3), crack=0 if f < 9 else f - 8)
        if f in (8, 10):
            S.star((C[0] + 18, C[1] - 18), 5, 5, P["arcane"], glow=0.8)
    return S


def ps_hoatuong(f):
    return a_field("phap-su", P["fire"], f, (134, 88), 40, "fire_wall", hits=hit_all((5, 7, 9, 11), 2))


def ps_nova(f):
    return a_explode("phap-su", P["ice"], f, r=46, spikes=10, root=True, frost=True, hits=hit_all((5,), 2))


def ps_muabang(f):
    return a_rain("phap-su", P["ice"], f, r=32, obj="shard", waves=5)


def ps_causam(f):
    S = stage("phap-su", f, {0: (6, 8), 3: (7,), 1: (9,), 2: (10,)})
    p = P["bolt"]
    charge(S, HAND, p, f, 9)
    t = seg(f, 3, 10)
    if t is not None:
        pos = towards(HAND, (150, 78), t)
        S.orb(pos, 6, p)
        S.ring((pos[0], pos[1] + 14), 10, 1, p, alpha=140)
        for k, i in enumerate((0, 3, 1, 2)):
            if f == 6 + k and abs(T[i][0] - pos[0]) < 60:
                S.bolt(pos, (T[i][0], T[i][1] - 10), p, seed=f + k, w=1.6, branches=1)
    if f >= 10:
        impact(S, (150, 78), p, seg(f, 10, 12), 16, n=12, seed=3)
    for i, fr in ((0, 6), (3, 7), (1, 9)):
        impact(S, (T[i][0], T[i][1] - 9), p, seg(f, fr, fr + 2), 5, seed=i, smoke=False)
    return S


def ps_thienhoa(f):
    S = stage("phap-su", f, hit_all((5, 8, 10)), dim=0.4)
    center = (138, 88)
    charge(S, HAND, P["arcane"], f, 10, last=3)
    if f < 4:
        S.decal(center, 40, P["arcane"], rot=f * 0.3, runes=15, alpha=200)
    # Ba pha tách màu: Hoả (4–6) → Băng (7–8) → Sét (9–11)
    tf = seg(f, 3, 5)
    if tf is not None and tf < 1:
        S.disc((center[0] - 30 * (1 - tf), center[1] - 80 * (1 - tf)), 8, P["fire"], glow=1.6)
    if 5 <= f <= 6:
        S.star((center[0], center[1] - 8), 34 - (f - 5) * 10, 12, P["fire"], glow=1.6)
        S.ring(center, 36, 4, P["fire"])
    if 7 <= f <= 8:
        for k in range(10):
            a = k * math.tau / 10
            b = (center[0] + math.cos(a) * 30, center[1] + math.sin(a) * 30 * SQ)
            S.poly([(b[0] - 3, b[1]), (b[0], b[1] - 14), (b[0] + 3, b[1])], P["ice"], glow=0.8)
        S.ring(center, 34, 3, P["ice"])
    if f >= 9:
        for k, i in enumerate((0, 1, 2, 3)):
            S.bolt((T[i][0] + 4, -2), (T[i][0], T[i][1] - 10), P["bolt"], seed=f * 3 + k, w=2.6)
        if f == 9:
            S.flash((255, 255, 255), 0.3)
    S.smoke(center, seg(f, 6, 11), 8, 6, DUST, spread=30)
    return S


def ps_thienloi(f):
    return a_chain("phap-su", P["bolt"], f, order=(0, 1, 2, 3, 4), from_sky=True, dim=0.35)


def ps_bangphong(f):
    S = a_explode("phap-su", P["ice"], f, r=70, spikes=16, root=True, frost=True, hits=hit_all((5,)), dim=0.25)
    return S


def ps_trieuhoi(f):
    units = [("xuong-no", (96, 90)), ("xuong-no", (82, 100)), ("xuong-no", (100, 76))]
    return a_summon("phap-su", P["necro"], f, units, circle_r=11)


def ps_khidoc(f):
    S = a_field("phap-su", P["necro"], f, (134, 88), 38, "poison", hits=hit_all((5, 7, 9, 11), 3))
    for i in range(3):
        if f >= 6:
            for k in range(min(3, (f - 4) // 2)):
                S.glyph((T[i][0] - 5 + k * 5, T[i][1] - 26), "poison", 3, P["necro"])
    return S


def ps_nguhanh(f):
    S = stage("phap-su", f, hit_all((6, 9)), dim=0.3)
    center = (136, 82)
    keys = ["metal", "wood", "ice", "fire", "earth"]
    charge(S, HAND, P["arcane"], f, 9)
    S.decal((center[0], center[1] + 6), 38, P["arcane"], rot=-f * 0.2, runes=5, alpha=190)
    if f >= 2:
        for k, key in enumerate(keys):
            a = f * 0.55 + k * math.tau / 5
            rr = 30 if f < 9 else 30 * (1 - (f - 9) / 3.0)
            pos = (center[0] + math.cos(a) * rr, center[1] + math.sin(a) * rr * SQ - 10)
            S.orb(pos, 5, P[key])
            S.crescent((center[0], center[1] - 10), rr, a - 0.7, a - 0.05, 3, P[key], squash=SQ, glow=0.4, alpha=170)
    if f >= 10:
        S.star((center[0], center[1] - 10), 26, 10, P["arcane"], glow=1.8)
        S.flash((255, 255, 255), 0.18 if f == 10 else 0.0)
    return S


# Hộ Vệ ----------------------------------------------------------------
def hv_khienchan(f):
    S = stage("ho-ve", f, {0: (5,), 3: (5,)})
    p = P["hv_steel"]
    charge(S, (C[0] + 12, C[1] - 14), p, f, 9)
    if 3 <= f <= 6:
        k = f - 3
        S.shield((C[0] + 18 + k * 6, C[1] - 14), 7, p, glow=1.0)
        S.crescent((C[0] + 10, C[1] - 10), 28 + k * 10, -0.8, 0.8, 9 - k, p, squash=0.7, alpha=int(255 * (1 - k * 0.2)))
    for i in (0, 3):
        impact(S, (T[i][0], T[i][1] - 9), p, seg(f, 5, 9), 8, seed=i)
        if f >= 6:
            S.glyph((T[i][0], T[i][1] - 24), "stun", 6, P["hv"])
    return S


def hv_khieukhich(f):
    S = a_explode("ho-ve", P["hv"], f, r=58, implode=False, hits=hit_all((5,)), star_n=8)
    t = seg(f, 5, 11)
    if t is not None:  # kéo quái về phía mình: mũi tên chevron chạy vào
        for i in range(4):
            pos = towards((T[i][0], T[i][1] - 12), (C[0] + 20, C[1] - 12), ease_out(t) * 0.5)
            S.crescent((pos[0] + 6, pos[1]), 6, 2.3, 4.0, 3, P["hv"], glow=0.6)
            S.glyph((T[i][0], T[i][1] - 26), "eye", 4, P["kk"])
    return S


def hv_laokhien(f):
    S = a_dash("ho-ve", P["hv_steel"], f, end=(112, 86), hits=(4,), afterimage=2)
    if 3 <= f <= 5:
        S.shield((f * 18 + 28, C[1] - 16), 9, P["hv_steel"], glow=1.2)
    return S


def hv_khienthep(f):
    S = a_buff("ho-ve", P["hv_steel"], f, glyph=_shield_glyph, rise=False)
    t = seg(f, 5, 11)
    if t is not None:
        for k in range(4):
            a = f * 0.5 + k * math.tau / 4
            S.shield((C[0] + math.cos(a) * 18, C[1] - 16 + math.sin(a) * 7), 4, P["hv_steel"], glow=0.5, alpha=220)
    return S


def hv_chandia(f):
    return a_explode("ho-ve", P["hv_earth"], f, r=50, debris=True, stun=True, hits=hit_all((5,), 2), star_n=8)


def hv_phanthuan(f):
    S = stage("ho-ve", f, {0: (5, 9), 1: (6, 8), 2: (6,)})
    p = P["hv_steel"]
    charge(S, HAND, p, f, 8)
    t = seg(f, 3, 11)
    if t is not None:
        u = math.sin(t * math.pi)
        pos = (HAND[0] + 120 * u, HAND[1] + 6 * math.sin(t * math.tau))
        S.disc(pos, 7, p, glow=1.0)
        S.crescent(pos, 9, f * 1.3, f * 1.3 + 2.2, 3, p, glow=0.6)
        prev = (HAND[0] + 120 * math.sin(max(0, t - 0.12) * math.pi), pos[1])
        S.streak(prev, pos, 5, p, alpha=150, glow=0.4)
    for i, fr in ((0, 5), (1, 6), (2, 6)):
        impact(S, (T[i][0], T[i][1] - 9), p, seg(f, fr, fr + 3), 6, seed=i, smoke=False)
    return S


def hv_phanquyet(f):
    return a_meteor("ho-ve", P["hv"], f, center=(132, 88), obj="hammer", r=28)


def hv_xungphong(f):
    S = a_dash("ho-ve", P["hv"], f, end=(150, 86), hits=(4,), afterimage=4)
    if f >= 6:
        for i in range(3):
            S.glyph((T[i][0], T[i][1] - 24), "stun", 6, P["hv"])
    return S


def hv_thanhbatdiet(f):
    S = a_buff("ho-ve", P["hv"], f, rise=True)
    t = seg(f, 4, 11)
    if t is not None:
        S.dome(C, 30, P["hv"], 1.0, alpha=150)
        for k in range(6):
            a = -f * 0.4 + k * math.tau / 6
            S.shield((C[0] + math.cos(a) * 32, C[1] - 6 + math.sin(a) * 12), 5, P["hv"], glow=0.7)
        S.ring(C, 40 + (f % 3) * 6, 1.5, P["hv"], alpha=160)
    for i in range(2):
        impact(S, (T[i][0], T[i][1] - 9), P["hv"], seg(f, 6, 8), 5, seed=i, smoke=False)
    return S


def hv_thanhquang(f):
    S = stage("ho-ve", f, {0: (5,), 3: (5,), 1: (6,)})
    p = P["hv"]
    charge(S, HAND, p, f, 10)
    t = seg(f, 4, 9)
    if t is not None:
        r = 30 + 60 * ease_out(t)
        S.crescent((C[0], C[1] - 12), r, -1.05, 1.05, 14 * (1 - t) + 2, p, squash=0.7, alpha=int(255 * (1 - t * 0.5)), head=0.5)
        if t < 0.3:
            S.flash(p[0], 0.15)
    S.sparks((C[0], C[1] - 6), seg(f, 6, 11), 10, 18, pal("#f4fff0", "#c8ffb0", "#6ad870", "#1c6a2a"), seed=2, up=True)  # hồi máu
    for i, fr in ((0, 5), (3, 5), (1, 6)):
        impact(S, (T[i][0], T[i][1] - 9), p, seg(f, fr, fr + 4), 7, seed=i)
    return S


def hv_thanhvuc(f):
    S = a_field("ho-ve", P["hv"], f, (C[0] + 4, C[1]), 44, "holy", hits=hit_all((6, 9), 2))
    if f >= 5 and f % 3 == 2:
        S.sparks((C[0], C[1] - 10), 0.5, 8, 12, pal("#f4fff0", "#c8ffb0", "#6ad870", "#1c6a2a"), seed=f, up=True)
    return S


def hv_thietchuy(f):
    S = a_explode("ho-ve", P["hv_earth"], f, r=60, debris=True, stun=True, hits=hit_all((5,)), star_n=8, implode=False)
    if f < 5:
        S.hammer((C[0] + 8, C[1] - 30 + f * 6), -math.pi / 2 + f * 0.5, 26, P["hv_steel"], glow=0.6 + f * 0.2)
    t = seg(f, 5, 11)
    if t is not None:  # vết nứt toả ra
        d = S.draw("ground")
        for k in range(7):
            a = k * math.tau / 7 + 0.3
            L = 60 * ease_out(min(1, t * 2))
            pts = [C]
            for j in range(1, 5):
                pts.append((C[0] + math.cos(a + (j % 2) * 0.15) * L * j / 4, C[1] + math.sin(a + (j % 2) * 0.15) * L * j / 4 * SQ))
            d.line(pts, fill=P["hv_earth"][3] + (255,), width=2)
            d.line(pts, fill=P["hv_earth"][1] + (200,), width=1)
    return S


def hv_thanhdong(f):
    S = a_explode("ho-ve", P["hv_steel"], f, r=44, implode=True, hits=hit_all((5,), 2), star_n=6)
    t = seg(f, 6, 11)
    if t is not None:
        S.dome(C, 24, P["hv_steel"], min(1.0, 0.4 + t * 2), alpha=170)
    if f < 4:
        S.shield((C[0] + 6, C[1] - 18), 6 + f, P["hv_steel"], glow=0.5 + f * 0.3)
    return S


def hv_thienthuan(f):
    return a_meteor("ho-ve", P["hv"], f, center=(124, 88), obj="shield", r=40, hits=hit_all((5,)), dim=0.4)


# Triệu Hồi Sư ---------------------------------------------------------
def th_soibong(f):
    return a_summon("trieu-hoi-su", P["th"], f, [("soi-bong", (96, 90))])


def th_linhtien(f):
    return a_projectile("trieu-hoi-su", P["th_teal"], f, "orb", count=5, spread=0.17, size=0.8,
                        hits={0: (6,), 1: (6,), 2: (7,), 3: (6,)})


def th_tieuquy(f):
    return a_summon("trieu-hoi-su", P["th"], f, [("tieu-quy", (92, 92)), ("tieu-quy", (80, 102)), ("tieu-quy", (98, 78))], circle_r=10)


def th_lienket(f):
    def aura(S, f):
        if f >= 4:
            d = S.draw("fx")
            a, b = (C[0] + 4, C[1] - 18), (96, 84)
            pts = [(lerp(a[0], b[0], k / 10.0), lerp(a[1], b[1], k / 10.0) + math.sin(k * 1.2 + f) * 3) for k in range(11)]
            S._glow_mask(lambda dd, s, fl: dd.line(pts, fill=fl, width=4), P["th_teal"][2], 1.0)
            d.line(pts, fill=P["th_teal"][2] + (255,), width=2)
            d.line(pts, fill=P["th_teal"][0] + (255,), width=1)
            k = (f * 2) % 11
            S.disc(pts[10 - k], 2.5, P["th_teal"], glow=1.0)
            S.ring((96, 96), 10, 1.5, P["th_teal"], alpha=220)
    S = a_summon("trieu-hoi-su", P["th_teal"], f, [], aura=aura)
    S.put("soi-bong", (96, 96), "idle", f % 2)
    if f >= 5:
        S.sparks((96, 92), (f % 3) / 3.0, 6, 14, P["th_teal"], seed=f, up=True)
    return S


def th_thachquy(f):
    S = a_summon("trieu-hoi-su", P["hv_earth"], f, [("thach-quy", (98, 92))], circle_r=16)
    if f == 6:
        S.flash(P["hv_earth"][1], 0.15)
    S.sparks((98, 90), seg(f, 6, 11), 12, 30, (P["hv_earth"][0], (180, 150, 110), (120, 90, 60), (60, 40, 30)), seed=5, grav=1.0, size=2.5)
    return S


def th_hoadieu(f):
    S = a_projectile("trieu-hoi-su", P["th_dragon"], f, "orb", size=1.2, hits={0: (5,), 1: (6,), 2: (7,)})
    t = seg(f, 4, 8)
    if t is not None:  # chim lửa: thân cầu + hai cánh trăng khuyết vỗ
        x = HAND[0] + (W + 20 - HAND[0]) * ease_in(t * 0.6 + 0.4 * t)
        y = HAND[1] + 10 * t - 2
        flap = 0.5 if f % 2 else -0.2
        S.crescent((x - 4, y + 6), 12, math.radians(200) + flap, math.radians(280) + flap, 5, P["th_dragon"], glow=0.8)
        S.crescent((x - 4, y - 6), 12, math.radians(80) - flap, math.radians(160) - flap, 5, P["th_dragon"], glow=0.8)
    for i, fr in ((0, 5), (1, 6), (2, 7)):
        if f > fr:
            S.sparks((T[i][0], T[i][1] - 6), ((f - fr) % 3) / 3.0, 5, 10, P["fire"], seed=i, up=True)
    return S


def th_linhtran(f):
    S = a_field("trieu-hoi-su", P["th"], f, (100, 90), 36, "spirit", hits={})
    S.put("soi-bong", (94, 92), "idle", f % 2)
    S.put("tieu-quy", (110, 86), "idle", f % 2)
    if f >= 5:
        for pos in ((94, 70), (110, 64)):
            S.crescent(pos, 4, -2.6, -0.5, 2, P["th"], glow=0.8)
    return S


def th_linhung(f):
    S = a_summon("trieu-hoi-su", P["th_teal"], f, [("linh-ung", (86, 70)), ("linh-ung", (100, 92))], circle_r=10)
    if f >= 8:
        for k, (a, i) in enumerate((((86, 60), 0), ((100, 82), 1))):
            t = seg(f, 8, 10)
            if t is not None:
                S.streak(a, towards(a, (T[i][0], T[i][1] - 10), t), 2, P["th_teal"], alpha=220)
    return S


def th_quandoan(f):
    units = [("linh-hon", (70 + (k % 5) * 14, 76 + (k // 5) * 18 + (k % 2) * 4)) for k in range(10)]
    S = stage("trieu-hoi-su", f, mob_count=2, dim=0.4)
    p = P["th"]
    S.decal((98, 88), 50, p, rot=f * 0.3, runes=10, alpha=210)
    charge(S, HAND, p, f, 10)
    for k, (sid, pos) in enumerate(units):
        t = seg(f, 3 + k * 0.4, 6 + k * 0.4)
        if t is not None and t < 1:
            S.pillar(pos, 6, 40, p, alpha=int(255 * (1 - t)), glow=0.8)
        if f >= 4 + k * 0.4:
            w = max(0.0, 1 - (f - 4 - k * 0.4) / 2.5)
            S.put(sid, pos, "idle", f % 2, white=w)
    if f == 5:
        S.flash(p[1], 0.2)
    S.sparks((98, 86), seg(f, 6, 11), 18, 50, p, seed=4, up=True)
    return S


def th_aulong(f):
    S = a_summon("trieu-hoi-su", P["th_dragon"], f, [("au-long", (98, 90))], circle_r=18)
    if f >= 9:  # phun lửa nổ lan
        S.streak((104, 76), (T[0][0] - 4, T[0][1] - 10), 6, P["fire"])
        impact(S, (T[0][0], T[0][1] - 9), P["fire"], seg(f, 9, 12), 12, seed=2)
    return S


def th_longhong(f):
    S = a_explode("trieu-hoi-su", P["th_dragon"], f, r=40, implode=True, stun=False, hits=hit_all((5, 6), 2), star_n=10)
    S.put("au-long", (92, 98), "attack" if 4 <= f <= 7 else "idle", min(2, max(0, f - 4)))
    t = seg(f, 5, 10)
    if t is not None:
        for k in range(3):
            rr = 10 + 30 * ease_out(max(0, t - k * 0.15))
            S.crescent((96, 84), rr, -0.9, 0.9, 3, P["th_dragon"], squash=0.8, alpha=int(255 * (1 - t)))
    return S


def th_loidodang(f):
    S = stage("trieu-hoi-su", f, {0: (6, 9), 1: (7, 10), 2: (8, 11)})
    p = P["th_storm"]
    base = (132, 90)
    charge(S, HAND, p, f, 8)
    t = seg(f, 1, 4)
    if t is not None:
        S.pillar(base, 10, 80 * (1 - t), p, alpha=200)
    if f >= 3:
        S.decal(base, 30, p, rot=f * 0.3, runes=8, alpha=170)
        d = S.draw("fx")
        d.rectangle((base[0] - 4, base[1] - 26, base[0] + 4, base[1]), fill=p[3] + (255,))
        d.rectangle((base[0] - 3, base[1] - 25, base[0] + 3, base[1] - 1), fill=(80, 70, 110, 255))
        for y in (-22, -14, -6):
            d.rectangle((base[0] - 2, base[1] + y, base[0] + 2, base[1] + y + 2), fill=p[1] + (255,))
        S.orb((base[0], base[1] - 30), 4, p)
    for i, fr in ((0, 6), (1, 7), (2, 8), (0, 9), (1, 10), (2, 11)):
        if f == fr:
            S.bolt((base[0], base[1] - 30), (T[i][0], T[i][1] - 10), p, seed=fr, w=2.0)
        impact(S, (T[i][0], T[i][1] - 9), p, seg(f, fr, fr + 1.5), 5, seed=fr, smoke=False)
    return S


def th_phongdodang(f):
    S = a_field("trieu-hoi-su", P["th_wind"], f, (128, 88), 40, "wind", hits={})
    base = (128, 90)
    if f >= 3:
        d = S.draw("fx")
        d.rectangle((base[0] - 4, base[1] - 24, base[0] + 4, base[1]), fill=(40, 70, 60, 255))
        d.rectangle((base[0] - 3, base[1] - 23, base[0] + 3, base[1] - 1), fill=(70, 120, 100, 255))
        S.crescent((base[0], base[1] - 28), 6, f * 0.8, f * 0.8 + 4, 2, P["th_wind"], glow=0.8)
    S.put("soi-bong", (86, 94), "run" if f >= 5 else "idle", f % 4)
    if f >= 5:
        S.glyph((86, 64), "eye", 3, P["th_wind"])
    return S


def th_kylan(f):
    S = a_summon("trieu-hoi-su", P["th_qilin"], f, [("ky-lan", (98, 90))], circle_r=22)
    S.dim(0.4 if f < 9 else 0.0)
    for pos in ((76, 100), (110, 102)):
        S.put("soi-bong", pos, "idle", f % 2)
        if f >= 7:
            S.sparks((pos[0], pos[1] - 4), (f - 7) / 4.0, 6, 14, pal("#f4fff0", "#c8ffb0", "#6ad870", "#1c6a2a"), seed=pos[0], up=True)
    if f >= 9:
        impact(S, (T[0][0], T[0][1] - 9), P["th_qilin"], seg(f, 9, 12), 14, n=10, seed=4)
    return S


SKILLS = {
    "kiem-khach": [("spin", "Xoáy Kiếm", kk_spin), ("dash", "Đột Kích", kk_dash), ("wave", "Trảm Phong", kk_wave),
                   ("kiemy", "Kiếm Ý", kk_kiemy), ("lientram", "Nguyệt Ảnh Liên Trảm", kk_lientram),
                   ("hongkiem", "Hống Kiếm", kk_hongkiem), ("kiemvu", "Kiếm Vũ", kk_kiemvu), ("phikiem", "Phi Kiếm", kk_phikiem),
                   ("vankiem", "Vạn Kiếm Quy Tông", kk_vankiem), ("thanhkiem", "Thánh Kiếm Trảm", kk_thanhkiem),
                   ("kiemvuc", "Kiếm Vực", kk_kiemvuc), ("huyetbao", "Huyết Bạo", kk_huyetbao),
                   ("huyetanh", "Huyết Ảnh", kk_huyetanh), ("nhatkiem", "Nhất Kiếm Khai Thiên", kk_nhatkiem)],
    "tho-san": [("rain", "Vũ Tiễn", ts_rain), ("pierce", "Xuyên Tâm Tiễn", ts_pierce), ("lanban", "Lộn Nhào", ts_lanban),
                ("eagle", "Ưng Nhãn", ts_eagle), ("tennay", "Tên Nảy", ts_tennay), ("trap", "Bẫy Gai", ts_trap),
                ("lienxa", "Liên Xạ", ts_lienxa), ("tendoc", "Tên Độc", ts_tendoc), ("thientien", "Thiên Tiễn Vũ", ts_thientien),
                ("phakhong", "Phá Không Tiễn", ts_phakhong), ("tamlien", "Tam Liên Thần Tiễn", ts_tamlien),
                ("baimin", "Bãi Mìn", ts_baimin), ("luoibay", "Lưới Bẫy", ts_luoibay), ("tinhvu", "Thiên Lạc Tinh Vũ", ts_tinhvu)],
    "phap-su": [("chain", "Sét Chuỗi", ps_chain), ("banglao", "Băng Lao", ps_banglao), ("meteor", "Thiên Thạch", ps_meteor),
                ("barrier", "Pháp Thuẫn", ps_barrier), ("hoatuong", "Hoả Tường", ps_hoatuong), ("nova", "Băng Ngục", ps_nova),
                ("muabang", "Mưa Băng", ps_muabang), ("causam", "Cầu Sấm", ps_causam),
                ("thienhoa", "Thiên Tai Nguyên Tố", ps_thienhoa), ("thienloi", "Thiên Lôi", ps_thienloi),
                ("bangphong", "Băng Phong Thiên Hạ", ps_bangphong), ("trieuhoi", "Triệu Hồi Xương", ps_trieuhoi),
                ("khidoc", "Khí Độc Tử Vong", ps_khidoc), ("nguhanh", "Ngũ Hành Luân Chuyển", ps_nguhanh)],
    "ho-ve": [("khienchan", "Khiên Chấn", hv_khienchan), ("khieukhich", "Khiêu Khích", hv_khieukhich),
              ("laokhien", "Lao Khiên", hv_laokhien), ("khienthep", "Khiên Thép", hv_khienthep), ("chandia", "Chấn Địa", hv_chandia),
              ("phanthuan", "Phi Thuẫn", hv_phanthuan), ("phanquyet", "Phán Quyết", hv_phanquyet),
              ("xungphong", "Xung Phong", hv_xungphong), ("thanhbatdiet", "Thành Bất Diệt", hv_thanhbatdiet),
              ("thanhquang", "Thánh Quang Trảm", hv_thanhquang), ("thanhvuc", "Thánh Vực", hv_thanhvuc),
              ("thietchuy", "Thiết Chuỳ Phá Địa", hv_thietchuy), ("thanhdong", "Thành Đồng", hv_thanhdong),
              ("thienthuan", "Thiên Thuẫn Giáng Thế", hv_thienthuan)],
    "trieu-hoi-su": [("soibong", "Triệu Hồi Sói Bóng", th_soibong), ("linhtien", "Linh Tiễn", th_linhtien),
                     ("tieuquy", "Triệu Hồi Tiểu Quỷ", th_tieuquy), ("lienket", "Liên Kết Linh Hồn", th_lienket),
                     ("thachquy", "Gọi Thạch Quỷ", th_thachquy), ("hoadieu", "Hoả Điểu", th_hoadieu),
                     ("linhtran", "Linh Trận", th_linhtran), ("linhung", "Gọi Linh Ưng", th_linhung),
                     ("quandoan", "Quân Đoàn Linh Hồn", th_quandoan), ("aulong", "Gọi Ấu Long", th_aulong),
                     ("longhong", "Long Hống", th_longhong), ("loidodang", "Lôi Đồ Đằng", th_loidodang),
                     ("phongdodang", "Phong Đồ Đằng", th_phongdodang), ("kylan", "Kỳ Lân Giáng Thế", th_kylan)],
}
CLASS_LABEL = {"kiem-khach": "Kiem Khach", "tho-san": "Tho San", "phap-su": "Phap Su", "ho-ve": "Ho Ve", "trieu-hoi-su": "Trieu Hoi Su"}


# ---------------------------------------------------------------- xuất
def _ascii(s):
    import unicodedata
    s = s.replace("đ", "d").replace("Đ", "D")
    return unicodedata.normalize("NFKD", s).encode("ascii", "ignore").decode()


def _card(frame, cls, idx, name, f):
    big = frame  # render() đã trả ảnh W×SCALE (HD: vẽ ×6 rồi thu nhỏ khử răng cưa)
    card = Image.new("RGB", (big.width, big.height + 30), (12, 14, 24))
    card.paste(big, (0, 0))
    d = ImageDraw.Draw(card)
    y = big.height
    d.text((8, y + 4), "%s / %02d / %s" % (CLASS_LABEL[cls], idx, _ascii(name)), fill=(240, 240, 248))
    d.text((8, y + 17), "FX-1 HD - trong game: tests/fx1_smoke.gd", fill=(120, 170, 255))
    x0 = big.width - 12 * 22 - 8
    for k in range(NF):  # dải tiến trình: vàng = tụ lực, đỏ = phát/va chạm, lam = tan
        col = (220, 180, 60) if k < 4 else ((240, 80, 70) if k < 6 else (90, 140, 230))
        box = (x0 + k * 22, y + 6, x0 + k * 22 + 18, y + 12)
        d.rectangle(box, fill=col if k == f else tuple(v // 3 for v in col))
    d.text((x0, y + 16), PHASE[f], fill=(200, 200, 210))
    return card


def export(only=None):
    count = 0
    sheets = {}
    for cls, skills in SKILLS.items():
        folder = os.path.join(OUT, cls)
        os.makedirs(folder, exist_ok=True)
        keyframes = []
        for idx, (sid, name, fn) in enumerate(skills, 1):
            if only and sid not in only:
                continue
            frames = [fn(f).render() for f in range(NF)]
            cards = [_card(fr, cls, idx, name, k) for k, fr in enumerate(frames)]
            stem = os.path.join(folder, "%02d-%s" % (idx, sid))
            # GIF duyệt thu 75% + 128 màu (bước 4 đề xuất: thư mục 30 MB → nhẹ hơn); PNG dải khung giữ độ phân giải đầy đủ
            small = [c.resize((c.width * 3 // 4, c.height * 3 // 4), Image.LANCZOS).convert("P", palette=Image.Palette.ADAPTIVE, colors=128) for c in cards]
            small[0].save(stem + ".gif", save_all=True, append_images=small[1:], duration=DUR, loop=0)
            pick = [1, 3, 4, 5, 7, 10]
            strip = Image.new("RGB", (W * 2 * 3, H * 2 * 2), (0, 0, 0))
            for k, fi in enumerate(pick):
                strip.paste(frames[fi].resize((W * 2, H * 2), Image.LANCZOS), ((k % 3) * W * 2, (k // 3) * H * 2))
            strip.save(stem + ".png")
            keyframes.append((idx, name, frames[5]))
            count += 1
        if keyframes and not only:
            cols = 7
            rows = (len(keyframes) + cols - 1) // cols
            sh = Image.new("RGB", (cols * W * 2, rows * (H * 2 + 16)), (10, 12, 20))
            d = ImageDraw.Draw(sh)
            for k, (idx, name, img) in enumerate(keyframes):
                x, y = (k % cols) * W * 2, (k // cols) * (H * 2 + 16)
                sh.paste(img.resize((W * 2, H * 2), Image.LANCZOS), (x, y))
                d.text((x + 4, y + H * 2 + 2), "%02d %s" % (idx, _ascii(name)), fill=(230, 230, 240))
            sh.save(os.path.join(OUT, cls + ".png"))
            sheets[cls] = sh
    return count


if __name__ == "__main__":
    only = set(sys.argv[1:]) or None
    print("ok: %d skill FX" % export(only))
