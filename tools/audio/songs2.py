"""MU-1 (docs/46): nhạc nền thế hệ 2 — 13 bài, 5 nhạc báo, 11 lớp âm môi trường (OGG Vorbis stereo 44,1 kHz).

    python tools/audio/songs2.py                 # sinh tất cả (song song nhiều tiến trình, vài phút)
    python tools/audio/songs2.py forest st_boss  # chỉ các id này
    python tools/audio/songs2.py --list          # liệt kê id

Ra: godot/assets/audio/music/<id>.ogg (+ <id>_combat.ogg — tầng chiến đấu S4 của bài khám phá / hang), godot/assets/audio/stinger/<id>.ogg, godot/assets/audio/ambient/<id>.ogg.
Cần numpy + soundfile (pip install numpy soundfile).

Mỗi bài = dữ liệu ở SONGS: nhịp, chủ âm, vòng hợp âm (ký hiệu La Mã theo chủ âm) cho từng đoạn, 2 câu giai điệu soạn tay
(độ lệch nửa cung so với nốt gốc của giai điệu, "r" = nghỉ, mỗi câu 8 ô nhịp = 32 phách), nhạc cụ theo vai.
Cấu trúc: dạo đầu (I, 4 ô) → A (câu A) → B (câu B) → C (lắng: đàn gảy hát lại câu A) → A' (câu A + bè) → kết (O, 4 ô).
Bài khám phá phát 1 lượt rồi nghỉ (S2 — audio_manager.gd); làng, hang, boss lặp liền mạch (đuôi nốt quấn về đầu).
"""
import os
import sys
from multiprocessing import Pool

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import inst2 as I  # noqa: E402
from inst2 import SR  # noqa: E402

ROOT = os.path.dirname(os.path.dirname(HERE))
OUT = os.path.join(ROOT, "godot", "assets", "audio")

ROMAN = {"i": (0, "min"), "I": (0, "maj"), "bII": (1, "maj"), "ii": (2, "min"), "bIII": (3, "maj"), "iii": (4, "min"),
         "iv": (5, "min"), "IV": (5, "maj"), "bv": (6, "maj"), "v": (7, "min"), "V": (7, "maj"), "bVI": (8, "maj"),
         "vi": (9, "min"), "bVII": (10, "maj"), "bvii": (10, "min")}
PENT = {"min": [0, 3, 5, 7, 10], "maj": [0, 2, 4, 7, 9], "hijaz": [0, 1, 4, 5, 7, 8, 10], "dark": [0, 1, 3, 6, 7, 10]}

# ------------------------------------------------------------------ dữ liệu bài
SONGS = {
    "village": dict(desc="Làng Thanh Thạch — êm, ấm (Rê trưởng ngũ cung)", bpm=76, tonic=62, mode="maj", loop=True, target=-19.0,
        prog={"I": "I IV I V", "A": "I vi IV V I vi V I", "B": "IV V iii vi IV V I I"},
        melA="4/1 7/1 9/1.5 7/.5  9/1 12/1 9/2  7/1.5 4/.5 2/1 0/1  2/3 r/1  4/1 7/.5 9/.5 12/1.5 14/.5  12/1 9/1 7/2  4/.5 7/.5 9/1 7/1 2/1  0/4",
        melB="12/2 9/1 7/1  9/1.5 7/.5 4/2  4/1 7/1 9/1 7/1  9/4  7/1 9/1 12/2  14/1.5 12/.5 9/1 7/1  4/1 2/1 0/2  0/2 r/2",
        leadA="dizi", leadB="erhu", lead_oct=0, arp="zheng", perc="frame", fx=["chimes"], form="I A B A2 O"),
    "forest": dict(desc="Rừng Sương — bí ẩn (La thứ ngũ cung)", bpm=84, tonic=57, mode="min", target=-18.0,
        prog={"I": "i bVI bIII bVII", "A": "i bVI bIII bVII i bVI bVII i", "B": "bVI bVII v i bVI bVII i v"},
        melA="7/1.5 5/.5 3/1 0/1  3/1 5/.5 3/.5 0/2  -2/1 0/.5 3/.5 7/2  5/3 r/1  7/1.5 10/.5 12/1 10/.5 7/.5  5/1 3/1 0/2  -2/.5 0/.5 3/1 5/1 3/.5 5/.5  0/4",
        melB="0/2 3/1 5/1  5/1.5 3/.5 -2/2  -5/1 -2/1 0/1 -2/1  0/4  3/2 5/1 7/1  10/1.5 7/.5 5/2  3/1 5/.5 3/.5 0/2  -5/2 r/2",
        leadA="dizi", leadB="erhu", arp="zheng", perc="frame", fx=["chimes"]),
    "core": dict(desc="Lõi Sương / hang — u ám, thưa (Mi thứ, màu Phrygian)", bpm=64, tonic=52, mode="min", loop=True, target=-20.0, rt60=3.6,
        prog={"I": "i i bII i", "A": "i bII i bVII i bVI bVII i", "B": "iv i bVI v iv bII i i"},
        melA="7/2 5/1 3/1  1/3 r/1  0/1 3/1 5/1.5 3/.5  2/4  7/1.5 8/.5 7/1 5/1  3/2 0/2  -2/1 0/1 2/2  0/4",
        melB="5/2 8/1 7/1  7/3 r/1  8/1 7/1 3/2  7/4  12/2 10/1 8/1  8/1.5 5/.5 1/2  3/1 1/1 0/2  0/2 r/2",
        leadA="erhu", leadB="dizi", arp="zheng", arp_sparse=True, perc="none", fx=["chimes"], form="I A B A2 O"),
    "plains": dict(desc="Đồng Bằng Gió Hú — thoáng, sáng (Mi trưởng ngũ cung)", bpm=104, tonic=64, mode="maj", target=-18.0,
        prog={"I": "I V vi IV", "A": "I V vi IV I V IV I", "B": "vi IV I V vi IV V V"},
        melA="0/.5 2/.5 4/1 7/1 4/1  7/1.5 9/.5 7/1 2/1  9/1 12/1 9/1 4/1  0/3 r/1  4/.5 7/.5 9/1 12/1.5 9/.5  14/1 7/1 9/1 7/1  9/1 7/1 4/1 2/1  0/4",
        melB="9/2 12/1 9/1  9/1 7/1 4/2  4/1 7/1 12/2  14/3 r/1  16/1.5 14/.5 12/1 9/1  12/2 9/2  7/1 9/1 7/1 2/1  2/2 r/2",
        leadA="dizi", leadB="erhu", arp="zheng", perc="frame", fx=["chimes"]),
    "desert": dict(desc="Sa Mạc Xích Sa — nóng, huyền bí (La Hijaz)", bpm=92, tonic=57, mode="hijaz", target=-18.0,
        prog={"I": "I I bII I", "A": "I bII I iv I bII bvii I", "B": "iv iv I bII iv bvii bII I"},
        melA="7/1 8/.5 7/.5 4/1 5/1  5/1.5 4/.5 1/2  0/1 1/1 4/1 7/1  8/2 5/2  12/1 13/.5 12/.5 10/1 8/1  8/1 7/1 5/1 1/1  10/1.5 8/.5 5/2  4/1 1/1 0/2",
        melB="5/2 8/1 12/1  13/1.5 12/.5 8/2  7/1 8/1 7/1 4/1  5/3 r/1  0/1 1/1 5/1 8/1  10/2 13/2  13/1 12/1 8/1 5/1  4/2 0/2",
        leadA="erhu", leadB="dizi", arp="pipa", perc="hand", fx=["gong"]),
    "swamp": dict(desc="Đầm Lầy U Minh — chậm, mơ hồ (Rê thứ ngũ cung)", bpm=70, tonic=50, mode="min", target=-19.0, rt60=3.4,
        prog={"I": "i i bVII i", "A": "i bVII bVI v i bVII bVI i", "B": "iv i bVI bVII iv i v i"},
        melA="0/1.5 3/.5 5/2  5/1 3/1 -2/2  3/2 0/2  7/3 r/1  7/1 10/1 12/1.5 10/.5  10/1 7/1 5/2  3/1 5/1 3/1 0/1  0/4",
        melB="5/2 3/1 0/1  0/3 r/1  3/1 5/1 3/2  5/1 7/1 10/2  12/2 10/1 7/1  7/1.5 5/.5 3/2  2/1 3/1 2/1 -2/1  0/2 r/2",
        leadA="erhu", leadB="dizi", lead_oct=12, arp="zheng", arp_sparse=True, perc="wood", fx=["chimes"]),
    "volcano": dict(desc="Núi Viêm Long — nặng, dồn (La thứ)", bpm=124, tonic=57, mode="min", target=-16.5, rt60=2.2,
        prog={"I": "i i bVI bVII", "A": "i bVI bVII i i bVI iv V", "B": "iv bVI i V iv bVI V i"},
        melA="0/1 3/1 7/1 3/1  8/1.5 7/.5 3/2  5/1 7/1 10/2  12/3 r/1  12/1 10/.5 8/.5 7/1 3/1  8/1 7/1 8/1 12/1  5/1.5 3/.5 0/2  -1/2 2/2",
        melB="5/.5 8/.5 12/1 8/1 5/1  8/1 12/1 15/2  15/1 12/1 10/1 7/1  11/3 r/1  12/1 8/1 5/1 8/1  12/1.5 10/.5 8/2  7/1 11/1 14/2  12/4",
        leadA="erhu", leadB="erhu", arp="spic", perc="taiko", bassinst="brass", fx=["gong"], intense=1.0),
    "tundra": dict(desc="Băng Nguyên — thưa, trong (La trưởng ngũ cung)", bpm=72, tonic=57, mode="maj", target=-19.0, rt60=3.6,
        prog={"I": "I IV I V", "A": "I iii IV I vi IV V I", "B": "IV I vi V IV I V I"},
        melA="4/2 7/1 9/1  7/3 4/1  9/2 12/2  7/4  9/1 12/1 16/2  14/1.5 12/.5 9/2  7/1 9/1 7/1 2/1  4/4",
        melB="12/2 9/2  7/1 4/1 7/2  9/2 4/2  2/3 r/1  0/1 2/1 4/1 9/1  7/2 12/2  14/1.5 12/.5 7/2  4/2 0/2",
        leadA="zheng", leadB="dizi", arp="zheng", arp_sparse=True, perc="none", choir=True, fx=["chimes"]),
    "sky": dict(desc="Thiên Không — bay bổng (Sol trưởng ngũ cung)", bpm=96, tonic=55, mode="maj", target=-18.0,
        prog={"I": "I IV vi V", "A": "I V vi iii IV I IV V", "B": "vi IV I V vi IV V I"},
        melA="7/1 12/1 14/1 16/1  14/2 12/1 7/1  9/1.5 12/.5 16/2  16/1 14/1 7/2  12/1.5 9/.5 12/2  16/1 14/1 12/2  9/1 12/1 14/1 12/1  14/4",
        melB="16/2 19/1 16/1  12/2 9/2  7/1 9/1 12/1 14/1  14/3 r/1  16/1 14/.5 12/.5 9/2  12/1 9/1 4/2  2/1 4/1 7/2  0/2 r/2",
        leadA="dizi", leadB="erhu", arp="zheng", perc="frame", choir=True, fx=["chimes"]),
    "void": dict(desc="Vực Hư Vô — chênh vênh (Đô thang tối)", bpm=58, tonic=48, mode="dark", target=-20.0, rt60=4.2,
        prog={"I": "i bII i bII", "A": "i bII bv i iv bII i i", "B": "iv bv i bII iv bII bv i"},
        melA="7/2 6/1 3/1  1/4  6/2 10/1 13/1  12/3 r/1  0/1 3/1 0/1 -2/1  1/2 -4/2  3/1 1/1 0/2  0/4",
        melB="12/2 13/1 12/1  10/2 6/2  7/1 6/1 3/2  1/3 r/1  0/2 3/2  1/1 3/1 1/2  6/2 1/2  0/2 r/2",
        leadA="erhu", leadB="dizi", lead_oct=12, arp="zheng", arp_sparse=True, perc="none", fx=["gong"]),
    "heaven": dict(desc="Thiên Đạo — hùng tráng, chủ đề chính (Đô trưởng)", bpm=88, tonic=60, mode="maj", target=-17.0,
        prog={"I": "I V vi IV", "A": "I V vi IV I iii IV V", "B": "vi IV I V vi IV V I"},
        melA="0/1 4/1 7/1.5 9/.5  7/2 11/1 14/1  12/1.5 11/.5 9/2  5/3 r/1  4/1 7/1 12/1.5 14/.5  16/1 14/1 11/2  12/1 9/1 5/1 9/1  7/4",
        melB="9/2 12/1 16/1  17/1.5 16/.5 12/2  16/1 14/1 12/1 7/1  11/3 r/1  12/1 14/1 16/2  17/1 16/1 14/1 12/1  14/2 11/2  12/4",
        leadA="dizi", leadB="erhu", arp="zheng", perc="taiko_light", choir=True, fx=["gong", "chimes"]),
    "boss": dict(desc="Trận boss — dồn dập (Rê thứ)", bpm=140, tonic=50, mode="min", loop=True, target=-15.5, rt60=2.0,
        prog={"I": "i i bVI bVII", "A": "i i bVI bVII i i iv V", "B": "iv iv bVI V iv bVII V i"},
        melA="0/1.5 -2/.5 -5/1 -4/1  -5/2 -9/1 -7/1  -4/1.5 -5/.5 -7/1 -9/1  -10/2 -7/2  0/1 2/.5 3/.5 2/1 0/1  -2/1 -5/1 0/2  -4/1 -5/1 -7/1 -9/1  -10/1 -13/1 -10/2",
        melB="-7/.5 -4/.5 0/1 -4/1 -7/1  0/1 3/1 0/1 -4/1  3/1.5 0/.5 -4/2  -5/1 -1/1 2/2  5/1 3/1 0/1 3/1  5/1.5 2/.5 -2/2  -1/1 2/1 -1/1 -5/1  0/4",
        leadA="erhu", leadB="erhu", lead_oct=24, arp="spic", perc="taiko", bassinst="brass", fx=["gong"], intense=1.0,
        form="I A B A2 O"),
    "boss_final": dict(desc="Trận boss vùng 7–9 — dồn dập (Rê Hijaz)", bpm=156, tonic=50, mode="hijaz", loop=True, target=-15.0, rt60=2.2,
        prog={"I": "I I bII I", "A": "I bII I iv I bII bvii I", "B": "iv iv bII I iv bvii bII I"},
        melA="0/.5 1/.5 4/1 7/1 4/1  5/1.5 4/.5 1/2  0/1 -2/1 -5/1 -8/1  -7/2 -4/2  7/1 8/.5 7/.5 4/1 1/1  1/1 5/1 8/2  -2/1.5 -4/.5 -7/2  -5/1 -8/1 -12/2",
        melB="-7/.5 -4/.5 0/1 -4/1 -7/1  0/1 5/1 8/1 5/1  8/1.5 5/.5 1/2  0/1 4/1 7/2  12/1 8/1 5/1 8/1  10/1.5 8/.5 5/2  5/1 4/1 1/2  0/4",
        leadA="erhu", leadB="erhu", lead_oct=24, arp="spic", perc="taiko", bassinst="brass", choir=True, fx=["gong"], intense=1.0,
        form="I A B A2 O"),
}


def parse(s):
    out, pos = [], 0.0
    for tok in s.split():
        a, b = tok.split("/")
        out.append((pos, float(b), None if a == "r" else int(a)))
        pos += float(b)
    return out, pos


def chord_of(spec, roman):
    off, q = ROMAN[roman]
    pc = (spec["tonic"] + off) % 12
    r = 48 + (pc - 48) % 12  # 48…59
    third = 3 if q == "min" else 4
    return r, [r, r + third, r + 7]


def gliss_notes(spec, lo, hi):
    sc = PENT["maj" if spec["mode"] == "maj" else "min"] if spec["mode"] in ("maj", "min") else PENT[spec["mode"]]
    return [m for m in range(lo, hi) if (m - spec["tonic"]) % 12 in sc]


def render_song(sid):
    spec = SONGS[sid]
    I.RNG = np.random.default_rng(sum(map(ord, sid)))
    bpm = spec["bpm"]
    beat = 60.0 / bpm
    bar = beat * 4
    form = spec.get("form", "I A B C A2 O").split()
    melA, la = parse(spec["melA"])
    melB, lb = parse(spec["melB"])
    assert abs(la - 32) < 1e-6 and abs(lb - 32) < 1e-6, (sid, la, lb)
    plan = song_plan(spec)  # (đoạn, hợp âm, ô thứ mấy trong đoạn)
    loop = spec.get("loop", False)
    total = len(plan) * bar
    mix = I.Mix(total + (0.0 if loop else 4.5), loop=loop)
    lead_base = spec["tonic"] + spec.get("lead_oct", 12)
    intense = spec.get("intense", 0.0)
    arp = spec.get("arp")
    perc = spec.get("perc", "none")
    starts = {}
    for b, (sec, ch, k) in enumerate(plan):
        starts.setdefault(sec, b)
        t0 = b * bar
        r, tri = chord_of(spec, ch)
        quiet = sec in ("I", "O")
        last_bar = b == len(plan) - 1
        # ---- dàn dây / hợp xướng nền
        dur = bar * (2.0 if (last_bar and not loop) else 1.0)
        mix.add("pad", t0, I.strings(tri, dur, 0.65 if quiet else (0.8 if sec == "C" else 1.0), attack=0.9 if not intense else 0.3), send=0.5)
        if spec.get("choir") and sec in ("B", "A2", "O"):
            mix.add("choir", t0, I.choir([m + 12 for m in tri], dur, 0.9 if sec != "O" else 0.6), send=0.6)
        # ---- trầm
        if not (sec == "I" and not intense):
            if spec.get("bassinst") == "brass":
                mix.add("bass", t0, I.brass(r - 12, bar * 0.95, 0.9), send=0.3)
                mix.add("bass", t0, I.brass(r - 5, bar * 0.95, 0.55), p=0.2, send=0.3)
            elif sec == "C":
                mix.add("bass", t0, I.bass(r - 12, bar, 0.7), p=-0.1, send=0.15)
            else:
                mix.add("bass", t0, I.bass(r - 12, beat * 2, 0.9), p=-0.1, send=0.15)
                mix.add("bass", t0 + beat * 2, I.bass(r - 5, beat * 2, 0.7), p=-0.1, send=0.15)
        # ---- đàn gảy rải / dây nảy
        tones = [r - 12, tri[0], tri[1], tri[2], tri[0] + 12, tri[1] + 12]
        if arp in ("zheng", "pipa"):
            sparse = spec.get("arp_sparse") or quiet
            if sparse:
                pat = [0, None, 2, None, 4, None, 3, None] if k % 2 == 0 else [0, None, None, 3, None, 4, None, 5]
            elif sec == "B":
                pat = [0, 2, 3, 2, 4, 2, 3, 5]
            elif sec == "C":
                pat = [0, None, 2, 3, None, 2, 3, None]
            else:
                pat = [0, 2, 3, 4, 3, 2, 4, 5]
            for i, idx in enumerate(pat):
                if idx is None:
                    continue
                v = (0.9 if i % 2 == 0 else 0.65) * I.RNG.uniform(0.9, 1.1) * (0.8 if sec == "C" else 1.0)
                if arp == "zheng":
                    bend = 2 if (sparse and i == 4 and k % 2 == 1) else 0
                    sig = I.guzheng(tones[idx], beat / 2, v, bend)
                else:
                    sig = I.pipa(tones[idx], beat / 2, v, trem=(sec == "B" and i == 0))
                mix.add("arp", t0 + i * beat / 2, sig, p=0.35, send=0.35, vol=0.85)
            # vuốt dây cuối đoạn (trước đoạn mới)
            nxt = plan[b + 1][0] if b + 1 < len(plan) else None
            if nxt is not None and nxt != sec and arp == "zheng":
                run = gliss_notes(spec, spec["tonic"] + 3, spec["tonic"] + 30)
                for j, m in enumerate(run):
                    mix.add("arp", t0 + bar - beat * 0.9 + j * 0.045, I.guzheng(m, 0.4, 0.4 + 0.025 * j), p=0.4 - 0.05 * j, send=0.45, vol=0.8)
        elif arp == "spic":
            rr = r
            cell = [rr, rr, rr + 7, rr, rr, rr + 12, rr + 7, rr]
            n16 = 8 if quiet and not intense else 16
            for i in range(n16):
                step = 16 // n16
                mix.add("arp", t0 + i * step * beat / 4, I.spiccato(cell[i % 8], 1.0 if (i * step) % 4 == 0 else 0.6),
                        p=-0.35 + 0.7 * (i % 2), send=0.2)
        # ---- bộ gõ
        if perc == "frame":
            if sec in ("A", "A2"):
                for i, v in ((0, 0.8), (2, 0.55)):
                    mix.add("drum", t0 + i * beat, I.frame_drum(v), p=-0.25, send=0.25)
            elif sec == "B":
                mix.add("drum", t0, I.frame_drum(0.7), p=-0.25, send=0.25)
                for i in (1, 3):
                    mix.add("drum", t0 + i * beat + beat / 2, I.woodblock(0.6), p=0.5, send=0.3)
        elif perc == "hand" and not quiet:
            pat = [(0, True, 1.0), (1, False, 0.6), (1.5, True, 0.8), (2.5, False, 0.6), (3, False, 0.5), (3.5, False, 0.7)]
            if sec == "B":
                pat += [(0.5, False, 0.4), (2, True, 0.7)]
            for pos, low, v in pat:
                if sec == "C" and not low:
                    continue
                mix.add("drum", t0 + pos * beat, I.hand_drum(v, low), p=-0.2 if low else 0.3, send=0.25)
        elif perc == "wood":
            if sec in ("A", "B", "A2"):
                if k % 2 == 0:
                    mix.add("drum", t0, I.frame_drum(0.5), p=-0.2, send=0.35)
                for pos in (1.5, 3.5):
                    mix.add("drum", t0 + pos * beat, I.woodblock(0.4), p=0.45, send=0.4)
        elif perc == "taiko":
            if quiet:
                hits = [(0, 1.0, True), (2, 0.8, True)] if sec == "I" else [(0, 1.0, True)]
            else:
                hits = [(0, 1.0, True), (1.5, 0.7, False), (2, 0.9, True), (3, 0.6, False), (3.5, 0.8, True)]
                if sec in ("B", "A2"):
                    hits += [(3.75, 0.6, False), (1, 0.5, False)]
            for pos, v, big in hits:
                mix.add("drum", t0 + pos * beat, I.taiko(v, big), p=-0.15 if big else 0.25, send=0.3)
        elif perc == "taiko_light":
            if sec in ("A", "B", "A2"):
                mix.add("drum", t0, I.taiko(0.6, True), p=-0.15, send=0.35)
                mix.add("drum", t0 + 2 * beat, I.frame_drum(0.6), p=-0.25, send=0.25)
                if sec != "A":
                    mix.add("drum", t0 + 3.5 * beat, I.taiko(0.4, False), p=0.2, send=0.3)
        # ---- điểm nhấn đầu đoạn
        if k == 0 and sec in ("I", "A", "B", "A2"):
            if "chimes" in spec.get("fx", []):
                mix.add("fx", t0, I.chimes(0.9, seed=b), p=0.6, send=0.6)
            if "gong" in spec.get("fx", []) and sec in ("A", "A2", "I"):
                mix.add("fx", t0, I.gong(0.8 if intense else 0.55), p=0.0, send=0.6)

    def lead(sec, notes, inst, shift=0, vol=1.0, p=0.0):
        if sec not in starts:
            return
        start = starts[sec] * bar
        prev = None
        for pos, d, off in notes:
            if off is None:
                prev = None
                continue
            m = lead_base + off + shift
            at = start + pos * beat
            v = I.RNG.uniform(0.9, 1.05)
            if inst == "dizi":
                sig = I.dizi(m, d * beat * 0.97, v, prev if (prev is not None and d <= 1.0) else None)
            elif inst == "erhu":
                sig = I.erhu(m, d * beat * 0.98, v, prev, intense)
            elif inst == "zheng":
                sig = I.guzheng(m, d * beat, v * 1.1, 2 if (d >= 2 and I.RNG.random() < 0.4) else 0)
                if d >= 2:  # vê nhẹ nốt dài
                    for q in range(1, int(d * 4)):
                        mix.add(inst, at + q * beat / 4, I.guzheng(m, beat / 4, 0.28), p=p, send=0.4, vol=vol)
            else:
                sig = I.pipa(m, d * beat, v, trem=d >= 2)
            mix.add(inst, at, sig, p=p, send=0.4, vol=vol)
            prev = m

    la_, lb_ = spec["leadA"], spec["leadB"]
    lead("A", melA, la_, p=0.0)
    lead("B", melB, lb_, p=-0.12)
    pluck = "zheng" if arp != "pipa" else "pipa"
    lead("C", melA, pluck if arp in ("zheng", "pipa") else lb_, shift=-12 if arp in ("zheng", "pipa") else 0,
         vol=0.9, p=0.25)
    lead("A2", melA, la_, p=0.05)
    if intense:
        lead("A2", melA, "dizi", shift=12, vol=0.5, p=-0.25)
    else:
        lead("A2", melA, lb_ if lb_ != la_ else "dizi", shift=-12, vol=0.5, p=-0.3)
    out = mix.render(rt60=spec.get("rt60", 2.8), loop=loop, target_db=spec["target"])
    if not loop:
        n = out.shape[1]
        f = int(2.5 * SR)
        out[:, n - f:] *= np.linspace(1, 0, f) ** 2
    return out


# ------------------------------------------------------------------ tầng chiến đấu (S4, đợt 2)
## Bài có tầng chiến đấu: bài khám phá + hang. File <id>_combat.ogg dài đúng bằng bài chính, cùng nhịp / hợp âm
## (dựng từ cùng kế hoạch ô nhịp) — AudioManager phát 2 file đồng bộ (AudioStreamSynchronized) và chỉ đổi âm lượng tầng.
LAYER_IDS = ["forest", "core", "plains", "desert", "swamp", "volcano", "tundra", "sky", "void", "heaven"]
LAYER_DB = -21.0


def song_plan(spec):
    form = spec.get("form", "I A B C A2 O").split()
    plan = []
    for sec in form:
        key = {"A2": "A", "C": "A", "O": "I"}.get(sec, sec)
        prog = spec["prog"][key].split()
        if sec == "O":
            prog = prog[:3] + [prog[0]]
        for k, ch in enumerate(prog):
            plan.append((sec, ch, k))
    return plan


def render_layer(sid):
    """Tầng chiến đấu: taiko + trống khung dồn, dây nảy chạy, kèn trầm dâng mỗi 2 ô; nhẹ ở dạo đầu / kết."""
    spec = SONGS[sid]
    I.RNG = np.random.default_rng(sum(map(ord, sid)) + 77)
    beat = 60.0 / spec["bpm"]
    bar = beat * 4
    plan = song_plan(spec)
    loop = spec.get("loop", False)
    mix = I.Mix(len(plan) * bar + (0.0 if loop else 4.5), loop=loop)
    fast = spec["bpm"] < 96  # nhịp chậm → dây nảy 16 phần cho có lực, nhịp nhanh → 8 phần
    for b, (sec, ch, k) in enumerate(plan):
        t0 = b * bar
        r, tri = chord_of(spec, ch)
        quiet = sec in ("I", "O")
        g = 0.55 if quiet else (0.8 if sec == "C" else 1.0)
        # trống
        hits = [(0, 1.0, True), (2, 0.85, True)] if quiet else [(0, 1.0, True), (1.5, 0.6, False), (2, 0.9, True), (2.75, 0.5, False), (3.5, 0.75, False)]
        if sec in ("B", "A2") and k % 2 == 1:
            hits += [(3.25, 0.5, False), (3.75, 0.6, False)]
        for pos, v, big in hits:
            mix.add("drum", t0 + pos * beat, I.taiko(v * g, big), p=-0.15 if big else 0.25, send=0.3)
        if not quiet:
            for i in range(8):
                if i % 2 == 1:
                    mix.add("drum", t0 + i * beat / 2, I.frame_drum(0.35 * g), p=0.35, send=0.2)
        # dây nảy
        cell = [r, r + 7, r + 12, r + 7]
        n = 16 if fast else 8
        for i in range(n):
            st = 4.0 / n
            mix.add("spic", t0 + i * st * beat, I.spiccato(cell[i % 4] - 12 if i % 4 == 0 else cell[i % 4], (1.0 if i % (n // 4) == 0 else 0.6) * g),
                    p=-0.4 + 0.8 * (i % 2), send=0.2)
        # kèn trầm dâng mỗi 2 ô
        if not quiet and k % 2 == 0:
            mix.add("brass", t0, I.brass(r - 12, bar * 1.9, 0.8 * g), send=0.3)
    out = mix.render(rt60=spec.get("rt60", 2.8) * 0.8, loop=loop, target_db=LAYER_DB - (1.0 if sid in ("core", "void") else 0.0))
    if not loop:
        nn = out.shape[1]
        f = int(2.5 * SR)
        out[:, nn - f:] *= np.linspace(1, 0, f) ** 2
    return out


# ------------------------------------------------------------------ nhạc báo (S5)
def st_levelup():
    m = I.Mix(4.5)
    for j, n in enumerate([62, 64, 66, 69, 71, 74, 76, 78, 81, 83, 86]):
        m.add("arp", j * 0.05, I.guzheng(n, 0.5, 0.5 + 0.04 * j), p=-0.4 + 0.08 * j, send=0.5)
    m.add("pad", 0.45, I.strings([62, 66, 69], 2.0, 1.0, attack=0.25), send=0.5)
    for k, (n, d) in enumerate(((74, 0.25), (78, 0.25), (81, 1.4))):
        m.add("lead", 0.5 + k * 0.25, I.dizi(n, d, 1.0), send=0.4)
    m.add("fx", 0.5, I.chimes(1.0, seed=3), p=0.5, send=0.6)
    return m.render(rt60=2.4, target_db=-16.0)


def st_quest():
    m = I.Mix(4.0)
    for k, (n, at, d) in enumerate(((69, 0.0, 0.3), (74, 0.3, 0.3), (76, 0.6, 0.3), (81, 0.9, 1.3))):
        m.add("lead", at, I.dizi(n, d, 1.0), send=0.4)
    m.add("pad", 0.0, I.strings([57, 62, 66], 2.2, 0.9, attack=0.2), send=0.5)
    m.add("drum", 0.9, I.frame_drum(0.8), p=-0.2, send=0.3)
    m.add("arp", 0.9, I.guzheng(62, 1.0, 0.9), p=0.3, send=0.4)
    return m.render(rt60=2.4, target_db=-17.0)


def st_region():
    m = I.Mix(6.0)
    m.add("pad", 0.0, I.strings([55, 60, 64], 3.5, 1.0, attack=1.0), send=0.6)
    m.add("choir", 0.3, I.choir([67, 72, 76], 3.0, 0.8, attack=1.0), send=0.6)
    for k, (n, at, d) in enumerate(((60, 0.8, 0.6), (64, 1.4, 0.6), (67, 2.0, 0.9), (69, 2.9, 0.3), (67, 3.2, 1.6))):
        m.add("lead", at, I.erhu(n + 12, d, 1.0), send=0.45)
    m.add("fx", 0.0, I.gong(0.5), send=0.6)
    return m.render(rt60=3.0, target_db=-18.0)


def st_boss():
    m = I.Mix(5.0)
    for at, v in ((0.0, 1.0), (0.32, 0.8), (0.64, 1.0), (1.4, 1.0)):
        m.add("drum", at, I.taiko(v, True), send=0.35)
    m.add("fx", 1.4, I.gong(1.0), send=0.6)
    m.add("bass", 1.4, I.brass(38, 2.4, 1.0), send=0.4)
    m.add("bass", 1.4, I.brass(39, 2.4, 0.6), p=0.3, send=0.4)
    m.add("pad", 1.4, I.strings([50, 53, 56], 2.4, 1.0, attack=0.15), send=0.5)
    return m.render(rt60=2.2, target_db=-15.0)


def st_victory():
    m = I.Mix(7.0)
    m.add("drum", 0.0, I.taiko(1.0, True), send=0.35)
    m.add("fx", 0.0, I.gong(0.8), send=0.6)
    m.add("pad", 0.0, I.strings([48, 55, 60, 64], 4.5, 1.0, attack=0.3), send=0.5)
    m.add("choir", 0.4, I.choir([67, 72, 76], 4.0, 1.0, attack=0.6), send=0.6)
    for k, (n, at, d) in enumerate(((72, 0.3, 0.3), (76, 0.6, 0.3), (79, 0.9, 0.6), (84, 1.5, 2.6))):
        m.add("lead", at, I.dizi(n, d, 1.0), send=0.45)
    for j, n in enumerate(gliss_notes({"tonic": 60, "mode": "maj"}, 60, 90)):
        m.add("arp", 1.5 + j * 0.04, I.guzheng(n, 0.4, 0.5), p=-0.4 + 0.07 * j, send=0.5)
    return m.render(rt60=2.8, target_db=-16.0)


STINGERS = {"st_levelup": st_levelup, "st_quest": st_quest, "st_region": st_region, "st_boss": st_boss, "st_victory": st_victory}


# ------------------------------------------------------------------ âm môi trường (S3) — vòng lặp 40 giây liền mạch
AMB_LEN = 40.0


def _lfo(n, rng, slow=(1, 2, 3, 5)):
    """Dao động chậm có số chu kỳ nguyên trong vòng lặp → nối liền mạch."""
    t = np.arange(n) / n
    v = sum(rng.uniform(0.3, 1.0) * np.sin(2 * np.pi * c * t + rng.uniform(0, 6.28)) for c in slow)
    return (v - v.min()) / (v.max() - v.min() + 1e-9)


def _noise_band(n, lo, hi, rng):
    """Nhiễu lọc dải bằng FFT trên cả vòng lặp — tự động liền mạch."""
    X = np.fft.rfft(rng.standard_normal(n))
    f = np.fft.rfftfreq(n, 1.0 / SR)
    X *= np.clip((f - lo * 0.6) / (lo * 0.4 + 1e-9), 0, 1) / np.sqrt(1 + (f / hi) ** 4)
    y = np.fft.irfft(X, n)
    return y / (np.abs(y).max() + 1e-9)


def _wind(n, rng, lo, hi, depth=0.7, gust=(1, 2, 3, 5)):
    st = np.stack([_noise_band(n, lo, hi, rng), _noise_band(n, lo, hi, rng)])
    g = 1.0 - depth + depth * _lfo(n, rng, gust)
    return st * g


def _place(m, name, sig_fn, count, rng, p_range=(-0.8, 0.8), send=0.4):
    for i in range(count):
        m.add(name, rng.uniform(0, AMB_LEN), sig_fn(i), p=rng.uniform(*p_range), send=send)


def _bird(rng):
    n = int(rng.uniform(0.25, 0.6) * SR)
    t = np.arange(n) / SR
    out = np.zeros(n)
    f0 = rng.uniform(2600, 4200)
    k = 0
    while k * 0.09 < t[-1] - 0.06:
        st = int(k * 0.09 * SR)
        L = int(0.06 * SR)
        tt = np.arange(L) / SR
        f = f0 * (1 + rng.uniform(-0.2, 0.25) * tt / 0.06)
        ph = 2 * np.pi * np.cumsum(f) / SR
        out[st:st + L] += np.sin(ph + 0.8 * np.sin(2 * np.pi * 40 * tt)) * np.sin(np.pi * tt / 0.06) ** 2
        k += 1
    return out * rng.uniform(0.3, 0.7)


def _cricket(rng):
    n = int(1.2 * SR)
    t = np.arange(n) / SR
    f = rng.uniform(4200, 5200)
    gate = (np.sin(2 * np.pi * 28 * t) > 0.3) * (np.sin(2 * np.pi * 3 * t) > -0.2)
    return np.sin(2 * np.pi * f * t) * gate * np.sin(np.pi * t / t[-1]) * 0.25


def _drip(rng):
    n = int(0.35 * SR)
    t = np.arange(n) / SR
    f = rng.uniform(900, 1700) * (1 + 0.6 * t / 0.05).clip(max=1.6)
    return np.sin(2 * np.pi * np.cumsum(f) / SR) * np.exp(-t / 0.05) * 0.5


def _frog(rng):
    n = int(0.5 * SR)
    t = np.arange(n) / SR
    f0 = rng.uniform(90, 160)
    body = sum(np.sin(2 * np.pi * f0 * k * t) / k for k in range(1, 8))
    gate = (np.sin(2 * np.pi * rng.uniform(18, 26) * t) > 0) * np.sin(np.pi * t / t[-1])
    return body * gate * 0.25


def _bubble(rng):
    n = int(0.25 * SR)
    t = np.arange(n) / SR
    f = rng.uniform(60, 140) * (1 + 2.5 * t)
    return np.sin(2 * np.pi * np.cumsum(f) / SR) * np.exp(-t / 0.07) * 0.8


def _tinkle(rng):
    n = int(1.5 * SR)
    t = np.arange(n) / SR
    f = rng.uniform(3000, 6000)
    return (np.sin(2 * np.pi * f * t) + 0.4 * np.sin(2 * np.pi * f * 2.7 * t)) * np.exp(-t / 0.35) * 0.18


def ambient(aid):
    rng = np.random.default_rng(sum(map(ord, aid)))
    I.RNG = np.random.default_rng(sum(map(ord, aid)) + 1)
    n = int(AMB_LEN * SR)
    m = I.Mix(AMB_LEN, loop=True)
    target = -27.0
    if aid in ("amb_forest", "amb_village"):
        m.add("wind", 0, _wind(n, rng, 300, 2500, 0.6) * 0.5, send=0.1)
        _place(m, "bird", lambda i: _bird(rng), 26 if aid == "amb_forest" else 18, rng, send=0.5)
        if aid == "amb_forest":
            _place(m, "bug", lambda i: _cricket(rng), 10, rng, send=0.3)
    elif aid == "amb_plains":
        m.add("wind", 0, _wind(n, rng, 150, 3500, 0.85) * 0.8, send=0.1)
        _place(m, "bird", lambda i: _bird(rng) * 0.6, 8, rng, send=0.5)
        target = -25.0
    elif aid == "amb_desert":
        m.add("wind", 0, _wind(n, rng, 120, 1500, 0.8), send=0.1)
        m.add("sand", 0, _wind(n, rng, 3000, 9000, 0.9, (2, 3, 7)) * 0.25, send=0.05)
        target = -26.0
    elif aid == "amb_swamp":
        m.add("wind", 0, _wind(n, rng, 100, 800, 0.4) * 0.4, send=0.2)
        _place(m, "frog", lambda i: _frog(rng), 22, rng, send=0.5)
        _place(m, "drip", lambda i: _drip(rng), 30, rng, send=0.6)
        _place(m, "bug", lambda i: _cricket(rng) * 0.6, 8, rng, send=0.3)
    elif aid == "amb_volcano":
        m.add("rumble", 0, _wind(n, rng, 30, 220, 0.5), send=0.2)
        _place(m, "pop", lambda i: _bubble(rng), 60, rng, send=0.4)
        m.add("hiss", 0, _wind(n, rng, 2500, 7000, 0.9, (3, 5, 8)) * 0.12, send=0.1)
        target = -25.0
    elif aid == "amb_tundra":
        m.add("wind", 0, _wind(n, rng, 400, 5000, 0.9, (1, 2, 4)) * 0.9, send=0.15)
        _place(m, "ice", lambda i: _tinkle(rng), 10, rng, send=0.6)
        target = -25.0
    elif aid == "amb_sky":
        m.add("wind", 0, _wind(n, rng, 600, 6000, 0.7, (1, 2, 3)) * 0.7, send=0.2)
        for i in range(4):
            m.add("bell", rng.uniform(0, AMB_LEN), I.chimes(0.6, seed=40 + i), p=rng.uniform(-0.7, 0.7), send=0.7)
    elif aid == "amb_void":
        t = np.arange(n) / SR
        drone = np.sin(2 * np.pi * 41.0 * t) + 0.7 * np.sin(2 * np.pi * 41.75 * t) + 0.3 * np.sin(2 * np.pi * 61.5 * t)
        m.add("drone", 0, np.stack([drone, np.roll(drone, 4000)]) * 0.5, send=0.3)
        m.add("whoosh", 0, _wind(n, rng, 200, 1800, 0.95, (1, 3, 4)) * 0.5, send=0.5)
        target = -26.0
    elif aid == "amb_heaven":
        m.add("wind", 0, _wind(n, rng, 500, 4000, 0.5) * 0.35, send=0.3)
        m.add("choir", 0, I.choir([60, 67, 72], AMB_LEN - 1.6, 0.6, attack=4.0)[:, :n], send=0.6)
        for i in range(5):
            m.add("bell", rng.uniform(0, AMB_LEN), I.chimes(0.5, seed=60 + i), p=rng.uniform(-0.7, 0.7), send=0.7)
    elif aid == "amb_cave":
        m.add("room", 0, _wind(n, rng, 60, 400, 0.4) * 0.5, send=0.4)
        _place(m, "drip", lambda i: _drip(rng), 24, rng, send=0.8)
        target = -28.0
    return m.render(rt60=3.0 if aid != "amb_cave" else 4.5, loop=True, target_db=target)


AMBIENTS = ["amb_forest", "amb_village", "amb_plains", "amb_desert", "amb_swamp", "amb_volcano", "amb_tundra", "amb_sky",
            "amb_void", "amb_heaven", "amb_cave"]


def job(item):
    kind, sid = item
    import time
    t0 = time.time()
    if kind == "music":
        st, sub = render_song(sid), "music"
    elif kind == "layer":
        st, sub = render_layer(sid), "music"
        sid = sid + "_combat"
    elif kind == "stinger":
        st, sub = STINGERS[sid](), "stinger"
    else:
        st, sub = ambient(sid), "ambient"
    path = os.path.join(OUT, sub, sid + ".ogg")
    I.write_ogg(path, st)
    rms = 20 * np.log10(np.sqrt((st.mean(0) ** 2).mean()) + 1e-12)
    return "%-8s %-12s %6.1f s  RMS %5.1f dB  đỉnh %.2f  (sinh %.0f s)" % (sub, sid, st.shape[1] / SR, rms, np.abs(st).max(), time.time() - t0)


def main():
    items = ([("music", k) for k in SONGS] + [("layer", k) for k in LAYER_IDS] + [("stinger", k) for k in STINGERS]
             + [("ambient", k) for k in AMBIENTS])
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    if "--list" in sys.argv:
        for kind, sid in items:
            print(kind, sid + ("_combat" if kind == "layer" else ""))
        return
    if args:
        items = [it for it in items if it[1] in args or (it[0] == "layer" and it[1] + "_combat" in args)]
    procs = max(1, min(len(items), (os.cpu_count() or 2) - 1, 6))
    with Pool(procs) as pool:
        for line in pool.imap_unordered(job, items):
            print(line, flush=True)
    print("ok: %d file" % len(items))


if __name__ == "__main__":
    main()
