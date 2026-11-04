"""AR-45: dải hành động từ master sheet người dùng cung cấp.

Không tái diễn giải kỹ năng thành icon hình học: giữ nguyên pose nhân vật, nhịp
hành động và VFX của artwork gốc cho 12 dải đã có minh hoạ. Bộ kết quả có 39
kỹ năng chủ động runtime, cộng Hỏa Cầu là đòn đánh thường của Pháp Sư.

    python tools/art/class_skill_actions.py
"""
import os
import sys
from functools import lru_cache

import numpy as np
from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.join(HERE, "src", "class-sheet.png")

COLS = {
    "kiem-khach": (8, 306),
    "tho-san": (314, 612),
    "phap-su": (620, 916),
    "ho-ve": (924, 1222),
    "trieu-hoi-su": (1228, 1528),
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
    "ho-ve": ["khienthep", "khieukhich", "chandia", "thanhbatdiet"],
    "trieu-hoi-su": ["soibong", "tieuquy", "lienket", "quandoan"],
}
ALL_SKILLS = {
    "kiem-khach": ["spin", "dash", "wave", "kiemy", "lientram", "hongkiem", "kiemvu", "phikiem", "vankiem", "thanhkiem", "kiemvuc", "huyetbao", "huyetanh", "nhatkiem"],
    "tho-san": ["rain", "pierce", "lanban", "eagle", "tennay", "trap", "lienxa", "tendoc", "thientien", "phakhong", "tamlien", "baimin", "luoibay", "tinhvu"],
    "phap-su": ["chain", "banglao", "meteor", "barrier", "hoatuong", "nova", "muabang", "causam", "thienhoa", "thienloi", "bangphong", "trieuhoi", "khidoc", "nguhanh"],
    "ho-ve": ["khienchan", "khieukhich", "laokhien", "khienthep", "chandia", "phanthuan", "phanquyet", "xungphong", "thanhbatdiet", "thanhquang", "thanhvuc", "thietchuy", "thanhdong", "thienthuan"],
    "trieu-hoi-su": ["soibong", "linhtien", "tieuquy", "lienket", "thachquy", "hoadieu", "linhtran", "linhung", "quandoan", "aulong", "longhong", "loidodang", "phongdodang", "kylan"],
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


@lru_cache(maxsize=None)
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


SLASH = {"spin", "dash", "lientram", "hongkiem", "kiemvu", "phikiem", "thanhkiem", "kiemvuc", "huyetbao", "huyetanh", "nhatkiem",
         "khienchan", "laokhien", "phanthuan", "phanquyet", "xungphong", "thanhquang", "thietchuy", "thanhdong"}
ARROW = {"rain", "pierce", "lanban", "tennay", "lienxa", "tendoc", "thientien", "phakhong", "tamlien", "tinhvu"}
ELEMENT = {"chain", "banglao", "meteor", "hoatuong", "nova", "muabang", "causam", "thienhoa", "thienloi", "bangphong", "khidoc", "nguhanh", "hoadieu"}
AURA = {"kiemy", "eagle", "barrier", "khienthep", "thanhbatdiet", "thanhvuc", "lienket", "linhtran", "phongdodang"}
SUMMON = {"trieuhoi", "soibong", "tieuquy", "thachquy", "linhung", "quandoan", "aulong", "kylan", "loidodang"}
SUMMON_SPRITES = {
    "trieuhoi": "linh-hon", "soibong": "soi-bong", "tieuquy": "tieu-quy", "thachquy": "thach-quy",
    "linhung": "linh-ung", "quandoan": "linh-hon", "aulong": "au-long", "kylan": "ky-lan",
}
NON_TARGET = AURA | SUMMON
SHEET_FX = {
    "spin": ("fx-sheet-tramphong",), "dash": ("fx-sheet-tramphong",), "lientram": ("fx-sheet-tramphong", "fx-sheet-tramphong"),
    "hongkiem": ("fx-sheet-kiemy",), "kiemvu": ("fx-sheet-vankiem", "fx-sheet-tramphong"),
    "phikiem": ("fx-sheet-tramphong", "fx-sheet-tramphong", "fx-sheet-tramphong"), "thanhkiem": ("fx-sheet-tramphong",),
    "kiemvuc": ("fx-sheet-vankiem", "fx-sheet-vankiem"), "huyetbao": ("fx-sheet-kiemy",), "huyetanh": ("fx-sheet-tramphong", "fx-sheet-tramphong"),
    "nhatkiem": ("fx-sheet-tramphong", "fx-sheet-kiemy"), "rain": ("fx-sheet-thientien", "fx-sheet-thientien"),
    "pierce": ("fx-sheet-xuyentam",), "lanban": ("fx-sheet-xuyentam", "fx-sheet-xuyentam", "fx-sheet-xuyentam"),
    "tennay": ("fx-sheet-xuyentam", "fx-sheet-xuyentam"), "lienxa": ("fx-sheet-xuyentam", "fx-sheet-xuyentam"),
    "tendoc": ("fx-sheet-xuyentam",), "thientien": ("fx-sheet-thientien", "fx-sheet-thientien", "fx-sheet-thientien"),
    "phakhong": ("fx-sheet-xuyentam",), "tamlien": ("fx-sheet-xuyentam", "fx-sheet-xuyentam", "fx-sheet-xuyentam"),
    "tinhvu": ("fx-sheet-thientien", "fx-sheet-thientien", "fx-sheet-thientien"), "chain": ("fx-sheet-kiemy",),
    "banglao": ("fx-sheet-banglao",), "meteor": ("fx-sheet-meteor-fire",), "hoatuong": ("fx-sheet-meteor-fire", "fx-sheet-meteor-fire"),
    "nova": ("fx-sheet-banglao", "fx-sheet-banglao"), "muabang": ("fx-sheet-banglao", "fx-sheet-banglao"),
    "causam": ("fx-sheet-kiemy",), "thienhoa": ("fx-sheet-meteor-fire", "fx-sheet-meteor-ice"), "thienloi": ("fx-sheet-kiemy",),
    "bangphong": ("fx-sheet-meteor-ice", "fx-sheet-banglao"), "trieuhoi": ("fx-sheet-kiemy",), "khidoc": ("fx-sheet-kiemy",),
    "nguhanh": ("fx-sheet-kiemy", "fx-sheet-meteor-fire", "fx-sheet-meteor-ice"), "khienchan": ("fx-sheet-khienthep",),
    "laokhien": ("fx-sheet-khienthep",), "phanthuan": ("fx-sheet-khienthep",), "phanquyet": ("fx-sheet-khienthep", "fx-sheet-kiemy"),
    "xungphong": ("fx-sheet-khienthep",), "thanhquang": ("fx-sheet-khienthep", "fx-sheet-tramphong"), "thanhvuc": ("fx-sheet-khienthep",),
    "thietchuy": ("fx-sheet-khienthep", "fx-sheet-kiemy"), "thanhdong": ("fx-sheet-khienthep", "fx-sheet-kiemy"),
    "linhtien": ("fx-sheet-kiemy",), "thachquy": ("fx-sheet-kiemy",), "hoadieu": ("fx-sheet-meteor-fire",),
    "linhtran": ("fx-sheet-kiemy",), "linhung": ("fx-sheet-kiemy",), "aulong": ("fx-sheet-meteor-fire",),
    "longhong": ("fx-sheet-kiemy",), "loidodang": ("fx-sheet-kiemy",), "phongdodang": ("fx-sheet-kiemy",),
    "kylan": ("fx-sheet-kiemy", "fx-sheet-meteor-fire"),
}


def _palette(skill_id):
    if skill_id in {"huyetbao", "huyetanh"}:
        return (255, 82, 102, 255), (129, 22, 38, 255), (255, 202, 210, 255)
    if skill_id in {"banglao", "nova", "muabang", "bangphong"}:
        return (104, 210, 255, 255), (36, 92, 178, 255), (222, 249, 255, 255)
    if skill_id in {"chain", "causam", "thienloi", "loidodang"}:
        return (245, 220, 116, 255), (116, 72, 218, 255), (255, 250, 198, 255)
    if skill_id in {"meteor", "hoatuong", "thienhoa", "hoadieu", "aulong"}:
        return (255, 128, 48, 255), (170, 42, 18, 255), (255, 230, 128, 255)
    if skill_id in {"khienthep", "thanhbatdiet", "thanhquang", "thanhvuc", "thienthuan"}:
        return (255, 215, 104, 255), (145, 86, 28, 255), (255, 247, 196, 255)
    if skill_id in SUMMON or skill_id in {"linhtien", "lienket"}:
        return (140, 230, 244, 255), (68, 74, 160, 255), (235, 255, 255, 255)
    if skill_id in ARROW:
        return (202, 232, 255, 255), (82, 120, 170, 255), (255, 250, 200, 255)
    return (255, 105, 112, 255), (126, 35, 54, 255), (255, 226, 218, 255)


def _pixel_glow(draw, center, radius, color, alpha):
    x, y = center
    for r in range(radius, 1, -2):
        a = max(8, round(alpha * (1.0 - r / (radius + 2)) ** 1.6))
        draw.ellipse((x - r, y - r, x + r, y + r), fill=(color[0], color[1], color[2], a))


@lru_cache(maxsize=None)
def _sheet_effect(effect_id):
    from class_sheet import fx
    return fx()[effect_id][0]


def _sheet_effect_scene(skill_id, phase):
    ids = SHEET_FX.get(skill_id, ())
    scene = Image.new("RGBA", (48, 48), (0, 0, 0, 0))
    if not ids:
        return scene
    for index, effect_id in enumerate(ids):
        source = _sheet_effect(effect_id)
        scale = (0.46, 0.68, 0.92)[phase] * (0.78 if len(ids) > 1 else 1.0)
        size = (max(1, round(source.width * scale)), max(1, round(source.height * scale)))
        piece = source.resize(size, Image.Resampling.NEAREST)
        turn = (-18, 0, 18)[phase] + (index - (len(ids) - 1) / 2.0) * 28
        piece = piece.rotate(turn, resample=Image.Resampling.NEAREST, expand=True)
        x = 26 + phase * 4 + (index - (len(ids) - 1) / 2.0) * 10 - piece.width / 2.0
        y = 22 + (index % 2) * 5 - piece.height / 2.0
        scene.alpha_composite(piece, (round(x), round(y)))
    return scene


@lru_cache(maxsize=None)
def _scene_ground(cls):
    """Nền tile ngữ cảnh, tối vừa đủ để nhân vật và FX luôn là chủ thể."""
    from env import tile
    from pixel import R
    palette = {
        "kiem-khach": R["grass"], "tho-san": R["leaf"], "phap-su": R["void"],
        "ho-ve": R["stone"], "trieu-hoi-su": R["purple"],
    }[cls]
    base = tile(palette, 730 + len(cls) * 17, tufts=cls in {"kiem-khach", "tho-san"}).to_image()
    ground = Image.new("RGBA", (48, 48), (0, 0, 0, 255))
    for y in range(0, 48, 32):
        for x in range(0, 48, 32):
            ground.alpha_composite(base, (x, y))
    dark = Image.new("RGBA", ground.size, (7, 9, 17, 132))
    ground.alpha_composite(dark)
    return ground


@lru_cache(maxsize=None)
def _summon_sprite(skill_id):
    sprite_id = SUMMON_SPRITES.get(skill_id)
    if not sprite_id:
        return None
    from builders import BUILDERS
    from catalog import SPRITES
    from pixel import sheet
    spec = SPRITES[sprite_id]
    rows = BUILDERS[spec["builder"]](spec["spec"])
    image, _meta = sheet(rows)
    frame = rows[0][1][0]
    return image.crop((0, 0, frame.w, frame.h))


@lru_cache(maxsize=None)
def _creature_frame(sprite_id, hurt=False):
    from builders import BUILDERS
    from catalog import SPRITES
    from pixel import sheet
    spec = SPRITES[sprite_id]
    rows = BUILDERS[spec["builder"]](spec["spec"])
    image, _meta = sheet(rows)
    row_index = 3 if hurt else 0
    frame = rows[row_index][1][0]
    y = sum(rows[index][1][0].h for index in range(row_index))
    return image.crop((0, y, frame.w, y + frame.h))


def _target_sprite(cls, skill_id, phase):
    if skill_id in NON_TARGET or phase == 0:
        return None
    enemy = {"kiem-khach": "wolf", "tho-san": "mushroom", "phap-su": "wisp", "ho-ve": "wolf", "trieu-hoi-su": "mushroom"}[cls]
    return _creature_frame(enemy, phase == 2)


@lru_cache(maxsize=None)
def _scene_ground_v2(cls, skill_id):
    """Biomes theo hành vi giúp silhouette/element của từng skill tách khỏi nền."""
    from env import tile
    from pixel import R
    if skill_id in {"meteor", "hoatuong", "thienhoa", "hoadieu", "aulong"}:
        palette = R["fire"]
    elif skill_id in {"banglao", "nova", "muabang", "bangphong"}:
        palette = R["crystal"]
    elif skill_id in SUMMON or skill_id in {"linhtien", "lienket", "linhtran", "phongdodang"}:
        palette = R["purple"]
    elif skill_id in {"khienthep", "thanhbatdiet", "thanhquang", "thanhvuc", "thienthuan"}:
        palette = R["stone"]
    elif skill_id in ARROW:
        palette = R["leaf"]
    else:
        palette = R["grass"] if cls != "phap-su" else R["void"]
    base = tile(palette, 1200 + len(skill_id) * 31, tufts=skill_id in ARROW).to_image()
    ground = Image.new("RGBA", (48, 48), (0, 0, 0, 255))
    for y in range(0, 48, 32):
        for x in range(0, 48, 32):
            ground.alpha_composite(base, (x, y))
    ground.alpha_composite(Image.new("RGBA", ground.size, (5, 7, 13, 118)))
    return ground


def _effect_scene(skill_id, phase):
    image = Image.new("RGBA", (48, 48), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)
    bright, dark, core = _palette(skill_id)
    target_x = (29, 34, 39)[phase]
    target_y = (24, 21, 20)[phase]
    power = (0.35, 0.7, 1.0)[phase]
    _pixel_glow(draw, (target_x, target_y), int(8 + power * 11), bright, int(75 * power))
    sheet_scene = _sheet_effect_scene(skill_id, phase)
    if sheet_scene.getbbox() is not None:
        image.alpha_composite(sheet_scene)
        for dx, dy in ((-8, 8), (9, -5), (11, 6)):
            if phase == 2:
                draw.line((target_x, target_y, target_x + dx, target_y + dy), fill=core, width=1)
        return image
    if skill_id in AURA:
        radius = int(8 + power * 10)
        draw.ellipse((24 - radius, 34 - radius // 2, 24 + radius, 34 + radius // 2), outline=bright, width=2)
        draw.arc((24 - radius - 3, 32 - radius // 2 - 3, 24 + radius + 3, 32 + radius // 2 + 3), 195, 345, fill=core, width=1)
        for dx in (-5, 0, 5):
            draw.line((24 + dx, 29, 24 + dx + 2, 19 - phase * 3), fill=core, width=1)
    elif skill_id in SUMMON:
        radius = int(7 + power * 7)
        draw.ellipse((target_x - radius, 34 - radius // 2, target_x + radius, 34 + radius // 2), outline=bright, width=2)
        for dx in (-6, 0, 6):
            draw.polygon(((target_x + dx - 3, 29), (target_x + dx, 14 - phase * 2), (target_x + dx + 3, 29)), fill=dark)
            draw.ellipse((target_x + dx - 3, 19 - phase, target_x + dx + 3, 29), fill=bright, outline=core)
    elif skill_id in ARROW:
        count = 1 if skill_id in {"pierce", "phakhong"} else 3 if phase < 2 else 5
        for index in range(count):
            y = target_y - (count - 1) * 2 + index * 4
            start = 16 + phase * 2
            end = min(47, target_x + 8 + phase * 4)
            draw.line((start, y + (index % 2), end, y), fill=bright, width=2 if phase == 2 else 1)
            draw.polygon(((end, y), (end - 5, y - 3), (end - 4, y + 3)), fill=core)
        draw.arc((target_x - 8, 25, target_x + 11, 42), 195, 345, fill=dark, width=1)
    elif skill_id in ELEMENT:
        if skill_id in {"chain", "causam", "thienloi", "loidodang"}:
            points = [(18, 12), (target_x - 5, 18), (target_x + 1, 23), (target_x - 3, 31), (target_x + 7, 37)]
            draw.line(points, fill=bright, width=2 if phase > 0 else 1)
            draw.line([(x + 1, y) for x, y in points], fill=core, width=1)
        elif skill_id in {"banglao", "nova", "muabang", "bangphong"}:
            for dx, dy in ((0, -11), (9, -5), (10, 5), (0, 10), (-9, 5), (-9, -5)):
                draw.polygon(((target_x, target_y), (target_x + dx, target_y + dy), (target_x + dx // 2 - dy // 3, target_y + dy // 2 + dx // 3)), fill=bright if phase else dark)
            draw.ellipse((target_x - 4, target_y - 4, target_x + 4, target_y + 4), fill=core)
        else:
            draw.ellipse((target_x - 6 - phase * 3, target_y - 6 - phase * 3, target_x + 6 + phase * 3, target_y + 6 + phase * 3), fill=dark, outline=bright, width=2)
            for dx, dy in ((-12, 8), (9, 10), (12, -6)):
                draw.line((target_x, target_y, target_x + dx, target_y + dy), fill=core, width=1)
    else:
        radius = int(9 + power * 11)
        draw.arc((target_x - radius, target_y - radius, target_x + radius, target_y + radius), 205 - phase * 18, 333 + phase * 16, fill=dark, width=4)
        draw.arc((target_x - radius, target_y - radius, target_x + radius, target_y + radius), 210 - phase * 18, 330 + phase * 16, fill=bright, width=2)
        draw.line((15, 33, target_x + 9, target_y - 11), fill=core, width=1)
        if phase == 2:
            for dx, dy in ((10, -8), (13, 0), (8, 9), (-4, -11)):
                draw.line((target_x, target_y, target_x + dx, target_y + dy), fill=core, width=1)
    return image


def _generated_strip(cls, skill_id):
    """Ba cảnh pixel-art riêng: pose source + VFX theo hành vi của từng kỹ năng."""
    poses = _action_frames(cls)
    strip = Image.new("RGBA", (288, 96), (0, 0, 0, 0))
    for phase in range(3):
        scene = _scene_ground(cls).copy()
        draw = ImageDraw.Draw(scene)
        draw.ellipse((5, 39, 42, 46), fill=(3, 4, 9, 145))
        scene.alpha_composite(_effect_scene(skill_id, phase))
        summon = _summon_sprite(skill_id)
        if summon is not None and phase > 0:
            scale = (0.78, 1.0)[phase - 1]
            pet = summon.resize((max(1, round(summon.width * scale)), max(1, round(summon.height * scale))), Image.Resampling.NEAREST)
            scene.alpha_composite(pet, (34 - pet.width // 2, 41 - pet.height))
        pose = poses[min(phase, len(poses) - 1)]
        pose.thumbnail((28, 34), Image.Resampling.NEAREST)
        px = 15 - phase * 2 if skill_id not in AURA and skill_id not in SUMMON else 10
        scene.alpha_composite(pose, (px, 42 - pose.height))
        if phase < 2:
            draw.line((47, 5, 47, 43), fill=(123, 142, 175, 115), width=1)
        strip.alpha_composite(scene.resize((96, 96), Image.Resampling.NEAREST), (phase * 96, 0))
    return strip


def _generated_strip_v2(cls, skill_id):
    """V2: mỗi pha là một combat scene có biome, mục tiêu và hit reaction thật."""
    poses = _action_frames(cls)
    strip = Image.new("RGBA", (288, 96), (0, 0, 0, 0))
    for phase in range(3):
        scene = _scene_ground_v2(cls, skill_id).copy()
        draw = ImageDraw.Draw(scene)
        draw.ellipse((4, 39, 43, 46), fill=(2, 3, 7, 142))
        target = _target_sprite(cls, skill_id, phase)
        if target is not None:
            scale = 0.84 if phase == 1 else 0.92
            creature = target.resize((max(1, round(target.width * scale)), max(1, round(target.height * scale))), Image.Resampling.NEAREST)
            x = 38 - creature.width // 2 + (3 if phase == 2 else 0)
            scene.alpha_composite(creature, (x, 42 - creature.height))
        scene.alpha_composite(_effect_scene(skill_id, phase))
        if target is not None and phase == 2:
            bright, _dark, core = _palette(skill_id)
            for dx, dy in ((-6, -6), (7, -4), (8, 5), (-5, 7)):
                draw.line((38, 27, 38 + dx, 27 + dy), fill=core, width=1)
            draw.ellipse((33, 22, 43, 32), outline=bright, width=1)
        summon = _summon_sprite(skill_id)
        if summon is not None and phase > 0:
            scale = (0.78, 1.0)[phase - 1]
            pet = summon.resize((max(1, round(summon.width * scale)), max(1, round(summon.height * scale))), Image.Resampling.NEAREST)
            scene.alpha_composite(pet, (34 - pet.width // 2, 41 - pet.height))
        pose = poses[min(phase, len(poses) - 1)]
        pose.thumbnail((28, 34), Image.Resampling.NEAREST)
        px = 15 - phase * 2 if skill_id not in AURA and skill_id not in SUMMON else 10
        scene.alpha_composite(pose, (px, 42 - pose.height))
        if phase < 2:
            draw.line((47, 5, 47, 43), fill=(175, 190, 218, 125), width=1)
        strip.alpha_composite(scene.resize((96, 96), Image.Resampling.NEAREST), (phase * 96, 0))
    return strip


def build_all(variant="v1"):
    out = {}
    for cls, skill_ids in SKILLS.items():
        for row, skill_id in zip(ROWS, skill_ids):
            image = _strip(cls, row)
            out["skill-action-" + skill_id] = (image, [image.width // 2, image.height // 2])
    for cls, skill_ids in ALL_SKILLS.items():
        for skill_id in skill_ids:
            key = "skill-action-" + skill_id
            if key not in out:
                image = _generated_strip_v2(cls, skill_id) if variant == "v2" else _generated_strip(cls, skill_id)
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