"""Nhạc nền vòng lặp (C1-41), kiểu chiptune, giai điệu ngũ cung.

Mỗi bản = dữ liệu (nhịp, số ô nhịp, giọng, vòng hợp âm, nhạc cụ). Giai điệu sinh bằng random có seed cố định,
theo cấu trúc lặp motif (A A B A…) để nghe có chủ đề. Mọi nốt/tiếng vang tràn qua cuối bài được quấn về đầu bài
(add_at wrap=True) nên vòng lặp liền mạch.
"""
import math
import random
import synth as S
from synth import osc, envelope, decay_env, lowpass, highpass, gain, note_freq

MAJOR_PENT = [0, 2, 4, 7, 9]
MINOR_PENT = [0, 3, 5, 7, 10]

# Hợp âm: (độ lệch nửa cung so với chủ âm, "maj" | "min")
SONGS = {
    "village": {
        "desc": "Làng Thanh Thạch — êm, sáng",
        "bpm": 84, "bars": 12, "root": 62, "scale": MAJOR_PENT, "seed": 11,
        "chords": [(0, "maj"), (9, "min"), (5, "maj"), (7, "maj")],
        "lead": {"wave": "triangle", "octave": 12, "vol": 0.32, "echo": 0.3},
        "arp": {"wave": "square", "duty": 0.125, "vol": 0.07, "div": 2},
        "bass": {"wave": "triangle", "vol": 0.3, "pattern": [1, 0, 0, 0, 1, 0, 0, 0]},
        "pad": {"vol": 0.06},
        "drums": {"kick": "x.......x.......", "snare": "", "hat": "....x.......x...", "vol": 0.25},
        "form": [0, 1, 0, 2, 0, 1, 3, 0, 1, 2, 0, 3],
        "rest": 0.25,
    },
    "forest": {
        "desc": "Rừng Sương — bí ẩn, nhịp vừa",
        "bpm": 100, "bars": 16, "root": 57, "scale": MINOR_PENT, "seed": 23,
        "chords": [(0, "min"), (-4, "maj"), (-2, "maj"), (0, "min"), (5, "min"), (3, "maj"), (-2, "maj"), (-5, "maj")],
        "lead": {"wave": "square", "duty": 0.25, "octave": 12, "vol": 0.22, "echo": 0.35},
        "arp": {"wave": "square", "duty": 0.125, "vol": 0.06, "div": 4},
        "bass": {"wave": "triangle", "vol": 0.34, "pattern": [1, 0, 0, 1, 0, 0, 1, 0]},
        "pad": {"vol": 0.0},
        "drums": {"kick": "x.......x.....x.", "snare": "....x.......x...", "hat": "x.x.x.x.x.x.x.x.", "vol": 0.3},
        "form": [0, 1, 0, 2, 0, 1, 3, 2, 0, 1, 0, 2, 3, 1, 0, 2],
        "rest": 0.2,
    },
    "core": {
        "desc": "Lõi Sương — u ám, thưa",
        "bpm": 70, "bars": 10, "root": 52, "scale": MINOR_PENT, "seed": 37,
        "chords": [(0, "min"), (1, "maj"), (0, "min"), (-2, "maj"), (-4, "maj")],
        "lead": {"wave": "sine", "octave": 12, "vol": 0.26, "echo": 0.5, "detune": 0.006},
        "arp": {"wave": "triangle", "duty": 0.5, "vol": 0.05, "div": 2},
        "bass": {"wave": "saw", "vol": 0.2, "pattern": [1, 0, 0, 0, 0, 0, 0, 0], "lowpass": 400},
        "pad": {"vol": 0.1},
        "drums": {"kick": "x...............", "snare": "", "hat": "", "vol": 0.25},
        "form": [0, 1, 2, 0, 3, 1, 2, 0, 3, 1],
        "rest": 0.4,
    },
    "boss": {
        "desc": "Trận boss — dồn dập",
        "bpm": 150, "bars": 20, "root": 50, "scale": MINOR_PENT, "seed": 41,
        "chords": [(0, "min"), (0, "min"), (-2, "maj"), (-4, "maj"), (0, "min"), (3, "maj"), (-2, "maj"), (-5, "maj")],
        "lead": {"wave": "square", "duty": 0.5, "octave": 12, "vol": 0.2, "echo": 0.15},
        "arp": {"wave": "square", "duty": 0.25, "vol": 0.06, "div": 4},
        "bass": {"wave": "square", "duty": 0.5, "vol": 0.22, "pattern": [1, 1, 1, 1, 1, 1, 1, 1], "lowpass": 900},
        "pad": {"vol": 0.0},
        "drums": {"kick": "x...x...x...x.x.", "snare": "....x.......x..x", "hat": "xxxxxxxxxxxxxxxx", "vol": 0.34},
        "form": [0, 0, 1, 2, 0, 0, 1, 3, 2, 2, 3, 1, 0, 0, 1, 2, 3, 3, 1, 0],
        "rest": 0.1,
    },
}

# Nhịp điệu 1 ô nhịp, đơn vị 1/8 nốt (tổng 8)
RHYTHMS = [[2, 2, 2, 2], [3, 1, 2, 2], [2, 1, 1, 2, 2], [4, 2, 2], [1, 1, 2, 1, 1, 2], [2, 2, 4], [3, 3, 2], [1, 1, 1, 1, 2, 2]]


def chord_tones(root, quality):
    third = 3 if quality == "min" else 4
    return [root, root + third, root + 7]


def scale_notes(song, lo, hi):
    out = []
    for m in range(lo, hi + 1):
        if (m - song["root"]) % 12 in song["scale"]:
            out.append(m)
    return out


def make_motifs(song):
    """4 motif 1 ô nhịp: [(vị trí 1/8, độ dài 1/8, midi hoặc None)]."""
    rnd = random.Random(song["seed"])
    base = song["root"] + song["lead"]["octave"]
    notes = scale_notes(song, base - 5, base + 14)
    motifs = []
    idx = len(notes) // 2
    for k in range(4):
        rhythm = RHYTHMS[rnd.randrange(len(RHYTHMS))]
        pos = 0
        m = []
        for j, dur in enumerate(rhythm):
            if j > 0 and rnd.random() < song["rest"]:
                m.append((pos, dur, None))
            else:
                idx = max(0, min(len(notes) - 1, idx + rnd.choice([-2, -1, -1, 0, 1, 1, 2])))
                m.append((pos, dur, idx))
            pos += dur
        motifs.append(m)
    return motifs, notes


def snap_to_chord(notes, idx, chord):
    """Nốt đầu ô nhịp kéo về âm của hợp âm gần nhất trong thang ngũ cung."""
    pcs = {c % 12 for c in chord}
    best = idx
    for d in range(0, 4):
        for cand in (idx - d, idx + d):
            if 0 <= cand < len(notes) and notes[cand] % 12 in pcs:
                return cand
    return best


def kick():
    return decay_env(osc("sine", 150, 0.16, freq_end=42), 0.06)


def snare():
    n = lowpass(osc("noise", 6000, 0.14, seed=91), 4500)
    return S.mix(decay_env(n, 0.05), gain(decay_env(osc("triangle", 190, 0.08), 0.03), 0.5))


def hat():
    return decay_env(highpass(osc("noise", 12000, 0.04, seed=92), 6000), 0.012)


def render(song_id):
    song = SONGS[song_id]
    beat = 60.0 / song["bpm"]
    eighth = beat / 2.0
    bar = beat * 4.0
    total = int(song["bars"] * bar * S.RATE)
    out = [0.0] * total
    motifs, notes = make_motifs(song)
    chords = song["chords"]
    L = song["lead"]
    drums = song["drums"]
    k_s, s_s, h_s = kick(), snare(), hat()

    for b in range(song["bars"]):
        start = int(b * bar * S.RATE)
        c_off, c_q = chords[b % len(chords)]
        croot = song["root"] + c_off
        tones = chord_tones(croot, c_q)

        # Đệm (pad): hợp âm ngân dài
        if song["pad"]["vol"] > 0:
            for t in tones:
                pad = envelope(osc("triangle", note_freq(t), bar, vibrato=0.003), 0.4, 0.3, 0.8, 0.4)
                S.add_at(out, pad, start, song["pad"]["vol"], True)

        # Bass
        B = song["bass"]
        for i, hitp in enumerate(B["pattern"]):
            if not hitp:
                continue
            m = croot - 12 + (7 if (i % 4 == 2 and len(B["pattern"]) == 8 and sum(B["pattern"]) > 4) else 0)
            tone = osc(B["wave"], note_freq(m), eighth * 0.95, duty=B.get("duty", 0.5))
            tone = envelope(tone, 0.004, 0.08, 0.6, 0.04)
            if B.get("lowpass"):
                tone = lowpass(tone, B["lowpass"])
            S.add_at(out, tone, start + int(i * eighth * S.RATE), B["vol"], True)

        # Rải hợp âm (arp)
        A = song["arp"]
        step = beat / A["div"]
        seq = tones + [tones[1]]
        for i in range(int(4 * A["div"])):
            m = seq[i % len(seq)] + 12
            tone = decay_env(osc(A["wave"], note_freq(m), step * 0.9, duty=A.get("duty", 0.5)), step * 0.5)
            S.add_at(out, tone, start + int(i * step * S.RATE), A["vol"], True)

        # Giai điệu chính theo motif
        motif = motifs[song["form"][b % len(song["form"])]]
        first = True
        for pos, dur, idx in motif:
            if idx is None:
                continue
            if first:
                idx = snap_to_chord(notes, idx, tones)
                first = False
            m = notes[idx]
            length = dur * eighth
            f = note_freq(m)
            tone = osc(L["wave"], f, length * 0.95, duty=L.get("duty", 0.5), vibrato=0.004, vib_rate=5.5)
            if L.get("detune"):
                tone = S.mix(gain(tone, 0.6), gain(osc(L["wave"], f * (1 + L["detune"]), length * 0.95), 0.6))
            tone = envelope(tone, 0.01, 0.12, 0.65, min(0.12, length * 0.4))
            S.add_at(out, tone, start + int(pos * eighth * S.RATE), L["vol"], True)

        # Trống: 16 ô, mỗi ô 1/16 nốt
        sixteenth = beat / 4.0
        for name, sample in (("kick", k_s), ("snare", s_s), ("hat", h_s)):
            pat = drums[name]
            for i, ch in enumerate(pat):
                if ch == "x":
                    vol = drums["vol"] * (0.5 if name == "hat" else 1.0)
                    S.add_at(out, sample, start + int(i * sixteenth * S.RATE), vol, True)

    if L.get("echo"):
        out = S.echo(out, beat * 0.75, 0.4, L["echo"] * 0.5, wrap=True)
    out = S.soft_clip(S.normalize(out, 0.9))
    return S.normalize(out, 0.6)


MUSIC = {k: (lambda k=k: render(k)) for k in SONGS}
