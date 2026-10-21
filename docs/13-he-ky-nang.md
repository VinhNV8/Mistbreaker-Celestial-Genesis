# Nghiên cứu và đề xuất: Hệ kỹ năng theo lớp và theo hệ

| | |
| --- | --- |
| Dự án | Thiên Phú Khai Giới |
| Nguồn | Spec_Notes đợt 5: *"Cần nghiên cứu kỹ về skills của từng hệ, đề xuất các hướng build skills, nên cố định, hay mở theo level (chuyển chức) hay là nên đánh quái rơi skills và học…"* · [Kịch bản](kich-ban-game-thien-phu-khai-gioi.md) mục 4 (4 lớp, 3 lần chuyển chức), mục 5 (*"đánh thường + 4 kỹ năng + 1 kỹ năng Thiên phú + né lăn"*, ngũ hành tương khắc) |
| Loại tài liệu | Nghiên cứu + đề xuất + kế hoạch triển khai |
| Trạng thái | ✅ **Đã duyệt "theo đề xuất"** (21/10/2026) — Q65–Q70 như cột Đề xuất mục 6. **SK1, SK2 xong** (mục 7, 8); SK3 chưa làm |

## 1. Hiện trạng trong game

| Lớp | Đánh thường | 4 kỹ năng (phím 1–4) | Chuyển chức 1 (cấp 30) | Chuyển chức 2 (cấp 60, chọn 1/2) |
| --- | --- | --- | --- | --- |
| Kiếm Khách | Chém | Xoáy Kiếm · Đột Kích · Kiếm Khí · Thiết Bích | Kiếm Sư (bị động) | Kiếm Thánh / Huyết Kiếm (bị động) |
| Thợ Săn | Bắn | Mưa Tên · Tên Xuyên Phá · Bẫy Gai · Ưng Nhãn | Xạ Thủ (bị động) | Thần Tiễn / Thợ Bẫy (bị động) |
| Pháp Sư | Hỏa Cầu | Lôi Xích · Băng Ngục · Thiên Thạch · Pháp Thuẫn | Pháp Sư Nguyên Tố (bị động) | Đại Pháp Sư / Tử Linh Sư (bị động) |

Ngoài ra: 1 kỹ năng Thiên phú (phím L, 20 Thiên phú — khác nhau mạnh) và Đạo Tặc sao chép kỹ năng boss (5 kỹ năng).

**Vấn đề:**

1. **Không có build kỹ năng:** mỗi lớp đúng 4 kỹ năng, có hết từ cấp 1, không lên cấp, không biến thể. Hai người cùng lớp chơi giống nhau, khác biệt chỉ đến từ Thiên phú và đồ.
2. **Không có mốc "mở khoá" kỹ năng** từ cấp 1 đến 60 — mất một nguồn cảm giác tiến bộ quan trọng của ARPG (kịch bản mục 9: *"sướng khi đánh quái lên cấp"*).
3. **Ngũ hành chỉ có ở quái và Thiên phú Ngũ Hành Linh Căn** — người chơi gần như không chọn hệ cho đòn đánh của mình (CB-05 đang 🟡).
4. Chuyển chức chỉ cho bị động → không có kỹ năng chủ động mới suốt 60 cấp.

## 2. Thị trường làm thế nào

| Game | Cách nhận kỹ năng | Cách tạo build | Điểm mạnh | Điểm yếu (với game này) |
| --- | --- | --- | --- | --- |
| **Diablo Immortal** (mobile) | Kỹ năng **mở theo cấp** cố định mỗi lớp (ví dụ Wizard: Magic Missile cấp 1, Lightning Nova cấp 3… Electrocute cấp 34); lắp 1 đánh thường + 4 kỹ năng | Chọn 4 trong ~12 kỹ năng của lớp; đồ Huyền thoại biến đổi kỹ năng | Dễ hiểu, mốc mở đều, hợp mobile/auto | Build sâu chủ yếu nằm ở đồ |
| **Diablo 4** | Điểm kỹ năng mỗi cấp, cây kỹ năng theo nhánh | Chọn 6 kỹ năng + nâng cấp nhánh (enhanced / upgrade) | Build rõ ràng, đổi được | Cây nhiều nút dễ làm người mới rối |
| **Lost Ark** | Điểm kỹ năng theo cấp (tổng 282 ở cấp tối đa) + bình điểm kỹ năng | **Tripod**: mỗi kỹ năng 3 tầng (mở ở cấp kỹ năng 4/7/10), mỗi tầng chọn 1 trong 2–3 biến thể; đổi lại lúc nào cũng được | Cùng kỹ năng có nhiều cách chơi, dễ hiểu | Thời gian cày Tripod dài |
| **Path of Exile 2** | **Đá kỹ năng rơi** (Uncut Gem) từ quái/boss/nhiệm vụ; cấp đá theo vùng rơi; đá hỗ trợ gắn vào kỹ năng | Ghép kỹ năng + đá hỗ trợ — tự do tối đa | Build vô hạn, săn đồ hấp dẫn | Rất khó với người mới; phụ thuộc may rủi |
| **Torchlight Infinite** | Nhận kỹ năng qua nhiệm vụ / mua ở cửa hàng; **kỹ năng hỗ trợ rơi** hiếm | 5 kỹ năng chủ động + 3 bị động, mỗi cái tới 5 ô hỗ trợ | Đa dạng | Người chơi than kỹ năng hỗ trợ rơi quá hiếm ("~100 giờ mới rơi 2 cái"), phải mua chợ |

**Rút ra:**

- Game **mobile / lai idle** thắng nhờ **mốc mở khoá rõ ràng** (Diablo Immortal) — người mới không bao giờ bị kẹt vì "chưa rơi kỹ năng".
- Độ sâu build đến từ **biến thể của kỹ năng** (Tripod của Lost Ark, Rune của Diablo 3), không cần cây kỹ năng khổng lồ.
- **Kỹ năng rơi ngẫu nhiên hoàn toàn** chỉ hợp game có chợ giao dịch và người chơi lõi (PoE, Torchlight). Game này **chưa có chợ** và **đã có một vòng quay may rủi lớn là Thiên phú** — chồng thêm may rủi lên kỹ năng dễ làm người chơi thấy "không phải lỗi mình".

## 3. Ba hướng chủ dự án hỏi — đánh giá cho Thiên Phú Khai Giới

| Hướng | Mô tả | Hợp với game | Không hợp | Đánh giá |
| --- | --- | --- | --- | --- |
| **A. Cố định** (như hiện tại) | 4 kỹ năng mỗi lớp, có từ đầu | Đơn giản, dễ cân bằng (TL-B) | Không có build; 60 cấp không có kỹ năng mới | ❌ Không đủ cho Alpha/Beta |
| **B. Mở theo cấp + chuyển chức** | Mỗi lớp ~12 kỹ năng chủ động, mở ở các mốc cấp; chuyển chức mở thêm kỹ năng của nhánh | Mốc tiến bộ đều; chuyển chức có ý nghĩa; hợp Tự đánh; dễ cân bằng | Cùng lớp vẫn hơi giống nhau nếu không có biến thể | ✅ Làm nền |
| **C. Đánh quái rơi rồi học** | Sách kỹ năng rơi từ quái/boss | Vòng săn đồ hấp dẫn; khớp hệ Di tích / boss hiếm | May rủi chồng lên Thiên phú; người mới có thể kẹt; cần chợ để công bằng | ⚠️ Chỉ dùng cho **phần thêm**, không cho kỹ năng chính |

## 4. Đề xuất: **B làm nền + "Bí Kíp" rơi để mở biến thể + ngũ hành gắn vào biến thể**

### 4.1. Kỹ năng chủ động: mở theo cấp và chuyển chức (hướng B)

Mỗi lớp **12 kỹ năng chủ động**, vẫn lắp **4 ô** (phím 1–4) như kịch bản. Đổi kỹ năng trong ô **miễn phí khi ở vùng an toàn** (làng, trại, thành).

| Mốc | Kiếm Khách | Thợ Săn | Pháp Sư |
| --- | --- | --- | --- |
| Cấp 1 | Xoáy Kiếm, Đột Kích | Mưa Tên, Tên Xuyên Phá | Lôi Xích, Băng Ngục |
| Cấp 4 | Kiếm Khí | Bẫy Gai | Thiên Thạch |
| Cấp 8 | Thiết Bích | Ưng Nhãn | Pháp Thuẫn |
| Cấp 15 | *Liên Trảm* (3 nhát liên tiếp) | *Tên Nảy* (nảy giữa 4 quái) | *Hoả Tường* (tường lửa chắn đường) |
| Cấp 22 | *Hống Kiếm* (gầm khiêu khích, giảm Tấn công quái) | *Lăn Bắn* (né lăn kèm 3 mũi tên) | *Dịch Chuyển* (blink 15 m) |
| Chuyển chức 1 (30) | +2 kỹ năng của chức: *Kiếm Vũ* (đứng xoáy giữ phím), *Phi Kiếm* | *Liên Xạ* (bắn giữ phím), *Tên Độc* | *Mưa Băng*, *Cầu Sấm* |
| Cấp 45 | 1 kỹ năng tối thượng mỗi lớp (hồi 60 giây) | | |
| Chuyển chức 2 (60) | +2 kỹ năng **riêng từng nhánh** (ví dụ Huyết Kiếm: *Huyết Bạo*; Thợ Bẫy: *Bãi Mìn*; Tử Linh Sư: *Triệu Hồi Xương*) | | |

Ghi chú: 4 kỹ năng hiện có giữ nguyên, chỉ dời mốc mở ở cấp 1–8 để có nhịp *"học kỹ năng mới"* trong 30 phút đầu (khớp chuỗi nhiệm vụ chương 1).

### 4.2. Cấp kỹ năng: dùng điểm, không cày riêng

- Mỗi lên cấp nhân vật: **+1 Điểm Kỹ Năng** (song song 5 điểm tiềm năng). Nhiệm vụ chương cho thêm.
- Kỹ năng cấp 1 → 10: mỗi cấp **+8% hệ số**; cấp 4 / 7 / 10 mở **tầng biến thể** I / II / III (giống Tripod).
- **Tẩy điểm kỹ năng miễn phí** ở vùng an toàn — khuyến khích thử build, không phạt người mới.

### 4.3. Biến thể kỹ năng — "Bí Kíp" (phần lấy từ hướng C)

Mỗi kỹ năng có **3 tầng × 2 biến thể** (chọn 1 mỗi tầng):

- **Biến thể thường** (một nửa) — mở ngay khi kỹ năng đạt cấp 4 / 7 / 10.
- **Biến thể Bí Kíp** (nửa còn lại) — cần **Bí Kíp** của kỹ năng đó:
  - Rơi từ **tinh anh** (tầng I), **boss vùng** (tầng II), **boss hiếm** (tầng III), **ô Di tích** (câu đố M5-04).
  - **Bảo hiểm chống xui:** Bí Kíp trùng → 1 *Mảnh Bí Kíp*; đủ 5 mảnh đổi Bí Kíp bất kỳ ở Thánh Đường / Thợ rèn. Không ai phải chờ "100 giờ không rơi" như Torchlight.

### 4.4. Ngũ hành gắn vào kỹ năng (trả lời "skills của từng hệ")

Biến thể tầng II của mọi kỹ năng sát thương là **một trong 5 hệ**, mỗi hệ một hiệu ứng phụ khớp bảng khắc đang có (Kim khắc Mộc, Mộc khắc Thổ, Thổ khắc Thủy, Thủy khắc Hỏa, Hỏa khắc Kim, +30%):

| Hệ | Hiệu ứng phụ | Ví dụ |
| --- | --- | --- |
| Hỏa | Thiêu đốt (sát thương theo thời gian) | Xoáy Kiếm · Hỏa: để lại vòng lửa |
| Thủy | Làm chậm / đóng băng | Mưa Tên · Thủy: mưa băng làm chậm 30% |
| Mộc | Hút máu / trói | Bẫy Gai · Mộc: dây leo trói lâu hơn, hồi máu |
| Kim | Xuyên giáp (bỏ qua 20% Phòng thủ), +chí mạng | Kiếm Khí · Kim: xuyên giáp |
| Thổ | Choáng / +sát thương vào Phá Thế | Thiên Thạch · Thổ: choáng 1 giây |

→ Người chơi **chọn hệ theo vùng / boss** (vùng Hỏa thì lắp biến thể Thủy…), làm hệ khắc trở thành lựa chọn chiến thuật thật — đúng tinh thần kịch bản mục 5. Thiên phú **Ngũ Hành Linh Căn** vẫn đặc biệt: đổi hệ tức thì mọi kỹ năng không cần đổi biến thể.

### 4.5. Ví dụ build (Kiếm Khách cấp 60)

| Build | Kỹ năng lắp | Biến thể chính | Hợp với |
| --- | --- | --- | --- |
| **Lốc Xoáy Huyết** | Xoáy Kiếm, Kiếm Vũ, Thiết Bích, Huyết Bạo | Xoáy Kiếm · Mộc (hút máu), Kiếm Vũ · kéo quái | Huyết Kiếm, Hấp Huyết, Tự đánh cày quái |
| **Kiếm Khí Xuyên Giáp** | Kiếm Khí, Phi Kiếm, Đột Kích, Liên Trảm | Kiếm Khí · Kim, Phi Kiếm · nảy | Kiếm Thánh, đánh boss giáp |
| **Phá Thế Choáng** | Liên Trảm, Hống Kiếm, Đột Kích, tối thượng | Thổ ở mọi kỹ năng | Kiếm Thánh, boss nhiều Phá Thế |

## 5. Ảnh hưởng và cách làm

| Hạng mục | Ảnh hưởng |
| --- | --- |
| Cân bằng | TL-B… phải chạy theo **bộ kỹ năng mặc định theo cấp** + 1–2 build mẫu mỗi lớp; thêm test "build mạnh nhất / yếu nhất chênh ≤ 25%" |
| Tự đánh | Dùng 4 kỹ năng đang lắp — không đổi |
| Đạo Tặc | Kỹ năng sao chép vẫn ở phím L (Thiên phú), không chiếm ô |
| Save | `skills_unlocked`, `skill_levels`, `skill_points`, `loadout[4]`, `variants{kỹ năng: [t1, t2, t3]}`, `secret_books`, `book_shards` |
| Giao diện | Bảng **Kỹ năng (phím K)**: danh sách 12 kỹ năng, cấp, biến thể, kéo vào 4 ô |
| Hình | ~24 icon kỹ năng mới mỗi đợt + icon Bí Kíp (sinh bằng code, `tools/art`) |

**Lộ trình đề xuất (sau khi duyệt):**

| Đợt | Nội dung | Ước lượng |
| --- | --- | --- |
| SK1 | Khung: mở kỹ năng theo cấp (dời 4 kỹ năng hiện có về mốc 1/4/8), ô lắp + đổi ở vùng an toàn, Điểm Kỹ Năng + cấp kỹ năng, bảng K, save | 1 đợt |
| SK2 | +2 kỹ năng mỗi lớp ở cấp 15/22 + 2 kỹ năng chuyển chức 1, biến thể tầng I–III (thường), 5 hệ ở tầng II | 1–2 đợt |
| SK3 | Bí Kíp rơi + Mảnh Bí Kíp + đổi ở Thánh Đường; kỹ năng tối thượng cấp 45; kỹ năng nhánh chuyển chức 2 | 1–2 đợt |

## 6. Điểm cần chủ dự án chọn

| # | Câu hỏi | Đề xuất |
| --- | --- | --- |
| Q65 | Hướng tổng thể: A (cố định) / B (mở theo cấp + chuyển chức) / C (rơi rồi học) / **B + Bí Kíp** | **B + Bí Kíp** (mục 4) |
| Q66 | Số ô kỹ năng: giữ 4 (kịch bản) hay tăng lên 5–6 ở cấp cao? | Giữ **4** (+ phím L Thiên phú) — hợp mobile, kịch bản đã ghi |
| Q67 | Điểm Kỹ Năng tách riêng hay dùng chung điểm tiềm năng? | **Tách riêng**, 1 điểm/cấp; tẩy miễn phí ở vùng an toàn |
| Q68 | Bí Kíp có giao dịch được không (khi có chợ ở Beta)? | Bí Kíp tầng I–II giao dịch được, tầng III khoá vào nhân vật |
| Q69 | Ngũ hành ở biến thể tầng II, hay cho đổi hệ tự do? | **Biến thể tầng II** — đổi bằng cách chọn lại biến thể (miễn phí ở vùng an toàn); tự do đổi hệ là đặc quyền của Ngũ Hành Linh Căn |
| Q70 | Làm hệ kỹ năng trước hay làm tiếp Chương 6? | Làm **SK1** trước (nền cho mọi chương sau; cân bằng chương 6+ sẽ dựa trên nó) |

## 7. Kết quả SK1 (21/10/2026)

| Hạng mục | Đã làm |
| --- | --- |
| Mở theo cấp | Mỗi kỹ năng có `unlock` trong `classes.gd`: 2 kỹ năng đầu cấp 1, kỹ năng 3 cấp 4, kỹ năng 4 cấp 8 (3 lớp). Lên cấp mở kỹ năng thì báo + sự kiện `skill_unlock`. Kỹ năng khoá: ô mờ, ghi "Cấp X", bấm thì báo cấp mở; Tự đánh bỏ qua |
| Điểm Kỹ Năng | +1 mỗi lần lên cấp (tách khỏi điểm tiềm năng, Q67). Save cũ được bù `cấp − 1` điểm |
| Cấp kỹ năng 1–10 | Kỹ năng sát thương ×(1 + 8% × (cấp − 1)) → cấp 10 ×1,72; kỹ năng hỗ trợ (Thiết Bích, Ưng Nhãn, Pháp Thuẫn) hồi chiêu −4%/cấp → cấp 10 −36% |
| 4 ô lắp | `profile.loadout` (id kỹ năng), phím 1–4 theo ô; `GameWorld.slot_skill(i)` thay mọi chỗ đọc kỹ năng theo vị trí. Đổi ô (2 ô đổi chỗ, hồi chiêu đi theo kỹ năng) và **tẩy điểm miễn phí chỉ ở vùng an toàn** |
| Giao diện | Bảng **Kỹ năng — phím U** (`ui/skill_panel.gd`; phím K đã là kỹ năng 1 khi chơi bàn phím, Q29): cấp, mô tả, +1 cấp, nút ô 1–4, Tẩy điểm. Thanh kỹ năng ghi cấp kỹ năng (ví dụ "Xoáy Kiếm 5"). Màn chọn lớp ghi cấp mở |
| Save | v13: `skill_points`, `skill_levels`, `loadout` (v12 dành cho M9 chương 6) |
| Cân bằng | TL-B…TL-B5 không đổi: bot dùng kỹ năng cấp 1 (Điểm Kỹ Năng chưa dùng), các boss ở cấp ≥ 5. Ở TL-B (cấp 5) kỹ năng 4 (hỗ trợ) bị khoá — không ảnh hưởng thời gian. Khi SK2 có thêm kỹ năng, cần build mẫu cho từng lớp trong TL-B |
| Kiểm thử | SK1-T1 (mốc mở, khoá), SK1-T2 (điểm, +8%, −4%, tẩy ở vùng an toàn), SK1-T3 (đổi ô, phím theo ô, save v13 + bù điểm). Sửa CL-T3, SN-T2 (đặt cấp 8), C1-T4 (dùng 2 kỹ năng cấp 1) |

**Tiếp theo:** SK2 — +2 kỹ năng mỗi lớp ở cấp 15/22, +2 kỹ năng chuyển chức 1, biến thể tầng I–III + 5 hệ ở tầng II; SK3 — Bí Kíp + Mảnh Bí Kíp, kỹ năng tối thượng cấp 45, kỹ năng nhánh chuyển chức 2.

## 8. Kết quả SK2 (22/10/2026)

**12 kỹ năng mới** (`classes.gd`, logic `core/skills2.gd`, vẽ `view/skills2_view.gd`, icon `tools/art/skills2_icons.py`):

| Lớp | Cấp 15 | Cấp 22 | Chuyển chức 1 (cần `job`) | Chuyển chức 1 |
| --- | --- | --- | --- | --- |
| Kiếm Khách | **Liên Trảm** — 3 nhát nón 90°, 7 m, mỗi nhát ×0,9 | **Hống Kiếm** — vòng 8 m ×1,0, quái thường choáng 1,2 s; boss/tinh anh: gấp đôi vào Phá Thế | **Kiếm Vũ** — 2 giây xoay 10 m, 8 lần ×0,45 | **Phi Kiếm** — 3 kiếm toả 30°, xuyên, ×1,2 |
| Thợ Săn | **Tên Nảy** — nảy tối đa 4 quái ×1,1; không còn quái thì dội lại mục tiêu ×0,35 | **Lăn Bắn** — lăn lùi (bất tử) + 3 mũi ×0,8 | **Liên Xạ** — 8 mũi ×0,6 trong 1,5 s, vẫn di chuyển | **Tên Độc** — xuyên ×1,0 + độc cộng dồn (như Đuôi Sa Hoàng) |
| Pháp Sư | **Hoả Tường** — tường 12 m, 4 s, ×0,4 mỗi 0,5 s | **Dịch Chuyển** — 15 m, chỗ cũ nổ băng 6 m ×0,8 + làm chậm | **Mưa Băng** — 9 m, 5 đợt ×0,5 + làm chậm | **Cầu Sấm** — cầu bay 25 m phóng sét ×0,5 mỗi 0,3 s, nổ cuối ×1,5 |

**Biến thể 3 tầng** (mở ở cấp kỹ năng 4 / 7 / 10; đổi ở vùng an toàn; `profile.variants`, save v14):

| Tầng | Kỹ năng sát thương | Kỹ năng hỗ trợ (Thiết Bích, Ưng Nhãn, Pháp Thuẫn) |
| --- | --- | --- |
| I | Tiết Kiệm −20% MP · Thần Tốc −15% hồi chiêu | như bên trái |
| II | **5 hệ**: Hỏa thiêu đốt 3 s (15% Tấn công/giây) · Thủy làm chậm 2 s · Mộc hút máu 4% · Kim bỏ qua 25% Phòng thủ · Thổ +50% vào Phá Thế. Hệ khắc hệ quái: **+30%** | Bền Bỉ hiệu lực +30% · Hồi Phục hồi 10% HP khi dùng |
| III | Bạo Lực +25% sát thương · Chí Mạng +20% tỉ lệ chí mạng | Tinh Thông −20% hồi chiêu · Vô Ngã không tốn MP |

**Kỹ thuật (D44):** mọi đòn mang **id kỹ năng nguồn** (`GameWorld.skill_ctx`; đạn, Mưa Tên, Bẫy, Thiên Thạch lưu id lúc tạo) để biến thể áp đúng kỹ năng — cả đòn trễ. Đánh thường không nhận biến thể.

**Cân bằng (SK2-T4)** — Huyền Ảnh, bot cấp 23, bộ đồ chuẩn cấp 23; bộ mặc định vs bộ có 2 kỹ năng mới (cấp 15 + 22), giây trung bình 2 seed: Kiếm Khách 27,9 → 27,7 · Thợ Săn 20,3 → 25,7 · Pháp Sư 27,6 → 35,1 — trong ngưỡng 30%, 0 lần chết. Bộ mới yếu hơn khi đánh boss đơn lẻ là chủ ý: kỹ năng cấp 15/22 thiên về diện rộng / khống chế / cơ động.

**Phát hiện:** bot test bấm kỹ năng theo **vị trí ô** (ô 3 Thợ Săn chỉ bấm khi quái cách < 12 m vì trước đây là Bẫy Gai) → đổi bot sang bấm theo **id kỹ năng** (`BOT_SKILL_RULES`); bộ mặc định cho kết quả y hệt trước (TL-B…TL-B6 không đổi).

**Kiểm thử:** SK2-T1 (mốc mở 8 kỹ năng, kỹ năng chuyển chức), SK2-T2 (12 kỹ năng gây sát thương + choáng / dịch chuyển / lăn / độc / tường / cầu), SK2-T3 (biến thể: mở theo cấp kỹ năng, MP, hồi chiêu, 5 hệ, khắc hệ, Bạo Lực, hỗ trợ, vùng an toàn, save v14), SK2-T4 (cân bằng).

## Nguồn tham khảo

- [Icy Veins — Diablo Immortal Wizard leveling](https://icy-veins.com/diablo-immortal/wizard-leveling-guide) · [TechRadar — Diablo Immortal Demon Hunter skills](https://www.techradar.com/how-to/diablo-immortal-demon-hunter-a-complete-skill-overview) · [TechRadar — Diablo Immortal Monk](https://www.techradar.com/how-to/diablo-immortal-monk-a-complete-skill-overview)
- [Maxroll — Torchlight Infinite skill system](https://maxroll.gg/torchlight-infinite/getting-started/skill-system-overview) · [Steam — Torchlight Infinite support skill drops](https://steamcommunity.com/app/1974050/discussions/0/4634860616374295237)
- [PoE Vault — PoE2 gems guide](https://www.poe-vault.com/poe2/guides/gems-guide) · [Prima Games — leveling gems in PoE2](https://primagames.com/tips/how-to-level-skill-and-support-gems-in-path-of-exile-2)
- [TheGamer — Lost Ark Tripods](https://www.thegamer.com/lost-ark-tripod-skill-upgrades-explained/) · [Mobalytics — Lost Ark skill points](https://mobalytics.gg/blog/lost-ark/lostark-how-to-get-skill-points-in-lost-ark-lost-ark-skill-point-guide/) · [GameSpot — Lost Ark skill point potions](https://gamespot.com/articles/lost-ark-skill-points-easy-ways-to-earn-skill-point-potions/1100-6501010/)
