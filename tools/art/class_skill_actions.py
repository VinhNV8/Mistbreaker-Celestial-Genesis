"""AR-45: dải hành động từ master sheet người dùng cung cấp.

Không tái diễn giải kỹ năng thành icon hình học: giữ nguyên pose nhân vật, nhịp
hành động và VFX của artwork gốc cho 12 dải đã có minh hoạ. Bộ kết quả có 39
kỹ năng chủ động runtime, cộng Hỏa Cầu là đòn đánh thường của Pháp Sư.

    python tools/art/class_skill_actions.py
"""
import os
import sys

import numpy as np
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.join(HERE, "src", "class-sheet.png")

COLS = {
    "kiem-khach": (8, 306),
    "tho-san": (314, 612),
    "phap-su": (620, 916),
}
ROWS = {
    "skill-1": (378, 447),
    "skill-2": (451, 521),
    "skill-3": (525, 597),
    "ultimate": (602, 708),
}
SKILLS = {
    "kiem-khach": ["wave", "lientram", "kiemy", "vankiem"],
    "tho-san": ["pierce", "rain", "lanban", "thientien"],
    "phap-su": ["fireball", "banglao", "chain", "thienhoa"],
}
ALL_SKILLS = {
    "kiem-khach": ["spin", "dash", "wave", "kiemy", "lientram", "hongkiem", "kiemvu", "phikiem", "vankiem", "thanhkiem", "kiemvuc", "huyetbao", "huyetanh"],
    "tho-san": ["rain", "pierce", "lanban", "eagle", "tennay", "trap", "lienxa", "tendoc", "thientien", "phakhong", "tamlien", "baimin", "luoibay"],
    "phap-su": ["chain", "banglao", "meteor", "barrier", "hoatuong", "nova", "muabang", "causam", "thienhoa", "thienloi", "bangphong", "trieuhoi", "khidoc"],
}


def _strip(cls, row):
    x0, x1 = COLS[cls]
    y0, y1 = ROWS[row]
    raw = np.asarray(Image.open(SRC).convert("RGBA"))[y0:y1, x0:x1].copy()
    rgb = raw[..., :3].astype(np.int16)
    hi = rgb.max(axis=2)
    lo = rgb.min(axis=2)
    # Master sheet uses near-black panel fill. Clear it while retaining coloured
    # pixels and bright cores; this intentionally leaves the artist's 1px
    # silhouette outlines adjacent to the surviving paint.
    alpha = np.where((hi < 48) | ((hi < 70) & ((hi - lo) < 14)), 0, 255).astype(np.uint8)
    # Nhãn "SKILL ..." nằm ở mép trái và dải trên mỗi hàng; không để chữ lẫn vào strip review.
    alpha[:, :100] = 0
    alpha[:26, :] = 0
    raw[..., 3] = alpha
    # Remove the panel separator, then crop to the painted action strip.
    raw[:2, :, 3] = 0
    raw[-2:, :, 3] = 0
    ys, xs = np.nonzero(alpha)
    if len(xs) == 0:
        raise ValueError("No painted pixels found for %s/%s" % (cls, row))
    left, right = max(0, xs.min() - 3), min(raw.shape[1], xs.max() + 4)
    top, bottom = max(0, ys.min() - 3), min(raw.shape[0], ys.max() + 4)
    return Image.fromarray(raw[top:bottom, left:right], "RGBA")


def _action_frames(cls):
    """Lấy ba pose attack thật đã cắt từ master sheet của lớp tương ứng."""
    from class_sheet import build_class
    sheet, meta, _cuts = build_class(cls)
    anim = meta["anims"]["attack"]
    fw, fh = meta["w"], meta["h"]
    y = anim["row"] * fh
    frames = []
    for index in range(anim["frames"]):
        frames.append(sheet.crop((index * fw, y, (index + 1) * fw, y + fh)))
    return frames


def _generated_strip(cls, skill_id):
    """Storyboard 3 nhịp: pose gốc, VFX tăng lực, pose + impact cuối."""
    from skill_vfx import build_all as build_vfx
    frames = _action_frames(cls)
    vfx, _origin = build_vfx()["vfx-" + skill_id]
    vfx = vfx.to_image()
    panel = Image.new("RGBA", (144, 64), (0, 0, 0, 0))
    # Ba khung có nền mờ để đọc được silhouette, nhưng không đóng khung UI trong asset runtime.
    bg = Image.new("RGBA", panel.size, (16, 18, 30, 180))
    panel.alpha_composite(bg)
    for index in range(3):
        x = index * 48
        pose = frames[min(index, len(frames) - 1)].resize((frames[min(index, len(frames) - 1)].width * 2, frames[min(index, len(frames) - 1)].height * 2), Image.NEAREST)
        effect_scale = (1, 2, 3)[index]
        effect = vfx.resize((32 * effect_scale, 32 * effect_scale), Image.NEAREST)
        ex = x + 24 - effect.width // 2 + (3 if index == 0 else 8)
        ey = 31 - effect.height // 2
        if index:
            panel.alpha_composite(effect, (ex, ey))
        px = x + 19 - pose.width // 2
        py = 57 - pose.height
        panel.alpha_composite(pose, (px, py))
        if index < 2:
            from PIL import ImageDraw
            ImageDraw.Draw(panel).line((x + 47, 7, x + 47, 57), fill=(120, 130, 170, 100), width=1)
    return panel


def build_all():
    out = {}
    for cls, skill_ids in SKILLS.items():
        for row, skill_id in zip(ROWS, skill_ids):
            image = _strip(cls, row)
            out["skill-action-" + skill_id] = (image, [image.width // 2, image.height // 2])
    for cls, skill_ids in ALL_SKILLS.items():
        for skill_id in skill_ids:
            key = "skill-action-" + skill_id
            if key not in out:
                image = _generated_strip(cls, skill_id)
                out[key] = (image, [image.width // 2, image.height // 2])
    return out


def register_env(out):
    out.update(build_all())


def main():
    sys.path.insert(0, HERE)
    from build_all import contact
    contact("class-skill-actions", [(skill_id, image) for skill_id, (image, _origin) in build_all().items()], scale=3, cols=1)
    print("ok: %d artist action strips" % len(build_all()))


if __name__ == "__main__":
    main()