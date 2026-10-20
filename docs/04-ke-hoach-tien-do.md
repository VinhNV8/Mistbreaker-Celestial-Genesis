# Kế hoạch và theo dõi tiến độ

| | |
| --- | --- |
| Dự án | Thiên Phú Khai Giới |
| Nguồn yêu cầu | [Kịch bản game](kich-ban-game-thien-phu-khai-gioi.md), mục 2–9 |
| Spec chi tiết | [01 — Prototype](01-requirement-spec.md) · [03 — MVP](03-mvp-spec.md) · [02 — Kỹ thuật](02-technical-spec.md) |
| Thiết kế nội dung | [05 — 20 Thiên phú](05-thien-phu-chi-tiet.md) (cấp, kỹ năng, tiến hoá, cộng hưởng) · [06 — Bản đồ, quái, boss](06-ban-do-quai-boss.md) (9 vùng, công thức chỉ số, 36 quái thường, 18 tinh anh, 9 boss chương, 9 boss hiếm). Cả hai **đã chốt** 20/10/2026 (Q17–Q27, mục 13) · [07 — Đồ hoạ](07-do-hoa-ke-hoach.md) (phong cách, hạng mục AR-xx) |
| Cập nhật | 20/10/2026 (sau đợt M3) |

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
| Thế giới quan, cốt truyện (mục 2) | 13 | 0 | 4 | 9 | 0 |
| Thiên phú (mục 3) | 41 | 23 | 9 | 9 | 0 |
| Nhân vật, chỉ số (mục 4) | 26 | 12 | 4 | 10 | 0 |
| Chiến đấu, quái (mục 5) | 23 | 15 | 2 | 5 | 1 |
| Bản đồ, vượt map (mục 6) | 11 | 0 | 2 | 9 | 0 |
| Khai phá, lãnh địa (mục 7) | 22 | 7 | 4 | 11 | 0 |
| Trang bị, kinh tế (mục 8) | 14 | 7 | 2 | 4 | 1 |
| 30 phút đầu (mục 9) | 9 | 5 | 1 | 3 | 0 |
| Đồ hoạ, âm thanh | 13 | 8 | 1 | 4 | 0 |
| Kỹ thuật, phát hành | 10 | 4 | 1 | 5 | 0 |
| **Tổng** | **182** | **81** (45%) | **30** (16%) | **69** (38%) | **2** |

### Các giai đoạn

| Giai đoạn | Phạm vi (kịch bản mục 9) | Trạng thái |
| --- | --- | --- |
| Prototype | Combat cơ bản, 1 lớp, 5 Thiên phú, 1 map, 1 boss, lưới khai phá 10 ô | ✅ Xong 19/10/2026 |
| MVP — M1 | Trang bị, cường hoá, phân rã, Lực chiến | ✅ Xong 20/10/2026 |
| MVP — M2 | Đủ 20 Thiên phú, luyện cấp, Đền Thiên Phú, công trình có thời gian xây | ✅ Xong 20/10/2026 |
| MVP — M3 | Lớp Thợ Săn, chọn lớp khi tạo nhân vật, đủ 4 kỹ năng mỗi lớp | ✅ Xong 20/10/2026 |
| MVP — M4 | Chương 2: Đồng Bằng Gió Hú, boss Huyền Ảnh, Thành Biên Đài, bản đồ lục địa, di chuyển giữa vùng | ⬜ Tiếp theo |
| MVP — M5 | Cốt truyện có thoại, hướng dẫn, nhiệm vụ, boss hiếm, Xưởng Rèn, cân bằng 1 → 20 | ⬜ |
| MVP — G | Đồ hoạ nhân vật, quái, bản đồ, hiệu ứng, âm thanh cho chương 1–2 | 🟡 G1 (hình chương 1, sinh bằng code) xong 20/10/2026 — [07](07-do-hoa-ke-hoach.md); còn âm thanh, khung giao diện, vùng 2 |
| Thử nghiệm kín | 50–100 người chơi (kịch bản mục 9) | ⬜ Cần M3–M5 + G |
| Alpha | 4 lớp, chương 1–5, chuyển chức 1–2, dungeon cổng ngẫu nhiên, bảng xếp hạng | ⬜ |
| Beta | Chương 1–9, endgame, boss thế giới, shop, sự kiện theo mùa | ⬜ |

## 2. Thế giới quan và cốt truyện (kịch bản mục 2)

| Mã | Hạng mục | Trạng thái | Đợt | Kiểm chứng | Ghi chú |
| --- | --- | --- | --- | --- | --- |
| CT-01 | Bối cảnh Huyền Thổ, đại nạn Thiên Liệt | 🟡 | Proto / M5 | — | Mới có trong 2 trang sách Di tích; chưa có cutscene mở đầu (xem TN-01) |
| CT-02 | Nhân vật chính ở làng Thanh Thạch, Lễ Thức Tỉnh tuổi 16 | 🟡 | Proto / M5 | AWK-01…05 | Có Lễ Thức Tỉnh; chưa có thoại giới thiệu nhân vật |
| CT-03 | Bí mật "mảnh Thiên phú thứ hai" | 🟡 | M5 / Beta | — | Mới gợi ý ở màn hình kết chương 1 ("Thiên phú khẽ rung động") |
| CT-04 | Phe Liên minh Khai Giới (giao nhiệm vụ, xếp hạng) | ⬜ | M4 | — | Gặp ở Thành Biên Đài, chương 2 |
| CT-05 | Phe Thương hội Kim Luân (cửa hàng, đấu giá, hộ tống) | ⬜ | M5 / Alpha | — | |
| CT-06 | Phe Thánh Đường Tinh Quang (thức tỉnh, tiến hoá Thiên phú) | ⬜ | Alpha | — | Gắn với tiến hoá hạng (TP-12) |
| CT-07 | Phe Hư Vô Giáo (phản diện) | ⬜ | M4 | — | Gián điệp trong thành, chương 2 |
| CT-08 | Phản diện Ma Tôn Vô Diện | ⬜ | Beta | — | Boss chương 9 |
| CT-09 | Chương 1 — Thức Tỉnh | 🟡 | Proto / M5 | MOB-10 | Đủ gameplay và boss; thiếu thoại, cutscene, hướng dẫn |
| CT-10 | Chương 2 — Thành Biên Đài | ⬜ | M4 | — | |
| CT-11 | Chương 3–5 | ⬜ | Alpha | — | |
| CT-12 | Chương 6–9 | ⬜ | Beta | — | |
| CT-13 | Hai kết thúc (Hợp nhất / Hiến tế) | ⬜ | Beta | — | |

## 3. Hệ thống Thiên phú (kịch bản mục 3)

Thiết kế chi tiết từng Thiên phú (hiệu ứng Lv1 → Lv10, 2 bậc tiến hoá, cộng hưởng, tương tác 4 lớp): [05-thien-phu-chi-tiet.md](05-thien-phu-chi-tiet.md).

| Mã | Hạng mục | Trạng thái | Đợt | Kiểm chứng | Ghi chú |
| --- | --- | --- | --- | --- | --- |
| TP-01 | 1 Thiên phú chính khi vào game qua Lễ Thức Tỉnh | ✅ | Proto | AWK-01 | |
| TP-02 | 3 lần quay lại miễn phí, chọn bất kỳ lần nào | ✅ | Proto | AWK-01, 02 | |
| TP-03 | Bảo hiểm: 4 lần dưới hạng B thì lần cuối lên B | ✅ | Proto | AWK-04 | |
| TP-04 | Hiệu ứng ánh sáng theo màu hạng khi chạm Bia Đá | 🟡 | Proto / G | — | Có viền màu theo hạng; chưa có hiệu ứng ánh sáng thật |
| TP-05 | Ô Thiên phú phụ ở cấp 30 và 60, tối đa 3 Thiên phú | ⬜ | Alpha | — | |
| TP-06 | 7 hạng F → SSS, đúng tỉ lệ quay | ✅ | M2 | TL-A | 200.000 lần quay, lệch < 0,5 điểm % |
| TP-07 | Nguyên tắc cân bằng: F và S chênh ≤ 25% | ✅ | M2 | TL-B | Chênh 7% (bot đánh boss chương 1) |
| TP-08 | Đủ 20 Thiên phú mẫu | ✅ | M2 | TL-C, TL-D | Chi tiết từng Thiên phú ở mục 3.1 |
| TP-09 | Kỹ năng chủ động hạng B, kỹ năng tối thượng hạng S | 🟡 | M2 | TL-D | Kịch bản không ghi kỹ năng cụ thể; spec tự thiết kế, **chờ duyệt Q6** |
| TP-10 | Luyện cấp Thiên phú Lv 1 → 10 bằng Tinh Hoa | ✅ | M2 | TL-G | |
| TP-11 | Mỗi 5 cấp mở 1 hiệu ứng phụ | 🟡 | M2 | TL-G | Bảng hiệu ứng phụ theo nhóm do spec đề xuất, **chờ duyệt Q11** |
| TP-12 | Tiến hoá hạng (ví dụ Tay Nhanh → Phong Ảnh Thủ → Vô Ảnh Kiếm), bắt buộc ở chương 4 và 7 | ⬜ | Alpha | — | |
| TP-13 | Cộng hưởng 2 Thiên phú cùng nhóm | ⬜ | Alpha | — | Cần có Thiên phú phụ (TP-05) trước |
| TP-14 | Tẩy Thiên phú bằng Nước Thánh Tinh Quang, giữ 50% cấp | ⬜ | Alpha | — | |
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
| TP-26 | Khứu Giác Kho Báu | C | 🟡 | Đã có: hiện rương ẩn 30 m (mục 3). Chưa có: "tăng tỉ lệ Di tích lên 20%" (mục 7) — làm ở M4 khi có lưới khai phá vùng 2 |
| TP-27 | Kiếm Tâm | B | ✅ | Có kỹ năng L Nhất Kiếm Đoạn (bổ sung). Có thể hơi mạnh (phát hiện F4) |
| TP-28 | Nhà Thảo Dược | B | ✅ | Có kỹ năng L Linh Dược (bổ sung) |
| TP-29 | Trái Tim Lãnh Chúa | B | ✅ | Có kỹ năng L Hiệu Triệu (bổ sung) |
| TP-30 | Thuần Thú Sư | A | ✅ | M3: thu phục cả quái Ổ quái (TP-T2); ngưỡng 10% → 15% và thú cưng +0 → 50% tấn công theo cấp Thiên phú |
| TP-31 | Mắt Ưng | A | ✅ | |
| TP-32 | Hấp Huyết | A | ✅ | |
| TP-33 | Bàn Tay Vàng | A | 🟡 | "Nguyên liệu hiếm" được định nghĩa là Tinh Kim, **chờ duyệt Q10** |
| TP-34 | Ngũ Hành Linh Căn | S | 🟡 | Kịch bản ghi "dùng cả 5 hệ phép" (dành cho Pháp Sư); với Kiếm Khách làm thành đòn đánh mang hệ. Xem lại khi có Pháp Sư (Alpha) |
| TP-35 | Thời Gian Ngưng Đọng | S | ✅ | |
| TP-36 | Bầy Đàn Bóng Tối | S | ✅ | Có kỹ năng L Bóng Tối Trỗi Dậy (bổ sung) |
| TP-37 | Thiên Mệnh Khai Giới | SS | ✅ | |
| TP-38 | Long Mạch | SS | ✅ | |
| TP-39 | Đạo Tặc (Ẩn) — sao chép kỹ năng boss | SSS | 🟡 | Mới sao chép được kỹ năng của 1 boss (Sói Chúa); thêm kỹ năng khi có boss mới (M4 trở đi) |
| TP-40 | Đạo Tặc (Ẩn) — Cướp Thuộc Tính khi hạ quái | SSS | ✅ | M3 ([CR-01](03-mvp-spec.md), DT-01…08, test TP-T3). Code theo mặc định Q13–Q16 — số liệu vẫn chờ duyệt |

### 3.2. Bổ sung từ thiết kế chi tiết ([05](05-thien-phu-chi-tiet.md), đã chốt Q17–Q21)

| Mã | Hạng mục | Trạng thái | Đợt | Kiểm chứng | Ghi chú |
| --- | --- | --- | --- | --- | --- |
| TP-41 | Hiệu ứng chính mạnh dần theo Lv, Lv10 = ×1,5 (05 mục 1.2) | ✅ | M3 | TP-T1 | **Q17**. 20 Thiên phú nội suy Lv1 → Lv10 theo bảng 05 mục 2.1; bảng Thiên phú hiện giá trị cấp này → cấp sau |
| TP-42 | Tiến hoá đặt lại Lv1, không tụt sức mạnh, hoàn 50% Tinh Hoa | ⬜ | Alpha | — | **Q18**. Đi cùng TP-12 |
| TP-43 | Bảng Thiên phú hiện trước cây tiến hoá (tên, hạng, điều kiện) | ⬜ | M5 | — | **Q20**. Làm cùng hướng dẫn (TN-04) để người quay F thấy đường lên B |
| TP-44 | Cộng hưởng đặc biệt hiện "???" kèm gợi ý cho tới khi kích hoạt | ⬜ | Alpha | — | **Q21**. Đi cùng TP-13; Thợ Săn Di Tích hiện sẵn |
| TP-45 | Thông báo toàn server khi có người tiến hoá lên SSS (không giới hạn độc nhất) | ⬜ | Beta | — | **Q19**. Cần backend (KT-09) |

## 4. Nhân vật, chỉ số và lên cấp (kịch bản mục 4)

| Mã | Hạng mục | Trạng thái | Đợt | Kiểm chứng | Ghi chú |
| --- | --- | --- | --- | --- | --- |
| NV-01 | Lớp Kiếm Khách | ✅ | Proto | — | Mới có 1 kỹ năng (Xoáy Kiếm), cần đủ 4 (CB-01) |
| NV-02 | Lớp Thợ Săn | ✅ | M3 | CL-T1, CL-T2 | Bắn tên 45 m, Tấn công từ AGI, HP thấp hơn, né gốc 5%; vũ khí tên Cung |
| NV-03 | Lớp Pháp Sư | ⬜ | Alpha | — | |
| NV-04 | Lớp Hộ Vệ | ⬜ | Alpha | — | |
| NV-05 | Chọn lớp khi tạo nhân vật | ✅ | M3 | Smoke `02b-class` | Màn hình sau Lễ Thức Tỉnh; không đổi lớp giữa chừng (Q34) |
| NV-06 | Chuyển chức 1 (cấp 30) và 2 (cấp 60) | ⬜ | Alpha | — | |
| NV-07 | Chuyển chức 3 (cấp 90) | ⬜ | Beta | — | |
| NV-08 | Cấp tối đa 100 | ✅ | Proto | CHR-01 | |
| NV-09 | Cấp Thần Vực vô hạn (endgame) | ⬜ | Beta | — | |
| NV-10 | Chỉ số gốc STR, AGI, VIT | ✅ | Proto | — | |
| NV-11 | Chỉ số gốc INT | 🟡 | M3 / Alpha | CL-T1 | M3: +MP, hồi MP, +sát thương kỹ năng. Vai trò chính khi có Pháp Sư (Alpha) |
| NV-12 | Chỉ số gốc LUK | ✅ | M3 | CL-T1 | +0,3% chí mạng, +0,2 điểm % rơi đồ mỗi điểm (Q30) |
| NV-13 | 5 điểm mỗi cấp, tẩy điểm miễn phí trước cấp 30 | ✅ | Proto | CHR-02, 04 | |
| NV-14 | HP, Tấn công, Phòng thủ, Chí mạng, Sát thương chí mạng, Tốc đánh | ✅ | Proto / M1 | — | |
| NV-15 | MP | ✅ | M3 | CL-T3 | 50 + 5/cấp + 6/INT, hồi 3/giây; 8 kỹ năng tốn MP (Q32) |
| NV-16 | Né tránh | ✅ | M3 | CL-T4 | 0,3%/AGI, trần 30%, Thợ Săn gốc 5% (Q31) |
| NV-17 | Kháng 5 hệ | ⬜ | M4 | — | Cần khi quái vùng 2 đánh có hệ |
| NV-18 | Lực chiến, dùng để mở map và xếp hạng | 🟡 | M1 | EQ-17 | Đã tính và hiện ở HUD; chưa hiện "trên đầu" nhân vật; chưa dùng mở map (vùng 3, Alpha) |
| NV-19 | Công thức EXP | ✅ | Proto | CHR-01 | |
| NV-20 | Nhịp độ 1 → 10 trong 30 phút | 🟡 | M5 | — | Bot lên cấp 5 sau 101 giây (phát hiện F2); cần đo người thật khi playtest |
| NV-21 | Nguồn EXP: quái, boss, khai phá | ✅ | Proto | — | |
| NV-22 | Nguồn EXP: nhiệm vụ cốt truyện (25%) | ⬜ | M5 | — | |
| NV-23 | Nguồn EXP: dungeon | ⬜ | Alpha | — | |
| NV-24 | Nguồn EXP: offline từ lãnh địa (5%) | ⬜ | M4 | — | Chưa làm; hiện offline chỉ có gỗ, vàng, Đuốc |
| NV-25 | Quái thấp hơn 10 cấp chỉ cho 10% EXP | ⬜ | M4 | — | Chưa làm; cần khi có vùng 2 (cấp 10–20) |
| NV-26 | Cảnh báo khi quên cộng điểm tiềm năng | 🟡 | M5 | — | HUD có nhắc; phát hiện F1 đề xuất nút "tự cộng điểm" |

## 5. Chiến đấu và quái vật (kịch bản mục 5)

Chỉ số, kỹ năng từng quái/boss và công thức sức mạnh theo cấp: [06-ban-do-quai-boss.md](06-ban-do-quai-boss.md).

| Mã | Hạng mục | Trạng thái | Đợt | Kiểm chứng | Ghi chú |
| --- | --- | --- | --- | --- | --- |
| CB-01 | Đánh thường + **4 kỹ năng** + 1 kỹ năng Thiên phú + né lăn | ✅ | M3 | CL-T3 | 4 kỹ năng mỗi lớp, phím 1–4 (K/chuột phải = kỹ năng 1) (Q28, Q29) |
| CB-02 | Nút Tự đánh khi cày map cũ (boss vẫn phải đánh tay) | ⬜ | M5 | — | |
| CB-03 | Né lăn 0,3 giây bất tử, hồi 3 giây | ✅ | Proto | CMB-03 | |
| CB-04 | Né "Hoàn hảo" làm chậm thời gian 1 giây | ✅ | M3 | CB-T3 | Chặn đòn trong 0,15 giây đầu của né lăn → quái và đạn chậm còn 30% trong 1 giây |
| CB-05 | Ngũ hành tương khắc +30% | 🟡 | M2 | TL-C | Quái đã có hệ; người chơi chỉ đổi hệ được nhờ Ngũ Hành Linh Căn. Người khác cần Khảm ngọc (TB-08) |
| CB-06 | Thanh Phá Thế ở boss | ✅ | Proto | MOB-07 | |
| CB-07 | Thanh Phá Thế ở quái tinh anh | ✅ | M3 | CB-T4 | 30% HP, choáng 3 giây, +50% sát thương; hiện dưới thanh máu |
| CB-08 | Combo tăng EXP (+20% ở 100 combo) | ✅ | Proto | CMB-05 | |
| CB-09 | Công thức sát thương | ✅ | Proto | CMB-04 | |
| CB-10 | Quái thường 4–6 loại mỗi map | 🟡 | M4 | MOB-01, CB-T6 | Rừng Sương có 4 loại (thêm Mộc Tinh ở M3) |
| CB-11 | Quái tinh anh: viền sáng, rơi đồ xanh/tím | ✅ | M1 | EQ-04 | |
| CB-12 | Quái tinh anh có 1 kỹ năng đặc biệt riêng | ✅ | M3 | CB-T5 | Sói Đầu Đàn: Hú gọi · Nấm Mẹ: Sinh sôi (Nấm Con tự nổ) (Q33) |
| CB-13 | Thủ lĩnh cứ điểm canh ô đất | ✅ | Proto | EXP-05 | Dạng Ổ quái |
| CB-14 | Boss vùng 2–3 giai đoạn, rơi Tinh Hoa | ✅ | Proto / M2 | MOB-06…10, TL-G | |
| CB-15 | Boss hiếm, xuất hiện 2 lần/ngày, rơi đồ Cam | ⬜ | M5 | — | Tạm thời Sói Chúa rơi đồ Cam 15% (**Q2**) |
| CB-16 | Boss thế giới (cả server) | ⛔ | Beta | — | Cần online; xem lại khi có backend |
| CB-17 | Boss chương 1 Sói Chúa Hư Vô | ✅ | Proto | MOB-06…10 | |
| CB-18 | Boss chương 2 Tướng Gián Điệp Huyền Ảnh (phân thân 3, bản thật có bóng) | ⬜ | M4 | — | |
| CB-19 | Boss chương 3–5 | ⬜ | Alpha | — | |
| CB-20 | Boss chương 6–9 | ⬜ | Beta | — | |
| CB-21 | Chỉ số quái tính bằng công thức mới (06 mục 1) thay cho bảng số cứng | ✅ | M3 | CB-T1 | **Q22**. `Formulas.mob_stats()` giống hệt `tools/gen_world_doc.py` |
| CB-22 | Số đòn mục tiêu: thường 3, tinh anh 12, boss chương 1 = 90 / chương 2–3 = 110 / chương 4+ = 130, boss hiếm 200 | ✅ | M3 | CB-T1, TL-B | **Q23**. Sói Chúa 4.023 HP; bot mặc bộ đồ chuẩn hạ trong khoảng 30 giây (phát hiện F7) |
| CB-23 | Khoá hang boss khi boss đã xuất hiện (không đánh xa từ ngoài hang) | ✅ | M3 | TL-B | Bổ sung trong M3 (03 mục 5.12): bot Thợ Săn phát hiện lỗ hổng |

## 6. Bản đồ và vượt map (kịch bản mục 6)

Chi tiết 9 vùng × 3 map con, cơ chế môi trường có số liệu, bộ trang bị và đồ Cam từng vùng: [06-ban-do-quai-boss.md](06-ban-do-quai-boss.md).

| Mã | Hạng mục | Trạng thái | Đợt | Kiểm chứng | Ghi chú |
| --- | --- | --- | --- | --- | --- |
| BD-01 | Vùng 1 Rừng Sương (cấp 1–10, hệ Mộc) | 🟡 | Proto | — | Mới 1 map; kịch bản: 3 map con (Ngoài rìa → Trung tâm → Lõi) + dungeon boss |
| BD-02 | Vùng 2 Đồng Bằng Gió Hú (cấp 10–20, hệ Kim, gió đẩy lùi) | ⬜ | M4 | — | |
| BD-03 | Vùng 3–5 | ⬜ | Alpha | — | Vùng 3 mở bằng Lực chiến 5.000 |
| BD-04 | Vùng 6–9 | ⬜ | Beta | — | |
| BD-05 | Điều kiện mở map: đủ cấp + hạ boss vùng + khai phá ≥ 60% | 🟡 | Proto | MOB-05 | Có cho hang boss vùng 1; áp dụng cho chuyển vùng ở M4 |
| BD-06 | 3 map con mỗi vùng + dungeon boss | ⬜ | M4 | — | **Q24, Q25**: 15 ô mỗi map con (vùng 1 = 10 + 15 + 15 = 40 ô); boss cấp 6 ở giữa vùng 1, Lõi Sương (7–10) mở sau boss |
| BD-07 | Bản đồ lục địa, di chuyển giữa các vùng | ⬜ | M4 | — | Cũng là cảnh kết chương 1 (TN-09) |
| BD-08 | Cứ điểm chiếm được thành điểm dịch chuyển | ⬜ | M4 | — | |
| BD-09 | Thử thách vượt ải: vào map cao hơn 5 cấp, thắng được EXP ×2 | ⬜ | M4 | — | |
| BD-10 | 3 độ khó mỗi vùng (Thường / Ác mộng / Địa ngục) | ⬜ | Beta | — | |
| BD-11 | Dungeon cổng ngẫu nhiên hạng E → S, tồn tại 2 giờ | ⬜ | Alpha | — | |

## 7. Khai phá vùng đất mới (kịch bản mục 7)

| Mã | Hạng mục | Trạng thái | Đợt | Kiểm chứng | Ghi chú |
| --- | --- | --- | --- | --- | --- |
| KP-01 | Lưới ô lục giác bị sương mù che | 🟡 | Proto | EXP-01 | 10 ô; kịch bản: 40–60 ô mỗi vùng. Mở rộng ở M4 |
| KP-02 | Đuốc Khai Giới, tối đa 10, hồi 1 cái/20 phút | 🟡 | Proto | EXP-03 | Đang hồi 2 phút/cái để test nhanh; quyết định giá trị thật sau playtest |
| KP-03 | Do thám → khám phá sự kiện → chinh phục | ✅ | Proto | EXP-02, 05 | |
| KP-04 | Chinh phục bằng giải câu đố | ⬜ | M5 | — | Hiện chỉ chinh phục bằng đánh quái |
| KP-05 | Xây công trình theo địa hình: rừng → Xưởng Gỗ | ✅ | Proto / M2 | EXP-04, TL-F | |
| KP-06 | Núi → Mỏ, sông → Bến Cá | ⬜ | M4 | — | Cần thêm tài nguyên Đá, Sắt (TB-11). **Q26**: Bến Cá không tạo tài nguyên, cho buff lãnh địa +3% HP mỗi cấp (tối đa +15%) |
| KP-07 | Phòng thủ: Triều Hư Vô mỗi 24 giờ chiếm lại công trình không được bảo vệ | ⬜ | Alpha | — | Cần Doanh Trại (KP-17) |
| KP-08 | Sự kiện Tài nguyên, Ổ quái, Di tích, Người sống sót, Kỳ quan | ✅ | Proto | EXP-01 | |
| KP-09 | Sự kiện Thương nhân lữ hành (bán đồ hiếm, 1 giờ) | ⬜ | M5 | — | |
| KP-10 | Sự kiện Cổng dungeon | ⬜ | Alpha | — | Gắn với BD-11 |
| KP-11 | Tỉ lệ sự kiện theo bảng kịch bản (35/25/12/10/8/7/3%) | 🟡 | M4 | — | Lưới 10 ô hiện chia cố định 4/2/2/1/1; dùng tỉ lệ thật khi lưới lớn hơn |
| KP-12 | Trung tâm lãnh địa: Trại → Thôn | ✅ | Proto / M2 | TL-F | |
| KP-13 | Trung tâm lãnh địa: Trấn → Thành → Hoàng Thành | ⬜ | Alpha / Beta | — | |
| KP-14 | Đền Thiên Phú | ✅ | M2 | TL-G | |
| KP-15 | Xưởng Rèn (chế trang bị) | ⬜ | M5 | — | Có trong phạm vi MVP (03-mvp-spec mục 1) |
| KP-16 | Vườn Thảo Dược (thuốc) | ⬜ | M5 | — | Hiện bình máu chế từ thảo dược hái ngoài đồng |
| KP-17 | Doanh Trại, Tháp Canh | ⬜ | Alpha | — | |
| KP-18 | Cảng Khí Cầu (đi vùng 7) | ⬜ | Beta | — | |
| KP-19 | Dân cư có kỹ năng nghề, xếp vào công trình | ⬜ | Alpha | — | Hiện người sống sót chỉ +10% sản lượng |
| KP-20 | Thu hoạch offline tối đa 12 giờ | ✅ | Proto | EXP-09 | |
| KP-21 | Thiên phú ảnh hưởng khai phá: Mắt Ưng, Trái Tim Lãnh Chúa | ✅ | Proto / M2 | TL-C, TL-F | |
| KP-22 | Thiên phú ảnh hưởng khai phá: Khứu Giác (Di tích 20%), Thuần Thú (quái Ổ quái) | 🟡 | M3 / M4 | TP-T2 | Thuần Thú xong ở M3; Khứu Giác Di tích làm ở M4 (TP-26) |

## 8. Trang bị, kinh tế và vòng lặp (kịch bản mục 8)

| Mã | Hạng mục | Trạng thái | Đợt | Kiểm chứng | Ghi chú |
| --- | --- | --- | --- | --- | --- |
| TB-01 | Túi đồ (inventory) | ✅ | M1 | EQ-09, 18 | Phím I, 30 ô |
| TB-02 | 8 ô trang bị | ✅ | M1 | EQ-01 | |
| TB-03 | 5 phẩm chất, đúng số affix | ✅ | M1 | EQ-02 | |
| TB-04 | Bộ trang bị mỗi vùng (2/4/6 món) | 🟡 | M1 | EQ-15 | Có bộ vùng 1; bộ vùng 2 làm ở M4 |
| TB-05 | Bộ cộng hưởng với nhóm Thiên phú (ví dụ "Người Khai Hoang") | ⬜ | M4 | — | |
| TB-06 | Cường hoá +1 → +15, thất bại không mất đồ | ✅ | M1 | EQ-12, 13 | Từ +10 cần Tinh Kim (M2, **Q10**) |
| TB-07 | Phân rã | ✅ | M1 | EQ-14 | |
| TB-08 | Khảm ngọc ngũ hành, đổi hệ vũ khí | ⬜ | Alpha | — | |
| TB-09 | Đồ Cam có hiệu ứng riêng | 🟡 | M1 | EQ-16 | Mới có 1 món (Nanh Sói Chúa) |
| TB-10 | Vàng, Gỗ, Thiên Phú Tinh Hoa, Đuốc | ✅ | Proto / M2 | — | |
| TB-11 | Đá, Sắt, Tinh Thạch | ⬜ | M4 | — | Cần cho nâng Trấn và Mỏ. **Q26**: không thêm tiền tệ nào khác (bỏ Tinh Thạch Hư Vô, thay bằng vật phẩm cốt truyện Lõi Hư Vô) |
| TB-12 | Mua bình thuốc bằng vàng, bán đồ lấy vàng | ⬜ | M5 | — | Cần cửa hàng (Thương hội) |
| TB-13 | Vòng lặp chiến đấu ↔ khai phá ↔ lãnh địa | ✅ | Proto | — | |
| TB-14 | Ngọc Thiên Đạo (tiền nạp), Battle Pass, thẻ tháng, ngoại hình | ⛔ | Beta | — | Cần backend; nếu bán mua đứt trên Steam thì bỏ |

## 9. Kịch bản 30 phút đầu (kịch bản mục 9)

| Mã | Phút | Cảnh | Trạng thái | Đợt | Ghi chú |
| --- | --- | --- | --- | --- | --- |
| TN-01 | 0–2 | Cutscene Thiên Liệt, giọng kể | ⬜ | M5 + G | Hiện vào thẳng màn hình tiêu đề |
| TN-02 | 2–4 | Tạo nhân vật: chọn ngoại hình, lớp | 🟡 | M3 + G | Chọn lớp xong ở M3; chọn ngoại hình cần đồ hoạ |
| TN-03 | 4–7 | Lễ Thức Tỉnh, lời Trưởng làng | ✅ | Proto | |
| TN-04 | 7–10 | Hướng dẫn combat: quái tấn công làng, học đánh/né/kỹ năng | ⬜ | M5 | Hiện chỉ có 1 dòng thông báo |
| TN-05 | 10–15 | Rừng Sương: lên cấp 5, nhặt đồ xanh đầu tiên | ✅ | Proto / M1 | EQ-05 |
| TN-06 | 15–19 | Khai phá đầu tiên, gặp người sống sót | ✅ | Proto | |
| TN-07 | 19–23 | Xây công trình đầu tiên, cộng điểm | ✅ | Proto / M2 | |
| TN-08 | 23–28 | Boss Sói Chúa 2 giai đoạn, thanh Phá Thế | ✅ | Proto | |
| TN-09 | 28–30 | Bản đồ lục địa hiện ra, vùng 2 sáng lên | ⬜ | M4 | Hiện là màn hình chữ "Chương 1 hoàn thành" |

## 10. Đồ hoạ và âm thanh (nhánh G)

Phong cách đã chốt: **pixel art góc trên xuống 3/4, sinh bằng code** (kịch bản mục 9 hỏi *"pixel art, 2.5D anime hay 3D low-poly?"*). Chi tiết, nghiên cứu, hạng mục AR-xx: [07-do-hoa-ke-hoach.md](07-do-hoa-ke-hoach.md). Công cụ: skill Claude Code `game-art` + `tools/art/`.

| Mã | Hạng mục | Trạng thái | Đợt | Ghi chú |
| --- | --- | --- | --- | --- |
| DH-01 | **Chốt phong cách đồ hoạ** | ✅ | G1 | Pixel art 3/4, frame 24/32/48 px, ×2, sinh bằng code (07 mục 1.2) |
| DH-02 | Sprite nhân vật Kiếm Khách: đứng, chạy, chém, Xoáy Kiếm, né, trúng đòn, chết | ✅ | G1 | AR-10. Xoáy Kiếm = frame chém + nháy sáng + vòng vector; né = mờ |
| DH-03 | Sprite nhân vật Thợ Săn | ✅ | G1 / M3 | AR-11: có trong game từ M3; thêm 8 icon kỹ năng, tên bay, kiếm khí, bẫy (AR-41) |
| DH-04 | Sprite quái: Sói Sương, Nấm Độc, Tinh Linh Sương (+ biến thể tinh anh) | ✅ | G1 | AR-12, AR-13 (thêm Mộc Tinh). Tinh anh: cùng hình, to hơn, ánh vàng, vòng chân |
| DH-05 | Sprite boss Sói Chúa Hư Vô (2 giai đoạn, tàng hình) | ✅ | G1 | AR-14: 48×48, bờm Hư Vô, mắt đỏ, hào quang; giai đoạn 2 ánh đỏ; tàng hình = mờ |
| DH-06 | Đồng minh: thú cưng, lính bóng tối | ✅ | G1 | AR-15: hình quái gốc, vòng xanh / tô tím |
| DH-07 | Tileset Rừng Sương, Làng Thanh Thạch, Hang Sói Chúa (dùng TileMap của Godot) | ✅ | G1 | AR-16: lát ô bằng đa giác UV (không cần TileMap), 4 loại cây, bụi, nhà, Bia Đá |
| DH-08 | Tileset Đồng Bằng Gió Hú, Thành Biên Đài | ⬜ | G | Sau M4 |
| DH-09 | Icon 8 ô trang bị × 5 phẩm chất, icon tài nguyên, icon 20 Thiên phú | ✅ | G1 | AR-17…20: 41 icon; phẩm chất vẽ bằng khung màu |
| DH-10 | Hiệu ứng (VFX): chém, kỹ năng, vòng báo hiệu, ánh sáng Bia Đá theo hạng | 🟡 | G1 / G2 | AR-21: đạn bào tử, tia trúng đòn, hoạt ảnh chết; chém/xoáy/vòng báo hiệu vẫn vẽ vector; Bia Đá theo hạng chưa làm |
| DH-11 | Giao diện có art (khung, nút, font chính thức) | ⬜ | G | Hiện dùng theme tối mặc định + font hệ thống |
| DH-12 | Âm thanh: đánh, trúng đòn, nhặt đồ, lên cấp, giao diện | ⬜ | G | |
| DH-13 | Nhạc nền: làng, rừng, boss | ⬜ | G | |

Khi có art, chỉ cần thay `scripts/view/world_view.gd` (vẽ) và theme UI; logic game không đổi (technical spec, quyết định D2, D6).

## 11. Kỹ thuật và phát hành

| Mã | Hạng mục | Trạng thái | Đợt | Ghi chú |
| --- | --- | --- | --- | --- |
| KT-01 | Engine Godot 4.7.2 | ✅ | Proto | |
| KT-02 | Dữ liệu tách khỏi logic (designer chỉnh không sửa code) | 🟡 | Proto | Dữ liệu nằm trong `scripts/data/*.gd`; kịch bản đề xuất JSON/Resource. Chuyển khi có designer |
| KT-03 | Lưu game cục bộ, chuyển đổi save cũ | ✅ | M1 / M2 | Save v3 |
| KT-04 | Test tự động headless | ✅ | Proto → M3 | 52 test; chạy một phần bằng `-- --only=<tên>` |
| KT-05 | Quản lý mã nguồn bằng Git | ✅ | 20/10/2026 | Repo cục bộ nhánh `main` (chưa có remote); `.gitignore` bỏ `.godot/`, `node_modules/`, log công cụ |
| KT-06 | Build file chạy Windows (.exe) | ⬜ | M5 | Cần cài export templates 4.7.2 |
| KT-07 | Cài đặt: âm lượng, đổi phím, cỡ chữ | ⬜ | M5 | |
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

- [ ] Viết spec M4
- [ ] BD-07: bản đồ lục địa, di chuyển giữa vùng; TN-09 cảnh kết chương 1
- [ ] BD-02: Đồng Bằng Gió Hú, cơ chế gió đẩy lùi; CB-10: 4–6 loại quái
- [ ] BD-06: 3 map con mỗi vùng + dungeon boss (làm lại vùng 1 theo cấu trúc này: 40 ô, Lõi Sương mở sau boss — Q24, Q25)
- [ ] CB-18: boss Tướng Gián Điệp Huyền Ảnh
- [ ] CT-04, CT-07, CT-10: Thành Biên Đài, Liên minh, gián điệp Hư Vô Giáo
- [ ] KP-01, KP-11: lưới khai phá lớn hơn, tỉ lệ sự kiện theo kịch bản; TP-26 Khứu Giác Di tích 20%
- [ ] KP-06, TB-11: Mỏ, Bến Cá (buff lãnh địa, không tạo tài nguyên), tài nguyên Đá/Sắt/Tinh Thạch (Q26)
- [ ] TB-04, TB-05: bộ trang bị vùng 2, bộ cộng hưởng Thiên phú
- [ ] NV-17, NV-24, NV-25: kháng hệ, EXP offline 5%, phạt EXP quái thấp cấp
- [ ] BD-08, BD-09: dịch chuyển, thử thách vượt ải
- [ ] TP-23: Chân Không Biết Mỏi đổi lại đúng nghĩa "bản đồ lớn"; TP-39 Đạo Tặc học kỹ năng boss 2

### M5 — Cốt truyện, hướng dẫn, chuẩn bị thử nghiệm kín

- [ ] Viết spec M5
- [ ] TN-01, CT-01…03: cutscene mở đầu, thoại chương 1–2
- [ ] TN-04: hướng dẫn combat; TP-43: cây tiến hoá hiện trong bảng Thiên phú (Q20)
- [ ] NV-22: nhiệm vụ cốt truyện
- [ ] CB-15: boss hiếm
- [ ] KP-15, KP-16: Xưởng Rèn, Vườn Thảo Dược
- [ ] KP-09, TB-12: Thương nhân lữ hành, mua bán
- [ ] CB-02: Tự đánh; NV-26: tự cộng điểm
- [ ] NV-20: cân bằng nhịp độ 1 → 20 từ dữ liệu playtest (chỉ chỉnh hệ số công thức CB-21, không đổi công thức)
- [ ] KT-06, KT-07: build .exe, màn hình cài đặt

### G — Đồ hoạ và âm thanh

- [x] DH-01: chốt phong cách đồ hoạ (pixel art sinh bằng code)
- [x] G1: DH-02, 04, 05, 06, 07, 09 — hình chương 1, icon, nối vào game ([07](07-do-hoa-ke-hoach.md))
- [ ] DH-03: Thợ Săn vào game (cùng M3); AR-41: icon 3 kỹ năng mới mỗi lớp
- [ ] DH-08: vùng 2 (cùng M4, AR-40)
- [ ] DH-10 phần còn lại, DH-11 khung giao diện, DH-12/13 âm thanh (G2)

## 13. Quyết định đang chờ chủ dự án

| # | Câu hỏi | Ảnh hưởng | Mặc định đang dùng |
| --- | --- | --- | --- |
| 1 | Nền tảng ra mắt đầu tiên: PC hay Mobile? | Điều khiển, giao diện, KT-08 | PC (bàn phím + chuột) |
| 2 | ~~Phong cách đồ hoạ (DH-01)~~ | Toàn bộ nhánh G | **Đã chốt** 20/10/2026: pixel art sinh bằng code (thay được bằng hình hoạ sĩ vẽ sau, giữ kích thước frame) |
| 3 | Q1–Q5 (trang bị) — [03-mvp-spec mục 3.9](03-mvp-spec.md) | Rơi đồ, boss, túi đồ | Như spec |
| 4 | Q6–Q12 (Thiên phú) — [03-mvp-spec mục 4.10](03-mvp-spec.md) | Kỹ năng L, Tinh Kim, công trình | Như spec |
| 5 | Tốc độ hồi Đuốc khi phát hành (KP-02) | Nhịp độ khai phá | 2 phút/cái (kịch bản: 20 phút) |
| 6 | Khởi tạo Git cho dự án (KT-05) | An toàn mã nguồn | Chưa có |
| 7 | Q13–Q16: số liệu Đạo Tặc cướp thuộc tính, độc nhất server — [CR-01](03-mvp-spec.md) | Thiên phú SSS | Như CR-01 (đã code ở M3) |
| 10 | Q28–Q34: 8 kỹ năng, phím 1–4, INT/LUK, né tránh, MP, tinh anh vùng 1, không đổi lớp — [03 mục 5.11](03-mvp-spec.md) | Combat 2 lớp | Như spec M3 (đã code) |

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
