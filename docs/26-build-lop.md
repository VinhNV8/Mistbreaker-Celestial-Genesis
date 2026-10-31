# Đề xuất chỉ số lớp và build từng lớp (gộp docs/24 + CR-001)

| | |
| --- | --- |
| Dự án | Thiên Phú Khai Giới |
| Nguồn | [CR-001](CR-001-He-so-thuoc-tinh-co-ban.md) (hệ 7 thuộc tính, chỉ số khởi tạo, tăng trưởng, đặc tính lớp) · [24](24-de-xuat-chi-so-lop.md) (phân tích vấn đề, Thiên tính lớp, Q147–Q152) · `core/stats.gd`, `core/formulas.gd`, `data/classes.gd` |
| Loại tài liệu | Đặc tả + kết quả. **Đã code (CS, 28/10)** — xem mục 9 |
| Thay thế | docs/24 mục 3–4 (bảng chỉ số và hệ số thuộc tính). Mục 1 (vấn đề P1–P5) và mục 5 (giao diện) của docs/24 vẫn dùng |
| Trạng thái | ✅ Chủ dự án duyệt theo đề xuất (28/10: "triển khai theo đề xuất mới") — Q147–Q152, Q161–Q168 theo cột Đề xuất |

## 1. Tóm tắt

- **Lấy nguyên số của CR-001** cho phần người chơi nhìn thấy: 7 thuộc tính, chỉ số khởi tạo từng lớp, thuộc tính tự tăng mỗi cấp, đặc tính lớp.
- **Đổi hệ số quy đổi** (1 điểm thuộc tính ra bao nhiêu Tấn công, HP…) để số cuối cùng vẫn nằm trong thang của game hiện tại. Lý do: thuộc tính trong CR-001 lớn gấp khoảng 5 lần bây giờ (tổng 70–85 điểm ở cấp 1, hiện là 17). Nếu giữ hệ số cũ, Kiếm Khách cấp 1 sẽ có 36 Tấn công thay vì 10, và phải cân lại toàn bộ quái.
- **Mỗi lớp có 3 build**, mỗi build gắn với một nhánh chuyển chức 2. Các build chênh nhau trong khoảng ±15% về sát thương và trụ, không có build nào thắng mọi mặt.
- Có 3 chỗ trong CR-001 không áp được nguyên văn vào game một người chơi, nên tôi đề xuất cách đổi (mục 3.3): **thù hận**, **độ chính xác**, **tối đa 3 thú**.

## 2. Hệ 7 thuộc tính

### 2.1. Tác dụng mỗi điểm

Thêm **WIS** và **DEX** vào 5 thuộc tính đang có. Mỗi thuộc tính có một tác dụng chung cho mọi lớp. Riêng phần **Tấn công** chỉ lấy từ thuộc tính chính của lớp, để STR không vô dụng với Kiếm Khách và INT không vô dụng với Pháp Sư.

| 1 điểm | Mọi lớp | Riêng lớp |
| --- | --- | --- |
| **STR** | — | Tấn công: Kiếm Khách **+0,6** · Hộ Vệ **+0,4** · Thợ Săn +0,1 |
| **AGI** | +0,15% tốc đánh · +0,05% chí mạng · +0,08% né | Thợ Săn: **+0,2 Tấn công** |
| **VIT** | +5 HP · +0,25 Phòng thủ | Hộ Vệ: +6 HP (thay +5) · **+0,12 Tấn công** |
| **INT** | +3 MP · +0,3% sát thương kỹ năng | Tấn công: Pháp Sư **+0,45** · Triệu Hồi Sư **+0,4** |
| **WIS** *(mới)* | +0,02 MP/giây · +0,1% kháng 5 hệ (trần chung 50% gồm cả trang bị) | Triệu Hồi Sư: +0,3% HP linh thú · Hộ Vệ: +0,1% kháng hiệu ứng |
| **DEX** *(mới)* | +0,1% xuyên giáp (trần 40%) · +0,2% sát thương vào thanh Phá Thế | Thợ Săn: **+0,25 Tấn công** |
| **LUK** | +0,15% chí mạng · +0,1% rơi đồ (trần +10%) | — |

Trần chung: tốc đánh ×2,0 · chí mạng 60% · né 30% (Thợ Săn 40%) · xuyên giáp 40%. Bỏ trần riêng "+20% tốc đánh từ AGI" của Thợ Săn (sửa vấn đề P4 của docs/24).

### 2.2. Phần gốc theo cấp

Ngoài thuộc tính, mỗi cấp nhân vật nhận một phần "gốc". Phần gốc **hiện trên trang Chỉ số** (dòng "Gốc theo cấp"), không còn ẩn như bây giờ (vấn đề P2).

- HP: lấy tỉ lệ từ CR-001 (+45 / +35 / +70 / +25 / +35 HP mỗi cấp), chia nhỏ cho hợp thang game.
- Tấn công: tính ngược để tổng ở cấp 30 và 60 khớp mục tiêu mục 4.

| Lớp | HP | Tấn công | Phòng thủ | MP | Tốc đánh gốc | Tốc chạy |
| --- | --- | --- | --- | --- | --- | --- |
| Kiếm Khách | 25 + **20**/cấp | 3,3/cấp | 2 + 1,2/cấp | 25 + 2/cấp | 1,00 | **265** (+15%, CR-001) |
| Thợ Săn | 30 + **22**/cấp | 5,0/cấp | 2 + 1,0/cấp | 25 + 3/cấp | 1,00 | **250** |
| Pháp Sư | 35 + **24**/cấp | 4,4/cấp | 2 + 0,85/cấp | **50** + 12/cấp | 0,95 | 220 |
| Hộ Vệ | 0 + **12**/cấp | 6,3/cấp | (2 + 1,6/cấp) **×1,3** | 25 + 2,4/cấp | 0,90 | 210 |
| Triệu Hồi Sư | 25 + **25**/cấp | 4,4/cấp | 2 + 1,3/cấp | 30 + 10/cấp | 1,00 | 220 |

Hộ Vệ có HP gốc theo cấp thấp nhất nhưng lại dày nhất. Lý do: lớp này tự tăng 3 VIT mỗi cấp, mỗi VIT cho 6 HP. Kiếm Khách được ghi "máu thấp" trong CR-001 nhưng vẫn trụ tốt nhờ né 10% của lớp.

### 2.3. Chỉ số cấp 1

Thuộc tính lấy nguyên CR-001; các chỉ số còn lại tính theo mục 2.1 và 2.2.

| | Kiếm Khách | Thợ Săn | Pháp Sư | Hộ Vệ | Triệu Hồi Sư |
| --- | --- | --- | --- | --- | --- |
| STR · AGI · VIT | **18** · 15 · 12 | 8 · **20** · 10 | 4 · 8 · 8 | 14 · 6 · **22** | 3 · 10 · 12 |
| INT · WIS · DEX · LUK | 5 · 6 · 14 · 10 | 6 · 8 · **19** · 14 | **24** · **18** · 10 · 8 | 5 · 10 · 8 · 5 | **20** · **20** · 10 · 10 |
| Tự tăng mỗi cấp | STR 2,5 · AGI 2 · DEX 1,5 · VIT 1 | AGI 2,5 · DEX 2,5 · LUK 1,5 | INT 3 · WIS 2 · DEX 1 | VIT 3 · STR 1,5 · WIS 1 | INT 2,5 · WIS 2,5 · VIT 1 |
| HP | 85 | 80 | 75 | **132** | 85 |
| Tấn công | **11** | 10 | **11** | 8 | 8 (+ linh thú) |
| Phòng thủ | 5 | 4,5 | 4 | **9,8** | 5 |
| MP | 40 | 43 | **122** | 40 | 90 |
| Tốc đánh | 1,02 | 1,03 | 0,96 | 0,91 | 1,01 |
| Chí mạng · ST chí mạng | 10% · **×1,7** | **21%** · ×1,5 | 5% · ×1,5 | 4% · ×1,5 | 5% · ×1,5 |
| Né · xuyên giáp | **11%** · 1% | 2% · **12%** | 1% · **16%** (phép) | 0% · 1% | 1% · 1% |

So với bây giờ: 7/10 chỉ số khác nhau rõ giữa các lớp, thay vì 7/10 trùng nhau (vấn đề P1).

## 3. Đặc tính lớp

### 3.1. Bảng gộp

Lấy đặc tính của CR-001 làm chính. Từ docs/24 mục 3.2 chỉ giữ cơ chế nào CR-001 chưa có.

| Lớp | Từ CR-001 | Giữ từ docs/24 | Bỏ (lý do) |
| --- | --- | --- | --- |
| Kiếm Khách | +15% tốc chạy · +10% né · +20% ST chí mạng · không chặn đòn | **Kiếm thế**: mỗi đòn trúng liên tiếp trong 2 giây +2% tốc đánh (tối đa +20%), mất khi bị trúng đòn | Xuyên giáp 10% (DEX đã cho) |
| Thợ Săn | +25% tầm đánh · +15% chí mạng · +10% xuyên giáp | **Thân pháp**: né thành công giảm 20% hồi chiêu né lăn | — |
| Hộ Vệ | **+30% Phòng thủ** · **+25% kháng hiệu ứng** (choáng, trói, chậm ngắn đi 25%) · +20% thù hận *(đổi, mục 3.3)* | Khiên: nhận ít hơn 15% sát thương (đã có trong game) | Chặn đòn 12% (đã đủ dày, xem Q164) |
| Pháp Sư | **+20% sát thương kỹ năng** · **+15% xuyên kháng phép** · +100 MP khởi đầu *(đổi thành +50, theo thang MP của game)* | — (Thấu phép trùng với xuyên kháng phép) | — |
| Triệu Hồi Sư | Tối đa 3 thú *(đổi, mục 3.3)* · **40% chỉ số chủ truyền cho thú** · thú +20% HP | **Gắn kết**: mỗi linh thú đang sống +4% hồi MP cho chủ (tối đa 3) | Linh lực +1% mỗi INT (trùng với 40% truyền chỉ số) |

### 3.2. Xuyên giáp và xuyên phép thực sự có tác dụng bao nhiêu

Sát thương trong game = Tấn công × hệ số × Tấn công / (Tấn công + Phòng thủ quái). Phòng thủ quái tăng chậm (3 + 1,5 × cấp), trong khi Tấn công người chơi tăng khoảng 8 mỗi cấp. Vì vậy Phòng thủ quái chỉ cắt khoảng **10%** sát thương, và xuyên giáp tối đa 40% chỉ thêm khoảng **+4%**.

Vì lý do đó, DEX có thêm tác dụng "+0,2% sát thương vào thanh Phá Thế". Khi phá thanh này, boss bị choáng và nhận thêm 50% sát thương, nên tác dụng thấy rõ hơn. Đây là cách hiểu "chính xác" của CR-001: đánh đúng điểm yếu.

### 3.3. Ba chỗ CR-001 phải đổi khi áp vào game

| CR-001 | Vấn đề trong game | Đề xuất |
| --- | --- | --- |
| Hộ Vệ **+20% tạo thù hận** | Game một người chơi: quái nào cũng đánh người chơi, thù hận không có tác dụng | Đổi thành: Khiêu Khích giữ quái lâu hơn 20%; quái trong 12 m ưu tiên đánh Hộ Vệ thay vì linh thú hoặc đồng minh (hữu ích với Thuần Thú Sư, Bầy Đàn Bóng Tối) |
| DEX **tăng độ chính xác** | Đòn của người chơi chưa bao giờ trượt, quái không có né | Đổi thành sát thương vào thanh Phá Thế (mục 3.2). Không thêm cơ chế đánh trượt |
| Triệu Hồi Sư **tối đa 3 thú** | Game đang cho tối đa 8 linh thú, tối thượng Quân Đoàn gọi 10, chuyển chức 3 thêm 2 | Đổi thành: tối đa **3 linh thú chủ lực** cùng lúc (Sói Bóng, Thạch Quỷ, Linh Hồ, Ấu Long). Thú tạm thời (Tiểu Quỷ, Linh Ưng, Quân Đoàn, Xương Nô) không tính |
| Pháp Sư **+100 Mana khởi đầu** | MP của mọi lớp đang là 50 | +50 (Pháp Sư 122 MP ở cấp 1, gấp 3 lớp cận chiến) |

## 4. Cân bằng: mô hình nhanh

### 4.1. Cách đo

Mô hình chạy bằng script Python với công thức `Stats.derive` và `Formulas.mob_stats` hiện tại. Không tính trang bị, kỹ năng, hay bị động chuyển chức.

- **Sát thương** = Tấn công × Tấn công / (Tấn công + Phòng thủ quái × (1 − xuyên)) × tốc đánh × (1 + chí mạng × (ST chí mạng − 1)), một nửa sát thương nhân thêm hệ số kỹ năng.
  - Cột **sát thương** so với **chính lớp đó ở bản hiện tại**. Lý do: bộ kỹ năng mỗi lớp đã được cân với chỉ số hiện tại.
- **Trụ** = HP × (1 + Phòng thủ / Tấn công quái × 0,5) / (1 − né) / (1 − giảm sát thương).
  - Cột **trụ** so với **Kiếm Khách hiện tại**.

Mục tiêu đặt ra (theo docs/24 mục 3.3):

| | Kiếm Khách | Thợ Săn | Pháp Sư | Hộ Vệ | Triệu Hồi Sư |
| --- | --- | --- | --- | --- | --- |
| Sát thương so với chính lớp đó bây giờ | 1,15 | 1,05 | 1,00 + 20% kỹ năng | 0,80 | 0,85 + linh thú |
| Trụ so với Kiếm Khách bây giờ | 0,95 | 0,80 | 0,65 | 1,65 | 0,85 |

### 4.2. Kết quả, build mặc định

Ô ghi "sát thương / trụ".

| Cấp | Kiếm Khách | Thợ Săn | Pháp Sư | Hộ Vệ | Triệu Hồi Sư |
| --- | --- | --- | --- | --- | --- |
| 1 | 1,18 / 0,96 | 1,10 / 0,79 | 1,27 / 0,70 | 0,71 / 2,05 | 0,78 / 0,86 |
| 10 | 0,93 / 0,84 | 0,85 / 0,66 | 1,01 / 0,65 | 0,79 / 1,75 | 0,83 / 0,84 |
| 30 | 1,01 / 0,87 | 0,93 / 0,70 | 1,00 / 0,64 | 0,79 / 1,71 | 0,84 / 0,84 |
| 60 | 1,16 / 0,95 | 1,06 / 0,79 | 1,01 / 0,64 | 0,79 / 1,70 | 0,85 / 0,84 |
| 100 | 1,38 / 1,01 | 1,26 / 0,96 | 1,02 / 0,64 | 0,79 / 1,70 | 0,86 / 0,84 |

Rủi ro thấy được:

- **Cấp 1–10 dao động.** Kiếm Khách và Thợ Săn hụt khoảng 10% ở cấp 10, vì thuộc tính tự tăng chưa kịp bù. Cần chỉnh bằng test TL-B (Huyền Ảnh, cấp 17) và M1-12 (Sói Chúa).
- **Kiếm Khách, Thợ Săn mạnh dần về cuối** (×1,26–1,38 ở cấp 100). Nguyên nhân: AGI tự tăng 2–2,5 mỗi cấp, nên tốc đánh và chí mạng tăng mãi. Cách sửa nếu test SK3-T4 / TL-J3 vượt 25%: hạ AGI xuống +0,12% tốc đánh, hoặc giảm dần phần gốc theo cấp sau cấp 60.
- **Pháp Sư trụ 0,64.** Đúng "máu rất thấp" của CR-001, nhưng thấp hơn bây giờ (0,89). Pháp Sư sống nhờ đánh xa, Băng Lao làm chậm và Pháp Thuẫn. Phải chạy lại test "0 lần chết".

Số trong bảng là **điểm xuất phát**. Số cuối cùng chốt bằng các test cân bằng có sẵn, luật giữ nguyên: các lớp hạ cùng boss chênh nhau ≤ 25% và 0 lần chết.

## 5. Build từng lớp

Mỗi lớp có 3 build:

- **Mặc định**: nút "Tự cộng điểm" và bot test dùng build này. Thay cho mảng `auto` trong `classes.gd`.
- **2 build chuyên**: mỗi build gắn với một nhánh chuyển chức 2.

Tỉ lệ ghi theo 5 điểm tự do mỗi cấp. Chỉ số trong bảng là ở **cấp 60, chưa mặc đồ**, sát thương / trụ đo như mục 4.

### 5.1. Kiếm Khách — Cận chiến · Chí mạng

| Build | 5 điểm / cấp | Nhánh chức 2 | ATK · HP · DEF | Tốc đánh · chí mạng · né | Sát thương / trụ |
| --- | --- | --- | --- | --- | --- |
| **Mặc định** | STR 3 · VIT 1 · AGI 1 | — | 400 · 1.855 · 105 | 1,29 · 19% · 25% | 1,16 / 0,95 |
| **Bạo Kích** | STR 3 · AGI 1 · LUK 1 | **Kiếm Thánh** | 400 · 1.560 · 91 | 1,29 · 28% · 25% | 1,22 / 0,78 |
| **Huyết Chiến** | STR 3 · VIT 2 | **Huyết Kiếm** | 400 · 2.150 · 120 | 1,20 · 16% · 21% | 1,06 / 1,06 |

- **Bạo Kích**: đánh boss.
  - Chuỗi kỹ năng: Kiếm Ý (+20% chí mạng) → Nguyệt Ảnh Liên Trảm → Trảm Phong.
  - Kiếm Thánh cộng 40% sát thương vào thanh Phá Thế. Cộng với DEX tự tăng, build này phá thế boss nhanh nhất game.
  - Thiên phú hợp: Kiếm Tâm, Mắt Ưng. Dòng phụ nên tìm: Chí mạng, ST chí mạng.
  - Điểm yếu: mỏng nhất trong 3 build; bị trúng đòn thì mất Kiếm thế.
- **Huyết Chiến**: dọn bầy quái.
  - Huyết Kiếm hút 6% máu; dưới 50% HP được +20% sát thương. Nhiều VIT thì có nhiều HP để "đứng dưới 50%" mà không chết.
  - Thiên phú hợp: Hấp Huyết, Huyết Chiến, Thân Thể Cường Tráng. Dòng phụ: HP, Tốc đánh.
- **Không nên** dồn INT hay WIS: Kiếm Khách hầu như không tốn MP (158 MP ở cấp 60 là đủ).

### 5.2. Thợ Săn — Đánh xa · Chí mạng · Cơ động

| Build | 5 điểm / cấp | Nhánh chức 2 | ATK · HP · DEF | Tốc đánh · chí mạng · né | Sát thương / trụ |
| --- | --- | --- | --- | --- | --- |
| **Mặc định** | DEX 2 · AGI 2 · VIT 1 | — | 424 · 1.673 · 78 | 1,43 · 48% · 23% | 1,06 / 0,79 |
| **Bách Phát** | DEX 3 · AGI 2 | **Thần Tiễn** | 439 · 1.378 · 64 | 1,43 · 48% · 23% | 1,10 / 0,63 |
| **Bẫy Thủ** | DEX 3 · VIT 1 · WIS 1 | **Thợ Bẫy** | 415 · 1.673 · 78 | 1,25 · 42% · 13% | 0,89 / 0,70 |

- **Không cộng LUK sau cấp 40.** Chí mạng gốc 20% (của lớp) cộng với LUK tự tăng 1,5 mỗi cấp sẽ chạm trần 60% quanh cấp 60. Thử build DEX 2 · AGI 1 · LUK 2: ở cấp 60 thấp hơn Bách Phát 9% sát thương.
- **Bách Phát**: đứng xa và thả diều.
  - Thần Tiễn tăng sát thương chí mạng ×1,2 nên rất hợp với chí mạng sẵn cao. Tầm đánh +25% giúp đứng ngoài tầm quái cận chiến.
  - Thiên phú hợp: Tay Nhanh, Kiếm Tâm. Dòng phụ: ST chí mạng, Tốc đánh.
  - Điểm yếu: mỏng nhất game sau Pháp Sư; quái lao tới là nguy hiểm.
- **Bẫy Thủ**: đánh có chuẩn bị.
  - Đặt 4 bẫy rồi kéo quái qua. WIS giúp hồi MP để đặt bẫy liên tục và kháng hệ cho các vùng nhiều phép.
  - Sát thương đo ở đây thấp (0,89) vì mô hình không tính sát thương bẫy (bẫy ×2,0 và nổ lan ×1,5).
  - Thiên phú hợp: Thời Gian Ngưng Đọng, Nhà Thảo Dược.

### 5.3. Pháp Sư — Phép diện rộng

| Build | 5 điểm / cấp | Nhánh chức 2 | ATK · HP · DEF | MP · hồi MP | Sát thương / trụ |
| --- | --- | --- | --- | --- | --- |
| **Mặc định** | INT 3 · VIT 1 · WIS 1 | — | 430 · 1.786 · 69 | 1.892 · 6,9/giây | 1,01 / 0,64 |
| **Nguyên Tố** | INT 4 · WIS 1 | **Đại Pháp Sư** | 456 · 1.491 · 54 | 2.069 · 6,9/giây | 1,14 / 0,52 |
| **Tử Linh** | INT 2 · VIT 2 · WIS 1 | **Tử Linh Sư** | 403 · 2.081 · 84 | 1.715 · 6,9/giây | 0,89 / 0,77 |

Ba build đều có kháng hệ 20% nhờ WIS tự tăng.

- **Nguyên Tố**: sát thương phép cao nhất game.
  - Chuỗi kỹ năng: Thiên Thạch (Đại Pháp Sư rơi 2 viên) → Sét Chuỗi → Băng Lao.
  - Phải đứng xa, dùng Băng Lao làm chậm quái và giữ Pháp Thuẫn để đỡ đòn.
  - Thiên phú hợp: Ngũ Hành Linh Căn (đổi hệ khắc quái), Thời Gian Ngưng Đọng.
- **Tử Linh**: đánh chậm hơn nhưng an toàn.
  - Xương Nô đứng chắn trước mặt; VIT giúp sống sót khi bị áp sát.
  - Hợp người mới chơi Pháp Sư. Thiên phú hợp: Bầy Đàn Bóng Tối, Thuần Thú Sư.
- **Không nên** dồn WIS quá 1/5: MP đã dư, mà WIS không cho sát thương.

### 5.4. Hộ Vệ — Đỡ đòn

| Build | 5 điểm / cấp | Nhánh chức 2 | ATK · HP · DEF | Tốc đánh · kháng hệ | Sát thương / trụ |
| --- | --- | --- | --- | --- | --- |
| **Mặc định** | VIT 3 · STR 2 | — | 505 · 2.964 · 248 | 0,91 · 7% | 0,79 / 1,70 |
| **Thành Trì** | VIT 3 · STR 1 · WIS 1 | **Thiết Vệ** | 481 · 2.964 · 248 | 0,91 · 13% | 0,75 / 1,70 |
| **Thánh Chiến** | STR 3 · VIT 1 · AGI 1 | **Thánh Kỵ Sĩ** | 514 · 2.256 · 209 | 1,00 · 7% | 0,90 / 1,28 |

- **Thành Trì**: đứng giữa bầy quái.
  - Thiết Vệ nhận ít hơn thêm 15% sát thương và phản lại 30%. Càng bị đánh nhiều thì sát thương phản càng lớn — đây là nguồn sát thương mà mô hình không tính.
  - WIS cho kháng hệ và kháng hiệu ứng: sau 25% của lớp, bị choáng ngắn hơn nữa.
  - Thiên phú hợp: Thân Thể Cường Tráng, Long Mạch. Dòng phụ: HP, Phòng thủ, kháng hệ.
- **Thánh Chiến**: Hộ Vệ đánh mạnh.
  - Thánh Kỵ Sĩ được +15% sát thương khi HP trên 70%, kèm hút máu 5%. Cần đủ trụ để giữ HP cao, nên STR là chính, VIT là phụ.
  - Thiên phú hợp: Hấp Huyết, Huyết Chiến.
- Hộ Vệ hạ boss chậm hơn lớp khác khoảng 20–25%, đúng luật cho phép của docs/24. Bù lại không chết.

### 5.5. Triệu Hồi Sư — Điều khiển linh thú

| Build | 5 điểm / cấp | Nhánh chức 2 | ATK · HP · DEF | MP · hồi MP · kháng hệ | Sát thương bản thân / trụ |
| --- | --- | --- | --- | --- | --- |
| **Mặc định** | INT 3 · VIT 1 · WIS 1 | — | 397 · 2.150 · 111 | 1.654 · 7,5/giây · 23% | 0,85 / 0,84 |
| **Long Uy** | INT 4 · VIT 1 | **Ngự Long Sư** | 421 · 2.150 · 111 | 1.830 · 6,3/giây · 17% | 0,97 / 0,84 |
| **Đồ Đằng** | INT 2 · WIS 2 · VIT 1 | **Đồ Đằng Sư** | 374 · 2.150 · 111 | 1.476 · 8,7/giây · 29% | 0,75 / 0,84 |

Cột sát thương chỉ tính **bản thân**. Linh thú lấy 40% chỉ số của chủ, nên mỗi điểm INT tăng cả sát thương của thú.

- **Long Uy**: sát thương lớn.
  - Ấu Long và Hoả Hồ nổ lan, cộng Liên Kết Linh Hồn (thú +40% sát thương). Ba thú chủ lực nên chọn: Sói Bóng, Thạch Quỷ, Ấu Long.
  - Thiên phú hợp: Thuần Thú Sư, Bầy Đàn Bóng Tối.
- **Đồ Đằng**: đánh lâu, đánh boss.
  - Đứng trong vòng đồ đằng thì hồi 2% HP và 2% MP mỗi giây. WIS cho thú thêm HP và cho chủ kháng hệ 29%, gần trần 50% khi có thêm trang bị.
  - Đúng "Đánh Boss lâu dài, solo nội dung khó" của CR-001. Thiên phú hợp: Nhà Thảo Dược, Long Mạch.
- **Điểm yếu** (theo CR-001): cần thời gian gọi thú đầu trận. Khi chưa có thú, sát thương bản thân chỉ bằng 85% lớp khác.

## 6. Giao diện đi kèm

Bổ sung cho docs/24 mục 5 (CS-UI1…4):

| Mã | Yêu cầu |
| --- | --- |
| CS-UI5 | Trang Chỉ số có 7 dòng thuộc tính. Mỗi dòng ghi "khởi tạo + tự tăng + điểm cộng"; ví dụ "STR 342 = 18 + 147 + 177" |
| CS-UI6 | Nút **Tự cộng điểm** có chọn build: Mặc định / 2 build chuyên của lớp. Từ cấp 60, gợi ý build khớp nhánh chức 2 đã chọn |
| CS-UI7 | Tooltip WIS và DEX ghi cả tác dụng chung lẫn tác dụng riêng của lớp. Thuộc tính đã chạm trần (ví dụ chí mạng 60%) ghi "đã chạm trần" màu xám |
| CS-UI8 | Màn chọn lớp hiện 7 thuộc tính khởi tạo dạng thanh, cạnh 5 sao của bảng cân bằng CR-001 |

## 7. Ảnh hưởng khi làm

| Hạng mục | Việc |
| --- | --- |
| Code | `core/stats.gd`: thêm `wis`, `dex` vào `STATS`; bảng `START` / `GROW` / phần gốc theo cấp thay `BASE_STATS`; bỏ phần trừ ngược D47 và các hằng `HUNTER_*`, `MAGE_*`, `SUMMONER_*`, `GUARD_*`. `GameWorld`: xuyên giáp, Phá Thế từ DEX, kháng hiệu ứng, tốc chạy theo lớp, Kiếm thế, Thân pháp. `Classes2`: linh thú lấy 40% chỉ số chủ, 3 thú chủ lực, Gắn kết. `data/classes.gd`: `auto` → 3 build |
| Save | Phiên bản +1 (game-c6 đang giữ v18): thêm `wis`, `dex` = 0; **tẩy điểm miễn phí 1 lần** (Q152) |
| Test sửa | Chạy lại toàn bộ TL-B…TL-B6, SK2-T4, SK3-T4, TL-J3, LH1/LH2, M1-12, PACE. UI-19 (chỉ số mặc định) viết lại theo bảng 2.3 |
| Test mới | **CS-T1**: mỗi lớp đứng đầu ít nhất 2 chỉ số ở cấp 1 (máy kiểm tra "đặc thù"). **CS-T2**: chỉ số cấp 1 / 30 / 60 khớp bảng 2.3 và 5.x (±1). **CS-T3**: mỗi lớp, 3 build chênh nhau ≤ 25% thời gian hạ boss chương 4, 0 lần chết. **CS-T4**: save cũ được tẩy điểm 1 lần, thêm WIS/DEX = 0 |
| Tài liệu | 02 (D47 → quyết định mới), 03, 04, 20 (bảng theo cấp cho 5 lớp, 7 thuộc tính), 24 (ghi "mục 3–4 thay bằng 26") |

Ước lượng: 1 đợt code (stats + UI) và 1 đợt cân bằng. Cân bằng tốn thời gian hơn: mỗi vòng test đầy đủ mất khoảng 15 phút.

## 8. Điểm cần chủ dự án chọn

Q147–Q152 của docs/24 vẫn giữ (đề xuất: Có / Có / Có / Giữ 5 điểm / Có / Có). Thêm:

| # | Câu hỏi | Đề xuất |
| --- | --- | --- |
| Q161 | Dùng hệ **7 thuộc tính** của CR-001 (thêm WIS, DEX)? | **Có**. Phân biệt lớp rõ hơn: Thợ Săn có DEX, Pháp Sư và Triệu Hồi Sư có WIS |
| Q162 | Giữ nguyên **số** thuộc tính của CR-001, đổi **hệ số quy đổi** (mục 2.1) để chỉ số cuối giữ thang game? | **Có**. Nếu giữ hệ số cũ, Tấn công cấp 1 gấp 3,6 lần, phải cân lại toàn bộ quái 9 chương |
| Q163 | Đổi "thù hận", "độ chính xác", "tối đa 3 thú", "+100 MP" như mục 3.3? | **Có** |
| Q164 | Hộ Vệ có thêm **chặn đòn** (docs/24) ngoài +30% Phòng thủ và Khiên −15%? | **Không**. Trụ đã 1,70 lần Kiếm Khách; chặn đòn để dành cho trang bị khiên sau này |
| Q165 | Tốc chạy theo lớp: Kiếm Khách 265 · Thợ Săn 250 · Pháp Sư / Triệu Hồi Sư 220 · Hộ Vệ 210? | **Có**. Khớp cột "Cơ động" của CR-001 |
| Q166 | Mỗi lớp 3 build (Mặc định + 2 build theo nhánh chức 2), chọn được ở nút Tự cộng điểm? | **Có** |
| Q167 | Thợ Săn +15% chí mạng gốc (CR-001) làm chí mạng chạm trần 60% quanh cấp 60. Giữ? | **Giữ**. Đổi lại, LUK của Thợ Săn sau trần chuyển thành ST chí mạng (+0,2% mỗi điểm vượt trần) để không phí điểm |
| Q168 | Hạn cân bằng: Kiếm Khách, Thợ Săn được mạnh hơn ở cấp cao (×1,26–1,38 ở cấp 100)? | **Không**. Hạ AGI xuống +0,12% tốc đánh nếu test cấp cao vượt luật 25% |

## 9. Kết quả triển khai (CS, 28–30/10)

Chủ dự án duyệt theo đề xuất ("triển khai theo đề xuất mới"). Đã code đủ mục 2–6; số chỉ số cuối cùng chốt bằng test cân bằng nên khác bảng đề xuất ở mục 2.2, 2.3 và 5 — **số đúng là bảng 9.2 và 9.3** (bảng cũ giữ để so sánh).

### 9.1. Đã làm

| Hạng mục | Nội dung | Code |
| --- | --- | --- |
| 7 thuộc tính | STR · AGI · VIT · INT · **WIS** · **DEX** · LUK. Thuộc tính = khởi tạo CR-001 + tự tăng × (cấp − 1) (làm tròn xuống) + điểm cộng + điểm Đạo Tặc cướp. Bỏ phần trừ ngược D47 | `Stats.START`, `GROW`, `attributes()`, `derive()` |
| Hồ sơ lớp | Phần gốc theo cấp, Tấn công từ thuộc tính chính, đặc tính lớp (mục 3.1) | `Stats.CLASS`, `base_atk()` |
| Xuyên giáp, Phá Thế | Đòn của người chơi bỏ qua `armor_pen` Phòng thủ quái; DEX cộng `poise_bonus` sát thương vào thanh Phá Thế | `GameWorld._hit_enemy`, `_apply_damage` |
| Kháng hiệu ứng | Hộ Vệ 25% + 0,1%/WIS (trần 60%): phần choáng / trói / chậm mới nhận bị rút ngắn | `GameWorld._resist_cc()` |
| Kiếm thế | Kiếm Khách: đòn trúng liên tiếp trong 2 giây +2% tốc đánh (tối đa +20%, tính tối đa 1 lần / 0,25 giây), mất khi bị trúng đòn | `GameWorld._sword_flow_hit()`, `atk_speed()` |
| Thân pháp | Thợ Săn né thành công → hồi chiêu né lăn −20% | `GameWorld._damage_player` |
| Chí mạng vượt trần | Thợ Săn: phần chí mạng vượt 60% đổi thành ST chí mạng (0,15% → 0,2%) — Q167 | `Stats.derive` |
| Triệu Hồi Sư | Linh thú +20% HP (+0,3%/WIS); tối đa 3 linh thú chủ lực (Sói Bóng, Thạch Quỷ, Ấu Long — gọi con thứ 4 thì con cũ nhất biến mất); **Gắn kết** +4% hồi MP mỗi linh thú (tối đa 3). Linh thú vẫn lấy Tấn công / HP theo chủ như trước (đúng ý "40% chỉ số chủ") | `Classes2.summon`, `bond_regen`, `MAIN_SUMMONS` |
| Hộ Vệ thù hận | Khiêu Khích bán kính 12 → 14,4 m | `Classes2.KK_THREAT` |
| Tốc chạy | 265 / 250 / 220 / 210 / 220 | `Stats.CLASS[c].move` |
| 3 build | Nút Tự cộng điểm có 3 build mỗi lớp; chưa chọn thì gợi ý build khớp nhánh chức 2; build Mặc định = `auto` của lớp (bot test dùng) | `ui/stats_page.gd` `PRESETS`, `preset_index()`; `data/classes.gd` `auto` |
| Trang Chỉ số | 7 thẻ thuộc tính (icon mới WIS, DEX), số lớn = khởi tạo + tự tăng + điểm cộng, nhãn "Chính" cho thuộc tính chính, dòng "Mỗi điểm" sinh từ hằng số `Stats` (không ghi tay), "Đang cho" có xuyên giáp / Phá Thế / kháng hiệu ứng / HP linh thú / kháng hệ và ghi "chí mạng đã chạm trần 60%"; cột phải thêm Xuyên giáp, Tốc chạy, Kháng hiệu ứng | `ui/stats_page.gd` |
| Màn chọn lớp | Dòng 7 thuộc tính khởi tạo; rê chuột xem tự tăng mỗi cấp | `ui/class_select.gd` |
| Save v19 | Thêm `wis`, `dex`; save < v19 được **tẩy điểm miễn phí 1 lần** (trả toàn bộ điểm đã cộng, giữ điểm Đạo Tặc cướp), vào game báo 1 dòng | `Profile.load_dict`, `cs_refunded` |
| Icon | `stat-wis` (hoa sen tím), `stat-dex` (hồng tâm có mũi tên) | `tools/art/stat_icons.py` |

### 9.2. Hệ số cuối cùng (khác đề xuất)

| Lớp | HP gốc | Tấn công gốc mỗi cấp | Tấn công từ thuộc tính | Khác đề xuất (lý do) |
| --- | --- | --- | --- | --- |
| Kiếm Khách | 50 + 20/cấp | 3,0 | STR × 0,6 | HP gốc 25 → 50 (chết ở vùng 1 với Thiên phú F); Tấn công gốc 3,3 → 3,0 (Kiếm thế đã cho +20% tốc đánh) |
| Thợ Săn | 30 + 22/cấp | 5,6; cấp 31+ **−1,2**; cấp 81+ **−14** | DEX × 0,25 · AGI × 0,2 · STR × 0,1 | Đề xuất DEX 0,35 / AGI 0,25 làm chí mạng 21% + Tấn công cao quá ở cấp 1; cấp cao AGI/DEX tự tăng dồn mạnh nên Tấn công gốc giảm dần |
| Pháp Sư | 35 + 24/cấp | 4,0 | INT × 0,45 | Tấn công gốc 4,4 → 4,0 (nhanh nhất 4/7 vùng) |
| Hộ Vệ | 0 + 16/cấp | 8,0; cấp 31+ **+2,8**; cấp 81+ **−22** | STR × 0,55 · VIT × 0,12 | Đề xuất (6,3; STR 0,4) chậm hơn lớp nhanh nhất 35–60%. HP 12 → 16/cấp |
| Triệu Hồi Sư | 25 + 25/cấp | 5,6; cấp 31+ **+0,6** | INT × 0,45 | Đề xuất (4,4; INT 0,4) chậm hơn 20–35% |
| Mọi lớp | | cấp 81+: −10 mỗi cấp (Thợ Săn −14, Hộ Vệ −22) | | Thuộc tính tự tăng dồn đủ mạnh ở cấp cao; giữ nhịp chương 8–9 như trước CS và để Hộ Vệ chức 3 (Thần Kỹ thay ô Khiên Thép) không nhanh hơn chức 2 quá 20% |

Các hệ số còn lại (MP, Phòng thủ, tốc đánh, chí mạng, né, xuyên giáp, kháng, mỗi điểm thuộc tính) đúng như mục 2.1–2.2.

### 9.3. Chỉ số thật

Cấp 1 (chưa cộng điểm):

| | Kiếm Khách | Thợ Săn | Pháp Sư | Hộ Vệ | Triệu Hồi Sư |
| --- | --- | --- | --- | --- | --- |
| HP | **110** | 80 | 75 | **132** | 85 |
| Tấn công | 10,8 | 9,6 | 10,8 | 10,3 | 9,0 |
| Phòng thủ | 5,0 | 4,5 | 4,0 | **9,8** | 5,0 |
| MP | 40 | 43 | **122** | 40 | 90 |
| Tốc đánh | 1,02 | 1,03 | 0,96 | 0,91 | 1,01 |
| Chí mạng · ST chí mạng | 10,2% · **×1,7** | **21,1%** · ×1,5 | 4,6% · ×1,5 | 4,0% · ×1,5 | 5,0% · ×1,5 |
| Né · xuyên giáp | **11,2%** · 1,4% | 1,6% · 11,9% | 0,6% · **16,0%** | 0,5% · 0,8% | 0,8% · 1,0% |
| Tốc chạy | **265** | 250 | 220 | 210 | 220 |

Cấp 60, chưa mặc đồ (CS-T2 kiểm build Mặc định):

| Lớp · build | Tấn công | HP | Phòng thủ | MP | Tốc đánh | Chí mạng | Né | Xuyên | Kháng hệ |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Kiếm Khách · Mặc định | 382 | 1.880 | 105 | 158 | 1,29 | 19% | 25% | 10% | 1% |
| Kiếm Khách · Bạo Kích | 382 | 1.585 | 91 | 158 | 1,29 | 28% | 25% | 10% | 1% |
| Kiếm Khách · Huyết Chiến | 382 | 2.175 | 120 | 158 | 1,20 | 16% | 21% | 10% | 1% |
| Thợ Săn · Mặc định | 423 | 1.673 | 78 | 220 | 1,43 | 48% | 23% | 38% | 1% |
| Thợ Săn · Bách Phát | 438 | 1.378 | 64 | 220 | 1,43 | 48% | 23% | 40% | 1% |
| Thợ Săn · Bẫy Thủ | 414 | 1.673 | 78 | 220 | 1,25 | 42% | 13% | 40% | 7% |
| Pháp Sư · Mặc định | 406 | 1.786 | 69 | 1.892 | 0,96 | 5% | 1% | 22% | 20% |
| Pháp Sư · Nguyên Tố | 433 | 1.491 | 54 | 2.069 | 0,96 | 5% | 1% | 22% | 20% |
| Pháp Sư · Tử Linh | 380 | 2.081 | 84 | 1.715 | 0,96 | 5% | 1% | 22% | 20% |
| Hộ Vệ · Mặc định | 722 | 3.200 | 248 | 182 | 0,91 | 4% | 0% | 1% | 7% |
| Hộ Vệ · Thành Trì | 690 | 3.200 | 248 | 182 | 0,91 | 4% | 0% | 1% | 13% |
| Hộ Vệ · Thánh Chiến | 740 | 2.492 | 209 | 182 | 1,00 | 7% | 5% | 1% | 7% |
| Triệu Hồi Sư · Mặc định | 503 | 2.150 | 111 | 1.652 | 1,01 | 5% | 1% | 1% | 23% |
| Triệu Hồi Sư · Long Uy | 530 | 2.150 | 111 | 1.829 | 1,01 | 5% | 1% | 1% | 17% |
| Triệu Hồi Sư · Đồ Đằng | 477 | 2.150 | 111 | 1.475 | 1,01 | 5% | 1% | 1% | 29% |

Tấn công của Hộ Vệ cao nhất nhưng hạ boss vẫn chậm nhất: tốc đánh 0,90, gần như không chí mạng, đánh cận chiến 8 m.

### 9.4. Cân bằng sau CS (bot, trung bình 20 Thiên phú)

Luật kịch bản: các lớp hạ cùng boss chênh ≤ 25%, 0 lần chết.

| Bài | Boss | Nhanh nhất · chậm nhất (giây) | Chênh |
| --- | --- | --- | --- |
| TL-B | Sói Chúa (vùng 1) | Hộ Vệ 26,5 · Triệu Hồi Sư 34,2 | 23% |
| TL-B2 | Huyền Ảnh | Pháp Sư 41,5 · Triệu Hồi Sư 46,0 | 10% |
| TL-B3 | Sa Hoàng | Thợ Săn 26,2 · Hộ Vệ 32,6 | 20% |
| TL-B4 | Nữ Vương | Thợ Săn 30,1 · Hộ Vệ 37,2 | 19% |
| TL-B5 | Viêm Long | Pháp Sư 36,1 · Hộ Vệ 42,1 | 14% |
| TL-B6 | Bản Ngã | Thợ Săn 24,2 · Triệu Hồi Sư 30,1 | 20% |
| TL-B7 | Thiên Không Cự Thần (cấp 81) | Thợ Săn 18,6 · Hộ Vệ 24,5 | 24% |
| TL-J3 | Cự Thần cấp 90, chức 3 | Thợ Săn 16,7 · Hộ Vệ 21,3 | 22%; chức 3 nhanh hơn chức 2 (Kiếm Khách / Thợ Săn / Pháp Sư / Hộ Vệ / Triệu Hồi Sư): 13 / 16 / 12 / 18 / 19% |

Sát sao nhất là TL-B7 (24%) và TL-B (23%). Lần cân bằng tới nên xem Hộ Vệ ở vùng 7 và Triệu Hồi Sư ở vùng 1.

### 9.5. Test

- **Mới:** CS-T1, T2 (đứng đầu ≥ 2 chỉ số; bảng 9.3; 3 build; gợi ý theo nhánh; chí mạng vượt trần), CS-T3 (xuyên giáp, kháng hiệu ứng, Kiếm thế, Thân pháp, Gắn kết, HP linh thú, 3 chủ lực, Khiêu Khích, Phá Thế, tốc chạy), CS-T4 (save v18 → v19 tẩy điểm 1 lần, cộng được WIS / DEX).
- **Sửa theo công thức mới:** M3 chỉ số lớp, SN-T1, UI-19, UI-21, LH1, TH-T1, SK2 (chí mạng nền), tự cộng điểm, TL-C và TP-T1 (Thân Thể so với HP gốc của lớp; rơi đồ cộng phần LUK khởi tạo), CL-T4 (trần né Thợ Săn 40%), C3-T4 / C5-T3 (tắt né khi đo sát thương nhận vào), C5-T2 (kháng Hỏa từ WIS), SH-T1 / J3-T2 (HP linh thú × 1,2 × WIS), TH-T1 / J3-T2 / J3-T3 (đếm giới hạn chung bằng Linh Ưng vì Sói Bóng giờ là linh thú chủ lực). Bot test cộng điểm theo build Mặc định (`_class_points`).
