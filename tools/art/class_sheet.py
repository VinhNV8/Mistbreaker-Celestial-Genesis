"""AR-44: cắt sprite sheet 5 lớp (tools/art/src/class-sheet.png, 1536×1024, người dùng cung cấp) thành sheet hoạt ảnh
"pc-<lớp>" cho game. Nền tối của sheet được tách bằng khoảng cách màu so với nền cục bộ; viền tối (tối hơn nền) luôn giữ.

    python tools/art/class_sheet.py          # cắt + ghi PNG + vá art_manifest.json (không đụng sprite khác)
    python tools/art/class_sheet.py --debug  # thêm ảnh soi khung cắt ở tools/art/_preview/class-sheet-cut.png

build_all.py cũng gọi build() nên chạy lại toàn bộ vẫn giữ các sprite này.
Hàng lấy từ sheet: idle · run · attack · hurt · death (bỏ hàng kỹ năng/tối thượng — hiệu ứng do game vẽ).
"""
import json
import os
import sys

import numpy as np
from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
ASSETS = os.path.join(ROOT, "godot", "assets")
SRC = os.path.join(HERE, "src", "class-sheet.png")

## Cột của mỗi lớp trên sheet (x đầu, x cuối) và dải y của mỗi hàng hoạt ảnh.
COLS = {"kiem-khach": (8, 306), "tho-san": (314, 612), "phap-su": (620, 916), "ho-ve": (924, 1222),
        "trieu-hoi-su": (1228, 1528)}
ROWS = {"idle": (168, 231), "run": (236, 297), "attack": (302, 375), "hurt": (726, 785), "death": (789, 849)}
NAMES = {"kiem-khach": "Kiếm Khách", "tho-san": "Cung Thủ", "phap-su": "Pháp Sư", "ho-ve": "Hộ Vệ",
         "trieu-hoi-su": "Triệu Hồi Sư"}
## Số frame mong đợi (tách đoạn dính nhau cho đủ).
EXPECT = {"idle": 5, "run": 4, "hurt": 5, "death": 4}
EXPECT_CLASS = {("trieu-hoi-su", "idle"): 4, ("trieu-hoi-su", "hurt"): 4}
## Hàng đánh thường: chỉ lấy frame có nhân vật (đạn/quả cầu bay riêng do game vẽ) — x tuyệt đối trên sheet.
ATTACK = {
    "kiem-khach": [(74, 117), (132, 173), (182, 239), (246, 299)],
    "tho-san": [(389, 436), (453, 495), (511, 547)],
    "phap-su": [(702, 753), (765, 803)],
    "ho-ve": [(1005, 1041), (1065, 1146), (1153, 1208)],
    "trieu-hoi-su": [(1303, 1338), (1373, 1414)],
}
FPS = {"idle": 5, "run": 9, "attack": 12, "hurt": 8, "death": 6}
LOOP = {"idle": True, "run": True, "attack": False, "hurt": False, "death": False}
SCALE = 0.62        # nhân vật ~52 px trên sheet → ~32 px trong frame
SIZE_MUL = 0.85     # vẽ trong game: 2 × 0.85 ≈ cùng chiều cao hero cũ (32×32, ×2)

_sheet = None


def _img():
    global _sheet
    if _sheet is None:
        _sheet = np.asarray(Image.open(SRC).convert("RGB")).astype(float)
    return _sheet


def _alpha(x0, x1, y0, y1, lines=True):
    """Ảnh RGBA (float 0..1 alpha) của vùng, nền = trung vị màu vùng."""
    blk = _img()[y0:y1, x0:x1]
    bg = np.median(blk.reshape(-1, 3), axis=0)
    d = np.abs(blk - bg).sum(axis=2)
    lum = blk.mean(axis=2)
    al = np.clip((d - 16) / 40, 0, 1)
    al[(lum < bg.mean() - 4) & (d > 12)] = 1  # viền/bóng tối hơn nền
    # bỏ đường kẻ ngang/dọc của khung sheet
    m = al > 0.5
    if lines:
        al[m[:, 90:-6].mean(axis=1) > 0.75, :] = 0  # bỏ qua vùng chữ tên hàng
    edge = (al > 0.5).mean(axis=0) > 0.8
    edge[8:-8] = False  # chỉ viền cột (vệt chém dày ở giữa không phải đường kẻ)
    if lines:
        al[:, edge] = 0
    # màu thật của điểm bán trong suốt (tách nền ra khỏi quầng sáng)
    a3 = np.maximum(al, 1e-3)[..., None]
    rgb = np.clip((blk - bg * (1 - a3)) / a3, 0, 255)
    rgb = np.where(al[..., None] >= 1, blk, rgb)
    return rgb, al


def _components(mask, min_px):
    """Bỏ mảng liền nhau nhỏ hơn min_px (nhiễu nền)."""
    h, w = mask.shape
    seen = np.zeros_like(mask)
    keep = np.zeros_like(mask)
    for sy in range(h):
        for sx in range(w):
            if not mask[sy, sx] or seen[sy, sx]:
                continue
            stack = [(sy, sx)]
            seen[sy, sx] = True
            pts = []
            while stack:
                y, x = stack.pop()
                pts.append((y, x))
                for ny in (y - 1, y, y + 1):
                    for nx in (x - 1, x, x + 1):
                        if 0 <= ny < h and 0 <= nx < w and mask[ny, nx] and not seen[ny, nx]:
                            seen[ny, nx] = True
                            stack.append((ny, nx))
            if len(pts) >= min_px:
                for y, x in pts:
                    keep[y, x] = True
    return keep


def _segments(cls, row):
    """Các khoảng x (tuyệt đối) chứa từng frame của hàng."""
    x0, x1 = COLS[cls]
    y0, y1 = ROWS[row]
    if row == "attack":
        return [(a - 2, b + 2) for a, b in ATTACK[cls]], True
    _, al = _alpha(x0, x1, y0, y1)
    m = al > 0.5
    m[:44, :82] = False  # chữ tên hàng
    m[:, :6] = False
    m[:, -6:] = False
    proj = m.sum(axis=0)
    segs, start = [], None
    for x, v in enumerate(proj):
        if v > 0 and start is None:
            start = x
        if v == 0 and start is not None:
            segs.append([start, x])
            start = None
    if start is not None:
        segs.append([start, len(proj)])
    segs = [s for s in segs if m[:, s[0]:s[1]].sum() > 25]
    want = EXPECT_CLASS.get((cls, row), EXPECT[row])
    while len(segs) > want:  # một frame bị đứt (xác nằm, vệt máu): nối hai đoạn gần nhau nhất
        i = min(range(len(segs) - 1), key=lambda k: segs[k + 1][0] - segs[k][1])
        segs[i:i + 2] = [[segs[i][0], segs[i + 1][1]]]
    while len(segs) < want:  # tách đoạn rộng nhất tại cột ít điểm nhất ở khúc giữa
        i = max(range(len(segs)), key=lambda k: segs[k][1] - segs[k][0])
        a, b = segs[i]
        lo, hi = a + (b - a) // 3, b - (b - a) // 3
        cut = lo + int(np.argmin(proj[lo:hi]))
        segs[i:i + 1] = [[a, cut], [cut, b]]
    # nới tới giữa khoảng trống hai bên để không mất phần mờ (xác nằm, vệt sáng)
    out = []
    for i, (a, b) in enumerate(segs):
        lo = (segs[i - 1][1] + a) // 2 if i > 0 else max(6, a - 6)
        hi = (b + segs[i + 1][0]) // 2 if i + 1 < len(segs) else min(len(proj) - 6, b + 6)
        out.append((x0 + lo, x0 + hi))
    return out, False


def _frame(cls, row, xa, xb):
    """Cắt 1 frame: trả về (RGBA uint8 ở độ phân giải sheet, gốc chân (x, y) trong ảnh)."""
    x0, x1 = COLS[cls]
    y0, y1 = ROWS[row]
    rgb, al = _alpha(x0, x1, y0, y1)  # tách nền trên cả hàng (đường kẻ khung nhận ra được), rồi cắt
    rgb, al = rgb[:, xa - x0:xb - x0], al[:, xa - x0:xb - x0].copy()
    if xa - x0 < 82:  # chữ tên hàng nằm ở góc trên trái cột
        al[:44, :max(0, x0 + 82 - xa)] = 0
    keep = _components(al > 0.3, 10)
    al = np.where(keep, al, 0)
    lum = rgb.mean(axis=2)
    dark = (al >= 1) & (lum < 70)
    ys, xs = np.nonzero(dark if dark.sum() > 30 else al > 0.5)
    foot_y = int(np.percentile(ys, 98)) + 1
    foot_x = float(np.median(xs))
    rgba = np.dstack([rgb, al * 255]).astype(np.uint8)
    return rgba, foot_x, foot_y


def _shrink(rgba, fx, fy):
    """Thu nhỏ về lưới pixel game: lấy mẫu giữa ô (giữ nét) rồi chốt alpha."""
    h, w = rgba.shape[:2]
    nw, nh = max(1, round(w * SCALE)), max(1, round(h * SCALE))
    im = Image.fromarray(rgba, "RGBA")
    box = np.asarray(im.resize((nw, nh), Image.BOX)).astype(float)
    near = np.asarray(im.resize((nw, nh), Image.NEAREST)).astype(float)
    # màu: điểm gần nhất (sắc nét); alpha: trung bình ô (không mất viền mảnh)
    a = box[..., 3]
    rgb = np.where(near[..., 3:4] > 127, near[..., :3], box[..., :3] / np.maximum(a[..., None] / 255, 1e-3))
    a = np.where(a > 150, 255, np.where(a < 70, 0, a))
    out = np.dstack([np.clip(rgb, 0, 255), a]).astype(np.uint8)
    return Image.fromarray(out, "RGBA"), fx * nw / w, fy * nh / h


def build_class(cls):
    rows = {}
    for row in ROWS:
        segs, _exact = _segments(cls, row)
        frames = []
        cut = []
        for xa, xb in segs:
            rgba, fx, fy = _frame(cls, row, xa, xb)
            cut.append((xa, xb))
            frames.append((rgba, fx, fy))
        # cả hàng chung một mặt đất (trung vị chân); idle/run/hurt đứng — x gốc theo từng frame
        ground = int(np.median([f[2] for f in frames]))
        small = []
        for rgba, fx, fy in frames:
            im, sx, sy = _shrink(rgba, fx, ground)
            small.append((im, sx, sy))
        rows[row] = (small, cut)
    # khung chung: đủ chứa mọi frame quanh điểm chân
    left = max(sx for r in rows.values() for _, sx, _ in r[0])
    right = max(im.width - sx for r in rows.values() for im, sx, _ in r[0])
    up = max(sy for r in rows.values() for _, _, sy in r[0])
    down = max(im.height - sy for r in rows.values() for im, _, sy in r[0])
    ox, oy = int(np.ceil(left)) + 1, int(np.ceil(up)) + 1
    fw, fh = ox + int(np.ceil(right)) + 1, oy + int(np.ceil(down)) + 1
    ncol = max(len(r[0]) for r in rows.values())
    sheet = Image.new("RGBA", (fw * ncol, fh * len(rows)), (0, 0, 0, 0))
    anims = {}
    for ri, (row, (small, _)) in enumerate(rows.items()):
        for ci, (im, sx, sy) in enumerate(small):
            sheet.alpha_composite(im, (ci * fw + ox - round(sx), ri * fh + oy - round(sy)))
        anims[row] = {"row": ri, "frames": len(small), "fps": FPS[row], "loop": LOOP[row]}
    meta = {"w": fw, "h": fh, "origin": [ox, oy], "anims": anims, "name": NAMES[cls], "size_mul": SIZE_MUL}
    return sheet, meta, {r: v[1] for r, v in rows.items()}


## Chân dung bán thân ở đầu mỗi cột sheet (giữ nền khung màu lớp) → icon "portrait-<lớp>" (ô lớp ở màn Tạo nhân vật).
BUST = (22, 90, 96, 164)  # x tính từ mép trái cột, y tuyệt đối — nằm trong khung, tránh đường viền trên/dưới


def busts():
    """{"portrait-<lớp>": Image RGBA 74×74}; icons.build_all() gọi sau portraits.py nên ghi đè chân dung vẽ bằng code."""
    im = Image.open(SRC).convert("RGBA")
    return {"portrait-" + cls: im.crop((x0 + BUST[0], BUST[1], x0 + BUST[2], BUST[3])) for cls, (x0, _) in COLS.items()}


## Mảnh hiệu ứng tách từ hàng kỹ năng/tối thượng (x0, y0, x1, y1 tuyệt đối trên sheet), tỉ lệ thu, xoay (độ, ngược kim
## đồng hồ — để đạn hướng sang phải), lật ngang, gốc vẽ ("center" | "tip": đáy giữa, chỗ chạm đất).
FX = {
    "fx-sheet-fireball": ((826, 396, 908, 444), 0.45, 0, False, "head"),       # Pháp Sư · Hỏa Cầu (đầu cầu lửa bên phải)
    "fx-sheet-tramphong": ((232, 396, 290, 446), 0.65, 0, False, "center"),    # Kiếm Khách · Trảm Phong (trăng khuyết đỏ)
    "fx-sheet-kiemy": ((234, 546, 298, 610), 0.55, 0, False, "center"),        # Kiếm Khách · Kiếm Ý (bùng sáng đỏ)
    "fx-sheet-vankiem": ((247, 622, 280, 717), 0.5, 0, False, "tip"),          # Kiếm Khách · Vạn Kiếm Quy Tông (kiếm khí cắm đất)
    "fx-sheet-xuyentam": ((516, 398, 602, 442), 0.45, 0, False, "head"),       # Cung Thủ · Xuyên Tâm Tiễn
    "fx-sheet-thientien": ((448, 622, 488, 717), 0.5, 0, False, "tip"),        # Cung Thủ · Thiên Tiễn (mũi tên trời)
    "fx-sheet-banglao": ((703, 478, 748, 530), 0.6, -45, False, "head"),       # Pháp Sư · Băng Lao (giáo băng chéo → xoay ngang)
    "fx-sheet-meteor-fire": ((648, 640, 692, 717), 0.5, 0, True, "tip"),       # Pháp Sư · Thiên Tai (thiên thạch lửa, lật: rơi từ trái)
    "fx-sheet-meteor-ice": ((700, 640, 746, 717), 0.5, 0, True, "tip"),        # Pháp Sư · Thiên Tai (đợt băng)
    "fx-sheet-khienthep": ((1105, 398, 1156, 450), 0.55, 0, False, "center"),  # Hộ Vệ · Khiên Thép (khiên vàng)
}


def _fx_piece(box, scale, rot, flip, anchor):
    x0, y0, x1, y1 = box
    blk = _img()[y0:y1, x0:x1]
    # nền: phân vị 25% độ sáng của viền hộp (nền sheet đổi màu theo cột/hàng; quầng sáng chạm viền thì lấy phần tối nhất)
    ring = np.concatenate([blk[:2].reshape(-1, 3), blk[-2:].reshape(-1, 3), blk[:, :2].reshape(-1, 3), blk[:, -2:].reshape(-1, 3)])
    order = np.argsort(ring.sum(axis=1))
    bg = np.median(ring[order[:len(order) // 2]], axis=0)
    d = np.abs(blk - bg).sum(axis=2)
    al = np.clip((d - 14) / 60, 0, 1)
    a3 = np.maximum(al, 1e-3)[..., None]
    rgb = np.clip((blk - bg * (1 - a3)) / a3, 0, 255)
    keep = _components(al > 0.3, 6)
    al = np.where(keep | (al <= 0.3), al, 0)
    rgba = Image.fromarray(np.dstack([rgb, al * 255]).astype(np.uint8), "RGBA")
    if flip:
        rgba = rgba.transpose(Image.FLIP_LEFT_RIGHT)
    if rot:
        rgba = rgba.rotate(rot, resample=Image.BICUBIC, expand=True)
    rgba = rgba.crop(rgba.getbbox())
    rgba = rgba.resize((max(1, round(rgba.width * scale)), max(1, round(rgba.height * scale))), Image.BOX)
    a = np.asarray(rgba).copy()
    a[..., 3] = np.where(a[..., 3] < 24, 0, a[..., 3])
    rgba = Image.fromarray(a, "RGBA")
    rgba = rgba.crop(rgba.getbbox())
    w, h = rgba.size
    origin = {"center": [w // 2, h // 2], "tip": [w // 2, h - 1], "head": [w - h // 2, h // 2]}[anchor]
    return rgba, origin


def fx():
    """{"fx-sheet-…": (Image RGBA, [ox, oy])} — env của manifest; build_all.py gọi."""
    return {k: _fx_piece(*v) for k, v in FX.items()}


def build():
    """{id: (sheet RGBA, meta không có path)} cho build_all.py."""
    out = {}
    for cls in COLS:
        sheet, meta, _ = build_class(cls)
        out["pc-" + cls] = (sheet, meta)
    return out


def _debug(cuts):
    im = Image.open(SRC).convert("RGB")
    dr = ImageDraw.Draw(im)
    for cls, rows in cuts.items():
        for row, segs in rows.items():
            y0, y1 = ROWS[row]
            for xa, xb in segs:
                dr.rectangle([xa, y0, xb - 1, y1 - 1], outline=(0, 255, 0))
    os.makedirs(os.path.join(HERE, "_preview"), exist_ok=True)
    im.save(os.path.join(HERE, "_preview", "class-sheet-cut.png"))


def main():
    path = os.path.join(ASSETS, "art_manifest.json")
    with open(path, encoding="utf-8") as f:
        manifest = json.load(f)
    cuts = {}
    previews = []
    for cls in COLS:
        sheet, meta, cut = build_class(cls)
        cuts[cls] = cut
        sid = "pc-" + cls
        sheet.save(os.path.join(ASSETS, "sprites", sid + ".png"))
        manifest["sprites"][sid] = dict({"path": "res://assets/sprites/%s.png" % sid}, **meta)
        previews.append((sid, sheet))
        print(sid, sheet.size, "frame %dx%d origin %s" % (meta["w"], meta["h"], meta["origin"]),
              {k: v["frames"] for k, v in meta["anims"].items()})
    for eid, (img, origin) in fx().items():
        img.save(os.path.join(ASSETS, "env", eid + ".png"))
        manifest["env"][eid] = {"path": "res://assets/env/%s.png" % eid, "w": img.width, "h": img.height, "origin": origin}
        previews.append((eid, img))
    for iid, img in busts().items():
        img.save(os.path.join(ASSETS, "icons", iid + ".png"))
        manifest["icons"][iid] = "res://assets/icons/%s.png" % iid
    with open(path, "w", encoding="utf-8", newline=chr(10)) as f:
        json.dump(manifest, f, ensure_ascii=False, indent=1)
    if "--debug" in sys.argv:
        _debug(cuts)
    sys.path.insert(0, HERE)
    from build_all import contact
    contact("class-sheet", previews, scale=4)


if __name__ == "__main__":
    main()
