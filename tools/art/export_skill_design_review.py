"""Xuất ảnh review kỹ năng vào docs/design/skills, không ghi vào game assets.

    python tools/art/export_skill_design_review.py
"""
import os
import sys

from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
OUT = os.path.join(ROOT, "docs", "design", "skills")

sys.path.insert(0, HERE)
import class_skill_actions  # noqa: E402


CLASS_NAMES = {
    "kiem-khach": "Kiem Khach",
    "tho-san": "Tho San",
    "phap-su": "Phap Su",
    "ho-ve": "Ho Ve",
    "trieu-hoi-su": "Trieu Hoi Su",
}
SKILL_NAMES = {
    "spin": "Xoay Kiem", "dash": "Dot Kich", "wave": "Tram Phong", "kiemy": "Kiem Y",
    "lientram": "Nguyet Anh Lien Tram", "hongkiem": "Hong Kiem", "kiemvu": "Kiem Vu",
    "phikiem": "Phi Kiem", "vankiem": "Van Kiem Quy Tong", "thanhkiem": "Thanh Kiem Tram",
    "kiemvuc": "Kiem Vuc", "huyetbao": "Huyet Bao", "huyetanh": "Huyet Anh", "nhatkiem": "Nhat Kiem Khai Thien",
    "rain": "Vu Tien", "pierce": "Xuyen Tam Tien", "lanban": "Lon Nhao", "eagle": "Ung Nhan",
    "tennay": "Ten Nay", "trap": "Bay Gai", "lienxa": "Lien Xa", "tendoc": "Ten Doc",
    "thientien": "Thien Tien Vu", "phakhong": "Pha Khong Tien", "tamlien": "Tam Lien Than Tien",
    "baimin": "Bai Min", "luoibay": "Luoi Bay", "tinhvu": "Thien Lac Tinh Vu", "chain": "Set Chuoi", "banglao": "Bang Lao",
    "meteor": "Thien Thach", "barrier": "Phap Thuan", "hoatuong": "Hoa Tuong", "nova": "Bang Nguc",
    "muabang": "Mua Bang", "causam": "Cau Sam", "thienhoa": "Thien Tai Nguyen To",
    "thienloi": "Thien Loi", "bangphong": "Bang Phong Thien Ha", "trieuhoi": "Trieu Hoi Xuong",
    "khidoc": "Khi Doc Tu Vong", "nguhanh": "Ngu Hanh Luan Chuyen", "thienthuan": "Thien Thuan Giang The",
    "kylan": "Ky Lan Giang The", "khienthep": "Khien Thep", "khieukhich": "Khieu Khich",
    "chandia": "Chan Dia", "thanhbatdiet": "Thanh Bat Diet", "soibong": "Trieu Hoi Soi Bong",
    "tieuquy": "Trieu Hoi Tieu Quy", "lienket": "Lien Ket Linh Hon", "quandoan": "Quan Doan Linh Hon",
}
SOURCE_ART = {skill_id for skills in class_skill_actions.SKILLS.values() for skill_id in skills if skill_id != "fireball"}
REVIEW_SKILLS = dict(class_skill_actions.ALL_SKILLS)
REVIEW_SKILLS.update({
    "ho-ve": ["khienchan", "khieukhich", "laokhien", "khienthep", "chandia", "phanthuan", "phanquyet", "xungphong", "thanhbatdiet", "thanhquang", "thanhvuc", "thietchuy", "thanhdong", "thienthuan"],
    "trieu-hoi-su": ["soibong", "linhtien", "tieuquy", "lienket", "thachquy", "hoadieu", "linhtran", "linhung", "quandoan", "aulong", "longhong", "loidodang", "phongdodang", "kylan"],
})
EXPORT_SKILLS = dict(class_skill_actions.ALL_SKILLS)
EXPORT_SKILLS.update({
    "ho-ve": class_skill_actions.SKILLS["ho-ve"],
    "trieu-hoi-su": class_skill_actions.SKILLS["trieu-hoi-su"],
})


def _review_card(class_id, skill_id, image):
    """Đặt mỗi strip lên một canvas cùng kích cỡ, có tên và trạng thái review."""
    width, height = 576, 288
    card = Image.new("RGBA", (width, height), (14, 17, 29, 255))
    draw = ImageDraw.Draw(card)
    source = skill_id in SOURCE_ART
    accent = (255, 202, 92, 255) if source else (120, 173, 255, 255)
    status = "SOURCE ART - APPROVED REFERENCE" if source else "CONCEPT REVIEW - NOT FOR GAME"
    draw.rectangle((0, 0, width - 1, height - 1), outline=accent, width=3)
    draw.rectangle((10, 10, width - 10, 48), fill=(24, 28, 46, 255), outline=(56, 64, 92, 255), width=1)
    draw.text((20, 17), "%s / %02d / %s" % (CLASS_NAMES[class_id], REVIEW_SKILLS[class_id].index(skill_id) + 1, SKILL_NAMES[skill_id]), fill=(245, 245, 250, 255))
    draw.text((20, 34), status, fill=accent)
    scale = min((width - 32) / image.width, (height - 72) / image.height)
    scaled = image.resize((max(1, round(image.width * scale)), max(1, round(image.height * scale))), Image.NEAREST)
    card.alpha_composite(scaled, ((width - scaled.width) // 2, 60 + (height - 60 - scaled.height) // 2))
    return card


def _animation_frames(class_id, skill_id, image):
    """Tạo khung GIF theo nhịp charge → cast → impact từ storyboard/action strip."""
    phase_names = ("CHARGE", "CAST", "IMPACT")
    if skill_id in SOURCE_ART:
        # Artwork gốc đã bố trí tiến trình theo chiều ngang; lấy ba lát tiến trình.
        width = image.width // 3
        source_frames = [image.crop((index * width, 0, image.width if index == 2 else (index + 1) * width, image.height)) for index in range(3)]
    else:
        # Storyboard concept được dựng đúng ba khung 48px cạnh nhau.
        source_frames = [image.crop((index * 48, 0, (index + 1) * 48, image.height)) for index in range(3)]
    frames = []
    for phase, source in zip(phase_names, source_frames):
        card = _review_card(class_id, skill_id, source)
        draw = ImageDraw.Draw(card)
        draw.rectangle((390, 14, 555, 42), fill=(8, 10, 18, 220), outline=(110, 125, 160, 255), width=1)
        draw.text((402, 22), phase, fill=(255, 255, 255, 255))
        frames.append(card.convert("P", palette=Image.Palette.ADAPTIVE, colors=128))
    return frames


def build():
    assets = class_skill_actions.build_all()
    count = 0
    for class_id, skill_ids in EXPORT_SKILLS.items():
        folder = os.path.join(OUT, class_id)
        os.makedirs(folder, exist_ok=True)
        for index, skill_id in enumerate(skill_ids, 1):
            image, _origin = assets["skill-action-" + skill_id]
            stem = "%02d-%s" % (REVIEW_SKILLS[class_id].index(skill_id) + 1, skill_id)
            legacy_stem = "%02d-%s" % (index, skill_id)
            if legacy_stem != stem:
                for ext in (".png", ".gif"):
                    legacy_path = os.path.join(folder, legacy_stem + ext)
                    if os.path.exists(legacy_path):
                        os.remove(legacy_path)
            _review_card(class_id, skill_id, image).save(os.path.join(folder, stem + ".png"))
            frames = _animation_frames(class_id, skill_id, image)
            frames[0].save(os.path.join(folder, stem + ".gif"), save_all=True, append_images=frames[1:], duration=[500, 300, 650], loop=0, disposal=2)
            count += 1
    return count


if __name__ == "__main__":
    print("ok: %d review images in %s" % (build(), OUT))