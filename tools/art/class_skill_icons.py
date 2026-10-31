"""AR-44: icon kỹ năng 5 lớp cắt từ hình chủ dự án cung cấp (tools/art/src/class-skills.png, 1536×1024 — bảng 5 cột,
mỗi cột 4 kỹ năng có icon vuông viền sáng). Lấy phần trong viền, thu về ICON×ICON. Ghi đè icon vẽ bằng code cùng id.

    python tools/art/class_skill_icons.py   # ghi PNG + vá art_manifest.json (chỉ các mục skill-* dưới đây)

icons.build_all() cũng gọi build() (sau mọi icon vẽ bằng code) nên chạy lại build_all.py vẫn giữ các icon này.
Id = trường "icon" của kỹ năng trong classes.gd (docs/19, docs/21 bảng ánh xạ).
"""
import json
import os

import numpy as np
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
ASSETS = os.path.join(ROOT, "godot", "assets")
SRC = os.path.join(HERE, "src", "class-skills.png")

ICON = 48           # giao diện co giãn icon theo ô (skill_bar, skill_panel) nên lấy to hơn 32 cho rõ nét
COL_X = [24, 329, 634, 939, 1244]   # mép trái viền icon (ước lượng, dò lại ±8 px)
ROW_Y = [469, 551, 632, 714]        # mép trên viền icon
BOX = 60                             # cỡ viền ngoài
## [lớp][hàng] → id icon. Hỏa Cầu là đánh thường của Pháp Sư (icon "fireball").
IDS = [
    ["wave", "lientram", "kiemy", "vankiem"],              # Kiếm Khách: Trảm Phong, Nguyệt Ảnh Liên Trảm, Kiếm Ý, Vạn Kiếm Quy Tông
    ["pierce", "rain", "lanban", "thientien"],             # Cung Thủ: Xuyên Tâm Tiễn, Vũ Tiễn, Lộn Nhào, Thiên Tiễn
    ["fireball", "banglao", "chain", "thienhoa"],          # Pháp Sư: Hỏa Cầu, Băng Lao, Sét Chuỗi, Thiên Tai Nguyên Tố
    ["khienthep", "khieukhich", "chandia", "thanhbatdiet"],  # Hộ Vệ: Khiên Thép, Khiêu Khích, Chấn Địa, Thành Bất Diệt
    ["soibong", "tieuquy", "lienket", "quandoan"],         # Triệu Hồi Sư: Sói Bóng, Tiểu Quỷ, Liên Kết Linh Hồn, Quân Đoàn
]


def _edge(guess, along):
    """Dò mép viền gần guess (±8 px): hàng/cột sáng đều suốt chiều dài (phân vị 10% cao nhất) — phần trong icon có chỗ tối."""
    best, best_v = guess, -1.0
    for p in range(guess - 8, guess + 9):
        v = float(along(p))
        if v > best_v:
            best, best_v = p, v
    return best


def build():
    """{"skill-<id>": Image RGBA ICON×ICON}."""
    im = Image.open(SRC).convert("RGB")
    lum = np.asarray(im).astype(float).sum(axis=2)
    out = {}
    for ci, x0 in enumerate(COL_X):
        for ri, y0 in enumerate(ROW_Y):
            x = _edge(x0, lambda p: np.percentile(lum[y0 + 6:y0 + BOX - 6, p], 10))
            y = _edge(y0, lambda p: np.percentile(lum[p, x + 6:x + BOX - 6], 10))
            # phần trong viền (viền 2 px + 1 px đệm)
            inner = im.crop((x + 3, y + 3, x + BOX - 4, y + BOX - 4))  # viền phải/dưới lệch 57–61 px
            out["skill-" + IDS[ci][ri]] = inner.resize((ICON, ICON), Image.LANCZOS).convert("RGBA")
    return out


def main():
    path = os.path.join(ASSETS, "art_manifest.json")
    with open(path, encoding="utf-8") as f:
        manifest = json.load(f)
    for iid, img in build().items():
        img.save(os.path.join(ASSETS, "icons", iid + ".png"))
        manifest["icons"][iid] = "res://assets/icons/%s.png" % iid
    with open(path, "w", encoding="utf-8", newline=chr(10)) as f:
        json.dump(manifest, f, ensure_ascii=False, indent=1)
    import sys
    sys.path.insert(0, HERE)
    from build_all import contact
    contact("class-skill-icons", list(build().items()), scale=3, cols=4)
    print("ok: %d icon" % sum(len(r) for r in IDS))


if __name__ == "__main__":
    main()
