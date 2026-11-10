# Thiên Phú Khai Giới (Mistbreaker: Celestial Genesis)

Game nhập vai hành động: nhận Thiên phú khi vào game, đánh quái lên cấp, vượt map, khai phá vùng đất bị sương mù che phủ.

Trạng thái: Chương 1 chơi được trên Godot 4.7.2. Đang làm **MVP**: đã xong M1 (trang bị, cường hoá), M2 (đủ 20 Thiên phú), G1 (hình pixel art sinh bằng code) và M3 (lớp Thợ Săn, 4 kỹ năng mỗi lớp, MP, né tránh, công thức chỉ số quái mới); đã xong đợt **C1 — hoàn chỉnh Chương 1** ([08](docs/08-chuong-1-hoan-chinh.md): tạo nhân vật, cốt truyện, hướng dẫn, Lõi Sương, boss hiếm, cửa hàng, âm thanh); **M4 — Chương 2** (Đồng Bằng Gió Hú, gió, boss Huyền Ảnh, Thành Biên Đài, Mỏ/Bến Cá); **M5** (boss hiếm Bạch Hổ, nhịp EXP mới, bản đồ nhỏ, câu đố Di tích, cỡ chữ, file .exe); Alpha **M6 — Chương 3** (Sa Mạc, chuyển chức 1), **M7 — Chương 4** (Đầm Lầy, tiến hoá Thiên phú) và **M8 — Chương 5** ([12](docs/12-chuong-5.md): Núi Viêm Long, Viêm Long, Thương hội phản bội, Công Trại, chuyển chức 2); Beta **M9 — Chương 6** ([14](docs/14-chuong-6.md): Băng Nguyên, Bản Ngã Bóng Tối) và **M10 — Chương 7** ([16](docs/16-chuong-7.md): lãnh địa Hoàng Thành + Cảng Khí Cầu, Quần Đảo Thiên Không — đảo bay, Thiên Không Cự Thần, tiến hoá Thiên phú lần 2).

## Thư mục

| Thư mục | Nội dung |
| --- | --- |
| [docs/](docs/) | Tài liệu: kịch bản, đặc tả yêu cầu, đặc tả kỹ thuật |
| [godot/](godot/) | Project Godot — bản đang phát triển |

## Tài liệu

| File | Dành cho | Nội dung |
| --- | --- | --- |
| [docs/kich-ban-game-thien-phu-khai-gioi.md](docs/kich-ban-game-thien-phu-khai-gioi.md) | Cả nhóm | Kịch bản đầy đủ: thế giới, Thiên phú, combat, bản đồ, lộ trình |
| [docs/01-requirement-spec.md](docs/01-requirement-spec.md) | Review phạm vi, nghiệm thu | Yêu cầu có mã (AWK-01…), tiêu chí nghiệm thu, trạng thái, chỗ lệch so với kịch bản |
| [docs/02-technical-spec.md](docs/02-technical-spec.md) | Lập trình, cài đặt | Cài Godot, import project, kiến trúc, định dạng save, chạy test, quyết định kỹ thuật, lỗi đã gặp |
| [docs/03-mvp-spec.md](docs/03-mvp-spec.md) | Review trước khi code | Lộ trình MVP (M1–M5), spec chi tiết từng đợt, kết quả và phát hiện |
| [docs/05-thien-phu-chi-tiet.md](docs/05-thien-phu-chi-tiet.md) | Thiết kế nội dung | 20 Thiên phú: hiệu ứng theo cấp, kỹ năng, tiến hoá 2 bậc, cộng hưởng, tương tác 4 lớp. Đã chốt Q17–Q21 |
| [docs/06-ban-do-quai-boss.md](docs/06-ban-do-quai-boss.md) | Thiết kế nội dung | Công thức chỉ số; 9 vùng, môi trường, quái, tinh anh, boss chương, boss hiếm, đồ Cam. Sinh bằng script — xem đầu file. Đã chốt Q22–Q27 |
| [docs/07-do-hoa-ke-hoach.md](docs/07-do-hoa-ke-hoach.md) | Đồ hoạ | Nghiên cứu, phong cách pixel art đã chốt, hạng mục AR-xx, kết quả G1. Sinh hình: `python tools/art/build_all.py` (skill `game-art`) |
| [docs/08-chuong-1-hoan-chinh.md](docs/08-chuong-1-hoan-chinh.md) | Kế hoạch | Đợt C1: hoàn chỉnh Chương 1, kết hợp ghi chú Spec_Notes (N1–N7), hạng mục C1-xx |
| [docs/15-hang-phu.md](docs/15-hang-phu.md) | Thiết kế nội dung | Hang phụ trong từng map (Spec_Notes đợt 6): cửa hang, 3 khu quái, Chúa Hang, thưởng, đóng 20 phút, save v15 |
| [docs/16-chuong-7.md](docs/16-chuong-7.md) | Review trước khi code | Đợt M10 — Chương 7 Thiên Không Đảo: lãnh địa cấp 3–5 + Cảng Khí Cầu, đảo bay, Thiên Không Cự Thần, Kỳ Lân Mây, tiến hoá Thiên phú lần 2 (chờ duyệt Q76–Q82) |
| [docs/17-chuong-8.md](docs/17-chuong-8.md) | Đặc tả + kết quả | Đợt M11 — Chương 8 Vực Hư Vô: Suy Thiên, Đèn Tinh Quang, Cột Đá, Giáo Chủ Hư Vô (Hút Thiên phú), Hư Vô Thú, Tổng tấn công, chuyển chức 3 ở 5 Tổ Sư. Rà lại 31/10 theo 5 lớp, J3, BK, map ×3 (mục 0b); **đã code** (save v25) |
| [docs/18-chuong-9.md](docs/18-chuong-9.md) | Đặc tả + kết quả | Đợt M12 — Chương 9 Thiên Đạo Chi Môn: 9 tầng theo hệ, Ma Tôn Vô Diện, hai kết thúc Hợp nhất / Hiến tế, endgame tối thiểu (cấp sau 100, Thần Vực, Tái Thiết Lục Địa). Rà lại 31/10 (mục 0b: 5 lớp, BK, map ×3); Q90–Q98 theo mặc định; **đã code** 01/11 (save v26) |
| [docs/19-ra-soat-de-xuat.md](docs/19-ra-soat-de-xuat.md) | Chủ dự án | Rà soát kịch bản + toàn bộ spec + bản game (ảnh chụp ở `docs/images/ra-soat/`): 12 việc ưu tiên, đề xuất cho kịch bản, Thiên phú, kỹ năng, quái/boss, giao diện, hình ảnh, kinh tế, quy trình; lộ trình R1–R6; Q99–Q104 |
| [docs/19-lop-ho-ve-trieu-hoi-su.md](docs/19-lop-ho-ve-trieu-hoi-su.md) | Thiết kế nội dung | Lớp thứ 4 **Hộ Vệ** (kịch bản) và lớp thứ 5 **Triệu Hồi Sư** (CR-03): chỉ số, 13 kỹ năng mỗi lớp (CL2), chuyển chức 1–2, linh thú, cân bằng; **LH1 + LH2 đã làm** |
| [docs/23-chuyen-chuc-3-linh-thu-co-mau.md](docs/23-chuyen-chuc-3-linh-thu-co-mau.md) | Thiết kế nội dung | **Chuyển chức 3** cho 5 lớp (Kiếm Thần, Thiên Lạc Xạ Thủ, Hiền Giả, Thủ Hộ Thần, Vạn Linh Chi Chủ — 2 hiệu ứng + 1 Thần Kỹ mỗi chức; điều kiện bản tạm khi chưa có chương 8) và **linh thú có máu** (Q112); Q140–Q146; **J3 + SH đã làm** |
| [docs/21-thiet-ke-lai-5-lop.md](docs/21-thiet-ke-lai-5-lop.md) | Chủ dự án | Đối chiếu [charactors.md](docs/charactors.md) (thiết kế lại 5 lớp) với hệ kỹ năng đang có: ánh xạ 4 kỹ năng chính mỗi lớp vào 13 ô kỹ năng, chỉnh chỉ số, tạo hình; đợt CL1 (3 lớp cũ), CL2 (sửa docs/19); Q130–Q139 duyệt theo mặc định; **CL1 đã làm** (mục 10) |
| [docs/25-spec-notes-dot-9.md](docs/25-spec-notes-dot-9.md) | Review + kết quả | Spec_Notes đợt 9: 5 ô nhân vật, tên + chức nghiệp, số sát thương theo màu, thú lao trước, EXP theo chênh cấp, bãi quái theo cấp, "+9 + 15 (gốc)", lên cấp tăng gì, khung mục tiêu |
| [docs/28-spec-notes-dot-10.md](docs/28-spec-notes-dot-10.md) | Review + kết quả | Spec_Notes đợt 10: kết quả cường hoá hiện giữa màn hình, bình MP (phím F, cửa hàng, rơi đồ, save v22) |
| [docs/30-spec-notes-dot-11.md](docs/30-spec-notes-dot-11.md) | Review + kết quả | Spec_Notes đợt 11: thẻ trang bị khi rê chuột, so sánh ▲▼ với đồ đang mặc, bản đồ rộng gấp 3 (×√3 mỗi chiều, quái ×3, save v23) |
| [docs/31-de-xuat-thanh-ky-nang.md](docs/31-de-xuat-thanh-ky-nang.md) | Đề xuất + kết quả | Spec_Notes đợt 12: bình máu không giới hạn; thanh kỹ năng 7 ô (ô 5 / 6 theo chuyển chức, ô Tuyệt kỹ G), báo + tự lắp kỹ năng mới, đổi ô ngoài giao tranh, kéo-thả, 2 bộ kỹ năng (save v27) |
| [docs/32-ra-soat-01-11.md](docs/32-ra-soat-01-11.md) | Báo cáo + kết quả | Rà soát 01/11: cân bằng sau 7 ô + TL-J3, 7 lỗi giao diện từ ảnh smoke chương 1–9, nhạc nền vùng 2–9 + âm kỹ năng theo lớp, Thần Vực TL-B9b (hệ số tầng, tầng 14–19) |
| [docs/33-thien-phu-phu-cong-huong.md](docs/33-thien-phu-phu-cong-huong.md) | Đặc tả + kết quả | **Thiên phú phụ** (ô 2 / 3 khi chuyển chức 1 / 2, Lễ Thức Tỉnh ô phụ, cấp riêng), **cộng hưởng** (+10% cùng nhóm, 9 cặp đặc biệt, ??? tới khi kích hoạt), **tẩy Thiên phú** bằng Nước Thánh Tinh Quang; save v28 |
| [docs/34-dungeon-cong-ngau-nhien.md](docs/34-dungeon-cong-ngau-nhien.md) | Đặc tả + kết quả | **Dungeon cổng ngẫu nhiên** hạng E → S (BD-11): mở ngẫu nhiên trên map đã tới, tồn tại 2 giờ chơi, Chúa Cổng, thưởng theo hạng; dọn sương 7% lộ cổng (KP-10); EXP dungeon (NV-23); save v29 |
| [docs/35-de-xuat-giao-dien-moi.md](docs/35-de-xuat-giao-dien-moi.md) | Đề xuất + quyết định | **Giao diện mới bớt pixel**: hiện trạng, 3 hướng (A giao diện / **B HD vector code vẽ — đã chọn** / C vẽ tay), lộ trình G0…G4 (UI-40…49), phong cách cel-shade; bản thử G0 |
| [docs/36-thiet-ke-lai-vfx-ky-nang.md](docs/36-thiet-ke-lai-vfx-ky-nang.md) | Thiết kế + đã làm | **Hiệu ứng kỹ năng FX-1 cho 70 kỹ năng 5 lớp**: nghiên cứu board Pinterest game-skill-effects, ngôn ngữ cel-shade 4 dải + glow cộng, bản sắc lớp, danh mục 70 kỹ năng; bản duyệt HD [docs/design/skills-fx](docs/design/skills-fx); trong game vẽ vector HD (`view/fx1.gd`), mặc định cho cả 70 kỹ năng, hình cũ chọn lại được (Cài đặt "Hiệu ứng kỹ năng"); ảnh so sánh thiết kế ↔ trong game [docs/design/skills-fx-ingame](docs/design/skills-fx-ingame) |
| [docs/37-icon-ky-nang.md](docs/37-icon-ky-nang.md) | Thiết kế + đã làm | **Icon kỹ năng IC-1**: vẽ lại 51 icon vẽ bằng code theo phong cách 19 icon vẽ tay + FX-1 (HD 128×128), giữ nguyên 19 icon vẽ tay; thêm 20 icon bị động; IC-2: 20 icon Thiên phú + 18 icon trang bị + 38 icon tài nguyên / chỉ số; đã vào game qua lớp phủ HD; ảnh [docs/design/skill-icons](docs/design/skill-icons) |
| [docs/39-thiet-ke-lai-quai-vat.md](docs/39-thiet-ke-lai-quai-vat.md) | Thiết kế + đã làm | **Thiết kế lại toàn bộ quái MD-1** (G3 / UI-47): nghiên cứu ảnh mẫu Pinterest, quy chuẩn phong cách cartoon vẽ tay (skill `monster-design`), 85 quái / tinh anh / boss HD vào game qua lớp phủ "Đồ hoạ HD", 9 linh thú chờ duyệt; ảnh [docs/design/monsters](docs/design/monsters) |
| [docs/40-icon-trang-bi.md](docs/40-icon-trang-bi.md) | Thiết kế + thử trong game (chờ duyệt) | **Icon trang bị HD (EQ-HD)**: nghiên cứu ảnh mẫu icon MMORPG, skill `equipment-design`, 336 icon theo dáng (5 kiểu vũ khí theo lớp + 7 ô) × 5 phẩm chất + 9 bộ × 2 biến thể; ảnh [docs/design/equipment](docs/design/equipment) |
| [docs/42-giao-dien-xem-do.md](docs/42-giao-dien-xem-do.md) | Thiết kế + đã làm | **Giao diện xem đồ**: nghiên cứu inventory các game, ô đồ theo bậc phẩm chất, thẻ thông tin trang bị mới (dải đầu màu phẩm chất, icon lớn, chỉ số to + biểu tượng, chip so sánh), icon trang bị có khối; ảnh trước / sau [docs/design/equipment](docs/design/equipment) |
| [docs/44-ty-le-khung-nhin-va-chieu-sau.md](docs/44-ty-le-khung-nhin-va-chieu-sau.md) | Thiết kế + đã làm (A, B1–B5, PF-02) | **Tỷ lệ khung nhìn + chiều sâu bản đồ (VS-1)** + §7 sửa "giật + vệt mờ phía trên" (PF-02, 08/11): màn hình to thấy rộng hơn (camera zoom ra, giao diện 90% / 85%), Tầm nhìn / Cỡ giao diện trong Cài đặt, bóng đổ + mảng sáng tối, sương / hạt bay / tiền cảnh mép dưới theo vùng; ảnh [docs/design/view-scale](docs/design/view-scale) |
| [docs/45-nghien-cuu-goc-nhin-va-nhan-vat.md](docs/45-nghien-cuu-goc-nhin-va-nhan-vat.md) | Nghiên cứu + đã làm GN-1a/b/c, GN-2 cảnh trại vùng 2–9, GN-3 bộ đếm combo + tông nền + nền đất mòn, GN-4 hình đứng thẳng + vách đá viền map (09/11) | **Góc nhìn + thiết kế nhân vật theo ảnh tham khảo ARPG 3D (GN-1)**: so sánh camera / bố cục / mặt đất / ánh sáng / tỷ lệ nhân vật; kết luận giữ 2D + chibi, giả phối cảnh nhẹ bằng shader (P1), camera động khi đánh boss (P2), nền nhiều vật liệu + bộ cảnh trại / tường cao phía xa (E1–E2), nguồn sáng điểm, AO, bóng tiếp xúc; HD-2D là phương án lớn để sau. Ảnh `docs/design/goc-nhin/` |
| [docs/46-nghien-cuu-nhac-nen.md](docs/46-nghien-cuu-nhac-nen.md) | Nghiên cứu + đã làm đợt 1 (09/11) | **MU-1 Nhạc nền** (Spec_Notes 09/11 "nhạc giả quá"): vì sao nghe "giả", 5 hướng; đã làm hướng A — 13 bài mới bằng nhạc cụ mô phỏng (sáo, nhị, đàn tranh, tỳ bà, dàn dây, hợp xướng, taiko…), OGG stereo, giai điệu soạn tay, nghỉ 30–90 giây giữa lượt, âm môi trường theo vùng, 5 nhạc báo (`tools/audio/songs2.py`, `inst2.py`); đợt 2 (10/11): tầng nhạc chiến đấu dâng lên khi đánh quái |
| [docs/47-de-xuat-nang-luc-chien-trang-bi.md](docs/47-de-xuat-nang-luc-chien-trang-bi.md) | Đề xuất + đã làm (09/11) | **NL-1 Thêm cách tăng Lực chiến cho trang bị** (Spec_Notes 09/11): 6 đường ngoài cường hoá — Khảm Ngọc Ngũ Hành (ấn hệ vũ khí +15%), Tẩy Luyện 1 dòng phụ, Thăng Phẩm bằng đồ trùng ô, Luyện Cấp đồ Cam / bộ, Thức Tỉnh (sau chuyển chức 3), Bảo Giám sưu tập; Lò Rèn thêm 6 tab (có Gợi ý), huy hiệu Lực chiến bấm được, save v32; ảnh [docs/design/nl1](docs/design/nl1) |
| [docs/CR-06-man-chon-nhan-vat-kieu-arpg.md](docs/CR-06-man-chon-nhan-vat-kieu-arpg.md) | Đã làm (10/11) | **CR-06 Màn Chọn nhân vật kiểu ARPG** (góp ý người chơi 10/11): nhân vật đang chọn đứng to giữa cảnh trước Bia Đá, danh sách dọc bên phải, nút Vào game lớn giữa đáy, nhấp đúp / phím; ảnh [docs/design/cr06](docs/design/cr06) |
| [docs/CR-05-hud-mo-khi-che-nhan-vat.md](docs/CR-05-hud-mo-khi-che-nhan-vat.md) | Đã làm (09/11) | **CR-05 HUD không che nhân vật** (Spec_Notes 09/11): bản đồ nhỏ / khung nhiệm vụ mờ còn 22% khi nhân vật đi vào dưới, rê chuột hiện rõ; 2 nút ẩn / hiện nhớ trong Cài đặt; ảnh [docs/design/cr05](docs/design/cr05) |
| [docs/CR-04-ban-do-tu-tui-va-tu-dong-ban.md](docs/CR-04-ban-do-tu-tui-va-tu-dong-ban.md) | Đề xuất + đã làm (08/11) | **CR-04 Bán đồ trong Túi + tự động xử lý đồ** (đánh giá người chơi 06/11): bán ở mọi nơi ngay trong túi, khoá đồ, quy tắc Giữ / Bán / Phân rã theo phẩm chất chạy khi nhặt hoặc khi túi đầy, mẫu cấu hình, mua lại; sửa kèm Điểm Kim "+50% vàng bán đồ" chưa áp dụng; save v31; ảnh [docs/design/cr04](docs/design/cr04) |
| [docs/43-hieu-ung-cuong-hoa.md](docs/43-hieu-ung-cuong-hoa.md) | Thiết kế + đã làm | **Hiệu ứng đồ cường hoá (EN-1)**: ánh kim / linh hoả bám dáng món đồ, vệt sáng chạy quanh viền ô theo chiều kim đồng hồ, bảng màu bậc mới, hào quang nhân vật, toast ĐỘT PHÁ; ảnh + GIF [docs/design/enhance](docs/design/enhance) |
| [docs/38-ra-soat-giao-dien-theo-tieu-chi.md](docs/38-ra-soat-giao-dien-theo-tieu-chi.md) | Rà soát + đã làm | **Giao diện theo tiêu chí chuẩn**: 10 tiêu chí (Xbox Accessibility Guidelines, Game Accessibility Guidelines, Hodent / Nielsen, vùng chạm iOS / Android, HUD nhập vai), chấm 80 màn hình, 14 vấn đề, UI-50…63 đã làm cả 3 đợt (HUD gọn, khung đồng mọi màn, tiêu đề có cảnh nền, Cài đặt 4 tab + đổi phím, trợ năng); ảnh [docs/images/ra-soat-ui](docs/images/ra-soat-ui) |
| [docs/26-build-lop.md](docs/26-build-lop.md) | Chủ dự án | Gộp docs/24 + CR-001: hệ 7 thuộc tính (thêm WIS, DEX), chỉ số khởi tạo/tự tăng theo CR-001 với hệ số quy đổi giữ thang game, đặc tính lớp, mô hình cân bằng cấp 1–100, 3 build mỗi lớp theo nhánh chức 2, Q161–Q168 |
| [docs/27-ky-nang-bi-dong.md](docs/27-ky-nang-bi-dong.md) | Đặc tả + kết quả | **Kỹ năng bị động**: 4 bị động mỗi lớp × 5 lớp (cấp 10/20/35/50, cấp 0–5, Điểm Kỹ Năng chung), tab Bị động trong bảng Kỹ năng, cân bằng PV-T3; **đã làm**, save v21 |
| [docs/29-bi-kip-diem-ky-nang.md](docs/29-bi-kip-diem-ky-nang.md) | Đặc tả + kết quả | **Bí Kíp = +1 Điểm Kỹ Năng**, biến thể ✦ mở bằng 2 điểm, bỏ Mảnh Bí Kíp, save v24; đề xuất Q171–Q175; **đã làm** |
| [docs/24-de-xuat-chi-so-lop.md](docs/24-de-xuat-chi-so-lop.md) | Chủ dự án | Đề xuất chỉ số khởi đầu và chỉ số đặc thù 5 lớp (góp ý người chơi 28/10): hồ sơ chỉ số theo sao charactors.md, Thiên tính lớp, thuộc tính tự tăng theo nghề, Q147–Q152 |
| [docs/04-ke-hoach-tien-do.md](docs/04-ke-hoach-tien-do.md) | **Theo dõi tiến độ** | 173 hạng mục của kịch bản: đã làm / một phần / chưa làm, đợt sẽ làm, việc cần làm từng đợt, quyết định đang chờ |

## Chạy nhanh

1. Mở **Godot 4.7.2** (lối tắt trên Desktop) → **Import** → chọn `godot/project.godot` → bấm **F5**.
2. Chạy test logic:

   ```bash
   "C:/Users/ADMIN/AppData/Local/Programs/Godot/Godot_v4.7.2-stable_win64_console.exe" --headless --path godot --script res://tests/run_tests.gd
   ```

Chi tiết xem [đặc tả kỹ thuật](docs/02-technical-spec.md).

## Quy ước

- Mỗi đợt phát triển: viết spec trong `03-mvp-spec.md` → duyệt → code → test → cập nhật kết quả vào spec.
- Xong mỗi đợt: cập nhật trạng thái và bảng Tổng quan trong `04-ke-hoach-tien-do.md`.
- Mỗi khi thay đổi kỹ thuật, cập nhật `02-technical-spec.md` trong cùng lần sửa code.
