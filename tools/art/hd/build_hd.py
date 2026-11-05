"""UI-40 (docs/35): sinh bộ hình HD vào godot/assets/hd/ và ghi lớp phủ "hd" trong art_manifest.json.

    python tools/art/hd/build_hd.py

Lớp phủ: manifest["hd"] = {"sprites": {id: mục}, "env": {id: mục}, "icons": {id: đường dẫn}}. Mục sprite / env có
thêm "px" = số px ảnh trên 1 px logic (4): SpriteLib chia tỉ lệ vẽ cho px, nên vị trí / kích thước trong game giữ
nguyên như hình pixel. Hình chưa có bản HD vẫn dùng bản pixel (bật / tắt ở Cài đặt → "Đồ hoạ HD").
Không đụng các mục khác của manifest (build_all.py / class_sheet.py vẫn chạy độc lập).
"""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(HERE)))
ASSETS = os.path.join(ROOT, "godot", "assets")
MANIFEST = os.path.join(ASSETS, "art_manifest.json")

import env_forest  # noqa: E402
import env_village  # noqa: E402
import env_camps  # noqa: E402
import env_regions  # noqa: E402
import action_icons  # noqa: E402
import icons_hd  # noqa: E402
import items_hd_more  # noqa: E402
import res_stat_hd  # noqa: E402
import mon_build  # noqa: E402  MD-1 (docs/39): 85 quái / boss HD

sys.path.insert(0, os.path.dirname(HERE))
import skill_icons_fx  # noqa: E402
import talent_icons_fx  # noqa: E402

PX = 4


def _save(img, sub, name):
    d = os.path.join(ASSETS, "hd", sub)
    os.makedirs(d, exist_ok=True)
    img.save(os.path.join(d, name + ".png"), optimize=True)
    return "res://assets/hd/%s/%s.png" % (sub, name)


def main():
    hd = {"sprites": {}, "env": {}, "icons": {}}
    # Không vẽ lại nhân vật người chơi (pc-*) và hình / hiệu ứng kỹ năng: dùng nguyên bộ hình chủ dự án cung cấp.
    # MD-1 (docs/39): toàn bộ quái / boss theo phong cách mới (thay bản G0 wolf.py); linh thú Triệu Hồi Sư chỉ có
    # ảnh duyệt (sprites-review/) cho tới khi chủ dự án đồng ý (Q190)
    hd["sprites"].update(mon_build.build_all(_save))
    env = dict(env_forest.build())
    env.update(env_village.build())  # UI-40b: Làng Thanh Thạch
    env.update(env_regions.build())  # UI-40c: nền + cảnh vật vùng 2–9
    env.update(env_camps.build())  # UI-40c: khu an toàn (nhà, lều, rào, đồ vật) theo vùng
    for k, (img, origin) in env.items():
        hd["env"][k] = {"path": _save(img, "env", k), "w": img.size[0], "h": img.size[1], "origin": origin, "px": PX}
    for k, img in icons_hd.build().items():
        hd["icons"][k] = _save(img, "icons", k)
    # IC-1 (docs/37): 51 icon kỹ năng vẽ lại (19 icon vẽ tay của chủ dự án giữ nguyên, không có trong bộ này)
    for k, img in skill_icons_fx.build().items():
        hd["icons"]["skill-" + k] = _save(img, "icons", "skill-" + k)
    # IC-2 (docs/37 §7): 18 icon trang bị còn thiếu + 20 icon Thiên phú
    for k, img in items_hd_more.build().items():
        hd["icons"][k] = _save(img, "icons", k)
    for k, img in talent_icons_fx.build().items():
        hd["icons"][k] = _save(img, "icons", k)
    # IC-2 §8: 14 icon tài nguyên + 24 icon chỉ số (chân dung portrait-* là hình chủ dự án, giữ nguyên)
    for k, img in res_stat_hd.build().items():
        hd["icons"][k] = _save(img, "icons", k)
    action_icons.save_all()  # UI-41d: icon riêng cụm nút góc phải (cụm nút nạp thẳng, không qua lớp phủ manifest)
    with open(MANIFEST, encoding="utf-8") as f:
        m = json.load(f)
    m["hd"] = hd
    with open(MANIFEST, "w", encoding="utf-8", newline=chr(10)) as f:
        json.dump(m, f, ensure_ascii=False, indent=1)
    print("HD: %d sprite, %d env, %d icon" % (len(hd["sprites"]), len(hd["env"]), len(hd["icons"])))


if __name__ == "__main__":
    main()
