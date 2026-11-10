# 44. Tỷ lệ khung nhìn khi toàn màn hình + chiều sâu bản đồ (VS-1)

| Mục | Nội dung |
| --- | --- |
| Ngày | 06/11/2026 |
| Yêu cầu | Phản ánh người chơi: *"Mở game ở khung nhỏ thì nhìn còn hợp lý, nhưng phóng to toàn màn hình thì cảm giác hơi to, mọi thứ chiếm nhiều quá, và chưa thấy có chiều sâu khi nhìn vào map."* |
| Ảnh | [design/view-scale/](design/view-scale/): `hien-trang-1366.png`, `hien-trang-1920.png` (hiện trạng), `thu-zoom-0.8-1920.png`, `thu-zoom-0.71-1920.png` (chạy thử thật trong game, đã hoàn tác code); sau khi làm: `sau-vs1-1366.png`, `sau-vs1-1920.png`, `sau-b4b5-1920.png`, `sau-b4b5-cac-vung.png` (sa mạc / núi lửa / băng / Hư Vô) |
| Trạng thái | ✅ Đã làm nhóm A + B1–B5 (06/11/2026, chủ dự án duyệt "theo đề xuất" Q206–Q210) — §6. B6 (cao độ địa hình) chưa làm. 08/11: sửa "giật + vệt mờ phía trên" (PF-02) — §7 |

## 1. Nguyên nhân "to quá khi toàn màn hình"

`project.godot`: khung gốc **1366×768**, `stretch/mode = canvas_items`, `aspect = expand`. Camera thế giới `zoom = 1` (`main.gd`).

Như vậy khi cửa sổ lớn lên, Godot **phóng to toàn bộ** (cả bản đồ lẫn HUD) theo cùng hệ số:

| Màn hình | Hệ số phóng | Nhân vật (32 px × 2) cao | Vùng bản đồ nhìn thấy |
| --- | --- | --- | --- |
| 1366×768 (cửa sổ) | ×1,00 | 64 px | 1366×768 px thế giới |
| 1920×1080 | ×1,41 | 90 px | **vẫn 1366×768** |
| 2560×1440 | ×1,87 | 120 px | **vẫn 1366×768** |

→ Màn hình to hơn **không cho thấy thêm map**, chỉ kéo phóng hình. Người chơi quen game PC hiện đại kỳ vọng ngược lại: màn hình to = thấy rộng hơn, HUD giữ cỡ vừa đọc. Thêm vào đó:

- Ảnh pixel (lọc Nearest) phóng ×1,41 là **hệ số lẻ** nên các điểm ảnh to nhỏ không đều, nhìn "thô".
- HUD (khung nhân vật, hộp nhật ký trái, hộp nhiệm vụ phải, thanh kỹ năng, cụm nút) phóng cùng hệ số, chiếm phần lớn bốn góc và cạnh dưới màn hình (ước chừng 1/3 diện tích) ở ảnh `hien-trang-1920.png`.

## 2. Nguyên nhân "chưa có chiều sâu"

Xem `hien-trang-1920.png`:

| # | Vấn đề | Chỗ trong code |
| --- | --- | --- |
| S1 | Nền đất một màu xanh phẳng; mảng loang (`_patches`) nhỏ và mờ, không có vùng sáng / tối lớn | `world_view.gd` `_draw_ground` |
| S2 | Không có hướng sáng chung: cây, nhà, quái chỉ có vòng tròn dưới chân, **không có bóng đổ** về một phía | `_draw_tree_sprite`, `_draw_enemy_sprite`, `_ground_ring` |
| S3 | Không có lớp tiền cảnh (tán lá, cỏ cao che mép màn hình) và không có không khí xa (sương, ánh sáng) | — |
| S4 | Nền và vật thể cùng độ bão hoà / độ sáng nên nhân vật, quái không "nổi" khỏi nền | bảng màu tile + sprite |
| S5 | Địa hình không có cao độ: không có vách, bậc, nước, đường dốc | dữ liệu map |

Đã có sẵn: sắp xếp vẽ theo trục Y (`_draw_sorted`), làm mờ cây che nhân vật, vignette viền (`main.gd`). Những thứ này đúng, nhưng chưa đủ tạo cảm giác 3 chiều.

## 3. Đề xuất

### 3.1. Nhóm A — Tỷ lệ khung nhìn (sửa nguyên nhân chính, ít việc, hiệu quả lớn)

**A1. Tầm nhìn theo độ phân giải.** Camera thế giới tự `zoom` ra khi màn hình lớn, để nhân vật giữ cỡ khoảng **7–7,5% chiều cao màn hình** thay vì 8,3%, và nhìn thấy thêm map.

```
s = chiều cao cửa sổ / 768        # hệ số Godot đang phóng
zoom = clamp(1 / s ^ 0.6, 0.65, 1.0) × hệ số "Tầm nhìn" người chọn
```

| Màn hình | zoom tự động | Nhân vật cao | Vùng map nhìn thấy |
| --- | --- | --- | --- |
| 1366×768 | 1,00 | 64 px | như cũ |
| 1920×1080 | ≈ 0,81 | ≈ 73 px | ≈ ×1,5 diện tích |
| 2560×1440 | ≈ 0,69 | ≈ 83 px | ≈ ×2,1 diện tích |

Ảnh `thu-zoom-0.8-1920.png` là bản chạy thử thật với zoom 0,8 ở 1920×1080: thấy trọn làng + bãi quái, hình gọn hơn rõ.

Thêm mục **Cài đặt → Hiển thị → Tầm nhìn: Gần / Vừa (mặc định) / Xa** (×1,1 / ×1,0 / ×0,88) cho người thích nhìn to hoặc nhìn rộng.

Việc kéo theo khi đổi zoom (đã thấy trong bản chạy thử):

- `world_view._view_rect()` phải chia cho `camera.zoom`, nếu không phần ngoài khung bị cắt khi vẽ (PF-01).
- Chữ vẽ trong thế giới (tên nhân vật, tên NPC, số sát thương, "12 m") nhỏ đi theo zoom → nhân cỡ chữ với `1 / zoom` để giữ cỡ đọc được.
- Kiểm tra lại các chỗ tính theo khung màn hình: quái sinh ngoài màn hình, sương mù chiến tranh, mũi tên chỉ đường mép màn hình, rung camera, tia cảnh báo đòn đánh ngoài màn hình.
- Hiệu năng: khung nhìn rộng ≈ ×1,5–2 diện tích → nhiều quái / cây vẽ hơn. Cần đo lại FPS ở map ×3 đông quái.

**A2. Tách cỡ HUD khỏi cỡ màn hình.** Thêm **Cài đặt → Cỡ giao diện: 80 / 90 / 100 / 110%**. Mặc định tự động: 100% ở ≤ 900 px chiều cao, 90% ở 1080p, 85% ở 1440p trở lên. Làm bằng `CanvasLayer.scale` của lớp UI (không đụng lớp thế giới). Cỡ chữ (M5-05) vẫn chỉnh riêng như cũ.

**A3. HUD gọn hơn khi toàn màn hình** (nhẹ, làm kèm A2):

- Hộp nhật ký trái: tự mờ dần sau 6 giây không có dòng mới, chỉ giữ 3 dòng gần nhất.
- Hộp nhiệm vụ phải: thu gọn còn 1 dòng (tên bước + khoảng cách), bấm để mở rộng.

**A4. (Tuỳ chọn) Pixel sắc nét.** Với kiểu art pixel cũ (khi người chơi tắt HD), làm tròn zoom để `2 × s × zoom` ra số nguyên hoặc nửa nguyên → điểm ảnh đều nhau. Art HD (mặc định) không cần.

### 3.2. Nhóm B — Chiều sâu bản đồ

Thứ tự theo hiệu quả trên công sức:

| # | Đề xuất | Cách làm | Công |
| --- | --- | --- | --- |
| **B1** | **Bóng đổ theo một hướng sáng** (sáng từ trên-trái, bóng đổ xuống dưới-phải) cho cây, nhà, đá, quái, nhân vật, NPC | 1 texture elip mềm (giống `_soft_blob`), vẽ lệch + kéo xiên dưới chân trong `_draw_sorted` trước khi vẽ vật. Cây / nhà bóng dài, quái / người bóng ngắn. Vẽ gộp được, rẻ. | Nhỏ |
| **B2** | **Ánh sáng nền tầng lớn**: mảng sáng nắng rọi + vùng tối dưới tán rừng, đường kính 300–800 px; tối nhẹ quanh gốc cây (đọng bóng) | Mở rộng `_patches` thành 2 cỡ (lớn + nhỏ), thêm lớp "đọng bóng" dưới cụm cây | Nhỏ |
| **B3** | **Phân tầng độ sáng / bão hoà**: hạ nền đất 10–15% độ bão hoà và độ sáng; nhân vật, quái giữ màu + viền sáng mảnh phía hướng sáng | Hệ số `modulate` cho lớp nền theo vùng; viền sáng trong `SpriteLib.draw_frame` (tuỳ chọn) | Nhỏ |
| **B4** | **Không khí xa**: dải sương mờ ở mép trên màn hình (phía "xa" trong góc nhìn 3/4), hạt sương / lá bay chậm, tia nắng xiên mờ ở map rừng | Lớp CanvasLayer giữa thế giới và HUD (cạnh vignette), gradient + vài hạt. Hợp tên vùng "Rừng Sương". | Vừa |
| **B5** | **Tiền cảnh thị sai**: tán lá, cành, cỏ cao bán trong suốt ở mép màn hình, trôi nhanh hơn nền ~1,15 lần khi camera di chuyển | Lớp `Parallax2D` phía trên thế giới, chỉ vẽ ở 4 mép (không che vùng chiến đấu giữa màn hình). Mỗi vùng 1 bộ hình (rừng / sa mạc / băng…). | Vừa |
| **B6** | **Cao độ địa hình**: vách đá có mặt đứng, bậc, mép nước có bờ, cầu | Cần art mới + va chạm; làm theo từng map | Lớn — để sau |

## 4. Kế hoạch đề xuất

| Đợt | Nội dung | Ghi chú |
| --- | --- | --- |
| VS-1a | A1 + A2 (+ A3) | Sửa đúng lời phản ánh "to quá". Cần test: culling, chữ thế giới, sinh quái, FPS. |
| VS-1b | B1 + B2 + B3 | Chiều sâu rõ ngay, không cần art mới ngoài texture bóng. |
| VS-1c | B4 + B5 | Mỗi vùng 1 bộ hình tiền cảnh / không khí (dùng skill game-art). |
| Sau | B6 | Đưa vào lúc làm lại map. |

Sau mỗi đợt: chụp lại `design/view-scale/` ở 1366×768 và 1920×1080 để so.

## 5. Câu hỏi chờ duyệt

| ID | Câu hỏi | Mặc định đề xuất |
| --- | --- | --- |
| Q206 | Zoom tự động theo độ phân giải: mức nào ở 1080p? | **≈ 0,8** (ảnh `thu-zoom-0.8-1920.png`). 0,71 (ảnh `thu-zoom-0.71-1920.png`) nhìn rộng hơn nhưng nhân vật hơi nhỏ. |
| Q207 | Có cho người chơi chỉnh "Tầm nhìn" Gần / Vừa / Xa không? Có giới hạn để PvE không bị lợi thế quá (thấy quái xa)? | Có, 3 mức, Xa tối đa ×0,88 |
| Q208 | Cỡ HUD mặc định ở 1080p | 90%, có mục chỉnh 80–110% |
| Q209 | Làm những mục chiều sâu nào trong đợt đầu? | B1 + B2 + B3 |
| Q210 | Tiền cảnh thị sai (B5) có chấp nhận che nhẹ mép màn hình không? | Có, chỉ ở mép, độ đục ≤ 60%, tự mờ khi có quái ở dưới |

Đã trả lời 06/11/2026: "triển khai như đề xuất" → mọi câu theo cột mặc định.

## 6. Đã làm (06/11/2026)

| Mục | Kết quả | Code |
| --- | --- | --- |
| A1 | Camera zoom ra theo độ phân giải: 1366×768 zoom 1 (như cũ), 1080p ≈ 0,81 (nhân vật ≈ 73 px), 1440p ≈ 0,69. Cài đặt → Hiển thị → **Tầm nhìn** Gần ×1,1 / Vừa / Xa ×0,88. Chữ trên bản đồ (tên, số sát thương, bảng tên quái, bảng cổng, chỉ đường "12 m") giữ cỡ đọc được. | `core/view_scale.gd`, `main._apply_view_scale`, `world_view._view_rect` / `_label`, `quest_view._text` |
| A2 | **Cỡ giao diện** Tự động (100% / 90% / 85%) hoặc 80–110%; 110% ở cửa sổ 768 bị giới hạn để vùng giao diện không thấp hơn 700 px (bảng không bị cắt). Cỡ thế giới không đổi khi đổi cỡ giao diện (camera bù). | `Window.content_scale_factor`, `ViewScale.ui_scale` |
| A3 | Nhật ký đã có sẵn (3 dòng, tự mờ sau 6 giây) — giữ. Khung nhiệm vụ: **chuột phải** để thu gọn còn tiêu đề + mục tiêu + chỉ đường (nhớ trong cài đặt `quest_compact`). | `hud.gd` |
| B1 | Bóng đổ một hướng sáng (nắng trên-trái → bóng xuống-phải) cho cây, nhà, cảnh sa mạc / hang, quái, linh thú, NPC, nhân vật. Cây sát nhau chồng bóng → nền rừng tối hơn. | `world_view._draw_shadows`, `_shadow_at`, `SpriteLib.env_extent` |
| B2 | Mảng nắng ấm / bóng râm lạnh 300–800 px (RNG riêng theo map, không đổi cảnh cũ). | `world_view._draw_depth_ground`, `_light` |
| B3 | Lớp hạ tông nền (tối + bớt rực ~16%) — nhân vật, quái, cây nổi khỏi nền. | `GROUND_DIM` |
| Tắt | Cài đặt → Hiển thị → "Bóng đổ và ánh sáng nền" (máy yếu). Chỉ chạy với hình HD. | `depth_fx` |

Test: VS1-T1. Ảnh: `sau-vs1-1366.png` (khung như cũ + chiều sâu), `sau-vs1-1920.png` (thấy rộng hơn, HUD 90%).

### 6.1. B4 + B5 (làm tiếp cùng ngày)

| Mục | Kết quả | Code |
| --- | --- | --- |
| B4 | Dải sương mép trên (phía xa) + dải mỏng mép dưới; 7 cụm sương lớn trôi theo gió (thị sai ×1,12); hạt bay theo vùng — lá (rừng), hạt cỏ (thảo nguyên), đom đóm (đầm lầy), bụi (sa mạc / phế tích / hang), tàn lửa (núi lửa), tuyết (băng nguyên), cánh hoa (đảo bay), tia vàng (Thiên Thê), bụi tím (Hư Vô); tia nắng xiên cùng hướng sáng với bóng đổ (rừng, thảo nguyên, sa mạc, băng, đảo bay, Thiên Thê; tắt ở đầm lầy / núi lửa / Hư Vô / hang). | `view/atmos_layer.gd` (`THEMES`, `theme_id`) |
| B5 | Tiền cảnh vẽ bằng code (không cần art): chùm lá (rừng), cành thông (băng), sậy / cỏ (đầm lầy / thảo nguyên), đá (sa mạc, núi lửa, Hư Vô, hang), mây (đảo bay, Thiên Thê). Neo theo thế giới, thị sai ×1,3, chỉ ở dải mép, đục tối đa 60%, mờ còn 35% khi người chơi / quái ở gần (Q210). | `_draw_foreground`, `_fg_piece`, `_leaf` |
| Vị trí | CanvasLayer `_fx` của main, dưới vignette, trên thế giới; cùng công tắc "Bóng đổ và ánh sáng nền" (`depth_fx`) + chỉ khi HD; ẩn khi đang dịch chuyển. | `main._atmos` |

### 6.2. Sửa sau phản hồi (06/11/2026)

| Lỗi | Nguyên nhân | Sửa |
| --- | --- | --- |
| Chữ chỉ đường ("485 m · Cổng → Mắt Bão") đè lên nhân vật | Chữ căn giữa ở điểm cách mũi tên 30 px; mũi tên chỉ ngang thì nửa chuỗi chữ chìa về phía nhân vật. Chữ giữ cỡ khi zoom ra (A1) nên càng to, càng đè. | `quest_view.draw`: mép gần của chữ đặt ngay sau đầu mũi tên (lệch theo hướng mũi tên một nửa bề rộng / cao chữ); nếu khung chữ vẫn chạm thân nhân vật thì đưa xuống dưới chân. Ảnh `sua-chu-chi-duong.png` (trái: trước, phải: sau). |

Còn lại: B6 (cao độ địa hình — vách đá, bờ nước, cầu; cần art + va chạm, làm khi làm lại map).

## 7. PF-02 — "di chuyển hơi giật + vệt mờ phía trên màn hình" (Spec_Notes 08/11/2026)

Phản ánh người chơi: *"Khi di chuyển trên bản đồ thì hơi giật giật, ngoài ra có vệt mờ mờ trên màn hình (phía trên)."* Cả hai xuất hiện sau VS-1 (06/11).

### 7.1. Vệt mờ phía trên

Chụp 1920×1080 (ảnh `docs/design/view-scale/pf02-truoc.png` / `pf02-sau.png`): mép trên màn hình có **chùm lá tối mờ** (tiền cảnh B5, kèm quầng mờ 300×240 px sau mỗi chùm) đè lên **dải sương cố định** (B4, đậm ở đỉnh, mờ dần tới 32% chiều cao, vẽ bằng 8 dải nên có ngấn) và **tia nắng xiên** từ góc trên-trái. Ba thứ này gắn với màn hình, không trôi theo bản đồ → nhìn như màn hình bẩn. Ngoài ra trong góc nhìn 3/4 mép trên là phía **xa** camera — đặt tán lá "sát camera" ở đó là sai phối cảnh.

| Sửa | Code |
| --- | --- |
| Bỏ dải sương cố định mép trên (và dải mỏng mép dưới), bỏ tia nắng xiên | `atmos_layer.gd`: xoá `_draw_haze`, `_draw_rays`, khoá `haze` / `rays` trong `THEMES` |
| Tiền cảnh chỉ ở **mép dưới** và **phần dưới hai mép bên** (y > 62% chiều cao); không bao giờ ở mép trên | `AtmosLayer.fg_edge(p, size)`, `FG_SIDE_FROM = 0.62` |
| Bỏ quầng mờ to sau mỗi mảng tiền cảnh (nhoè + tốn tô điểm ảnh); độ đục tối đa 60% → 50% | `_fg_piece`, `FG_MAX_A` |
| Giữ: cụm sương trôi (neo theo thế giới, rất nhạt), hạt bay theo vùng | `_draw_mist`, `_draw_motes` |

### 7.2. Giật khi di chuyển

Đo bằng `tests/perf_walk.gd` (có cửa sổ, 1920×1080, rừng 1-1, 120 quái, nhân vật tự đi vòng) trên máy dev (Intel Arc iGPU). Bản trước VS-1 ≈ 34,5 khung/giây, sau VS-1 ≈ 27,5 → tụt ~20%: camera zoom ra (thấy ×1,5 diện tích) nên vẽ nhiều vật hơn, cộng thêm bóng đổ / mảng sáng / lớp không khí. Đo tách từng phần (thêm `--scan`, dòng `TIMELINE` / `RENDER` vào công cụ):

| Chỗ tốn (ms / khung, trước) | Nguyên nhân | Sửa |
| --- | --- | --- |
| Lớp không khí ≈ 2,5 CPU + tô điểm ảnh | dải sương 8 dải toàn chiều ngang, 4 tia nắng, quầng mờ 300×240 sau mỗi mảng tiền cảnh | §7.1 |
| Cổng dịch chuyển ≈ 1,8 | vẽ **mọi** cổng của map mỗi khung (không lọc khung nhìn), bảng tên tạo `StyleBoxFlat` mới mỗi khung | `_draw_portals(view)`, `_draw_portal_labels(view)` lọc theo khung nhìn |
| Tách quái ≈ 1,8 | `GameWorld._separate_enemies` so **mọi cặp** (120 quái = 7 140 cặp) | lưới ô cạnh = đường kính quái lớn nhất, cặp của mỗi quái vẫn xử lý theo thứ tự cũ. Mật độ thường cho kết quả trùng khớp; cụm rất dày lệch < 1,5 px / khung (cặp bị đẩy vào gần trong cùng khung được tách ở khung sau) |
| Sắp xếp vật theo Y ≈ 1 | `sort_custom` + lambda cho ~200 vật | khoá số `floor(y·16)·65536 + chỉ số` trong `PackedFloat64Array.sort()` (sắp xếp gốc) |
| Cây ≈ 1,1 | mỗi cây đọc lại `map.decor` tới 7 lần + tính khung hình cây để làm mờ khi che | `_decor_now` đọc 1 lần / khung; `_tree_fade` bỏ qua khi không có điểm cần thấy ở gần phía sau gốc |
| Mảng nắng / bóng râm (GPU) | 15–20 hình mờ 600–1600 px chồng nhau + 1 lớp hạ tông, vẽ lại mỗi khung | nướng 1 lần mỗi map thành ảnh thấp (1 điểm ảnh = 40 px thế giới, lọc Linear qua `CanvasTexture`), mỗi khung vẽ 1 ảnh — `_bake_light`, `blob_falloff`, `over` (cùng bảng dừng gradient, phủ "over" lần lượt = gộp) |
| Cổng chặn boss, đấu trường, hàng rào | vẽ cả khi ngoài khung nhìn | lọc theo khung nhìn |

Kết quả (đo xen kẽ trước / sau, cùng điều kiện máy — lúc đo máy chạy pin và có một cửa sổ Godot khác đang mở nên số tuyệt đối thấp, chỉ so tương đối):

| | Trước | Sau | |
| --- | --- | --- | --- |
| Script (`_process` + `_draw`) | 40,3 ms | 31,1 ms | −23% |
| Render CPU | 13,7 ms | 9,9 ms | −28% |
| GPU | 11,3 ms | 8,5 ms | −25% |
| Cả khung | 86,8 ms | 73,2 ms | −16% |

Lúc máy cắm sạc (đầu phiên): 27,5 → ~32–38 khung/giây (có 120 quái; dao động giữa các lần chạy). Dựng cảnh khi vào map thêm ảnh sáng: 70–85 ms (trong lúc chuyển map).

**Còn lại / chưa đạt NFR-01 (60 khung/giây) trên máy iGPU khi có nhiều quái**: vẽ thế giới vẫn ~8 ms script (cây ~1 ms, quái ~0,8 ms, bóng đổ ~1 ms, dựng danh sách), `world.update` ~2,7 ms, HUD ~1,5–2 ms, render ~8–10 ms. Bước tiếp nếu cần: nướng bóng đổ tĩnh của cây / nhà theo vùng (như ảnh sáng), gộp texture môi trường vào atlas để giảm đổi texture (draw call ~800), quái ở xa cập nhật AI thưa hơn. Người chơi máy yếu có thể tắt "Bóng đổ và ánh sáng nền" (≈ +4 ms) hoặc chọn Tầm nhìn "Gần".

Test: **PF02-T1** (tiền cảnh không ở mép trên, không còn dải sương / tia nắng, tách quái theo lưới = so mọi cặp ở mật độ thường và chồng lấn tương đương ở cụm dày, độ đậm + phép gộp mảng sáng).
