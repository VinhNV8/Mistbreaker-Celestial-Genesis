"""Sinh hiệu ứng âm thanh của game (C1-40). Chỉ dùng thư viện chuẩn Python.

MU-1 (docs/46): nhạc nền KHÔNG còn sinh ở đây — dùng tools/audio/songs2.py (OGG stereo, nhạc cụ mô phỏng, nhạc báo,
âm môi trường). music.py (chiptune thế hệ 1) giữ lại để tham khảo, không ghi file nào nữa.

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

ROOT = os.path.dirname(os.path.dirname(HERE))
OUT = os.path.join(ROOT, "godot", "assets", "audio")


def main():
    only = set(sys.argv[1:])
    rows = []
    for group, table in (("sfx", SFX),):
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
        print("%-6s %-12s %6.2f s   (sinh %.1f s)" % (group, sid, dur, took))
    print("ok: %d file" % len(rows))


if __name__ == "__main__":
    main()
