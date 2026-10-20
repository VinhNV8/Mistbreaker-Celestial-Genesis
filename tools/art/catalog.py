"""Danh mục mọi hình của game. Thêm nhân vật/quái mới: thêm 1 dòng vào SPRITES.

Khoá (id) phải khớp id trong dữ liệu game:
- quái: khoá trong godot/scripts/data/monsters.gd DEFS
- nhân vật: "hero-<lớp>"
"""

# fps theo hoạt ảnh (dùng chung); có thể ghi đè trong từng sprite bằng "fps"
FPS = {"idle": 3, "run": 9, "attack": 10, "hurt": 8, "death": 6}
LOOP = {"idle": True, "run": True, "attack": False, "hurt": False, "death": False}

# C1-02: ngoại hình tuỳ chọn. Thân (không tóc) theo lớp × giới tính × màu da; tóc là lớp riêng
# theo lớp × kiểu tóc, vẽ xám để game tô màu. Id: hero-<lớp>-<nam|nu>-<da 0..2>, hair-<lớp>-<kiểu>.
SKINS = ["skin_light", "skin", "skin_dark"]
CLASS_LOOK = {
    "kiem-khach": {"cloth": "cloth_blue", "pants": "leather", "cape": "cloth_red", "weapon": "sword"},
    "tho-san": {"cloth": "cloth_green", "pants": "leather", "weapon": "bow", "trim": "leather", "collar": "leaf"},
    # SN-06: Pháp Sư — áo choàng tím dài, cổ vàng, trượng ngọc tím
    "phap-su": {"cloth": "purple", "pants": "leather", "weapon": "staff", "trim": "gold", "robe": True, "orb": "crystal"},
}
HAIR_STYLES = ["ngan", "dai", "bui", "duoi"]


def _custom_sprites():
    out = {}
    for cid, look in CLASS_LOOK.items():
        for g in ("nam", "nu"):
            for i, sk in enumerate(SKINS):
                spec = dict(look, gender=g, skin=sk, layer="base")
                out["hero-%s-%s-%d" % (cid, g, i)] = {"builder": "humanoid", "name": "%s %s da %d" % (cid, g, i), "spec": spec}
        for st in HAIR_STYLES:
            spec = dict(look, hair_style=st, layer="hair")
            out["hair-%s-%s" % (cid, st)] = {"builder": "humanoid", "name": "tóc %s %s" % (cid, st), "spec": spec}
    return out


SPRITES = {
    # ------------------------------------------------ nhân vật
    "hero-kiem-khach": {"builder": "humanoid", "name": "Kiếm Khách",
                        "spec": {"hair": "hair_dark", "cloth": "cloth_blue", "pants": "leather", "cape": "cloth_red", "weapon": "sword"}},
    "hero-phap-su": {"builder": "humanoid", "name": "Pháp Sư",
                     "spec": {"hair": "hair_dark", "cloth": "purple", "pants": "leather", "weapon": "staff", "trim": "gold",
                              "robe": True, "orb": "crystal"}},
    "hero-tho-san": {"builder": "humanoid", "name": "Thợ Săn",
                     "spec": {"hair": "hair_brown", "cloth": "cloth_green", "pants": "leather", "weapon": "bow", "hood": True, "trim": "leather"}},
    # ------------------------------------------------ quái vùng 1 (06-ban-do-quai-boss.md)
    "wolf": {"builder": "quadruped", "name": "Sói Sương", "spec": {"fur": "fur_grey", "eye": "#ffd23c"}},
    "mushroom": {"builder": "mushroom", "name": "Nấm Độc", "spec": {}},
    "wisp": {"builder": "wisp", "name": "Tinh Linh Sương", "spec": {}},
    "moc-tinh": {"builder": "treant", "name": "Mộc Tinh", "spec": {}},
    # Nấm Con (M3, CB-12): do Nấm Mẹ đẻ ra, hiển thị nhỏ hơn (size_mul) — mũ hồng sáng, bào tử cam
    "nam-con": {"builder": "mushroom", "name": "Nấm Con", "size_mul": 0.6,
                "spec": {"cap": "fire", "spots": "#fff2c8", "spore": "#ff9a3c"}},
    "boss": {"builder": "quadruped", "name": "Sói Chúa Hư Vô",
             "spec": {"size": 48, "fur": "fur_void", "mane": "void", "eye": "#ff3b4e", "aura": "#9b6ee0"}},
}
SPRITES.update(_custom_sprites())
# C1-23: boss hiếm Lão Thụ Sương Mù (cây cổ thụ, lá tím sương) và Gốc Rễ — dáng treant, phóng to bằng size_mul
SPRITES["lao-thu"] = {"builder": "treant", "name": "Lão Thụ Sương Mù", "size_mul": 2.2,
                      "spec": {"bark": "bark", "leaf": "purple", "eye": "#ff5470"}}
SPRITES["goc-re"] = {"builder": "treant", "name": "Gốc Rễ", "size_mul": 0.8,
                     "spec": {"bark": "wood", "leaf": "leaf", "eye": "#c878ff"}}
# M4.2: quái vùng 2 Đồng Bằng Gió Hú (06 vùng 2) — hệ Kim: trắng bạc, thép
SPRITES["ung-gio"] = {"builder": "bird", "name": "Ưng Gió", "spec": {"body": "white", "wing": "steel", "eye": "#ff5470"}}
SPRITES["linh-danh-thue"] = {"builder": "humanoid", "name": "Lính Đánh Thuê Hư Vô",
                             "spec": {"cloth": "steel", "pants": "leather", "hair": "hair_dark", "hood": True, "trim": "void",
                                      "weapon": "sword", "cape": "void"}}
SPRITES["doi-truong"] = {"builder": "humanoid", "name": "Đội Trưởng Đánh Thuê", "size_mul": 1.25,
                         "spec": {"cloth": "steel", "pants": "cloth_red", "hood": True, "trim": "gold", "weapon": "sword", "cape": "cloth_red"}}
SPRITES["cung-thu"] = {"builder": "humanoid", "name": "Cung Thủ Thảo Nguyên",
                       "spec": {"cloth": "leaf", "pants": "leather", "hair": "hair_brown", "hair_style": "duoi", "trim": "leather",
                                "weapon": "bow", "collar": "dirt"}}
SPRITES["loc-xoay"] = {"builder": "wisp", "name": "Lốc Xoáy Con", "spec": {"body": "white", "glow": "#e8e2c8"}}
SPRITES["phu-thuy-gio"] = {"builder": "humanoid", "name": "Phù Thuỷ Gió", "size_mul": 1.15,
                           "spec": {"cloth": "purple", "pants": "purple", "hood": True, "trim": "white", "weapon": "none"}}
# Boss chương 2: Tướng Gián Điệp Huyền Ảnh — bản thật có bóng, bản sao (huyen-anh-ao) không có bóng (kịch bản)
SPRITES["huyen-anh"] = {"builder": "humanoid", "name": "Tướng Gián Điệp Huyền Ảnh", "size_mul": 1.5,
                        "spec": {"cloth": "void", "pants": "hair_dark", "hood": True, "trim": "blood", "weapon": "sword", "cape": "purple"}}
SPRITES["huyen-anh-ao"] = {"builder": "humanoid", "name": "Bản sao Huyền Ảnh", "size_mul": 1.5,
                           "spec": {"cloth": "void", "pants": "hair_dark", "hood": True, "trim": "blood", "weapon": "sword", "cape": "purple",
                                    "no_shadow": True}}
# M4.3: NPC Thành Biên Đài
SPRITES["npc-lac-phong"] = {"builder": "humanoid", "name": "Đội trưởng Lạc Phong",
                            "spec": {"cloth": "cloth_blue", "pants": "steel", "hair": "hair_brown", "hair_style": "bui", "trim": "gold", "weapon": "sword", "cape": "cloth_blue"}}
SPRITES["npc-thiet-nguu"] = {"builder": "humanoid", "name": "Thợ rèn Thiết Ngưu",
                             "spec": {"cloth": "leather", "pants": "bark", "skin": "skin_dark", "hair": "hair_dark", "weapon": "none"}}
SPRITES["npc-mac-tam"] = {"builder": "humanoid", "name": "Thương nhân Mạc Tam",
                          "spec": {"cloth": "gold", "pants": "cloth_red", "hood": True, "trim": "purple", "weapon": "none", "skin": "skin_light"}}
# C1-11: NPC làng Thanh Thạch (hộp thoại + đứng trong làng)
SPRITES["npc-elder"] = {"builder": "humanoid", "name": "Trưởng làng Thạch Lão",
                        "spec": {"skin": "skin", "hair": "white", "hair_style": "bui", "cloth": "wood", "pants": "leather",
                                 "trim": "gold", "weapon": "none", "gender": "nam"}}
SPRITES["npc-merchant"] = {"builder": "humanoid", "name": "Thương nhân lữ hành",
                           "spec": {"skin": "skin_light", "cloth": "gold", "pants": "cloth_red", "trim": "cloth_red",
                                    "weapon": "none", "hood": True, "gender": "nam"}}
