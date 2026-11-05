"""MD-1 (docs/39): dựng bộ quái HD từ mon_catalog.

    python tools/art/hd/mon_build.py                 # sinh sheet + ảnh duyệt (không ghi manifest)
    python tools/art/hd/mon_build.py wolf boss       # chỉ vài id
    python tools/art/hd/mon_build.py --doc           # in bảng thiết kế (markdown) cho docs/39 §4

build_hd.py gọi build_all() để ghi lớp phủ manifest["hd"]["sprites"].

Kích thước logic (w / px) luôn bằng bản pixel cùng id; độ phân giải L (24 / 32 / 48…) chỉ đổi px.
Kích thước hiển thị: size_mul HD được TỰ HIỆU CHỈNH theo hình pixel cùng id (khung bao frame idle 0, trung bình nhân
cao × rộng) rồi nhân BOOST, để quái HD to tương đương bản pixel — vùng va chạm và cảm giác to nhỏ không đổi.
"""
import json
import math
import os
import sys

from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(HERE)))
ASSETS = os.path.join(ROOT, "godot", "assets")
MANIFEST = os.path.join(ASSETS, "art_manifest.json")
REVIEW = os.path.join(ROOT, "docs", "design", "monsters")
FONT = os.path.join(ASSETS, "fonts", "BeVietnamPro-Medium.ttf")
FONT_B = os.path.join(ASSETS, "fonts", "BeVietnamPro-ExtraBold.ttf")

import mon_beast  # noqa: E402
import mon_biped  # noqa: E402
import mon_catalog  # noqa: E402
import mon_kit  # noqa: E402
import mon_misc  # noqa: E402

DRAW = {"biped": mon_biped.draw, "beast": mon_beast.draw}
DRAW.update(mon_misc.BUILDERS)
DEATH = {"biped": "fall", "spirit": "fade", "eye": "fade"}
BOOST = 1.12  # HD hơi to hơn pixel một chút cho thấy chi tiết (G0: sói 1.35 trên khung tương đương)


def _pixel():
    with open(MANIFEST, encoding="utf-8") as f:
        return json.load(f)


def _bbox(img, thr):
    a = img.getchannel("A").point(lambda v: 255 if v > thr else 0)
    return a.getbbox()


def spec_of(mid, man):
    e = dict(mon_catalog.M[mid])
    pix = man["sprites"].get(mid, {})
    e["name"] = pix.get("name", mid)
    # độ phân giải: ảnh HD (4L) không nhỏ hơn cỡ hiển thị của bản pixel (w × 2 × size_mul)
    need = pix.get("w", 24) * float(pix.get("size_mul", 1.0)) / 2.0
    e["L"] = max(e["L"], int(math.ceil(need / 8.0) * 8))
    e.setdefault("death", DEATH.get(e["b"], "crumble"))
    e["size_mul"] = 1.0
    return e


def calibrate(mid, sheet, spec, man):
    """size_mul HD sao cho khung bao idle 0 (px logic × size_mul) ≈ bản pixel × BOOST."""
    pix = man["sprites"].get(mid)
    n = spec["L"] * mon_kit.PX
    hb = _bbox(sheet.crop((0, 0, n, n)), 120)
    if not pix or not hb:
        return 1.0
    pimg = Image.open(os.path.join(ASSETS, pix["path"].replace("res://assets/", "").replace("/", os.sep)))
    pb = _bbox(pimg.crop((0, 0, pix["w"], pix["h"])), 60)
    if not pb:
        return 1.0
    ph_, pw_ = (pb[3] - pb[1]) * float(pix.get("size_mul", 1.0)), (pb[2] - pb[0]) * float(pix.get("size_mul", 1.0))
    px = n / float(pix["w"])
    hh, hw = (hb[3] - hb[1]) / px, (hb[2] - hb[0]) / px
    return round(math.sqrt((ph_ / hh) * (pw_ / hw)) * BOOST, 3)


def build_one(mid, man):
    spec = spec_of(mid, man)
    sheet, meta = mon_kit.build(spec, DRAW[spec["b"]])
    # độ nét theo cỡ hiển thị THẬT (sau hiệu chỉnh): ảnh frame (4L) ≥ w_logic × 2 × size_mul, nếu thiếu thì dựng lại to hơn
    pw0 = man["sprites"].get(mid, {}).get("w", spec["L"])
    need = int(math.ceil(pw0 * calibrate(mid, sheet, spec, man) / 2.0 / 8.0) * 8)
    if need > spec["L"]:
        spec["L"] = need
        sheet, meta = mon_kit.build(spec, DRAW[spec["b"]])
    # kích thước logic (w / px) = bản pixel cùng id → khung chân dung / mục tiêu không đổi; độ nét nằm ở px
    pw = man["sprites"].get(mid, {}).get("w", spec["L"])
    meta["px"] = round(meta["w"] / float(pw), 4)
    meta["size_mul"] = calibrate(mid, sheet, spec, man)
    return sheet, meta, spec


def build_all(save, ids=None, live_only=True):
    """Sinh mọi quái; save(img, sub, name) -> res path. Trả về {id: meta} để ghi vào manifest["hd"]["sprites"]."""
    man = _pixel()
    out = {}
    ids = ids or list(mon_catalog.M)
    for mid in ids:
        sheet, meta, spec = build_one(mid, man)
        if live_only and mid in mon_catalog.LIVE_EXCLUDE:
            save(sheet, "sprites-review", mid)
            continue
        meta["path"] = save(sheet, "sprites", mid)
        out[mid] = meta
    return out


# ------------------------------------------------------------------ ảnh duyệt
def _font(sz, bold=False):
    try:
        return ImageFont.truetype(FONT_B if bold else FONT, sz)
    except OSError:
        return ImageFont.load_default()


def review(results, man):
    """docs/design/monsters/vung-<n>.png: mỗi quái 1 ô — pixel cũ (trái, nhỏ) · HD idle (giữa, lớn) · dải hoạt ảnh."""
    os.makedirs(REVIEW, exist_ok=True)
    groups = {}
    for mid, (sheet, meta, spec) in results.items():
        groups.setdefault(spec["region"], []).append((mid, sheet, meta, spec))
    cell_w, cell_h = 560, 300
    for reg, items in groups.items():
        cols = 3
        rows = (len(items) + cols - 1) // cols
        W, H = cols * cell_w, rows * cell_h + 70
        img = Image.new("RGBA", (W, H), (28, 24, 38, 255))
        d = ImageDraw.Draw(img)
        d.text((24, 18), "Vùng %s · %s — thiết kế lại quái (MD-1, docs/39)" % (reg, mon_catalog.REGION_NAMES[reg]), font=_font(28, True),
               fill=(240, 226, 190))
        for k, (mid, sheet, meta, spec) in enumerate(items):
            cx, cy = (k % cols) * cell_w, 70 + (k // cols) * cell_h
            d.rounded_rectangle([cx + 8, cy + 6, cx + cell_w - 8, cy + cell_h - 6], 14, fill=(52, 70, 50, 255), outline=(90, 80, 110))
            n = meta["w"]
            big = sheet.crop((0, 0, n, n)).resize((210, 210), Image.LANCZOS)
            img.alpha_composite(big, (cx + 110, cy + 40))
            pix = man["sprites"].get(mid)
            if pix:
                pimg = Image.open(os.path.join(ASSETS, pix["path"].replace("res://assets/", "").replace("/", os.sep))).convert("RGBA")
                pf = pimg.crop((0, 0, pix["w"], pix["h"]))
                sc = max(1, 96 // pix["w"])
                pf = pf.resize((pix["w"] * sc, pix["h"] * sc), Image.NEAREST)
                img.alpha_composite(pf, (cx + 14, cy + 150 - pf.size[1] // 2))
                d.text((cx + 18, cy + 214), "pixel cũ", font=_font(13), fill=(190, 200, 190))
            # dải hoạt ảnh: run 0..3, attack 0..2, death 2
            strip = [(1, q) for q in range(4)] + [(2, q) for q in range(3)] + [(4, 2)]
            for j, (r, q) in enumerate(strip):
                fr = sheet.crop((q * n, r * n, q * n + n, r * n + n)).resize((58, 58), Image.LANCZOS)
                img.alpha_composite(fr, (cx + 330 + (j % 4) * 56, cy + 60 + (j // 4) * 64))
            tier = {"boss": "BOSS", "tinh_anh": "Tinh anh", "thuong": "Thường", "linh_thu": "Linh thú"}[spec["tier"]]
            d.text((cx + 20, cy + 14), "%s  ·  %s" % (spec["name"], tier), font=_font(17, True), fill=(250, 240, 210))
            d.text((cx + 330, cy + 196), "%s · ×%.2f" % (mid, meta["size_mul"]), font=_font(12), fill=(170, 180, 170))
            _wrap(d, spec["concept"], cx + 20, cy + 252, cell_w - 40, _font(12), (215, 215, 200))
        img.convert("RGB").save(os.path.join(REVIEW, "vung-%s.png" % reg), quality=92)


def _wrap(d, text, x, y, w, font, col):
    line, yy = "", y
    for word in text.split():
        t = (line + " " + word).strip()
        if d.textlength(t, font=font) > w:
            d.text((x, yy), line, font=font, fill=col)
            line, yy = word, yy + 16
        else:
            line = t
    d.text((x, yy), line, font=font, fill=col)


def doc_table():
    man = _pixel()
    print("| Vùng | id | Tên | Hạng | Dáng | Ý tưởng thiết kế |")
    print("| --- | --- | --- | --- | --- | --- |")
    for mid, e in mon_catalog.M.items():
        name = man["sprites"].get(mid, {}).get("name", mid)
        tier = {"boss": "Boss", "tinh_anh": "Tinh anh", "thuong": "Thường", "linh_thu": "Linh thú"}[e["tier"]]
        print("| %s | `%s` | %s | %s | %s | %s |" % (e["region"], mid, name, tier, e["b"], e["concept"]))


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    if "--doc" in sys.argv:
        doc_table()
        return
    man = _pixel()
    ids = args or list(mon_catalog.M)
    results = {}
    for mid in ids:
        results[mid] = build_one(mid, man)
        print(mid, results[mid][1]["size_mul"], results[mid][2]["L"])
    review(results, man)


if __name__ == "__main__":
    main()
