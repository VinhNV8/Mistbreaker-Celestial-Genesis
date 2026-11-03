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
| `scripts/core/gift_code.gd` | Kiểm gift code (SHA-256 + Base32 Crockford), mã đã dùng lưu `user://redeemed_codes.cfg` (CR-02). `SERIAL_TALENTS` (`{"DT": "dao-tac"}`) + `talent_of(serial)`: tiền tố seri → Thiên phú cố định, `validate()` trả thêm khoá `talent`; `Awakening.gift_roll(serial, talent_id)` ra đúng Thiên phú đó (GC-09) |
| `tools/giftcode.py` (ngoài `godot/`) | Nhà phát hành sinh mã: `python tools/giftcode.py <số lượng> [đợt]` → `tools/giftcode_out/<đợt>.csv` (không commit); `--talent DT <số lượng> [đợt]` sinh mã Đạo Tặc (GC-09, bảng `SERIAL_TALENTS` phải giống `gift_code.gd`; mã thường tránh tiền tố đặc biệt); `--check <mã>` để thử (in Thiên phú cố định nếu có). Thuật toán phải giống `gift_code.gd` (test GC-T1 kiểm 1 mã do công cụ sinh) |
| `scripts/data/looks.gd` | Ngoại hình: giới tính, 3 da, 4 kiểu tóc, 6 màu tóc; id sprite thân/tóc (C1) |
| `scripts/data/story.gd` | 18 đoạn thoại và chuỗi 11 nhiệm vụ chương 1 (C1) |
| `scripts/data/resources.gd` | Tên, icon, chú thích 8 tài nguyên (C1, Spec_Notes N6) |
| `scripts/data/maps.gd` | Các vùng, map (1-1 Rừng Sương, 1-3 Lõi Sương) — M4.1. SN11-03: `get_map()` nhân toạ độ ×`MAP_SCALE` (√3), `scaled()`, `POINT_LISTS`, `CIRCLE_LISTS` (D69) |
| `scripts/data/classes.gd` | 2 lớp (Kiếm Khách, Thợ Săn) và 4 kỹ năng mỗi lớp: hồi chiêu, MP, hệ số, icon (M3) |
| `scripts/data/items.gd` | Trang bị: 8 ô, 5 phẩm chất, affix, tỉ lệ cường hoá, bảng rơi đồ, bộ trang bị, đồ Cam (M1) |
| `scripts/core/config.gd` | **Mọi hằng số cân bằng** (Đuốc, điều kiện mở hang, giá xây…) |
| `scripts/core/formulas.gd` | Công thức EXP, sát thương, combo; **chỉ số quái theo tài liệu 06** (`mob_stats`, `boss_hits`, M3) — phải giống hệt `tools/gen_world_doc.py` |
| `scripts/core/stats.gd` | Tính chỉ số phái sinh từ lớp + cấp + 7 thuộc tính (khởi tạo `START` + tự tăng `GROW` + điểm + điểm Đạo Tặc cướp) + Thiên phú: HP, MP, Tấn công, né tránh, xuyên giáp, kháng hiệu ứng… Hồ sơ lớp ở `CLASS` (CS, docs/26) |
| `scripts/core/gates.gd` | BD-11 / KP-10 / NV-23 ([34](34-dungeon-cong-ngau-nhien.md)): Cổng dungeon — mở ngẫu nhiên, hạng, bản đồ trong cổng, Chúa Cổng, thưởng |
| `scripts/core/talent_slots.gd` | TP-05/13/14 ([33](33-thien-phu-phu-cong-huong.md)): Thiên phú chính + phụ (`has`, `level_of`, `value`, `has_group_sub`), ô phụ / bể quay, 9 cặp cộng hưởng đặc biệt (`SPECIAL`), dòng cộng hưởng cho bảng Thiên phú |
| `scripts/ui/sub_talent_panel.gd` | TP5-02: bảng Lễ Thức Tỉnh ô Thiên phú phụ (quay / quay lại / nhận) |
| `scripts/ui/item_tip.gd` | SN11-01/02: thẻ thông tin trang bị khi rê chuột (`ItemTip.make` — đồ trong túi: [ĐANG XEM + so sánh ▲▼][ĐANG MẶC]; đồ đang mặc: [ĐANG MẶC]), `diff_lines` dùng cả cho khung chi tiết Túi đồ |
| `scripts/ui/enhance_toast.gd` | SN10-01: kết quả cường hoá giữa màn hình (`EnhanceToast.pop`), dùng chung Túi đồ và Lò Rèn |
| `scripts/core/rng_util.gd` | RNG dạng `Callable`, chọn theo trọng số, xáo trộn |
| `scripts/core/awakening.gd` | Lễ Thức Tỉnh: lượt quay, bảo hiểm hạng B |
| `scripts/core/explore.gd` | Lưới lục giác, sự kiện ô đất, công trình có thời gian xây, sản lượng, hồi Đuốc |
| `scripts/core/profile.gd` | Hồ sơ người chơi + chuyển đổi sang/từ Dictionary |
| `scripts/core/save_system.gd` | Đọc/ghi JSON, thu hoạch offline. SN9-02: 5 ô nhân vật (`select_slot`, `slot_summary`, `list_slots`, `first_empty`, `delete_slot`, `name_taken`, `remember_slot` / `last_slot`) |
| `scripts/ui/target_frame.gd` | SN9-09: khung mục tiêu (chân dung quái, loại · tên · cấp, hệ, thanh máu + số, Phá Thế, trạng thái) — đọc `GameWorld.focus` |
| `scripts/core/items.gd` | Sinh đồ, chỉ số đồ, mặc/tháo, cường hoá, phân rã, Lực chiến (M1); chuyển cấp cường hoá khi mặc (`plus_after_equip`), bộ lọc phân rã/bán nhanh (`bulk_candidates`) — SN2 |
| `scripts/core/chapters.gd` | Bộ điều phối logic theo chương (D38): `MODULES = [Ch3, Ch4, …]`; GameWorld gọi `Chapters.<hook>(self, …)`; mỗi chapterN.gd khai báo `HOOKS`, `MAPS`, `NPCS`. Danh sách hook + chữ ký ở đầu file |
| `scripts/core/chapter4.gd` | M7 chương 4 (docs/11): nước đầm, độc tích luỹ, ảo ảnh, quái vùng 4, Nữ Vương Phệ Mộng, Thuỷ Quái Thất Đầu, Bộ U Minh, Gối Mộng, Vảy Thất Đầu, Mộng Cảnh, nhiệm vụ chương 4, **tiến hoá Thiên phú** (`evolve`, `stage_level`, `evo_form`) |
| `scripts/core/chapter3.gd` | M6 chương 3 (docs/10): môi trường sa mạc, quái/boss vùng 3, Nhân Sư, đồ/bộ vùng 3, Độn Thổ, nhiệm vụ chương 3, chuyển chức 1. Hàm static nhận `GameWorld`; trạng thái ở `GameWorld.ch3` (`Ch3.State`) |
| `scripts/core/fog.gd` | Sương che bản đồ: ô 64 px, mở bán kính 36 m, lưu base64 bitset, % khám phá (SN-31) |
| `scripts/core/game_world.gd` | Mô phỏng: di chuyển, combat, AI quái, boss, EXP, rơi đồ, kỹ năng Thiên phú, đồng minh, thảo dược, rương ẩn; Đạo Tặc cướp thuộc tính (giới hạn, Túi Tang Vật, Đà Cướp, Sổ — D66) |
| `scripts/view/world_view.gd` | Vẽ bản đồ, quái, vòng báo hiệu, hiệu ứng chém, chữ bay. Có hình thì vẽ sprite (sắp xếp theo chiều sâu, hoạt ảnh theo trạng thái, xác quái, tia trúng đòn); thiếu hình thì vẽ hình khối tạm |
| `scripts/view/sprite_lib.gd` | Nạp `assets/art_manifest.json`, cắt frame, lật ngang, lát ô bằng đa giác UV, lấy icon (G1) |
| `assets/sprites/`, `assets/icons/`, `assets/env/`, `assets/art_manifest.json` | Hình do `tools/art` sinh ra — **không sửa tay**, sửa code sinh rồi chạy lại |
| `scripts/ui/ui_theme.gd` | Theme, màu, font, hàm dựng Control nhanh. DH-11: font Be Vietnam Pro từ `assets/fonts` (thiếu file thì dùng font hệ thống; font hệ thống làm dự phòng cho ký tự lạ), nút gỗ/vàng nổi khối |
| `scripts/ui/frame_box.gd` | StyleBox tự vẽ khung trang trí (nền gỗ, viền vàng 2 lớp, hoa văn góc) — `SolidPanel` khung lớn, `PanelContainer` khung nhỏ (DH-11) |
| `assets/fonts/` | Be Vietnam Pro Medium + ExtraBold, giấy phép SIL OFL 1.1 (`OFL.txt`) |
| `scripts/ui/hud.gd` | HUD khi chơi |
| `scripts/ui/char_frame.gd` | UI-08: khung nhân vật góc trái trên, vẽ hoàn toàn bằng `_draw()` (không dùng ảnh): bảng tên, chân dung tròn + vòng EXP tím, khiên cấp, hoa sen Thiên phú, huy hiệu Lực chiến / Điểm tiềm năng, thanh HP/MP. `hud.gd` gọi `set_data(dict)` mỗi khung hình. Không nền; thu nhỏ bằng `scale = SCALE` (0,75), nhân vật vẽ `size_mul = 1/SCALE` để giữ điểm ảnh nguyên |
| `scripts/core/chapter5.gd` | M8 chương 5 Núi Lửa Phẫn Nộ ([12](12-chuong-5.md)): dung nham, núi lửa phun, nhiệt, quái vùng 5, Viêm Long, Phượng Hoàng Tro, Công Trại / đột kích, nhiệm vụ chương 5, chuyển chức 2 (`can_job2`, `do_job2`). Gắn qua `chapters.gd` |
| `scripts/view/region5_view.gd` | Vẽ vùng 5: hồ dung nham, Long Huyệt ngập + Đá Nổi (`draw_arena`), vòng báo thiên thạch, cột lửa, phun lửa, Cổng Trại (`draw_over`), cây cối núi lửa (`decor_id`) |
| `scripts/core/chapter6.gd` | M9 chương 6 Băng Nguyên Vĩnh Dạ ([14](14-chuong-6.md)): băng giá (tầng, đông cứng), đêm dài, mặt băng trơn (`input_move`), Than Hồng, quái vùng 6, Bản Ngã Bóng Tối (ghi kỹ năng người chơi theo hồi chiêu → dùng lại sau 3 giây, Gương vỡ, Thiên phú phản chiếu), Long Băng, Đèn Cực Quang, Ám Khí / mất kiểm soát (`input_filter`), nhiệm vụ chương 6. Gắn qua `chapters.gd` |
| `scripts/view/region6_view.gd` | Vẽ vùng 6: lửa trại, chậu lửa, Đèn Cực Quang (`draw_props`), mặt băng, Bão tuyết, bóng tấm gương thật (`draw_ground`), Bản Ngã = dáng lớp người chơi tô đen / Gương Băng (`draw_enemy`), vòng báo, đêm dài + cực quang, viền băng giá / Ám Khí (`draw_over`), cây cối băng nguyên (`decor_id`) |
| `scripts/core/chapter7.gd` | M10 chương 7 Thiên Không Đảo ([16](16-chuong-7.md)): đảo bay (`on_land` = đảo ∪ cầu đang bật ∪ đảo vụn ∪ nền đấu trường còn; `on_land_static` cho vẽ/đặt quái), rơi khỏi mép (0,25 giây → Đá Neo gần nhất, −10% HP, bất tử 1,5 giây; né lăn / Đột Kích không xét), cầu gió (tắt 5/30 giây, lệch 4,3 giây mỗi cầu, Trụ Gió đã kích giữ cầu gần đó), đảo vụn, Lông Vũ Gió (`drink`), quái vùng 7, Thiên Không Cự Thần (`update_enemy` tự điều khiển: Đấm đất / Mưa đá / Thiên chuỳ, vành ngoài vỡ theo 10% HP hoặc 20 giây — D41), Kỳ Lân Mây (`update_rare`: chạy = trượt, dừng tới 12% HP / 6 giây), Bộ Thiên Phong, Búa Cự Thần (`after_slash/after_shot`), Sừng Kỳ Lân, Thiên Chuỳ (Đạo Tặc), Neo Hư Vô (`vanish`), nhiệm vụ 8 bước, tiến hoá lần 2 / Đột Phá (`form`, `evolve2`). Gắn qua `chapters.gd` |
| `scripts/view/region7_view.gd` | Vẽ vùng 7: trời mây (gradient + mây trôi) phủ cả map rồi vẽ lại đảo (vách đá, nền, mép mây), cầu gió (nhấp nháy khi còn ≤ 2 giây, mờ khi tắt, vàng khi không bao giờ tắt), Đá Neo, Trụ Gió, đảo vụn (`draw_ground`); hố / cung vỡ / cung sắp vỡ / vết nứt / Bia Đá gốc trên đấu trường (`draw_arena`); vòng báo, vệt sấm, Khiên trời, vòng báo đòn Cự Thần, rơi / Lông Vũ Gió (`draw_over`); cây cảnh `decor_id` |
| `scripts/core/chapter8.gd` | M11 chương 8 Vực Hư Vô ([17](17-chuong-8.md)): Suy Thiên (`decay` 0–50%, +10% mỗi 60 giây ngoài đèn / vùng an toàn; hook `talent_mult` / `talent_cd_mult` — D70; `Talents.suppressed` tắt hiệu ứng phụ bậc 5/10 khi k ≤ 0,5), Đèn Tinh Quang (map `lamps`, `lamps_off`; 4 đèn Điện Giáo Chủ, 4 đèn ổ Hư Vô Thú; đứng 5 giây → Suy Thiên về 0), Cột Đá Hư Vô (`stones8` + 4 cột đấu trường: chặn đạn quái / người chơi, che tia, người chơi và quái không đi xuyên), Đèn Lồng (`drink`), không hệ (`element: ""`), quái vùng 8 (Bóng Hư Vô tàng hình qua meta `stealth` + `is_hidden`, Đâm lén, Kẻ Nuốt — đạn hệ giả `nuot` → `player_hurt` xoá buff, Giáp Sĩ Chém nặng `chase`, Mắt Hư Vô `update_enemy`, Tư Tế Tế lễ, Không Mặt `adjust_damage` theo meta `face8`), Giáo Chủ Hư Vô (`update_enemy` tự điều khiển: Phong ấn / Tia hư vô / Trượng, Hút Thiên phú kênh 1,5 giây mỗi 30 giây — `drain_talent(w, t)` dùng lại ở chương 9, GĐ3 4 Tư Tế + Tín Đồ, chuyển cảnh trung lập 3 giây), Hư Vô Thú (qua `update_enemy`, không qua `update_rare` vì GameWorld vẫn chạy máy trạng thái chung sau `update_rare`), Lõi Hư Vô, Ấn Hư Vô, Nanh Hư Vô (`derive_after` +30% xuyên giáp), Bộ Tinh Quang, Hút Thiên Phú (Đạo Tặc), nhiệm vụ 7 bước, Tổng tấn công (Lính Liên minh = `Ally` kind `soldier` có HP), Phản công Hư Vô, 5 Tổ Sư (`talk` → `"job3"`). Gắn qua `chapters.gd` |
| `scripts/view/region8_view.gd` | Vẽ vùng 8: sương tím, Cột Đá, Đèn Tinh Quang (vòng sáng 6 m, tiến độ thắp), đèn đấu trường / ổ (`draw_ground`); vòng Phong ấn, Tia hư vô, Tia nhìn (bị cột chặn thì ngắn lại), nón Chém nặng / Hàm hư vô, nón mặt Không Mặt, dây Hút Thiên phú, mũi tên chỉ đèn khi Suy Thiên ≥ 30% (`draw_over`); cây cảnh `decor_id` |
| `scripts/core/chapter9.gd` | M12 chương 9 Thiên Đạo Chi Môn ([18](18-chuong-9.md)): 9 tầng (3 tầng mỗi map; `floor_of` theo `doors9`; Cửa Tầng đóng đẩy người chơi lại; Thủ Tầng `guards9` → `profile.floors9`), hệ tầng rút khi bước vào tầng (không trùng lần trước, `Enemy.el_override` — D71), Ấn Hệ (`seals9`, 60/120 giây, +30% qua `hit_mult`), mật độ quái theo tầng; quái vùng 9 (Kích ngũ hành, Tàn Hồn mang Thiên phú theo nhóm, Phi nước đại, Gầm ngũ hành → `nocounter_t`, Thiên phạt, Ngũ Hành Sứ Giả đổi hệ 8 giây + nhận 25% khi không khắc — `player_counters`); Ma Tôn Vô Diện (`update_enemy` tự điều khiển: GĐ1 Vồ / Phân thân theo 12% HP (meta `hide9`, bản giả `ma-ton-ao` tan khi trúng) / Độn thổ; GĐ2 Giấc mơ (`input_filter` đảo phím, né lăn tránh) / Dung nham + 5 Đá Nổi / Sao chép theo `Ch6.MIRROR_OF`; GĐ3 vành vỡ / Hút Thiên phú (`Ch8.drain_talent`, 3 đèn) / đổi hệ 10 giây; dưới 10% mảnh thứ hai — Ám Khí +10/giây; chuyển cảnh trung lập 6 giây), Thiên Đạo Hư Ảnh (`update_rare` chặn nhánh chung, 3 cơ chế Thiên phú S+), Mặt Nạ Vô Diện, Bộ Thiên Đạo, Vô Diện (Đạo Tặc), nhiệm vụ 7 bước, 9 dòng ký ức, `choose_ending` (Hợp nhất: Thiên Đạo Lực → Thần Hoá; Hiến tế: sương vùng 1–9 mở, ô lộ sự kiện, `talent_mult` 1,2). Gắn qua `chapters.gd` |
| `scripts/core/endgame.gd` | M12.4 endgame ([18](18-chuong-9.md) mục 6): cấp sau 100 (`after_exp` — hook mới — chuyển `profile.xp` ở cấp 100 thành `divine_level` khi đã chọn kết thúc; `divine_need(N)` = EXP(99→100) × (1 + 0,02N)), Điểm Thiên Đạo 5 nhánh (`allocate`, `respec`, `skill_cd_mult`, `derive_bonus`), Thần Vực (`start_tower` — tháp ở Thiên Thê Đài I, khoá trong vòng 30 m, 90 giây/tầng, cấp quái 100 + 2·tầng, Thần Tướng mỗi 5 tầng, `tower_best`), Tái Thiết (buff `rebuilt(p, k)` dùng trong GameWorld: EXP, đi đường, bình máu, vàng, cường hoá; Explore: Đuốc, sản lượng; Skills2: Bí Kíp; Triều tàn dư mỗi 30 phút → `rebuild_raid`). Trạng thái `GameWorld.eg` |
| `scripts/view/region9_view.gd` | Vẽ vùng 9: màu trời từng tầng theo hệ, Cửa Tầng (đóng/mở), bệ Ấn Hệ (`draw_ground`); vành vỡ / sắp vỡ, dung nham, Đá Nổi, đèn (`draw_arena`); vòng báo, bóng thật của Ma Tôn khi phân thân, vòng Giấc mơ, dây Hút, đổi hệ Sứ Giả, sương Hư Ảnh, vòng Thần Vực (`draw_over`) |
| `scripts/ui/divine_panel.gd` | M12.4: bảng Điểm Thiên Đạo (5 nhánh, tẩy điểm) + tóm tắt Thần Vực / Tái Thiết — Vân Hạc (E) ở Thiên Thê Đài I sau kết thúc |
| `scripts/ui/job2_panel.gd` | Bảng chọn 1 trong 2 nhánh chuyển chức 2 (Liệt Diễm, phím E) |
| `scripts/core/puzzle.gd` | Câu đố ô Di tích (M5-04): Trận Đèn Cổ 3 × 3 và câu hỏi cổ thư; sinh cố định theo (tên nhân vật, vùng, ô) nên không cần lưu save; `GameWorld.relic_press/relic_answer` mở rương với thưởng ×2 |
| `scripts/core/skills2.gd` | SK2–SK3: 12 kỹ năng cấp 15/22 + chuyển chức 1, 3 tối thượng, 12 kỹ năng nhánh chuyển chức 2, Bí Kíp (`grant_book`, `drop_book`, `exchange_book`, `on_kill`, `on_relic`) (`cast`, `tick`), biến thể 3 tầng (`set_variant`, `cost_mult`, `hit_mult`, `def_mult`, `after_hit`, `after_cast`); trạng thái `GameWorld.sk2` |
| `scripts/view/skills2_view.gd` | Vẽ Hoả Tường, Mưa Băng, Cầu Sấm; vùng có `"color"` (Thánh Vực, hào quang Thành Bất Diệt, Linh Trận) vẽ thành vòng sáng |
| `scripts/core/classes2.gd` | LH1/LH2 ([19](19-lop-ho-ve-trieu-hoi-su.md)): lớp Hộ Vệ, Triệu Hồi Sư — 26 kỹ năng (`cast`, gọi từ `Skills2.cast` khi id không thuộc 3 lớp cũ), đặc tính lớp và bị động chuyển chức (`taken_mult`, `def_mult`, `on_player_hit`, `hit_mult`, `after_hit`, `after_slash`, `after_dash_hit`), linh thú (`SUMMONS`, `summon`, `summon_act`, `ally_mult`, `focus_target`, Linh Hồ thường trực), đánh thường Linh Cầu (`basic_spirit`), đồ đằng; trạng thái `GameWorld.cl2` |
| `scripts/core/job3.gd` | J3 ([23](23-chuyen-chuc-3-linh-thu-co-mau.md)): chuyển chức 3 — `can_job3` / `do_job3`, +10% HP và Tấn công, hiệu ứng Kiếm Thần / Thiên Lạc Xạ Thủ / Hiền Giả, Thần Kỹ `nhatkiem` / `tinhvu` / `nguhanh` (`cast`, gọi từ `Classes2.cast`); là module của `Chapters` (`HOOKS`: derive_bonus, derive_after, after_shot, hit_mult, poise_mult, tick, on_load); gọi thẳng từ GameWorld: `crit_bonus`, `break_extra`, `area`, `is_free`, `after_cast`; trạng thái `GameWorld.j3` |
| `scripts/core/passives.gd` | PV ([27](27-ky-nang-bi-dong.md)): 20 kỹ năng bị động (5 lớp × 4, cấp 0–5, Điểm Kỹ Năng chung) — dữ liệu `DEFS`, chữ đặc tính lớp `TRAITS`, `upgrade` / `reset` / `describe`; module của `Chapters` (`HOOKS`: derive_bonus, derive_after, hit_mult, tick); gọi thẳng từ GameWorld: `speed_mult`, `on_evade`, `absorb`, `after_hit`; từ Classes2: `taken_mult`, `reflect`, `ally_bonus`; trạng thái `GameWorld.pv`; save v21 `passive_levels` |
| `scripts/ui/job3_panel.gd` | Bảng chuyển chức 3 (1 thẻ viền bạc, 2 hiệu ứng, Thần Kỹ, nút Chuyển chức; Liệt Diễm trả `"job3"`) |
| `scripts/view/job3_view.gd` | Vẽ hào quang chức 3, Nhất Kiếm (vệt báo + vệt chém), mũi tên sao, 5 cầu Ngũ Hành, vòng Bất Khuất, thanh máu linh thú |
| `tools/art/job3_icons.py` | Icon 5 Thần Kỹ (viền bạc) |
| `scripts/view/classes2_view.gd` | Vẽ Phi Thuẫn, Phán Quyết, Khiên Thép (vòng thép + khiên vàng `fx-sheet-khienthep` nếu có), Thành Bất Diệt (đôi cánh), đồ đằng, dây Liên Kết Linh Hồn |
| `tools/art/classes45_icons.py` | Icon 18 kỹ năng + 2 đánh thường (`bash`, `spiritorb`) của Hộ Vệ, Triệu Hồi Sư; 8 kỹ năng charactors.md lấy icon từ `class_skill_icons.py` |
| `scripts/view/class_fx.gd` | AR-44: vẽ hiệu ứng kỹ năng cắt từ sprite sheet 5 lớp (`fx-sheet-*`): đạn Hỏa Cầu/Trảm Phong/Xuyên Tâm/Băng Lao, Thiên Tiễn, thiên thạch, Kiếm Ý, Vạn Kiếm. AR-45b: `CAST_FX` + `on_cast`/`draw_casts` vẽ keyframe `vfx-<id>` khi thi triển 11 kỹ năng Kiếm Khách (charge → cast → impact, quanh thân hoặc trước mặt theo hướng nhìn); `SHOT_LOOK` cho đạn Phi Kiếm / Thánh Kiếm Trảm. world_view `_watch_casts` nhận ra lúc thi triển qua bước nhảy hồi chiêu của ô (chỉ lớp vẽ) |
| `scripts/ui/skill_panel.gd` | Bảng Kỹ năng (SK1, phím U): cấp kỹ năng, Điểm Kỹ Năng, lắp 7 ô (SN12-02: kéo-thả vào hàng Thanh kỹ năng, đổi Bộ 1 / 2), tẩy điểm (đổi ô / tẩy chỉ ở vùng an toàn). UI-23: `_groups()` chia kỹ năng theo tab (`base` / `job` / `ult` / `job2`, tab rỗng bị bỏ), `_layout()` xếp cây (2 ô đầu giữa, còn lại 2 nhánh; job2 chưa chọn = 2 cột theo nhánh), `SkillNode` (ô tự vẽ: khung, huy hiệu cấp, số ô lắp, ổ khoá) + `TreeCanvas` (đường gấp khúc + mũi tên), `_numbers()` tính số liệu theo cấp (sát thương `mul × (1 + 0,08 × (cấp − 1))`, hồi chiêu hỗ trợ −4%/cấp, `Skills2.cost_mult` của biến thể; Phạm vi = số "N m" đầu tiên trong mô tả), `_upgrade_block()` cố định ở đáy cột phải. Biển lớp dùng lại `ClassSelect.ClassScene` + `StatsPage.QUOTES`. Tên node giữ `SkillUp_<id>`, `Slot_<id>_<i>`, `Var_…`, `Book_…`, `SkillReset`; mới `Tab_<nhóm>`, `Node_<id>` |
| `scripts/ui/minimap.gd` | Bản đồ nhỏ góc phải HUD (M5-03; SN5-01: chuột trái → `GameWorld.set_move_target`, chuột phải huỷ): ảnh sương 1 pixel/ô dựng lại khi `fog.version` đổi, vẽ làng, hang boss, tường sương, NPC, quái ở vùng đã thấy, boss/boss hiếm nhấp nháy, mũi tên nhân vật; phím V đổi cỡ 230 ↔ 460 px |
| `scripts/ui/skill_bar.gd` | Thanh kỹ năng 12 ô (SN12-02: J, 1–6, G, Space, L, Q, F; ô chưa mở ẩn, ô G to, ô trống "+", chuột phải / thả kỹ năng) có khung trang trí, tự vẽ bằng `_draw`: icon cắt tròn, hồi chiêu quét tròn, nhãn phím, tên + dòng phụ; HUD gọi `set_slot(i, {...})` mỗi khung hình (DH-11) |
| `scripts/ui/modal.gd` | Lớp cha của bảng phủ |
| `scripts/ui/class_select.gd` | UI-22: màn chọn lớp kiểu thẻ (bước 1 tạo nhân vật) — `CARDS` (màu, cảnh, huy hiệu, câu dẫn, kỹ năng hiện), `ClassScene` vẽ cảnh + chân dung `portrait-<lớp>`, `on_pick(class_id)`; `create_screen.gd` thêm nó làm lớp phủ, nút "Đổi lớp" mở lại |
| `scripts/ui/ornate.gd` | UI-27: mảnh trang trí cắt từ ảnh mẫu (`assets/ui/`, sinh bằng `tools/art/ui_cut.py`) — `tex(id)`, `linear(ctrl)` (ảnh vẽ lọc Linear; nội dung pixel bên trong đặt lại Nearest), `panel_style(pad)` (StyleBoxTexture 9-slice lề 32), `row_style()`, `button(b, "gold"/"dark"/"plus")` (normal/hover/pressed/disabled bằng `modulate_color`), `image(id, w, h)`, `image_button(id, w, h)` (UI-28: nút là nguyên ảnh, hover/pressed bằng `modulate_color`), `style(id, l, t, r, b, pad)`, `group(n)` (5.938), lớp `Plate` (biển vẽ + tiêu đề + số in đè theo toạ độ tỉ lệ) |
| `scripts/ui/char_widgets.gd` | UI-21: các mảnh tự vẽ của bảng Nhân vật — `ScenePortrait` (rừng đêm, đuốc, bệ đá, nhân vật), `RankBadge`, `Stars`, `PowerBanner` (Lực chiến), `CampScene` |
| `scripts/ui/stats_page.gd` | UI-27: hàng thuộc tính gọn `StatCard_<id>` (icon vẽ `attr-<id>`, mã + tên, `MainTag_<id>`, `Total_<id>` + `Source_<id>` — HBox nhiều Label mỗi nguồn một màu UI-26b, `Help_<id>` tooltip = `per_point_lines()` + `contribution()`, `Plus_<id>`), thứ tự `ROWS` cố định (UI-26c); đầu trang `PointsBadge` (Ornate.Plate), dưới `AutoAllocate` (nút vàng), `AutoPreset`, `Respec`; `build_side()` = `PowerBanner` (Ornate.Plate có `power`), Chỉ số chiến đấu, câu trích + `ui-scene`. UI-21: `build()` = cột giữa "Điểm thuộc tính" (thẻ chỉ số, Tẩy điểm, Tự cộng + `PRESETS` mẫu theo lớp, `apply_preset`), `build_side()` = cột phải Lực chiến + Chỉ số chiến đấu. UI-11: trang Chỉ số (cộng điểm, tẩy điểm, tự cộng) — `StatsPage.build(vbox, world, refresh)`, dùng làm tab "Chỉ số" của Túi đồ (thay `stats_panel.gd` đã xoá). Phím C → `inventory_panel.toggle_tab(world, "stats")` |
| `scripts/core/caves.gd` | Hang phụ ([15](15-hang-phu.md)): bản đồ `cave-<map cha>` sinh từ map cha (`build_map`, `Maps.get_map` nạp muộn để tránh preload vòng), cửa hang (`entrance`), `blocker` (đang đóng), `populate` (3 khu: 5+1, 6+1 tinh anh, Chúa Hang HP ×5 + 2 quái), `on_kill` (Chúa Hang → món ≥ Xanh dương, vàng, Đá, cổng ra, đóng `COOLDOWN` 1200 giây chơi). `GameWorld.in_cave()`; trong hang không sinh quái ngoài đồng, không lưu sương / thưởng khai phá, không thêm `unlocked_maps`; logic chương không áp (hang không thuộc `MAPS` của module chương) |
| `scripts/ui/element_icon.gd` | UI-13: `ElementIcon.draw(ci, tâm, hệ, bán kính, alpha)` — biểu tượng ngũ hành vẽ bằng code (thay chữ "Mộc"…) cho quái, cột đá, khung nhân vật |
| `scripts/ui/log_box.gd` | UI-20: StyleBox một dòng nhật ký (dải mờ dần, vạch + huy hiệu màu theo loại). `hud.log_message` dùng `RichTextLabel` BBCode: `_log_bbcode` tô đậm số, `_group_thousands` thêm dấu chấm |
| `scripts/ui/quest_box.gd` | UI-16b: StyleBox nền khung nhiệm vụ (tím mờ, viền vàng, ngọc góc) + lớp con `Divider` (đường kẻ có ngọc dưới tiêu đề) |
| `scripts/ui/help_panel.gd` | UI-17: bảng Trợ giúp (modal) — phím F1/H (`toggle_help`), nút trong `pause_menu` (tín hiệu `help`); phím lấy từ `Screens.CONTROLS` |
| `scripts/ui/auto_button.gd` | UI-12: nút tròn bật/tắt Tự đánh cạnh thanh kỹ năng; HUD phát `auto_toggled` → main gọi `world.toggle_auto()` |
| `scripts/ui/map_panel.gd`, `hex_map.gd` | Bản đồ khai phá |
| `scripts/ui/char_bar.gd` | UI-28b: thanh tiêu đề chung nhóm Nhân vật — `CharBar.build(world, active, on_pick, on_close)` (`TopBar`: `BackButton`, `Tab_<id>` theo `TABS` stats/bag/res/skills/talent, Vàng + Tinh Thạch, `CurrencyPlus` → "res", `CloseButton`). Dùng ở `inventory_panel`, `skill_panel`, `talent_panel`; mỗi bảng có `signal open_panel(id)`, main.gd `_open_char_tab(id)` đóng cả 3 rồi mở bảng / tab đúng |
| `scripts/ui/inventory_panel.gd` | UI-28: `_top_bar()` gọi `CharBar.build` (tab ngoài Túi đồ phát `open_panel`), `_frame()` khung vẽ cho mọi cột (nội dung đặt lại Nearest). UI-21: bảng Nhân vật 3 cột (tiêu đề + tab, cột nhân vật `_character_column`, nội dung tab, cột phải). UI-26c: `_set_box` bọc trong `SetScroll` (ScrollContainer, giãn theo phần còn lại của cột) để cột trái không cao quá cửa sổ. Túi đồ: đang mặc, túi 30 ô, chi tiết, so sánh, cường hoá (M1); khung Phân rã nhanh, chấm đỏ ở món khớp lọc (SN-11) |
| `scripts/ui/bulk_box.gd` | Khung bộ lọc dùng chung: Phân rã nhanh (túi đồ) / Bán nhanh (cửa hàng), hỏi xác nhận (SN-10…12) |
| `scripts/ui/intro_screen.gd` | Cảnh mở đầu 5 trang (C1-10) |
| `scripts/ui/create_screen.gd` | Tạo nhân vật + ô xem trước động (C1-02); lớp `Preview` dùng lại ở túi đồ |
| `scripts/ui/dialog_box.gd` | Hộp thoại có chân dung; chờ khi đang mở bảng (C1-11) |
| `scripts/ui/shop_panel.gd` | Cửa hàng — phím E (C1-30, 32; UI-24): tab dọc Tạp hoá / Lữ hành / Bán đồ, lưới thẻ hàng, khung chi tiết + chọn số lượng (Mua ×N gọi `shop_buy` N lần), bán từng món + bán nhanh; tín hiệu `open_forge` |
| `scripts/ui/forge_panel.gd` | UI-25: Lò Rèn — phím R, `open_forge` từ Cửa hàng / Túi đồ, Thiết Ngưu (`talk` trả `"forge"`). Tab `enhance` (chọn món, ô chi phí, bảng chi phí mọi cấp `CostGrid`), `craft` (`forge_craft`), `refine` (`smith_trade`, `shop_buy("crystal_kim")`), `salvage` (BulkBox) |
| `scripts/ui/shop_widgets.gd` | UI-24/25: thành phần chung — `title_bar`, `currency`, `cost_chip` / `cost_row` (cần / có, thiếu đỏ), `side_tab`, `item_card`, `qty_box`, `section`, `group` (dấu chấm ngăn nghìn) |
| `scripts/ui/pause_menu.gd` | Menu tạm dừng + Cài đặt (C1-42) |
| `scripts/ui/world_map_panel.gd` | Bản đồ lục địa — phím N (M4.1). MP-09: nút Lên đường chỉ bật khi `world.at_waypoint()` và map đã mở |
| `scripts/core/portals.gd` | MP-09: cổng dịch chuyển sinh từ dữ liệu map (`list(id)` → `[{kind: next/back/waypoint, to, pos}]`, `chain()` thứ tự map theo REGIONS, `arrive_pos`, `waypoint_offset` chọn chỗ trống tránh `Maps.safe_buildings()` + NPC). `GameWorld._check_portals()` mỗi khung hình (trước di chuyển): vào cổng next/back → `travel(to, true)`; waypoint → sự kiện `"waypoint"` (main mở bảng lục địa). `portal_inside` chống kích hoạt lặp; `_arrive_via` đặt nhân vật cạnh cổng về khi tới nơi. Vẽ ở `world_view._draw_portals`, chấm trên `minimap` |
| `scripts/core/settings.gd` | Cài đặt âm lượng, toàn màn hình → `user://settings.cfg`; tạo bus Music, SFX (C1-42) |
| `scripts/audio/audio_manager.gd` | Phát hiệu ứng (10 kênh, chống lặp 0,05 giây) và nhạc nền vòng lặp có mờ dần (C1-40, 41) |
| `assets/audio/sfx/*.wav`, `assets/audio/music/*.wav` | Âm thanh do `tools/audio/gen_audio.py` sinh — không sửa tay |
| `scripts/ui/talent_panel.gd` | Bảng Thiên phú: hiệu ứng, kỹ năng L, hiệu ứng phụ, luyện cấp (M2) |
| `scripts/ui/screens.gd` | Màn hình tiêu đề, Lễ Thức Tỉnh, chiến thắng |
| `scripts/main.gd` | Điểm vào + chế độ smoke test |
| `tests/run_tests.gd` | ~127 test logic chạy headless; chạy một phần bằng `-- --only=<chuỗi trong tên test>` |
| `tools/audio/*.py` (ngoài `godot/`) | Sinh âm thanh bằng code (thư viện chuẩn Python): `python tools/audio/gen_audio.py [id …]`; danh sách id ở `tools/audio/README.md` |
| `godot/export_presets.cfg`, `tools/build_windows.sh` | Preset xuất Windows và script build `build/ThienPhuKhaiGioi.exe` (C1-50) |
| `tools/art/*.py` (ngoài `godot/`) | Bộ sinh hình pixel art (Python 3 + Pillow): `pixel.py` thư viện vẽ, `builders.py` dáng nhân vật/quái, `catalog.py` danh mục sprite, `icons.py`, `env.py`, `build_all.py`; `class_sheet.py` cắt sprite sheet 5 lớp `src/class-sheet.png` thành `sprites/pc-<lớp>.png` (AR-44, `build_all.py` gọi; chạy riêng thì chỉ vá các mục `pc-*` của manifest); `class_skill_icons.py` cắt 20 icon kỹ năng 48×48 từ `src/class-skills.png` (AR-44, `icons.build_all()` gọi cuối cùng nên ghi đè icon vẽ bằng code cùng id); `class_sheet.py` còn sinh chân dung `portrait-<lớp>` và 10 hiệu ứng `env/fx-sheet-*` (vẽ ở `godot/scripts/view/class_fx.gd`); `skill_vfx.py` sinh 40 keyframe `env/vfx-<id>` 32×32 (AR-45b, `env.py` đăng ký); `class_skill_actions.py` + `export_skill_design_review.py` xuất bộ duyệt PNG/GIF vào `docs/design/skills/` (không ghi `godot/assets`). Quy trình ở skill `.claude/skills/game-art/SKILL.md` |
| `tools/gen_world_doc.py` (ngoài `godot/`) | Sinh `docs/06-ban-do-quai-boss.md` từ công thức chỉ số quái; chạy `python tools/gen_world_doc.py docs/06-ban-do-quai-boss.md` (cần Python 3) |

### 2.3.2. Build file chạy Windows (C1-50)

1. Cài export templates Godot 4.7.2 **một lần** (1,28 GB): Godot editor → *Editor → Manage Export Templates → Download and Install*, hoặc giải nén `Godot_v4.7.2-stable_export_templates.tpz` vào `%APPDATA%\Godot\export_templates\4.7.2.stable\`.
2. `bash tools/build_windows.sh` → `build/ThienPhuKhaiGioi.exe` (pck nhúng trong exe; thư mục `build/` không commit).
3. Preset ở `godot/export_presets.cfg` (đã bỏ khỏi `.gitignore`): x86_64, loại `tests/*`, kèm `assets/*.json` (manifest hình đọc bằng `FileAccess`).
4. Máy này đã cài (20/10/2026) chỉ 5 file Windows x86_64 + `version.txt` từ gói `.tpz` (khoảng 200 MB thay vì 1,28 GB). Kết quả: 1 file exe 111 MB. Muốn build không dính phần đang sửa dở, build từ `git worktree` của commit cần phát hành. Kiểm thử bản build: `build/ThienPhuKhaiGioi.exe -- --smoke=<thư mục>`.

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
| Đường dẫn Godot | **5 ô nhân vật** (SN9-02, D60): ô 1 `user://save.json` (save cũ tự thành ô 1), ô 2…5 `user://save_2.json`…`save_5.json`; ô chơi gần nhất ở `user://slots.cfg` |
| Trên Windows | `%APPDATA%\Godot\app_userdata\Thiên Phú Khai Giới\save.json` (và `save_2.json`…) |
| Smoke test | `user://smoke_save*.json`, `user://smoke_slots.cfg` (`SaveSystem.prefix` / `slots_cfg`; tự xoá sau khi chạy, không đụng save thật) |
| Định dạng | JSON một dòng |
| Phiên bản hiện tại | **26** (M1 trang bị · M2 Thiên phú, công trình · M3 lớp, INT/LUK, điểm cướp · v5 M4.1 nhiều bản đồ · v6 C1: tên, ngoại hình, nhiệm vụ/thoại chương 1, lưới 40 ô, boss hiếm, Thương nhân, Vườn · v7 SN2: sương che từng map, thưởng khám phá, bộ lọc phân rã/bán nhanh · **v8 M5**: `rare_at` = lịch riêng từng boss hiếm, thay `rare_boss_at`; **v9 M6**: `job` (chuyển chức), `quest.ch3/kills3/oases`, `heat_free_until` · **v10 M7**: `evo` (số lần tiến hoá), `quest.ch4/kills4/orbs4`, `antidotes`, `fire_torches` · **v11 M8**: `job2` (chức 2), Tinh Thạch, Bình Nước Thánh, đột kích, `quest.ch5/kills5/raid_won` · **v12 M9**: `quest.ch6/kills6/beacons6/dark6`, `embers` (Than Hồng) · v13 SK1: `skill_points`, `skill_levels`, `loadout` · **v14 SK2**: `variants` · **v15 hang phụ**: `caves` {map cha: giây chơi khi hang mở lại}; đang ở trong hang thì `map_id` ghi map cha · **v16 SK3**: `secret_books`, `book_shards` · **v17 M10**: `feathers` (Lông Vũ Gió), `anchor_stones` {map: [Đá Neo đã chạm]}, `quest.ch7/kills7/pillars7/anchors7`, `buildings` camp3–5 + port · v18 J3 `job3` · v19 CS 7 thuộc tính · v20 Đạo Tặc `steal_bag`, `steal_log` · v21 PV `passive_levels` · v22 `mp_potions` · v23 SN11-03 sương theo map ×3 · v24 BK · **v25 M11**: `void_cores` (Lõi Hư Vô), `lanterns` (Đèn Lồng), `lamp_off_until` {"map:đèn": giây chơi}, `assault_play`, `quest.ch8/kills8/lamps8/cages8/pillars8/cores8_first` · **v26 M12**: `floors9`, `ending`, `divine_level`, `divine_points`, `tower_best`, `rebuild_raid`, `quest.ch9/kills9/souls9/mask9/tiles9`; EXP tích luỹ ở cấp 100 = `xp`). Save cũ được chuyển đổi tự động khi nạp |

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
- `fog`: {map_id: base64 của bitset}, bit i = ô `(i % w, i / w)` với `w = ⌈rộng / 64⌉`. Map đổi kích thước thì chuỗi cũ lệch ô — khi đổi kích thước map phải xoá `fog` của map đó. Khi chuyển từ v6: `fog`, `fog_rewards` rỗng (mọi map phủ sương), `bulk_filter` = mặc định (`Items.default_filter()`). Món đồ thêm `style` = `"staff"` (vũ khí Pháp Sư tên Trượng).
- Khi chuyển từ v5 (C1): tên `Khai Giới Giả`, ngoại hình mặc định; `quest_step` = 12 nếu đã hạ Sói Chúa, ngược lại 5 (bỏ qua phần hướng dẫn); lưới vùng 1 có 10 ô được thêm 30 ô (`Explore.upgrade_region1`), ô cũ `zone` = 1. `tiles[].zone` = 1 Bìa Rừng · 2 Rừng Sâu · 3 Lõi Sương.
- `rare_boss_at`, `merchant.until` là **giờ Unix** (boss hiếm 2 lần/ngày, thương nhân 1 giờ theo giờ thực) — khác `boss_respawn_at` tính theo giờ chơi.
- Khi chuyển từ v3: `class_id` = `kiem-khach`, `points` thêm `int`, `luk` = 0, `stolen` rỗng. Món đồ có thêm trường `style` (`"bow"` = vũ khí tên Cung), save cũ không có thì là `""`.
- `stolen`: thuộc tính Đạo Tặc cướp được, cũ → mới; tối đa = cấp nhân vật, giữ vĩnh viễn — đầy thì không cướp thêm (DT-04, sửa 2026-10-30). Không bị tẩy điểm.
- Khi chuyển từ v2: Xưởng Gỗ đã chiếm và Thôn đã nâng được đánh dấu xong ngay (`0.0`), để người chơi cũ không bị mất sản lượng.

### 3.2. Toạ độ lục giác

Dạng axial `(q, r)`, lục giác đỉnh nhọn. Khoảng cách: `(|dq| + |dr| + |dq + dr|) / 2`. Trại ở `(0, 0)`; vòng 1 gồm 6 ô; vòng 2 dùng 4 ô `(2,0) (-1,-1) (-2,2) (1,1)`.

### 3.3. Bản đồ thế giới

| Hạng mục | Giá trị |
| --- | --- |
Map 1-1 (Rừng Sương); các map khác xem `scripts/data/maps.gd`. SN-30: mọi map ×1,6 mỗi chiều so với M4. **SN11-03** ([30](30-spec-notes-dot-11.md)): thêm ×√3 mỗi chiều (diện tích ×3) — `maps.gd` giữ toạ độ cũ, `Maps.get_map()` trả bản đã nhân `MAP_SCALE` (D69).

| Hạng mục | Giá trị |
| --- | --- |
| Kích thước | 7205 × 4434 đơn vị (= 4160 × 2560 × √3; M4: 2600 × 1600) |
| Làng | tâm (637, 2217), bán kính 170 (bán kính giữ nguyên) |
| Hang boss | tâm (6346, 2217), bán kính 270 |
| Tường sương mù | x ≈ 6016 (tâm hang − 330) |
| Cấp quái | `zone_x` [720, 416] × √3: `1 + ⌊(x − 1247) / 721⌋`, giới hạn 1–6 |
| Số quái thường | `16 × diện tích / (2600 × 1600)`, trần **120** (1-1: 120 con, mật độ như trước); sinh thêm mỗi 1,2 giây, cách người chơi ≥ 450. Thảo dược, rương, mảng cỏ, cây cũng nhân theo diện tích. Quái / thảo dược / rương lúc nạp map dùng RNG riêng `_fill_rng` |
| Bãi quái | tối đa **10** quái mỗi bãi (`CAMP_MAX`, trước 6) |
| Sương che | ô 64 px (1-1: 113 × 70 ô), mở bán kính 360 quanh người chơi 5 lần/giây; vẽ bằng texture 1 điểm ảnh/ô lọc tuyến tính, `z_index` 50 (`world_view.FogLayer`). Save < v23 phủ sương lại (lưới đổi kích thước) |

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
- Kết quả gần nhất: **105/105 qua** (M7). Toàn bộ chạy khoảng 1 phút vì có 2 mô phỏng 15 phút chơi và 20 trận boss.
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
| D30 | Sương che là bitset trong `core/fog.gd`, view dựng lại texture khi `fog.version` đổi | Logic test được headless; texture nhỏ (≤ 70 × 40) dựng lại rẻ | Mép sương mờ theo ô 64 px, không mịn theo bán kính |
| D31 | Chuyển cường hoá = **đổi** cấp giữa 2 món khi đồ cũ cao hơn (Q47) | Không bao giờ mất cấp; mặc lại đồ cũ thì về như cũ | Đồ trong túi có thể mang cấp thấp hơn lúc nhặt |
| D32 | Test cân bằng boss (TL-B, TL-B2) tắt sinh quái thường (`GameWorld.field_spawn = false`) | Map ×1,6 có tới 40 quái: test chậm > 10 phút và số đo nhiễu theo RNG | Số đo chỉ phản ánh trận boss, không tính quái lạc vào hang |
| D33 | Boss hiếm khai báo bằng bảng `GameWorld.RARE_BOSSES` (map → loại, cấp, boss vùng phải ngã trước, đồ Cam, thoại); lịch lưu theo loại boss (`profile.rare_at`) | Thêm boss hiếm vùng mới = 1 dòng bảng + nhánh AI | Kỹ năng riêng của từng boss vẫn viết tay trong `_update_rare` / `_perform_attack` |
| D34 | Test cân bằng boss hiếm (M5-T3) cho bot mang 3 bình máu, uống khi dưới 40% HP | Boss hiếm khó hơn boss chương (200 đòn); người chơi thật luôn mang bình | Số đo không so trực tiếp được với TL-B/TL-B2 (không dùng bình) |
| D35 | Bài đo nhịp lên cấp (`PACE-*`) nằm trong `run_tests.gd` nhưng chỉ chạy khi gọi `--only=PACE` | Cần chạy lại mỗi lần chỉnh EXP mà không làm bộ test thường chậm thêm vài phút | Dễ quên chạy: M5-T5 kiểm nhanh ngân sách EXP bằng công thức để bắt lỗi lớn |
| D36 | Logic một chương nằm ở file riêng (`core/chapter3.gd`, hàm static nhận world); `game_world.gd` chỉ có dòng móc `Ch3.` | `game_world.gd` đã > 3.600 dòng, nhiều phiên cùng sửa | Truy cập hàm/hằng "riêng" của GameWorld qua `w._…` — đổi tên ở GameWorld phải tìm cả trong chapter3.gd |
| D37 | Cân bằng Thợ Săn theo cấp: AGI +0,6% tốc đánh (trần +20%), +0,25% chí mạng; Bộc Phá trên Mưa Tên ×0,6 (TL-B3) | AGI cộng 3 lợi ích nên tăng tuyến tính mạnh hơn STR/INT; cấp 29 Thợ Săn nhanh hơn Kiếm Khách 47% | Thợ Săn vùng 1 gần như không đổi; nếu thêm nguồn tốc đánh lớn cho Thợ Săn phải đo lại |
| D38 | Bộ điều phối chương `core/chapters.gd`: GameWorld chỉ gọi `Chapters.<hook>`; mỗi chương là 1 file `chapterN.gd` khai báo `HOOKS` (hàm nó có), `MAPS`, `NPCS`. Hook trả bool → dừng ở chương đầu tiên xử lý; hook hệ số → nhân dồn | 2 phiên cùng làm chương 4 và 5 song song; tránh sửa chồng game_world.gd | Danh sách chương có hook được lưu sẵn (`_cache`) vì hook gọi nhiều lần mỗi khung hình cho từng quái; thêm chương = thêm vào `MODULES` |
| D39 | Tiến hoá Thiên phú: `talent_level` là **cấp hiệu dụng** = Lv + 9 × `evo` (tối đa 28); chỉ phần hiển thị + luyện cấp dùng `Ch4.stage_level()` (1–10) | Mọi chỗ đang tính hiệu ứng theo `talent_level` (`tv`, `lv_value`, Stats, Items, Explore) tự đúng, không tụt sức mạnh (Q18) | Hiệu ứng riêng của dạng tiến hoá chưa có (Q55); thông báo mở hiệu ứng phụ chỉ ở dạng gốc |
| D40 | Chức 2 lưu ở trường riêng `profile.job2` (không ghi đè `job`) | Hiệu ứng chức 1 trong `chapter3.gd` kiểm `job` theo id — giữ nguyên được, chức 2 cộng thêm | `Classes.title(lớp, job, job2)` có thêm tham số |
| D41 | Boss "bất tử theo lượt" (Viêm Long) mở cửa sổ đánh theo **lượng sát thương** (15% HP hoặc tối đa 10 giây), không theo đồng hồ cố định | Thời gian trận tỉ lệ với sát thương — không khuếch đại chênh lệch giữa các lớp (TL-B5 36% → 19%) | Trận có thể dài hơn với người sát thương thấp (giới hạn 10 giây mỗi lần đáp) |
| D42 | Hook `input_filter(w, input)` (M9) thay **cả** phím của khung hình, gọi ngay sau `_travel_input` trong `GameWorld.update`; Bản Ngã biết người chơi vừa dùng kỹ năng nào bằng cách dò hồi chiêu `skill_cds[i]` nhảy lên (không móc vào `use_skill`) | Mất kiểm soát (chương 6) cần bỏ qua mọi phím, không chỉ hướng đi (`input_move`); dò hồi chiêu không đụng `use_skill` đang được viết lại ở SK1 | Kỹ năng không có hồi chiêu sẽ không bị sao chép; id kỹ năng mới (SK1) chưa có trong `Ch6.MIRROR_OF` thì Bản Ngã dùng Tia bóng |
| D60 | SN9-02: nhân vật = **file save riêng** cho từng ô (`save.json`, `save_2.json`…), `SaveSystem.save_path` là ô đang chọn; không thêm trường vào profile, không tăng version | Save cũ tự thành ô 1; mọi chỗ đang gọi `load_profile`/`save_profile` giữ nguyên | Màn Chọn nhân vật đọc trọn 5 file JSON để lấy tóm tắt (nhanh với 5 ô; nếu tăng nhiều ô nên ghi tóm tắt vào `slots.cfg`) |
| D61 | SN9-06: bãi quái **tính lúc nạp map** từ dải cấp + `zone_x` + băm `map_id:cấp` (`GameWorld.camps`), không khai báo trong `maps.gd`; 75% quái sinh trong bãi | Mọi map (kể cả chương mới) tự có bãi, vị trí cố định giữa các lần chơi, không phải sửa dữ liệu. Việc dời quái vào bãi dùng **RNG riêng** (`_camp_rng`, seed theo map) và chữ nổi mới dùng `_note` (không lệch ngẫu nhiên) — chuỗi `_rng` chính giữ nguyên, các test cân bằng (TL-B…) không đổi kết quả vì SN9 | Bãi có thể rơi vào địa hình xấu (dung nham, khoảng trời) — quái vẫn tránh qua hook `enemy_avoid`; muốn đặt tay thì thêm khoá `camps` vào map sau |
| D62 | SN9-03, SN9-09: `_apply_damage(e, dmg, crit, by_player, kind)` thêm `kind` (counter / burn / poison / dot) để tô màu; đòn của người chơi (và thiêu/độc của người chơi) ghi `_last_target` → `GameWorld.focus` | Một chỗ cho số sát thương và mục tiêu; tham số mặc định nên mọi lời gọi cũ giữ nguyên | Nguồn sát thương mới muốn màu riêng phải truyền `kind` |
| D64 | UI-27: khung giao diện bảng Nhân vật dùng **ảnh vẽ cắt từ ảnh mẫu của chủ dự án** (ngoại lệ với hướng pixel art sinh bằng code — docs 07), chỉ phần trang trí; chữ / số / chân dung / ô trang bị vẫn do game vẽ. Cắt bằng script (`tools/art/ui_cut.py`, ảnh gốc lưu ở `tools/art/src/`) để chạy lại được | Chủ dự án chọn "dùng trang trí từ ảnh" (28/10/2026) | Ảnh gốc 1536×1024 — màn hình lớn hơn 1366×768 hơi mềm; trộn nét vẽ với icon pixel. Chữ in sẵn được xoá bằng khuếch tán màu — đổi toạ độ cắt phải xem lại vùng xoá |
| D65 | AS (30/10): giữ AGI +0,15% tốc đánh (thử +0,5% làm lệch cân bằng lớp TL-B2…B6, J3 — Kiếm Khách/Thợ Săn tự tăng AGI theo cấp — nên bỏ). Hoạt ảnh đánh thường dài `gốc ÷ tốc đánh` (`GameWorld.basic_swing` → `Player.swing_len`; `world_view._swing_len` dùng độ dài mặc định khi kỹ năng đặt `swing` dài hơn). Trang Chỉ số hiện "đòn/giây" = tốc đánh ÷ `GameWorld.basic_interval(lớp)` | Hoạt ảnh vung cố định 0,16 giây và không có số đòn/giây nên người chơi không thấy tốc đánh thay đổi | Nếu muốn AGI cho tốc đánh rõ hơn: chỉ tăng cho điểm tự cộng, không cho phần tự tăng theo cấp |
| D63 | CS (docs/26): hệ 7 thuộc tính (thêm WIS, DEX). Thuộc tính = khởi tạo `Stats.START` (CR-001) + tự tăng `Stats.GROW` × (cấp − 1) + điểm; chỉ số = phần gốc theo cấp của lớp (`Stats.CLASS`) + thuộc tính × hệ số. Tấn công chỉ lấy từ thuộc tính chính của lớp (`CLASS[c].atk`); Tấn công gốc theo cấp `Stats.base_atk()` = `atkg` × (cấp − 1) + `atkx` từ cấp 31 + `LATE_ATK` từ cấp 81 (độ dốc theo lớp để giữ luật chênh ≤ 25% ở mọi vùng). Thay D47 | Số thuộc tính người chơi thấy giữ nguyên CR-001 mà chỉ số cuối vẫn trong thang quái hiện tại (hệ số nhỏ, phần gốc theo cấp hiện rõ trên trang Chỉ số) | Đổi `START`/`GROW` làm nhân vật mạnh/yếu thật — phải chạy lại TL-B…, SK2-T4, SK3-T4, TL-J3, M1-12. Save v19 tẩy điểm 1 lần (`Profile.cs_refunded`) |
| D66 | Đạo Tặc (30/10, Q169–Q170): `GameWorld.steal_cap()` = `Ch4.stage_level` (1–10) × cấp; `_try_steal` xét từng điểm theo thứ tự trần loài (`steal_species_cap(kind)`: `RARE_BOSSES` 10, `arch == "boss"` 9, còn lại 5) → `profile.stolen` → `profile.steal_bag` (≤ `STEAL_BAG_MAX`) → Đà Cướp `steal_buffs` [{stat, left}]. `_flush_steal_bag()` gọi sau thông báo lên cấp (để dòng "phần tăng của cấp" không lẫn điểm túi) và sau `level_talent()`. Đà Cướp cộng vào `Stats.derive` như điểm cướp tạm (`steal_buff_points()`), `_tick_steal_buffs` trong `update()` hết hạn thì `_refresh_stats`. Save v20 thêm `steal_bag`, `steal_log` | Không đổi chữ ký `Stats.derive`; trần loài suy ra từ dữ liệu quái nên sổ và lúc cướp luôn khớp | Boss mới phải có `arch: "boss"` (hoặc nằm trong `RARE_BOSSES`) mới được trần 9/10; Đà Cướp không lưu save |
| D67 | PV (30/10): kỹ năng bị động là module `core/passives.gd` trong `Chapters.MODULES` (khung hook D38, như D58); cấp lưu ở `profile.passive_levels`, tốn chung `skill_points`; `skill_reset` hoàn cả bị động. Bị động **không** tăng sát thương vào thanh Phá Thế | Ít lời gọi thẳng trong `game_world.gd` (4 chỗ); hook cũ `hit_mult` / `derive_*` đủ cho hầu hết hiệu ứng | Trận boss có ngưỡng vỡ Phá Thế: +15% Phá Thế làm Hộ Vệ hạ Viêm Long nhanh hơn 26% (docs/27 mục 5) — bị động mới đo bằng PV-T3 trung bình 2 seed |
| D68 | BK (31/10, [29](29-bi-kip-diem-ky-nang.md)): Bí Kíp rơi = +1 `skill_points` (`Skills2.drop_book(w)`); biến thể ✦ mở bằng `STAR_COST` = 2 điểm (`unlock_star`), `secret_books` giữ tên nhưng nghĩa là "✦ đã mở"; `skill_reset` gọi `reset_stars` (hoàn điểm, bỏ chọn ✦). Bỏ `book_shards` / `exchange_book`; save v24 đổi Mảnh cũ thành điểm (5 Mảnh = 1, làm tròn lên) | Một loại tài nguyên (Điểm Kỹ Năng) cho kỹ năng, bị động, ✦ — người chơi tự chọn; không còn Bí Kíp vô ích cho kỹ năng không dùng | `variant()` không kiểm `has_book`: khoá lại ✦ thì phải xoá lựa chọn ✦ trong `variants` (đã làm trong `reset_stars`) |
| D69 | SN11-03 (31/10, [30](30-spec-notes-dot-11.md)): map ×3 diện tích làm **một chỗ**: `Maps.MAPS` giữ toạ độ cũ, `Maps.get_map(id)` trả bản sao đã nhân `MAP_SCALE` = √3 (có cache) — `size`, `zone_x`, `safe.pos`, `arena.pos`, `stele3`, mảng điểm `POINT_LISTS`, mảng tròn `CIRCLE_LISTS` (đảo bay nhân cả bán kính; dung nham, ốc đảo, đất sụt giữ bán kính), vùng nước; số cây ×3. Bán kính làng / hang / NPC lệch tâm giữ nguyên. Hang phụ (`cave-*`) không đổi. **Mọi code đọc map qua `get_map` / `GameWorld.map`**; map mới có khoá toạ độ mới thì thêm vào `POINT_LISTS` / `CIRCLE_LISTS`. Hằng `GameWorld.WORLD_SIZE`, `VILLAGE_POS`, `ARENA_POS`, `GATE_X` × `MAP_SCALE`. Quái / thảo dược / rương lúc nạp map dùng `_fill_rng` (băm `fill:<map>`) để chuỗi `_r()` của trận đánh không đổi theo số quái. Đa giác nhỏ trong thế giới vẽ qua `SpriteLib.poly()` (vẽ quanh gốc rồi dời — toạ độ ~7000 px làm Godot tam giác hoá lỗi "Invalid polygon data"); `ElementIcon.draw` cũng vậy |
| D70 | M11 (31/10, [17](17-chuong-8.md) C8-10): hiệu lực Thiên phú là **một hệ số k** qua hook mới `talent_mult` (nhân dồn mọi module; `Chapters.talent_mult`). k đi vào: `GameWorld.tv()` (giá trị v1 < 1 → v × k; v1 ≥ 1 là hệ số nhân → 1 + (v − 1) × k), `Stats.derive` qua `bonus.talent_k` (Chapter8.`derive_bonus`: thưởng cấp Thiên phú, Long Mạch, Thần Thể, Mắt Ưng, Tay Nhanh), `Talents.suppressed` (k ≤ 0,5 → `has_sub` trả false), `_use_talent` khoá khi k = 0. Hồi chiêu L × `talent_cd_mult`. Hiệu Triệu đổi sang `Talents.lv_value` để hồi chiêu không giảm theo k. k đổi → `_refresh_stats` | Không phải sửa 23 chỗ `tv()` + 31 chỗ `profile.talent ==`; chương 9 (Hút Thiên phú của Ma Tôn, Tinh Quang Thủ Hộ +20%) dùng lại cùng hook | `Talents.suppressed` là biến tĩnh — module chương 8 đặt lại mỗi khung hình và khi nạp map; test gọi `Stats.derive` trực tiếp sau test chương 8 phải nạp lại world. Hiệu ứng chỉ kiểm `profile.talent == "x"` mà không qua `tv`/`has_sub` (ví dụ Khứu Giác thấy rương) vẫn còn khi bị Hút |
| D71 | M12 (01/11, [18](18-chuong-9.md) C9-10): hệ của quái có thể đổi lúc chạy — `Enemy.el_override` + `GameWorld.el_of(e)`; mọi chỗ đọc hệ quái (khắc hệ đòn người chơi, Ngũ Hành Linh Căn, biến thể hệ / Âm Dương ở `skills2.gd`, Mắt Nhân Sư, bị động, đạn quái, bảng tên, khung mục tiêu) đọc qua `el_of`. Hook mới `after_exp` (cuối `add_exp`) cho cấp sau 100; `tv()` nay nhân cả k > 1 (Hiến tế +20%). Endgame gọi thẳng từ GameWorld ở 6 chỗ (`Endgame.exp_mult / travel_mult / skill_cd_mult / potion_mult / gold_mult / enhance_bonus`) | Hệ tầng vùng 9, Ma Tôn GĐ3, Sứ Giả, Hư Ảnh đều đổi hệ — không thể sửa `Monsters.DEFS`. Một chỗ đọc hệ cho mọi hệ thống | Chỗ mới đọc hệ quái phải dùng `el_of` (đọc `Monsters.DEFS[e.kind].element` trực tiếp sẽ sai ở vùng 9) |
| D72 | SN12-02 (01/11, [31](31-de-xuat-thanh-ky-nang.md)): **7 ô kỹ năng** — `profile.loadout` 7 phần tử ("" = trống), ô 4/5 mở theo `profile.job` / `job2`, ô 6 (Tuyệt kỹ, phím G) từ cấp 45 chỉ nhận `ultimate` / `job3`. `GameWorld._valid_loadout` nâng bộ 4 ô cũ, bỏ id lạ / trùng; hồi chiêu nhớ theo id (`_cd_until`) khi rời ô. Đổi ô: vùng an toàn **hoặc** `time − _last_combat ≥ COMBAT_LOCK` (5 giây). Kỹ năng mới: so với ảnh chụp `_known_skills` mỗi khung hình (ảnh chụp lấy ở `_init` và khung hình đầu — nạp save / test dựng sẵn không báo), tự lắp ô trống, sự kiện `skill_unlock` có `slot`. Bộ 2: `loadout_alt` + `loadout_set`, đổi bằng `swap_loadout()`. Thanh HUD: ô ẩn không chiếm chỗ (`SkillBar` tính lại `_xs`), kéo-thả bằng `_get_drag_data` / `_can_drop_data` (bảng Kỹ năng có hàng ô thả riêng vì lớp phủ modal che HUD), chuột phải → `PopupMenu` |
| D73 | Rà soát 01–02/11 ([32](32-ra-soat-01-11.md)): **Thần Vực** — quái tháp mạnh thêm theo luỹ thừa mỗi tầng (`Endgame._tower_scale`: HP × `TOWER_HP_GROWTH`^tầng 1,14, Tấn công × `TOWER_ATK_GROWTH`^tầng 1,05), Thần Tướng HP × `TOWER_GUARD_HP` 3. **Âm thanh**: nhạc theo vùng `main.gd REGION_MUSIC` (an toàn `village`, hang `core`, boss vùng ≥ 7 `boss_final`); âm kỹ năng theo lớp `GameWorld.SKILL_SFX` / `skill_sfx()` (Tối thượng / Thần Kỹ `ultimate`), `unlock` khi mở kỹ năng, `portal` khi tới map. **Bảng lục địa** đóng khi đổi map (sự kiện `map`) |
| D74 | TP-05/13/14 ([33](33-thien-phu-phu-cong-huong.md)): Thiên phú phụ lưu `profile.subs` [{id, level}] (v28). Mọi hiệu ứng chính kiểm **`has_talent(id)` + `tvt(id, v1, v10)`** (cấp của chính Thiên phú đó + cộng hưởng chung ×1,1, nhân hiệu lực Thiên phú chương 8) — `tv()` = `tvt(Thiên phú chính)`; hiệu ứng phụ nhóm qua `TalentSlots.has_group_sub`. `Stats.derive` nhận giá trị tính sẵn (`bonus.talent_vals`, `dragon_val`, `combat_sub1/2`) nên chữ ký giữ nguyên. Kỹ năng L: `skill_talent()`. Đạo Tặc chỉ là Thiên phú chính (kiểm `profile.talent`). Lễ ô phụ dùng `Awakening` với bể lọc + `_loot_rng`; lượt giữ ở `GameWorld.sub_aw` (không lưu save) |
| D75 | SN14-02 ([31](31-de-xuat-thanh-ky-nang.md) mục SN14): `can_change_loadout(in_menu := false)`, `set_slot(slot, id, in_menu := false)`, `swap_loadout(in_menu := false)` — UI gọi từ bảng Kỹ năng (và thả kỹ năng từ cây lên thanh HUD, nguồn kéo chỉ có trong bảng) truyền `true` vì `main.gd` dừng thế giới khi có bảng mở (`time` không chạy, khoá `COMBAT_LOCK` không bao giờ hết). SN14-01: `drink_potion` không còn kiểm Hấp Huyết |
| D76 | BD-11 ([34](34-dungeon-cong-ngau-nhien.md)): bản đồ trong cổng id **`gate-<hạng>-<map cha>`** — hạng nằm trong id để `Maps.get_map` dựng được không cần hồ sơ; `Caves.is_cave` đúng cho cả `gate-…` nên cổng hưởng mọi xử lý của hang (không sương, không quái ngoài đồng, save ghi map cha, cổng ra). Cổng trên map cha là cổng `dgate` thêm động vào `GameWorld.portals` (`Gates.portal_of`) lúc nạp map / lúc mở cổng. RNG riêng `_gate_rng` (seed theo `play_seconds` lúc tạo GameWorld) — không đổi chuỗi `_rng`. Thời gian theo `play_seconds` |
| D59 | SH: linh thú Triệu Hồi Sư có HP (`Ally.hp/max_hp/hurt_t`). Quái chọn đánh linh thú qua một hook `Classes2.mob_vs_summon` gọi trong `_update_enemy` ngay sau ảo ảnh (Decoy): trả true thì quái đứng đánh linh thú bằng nhịp `windup + recover` của nó, bỏ qua AI đánh người chơi | Không phải sửa hơn 40 kiểu đòn quái / boss (đều nhắm vị trí người chơi) | Boss, boss hiếm, quái trận boss không đánh linh thú (Q143); quái đánh linh thú không dùng kỹ năng tinh anh trong lúc đó |
| D58 | J3: chuyển chức 3 của 3 lớp cũ là module `core/job3.gd` trong `Chapters.MODULES` (dùng lại khung hook D38, không có map / NPC); Thủ Hộ Thần, Vạn Linh Chi Chủ nằm trong `classes2.gd` (D50). Thần Kỹ là kỹ năng thường có `"job3": true` | Ít chỗ sửa `game_world.gd`: chỉ 5 lời gọi trực tiếp (chí mạng, choáng Phá Thế, bán kính, kỹ năng miễn phí, `skill_unlocked`) | `Classes2.cast` → `w.Job3.cast` (gọi qua GameWorld, tránh vòng preload) |
| D57 | CL1b: mức làm chậm theo từng hiệu ứng = `Enemy.slow_mul` đi kèm `slow_t` (0 = mức chung 0,6); hệ từng đợt của tối thượng nhiều hệ = `Skills2.State.wave_el` đặt tạm lúc đánh, `element_of` đọc | Không phải thêm loại hiệu ứng mới; mọi chỗ đang đặt `slow_t` giữ nguyên | `slow_mul` còn giữ nếu nguồn khác gia hạn `slow_t` trước khi hết — chấp nhận được |
| D56 | CL1 ([21](21-thiet-ke-lai-5-lop.md)): kỹ năng chỉ đổi tên/số **giữ id cũ**; kỹ năng thay cơ chế dùng id mới + `"replaces"` (`kiemy`←`guard`, `banglao`←`dichchuyen`), `Skills2.migrate_replaced` chuyển cấp/biến thể/Bí Kíp khi gọi `_ensure_loadout` | Save cũ không mất điểm kỹ năng, không cần tăng phiên bản save | Mã `guard_time` (Thiết Bích) giữ lại vì biến thể Kiên Cố dùng; Dịch Chuyển còn mã trong skills2.gd nhưng không lớp nào có |
| D52 | Đòn của linh thú Triệu Hồi Sư đi qua `GameWorld._hit_enemy` (như đòn người chơi: chí mạng, khắc hệ, biến thể, Phá Thế) với `skill_ctx` = id kỹ năng gọi, × hệ số linh thú × `SUMMON_HIT` 0,7; hệ số không nhân `skill_mul` | Cấp kỹ năng, biến thể, Bí Kíp, Thiên phú nhóm Triệu hồi áp đúng lên linh thú mà không viết công thức riêng | Linh thú cũng kích hoạt hiệu ứng "khi đánh trúng" của người chơi (Hấp Huyết, Thuần Thú Sư…); `cl2.ally_hit` đánh dấu đòn của linh thú để loại trừ khi cần (Liên Kết "mình +20%") |
| D51 | `Classes.DEFS[lớp].range` = `"melee"` / `"ranged"`, `basic.kind` (`slash` / `shot` / `fireball` / `spirit`), `auto` (mẫu Tự cộng điểm); `GameWorld.is_ranged()` đọc `range` | Thêm lớp không phải sửa các chỗ `is_hunter() or is_mage()` | Code mới nên dùng `is_ranged()` |
| D50 | Lớp thứ 4–5 sống trong `core/classes2.gd` (trạng thái `w.cl2`), GameWorld chỉ gọi hook | Giảm sửa chồng `game_world.gd` khi nhiều phiên làm song song (cùng lý do D38) | `GameWorld.Ally` thêm `factor/ranged/splash/rate/skill/perm`; `PlayerState` thêm `dash_skill/dash_dist` (Xung Phong lao 25 m, đòn lao mang đúng id kỹ năng) |
| D55 | UI-21: mẫu Tự cộng điểm nằm ở UI (`StatsPage.PRESETS` + `apply_preset` gọi `world.allocate` lặp), mẫu 0 gọi `GameWorld.auto_allocate`; lựa chọn chỉ giữ trong phiên (static var), không thêm trường save | Thiết kế mới có ô chọn mẫu; không muốn đụng save / GameWorld đang có phiên khác sửa | Thoát game là về mẫu 0; muốn nhớ qua phiên thì thêm trường profile sau |
| D49 | Đảo bay = **danh sách hình tròn** trong `maps.gd` (`islands`, `crumble`) + cầu là đoạn thẳng nối tâm 2 đảo (rộng 6 m); không dùng ảnh mặt nạ | Kiểm "đứng trên đất" rẻ (vài phép so khoảng cách mỗi khung hình), dễ test, quái/rương/cửa hang/cổng tự dời về đất bằng `land_point` | Hình đảo chỉ là hình tròn; muốn đảo méo phải ghép nhiều vòng tròn |
| D48 | Boss chương 7 (Cự Thần) điều khiển trọn trong hook `update_enemy` (tự quản windup/recover, chuỗi Thiên chuỳ 3 lần vung 1,2 giây) thay vì dùng `chain_left` của GameWorld | Chuỗi của GameWorld cố định khoảng nghỉ 0,4 giây (Bạch Hổ); Thiên chuỳ cần 1,2 giây mỗi lần để lớp cận chiến kịp chạy | Choáng (Phá Thế) vẫn để GameWorld xử lý: hook trả `false` khi `state == "stunned"` |
| D47 | *(Thay bằng D63 — CS, docs/26)* Chỉ số mặc định theo lớp (`Stats.BASE_STATS`, UI-19) tính như điểm thường nhưng phần nền theo lớp + cấp trừ đúng phần mặc định đóng góp | Trang Chỉ số hiện được "mặc định + điểm cộng" như game nhập vai quen thuộc mà **không đổi một con số nào** (TL-B…, PACE vẫn đúng) | Mặc định chỉ là cách trình bày lại phần nền; đổi `BASE_STATS` không làm nhân vật mạnh/yếu đi. Muốn mặc định có tác dụng thật thì phải bỏ phần trừ và cân lại |
| D46 | Hang phụ là **map sinh động** `cave-<id>` dùng chung `_load_map`/cổng/`travel()`, không phải lớp phủ trong map cha | Tái dùng toàn bộ hệ map (sương, sinh quái, vẽ, bản đồ nhỏ, chết hồi sinh ở cửa hang) — không phải viết vòng lặp riêng | Mọi chỗ dùng `map_id` làm khoá (sương, khai phá, `unlocked_maps`, save) phải loại trừ hang — gom ở `Caves.is_cave` |
| D45 | Cổng dịch chuyển (MP-09) **sinh từ dữ liệu map** (`core/portals.gd`), không khai báo tay từng map; đi qua cổng vẫn gọi `travel()` | Map mới (chương sau) tự có cổng; điều kiện, đi đường, test MP-T1… giữ nguyên | Vị trí cổng theo công thức (rìa trái/phải); map có địa hình đặc biệt (dung nham…) có thể cần chỉnh tay sau |
| D43 | Kỹ năng theo **ô lắp** (`profile.loadout` = id), mọi chỗ đọc kỹ năng đi qua `GameWorld.slot_skill(i)` | Đổi ô / thêm kỹ năng (SK2–SK3) không phải sửa code theo vị trí | Hồi chiêu `skill_cds[i]` vẫn theo ô — khi đổi ô phải đổi kèm |
| D44 | Mọi đòn của người chơi mang id kỹ năng nguồn (`GameWorld.skill_ctx`; `PlayerShot/RainZone/Trap/Meteor.skill`) | Biến thể kỹ năng (SK2) áp đúng cả đòn trễ (đạn bay, mưa tên, bẫy, thiên thạch) | Chỗ gây sát thương mới phải đặt `skill_ctx` (xem `skills2.gd`) |
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
