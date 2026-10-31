# Đề xuất: chỉ số khởi đầu và chỉ số đặc thù của từng lớp

| | |
| --- | --- |
| Dự án | Thiên Phú Khai Giới |
| Nguồn | Góp ý người chơi (28/10/2026): *"chỉ số các class ban đầu đang chưa hợp lý; core stats mặc định của các nghề đang giống nhau, không thấy sự chuyên biệt / đặc thù của từng class"* · [charactors.md](charactors.md) (sao chỉ số của chủ dự án) · [20](20-bang-chi-so-nen-nhan-vat.md) (bảng chỉ số nền) · [21](21-thiet-ke-lai-5-lop.md) Q132 · `godot/scripts/core/stats.gd` |
| Loại tài liệu | Phân tích + đề xuất. **Chưa đổi code** |
| Trạng thái | ✅ Duyệt theo đề xuất (28/10). **Mục 3–4 đã gộp với CR-001 thành [26](26-build-lop.md) và đã code (CS)** — số chỉ số và hệ số thuộc tính lấy theo docs/26 |

## 1. Góp ý của người chơi là đúng — số liệu hiện tại

Chỉ số cấp 1 khi chưa cộng điểm (theo `Stats.derive`, sau CL1):

| Chỉ số | Kiếm Khách | Thợ Săn | Pháp Sư | Hộ Vệ | Triệu Hồi Sư |
| --- | --- | --- | --- | --- | --- |
| HP (+ mỗi cấp) | 100 (+15) | 90 (+13) | 85 (+12) | 115 (+17) | 88 (+12) |
| Tấn công (+ mỗi cấp) | **10 (+2)** | **10 (+2)** | **10 (+2)** | **10 (+2)** | **10 (+2)** |
| Phòng thủ (+ mỗi cấp) | 5 (+1,5) | 5 (+1,5) | 4 (+1,2) | **5 (+1,5)** | 5 (+1,5) |
| MP | 50 | 50 | 80 | 50 | 70 |
| Tốc đánh | **1,00** | **1,00** | **1,00** | **1,00** | **1,00** |
| Chí mạng | 8% | 5% | 5% | 5% | 5% |
| ST chí mạng | **×1,5** | **×1,5** | **×1,5** | **×1,5** | **×1,5** |
| Né tránh | 0% | 5% | 0% | 0% | 0% |
| Tốc chạy | **230** | **230** | **230** | **230** | **230** |

Vấn đề cụ thể:

| # | Vấn đề | Hậu quả người chơi thấy |
| --- | --- | --- |
| P1 | **7/10 chỉ số giống hệt nhau** giữa 5 lớp; khác biệt chỉ ở HP (±15%) và vài con số nhỏ (chí mạng 8%, né 5%) | Màn chọn lớp (UI-22) hiện 7 chỉ số cấp 1 gần như trùng nhau → "nghề nào cũng vậy" |
| P2 | **Chỉ số mặc định chỉ để trình bày** (UI-19 / D47): Kiếm Khách hiện "STR 5", Pháp Sư "INT 5" nhưng code trừ ngược phần đó, nên 17 điểm mặc định **không cho gì** | Người chơi thấy số nhưng không thấy tác dụng — "chưa hợp lý" |
| P3 | **Hộ Vệ (Tank) có Phòng thủ bằng Kiếm Khách** dù sao DEF ★★★★★; Thợ Săn né ★★★★★ nhưng né nền chỉ 5%, trần 30% như mọi lớp | Sao trong charactors.md không khớp số thật |
| P4 | **AGI cho lớp khác lợi hơn cho Thợ Săn**: 1 AGI = +1% tốc đánh, +0,5% chí mạng cho Kiếm Khách / Pháp Sư, nhưng Thợ Săn chỉ +0,6% tốc đánh (trần +20%), +0,25% chí mạng | Lớp "Nhanh nhẹn" lại nhận ít nhất từ Nhanh nhẹn |
| P5 | Không có **cơ chế chỉ số riêng** của lớp (chặn đòn, xuyên giáp, hồi MP khi đánh, sức mạnh linh thú…) — đặc thù chỉ đến từ kỹ năng | Sau khi cộng điểm, bảng Chỉ số của 5 lớp trông như nhau |

Nguyên nhân gốc: từ M3 cân bằng bằng cách giữ "người chơi chuẩn" giống nhau rồi chỉnh kỹ năng; UI-19 thêm chỉ số mặc định nhưng cố ý không đổi một con số nào (để không phải cân lại).

## 2. Hướng đề xuất

Ba thay đổi, làm cùng một đợt (gọi là **CS — Chỉ số lớp**):

1. **Mỗi lớp một hồ sơ chỉ số rõ rệt** theo sao của charactors.md (mục 3) — chênh lệch đủ lớn để nhìn thấy (20–50%), nhưng giữ luật kịch bản *các lớp hạ cùng boss chênh ≤ 25%* bằng cách bù trừ: lớp đánh mạnh thì mỏng, lớp dày thì đánh yếu.
2. **Chỉ số mặc định có tác dụng thật + tự tăng theo nghề** (mục 4): bỏ phần trừ ngược của D47; mỗi cấp lớp tự nhận một số điểm vào thuộc tính chính của nghề (như MU Online / Ragnarok), thay cho phần "nền tăng theo cấp" đang giống nhau. 5 điểm tự do mỗi cấp giữ nguyên.
3. **Mỗi lớp 1 "Thiên tính lớp"** — 2 chỉ số chỉ lớp đó có (mục 3.2), hiện ở trang Chỉ số.

## 3. Hồ sơ chỉ số đề xuất

### 3.1. Chỉ số nền (cấp 1 → mỗi cấp)

Số in đậm là chỗ đổi. Cột "Sao" lấy từ charactors.md.

| Chỉ số | Kiếm Khách | Thợ Săn | Pháp Sư | Hộ Vệ | Triệu Hồi Sư |
| --- | --- | --- | --- | --- | --- |
| Vai trò | Cận chiến · chí mạng | Đánh xa · né, cơ động | Phép diện rộng | Đỡ đòn | Điều khiển linh thú |
| HP | 100 (+15) · ★★★ | **85 (+12)** · ★★ | **75 (+11)** · ★★ | **140 (+22)** · ★★★★★ | 90 (+13) · ★★★ |
| Tấn công | **12 (+2,3)** · ★★★★★ | 10 (+2,1) · ★★★★ | 10 (+2,1) phép · ★★★★★ | **7 (+1,4)** · ★★ | **8 (+1,6)** bản thân |
| Phòng thủ | **4,5 (+1,3)** · ★★ | **4 (+1,1)** · ★★ | **3,5 (+0,9)** · ★ | **9 (+2,6)** · ★★★★★ | 5 (+1,4) |
| MP · hồi/giây | 50 · 3 | 55 · 3 | **100 · 4,5** · ★★★★★ | 50 · 3 | **100 · 4** · ★★★★★ |
| Tốc đánh | **1,05** | **1,10** | **0,95** | **0,90** | 1,00 |
| Chí mạng · ST chí mạng | **10% · ×1,75** · ★★★★★ | **8% · ×1,6** · ★★★★ | 5% · ×1,5 | **3% · ×1,5** | 5% · ×1,5 |
| Né tránh (trần) | 3% (30%) | **12% (40%)** · ★★★★★ | 0% (30%) | 0% (20%) | 3% (30%) |
| Tốc chạy | **235** · ★★★★ | **250** | **225** | **215** | 230 |

### 3.2. Thiên tính lớp (chỉ lớp đó có, hiện ở trang Chỉ số)

| Lớp | Thiên tính 1 | Thiên tính 2 |
| --- | --- | --- |
| Kiếm Khách | **Kiếm thế** — mỗi đòn trúng liên tiếp trong 2 giây +2% tốc đánh (tối đa +20%), mất khi bị trúng đòn | **Xuyên giáp** 10% — bỏ qua 10% Phòng thủ quái |
| Thợ Săn | **Tầm bắn** +15% (đạn bay xa hơn, tự ngắm xa hơn) | **Thân pháp** — né thành công hồi 20% hồi chiêu né lăn |
| Pháp Sư | **Sát thương kỹ năng** +15% | **Thấu phép** — kỹ năng bỏ qua 10% kháng hệ của quái (khi có kháng hệ) |
| Hộ Vệ | **Giảm sát thương** 10% mọi đòn | **Chặn đòn** 12% — chặn 60% một đòn trước mặt |
| Triệu Hồi Sư | **Linh lực** — linh thú nhận +1% Tấn công và HP mỗi 1 INT | **Gắn kết** — mỗi linh thú đang sống +4% hồi MP cho chủ (tối đa 3) |

### 3.3. Vì sao không lệch cân bằng

Thước đo nhanh (cấp 1, chưa cộng điểm, chưa tính Thiên tính lớp; "chuẩn" = Tấn công 10, tốc đánh 1,0, chí mạng 5% ×1,5, HP 100, Phòng thủ 5; "sát thương" = Tấn công × tốc đánh × (1 + chí mạng × (ST chí mạng − 1)); "trụ" = HP × (1 + Phòng thủ/50) / (1 − né)):

| | Kiếm Khách | Thợ Săn | Pháp Sư | Hộ Vệ | Triệu Hồi Sư |
| --- | --- | --- | --- | --- | --- |
| Sát thương (chuẩn = 1,00) | 1,32 | 1,12 | 0,95 × 1,15 kỹ năng ≈ 1,09 | 0,62 | 0,80 + linh thú |
| Trụ (chuẩn = 1,00) | 1,02 | 0,95 | 0,73 | 1,50 (≈ 1,75 khi tính giảm 10% + chặn đòn) | 0,93 |
| Đặc điểm bù | Cận chiến, phải lao vào | Đánh xa an toàn hơn | Diện rộng, đánh được nhiều quái | Không chết nhưng đánh chậm | Sát thương chủ yếu ở linh thú |

Số trên là **điểm xuất phát**. Mọi số cuối cùng phải qua test cân bằng có sẵn (TL-B…TL-B6, SK2-T4, SK3-T4 cho cả 5 lớp) với luật **chênh ≤ 25%, 0 lần chết**; chỉnh hệ số (thường là Tấn công nền) cho tới khi đạt. Hộ Vệ và Triệu Hồi Sư được phép chậm hơn tới 25% ở trận boss vì vai trò, nhưng không chết.

## 4. Chỉ số mặc định có tác dụng thật + tự tăng theo nghề

### 4.1. Thay "nền tăng theo cấp giống nhau" bằng "thuộc tính tự tăng theo nghề"

Hiện tại mỗi cấp mọi lớp nhận cùng +2 Tấn công, +1,5 Phòng thủ (nền) **và** 5 điểm tự do. Đề xuất: phần nền chuyển thành **thuộc tính tự tăng** — mỗi 10 cấp lớp tự nhận các điểm dưới (tổng 27 mỗi lớp, chia đều theo cấp), hiện trên trang Chỉ số dạng **"mặc định + tự tăng + điểm cộng"**. 5 điểm tự do mỗi cấp **giữ nguyên**.

| Mỗi 10 cấp | STR | AGI | INT | VIT | LUK |
| --- | --- | --- | --- | --- | --- |
| Kiếm Khách | **10** | 5 | 0 | 9 | 3 |
| Thợ Săn | 3 | **11** | 0 | 8 | 5 |
| Pháp Sư | 0 | 3 | **12** | 8 | 4 |
| Hộ Vệ | 6 | 2 | 0 | **16** | 3 |
| Triệu Hồi Sư | 0 | 3 | **10** | 10 | 4 |

Phần nền theo cấp (cột "+ mỗi cấp" ở mục 3.1) **trừ đi** phần thuộc tính tự tăng đã cho, để tổng ở mỗi cấp đúng bằng bảng 3.1 — tức là con số người chơi thấy trên trang Chỉ số **giải thích được** từ thuộc tính ("STR 52 → +104 Tấn công"), thay vì một "nền" vô hình.

### 4.2. Mỗi thuộc tính lợi nhất cho đúng lớp của nó

| 1 điểm | Kiếm Khách | Thợ Săn | Pháp Sư | Hộ Vệ | Triệu Hồi Sư |
| --- | --- | --- | --- | --- | --- |
| STR | **+2 Tấn công**, +0,2% ST chí mạng | +0,5 Tấn công | — | **+1,5 Tấn công** | — |
| AGI | +0,6% tốc đánh, +0,4% chí mạng | **+2 Tấn công, +0,8% tốc đánh, +0,3% né** | +0,4% tốc đánh | +0,4% tốc đánh | +0,4% tốc đánh |
| INT | +4 MP | +4 MP | **+2 Tấn công phép, +8 MP, +0,6% ST kỹ năng** | +4 MP | **+1 Tấn công, +8 MP, linh thú +1%** |
| VIT | +12 HP, +0,5 Phòng thủ | +12 HP, +0,4 Phòng thủ | +12 HP, +0,4 Phòng thủ | **+16 HP, +0,8 Phòng thủ**, +0,5 Tấn công | +12 HP, +0,5 Phòng thủ |
| LUK | +0,3% chí mạng, +0,2% rơi đồ | +0,3% chí mạng, +0,2% rơi đồ | +0,2% chí mạng, +0,2% rơi đồ | +0,2% chặn đòn, +0,2% rơi đồ | +0,2% chí mạng, +0,3% rơi đồ |

Sửa P4: AGI của Thợ Săn giờ cho nhiều nhất (Tấn công + tốc đánh + né); bỏ trần +20% tốc đánh riêng của Thợ Săn, thay bằng trần chung tốc đánh ×2,0.

### 4.3. Save cũ

Không mất gì: điểm tự do đã cộng giữ nguyên; thuộc tính tự tăng tính theo cấp hiện tại (không lưu); mở game lần đầu sau cập nhật **tẩy điểm miễn phí 1 lần** để người chơi phân bổ lại theo hệ số mới.

## 5. Giao diện đi kèm

| Mã | Yêu cầu |
| --- | --- |
| CS-UI1 | Màn chọn lớp (UI-22): thay 7 số cấp 1 (gần giống nhau) bằng **thanh 5 sao** theo bảng 3.1 (HP, Tấn công, Phòng thủ, Tốc độ, Chí mạng / Né / MP / Linh thú tuỳ lớp) + 2 dòng Thiên tính lớp; số thật hiện khi rê chuột |
| CS-UI2 | Trang Chỉ số (UI-21): mỗi thuộc tính hiện "mặc định + tự tăng + điểm cộng"; khung **Thiên tính lớp** dưới thẻ Thiên phú; thuộc tính chính của lớp có viền màu lớp + nhãn "Chính" |
| CS-UI3 | Tooltip thuộc tính ghi đúng tác dụng **cho lớp đang chơi** (bảng 4.2), không ghi chung |
| CS-UI4 | Lên cấp: dòng nhật ký *"Lên cấp 12! +5 điểm · STR +1, VIT +1 (tự tăng)"* — trả lời luôn Spec_Notes *"Khi nhân vật tăng cấp, máu và các thuộc tính khác được tăng thêm như thế nào"* |

## 6. Điểm cần chủ dự án chọn

| # | Câu hỏi | Đề xuất |
| --- | --- | --- |
| Q147 | Độ chênh giữa các lớp: nhỏ (±10%, an toàn) hay rõ (±20–50% như mục 3.1)? | **Rõ** — đúng góp ý người chơi; cân lại bằng test, luật thời gian hạ boss ≤ 25% giữ nguyên |
| Q148 | Chỉ số mặc định có tác dụng thật (bỏ phần trừ ngược D47)? | **Có** |
| Q149 | Thuộc tính tự tăng theo nghề (mục 4.1) hay giữ "nền theo cấp" vô hình? | **Tự tăng theo nghề** — số trên trang Chỉ số giải thích được |
| Q150 | Giữ 5 điểm tự do mỗi cấp? | **Giữ** |
| Q151 | Thiên tính lớp (mục 3.2) — 2 cái mỗi lớp? | **Có**, đúng 2 cái, không mở rộng thêm để tránh chồng với Thiên phú |
| Q152 | Tẩy điểm miễn phí 1 lần cho save cũ? | **Có** |

## 7. Ảnh hưởng và cách làm (khi duyệt)

| Hạng mục | Ảnh hưởng |
| --- | --- |
| Code | `core/stats.gd` (bảng hồ sơ lớp thay các hằng `SWORD_CRIT`, `MAGE_DEF`, `GUARD_*`, `SUMMONER_*`; bỏ phần trừ `b_*`), `GameWorld` (tốc chạy, chặn đòn, giảm sát thương, Kiếm thế, Thân pháp), `Classes2` (Linh lực, Gắn kết), `ui/stats_page.gd`, `ui/class_select.gd` |
| Cân bằng | Chạy lại toàn bộ TL-B…TL-B6, SK2-T4, SK3-T4, TL-J3, LH1/LH2 cho 5 lớp; PACE-T1/T2 kiểm nhịp lên cấp (lớp mỏng có thể chết nhiều hơn khi cày) |
| Test mới | **CS-T1**: mỗi lớp đứng đầu ở ít nhất 2 chỉ số trong bảng 3.1 (kiểm "đặc thù" bằng máy); **CS-T2**: thuộc tính tự tăng + mặc định + điểm cộng ra đúng số bảng 3.1 ở cấp 1, 30, 60, 100; **CS-T3**: save cũ được tẩy điểm 1 lần |
| Tài liệu | Cập nhật 20 (bảng theo cấp), 21 (Q132 thay bằng mục 3), 02 (D47 → quyết định mới), 03, 04 |
