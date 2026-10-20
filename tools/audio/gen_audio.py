"""Sinh toàn bộ âm thanh của game (C1-40, C1-41). Chỉ dùng thư viện chuẩn Python.

    python tools/audio/gen_audio.py              # sinh tất cả
    python tools/audio/gen_audio.py slash boss   # chỉ sinh các id này

Ghi ra godot/assets/audio/sfx/<id>.wav và godot/assets/audio/music/<id>.wav (WAV 16-bit mono 22050 Hz),
in danh sách file kèm thời lượng.
"""
import os
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)

import synth  # noqa: E402
from sfx import SFX  # noqa: E402
from music import MUSIC, SONGS  # noqa: E402

ROOT = os.path.dirname(os.path.dirname(HERE))
OUT = os.path.join(ROOT, "godot", "assets", "audio")


def main():
    only = set(sys.argv[1:])
    rows = []
    for group, table in (("sfx", SFX), ("music", MUSIC)):
        os.makedirs(os.path.join(OUT, group), exist_ok=True)
        for sid, fn in table.items():
            if only and sid not in only:
                continue
            t0 = time.time()
            sig = fn()
            if group == "sfx":
                sig = synth.fade(synth.normalize(synth.remove_dc(sig), 0.85))
            else:
                sig = synth.normalize(synth.remove_dc(sig, loop=True), 0.6)
            path = os.path.join(OUT, group, sid + ".wav")
            synth.write_wav(path, sig)
            rows.append((group, sid, len(sig) / synth.RATE, time.time() - t0))
    for group, sid, dur, took in rows:
        note = (" — " + SONGS[sid]["desc"]) if group == "music" else ""
        print("%-6s %-12s %6.2f s   (sinh %.1f s)%s" % (group, sid, dur, took, note))
    print("ok: %d file" % len(rows))


if __name__ == "__main__":
    main()
