# Bí Kíp = Điểm Kỹ Năng (BK)

| | |
| --- | --- |
| Dự án | Thiên Phú Khai Giới |
| Nguồn | Chủ dự án (31/10/2026): *"Bí kíp thì tương đương với 1 điểm kỹ năng, tức là nhặt được bí kíp thì sẽ được +1 điểm kỹ năng"*. Biến thể ✦ chọn phương án "tốn Điểm Kỹ Năng" |
| Thay cho | Phần Bí Kíp của SK3 ([13 mục 9](13-he-ky-nang.md)): Bí Kíp theo kỹ năng và tầng, Mảnh Bí Kíp, "Đổi 5 Mảnh"; luật R1 "chỉ rơi cho kỹ năng đã mở" |
| Trạng thái | ✅ **Đã làm** (31/10/2026), save v24, test SK3-T3 / BK-T1, BK-T2, R1-T1 |

## 1. Vì sao đổi

| Cách cũ (SK3) | Vấn đề |
| --- | --- |
| Bí Kíp gắn với 1 kỹ năng + 1 tầng, rơi ngẫu nhiên | May rủi chồng lên Thiên phú. Rơi Bí Kíp cho kỹ năng không dùng thì gần như vô ích |
| Trùng → Mảnh, 5 Mảnh đổi Bí Kíp chọn trước | Thêm một loại tiền tệ và một nút phải giải thích |
| Nhặt xong phải vào bảng Kỹ năng tìm đúng kỹ năng | Người chơi hỏi "nhặt rồi dùng thế nào?" |

Cách mới: **mọi Bí Kíp đều có ích ngay**, người chơi tự quyết dùng điểm vào đâu.

## 2. Luật

| Mã | Yêu cầu |
| --- | --- |
| BK-01 | Nhặt Bí Kíp = **+1 Điểm Kỹ Năng**, cộng ngay. Chữ vàng giữa màn hình *"Bí Kíp: +1 Điểm Kỹ Năng"* + dòng thông báo |
| BK-02 | Nguồn rơi giữ nguyên: tinh anh 5% · boss vùng 40% · Chúa Hang 25% · boss hiếm 100% · ô Di tích giải câu đố 30%. Không còn phân tầng I / II / III |
| BK-03 | Biến thể ✦ (Song Phát, Âm Dương, Vô Song, Thanh Tâm, Kiên Cố) mở bằng **2 Điểm Kỹ Năng** mỗi cái, mở 1 lần cho đúng kỹ năng và tầng đó |
| BK-04 | Mở ✦ cần kỹ năng đã đủ cấp tầng (4 / 7 / 10). Mở ở mọi nơi, giống nâng cấp kỹ năng. **Chọn** biến thể vẫn chỉ ở vùng an toàn |
| BK-05 | Bảng Kỹ năng: cạnh lựa chọn ✦ chưa mở có nút **"Mở ✦ (2 điểm)"**; thiếu điểm hoặc chưa đủ cấp thì khoá, tooltip ghi lý do |
| BK-06 | **Tẩy điểm** khoá lại mọi ✦, hoàn 2 điểm mỗi ✦, bỏ chọn ✦ đang dùng (tầng đó về chưa chọn) |
| BK-07 | Bỏ Mảnh Bí Kíp và nút "Đổi 5 Mảnh". Chân bảng Kỹ năng ghi "Bí Kíp = +1 Điểm Kỹ Năng" (tooltip ghi nguồn rơi) |
| BK-08 | Save **v24**. Save cũ: ✦ đã có giữ nguyên (vẫn dùng được); Mảnh Bí Kíp đổi thành điểm, 5 Mảnh = 1 điểm, làm tròn lên |

## 3. Ngân sách Điểm Kỹ Năng

Mỗi lớp có thể tiêu tối đa:

| Chỗ tiêu | Điểm |
| --- | ---: |
| 13 kỹ năng chủ động × 9 cấp (1 → 10) | 117 |
| 4 bị động × 5 cấp ([27](27-ky-nang-bi-dong.md)) | 20 |
| 13 kỹ năng × 3 ✦ × 2 điểm | 78 |
| **Tổng** | **215** |

Lên cấp cho 1 điểm mỗi cấp: 59 điểm ở cấp 60, 99 điểm ở cấp 100. Bí Kíp bù phần còn thiếu, nên đánh tinh anh, boss và giải Di tích có thêm lý do. Cày boss hồi sinh cũng không phá vỡ hệ thống vì chỗ tiêu điểm còn rất lớn.

## 4. Kỹ thuật

| Mục | Cách làm |
| --- | --- |
| `core/skills2.gd` | `drop_book(w)` cộng 1 `skill_points`; `on_kill` / `on_relic` giữ tỉ lệ cũ. Mới: `STAR_COST`, `star_of`, `can_unlock_star`, `unlock_star`, `reset_stars`, `STAR_IDS`. Bỏ `grant_book`, `exchange_book`, `SHARDS_PER_BOOK`. Trường `secret_books` giữ tên cũ, nay nghĩa là "✦ đã mở" |
| `core/game_world.gd` | `skill_reset` cộng `Skills2.reset_stars(profile)` |
| `core/profile.gd` | `VERSION` 24; bỏ `book_shards` (save cũ < v24 cộng `ceil(Mảnh / 5)` vào `skill_points`) |
| `ui/skill_panel.gd` | Nút `Book_<kỹ năng>_<tầng>` = "Mở ✦ (2 điểm)"; tooltip Điểm Kỹ Năng ghi nguồn điểm; chân bảng bỏ số Mảnh |

Tỉ lệ rơi dùng ít số ngẫu nhiên hơn trước (không còn chọn kỹ năng, chọn tầng). Các test cân bằng tắt quái trên bản đồ nên không bị ảnh hưởng.

## 5. Kiểm thử

| Mã | Nội dung |
| --- | --- |
| SK3-T3 / BK-T1 | Chưa mở ✦ thì không chọn được; 1 điểm chưa đủ; kỹ năng cấp 3 chưa mở được ✦ tầng I; mở Song Phát −2 điểm; mở lại bị từ chối; Song Phát / Âm Dương / Vô Song / Thanh Tâm vẫn chạy; boss hiếm +1 điểm, tinh anh ~5%; save v24 giữ ✦; save v23 có 7 Mảnh → +2 điểm; tẩy điểm hoàn 2 điểm mỗi ✦ và bỏ chọn ✦ |
| BK-T2 | Bảng Kỹ năng: nút Mở ✦ khoá khi có 1 điểm, bấm được khi có 3 điểm, bấm xong còn 1 điểm và nút biến mất |
| R1-T1 | 60 Bí Kíp = +60 điểm, không tự mở ✦ |

## 6. Đề xuất thêm (chưa làm, chờ chủ dự án)

| # | Đề xuất | Lý do |
| --- | --- | --- |
| Q171 | **Chấm đỏ trên nút Kỹ năng ở HUD** khi còn Điểm Kỹ Năng chưa dùng | Giờ điểm đến từ 2 nguồn; người chơi dễ quên tiêu |
| Q172 | **Boss hiếm rơi 2 Bí Kíp** (thay vì 1) | Boss hiếm khó và ít, trước đây cho Bí Kíp tầng III (mạnh nhất). Nay mọi Bí Kíp như nhau nên boss hiếm thiệt nhất |
| Q173 | Khi **mọi chỗ tiêu điểm đã đầy** (215 điểm), Bí Kíp đổi thành vàng hoặc Tinh Thạch | Tránh điểm thừa vô dụng ở cuối game |
| Q174 | Đổi tên "Bí Kíp" trong thông báo thành "Bí Kíp (+1 Điểm Kỹ Năng)" ở bảng Thiên phú / trợ giúp F1 | Người chơi mới hiểu ngay |
| Q175 | Q68 cũ (Bí Kíp giao dịch được khi có chợ): bỏ | Bí Kíp nay cộng thẳng vào nhân vật, không còn là vật phẩm |
