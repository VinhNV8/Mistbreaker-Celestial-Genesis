# 41 — Đề xuất làm lại hệ thống nhiệm vụ (Spec_Notes 05/11/2026)

> **Góp ý người chơi** (Spec_Notes 05/11): *"Nhiệm vụ đơn điệu, quá ít, không thu hút, chưa rõ ràng… → nghiên cứu và đề xuất thay đổi."*
> Tài liệu này: hiện trạng đo từ code → nguyên nhân từng ý góp ý → cách các game ARPG / MMORPG cùng thể loại làm → đề xuất 5 nhóm (NV-A…E) → lộ trình → câu hỏi chờ chủ dự án (Q195–Q201).

## 1. Hiện trạng (đo từ code ngày 05/11)

| Mục | Hiện có |
| --- | --- |
| Nhiệm vụ chính | **64 bước** cho 9 chương (`data/story.gd` `QUESTS`, `QUESTS2…9`), mỗi chương 5–11 bước, đi thẳng một mạch |
| Loại bước | **Hạ boss 9** · **"hạ 30 quái vùng" 8** · **đến nói chuyện 14** · **"khám phá ≥ 40% map" 5** · chiếm ô đất 2 · chuyển chức / tiến hoá 5 · còn lại mỗi loại 1 (Bọc Mộng, Đèn Cực Quang, ốc đảo, cột đá, giữ Cổng Trại…) |
| Nhiệm vụ phụ | **0** |
| Nhiệm vụ ngày / lặp lại | **0** — kịch bản gốc có *"nhiệm vụ ngày → Đuốc Khai Giới"* và *"Người sống sót gia nhập lãnh địa, giao nhiệm vụ phụ"* (kich-ban mục 7–8) nhưng chưa làm |
| Thưởng | EXP + vàng / vật phẩm cố định (≈ 25% EXP của chương); không chọn thưởng, không đồ riêng, không danh hiệu |
| Giao diện | Khung nhiệm vụ HUD (cuộn giấy da, UI-41) chỉ hiện **1 bước đang làm**: tên, 1 dòng gợi ý chữ, tiến độ, thưởng. Xong chương thì chỉ còn dòng gợi ý chung ("Luyện cấp ở…") |
| Chỉ đường | Chỉ bằng chữ trong gợi ý ("N → Mắt Bão", "phía đông", "đứng cạnh Lão Ngư bấm E"). **Không** có điểm đánh dấu trên bản đồ nhỏ / bản đồ lớn, không mũi tên, không khoảng cách |
| NPC | 23 khu an toàn có NPC; không dấu "!" / "?" trên đầu — người chơi không biết NPC nào có việc |
| Sổ nhiệm vụ | **Không có** — không xem lại được bước trước, thoại, hay việc còn mở |
| Nội dung có sẵn nhưng không gắn nhiệm vụ | bãi quái theo cấp (SN9-06), ổ quái + thủ lĩnh, **26 hang phụ**, **cổng dungeon E→S** (BD-11), **9 boss hiếm**, rương, thảo dược, mỏ / công trình lãnh địa, câu đố cột đá, Thần Vực |

## 2. Góp ý → nguyên nhân

| Góp ý | Nguyên nhân trong game hiện tại |
| --- | --- |
| **Đơn điệu** | 36 / 64 bước (56%) chỉ là 4 kiểu: hạ boss, hạ 30 quái, đi nói chuyện, khám phá 40%. Bước "hạ 30 quái vùng" lặp y hệt ở chương 2, 3, 4, 5, 6, 7, 8, 9 — không quái riêng, không bối cảnh |
| **Quá ít** | Chỉ có chuỗi chính; mỗi chương ~7 bước cho ~10–15 cấp. Giữa các bước (và sau khi xong chương) người chơi tự cày không mục tiêu |
| **Không thu hút** | Thưởng chỉ là số EXP / vàng; không câu chuyện nhỏ của NPC, không lựa chọn, không phần thưởng "muốn có" (đồ đẹp, danh hiệu, thú cưng…); không có gì để quay lại mỗi ngày |
| **Chưa rõ ràng** | Gợi ý bằng chữ, không đánh dấu nơi cần đến; "khám phá 40%" không nói đi đâu; NPC không có dấu hiệu; không sổ nhiệm vụ để đọc lại |

## 3. Các game cùng thể loại làm thế nào (mẫu chung)

| Mẫu | Cách làm phổ biến | Áp dụng cho game này |
| --- | --- | --- |
| **Dấu trên đầu NPC** | "!" vàng = có việc mới, "?" vàng = xong việc chờ trả, màu khác cho việc lặp lại | Rẻ, hiệu quả rõ ràng tức thì |
| **Theo dõi mục tiêu** | Vòng / chấm mục tiêu trên bản đồ nhỏ + bản đồ lớn, mũi tên ở mép màn hình, khoảng cách; bấm nhiệm vụ → tự chạy tới | Có sẵn `set_move_target` (bấm bản đồ nhỏ tự chạy) |
| **Sổ nhiệm vụ** | Tab Chính / Phụ / Hằng ngày / Đã xong; xem lại thoại, thưởng | Một bảng mới, dùng khung đồng UI-41 |
| **Nhiệm vụ phụ theo NPC** | Mỗi khu có vài NPC giao chuỗi 2–4 bước kể một câu chuyện nhỏ; thưởng đồ / danh hiệu | Dùng lại bãi quái, hang, boss hiếm, rương, thảo dược làm mục tiêu |
| **Bảng uỷ thác / truy nã** | 3–5 việc ngẫu nhiên mỗi ngày, làm nhanh 3–10 phút, thưởng cố định + điểm đổi đồ; chuỗi đăng nhập nhiều ngày | Đúng với "nhiệm vụ ngày → Đuốc" trong kịch bản |
| **Đa dạng kiểu nhiệm vụ** | Hộ tống, bảo vệ, thu thập vật rơi, săn tinh anh có tên, điều tra dấu vết, giới hạn thời gian, lựa chọn đối thoại | Thay các bước "hạ 30 quái" lặp lại |
| **Sự kiện thế giới** | Gặp ngẫu nhiên trên đường (đoàn buôn bị phục, người sống sót) → nhiệm vụ 1–2 phút | Tăng cảm giác "thế giới sống" khi khám phá |
| **Thưởng chọn 1 trong 3** | Đồ theo lớp / vật phẩm / vàng | Người chơi thấy có quyền chọn |

## 4. Đề xuất

### NV-A — Rõ ràng (ưu tiên 1, sửa đúng ý "chưa rõ ràng")

| Mã | Nội dung |
| --- | --- |
| NV-A1 | **Điểm mục tiêu**: mỗi bước nhiệm vụ có `goal` (map + toạ độ / vùng / NPC / loại quái). Hiện: vòng vàng nhấp nháy trên bản đồ nhỏ + bản đồ lớn (M); **mũi tên vàng ở mép màn hình** khi mục tiêu ngoài khung nhìn, kèm khoảng cách ("85 m"); mục tiêu ở map khác → mũi tên chỉ cổng sang map đó. Bước "khám phá 40%" → đánh dấu vùng chưa khám phá gần nhất |
| NV-A2 | **Dấu trên đầu NPC**: "!" vàng (có nhiệm vụ mới), "?" vàng (đã xong, chờ trả), "!" xanh (uỷ thác lặp lại). Nhấp nhô nhẹ, thấy từ xa; cũng hiện trên bản đồ nhỏ |
| NV-A3 | **Sổ nhiệm vụ** (phím **O**, gợi ý — J/K/L đã dùng): tab Chính · Phụ · Uỷ thác · Đã xong. Mỗi mục: tên, mô tả 2–3 câu (vì sao làm), các bước (đã xong gạch ngang), thưởng, nút **"Theo dõi"** và **"Chỉ đường"** (tự chạy tới) |
| NV-A4 | **Khung theo dõi HUD**: tối đa 3 việc (chính + 2 ghim), mỗi việc 1 dòng + thanh tiến độ; bấm dòng → tự chạy tới mục tiêu |
| NV-A5 | **Thông báo** nhận / xong nhiệm vụ: dải chữ lớn giữa màn hình 2 giây + âm, thưởng bay vào túi |
| NV-A6 | Viết lại gợi ý bằng **hành động cụ thể** ("Đi về phía đông tới Cửa Gió — cổng vàng trên bản đồ nhỏ") thay cho phím tắt ("N → …") |

### NV-B — Nhiệm vụ chính bớt đơn điệu (sửa ý "đơn điệu")

Giữ nguyên mạch truyện và số bước mỗi chương; **thay 8 bước "hạ 30 quái vùng"** và vài bước "đi nói chuyện" bằng kiểu mới, mỗi chương một kiểu khác nhau:

| Chương | Bước cũ | Bước mới (gợi ý) |
| --- | --- | --- |
| 2 Cửa Gió | Dẹp loạn: hạ 30 quái | **Săn tinh anh có tên**: "Đội trưởng Khiên Sắt" (tinh anh riêng, có thoại, rơi đồ Xanh dương) + 10 lính |
| 3 Sa Mạc | (kills) | **Hộ tống** đoàn lạc đà của Sa Lão qua 2 bãi quái tới ốc đảo (đoàn có thanh máu, dừng khi bị đánh) |
| 4 Đầm Lầy | Cùng Lam Nhi hạ 30 quái | **Điều tra**: tìm 3 dấu vết (vật phát sáng) quanh Bãi Lau → lần ra hang ổ ảo ảnh → hạ thủ lĩnh |
| 5 Núi Lửa | Dọn đường đoàn buôn: 30 quái | **Thu thập**: nhặt 8 "Than Đá Đỏ" rơi từ Thằn Lằn Lửa, giao Kim Phú (vật rơi nhiệm vụ riêng) |
| 6 Băng Nguyên | Đàn sói đói: 30 quái | **Bảo vệ**: giữ lửa trại của Lão Hàn qua 3 đợt sói (lửa có thanh bền) |
| 7 Thiên Không | (kills) | **Giới hạn thời gian**: đưa thư qua 3 đảo trước khi gió đổi (2 phút) |
| 8 Hư Vô | (kills) | **Lựa chọn**: tha hay diệt tín đồ đầu hàng → thoại + thưởng khác nhau (không đổi kết cục chính) |
| 9 Thiên Đạo | (kills) | **Đánh cùng đồng minh**: NPC đồng hành đánh cùng 1 bãi quái mạnh |

Ngoài ra: mỗi bước có **2–3 câu dẫn truyện** (vì sao làm) hiện trong sổ nhiệm vụ và lúc nhận.

### NV-C — Nhiệm vụ phụ theo NPC (sửa ý "quá ít" + "không thu hút")

- Mỗi vùng **3 chuỗi phụ**, mỗi chuỗi 2–4 bước, kể một chuyện nhỏ của NPC trong khu an toàn → **27 chuỗi, ~80 bước** (gấp ~2 lần nhiệm vụ chính).
- Mục tiêu dùng lại nội dung đã có: bãi quái theo cấp, hang phụ, cổng dungeon, boss hiếm, rương, thảo dược, mỏ, công trình lãnh địa.
- Thưởng: EXP ≈ 5–8% EXP cấp đó mỗi chuỗi + **chọn 1 trong 3** (đồ theo lớp người chơi / vật phẩm hiếm / vàng) ; một số chuỗi tặng **danh hiệu** hiện dưới tên.
- Mở theo cấp + bước nhiệm vụ chính (không ngợp lúc đầu).

Ví dụ vùng 1–2:

| Vùng | Chuỗi | Bước |
| --- | --- | --- |
| 1 | *Con dê lạc của bà Mận* | Tìm dê ở bìa rừng (điểm đánh dấu) → đuổi 3 sói đang vây → dắt dê về (dê đi theo) → thưởng: Bình máu ×3 hoặc Giày Xanh lá |
| 1 | *Thảo dược cho Thầy Lang* | Hái 5 thảo dược → hạ Nấm Mẹ ở hang phụ Rừng Sương lấy "Bào Tử Mẹ" → thưởng: công thức bình máu lớn |
| 1 | *Bóng ma trong Lõi Sương* | Điều tra tiếng hú (3 dấu vết) → hạ tinh anh "Sói Mắt Đỏ" → mở rương ẩn → danh hiệu "Thợ Săn Sương" |
| 2 | *Thư nhà của lính gác* | Nhặt thư rơi từ Lính Khiên → giao cho mẹ anh ở Thành Biên Đài → lựa chọn: kể thật / nói dối (thoại khác) |
| 2 | *Bạch Hổ thức giấc* | Tìm dấu móng ở Mắt Bão → hạ boss hiếm Bạch Hổ khi nó xuất hiện → thưởng đồ Tím theo lớp |
| 2 | *Thương nhân mất hàng* | Dọn 1 cổng dungeon hạng D bất kỳ → mang "Hòm hàng" về → giảm giá cửa hàng 5% vĩnh viễn |

### NV-D — Uỷ thác hằng ngày (lý do quay lại mỗi ngày; đúng kịch bản "nhiệm vụ ngày → Đuốc")

- **Bảng Uỷ Thác** ở mỗi khu an toàn (NPC "!" xanh hoặc tấm bảng gỗ): **3 việc mỗi ngày** chọn ngẫu nhiên theo vùng người chơi đang ở, đổi lúc 0 giờ (theo ngày thực).
- Mẫu việc (5–10 phút): săn 15 quái loại X · hạ 2 tinh anh ở bãi cấp N · dọn 1 hang phụ · dọn 1 cổng dungeon · hái 5 thảo dược · mở 2 rương · hạ 1 boss hiếm (việc "khó").
- Thưởng mỗi việc: EXP theo cấp + **1 Đuốc Khai Giới** + **Điểm Uỷ Thác**; làm đủ 3 việc: thêm rương thưởng. Điểm Uỷ Thác đổi ở cửa hàng: đá cường hoá, Tinh Hoa, ngoại hình / danh hiệu.
- **Chuỗi 7 ngày**: ngày 7 rương lớn (1 món Tím theo lớp). Bỏ 1 ngày không mất chuỗi (giữ nhẹ nhàng).
- Được **đổi 1 việc / ngày** (bấm "Đổi").

### NV-E — Sự kiện trên đường (tuỳ chọn, làm sau)

Khi đi trên map ngoài trời, mỗi ~5 phút 25% gặp 1 sự kiện ngắn (1–2 phút) có dấu "!" trên bản đồ nhỏ: *đoàn buôn bị phục kích* (bảo vệ 60 giây), *người sống sót bị thương* (đưa về khu an toàn → gia nhập lãnh địa, đúng kịch bản), *rương bị khoá* (hạ 3 lính canh), *tinh anh đi lạc* (săn trước khi nó chạy). Thưởng nhỏ + 1 Đuốc.

## 5. Lộ trình gợi ý

| Đợt | Nội dung | Kết quả người chơi thấy | Ước lượng |
| --- | --- | --- | --- |
| **P1** | NV-A1…A6 (rõ ràng) + khung dữ liệu nhiệm vụ chung (chính / phụ / uỷ thác dùng chung) | Luôn biết đi đâu, làm gì; có sổ nhiệm vụ | Lớn vừa |
| **P2** | NV-D (Uỷ thác hằng ngày) | Có việc mỗi ngày, có Đuốc | Vừa |
| **P3** | NV-C vùng 1–3 (9 chuỗi), rồi vùng 4–9 (18 chuỗi) | Nhiều việc hơn gấp đôi, truyện nhỏ, đồ / danh hiệu | Lớn (nhiều nội dung) |
| **P4** | NV-B (thay 8 bước "hạ 30 quái") + NV-E | Chính tuyến đa dạng; thế giới "sống" | Vừa |

## 6. Kỹ thuật (sơ bộ, chốt khi triển khai)

- **Dữ liệu**: `data/quests.gd` khai báo nhiệm vụ phụ / uỷ thác theo cùng khuôn: `{id, giver, region, unlock, steps: [{type, target, need, goal, text}], reward, choices}`. Nhiệm vụ chính giữ ở `story.gd` nhưng thêm `goal` + `lore` cho từng bước.
- **Tiến độ**: `profile.side = {id: {step, n, state}}`, `profile.daily = {day, tasks, done, streak, points}`; save +1 phiên bản (nâng bản cũ: rỗng).
- **Sự kiện**: dùng lại `quest_event(kind, n)` đang có (kill, talk, pickup, enter_map…) + thêm `kill_kind`, `cave_clear`, `gate_clear`, `herb`, `chest`, `escort_done`, `defend_done`.
- **Điểm mục tiêu**: hàm chung `goal_pos(goal) -> {map, pos}`; HUD vẽ mũi tên mép màn hình; bản đồ nhỏ vẽ vòng; nhiều map → mũi tên tới cổng gần nhất theo `Portals`.
- **Test**: mỗi loại bước một test qua vòng `update()` thật (bài học BOSS-T1); bot chạy hết uỷ thác 1 ngày; nâng save cũ.

## 7. Câu hỏi chờ chủ dự án

> **Đã chốt 05/11/2026**: Q195 = **làm hết P1–P4** (lần lượt P1 → P2 → P3 → P4); Q196–Q201 **giữ theo gợi ý**.

| Mã | Câu hỏi | Gợi ý |
| --- | --- | --- |
| Q195 | Làm đợt nào trước? | **P1 (rõ ràng)** — sửa đúng góp ý "chưa rõ ràng", là nền cho P2–P4 |
| Q196 | Sổ nhiệm vụ dùng phím nào? | **O** (J/K/L đã dùng) |
| Q197 | Uỷ thác: 3 việc / ngày hay 5? Đổi lúc 0 giờ theo giờ máy? | 3 việc, 0 giờ giờ máy |
| Q198 | Thưởng chọn 1 trong 3 ở nhiệm vụ phụ? | Có |
| Q199 | Danh hiệu (hiện dưới tên) — có làm không? | Có, chỉ để trang trí (không cộng chỉ số) |
| Q200 | NV-B: thay 8 bước "hạ 30 quái" của nhiệm vụ chính — đồng ý đổi chính tuyến? (save đang ở giữa bước cũ: tự quy đổi sang bước mới, giữ tiến độ %) | Đồng ý |
| Q201 | NV-E sự kiện trên đường — có làm không? | Làm sau P1–P3 |

## 8. Kết quả triển khai

### P1 — NV-A Rõ ràng (xong 05/11/2026)

| Mã | Đã làm |
| --- | --- |
| NV-A1 | Mỗi bước nhiệm vụ chính (64 bước) có khoá `goal` trong `data/story.gd`. `core/quest_log.gd` giải ra điểm cần tới: NPC, đấu trường, khu an toàn, bãi quái hợp cấp gần nhất, ô sương chưa mở gần nhất (bước "khám phá 40%"), vật nhiệm vụ còn lại gần nhất (ốc đảo, Bọc Mộng, Đèn Cực Quang, Trụ Gió, Neo Hư Vô, Đèn Tinh Quang, Lồng, Trụ Phong Ấn), Thủ Tầng / Tàn Hồn. Mục tiêu ở map khác → cổng trước / sau theo chuỗi map, **Cổng Dịch Chuyển** nếu map đích đã mở và không kề, **cửa ra** nếu đang trong hang / cổng dungeon. Hiện: **mũi tên vàng quanh chân nhân vật + khoảng cách** ("67 m"; chưa tới map đích thì kèm tên cổng), **vòng vàng nhấp nháy** tại điểm cần tới, **chấm / mũi tên mép** trên bản đồ nhỏ (`view/quest_view.gd`, `minimap._draw_goal`). Mũi tên đặt quanh nhân vật thay cho mép màn hình — luôn cạnh chỗ mắt đang nhìn |
| NV-A2 | Dấu **"!" vàng** nhấp nhô trên đầu NPC là mục tiêu bước đang làm (NPC chưa hiện / ở map khác: lấy vị trí theo dữ liệu map; Tổ Sư chọn đúng người của lớp). "?" (trả việc) và "!" xanh (uỷ thác) dùng cho P2 / P3 |
| NV-A3 | **Sổ nhiệm vụ** (phím **O**, đổi phím được) — tab Chính · Phụ · Uỷ thác · Đã xong; tab Chính: 9 chương (✓ / ◆ / 🔒), câu dẫn truyện mỗi chương, danh sách bước, chi tiết bước đang làm + nút **Chỉ đường** (`ui/quest_panel.gd`) |
| NV-A4 | **Bấm khung nhiệm vụ** HUD → tự chạy tới điểm cần tới (dùng `set_move_target` sẵn có) hoặc mở bảng cần dùng (Bản đồ khai phá / Túi đồ / Nhân vật). Khung có thêm dòng chỉ đường "➜ 67 m · Bãi quái". Khung theo dõi nhiều việc (chính + 2 ghim) làm cùng P2 / P3 khi có việc phụ |
| NV-A5 | Xong bước chính → dải chữ lớn giữa màn hình "✓ <bước vừa xong>" + "Nhiệm vụ mới: <bước tiếp>" |
| NV-A6 | Gợi ý dạng "N → Map." đổi thành "Tới Map (theo mũi tên vàng)."; bước Lõi Sương viết lại |

Test **NVA-T1**: 64 bước có goal hợp lệ; mọi bước có điểm trên bản đồ đều ra toạ độ khi đứng đúng map; chỉ cổng khi ở map khác; Cổng Dịch Chuyển khi map đích xa đã mở; cửa ra trong hang; bước khám phá chỉ vào ô sương chưa mở; Sổ nhiệm vụ (tab, 9 chương, nút Chỉ đường); dòng chỉ đường.

### P2 — NV-D Uỷ thác hằng ngày (xong 05/11/2026)

- `core/quests.gd`: **3 việc / ngày** bốc từ 5 mẫu — săn 15 con 1 loài của vùng đang đứng · hạ 2 tinh anh · dọn 1 hang phụ · dọn 1 cổng dungeon (khi đã hạ Sói Chúa) · hái 6 thảo dược (bỏ mẫu "mở rương": rương ẩn chỉ hiện với Thiên phú Khứu Giác). Đổi ngày lúc 0 giờ giờ máy; cùng ngày luôn ra cùng việc.
- Làm ở đâu cũng tính; **nhận thưởng khi đứng trong khu an toàn**, ở Sổ nhiệm vụ → tab Uỷ thác (không làm tấm bảng / NPC "!" xanh riêng — nhận ở mọi làng / thành / trại tiện hơn).
- Mỗi việc: ≈ 6% EXP lên cấp + 1 Đuốc + 10 Điểm Uỷ Thác. Đủ 3 việc: rương ngày (50 × cấp vàng, 3 Đá Cường Hoá, 1 Thiên Phú Tinh Hoa) + chuỗi ngày; **bỏ 1 ngày không mất chuỗi**; chuỗi 7 ngày: 1 món Tím theo lớp. Đổi 1 việc / ngày.
- Cửa hàng điểm: 30 → 5 Đá Cường Hoá · 60 → 1 Thiên Phú Tinh Hoa · 120 → 1 món Tím theo lớp.
- **Ghim** tối đa 2 việc (uỷ thác / nhiệm vụ phụ) → hiện dưới nhiệm vụ chính trên khung HUD "◇ Săn 15 Nấm Độc 0/15 · 60 m", bấm dòng → tự chạy tới.
- Save **v30**: `daily`, `side`, `tracked`, `titles`, `title` (save cũ: rỗng). Test **NVD-T1**.

### P3 — NV-C 27 chuỗi nhiệm vụ phụ (xong 05/11/2026)

- `data/side_quests.gd`: **27 chuỗi** (3 / vùng, 2–3 bước mỗi chuỗi), người giao là **NPC sẵn có** ở khu an toàn của vùng (không cần vẽ NPC mới — các ví dụ ở mục 4 NV-C đổi theo). Mỗi vùng: 2 chuỗi mở khi tới vùng (săn loài quái riêng của vùng, tinh anh, thảo dược, dọn hang / cổng dungeon) + 1 chuỗi mở sau khi hạ boss vùng: tới map cuối và **hạ boss hiếm của vùng**, thưởng thêm **danh hiệu** (Thợ Săn Sương, Kẻ Thuần Hổ, Người Giải Đố, Kẻ Chém Thất Đầu, Kẻ Dập Lửa, Người Phá Băng, Kẻ Cưỡi Mây, Kẻ Săn Hư Vô, Người Vượt Thiên Đạo).
- Nhận: E cạnh NPC có **"!" vàng** (NPC đang là mục tiêu bước chính thì thoại chính đi trước); tự ghim nếu còn chỗ. Xong bước cuối: NPC có **"?" vàng**, E → Sổ nhiệm vụ tab Phụ, **chọn 1 trong 3** (trang bị theo lớp / vật phẩm / vàng hoặc Tinh Hoa) + EXP 25–35% EXP lên cấp.
- Tab Phụ: đang làm (bước + tiến độ, Ghim), có thể nhận (gặp ai ở đâu), đã hoàn thành x/27, đổi danh hiệu đang đeo; danh hiệu hiện « … » trên tên nhân vật (chỉ trang trí). Test **NVC-T1** (kể cả: người giao thật sự hiện trên map lúc chuỗi mở).

### P4 — NV-B chính tuyến + NV-E sự kiện trên đường (xong 05/11/2026)

**NV-B** (`core/main_variants.gd`): 8 bước "hạ 30 quái vùng" đổi thành **4 kiểu**, mỗi kiểu 2 chương (đề xuất mục 4 có 8 kiểu — hộ tống, giới hạn thời gian, lựa chọn, đánh cùng đồng minh chưa làm; 4 kiểu dưới đây dùng lại được cho nội dung sau):

| Chương | Bước | Mục tiêu mới |
| --- | --- | --- |
| 2 | Dẹp loạn Cửa Gió | Hạ 10 quái + **Đội trưởng Lính Thuê** (tinh anh có tên ở bãi gần thành) |
| 3 | Mảnh bản đồ | **Tìm 3 Mảnh bản đồ phát sáng** quanh Rìa Cát Đỏ → Xác Ướp Giữ Bản Đồ xuất hiện, hạ nó |
| 4 | Tiếng hát trong lau | **Lần 3 dấu vết ảo ảnh** ở Bãi Lau Mù → hạ Ảo Ảnh Gọi Tên |
| 5 | Dọn đường cho đoàn buôn | **Nhặt 8 Than Đá Đỏ** rơi từ Thằn Lằn Lửa / Người Đá (50%) |
| 6 | Đàn sói đói | **Giữ điểm** phía đông Trạm Tuyết Bạc qua 3 đợt sói (rời xa → đợt đang đánh bị huỷ) |
| 7 | Bầy chim dữ | **Giữ điểm** phía đông Bến Mây qua 3 đợt Đại Bàng Mây |
| 8 | Mở đường | **Nhặt 8 Mảnh Phong Ấn** từ Kẻ Nuốt / Bóng Hư Vô |
| 9 | Thiên binh | Hạ 10 quái + **Thiên Binh Thống Lĩnh** |

Tiến độ ghi vào `profile.quest.killsN` (= max) trước mỗi lần chương kiểm nhiệm vụ → chương tự chuyển bước, logic chương không đổi (chỉ bỏ dòng cộng `killsN` theo mỗi quái). Save đang dở bước cũ: quy đổi theo % (vd 15/30 → 2/4). Dấu vết vẽ đốm sáng lấp lánh, điểm giữ vẽ vòng nét đứt. Test **NVB-T1**.

**NV-E** (`core/road_events.gd`): đi ngoài trời, mỗi 5 phút 25% gặp 1 sự kiện cạnh bãi quái gần đó: **đoàn buôn bị phục kích** (hạ 5 tên cướp) · **người sống sót bị thương** (tới chỗ người đó rồi đưa về khu an toàn — gia nhập lãnh địa) · **rương bị canh** (hạ 3 lính canh, +2 Đá Cường Hoá) · **tinh anh đi lạc** (hạ trong 90 giây). Hết 120 giây chưa xong thì tan. Thưởng ≈ 3% EXP + 20 × cấp vàng + 1 Đuốc. Dấu "!" trên bản đồ nhỏ, dòng "⚑ …" đầu danh sách theo dõi (bấm → tự chạy tới). Tắt khi `field_spawn` tắt (test cũ không đổi). Test **NVE-T1**.
