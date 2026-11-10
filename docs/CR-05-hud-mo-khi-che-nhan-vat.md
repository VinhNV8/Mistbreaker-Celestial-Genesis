# CR-05 — Bản đồ nhỏ / khung nhiệm vụ mờ đi khi che nhân vật + nút ẩn / hiện

| Mục | Nội dung |
| --- | --- |
| Mã | CR-05 (nối tiếp [CR-04](CR-04-ban-do-tu-tui-va-tu-dong-ban.md)) |
| Ngày | 09/11/2026 |
| Nguồn | Spec_Notes 09/11: *"Bản đồ nhỏ và Bảng nhiệm vụ nhỏ góc bên phải — khi nhân vật đi vào mép bản đồ thì chỗ đó che mất nhân vật → khi đi vào thì 2 chỗ đó mờ đi để nhìn rõ khung cảnh, nhân vật bên dưới; khi không đi vào thì vẫn như hiện tại. Ngoài ra muốn có icon ẩn / hiện bảng nhiệm vụ hoặc bản đồ nhỏ."* |
| Ảnh hưởng | HUD góc phải trên (UI-41 la bàn, UI-16 / UI-41 khung nhiệm vụ), R1 (docs/19 — mờ khi đánh boss), PF-01 `DrawLayer` |
| Trạng thái | ✅ **Đã làm 09/11/2026** ("triển khai tiếp các CR trong Spec_Notes"). Mã yêu cầu **HM-01…05** (HUD Mờ) |
| Ảnh | [design/cr05/](design/cr05/): `cr5-binh-thuong.png`, `cr5-duoi-ban-do.png`, `cr5-duoi-nhiem-vu.png`, `cr5-an-ca-hai.png` (khối hồng = chỗ nhân vật) |

## 1. Hiện trạng

- Cột phải HUD: la bàn (bản đồ nhỏ, ~224 × 238 px + dòng tên vùng) và khung nhiệm vụ cuộn giấy (240 px rộng, cao 200–260 px) — chiếm ~18% bề ngang, ~65% chiều cao bên phải màn hình.
- Camera bị giới hạn ở mép bản đồ (`limit_*`), nên khi nhân vật đi sát mép đông / bắc, nó **không còn ở giữa màn hình** mà trượt vào góc phải trên — đúng chỗ 2 khung này đứng, đều đục 100%.
- Đã có mờ khi đánh boss (R1: bản đồ 0.35, nhiệm vụ 0.7) nhưng chỉ theo trạng thái boss, không theo vị trí nhân vật.
- Không có cách tắt 2 khung (chỉ thu gọn khung nhiệm vụ bằng chuột phải — VS-1 A3; V đổi cỡ la bàn).

## 2. Yêu cầu

| Mã | Yêu cầu | Tiêu chí nghiệm thu |
| --- | --- | --- |
| HM-01 | Nhân vật đi vào dưới (hoặc sát trong 12 px) bản đồ nhỏ / khung nhiệm vụ → **khung đó** mờ dần còn 22% (~0,2 giây); đi ra → hiện lại như cũ. Hai khung xét riêng (đứng dưới la bàn thì khung nhiệm vụ vẫn rõ). | CR05-T1 |
| HM-02 | Rê chuột vào khung đang mờ → hiện rõ ngay để đọc / bấm (bấm la bàn để tự chạy, bấm khung nhiệm vụ để dẫn đường vẫn dùng được). | CR05-T1 (`occlusion_alpha` hovered) |
| HM-03 | Giữ quy tắc R1: đang đánh boss thì khung vẫn mờ sẵn (0.35 / 0.7); khi che nhân vật lấy mức mờ hơn. | CR05-T1 |
| HM-04 | 2 nút tròn nhỏ (biểu tượng tấm bản đồ / cuộn giấy), **mỗi nút gắn ở góc trên-trái khung của nó** (la bàn; cuộn giấy nhiệm vụ ngang hàng tiêu đề) và mờ theo khung: bấm để ẩn / hiện bản đồ nhỏ, khung nhiệm vụ. Nhớ trong Cài đặt (`hud_minimap`, `hud_quest`, mặc định hiện). Khung đang tắt: nút đứng đúng chỗ khung đó ở sát mép phải, biểu tượng nhạt + gạch chéo đỏ; bản đồ ẩn thì khung nhiệm vụ lên ngay dưới nút bản đồ. *(Bản đầu xếp 2 nút chung một cột trái la bàn — góp ý 09/11: "2 icon cách xa nhau, không gắn với vật thể chính" → đổi như trên.)* | CR05-T1, ảnh `cr5-an-ca-hai.png` |
| HM-05 | Phím V khi bản đồ nhỏ đang ẩn → hiện lại (không đổi cỡ). | đọc code `toggle_minimap` |

## 3. Cách làm

| Chỗ | Thay đổi |
| --- | --- |
| `main.gd` `_player_screen_rect()` | Mỗi khung: khung bao nhân vật `PLAYER_BOX = Rect2(-30, -96, 60, 108)` quanh chân (thân + đầu + vũ khí), đổi sang toạ độ màn hình qua `_view.get_canvas_transform()` (có zoom camera VS-1); bật nghiêng phối cảnh (GN-1) thì 2 góc đổi qua `Tilt.dst_uv`. Gán `hud.focus_rect` trước `hud.update_from`. |
| `hud.gd` | `occlusion_alpha(box, focus, hovered, base)` (tĩnh, test được): chuột trên khung → 1; khung (nới `OCCLUDE_PAD` 12 px) cắt khung nhân vật → `min(base, OCCLUDE_A 0.22)`; còn lại → `base` (R1). `_apply_fade()` sau `_layout()`: hộp la bàn = la bàn ∪ dòng tên vùng; alpha tiến dần `FADE_SPEED` 5/giây (`move_toward`). Thay chỗ R1 cũ đặt `modulate.a` trực tiếp. |
| `hud.gd` `HudToggle` | Lớp nút tròn vẽ bằng `_draw` (nền tối, viền đồng sáng khi rê chuột, biểu tượng bản đồ gấp 3 / cuộn giấy), `pressed` → `Settings.set_value`. `update_from` đặt `visible` của la bàn, dòng tên vùng, khung nhiệm vụ theo Cài đặt; `_layout` đặt nút ở góc khung (`la bàn + (2, 2)`, `khung nhiệm vụ + QUEST_BTN_AT (8, 10)`) hoặc sát mép phải khi khung ẩn; `_apply_fade` cho nút mờ theo khung. |
| `draw_layer.gd` | **Sửa kèm**: lớp nướng (vành la bàn) trộn premultiplied nên `modulate` của cha chỉ giảm alpha mà không giảm màu → vành **không mờ** theo bản đồ (lỗi có sẵn từ R1). Nay vẽ ảnh với màu nhân `(a, a, a, 1)`, `a` = tích `modulate.a` các node cha (`inherited_alpha()`); `_process` vẽ lại ảnh (1 draw call) khi `a` đổi. |
| `settings.gd` | Thêm `hud_minimap`, `hud_quest` = true. |

Không đổi save game (cài đặt nằm ở `user://settings.cfg`).

## 4. Kết quả triển khai (09/11/2026)

- Test **CR05-T1**: `occlusion_alpha` (dưới khung / sát mép / xa / rê chuột / giữ mờ boss / chưa có nhân vật), mặc định Cài đặt, HUD thật: đứng dưới la bàn → la bàn mờ, khung nhiệm vụ giữ; đi xuống khung nhiệm vụ → đảo lại; tắt 2 khung → ẩn hẳn, nút còn, nút về góc phải.
- Công cụ chụp `godot/tests/cr5_shot.gd` (`-- --dir=<thư mục>`, cần cửa sổ) → 4 ảnh ở `design/cr05/`.
- Ảnh `cr5-duoi-ban-do.png`: la bàn kể cả vành đồng mờ còn ~22%, thấy rõ nhân vật bên dưới; `cr5-duoi-nhiem-vu.png`: cuộn giấy mờ, la bàn rõ.

### Còn để ngỏ (không chặn)

- Chỉ xét **nhân vật**; quái / boss đứng dưới khung không làm mờ (tránh khung nhấp nháy liên tục khi đông quái). Nếu người chơi vẫn thấy vướng, mở rộng sang mục tiêu đang đánh.
- Các khung khác (thanh tài nguyên giữa trên, khung nhân vật trái trên, nhật ký trái dưới) chưa áp dụng — cùng hàm `occlusion_alpha` dùng lại được.
