"""NL-1 (docs/47 §3.A): icon Ngọc Ngũ Hành HD 128×128 — 5 hệ × 3 kiểu cắt + ô lỗ ngọc trống.

Cùng bộ vẽ / phong cách icon HD (vec.py, res_stat_hd.py): cel-shade, viền tối dày, nền trong suốt.
Kiểu cắt theo cấp ngọc (docs/47 §5): cấp 1–3 viên tròn (cabochon), 4–6 cắt giác lục lăng, 7–10 ngọc giọt nước có
đế vàng, lõi sáng và sao lấp lánh. Màu theo hệ (giống huy hiệu ngũ hành UI-13).

    python tools/art/hd/gem_icons.py            # ảnh duyệt docs/design/nl1/ngoc-ngu-hanh.png
    python tools/art/hd/gem_icons.py --apply    # ghi godot/assets/hd/icons/gem-*.png + manifest (icons + hd.icons)
"""
import json
import math
import os
import sys

from PIL import Image, ImageDraw

from vec import Canvas, Tone, hexc, mix

S = 128
OUTLINE = "#140d18"
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(HERE)))
ASSETS = os.path.join(ROOT, "godot", "assets")

## Màu hệ: nền, bóng, sáng.
ELEMENTS = {
    "kim": Tone("#e6ecf6", "#8a98b4", "#ffffff"),
    "moc": Tone("#3ccf7a", "#1a7a44", "#b8ffd0"),
    "thuy": Tone("#34a4ea", "#16508e", "#b4e6ff"),
    "hoa": Tone("#e8423a", "#8a1420", "#ffb0a0"),
    "tho": Tone("#e8a92a", "#94600e", "#fff0a0"),
}
GLOW = {"kim": "#f4f8ff", "moc": "#7affb0", "thuy": "#6ad0ff", "hoa": "#ff7a50", "tho": "#ffd060"}
GOLD = Tone("#e8b648", "#9a6416", "#fff2b8")


def _c():
    return Canvas(S, S, light=(-1.0, -1.2))


def _facets(c, pts, centre, tone):
    """Mặt cắt: tam giác từ tâm tới từng cạnh, sáng / tối xen kẽ theo hướng sáng trên-trái."""
    cx, cy = centre
    n = len(pts)
    for i in range(n):
        a, b = pts[i], pts[(i + 1) % n]
        mx, my = (a[0] + b[0]) / 2 - cx, (a[1] + b[1]) / 2 - cy
        lit = -(mx + my * 1.2) / (math.hypot(mx, my) or 1)
        col = mix(tone.base, tone.light, 0.55) if lit > 0.35 else (mix(tone.base, tone.shade, 0.55) if lit < -0.35 else tone.base)
        c.flat(lambda d, a=a, b=b: c.poly(d, [(cx, cy), a, b]), col, alpha=150)


def _shine(c, x, y, r):
    c.flat(lambda d: c.circle(d, x, y, r), "#ffffff", alpha=240)


def _sparkle(c, x, y, r, col="#ffffff"):
    c.flat(lambda d: c.poly(d, [(x, y - r), (x + r * 0.22, y - r * 0.22), (x + r, y), (x + r * 0.22, y + r * 0.22),
                                (x, y + r), (x - r * 0.22, y + r * 0.22), (x - r, y), (x - r * 0.22, y - r * 0.22)]), col, alpha=235)


def gem_round(el):
    """Cấp 1–3: viên tròn mài nhẵn."""
    t = ELEMENTS[el]
    c = _c()
    c.glow(lambda d: c.circle(d, 64, 66, 40), GLOW[el], 10, 70)
    c.part(lambda d: c.ellipse(d, 64, 66, 36, 32), t, shade_d=9, light_d=3)
    c.flat(lambda d: c.ellipse(d, 54, 54, 16, 9, rot=-0.5), t.light, alpha=170)
    _shine(c, 48, 50, 6)
    return c.render(outline=OUTLINE, width=3)


def gem_hex(el):
    """Cấp 4–6: cắt giác lục lăng, mặt bàn phẳng ở giữa."""
    t = ELEMENTS[el]
    c = _c()
    c.glow(lambda d: c.circle(d, 64, 64, 44), GLOW[el], 12, 100)
    outer = [(64 + 42 * math.cos(math.radians(a)), 64 + 40 * math.sin(math.radians(a))) for a in range(-90, 270, 60)]
    c.part(lambda d: c.poly(d, outer), t, shade_d=7, light_d=2.5)
    _facets(c, outer, (64, 64), t)
    table = [(64 + 20 * math.cos(math.radians(a)), 64 + 19 * math.sin(math.radians(a))) for a in range(-90, 270, 60)]
    c.flat(lambda d: c.poly(d, table), mix(t.base, t.light, 0.35), alpha=230)
    c.flat(lambda d: c.poly(d, [table[5], table[0], (64, 64)]), t.light, alpha=200)
    _shine(c, 52, 46, 5)
    _sparkle(c, 96, 34, 9)
    return c.render(outline=OUTLINE, width=3)


def gem_drop(el):
    """Cấp 7–10: ngọc giọt nước trên đế vàng, lõi sáng, sao lấp lánh."""
    t = ELEMENTS[el]
    c = _c()
    c.glow(lambda d: c.circle(d, 64, 68, 40), GLOW[el], 9, 150)
    # đế vàng 4 chấu
    for ang in (35, 145, 215, 325):
        a = math.radians(ang)
        c.part(lambda d, a=a: c.capsule(d, (64 + 30 * math.cos(a), 72 + 34 * math.sin(a)), (64 + 42 * math.cos(a), 72 + 46 * math.sin(a)), 4.5, 3),
               GOLD, shade_d=2, light_d=1)
    c.part(lambda d: c.ellipse(d, 64, 72, 40, 44), GOLD, shade_d=4, light_d=1.6)
    pts = [(64, 14)]
    for i in range(13):
        a = math.radians(-20 + i * (220 / 12))
        pts.append((64 + 34 * math.cos(a), 76 + 36 * math.sin(a)))
    pts = [pts[0]] + pts[1:]
    c.part(lambda d: c.poly(d, pts), t, shade_d=8, light_d=3)
    _facets(c, pts, (64, 70), t)
    c.glow(lambda d: c.circle(d, 64, 72, 12), "#ffffff", 6, 200)
    c.flat(lambda d: c.circle(d, 64, 72, 6), mix(t.light, hexc("#ffffff"), 0.6), alpha=255)
    c.flat(lambda d: c.poly(d, [(64, 20), (52, 52), (60, 56)]), t.light, alpha=210)
    _shine(c, 52, 48, 4.5)
    _sparkle(c, 98, 30, 12)
    _sparkle(c, 30, 98, 7, GLOW[el])
    return c.render(outline=OUTLINE, width=3)


def socket():
    """Ô lỗ ngọc trống."""
    c = _c()
    c.part(lambda d: c.circle(d, 64, 64, 40), Tone("#4a3a2c", "#241a12", "#7a644c"), shade_d=-6, light_d=0)
    c.flat(lambda d: c.circle(d, 64, 64, 28), "#120c08", alpha=255)
    c.flat(lambda d: c.ellipse(d, 72, 74, 14, 8, rot=-0.6), "#3a2c20", alpha=200)
    return c.render(outline=OUTLINE, width=3)


def build():
    out = {}
    for el in ELEMENTS:
        out["gem-%s-1" % el] = gem_round(el)
        out["gem-%s-2" % el] = gem_hex(el)
        out["gem-%s-3" % el] = gem_drop(el)
    out["gem-socket"] = socket()
    return out


def review(icons, path=None):
    S2 = 96
    cols = 3
    els = list(ELEMENTS)
    sheet = Image.new("RGBA", (cols * (S2 + 12) + 130, len(els) * (S2 + 12) + 40), hexc("#241c2c"))
    d = ImageDraw.Draw(sheet)
    d.text((8, 6), "NL-1 Ngoc Ngu Hanh - cot: cap 1-3 / 4-6 / 7-10", fill=(235, 235, 240))
    for r, el in enumerate(els):
        y = 30 + r * (S2 + 12)
        d.text((8, y + S2 // 2), el, fill=(200, 200, 220))
        for k in range(3):
            sheet.alpha_composite(icons["gem-%s-%d" % (el, k + 1)].resize((S2, S2), Image.LANCZOS), (60 + k * (S2 + 12), y))
    sheet.alpha_composite(icons["gem-socket"].resize((S2, S2), Image.LANCZOS), (60 + 3 * (S2 + 12) - 12, 30))
    path = path or os.path.join(ROOT, "docs", "design", "nl1", "ngoc-ngu-hanh.png")
    os.makedirs(os.path.dirname(path), exist_ok=True)
    sheet.convert("RGB").save(path)


def apply(icons):
    dst = os.path.join(ASSETS, "hd", "icons")
    path = os.path.join(ASSETS, "art_manifest.json")
    m = json.load(open(path, encoding="utf-8"))
    hd = m.setdefault("hd", {}).setdefault("icons", {})
    for k, img in icons.items():
        img.save(os.path.join(dst, k + ".png"), optimize=True)
        res = "res://assets/hd/icons/%s.png" % k
        hd[k] = res
        m["icons"][k] = res  # không có bản pixel: tắt HD vẫn dùng hình này
    with open(path, "w", encoding="utf-8", newline=chr(10)) as f:
        json.dump(m, f, ensure_ascii=False, indent=1)


if __name__ == "__main__":
    icons = build()
    review(icons)
    if "--apply" in sys.argv:
        apply(icons)
    print("ok: %d icon ngoc%s" % (len(icons), " (applied)" if "--apply" in sys.argv else ""))
