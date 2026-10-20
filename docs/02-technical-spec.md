# Đặc tả kỹ thuật

| | |
| --- | --- |
| Dự án | Thiên Phú Khai Giới |
| Engine | Godot 4.7.2-stable, GDScript, renderer GL Compatibility |
| Mã nguồn | [godot/](../godot/) — khoảng 7.400 dòng GDScript |
| Yêu cầu | [01-requirement-spec.md](01-requirement-spec.md) (Chương 1, phần nền), [03-mvp-spec.md](03-mvp-spec.md) (MVP) |
| Cập nhật | 20/10/2026 |

## 1. Môi trường và cài đặt

### 1.1. Godot đã cài trên máy này

| Hạng mục | Giá trị |
| --- | --- |
| Phiên bản | 4.7.2-stable (official, build `ed1daf0bf`), phát hành 18/08/2026 |
| Nguồn tải | `https://github.com/godotengine/godot/releases/download/4.7.2-stable/Godot_v4.7.2-stable_win64.exe.zip` |
| Kiểm tra toàn vẹn | SHA-512 khớp với `SHA512-SUMS.txt` của bản release |
| Thư mục cài | `C:\Users\ADMIN\AppData\Local\Programs\Godot\` (bản portable, không cần quyền admin) |
| File chạy | `Godot_v4.7.2-stable_win64.exe` (có giao diện), `Godot_v4.7.2-stable_win64_console.exe` (in log ra terminal) |
| Lối tắt | Start Menu và Desktop: "Godot 4.7.2" |

Cài trên máy khác: tải đúng file zip trên, giải nén ở đâu cũng được. Không cần .NET vì project dùng GDScript.

### 1.2. Mở project (import vào editor)

1. Mở Godot → **Import** → chọn `D:\Projects\AI Project\Game\godot\project.godot`.
2. Lần đầu Godot tự sinh thư mục `.godot/` (cache, đã nằm trong `.gitignore`).
3. Bấm **F5** để chạy.

Chạy từ dòng lệnh, không mở editor:

```bash
"C:/Users/ADMIN/AppData/Local/Programs/Godot/Godot_v4.7.2-stable_win64_console.exe" --path "D:/Projects/AI Project/Game/godot"
```

Nếu import lỗi hoặc cache hỏng: xoá `godot/.godot/` rồi chạy `--headless --path godot --import`.

### 1.3. Cấu hình project (`project.godot`)

| Thiết lập | Giá trị | Lý do |
| --- | --- | --- |
| Cửa sổ gốc | 1366 × 768 | Độ phân giải laptop phổ biến |
| Stretch | `canvas_items`, aspect `expand` | UI co giãn theo cửa sổ, màn rộng thấy được nhiều bản đồ hơn |
| Renderer | `gl_compatibility` (cả desktop và mobile) | Chạy được máy yếu, xuất web/mobile sau này |
| Scene chính | `res://scenes/main.tscn` | Chỉ có 1 node `Main`; mọi thứ khác dựng bằng code |
| Lọc texture mặc định | Nearest (`textures/canvas_textures/default_texture_filter=0`) | Pixel art không bị nhoè khi phóng ×2 (G1) |

## 2. Kiến trúc

### 2.1. Phân lớp

```
data/   →  core/   →  view/ + ui/  →  main.gd
dữ liệu    logic       hiển thị        điều phối
```

| Lớp | Thư mục | Quy tắc |
| --- | --- | --- |
| Dữ liệu thiết kế | `scripts/data/` | Chỉ có hằng số (Thiên phú, quái). Designer sửa ở đây |
| Logic | `scripts/core/` | `extends RefCounted`, **không dùng Node, không vẽ, không đọc Input**. Test được ở chế độ headless |
| Hiển thị | `scripts/view/` | Chỉ đọc trạng thái `GameWorld` rồi vẽ, không thay đổi trạng thái |
| Giao diện | `scripts/ui/` | Dựng Control bằng code; gọi phương thức công khai của `GameWorld` khi người chơi bấm nút |
| Điều phối | `scripts/main.gd` | Dựng cây node, đọc Input, chạy vòng lặp, chuyển màn hình, lưu game |

### 2.2. Cây node lúc chạy

```
Main (Node, main.gd)
├── WorldView (Node2D, world_view.gd)     vẽ thế giới bằng _draw()
│   └── Camera2D                          bám theo người chơi, giới hạn trong 2600 × 1600
├── CanvasLayer (layer 1)                 hiệu ứng toàn màn hình
│   ├── TextureRect                       vignette sương mù (GradientTexture2D radial)
│   └── ColorRect                         màu xanh khi Thời Gian Ngưng Đọng
└── CanvasLayer (layer 2)
    └── Control (theme chung)
        ├── màn hình hiện tại             tiêu đề / Lễ Thức Tỉnh
        ├── Hud
        ├── StatsPanel, MapPanel,         bảng phủ, tạm dừng game khi mở
        │   InventoryPanel, TalentPanel
        └── màn hình chiến thắng
```

### 2.3. Danh mục file

| File | Vai trò |
| --- | --- |
| `scripts/data/talents.gd` | 20 Thiên phú, kỹ năng L, tỉ lệ theo hạng, hiệu ứng phụ theo nhóm, chi phí luyện cấp (M2) |
| `scripts/data/monsters.gd` | 6 loại quái vùng 1 + boss: loại (arch), tốc, tầm, đòn đánh, hệ ngũ hành, bảng Đạo Tặc cướp, tinh anh (M3). **Không** chứa HP/Tấn công/Phòng thủ — tính bằng `Formulas.mob_stats()` |
| `scripts/core/gift_code.gd` | Kiểm gift code (SHA-256 + Base32 Crockford), mã đã dùng lưu `user://redeemed_codes.cfg` (CR-02) |
| `tools/giftcode.py` (ngoài `godot/`) | Nhà phát hành sinh mã: `python tools/giftcode.py <số lượng> [đợt]` → `tools/giftcode_out/<đợt>.csv` (không commit); `--check <mã>` để thử. Thuật toán phải giống `gift_code.gd` (test GC-T1 kiểm 1 mã do công cụ sinh) |
| `scripts/data/looks.gd` | Ngoại hình: giới tính, 3 da, 4 kiểu tóc, 6 màu tóc; id sprite thân/tóc (C1) |
| `scripts/data/story.gd` | 18 đoạn thoại và chuỗi 11 nhiệm vụ chương 1 (C1) |
| `scripts/data/resources.gd` | Tên, icon, chú thích 8 tài nguyên (C1, Spec_Notes N6) |
| `scripts/data/maps.gd` | Các vùng, map (1-1 Rừng Sương, 1-3 Lõi Sương) — M4.1 |
| `scripts/data/classes.gd` | 2 lớp (Kiếm Khách, Thợ Săn) và 4 kỹ năng mỗi lớp: hồi chiêu, MP, hệ số, icon (M3) |
| `scripts/data/items.gd` | Trang bị: 8 ô, 5 phẩm chất, affix, tỉ lệ cường hoá, bảng rơi đồ, bộ trang bị, đồ Cam (M1) |
| `scripts/core/config.gd` | **Mọi hằng số cân bằng** (Đuốc, điều kiện mở hang, giá xây…) |
| `scripts/core/formulas.gd` | Công thức EXP, sát thương, combo; **chỉ số quái theo tài liệu 06** (`mob_stats`, `boss_hits`, M3) — phải giống hệt `tools/gen_world_doc.py` |
| `scripts/core/stats.gd` | Tính chỉ số phái sinh từ lớp + cấp + điểm (+ điểm Đạo Tặc cướp) + Thiên phú: HP, MP, Tấn công, né tránh… |
| `scripts/core/rng_util.gd` | RNG dạng `Callable`, chọn theo trọng số, xáo trộn |
| `scripts/core/awakening.gd` | Lễ Thức Tỉnh: lượt quay, bảo hiểm hạng B |
| `scripts/core/explore.gd` | Lưới lục giác, sự kiện ô đất, công trình có thời gian xây, sản lượng, hồi Đuốc |
| `scripts/core/profile.gd` | Hồ sơ người chơi + chuyển đổi sang/từ Dictionary |
| `scripts/core/save_system.gd` | Đọc/ghi JSON, thu hoạch offline |
| `scripts/core/items.gd` | Sinh đồ, chỉ số đồ, mặc/tháo, cường hoá, phân rã, Lực chiến (M1) |
| `scripts/core/game_world.gd` | Mô phỏng: di chuyển, combat, AI quái, boss, EXP, rơi đồ, kỹ năng Thiên phú, đồng minh, thảo dược, rương ẩn |
| `scripts/view/world_view.gd` | Vẽ bản đồ, quái, vòng báo hiệu, hiệu ứng chém, chữ bay. Có hình thì vẽ sprite (sắp xếp theo chiều sâu, hoạt ảnh theo trạng thái, xác quái, tia trúng đòn); thiếu hình thì vẽ hình khối tạm |
| `scripts/view/sprite_lib.gd` | Nạp `assets/art_manifest.json`, cắt frame, lật ngang, lát ô bằng đa giác UV, lấy icon (G1) |
| `assets/sprites/`, `assets/icons/`, `assets/env/`, `assets/art_manifest.json` | Hình do `tools/art` sinh ra — **không sửa tay**, sửa code sinh rồi chạy lại |
| `scripts/ui/ui_theme.gd` | Theme, màu, font, hàm dựng Control nhanh |
| `scripts/ui/hud.gd` | HUD khi chơi |
| `scripts/ui/skill_bar.gd` | Thanh kỹ năng 8 ô có khung trang trí, tự vẽ bằng `_draw`: icon cắt tròn, hồi chiêu quét tròn, nhãn phím, tên + dòng phụ; HUD gọi `set_slot(i, {...})` mỗi khung hình (DH-11) |
| `scripts/ui/modal.gd` | Lớp cha của bảng phủ |
| `scripts/ui/stats_panel.gd` | Bảng chỉ số |
| `scripts/ui/map_panel.gd`, `hex_map.gd` | Bản đồ khai phá |
| `scripts/ui/inventory_panel.gd` | Túi đồ: đang mặc, túi 30 ô, chi tiết, so sánh, cường hoá (M1) |
| `scripts/ui/intro_screen.gd` | Cảnh mở đầu 5 trang (C1-10) |
| `scripts/ui/create_screen.gd` | Tạo nhân vật + ô xem trước động (C1-02); lớp `Preview` dùng lại ở túi đồ |
| `scripts/ui/dialog_box.gd` | Hộp thoại có chân dung; chờ khi đang mở bảng (C1-11) |
| `scripts/ui/shop_panel.gd` | Cửa hàng làng, Thương nhân lữ hành, Xưởng Rèn, bán đồ — phím E (C1-30, 32) |
| `scripts/ui/pause_menu.gd` | Menu tạm dừng + Cài đặt (C1-42) |
| `scripts/ui/world_map_panel.gd` | Bản đồ lục địa, đi giữa map — phím N (M4.1) |
| `scripts/core/settings.gd` | Cài đặt âm lượng, toàn màn hình → `user://settings.cfg`; tạo bus Music, SFX (C1-42) |
| `scripts/audio/audio_manager.gd` | Phát hiệu ứng (10 kênh, chống lặp 0,05 giây) và nhạc nền vòng lặp có mờ dần (C1-40, 41) |
| `assets/audio/sfx/*.wav`, `assets/audio/music/*.wav` | Âm thanh do `tools/audio/gen_audio.py` sinh — không sửa tay |
| `scripts/ui/talent_panel.gd` | Bảng Thiên phú: hiệu ứng, kỹ năng L, hiệu ứng phụ, luyện cấp (M2) |
| `scripts/ui/screens.gd` | Màn hình tiêu đề, Lễ Thức Tỉnh, chiến thắng |
| `scripts/main.gd` | Điểm vào + chế độ smoke test |
| `tests/run_tests.gd` | 76 test logic chạy headless; chạy một phần bằng `-- --only=<chuỗi trong tên test>` |
| `tools/audio/*.py` (ngoài `godot/`) | Sinh âm thanh bằng code (thư viện chuẩn Python): `python tools/audio/gen_audio.py [id …]`; danh sách id ở `tools/audio/README.md` |
| `godot/export_presets.cfg`, `tools/build_windows.sh` | Preset xuất Windows và script build `build/ThienPhuKhaiGioi.exe` (C1-50) |
| `tools/art/*.py` (ngoài `godot/`) | Bộ sinh hình pixel art (Python 3 + Pillow): `pixel.py` thư viện vẽ, `builders.py` dáng nhân vật/quái, `catalog.py` danh mục sprite, `icons.py`, `env.py`, `build_all.py`. Quy trình ở skill `.claude/skills/game-art/SKILL.md` |
| `tools/gen_world_doc.py` (ngoài `godot/`) | Sinh `docs/06-ban-do-quai-boss.md` từ công thức chỉ số quái; chạy `python tools/gen_world_doc.py docs/06-ban-do-quai-boss.md` (cần Python 3) |

### 2.3.2. Build file chạy Windows (C1-50)

1. Cài export templates Godot 4.7.2 **một lần** (1,28 GB): Godot editor → *Editor → Manage Export Templates → Download and Install*, hoặc giải nén `Godot_v4.7.2-stable_export_templates.tpz` vào `%APPDATA%\Godot\export_templates\4.7.2.stable\`.
2. `bash tools/build_windows.sh` → `build/ThienPhuKhaiGioi.exe` (pck nhúng trong exe; thư mục `build/` không commit).
3. Preset ở `godot/export_presets.cfg` (đã bỏ khỏi `.gitignore`): x86_64, loại `tests/*`, kèm `assets/*.json` (manifest hình đọc bằng `FileAccess`).

### 2.3.1. Quy trình sinh hình (G1)

```bash
pip install pillow                       # 1 lần
python tools/art/build_all.py            # sinh mọi hình + manifest + bảng xem trước tools/art/_preview/
"C:/Users/ADMIN/AppData/Local/Programs/Godot/Godot_v4.7.2-stable_win64_console.exe" --headless --path godot --import
```

- Manifest: `{"scale": 2, "sprites": {id: {path, w, h, origin, anims: {tên: {row, frames, fps, loop}}}}, "icons": {id: path}, "env": {id: {path, w, h, origin}}}`. `origin` là điểm chân (sprite) hoặc tâm (vật rơi), game đặt điểm này vào toạ độ thực thể.
- Sheet: hàng = hoạt ảnh (`idle, run, attack, hurt, death`), cột = frame. Hình quay phải; game lật khi đi trái.
- Id sprite trùng khoá quái trong `monsters.gd`; nhân vật là `hero-<lớp>`; icon là `item-<ô hoặc đồ Cam>`, `res-<tài nguyên>`, `skill-<kỹ năng>`, `talent-<id>`.
- Chưa import cũng chạy được: `sprite_lib.gd` đọc thẳng PNG bằng `Image.load_from_file` (chỉ dùng khi phát triển; bản xuất cần import).

### 2.4. Vòng lặp một khung hình

`main._process(delta)`:

1. Nếu đang mở bảng hoặc màn hình chiến thắng: không cập nhật thế giới (tạm dừng).
2. Đọc input thành Dictionary `{move, aim, attack, skill, talent, dodge}` (hoặc lấy từ bot khi smoke test).
3. `GameWorld.update(min(delta, 0.05), input)` — chặn `delta` để máy giật không làm quái nhảy cóc.
4. Lấy sự kiện bằng `drain_events()` (thông báo, lên cấp, chiếm ô, chết, chiến thắng) → đẩy lên HUD, lưu game.
5. Đặt camera theo người chơi, cập nhật vignette và HUD.
6. Cứ 5 giây lưu game một lần.

`GameWorld` không gọi ngược lên UI; UI chỉ nhận sự kiện qua `drain_events()`. Nhờ vậy test chạy logic mà không cần giao diện.

### 2.5. Máy trạng thái của quái

```
idle ──(người chơi trong 260px, không ở làng/hang)──▶ chase
chase ──(trong tầm đánh)──▶ windup ──(hết thời gian vung)──▶ ra đòn ──▶ recover ──▶ chase
chase ──(xa > 560px hoặc người chơi vào làng/hang)──▶ idle
boss: chase ──(cách > 150px, hết hồi chiêu 5s)──▶ windup "pounce"
boss: thanh Phá Thế = 0 ──▶ stunned (5s) ──▶ chase
```

Giai đoạn `windup` là cửa sổ để người chơi né; `world_view.gd` vẽ vòng đỏ lớn dần theo tiến độ vung đòn.

## 3. Dữ liệu

### 3.1. File save

| Hạng mục | Giá trị |
| --- | --- |
| Đường dẫn Godot | `user://save.json` |
| Trên Windows | `%APPDATA%\Godot\app_userdata\Thiên Phú Khai Giới\save.json` |
| Smoke test | `user://smoke_save.json` (tự xoá sau khi chạy, không đụng save thật) |
| Định dạng | JSON một dòng |
| Phiên bản hiện tại | **6** (M1 trang bị · M2 Thiên phú, công trình · M3 lớp, INT/LUK, điểm cướp · v5 M4.1 nhiều bản đồ · **v6 C1**: tên, ngoại hình, nhiệm vụ/thoại chương 1, lưới 40 ô, boss hiếm, Thương nhân, Vườn). Save v1–v5 được chuyển đổi tự động khi nạp |

```json
{
  "version": 1,
  "talent": "kiem-tam",
  "level": 5, "xp": 120,
  "points": {"str": 12, "agi": 0, "int": 0, "vit": 8, "luk": 0}, "unspent": 0,
  "gold": 46.5, "wood": 120.0,
  "torches": 4, "torch_timer": 37.2,
  "tiles": [{"id": 0, "q": 0, "r": 0, "event": "camp", "status": "owned"}, "…10 ô nữa"],
  "camp_level": 1, "boss_defeated": false,
  "kills": 42, "play_seconds": 1180.0,
  "last_seen": 1792426000.0,
  "inventory": [{"id": 12, "slot": "helm", "rarity": "purple", "level": 5, "plus": 0,
                 "set": "frost_hunter", "unique": "", "affixes": [{"stat": "crit", "value": 0.031}]}],
  "equipment": {"weapon": {"id": 7, "slot": "weapon", "rarity": "orange", "unique": "wolf_fang", "…": "…"}},
  "stones": 19, "next_item_id": 13, "boss_respawn_at": 1780.0,
  "talent_level": 3, "essence": 2, "tinh_kim": 1, "potions": 2, "herbs": 1,
  "pets": [{"kind": "wolf", "level": 4}], "copied_skills": ["pounce"], "element": "kim",
  "buildings": {"lumber_3": 60.0, "temple": 300.0}, "build_clock": 845.2,
  "class_id": "tho-san", "stolen": ["agi", "str", "agi"],
  "name": "Lâm Phong", "look": {"gender": "nu", "skin": 1, "hair_style": "duoi", "hair_color": 2},
  "quest_step": 7, "quest_progress": 1, "seen_dialogs": ["q1", "q2"],
  "rare_boss_at": 1792470000.0, "evo_essence": 0, "herb_timer": 42.0,
  "merchant": {"until": 1792429600.0, "items": [{"id": 31, "slot": "ring", "rarity": "blue", "price": 160, "…": "…"}]}
}
```

- `last_seen`: giây Unix, dùng để tính thu hoạch offline.
- `tiles[].event`: `camp | resource | nest | relic | survivor | wonder`; `tiles[].status`: `fog | revealed | owned`.
- JSON của Godot đọc mọi số thành `float`, nên `Profile.load_dict()` ép lại `int` cho từng trường.
- Đổi cấu trúc save thì **tăng `Profile.VERSION`** và cho `load_dict()` đọc được cả bản cũ: trường mới đọc bằng `d.get(khoá, mặc định)`. Cách làm mẫu: chuyển đổi v1 → v2 ở M1. Save có version lớn hơn bản game hiện tại sẽ bị từ chối.
- `boss_respawn_at` tính theo `play_seconds` (giây đã chơi), không theo giờ thực, nên boss không hồi khi tắt game.
- `buildings[khoá]` là thời điểm xong theo `build_clock`. Khác `play_seconds`, `build_clock` **chạy cả khi offline** (cộng trong `apply_offline`), nên công trình xây xong trong lúc tắt game. Công trình xong khi `build_clock >= buildings[khoá]`.
- Khi chuyển từ v5 (C1): tên `Khai Giới Giả`, ngoại hình mặc định; `quest_step` = 12 nếu đã hạ Sói Chúa, ngược lại 5 (bỏ qua phần hướng dẫn); lưới vùng 1 có 10 ô được thêm 30 ô (`Explore.upgrade_region1`), ô cũ `zone` = 1. `tiles[].zone` = 1 Bìa Rừng · 2 Rừng Sâu · 3 Lõi Sương.
- `rare_boss_at`, `merchant.until` là **giờ Unix** (boss hiếm 2 lần/ngày, thương nhân 1 giờ theo giờ thực) — khác `boss_respawn_at` tính theo giờ chơi.
- Khi chuyển từ v3: `class_id` = `kiem-khach`, `points` thêm `int`, `luk` = 0, `stolen` rỗng. Món đồ có thêm trường `style` (`"bow"` = vũ khí tên Cung), save cũ không có thì là `""`.
- `stolen`: thuộc tính Đạo Tặc cướp được, cũ → mới; tối đa = cấp nhân vật, đầy thì bỏ phần tử đầu. Không bị tẩy điểm.
- Khi chuyển từ v2: Xưởng Gỗ đã chiếm và Thôn đã nâng được đánh dấu xong ngay (`0.0`), để người chơi cũ không bị mất sản lượng.

### 3.2. Toạ độ lục giác

Dạng axial `(q, r)`, lục giác đỉnh nhọn. Khoảng cách: `(|dq| + |dr| + |dq + dr|) / 2`. Trại ở `(0, 0)`; vòng 1 gồm 6 ô; vòng 2 dùng 4 ô `(2,0) (-1,-1) (-2,2) (1,1)`.

### 3.3. Bản đồ thế giới

| Hạng mục | Giá trị |
| --- | --- |
| Kích thước | 2600 × 1600 đơn vị |
| Làng | tâm (230, 800), bán kính 170 |
| Hang boss | tâm (2290, 800), bán kính 270 |
| Tường sương mù | x = 1960 |
| Cấp quái | `1 + ⌊(x − 450) / 260⌋`, giới hạn 1–6 |
| Số quái thường | duy trì 16 con, sinh thêm mỗi 1,2 giây, cách người chơi ≥ 450 |

## 4. Điều khiển (Input Map)

`main.gd` tạo các action lúc khởi động. **Nếu action cùng tên đã có trong Project Settings → Input Map thì dùng bản đó**, nên muốn đổi phím chỉ cần khai báo trong editor.

| Action | Mặc định |
| --- | --- |
| `move_left/right/up/down` | A D W S, phím mũi tên |
| `attack` | J, chuột trái (giữ) |
| `skill` | K, chuột phải (= kỹ năng 1) |
| `skill_1` … `skill_4` | 1 2 3 4 (M3) |
| `interact` | E — cửa hàng khi đứng trong làng (C1) |
| `auto_fight` | Z — bật/tắt Tự đánh (C1) |
| `toggle_world` | N — bản đồ lục địa (M4.1) |
| `talent` | L |
| `dodge` | Space |
| `toggle_stats` | C |
| `toggle_map` | M, Tab |
| `toggle_inventory` | I, B |
| `toggle_talent` | T |
| `potion` | Q |
| `close_panel` | Esc — đóng bảng; không có bảng nào thì mở **menu tạm dừng** (C1) |

Chơi chỉ bằng bàn phím: nếu chuột đứng yên quá 1,5 giây mà người chơi đang di chuyển, hướng chém đi theo hướng di chuyển.

## 5. Kiểm thử

### 5.1. Test logic (headless, khoảng 5 giây)

```bash
"C:/Users/ADMIN/AppData/Local/Programs/Godot/Godot_v4.7.2-stable_win64_console.exe" --headless --path godot --script res://tests/run_tests.gd
```

- In `ok` / `FAIL` cho từng test; thoát mã **1** nếu có test hỏng, dùng được trong CI.
- 16 test phần nền Chương 1: công thức, Lễ Thức Tỉnh, khai phá, offline, lưu/nạp JSON, 4 test mô phỏng thế giới (có bot tự đánh boss để đo độ khó).
- 12 test M1 (`M1-1` … `M1-12`), khớp danh sách ở mục 3.11 của [03-mvp-spec.md](03-mvp-spec.md).
- 10 test M2 (`TL-B` … `TL-H`; `TL-A` thay test tỉ lệ quay cũ), khớp mục 4.9. `TL-B` cho bot đánh boss với từng Thiên phú trong 20 để kiểm nguyên tắc cân bằng F/S.
- 1 test đồ hoạ (`AR-35`): mọi quái có đủ 5 hoạt ảnh và nạp được ảnh; mọi Thiên phú, ô đồ, đồ Cam, kỹ năng có icon.
- 13 test M3 (`CL-T1…T5`, `CB-T1`, `CB-T3…T6`, `TP-T1…T3`), khớp mục 5.10 của 03-mvp-spec. `TL-B` chạy cho **2 lớp × 20 Thiên phú**, bot mặc bộ đồ chuẩn (`_standard_kit`) vì công thức quái giả định người chơi mặc đồ đúng vùng.
- Chạy một phần: `... --script res://tests/run_tests.gd -- --only=TL-B` (TL-B riêng khoảng 13 giây).
- 12 test C1 (`C1-T1…T12`, 08 mục 3.4). Hồ sơ test mặc định đặt `quest_step = 12` (đã qua hướng dẫn) để không sinh quái nhiệm vụ/thoại trong test cũ; test chuỗi nhiệm vụ dùng hồ sơ mới. Test thời gian thực đặt `GameWorld.debug_now`.
- 11 test M4.2–M4.3 (03 mục 6.6, 6.8); TL-B2 đánh Huyền Ảnh 2 lớp × 20 Thiên phú × 2 seed (khoảng 2 phút).
- Kết quả gần nhất: **76/76 qua**. Toàn bộ chạy khoảng 1 phút vì có 2 mô phỏng 15 phút chơi và 20 trận boss.
- **Đọc log, không chỉ dòng tổng kết**: có `SCRIPT ERROR` trong log thì coi như hỏng, kể cả khi test báo `ok` (xem mục 7).

### 5.2. Smoke test (có cửa sổ, khoảng 1–2 phút)

```bash
"C:/Users/ADMIN/AppData/Local/Programs/Godot/Godot_v4.7.2-stable_win64_console.exe" --path godot -- --smoke=<thư mục ảnh>
```

Game tự chạy qua: tiêu đề → quay Thiên phú 2 lần → nhận → bot đánh quái → mở bản đồ, dọn 1 ô → bảng chỉ số → túi đồ (thêm đồ mẫu, mặc và cường hoá Nanh Sói Chúa) → dựng hồ sơ đủ điều kiện → đánh boss (tốc độ ×3) → màn hình chiến thắng. Mỗi bước chụp 1 ảnh PNG (`01-title.png` … `07-victory.png`, có `05b`/`05c` cho túi đồ). Thành công khi in `SMOKE done: boss_defeated=true` và không có dòng `SCRIPT ERROR`.

Smoke test cần GPU và cửa sổ thật, nên không chạy được trên CI headless.

### 5.3. Kiểm tra cú pháp toàn bộ script

```bash
for f in $(find scripts -name "*.gd"); do godot --headless --path godot --check-only --script "res://$f"; done
```

### 5.4. Cách đã dùng để cân bằng độ khó boss

Chạy bot trên nhiều seed, có né và không né, rồi chỉnh HP/ATK boss cho tới khi: bot né đúng lúc thắng sau khoảng 40 giây, còn 10–30% HP; bot không né chết 1–5 lần. Kết quả: HP 3600, ATK 27, Phá Thế 600, vồ mỗi 5 giây (ở `monsters.gd` và `game_world.gd`).

## 6. Quyết định kỹ thuật

| # | Quyết định | Lý do | Hệ quả |
| --- | --- | --- | --- |
| D1 | Chuyển từ prototype web (TypeScript + Vite) sang Godot 4 | Người dùng chọn Godot làm engine chính; tránh làm prototype rồi viết lại | Bản web đã xoá khỏi repo (2026-10-20); xem lại trong lịch sử Git nếu cần |
| D2 | Logic là `RefCounted` thuần, tách khỏi Node | Test headless được, logic không phụ thuộc cách vẽ | Đổi sang sprite/TileMap chỉ phải sửa `view/` |
| D3 | Dùng `preload()` vào hằng số, **không dùng `class_name`** | `class_name` cần editor dựng cache lớp toàn cục; chạy test từ dòng lệnh khi chưa import sẽ lỗi | Mỗi file khai báo `const X = preload(...)` cho script nó cần |
| D4 | RNG truyền vào dạng `Callable` trả `float [0,1)` | Test cố định seed, hoặc truyền `func(): return 0.0` để ép kết quả | Mọi hàm có ngẫu nhiên đều nhận tham số `rng` |
| D5 | Dựng UI bằng code, scene chỉ có 1 node | Nhanh cho prototype, dễ review trong diff | Chưa chỉnh UI kéo thả trong editor được; chuyển sang `.tscn` khi có thiết kế UI thật |
| D6 | Vẽ bằng `_draw()` hình khối placeholder | Chưa chốt art style | Thay bằng sprite khi có art; logic va chạm vẫn là hình tròn |
| D7 | Input Map tạo lúc chạy, nhường Project Settings | Tránh định dạng `InputEvent` dài dòng trong `project.godot` | Đổi phím bằng editor vẫn được |
| D8 | Font hệ thống (`SystemFont`: Be Vietnam Pro → Segoe UI → Noto Sans → Arial) | Đủ dấu tiếng Việt, không phải đóng gói font | Trên máy thiếu cả 4 font, Godot dùng font mặc định; trước khi phát hành nên nhúng 1 file font vào project |
| D9 | Renderer GL Compatibility | Hỗ trợ phần cứng rộng nhất, xuất web được | Không dùng được vài hiệu ứng chỉ có ở Forward+ |
| D10 | Save JSON ở `user://`, có `version` | Dễ đọc khi debug | Người chơi sửa được file save; nếu cần chống gian lận thì chuyển sang tính trên server (như kịch bản đề xuất) |
| D11 | Món đồ là Dictionary thuần, lưu thẳng vào save | Không phải viết bộ chuyển đổi riêng cho từng lớp | `Profile._load_item()` phải ép kiểu từng trường sau khi đọc JSON |
| D12 | Hiệu ứng trang bị gom vào một "bonus" rồi đưa vào `Stats.derive()` | Một chỗ tính chỉ số duy nhất, dễ test | Thêm loại hiệu ứng mới phải thêm vào cả `equipment_bonus()` và `derive()` |
| D13 | Mỗi đợt MVP: spec → code → test → cập nhật spec | Yêu cầu của chủ dự án: bám kịch bản, review được | Spec đợt mới nằm ở [03-mvp-spec.md](03-mvp-spec.md) |
| D14 | Hiệu ứng Thiên phú kiểm tra tại chỗ dùng (`profile.talent == "..."`, `Talents.has_sub(...)`), không làm hệ thống "hiệu ứng" chung | 20 Thiên phú đa số có 1 hiệu ứng ở 1 chỗ; hệ thống chung tốn công hơn lợi ích ở quy mô này | Thêm Thiên phú mới: tìm theo id để thấy mọi chỗ ảnh hưởng. Nếu lên 50+ Thiên phú nên gom thành bảng hiệu ứng |
| D15 | Quái không tấn công đồng minh (Q9) | Tránh phải làm AI chọn mục tiêu cho MVP | Thú cưng bất tử; xem lại sau playtest |
| D17 | Hình pixel art **sinh bằng code** (Python + Pillow), không vẽ tay, không AI tạo ảnh | Miễn phí, chạy lại được, một phong cách, thêm quái chỉ cần khai báo; chưa có hoạ sĩ và ngân sách | Mức chi tiết giới hạn; khi có hoạ sĩ chỉ cần thay PNG cùng kích thước frame và manifest (logic, `sprite_lib.gd` giữ nguyên) |
| D18 | `world_view.gd` vẫn vẽ bằng `_draw()` (draw_texture_rect_region) thay vì tạo node Sprite2D cho từng thực thể | Không phải đồng bộ vòng đời node với danh sách thực thể của GameWorld; giữ dự phòng hình khối tạm | Sắp xếp chiều sâu làm thủ công (sort mỗi frame); nếu lên hàng nghìn thực thể nên chuyển sang node + y_sort |
| D19 | Chỉ số quái **tính lúc sinh quái** từ công thức (`Formulas.mob_stats`) thay vì bảng số trong dữ liệu (M3, Q22) | Một công thức cho 9 vùng, thêm quái chỉ cần khai báo loại (arch); tài liệu 06 sinh từ cùng công thức | Đổi công thức phải sửa **2 chỗ**: `formulas.gd` và `tools/gen_world_doc.py`; test CB-T1 bắt lệch |
| D20 | Kỹ năng lớp khai báo dữ liệu (`classes.gd`), hiệu ứng viết trong `GameWorld.use_skill()` theo `id` | Như D14: 8 kỹ năng mỗi cái một cơ chế riêng | Thêm lớp mới: thêm khối dữ liệu + nhánh `match` cho kỹ năng mới |
| D21 | Khoá hang boss khi boss xuất hiện (CB-23) | Chặn đánh xa từ ngoài hang | Người chơi muốn bỏ chạy phải gục hoặc hạ boss — xem lại khi playtest |
| D22 | Ngoại hình = sprite thân (lớp × giới tính × da) + sprite tóc vẽ xám, tô màu bằng `modulate` lúc vẽ | 288 tổ hợp chỉ cần 20 sheet | Tóc vẽ trên tay/vũ khí → sheet tóc đã khoét chỗ tay/vũ khí che (`layer="hair"`) |
| D23 | Âm thanh: logic chỉ ghi id vào `GameWorld.sfx` (tối đa 32/khung), `main.gd` chuyển cho `AudioManager` | Logic vẫn chạy headless, test không cần âm thanh | Thêm âm mới: gọi `_sfx("id")` + sinh file cùng id |
| D24 | Thoại và nhiệm vụ là dữ liệu (`story.gd`); trạng thái kiểm theo nhịp 0,5 giây (`_check_quest_state`) + sự kiện đếm (`quest_event`) | Thêm bước mới chỉ cần 1 dòng dữ liệu + 1 nhánh `match` | Bước kiểu trạng thái có độ trễ tối đa 0,5 giây |
| D25 | Thời gian thực (boss hiếm, thương nhân) dùng `GameWorld.now_unix()`, test ghi đè bằng `debug_now` | Kịch bản "2 lần/ngày", "tồn tại 1 giờ" | Người chơi đổi giờ máy để gọi boss — chống gian lận ở server (KT-10) |
| D26 | Gift code kiểm offline bằng tổng kiểm tra SHA-256 có khoá bí mật trong game (CR-02) | Chưa có server; nhà phát hành vẫn phát mã được ngay | Người giải nén game tự sinh được mã; mỗi mã chỉ chặn dùng lại trên 1 máy → bản phát hành phải chuyển sang server (KT-10) |
| D27 | Gió là trạng thái của `GameWorld` (hướng, đồng hồ, gió mạnh), áp lên vận tốc người chơi và hướng đạn lúc bắn | Một chỗ đọc, test được headless | Thêm map có gió chỉ cần `wind` trong `maps.gd` |
| D28 | Lưới khai phá theo vùng: `tiles` = vùng đang đứng, `grids` cất vùng khác; khoá công trình vùng ≥ 2 là `<loại>_r<vùng>_<id ô>` (`Explore.tile_key`) | Id ô trùng giữa các vùng | Sản lượng phải duyệt mọi lưới (`Explore.region_grids`) |
| D29 | Ảo ảnh hút đòn (`decoys`): quái trong 30 m đi tới ảo ảnh gần nhất thay vì người chơi | Không cần hệ mục tiêu chung cho mọi quái | Ảo ảnh không có máu, chỉ hết theo thời gian |
| D16 | Đồng hồ xây riêng (`build_clock`) thay vì giờ thực | Không phụ thuộc đồng hồ máy (người chơi chỉnh giờ để gian lận); vẫn chạy offline qua `apply_offline` | Phải nhớ cộng `build_clock` ở cả `update()` và `apply_offline()` |

## 7. Lỗi đã gặp và cách xử lý

Ghi lại để không lặp lại khi viết thêm code.

| Hiện tượng | Nguyên nhân | Cách sửa |
| --- | --- | --- |
| HUD dồn hết về góc trái, bảng bản đồ không nằm giữa | `set_anchors_preset(FULL_RECT)` gọi trong `_ready()` (khi node đã vào cây) chỉ đổi anchor, giữ kích thước 0 | Dùng `set_anchors_and_offsets_preset()`; bảng phủ căn giữa bằng `CenterContainer` |
| `Parse Error: Cannot infer the type of "idx"` | `:=` với giá trị kiểu Variant (lấy từ biến không khai báo kiểu, Dictionary, phần tử Array) | Khai báo kiểu rõ: `var idx: int = i` |
| Nguy cơ lỗi hằng số | Định dạng chuỗi `%` bên trong `const` | Để chuỗi mẫu trong `const`, định dạng lúc chạy |
| Dấu ✔ hiện thành emoji tím | Font dự phòng emoji của Windows | Dùng ✓ (U+2713); tránh emoji trong UI |
| Nhật ký đè lên thanh kỹ năng | Độ rộng cố định 400px ở cửa sổ 1366px | Thu nhật ký còn 350px, ô kỹ năng còn 100px |
| Quái thường đuổi theo vào hang boss | Thiếu điều kiện bỏ đuổi | Quái không thuộc hang bỏ đuổi khi người chơi ở trong hang (MOB-04, có test) |
| Test cường hoá báo "ok" nhưng không kiểm tra gì | 10.000 lần thử tiêu hết vàng → lệnh bị từ chối → lỗi truy cập `res.success` làm hàm test dừng giữa chừng, mà chưa có `_check` nào hỏng | Nạp lại vàng mỗi lần thử và kiểm tra `res.ok`. **Bài học:** script lỗi giữa test không tự tính là FAIL; khi thấy `SCRIPT ERROR` trong log test thì coi như hỏng |
| Bot có đồ vẫn không đánh được boss | Bot không mở bản đồ nên tường sương mù vẫn chặn (đúng luật MOB-05); bot cũng không cộng điểm tiềm năng | Test giả lập đã khai phá 6 ô và cộng điểm như người chơi (`_gear_up`) |
| Định dạng chuỗi `"HP% ở %d"` báo lỗi | `%` đứng trước khoảng trắng | Viết `%%` khi muốn in dấu phần trăm |
| `Parse Error` khi đặt tên biến `super` | `super` là từ khoá của GDScript | Đổi tên (`empowered`) |
| Nhãn HUD có ký tự xuống dòng thật bên trong chuỗi | Script Python vá file viết `"\\n"` thành xuống dòng thật | Kiểm lại file sau khi vá; trong GDScript dùng chuỗi thoát `\n` |
| Nhãn nhiều dòng chỉ hiện 1 dòng | `Label.clip_text = true` ép một dòng | Dùng `max_lines_visible` thay cho `clip_text` |
| Thanh kỹ năng 5 ô đè lên nhật ký | Thêm ô bình máu Q làm thanh rộng ra | Ô kỹ năng 92px, nhật ký 320px; mỗi lần thêm phần tử HUD cần chụp lại ảnh ở 1366 × 768 |
| Ô kỹ năng đè nhật ký lần 2 (G1) | Thêm icon 32px làm ô rộng 124px | Ô 100px, chữ lệch phải 33px |
| `Cannot infer the type` với `var x := a.kind == "..."` | `a` không khai báo kiểu nên biểu thức là Variant | `var x: bool = ...` |
| Test báo `ok` nhưng log có `unsupported format character` (M3) | Câu báo lỗi trong `_check()` chứa `%` (ví dụ "+12% + 18%") rồi dùng toán tử `%` | Viết `%%`; lại một lần nữa: thấy `SCRIPT ERROR` là coi như hỏng |
| Vá file bằng Python qua heredoc làm `\n` trong chuỗi GDScript thành xuống dòng thật (lặp lại ở M3) | Lớp shell/heredoc ăn mất dấu `\` | Viết script vá ra file riêng bằng công cụ Write, dùng `chr(92)` cho dấu `\` |
| `Cannot infer the type of "before"` (M3) | `:=` với `Array.duplicate()` của biến kiểu Variant | `var before: Array = ...` |
| 29 file bị đổi sang CRLF (C1) | Python trên Windows ghi file chế độ văn bản → `\r\n` | `.gitattributes` `* text=auto eol=lf`; script vá dùng thư viện ghi nhị phân LF |
| `String formatting error: unsupported format character` (C1, 2 lần) | Chuỗi có `%` theo sau là khoảng trắng/ngoặc ("20% (%d)") | Viết `%%`; dò bằng `grep "ERROR"` trong log test |
| Hộp thoại hiện đè lên bảng túi đồ/cửa hàng (C1) | Sự kiện thoại tới lúc bảng đang mở | `DialogBox.hold` khi có bảng mở |
| Lưới khai phá 40 ô tràn ra ngoài bảng M (Spec_Notes N10) | Cỡ ô cố định 46 px | `hex_map._fit()` tính cỡ ô theo khung |
| Lệnh bash treo tới hết thời gian chờ | Lỡ để `cat > file` không có đầu vào (chờ bàn phím) | Không dùng `cat >` không kèm heredoc |

## 8. Hạn chế và việc cần làm

- Repo Git: https://github.com/VinhNV8/Mistbreaker-Celestial-Genesis (nhánh `main`; `.godot/` không commit).
- Chưa có export preset: thêm khi cần build `.exe` (Project → Export → Windows Desktop; cần tải export templates 4.7.2).
- Va chạm là hình tròn và cây chỉ để trang trí, nhân vật đi xuyên qua cây được.
- Mới test thủ công 2 phân giải (1366 × 768 và màn hình HiDPI 2880 × 1694).
- File `.uid` cạnh mỗi script do Godot 4.4+ tự sinh: **phải commit cùng script**, đừng xoá.

## 9. Tham chiếu

- Kịch bản game: [kich-ban-game-thien-phu-khai-gioi.md](kich-ban-game-thien-phu-khai-gioi.md)
- Đặc tả yêu cầu: [01-requirement-spec.md](01-requirement-spec.md)
- Godot 4.7.2 release: https://github.com/godotengine/godot/releases/tag/4.7.2-stable
