"""Sinh toàn bộ hình của game (AR-06).

    python tools/art/build_all.py            # sinh tất cả
    python tools/art/build_all.py wolf boss  # chỉ sinh các id này (vẫn ghi lại manifest đầy đủ)

Kết quả:
- godot/assets/sprites/<id>.png   sheet hoạt ảnh (hàng = hoạt ảnh, cột = frame)
- godot/assets/icons/<id>.png     icon 32×32
- godot/assets/env/<id>.png       môi trường
- godot/assets/art_manifest.json  thông tin cắt frame cho sprite_lib.gd
- tools/art/_preview/*.png        bảng xem trước phóng to ×4 (để duyệt, không đưa vào game)
"""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)

from PIL import Image, ImageDraw  # noqa: E402
import pixel  # noqa: E402
from builders import BUILDERS  # noqa: E402
from catalog import SPRITES, FPS, LOOP  # noqa: E402
import icons  # noqa: E402
import env  # noqa: E402

ROOT = os.path.dirname(os.path.dirname(HERE))
ASSETS = os.path.join(ROOT, "godot", "assets")
PREVIEW = os.path.join(HERE, "_preview")


def _save(img, *parts):
    path = os.path.join(ASSETS, *parts)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    img.save(path)
    return "res://assets/" + "/".join(parts)


def build_sprites(only):
    out = {}
    previews = []
    for sid, d in SPRITES.items():
        rows = BUILDERS[d["builder"]](d["spec"])
        img, meta = pixel.sheet(rows)
        fw, fh = rows[0][1][0].w, rows[0][1][0].h
        if not only or sid in only:
            path = _save(img, "sprites", sid + ".png")
        else:
            path = "res://assets/sprites/%s.png" % sid
        anims = {}
        for name, m in meta.items():
            anims[name] = {"row": m["row"], "frames": m["frames"],
                           "fps": d.get("fps", {}).get(name, FPS[name]), "loop": LOOP[name]}
        # Gốc vẽ = điểm chân (giữa bóng); game đặt điểm này vào vị trí thực thể.
        out[sid] = {"path": path, "w": fw, "h": fh, "origin": [fw // 2, round(fh * 29.5 / 32)], "anims": anims, "name": d["name"],
                    "size_mul": d.get("size_mul", 1.0)}
        previews.append((d["name"], img))
    return out, previews


def contact(title, items, scale=4, cols=1, bg=(40, 44, 52, 255)):
    """Ghép nhiều ảnh thành 1 bảng xem trước, phóng to ×scale."""
    pad = 8
    cells = [(name, im.resize((im.width * scale, im.height * scale), Image.NEAREST)) for name, im in items]
    rows = [cells[i:i + cols] for i in range(0, len(cells), cols)]
    w = max(sum(c[1].width + pad for c in r) for r in rows) + pad
    h = sum(max(c[1].height for c in r) + 20 + pad for r in rows) + pad + 18
    sheet = Image.new("RGBA", (w, h), bg)
    dr = ImageDraw.Draw(sheet)
    dr.text((pad, 4), title, fill=(255, 255, 255, 255))
    y = 22
    for r in rows:
        x = pad
        for name, im in r:
            dr.text((x, y), name.encode("ascii", "replace").decode(), fill=(220, 220, 220, 255))
            sheet.alpha_composite(im, (x, y + 14))
            x += im.width + pad
        y += max(c[1].height for c in r) + 20 + pad
    os.makedirs(PREVIEW, exist_ok=True)
    sheet.save(os.path.join(PREVIEW, title + ".png"))


def main():
    only = set(sys.argv[1:])
    manifest = {"version": 1, "scale": 2, "sprites": {}, "icons": {}, "env": {}}
    manifest["sprites"], previews = build_sprites(only)
    contact("sprites", previews, scale=4)
    icon_imgs = icons.build_all()
    for iid, img in icon_imgs.items():
        manifest["icons"][iid] = _save(img, "icons", iid + ".png")
    contact("icons", list(icon_imgs.items()), scale=3, cols=10)
    env_imgs = env.build_all()
    for eid, (img, origin) in env_imgs.items():
        manifest["env"][eid] = {"path": _save(img, "env", eid + ".png"), "w": img.width, "h": img.height, "origin": origin}
    contact("env", [(k, v[0]) for k, v in env_imgs.items()], scale=3, cols=8)
    with open(os.path.join(ASSETS, "art_manifest.json"), "w", encoding="utf-8") as f:
        json.dump(manifest, f, ensure_ascii=False, indent=1)
    print("ok: %d sprite, %d icon, %d env" % (len(manifest["sprites"]), len(manifest["icons"]), len(manifest["env"])))


if __name__ == "__main__":
    main()
