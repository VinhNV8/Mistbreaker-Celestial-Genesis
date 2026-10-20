# Đợt C1 — Hoàn chỉnh Chương 1

| | |
| --- | --- |
| Dự án | Thiên Phú Khai Giới |
| Nguồn | [Kịch bản](kich-ban-game-thien-phu-khai-gioi.md) mục 2, 5, 6, 7, 9 · [Spec_Notes](Spec_Notes.md) (ghi chú của chủ dự án) · tồn đọng chương 1 trong [04](04-ke-hoach-tien-do.md) |
| Mục tiêu | Chương 1 đủ để **mời người chơi thử**: có cốt truyện, hướng dẫn, đủ 3 map con, boss hiếm, âm thanh, file chạy Windows |
| Thứ tự | Làm **trước M4** (đổi lộ trình 20/10/2026). M4 bắt đầu khi C1 xong |
| Quy trình | Spec (file này) → code → test → cập nhật 01/02/03/04 và mục Kết quả cuối file |
| Trạng thái | 🟡 Đang làm |

Ký hiệu: ✅ xong · 🟡 một phần · ⬜ chưa làm. Cột **Nguồn**: `N1…N7` = dòng trong Spec_Notes; mã khác = hạng mục trong 04.

## 1. Đối chiếu Spec_Notes

| # | Ghi chú của chủ dự án | Xử lý | Hạng mục |
| --- | --- | --- | --- |
| N1 | Có inventory chưa? | Đã có từ M1 (phím I, 30 ô) | — |
| N2 | Nhân vật, quái chưa có hình ảnh | Đã làm ở G1 (07); C1 thêm ngoại hình tuỳ chọn, Lão Thụ, âm thanh | C1-02, C1-23, C1-40 |
| N3 | Chưa có plan cụ thể | Plan 04 (toàn dự án), 07 (đồ hoạ), file này (chương 1) | — |
| N4 | Chỗ đặt tên, chọn giới tính, ngoại hình | Màn hình Tạo nhân vật | C1-02 |
| N5 | Quái đứng sau nhân vật thì không chém được, quay lại cũng không chém được | **Lỗi** — sửa và có test | C1-01 |
| N6 | Vàng, gỗ, đuốc là gì; thay bằng icon được không | HUD dùng icon + chú thích; bảng giải thích tài nguyên | C1-03 |
| N7 | Inventory không có thông tin nhân vật | Túi đồ thêm cột nhân vật (chân dung, chỉ số, tài nguyên) | C1-04 |

**Nguyên nhân N5** (đã đọc code): hướng chém lấy theo vị trí chuột. Khi chơi bằng bàn phím, hướng chỉ theo hướng di chuyển **trong lúc đang chạy**; dừng lại thì quay về hướng chuột (đứng yên ở chỗ cũ trên màn hình). Người chơi chạy sang trái để quay mặt về quái phía sau, dừng lại bấm J → nhân vật quay ngược về phía chuột và chém vào khoảng không. Ngoài ra cung chém chỉ 120° nên quái áp sát sau lưng cũng không trúng.

## 2. Hạng mục

### Phần A — Ghi chú của chủ dự án (ưu tiên cao nhất)

| Mã | Yêu cầu | Tiêu chí nghiệm thu | Nguồn |
| --- | --- | --- | --- |
| C1-01 | **Sửa hướng đánh.** (a) Chơi bàn phím: giữ hướng di chuyển cuối cùng cả khi đã dừng; chỉ đổi sang hướng chuột khi chuột vừa di chuyển. (b) **Tự xoay mặt**: đòn đánh thường không có quái trong cung chém nhưng có quái trong tầm thì quay về quái gần nhất rồi chém. Thợ Săn: không có quái trong nón 30° theo hướng ngắm thì ngắm quái gần nhất trong tầm bắn | Test C1-T1: quái sau lưng (cả khi đứng yên) bị chém trúng; Thợ Săn bắn trúng quái phía sau | N5 |
| C1-02 | **Tạo nhân vật**: tên (2–16 ký tự, có dấu tiếng Việt), giới tính Nam/Nữ, màu da (3), kiểu tóc (4: Ngắn, Dài, Búi, Đuôi ngựa), màu tóc (6), lớp (Kiếm Khách/Thợ Săn) — **1 màn hình**, xem trước nhân vật động. Tên hiện trên đầu nhân vật và HUD. Thứ tự theo kịch bản mục 9: Mở đầu → Tạo nhân vật → Lễ Thức Tỉnh | Smoke `02-create`; save v5 giữ tên, ngoại hình (C1-T2) | N4, TN-02 |
| C1-03 | **Tài nguyên dạng icon**: HUD góc phải hiện icon + số (Vàng, Gỗ, Đuốc, Đá Cường Hoá, Tinh Hoa); rê chuột hiện chú thích 1 dòng. Bảng **Tài nguyên** giải thích 8 loại: là gì, kiếm ở đâu, dùng làm gì | Smoke `03-combat`, `05b-inventory` | N6 |
| C1-04 | **Túi đồ có thông tin nhân vật**: cột trái = chân dung lớn, tên, lớp, cấp, Thiên phú, Lực chiến, HP/MP/Tấn công/Phòng thủ/Chí mạng/Né; 8 ô trang bị xếp quanh; tab Tài nguyên (C1-03) | Smoke `05b-inventory` | N7 |

### Phần B — Cốt truyện và hướng dẫn

| Mã | Yêu cầu | Tiêu chí | Nguồn |
| --- | --- | --- | --- |
| C1-10 | **Cảnh mở đầu**: 5 trang (Huyền Thổ → Thiên Liệt → sương Hư Vô → Khai Giới Giả → làng Thanh Thạch), chữ hiện dần, hình vẽ bằng code, Space/chuột để sang trang, nút Bỏ qua. Chỉ chiếu khi bắt đầu hành trình mới | Smoke `01b-intro` | TN-01, CT-01 |
| C1-11 | **Hộp thoại**: tên + chân dung + lời; Space/chuột để tiếp; game tạm dừng khi có thoại. Thoại chương 1 (Trưởng làng Thạch Lão, nhân vật chính, Người sống sót, Sói Chúa) ở các mốc: vào làng, quái tấn công, cấp 5, ô đầu tiên, mở hang, boss xuất hiện, boss giai đoạn 2, hạ boss, vào Lõi Sương | Test C1-T3 (thoại kích hoạt đúng mốc, không lặp lại) | CT-02, CT-09 |
| C1-12 | **Chuỗi nhiệm vụ chương 1 = hướng dẫn** (bảng 3.1): 11 bước, mỗi bước có hướng dẫn phím, thưởng EXP/vàng/đồ; bước 1 "Quái Sương tấn công làng" sinh 3 Sói Sương cấp 1 ở cổng làng. Bước 4 Trưởng làng tặng vũ khí Xanh lá theo lớp (phát hiện F8). Bảng nhiệm vụ thay 3 mục tiêu cũ trên HUD | Test C1-T4 (bot đi hết 11 bước) | TN-04, NV-22 |
| C1-13 | **Kết chương**: bản đồ lục địa 9 vùng (vẽ bằng code), vùng 1 sáng, vùng 2 nhấp nháy "Đồng Bằng Gió Hú — Chương 2", lời kể gợi "mảnh Thiên phú thứ hai" | Smoke `07-victory` | TN-09, CT-03 |
| C1-14 | Bảng Thiên phú hiện **cây tiến hoá** (2 bậc, tên, hạng, điều kiện) theo tài liệu 05 | Smoke `05d-talent` | TP-43 |
| C1-15 | Lễ Thức Tỉnh: Bia Đá **toả sáng theo màu hạng** vừa quay (hạng S trở lên có tia sáng) | Smoke `02-awakening` | TP-04 |

### Phần C — Vùng 1 đầy đủ

| Mã | Yêu cầu | Tiêu chí | Nguồn |
| --- | --- | --- | --- |
| C1-20 | **3 map con trong 1 bản đồ liền** (thế giới 3.600 × 1.600): Bìa Rừng Sương (cấp 1–4), Rừng Sương Sâu (cấp 4–7, có hang Sói Chúa), **Lõi Sương** (cấp 7–10, sau tường sương thứ 2, mở khi hạ Sói Chúa). Tên vùng hiện khi bước vào | Test C1-T5 | BD-01, BD-06 |
| C1-21 | **Lưới khai phá 40 ô** (10 + 15 + 15), 3 màu theo map con; ô Lõi Sương bị khoá tới khi hạ Sói Chúa. Sự kiện theo tỉ lệ kịch bản (bảng 3.2), có **Thương nhân lữ hành**. Khứu Giác Kho Báu: Di tích 20%. Điều kiện vào hang giữ nguyên: cấp 5 + 6 ô. Save cũ (10 ô) được thêm 30 ô | Test C1-T6 | KP-01, KP-11, TP-26, KP-09 |
| C1-22 | **Lõi Sương**: quái cấp 7–10 (Tinh Linh Sương, Mộc Tinh, Nấm Độc, tinh anh); sương dày: quái cách xa hơn 20 m bị mờ, Tinh Linh Sương ở xa thì tàng hình | Test C1-T5 | 06 vùng 1 |
| C1-23 | **Boss hiếm Lão Thụ Sương Mù** (cấp 9, chỉ số theo công thức 06): Rễ Trói, Lá Độc, dưới 40% HP Rừng Thức Tỉnh (gọi 2 Mộc Tinh + 3 Gốc Rễ, hồi 1% HP/giây tới khi phá hết rễ). Xuất hiện ở Lõi Sương; lần đầu khi người chơi vào Lõi Sương, sau đó **2 lần mỗi ngày** (mỗi 12 giờ thực). Rơi **Vỏ Lão Thụ** (bùa Cam: đứng yên 1 giây hồi 2% HP/giây), 1 **Tinh Hoa Tiến Hoá**, 5 Thiên Phú Tinh Hoa. Sprite 48 px | Test C1-T7 | CB-15, TB-09 |
| C1-24 | Cơ chế quái còn thiếu (06): Nấm Độc chết để lại **vũng độc** 3 m (2% HP/giây, 3 giây); Tinh Linh Sương **Lao sương** (lao 15 m) | Test C1-T8 | 06 vùng 1 |

### Phần D — Lãnh địa và tiện ích

| Mã | Yêu cầu | Tiêu chí | Nguồn |
| --- | --- | --- | --- |
| C1-30 | **Xưởng Rèn** (công trình 150 vàng, 80 gỗ, 120 giây): chế 1 món cho ô chọn, cấp = cấp nhân vật, tốn 60 + 15 × cấp vàng và 3 Đá; phẩm chất Xanh lá 60% / Xanh dương 35% / Tím 5% | Test C1-T9 | KP-15 |
| C1-31 | **Vườn Thảo Dược** (60 vàng, 60 gỗ, 90 giây): 1 thảo dược mỗi 3 phút, chạy cả khi offline (trần như thu hoạch offline) | Test C1-T9 | KP-16 |
| C1-32 | **Cửa hàng**: Thương nhân ở làng (phím E khi đứng trong làng) bán bình máu 30 vàng, Đá Cường Hoá 25 vàng; **bán đồ** lấy vàng (giá = 5 × cấp × hệ số phẩm chất 1/2/4/8/20). Thương nhân lữ hành (ô sự kiện) bán thêm 3 món Xanh dương/Tím, tồn tại 1 giờ thực | Test C1-T10 | TB-12, KP-09 |
| C1-33 | **Tự đánh** (phím Z): tự tới quái gần nhất trong 40 m, đánh thường, dùng kỹ năng khi đủ MP; người chơi bấm di chuyển thì tạm nhường; **tắt khi vào hang boss hoặc boss hiếm xuất hiện** | Test C1-T11 | CB-02 |
| C1-34 | **Tự cộng điểm**: nút trong bảng Chỉ số, cộng theo lớp (Kiếm Khách 3 STR : 2 VIT; Thợ Săn 3 AGI : 1 VIT : 1 LUK) | Test C1-T11 | NV-26 |

### Phần E — Âm thanh và cài đặt

| Mã | Yêu cầu | Tiêu chí | Nguồn |
| --- | --- | --- | --- |
| C1-40 | **Hiệu ứng âm thanh sinh bằng code** (`tools/audio/`, như cách sinh hình): chém, bắn, trúng đòn, chí mạng, quái chết, người chơi trúng đòn, né, Hoàn hảo, nhặt vàng, nhặt đồ, lên cấp, kỹ năng, nút giao diện, boss gầm | Test C1-T12 (mọi id âm thanh có file) | DH-12 |
| C1-41 | **Nhạc nền** vòng lặp sinh bằng code: Làng, Rừng Sương, Lõi Sương, Boss; đổi bản nhạc theo vị trí | Smoke (không lỗi) | DH-13 |
| C1-42 | **Menu tạm dừng** (Esc khi không mở bảng nào): Tiếp tục · Cài đặt · Về màn hình chính. **Cài đặt**: âm lượng tổng/nhạc/hiệu ứng, toàn màn hình; lưu `user://settings.cfg` | Smoke `08-settings` | KT-07 |

### Phần F — Phát hành thử

| Mã | Yêu cầu | Tiêu chí | Nguồn |
| --- | --- | --- | --- |
| C1-50 | **File chạy Windows**: export preset, hướng dẫn build trong 02; build được `build/ThienPhuKhaiGioi.exe` nếu máy có export templates 4.7.2 | File .exe chạy được | KT-06 |
| C1-51 | Cân bằng lại nhịp 1 → 10 với chuỗi nhiệm vụ và Lõi Sương; bot đo thời gian | Ghi số đo vào mục 5 | NV-20 |

### Để lại sau C1

Giải đố Di tích (KP-04), Cổng dungeon (BD-11, Alpha), khung giao diện có art (DH-11), Đuốc hồi 20 phút như kịch bản (KP-02 — quyết định sau playtest).

## 3. Chi tiết

### 3.1. Chuỗi nhiệm vụ chương 1

| # | Nhiệm vụ | Hướng dẫn hiện trên HUD | Hoàn thành khi | Thưởng |
| --- | --- | --- | --- | --- |
| 1 | Quái Sương tấn công làng! | Chuột trái / J để đánh | Hạ 3 Sói Sương ở cổng làng | 60 EXP, 20 vàng |
| 2 | Học kỹ năng | Phím 1–4 dùng kỹ năng (tốn MP) | Dùng kỹ năng 2 lần | 40 EXP |
| 3 | Học né | Space né lăn; né đúng lúc = Hoàn hảo | Né 1 lần | 40 EXP |
| 4 | Món quà của Trưởng làng | I mở túi đồ, mặc vũ khí | Mặc 1 vũ khí | Vũ khí Xanh lá theo lớp (tặng khi nhận nhiệm vụ) |
| 5 | Vào Rừng Sương | Đánh quái lên cấp | Đạt cấp 3 | 100 vàng |
| 6 | Cộng điểm tiềm năng | C mở Chỉ số (hoặc nút Tự cộng điểm) | Cộng hết điểm | 2 bình máu |
| 7 | Dọn sương | M mở Bản đồ, dùng Đuốc | Dọn 3 ô | 1 Đuốc, 80 EXP |
| 8 | Xây công trình đầu tiên | Chiếm Rừng gỗ, xây Xưởng Gỗ | Xây xong 1 công trình | 150 vàng |
| 9 | Chuẩn bị đánh boss | Cấp 5 và chiếm 6 ô | Mở được hang | 3 Đá Cường Hoá |
| 10 | Sói Chúa Hư Vô | Phá thanh Phá Thế để làm boss choáng | Hạ Sói Chúa | (thưởng boss) |
| 11 | Lõi Sương | Đi qua tường sương phía đông | Vào Lõi Sương | 200 EXP — mở bản đồ lục địa |

EXP nhiệm vụ cộng lại khoảng 25% EXP tới cấp 6, khớp tỉ lệ "nhiệm vụ cốt truyện 25%" (kịch bản mục 4).

### 3.2. Lưới khai phá 40 ô

| Map con | Số ô | Tài nguyên | Ổ quái | Di tích | Người sống sót | Thương nhân | Kỳ quan |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1-1 Bìa Rừng (vòng 1 + 4 ô vòng 2) | 10 | 4 | 2 | 2 | 1 | 0 | 1 |
| 1-2 Rừng Sâu (8 ô vòng 2 + 7 ô vòng 3) | 15 | 6 | 4 | 2 | 2 | 1 | 0 |
| 1-3 Lõi Sương (11 ô vòng 3 + 4 ô vòng 4) | 15 | 6 | 5 | 1 | 1 | 2 | 0 |
| **Tổng** | **40** | **16 (40%)** | **11 (28%)** | **5 (12%)** | **4 (10%)** | **3 (8%)** | **1 (2%)** |

Kịch bản: 35 / 25 / 12 / 10 / 8 / 7 (Cổng dungeon — Alpha, dồn sang Tài nguyên và Ổ quái) / 3%. Khứu Giác Kho Báu: 3 ô Tài nguyên ở map 1-2, 1-3 đổi thành Di tích (8/40 = 20%).

### 3.3. Thay đổi save (version 4 → 5)

| Trường | Kiểu | Mặc định khi chuyển từ v4 |
| --- | --- | --- |
| `name` | Tên nhân vật | `"Khai Giới Giả"` |
| `look` | `{gender, skin, hair_style, hair_color}` | Nam, da 1, tóc Ngắn, màu 0 |
| `quest_step`, `quest_progress` | Bước nhiệm vụ chương 1, tiến độ | Save đã hạ boss: bước 11; còn lại: bước 5 |
| `seen_dialogs` | Mốc thoại đã xem | `[]` |
| `tiles` | Thêm trường `zone` (1–3); 30 ô mới | Ô cũ = zone 1 |
| `rare_boss_at` | Giờ Unix boss hiếm xuất hiện lần tới (0 = khi vào Lõi Sương) | `0` |
| `evo_essence` | Tinh Hoa Tiến Hoá | `0` |
| `herb_timer`, `merchant` | Vườn Thảo Dược; hàng của Thương nhân lữ hành `{until, items}` | `0`, `{}` |

### 3.4. Kiểm thử cần có

| # | Nội dung |
| --- | --- |
| C1-T1 | Hướng đánh: quái sau lưng bị chém khi đứng yên chơi bàn phím; tự xoay khi cung chém trống; Thợ Săn tự ngắm |
| C1-T2 | Save v4 → v5; lưu/nạp tên, ngoại hình, nhiệm vụ, ô zone |
| C1-T3 | Thoại kích hoạt đúng mốc, không lặp |
| C1-T4 | Chuỗi nhiệm vụ: đi hết 11 bước, thưởng đúng, quà vũ khí theo lớp |
| C1-T5 | 3 map con: cấp quái theo vùng; tường Lõi Sương chặn tới khi hạ boss; Tinh Linh ở Lõi Sương tàng hình khi xa |
| C1-T6 | Lưới 40 ô đúng cơ cấu bảng 3.2; ô Lõi Sương khoá; Khứu Giác Di tích 20%; save 10 ô được bù 30 ô |
| C1-T7 | Lão Thụ: chỉ số theo công thức; Rễ Trói trói người chơi; Rừng Thức Tỉnh hồi máu tới khi phá rễ; rơi đúng đồ; lịch 12 giờ |
| C1-T8 | Vũng độc Nấm Độc; Lao sương |
| C1-T9 | Xưởng Rèn chế đồ (tỉ lệ phẩm chất, giá); Vườn Thảo Dược sinh thảo dược cả offline |
| C1-T10 | Cửa hàng mua/bán; Thương nhân lữ hành hết hạn sau 1 giờ |
| C1-T11 | Tự đánh tự tắt ở hang boss; tự cộng điểm đúng tỉ lệ theo lớp |
| C1-T12 | Mọi hình (ngoại hình, Lão Thụ) và âm thanh có file |

## 4. Tiến độ

| Phần | Hạng mục | Trạng thái |
| --- | --- | --- |
| A | C1-01 … C1-04 | ⬜ |
| B | C1-10 … C1-15 | ⬜ |
| C | C1-20 … C1-24 | ⬜ |
| D | C1-30 … C1-34 | ⬜ |
| E | C1-40 … C1-42 | ⬜ |
| F | C1-50, C1-51 | ⬜ |

## 5. Kết quả

(Cập nhật khi xong từng phần.)
