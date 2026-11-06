---
name: equipment-design
description: "Thiết kế và sinh icon trang bị HD (vũ khí, mũ, giáp, găng, giày, dây chuyền, nhẫn, bùa) cho game Thiên Phú Khai Giới theo phong cách 'icon MMORPG châu Á' đã chốt ở docs/40: góc 3/4, kim loại có vệt bóng loáng, ngọc khảm làm điểm nhấn, bậc phẩm chất = bậc chất liệu + độ cầu kỳ, mỗi bộ trang bị có bảng màu + hoạ tiết nền riêng. Dùng khi thêm bộ trang bị mới, thêm phẩm chất / kiểu vũ khí / ô trang bị mới, sửa icon trang bị, hoặc khi người dùng nói 'icon trang bị', 'icon đồ', 'vẽ vũ khí', 'design trang bị', 'equipment icon'."
---

# Skill: equipment-design — icon trang bị HD theo docs/40

Icon trang bị **sinh bằng code** (Python + Pillow, thư viện vector `tools/art/hd/vec.py`, siêu mẫu ×4 rồi thu Lanczos), không vẽ tay, không AI tạo ảnh. Một bảng **chủ đề** (phẩm chất + bộ) × **dáng** (12) × **biến thể** (2) → `eq-<dáng>-<biến thể>-<chủ đề>` 128 × 128, lớp phủ `manifest["hd"]["icons"]` (bật / tắt ở Cài đặt → Đồ hoạ HD; tắt → icon ô cũ).

Tài liệu gốc: `docs/40-icon-trang-bi.md` (nghiên cứu ảnh mẫu, quy chuẩn, danh mục). **Ảnh duyệt trong `docs/design/equipment/` là spec**: `pham-chat.png` (12 dáng × 2 biến thể × 5 phẩm chất), `bo-trang-bi.png` (12 dáng × 9 bộ), `tui-do-trong-game.png` (ô túi đồ thật, HD tắt / bật).

## 1. Quy chuẩn phong cách (bắt buộc)

Rút ra từ ảnh mẫu Pinterest 811773901563380624 (bảng icon trang bị MMORPG). Chỉ học **phong cách**, không chép món nào của ảnh mẫu.

| # | Quy tắc | Cách làm trong code |
| --- | --- | --- |
| E1 | **Góc 3/4, vật nghiêng chéo** (vũ khí ~45°, chuôi dưới trái → mũi trên phải), chiếm 80–90% ô; nguồn sáng trên-trái | Ô 128, toạ độ `along(base, tip)`; `new()` đặt nguồn sáng (−1, −1,25) |
| E2 | **Chất liệu 3 tông + vệt bóng loáng** sắc trên kim loại (kim loại phải "lấp lánh", không phẳng) | `c.part(shape, tone, shade_d, light_d)` + `spec(c, pts)` dọc cạnh sáng |
| E3 | **Ngọc khảm là điểm nhấn** (mặt cắt nhiều mặt, chấm sáng trắng, quầng màu) — ở chắn tay, mặt dây, giữa mũ / giáp | `gem(c, x, y, r, col, cut="round/drop/diamond")` |
| E4 | **Bậc phẩm chất** = bậc chất liệu + độ cầu kỳ (`orn` 0–4): Trắng sắt cũ trơn, không ngọc → Lục thép + viền màu → Lam bạc + ngọc → Tím thép tối viền vàng + hoa văn phát sáng → Cam vàng ròng + ngọc lớn + cánh / gai + hào quang | `THEMES[...]`: `metal, trim, cloth, leather, gem, glow, orn, aura` |
| E5 | **Đồ trong bộ** dùng chung bảng màu + **hoạ tiết nền** (cánh, lửa, băng, lông vũ, sao, vòng ngọc, bọt độc, cát xoáy, sương lạnh) vẽ sau vật | `Theme.motif` → `backdrop()` (gọi trong `aura()`) |
| E6 | **Viền tối mảnh** `#140d18`, dày 2,0 (mảnh hơn quái — giữ chất "tranh") | `render(c)` |
| E7 | **Không lặp hình trong túi**: mỗi dáng ≥ 2 biến thể, game chọn theo `item.id % 2` | `VARIANTS`, `SpriteLib.EQ_VARIANTS` |
| E8 | **Đọc được ở 44 px** (ô túi đồ): hình chính to, chi tiết < 3 px ở 128 sẽ thành nhiễu — gom thành mảng | Kiểm bằng `tui-do-trong-game.png` |
| E9 | **Có khối như tranh vẽ** (docs/42 §3.3): ánh sáng chéo trên-trái → dưới-phải, viền sáng mép đón sáng, bóng lõm mép khuất, hạt vân nhẹ, tương phản / bão hoà nhỉnh | Tự động trong `render(c)` → `paint_pass` — không tắt |
| E10 | **Quầng sáng không bao giờ vẽ chung lớp vật** (viền tối tính theo alpha sẽ bọc quầng thành đĩa nâu) | `glow_bg(c, …)` sau vật, `glow_fg(c, …)` trước vật; **không** gọi `c.glow` trực tiếp |

Đồ độc nhất (`item-<unique>`, 17 món) vẽ riêng từng món trong `tools/art/hd/equip_unique.py` (docs/42 §6): một hàm / món, kể chuyện boss rơi ra, bậc trang trí cao nhất, quầng màu theo boss (`halo`). **Đồ độc nhất mới** (thêm vào `ItemData.UNIQUES`): viết hàm mới cùng mẫu, thêm vào `BUILDERS`, `python tools/art/hd/equip_unique.py` (ảnh duyệt cũ | mới `docs/design/equipment/doc-nhat.png`) rồi `--apply`. Không đổi icon kỹ năng / nhân vật (bộ hình chủ dự án, xem memory keep-owner-art).

## 2. Chủ đề có sẵn

| Khoá | Tên | Kim loại / viền | Ngọc | orn | Hoạ tiết nền |
| --- | --- | --- | --- | --- | --- |
| white | Trắng | sắt / sắt | — | 0 | — |
| green | Xanh lá | thép / men lục | lục | 1 | — |
| blue | Xanh dương | bạc / men lam | lam | 2 | — |
| purple | Tím | thép tối / vàng | tím | 3 | — |
| orange | Cam | vàng / men đỏ | cam | 4 + hào quang | — |
| frost_hunter | Thợ Săn Sương | thép / trắng | lam băng | 3 | sương lạnh |
| phong_hanh | Phong Hành | bạc / ngọc lục | ngọc gió | 3 | lông vũ |
| u_minh | U Minh | sắt rêu / tím | lục độc | 3 | bọt độc + khói tím |
| hoa_nguc | Hoả Ngục | thép đen / vàng | cam lửa | 4 | lưỡi lửa |
| cuc_quang | Cực Quang | bạc / ngọc băng | băng | 4 | gai băng |
| thien_phong | Thiên Phong | trắng / vàng | lam trời | 4 | đôi cánh |
| tinh_quang | Tinh Quang | tím đêm / bạc | tím sao | 4 | sao + vòng |
| thien_dao | Thiên Đạo | ngọc trắng / vàng | lam | 4 | vòng ngọc |
| sa_hanh | Sa Hành Giả | vàng / ngọc lam | lam ngọc | 3 | cát xoáy |

Dáng (`FAMILIES`): `sword bow staff mace orb` (vũ khí theo `item.style` của lớp: "" = kiếm, Thợ Săn bow, Pháp Sư staff, Hộ Vệ mace, Triệu Hồi Sư orb) · `helm armor gloves boots necklace ring amulet`.

## 2b. Giao diện xem đồ (docs/42) — icon phải đẹp trong ô và thẻ thật

- Ô đồ (`godot/scripts/ui/item_card.gd` `SlotBox`, gán bằng `ItemCard.style_slot(button, item, selected)`): nền nhuộm màu phẩm chất toả từ đáy + khung theo bậc (Trắng trơn → Lục → Lam + đinh góc → Tím + nẹp góc vàng → Cam + quầng ngoài). Icon chiếm ~90% ô — icon mới phải nhìn ổn trên nền nhuộm này.
- Thẻ thông tin (`ItemCard.build`): dải đầu màu phẩm chất + icon 64 px, chỉ số chính số to + biểu tượng `stat-*`, dòng phụ có biểu tượng, bộ, so sánh dạng chip ▲ ▼. Dùng chung cho bảng chi tiết túi đồ và thẻ nổi (`item_tip`). Chỉ số mới → thêm vào `ItemCard.STAT_ICON`.

## 3. File

| File | Vai trò |
| --- | --- |
| `tools/art/hd/equip_kit.py` | Chất liệu (`IRON STEEL SILVER GOLD DARK LEATHER WOOD BONE`), `THEMES`, `gem`, `spec`, `sparkle`, `rivets`, `aura` + `backdrop` (hoạ tiết bộ), `along`, `arc`, `render` |
| `tools/art/hd/equip_icons.py` | 12 hàm dáng `(theme, variant) → Image`, `FAMILIES`, `build()`, ảnh duyệt `previews()`, `save_all()` (ghi PNG + manifest) |
| `tools/art/hd/build_hd.py` | Dựng lại toàn bộ lớp phủ HD (gọi `equip_icons.build()`) |
| `godot/scripts/view/sprite_lib.gd` | `item_icon(item)` → `eq_icon_id(item)` (dáng / biến thể / chủ đề), thiếu thì icon ô cũ |
| `godot/tests/eq_bag.gd` | Ảnh ô túi đồ thật 5 lớp, HD tắt / bật |
| `tools/art/hd/equip_unique.py` | 17 icon đồ độc nhất vẽ riêng (`BUILDERS`, `review`, `--apply`) |
| `godot/scripts/ui/item_card.gd` | Ô đồ theo bậc (`SlotBox`, `style_slot`, `icon_slot`) + thẻ thông tin (`build`) — docs/42 |

## 4. Quy trình

1. **Bộ trang bị mới** (thêm vào `ItemData.SETS`): thêm 1 `Theme` cùng khoá vào `THEMES` — chọn kim loại / viền / vải / da (`T(nền, bóng, sáng)`), màu ngọc + glow theo hệ của vùng rơi bộ đó, `orn` 3–4, `motif` (có sẵn hoặc viết nhánh mới trong `backdrop`). **Phẩm chất mới**: thêm theme + khoá vào `RARITY_KEYS`. **Kiểu vũ khí / ô mới**: viết hàm dáng mới (mẫu `sword`: `c = new()` → `aura(c, th)` → vẽ từ sau ra trước → ngọc → `render(c)`), thêm vào `FAMILIES`, đủ `VARIANTS` biến thể; cập nhật `SpriteLib.eq_icon_id` nếu cách chọn dáng đổi.
2. **Xem ảnh duyệt**: `python tools/art/hd/equip_icons.py --preview` (~1 phút) → mở `docs/design/equipment/pham-chat.png`, `bo-trang-bi.png` bằng Read. Kiểm: bậc phẩm chất phân biệt được khi nhìn lướt (E4), bộ phân biệt bằng hình chứ không chỉ màu (E5), ngọc thấy rõ, không mảng rời / lệch khung.
3. **Ghi vào game**: `python tools/art/hd/equip_icons.py` (PNG `godot/assets/hd/icons/eq-*.png` + manifest), rồi `godot --headless --path godot --import`.
4. **Kiểm trong game**: test `EQ1-T1` (`--only=EQ1`: đủ icon mọi tổ hợp, đồ độc nhất giữ icon, tắt HD về icon cũ); ảnh ô túi đồ thật `Godot_console.exe --path godot --script res://tests/eq_bag.gd -- --out=docs/design/equipment/tui-do-trong-game.png` (cần cửa sổ); ảnh smoke `05b-inventory`, `05f-shop`, `05h-forge`.
5. **Cập nhật tài liệu**: docs/40 (danh mục, trạng thái), docs/02 (file), docs/07 + docs/04 (trạng thái DH).

## 5. Mẹo

- `c.part(fn, tone, shade_d, light_d)`: `shade_d` to → mảng bóng dày (khối tròn), nhỏ (0,6–1,4) cho chi tiết.
- Ngọc / glow / văn khắc phát sáng vẽ **sau** thân vật để không bị phủ; hoạ tiết bộ vẽ **trước** (nằm sau vật), alpha 150–200.
- Đồ Trắng không ngọc (`gem=None`) và không hào quang — giữ khoảng cách bậc rõ ràng.
- 336 icon ≈ 10 MB, dựng ~1 phút; thêm 1 chủ đề = +24 icon.
