# 43. Thiết kế lại hiệu ứng đồ cường hoá (EN-1)

| Mục | Nội dung |
| --- | --- |
| Ngày | 06/11/2026 |
| Yêu cầu | [Spec_Notes](Spec_Notes.md): *"Hiệu ứng đồ sau khi được nâng cấp → Người chơi đánh giá nó xấu quá, không giống như game hiện đại bây giờ → cần nghiên cứu và design lại."* Chủ dự án: đề xuất vài hướng để duyệt trước rồi mới làm thử. |
| Ảnh | [design/enhance/](design/enhance/): `hien-trang-o-do.png` (hiện trạng), `de-xuat-o-do.png` (ảnh mẫu các hướng), `huong-d.gif` (ảnh động hướng D đã chọn); trong game: `o-do-trong-game.png`, `toast-dot-pha.png`, `hao-quang-13.png` |
| Trạng thái | ✅ Đã làm và có trong game (06/11/2026): hướng **D** + vệt sáng chạy quanh viền, kèm E1–E3 — §6 |

## 1. Hiện trạng

Bậc cường hoá: +4–6 / +7–9 / +10–12 / +13–15 (`Items.enhance_tier` 1–4, màu lam / tím / vàng / đỏ).

| Chỗ | Code | Vấn đề |
| --- | --- | --- |
| Ô đồ (túi, đang mặc, Lò Rèn) | `inventory_panel.gd` `PlusGlow` | Thêm 1–4 khung chữ nhật nháy **đè lên khung phẩm chất**. Màu bậc trùng thang phẩm chất, nên đồ Tím +4 trông như đồ Lam. Chấm tròn bay quanh trông như bụi hoặc lỗi, ở +13 chấm đỏ trông như "bệnh". Bản thân món đồ không đổi gì. |
| Nhân vật ngoài bản đồ | `world_view.gd` (N8) | Vũ khí +4 trở lên vẽ một đĩa màu mờ và vài chấm xoay quanh. Đơn giản, không gắn với vũ khí. |
| Lúc cường hoá | `enhance_toast.gd` (SN10-01) | Khung chữ, vòng sáng và tia toả ra. Mọi cấp giống nhau, không có hình món đồ, các mốc +10 / +13 / +15 không có gì khác. |

## 2. Game hiện đại làm thế nào

- **Hiệu ứng nằm trên chính món đồ, không nằm trên khung.** Lineage, MU, Black Desert: vũ khí cấp cao toả sáng hoặc bốc lửa theo dáng vũ khí. Khung ô vẫn dành riêng cho phẩm chất.
- **Mốc rõ ràng.** Mỗi mốc là một bước nhảy thị giác. Cấp cuối (+13 trở lên) phải khác hẳn để người chơi muốn đạt.
- **Chuyển động sang trọng:** vệt sáng lướt định kỳ, sao lấp lánh thưa. Tránh nháy liên tục.
- **Số cấp đọc ngay:** "+N" trên tấm nhỏ, có tương phản.

## 3. Các hướng (ảnh `de-xuat-o-do.png`)

Cả bốn hướng đều thống nhất mấy điểm sau:

- Khung ô để nguyên cho phẩm chất.
- "+N" đặt trên tấm nhỏ ở góc dưới phải.
- Đổi bảng màu bậc thành **bạc → lam băng → vàng kim → huyết hồng** cho bớt trùng thang phẩm chất.

| Hướng | Mô tả | Ưu | Nhược |
| --- | --- | --- | --- |
| **A. Ánh kim** | Viền sáng bám theo dáng món đồ, dày dần theo bậc. Vệt sáng trắng lướt chéo vài giây một lần. Có sao lấp lánh. Từ +10 có quầng sáng sau món. +15 có viền ánh cầu vồng. | Sang, sạch, đọc rõ ở ô 44 px | Ở +13 / +15 chưa đủ "bùng nổ" |
| **B. Linh hoả** | Ngọn lửa linh khí bốc lên từ chính món đồ, cao dần theo bậc, có tàn lửa bay. | Rất "game châu Á", ấn tượng | Rối mắt khi cả túi toàn đồ cường hoá; từ +4 đã có lửa nên các mốc ít khác nhau |
| **D. A + B** *(đề xuất)* | Dùng A cho +4…+12. Từ +13 món đồ bốc linh hoả. | Mốc cuối khác hẳn; túi đồ vẫn gọn | Tốn công làm hai kiểu |
| **C. Ấn bậc tối giản** | Không phủ hiệu ứng lên hình. Thêm 5 sao trên đỉnh ô (3 cấp = 1 sao) và đá khảm ở góc. | Gọn nhất | Không "đẹp lên", không đúng ý "game hiện đại" |

### Phần đi kèm (áp dụng cho hướng được chọn)

| # | Chỗ | Đề xuất |
| --- | --- | --- |
| E1 | Nhân vật ngoài bản đồ | Bỏ đĩa màu và chấm xoay. Thay bằng vòng ấn mờ dưới chân, xoay chậm, màu bậc. Thêm hạt sáng bốc lên từ người. Từ +13: vệt chém hoặc đạn mang màu bậc. Hình nhân vật giữ nguyên (không vẽ lại). |
| E2 | Lúc cường hoá thành công | Icon món đồ to ở giữa. Vệt sáng lướt qua icon. Số chạy "+9 → +10". Các mốc +4 / +7 / +10 / +13 / +15 có cột sáng, tiêu đề riêng (ví dụ "ĐỘT PHÁ +10") và rung nhẹ màn hình. |
| E3 | Lúc cường hoá thất bại | Icon rung, vệt nứt xám. Giữ ngắn để không gây khó chịu. |

## 4. Câu hỏi

| Mã | Câu hỏi | Đề xuất |
| --- | --- | --- |
| Q204 | Chọn hướng hiệu ứng trên ô đồ: A / B / C / D? | ✅ D, thêm lấp lánh / vệt sáng chạy quanh viền ô theo chiều kim đồng hồ (06/11) — §5 |
| Q205 | Làm luôn phần đi kèm E1 (nhân vật), E2 / E3 (lúc cường hoá)? | ✅ Chủ dự án duyệt GIF: "ok rồi, triển khai luôn nhé" (06/11) → làm cả ba, §6 |

## 5. Hướng D đã chọn: ảnh động duyệt (06/11/2026)

Chủ dự án: *"anh chọn cấp D, nhưng thêm hiệu ứng lấp lánh hoặc hiệu ứng sáng chạy vòng quanh border ô vuông theo chiều kim đồng hồ → làm 1 ảnh gif động trước để anh duyệt"*. Ảnh: [huong-d.gif](design/enhance/huong-d.gif) (vòng lặp khoảng 2 giây).

| Bậc | Trên món đồ | Quanh viền ô |
| --- | --- | --- |
| +1…+3 | không có | không có (chỉ hiện tấm "+N") |
| +4…+6 (bạc) | viền sáng mảnh theo dáng món, sáng lên tối xuống | 1 vệt sáng kiểu sao chổi chạy theo chiều kim đồng hồ, 1 vòng / 2 giây |
| +7…+9 (lam băng) | viền dày hơn và 2 sao lấp lánh | như trên |
| +10…+12 (vàng kim) | thêm quầng sáng sau món và 3–4 sao | 2 vệt đối nhau |
| +13…+15 (huyết hồng) | linh hoả bốc lên và tàn lửa bay; +15 thêm viền cầu vồng xoay | 2 vệt chạy nhanh gấp đôi |

Mọi bậc từ +4: vệt sáng trắng lướt chéo qua món đồ một lần mỗi vòng lặp. Đầu mỗi vệt chạy viền có một sao nhỏ. Khung ô vẫn giữ màu phẩm chất; vệt chạy viền mang màu bậc cường hoá.

Công cụ dựng ảnh mẫu: `tools/art/enhance/enh_mock.py` (ảnh tĩnh các hướng), `enh_gif.py` (GIF hướng D).

## 6. Đã làm trong game (06/11/2026)

Chủ dự án duyệt GIF: *"ok rồi, triển khai luôn nhé"*.

| # | Phần | Code | Mô tả |
| --- | --- | --- | --- |
| EN-1a | Bảng màu bậc | `core/items.gd` `ENHANCE_TIER_HEX` | Bạc `#cde4ff` / lam băng `#5ad2ff` / vàng kim `#ffce50` / huyết hồng `#ff4660`; dùng chung cho ô đồ, toast, Lò Rèn, hào quang. |
| EN-1b | Hiệu ứng ô đồ | `ui/enhance_fx.gd` (`EnhanceFx.attach(host, item, tex, inset, radius)`) | Thay `PlusGlow`. Con `Glow` (show_behind_parent) dùng shader cộng sáng đọc alpha của icon (uniform `icon_tex`) để vẽ viền sáng theo dáng, quầng (+10), lửa (+13), vệt lướt chéo, viền cầu vồng (+15). Node chính vẽ vệt sao chổi quanh viền theo chiều kim đồng hồ (`perimeter_point`), sao lấp lánh ở điểm đặc của icon (cache theo texture), tàn lửa (+13) và tấm "+N". Gắn ở: ô túi đồ / đang mặc (`inventory_panel._item_button`), Lò Rèn (ô danh sách + icon lớn), icon 64 px trong thẻ thông tin (`ItemCard.icon_slot`, tắt tấm số vì tên món đã có "+N"). |
| EN-1c (E1) | Nhân vật ngoài bản đồ | `view/world_view.gd` `_enhance_aura` | Vòng ấn dẹt dưới chân: 4–10 vạch cung + hình thoi, xoay chậm, thở nhẹ; hạt sáng bốc lên từ chân. +13 có thêm vòng trong xoay ngược, và mép vệt chém (Kiếm Khách) mang màu bậc + viền trắng. |
| EN-1d (E2/E3) | Lúc cường hoá | `ui/enhance_toast.gd` (`pop(..., tex)`) | Icon món đồ 96 px ở giữa, phóng nhẹ rồi về cỡ, đã mang `EnhanceFx` của cấp mới; số chạy "+N−1 → +N". Mốc +4 / +7 / +10 / +13 tiêu đề "ĐỘT PHÁ +N", +15 "TUYỆT PHẨM +15": loé màn hình, cột sáng, giữ 2,6 giây (thường 1,8). Thất bại: icon xám rung, vết nứt gãy khúc, "Mất nguyên liệu · món đồ vẫn +N". |

Kiểm tra:

- Test **EN1-T1** (mới): bảng màu; +3 không có lớp sáng; +7 có shader; +15 bậc 4 + cầu vồng; không chặn chuột; vệt viền đi theo chiều kim đồng hồ và hết vòng về điểm đầu; icon rect khớp lề SlotBox; ô túi đồ có `EnhanceFx`; `PlusGlow` đã bỏ.
- **SN10-T1** (mở rộng): mốc +10 giữ lâu hơn, +8 không phải mốc; icon toast thành công có `EnhanceFx`, thất bại không. **EQ1-T1**, **SN11** vẫn qua.
- Ảnh thật:
  - [o-do-trong-game.png](design/enhance/o-do-trong-game.png) (`godot/tests/enh_now.gd`, ô 64 px và 44 px);
  - [toast-dot-pha.png](design/enhance/toast-dot-pha.png) (smoke `05c-inventory-equipped`);
  - [hao-quang-13.png](design/enhance/hao-quang-13.png) (smoke `05c3-enhance-aura`, mới).
- Smoke: 82 ảnh, không có SCRIPT ERROR / SHADER ERROR.
