"""Hiệu ứng âm thanh (C1-40). Mỗi hàm trả về tín hiệu 0,05–0,8 giây. Thêm âm mới: viết hàm + thêm vào SFX."""
import synth as S
from synth import osc, envelope, decay_env, lowpass, highpass, gain, mix, concat, note_freq


def slash():
    whoosh = highpass(osc("noise", 9000, 0.16, seed=1), 1800)
    whoosh = envelope(whoosh, 0.01, 0.06, 0.4, 0.08)
    blade = decay_env(osc("square", 1400, 0.12, duty=0.25, freq_end=500), 0.04)
    return mix(gain(whoosh, 0.7), gain(blade, 0.25))


def shot():
    twang = decay_env(osc("triangle", 300, 0.18, freq_end=900), 0.05)
    air = envelope(highpass(osc("noise", 7000, 0.14, seed=2), 2500), 0.002, 0.03, 0.3, 0.09)
    return mix(gain(twang, 0.6), gain(air, 0.35))


def hit():
    thump = decay_env(osc("square", 160, 0.12, duty=0.5, freq_end=60), 0.035)
    click = decay_env(osc("noise", 6000, 0.05, seed=3), 0.01)
    return mix(gain(lowpass(thump, 1800), 0.8), gain(click, 0.5))


def crit():
    ping = decay_env(osc("square", note_freq(88), 0.22, duty=0.125), 0.07)
    return mix(hit(), gain(ping, 0.35), gain(S.silence(0.25), 0))


def enemy_die():
    notes = [76, 71, 67, 62, 55]
    parts = [decay_env(osc("square", note_freq(m), 0.07, duty=0.5), 0.05) for m in notes]
    body = concat(*parts)
    dust = envelope(lowpass(osc("noise", 3000, len(body) / S.RATE, seed=4), 1500), 0.01, 0.1, 0.3, 0.15)
    return mix(gain(body, 0.45), gain(dust, 0.3))


def player_hurt():
    tone = envelope(osc("saw", 320, 0.25, freq_end=150, vibrato=0.06, vib_rate=30), 0.002, 0.05, 0.5, 0.1)
    return mix(gain(lowpass(tone, 2200), 0.6), gain(decay_env(osc("noise", 4000, 0.08, seed=5), 0.02), 0.35))


def dodge():
    sweep = osc("noise", 8000, 0.22, seed=6)
    sweep = lowpass(sweep, lambda i: 600 + 5000 * (i / (0.22 * S.RATE)))
    return envelope(gain(sweep, 0.8), 0.02, 0.08, 0.5, 0.1)


def perfect():
    notes = [84, 88, 91, 96]
    out = S.silence(0.5)
    for k, m in enumerate(notes):
        bell = decay_env(mix(osc("sine", note_freq(m), 0.35), gain(osc("sine", note_freq(m) * 2.01, 0.35), 0.3)), 0.12)
        S.add_at(out, bell, int(k * 0.06 * S.RATE), 0.35)
    return out


def pickup_gold():
    a = decay_env(osc("square", note_freq(83), 0.06, duty=0.25), 0.03)
    b = decay_env(osc("square", note_freq(88), 0.1, duty=0.25), 0.05)
    return gain(concat(a, b), 0.45)


def pickup_item():
    notes = [72, 76, 79, 84]
    return gain(concat(*[decay_env(osc("triangle", note_freq(m), 0.075), 0.06) for m in notes]), 0.6)


def levelup():
    # Ngũ cung đi lên rồi hợp âm sáng (C D E G A)
    notes = [60, 62, 64, 67, 69, 72]
    out = S.silence(0.8)
    for k, m in enumerate(notes):
        tone = decay_env(osc("square", note_freq(m + 12), 0.14, duty=0.25), 0.08)
        S.add_at(out, tone, int(k * 0.065 * S.RATE), 0.25)
    chord = S.silence(0.4)
    for m in (72, 76, 79):
        chord = mix(chord, gain(decay_env(osc("triangle", note_freq(m + 12), 0.4), 0.2), 0.3))
    S.add_at(out, chord, int(0.4 * S.RATE))
    return out


def skill():
    rise = envelope(osc("square", 200, 0.3, duty=0.3, freq_end=900), 0.01, 0.1, 0.5, 0.12)
    shimmer = envelope(highpass(osc("noise", 11000, 0.3, seed=7), 4000), 0.05, 0.1, 0.4, 0.12)
    return mix(gain(lowpass(rise, 3000), 0.4), gain(shimmer, 0.25))


def ui_click():
    return gain(decay_env(osc("square", 1500, 0.05, duty=0.5), 0.012), 0.35)


def boss_roar():
    growl = osc("saw", 95, 0.8, freq_end=60, vibrato=0.12, vib_rate=18)
    growl = envelope(lowpass(growl, 900), 0.06, 0.2, 0.7, 0.3)
    breath = envelope(lowpass(osc("noise", 2000, 0.8, seed=8), 700), 0.1, 0.2, 0.6, 0.3)
    return mix(gain(growl, 0.8), gain(breath, 0.5))


def explode():
    boom = decay_env(osc("sine", 120, 0.6, freq_end=40), 0.15)
    rumble = decay_env(lowpass(osc("noise", 4000, 0.6, seed=9), lambda i: 3000 * (1 - i / (0.6 * S.RATE)) + 200), 0.18)
    return mix(gain(boom, 0.7), gain(rumble, 0.8))


def heal():
    notes = [72, 76, 79, 84, 88]
    out = S.silence(0.5)
    for k, m in enumerate(notes):
        tone = decay_env(osc("sine", note_freq(m), 0.25, vibrato=0.01, vib_rate=8), 0.1)
        S.add_at(out, tone, int(k * 0.06 * S.RATE), 0.3)
    return out


SFX = {
    "slash": slash, "shot": shot, "hit": hit, "crit": crit, "enemy_die": enemy_die,
    "player_hurt": player_hurt, "dodge": dodge, "perfect": perfect, "pickup_gold": pickup_gold,
    "pickup_item": pickup_item, "levelup": levelup, "skill": skill, "ui_click": ui_click,
    "boss_roar": boss_roar, "explode": explode, "heal": heal,
}
