# Đợt M7 — Chương 4: Đầm Lầy Mộng (vùng 4 Đầm Lầy U Minh) + Tiến hoá Thiên phú lần 1

| | |
| --- | --- |
| Dự án | Thiên Phú Khai Giới |
| Nguồn | [Kịch bản](kich-ban-game-thien-phu-khai-gioi.md) mục 2 (chương 4: *"Bạn đồng hành bị đoạt Thiên phú — kết chương: cứu bạn, Thiên phú tiến hoá lần 1"*), mục 3 (tiến hoá), mục 6 (vùng 4 *"độc tích luỹ, ảo ảnh — mở: chuyển chức 1"*) · [05](05-thien-phu-chi-tiet.md) mục 1.3, 3 (tiến hoá, Q18, Q20) · [06](06-ban-do-quai-boss.md) vùng 4 |
| Mục tiêu | Chương 4 chơi trọn từ lúc mở vùng 4 tới tiến hoá Thiên phú lần 1 (điều kiện mở vùng 5 — M8 của phiên game-c6) |
| Thứ tự | Sau M6 + Spec_Notes đợt 4. Chia M7.1 (vùng, môi trường, quái) → M7.2 (boss, đồ) → M7.3 (cốt truyện, tiến hoá) |
| Kiến trúc | Logic trong file mới `core/chapter4.gd`; GameWorld gọi qua bộ điều phối `core/chapters.gd` (D38) để chương 5 (M8) gắn vào không phải sửa lại các chỗ móc |
| Quy trình | Spec (file này) → code → test → cập nhật 02/03/04/05/06 và mục Kết quả |
| Trạng thái | 🟡 Spec |

## 1. Mở vùng 4

| Mã | Yêu cầu | Tiêu chí |
| --- | --- | --- |
| C4-01 | Điều kiện mở (kịch bản mục 6): **chuyển chức 1** (đã làm M6) + **hạ Bọ Cạp Sa Hoàng**. Bảng Lục địa hiện điều kiện thiếu | C4-T1 |
| C4-02 | 3 map 4.480 × 2.560, sương che: **4-1 Bãi Lau Mù** (cấp 32–36, trại *Làng Chài Lau* — 3 NPC), **4-2 Đầm Sâu** (36–41, phần lớn là nước), **4-3 Cung Mộng** (41–45, trạm *Bờ Mộng*, hang *Cung Phệ Mộng* cấp 43, boss hiếm Thuỷ Quái Thất Đầu). Đi 4-1 → 4-2 → 4-3 | C4-T1 |
| C4-03 | Lưới khai phá vùng 4: 45 ô (dùng bảng sự kiện vùng 2–3) | C4-T5 |

## 2. Môi trường đầm lầy (M7.1)

| Mã | Yêu cầu | Tiêu chí |
| --- | --- | --- |
| C4-10 | **Nước đầm**: mỗi map có vùng nước (4-1: vài hồ; 4-2: nước khắp nơi trừ các cồn đất khô; 4-3: nửa map). Lội nước chậm 15% | C4-T2 |
| C4-11 | **Độc tích luỹ**: mỗi 10 giây trong nước +1 tầng độc (tối đa 10; mỗi tầng mất 0,3% HP/giây, không làm gục). Đứng trên đất khô 3 giây giảm 1 tầng. **Thuốc Giải** (cửa hàng Làng Chài Lau, 40 vàng; uống phím Q khi có ≥ 3 tầng độc — ưu tiên hơn bình máu) xoá hết. Bộ U Minh 2 món: tích độc chậm 50%. HUD ghi số tầng | C4-T2 |
| C4-12 | **Ảo ảnh**: 20% quái thường sinh ra là ảo ảnh (mờ hơn một chút) — trúng 1 đòn là tan, không cho EXP, không rơi đồ, không tính nhiệm vụ | C4-T2 |

## 3. Quái vùng 4 (M7.1)

| Mã | Quái | Loại · hệ | Kỹ năng | Tiêu chí |
| --- | --- | --- | --- | --- |
| C4-20 | **Ếch Độc** | Xa · Thủy | **Lưỡi độc** (vung 0,7 s, 12 m): kéo người chơi 4 m về phía ếch, +1 tầng độc | C4-T3 |
| C4-21 | **Đỉa Hút Máu** | Nhanh · Thủy | **Bám**: chạm vào thì dính trên người chơi, hút 1% HP/giây và tự hồi lượng đó; né lăn để gỡ | C4-T3 |
| C4-22 | **Hồn Ma Đầm** | Phép · Thủy | **Phân ảnh** (hồi 12 s): tạo 2 ảo ảnh 1 HP · **Tiếng than** (vòng 8 m, ×1,1) | C4-T3 |
| C4-23 | **Cá Sấu Bùn** | Giáp · Thổ | **Đớp** (vung 0,8 s, ×1,8) + choáng 1 giây | C4-T3 |
| C4-24 | Tinh anh **Phù Thuỷ Đầm Lầy** (của Hồn Ma, từ cấp 36) | Phép · Thủy | **Mưa độc** (hồi 12 s): vùng 10 m trong 5 giây, +2 tầng độc mỗi giây | C4-T3 |
| C4-25 | Tinh anh **Cá Sấu Chúa** (của Cá Sấu Bùn, từ cấp 40) | Giáp · Thổ | **Cuộn tử thần** (hồi 14 s, vung 0,8 s): trúng thì giữ người chơi 2 giây, ×0,6 mỗi 0,5 giây; né lăn trong lúc vung để tránh | C4-T3 |

## 4. Boss và đồ (M7.2)

| Mã | Yêu cầu | Tiêu chí |
| --- | --- | --- |
| C4-30 | **Nữ Vương Phệ Mộng** (boss chương 4, cấp 43, Thủy, 130 đòn — Q23 chương 4+). GĐ1 (100 → 60%): **Lời ru** (vòng 12 m, vung 1,0 s, ×1,0, chậm 50% 3 giây), **Gai mộng** (3 gai thẳng nón 30°, ×1,4). GĐ2 (60 → 25%): **Giấc mơ** — 12 giây **đảo ngược điều khiển** (trái ↔ phải, lên ↔ xuống), hiện 3 **Mộng Châu** quanh hang; phá đủ 3 thì tỉnh sớm; Nữ Vương bất tử khi người chơi đang mơ. GĐ3 (dưới 25%): **Phệ mộng** — hút 2% HP/giây nếu người chơi trong 15 m mà không đứng trong **vòng sáng** (bán kính 6 m, trôi chậm quanh hang) | C4-T4; TL-B4 |
| C4-31 | Rơi: 1 đồ Tím · 15% **Gối Mộng** (bùa Cam: 15% né hoàn toàn một đòn) · 3 Tinh Hoa · 1 Tinh Kim | C4-T4 |
| C4-32 | **Đạo Tặc — Mộng Cảnh**: quái trong 10 m đánh nhau 4 giây (không đánh người chơi; đánh quái gần nhất) | C4-T4 |
| C4-33 | **Boss hiếm Thuỷ Quái Thất Đầu** ở 4-3 (cấp 45, Lì, Thủy, 200 đòn): thân bất tử, **7 đầu** quanh thân (mỗi đầu 1/7 HP boss, có thanh máu riêng). Đầu bị chặt **mọc lại sau 20 giây** trừ khi trúng đòn **hệ Hỏa** trong 5 giây sau khi chặt (Hỏa Cầu / Thiên Thạch của Pháp Sư, Ngũ Hành hệ Hỏa, hoặc **Đuốc Lửa** — vật phẩm cửa hàng 60 vàng, ném bằng phím Q khi có đầu vừa bị chặt). Chặt hết 7 đầu cùng lúc → Thuỷ Quái gục. Mỗi đầu: **Phun nước** (thẳng 15 m, ×1,2) | C4-T4 |
| C4-34 | Thất Đầu rơi: **Vảy Thất Đầu** (áo Cam: hồi 1% HP/giây, +20% kháng Thủy) · 1 Tinh Hoa Tiến Hoá · 5 Tinh Hoa | C4-T4 |
| C4-35 | **Bộ U Minh** (đồ Tím vùng 4): 2 — độc tích luỹ chậm 50% · 4 — +12% HP · 6 — đòn đánh 15% gây 1 tầng độc lên quái (quái mất 0,3% HP tối đa/giây mỗi tầng, tối đa 10) | C4-T4 |

## 5. Cốt truyện và tiến hoá (M7.3)

| Mã | Yêu cầu | Tiêu chí |
| --- | --- | --- |
| C4-40 | **Bạn đồng hành Lam Nhi** (cô gái làng chài, Thiên phú hạng B *Tiếng Gọi Thủy Triều*) gặp ở Làng Chài Lau. NPC: *Lão Ngư* (trưởng làng, cửa hàng Thuốc Giải/Đuốc Lửa), *Lam Nhi*, *Tinh Quang Sứ* (sứ giả Thánh Đường Tinh Quang — tiến hoá) | Smoke `12b-village4` |
| C4-41 | **Nhiệm vụ chương 4 — 6 bước**: (1) tới Làng Chài Lau gặp Lão Ngư · (2) cùng Lam Nhi hạ 30 quái vùng 4 · (3) **Lam Nhi bị Nữ Vương bắt đi, Thiên phú bị đoạt** (thoại) — vào Đầm Sâu tìm dấu vết: phá 5 **Bọc Mộng** rải trong 4-2 · (4) tới Cung Mộng, khám phá ≥ 40% · (5) hạ Nữ Vương Phệ Mộng → Lam Nhi tỉnh lại, Thiên phú trả về · (6) **tiến hoá Thiên phú** với Tinh Quang Sứ. Thưởng EXP ≈ 25% EXP cấp 30 → 45 | C4-T5 |
| C4-42 | **Kết chương 4**: Lam Nhi kể Nữ Vương phục vụ "người không có Thiên phú" — Ma Tôn Vô Diện cướp Thiên phú người khác; gợi ý mảnh thứ hai. Màn kết chương | Smoke |
| C4-43 | **Tiến hoá Thiên phú lần 1** (TP-12, Q18, Q20): điều kiện **Thiên phú Lv10 + 1 Tinh Hoa Tiến Hoá + nhiệm vụ chương 4 bước 6** (M7 dùng chung cho mọi hạng; chuỗi "Phế Vật Nghịch Thiên" riêng cho F để sau). Tiến hoá: đổi tên + hạng theo bảng 05 mục 3 (bậc 1), Thiên phú về **Lv1**, **hoàn 50% Tinh Hoa đã luyện** (12). Đạo Tặc không tiến hoá — coi như đạt điều kiện | C4-T6 |
| C4-44 | **Không tụt sức mạnh** (Q18): hiệu lực Thiên phú tính theo **cấp hiệu dụng = Lv + 9 × số lần tiến hoá** — tiến hoá xong Lv1 = Lv10 cũ; luyện tiếp tới Lv10 thì hiệu ứng chính ×1,5 nữa (so với Lv10 cũ), thưởng chung +2%/cấp hiệu dụng. Hiệu ứng phụ Lv5/Lv10 giữ nguyên. Hiệu ứng **riêng** của dạng tiến hoá (ví dụ *Kim Cang Thân*, *Vạn Kiếm Quy Tông*) để Alpha | C4-T6 |
| C4-45 | Giao diện: HUD, bảng Thiên phú, Lễ… hiện **tên + hạng dạng tiến hoá**; bảng Thiên phú có nút **Tiến hoá** (hiện điều kiện còn thiếu) | Smoke `12-talent-evo` |

## 6. Thay đổi save (version 9 → 10)

| Trường | Kiểu | Mặc định save cũ |
| --- | --- | --- |
| `evo` | int (số lần tiến hoá) | 0 |
| `quest.ch4`, `quest.kills4`, `quest.orbs4` | int, int, Array[int] | 0, 0, [] |
| `antidotes`, `fire_torches` | int | 0, 0 |

Chương 5 (M8, phiên game-c6) dùng **v11**.

## 7. Kiểm thử

| Mã | Kiểm |
| --- | --- |
| C4-T1 | Điều kiện mở vùng 4; 3 map đúng cấp/kích thước |
| C4-T2 | Lội nước chậm 15%; +1 tầng độc mỗi 10 giây, đất khô 3 giây −1 tầng, không gục; Thuốc Giải; Bộ U Minh 2 món chậm 50%; ảo ảnh tan sau 1 đòn, không EXP |
| C4-T3 | Lưỡi độc kéo + độc; Đỉa bám hút máu, né lăn gỡ; Phân ảnh; Đớp choáng; Mưa độc; Cuộn tử thần |
| C4-T4 | Nữ Vương 3 giai đoạn (giấc mơ đảo điều khiển, Mộng Châu, vòng sáng); Gối Mộng; Mộng Cảnh; Thất Đầu (đầu mọc lại / đốt bằng hệ Hỏa, chặt 7 đầu thì gục); Vảy Thất Đầu; Bộ U Minh |
| C4-T5 | Nhiệm vụ chương 4 đủ 6 bước; thưởng EXP ≈ 25% |
| C4-T6 | Tiến hoá: điều kiện, tên/hạng mới, Lv1, hoàn 12 Tinh Hoa, không tụt sức mạnh (chỉ số và hiệu ứng ≥ trước), Đạo Tặc; save v10 |
| TL-B4 | 3 lớp × 20 Thiên phú hạ Nữ Vương (cấp 42, bộ đồ chuẩn cấp 42, đã chuyển chức): F/S ≤ 25%, các lớp ≤ 25% |

## 8. Điểm cần duyệt

| # | Câu hỏi | Mặc định đã chọn |
| --- | --- | --- |
| Q55 | Hiệu ứng riêng của từng dạng tiến hoá (19 dạng) làm luôn hay để Alpha? | Để Alpha; M7 làm khung tiến hoá + "cấp hiệu dụng" (không tụt sức mạnh, tên/hạng mới) |
| Q56 | Thất Đầu cần hệ Hỏa để đốt đầu — lớp không có hệ Hỏa làm sao? | Bán **Đuốc Lửa** ở Làng Chài Lau; Pháp Sư đốt bằng Hỏa Cầu/Thiên Thạch |
| Q57 | Giấc mơ đảo điều khiển 12 giây có quá khó chịu? | Giữ 12 giây nhưng phá 3 Mộng Châu thì tỉnh ngay; HUD báo "ĐANG MƠ — điều khiển đảo ngược" |
| Q58 | Lam Nhi có đi cùng chiến đấu? | Không (chỉ cốt truyện) — đồng đội AI để Alpha |

## 9. Kết quả

*(điền sau khi làm xong)*
