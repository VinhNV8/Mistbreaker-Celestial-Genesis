# Đợt M9 — Chương 6: Băng Nguyên Vĩnh Dạ (vùng 6 Băng Nguyên Bắc Cực)

| | |
| --- | --- |
| Dự án | Thiên Phú Khai Giới |
| Nguồn | [Kịch bản](kich-ban-game-thien-phu-khai-gioi.md) mục 2 (chương 6: *"Mảnh Thiên phú thứ hai thức giấc, nhân vật mất kiểm soát — kết chương: biết sự thật về thân phận"*), mục 5 (boss Bản Ngã Bóng Tối: *"sao chép Thiên phú và kỹ năng của chính người chơi"*), mục 6 (vùng 6: *"đóng băng, đêm dài tầm nhìn thấp — mở: chuyển chức 2"*) · [06](06-ban-do-quai-boss.md) vùng 6 (quái, boss, môi trường, đồ Cam) · [12](12-chuong-5.md) (chuyển chức 2, save v11, bài học D41) |
| Mục tiêu | Chương 6 chơi trọn từ lúc mở vùng 6 tới màn "sự thật về thân phận" |
| Thứ tự | Sau M8 (phiên game-c6). Chia M9.1 (vùng, môi trường, quái) → M9.2 (boss, đồ) → M9.3 (cốt truyện, Ám Khí / mất kiểm soát) |
| Kiến trúc | Logic trong `core/chapter6.gd`, gắn qua `core/chapters.gd` (`MODULES += [Ch6]`). Hook mới (D42): `input_filter(w, input) -> Dictionary` (mất kiểm soát) — chèn 1 dòng trong `GameWorld.update` sau `_travel_input`. Vẽ ở `view/region6_view.gd`, hình ở `tools/art/region6.py` |
| Quy trình | Spec (file này) → code → test → cập nhật 02/03/04/06/07 và mục Kết quả |
| Trạng thái | ✅ **Xong 21/10/2026** (phiên game-bc) — xem mục 9 (một số số liệu đổi sau khi cân bằng) |

Ký hiệu: ✅ xong · 🟡 một phần · ⬜ chưa làm.

## 1. Mở vùng 6

| Mã | Yêu cầu | Tiêu chí |
| --- | --- | --- |
| C6-01 | Điều kiện mở (kịch bản mục 6): **đã chuyển chức 2** (`profile.job2 != ""`) + **hạ Viêm Long** + **cấp ≥ 59**. Bảng Lục địa hiện điều kiện còn thiếu | C6-T1 |
| C6-02 | 3 map 4.480 × 2.560, sương che (SN-31): **6-1 Đồng Tuyết** (cấp 60–64, trại *Trạm Tuyết Bạc* — 3 NPC), **6-2 Rừng Băng** (64–68, trạm *Lều Thợ Săn*, 3 **Đèn Cực Quang**), **6-3 Đỉnh Cực Quang** (68–72, trạm *Đài Cực Quang*, hang *Gương Băng Vĩnh Dạ* cấp 70, boss hiếm Long Băng Bắc Cực). Đi 6-1 → 6-2 → 6-3 | C6-T1; smoke `15-region6` |
| C6-03 | Lưới khai phá vùng 6: 45 ô (bảng sự kiện vùng 2–5). Ô Mỏ của vùng 6 cũng là **Mỏ Tinh Thạch** (06: *"Tài nguyên: Mỏ Tinh Thạch, rừng thông → Xưởng Gỗ"*) | C6-T5 |

## 2. Môi trường băng nguyên (M9.1)

| Mã | Yêu cầu | Tiêu chí |
| --- | --- | --- |
| C6-10 | **Băng giá** (06): tầng 0–5. Đứng yên (không di chuyển, không né) **mỗi 2 giây +1 tầng**; di chuyển **mỗi 1,5 giây −1 tầng**; đứng trong **8 m quanh lửa** (lửa trại, Đèn Cực Quang đã thắp, chậu lửa trong hang boss) **mỗi 0,5 giây −1 tầng** và không tăng. Mỗi tầng **−10% tốc chạy**. Đủ **5 tầng → đông cứng 1,5 giây** (không đi, không đánh, không né — như choáng), rồi về 0 tầng và **miễn tăng tầng 3 giây**. Một số đòn quái cộng tầng (mục 3) | C6-T2 |
| C6-11 | **Đêm dài** (06): chu kỳ 8 phút theo giờ chơi, **6 phút đêm**: tầm nhìn 60% (lớp tối quanh người chơi như đêm sa mạc M6); ban đêm quái ngoài tầm nhìn **không hiện tên/thanh máu** | C6-T2; smoke `15b-night6` |
| C6-12 | **Mặt băng trơn** (06): thả phím di chuyển thì nhân vật **trượt tiếp 0,3 giây** theo hướng cũ (tốc giảm dần về 0). Né lăn, Đột Kích, bị trói/choáng thì không trượt | C6-T2 |
| C6-13 | **Than Hồng** (vật phẩm mới, cửa hàng Lão Hàn 100 vàng): phím Q khi có ≥ 2 tầng băng giá → **xoá hết tầng + miễn băng giá 30 giây** (dùng thay bình máu, như Thuốc Giải M7). HUD dòng môi trường: *"Băng giá 3/5 · đứng yên sẽ đông cứng"* / *"Đêm · tầm nhìn 60% · còn 4:12"* / *"Q: Than Hồng (2)"* | C6-T2 |

## 3. Quái vùng 6 (M9.1)

Chỉ số từ `Formulas.mob_stats` (06 vùng 6).

| Mã | Quái | Loại · hệ | Kỹ năng | Tiêu chí |
| --- | --- | --- | --- | --- |
| C6-20 | **Sói Băng** | Bầy · Thủy | Đi **bầy 4 con**. **Cắn** ×1,0 **+1 tầng băng giá** | C6-T3 |
| C6-21 | **Người Tuyết** | Lì · Thủy | **Ném cầu tuyết** (vung 0,9 s, ném tới chỗ người chơi lúc bắt đầu vung, tầm 14 m): vòng 3 m ×1,3 (vòng báo) | C6-T3 |
| C6-22 | **Tinh Linh Băng** | Phép · Thủy | Đánh xa 18 m bằng **Băng trụ** (vung 1,0 s, vòng 4 m tại chỗ người chơi, ×1,1, **đóng băng 1 giây**) | C6-T3 |
| C6-23 | **Cung Thủ Băng** | Xa · Kim | Tầm 24 m. **Mũi tên xuyên** ×1,0 (đạn bay nhanh, xuyên qua ảo ảnh/đồng minh) | C6-T3 |
| C6-24 | Tinh anh **Gấu Băng Khổng Lồ** (của Người Tuyết, từ cấp 63) | Lì · Thủy | **Đập băng** (hồi 10 s, vung 1,0 s): nứt nền **3 đường thẳng 15 m** (giữa hướng người chơi, hai bên lệch ±25°), rộng 1,2 m, mỗi đường ×1,8 (vệt báo) | C6-T3 |
| C6-25 | Tinh anh **Pháp Sư Bão Tuyết** (của Tinh Linh Băng, từ cấp 66) | Phép · Kim | **Bão tuyết** (hồi 15 s): vùng **14 m** quanh chỗ người chơi trong **6 giây**, trong vùng **+1 tầng băng giá mỗi giây** (bất kể đi hay đứng) | C6-T3 |

## 4. Boss và đồ (M9.2)

| Mã | Yêu cầu | Tiêu chí |
| --- | --- | --- |
| C6-30 | **Bản Ngã Bóng Tối** (boss chương 6, cấp 70, hang *Gương Băng Vĩnh Dạ*). Hình: **cái bóng của chính nhân vật** (dáng lớp người chơi, tô đen tím, **không có mặt**). Hệ **theo người chơi**: Ngũ Hành không khắc được nó. 4 **chậu lửa** quanh hang (sưởi băng giá C6-10). **GĐ1 (100 → 50%)** — **Sao chép kỹ năng** (kịch bản): mỗi kỹ năng người chơi dùng được ghi lại; **3 giây sau** Bản Ngã dùng lại bản bóng tối của nó (vung 0,6 s, có vòng/vệt báo) — bảng C6-30a. Đòn thường: Chém bóng ×1,0 | C6-T4; TL-B6 |
| C6-30b | **GĐ2 (50 → 20%) — Gương vỡ** (06): hang hiện **4 tấm Gương Băng** (vị trí cố định trên vòng 0,6 bán kính hang); Bản Ngã **ẩn trong 1 tấm** — chỉ tấm thật **có bóng** dưới chân. Cả 4 tấm đứng yên và cứ 2,5 giây bắn **Tia bóng** về phía người chơi (tấm giả ×0,5, tấm thật ×1,0). Đánh nhầm tấm giả: **phản 50% sát thương** về người chơi (tối đa **4% HP**, các tấm giả **chung hồi 1 giây**, bỏ qua Phòng thủ, không gục dưới 1 HP), tấm giả không mất máu. Cả 4 tấm **không bị tự ngắm** (soft-lock, Lôi Xích, đồng minh không chọn) — người chơi nhìn bóng mà ngắm. Theo D41, **đổi chỗ theo lượng sát thương**: cứ mỗi khi tấm thật mất **10% HP tối đa** thì 4 tấm vỡ và xếp lại (tấm thật sang vị trí khác). Chuyển cảnh bất tử cố định: vỡ gương **3 giây**, mỗi lần xoay **2 giây**, vào GĐ3 **2,5 giây** | C6-T4 |
| C6-30c | **GĐ3 (dưới 20%) — Thiên phú phản chiếu** (06): Bản Ngã dùng Thiên phú của người chơi ở **dạng tiến hoá cao nhất** (tên dạng cuối trong cây tiến hoá, hiện ở HUD), hiệu ứng theo **nhóm Thiên phú**: chiến đấu → +30% Tấn công, +20% tốc đánh · phép thuật / khống chế → cứ 8 giây làm **chậm người chơi 40%** trong 2 giây · triệu hồi → cứ 12 giây gọi **2 Ảnh Bóng** (quái nhỏ, 8% HP boss) · khai phá / kinh tế / chế tạo / lãnh địa / đặc biệt → +20% Tấn công, +25% tốc chạy. Sao chép kỹ năng tiếp tục, trễ **2 giây** | C6-T4 |
| C6-31 | Bản Ngã rơi: 1 đồ Tím · 15% **Gương Bản Ngã** (bùa Cam: khi bị đánh trúng, **10%** phản **50% sát thương nhận** lên quái gần nhất trong 6 m) · 3 Tinh Hoa · 1 Tinh Kim · **10 Tinh Thạch**. Hồi sinh 10 phút | C6-T4 |
| C6-32 | **Đạo Tặc — Kính Ảnh** (06; sao chép khi hạ Bản Ngã lần đầu): tạo **1 bản sao** của bản thân 8 giây, đánh quái gần nhất với **50% Tấn công** người chơi | C6-T4 |
| C6-33 | **Boss hiếm Long Băng Bắc Cực** ở 6-3 (cấp 72, Lì, Thủy; bảng `RARE_BOSSES`; xuất hiện sau khi hạ Bản Ngã). **Hơi thở vĩnh đông** (hồi 9 s, vung 0,8 s): nón 90°, 20 m — trúng ×0,8, để lại **mặt băng đóng** 3 giây (5 mảng trong nón); đứng trên mặt băng **+2 tầng băng giá mỗi giây**. **Mưa băng** (hồi 7 s): **15 vòng 3 m** ngẫu nhiên trong 16 m quanh người chơi, vòng báo 1,2 s, ×1,2. Cắn ×1,2 | C6-T4 |
| C6-34 | Long Băng rơi: **Vảy Long Băng** (giày Cam: **miễn băng giá**, +15% tốc chạy) · 1 Tinh Hoa Tiến Hoá · 5 Tinh Hoa | C6-T4 |
| C6-35 | **Bộ Cực Quang** (đồ Tím vùng 6, 06): 2 — **băng giá dưới 3 tầng không làm chậm** · 4 — +10% chí mạng · 6 — **đòn chí mạng làm chậm quái 40%** trong 2 giây (dùng trạng thái chậm có sẵn của quái) | C6-T4 |

**C6-30a — bản bóng tối của từng kỹ năng** (sát thương theo Tấn công của Bản Ngã):

| Kỹ năng người chơi | Bản Ngã dùng lại |
| --- | --- |
| Xoáy Kiếm, Băng Ngục | **Xoáy bóng**: vòng 5,5 m quanh Bản Ngã ×1,3 |
| Đột Kích | **Lao bóng**: lao thẳng tới chỗ người chơi lúc bắt đầu vung (tối đa 25 m), trúng trên đường ×1,5 |
| Kiếm Khí, Tên Xuyên Phá, Hỏa Cầu, Lôi Xích | **Tia bóng**: 1 đạn bay thẳng ×1,2 |
| Mưa Tên | **Mưa bóng**: 3 vòng 2,75 m quanh chỗ người chơi, báo 1,0 s, ×1,0 |
| Thiên Thạch | **Thiên thạch bóng**: 1 vòng 4,5 m tại chỗ người chơi, báo 1,2 s, ×1,8 |
| Bẫy Gai | **Bẫy bóng**: vòng 2 m tại chỗ người chơi, báo 1,5 s, ×1,0 + trói 1 giây |
| Thiết Bích, Pháp Thuẫn | **Thuẫn bóng**: Bản Ngã nhận −30% sát thương trong 3 giây |
| Ưng Nhãn | **Mắt bóng**: Bản Ngã +30% tốc đánh 5 giây và **cướp Ưng Nhãn** (người chơi mất phần còn lại) |

## 5. Cốt truyện, Ám Khí và mất kiểm soát (M9.3)

| Mã | Yêu cầu | Tiêu chí |
| --- | --- | --- |
| C6-40 | **NPC Trạm Tuyết Bạc**: *Tuyết Nga* (nữ tư tế Thánh Đường Tinh Quang giữ Bia Băng, người dẫn truyện) · *Lão Hàn* (thợ săn băng già — **cửa hàng** Than Hồng, bình máu) · *Lam Nhi* (bạn đồng hành chương 4, theo nhân vật lên phương bắc) | Smoke `15c-camp6` |
| C6-41 | **Nhiệm vụ chương 6 — 7 bước**: (1) tới Trạm Tuyết Bạc gặp Tuyết Nga · (2) **Đàn sói đói**: hạ 30 quái vùng 6 · (3) **Thắp Đèn Cực Quang**: tới Rừng Băng, đứng cạnh **3 Đèn Cực Quang** 2 giây để thắp (đèn đã thắp sưởi băng giá như lửa trại) · (4) **Mảnh thứ hai thức giấc**: tới Đỉnh Cực Quang (thoại thức giấc) rồi **trải qua 3 lần mất kiểm soát** (C6-42) · (5) khám phá 6-3 ≥ 40% (tìm cửa Gương Băng Vĩnh Dạ) · (6) hạ **Bản Ngã Bóng Tối** · (7) **Sự thật**: về Trạm Tuyết Bạc nói với Tuyết Nga (C6-44). Thưởng EXP ≈ 25% EXP cấp 60 → 72 (13,3 triệu × 25% ≈ 3,34 triệu), chia tăng dần theo bước | C6-T5 |
| C6-42 | **Ám Khí — mất kiểm soát** (kịch bản: *"nhân vật mất kiểm soát"*): từ bước 4, ở vùng 6 (trừ trong hang boss) thanh **Ám Khí** 0–100 tăng **+2/giây khi đang giao chiến** và **+5 mỗi quái hạ**; đứng gần lửa **−10/giây**. Đầy 100 → báo 2 giây *"Mảnh thứ hai thức giấc!"* → **mất kiểm soát 4 giây**: bỏ qua mọi phím, nhân vật **tự lao vào quái gần nhất và đánh thường** với **+40% Tấn công**; không dùng kỹ năng, không né. Hết → Ám Khí về 0. HUD hiện thanh Ám Khí (dòng môi trường) và viền tím khi mất kiểm soát | C6-T6 |
| C6-43 | **Sau chương** (đã biết sự thật): Ám Khí đầy không còn mất kiểm soát mà thành **Ám Hoá 6 giây**: +20% Tấn công, vẫn điều khiển bình thường (mồi Thiên phú thứ hai ở endgame) | C6-T6 |
| C6-44 | **Kết chương 6 — sự thật về thân phận**: hạ Bản Ngã → bóng tan vào ngực nhân vật; Tuyết Nga kể: 1.000 năm trước Ma Tôn Vô Diện mất **một mảnh linh hồn** khi gây Thiên Liệt, Thánh Đường phong nó trong Bia Đá; 16 năm trước Bia Đá Thanh Thạch nứt, mảnh linh hồn nhập vào một đứa trẻ sơ sinh — **chính nhân vật**. Ma Tôn săn nhân vật để thành toàn vẹn; muốn phong ấn lại phải tìm **Bia Đá gốc** ở **Quần Đảo Thiên Không** (mồi chương 7). Màn kết chương | Smoke `16-chapter6-end` |

## 6. Thay đổi save (version 11 → 12)

| Trường | Kiểu | Mặc định save cũ |
| --- | --- | --- |
| `quest.ch6`, `quest.kills6`, `quest.beacons6`, `quest.dark6` | int, int, Array[int] (đèn đã thắp), int (số lần mất kiểm soát đã trải qua) | 0, 0, [], 0 |
| `embers` (Than Hồng) | int | 0 |

Tầng băng giá, Ám Khí, giấc mất kiểm soát là trạng thái trong trận (không lưu).

## 7. Kiểm thử

| Mã | Kiểm |
| --- | --- |
| C6-T1 | Điều kiện mở vùng 6 (thiếu chức 2 / thiếu Viêm Long / thiếu cấp → khoá); 3 map đúng cấp/kích thước, đi 6-1 → 6-3 |
| C6-T2 | Băng giá: đứng yên 2 giây +1 tầng, đi −1, lửa xoá, 5 tầng đông cứng 1,5 giây + miễn 3 giây, −10% tốc chạy mỗi tầng; đêm 6/8 phút, tầm nhìn 60%; trượt 0,3 giây sau khi thả phím; Than Hồng |
| C6-T3 | Sói Băng bầy 4 + cắn +1 tầng; cầu tuyết; Băng trụ đóng băng 1 giây; Cung Thủ bắn xa; Đập băng 3 đường; Bão tuyết +1 tầng/giây |
| C6-T4 | Bản Ngã: ghi kỹ năng và dùng lại sau 3 giây (đủ bảng C6-30a), GĐ2 4 gương — tấm giả phản 50% (tối đa 4% HP, 1 lần/giây), tấm thật có bóng, đổi chỗ sau mỗi 10% HP, chuyển cảnh bất tử; GĐ3 theo nhóm Thiên phú; Ngũ Hành không khắc; Gương Bản Ngã; Kính Ảnh; Long Băng (hơi thở → mặt băng +2 tầng/giây, mưa băng 15 vòng); Vảy Long Băng; Bộ Cực Quang 2/4/6 |
| C6-T5 | Nhiệm vụ chương 6 đủ 7 bước; thưởng EXP ≈ 25%; Đèn Cực Quang; lưới vùng 6 45 ô, Mỏ Tinh Thạch |
| C6-T6 | Ám Khí: tăng khi giao chiến/hạ quái, giảm gần lửa, không tăng trong hang boss; mất kiểm soát 4 giây (bỏ qua phím, tự đánh, +40%); bước 4 xong sau 3 lần; sau chương thành Ám Hoá; save v12 + chuyển đổi v11 |
| TL-B6 | 3 lớp × 20 Thiên phú (đã chuyển chức 2, 2 nhánh luân phiên theo seed) hạ Bản Ngã (cấp 69, bộ đồ chuẩn cấp 69, tiến hoá 1 lần, Thiên phú Lv10): F/S ≤ 25%, các lớp ≤ 25%, 0 lần chết |

## 8. Điểm cần duyệt

| # | Câu hỏi | Mặc định đã chọn |
| --- | --- | --- |
| Q71 | Bản Ngã "dùng 80% chỉ số của người chơi" (06) — chép cả Tấn công người chơi? | **Không** — Bản Ngã dùng chỉ số boss cấp 70 theo công thức 06 (để TL-B6 cân được giữa các lớp), chỉ **chép hành vi** (kỹ năng, Thiên phú). Sát thương bản bóng tối theo bảng C6-30a |
| Q72 | Gương vỡ: đánh nhầm phản 50% — kỹ năng nhiều phát / diện rộng (tên, Mưa Tên, Lôi Xích) chắc chắn trúng gương giả? | Các gương cách nhau ≥ 23 m; phản tối đa **4% HP**, các gương chung hồi 1 giây; cả 4 tấm không bị tự ngắm (xem mục 9, F1) |
| Q73 | "Nhân vật mất kiểm soát" làm thành cơ chế chơi hay chỉ cắt cảnh? | **Cơ chế** Ám Khí (C6-42): 4 giây tự đánh +40%, chỉ ở vùng 6 từ bước 4, không xảy ra trong hang boss; sau chương thành buff có lợi (C6-43) |
| Q74 | Gương Bản Ngã "phản 50% sát thương nhận" — phản về ai? | Quái **gần nhất trong 6 m** (game chưa ghi nguồn của từng đòn) |
| Q75 | Điều kiện sang vùng 7 (lãnh địa cấp 5 + Cảng Khí Cầu, 06) làm ở M9? | **Không** — thuộc chương 7 (cần hệ cấp lãnh địa KP-xx); bảng Lục địa vùng 7 vẫn ghi "Beta" |

## 9. Kết quả

| Mã | Trạng thái | Ghi chú |
| --- | --- | --- |
| C6-01…03 | ✅ | `maps.gd` 6-1/6-2/6-3 (`frost`, `night`, `fires`, `beacons`); `Ch6.map_requirement` (Viêm Long + `job2` + cấp 59); Mỏ vùng 6 cho Tinh Thạch (`Explore.production_per_minute` đếm `mine_r6_*`) |
| C6-10…13 | ✅ | `Ch6.tick`: băng giá theo quãng đường đi mỗi khung hình (đứng yên / đi / gần lửa), đông cứng = `stun_timer`; đêm theo `play_seconds`; mặt băng trơn qua hook `input_move`; Than Hồng qua hook `drink`, mua ở Lão Hàn (`shop_buy("ember")`) |
| C6-20…25 | ✅ | Sói Băng (bầy 4, `frostbite`), Người Tuyết (`snowball`), Tinh Linh Băng (`icepillar`), Cung Thủ Băng (`icearrow`), Gấu Băng (`icecrack`), Pháp Sư Bão Tuyết (`blizzard`) |
| C6-30…35 | ✅ | Bản Ngã: dò hồi chiêu `skill_cds` để biết kỹ năng vừa dùng (D42) → `MIRROR_OF`; Gương vỡ (3 Gương Băng giả `role = bossMinion`, xếp lại theo 10% HP); Thiên phú phản chiếu theo nhóm (`talent_group`, `top_form`); hình = `SpriteLib.draw_hero` tô đen (`region6_view.draw_enemy`). Long Băng (`RARE_BOSSES["6-3"]`), Gương Bản Ngã (`player_hurt`), Vảy Long Băng, Bộ Cực Quang, Kính Ảnh (Đạo Tặc) |
| C6-40…44 | ✅ | `story.gd` `QUESTS6` + 22 đoạn thoại; thưởng EXP 3.340.000 ≈ 25% EXP cấp 60 → 72; Đèn Cực Quang (đứng 2 giây); Ám Khí + mất kiểm soát qua hook mới `input_filter` (D42); Ám Hoá sau chương; màn chiến thắng `Screens.VICTORY["ban-nga"]` |
| Sửa lỗi chung | ✅ | Đạo Tặc dùng Long Tức (chương 5) bị rơi vào Vồ Mồi: nhánh `dao-tac` trong `_use_talent` giờ gọi `Chapters.copy_skill` cho mọi kỹ năng chương 3+ |

**Đổi so với spec (sau khi code + cân bằng):**

| Mục | Spec | Đã làm | Lý do |
| --- | --- | --- | --- |
| C6-30b phản sát thương | 50%, tối đa 6% HP mỗi đòn | 50%, tối đa **4% HP**, các gương giả **chung hồi 1 giây** | Thợ Săn (tên nhiều phát), Pháp Sư (Lôi Xích nhảy) chết 40–90 lần mỗi trận: mỗi phát tên là một lần phản |
| C6-30b ngắm | — | Cả 4 tấm **không bị tự ngắm** (`is_hidden`): soft-lock, Lôi Xích, đồng minh không chọn | Tự ngắm luôn chọn tấm gần nhất — thường là tấm giả; nếu chỉ ẩn tấm giả thì tự ngắm lộ tấm thật |
| C6-30b/c chuyển cảnh | — | Bất tử ngắn **cố định**: vỡ gương 3,5 giây, mỗi lần xoay 2,5 giây, vào GĐ3 3 giây; trong lúc đó gương ngừng bắn, Bản Ngã không dùng lại kỹ năng | Trận chỉ 15–22 giây; thời gian cố định cộng đều cho mọi lớp → thu hẹp chênh lệch. Lần thử đầu (gương vẫn bắn khi bất tử) làm Kiếm Khách chết và chênh lệch tăng 28% → 31% |
| C6-30a Thuẫn bóng | −50% sát thương | **−30%** | Chỉ Kiếm Khách (Thiết Bích) và Pháp Sư (Pháp Thuẫn) bị — Thợ Săn không có kỹ năng phòng thủ |
| C6-30a Mắt bóng | Bản Ngã +30% tốc đánh | +30% tốc đánh **và cướp Ưng Nhãn** của người chơi | Thợ Săn hạ GĐ1 (50% HP) trong 5,5 giây so với 10–11 giây của 2 lớp kia nhờ cú bùng nổ mở màn có Ưng Nhãn |
| C6-35 6 món | Chậm 30% | Chậm **40%** | Dùng trạng thái chậm có sẵn của quái (`slow_t`) |

**Cân bằng TL-B6** (Bản Ngã cấp 70, bot cấp 69, bộ đồ chuẩn cấp 69, Thiên phú tiến hoá 1 lần Lv10, đã chuyển chức 2 — 2 nhánh luân phiên theo seed; 20 Thiên phú × 2 seed): Kiếm Khách 32,7 · Thợ Săn 27,7 · Pháp Sư 30,5 giây — các lớp chênh **15%**, F/S chênh tối đa 9% (Thợ Săn), **0 lần chết**.

**Phát hiện:**

- **F1 — Boss "gương / phân thân" phải tách khỏi tự ngắm.** Các hàm tự chọn mục tiêu (`_soft_lock`, `_face_nearest`, `_nearest_enemy`, đồng minh) luôn chọn quái gần nhất. Cơ chế "đánh nhầm bị phạt" cần đánh dấu mọi bản (kể cả bản thật) là `is_hidden`, nếu không tự ngắm vừa phạt oan vừa lộ đáp án.
- **F2 — Phạt theo từng đòn khuếch đại theo số đòn/giây**: lớp đánh nhiều phát nhỏ (Thợ Săn, Lôi Xích) bị phạt gấp nhiều lần lớp đánh ít phát to. Phạt nên có hồi chung.
- **F3 — Thời gian bất tử "cố định" chỉ trung lập khi boss cũng ngừng gây sát thương** trong lúc đó; nếu không, lớp đứng gần (cận chiến) chịu thiệt.
- **F4 — Kỹ năng không có hồi chiêu sẽ không bị sao chép** (dò theo `skill_cds`). Khi SK1 thêm kỹ năng mới, id lạ được Bản Ngã dùng như Tia bóng; nên bổ sung `Ch6.MIRROR_OF`.

**Kiểm thử:** 125/125 test (thêm C6-T1…T6, TL-B6; chạy trên c50eea3 + M9); smoke thêm `15c-camp6`, `15-region6`, `15b-night6`, `15d-ban-nga`.
