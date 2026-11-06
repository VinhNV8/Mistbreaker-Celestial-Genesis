# 40. Icon trang bị HD (EQ-HD)

| Mục | Nội dung |
| --- | --- |
| Ngày | 05/11/2026 |
| Yêu cầu | Chủ dự án: *"tiếp đến các trang bị hiện tại bạn có thấy icon đơn điệu không? Nghiên cứu, và tạo skills để generate trang bị — https://www.pinterest.com/pin/811773901563380624/ — Sau đó tiến hành thử nghiệm vào game"* |
| Skill | [`.claude/skills/equipment-design`](../.claude/skills/equipment-design/SKILL.md) |
| Ảnh duyệt | [docs/design/equipment/](design/equipment/) — `pham-chat.png`, `bo-trang-bi.png`, `tui-do-trong-game.png` |
| Trong game | `godot/assets/hd/icons/eq-*.png` (336 icon) + lớp phủ `manifest["hd"]["icons"]`; `SpriteLib.item_icon` → `eq_icon_id` |
| Trạng thái | **Thử nghiệm trong game (bật khi Đồ hoạ HD bật)** — chờ chủ dự án duyệt ảnh (Q193) |

## 1. Hiện trạng: có đơn điệu không?

Có. Ảnh [tui-do-trong-game.png](design/equipment/tui-do-trong-game.png) (nửa trái, HD tắt):

- **Một icon cho mỗi ô trang bị**: mọi chiếc mũ cùng một hình, mọi đôi giày cùng một hình — đồ Trắng và đồ Cam chỉ khác viền ô.
- **Vũ khí của 4 lớp vẫn là thanh kiếm**: Cung (Thợ Săn), Trượng (Pháp Sư), Chùy (Hộ Vệ), Linh Châu (Triệu Hồi Sư) đều dùng `item-weapon` dù tên món đã đúng.
- **Đồ bộ** (9 bộ) không có hình riêng — trông y hệt đồ Tím thường.
- Icon HD cũ (UI-40) phẳng, đơn sắc, không có chất liệu / ngọc / bậc phẩm chất. Chỉ 17 đồ độc nhất có hình riêng.

## 2. Nghiên cứu ảnh mẫu

Ảnh mẫu là bảng icon trang bị kiểu MMORPG châu Á: hàng trên là ngọc nhiều màu / nhiều kiểu cắt, phía dưới là áo, nhẫn, mũ, găng, giày, dây chuyền, đai, vũ khí theo từng "bộ màu" (tím, vàng, lam, đỏ). Quy chuẩn rút ra (chỉ học phong cách, không chép món nào):

| # | Quy chuẩn | Áp dụng |
| --- | --- | --- |
| E1 | Góc 3/4, vật nghiêng chéo, chiếm gần kín ô; nguồn sáng trên-trái | Vũ khí 45° chuôi dưới trái; mũ / giáp 3/4 |
| E2 | Kim loại có dải tông + vệt bóng loáng sắc; vải có nếp; da có đường may / dây quấn | `spec()`, nếp áo, dây quấn chuôi |
| E3 | Ngọc khảm là điểm nhấn | `gem()` ở chắn tay, núm kiếm, mặt dây, giữa mũ / giáp / găng |
| E4 | Món càng hiếm càng cầu kỳ: sắt → thép → bạc → thép tối viền vàng → vàng ròng; thêm cánh / gai / mào / văn phát sáng / hào quang | `orn` 0–4 theo phẩm chất |
| E5 | Mỗi bộ một bảng màu thống nhất (bộ tím, bộ vàng, bộ lam…) | 9 chủ đề bộ + hoạ tiết nền riêng |
| E6 | Viền tối mảnh, không viền đen dày | Viền `#140d18` dày 2,0 |

Khác ảnh mẫu (giới hạn của hình vẽ bằng code): không có kết cấu vẽ tay chi tiết (vân kim loại, nếp vải mịn); bù bằng cel 3 tông + vệt bóng + ngọc phát sáng (cùng ngôn ngữ với icon kỹ năng IC-1 và cụm nút UI-41d).

## 3. Thiết kế

**id icon**: `eq-<dáng>-<biến thể>-<chủ đề>` — 12 dáng × 2 biến thể × 14 chủ đề = **336 icon** 128 × 128.

| Dáng | Biến thể 0 | Biến thể 1 |
| --- | --- | --- |
| sword (Kiếm Khách) | kiếm thẳng hai lưỡi | đao lưng dày |
| bow (Thợ Săn) | cung cánh cong kép + tên | cung dài + tên |
| staff (Pháp Sư) | móng vuốt ôm ngọc cầu | cụm pha lê |
| mace (Hộ Vệ) | chùy cánh | quả cầu gai |
| orb (Triệu Hồi Sư) | cầu trên móng đỡ | cầu có vòng xoay |
| helm | mũ hiệp sĩ có tấm che, mào (Tím+) | mũ mở có sừng |
| armor | giáp tấm + giáp vai | áo bào có cổ và đai |
| gloves | găng giáp tấm | găng da cổ loe |
| boots | ủng giáp (cánh ở Tím+) | ủng da dây buộc |
| necklace | mặt tròn khảm ngọc | mặt giọt nước + cánh |
| ring | ổ ngọc lớn có chấu | 3 ngọc trên mặt nhẫn |
| amulet | ngọc bội tròn + tua rua | bùa thẻ có ký tự |

**Chủ đề** — phẩm chất (đồ không thuộc bộ): Trắng sắt cũ không ngọc · Xanh lá thép viền men lục · Xanh dương bạc + ngọc lam · Tím thép tối viền vàng + văn phát sáng · Cam vàng ròng + ngọc lớn + hào quang. Bộ (đồ thuộc bộ dùng chủ đề của bộ, không theo phẩm chất):

| Bộ | Bảng màu | Hoạ tiết nền |
| --- | --- | --- |
| Thợ Săn Sương | thép, trắng, lam băng | sương lạnh |
| Phong Hành | bạc, ngọc lục | lông vũ |
| U Minh | sắt rêu, tím, lục độc | bọt độc + khói tím |
| Hoả Ngục | thép đen, vàng, đỏ lửa | lưỡi lửa |
| Cực Quang | bạc, ngọc băng | gai băng |
| Thiên Phong | trắng, vàng, lam trời | đôi cánh |
| Tinh Quang | tím đêm, bạc | sao + vòng |
| Thiên Đạo | ngọc trắng, vàng, lục ngọc | vòng ngọc |
| Sa Hành Giả | vàng, ngọc lam, vải cát | cát xoáy |

**Chọn icon trong game** (`SpriteLib.eq_icon_id`): dáng = `item.style` với vũ khí ("" → kiếm) hoặc ô trang bị; chủ đề = `item.set` nếu có, không thì `item.rarity`; biến thể = `item.id % 2`. Đồ độc nhất giữ `item-<unique>`. Tắt Đồ hoạ HD → icon ô cũ (không có `eq-*` ngoài lớp phủ HD).

## 4. Thử nghiệm trong game

- Test **EQ1-T1**: đủ icon cho mọi ô × kiểu vũ khí × 5 phẩm chất × 9 bộ × 2 biến thể (8 ô; ô vũ khí 5 kiểu); đúng quy tắc chọn; đồ độc nhất giữ icon; tắt HD về icon cũ.
- Ảnh ô túi đồ thật [tui-do-trong-game.png](design/equipment/tui-do-trong-game.png) (`godot/tests/eq_bag.gd`): 5 lớp × 30 món ngẫu nhiên, HD tắt / bật — mỗi lớp có vũ khí đúng kiểu, túi đồ không còn lặp một hình.
- Ảnh smoke túi đồ / cửa hàng / Lò Rèn: icon mới hiện ở ô túi đồ, ô đang mặc, Lò Rèn.

## 5. Câu hỏi cho chủ dự án

| Mã | Câu hỏi | Đề xuất |
| --- | --- | --- |
| Q193 | Duyệt bộ icon trang bị HD (ảnh `docs/design/equipment/`) để giữ làm mặc định khi bật Đồ hoạ HD? Hay cần chỉnh (món nào / bộ nào)? | Giữ; góp ý thì chỉnh theo skill `equipment-design` |
| Q194 | *(→ Q203, docs/42 — ✅ đã vẽ lại 05/11)* Có vẽ lại 17 icon đồ độc nhất cùng phong cách này không? | Có, đợt sau (mỗi món 1 hình riêng theo boss rơi ra) |
