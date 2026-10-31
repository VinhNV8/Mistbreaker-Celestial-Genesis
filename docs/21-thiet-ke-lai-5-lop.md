# Thiết kế lại 5 lớp theo docs/charactors.md — đối chiếu và đề xuất

| | |
| --- | --- |
| Dự án | Thiên Phú Khai Giới |
| Nguồn | [charactors.md](charactors.md) (chủ dự án, 27/10/2026); đối chiếu với [13 hệ kỹ năng](13-he-ky-nang.md), [19 Hộ Vệ · Triệu Hồi Sư](19-lop-ho-ve-trieu-hoi-su.md), `godot/scripts/data/classes.gd` |
| Loại tài liệu | Đặc tả + kết quả. Chủ dự án duyệt **theo mặc định** Q130–Q139 (27/10/2026). **CL1 đã code** (mục 10), CL2 đã sửa docs/19 (chờ phiên game-c6 code) |
| Đợt đề xuất | **CL1** 3 lớp đang có · **CL2** sửa docs/19 cho Hộ Vệ, Triệu Hồi Sư (phiên game-c6 đang giữ) |

## 1. Kết luận nhanh

charactors.md mô tả mỗi lớp **4 kỹ năng chính** (3 kỹ năng + 1 tối thượng), tạo hình nhân vật và "sao" chỉ số. Game hiện đã có **13 kỹ năng mỗi lớp** (docs/13, mở dần tới cấp 60) và đủ chuyển chức 1–2. Vì vậy:

- **Không thay cả bộ 13 kỹ năng.** Đề xuất ánh xạ 4 kỹ năng của charactors.md vào các ô đã có. Ô nào gần giống thì đổi tên + chỉnh số; ô nào là cơ chế mới (ví dụ buff Kiếm Ý) thì thay một kỹ năng hiện có.
- **Tạo hình nhân vật** của charactors.md đã khớp với chân dung màn chọn lớp (UI-22). Sprite trong trận sẽ chỉnh màu cho khớp (mục 5).
- **"Sao" chỉ số** chuyển thành chênh lệch nhỏ quanh chỉ số nền hiện tại. Không làm lệch luật cân bằng của kịch bản: các lớp chênh nhau ≤ 25% (test TL-B).
- **PvP, 30–50 kỹ năng mỗi lớp, chuyển chức lần 3**: ngoài phạm vi đợt này (mục 6).

Ký hiệu cột "Đề xuất": **Giữ** = đã có, chỉ đổi tên/chú thích · **Chỉnh** = đổi số hoặc thêm hiệu ứng nhỏ · **Mới** = cơ chế mới, thay một kỹ năng cũ.

## 2. Kiếm Khách

| charactors.md | Đang có trong game | Đề xuất |
| --- | --- | --- |
| **Trảm Phong** — CD 4 giây, chém thẳng phía trước 150% | Kiếm Khí (cấp 4): CD 5 giây, luồng kiếm khí 40 m xuyên quái ×2,0 | **Chỉnh**: đổi tên Kiếm Khí → Trảm Phong, CD 5 → 4 giây, ×2,0 → ×1,6 (giữ tổng sát thương mỗi giây ≈ cũ) |
| **Nguyệt Ảnh Liên Trảm** — lao tới mục tiêu, 3 nhát liên tiếp, tổng 350% | Đột Kích (cấp 1): lao 18 m ×1,5 · Liên Trảm (cấp 15): 3 nhát ×0,9 | **Chỉnh**: Liên Trảm thành Nguyệt Ảnh Liên Trảm — lao tới quái gần nhất trong 15 m rồi chém 3 nhát ×1,15 (tổng 345%), CD 7 → 10 giây. Đột Kích giữ nguyên |
| **Kiếm Ý** — buff +20% chí mạng, +15% tốc đánh, 8 giây | Thiết Bích (cấp 8): 4 giây giảm 50% sát thương nhận vào | **Mới** (Q130): Kiếm Ý thay Thiết Bích ở ô cấp 8, CD 20 giây, 8 giây +20% chí mạng (vẫn theo trần 60%), +15% tốc đánh. Kiếm Khách mất kỹ năng đỡ đòn → hợp vai "khó chơi, sát thương lớn" |
| **Vạn Kiếm Quy Tông** (tối thượng) — CD 30 giây, 800% | Đã có (cấp 45): CD 60 giây, 12 đợt ×0,6 = 720% | **Chỉnh** (Q131): 12 đợt ×0,67 = 800%. CD giữ 60 giây như mọi tối thượng, hoặc 30 giây nếu chủ dự án muốn (khi đó ×0,4 mỗi đợt để không vượt sát thương mỗi giây) |
| Vai trò: DPS vật lý, chí mạng cao, khó chơi | Cận chiến cân bằng, máu dày nhất | **Chỉnh** (Q132): vai trò "Cận chiến · Chí mạng"; chí mạng nền 5% → 8%; HP nền giữ (đang dày nhất để bù việc phải lao vào bầy quái) |
| Áo choàng đỏ đen, kiếm sáng, kiếm khí đỏ | Chân dung UI-22 đã đúng; sprite trong trận áo xanh | **Chỉnh**: sprite trong trận đổi áo đỏ đen, vệt chém + Trảm Phong màu đỏ |

## 3. Thợ Săn ("Cung Thủ" trong charactors.md)

| charactors.md | Đang có trong game | Đề xuất |
| --- | --- | --- |
| Tên lớp **Cung Thủ** | **Thợ Săn** (theo kịch bản, chuyển chức Xạ Thủ → Thần Tiễn / Thợ Bẫy) | **Giữ** tên Thợ Săn (Q133). Đổi tên lớp phải sửa thoại, nhiệm vụ, bảng kịch bản |
| **Xuyên Tâm Tiễn** — xuyên 3 mục tiêu, 180% | Tên Xuyên Phá (cấp 1): xuyên **mọi** quái, 60 m, ×2,5 | **Chỉnh**: đổi tên → Xuyên Tâm Tiễn, xuyên tối đa 3 quái ×1,8, CD 6 → 5 giây |
| **Vũ Tiễn** — mưa tên diện rộng 250% | Mưa Tên (cấp 1): vùng 9 m, 5 đợt ×0,6 = 300% | **Giữ** cơ chế, đổi tên → Vũ Tiễn, 5 đợt ×0,5 = 250% |
| **Lộn Nhào** — lướt, +50% né tránh 3 giây | Lăn Bắn (cấp 22): lăn lùi (bất tử) rồi bắn 3 mũi ×0,8 | **Chỉnh**: đổi tên → Lộn Nhào, thêm +50% né tránh 3 giây sau khi lăn (vẫn theo trần né tránh). Có thể hạ mở khoá cấp 22 → 4 và đổi chỗ với Bẫy Gai (Q134) |
| **Thiên Tiễn** (tối thượng) — 700% vùng | Thiên Tiễn Vũ (cấp 45): 10 đợt ×0,7 = 700% | **Giữ** — đã đúng 700% |
| Né tránh cao, máu mỏng | Né tránh nền +5%, HP nền thấp hơn Kiếm Khách | **Giữ** |

## 4. Pháp Sư

| charactors.md | Đang có trong game | Đề xuất |
| --- | --- | --- |
| **Hỏa Cầu** — 200% phép | Đánh thường "Hỏa Cầu" (×1,0 mỗi phát) | **Giữ** là đánh thường. Kỹ năng ×2,0 riêng sẽ trùng Thiên Thạch → không thêm |
| **Băng Lao** — 150%, làm chậm 50% | Băng Ngục (cấp 1): nổ băng quanh mình 11 m ×1,4, trói 2 giây | **Mới** (Q135): Băng Lao thay Băng Ngục — mũi băng bay thẳng 40 m, xuyên quái ×1,5, làm chậm 50% trong 3 giây. Pháp Sư mất kỹ năng tự vệ quanh mình; có thể giữ Băng Ngục ở ô cấp 22 thay Dịch Chuyển |
| **Sét Chuỗi** — nảy 5 mục tiêu, 120% mỗi mục tiêu | Lôi Xích (cấp 1): nảy tối đa 5 quái (1 + 4), ×1,6 | **Chỉnh**: đổi tên → Sét Chuỗi, ×1,6 → ×1,2, CD 6 → 5 giây |
| **Thiên Tai Nguyên Tố** (tối thượng) — lửa, băng, sét cùng giáng, 1000% | Thiên Hoả Phần Thế (cấp 45): 5 thiên thạch ×2,5 | **Chỉnh** (Q136): 3 đợt (Hỏa ×4,0 vòng 12 m → Băng ×3,0 làm chậm → Sét ×3,0 nảy 5 quái) = 1000% với 1 mục tiêu. Mỗi đợt mang hệ tương ứng (Hỏa / Thủy / Kim) nên ăn khắc hệ của Ngũ Hành Linh Căn |
| MP rất cao, phòng thủ rất thấp | MP nền +30, phòng thủ như lớp khác | **Chỉnh** (Q132): phòng thủ nền ×0,8 so với Kiếm Khách |

## 5. Tạo hình trong trận (cả 3 lớp)

Chân dung màn chọn lớp (UI-22) đã theo charactors.md. Sprite 32×32 trong trận chỉnh theo cho khớp (`tools/art/catalog.py`, giữ đúng khung và số hoạt ảnh):

- **Kiếm Khách:** áo choàng đỏ đen, kiếm có viền sáng đỏ. Vệt chém + Trảm Phong đổi sang đỏ.
- **Thợ Săn:** mũ trùm + áo choàng xanh lá, bao tên sau lưng.
- **Pháp Sư:** mũ phù thuỷ tím, trượng pha lê. Vòng ma pháp trận mờ dưới chân khi niệm kỹ năng.

## 6. Hộ Vệ, Triệu Hồi Sư (CL2 — phiên game-c6, docs/19)

docs/19 đã có đủ 13 kỹ năng cho mỗi lớp. 4 kỹ năng của charactors.md khớp gần hết:

| charactors.md | docs/19 | Đề xuất sửa docs/19 |
| --- | --- | --- |
| Hộ Vệ · **Khiên Thép** — +30% phòng thủ 10 giây | Thánh Thuẫn (cấp 8): 5 giây nhận ít hơn 40%, phản 50% | Đổi tên + 10 giây, +30% phòng thủ, bỏ phản đòn (phản đòn đã có ở chức Thiết Vệ) |
| Hộ Vệ · **Khiêu Khích** — quái tập trung đánh mình | Khiêu Khích (cấp 1): gầm 12 m, kéo quái về sát mình | Giữ |
| Hộ Vệ · **Chấn Địa** — đập khiên diện rộng, choáng 2 giây | Chấn Địa (cấp 15): vòng 10 m ×1,5, làm chậm 2 giây | Làm chậm → **choáng 2 giây** quái thường (boss: thanh Phá Thế ×2) |
| Hộ Vệ · **Thành Bất Diệt** (tối thượng) — giảm 80% sát thương 8 giây | Thiên Thần Hộ Mệnh: 8 giây, hào quang ×0,5, giảm 50% | Đổi tên, giảm 50% → 80%, hào quang ×0,5 → ×0,3 |
| Triệu Hồi Sư · **Triệu Hồi Sói Bóng** — sói chiến đấu 20 giây | Gọi Linh Lang (cấp 1): 2 sói 12 giây ×0,6 | Đổi tên, 1 sói 20 giây ×0,9 (Q137) |
| Triệu Hồi Sư · **Triệu Hồi Tiểu Quỷ** — 3 tiểu quỷ đánh xa | Gọi Linh Ưng (cấp 30, chức Linh Sư): 2 linh ưng đánh xa | Thêm Tiểu Quỷ ở ô cấp 4 thay Linh Bạo: 3 tiểu quỷ đánh xa 20 m, 12 giây ×0,4 |
| Triệu Hồi Sư · **Liên Kết Linh Hồn** — linh thú +40% sát thương, mình +20% | Linh Giáp (cấp 8): linh thú +50%, mình nhận ít hơn 25% | Đổi tên + số: linh thú +40% sát thương, mình +20% sát thương, 8 giây |
| Triệu Hồi Sư · **Quân Đoàn Linh Hồn** (tối thượng) — 10 linh thú 15 giây | Vạn Linh Triều Bái: 6 linh thú 10 giây | Đổi tên, 10 linh thú 15 giây ×0,45 (giới hạn số linh thú tối đa 12 để giữ khung hình) |

Hai lớp này chưa code nên sửa spec là đủ. Cần báo phiên game-c6 trước khi họ code LH1/LH2 (Q138).

## 7. Ngoài phạm vi (ghi nhận, chưa làm)

| Ý trong charactors.md | Tình trạng |
| --- | --- |
| Bảng độ khó / Solo / **PvP** / Boss / Farm | Game chơi đơn, chưa có PvP. Cột PvP bỏ; các cột khác dùng làm mục tiêu khi cân bằng (test thời gian hạ boss theo lớp) |
| Thăng cấp nghề lần 2, lần 3 | Lần 1 (cấp 30) và 2 (cấp 60) đã có. Lần 3 (cấp 90) ở docs/17 chương 8 |
| Cây kỹ năng 30–50 kỹ năng mỗi lớp | Hiện 13 kỹ năng + Bí Kíp (docs/13). Mở rộng là một đợt lớn riêng (Q139) |
| Ngũ Hành Linh Căn ảnh hưởng từng kỹ năng | Đề xuất bước đầu: Thiên Tai Nguyên Tố mang 3 hệ (mục 4). Mỗi kỹ năng có hệ riêng là đợt sau |
| Bộ kỹ năng PvP/PvE riêng | Ngoài phạm vi (chưa có PvP) |
| Sprite gameplay (đứng, chạy, đánh, tung skill) để giao artist | Game đã có sprite sinh bằng code cho đứng / chạy / đánh / trúng đòn / chết. Chưa có động tác "tung kỹ năng" riêng |

## 8. Cân bằng và kiểm thử (khi code CL1)

- Mỗi kỹ năng đổi số: giữ sát thương mỗi giây (×hệ số ÷ CD) trong ±15% so với cũ, trừ khi charactors.md yêu cầu khác (ghi rõ ở bảng).
- Chạy lại TL-B / TL-B2 (chênh lớp ≤ 25%), SK1-T…SK3-T (bộ kỹ năng mặc định không chết, 6 nhánh trong ±15%), bài boss từng chương.
- Test mới CL1-T1…T5: Kiếm Ý cộng đúng chí mạng/tốc đánh và hết sau 8 giây; Nguyệt Ảnh lao tới quái gần nhất rồi 3 nhát; Xuyên Tâm Tiễn dừng sau 3 quái; Lộn Nhào +50% né tránh 3 giây; Băng Lao làm chậm 50%; Thiên Tai Nguyên Tố 3 đợt 3 hệ.
- Save **không đổi phiên bản**: kỹ năng lưu theo id. Ô bị thay (Thiết Bích, Băng Ngục) được chuyển điểm kỹ năng sang kỹ năng mới cùng ô khi tải save cũ.

## 9. Câu hỏi (đã duyệt theo cột Mặc định, 27/10/2026)

| # | Câu hỏi | Mặc định |
| --- | --- | --- |
| Q130 | Kiếm Ý thay Thiết Bích (mất kỹ năng giảm sát thương)? | Có — thay |
| Q131 | Vạn Kiếm Quy Tông: CD 30 giây như charactors.md hay giữ 60 giây như mọi tối thượng? | Giữ 60 giây, sát thương 800% |
| Q132 | "Sao" chỉ số áp thế nào? | Chênh nhỏ: Kiếm Khách chí mạng nền 8%, Pháp Sư phòng thủ ×0,8; còn lại giữ |
| Q133 | Đổi tên lớp Thợ Săn → Cung Thủ? | Không — giữ Thợ Săn theo kịch bản |
| Q134 | Lộn Nhào mở ở cấp 4 (đổi chỗ với Bẫy Gai)? | Có |
| Q135 | Băng Lao thay Băng Ngục ở ô cấp 1; Băng Ngục chuyển sang ô cấp 22 thay Dịch Chuyển? | Có cả hai |
| Q136 | Thiên Tai Nguyên Tố thay Thiên Hoả Phần Thế, mỗi đợt một hệ? | Có |
| Q137 | Triệu Hồi Sư: Sói Bóng 1 con 20 giây thay 2 Linh Lang 12 giây? | Có |
| Q138 | Sửa docs/19 theo mục 6 và báo phiên game-c6? | Có — Claude sửa spec, game-c6 code |
| Q139 | Mở rộng 30–50 kỹ năng mỗi lớp? | Để đợt sau, sau chương 9 |

## 10. Kết quả CL1 (27/10/2026)

### 10.1. Số liệu đang dùng (`godot/scripts/data/classes.gd`)

| Lớp | Ô (mở ở cấp) | Kỹ năng | Hồi chiêu / MP | Hiệu ứng |
| --- | --- | --- | --- | --- |
| Kiếm Khách | 3 (4) | **Trảm Phong** (`wave`) | 4 s / 15 | Luồng kiếm khí thẳng 40 m, xuyên mọi quái, ×1,6 |
| Kiếm Khách | 4 (8) | **Kiếm Ý** (`kiemy`, mới) | 20 s / 25 | *(hỗ trợ)* 8 giây: +20% chí mạng cho mọi đòn (không vượt trần 60%), +15% tốc đánh. Biến thể Bền Bỉ kéo dài 30% |
| Kiếm Khách | 5 (15) | **Nguyệt Ảnh Liên Trảm** (`lientram`) | 10 s / 20 | Lướt tới quái gần nhất trong 15 m (dừng sát quái), rồi 3 nhát nón 90° 7 m, mỗi nhát ×1,15 |
| Kiếm Khách | tối thượng (45) | Vạn Kiếm Quy Tông | 60 s / 50 | 12 đợt ×0,67 = 800% |
| Thợ Săn | 1 (1) | **Vũ Tiễn** (`rain`) | 8 s / 25 | 5 đợt ×0,5 = 250% |
| Thợ Săn | 2 (1) | **Xuyên Tâm Tiễn** (`pierce`) | 5 s / 15 | Bay 60 m, xuyên tối đa **3 quái**, ×1,8 |
| Thợ Săn | 3 (4) | **Lộn Nhào** (`lanban`, trước ở cấp 22) | 8 s / 20 | Lộn lùi (bất tử) + 3 mũi ×0,8; sau đó 3 giây +50% né tránh (trần 60% trong lúc này) |
| Thợ Săn | 6 (22) | Bẫy Gai (`trap`, trước ở cấp 4) | 10 s / 20 | Không đổi |
| Pháp Sư | 1 (1) | **Sét Chuỗi** (`chain`) | 5 s / 15 | 5 mục tiêu, mỗi quái ×1,2 |
| Pháp Sư | 2 (1) | **Băng Lao** (`banglao`, mới) | 6 s / 15 | Mũi băng 40 m xuyên quái ×1,5, làm chậm 3 giây |
| Pháp Sư | 6 (22) | Băng Ngục (`nova`, trước ở cấp 1) | 9 s / 20 | Không đổi; thay Dịch Chuyển (đã bỏ) |
| Pháp Sư | tối thượng (45) | **Thiên Tai Nguyên Tố** (`thienhoa`) | 60 s / 50 | Thiên thạch vòng 12 m ×4,0 (sau 0,8 s) → 0,7 s sau băng nổ cùng chỗ ×3,0 + làm chậm 3 s → 0,7 s sau sét nảy 5 quái ×3,0 |

Chỉ số nền (`stats.gd`): Kiếm Khách chí mạng 5% → **8%** (`SWORD_CRIT`), Pháp Sư phòng thủ nền (5 + 1,5 × (cấp − 1)) **×0,8** (`MAGE_DEF`). Vai trò Kiếm Khách trên màn chọn lớp: "Cận chiến · Chí mạng".

### 10.2. Kỹ thuật

- Giữ **id cũ** khi chỉ đổi tên/số (`wave`, `lientram`, `rain`, `pierce`, `lanban`, `chain`, `thienhoa`) → save cũ giữ nguyên cấp kỹ năng, biến thể, Bí Kíp, ô lắp.
- 2 kỹ năng mới có id mới: `kiemy` thay `guard`, `banglao` thay `dichchuyen` (`"replaces"` trong classes.gd, `Skills2.REPLACED`). `Skills2.migrate_replaced(profile)` chạy đầu `GameWorld._ensure_loadout()`: chuyển `skill_levels`, `variants`, `secret_books` của id cũ sang id mới (D56). Ô lắp còn id cũ → lắp lại mặc định theo lớp. **Save không đổi phiên bản.**
- Buff: `Skills2.State.kiemy_t`, `lonnhao_t` (giảm trong `Skills2.tick`). Chí mạng cộng ở `Skills2.crit_bonus` (mọi đòn, kể cả đánh thường); tốc đánh nhân ở `GameWorld.atk_speed()` qua `Skills2.speed_mult`; khi bị đánh, né tránh dùng `Skills2.evasion_of` thay `stats.evasion`.
- Xuyên Tâm Tiễn: `PlayerShot.max_hits` (0 = không giới hạn) — đạn dừng khi đã trúng đủ số quái; áp cả bản Song Phát trong hàng đợi.
- Thiên Tai Nguyên Tố: 1 `Meteor` + 2 mục hàng đợi `tt_ice`, `tt_bolt` (`Skills2.tick`).
- CL1b (27/10, cùng ngày): `Enemy.slow_mul` cho Băng Lao 50%; `Skills2.State.wave_el` + `TTN_ELEMENTS` cho hệ từng đợt Thiên Tai Nguyên Tố; màu hiệu ứng ở `world_view._draw_player_fx` và vòng vẽ đạn.
- Bản Ngã Bóng Tối (chương 6) chép kỹ năng mới: Kiếm Ý → Xoáy bóng, Băng Lao → Tia bóng, Lộn Nhào → Lao bóng (`Ch6.MIRROR_OF`).

### 10.3. Khác với spec / chưa làm

| Mục | Tình trạng |
| --- | --- |
| Băng Lao "làm chậm 50%" | ✅ (CL1b) Quái có mức chậm riêng `Enemy.slow_mul` (0 = mức chung 40%); Băng Lao đặt 0,5 → quái còn 50% tốc chạy trong 3 giây. Hết `slow_t` thì `slow_mul` tự về 0 |
| Thiên Tai Nguyên Tố "mỗi đợt mang hệ Hỏa / Thủy / Kim" | ✅ (CL1b) `Skills2.element_of("thienhoa")` trả hệ của đợt: thiên thạch **Hỏa** (thiêu 3 giây), băng **Thủy** (làm chậm), sét **Kim** (bỏ qua 25% Phòng thủ); mỗi đợt nhận khắc hệ +30% với quái bị khắc (`Monsters.counters`). Hệ tầng II người chơi chọn cho kỹ năng này không còn tác dụng (Âm Dương vẫn có) |
| Sprite trong trận đổi màu (mục 5) | **Không làm ở đây**: phiên game-5f đang nhập bộ sprite 5 lớp của chủ dự án (`pc-*`), hình trong trận lấy từ đó |
| Icon riêng cho Kiếm Ý, Băng Lao | ✅ Phiên game-5f cắt từ bộ icon kỹ năng của chủ dự án (`tools/art/class_skill_icons.py`, `skill-kiemy`, `skill-banglao`; cũng thay icon các kỹ năng chính khác) |
| Trảm Phong / vệt chém màu đỏ | ✅ (CL1b) `world_view.gd`: vệt chém của Kiếm Khách đỏ, kiếm khí (đạn `wave`: Trảm Phong, Phi Kiếm, Thánh Kiếm Trảm…) nhuộm đỏ; mũi Băng Lao nhuộm xanh băng + quầng sáng |

### 10.4. Kiểm thử

- Test mới **CL1** (`_test_cl1_redesign`): Kiếm Ý +20% chí mạng (trần 60%) + 15% tốc đánh, hết sau 8 giây; Nguyệt Ảnh lướt tới sát quái cách 13 m rồi 3 nhát; Xuyên Tâm Tiễn trúng đúng 3/5 quái thẳng hàng; Lộn Nhào +50% né tránh, hết sau 3 giây, mở cấp 4 (Bẫy Gai cấp 22); Băng Lao xuyên + làm chậm; Thiên Tai Nguyên Tố đủ 3 đợt, đợt băng làm chậm; chí mạng nền 8% / 5%, phòng thủ Pháp Sư thấp hơn; save cũ Thiết Bích cấp 6 → Kiếm Ý cấp 6, Dịch Chuyển cấp 4 → Băng Lao cấp 4. CL1b thêm: Băng Lao `slow_mul` = 0,5; đợt thiên thạch thiêu quái (Hỏa); hệ mặc định Hỏa, đợt sét Kim bỏ qua 25% Phòng thủ.
- Sửa test cũ theo thứ tự ô mới: CL-T1 (chí mạng nền), CL-T3 (Bẫy Gai ở cấp 22; hiệu ứng Thiết Bích giữ cho Kiên Cố), SN-T2 (Băng Ngục ở ô cấp 22), SK1-T2/T3, SK2-T1/T2/T3/T4, SK3-T3 (Kiếm Ý thay Thiết Bích, Băng Ngục thay Dịch Chuyển), C6-T4 (bản bóng tối cho kỹ năng mới).
- Cân bằng chạy lại, đều đạt: Thiên phú F/S cùng lớp chênh 1–12% (giới hạn 25%), 0 lần chết; bộ kỹ năng mới so với mặc định: Kiếm Khách 27,7 → 28,8 s, Thợ Săn 30,6 → 27,4 s, Pháp Sư 26,5 → 25,4 s; 6 nhánh chuyển chức 2 trong giới hạn của SK3-T4.
