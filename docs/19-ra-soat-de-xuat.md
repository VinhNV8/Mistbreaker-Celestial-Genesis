# Rà soát toàn bộ kịch bản + spec và đề xuất cải thiện

| | |
| --- | --- |
| Dự án | Thiên Phú Khai Giới |
| Phạm vi | [Kịch bản](kich-ban-game-thien-phu-khai-gioi.md), spec 01–18, bản game ở commit `a29c598` (22/10/2026) |
| Cách làm | Đọc lại kịch bản và 18 tài liệu spec; chạy smoke test trên worktree sạch (34 ảnh chụp, từ màn tiêu đề tới Bản Ngã Bóng Tối, 0 `SCRIPT ERROR`); phóng to sprite nhân vật, quái, boss; đối chiếu bảng theo dõi [04](04-ke-hoach-tien-do.md). Ảnh chụp ở `docs/images/ra-soat/`. *Lưu ý: ảnh chụp chưa có các thay đổi giao diện UI-16/17/20 đang làm dở của phiên game-39 (khung nhiệm vụ trong ảnh là bản cũ)* |
| Loại tài liệu | Rà soát + đề xuất. Không đổi code |
| Trạng thái | ⬜ Chờ chủ dự án chọn hướng (mục 11) |

Mỗi mục có mã `RS-…`, **ưu tiên** (Cao / Vừa / Thấp) và **công sức** ước lượng (S = vài giờ, M = 1 đợt, L = nhiều đợt).

## 0. Tóm tắt — 12 việc nên làm trước

| # | Việc | Vì sao | Mục |
| --- | --- | --- | --- |
| 1 | **Cho người thật chơi thử** chương 1–3 trước khi làm tiếp chương 7–9 | Cả 6 chương mới chỉ cân bằng bằng bot. Kịch bản đặt thử nghiệm kín 50–100 người ngay sau MVP — vẫn ⬜ | RS-Q01 |
| 2 | **Dọn rác chữ trên chiến trường**: bảng tên quái, số sát thương, chữ nhặt đồ chồng lên nhau | Ảnh vùng 5, vùng 6: không đọc được gì khi đánh đông quái | RS-UI01 |
| 3 | **HUD bên phải che đấu trường boss** | Hang boss vùng 4–6 nằm phía đông map → khung nhiệm vụ + bản đồ nhỏ đè lên trận | RS-UI02 |
| 4 | Sửa 5 lỗi hiển thị thấy ngay trong ảnh chụp | Icon kỹ năng tràn thẻ lớp, "+10!" đè chữ, chữ xuyên qua màn chiến thắng, log lặp, số không có dấu chấm | RS-UI03…07 |
| 5 | **Thiên phú phụ + Cộng hưởng** (TP-05, TP-13) — điểm khác biệt chính của kịch bản, vẫn ⬜ | Làm trước chương 7–9 vì mọi trận boss sau phải cân lại khi có 2–3 Thiên phú | RS-T01 |
| 6 | **Trang bị hiện trên nhân vật**, nhân vật có hướng lên/xuống, mỗi lớp có dáng riêng | Game săn đồ mà mặc đồ Cam vẫn y như áo vải; 3 lớp cùng 1 khuôn người | RS-A01…03 |
| 7 | **Boss to và có hình riêng**, đấu trường có cảnh vật | Viêm Long dùng thân sói + cánh; boss chỉ to ×1,5 người chơi; hang boss là hình tròn tô màu | RS-M01, M02 |
| 8 | **Cảm giác đánh**: khựng hình khi trúng, rung màn hình, đẩy lùi, chớp sáng | Không tìm thấy hit-stop / rung màn hình trong code — đòn đánh "nhẹ tay" | RS-C01 |
| 9 | **Dàn dựng lại Lễ Thức Tỉnh và cảnh mở đầu** | Kịch bản gọi là "đỉnh cảm xúc đầu tiên"; hiện là thẻ chữ trên nền đen, cảnh mở đầu là hình tròn và vạch đỏ | RS-UI08, A06 |
| 10 | **Gộp bớt tài nguyên và vật phẩm tiêu hao theo chương** | Khoảng 20 loại; chương 4, 6, 7, 8 lặp cùng một mẫu "thanh môi trường + 1 vật phẩm phím Q" | RS-E01, E02 |
| 11 | **Bí Kíp chỉ rơi cho kỹ năng đã mở** | Ảnh màn chiến thắng: cấp 6 nhận Bí Kíp *Vạn Kiếm Quy Tông* (mở ở cấp 45) | RS-C04 |
| 12 | **Rút gọn nhịp 1 → 100** hoặc thêm nội dung lặp lại | Kịch bản ≈ 250 giờ; nội dung có thể chơi lặp (hang phụ, boss hiếm) mỏng; cổng dungeon, Ác mộng chưa có | RS-K02 |

## 1. Điểm mạnh nên giữ

- **Quy trình spec → code → test → cập nhật** rất kỷ luật: mỗi chương có spec, mã yêu cầu, test tự động, mục "đổi so với spec" và phát hiện. Hiếm dự án nhỏ làm được.
- **Cân bằng bằng bot** (TL-B…, PACE) kèm bài học rõ ràng (D41, F1–F4) — nền tốt để cân tiếp.
- **Kiến trúc chương cắm thêm** (`core/chapters.gd`, hook) cho phép nhiều phiên làm song song.
- **Hệ kỹ năng SK1–SK3** (mở theo cấp + biến thể + Bí Kíp) chọn đúng hướng thị trường.
- **Mỗi vùng có môi trường riêng** (gió, nắng/đêm, độc, dung nham, băng giá) — đúng tinh thần kịch bản.

## 2. Kịch bản và thiết kế tổng

| Mã | Vấn đề | Đề xuất | Ưu tiên · Công sức |
| --- | --- | --- | --- |
| RS-K01 | **Phản diện vắng mặt**: Ma Tôn Vô Diện chỉ được nhắc qua thoại và trang sách, lần đầu xuất hiện là chương 9. Hư Vô Giáo có mặt ở chương 2 rồi biến mất tới chương 8 | Cho Ma Tôn **xuất hiện thật** 3 lần trước chương 9: chương 3 (ảo ảnh trong di tích — đánh không lại, chạy thoát), chương 6 (giọng nói trong Ám Khí), chương 7 (bóng hắn phía sau Giáo Chủ). Thêm 1 tinh anh Hư Vô Giáo ở mỗi vùng 3–6 | Vừa · M |
| RS-K02 | **Nhịp quá dài so với nội dung**: kịch bản 30 phút → 6 giờ → 40 giờ → 120 giờ → 80 giờ (≈ 250 giờ tới cấp 100). Nội dung chơi lặp được hiện chỉ có hang phụ + boss hiếm + quái ngoài đồng. Cổng dungeon (BD-11), Ác mộng/Địa ngục (BD-10), Triều Hư Vô vẫn ⬜ | Chọn một: **(a)** rút cốt truyện chính còn **25–35 giờ** (ARPG PC trả tiền một lần: Diablo 4 chiến dịch ≈ 25–35 giờ, PoE 2 ≈ 20–25 giờ) và để 60 → 100 dài ở endgame; hoặc **(b)** giữ 250 giờ nhưng làm **cổng dungeon ngẫu nhiên** trước chương 7 để có nội dung lặp | Cao · quyết định (Q99) |
| RS-K03 | **Nhân vật chính và bạn đồng hành mỏng**: nhân vật không nói; Lam Nhi, Lạc Phong, Tuyết Nga chỉ đứng ở trại | Mỗi chương 1 **cảnh bạn đồng hành đánh cùng** (đồng minh AI có sẵn từ Tử Linh Sư / Tổng tấn công); cho nhân vật 1–2 câu đáp ở các cảnh lớn | Thấp · M |
| RS-K04 | **Chỉ có một lựa chọn** trong cả game (kết thúc chương 9) | Thêm 2–3 lựa chọn nhỏ có hậu quả ở đoạn kết: tha hay bắt Kim Phú (chương 5), tin Mạc Tam (chương 8), cứu Lam Nhi trước hay đuổi theo Nữ Vương (chương 4). Kết thúc đọc lại các lựa chọn này | Thấp · M |
| RS-K05 | **Lớp Hộ Vệ** (4 lớp trong kịch bản) chưa có, và không có trong kế hoạch gần | Quyết định: bỏ khỏi bản đầu (ghi chỗ lệch kịch bản) hoặc làm **trước chương 7** — càng muộn càng phải cân lại nhiều chương | Vừa · L (Q100) |
| RS-K06 | **Online** (bảng xếp hạng, giao dịch, boss thế giới, độc nhất server SSS, thông báo toàn server) có trong kịch bản nhưng chưa có backend; CR-01 "độc nhất server" đã chốt làm | Chốt nền tảng + mô hình bán trước (Q1 ở 04 mục 13 vẫn treo). Nếu PC mua đứt: bỏ độc nhất server, giữ bảng xếp hạng Steam | Vừa · quyết định (Q101) |

## 3. Thiên phú

| Mã | Vấn đề | Đề xuất | Ưu tiên · Công sức |
| --- | --- | --- | --- |
| RS-T01 | **Thiên phú phụ (cấp 30/60) và Cộng hưởng** — thứ làm game khác các ARPG khác — vẫn ⬜ (TP-05, TP-13, TP-44). Kịch bản lấy "Thợ Săn Di Tích" làm ví dụ | Làm thành đợt riêng **trước M11** (M10 đang code): ô phụ 1 nhận ở chương 3 (cấp 30), ô phụ 2 ở chương 6 (cấp 60) — bù cho save cũ. Cân lại TL-B… với 2–3 Thiên phú | Cao · L |
| RS-T02 | **Thiên phú kinh tế / chế tạo / lãnh địa không đổi cách chơi khi chiến đấu** (Bàn Tay Vàng, May Mắn Nhỏ, Thợ Rèn Bẩm Sinh, Trái Tim Lãnh Chúa). Kịch bản: *"Thiên phú không chỉ là buff chỉ số mà thay đổi cách chơi"*. Người quay trúng chúng thấy mình "trắng tay" ở trận boss | Làm **hiệu ứng riêng của dạng tiến hoá** (Q55, vẫn treo) với 1 cơ chế chiến đấu nhỏ cho mỗi Thiên phú không chiến đấu (ví dụ Bàn Tay Vàng: đòn chí mạng rơi vàng + 5% Tấn công theo số vàng nhặt trong 10 giây) | Vừa · M |
| RS-T03 | **Gift code ở Lễ Thức Tỉnh** (CR-02) cho Thiên phú hạng A ngay trên màn quay — trái nguyên tắc kịch bản *"không bán lượt quay Thiên phú hạng cao"* nếu sau này code được bán / tặng theo sự kiện nạp | Chuyển ô nhập code sang **Cài đặt** hoặc màn tiêu đề; code chỉ tặng tối đa hạng B hoặc vật phẩm | Vừa · S |
| RS-T04 | Các quyết định Thiên phú **Q7, Q8, Q10, Q11** vẫn "chờ duyệt" dù đã code từ M2 | Chủ dự án duyệt gộp một lần để bảng 04 bớt 🟡 | Thấp · S |

## 4. Kỹ năng và chiến đấu

| Mã | Vấn đề | Đề xuất | Ưu tiên · Công sức |
| --- | --- | --- | --- |
| RS-C01 | **Thiếu "cảm giác đánh"**: không tìm thấy hit-stop (khựng hình), rung màn hình, đẩy lùi quái thường, chớp trắng khi trúng trong code (`grep shake/hitstop` không có kết quả). Spec C5-11 có ghi "rung màn hình nhẹ" | Thêm 4 thứ, có tuỳ chọn tắt trong Cài đặt: khựng 40–60 ms khi chí mạng / vỡ Phá Thế / trúng boss; rung theo cường độ đòn; đẩy lùi quái thường 0,5–1 m; quái trúng đòn chớp trắng 1 khung hình. Đây là chỗ Vampire Survivors, Hades, Diablo tạo cảm giác "đã tay" | **Cao · M** |
| RS-C02 | **Kỹ năng ít liên kết với nhau**: 12–17 kỹ năng mỗi lớp nhưng chủ yếu khác số (vòng, đường thẳng, mưa). Build mẫu trong docs/13 mục 4.5 chưa có cơ chế "kỹ năng A làm kỹ năng B mạnh hơn" | Thêm **trạng thái dùng chung** (Thiêu, Chậm, Choáng, Đánh dấu) — mỗi kỹ năng **tạo** hoặc **ăn** một trạng thái (ví dụ Kiếm Khí đánh dấu, Đột Kích vào quái bị đánh dấu ×1,5). Cho bảng Kỹ năng gợi ý "hợp với" | Vừa · M |
| RS-C03 | Kỹ năng mở theo cấp nhưng **log báo khoá lặp lại** mỗi lần bấm phím kỹ năng chưa mở ("Thiên Thạch mở ở cấp 4" ×3 trong ảnh) | Báo khoá chỉ hiện **ở ô kỹ năng** (đã có chữ "Cấp 4"), không ghi log; nếu ghi thì 1 lần / 10 giây | Cao · S |
| RS-C04 | **Bí Kíp rơi cho kỹ năng chưa mở** (cấp 6 nhận Bí Kíp tầng II của tối thượng cấp 45) | Chỉ rơi cho kỹ năng **đã mở**; chưa có kỹ năng nào đủ cấp 4/7/10 thì đổi thành Mảnh Bí Kíp | Cao · S |
| RS-C05 | **Bảng Kỹ năng nặng chữ**: 3 hàng biến thể × 3–5 nút, nhiều nút xám không rõ vì sao | Mỗi biến thể là **thẻ có icon** + 1 dòng hiệu ứng; nút khoá có tooltip lý do; ẩn "Đổi 5 Mảnh" khi chưa đủ 5 Mảnh | Vừa · M |
| RS-C06 | **Mẫu boss "đứng đúng chỗ"** lặp lại: Đá Nổi (Viêm Long), lửa (Bản Ngã), lõi đảo (Cự Thần), Đèn Tinh Quang (Giáo Chủ), Đá Nổi lại (Ma Tôn). Nhiều trận thành "chạy tới vòng an toàn" | Giữ cho Viêm Long + Giáo Chủ; Cự Thần đổi trọng tâm sang **né đòn nện theo nhịp** (đã có Thiên chuỳ); Ma Tôn dùng bản rút gọn ngắn | Thấp · S (sửa spec 16–18) |

## 5. Quái và boss

| Mã | Vấn đề | Đề xuất | Ưu tiên · Công sức |
| --- | --- | --- | --- |
| RS-M01 | **Boss dùng lại khuôn quái**: Viêm Long = thân sói 4 chân + cánh (trông như chó có cánh); Long Băng dùng lại khuôn Viêm Long; Bản Ngã = người chơi tô đen; Nữ Vương cùng khuôn với Pháp Sư. Xem `images/ra-soat/sprites.png` | Mỗi boss chương **một khuôn riêng** (rồng thân rắn có cổ dài, nữ vương có váy/vương miện to, cự thần cao 2 ô…). Đây là hình người chơi nhớ nhất | **Cao · M** (bộ dựng mới trong `tools/art`) |
| RS-M02 | **Boss nhỏ**: 48 px (×1,5 người chơi). ARPG thường để boss to gấp 3–6 lần người | Boss chương **96–128 px**, boss hiếm 64–96 px; vùng va chạm và vòng báo giữ nguyên. Thanh máu boss đã có ở trên | Cao · M |
| RS-M03 | **Đấu trường boss là hình tròn tô màu** (tím, dung nham lặp ô, băng) không có cảnh vật; hang phụ trông giống ngoài đồng tối đi (ảnh `09a2-cave`) | Mỗi hang boss 1 bộ cảnh: cột, xương, đuốc tường, vách hang bao quanh; hang phụ dùng nền đá + vách + ánh đuốc thay vì nền cỏ của map cha | Vừa · M |
| RS-M04 | **Quái thường 4–6 loại mỗi vùng nhưng hành vi giống nhau** (đuổi + đánh), khác ở 1 kỹ năng | Thêm 2 vai trò còn thiếu: **quái chạy trốn / gọi đồng bọn** và **quái đặt bẫy / tạo vùng**; mỗi vùng ít nhất 1 quái buộc người chơi đổi vị trí | Thấp · M |
| RS-M05 | **Tinh anh chỉ là quái tô sáng** | Tinh anh to ×1,3, viền màu theo kỹ năng, có **tiền tố** ngẫu nhiên (Nhanh, Lì, Nổ khi chết…) như Diablo — tăng đa dạng không cần vẽ thêm | Thấp · S |

## 6. Giao diện

| Mã | Vấn đề (bằng chứng) | Đề xuất | Ưu tiên · Công sức |
| --- | --- | --- | --- |
| RS-UI01 | **Chữ chồng chữ khi đánh đông**: mỗi quái có bảng tên "Thường · Tên · Lv65" + số sát thương + "+N EXP" + chữ trạng thái, đè lên nhau và lên nhân vật (ảnh `13-region5`, `15-region6`) | Quái **thường**: bỏ bảng tên mặc định — chỉ hiện **chấm cấp màu + thanh máu mỏng** khi đã trúng đòn; bảng tên đầy đủ khi **rê chuột / đang khoá mục tiêu** và luôn hiện cho tinh anh / boss. Số sát thương: gộp theo mục tiêu trong 0,3 giây, chỉ chí mạng mới to; trần 12 số trên màn hình. Tuỳ chọn "Hiện số sát thương: Đủ / Gọn / Tắt" | **Cao · M** |
| RS-UI02 | **HUD phải che trận boss**: hang boss vùng 4–6 ở phía đông, bản đồ nhỏ + khung nhiệm vụ (≈ 290 px) đè lên đấu trường (ảnh `13c-vien-long`, `15d-ban-nga`) | Khi có thanh máu boss: **thu khung nhiệm vụ** về 1 dòng, bản đồ nhỏ mờ 40%; camera lệch về giữa đấu trường. Áp chung cho mọi boss | **Cao · S** |
| RS-UI03 | **Icon kỹ năng tràn khỏi thẻ lớp** ở màn tạo nhân vật — 12–17 icon chạy qua thẻ bên cạnh và ra ngoài màn hình (ảnh `02-create`) | Thẻ lớp chỉ hiện **4 kỹ năng đầu** + "+13 kỹ năng"; hoặc xuống dòng có giới hạn | **Cao · S** |
| RS-UI04 | **Hiệu ứng "+10!" của cường hoá đè lên chữ chỉ số** của món đồ (ảnh `05c-inventory-equipped`) | Hiệu ứng vẽ lên **ô đồ** (bên trái) hoặc phía trên tên món, không lên khung chữ | Cao · S |
| RS-UI05 | **Màn chiến thắng bị chữ xuyên qua**: "Lên cấp 6!", "+3171 EXP", "Bí Kíp…", tên và số sát thương của trận vẫn hiện xuyên qua bảng; nền chỉ tối nhẹ (ảnh `07-victory`) | Màn chiến thắng / kết chương: nền tối 75% + mờ; dừng mọi chữ bay; thông báo lên cấp / Bí Kíp xếp hàng hiện **sau** khi đóng bảng | Cao · S |
| RS-UI06 | **Số lớn không có dấu chấm** ở khung nhiệm vụ ("Thưởng: 100000 EXP", "450000 EXP") — UI-20 mới làm cho nhật ký | Dùng chung hàm `_group_thousands` cho mọi số ≥ 10.000 (khung nhiệm vụ, túi đồ, cửa hàng, tổng kết) | Cao · S |
| RS-UI07 | **Vòng tròn xám mờ trên mặt đất** khắp các map (ảnh vùng 2, 5, 6) — trông như lỗi vẽ; dải tối ngang map (vùng 6) | Kiểm tra: nếu là mảng nền / lối mòn thì đổi sang hoạ tiết ô có viền mềm; nếu là sương thì làm mép mềm hơn | Vừa · S |
| RS-UI08 | **Lễ Thức Tỉnh phẳng**: thẻ chữ hạng + tên trên nền đen, Bia Đá nhỏ, không có nhân vật; kịch bản: *"đỉnh cảm xúc đầu tiên"*, *"hiệu ứng ánh sáng theo màu hạng"* (ảnh `02b-awakening`) | Dàn dựng: nhân vật đứng trước Bia Đá to (½ chiều cao màn hình); khi quay — cột sáng màu hạng đi lên dần (xám → … → cầu vồng), rung nhẹ, âm thanh lên cao; hạng S trở lên có màn bừng sáng riêng; thẻ Thiên phú lật ra sau. Lịch sử lượt quay thành 4 thẻ nhỏ có màu hạng | **Cao · M** |
| RS-UI09 | **Bản đồ khai phá chỉ là ô lục giác màu + "?"** (ảnh `04-map`) | Mỗi ô có hình nền địa hình (rừng, núi, sông) + icon sự kiện + hình công trình đã xây; ô sương phủ mây trôi. Đây là "lãnh địa" — trục thứ hai của game — nên phải đẹp như màn chiến đấu | Vừa · M |
| RS-UI10 | **Màn tiêu đề không có hình**, chỉ chữ + bảng phím (ảnh `01-title`); dòng phụ tiếng Anh | Hình nền minh hoạ (Bia Đá + sương + lục địa vỡ), nhạc; bỏ bảng phím (đã có F1); tên tiếng Anh nhỏ dưới cùng | Vừa · M |
| RS-UI11 | **Thanh trên cùng 2 dòng chữ nhỏ** (Đuốc hồi, tên map, cấp map, khám phá %, Vượt ải) + 7–9 tài nguyên | Dòng phụ chuyển vào **bản đồ nhỏ** (tên map + %), Đuốc hồi thành vòng quanh icon Đuốc; chỉ hiện tài nguyên của vùng đang ở + vàng | Vừa · S |
| RS-UI12 | **Khung hội thoại**: chân dung là sprite 32 px nhỏ; không có tên người nói ở phía nhân vật | Chân dung bán thân 96–128 px cho NPC chính và nhân vật (sinh bằng code từ ngoại hình) | Thấp · M |
| RS-UI13 | Giao diện thiết kế cho **chuột + bàn phím** (nhiều phím tắt, bảng dày chữ); nền tảng PC hay Mobile vẫn chưa chốt | Chốt nền tảng (Q101). Nếu có Mobile: cần nút ảo, bảng ít chữ, cỡ chữ ≥ 14 — làm sớm đỡ làm lại | Vừa · quyết định |

## 7. Hình ảnh nhân vật và đồ hoạ

Ảnh `images/ra-soat/sprites.png`: Kiếm Khách, Thợ Săn, Pháp Sư, Sói Sương, Sói Chúa, Viêm Long, Bản Ngã, Cự Thần, Sói Băng, Sa Hoàng, Nữ Vương, Xác Ướp (phóng ×4).

| Mã | Vấn đề | Đề xuất | Ưu tiên · Công sức |
| --- | --- | --- | --- |
| RS-A01 | **Trang bị không hiện trên nhân vật**: mặc Nanh Sói Chúa +10 (đồ Cam) vẫn là thanh kiếm sắt, áo xanh. Trong game săn đồ, nhìn thấy đồ mới trên người là phần thưởng lớn nhất | Ghép lớp (paper-doll) ở mức tối thiểu: **vũ khí** theo loại + màu phẩm chất, **áo** đổi màu theo phẩm chất / bộ vùng, **hào quang nhẹ** khi mặc đủ 6 món bộ. Bộ dựng `humanoid` đã có lớp `base`/`hair` — thêm lớp `armor`, `weapon` | **Cao · M** |
| RS-A02 | **Chỉ có hướng sang phải + lật**: đi lên/xuống vẫn thấy người nghiêng sang một bên — lạ với góc nhìn trên xuống | Thêm hướng **trước** và **sau** cho nhân vật người chơi + NPC (quái giữ 2 hướng) | Vừa · M |
| RS-A03 | **3 lớp cùng một khuôn người**, chỉ khác màu áo và vũ khí; Pháp Sư trông như trẻ con | Mỗi lớp 1 dáng: Kiếm Khách vai rộng + giáp vai + áo choàng; Thợ Săn mũ trùm + ống tên sau lưng; Pháp Sư mũ/khăn + áo dài chấm đất | Cao · M |
| RS-A04 | **Chuyển chức không đổi ngoại hình** (chỉ hào quang) | Mỗi lần chuyển chức đổi 1 lớp ngoại hình (giáp vai, áo choàng, mũ) — người chơi thấy mình "lên chức" | Vừa · M |
| RS-A05 | **Nhân vật 64 px nhỏ so với cây 80–120 px** (G-F5, để xem lại khi playtest) — cảnh rừng dày làm nhân vật lẫn mất (ảnh `03-combat`) | Giảm mật độ cây quanh đường đi; cây che nhân vật thì **mờ đi** khi nhân vật đứng sau; vòng sáng dưới chân nhân vật rõ hơn | Vừa · S |
| RS-A06 | **Cảnh mở đầu (Thiên Liệt) vẽ bằng hình học** — vòng tròn xanh + vạch đỏ (ảnh `01b-intro`) — 90 giây đầu tiên của game | 5 tranh pixel art minh hoạ (lục địa, Bia Đá, trời nứt, sương mù, làng Thanh Thạch), chuyển cảnh chậm, chữ hiện dần | Cao · M |
| RS-A07 | Hình sinh bằng code đồng nhất nhưng **thiếu chi tiết** ở mức "có bản sắc"; AR-44 (thay bằng hình hoạ sĩ) để "khi có ngân sách" | Lên kế hoạch: giữ code cho quái thường / icon; **thuê vẽ (hoặc tự vẽ đè) 12 hình quan trọng nhất**: 3 lớp × 2 giới tính, 9 boss chương, tranh mở đầu. Manifest giữ nguyên kích thước nên thay được dần | Vừa · L (Q102) |
| RS-A08 | Hiệu ứng kỹ năng vẽ vector (vòng, đường) — rõ nhưng đơn điệu | Thêm hạt (particle) và vệt mờ dần cho đòn chém, mưa tên, thiên thạch; màu theo hệ biến thể tầng II | Thấp · M |

## 8. Kinh tế, tài nguyên, lãnh địa

| Mã | Vấn đề | Đề xuất | Ưu tiên · Công sức |
| --- | --- | --- | --- |
| RS-E01 | **Quá nhiều loại tài nguyên**: vàng, Gỗ, Đá, Sắt, Tinh Thạch, Đá Cường Hoá, Tinh Kim, Thiên Phú Tinh Hoa, Tinh Hoa Tiến Hoá, Đuốc, thảo dược, Bí Kíp, Mảnh Bí Kíp, Lõi Hư Vô + 7 vật phẩm tiêu hao theo chương ≈ **20 loại**. Chính Q26 (06) đặt nguyên tắc *"ít loại tiền tệ"* | Gộp: **Đá + Sắt → Khoáng**; **Tinh Kim + Đá Cường Hoá** → một nguyên liệu cường hoá có 2 bậc; Mảnh Bí Kíp giữ. Thanh tài nguyên chỉ hiện cái đang dùng ở vùng hiện tại | Vừa · M |
| RS-E02 | **Mẫu "thanh môi trường + vật phẩm phím Q" lặp lại** ở chương 4 (Thuốc Giải), 5 (Bình Nước Thánh), 6 (Than Hồng), 7 (Lông Vũ Gió), 8 (Đèn Lồng) — mỗi chương 1 món phải mua, chiếm phím bình máu | Thay bằng **1 ô "Bùa Vùng"** (phím Q2 hoặc tự dùng): bùa đổi hiệu ứng theo vùng đang đứng, nâng cấp ở thợ rèn. Spec 16/17 nên đổi theo nếu duyệt | Vừa · S (sửa spec) + M (code) |
| RS-E03 | **Lãnh địa là bảng menu**, không phải nơi đi lại: xây công trình chỉ thấy chữ; nâng Thôn chỉ +20% sản lượng | Trại Khai Giới hiện **trên map làng** và lớn dần theo cấp (spec 16 C7-03 đã có 5 hình); công trình đã xây hiện trên ô của bản đồ khai phá (RS-UI09) | Vừa · M |
| RS-E04 | **Đuốc hồi 2 phút** (kịch bản 20 phút) vẫn là giá trị test (KP-02) | Chốt sau playtest; nếu giữ 2 phút thì sửa kịch bản để hết lệch | Thấp · S |

## 9. Tài liệu và quy trình

| Mã | Vấn đề | Đề xuất | Ưu tiên · Công sức |
| --- | --- | --- | --- |
| RS-Q01 | **Chưa có playtest người thật** (thử nghiệm kín ⬜). Mọi số cân bằng đến từ bot; bot không bị rối vì chữ chồng, không đọc thoại, biết mọi cơ chế | Mở **playtest kín nhỏ** (5–10 người, bản .exe chương 1–3) với phiếu ở 01 mục 7 + ghi hình; dùng kết quả để chốt RS-K02, RS-UI01, RS-C01 trước khi làm tiếp | **Cao · S** |
| RS-Q02 | **01-requirement-spec lỗi thời** (ghi 5 Thiên phú, 1 lớp, cập nhật 20/10) trong khi memory/quy trình yêu cầu cập nhật 01 mỗi lần thay đổi | Đổi 01 thành **danh mục yêu cầu toàn game** (trỏ sang 03, 08–18) hoặc ghi rõ "chỉ là prototype" ở đầu file | Vừa · S |
| RS-Q03 | **03-mvp-spec trùng số mục** (hai mục "## 9"), dài 1.100 dòng gồm cả UI đợt 4–7 | Tách giao diện (UI-07…20) sang file riêng `docs/20-giao-dien.md`; sửa đánh số | Thấp · S |
| RS-Q04 | **06 sinh bằng script nên chưa có quyết định Q76** (Lõi Hư Vô) và các chỗ làm mềm ở spec 16–18 | Khi duyệt, sửa `tools/gen_world_doc.py` rồi chạy lại | Thấp · S |
| RS-Q05 | **`game_world.gd` 4.283 dòng** — nhiều phiên cùng sửa, dễ xung đột | Tách dần: `combat.gd` (đòn, sát thương), `enemy_ai.gd`, `player.gd`; làm khi không có phiên nào đang code chương | Vừa · M |
| RS-Q06 | **Số version save do nhiều phiên giữ chỗ** (v15 hang phụ, v16 SK3, v17 M10, v18 game-c6…) | Ghi bảng "version → đợt" ở 02 mục định dạng save; mỗi phiên lấy số ở đó | Thấp · S |

## 10. Lộ trình đề xuất

| Đợt | Nội dung | Mã |
| --- | --- | --- |
| **R1 — Sửa nhanh giao diện** (1 đợt) | Lỗi hiển thị + HUD khi đánh boss + log + số + Bí Kíp | RS-UI02…07, RS-C03, RS-C04 |
| **R2 — Cảm giác đánh và chữ trên chiến trường** (1 đợt) | Hit-stop, rung, đẩy lùi, chớp; bảng tên / số sát thương gọn | RS-C01, RS-UI01 |
| **R3 — Playtest kín nhỏ** | Bản .exe chương 1–3, 5–10 người | RS-Q01 |
| **R4 — Hình ảnh nhân vật và boss** (2 đợt) | Trang bị trên người, dáng riêng 3 lớp, 2 hướng thêm, boss to + khuôn riêng, đấu trường | RS-A01…04, RS-M01…03 |
| **R5 — Ấn tượng đầu** (1 đợt) | Lễ Thức Tỉnh, cảnh mở đầu, màn tiêu đề | RS-UI08, RS-UI10, RS-A06 |
| **R6 — Thiên phú phụ + Cộng hưởng** (1–2 đợt) | Trước M11 | RS-T01, RS-T02 |
| M10 (đang làm) → M11 → M12 | Chương 7–9, sau khi áp RS-E02 vào spec 17–18 nếu duyệt | spec 16–18 |

R1 và R2 không đụng file chương (chủ yếu `hud.gd`, `world_view.gd`, `screens.gd`, `inventory_panel.gd`) nên làm song song được với M10 nếu chia file rõ.

## 11. Điểm cần chủ dự án chọn

| # | Câu hỏi | Đề xuất |
| --- | --- | --- |
| Q99 | Nhịp tổng: rút cốt truyện chính còn 25–35 giờ hay giữ ≈ 250 giờ của kịch bản? | **Rút còn 25–35 giờ** cho cốt truyện; thời gian dài để ở endgame (Thần Vực, Tái Thiết, cấp sau 100) |
| Q100 | Lớp Hộ Vệ: làm trước chương 7 hay bỏ khỏi bản đầu? | **Bỏ khỏi bản đầu**, ghi chỗ lệch kịch bản; làm sau như nội dung cập nhật |
| Q101 | Nền tảng và mô hình bán: PC mua đứt / Mobile miễn phí? | **PC (Steam) mua đứt trước** — khớp giao diện hiện tại, không cần backend để ra mắt; bỏ "độc nhất server" |
| Q102 | Hình ảnh: tiếp tục sinh bằng code hay thuê vẽ một phần? | **Lai**: code cho quái thường / icon; thuê hoặc tự vẽ 3 lớp + 9 boss + tranh mở đầu |
| Q103 | Thứ tự R1–R6 so với M11–M12 | **R1 → R2 → R3** trước M11; R4–R6 song song tuỳ người |
| Q104 | Gộp vật phẩm môi trường thành "Bùa Vùng" (RS-E02)? | **Có** — sửa spec 17, 18 trước khi code; chương 4–7 đổi dần |
