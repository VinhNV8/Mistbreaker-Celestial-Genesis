# Kế hoạch và theo dõi tiến độ

| | |
| --- | --- |
| Dự án | Thiên Phú Khai Giới |
| Nguồn yêu cầu | [Kịch bản game](kich-ban-game-thien-phu-khai-gioi.md), mục 2–9 |
| Spec chi tiết | [01 — Chương 1](01-requirement-spec.md) · [03 — MVP](03-mvp-spec.md) · [02 — Kỹ thuật](02-technical-spec.md) |
| Thiết kế nội dung | [05 — 20 Thiên phú](05-thien-phu-chi-tiet.md) (cấp, kỹ năng, tiến hoá, cộng hưởng) · [06 — Bản đồ, quái, boss](06-ban-do-quai-boss.md) (9 vùng, công thức chỉ số, 36 quái thường, 18 tinh anh, 9 boss chương, 9 boss hiếm). Cả hai **đã chốt** 20/10/2026 (Q17–Q27, mục 13) · [07 — Đồ hoạ](07-do-hoa-ke-hoach.md) (phong cách, hạng mục AR-xx) · [08 — Hoàn chỉnh Chương 1](08-chuong-1-hoan-chinh.md) (kết hợp Spec_Notes) |
| Cập nhật | 20/10/2026 (sau M4 — Chương 2) |

File này liệt kê **mọi hạng mục trong kịch bản**: trạng thái hiện tại, đợt sẽ làm, và mã yêu cầu/test để kiểm chứng. Mỗi lần xong một đợt, cập nhật cột Trạng thái và phần Tổng quan.

**Ký hiệu trạng thái**

| Ký hiệu | Nghĩa |
| --- | --- |
| ✅ | Đã làm, có test tự động hoặc smoke test |
| 🟡 | Làm một phần, hoặc làm bản tạm/lệch so với kịch bản (xem Ghi chú) |
| ⬜ | Chưa làm |
| ⛔ | Không làm (không áp dụng cho game chơi đơn, hoặc đã quyết bỏ) |

**Cột Đợt:** `Proto` = prototype Chương 1 · `M1`…`M5` = các đợt MVP · `G` = nhánh đồ hoạ & âm thanh · `Alpha`, `Beta` = giai đoạn sau MVP (kịch bản mục 9).

## 1. Tổng quan

Đếm theo từng hạng mục có mã trong file này (mỗi dòng bảng = 1 hạng mục).

| Phần | Tổng | ✅ Xong | 🟡 Một phần | ⬜ Chưa làm | ⛔ Không làm |
| --- | --- | --- | --- | --- | --- |
| Thế giới quan, cốt truyện (mục 2) | 13 | 11 | 2 | 0 | 0 |
| Thiên phú (mục 3) | 42 | 29 | 7 | 6 | 0 |
| Nhân vật, chỉ số (mục 4) | 28 | 25 | 2 | 1 | 0 |
| Chiến đấu, quái (mục 5) | 23 | 21 | 0 | 1 | 1 |
| Bản đồ, vượt map (mục 6) | 13 | 11 | 0 | 2 | 0 |
| Khai phá, lãnh địa (mục 7) | 22 | 17 | 2 | 3 | 0 |
| Trang bị, kinh tế (mục 8) | 19 | 17 | 1 | 0 | 1 |
| 30 phút đầu (mục 9) | 9 | 9 | 0 | 0 | 0 |
| Đồ hoạ, âm thanh | 27 | 24 | 0 | 3 | 0 |
| Kỹ thuật, phát hành | 10 | 5 | 2 | 3 | 0 |
| **Tổng** | **206** | **169** (82%) | **16** (8%) | **19** (9%) | **2** |

### Các giai đoạn

| Giai đoạn | Phạm vi (kịch bản mục 9) | Trạng thái |
| --- | --- | --- |
| Prototype | Combat cơ bản, 1 lớp, 5 Thiên phú, 1 map, 1 boss, lưới khai phá 10 ô | ✅ Xong 19/10/2026 |
| MVP — M1 | Trang bị, cường hoá, phân rã, Lực chiến | ✅ Xong 20/10/2026 |
| MVP — M2 | Đủ 20 Thiên phú, luyện cấp, Đền Thiên Phú, công trình có thời gian xây | ✅ Xong 20/10/2026 |
| MVP — M3 | Lớp Thợ Săn, chọn lớp khi tạo nhân vật, đủ 4 kỹ năng mỗi lớp | ✅ Xong 20/10/2026 |
| MVP — C1 | **Hoàn chỉnh Chương 1**: tạo nhân vật, sửa hướng đánh, cốt truyện + hướng dẫn, 3 map con + 40 ô, boss hiếm, Xưởng Rèn, cửa hàng, âm thanh — [08](08-chuong-1-hoan-chinh.md) | ✅ Xong 20/10/2026 (còn .exe chờ tải templates) |
| MVP — M4 | Chương 2: Đồng Bằng Gió Hú, boss Huyền Ảnh, Thành Biên Đài, bản đồ lục địa, di chuyển giữa vùng | ✅ Xong 20/10/2026 (M4.1 phiên game-bc · M4.2, M4.3) |
| MVP — SN2 | **Spec_Notes đợt 2**: lớp Pháp Sư, phân rã/bán nhanh có bộ lọc, chuyển cấp cường hoá khi mặc đồ, map ×1,6, sương che bản đồ — [09](09-spec-notes-dot-2.md) | ✅ Xong 20/10/2026 (phiên game-bc) |
| MVP — M5 | Cốt truyện có thoại, hướng dẫn, nhiệm vụ, boss hiếm, Xưởng Rèn, cân bằng 1 → 20 | ✅ Xong 20/10/2026 — [03 mục 8](03-mvp-spec.md): Bạch Hổ, nhịp EXP mới, bản đồ nhỏ, câu đố Di tích, cỡ chữ, .exe. Còn chờ playtest người thật để chỉnh nhịp |
| Alpha — M6 | **Chương 3 Sa Mạc Lãng Quên**: vùng 3 (3 map, ngày/đêm, nắng gắt, ốc đảo, bão cát), 6 quái + 2 tinh anh, Bọ Cạp Sa Hoàng, Nhân Sư Đá, bộ Sa Hành Giả, 2 đồ Cam, Độn Thổ, nhiệm vụ 6 bước, chuyển chức 1 — [10](10-chuong-3.md) | ✅ Xong 21/10/2026 (phiên game-bc) |
| Alpha — M7 | **Chương 4 Đầm Lầy Mộng**: vùng 4 (nước đầm, độc tích luỹ, ảo ảnh), 4 quái + 2 tinh anh, Nữ Vương Phệ Mộng (giấc mơ đảo điều khiển), Thuỷ Quái Thất Đầu, Bộ U Minh, 2 đồ Cam, Mộng Cảnh, Lam Nhi, **tiến hoá Thiên phú lần 1**; bộ điều phối chương `core/chapters.gd` — [11](11-chuong-4.md) | ✅ Xong 21/10/2026 (phiên game-bc) |
| Alpha — M8 | **Chương 5 Núi Lửa Phẫn Nộ**: vùng 5 Núi Viêm Long (dung nham, núi lửa phun, nhiệt), 4 quái + 2 tinh anh, Viêm Long (dung nham dâng theo lượt, đá nổi), Phượng Hoàng Tro (Niết bàn), Bộ Hoả Ngục, Long Tâm, Lông Phượng, Long Tức, Thương hội Kim Luân phản bội + Công Trại (chiến tranh lãnh địa), Tinh Thạch, chuyển chức 2 (6 nhánh) — [12](12-chuong-5.md) | ✅ Xong 21/10/2026 (phiên game-c6) |
| Beta — M9 | **Chương 6 Băng Nguyên Vĩnh Dạ**: vùng 6 Băng Nguyên Bắc Cực (băng giá tích tầng → đông cứng, đêm dài, mặt băng trơn, lửa trại, Than Hồng), 4 quái + 2 tinh anh, Bản Ngã Bóng Tối (sao chép kỹ năng người chơi, Gương vỡ, Thiên phú phản chiếu), Long Băng Bắc Cực, Bộ Cực Quang, Gương Bản Ngã, Vảy Long Băng, Kính Ảnh, Đèn Cực Quang, **Ám Khí — mất kiểm soát**, sự thật về thân phận — [14](14-chuong-6.md) | ✅ Xong 21/10/2026 (phiên game-bc) |
| Beta — M10 | **Chương 7 Thiên Không Đảo**: lãnh địa cấp 3–5 + Cảng Khí Cầu, vùng 7 Quần Đảo Thiên Không (đảo bay, rơi về Đá Neo, cầu gió, đảo vỡ, Lông Vũ Gió), 4 quái + 2 tinh anh, Thiên Không Cự Thần (chiến trường thu nhỏ), Kỳ Lân Mây, Bộ Thiên Phong, Búa Cự Thần, Sừng Kỳ Lân, Thiên Chuỳ, Bia Đá gốc, **tiến hoá Thiên phú lần 2** — [16](16-chuong-7.md) | ✅ Xong 27/10/2026 (phiên game-39) — 7 test C7 + TL-B7 |
| Beta — M11 | **Chương 8 Vực Hư Vô**: Suy Thiên (Thiên phú yếu dần, Đèn Tinh Quang), không hệ, 4 quái + 2 tinh anh, Giáo Chủ Hư Vô (Hút Thiên phú), Hư Vô Thú, Bộ Tinh Quang, Ấn Hư Vô, Nanh Hư Vô, Hút Thiên Phú, Tổng tấn công Sào Huyệt, **chuyển chức 3** (Thần Kỹ) — [17](17-chuong-8.md) (rà lại 31/10 theo 5 lớp, J3, BK, map ×3) | ✅ Xong 31/10/2026 (phiên game-3f) — 6 test C8 + TL-B8, save v25 |
| Beta — M12 | **Chương 9 Thiên Đạo Chi Môn**: 9 tầng mỗi tầng một hệ, Ấn Hệ, 4 quái + 2 tinh anh (Thủ Tầng), Ma Tôn Vô Diện (cơ chế 8 boss chương), Thiên Đạo Hư Ảnh, Bộ Thiên Đạo, Mặt Nạ Vô Diện, Vô Diện, **hai kết thúc** Hợp nhất / Hiến tế, endgame tối thiểu (cấp sau 100, Thần Vực, Tái Thiết Lục Địa) — [18](18-chuong-9.md) | ✅ Xong 01/11/2026 (phiên game-3f) — 6 test C9 + TL-B9, save v26 |
| MVP — G | Đồ hoạ nhân vật, quái, bản đồ, hiệu ứng, âm thanh cho chương 1–2 | 🟡 G1 (hình chương 1, sinh bằng code) xong 20/10/2026 — [07](07-do-hoa-ke-hoach.md); còn âm thanh, khung giao diện, vùng 2 |
| Thử nghiệm kín | 50–100 người chơi (kịch bản mục 9) | ⬜ Cần M3–M5 + G |
| Alpha | 4 lớp, chương 1–5, chuyển chức 1–2, dungeon cổng ngẫu nhiên, bảng xếp hạng | ⬜ |
| Beta | Chương 1–9, endgame, boss thế giới, shop, sự kiện theo mùa | ⬜ |

## 2. Thế giới quan và cốt truyện (kịch bản mục 2)

| Mã | Hạng mục | Trạng thái | Đợt | Kiểm chứng | Ghi chú |
| --- | --- | --- | --- | --- | --- |
| CT-01 | Bối cảnh Huyền Thổ, đại nạn Thiên Liệt | ✅ | C1 | Smoke `01b-intro` | Cảnh mở đầu 5 trang (C1-10) |
| CT-02 | Nhân vật chính ở làng Thanh Thạch, Lễ Thức Tỉnh tuổi 16 | ✅ | C1 | C1-T3 | Có tên nhân vật, thoại Trưởng làng Thạch Lão (C1-11) |
| CT-03 | Bí mật "mảnh Thiên phú thứ hai" | ✅ | C1 / M9 / Beta | C6-T6, C9-T4, C9-T7 | Gợi ý ở chương 1–5; chương 6 thức giấc (Ám Khí); chương 9 (M12, 01/11): Ma Tôn gọi mảnh thứ hai dưới 10% HP, 9 dòng ký ức kể nguồn gốc mảnh, lựa chọn Hợp nhất / Hiến tế — [18](18-chuong-9.md) |
| CT-04 | Phe Liên minh Khai Giới (giao nhiệm vụ, xếp hạng) | ✅ | M4.3 | KP-T2 | Lạc Phong ở Thành Biên Đài; hạng Đồng → Bạc → Vàng theo ô chiếm vùng 2 (0/10/25) |
| CT-05 | Phe Thương hội Kim Luân (cửa hàng, đấu giá, hộ tống) | 🟡 | M8 / Alpha | C5-T5 | Chương 5: chi nhánh Kim Luân ở Trại Tro Hồng (cửa hàng, đổi Tinh Thạch), Kim Phú phản bội. Còn đấu giá, hộ tống (Q64) |
| CT-06 | Phe Thánh Đường Tinh Quang (thức tỉnh, tiến hoá Thiên phú) | 🟡 | Alpha | C4-T6 | M7: Tinh Quang Sứ ở Làng Chài Lau làm tiến hoá lần 1 ([11](11-chuong-4.md)). Còn Thánh Đường, thức tỉnh |
| CT-07 | Phe Hư Vô Giáo (phản diện) | ✅ | M4.3 | KP-T2 | Gián điệp Mạc Tam lộ mặt ở bước 4, chạy về Phủ Huyền Ảnh |
| CT-08 | Phản diện Ma Tôn Vô Diện | ✅ | M12 | C9-T4, TL-B9 | Ma Tôn Vô Diện (M12, 01/11): 3 giai đoạn dùng lại cơ chế boss chương 1–8 (Vồ, Phân thân, Độn thổ · Giấc mơ, Dung nham, Sao chép · vành vỡ, Hút Thiên phú, đổi hệ), mảnh thứ hai dưới 10%; 9 dòng ký ức tầng — [18](18-chuong-9.md) |
| CT-09 | Chương 1 — Thức Tỉnh | ✅ | C1 | C1-T4 | Đủ gameplay, boss, thoại, cảnh mở đầu, hướng dẫn, kết chương ([08](08-chuong-1-hoan-chinh.md)) |
| CT-10 | Chương 2 — Thành Biên Đài | ✅ | M4.3 | KP-T2 | 5 bước nhiệm vụ chính, 3 NPC (E), thoại, màn kết chương 2 |
| CT-11 | Chương 3–5 | ✅ | Alpha | C3-T5, C4-T5, C5-T5 | Chương 3 (M6), chương 4 (M7), chương 5 (M8: Thương hội phản bội, Công Trại, Viêm Long, chuyển chức 2) |
| CT-12 | Chương 6–9 | ✅ | M9 / M10–M12 | C6-T5, C6-T6, C8-T5, C9-T5 | Chương 6 (M9), chương 7 (M10, 27/10), chương 8 (M11, 31/10), chương 9 (M12, 01/11) — [14](14-chuong-6.md), [16](16-chuong-7.md), [17](17-chuong-8.md), [18](18-chuong-9.md) |
| CT-13 | Hai kết thúc (Hợp nhất / Hiến tế) | ✅ | M12 | C9-T7 | M12 (01/11): màn 2 thẻ + xác nhận lần 2, không đổi lại; Hợp nhất (Thiên Đạo Lực → Thần Hoá, Thần Vực) / Hiến tế (sương vùng 1–9 tan, Thiên phú +20%, lãnh địa +30%, Tái Thiết); bảng tổng kết + danh đề |

## 3. Hệ thống Thiên phú (kịch bản mục 3)

Thiết kế chi tiết từng Thiên phú (hiệu ứng Lv1 → Lv10, 2 bậc tiến hoá, cộng hưởng, tương tác 4 lớp): [05-thien-phu-chi-tiet.md](05-thien-phu-chi-tiet.md).

| Mã | Hạng mục | Trạng thái | Đợt | Kiểm chứng | Ghi chú |
| --- | --- | --- | --- | --- | --- |
| TP-01 | 1 Thiên phú chính khi vào game qua Lễ Thức Tỉnh | ✅ | Proto | AWK-01 | |
| TP-02 | 3 lần quay lại miễn phí, chọn bất kỳ lần nào | ✅ | Proto | AWK-01, 02 | |
| TP-03 | Bảo hiểm: 4 lần dưới hạng B thì lần cuối lên B | ✅ | Proto | AWK-04 | |
| TP-04 | Hiệu ứng ánh sáng theo màu hạng khi chạm Bia Đá | ✅ | C1 | Smoke `02b-awakening` | Bia Đá toả sáng theo màu hạng, hạng S trở lên có tia sáng (C1-15) |
| TP-05 | Ô Thiên phú phụ ở cấp 30 và 60, tối đa 3 Thiên phú | ✅ | 02/11 | TP5-T1, T2 | Ô mở khi chuyển chức 1 / 2; Lễ Thức Tỉnh ô phụ; cấp riêng, bị động — [33](33-thien-phu-phu-cong-huong.md) |
| TP-06 | 7 hạng F → SSS, đúng tỉ lệ quay | ✅ | M2 | TL-A | 200.000 lần quay, lệch < 0,5 điểm % |
| TP-07 | Nguyên tắc cân bằng: F và S chênh ≤ 25% | ✅ | M2 | TL-B | Chênh 7% (bot đánh boss chương 1) |
| TP-08 | Đủ 20 Thiên phú mẫu | ✅ | M2 | TL-C, TL-D | Chi tiết từng Thiên phú ở mục 3.1 |
| TP-09 | Kỹ năng chủ động hạng B, kỹ năng tối thượng hạng S | 🟡 | M2 | TL-D | Kịch bản không ghi kỹ năng cụ thể; spec tự thiết kế, **chờ duyệt Q6** |
| TP-10 | Luyện cấp Thiên phú Lv 1 → 10 bằng Tinh Hoa | ✅ | M2 | TL-G | |
| TP-11 | Mỗi 5 cấp mở 1 hiệu ứng phụ | 🟡 | M2 | TL-G | Bảng hiệu ứng phụ theo nhóm do spec đề xuất, **chờ duyệt Q11** |
| TP-12 | Tiến hoá hạng (ví dụ Tay Nhanh → Phong Ảnh Thủ → Vô Ảnh Kiếm), bắt buộc ở chương 4 và 7 | 🟡 | M7 | C4-T6 | Tiến hoá lần 1 (chương 4): tên + hạng mới, cấp hiệu dụng (D39). Tiến hoá lần 2 (M10, chương 7 bước 7 ở Bia Đá gốc; Thiên phú hết bậc → Đột Phá, C7-43/44, C7-T7) ✅. Còn hiệu ứng riêng của từng dạng (Q55) |
| TP-13 | Cộng hưởng 2 Thiên phú cùng nhóm | ✅ | 02/11 | TP13-T1 | +10% chung; 9 cặp đặc biệt — [33](33-thien-phu-phu-cong-huong.md) |
| TP-14 | Tẩy Thiên phú bằng Nước Thánh Tinh Quang, giữ 50% cấp | ✅ | 02/11 | TP14-T1 | Rơi boss hiếm 30%, cửa hàng vùng 4+ 3.000 vàng — [33](33-thien-phu-phu-cong-huong.md) |
| TP-15 | SSS "độc nhất server" | ⬜ | Beta | DT-10…15 | **Đổi từ ⛔ sang làm** theo yêu cầu 20/10/2026 ([CR-01](03-mvp-spec.md)); cần backend (KT-09, KT-10) |

### 3.1. Từng Thiên phú

| Mã | Thiên phú | Hạng | Trạng thái | Ghi chú so với kịch bản |
| --- | --- | --- | --- | --- |
| TP-20 | Thân Thể Cường Tráng | F | ✅ | |
| TP-21 | Tay Nhanh | F | ✅ | |
| TP-22 | May Mắn Nhỏ | F | 🟡 | "+5%" hiểu là cộng 5 điểm % (6% → 11%), **chờ duyệt Q7** |
| TP-23 | Chân Không Biết Mỏi | F | 🟡 | Chưa có bản đồ lớn; tạm thời +10% tốc chạy khi không giao chiến (**Q8**). Đổi lại đúng nghĩa ở M4 |
| TP-24 | Huyết Chiến | C | ✅ | |
| TP-25 | Thợ Rèn Bẩm Sinh | C | ✅ | |
| TP-26 | Khứu Giác Kho Báu | C | ✅ | Rương ẩn 30 → 45 m; Di tích 20% trên lưới 40 ô (C1-21, test C1-T6) |
| TP-27 | Kiếm Tâm | B | ✅ | Có kỹ năng L Nhất Kiếm Đoạn (bổ sung). Có thể hơi mạnh (phát hiện F4) |
| TP-28 | Nhà Thảo Dược | B | ✅ | Có kỹ năng L Linh Dược (bổ sung) |
| TP-29 | Trái Tim Lãnh Chúa | B | ✅ | Có kỹ năng L Hiệu Triệu (bổ sung) |
| TP-30 | Thuần Thú Sư | A | ✅ | M3: thu phục cả quái Ổ quái (TP-T2); ngưỡng 10% → 15% và thú cưng +0 → 50% tấn công theo cấp Thiên phú |
| TP-31 | Mắt Ưng | A | ✅ | |
| TP-32 | Hấp Huyết | A | ✅ | SN14-01 (02/11): bỏ hạn chế không dùng bình máu |
| TP-33 | Bàn Tay Vàng | A | 🟡 | "Nguyên liệu hiếm" được định nghĩa là Tinh Kim, **chờ duyệt Q10** |
| TP-34 | Ngũ Hành Linh Căn | S | 🟡 | Kịch bản ghi "dùng cả 5 hệ phép" (dành cho Pháp Sư); với Kiếm Khách làm thành đòn đánh mang hệ. SN2: Pháp Sư có Hỏa Cầu mang hệ + Bộc Phá theo Băng Ngục; 10 phép kết hợp 2 hệ để Alpha (Q46). Xem lại khi có Pháp Sư (Alpha) |
| TP-35 | Thời Gian Ngưng Đọng | S | ✅ | |
| TP-36 | Bầy Đàn Bóng Tối | S | ✅ | Có kỹ năng L Bóng Tối Trỗi Dậy (bổ sung) |
| TP-37 | Thiên Mệnh Khai Giới | SS | ✅ | |
| TP-38 | Long Mạch | SS | ✅ | |
| TP-39 | Đạo Tặc (Ẩn) — sao chép kỹ năng boss | SSS | ✅ | Vồ Mồi (Sói Chúa) + Phân Thân (Huyền Ảnh, M4.2); chọn kỹ năng L trong bảng Thiên phú |
| TP-40 | Đạo Tặc (Ẩn) — Cướp Thuộc Tính khi hạ quái | SSS | ✅ | M3 ([CR-01](03-mvp-spec.md), DT-01…08, test TP-T3). Sửa 2026-10-30: điểm cướp giữ vĩnh viễn, đầy thì không cướp thêm (trước đây thay điểm cũ nhất). Code theo mặc định Q13–Q16 — số liệu vẫn chờ duyệt |

### 3.2. Bổ sung từ thiết kế chi tiết ([05](05-thien-phu-chi-tiet.md), đã chốt Q17–Q21)

| Mã | Hạng mục | Trạng thái | Đợt | Kiểm chứng | Ghi chú |
| --- | --- | --- | --- | --- | --- |
| TP-41 | Hiệu ứng chính mạnh dần theo Lv, Lv10 = ×1,5 (05 mục 1.2) | ✅ | M3 | TP-T1 | **Q17**. 20 Thiên phú nội suy Lv1 → Lv10 theo bảng 05 mục 2.1; bảng Thiên phú hiện giá trị cấp này → cấp sau |
| TP-42 | Tiến hoá đặt lại Lv1, không tụt sức mạnh, hoàn 50% Tinh Hoa | ✅ | M7 | C4-T6 | **Q18**: cấp hiệu dụng = Lv + 9 × số lần tiến hoá; hoàn 12 Tinh Hoa |
| TP-43 | Bảng Thiên phú hiện trước cây tiến hoá (tên, hạng, điều kiện) | ✅ | C1 | Smoke `05d-talent` | **Q20** (C1-14) |
| TP-44 | Cộng hưởng đặc biệt hiện "???" kèm gợi ý cho tới khi kích hoạt | ✅ | 02/11 | TP13-T1 | **Q21**. Thợ Săn Di Tích hiện sẵn — [33](33-thien-phu-phu-cong-huong.md) |
| TP-45 | Thông báo toàn server khi có người tiến hoá lên SSS (không giới hạn độc nhất) | ⬜ | Beta | — | **Q19**. Cần backend (KT-09) |
| TP-46 | **Gift code** ở Lễ Thức Tỉnh: lượt quay thêm chỉ ra hạng A–SSS ([CR-02](03-mvp-spec.md)) | ✅ | C1 | GC-T1, GC-T2 | Bản offline: mỗi mã 1 lần mỗi máy; mỗi mã 1 lần toàn server cần backend (KT-10). Sinh mã: `python tools/giftcode.py`. GC-09: mã seri `DT…` → luôn ra Đạo Tặc (`--talent DT`) |

## 4. Nhân vật, chỉ số và lên cấp (kịch bản mục 4)

| Mã | Hạng mục | Trạng thái | Đợt | Kiểm chứng | Ghi chú |
| --- | --- | --- | --- | --- | --- |
| NV-01 | Lớp Kiếm Khách | ✅ | Proto | — | Mới có 1 kỹ năng (Xoáy Kiếm), cần đủ 4 (CB-01) |
| NV-02 | Lớp Thợ Săn | ✅ | M3 | CL-T1, CL-T2 | Bắn tên 45 m, Tấn công từ AGI, HP thấp hơn, né gốc 5%; vũ khí tên Cung. SN-07: AGI của Thợ Săn chỉ +0,6% tốc đánh (lớp khác +1%) để cân bằng vùng 2 |
| NV-03 | Lớp Pháp Sư | ✅ | SN2 | SN-T1, SN-T2, TL-B, TL-B2 | Hỏa Cầu nổ lan, Lôi Xích, Băng Ngục (trói), Thiên Thạch, Pháp Thuẫn; Tấn công từ INT, HP thấp nhất, MP +30; vũ khí tên Trượng ([09](09-spec-notes-dot-2.md)) |
| NV-04 | Lớp Hộ Vệ | ✅ | LH1 | HV-T1…T3, TL-B… | [19 mục 2](19-lop-ho-ve-trieu-hoi-su.md): VIT, Khiên −15% sát thương nhận, 13 kỹ năng (CL2), Hiệp Sĩ → Thánh Kỵ Sĩ / Thiết Vệ |
| NV-04b | Lớp Triệu Hồi Sư (CR-03) | ✅ | LH2 | TH-T1…T3, TL-B… | [19 mục 3](19-lop-ho-ve-trieu-hoi-su.md): INT, linh thú, Linh Sư → Ngự Long Sư / Đồ Đằng Sư |
| NV-05 | Chọn lớp khi tạo nhân vật | ✅ | M3 | Smoke `02b-class` | Màn hình sau Lễ Thức Tỉnh; không đổi lớp giữa chừng (Q34) |
| NV-06 | Chuyển chức 1 (cấp 30) và 2 (cấp 60) | ✅ | Alpha | C3-T6, C5-T7 | Chuyển chức 1 (M6): Kiếm Sư · Xạ Thủ · Pháp Sư Nguyên Tố. Chuyển chức 2 (M8): chọn 1 trong 2 nhánh — Kiếm Thánh / Huyết Kiếm, Thần Tiễn / Thợ Bẫy, Đại Pháp Sư / Tử Linh Sư; +10% HP/Tấn công + 2 hiệu ứng, 30 Tinh Thạch |
| NV-07 | Chuyển chức 3 (cấp 90) | ✅ | J3 → M11 | J3-T1…T3, TL-J3, C8-T5 | [23](23-chuyen-chuc-3-linh-thu-co-mau.md): đủ 5 lớp — Kiếm Thần · Thiên Lạc Xạ Thủ · Hiền Giả · Thủ Hộ Thần · Vạn Linh Chi Chủ, +10%, 2 hiệu ứng + 1 Thần Kỹ. M11 ([17](17-chuong-8.md) C8-45, 31/10): điều kiện chương 8 (hạ Giáo Chủ + 3 Lõi Hư Vô + 50 Tinh Thạch), chuyển chức ở 5 Tổ Sư (Cổng Phá Vây); Liệt Diễm chỉ đường |
| NV-07b | Linh thú có máu (Q112) | ✅ | SH | SH-T1 | [23 mục 4](23-chuyen-chuc-3-linh-thu-co-mau.md): HP theo loại, quái thường / tinh anh đánh linh thú, Thạch Quỷ khiêu khích, boss bỏ qua, Linh Hồ sinh lại sau 10 giây |
| NV-08 | Cấp tối đa 100 | ✅ | Proto | CHR-01 | |
| NV-09 | Cấp Thần Vực vô hạn (endgame) | ✅ | M12 | C9-T8 | M12.4 (01/11): cấp sau 100 cho cả hai kết thúc (Thần Vực N / Khai Thế N), EXP(100) × (1 + 0,02N), Điểm Thiên Đạo 5 nhánh, tẩy điểm ở vùng an toàn — `core/endgame.gd` |
| NV-10 | Chỉ số gốc STR, AGI, VIT | ✅ | Proto | — | |
| NV-11 | Chỉ số gốc INT | ✅ | M3 / SN2 | CL-T1, SN-T1 | +MP, hồi MP, +sát thương kỹ năng; Pháp Sư: +2 Tấn công mỗi điểm |
| NV-12 | Chỉ số gốc LUK | ✅ | M3 | CL-T1 | +0,3% chí mạng, +0,2 điểm % rơi đồ mỗi điểm (Q30) |
| NV-13 | 5 điểm mỗi cấp, tẩy điểm miễn phí trước cấp 30 | ✅ | Proto | CHR-02, 04 | |
| NV-14 | HP, Tấn công, Phòng thủ, Chí mạng, Sát thương chí mạng, Tốc đánh | ✅ | Proto / M1 | — | |
| NV-15 | MP | ✅ | M3 | CL-T3 | 50 + 5/cấp + 6/INT, hồi 3/giây; 8 kỹ năng tốn MP (Q32) |
| NV-16 | Né tránh | ✅ | M3 | CL-T4 | 0,3%/AGI, trần 30%, Thợ Săn gốc 5% (Q31) |
| NV-17 | Kháng 5 hệ | ✅ | M4.2 | CB-T9 | 5 affix Kháng hệ trên đồ phòng thủ (mũ, áo, giày, dây chuyền, bùa); quái đánh mang hệ |
| NV-18 | Lực chiến, dùng để mở map và xếp hạng | 🟡 | M1 | EQ-17 | Đã tính và hiện ở HUD; chưa hiện "trên đầu" nhân vật; chưa dùng mở map (vùng 3, Alpha) |
| NV-19 | Công thức EXP | ✅ | Proto | CHR-01 | |
| NV-20 | Nhịp độ 1 → 10 trong 30 phút | 🟡 | C1 / M5 | M5-T5, PACE-T1/T2 | M5-02 (Spec_Notes đợt 3): EXP quái 30·L^1,5 → 6,5·L^1,3, thưởng nhiệm vụ/boss tăng theo tỉ lệ nguồn EXP kịch bản. Bot chỉ đánh quái: cấp 10 sau 17–22 phút (cũ 2–3 phút), cấp 10 → 20 mất 86–89 phút. Còn chờ playtest người thật ([03 mục 8.3](03-mvp-spec.md)) |
| NV-21 | Nguồn EXP: quái, boss, khai phá | ✅ | Proto | — | |
| NV-22 | Nguồn EXP: nhiệm vụ cốt truyện (25%) | ✅ | C1 | C1-T4 | Chuỗi 11 nhiệm vụ chương 1 (C1-12) |
| NV-23 | Nguồn EXP: dungeon | ✅ | 02/11 | BD11-T1, T3 | Quái trong Cổng dungeon + EXP thưởng dọn cổng theo hạng — [34](34-dungeon-cong-ngau-nhien.md) |
| NV-24 | Nguồn EXP: offline từ lãnh địa (5%) | ✅ | M4.3 | KP-T1b | 1 × cấp EXP mỗi phút mỗi Xưởng Gỗ/Mỏ (Q42) |
| NV-25 | Quái thấp hơn 10 cấp chỉ cho 10% EXP | ✅ | M4.1 | CB-T9 | |
| NV-26 | Cảnh báo khi quên cộng điểm tiềm năng | ✅ | C1 | C1-T11 | HUD nhắc + nút Tự cộng điểm theo lớp (C1-34) |

## 5. Chiến đấu và quái vật (kịch bản mục 5)

Chỉ số, kỹ năng từng quái/boss và công thức sức mạnh theo cấp: [06-ban-do-quai-boss.md](06-ban-do-quai-boss.md).

| Mã | Hạng mục | Trạng thái | Đợt | Kiểm chứng | Ghi chú |
| --- | --- | --- | --- | --- | --- |
| CB-01 | Đánh thường + **4 kỹ năng** + 1 kỹ năng Thiên phú + né lăn | ✅ | M3 | CL-T3 | 4 kỹ năng mỗi lớp, phím 1–4 (K/chuột phải = kỹ năng 1) (Q28, Q29) |
| CB-02 | Nút Tự đánh khi cày map cũ (boss vẫn phải đánh tay) | ✅ | C1 | C1-T11 | Phím Z; tự tắt khi có boss (C1-33) |
| CB-03 | Né lăn 0,3 giây bất tử, hồi 3 giây | ✅ | Proto | CMB-03 | |
| CB-04 | Né "Hoàn hảo" làm chậm thời gian 1 giây | ✅ | M3 | CB-T3 | Chặn đòn trong 0,15 giây đầu của né lăn → quái và đạn chậm còn 30% trong 1 giây |
| CB-05 | Ngũ hành tương khắc +30% | ✅ | M2 | TL-C, NL1-T1 | Quái đã có hệ. Ngũ Hành Linh Căn đổi hệ đòn (+30%); NL-1 (09/11): mọi lớp ấn hệ vũ khí bằng 2 ngọc cùng hệ (+15%) — [47](47-de-xuat-nang-luc-chien-trang-bi.md) |
| CB-06 | Thanh Phá Thế ở boss | ✅ | Proto | MOB-07 | |
| CB-07 | Thanh Phá Thế ở quái tinh anh | ✅ | M3 | CB-T4 | 30% HP, choáng 3 giây, +50% sát thương; hiện dưới thanh máu |
| CB-08 | Combo tăng EXP (+20% ở 100 combo) | ✅ | Proto | CMB-05 | |
| CB-09 | Công thức sát thương | ✅ | Proto | CMB-04 | |
| CB-10 | Quái thường 4–6 loại mỗi map | ✅ | M4.2 | CB-T7 | Vùng 1: 4 loại; vùng 2: 4 loại + 2 tinh anh |
| CB-11 | Quái tinh anh: viền sáng, rơi đồ xanh/tím | ✅ | M1 | EQ-04 | |
| CB-12 | Quái tinh anh có 1 kỹ năng đặc biệt riêng | ✅ | M3 | CB-T5 | Sói Đầu Đàn: Hú gọi · Nấm Mẹ: Sinh sôi (Nấm Con tự nổ) (Q33) |
| CB-13 | Thủ lĩnh cứ điểm canh ô đất | ✅ | Proto | EXP-05 | Dạng Ổ quái |
| CB-14 | Boss vùng 2–3 giai đoạn, rơi Tinh Hoa | ✅ | Proto / M2 | MOB-06…10, TL-G | |
| CB-15 | Boss hiếm, xuất hiện 2 lần/ngày, rơi đồ Cam | ✅ | C1 / M5 | C1-T7, M5-T1…T3 | Lão Thụ Sương Mù ở Lõi Sương (C1-23, rơi Vỏ Lão Thụ); Bạch Hổ Phong Vân ở Mắt Bão (M5-01, rơi Vuốt Bạch Hổ). Mỗi boss có lịch 12 giờ riêng |
| CB-16 | Boss thế giới (cả server) | ⛔ | Beta | — | Cần online; xem lại khi có backend |
| CB-17 | Boss chương 1 Sói Chúa Hư Vô | ✅ | Proto | MOB-06…10 | |
| CB-18 | Boss chương 2 Tướng Gián Điệp Huyền Ảnh (phân thân 3, bản thật có bóng) | ✅ | M4.2 | CB-T8, TL-B2 | 18.804 HP; Ám tiễn, Thoắt ẩn, 2 → 4 bản sao không bóng, đổi chỗ mỗi 6 giây |
| CB-19 | Boss chương 3–5 | ✅ | Alpha | C3-T4, C4-T4, C5-T4, TL-B3, TL-B4, TL-B5 | Sa Hoàng + Nhân Sư (chương 3), Nữ Vương + Thất Đầu (chương 4), Viêm Long (dung nham dâng theo lượt, Đá Nổi) + Phượng Hoàng Tro (Niết bàn) (chương 5) |
| CB-20 | Boss chương 6–9 | ✅ | M9–M12 | TL-B6…B9 | Bản Ngã Bóng Tối, Thiên Không Cự Thần, Giáo Chủ Hư Vô, Ma Tôn Vô Diện + boss hiếm (cập nhật 02/11) |
| CB-21 | Chỉ số quái tính bằng công thức mới (06 mục 1) thay cho bảng số cứng | ✅ | M3 | CB-T1 | **Q22**. `Formulas.mob_stats()` giống hệt `tools/gen_world_doc.py` |
| CB-22 | Số đòn mục tiêu: thường 3, tinh anh 12, boss chương 1 = 90 / chương 2–3 = 110 / chương 4+ = 130, boss hiếm 200 | ✅ | M3 | CB-T1, TL-B | **Q23**. Sói Chúa 4.023 HP; bot mặc bộ đồ chuẩn hạ trong khoảng 30 giây (phát hiện F7) |
| CB-23 | Khoá hang boss khi boss đã xuất hiện (không đánh xa từ ngoài hang) | ✅ | M3 | TL-B | Bổ sung trong M3 (03 mục 5.12): bot Thợ Săn phát hiện lỗ hổng |

## 6. Bản đồ và vượt map (kịch bản mục 6)

Chi tiết 9 vùng × 3 map con, cơ chế môi trường có số liệu, bộ trang bị và đồ Cam từng vùng: [06-ban-do-quai-boss.md](06-ban-do-quai-boss.md).

| Mã | Hạng mục | Trạng thái | Đợt | Kiểm chứng | Ghi chú |
| --- | --- | --- | --- | --- | --- |
| BD-01 | Vùng 1 Rừng Sương (cấp 1–10, hệ Mộc) | ✅ | C1 | C1-T5 | Map 1-1 Rừng Sương + map 1-3 Lõi Sương (M4.1) |
| BD-02 | Vùng 2 Đồng Bằng Gió Hú (cấp 10–20, hệ Kim, gió đẩy lùi) | ✅ | M4.2 | GI-T1 | 3 map Cửa Gió, Thảo Nguyên Hú, Mắt Bão; gió đổi 12/8 giây |
| BD-03 | Vùng 3–5 | ✅ | Alpha | C3-T1, C4-T1, C5-T1 | Vùng 3 (M6), vùng 4 (M7), vùng 5 Núi Viêm Long (M8: mở bằng hạ Nữ Vương + tiến hoá 1 lần + cấp 44; dung nham, núi lửa phun, nhiệt) |
| BD-04 | Vùng 6–9 | ✅ | M9 / Beta | C6-T1, C6-T2 | Vùng 6 Băng Nguyên Bắc Cực (M9: mở bằng chuyển chức 2 + hạ Viêm Long + cấp 59; băng giá, đêm dài, mặt băng trơn). Vùng 7 Quần Đảo Thiên Không (M10: Hoàng Thành + Cảng Khí Cầu + hạ Bản Ngã + cấp 71; đảo bay, cầu gió, đảo vụn) ✅. Vùng 8 Vực Hư Vô (M11: tiến hoá 2 lần + hạ Cự Thần + cấp 83; Suy Thiên, Đèn Tinh Quang, Cột Đá, không hệ) ✅ 31/10. Vùng 9 Cổng Thiên Đạo (M12: chức 3 + Giáo Chủ + cấp 94; 9 tầng theo hệ, Ấn Hệ, Cửa Tầng) ✅ 01/11 |
| BD-05 | Điều kiện mở map: đủ cấp + hạ boss vùng + khai phá ≥ 60% | ✅ | M4.2 | MP-T2 | Vùng 2: hạ Sói Chúa + 60% vùng 1 + thử thách vượt ải (cấp ≥ 5) |
| BD-06 | 3 map con mỗi vùng + dungeon boss | ✅ | C1 / M4.2 | C1-T6 | Vùng 1: 2 map (Q35) + lưới 3 map con; vùng 2: 3 map + Phủ Huyền Ảnh |
| BD-07 | Bản đồ lục địa, di chuyển giữa các vùng | ✅ | M4.1 | MP-T1 | Phím N |
| BD-08 | Cứ điểm chiếm được thành điểm dịch chuyển | ✅ | M4.1 | MP-T1 | Vào map lần đầu mở điểm dịch chuyển |
| BD-09 | Thử thách vượt ải: vào map cao hơn 5 cấp, thắng được EXP ×2 | ✅ | M4.1 | MP-T2 | |
| BD-10 | 3 độ khó mỗi vùng (Thường / Ác mộng / Địa ngục) | ⬜ | Beta | — | |
| BD-11 | Dungeon cổng ngẫu nhiên hạng E → S, tồn tại 2 giờ | ✅ | 02/11 | BD11-T1…T3 | Mỗi 5 phút 50% mở cổng trên map đã tới (tối đa 2), 2 giờ chơi, khung hang phụ, Chúa Cổng; save v29 — [34](34-dungeon-cong-ngau-nhien.md) |
| BD-12 | Bản đồ rộng hơn (Spec_Notes S6) | ✅ | SN2 | SN-T5 | Mọi map ×1,6 mỗi chiều; quái, cây, thảo dược, rương nhân theo diện tích (trần 40 quái) |
| BD-13 | Sương che bản đồ: đi tới đâu thấy đất tới đó (Spec_Notes S7) | ✅ | SN2 | SN-T5, SN-T6 | Ô 64 px, mở 36 m quanh nhân vật; % khám phá ở HUD và bảng N; thưởng 50% (+1 Đuốc), 90% (+1 Tinh Hoa, vàng) |

## 7. Khai phá vùng đất mới (kịch bản mục 7)

| Mã | Hạng mục | Trạng thái | Đợt | Kiểm chứng | Ghi chú |
| --- | --- | --- | --- | --- | --- |
| KP-01 | Lưới ô lục giác bị sương mù che | ✅ | C1 | C1-T6 | Vùng 1: 40 ô (C1-21) |
| KP-02 | Đuốc Khai Giới, tối đa 10, hồi 1 cái/20 phút | 🟡 | Proto | EXP-03 | Đang hồi 2 phút/cái để test nhanh; quyết định giá trị thật sau playtest |
| KP-03 | Do thám → khám phá sự kiện → chinh phục | ✅ | Proto | EXP-02, 05 | |
| KP-04 | Chinh phục bằng giải câu đố | ✅ | M5 | M5-T8 | Ô Di tích: Trận Đèn Cổ 3 × 3 hoặc câu hỏi cổ thư (cốt truyện, ngũ hành); giải được thưởng ×2 + 1 Đá Cường Hoá, sai khoá 30 giây; vẫn có "Phá khoá" thưởng thường (M5-04, `core/puzzle.gd`) |
| KP-05 | Xây công trình theo địa hình: rừng → Xưởng Gỗ | ✅ | Proto / M2 | EXP-04, TL-F | |
| KP-06 | Núi → Mỏ, sông → Bến Cá | ✅ | M4.3 | KP-T1b | Mỏ 4 Đá + 2 Sắt/phút; Bến Cá +3% HP mỗi cái (tối đa 15%) |
| KP-07 | Phòng thủ: Triều Hư Vô mỗi 24 giờ chiếm lại công trình không được bảo vệ | 🟡 | M8 / Alpha | C5-T6 | M8: Công Trại (giữ cổng 3 đợt) + đột kích Kim Luân mỗi 30 phút chơi ở vùng 5 — thua thì Mỏ vùng 5 ngừng 30 phút (Q59). Còn mất ô vĩnh viễn, Doanh Trại (KP-17) |
| KP-08 | Sự kiện Tài nguyên, Ổ quái, Di tích, Người sống sót, Kỳ quan | ✅ | Proto | EXP-01 | |
| KP-09 | Sự kiện Thương nhân lữ hành (bán đồ hiếm, 1 giờ) | ✅ | C1 | C1-T10 | 3 ô trên lưới vùng 1 (C1-32) |
| KP-10 | Sự kiện Cổng dungeon | ✅ | 02/11 | BD11-T2 | Dọn sương 1 ô: 7% lộ Cổng dungeon trên map đang đứng (bảng sự kiện ô KP-11 giữ nguyên) — [34](34-dungeon-cong-ngau-nhien.md) |
| KP-11 | Tỉ lệ sự kiện theo bảng kịch bản (35/25/12/10/8/7/3%) | ✅ | C1 | C1-T6 | 40/28/12/10/8/2% — Cổng dungeon (7%) để Alpha, dồn sang Tài nguyên, Ổ quái |
| KP-12 | Trung tâm lãnh địa: Trại → Thôn | ✅ | Proto / M2 | TL-F | |
| KP-13 | Trung tâm lãnh địa: Trấn → Thành → Hoàng Thành | ✅ | M10 | C7-T1 | Spec [16](16-chuong-7.md) C7-02, C7-03: cần số ô đã chiếm 40/80/120 + Gỗ/Đá/Sắt/Tinh Thạch, mỗi cấp +10% sản lượng |
| KP-14 | Đền Thiên Phú | ✅ | M2 | TL-G | |
| KP-15 | Xưởng Rèn (chế trang bị) | ✅ | C1 | C1-T9 | Chế theo ô, Xanh lá/Xanh dương/Tím 60/35/5% (C1-30) |
| KP-16 | Vườn Thảo Dược (thuốc) | ✅ | C1 | C1-T9 | 1 thảo dược mỗi 3 phút, cả khi offline (C1-31) |
| KP-17 | Doanh Trại, Tháp Canh | ⬜ | Alpha | — | |
| KP-18 | Cảng Khí Cầu (đi vùng 7) | ✅ | M10 | C7-T1 | Spec [16](16-chuong-7.md) C7-04: xây khi Hoàng Thành, mở cổng Bến Khí Cầu 6-3 → 7-1 |
| KP-19 | Dân cư có kỹ năng nghề, xếp vào công trình | ⬜ | Alpha | — | Hiện người sống sót chỉ +10% sản lượng |
| KP-20 | Thu hoạch offline tối đa 12 giờ | ✅ | Proto | EXP-09 | |
| KP-21 | Thiên phú ảnh hưởng khai phá: Mắt Ưng, Trái Tim Lãnh Chúa | ✅ | Proto / M2 | TL-C, TL-F | |
| KP-22 | Thiên phú ảnh hưởng khai phá: Khứu Giác (Di tích 20%), Thuần Thú (quái Ổ quái) | ✅ | M3 / C1 | TP-T2, C1-T6 | |

## 8. Trang bị, kinh tế và vòng lặp (kịch bản mục 8)

| Mã | Hạng mục | Trạng thái | Đợt | Kiểm chứng | Ghi chú |
| --- | --- | --- | --- | --- | --- |
| TB-01 | Túi đồ (inventory) | ✅ | M1 | EQ-09, 18 | Phím I, 30 ô |
| TB-02 | 8 ô trang bị | ✅ | M1 | EQ-01 | |
| TB-03 | 5 phẩm chất, đúng số affix | ✅ | M1 | EQ-02 | |
| TB-04 | Bộ trang bị mỗi vùng (2/4/6 món) | ✅ | M1 / M4.2 | TB-T1 | Bộ Thợ Săn Sương (vùng 1), Bộ Phong Hành (vùng 2) |
| TB-05 | Bộ cộng hưởng với nhóm Thiên phú (ví dụ "Người Khai Hoang") | ✅ | M4.3 | — | Thợ Săn Sương ≥ 4 + Chiến đấu: +5% chí mạng; Phong Hành ≥ 4 + Khai phá: +10% tốc chạy, +1 Đuốc |
| TB-06 | Cường hoá +1 → +15, thất bại không mất đồ | ✅ | M1 | EQ-12, 13 | Từ +10 cần Tinh Kim (M2, **Q10**) |
| TB-07 | Phân rã | ✅ | M1 | EQ-14 | |
| TB-08 | Khảm ngọc ngũ hành, đổi hệ vũ khí | ✅ | NL-1 | NL1-T1 | [47](47-de-xuat-nang-luc-chien-trang-bi.md) làm 09/11: lỗ ngọc theo phẩm chất, 5 loại ngọc cấp 1–10, ghép 3 → 1, rơi theo hệ quái, ấn hệ vũ khí +15%; save v32 |
| TB-09 | Đồ Cam có hiệu ứng riêng | 🟡 | M1 / C1 / M4.2 / M8 | EQ-16, C1-T7, TB-T1, C5-T4 | Nanh Sói Chúa, Vỏ Lão Thụ, Mặt Nạ Huyền Ảnh, Vuốt Bạch Hổ, đồ Cam chương 3–4, Long Tâm, Lông Phượng, Gương Bản Ngã, Vảy Long Băng |
| TB-10 | Vàng, Gỗ, Thiên Phú Tinh Hoa, Đuốc | ✅ | Proto / M2 | — | |
| TB-11 | Đá, Sắt, Tinh Thạch | ✅ | M4.3 / M8 | KP-T1b, C5-T5 | Đá, Sắt từ Mỏ vùng 2–4; **Tinh Thạch từ Mỏ vùng 5–6** (+1/phút): 30 để chuyển chức 2, 5 → 1 Tinh Kim ở Trại Tro Hồng |
| TB-12 | Mua bình thuốc bằng vàng, bán đồ lấy vàng | ✅ | C1 | C1-T10 | Cửa hàng làng (phím E) (C1-32) |
| TB-13 | Vòng lặp chiến đấu ↔ khai phá ↔ lãnh địa | ✅ | Proto | — | |
| TB-15 | Mặc đồ mới nhận cấp cường hoá của đồ cũ (Spec_Notes S4) | ✅ | SN2 | SN-T4 | Đồ cũ cao hơn thì 2 món **đổi cấp** (Q47); chi tiết đồ báo trước, Lực chiến so sánh tính cả cấp chuyển |
| TB-16 | Phân rã nhanh có bộ lọc (Spec_Notes S2, S3) | ✅ | SN2 | SN-T3 | Lọc theo phẩm chất, giữ đồ cường hoá, giữ đồ bộ, chỉ đồ yếu hơn; lưu trong save |
| TB-17 | Bán nhanh ở cửa hàng có bộ lọc (Spec_Notes S5) | ✅ | SN2 | SN-T3 | Cùng bộ lọc với phân rã nhanh |
| TB-18 | Bán đồ ngay trong Túi + tự động bán / phân rã theo cấu hình (CR-04, đánh giá người chơi 06/11) | ✅ | CR-04 | CR4-T1…T7 | [CR-04](CR-04-ban-do-tu-tui-va-tu-dong-ban.md) làm 08/11: bán ở mọi nơi, khoá đồ, tab Tự động (Khi nhặt / Khi túi đầy, Giữ / Bán / Phân rã theo phẩm chất, 3 mẫu), mua lại 10 món, Điểm Kim +50% vàng; save v31 |
| TB-19 | Bản đồ nhỏ / khung nhiệm vụ mờ khi che nhân vật + nút ẩn / hiện (CR-05, Spec_Notes 09/11) | ✅ | CR-05 | CR05-T1 | [CR-05](CR-05-hud-mo-khi-che-nhan-vat.md) làm 09/11: mờ còn 22% khi nhân vật đi vào dưới khung, rê chuột hiện rõ, 2 nút ẩn / hiện gắn ở góc mỗi khung, nhớ trong Cài đặt; sửa kèm vành la bàn (lớp nướng) không mờ theo |
| TB-20 | Thêm cách tăng Lực chiến cho trang bị ngoài cường hoá (NL-1, Spec_Notes 09/11) | ✅ | NL-1 | NL1-T2, NL2-T1, NL2-T2, NL3-T1, NL3-T2 | [47](47-de-xuat-nang-luc-chien-trang-bi.md) làm 09/11: Tẩy luyện 1 dòng, Thăng phẩm bằng đồ trùng ô, Luyện cấp đồ Cam / bộ, Thức Tỉnh (sau chuyển chức 3), Bảo Giám, tab Gợi ý + huy hiệu Lực chiến bấm được, thẻ đồ tách Lực chiến món |
| TB-14 | Ngọc Thiên Đạo (tiền nạp), Battle Pass, thẻ tháng, ngoại hình | ⛔ | Beta | — | Cần backend; nếu bán mua đứt trên Steam thì bỏ |

## 9. Kịch bản 30 phút đầu (kịch bản mục 9)

| Mã | Phút | Cảnh | Trạng thái | Đợt | Ghi chú |
| --- | --- | --- | --- | --- | --- |
| TN-01 | 0–2 | Cutscene Thiên Liệt, giọng kể | ✅ | C1 | Cảnh mở đầu 5 trang, chữ chạy (chưa có giọng đọc) |
| TN-02 | 2–4 | Tạo nhân vật: chọn ngoại hình, lớp | ✅ | C1 | Tên, giới tính, da, tóc, màu tóc, lớp trên 1 màn hình (C1-02) |
| TN-03 | 4–7 | Lễ Thức Tỉnh, lời Trưởng làng | ✅ | Proto | |
| TN-04 | 7–10 | Hướng dẫn combat: quái tấn công làng, học đánh/né/kỹ năng | ✅ | C1 | Nhiệm vụ 1–3: 3 Sói Sương ở cổng làng, học kỹ năng, học né (C1-12) |
| TN-05 | 10–15 | Rừng Sương: lên cấp 5, nhặt đồ xanh đầu tiên | ✅ | Proto / M1 | EQ-05 |
| TN-06 | 15–19 | Khai phá đầu tiên, gặp người sống sót | ✅ | Proto | |
| TN-07 | 19–23 | Xây công trình đầu tiên, cộng điểm | ✅ | Proto / M2 | |
| TN-08 | 23–28 | Boss Sói Chúa 2 giai đoạn, thanh Phá Thế | ✅ | Proto | |
| TN-09 | 28–30 | Bản đồ lục địa hiện ra, vùng 2 sáng lên | ✅ | C1 / M4 | Màn kết chương vẽ lục địa 9 vùng, rồi mở bản đồ lục địa (C1-13, MP-06) |

## 10. Đồ hoạ và âm thanh (nhánh G)

Phong cách đã chốt: **pixel art góc trên xuống 3/4, sinh bằng code** (kịch bản mục 9 hỏi *"pixel art, 2.5D anime hay 3D low-poly?"*). Chi tiết, nghiên cứu, hạng mục AR-xx: [07-do-hoa-ke-hoach.md](07-do-hoa-ke-hoach.md). Công cụ: skill Claude Code `game-art` + `tools/art/`.

| Mã | Hạng mục | Trạng thái | Đợt | Ghi chú |
| --- | --- | --- | --- | --- |
| DH-01 | **Chốt phong cách đồ hoạ** | ✅ | G1 | Pixel art 3/4, frame 24/32/48 px, ×2, sinh bằng code (07 mục 1.2). **03/11/2026: đổi sang HD vector cel-shade (Q176 = B) — UI-40…49, [35](35-de-xuat-giao-dien-moi.md)** |
| DH-02 | Sprite nhân vật Kiếm Khách: đứng, chạy, chém, Xoáy Kiếm, né, trúng đòn, chết | ✅ | G1 | AR-10. Xoáy Kiếm = frame chém + nháy sáng + vòng vector; né = mờ |
| DH-03 | Sprite nhân vật Thợ Săn | ✅ | G1 / M3 | AR-11: có trong game từ M3; thêm 8 icon kỹ năng, tên bay, kiếm khí, bẫy (AR-41) |
| DH-04 | Sprite quái: Sói Sương, Nấm Độc, Tinh Linh Sương (+ biến thể tinh anh) | ✅ | G1 | AR-12, AR-13 (thêm Mộc Tinh). Tinh anh: cùng hình, to hơn, ánh vàng, vòng chân |
| DH-05 | Sprite boss Sói Chúa Hư Vô (2 giai đoạn, tàng hình) | ✅ | G1 | AR-14: 48×48, bờm Hư Vô, mắt đỏ, hào quang; giai đoạn 2 ánh đỏ; tàng hình = mờ |
| DH-06 | Đồng minh: thú cưng, lính bóng tối | ✅ | G1 | AR-15: hình quái gốc, vòng xanh / tô tím |
| DH-07 | Tileset Rừng Sương, Làng Thanh Thạch, Hang Sói Chúa (dùng TileMap của Godot) | ✅ | G1 | AR-16: lát ô bằng đa giác UV (không cần TileMap), 4 loại cây, bụi, nhà, Bia Đá |
| DH-08 | Tileset Đồng Bằng Gió Hú, Thành Biên Đài | ✅ | M4.2 | Nền thảo nguyên, đá, cỏ cao, nhà đá, tháp, nền thành; 6 quái + boss + bản sao + 3 NPC |
| DH-09 | Icon 8 ô trang bị × 5 phẩm chất, icon tài nguyên, icon 20 Thiên phú | ✅ | G1 | AR-17…20: 41 icon; phẩm chất vẽ bằng khung màu |
| DH-10 | Hiệu ứng (VFX): chém, kỹ năng, vòng báo hiệu, ánh sáng Bia Đá theo hạng | ✅ | G1 / C1 | Thêm: Bia Đá theo hạng, hiệu ứng cường hoá (N8), Rễ Trói, Lá Độc, vũng độc |
| DH-11 | Giao diện có art (khung, nút, font chính thức) | ✅ | G | Thanh kỹ năng có khung trang trí (ô tròn viền vàng, hồi chiêu quét tròn); mọi bảng phủ + khung HUD dùng `ui/frame_box.gd` (nền gỗ, viền vàng 2 lớp, hoa văn góc); nút gỗ/vàng nổi khối; font chính thức **Be Vietnam Pro** (OFL) đóng gói ở `assets/fonts` |
| DH-12 | Âm thanh: đánh, trúng đòn, nhặt đồ, lên cấp, giao diện | ✅ | C1 | 16 hiệu ứng sinh bằng code (`tools/audio`) |
| DH-13 | Nhạc nền: làng, rừng, boss | ✅ | C1 | Làng, Rừng Sương, Lõi Sương, Boss — vòng lặp sinh bằng code |
| DH-14 | **Thiết kế lại VFX 70 kỹ năng (FX-1)** theo board Pinterest "game skill effects": cel-shade 4 dải + glow cộng, bản sắc 5 lớp, nhịp 12 khung; bản duyệt HD `docs/design/skills-fx`; **trong game** vẽ vector HD (`view/fx1.gd`), mặc định FX-1 cả 70 kỹ năng, hình cũ vẫn chọn được (Cài đặt "Hiệu ứng kỹ năng") | ✅ | 03/11 | FX1-T1, smoke `tests/fx1_smoke.gd` 5 lớp — [36](36-thiet-ke-lai-vfx-ky-nang.md) (Q180–Q183 đã duyệt) |
| DH-15 | **Icon kỹ năng IC-1**: vẽ lại 51 icon vẽ bằng code cùng phong cách 19 icon vẽ tay + FX-1, HD 128×128, đã vào game qua lớp phủ HD | ✅ | 03/11 | IC1-T1, `tests/ic1_bar.gd` — [37](37-icon-ky-nang.md) (Q184 đã duyệt) |
| DH-16 | **Rà soát giao diện theo tiêu chí chuẩn + làm lại (UI-50…63)**: 10 tiêu chí (XAG, GAG, Hodent / Nielsen, vùng chạm, HUD), 14 vấn đề; làm 3 đợt — HUD gọn (chữ nổi, tên quái, dải nhặt đồ, máu thấp), một ngôn ngữ khung đồng cho mọi màn, tiêu đề có cảnh nền, Cài đặt 4 tab + đổi phím, trợ năng | ✅ | 04/11 | UI38-T1, smoke — [38](38-ra-soat-giao-dien-theo-tieu-chi.md) (Q185–Q189 theo đề xuất) |
| DH-17 | **Icon trang bị HD (EQ-HD)**: nghiên cứu ảnh mẫu Pinterest (icon MMORPG) → skill `equipment-design`; 336 icon (12 dáng × 2 biến thể × 5 phẩm chất + 9 bộ), vũ khí đúng kiểu từng lớp; đã thử trong game (bật khi Đồ hoạ HD) | 🧪 chờ duyệt | 05/11 | EQ1-T1, `tests/eq_bag.gd` — [40](40-icon-trang-bi.md) (Q193, Q194) |
| DH-18 | **Giao diện xem đồ (UI-64…66) + icon có khối (EQ-HD v2)**: nghiên cứu inventory các game; ô đồ theo bậc (nền nhuộm + khung riêng từng bậc), thẻ thông tin mới dùng chung (dải đầu màu phẩm chất, icon lớn, chỉ số to + biểu tượng, chip so sánh), icon thêm lớp "tranh vẽ" + quầng tách lớp | ✅ | 05/11 | EQ1-T1, SN11-T1/T2, smoke — [42](42-giao-dien-xem-do.md) (Q202, Q203) |
| EN-1 | **Hiệu ứng đồ cường hoá** (Spec_Notes 06/11): hướng D (ánh kim +4…+12, linh hoả +13…+15) + vệt sáng chạy quanh viền ô; bảng màu bậc mới; hào quang nhân vật; toast có icon + ĐỘT PHÁ | ✅ | 06/11 | EN1-T1, SN10-T1, smoke — [43](43-hieu-ung-cuong-hoa.md) |
| VS-1 | **Tỷ lệ khung nhìn + chiều sâu bản đồ** (phản ánh người chơi 06/11: toàn màn hình "to quá", map thiếu chiều sâu): camera zoom ra + cỡ giao diện theo độ phân giải, Tầm nhìn / Cỡ giao diện trong Cài đặt, khung nhiệm vụ thu gọn; bóng đổ một hướng sáng, mảng nắng / bóng râm, hạ tông nền; sương xa, hạt bay, tia nắng, tiền cảnh mép theo vùng | ✅ | 06/11 | VS1-T1, smoke 1366 / 1920 — [44](44-ty-le-khung-nhin-va-chieu-sau.md) (B6 sau) |
| GN-1 | **Góc nhìn có chiều sâu + cảnh trại** (ảnh tham khảo ARPG 3D, [45](45-nghien-cuu-goc-nhin-va-nhan-vat.md)): nghiêng phối cảnh (Cài đặt → Phối cảnh), zoom gần khi đánh boss, camera dẫn hướng; quầng sáng đuốc / đèn, bóng sát chân, tông nền vùng 1, lối mòn mép mềm; rào cọc / chòi canh / cờ quanh đấu trường + bãi trại bỏ hoang + đồ vương vãi vùng 1 | ✅ | 09/11 | GN1-T1, ảnh `docs/design/goc-nhin/` + GN-2 09/11: cảnh trại vùng 2–9 + GN-3: bộ đếm combo, tông nền 9 vùng, nền đất mòn + GN-4: hình đứng thẳng, vách đá viền map, thành hồ / hố (còn: bậc / cầu có va chạm) |
| UI-40 | **G0 bản thử HD cel-shade**: bộ vẽ vector `tools/art/hd/`, Sói Sương, Sói Chúa, cảnh Rừng Sương, 10 icon (03/11: **gỡ Kiếm Khách HD** — nhân vật + kỹ năng giữ hình gốc); lớp phủ `hd` trong manifest, bật / tắt ở Cài đặt | ✅ | 03/11 | UI40-T1; ảnh so sánh `03g-hd-scene` / `03g2-pixel-scene` — **chờ chủ dự án duyệt** [35](35-de-xuat-giao-dien-moi.md) |
| UI-40b | **Làng Thanh Thạch HD** (chủ dự án 03/11: "khu vực thôn xấu quá, cần giống thực tế"): 3 kiểu nhà gỗ mái ngói / mái tranh, sân đất nện mép lượn + sân lát đá, hàng rào cọc gỗ thay vòng viền, giếng, thùng hàng, đèn lồng, ruộng rau + đống rơm ngoài rào, bia đá HD; Cổng Dịch Chuyển đặt ở khoảng trống | ✅ | 03/11 | UI40b-T1; `03h-village` — [35 §9](35-de-xuat-giao-dien-moi.md) |
| UI-40c | **Toàn bộ map 9 vùng HD** (chủ dự án 03/11: "các map khác cũng xấu, giả tạo"): khu an toàn theo chủ đề vùng (nhà / lều / nhà sàn / lò rèn / nhà gỗ tuyết / đình / miếu, rào riêng, đồ vật, cảnh quanh), Thành Biên Đài, 18 nền + ~40 cảnh vật HD, mảng loang mềm | ✅ | 03/11 | UI40b-T1 — [35 §10](35-de-xuat-giao-dien-moi.md) |
| UI-41 | **Giao diện đồng chạm khắc theo ảnh mẫu** (chủ dự án 03/11 chọn 6 phần): khung đồng + ngọc + nền rêu + chữ cổ cho mọi khung, thanh kỹ năng ô vuông viền theo hệ + phím treo + rồng / sư tử, thanh EXP tím dưới đáy, cụm nút tròn góc phải bấm / chạm được, bản đồ nhỏ la bàn tròn N/E/S/W + nút +/−, cuộn nhiệm vụ giấy da + dấu sáp + thanh tiến độ | ✅ | 03/11 | UI41-T1, M5-T6 — [35 §11](35-de-xuat-giao-dien-moi.md) |
| UI-42…45 | G1 còn lại: khung nhân vật góc trái, màn tiêu đề / tạo nhân vật có minh hoạ, bảng phủ bên trong, icon 128 px toàn bộ, chuyển cảnh | ⬜ | — | Chờ chủ dự án duyệt UI-41 |
| UI-46 | G2: thú cưng, đồng minh, NPC (**không** vẽ lại 5 lớp nhân vật / kỹ năng — hình gốc của chủ dự án) | ⬜ | — | Cần chủ dự án đồng ý |
| UI-47 | G3 quái 9 vùng, boss vùng, boss hiếm, boss cuối — **MD-1**: 85 quái / tinh anh / boss vẽ lại HD theo ảnh mẫu Pinterest (cartoon vẽ tay), skill `monster-design` | ✅ | 04/11 | MD1-T1 — [39](39-thiet-ke-lai-quai-vat.md) (Q190 / Q192 duyệt 09/11: 9 linh thú vào game, giữ sói mới; Q191 chờ chơi thử) |
| UI-48, 49 | G4 cảnh 9 vùng + hiệu ứng kỹ năng cùng phong cách | ⬜ | — | |
| CR-06 | **Màn Chọn nhân vật kiểu ARPG cổ điển** (góp ý người chơi 10/11 "giống màn chọn nhân vật của Diablo") — nhân vật đứng to giữa cảnh trên bệ đá trước Bia Đá, danh sách dọc bên phải, nút Vào game lớn giữa đáy | ✅ | CR-06 | [CR-06](CR-06-man-chon-nhan-vat-kieu-arpg.md) làm 10/11: CS-01…09 (gồm góp ý 2: mở game vào thẳng màn chọn, nhân vật chơi cuối hiện sẵn), `ui/char_select.gd`, sprite `pcx-<lớp>` cắt ở độ phân giải gốc sheet (không vẽ lại); test CR06-T1, ảnh `design/cr06/` |

Khi có art, chỉ cần thay `scripts/view/world_view.gd` (vẽ) và theme UI; logic game không đổi (technical spec, quyết định D2, D6).

## 11. Kỹ thuật và phát hành

| Mã | Hạng mục | Trạng thái | Đợt | Ghi chú |
| --- | --- | --- | --- | --- |
| KT-01 | Engine Godot 4.7.2 | ✅ | Proto | |
| KT-02 | Dữ liệu tách khỏi logic (designer chỉnh không sửa code) | 🟡 | Proto | Dữ liệu nằm trong `scripts/data/*.gd`; kịch bản đề xuất JSON/Resource. Chuyển khi có designer |
| KT-03 | Lưu game cục bộ, chuyển đổi save cũ | ✅ | M1 / M2 | Save v3 |
| KT-04 | Test tự động headless | ✅ | Proto → C1 | 64 test; chạy một phần bằng `-- --only=<tên>` |
| KT-05 | Quản lý mã nguồn bằng Git | ✅ | 20/10/2026 | Nhánh `main`, remote GitHub `VinhNV8/Mistbreaker-Celestial-Genesis`; `.gitignore` bỏ `.godot/`, `node_modules/`, log công cụ |
| KT-06 | Build file chạy Windows (.exe) | ✅ | C1 | `bash tools/build_windows.sh` → `build/ThienPhuKhaiGioi.exe` (111 MB, 1 file, gói dữ liệu nằm trong exe). Templates 4.7.2 đã cài (chỉ Windows x86_64) 20/10/2026; bản build từ commit 96613e0 chạy đủ smoke 21 ảnh |
| KT-07 | Cài đặt: âm lượng, đổi phím, cỡ chữ | 🟡 | C1 / M5 | Âm lượng tổng/nhạc/hiệu ứng, toàn màn hình, **cỡ chữ 4 mức (M5-05, test M5-T7)** (Esc → Cài đặt); đổi phím vẫn qua Input Map, chưa có màn đổi phím trong game |
| KT-08 | Điều khiển tay cầm / cảm ứng | ⬜ | Alpha | Phụ thuộc quyết định PC hay Mobile |
| KT-09 | Backend: tài khoản, lưu đám mây, bảng xếp hạng | ⬜ | Alpha / Beta | Bảng xếp hạng có trong phạm vi Alpha |
| KT-10 | Chống gian lận: quay Thiên phú, rơi đồ tính trên server | ⬜ | Beta | |

## 12. Kế hoạch các đợt tiếp theo

Mỗi đợt theo quy trình: **viết spec → duyệt → code → test → cập nhật file này**. Đánh dấu `- [x]` khi xong.

### M3 — Lớp Thợ Săn và 4 kỹ năng mỗi lớp

- [x] Viết spec M3 trong `03-mvp-spec.md` (mục 5)
- [x] NV-05: màn hình chọn lớp sau Lễ Thức Tỉnh (Kiếm Khách / Thợ Săn)
- [x] NV-02: Thợ Săn đánh xa bằng cung, chỉ số chính AGI
- [x] CB-01: đủ 4 kỹ năng cho Kiếm Khách và Thợ Săn (phím 1–4), có hồi chiêu
- [x] NV-15: MP — kỹ năng tốn MP, MP hồi theo thời gian
- [x] NV-16: Né tránh; NV-12: LUK
- [x] CB-04: né "Hoàn hảo" làm chậm thời gian 1 giây
- [x] CB-07: thanh Phá Thế cho quái tinh anh
- [x] CB-12: mỗi loại tinh anh có 1 kỹ năng đặc biệt
- [x] TP-30: Thuần Thú Sư thu phục được quái trong Ổ quái
- [x] TP-40 (CR-01): Đạo Tặc cướp thuộc tính khi hạ quái, DT-01…08
- [x] CB-21 (Q22): quái lấy chỉ số từ công thức của tài liệu 06 (hàm trong `formulas.gd`), bỏ bảng số cứng của vùng 1
- [x] CB-22 (Q23): boss chương 1 = 90 đòn; kiểm bằng bot chuẩn cấp 5 (35–45 giây)
- [x] TP-41 (Q17): hiệu ứng chính Thiên phú mạnh dần theo Lv (×1,5 ở Lv10)
- [x] Cân bằng (sau CB-21, CB-22, TP-41): 20 Thiên phú × 2 lớp đều hạ được boss, F/S chênh ≤ 25% ở cả Lv1 và Lv10
- [x] Save v4, test, cập nhật tài liệu
- [x] CB-23 (bổ sung): khoá hang boss
- [x] UI: màn hình chọn lớp, HUD 8 ô + MP, bảng Chỉ số 5 chỉ số, icon kỹ năng

### M4 — Chương 2

- [x] Viết spec M4
- [x] BD-07: bản đồ lục địa, di chuyển giữa vùng; TN-09 cảnh kết chương 1
- [x] BD-02: Đồng Bằng Gió Hú, cơ chế gió đẩy lùi; CB-10: 4–6 loại quái
- [x] BD-06: 3 map con mỗi vùng + dungeon boss (làm lại vùng 1 theo cấu trúc này: 40 ô, Lõi Sương mở sau boss — Q24, Q25)
- [x] CB-18: boss Tướng Gián Điệp Huyền Ảnh
- [x] CT-04, CT-07, CT-10: Thành Biên Đài, Liên minh, gián điệp Hư Vô Giáo
- [x] KP-01, KP-11: lưới khai phá lớn hơn, tỉ lệ sự kiện theo kịch bản; TP-26 Khứu Giác Di tích 20%
- [x] KP-06, TB-11: Mỏ, Bến Cá (buff lãnh địa, không tạo tài nguyên), tài nguyên Đá/Sắt/Tinh Thạch (Q26)
- [x] TB-04, TB-05: bộ trang bị vùng 2, bộ cộng hưởng Thiên phú
- [x] NV-17, NV-24, NV-25: kháng hệ, EXP offline 5%, phạt EXP quái thấp cấp
- [x] BD-08, BD-09: dịch chuyển, thử thách vượt ải
- [x] TP-23: Chân Không Biết Mỏi đổi lại đúng nghĩa "bản đồ lớn"; TP-39 Đạo Tặc học kỹ năng boss 2

### M5 — Cốt truyện, hướng dẫn, chuẩn bị thử nghiệm kín

- [x] Viết spec M5 ([03 mục 8](03-mvp-spec.md))
- [x] TN-01, CT-01…03: cutscene mở đầu, thoại chương 1–2 (xong ở C1, M4.3)
- [x] TN-04: hướng dẫn combat; TP-43: cây tiến hoá hiện trong bảng Thiên phú (Q20) (xong ở C1)
- [x] NV-22: nhiệm vụ cốt truyện (chương 1 ở C1, chương 2 ở M4.3)
- [x] CB-15: boss hiếm — Lão Thụ (C1), **Bạch Hổ Phong Vân (M5-01)**
- [x] KP-15, KP-16: Xưởng Rèn, Vườn Thảo Dược (xong ở C1)
- [x] KP-09, TB-12: Thương nhân lữ hành, mua bán (xong ở C1)
- [x] CB-02: Tự đánh; NV-26: tự cộng điểm (xong ở C1)
- [x] M5-02, NV-20: nhịp lên cấp — Spec_Notes đợt 3 "lên level nhanh quá" (nghiên cứu ARPG, chỉnh hệ số EXP); lính khiên quay chậm (F-M5-1)
- [x] M5-03: bản đồ nhỏ theo thời gian thực (Spec_Notes đợt 3) — `ui/minimap.gd`, phím V
- [x] M5-04, KP-04: chinh phục Di tích bằng câu đố
- [x] KT-06: build .exe (game-bc, 20/10/2026)
- [x] KT-07: cỡ chữ (M5-05) — Esc → Cài đặt, 4 mức

### Spec_Notes đợt 5 ([03 mục 9](03-mvp-spec.md))

- [x] SN5-01: bấm bản đồ nhỏ để tự chạy tới
- [x] SN5-10: chữ nhặt đồ xếp dòng, gộp vàng, không đè nhau
- [x] SN5-20: hệ kỹ năng — đề xuất ở [13](13-he-ky-nang.md), **duyệt "theo đề xuất"** 21/10/2026
- [x] SK1: mở kỹ năng theo cấp, Điểm Kỹ Năng, cấp kỹ năng 1–10, 4 ô lắp (đổi ở vùng an toàn), bảng Kỹ năng (U), save v13 — [13 mục 7](13-he-ky-nang.md)
- [x] SK2: +2 kỹ năng cấp 15/22, +2 kỹ năng chuyển chức 1 (12 kỹ năng mới), biến thể 3 tầng, ngũ hành ở tầng II, save v14 — [13 mục 8](13-he-ky-nang.md)
- [x] SK3: Bí Kíp rơi + Mảnh Bí Kíp, kỹ năng tối thượng cấp 45, kỹ năng nhánh chuyển chức 2 (12), save v16 — [13 mục 9](13-he-ky-nang.md)

### Spec_Notes đợt 6 ([03 mục 8b](03-mvp-spec.md))

- [x] UI-08: khung nhân vật theo hình mẫu (khung vàng – ngọc tím), EXP + HP + MP thành vòng quanh chân dung, Thiên phú dời xuống, không nền, thu nhỏ ×0,75 — `ui/char_frame.gd`
- [x] UI-09: "+N EXP" khi hạ quái (SN6-T1)
- [x] UI-10: thanh kỹ năng thấp, bỏ tên/dòng phụ, huy hiệu cấp / số bình, chữ khoá
- [x] UI-11: gộp Chỉ số (C) vào Túi đồ (I) — tab "Chỉ số"
- [x] UI-12: nút bật/tắt Tự đánh; bỏ chữ "C: cộng điểm"
- [x] MP-09: cổng dịch chuyển (cổng tiến/lùi + Cổng Dịch Chuyển ở vùng an toàn) thay chọn nơi đến trên bảng lục địa (SN6-T2)
- [x] UI-13: biểu tượng ngũ hành thay chữ (quái, cột đá, khung nhân vật); UI-08g: tên Thiên phú một dòng
- [x] UI-14: cổng vẽ lại (vòng phù văn mặt đất, trụ pha lê, bảng tên), không che nhân vật, tự tránh nhà / cây
- [x] CB-30: quái áp sát nhanh hơn (đuổi ×1,25, tối thiểu 165, Truy kích khi bị đánh từ xa, tầm phát hiện 330)
- [x] UI-15: bảng tên quái (loại · tên · cấp, màu theo chênh cấp); UI-11b: tab Chỉ số | Túi đồ | Tài nguyên
- [x] UI-16: khung nhiệm vụ gọn (nền mờ, 4 dòng, bỏ dòng phím tắt) + UI-16b thiết kế lại khung (QuestBox); UI-17: bảng Trợ giúp F1 / H; UI-13b: biểu tượng hệ không đè Thiên phú (đợt 7)
- [x] UI-20: nhật ký thông báo vẽ lại (dải mờ dần, huy hiệu theo loại, số tô đậm, dấu chấm ngăn nghìn)
- [x] UI-18: bỏ trùng chỉ số ở tab Chỉ số (khung tổng kết lặp cột nhân vật; Lực chiến chỉ ở tiêu đề, cột trái thêm ST chí mạng)
- [x] CL1: thiết kế lại kỹ năng / chỉ số 3 lớp theo charactors.md ([21](21-thiet-ke-lai-5-lop.md) mục 10) — Kiếm Ý, Nguyệt Ảnh Liên Trảm, Xuyên Tâm Tiễn, Lộn Nhào, Băng Lao, Thiên Tai Nguyên Tố; save cũ chuyển điểm; cân bằng đạt
- [x] CL1b: Băng Lao làm chậm đúng 50%, Thiên Tai Nguyên Tố mang 3 hệ (Hỏa / Thủy / Kim), vệt chém + kiếm khí Kiếm Khách màu đỏ (icon Kiếm Ý / Băng Lao: ✅ game-5f)
- [x] CL2 (spec): sửa docs/19 — 7 kỹ năng Hộ Vệ / Triệu Hồi Sư theo charactors.md (code: phiên game-c6, LH1/LH2)
- [x] LH1: lớp Hộ Vệ (NV-04) — 13 kỹ năng, Khiên, Hiệp Sĩ / Thánh Kỵ Sĩ / Thiết Vệ, Chùy, hình tạm + icon, thẻ chọn lớp mở — [19 mục 2, 7](19-lop-ho-ve-trieu-hoi-su.md)
- [x] LH2: lớp Triệu Hồi Sư (CR-03) — 13 kỹ năng, Linh Hồ thường trực, 8 loại linh thú, đồ đằng, Linh Sư / Ngự Long Sư / Đồ Đằng Sư, Linh Châu — [19 mục 3, 7](19-lop-ho-ve-trieu-hoi-su.md)
- [x] J3: chuyển chức 3 cho 5 lớp (NV-07, bản tạm Q140) — 5 chức, 10 hiệu ứng, 5 Thần Kỹ (icon viền bạc), bảng chuyển chức 3, tab "Chức 3" bảng Kỹ năng, save v18 — [23](23-chuyen-chuc-3-linh-thu-co-mau.md)
- [x] SH: linh thú có máu (Q112) — [23 mục 4](23-chuyen-chuc-3-linh-thu-co-mau.md)
- [x] UI-24, UI-25 (Spec_Notes đợt 8): Cửa hàng kiểu mới (tab dọc, thẻ hàng, chọn số lượng, Mua ×N, khung chi tiết) + **Lò Rèn tách riêng** (phím R; cường hoá có ô chi phí cần / có + bảng chi phí mọi cấp, chế tạo, luyện nguyên liệu, phân rã); Túi đồ hiện chi phí cường hoá bằng ô icon. Màn chọn lớp: đã làm ở UI-22. Test UI-24, UI-25
- [x] UI-26 (28/10, ảnh mẫu của chủ dự án): thẻ thuộc tính kiểu mới — icon lớn, nhãn Thuộc tính chính (xếp đầu), "Tăng mỗi điểm" từng dòng, cột Tổng + "(N cơ bản + M điểm cộng)", nút ? và +; icon vương miện `stat-main` (AR-77); UI-26b: phần gốc trắng, phần điểm cộng xanh lá đậm, phần cướp đỏ; UI-26c: thứ tự thẻ cố định mọi lớp (STR VIT AGI INT WIS DEX LUK), thẻ cao bằng nhau (3 dòng), khung bộ đồ cột trái cuộn được — hết tràn che nút Tẩy điểm. Test UI-19 mở rộng
- [x] UI-27 (28/10): bảng Nhân vật dùng trang trí cắt từ ảnh mẫu (`tools/art/ui_cut.py`, `ui/ornate.gd`, 17 mảnh `assets/ui/`) — khung cột, 7 hàng thuộc tính gọn (icon vẽ, nhãn Chính, nút i, nút +), ô Điểm thuộc tính, biển Lực chiến, nút Phân bổ tự động / Tẩy điểm. Còn lại theo ảnh: thanh tab trên + vàng / kim cương, khung bộ đồ dạng thẻ. Test UI-19 viết lại cho hàng gọn
- [x] AS (30/10): tốc đánh cảm nhận được — hoạt ảnh và vệt chém đánh thường nhanh theo tốc đánh; trang Chỉ số hiện "đòn/giây" và tooltip giây mỗi đòn. Test AS-T1 (D65, docs/26 mục 2.1)
- [x] DT-04 (30/10): sửa lỗi Đạo Tặc — điểm cướp giữ vĩnh viễn, đầy 1 × cấp thì không cướp thêm (trước đây thay điểm cũ nhất nên không cộng dồn). Test TP-T3 mở rộng
- [x] DT-03/17/18/19 (30/10, Q169–Q170): giới hạn cướp = cấp Thiên phú × cấp; Túi Tang Vật (5), Đà Cướp (+3% 30 giây × 5), Sổ Đạo Tặc (loài 5 / boss 9 / boss hiếm 10); bảng Thiên phú hiện đủ; save v20. Test DT-T2. ⚠ Cuối game ≈ +60% điểm tiềm năng — cần playtest cân bằng
- [x] PV (30/10): kỹ năng bị động cho 5 lớp — 4 bị động mỗi lớp (cấp 10/20/35/50, cấp 0–5, Điểm Kỹ Năng chung), tab Bị động trong bảng Kỹ năng (kèm đặc tính lớp và bị động chuyển chức 1/2/3), 21 icon viền xanh lục, tẩy điểm hoàn cả bị động, save v21. Test PV-T1…T4 — [27](27-ky-nang-bi-dong.md)
- [x] BK (31/10): Bí Kíp nhặt được = +1 Điểm Kỹ Năng (nguồn rơi giữ nguyên); biến thể ✦ mở bằng 2 Điểm Kỹ Năng (nút "Mở ✦"); bỏ Mảnh Bí Kíp; tẩy điểm khoá lại ✦ và hoàn điểm; save v24 (Mảnh cũ → điểm). Test SK3-T3 / BK-T1, BK-T2, R1-T1. Đề xuất Q171–Q175 chờ duyệt — [29](29-bi-kip-diem-ky-nang.md)
- [x] UI-28 (30/10): thanh tiêu đề bảng Nhân vật theo ảnh mẫu — quay lại, "Nhân Vật", 5 tab chữ (tab chọn nền vàng + hình thoi), Kỹ năng / Thiên phú mở bảng riêng, Vàng + Tinh Thạch, nút +, X; khung vẽ cho cả 3 cột mọi tab. UI-28b: Kỹ năng / Thiên phú dùng chung thanh tiêu đề (`ui/char_bar.gd`), chuyển qua lại được giữa 5 tab; UI-28c: tab Thiên phú 3 cột vừa 1 trang (thẻ · hiệu ứng theo cấp + luyện cấp · cây tiến hoá), không cuộn. UI-28d: khối cấp Thiên phú nổi bật (số lớn, 10 ô tiến độ, TỐI ĐA). Chưa có tab Danh hiệu. Test UI-21 mở rộng
- [x] UI-23: bảng Kỹ năng kiểu mới theo ảnh thiết kế (27/10): tab nhóm kỹ năng (Lớp · Chuyển chức 1 · Tối thượng · Chuyển chức 2), biển lớp + Điểm kỹ năng, cây kỹ năng có mũi tên, cột chi tiết (hiệu ứng hiện tại / cấp kế, Nâng cấp, ô lắp, biến thể), Tẩy điểm
- [x] R1-01…07 (rà soát docs/19 mục 0): "+N!" cường hoá trên chân dung, màn chiến thắng nền 0,95, nhật ký kỹ năng chưa mở báo 1 lần, số ≥ 5 chữ số có dấu chấm ở khung nhiệm vụ, Bí Kíp chỉ cho kỹ năng đã mở, HUD phải thu gọn khi đánh boss; icon tràn thẻ lớp đã hết nhờ UI-22
- [x] SN9-01…09 (Spec_Notes đợt 9, [25](25-spec-notes-dot-9.md)): tên + chức nghiệp, 5 ô nhân vật, số sát thương "-N" theo màu, thú lao trước, EXP theo chênh cấp, bãi quái theo cấp, "+9 + 15 (gốc)", dòng tăng chỉ số khi lên cấp, khung mục tiêu
- [x] CS — chỉ số lớp đặc thù (góp ý người chơi 28/10): [26](26-build-lop.md) gộp [24](24-de-xuat-chi-so-lop.md) + CR-001, duyệt theo đề xuất (Q147–Q152, Q161–Q168): 7 thuộc tính, đặc tính lớp, 3 build mỗi lớp, save v19
- [x] SN10-01, 02 (Spec_Notes đợt 10, [28](28-spec-notes-dot-10.md)): kết quả cường hoá giữa màn hình, bình MP (phím F, cửa hàng, rơi đồ, save v22)
- [x] SN11-01…03 (Spec_Notes đợt 11, 31/10, [30](30-spec-notes-dot-11.md)): thẻ trang bị khi rê chuột (đồ đang mặc / trong túi), so sánh ▲▼ với đồ đang mặc, bản đồ ×3 diện tích (trần quái 120, bãi 10, save v23 phủ sương lại); sửa lỗi "triangulation failed" khi vẽ hình nhỏ ở toạ độ lớn
- [x] SN12-01, 02 (Spec_Notes đợt 12, 01/11, [31](31-de-xuat-thanh-ky-nang.md)): bình máu không giới hạn; thanh kỹ năng 7 ô (ô 5 / 6 theo chuyển chức, ô Tuyệt kỹ G cấp 45), báo + tự lắp kỹ năng mới, đổi ô ngoài giao tranh, kéo-thả + chuột phải, 2 bộ kỹ năng (X); save v27
- [x] CB-31 (01/11): cân bằng sau 7 ô — đo SN12-T3 (Viêm Long cấp 60: 7 ô nhanh hơn 4 ô 0–19%, Pháp Sư chậm hơn 12% vì MP) → không đổi máu boss; TL-J3: Ngũ Hành Luân Chuyển ×0,6 → ×0,75 (Pháp Sư chức 3 nhanh hơn chức 2 8% → 16%)
- [x] RS-0111 (01–02/11, [32](32-ra-soat-01-11.md)): rà 65 ảnh smoke chương 1–9 — sửa 7 lỗi (bảng lục địa che ảnh / nội dung cũ, bảng tên Cổng Dịch Chuyển đè tên NPC, tên đấu trường đè thanh máu boss, chữ "Kỹ năng mới" chồng nhau, mẫu tự cộng điểm bị cắt, "Thần Vực N", mẹo thanh kỹ năng)
- [x] AU (01/11, [32](32-ra-soat-01-11.md)): 9 nhạc nền (vùng 2–9 + boss vùng 7–9), 8 âm (kỹ năng theo lớp, Tối thượng, mở kỹ năng, tới map). Test AU-T1
- [x] SN13-01 (Spec_Notes 02/11, [32](32-ra-soat-01-11.md) mục 5): sửa Thuỷ Quái Thất Đầu không nhận sát thương (7 đầu không mọc); test RB-T1 cho 9 boss hiếm
- [x] SN14-01/02 (Spec_Notes 02/11, [31](31-de-xuat-thanh-ky-nang.md) mục SN14): Hấp Huyết dùng được bình máu; đổi ô / đổi bộ trong bảng Kỹ năng luôn được (game dừng nên khoá giao tranh 5 giây làm kẹt nút)
- [x] TP-05/13/14/44 (02/11, [33](33-thien-phu-phu-cong-huong.md)): Thiên phú phụ (ô 2 / 3 khi chuyển chức 1 / 2, Lễ Thức Tỉnh ô phụ, cấp riêng), cộng hưởng chung +10% + 9 cặp đặc biệt (??? tới khi kích hoạt), tẩy bằng Nước Thánh Tinh Quang; save v28
- [x] BD-11 + KP-10 + NV-23 (02/11, [34](34-dungeon-cong-ngau-nhien.md)): Dungeon cổng ngẫu nhiên hạng E → S (mở ngẫu nhiên mỗi 5 phút trên map đã tới, tối đa 2, 2 giờ chơi, 3 khu quái + Chúa Cổng, thưởng EXP / đồ / Tinh Hoa theo hạng), dọn sương 7% lộ cổng; save v29
- [x] SN15-01 (Spec_Notes 03/11, [32](32-ra-soat-01-11.md) mục 6, 04/11): Phượng Hoàng Tro đánh không chết — trứng Niết bàn không nở vì `update_enemy` chặn `update_rare`; gục giữa trận thì trận sau có lại Niết bàn. Test C5-T4
- [x] SN16-01 (Spec_Notes 05/11, [36 §9.15](36-thiet-ke-lai-vfx-ky-nang.md)): linh thú / Xương Nô hiện hình 0,5 giây rồi mới lao ra đánh (không trừ thời gian tồn tại); nghi thức gọi 0,9 → 0,7 giây, cột sáng tắt khớp. Test SN16-T1
- [x] BOSS-T1 (04/11, [32](32-ra-soat-01-11.md) mục 7): quét 50 boss (9 vùng, 9 hiếm, 26 Chúa Hang, 6 Chúa Cổng) qua vòng chơi thật — tất cả gục và biến mất; sửa Chúa Hang Nấm Mẹ bị đẩy lùi ra ngoài mép hang (đánh không chết) — quái nay luôn ở trong mép bản đồ
- [x] NV-P1 (05/11, [41](41-de-xuat-nhiem-vu.md) mục 8): nhiệm vụ rõ ràng — goal cho 64 bước, mũi tên vàng + khoảng cách, vòng mục tiêu, chấm trên bản đồ nhỏ, "!" trên NPC, Sổ nhiệm vụ (O), bấm khung nhiệm vụ để tự chạy tới, dải chữ khi xong bước, gợi ý viết lại. Test NVA-T1
- [x] NV-P2 (05/11, [41](41-de-xuat-nhiem-vu.md) mục 8): uỷ thác hằng ngày — 3 việc / ngày, nhận ở khu an toàn, rương ngày, chuỗi 7 ngày, đổi việc, cửa hàng Điểm Uỷ Thác, ghim 2 việc lên HUD; save v30. Test NVD-T1
- [x] NV-P3 (05/11): 27 chuỗi nhiệm vụ phụ (3 / vùng, NPC sẵn có giao, "!" / "?", chọn 1 trong 3 thưởng, 9 danh hiệu). Test NVC-T1
- [x] NV-P4 (05/11): 8 bước "hạ 30 quái" → tinh anh có tên / dấu vết / nhặt vật / giữ điểm; sự kiện trên đường (4 loại). Test NVB-T1, NVE-T1
- [x] NV (Spec_Notes 05/11 — **chốt 05/11: làm P1–P4, xong cả 4 đợt 05/11** "nhiệm vụ đơn điệu, ít, không thu hút, chưa rõ ràng"): đề xuất [41](41-de-xuat-nhiem-vu.md) — hiện trạng 64 bước chính, 0 nhiệm vụ phụ / ngày, không điểm đánh dấu / sổ nhiệm vụ; 5 nhóm NV-A rõ ràng · NV-B đa dạng chính tuyến · NV-C 27 chuỗi phụ · NV-D uỷ thác hằng ngày · NV-E sự kiện trên đường; chờ chủ dự án chọn (Q195–Q201)
- [x] PF-01 (04/11, góp ý người chơi "di chuyển giật", [32](32-ra-soat-01-11.md) mục 8): game chỉ ~20 khung/giây — sửa mảng loang nền đất (4 vòng tròn → 1 texture), HUD đồng nướng lớp tĩnh thành ảnh (`ui/draw_layer.gd`), lọc quái / vật ngoài khung nhìn, bản đồ nhỏ chỉ vẽ trong vòng, sương cập nhật theo vùng → ~60 khung/giây (có quái ~43). Công cụ đo `tests/perf_walk.gd`
- [x] UI-40 (03/11, [35](35-de-xuat-giao-dien-moi.md)): Spec_Notes "giao diện pixel quá" → đề xuất 3 hướng, chủ dự án chọn **B (HD vector, code vẽ) + cel-shade mobile**; làm bản thử G0 (Sói Sương, Sói Chúa, Rừng Sương, 10 icon; Kiếm Khách HD đã gỡ theo yêu cầu), bật / tắt ở Cài đặt — chờ duyệt ảnh
- [x] UI-40b (03/11, [35 §9](35-de-xuat-giao-dien-moi.md)): Làng Thanh Thạch vẽ lại HD — nhà gỗ mái ngói / tranh, hàng rào, giếng, sân lát đá, ruộng; Cổng Dịch Chuyển ở khoảng trống (UI40b-T1)
- [x] UI-40c (03/11, [35 §10](35-de-xuat-giao-dien-moi.md)): 8 vùng còn lại + Thành Biên Đài vẽ lại HD — khu an toàn theo chủ đề vùng, nền + cảnh vật HD
- [x] UI-41 (03/11, [35 §11](35-de-xuat-giao-dien-moi.md)): giao diện đồng chạm khắc theo ảnh mẫu — khung, thanh kỹ năng, thanh EXP, cụm nút góc phải, la bàn, cuộn nhiệm vụ
- [x] DH-14 / FX-1 (03/11, [36](36-thiet-ke-lai-vfx-ky-nang.md)): nghiên cứu board Pinterest game-skill-effects, thiết kế lại VFX 70 kỹ năng 5 lớp, bản duyệt `docs/design/skills-fx` (GIF 12 khung + PNG + bảng tổng lớp)
- [x] FX-2…4 (03/11, [36 §9](36-thiet-ke-lai-vfx-ky-nang.md)): chủ dự án duyệt Q180–Q183; FX-1 vào game cho cả 70 kỹ năng, vẽ vector HD, chạy song song với hình đã duyệt; thứ tự Pháp Sư → Thợ Săn → Triệu Hồi Sư → Hộ Vệ → Kiếm Khách (FX1-T1, smoke `tests/fx1_smoke.gd`); AR45d-T1 cập nhật theo AR-46
- [x] FX-1 khớp thiết kế (03/11, [36 §9.6](36-thiet-ke-lai-vfx-ky-nang.md)): chủ dự án thấy Xoáy Kiếm trong game khác bản thiết kế → sửa game theo thiết kế (mặt đất 3/4, nhịp 12 khung, độ dày, bỏ hình cũ chồng lên, Thiên Tai 3 pha, Triệu Hồi Xương); ảnh so sánh 70 kỹ năng `docs/design/skills-fx-ingame`
- [x] DH-15 / IC-1 (03/11, [37](37-icon-ky-nang.md)): vẽ lại 51 icon kỹ năng (giữ 19 icon vẽ tay), chủ dự án duyệt → vào game qua lớp phủ HD `manifest.hd.icons` (IC1-T1, ảnh thanh kỹ năng thật); bổ sung 20 icon bị động + icon tab "Bị động" cho đồng bộ ([37 §6](37-icon-ky-nang.md))
- [x] DH-16 (04/11, [38](38-ra-soat-giao-dien-theo-tieu-chi.md)): rà soát giao diện theo tiêu chí chuẩn, chủ dự án duyệt theo đề xuất → làm cả 3 đợt UI-50…63 (UI38-T1)
- [x] Theo đề xuất cải thiện (03/11): sửa lỗi save cũ — ô lắp kỹ năng đã thay (Thiết Bích → Kiếm Ý, Dịch Chuyển → Băng Lao) thành trống (`Skills2.migrate_replaced` đổi cả `loadout` / `loadout_alt`; test CL1 hết `SCRIPT ERROR`); FX-1 hiệu năng 1,65 ms/khung; rung + khựng đòn + âm nổ đúng khung va chạm; cài đặt rung / giảm chớp; vòng cảnh báo đòn quái FX-1; chỉnh Hoả Tường, cột sáng triệu hồi, icon Ấu Long / Linh Ưng ([36 §9.7–9.10](36-thiet-ke-lai-vfx-ky-nang.md))
- [x] Bước 8 lát 2 (04/11): cảnh báo đòn quái của từng chương (region5–9) + dạng nón / đường theo FX-1, đúng kích thước gameplay ([36 §9.11](36-thiet-ke-lai-vfx-ky-nang.md))
- [x] MD-1 / UI-47 (04/11, [39](39-thiet-ke-lai-quai-vat.md)): nghiên cứu ảnh mẫu Pinterest → quy chuẩn phong cách S1–S10 + họ màu 9 vùng (skill `.claude/skills/monster-design`); bộ dựng `tools/art/hd/mon_*.py`; 85 quái / tinh anh / boss vào game qua lớp phủ HD (MD1-T1), 9 linh thú chỉ có bản duyệt (Q190); ảnh duyệt `docs/design/monsters/`. 09/11: Q190 duyệt → 9 linh thú vào game; Q192 giữ sói mới
- [x] DH-17 / EQ-HD (05/11, [40](40-icon-trang-bi.md)): icon trang bị đơn điệu (1 hình / ô, vũ khí 4 lớp vẫn là kiếm) → skill `equipment-design` + 336 icon HD theo dáng / phẩm chất / bộ / biến thể, thử trong game (EQ1-T1, ảnh túi đồ thật); chờ duyệt Q193
- [x] DH-18 (05/11, [42](42-giao-dien-xem-do.md)): người chơi chê "xem đồ xấu" → nghiên cứu inventory game khác, làm lại ô đồ theo bậc, thẻ thông tin trang bị, icon có khối (paint pass) + sửa quầng sáng thành đĩa tối
- [x] EN-1 (06/11, [43](43-hieu-ung-cuong-hoa.md)): Spec_Notes "hiệu ứng đồ sau khi nâng cấp xấu" → đề xuất 4 hướng, chủ dự án chọn D + vệt sáng chạy quanh viền (GIF duyệt) → `enhance_fx.gd` trên ô đồ / Lò Rèn / thẻ, bảng màu bậc mới, hào quang nhân vật (vòng ấn + hạt sáng, vệt chém +13), toast cường hoá có icon + ĐỘT PHÁ ở mốc
- [x] VS-1 (06/11, [44](44-ty-le-khung-nhin-va-chieu-sau.md)): khung gốc 1366×768 + `canvas_items` làm màn hình to chỉ phóng hình → `view_scale.gd`: camera zoom ra (1080p ≈ 0,81), giao diện 90% / 85%, chữ thế giới giữ cỡ; Cài đặt Tầm nhìn / Cỡ giao diện / Bóng đổ; chuột phải thu gọn khung nhiệm vụ; B1–B5 chiều sâu (`atmos_layer.gd`: sương, hạt, tia nắng, tiền cảnh mép theo 11 chủ đề vùng). Còn B6 (cao độ địa hình)
- [x] PF-02 (08/11, [44 §7](44-ty-le-khung-nhin-va-chieu-sau.md)): Spec_Notes "di chuyển hơi giật + vệt mờ phía trên" — vệt mờ = dải sương / tia nắng / chùm lá tiền cảnh cố định ở mép trên (bỏ; tiền cảnh chỉ mép dưới). Giật: sau VS-1 tụt ~20% khung/giây → lọc khung nhìn cho cổng / cổng chặn / đấu trường / rào, tách quái theo lưới, sắp xếp gốc, nướng mảng sáng thành 1 ảnh, bớt việc khi vẽ cây → script −23%, render −28%, GPU −25% (đo xen kẽ). Test PF02-T1. Chưa đạt 60 khung/giây trên iGPU khi đông quái (NFR-10 🟡)
- [x] GN-1 (09/11, [45](45-nghien-cuu-goc-nhin-va-nhan-vat.md)): nghiên cứu góc nhìn + nhân vật theo ảnh tham khảo → duyệt "làm theo đề xuất" (Q218–Q223 mặc định) → GN-1a (phối cảnh Nhẹ, zoom trận boss ×1,1, camera dẫn hướng 5%), GN-1b (quầng sáng, bóng sát chân, tông nền vùng 1), GN-1c (lối mòn mép mềm, bộ cảnh trại vùng 1). 
- [x] GN-2 (09/11, [45 §7](45-nghien-cuu-goc-nhin-va-nhan-vat.md)): "triển khai theo đề xuất" → cảnh trại vùng 2–9 (8 bộ rào / tường + cờ + đá vụn theo vùng, phông đấu trường vùng 2/3/4/6, tránh nước / dung nham / đảo / cầu / điểm nhiệm vụ). Còn lại: E6 cao độ địa hình, Q223 bộ đếm combo
- [x] GN-3 (09/11, [45 §8](45-nghien-cuu-goc-nhin-va-nhan-vat.md)): "triển khai tiếp" → bộ đếm combo lớn (Cài đặt Lớn / Nhỏ / Tắt), tông nền vùng 2–9, nền đất mòn dưới bãi trại + viền mềm sân đấu trường + sân lát trại vùng 1–2, sửa xương rồng trong đấu trường 3-3. Còn lại: E6 cao độ địa hình
- [x] GN-4 (09/11, [45 §9](45-nghien-cuu-goc-nhin-va-nhan-vat.md)): "triển khai tiếp phần còn lại" → hình đứng thẳng dưới phối cảnh (P1-B), vách đá viền map 8 vùng + thành hồ nước / hố dung nham / mặt đổ cồn đất (E6, chỉ hình). Còn lại: bậc / cầu có va chạm (khi làm lại map)
- [x] CR-05 (09/11, [CR-05](CR-05-hud-mo-khi-che-nhan-vat.md)): Spec_Notes "bản đồ nhỏ / bảng nhiệm vụ che nhân vật ở mép bản đồ, muốn icon ẩn / hiện" → `hud.focus_rect` + `occlusion_alpha` (mờ 22%, rê chuột rõ), nút `HudToggle` ×2 (Cài đặt `hud_minimap` / `hud_quest`), V hiện lại la bàn; sửa `DrawLayer` nướng mờ theo cha; test CR05-T1, ảnh `design/cr05/`
- [x] MU-1 (09/11, [46](46-nghien-cuu-nhac-nen.md)): Spec_Notes "tiếng nhạc giả quá" → nghiên cứu + bản nghe thử, chủ dự án "làm theo đề xuất" → **đợt 1 đã làm**: 13 bài mới (nhạc cụ mô phỏng: sáo, nhị, đàn tranh, tỳ bà, dàn dây, hợp xướng, taiko…; stereo OGG; giai điệu soạn tay; I-A-B-C-A'-O), nghỉ 30–90 giây giữa lượt bài khám phá, âm môi trường 9 vùng + làng + hang (bus + thanh âm lượng riêng), 5 nhạc báo (lên cấp, nhiệm vụ, sang vùng, gặp boss, chiến thắng); `tools/audio/songs2.py`, `inst2.py`, `audio_manager.gd`; test MU1-T1. Đợt 2 (S4 tầng chiến đấu) làm 10/11 — dòng dưới
- [x] MU-1 đợt 2 (10/11, [46 §10](46-nghien-cuu-nhac-nen.md)): S4 tầng chiến đấu — 10 file `<id>_combat.ogg` (taiko, trống khung, dây nảy, kèn trầm; cùng kế hoạch ô nhịp với bài chính), `AudioStreamSynchronized` + `set_combat(world.in_combat())`, dâng 1,5 giây / lắng 4 giây, đang nghỉ vào trận thì nhạc vào luôn; test MU1-T1, `tests/mu1_play.gd`
- [x] NL-1 (09/11, [47](47-de-xuat-nang-luc-chien-trang-bi.md)): Spec_Notes "ngoài nâng cấp đồ cần thêm cách tăng lực chiến cho đồ" → đề xuất 6 đường → chủ dự án "triển khai theo đề xuất" → **đã làm cả P1–P3**: Khảm Ngọc Ngũ Hành (ấn hệ +15%), Tẩy Luyện, Thăng Phẩm, Luyện Cấp đồ Cam / bộ, Thức Tỉnh, Bảo Giám; Lò Rèn thêm 6 tab, thẻ đồ có lỗ ngọc / ✦ / Thức Tỉnh / Lực chiến món, huy hiệu Lực chiến → Gợi ý; save v32; test NL1-T1…NL3-T2, ảnh `design/nl1/`. Còn: Q235 theo dõi độ khó chương 7–9 khi chơi thử
- [x] CR-06 (10/11, [CR-06](CR-06-man-chon-nhan-vat-kieu-arpg.md)): góp ý người chơi "màn chọn nhân vật giống Diablo" → bố cục ARPG cổ điển: `ui/char_select.gd` (sân khấu `HeroStage` + danh sách phải + Vào game giữa đáy, bấm = chọn, nhấp đúp / Enter = vào, ↑ ↓ / Esc / Delete), `Screens.slots(..., selected)`, `slot_summary` + `look` / `map_id`, `class_sheet.build_pcx()` → `pcx-<lớp>`; test CR06-T1, `tests/cr6_shot.gd`. Góp ý 2 cùng ngày (CR-06b): `main.gd` `_go_home()` — mở game / "Về màn hình chính" vào thẳng màn Chọn nhân vật khi đã có nhân vật; thêm Cài đặt / Thoát game ở màn chọn. Còn Q237 (tranh toàn thân nếu muốn mượt hơn)
- [x] HM-06 (10/11): Spec_Notes "đang toàn màn hình, bấm icon thu nhỏ bản đồ / nhiệm vụ / cài đặt âm thanh thì bị thu nhỏ" → `Settings.apply()` không ép chế độ cửa sổ nữa, chỉ đổi khi ô Toàn màn hình đổi (D94); test FS01-T1 + kiểm tra cửa sổ thật
- [x] CR-04 (08/11, [CR-04](CR-04-ban-do-tu-tui-va-tu-dong-ban.md)): đánh giá người chơi "Inventory không bán được đồ, không có cấu hình tự bán" → bán / phân rã / khoá ngay trong Túi đồ (S / D / L), khung dưới 4 tab, tab Tự động (`loot_box.gd`, `Items.decide`, chèn ở `_update_pickups`), mua lại trong phiên, thẻ đồ có giá, sửa Điểm Kim chưa cộng +50% vàng; save v31; test CR4-T1…T7
- [x] CR-04 rà soát (09/11, [CR-04 §11](CR-04-ban-do-tu-tui-va-tu-dong-ban.md)): đồ Cam / khoá không bị phân rã khi túi đầy (nằm lại trên đất), phím S / D / L và "Chắc chắn?" không dùng trạng thái cũ, thẻ ĐANG MẶC bỏ giá, Thần Tài (Tinh Hoa khi phân rã, lãnh địa +20% vàng; Q217 chốt 09/11: giữ +50% bán đồ), Mua lại ở cửa hàng, Trợ giúp, dấu chấm ngăn nghìn; test CR4-T8.
- [x] CR-04 pha sau (09/11, [CR-04 §12](CR-04-ban-do-tu-tui-va-tu-dong-ban.md)): nút Sắp xếp túi (phẩm chất / ô / Lực chiến), giữ đồ bộ thông minh trong tự động, trang Quy tắc nâng cao (theo ô, luôn giữ theo dòng chỉ số), khoá nhanh đồ đang mặc, thẻ tóm tắt tự xử lý khi mở túi; test CR4-T9
- [x] DH-18b (05/11, [42 §6](42-giao-dien-xem-do.md)): chủ dự án "vẽ lại đi em" (Q203) → 17 icon đồ độc nhất vẽ lại theo EQ-HD v2 (`equip_unique.py`), mỗi món kể chuyện boss rơi ra
- [x] IC-2 (04/11, [37 §7](37-icon-ky-nang.md)): 20 icon Thiên phú + 18 icon trang bị HD (phiên giao diện đồng ý; 7 icon trang bị UI-40 giữ nguyên) — phần "icon 128 px" của UI-42…45
- [x] Soát cảnh báo tự nhiên (04/11, [36 §9.14](36-thiet-ke-lai-vfx-ky-nang.md)): đọc được trên mọi nền (nét sẫm dưới nét sáng), cây mờ khi che quái lấy đà gần, chuỗi khung chuyển động, chế độ mù màu
- [x] Cảm giác chơi (04/11, [36 §9.13](36-thiet-ke-lai-vfx-ky-nang.md)): cây / đá che người chơi hoặc boss thì mờ; quái co người + ngả + run khi lấy đà; âm báo tinh anh / boss; đo nguồn sát thương (PACE-TELE) → Sói lao giữ rãnh bụi
- [x] Cảnh báo đòn quái kiểu tự nhiên (04/11, [36 §9.12](36-thiet-ke-lai-vfx-ky-nang.md)): theo ARPG — quái thường chỉ báo bằng động tác, tinh anh / boss vết đất nứt / bóng / sương / hơi nóng nằm dưới quái; cài đặt Tự nhiên / Rõ ràng
- [x] IC-2 §8 (04/11): 14 icon tài nguyên + 24 icon chỉ số HD → mọi icon đã có bản HD, trừ 5 chân dung (hình chủ dự án, giữ nguyên); cảnh báo đòn quái vùng 5–9 chụp trong game + bỏ vòng đỏ chồng của nhánh mặc định ([36 §9.11](36-thiet-ke-lai-vfx-ky-nang.md))
- [x] AR-45d (03/11, [07](07-do-hoa-ke-hoach.md)): **AR-45d (03/11/2026, thay AR-45c):** 10 kỹ năng Kiếm Khách (Xoáy Kiếm, Đột Kích, Hống Kiếm, Kiếm Vũ, Phi Kiếm, Thánh Kiếm Trảm, Kiếm Vực, Huyết Bạo, Huyết Ảnh, Nhất Kiếm Khai Thiên) **dàn dựng chuyển động theo cơ chế thật** bằng chính các mảnh hình gốc mà bộ review `docs/design/skills/kiem-khach` ghép từ master sheet (trăng khuyết Trảm Phong, vụ nổ Kiếm Ý, thanh kiếm Vạn Kiếm): Xoáy Kiếm 4 trăng khuyết xoay 2 vòng nở ra 12,5 m; Đột Kích / Huyết Ảnh vệt trăng khuyết theo đường lao thật; Hống Kiếm / Huyết Bạo tụ lực rồi nổ + 8 trăng khuyết toả ra đủ bán kính; Kiếm Vũ 4 kiếm bay quanh 2 giây + nhát chém mỗi nhịp; Phi Kiếm / Thánh Kiếm loé lực ở mũi kiếm (kiếm bay vẽ như đạn); Kiếm Vực vòng vực đi theo người, 8 kiếm cắm quanh mép, kiếm rơi cắm xuống mỗi nhịp 0,5 giây (trước đây bị vẽ nhầm thành Mưa Băng); Nhất Kiếm tụ lực 0,5 giây rồi chuỗi trăng khuyết chạy dọc vệt chém 40 m. AR-45c (3 ảnh tĩnh của storyboard dán cạnh nhân vật) đã gỡ vì chủ dự án thấy "không giống ra chiêu trong game". Trảm Phong, Kiếm Ý, Nguyệt Ảnh Liên Trảm, Vạn Kiếm Quy Tông giữ hình cũ
- [x] UI-22: tạo nhân vật 2 bước — màn chọn lớp kiểu thẻ (5 thẻ, chân dung lớn theo lớp, chỉ số cấp 1, 4 kỹ năng, Hộ Vệ / Triệu Hồi Sư "Sắp ra mắt") rồi đặt tên + ngoại hình (nút Đổi lớp)
- [x] UI-21: bảng Nhân vật kiểu mới theo ảnh thiết kế (27/10): tiêu đề + tab vàng, cột nhân vật (bệ đá, thẻ Thiên phú có sao, khung bộ đồ Xem set), trang Điểm thuộc tính dạng thẻ (tổng + điểm cộng), mẫu Tự cộng điểm theo lớp, cột Lực chiến + Chỉ số chiến đấu + lửa trại; Túi đồ / Tài nguyên cùng phong cách; 21 icon `stat-*`; UI-21b: kiếm chéo trên biển Lực chiến (không đè chữ), tab Chỉ số không lặp 8 chỉ số ở cột trái; UI-21c: khung bộ đồ hiện đủ mức thưởng, chỉ khi có mặc đồ bộ, bỏ nút Xem set; 3 tab cột trái không còn 8 chỉ số
- [x] UI-19: chỉ số mặc định theo lớp (tổng 17), trang Chỉ số hiện "mặc định + điểm cộng" và chỉ số đó đang cho bao nhiêu — chỉ số cuối không đổi
- [x] HP-01…10: hang phụ trong từng map (cửa hang, 3 khu, Chúa Hang, thưởng, đóng 20 phút, save v15) — [15](15-hang-phu.md)

### M10–M12 — Chương 7–9 — xong 01/11/2026 (spec [16](16-chuong-7.md), [17](17-chuong-8.md), [18](18-chuong-9.md), viết 22/10/2026; 17–18 rà lại 31/10 theo các thay đổi sau đó — mục 0b mỗi spec)

- [x] Spec chương 7, 8, 9 (bám kịch bản mục 2, 4, 5, 6 + 06 vùng 7–9 + các điều chỉnh SK1–SK3, HP, MP-09, CB-30, UI-15/16/17, D41)
- [x] M10.1: KP-13 Trấn / Thành / Hoàng Thành, KP-18 Cảng Khí Cầu (C7-01…04)
- [x] M10.2: vùng 7 — đảo bay, rơi về Đá Neo, cầu gió, đảo vỡ, Lông Vũ Gió, 4 quái + 2 tinh anh, Hang Mây Ẩn (C7-05…25)
- [x] M10.3: Thiên Không Cự Thần, Kỳ Lân Mây, Bộ Thiên Phong, Búa Cự Thần, Sừng Kỳ Lân, Thiên Chuỳ (C7-30…35, TL-B7)
- [x] M10.4: nhiệm vụ chương 7, Bia Đá gốc, tiến hoá lần 2 + Đột Phá, save v17 (C7-40…46)
- [x] M11.1: vùng 8 — Suy Thiên (hook `talent_mult`, D70), Đèn Tinh Quang (12/8/5), không hệ, Cột Đá, Đèn Lồng, Mạch Tinh Thạch, 4 quái + 2 tinh anh (C8-01…25)
- [x] M11.2: Giáo Chủ Hư Vô, Hư Vô Thú, Bộ Tinh Quang, Ấn Hư Vô, Nanh Hư Vô, Lõi Hư Vô, Hút Thiên Phú (C8-30…35, TL-B8)
- [x] M11.3: nhiệm vụ chương 8, Tổng tấn công, Phản công Hư Vô, chuyển chức 3 ở 5 Tổ Sư (Thần Kỹ đã có từ J3), save v25 (C8-40…47)
- [x] M12.1: vùng 9 — 9 tầng, hệ tầng, Ấn Hệ, Cửa Tầng / Thủ Tầng, 4 quái + 2 tinh anh (C9-01…25)
- [x] M12.2: Ma Tôn Vô Diện 3 giai đoạn + mảnh thứ hai, Thiên Đạo Hư Ảnh, Bộ Thiên Đạo, Mặt Nạ Vô Diện, Vô Diện (C9-30…35, TL-B9)
- [x] M12.3: nhiệm vụ chương 9, hai kết thúc, cảnh kết, danh đề (C9-40…47)
- [x] M12.4: cấp sau 100, Thần Vực, Tái Thiết Lục Địa, save v26 (C9-50…53) — TL-B9b (02/11, [32](32-ra-soat-01-11.md) mục 4): bot 5 lớp tầng 14–19 sau khi thêm hệ số mỗi tầng (HP ×1,14, Tấn công ×1,05) + Thần Tướng HP ×3

### G — Đồ hoạ và âm thanh

- [x] DH-01: chốt phong cách đồ hoạ (pixel art sinh bằng code)
- [x] G1: DH-02, 04, 05, 06, 07, 09 — hình chương 1, icon, nối vào game ([07](07-do-hoa-ke-hoach.md))
- [ ] DH-03: Thợ Săn vào game (cùng M3); AR-41: icon 3 kỹ năng mới mỗi lớp
- [ ] DH-08: vùng 2 (cùng M4, AR-40)
- [ ] DH-10 phần còn lại, DH-11 khung giao diện, DH-12/13 âm thanh (G2) — 01/11: nhạc riêng 9 vùng + âm kỹ năng theo lớp đã có ([32](32-ra-soat-01-11.md) mục 3)
- [x] AR-44 (phần nhân vật): sprite 5 lớp cắt từ sprite sheet chủ dự án cung cấp (`tools/art/class_sheet.py` → `pc-<lớp>`), thay thân nhân vật sinh bằng code trong trận và giao diện (27/10/2026); 20 icon kỹ năng cắt từ hình kỹ năng 5 lớp (`tools/art/class_skill_icons.py`); lựa chọn Kiểu hình (Hình lớp / Tuỳ biến); thẻ chọn lớp + chân dung từ sheet; 10 hiệu ứng kỹ năng `fx-sheet-*` (`view/class_fx.gd`); test AR-44

## 13. Quyết định đang chờ chủ dự án

| # | Câu hỏi | Ảnh hưởng | Mặc định đang dùng |
| --- | --- | --- | --- |
| 1 | Nền tảng ra mắt đầu tiên: PC hay Mobile? | Điều khiển, giao diện, KT-08 | PC (bàn phím + chuột) |
| 2 | ~~Phong cách đồ hoạ (DH-01)~~ | Toàn bộ nhánh G | **Đã chốt** 20/10/2026: pixel art sinh bằng code (thay được bằng hình hoạ sĩ vẽ sau, giữ kích thước frame) |
| 3 | Q1–Q5 (trang bị) — [03-mvp-spec mục 3.9](03-mvp-spec.md) | Rơi đồ, boss, túi đồ | Như spec |
| 4 | Q6–Q12 (Thiên phú) — [03-mvp-spec mục 4.10](03-mvp-spec.md) | Kỹ năng L, Tinh Kim, công trình | Như spec |
| 5 | Tốc độ hồi Đuốc khi phát hành (KP-02) | Nhịp độ khai phá | 2 phút/cái (kịch bản: 20 phút) |
| 6 | ~~Khởi tạo Git cho dự án (KT-05)~~ | An toàn mã nguồn | **Đã xong** 20/10/2026, có remote GitHub |
| 7 | Q13–Q16: số liệu Đạo Tặc cướp thuộc tính, độc nhất server — [CR-01](03-mvp-spec.md) | Thiên phú SSS | Như CR-01 (đã code ở M3) |
| 10 | Q28–Q34: 8 kỹ năng, phím 1–4, INT/LUK, né tránh, MP, tinh anh vùng 1, không đổi lớp — [03 mục 5.11](03-mvp-spec.md) | Combat 2 lớp | Như spec M3 (đã code) |
| 11 | Q46–Q50: phép kết hợp Ngũ Hành của Pháp Sư, cách chuyển cường hoá, bộ lọc mặc định, kích thước map, sương che quái — [09 mục 5](09-spec-notes-dot-2.md) | Pháp Sư, túi đồ, bản đồ | Như 09 mục 5 (đã code) |
| 13 | ~~Q65–Q70: hệ kỹ năng~~ — [13 mục 6](13-he-ky-nang.md) | Toàn bộ combat | **Đã chốt** 21/10/2026 "theo đề xuất": mở theo cấp + chuyển chức + Bí Kíp, 4 ô, Điểm Kỹ Năng riêng, Bí Kíp tầng III khoá nhân vật, ngũ hành ở biến thể tầng II, làm SK1 trước |
| 14 | Q76–Q98: chương 7–9 — lãnh địa cấp 5 = Hoàng Thành, Lõi Hư Vô dùng cho chuyển chức 3 (lệch 06 Q26), giá nâng lãnh địa, Đột Phá cho Thiên phú hết bậc, Kỳ Lân / Hút Thiên phú / Không Mặt / Sứ Giả mềm hơn 06, chức 3 hợp nhánh + Thần Kỹ, kết thúc không đổi lại, cấp sau 100 cho cả hai kết thúc, endgame tối thiểu — [16 mục 9](16-chuong-7.md), [17 mục 9](17-chuong-8.md), [18 mục 10](18-chuong-9.md) | Chương 7–9, endgame | Như cột Mặc định đề xuất của từng spec |
| 12 | Q59–Q64: mức "chiến tranh lãnh địa" ở MVP, thiên thạch −25% HP, Bình Nước Thánh cho Phượng Hoàng, chuyển chức 2 tốn 30 Tinh Thạch, ô Thiên phú phụ 2, phe Kim Luân — [12 mục 8](12-chuong-5.md) | Chương 5 | Như 12 mục 8 |
| 15 | Q140–Q146: chuyển chức 3 khi chưa có chương 8 (Liệt Diễm, cấp 90 + 50 Tinh Thạch), Thủ Hộ Thần / Vạn Linh Chi Chủ tự thiết kế, boss không đánh linh thú, thú cưng / Xương Nô không có máu, Bản Ngã sao chép Thần Kỹ, cây 3 chức ở màn chọn lớp — [23 mục 7](23-chuyen-chuc-3-linh-thu-co-mau.md) | Chuyển chức 3, linh thú | Như cột Mặc định của 23 (đã code, trừ Q146) |
| 16 | Q195–Q201: làm lại hệ thống nhiệm vụ — đợt làm trước (P1 rõ ràng / P2 uỷ thác / P3 nhiệm vụ phụ / P4 đa dạng chính tuyến), phím sổ nhiệm vụ, số uỷ thác / ngày, thưởng chọn 1 trong 3, danh hiệu, đổi 8 bước "hạ 30 quái", sự kiện trên đường — [41](41-de-xuat-nhiem-vu.md) mục 7 | Nhiệm vụ, HUD, save | **Đã chốt 05/11**: làm hết P1–P4 (lần lượt), giữ mặc định gợi ý (phím O, 3 uỷ thác / ngày đổi lúc 0 giờ giờ máy, thưởng chọn 1 trong 3, danh hiệu chỉ trang trí, đổi 8 bước "hạ 30 quái", sự kiện trên đường làm ở P4) |
| 17 | Q229–Q236: thêm cách tăng Lực chiến cho trang bị — [47](47-de-xuat-nang-luc-chien-trang-bi.md) §8 | Trang bị, Lò Rèn, cân bằng, save | **Đã chốt 09/11** ("triển khai theo đề xuất"): cả 6 đường P1 → P3, mở khảm ngọc vùng 2, ấn hệ +15%, tẩy 1 dòng, không lên Cam, Thức Tỉnh 4 món, Túi Ngọc riêng; Q235 chỉnh độ khó để sau chơi thử |

### 13.1. Đã chốt

Chủ dự án uỷ quyền (20/10/2026) chọn phương án tốt nhất, hợp thị trường. Lý do chi tiết ở [05 mục 7](05-thien-phu-chi-tiet.md) và [06 mục 7](06-ban-do-quai-boss.md).

| # | Quyết định | Hạng mục theo dõi |
| --- | --- | --- |
| Q17 | Hiệu ứng chính Thiên phú tăng đều tới ×1,5 ở Lv10, làm ở M3 | TP-41 |
| Q18 | Tiến hoá đặt lại Lv1 nhưng không tụt sức mạnh, hoàn 50% Tinh Hoa | TP-42 |
| Q19 | Tiến hoá lên SSS không bị giới hạn độc nhất; có thông báo toàn server | TP-45 |
| Q20 | Dùng tên/hiệu ứng tiến hoá như tài liệu 05; cây tiến hoá hiện trước | TP-12, TP-43 |
| Q21 | Dùng cặp cộng hưởng như tài liệu 05; hiện "???" tới khi kích hoạt | TP-13, TP-44 |
| Q22 | Áp công thức chỉ số quái mới ngay ở M3; M5 chỉ tinh chỉnh hệ số | CB-21 |
| Q23 | Quái thường 3 đòn, tinh anh 12; boss chương 1 = 90, chương 2–3 = 110, chương 4+ = 130; boss hiếm 200 | CB-22 |
| Q24 | 15 ô mỗi map con; vùng 1 = 40 ô | BD-06 |
| Q25 | Boss vùng 1 cấp 6 giữa vùng; Lõi Sương mở sau boss | BD-06 |
| Q26 | Chỉ thêm Đá, Sắt, Tinh Thạch; Bến Cá là buff lãnh địa; bỏ Tinh Thạch Hư Vô | KP-06, TB-11 |
| Q27 | Dùng tên, kỹ năng, đồ Cam như tài liệu 06 | BD-02…04, CB-18…20 |
| Q43–Q45 | Gift code: lượt **thêm**; tỉ lệ A 65 · S 25 · SS 9 · SSS 1; **1 mã** mỗi nhân vật (chủ dự án chốt) | TP-46 |
