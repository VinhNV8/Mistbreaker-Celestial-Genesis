---
name: game-art
description: "Sinh hình pixel art cho game Thiên Phú Khai Giới bằng code (Python + Pillow): nhân vật, quái, boss, icon trang bị/tài nguyên/kỹ năng/Thiên phú, môi trường, hiệu ứng. Dùng khi cần thêm hoặc sửa hình ảnh, thêm quái/nhân vật/đồ vật mới, hoặc khi người dùng nói 'vẽ', 'build hình', 'sprite', 'icon', 'đồ hoạ'."
---

# Skill: game-art — sinh hình pixel art cho Thiên Phú Khai Giới

Mọi hình trong game được **sinh bằng code** từ tham số, không vẽ tay, không dùng AI tạo ảnh. Nhờ vậy cả game giữ một phong cách, chạy lại được, và thêm quái mới chỉ cần khai báo vài dòng.

Kế hoạch và trạng thái: `docs/07-do-hoa-ke-hoach.md` (mã AR-xx). Phong cách đã chốt ở mục 1.2 của tài liệu đó — **không tự đổi** kích thước frame, tỉ lệ ×2, hướng nhìn hay số hoạt ảnh.

## Quy ước phong cách (bắt buộc)

| Mục | Giá trị |
| --- | --- |
| Góc nhìn | Trên xuống chéo 3/4, **quay mặt sang phải** (game tự lật khi đi trái) |
| Frame | Nhân vật 32×32 · quái thường 24×24 · boss 48×48 · icon 32×32 · ô đất 32×32 |
| Phóng to | ×2 trong game, lọc Nearest |
| Tô màu | Dải 4 màu tối → sáng trong `pixel.R`; ánh sáng từ trên trái; viền tối 1 px (`Canvas.outline`) |
| Chân | Điểm chân nằm ở giữa bóng, y ≈ 29,5/32 chiều cao frame (manifest tự tính) |
| Hoạt ảnh | `idle` 2 · `run` 4 · `attack` 3 · `hurt` 1 · `death` 3 frame |
| Icon đồ | Không tô màu phẩm chất — giao diện vẽ khung theo phẩm chất |

## Cấu trúc

| File | Vai trò |
| --- | --- |
| `tools/art/pixel.py` | Canvas, dải màu `R`, elip/đa giác có đổ bóng, đường, cung, viền, hào quang, ghép sheet |
| `tools/art/builders.py` | Bộ dựng theo dáng: `humanoid`, `quadruped`, `mushroom`, `wisp`, `treant` |
| `tools/art/catalog.py` | **Danh mục sprite** (id → builder + tham số). Thêm nhân vật/quái ở đây |
| `tools/art/icons.py` | Icon trang bị (`ITEMS`), tài nguyên (`RESOURCES`), kỹ năng (`SKILLS`), Thiên phú (`TALENTS`) |
| `tools/art/env.py` | Ô đất, cây, nhà, Bia Đá, rương, thảo dược, vật rơi, hiệu ứng |
| `tools/art/build_all.py` | Sinh tất cả + `godot/assets/art_manifest.json` + bảng xem trước `tools/art/_preview/` |
| `godot/scripts/view/sprite_lib.gd` | Phía game: nạp manifest, vẽ frame, lấy icon |

## Quy trình

1. **Xác định id** khớp dữ liệu game: quái = khoá trong `godot/scripts/data/monsters.gd` `DEFS`; Thiên phú = `id` trong `talents.gd`; ô đồ = khoá `SLOTS`; đồ Cam = khoá `UNIQUES` trong `godot/scripts/data/items.gd`. Quái mới lấy tên, loại, hệ, kỹ năng từ `docs/06-ban-do-quai-boss.md`.
2. **Khai báo hoặc vẽ:**
   - Quái/nhân vật dùng dáng có sẵn → thêm 1 dòng vào `SPRITES` trong `catalog.py`, chỉ đổi tham số (dải màu, mắt, bờm, hào quang, size). Màu theo hệ: Mộc xanh lá, Kim trắng bạc, Thủy xanh lam, Hỏa đỏ cam, Thổ nâu vàng, Hư Vô tím.
   - Dáng mới (chim, rắn, người đá…) → viết hàm builder mới trong `builders.py` theo mẫu: hàm `frame(...)` vẽ 1 tư thế, rồi trả về đủ 5 hoạt ảnh; thêm vào `BUILDERS`.
   - Icon mới → viết `g_<tên>(cv)` trong `icons.py`, thêm vào bảng tương ứng. Thiên phú mới thêm 1 dòng vào `TALENTS` (id, hạng, nhóm, hàm biểu tượng).
   - Dùng dải màu có sẵn trong `pixel.R`; cần màu mới thì thêm dải 4 màu tối → sáng vào `R`.
3. **Sinh:** `python tools/art/build_all.py` (hoặc `python tools/art/build_all.py <id> ...` để chỉ ghi lại các sprite đó).
4. **Duyệt bằng mắt — bắt buộc:** mở `tools/art/_preview/sprites.png`, `icons.png`, `env.png` bằng công cụ Read (ảnh). Kiểm: dáng đọc được ở cỡ nhỏ, không có mảng bị cắt/tách rời, mắt/mặt nhìn thấy, viền liền, hoạt ảnh chạy có chân đổi nhịp. Muốn soi 1 frame thì phóng to ×8 bằng script nhỏ trong scratchpad. Sửa rồi sinh lại cho tới khi đạt.
5. **Import vào Godot:** `godot --headless --path godot --import` (tạo file `.import`; thiếu bước này game vẫn chạy được nhờ đọc thẳng PNG, nhưng bản xuất .exe cần import).
6. **Nối vào game nếu là loại hình mới:** quái mới dùng `kind` trùng id thì `world_view.gd` tự vẽ. Icon mới lấy bằng `SpriteLib.icon("<nhóm>-<id>")`.
7. **Kiểm:** chạy test (`godot --headless --path godot --script res://tests/run_tests.gd`) — test AR-35 hỏng nếu có quái/Thiên phú/ô đồ thiếu hình. Chạy smoke test (`godot --path godot -- --smoke=<thư mục>`) và xem ảnh chụp `03-combat.png`, `06-boss.png`.
8. **Cập nhật tài liệu:** trạng thái AR-xx ở `docs/07-do-hoa-ke-hoach.md`, DH-xx ở `docs/04-ke-hoach-tien-do.md`, danh sách file ở `docs/02-technical-spec.md` nếu thêm file.

## Mẹo vẽ

- Toạ độ thực, điểm ảnh (x, y) phủ ô [x, x+1). Vẽ từ xa ra gần: bóng → đồ phía sau → chi phía xa (dải `_darker`) → thân → chi phía gần → đầu → vũ khí.
- `shade_ellipse(..., light=...)` đổi hướng sáng khi phần cần sáng nằm khuất (ví dụ mặt quay phải dùng `light=(0.35, -0.5)`).
- `cv.clear(...)` để khoét (ví dụ cắt đáy mũ nấm) — khoét **trước** khi vẽ phần nằm dưới.
- Hào quang (`glow`) và bóng có alpha thấp nên không bị viền; vẽ hào quang sau `outline` nếu muốn nó toả ra ngoài viền.
- Boss nên to gấp đôi quái thường (`size: 48`) và có ít nhất một đặc điểm nhận diện từ xa (bờm, sừng, mắt sáng, hào quang).
- Giữ hình đơn giản: ở 24×24 mỗi chi tiết nhỏ hơn 2 px sẽ thành nhiễu.
