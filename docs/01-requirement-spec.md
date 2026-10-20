# Đặc tả yêu cầu — Chương 1 "Thức Tỉnh" (phần nền)

| | |
| --- | --- |
| Dự án | Thiên Phú Khai Giới |
| Phạm vi | Chương 1 "Thức Tỉnh" — phần nền của game: combat, Thiên phú, khai phá, boss đầu |
| Nguồn yêu cầu | [Kịch bản game](kich-ban-game-thien-phu-khai-gioi.md), mục 9 (giai đoạn Prototype) |
| Bản triển khai | [godot/](../godot/), Godot 4.7.2 — kỹ thuật xem [02-technical-spec.md](02-technical-spec.md) |
| Cập nhật | 20/10/2026 |
| Giai đoạn tiếp theo | [03-mvp-spec.md](03-mvp-spec.md) — MVP chia đợt M1–M5 |

## 1. Mục tiêu

Giai đoạn đầu (bản prototype, xong 19/10/2026) phải trả lời 3 câu hỏi trước khi đầu tư đồ hoạ và nội dung:

1. Combat có vui không?
2. Thiên phú có làm cách chơi khác đi không?
3. Vòng "đánh quái → khai phá → vượt map" có hấp dẫn không?

Tiêu chí thành công: người chơi mới hoàn thành Chương 1 trong **20–30 phút** mà không cần hướng dẫn ngoài game, và trả lời "có muốn chơi tiếp" (xem phiếu playtest ở mục 7).

## 2. Phạm vi

**Trong phạm vi:** 1 lớp nhân vật (Kiếm Khách), 5 Thiên phú, 1 bản đồ (Rừng Sương), lưới khai phá 10 ô, 1 boss (Sói Chúa Hư Vô), lưu game, chạy trên PC (Windows) bằng bàn phím + chuột.

**Ngoài phạm vi (để dành cho MVP):** trang bị và cường hoá, lớp nhân vật thứ 2–4, chuyển chức, tiến hoá và cộng hưởng Thiên phú, Thiên phú phụ, thương nhân, cổng dungeon, Triều Hư Vô, né "Hoàn hảo", chương 2 trở đi, online, monetization, âm thanh, đồ hoạ thật, điều khiển cảm ứng/tay cầm.

## 3. Yêu cầu chức năng

Cột **Trạng thái**: ✅ đã làm và có test tự động · 🟡 đã làm, chỉ kiểm tra bằng smoke test/quan sát · ⬜ chưa làm.

### 3.1. Luồng màn hình (SCR)

| Mã | Yêu cầu | Tiêu chí nghiệm thu | Trạng thái |
| --- | --- | --- | --- |
| SCR-01 | Màn hình tiêu đề có "Hành trình mới", "Tiếp tục" và bảng phím điều khiển | "Tiếp tục" bị vô hiệu khi chưa có save | 🟡 |
| SCR-02 | "Hành trình mới" khi đã có save phải hỏi xác nhận trước khi xoá | Huỷ thì save giữ nguyên | 🟡 |
| SCR-03 | Thắng boss hiện màn hình kết chương: thời gian chơi, cấp, số quái, khai phá, Thiên phú | Có nút "Tiếp tục khám phá" và "Về màn hình chính" | 🟡 |
| SCR-04 | Mở bảng Chỉ số (C) hoặc Bản đồ (M/Tab) thì game tạm dừng; Esc hoặc bấm ra ngoài để đóng | Quái không di chuyển khi bảng đang mở | 🟡 |

### 3.2. Lễ Thức Tỉnh — nhận Thiên phú (AWK)

| Mã | Yêu cầu | Tiêu chí nghiệm thu | Trạng thái |
| --- | --- | --- | --- |
| AWK-01 | 1 lần quay + 3 lần quay lại miễn phí, tổng tối đa 4 lần | Lần thứ 5 không quay được | ✅ |
| AWK-02 | Người chơi chọn được **bất kỳ** kết quả nào đã quay, không bắt buộc lấy lần cuối | Bấm chip "Lần n" để chọn lại | 🟡 |
| AWK-03 | Tỉ lệ theo bảng độ hiếm của kịch bản: F 30, C 28, B 22, A 13, S 5 (chuẩn hoá trên bể 5 Thiên phú) | Mô phỏng 20.000 lần quay lệch < 2% | ✅ |
| AWK-04 | Bảo hiểm: cả 4 lần đều dưới hạng B thì lần cuối được nâng lên hạng B | Test với RNG luôn ra F | ✅ |
| AWK-05 | Hiển thị tỉ lệ quay và luật bảo hiểm ngay trên màn hình | — | 🟡 |

### 3.3. Thiên phú (TAL)

| Mã | Thiên phú | Hạng | Hiệu ứng | Trạng thái |
| --- | --- | --- | --- | --- |
| TAL-01 | Tay Nhanh | F | +5% tốc đánh | ✅ |
| TAL-02 | Huyết Chiến | C | HP < 30%: +20% sát thương | 🟡 |
| TAL-03 | Kiếm Tâm | B | Mỗi đòn chém thứ 5 gây sát thương ×2 | 🟡 |
| TAL-04 | Mắt Ưng | A | Thấy sự kiện của ô sương mù cách lãnh địa ≤ 2 ô; +10% chí mạng | ✅ |
| TAL-05 | Thời Gian Ngưng Đọng | S | Phím L: quái và đạn đứng yên 3 giây, hồi chiêu 90 giây | 🟡 |
| TAL-06 | Bấm L với Thiên phú bị động thì báo "bị động — luôn có hiệu lực", không lỗi | — | 🟡 |

### 3.4. Nhân vật và lên cấp (CHR)

| Mã | Yêu cầu | Tiêu chí nghiệm thu | Trạng thái |
| --- | --- | --- | --- |
| CHR-01 | EXP lên cấp: `EXP(L) = 100·L^2.2 + 500·⌊L/10⌋³` | EXP(1) = 100, luôn tăng tới cấp 100 | ✅ |
| CHR-02 | Mỗi cấp +5 điểm tiềm năng, cộng vào STR / AGI / VIT | — | 🟡 |
| CHR-03 | STR +2 tấn công; AGI +1% tốc đánh, +0,5% chí mạng; VIT +12 HP, +0,5 phòng thủ | — | 🟡 |
| CHR-04 | Tẩy điểm miễn phí trước cấp 30 | — | 🟡 |
| CHR-05 | Lên cấp: hồi đầy HP, +1 Đuốc Khai Giới, hiện thông báo lớn | — | 🟡 |

### 3.5. Combat (CMB)

| Mã | Yêu cầu | Tiêu chí nghiệm thu | Trạng thái |
| --- | --- | --- | --- |
| CMB-01 | Chém theo hướng chuột: cung ±60°, tầm 80, giữ chuột để chém liên tục | — | 🟡 |
| CMB-02 | Xoáy Kiếm (K / chuột phải): đánh vòng tròn tầm 125, ×1,8 sát thương, hồi 6 giây | — | 🟡 |
| CMB-03 | Né lăn (Space): bất tử 0,3 giây, hồi 3 giây | Đòn trúng lúc né hiện "Né!" và không mất máu | 🟡 |
| CMB-04 | Sát thương: `ATK · HệSố · ATK/(ATK+DEF) · (1+KhắcHệ) · (1+ThiênPhú)`, dao động ±10% | Đúng công thức với số mẫu | ✅ |
| CMB-05 | Combo: mỗi đòn trúng +1, reset khi bị trúng đòn hoặc 5 giây không đánh; EXP +20% ở 100 combo | — | ✅ |
| CMB-06 | Mọi đòn của quái có báo hiệu trước (vòng đỏ / vạch bắn) để người chơi kịp né | — | 🟡 |
| CMB-07 | Chết: hồi sinh ở làng sau 2,5 giây, không mất tiến trình | — | 🟡 |

### 3.6. Quái và boss (MOB)

| Mã | Yêu cầu | Tiêu chí nghiệm thu | Trạng thái |
| --- | --- | --- | --- |
| MOB-01 | 3 loại quái: Sói Sương (cận chiến nhanh), Nấm Độc (bắn bào tử), Tinh Linh Sương (cận chiến mạnh) | — | 🟡 |
| MOB-02 | Cấp quái tăng dần từ làng (cấp 1) về phía hang (cấp 6) | — | 🟡 |
| MOB-03 | 6% quái sinh ra là tinh anh: HP ×2,2, ATK ×1,5, EXP ×3; hạ được +1 Đuốc | — | 🟡 |
| MOB-04 | Quái không đuổi theo vào làng và vào hang boss | Sói đang đuổi bỏ cuộc khi người chơi vào hang | ✅ |
| MOB-05 | Hang Sói Chúa chỉ mở khi **đạt cấp 5 và khai phá ≥ 60% ô đất**; trước đó bị tường sương mù chặn kèm thông báo lý do | Không đi qua được, boss không xuất hiện | ✅ |
| MOB-06 | Sói Chúa: cắn (cận chiến) và vồ (vòng đỏ ở vị trí người chơi, ×2 sát thương, mỗi 5 giây) | — | 🟡 |
| MOB-07 | Thanh Phá Thế 600 điểm: cạn thì boss choáng 5 giây và nhận +50% sát thương | — | 🟡 |
| MOB-08 | Dưới 50% HP: gọi 3 sói cấp 5 và tàng hình, chỉ hiện khi vung đòn, bị choáng hoặc ở gần (< 140) | — | 🟡 |
| MOB-09 | Người chơi chết thì boss rút về hang và hồi đầy máu | — | 🟡 |
| MOB-10 | Độ khó: nhân vật cấp 5 (12 STR, 8 VIT) biết né thắng được trong khoảng 40 giây | Bot né thắng sau 42 giây, 0 lần chết | ✅ |

### 3.7. Khai phá và lãnh địa (EXP)

| Mã | Yêu cầu | Tiêu chí nghiệm thu | Trạng thái |
| --- | --- | --- | --- |
| EXP-01 | Lưới lục giác 10 ô quanh Trại: 4 Rừng gỗ, 2 Ổ quái, 2 Di tích, 1 Người sống sót, 1 Kỳ quan; xáo ngẫu nhiên theo vòng | Đúng cơ cấu | ✅ |
| EXP-02 | Dùng 1 Đuốc để dọn sương một ô **kề** lãnh địa; dọn xong được 40 × cấp EXP | Ô không kề hoặc hết Đuốc thì bị chặn kèm lý do | ✅ |
| EXP-03 | Đuốc: bắt đầu 3, tối đa 10, hồi 1 cái mỗi 2 phút | — | ✅ |
| EXP-04 | Rừng gỗ: xây Xưởng Gỗ giá 30 vàng → +6 gỗ, +3 vàng mỗi phút | Thiếu vàng thì không xây được | ✅ |
| EXP-05 | Ổ quái: bấm "Chinh phục" sinh 1 thủ lĩnh tinh anh + 3 quái; chỉ chiếm ô khi hạ thủ lĩnh | — | ✅ |
| EXP-06 | Di tích: +80 vàng, +150 EXP, một trang sách cốt truyện | — | 🟡 |
| EXP-07 | Người sống sót +10% sản lượng; Suối Linh Khí +10% EXP chiến đấu | — | 🟡 |
| EXP-08 | Nâng Trại lên Thôn: 100 vàng + 100 gỗ → +20% sản lượng | — | 🟡 |
| EXP-09 | Sản xuất và hồi Đuốc tiếp tục khi offline, tối đa 12 giờ; báo kết quả khi quay lại | — | ✅ |

### 3.8. Lưu game (SAV)

| Mã | Yêu cầu | Tiêu chí nghiệm thu | Trạng thái |
| --- | --- | --- | --- |
| SAV-01 | Tự lưu mỗi 5 giây, khi lên cấp, khi chiếm ô, khi thắng boss và khi đóng cửa sổ | — | 🟡 |
| SAV-02 | Save có trường `version`; save sai phiên bản bị bỏ qua, không làm crash game | — | ✅ |
| SAV-03 | Lưu rồi nạp lại giữ đúng mọi giá trị và kiểu dữ liệu | Test lưu/nạp qua JSON | ✅ |

## 4. Yêu cầu phi chức năng

| Mã | Yêu cầu |
| --- | --- |
| NFR-01 | Chạy mượt 60 FPS trên laptop văn phòng; dùng renderer GL Compatibility để chạy được cả máy yếu và xuất web sau này |
| NFR-02 | Toàn bộ chữ trong game là tiếng Việt có dấu, hiển thị đúng |
| NFR-03 | Logic game tách khỏi phần vẽ để test tự động được ở chế độ headless |
| NFR-04 | Thông số cân bằng (thời gian hồi, giá, điều kiện mở khoá) nằm tập trung ở `config.gd` và `data/`, sửa không cần đụng logic |
| NFR-05 | Không mất tiến trình khi game đóng đột ngột quá 5 giây kể từ lần lưu gần nhất |
| NFR-06 | Cửa sổ co giãn được, tối thiểu 1280 × 720 vẫn hiển thị đủ HUD |

## 5. Chỗ lệch so với kịch bản

Cố ý thay đổi để test nhanh hơn. Khi chuyển sang MVP cần quyết định giữ hay trả về giá trị gốc.

| Hạng mục | Kịch bản | Trong game | Lý do |
| --- | --- | --- | --- |
| Hồi Đuốc | 1 cái / 20 phút | 1 cái / 2 phút | Phiên test chỉ 20–30 phút |
| Nguồn Đuốc | Hồi theo thời gian, nhiệm vụ ngày | Thêm: lên cấp +1, hạ tinh anh +1 | Như trên |
| Bể Thiên phú | 20 Thiên phú, có SS/SSS | 5 Thiên phú F → S | Đủ để so sánh lối chơi |
| Cấp tối đa | 100 | 100 (nội dung chỉ tới khoảng cấp 6) | — |
| Thời gian 1 → 10 | 30 phút | Mục tiêu cấp 5 trong 15–20 phút | Boss cần cấp 5 |
| Sự kiện ô đất | 7 loại | 5 loại (bỏ Thương nhân, Cổng dungeon) | Thu gọn phạm vi |

## 6. Truy vết với kịch bản

| Mục trong kịch bản | Yêu cầu tương ứng |
| --- | --- |
| 2. Thế giới quan & cốt truyện | SCR-03, EXP-06 (trang sách) |
| 3. Hệ thống Thiên phú | AWK-01…05, TAL-01…06 |
| 4. Nhân vật, chỉ số & lên cấp | CHR-01…05 |
| 5. Chiến đấu & quái vật | CMB-01…07, MOB-01…10 |
| 6. Bản đồ & vượt map | MOB-02, MOB-05 |
| 7. Khai phá vùng đất mới | EXP-01…09 |
| 9. Kịch bản 30 phút đầu | Luồng SCR, mục tiêu ở mục 1 |

## 7. Nghiệm thu bằng playtest

Cho 3–5 người chơi thử từ đầu tới khi hạ boss, không hướng dẫn thêm. Ghi lại thời gian hoàn thành, số lần chết và Thiên phú đã chọn, rồi hỏi:

1. Lúc quay Thiên phú có hồi hộp không? Có muốn quay lại không?
2. Đánh quái có "đã tay" không? Chỗ nào thấy nhàm?
3. Có hiểu vì sao bị chặn ở sương mù phía đông không?
4. Khai phá ô đất có hấp dẫn, hay chỉ là việc phải làm?
5. Trận boss khó quá, dễ quá, hay vừa? Có dùng né lăn không?
6. Thiên phú của bạn có làm cách chơi khác đi không?
7. Có muốn chơi tiếp chương 2 không?

## 8. Câu hỏi còn mở

- Nền tảng ra mắt đầu tiên: PC hay Mobile? Quyết định này ảnh hưởng điều khiển (NFR-06) và UI.
- Phong cách đồ hoạ: pixel art, 2.5D anime hay 3D low-poly?
- Sau playtest: có giữ tốc độ hồi Đuốc 2 phút cho bản chính không?
