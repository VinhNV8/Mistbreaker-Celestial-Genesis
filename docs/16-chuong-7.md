# Đợt M10 — Chương 7: Thiên Không Đảo (vùng 7 Quần Đảo Thiên Không)

| | |
| --- | --- |
| Dự án | Thiên Phú Khai Giới |
| Nguồn | [Kịch bản](kich-ban-game-thien-phu-khai-gioi.md) mục 2 (chương 7: *"Tìm Bia Đá gốc để phong ấn lại — kết chương: Thiên phú tiến hoá lần 2"*), mục 3 (*"Cốt truyện chương 4 và 7 bắt buộc một lần tiến hoá"*), mục 5 (boss Thiên Không Cự Thần: *"Đảo bay vỡ dần, chiến trường thu nhỏ"*), mục 6 (vùng 7: *"Đảo bay, rơi xuống = về điểm lưu — mở: Lãnh địa cấp 5 (xây cảng khí cầu)"*), mục 7 (lãnh địa 5 cấp: Trại → Thôn → Trấn → Thành → Hoàng Thành; Cảng Khí Cầu) · [05](05-thien-phu-chi-tiet.md) mục 3 (dạng tiến hoá bậc 2, *"Nghịch Thiên Cải Mệnh"*) · [06](06-ban-do-quai-boss.md) vùng 7 (quái, boss, môi trường, đồ Cam — **giữ nguyên tên và danh sách**) · [13](13-he-ky-nang.md) (hệ kỹ năng SK1–SK3, Bí Kíp) · [14](14-chuong-6.md) (mồi chương 7, bài học F1–F4) · [15](15-hang-phu.md) (hang phụ) |
| Mục tiêu | Chương 7 chơi trọn từ lúc xây Cảng Khí Cầu tới **tiến hoá Thiên phú lần 2** (điều kiện mở vùng 8) |
| Thứ tự | Sau M9 + SK3 + đợt UI 6–7. Chia M10.1 (lãnh địa cấp 3–5, Cảng Khí Cầu) → M10.2 (vùng, đảo bay, quái) → M10.3 (boss, đồ) → M10.4 (cốt truyện, tiến hoá lần 2) |
| Kiến trúc | Logic trong `core/chapter7.gd`, gắn qua `core/chapters.gd` (`MODULES += [Ch7]`). Đảo / cầu / điểm lưu khai báo trong `data/maps.gd` (`islands`, `bridges`, `anchors`). Vẽ ở `view/region7_view.gd`, hình ở `tools/art/region7.py`. Lãnh địa cấp 3–5 + Cảng Khí Cầu ở `core/explore.gd` (`BUILDINGS`) |
| Phân công | Spec: phiên này. Code M10: **phiên game-39** (đã thống nhất 22/10/2026) |
| Quy trình | Spec (file này) → duyệt → code → test → cập nhật 01/02/03/04/06/07 và mục Kết quả |
| Trạng thái | ✅ **Xong 27/10/2026** (phiên game-39). Q76–Q82 dùng mặc định đề xuất (chủ dự án: "tiếp tục triển khai"). Kết quả: mục 10 |

Ký hiệu: ✅ xong · 🟡 một phần · ⬜ chưa làm.

## 0. Bám kịch bản và các điều chỉnh mới

| Nguồn | Áp vào chương 7 |
| --- | --- |
| Kịch bản chương 7 | Mục tiêu cốt truyện là **Bia Đá gốc** (mồi từ C6-44); kết chương **tiến hoá lần 2 bắt buộc** (bước 7) |
| Kịch bản mục 6 | Mở vùng 7 bằng **lãnh địa cấp 5 + Cảng Khí Cầu** (Q75 đã dời sang đây) → M10.1 phải làm KP-13 (Trấn → Thành → Hoàng Thành) và KP-18 |
| Kịch bản boss | *"Đảo bay vỡ dần, chiến trường thu nhỏ"* = GĐ2 của Cự Thần |
| MP-09 / D45 (cổng dịch chuyển) | Không chọn nơi đến trên bảng lục địa: cổng "next" ở 6-3 thành **Bến Khí Cầu** (vẽ khác, cùng hệ cổng) — chỉ mở khi đủ điều kiện C7-01 |
| HP-01…10 (hang phụ) | 3 map mới tự có cửa hang (D46): tên **Hang Mây Ẩn**; hang nằm trên đảo chính, logic đảo bay **không** áp trong hang (HP-10) |
| SK1–SK3 (kỹ năng) | Boss vùng rơi Bí Kíp tầng II 40%, boss hiếm tầng III 100%, Chúa Hang 25% — **tự áp**, không viết thêm. Bot cân bằng dùng **bộ kỹ năng mặc định theo cấp** (có tối thượng + 2 kỹ năng nhánh chức 2) |
| CB-30 (quái áp sát nhanh) | Áp cho quái vùng 7. Đại Bàng Mây (Nhanh) + quạt đẩy lùi là áp lực chính với lớp đánh xa |
| UI-15 (bảng tên quái) | Quái mới dùng bảng tên có sẵn; Kỳ Lân Mây hiện "Hiếm" (tím) |
| UI-16 (khung nhiệm vụ gọn) | Mỗi bước nhiệm vụ: **mục tiêu ≤ 30 ký tự**, **gợi ý ≤ 40 ký tự**, không ghi phím tắt (phím ở bảng F1) |
| UI-17 (Trợ giúp F1) | Thêm 1 mẹo: *"Đảo bay: rơi khỏi mép về Đá Neo gần nhất, mất 10% HP. Lông Vũ Gió (Q) giúp lướt qua khe."* |
| D41, F1–F4 chương 6 | Cửa sổ đánh boss mở **theo lượng sát thương**, không theo đồng hồ; mọi hình phạt theo đòn có **hồi chung**; bot test phải né vòng/vệt báo và tránh mép đảo |

## 1. Lãnh địa cấp 3–5 và Cảng Khí Cầu (M10.1)

Hiện có: Trại (cấp 1) → Thôn (cấp 2, `camp2`). Kịch bản mục 7: *"Trại Khai Giới → Thôn → Trấn → Thành → Hoàng Thành (5 cấp, nâng bằng gỗ, đá, sắt, tinh thạch)"*.

| Mã | Yêu cầu | Tiêu chí |
| --- | --- | --- |
| C7-01 | **Điều kiện mở vùng 7** (kịch bản mục 6): **lãnh địa cấp 5 (Hoàng Thành) + đã xây Cảng Khí Cầu** + **hạ Bản Ngã Bóng Tối** + **cấp ≥ 71**. Cổng Bến Khí Cầu ở 6-3 và bảng Cổng Dịch Chuyển hiện điều kiện còn thiếu (một dòng mỗi điều kiện) | C7-T1 |
| C7-02 | **Nâng trung tâm lãnh địa** (KP-13) — bảng dưới. Nâng ở Trại Khai Giới (bảng Lãnh địa, nút "Nâng"), cần đủ **số ô đã chiếm** (cộng mọi vùng) + tài nguyên, xây theo thời gian như công trình (Trái Tim Lãnh Chúa ×0,75, Chiếu Chỉ hoàn thành ngay). Mỗi cấp **+10% sản lượng** lãnh địa (thay +20% cố định của Thôn: Thôn +20%, Trấn +30%, Thành +40%, Hoàng Thành +50%) | C7-T1 |
| C7-03 | Trung tâm vẽ theo cấp (5 hình: lều → nhà gỗ → tường gỗ → tường đá → cung điện) ở bảng Lãnh địa và ở vùng an toàn làng Thanh Thạch (1-1). Tên cấp hiện ở bảng Lãnh địa: *"Hoàng Thành · cấp 5"* | Smoke `17b-territory5` |
| C7-04 | **Cảng Khí Cầu** (KP-18): công trình mới, chỉ xây khi trung tâm **cấp 5**; giá 5.000 vàng · 400 Gỗ · 300 Sắt · 60 Tinh Thạch, 20 phút. Xây xong: báo *"Cảng Khí Cầu hoàn thành — khí cầu đợi ở Đỉnh Cực Quang"*, cổng Bến Khí Cầu ở 6-3 sáng lên | C7-T1 |

**C7-02 — giá nâng trung tâm** (số liệu tạm, chỉnh theo PACE-T4):

| Cấp | Tên | Ô đã chiếm (mọi vùng) | Vàng | Gỗ | Đá | Sắt | Tinh Thạch | Thời gian |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 2 | Thôn (có sẵn) | — | 100 | 100 | — | — | — | 3 phút |
| 3 | Trấn | 40 | 2.000 | 400 | 300 | 150 | — | 10 phút |
| 4 | Thành | 80 | 6.000 | 800 | 600 | 400 | 40 | 20 phút |
| 5 | Hoàng Thành | 120 | 15.000 | 1.200 | 1.000 | 700 | 100 | 40 phút |

Căn cứ: một người chơi tới cấp 70 thường đã chiếm 150–200 ô (vùng 1–6, 265 ô) và có ≥ 6 Xưởng Gỗ, ≥ 6 Mỏ, ≥ 3 Mỏ Tinh Thạch → Gỗ ≈ 36/phút, Đá ≈ 24/phút, Sắt ≈ 12/phút, Tinh Thạch ≈ 3/phút (`Explore.production_per_minute`) + thu hoạch offline 12 giờ. Cả 3 cấp + Cảng ≈ 4–6 giờ sản xuất — đúng một phiên cày vùng 6 bình thường. Người bỏ lãnh địa sẽ bị chặn ở đây: chủ ý của kịch bản (*"tài nguyên lãnh địa quay lại nuôi nhân vật"*), có nhắc từ bước 1 chương 7 (mục 5).

## 2. Vùng 7 (M10.2)

| Mã | Yêu cầu | Tiêu chí |
| --- | --- | --- |
| C7-05 | 3 map 4.480 × 2.560, sương che (SN-31): **7-1 Đảo Mây Trôi** (cấp 72–76, trạm *Bến Mây* — 3 NPC), **7-2 Đảo Rừng Treo** (76–80, trạm *Tổ Hạc Cổ*, 3 **Trụ Gió**), **7-3 Thiên Cung Đổ Nát** (80–84, trạm *Thiên Môn Đài*, hang *Đài Cự Thần* cấp 82, boss hiếm Kỳ Lân Mây). Đi 7-1 → 7-2 → 7-3. Tới 7-1 lần đầu bằng **Bến Khí Cầu** (6-3 → 7-1, đi đường 4 giây có cảnh khí cầu bay ngang mây) | C7-T1; smoke `17-region7` |
| C7-06 | Lưới khai phá vùng 7: 45 ô (bảng sự kiện vùng 2–6). Tài nguyên (06): **Rừng treo → Xưởng Gỗ**, Mỏ của vùng 7 là **Mỏ Tinh Thạch** (`mine_r7_*`) | C7-T6 |
| C7-07 | Hang phụ (HP-02): **Hang Mây Ẩn** ở cả 3 map, cửa hang đặt trên **đảo chính** (nếu điểm mặc định `size × (0,5; 0,82)` rơi vào khoảng trời thì dời về điểm đất gần nhất). Trong hang không có khoảng trời | C7-T1 |

## 3. Môi trường đảo bay (M10.2)

| Mã | Yêu cầu | Tiêu chí |
| --- | --- | --- |
| C7-10 | **Đảo bay** (kịch bản: *"Đảo bay, rơi xuống = về điểm lưu"*): mỗi map gồm **đảo** (đa giác/vòng tròn khai báo trong `maps.gd` `islands`) nằm giữa **khoảng trời** (nền mây trôi, không đi được). Đảo chính chứa trạm + vùng an toàn; 6–10 đảo phụ. Quái **không bước ra khoảng trời** (như tránh dung nham, hook `enemy_avoid`) | C7-T2 |
| C7-11 | **Rơi khỏi mép**: tâm nhân vật ra khỏi mọi đảo/cầu **0,25 giây** (cho phép lướt qua khe nhỏ khi né lăn, lao Đột Kích, Dịch Chuyển: chỉ xét **điểm dừng**) → cảnh rơi 1 giây (nhân vật nhỏ dần, mây vụt lên) → hiện ở **Đá Neo** đã chạm gần nhất, **mất 10% HP tối đa** (06; bỏ qua Phòng thủ, không gục dưới 1 HP), bất tử 1,5 giây. Không mất đồ, không tính là chết | C7-T2 |
| C7-12 | **Đá Neo** (điểm lưu): trạm + 3–5 Đá Neo mỗi map (cột đá có dây xích, sáng xanh khi đã chạm). Chạm (đi qua trong 4 m) để lưu. Đá Neo mặc định = trạm của map | C7-T2 |
| C7-13 | **Cầu gió** (06): cầu nối các đảo (`bridges`, rộng 6 m), **tắt 5 giây sau mỗi 30 giây** (chu kỳ riêng từng cầu, lệch nhau). **Báo trước 2 giây**: cầu nhấp nháy + kêu gió. Đứng trên cầu khi tắt = rơi (C7-11). HUD dòng môi trường khi đứng trên cầu: *"Cầu gió tắt sau 0:04"* | C7-T2 |
| C7-14 | **Đảo vỡ** (06, chỉ 7-3): **đảo vụn** (bán kính 6–10 m, 6–8 cái) sụp mép **1 m mỗi 10 giây** khi có người chơi đứng trên, tới hết thì rơi; **mọc lại sau 60 giây**. Đảo chính và đảo có trạm/Đá Neo không vỡ | C7-T2 |
| C7-15 | **Lông Vũ Gió** (vật phẩm mới, cửa hàng Phong Linh 120 vàng): phím **Q** → **2 giây lơ lửng**: không rơi khi ra khỏi mép, tốc chạy +20% (dùng thay bình máu, như Than Hồng C6-13). HUD: *"Q: Lông Vũ Gió (3)"* | C7-T2 |
| C7-16 | **Đẩy lùi về mép**: đòn đẩy lùi của quái (Quạt cánh) **có thể đẩy rơi** — chủ ý của vùng. Bộ Thiên Phong 2 món miễn đẩy lùi (C7-35). Khiên / bất tử khi né vẫn chặn đẩy lùi như hiện tại | C7-T3 |

## 4. Quái vùng 7 (M10.2)

Chỉ số từ `Formulas.mob_stats` (06 vùng 7). **Giữ nguyên tên và danh sách 06** (phiên game-39 đang vẽ hình theo danh sách này).

| Mã | Quái | Loại · hệ | Kỹ năng | Tiêu chí |
| --- | --- | --- | --- | --- |
| C7-20 | **Đại Bàng Mây** | Nhanh · Kim | Bay sà xuống; **Quạt cánh** (vung 0,6 s, hồi 6 s, nón 60° 6 m): ×0,8 + **đẩy lùi 5 m** theo hướng từ đại bàng tới người chơi (06: *"thường về phía mép đảo"* — đại bàng ưu tiên đứng **phía trong đảo** so với người chơi trước khi quạt) | C7-T3 |
| C7-21 | **Người Gỗ Đảo Bay** | Giáp · Mộc | **Rễ quật** (vung 1,0 s, hồi 8 s): vòng 5 m quanh mình ×1,3, vòng báo | C7-T3 |
| C7-22 | **Tiên Gió** | Phép · Mộc | Đánh xa 18 m (Phong nhận ×1,0). **Hồi phục**: mỗi 2 giây hồi **5% HP** cho đồng bọn trong 10 m (không tự hồi, vòng xanh lá nhấp nháy) — nên hạ trước | C7-T3 |
| C7-23 | **Hiệp Sĩ Thiên Không** | Lì · Kim | **Thương phá** (vung 0,8 s, hồi 7 s): đâm xuyên thẳng 15 m rộng 1,5 m ×1,6 (vệt báo), không đẩy lùi | C7-T3 |
| C7-24 | Tinh anh **Thủ Hộ Đảo** (của Người Gỗ, từ cấp 75) | Giáp · Kim | **Khiên trời** (hồi 18 s): đồng bọn trong 10 m **bất tử 4 giây** (vòm vàng; bản thân không bất tử). Theo F2 (chương 6): khiên **không phản đòn** | C7-T3 |
| C7-25 | Tinh anh **Rồng Mây** (của Đại Bàng, từ cấp 78) | Nhanh · Mộc | Bay vòng quanh người chơi bán kính 12 m (đánh được khi bay); **Lao mây** (hồi 8 s, vung 0,7 s): lao thẳng 18 m ×2,0 (vệt báo), đẩy lùi 3 m | C7-T3 |

## 5. Boss và đồ (M10.3)

| Mã | Yêu cầu | Tiêu chí |
| --- | --- | --- |
| C7-30 | **Thiên Không Cự Thần** (boss chương 7, cấp 82, Kim, 130 đòn — Q23; 110.081 HP theo 06) ở hang *Đài Cự Thần*: đấu trường là **một đảo tròn bán kính 30 m** giữa trời: **lõi** (0–22 m, không bao giờ vỡ) + **vành ngoài** (22–30 m) chia **4 cung** (mỗi cung 1/4 vòng). Hình: người khổng lồ đá mây, giáp đồng, mắt xanh (hộ vệ Bia Đá gốc, bị Hư Vô Giáo khắc ấn làm điên). **GĐ1 (100 → 60%)**: **Đấm đất** (vung 1,0 s, hồi 7 s): vòng 8 m tại chỗ người chơi ×2,0, nền vòng đó **vỡ 10 giây** (thành khoảng trời — đứng vào là rơi) · **Mưa đá** (hồi 10 s): 10 vòng 3 m quanh người chơi trong 14 m, báo 1,2 s, ×1,0 · đòn thường Đập ×1,0 | C7-T4; TL-B7 |
| C7-30b | **GĐ2 (60 → 20%) — Đảo vỡ dần, chiến trường thu nhỏ** (kịch bản): **một cung vành ngoài vỡ sau mỗi lần Cự Thần mất 10% HP tối đa hoặc 20 giây**, cái nào tới trước (D41 — lượng sát thương là chính, đồng hồ chỉ để người sát thương thấp không đứng mãi ở vành ngoài) → hết GĐ2 còn đúng lõi 22 m. Báo trước 3 giây (cung nứt đỏ, đá vụn rơi). Cung vỡ chọn **cung người chơi đang đứng gần nhất** (ép người chơi vào giữa). Rơi khỏi mép → về **Đá Neo cửa hang** (cạnh đấu trường), mất 10% HP, **Cự Thần hồi 5% HP** (06). Đấm đất + Mưa đá tiếp tục; trong lõi, Đấm đất chỉ **nứt hình** (không thành khoảng trời) | C7-T4 |
| C7-30c | **GĐ3 (dưới 20%) — Thiên chuỳ** (06): Cự Thần đứng yên nện **3 lần liên tiếp**, mỗi lần vòng **12 m quanh Cự Thần** ×3,0, **vung 1,2 s mỗi lần** (vòng báo đỏ đậm), hồi 14 s. Lõi 22 m đủ chỗ chạy ra ngoài 12 m (tốc chạy 230 → 1,2 s đi được 27 m); cận chiến có 0,6 giây giữa các lần nện để đánh rồi lùi. Thêm Mưa đá mỗi 8 giây | C7-T4 |
| C7-30d | **Khắc chế rơi oan**: Cự Thần **không đẩy lùi** (06 không ghi đẩy lùi; đẩy lùi + mép = chết oan với lớp cận chiến). Đấu trường không có cầu gió | C7-T4 |
| C7-31 | Cự Thần rơi: 1 đồ Tím · 15% **Búa Cự Thần** (vũ khí Cam: **đòn thứ 3** tạo sóng chấn vòng 6 m ×0,8 — với Thợ Săn/Pháp Sư: phát bắn thứ 3 nổ sóng chấn tại chỗ trúng) · 3 Tinh Hoa · 1 Tinh Kim · **12 Tinh Thạch** · 40% Bí Kíp tầng II (SK3). Hồi sinh 10 phút | C7-T4 |
| C7-32 | **Đạo Tặc — Thiên Chuỳ** (06; sao chép khi hạ Cự Thần lần đầu): nện đất vòng 10 m ×3,0, **choáng 1 giây** (boss/tinh anh: gấp đôi vào Phá Thế thay cho choáng) | C7-T4 |
| C7-33 | **Boss hiếm Kỳ Lân Mây** ở 7-3 (cấp 84, Nhanh, Mộc, 200 đòn; 183.097 HP theo 06; `RARE_BOSSES["7-3"]`; xuất hiện sau khi hạ Cự Thần). **Chạy vòng** quanh đảo của nó (bán kính 20 m, 3 giây một vòng), để lại **vệt sấm** 3 giây (×0,4 mỗi giây khi đứng lên); khi chạy **không nhận sát thương** (miss). **Dừng lại** giữa các vòng: tới khi **mất 12% HP tối đa hoặc 6 giây** (D41 — không phải 3 giây cố định của 06); khi dừng dùng **Sấm sét** (5 vòng 4 m quanh người chơi, báo 1,0 s, ×1,5) rồi Húc ×1,2 | C7-T4 |
| C7-34 | Kỳ Lân rơi: **Sừng Kỳ Lân** (dây chuyền Cam: +20% hiệu lực hồi máu; **mỗi 10 giây hồi 5% HP**) · 1 Tinh Hoa Tiến Hoá · 5 Tinh Hoa · Bí Kíp tầng III (SK3, 100%) | C7-T4 |
| C7-35 | **Bộ Thiên Phong** (đồ Tím vùng 7, 06): 2 — **không bị đẩy lùi** · 4 — **+10% tốc đánh** · 6 — **rơi khỏi mép không mất HP** (hồi 60 giây; vẫn về Đá Neo) | C7-T4 |

## 6. Cốt truyện và tiến hoá lần 2 (M10.4)

| Mã | Yêu cầu | Tiêu chí |
| --- | --- | --- |
| C7-40 | **NPC Bến Mây** (7-1): *Vân Hạc* (lão đạo nhân giữ Thiên Cung — người cuối cùng của **Thánh Đường cổ** đời đầu, người dẫn truyện; **tiến hoá lần 2**) · *Phong Linh* (thuyền trưởng khí cầu của Liên minh — **cửa hàng** Lông Vũ Gió, bình máu) · *Tuyết Nga* (theo nhân vật từ Băng Nguyên, giữ bản dập Bia Băng). *Lam Nhi* ở lại Trạm Tuyết Bạc (chỉ nói 1 câu tiễn) | Smoke `17c-camp7` |
| C7-41 | **Nhiệm vụ chương 7 — 7 bước** (mục tiêu / gợi ý theo UI-16): (0, mở trước khi có vùng 7, hiện ở khung nhiệm vụ sau C6-44) **"Dựng Cảng Khí Cầu"** — *"Nâng lãnh địa lên Hoàng Thành"* (đếm cấp trung tâm + Cảng) · (1) **Lên đảo**: tới Bến Mây gặp Vân Hạc · (2) **Bầy chim dữ**: hạ 30 quái vùng 7 · (3) **Nối cầu gió**: tới Đảo Rừng Treo, đứng cạnh **3 Trụ Gió** 2 giây để kích (Trụ Gió đã kích làm cầu gió gần nó **không tắt nữa** — giảm khó cho người quay lại) · (4) **Neo Hư Vô**: tới Thiên Cung Đổ Nát, phá **3 Neo Hư Vô** (vật thể có thanh máu = 20 × cấp, mỗi neo có 4 quái + 1 tinh anh canh) — Hư Vô Giáo đang kéo Thiên Cung rơi xuống · (5) khám phá 7-3 ≥ 40% (tìm Đài Cự Thần) · (6) hạ **Thiên Không Cự Thần** · (7) **Nghịch Thiên Cải Mệnh**: chạm Bia Đá gốc ở Đài Cự Thần → **tiến hoá Thiên phú lần 2** (C7-43). Thưởng EXP ≈ 25% EXP cấp 72 → 84 (19,65 triệu × 25% ≈ **4,91 triệu**), chia tăng dần theo bước | C7-T5 |
| C7-42 | **Kết chương 7** (kịch bản: *"Tìm Bia Đá gốc để phong ấn lại"*): hạ Cự Thần → ấn Hư Vô trên trán nó vỡ, Cự Thần tỉnh lại và quỳ trước Bia Đá gốc rồi hoá đá. Bia Đá gốc nói qua Vân Hạc: **chỉ phong ấn lại được ở chính Cổng Thiên Đạo**, và phải mang **Thiên phú đã tiến hoá hai lần** mới chịu được sức hút của mảnh thứ hai → nghi thức Nghịch Thiên Cải Mệnh (bước 7). Sau tiến hoá, Bia Đá gốc **nứt một mảnh**: bóng **Giáo Chủ Hư Vô** hiện ra, lấy mảnh vỡ và rút về **Vực Hư Vô** — Hư Vô Giáo dùng mảnh Bia để mở Cổng Thiên Đạo cho Ma Tôn (mồi chương 8). Màn kết chương | Smoke `18-chapter7-end` |
| C7-43 | **Tiến hoá Thiên phú lần 2** (TP-12; kịch bản mục 3 *"chương 4 và 7 bắt buộc một lần tiến hoá"*; 05 mục 3 bậc 2): điều kiện **đã tiến hoá 1 lần + Thiên phú Lv10 + 1 Tinh Hoa Tiến Hoá + bước 7**. Tiến hoá: đổi tên + hạng theo cột **bậc 2** bảng 05 mục 3, Lv1, hoàn 50% Tinh Hoa đã luyện (như C4-43), **cấp hiệu dụng = Lv + 9 × 2** (D39 — không tụt sức mạnh). Nghi thức ở Bia Đá gốc (bảng Thiên phú mở sẵn nút Tiến hoá). Sau đó đổi được ở Vân Hạc | C7-T7 |
| C7-44 | **Thiên phú không còn bậc 2** (05: SS → SSS chỉ 1 bậc — Thiên Mệnh Khai Giới, Long Mạch; và dạng đã ở SSS): tiến hoá lần 2 thành **Đột Phá** — giữ tên, thêm hậu tố *"· Đột Phá"*, hạng giữ nguyên, **vẫn tính 1 lần tiến hoá** (cấp hiệu dụng +9, hoàn Tinh Hoa) để không ai thiệt vì quay trúng hạng cao (Q78). **Đạo Tặc** coi như đạt (như C5-01) | C7-T7 |
| C7-45 | **Nhiệm vụ "Nghịch Thiên Cải Mệnh"** của SS (05 mục 3): chính là bước 7 — không cần nhiệm vụ riêng. Chuỗi "Phế Vật Nghịch Thiên" của F, "Thử Luyện Tinh Quang", "Vấn Đạo" **chưa làm** (vẫn dùng điều kiện chung như C4-43) | — |
| C7-46 | Giao diện: hào quang tiến hoá bậc 2 (màu hạng mới), tên dạng bậc 2 ở khung nhân vật (UI-08g một dòng), bảng Thiên phú hiện "Tiến hoá 2/2" | Smoke `18b-talent-evo2` |

## 7. Thay đổi save (version 16 → 17)

Số version: SK3 = v16, **M10 = v17** (phiên game-c6 giữ v18 cho đợt của họ).

| Trường | Kiểu | Mặc định save cũ |
| --- | --- | --- |
| `camp_level` | int 1–5 (có sẵn, trước chỉ tới 2) | giữ nguyên |
| `buildings["camp3"…"camp5"]`, `buildings["port"]` | như công trình có sẵn | không có |
| `quest.ch7`, `quest.kills7`, `quest.pillars7`, `quest.anchors7` | int, int, Array[int] (Trụ Gió đã kích), Array[int] (Neo Hư Vô đã phá) | 0, 0, [], [] |
| `feathers` (Lông Vũ Gió) | int | 0 |
| `anchor_stones` | Dictionary map id → Array[int] (Đá Neo đã chạm) | {} |

`evo` (số lần tiến hoá) dùng lại trường có sẵn (giờ tới 2). Cầu gió, đảo vụn, trạng thái rơi là trạng thái trong trận (không lưu).

## 8. Kiểm thử

| Mã | Kiểm |
| --- | --- |
| C7-T1 | Nâng Trấn / Thành / Hoàng Thành (đủ ô + tài nguyên, thời gian, Trái Tim Lãnh Chúa), sản lượng +10%/cấp; Cảng Khí Cầu chỉ xây ở cấp 5; điều kiện mở vùng 7 (thiếu Cảng / Bản Ngã / cấp → Bến Khí Cầu báo lý do); 3 map đúng cấp/kích thước, đi 7-1 → 7-3; cửa Hang Mây Ẩn nằm trên đất |
| C7-T2 | Rơi khỏi mép (0,25 giây, về Đá Neo gần nhất, −10% HP, không gục, bất tử 1,5 giây); né lăn qua khe không rơi; Đá Neo lưu; cầu gió tắt 5/30 giây có báo; đảo vụn sụp 1 m/10 giây và mọc lại; Lông Vũ Gió 2 giây; quái không ra khoảng trời; trong hang không có mép |
| C7-T3 | Quạt cánh đẩy lùi 5 m (rơi được), Bộ Thiên Phong 2 miễn; Rễ quật; Tiên Gió hồi 5%/2 giây cho đồng bọn; Thương phá; Khiên trời bất tử 4 giây; Rồng Mây bay vòng + Lao mây |
| C7-T4 | Cự Thần 3 giai đoạn: Đấm đất làm vỡ nền 10 giây (GĐ1), 4 cung vành ngoài vỡ theo 10% HP hoặc 20 giây (cung gần người chơi), lõi 22 m không vỡ, rơi → boss +5% HP; Thiên chuỳ 3 lần; không đẩy lùi. Búa Cự Thần (cả bản bắn xa); Thiên Chuỳ (Đạo Tặc); Kỳ Lân: chạy thì miss, dừng tới 12% HP / 6 giây, vệt sấm; Sừng Kỳ Lân; Bộ Thiên Phong 2/4/6; Bí Kíp rơi đúng tầng |
| C7-T5 | Nhiệm vụ chương 7 bước 0–7; thưởng EXP ≈ 4,91 triệu; Trụ Gió giữ cầu; Neo Hư Vô |
| C7-T6 | Lưới vùng 7 45 ô, Xưởng Gỗ + Mỏ Tinh Thạch (`mine_r7_*` cho Tinh Thạch) |
| C7-T7 | Tiến hoá lần 2: điều kiện, tên/hạng bậc 2 theo 05, cấp hiệu dụng Lv + 18, hoàn Tinh Hoa; Đột Phá cho Thiên phú hết bậc; Đạo Tặc coi như đạt; save v17 + chuyển đổi v16 |
| TL-B7 | 3 lớp × 20 Thiên phú (chức 2 — 2 nhánh luân phiên theo seed, **bộ kỹ năng mặc định cấp 81** gồm tối thượng + 2 kỹ năng nhánh) hạ Cự Thần (bot cấp 81, bộ đồ chuẩn cấp 81, tiến hoá 1 lần Lv10): F/S ≤ 25%, các lớp ≤ 25%, **0 lần chết**, số lần rơi in ra (mục tiêu ≤ 1/trận). Bot: né vòng/vệt báo, **đứng trên nền còn nguyên**, không đứng ở cung sắp vỡ, ra ngoài 12 m khi Thiên chuỳ |
| PACE-T4 | (chạy riêng `--only=PACE`) giả lập sản lượng lãnh địa của người chơi cấp 70 tiêu chuẩn: in số giờ để đủ Hoàng Thành + Cảng (mục tiêu 4–6 giờ gồm offline) |

Smoke mới: `17-region7`, `17b-territory5`, `17c-camp7`, `17d-cu-than`, `18-chapter7-end`, `18b-talent-evo2`.

## 9. Điểm cần duyệt

| # | Câu hỏi | Mặc định đề xuất |
| --- | --- | --- |
| Q76 | "Lãnh địa cấp 5" (kịch bản) = Hoàng Thành? 06 (Q26) lại ghi Lõi Hư Vô (rơi ở chương 8) dùng để nâng Hoàng Thành — mâu thuẫn | **Theo kịch bản**: Hoàng Thành nâng ở chương 7 bằng Gỗ/Đá/Sắt/Tinh Thạch. **Lõi Hư Vô** đổi công dụng: vật phẩm cho **chuyển chức 3** (spec chương 8, C8-45). Sửa 06 khi duyệt |
| Q77 | Giá nâng Trấn / Thành / Hoàng Thành (mục 1) có quá nặng với người ít làm lãnh địa? | Giữ (4–6 giờ sản xuất). Thêm gợi ý ở bước 0 + PACE-T4. Nếu playtest thấy kẹt: hạ yêu cầu số ô (40/80/120 → 30/60/90) trước, không hạ tài nguyên |
| Q78 | Thiên phú SS (chỉ còn 1 bậc) và SSS tiến hoá lần 2 thế nào? | **Đột Phá** (C7-44): giữ tên + hạng, +9 cấp hiệu dụng — công bằng với F/C/B/A/S có bậc 2 |
| Q79 | Rơi khỏi mép −10% HP có làm Thợ Săn/Pháp Sư (bị Đại Bàng đẩy) chịu thiệt? | Chủ ý tạo khó cho lớp thả diều (khớp CB-30); bù bằng Bộ Thiên Phong 2, Lông Vũ Gió, và đại bàng **báo trước 0,6 giây** để né |
| Q80 | Kỳ Lân Mây "chỉ đánh được khi nó dừng 3 giây" (06) | Dừng **tới khi mất 12% HP hoặc 6 giây** (D41) — 3 giây cố định làm lớp sát thương thấp mất 2–3 lần thời gian |
| Q81 | Thiên Cung có bao nhiêu "Bia Đá gốc"? Người chơi có quay lại được không? | 1 Bia ở Đài Cự Thần, sau chương thành nơi đổi tiến hoá (như Tinh Quang Sứ) và mở Cổng Dịch Chuyển ngay trong hang |
| Q82 | Hộ Vệ (lớp thứ 4 trong kịch bản) có cần cho chương 7–9? | **Không** — các chương cân bằng cho 3 lớp hiện có; Hộ Vệ là đợt riêng (cần 12 kỹ năng + 2 nhánh chức 2 + chức 3) |

## 10. Kết quả

✅ Xong 27/10/2026. Test: C7-T1…T7 ✅, **TL-B7 ✅** (3 lớp × 20 Thiên phú × 2 seed: các lớp chênh **19%**, F/S trong lớp ≤ 9%, **0 lần chết**, rơi 0,00 lần/trận). Smoke: `17-region7`, `17b-territory5`, `17c-camp7`, `17d-cu-than`, `18-chapter7-end`, `18b-talent-evo2`.

| Hạng mục | File |
| --- | --- |
| Lãnh địa Trấn / Thành / Hoàng Thành, Cảng Khí Cầu (giá trong `BUILDINGS`, `build_blocker`, `total_owned`, `camp_name`, sản lượng theo `CAMP_BONUS`) | `core/explore.gd`, `ui/map_panel.gd` |
| 3 map đảo bay (`islands`, `bridges`, `anchors`, `pillars`, `void_anchors`, `crumble`, `solid`) | `data/maps.gd` |
| Logic chương 7 (đảo bay, rơi, cầu gió, đảo vụn, Lông Vũ Gió, quái, Cự Thần, Kỳ Lân, đồ, nhiệm vụ, tiến hoá lần 2) | `core/chapter7.gd` (gắn `chapters.gd`) |
| Vẽ trời mây, đảo, cầu, Đá Neo, Trụ Gió, đấu trường, vòng báo, rơi | `view/region7_view.gd` |
| Hình (AR-62): quái, tinh anh, Cự Thần (builder `colossus`), Kỳ Lân, Neo Hư Vô (`void_pylon`), NPC Vân Hạc / Phong Linh, Đá Neo, Trụ Gió, Bia Đá gốc, 5 trung tâm lãnh địa, nền trời / cẩm thạch / cầu gió, icon Búa Cự Thần / Sừng Kỳ Lân / Lông Vũ Gió | `tools/art/region7.py` |
| Nhiệm vụ + thoại | `data/story.gd` (`QUESTS7`, `DONE7 = 9`) |
| Bảng Thiên phú "Tiến hoá 2/2", tên dạng bậc 2 / Đột Phá ở khung nhân vật | `ui/talent_panel.gd`, `ui/hud.gd` |
| Save v17 | `core/profile.gd` |

**Chỗ lệch so với spec (ghi lại để duyệt):**

| # | Spec | Đã làm | Lý do |
| --- | --- | --- | --- |
| L1 | Cự Thần 3 giai đoạn, không có chuyển cảnh | Thêm **chuyển cảnh 4 giây** ở 60% và 20% ("ấn Hư Vô rạn"): Cự Thần không nhận và không gây sát thương | Đo TL-B7: trận chỉ 12–22 giây, chênh lệch sát thương gốc giữa 3 lớp lộ hết (30–32%, vượt 25%); tắt Mưa đá / Đấm đất / cho boss đứng yên không đổi kết quả. Chuyển cảnh thời lượng cố định cộng như nhau cho mọi lớp (cách chương 6 làm) → 19%. Bộ đếm chuyển cảnh chạy theo đồng hồ thật và Cự Thần không bị choáng trong lúc chuyển cảnh (nếu không, lớp hay Phá Thế như Hộ Vệ bị kéo dài chuyển cảnh 13–18 giây). Đo thử với 5 lớp (có Hộ Vệ, Triệu Hồi Sư — nhánh của phiên game-c6): chênh 21% |
| L2 | Hitbox theo 06 | Bán kính Cự Thần 40 → **56** | Khớp hình vẽ (×2,3); lớp cận chiến đánh trúng khi né vòng báo |
| L3 | Neo Hư Vô "thanh máu = 20 × cấp" | **≈ 20 đòn** = 7 × HP quái thường loại Lì cùng cấp | 20 × cấp (≈ 1.600) chết trong 1 đòn ở cấp 80 |
| L4 | TL-B7 "tiến hoá 1 lần Lv10" | Bot dùng `talent_level = 10` như TL-B5/B6 | Cấp hiệu dụng 19 làm trận chỉ còn 12–18 giây; giữ cùng quy ước với các chương trước để so sánh được |
| L5 | Cửa sổ / khiên chặn đòn của người chơi | Chuyển cảnh Cự Thần, Khiên trời, Kỳ Lân đang chạy chặn **mọi nguồn** sát thương (cả bẫy, Mưa Tên, đồng minh) | Bẫy / Mưa Tên gây sát thương với `by_player = false` nên lọt qua nếu chỉ chặn đòn tay |
| L6 | — | Cự Thần khai báo hook `boss_phase_two` | Không có hook này GameWorld áp giai đoạn 2 chung ở 50% (gọi sói của Sói Chúa) |

