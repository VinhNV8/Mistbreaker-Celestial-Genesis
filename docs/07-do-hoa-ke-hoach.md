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
| AR-43 | Âm thanh, nhạc (DH-12, DH-13) | G2 |
| AR-44 | Thay hình sinh bằng code bằng hình hoạ sĩ vẽ (giữ kích thước, manifest) | Khi có ngân sách |

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
| AR-60 | Vùng 5 (M8, docs/12) — **file riêng `tools/art/region5.py`** (catalog/icons/env chỉ gọi `register_*`, để chương 4 thêm AR-59 song song không đụng): builder mới `dragon` (thú 4 chân + cánh màng phía sau — Viêm Long, Rồng Non Lửa) và `phoenix` (chim + hào quang + đuôi lửa — Phượng Hoàng Tro); Thằn Lằn Lửa, Người Đá Dung Nham (humanoid đá), Mảnh Đá (insect), Linh Hồn Lửa (wisp), Pháp Sư Hoả Diệm, Thợ Rèn Hư Vô, Lính/Đội Trưởng Kim Luân, Xương Nô (Tử Linh Sư); NPC Xích Đồng, Kim Phú, Liệt Diễm, Tiểu Hoả; nền dung nham/tro/đá đen, đá dung nham, cây cháy, Đá Nổi, miệng phun, lò rèn, thiên thạch; icon Long Tâm, Lông Phượng, Tinh Thạch, Bình Nước Thánh, kỹ năng Long Tức; dải màu `lava`, `basalt`, `ash`, `ember`, `bone` | ✅ | Hình xong trước code (code M8 chờ M7) |

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
