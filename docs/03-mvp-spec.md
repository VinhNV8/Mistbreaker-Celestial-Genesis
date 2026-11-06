# Đặc tả MVP — Vertical slice

| | |
| --- | --- |
| Dự án | Thiên Phú Khai Giới |
| Nguồn | [Kịch bản game](kich-ban-game-thien-phu-khai-gioi.md), mục 9, giai đoạn 2: *"MVP / Vertical slice: 2 lớp, 20 Thiên phú, chương 1–2, lãnh địa cấp 1–2, trang bị + cường hoá, lưu game. Thử nghiệm kín 50–100 người."* |
| Kế thừa | Chương 1, phần nền — [01-requirement-spec.md](01-requirement-spec.md) |
| Cập nhật | 20/10/2026 |

Quy trình cho mỗi đợt: **viết spec → duyệt → code → test → cập nhật spec (trạng thái) và technical spec**. Mục 2 chia MVP thành 5 đợt. Mục 3 là spec chi tiết của đợt đang làm. Các đợt sau sẽ được viết chi tiết khi tới lượt.

## 1. Phạm vi MVP so với kịch bản

| Hạng mục trong kịch bản | MVP làm | Để lại sau MVP |
| --- | --- | --- |
| Lớp nhân vật (mục 4) | Kiếm Khách + Thợ Săn + Pháp Sư (SN2) + **Hộ Vệ** (LH1) + **Triệu Hồi Sư** (LH2, CR-03) — [19](19-lop-ho-ve-trieu-hoi-su.md); chuyển chức 1–3 (J3 — [23](23-chuyen-chuc-3-linh-thu-co-mau.md), điều kiện bản tạm khi chưa có chương 8) | Chuyển chức 3 theo đúng chương 8 (Giáo Chủ, Lõi Hư Vô, Tổ Sư) |
| Thiên phú (mục 3) | Đủ 20 Thiên phú mẫu, hạng F → SSS; luyện cấp Lv 1→10 | Thiên phú phụ (cấp 30/60), tiến hoá hạng, cộng hưởng |
| Bản đồ (mục 6) | Vùng 1 Rừng Sương (cấp 1–10), vùng 2 Đồng Bằng Gió Hú (cấp 10–20) | Vùng 3–9, độ khó Ác mộng/Địa ngục |
| Cốt truyện (mục 2) | Chương 1–2 | Chương 3–9 |
| Lãnh địa (mục 7) | Trại → Thôn (cấp 1–2), Xưởng Rèn, Đền Thiên Phú | Trấn, Thành, Hoàng Thành; Triều Hư Vô |
| Trang bị (mục 8) | 8 ô, 5 phẩm chất, affix, bộ trang bị, cường hoá +15, phân rã | Khảm ngọc ngũ hành |
| Quái (mục 5) | Boss vùng 1–2, quái tinh anh, boss hiếm | Boss thế giới |
| Lưu game | Lưu cục bộ, có chuyển đổi save cũ | Lưu đám mây |

## 2. Lộ trình các đợt

Thứ tự được chọn theo phụ thuộc: nhiều Thiên phú trong danh sách 20 cần hệ thống khác có trước. Ví dụ Thợ Rèn Bẩm Sinh cần cường hoá, Bàn Tay Vàng cần phân rã, Thuần Thú Sư cần thú cưng.

| Đợt | Nội dung | Mục kịch bản | Phụ thuộc | Trạng thái |
| --- | --- | --- | --- | --- |
| **M1** | Trang bị: rơi đồ, túi đồ, mặc/tháo, affix, bộ trang bị, cường hoá, phân rã, Lực chiến | 4, 5, 8 | — | ✅ Đã xong 20/10/2026 — kết quả ở mục 3.12 |
| **M2** | Đủ 20 Thiên phú (bể quay 7 hạng) + luyện cấp Thiên phú bằng Tinh Hoa + Đền Thiên Phú | 3, 7 | M1 | ✅ Đã xong 20/10/2026 — kết quả ở mục 4.11 |
| **M3** | Lớp Thợ Săn (đánh xa) + chọn lớp lúc tạo nhân vật, 4 kỹ năng mỗi lớp, MP, né tránh, công thức chỉ số quái mới | 4, 5, 9 | M2 | ✅ Đã xong 20/10/2026 — kết quả ở mục 5.12 |
| M4 | Chương 2: Đồng Bằng Gió Hú, gió đẩy lùi, boss Tướng Gián Điệp Huyền Ảnh, Thành Biên Đài, di chuyển giữa các vùng | 2, 5, 6, 7 | M1–M3 | 🟡 Spec ở mục 6 (3 đợt con M4.1–M4.3), đang code |
| M5 | Cốt truyện có thoại, nhiệm vụ chính, boss hiếm, cân bằng lại 1 → 20 cho thử nghiệm kín | 2, 5, 9 | M1–M4 | Chưa viết spec |

## 3. Đợt M1 — Trang bị và cường hoá

### 3.1. Mục tiêu

Thêm động lực "nhặt đồ mạnh hơn" vào vòng lặp đánh quái, đúng tinh thần Diablo/Path of Exile mà kịch bản lấy làm tham chiếu (mục 1). Theo kịch bản 30 phút đầu (mục 9), người chơi phải **nhặt trang bị xanh đầu tiên ở phút 10–15**.

### 3.2. Yêu cầu chức năng

Mã yêu cầu bắt đầu bằng `EQ-`. Cột **Nguồn** ghi mục kịch bản; ghi "đề xuất" là phần kịch bản chưa nói rõ, cần duyệt (xem 3.9).

| Mã | Yêu cầu | Nguồn | Tiêu chí nghiệm thu |
| --- | --- | --- | --- |
| EQ-01 | 8 ô trang bị: vũ khí, mũ, áo, găng, giày, dây chuyền, nhẫn, bùa hộ mệnh | 8 | Mỗi ô chỉ mặc được đúng loại |
| EQ-02 | 5 phẩm chất với số affix cố định: Trắng 0, Xanh lá 1, Xanh dương 2, Tím 3, Cam 4 + hiệu ứng riêng | 8 | Đồ sinh ra có đúng số affix, không trùng loại |
| EQ-03 | Mỗi món có cấp đồ = cấp quái làm rơi; chỉ số gốc tăng theo cấp đồ và phẩm chất | đề xuất | Đồ cấp cao hơn có chỉ số gốc cao hơn |
| EQ-04 | Quái tinh anh **chắc chắn** rơi 1 món Xanh dương hoặc Tím | 5 | — |
| EQ-05 | Quái thường có 6% rơi đồ (Trắng 60%, Xanh lá 35%, Xanh dương 5%) và 25% rơi Đá Cường Hoá | 5, 9 (đề xuất) | Bot đánh 15 phút đầu nhặt được ít nhất 1 món Xanh lá |
| EQ-06 | Sói Chúa Hư Vô chắc chắn rơi 1 món Tím; 15% rơi món Cam "Nanh Sói Chúa" | đề xuất | — |
| EQ-07 | Sói Chúa hồi sinh 10 phút sau khi bị hạ, để cày đồ | đề xuất | — |
| EQ-08 | Rương Di tích tặng thêm 1 món Xanh dương | đề xuất | — |
| EQ-09 | Túi đồ 30 ô. Túi đầy thì món mới tự phân rã thành Đá Cường Hoá, kèm thông báo | đề xuất | Không mất đồ trong im lặng |
| EQ-10 | Mặc đồ thay đồ cũ (đồ cũ về túi); tháo đồ về túi (túi đầy thì không tháo được) | 8 | — |
| EQ-11 | Chỉ số trang bị cộng vào chỉ số nhân vật ngay khi mặc/tháo; HP hiện tại giữ đúng tỉ lệ | 4 | — |
| EQ-12 | Cường hoá +0 → +15: mỗi cấp +10% chỉ số gốc. +1 → +7 luôn thành công; từ +8 có thể thất bại; thất bại **không mất đồ, không tụt cấp**, chỉ mất nguyên liệu | 8 | Test 10.000 lần: +1…+7 luôn thành công, thất bại giữ nguyên món |
| EQ-13 | Cường hoá tốn vàng + Đá Cường Hoá theo bảng 3.5 | 8 | Thiếu nguyên liệu thì nút bị khoá kèm lý do |
| EQ-14 | Phân rã đồ trong túi → Đá Cường Hoá theo phẩm chất và cấp cường hoá | 8 (Bàn Tay Vàng nhắc tới phân rã) | — |
| EQ-15 | Bộ trang bị vùng 1 "Bộ Thợ Săn Sương" (6 món): hiệu ứng ở 2/4/6 món | 8 | Đủ số món thì hiệu ứng bật, thiếu thì tắt |
| EQ-16 | Món Cam "Nanh Sói Chúa" (vũ khí): mỗi đòn chém thứ 3 gây thêm 60% sát thương | 8 | — |
| EQ-17 | **Lực chiến**: một con số tổng hợp, hiện ở HUD và bảng chỉ số | 4 | Mặc đồ mạnh hơn thì Lực chiến tăng |
| EQ-18 | Bảng Túi đồ (phím **I**): 8 ô đang mặc, túi 30 ô, chi tiết món đang chọn, so sánh với món cùng ô đang mặc, các nút Mặc / Tháo / Cường hoá / Phân rã | 8 | Mở túi đồ thì game tạm dừng như các bảng khác |
| EQ-19 | Màu chữ tên đồ theo phẩm chất; nhặt đồ hiện thông báo tên món đúng màu | đề xuất | — |
| EQ-20 | Save lên version 2 (thêm túi đồ, đồ đang mặc, nguyên liệu). Save version 1 của prototype **tự chuyển đổi**, không mất tiến trình | — | Test nạp save v1 |

### 3.3. Chỉ số gốc theo ô

`L` = cấp đồ. Hệ số phẩm chất: Trắng 1,0 · Xanh lá 1,1 · Xanh dương 1,2 · Tím 1,35 · Cam 1,5.

| Ô | Chỉ số gốc | Giá trị ở cấp L |
| --- | --- | --- |
| Vũ khí | Tấn công | 4 + 2·L |
| Mũ | HP | 10 + 5·L |
| Áo | Phòng thủ | 2 + 1·L |
| Găng | Tấn công | 1 + 0,8·L |
| Giày | HP | 6 + 3·L |
| Dây chuyền | Chí mạng | 2% + 0,1%·L |
| Nhẫn | Sát thương chí mạng | 8% + 0,4%·L |
| Bùa hộ mệnh | HP | 8 + 4·L |

Chỉ số gốc × hệ số phẩm chất × (1 + 0,1 × cấp cường hoá).

### 3.4. Affix

Mỗi món rút ngẫu nhiên các loại affix **khác nhau** trong bảng dưới. Giá trị = mức gốc × hệ số ngẫu nhiên 0,8–1,2. Cường hoá không ảnh hưởng affix.

| Affix | Giá trị ở cấp L |
| --- | --- |
| Tấn công | 1 + 0,6·L |
| HP | 6 + 3·L |
| Phòng thủ | 1 + 0,4·L |
| Chí mạng | 3% |
| Sát thương chí mạng | 10% |
| Tốc đánh | 4% |
| Tốc chạy | 10 |

Hiện tại chí mạng gây ×1,5 sát thương; M1 đổi thành ×(1,5 + tổng "Sát thương chí mạng").

### 3.5. Cường hoá

`n` = cấp hiện tại (lên từ n → n+1). `L` = cấp đồ.

| Lên cấp | Tỉ lệ thành công |
| --- | --- |
| +1 → +7 | 100% |
| +8 | 80% |
| +9 | 70% |
| +10 | 60% |
| +11 | 50% |
| +12 | 40% |
| +13 | 30% |
| +14 | 25% |
| +15 | 20% |

- Vàng: `round(10 × (n+1)^1,6 × (1 + L/10))`
- Đá Cường Hoá: `1 + ⌊n/3⌋`
- Thất bại: mất vàng và đá, món giữ nguyên cấp.

### 3.6. Phân rã

Đá Cường Hoá nhận được: Trắng 1 · Xanh lá 2 · Xanh dương 3 · Tím 5 · Cam 8, cộng thêm `⌊cấp cường hoá / 2⌋`. Không phân rã được đồ đang mặc.

### 3.7. Bộ trang bị và đồ Cam

**Bộ Thợ Săn Sương** (vùng 1). Món thuộc bộ chỉ rơi ở phẩm chất Tím, 25% món Tím rơi trong Rừng Sương là đồ bộ.

| Số món | Hiệu ứng |
| --- | --- |
| 2 | +8% HP tối đa |
| 4 | +10% Tấn công |
| 6 | Xoáy Kiếm hồi chiêu 6 → 4 giây |

**Nanh Sói Chúa** (Cam, vũ khí): 4 affix ngẫu nhiên + hiệu ứng riêng *"Mỗi đòn chém thứ 3 gây thêm 60% sát thương"*. Hiệu ứng này cộng dồn được với Thiên phú Kiếm Tâm (đòn thứ 5).

### 3.8. Lực chiến

```
Lực chiến = round(ATK × 10 + HP + DEF × 8 + Chí mạng × 1000 + Sát thương chí mạng × 300 + (Tốc đánh − 1) × 800)
```

Nhân vật cấp 1 không mặc đồ = 440 điểm (100 + 100 + 40 + 50 + 150). Kịch bản đặt mốc mở vùng 3 là Lực chiến 5.000 (mục 6); M4 sẽ kiểm tra lại mốc này.

### 3.9. Điểm cần duyệt

Kịch bản chưa nói rõ những điểm dưới đây. M1 code theo **mặc định**; nếu bạn chọn khác thì chỉ cần sửa trong `data/` và `config.gd`. **Trạng thái: chưa duyệt** (20/10/2026) — đang chạy với mặc định.

| # | Câu hỏi | Mặc định | Lý do |
| --- | --- | --- | --- |
| Q1 | Quái thường có rơi trang bị không? Bảng quái (mục 5) chỉ ghi "nguyên liệu thường" | Có, 6%, đa số Trắng/Xanh lá | Mục 9 yêu cầu nhặt trang bị xanh ở phút 10–15 |
| Q2 | Boss vùng có rơi trang bị không? Kịch bản chỉ ghi "mở map, Tinh Hoa" | Có: 1 món Tím chắc chắn, 15% món Cam | Boss là phần thưởng lớn nhất chương; boss hiếm (rơi Cam) để M5 |
| Q3 | Boss vùng có đánh lại được không? | Có, hồi sinh sau 10 phút | Cho người chơi cày đồ |
| Q4 | Túi đầy thì sao? | Tự phân rã kèm thông báo | Không mất đồ trong im lặng |
| Q5 | Đồ có giới hạn cấp mặc không? | Không | Đơn giản cho MVP; xem lại khi có vùng 2 |

### 3.10. Thay đổi dữ liệu save (version 1 → 2)

Thêm vào hồ sơ:

| Trường | Kiểu | Mặc định khi chuyển từ v1 |
| --- | --- | --- |
| `inventory` | Mảng món đồ, tối đa 30 | `[]` |
| `equipment` | `{ô: món đồ}` | `{}` |
| `stones` | Số Đá Cường Hoá | `0` |
| `next_item_id` | Số tăng dần để đặt id món đồ | `1` |
| `boss_respawn_at` | Thời điểm (giây chơi) Sói Chúa hồi sinh | `0` |

Một món đồ:

```json
{"id": 12, "slot": "weapon", "rarity": "purple", "level": 5, "plus": 3,
 "set": "frost_hunter", "unique": "",
 "affixes": [{"stat": "crit", "value": 0.031}, {"stat": "atk", "value": 4.2}]}
```

### 3.11. Kiểm thử tự động cần có

1. Sinh 1.000 món mỗi phẩm chất: đúng số affix, không trùng loại affix, chỉ số gốc > 0.
2. Cường hoá 10.000 lần: +1…+7 luôn thành công; tỉ lệ +8 xấp xỉ 80%; thất bại giữ nguyên cấp và món.
3. Thiếu vàng hoặc đá thì cường hoá bị từ chối, không trừ gì.
4. Mặc/tháo cộng trừ đúng chỉ số; mặc đồ thay đồ cũ về túi.
5. Hiệu ứng bộ bật ở đúng 2/4/6 món.
6. Phân rã ra đúng số đá; đồ đang mặc không phân rã được.
7. Quái tinh anh luôn rơi Xanh dương hoặc Tím.
8. Túi đầy: món mới tự phân rã.
9. Save v1 chuyển đổi được, lưu/nạp v2 giữ nguyên đồ.
10. Bot đánh 15 phút đầu nhặt được ít nhất 1 món Xanh lá trở lên.
11. Trận boss vẫn thắng được với đồ rơi tự nhiên (chạy lại bot cân bằng).

### 3.12. Kết quả triển khai M1

Hoàn thành 20/10/2026. Kiểm thử: 12 test tự động mới (tổng 28/28 qua) và smoke test có ảnh chụp bảng Túi đồ.

| Mã | Trạng thái | Kiểm chứng |
| --- | --- | --- |
| EQ-01, 02, 03 | ✅ | Test M1-1: 5.000 món, đúng số affix, không trùng, đồ cấp cao mạnh hơn |
| EQ-04 | ✅ | Test M1-7: 200 lần hạ tinh anh đều rơi Xanh dương/Tím |
| EQ-05 | ✅ | Test M1-10: bot 15 phút nhặt được 21 món Xanh lá trở lên |
| EQ-06, 07 | ✅ | Test M1-11: boss rơi Tím, hồi sinh sau 10 phút, hạ lần 2 không hiện lại màn hình kết chương |
| EQ-08 | 🟡 | Smoke test |
| EQ-09 | ✅ | Test M1-8 |
| EQ-10, 11 | ✅ | Test M1-4 |
| EQ-12, 13 | ✅ | Test M1-2, M1-3: 10.000 lần thử, +8 thành công ≈ 80%, thất bại giữ nguyên món |
| EQ-14 | ✅ | Test M1-6 |
| EQ-15 | ✅ | Test M1-5 |
| EQ-16 | 🟡 | Smoke test (mặc và cường hoá Nanh Sói Chúa) |
| EQ-17, 18, 19 | 🟡 | Smoke test, ảnh `05b-inventory`, `05c-inventory-equipped` |
| EQ-20 | ✅ | Test M1-9: save v1 nạp được; save v2 giữ nguyên đồ và kiểu dữ liệu |

**Cân bằng (bot, seed cố định):**

| Tình huống | Thời gian hạ boss | Số lần chết |
| --- | --- | --- |
| Cấp 5, có cộng điểm, không đồ | 42,4 giây | 0 |
| Cấp 5, có cộng điểm, mặc 2 món nhặt được trên đường lên cấp | 27,3 giây | 0 |
| Cấp 11, có cộng điểm, mặc 7 món | 11,6 giây | 0 |

Trang bị rút ngắn trận boss khoảng 35% ở đúng cấp dự kiến; boss vẫn là thử thách. Test M1-12 sẽ báo hỏng nếu trận boss cấp 5 xuống dưới 20 giây.

**Phát hiện cần đưa vào playtest:**

| # | Phát hiện | Đề xuất |
| --- | --- | --- |
| F1 | Nhân vật **không cộng điểm tiềm năng** yếu hơn hẳn: cấp 11 không cộng điểm còn yếu hơn cấp 5 có cộng điểm (ATK 30 so với 42) | Quan sát xem người chơi có bỏ sót không. Nếu có: thêm nút "Tự cộng điểm theo gợi ý" (đưa vào M5) |
| F2 | Bot lên cấp 5 sau 101 giây, cấp 11 sau 15 phút. Kịch bản đặt mốc 1 → 10 trong 30 phút | Bot đánh liên tục nên nhanh hơn người. Đo thời gian thật khi playtest rồi mới chỉnh công thức EXP |
| F3 | Túi 30 ô đầy sau khoảng 15 phút cày, phần lớn là đồ Trắng | Đề xuất thêm nút "Phân rã tất cả đồ Trắng/Xanh lá" (đưa vào M5) |

## 4. Đợt M2 — Đủ 20 Thiên phú

### 4.1. Mục tiêu

Thiên phú là đặc trưng của game: *"Thiên phú quyết định lối chơi chứ không chỉ cộng chỉ số"* (kịch bản mục 3). M2 đưa vào đủ 20 Thiên phú mẫu với 7 hạng F → SSS, đúng tỉ lệ quay, và cho Thiên phú lên cấp bằng Thiên Phú Tinh Hoa tại Đền Thiên Phú.

**Ngoài phạm vi M2** (theo bảng 1): Thiên phú phụ (cấp 30/60), tiến hoá hạng, cộng hưởng, tẩy Thiên phú.

### 4.2. Cách hiểu bảng độ hiếm

Kịch bản quy định mức sức mạnh theo hạng (mục 3, bảng Độ hiếm). Danh sách 20 Thiên phú chỉ mô tả hiệu ứng chính, nên M2 **bổ sung** phần còn thiếu để mỗi Thiên phú khớp với hạng của nó:

| Hạng | Kịch bản yêu cầu | M2 làm |
| --- | --- | --- |
| F | Buff chỉ số nhỏ | Chỉ hiệu ứng chính |
| C | Buff + 1 hiệu ứng bị động | Chỉ hiệu ứng chính (đã là bị động) |
| B | Bị động + **1 kỹ năng chủ động** | Hiệu ứng chính + kỹ năng chủ động phím L *(bổ sung)* |
| A | Thay đổi cơ chế chơi | Hiệu ứng chính (đều đổi cơ chế) |
| S | Cơ chế riêng + **kỹ năng tối thượng** | Hiệu ứng chính + kỹ năng tối thượng phím L *(bổ sung với Bầy Đàn Bóng Tối)* |
| SS | Hiệu ứng lên cả bản đồ / lãnh địa | Hiệu ứng chính |
| SSS | Độc nhất server (tuỳ chọn) | Hiệu ứng chính; game chơi đơn nên bỏ "độc nhất server" |

Nguyên tắc cân bằng của kịch bản: *"chênh lệch sức mạnh giữa F và S ở cùng cấp không quá 25%"*. Test TL-B kiểm tra nguyên tắc này bằng bot (mục 4.9).

### 4.3. 20 Thiên phú

Quy ước khoảng cách: **1 m = 10 đơn vị** trong game. Phím L dùng kỹ năng Thiên phú.

| # | Thiên phú | Hạng | Nhóm | Hiệu ứng trong game | Kỹ năng L | Hệ thống cần thêm |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | Thân Thể Cường Tráng | F | Chiến đấu | +8% HP tối đa | — | — |
| 2 | Tay Nhanh | F | Chiến đấu | +5% tốc đánh | — | — (đã có) |
| 3 | May Mắn Nhỏ | F | Kinh tế | Tỉ lệ rơi đồ của quái thường 6% → 11%, Đá Cường Hoá 25% → 30% | — | — |
| 4 | Chân Không Biết Mỏi | F | Khai phá | +10% tốc chạy khi không giao chiến (3 giây không đánh/không trúng đòn) | — | — |
| 5 | Huyết Chiến | C | Chiến đấu | HP < 30%: +20% sát thương | — | — (đã có) |
| 6 | Thợ Rèn Bẩm Sinh | C | Chế tạo | Cường hoá +10% tỉ lệ thành công | — | — |
| 7 | Khứu Giác Kho Báu | C | Khai phá | Hiện Rương ẩn trong bán kính 30 m | — | **Rương ẩn** |
| 8 | Kiếm Tâm | B | Chiến đấu | Đòn chém thứ 5 ×2 sát thương | *Nhất Kiếm Đoạn*: đòn chém tiếp theo ×3 và chắc chắn chí mạng; hồi 15 giây | — |
| 9 | Nhà Thảo Dược | B | Chế tạo | Hái thảo dược ×2; bình máu hồi mạnh hơn 30% | *Linh Dược*: hồi 30% HP, không tốn bình; hồi 45 giây | **Thảo dược + bình máu** |
| 10 | Trái Tim Lãnh Chúa | B | Lãnh địa | Công trình xây nhanh 25% | *Hiệu Triệu*: hoàn thành ngay 1 công trình đang xây; hồi 300 giây | **Thời gian xây** |
| 11 | Thuần Thú Sư | A | Triệu hồi | Đòn đánh làm quái thường tụt dưới 10% HP thì thu phục thành thú cưng (tối đa 2) | — | **Đồng minh** |
| 12 | Mắt Ưng | A | Khai phá | Nhìn xuyên sương mù 2 ô; +10% chí mạng | — | — (đã có) |
| 13 | Hấp Huyết | A | Chiến đấu | 8% sát thương gây ra hồi thành máu; **không dùng được bình máu** | — | Bình máu |
| 14 | Bàn Tay Vàng | A | Kinh tế | Phân rã có 20% nhận thêm 1 **Tinh Kim** (nguyên liệu hiếm) | — | **Tinh Kim** |
| 15 | Ngũ Hành Linh Căn | S | Phép thuật | Đòn đánh mang hệ (Kim/Mộc/Thủy/Hỏa/Thổ); đánh hệ khắc +30% | *Đổi hệ*: chuyển sang hệ kế tiếp. Xoáy Kiếm dùng trong 2 giây sau khi đổi hệ thành *Ngũ Hành Bộc Phá* (kết hợp 2 hệ): +100% sát thương, bán kính 16 m | **Ngũ hành** |
| 16 | Thời Gian Ngưng Đọng | S | Điều khiển | Kỹ năng chủ động là chính | Ngưng thời gian của quái 3 giây; hồi 90 giây | — (đã có) |
| 17 | Bầy Đàn Bóng Tối | S | Triệu hồi | Quái bị hạ có 15% đứng dậy thành lính bóng tối (tối đa 10, tồn tại 60 giây) | *Bóng Tối Trỗi Dậy*: gọi ngay 3 lính bóng tối; hồi 60 giây | Đồng minh |
| 18 | Thiên Mệnh Khai Giới | SS | Khai phá | Mỗi Đuốc dọn thêm tối đa 2 ô sương kề bên (tổng ×3); sản lượng lãnh địa +20% | — | — |
| 19 | Long Mạch | SS | Lãnh địa | Mở công trình **Long Mạch Đàn**; khi xây xong: +10% Tấn công và HP cho nhân vật và mọi đồng minh | — | **Công trình Rồng** |
| 20 | Đạo Tặc (Ẩn) | SSS | Đặc biệt | Mỗi lần hạ boss, sao chép 1 kỹ năng của boss đó | Dùng kỹ năng đã sao chép. Chương 1: *Vồ Mồi* (của Sói Chúa) — lao tới điểm ngắm (tối đa 30 m), ×2,5 sát thương bán kính 9 m; hồi 8 giây | — |

### 4.4. Hệ thống mới

| Mã | Hệ thống | Đặc tả | Nguồn |
| --- | --- | --- | --- |
| TL-S1 | **Rương ẩn** | Mỗi lần vào game sinh 6 rương ẩn rải rác ở Rừng Sương. Bình thường không nhìn thấy, nhưng đi sát (< 2,4 m) vẫn mở được. Mở: 10 × cấp vàng, 2 Đá Cường Hoá, 30% thêm 1 món Xanh lá/Xanh dương. Khứu Giác Kho Báu hiện các rương trong 30 m | TP #7 |
| TL-S2 | **Thảo dược, bình máu** | 8 bụi thảo dược trên bản đồ; đi qua để hái (+1, Nhà Thảo Dược +2); hái xong mọc lại chỗ khác sau 60 giây. Đủ 2 thảo dược tự chế 1 bình máu. Bình máu: bắt đầu 2, không giới hạn (SN12-01, 01/11 — trước: tối đa 5); phím **Q** hồi 35% HP, hồi chiêu 8 giây | TP #9, #13; mục 8 "mua bình thuốc" |
| TL-S3 | **Thời gian xây** | Xưởng Gỗ 60 giây, nâng Thôn 180 giây, Đền Thiên Phú 120 giây, Long Mạch Đàn 120 giây. Đồng hồ xây chạy cả khi offline (tối đa 12 giờ, cùng mức thu hoạch offline). Ô đất được tính là đã khai phá ngay khi bấm xây; sản lượng và hiệu ứng chỉ có khi xây xong | TP #10; mục 7 "xây dựng" |
| TL-S4 | **Đồng minh** | Thú cưng và lính bóng tối đi theo nhân vật, tự đánh quái gần nhất trong 26 m. Quái **không** tấn công đồng minh (đơn giản cho MVP). Thú cưng: chỉ số của con quái lúc thu phục, được lưu vào save, không biến mất. Lính bóng tối: tấn công = 30% tấn công nhân vật, mất sau 60 giây, không lưu | TP #11, #17 |
| TL-S5 | **Tinh Kim** | Nguyên liệu hiếm. Nguồn: Bàn Tay Vàng (20% khi phân rã), mỗi lần hạ Sói Chúa +1. Dùng: cường hoá lên **+10 trở lên** cần thêm 1 Tinh Kim mỗi lần (sửa EQ-13) | TP #14 |
| TL-S6 | **Ngũ hành** | Mỗi loại quái có một hệ: Sói Sương Mộc, Nấm Độc Thổ, Tinh Linh Sương Thủy, Sói Chúa Mộc (Rừng Sương hệ chủ đạo Mộc, mục 6). Khắc: Kim → Mộc → Thổ → Thủy → Hỏa → Kim. Hệ của quái hiện bằng chữ nhỏ cạnh thanh máu. Chỉ người có Ngũ Hành Linh Căn được đổi hệ đòn đánh (khảm ngọc để sau MVP) | Mục 5 "Ngũ hành tương khắc" |
| TL-S7 | **Long Mạch Đàn** | Chỉ xây được khi có Thiên phú Long Mạch: 150 vàng + 100 gỗ, 120 giây | TP #19 |

### 4.5. Bể quay 7 hạng

| Mã | Yêu cầu | Tiêu chí nghiệm thu |
| --- | --- | --- |
| TL-01 | Bể quay gồm đủ 20 Thiên phú. Tỉ lệ **theo hạng** đúng bảng kịch bản: F 30 · C 28 · B 22 · A 13 · S 5 · SS 1,8 · SSS 0,2. Trong cùng hạng, các Thiên phú chia đều | Mô phỏng 200.000 lần: mỗi hạng lệch < 0,5 điểm % |
| TL-02 | Bảo hiểm hạng B và 3 lần quay lại giữ nguyên như AWK-01…04 | Test cũ vẫn qua |
| TL-03 | Màn hình Lễ Thức Tỉnh hiện tỉ lệ theo hạng; Thiên phú SSS hiện tên "???" trong bảng tỉ lệ, chỉ lộ tên khi quay trúng | — |

### 4.6. Luyện cấp Thiên phú

| Mã | Yêu cầu | Nguồn |
| --- | --- | --- |
| TL-10 | Thiên phú có cấp 1 → 10. Mỗi cấp trên 1: +2% Tấn công và +2% HP (cấp 10 = +18%) | Mục 3 |
| TL-11 | Chi phí Thiên Phú Tinh Hoa để lên cấp n → n+1: 1, 1, 2, 2, 3, 3, 4, 4, 5 (tổng 25) | đề xuất |
| TL-12 | Tinh Hoa rơi từ Sói Chúa: 3 mỗi lần hạ | Mục 5, mục 8 |
| TL-13 | Chỉ luyện được khi đã xây **Đền Thiên Phú** (80 vàng + 60 gỗ, 120 giây) | Mục 7 |
| TL-14 | Cấp 5 và cấp 10 mở hiệu ứng phụ theo nhóm (bảng dưới) | Mục 3: "mỗi 5 cấp mở 1 hiệu ứng phụ" |
| TL-15 | Bảng Thiên phú (phím **T**): thẻ Thiên phú, cấp, hiệu ứng chính, kỹ năng L, hiệu ứng phụ (khoá/mở), chi phí, nút Luyện cấp | — |

Hiệu ứng phụ theo nhóm *(đề xuất — kịch bản không ghi chi tiết)*:

| Nhóm | Cấp 5 | Cấp 10 |
| --- | --- | --- |
| Chiến đấu | +5% chí mạng | +15% sát thương chí mạng |
| Kinh tế | +10% vàng nhặt được | Phân rã +1 Đá Cường Hoá |
| Khai phá | +1 Đuốc tối đa | Đuốc hồi nhanh hơn 20% |
| Chế tạo | Cường hoá rẻ hơn 10% vàng | +5% tỉ lệ cường hoá |
| Lãnh địa | +10% sản lượng | Thu hoạch offline tối đa 16 giờ |
| Triệu hồi | Đồng minh +20% sát thương | +1 đồng minh tối đa |
| Phép thuật | Khắc hệ +10% (30% → 40%) | Kỹ năng L hồi nhanh hơn 20% |
| Điều khiển | Kỹ năng L hồi nhanh hơn 15% | Thời gian hiệu ứng L +1 giây |
| Đặc biệt | Kỹ năng sao chép +20% sát thương | Kỹ năng sao chép hồi nhanh hơn 25% |

### 4.7. Giao diện

| Mã | Yêu cầu |
| --- | --- |
| TL-20 | HUD: ô bình máu (phím Q, số bình + số thảo dược), số đồng minh, hệ đang dùng (Ngũ Hành Linh Căn) |
| TL-21 | Ô kỹ năng L trên HUD hiện tên kỹ năng chủ động và hồi chiêu; Thiên phú không có kỹ năng L thì hiện "bị động" |
| TL-22 | Bản đồ khai phá thêm mục **Công trình**: Đền Thiên Phú, Long Mạch Đàn (nếu có Thiên phú), nâng Thôn; công trình đang xây hiện thời gian còn lại |
| TL-23 | Rương ẩn, thảo dược, đồng minh được vẽ trên bản đồ thế giới; Rương ẩn chỉ hiện khi có Khứu Giác Kho Báu |

### 4.8. Thay đổi save (version 2 → 3)

| Trường | Kiểu | Mặc định khi chuyển từ v2 |
| --- | --- | --- |
| `talent_level` | Cấp Thiên phú 1–10 | `1` |
| `essence` | Số Thiên Phú Tinh Hoa | `0` |
| `tinh_kim` | Số Tinh Kim | `0` |
| `potions`, `herbs` | Bình máu, thảo dược | `2`, `0` |
| `pets` | `[{kind, level}]` | `[]` |
| `copied_skills` | Kỹ năng boss đã sao chép | `[]` |
| `element` | Hệ đòn đánh hiện tại | `"kim"` |
| `buildings` | `{khoá: thời điểm xong theo build_clock}`; khoá: `lumber_<id ô>`, `camp2`, `temple`, `dragon` | Xưởng Gỗ đã có → xong ngay; `camp_level` 2 → `camp2` xong ngay |
| `build_clock` | Đồng hồ xây (giây), chạy cả khi offline | `0` |

### 4.9. Kiểm thử tự động cần có

| # | Nội dung |
| --- | --- |
| TL-A | Tỉ lệ quay 7 hạng đúng (200.000 lần); bảo hiểm vẫn đúng |
| TL-B | **Cân bằng**: bot cấp 5 (12 STR, 8 VIT) đánh Sói Chúa với từng Thiên phú trong 20; tất cả đều thắng. Chênh lệch thời gian giữa nhóm F và nhóm S ≤ 25% (nguyên tắc kịch bản) |
| TL-C | Từng hiệu ứng chính có test riêng: HP +8%, rơi đồ 11%, tốc chạy khi không giao chiến, +10% cường hoá, hồi máu Hấp Huyết và chặn bình máu, Tinh Kim 20%, khắc hệ +30%, thu phục thú cưng dưới 10% HP, lính bóng tối 15%, Thiên Mệnh dọn 3 ô, Long Mạch +10%, Đạo Tặc học Vồ Mồi |
| TL-D | Kỹ năng L của 7 Thiên phú có kỹ năng: dùng được, đúng hồi chiêu |
| TL-E | Rương ẩn mở được khi đi sát; thảo dược → bình máu; phím Q hồi đúng 35% (Nhà Thảo Dược 45,5%) |
| TL-F | Thời gian xây: Xưởng Gỗ chưa xong thì chưa sản xuất; Trái Tim Lãnh Chúa xây nhanh 25%; Hiệu Triệu hoàn thành ngay; đồng hồ xây chạy khi offline |
| TL-G | Luyện cấp: cần Đền; đúng chi phí; cấp 5/10 mở hiệu ứng phụ; cấp 10 là tối đa |
| TL-H | Save v2 chuyển đổi sang v3 (Xưởng Gỗ cũ vẫn sản xuất); lưu/nạp v3 giữ thú cưng, kỹ năng sao chép, công trình |

### 4.10. Điểm cần duyệt

M2 code theo **mặc định**. **Trạng thái: chưa duyệt.**

| # | Câu hỏi | Mặc định | Lý do |
| --- | --- | --- | --- |
| Q6 | Thêm kỹ năng L cho các Thiên phú hạng B và Bầy Đàn Bóng Tối? | Có (mục 4.3) | Bảng độ hiếm yêu cầu B có kỹ năng chủ động, S có kỹ năng tối thượng |
| Q7 | "+5% tỉ lệ rơi đồ" là cộng 5 điểm % hay nhân 1,05? | Cộng 5 điểm (6% → 11%) | Nhân 1,05 gần như không cảm nhận được |
| Q8 | "Trên bản đồ lớn" khi chưa có bản đồ thế giới? | +10% tốc chạy khi không giao chiến | M4 mới có di chuyển giữa các vùng; khi đó đổi lại đúng nghĩa |
| Q9 | Quái có tấn công đồng minh không? | Không | Đơn giản cho MVP; xem lại khi playtest |
| Q10 | "Nguyên liệu hiếm" của Bàn Tay Vàng là gì, dùng để làm gì? | Tinh Kim, cần cho cường hoá +10 trở lên | Kịch bản chưa định nghĩa; cần một chỗ dùng để Thiên phú có giá trị |
| Q11 | Bảng hiệu ứng phụ theo nhóm (mục 4.6) | Như bảng | Kịch bản chỉ ghi "mỗi 5 cấp mở 1 hiệu ứng phụ" |
| Q12 | Thêm thời gian xây công trình (hiện đang xây ngay)? | Có (mục 4.4, TL-S3) | Trái Tim Lãnh Chúa cần thời gian xây mới có ý nghĩa |

### 4.11. Kết quả triển khai M2

Hoàn thành 20/10/2026. Kiểm thử: 10 test tự động mới, 3 test cũ cập nhật theo luật mới (tổng **38/38 qua**), và smoke test có ảnh chụp bảng Thiên phú, mục Công trình, HUD với ô bình máu.

| Mã | Trạng thái | Kiểm chứng |
| --- | --- | --- |
| TL-01, 02 | ✅ | TL-A: 200.000 lần quay, mỗi hạng lệch < 0,5 điểm %; bảo hiểm hạng B vẫn đúng |
| TL-03 | 🟡 | Smoke test |
| 20 Thiên phú (4.3) | ✅ | TL-C (4 test) kiểm từng hiệu ứng chính; TL-D kiểm 7 kỹ năng L |
| TL-S1 Rương ẩn | ✅ | TL-E: Khứu Giác thấy rương trong 30 m, đi sát thì mở được (kể cả không có Thiên phú) |
| TL-S2 Thảo dược, bình máu | ✅ | TL-E: hái ×1/×2, bình hồi 35% / 45,5%; Hấp Huyết bị chặn |
| TL-S3 Thời gian xây | ✅ | TL-F: 60 → 45 giây với Trái Tim Lãnh Chúa, đồng hồ xây chạy khi offline |
| TL-S4 Đồng minh | ✅ | TL-C: thu phục dưới 10% HP; lính bóng tối 15%; TL-H: thú cưng còn sau khi nạp lại |
| TL-S5 Tinh Kim | ✅ | TL-C: Bàn Tay Vàng 20%; TL-G: boss rơi 1 Tinh Kim |
| TL-S6 Ngũ hành | ✅ | TL-C: Kim khắc Mộc +30%, không khắc Thổ |
| TL-S7 Long Mạch Đàn | ✅ | TL-C: +10% tấn công khi xây xong; Thiên phú khác không xây được |
| TL-10…14 Luyện cấp | ✅ | TL-G: cần Đền, tổng 25 Tinh Hoa, cấp 10 +18% tấn công, hiệu ứng phụ mở ở cấp 5 |
| TL-15, 20…23 Giao diện | 🟡 | Smoke test, ảnh `05d-talent`, `05e-map-buildings`, `03-combat`, `06-boss` |
| Save v3 (4.8) | ✅ | TL-H: save v2 chuyển đổi được, Xưởng Gỗ cũ vẫn sản xuất |

**Cân bằng — nguyên tắc "F và S chênh không quá 25%"** (TL-B, bot cấp 5, 12 STR / 8 VIT, cùng seed):

| Hạng | Thời gian hạ Sói Chúa |
| --- | --- |
| F (4 Thiên phú) | 43–45 giây, trung bình 44,2 |
| C (3) | 43–45 giây |
| B (3) | Kiếm Tâm 32 · Nhà Thảo Dược 46 · Trái Tim Lãnh Chúa 45 |
| A (4) | 42–45 giây |
| S (3) | Ngũ Hành Linh Căn 42 · Thời Gian Ngưng Đọng 44 · Bầy Đàn Bóng Tối 38; trung bình 41,3 |
| SS, SSS (3) | 45 giây |

F và S chênh **7%**, đạt nguyên tắc. Không Thiên phú nào chết lần nào. Hạng cao không mạnh hơn hẳn về sát thương; khác biệt nằm ở cơ chế (khai phá, lãnh địa, triệu hồi), đúng ý kịch bản.

**Phát hiện cần đưa vào playtest:**

| # | Phát hiện | Đề xuất |
| --- | --- | --- |
| F4 | Kiếm Tâm nhanh hơn trung bình khoảng 28% nhờ Nhất Kiếm Đoạn (hồi 15 giây) | Theo dõi khi playtest; nếu quá mạnh, tăng hồi chiêu lên 20 giây |
| F5 | 3 Thiên phú SS/SSS không giúp gì trong trận boss (Thiên Mệnh, Long Mạch chưa xây, Đạo Tặc chưa sao chép) | Đúng thiết kế ("hiệu ứng lên bản đồ / lãnh địa"), nhưng người quay trúng hạng hiếm có thể thất vọng ở chương 1. Hỏi cảm nhận khi playtest |
| F6 | Bot chỉ bấm L liên tục, không dùng bình máu, không xây Long Mạch | Số liệu cân bằng là cận dưới; người chơi thật dùng Thiên phú khéo hơn |

## 5. Đợt M3 — Lớp Thợ Săn, 4 kỹ năng mỗi lớp, cân bằng theo công thức mới

### 5.1. Mục tiêu

Kịch bản mục 4–5: có **Kiếm Khách** (cận chiến, STR) và **Thợ Săn** (đánh xa, cơ động, AGI), chọn lớp khi tạo nhân vật; combat đủ *"đánh thường + 4 kỹ năng + 1 kỹ năng Thiên phú + né lăn"*. Đồng thời áp các quyết định đã chốt Q17, Q22, Q23 (tài liệu 04 mục 13.1) để chỉ cân bằng một lần.

**Ngoài phạm vi M3:** Pháp Sư, Hộ Vệ, chuyển chức; kháng hệ (M4); Tự đánh (M5); boss hiếm (M5); vũng độc của Nấm Độc, Lao sương của Tinh Linh Sương (M4 khi làm lại vùng 1 theo 3 map con).

### 5.2. Lớp nhân vật

| Mã | Yêu cầu | Tiêu chí nghiệm thu |
| --- | --- | --- |
| CL-01 | Sau Lễ Thức Tỉnh hiện màn hình **Chọn lớp**: Kiếm Khách / Thợ Săn, mỗi lớp có mô tả, chỉ số chính, 4 kỹ năng | Smoke test chụp `02b-class` |
| CL-02 | Lớp lưu trong save (`class_id`). Save cũ (v3) → Kiếm Khách | TL-H, CL-T5 |
| CL-03 | Không đổi lớp giữa chừng (chỉ khi bắt đầu hành trình mới) | — |
| CL-04 | Hình nhân vật theo lớp (`hero-kiem-khach`, `hero-tho-san`) | Smoke test |
| CL-05 | Vũ khí dùng chung ô Vũ khí; món sinh ra khi đang là Thợ Săn tên là **Cung**, Kiếm Khách tên **Kiếm** (chỉ số như nhau) | CL-T2 |

**Chỉ số theo lớp:**

| | Kiếm Khách | Thợ Săn |
| --- | --- | --- |
| Tấn công | 10 + 2/cấp + **2/STR** | 10 + 2/cấp + **2/AGI** + 1/STR |
| HP | 100 + 15/cấp + 12/VIT | **90** + 13/cấp + 12/VIT |
| Né tránh gốc | 0% | **5%** |
| Đánh thường | Chém vòng cung 8 m, 60°, 0,5 giây/đòn, trúng mọi quái trong cung | **Bắn tên** 45 m, 0,6 giây/đòn, trúng quái đầu tiên trên đường bay (tên bay 70 m/s) |

### 5.3. Chỉ số mới

| Mã | Chỉ số | Công thức | Nguồn |
| --- | --- | --- | --- |
| ST-01 | **INT** (Trí tuệ), cộng điểm được | +6 MP tối đa, +0,05 MP/giây, +0,5% sát thương kỹ năng (1–4) mỗi điểm | Kịch bản mục 4; CR-01 cần INT |
| ST-02 | **LUK** (May mắn), cộng điểm được | +0,3% chí mạng, +0,2 điểm % tỉ lệ rơi đồ của quái thường (tối đa +10) mỗi điểm | Kịch bản mục 4 (chưa nói tác dụng) |
| ST-03 | **MP** | Tối đa `50 + 5/cấp + 6/INT`; hồi `3 + 0,05/INT` mỗi giây; đầy lại khi lên cấp, hồi sinh | Kịch bản mục 4 |
| ST-04 | **Né tránh** | `gốc lớp + 0,3%/AGI`, tối đa 30%. Mỗi đòn của quái (cả đạn, Vồ) có tỉ lệ này bị né: hiện "Né!", không mất máu, không mất combo | Kịch bản mục 4 |
| ST-05 | Tẩy điểm (trước cấp 30) trả lại cả INT, LUK | — | NV-13 |

### 5.4. Kỹ năng (phím 1–4)

Phím **1–4** dùng kỹ năng; **K / chuột phải** vẫn là kỹ năng 1 (giữ thói quen cũ). Mỗi kỹ năng có hồi chiêu và tốn MP; thiếu MP thì không dùng được (hiện "Thiếu MP"). Sát thương kỹ năng nhân thêm thưởng INT (ST-01).

**Kiếm Khách**

| # | Kỹ năng | Hiệu ứng | Hồi | MP |
| --- | --- | --- | --- | --- |
| 1 | **Xoáy Kiếm** (đã có) | Chém vòng quanh 12,5 m, ×1,8 | 6 giây (bộ Thợ Săn Sương 6 món: 4) | 15 |
| 2 | **Đột Kích** | Lao 18 m theo hướng ngắm trong 0,2 giây, chém mọi quái trên đường ×1,5; bất tử khi lao | 8 giây | 20 |
| 3 | **Kiếm Khí** | Phóng luồng kiếm khí bay thẳng 40 m, **xuyên** mọi quái, ×2,0 | 5 giây | 15 |
| 4 | **Thiết Bích** | 4 giây giảm 50% sát thương nhận vào, đòn đánh +50% sát thương vào thanh Phá Thế | 20 giây | 25 |

**Thợ Săn**

| # | Kỹ năng | Hiệu ứng | Hồi | MP |
| --- | --- | --- | --- | --- |
| 1 | **Mưa Tên** | Vùng 9 m tại điểm ngắm (tầm tối đa 40 m): 5 đợt trong 1,5 giây, mỗi đợt ×0,6 (tổng ×3,0) | 8 giây | 25 |
| 2 | **Tên Xuyên Phá** | 1 mũi tên xuyên mọi quái, 60 m, ×2,5 | 6 giây | 15 |
| 3 | **Bẫy Gai** | Đặt bẫy tại chỗ (tối đa 2, tồn tại 20 giây). Quái chạm vào: nổ vòng 6 m ×2,0 và trói 2 giây | 10 giây | 20 |
| 4 | **Ưng Nhãn** | 6 giây: +30% tốc đánh, +15% chí mạng | 25 giây | 30 |

**Thiên phú với 2 lớp** (05 mục 5): Kiếm Tâm, Nanh Sói Chúa tính theo **đòn đánh thường** (chém hoặc bắn). Ngũ Hành Bộc Phá kích hoạt bằng **kỹ năng 1** (Xoáy Kiếm / Mưa Tên). Hấp Huyết, Huyết Chiến áp dụng mọi đòn.

### 5.5. Chiến đấu

| Mã | Yêu cầu | Tiêu chí |
| --- | --- | --- |
| CB-04 | **Né Hoàn hảo**: một đòn của quái bị chặn trong **0,15 giây đầu** của né lăn → hiện "Hoàn hảo!", quái và đạn chậm còn 30% tốc độ trong **1 giây** (người chơi không chậm). Mỗi lần né chỉ kích hoạt 1 lần | CB-T3 |
| CB-07 | **Phá Thế cho quái tinh anh**: thanh = 30% HP tối đa; phá → choáng **3 giây**, nhận +50% sát thương; hồi đầy khi hết choáng. Thanh Phá Thế hiện dưới thanh máu | CB-T4 |
| CB-12 | **Kỹ năng riêng của tinh anh** (06 vùng 1): **Sói Đầu Đàn** — *Hú gọi* (hồi 15 giây, khi đang đuổi): gọi 2 Sói Sương cùng cấp; cả bầy +20% tốc chạy 6 giây. **Nấm Mẹ** — *Sinh sôi* (mỗi 8 giây khi đang đuổi): đẻ 2 Nấm Con lao tới, tự nổ sau 3 giây hoặc khi chạm người chơi (vòng 3 m, ×1,5, báo hiệu 0,5 giây) | CB-T5 |
| CB-13 | Quái tinh anh vùng 1 chỉ còn 2 loại: Sói Sương tinh anh = **Sói Đầu Đàn** (từ cấp 3), Nấm Độc tinh anh = **Nấm Mẹ** (từ cấp 5); thủ lĩnh Ổ quái chọn trong 2 loại này | CB-T5 |
| MC-01 | Quái mới **Mộc Tinh** (06): loại Giáp, hệ Mộc, cấp 6 trở lên; *Dậm đất*: báo hiệu 1,0 giây, vòng 6 m quanh nó, ×1,4 | CB-T6 |

### 5.6. Chỉ số quái theo công thức (Q22, Q23)

| Mã | Yêu cầu |
| --- | --- |
| CB-21 | Chỉ số quái tính bằng `Formulas.mob_stats(cấp, bậc, loại)` — **đúng công thức tài liệu 06 mục 1** (cùng cách tính với `tools/gen_world_doc.py`). Bỏ bảng nhân theo cấp cũ. Bậc: quái thường, quái Ổ quái → *thường*; tinh anh, thủ lĩnh Ổ → *tinh anh*; Sói Chúa → *boss* (tính với người chơi chuẩn cấp 5) |
| CB-22 | Boss chương 1 = **90 đòn**; Phá Thế = HP/6; EXP boss = 0,3 × EXP lên cấp 6 |
| — | Loại quái: Sói Sương *Nhanh*, Nấm Độc *Xa*, Tinh Linh Sương *Phép*, Mộc Tinh *Giáp*, Sói Đầu Đàn *Nhanh*, Nấm Mẹ *Lì*, Nấm Con *Bầy* (ATK ×2,5 khi nổ như *Tự nổ*) |
| — | Test so khớp: Sói Sương cấp 1 = 18 HP, cấp 7 = 188 HP / 36 ATK; Sói Chúa = 4.023 HP / 43 ATK / 24 DEF (bảng 06) |

Công thức giả định **người chơi chuẩn mặc đồ đúng vùng** (06 mục 1.1). Bot trong test cân bằng vì vậy được mặc đồ (`_gear_up`), như người chơi thật ở phút thứ 20.

### 5.7. Thiên phú (Q17, TP-30, TP-40)

| Mã | Yêu cầu |
| --- | --- |
| TP-41 | **Hiệu ứng chính mạnh dần theo Lv**: mỗi giá trị trong bảng 05 mục 2.1 nội suy tuyến tính từ Lv1 tới Lv10 (`Talents.lv_value(v1, v10, lv)`). Bảng Thiên phú hiện giá trị ở cấp hiện tại và cấp kế tiếp |
| TP-30 | Thuần Thú Sư thu phục được cả **quái Ổ quái** (không gồm thủ lĩnh); ngưỡng 10% → 15% HP theo Lv; thú cưng +0% → +50% tấn công theo Lv |
| TP-40 | **Đạo Tặc — Cướp Thuộc Tính** đúng CR-01.1 (DT-01…08) với mặc định Q13–Q16: hạ quái có tỉ lệ cướp (thường 3%, tinh anh 30%, thủ lĩnh Ổ 100%, boss 100% × 3 điểm), loại thuộc tính theo bảng đặc trưng của quái (06), giới hạn cấp Thiên phú × cấp (Q169), điểm đã cướp giữ vĩnh viễn (đầy thì vào Túi Tang Vật / Đà Cướp — DT-17/18; trần theo loài — DT-19); quái thấp hơn quá 5 cấp không cướp được (boss luôn được); tỉ lệ ×1,0 → ×1,5 theo Lv. Điểm cướp cộng thẳng vào chỉ số, không bị tẩy điểm, hiện riêng trong bảng Chỉ số; thông báo *"Cướp +1 AGI từ Sói Sương (12/15)"* |

### 5.8. Giao diện

| Mã | Yêu cầu |
| --- | --- |
| UI-01 | HUD: thanh MP dưới thanh HP; thanh kỹ năng 8 ô: Đánh thường · 1 · 2 · 3 · 4 · Né · L · Q, mỗi ô có icon, hồi chiêu; ô thiếu MP: viền + icon xanh (không thêm chữ). *Cập nhật DH-11:* ô tròn viền vàng trong khung "Kỹ năng", phím ở góc ô, tên + MP dưới icon, hồi chiêu quét tròn kèm số giây |
| UI-02 | Nhật ký dời lên trên thanh kỹ năng để không đè ở 1366 × 768 |
| UI-03 | Bảng Chỉ số: 5 chỉ số gốc (STR, AGI, INT, VIT, LUK) + phần cướp được (Đạo Tặc), MP, Né tránh; mô tả tác dụng theo lớp |
| UI-04 | Màn hình tiêu đề, phím điều khiển cập nhật phím 1–4 |
| UI-05 | Vẽ: tên bay (Thợ Săn), kiếm khí, mưa tên, bẫy, khiên Thiết Bích, thanh Phá Thế tinh anh, vòng báo hiệu Dậm đất / Nấm Con nổ |
| UI-06 | Hình mới (skill `game-art`): 8 icon kỹ năng, mũi tên, kiếm khí, bẫy, Nấm Con |

### 5.9. Thay đổi save (version 3 → 4)

| Trường | Kiểu | Mặc định khi chuyển từ v3 |
| --- | --- | --- |
| `class_id` | `"kiem-khach"` \| `"tho-san"` | `"kiem-khach"` |
| `points` | thêm `int`, `luk` | `0`, `0` |
| `stolen` | Điểm Đạo Tặc cướp được, theo thứ tự cũ → mới, ví dụ `["agi", "str"]` | `[]` |

### 5.10. Kiểm thử tự động cần có

| # | Nội dung |
| --- | --- |
| CL-T1 | Chỉ số theo lớp: Thợ Săn lấy Tấn công từ AGI, HP thấp hơn, né gốc 5%; INT tăng MP, LUK tăng chí mạng |
| CL-T2 | Thợ Săn bắn tên trúng quái ở 30 m, không trúng quái sau lưng quái đầu tiên; vũ khí rơi tên "Cung" |
| CL-T3 | 8 kỹ năng: dùng được, đúng hồi chiêu, trừ MP, thiếu MP thì bị từ chối; Kiếm Khí/Tên Xuyên Phá xuyên quái; Bẫy trói; Thiết Bích giảm 50% |
| CL-T4 | Né tránh: AGI 100 → 30% (trần), mô phỏng 2.000 đòn lệch < 3 điểm % |
| CL-T5 | Save v3 → v4: lớp Kiếm Khách, INT/LUK = 0; lưu/nạp v4 giữ lớp, điểm cướp |
| CB-T1 | Chỉ số quái khớp bảng 06 (Sói Sương cấp 1/7, Sói Chúa) |
| CB-T3 | Né Hoàn hảo: chặn đòn trong 0,15 giây đầu → làm chậm 1 giây; né muộn thì không |
| CB-T4 | Phá Thế tinh anh: đủ sát thương → choáng 3 giây, +50% sát thương |
| CB-T5 | Sói Đầu Đàn gọi 2 sói; Nấm Mẹ đẻ Nấm Con, Nấm Con nổ |
| CB-T6 | Mộc Tinh xuất hiện từ cấp 6, Dậm đất trúng người đứng trong 6 m |
| TP-T1 | Hiệu ứng theo Lv: Thân Thể Lv10 = +12% HP; Ngưng Đọng Lv10 = 4,5 giây |
| TP-T2 | Thuần Thú thu phục quái Ổ quái |
| TP-T3 | Đạo Tặc: boss cho 3 điểm; Thiên phú Lv1 giới hạn 1 × cấp, đầy thì giữ nguyên điểm cũ, lên cấp thì cướp tiếp; quái thấp hơn 6 cấp không cướp được; điểm cướp không bị tẩy |
| DT-T2 | Đạo Tặc: giới hạn = cấp Thiên phú × cấp; đầy → Túi Tang Vật, lên cấp tự cộng; loài hết / túi đầy → Đà Cướp +3%, tối đa 5 tầng, hết 30 giây thì mất; boss lúc đầy không mất trắng; Sổ ghi 5/5; save v20; bảng Thiên phú hiện đủ 4 dòng |
| TL-B | **Cân bằng** chạy cho **2 lớp × 20 Thiên phú**: tất cả hạ được Sói Chúa; F và S chênh ≤ 25% trong từng lớp; 2 lớp chênh nhau ≤ 25% |

### 5.11. Điểm cần duyệt

M3 code theo **mặc định** dưới đây. **Trạng thái: chưa duyệt** (đã code theo mặc định).

| # | Câu hỏi | Mặc định | Lý do |
| --- | --- | --- | --- |
| Q28 | Tên và hiệu ứng 8 kỹ năng (mục 5.4) | Như bảng | Kịch bản không có danh sách kỹ năng; thiết kế theo vai trò lớp (cận chiến cân bằng / xa cơ động) và hướng chuyển chức (Huyết Kiếm, Thợ Bẫy) |
| Q29 | Phím kỹ năng | 1–4; K/chuột phải = kỹ năng 1 | Phím số là chuẩn ARPG PC; giữ K cho người đã quen |
| Q30 | Tác dụng INT, LUK cho 2 lớp hiện có | Mục 5.3 | INT có ích cho mọi lớp qua MP và sát thương kỹ năng; LUK cho người cày đồ |
| Q31 | Né tránh 0,3%/AGI, trần 30%, Thợ Săn gốc 5% | Như vậy | Trần 30% để boss vẫn nguy hiểm |
| Q32 | MP: 50 + 5/cấp, hồi 3/giây | Như vậy | Đủ dùng xoay vòng 4 kỹ năng ở chương 1, thiếu nếu bấm liên tục |
| Q33 | Tinh anh vùng 1 chỉ còn Sói Đầu Đàn, Nấm Mẹ (thay "… Tinh Anh") | Có | Đúng tài liệu 06 (2 loại tinh anh mỗi map, kịch bản mục 5) |
| Q34 | Không đổi lớp giữa chừng | Không đổi được | Đổi lớp sẽ đi cùng chuyển chức (Alpha) |

### 5.12. Kết quả triển khai M3

Hoàn thành 20/10/2026. Kiểm thử: **13 test tự động mới** (CL-T1…T5, CB-T1, CB-T3…T6, TP-T1…T3), TL-B mở rộng cho 2 lớp, 2 test boss cũ cập nhật theo luật mới. Tổng **52/52 qua**, không có `SCRIPT ERROR`. Smoke test chụp thêm `02b-class` (chọn lớp) và `03b-hunter` (Thợ Săn đánh, có bẫy và tên bay).

| Mã | Trạng thái | Kiểm chứng |
| --- | --- | --- |
| CL-01…05 Lớp nhân vật | ✅ | CL-T1, CL-T2, CL-T5; smoke `02b-class`, `03b-hunter` |
| ST-01…05 INT, LUK, MP, né tránh, tẩy điểm | ✅ | CL-T1, CL-T4 (né 29,9% với AGI 100, mục tiêu 30%) |
| 8 kỹ năng (5.4) | ✅ | CL-T3: hồi chiêu, MP, xuyên quái, bẫy trói, Thiết Bích giảm đúng 50% |
| CB-04 Né Hoàn hảo | ✅ | CB-T3 |
| CB-07 Phá Thế tinh anh | ✅ | CB-T4 |
| CB-12, CB-13 Tinh anh Sói Đầu Đàn, Nấm Mẹ, Nấm Con | ✅ | CB-T5 |
| MC-01 Mộc Tinh | ✅ | CB-T6 |
| CB-21, CB-22 Công thức chỉ số quái, boss 90 đòn | ✅ | CB-T1: Sói Sương cấp 1 = 18 HP, cấp 7 = 188 HP / 36 ATK, Sói Chúa = 4.023 / 43 / 24, EXP 1.545 — đúng bảng 06 |
| TP-41 Thiên phú mạnh dần theo cấp | ✅ | TP-T1; bảng Thiên phú hiện giá trị cấp này → cấp sau |
| TP-30 Thuần Thú thu phục quái Ổ quái | ✅ | TP-T2 |
| TP-40 Đạo Tặc cướp thuộc tính | ✅ | TP-T3: boss 3 điểm, giới hạn (Lv1) 1 × cấp, quái thấp hơn 6 cấp không cướp, tẩy điểm không mất · DT-T2: giới hạn × cấp Thiên phú, Túi, Đà Cướp, Sổ |
| UI-01…06 | ✅ | Smoke test: HUD 8 ô + thanh MP, nhật ký trên thanh kỹ năng, bảng Chỉ số 5 chỉ số, icon kỹ năng (skill `game-art`) |
| Save v4 (5.9) | ✅ | CL-T5 |

**Bổ sung trong lúc làm (ngoài spec ban đầu):**

| Mã | Yêu cầu | Lý do |
| --- | --- | --- |
| CB-23 | **Khoá hang boss**: Sói Chúa đã xuất hiện thì người chơi không ra khỏi hang tới khi boss chết hoặc người chơi gục | Bot Thợ Săn phát hiện có thể đứng **ngoài hang** bắn vào, trong khi boss bị giữ trong hang nên không với tới → thắng không mất máu. Phòng boss đóng cửa là cách làm chuẩn của ARPG |
| — | Test chạy một phần: `-- --only=<tên>` | Cân bằng nhanh (TL-B chạy riêng khoảng 13 giây) |

**Cân bằng — TL-B, bot cấp 5 mặc bộ đồ chuẩn (vũ khí Xanh dương, áo + mũ Xanh lá), dùng cả 4 kỹ năng:**

| Lớp | F (trung bình) | S (trung bình) | Chênh F/S | Trung bình 20 Thiên phú | Chết |
| --- | --- | --- | --- | --- | --- |
| Kiếm Khách | 29,8 giây | 27,6 giây | 7% | 29,3 giây | 0 |
| Thợ Săn | 31,0 giây | 27,9 giây | 10% | 30,5 giây | 0 |

2 lớp chênh **4%**. Bot không mặc đồ thì chết 24 lần và không hạ được boss trong 10 phút — đúng giả định của công thức (người chơi chuẩn mặc đồ đúng vùng). Người chơi thật ở phút 20–25 thường có 3 món (M1-12: Lực chiến 1.303 → 30 giây).

**Phát hiện cần đưa vào playtest:**

| # | Phát hiện | Đề xuất |
| --- | --- | --- |
| F7 | Boss khoảng 30 giây, nhanh hơn mục tiêu Q23 (35–40 giây) vì bot dùng đủ 4 kỹ năng và thường xuyên phá Phá Thế | Giữ ở M3; nếu playtest thấy dễ, tăng số đòn boss chương 1 từ 90 lên 110 (1 dòng trong `Formulas.boss_hits`) |
| F8 | Người chơi **không mặc đồ** gần như không thể thắng boss ở cấp 5 | Hướng dẫn (M5) phải nhắc mặc đồ; xem xét cho Trưởng làng tặng 1 vũ khí Xanh lá |
| F9 | Kiếm Tâm vẫn nhanh nhất (22–26 giây, khoảng 20% nhanh hơn trung bình) | Như F4: theo dõi playtest |
| F10 | Quái cấp 1–2 yếu hơn trước (Sói Sương 40 → 18 HP) nên 5 phút đầu nhanh hơn | Đúng ý đồ "30 phút đầu trơn tru"; đo lại nhịp lên cấp khi playtest (NV-20) |

## 6. Đợt M4 — Chương 2: Đồng Bằng Gió Hú, Thành Biên Đài

### 6.1. Mục tiêu

Kịch bản mục 2 (chương 2: *"Gia nhập Liên minh, nhận lãnh địa đầu tiên — Phát hiện gián điệp Hư Vô Giáo trong thành"*), mục 6 (vùng 2, gió đổi hướng đẩy lùi, quy tắc vượt map), mục 7 (lưới 40–60 ô, núi → mỏ, sông → bến cá). Nội dung quái/boss theo [06](06-ban-do-quai-boss.md) vùng 2.

Phạm vi lớn nên chia **3 đợt con**, mỗi đợt có test và commit riêng:

| Đợt con | Nội dung | Hạng mục 04 |
| --- | --- | --- |
| **M4.1** Nhiều bản đồ | Kiến trúc bản đồ dữ liệu hoá; **bản đồ lục địa**, di chuyển giữa map, điểm dịch chuyển; **Lõi Sương** (map 1-3); thử thách vượt ải; cảnh kết chương 1 | BD-06, BD-07, BD-08, BD-09, TN-09, TP-23 |
| **M4.2** Vùng 2 chiến đấu | 3 map vùng 2 (Cửa Gió, Thảo Nguyên Hú, Mắt Bão); **gió**; 4 quái thường + 2 tinh anh; **boss Tướng Gián Điệp Huyền Ảnh**; kháng hệ; phạt EXP quái thấp cấp; bộ Phong Hành, Mặt Nạ Huyền Ảnh; Đạo Tặc học Phân Thân | BD-02, CB-10, CB-18, NV-17, NV-25, TB-04, TP-39 |
| **M4.3** Thành và lãnh địa vùng 2 | **Thành Biên Đài** (NPC, thoại, nhiệm vụ chính chương 2, gián điệp Hư Vô Giáo); lưới khai phá vùng 2 **45 ô** theo tỉ lệ kịch bản; Mỏ, Bến Cá, Đá, Sắt; Khứu Giác Di tích; EXP offline; bộ cộng hưởng Thiên phú | CT-04, CT-07, CT-10, KP-01, KP-06, KP-11, TB-05, TB-11, TP-26, NV-24 |

**Ngoài phạm vi M4:** boss hiếm Bạch Hổ (M5), cửa hàng mua bán (M5), Xưởng Rèn (M5), vùng 3 (Alpha).

### 6.2. M4.1 — Nhiều bản đồ

**Bản đồ** (`scripts/data/maps.gd`): mỗi map là dữ liệu — kích thước, cấp quái theo vị trí, vùng an toàn (làng/thành/trạm), hang boss (nếu có), tường sương mù, bảng quái, môi trường, nền đất.

| Map | Vùng | Cấp | Nội dung | Mở khi |
| --- | --- | --- | --- | --- |
| 1-1 Rừng Sương (gộp Bìa Rừng + Rừng Sâu) | 1 | 1–6 | Làng Thanh Thạch, Hang Sói Chúa — **map hiện có, giữ nguyên** | Bắt đầu |
| 1-3 Lõi Sương | 1 | 7–10 | Trạm Gác (an toàn), Tinh Linh Sương, Mộc Tinh, Sói Sương cấp 7+, tinh anh; sương dày hơn | Hạ Sói Chúa |
| 2-1 Cửa Gió | 2 | 10–13 | Thành Biên Đài (an toàn) ở rìa tây | Cấp 10 + hạ Sói Chúa + khai phá vùng 1 ≥ 60% (kịch bản mục 6, 3 điều kiện) |
| 2-2 Thảo Nguyên Hú | 2 | 13–17 | | Đã tới Cửa Gió |
| 2-3 Mắt Bão | 2 | 17–20 | Gió đổi mỗi 8 giây; dungeon **Phủ Huyền Ảnh** (boss cấp 18) | Đã tới Thảo Nguyên Hú |

| Mã | Yêu cầu | Tiêu chí |
| --- | --- | --- |
| MP-01 | `GameWorld` chạy trên 1 map (`map_id`); mọi vị trí (làng, hang, tường) đọc từ dữ liệu map. Map 1-1 giữ đúng toạ độ cũ (test cũ không đổi) | Test cũ qua |
| MP-02 | **Bản đồ lục địa** (phím **N**): 9 vùng, vùng đã mở sáng lên, vùng chưa mở ghi điều kiện; trong vùng liệt kê map con + trạng thái + nút **Lên đường** | Smoke `08-world-map` |
| MP-03 | Di chuyển giữa map: chỉ khi **không giao chiến** (3 giây) và không có boss; mất **4 giây đi đường** (màn hình chờ); Chân Không Biết Mỏi giảm 10% → 15% (TP-23) | MP-T1 |
| MP-04 | **Điểm dịch chuyển** (BD-08): vào map lần đầu thì mở điểm dịch chuyển ở vùng an toàn của map đó; lên đường tới map đã mở đến thẳng vùng an toàn | MP-T1 |
| MP-05 | **Thử thách vượt ải** (BD-09): được vào map có cấp tối thiểu cao hơn cấp nhân vật tối đa 5 cấp, có cảnh báo; hạ quái **cao hơn mình từ 5 cấp** được **EXP ×2** | MP-T2 |
| MP-06 | Cảnh kết chương 1 (TN-09): bấm "Tiếp tục khám phá" ở màn hình chiến thắng → mở bản đồ lục địa, vùng 2 sáng lên kèm dòng *"Phía đông, Đồng Bằng Gió Hú đang chờ…"* | Smoke |
| MP-07 | Mỗi map tự sinh quái theo bảng của map; hồi sinh tại vùng an toàn của map đang đứng | MP-T1 |
| MP-08 | Save lưu `map_id`, các map đã mở (`unlocked_maps`); vào game tiếp tục ở map cũ | MP-T3 |

### 6.3. M4.2 — Vùng 2 chiến đấu

**Gió** (BD-02, 06 vùng 2):

| Mã | Yêu cầu |
| --- | --- |
| GI-01 | Gió có 8 hướng, đổi mỗi **12 giây** (Mắt Bão **8 giây**), báo trước **2 giây** bằng mũi tên trên HUD |
| GI-02 | Gió đẩy người chơi **6 m/giây**; chạy ngược gió −30% tốc chạy, xuôi gió +20% |
| GI-03 | Đạn, mũi tên (của người chơi và quái) lệch tối đa **15°** về hướng gió khi bắn |
| GI-04 | Né lăn và Đột Kích không bị gió đẩy |

**Quái vùng 2** (chỉ số bằng công thức 06; hình mới bằng skill `game-art`):

| Quái | Loại · Hệ | Đòn/kỹ năng trong game |
| --- | --- | --- |
| Ưng Gió | Nhanh · Kim | **Bổ nhào**: bay lên 0,6 giây (vòng báo hiệu tại chỗ người chơi) rồi lao tới, vòng 3 m ×1,3 |
| Lính Đánh Thuê Hư Vô | Giáp · Kim | **Khiên chặn**: giảm 70% sát thương đến từ phía trước (±60° hướng nó nhìn); nó **không quay người** khi đang vung đòn — đánh từ bên/sau. **Đâm** ×1,2 |
| Cung Thủ Thảo Nguyên | Xa · Mộc | **Bắn ba mũi**: nón 30°, mỗi mũi ×0,7 |
| Lốc Xoáy Con | Phép · Kim | **Hút**: 2 giây kéo người chơi trong 8 m về phía nó 3 m/giây, rồi nổ vòng 4 m ×1,5 |
| *Đội Trưởng Đánh Thuê* (tinh anh của Lính Đánh Thuê) | Giáp · Kim | Khiên chặn + **Chém xoáy** (hồi 10 giây): 3 vòng chém 5 m, mỗi vòng ×1,6, cách nhau 0,5 giây |
| *Phù Thuỷ Gió* (tinh anh của Lốc Xoáy) | Phép · Kim | **Nghịch Phong** (hồi 14 giây): đổi hướng gió ngay, gió mạnh ×2 trong 6 giây |

**Boss chương 2 — Tướng Gián Điệp Huyền Ảnh** (cấp 18, kịch bản: *"Phân thân 3 bản, chỉ bản thật có bóng"*):

| Giai đoạn | Kỹ năng |
| --- | --- |
| 1 (100% → 60%) | **Ám tiễn**: 3 phi tiêu nón 40°, mỗi phi tiêu ×0,8 · **Thoắt ẩn** (hồi 6 giây): dịch chuyển ra sau lưng người chơi, vung 0,4 giây, ×1,5 |
| 2 (60% → 25%) | **Phân thân**: 2 bản sao (mỗi bản 8% HP boss, đánh ×0,5, **không có bóng**). Đánh chết bản sao: nó nổ vòng 4 m ×0,8 |
| 3 (dưới 25%) | **Vạn Ảnh**: 4 bản sao; boss và bản sao **đổi chỗ cho nhau mỗi 6 giây** |

Rơi: 1 đồ Tím, 15% **Mặt Nạ Huyền Ảnh**, 3 Tinh Hoa, 1 Tinh Kim. Thanh Phá Thế = HP/6. Hang khoá như Sói Chúa (CB-23). Hạ lần đầu → màn hình **"Chương 2 hoàn thành"**.

| Mã | Yêu cầu |
| --- | --- |
| NV-17 | **Kháng 5 hệ**: 5 affix mới *Kháng Kim/Mộc/Thủy/Hỏa/Thổ* (`3% + 0,2%/cấp`), giảm % sát thương nhận từ quái hệ đó, tối đa 50%. Mọi quái đánh mang hệ của nó |
| NV-25 | Quái thấp hơn người chơi **từ 10 cấp** chỉ cho **10% EXP** (kịch bản mục 4) |
| TB-04 | **Bộ Phong Hành** (vùng 2): 2 món +8% tốc chạy · 4 món +8% tốc đánh · 6 món né lăn hồi 3 → 2 giây. Đồ Tím vùng 2 có 25% thuộc bộ này |
| TB-04 | **Mặt Nạ Huyền Ảnh** (mũ Cam): né lăn để lại 1 **phân thân hút đòn** 2 giây |
| TP-39 | **Đạo Tặc** hạ Huyền Ảnh → học **Phân Thân**: tạo 2 ảo ảnh hút đòn 6 giây. Có ≥ 2 kỹ năng sao chép thì chọn kỹ năng dùng bằng phím L trong bảng Thiên phú |
| — | **Ảo ảnh hút đòn**: quái trong 30 m đổi mục tiêu sang ảo ảnh gần nhất cho tới khi ảo ảnh hết giờ |
| — | Rơi đồ theo vùng: đồ Tím vùng 1 → Bộ Thợ Săn Sương, vùng 2 → Bộ Phong Hành |

### 6.4. M4.3 — Thành Biên Đài và lãnh địa vùng 2

| Mã | Yêu cầu |
| --- | --- |
| CT-10 | **Thành Biên Đài**: vùng an toàn lớn ở rìa tây Cửa Gió; tường thành, nhà đá; quái không vào. 3 NPC đứng yên, đến gần bấm **E** để nói chuyện: **Đội trưởng Liên minh Lạc Phong** (nhiệm vụ chính), **Thợ rèn Thiết Ngưu** (đổi nguyên liệu), **Thương nhân Mạc Tam** (về sau lộ là gián điệp) |
| CT-04 | **Liên minh Khai Giới**: nhiệm vụ chính chương 2 (bảng dưới) và **hạng Khai Giới Giả** Đồng → Bạc → Vàng theo số ô đất chiếm được ở vùng 2 (0 / 10 / 25), hiện trong thoại và HUD |
| CT-07 | **Gián điệp Hư Vô Giáo**: bước 4 của nhiệm vụ — nói chuyện với Mạc Tam sau khi chiếm 6 ô → Mạc Tam lộ mặt, bỏ chạy về Phủ Huyền Ảnh; Thương nhân biến khỏi thành |
| KP-01 | **Lưới khai phá riêng cho vùng 2: 45 ô** (vòng 1–3 = 36 ô + 9 ô vòng 4), trung tâm là Thành Biên Đài (đã chiếm sẵn). Bản đồ khai phá (M) hiện lưới của vùng đang đứng |
| KP-11 | Sự kiện ô vùng 2 theo **tỉ lệ kịch bản**: Tài nguyên 35 · Ổ quái 25 · Di tích 12 · Người sống sót 10 · Thương nhân 8 · Cổng dungeon 7 · Kỳ quan 3. Thương nhân và Cổng dungeon **chưa có ở MVP** → tạm tính là Tài nguyên (ghi chú). Tài nguyên chia: Rừng thưa (Xưởng Gỗ) · **Núi đá (Mỏ)** · **Suối (Bến Cá)** |
| KP-06 | **Mỏ**: 40 vàng + 40 gỗ, 90 giây; sản xuất **Đá** 4/phút và **Sắt** 2/phút. **Bến Cá**: 30 vàng + 30 gỗ, 60 giây; +3% HP tối đa mỗi Bến Cá, tối đa +15% (Q26) |
| TB-11 | Tài nguyên **Đá, Sắt** hiện trên HUD khi có. Dùng ở Thợ rèn Thiết Ngưu: **10 Đá → 1 Đá Cường Hoá**, **20 Đá + 10 Sắt → 1 Tinh Kim** |
| TP-26 | **Khứu Giác Kho Báu**: ô Di tích ở lưới mới 12% → **20%** (Lv10 30%) |
| NV-24 | **EXP offline từ lãnh địa** (kịch bản: 5% nguồn EXP): mỗi công trình sản xuất (Xưởng Gỗ, Mỏ) cho **1 × cấp EXP mỗi phút** khi offline, cùng giới hạn 12 giờ |
| TB-05 | **Bộ cộng hưởng Thiên phú**: mặc ≥ 4 món của 1 bộ và Thiên phú thuộc nhóm hợp bộ → thêm hiệu ứng *"Người Khai Hoang"*: Bộ Thợ Săn Sương + nhóm Chiến đấu: +5% chí mạng; Bộ Phong Hành + nhóm Khai phá: +10% tốc chạy và +1 Đuốc tối đa |
| — | Sản lượng lãnh địa cộng **mọi vùng** (Xưởng Gỗ vùng 1 vẫn chạy khi đang ở vùng 2) |

**Nhiệm vụ chính chương 2** (HUD góc phải thay mục tiêu chương 1 khi đang ở vùng 2):

| Bước | Mục tiêu | Thoại/kết quả |
| --- | --- | --- |
| 1 | Tới Thành Biên Đài, nói chuyện với Lạc Phong | Gia nhập Liên minh, nhận **lãnh địa đầu tiên** (lưới vùng 2), +200 vàng |
| 2 | Hạ 30 quái ở vùng 2 | +1 món Xanh dương |
| 3 | Chiếm 6 ô đất vùng 2 | Hạng Bạc khi đủ 10 ô (về sau) |
| 4 | Hỏi Mạc Tam về tin đồn | Mạc Tam lộ là gián điệp Hư Vô Giáo, chạy về Phủ Huyền Ảnh |
| 5 | Hạ Tướng Gián Điệp Huyền Ảnh ở Mắt Bão | Chương 2 hoàn thành |

### 6.5. Thay đổi save (version 4 → 5)

| Trường | Kiểu | Mặc định khi chuyển từ v4 |
| --- | --- | --- |
| `map_id` | Map đang đứng | `"1-1"` |
| `unlocked_maps` | Map đã mở điểm dịch chuyển | `["1-1"]`, thêm `"1-3"` nếu đã hạ Sói Chúa |
| `grids` | `{vùng: [ô]}` lưới của các vùng **không** đang đứng (`tiles` vẫn là lưới vùng hiện tại) | `{}` |
| `bosses` | Boss đã hạ: `{id: true}`; `boss_defeated` giữ cho Sói Chúa | `{"boss": boss_defeated}` |
| `ore`, `iron` | Đá, Sắt | `0` |
| `quest` | Bước nhiệm vụ chính chương 2, số quái đã hạ ở vùng 2 | `{"ch2": 0, "kills2": 0}` |
| `active_copy` | Kỹ năng sao chép đang dùng (Đạo Tặc) | kỹ năng cuối cùng |

### 6.6. Kiểm thử tự động cần có

| # | Nội dung |
| --- | --- |
| MP-T1 | Di chuyển: bị chặn khi đang giao chiến/có boss; 4 giây đi đường (Chân Không 3,6 giây); tới vùng an toàn map mới; mở điểm dịch chuyển; hồi sinh ở vùng an toàn của map |
| MP-T2 | Điều kiện mở map (3 điều kiện vùng 2); thử thách vượt ải ≤ 5 cấp; EXP ×2 với quái cao hơn ≥ 5 cấp |
| MP-T3 | Save v4 → v5; lưu/nạp giữ map, map đã mở, lưới vùng 2, Đá/Sắt, bước nhiệm vụ |
| GI-T1 | Gió: đẩy đúng 60 đơn vị/giây; ngược −30%, xuôi +20%; đổi hướng đúng chu kỳ; đạn lệch ≤ 15° |
| CB-T7 | Quái vùng 2 khớp bảng 06 (Ưng Gió cấp 10, Huyền Ảnh 18.804 HP); khiên chặn giảm 70% từ trước, không giảm từ sau; Hút kéo người chơi; Bổ nhào trúng |
| CB-T8 | Huyền Ảnh: giai đoạn 2 có 2 bản sao không bóng, giai đoạn 3 có 4; bản sao chết thì nổ; đổi chỗ mỗi 6 giây; hạ → chương 2 hoàn thành |
| CB-T9 | Kháng hệ giảm đúng %; NV-25 quái thấp 10 cấp cho 10% EXP |
| TB-T1 | Bộ Phong Hành 2/4/6; Mặt Nạ tạo phân thân khi né; ảo ảnh hút đòn; Đạo Tặc học Phân Thân |
| KP-T1 | Lưới vùng 2: 45 ô, tỉ lệ sự kiện (mô phỏng 2.000 lưới); Khứu Giác Di tích 20%; Mỏ ra Đá/Sắt; Bến Cá +3% HP; sản lượng cộng mọi vùng; EXP offline |
| KP-T2 | Nhiệm vụ chương 2 đi đủ 5 bước; Mạc Tam biến mất sau bước 4; thợ rèn đổi đúng; hạng Khai Giới Giả |
| TL-B2 | Cân bằng vùng 2: bot cấp 17, mặc bộ đồ chuẩn cấp 17, 2 lớp × 20 Thiên phú hạ được Huyền Ảnh; F/S ≤ 25%, 2 lớp ≤ 25% |

### 6.7. Điểm cần duyệt

M4 code theo **mặc định** dưới đây. **Trạng thái: chưa duyệt** (đã code theo mặc định; kết quả ở 6.8).

| # | Câu hỏi | Mặc định | Lý do |
| --- | --- | --- | --- |
| Q35 | Gộp Bìa Rừng + Rừng Sâu thành map 1-1 hiện có (vùng 1 = 2 map + hang) | Gộp | Map 1-1 đã cân bằng và có test; tách đôi không thêm nội dung mới |
| Q36 | Di chuyển giữa map qua bản đồ lục địa, 4 giây đi đường, không đi được khi giao chiến | Như vậy | Đơn giản, tránh thoát boss bằng cách đổi map |
| Q37 | Thành Biên Đài là vùng an toàn trong Cửa Gió (không phải map riêng) | Như vậy | Ít màn chờ; giống Làng Thanh Thạch ở vùng 1 |
| Q38 | Tên NPC (Lạc Phong, Thiết Ngưu, Mạc Tam) và nội dung 5 bước nhiệm vụ | Như bảng | Kịch bản chỉ ghi diễn biến 1 dòng |
| Q39 | Đá/Sắt dùng ở Thợ rèn (đổi Đá Cường Hoá, Tinh Kim) cho tới khi có Xưởng Rèn (M5) và nâng Trấn (Alpha) | Như vậy | Cần chỗ tiêu ngay để tài nguyên mới có ý nghĩa (Q26) |
| Q40 | Kháng hệ đến từ affix trang bị | Như vậy | Kịch bản chỉ liệt kê chỉ số; khảm ngọc (Alpha) sẽ thêm nguồn kháng |
| Q41 | Thương nhân, Cổng dungeon trên lưới vùng 2 tạm tính là Tài nguyên | Như vậy | 2 hệ thống này ở M5/Alpha |
| Q42 | EXP offline = 1 × cấp mỗi phút mỗi công trình sản xuất | Như vậy | Kịch bản chỉ ghi "5% nguồn EXP"; cần playtest |

### 6.8. Kết quả triển khai M4

Hoàn thành 20/10/2026: M4.1 (phiên game-bc), M4.2 + M4.3 (phiên chính). **76/76 test** (11 test M4.2–M4.3 mới: GI-T1, CB-T7, CB-T8, CB-T9, TB-T1, MP-T2, TL-B2, KP-T1, KP-T1b, KP-T2 + M4.1). Smoke test chụp thêm `09-region2`, `09b-town`, `09c-town-shop`.

**Cân bằng TL-B2** (bot cấp 17, bộ đồ chuẩn cấp 17, mỗi tổ hợp 2 trận với 2 seed): Kiếm Khách F 47,5 / S 40,4 giây (15%); Thợ Săn F 41,4 / S 31,7 giây (23%); 2 lớp chênh 17%; không lần chết nào.

**Chỉnh trong lúc làm (so với spec):**

| # | Thay đổi | Lý do |
| --- | --- | --- |
| M4-F1 | Kháng hệ **chỉ** có trên đồ phòng thủ (mũ, áo, giày, dây chuyền, bùa) | 5 affix mới làm loãng bể affix: vũ khí hay ra kháng thay vì tấn công, boss chương 1 chậm 29 → 37 giây |
| M4-F2 | Bản sao Huyền Ảnh bắn **1** phi tiêu, hồi 2,2 giây (thay vì 3 phi tiêu như boss) | 4 bản sao × 3 phi tiêu mỗi 1,8 giây là màn đạn không né nổi |
| M4-F3 | Huyền Ảnh đánh thường hồi 1,1 giây (0,7 trong bản nháp) | Kiếm Khách chết 2–6 lần/trận: né lăn hồi 3 giây không theo kịp nhịp đánh 1,2 giây |
| M4-F4 | **Khoá mục tiêu mềm** cho Thợ Săn: dùng chuột → quái trong hướng ngắm ±15° trước; bàn phím → quái gần nhất (N9). Đòn đã khoá **bù gió** (chỉ lệch 5°) | "Luôn bắn quái gần nhất" làm không nhắm được bản thật giữa các bản sao; gió 15° làm tên trượt ở tầm xa |
| M4-F5 | Phủ Huyền Ảnh (Mắt Bão) khoá tới khi lật mặt Mạc Tam (bước 5) | Giữ đúng thứ tự cốt truyện chương 2 |
| M4-F6 | Thương nhân lữ hành có trên lưới vùng 2 (4 ô) — không tính là Tài nguyên như Q41 | Thương nhân đã làm ở C1 |
| M4-F7 | TL-B2 chạy 2 seed mỗi tổ hợp | Gió đổi ngẫu nhiên làm một trận đơn lẻ dao động quá mạnh |


## 7. Đợt SN2 — Spec_Notes đợt 2

Spec riêng: [09-spec-notes-dot-2.md](09-spec-notes-dot-2.md) — lớp Pháp Sư (SN-01…07), phân rã/bán nhanh có bộ lọc (SN-10…12), chuyển cấp cường hoá khi mặc đồ (SN-20), map ×1,6 và sương che bản đồ (SN-30…33), save v7, test SN-T1…T6.

Thay đổi so với spec các đợt trước:

| Mục cũ | Thay đổi ở SN2 |
| --- | --- |
| 5.3 — AGI +1% tốc đánh | Thợ Săn chỉ +0,6%/AGI (SN-07); lớp khác giữ +1% |
| 6.2 — kích thước map (2600 × 1600…) | Mọi map ×1,6 mỗi chiều (SN-30) |
| EQ-10 — mặc đồ, đồ cũ về túi | Đồ cũ cường hoá cao hơn thì 2 món đổi cấp (SN-20) |
| TL-B, TL-B2 — có quái thường | Tắt sinh quái thường trong trận đo; TL-B2 lấy trung bình 4 trận; so lớp nhanh nhất với lớp chậm nhất (3 lớp) |

## 8. Đợt M5 — Chuẩn bị thử nghiệm kín

### 8.1. Phạm vi

Phần lớn hạng mục M5 trong lộ trình ban đầu (thoại, nhiệm vụ cốt truyện, hướng dẫn, Xưởng Rèn, Vườn Thảo Dược, Thương nhân lữ hành, cửa hàng, Tự đánh, tự cộng điểm, boss hiếm vùng 1) **đã làm sớm ở đợt C1** ([08](08-chuong-1-hoan-chinh.md)). M5 còn lại:

| Mã | Nội dung | Trạng thái |
| --- | --- | --- |
| M5-01 | Boss hiếm vùng 2 **Bạch Hổ Phong Vân** ở Mắt Bão (06 vùng 2), rơi **Vuốt Bạch Hổ** | ✅ |
| M5-02 | Nhịp lên cấp: Spec_Notes đợt 3 "nhân vật lên level nhanh quá" — nghiên cứu nhịp ARPG, chỉnh hệ số EXP (NV-20) | ✅ |
| M5-03 | Bản đồ nhỏ theo thời gian thực (Spec_Notes đợt 3) | ✅ |
| M5-04 | KP-04: chinh phục ô Di tích bằng câu đố | ✅ |
| M5-05 | KT-07: cài đặt cỡ chữ (hook `UiTheme.set_font_scale` đã có) | ✅ |
| M5-06 | KT-06: build .exe | ✅ (phiên game-bc, c1046bc) |

### 8.2. M5-01 — Bạch Hổ Phong Vân

- **Xuất hiện:** ở map 2-3 Mắt Bão, **sau khi đã hạ Huyền Ảnh**. Lần đầu vào map sau mốc đó thì xuất hiện ngay, sau đó mỗi 12 giờ thực (2 lần/ngày, như Lão Thụ). Lão Thụ cũng chỉ xuất hiện sau khi hạ boss vùng (Lõi Sương mở sau Sói Chúa). Boss không xuất hiện trong Phủ Huyền Ảnh.
- **Chỉ số:** theo công thức 06, bậc "hiem", loại "nhanh", cấp 20: 42.640 HP · 159 Tấn công · 53 Phòng thủ. Có thanh Phá Thế (HP/6).
- **Kỹ năng:**

| Kỹ năng | Spec 06 | Code |
| --- | --- | --- |
| Hổ Vồ | Chuỗi 3 cú vồ, mỗi cú vòng 6 m ×1,4 | Mỗi 4 giây; vung 0,7 s, giữa 2 cú 0,4 s; mỗi cú vồ xa tối đa 22 m tới chỗ người chơi đang đứng; vòng đỏ báo trước. Phá Thế ngắt chuỗi |
| Gầm Gió | Vòng 10 m: đẩy lùi 8 m, choáng 1 giây | Chỉ dùng khi người chơi đứng trong 10 m, hồi riêng 9 giây; vung 0,8 s; né lăn tránh được. Choáng: không đi, không đánh, không né, gió không đẩy |
| Cưỡi Gió | Dưới 50%: luôn xuôi gió, tốc ×1,5 | Tốc chạy ×1,5 (quái không chịu gió nên "luôn xuôi gió" không cần xử lý thêm) |
| Đòn cắn thường | — | Vung 0,6 s, nghỉ 1,2 s (thú vồ, không đánh tay đôi liên tục) |

- **Rơi:** Vuốt Bạch Hổ (găng Cam) · 1 Tinh Hoa Tiến Hoá · 5 Thiên Phú Tinh Hoa · 1.600 vàng. Theo 06, không rơi thêm đồ Tím (Lão Thụ thì có).
- **Vuốt Bạch Hổ:** đòn chí mạng gây chảy máu, mỗi giây một lần, 4 lần; mỗi lần = sát thương của 30% Tấn công qua Phòng thủ quái. Chí mạng lại thì làm mới thời gian.
- **Save v8:** `rare_at` = {loại boss: giờ Unix lần tới}. Save v7 trở về trước: `rare_boss_at` chuyển thành lịch của Lão Thụ.

**Cân bằng (M5-T3, bot cấp 20, bộ đồ chuẩn cấp 20, 3 bình máu, 2 seed):**

| Lớp | Thời gian | Chết | Bình máu dùng |
| --- | --- | --- | --- |
| Kiếm Khách | 81–85 giây | 0 | 2–3 |
| Thợ Săn | 52–55 giây | 0 | 0 |
| Pháp Sư | 73–121 giây | 0 | 0 |

Lúc đầu Gầm Gió dùng chung nhịp 3,2 giây với Hổ Vồ: Kiếm Khách bị đẩy ra và choáng gần một nửa thời gian, chết 17 lần trong 600 giây. Sau khi tách Gầm Gió ra hồi riêng 9 giây và cho đòn cắn thường nghỉ 1,2 giây, Kiếm Khách thắng mà không chết lần nào. Lớp cận chiến vẫn chậm hơn lớp đánh xa khoảng 50%. Chấp nhận được với boss hiếm, xem lại khi có playtest.

### 8.3. M5-02 — Nhịp lên cấp

**Vấn đề (Spec_Notes đợt 3):** "Nhân vật lên level nhanh quá." Bot chỉ đánh quái, không làm nhiệm vụ, boss hay khai phá mà vẫn lên **cấp 10 sau 2,3–3,2 phút, cấp 17 sau khoảng 10 phút**. Kịch bản đặt mục tiêu cấp 10 sau 30 phút. Chỉ cần hạ khoảng 89 quái là lên cấp 10.

**Tham khảo thị trường:**

| Game | Nhịp |
| --- | --- |
| Diablo 4 | Cấp 20 khoảng hết Màn 1, 8–10 giờ (bản thử nghiệm); cấp 100 trung bình 150 giờ (Blizzard) |
| Path of Exile 2 | Lần chơi đầu: cả cốt truyện 20–25 giờ |
| Game mobile / idle | Cấp 5–10 đạt trong phiên đầu (phiên đầu trung bình 9 phút, phiên > 9 phút giữ chân ngày 1 tốt hơn: 31% so với 20%) |
| Kịch bản Thiên Phú Khai Giới | Cấp 1 → 10 trong 30 phút, 10 → 30 trong 6 giờ (chặng 10 → 20 chiếm 24% EXP, khoảng 86 phút) |

Game là ARPG lai idle, nên nhanh hơn Diablo nhưng giữ đúng mốc của kịch bản. Mục tiêu cho người chơi thật: **cấp 5 ở phút 10–15** (mở hang Sói Chúa), **cấp 10 ở phút 30** (mở vùng 2), **cấp 20 sau khoảng 2 giờ**.

**Ngân sách EXP theo nguồn (kịch bản mục 4):** quái 40% · nhiệm vụ 25% · boss + boss hiếm 20% · khai phá 10% · offline 5%.

| Thay đổi | Cũ | Mới |
| --- | --- | --- |
| EXP quái thường (`Formulas.mob_exp`) | 30·L^1,5 | **6,5·L^1,3** (tinh anh ×3 như cũ) |
| EXP boss chương (`boss_exp`) | 0,3 × EXP cấp | **0,6 × EXP cấp** |
| EXP khai phá mỗi phát hiện (`Formulas.explore_exp`) | 40 × cấp | **8·L^1,6** (cấp 5: 105, cấp 15: 609) |
| Thưởng nhiệm vụ chương 1 | tổng 420 EXP | tổng **9.650 EXP** (80 → 3.500 tăng dần theo bước) |
| Thưởng nhiệm vụ chương 2 | tổng 3.000 EXP | tổng **95.000 EXP** (5.000 · 15.000 · 20.000 · 25.000 · 30.000) |
| Lính khiên quay người | tức thì | **tối đa 120°/giây** (xem dưới) |

Với số mới: chỉ đánh quái thì lên cấp 10 cần khoảng 600 quái, cấp 20 khoảng 2.300 quái. Nhiệm vụ chiếm 23% (chương 1) và 25% (chương 2) EXP của chặng. Boss + boss hiếm chiếm 22% và 19%.

**Số đo (bot cày, chỉ EXP từ quái; `--only=PACE`):**

| | Cũ | Mới |
| --- | --- | --- |
| Cấp 1 → 10 (3 lớp) | 2,3–3,2 phút, 250–270 quái | **16,8–22,5 phút**, khoảng 530 quái, 0 lần chết với lớp đánh xa |
| Cấp 10 → 20 vùng 2 (3 lớp) | khoảng 7 phút | **86–89 phút**, khoảng 1.400–1.550 quái |

Bot đánh nhanh hơn người (không đi lạc, không mở bảng, không đọc thoại), nhưng người lại nhận thêm khoảng 60% EXP từ nhiệm vụ, boss và khai phá. Ước tính người chơi thật lên cấp 10 ở phút 25–35 và cấp 20 sau 2–2,5 giờ. Phải kiểm lại bằng playtest người thật.

**Phát hiện F-M5-1, lính khiên:** khi người chơi ngang cấp quái (trước đây người chơi luôn cao cấp hơn nên không lộ ra), Kiếm Khách chết **52 lần** trên chặng 10 → 20. Lính Đánh Thuê luôn quay mặt về người chơi ngay lập tức, nên lời dặn "đánh từ bên hông hoặc sau lưng" không làm được, và cận chiến luôn bị khiên chặn 70%. Sửa: lính khiên quay tối đa 120°/giây, chạy vòng thì đánh được vào hông. Bot Kiếm Khách được dạy chạy vòng. Kết quả: Kiếm Khách chết **16 lần**, mất 86 phút, ngang lớp đánh xa. TL-B, TL-B2 và M5-T3 không đổi.

### 8.4. M5-03 — Bản đồ nhỏ

Spec_Notes đợt 3: "cần thêm bản đồ real-time để tiện theo dõi đang đứng ở đâu".

- **Vị trí:** góc phải HUD, dưới bảng nhiệm vụ. Rộng 230 px, cao theo tỉ lệ map. **Phím V** đổi sang cỡ lớn 460 px và ngược lại. Dòng combo dời xuống dưới bản đồ.
- **Nội dung:** tiêu đề "tên map · % khám phá"; đất tô màu theo vùng; **chỗ chưa khám phá phủ tối**, cùng dữ liệu với sương che SN-31, nên giữ được cảm giác "đi tới đâu thấy tới đó"; làng/thành/trạm (vàng); hang boss (vòng đỏ); tường sương trước hang khi chưa mở (vạch tím); NPC (chấm vàng); quái thường (chấm đỏ nhỏ), tinh anh (cam); boss và boss hiếm (to, nhấp nháy); nhân vật là mũi tên trắng theo hướng nhìn.
- **Không lộ thông tin:** quái ở chỗ chưa khám phá và quái đang tàng hình (Tinh Linh Sương ở Lõi Sương) không hiện.
- **Hiệu năng:** sương là ảnh 1 pixel/ô (tối đa 70 × 40), chỉ dựng lại khi có ô mới mở.

### 8.5. M5-05 — Cỡ chữ

Esc → Cài đặt → dòng **Cỡ chữ** có 4 mức: Nhỏ (×0,9) · Vừa (×1,0) · Lớn (×1,15) · Rất lớn (×1,3). Đổi là áp ngay: `main.gd` dựng lại theme bằng `UiTheme.set_font_scale(k)` và gán cho cây UI. Hệ số lưu trong `user://settings.cfg` (`font_scale`, tách khỏi save game) và được áp ngay khi mở game. Phạm vi: mọi chữ lấy cỡ từ theme. Chỗ code tự đặt cỡ chữ chỉ đổi theo khi dùng `UiTheme.fs()`. Phần chữ vẽ tay trên bản đồ nhỏ và thanh kỹ năng giữ cỡ cố định.

### 8.6. M5-04 — Câu đố Di tích (KP-04)

Kịch bản mục 7: "Chinh phục: hạ quái canh giữ **hoặc giải câu đố** để chiếm ô"; Di tích (12%): "câu đố, rương báu, trang sách cốt truyện".

- Chọn ô Di tích đã dọn sương trong bảng khai phá (M) thì hiện câu đố của ô đó. Có 2 loại:
  - **Trận Đèn Cổ:** lưới 3 × 3 bùa; bấm một bùa thì nó và các bùa kề trên/dưới/trái/phải đảo sáng/tối; thắp đủ 9 bùa là giải được. Đề sinh bằng cách bấm 3 bùa khác nhau từ trạng thái đã giải. Bài Lights Out 3 × 3 luôn có nghiệm duy nhất, nên đề không bao giờ đã giải sẵn và luôn giải được trong ≤ 3 bước.
  - **Câu hỏi cổ thư:** 1 câu, 3 lựa chọn, về cốt truyện và mẹo chơi (Đuốc, Phá Thế, né Hoàn hảo, ngũ hành tương khắc khớp `Monsters.COUNTERS`). Câu về chương 2 chỉ hỏi ở vùng 2.
- **Giải được:** chiếm ô, **thưởng ×2**: 160 vàng, EXP khai phá ×4 (`explore_exp × 2 × 2`), **+1 Đá Cường Hoá**, cộng món Xanh dương và trang sách cốt truyện như cũ.
- **Trả lời sai:** cơ quan rương khoá **30 giây** (giờ thực), sau đó trả lời lại được. Trận Đèn Cổ không bị phạt.
- **Phá khoá (thưởng thường):** vẫn mở ngay được như trước (80 vàng, EXP ×2), để người chơi không bị kẹt.
- **Không đổi save:** câu đố sinh cố định theo (tên nhân vật, vùng, id ô), mở lại vẫn là câu cũ. Trạng thái giải dở chỉ giữ trong phiên chơi.
- EXP Di tích đổi từ cố định 150 thành theo cấp (M5-02).

### 8.7. Kiểm thử

| Mã | Nội dung |
| --- | --- |
| M5-T1 | Bạch Hổ: chưa hạ Huyền Ảnh thì không xuất hiện; chỉ số 06; không xuất hiện trong Phủ; Hổ Vồ đúng 3 cú, tầm 22 m; Gầm Gió đẩy 8 m + choáng (không đi/đánh/né); né lăn tránh được; Phá Thế ngắt chuỗi; Cưỡi Gió ×1,5; rơi Vuốt (không Tím); lịch riêng từng boss; save v8 và chuyển đổi v7 |
| M5-T2 | Vuốt Bạch Hổ: chí mạng → chảy máu 4 giây, 30% Tấn công mỗi giây; không mặc thì không chảy máu |
| M5-T3 | 3 lớp cấp 20 hạ Bạch Hổ không chết lần nào, tối đa 3 bình máu |
| M5-T4 | Lính khiên quay tối đa 2° mỗi khung hình; đánh sau lưng không bị chặn; sau 1,5 giây quay lại đối mặt |
| M5-T5 | Chỉ đánh quái: cấp 10 cần 500–700 quái, cấp 20 cần 2.000–2.700 quái; nhiệm vụ 18–32% EXP mỗi chương; boss + boss hiếm 15–30% |
| M5-T6 | Bản đồ nhỏ: ảnh sương đúng số ô của map, cỡ đúng tỉ lệ, dựng lại khi khám phá thêm, phím V đổi cỡ |
| M5-T7 | Cỡ chữ: mặc định 1,0; "Rất lớn" nhân cỡ chữ theme ×1,3; `fs()` theo hệ số |
| M5-T8 | Câu đố: sinh cố định, đủ 2 loại; Trận Đèn Cổ chưa giải sẵn và giải được trong ≤ 3 bước (thử hết 512 tổ hợp); đáp án đúng vị trí; vùng 1 không hỏi chuyện chương 2; câu ngũ hành khớp bảng khắc; giải được +160 vàng +1 Đá; sai khoá 30 giây; phá khoá +80 vàng |
| PACE-T1, T2 | Đo nhịp (chạy riêng `--only=PACE`, vài phút): bot cày từ cấp 1 và từ cấp 10, in phút tới từng mốc cấp, số quái, số lần chết theo map |

## 8b. Spec_Notes đợt 4 — gọn giao diện (UI-07)

Ghi chú của chủ dự án: *"Kỹ năng đang to quá — khi mở toàn màn hình bị chiếm khá nhiều diện tích; thanh máu cũng vậy. Thanh tài nguyên nên căn giữa góc trên; vị trí cũ của thanh tài nguyên đổi cho bản đồ nhỏ."*

| Mã | Yêu cầu | Trạng thái |
| --- | --- | --- |
| UI-07a | Thanh kỹ năng thu nhỏ ×0,8 (chữ trong thanh vẽ to hơn để vẫn đọc được ở 1366 × 768) | ✅ |
| UI-07b | Khung nhân vật (góc trái): rộng 290 → 240, thanh HP 20 → 15, MP/EXP 10, chữ nhỏ hơn | ✅ |
| UI-07c | Thanh tài nguyên ra **giữa cạnh trên**; bỏ dòng gợi ý "rê chuột…" (chỉ hiện khi Đuốc đang hồi); dòng gió/môi trường và thanh máu boss nằm ngay dưới | ✅ |
| UI-07d | Bản đồ nhỏ lên **góc phải trên**; khung nhiệm vụ (rộng 260) nằm ngay dưới bản đồ nhỏ | ✅ |

### UI-08 — Khung nhân vật kiểu "khung vàng – ngọc tím" (Spec_Notes đợt 6)

Chủ dự án gửi hình mẫu khung thanh máu/thông tin nhân vật (21/10/2026), sau đó góp ý thêm: *"Kinh nghiệm nên thành vòng tròn bao quanh nhân vật, chỗ nối với level màu tím; bỏ viền chữ nhật và nền để nhìn rõ map; khung avatar to quá, chỉnh nhỏ lại; Thiên phú đổi xuống chỗ Máu và MP, Máu và MP cũng bao quanh giống thanh kinh nghiệm."* Cùng đợt: gộp C vào Túi đồ, thanh kỹ năng thấp hơn, hiện EXP khi hạ quái, Tự đánh thành nút bấm, bỏ chữ "C: cộng điểm", cổng dịch chuyển thay bảng lục địa.

| Mã | Yêu cầu | Trạng thái |
| --- | --- | --- |
| UI-08a | Thay khung cũ (UI-07b) bằng khung theo hình mẫu: bảng tên viền vàng + ngọc tím ở trên; chân dung tròn (vẽ nhân vật theo ngoại hình, có nhịp thở) viền vàng 2 lớp, gai vàng 4 góc chéo, ngọc 3 phía; khiên **cấp** ở chân chân dung; 2 huy hiệu lục giác hai bên bảng tên: **Lực chiến** (la bàn, trái) và **Điểm tiềm năng** (phải; +N nhấp nháy khi còn điểm, mờ khi 0). *(Bản đầu có hoa sen bên trái và 2 thanh HP/MP ngang — đã thay ở UI-08f.)* | ✅ |
| UI-08b | **EXP là vòng tím** quanh chân dung, hai đầu nối vào khiên cấp (đầy theo chiều kim đồng hồ từ mép trái khiên, qua đỉnh, về mép phải); chữ "EXP x,x%" dưới khiên | ✅ |
| UI-08c | **Không nền, không viền chữ nhật** — nhìn xuyên thấy bản đồ (chữ đều có viền đen để đọc được trên mọi nền) | ✅ |
| UI-08d | Thu nhỏ cả khung ×0,75 (≈ 177 × 183 điểm ảnh ở 1366 × 768); nhân vật trong chân dung vẫn đúng 1 điểm ảnh gốc = 2 điểm màn hình | ✅ |
| UI-08e | Dòng phụ cuối khung (chỉ hiện khi có): cấp Thiên phú/tiến hoá, Đồng minh, Hệ (Ngũ Hành). Bỏ "TỰ ĐÁNH (Z)" (thành nút UI-12) và "C: cộng điểm" (huy hiệu Điểm đã đủ báo) | ✅ |
| UI-08f | **HP / MP thành vòng** bao ngoài vòng EXP: nửa trái đỏ (HP), nửa phải xanh (MP), đầy từ đáy (khiên cấp) lên đỉnh, đầu vòng có chấm sáng; số "hiện tại / tối đa" cạnh huy hiệu tim / giọt nước hai bên. **Thiên phú** (hoa sen màu theo hạng + icon + tên dạng tiến hoá) dời xuống dưới, chỗ 2 thanh cũ | ✅ |
| UI-09 | Hạ quái hiện **"+N EXP"** (tím) trong cột chữ nhặt đồ trên đầu nhân vật; các lần hạ liền nhau trong 1 giây gộp một dòng; EXP thưởng nhiệm vụ không hiện ở đây (đã có dòng nhật ký) | SN6-T1 ✅ |
| UI-10 | **Thanh kỹ năng thấp**: bỏ bảng tiêu đề "Kỹ năng", tên và dòng phụ dưới ô; ô R 26 → 22, khoảng 82 → 60, tỉ lệ 0,8 → 1 (cao ≈ 70 điểm ảnh thay vì ≈ 120). Giữ: icon, phím, hồi chiêu; thêm **huy hiệu số** góc trên phải (cấp kỹ năng > 1, số bình máu) và **chữ khoá** trên ô chưa mở ("Cấp 8"); thiếu MP thì ô ngả xanh | ✅ |
| UI-11 | **Gộp bảng Chỉ số (C) vào Túi đồ (I)** — bảng "Nhân vật" có 3 tab: Túi đồ · **Chỉ số** · Tài nguyên; cột trái (búp bê trang bị + chỉ số) giữ nguyên ở mọi tab. Phím **I** mở tab Túi đồ, phím **C** mở thẳng tab Chỉ số (bấm lại cùng phím thì đóng); tab Chỉ số ghi "+N điểm" khi còn điểm. Lý do: cộng điểm và thay đồ cùng đổi chỉ số — xem chung một chỗ thấy ngay kết quả; giữ phím C cho người quen | ✅ |
| UI-12 | **Nút Tự đánh** tròn (2 kiếm chéo, nhãn BẬT/TẮT, phím Z ở góc) cạnh phải thanh kỹ năng; bấm chuột hoặc Z; chuột trên nút không vung kiếm | ✅ |
| MP-09 | **Cổng dịch chuyển** thay cho chọn nơi đến trên bảng lục địa. Mỗi map tự sinh cổng từ dữ liệu: **cổng tiến** (rìa phải, phía trên, trước tường sương hang boss) sang map kế tiếp theo thứ tự vùng; **cổng lùi** (rìa trái, ngang vùng an toàn) về map trước; **Cổng Dịch Chuyển** trong vùng an toàn. Bước vào cổng tiến/lùi → lên đường (vẫn theo MP-03: không giao chiến, 4 giây đi đường); chưa đủ điều kiện (MP-05, điều kiện cốt truyện) thì báo lý do, cổng xám và ghi điều kiện ngay trên cổng. Tới nơi bằng cổng thì đứng cạnh cổng dẫn ngược về (không bị kéo ngược lại; phải bước ra rồi vào lại mới kích hoạt). Bước vào Cổng Dịch Chuyển → mở bảng lục địa; chỉ ở đây mới chọn được nơi đến, và chỉ tới **map đã mở** (MP-04) — map mới phải đi bộ qua cổng. Phím N ở chỗ khác chỉ để xem. Cổng hiện trên bản đồ nhỏ (vàng tiến, xanh lùi, tím Cổng Dịch Chuyển) | SN6-T2 ✅ |
| UI-14 | Thiết kế lại cổng (góp ý *"cổng đè mất nhân vật, UI xấu"*): vòng phù văn **nằm phẳng trên mặt đất** (elip), vành đá + vàng, 12 vạch phù văn sáng chạy vòng, lòng cổng xoáy sáng; 2 trụ đá có pha lê; cột sáng mờ + hạt bay lên (chỉ khi đi được); **bảng tên** nền tối viền màu phía trên ("Tới / Về <map>", dòng phụ cấp map hoặc điều kiện còn thiếu). Cổng vẽ ở lớp mặt đất, **trước** nhân vật/quái → nhân vật đứng trong cổng luôn hiện rõ. Cây/đá trang trí không mọc trong 120 điểm ảnh quanh cổng; Cổng Dịch Chuyển tự chọn chỗ trống trong vùng an toàn (xa nhà, NPC, tâm, điểm xuất hiện) | Smoke `09a-portal` ✅ |
| UI-13 | **Biểu tượng ngũ hành** thay chữ: Kim = thỏi bạc hình thoi, Mộc = lá, Thủy = giọt nước, Hỏa = ngọn lửa, Thổ = núi; huy hiệu tròn viền màu hệ. Dùng cho hệ của quái (cạnh thanh máu), cột đá Câu Đố Nhân Sư, và hệ đang dùng của Ngũ Hành Linh Căn (góc hoa sen trên khung nhân vật — bỏ chữ "Hệ Mộc" ở dòng phụ) | ✅ |
| UI-08g | Tên Thiên phú trên khung nhân vật **một dòng** (tự thu cỡ chữ cho vừa), không xuống dòng ("S · Ngũ Hành Linh Căn") | ✅ |
| UI-15 | **Bảng tên quái** "<biểu tượng hệ> Loại · Tên · Lv N": Thường (xám) · Tinh anh (vàng) · Thủ lĩnh (cam, chủ Ổ quái) · Hiếm (tím) · Chúa Hang (đỏ cam); cấp tô màu theo chênh lệch với người chơi (đỏ ≥ +5, cam > 0, trắng, xám ≤ −5). Quái thường chỉ hiện khi ở gần (≤ 420) hoặc đã bị đánh | ✅ |
| UI-11b | Thứ tự tab Túi đồ: **Chỉ số (C) · Túi đồ (I) · Tài nguyên** | ✅ |
| UI-16 | *(Spec_Notes đợt 7 — "Nhiệm vụ: thông tin nhiều hơi rối, cần gọn; bỏ M: Khai phá… đưa vào help")* **Khung nhiệm vụ gọn**: rộng 260 → 240, bỏ khung gỗ → nền mờ + vạch vàng bên trái; 4 dòng: tiêu đề nhỏ ("CHƯƠNG 2 · 1/5 · Hạng Đồng" — bỏ chữ "NHIỆM VỤ"), mục tiêu (vàng đậm 13), gợi ý (12), thưởng (11, nhạt); **bỏ dòng phím tắt** | ✅ |
| UI-16b | *(đợt 7: "khung nhiệm vụ hơi xấu, cần design lại")* Nền `ui/quest_box.gd` cùng phong cách khung nhân vật: tím đêm mờ, viền vàng mảnh 2 lớp, ngọc tím 4 góc + ngọc giữa cạnh trên; tiêu đề căn giữa, vàng đậm, đường kẻ vàng mờ 2 đầu có ngọc giữa | ✅ |
| UI-13b | *(đợt 7: "hệ Thổ với Thiên phú đè lên nhau")* Biểu tượng hệ (Ngũ Hành Linh Căn) chuyển sang **ô riêng cuối hàng Thiên phú**; tên Thiên phú co lại nhường chỗ, không còn chồng lên hoa sen / chữ | ✅ |
| UI-20 | *(góp ý 22/10: "nhật ký thông báo chưa đẹp, chưa chuyên nghiệp")* **Nhật ký thông báo** (góc trái dưới) vẽ lại: bỏ hộp xám bo góc → dải nền tối mờ dần sang phải (`ui/log_box.gd`), vạch màu mép trái + huy hiệu kim cương đầu dòng theo loại tin (vàng = tốt, đỏ = xấu, xanh xám = thường), chữ 13 có viền; **số trong câu tô đậm màu loại tin**, số ≥ 5 chữ số có dấu chấm ngăn nghìn (80.000); tối đa 5 dòng, mỗi dòng hiện dần 0,18 giây, sống 6 giây rồi mờ dần | ✅ |
| UI-17 | **Bảng Trợ giúp** — phím **F1 / H** hoặc nút "Trợ giúp (F1)" trong menu Esc: toàn bộ phím tắt (danh sách chung với màn hình tiêu đề, đã bổ sung Z, U, V, E, F1) + 6 mẹo (cổng, Cổng Dịch Chuyển, hang, bảng tên quái, Truy kích, điểm tiềm năng). Đầu mỗi phiên chơi có 1 dòng nhật ký "Nhấn F1 để xem phím tắt và mẹo chơi." | Smoke `05a-help` ✅ |
| UI-18 | *(người dùng, ảnh chụp tab Chỉ số: "đang bị trùng lặp thông tin")* **Bỏ trùng chỉ số ở tab Chỉ số**: khung tổng kết cuối trang Chỉ số (Lực chiến · HP · MP · Tấn công · Phòng thủ · Tốc đánh · Chí mạng · ST chí mạng · Né tránh) lặp lại đúng cột nhân vật bên trái (dùng chung cho 3 tab) → bỏ khung đó. Cột trái là nơi duy nhất hiện chỉ số dẫn xuất; dòng *Lực chiến* trong cột trái (đã có ở tiêu đề bảng "Nhân vật · Lực chiến N") đổi thành **ST chí mạng ×N** (thứ duy nhất khung cũ có mà cột trái thiếu) | ✅ Smoke `05-stats` |
| UI-19 | *(Spec_Notes: "Chỉ số sức mạnh, nhanh nhẹn… không có thông tin mặc định nhân vật thì chỉ số như thế nào?"; người dùng góp ý tiếp: hiện ngay ở cột số dạng "5 + 56", không cần bảng riêng)* **Chỉ số mặc định theo lớp** (`Stats.BASE_STATS`, tổng 17): Kiếm Khách STR 5 · AGI 3 · INT 2 · VIT 5 · LUK 2; Thợ Săn 3 · 5 · 2 · 4 · 3; Pháp Sư 2 · 3 · 5 · 4 · 3. Chỉ số = mặc định + điểm cộng (+ điểm Đạo Tặc cướp, đỏ), cột số hiện **"5 + 12"** (mặc định màu nhạt). Mặc định tính như điểm thường; phần nền theo lớp + cấp đã trừ đúng phần mặc định đóng góp nên **chỉ số cuối cùng không đổi** (không lệch cân bằng). Dòng phụ vàng: chỉ số đó (mặc định + điểm cộng) **đang cho bao nhiêu** ("Đang cho: +34 Tấn công"); tác dụng mỗi điểm ở tooltip. Hai nút Tẩy điểm / Tự cộng đặt cạnh nhau | ✅ UI-19; smoke `05-stats` |
| UI-21 | *(người dùng 27/10, gửi ảnh thiết kế: "design lại màn hình chỉ số, inventory… theo design mới")* **Bảng Nhân vật kiểu mới** (chung 3 tab Chỉ số · Túi đồ · Tài nguyên): tiêu đề biển gỗ "Nhân vật" + icon mũ, tab vàng có icon, nút đóng X vuông (I / C / Esc vẫn đóng). **Cột trái** (mọi tab): tên lớn + "Lv · chức nghiệp · Thiên phú (dạng hiện tại)"; búp bê giấy 4 + 4 ô đồ nền màu phẩm chất, số +N; chân dung đứng trên **bệ đá giữa rừng đêm, 2 đuốc lập loè** (thỉnh thoảng vung đòn); thẻ Thiên phú (huy hiệu lục giác màu hạng, tên, **5 sao = cấp Thiên phú/2**, mô tả, nút "?" — chú thích chi tiết + "phím T"); 8 chỉ số chính 2 cột có icon; khung **bộ đồ** (tên bộ, số món, icon từng món đang mặc, nút **Xem set** mở/ẩn danh sách thưởng 2/4/6). **Tab Chỉ số**: cột giữa "Điểm thuộc tính" — huy hiệu "Điểm còn lại", 5 thẻ (icon, tên, "Đang cho: …", **số lớn = tổng** mặc định + điểm cộng, bên cạnh "+ điểm đã cộng" màu vàng, điểm Đạo Tặc đỏ, nút +); nút Tẩy điểm (icon, 2 dòng) và **Tự cộng điểm** kèm danh sách **mẫu cộng theo lớp** (Kiếm Khách: STR Build 3 STR : 2 VIT · Chí mạng 2 STR : 2 AGI : 1 LUK · Trâu 2 STR : 3 VIT; Thợ Săn: AGI Build 3 : 1 VIT : 1 LUK · Trâu 3 AGI : 2 VIT · May mắn 2 AGI : 1 VIT : 2 LUK; Pháp Sư: INT Build 3 : 2 VIT · Trâu 2 INT : 3 VIT · Chí mạng 3 INT : 1 AGI : 1 LUK; mẫu đầu = Tự cộng cũ C1-34; lựa chọn giữ trong phiên chơi, không lưu save). Cột phải: **bảng Lực chiến** (2 cờ đỏ, kiếm chéo, số vàng lớn), "Chỉ số chiến đấu" (8 chỉ số chính + Hồi MP, ST kỹ năng, Rơi đồ, Kháng hệ — chú thích ghi 5 hệ), cảnh lửa trại + câu dẫn theo lớp. **Tab Túi đồ**: khung "Túi đồ" (số ô), 30 ô nền tối, đồ có nền/viền phẩm chất, Phân rã nhanh bên dưới; khung chi tiết món bên phải. **Tab Tài nguyên**: thẻ 2 cột (icon, tên, số lượng vàng, mô tả), cuộn được. Tab Túi đồ / Tài nguyên hiện Lực chiến gọn ở tiêu đề. Khác thiết kế: cột phải tab Chỉ số thêm chỉ số phụ (Hồi MP, ST kỹ năng, Rơi đồ, Kháng hệ). **UI-21b** *(góp ý 27/10: "2 thanh gươm đè lên Lực chiến, khác design"; "chỉ số lặp giữa chỗ nhân vật và Chỉ số chiến đấu")*: 2 kiếm nhỏ bắt chéo **trên** tấm biển Lực chiến (trên chóp giữa mép trên), không đè chữ; ở tab Chỉ số cột trái **bỏ 8 chỉ số chính** (đã có ở "Chỉ số chiến đấu"). **UI-21c** *(27/10, duyệt qua ảnh mock: "từ Ngũ Hành Linh Căn trở lên giữ như design cũ, chỉ đẩy Bộ đồ set lên nếu có, show all thông tin, không cần nút Xem set"; "không mặc đồ bộ thì không hiển thị")*: chân dung giữ chiều cao cũ ở cả 3 tab, **giãn ngang** để cột ô đồ bên phải thẳng mép phải với thẻ Thiên phú / khung bộ đồ; cả 3 tab cột trái không còn 8 chỉ số chính; khung bộ đồ ngay dưới thẻ Thiên phú, **chỉ hiện khi mặc ≥ 1 món thuộc bộ**: tên bộ + huy hiệu "n/6", 6 ô món (thiếu để mờ), đủ 3 mức thưởng 2/4/6 ghi "Đang có" (xanh) / "Thiếu N" (xám); bỏ nút "Xem set". Vừa khung 1366 × 768 | ✅ UI-21 |
| UI-22 | *(người dùng 27/10, gửi ảnh thiết kế màn chọn lớp; Spec_Notes: "chỗ chọn Class… giao diện đang xấu, cần design lại"; duyệt qua mock)* **Tạo nhân vật 2 bước.** Bước 1 — màn **chọn lớp kiểu thẻ** (`ui/class_select.gd`): 5 thẻ cột, mỗi lớp 1 màu (Kiếm Khách đỏ, Thợ Săn xanh lá, Pháp Sư tím, Hộ Vệ vàng, Triệu Hồi Sư tím hồng); mỗi thẻ: huy hiệu thoi + tên + vai trò ngắn, **chân dung lớn** 64×72 (×2) trên bệ đá trong cảnh theo lớp (sảnh đá cờ đỏ / rừng đom đóm / sảnh phép vòng phù văn / sảnh vàng / hư không), 8 ô trang bị 2 bên, câu dẫn, 7 chỉ số cấp 1 (HP, MP, Tấn công, Phòng thủ, Tốc đánh, Chí mạng, Né tránh), 4 kỹ năng đặc trưng (3 đầu + tối thượng; chú thích khi rê chuột), nút "Chọn lớp" màu lớp; chân trang "NĂM CON ĐƯỜNG, MỘT THẾ GIỚI". **Hộ Vệ, Triệu Hồi Sư** (docs/19, chưa làm) có chân dung nhưng ghi "SẮP RA MẮT", không chỉ số, nút khoá. Bước 2 — màn đặt tên + giới tính / da / tóc như cũ; hàng chọn lớp thay bằng thẻ lớp đã chọn (chân dung nhỏ, tên màu lớp, vai trò · chỉ số chính) + nút **Đổi lớp** mở lại bước 1. Khác thiết kế: chỉ số là số thật cấp 1 (ảnh minh hoạ số lớn hơn); hình là pixel art sinh bằng code (không phải tranh vẽ) | ✅ UI-22 |
| UI-23 | *(người dùng 27/10, gửi ảnh thiết kế: "phần kỹ năng cần design lại theo màn hình này")* **Bảng Kỹ năng kiểu mới** (phím U, `ui/skill_panel.gd`): tiêu đề biển gỗ "Kỹ năng" + nút X; **cột tab trái** chia kỹ năng thành Lớp (kỹ năng cấp 1–29) · Chuyển chức 1 · Tối thượng · Chuyển chức 2 (tab chưa mở hơi mờ, tooltip lý do; vẫn bấm xem được); **biển lớp** (nhân vật trên bệ theo cảnh màn chọn lớp, tên chức hiện tại, câu dẫn, ô **Điểm kỹ năng còn lại** + "mỗi cấp +8% sát thương / −4% hồi chiêu hỗ trợ"); **cây kỹ năng**: 2 kỹ năng đầu xếp dọc giữa, các kỹ năng sau chia 2 nhánh trái/phải nối mũi tên theo thứ tự mở (chỉ là thứ tự mở theo cấp, không thêm điều kiện học trước); ô kỹ năng có huy hiệu cấp "n/10", số ô đang lắp ở góc, ổ khoá + "Mở ở cấp N" / "Cần chuyển chức…" khi chưa mở; tab Chuyển chức 2 chưa chọn nhánh hiện 2 cột theo 2 nhánh; **cột phải** chi tiết kỹ năng đang chọn: icon lớn, nhãn Chủ động / Hỗ trợ / Tối thượng (+ hệ nếu có), cấp, mô tả, bảng **Hiệu ứng hiện tại** và **Hiệu ứng cấp kế** (Sát thương % công, Phạm vi lấy từ mô tả, Tiêu hao MP, Hồi chiêu — đã tính biến thể; chênh lệch tô xanh), Lắp vào ô 1–4, Biến thể 3 tầng + đổi Mảnh Bí Kíp (phần giữa cuộn được); thanh cấp + nút **Nâng cấp** cố định ở đáy; chân bảng **Tẩy điểm** + ghi chú vùng an toàn, số Mảnh Bí Kíp. **Khác ảnh thiết kế:** cột tab là các nhóm kỹ năng của lớp đang chơi (game không cho xem lớp khác); bỏ nút "Xem thử" (chưa có xem trước hoạt ảnh trong game); ghi chú tẩy điểm giữ đúng luật hiện tại (miễn phí ở vùng an toàn) thay cho "phí tăng theo số lần tẩy" | Smoke `05g-skills`, `14c-skills` ✅ |
| UI-24 | *(Spec_Notes đợt 8: "Shop: design đang không common giống các game hiện tại → design lại cho chuyên nghiệp")* **Cửa hàng kiểu quen thuộc** (`ui/shop_panel.gd`, phím E): biển tiêu đề "Cửa hàng · nơi · người bán" + ô Vàng / Đá / Bình máu + nút X; **tab dọc** Tạp hoá · Lữ hành (huy hiệu số món) · Bán đồ (số món trong túi) + nút **Lò Rèn (R)**; giữa là **lưới thẻ hàng** 3 cột (icon trong khung, viền theo phẩm chất, tên, giá kèm đồng vàng — đỏ khi không đủ tiền, góc ghi "có N" / cấp); phải là **khung chi tiết**: icon lớn, tên, mô tả công dụng, "Đang có", **chọn số lượng** (− N + Tối đa — Tối đa theo vàng và giới hạn mang, ví dụ bình máu 5), **Tổng** tiền, nút **Mua ×N**; đồ của Thương nhân lữ hành hiện chỉ số gốc, dòng phụ, đồ Cam, bộ, "Mặc vào: Lực chiến ±N"; tab Bán đồ: lưới túi 7 cột + bán nhanh theo bộ lọc, khung phải hiện món chọn + giá bán + nút Bán. Xưởng Rèn và thợ rèn chuyển sang Lò Rèn (UI-25). Thành phần dùng chung: `ui/shop_widgets.gd` | ✅ UI-24 |
| UI-25 | *(Spec_Notes đợt 8: "Cường hoá: không show mỗi lần cường hoá hết bao nhiêu tiền (nguyên liệu)"; "Xưởng rèn nên tách ra khỏi shop")* **Lò Rèn riêng** (`ui/forge_panel.gd`, phím **R**, nút "Lò Rèn" ở Cửa hàng và ở chi tiết món trong Túi đồ, nói chuyện **Thiết Ngưu** mở thẳng tab Luyện). Tiêu đề + ô Vàng / Đá Cường Hoá / Tinh Kim; 4 tab dọc: **Cường hoá** — chọn món (8 ô đang mặc + túi), khung giữa: +N ➜ +N+1, chỉ số gốc trước ➜ sau, thanh tỉ lệ (ghi phần Thiên phú cộng), **"Chi phí lần này"** là các ô icon *cần* + *có N* (thiếu thì viền và số đỏ, chú thích ghi số thiếu), nút "Cường hoá +N", lý do khoá; cột phải **bảng chi phí mọi cấp** +0→+15 (tỉ lệ, vàng, đá, Tinh Kim; cấp hiện tại tô vàng) + tổng chi phí lên +15. **Chế tạo** — Xưởng Rèn (chưa xây thì ghi giá xây): 8 thẻ ô trang bị, tỉ lệ phẩm chất, ô chi phí, nút Chế, dòng "Vừa chế". **Luyện nguyên liệu** — Thiết Ngưu (chỉ ở 2-1: 10 Đá → Đá Cường Hoá, 20 Đá + 10 Sắt → Tinh Kim), Thương hội Kim Luân (vùng 5: 5 Tinh Thạch → Tinh Kim); mỗi công thức có nút Luyện và Luyện hết (N). **Phân rã** — phân rã nhanh theo bộ lọc. Túi đồ: khối cường hoá đổi sang tiêu đề "+N → +N+1 · Tỉ lệ" + cùng các ô chi phí cần / có. Công thức chi phí, tỉ lệ không đổi | ✅ UI-25 |
| UI-26 | *(Chủ dự án 28/10/2026, kèm ảnh mẫu: "Mục chỉ số thì cần design lại theo hướng như ảnh")* **Thẻ thuộc tính kiểu mới** ở tab Chỉ số (`ui/stats_page.gd`): mỗi thuộc tính một thẻ — icon lớn trong khung viền vàng · tên (vàng) · nhãn **👑 Thuộc tính chính** (theo `Classes.DEFS.main`, thẻ viền sáng hơn và **xếp lên đầu** theo thứ tự trong `main`, ví dụ Thợ Săn DEX rồi AGI) · **"Tăng mỗi điểm:"** liệt kê **mỗi tác dụng một dòng** (sinh từ hằng số `Stats` theo lớp) · cột **Tổng** (số lớn, dòng nhỏ "(N cơ bản + M điểm cộng [+ K cướp])", cơ bản = khởi tạo lớp + tự tăng theo cấp) · nút tròn **?** (rê chuột: thuộc tính đang cho bao nhiêu + tác dụng mỗi điểm) · nút **+** vuông viền vàng. Danh sách thẻ cuộn được; Tẩy điểm / Tự cộng điểm giữ nguyên. Trang bị chưa cộng thuộc tính nên không có phần "+ trang bị" như ảnh mẫu. Công thức không đổi. **UI-26b** *(góp ý người chơi 28/10: phân biệt rõ chỉ số gốc và chỉ số cộng thêm)*: dòng tách nguồn tô màu riêng từng phần — gốc trắng thường, **+ điểm cộng** xanh lá sáng in đậm (xám khi bằng 0), **+ cướp** đỏ in đậm; sau này có thuộc tính từ trang bị / hào quang thì thêm phần màu riêng cùng chỗ. **UI-26c** *(chủ dự án 28/10: "bị vỡ thiết kế", "thứ tự thông tin các class khác nhau → thống nhất")*: **thứ tự thẻ cố định cho mọi lớp** STR · VIT · AGI · INT · WIS · DEX · LUK (thuộc tính chính chỉ đánh dấu bằng nhãn + viền, không đổi chỗ); nhãn Thuộc tính chính nằm cùng dòng với tên; **mọi thẻ cao bằng nhau** — luôn đúng 3 dòng tác dụng (thiếu thì dòng trống, thừa thì gộp dòng cuối bằng " · ", bản đầy đủ ở tooltip nút ?); Triệu Hồi Sư INT ghi "+0,45 Tấn công (cả linh thú)". Sửa vỡ bố cục: khung bộ đồ ở cột trái nay **cuộn trong phần còn lại của cột** — mặc 2–3 bộ không còn đẩy cả bảng cao quá cửa sổ và che nút Tẩy điểm / Tự cộng điểm | ✅ UI-26 |
| UI-27 | *(Chủ dự án 28/10/2026, kèm ảnh mẫu bảng Nhân vật: "Design lại Inventory → cắt ảnh giữ nguyên để đưa vào game?" → chọn "dùng trang trí từ ảnh")* **Bảng Nhân vật dùng trang trí cắt từ ảnh mẫu** (`tools/art/ui_cut.py` → `assets/ui/`, D64): khung 3 cột (viền vàng, góc hoa văn chữ X), hàng thuộc tính viền vàng, 7 icon thuộc tính vẽ, nhãn 👑 Chính, nút **i** tròn, nút **+** vuông, nút vàng, nút tối, biển **Lực chiến** (cánh + kiếm), ô **Điểm thuộc tính** (cánh), cảnh kiếm cắm đất. Chữ / số in sẵn trong ảnh được xoá; game in chữ thật đè lên. Tab Chỉ số theo bố cục ảnh: tiêu đề "Thuộc tính" + nút i + ô Điểm thuộc tính; **7 hàng gọn** STR · VIT · AGI · INT · WIS · DEX · LUK (icon · mã + tên · nhãn Chính · tổng + dòng nhỏ "gốc +cộng" tách màu UI-26b · nút i: tác dụng mỗi điểm + đang cho bao nhiêu · nút +), đủ 7 hàng không cuộn ở 1366×768; dưới: nút vàng **Phân bổ tự động**, ô chọn mẫu, **Tẩy điểm** + "Miễn phí trước cấp 30"; cột phải: biển Lực chiến (số có dấu chấm ngăn nghìn), Chỉ số chiến đấu, câu trích theo lớp + cảnh. Cột trái nhân vật dùng cùng khung. **Không cắt** chân dung, ô trang bị, chữ/số (phải thay theo nhân vật). Chưa làm theo ảnh: thanh tab trên (Trang bị / Kỹ năng / Thiên phú / Danh hiệu + vàng / kim cương), khung bộ đồ dạng thẻ nhỏ + "Xem chi tiết" | ✅ UI-27 |
| UI-28 | *(Chủ dự án 30/10/2026, kèm ảnh thanh tiêu đề: "sửa lại giống ảnh, màu sắc, khoảng cách, focus")* **Thanh tiêu đề bảng Nhân vật theo ảnh mẫu** (mảnh cắt `tools/art/ui_cut.py` từ `tools/art/src/ui-topbar-mockup.png`): nút **quay lại** (đóng bảng) · ô **"Nhân Vật"** chữ vàng · **tab chữ** Thuộc tính · Trang bị · Tài nguyên · Kỹ năng · Thiên phú, rộng đều 127 px, ngăn bằng vạch mảnh; tab đang chọn: nền vàng sáng dần + hình thoi dưới, chữ trắng ngà; tab khác chỉ chữ màu be, rê chuột hiện nền vàng mờ; **Kỹ năng / Thiên phú** đóng bảng và mở bảng riêng (U / T) · **Vàng** + **Tinh Thạch** (icon đồng vàng / viên đá xanh, số có dấu chấm) · nút **+** (mở tab Tài nguyên) · nút **X**. Bỏ chữ "(C)", "(I)", "· +N", "N/30" và ô Lực chiến gọn ở thanh (phím tắt và số ô túi chuyển vào tooltip; điểm chưa cộng xem ở ô Điểm thuộc tính, số ô túi ở khung Túi đồ). Khung vẽ dùng cho cả 3 cột ở mọi tab. Chưa có tab **Danh hiệu** (chưa có hệ Danh hiệu); ảnh mẫu dùng dấu phẩy ngăn nghìn, game dùng dấu chấm theo tiếng Việt. **UI-28b** *(chủ dự án 30/10: "nhấn Kỹ năng, Thiên phú thì không có chỗ quay lại Thuộc tính, Trang bị, Tài nguyên")*: bảng **Kỹ năng** (U) và **Thiên phú** (T) dùng **cùng thanh tiêu đề** (`ui/char_bar.gd`) — từ bảng nào cũng chuyển được sang 4 tab còn lại; Thiên phú đặt trong khung vẽ. **UI-28c** *(chủ dự án 30/10: "tab Thiên phú trình bày lại cho gọn trên 1 page, đang phải cuộn")*: tab Thiên phú **3 cột, không cuộn** — trái **Thiên phú** (thẻ: icon, hạng, tên, nhóm · cấp · tiến hoá, mô tả; kỹ năng L; trạng thái riêng như thú cưng, Đạo Tặc — Sổ Đạo Tặc chỉ hiện 6 loài cướp nhiều nhất); giữa **Hiệu ứng theo cấp** (cấp hiện tại → cấp kế màu xanh, +% Tấn công / HP, mốc cấp 5 / 10, Tinh Hoa, nút vàng Luyện cấp, lý do khoá); phải **Cây tiến hoá** (các bậc, điều kiện, nút Tiến hoá). **UI-28d** *(chủ dự án 30/10: "chưa thấy điểm nổi bật của cấp thiên phú")*: trong thẻ có **khối cấp** — "CẤP" + số cấp lớn vàng + "/ 10", nhãn "Cấp kế: N" (hoặc **TỐI ĐA** vàng khi đủ cấp), **10 ô tiến độ** tô màu hạng, ô mốc 5 / 10 viền vàng (mốc mở hiệu ứng phụ) | ✅ UI-28 |
| CL1-01…06 | *(chủ dự án 27/10: "làm theo docs/charactors.md", duyệt mặc định Q130–Q139)* **Thiết kế lại 3 lớp đang có** theo [21](21-thiet-ke-lai-5-lop.md) mục 2–4, số liệu ở mục 10.1: (01) Kiếm Khách — Trảm Phong, **Kiếm Ý** thay Thiết Bích, **Nguyệt Ảnh Liên Trảm**, Vạn Kiếm 800%, chí mạng nền 8%; (02) Thợ Săn — Vũ Tiễn, **Xuyên Tâm Tiễn** (xuyên 3 quái), **Lộn Nhào** (+50% né tránh 3 s) mở cấp 4, Bẫy Gai xuống cấp 22; (03) Pháp Sư — Sét Chuỗi, **Băng Lao** thay Băng Ngục ở cấp 1, Băng Ngục thay Dịch Chuyển ở cấp 22, **Thiên Tai Nguyên Tố**, phòng thủ nền ×0,8; (04) save cũ chuyển điểm kỹ năng bị thay; (05) cân bằng lớp giữ ≤ 25%; (06) CL2 — sửa docs/19 cho Hộ Vệ, Triệu Hồi Sư. CL1b: Băng Lao làm chậm 50% (mức riêng), Thiên Tai Nguyên Tố 3 đợt 3 hệ Hỏa / Thủy / Kim, vệt chém + kiếm khí Kiếm Khách đỏ; icon kỹ năng và sprite theo bộ hình của chủ dự án (phiên game-5f) | ✅ CL1 (06: spec ✅, code chờ game-c6) |
| SN9-01…09 | *(Spec_Notes đợt 9, chủ dự án 28/10: "triển khai các công việc chưa làm trong spec_notes")* Spec riêng [25](25-spec-notes-dot-9.md): tên + chức nghiệp trên khung nhân vật và trên đầu; **5 ô nhân vật** (màn Chọn nhân vật, xoá phải gõ lại tên, tên không trùng); số sát thương "-N" + màu theo loại (khắc hệ cam + chữ "Khắc", thiêu, độc); thú cưng / lính bóng / Xương Nô lao trước (32 m, chạy 320), Tự đánh chờ thú áp sát; EXP theo chênh cấp (bảng mượt, giữ +5 → ×2, −10 → 10%); **bãi quái theo cấp** (mỗi cấp 1 bãi, 75% quái sinh trong bãi, chấm trên bản đồ nhỏ); "+9 + 15 Tấn công (gốc)"; dòng tăng chỉ số khi lên cấp; **khung mục tiêu** (chân dung, thanh máu, Phá Thế, trạng thái) + vòng vàng dưới chân quái | ✅ SN9-T2…T9 |
| R1-01…07 | *(chủ dự án 27/10: "phần này có thể đưa vào làm trước" — 7 lỗi thấy trong ảnh chụp rà soát [19-ra-soat](19-ra-soat-de-xuat.md) mục 0)* (01) Icon kỹ năng tràn thẻ lớp ở màn tạo nhân vật — **đã hết** nhờ UI-22 (thẻ lớp chỉ hiện 4 kỹ năng). (02) Hiệu ứng "+N!" khi cường hoá ở Túi đồ đặt trên **chân dung nhân vật** (cột trái) thay vì toạ độ cố định đè cột chi tiết (Lò Rèn giữ chỗ riêng). (03) Màn chiến thắng nền tối 0,82 → **0,95** — chữ "Lên cấp", Bí Kíp, số sát thương phía sau không lộ qua. (04) Bấm kỹ năng chưa mở: nhật ký báo **1 lần mỗi kỹ năng**, lần sau chỉ chữ nổi "Cấp N" trên đầu (trước: 1 dòng mỗi 1,5 giây). (05) Khung nhiệm vụ: mọi số ≥ 5 chữ số có dấu chấm (`Hud.group_numbers`, "100.000 EXP"). (06) Bí Kíp chỉ rơi cho kỹ năng **đã mở**; chưa có kỹ năng nào hợp lệ → 1 Mảnh Bí Kíp. (07) Khi có thanh máu boss: khung nhiệm vụ thu về tiêu đề + 1 dòng, mờ 70%; bản đồ nhỏ mờ 35% — không che đấu trường phía đông | ✅ R1 |
| CS-01…08 | *(góp ý người chơi 28/10 "chỉ số các lớp giống nhau"; chủ dự án 28/10 "triển khai theo đề xuất mới")* Spec [26](26-build-lop.md) (gộp [24](24-de-xuat-chi-so-lop.md) + [CR-001](CR-001-He-so-thuoc-tinh-co-ban.md)): (01) **7 thuộc tính** STR · AGI · VIT · INT · **WIS** · **DEX** · LUK, khởi tạo + tự tăng mỗi cấp theo CR-001; (02) phần gốc theo cấp + hệ số quy đổi theo lớp, Tấn công chỉ từ thuộc tính chính; (03) đặc tính lớp: Kiếm Khách +15% tốc chạy, +10% né, ST chí mạng ×1,7, **Kiếm thế**; Thợ Săn +15% chí mạng, +10% xuyên giáp, **Thân pháp**, chí mạng vượt trần → ST chí mạng; Pháp Sư +20% sát thương kỹ năng, +15% xuyên giáp; Hộ Vệ Phòng thủ ×1,3, kháng hiệu ứng 25%, Khiêu Khích +20% bán kính; Triệu Hồi Sư linh thú +20% HP, tối đa 3 linh thú chủ lực, **Gắn kết**; (04) DEX: xuyên giáp + sát thương vào thanh Phá Thế; WIS: hồi MP + kháng 5 hệ; (05) tốc chạy theo lớp 265 / 250 / 220 / 210 / 220; (06) 3 build mỗi lớp ở nút Tự cộng điểm (gợi ý theo nhánh chức 2); (07) trang Chỉ số 7 thẻ "khởi tạo + tự tăng + điểm cộng", màn chọn lớp hiện 7 thuộc tính khởi tạo; (08) save v19 tẩy điểm miễn phí 1 lần | ✅ CS-T1…T4 |
| SN10-01…02 | *(Spec_Notes đợt 10, chủ dự án 30/10)* Spec [28](28-spec-notes-dot-10.md): (01) kết quả cường hoá hiện **giữa màn hình** ("CƯỜNG HOÁ THÀNH CÔNG" + tên món +N / "CƯỜNG HOÁ THẤT BẠI" + "Mất nguyên liệu · món đồ vẫn +N"), dùng chung Túi đồ và Lò Rèn, không chặn chuột; (02) **bình MP**: phím F hồi 40% MP, hồi chiêu riêng 8 giây, không giới hạn số bình, cửa hàng 30 vàng, rơi từ quái 3% / tinh anh 25% / boss 1 bình (RNG riêng), ô thứ 9 trên thanh kỹ năng, save v22 | ✅ SN10-T1, T2 |
| SN11-01…03 | *(Spec_Notes đợt 11, chủ dự án 31/10; map: chọn "Diện tích ×3")* Spec [30](30-spec-notes-dot-11.md): (01) rê chuột vào **đồ đang mặc** hiện thẻ thông tin "ĐANG MẶC"; (02) rê chuột vào **món trong túi** hiện 2 thẻ [ĐANG XEM + so sánh ▲ xanh / ▼ đỏ từng chỉ số và Lực chiến][ĐANG MẶC], khung chi tiết có "So với đang mặc:"; (03) **bản đồ ×3 diện tích** (×√3 mỗi chiều, 1-1: 7205 × 4434), trần quái thường 120 (mật độ giữ nguyên), bãi quái tối đa 10, cây / thảo dược / rương ×3, bán kính làng / hang giữ nguyên, hang phụ giữ nguyên; save v23 phủ sương lại | SN11-T1/T2, SN-T5, C3…C7-T1 ✅ |
| SN12-01…02 | *(Spec_Notes đợt 12, chủ dự án 01/11; thanh kỹ năng: chọn "phương án A" + 4 tiện ích)* Spec [31](31-de-xuat-thanh-ky-nang.md): (01) **bình máu không giới hạn** (bỏ trần 5; thảo dược đủ 2 tự chế 1 bình); (02) **thanh kỹ năng 7 ô** — ô 5 khi chuyển chức 1, ô 6 khi chuyển chức 2, ô **Tuyệt kỹ (G)** cấp 45 chỉ Tối thượng / Thần Kỹ, ô chưa mở ẩn; **báo + tự lắp kỹ năng mới**; **đổi ô ngoài giao tranh** (5 giây); **kéo-thả** từ cây kỹ năng vào hàng Thanh kỹ năng, **chuột phải** ô HUD chọn nhanh; **2 bộ kỹ năng** (phím X); hồi chiêu đi theo kỹ năng; save v27 | C1-T10, UI-24, SN12-T1/T2 ✅ |
| CB-31 | *(01/11, sau SN12-02)* **Cân bằng 7 ô**: đo bộ 7 ô so với 4 ô ở Viêm Long cấp 60 — nhanh hơn 0–19% (Pháp Sư chậm hơn 12% vì MP) → giữ máu boss. **TL-J3**: Thần Kỹ Ngũ Hành Luân Chuyển ×0,6 → ×0,75 (Pháp Sư chức 3 nhanh hơn chức 2 8% → 16%, các lớp 16–19%) | SN12-T3, TL-J3 ✅ |
| RS-0111, AU, TL-B9b | *(01–02/11, chủ dự án chọn "cả 4 việc")* Báo cáo [32](32-ra-soat-01-11.md): sửa 7 lỗi giao diện từ rà ảnh smoke; nhạc nền riêng vùng 2–9 + boss vùng 7–9, âm kỹ năng theo lớp, Tối thượng, mở kỹ năng, tới map; Thần Vực: quái tháp HP ×1,14 / Tấn công ×1,05 mỗi tầng, Thần Tướng HP ×3 → bot 5 lớp tầng 14–19 | AU-T1, TL-B9b ✅ |
| SN13-01 | *(Spec_Notes 02/11: "Boss Thủy quái thất đầu bị lỗi không lên damage, không chém được")* Sửa: 7 đầu không mọc vì `update_enemy` chặn `update_rare`; đánh thân hiện "Miễn sát thương — chặt N đầu còn lại"; test chung 9 boss hiếm — [32](32-ra-soat-01-11.md) mục 5 | C4-T4, RB-T1 ✅ |
| SN14-01, SN14-02 | *(Spec_Notes 02/11)* Spec [31](31-de-xuat-thanh-ky-nang.md) mục SN14: **Hấp Huyết** uống được bình máu (bỏ hạn chế); **đổi kỹ năng trong bảng Kỹ năng** luôn được (bảng mở thì game dừng → khoá giao tranh 5 giây chỉ còn cho phím X / menu HUD lúc chơi) | TL-C, TP5-T2, SN12-T1 ✅ |
| SN15-01 | *(Spec_Notes 03/11: "Phượng Hoàng Tro đánh chết không bị mất")* Sửa: trứng Niết bàn không bao giờ nở (`update_enemy` chặn `update_rare`) → boss kẹt 1 HP, bất tử; nay nở sau 3 giây với 50% HP, lần hạ thứ hai gục hẳn. Người chơi gục → boss hồi đầy và có lại Niết bàn — [32](32-ra-soat-01-11.md) mục 6 | C5-T4 ✅ |
| SN16-01 | *(Spec_Notes 05/11: "triệu hồi chưa xuất hiện xong đã chạy ra đánh")* Linh thú / Xương Nô vừa gọi **hiện hình 0,5 giây** (đứng yên trong vòng trận, mọc lên từ đất, chưa đánh, chưa bị quái nhắm, chưa trừ thời gian tồn tại) rồi mới lao ra; nghi thức FX-1 rút 0,9 → 0,7 giây, cột sáng tắt đúng lúc linh thú lao ra. Linh Hồ thường trực không chờ — [36 §9.15](36-thiet-ke-lai-vfx-ky-nang.md) | SN16-T1, SH-T1 ✅ |
| BOSS-T1 | *(04/11 chủ dự án: "test lại 1 lượt các boss ở tất cả các map")* Quét **50 boss** qua vòng chơi thật (9 boss vùng, 9 boss hiếm, Chúa Hang 26 map, Chúa Cổng E…S): tất cả gục và rời danh sách quái. Sửa: đẩy lùi đưa **Chúa Hang Nấm Mẹ** (hang 1-1, 1-3) ra ngoài mép hang → đánh không tới; quái nay luôn giữ trong mép bản đồ — [32](32-ra-soat-01-11.md) mục 7 | BOSS-T1 (`--only=BOSS`) ✅ |
| NV-A1…A6 | *(Spec_Notes 05/11 "nhiệm vụ chưa rõ ràng"; chủ dự án chọn làm P1–P4)* Spec [41](41-de-xuat-nhiem-vu.md): mỗi bước nhiệm vụ chính có điểm mục tiêu — **mũi tên vàng quanh nhân vật + khoảng cách**, vòng vàng tại mục tiêu, chấm trên bản đồ nhỏ, chỉ cổng khi mục tiêu ở map khác; **"!" trên NPC** cần gặp; **Sổ nhiệm vụ (O)**; bấm khung nhiệm vụ → tự chạy tới / mở bảng cần dùng; dải chữ khi xong bước; gợi ý không còn dạng "N → …" | NVA-T1 ✅ |
| NV-D | *(Spec_Notes 05/11 "nhiệm vụ quá ít")* [41](41-de-xuat-nhiem-vu.md) P2: **Uỷ thác hằng ngày** — 3 việc / ngày (săn loài quái của vùng, tinh anh, hang phụ, cổng dungeon, thảo dược), nhận thưởng ở khu an toàn (EXP + Đuốc + Điểm Uỷ Thác), đủ 3 việc: rương ngày + chuỗi ngày, 7 ngày: món Tím; đổi 1 việc / ngày; cửa hàng điểm; ghim lên HUD | NVD-T1 ✅ |
| NV-C | *("không thu hút")* P3: **27 chuỗi nhiệm vụ phụ** do NPC sẵn có giao, "!" / "?" trên đầu NPC, chọn 1 trong 3 phần thưởng, 9 danh hiệu hiện trên tên | NVC-T1 ✅ |
| NV-B, NV-E | *("đơn điệu")* P4: 8 bước "hạ 30 quái" của chính tuyến → tinh anh có tên / tìm dấu vết / nhặt vật rơi / giữ điểm qua 3 đợt; **sự kiện trên đường** mỗi ~5 phút (phục kích, người sống sót, rương bị canh, tinh anh đi lạc) | NVB-T1, NVE-T1 ✅ |
| PF-01 | *(04/11 người chơi: "di chuyển giật giật, không mượt")* Hiệu năng: game chạy ~20 khung/giây → **~60** (có quái ngoài đồng ~43). Mảng loang nền đất vẽ 1 texture; HUD đồng (thanh kỹ năng, cụm nút, thanh EXP, khung nhân vật, vành bản đồ nhỏ) nướng phần tĩnh thành ảnh, chỉ vẽ lại khi dữ liệu đổi; chỉ vẽ quái / vật trong khung nhìn; sương cập nhật theo vùng ô vừa mở — [32](32-ra-soat-01-11.md) mục 8 | `tests/perf_walk.gd` (đo tay), UI41-T1, M5-T6 ✅ |
| BD11-01…09, KP-10, NV-23 | *(02/11, chủ dự án "triển khai theo đề xuất")* Spec [34](34-dungeon-cong-ngau-nhien.md): **Dungeon cổng ngẫu nhiên** — từ cấp 6, mỗi 5 phút chơi 50% mở cổng hạng E 40 / D 28 / C 18 / B 9 / A 4 / S 1% trên map đã tới (tối đa 2, mỗi map 1), tồn tại 2 giờ chơi; trong cổng: khung hang phụ, 3 khu quái + Chúa Cổng, cấp −3…+8 so với map cha, HP / tấn công / số quái theo hạng; dọn → EXP thưởng (NV-23), đồ (E Xanh dương … S Cam), Tinh Hoa; dọn sương 1 ô 7% lộ cổng (KP-10); save v29 | BD11-T1…T3 ✅ |
| UI-40 | *(Spec_Notes 02/11 "giao diện pixel quá, người chơi muốn đẹp"; 03/11 chủ dự án chọn Q176 = B, Q177 = cel-shade)* Spec [35](35-de-xuat-giao-dien-moi.md): hình **HD vector cel-shade** sinh bằng code (vẽ ×4 siêu mẫu, viền tối mềm, bóng cel), thay dần qua lớp phủ `hd` của manifest; bản thử G0: Sói Sương, Sói Chúa Hư Vô, cảnh Rừng Sương (cỏ, đất, 3 cây, thông, bụi, 2 đá, cỏ cao), 10 icon; Cài đặt → "Đồ hoạ HD" bật / tắt | UI40-T1 ✅ |
| UI-40b | *(03/11 chủ dự án: "khu vực thôn xấu quá, cần design lại cho giống thực tế")* Làng Thanh Thạch HD ([35 §9](35-de-xuat-giao-dien-moi.md)): 4 nhà gỗ (ngói xám đầu đao + đèn lồng, ngói đỏ, 2 mái tranh), sân đất nện mép lượn tự nhiên + sân lát đá quanh bia, hàng rào cọc gỗ làm ranh giới vùng an toàn (chừa cổng đông, lối nam), giếng, thùng hàng, 2 cột đèn lồng, ngoài rào 3 luống rau + đống rơm; Cổng Dịch Chuyển cố định ở khoảng trống đông nam. Nhà / đồ không chặn đường; tắt HD thì vẽ như cũ | UI40b-T1 ✅ |
| UI-41 | *(03/11 chủ dự án gửi ảnh mẫu, chọn 6 phần)* Giao diện "đồng chạm khắc" ([35 §11](35-de-xuat-giao-dien-moi.md)): mọi khung viền đồng chạm khắc + ngọc góc + nền xanh rêu + chữ tiêu đề vàng kiểu cổ (Cormorant SC); thanh kỹ năng ô vuông viền màu theo hệ, phím treo dưới ô, đầu rồng 2 bên + huy hiệu sư tử; thanh EXP tím dài dưới đáy; cụm nút góc phải (Đánh tròn lớn + Q, F, L, Space, Z) bấm / chạm được, kiểu mobile; bản đồ nhỏ la bàn tròn lấy nhân vật làm tâm, N/E/S/W, nút +/−, V = toàn bản đồ; nhiệm vụ trên cuộn giấy da có dấu sáp + thanh tiến độ "(a/b)" | UI41-T1, M5-T6 ✅ |
| UI-41b | *(03/11 chủ dự án: cụm nút góc phải "lỗi, xấu")* Vẽ lại cụm nút: 5 nút nhỏ cách đều trên dải nền vòng cung viền đồng, nhãn phím hướng ra ngoài (không đè nút bên), số bình trong nút, nút Z "Z · BẬT/TẮT" không bị cắt mép, chú thích khi rê chuột | UI41-T1 ✅ |
| UI-41c | *(03/11 chủ dự án gửi ảnh concept cụm nút)* Vẽ lại theo concept: nút Đánh vòng thép + vành đồng có gai, 4 nút màu lớn trên vòng cung rộng với đốm sáng vàng giữa các nút, nút Z màu đá trên cánh tay đồng cong ([35 §11](35-de-xuat-giao-dien-moi.md)) | UI41-T1 ✅ |
| UI-41d | *(03/11 chủ dự án: icon Đánh, bình máu, bình MP, Space… "xấu quá")* Bộ icon HD riêng cho cụm nút (cách làm icon HD UI-40, quầng sáng + lấp lánh như concept): nút Đánh theo lớp, 2 bình thuốc, Né, Tự đánh ([bảng icon](design/ui-cluster/icons.png)); icon kỹ năng gốc không đổi | UI41-T1 ✅ |
| UI-50…56 | *(04/11 chủ dự án: "Do as your propose" — rà soát [38](38-ra-soat-giao-dien-theo-tieu-chi.md) đợt 1)* Cỡ chữ tối thiểu 11 px; chữ nổi không chồng + dải nhặt đồ bên trái; tên quái "thông minh"; nhật ký 3 dòng, combo nhỏ cạnh cụm nút; viền đỏ máu thấp; thanh tài nguyên 1 hàng; khung chân dung tông đồng | UI38-T1 ✅ |
| UI-57…61 | *(đợt 2)* Màn tiêu đề cảnh nền vẽ bằng code + logo, bỏ bảng phím; chọn nhân vật / kết chương / kết thúc / danh đề khung đồng; chọn lớp vừa cửa sổ; Cài đặt 4 tab có đổi phím trong game + Trợ năng | UI38-T1 ✅ |
| UI-62, 63 | *(đợt 3)* Nút khoá dễ thấy + lý do; biểu tượng hệ trên ô kỹ năng, chấm phẩm chất trên ô đồ, bảng màu mù màu; rìa sương mềm | UI38-T1 ✅ |
| UI-40c | *(03/11 chủ dự án: "các map khác cũng xấu và giả tạo")* Mọi map ([35 §10](35-de-xuat-giao-dien-moi.md)): khu an toàn theo chủ đề vùng — sân mép lượn, rào riêng (cọc gỗ / tường đá / cọc tre / cọc sắt / trụ cẩm thạch / cọc tinh thể / trụ ngọc), 2–3 nhà (lều, chòi canh, nhà sàn, lò rèn, nhà gỗ tuyết, đình, miếu), đồ vật giữa / quanh sân; Thành Biên Đài: nhà vách trát mái ngói, tháp đá, sân cuội; 18 nền + ~40 cảnh vật HD cùng kích thước bản pixel; Cổng Dịch Chuyển ở khoảng trống | UI40b-T1 ✅ |
| AR-45d | *(chủ dự án 03/11: thay ảnh skill theo docs/design/skills/kiem-khach, trừ 4 kỹ năng chính; rồi "các skill khác trông không giống ra chiêu trong game")* **AR-45d (03/11/2026, thay AR-45c):** 10 kỹ năng Kiếm Khách (Xoáy Kiếm, Đột Kích, Hống Kiếm, Kiếm Vũ, Phi Kiếm, Thánh Kiếm Trảm, Kiếm Vực, Huyết Bạo, Huyết Ảnh, Nhất Kiếm Khai Thiên) **dàn dựng chuyển động theo cơ chế thật** bằng chính các mảnh hình gốc mà bộ review `docs/design/skills/kiem-khach` ghép từ master sheet (trăng khuyết Trảm Phong, vụ nổ Kiếm Ý, thanh kiếm Vạn Kiếm): Xoáy Kiếm 4 trăng khuyết xoay 2 vòng nở ra 12,5 m; Đột Kích / Huyết Ảnh vệt trăng khuyết theo đường lao thật; Hống Kiếm / Huyết Bạo tụ lực rồi nổ + 8 trăng khuyết toả ra đủ bán kính; Kiếm Vũ 4 kiếm bay quanh 2 giây + nhát chém mỗi nhịp; Phi Kiếm / Thánh Kiếm loé lực ở mũi kiếm (kiếm bay vẽ như đạn); Kiếm Vực vòng vực đi theo người, 8 kiếm cắm quanh mép, kiếm rơi cắm xuống mỗi nhịp 0,5 giây (trước đây bị vẽ nhầm thành Mưa Băng); Nhất Kiếm tụ lực 0,5 giây rồi chuỗi trăng khuyết chạy dọc vệt chém 40 m. AR-45c (3 ảnh tĩnh của storyboard dán cạnh nhân vật) đã gỡ vì chủ dự án thấy "không giống ra chiêu trong game". Trảm Phong, Kiếm Ý, Nguyệt Ảnh Liên Trảm, Vạn Kiếm Quy Tông giữ hình cũ | AR45d-T1 ✅ |
| TP5-01…05, TP13-01…02, TP44-01, TP14-01…02 | *(02/11, chủ dự án chọn 4 phương án đề xuất)* Spec [33](33-thien-phu-phu-cong-huong.md): **Thiên phú phụ** — ô 2 / 3 mở khi chuyển chức 1 / 2, Lễ Thức Tỉnh ô phụ (quay như lễ đầu, không trùng, không Đạo Tặc), cấp riêng 1–10 luyện ở Đền, chỉ bị động (L dùng kỹ năng phụ khi chính bị động); **cộng hưởng** cùng nhóm +10% + 9 cặp đặc biệt (Thợ Săn Di Tích, Huyết Chiến Thần, Liên Hoàn Kiếm, Bất Khuất, Phú Quý, Luyện Kim Sư, Long Đế, Chúa Tể Bầy Đàn, Lữ Khách Thiên Mệnh), "???" tới khi kích hoạt; **tẩy** bằng Nước Thánh Tinh Quang (giữ 50% cấp, mất tiến hoá); save v28 | TP5-T1/T2, TP13-T1, TP14-T1 ✅ |
| HP-01…10 | **Hang phụ trong từng map** — chủ dự án chọn hướng 1 ("làm theo đề xuất"). Spec riêng: [15-hang-phu.md](15-hang-phu.md) | SN6-T4, T5 ✅ |
| CB-30 | **Quái áp sát nhanh hơn** (góp ý *"cung, pháp sư thả diều được, không công bằng"*) — chỉ quái thường + tinh anh, boss / boss hiếm giữ nguyên: đuổi ×1,25; quái cận chiến (không phải hệ "xa"/"phép") đuổi tối thiểu **165**/giây (người chơi 230); bị đánh từ xa hơn 150 → **Truy kích** ×1,5 trong 1,5 giây và đang lang thang thì đuổi ngay; tầm phát hiện 260 → **330**, bỏ đuổi 560 → **700** | Test cũ (TL-B…, PACE) ✅ |


## 9. Đợt M6 (Alpha) — Chương 3 Sa Mạc Lãng Quên

Spec riêng: [10-chuong-3.md](10-chuong-3.md) — vùng 3 Sa Mạc Xích Sa (C3-01…03), môi trường sa mạc (C3-10…13), quái vùng 3 (C3-20…25), Bọ Cạp Sa Hoàng, Nhân Sư Đá, đồ/bộ vùng 3, Độn Thổ (C3-30…35), cốt truyện + chuyển chức 1 (C3-40…44), save v9, test C3-T1…T6, TL-B3.

Thay đổi so với spec các đợt trước:

| Mục cũ | Thay đổi ở M6 |
| --- | --- |
| 5.3 — AGI +0,5% chí mạng, SN-07 — Thợ Săn +0,6% tốc đánh/AGI | Thợ Săn: +0,25% chí mạng/AGI, tốc đánh từ AGI tối đa +20% (TL-B3) |
| TL-S6 / M3 — Bộc Phá theo Mưa Tên +100% | Mỗi đợt Mưa Tên chỉ +60% (tổng thêm bằng Xoáy Kiếm) |
| Thông báo gục / boss rút về / Phá Thế ghi cứng "Làng Thanh Thạch", "Sói Chúa" | Lấy tên vùng an toàn và tên boss của map hiện tại |

## 10. Đợt M7 (Alpha) — Chương 4 Đầm Lầy Mộng + tiến hoá Thiên phú

Spec riêng: [11-chuong-4.md](11-chuong-4.md) — vùng 4 (C4-01…03), môi trường đầm lầy (C4-10…12), quái vùng 4 (C4-20…25), Nữ Vương Phệ Mộng, Thuỷ Quái Thất Đầu, đồ/bộ vùng 4, Mộng Cảnh (C4-30…35), cốt truyện Lam Nhi + tiến hoá Thiên phú lần 1 (C4-40…45), save v10, test C4-T1…T6, TL-B4. Kiến trúc: bộ điều phối chương `core/chapters.gd` (D38) — chương 5 (M8, [12](12-chuong-5.md)) gắn vào cùng cách.

Thay đổi so với spec các đợt trước:

| Mục cũ | Thay đổi ở M7 |
| --- | --- |
| TP-41 — Lv tối đa 10 | `talent_level` thành cấp hiệu dụng (tối đa 28); Lv hiển thị = cấp hiệu dụng − 9 × số lần tiến hoá (D39) |
| Phím Q = bình máu | Phím Q ưu tiên vật phẩm chương: Thuốc Giải (≥ 3 tầng độc), Đuốc Lửa (cạnh gốc đầu Thất Đầu) |

## 9. Spec_Notes đợt 5 (21/10/2026)

| Mã | Ghi chú của chủ dự án | Đã làm | Trạng thái |
| --- | --- | --- | --- |
| SN5-01 | *"Map: chỉ định vị trí hoặc nhấn vào vị trí thì nhân vật sẽ chạy đúng vị trí tương ứng trên bản đồ"* | Chuột trái lên **bản đồ nhỏ** (cỡ nhỏ hoặc cỡ lớn, phím V) → nhân vật **tự chạy thẳng** tới điểm đó; cờ vàng đánh dấu điểm đến trên bản đồ nhỏ và trong thế giới. **Huỷ** khi: tới nơi (≤ 2,4 m), người chơi tự di chuyển hoặc né lăn, chuột phải lên bản đồ, gục, đổi map, hoặc **kẹt** (không gần thêm được trong 1,5 giây — tường sương, cổng, hang boss khoá). Đang tự chạy thì Tự đánh nhường (như khi tự di chuyển). Bấm chuột lên bản đồ nhỏ không vung kiếm / dùng kỹ năng | ✅ |
| SN5-10 | *"Khi nhặt đồ: nếu nhiều đồ được nhặt cùng lúc, thì text đang bị đè lên nhau"* | Chữ nhặt đồ tách khỏi chữ sát thương: **xếp thành cột trên đầu nhân vật**, mỗi dòng cách 20 px, mới nhất ở dưới, tối đa 6 dòng, mờ dần sau 1,8 giây (đồ 2,4 giây). Vàng / Đá / HP nhặt liên tiếp trong 1 giây **gộp một dòng** ("+50 vàng"); mỗi món đồ một dòng riêng theo màu độ hiếm | ✅ |
| SN5-20 | *"Cần nghiên cứu kỹ về skills của từng hệ, đề xuất các hướng build skills…"* | Nghiên cứu thị trường + đề xuất: [13-he-ky-nang.md](13-he-ky-nang.md) — **mở theo cấp + chuyển chức (nền) + Bí Kíp rơi để mở biến thể + ngũ hành ở biến thể tầng II**; câu hỏi Q65–Q70 | 🟡 Chờ duyệt |

**Kiểm thử:** SN5-T1 (tự chạy: tới nơi, tự đi huỷ, kẹt sau tường sương, đổi map huỷ, toạ độ bản đồ nhỏ → thế giới), SN5-T2 (gộp vàng, mỗi món một dòng, tối đa 6 dòng, tự mất).

## Phụ lục A — Yêu cầu thay đổi (CR)

Thay đổi do chủ dự án yêu cầu sau khi kịch bản đã viết. Mỗi CR ghi nguồn, đề xuất, trạng thái duyệt, và đợt sẽ làm.

### CR-01 — Đạo Tặc (Ẩn): cướp thuộc tính + độc nhất server

| | |
| --- | --- |
| Ngày yêu cầu | 20/10/2026 |
| Yêu cầu của chủ dự án | *"SSS 'độc nhất server' → có làm. Thiên phú này đánh quái sẽ cướp thuộc tính của quái, cướp random loại thuộc tính để cộng vào nhân vật."* |
| Kịch bản gốc (mục 3) | Đạo Tặc (Ẩn), SSS, Đặc biệt: "Sao chép 1 kỹ năng boss sau mỗi lần hạ boss"; SSS "độc nhất server (tuỳ chọn)" |
| Trạng thái | Cướp thuộc tính **đã code ở M3** theo mặc định Q13–Q16 (03 mục 5.7, test TP-T3); số liệu vẫn chờ duyệt. Độc nhất server: Beta |
| Đợt | Cướp thuộc tính: **M3** (cần INT, LUK — NV-11, NV-12). Độc nhất server: **Beta** (cần backend — KT-09, KT-10) |

#### CR-01.1. Cướp Thuộc Tính (bị động, mới)

| Mã | Yêu cầu |
| --- | --- |
| DT-01 | Hạ quái có tỉ lệ cướp điểm thuộc tính (bảng nguồn); điểm cộng thẳng vào STR/AGI/VIT/INT/LUK của nhân vật |
| DT-02 | Loại thuộc tính chọn ngẫu nhiên theo bảng đặc trưng của loại quái |
| DT-03 | Giới hạn: tổng điểm cướp ≤ **cấp Thiên phú × cấp nhân vật** *(sửa 30/10/2026, Q169 — trước đây 1 × cấp)*. Thiên phú Lv1 = 1 × cấp, Lv10 = 10 × cấp; lên cấp Thiên phú ở Đền Thiên Phú cũng mở thêm chỗ |
| DT-04 | Điểm đã cướp được **giữ vĩnh viễn** (không bị thay, không bị tẩy). Đã đầy giới hạn thì không cướp thêm; lên cấp thì có chỗ cướp tiếp. Boss cho 3 điểm mà chỉ còn 1–2 chỗ thì chỉ nhận đủ số chỗ còn lại *(sửa 2026-10-30: trước đây đầy thì điểm mới thay điểm cũ nhất nên điểm cướp không cộng dồn)* |
| DT-05 | Quái thấp hơn nhân vật quá 5 cấp không cướp được; boss luôn cướp được |
| DT-06 | Điểm cướp lưu riêng (không lẫn với điểm tiềm năng), **không bị tẩy điểm**, hiện riêng trong bảng Chỉ số và bảng Thiên phú |
| DT-07 | Mỗi lần cướp hiện thông báo, ví dụ *"Cướp +1 AGI từ Sói Sương (12/15)"* |
| DT-08 | Giữ kỹ năng gốc: hạ boss thì sao chép 1 kỹ năng boss, dùng bằng phím L (đã làm ở M2, TP-39) |
| DT-17 | *(30/10/2026, Q170)* **Túi Tang Vật**: giới hạn DT-03 đã đầy thì điểm cướp vào túi chờ (tối đa **5**), không mất. Lên cấp nhân vật hoặc lên cấp Thiên phú có chỗ thì túi tự cộng vào (cũ trước), thông báo *"Túi Tang Vật: cộng +1 AGI vào nhân vật (16/16)"*. Boss cho 3 điểm lúc đầy thì lấp túi trước, phần dư sang DT-18 |
| DT-18 | *(30/10/2026, Q170)* **Đà Cướp**: không còn chỗ nào (túi đầy, hoặc loài đã cướp hết theo DT-19) thì mỗi điểm cướp trúng thành 1 tầng **+3% thuộc tính đó trong 30 giây** (làm tròn lên, ít nhất +1), tối đa **5 tầng**; tầng thứ 6 thay tầng sắp hết nhất. Tạm thời, không lưu save, không tính vào giới hạn |
| DT-19 | *(30/10/2026, Q170)* **Sổ Đạo Tặc** — trần theo loài: mỗi loài quái chỉ cướp được tới **5** điểm (quái thường và tinh anh cùng loài tính chung), **boss 9** (3 lần hạ), **boss hiếm 10** (2 lần hạ). Điểm vào Túi cũng tính vào sổ. Loài đã hết thì cướp trúng chỉ ra Đà Cướp. Bảng Thiên phú hiện: điểm cướp / giới hạn, Túi, Đà Cướp đang có, sổ "đã cướp N/54 loài" kèm từng loài *"Sói Sương 5/5"* |
| DT-20 | Save **v20**: `steal_bag` (Túi Tang Vật), `steal_log` {loài: điểm}. Save cũ: túi rỗng, sổ trống — điểm đã cướp trước đó giữ nguyên, chỉ tính vào giới hạn tổng |

**Bảng nguồn:**

| Loại quái | Tỉ lệ cướp khi hạ | Số điểm |
| --- | --- | --- |
| Quái thường | 3% | 1 |
| Quái tinh anh | 30% | 1 |
| Thủ lĩnh Ổ quái | 100% | 1 |
| Boss vùng | 100% | 3 |
| Boss hiếm (M5) | 100% | 5 |

**Bảng đặc trưng** (xác suất từng thuộc tính khi cướp; quái mới ở vùng sau phải thêm vào bảng này):

| Quái | STR | AGI | VIT | INT | LUK |
| --- | --- | --- | --- | --- | --- |
| Sói Sương | 35% | 50% | 15% | — | — |
| Nấm Độc | — | — | 45% | 35% | 20% |
| Tinh Linh Sương | — | 35% | — | 45% | 20% |
| Sói Chúa Hư Vô | 40% | 30% | 30% | — | — |
| Thủ lĩnh Ổ quái | theo loại quái gốc | | | | |

**Ước tính mức mạnh** (người chơi hạ khoảng 8 quái/phút, 6% là tinh anh → khoảng 25 điểm/giờ, luôn nhanh hơn tốc độ tăng giới hạn):

| Cấp | Điểm tiềm năng thường | Điểm cướp tối đa | Tấn công tăng khoảng |
| --- | --- | --- | --- |
| 5 | 20 | +5 (+25%) | +10% |
| 30 | 145 | +30 (+21%) | +15% |
| 100 | 495 | +100 (+20%) | +15% |

So với nguyên tắc kịch bản (F và S chênh ≤ 25%): Đạo Tặc mạnh hơn khoảng 15%, nằm trong biên độ, nhưng là Thiên phú duy nhất mạnh lên theo chỉ số thuần — chấp nhận được vì chỉ 1 người trên server có.

**Sau Q169–Q170 (30/10/2026):** giới hạn tổng = cấp Thiên phú × cấp nên ở Thiên phú Lv10 không còn là giới hạn thật (cấp 100: 1.000 điểm, gấp đôi 495 điểm tiềm năng). Giới hạn thật lúc cuối game là **Sổ Đạo Tặc**: 54 loài có bảng cướp (7 boss × 9, 3 boss hiếm × 10 trong đó), tổng trần khoảng **47 × 5 + 7 × 9 ≈ 300 điểm** nếu săn hết mọi loài — tức khoảng **+60% điểm tiềm năng**, vượt nguyên tắc 25%. Chủ dự án chấp nhận để Đạo Tặc là SSS mạnh hẳn; cần playtest cân bằng lại (giảm trần loài hoặc trần theo cấp Thiên phú) nếu quá mạnh, nhất là khi mã gift code `DT…` (GC-09) có thể tặng Đạo Tặc.

#### CR-01.2. Độc nhất server

| Mã | Yêu cầu |
| --- | --- |
| DT-10 | Server ghi **1 người giữ** Đạo Tặc duy nhất |
| DT-11 | Đã có người giữ: người khác quay trúng SSS được đổi thành 1 Thiên phú SS ngẫu nhiên, kèm câu *"Thiên Đạo đã chọn một người khác."* |
| DT-12 | Thông báo toàn server khi có người thức tỉnh Đạo Tặc |
| DT-13 | Người giữ không đăng nhập **30 ngày** hoặc xoá nhân vật → Đạo Tặc trở lại bể quay, thông báo toàn server |
| DT-14 | Lượt quay Thiên phú **bắt buộc tính trên server** (KT-10); bản offline không được tự gán SSS |
| DT-15 | Trước khi có server: Đạo Tặc vẫn là SSS 0,2% mỗi lần quay, không giới hạn số người |

Xác suất: 0,2% mỗi lần quay, 4 lần quay mỗi nhân vật → khoảng 0,8% mỗi người. Server 10.000 người sẽ có khoảng 80 người quay trúng, chỉ người đầu tiên nhận được.

#### CR-01.3. Điểm cần duyệt

| # | Câu hỏi | Mặc định | Lựa chọn khác |
| --- | --- | --- | --- |
| Q13 | Giữ cả kỹ năng gốc "sao chép kỹ năng boss" cùng với cướp thuộc tính? | Giữ cả hai | Chỉ cướp thuộc tính |
| Q14 | Giới hạn điểm cướp | 1 × cấp (≈ +15% tấn công) | 2 × cấp (≈ +30% tấn công, vượt nguyên tắc 25%) |
| Q15 | Cướp khi **hạ** quái hay mỗi **đòn đánh**? | Khi hạ quái | Mỗi đòn có tỉ lệ nhỏ cướp tạm thời, làm quái yếu đi trong trận |
| Q16 | Thời gian giải phóng khi người giữ bỏ game | 30 ngày | 14 / 60 ngày, hoặc không bao giờ |
| Q169 | *(chủ dự án chốt 30/10/2026)* Giới hạn điểm cướp | **Cấp Thiên phú × cấp nhân vật** | Trước đây 1 × cấp: đầy rất nhanh, cướp gần như không hoạt động từ giữa game |
| Q170 | *(chủ dự án chốt 30/10/2026)* Đầy giới hạn thì sao | **Làm cả 3**: Túi Tang Vật 5 điểm (DT-17), Đà Cướp +3% / 30 giây × 5 tầng (DT-18), Sổ Đạo Tặc trần theo loài 5 / boss 9 / boss hiếm 10 (DT-19) | Số liệu là đề xuất của Claude, chờ playtest |

### CR-02 — Gift code ở Lễ Thức Tỉnh

| | |
| --- | --- |
| Ngày yêu cầu | 20/10/2026 |
| Yêu cầu của chủ dự án | *"Nhà phát hành phát mã code; ở màn hình thức tỉnh Thiên phú lúc đầu game có ô nhập gift-code → người chơi có mã được nhận Thiên phú random từ A → SSS."* |
| Kịch bản gốc | Không có (mục 8 kiếm tiền: không bán Thiên phú — gift code là quà sự kiện, không bán) |
| Trạng thái | ✅ Đã làm (bản offline) · bản server ở Beta (KT-10) |

#### CR-02.1. Yêu cầu

| Mã | Yêu cầu | Tiêu chí nghiệm thu |
| --- | --- | --- |
| GC-01 | Màn hình Lễ Thức Tỉnh có ô **Nhập gift code** + nút **Đổi mã** | Smoke `02b-awakening` |
| GC-02 | Mã hợp lệ → Bia Đá quay thêm **1 lần đặc biệt** chỉ ra Thiên phú hạng **A, S, SS hoặc SSS**; kết quả thêm vào danh sách lượt quay để chọn như các lượt khác. **Không tốn** lượt quay lại | GC-T1 |
| GC-03 | Tỉ lệ trong lượt gift code giữ đúng tỉ lệ tương đối của kịch bản giữa các hạng A trở lên: A 65% · S 25% · SS 9% · SSS 1% | GC-T2: 100.000 lần, lệch < 1 điểm % |
| GC-04 | Mỗi nhân vật dùng **tối đa 1 mã**; mỗi mã chỉ dùng **1 lần trên máy** (lưu `user://redeemed_codes.cfg`, không mất khi xoá save) | GC-T1 |
| GC-05 | Mã sai báo lỗi rõ ràng: sai định dạng / mã không tồn tại / mã đã dùng / đã dùng mã cho nhân vật này | GC-T1 |
| GC-06 | Định dạng mã `TPKG-XXXX-XXXX-XXXX` (12 ký tự Base32 Crockford, không phân biệt hoa thường, bỏ qua dấu gạch và khoảng trắng): 8 ký tự số seri + 4 ký tự kiểm tra = SHA-256(khoá bí mật + seri) | GC-T1 |
| GC-07 | Nhà phát hành sinh mã bằng `python tools/giftcode.py <số lượng> [tên đợt]` → in danh sách và ghi `tools/giftcode_out/<đợt>.csv` (thư mục này không commit) | Công cụ sinh 1.000 mã, game nhận hết |
| GC-08 | Hồ sơ lưu mã đã dùng (`gift_code`) để tra soát | GC-T1 |
| GC-09 | *(30/10/2026)* **Mã gắn Thiên phú**: seri bắt đầu bằng tiền tố đặc biệt thì lượt gift code ra **đúng** Thiên phú đó, không quay ngẫu nhiên. Hiện có: **`DT` → Đạo Tặc** (ví dụ `TPKG-DT0B-7HZG-RKNK`). Sinh mã: `python tools/giftcode.py --talent DT <số lượng> [đợt]` (CSV thêm cột `talent`); `--check` báo mã ra Thiên phú nào. Mã thường do công cụ sinh **không bao giờ** bắt đầu bằng tiền tố đặc biệt. Các luật khác (1 mã/nhân vật, 1 lần/máy, không tốn lượt quay lại) giữ nguyên | GC-T1 |

#### CR-02.2. Bảo mật và giới hạn của bản offline

- Game kiểm mã **ngay trên máy**, khoá bí mật nằm trong file game: người giải nén game có thể tự sinh mã. Chấp nhận cho bản thử nghiệm kín.
- "Mỗi mã 1 lần" chỉ đúng **trên 1 máy**; muốn mỗi mã dùng 1 lần trên toàn bộ người chơi phải kiểm ở **server** (Beta, KT-10): server giữ danh sách mã và đánh dấu đã dùng.
- Đạo Tặc (SSS) quay từ gift code vẫn theo luật DT-15 (chưa có server thì không giới hạn).

#### CR-02.3. Quyết định (chủ dự án chốt 20/10/2026)

| # | Câu hỏi | Quyết định | Ghi chú |
| --- | --- | --- | --- |
| Q43 | Lượt gift code là lượt thêm hay thay lượt quay thường? | **Lượt thêm** | Vẫn chọn được bất kỳ lượt quay thường nào |
| Q44 | Tỉ lệ trong lượt gift code | **A 65 · S 25 · SS 9 · SSS 1** (đề xuất của Claude, chủ dự án đồng ý) | Giữ tỉ lệ tương đối của kịch bản: hạng cao vẫn hiếm, SSS không bị phá giá; chia đều 25% sẽ làm SSS phổ biến gấp 125 lần quay thường |
| Q45 | Mỗi nhân vật dùng tối đa mấy mã | **1 mã** | |

### CR-03 — Lớp thứ 5: Triệu Hồi Sư

| | |
| --- | --- |
| Ngày yêu cầu | 22/10/2026 |
| Yêu cầu của chủ dự án | *"should do the 4th class, Hộ Vệ (NV-04), and should make another class (5th) Triệu hồi sư"* |
| Kịch bản gốc (mục 4) | 4 lớp (Kiếm Khách, Thợ Săn, Pháp Sư, Hộ Vệ); không có Triệu Hồi Sư |
| Thiết kế | [19 mục 3](19-lop-ho-ve-trieu-hoi-su.md): đánh xa, INT, Linh Hồ thường trực, 13 kỹ năng (4 kỹ năng chính theo [charactors.md](charactors.md) — CL2), chuyển chức Linh Sư → Ngự Long Sư / Đồ Đằng Sư; Q110–Q117 theo mặc định |
| Trạng thái | ✅ Đã làm (LH2, 27/10/2026); số liệu chờ chủ dự án xem lại |
