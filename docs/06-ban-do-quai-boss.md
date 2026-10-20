# Thiết kế bản đồ, quái vật, boss

| | |
| --- | --- |
| Dự án | Thiên Phú Khai Giới |
| Nguồn | [Kịch bản](kich-ban-game-thien-phu-khai-gioi.md) mục 2, 5, 6, 7 |
| Trạng thái | **Đã chốt thiết kế** 20/10/2026 — Q22–Q27 chốt theo phương án ở mục 7. Đã code: vùng 1 (một phần) — **chỉ số quái trong game tính bằng công thức mục 1 từ M3** (`Formulas.mob_stats`) |
| Cập nhật | 20/10/2026 |
| Cách tạo | Các bảng chỉ số được **sinh bằng script** `tools/gen_world_doc.py` từ công thức ở mục 1. Đổi công thức hoặc thêm quái: sửa script rồi chạy `python tools/gen_world_doc.py docs/06-ban-do-quai-boss.md`, không sửa tay từng số |

Quy ước: 1 m = 10 đơn vị trong game. Tốc chạy tính bằng đơn vị/giây (người chơi: 230). "×1,5" = 1,5 lần Tấn công của quái đó. Chỉ số quái ghi ở **cấp thấp nhất → cấp cao nhất** nơi nó xuất hiện.

## 1. Công thức chỉ số

### 1.1. Người chơi chuẩn

Mọi chỉ số quái được tính để cân với **người chơi chuẩn** ở cùng cấp: Kiếm Khách, cộng điểm 60% STR / 40% VIT, mặc đồ đúng vùng cường hoá trung bình.

| Chỉ số | Công thức (L = cấp) | Cấp 1 | Cấp 10 | Cấp 30 | Cấp 60 | Cấp 100 |
| --- | --- | --- | --- | --- | --- | --- |
| Tấn công | 10 + 13·(L−1) | 10 | 127 | 387 | 777 | 1.297 |
| HP | 100 + 50·(L−1) | 100 | 550 | 1.550 | 3.050 | 5.050 |
| Phòng thủ | 5 + 3,5·(L−1) | 5 | 36 | 106 | 212 | 352 |

Đối chiếu: nhân vật cấp 5 trong test M1 (cộng điểm, mặc 2–3 món) có Tấn công khoảng 55–62; công thức cho 62.

### 1.2. Quái

Sát thương dùng công thức kịch bản mục 5: `DMG = ATK × hệ số × ATK / (ATK + DEF)`.

| Thành phần | Công thức |
| --- | --- |
| Phòng thủ quái | `(3 + 1,5·L) × hệ số bậc × hệ số loại` |
| HP quái | `số đòn mục tiêu × sát thương 1 đòn của người chơi chuẩn × hệ số loại` |
| Tấn công quái | Chọn sao cho 1 đòn thường của quái lấy đúng `% HP mục tiêu` của người chơi chuẩn, rồi × hệ số loại |
| EXP | Quái thường `30·L^1,5` (đã code); tinh anh ×3 (đã code); boss vùng `0,3 × EXP lên cấp L`; boss hiếm `0,5 × EXP lên cấp L` |
| Vàng | Quái thường `3·L`, tinh anh `12·L` (đã code); boss vùng `50·L`; boss hiếm `80·L` |
| Phá Thế | Boss: 1/6 HP (Sói Chúa đang dùng 600/3600); tinh anh: 30% HP (CB-07, M3) |

**Theo bậc quái:**

| Bậc | Số đòn để hạ (người chơi chuẩn, đòn thường) | 1 đòn của quái lấy | Hệ số phòng thủ |
| --- | --- | --- | --- |
| Quái thường | 3 | 6% HP | ×1,0 |
| Quái tinh anh | 12 | 9% HP | ×1,5 |
| Boss vùng | 90 (chương 1) · 110 (chương 2–3) · 130 (chương 4+) | 10% HP | ×2,0 |
| Boss hiếm | 200 | 12% HP | ×2,0 |

Boss vùng tính với người chơi **thấp hơn boss 1 cấp** (cấp khuyến nghị khi vào hang). 90 đòn ≈ 35–40 giây, 130 đòn ≈ 45–60 giây có né đòn (Q23). Boss hiếm: loại quái chỉ đổi Tấn công/Phòng thủ, HP không nhân theo loại.

**Theo loại quái:**

| Loại | HP | Tấn công | Phòng thủ | Tốc chạy | Tầm đánh | Vai trò |
| --- | --- | --- | --- | --- | --- | --- |
| Nhanh | ×0,8 | ×0,9 | ×0,8 | 160 | 3,4 m | Áp sát nhanh, máu mỏng |
| Bầy | ×0,5 | ×0,6 | ×0,6 | 140 | 3,0 m | Đi đông, yếu từng con |
| Lì | ×1,4 | ×0,9 | ×1,3 | 80 | 3,6 m | Máu dày, chậm |
| Giáp | ×1,2 | ×1,0 | ×2,0 | 70 | 4,0 m | Phòng thủ cao, chậm nhất |
| Xa | ×0,9 | ×0,9 | ×0,8 | 70 | 24 m | Bắn từ xa, đứng yên |
| Phép | ×0,9 | ×1,2 | ×0,8 | 110 | 18 m | Sát thương cao, kỹ năng vùng |
| Tự nổ | ×0,6 | ×2,5 | ×0,5 | 170 | 2,0 m | Lao tới nổ một lần |

### 1.3. So với chỉ số của prototype (trước M3)

Trước M3, code dùng công thức cũ của prototype (`HP × (1 + 0,35·(L−1))`, `ATK × (1 + 0,25·(L−1))`). Công thức mới **làm quái cứng hơn ở cấp 5 trở lên** — khớp với phát hiện F2 (người chơi lên cấp quá nhanh). **Đã áp dụng ở M3** (Q22): `godot/scripts/core/formulas.gd` `mob_stats()` tính giống hệt script này; test CB-T1 so khớp bảng dưới. M5 chỉ tinh chỉnh hệ số từ dữ liệu playtest. Cột trái là số cũ để so sánh.

| Quái | Cấp | Code hiện tại (HP / ATK / DEF) | Thiết kế mới (HP / ATK / DEF) |
| --- | --- | --- | --- |
| Sói Sương | 1 | 40 / 8 / 4 | 18 / 8 / 4 |
| Sói Sương | 7 | 124 / 20 / 10 | 188 / 36 / 11 |
| Nấm Độc | 2 | 74 / 9 / 6 | 51 / 13 / 5 |
| Nấm Độc | 7 | 170 / 18 / 11 | 212 / 36 / 11 |
| Tinh Linh Sương | 5 | 168 / 24 / 11 | 147 / 35 / 8 |
| Tinh Linh Sương | 10 | 290 / 39 / 16 | 308 / 66 / 14 |
| Sói Chúa Hư Vô | 6 | 3600 / 27 / 12 | 4023 / 43 / 24 |

## 2. Tổng quan 9 vùng

| # | Vùng | Cấp | Hệ chủ đạo | Mở khoá (kịch bản) | Boss chương | Boss hiếm | Trạng thái |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | Rừng Sương | 1–10 | Mộc | Bắt đầu game | Sói Chúa Hư Vô (cấp 6) | Lão Thụ Sương Mù (cấp 9) | 🟡 1/3 map |
| 2 | Đồng Bằng Gió Hú | 10–20 | Kim | Hạ Sói Chúa (kịch bản) | Tướng Gián Điệp Huyền Ảnh (cấp 18) | Bạch Hổ Phong Vân (cấp 20) | ⬜ M4 |
| 3 | Sa Mạc Xích Sa | 20–32 | Thổ | Lực chiến 5.000 (kịch bản) | Bọ Cạp Sa Hoàng (cấp 30) | Nhân Sư Đá (cấp 32) | ⬜ Alpha |
| 4 | Đầm Lầy U Minh | 32–45 | Thủy | Chuyển chức 1 (kịch bản) | Nữ Vương Phệ Mộng (cấp 43) | Thuỷ Quái Thất Đầu (cấp 45) | ⬜ Alpha |
| 5 | Núi Viêm Long | 45–60 | Hỏa | Thiên phú tiến hoá 1 lần (kịch bản) | Viêm Long (cấp 58) | Phượng Hoàng Tro (cấp 60) | ⬜ Alpha |
| 6 | Băng Nguyên Bắc Cực | 60–72 | Thủy + Kim | Chuyển chức 2 (kịch bản) | Bản Ngã Bóng Tối (cấp 70) | Long Băng Bắc Cực (cấp 72) | ⬜ Beta |
| 7 | Quần Đảo Thiên Không | 72–84 | Kim + Mộc | Lãnh địa cấp 5, xây Cảng Khí Cầu (kịch bản) | Thiên Không Cự Thần (cấp 82) | Kỳ Lân Mây (cấp 84) | ⬜ Beta |
| 8 | Vực Hư Vô | 84–95 | Hư Vô (không hệ) | Thiên phú tiến hoá 2 lần (kịch bản) | Giáo Chủ Hư Vô (cấp 93) | Hư Vô Thú (cấp 95) | ⬜ Beta |
| 9 | Cổng Thiên Đạo | 95–100 | Tất cả (theo tầng) | Chuyển chức 3 (kịch bản) | Ma Tôn Vô Diện (cấp 100) | Thiên Đạo Hư Ảnh (cấp 100) | ⬜ Beta |

Mỗi vùng gồm 3 map con (Ngoài rìa → Trung tâm → Lõi) và 1 dungeon boss (kịch bản mục 6). Lưới khai phá 15 ô mỗi map con, tổng khoảng 45 ô mỗi vùng (kịch bản: 40–60). Vùng 1 giữ lưới 10 ô hiện có cho map đầu.

## 3. Chi tiết từng vùng

### Vùng 1 — Rừng Sương (cấp 1–10, hệ Mộc)

**Mở khoá:** Bắt đầu game. **Sang vùng tiếp theo:** Hạ Sói Chúa Hư Vô + cấp 10 + khai phá ≥ 60% vùng 1.

**Môi trường**

| Cơ chế | Chi tiết |
| --- | --- |
| Sương mù nhẹ | Tầm nhìn còn khoảng 60% màn hình (vignette). Ở Lõi Sương, quái cách xa hơn 20 m bị mờ. |
| Vùng hướng dẫn | Quái không theo vào Làng Thanh Thạch; hồi sinh ở làng sau 2,5 giây |

**Map con**

| Map | Cấp | Nội dung |
| --- | --- | --- |
| 1-1 Bìa Rừng Sương | 1–4 | Làng Thanh Thạch, Lễ Thức Tỉnh, lưới khai phá đầu tiên (10 ô) |
| 1-2 Rừng Sương Sâu | 4–7 | Lưới khai phá 15 ô, Ổ quái, lối vào Hang Sói Chúa |
| 1-3 Lõi Sương | 7–10 | Mở sau khi hạ Sói Chúa; lưới 15 ô; boss hiếm Lão Thụ Sương Mù |
| Dungeon: Hang Sói Chúa | 6 | Boss chương 1 |

**Khai phá:** lưới 40 ô (10 + 15 + 15). Tài nguyên: Rừng gỗ → Xưởng Gỗ; thảo dược.  
**Bộ trang bị vùng:** Bộ Thợ Săn Sương — 2: +8% HP · 4: +10% Tấn công · 6: Xoáy Kiếm hồi chiêu 6 → 4 giây. ✅ Đã có

**Quái thường**

| Quái | Loại | Hệ | Cấp | HP | Tấn công | Phòng thủ | Tốc · Tầm | EXP | Kỹ năng | Đạo Tặc cướp |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Sói Sương ✅ | Nhanh | Mộc | 1–7 | 18 → 188 | 8 → 36 | 4 → 11 | 160 · 3,4 m | 30 → 556 | **Cắn** (vung 0,45 s, ×1,0). Đi bầy 2–3 con | STR 35 · AGI 50 · VIT 15 |
| Nấm Độc ✅ | Xa | Thổ | 2–7 | 51 → 212 | 13 → 36 | 5 → 11 | 70 · 24 m | 85 → 556 | **Phun bào tử** (vung 0,7 s, đạn 28 m/s, ×1,0). Chết để lại vũng độc 3 m, 2% HP/giây trong 3 giây | VIT 45 · INT 35 · LUK 20 |
| Tinh Linh Sương ✅ | Phép | Thủy | 5–10 | 147 → 308 | 35 → 66 | 8 → 14 | 110 · 18 m | 335 → 949 | **Lao sương** (vung 0,35 s, lao 15 m, ×1,0). Ở Lõi Sương: tàng hình khi cách hơn 20 m | AGI 35 · INT 45 · LUK 20 |
| Mộc Tinh | Giáp | Mộc | 6–10 | 205 → 356 | 35 → 55 | 24 → 36 | 70 · 4,0 m | 441 → 949 | **Dậm đất** (vung 1,0 s, vòng 6 m, ×1,4). Chậm nhưng khó hạ | STR 40 · VIT 60 |

**Quái tinh anh** (viền sáng, có 1 kỹ năng riêng; luôn rơi đồ Xanh dương/Tím; 30% Đạo Tặc cướp)

| Quái | Loại | Hệ | Cấp | HP | Tấn công | Phòng thủ | Tốc · Tầm | EXP | Kỹ năng | Đạo Tặc cướp |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Sói Đầu Đàn | Nhanh | Mộc | 3–8 | 276 → 823 | 24 → 54 | 9 → 18 | 160 · 3,4 m | 468 → 2.037 | **Hú gọi** (hồi 15 s): gọi 2 Sói Sương; cả bầy +20% tốc chạy 6 giây | STR 35 · AGI 50 · VIT 15 |
| Nấm Mẹ | Lì | Thổ | 5–10 | 783 → 1.672 | 36 → 67 | 20 → 35 | 80 · 3,6 m | 1.005 → 2.847 | **Sinh sôi** (mỗi 8 s): đẻ 2 nấm con (loại Bầy), nấm con tự nổ sau 3 giây, vòng 3 m, ×1,5 | VIT 45 · INT 35 · LUK 20 |

**Boss chương 1: Sói Chúa Hư Vô** — **đã có trong game** (chỉ số theo công thức mục 1 từ M3)

| Cấp | Hệ | HP | Tấn công | Phòng thủ | Phá Thế | Cấp khuyến nghị | EXP | Vàng |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 6 | Mộc | 4.023 | 43 | 24 | 670 | 5 | 1.545 | 300 |

| Giai đoạn | Kỹ năng |
| --- | --- |
| 1 (100% → 50%) | **Cắn** (vung 0,55 s, ×1,0, 5,8 m) · **Vồ** (khi người chơi cách hơn 15 m, hồi 5 s: vòng đỏ 8 m tại chỗ người chơi, vung 0,85 s, ×2,0) |
| 2 (dưới 50%) | Gọi 3 Sói Sương cấp 5 · **Ẩn mình trong sương**: chỉ hiện khi vung đòn, bị choáng, hoặc người chơi đứng gần dưới 14 m |

- **Rơi:** 1 đồ Tím (25% thuộc Bộ Thợ Săn Sương) · 15% **Nanh Sói Chúa** (vũ khí Cam: đòn chém thứ 3 thêm 60% sát thương) ✅ · 3 Thiên Phú Tinh Hoa · 1 Tinh Kim.
- **Đạo Tặc sao chép:** **Vồ Mồi**: lao tới điểm ngắm (tối đa 30 m), ×2,5 sát thương vòng 9 m (✅).

**Boss hiếm: Lão Thụ Sương Mù** — xuất hiện ngẫu nhiên 2 lần/ngày ở Lõi Sương (kịch bản mục 5)

| Cấp | Hệ | Loại | HP | Tấn công | Phòng thủ | EXP | Vàng |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 9 | Mộc | Lì | 16.566 | 75 | 43 | 6.284 | 720 |

- **Kỹ năng:** **Rễ Trói** (vung 1,2 s: 3 vòng 3 m quanh người chơi, ×1,2, trói 1,5 s) · **Lá Độc** (nón 60°, 10 m, ×1,0 + độc 2% HP/giây 4 giây). Dưới 40% HP: **Rừng Thức Tỉnh** — gọi 2 Mộc Tinh, hồi 1% HP/giây khi còn rễ (phá 3 gốc rễ để ngắt)
- **Rơi:** **Vỏ Lão Thụ** (bùa Cam: đứng yên 1 giây thì hồi 2% HP/giây) · 1 Tinh Hoa Tiến Hoá · 5 Thiên Phú Tinh Hoa

### Vùng 2 — Đồng Bằng Gió Hú (cấp 10–20, hệ Kim)

**Mở khoá:** Hạ Sói Chúa (kịch bản). **Sang vùng tiếp theo:** Hạ Tướng Gián Điệp Huyền Ảnh + **Lực chiến 5.000** (kịch bản).

**Môi trường**

| Cơ chế | Chi tiết |
| --- | --- |
| Gió đổi hướng | Mỗi 12 giây đổi hướng (mũi tên báo trước 2 giây). Đẩy người chơi 6 m/giây theo hướng gió; ngược gió −30% tốc chạy, xuôi gió +20% |
| Đạn bị lệch | Đạn và mũi tên lệch 15° theo hướng gió (cả của người chơi lẫn quái) |

**Map con**

| Map | Cấp | Nội dung |
| --- | --- | --- |
| 2-1 Cửa Gió | 10–13 | Lưới 15 ô |
| 2-2 Thảo Nguyên Hú | 13–17 | Lưới 15 ô; Mỏ đá đầu tiên |
| Thành Biên Đài | — | Thành an toàn: Liên minh Khai Giới, cửa hàng, nhiệm vụ cốt truyện chương 2 |
| 2-3 Mắt Bão | 17–20 | Lưới 15 ô; gió đổi mỗi 8 giây; boss hiếm Bạch Hổ Phong Vân |
| Dungeon: Phủ Huyền Ảnh | 18 | Boss chương 2 |

**Khai phá:** lưới 45 ô. Tài nguyên: Rừng thưa → Xưởng Gỗ; Núi đá → **Mỏ** (Đá); Suối → **Bến Cá** (buff lãnh địa: +3% HP tối đa mỗi cấp công trình, tối đa +15%; không tạo tài nguyên mới — Q26).  
**Bộ trang bị vùng:** Bộ Phong Hành — 2: +8% tốc chạy · 4: +8% tốc đánh · 6: né lăn hồi 3 → 2 giây. ⬜

**Quái thường**

| Quái | Loại | Hệ | Cấp | HP | Tấn công | Phòng thủ | Tốc · Tầm | EXP | Kỹ năng | Đạo Tặc cướp |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Ưng Gió | Nhanh | Kim | 10–16 | 274 → 445 | 49 → 77 | 14 → 22 | 160 · 3,4 m | 949 → 1.920 | **Bổ nhào** (bay lên 0,6 s rồi lao 12 m, ×1,3). Xuôi gió +50% tốc | AGI 60 · LUK 40 |
| Lính Đánh Thuê Hư Vô | Giáp | Kim | 11–18 | 394 → 660 | 60 → 95 | 39 → 60 | 70 · 4,0 m | 1.094 → 2.291 | **Khiên chặn**: giảm 70% sát thương từ phía trước — đánh từ bên hoặc sau. **Đâm** (vung 0,6 s, ×1,2) | STR 50 · VIT 50 |
| Cung Thủ Thảo Nguyên | Xa | Mộc | 12–19 | 372 → 597 | 59 → 91 | 17 → 25 | 70 · 24 m | 1.247 → 2.485 | **Bắn ba mũi** (vung 0,8 s, nón 30°, mỗi mũi ×0,7) | AGI 70 · LUK 30 |
| Lốc Xoáy Con | Phép | Kim | 14–20 | 436 → 629 | 90 → 127 | 19 → 26 | 110 · 18 m | 1.571 → 2.683 | **Hút** (vung 1,0 s): kéo người chơi trong 8 m về phía nó 3 m/giây trong 2 giây, rồi nổ vòng 4 m ×1,5 | INT 60 · AGI 40 |

**Quái tinh anh** (viền sáng, có 1 kỹ năng riêng; luôn rơi đồ Xanh dương/Tím; 30% Đạo Tặc cướp)

| Quái | Loại | Hệ | Cấp | HP | Tấn công | Phòng thủ | Tốc · Tầm | EXP | Kỹ năng | Đạo Tặc cướp |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Đội Trưởng Đánh Thuê | Giáp | Kim | 13–19 | 1.699 → 2.533 | 94 → 135 | 68 → 94 | 70 · 4,0 m | 4.218 → 7.455 | **Chém xoáy** (hồi 10 s): 3 vòng chém 360°, 5 m, mỗi vòng ×1,6 | STR 60 · VIT 40 |
| Phù Thuỷ Gió | Phép | Kim | 15–20 | 1.789 → 2.405 | 130 → 170 | 31 → 40 | 110 · 18 m | 5.229 → 8.049 | **Nghịch Phong** (hồi 14 s): đổi hướng gió ngay lập tức, gió mạnh ×2 trong 6 giây | INT 60 · LUK 40 |

**Boss chương 2: Tướng Gián Điệp Huyền Ảnh**

| Cấp | Hệ | HP | Tấn công | Phòng thủ | Phá Thế | Cấp khuyến nghị | EXP | Vàng |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 18 | Kim | 18.804 | 132 | 60 | 3.134 | 17 | 17.477 | 900 |

| Giai đoạn | Kỹ năng |
| --- | --- |
| 1 (100% → 60%) | **Ám tiễn** (vung 0,5 s: 3 phi tiêu nón 40°, mỗi phi tiêu ×0,8) · **Thoắt ẩn** (hồi 6 s: dịch chuyển ra sau lưng người chơi, vung 0,4 s, ×1,5) |
| 2 (60% → 25%) | **Phân thân**: tạo 2 bản sao (mỗi bản 8% HP boss, đánh ×0,5). **Chỉ bản thật có bóng** (kịch bản). Đánh trúng bản giả: nó nổ vòng 4 m ×0,8 |
| 3 (dưới 25%) | **Vạn Ảnh**: 4 bản sao, cả 5 đổi chỗ cho nhau mỗi 6 giây |

- **Rơi:** 1 đồ Tím · 15% **Mặt Nạ Huyền Ảnh** (mũ Cam: né lăn để lại 1 phân thân hút đòn trong 2 giây) · 3 Thiên Phú Tinh Hoa · 1 Tinh Kim.
- **Đạo Tặc sao chép:** **Phân Thân**: tạo 2 ảo ảnh hút đòn của quái trong 6 giây (⬜).

**Boss hiếm: Bạch Hổ Phong Vân** — xuất hiện ngẫu nhiên 2 lần/ngày ở Mắt Bão (kịch bản mục 5)

| Cấp | Hệ | Loại | HP | Tấn công | Phòng thủ | EXP | Vàng |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 20 | Kim | Nhanh | 42.640 | 159 | 53 | 38.411 | 1.600 |

- **Kỹ năng:** **Hổ Vồ** (chuỗi 3 cú vồ liên tiếp, mỗi cú vòng 6 m, ×1,4) · **Gầm Gió** (vòng 10 m: đẩy lùi 8 m, choáng 1 giây). Dưới 50%: **Cưỡi Gió** — luôn xuôi gió, tốc ×1,5
- **Rơi:** **Vuốt Bạch Hổ** (găng Cam: đòn chí mạng gây chảy máu ×0,3 mỗi giây trong 4 giây) · 1 Tinh Hoa Tiến Hoá · 5 Thiên Phú Tinh Hoa

### Vùng 3 — Sa Mạc Xích Sa (cấp 20–32, hệ Thổ)

**Mở khoá:** Lực chiến 5.000 (kịch bản). **Sang vùng tiếp theo:** Hạ Bọ Cạp Sa Hoàng + **chuyển chức 1** (kịch bản).

**Môi trường**

| Cơ chế | Chi tiết |
| --- | --- |
| Ngày / đêm | Chu kỳ 6 phút: 4 phút ngày, 2 phút đêm |
| Nắng gắt (ban ngày) | Mất 1% HP mỗi 5 giây khi không đứng trong bóng râm hoặc ốc đảo; uống nước ở ốc đảo xoá 60 giây |
| Đêm | Quái +15% Tấn công; tầm nhìn 70% |
| Bão cát | Ngẫu nhiên mỗi 3–5 phút, 30 giây: tầm nhìn 40%, đạn bay chậm 30% |

**Map con**

| Map | Cấp | Nội dung |
| --- | --- | --- |
| 3-1 Rìa Cát Đỏ | 20–24 | Lưới 15 ô |
| 3-2 Ốc Đảo Lãng Quên | 24–28 | Lưới 15 ô; ốc đảo là vùng an toàn khỏi nắng |
| 3-3 Di Tích Khai Giới Giả | 28–32 | Lưới 15 ô; cốt truyện chương 3; boss hiếm Nhân Sư Đá |
| Dungeon: Sào Huyệt Sa Hoàng | 30 | Boss chương 3 |

**Khai phá:** lưới 45 ô. Tài nguyên: Mỏ đá, Mỏ sắt (**Sắt**), ốc đảo → Vườn Thảo Dược.  
**Bộ trang bị vùng:** Bộ Sa Hành Giả — 2: miễn nhiễm Nắng gắt · 4: +10% Phòng thủ · 6: Xoáy Kiếm để lại lốc cát 4 giây làm chậm 40%. ⬜

**Quái thường**

| Quái | Loại | Hệ | Cấp | HP | Tấn công | Phòng thủ | Tốc · Tầm | EXP | Kỹ năng | Đạo Tặc cướp |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Bọ Cát | Bầy | Thổ | 20–26 | 358 → 467 | 63 → 82 | 20 → 25 | 140 · 3,0 m | 2.683 → 3.977 | Đi bầy 5 con. **Cắn** (vung 0,4 s, ×1,0) | VIT 50 · STR 50 |
| Rắn Đồi Cát | Nhanh | Thổ | 21–28 | 588 → 788 | 100 → 132 | 28 → 36 | 160 · 3,4 m | 2.887 → 4.445 | **Chui cát** 1,5 giây (bất tử, có vệt cát báo), trồi lên dưới chân người chơi, ×1,4 | AGI 60 · STR 40 |
| Xác Ướp Khai Giới | Lì | Thổ | 24–32 | 1.115 → 1.495 | 113 → 150 | 51 → 66 | 80 · 3,6 m | 3.527 → 5.431 | **Nguyền rủa** (vung 0,8 s): −20% hồi máu trong 6 giây | VIT 60 · INT 40 |
| Pháp Sư Cát | Phép | Hỏa | 26–32 | 822 → 1.015 | 163 → 200 | 34 → 41 | 110 · 18 m | 3.977 → 5.431 | **Lốc cát** (vung 1,0 s, vòng 7 m, ×1,0, làm chậm 40% trong 3 giây) | INT 70 · LUK 30 |

**Quái tinh anh** (viền sáng, có 1 kỹ năng riêng; luôn rơi đồ Xanh dương/Tím; 30% Đạo Tặc cướp)

| Quái | Loại | Hệ | Cấp | HP | Tấn công | Phòng thủ | Tốc · Tầm | EXP | Kỹ năng | Đạo Tặc cướp |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Bọ Hung Giáp Vàng | Giáp | Kim | 23–30 | 3.089 → 4.062 | 162 → 210 | 112 → 144 | 70 · 4,0 m | 9.927 → 14.790 | **Lăn cầu** (hồi 9 s): lăn thẳng 20 m, ×1,8; giáp phía trước như Lính Đánh Thuê | VIT 70 · STR 30 |
| Thủ Lĩnh Xác Ướp | Lì | Thổ | 27–32 | 4.701 → 5.592 | 171 → 201 | 85 → 99 | 80 · 3,6 m | 12.627 → 16.293 | **Hồi sinh** (hồi 20 s): dựng lại 2 Xác Ướp vừa bị hạ | INT 50 · VIT 50 |

**Boss chương 3: Bọ Cạp Sa Hoàng**

| Cấp | Hệ | HP | Tấn công | Phòng thủ | Phá Thế | Cấp khuyến nghị | EXP | Vàng |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 30 | Thổ | 32.737 | 220 | 96 | 5.456 | 29 | 57.357 | 1.500 |

| Giai đoạn | Kỹ năng |
| --- | --- |
| 1 (100% → 50%) | **Kìm kẹp** (vung 0,6 s, ×1,3, giữ người chơi 1 giây) · **Đuôi độc** (vòng 8 m tại chỗ người chơi, vung 0,9 s, ×1,5 + độc 2% HP/giây 5 giây) |
| 2 (dưới 50%) | **Chui xuống cát** (kịch bản): bất tử 3 giây, trồi lên dưới chân người chơi vòng 7 m, ×2,2 (vết cát báo 1,2 s) · **Bão cát** (kịch bản): tầm nhìn 40% suốt giai đoạn |

- **Rơi:** 1 đồ Tím · 15% **Đuôi Sa Hoàng** (vũ khí Cam: đòn đánh gây độc ×0,2 mỗi giây trong 4 giây, cộng dồn 3 lần) · 3 Thiên Phú Tinh Hoa · 1 Tinh Kim.
- **Đạo Tặc sao chép:** **Độn Thổ**: chui đất 1,5 giây (bất tử), trồi lên vòng 7 m ×2,0 (⬜).

**Boss hiếm: Nhân Sư Đá** — xuất hiện ngẫu nhiên 2 lần/ngày ở Di Tích Khai Giới Giả (kịch bản mục 5)

| Cấp | Hệ | Loại | HP | Tấn công | Phòng thủ | EXP | Vàng |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 32 | Thổ | Giáp | 55.290 | 279 | 204 | 109.150 | 2.560 |

- **Kỹ năng:** **Câu Đố Nhân Sư**: mỗi khi mất 25% HP, hiện 3 cột đá mang 3 hệ — đứng vào cột mang hệ **khắc Thổ** (Mộc) trong 4 giây, sai cột nhận ×3. **Ánh mắt hoá đá** (nón 45°, 14 m: hoá đá 1,5 giây)
- **Rơi:** **Mắt Nhân Sư** (dây chuyền Cam: +10% chí mạng; chí mạng vào quái bị khắc hệ ×1,2) · 1 Tinh Hoa Tiến Hoá · 5 Thiên Phú Tinh Hoa

### Vùng 4 — Đầm Lầy U Minh (cấp 32–45, hệ Thủy)

**Mở khoá:** Chuyển chức 1 (kịch bản). **Sang vùng tiếp theo:** Hạ Nữ Vương Phệ Mộng + **Thiên phú tiến hoá 1 lần** (kịch bản).

**Môi trường**

| Cơ chế | Chi tiết |
| --- | --- |
| Độc tích luỹ | Mỗi 10 giây trong nước đầm +1 tầng độc (tối đa 10; mỗi tầng mất 0,3% HP/giây). Đứng trên đất khô 3 giây giảm 1 tầng; Thuốc Giải xoá hết |
| Ảo ảnh | 20% quái là ảo ảnh: trúng 1 đòn là tan, không cho EXP, không rơi đồ |

**Map con**

| Map | Cấp | Nội dung |
| --- | --- | --- |
| 4-1 Bãi Lau Mù | 32–36 | Lưới 15 ô |
| 4-2 Đầm Sâu | 36–41 | Lưới 15 ô; phần lớn là nước |
| 4-3 Cung Mộng | 41–45 | Lưới 15 ô; cốt truyện chương 4 (tiến hoá bắt buộc); boss hiếm Thuỷ Quái Thất Đầu |
| Dungeon: Cung Phệ Mộng | 43 | Boss chương 4 |

**Khai phá:** lưới 45 ô. Tài nguyên: Bãi lau → Xưởng Gỗ; đầm → **Vườn Thảo Dược** (Thuốc Giải).  
**Bộ trang bị vùng:** Bộ U Minh — 2: độc tích luỹ chậm 50% · 4: +12% HP · 6: đòn đánh 15% gây 1 tầng độc lên quái. ⬜

**Quái thường**

| Quái | Loại | Hệ | Cấp | HP | Tấn công | Phòng thủ | Tốc · Tầm | EXP | Kỹ năng | Đạo Tặc cướp |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Ếch Độc | Xa | Thủy | 32–38 | 1.015 → 1.208 | 150 → 177 | 41 → 48 | 70 · 24 m | 5.431 → 7.027 | **Lưỡi độc** (vung 0,7 s, 12 m): kéo người chơi 4 m, +1 tầng độc | AGI 50 · VIT 50 |
| Đỉa Hút Máu | Nhanh | Thủy | 33–40 | 931 → 1.131 | 154 → 186 | 42 → 50 | 160 · 3,4 m | 5.687 → 7.589 | **Bám**: dính vào người chơi, hút 1% HP/giây và hồi cho nó; né lăn để gỡ | VIT 60 · LUK 40 |
| Hồn Ma Đầm | Phép | Thủy | 36–45 | 1.143 → 1.433 | 224 → 279 | 46 → 56 | 110 · 18 m | 6.480 → 9.056 | **Phân ảnh** (hồi 12 s): tạo 2 ảo ảnh 1 HP · **Tiếng than** (vòng 8 m, ×1,1) | INT 70 · LUK 30 |
| Cá Sấu Bùn | Giáp | Thổ | 38–45 | 1.420 → 1.687 | 197 → 232 | 120 → 141 | 70 · 4,0 m | 7.027 → 9.056 | **Đớp** (vung 0,8 s, ×1,8) + kéo xuống nước: choáng 1 giây | STR 60 · VIT 40 |

**Quái tinh anh** (viền sáng, có 1 kỹ năng riêng; luôn rơi đồ Xanh dương/Tím; 30% Đạo Tặc cướp)

| Quái | Loại | Hệ | Cấp | HP | Tấn công | Phòng thủ | Tốc · Tầm | EXP | Kỹ năng | Đạo Tặc cướp |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Phù Thuỷ Đầm Lầy | Phép | Thủy | 36–43 | 4.378 → 5.241 | 301 → 358 | 68 → 81 | 110 · 18 m | 19.440 → 25.377 | **Mưa độc** (hồi 12 s): vùng 10 m trong 5 giây, +2 tầng độc mỗi giây | INT 70 · VIT 30 |
| Cá Sấu Chúa | Giáp | Thổ | 40–45 | 5.452 → 6.147 | 278 → 312 | 189 → 212 | 70 · 4,0 m | 22.767 → 27.168 | **Cuộn tử thần** (hồi 14 s): giữ người chơi 2 giây, ×0,6 mỗi 0,5 s; né lăn đúng lúc vung để thoát | STR 70 · VIT 30 |

**Boss chương 4: Nữ Vương Phệ Mộng**

| Cấp | Hệ | HP | Tấn công | Phòng thủ | Phá Thế | Cấp khuyến nghị | EXP | Vàng |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 43 | Thủy | 56.534 | 316 | 135 | 9.422 | 42 | 127.293 | 2.150 |

| Giai đoạn | Kỹ năng |
| --- | --- |
| 1 (100% → 60%) | **Lời ru** (sóng vòng 12 m, vung 1,0 s, ×1,0, chậm 50% trong 3 giây) · **Gai mộng** (3 gai thẳng, ×1,4) |
| 2 (60% → 25%) | **Giấc mơ** (kịch bản): kéo người chơi vào giấc mơ 12 giây, **đảo ngược điều khiển** (trái ↔ phải, lên ↔ xuống); phá 3 Mộng Châu để thoát sớm |
| 3 (dưới 25%) | **Phệ mộng**: hút 2% HP/giây với người chơi trong 15 m nếu không đứng trong vòng sáng (vòng sáng di chuyển chậm) |

- **Rơi:** 1 đồ Tím · 15% **Gối Mộng** (bùa Cam: 15% né hoàn toàn một đòn) · 3 Thiên Phú Tinh Hoa · 1 Tinh Kim.
- **Đạo Tặc sao chép:** **Mộng Cảnh**: quái trong 10 m đánh nhau trong 4 giây (⬜).

**Boss hiếm: Thuỷ Quái Thất Đầu** — xuất hiện ngẫu nhiên 2 lần/ngày ở Cung Mộng (kịch bản mục 5)

| Cấp | Hệ | Loại | HP | Tấn công | Phòng thủ | EXP | Vàng |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 45 | Thủy | Lì | 88.521 | 350 | 183 | 232.789 | 3.600 |

- **Kỹ năng:** **7 đầu**, mỗi đầu thanh máu riêng (14% HP boss). Đầu bị chặt mọc lại sau 20 giây nếu không bị đòn **hệ Hỏa** trong 5 giây sau khi chặt (Thủy bị Hỏa khắc ngược — dùng ngọc/Ngũ Hành). Mỗi đầu: **Phun nước** (thẳng 15 m, ×1,2)
- **Rơi:** **Vảy Thất Đầu** (áo Cam: hồi 1% HP/giây, +20% kháng Thủy) · 1 Tinh Hoa Tiến Hoá · 5 Thiên Phú Tinh Hoa

### Vùng 5 — Núi Viêm Long (cấp 45–60, hệ Hỏa)

**Mở khoá:** Thiên phú tiến hoá 1 lần (kịch bản). **Sang vùng tiếp theo:** Hạ Viêm Long + **chuyển chức 2** (kịch bản).

**Môi trường**

| Cơ chế | Chi tiết |
| --- | --- |
| Dung nham | Ô dung nham: mất 5% HP/giây |
| Núi lửa phun | Mỗi 45 giây: 8 thiên thạch, mỗi viên có vòng báo 1,5 giây, trúng mất 25% HP |
| Nhiệt | Đứng trong 5 m quanh dung nham: +10% tốc đánh (thưởng cho người dám đứng gần) |

**Map con**

| Map | Cấp | Nội dung |
| --- | --- | --- |
| 5-1 Chân Núi Tro | 45–50 | Lưới 15 ô |
| 5-2 Sườn Dung Nham | 50–55 | Lưới 15 ô |
| 5-3 Miệng Núi Lửa | 55–60 | Lưới 15 ô; boss hiếm Phượng Hoàng Tro |
| Dungeon: Long Huyệt | 58 | Boss chương 5 |

**Khai phá:** lưới 45 ô. Tài nguyên: Mỏ sắt, **Mỏ Tinh Thạch**.  
**Bộ trang bị vùng:** Bộ Hoả Ngục — 2: +30% kháng Hỏa · 4: +10% Tấn công · 6: Xoáy Kiếm để lại vòng lửa 5 giây, ×0,3 mỗi giây. ⬜

**Quái thường**

| Quái | Loại | Hệ | Cấp | HP | Tấn công | Phòng thủ | Tốc · Tầm | EXP | Kỹ năng | Đạo Tặc cướp |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Thằn Lằn Lửa | Nhanh | Hỏa | 45–52 | 1.273 → 1.473 | 209 → 241 | 56 → 65 | 160 · 3,4 m | 9.056 → 11.249 | Chạy để lại vệt lửa 3 giây (×0,2 mỗi giây). **Cắn** ×1,0 | AGI 60 · STR 40 |
| Người Đá Dung Nham | Giáp | Thổ | 47–56 | 1.763 → 2.105 | 243 → 288 | 147 → 174 | 70 · 4,0 m | 9.666 → 12.572 | **Đấm** (×1,3). Khi bị hạ vỡ thành 3 mảnh đá nhỏ (loại Bầy) | VIT 60 · STR 40 |
| Linh Hồn Lửa | Tự nổ | Hỏa | 48–58 | 1.054 → 1.275 | 619 → 746 | 38 → 45 | 170 · 2,0 m | 9.977 → 13.251 | Lao tới người chơi, **tự nổ** sau vung 0,8 s, vòng 5 m | INT 50 · LUK 50 |
| Pháp Sư Hoả Diệm | Phép | Hỏa | 52–60 | 1.658 → 1.915 | 321 → 370 | 65 → 74 | 110 · 18 m | 11.249 → 13.943 | **Cột lửa** (vung 1,0 s: 3 cột nối tiếp về phía người chơi, mỗi cột ×1,2) | INT 70 · LUK 30 |

**Quái tinh anh** (viền sáng, có 1 kỹ năng riêng; luôn rơi đồ Xanh dương/Tím; 30% Đạo Tặc cướp)

| Quái | Loại | Hệ | Cấp | HP | Tấn công | Phòng thủ | Tốc · Tầm | EXP | Kỹ năng | Đạo Tặc cướp |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Rồng Non Lửa | Nhanh | Hỏa | 50–58 | 5.426 → 6.303 | 312 → 361 | 94 → 108 | 160 · 3,4 m | 31.821 → 39.753 | **Phun lửa** (hồi 10 s): nón 60°, 12 m, ×0,5 mỗi 0,2 s trong 2 giây | STR 50 · INT 50 |
| Thợ Rèn Hư Vô | Giáp | Kim | 54–60 | 7.398 → 8.233 | 374 → 415 | 252 → 279 | 70 · 4,0 m | 35.715 → 41.829 | **Búa rèn** (hồi 12 s): đập vòng 6 m ×2,0; quái trong 10 m +20% Tấn công 8 giây | STR 70 · VIT 30 |

**Boss chương 5: Viêm Long**

| Cấp | Hệ | HP | Tấn công | Phòng thủ | Phá Thế | Cấp khuyến nghị | EXP | Vàng |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 58 | Hỏa | 77.128 | 427 | 180 | 12.855 | 57 | 246.083 | 2.900 |

| Giai đoạn | Kỹ năng |
| --- | --- |
| 1 (100% → 60%) | **Vuốt** (×1,5) · **Long tức** (nón 70°, 18 m, ×0,6 mỗi 0,25 s trong 2,5 giây) |
| 2 (60% → 20%) | Bay lên. **Dung nham dâng theo lượt** (kịch bản): mỗi 20 giây nền ngập dung nham 6 giây, chỉ 5 đá nổi an toàn; mưa thiên thạch như môi trường |
| 3 (dưới 20%) | Rơi xuống, **Cuồng nộ**: +30% tốc đánh, Long tức mỗi 8 giây |

- **Rơi:** 1 đồ Tím · 15% **Long Tâm** (nhẫn Cam: +20% sát thương hệ Hỏa; miễn dung nham 2 giây sau khi né) · 3 Thiên Phú Tinh Hoa · 1 Tinh Kim.
- **Đạo Tặc sao chép:** **Long Tức**: phun lửa nón 12 m, ×0,5 mỗi 0,25 s trong 2 giây (⬜).

**Boss hiếm: Phượng Hoàng Tro** — xuất hiện ngẫu nhiên 2 lần/ngày ở Miệng Núi Lửa (kịch bản mục 5)

| Cấp | Hệ | Loại | HP | Tấn công | Phòng thủ | EXP | Vàng |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 60 | Hỏa | Phép | 130.423 | 619 | 149 | 462.228 | 4.800 |

- **Kỹ năng:** **Niết bàn**: lần đầu bị hạ hồi sinh 50% HP, **trừ khi** trúng đòn hệ Thủy trong 5 giây cuối · **Mưa lông lửa** (12 vòng 3 m ngẫu nhiên, ×1,0)
- **Rơi:** **Lông Phượng** (bùa Cam: mỗi 5 phút, lần đầu bị hạ thì hồi sinh 30% HP) · 1 Tinh Hoa Tiến Hoá · 5 Thiên Phú Tinh Hoa

### Vùng 6 — Băng Nguyên Bắc Cực (cấp 60–72, hệ Thủy + Kim)

**Mở khoá:** Chuyển chức 2 (kịch bản). **Sang vùng tiếp theo:** Hạ Bản Ngã Bóng Tối + **lãnh địa cấp 5, xây Cảng Khí Cầu** (kịch bản).

**Môi trường**

| Cơ chế | Chi tiết |
| --- | --- |
| Băng giá | Đứng yên quá 2 giây: +1 tầng (−10% tốc chạy mỗi tầng); 5 tầng → đông cứng 1,5 giây. Di chuyển hoặc đứng cạnh lửa trại để giảm |
| Đêm dài | Chu kỳ 8 phút, 6 phút đêm: tầm nhìn 60% |
| Mặt băng trơn | Dừng lại vẫn trượt thêm 0,3 giây |

**Map con**

| Map | Cấp | Nội dung |
| --- | --- | --- |
| 6-1 Đồng Tuyết | 60–64 | Lưới 15 ô |
| 6-2 Rừng Băng | 64–68 | Lưới 15 ô |
| 6-3 Đỉnh Cực Quang | 68–72 | Lưới 15 ô; cốt truyện chương 6 (mảnh Thiên phú thứ hai thức giấc); boss hiếm Long Băng |
| Dungeon: Gương Băng Vĩnh Dạ | 70 | Boss chương 6 |

**Khai phá:** lưới 45 ô. Tài nguyên: Mỏ Tinh Thạch, rừng thông → Xưởng Gỗ.  
**Bộ trang bị vùng:** Bộ Cực Quang — 2: miễn băng giá dưới 3 tầng · 4: +10% chí mạng · 6: đòn chí mạng làm chậm quái 30%. ⬜

**Quái thường**

| Quái | Loại | Hệ | Cấp | HP | Tấn công | Phòng thủ | Tốc · Tầm | EXP | Kỹ năng | Đạo Tặc cướp |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Sói Băng | Bầy | Thủy | 60–66 | 1.087 → 1.197 | 185 → 203 | 56 → 61 | 140 · 3,0 m | 13.943 → 16.086 | Đi bầy 4 con. **Cắn** ×1,0 + 1 tầng băng giá | AGI 60 · STR 40 |
| Người Tuyết | Lì | Thủy | 61–68 | 2.871 → 3.204 | 282 → 314 | 123 → 136 | 80 · 3,6 m | 14.293 → 16.822 | **Ném cầu tuyết** (vung 0,9 s, ×1,3, vòng 3 m) | VIT 60 · STR 40 |
| Tinh Linh Băng | Phép | Thủy | 63–72 | 2.011 → 2.300 | 388 → 443 | 78 → 89 | 110 · 18 m | 15.001 → 18.328 | **Băng trụ** (vung 1,0 s, vòng 4 m, ×1,1, đóng băng 1 giây) | INT 70 · LUK 30 |
| Cung Thủ Băng | Xa | Kim | 65–72 | 2.075 → 2.300 | 300 → 332 | 80 → 89 | 70 · 24 m | 15.721 → 18.328 | **Mũi tên xuyên** (xuyên mọi mục tiêu trên đường, ×1,0) | AGI 70 · LUK 30 |

**Quái tinh anh** (viền sáng, có 1 kỹ năng riêng; luôn rơi đồ Xanh dương/Tím; 30% Đạo Tặc cướp)

| Quái | Loại | Hệ | Cấp | HP | Tấn công | Phòng thủ | Tốc · Tầm | EXP | Kỹ năng | Đạo Tặc cướp |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Gấu Băng Khổng Lồ | Lì | Thủy | 63–70 | 11.118 → 12.366 | 391 → 434 | 190 → 211 | 80 · 3,6 m | 45.003 → 52.710 | **Đập băng** (hồi 10 s): nứt nền 3 đường thẳng 15 m, mỗi đường ×1,8 | STR 60 · VIT 40 |
| Pháp Sư Bão Tuyết | Phép | Kim | 66–72 | 8.078 → 8.818 | 547 → 596 | 122 → 133 | 110 · 18 m | 48.258 → 54.984 | **Bão tuyết** (hồi 15 s): vùng 14 m trong 6 giây, +1 tầng băng giá mỗi giây | INT 70 · VIT 30 |

**Boss chương 6: Bản Ngã Bóng Tối**

| Cấp | Hệ | HP | Tấn công | Phòng thủ | Phá Thế | Cấp khuyến nghị | EXP | Vàng |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 70 | theo hệ người chơi | 93.604 | 515 | 216 | 15.601 | 69 | 395.274 | 3.500 |

| Giai đoạn | Kỹ năng |
| --- | --- |
| 1 (100% → 50%) | **Sao chép Thiên phú và kỹ năng của chính người chơi** (kịch bản): dùng lại kỹ năng người chơi vừa dùng 3 giây trước, với 80% chỉ số của người chơi |
| 2 (50% → 20%) | **Gương vỡ**: 4 tấm gương, boss ẩn trong 1 tấm (tấm có bóng tối). Đánh nhầm gương: gương phản 50% sát thương |
| 3 (dưới 20%) | Dùng Thiên phú của người chơi ở **dạng tiến hoá cao nhất** của Thiên phú đó |

- **Rơi:** 1 đồ Tím · 15% **Gương Bản Ngã** (bùa Cam: 10% phản 50% sát thương nhận) · 3 Thiên Phú Tinh Hoa · 1 Tinh Kim.
- **Đạo Tặc sao chép:** **Kính Ảnh**: tạo 1 bản sao của bản thân 8 giây, gây 50% sát thương (⬜).

**Boss hiếm: Long Băng Bắc Cực** — xuất hiện ngẫu nhiên 2 lần/ngày ở Đỉnh Cực Quang (kịch bản mục 5)

| Cấp | Hệ | Loại | HP | Tấn công | Phòng thủ | EXP | Vàng |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 72 | Thủy | Lì | 142.516 | 556 | 289 | 695.429 | 5.760 |

- **Kỹ năng:** **Hơi thở vĩnh đông** (nón 90°, 20 m: đóng băng nền 3 giây, ai đứng trên bị +2 tầng băng giá mỗi giây) · **Mưa băng** (15 vòng 3 m, ×1,2)
- **Rơi:** **Vảy Long Băng** (giày Cam: miễn băng giá, +15% tốc chạy) · 1 Tinh Hoa Tiến Hoá · 5 Thiên Phú Tinh Hoa

### Vùng 7 — Quần Đảo Thiên Không (cấp 72–84, hệ Kim + Mộc)

**Mở khoá:** Lãnh địa cấp 5, xây Cảng Khí Cầu (kịch bản). **Sang vùng tiếp theo:** Hạ Thiên Không Cự Thần + **Thiên phú tiến hoá 2 lần** (kịch bản).

**Môi trường**

| Cơ chế | Chi tiết |
| --- | --- |
| Đảo bay | Rơi khỏi mép đảo: về điểm lưu gần nhất, mất 10% HP (kịch bản) |
| Cầu gió | Cầu nối giữa các đảo tắt 5 giây sau mỗi 30 giây |
| Đảo vỡ | Ở Thiên Cung Đổ Nát, mép đảo sụp 1 m mỗi 10 giây |

**Map con**

| Map | Cấp | Nội dung |
| --- | --- | --- |
| 7-1 Đảo Mây Trôi | 72–76 | Lưới 15 ô |
| 7-2 Đảo Rừng Treo | 76–80 | Lưới 15 ô |
| 7-3 Thiên Cung Đổ Nát | 80–84 | Lưới 15 ô; cốt truyện chương 7 (Bia Đá gốc, tiến hoá bắt buộc); boss hiếm Kỳ Lân Mây |
| Dungeon: Đài Cự Thần | 82 | Boss chương 7 |

**Khai phá:** lưới 45 ô. Tài nguyên: Rừng treo → Xưởng Gỗ, **Mỏ Tinh Thạch**.  
**Bộ trang bị vùng:** Bộ Thiên Phong — 2: không bị đẩy lùi · 4: +10% tốc đánh · 6: rơi khỏi mép không mất HP (1 lần/phút). ⬜

**Quái thường**

| Quái | Loại | Hệ | Cấp | HP | Tấn công | Phòng thủ | Tốc · Tầm | EXP | Kỹ năng | Đạo Tặc cướp |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Đại Bàng Mây | Nhanh | Kim | 72–78 | 2.045 → 2.216 | 332 → 360 | 89 → 96 | 160 · 3,4 m | 18.328 → 20.666 | **Quạt cánh** (vung 0,6 s): đẩy lùi 5 m (thường về phía mép đảo) | AGI 70 · LUK 30 |
| Người Gỗ Đảo Bay | Giáp | Mộc | 73–80 | 2.751 → 3.017 | 374 → 410 | 225 → 246 | 70 · 4,0 m | 18.711 → 21.466 | **Rễ quật** (vòng 5 m, ×1,3) | VIT 60 · STR 40 |
| Tiên Gió | Phép | Mộc | 75–84 | 2.397 → 2.686 | 461 → 516 | 92 → 103 | 110 · 18 m | 19.486 → 23.096 | **Hồi phục**: hồi 5% HP cho đồng bọn trong 10 m mỗi 2 giây — nên hạ trước | INT 60 · LUK 40 |
| Hiệp Sĩ Thiên Không | Lì | Kim | 78–84 | 3.679 → 3.963 | 360 → 387 | 156 → 168 | 80 · 3,6 m | 20.666 → 23.096 | **Thương phá** (vung 0,8 s, đâm xuyên 15 m, ×1,6) | STR 60 · VIT 40 |

**Quái tinh anh** (viền sáng, có 1 kỹ năng riêng; luôn rơi đồ Xanh dương/Tím; 30% Đạo Tặc cướp)

| Quái | Loại | Hệ | Cấp | HP | Tấn công | Phòng thủ | Tốc · Tầm | EXP | Kỹ năng | Đạo Tặc cướp |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Thủ Hộ Đảo | Giáp | Kim | 75–82 | 10.318 → 11.292 | 517 → 564 | 346 → 378 | 70 · 4,0 m | 58.458 → 66.828 | **Khiên trời** (hồi 18 s): đồng bọn trong 10 m bất tử 4 giây | VIT 70 · INT 30 |
| Rồng Mây | Nhanh | Mộc | 78–84 | 8.496 → 9.153 | 483 → 520 | 144 → 155 | 160 · 3,4 m | 61.998 → 69.288 | Bay vòng quanh; **Lao mây** (hồi 8 s, ×2,0) | AGI 60 · STR 40 |

**Boss chương 7: Thiên Không Cự Thần**

| Cấp | Hệ | HP | Tấn công | Phòng thủ | Phá Thế | Cấp khuyến nghị | EXP | Vàng |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 82 | Kim | 110.081 | 604 | 252 | 18.347 | 81 | 563.780 | 4.100 |

| Giai đoạn | Kỹ năng |
| --- | --- |
| 1 (100% → 60%) | **Đấm đất** (vòng 8 m, ×2,0, ô nền đó vỡ 10 giây) · **Mưa đá** (10 vòng 3 m, ×1,0) |
| 2 (60% → 20%) | **Đảo bay vỡ dần, chiến trường thu nhỏ** (kịch bản): mỗi 15 giây mất 1 vòng mép; rơi khỏi mép → về điểm lưu, boss hồi 5% HP |
| 3 (dưới 20%) | **Thiên chuỳ**: nện 3 lần liên tiếp vòng 12 m, mỗi lần ×3,0 (vung 1,2 s mỗi lần) |

- **Rơi:** 1 đồ Tím · 15% **Búa Cự Thần** (vũ khí Cam: đòn thứ 3 tạo sóng chấn vòng 6 m ×0,8) · 3 Thiên Phú Tinh Hoa · 1 Tinh Kim.
- **Đạo Tặc sao chép:** **Thiên Chuỳ**: nện đất vòng 10 m ×3,0, choáng 1 giây (⬜).

**Boss hiếm: Kỳ Lân Mây** — xuất hiện ngẫu nhiên 2 lần/ngày ở Thiên Cung Đổ Nát (kịch bản mục 5)

| Cấp | Hệ | Loại | HP | Tấn công | Phòng thủ | EXP | Vàng |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 84 | Mộc | Nhanh | 183.097 | 648 | 206 | 983.824 | 6.720 |

- **Kỹ năng:** Chạy vòng quanh đảo, để lại vệt sấm (×0,4 mỗi giây). **Chỉ đánh được khi nó dừng 3 giây** giữa các vòng · **Sấm sét** (5 vòng 4 m, ×1,5)
- **Rơi:** **Sừng Kỳ Lân** (dây chuyền Cam: +20% hiệu lực hồi máu; mỗi 10 giây hồi 5% HP) · 1 Tinh Hoa Tiến Hoá · 5 Thiên Phú Tinh Hoa

### Vùng 8 — Vực Hư Vô (cấp 84–95, hệ Hư Vô (không hệ))

**Mở khoá:** Thiên phú tiến hoá 2 lần (kịch bản). **Sang vùng tiếp theo:** Hạ Giáo Chủ Hư Vô + **chuyển chức 3** (kịch bản).

**Môi trường**

| Cơ chế | Chi tiết |
| --- | --- |
| Thiên phú yếu dần | Mỗi 60 giây ở trong vực, hiệu lực Thiên phú −10% (tối đa −50%) (kịch bản). Đứng cạnh **Đèn Tinh Quang** 5 giây để hồi lại |
| Không hệ | Quái không có hệ: khắc hệ không có tác dụng, cả với người chơi lẫn quái |

**Map con**

| Map | Cấp | Nội dung |
| --- | --- | --- |
| 8-1 Rìa Vực | 84–88 | Lưới 15 ô |
| 8-2 Đáy Vực | 88–92 | Lưới 15 ô; Đèn Tinh Quang thưa dần |
| 8-3 Sào Huyệt Hư Vô | 92–95 | Lưới 15 ô; cốt truyện chương 8; boss hiếm Hư Vô Thú |
| Dungeon: Điện Giáo Chủ | 93 | Boss chương 8 |

**Khai phá:** lưới 45 ô. Tài nguyên: Không có tài nguyên thường; khai phá cho **Tinh Thạch** ×3; boss rơi **Lõi Hư Vô** (vật phẩm cốt truyện, nâng Hoàng Thành — không phải tiền tệ, Q26).  
**Bộ trang bị vùng:** Bộ Tinh Quang — 2: Thiên phú yếu dần chậm 50% · 4: +12% HP · 6: mỗi 60 giây miễn 1 lần bị vô hiệu Thiên phú. ⬜

**Quái thường**

| Quái | Loại | Hệ | Cấp | HP | Tấn công | Phòng thủ | Tốc · Tầm | EXP | Kỹ năng | Đạo Tặc cướp |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Bóng Hư Vô | Nhanh | Hư Vô | 84–90 | 2.387 → 2.559 | 387 → 415 | 103 → 110 | 160 · 3,4 m | 23.096 → 25.614 | Tàng hình khi đứng yên; **Đâm lén** từ sau lưng ×1,8 | AGI 70 · LUK 30 |
| Kẻ Nuốt Thiên Phú | Phép | Hư Vô | 85–92 | 2.718 → 2.943 | 522 → 565 | 104 → 113 | 110 · 18 m | 23.510 → 26.473 | Đòn trúng xoá 1 hiệu ứng có lợi và làm Thiên phú yếu thêm 5% | INT 70 · LUK 30 |
| Giáp Sĩ Hư Vô | Giáp | Hư Vô | 87–95 | 3.284 → 3.588 | 445 → 486 | 267 → 291 | 70 · 4,0 m | 24.344 → 27.778 | **Chém nặng** (vung 1,0 s, ×1,6) | STR 50 · VIT 50 |
| Mắt Hư Vô | Xa | Hư Vô | 89–95 | 2.846 → 3.039 | 410 → 437 | 109 → 116 | 70 · 24 m | 25.189 → 27.778 | **Tia nhìn**: chiếu liên tục ×0,3 mỗi 0,2 s; nấp sau vật cản để tránh | INT 60 · AGI 40 |

**Quái tinh anh** (viền sáng, có 1 kỹ năng riêng; luôn rơi đồ Xanh dương/Tím; 30% Đạo Tặc cướp)

| Quái | Loại | Hệ | Cấp | HP | Tấn công | Phòng thủ | Tốc · Tầm | EXP | Kỹ năng | Đạo Tặc cướp |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Tư Tế Hư Vô | Phép | Hư Vô | 88–94 | 10.791 → 11.531 | 726 → 775 | 162 → 173 | 110 · 18 m | 74.295 → 82.023 | **Tế lễ** (hồi 15 s): hiến 1 quái gần đó để hồi 30% HP và +30% Tấn công cho đồng bọn trong 12 m | INT 70 · VIT 30 |
| Quái Vật Không Mặt | Lì | Hư Vô | 90–95 | 15.932 → 16.823 | 557 → 588 | 269 → 284 | 80 · 3,6 m | 76.842 → 83.334 | **Vô diện**: miễn nhiễm sát thương từ phía trước, chỉ đánh được sau lưng | VIT 60 · STR 40 |

**Boss chương 8: Giáo Chủ Hư Vô**

| Cấp | Hệ | HP | Tấn công | Phòng thủ | Phá Thế | Cấp khuyến nghị | EXP | Vàng |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 93 | Hư Vô | 125.184 | 685 | 285 | 20.864 | 92 | 751.718 | 4.650 |

| Giai đoạn | Kỹ năng |
| --- | --- |
| 1 (100% → 60%) | **Phong ấn hư vô** (vòng 10 m tại chỗ người chơi, vung 1,0 s, ×1,8) · **Tia hư vô** (thẳng 25 m, ×1,2) |
| 2 (60% → 25%) | **Hút Thiên phú** (kịch bản): vô hiệu hoá Thiên phú người chơi 10 giây, mỗi 30 giây |
| 3 (dưới 25%) | Gọi 4 Tư Tế Hư Vô; mỗi lần Tư Tế tế lễ, boss +10% Tấn công |

- **Rơi:** 1 đồ Tím · 15% **Ấn Hư Vô** (nhẫn Cam: miễn hiệu ứng Thiên phú yếu dần) · 3 Thiên Phú Tinh Hoa · 1 Tinh Kim.
- **Đạo Tặc sao chép:** **Hút Thiên Phú**: quái trong 12 m mất mọi tăng cường 6 giây, hút 10% HP của chúng (⬜).

**Boss hiếm: Hư Vô Thú** — xuất hiện ngẫu nhiên 2 lần/ngày ở Sào Huyệt Hư Vô (kịch bản mục 5)

| Cấp | Hệ | Loại | HP | Tấn công | Phòng thủ | EXP | Vàng |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 95 | Hư Vô | Lì | 188.514 | 731 | 378 | 1.304.170 | 7.600 |

- **Kỹ năng:** **Nuốt ánh sáng**: mỗi 20 giây tắt 1 Đèn Tinh Quang trong trận (4 đèn) · **Hàm hư vô** (nón 60°, 10 m, ×2,0)
- **Rơi:** **Nanh Hư Vô** (vũ khí Cam: bỏ qua 30% Phòng thủ của quái) · 1 Tinh Hoa Tiến Hoá · 5 Thiên Phú Tinh Hoa

### Vùng 9 — Cổng Thiên Đạo (cấp 95–100, hệ Tất cả (theo tầng))

**Mở khoá:** Chuyển chức 3 (kịch bản). **Sang vùng tiếp theo:** Hạ Ma Tôn Vô Diện → chọn 1 trong 2 kết thúc, mở endgame.

**Môi trường**

| Cơ chế | Chi tiết |
| --- | --- |
| Mỗi tầng một hệ | 9 tầng; khi vào tầng, hệ của tầng chọn ngẫu nhiên (kịch bản). Mọi quái trong tầng mang hệ đó |
| Ấn Hệ | Mỗi tầng có 1 Ấn Hệ: nhặt được thì đòn đánh tạm mang hệ khắc của tầng trong 60 giây |

**Map con**

| Map | Cấp | Nội dung |
| --- | --- | --- |
| 9-1 Tầng 1–3 | 95–97 | Mỗi tầng 5 ô khai phá |
| 9-2 Tầng 4–6 | 97–99 | Mỗi tầng 5 ô khai phá |
| 9-3 Tầng 7–9 | 99–100 | Mỗi tầng 5 ô khai phá |
| Dungeon: Thiên Đạo Chi Môn | 100 | Boss chương 9 |

**Khai phá:** lưới 45 ô (9 tầng × 5). Tài nguyên: Không có; phần thưởng là Tinh Hoa Tiến Hoá.  
**Bộ trang bị vùng:** Bộ Thiên Đạo — 2: +5% mọi chỉ số · 4: khắc hệ +20% · 6: kỹ năng L hồi nhanh 30%. ⬜

**Quái thường**

| Quái | Loại | Hệ | Cấp | HP | Tấn công | Phòng thủ | Tốc · Tầm | EXP | Kỹ năng | Đạo Tặc cướp |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Thiên Binh Ngũ Hành | Giáp | theo tầng | 95–100 | 3.588 → 3.778 | 486 → 511 | 291 → 306 | 70 · 4,0 m | 27.778 → 30.000 | **Kích ngũ hành** (×1,4, hệ của tầng) | STR 50 · VIT 50 |
| Tàn Hồn Khai Giới Giả | Phép | theo tầng | 95–100 | 3.039 → 3.200 | 583 → 614 | 116 → 122 | 110 · 18 m | 27.778 → 30.000 | Mang 1 Thiên phú ngẫu nhiên trong 20 và dùng kỹ năng L của Thiên phú đó | INT 50 · LUK 50 |
| Thiên Mã | Nhanh | theo tầng | 96–100 | 2.730 → 2.844 | 442 → 460 | 118 → 122 | 160 · 3,4 m | 28.218 → 30.000 | **Phi nước đại** (lao 20 m, ×1,5) | AGI 70 · VIT 30 |
| Ngũ Hành Linh Thú | Lì | theo tầng | 97–100 | 4.581 → 4.723 | 446 → 460 | 193 → 199 | 80 · 3,6 m | 28.660 → 30.000 | **Gầm ngũ hành** (vòng 8 m, ×1,2): người chơi mất thưởng khắc hệ 5 giây | VIT 50 · STR 50 |

**Quái tinh anh** (viền sáng, có 1 kỹ năng riêng; luôn rơi đồ Xanh dương/Tím; 30% Đạo Tặc cướp)

| Quái | Loại | Hệ | Cấp | HP | Tấn công | Phòng thủ | Tốc · Tầm | EXP | Kỹ năng | Đạo Tặc cướp |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Thiên Tướng | Giáp | theo tầng | 96–100 | 13.239 → 13.795 | 660 → 687 | 441 → 459 | 70 · 4,0 m | 84.654 → 90.000 | **Thiên phạt** (hồi 12 s): 5 cột sét vòng 4 m, mỗi cột ×1,6 | STR 60 · VIT 40 |
| Ngũ Hành Sứ Giả | Phép | đổi mỗi 8 s | 97–100 | 11.901 → 12.271 | 800 → 824 | 178 → 184 | 110 · 18 m | 85.980 → 90.000 | Đổi hệ mỗi 8 giây; chỉ nhận sát thương từ hệ khắc hệ hiện tại | INT 60 · LUK 40 |

**Boss chương 9: Ma Tôn Vô Diện**

| Cấp | Hệ | HP | Tấn công | Phòng thủ | Phá Thế | Cấp khuyến nghị | EXP | Vàng |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 100 | đổi mỗi 10 s | 134.796 | 736 | 306 | 22.466 | 99 | 903.566 | 5.000 |

| Giai đoạn | Kỹ năng |
| --- | --- |
| 1 (100% → 66%) | Dùng kỹ năng của boss chương 1–3: Vồ, Phân thân, Chui xuống cát |
| 2 (66% → 33%) | Kỹ năng boss chương 4–6: Giấc mơ (đảo điều khiển), Dung nham dâng, Sao chép Thiên phú người chơi |
| 3 (dưới 33%) | Kỹ năng boss chương 7–8: Chiến trường thu nhỏ, Hút Thiên phú; thêm **Vô Diện** — đổi hệ mỗi 10 giây (kịch bản: "3 giai đoạn, dùng Thiên phú của mọi boss trước đó") |

- **Rơi:** 2 đồ Tím · 100% lần đầu **Mặt Nạ Vô Diện** (mũ Cam: mỗi 30 giây đòn đánh đổi sang hệ khắc mục tiêu) · 3 Thiên Phú Tinh Hoa · 1 Tinh Kim.
- **Đạo Tặc sao chép:** **Vô Diện**: dùng ngẫu nhiên 1 kỹ năng boss đã sao chép với ×1,5 sát thương (⬜).

**Boss hiếm: Thiên Đạo Hư Ảnh** — xuất hiện ngẫu nhiên 2 lần/ngày ở Endgame (sau khi hạ Ma Tôn) (kịch bản mục 5)

| Cấp | Hệ | Loại | HP | Tấn công | Phòng thủ | EXP | Vàng |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 100 | Tất cả | Phép | 218.214 | 1026 | 245 | 1.505.943 | 8.000 |

- **Kỹ năng:** Dùng ngẫu nhiên 3 Thiên phú hạng S trở lên trong 20, đổi mỗi giai đoạn (3 giai đoạn)
- **Rơi:** 3 Tinh Hoa Tiến Hoá · 10 Thiên Phú Tinh Hoa · đồ Cam ngẫu nhiên của mọi vùng

## 4. Đồ Cam theo vùng

| Vùng | Từ boss chương (15%) | Từ boss hiếm |
| --- | --- | --- |
| 1. Rừng Sương | Nanh Sói Chúa — vũ khí Cam: đòn chém thứ 3 thêm 60% sát thương | Vỏ Lão Thụ — bùa Cam: đứng yên 1 giây thì hồi 2% HP/giây |
| 2. Đồng Bằng Gió Hú | Mặt Nạ Huyền Ảnh — mũ Cam: né lăn để lại 1 phân thân hút đòn trong 2 giây | Vuốt Bạch Hổ — găng Cam: đòn chí mạng gây chảy máu ×0,3 mỗi giây trong 4 giây |
| 3. Sa Mạc Xích Sa | Đuôi Sa Hoàng — vũ khí Cam: đòn đánh gây độc ×0,2 mỗi giây trong 4 giây, cộng dồn 3 lần | Mắt Nhân Sư — dây chuyền Cam: +10% chí mạng; chí mạng vào quái bị khắc hệ ×1,2 |
| 4. Đầm Lầy U Minh | Gối Mộng — bùa Cam: 15% né hoàn toàn một đòn | Vảy Thất Đầu — áo Cam: hồi 1% HP/giây, +20% kháng Thủy |
| 5. Núi Viêm Long | Long Tâm — nhẫn Cam: +20% sát thương hệ Hỏa; miễn dung nham 2 giây sau khi né | Lông Phượng — bùa Cam: mỗi 5 phút, lần đầu bị hạ thì hồi sinh 30% HP |
| 6. Băng Nguyên Bắc Cực | Gương Bản Ngã — bùa Cam: 10% phản 50% sát thương nhận | Vảy Long Băng — giày Cam: miễn băng giá, +15% tốc chạy |
| 7. Quần Đảo Thiên Không | Búa Cự Thần — vũ khí Cam: đòn thứ 3 tạo sóng chấn vòng 6 m ×0,8 | Sừng Kỳ Lân — dây chuyền Cam: +20% hiệu lực hồi máu; mỗi 10 giây hồi 5% HP |
| 8. Vực Hư Vô | Ấn Hư Vô — nhẫn Cam: miễn hiệu ứng Thiên phú yếu dần | Nanh Hư Vô — vũ khí Cam: bỏ qua 30% Phòng thủ của quái |
| 9. Cổng Thiên Đạo | Mặt Nạ Vô Diện — mũ Cam: mỗi 30 giây đòn đánh đổi sang hệ khắc mục tiêu | 3 Tinh Hoa Tiến Hoá · 10 Thiên Phú Tinh Hoa · đồ Cam ngẫu nhiên của mọi vùng |

## 5. Kỹ năng Đạo Tặc sao chép từ boss

Dùng bằng phím L (Thiên phú Đạo Tặc, [05-thien-phu-chi-tiet](05-thien-phu-chi-tiet.md)). Học được khi hạ boss lần đầu; chọn kỹ năng đang dùng trong bảng Thiên phú.

| Boss | Kỹ năng sao chép | Code |
| --- | --- | --- |
| Sói Chúa Hư Vô (chương 1) | **Vồ Mồi**: lao tới điểm ngắm (tối đa 30 m), ×2,5 sát thương vòng 9 m | ✅ |
| Tướng Gián Điệp Huyền Ảnh (chương 2) | **Phân Thân**: tạo 2 ảo ảnh hút đòn của quái trong 6 giây | ⬜ |
| Bọ Cạp Sa Hoàng (chương 3) | **Độn Thổ**: chui đất 1,5 giây (bất tử), trồi lên vòng 7 m ×2,0 | ⬜ |
| Nữ Vương Phệ Mộng (chương 4) | **Mộng Cảnh**: quái trong 10 m đánh nhau trong 4 giây | ⬜ |
| Viêm Long (chương 5) | **Long Tức**: phun lửa nón 12 m, ×0,5 mỗi 0,25 s trong 2 giây | ⬜ |
| Bản Ngã Bóng Tối (chương 6) | **Kính Ảnh**: tạo 1 bản sao của bản thân 8 giây, gây 50% sát thương | ⬜ |
| Thiên Không Cự Thần (chương 7) | **Thiên Chuỳ**: nện đất vòng 10 m ×3,0, choáng 1 giây | ⬜ |
| Giáo Chủ Hư Vô (chương 8) | **Hút Thiên Phú**: quái trong 12 m mất mọi tăng cường 6 giây, hút 10% HP của chúng | ⬜ |
| Ma Tôn Vô Diện (chương 9) | **Vô Diện**: dùng ngẫu nhiên 1 kỹ năng boss đã sao chép với ×1,5 sát thương | ⬜ |

## 6. Kế hoạch làm

| Đợt | Nội dung |
| --- | --- |
| M3 | ✅ Xong 20/10/2026 — **Áp công thức chỉ số mới cho vùng 1 (Q22)**: quái lấy chỉ số từ công thức trong code thay cho bảng số cứng · boss chương 1 = 90 đòn (Q23) · Thanh Phá Thế + kỹ năng riêng cho quái tinh anh vùng 1 (Sói Đầu Đàn, Nấm Mẹ) · thêm Mộc Tinh |
| M4 | Vùng 1 đủ 3 map con, 40 ô (Bìa Rừng, Rừng Sâu, Lõi Sương mở sau boss — Q24, Q25) · toàn bộ vùng 2, 45 ô · Mỏ (Đá, Sắt), Bến Cá dạng buff (Q26) · bộ Phong Hành · Mặt Nạ Huyền Ảnh |
| M5 | Boss hiếm vùng 1–2 (Lão Thụ, Bạch Hổ) · tinh chỉnh hệ số công thức (số đòn, % HP) từ dữ liệu playtest |
| Alpha | Vùng 3–5 |
| Beta | Vùng 6–9 |

## 7. Quyết định đã chốt (20/10/2026)

Chủ dự án uỷ quyền chọn phương án tốt nhất, hợp thị trường. Căn cứ chung: ARPG/idle hiện nay (Diablo Immortal, Vampire Survivors, Solo Leveling: Arise, các game nhập vai mobile ở Việt Nam và Đông Nam Á) cần **30 phút đầu trơn tru** (quyết định tỉ lệ giữ chân ngày 1), **trận đấu ngắn** hợp phiên chơi 5–15 phút, và **ít loại tiền tệ** (nhiều tài nguyên là lời chê phổ biến).

| # | Câu hỏi | Quyết định | Lý do |
| --- | --- | --- | --- |
| Q22 | Áp công thức chỉ số mới cho vùng 1? | **Có, áp ở M3** (không đợi M5); M5 chỉ tinh chỉnh hệ số | M3 phải cân bằng 20 Thiên phú × 2 lớp; cân trên số cũ rồi M5 đổi công thức là làm 2 lần. Công thức trong code còn giúp thêm vùng mới không phải nhập tay chỉ số (KT-02) |
| Q23 | Số đòn mục tiêu | **Quái thường 3, tinh anh 12 giữ nguyên; boss chương 1 = 90 đòn, chương 2–3 = 110, chương 4+ = 130; boss hiếm 200** | Quái chết nhanh là cảm giác "đã tay" của thể loại. Boss đầu tiên nằm trong 30 phút đầu nên phải thắng được ngay lần đầu (≈ 35–40 giây); boss sau dài dần để có chỗ cho cơ chế giai đoạn |
| Q24 | Mỗi map con 15 ô (45 ô/vùng) | **Giữ**; vùng 1 = 40 ô (10 + 15 + 15) | Nằm trong khoảng 40–60 của kịch bản; mỗi map con chơi xong trong 1–2 phiên ngắn |
| Q25 | Vùng 1: boss cấp 6 giữa vùng, Lõi Sương (7–10) mở sau boss | **Giữ** | Khớp 30 phút đầu của kịch bản (boss ở phút 23–28). Lõi Sương thành nội dung "sau boss" có boss hiếm, giữ người chơi ở lại chương 1 tới cấp 10 |
| Q26 | Tài nguyên mới | **Giữ Đá, Sắt, Tinh Thạch** (kịch bản có). **Bỏ Tinh Thạch Hư Vô** khỏi danh sách tiền tệ: thay bằng Tinh Thạch ×3 và vật phẩm cốt truyện Lõi Hư Vô. **Bến Cá không tạo tài nguyên**, chỉ cho buff lãnh địa +3% HP mỗi cấp (tối đa +15%) | Giữ số tài nguyên trên HUD ở mức hiện tại + 3. Mỗi tài nguyên mới phải có chỗ tiêu rõ ràng |
| Q27 | Tên, kỹ năng, đồ Cam do thiết kế đặt | **Như tài liệu**; tên theo phong cách Hán-Việt của kịch bản | Giữ đúng cơ chế 1 dòng của kịch bản cho 9 boss chương. Tên có thể đổi khi có người viết cốt truyện mà không ảnh hưởng chỉ số |
