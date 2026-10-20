# Đặc tả MVP — Vertical slice

| | |
| --- | --- |
| Dự án | Thiên Phú Khai Giới |
| Nguồn | [Kịch bản game](kich-ban-game-thien-phu-khai-gioi.md), mục 9, giai đoạn 2: *"MVP / Vertical slice: 2 lớp, 20 Thiên phú, chương 1–2, lãnh địa cấp 1–2, trang bị + cường hoá, lưu game. Thử nghiệm kín 50–100 người."* |
| Kế thừa | Prototype Chương 1 — [01-requirement-spec.md](01-requirement-spec.md) |
| Cập nhật | 20/10/2026 |

Quy trình cho mỗi đợt: **viết spec → duyệt → code → test → cập nhật spec (trạng thái) và technical spec**. Mục 2 chia MVP thành 5 đợt. Mục 3 là spec chi tiết của đợt đang làm. Các đợt sau sẽ được viết chi tiết khi tới lượt.

## 1. Phạm vi MVP so với kịch bản

| Hạng mục trong kịch bản | MVP làm | Để lại sau MVP |
| --- | --- | --- |
| Lớp nhân vật (mục 4) | Kiếm Khách + Thợ Săn | Pháp Sư, Hộ Vệ; chuyển chức (cấp 30) |
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
| M3 | Lớp Thợ Săn (đánh xa) + chọn lớp lúc tạo nhân vật, 4 kỹ năng mỗi lớp, MP, né tránh, công thức chỉ số quái mới | 4, 5, 9 | M2 | 🟡 Spec ở mục 5, đang code |
| M4 | Chương 2: Đồng Bằng Gió Hú, gió đẩy lùi, boss Tướng Gián Điệp Huyền Ảnh, Thành Biên Đài, di chuyển giữa các vùng | 2, 5, 6 | M1 | Chưa viết spec |
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
| TL-S2 | **Thảo dược, bình máu** | 8 bụi thảo dược trên bản đồ; đi qua để hái (+1, Nhà Thảo Dược +2); hái xong mọc lại chỗ khác sau 60 giây. Đủ 2 thảo dược tự chế 1 bình máu. Bình máu: tối đa 5, bắt đầu 2; phím **Q** hồi 35% HP, hồi chiêu 8 giây | TP #9, #13; mục 8 "mua bình thuốc" |
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
| TP-40 | **Đạo Tặc — Cướp Thuộc Tính** đúng CR-01.1 (DT-01…08) với mặc định Q13–Q16: hạ quái có tỉ lệ cướp (thường 3%, tinh anh 30%, thủ lĩnh Ổ 100%, boss 100% × 3 điểm), loại thuộc tính theo bảng đặc trưng của quái (06), giới hạn 1 × cấp, đầy thì bỏ điểm cũ nhất; quái thấp hơn quá 5 cấp không cướp được (boss luôn được); tỉ lệ ×1,0 → ×1,5 theo Lv. Điểm cướp cộng thẳng vào chỉ số, không bị tẩy điểm, hiện riêng trong bảng Chỉ số; thông báo *"Cướp +1 AGI từ Sói Sương (12/15)"* |

### 5.8. Giao diện

| Mã | Yêu cầu |
| --- | --- |
| UI-01 | HUD: thanh MP dưới thanh HP; thanh kỹ năng 8 ô: Đánh thường · 1 · 2 · 3 · 4 · Né · L · Q, mỗi ô có icon, hồi chiêu; ô thiếu MP tô xanh mờ |
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
| TP-T3 | Đạo Tặc: boss cho 3 điểm; giới hạn 1 × cấp, đầy thì thay điểm cũ nhất; quái thấp hơn 6 cấp không cướp được; điểm cướp không bị tẩy |
| TL-B | **Cân bằng** chạy cho **2 lớp × 20 Thiên phú**: tất cả hạ được Sói Chúa; F và S chênh ≤ 25% trong từng lớp; 2 lớp chênh nhau ≤ 25% |

### 5.11. Điểm cần duyệt

M3 code theo **mặc định** dưới đây. **Trạng thái: chưa duyệt.**

| # | Câu hỏi | Mặc định | Lý do |
| --- | --- | --- | --- |
| Q28 | Tên và hiệu ứng 8 kỹ năng (mục 5.4) | Như bảng | Kịch bản không có danh sách kỹ năng; thiết kế theo vai trò lớp (cận chiến cân bằng / xa cơ động) và hướng chuyển chức (Huyết Kiếm, Thợ Bẫy) |
| Q29 | Phím kỹ năng | 1–4; K/chuột phải = kỹ năng 1 | Phím số là chuẩn ARPG PC; giữ K cho người đã quen |
| Q30 | Tác dụng INT, LUK cho 2 lớp hiện có | Mục 5.3 | INT có ích cho mọi lớp qua MP và sát thương kỹ năng; LUK cho người cày đồ |
| Q31 | Né tránh 0,3%/AGI, trần 30%, Thợ Săn gốc 5% | Như vậy | Trần 30% để boss vẫn nguy hiểm |
| Q32 | MP: 50 + 5/cấp, hồi 3/giây | Như vậy | Đủ dùng xoay vòng 4 kỹ năng ở chương 1, thiếu nếu bấm liên tục |
| Q33 | Tinh anh vùng 1 chỉ còn Sói Đầu Đàn, Nấm Mẹ (thay "… Tinh Anh") | Có | Đúng tài liệu 06 (2 loại tinh anh mỗi map, kịch bản mục 5) |
| Q34 | Không đổi lớp giữa chừng | Không đổi được | Đổi lớp sẽ đi cùng chuyển chức (Alpha) |

## Phụ lục A — Yêu cầu thay đổi (CR)

Thay đổi do chủ dự án yêu cầu sau khi kịch bản đã viết. Mỗi CR ghi nguồn, đề xuất, trạng thái duyệt, và đợt sẽ làm.

### CR-01 — Đạo Tặc (Ẩn): cướp thuộc tính + độc nhất server

| | |
| --- | --- |
| Ngày yêu cầu | 20/10/2026 |
| Yêu cầu của chủ dự án | *"SSS 'độc nhất server' → có làm. Thiên phú này đánh quái sẽ cướp thuộc tính của quái, cướp random loại thuộc tính để cộng vào nhân vật."* |
| Kịch bản gốc (mục 3) | Đạo Tặc (Ẩn), SSS, Đặc biệt: "Sao chép 1 kỹ năng boss sau mỗi lần hạ boss"; SSS "độc nhất server (tuỳ chọn)" |
| Trạng thái | **Đề xuất — chờ duyệt số liệu** (bảng Q13–Q16) |
| Đợt | Cướp thuộc tính: **M3** (cần INT, LUK — NV-11, NV-12). Độc nhất server: **Beta** (cần backend — KT-09, KT-10) |

#### CR-01.1. Cướp Thuộc Tính (bị động, mới)

| Mã | Yêu cầu |
| --- | --- |
| DT-01 | Hạ quái có tỉ lệ cướp điểm thuộc tính (bảng nguồn); điểm cộng thẳng vào STR/AGI/VIT/INT/LUK của nhân vật |
| DT-02 | Loại thuộc tính chọn ngẫu nhiên theo bảng đặc trưng của loại quái |
| DT-03 | Giới hạn: tổng điểm cướp ≤ **1 × cấp nhân vật** |
| DT-04 | Đã đầy giới hạn: điểm mới **thay điểm cũ nhất** (hàng đợi vào trước ra trước) — cho phép đổi build bằng cách chọn quái để cày |
| DT-05 | Quái thấp hơn nhân vật quá 5 cấp không cướp được; boss luôn cướp được |
| DT-06 | Điểm cướp lưu riêng (không lẫn với điểm tiềm năng), **không bị tẩy điểm**, hiện riêng trong bảng Chỉ số và bảng Thiên phú |
| DT-07 | Mỗi lần cướp hiện thông báo, ví dụ *"Cướp +1 AGI từ Sói Sương (12/15)"* |
| DT-08 | Giữ kỹ năng gốc: hạ boss thì sao chép 1 kỹ năng boss, dùng bằng phím L (đã làm ở M2, TP-39) |

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
