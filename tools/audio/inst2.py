"""MU-1 (docs/46): thư viện nhạc cụ mô phỏng + bàn trộn cho nhạc nền thế hệ 2 (thay sóng chip của music.py).

- stereo 44,1 kHz; mỗi nhạc cụ có vị trí trái / phải và tiếng vang phòng (tích chập FFT với đáp ứng xung tổng hợp);
- nhạc cụ: đàn tranh, tỳ bà (dây gảy: họa âm tắt dần, nhấn nốt, vê), sáo trúc (hơi thở, rung trễ, luyến),
  đàn nhị (vĩ kéo qua thân cộng hưởng, vuốt nốt), dàn dây nền, dây nảy, hợp xướng (formant "a"), contrabass,
  kèn đồng trầm, taiko, trống khung, trống tay, mõ, chuông gió, chiêng;
- nhân hoá: lệch nhịp ±8 ms, lực ±10%.

Dùng bởi songs2.py (bài nhạc, nhạc báo, âm môi trường). Cần numpy.
"""
import os
import sys
import wave

import numpy as np

SR = 44100
RNG = np.random.default_rng(7)


def mtof(m):
    return 440.0 * 2.0 ** ((m - 69) / 12.0)


# ------------------------------------------------------------------ tiện ích tín hiệu
def adsr(n, a, d, s, r, curve=2.0):
    """Bao hình (giây) cho tín hiệu dài n mẫu; r tính trong n (nốt đã gồm đuôi nhả)."""
    t = np.arange(n) / SR
    env = np.ones(n) * s
    A, D, R = max(1, int(a * SR)), max(1, int(d * SR)), max(1, int(r * SR))
    env[:A] = (np.arange(A) / A) ** (1.0 / curve) if A < n else env[:A]
    end_d = min(n, A + D)
    if end_d > A:
        env[A:end_d] = 1.0 + (s - 1.0) * (np.arange(end_d - A) / D)
    if R < n:
        rel = (1.0 - np.arange(R) / R) ** curve
        env[n - R:] *= rel
    return env


def band_noise(n, lo, hi, seed=None):
    rng = np.random.default_rng(seed) if seed is not None else RNG
    x = rng.standard_normal(n)
    X = np.fft.rfft(x)
    f = np.fft.rfftfreq(n, 1.0 / SR)
    mask = np.clip((f - lo * 0.7) / (lo * 0.3 + 1e-9), 0, 1) * np.clip((hi * 1.3 - f) / (hi * 0.3 + 1e-9), 0, 1)
    y = np.fft.irfft(X * mask, n)
    return y / (np.abs(y).max() + 1e-9)


def lowpass(x, fc):
    X = np.fft.rfft(x)
    f = np.fft.rfftfreq(len(x), 1.0 / SR)
    return np.fft.irfft(X / np.sqrt(1.0 + (f / fc) ** 4), len(x))


def phase_from(freq):
    return 2.0 * np.pi * np.cumsum(freq) / SR


def vibrato(n, f0, depth, rate, delay=0.25, ramp=0.4):
    t = np.arange(n) / SR
    amt = np.clip((t - delay) / ramp, 0, 1) * depth
    wob = np.sin(2 * np.pi * rate * t + RNG.uniform(0, 6.28)) + 0.15 * np.sin(2 * np.pi * rate * 0.53 * t)
    return f0 * (1.0 + amt * wob)


def additive(freq, amps, body=None):
    """Tổng các họa âm (chống răng cưa: bỏ họa âm vượt 16 kHz). body(fk) → hệ số cộng hưởng thân đàn."""
    ph = phase_from(freq)
    fmax = float(freq.max())
    out = np.zeros(len(freq))
    for k, a in enumerate(amps, start=1):
        fk = fmax * k
        if fk > 16000:
            break
        g = a * (body(fk) if body else 1.0)
        out += g * np.sin(k * ph)
    return out


def pan(x, p):
    """p: -1 trái … +1 phải, công suất không đổi."""
    th = (p + 1.0) * np.pi / 4.0
    return np.stack([x * np.cos(th), x * np.sin(th)])


# ------------------------------------------------------------------ nhạc cụ
def guzheng(m, dur, vel=1.0, bend=0.0):
    """Đàn tranh: các họa âm tắt dần (họa âm cao tắt nhanh), lệch họa âm nhẹ, tiếng móng gảy; bend = nhấn nốt (nửa cung)."""
    f0 = mtof(m)
    ring = min(4.0, 2.2 + 120.0 / f0)
    n = int((dur + ring) * SR)
    t = np.arange(n) / SR
    freq = np.full(n, f0)
    if bend:
        # nhấn: gảy rồi nhấn dây lên bend nửa cung sau 0,15 giây, nhả về
        b = np.clip((t - 0.15) / 0.12, 0, 1) * np.clip((dur * 0.85 - t) / 0.2, 0, 1)
        freq = f0 * 2.0 ** (bend * b / 12.0)
    ph = phase_from(freq)
    out = np.zeros(n)
    B = 0.00012
    for k in range(1, 14):
        fk = f0 * k * np.sqrt(1 + B * k * k)
        if fk > 15000:
            break
        a = abs(np.sin(np.pi * k * 0.19)) / k ** 0.9
        tau = ring / (1.0 + 0.55 * (k - 1)) * (0.6 if f0 > 700 else 1.0)
        out += a * np.exp(-t / tau) * np.sin(k * np.sqrt(1 + B * k * k) * ph + k * 0.7)
    pick = band_noise(int(0.012 * SR), 1500, 7000) * np.linspace(1, 0, int(0.012 * SR)) * 0.25
    out[:len(pick)] += pick
    att = np.clip(t / 0.002, 0, 1)
    return out * att * vel * 0.55


def dizi(m, dur, vel=1.0, prev=None):
    """Sáo trúc: họa âm thưa, hơi thở lọc dải, rung trễ, luyến từ nốt trước (prev)."""
    f0 = mtof(m)
    n = int((dur + 0.25) * SR)
    t = np.arange(n) / SR
    freq = vibrato(n, f0, 0.007, 5.3, delay=0.28, ramp=0.5)
    scoop = 2.0 ** (-0.35 * np.exp(-t / 0.035) / 12.0)
    if prev is not None:
        scoop = 2.0 ** ((prev - m) * np.exp(-t / 0.045) / 12.0)
    freq = freq * scoop
    tone = additive(freq, [1.0, 0.42, 0.16, 0.07, 0.03])
    breath = band_noise(n, f0 * 0.8, f0 * 4.5) * 0.10
    chiff = band_noise(n, 2000, 8000) * np.exp(-t / 0.02) * 0.18
    env = adsr(n, 0.07 if prev is None else 0.02, 0.15, 0.82, 0.22)
    swell = 1.0 + 0.12 * np.clip((t - 0.3) / max(0.3, dur), 0, 1)
    return (tone * swell + breath + chiff) * env * vel * 0.42


def erhu(m, dur, vel=1.0, prev=None, intense=0.0):
    """Đàn nhị: vĩ kéo (răng cưa hạn dải) qua thân cộng hưởng, rung sâu, vuốt nốt từ nốt trước."""
    f0 = mtof(m)
    n = int((dur + 0.18) * SR)
    t = np.arange(n) / SR
    freq = vibrato(n, f0, 0.011 + 0.006 * intense, 5.9, delay=0.18, ramp=0.35)
    if prev is not None:
        freq = freq * 2.0 ** ((prev - m) * np.exp(-t / 0.06) / 12.0)

    def body(fk):
        return 0.35 + 0.9 * np.exp(-((fk - 900) / 500) ** 2) + 0.7 * np.exp(-((fk - 2600) / 900) ** 2)

    tone = additive(freq, [1.0 / k for k in range(1, 18)], body)
    bow = band_noise(n, 1500, 6000) * 0.05 * (0.6 + 0.4 * np.sin(2 * np.pi * 3.1 * t))
    env = adsr(n, 0.06 - 0.03 * intense, 0.2, 0.85, 0.16)
    return (tone + bow) * env * vel * 0.20


def strings(chord, dur, vel=1.0, attack=0.9):
    """Dàn dây nền: mỗi âm 3 bè lệch ±7 cent, họa âm mềm, lên / xuống chậm. Trả về stereo."""
    n = int((dur + 1.4) * SR)
    out = np.zeros((2, n))
    for i, m in enumerate(chord):
        for j, c in enumerate((-7, 0, 7)):
            f0 = mtof(m) * 2.0 ** (c / 1200.0)
            freq = vibrato(n, f0, 0.003, 4.6 + 0.4 * j, delay=0.0, ramp=0.5)
            tone = additive(freq, [np.exp(-k / 5.0) / k for k in range(1, 16)])
            p = (-0.6 + 1.2 * ((i * 3 + j) / max(1, len(chord) * 3 - 1)))
            out += pan(tone, p)
    env = adsr(n, attack, 0.3, 0.9, 1.3, curve=1.5)
    return out * env * vel * 0.045


def spiccato(m, vel=1.0):
    """Dây nảy (nhạc boss): nốt ngắn, 3 bè."""
    n = int(0.22 * SR)
    out = np.zeros(n)
    for c in (-8, 0, 8):
        f0 = mtof(m) * 2.0 ** (c / 1200.0)
        out += additive(np.full(n, f0), [np.exp(-k / 4.0) / k for k in range(1, 14)])
    return out * adsr(n, 0.008, 0.06, 0.35, 0.1) * vel * 0.12


def bass(m, dur, vel=1.0):
    """Contrabass gảy mềm."""
    f0 = mtof(m)
    n = int((dur + 0.6) * SR)
    t = np.arange(n) / SR
    out = sum((1.0 / k ** 1.4) * np.exp(-t / (1.6 / k)) * np.sin(2 * np.pi * f0 * k * t) for k in range(1, 7))
    return out * np.clip(t / 0.006, 0, 1) * adsr(n, 0.005, 0.1, 1.0, 0.25) * vel * 0.5


def brass(m, dur, vel=1.0):
    """Kèn đồng trầm (boss): răng cưa qua lọc mở dần."""
    f0 = mtof(m)
    n = int((dur + 0.3) * SR)
    t = np.arange(n) / SR
    bright = np.clip(t / 0.25, 0, 1)
    amps = [1.0 / k for k in range(1, 20)]
    out = np.zeros(n)
    ph = phase_from(vibrato(n, f0, 0.002, 4.8, 0.3, 0.5))
    for k, a in enumerate(amps, start=1):
        out += a * np.exp(-k * (0.45 - 0.3 * bright)) * np.sin(k * ph)
    return out * adsr(n, 0.12, 0.2, 0.85, 0.25) * vel * 0.13


def taiko(vel=1.0, big=True):
    n = int(1.4 * SR)
    t = np.arange(n) / SR
    f = (55 if big else 90) + (45 if big else 70) * np.exp(-t / 0.045)
    body = np.sin(phase_from(f)) * np.exp(-t / (0.42 if big else 0.22))
    skin = band_noise(n, 80, 900) * np.exp(-t / 0.05) * 0.5
    slap = band_noise(n, 1500, 5000) * np.exp(-t / 0.008) * 0.25
    return (body + skin + slap) * vel * (0.85 if big else 0.5)


def frame_drum(vel=1.0):
    n = int(0.6 * SR)
    t = np.arange(n) / SR
    body = np.sin(phase_from(120 + 40 * np.exp(-t / 0.03))) * np.exp(-t / 0.16)
    skin = band_noise(n, 200, 2500) * np.exp(-t / 0.03) * 0.4
    return (body + skin) * vel * 0.35


def woodblock(vel=1.0):
    n = int(0.15 * SR)
    t = np.arange(n) / SR
    return (np.sin(2 * np.pi * 1050 * t) + 0.4 * np.sin(2 * np.pi * 2650 * t)) * np.exp(-t / 0.025) * vel * 0.18


def chimes(vel=1.0, seed=1):
    rng = np.random.default_rng(seed)
    n = int(4.0 * SR)
    t = np.arange(n) / SR
    out = np.zeros(n)
    for i in range(5):
        st = int(rng.uniform(0, 0.5) * SR)
        f0 = rng.choice([2093, 2349, 2637, 3136, 3520])
        tt = t[: n - st]
        tone = sum(a * np.sin(2 * np.pi * f0 * r * tt) * np.exp(-tt / (1.6 / r)) for r, a in ((1, 1), (2.76, 0.4), (5.4, 0.15)))
        out[st:] += tone * rng.uniform(0.5, 1.0)
    return out * vel * 0.05


def gong(vel=1.0):
    n = int(5.0 * SR)
    t = np.arange(n) / SR
    out = np.zeros(n)
    for r, a in ((1, 1.0), (1.48, 0.6), (2.03, 0.5), (2.71, 0.35), (3.42, 0.3), (4.16, 0.2)):
        out += a * np.sin(2 * np.pi * 92 * r * t * (1 + 0.004 * np.exp(-t / 0.5)))
    swell = (1 - np.exp(-t / 0.08)) * np.exp(-t / 1.8)
    return (out * swell + band_noise(n, 300, 3000) * np.exp(-t / 0.4) * 0.15) * vel * 0.22


# ------------------------------------------------------------------ dựng bài
class Mix:
    """Bàn trộn: mỗi kênh (tên) là stereo; send = lượng gửi vào tiếng vang."""

    def __init__(self, seconds, loop=False):
        self.n = int(seconds * SR)
        self.loop = loop
        self.bus = {}
        self.send = {}

    def add(self, name, at, sig, p=0.0, send=0.3, vol=1.0):
        st = int(max(0.0, at + RNG.uniform(-0.008, 0.008)) * SR)
        if sig.ndim == 1:
            sig = pan(sig, p)
        if name not in self.bus:
            self.bus[name] = np.zeros((2, self.n))
            self.send[name] = send
        st %= self.n
        end = min(self.n, st + sig.shape[1])
        if end > st:
            self.bus[name][:, st:end] += sig[:, : end - st] * vol
        # vòng lặp: phần đuôi nốt tràn qua cuối bài quấn về đầu bài (chỗ nối liền mạch)
        rest = sig.shape[1] - (end - st)
        if self.loop and rest > 0:
            k = min(rest, self.n)
            self.bus[name][:, :k] += sig[:, end - st : end - st + k] * vol

    def render(self, rt60=2.6, wet=0.32, loop=None, target_db=-18.0):
        """Trộn khô + vang, chỉnh độ lớn trung bình về target_db (RMS) — giữ dải động (nhạc cũ ~−19 dB), chỉ hạn chế
        mềm phần đỉnh vượt 0,85."""
        loop = self.loop if loop is None else loop
        dry = sum(self.bus.values())
        sends = sum(b * self.send[k] for k, b in self.bus.items())
        out = dry + reverb(sends, rt60, loop) * wet / 0.32 * 0.6
        rms = np.sqrt((out.mean(0) ** 2).mean()) + 1e-12
        out *= 10 ** (target_db / 20.0) / rms
        a = np.abs(out)
        over = a > 0.85
        out[over] = np.sign(out[over]) * (0.85 + 0.13 * np.tanh((a[over] - 0.85) / 0.13))
        return out


def reverb(x, rt60, loop):
    """Tiếng vang phòng: tích chập FFT với đáp ứng xung tổng hợp (nhiễu tắt dần, tối dần theo thời gian, 2 kênh khác nhau)."""
    L = int(rt60 * SR)
    t = np.arange(L) / SR
    out = np.zeros_like(x)
    n = x.shape[1]
    for ch in range(2):
        rng = np.random.default_rng(100 + ch)
        ir = rng.standard_normal(L) * np.exp(-6.9 * t / rt60)
        # tối dần: trộn bản lọc thấp theo thời gian
        dark = lowpass(ir, 2500)
        k = np.clip(t / (rt60 * 0.5), 0, 1)
        ir = ir * (1 - k) * 0.6 + dark * k
        ir[: int(0.012 * SR)] = 0.0
        for d, g in ((0.017, 0.5), (0.029, 0.35), (0.041 + 0.006 * ch, 0.3)):
            ir[int(d * SR)] += g * 8
        ir /= np.sqrt((ir ** 2).sum())
        size = 1 << int(np.ceil(np.log2(n + L)))
        y = np.fft.irfft(np.fft.rfft(x[ch], size) * np.fft.rfft(ir, size), size)
        if loop:
            out[ch] = y[:n]
            out[ch, : L] += y[n : n + L][: min(L, n)]
        else:
            out[ch] = y[:n]
    return out


def parse(s):
    """'76/1.5 74/.5 r/1' → [(nhịp bắt đầu, độ dài nhịp, midi | None)]."""
    out, pos = [], 0.0
    for tok in s.split():
        a, b = tok.split("/")
        d = float(b)
        out.append((pos, d, None if a == "r" else int(a)))
        pos += d
    return out


def write_wav(path, st):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    pcm = (np.clip(st.T, -1, 1) * 32767).astype("<i2")
    with wave.open(path, "wb") as w:
        w.setnchannels(2)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(pcm.tobytes())



def pipa(m, dur, vel=1.0, trem=False):
    """Tỳ bà: dây gảy sáng, ngân ngắn hơn đàn tranh; trem = vê (gảy lặp nhanh suốt nốt)."""
    f0 = mtof(m)
    ring = min(2.0, 0.9 + 60.0 / f0)

    def one(v, length):
        n = int((length + ring) * SR)
        t = np.arange(n) / SR
        out = np.zeros(n)
        B = 0.0004
        for k in range(1, 12):
            fk = f0 * k * np.sqrt(1 + B * k * k)
            if fk > 15000:
                break
            a = abs(np.sin(np.pi * k * 0.12)) / k ** 0.8
            out += a * np.exp(-t / (ring / (1.0 + 0.8 * (k - 1)))) * np.sin(2 * np.pi * fk * t + k)
        pk = int(0.006 * SR)
        out[:pk] += band_noise(pk, 2000, 9000) * np.linspace(1, 0, pk) * 0.3
        return out * np.clip(t / 0.0015, 0, 1) * v

    if not trem:
        return one(vel, dur) * 0.5
    step = 1.0 / 14.0
    n = int((dur + ring) * SR)
    out = np.zeros(n)
    k = 0
    while k * step < dur:
        s = one(vel * (0.75 if k else 1.0) * RNG.uniform(0.85, 1.0), step * 1.5)
        st = int(k * step * SR)
        e = min(n, st + len(s))
        out[st:e] += s[: e - st] * 0.6
        k += 1
    return out * 0.5


def choir(chord, dur, vel=1.0, attack=1.2):
    """Hợp xướng tổng hợp (nguyên âm "a"): răng cưa qua 3 formant, 2 giọng / âm, rung chậm. Trả về stereo."""
    n = int((dur + 1.6) * SR)
    out = np.zeros((2, n))

    def body(fk):
        return (np.exp(-((fk - 760) / 160) ** 2) + 0.7 * np.exp(-((fk - 1150) / 200) ** 2)
                + 0.3 * np.exp(-((fk - 2600) / 400) ** 2) + 0.04)

    for i, m in enumerate(chord):
        for j, c in enumerate((-9, 9)):
            f0 = mtof(m) * 2.0 ** (c / 1200.0)
            freq = vibrato(n, f0, 0.006, 4.8 + 0.5 * j, delay=0.3, ramp=0.8)
            tone = additive(freq, [1.0 / k for k in range(1, 30)], body)
            out += pan(tone, -0.5 + (i + j * 0.5) / max(1, len(chord)))
    return out * adsr(n, attack, 0.4, 0.9, 1.5, curve=1.5) * vel * 0.05


def hand_drum(vel=1.0, low=True):
    """Trống tay (darbuka): "dum" trầm / "tek" vành."""
    n = int(0.5 * SR)
    t = np.arange(n) / SR
    if low:
        sig = np.sin(phase_from(105 + 60 * np.exp(-t / 0.02))) * np.exp(-t / 0.14) + band_noise(n, 100, 800) * np.exp(-t / 0.02) * 0.3
    else:
        sig = band_noise(n, 1800, 7000) * np.exp(-t / 0.018) + 0.4 * np.sin(2 * np.pi * 620 * t) * np.exp(-t / 0.03)
    return sig * vel * 0.35


def write_ogg(path, st):
    """Ghi OGG Vorbis stereo (cần soundfile: pip install soundfile). Ghi từng khối 1 giây — ghi cả mảng một lần
    làm libsndfile 1.2.2 treo với file dài."""
    import soundfile as sf
    os.makedirs(os.path.dirname(path), exist_ok=True)
    x = np.clip(st.T, -1, 1).astype(np.float32)
    with sf.SoundFile(path, "w", SR, 2, format="OGG", subtype="VORBIS") as f:
        for i in range(0, len(x), SR):
            f.write(x[i:i + SR])
