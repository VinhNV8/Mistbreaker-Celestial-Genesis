"""FX-1 (docs/36 §9.6): ghép ảnh chụp trong game (tests/fx1_smoke.gd --frames=34) thành bản "đã làm" để so với
bản thiết kế docs/design/skills-fx.

    Godot_console.exe --path godot --script res://tests/fx1_smoke.gd -- --class=<lớp> --frames=34 --mode= --out=<dir>/<lớp>
    python tools/art/skill_fx_ingame.py <dir> [--gif]

Xuất docs/design/skills-fx-ingame/<lớp>/NN-<id>-so-sanh.jpg (+ NN-<id>.gif 34 khung, 1/15 giây khi có --gif)
(hàng trên: 6 khung thiết kế; hàng dưới: 6 khung chụp trong game).
"""
import os
import sys

from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import skill_fx_design as design  # noqa: E402

ROOT = os.path.dirname(os.path.dirname(HERE))
OUT = os.path.join(ROOT, "docs", "design", "skills-fx-ingame")
CW, CH = 576, 336
PICK = [1, 3, 5, 7, 10, 14]
## Kỹ năng kéo dài hơn 1,3 giây: chọn khung trải đều 2,2 giây (Thiên Tai 3 pha, Quân Đoàn, Kỳ Lân, Vạn Kiếm…).
PICK_LONG = {"thienhoa": [3, 12, 20, 26, 34, 40], "vankiem": [2, 6, 10, 16, 22, 30], "quandoan": [2, 6, 10, 16, 22, 30],
             "kylan": [2, 6, 10, 16, 22, 30], "tinhvu": [2, 6, 10, 16, 22, 30], "nhatkiem": [2, 5, 8, 10, 13, 18]}
NF = 34


def build(cap_dir, want_gif=False):
    n = 0
    for cls, skills in design.SKILLS.items():
        src = os.path.join(cap_dir, cls)
        if not os.path.isdir(src):
            continue
        folder = os.path.join(OUT, cls)
        os.makedirs(folder, exist_ok=True)
        for idx, (sid, name, _fn) in enumerate(skills, 1):
            paths = []
            while os.path.exists(os.path.join(src, "%s-f%02d.png" % (sid, len(paths)))):
                paths.append(os.path.join(src, "%s-f%02d.png" % (sid, len(paths))))
            if len(paths) < 20 or max(PICK_LONG.get(sid, PICK)) >= len(paths):
                continue
            frames = [Image.open(p).convert("RGB").resize((CW, CH), Image.LANCZOS) for p in paths]
            stem = os.path.join(folder, "%02d-%s" % (idx, sid))
            # GIF (nền rừng nặng ~0,6 MB/kỹ năng) chỉ xuất khi gọi --gif; mặc định chỉ ảnh so sánh JPEG.
            if want_gif:
                gif = [f.resize((384, 224), Image.LANCZOS).convert("P", palette=Image.Palette.ADAPTIVE, colors=96) for f in frames]
                gif[0].save(stem + ".gif", save_all=True, append_images=gif[1:], duration=[67] * (len(frames) - 1) + [400], loop=0)
            # so sánh: hàng trên thiết kế (dải 6 khung của bản duyệt), hàng dưới trong game
            w3, h3 = CW // 2, CH // 2
            cmp_img = Image.new("RGB", (w3 * 6, (h3 + 18) * 2), (12, 14, 24))
            d = ImageDraw.Draw(cmp_img)
            dpath = os.path.join(design.OUT, cls, "%02d-%s.png" % (idx, sid))
            if os.path.exists(dpath):
                strip = Image.open(dpath).convert("RGB")
                fw, fh = strip.width // 3, strip.height // 2
                for k in range(6):
                    tile = strip.crop(((k % 3) * fw, (k // 3) * fh, (k % 3 + 1) * fw, (k // 3 + 1) * fh))
                    cmp_img.paste(tile.resize((w3, h3), Image.LANCZOS), (k * w3, 18))
            for k, fi in enumerate(PICK_LONG.get(sid, PICK)):
                cmp_img.paste(frames[fi].resize((w3, h3), Image.LANCZOS), (k * w3, h3 + 36))
            d.text((6, 3), "THIET KE  %s / %02d / %s" % (design.CLASS_LABEL[cls], idx, design._ascii(name)), fill=(255, 210, 120))
            d.text((6, h3 + 21), "TRONG GAME (chup tu tests/fx1_smoke.gd)", fill=(140, 200, 255))
            cmp_img.save(stem + "-so-sanh.jpg", quality=86)
            n += 1
    return n


if __name__ == "__main__":
    print("ok: %d skill" % build(sys.argv[1], "--gif" in sys.argv))
