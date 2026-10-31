# Lớp thứ 4 và thứ 5: Hộ Vệ, Triệu Hồi Sư

| | |
| --- | --- |
| Dự án | Thiên Phú Khai Giới |
| Nguồn | **Hộ Vệ:** [kịch bản](kich-ban-game-thien-phu-khai-gioi.md) mục 4 — *"Hộ Vệ · Đỡ đòn, hỗ trợ · Thể lực · Hiệp Sĩ → Thánh Kỵ Sĩ / Thiết Vệ → Thủ Hộ Thần"*; kế hoạch NV-04. **Triệu Hồi Sư:** yêu cầu của chủ dự án 22/10/2026 — *"should make another class (5th) Triệu hồi sư"* → **CR-03** ([03 Phụ lục A](03-mvp-spec.md)) |
| Loại tài liệu | Đặc tả + kế hoạch triển khai |
| Trạng thái | ✅ **LH1 + LH2 đã code** (mục 7) theo bảng CL2. Hộ Vệ theo kịch bản. Triệu Hồi Sư là thiết kế mới — số liệu và tên nhánh theo cột Mặc định mục 6 (Q110–Q117), **chủ dự án có thể sửa**. Số đánh dấu *(cân bằng)* đã chỉnh sau khi chạy test cân bằng |
| Đợt | **LH1** Hộ Vệ · **LH2** Triệu Hồi Sư |

> **CL2 (27/10/2026, [docs/21](21-thiet-ke-lai-5-lop.md) mục 6, chủ dự án duyệt theo mặc định):** 7 kỹ năng đổi theo [charactors.md](charactors.md), đánh dấu *(CL2)* trong bảng 2.2 và 3.2 — Hộ Vệ: Khiên Thép, Chấn Địa (choáng), Thành Bất Diệt; Triệu Hồi Sư: Sói Bóng, Tiểu Quỷ (thay Linh Bạo), Liên Kết Linh Hồn, Quân Đoàn Linh Hồn. Khiêu Khích giữ nguyên. **Đã code theo bảng mới** (LH1/LH2).

## 1. Phạm vi

Cả hai lớp đủ như 3 lớp hiện có, theo hệ kỹ năng [docs/13](13-he-ky-nang.md):

- Đánh thường + đặc tính lớp.
- **13 kỹ năng**, cùng khung mở khoá với 3 lớp cũ:

  | Vị trí | Mở ở | Ghi chú |
  | --- | --- | --- |
  | 1–2 | cấp 1 | |
  | 3 | cấp 4 | |
  | 4 | cấp 8 | kỹ năng hỗ trợ (`mul = 0`) |
  | 5 | cấp 15 | |
  | 6 | cấp 22 | |
  | 7–8 | cấp 30 | chuyển chức 1 |
  | 9 | cấp 45 | tối thượng |
  | 10–13 | cấp 60 | 2 kỹ năng mỗi nhánh chuyển chức 2 |

  Kỹ năng 5–13 đều gây sát thương, nên test chung SK2-T2, SK3-T2 áp được.
- Chuyển chức 1 ở cấp 30 (1 chức) và chuyển chức 2 ở cấp 60 (2 nhánh): cùng nhiệm vụ, cùng thưởng +10% HP và Tấn công như lớp cũ, mỗi chức một bị động riêng.
- Biến thể 3 tầng và Bí Kíp dùng chung bảng của docs/13 mục 4.2, không cần dữ liệu riêng.
- Hình nhân vật (thân × giới tính × 3 màu da + 4 kiểu tóc), 13 icon kỹ năng + icon đánh thường, kiểu vũ khí riêng.
- Chọn lớp ở màn tạo nhân vật (5 lớp).

**Ngoài phạm vi:** chuyển chức 3 (cấp 90, NV-07 — kịch bản: Thủ Hộ Thần; Triệu Hồi Sư: Vạn Linh Chi Chủ, Q115) — làm cùng chuyển chức 3 của mọi lớp. **Đã làm ở J3** ([23](23-chuyen-chuc-3-linh-thu-co-mau.md)).

**Save:** không đổi phiên bản — `class_id` đã là chuỗi; linh thú thường trực của Triệu Hồi Sư sinh lại khi vào map, không lưu.

## 2. Hộ Vệ (`ho-ve`) — LH1

| | |
| --- | --- |
| Vai trò | Cận chiến, đỡ đòn, hỗ trợ (kịch bản) |
| Chỉ số chính | **VIT** — vừa cho Tấn công vừa cho HP |
| Chỉ số mặc định (UI-19, tổng 17) | STR 4 · AGI 2 · INT 2 · VIT 6 · LUK 3 |
| HP nền | 115 + 17 × (cấp − 1) — dày nhất (Kiếm Khách 100 + 15) |
| Tấn công từ điểm | VIT × **1,5** + STR × 1,5 *(cân bằng; ban đầu VIT × 1,0)* (Kiếm Khách: STR × 2). Bot test cộng 8 STR : 12 VIT → 30 (Kiếm Khách 24) — bù việc Hộ Vệ không có đòn đánh xa như Kiếm Khí |
| Tự cộng điểm | 3 VIT : 2 STR |
| Đặc tính lớp — **Khiên** | Nhận ít hơn 15% sát thương (cộng dồn nhân với Thiết Bích, kháng hệ) |
| Đánh thường — **Đập Khiên** | Như Chém của Kiếm Khách (nón 60°, 8 m, 0,5 giây/đòn) |
| Vũ khí | Chùy + khiên (kiểu `mace`) — chỉ số như Kiếm |
| Hình | Giáp sắt xám, áo choàng lam đậm, khiên tròn viền vàng ở tay sau, chùy ở tay trước |

### 2.1. Chuyển chức

| Mốc | Chức | Bị động |
| --- | --- | --- |
| 1 (cấp 30) | **Hiệp Sĩ** (`hiep-si`) | Mỗi đòn thứ 4 **phóng sóng khiên 25 m xuyên quái ×0,8** (như Kiếm Sư) và choáng quái thường trước mặt 0,8 giây *(cân bằng; ban đầu: đập khiên ×1,5 tại chỗ)* |
| 2a (cấp 60) | **Thánh Kỵ Sĩ** (`thanh-ky-si`) | Hút máu 5% sát thương gây ra; HP trên 70% thì +15% sát thương |
| 2b (cấp 60) | **Thiết Vệ** (`thiet-ve`) | Nhận ít hơn thêm 15% sát thương; phản 30% sát thương bị đánh lên quái đánh mình |
| 3 (cấp 90) | Thủ Hộ Thần | ✅ J3 — [23 mục 3](23-chuyen-chuc-3-linh-thu-co-mau.md) |

### 2.2. Kỹ năng

| # | Mở | Id | Tên | Hồi / MP | Hiệu ứng |
| --- | --- | --- | --- | --- | --- |
| 1 | 1 | `khienchan` | Khiên Chấn | **5 s** / 15 | Đập khiên nón 90° 9 m **×2,2** *(cân bằng; ban đầu 6 s ×1,8)*, choáng quái thường 1 giây |
| 2 | 1 | `khieukhich` | Khiêu Khích | 9 s / 20 | Gầm vòng 12 m **×1,5** *(cân bằng; ban đầu ×1,2)*, **kéo quái thường về sát mình**; boss/tinh anh nhận gấp đôi vào thanh Phá Thế |
| 3 | 4 | `laokhien` | Lao Khiên | 8 s / 20 | Lao 18 m theo hướng ngắm **×1,8** *(cân bằng; ban đầu ×1,5)* mọi quái trên đường, đẩy lùi 4 m; bất tử khi lao |
| 4 | 8 | `khienthep` | Khiên Thép *(CL2)* | 20 s / 25 | *(hỗ trợ)* 10 giây: +30% Phòng thủ (phản đòn để cho chức Thiết Vệ) |
| 5 | 15 | `chandia` | Chấn Địa *(CL2)* | 8 s / 20 | Đập khiên xuống đất vòng 10 m ×1,5, **choáng 2 giây** quái thường; boss/tinh anh nhận gấp đôi vào thanh Phá Thế |
| 6 | 22 | `phanthuan` | Phi Thuẫn | 7 s / 20 | Ném khiên xuyên 30 m rồi bay về, mỗi lượt ×1,1 |
| 7 | 30 | `phanquyet` | Phán Quyết | 9 s / 25 | *(Hiệp Sĩ)* Búa ánh sáng giáng xuống điểm ngắm, vòng 8 m ×2,4 |
| 8 | 30 | `xungphong` | Xung Phong | 10 s / 25 | *(Hiệp Sĩ)* Lao 25 m ×1,6, quái trúng choáng 1,5 giây |
| 9 | 45 | `thanhbatdiet` | Thành Bất Diệt *(CL2)* | 60 s / 50 | *(Tối thượng)* 8 giây: nhận ít hơn **80%** sát thương, hào quang 12 m ×0,3 mỗi 0,5 giây |
| 10 | 60 | `thanhquang` | Thánh Quang Trảm | 9 s / 30 | *(Thánh Kỵ Sĩ)* Nón ánh sáng 120° 11 m ×3,0, hồi HP bằng 15% sát thương gây ra |
| 11 | 60 | `thanhvuc` | Thánh Vực | 14 s / 35 | *(Thánh Kỵ Sĩ)* Vùng 10 m đi theo mình 5 giây, ×0,4 mỗi 0,5 giây, mỗi nhịp hồi 1,5% HP |
| 12 | 60 | `thietchuy` | Thiết Chuỳ Phá Địa | 10 s / 30 | *(Thiết Vệ)* Đập đất vòng 12 m ×2,6, choáng quái thường 1,5 giây |
| 13 | 60 | `thanhdong` | Thành Đồng | 14 s / 35 | *(Thiết Vệ)* Nổ khiên vòng 9 m ×1,8 + khiên chắn 20% HP tối đa 6 giây |

Kéo quái, choáng, làm chậm không áp lên boss / boss hiếm / tinh anh — chúng nhận thêm vào thanh Phá Thế (như Hống Kiếm). Kéo và đẩy lùi cũng không áp lên quái của trận boss (Mộng Châu, đầu Thuỷ Quái…), vì chúng phải đứng yên theo cơ chế.

## 3. Triệu Hồi Sư (`trieu-hoi-su`) — LH2 (CR-03)

| | |
| --- | --- |
| Vai trò | Đánh xa, **triệu hồi linh thú** — linh thú gây phần lớn sát thương, người chơi giữ khoảng cách và hỗ trợ |
| Chỉ số chính | **INT** (Q110) |
| Chỉ số mặc định | STR 2 · AGI 3 · INT 5 · VIT 4 · LUK 3 |
| HP nền | 88 + 12 × (cấp − 1); MP gốc +20, hồi MP +0,5/giây (Pháp Sư: +30, +1) |
| Tấn công từ điểm | INT × 2 (như Pháp Sư) |
| Tự cộng điểm | 3 INT : 2 VIT |
| Đặc tính lớp — **Linh Hồ** | Luôn có 1 Linh Hồ đồng hành (không chết, không hết giờ, sinh lại khi vào map); 1,25 giây cắn 1 lần, Tấn công = 40% Tấn công người chơi |
| Đánh thường — **Linh Cầu** | Cầu linh hồn bay 40 m **×0,45** *(cân bằng; ban đầu ×0,85 — linh thú gây phần lớn sát thương)*, trúng quái đầu tiên, tự nhắm như Hỏa Cầu; 0,6 giây/đòn |
| Vũ khí | Linh châu (kiểu `orb`) — chỉ số như Kiếm |
| Hình | Áo choàng ngọc lam dài, cổ bạc, quả cầu linh hồn lơ lửng trên tay |
| Khác Tử Linh Sư | Tử Linh Sư (nhánh Pháp Sư) dựng xác quái chết làm Xương Nô. Triệu Hồi Sư gọi **linh thú** bằng kỹ năng, có linh thú thường trực, nhánh chức 2 là rồng hoặc đồ đằng |

**Linh thú** dùng hệ đồng minh có sẵn (`GameWorld.Ally`, D50):

- Không có HP.
- Đánh **quái người chơi vừa đánh** (trong 3 giây gần nhất), kể cả quái ẩn như tấm gương thật của Bản Ngã. Không có thì đánh quái gần người chơi nhất trong **45 m** (thú cưng / Xương Nô: 26 m). Triệu Hồi Sư đứng xa như Pháp Sư.
- Nhận thưởng sát thương đồng minh: Thiên phú nhóm Triệu hồi (Thuần Thú Sư, Bầy Đàn Bóng Tối) và Long Mạch.
- Thêm 2 trường mới:
  - `ranged` — đánh xa, bắn tia từ chỗ nó.
  - `splash` — bán kính nổ lan.
- Kỹ năng gọi linh thú ghi `mul` = hệ số Tấn công của linh thú (so với Tấn công người chơi). Cấp kỹ năng (+8%/cấp) và biến thể (sát thương, ngũ hành) áp lên đòn của linh thú qua `skill_ctx` = id kỹ năng gọi.
- **Mỗi đòn của linh thú gây 70% Tấn công của nó** (`Classes2.SUMMON_HIT`, *cân bằng*): đòn tính như đòn người chơi (chí mạng, khắc hệ, Phá Thế) × hệ số linh thú × 0,7. Nếu tính đủ 100%, Triệu Hồi Sư hạ boss vùng 3 trong 11–16 giây, trong khi các lớp khác cần 28–38 giây.
- Hệ số linh thú gọi bằng kỹ năng **không nhân `skill_mul`** (+0,5% mỗi INT) như kỹ năng khác. Lý do: linh thú đã mạnh theo Tấn công (INT × 2), nhân thêm thì INT tính hai lần — yếu ở cấp thấp, quá mạnh ở cấp cao.
- Nhịp đánh (giây/đòn) *(cân bằng)*: Linh Hồ, Sói Bóng, linh hồn Quân Đoàn 1,25 · Linh Ưng 1,3 · Tiểu Quỷ, Ấu Long 1,5 · Thạch Quỷ 1,6. Phong Đồ Đằng: ×1,4 tốc đánh.

### 3.1. Chuyển chức (Q111–Q113)

| Mốc | Chức | Bị động |
| --- | --- | --- |
| 1 (cấp 30) | **Linh Sư** (`linh-su`) | Thêm 1 Linh Hồ thường trực; linh thú +20% sát thương |
| 2a (cấp 60) | **Ngự Long Sư** (`ngu-long-su`) | Linh Hồ hoá Hoả Hồ: mỗi đòn nổ lan 4 m; linh thú +20% sát thương |
| 2b (cấp 60) | **Đồ Đằng Sư** (`do-dang-su`) | Đồ đằng tồn tại lâu hơn 50%; đứng trong 12 m quanh đồ đằng: hồi 2% HP và 2% MP mỗi giây |
| 3 (cấp 90) | Vạn Linh Chi Chủ | ✅ J3 — [23 mục 3](23-chuyen-chuc-3-linh-thu-co-mau.md) |

### 3.2. Kỹ năng

| # | Mở | Id | Tên | Hồi / MP | Hiệu ứng |
| --- | --- | --- | --- | --- | --- |
| 1 | 1 | `soibong` | Triệu Hồi Sói Bóng *(CL2)* | **20 s** / 20 | Gọi 1 Sói Bóng chiến đấu 20 giây, Tấn công ×0,9 *(hồi chiêu = thời gian sống: luôn đúng 1 sói)* |
| 2 | 1 | `linhtien` | Linh Tiễn | 5 s / 15 | 5 tia linh hồn toả 40°, bay 35 m, mỗi tia **×0,45** *(cân bằng; ban đầu ×0,7)* |
| 3 | 4 | `tieuquy` | Triệu Hồi Tiểu Quỷ *(CL2)* | **16 s** / 20 | Gọi 3 Tiểu Quỷ **đánh xa** 20 m, 12 giây, Tấn công ×0,4 |
| 4 | 8 | `lienket` | Liên Kết Linh Hồn *(CL2)* | 20 s / 25 | *(hỗ trợ)* 8 giây: linh thú +40% sát thương, mình +20% sát thương |
| 5 | 15 | `thachquy` | Gọi Thạch Quỷ | **20 s** / 30 | Gọi 1 Thạch Quỷ 15 giây, Tấn công ×1,4, mỗi đòn nổ lan 5 m |
| 6 | 22 | `hoadieu` | Hoả Điểu | 7 s / 20 | Chim lửa bay thẳng 40 m xuyên quái ×1,8, thiêu 3 giây |
| 7 | 30 | `linhtran` | Linh Trận | 10 s / 30 | *(Linh Sư)* Trận 9 m tại điểm ngắm 4 giây, ×0,45 mỗi 0,5 giây; linh thú trong trận +30% sát thương |
| 8 | 30 | `linhung` | Gọi Linh Ưng | **16 s** / 25 | *(Linh Sư)* Gọi 2 Linh Ưng **đánh xa** 25 m, 12 giây, Tấn công ×0,7 |
| 9 | 45 | `quandoan` | Quân Đoàn Linh Hồn *(CL2)* | 60 s / 50 | *(Tối thượng)* Gọi 10 linh thú 15 giây, Tấn công ×0,45 (tối đa 12 linh thú cùng lúc) |
| 10 | 60 | `aulong` | Gọi Ấu Long | **24 s** / 40 | *(Ngự Long Sư)* Gọi Ấu Long 18 giây: **đánh xa** 22 m, Tấn công ×1,8, nổ lan 6 m |
| 11 | 60 | `longhong` | Long Hống | 10 s / 30 | *(Ngự Long Sư)* Rồng gầm vòng 12 m quanh mình ×2,4; có Ấu Long thì nó gầm thêm 1 lần tại chỗ nó |
| 12 | 60 | `loidodang` | Lôi Đồ Đằng | 12 s / 30 | *(Đồ Đằng Sư)* Cắm cột tại điểm ngắm 10 giây, sét quái gần nhất trong 15 m mỗi 0,5 giây ×0,5 |
| 13 | 60 | `phongdodang` | Phong Đồ Đằng | 14 s / 30 | *(Đồ Đằng Sư)* Cột 8 giây vòng 10 m: ×0,35 mỗi 0,5 giây, làm chậm quái; linh thú trong vòng +40% tốc đánh |

Giới hạn linh thú gọi bằng kỹ năng: tối đa 8 cùng lúc (không tính Linh Hồ thường trực); gọi thêm thì con cũ nhất biến mất.

## 4. Kỹ thuật

| Phần | Thay đổi |
| --- | --- |
| `data/classes.gd` | `ORDER` thêm `ho-ve` (LH1), `trieu-hoi-su` (LH2). `DEFS[c].range` = `"melee"` hoặc `"ranged"` (D51). `JOBS`, `JOBS2`, 13 kỹ năng mỗi lớp |
| `core/stats.gd` | `BASE_STATS`, HP nền, Tấn công từ điểm, MP theo lớp. Bảng `CLASS_STATS` thay `hunter` / `mage` rời rạc |
| `core/game_world.gd` | `is_ranged()` đọc `DEFS.range`. `is_guard()`, `is_summoner()`. Đánh thường theo `DEFS.basic.kind` (`slash`, `shot`, `fireball`, `spirit`). `_damage_player` nhân `Classes2.taken_mult`, gọi `Classes2.on_player_hit` (phản đòn). `Ally` thêm `ranged`, `splash`, `skill`, `haste`. Linh thú đánh mang `skill_ctx` = kỹ năng gọi |
| `core/classes2.gd` (mới) | Logic 2 lớp mới (D50): `State` ở `w.cl2` (khiên chắn, phản đòn, hào quang, đồ đằng, linh thú thường trực), `cast(w, id, mul)` (gọi từ `Skills2.cast` khi id không phải của 3 lớp cũ), `tick`, `taken_mult`, `on_player_hit`, `basic_hit` (đòn thứ 4 Hiệp Sĩ), `ally_mult`, `on_map_load` (sinh Linh Hồ) |
| `core/items.gd` | Vũ khí sinh ra: Hộ Vệ `mace` (Chùy), Triệu Hồi Sư `orb` (Linh Châu) |
| `core/chapter6.gd` | `MIRROR_OF`: Bản Ngã dùng lại kỹ năng mới theo kiểu gần nhất (cận chiến → `m_spin` / `m_dash`, phép vùng → `m_meteor` / `m_rain`, hỗ trợ → `m_shield`, gọi linh thú → `m_bolt`) |
| `ui/class_select.gd` (UI-22) | Thẻ lớp tự mở khi `Classes.DEFS` có id; `skills` của thẻ = 4 kỹ năng charactors.md (Khiêu Khích, Khiên Thép, Chấn Địa, Thành Bất Diệt · Sói Bóng, Tiểu Quỷ, Liên Kết, Quân Đoàn) |
| `ui/stats_page.gd` | `ROWS` thêm cột mô tả "mỗi điểm" cho 2 lớp (`CLASS_COL`), `PRESETS` 3 mẫu Tự cộng điểm mỗi lớp, câu trích dẫn (`QUOTES`) |
| `view/` | Vẽ linh thú mới (Linh Hồ, Linh Lang, Linh Ưng, Thạch Quỷ, Ấu Long), đồ đằng, khiên chắn, hào quang |
| `tools/art` | `CLASS_LOOK` thêm 2 lớp (hình tạm `hero-ho-ve-*`, `hero-trieu-hoi-su-*` + tóc — khi có bộ `pc-<lớp>` của game-5f thì `SpriteLib.hero_sprite` dùng bộ đó); builder `humanoid` thêm vũ khí `mace` (+ `shield`) và `orb`; 8 sprite linh thú (`linh-ho`, `hoa-ho`, `soi-bong`, `tieu-quy`, `thach-quy`, `linh-ung`, `linh-hon`, `au-long`); `tools/art/classes45_icons.py`: icon cho 18 kỹ năng + 2 đánh thường (`bash`, `spiritorb`); 8 kỹ năng charactors.md dùng icon từ ảnh của chủ dự án (`class_skill_icons.py`, game-5f) |
| Test bot | `_class_points`, `BOT_SKILL_RULES` cho 26 id mới; Hộ Vệ đánh như cận chiến, Triệu Hồi Sư như Pháp Sư (giữ 18–30 m) |

## 5. Cân bằng và kiểm thử

**Nguyên tắc:** mọi test lặp `Classes.ORDER` phải tự áp lên lớp mới mà không nới ngưỡng. Gồm cân bằng boss chương 1–6 (TL-B…), M4.2, Bạch Hổ, C3–C6, SK2-T4, SK3-T4.

- Hộ Vệ: chậm hơn Kiếm Khách tối đa ~10%, chết ít hơn.
- Triệu Hồi Sư: thời gian hạ boss nằm giữa Thợ Săn và Pháp Sư.

| Test | Nội dung |
| --- | --- |
| HV-T1 | Hộ Vệ: chỉ số mặc định tổng 17, VIT cho Tấn công + HP, Khiên −15% sát thương nhận, 13 kỹ năng mở 1/1/4/8/15/22/30/30/45/60 ×4 |
| HV-T2 | 12 kỹ năng gây sát thương của Hộ Vệ trúng quái; Khiêu Khích kéo quái thường, không kéo tinh anh; Khiên Thép +30% Phòng thủ, không phản đòn, hết sau 10 giây; Chấn Địa choáng 2 giây; Thành Bất Diệt nhận ×0,2; Thành Đồng có khiên chắn; Xung Phong choáng |
| HV-T3 | Bị động: Hiệp Sĩ đòn thứ 4 choáng; Thánh Kỵ Sĩ hút máu; Thiết Vệ phản 30% |
| TH-T1 | Triệu Hồi Sư: chỉ số, Linh Hồ thường trực (sinh lại khi đổi map, Linh Sư có 2), giới hạn 8 linh thú gọi |
| TH-T2 | 12 kỹ năng gây sát thương của Triệu Hồi Sư (linh thú gọi ra gây sát thương trong 4 giây); Tiểu Quỷ / Linh Ưng / Ấu Long đánh xa; Liên Kết Linh Hồn: linh thú +40%, mình +20% |
| TH-T3 | Bị động: Ngự Long Sư nổ lan; Đồ Đằng Sư hồi HP/MP gần đồ đằng; sát thương linh thú mang id kỹ năng (cấp kỹ năng tăng sát thương linh thú) |
| LH-T1 | Toàn bộ bộ test cũ chạy qua 5 lớp, không nới ngưỡng |

## 6. Câu hỏi (mặc định đang dùng để code)

| # | Câu hỏi | Mặc định |
| --- | --- | --- |
| Q110 | Chỉ số chính Triệu Hồi Sư? | **INT** — dùng chung đồ Trí tuệ với Pháp Sư |
| Q111 | Tên chuỗi chuyển chức Triệu Hồi Sư? | **Linh Sư → Ngự Long Sư / Đồ Đằng Sư → Vạn Linh Chi Chủ** |
| Q112 | Linh thú có HP, bị quái đánh chết? | ~~Không~~ → **Có** (chủ dự án 27/10/2026, đợt SH — [23 mục 4](23-chuyen-chuc-3-linh-thu-co-mau.md)): quái thường / tinh anh đánh linh thú, boss thì không |
| Q113 | Linh thú thường trực? | **Có** — 1 Linh Hồ từ cấp 1 (Linh Sư: 2), để lớp có bản sắc ngay từ đầu |
| Q114 | Hộ Vệ "hỗ trợ" trong game chơi một mình? | Hỗ trợ **bản thân và đồng minh** (thú cưng, Xương Nô, linh thú): Thánh Vực, Thiên Thần Hộ Mệnh; chế độ nhóm (Beta) sẽ mở rộng hào quang sang đồng đội |
| Q115 | Chuyển chức 3 của 2 lớp mới? | Làm cùng NV-07 cho mọi lớp — ✅ J3 |
| Q116 | Lớp mới có nhiệm vụ / thoại riêng? | **Không** — nhiệm vụ chuyển chức chung; thoại dùng tên chức qua `Classes.title()` |
| Q117 | Thứ tự trên màn tạo nhân vật? | Kiếm Khách · Thợ Săn · Pháp Sư · Hộ Vệ · Triệu Hồi Sư |

## 7. Kết quả (LH1 + LH2, 28/10/2026)

**Cân bằng** — giây trung bình hạ boss vùng, 20 Thiên phú (bot, bộ đồ chuẩn), 0 lần chết ở mọi lớp. Ngưỡng: các lớp chênh ≤ 25%.

| Boss (test) | Kiếm Khách | Thợ Săn | Pháp Sư | **Hộ Vệ** | **Triệu Hồi Sư** | Chênh |
| --- | --- | --- | --- | --- | --- | --- |
| Sói Chúa (TL-B) | 31,6 | 33,0 | 29,5 | 26,7 | 34,1 | 22% |
| Huyền Ảnh (TL-B2) | 43,0 | 48,3 | 45,0 | 39,1 | 47,5 | 19% |
| Sa Hoàng (TL-B3) | 34,7 | 28,8 | 30,8 | 32,2 | 29,8 | 17% |
| Nữ Vương (TL-B4) | 39,2 | 30,5 | 32,0 | 37,6 | 34,0 | 22% |
| Viêm Long (TL-B5) | 43,9 | 39,9 | 35,0 | 44,2 | 42,7 | 21% |
| Bản Ngã (TL-B6) | 30,3 | 27,9 | 29,4 | 30,2 | 31,4 | 11% |
| Thiên Không Cự Thần (TL-B7, chương 7 đang làm) | 25,8 | 21,4 | 20,9 | 26,5 | 24,3 | 21% — sau khi game-39 sửa lỗi giai đoạn chuyển cảnh không đếm lúc boss choáng (Hộ Vệ phá thế nhiều) |

- Bạch Hổ (boss hiếm): Hộ Vệ 67 giây, Triệu Hồi Sư 80–84 giây, 0 lần chết.
- Bộ kỹ năng nhánh chuyển chức 2 vs mặc định (SK3-T4, Viêm Long):
  - Thánh Kỵ Sĩ 37,4 → 34,9 giây.
  - Thiết Vệ 39,5 → 36,6 giây.
  - Ngự Long Sư 37,2 → 30,2 giây.
  - Đồ Đằng Sư 39,9 → 37,3 giây.

**Lỗi tìm thấy khi cân bằng:**

- Bản Ngã giai đoạn gương: cả boss lẫn gương đều "ẩn", nên linh thú không đánh gì và Triệu Hồi Sư chết 4 lần. Sửa: linh thú đánh quái người chơi vừa đánh.
- Lao Khiên / Khiêu Khích đẩy, kéo cả Mộng Châu. Sửa: không áp lên quái của trận boss.

**Kiểm thử:** HV-T1…T3, TH-T1…T3. Test chung áp lên 5 lớp: SK1-T…, SK2-T…, SK3-T… (13 kỹ năng mỗi lớp đều gây sát thương), C1 (hình), UI-22 (5 thẻ chọn được). 155/156 test qua; TL-B7 qua sau bản sửa chương 7 của game-39.

**Chưa làm:**

- ~~Chuyển chức 3 (NV-07)~~ → ✅ J3 ([23](23-chuyen-chuc-3-linh-thu-co-mau.md)).
- ~~Linh thú có HP (Q112)~~ → ✅ SH ([23 mục 4](23-chuyen-chuc-3-linh-thu-co-mau.md)).
- Hình động riêng cho kỹ năng.
- Tuỳ biến ngoại hình dùng hình tạm `hero-ho-ve-*` / `hero-trieu-hoi-su-*`; mặc định dùng bộ `pc-*` của chủ dự án.
