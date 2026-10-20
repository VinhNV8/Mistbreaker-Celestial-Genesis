"""Bộ tổng hợp âm thanh tối giản (chỉ thư viện chuẩn) cho hiệu ứng và nhạc kiểu chiptune.

Mọi tín hiệu là list[float] trong [-1, 1], tần số lấy mẫu RATE. Ghi ra WAV 16-bit mono.
"""
import math
import random
import struct
import wave

RATE = 22050
TAU = math.pi * 2.0


def silence(seconds):
    return [0.0] * int(seconds * RATE)


def note_freq(midi):
    return 440.0 * 2.0 ** ((midi - 69) / 12.0)


# ------------------------------------------------------------------ dao động
def osc(kind, freq, seconds, duty=0.5, freq_end=None, vibrato=0.0, vib_rate=6.0, seed=0):
    """Một nốt: kind = square | triangle | saw | sine | noise. freq_end: trượt tần số tuyến tính (cao độ)."""
    n = int(seconds * RATE)
    out = [0.0] * n
    phase = 0.0
    rnd = random.Random(seed)
    noise_val = 0.0
    noise_step = 0.0
    for i in range(n):
        t = i / RATE
        f = freq if freq_end is None else freq + (freq_end - freq) * (i / max(1, n - 1))
        if vibrato:
            f *= 1.0 + vibrato * math.sin(TAU * vib_rate * t)
        phase += f / RATE
        ph = phase - math.floor(phase)
        if kind == "square":
            v = 1.0 if ph < duty else -1.0
        elif kind == "triangle":
            v = 4.0 * ph - 1.0 if ph < 0.5 else 3.0 - 4.0 * ph
        elif kind == "saw":
            v = 2.0 * ph - 1.0
        elif kind == "sine":
            v = math.sin(TAU * ph)
        else:  # noise kiểu chip: giữ giá trị trong 1 chu kỳ "tần số"
            noise_step += f / RATE
            if noise_step >= 1.0:
                noise_step -= math.floor(noise_step)
                noise_val = rnd.uniform(-1.0, 1.0)
            v = noise_val
        out[i] = v
    return out


def envelope(sig, attack=0.005, decay=0.05, sustain=0.6, release=0.05, curve=1.0):
    n = len(sig)
    a, d, r = int(attack * RATE), int(decay * RATE), int(release * RATE)
    out = [0.0] * n
    for i in range(n):
        if i < a:
            g = i / max(1, a)
        elif i < a + d:
            g = 1.0 - (1.0 - sustain) * ((i - a) / max(1, d))
        else:
            g = sustain
        if i > n - r:
            g *= max(0.0, (n - i) / max(1, r))
        out[i] = sig[i] * (g ** curve)
    return out


def decay_env(sig, tau):
    """Tắt dần theo hàm mũ (tau giây)."""
    return [v * math.exp(-(i / RATE) / tau) for i, v in enumerate(sig)]


def lowpass(sig, cutoff):
    """Lọc thông thấp 1 cực. cutoff có thể là số hoặc hàm(i) → Hz."""
    out = [0.0] * len(sig)
    y = 0.0
    for i, x in enumerate(sig):
        c = cutoff(i) if callable(cutoff) else cutoff
        k = 1.0 - math.exp(-TAU * c / RATE)
        y += k * (x - y)
        out[i] = y
    return out


def highpass(sig, cutoff):
    lp = lowpass(sig, cutoff)
    return [x - y for x, y in zip(sig, lp)]


def remove_dc(sig, loop=False):
    """Khử lệch DC (lọc thông cao 20 Hz). loop=True: lọc trên tín hiệu nhân đôi rồi lấy nửa sau,
    để trạng thái bộ lọc liền mạch ở chỗ nối vòng lặp."""
    if loop:
        twice = highpass(sig + sig, 20.0)
        return twice[len(sig):]
    return highpass(sig, 20.0)


def gain(sig, g):
    return [v * g for v in sig]


def mix(*sigs):
    n = max(len(s) for s in sigs)
    out = [0.0] * n
    for s in sigs:
        for i, v in enumerate(s):
            out[i] += v
    return out


def concat(*sigs):
    out = []
    for s in sigs:
        out.extend(s)
    return out


def add_at(dst, src, start, g=1.0, wrap=False):
    """Cộng src vào dst từ mẫu start. wrap=True: phần tràn quấn về đầu (để nhạc lặp liền mạch)."""
    n = len(dst)
    for i, v in enumerate(src):
        j = start + i
        if j >= n:
            if not wrap:
                break
            j %= n
        dst[j] += v * g


def echo(sig, delay, feedback=0.35, wet=0.3, wrap=False):
    d = int(delay * RATE)
    out = list(sig)
    buf = list(sig)
    for k in range(1, 4):
        add_at(out, buf, d * k, wet * feedback ** (k - 1), wrap)
    return out


def normalize(sig, peak=0.8):
    m = max((abs(v) for v in sig), default=0.0)
    if m <= 1e-9:
        return sig
    return [v * peak / m for v in sig]


def soft_clip(sig):
    return [math.tanh(v) for v in sig]


def fade(sig, fade_in=0.002, fade_out=0.01):
    n = len(sig)
    a, b = int(fade_in * RATE), int(fade_out * RATE)
    out = list(sig)
    for i in range(min(a, n)):
        out[i] *= i / max(1, a)
    for i in range(min(b, n)):
        out[n - 1 - i] *= i / max(1, b)
    return out


def write_wav(path, sig):
    with wave.open(path, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        frames = bytearray()
        for v in sig:
            frames += struct.pack("<h", int(max(-1.0, min(1.0, v)) * 32767))
        w.writeframes(bytes(frames))
