# CR-06 — Màn Chọn nhân vật kiểu ARPG cổ điển (nhân vật đứng giữa cảnh + danh sách bên phải)

| Mục | Nội dung |
| --- | --- |
| Mã | CR-06 (nối tiếp [CR-05](CR-05-hud-mo-khi-che-nhan-vat.md)) |
| Ngày | 10/11/2026 |
| Nguồn | Góp ý của người chơi 10/11 kèm ảnh màn Chọn nhân vật cũ: *"Người chơi muốn màn hình giống với màn hình chọn nhân vật của Diablo"* |
| Ảnh hưởng | SN9-02 (5 ô nhân vật, D60), UI-57 / UI-58 (docs/38 — cảnh nền + thẻ khung đồng), AR-44 (sprite 5 lớp) |
| Trạng thái | ✅ **Đã làm 10/11/2026**. Mã yêu cầu **CS-01…07** (Chọn nhân vật — Sân khấu) |
| Ảnh | [design/cr06/](design/cr06/): `cr6-chon-o3.png`, `cr6-chon-o2.png`, `cr6-chua-co.png` |

## 1. Hiện trạng (trước CR-06)

- 5 thẻ khung đồng xếp ngang giữa màn hình, mỗi thẻ có chân dung bán thân 104 px, tên, Lv · lớp, Thiên phú, thời gian chơi, 2 nút Vào game / Xoá → 10 nút giống nhau, nhìn như một bảng biểu.
- Không có cảm giác "nhân vật của mình đang đứng đó", không có nhân vật đang chọn.

## 2. Điều người chơi muốn (bố cục thể loại, không sao chép)

Màn chọn nhân vật của các ARPG cổ điển có chung một bố cục: **nhân vật đang chọn đứng to giữa cảnh**, **danh sách nhân vật dọc một bên**, **nút Chơi lớn ở giữa đáy**, nút tạo mới / xoá cạnh danh sách. CR-06 dùng bố cục này với cảnh, khung, màu, chữ **của riêng game** (Bia Đá Thiên Đạo, khung đồng FrameBox, chữ Cormorant SC vàng) — không dùng tên, logo, hình, âm thanh hay cách trình bày đặc trưng của game nào khác.

## 3. Yêu cầu

| Mã | Yêu cầu | Tiêu chí nghiệm thu |
| --- | --- | --- |
| CS-01 | Nhân vật đang chọn đứng **to giữa cảnh** (~42% chiều cao màn hình) trên bệ đá tròn trước Bia Đá Thiên Đạo, có cột sáng chiếu xuống + vòng phù văn và đốm sáng bay theo **màu hạng Thiên phú** | CR06-T1, ảnh `cr6-chon-o3.png` |
| CS-02 | Đổi nhân vật → hình hiện dần (~0,35 giây) và múa một đòn đánh thường rồi đứng thở (idle) | đọc code `HeroStage`, chạy thật |
| CS-03 | Trên đầu nhân vật: tên lớn chữ cổ vàng, `Lv · lớp (theo chuyển chức)`, `Thiên phú hạng · tên` (màu hạng), `Vùng N · tên vùng · Đã chơi X giờ Y phút` | CR06-T1 |
| CS-04 | Danh sách 5 ô **dọc bên phải** trong khung đồng: chân dung nhỏ + tên + Lv · lớp + Thiên phú; dòng đang chọn sáng viền vàng; ô trống "+ Ô trống — Tạo nhân vật mới" (bấm = tạo mới) | CR06-T1 |
| CS-05 | Bấm 1 dòng = **chọn** (chưa vào game); **nhấp đúp** = vào game; nút **Vào game** lớn giữa đáy dưới chân nhân vật; "Tạo nhân vật mới" + "Xoá" ở đáy danh sách (Xoá vẫn hỏi gõ lại tên — Q154); "Quay lại" góc trái dưới | CR06-T1 |
| CS-06 | Phím: ↑ ↓ (← →) đổi nhân vật (bỏ qua ô trống, vòng quanh), Enter vào game, Esc quay lại, Delete xoá | CR06-T1 (`step`), chạy thật |
| CS-07 | Mở màn → chọn sẵn **nhân vật chơi gần nhất**; chưa có nhân vật → bệ trống, "Vào game" / "Xoá" tắt; đủ 5 → "Tạo nhân vật mới" tắt (có chú thích) | CR06-T1, ảnh `cr6-chua-co.png` |

| CS-08 | **(CR-06b, góp ý người chơi 10/11)** Mở game → đã có nhân vật thì **màn đầu tiên là màn Chọn nhân vật**, nhân vật chơi cuối hiện sẵn giữa cảnh để bấm Vào game ngay, hoặc chọn nhân vật khác / tạo mới. Chưa có nhân vật nào → màn tiêu đề "Hành trình mới" như cũ. "Về màn hình chính" trong menu Tạm dừng cũng về màn Chọn nhân vật | CR06-T1 (đọc `main.gd` `_go_home`), chạy thật |
| CS-09 | Vì là màn đầu: góc trái dưới có **Màn tiêu đề** (thay "Quay lại"), **Cài đặt**, **Thoát game**; khi bảng Cài đặt đang mở đè lên thì màn chọn không nhận phím | CR06-T1, ảnh `cr6-chon-o3.png` |

## 4. Cách làm

| Chỗ | Thay đổi |
| --- | --- |
| `scripts/ui/char_select.gd` (mới) | `extends ColorRect`. Lớp con `HeroStage` vẽ bệ / cột sáng / vòng phù văn / nhân vật / đốm sáng (`_draw`, lọc Nearest). Hằng `HERO_X` 0.42, `FEET_Y` 0.79, `HERO_H` 0.42, `LIST_W` 372. `select(n)`, `step(dir)`, `region_name(map_id)`, `_unhandled_key_input`. Tên node cho test: `HeroName`, `SlotList`, `Slot_<n>`, `PlayButton`, `NewButton`, `DeleteButton`, `BackButton` |
| `scripts/ui/screens.gd` | `slots(..., selected := 0)` trả về `CharSelect` (giữ chữ ký cũ + tham số ô chọn sẵn); `Backdrop.stele_x` (mặc định 0.5) — màn chọn đặt 0.42 để Bia Đá đứng ngay sau nhân vật |
| `scripts/main.gd` | `_open_slots()` truyền `SaveSystem.last_slot()`, `_open_settings`, thoát game. CR-06b: `_go_home()` = `_go_title()` rồi `_open_slots()` nếu `SaveSystem.any_save()` — gọi khi mở game (`_ready`) và "Về màn hình chính" ở menu Tạm dừng; smoke test vẫn gọi `_go_title()` |
| `scripts/core/save_system.gd` | `slot_summary` thêm `look`, `map_id` (không đổi save, không tăng version) |
| `tools/art/class_sheet.py` | `build_pcx()`: cắt thêm **`pcx-<lớp>`** (idle + attack) ở **độ phân giải gốc của sheet** (không thu 0,62 như `pc-`), cùng thuật toán tách nền; `build_all.py` cũng gọi. Không vẽ lại, không đè `pc-*` (keep-owner-art) |
| Vẽ nhân vật | `HeroStage.stage_sprite`: nhân vật kiểu "Hình lớp" → `pcx-<lớp>`; kiểu ngoại hình ghép → đúng sprite trong game (`draw_hero`, có tóc). `size_mul_for` làm tròn để 1 pixel ảnh = số nguyên pixel màn hình (×4 ở 1366×768) → nét đều |

## 5. Kết quả triển khai (10/11/2026; CS-08…09 làm cùng ngày theo góp ý thứ hai)

- Test **CR06-T1** (chọn sẵn ô gần nhất, sân khấu đúng lớp + dùng `pcx-`, bấm dòng chỉ chọn, Vào game / Xoá theo ô chọn, nhấp đúp vào game, ↑ ↓ bỏ ô trống, ô trống → tạo mới, tên vùng, màn trống / màn đủ 5, đủ 5 sprite `pcx-`); SN9-T2 thêm kiểm `look` / `map_id` trong tóm tắt. Đã chạy lại SN9, AR-44, UI38, UI40 — qua.
- Công cụ chụp `godot/tests/cr6_shot.gd -- --dir=<thư mục>` (cần cửa sổ) → 3 ảnh ở `design/cr06/`.
- Bản đầu vẽ bằng `pc-` (50 px, đã thu nhỏ) phóng ×4 → vỡ hình, nên thêm bộ `pcx-` cắt ở độ phân giải gốc.

### Còn để ngỏ (không chặn)

- **Q237**: hình to giữa cảnh là pixel art của sheet phóng ×4 — nếu chủ dự án muốn mượt hơn (tranh vẽ tay toàn thân từng lớp, kiểu tranh chân dung), cần chủ dự án cung cấp / duyệt hình mới (không tự vẽ lại nhân vật).
- Hình Hộ Vệ trên sheet gốc nhiều vệt sáng nên khi phóng to hơi rối; có thể chọn frame idle khác nếu cần.
- Chưa có nhạc / âm thanh riêng khi đổi nhân vật (dùng nhạc màn tiêu đề).
