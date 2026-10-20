"""Danh mục mọi hình của game. Thêm nhân vật/quái mới: thêm 1 dòng vào SPRITES.

Khoá (id) phải khớp id trong dữ liệu game:
- quái: khoá trong godot/scripts/data/monsters.gd DEFS
- nhân vật: "hero-<lớp>"
"""

# fps theo hoạt ảnh (dùng chung); có thể ghi đè trong từng sprite bằng "fps"
FPS = {"idle": 3, "run": 9, "attack": 10, "hurt": 8, "death": 6}
LOOP = {"idle": True, "run": True, "attack": False, "hurt": False, "death": False}

SPRITES = {
    # ------------------------------------------------ nhân vật
    "hero-kiem-khach": {"builder": "humanoid", "name": "Kiếm Khách",
                        "spec": {"hair": "hair_dark", "cloth": "cloth_blue", "pants": "leather", "cape": "cloth_red", "weapon": "sword"}},
    "hero-tho-san": {"builder": "humanoid", "name": "Thợ Săn",
                     "spec": {"hair": "hair_brown", "cloth": "cloth_green", "pants": "leather", "weapon": "bow", "hood": True, "trim": "leather"}},
    # ------------------------------------------------ quái vùng 1 (06-ban-do-quai-boss.md)
    "wolf": {"builder": "quadruped", "name": "Sói Sương", "spec": {"fur": "fur_grey", "eye": "#ffd23c"}},
    "mushroom": {"builder": "mushroom", "name": "Nấm Độc", "spec": {}},
    "wisp": {"builder": "wisp", "name": "Tinh Linh Sương", "spec": {}},
    "moc-tinh": {"builder": "treant", "name": "Mộc Tinh", "spec": {}},
    "boss": {"builder": "quadruped", "name": "Sói Chúa Hư Vô",
             "spec": {"size": 48, "fur": "fur_void", "mane": "void", "eye": "#ff3b4e", "aura": "#9b6ee0"}},
}
