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

### 3.9. Túi đồ — bán đồ và tự xử lý đồ (TD, [CR-04](CR-04-ban-do-tu-tui-va-tu-dong-ban.md))

*(Đánh giá người chơi 06/11: "Tại sao Inventory không cho bán đồ luôn? Không có chỗ cấu hình tự động bán đồ?")*

| Mã | Yêu cầu | Tiêu chí nghiệm thu | Trạng thái |
| --- | --- | --- | --- |
| TD-01…05 | Bán ngay trong Túi đồ ở mọi nơi, đủ giá (Q211): nút Bán / Phân rã ở chi tiết món (Tím, Cam, ≥ +4 bấm 2 lần); khung dưới lưới Phân rã nhanh · Bán nhanh · Tự động · Mua lại; rê chuột + S / D; thẻ đồ có dòng giá bán / phân rã | CR4-T1, CR4-T7 | ✅ |
| TD-06…08 | Khoá đồ (nút hoặc L): món khoá không bán, phân rã, tự xử lý, không vào bộ lọc; ổ khoá trên ô; đồ Cam tự khoá (Q214) | CR4-T1, CR4-T2, CR4-T5 | ✅ |
| TD-09…12 | Tự xử lý đồ khi nhặt: chế độ Tắt / Khi nhặt / Khi túi đầy; Giữ / Bán / Phân rã theo phẩm chất (Cam luôn giữ); ngoại lệ đồ cường hoá, đồ bộ, đồ mạnh hơn, đồ gần cấp; 3 mẫu; thông báo gộp; thống kê phiên; "Áp dụng cho túi"; mua lại 10 món trong phiên (Q213); chỉ áp cho đồ rơi, không áp thưởng nhiệm vụ | CR4-T3, CR4-T4, CR4-T6 | ✅ |
| TD-13 | Bàn Tay Vàng — Điểm Kim: bán đồ +50% vàng ở mọi đường bán; Thần Tài: phân rã 10% ra Thiên Phú Tinh Hoa, lãnh địa +20% vàng (Q217 chốt 09/11: vẫn giữ +50% bán đồ) | CR4-T7, CR4-T8 | ✅ |
| TD-14 | Không mất đồ Cam / đồ khoá khi túi đầy: món nằm lại trên đất + nhắc dọn túi (rà soát 09/11 R1) | CR4-T8 | ✅ |
| TD-15…19 | Pha sau: sắp xếp túi (phẩm chất / ô / Lực chiến, món khoá đầu); giữ đồ bộ thông minh trong tự động (bỏ món trùng bộ + ô kém hơn); quy tắc nâng cao theo ô + dòng chỉ số luôn giữ; khoá / mở khoá nhanh đồ đang mặc; thẻ tóm tắt tự xử lý từ lần mở túi trước | CR4-T9 | ✅ |

### 3.10. HUD — bản đồ nhỏ / khung nhiệm vụ không che nhân vật (HM, [CR-05](CR-05-hud-mo-khi-che-nhan-vat.md))

*(Spec_Notes 09/11: "đi vào mép bản đồ thì bản đồ nhỏ / bảng nhiệm vụ che mất nhân vật; muốn có icon ẩn / hiện")*

| Mã | Yêu cầu | Tiêu chí nghiệm thu | Trạng thái |
| --- | --- | --- | --- |
| HM-01…03 | Nhân vật đi vào dưới (hoặc sát 12 px) bản đồ nhỏ / khung nhiệm vụ → khung đó mờ dần còn 22%, đi ra hiện lại; rê chuột vào khung → rõ để bấm; giữ mức mờ khi đánh boss (R1) | CR05-T1 | ✅ |
| HM-04…05 | 2 nút ẩn / hiện (bản đồ nhỏ, khung nhiệm vụ) cạnh trái la bàn, nhớ trong Cài đặt; bản đồ ẩn thì nút về góc phải; V hiện lại bản đồ nhỏ đang ẩn | CR05-T1 | ✅ |

### 3.11. Nhạc nền và âm môi trường (MU, [46](46-nghien-cuu-nhac-nen.md))

*(Spec_Notes 09/11: "tiếng nhạc trong game giả quá, không giống như game hiện tại")*

| Mã | Yêu cầu | Tiêu chí nghiệm thu | Trạng thái |
| --- | --- | --- | --- |
| MU-01 | Nhạc nền dùng âm nhạc cụ (sáo trúc, đàn nhị, đàn tranh, tỳ bà, dàn dây, trống…), stereo, có không gian; mỗi vùng 1 bài + làng, hang, boss, boss cuối (13 bài); giai điệu có câu, có đoạn | MU1-T1 (đủ file OGG, bài khám phá ≥ 75 giây) + nghe thử | ✅ |
| MU-02 | Bài khám phá phát 1 lượt rồi nghỉ 30–90 giây (chỉ còn âm môi trường), mờ vào lại; làng / hang / boss lặp liền | MU1-T1 | ✅ |
| MU-03 | Âm môi trường theo vùng (gió, chim, côn trùng, nước, dung nham…), làng và hang riêng; thanh âm lượng "Âm thanh môi trường" trong Cài đặt | MU1-T1 | ✅ |
| MU-04 | Nhạc báo: lên cấp, hoàn thành nhiệm vụ, sang vùng mới, gặp boss, chiến thắng; nhạc nền tự hạ khi nhạc báo phát | MU1-T1 | ✅ |
| MU-05 | Tầng nhạc chiến đấu khi đánh quái thường (đợt 2, Q227) | — | ⬜ |

### 3.12. Thêm cách tăng Lực chiến cho trang bị (NL, [47](47-de-xuat-nang-luc-chien-trang-bi.md))

*(Spec_Notes 09/11: "ngoài việc nâng cấp đồ thì cần thêm các hình thức khác để nâng lực chiến cho đồ")* — chủ dự án "triển khai theo đề xuất", **đã làm 09/11/2026** ([47 §9](47-de-xuat-nang-luc-chien-trang-bi.md)). Mở theo vùng cao nhất đã tới: ngọc vùng 2, tẩy luyện + luyện cấp vùng 3, thăng phẩm vùng 4, Thức Tỉnh sau chuyển chức 3.

| Mã | Yêu cầu | Tiêu chí nghiệm thu | Trạng thái |
| --- | --- | --- | --- |
| NL-A | Khảm Ngọc Ngũ Hành: lỗ theo phẩm chất (0/1/1/2/3), đục thêm tối đa 3; 5 loại ngọc cấp 1–10, ghép 3 → 1; ngọc rơi theo hệ quái; ≥ 2 ngọc cùng hệ trên vũ khí → ấn hệ (+15% khắc); tháo không vỡ, phân rã / bán trả ngọc về Túi Ngọc | NL1-T1 | ✅ |
| NL-B | Tẩy Luyện: 1 dòng phụ cố định mỗi món, luyện giá trị hoặc đổi dòng, chọn giữ cũ / mới; không tẩy hiệu ứng Cam / bộ | NL1-T2 | ✅ |
| NL-C | Thăng Phẩm: hút 1 món cùng ô cùng phẩm chất → lên 1 bậc (tới Tím), giữ cường hoá / ngọc / dòng cũ, thêm 1 dòng | NL2-T1 | ✅ |
| NL-D | Luyện Cấp đồ Cam / đồ bộ +5 cấp mỗi lần, tối đa cấp nhân vật | NL2-T2 | ✅ |
| NL-E | Thức Tỉnh (sau chuyển chức 3): món Tím / Cam +12 mở 1 dòng theo lớp / Thiên phú, bậc 1–5, tối đa 4 món có hiệu lực | NL3-T1 | ✅ |
| NL-F | Bảo Giám: ghi danh lần đầu sở hữu đồ bộ / Cam / mốc cường hoá / ngọc cao → mốc thưởng vĩnh viễn ≈ +5% | NL3-T1 | ✅ |
| NL-G | Thẻ đồ tách Lực chiến theo nguồn; nút "Gợi ý tăng Lực chiến" cạnh huy hiệu Lực chiến | NL1-T1 + ảnh | ✅ |

## 4. Yêu cầu phi chức năng

| Mã | Yêu cầu |
| --- | --- |
| NFR-01 | Chạy mượt 60 FPS trên laptop văn phòng; dùng renderer GL Compatibility để chạy được cả máy yếu và xuất web sau này |
| NFR-02 | Toàn bộ chữ trong game là tiếng Việt có dấu, hiển thị đúng |
| NFR-03 | Logic game tách khỏi phần vẽ để test tự động được ở chế độ headless |
| NFR-04 | Thông số cân bằng (thời gian hồi, giá, điều kiện mở khoá) nằm tập trung ở `config.gd` và `data/`, sửa không cần đụng logic |
| NFR-05 | Không mất tiến trình khi game đóng đột ngột quá 5 giây kể từ lần lưu gần nhất |
| NFR-06 | Cửa sổ co giãn được, tối thiểu 1280 × 720 vẫn hiển thị đủ HUD |
| NFR-07 | Hiệu ứng kỹ năng đọc được gameplay (FX-1, [36](36-thiet-ke-lai-vfx-ky-nang.md) §3.3): kỹ năng đặt điểm có vòng cảnh báo đúng bán kính trước khi gây sát thương; quái trúng đòn nháy trắng; choáng / trói / độc có ký hiệu trên đầu; màu xanh lá chỉ dùng cho hồi máu; mỗi lớp một bảng màu riêng (§4). Nghiệm thu: chủ dự án duyệt Q180–Q183 (03/11/2026: cả 70 kỹ năng, song song với hình đã duyệt, HD); test FX1-T1 + smoke `tests/fx1_smoke.gd` — ✅ |
| NFR-08 | Quái / tinh anh / boss cùng một phong cách HD (MD-1, [39](39-thiet-ke-lai-quai-vat.md)): cartoon vẽ tay theo ảnh mẫu — silhouette nhận ra ở ~50 px, viền tối dày, cel 3 tông, một màu nhấn phát sáng, họ màu theo vùng; cỡ hiển thị và vùng va chạm như bản pixel; frame đánh đầu tiên là tư thế lấy đà; tắt "Đồ hoạ HD" về hình pixel. 9 linh thú Triệu Hồi Sư cùng phong cách (Q190, 09/11). Nghiệm thu: test MD1-T1 + ảnh `docs/design/monsters/` (+ `ingame/`); Q190 / Q192 duyệt 09/11, Q191 chốt làm chuẩn, chỉnh sau khi chơi thử — 🟡 chờ phản hồi chơi thử |
| NFR-09 | Màn hình to hơn thì thấy rộng hơn, không chỉ phóng to (VS-1, [44](44-ty-le-khung-nhin-va-chieu-sau.md)): 1366×768 giữ như cũ; 1080p trở lên camera tự zoom ra (nhân vật ≈ 7–7,5% chiều cao màn hình, 1080p ≈ ×1,5 diện tích map), giao diện tự động 90% (1080p) / 85% (≥ 1440p); Cài đặt → Hiển thị có "Tầm nhìn" Gần / Vừa / Xa (Xa ×0,88) và "Cỡ giao diện" Tự động / 80–110%; chữ trên bản đồ giữ cỡ đọc được. Bản đồ có chiều sâu: bóng đổ theo một hướng sáng, mảng nắng / bóng râm lớn, nền hạ tông để nhân vật nổi, cụm sương trôi + hạt bay theo vùng, tiền cảnh mờ ở mép dưới màn hình (tắt được; PF-02 08/11: không còn dải sương / tia nắng / tiền cảnh ở mép trên — người chơi thấy như "vệt mờ"). Nghiệm thu thêm: PF02-T1. Khung nhiệm vụ thu gọn bằng chuột phải. Nghiệm thu: test VS1-T1 + ảnh `docs/design/view-scale/` — ✅ (B6 cao độ địa hình chưa làm) |
| NFR-10 | Đi trên bản đồ không giật (PF-02, [44 §7](44-ty-le-khung-nhin-va-chieu-sau.md), phản ánh 08/11): vẽ thế giới chỉ những gì trong khung nhìn (cả cổng, cổng chặn boss, đấu trường, hàng rào), tách quái theo lưới ô (không so mọi cặp), mảng nắng / bóng râm nướng sẵn 1 ảnh mỗi map, sắp xếp vật theo Y bằng sắp xếp gốc. Đo: `tests/perf_walk.gd` (dòng `TIMELINE` / `RENDER`, `--scan`). Kết quả 08/11 trên máy iGPU 1080p + 120 quái: script −23%, render CPU −28%, GPU −25%. Nghiệm thu: PF02-T1 — 🟡 (chưa đạt 60 khung/giây của NFR-01 trên iGPU khi đông quái; bước tiếp ở 44 §7.2) |
| NFR-11 | Góc nhìn có chiều sâu (GN-1, [45](45-nghien-cuu-goc-nhin-va-nhan-vat.md), chủ dự án duyệt "làm theo đề xuất" 09/11): **Phối cảnh** Tắt / Nhẹ (mặc định) / Vừa — mép trên (phía xa) nhỏ hơn mép dưới, nhân vật giữa màn hình giữ cỡ, chuột ngắm đúng chỗ; camera zoom gần ×1,1 khi có boss sống trong 700 px; camera lệch 5% về hướng chạy; vùng 1 có cảnh trại (rào cọc phía xa đấu trường, bãi trại bỏ hoang, đồ vương vãi), quầng sáng đuốc / đèn lồng / lửa trại, bóng sát chân, tông nền trầm hơn, lối mòn mép mềm. GN-4: dưới phối cảnh nhân vật / cây / nhà đứng thẳng; mép map có vách đá (mép trên), mặt bằng cao (hai bên), gờ vực (mép dưới) — người chơi vẫn bị chặn ở mép cũ; hồ nước / hố dung nham có thành. GN-3: bộ đếm combo lớn ở mép trái (Cài đặt Bộ đếm combo: Lớn / Nhỏ / Tắt), tông nền 9 vùng, nền đất mòn dưới bãi trại, viền mềm sân đấu trường, không cây trong sân đấu trường 3-3. GN-2: vùng 2–9 cũng có cảnh trại theo chất liệu vùng (không đè nước / dung nham / đảo / cầu / điểm nhiệm vụ; vùng 6 không đặt lửa). Giữ nhân vật chibi + 2D (Q222), không thêm viền sáng nhân vật (Q221) | ✅ | Test GN1-T1, ảnh `docs/design/goc-nhin/` |

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
- ~~Q229–Q236~~ đã trả lời 09/11/2026 ("triển khai theo đề xuất") — [47 §8](47-de-xuat-nang-luc-chien-trang-bi.md); Q235 (chỉnh độ khó chương 7–9) theo dõi khi chơi thử.
- ~~Q224–Q228~~ đã trả lời 09/11/2026 ("làm theo đề xuất") — [46 §8](46-nghien-cuu-nhac-nen.md).
- ~~Q180–Q183~~ đã trả lời 03/11/2026 — [36 §8](36-thiet-ke-lai-vfx-ky-nang.md).
