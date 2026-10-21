# Đợt M6 — Chương 3: Sa Mạc Lãng Quên (vùng 3 Sa Mạc Xích Sa)

| | |
| --- | --- |
| Dự án | Thiên Phú Khai Giới |
| Nguồn | [Kịch bản](kich-ban-game-thien-phu-khai-gioi.md) mục 2 (chương 3: *"Truy tìm di tích của Khai Giới Giả đời đầu — kết chương: chuyển chức lần 1, biết về Thiên Liệt"*), mục 4 (chuyển chức), mục 6 (vùng 3) · [06](06-ban-do-quai-boss.md) vùng 3 (quái, boss, môi trường, đồ Cam — số liệu đã chốt Q27) |
| Mục tiêu | Chương 3 chơi được trọn vẹn từ lúc mở vùng tới chuyển chức lần 1, như chương 2 ở M4 |
| Thứ tự | Sau M5 (phiên game-c6). Chia 3 đợt con M6.1 → M6.2 → M6.3 |
| Quy trình | Spec (file này) → code → test → cập nhật 02/03/04/06 và mục Kết quả cuối file |
| Trạng thái | ✅ **Xong 21/10/2026** (phiên game-bc) — trừ ô Ốc đảo trên lưới khai phá (C3-03, xem Kết quả) |

Ký hiệu: ✅ xong · 🟡 một phần · ⬜ chưa làm.

## 1. Mở vùng 3

| Mã | Yêu cầu | Tiêu chí nghiệm thu |
| --- | --- | --- |
| C3-01 | Điều kiện mở (06, kịch bản mục 6): **hạ Huyền Ảnh** (boss chương 2) + **Lực chiến ≥ 5.000** + cấp ≥ 18. Bảng Lục địa (N) hiện điều kiện còn thiếu | Test C3-T1 |
| C3-02 | 3 map, mỗi map ×1,6 như SN-30 (4.480 × 2.560), có sương che (SN-31): **3-1 Rìa Cát Đỏ** (cấp 20–24, trại an toàn *Trại Cát Đỏ* — 3 NPC), **3-2 Ốc Đảo Lãng Quên** (24–28, 3 ốc đảo), **3-3 Di Tích Khai Giới Giả** (28–32, trạm *Cổng Di Tích*, hang boss *Sào Huyệt Sa Hoàng* cấp 30, boss hiếm Nhân Sư Đá). Thứ tự đi: 3-1 → 3-2 → 3-3 | Test C3-T1; smoke `10-region3` |
| C3-03 | Lưới khai phá vùng 3: **45 ô** (3 map con × 15 ô, như vùng 2). Tài nguyên: Mỏ (Đá, Sắt), **Ốc đảo** (ô mới) → xây Vườn Thảo Dược ngay trên ô | Test C3-T5 |

## 2. Môi trường sa mạc (M6.1)

| Mã | Yêu cầu | Tiêu chí nghiệm thu |
| --- | --- | --- |
| C3-10 | **Ngày / đêm**: chu kỳ 6 phút (4 phút ngày, 2 phút đêm), chung cho cả vùng. HUD ghi *"Ngày · còn 2:31"* / *"Đêm"*. Đêm: quái **+15% Tấn công**, tầm nhìn 70% (màn tối viền) | Test C3-T2 |
| C3-11 | **Nắng gắt** (ban ngày): mất **1% HP mỗi 5 giây** khi không đứng trong **bóng râm** (trong 50 đơn vị quanh tảng đá lớn) hoặc **ốc đảo**. Không làm chết (giữ tối thiểu 1 HP). **Uống nước** (đứng trong ốc đảo 1 giây) → miễn nắng 60 giây. Bộ Sa Hành Giả 2 món → miễn nắng | Test C3-T2 |
| C3-12 | **Bão cát**: ngẫu nhiên mỗi 3–5 phút, kéo dài 30 giây, báo trước 5 giây. Tầm nhìn 40%, **đạn (của cả người chơi và quái) bay chậm 30%** | Test C3-T2 |
| C3-13 | **Ốc đảo**: vùng tròn (3-1: 1 · 3-2: 3 · 3-3: 1), vẽ hồ nước + cây cọ; quái không đuổi vào (như vùng an toàn) | Test C3-T2 |

## 3. Quái vùng 3 (M6.1)

Chỉ số lấy từ `Formulas.mob_stats` (như M3). Hệ, loại, kỹ năng như 06.

| Mã | Quái | Loại · hệ | Kỹ năng | Tiêu chí |
| --- | --- | --- | --- | --- |
| C3-20 | **Bọ Cát** | Bầy · Thổ | Sinh theo **bầy 5 con**; Cắn (vung 0,4 s, ×1,0) | Test C3-T3 |
| C3-21 | **Rắn Đồi Cát** | Nhanh · Thổ | **Chui cát** 1,5 giây (bất tử, vệt cát báo), trồi lên dưới chân người chơi, vòng 3 m ×1,4 | Test C3-T3 |
| C3-22 | **Xác Ướp Khai Giới** | Lì · Thổ | **Nguyền rủa** (vung 0,8 s): trúng → −20% hồi máu 6 giây (bình máu, Hấp Huyết, thảo dược) | Test C3-T3 |
| C3-23 | **Pháp Sư Cát** | Phép · Hỏa | Đánh xa 18 m; **Lốc cát** (vung 1,0 s, vòng 7 m tại chỗ người chơi, ×1,0, chậm 40% 3 giây) | Test C3-T3 |
| C3-24 | Tinh anh **Bọ Hung Giáp Vàng** (từ cấp 23) | Giáp · Kim | **Lăn cầu** (hồi 9 s): lăn thẳng 20 m ×1,8 (có vệt báo); khiên phía trước như Lính Đánh Thuê | Test C3-T3 |
| C3-25 | Tinh anh **Thủ Lĩnh Xác Ướp** (từ cấp 27) | Lì · Thổ | **Hồi sinh** (hồi 20 s): dựng lại tối đa 2 Xác Ướp vừa bị hạ trong 15 m | Test C3-T3 |

## 4. Boss (M6.2)

| Mã | Yêu cầu | Tiêu chí nghiệm thu |
| --- | --- | --- |
| C3-30 | **Bọ Cạp Sa Hoàng** (boss chương 3, cấp 30, Thổ, 110 đòn theo Q23). GĐ1: **Kìm kẹp** (vung 0,6 s, ×1,3, giữ người chơi 1 giây — không di chuyển, vẫn né lăn được), **Đuôi độc** (vòng 8 m tại chỗ người chơi, vung 0,9 s, ×1,5 + độc 2% HP/giây 5 giây). GĐ2 (dưới 50%): **Chui xuống cát** (bất tử 3 giây, vết cát báo 1,2 s, trồi lên vòng 7 m ×2,2), **bão cát** suốt giai đoạn | Test C3-T4; TL-B3 |
| C3-31 | Rơi: 1 đồ Tím · 15% **Đuôi Sa Hoàng** (vũ khí Cam: đòn đánh gây độc ×0,2 mỗi giây 4 giây, cộng dồn 3 lần) · 3 Tinh Hoa · 1 Tinh Kim. Hồi sinh 10 phút như boss khác | Test C3-T4 |
| C3-32 | **Đạo Tặc — Độn Thổ** (sao chép khi hạ Sa Hoàng lần đầu): chui đất 1,5 giây (bất tử), trồi lên tại điểm ngắm (≤ 15 m), vòng 7 m ×2,0 | Test C3-T4 |
| C3-33 | **Boss hiếm Nhân Sư Đá** ở 3-3 (cấp 32, Giáp, Thổ, 200 đòn): **Câu Đố Nhân Sư** — mỗi lần mất 25% HP, Nhân Sư bất tử, hiện **3 cột đá mang 3 hệ** (luôn có Mộc); đứng vào cột **Mộc** (khắc Thổ) trong 4 giây, đứng sai cột hoặc ngoài cột nhận ×3. **Ánh mắt hoá đá** (nón 45°, 14 m, vung 1,0 s): hoá đá 1,5 giây. Lịch xuất hiện như boss hiếm khác (bảng `RARE_BOSSES` của M5) | Test C3-T4 |
| C3-34 | Nhân Sư rơi: **Mắt Nhân Sư** (dây chuyền Cam: +10% chí mạng; chí mạng vào quái bị khắc hệ ×1,2) · 1 Tinh Hoa Tiến Hoá · 5 Tinh Hoa | Test C3-T4 |
| C3-35 | **Bộ Sa Hành Giả** (đồ Tím vùng 3): 2 món — miễn Nắng gắt · 4 — +10% Phòng thủ · 6 — Xoáy Kiếm / Mưa Tên / Băng Ngục để lại lốc cát 4 giây làm chậm quái 40% | Test C3-T4 |

## 5. Cốt truyện và chuyển chức 1 (M6.3)

| Mã | Yêu cầu | Tiêu chí nghiệm thu |
| --- | --- | --- |
| C3-40 | **NPC Trại Cát Đỏ**: *Sa Lão* (học giả già, người dẫn truyện chương 3), *A Mộc* (người dẫn đường bán nước — cửa hàng), *Thạch Thủ* (hộ vệ di tích, chuyển chức). Hộp thoại có chân dung như C1 | Smoke `10b-camp` |
| C3-41 | **Nhiệm vụ chương 3 — 6 bước**: (1) tới Trại Cát Đỏ gặp Sa Lão · (2) hạ 30 quái vùng 3 lấy mảnh bản đồ · (3) tới Ốc Đảo Lãng Quên, uống nước ở cả 3 ốc đảo · (4) vào Di Tích, mở Bia Khai Giới Giả (khám phá 3-3 ≥ 40%) · (5) hạ Bọ Cạp Sa Hoàng · (6) **chuyển chức** với Thạch Thủ. Thưởng EXP/vàng mỗi bước; HUD hiện bước như chương 2 | Test C3-T5 |
| C3-42 | **Thiên Liệt** (kết chương): đọc Bia Khai Giới Giả lộ ra chuyện 1.000 năm trước — Khai Giới Giả mạnh nhất cố đoạt Thiên phú của Thiên Đạo, trời nứt làm chín; gợi ý "mảnh thứ hai". Màn kết chương 3 có bản đồ lục địa, mở gợi ý vùng 4 (Alpha) | Smoke `11-chapter3-end` |
| C3-43 | **Chuyển chức 1** (kịch bản mục 4, cấp 30): điều kiện **cấp 30 + hạ Sa Hoàng**. Mỗi lớp 1 chức mới (nhánh thứ 2 để chuyển chức 2): **Kiếm Khách → Kiếm Sư**, **Thợ Săn → Xạ Thủ**, **Pháp Sư → Pháp Sư Nguyên Tố**. Mọi chức: +10% HP và Tấn công, tên chức hiện ở HUD/bảng Chỉ số, hào quang khi chuyển | Test C3-T6 |
| C3-44 | **Kỹ năng chuyển chức** (bị động, mỗi chức 2 hiệu ứng): *Kiếm Sư* — đòn chém thứ 4 phóng kiếm khí ×0,8 (bay 25 m, xuyên); Xoáy Kiếm +30% bán kính. *Xạ Thủ* — mỗi phát bắn thêm 1 mũi tên phụ ×0,5 vào quái gần thứ 2; Tên Xuyên Phá hồi 6 → 4 giây. *Pháp Sư Nguyên Tố* — Hỏa Cầu tự đổi sang hệ khắc mục tiêu (+30%); Lôi Xích nảy thêm 2 lần | Test C3-T6 |

## 6. Thay đổi save (version hiện tại + 1)

| Trường | Kiểu | Mặc định save cũ |
| --- | --- | --- |
| `job` | String (`""` \| `"kiem-su"` \| `"xa-thu"` \| `"phap-su-nguyen-to"`) | `""` |
| `quest.ch3`, `quest.kills3`, `quest.oases` | int, int, Array[int] | 0, 0, [] |
| `heat_free_until` | float (giây chơi) | 0 |

`fog`, `grids`, `unlocked_maps`, `bosses` dùng lại trường có sẵn.

## 7. Kiểm thử tự động

| Mã | Kiểm |
| --- | --- |
| C3-T1 | Điều kiện mở vùng 3; 3 map đúng cấp, đúng kích thước, đi được 3-1 → 3-3 |
| C3-T2 | Ngày/đêm 4/2 phút, đêm quái +15%; nắng −1%/5 giây ngoài bóng râm, không chết; uống nước miễn 60 giây; Sa Hành Giả 2 món miễn; bão cát làm đạn chậm 30% |
| C3-T3 | Bọ Cát sinh bầy 5; Rắn chui cát bất tử rồi trồi lên; Nguyền rủa giảm hồi máu 20%; Lốc cát làm chậm; Bọ Hung lăn cầu + khiên trước; Thủ Lĩnh hồi sinh 2 Xác Ướp |
| C3-T4 | Sa Hoàng 2 giai đoạn: kìm giữ 1 giây, đuôi độc, chui cát bất tử; rơi Đuôi Sa Hoàng (độc cộng dồn 3); Độn Thổ; Nhân Sư: cột Mộc an toàn, cột sai ×3, hoá đá; Mắt Nhân Sư; bộ Sa Hành Giả |
| C3-T5 | Nhiệm vụ chương 3 đủ 6 bước; lưới vùng 3 45 ô, ô Ốc đảo |
| C3-T6 | Chuyển chức: điều kiện, +10%, 3 kỹ năng chuyển chức; save giữ chức |
| TL-B3 | 3 lớp × 20 Thiên phú hạ Sa Hoàng (cấp 29, bộ đồ chuẩn cấp 29): F/S ≤ 25%, các lớp ≤ 25%, 0 lần chết |

## 8. Điểm cần duyệt

| # | Câu hỏi | Mặc định đã chọn |
| --- | --- | --- |
| Q51 | Chuyển chức 1 chỉ có 1 chức mỗi lớp (kịch bản ghi 1 tên trước dấu →), nhánh chọn ở chuyển chức 2? | Đúng — chuyển chức 2 mới chọn 1 trong 2 nhánh |
| Q52 | Nắng gắt có được làm người chơi gục không? | Không — giữ tối thiểu 1 HP (áp lực, không phạt chết) |
| Q53 | Điều kiện mở vùng 3 thêm cấp ≥ 18 (kịch bản chỉ ghi Lực chiến 5.000)? | Có — tránh người chơi mua đồ đủ Lực chiến khi cấp quá thấp |
| Q54 | Bóng râm lấy theo tảng đá lớn trên map (50 đơn vị quanh tảng đá)? | Có — hiển thị vùng tối dưới chân tảng đá |

## 9. Kết quả

| Mã | Trạng thái | Ghi chú |
| --- | --- | --- |
| C3-01, C3-02 | ✅ | `maps.gd` 3-1/3-2/3-3; `GameWorld.map_requirement`, `gate_open("3-3")` (mở khi tới bước 5 hoặc đã hạ Sa Hoàng) |
| C3-03 | 🟡 | Lưới vùng 3 cùng cỡ và bảng sự kiện vùng 2 (Mỏ, Bến Cá…). **Chưa có ô Ốc đảo riêng** — cần thêm loại sự kiện trong `explore.gd` |
| C3-10…13 | ✅ | `core/chapter3.gd` (`tick`, `heat_active`, `storm_on`, `rocks`, `oasis_at`); HUD dòng trạng thái (dùng chung dòng gió); view tối viền ban đêm, phủ cát + vệt gió khi bão; quái không đuổi vào ốc đảo |
| C3-20…25 | ✅ | `monsters.gd` + `Ch3.chase / perform / elite_skill / adjust_damage`; Bọ Cát sinh bầy ở `_spawn_field_mob` (`Ch3.after_spawn`); Rắn/Sa Hoàng chui cát = bất tử + ẩn, vẽ ụ cát |
| C3-30…35 | ✅ | Sa Hoàng: giai đoạn 2 dùng `Ch3.boss_phase_two` (không gọi bầy sói của Sói Chúa); Nhân Sư: `RARE_BOSSES["3-3"]` + `Ch3.update_sphinx`; Đuôi Sa Hoàng (độc cộng dồn), Mắt Nhân Sư, Bộ Sa Hành Giả (2 miễn nắng · 4 +10% Phòng thủ · 6 lốc cát cho Xoáy Kiếm/Mưa Tên/Băng Ngục) |
| C3-40…42 | ✅ | `story.gd` `QUESTS3` + 16 đoạn thoại; NPC Trại Cát Đỏ; Bia Khai Giới Giả ở 3-3 kể Thiên Liệt; thưởng EXP 300.000 = 25% EXP cấp 20 → 30 (cùng tỉ lệ M5-02) |
| C3-43, C3-44 | ✅ | `classes.gd` `JOBS`; `Ch3.do_job` (Thạch Thủ, phím E); tên chức hiện ở HUD, bảng Chỉ số, túi đồ. Pháp Sư Nguyên Tố: Hỏa Cầu luôn +30% (mọi hệ quái đều có hệ khắc nên "tự đổi sang hệ khắc" = luôn khắc) |
| Câu đố Di tích | ✅ | Thêm 4 câu hỏi vùng 3 vào `Puzzle.RIDDLES` |

**Cân bằng (TL-B, TL-B2, TL-B3)** — bot, bộ đồ chuẩn đúng cấp, 20 Thiên phú mỗi lớp; giây trung bình hạ boss:

| Lớp | Sói Chúa (cấp 5) | Huyền Ảnh (cấp 17) | Sa Hoàng (cấp 29) |
| --- | --- | --- | --- |
| Kiếm Khách | 30,7 | 47,9 | 37,6 |
| Thợ Săn | 33,0 | 48,2 | 28,6 |
| Pháp Sư | 30,7 | 49,3 | 32,3 |
| Lớp nhanh nhất / chậm nhất | chênh 7% | chênh 3% | chênh 24% |

F/S chênh tối đa: vùng 1 9% · vùng 2 23% (Thợ Săn) · vùng 3 14%. 0 lần chết.

**Phát hiện:**

- **F1 — Thợ Săn tăng sức mạnh quá nhanh theo cấp.** Cấp 29 (84 AGI): chí mạng gốc 47%, tốc đánh +50% → hạ Sa Hoàng trong 20 giây, Kiếm Khách 37,6 giây (chênh 47%). Sửa (D37): chí mạng/AGI của Thợ Săn 0,5% → 0,25%, tốc đánh từ AGI tối đa +20%. Vùng 1 gần như không đổi (12 AGI).
- **F2 — Bộc Phá trên Mưa Tên quá mạnh.** +100% cộng vào cả 5 đợt ×0,6 = thêm ×3,0, trong khi Xoáy Kiếm chỉ thêm ×1,8 → Thợ Săn + Ngũ Hành Linh Căn là tổ hợp nhanh nhất mọi vùng. Sửa: hệ số 0,6 cho Mưa Tên.
- **F3 — Thông báo ghi cứng tên chương 1.** "hồi sinh tại Làng Thanh Thạch", "Sói Chúa Hư Vô rút về hang", "Phá Thế! Sói Chúa choáng" hiện cả ở sa mạc. Sửa: dùng tên vùng an toàn và tên boss.
- **F4 — Lỗi định dạng chuỗi** "+15% Tấn công" trong dòng trạng thái ban đêm (lần thứ 4 của dự án) → `%%`.

**Kiểm thử:** 98 test (thêm C3-T1…T6, TL-B3); smoke thêm `10b-camp`, `10-region3`, `10c-night-storm`, `11-sa-hoang`.
