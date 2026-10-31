# Spec_Notes đợt 11: thẻ trang bị khi rê chuột, so sánh với đồ đang mặc, bản đồ rộng gấp 3

| | |
| --- | --- |
| Dự án | Thiên Phú Khai Giới |
| Nguồn | [Spec_Notes.md](Spec_Notes.md) (chủ dự án, 31/10/2026) — đã chuyển sang [Spec_Notes_Done.md](Spec_Notes_Done.md) |
| Loại tài liệu | Đặc tả + kết quả |
| Trạng thái | ✅ Đã làm (31/10/2026), save v23, test SN11-T1/T2, SN-T5, C3…C7-T1 (cập nhật) |

## 1. Yêu cầu

| Mã | Ghi chú của chủ dự án | Cách hiểu |
| --- | --- | --- |
| SN11-01 | *"Thông tin nhân vật, khi di chuột vào trang bị — nếu nhân vật đang mặc trang bị → thì không thấy hiển thị thông tin về trang bị đó dạng tool-tip nhỉ?"* | Rê chuột vào ô đồ đang mặc (cột trang bị trong Túi đồ) hiện **thẻ thông tin** của món đó |
| SN11-02 | *"Tab trang bị — khi chọn hoặc di chuột vào 1 trang bị, thì không thấy hiển thị thông tin trang bị đang mặc để compare với trang bị đang select nhỉ? Các game thường sẽ có kiểu này."* | Rê chuột / chọn món trong túi: hiện thẻ món đó **kèm thẻ món đang mặc cùng ô** bên cạnh, dòng chênh lệch ▲ xanh / ▼ đỏ |
| SN11-03 | *"Map (bản đồ) — hiện tại đang bé quá, đi vài bước chân đã hết bản đồ rồi … tôi muốn bản đồ rộng gấp 3 lần hiện tại"* | Chủ dự án chọn **diện tích ×3** (31/10): mỗi chiều ×√3 ≈ 1,73; mật độ quái giữ nguyên (số quái ×3) |

## 2. SN11-01, SN11-02 — thẻ trang bị và so sánh

| Rê chuột vào | Hiện |
| --- | --- |
| Ô đồ đang mặc | 1 thẻ **ĐANG MẶC** |
| Món trong túi, ô đó đang mặc đồ | 2 thẻ cạnh nhau: **ĐANG XEM** (kèm phần "So với đang mặc:") + **ĐANG MẶC** |
| Món trong túi, ô đó đang trống | 1 thẻ **ĐANG XEM**, phần so sánh ghi "Ô này đang trống — mặc vào:" |

Mỗi thẻ: tên (màu phẩm chất), phẩm chất · ô · cấp, chỉ số gốc "(gốc)", dòng phụ (xanh nhạt), hiệu ứng riêng, bộ. Phần so sánh: mỗi chỉ số chênh một dòng **▲ +N (xanh)** / **▼ −N (đỏ)**, dòng cuối ▲/▼ Lực chiến. Món trong túi tính theo cấp cường hoá sẽ nhận khi mặc (chuyển cường hoá theo ô).

- Thẻ nổi trên bảng (`top_level`), không chặn chuột, đặt cạnh con trỏ, tự lật khi sắp tràn màn hình; rời chuột / đóng bảng / vẽ lại thì ẩn.
- Khung chi tiết khi **chọn** món trong túi có phần "So với đang mặc:" giống thẻ (thay dòng "Mặc vào: Lực chiến" cũ).
- Các ô đồ không còn tooltip chữ của Godot (thẻ thay thế).

Code: `ui/item_tip.gd` (`ItemTip.make`, `card`, `diff_lines`, `place`); `InventoryPanel._show_tip / _hide_tip`, nút `Worn_<ô>`, `Bag_<i>`; `_detail` mục `CompareHeader`.

## 3. SN11-03 — bản đồ rộng gấp 3

| Hạng mục | Trước | Sau |
| --- | --- | --- |
| Kích thước map (1-1) | 4160 × 2560 | **7205 × 4434** (×√3 mỗi chiều) |
| Map vùng 2–7 | 4480 × 2560 | 7760 × 4434 |
| Vị trí làng, hang boss, tường sương, đèn / cột / lửa trại / đảo bay / vùng nước | — | nhân ×√3 |
| Bán kính làng, hang boss, dung nham, ốc đảo, đất sụt; vị trí NPC trong làng | — | giữ nguyên |
| Đảo bay, vùng nước đầm | — | nhân cả bán kính (là địa hình) |
| Dải cấp quái theo chiều ngang (`zone_x`) | — | nhân ×√3 (cấp đầu / cuối map không đổi) |
| Số cây | — | ×3 |
| Trần quái thường | 40 | **120** (mật độ như cũ) |
| Thảo dược, rương | theo diện tích | tự ×3 |
| Bãi quái tối đa | 6 | **10** |
| Hang phụ (`cave-*`) | — | giữ nguyên |

- **Sương mù:** lưới sương đổi kích thước → save cũ (< v23) **phủ sương lại** cho mọi map; thưởng khai phá đã nhận giữ nguyên. Save **v23**.
- **RNG:** quái / thảo dược / rương sinh lúc nạp map dùng RNG riêng `_fill_rng` (băm `fill:<map>`): số quái ×3 không làm đổi chuỗi ngẫu nhiên của trận đánh sau đó.
- **Vẽ:** toạ độ lên tới ~7000 px làm Godot báo *"Invalid polygon data, triangulation failed"* với hình nhỏ (huy hiệu ngũ hành trên bảng tên quái). Đa giác nhỏ trong thế giới vẽ quanh gốc rồi dời tới vị trí (`SpriteLib.poly`, `ElementIcon.draw`).

Code: `data/maps.gd` `MAP_SCALE`, `get_map()` (có cache), `scaled()`, `POINT_LISTS`, `CIRCLE_LISTS`; `core/caves.gd` `entrance()` đọc qua `get_map`; `GameWorld.WORLD_SIZE / VILLAGE_POS / ARENA_POS / GATE_X` × `MAP_SCALE`, `FIELD_MOBS_CAP` 120, `CAMP_MAX` 10, `_fill_rng`; `Profile` v23 (fog); `view/sprite_lib.gd` `poly()`; `main.gd` toạ độ smoke × `MAP_SCALE`.

**Map mới (chương 8+):** khai báo toạ độ theo thang cũ (4480 × 2560) trong `MAPS`; khoá mảng điểm mới thêm vào `POINT_LISTS`, mảng [tâm, bán kính] thêm vào `CIRCLE_LISTS`.

## 4. Test

| Mã | Kiểm |
| --- | --- |
| SN11-T1, T2 | Thẻ ĐANG MẶC cho đồ đang mặc; đồ trong túi 2 thẻ + so sánh; ▲ Tấn công khi mạnh hơn, ▼ đỏ khi yếu hơn; ô trống không có thẻ ĐANG MẶC; khung chi tiết có "So với đang mặc:"; ô đang mặc rê chuột hiện thẻ |
| SN-T5, C3-T1, C4-T1, C5-T1, C6-T1, C7-T1 | Kích thước map = cũ × `MAP_SCALE`; cấp quái theo chiều ngang nhân ×√3 |
| CL-T3, CB-T9, C3-T3, C3-T4, C4-T3, C4-T4, C5-T4 | Các phép kiểm "đòn trúng" đặt né tránh = 0 (chuỗi ngẫu nhiên đổi vì map lớn hơn — trước đó có lúc né trúng 10% của Kiếm Khách) |
| PV-T3 | Đo trung bình **3 seed** (5, 11, 13) thay vì 2 cho ổn định |
