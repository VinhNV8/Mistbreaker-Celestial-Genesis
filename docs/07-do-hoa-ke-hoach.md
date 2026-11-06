# Đồ hoạ: kế hoạch và theo dõi (nhánh G)

| | |
| --- | --- |
| Dự án | Thiên Phú Khai Giới |
| Nguồn | [Kịch bản](kich-ban-game-thien-phu-khai-gioi.md) mục 9 (câu hỏi phong cách đồ hoạ) · [04 — Plan](04-ke-hoach-tien-do.md) mục 10 (DH-01…DH-13) |
| Trạng thái | **Đợt G1 xong** 20/10/2026 — 39/39 test qua, smoke test qua |
| Công cụ | Skill Claude Code `game-art` (`.claude/skills/game-art/`) + bộ sinh hình `tools/art/` (Python + Pillow) |

## 1. Nghiên cứu và quyết định

### 1.1. Các cách có hình ảnh

| Cách | Ưu | Nhược | Kết luận |
| --- | --- | --- | --- |
| Thuê/vẽ tay | Đẹp nhất, có bản sắc | Tốn tiền, chậm, chưa có hoạ sĩ | Để sau khi có ngân sách; bộ sinh hình hiện tại làm khung (kích thước, số frame) cho hoạ sĩ vẽ đè |
| AI tạo ảnh (Stable Diffusion, PixelLab…) | Nhanh, chi tiết | Cần API key và chi phí; nhân vật không đồng nhất giữa các frame; cần dọn điểm ảnh; vấn đề bản quyền chưa rõ | Không dùng ở bước này |
| Asset miễn phí (Kenney, OpenGameArt CC0) | Có ngay | Không khớp bối cảnh Hán-Việt; không có quái riêng của game | Không dùng |
| **Sinh bằng code (procedural pixel art)** | Miễn phí, chạy lại được, đồng nhất phong cách, thêm quái mới chỉ cần khai báo tham số | Mức chi tiết giới hạn | **Chọn** cho G1 |

### 1.2. Phong cách (chốt DH-01)

*(03/11/2026: Spec_Notes "giao diện pixel quá" → chủ dự án chọn **HD vector cel-shade sinh bằng code** (Q176 = B, Q177) — lộ trình UI-40…49 ở [35](35-de-xuat-giao-dien-moi.md); 03/11: Làng Thanh Thạch HD — UI-40b, [35 §9](35-de-xuat-giao-dien-moi.md). Bảng dưới là phong cách pixel G1, còn dùng cho hình chưa vẽ lại.)*

| Mục | Quyết định | Lý do |
| --- | --- | --- |
| Phong cách | **Pixel art, góc nhìn trên xuống chéo 3/4** | Hợp nhóm game tham chiếu ở kịch bản (Vampire Survivors, ARPG góc trên); sinh bằng code được; chạy nhẹ cả trên máy yếu và mobile |
| Hướng | Chỉ vẽ hướng **phải**, quay trái bằng lật ngang | Cách phổ biến của dòng survivors-like; giảm 4 lần số hình |
| Kích thước frame | Nhân vật 32×32 · quái thường 24×24 · boss 48×48 · icon 32×32 · ô đất 32×32 | Theo quy ước 16/32 px phổ biến; boss lớn gấp đôi để nổi bật |
| Phóng to | ×2 trong game (số nguyên, lọc Nearest) | Pixel art không bị nhoè; khớp bán kính va chạm hiện có (người chơi 16 → hình cao 64) |
| Bảng màu | Mỗi vật liệu 1 dải 4 màu (tối → sáng), ánh sáng từ trên trái, viền tối 1 px | Đồng nhất phong cách giữa mọi hình do code sinh |
| Phẩm chất đồ | Icon không tô màu phẩm chất; giao diện vẽ khung màu phẩm chất | 1 icon dùng cho cả 5 phẩm chất |
| Quái tinh anh, đồng minh | Dùng chung hình quái, thêm viền sáng/tô màu lúc chạy | Không phải vẽ thêm biến thể |

### 1.3. Hoạt ảnh

| Loại | Frame | Ghi chú |
| --- | --- | --- |
| idle | 2 | Nhấp nhô thở |
| run | 4 | |
| attack | 3 | Vung đòn; quái dùng khi vào trạng thái báo hiệu (windup) |
| hurt | 1 | |
| death | 3 | Ngã, mờ dần |

Mỗi hình là 1 sheet PNG: mỗi hàng 1 hoạt ảnh, mỗi cột 1 frame. Thông tin cắt frame ghi trong `godot/assets/art_manifest.json`.

## 2. Hạng mục theo dõi

Ký hiệu như [04](04-ke-hoach-tien-do.md): ✅ xong · 🟡 một phần · ⬜ chưa làm.

### 2.1. Công cụ

| Mã | Hạng mục | Trạng thái | Ghi chú |
| --- | --- | --- | --- |
| AR-01 | Thư viện vẽ pixel: dải màu, hình cơ bản, tự viền, tự đổ bóng, xuất sheet | ✅ | `tools/art/pixel.py` |
| AR-02 | Bộ dựng nhân vật hình người theo tham số (tóc, áo, vũ khí, tư thế) | ✅ | `tools/art/builders.py` |
| AR-03 | Bộ dựng quái theo dáng: 4 chân, nấm/khối, hồn bay, người | ✅ | Thêm quái mới ở tài liệu 06 chỉ cần khai báo |
| AR-04 | Bộ dựng icon: trang bị, tài nguyên, kỹ năng, Thiên phú | ✅ | |
| AR-05 | Bộ dựng môi trường: ô đất, cây, nhà, Bia Đá, rương, thảo dược | ✅ | |
| AR-06 | Lệnh sinh tất cả + bảng xem trước (contact sheet) + manifest | ✅ | `python tools/art/build_all.py` |
| AR-07 | Skill Claude Code `game-art`: quy trình thêm hình mới | ✅ | `.claude/skills/game-art/SKILL.md` |

### 2.2. Hình ảnh (nội dung đang có trong game + M3)

| Mã | Hạng mục | Liên kết 04 | Trạng thái | Ghi chú |
| --- | --- | --- | --- | --- |
| AR-10 | Kiếm Khách: idle, run, attack, hurt, death | DH-02 | ✅ | |
| AR-11 | Thợ Săn (cung): idle, run, attack, hurt, death | DH-03 | ✅ | Sprite xong; hiện trong game khi có lớp Thợ Săn (M3) |
| AR-12 | Sói Sương, Nấm Độc, Tinh Linh Sương | DH-04 | ✅ | |
| AR-13 | Mộc Tinh (quái mới M3) | DH-04 | ✅ | Sprite xong; vào game khi thêm quái ở M3 |
| AR-14 | Boss Sói Chúa Hư Vô (48×48) | DH-05 | ✅ | Giai đoạn 2 tô đỏ lúc chạy |
| AR-15 | Đồng minh: thú cưng, lính bóng tối | DH-06 | ✅ | Dùng hình quái + tô màu lúc chạy |
| AR-16 | Môi trường Rừng Sương, Làng Thanh Thạch | DH-07 | ✅ | |
| AR-17 | Icon 8 ô trang bị + đồ Cam Nanh Sói Chúa | DH-09 | ✅ | |
| AR-18 | Icon tài nguyên: vàng, gỗ, Đá Cường Hoá, Tinh Hoa, Tinh Kim, Đuốc, thảo dược, bình máu | DH-09 | ✅ | |
| AR-19 | Icon 20 Thiên phú | DH-09 | ✅ | |
| AR-20 | Icon kỹ năng: Chém, Xoáy Kiếm, Né, Bình máu | DH-09 | ✅ | Kỹ năng L dùng icon Thiên phú |
| AR-21 | Hiệu ứng: đạn bào tử, tia trúng đòn | DH-10 | ✅ | Chém/Xoáy Kiếm giữ vẽ vector (đã đẹp, đổi màu theo hệ) |

### 2.3. Đưa vào game

| Mã | Hạng mục | Trạng thái | Ghi chú |
| --- | --- | --- | --- |
| AR-30 | `sprite_lib.gd`: nạp manifest, vẽ frame, lật ngang | ✅ | Không đổi logic game (quyết định D2, D6) |
| AR-31 | `world_view.gd` vẽ người chơi, quái, boss, đồng minh bằng sprite | ✅ | Giữ vòng hạng Thiên phú, thanh máu, nhãn hệ |
| AR-32 | `world_view.gd` vẽ đất, cây, làng, rương, thảo dược, vật rơi bằng sprite | ✅ | |
| AR-33 | Giao diện hiện icon: túi đồ, ô trang bị, ô kỹ năng HUD, bảng Thiên phú | ✅ | |
| AR-34 | Lọc Nearest cho toàn dự án; nạp được cả khi chưa import | ✅ | |
| AR-35 | Test: mọi id trong dữ liệu (quái, Thiên phú, ô đồ) có hình; smoke test chụp màn hình | ✅ | |
| AR-36 | Cập nhật 02, 04, README | ✅ | |

### 2.4. Để sau (ngoài G1)

| Mã | Hạng mục | Đợt |
| --- | --- | --- |
| AR-40 | Quái và boss vùng 2 (tài liệu 06) | M4 |
| AR-41 | ✅ 8 icon kỹ năng M3, mũi tên, tên xuyên phá, kiếm khí, bẫy, sprite Nấm Con (20/10/2026) | M3 |
| AR-42 | Khung giao diện có art, font chính thức (DH-11) | G2 |
| AR-43 | Âm thanh, nhạc (DH-12, DH-13) | G2 — 01/11: nhạc riêng 9 vùng + boss cuối, âm kỹ năng theo lớp ([32](32-ra-soat-01-11.md)) |
| AR-44 | Thay hình sinh bằng code bằng hình hoạ sĩ vẽ (giữ kích thước, manifest). ✅ Phần nhân vật 5 lớp (27/10/2026): sprite sheet chủ dự án cung cấp lưu ở `tools/art/src/class-sheet.png`, `tools/art/class_sheet.py` tách nền + cắt hàng idle 5/4 · run 4 · attack 2–4 · hurt 5/4 · death 4 frame, thu nhỏ ×0,62 về lưới pixel, ghi `sprites/pc-<lớp>.png` (khung 40–56 × 50, gốc ở chân, `size_mul` 0,85). Hàng kỹ năng/tối thượng của sheet không dùng (hiệu ứng do game vẽ). `SpriteLib.hero_sprite/draw_hero` ưu tiên `pc-<lớp>`; khi đó ngoại hình (giới tính, da, tóc) không đổi hình thân. ✅ Icon kỹ năng (27/10/2026): `tools/art/class_skill_icons.py` cắt 20 icon từ `tools/art/src/class-skills.png` (dò viền sáng từng ô, lấy phần trong, 48×48), ghi đè icon vẽ bằng code: Kiếm Khách `wave` `lientram` `kiemy` `vankiem` · Cung Thủ `pierce` `rain` `lanban` `thientien` · Pháp Sư `fireball` (đánh thường Hỏa Cầu) `banglao` `chain` `thienhoa` · Hộ Vệ `khienthep` `khieukhich` `chandia` `thanhbatdiet` · Triệu Hồi Sư `soibong` `tieuquy` `lienket` `quandoan`. `classes.gd`: Kiếm Ý dùng icon `kiemy` (trước mượn `kiemvu`), Băng Lao dùng `banglao` (trước mượn `bangphong`). ✅ Kiểu hình (27/10/2026): ngoại hình có `style` — "Hình lớp" (mặc định, kể cả save cũ không có khoá này) dùng `pc-<lớp>`; "Tuỳ biến" dùng thân + tóc ghép (giới tính, da, tóc). Màn Tạo nhân vật thêm hàng "Kiểu hình", làm mờ giới tính/da/tóc khi đang chọn Hình lớp. ✅ Màn chọn lớp: thẻ vẽ `pc-<lớp>` có hoạt ảnh trên bệ (cứ 4 giây vung đòn); icon `portrait-<lớp>` = chân dung bán thân ở đầu mỗi cột sheet (74×74, `class_sheet.busts()`). ✅ Hiệu ứng kỹ năng: 10 mảnh `env` "fx-sheet-*" tách từ hàng kỹ năng/tối thượng (`class_sheet.FX`, nền ước lượng từ viền hộp cắt), vẽ ở `view/class_fx.gd`: Hỏa Cầu (đạn đánh thường Pháp Sư), Trảm Phong, Xuyên Tâm Tiễn, Băng Lao (đạn, xoay theo hướng bay), Thiên Tiễn (tên trời rơi thẳng), thiên thạch lửa (Thiên Thạch + đợt lửa Thiên Tai), đợt băng Thiên Tai, hào quang Kiếm Ý, kiếm khí Vạn Kiếm Quy Tông cắm quanh người; `fx-sheet-khienthep` chờ lớp Hộ Vệ. Thiếu hình thì vẽ kiểu cũ. Test AR-44 | Khi có ngân sách |
| AR-45b | ✅ Hình thi triển 14 kỹ năng Kiếm Khách vào game (02/11/2026, chủ dự án duyệt bộ review `docs/design/skills/kiem-khach`). Trảm Phong / Kiếm Ý / Vạn Kiếm Quy Tông giữ hình cắt từ master sheet (`fx-sheet-*`, AR-44). 11 kỹ năng còn lại dùng keyframe 32×32 `env/vfx-<id>` của `tools/art/skill_vfx.py` (nay được `env.py` đăng ký vào manifest — trước đó PNG có trong thư mục nhưng không có trong manifest, game không dùng; thêm `vfx-nhatkiem`). `view/class_fx.gd` `CAST_FX`: vẽ khi thi triển theo nhịp charge → cast → impact — quanh thân (Xoáy Kiếm, Hống Kiếm, Huyết Bạo; Kiếm Vũ 2 giây, Kiếm Vực 4 giây mờ + xoay) hoặc phía trước theo hướng nhìn (Đột Kích, Nguyệt Ảnh Liên Trảm, Phi Kiếm, Thánh Kiếm Trảm, Huyết Ảnh, Nhất Kiếm Khai Thiên — tụ lực 0,5 giây rồi đường chém xẻ trời). Tối đa 85% đậm, vòng quanh thân thêm ×0,75 để thấy nhân vật. Đạn Phi Kiếm (xanh bạc, ×0,8) và Thánh Kiếm Trảm (vàng, ×1,35) dùng trăng khuyết Trảm Phong. world_view nhận ra lúc thi triển qua bước nhảy hồi chiêu của ô (cùng kỹ năng trong ô; đổi bộ / nạp save thì bỏ qua) — không đổi logic. Test AR-45b; smoke `03e-kiem-vfx-spin`, `03f-kiem-vfx-nhatkiem` | Xong |
| AR-45d | ✅ **AR-45d (03/11/2026, thay AR-45c):** 10 kỹ năng Kiếm Khách (Xoáy Kiếm, Đột Kích, Hống Kiếm, Kiếm Vũ, Phi Kiếm, Thánh Kiếm Trảm, Kiếm Vực, Huyết Bạo, Huyết Ảnh, Nhất Kiếm Khai Thiên) **dàn dựng chuyển động theo cơ chế thật** bằng chính các mảnh hình gốc mà bộ review `docs/design/skills/kiem-khach` ghép từ master sheet (trăng khuyết Trảm Phong, vụ nổ Kiếm Ý, thanh kiếm Vạn Kiếm): Xoáy Kiếm 4 trăng khuyết xoay 2 vòng nở ra 12,5 m; Đột Kích / Huyết Ảnh vệt trăng khuyết theo đường lao thật; Hống Kiếm / Huyết Bạo tụ lực rồi nổ + 8 trăng khuyết toả ra đủ bán kính; Kiếm Vũ 4 kiếm bay quanh 2 giây + nhát chém mỗi nhịp; Phi Kiếm / Thánh Kiếm loé lực ở mũi kiếm (kiếm bay vẽ như đạn); Kiếm Vực vòng vực đi theo người, 8 kiếm cắm quanh mép, kiếm rơi cắm xuống mỗi nhịp 0,5 giây (trước đây bị vẽ nhầm thành Mưa Băng); Nhất Kiếm tụ lực 0,5 giây rồi chuỗi trăng khuyết chạy dọc vệt chém 40 m. AR-45c (3 ảnh tĩnh của storyboard dán cạnh nhân vật) đã gỡ vì chủ dự án thấy "không giống ra chiêu trong game". Trảm Phong, Kiếm Ý, Nguyệt Ảnh Liên Trảm, Vạn Kiếm Quy Tông giữ hình cũ. Test AR45d-T1; smoke `03f2…03f7` |
| AR-46 | 🟡 **Vertical slice source VFX (03/11/2026):** `tools/art/skill_source_vfx.py` sinh 15 frame 64×64 (`fx-skill-<id>-p0/p1/p2`) cho Đột Kích, Tên Nảy, Thiên Thạch, Thiết Chuỳ Phá Địa, Gọi Ấu Long. `build_all.py` ghi asset vào manifest; `class_fx.gd` render pha cast, marker nảy và chuỗi telegraph/rơi/impact của Thiên Thạch theo state gameplay thật. Không đổi damage, hitbox hay cooldown. 🟡 Còn 65 skill cần source VFX riêng. |
| FX-1 | ✅ **Thiết kế lại VFX 70 kỹ năng (03/11/2026, [36](36-thiet-ke-lai-vfx-ky-nang.md))** theo board Pinterest "game skill effects": cel-shade 4 dải (viền tối → bão hoà → sáng → lõi trắng) + glow cộng lượng tử 3 bậc, nhịp 12 khung (4 tụ lực · phát · va chạm giữ 190 ms · 6 tan), bản sắc màu/hình khối riêng 5 lớp. `tools/art/skill_fx_kit.py` (nguyên tố: trăng khuyết, sao va chạm, vòng, sét, cột sáng, vòm khiên, tia lửa, khói) + `tools/art/skill_fx_design.py` (11 nguyên mẫu, 70 kỹ năng) xuất `docs/design/skills-fx/<lớp>/NN-<id>.gif/.png` + bảng tổng lớp. Sprite nhân vật/linh thú/quái dán nguyên khung gốc làm ngữ cảnh, **không vẽ lại**; không ghi `godot/assets`, không thay hình đã duyệt (AR-44/45b/45d/46). Chủ dự án duyệt 03/11 (Q180 cả 70 · Q181 song song · Q182 HD · Q183 theo đề xuất); bản duyệt vẽ lại HD (×6 rồi thu về ×3, Lanczos) | Xong |
| FX-2…4 | ✅ **FX-1 trong game (03/11/2026, [36 §9](36-thiet-ke-lai-vfx-ky-nang.md))**: `view/fx1_kit.gd` (nguyên tố, Painter đếm được ở headless) + `view/fx1.gd` (70 kỹ năng, chính sách song song, dàn cảnh thi triển, lớp phủ đạn / tia / vùng / thiên thạch / tường lửa / cầu sấm / đồ đằng / bẫy / khiên bay / búa / mũi tên sao / 5 cầu Ngũ Hành / nghi thức gọi linh thú / sao trúng đòn) vẽ vector HD ở toạ độ thế giới; glow ở node con `Fx1Glow` (BLEND_MODE_ADD). Cài đặt "Hiệu ứng kỹ năng": **FX-1 cả 70 kỹ năng (mặc định, chủ dự án chọn 03/11)** / FX-1 giữ 22 kỹ năng đã duyệt (`Fx1.REPLACE` để đổi) / Hình cũ. Đưa vào theo thứ tự Pháp Sư → Thợ Săn → Triệu Hồi Sư → Hộ Vệ → Kiếm Khách, mỗi lớp kiểm bằng smoke `tests/fx1_smoke.gd`. **Hiệu năng / đánh trúng / cảnh báo đòn quái (§9.7–9.10):** 1,65 ms/khung thực tế; rung + khựng đòn + âm nổ đúng khung va chạm; cài đặt rung / giảm chớp; vòng cảnh báo đòn quái dạng tròn theo FX-1; §9.11: cảnh báo của từng chương 5–9 và dạng nón / đường cũng theo FX-1. §9.12: mặc định kiểu tự nhiên như ARPG (động tác cho quái thường, vết đất theo chất liệu cho tinh anh / boss), "Rõ ràng" là tuỳ chọn. **Khớp thiết kế (§9.6):** mặt đất 3/4, nhịp 12 khung, Xoáy Kiếm port đúng `a_spin`, bỏ hình cũ chồng lên, Thiên Tai 3 pha, Triệu Hồi Xương; ảnh so sánh thiết kế ↔ trong game ở `docs/design/skills-fx-ingame`. Test FX1-T1 | Xong |
| IC-1 | ✅ **Icon kỹ năng (03/11/2026, [37](37-icon-ky-nang.md))**: 51 icon vẽ bằng code vẽ lại bằng bộ nguyên tố FX-1 (`tools/art/skill_icons_fx.py`, 256 → 128 px), nền tối toả màu kỹ năng như 19 icon vẽ tay (giữ nguyên), linh thú = bóng từ sprite thật. Bản duyệt `docs/design/skill-icons` + ảnh thanh kỹ năng thật (`tests/ic1_bar.gd`). Chủ dự án duyệt (Q184) → áp dụng qua lớp phủ `manifest.hd.icons` (`--apply`, đã nối vào `tools/art/hd/build_hd.py`); tắt Đồ hoạ HD về icon cũ. **§6:** thêm 20 icon bị động + icon tab "Bị động" (`tools/art/passive_icons_fx.py`). **§7 IC-2 (04/11):** 20 icon Thiên phú (huy hiệu tròn, viền màu hạng; `tools/art/talent_icons_fx.py`) + 18 icon trang bị (Bùa hộ mệnh + 17 món độc nhất; cùng phong cách 7 icon UI-40, `tools/art/hd/items_hd_more.py`). **§8:** 14 icon tài nguyên + 24 icon chỉ số (`tools/art/hd/res_stat_hd.py`); chân dung giữ nguyên. Test IC1-T1 | Xong |
| MD-1 | ✅ **Thiết kế lại toàn bộ quái (04/11/2026, [39](39-thiet-ke-lai-quai-vat.md))** — giai đoạn G3 / UI-47 của [35](35-de-xuat-giao-dien-moi.md). Nghiên cứu ảnh mẫu Pinterest (bảng ~100 nhân vật cartoon vẽ tay) → 10 đặc điểm phong cách, quy chuẩn S1–S10 + họ màu theo vùng, ghi thành skill `.claude/skills/monster-design`. Bộ dựng HD `tools/art/hd/mon_kit.py` (không gian 96 đơn vị, 3 lớp, chuyển sáng dọc, rim, hurt / death chung), `mon_biped.py`, `mon_beast.py`, `mon_misc.py`, danh mục `mon_catalog.py` (94 mục + ý tưởng), `mon_build.py` (tự hiệu chỉnh `px` / `size_mul` theo bản pixel, ảnh duyệt `docs/design/monsters/vung-*.png`). 85 quái / tinh anh / boss vào game qua `manifest.hd.sprites` (thay Sói Sương / Sói Chúa G0); 9 linh thú chỉ có bản duyệt (Q190). Test MD1-T1 | Xong, chờ duyệt |
| EQ-HD | 🧪 **Icon trang bị HD (05/11/2026, [40](40-icon-trang-bi.md))** — skill `equipment-design`: góc 3/4, kim loại có vệt bóng, ngọc khảm, bậc phẩm chất = bậc chất liệu + độ cầu kỳ, bộ trang bị có bảng màu + hoạ tiết nền; 336 icon `eq-*` (lớp phủ HD), vũ khí theo lớp (kiếm / cung / trượng / chùy / linh châu); ảnh duyệt [design/equipment](design/equipment/); chờ duyệt Q193 |
| EQ-HD v2 + UI-64…66 | ✅ **Giao diện xem đồ (05/11/2026, [42](42-giao-dien-xem-do.md))**: icon trang bị có khối (lớp "tranh vẽ"), quầng sáng tách lớp; ô đồ theo bậc phẩm chất; thẻ thông tin trang bị mới; ảnh trước / sau [design/equipment](design/equipment/) |

### 2.5. Bổ sung ở đợt C1 (08)

| Mã | Hạng mục | Trạng thái | Ghi chú |
| --- | --- | --- | --- |
| AR-50 | Ngoại hình tuỳ chọn: 12 sheet thân (2 lớp × 2 giới tính × 3 da) + 8 sheet tóc xám (2 lớp × 4 kiểu) | ✅ | `humanoid(layer="base"/"hair")`, tô màu tóc lúc vẽ (D22) |
| AR-51 | NPC: Trưởng làng Thạch Lão, Thương nhân | ✅ | Đứng trong làng, chân dung hộp thoại |
| AR-52 | Boss hiếm Lão Thụ Sương Mù (×2,2), Gốc Rễ, icon Vỏ Lão Thụ | ✅ | Dáng treant + `size_mul` |
| AR-53 | Hiệu ứng: cường hoá theo bậc (N8), Bia Đá theo hạng, Rễ Trói, Lá Độc, vũng độc, cảnh mở đầu, bản đồ lục địa | ✅ | Vẽ vector bằng `_draw` |
| AR-54 | Âm thanh 16 hiệu ứng + 4 nhạc nền | ✅ | `tools/audio` (sinh bằng code, phiên game-bc) |
| AR-55 | Pháp Sư (SN-06): sprite `hero-phap-su` + 6 sheet thân + 4 sheet tóc (áo choàng dài `robe`, trượng ngọc `weapon="staff"`, khung đánh = giơ trượng, ngọc sáng); 5 icon kỹ năng `fireball`, `chain`, `nova`, `meteor`, `barrier` | ✅ | `humanoid` thêm `robe`, `orb`; hiệu ứng cầu lửa, sét, vòng băng, thiên thạch, khiên vẽ vector trong `world_view` |
| AR-56 | Sương che bản đồ (SN-31) | ✅ | Texture 1 điểm ảnh/ô, lọc tuyến tính — không cần hình |
| AR-57 | Khung giao diện (DH-11): thanh kỹ năng, khung bảng phủ + khung HUD, nút, font Be Vietnam Pro | ✅ | `ui/skill_bar.gd`, `ui/frame_box.gd` vẽ bằng code; font tải từ Google Fonts (OFL) |
| AR-58 | Vùng 3 (M6, docs/10): builder mới `insect` (Bọ Cát, Bọ Hung), `snake` (Rắn Đồi Cát), `scorpion` (Bọ Cạp Sa Hoàng 48 px); Xác Ướp, Thủ Lĩnh Xác Ướp, Pháp Sư Cát (humanoid robe/staff), Nhân Sư Đá (quadruped cát + bờm vàng); NPC Sa Lão, A Mộc, Thạch Thủ; nền cát/cát đỏ/phế tích, đá đỏ (bóng râm), xương rồng, cọ, ốc đảo, cột di tích, lều; icon Đuôi Sa Hoàng, Mắt Nhân Sư; dải màu `sand`, `sand_red`, `bandage`, `chitin` | ✅ | Ngày/đêm, bão cát, ụ cát khi chui, cột Câu Đố vẽ vector trong `world_view` |
| AR-59 | Vùng 4 (M7, docs/11) — `tools/art/region4.py`: builder `frog` (Ếch Độc), `croc` (Cá Sấu Bùn, Cá Sấu Chúa có vương miện); Đỉa / Thuỷ Quái / Đầu Thuỷ Quái (builder rắn, dải màu đỉa / nước), Hồn Ma, Mộng Châu (wisp), Phù Thuỷ Đầm Lầy, Nữ Vương Phệ Mộng, NPC Lão Ngư, Lam Nhi, Tinh Quang Sứ; nền đầm, cây chết, lau sậy, lá súng, Bọc Mộng; icon Gối Mộng, Vảy Thất Đầu | ✅ | Nước đầm, cồn đất, gợn nước, mưa độc, gốc đầu Thất Đầu, vòng sáng, giấc mơ vẽ vector trong `world_view` |
| AR-60 | Vùng 5 (M8, docs/12) — **file riêng `tools/art/region5.py`** (catalog/icons/env chỉ gọi `register_*`, để chương 4 thêm AR-59 song song không đụng): builder mới `dragon` (thú 4 chân + cánh màng phía sau — Viêm Long, Rồng Non Lửa) và `phoenix` (chim + hào quang + đuôi lửa — Phượng Hoàng Tro); Thằn Lằn Lửa, Người Đá Dung Nham (humanoid đá), Mảnh Đá (insect), Linh Hồn Lửa (wisp), Pháp Sư Hoả Diệm, Thợ Rèn Hư Vô, Lính/Đội Trưởng Kim Luân, Xương Nô (Tử Linh Sư); NPC Xích Đồng, Kim Phú, Liệt Diễm, Tiểu Hoả; nền dung nham/tro/đá đen, đá dung nham, cây cháy, Đá Nổi, miệng phun, lò rèn, thiên thạch; icon Long Tâm, Lông Phượng, Tinh Thạch, Bình Nước Thánh, kỹ năng Long Tức; dải màu `lava`, `basalt`, `ash`, `ember`, `bone` | ✅ | Hình xong trước code (code M8 chờ M7) |
| AR-61 | Vùng 6 (M9, docs/14) — file riêng `tools/art/region6.py`: builder mới `mirror` (Gương Băng đứng, khung bạc); Sói Băng, Người Tuyết, Tinh Linh Băng (wisp), Cung Thủ Băng, Gấu Băng Khổng Lồ, Pháp Sư Bão Tuyết, Bản Ngã Bóng Tối (humanoid đen tím — trong game vẽ bằng dáng lớp người chơi tô đen, không mặt), Ảnh Bóng, Long Băng Bắc Cực (builder `dragon` của vùng 5); NPC Tuyết Nga, Lão Hàn (Lam Nhi dùng lại hình vùng 4); nền tuyết/băng, thông phủ tuyết, đá băng, gò tuyết, lửa trại, Đèn Cực Quang (tắt/thắp), Gương Băng; icon Gương Bản Ngã, Vảy Long Băng, Than Hồng, kỹ năng Kính Ảnh; dải màu `snow`, `ice`, `frost`, `shadow`, `aurora`, `fur_snow` | ✅ | |
| AR-62 | Vùng 7 (M10, chương 7) — file riêng `tools/art/region7.py`: builder mới `colossus` (người khổng lồ đá – kim loại 48×48 cầm chuỳ, lõi vàng ngực, mắt xanh; attack giơ chuỳ → nện) cho Thiên Không Cự Thần; Đại Bàng Mây (bird), Người Gỗ Đảo Bay (treant), Tiên Gió, Hiệp Sĩ Thiên Không, Thủ Hộ Đảo (humanoid), Rồng Mây (dragon), Kỳ Lân Mây (quadruped); nền cỏ đảo bay / cẩm thạch / cầu gió, mây mép đảo, cây rừng treo, cột Thiên Cung, Cảng Khí Cầu; icon Búa Cự Thần, Sừng Kỳ Lân; dải màu `cloud`, `sky`, `sky_gold`, `marble`, `colossus`, `leaf_sky`. Danh sách quái theo docs/06 §Vùng 7 | ✅ | Hình xong trước code (chờ spec docs/16 của game-ca) |
| AR-63 | UI-21 — `tools/art/stat_icons.py`: 21 icon `stat-*` 32×32 (5 chỉ số gốc STR nắm đấm · AGI giày · INT sách · VIT khiên · LUK cỏ 4 lá; chỉ số chiến đấu atk/def/hp/mp/aspd/crit/critdmg/eva/regen/skill/drop/move/res; nút respec/auto; huy hiệu bộ đồ `set`), đăng ký qua `icons.STAT_ICONS` | ✅ | Bảng Nhân vật, test UI-21 |
| AR-64 | UI-22 — `tools/art/portraits.py`: 5 chân dung lớn 64×72 (chibi đầu to, quay 3/4 phải, tư thế chiến đấu) cho màn chọn lớp: Kiếm Khách (tóc đen nhọn, giáp tối, khăn + áo choàng đỏ, kiếm đỏ rực), Thợ Săn (mũ trùm xanh, tóc vàng, cung + tên xanh sáng), Pháp Sư (mũ phù thuỷ tím, tóc bạc, trượng cầu tím), Hộ Vệ (giáp tấm, mũ trụ lông đỏ, khiên chữ thập vàng, chuỳ), Triệu Hồi Sư (tóc bạc, áo choàng tím đen, dơi + sói linh hồn); ghi icon `portrait-<lớp>`. Chỉ dùng ở giao diện — không đổi sprite 32×32 trong trận | ✅ | Màn chọn lớp, test UI-22 |
| AR-65 | Vùng 8 (M11, docs/17) — file riêng `tools/art/region8.py`: builder mới `void_eye` (con mắt lơ lửng, đồng tử hồng sáng, xúc tu bóng) cho Mắt Hư Vô; Bóng Hư Vô, Kẻ Nuốt Thiên Phú, Giáp Sĩ Hư Vô, Tư Tế Hư Vô, Quái Vật Không Mặt (mặt trống, khiên bạc), Giáo Chủ Hư Vô (áo choàng đen viền vàng, mặt bạc, hào quang vàng đốm Thiên phú) (humanoid); Hư Vô Thú (quadruped 48); Lồng Hư Vô, Trụ Phong Ấn (`void_pylon` của vùng 7); NPC Tổ Sư (5 Tổ Sư dùng chung); nền vực `tile-abyss`, Cột Đá Hư Vô `void-stone`, Đèn Tinh Quang (tắt/sáng); icon Ấn Hư Vô, Nanh Hư Vô, Đèn Lồng Tinh Quang `res-lantern`, Lõi Hư Vô `res-void_core`; dải màu `abyss`, `silver`, `starlight` | ✅ | Duyệt bằng mắt 31/10 |
| AR-66 | Vùng 9 (M12, docs/18) — file riêng `tools/art/region9.py`: Thiên Binh Ngũ Hành, Thiên Tướng, Ngũ Hành Sứ Giả, Ma Tôn Vô Diện + phân thân (giáp đen không mặt, hào quang tím), Thiên Đạo Hư Ảnh (humanoid); Tàn Hồn Khai Giới Giả (wisp); Thiên Mã, Ngũ Hành Linh Thú (quadruped); nền ngọc `tile-heaven`, cột ngọc `heaven-pillar-*`; icon Mặt Nạ Vô Diện; dải màu `jade`, `heaven_gold`, `void_black`, `spirit` | ✅ | Duyệt bằng mắt 01/11 |

### 2.6. Lớp thứ 4–5 (LH1 / LH2, [19](19-lop-ho-ve-trieu-hoi-su.md))

| Mã | Hạng mục | Trạng thái |
| --- | --- | --- |
| AR-70 | Hình tạm Hộ Vệ (`hero-ho-ve`, thân × giới tính × da + 4 tóc): giáp thép, áo choàng lam, khiên tròn viền vàng (`shield`), chùy (`weapon: mace`) | ✅ — dùng khi người chơi chọn ngoại hình "Tuỳ biến"; mặc định là bộ `pc-ho-ve` (game-5f) |
| AR-71 | Hình tạm Triệu Hồi Sư (`hero-trieu-hoi-su`): áo choàng ngọc lam dài, cổ bạc, cầu linh hồn lơ lửng (`weapon: orb`) | ✅ — như AR-70 với `pc-trieu-hoi-su` |
| AR-72 | 8 linh thú: Linh Hồ, Hoả Hồ, Sói Bóng (thú 4 chân), Tiểu Quỷ, Linh Hồn (tinh linh bay), Thạch Quỷ (người đá), Linh Ưng (chim), Ấu Long (thú lửa có bờm) | ✅ `catalog.py` |
| AR-73 | Icon 18 kỹ năng + 2 đánh thường (`tools/art/classes45_icons.py`); 8 kỹ năng chính lấy từ ảnh của chủ dự án | ✅ |

### 2.7. Chuyển chức 3 (J3, [23](23-chuyen-chuc-3-linh-thu-co-mau.md))

| Mã | Hạng mục | Trạng thái |
| --- | --- | --- |
| AR-74 | Icon 5 Thần Kỹ viền bạc (`tools/art/job3_icons.py`): Nhất Kiếm Khai Thiên, Thiên Lạc Tinh Vũ, Ngũ Hành Luân Chuyển, Thiên Thuẫn Giáng Thế, Kỳ Lân Giáng Thế | ✅ |
| AR-75 | Kỳ Lân Thần Thú (`ky-lan`, thú 4 chân trắng bờm vàng) | ✅ `catalog.py` |
| AR-76 | Hiệu ứng vẽ bằng code (`view/job3_view.gd`): hào quang trắng bạc dưới chân, vệt Nhất Kiếm, mũi tên sao, 5 cầu ngũ hành, vòng Bất Khuất, thanh máu linh thú | ✅ — chưa có ảnh động riêng |
| AR-77 | UI-26 — `stat-main` (vương miện vàng 3 chóp, ngọc đỏ) trong `tools/art/stat_icons.py`: nhãn "Thuộc tính chính" ở thẻ thuộc tính; không dùng ký tự ♛ vì phông Be Vietnam Pro không có | ✅ | Tab Chỉ số, test UI-19 |
| AR-78 | UI-27 — **ngoại lệ phong cách (D64)**: 17 mảnh trang trí **cắt từ ảnh mẫu vẽ** của chủ dự án (`tools/art/src/ui-character-mockup.png`) bằng `tools/art/ui_cut.py` → `godot/assets/ui/`: `ui-panel` (9-slice 96×96, lề 32), `ui-row`, `ui-btn-gold`, `ui-btn-dark`, `ui-btn-plus`, `ui-btn-info`, `ui-tag-main`, `ui-power`, `ui-points` (chữ xoá + tô bù khuếch tán), `ui-scene`, `attr-<7 thuộc tính>`. Lọc Linear (dự án mặc định Nearest). Muốn đổi: sửa toạ độ trong `ui_cut.py` rồi chạy lại | ✅ | Tab Chỉ số, test UI-19, UI-21 |
| AR-79 | UI-28 — 9 mảnh thanh tiêu đề cắt từ `tools/art/src/ui-topbar-mockup.png` (`ui_cut.topbar()`): `ui-topbar` (lát nền), `ui-topbar-back`, `ui-topbar-title` và `ui-tab-active` (chữ xoá + tô bù), `ui-tab-sep`, `ui-coin`, `ui-gem`, `ui-topbar-plus`, `ui-topbar-close` | ✅ | Thanh tiêu đề bảng Nhân vật, test UI-21 |
| AR-80 | PV ([27](27-ky-nang-bi-dong.md)) — `tools/art/passive_icons.py`: 20 icon kỹ năng bị động `skill-pv-<id>` + icon tab `skill-pv-tab`; nền kỹ năng thường + viền trong xanh lục `#9ad46a` để phân biệt bị động với chủ động | ✅ | Sinh bằng code, cùng phong cách icon kỹ năng SK2 |

## 3. Kết quả (20/10/2026)

| Hạng mục | Kết quả |
| --- | --- |
| Hình đã sinh | 7 sprite động (2 nhân vật, 4 quái, 1 boss; mỗi sprite 13 frame), 41 icon (9 trang bị, 8 tài nguyên, 4 kỹ năng, 20 Thiên phú), 22 hình môi trường/hiệu ứng |
| Thời gian sinh | Dưới 1 giây cho toàn bộ (`python tools/art/build_all.py`) |
| Trong game | Người chơi, quái, boss, đồng minh vẽ bằng sprite có hoạt ảnh đứng/chạy/đánh/trúng đòn/chết; quái chết để lại hoạt ảnh ngã 0,6 giây; tia trúng đòn; cây, nhà, Bia Đá, rương, thảo dược, vật rơi; nền cỏ, lối mòn, sân làng, hang Hư Vô lát ô; sắp xếp theo chiều sâu (vật ở dưới che vật ở trên) |
| Giao diện | Icon ở túi đồ (ô trống hiện mờ loại đồ), ô trang bị, 5 ô kỹ năng HUD, bảng Thiên phú |
| Dự phòng | Thiếu `art_manifest.json` hoặc thiếu hình của 1 quái thì vẽ hình khối tạm như trước, game không lỗi |
| Test | AR-35 kiểm mọi quái có đủ 5 hoạt ảnh và nạp được ảnh, mọi Thiên phú/ô đồ/đồ Cam/kỹ năng có icon. 39/39 test qua; smoke test chụp đủ 11 ảnh, `boss_defeated=true` |

**Phát hiện**

| # | Phát hiện | Xử lý |
| --- | --- | --- |
| G-F1 | Mặt nhân vật bị tối, tóc che mắt (ánh sáng trên trái chiếu vào gáy) | Đầu dùng hướng sáng riêng `light=(0.35, -0.5)`, hạ tóc |
| G-F2 | Mũ nấm tách khỏi thân (lệnh khoét đáy mũ xoá luôn thân) | Khoét trước, vẽ thân sau |
| G-F3 | Sói chết xoay 90° trông như đứng dậy | Thú 4 chân chết bằng nằm rạp + mờ dần thay vì xoay |
| G-F4 | Ô kỹ năng có icon rộng ra, đè nhật ký ở 1366 px | Ô 100 px, icon 32 px |
| G-F5 | Nhân vật 64 px trông nhỏ so với cây 80–120 px | Giữ nguyên ở G1 (tầm nhìn rộng hợp combat đông quái); xem lại khi playtest |
