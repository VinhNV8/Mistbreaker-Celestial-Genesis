# Đề xuất giao diện mới — bớt "pixel", đẹp hơn (Spec_Notes 02/11)

| | |
| --- | --- |
| Dự án | Thiên Phú Khai Giới |
| Nguồn | Spec_Notes 02/11/2026: *"Cần cải thiện giao diện, giao diện hiện tại pixel quá người chơi không thích → Người chơi muốn giao diện đẹp cơ → hãy lên kế hoạch đề xuất giao diện"* |
| Loại tài liệu | Đề xuất + quyết định (03/11/2026: **Q176 = B**, **Q177 = cel-shade mobile**; Q178, Q179 theo đề xuất mặc định cho tới khi chủ dự án nói khác) |
| Liên quan | [07](07-do-hoa-ke-hoach.md) mục 1 (quyết định DH-01: pixel art sinh bằng code), UI-26…28d (bảng Nhân vật theo ảnh mẫu) |

## 1. Hiện trạng: "pixel" nằm ở đâu

Ảnh smoke 02/11 (`03-combat`, `05b-inventory`, `05g-skills`, `01-title`):

| Lớp | Hiện tại | Mức "pixel" |
| --- | --- | --- |
| Khung bảng (Nhân vật, Kỹ năng, HUD, thanh kỹ năng) | Khung vàng–nâu có hoa văn, chữ Be Vietnam Pro mượt (UI-26…28d) | Thấp — khung đã "game thương mại", chỉ thiếu chiều sâu (bóng, chất liệu) |
| **Nhân vật, quái, boss** | Sinh bằng code, frame 32×32 (quái 24, boss 48), phóng ×2 lọc Nearest | **Cao** — đây là chỗ người chơi thấy "pixel" nhiều nhất |
| **Icon** đồ / kỹ năng / Thiên phú | 32×32 phóng lên 48–74 px | **Cao** — ô túi đồ, cây kỹ năng nhìn răng cưa |
| Cảnh (cây, đá, cỏ, nền đất) | Ô 32×32, cây pixel | Cao |
| Hiệu ứng kỹ năng | Sprite sheet pixel (AR-44/45b) + vẽ code | Trung bình |
| **Màn hình tiêu đề, tạo nhân vật** | Nền tối trơn, chữ + bảng phím | Không pixel nhưng **trống, không có hình** — ấn tượng đầu tiên kém |

**Kết luận**: muốn hết cảm giác "pixel" phải đổi **hình nhân vật / quái / icon / cảnh**, không chỉ khung giao diện. Riêng khung giao diện và màn hình đầu thì làm đẹp được ngay bằng code.

## 2. Ràng buộc cần nói rõ

- Toàn bộ hình hiện tại **sinh bằng code Python** (DH-01, 07 mục 1.1): miễn phí, đồng nhất, nhưng trần chất lượng thấp. Code vẽ được kiểu **vector phẳng / cel-shade mượt độ phân giải cao** (giống game mobile casual), **không** vẽ được kiểu tranh vẽ tay chi tiết (anime, painterly).
- Hình "đẹp như game thương mại" (nhân vật vẽ tay, minh hoạ) cần **hoạ sĩ** hoặc **AI tạo ảnh** — 07 mục 1.1 đã gác lại vì chi phí / bản quyền / không đồng nhất frame. Cần chủ dự án quyết lại.
- Game đang có ~400 hình (169 icon 32 px, 153 sheet nhân vật/quái, ~90 hình cảnh). Đổi phong cách toàn bộ là việc lớn; đổi theo giai đoạn được vì `art_manifest.json` tách khung cắt frame khỏi code.

## 3. Ba hướng

| | A. Làm mới giao diện, giữ thế giới pixel | **B. HD vector toàn bộ (sinh bằng code) — đề xuất** | C. Vẽ tay / AI tạo ảnh |
| --- | --- | --- | --- |
| Làm gì | Khung bảng có chiều sâu (bóng, chất liệu da/kim loại), **icon vẽ lại mượt 128 px**, màn hình tiêu đề / tạo nhân vật có minh hoạ, chuyển cảnh, chữ nổi đẹp | A **+** vẽ lại nhân vật / quái / boss / cảnh bằng **vector mượt độ phân giải ×4** (nhân vật 128 px, viền mềm, đổ bóng, khử răng cưa), lọc Linear | Nhân vật, quái, minh hoạ vẽ tay (hoạ sĩ) hoặc AI tạo rồi dọn; code chỉ thay hình |
| Hết "pixel"? | Một phần — UI hết, nhân vật / cảnh vẫn pixel | **Hết** — phong cách "2D mobile casual" (kiểu game nhập vai mobile phổ biến) | Hết, đẹp nhất |
| Ai làm | Claude (code) | Claude (code, bộ vẽ vector mới thay bộ pixel) | Hoạ sĩ / dịch vụ AI + Claude ghép |
| Thời lượng (ước tính) | 1–2 đợt | 4–6 đợt (chia giai đoạn, mục 4) | Phụ thuộc hoạ sĩ; code ghép 1–2 đợt |
| Chi phí ngoài | 0 | 0 | Có (thuê / gói AI), cần xem bản quyền |
| Rủi ro | Người chơi vẫn chê nhân vật pixel | Chất lượng trần của hình code — làm **bản thử 1 lớp + 1 map** trước để duyệt | Không đồng nhất giữa các hình; chi phí; chậm |

**Đề xuất: B, chia giai đoạn, bắt đầu bằng bản thử** — không tốn chi phí ngoài, giữ được ưu điểm "thêm quái mới chỉ cần khai báo tham số", và chủ dự án duyệt bằng ảnh trước khi đổi toàn bộ. Nếu bản thử chưa đạt, chuyển C (lúc đó bộ khung kích thước / frame mới dùng lại cho hoạ sĩ).

## 4. Lộ trình (hướng B)

| Giai đoạn | Mã | Nội dung | Duyệt |
| --- | --- | --- | --- |
| **G0 — Bản thử** | UI-40 | Bộ vẽ vector mới (`tools/art/hd/`): vẽ ở ×4 rồi thu về, viền mềm, đổ bóng, gradient. Làm **Kiếm Khách + Sói Sương + Sói Chúa + 10 icon + cảnh Rừng Sương (cây, đá, cỏ, nền)**. Ảnh so sánh trước / sau cùng góc máy | Chủ dự án xem ảnh, chọn đi tiếp / chỉnh / chuyển C |
| G1 — Giao diện | UI-41…45 | Màn hình tiêu đề có minh hoạ (Bia Đá, sương, nhân vật), tạo nhân vật có hình lớp; khung bảng có chiều sâu; icon 128 px cho đồ / kỹ năng / Thiên phú / tài nguyên; HUD (khung chân dung, thanh máu bóng, số sát thương đẹp hơn); chuyển cảnh mờ dần | Ảnh smoke |
| G2 — Nhân vật | UI-46 | 5 lớp × 3 hình chuyển chức, thú cưng, đồng minh, NPC | Ảnh smoke |
| G3 — Quái, boss | UI-47 | Quái 9 vùng, 9 boss vùng, 9 boss hiếm, boss cuối | Ảnh smoke |
| G4 — Cảnh, hiệu ứng | UI-48, 49 | Nền đất / cây / đá / công trình 9 vùng; hiệu ứng kỹ năng vẽ lại cùng phong cách | Ảnh smoke + video ngắn |

Mỗi giai đoạn giữ game chạy được (hình mới thay dần qua `art_manifest.json`; hình chưa vẽ lại vẫn dùng bản pixel), test smoke chụp ảnh như hiện nay.

## 5. Câu hỏi cho chủ dự án

| Mã | Câu hỏi | Đề xuất |
| --- | --- | --- |
| Q176 | Hướng nào: A (chỉ giao diện) / **B (HD vector, code vẽ)** / C (vẽ tay / AI) | B, bắt đầu G0 |
| Q177 | Phong cách hình mong muốn (có ảnh game tham chiếu càng tốt): cel-shade mobile casual / chibi dễ thương / tranh vẽ tối tăm (dark fantasy) | Cel-shade, tỉ lệ người ~1:4, viền tối mềm, màu tươi — hợp bối cảnh Hán-Việt tiên hiệp và vẽ được bằng code |
| Q178 | Có ngân sách / chấp nhận AI tạo ảnh cho **minh hoạ tĩnh** (màn tiêu đề, chân dung NPC, thẻ Thiên phú) không? | Nếu có: chỉ dùng cho minh hoạ tĩnh, nhân vật trong trận vẫn code vẽ |
| Q179 | Màn hình mục tiêu: PC trước hay mobile trước (ảnh hưởng cỡ chữ, cỡ nút, độ chi tiết hình) | PC trước (đang làm PC), giữ bố cục co giãn |

## 6. Quyết định (03/11/2026)

| Mã | Chọn |
| --- | --- |
| Q176 | **B — HD vector, code vẽ**, chia giai đoạn, bắt đầu bản thử G0 |
| Q177 | **Cel-shade mobile**: viền tối mềm, màu tươi, tỉ lệ người ~1:4 |
| Q178 | Chưa trả lời — tạm không dùng AI tạo ảnh |
| Q179 | Chưa trả lời — tạm PC trước |

## 7. Kết quả bản thử G0 (UI-40, 03/11/2026) — chờ chủ dự án duyệt

| Ảnh | Nội dung |
| --- | --- |
| [g0-hd.png](images/ui40/g0-hd.png) / [g0-pixel.png](images/ui40/g0-pixel.png) | **Cùng một cảnh** Rừng Sương (3 Sói Sương, Sói Chúa Hư Vô, cây, bụi, nền cỏ): HD cel-shade / pixel cũ. *Ảnh chụp trước 03/11 rollback nên còn Kiếm Khách HD — nay đã gỡ* |
| [g0-hd-inventory.png](images/ui40/g0-hd-inventory.png) | Bảng Nhân vật: icon HD trong túi đồ và ô trang bị (icon đồ Cam riêng chưa vẽ lại). *Nhân vật HD trong ảnh đã gỡ (03/11)* |
| [g0-soi-chua-sheet.png](images/ui40/g0-soi-chua-sheet.png) | Sói Chúa Hư Vô: bờm tím, mắt hồng phát sáng, khói Hư Vô |
| [g0-forest.png](images/ui40/g0-forest.png) · [g0-icons.png](images/ui40/g0-icons.png) | Nền cỏ lặp liền mạch (256 px), 3 cây tán tròn, thông, bụi, 2 đá rêu · 10 icon 128 px |

- Vào game: Cài đặt (Esc) → **"Đồ hoạ HD"** bật / tắt để tự so sánh. Hình chưa vẽ lại vẫn dùng bản pixel.
- Kích thước hiển thị chỉnh cho bằng bản pixel (Kiếm Khách ×1,02, Sói Sương ×1,35, Sói Chúa ×1,3 so với khung) — va chạm, vị trí không đổi.
- Dung lượng: 1,1 MB cho 25 hình (ước tính toàn bộ ~20–30 MB khi xong G4).
- Test UI40-T1.
- **Bước tiếp**: chủ dự án duyệt → G1 (giao diện + icon toàn bộ) và G2 (5 lớp); hoặc góp ý chỉnh phong cách (màu, tỉ lệ đầu / người, độ dày viền) trước khi nhân rộng.

## 8. Rollback nhân vật (03/11/2026)

Chủ dự án: *"ảnh skills và nhân vật đang bị vẽ lại, phải rollback lại"*. **Quy tắc:** hình nhân vật người chơi (sprite sheet 5 lớp `tools/art/src/class-sheet.png`) và hình / hiệu ứng kỹ năng (AR-44, AR-45b, `class-skills.png`, `docs/design/skills/`) do chủ dự án cung cấp / duyệt — **giữ nguyên, không vẽ lại bằng HD**. Đã gỡ Kiếm Khách HD (`hero_kiem.py`, `assets/hd/sprites/pc-kiem-khach.png`); lớp phủ HD chỉ còn Sói Sương, Sói Chúa Hư Vô, cảnh Rừng Sương, 10 icon trang bị / tài nguyên. Các file hình gốc chưa từng bị sửa (HD là lớp phủ riêng). Test UI40-T1 kiểm `pc-*`, `hero-*`, `skill-*` không có bản HD.

Lộ trình G2 (mục 4) đổi thành: **không** vẽ lại 5 lớp nhân vật; chỉ thú cưng, đồng minh, NPC nếu chủ dự án đồng ý.

## 9. Làng Thanh Thạch HD (UI-40b, 03/11/2026)

Chủ dự án: *"khu vực thôn, giao diện xấu quá, cần design lại cho giống thực tế"*. Trước: nền tròn nâu viền cứng + 4 mái nhà pixel nhỏ giống nhau. Sau (HD cel-shade, cùng phong cách G0):

| Thành phần | Chi tiết |
| --- | --- |
| Nhà (`house-village-0/1/2`) | Nhà gỗ ván, cột + xà, nền đá, cửa 2 cánh hé đèn, cửa sổ song gỗ giấy sáng đèn; mái **ngói xám** đầu đao cong + đèn lồng đỏ / **ngói đỏ** + chum nước, chổi / **mái tranh** rơm buộc tre. Rộng ~120 px trong game (lều cũ 96 px) |
| Sân | Mép đất nện **lượn tự nhiên** (không còn vòng tròn), viền mờ hoà vào cỏ; **sân lát đá phiến** quanh bia; lối đất ra ruộng phía nam |
| Ranh giới vùng an toàn | **Hàng rào cọc gỗ** 2 thanh ngang (thay vòng viền nâu), chừa cổng đông (đường tới hang) và lối nam; 2 cột đèn lồng ở cổng đông |
| Đồ trang trí | Giếng đá mái ngói + tời, thùng gỗ / hòm / bao tải cạnh Thương nhân; ngoài rào: 3 luống rau, đống rơm |
| Bia đá | Bia đá xám khắc chữ phát sáng vàng (cùng cỡ bản pixel) |
| Cổng Dịch Chuyển | Đặt sẵn ở khoảng trống đông nam (`safe.waypoint`), không bị mái nhà che |

- Không đổi: nhân vật, NPC (Thạch Lão, Thương nhân), vị trí NPC, bán kính vùng an toàn, va chạm (nhà / đồ trang trí không chặn đường như trước).
- Tắt "Đồ hoạ HD": làng vẽ như cũ (4 lều pixel, nền tròn), chỉ cổng dịch chuyển đổi chỗ.
- Ảnh: [village-before-after.png](images/ui40/village-before-after.png) (trái pixel cũ / phải HD), [village-hd.png](images/ui40/village-hd.png), [village-sheet.png](images/ui40/village-sheet.png).
- Code: `tools/art/hd/env_village.py`; `Maps.safe_props()`, `safe.waypoint`; `world_view._draw_village_yard / _village_fence / _draw_fence_post`. Test UI40b-T1. Smoke `03h-village` / `03h2-village-pixel`.
- Thành Biên Đài (town), trạm gác (camp) chưa vẽ lại — làm tiếp nếu chủ dự án duyệt phong cách làng.

## 10. Toàn bộ map 9 vùng HD (UI-40c, 03/11/2026)

Chủ dự án: *"các map khác cũng xấu và giả tạo, phải thiết kế lại"*. Trước: mọi khu an toàn là vòng tròn viền cứng + 1–3 lều pixel; nền có mảng tròn mép cứng; cây / đá / cột pixel nhỏ ([regions-before.png](images/ui40/regions-before.png)). Sau: [regions-after.png](images/ui40/regions-after.png).

**Khu an toàn theo vùng** (`Maps.safe_theme()` — dữ liệu, `CAMP_THEMES`): sân mép lượn hoà vào nền, hàng rào cọc riêng mỗi vùng (chừa cổng đông + lối tây), 2–3 nhà theo bán kính, đống lửa / vật giữa sân, 2 đèn cổng đông, đồ đạc phía nam, cảnh quanh ngoài rào.

| Vùng | Nhà | Rào / sân | Đồ vật, cảnh quanh |
| --- | --- | --- | --- |
| 1 trạm gác | Chòi canh gỗ, lều vải, nhà mái tranh | Cọc gỗ / đất nện | Lửa trại, thùng hàng, đống rơm, luống rau |
| 2 Thành Biên Đài | 4 nhà vách trát khung gỗ mái ngói đỏ / xám, 2 tháp đá có cờ | Tường cột đá 3 thanh / sân đá cuội, quảng trường lát đá | Giếng, đèn lồng, thùng hàng |
| 2 trạm | Lều vải, chòi canh, nhà ngói đỏ | Cọc gỗ | Lửa trại, đống rơm |
| 3 Xích Sa | Lều tròn sọc đỏ kem, lều mái che + thảm, chum | Cọc nhọn dây thừng / cát đỏ | Đuốc, chum gốm, cây cọ ngoài rào |
| 4 U Minh | **Nhà sàn** mái tranh / ngói trên cột tre, thang | Cọc tre / bùn + sàn ván | Giàn phơi lưới cá, thuyền, lau sậy |
| 5 Viêm Long | Nhà đá bazan mái phiến (vết lửa), **lò rèn** mở có lò + đe, lều da đỏ | Cọc sắt / tro + đá bazan | Lò than, xe quặng |
| 6 Băng Nguyên | **Nhà gỗ súc** mái phủ tuyết + băng rủ, lều da phủ tuyết | Cọc gỗ đội tuyết / tuyết | Lửa trại, đống củi, xe trượt, thông tuyết |
| 7 Thiên Không | Đình mái ngói xanh cột cẩm thạch, **bến khí cầu**, lều vải | Trụ cẩm thạch / cỏ trời + sân cẩm thạch | Đèn lồng, mây |
| 8 Hư Vô | Miếu đá tím có tinh thể sáng, lều tím viền sáng | Cọc trấn tinh thể tím / đá vực + sân đá tím | Đèn Tinh Quang, cột Hư Vô |
| 9 Thiên Thê | Đình ngói ngọc bích / ngói vàng cột son | Trụ ngọc đỉnh vàng / sàn ngọc | Lư hương đồng toả khói, cột ngọc |

**Nền + cảnh vật** (`tools/art/hd/env_regions.py`, đè cùng id, cùng kích thước logic → vị trí / va chạm không đổi): 18 nền (thảo nguyên, đá cuội, cát, cát đỏ, di tích, đầm, tro, bazan, dung nham ×2, tuyết, băng nứt, cỏ trời, cẩm thạch, cầu gió, vực Hư Vô, sàn đấu trường Hư Vô, sàn Thiên Thê) và ~40 vật: đá đỏ, xương rồng, cọ, hồ ốc đảo, cột di tích, cây chết, lau sậy, lá súng, Bọc Mộng, đá dung nham, cây cháy, Đá Nổi, miệng phun, lò, thông tuyết, đá băng, gò tuyết, Đèn Cực Quang, mây, cây rừng treo, cột Thiên Cung, Đá Neo, Trụ Gió, Bia Đá gốc, Cột Đá Hư Vô, Đèn Tinh Quang, cột ngọc. Mảng loang trên nền vẽ mềm (4 vòng mờ dần) thay vòng tròn mép cứng.

- Không vẽ lại: nhân vật, NPC, quái, hình kỹ năng; Gương Băng (cùng hình quái `guong-bang` — để đợt quái G3).
- Cổng Dịch Chuyển: trại đặt ở khoảng trống phía nam (thử chỗ khác nếu có NPC / đồ đứng đó), thành đặt cố định.
- Tắt "Đồ hoạ HD": vẽ như cũ (vòng tròn + nhà pixel).
- Dung lượng HD: 3,3 MB (128 hình môi trường). Bảng hình: [camps-sheet.png](images/ui40/camps-sheet.png), [regions-sheet.png](images/ui40/regions-sheet.png).
- Test UI40b-T1 (mọi map: đủ hình HD, cổng không bị nhà / đồ / NPC che).
- Còn lại cùng phong cách: quái + boss (G3), hang phụ / cổng dungeon (dùng nền vùng), rương / thảo dược / vật phẩm rơi.

## 11. Giao diện "đồng chạm khắc" theo ảnh mẫu (UI-41, 03/11/2026)

Chủ dự án gửi ảnh mẫu giao diện fantasy (khung đồng, cuộn nhiệm vụ, la bàn, cụm nút tròn) và chọn làm trước 6 phần. Phần tranh vẽ tay của ảnh (cảnh nền, chân dung, icon) không vẽ bằng code; icon kỹ năng + nhân vật giữ hình gốc (chỉ đổi khung bọc).

| Phần | Làm |
| --- | --- |
| Khung viền | `ui/bronze.gd` `frame()`: nền xanh rêu tối, viền đồng 3 lớp (tối – đồng – gờ sáng trên / tối dưới), chấm + vạch chạm khắc dọc viền, góc tấm đồng hình thoi + cuộn hoa văn + ngọc xanh, bảng lớn có phù hiệu giữa cạnh trên. `FrameBox` gọi hàm này → **mọi khung** (HUD, túi đồ, cửa hàng, cài đặt…) đổi theo. Chữ tiêu đề **Cormorant SC Bold** (OFL, đủ dấu tiếng Việt — `assets/fonts/OFL-CormorantSC.txt`), màu vàng cổ viền nâu |
| Thanh kỹ năng | Ô **vuông** bo góc trong ổ đồng, viền màu theo hệ của biến thể ✦ (chưa có hệ: đồng; Tuyệt kỹ: vàng + ngọc đỏ), hồi chiêu quét trong ô vuông, **phím treo dưới ô** (tấm khiên đồng), khung đồng có **2 đầu rồng** 2 đầu + **huy hiệu đầu sư tử** giữa cạnh trên |
| Thanh kinh nghiệm | `ui/exp_bar.gd`: thanh **tím** chạy dài sát đáy (60% bề ngang màn hình), vạch 10%, đốm sáng đầu thanh, chữ "EXP 75% · còn 12.500 tới cấp 56", 2 đầu rồng mắt tím + 2 ngọc tím |
| Cụm nút góc phải | `ui/action_cluster.gd`: nút **Đánh tròn lớn** (vành đồng răng cưa, 4 ngọc) + 5 nút nhỏ trên vòng cung đồng: bình máu Q, bình MP F, Thiên phú L, Né Space, Tự đánh Z. **Bấm / chạm được** (gửi đúng action bàn phím — logic game không đổi; giữ nút Đánh = đánh liên tục); bấm trên cụm nút ngắm theo hướng di chuyển. Các ô này rời khỏi thanh kỹ năng. **UI-41b (03/11, chủ dự án chê cụm cũ lỗi / xấu):** 5 nút nhỏ giãn đều 27° trên vòng cung R 104 đặt trên một dải nền tối bo tròn viền đồng; nhãn phím (viên đồng) đặt hướng ra ngoài vòng cung thay vì treo dưới nút (cũ đè nút kế bên); số lượng bình nằm trong góc dưới phải của nút; Z hiện "Z · BẬT/TẮT" ngay trên nhãn (bỏ chữ lơ lửng, hết bị cắt mép phải); rê chuột hiện chú thích tên + phím. **UI-41c (03/11, vẽ lại theo ảnh concept thứ 2 của chủ dự án):** nút Đánh = đĩa icon + vòng thép sáng trên / tối dưới + vành đồng có đinh tán, gai 4 hướng (trừ hướng dưới — nhãn J) và gai nhỏ chéo; 4 nút màu lớn (Q, F, L, Space; r 24) giãn rộng 39° trên vòng cung R 112 phía trên – trái, quầng màu theo hệ / bậc, giữa các nút có đốm sáng vàng nhấp nháy; bỏ dải nền; nút phụ Z màu đá trầm gắn trên cánh tay đồng cong bên phải, nhãn "Z · BẬT/TẮT" dưới nút ([ảnh](images/ui41/hud-cluster-b.png)). **UI-41d (03/11, chủ dự án: icon trong cụm nút "xấu quá"):** bộ icon HD riêng cho cụm nút theo cách làm icon HD UI-40 (`tools/art/hd/vec.py`: cel-shade 3 tông + viền tối mềm, siêu mẫu ×4) + quầng sáng màu + đốm lấp lánh như concept — nút Đánh theo đòn đánh thường của lớp (kiếm + vệt chém, cung + tên, ngọn lửa, khiên, cầu linh hồn), bình máu / bình MP (bình cầu thuỷ tinh, mặt nước sáng, bọt), Né (người chạy lướt + vệt gió), Tự đánh (2 kiếm chéo + vòng mũi tên vàng) — [bảng icon](design/ui-cluster/icons.png). Chỉ dùng trong cụm nút: icon kỹ năng ở thanh / bảng kỹ năng giữ nguyên (ảnh chủ dự án đã duyệt); nút L vẫn dùng icon Thiên phú. *03/11:* thanh EXP rút ngắn theo mép trái cụm nút — đầu rồng không còn bị bình máu Q đè |
| Hoạ tiết | Đầu rồng đồng giản lược (sừng cong, bờm gai, hàm há có răng, cánh dơi xoè, mắt ngọc), huy hiệu đầu sư tử (bờm 14 tia) — vẽ bằng đa giác, không chi tiết như tranh |
| Bản đồ nhỏ | **La bàn tròn** lấy nhân vật làm tâm: vành đồng vạch khắc, chữ N / E / S / W trên tấm tròn, kim bắc, **nút + / −** đổi tầm nhìn (3 mức), biển tên map + % khám phá dưới vòng. Phím V: toàn bản đồ chữ nhật trong khung đồng (bấm để tự chạy tới điểm xa như cũ) |
| Bảng nhiệm vụ | **Cuộn giấy da**: thân giấy mép sẫm + vết ố, 2 trục cuộn có núm gỗ, **dấu sáp đỏ** góc phải, tiêu đề chữ cổ mực đỏ, chữ mực nâu; mục tiêu có "(a/b)" → **thanh tiến độ** vàng |

- Chưa đổi (không nằm trong 6 phần đã chọn): khung nhân vật góc trái (UI-08), dòng tài nguyên giữa trên (chỉ đổi sang khung đồng), các bảng phủ bên trong (chỉ đổi khung).
- Test UI41-T1, M5-T6 (la bàn), SN5 (bản đồ lớn bấm tự chạy). Ảnh: [hud-after.png](images/ui41/hud-after.png).
