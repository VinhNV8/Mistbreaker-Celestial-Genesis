# 37. Thiết kế lại icon kỹ năng (IC-1)

| Mục | Nội dung |
| --- | --- |
| Ngày | 03/11/2026 |
| Yêu cầu | Chủ dự án: "đã design lại icon đại diện của skills chưa? … icon nằm ở thanh kỹ năng" |
| Phạm vi (chủ dự án chọn) | Vẽ lại **51 icon vẽ bằng code**. **Giữ nguyên 19 icon vẽ tay** cắt từ `tools/art/src/class-skills.png` (`tools/art/class_skill_icons.py`) |
| Cách đưa vào game (chủ dự án chọn) | Duyệt ảnh trước, áp dụng sau |
| Bản duyệt | [docs/design/skill-icons/](design/skill-icons/) — `<lớp>/<icon>.png` (128×128), `<lớp>-so-sanh.png` (hàng trên: icon cũ, hàng dưới: IC-1), `thanh-ky-nang-trong-game.png` (thanh kỹ năng thật, icon lấy qua `SpriteLib.icon`: hàng trên tắt HD, hàng dưới bật HD) |
| Trong game | `godot/assets/hd/icons/skill-<icon>.png` (51 chủ động + 21 bị động / tab, §6) + lớp phủ `manifest["hd"]["icons"]` |
| Công cụ | `tools/art/skill_icons_fx.py`; ảnh thanh kỹ năng: `godot/tests/ic1_bar.gd` |
| Trạng thái | ✅ **Đã duyệt và đưa vào game (03/11/2026)**: chủ dự án "ok, triển khai vào game" (Q184) |

## 1. Vì sao trước đây icon chưa đổi

Đợt FX-1 ([36](36-thiet-ke-lai-vfx-ky-nang.md)) chỉ làm hiệu ứng khi thi triển. Tài liệu 36 ghi "Không đổi … icon UI", brief cũ cũng ghi "Không thiết kế lại icon UI trong đợt này". Vì vậy thanh kỹ năng vẫn dùng icon cũ: 19 icon vẽ tay đẹp, còn 51 icon vẽ bằng code thì phẳng, đơn sắc, lệch phong cách.

## 2. Phong cách

Bộ icon mới theo phong cách của 19 icon vẽ tay và của các bộ icon trên board tham khảo (Juggernaut Wars, A-Ravlik, Elemental Magic Icons, [36 §2](36-thiet-ke-lai-vfx-ky-nang.md)):

- Tranh vuông kín ô. Nền tối toả từ giữa theo màu của kỹ năng, có vài tia sáng chéo mờ và góc tối nhẹ.
- Hình chính ở giữa ô, vẽ bằng **chính bộ nguyên tố FX-1**: trăng khuyết, sao va chạm, kiếm, tên, cầu, khiên, búa, sét, cột sáng, vòm. Mỗi hình có 4 dải màu và glow cộng sáng, nên icon khớp với hiệu ứng khi thi triển.
- Bảng màu theo bản sắc lớp và nhánh như FX-1 ([36 §4](36-thiet-ke-lai-vfx-ky-nang.md)).
- Kỹ năng gọi linh thú dùng **bóng của sprite linh thú thật** (chỉ lấy dáng, không vẽ lại sprite): thân tối, viền sáng sắc, glow toả ra ngoài, giống icon Sói Bóng vẽ tay.
- Vẽ ở 256 px rồi thu về 128×128 bằng Lanczos (HD, Q182). Ô trên thanh kỹ năng hiển thị khoảng 44–52 px.

## 3. Danh mục 51 icon

| Lớp | Icon vẽ lại | Giữ icon vẽ tay |
| --- | --- | --- |
| Kiếm Khách | Xoáy Kiếm, Đột Kích, Hống Kiếm, Kiếm Vũ, Phi Kiếm, Thánh Kiếm Trảm, Kiếm Vực, Huyết Bạo, Huyết Ảnh, Nhất Kiếm Khai Thiên | Trảm Phong, Kiếm Ý, Nguyệt Ảnh Liên Trảm, Vạn Kiếm Quy Tông |
| Thợ Săn | Ưng Nhãn, Tên Nảy, Bẫy Gai, Liên Xạ, Tên Độc, Phá Không Tiễn, Tam Liên Thần Tiễn, Bãi Mìn, Lưới Bẫy, Thiên Lạc Tinh Vũ | Vũ Tiễn, Xuyên Tâm Tiễn, Lộn Nhào, Thiên Tiễn Vũ |
| Pháp Sư | Thiên Thạch, Pháp Thuẫn, Hoả Tường, Băng Ngục, Mưa Băng, Cầu Sấm, Thiên Lôi, Băng Phong Thiên Hạ, Triệu Hồi Xương, Khí Độc Tử Vong, Ngũ Hành Luân Chuyển | Sét Chuỗi, Băng Lao, Thiên Tai Nguyên Tố |
| Hộ Vệ | Khiên Chấn, Lao Khiên, Phi Thuẫn, Phán Quyết, Xung Phong, Thánh Quang Trảm, Thánh Vực, Thiết Chuỳ Phá Địa, Thành Đồng, Thiên Thuẫn Giáng Thế | Khiêu Khích, Khiên Thép, Chấn Địa, Thành Bất Diệt |
| Triệu Hồi Sư | Linh Tiễn, Gọi Thạch Quỷ, Hoả Điểu, Linh Trận, Gọi Linh Ưng, Gọi Ấu Long, Long Hống, Lôi Đồ Đằng, Phong Đồ Đằng, Kỳ Lân Giáng Thế | Triệu Hồi Sói Bóng, Triệu Hồi Tiểu Quỷ, Liên Kết Linh Hồn, Quân Đoàn Linh Hồn |

## 4. Đưa vào game (đã làm 03/11/2026)

`python tools/art/skill_icons_fx.py --apply`: ghi `godot/assets/hd/icons/skill-<icon>.png` và thêm mục vào **lớp phủ HD** `manifest["hd"]["icons"]` (cơ chế UI-40, [35](35-de-xuat-giao-dien-moi.md)). Icon cũ trong `godot/assets/icons` giữ nguyên; tắt Cài đặt → "Đồ hoạ HD" thì về icon cũ. Thanh kỹ năng, bảng kỹ năng, tooltip dùng chung `SpriteLib.icon`, nên đổi cùng lúc. `tools/art/hd/build_hd.py` ghi lại toàn bộ `manifest["hd"]`, nên đã thêm bước sinh icon kỹ năng vào đó: chạy `build_hd.py` sẽ dựng lại cả 51 icon, không làm mất. `build_all.py` vẫn giữ nguyên khoá `hd`. Đã chạy `godot --headless --import` để Godot nhập các ảnh mới.

| Kiểm thử | Nội dung | Kết quả |
| --- | --- | --- |
| IC1-T1 (`run_tests.gd`) | Bật HD: 51 icon IC-1 có kích thước 128 px, 19 icon vẽ tay (nhận từ `class_skill_icons.py`) giữ nguyên kích thước ≤ 64 px; tắt HD → icon cũ | ✅ |
| `tests/ic1_bar.gd` | Chụp thanh kỹ năng thật của game cho cả 5 lớp, icon lấy qua `SpriteLib.icon` như HUD | ✅ `docs/design/skill-icons/thanh-ky-nang-trong-game.png` |

## 5. Câu hỏi chờ duyệt

| Mã | Câu hỏi | Đề xuất |
| --- | --- | --- |
| Q184 | Duyệt 51 icon IC-1 (xem `docs/design/skill-icons/*-so-sanh.png` và `thanh-ky-nang-trong-game.png`)? Icon nào cần vẽ lại thì ghi tên | Duyệt, rồi áp dụng qua lớp phủ HD — ✅ chủ dự án duyệt 03/11/2026 |

## 6. Icon kỹ năng bị động (03/11/2026)

**Chủ dự án hỏi:** "Các icon bị động không vẽ lại cho đồng bộ à?" Lúc đó chưa vẽ lại, vì đợt đầu chỉ làm icon của 70 kỹ năng chủ động. Đã bổ sung **20 icon bị động** (4 mỗi lớp, `core/passives.gd` DEFS) và **icon tab "Bị động"** của bảng kỹ năng. Cả 21 icon này trước đây đều vẽ bằng code (`tools/art/passive_icons.py`), không có icon vẽ tay nào. Cách vẽ giống 51 icon chủ động: nền tối toả màu của lớp, hình chính bằng bộ nguyên tố FX-1, linh thú vẽ dạng bóng lấy từ sprite thật.

| Lớp | Bị động → hình chính |
| --- | --- |
| Kiếm Khách | Thiết Cốt: trái tim đỏ bọc vòng thép · Kiếm Tâm: kiếm dựng, sao chí mạng ở mũi · Phản Kích: vệt vòng ngược + kiếm · Chiến Ý: kiếm giữa ba ngọn lửa |
| Thợ Săn | Ưng Mục: mắt ưng trong vòng ngắm · Săn Mồi: bia ngắm đỏ + vết vuốt · Bước Gió: gió xoáy + vệt tốc độ · Tên Tẩm Độc: mũi tên nhỏ giọt độc |
| Pháp Sư | Minh Tưởng: cầu pháp lực trên vòng tĩnh toạ · Tinh Thông Nguyên Tố: 3 cầu Hoả / Băng / Lôi quanh sao · Pháp Lực Dồi Dào: cầu pháp lực tràn giọt · Hộ Thể Pháp Lực: vòm phép bọc cầu pháp lực |
| Hộ Vệ | Kiên Thủ: khiên thép lớn · Ý Chí Sắt: trái tim thép + hạt hồi máu · Phản Chấn: khiên dội tia ra ngoài · Uy Áp: đầu lâu dưới áp lực vàng |
| Triệu Hồi Sư | Linh Khế: hai linh hồn nối khế ước · Linh Thể: bóng Sói Bóng + trái tim · Linh Hộ: khiên + 3 linh hồn xoay · Hồn Lực: ngọn lửa linh hồn |

- Công cụ: `tools/art/passive_icons_fx.py`, được `skill_icons_fx.build()` gọi. Khoá `pv-<id>` ứng với icon game `skill-pv-<id>`.
- Bản duyệt: `docs/design/skill-icons/bi-dong-so-sanh.png` (hàng trên icon cũ, hàng dưới IC-1) và `docs/design/skill-icons/bi-dong/`.
- Đã vào game qua cùng lớp phủ HD (`--apply`); tắt "Đồ hoạ HD" thì về icon cũ.
- Test: IC1-T1 kiểm tra đủ 20 icon bị động và icon tab, mỗi icon 128 px khi bật HD.
