# Đợt M8 — Chương 5: Núi Lửa Phẫn Nộ (vùng 5 Núi Viêm Long) + Chuyển chức 2

| | |
| --- | --- |
| Dự án | Thiên Phú Khai Giới |
| Nguồn | [Kịch bản](kich-ban-game-thien-phu-khai-gioi.md) mục 2 (chương 5: *"Thương hội phản bội, chiến tranh lãnh địa — kết chương: chuyển chức lần 2"*), mục 4 (cây chuyển chức), mục 5 (boss Viêm Long: *"dung nham dâng theo lượt, phải đứng trên đá nổi"*), mục 6 (vùng 5: *"dung nham, núi lửa phun theo chu kỳ — mở: Thiên phú tiến hoá 1 lần"*) · [06](06-ban-do-quai-boss.md) vùng 5 (quái, boss, môi trường, đồ Cam — số liệu Q27) · [11](11-chuong-4.md) (tiến hoá, save v10, bộ điều phối `core/chapters.gd`) |
| Mục tiêu | Chương 5 chơi trọn từ lúc mở vùng 5 tới chuyển chức 2 (điều kiện mở vùng 6) |
| Thứ tự | Sau M7 (phiên game-bc). Chia M8.1 (vùng, môi trường, quái) → M8.2 (boss, đồ) → M8.3 (cốt truyện, chiến tranh lãnh địa, chuyển chức 2) |
| Kiến trúc | Logic trong file mới `core/chapter5.gd`, gắn vào `core/chapters.gd` (`MODULES += [Ch5]`, khai báo `HOOKS`, `MAPS`) — **không sửa chỗ móc trong `game_world.gd`** trừ khi cần hook mới (báo phiên game-bc trước) |
| Quy trình | Spec (file này) → code → test → cập nhật 02/03/04/06/07 và mục Kết quả |
| Trạng thái | ✅ **Xong 21/10/2026** (phiên game-c6) — xem mục 9 (một số số liệu đổi so với spec sau khi cân bằng) |

Ký hiệu: ✅ xong · 🟡 một phần · ⬜ chưa làm.

## 1. Mở vùng 5

| Mã | Yêu cầu | Tiêu chí |
| --- | --- | --- |
| C5-01 | Điều kiện mở (kịch bản mục 6 + M7): **Thiên phú đã tiến hoá ≥ 1 lần** (`profile.evo >= 1`; Đạo Tặc coi như đạt) + **hạ Nữ Vương Phệ Mộng** (`bosses["nu-vuong"]`) + **cấp ≥ 44** (như Q53). Bảng Lục địa hiện điều kiện còn thiếu | C5-T1 |
| C5-02 | 3 map 4.480 × 2.560, sương che (SN-31): **5-1 Chân Núi Tro** (cấp 45–50, trại *Trại Tro Hồng* — 3 NPC), **5-2 Sườn Dung Nham** (50–55, trạm *Trạm Đá Đen*, dung nham chảy thành dòng), **5-3 Miệng Núi Lửa** (55–60, trạm *Đỉnh Khói*, hang *Long Huyệt* cấp 58, boss hiếm Phượng Hoàng Tro). Đi 5-1 → 5-2 → 5-3 | C5-T1; smoke `13-region5` |
| C5-03 | Lưới khai phá vùng 5: 45 ô (bảng sự kiện vùng 2–3). Ô Mỏ của vùng 5 là **Mỏ Tinh Thạch** (06): +1 **Tinh Thạch**/phút (TB-11, tài nguyên mới, hiện ở HUD khi có) thay cho Đá/Sắt | C5-T5 |

## 2. Môi trường núi lửa (M8.1)

| Mã | Yêu cầu | Tiêu chí |
| --- | --- | --- |
| C5-10 | **Dung nham**: các vùng dung nham khai báo trong `maps.gd` (5-1: vài hồ nhỏ · 5-2: 2–3 dòng chảy cắt ngang map, có cầu đá đi qua · 5-3: hồ lớn quanh miệng núi). Đứng trong dung nham **mất 5% HP tối đa/giây** (06), có viền sáng + bốc khói; quái tránh dung nham (không đuổi vào). Né lăn qua dung nham không mất máu | C5-T2 |
| C5-11 | **Núi lửa phun** (06): mỗi **45 giây** (báo trước 3 giây: HUD *"Núi lửa sắp phun!"* + rung màn hình nhẹ), 8 thiên thạch rơi quanh người chơi trong 25 m, mỗi viên **vòng báo 1,5 giây**, trúng **mất 25% HP tối đa** (bỏ qua Phòng thủ, né lăn tránh được, không gục dưới 1 HP — như Q52). 5-1 không phun (chỉ khói), 5-2 và 5-3 phun | C5-T2 |
| C5-12 | **Nhiệt** (06): đứng trong 5 m quanh dung nham (không đứng trong) **+10% tốc đánh**. HUD dòng môi trường: *"Gần dung nham: +10% tốc đánh"* / *"Núi lửa phun sau 0:12"* (dùng dòng `_wind` như chương 3) | C5-T2 |
| C5-13 | **Kháng Hỏa**: affix Kháng Hỏa có sẵn (NV-17) giảm cả sát thương dung nham và thiên thạch (vì chúng mang hệ Hỏa) — tạo lý do mặc đồ kháng ở vùng này | C5-T2 |

## 3. Quái vùng 5 (M8.1)

Chỉ số từ `Formulas.mob_stats` (06 vùng 5).

| Mã | Quái | Loại · hệ | Kỹ năng | Tiêu chí |
| --- | --- | --- | --- | --- |
| C5-20 | **Thằn Lằn Lửa** | Nhanh · Hỏa | Chạy để lại **vệt lửa** 3 giây (×0,2 mỗi giây khi đứng lên); Cắn ×1,0 | C5-T3 |
| C5-21 | **Người Đá Dung Nham** | Giáp · Thổ | Đấm ×1,3; bị hạ **vỡ thành 3 Mảnh Đá** nhỏ (bầy, 15% HP, không rơi đồ, EXP ×0,2 mỗi mảnh) | C5-T3 |
| C5-22 | **Linh Hồn Lửa** | Tự nổ · Hỏa | Lao tới, **tự nổ** sau vung 0,8 s, vòng 5 m (vòng báo đỏ) — như Nấm Con nhưng nhanh; nổ trong dung nham thì không nổ (tắt) | C5-T3 |
| C5-23 | **Pháp Sư Hoả Diệm** | Phép · Hỏa | Đánh xa 18 m; **Cột lửa** (vung 1,0 s): 3 cột nối tiếp về phía người chơi, mỗi cột vòng 2,5 m ×1,2, cách nhau 0,3 giây | C5-T3 |
| C5-24 | Tinh anh **Rồng Non Lửa** (của Thằn Lằn, từ cấp 50) | Nhanh · Hỏa | **Phun lửa** (hồi 10 s): nón 60°, 12 m, ×0,5 mỗi 0,2 s trong 2 giây — quay theo người chơi chậm (60°/giây) để chạy vòng thoát được | C5-T3 |
| C5-25 | Tinh anh **Thợ Rèn Hư Vô** (của Người Đá, từ cấp 54) — thợ rèn Kim Luân bán mình cho Hư Vô Giáo | Giáp · Kim | **Búa rèn** (hồi 12 s): đập vòng 6 m ×2,0; quái trong 10 m **+20% Tấn công 8 giây** (hào quang đỏ). Khiên phía trước như Lính Đánh Thuê | C5-T3 |
| C5-26 | **Lính Kim Luân** (chỉ trong Công Trại, mục 5) | Lì · Kim | Lính đánh thuê của Thương hội: Chém ×1,0; 1/3 mang khiên (như Lính Đánh Thuê) | C5-T6 |

## 4. Boss và đồ (M8.2)

| Mã | Yêu cầu | Tiêu chí |
| --- | --- | --- |
| C5-30 | **Viêm Long** (boss chương 5, cấp 58, Hỏa, 130 đòn — Q23 chương 4+; 77.128 HP theo 06). **GĐ1 (100 → 60%)**: **Vuốt** (vung 0,6 s, ×1,5) · **Long tức** (vung 0,8 s, nón 70°, 18 m, ×0,6 mỗi 0,25 s trong 2,5 giây; quay theo người chơi 45°/giây). **GĐ2 (60 → 20%)**: bay lên — **bất tử, không bị nhắm**; **dung nham dâng theo lượt** (kịch bản): mỗi 20 giây nền hang **ngập dung nham 6 giây** (báo trước 3 giây, nền đỏ dần), chỉ **5 Đá Nổi** (vòng 3 m, vị trí cố định quanh hang) an toàn; ngoài đá nổi mất 8% HP/giây. Giữa các lượt ngập, Viêm Long đáp xuống 8 giây (đánh được, Phá Thế được) rồi bay lên lại; mưa thiên thạch như C5-11 suốt giai đoạn. **GĐ3 (dưới 20%)**: rơi xuống, **Cuồng nộ** — +30% tốc đánh, Long tức mỗi 8 giây, hết ngập dung nham | C5-T4; TL-B5 |
| C5-31 | Viêm Long rơi: 1 đồ Tím · 15% **Long Tâm** (nhẫn Cam: +20% sát thương hệ Hỏa; **miễn dung nham 2 giây sau mỗi lần né lăn**) · 3 Tinh Hoa · 1 Tinh Kim · **10 Tinh Thạch**. Hồi sinh 10 phút | C5-T4 |
| C5-32 | **Đạo Tặc — Long Tức** (sao chép khi hạ Viêm Long lần đầu): phun lửa nón 12 m, ×0,5 mỗi 0,25 s trong 2 giây (đứng yên khi phun) | C5-T4 |
| C5-33 | **Boss hiếm Phượng Hoàng Tro** ở 5-3 (cấp 60, Phép, Hỏa, 200 đòn; 130.423 HP theo 06; bảng `RARE_BOSSES` của M5; xuất hiện sau khi hạ Viêm Long). **Mưa lông lửa** (hồi 6 s): 12 vòng 3 m ngẫu nhiên trong 15 m, vung 1,2 s, ×1,0 · **Lao lửa** (hồi 9 s): bay thẳng xuyên qua người chơi 20 m, vệt báo, ×1,6. **Niết bàn** (06): lần đầu bị hạ thì **hồi sinh 50% HP** trong 3 giây (bất tử, hoá trứng lửa) — **trừ khi** đã trúng đòn **hệ Thủy** trong 5 giây cuối trước khi gục. Nguồn hệ Thủy: Băng Ngục của Pháp Sư, Ngũ Hành hệ Thủy, hoặc **Bình Nước Thánh** (cửa hàng Trại Tro Hồng, 80 vàng; ném bằng phím Q khi Phượng Hoàng dưới 15% HP — như Đuốc Lửa M7) | C5-T4 |
| C5-34 | Phượng Hoàng rơi: **Lông Phượng** (bùa Cam: lần đầu bị hạ thì hồi sinh tại chỗ với 30% HP; hồi 5 phút) · 1 Tinh Hoa Tiến Hoá · 5 Tinh Hoa | C5-T4 |
| C5-35 | **Bộ Hoả Ngục** (đồ Tím vùng 5, 06): 2 — **+30% kháng Hỏa** · 4 — +10% Tấn công · 6 — kỹ năng vùng (Xoáy Kiếm / Mưa Tên / Băng Ngục) để lại **vòng lửa** 5 giây, ×0,3 mỗi giây | C5-T4 |

## 5. Cốt truyện, chiến tranh lãnh địa, chuyển chức 2 (M8.3)

| Mã | Yêu cầu | Tiêu chí |
| --- | --- | --- |
| C5-40 | **NPC Trại Tro Hồng**: *Xích Đồng* (trưởng tộc Hỏa Sơn, thợ rèn già, người dẫn truyện) · *Kim Phú* (chưởng quỹ **Thương hội Kim Luân** — cửa hàng Bình Nước Thánh, đổi Tinh Thạch; CT-05) · *Liệt Diễm* (Kiếm khách lửa ẩn cư, **chuyển chức 2**). Sau bước 4, Kim Phú bỏ trốn → cửa hàng do *Tiểu Hoả* (cháu Xích Đồng) tiếp quản | Smoke `13b-camp5` |
| C5-41 | **Nhiệm vụ chương 5 — 7 bước**: (1) tới Trại Tro Hồng gặp Xích Đồng · (2) Kim Phú nhờ **dọn đường cho đoàn buôn**: hạ 30 quái vùng 5 · (3) **dựng lãnh địa**: chiếm 6 ô vùng 5, có ≥ 1 Mỏ Tinh Thạch · (4) **Thương hội phản bội** (thoại): Kim Phú lộ chuyện bán vũ khí cho Hư Vô Giáo, muốn đoạt Long Tâm của Viêm Long, thuê lính đánh Trại → **Công Trại** (C5-42) · (5) lên Miệng Núi Lửa, khám phá 5-3 ≥ 40% (tìm lối vào Long Huyệt) · (6) hạ **Viêm Long** trước khi Kim Luân lấy được Long Tâm · (7) **chuyển chức 2** với Liệt Diễm. Thưởng EXP ≈ 25% EXP cấp 45 → 60 (cùng tỉ lệ M5-02), chia tăng dần theo bước | C5-T5 |
| C5-42 | **Chiến tranh lãnh địa — Công Trại** (kịch bản chương 5; khởi đầu KP-07): **3 đợt** lính Kim Luân (đợt 1: 6 Lính · đợt 2: 8 Lính + 1 Thợ Rèn Hư Vô · đợt 3: 6 Lính + **Đội Trưởng Kim Luân**, tinh anh Lì · Kim, Phá Thế) tràn vào trại từ 2 hướng; **Cổng Trại** có thanh bền (HP = 30 × cấp người chơi; lính đứng cạnh cổng đánh cổng). Thắng = hạ hết 3 đợt trước khi cổng vỡ; thua = cổng vỡ hoặc người chơi gục → đánh lại được ngay (bấm E với Xích Đồng). Trong lúc Công Trại, trại **không còn là vùng an toàn**. HUD: *"Công Trại · đợt 2/3 · Cổng 74%"* | C5-T6 |
| C5-43 | **Đột kích định kỳ** (sau chương): mỗi **30 phút chơi** ở vùng 5, Kim Luân đột kích một trại vùng 5 (1 đợt 8 Lính + 1 Thợ Rèn Hư Vô, báo trước 60 giây). Thắng: 300 × cấp/50 vàng + 3 Tinh Thạch. **Bỏ qua hoặc thua: công trình vùng 5 ngừng sản xuất 30 phút** (không mất ô — mất ô vĩnh viễn để Alpha khi có Doanh Trại/Tháp Canh KP-17) | C5-T6 |
| C5-44 | **Kết chương 5**: hạ Viêm Long → Kim Phú tới muộn, bị Liệt Diễm đuổi đi; Xích Đồng rèn lại vũ khí cho nhân vật; dư âm: Long Tâm phản chiếu "mảnh thứ hai" — nhân vật thấy bóng mình **không có mặt** (mồi chương 6 *Bản Ngã Bóng Tối*). Màn kết chương | Smoke `14-chapter5-end` |
| C5-45 | **Chuyển chức 2** (kịch bản mục 4, cấp 60; NV-06): điều kiện **cấp 60 + đã chuyển chức 1 + hạ Viêm Long + 30 Tinh Thạch**. **Chọn 1 trong 2 nhánh** (Q51) theo cây kịch bản. Mọi chức 2: thêm **+10% HP và Tấn công** (cộng dồn với chức 1 = +20%), giữ 2 hiệu ứng của chức 1, thêm 2 hiệu ứng mới (C5-46). Không đổi nhánh sau khi chọn (như Q34 không đổi lớp) | C5-T7 |
| C5-46 | **Kỹ năng chuyển chức 2** (bị động, 2 hiệu ứng mỗi nhánh) — bảng dưới | C5-T7; TL-B5 |
| C5-47 | Giao diện: bảng chọn nhánh (2 thẻ: tên, mô tả, hình hào quang màu), tên chức mới ở HUD/bảng Chỉ số/túi đồ; hào quang + thông báo khi chuyển | Smoke `14b-job2` |

**C5-46 — hiệu ứng chuyển chức 2:**

| Lớp | Nhánh | Hiệu ứng 1 | Hiệu ứng 2 |
| --- | --- | --- | --- |
| Kiếm Khách | **Kiếm Thánh** | Kiếm khí (của Kiếm Sư) phóng ở **mỗi đòn chém thứ 3** thay vì thứ 4, ×1,0 | Sát thương vào thanh Phá Thế **+40%** |
| Kiếm Khách | **Huyết Kiếm** | Hút máu **6% sát thương** gây ra (cộng dồn Hấp Huyết) | HP dưới 50%: **+20% Tấn công** |
| Thợ Săn | **Thần Tiễn** | **+10% chí mạng**; chí mạng ×1,2 sát thương chí mạng | Tên Xuyên Phá xuyên **không giới hạn** quái, ×1,2 |
| Thợ Săn | **Thợ Bẫy** | Đặt tối đa **4 bẫy** (thay vì 2), bẫy tồn tại 40 giây | Bẫy khi kích **nổ vòng 4 m ×1,5** (ngoài trói) |
| Pháp Sư | **Đại Pháp Sư** | Thiên Thạch rơi **2 viên** (viên thứ 2 lệch 3 m, ×0,6) | **+30% hồi MP** |
| Pháp Sư | **Tử Linh Sư** | Quái thường bị hạ có **20%** dựng thành **Xương Nô** (đồng minh 12 giây, đánh ×0,5 Tấn công người chơi, tối đa 3) | Mỗi Xương Nô đang có: **+5% Tấn công** |

## 6. Thay đổi save (version 10 → 11)

| Trường | Kiểu | Mặc định save cũ |
| --- | --- | --- |
| `job2` | String — `""` hoặc 1 trong 6 nhánh (`kiem-thanh`, `huyet-kiem`, `than-tien`, `tho-bay`, `dai-phap-su`, `tu-linh-su`). Tách khỏi `job` (chức 1) để giữ nguyên 2 hiệu ứng của chức 1 (`Ch3` kiểm `job == "kiem-su"`…) | `""` |
| `quest.ch5`, `quest.kills5`, `quest.raid_won` | int, int, bool | 0, 0, false |
| `crystal` (Tinh Thạch) | float | 0 |
| `holy_water` (Bình Nước Thánh) | int | 0 |
| `raid_play` (giây chơi ở vùng 5 từ lần đột kích trước), `raid_penalty_until` (giây chơi) | float, float | 0, 0 |

`fog`, `grids`, `unlocked_maps`, `bosses`, `rare_at` dùng lại trường có sẵn.

## 7. Kiểm thử

| Mã | Kiểm |
| --- | --- |
| C5-T1 | Điều kiện mở vùng 5 (thiếu tiến hoá / thiếu Nữ Vương / thiếu cấp → khoá; Đạo Tặc không cần tiến hoá); 3 map đúng cấp/kích thước, đi 5-1 → 5-3 |
| C5-T2 | Dung nham −5% HP/giây, né lăn qua không mất máu, quái không đuổi vào; núi lửa phun mỗi 45 giây, 8 thiên thạch, −25% HP, né được, không gục; nhiệt +10% tốc đánh trong 5 m; Kháng Hỏa giảm sát thương dung nham |
| C5-T3 | Vệt lửa; Người Đá vỡ 3 mảnh; Linh Hồn Lửa tự nổ, tắt trong dung nham; Cột lửa 3 cột; Phun lửa quay chậm; Búa rèn + hào quang +20% |
| C5-T4 | Viêm Long 3 giai đoạn (bất tử khi bay, ngập dung nham theo lượt, đá nổi an toàn, cuồng nộ); Long Tâm; Long Tức; Phượng Hoàng: Niết bàn hồi sinh 50%, trúng hệ Thủy 5 giây cuối thì không hồi sinh, Bình Nước Thánh; Lông Phượng; Bộ Hoả Ngục |
| C5-T5 | Nhiệm vụ chương 5 đủ 7 bước; thưởng EXP ≈ 25%; lưới vùng 5 45 ô, Mỏ Tinh Thạch +1/phút |
| C5-T6 | Công Trại 3 đợt, cổng có thanh bền, thua đánh lại được, trại không an toàn khi đang công; đột kích mỗi 30 phút chơi, thắng có thưởng, bỏ qua thì công trình vùng 5 ngừng 30 phút |
| C5-T7 | Chuyển chức 2: điều kiện, chọn nhánh, +20% tổng, 6 nhánh × 2 hiệu ứng, không đổi nhánh; save v11 + chuyển đổi v10 |
| TL-B5 | 3 lớp × 20 Thiên phú (mỗi lớp thử cả nhánh chức 1, không dùng chức 2) hạ Viêm Long (cấp 57, bộ đồ chuẩn cấp 57, đã tiến hoá 1 lần): F/S ≤ 25%, các lớp ≤ 25%, 0 lần chết |
| TL-J2 | Mỗi lớp: 2 nhánh chức 2 hạ Viêm Long chênh nhau ≤ 15% (không có nhánh "bắt buộc phải chọn") |
| PACE-T3 | (chạy riêng `--only=PACE`) bot cày vùng 5 cấp 45 → 60: in phút và số lần chết theo map |

## 8. Điểm cần duyệt

| # | Câu hỏi | Mặc định đã chọn |
| --- | --- | --- |
| Q59 | "Chiến tranh lãnh địa" (kịch bản chương 5) làm tới mức nào ở MVP? | **Công Trại** (sự kiện cốt truyện, 3 đợt, giữ cổng) + **đột kích định kỳ** mỗi 30 phút chơi ở vùng 5; thua chỉ ngừng sản xuất 30 phút. Mất ô vĩnh viễn, Doanh Trại/Tháp Canh, chiến tranh giữa người chơi → Alpha (KP-07, KP-17) |
| Q60 | Thiên thạch núi lửa −25% HP (06) có quá nặng? | Giữ 25% (bỏ qua Phòng thủ, Kháng Hỏa giảm được) nhưng **không làm gục dưới 1 HP** và có vòng báo 1,5 giây — áp lực, không phạt chết oan |
| Q61 | Phượng Hoàng cần hệ Thủy — lớp không có hệ Thủy? | **Bình Nước Thánh** 80 vàng ở Trại Tro Hồng (như Đuốc Lửa ở M7, Q56) |
| Q62 | Chuyển chức 2 có tốn tài nguyên? | **30 Tinh Thạch** — tạo chỗ tiêu cho tài nguyên mới (Q26: mỗi tài nguyên phải có chỗ tiêu) và gắn lãnh địa vùng 5 với chuyển chức |
| Q63 | Ô Thiên phú phụ thứ 2 ở cấp 60 (kịch bản mục 3, TP-05) làm cùng M8? | **Không** — cần cả hệ Thiên phú phụ (ô 1 ở cấp 30 cũng chưa có); làm thành đợt riêng trước Alpha |
| Q64 | Thương hội Kim Luân sau chương 5 còn bán hàng không? | Chi nhánh ở Trại Tro Hồng đóng (Tiểu Hoả bán thay); phe Kim Luân (CT-05: đấu giá, hộ tống) để Alpha, vai phản diện phụ |

## 9. Kết quả

| Mã | Trạng thái | Ghi chú |
| --- | --- | --- |
| C5-01…03 | ✅ | `maps.gd` 5-1/5-2/5-3 (`lava`, `eruption`); `Ch5.map_requirement` (Nữ Vương + `Ch4.evolved_once` + cấp 44); lưới vùng 5 dùng bảng sự kiện vùng 2–4; **Mỏ vùng 5 cho Tinh Thạch** (`Explore.production_per_minute` đếm khoá `mine_r5_*`), Tinh Thạch hiện ở HUD |
| C5-10…13 | ✅ | `Ch5.tick`: dung nham −5%/giây (né lăn / Long Tâm miễn), núi lửa phun 5-2/5-3, nhiệt +10% tốc đánh (dựng lại chỉ số khi vào/ra vùng nhiệt), Kháng Hỏa giảm; quái tránh dung nham (`enemy_avoid`). View `view/region5_view.gd` |
| C5-20…26 | ✅ | Thằn Lằn (vệt lửa), Người Đá (Đấm ×1,3; vỡ 3 Mảnh Đá), Linh Hồn Lửa (nổ 5 m, tắt trong dung nham), Pháp Sư Hoả Diệm (3 Cột lửa), Rồng Non (Phun lửa quay 60°/giây), Thợ Rèn Hư Vô (Búa rèn + hào quang +20%, khiên trước), Lính/Đội Trưởng Kim Luân |
| C5-30…35 | ✅ | Viêm Long 3 giai đoạn (bay = bất tử + không bị nhắm qua `Enemy.fly_t`, ngập dung nham, 5 Đá Nổi, cuồng nộ); Long Tâm, Long Tức (Đạo Tặc), Phượng Hoàng Tro (`RARE_BOSSES["5-3"]`, Niết bàn, Bình Nước Thánh, Băng Ngục/Ngũ Hành Thủy/Hỏa Cầu Nguyên Tố = hệ Thủy), Lông Phượng (hook `player_hurt`), Bộ Hoả Ngục |
| C5-40…44 | ✅ | `story.gd` `QUESTS5` + 24 đoạn thoại; NPC Trại Tro Hồng (Kim Phú bỏ trốn → Tiểu Hoả, hook mới `npc_visible`); thưởng EXP 2.450.000 ≈ 25% EXP cấp 45 → 60; màn kết chương 5 |
| C5-42, C5-43 | ✅ | Công Trại 3 đợt (cổng có thanh bền, trại mất an toàn qua `safe_blocked`), đột kích mỗi 30 phút chơi sau chương (thua: Mỏ Tinh Thạch ngừng 30 phút theo `build_clock`) |
| C5-45…47 | ✅ | `Classes.JOBS2`, `Ch5.can_job2 / do_job2`, bảng chọn nhánh `ui/job2_panel.gd` (Liệt Diễm, phím E), tên chức 2 ở HUD/Chỉ số/túi đồ. Hook mới: `poise_mult`, `trap_extra`, `trap_triggered`, `meteor_extra` |
| Sửa lỗi chung | ✅ | (1) `main.gd`: NPC trả về `"shop"` ở trại vùng 3–5 (A Mộc, Lão Ngư) không mở được cửa hàng — chỉ mở ở 1-1/2-1. (2) Màn chiến thắng hạ Sa Hoàng / Nữ Vương ghi "CHƯƠNG 1 HOÀN THÀNH" — đổi thành bảng `Screens.VICTORY` theo boss (chương 1–5). (3) `_nova` đặt `hit_source = "nova"` để chương nhận ra đòn Băng Ngục |

**Đổi so với spec (sau khi code + cân bằng):**

| Mục | Spec | Đã làm | Lý do |
| --- | --- | --- | --- |
| C5-30 lượt ngập | Chu kỳ cố định 20 giây: bay 9 s → đáp 8 s → bay 3 s | Bay 9 s (báo 3 + ngập 6) → **đáp tới khi mất 15% HP hoặc 10 giây** → bay lại; đáp **ngay cạnh người chơi**, 3 giây đầu không phun Long tức | Chu kỳ cố định "làm tròn" thời gian giai đoạn 2 theo bậc 20 giây: Thợ Săn hạ 40% HP trong 1 lần đáp, Kiếm Khách cần 2 lần → các lớp chênh 36%. Đáp theo lượng sát thương → thời gian tỉ lệ với sát thương |
| C5-30 Đá Nổi | Vòng 3 m | An toàn khi thân người chơi còn chạm đá (3 m + bán kính người) | 3 m quá chặt — người chơi đứng mép đá bị trôi ra ngoài |
| C5-21 Mảnh Đá | EXP ×0,2 mỗi mảnh | Không cho EXP/đồ | Đơn giản hoá (hook `vanish`) — tránh 3 mảnh cho EXP như 3 quái |
| C5-42 Cổng Trại | HP = 30 × cấp | HP = 200 × cấp; lính đứng cạnh cổng đánh 50% Tấn công mỗi 1,5 giây | 30 × cấp vỡ trong vài giây ở cấp 50 |
| C5-46 Kiếm Thánh | Kiếm khí ở đòn thứ 3 *thay vì* thứ 4 | Đòn thứ 3 phóng **thêm** kiếm khí ×1,0 (đòn thứ 4 của Kiếm Sư giữ nguyên) | Không sửa logic chức 1 trong `chapter3.gd` |
| C5-46 Thần Tiễn | Tên Xuyên Phá xuyên không giới hạn, ×1,2 | Tên Xuyên Phá hồi chiêu −1 giây (4 → 3) | Tên Xuyên Phá vốn đã xuyên mọi quái |
| C5-26 Lính Kim Luân | 1/3 mang khiên | 1/3 (theo id quái) chặn 70% đòn trước mặt, không vẽ khiên | Khiên vẽ theo dữ liệu loại quái (`shield` trong `monsters.gd`), không theo từng con |
| Save | `job` thêm 6 giá trị | Trường mới `job2` | Xem mục 6 |

**Cân bằng TL-B5** (Viêm Long cấp 58, bot cấp 57, bộ đồ chuẩn cấp 57, Thiên phú đã tiến hoá 1 lần, chưa chuyển chức 2; 20 Thiên phú × 2 seed): Kiếm Khách 47,1 · Thợ Săn 39,2 · Pháp Sư 38,3 giây — các lớp chênh 19%, F/S chênh tối đa 16% (Pháp Sư), **0 lần chết**.

**Phát hiện:**

- **F1 — Thời gian giai đoạn nhảy bậc theo chu kỳ** (xem bảng trên): cơ chế "bất tử theo lượt cố định" khuếch đại chênh lệch sát thương nhỏ giữa các lớp thành chênh lệch thời gian lớn. Boss sau nên mở cửa sổ đánh theo lượng sát thương.
- **F2 — Trạng thái ngập còn sót khi boss sinh lại** (người chơi gục → boss mới giai đoạn 1 vẫn ngập dung nham). Sửa: giai đoạn khác 2 luôn tắt ngập.
- **F3 — Thiên phú Lv1 ở vùng 5 quá yếu**: cùng trận, Thiên phú Lv1 (chưa tiến hoá) mất 50–230 giây (Kiếm Khách 230). Cấp hiệu dụng sau tiến hoá (D39) là một phần lớn sức mạnh cấp cao — người chơi bỏ luyện Thiên phú sẽ kẹt ở vùng 5. Cân nhắc nhắc luyện Thiên phú trong nhiệm vụ chương 4–5.
- **F4 — Lỗi định dạng `%` lần thứ 5** ("+10% HP" trong bảng chuyển chức 2) — smoke bắt được.
- **Bot**: thêm né vòng báo thiên thạch / cột lửa / mưa lông và lên Đá Nổi khi dung nham dâng (trước đó bot cận chiến gục vì đứng yên trong vòng thiên thạch 25% HP).

**Kiểm thử:** 113 test (thêm C5-T1…T7, TL-B5); smoke thêm `13b-camp5`, `13-region5`, `13c-vien-long`, `14b-job2`, `13d-siege`.
