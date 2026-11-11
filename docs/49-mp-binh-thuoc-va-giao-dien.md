# 49. Cân bằng MP (MP-1), thời gian hồi bình (PT-1), bảng Thiên phú (UI-TL1), ngọc trên thẻ đồ (GC-1), dòng hồi HP/MP trên trang bị (HR-1)

| Mục | Nội dung |
| --- | --- |
| Ngày | 10/11/2026 |
| Yêu cầu | [Spec_Notes](Spec_Notes.md) 10/11 (4 ý): *"Màn hình Thiên phú → trường hợp có thêm thiên phú → bị vỡ khung layout - che khuất màn hình"*; *"Các thuộc tính của đá sau khi gắn vào trang bị → nên thành section riêng và từng dòng tương ứng với đá (có icon nhỏ của đá)"*; *"Khi người chơi sử dụng HP/MP → thời gian hồi lại để sử dụng lần tiếp theo lâu quá → research các game hiện đại → đề xuất"*; *"Lượng MP của nhân vật quá ít → ra vài chiêu đã hết rồi → cần nghiên cứu giải pháp phù hợp cân bằng"*; thêm 10/11 (ý 5): *"Đồ tấn công - Có nên có các dòng như hồi HP/MP không? hãy đề xuất giải pháp theo game hiện đại ngày nay."* |
| Quyết định | Ý 1–4: chủ dự án "Em tiếp tục triển khai" → đã làm với số đề xuất mặc định (Q238–Q241, chỉnh sau playtest). Ý 5: chủ dự án "gộp với doc 49 để review 1 thể" → đề xuất mục G → 11/11 chủ dự án chốt Q242–Q247 (đổi Q243 thành **có** hút HP / MP) + 5 xung đột (G.7) → **đã làm** |
| Mã yêu cầu | `MP-` (cân bằng MP), `PT-` (Potion), `UI-TL1` (bảng Thiên phú), `GC-` (Gem Card), `HR-` (Hồi phục trên trang bị) — đã kiểm tra chưa dùng (`DH-` đã có nơi dùng) |
| Ảnh | [design/mp1/](design/mp1/): `thien-phu.png` (Đạo Tặc + 2 Thiên phú phụ), `the-do-ngoc-kham.png`, `lo-ren-kham-ngoc.png` |
| Trạng thái | A–D ✅ đã làm 10/11/2026 (test MP1-T1, UI-TL1; số MP chỉnh 11/11 theo TL-B, D.3) · G (HR-1) ✅ đã làm 11/11/2026 (test HR1-T1) |

## A. Bảng Thiên phú bị vỡ khung (UI-TL1)

**Nguyên nhân:** bảng (modal) cao theo nội dung, không có giới hạn. Ba cột (thẻ Thiên phú / hiệu ứng theo cấp / cây tiến hoá) cộng hàng Thiên phú phụ bên dưới. Khi Thiên phú có nhiều dòng trạng thái (Đạo Tặc: sao chép, điểm cướp, Túi Tang Vật, Sổ Đạo Tặc, chọn kỹ năng L) và đã mở 2 ô Thiên phú phụ, bảng cao **958 px** trên màn hình 768 px: mất thanh tiêu đề và cả hàng Thiên phú phụ.

**Cách sửa:** ba cột cao cố định theo màn hình (`màn hình − 2 × 24 − 300`, trong khoảng 220–470 px). Nội dung dài **cuộn trong từng cột**, tiêu đề cột đứng yên. Hàng Thiên phú phụ + Cộng hưởng luôn hiện. Với trường hợp nặng nhất ở trên, bảng còn cao 701 px. Màn hình cao hơn thì cột cao hơn (tối đa 470 px).

## B. Ngọc trên thẻ đồ thành mục riêng (GC-1)

Trước: một hàng icon lỗ ngọc + **tổng** chỉ số ngọc gộp ("+37 Tấn công"), không biết viên nào cho gì.

Sau: mục **NGỌC KHẢM n/m** riêng (có đường phân cách), **mỗi lỗ 1 dòng**:

| Cột | Nội dung |
| --- | --- |
| Icon | Icon ngọc nhỏ (20 px) theo hệ + cấp; lỗ trống = icon lỗ mờ |
| Tên | "Bạch Ngọc cấp 6" — màu theo hệ (Kim trắng ngà, Mộc xanh lá, Thủy xanh dương, Hỏa cam đỏ, Thổ vàng đất) |
| Chỉ số | Chỉ số **của viên đó** (vd. "+21 Tấn công"; đồ phòng thủ có thêm "+x% Kháng hệ") |
| Lỗ trống | "Lỗ trống — khảm ở Lò Rèn (tab Khảm ngọc)" |

Dòng "Ấn hệ …" (vũ khí ≥ 2 viên cùng hệ) giữ ngay dưới mục. Lò Rèn → Khảm ngọc dùng chung dòng này dưới các ô lỗ ngọc, rồi thêm dòng "Tổng ngọc" khi có ≥ 2 viên.

## C. Thời gian hồi bình (PT-1)

### C.1. Hiện trạng

| Bình | Hồi | Thời gian hồi (trước) |
| --- | --- | --- |
| Bình máu (Q) | 35% HP tức thì | 8 giây |
| Bình MP (F) | 40% MP tức thì | 8 giây |

Hai bình hồi riêng. Mua 30 vàng, không giới hạn số bình mang theo.

### C.2. Các game hiện đại làm thế nào

| Game | Cách làm | Ghi chú |
| --- | --- | --- |
| Lost Ark | Bình máu thường hồi 30% HP tức thì, **hồi 10 giây**; bình loại tốt hồi 45–60%, cũng 10 giây | Có giới hạn số bình ở một số nơi |
| Diablo IV | Số **lượt uống** giới hạn (4 → tối đa 10), nạp lại bằng bình rơi từ quái | Hạn chế bằng số lượt, không bằng thời gian hồi dài |
| Path of Exile | Bình **nạp lại khi giết quái** (quái thường 1, hiếm 6, độc nhất 11), hồi máu **dần trong vài giây** | Bình nạp lại khi giết quái |

Điểm chung: các game này không giữ người chơi chờ lâu giữa hai lần uống trong lúc đánh. Họ hạn chế bằng **lượng hồi mỗi lần**, **số lượt** hoặc **nạp lại bằng giao tranh**. Thời gian hồi dài là cách hạn chế duy nhất của game mình, trong khi bình lại mua không giới hạn.

### C.3. Làm

| Bình | Trước | Sau | Vì sao |
| --- | --- | --- | --- |
| Bình máu | 8 giây | **5 giây** | Hồi 35% tức thì vẫn mạnh hơn Lost Ark (30% / 10 giây), nên chỉ rút tới 5 giây để boss không thành "đứng uống thuốc" |
| Bình MP | 8 giây | **3 giây** | MP là nơi người chơi kẹt nhất (mục D); bình MP không cứu mạng nên rút mạnh hơn |

Lượng hồi, giá, nguồn rơi giữ nguyên. Ô bình trên thanh kỹ năng vẫn hiện số giây còn lại. Tự đánh vẫn uống khi HP < 35% / MP < 12%.

## D. Lượng MP (MP-1)

### D.1. Đo

Lấy 7 kỹ năng mở mới nhất theo cấp, không cộng điểm tiềm năng. *Lượt xả / MP* là MP để tung mỗi kỹ năng 1 lần chia cho MP tối đa. *Bù* là hồi MP mỗi giây chia cho MP tiêu mỗi giây khi tung mọi kỹ năng ngay lúc hồi xong.

| Lớp | Cấp | MP (trước) | Lượt xả / MP | Hồi MP | Bù |
| --- | --- | --- | --- | --- | --- |
| Kiếm Khách | 30 / 60 | 98 / 158 | **1,22 / 1,30** | 3,1/giây | 22% / 20% |
| Thợ Săn | 30 / 60 | 130 / 220 | 0,98 / 0,90 | 3,2/giây | 21% / 19% |
| Hộ Vệ | 30 / 60 | 110 / 182 | 1,09 / 1,21 | 3,8 / 4,4 | 26% / 25% |
| Pháp Sư | 30 / 60 | 731 / 1361 | 0,18 / 0,17 | 4,5 / 5,7 | 31% / 36% |
| Triệu Hồi Sư | 30 / 60 | 596 / 1121 | 0,22 / 0,21 | 4,8 / 6,3 | 45% / 44% |

→ Ba lớp vật lý **không đủ MP cho 1 lượt xả** (lượt xả > 1). MP gốc chỉ 25 + 2–3/cấp, INT thấp nên gần như không có MP từ thuộc tính. Hồi MP cố định 3/giây chỉ bù khoảng 20%. Trang bị không có dòng MP. Phản hồi "ra vài chiêu đã hết" là đúng với 3 lớp này. Pháp Sư và Triệu Hồi Sư không thiếu.

### D.2. Các game hiện đại làm thế nào

- **Diablo III / IV**: lớp cận chiến dùng tài nguyên riêng, **tích lại khi đánh thường / bị đánh** rồi tiêu vào chiêu mạnh ("generator / spender"). Lớp phép có kho MP lớn và hồi theo thời gian.
- **Lost Ark và hầu hết ARPG**: hồi MP rất nhanh khi ra khỏi giao tranh, để giữa hai đàn quái không phải đứng chờ.

### D.3. Làm (3 phần) — số đã chỉnh theo TL-B ngày 11/11

| Phần | Số | Áp cho |
| --- | --- | --- |
| MP gốc | 25 → **55**; mỗi cấp Kiếm Khách 2 → **3,5**, Thợ Săn 3 → **4**. Hộ Vệ 25 → **40**, mỗi cấp 2,4 → **3** | Kiếm Khách, Thợ Săn, Hộ Vệ |
| Đánh thường hồi MP | Chỉ **Thợ Săn +1** mỗi lượt đánh trúng (1 lần mỗi lượt, kỹ năng không hồi). Kiếm Khách / Hộ Vệ / lớp phép = 0 từ lớp; ai muốn thì lấy dòng trang bị "MP mỗi đòn đánh" (HR-1, mục G) | Thợ Săn |
| Hồi MP ngoài giao tranh | Không đánh / bị đánh quá 3 giây → hồi MP **×3** | Mọi lớp |

**Vì sao chỉnh (11/11):** số đầu tiên (MP gốc 55 cho cả 3 lớp, đánh thường hồi 4 / 3 / 5) làm TL-B (hạ boss vùng 1, 5 lớp × 20 Thiên phú) **chênh giữa các lớp 30%** (giới hạn 25%): Kiếm Khách 29,5 → 24,3 giây, Thợ Săn 33,0 → 25,0, Hộ Vệ 26,8 → 24,2; Triệu Hồi Sư vẫn 34,5. Chủ dự án chọn "giảm đánh thường hồi MP, đo tới khi ≤ 25%". Các lần đo:

| Thử | Kiếm Khách | Thợ Săn | Hộ Vệ | Chênh lớp |
| --- | --- | --- | --- | --- |
| Đánh thường hồi 4 / 3 / 5, MP 55 | 24,3 | 25,0 | 24,2 | 30% ✗ |
| Hồi 2 / 1,5 / 2,5 | 24,3 | 25,7 | 24,2 | 30% ✗ |
| Hồi 0 / 0 / 0 | 28,5 | 30,3 | 25,0 | 28% ✗ — riêng MP 55 đã đẩy Hộ Vệ (lớp nhanh nhất từ trước) qua ngưỡng |
| Hồi 1 / 1 / 0, Hộ Vệ MP 40 | 25,2 | 27,4 | 26,3 | 27% ✗ — Kiếm Khách rất nhạy với hồi theo đòn |
| **Hồi 0 / 1 / 0, Hộ Vệ MP 40 (chốt)** | **28,5** | **27,4** | **26,3** | **24% ✓** |

Lệch so với hướng chủ dự án chọn (cần duyệt lại khi review): Hộ Vệ MP gốc 40 thay vì 55; đánh thường hồi MP gần như chỉ còn ở Thợ Săn. Phần "hồi MP trong trận" chuyển sang **trang bị** (HR-1: MP khi hạ quái, MP mỗi đòn, Hút MP, +% Hồi MP), để người chơi tự chọn đổi sát thương lấy MP.

Kết quả (cùng cách đo, chưa tính trang bị):

| Lớp | Cấp | MP (trước → sau) | Lượt xả / MP | Hồi trong trận | Bù |
| --- | --- | --- | --- | --- | --- |
| Kiếm Khách | 30 / 60 | 98 → **172** / 158 → **277** | 0,70 / 0,74 | 3,1 /giây | 22% / 20% |
| Thợ Săn | 30 / 60 | 130 → **189** / 220 → **309** | 0,68 / 0,64 | 4,3 / 4,4 | 29% / 27% |
| Hộ Vệ | 30 / 60 | 110 → **142** / 182 → **232** | 0,85 / 0,95 | 3,8 / 4,4 | 26% / 25% |

→ Cả 3 lớp đủ 1 lượt xả chiêu trở lên (trước: thiếu), ngoài giao tranh hồi ×3 nên giữa 2 đàn quái không phải đứng chờ; muốn xả liên tục hơn thì lấy dòng hồi MP trên trang bị. Pháp Sư vẫn có MP gấp đôi Kiếm Khách (SN-T1). Trang Chỉ số → "Hồi MP" hiện "+N/đòn" khi có, rê chuột xem giải thích.

### D.4. Kỹ thuật

- `Stats.CLASS[lớp].mp0 / mpg / mp_hit`; `Stats.derive` trả thêm `mp_hit`; `Stats.MP_OOC_MULT = 3`.
- `GameWorld._hit_enemy`: đòn không thuộc kỹ năng (`Skills2.source == ""`) → +`mp_hit`, mỗi lượt đánh (`player.hits`) chỉ 1 lần (`_mp_hit_tag`).
- Hồi MP mỗi khung × `MP_OOC_MULT` khi `time − _last_combat > OUT_OF_COMBAT` (3 giây, chung mốc với "đang giao tranh").
- `GameWorld.POTION_CD = 5`, `MP_POTION_CD = 3`.
- Không đổi save.

## E. Câu hỏi chờ chủ dự án (đã áp số mặc định)

| Mã | Câu hỏi | Mặc định đã làm |
| --- | --- | --- |
| Q238 | MP gốc 3 lớp vật lý | Kiếm Khách / Thợ Săn 55 + 3,5 / 4 mỗi cấp; **Hộ Vệ 40 + 3** (chỉnh 11/11 theo TL-B, D.3) |
| Q239 | Thời gian hồi bình | Máu 5 giây, MP 3 giây (giữ lượng hồi) |
| Q240 | Hồi MP ngoài giao tranh | ×3 sau 3 giây |
| Q241 | MP mỗi đòn đánh thường | **Chỉ Thợ Săn +1** (chỉnh 11/11 theo TL-B — chủ dự án chọn "giảm đánh thường hồi MP"; số đầu 4 / 3 / 5 làm chênh lớp 30%) |

Có thể làm sau nếu playtest thấy cần: ngọc cho MP, bình hồi dần theo kiểu Path of Exile. (Dòng phụ hồi MP đã làm ở mục G.)

## F. Test

- `--only=MP1`: MP cấp 30 của 3 lớp vật lý ≥ 1,1 × lượt xả 6 kỹ năng; MP mỗi đòn theo lớp (Thợ Săn 1, còn lại 0); chém trúng 3 quái với vũ khí "MP mỗi đòn đánh" → +MP đúng 1 lần; kỹ năng không hồi; ngoài giao tranh hồi ×3; bình máu 5 giây, bình MP 3 giây.
- `--only=HR1`: mục G.
- `--only=TL-B cân bằng`: chênh giữa các lớp 24% (≤ 25%).
- `--only=UI-TL1`: bảng Thiên phú Đạo Tặc + 2 Thiên phú phụ cao ≤ 768 px, cột có cuộn, còn hàng Thiên phú phụ; thẻ đồ có mục NGỌC KHẢM với 3 dòng (2 ngọc + 1 lỗ trống).
- Đổi số cũ: CS-T2 (MP cấp 1: Kiếm Khách 70, Thợ Săn 73, Hộ Vệ 55), SN10-T2 (bình MP hồi theo hằng số).
- Ảnh: `tests/tl_shot.gd --out=<file> [--talent=…] [--size=WxH]`; thẻ đồ / Lò Rèn: `tests/nl1_shot.gd --dir=<thư mục>`.

Nguồn tra cứu: [Lost Ark HP Potion](https://lostark.wiki.fextralife.com:443/HP+Potion), [Lost Ark Major HP Potion](https://lostark.wiki.fextralife.com/Major+HP+Potion), [Diablo 4 healing potions](https://www.gamepressure.com/diablo-iv/how-to-carry-more-healing-potions/zd109ab), [PoE Mana Flask](https://pathofexile.fandom.com/wiki/Mana_Flask), [PoE2 Flask](https://www.poe2wiki.net/wiki/Flask), [Diablo Fury](https://www.diablowiki.net/Fury), [Diablo resource](https://www.diablowiki.net/Resource).

## G. Dòng hồi HP / MP trên trang bị (HR-1) — ✅ đã làm 11/11/2026

> Spec_Notes 10/11: *"Đồ tấn công - Có nên có các dòng như hồi HP/MP không? hãy đề xuất giải pháp theo game hiện đại ngày nay."*
> **Trả lời ngắn:** **Nên có**, nhưng mỗi món tối đa **1 dòng hồi phục**, và dòng đó **chiếm chỗ của 1 dòng sát thương**. Đồ tấn công nhận dòng hồi **theo giao tranh** (khi hạ quái, mỗi đòn đánh). Đồ phòng thủ nhận dòng hồi **theo thời gian** (mỗi giây). ~~Không đưa "hút máu %" vào dòng phụ ngẫu nhiên~~ → chủ dự án chốt **có** dòng Hút HP / Hút MP (Q243), kèm trần (G.7).

### G.1. Rà tổng thể: hiện người chơi hồi HP / MP từ đâu

| Nguồn | Hồi HP | Hồi MP | Mở khi | Ghi chú |
| --- | --- | --- | --- | --- |
| Dòng phụ trang bị (13 dòng) | — | — | — | Chỉ có Tấn công, HP, Phòng thủ, Chí mạng, ST chí mạng, Tốc đánh, Tốc chạy, 5 Kháng hệ. **Không có dòng hồi nào** |
| Ngọc Ngũ Hành (NL-1) | Mộc: +HP tối đa (không hồi) | — | Chương 2 | |
| Đồ bộ (9 bộ) | Chỉ +% HP tối đa | — | | |
| Đồ độc nhất | Sừng Kỳ Lân (5% / 10 giây), Vảy Thất Đầu (1% / giây), Vỏ Lão Thụ (2% / giây khi đứng yên) | — | Rơi từ boss | Hiếm, cố định ô |
| Thức Tỉnh (NL-1) | Hút máu 0,3–1,5% sát thương | — | Sau chuyển chức 3, đồ Tím / Cam +12 | Rất muộn |
| Thiên phú | Hấp Huyết hút 8–12%; Nhà Thảo Dược (kỹ năng L hồi 30–45%) | — | Quay Thiên phú | Chỉ ai có Thiên phú đó |
| Kỹ năng bị động | Ý Chí Sắt 0,2% HP / giây | Minh Tưởng +6% hồi MP | Điểm Kỹ Năng | |
| Kỹ năng | | Thanh Tâm hồi 20% MP | | Theo lớp |
| Cơ chế chung | Bình máu (5 giây), cầu máu rơi | Bình MP (3 giây), hồi gốc 3 + WIS, ×3 ngoài giao tranh, **đánh thường hồi MP** (lớp vật lý, mục D) | | Không có hồi HP gốc theo thời gian |

**Lỗ hổng:** từ cấp 1 tới khoảng cấp 60 (trước Thức Tỉnh) người chơi gần như **chỉ hồi HP bằng bình**, trừ khi quay trúng Hấp Huyết hoặc rơi đúng món độc nhất. Trang bị, thứ người chơi cày nhiều nhất, không cho cách nào để tự chọn lối chơi "trâu, hồi tốt" thay vì "sát thương cao".

### G.2. Các game hiện đại làm thế nào

| Game | Dòng hồi trên trang bị | Cách giữ cân bằng |
| --- | --- | --- |
| Diablo IV | Vũ khí: **+HP khi hạ quái**, **+tài nguyên khi hạ quái**, **+% tạo tài nguyên**; trang sức: **+HP mỗi giây**; dòng "Lucky Hit: có tỉ lệ hồi tài nguyên" | Dòng hồi chiếm chỗ dòng sát thương; giá trị phẳng (không theo sát thương) |
| Path of Exile | **Hút máu / hút MP theo % sát thương** của đòn đánh, chủ yếu đến từ vũ khí / trang bị | Trần tốc độ hồi từ hút: tối đa 20% HP hoặc MP tối đa mỗi giây; phần lớn chỉ áp cho sát thương vật lý của đòn đánh |
| MU Online (dòng Excellent) | **Hồi HP / MP sau khi hạ quái** (theo phần của HP / MP tối đa) | Đồ rơi từ quái tối đa 2 dòng Excellent |

Điểm chung: dòng hồi **theo giao tranh** (khi trúng đòn / hạ quái) nằm trên đồ tấn công. Dòng hồi **theo thời gian** nằm trên đồ phòng thủ / trang sức. Hút máu theo % sát thương thì có **trần** hoặc là phần thưởng hiếm, vì nó tăng theo sát thương: càng mạnh càng hồi nhiều, nên đánh boss gần như bất tử.

### G.3. Đề xuất 5 dòng mới

Giá trị theo công thức dòng phụ hiện có: `(a + b·L) × ngẫu nhiên 0,8–1,2`, L = cấp đồ. Để so sánh, Kiếm Khách cấp 30 có khoảng 850 HP / 170 MP, cấp 60 khoảng 1.600–1.900 HP / 280 MP.

| Mã | Dòng | Ô (đồ tấn công in đậm) | a + b·L | Cấp 30 | Cấp 60 | Tham chiếu |
| --- | --- | --- | --- | --- | --- | --- |
| HR-01 | **Hồi HP khi hạ quái** | **Vũ khí, Găng, Nhẫn** | 4 + 1,2·L | ~40 HP (~4,5%) | ~76 HP (~4%) | Diablo IV "Life on Kill", MU "HP sau khi hạ quái" |
| HR-02 | **Hồi MP khi hạ quái** | **Vũ khí, Găng, Nhẫn**, Dây chuyền | 2 + 0,12·L | ~5,6 MP | ~9 MP | Diablo IV "Resource on Kill" |
| HR-03 | **MP mỗi đòn đánh** | **Vũ khí, Găng** | 1 + 0,03·L | +1,9 / lượt đánh | +2,8 | Cộng vào "đánh thường hồi MP" của mục D (1 lần mỗi lượt); áp cả Pháp Sư / Triệu Hồi Sư |
| HR-04 | Hồi HP mỗi giây | Mũ, Áo, Giày, Bùa | 0,6 + 0,1·L | ~3,6 / giây (~0,4%) | ~6,6 / giây (~0,4%) | Diablo IV "Life per Second" |
| HR-05 | +% Hồi MP | Dây chuyền, Bùa, Mũ | 8% + 0,1%·L | ~11% | ~14% | Nhân với hồi MP mỗi giây (như Minh Tưởng) |

### G.4. Luật cân bằng

| Mã | Luật | Vì sao |
| --- | --- | --- |
| HR-06 | **Mỗi món tối đa 1 dòng hồi phục** (nhóm HR-01…05). Món đã có thì lần quay sau bỏ qua cả nhóm | Diablo IV / MU: dòng hồi chiếm chỗ dòng sát thương → người chơi phải đổi sát thương lấy độ trâu |
| HR-07 | ~~Không thêm "Hút máu %"~~ → **Có** 2 dòng: **Hút HP** (Vũ khí, Găng, Nhẫn; 0,3% + 0,008%·L → cấp 30 ~0,5%, cấp 60 ~0,8%) và **Hút MP** (Vũ khí, Nhẫn; 0,2% + 0,005%·L → ~0,35–0,5%). Trần: hút HP từ trang bị (dòng phụ + Thức Tỉnh) **tối đa 3% HP / giây**, hút MP **tối đa 3% MP / giây**; Thiên phú Hấp Huyết tính riêng | Chủ dự án 11/11: "đồ thì nên có random dòng để hút HP/MP". Trần giữ cho trận boss không thành bất tử (PoE cũng đặt trần) |
| HR-08 | "Khi hạ quái" **không** tính boss, chúa hang, quái hiếm, quái do boss gọi ra | Không biến trận boss thành gọi quái con để hồi máu; dòng này dành cho cày bãi |
| HR-09 | Hồi HP mỗi giây từ dòng phụ: **trần 1% HP tối đa / giây** (cộng mọi món) | Đồ độc nhất (Vảy Thất Đầu 1% / giây) vẫn đáng giá; bình máu vẫn cần trong trận boss |
| HR-10 | Mở theo phẩm chất: dòng hồi chỉ ra trên đồ **Xanh dương trở lên** (≥ 2 dòng phụ) | Đồ Xanh lá có 1 dòng phụ, nếu thành dòng hồi thì mất hết sát thương; đồ đầu game giữ đơn giản |

### G.5. Những chỗ bị ảnh hưởng (rà trước để không sót)

| Chỗ | Việc |
| --- | --- |
| `data/items.gd AFFIXES` | 5 dòng mới + `slots` + cờ `group: "recover"` |
| `core/items.gd` (quay dòng phụ, `item_stats`, `equipment_bonus`) | Luật 1 dòng / món (HR-06), mở từ Xanh dương (HR-10); cộng vào `bonus` |
| `core/stats.gd` / `GameWorld._derive` | Chỉ số mới `hp_regen`, `hp_on_kill`, `mp_on_kill`, `mp_hit` (+ từ đồ), `mp_regen` × (1 + %) |
| `GameWorld` | Hồi HP mỗi giây (có trần HR-09); khi quái chết (không phải boss…, HR-08) cộng HP / MP |
| Lực chiến (`STAT_POWER`) | Đề xuất: HP mỗi giây ×15, HP khi hạ quái ×3, MP khi hạ quái ×4, MP mỗi đòn ×30, % hồi MP ×400 — để dòng hồi có Lực chiến gần dòng Tấn công cùng cấp |
| Tẩy luyện / Thăng phẩm (NL-1, `gear.gd _swap_pool`) | Bể đổi dòng tôn trọng HR-06 (đã có dòng hồi thì không đổi sang dòng hồi khác trừ khi tẩy chính dòng đó) |
| Thẻ đồ, so sánh ▲▼, ô nhặt đồ (`item_card`, `item_tip`, `loot_box`) | Tên dòng tự lấy từ `AFFIXES`; thêm icon cho 5 dòng (dùng lại `stat-hp`, `stat-regen`, không cần vẽ mới) |
| Trang Chỉ số (`stats_page`) | Thêm hàng "Hồi HP" (mỗi giây / khi hạ quái) và gộp MP khi hạ quái / mỗi đòn vào hàng "Hồi MP" |
| Tự động bán / phân rã (CR-04) | Không đổi (lọc theo phẩm chất) |
| Tự đánh (AF-1) | Không đổi |
| Save | Không đổi phiên bản (dòng phụ lưu dạng tên chỉ số); đồ cũ giữ nguyên |
| Test cân bằng (TL-B…) | Thêm dòng vào bể làm thay đổi kết quả xáo trộn → đồ ngẫu nhiên của bot đổi → số TL-B lệch nhẹ. **Cách tránh**: quay dòng hồi ở một bước riêng sau khi đã quay xong các dòng cũ (bể cũ giữ nguyên, kết quả xáo cũ giữ nguyên). Bước này có 25% thay 1 dòng bằng dòng hồi phục |

### G.6. Câu hỏi chờ duyệt

| Mã | Câu hỏi | Đề xuất mặc định |
| --- | --- | --- |
| Mã | Câu hỏi | Chốt 11/11/2026 |
| --- | --- | --- |
| Q242 | Có thêm dòng hồi HP / MP vào trang bị không? | **Có**, 5 dòng HR-01…05 (như đề xuất) |
| Q243 | Có cho "Hút máu %" thành dòng phụ ngẫu nhiên không? | **Có** — chủ dự án đổi: thêm **Hút HP** + **Hút MP** (HR-07, G.7) |
| Q244 | Mỗi món tối đa mấy dòng hồi phục? | **1** (như đề xuất); Hút HP / Hút MP **tính chung nhóm** (G.7) |
| Q245 | "Khi hạ quái" có tính boss / quái do boss gọi ra không? | **Không** (như đề xuất) |
| Q246 | Trần hồi HP mỗi giây từ dòng phụ | **1% HP tối đa / giây** (như đề xuất) |
| Q247 | Dòng hồi ra từ phẩm chất nào, tỉ lệ thay dòng? | **Xanh dương trở lên, 25% mỗi món** (như đề xuất) |

### G.7. Xung đột khi đổi Q243 → "có" (chủ dự án chốt 11/11)

| # | Xung đột | Chốt |
| --- | --- | --- |
| 1 | Thức Tỉnh đã có dòng "Hút máu" 0,3–1,5% (sau chuyển chức 3) | **Giữ cả hai**: dòng phụ yếu hơn (~0,3–0,8% / món), Thức Tỉnh bậc 5 vẫn mạnh nhất; cộng dồn |
| 2 | Lý do không cho hút máu ngẫu nhiên: đánh boss gần như bất tử | **Trần 3% HP / giây** cho hút máu từ trang bị (dòng phụ + Thức Tỉnh); Hấp Huyết không tính vào trần |
| 3 | Hút MP cộng dồn với MP-1 (mục D) + dòng "MP mỗi đòn" | **Ô hẹp** (chỉ Vũ khí, Nhẫn) + **trần 3% MP / giây** |
| 4 | Luật 1 dòng hồi / món | Hút HP / Hút MP **tính chung nhóm hồi phục** (7 dòng, mỗi món 1) |
| 5 | (phát hiện khi chạy test 11/11) MP-1 làm TL-B chênh lớp 30% | Chủ dự án chọn "giảm đánh thường hồi MP" → số chốt ở D.3 (chênh 24%) |

### G.8. Kết quả triển khai (11/11/2026)

- **Dữ liệu** `data/items.gd`: 7 dòng `group: "recover"` (`hp_on_kill`, `mp_on_kill`, `mp_on_hit`, `leech_hp`, `leech_mp`, `hp_regen`, `mp_regen_pct`), `RECOVER_RARITIES`, `RECOVER_CHANCE` 0,25, trần `LEECH_HP_CAP` / `LEECH_MP_CAP` 0,03, `HP_REGEN_CAP` 0,01, `NO_KILL_RECOVER_ROLES`.
- **Sinh đồ** `Items.create`: bể quay thường **loại** nhóm hồi (chuỗi ngẫu nhiên cũ giữ nguyên → TL-B không đổi: vẫn 24%). `Items._roll_recover`: RNG riêng gieo từ chính các dòng vừa quay, đồ Xanh dương+ có 25% thay dòng cuối bằng 1 dòng hồi hợp ô.
- **Tẩy luyện / Thăng phẩm** `Gear._swap_pool`: đã có dòng hồi thì dòng khác không đổi sang dòng hồi; tẩy chính dòng hồi thì được đổi sang dòng hồi khác; đồ dưới Xanh dương không ra dòng hồi.
- **Trận đánh** `GameWorld`: `_derive_gear` chép chỉ số (Hút HP cộng vào `lifesteal` chung với Thức Tỉnh; `mp_on_hit` cộng vào `mp_hit`; `mp_regen_pct` nhân hồi MP); `_update_recover` (ngân sách hút 3% / giây, HP mỗi giây trần 1%); `_kill_recover` (không tính boss, quái hiếm, quái do boss / quái hiếm gọi ra, Chúa Hang, boss Cổng); `_hit_enemy` hút HP / MP theo ngân sách.
- **Lực chiến**: `Items.STAT_POWER` thêm 7 dòng (HP khi hạ quái ×3, MP khi hạ quái ×4, MP mỗi đòn ×30, HP mỗi giây ×15, % hồi MP ×400, Hút HP ×5000, Hút MP ×3000); `cp_extra` cộng phần này.
- **Giao diện**: thẻ đồ (icon `stat-hp` / `stat-regen`, chữ "+0.7% Hút HP", "+40 HP khi hạ quái", "+6 HP mỗi giây"); trang Chỉ số thêm hàng **Hồi HP** (mỗi giây · /quái · hút %), chú thích "Hồi MP" thêm phần trang bị; Túi → Tự động → "Luôn giữ đồ có dòng chỉ số" gộp 7 dòng thành 1 nút **Dòng hồi phục** (lưới giữ 4 hàng).
- **Save**: không đổi phiên bản (dòng phụ lưu theo tên).
- **Test** `--only=HR1` (HR1-T1): 2.000 món — chỉ Xanh dương+, tỉ lệ ~25%, tối đa 1 dòng, đúng ô; luật Tẩy luyện / Thăng phẩm; hạ quái thường +HP / +MP, boss / Chúa Hang không; HP mỗi giây trần 1%; hút HP / MP trần 3%; +% hồi MP; Lực chiến tổng + Lực chiến món; save; chữ trên thẻ đồ.
- **Ảnh**: [design/mp1/hr1-the-do-dong-hoi.png](design/mp1/hr1-the-do-dong-hoi.png), [design/mp1/hr1-tu-dong-giu-dong-hoi.png](design/mp1/hr1-tu-dong-giu-dong-hoi.png).

Nguồn tra cứu mục G: [Diablo 4 weapon affixes (Fextralife)](https://diablo4.wiki.fextralife.com/Weapon+Affixes), [Diablo 4 gear affixes (Mobalytics)](https://mobalytics.gg/diablo-4/guides/gear-affixes-full-list/), [PoE Leech](https://www.poewiki.net/wiki/Leech), [PoE2 Leech](https://www.poe2wiki.net/wiki/Leech), [MU Online Excellent options](https://mudream.online/about/options/excellent).
