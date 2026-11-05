# 38. Rà soát giao diện theo tiêu chí chuẩn và đề xuất thiết kế lại (UI-50…63)

| Mục | Nội dung |
| --- | --- |
| Ngày | 04/11/2026 |
| Yêu cầu | Chủ dự án: *"Về mặt giao diện, thì còn chỗ nào cần cải thiện không? hãy research tiêu chí chuẩn design của game và đề xuất design lại cho game hiện tại"* |
| Cách làm | (1) Tổng hợp tiêu chí từ các bộ hướng dẫn công khai (Xbox Accessibility Guidelines, Game Accessibility Guidelines, khung UX của Celia Hodent / heuristic Nielsen, hướng dẫn cỡ vùng chạm iOS / Android, bài về HUD game nhập vai hành động). (2) Chạy smoke chụp **80 màn hình** của bản hiện tại (chương 1 → 9, kết thúc). (3) Chấm từng tiêu chí, liệt kê lỗi kèm ảnh, đề xuất sửa |
| Ảnh | [docs/images/ra-soat-ui/](images/ra-soat-ui/) — 6 bảng ghép 2×2 + 2 ảnh chi tiết |
| Trạng thái | ✅ **Đã duyệt và làm cả 3 đợt (04/11/2026)** — chủ dự án: *"Do as your propose"* → Q185–Q189 theo đề xuất (§6); kết quả §8 |
| Liên quan | [35](35-de-xuat-giao-dien-moi.md) (UI-40…49, giao diện "đồng chạm khắc" UI-41), [36](36-thiet-ke-lai-vfx-ky-nang.md) (FX-1), [37](37-icon-ky-nang.md) (icon IC-1) |

Lưu ý về đơn vị: game vẽ ở khung gốc **1366×768** rồi phóng theo cửa sổ (`stretch = canvas_items`). Cỡ chữ trong tài liệu này là **px khung gốc**; trên màn 1080p nhân ×1,41 (chữ 10 px gốc ≈ 14 px thật).

## 1. Tiêu chí chuẩn (tóm tắt nghiên cứu)

| # | Tiêu chí | Ngưỡng / cách đo dùng cho game này | Nguồn |
| --- | --- | --- | --- |
| T1 | **Cỡ chữ đọc được** | Xbox: chữ thân tối thiểu ~26 px ở 1080p trên TV; máy cầm tay: không dưới 14 px, nên 18 px ở 1080p. Với PC ngồi gần, lấy mốc **18 px ở 1080p ≈ 13 px gốc** cho chữ thân, **≥ 11 px gốc** cho chú thích phụ. Người chơi phải chỉnh được cỡ chữ | XAG 101; hướng dẫn máy cầm tay Xbox; GAG "cỡ chữ mặc định dễ đọc" |
| T2 | **Tương phản** | Chữ trên nền ≥ **4,5 : 1** (WCAG AA); đo ở chỗ nền kém tương phản nhất (nền cảnh thay đổi theo map); chữ đặt trên cảnh phải có viền / nền đệm | XAG 102 |
| T3 | **Không dùng màu làm kênh duy nhất** | Thông tin quan trọng (hệ, độ hiếm, bậc quái, trạng thái) phải có thêm ký hiệu / chữ / hình dạng; nên có bảng màu cho người mù màu (đỏ–lục, lam–cam) | GAG (mức cơ bản); XAG 103; Apple HIG |
| T4 | **Thứ bậc thông tin trên HUD** | Xếp theo độ khẩn: sống còn (máu, đòn nguy hiểm) luôn hiện, to, tương phản cao, có chuyển động; thông tin phụ nhỏ / ẩn. Lỗi hay gặp: mọi thứ cùng "trọng lượng" → mắt không biết nhìn đâu | Các bài HUD (RocketBrush, Bugnet, UX Collective "7 lỗi HUD") |
| T5 | **Tách lớp phản hồi tức thời** | Số sát thương, nhặt đồ, thông báo là lớp "phản hồi" ngắn hạn, tách khỏi HUD cố định; không để hiệu ứng / chữ nổi thành nhiễu | Các bài HUD |
| T6 | **Dấu hiệu và phản hồi** (Signs & Feedback), **rõ ràng** (Clarity), **hình thức theo chức năng** | Mỗi hành động có phản hồi; nút trông bấm được, nút khoá phải nói vì sao khoá | Celia Hodent — *The Gamer's Brain* (dựa trên heuristic Nielsen) |
| T7 | **Nhất quán** | Một ngôn ngữ hình ảnh cho mọi màn hình: cùng khung, nút, màu chữ, trạng thái | Heuristic Nielsen / Shneiderman |
| T8 | **Giảm tải nhận thức** | Không đổ danh sách dài lên màn đầu; thông tin trùng lặp ở nhiều chỗ là tải thừa | Heuristic Nielsen ("thiết kế tối giản") |
| T9 | **Vùng chạm** (nếu lên mobile) | Tối thiểu 44 pt (iOS) / 48 dp (Android), cách nhau ≥ 8 dp; nút hay dùng trong tầm ngón cái | Apple HIG, Material Design |
| T10 | **Tuỳ biến** | Đổi phím trong game, cỡ chữ, bật / tắt chữ nổi, bảng màu, giảm chớp | XAG 101 / 103, GAG |

## 2. Chấm điểm hiện trạng

| # | Tiêu chí | Kết quả | Nhận xét ngắn |
| --- | --- | --- | --- |
| T1 | Cỡ chữ | ❌ Chưa đạt | Nhiều chữ 9–11 px gốc (≈ 13–15 px ở 1080p): dòng phụ thanh tài nguyên, số HP/MP khung chân dung, bảng chi phí Lò Rèn, tooltip đồ, nhãn khoá. Có chỉnh cỡ chữ (Nhỏ / Vừa / Lớn / Rất lớn, mặc định Vừa) nhưng nhiều chữ vẽ tay không theo, khung chân dung HUD còn thu ×0,75 |
| T2 | Tương phản | ⚠ Một phần | Khung đồng / giấy da tốt. Chữ xám phụ trên nền rêu và chữ trắng trên map sáng (Thiên Thê) kém; nút khoá gần như vô hình |
| T3 | Màu | ⚠ Một phần | Bậc quái có chữ ("Thường", "Tinh anh") ✅. Hệ của kỹ năng (viền ô) và độ hiếm đồ (viền ô túi) **chỉ bằng màu** |
| T4 | Thứ bậc HUD | ❌ Chưa đạt | "45 combo · +9% EXP" chữ vàng to giữa mép phải nặng hơn cả thanh máu; **không có cảnh báo máu thấp** |
| T5 | Lớp phản hồi | ❌ Chưa đạt | EXP / vàng / đồ rơi / "Thiếu MP" / sát thương chồng lên tên nhân vật; nhật ký 5–6 dòng luôn hiện lặp lại cùng thông tin |
| T6 | Dấu hiệu, phản hồi | ⚠ Một phần | Kỹ năng, cụm nút có hồi chiêu, chú thích tốt. Nút khoá ("Phân bổ tự động", "Cường hoá +11") không nói lý do |
| T7 | Nhất quán | ❌ Chưa đạt | **3 ngôn ngữ hình ảnh** cùng lúc (§3, V1) |
| T8 | Giảm tải | ⚠ Một phần | Màn tiêu đề đổ 20 dòng phím tắt; tab Thiên phú dày chữ |
| T9 | Vùng chạm | ✅ Đạt (cụm nút) / ⚠ thanh kỹ năng | Cụm nút góc phải ⌀ 48 px gốc; ô thanh kỹ năng ~40 px, sát nhau |
| T10 | Tuỳ biến | ⚠ Một phần | Có cỡ chữ, âm lượng, rung, giảm chớp. **Không đổi phím trong game** (bảng Cài đặt còn ghi chữ cho lập trình viên "Project Settings → Input Map"), không có bảng màu mù màu, không tắt được chữ nổi / tên quái |

## 3. Các vấn đề cụ thể

Mức: **Cao** = ảnh hưởng mọi người chơi mỗi phút chơi; **TB** = một số màn / tình huống; **Thấp** = trau chuốt.

| Mã | Mức | Vấn đề | Ở đâu (ảnh) |
| --- | --- | --- | --- |
| V1 | Cao | **3 ngôn ngữ hình ảnh**: (a) đồng chạm khắc + rêu (UI-41: khung bảng, thanh kỹ năng, cụm nút, nhiệm vụ); (b) tím – vàng (khung chân dung HUD, nhãn tên); (c) **xanh đen phẳng cũ** (màn tiêu đề, chọn ô nhân vật, Cài đặt, màn chiến thắng chương, chọn kết thúc) | [1-man-dau](images/ra-soat-ui/1-man-dau.png), [4](images/ra-soat-ui/4-cua-hang-ky-nang-cai-dat.png) (Cài đặt), [6](images/ra-soat-ui/6-cuoi-game.png), [chi-tiet-chu-nho](images/ra-soat-ui/chi-tiet-chu-nho.png) |
| V2 | Cao | **Chữ quá nhỏ** (T1) ở HUD và bảng (khung chân dung vẽ ×0,75 nên chữ 11 px thành ~8 px) | [chi-tiet-chu-nho](images/ra-soat-ui/chi-tiet-chu-nho.png), [3](images/ra-soat-ui/3-bang-nhan-vat.png) |
| V3 | Cao | **Chữ nổi chồng nhau**: "+2634 EXP", "+1 Đá Cường Hoá", "Thiếu MP", sát thương, tên nhân vật chồng một chỗ; **tên quái** "Thường · Thiên Binh Ngũ Hành · Lv95" hiện cho mọi con, đông quái thì đè nhau thành một mảng | [chi-tiet-chu-chong](images/ra-soat-ui/chi-tiet-chu-chong.png), [5](images/ra-soat-ui/5-ban-do-tro-giup-cong.png) (trong cổng), [6](images/ra-soat-ui/6-cuoi-game.png) (Thiên Thê) |
| V4 | Cao | **Màn đầu kém ấn tượng**: tiêu đề chữ trên nền tối trơn, không có hình, kèm danh sách 20 phím tắt; chọn ô nhân vật là các thẻ trống phẳng | [1-man-dau](images/ra-soat-ui/1-man-dau.png) |
| V5 | TB | **Nhiễu, trùng lặp**: nhật ký 5–6 dòng góc trái luôn hiện (lặp lại chữ nổi), dòng combo to ở giữa mép phải, banner — cùng lúc | [2-chien-dau](images/ra-soat-ui/2-chien-dau.png) |
| V6 | TB | **Không có cảnh báo máu thấp** (viền màn hình đỏ, nhịp tim) — thông tin sống còn chỉ nằm ở vòng máu nhỏ góc trái | — |
| V7 | TB | **Cài đặt**: lộ chữ lập trình viên; không đổi phím; không có mục Trợ năng (mù màu, ẩn chữ nổi, kiểu tên quái) | [4](images/ra-soat-ui/4-cua-hang-ky-nang-cai-dat.png) |
| V8 | TB | **Chỉ dùng màu**: hệ kỹ năng (viền ô), độ hiếm đồ (viền ô túi) | [3](images/ra-soat-ui/3-bang-nhan-vat.png) |
| V9 | TB | **Nút khoá** gần như vô hình, không nói lý do; tooltip so sánh đồ che nửa bảng; tab Thiên phú chữ dày đặc | [3](images/ra-soat-ui/3-bang-nhan-vat.png), [4](images/ra-soat-ui/4-cua-hang-ky-nang-cai-dat.png) (Lò Rèn) |
| V10 | TB | **Map sáng** (Thiên Thê): chữ trắng viền mỏng chìm vào nền | [6](images/ra-soat-ui/6-cuoi-game.png) |
| V11 | TB | Màn **chọn lớp** bị cắt dòng chữ đáy ("NĂM CON ĐƯỜNG…") ở 1366×768 | [1-man-dau](images/ra-soat-ui/1-man-dau.png) |
| V12 | Thấp | Thanh tài nguyên trên cùng: 7 con số + 2 dòng chữ phụ xám nhỏ — đông, khó quét | [2](images/ra-soat-ui/2-chien-dau.png) |
| V13 | Thấp | Màn chiến thắng chương / kết thúc: chữ trên nền tối, không có thẻ phần thưởng, không cùng khung đồng | [2](images/ra-soat-ui/2-chien-dau.png), [6](images/ra-soat-ui/6-cuoi-game.png) |
| V14 | Thấp | Rìa sương mù là các ô vuông răng cưa | [2](images/ra-soat-ui/2-chien-dau.png) |

Điểm **đã tốt**, nên giữ: bảng Nhân vật / Kỹ năng / Lò Rèn / Cửa hàng theo khung đồng (UI-26…28, UI-41); cuộn nhiệm vụ giấy da có thanh tiến độ; bản đồ khai phá lục giác; cụm nút góc phải mới (UI-41c/d); icon kỹ năng IC-1; thanh máu boss + "Phá Thế"; bảng chuyển chức.

## 4. Đề xuất thiết kế lại

### 4.1 Nền tảng: một hệ thiết kế duy nhất (UI-50)

Gom mọi thông số vào `ui_theme.gd` + `bronze.gd` thành **token** dùng chung, rồi chuyển các màn hình kiểu cũ sang:

| Token | Đề xuất |
| --- | --- |
| Thang cỡ chữ (px gốc) | Chú thích **11** (tối thiểu, chỉ số phụ) · Thân **13** · Nhấn **15** · Tiêu đề mục **18** · Tiêu đề bảng **24** (Cormorant SC) · Tiêu đề lớn **40+**. Cấm dưới 11 |
| Màu chữ theo vai trò | `text` kem #f1e6cc, `text_dim` #b9ab8c (đạt 4,5:1 trên rêu #1b251f), `text_off` (khoá, kèm biểu tượng ổ khoá), `accent` vàng #f3d78e, `good` / `bad`; mọi chữ đặt trên cảnh có viền tối 3 px hoặc nền đệm |
| Nút | 4 trạng thái thấy rõ: thường / rê chuột (sáng viền) / bấm (lún 1 px) / **khoá** (xám + ổ khoá + chú thích "Cần …") |
| Khung | 3 loại: bảng lớn (khung đồng + ngọc + phù hiệu), khung nhỏ HUD, cuộn giấy da (nhiệm vụ, lời thoại, kết quả) |
| Độ hiếm / hệ | Màu **+ ký hiệu** (§4.5) |
| Khoảng cách | Lưới 4 px (4 / 8 / 12 / 16 / 24) |

Khung chân dung HUD (tím – vàng) đổi sang đồng + ngọc tím cho khớp.

### 4.2 HUD trong trận

| Mã | Đề xuất | Tiêu chí |
| --- | --- | --- |
| UI-51 | **Cỡ chữ + tương phản HUD**: số HP / MP trong khung chân dung ≥ 13 px, dòng phụ thanh tài nguyên ≥ 11 px màu `text_dim`; cỡ chữ theme không dưới 11 px | T1, T2 |
| UI-52 | **Lớp chữ nổi có luật**: (1) sát thương nảy ra theo hướng đòn, chí mạng to hơn + rung nhẹ; cộng dồn nhiều đòn nhỏ trên cùng mục tiêu trong 0,3 giây; (2) **EXP / vàng / đồ rơi không nổi trên đầu nhân vật nữa** — gom vào **dải nhặt đồ** cạnh trái màn hình (biểu tượng + số, gộp "+157 vàng ×3"), tự mờ sau 3 giây; (3) "Thiếu MP", "Đang hồi chiêu" hiện cạnh ô kỹ năng vừa bấm; (4) tối đa ~8 chữ nổi cùng lúc, chữ mới đẩy chữ cũ lên, không chồng | T4, T5 |
| UI-53 | **Tên quái gọn**: mặc định chỉ hiện với mục tiêu đang đánh / chuột trỏ / tinh anh / boss / quái đang mất máu; dạng ngắn "biểu tượng bậc + Lv95 Thiên Binh"; tên dài tự rút gọn; tên chồng nhau thì đẩy lệch. Cài đặt: Luôn / Thông minh (mặc định) / Tắt | T5, T8 |
| UI-54 | **Nhật ký thu gọn**: 2 dòng mới nhất, tự mờ sau 6 giây; rê chuột / phím để mở cả lịch sử. Dòng combo nhỏ lại, chuyển xuống cạnh cụm nút (dạng huy hiệu "×45 · +9%") | T4, T8 |
| UI-55 | **Cảnh báo máu thấp**: dưới 30% HP → viền màn hình đỏ nhấp nháy theo nhịp tim + âm nhịp tim nhẹ (tắt được); bình máu Q sáng viền gợi ý bấm | T4, T6 |
| UI-56 | **Thanh tài nguyên trên cùng** gọn: 1 hàng số chính (vàng, Đá, Tinh Hoa…), dòng "vùng · cấp · khám phá" chuyển xuống dưới la bàn (gắn với bản đồ) | T4, T8 |

### 4.3 Màn đầu và màn kết quả

| Mã | Đề xuất |
| --- | --- |
| UI-57 | **Màn tiêu đề có hình**: cảnh nền vẽ bằng code HD (Bia Đá giữa sương, ánh sáng xanh, rừng hai bên, hạt sương trôi chậm), logo chữ cổ vàng có viền đồng, 3 nút đồng lớn (Hành trình mới / Tiếp tục / Cài đặt) + Thoát; **bỏ danh sách phím tắt** (đã có F1 và hướng dẫn trong game) |
| UI-58 | **Chọn ô nhân vật**: thẻ khung đồng có hình nhân vật đứng trên bệ, tên, lớp, cấp, Thiên phú, thời gian chơi; ô trống là bệ đá có dấu "+" |
| UI-59 | **Màn chiến thắng chương / chọn kết thúc**: cuộn giấy da / khung đồng, **thẻ phần thưởng** (EXP, vàng, đồ có viền độ hiếm), bản đồ 9 vùng thành chuỗi ấn đồng sáng dần |
| UI-60 | Sửa màn chọn lớp bị cắt đáy (V11): co chiều cao thẻ theo cửa sổ |

### 4.4 Bảng và Cài đặt

| Mã | Đề xuất |
| --- | --- |
| UI-61 | **Cài đặt mới** khung đồng, 4 tab: *Âm thanh* · *Hiển thị* (toàn màn hình, HD, hiệu ứng kỹ năng, cỡ chữ, cỡ giao diện) · *Điều khiển* (**đổi phím trong game**, bấm phím mới để gán, nút "Mặc định") · *Trợ năng* (bảng màu mù màu, chữ nổi bật / tắt từng loại, kiểu tên quái, cảnh báo máu thấp, giảm chớp, rung). Bỏ chữ "Project Settings → Input Map" |
| UI-62 | **Trạng thái khoá + tooltip**: nút khoá có ổ khoá và chú thích lý do ("Cần 1 Tinh Kim", "Lên cấp 30"); tooltip so sánh đồ đặt ra ngoài bảng (hoặc bên cạnh ô), không che nội dung; tab Thiên phú chia thẻ gấp được |

### 4.5 Không chỉ dùng màu (UI-63)

- **Hệ kỹ năng**: thêm ký hiệu nhỏ ở góc ô (Hoả 🔥, Thuỷ 💧, Mộc 🍃, Kim ⚔, Thổ ⛰ — vẽ bằng code, không dùng emoji) bên cạnh viền màu.
- **Độ hiếm đồ**: viền màu + chữ cái góc (T / X / L / Tm / C) hoặc số chấm; tooltip đã có tên độ hiếm.
- **Bảng màu mù màu** (Cài đặt → Trợ năng): đổi cặp đỏ – lục (máu / hồi phục, xấu / tốt) sang cam – lam.

## 5. Lộ trình đề xuất

| Đợt | Nội dung | Lý do | Kiểm tra |
| --- | --- | --- | --- |
| **Đợt 1 — sửa nhanh, ảnh hưởng lớn** | UI-51, UI-52, UI-53, UI-54, UI-55, UI-60; bỏ chữ lập trình viên ở Cài đặt | Người chơi thấy ngay mỗi trận; ít đụng tới bố cục bảng | Test mới (đếm chữ nổi chồng nhau trong cảnh đông quái, kiểm tra cỡ chữ tối thiểu ≥ 11 px theo theme), smoke chương 1 + Thiên Thê |
| **Đợt 2 — đồng bộ hình ảnh** | UI-50 (token), UI-57, UI-58, UI-59, UI-61, khung chân dung HUD, UI-56 | Gỡ V1 (3 ngôn ngữ hình ảnh), ấn tượng đầu tiên | Ảnh smoke trước / sau mọi màn, test tương phản tự động (tính tỉ lệ cho các cặp màu token) |
| **Đợt 3 — trau chuốt, trợ năng** | UI-62, UI-63, bảng màu mù màu, sương mù viền mềm (V14), chuẩn bị mobile (ô thanh kỹ năng ≥ 44 px, vùng an toàn) nếu chọn mobile | Hoàn thiện theo T3, T9, T10 | Smoke + ảnh mô phỏng mù màu |

Mỗi đợt: viết spec chi tiết → chủ dự án duyệt ảnh → code → test → cập nhật spec (như các đợt trước). Không đụng hình nhân vật / kỹ năng của chủ dự án (chỉ khung, chữ, bố cục, icon giao diện).

## 6. Câu hỏi cho chủ dự án

| Mã | Câu hỏi | Đề xuất |
| --- | --- | --- |
| Q185 | Nền tảng chính khi phát hành: **PC** hay **mobile** (hay cả hai)? Quyết định cỡ ô thanh kỹ năng, cỡ chữ, vị trí nút | PC trước, giữ cụm nút chạm được để sau làm mobile |
| Q186 | Làm theo lộ trình §5 (đợt 1 → 3)? | Đồng ý, bắt đầu đợt 1 |
| Q187 | Tên quái mặc định: **Thông minh** (chỉ mục tiêu / tinh anh / boss / quái mất máu) hay **Luôn hiện** như hiện nay? | Thông minh |
| Q188 | EXP / vàng / đồ rơi: chuyển sang **dải nhặt đồ** cạnh trái (bỏ chữ nổi trên đầu nhân vật)? | Có |
| Q189 | Màn tiêu đề: cảnh nền **vẽ bằng code HD** (như cảnh UI-40) hay chủ dự án gửi **tranh minh hoạ**? | Vẽ bằng code trước; nếu có tranh thì thay vào sau |

**Trả lời (04/11/2026):** chủ dự án *"Do as your propose"* → Q185 = PC trước (giữ cụm nút chạm được), Q186 = làm cả 3 đợt, Q187 = Thông minh, Q188 = có, Q189 = vẽ bằng code (D82).

## 8. Đã làm (04/11/2026)

| Mã | Đã làm | Mã nguồn |
| --- | --- | --- |
| UI-51 | `UiTheme.MIN_FONT` = 11: mọi cỡ chữ qua `fs()` không dưới 11 px gốc; khung chân dung HUD: số HP/MP 17 px, "/ tối đa" 14 px, EXP 15 px, "Điểm" 13 px (khung vẽ ×0,75) | `ui/ui_theme.gd`, `ui/char_frame.gd` |
| UI-52 | Chữ nổi: tối đa 10 chữ (mới nhất), chữ trùng chỗ đẩy lên trên, không chồng. EXP / vàng / Đá / đồ rơi / hồi máu → **dải nhặt đồ** bên trái (ngọc màu + chữ, gộp số, giữ 2,4 giây) | `view/world_view.gd` (`_draw_texts`), `ui/pickup_feed.gd`, `GameWorld.PICKUP_NOTE_TTL` |
| UI-53 | Bảng tên quái theo Cài đặt `nameplates`: **Thông minh** (mặc định; quái thường chỉ hiện khi là mục tiêu hoặc đã mất máu, dạng ngắn "Lv N Tên"), Luôn hiện (như cũ), Chỉ quái mạnh. Bảng tên trùng chỗ: quái thường bỏ qua, quái mạnh đẩy lên | `view/world_view.gd` (`_enemy_nameplate`) |
| UI-54 | Nhật ký 3 dòng (cũ 5); dòng combo nhỏ (15 px) đặt ngay trên cụm nút, dạng "×N combo · +x% EXP" | `ui/hud.gd` |
| UI-55 | Viền màn hình đỏ đập theo nhịp tim khi HP < 30% (nhanh dần khi máu càng thấp); bình máu Q viền đỏ gợi ý bấm; tắt được (Trợ năng) | `ui/low_hp_overlay.gd`, `ui/hud.gd` |
| UI-56 | Thanh tài nguyên trên cùng còn 1 hàng số (+ dòng Đuốc hồi khi có); dòng "vùng · cấp · khám phá" chuyển xuống dưới la bàn | `ui/hud.gd` |
| UI-57 | Màn tiêu đề: cảnh nền vẽ bằng code (trời đêm, núi, rừng thông, Bia Đá phát sáng + cột sáng, sương trôi, đốm sáng), logo Cormorant SC vàng 72 px, cột nút lớn; bỏ bảng 20 phím tắt (còn 1 dòng gợi ý F1 / đổi phím); chưa có nhân vật thì ẩn "Tiếp tục" | `ui/screens.gd` (`Backdrop`, `title`) |
| UI-58 | Chọn nhân vật: cảnh nền mờ + thẻ khung đồng, ô trống có dấu "+" | `ui/screens.gd` (`slots`) |
| UI-59 | Màn kết chương, chọn kết thúc, danh đề: khung đồng (SolidPanel), tiêu đề chữ cổ; số liệu kết chương thành 5 ô nhỏ | `ui/screens.gd` |
| UI-60 | Màn chọn lớp tự thu nhỏ vừa cửa sổ (dòng chân không còn bị cắt) | `ui/class_select.gd` (`_fit`) |
| UI-61 | Cài đặt khung đồng 4 tab: Âm thanh · Hiển thị · **Điều khiển** (đổi 28 phím trong game, gán phím đang dùng thì thao tác kia mất phím, nút khôi phục mặc định) · **Trợ năng** (tên quái, cảnh báo máu thấp, bảng màu mù màu, rung, giảm chớp); bỏ chữ "Project Settings → Input Map". Menu tạm dừng cùng khung đồng | `ui/pause_menu.gd`, `core/keybinds.gd`, `core/settings.gd`, `main.gd` |
| UI-62 | Nút khoá: nền đá xám + chữ xám sáng (tương phản 5,1 : 1, cũ gần như vô hình); rê chuột hiện lý do khoá ở các nút có điều kiện (Lò Rèn, túi đồ, chuyển chức, bản đồ khai phá, Thiên phú, kỹ năng, cửa hàng, phân bổ điểm) | `ui/ui_theme.gd`, các bảng |
| UI-63 | Biểu tượng hệ ở góc ô kỹ năng (cạnh viền màu); chấm phẩm chất 1–5 ở góc ô đồ; bảng màu mù màu: tốt / xấu đổi lục / đỏ → lam / cam (so sánh đồ, chữ HUD dùng `UiTheme.GOOD/BAD`) | `ui/skill_bar.gd`, `ui/inventory_panel.gd`, `ui/item_tip.gd`, `UiTheme.set_colorblind` |
| UI-50 | Khung chân dung HUD đổi tông vàng – tím sang đồng (ngọc tím EXP giữ); mọi màn hình kiểu cũ (tiêu đề, chọn nhân vật, Cài đặt, tạm dừng, kết chương, kết thúc, danh đề) dùng khung đồng | `ui/char_frame.gd`, `ui/screens.gd`, `ui/pause_menu.gd` |
| V14 | Rìa sương mù mềm (làm mờ 5×5 bằng shader) | `view/world_view.gd` (`FogLayer`) |

Chưa làm (để sau, không cần cho PC — Q185): ô thanh kỹ năng ≥ 44 px và vùng an toàn cho mobile. Bảng Trợ giúp F1 vẫn ghi phím mặc định (chưa đọc phím đã đổi).

Kiểm tra: test **UI38-T1** (cỡ chữ tối thiểu, máu thấp, đổi phím + khôi phục, Cài đặt 4 tab, tiêu đề mới, dải nhặt đồ / tên quái / nhật ký); UI41-T1; smoke chụp lại toàn bộ màn hình ([images/ra-soat-ui/sau-*.png](images/ra-soat-ui/)).

## 7. Nguồn

- Xbox Accessibility Guideline 101 — Text display: https://learn.microsoft.com/da-dk/gaming/accessibility/xbox-accessibility-guidelines/101 · bản chi tiết: https://devdocs.xbox.com/build/game-principles/accessibility/xag-deep-dives/xag-101-text-display.md
- Xbox Accessibility Guideline 102 — Contrast: https://learn.microsoft.com/en-us/gaming/accessibility/xbox-accessibility-guidelines/102
- Xbox Accessibility Guideline 103 — Additional channels for visual and audio cues: https://learn.microsoft.com/en-gb/gaming/accessibility/xbox-accessibility-guidelines/103
- Xbox handheld guidelines (cỡ chữ tối thiểu 14 px, nên 18 px ở 1080p): https://devdocs.xbox.com/build/gdk-and-engines/handheld/handheld-guidelines-and-testcases.md
- Game Accessibility Guidelines (tóm tắt mức cơ bản): https://www.webbie.org.uk/blog/?p=115 · https://www.abratabia.com/game-accessibility/accessibility-guidelines.php
- Apple HIG — Accessibility (màu, mù màu): https://developer.apple.com/design/human-interface-guidelines/accessibility.md
- Celia Hodent — UX của Fortnite, khung usability / engage-ability: https://www.designative.info/2019/03/28/the-ux-of-fortnite-celia-hodent/ · https://uxdesign.cc/usability-heuristics-and-competition-in-games-707cac36ff12
- Vùng chạm: https://www.smashingmagazine.com/2012/02/finger-friendly-design-ideal-mobile-touchscreen-target-sizes/ · https://blog.openreplay.com/improving-tap-targets-mobile-ux/
- HUD: https://rocketbrush.com/blog/designing-practical-and-pretty-hud-in-video-games · https://bugnet.io/blog/how-to-design-a-readable-hud · https://bootcamp.uxdesign.cc/7-obvious-beginner-mistakes-with-your-games-hud-from-a-ui-ux-art-director-d852e255184a · https://www.strayspark.studio/blog/game-ui-ux-design-principles
