"""UI-27: cắt mảnh trang trí từ ảnh mẫu bảng Nhân vật của chủ dự án (tools/art/src/ui-character-mockup.png, 1536×1024)
ra godot/assets/ui/. Chủ dự án chọn dùng nét vẽ của ảnh mẫu cho khung giao diện (28/10/2026) — chỉ cắt phần trang trí;
chữ, số, chân dung, ô trang bị vẫn do game vẽ. Chữ in sẵn trong ô Lực chiến / Điểm thuộc tính được xoá và tô bù
(khuếch tán màu từ viền vùng xoá). Chạy: python tools/art/ui_cut.py
"""
import os

import numpy as np
from PIL import Image

ROOT = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.join(ROOT, "src", "ui-character-mockup.png")
SRC_TOPBAR = os.path.join(ROOT, "src", "ui-topbar-mockup.png")
OUT = os.path.join(ROOT, "..", "..", "godot", "assets", "ui")

# Hàng thuộc tính trong ảnh mẫu: mép trên của 7 hàng STR VIT AGI INT WIS DEX LUK
ROW_TOPS = [188, 282, 376, 471, 569, 666, 764]
ATTRS = ["str", "vit", "agi", "int", "wis", "dex", "luk"]


def fill_hole(im, box, iters=600):
    """Xoá vùng box (x0, y0, x1, y1) rồi tô bù bằng khuếch tán màu từ viền vào trong, thêm hạt nhiễu nhẹ như nền."""
    a = np.asarray(im).astype(np.float32)
    x0, y0, x1, y1 = box
    ring = np.concatenate([a[y0 - 1, x0:x1], a[y1, x0:x1], a[y0:y1, x0 - 1], a[y0:y1, x1]])
    a[y0:y1, x0:x1] = ring.mean(axis=0)
    for _ in range(iters):
        sub = a[y0 - 1:y1 + 1, x0 - 1:x1 + 1]
        a[y0:y1, x0:x1] = (sub[:-2, 1:-1] + sub[2:, 1:-1] + sub[1:-1, :-2] + sub[1:-1, 2:]) / 4.0
    rng = np.random.default_rng(7)
    noise = rng.normal(0.0, ring[:, :3].std(axis=0).mean() * 0.06, (y1 - y0, x1 - x0, 1))
    a[y0:y1, x0:x1, :3] += noise
    return Image.fromarray(np.clip(a, 0, 255).astype(np.uint8), im.mode)


def feather(im, px):
    """Mờ dần về trong suốt ở 4 mép (mảnh đặt lên nền tối của game không lộ mép cắt)."""
    im = im.convert("RGBA")
    w, h = im.size
    xs = np.minimum(np.arange(w), np.arange(w)[::-1]) / px
    ys = np.minimum(np.arange(h), np.arange(h)[::-1]) / px
    m = np.clip(np.minimum.outer(ys, xs), 0.0, 1.0)
    a = np.asarray(im).astype(np.float32)
    a[..., 3] *= m
    return Image.fromarray(a.astype(np.uint8), "RGBA")


def hstrip(im, left, mid, right, y0, y1):
    """Ghép mảnh 9-slice ngang: mép trái + 1 lát giữa + mép phải (x0, x1 mỗi phần)."""
    parts = [im.crop((x0, y0, x1, y1)) for x0, x1 in (left, mid, right)]
    w = sum(p.width for p in parts)
    out = Image.new("RGB", (w, y1 - y0))
    x = 0
    for p in parts:
        out.paste(p, (x, 0))
        x += p.width
    return out


def panel_frame(im):
    """Khung cột 96×96 (9-slice, lề 32): góc hoa văn chữ X lấy ở góc dưới-trái cột giữa, lật cho đủ 4 góc;
    cạnh = viền vàng mảnh; phần trong là màu nền bảng (hơi trong)."""
    c = 32
    corner = im.crop((495, 976, 495 + c, 976 + c)).convert("RGBA")  # góc dưới-trái
    # màu nền = phần phía trong của lát viền dưới (cùng chỗ với góc, không lệch tông)
    bg = np.asarray(im.crop((1000, 976, 1010, 990))).reshape(-1, 3).mean(axis=0)
    fill = (int(bg[0]), int(bg[1]), int(bg[2]), 255)
    out = Image.new("RGBA", (96, 96), fill)
    edge_v = im.crop((495, 600, 495 + 14, 601)).convert("RGBA")  # viền trái: 14 px đầu, còn lại là nền
    edge_h = im.crop((1000, 976, 1001, 976 + c)).convert("RGBA")  # viền dưới
    for y in range(c, 96 - c):
        out.paste(edge_v, (0, y))
        out.paste(edge_v.transpose(Image.FLIP_LEFT_RIGHT), (96 - 14, y))
    for x in range(c, 96 - c):
        out.paste(edge_h, (x, 96 - c))
        out.paste(edge_h.transpose(Image.FLIP_TOP_BOTTOM), (x, 0))
    out.paste(corner, (0, 96 - c))
    out.paste(corner.transpose(Image.FLIP_LEFT_RIGHT), (96 - c, 96 - c))
    out.paste(corner.transpose(Image.FLIP_TOP_BOTTOM), (0, 0))
    out.paste(corner.transpose(Image.ROTATE_180), (96 - c, 0))
    return out


def topbar():
    """UI-28: thanh tiêu đề bảng Nhân vật (tools/art/src/ui-topbar-mockup.png, 1339×64; dải thanh y 7…63).
    Chữ (tiêu đề, tên tab, số tiền) do game in; ở đây chỉ lấy nền, tab đang chọn (xoá chữ), vạch ngăn, nút, icon tiền."""
    im = Image.open(SRC_TOPBAR).convert("RGB")
    y0, y1 = 7, 64
    out = {}
    out["ui-topbar"] = im.crop((880, y0, 900, y1))  # lát nền trơn, kéo giãn ngang
    out["ui-topbar-back"] = im.crop((0, y0, 68, y1))
    out["ui-topbar-title"] = fill_hole(im, (74, 18, 186, 52)).crop((62, y0, 205, y1))
    out["ui-tab-active"] = fill_hole(im, (222, 18, 318, 50)).crop((206, y0, 333, y1))
    out["ui-tab-sep"] = im.crop((457, y0, 462, y1))
    out["ui-coin"] = im.crop((970, 21, 999, 50))
    out["ui-gem"] = im.crop((1091, 21, 1121, 50))
    out["ui-topbar-plus"] = im.crop((1207, 18, 1240, 51))
    out["ui-topbar-close"] = im.crop((1262, y0, 1337, y1))
    return out


def build():
    os.makedirs(OUT, exist_ok=True)
    im = Image.open(SRC).convert("RGB")
    out = {}
    # 7 icon thuộc tính (khung màu theo thuộc tính)
    for i, k in enumerate(ATTRS):
        t = ROW_TOPS[i]
        out["attr-" + k] = im.crop((519, t + 5, 607, t + 87))
    # hàng thuộc tính 9-slice: mép phải thật + lát giữa sạch + mép phải lật làm mép trái
    t = ROW_TOPS[0]
    right = im.crop((1115, t, 1133, t + 90))
    mid = im.crop((950, t, 975, t + 90))
    row = Image.new("RGB", (18 + 25 + 18, 90))
    row.paste(right.transpose(Image.FLIP_LEFT_RIGHT), (0, 0))
    row.paste(mid, (18, 0))
    row.paste(right, (43, 0))
    out["ui-row"] = row
    out["ui-tag-main"] = im.crop((725, 203, 817, 238))
    out["ui-btn-plus"] = im.crop((1052, 202, 1114, 264))
    out["ui-btn-info"] = im.crop((983, 213, 1023, 255))
    out["ui-btn-gold"] = hstrip(im, (519, 556), (784, 792), (792, 829), 876, 966)
    out["ui-btn-dark"] = hstrip(im, (848, 862), (961, 965), (965, 979), 934, 981)
    # biển Lực chiến: cánh + kiếm, xoá chữ "Lực chiến 5,938"
    power = fill_hole(im, (1250, 165, 1440, 257))
    out["ui-power"] = feather(power.crop((1165, 76, 1523, 284)), 10)
    # ô Điểm thuộc tính: cánh, xoá chữ "Điểm thuộc tính 95"
    pts = fill_hole(im, (920, 92, 1088, 166))
    out["ui-points"] = feather(pts.crop((868, 74, 1138, 190)), 8)
    # cảnh kiếm cắm đất (dưới câu trích dẫn — câu trích do game in theo lớp)
    out["ui-scene"] = im.crop((1162, 834, 1529, 1000))
    out["ui-panel"] = panel_frame(im)
    out.update(topbar())
    for k, v in out.items():
        v.save(os.path.join(OUT, k + ".png"))
    print("ok: %d pieces -> %s" % (len(out), os.path.normpath(OUT)))


if __name__ == "__main__":
    build()
