# 42. Thiết kế lại giao diện xem đồ (UI-64…66, EQ-HD v2)

| Mục | Nội dung |
| --- | --- |
| Ngày | 05/11/2026 |
| Yêu cầu | Chủ dự án: *"Người chơi xem đồ và thấy xấu quá, ko đẹp như những game khác → Em hãy nghiên cứu và design lại cho anh nhé"* |
| Phạm vi | (1) icon trang bị (EQ-HD, [40](40-icon-trang-bi.md)) vẽ lại có khối; (2) ô đồ trong túi / đang mặc; (3) thẻ thông tin trang bị (bảng chi tiết + thẻ nổi khi rê chuột) |
| Ảnh | [design/equipment/](design/equipment/): `xem-do-truoc.png` → `xem-do-sau.png`, `xem-do-so-sanh-truoc.png` → `xem-do-so-sanh-sau.png`, `pham-chat.png`, `bo-trang-bi.png`, `tui-do-trong-game.png` |
| Trạng thái | ✅ Đã làm và có trong game (05/11/2026) — chờ chủ dự án xem (Q202) |

## 1. Vì sao "xấu"

Ảnh [xem-do-truoc.png](design/equipment/xem-do-truoc.png), [xem-do-so-sanh-truoc.png](design/equipment/xem-do-so-sanh-truoc.png):

| Chỗ | Vấn đề |
| --- | --- |
| Icon | Phẳng kiểu hoạt hình: một mảng màu + viền, không có khối sáng tối, không viền sáng, kim loại không "lấp lánh" |
| Ô đồ | Hình chữ nhật phẳng, viền màu mảnh 1 px; icon chỉ chiếm ~60% ô; ô Trắng và ô Cam chỉ khác màu viền; ô trống là ô đen |
| Bảng chi tiết / thẻ nổi | Một cột chữ trơn: tên, 1 dòng phẩm chất, các dòng chỉ số cùng cỡ; không có icon lớn, không có biểu tượng chỉ số, không phân nhóm; phần so sánh là chữ ▲ ▼ xếp dọc dài |

## 2. Nghiên cứu: giao diện đồ ở các game khác

| Quy chuẩn | Nguồn |
| --- | --- |
| Phẩm chất phải **đọc được không cần rê chuột**: nền ô nhuộm màu và / hoặc khung theo bậc | Người chơi Path of Exile, Dark and Darker đề nghị (nền / viền / dấu góc theo bậc) |
| **Không chỉ dùng màu**: mỗi bậc một kiểu khung + dấu hiệu riêng (người mù màu vẫn phân biệt) | Bản thiết kế Salt & Steel (khung, hạt sáng, chữ, mật độ chi tiết theo bậc) |
| Thang màu phẩm chất quen thuộc Trắng → Lục → Lam → Tím → Cam | Quy ước WoW, Borderlands, Torchlight (game đang dùng đúng thang này) |
| Thẻ thông tin: **tên màu phẩm chất ở đầu**, tách khỏi phần thân | Quy ước tooltip WoW / Last Epoch |
| Ô trống: **bóng khắc mờ** của loại đồ | Salt & Steel |
| Ô lưới 48–64 px trên PC | Hướng dẫn inventory UI (abratabia) |

## 3. Thiết kế

### 3.1 Ô đồ theo bậc (UI-64) — `ui/item_card.gd` `SlotBox`

| Bậc | Nền | Khung |
| --- | --- | --- |
| Trắng | nhuộm xám nhẹ từ đáy | viền 1 px xám |
| Xanh lá | nhuộm lục | viền 1,5 px lục |
| Xanh dương | nhuộm lam | viền 2 px + **4 đinh góc** |
| Tím | nhuộm tím đậm | viền 2 px + đinh + **nẹp góc vàng hình L** |
| Cam | nhuộm cam đậm nhất | viền 2,5 px + đinh + nẹp + **quầng sáng ngoài** + hình thoi giữa cạnh |

Nền toả sáng từ đáy (vệt sáng hình bầu dục dưới icon), gờ sáng mép trên; icon chiếm ~90% ô (lề trong 3 px); ô đang chọn có viền vàng ngoài; rê chuột sáng nền + viền. Ô trống: nền tối, ô đang mặc trống có bóng khắc mờ của loại đồ. Chấm phẩm chất (UI-63) và số cường hoá giữ nguyên.

### 3.2 Thẻ thông tin trang bị (UI-65, UI-66) — `ItemCard.build`, dùng chung cho thẻ nổi (`item_tip`) và bảng chi tiết (`inventory_panel._detail`)

1. **Dải đầu** nhuộm màu phẩm chất (mờ dần sang phải, gạch màu mép trên): icon lớn 64 px trong ô theo bậc · tên (đậm, màu phẩm chất, đã có "+N") · tên ô · chip "Cam · Huyền thoại" (bậc: Thường / Tốt / Hiếm / Sử thi / Huyền thoại) · chip "Đồ bộ". *UI-65b (06/11, chủ dự án thấy thừa): bỏ "· Cấp N" cạnh tên ô (cấp món chỉ để tính chỉ số, không giới hạn mặc) và chip "+N" (trùng số trong tên).*
2. **Chỉ số chính** số to 20 px kèm biểu tượng chỉ số; phần cộng thêm từ cường hoá tô lục; "(gốc)" chữ nhỏ.
3. Đường phân cách có ngọc → **dòng phụ** mỗi dòng một biểu tượng chỉ số (stat-*), chữ lam.
4. **Đồ độc nhất**: ô viền màu phẩm chất "✦ hiệu ứng".
5. **Bộ**: tên bộ + (đang mặc / tổng), các mốc ✓ sáng / · mờ.
6. **So sánh**: tiêu đề "So với đang mặc: …" + các **chip ▲ / ▼** (lục / đỏ, hoặc lam / cam ở bảng màu mù màu) xếp thành hàng.

Thẻ nổi: khung tối đổ bóng, viền màu phẩm chất, rộng 290 px; đồ trong túi hiện [ĐANG XEM][ĐANG MẶC] cạnh nhau như cũ.

### 3.3 Icon trang bị có khối (EQ-HD v2) — `tools/art/hd/equip_kit.py`

- **Lớp "tranh vẽ"** (`paint_pass`) sau khi dựng: ánh sáng chéo trên-trái (+16%) → dưới-phải (−20%) trên toàn vật; **viền sáng** ở mép đón sáng; **bóng lõm** ở mép khuất; hạt vân chất liệu rất nhẹ; tương phản +8%, bão hoà +14%.
- **Quầng sáng tách lớp** (`glow_bg` sau vật, `glow_fg` trước vật): trước đây quầng vẽ chung lớp bị viền tối của silhouette bọc thành đĩa nâu tối; nay quầng không có viền, sáng trong.
- Kiếm biến thể 1 thành **đao cong một lưỡi** (trước gần giống biến thể 0).
- Quy chuẩn ghi vào skill `equipment-design` (E9, E10).

## 4. Kiểm tra

- Test **EQ1-T1** (mở rộng): ô đồ dùng `SlotBox` đúng bậc, ô chọn có viền; thẻ đồ có nhãn bậc, chip cường hoá, phần so sánh dạng chip, `CompareHeader`. **SN11-T1/T2** (thẻ nổi, so sánh) vẫn qua.
- Ảnh smoke thật: [xem-do-sau.png](design/equipment/xem-do-sau.png) (túi đồ + bảng chi tiết), [xem-do-so-sanh-sau.png](design/equipment/xem-do-so-sanh-sau.png) (thẻ nổi so sánh); ô túi đồ 5 lớp [tui-do-trong-game.png](design/equipment/tui-do-trong-game.png).

## 5. Câu hỏi

| Mã | Câu hỏi | Đề xuất |
| --- | --- | --- |
| Q202 | Giao diện xem đồ mới đã đạt chưa, cần chỉnh gì (ô, thẻ, icon)? | — |
| Q203 | 17 icon đồ độc nhất (Nanh Sói Chúa…) vẫn kiểu phẳng cũ — giờ lệch hẳn với đồ thường. Vẽ lại theo EQ-HD v2? (thay cho Q194) | ✅ Chủ dự án "vẽ lại đi em" (05/11) → đã làm, §6 |

## 6. Vẽ lại 17 icon đồ độc nhất (05/11/2026, Q203)

`tools/art/hd/equip_unique.py` — mỗi món một hình riêng kể chuyện boss rơi ra nó, cùng ngôn ngữ EQ-HD v2 (khối, vệt bóng, ngọc, quầng màu theo boss tách lớp, lớp "tranh vẽ"). Ảnh duyệt cũ | mới: [doc-nhat.png](design/equipment/doc-nhat.png). Ghi đè bản phẳng IC-2 (`items_hd_more.py` giữ nguyên; `build_hd.py` chạy `equip_unique` sau).

| Món | Boss | Hình mới |
| --- | --- | --- |
| Nanh Sói Chúa | Sói Chúa Hư Vô | lưỡi nanh ngà cong có vân, chắn tay đen ngọc tím, chuôi quấn lông sói, quầng tím |
| Vỏ Lão Thụ | Lão Thụ Sương Mù | mảnh vỏ cổ thụ khắc rune lục phát sáng, rêu, mầm lá, dây leo |
| Mặt Nạ Huyền Ảnh | Tướng Gián Điệp Huyền Ảnh | mặt nạ bạc, nửa mặt tan thành bóng tím (phân thân), khe mắt sáng |
| Vuốt Bạch Hổ | Bạch Hổ Phong Vân | găng lông trắng sọc đen nắm lại, 3 vuốt thép cong từ đốt tay, vệt gió |
| Đuôi Sa Hoàng | Bọ Cạp Sa Hoàng | đuôi bọ cạp nhiều đốt vỏ đỏ viền vàng, kim độc nhỏ giọt lục |
| Mắt Nhân Sư | Nhân Sư Đá | huy chương sa thạch viền vàng, mắt hổ phách phát sáng, ngọc lam |
| Long Tâm | Viêm Long | nhẫn đen, móng rồng vàng ôm tim nham thạch rực cháy |
| Lông Phượng | Phượng Hoàng Tro | lông vũ lửa đỏ → cam → vàng, than hồng bay |
| Gối Mộng | Nữ Vương Phệ Mộng | gối lụa tím, trăng khuyết vàng thêu, tua, sao mộng |
| Vảy Thất Đầu | Thuỷ Quái Thất Đầu | áo giáp vảy ngọc lam xếp lớp, 7 nanh ở cổ, ngọc thuỷ, giọt nước |
| Gương Bản Ngã | Bản Ngã Bóng Tối | gương tay khung bạc gai băng, mặt gương tối in bóng người không mặt |
| Vảy Long Băng | Long Băng Bắc Cực | ủng phủ vảy băng, gai băng ở cổ ủng |
| Búa Cự Thần | Thiên Không Cự Thần | đầu búa đá trắng khổng lồ, đai vàng, rune trời phát sáng lam |
| Sừng Kỳ Lân | Kỳ Lân Mây | mặt dây sừng xoắn ngà viền vàng, mây cuộn, quầng lục hồi máu |
| Ấn Hư Vô | Giáo Chủ Hư Vô | nhẫn ấn bạc, mặt ấn đen khắc mắt Hư Vô hồng tím |
| Nanh Hư Vô | Hư Vô Thú | dao găm tinh thể đen răng cưa, vết nứt hồng phát sáng |
| Mặt Nạ Vô Diện | Ma Tôn Vô Diện | mặt nạ sứ trắng không nét mặt, vết nứt Hư Vô, vương miện đen 5 ngọc ngũ hành |

Kiểm tra: EQ1-T1 (đồ độc nhất dùng `item-<id>`), ảnh smoke túi đồ / thẻ so sánh có Nanh Sói Chúa mới ([xem-do-so-sanh-sau.png](design/equipment/xem-do-so-sanh-sau.png)).
