# 45. Nghiên cứu góc nhìn + thiết kế nhân vật theo ảnh tham khảo (GN-1)

| Mục | Nội dung |
| --- | --- |
| Ngày | 09/11/2026 |
| Yêu cầu | Chủ dự án gửi ảnh một game ARPG di động 3D (`design/goc-nhin/tham-khao.png`): *"Nghiên cứu về góc nhìn và cách design nhân vật như vậy → xem có apply được vào game hiện tại không? Nếu được thì apply như thế nào, apply những gì?"* |
| Ảnh | [design/goc-nhin/](design/goc-nhin/): `tham-khao.png` (ảnh gửi), `hien-trang-1366.png` (chụp thật trong game, rừng 1-1, tắt HUD), `thu-phoi-canh-so-sanh.png` (trái: hiện tại, phải: thử nghiêng phối cảnh bằng cách biến dạng ảnh — chỉ là ảnh thử, chưa đụng code) |
| Trạng thái | ✅ Chủ dự án duyệt "làm theo đề xuất" (09/11, Q218–Q223 theo cột mặc định) → đã làm GN-1a + GN-1b + GN-1c (§6). 09/11 (lần 2, "triển khai theo đề xuất"): GN-2 — cảnh trại cho vùng 2–9 (§7). Lần 3 ("triển khai tiếp"): GN-3 — bộ đếm combo (Q223), tông nền vùng 2–9, nền đất mòn / sân lát / mép đấu trường, sửa xương rồng trong đấu trường 3-3 (§8). Lần 4 ("triển khai tiếp phần còn lại"): GN-4 — hình đứng thẳng dưới phối cảnh (P1-B) + vách đá viền map, thành hồ / hố (E6, chỉ hình) (§9). Còn lại: bậc / cầu có va chạm (khi làm lại map) |
| Liên quan | [44](44-ty-le-khung-nhin-va-chieu-sau.md) (VS-1: zoom theo độ phân giải, bóng đổ, ánh sáng nền, không khí, tiền cảnh — đã làm), [39](39-thiet-ke-lai-quai-vat.md) (phong cách quái cartoon), quy tắc giữ hình nhân vật của chủ dự án |

## 1. Ảnh tham khảo làm gì

### 1.1. Góc nhìn

| Đặc điểm | Ảnh tham khảo | Game hiện tại |
| --- | --- | --- |
| Loại camera | Camera 3D **phối cảnh thật**, nghiêng ≈ 50–55° so với mặt đất, góc mở hẹp | Camera 2D **trực giao** (không phối cảnh). Hình vẽ kiểu 3/4 (thấy mái + mặt trước) nên *giả* được góc ≈ 45° |
| Chiều sâu | Vật ở mép trên **nhỏ hơn** (viên đá lát dưới ≈ 45 px, giữa-trên ≈ 28 px), mặt đất "chạy ra xa" | Mọi chỗ cùng tỷ lệ; cây ở mép trên to bằng cây ở mép dưới |
| Nhân vật trên màn hình | Cao ≈ **15%** chiều cao màn hình; khung ngang ≈ 11 lần chiều cao nhân vật (camera gần, kiểu di động) | ≈ 7–8% (VS-1); khung ngang ≈ 21 lần (1366) – 26 lần (1080p) → thấy rộng gấp ~4–5 lần diện tích |
| Bố cục cảnh | "Sân khấu": nền trống ở giữa để đánh, **tường cọc gỗ, giàn giáo, tháp canh dựng cao ở phía xa (mép trên)** đóng khung | Rừng rải đều cây, không có vật dựng đứng cao làm "phông" |
| Mặt đất | Nhiều vật liệu: đá lát, đất, cỏ, chuyển tiếp mềm; đồ vương vãi (vũ khí gãy, giáp, khúc gỗ, thùng, thịt) | 1 texture cỏ + mảng sáng/tối (VS-1 B2); lối mòn là 1 hình chữ nhật đất mờ 55% |
| Ánh sáng | Nắng ấm 1 hướng, bóng mềm dài, che khuất môi trường (AO) ở chân tường / gốc vật, đuốc / lửa có quầng sáng | Đã có: bóng đổ 1 hướng (B1), mảng nắng / râm (B2), hạ tông nền (B3). Chưa có: nguồn sáng điểm (đuốc, lửa), AO chân vật |
| Màu | Nền bớt bão hoà, tông nâu-xanh xám; nhân vật sáng màu + hiệu ứng đỏ / xanh nổi lên | Nền xanh đậm khá rực (đã hạ 16% ở B3), cây và nhân vật cùng độ rực |

### 1.2. Thiết kế nhân vật

| Đặc điểm | Ảnh tham khảo | Game hiện tại |
| --- | --- | --- |
| Tỷ lệ | Người thật, ≈ 7–7,5 đầu, dáng mảnh | Chibi ≈ 2,5–3 đầu (hình của chủ dự án, `class-sheet.png`) |
| Kỹ thuật | Mô hình 3D, vật liệu PBR, ánh sáng thật, áo / tóc có vật lý | Sprite 2D vẽ sẵn, 32 px × 2 (HD lọc Linear) |
| Đọc hình | Bóng dáng rõ nhờ màu sáng (tóc xanh, áo trắng) trên nền trầm + bóng đổ dưới chân | Đọc hình nhờ viền tối + màu lớp; nền và nhân vật cùng độ sáng nên kém nổi hơn |
| Quái | Cùng tỷ lệ người thật, to hơn nhân vật một chút; hiệu ứng trúng đòn đỏ | Cartoon chunky (docs/39), thống nhất phong cách với nhân vật chibi |

## 2. Áp dụng được không?

**Kết luận ngắn:** *bản thân* ảnh tham khảo (3D phối cảnh thật + nhân vật người thật) **không chép thẳng được** vào game hiện tại; nhưng **khoảng 70% cảm giác** của nó (chiều sâu, bố cục sân khấu, mặt đất phong phú, ánh sáng, nhân vật nổi khỏi nền) **làm được trong 2D** với công sức vừa phải.

| Muốn có | Làm được trong 2D hiện tại? | Lý do |
| --- | --- | --- |
| Phối cảnh (xa nhỏ, gần to) | 🟡 Giả được (mục 3.1) | Godot 2D không có camera phối cảnh; giả bằng shader biến dạng mặt đất hoặc co vật theo độ sâu |
| Camera gần như ảnh (nhân vật 15%) | ⛔ Không nên | Ngược với phản hồi VS-1 ("to quá, chiếm nhiều quá" — docs/44); màn PC cần thấy rộng. Chỉ dùng zoom gần **tạm thời** khi đánh boss (mục 3.1 P2) |
| Bố cục sân khấu, tường cao phía xa | ✅ | Thêm bộ cảnh dựng (prop set) — giống cách đã làm nhà / cây HD |
| Mặt đất nhiều vật liệu, đồ vương vãi | ✅ | Texture mới qua `tools/art/hd` + `SpriteLib.fill_polygon` / `draw_env` đã có sẵn |
| Nguồn sáng điểm (đuốc, lửa trại) | ✅ | Vẽ quầng cộng sáng (additive) nướng sẵn như `_bake_light`; không cần hệ đèn 2D của Godot |
| Nhân vật tỷ lệ người thật 7 đầu | ⛔ Không đề xuất | (1) Hình nhân vật là của chủ dự án, không được vẽ lại khi chưa hỏi; (2) cả game đã chốt phong cách cartoon / chibi (quái docs/39, trang bị docs/40, kỹ năng docs/36); (3) ở cỡ 64–73 px, người 7 đầu chỉ còn đầu ≈ 9 px — mất nhận diện, ảnh tham khảo đọc được vì nhân vật to 15% màn hình và là 3D |
| Chuyển hẳn sang 3D / "HD-2D" (nền 3D + nhân vật sprite đứng) | 🟡 Làm được nhưng rất lớn (mục 3.5) | Viết lại toàn bộ lớp vẽ (`scripts/view/`, 29 tệp ≈ 6 200 dòng + FX-1), làm lại mọi bản đồ thành cảnh 3D |

## 3. Đề xuất áp dụng

### 3.1. Nhóm P — Góc nhìn

| # | Đề xuất | Cách làm | Công |
| --- | --- | --- | --- |
| **P1** | **Nghiêng phối cảnh nhẹ** — mép trên (xa) co lại ~10–15%, mép dưới (gần) giữ nguyên | **Cách A (khuyên dùng để thử):** vẽ thế giới vào `SubViewport`, hiển thị qua 1 shader biến dạng hình thang (như ảnh `thu-phoi-canh-so-sanh.png`). Một lượt vẽ toàn màn hình, không phải sửa từng hàm vẽ. Cần: hàm đổi ngược toạ độ chuột (`main.gd:404` lấy hướng ngắm từ chuột), vẽ chữ trên bản đồ / thanh máu ra lớp riêng không biến dạng, khung nhìn cắt (`_view_rect`) nới rộng phía trên. Nhược: cây ở hai góc trên hơi nghiêng ra ngoài (~3–5° ở mức nhẹ). **Cách B:** đổi vị trí + co từng sprite theo độ sâu, sprite vẫn đứng thẳng — đẹp hơn nhưng phải sửa mọi chỗ vẽ (world_view, region5–9_view, fx1, quest_view…) | A: vừa · B: lớn |
| **P2** | **Camera động khi chiến đấu**: vào trận boss / đấu trường → zoom gần ×1,1–1,15 trong 0,6 giây, ra khỏi trận trở lại; rung + "khựng hình" 40–60 ms khi đòn chí mạng / phá giáp | `main._apply_view_scale` thêm hệ số trận đấu, lerp; đã có rung camera | Nhỏ |
| **P3** | **Camera dẫn hướng**: lệch khung về hướng nhân vật đang chạy ~5% (thấy trước đường đi) | Lerp `camera.offset` theo vận tốc | Nhỏ |
| — | Không làm: camera gần cố định như ảnh | Xem mục 2 | — |

### 3.2. Nhóm E — Môi trường (khoảng cách lớn nhất so với ảnh)

| # | Đề xuất | Cách làm | Công |
| --- | --- | --- | --- |
| **E1** | **Nền nhiều vật liệu**: đá lát trong làng / trại, đất mòn quanh nhà và cổng, viền chuyển cỏ ↔ đất ↔ đá mềm (không còn hình chữ nhật cứng) | Texture HD mới `tile-cobble`, `tile-dirt-worn` + mặt nạ viền mềm; vùng vật liệu khai báo trong dữ liệu map (đa giác). Nướng 1 lần mỗi map như `_bake_light` để không tốn khung hình | Vừa |
| **E2** | **Bộ cảnh "trại / bãi chiến"**: hàng rào cọc gỗ, giàn giáo, tháp canh, cờ, giá vũ khí, chồng thùng, củi, vũ khí gãy / giáp rơi vương vãi | Bộ `env-*` HD mới (skill game-art); đặt thành **cụm** quanh làng, trại quái, đấu trường boss. Tường cao đặt ở phía **xa** (trên) của khu để làm phông → chiều cao + đóng khung như ảnh. Đồ vương vãi là hình phẳng sát đất (vẽ cùng lớp nền đã nướng, không tốn) | Vừa – lớn (theo số vùng) |
| **E3** | **Nguồn sáng điểm**: đuốc, đèn lồng, lửa trại, cổng dịch chuyển có quầng sáng ấm / tím nhấp nháy nhẹ, hắt lên nền | Quầng additive (texture `_soft_blob`), độ sáng dao động theo thời gian; tắt cùng công tắc `depth_fx` | Nhỏ |
| **E4** | **Che khuất chân vật (AO)**: viền tối mềm sát chân tường, nhà, đá, gốc cây — khác bóng đổ (B1) ở chỗ tối đều quanh chân | Thêm vào `_draw_shadows` 1 elip tối nhỏ đậm hơn sát gốc | Nhỏ |
| **E5** | **Bảng màu nền trầm hơn theo vùng** (nâu-xanh xám như ảnh), giữ nhân vật / quái / hiệu ứng rực | Chỉnh `GROUND_DIM` theo vùng + texture nền | Nhỏ |
| E6 | Cao độ địa hình (vách, bậc, bờ nước) | = B6 của docs/44, để khi làm lại map | Lớn |

### 3.3. Nhóm C — Nhân vật (không vẽ lại hình của chủ dự án)

| # | Đề xuất | Cách làm | Công |
| --- | --- | --- | --- |
| **C1** | **Giữ tỷ lệ chibi**, chỉ học nguyên tắc "nhân vật nổi khỏi nền" | — | — |
| **C2** | **Viền sáng (rim light)** phía hướng nắng (trên-trái) cho nhân vật + quái, mảnh 1–2 px, màu theo vùng | Shader trên sprite lúc vẽ (không sửa tệp hình) — là hiệu ứng ánh sáng, **không** vẽ lại; vẫn hỏi chủ dự án vì đụng tới cách nhân vật hiển thị (Q221) | Nhỏ – vừa |
| **C3** | **Bóng tiếp xúc** đậm sát chân nhân vật (ngoài bóng đổ B1) → "đứng trên đất" rõ như ảnh | `_draw_shadows` | Nhỏ |
| **C4** | **Tỷ lệ nhân vật : môi trường** như ảnh — cửa nhà ≈ 1,3× người, tường / hàng rào cao 2–3×, thùng ≈ 0,5× | Kiểm `size_mul` các `env-*` khi làm E2; bộ cảnh mới vẽ đúng tỷ lệ này | Nhỏ |
| C5 | (Chỉ nếu chủ dự án muốn) nhân vật tỷ lệ thật | Là đổi **định hướng mỹ thuật** toàn game: 5 lớp × ngoại hình × hoạt ảnh, 85 quái, 9 linh thú, NPC. Cần hình từ chủ dự án. Không làm trong 2D ở cỡ hiện tại | Rất lớn |

### 3.4. Nhóm U — HUD (ảnh tham khảo rất gọn)

Ghi lại để tham khảo, không thuộc yêu cầu chính: ảnh tham khảo dùng thanh HP / MP mảnh, mục tiêu 1 dòng ("Tiêu diệt mọi quái vật"), **bộ đếm combo to** bên trái, cụm kỹ năng hình thoi. Game đã có thu gọn khung nhiệm vụ (chuột phải, docs/44 A3) và yêu cầu ẩn / hiện + làm mờ khung nhiệm vụ / bản đồ nhỏ đang nằm trong `Spec_Notes.md`. Bộ đếm combo có thể là đề xuất riêng (Q223).

### 3.5. Phương án lớn — chuyển sang "HD-2D" (nền 3D + sprite 2D đứng)

Cách các game kiểu "HD-2D" làm: mặt đất, tường, nhà là mô hình 3D đơn giản; nhân vật / quái là sprite 2D đứng (billboard `Sprite3D`) trong cảnh 3D; camera phối cảnh thật, ánh sáng + bóng thật, mờ xa (DOF).

- **Được:** đúng cảm giác ảnh tham khảo (phối cảnh, tường cao, ánh sáng thật) mà **vẫn giữ hình nhân vật / quái 2D hiện có**.
- **Mất:** viết lại toàn bộ lớp vẽ sang 3D (logic `GameWorld` vẫn 2D, đổi `x, y` → `x, 0, z` được); làm lại 9 vùng + hang + dungeon thành cảnh 3D; FX-1 (70 kỹ năng vẽ vector 2D) phải chuyển sang mặt phẳng trong 3D; hiệu năng trên iGPU còn chưa đạt 60 khung/giây ở 2D (docs/44 §7).
- **Khuyên:** không làm bây giờ. Nếu muốn cân nhắc, làm **1 bản thử tách nhánh** cho 1 map (rừng 1-1) để chủ dự án xem trước khi quyết.

## 4. Kế hoạch đề xuất

| Đợt | Nội dung | Ghi chú |
| --- | --- | --- |
| GN-1a | P1 cách A (có công tắc Cài đặt → Hiển thị → "Phối cảnh": Tắt / Nhẹ / Vừa) + P2 + P3 | Chụp 1366 / 1920 để duyệt; đo FPS bằng `perf_walk.gd` (thêm 1 lượt vẽ toàn màn hình) |
| GN-1b | E3 + E4 + C3 + E5 | Không cần hình mới |
| GN-1c | E1 + E2 + C4 cho **vùng 1 (làng Thanh Thạch + trại sói + đấu trường Lõi Sương)** | Hình mới qua skill game-art; duyệt rồi nhân ra các vùng khác |
| Tuỳ | C2 (khi chủ dự án đồng ý), HD-2D thử (khi chủ dự án muốn) | |

## 5. Câu hỏi chờ duyệt

| ID | Câu hỏi | Mặc định đề xuất |
| --- | --- | --- |
| Q218 | Có làm nghiêng phối cảnh (P1) không? Mức mặc định? | Có, cách A, mặc định **Nhẹ** (mép trên co ~10%), cho chọn Tắt / Nhẹ / Vừa |
| Q219 | Camera động khi đánh boss (P2) + dẫn hướng (P3)? | Có, zoom gần ×1,1 khi vào trận boss; dẫn hướng 5% |
| Q220 | Làm môi trường (E1–E5) bắt đầu từ vùng nào? | Vùng 1 trước (người chơi mới thấy đầu tiên) |
| Q221 | Có cho thêm viền sáng (C2) lên nhân vật — hiệu ứng lúc vẽ, không sửa tệp hình? | Hỏi chủ dự án; mặc định **không** làm cho đến khi duyệt |
| Q222 | Có muốn đổi nhân vật sang tỷ lệ người thật (C5) hoặc thử HD-2D (3.5) không? | Không. Giữ chibi + 2D |
| Q223 | Thêm bộ đếm combo to kiểu ảnh tham khảo? | Để đợt HUD sau |

Đã trả lời 09/11/2026: *"làm theo đề xuất của em"* → mọi câu theo cột mặc định (Q221: không làm viền sáng nhân vật; Q222: giữ chibi + 2D; Q223: để đợt HUD sau).

## 6. Đã làm (09/11/2026)

| Mục | Kết quả | Code |
| --- | --- | --- |
| P1 | **Cài đặt → Hiển thị → Phối cảnh: Tắt / Nhẹ (mặc định) / Vừa.** Shader biến dạng hình thang trên ảnh thế giới: Nhẹ — mép dưới phóng ≈ ×1,11 so với mép trên, Vừa ≈ ×1,19. Camera zoom ra bù độ phóng giữa màn hình → nhân vật giữ cỡ cũ. Chuột ngắm đổi ngược qua phép biến dạng. HUD không bị biến dạng | `view/tilt.gd`, `main._tilt`, `_world_mouse`, `_apply_view_scale` |
| P2 | Boss còn sống trong 700 px → camera zoom gần ×1,1 trong 0,6 giây; hết trận trở lại | `main.FIGHT_ZOOM`, `_boss_near` |
| P3 | Camera lệch 5% khung nhìn về hướng đang chạy, đổi hướng mượt ~0,8 giây; dịch chuyển không tính | `main._update_lead`, `WorldView.cam_lead` (cộng với rung) |
| E1 | Lối mòn làng → đấu trường: mép lượn + 2 lớp (viền mờ 22% + lõi 60%) thay cho dải chữ nhật | `world_view._path_points` |
| E2 | Vùng 1: đấu trường Hang Sói Chúa có **rào cọc ở cung phía xa** (205°–335°) làm phông, 2 chòi canh, 2 cờ đầu sói, 2 đuốc lối vào tây, giá vũ khí, xương / vũ khí gãy trong sân; **bãi trại bỏ hoang** (≈ 12 bãi / map ×3, cách nhau ≥ 700 px: 3 đoạn rào phía bắc, giá vũ khí, thùng, đồ vương vãi, có khi có cờ). Không chặn đường đi; cây đè lên bị dọn | `view/camp_decor.gd`, `tools/art/hd/env_camp_props.py` |
| E3 | Quầng sáng cộng nhấp nháy nhẹ: vũng sáng trên nền + quầng ở đầu lửa cho đèn lồng, đuốc, lửa trại, lò lửa, đèn chòi canh (mọi khu an toàn HD + cảnh trại) | `world_view._draw_lamp_glow`, `CampDecor.LIGHTS` |
| E4 + C3 | Lõi tối hẹp sát chân mọi vật có bóng (cây, nhà, cảnh, quái, linh thú, NPC, nhân vật) | `_shadow_at` |
| E5 | Vùng 1: lớp hạ tông nền nâu-xám ấm, đậm hơn (22%) — nhân vật / quái / cảnh nổi lên | `REGION_DIM` |
| C4 | Bộ cảnh mới vẽ theo tỷ lệ: rào ≈ 1,8× người, cờ ≈ 2×, giá vũ khí ≈ 1,1× | `env_camp_props.py` |
| Tắt | P1 riêng (Phối cảnh: Tắt). E1–E5 đi cùng công tắc "Bóng đổ và ánh sáng nền" + hình HD (tắt HD → cảnh cũ) | |

Ảnh: `truoc-gn1-1920.png` (tắt phối cảnh + chiều sâu) / `sau-gn1-1920.png`, `sau-lang-1366.png` (đèn lồng làng), `hd-camp-props.png` (bộ cảnh, trong `tools/art/_preview/`). Test **GN1-T1**. Công cụ chụp `tests/gn1_shot.gd`.

Hiệu năng (`perf_walk.gd --map=1-1 --mobs`, đo xen kẽ 2 lượt, thêm `--off=notilt` để tắt phối cảnh): khung/giây như nhau (30,1 / 30,3 so với 30,3 / 30,0 — máy đang bận nên số tuyệt đối thấp), GPU thêm ≈ 0–0,6 ms cho lượt shader.

Còn lại sau GN-1: cảnh trại vùng 2–9 → đã làm ở §7.

## 7. GN-2 — cảnh trại vùng 2–9 (09/11/2026, "triển khai theo đề xuất")

Theo kế hoạch §4 ("duyệt vùng 1 rồi nhân ra các vùng khác"). Mỗi vùng 1 bộ hình theo chất liệu vùng (ảnh `gn2-bo-canh.png`):

| Vùng | Rào / tường | Cờ | Đồ vương vãi | Đồ bãi trại | Đèn bãi trại | Phông đấu trường |
| --- | --- | --- | --- | --- | --- | --- |
| 1 Rừng Sương | rào cọc gỗ | đỏ, đầu sói | xương, vũ khí gãy, khúc gỗ | thùng | — | ✅ chòi canh + đuốc |
| 2 Đồng Bằng | rào gỗ sáng | lam, gió | như vùng 1 | đống rơm, thùng | đuốc | ✅ chòi canh + đuốc |
| 3 Xích Sa | tường sa thạch đổ | cam, mặt trời | đá vụn sa thạch, xương | vò | đuốc | ✅ tháp đá + đuốc |
| 4 Đầm Lầy | rào tre | lục, lá | khúc gỗ, xương | thùng | đèn lồng | ✅ chòi canh + đèn lồng |
| 5 Núi Lửa | tường bazan nứt dung nham phát sáng | đen, lửa | đá bazan vụn có ánh dung nham | xe quặng | chậu lửa | — (đấu trường riêng) |
| 6 Băng Nguyên | rào gỗ phủ tuyết | trắng, bông tuyết | đá băng vụn, xương | củi, xe trượt | **không** (lửa là cơ chế sưởi) | ✅ chòi canh, không đuốc |
| 7 Thiên Không | tường cẩm thạch đổ | lam nhạt, mây | đá cẩm thạch vụn | thùng | đèn lồng | — (đảo mây) |
| 8 Hư Vô | mảnh hắc diện thạch nhọn, quầng tím | tím, mắt | đá Hư Vô vụn có ánh tím | đá Hư Vô | — | — |
| 9 Thiên Thê | tường cẩm thạch gờ ngọc, ngọc khảm | vàng, sen | đá cẩm thạch vụn | lư hương | — | — |

Chỗ đặt (`CampDecor.spot_ok`): ngoài các điều kiện của vùng 1, tránh mọi điểm ghi trong dữ liệu map (`map_points`: cửa tầng, lính gác, ấn, lửa trại, đèn, bia… — Vector2, mảng Vector2, mảng [tâm, r], đoạn thẳng), nước (vùng 4 — map ngập 4-2 chỉ đặt trên cồn ≥ 160 px, nên chỉ 1 bãi), dung nham (+220 px), ngoài đảo và cầu gió (vùng 7, kiểm 5 điểm quanh bãi). Hang và dungeon cổng ngẫu nhiên không có cảnh trại (chỉ map trong `Maps.MAPS`).

Ảnh: `gn2-bai-trai-vung-2-9.png` (bãi trại 8 vùng), `gn2-dau-truong-2-3-4-6.png` (phông đấu trường). Test GN1-T1 mở rộng (8 map vùng 2–9).

Còn lại sau GN-2: E6 cao độ địa hình, Q223 bộ đếm combo, đấu trường 3-3 có xương rồng mọc trong sân (lỗi cũ) → Q223 + lỗi làm ở §8.

## 8. GN-3 — làm tiếp phần còn lại (09/11/2026, "triển khai tiếp")

| Mục | Kết quả | Code |
| --- | --- | --- |
| Q223 | **Bộ đếm combo lớn** kiểu ảnh tham khảo: số to viền tối + chữ "Combo" ở mép trái, ngay dưới khung nhân vật; nảy ×1,35 mỗi lần tăng (0,18 giây), số chuyển kem → cam khi chuỗi dài, dòng nhỏ "+n% EXP"; đứt chuỗi thì mờ dần 0,45 giây. Hiện từ 5 combo (như dòng cũ UI-54). **Cài đặt → Hiển thị → Bộ đếm combo: Lớn (mặc định) / Nhỏ (dòng chữ cũ trên cụm nút) / Tắt** — giữ lựa chọn UI-54 cho ai thích gọn | `ui/combo_counter.gd`, `hud.gd` (`_combo_big`), Settings `combo_style` |
| E5 | Tông nền cho cả 9 vùng (`REGION_DIM`), nhẹ hơn vùng 1: cát / tuyết / cẩm thạch bớt chói, đầm lầy / núi lửa / Hư Vô giữ màu tối | `world_view.REGION_DIM` |
| E1 | Nền đất mòn mép lượn (2 lớp) dưới mỗi bãi trại theo vùng (đất, cát đỏ, bùn, tro, đá lát tối / sáng); viền mờ ngoài sân đấu trường (chuyển nền mềm, không còn mép tròn cứng); trại vùng 1–2 chưa có sân lát → sân đá lát nhỏ giữa trại | `CampDecor.THEMES.ground`, `_ellipse_blob`, `_draw_arena`, `_draw_village_yard` |
| Lỗi | Đấu trường 3-3: xương rồng / cọ không còn mọc trong sân (lọc sau khi sinh, các cây khác giữ chỗ) | `_build_decor` |

Ảnh: `gn3-bo-dem-combo.png`, `gn3-tong-nen-truoc-sau.png` (vùng 2 / 3 / 6 / 9, trái trước — phải sau), `gn3-nen-dat-mon.png`, `gn3-trai-san-lat.png`, `gn3-dau-truong-3-3-het-xuong-rong.png`. Test **GN3-T1**.

Còn lại sau GN-3: E6 cao độ địa hình; P1 cách B → làm ở §9.

## 9. GN-4 — phần còn lại (09/11/2026, "triển khai tiếp phần còn lại")

### 9.1. P1-B — hình đứng thẳng dưới phối cảnh

Không viết lại ~700 chỗ vẽ: trong lúc WorldView vẽ, `SpriteLib` **xô ngược** mỗi hình (nhân vật, quái, NPC, cây, nhà, cảnh) quanh chân một hệ số bằng đạo hàm của phép biến dạng tại chân hình: `dx/dy = −(u − 0,5)·g·(dv/dy)/d · (W/H)`. Sau lớp biến dạng, thân hình thẳng đứng, chân vẫn khớp nền (nền, bóng, vòng dưới chân vẫn theo phối cảnh — đúng vì chúng nằm trên mặt đất). Thân cao 120 px ở góc màn hình lệch < 1,5 px (test). Giao diện không bị ảnh hưởng (chỉ bật giữa `upright_begin` / `upright_end`). Còn biến dạng nhẹ: chữ / thanh máu vẽ trong thế giới, hiệu ứng kỹ năng dạng cột. Ảnh `gn4-dung-thang.png` (mức Vừa, góc trên trái: trái chưa chỉnh — thân cây nghiêng, phải đã chỉnh).

### 9.2. E6 — cao độ địa hình (chỉ hình, không đổi đường đi)

| Mục | Kết quả |
| --- | --- |
| Vách đá viền map | Mép trên (phía xa): vách đứng cao ≈ 112 px, mép trên lượn lởm chởm, mặt đá tối dần xuống chân + đọng bóng chân vách, phía sau là mặt bằng cao. Hai mép bên: mặt bằng cao có viền đá. Mép dưới: gờ vực đổ xuống tối dần. Camera được nhìn ra ngoài mép map (trên 170 / bên 90 / dưới 110 px) nên đi sát mép mới thấy; **người chơi vẫn bị chặn ở mép cũ** (chân vách = ranh giới cũ). Mặt đá theo vùng: đá xám (1, 2, 4), sa thạch (3), bazan (5), đá băng (6), Hư Vô (8), cẩm thạch (9). Vùng 7 không có (đảo mây đã có vách đảo); hang / dungeon không có |
| Thành hồ / hố | Hồ nước (vùng 4): thành đất ở mép xa (nửa trên, phía trong). Cồn đất giữa nước (4-2): mặt đất đổ xuống ở mép gần (nửa dưới). Hố dung nham (vùng 5): thành bazan mép xa, viền cam |
| Không làm | Bậc, dốc, cầu có chặn va chạm — cần hệ va chạm mới cho người chơi / quái / bot cân bằng; để khi làm lại map |

Code: `view/terrain_edge.gd` (`margins`, `draw_border`, `draw_banks`), `main._fit_camera`, hình `tools/art/hd/env_cliffs.py` (6 ô `cliff-*` lặp liền mạch). Ảnh: `gn4-vach-da-1-1.png`, `gn4-vach-da-6-1.png`, `gn4-ho-dung-nham-5-1.png`, `gn4-con-dat-4-2.png`, `gn4-mat-da.png`. Test **GN4-T1**.

Hiệu năng (`perf_walk --map=1-1 --mobs`, xen kẽ 2 lượt): bật phối cảnh + đứng thẳng 56,9 / 57,0 khung/giây, tắt 57,5 / 58,2 — chênh trong nhiễu đo.

Còn lại: bậc / cầu có va chạm (khi làm lại map); chủ dự án chọn mức Phối cảnh Nhẹ / Vừa sau khi chơi thử.
