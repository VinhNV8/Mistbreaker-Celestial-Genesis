# Đợt M12 — Chương 9: Thiên Đạo Chi Môn (vùng 9 Cổng Thiên Đạo) + Hai kết thúc + Endgame

| | |
| --- | --- |
| Dự án | Thiên Phú Khai Giới |
| Nguồn | [Kịch bản](kich-ban-game-thien-phu-khai-gioi.md) mục 2 (chương 9: *"Quyết chiến Ma Tôn Vô Diện — Hai kết thúc"*; **Hai kết thúc**: *"(1) Hợp nhất — nhân vật hấp thụ mảnh thứ hai, trở thành Thiên Đạo mới, mở chế độ endgame 'Thần Vực'. (2) Hiến tế — nhân vật trả mảnh thứ hai cho Bia Đá, sương mù tan, mở chế độ endgame 'Tái Thiết Lục Địa'. Lựa chọn ảnh hưởng trục Thiên phú được mở ở endgame."*), mục 4 (*"cấp tối đa 100 (+ cấp Thần Vực vô hạn ở endgame)"*), mục 5 (Ma Tôn: *"3 giai đoạn, dùng Thiên phú của mọi boss trước đó"*), mục 6 (vùng 9: *"Tất cả · Mỗi tầng một hệ, đổi ngẫu nhiên — mở: Chuyển chức 3"*) · [06](06-ban-do-quai-boss.md) vùng 9 (**giữ nguyên tên và danh sách**) · [14](14-chuong-6.md) (Ám Khí, Ám Hoá, Bản Ngã) · [16](16-chuong-7.md), [17](17-chuong-8.md) (mồi chương 9, Bia Đá gốc, Lõi Hư Vô) |
| Mục tiêu | Chương 9 chơi trọn từ lúc lên Cổng Thiên Đạo tới **lựa chọn kết thúc** và vào được **chế độ endgame** tương ứng — game có kết thúc trọn vẹn |
| Thứ tự | Sau M11. Chia M12.1 (vùng 9: tầng, hệ tầng, quái) → M12.2 (Ma Tôn, đồ) → M12.3 (cốt truyện, hai kết thúc) → M12.4 (endgame tối thiểu: cấp sau 100, Thần Vực / Tái Thiết Lục Địa, Thiên Đạo Hư Ảnh) |
| Kiến trúc | `core/chapter9.gd` (vùng, Ma Tôn — dùng lại hàm cơ chế của `chapter4/5/6/7/8.gd`, không chép code), `core/endgame.gd` (cấp sau 100, 2 chế độ). Ma Tôn gọi cơ chế cũ qua hàm tĩnh công khai của từng chương (ví dụ `Ch5.lava_flood`, `Ch6.mirror_cast`, `Ch8.drain_talent`) — chương nào chưa tách hàm thì tách ra khi làm M12. Vẽ ở `view/region9_view.gd`, hình `tools/art/region9.py` |
| Quy trình | Spec (file này) → duyệt → code → test → cập nhật 01/02/03/04/05/06/07 và mục Kết quả |
| Trạng thái | 🟡 **Rà lại 31/10/2026** (mục 0b); Q90–Q98 dùng cột Mặc định (04 mục 13 dòng 14). Code sau M11 |

Ký hiệu: ✅ xong · 🟡 một phần · ⬜ chưa làm.

## 0. Bám kịch bản và các điều chỉnh mới

| Nguồn | Áp vào chương 9 |
| --- | --- |
| Kịch bản chương 9 + Hai kết thúc | Màn lựa chọn sau khi hạ Ma Tôn (C9-44); mỗi kết thúc **mở một chế độ endgame** và **một trục Thiên phú** riêng (C9-45, C9-46) |
| Kịch bản mục 4 | Cấp sau 100 vô hạn (NV-09) ở endgame (C9-50) |
| Kịch bản Ma Tôn | 3 giai đoạn **dùng lại cơ chế boss chương 1–8** (06) — mỗi cơ chế là phiên bản rút gọn, giữ đúng bài học cân bằng đã rút ra ở chương đó |
| CT-03 "mảnh thứ hai" | Đỉnh điểm: Ma Tôn gọi mảnh thứ hai ở cuối trận (Ám Khí), rồi người chơi chọn số phận của nó |
| MP-09 | Cổng "next" ở 8-3 thành **Thiên Thê** (cầu thang ánh sáng). Trong vùng 9, giữa các tầng có **Cửa Tầng** (cổng loại mới, mở sau khi hạ Thủ Tầng) |
| HP-01…10 | Hang phụ **Mật Thất Thiên Đạo** ở 3 map; trong hang hệ tầng **không** áp |
| SK2 (biến thể hệ tầng II), Ngũ Hành Linh Căn, Bí Kíp Âm Dương | Vùng 9 là nơi **hệ khắc quan trọng nhất** — Ấn Hệ (C9-11) cho mọi lớp cách khắc hệ mà không phải đổi biến thể |
| UI-15/16/17 | Bảng tên quái hiện **biểu tượng hệ của tầng**; HUD *"Tầng 4 · Hỏa"*; mẹo F1: *"Cổng Thiên Đạo: mỗi tầng một hệ — nhặt Ấn Hệ để đòn đánh khắc hệ tầng 60 giây."* |
| D41, F1–F4 | Phân thân của Ma Tôn: mọi bản `is_hidden`; không phạt theo từng đòn; không bất tử theo đồng hồ trừ Độn thổ ngắn (boss ngừng gây sát thương khi bất tử — F3) |

## 0b. Rà lại 31/10/2026 — các thay đổi sau ngày viết spec (22/10)

Chỗ đã sửa trong các mục sau được đánh dấu *(rà 31/10)*.

| Thay đổi (tài liệu) | Ảnh hưởng tới chương 9 | Sửa ở |
| --- | --- | --- |
| **5 lớp** ([19](19-lop-ho-ve-trieu-hoi-su.md), [21](21-thiet-ke-lai-5-lop.md)); Q82 "Hộ Vệ ngoài phạm vi" không còn đúng | Test cân bằng và Thần Vực chạy **5 lớp**; bảng tổng kết hành trình ghi đúng chức 3 của 5 lớp | TL-B9, TL-B9b, mục 9 |
| **Chuyển chức 3 + 5 Thần Kỹ đã code** ([23](23-chuyen-chuc-3-linh-thu-co-mau.md)) | Bot TL-B9 lắp Thần Kỹ docs/23 ở ô 4; Ma Tôn GĐ2 *Sao chép* có bản bóng cho Thần Kỹ qua `Ch6.MIRROR_OF` (J3 Q145) | C9-30b, TL-B9 |
| **Linh thú có máu** (SH-03) | Ma Tôn, Thiên Đạo Hư Ảnh và quái gọi trong trận **không đánh linh thú**; quái thường vùng 9 đánh được | C9-30 |
| **Kỹ năng bị động** (PV, [27](27-ky-nang-bi-dong.md)) | Không phải Thiên phú → không bị Hút Thiên phú (GĐ3 Ma Tôn), không được +20% của Tinh Quang Thủ Hộ | C9-30c, C9-46 |
| **Bí Kíp = +1 Điểm Kỹ Năng** (BK, [29](29-bi-kip-diem-ky-nang.md)) | "Bí Kíp tầng II/III" → **Bí Kíp** (+1 Điểm Kỹ Năng), tỉ lệ giữ theo nguồn. Bộ Tái Thiết vùng 8 "+10% tỉ lệ rơi Bí Kíp" giữ nguyên | C9-31, C9-34 |
| **Bản đồ ×3 diện tích** (SN11-03) | Toạ độ gốc 4.480 × 2.560 → trong game 7.760 × 4.434. Mỗi tầng ≈ 2.590 m bề ngang — đủ rộng; giữ 3 tầng mỗi map | C9-02 |
| **EXP theo chênh cấp** (SN9-05) | Sau cấp 100, chênh cấp tính với **cấp 100** (cấp Thần Vực / Khai Thế không làm quái cấp 100 thành "thấp cấp") | C9-50 |
| **Điểm Kỹ Năng, điểm tiềm năng mỗi cấp** (SK1, CS) | Cấp sau 100 **không** cho Điểm Kỹ Năng / điểm tiềm năng — chỉ cho Điểm Thiên Đạo | C9-50 |
| **Bình MP** (SN10-02) | Tuyết Nga bán bình MP | C9-40 |
| **Chương 8 rà lại** ([17](17-chuong-8.md) mục 0b) | Hút Thiên phú dùng `Ch8` (talent_mult = 0); 12/8/5 đèn ở vùng 8 không đổi số 3 đèn của đấu trường Ma Tôn | C9-30c |
| Save đã tới v24, M11 = v25 | **M12 = v26** (thay v20) | mục 7 |
| RS-K01 (Ma Tôn xuất hiện sớm), RS-K04 (lựa chọn nhỏ) — chưa duyệt | Ngoài phạm vi M12; kết thúc không đọc lựa chọn nhỏ | — |

## 1. Mở vùng 9

| Mã | Yêu cầu | Tiêu chí |
| --- | --- | --- |
| C9-01 | Điều kiện (kịch bản mục 6): **đã chuyển chức 3** (`profile.job3 != ""`) + **hạ Giáo Chủ Hư Vô** + **cấp ≥ 94**. Cổng Thiên Thê ở 8-3 + bảng Cổng Dịch Chuyển hiện điều kiện còn thiếu | C9-T1 |
| C9-02 | 3 map (toạ độ gốc 4.480 × 2.560 theo 06; trong game ×√3 — SN11-03 *(rà 31/10)*): **9-1 Tầng 1–3** (cấp 95–97), **9-2 Tầng 4–6** (97–99), **9-3 Tầng 7–9** (99–100, hang *Thiên Đạo Chi Môn* cấp 100). Mỗi map chia **3 tầng theo chiều ngang** (mỗi tầng ≈ 1/3 bề rộng), ngăn bởi **Cửa Tầng**. Trạm đầu mỗi map: *Thiên Thê Đài I / II / III* (vùng an toàn, Cổng Dịch Chuyển) | C9-T1; smoke `21-region9` |
| C9-03 | **Thủ Tầng**: cuối mỗi tầng có 1 tinh anh canh Cửa Tầng (tầng lẻ: Thiên Tướng, tầng chẵn: Ngũ Hành Sứ Giả, tầng 9: cả hai). Hạ lần đầu → Cửa Tầng mở **vĩnh viễn** (`floors9`). Cửa Tầng đóng: bước vào báo *"Hạ Thủ Tầng để mở"* | C9-T1 |
| C9-04 | Lưới khai phá 45 ô = **9 tầng × 5 ô** (06). Không có tài nguyên thường; ô sự kiện Tài nguyên đổi thành **Kỳ quan nhỏ** hoặc **Ổ quái**. Chiếm đủ 5 ô của một tầng → **1 Tinh Hoa Tiến Hoá** (06: *"phần thưởng là Tinh Hoa Tiến Hoá"*; 9 tầng = 9 Tinh Hoa) | C9-T6 |
| C9-05 | Hang phụ **Mật Thất Thiên Đạo** (HP-02) ở cả 3 map | C9-T1 |

## 2. Môi trường Cổng Thiên Đạo (M12.1)

| Mã | Yêu cầu | Tiêu chí |
| --- | --- | --- |
| C9-10 | **Mỗi tầng một hệ, đổi ngẫu nhiên** (kịch bản): mỗi lần người chơi **bước vào một tầng** (qua Cửa Tầng, qua cổng, hoặc hồi sinh), hệ tầng rút ngẫu nhiên 1 trong 5 (Kim/Mộc/Thủy/Hỏa/Thổ), **không trùng hệ lần trước** của tầng đó. Mọi quái trong tầng mang hệ tầng (tạo lại hệ của quái đang sống). Nền + sương tô màu hệ; HUD dòng môi trường *"Tầng 4 · Hỏa · khắc: Thủy"* | C9-T2 |
| C9-11 | **Ấn Hệ** (06): mỗi tầng có 1 bệ Ấn Hệ (vị trí ngẫu nhiên trong tầng, hiện trên bản đồ nhỏ). Nhặt → **60 giây** mọi đòn của người chơi (đánh thường + kỹ năng + Thần Kỹ + đồng minh) mang **hệ khắc hệ tầng** (+30%; thay hệ biến thể tầng II, giữ hiệu ứng phụ của biến thể). Bệ hồi lại sau 90 giây. **Ngũ Hành Linh Căn**: Ấn kéo dài 120 giây. Icon Ấn + đếm giờ ở cạnh khung nhân vật | C9-T2 |
| C9-12 | **Áp lực thiên uy**: tầng càng cao quái càng đông — số quái ngoài đồng tầng *n* × (1 + 0,05·n) (trần 40 quái của BD-12 giữ nguyên) | C9-T2 |

## 3. Quái vùng 9 (M12.1)

Chỉ số từ `Formulas.mob_stats` (06 vùng 9), hệ = hệ tầng.

| Mã | Quái | Loại | Kỹ năng | Tiêu chí |
| --- | --- | --- | --- | --- |
| C9-20 | **Thiên Binh Ngũ Hành** | Giáp | **Kích ngũ hành** (vung 0,8 s, hồi 6 s): đâm thẳng 6 m ×1,4, mang hệ tầng (màu theo hệ) | C9-T3 |
| C9-21 | **Tàn Hồn Khai Giới Giả** | Phép | Linh hồn Khai Giới Giả bị Ma Tôn cướp Thiên phú 1.000 năm trước. **Mang 1 Thiên phú ngẫu nhiên trong 20** (tên Thiên phú hiện dưới bảng tên, màu hạng) và dùng hiệu ứng theo **nhóm Thiên phú** (dùng lại bảng C6-30c của Bản Ngã): Chiến đấu → +30% Tấn công, +20% tốc đánh · Phép thuật / Điều khiển → mỗi 8 giây làm chậm người chơi 40% 2 giây · Triệu hồi → mỗi 12 giây gọi 2 Ảnh Bóng · Khai phá / Kinh tế / Chế tạo / Lãnh địa → +25% tốc chạy · Đặc biệt (Đạo Tặc) → mỗi 10 giây dùng lại kỹ năng người chơi vừa dùng (bản bóng, C8-51). Đánh xa 18 m ×1,0 | C9-T3 |
| C9-22 | **Thiên Mã** | Nhanh | **Phi nước đại** (vung 0,6 s, hồi 7 s): lao thẳng 20 m ×1,5 (vệt báo) | C9-T3 |
| C9-23 | **Ngũ Hành Linh Thú** | Lì | **Gầm ngũ hành** (vung 0,9 s, hồi 10 s): vòng 8 m ×1,2 + người chơi **mất thưởng khắc hệ 5 giây** (kể cả Ấn Hệ — Ấn không mất, chỉ tạm vô hiệu) | C9-T3 |
| C9-24 | Tinh anh **Thiên Tướng** (Thủ Tầng tầng lẻ; ngoài đồng từ cấp 96) | Giáp | **Thiên phạt** (hồi 12 s): 5 cột sét vòng 4 m quanh người chơi, báo 1,2 s, mỗi cột ×1,6 | C9-T3 |
| C9-25 | Tinh anh **Ngũ Hành Sứ Giả** (Thủ Tầng tầng chẵn; ngoài đồng từ cấp 97) | Phép | **Đổi hệ mỗi 8 giây** (không theo hệ tầng; báo đổi 1 giây trước bằng vòng màu). **Chỉ nhận đủ sát thương từ hệ khắc hệ hiện tại**; hệ khác hoặc không hệ nhận **25%** (Q90). Bí Kíp Âm Dương, Ngũ Hành Linh Căn / Hỗn Độn Linh Căn, Mặt Nạ Vô Diện luôn khắc | C9-T3 |

## 4. Boss và đồ (M12.2)

**Ma Tôn Vô Diện** (boss chương 9, cấp 100, 130 đòn; 134.796 HP, Phá Thế 22.466 theo 06) ở *Thiên Đạo Chi Môn*: đấu trường tròn **32 m** trước cánh cổng ánh sáng; **5 Đá Nổi** (vòng 3 m), **3 Đèn Tinh Quang**, vành ngoài 24–32 m chia 4 cung. Hình: người mặc giáp đen không mặt (khuôn mặt là khoảng trống xoáy sương), sau lưng 8 bóng mờ của 8 boss chương trước sáng lên khi hắn dùng cơ chế của boss đó. Hệ: **đổi mỗi 10 giây ở GĐ3**, trước đó theo hệ tầng 9 lúc vào hang.

| Mã | Giai đoạn | Cơ chế (dùng lại boss cũ, rút gọn) | Tiêu chí |
| --- | --- | --- | --- |
| C9-30 | **GĐ1 (100 → 66%) — Ký ức chương 1–3** | **Vồ** (Sói Chúa): vung 0,8 s, lao tới chỗ người chơi (tối đa 30 m), vòng 9 m ×2,0, vệt báo · **Phân thân** (Huyền Ảnh): mỗi khi mất **12% HP** tách 3 bản (1 thật), **chỉ bản thật có bóng**; cả 3 bản `is_hidden` (F1); đánh bản giả: bản đó tan (không phạt); kéo dài tới khi bản thật trúng **3 đòn** hoặc 8 giây · **Độn thổ** (Sa Hoàng): mỗi 20 giây chui xuống **1,5 giây** (bất tử, **không gây sát thương** — F3), trồi lên dưới chân người chơi vòng 7 m ×2,0, vòng báo 1,0 s. Đánh thường Chưởng ×1,0 | C9-T4; TL-B9 |
| C9-30b | **GĐ2 (66 → 33%) — Ký ức chương 4–6** | **Giấc mơ** (Nữ Vương): mỗi 25 giây, vung 1,5 s (sương tím quanh người chơi) → **đảo ngược điều khiển 4 giây** (hook `input_filter`, viền tím, chữ *"Giấc mơ!"*) — né lăn trong lúc vung **tránh được** · **Dung nham dâng** (Viêm Long): mỗi 25 giây (lệch Giấc mơ 12 giây) nền **ngập 5 giây** (báo 3 giây), chỉ 5 Đá Nổi an toàn, ngoài đá −8% HP/giây; **Ma Tôn không bay, vẫn đánh được** (D41) · **Sao chép** (Bản Ngã): dùng lại kỹ năng người chơi vừa dùng sau **3 giây** theo nhóm kỹ năng (C8-51), vung 0,6 s có báo | C9-T4 |
| C9-30c | **GĐ3 (dưới 33%) — Vô Diện, ký ức chương 7–8** | **Chiến trường thu nhỏ** (Cự Thần): một cung vành ngoài vỡ sau mỗi **8% HP** mất hoặc 20 giây (lõi 24 m không vỡ); rơi → về mép lõi, −10% HP, Ma Tôn hồi 3% · **Hút Thiên phú** (Giáo Chủ): mỗi 30 giây kênh 1,5 giây, vô hiệu Thiên phú 10 giây, **3 Đèn Tinh Quang chặn được** (mỗi đèn 1 lần) · **Vô Diện**: **đổi hệ mỗi 10 giây** (biểu tượng hệ to trên đầu, báo 1 giây trước) | C9-T4 |
| C9-30d | **Mảnh thứ hai thức tỉnh** (dưới 10% HP, đỉnh điểm CT-03) | Ma Tôn ngừng mọi cơ chế 3 giây (bất tử, không gây sát thương — F3), **gọi mảnh thứ hai**: thoại *"Trả lại... phần của ta!"*. Từ đó Ám Khí người chơi **+10 mỗi giây**; đầy → **Ám Hoá** (C6-43: +20% Tấn công, giữ điều khiển) rồi về 0 và tăng lại. Ma Tôn mất khả năng **Hút Thiên phú** (mảnh thứ hai đang chống lại hắn). Hạ Ma Tôn → cảnh kết (C9-44) | C9-T4 |
| C9-31 | Ma Tôn rơi | 2 đồ Tím · **Mặt Nạ Vô Diện** lần đầu **100%**, sau đó 15% (mũ Cam: mỗi 30 giây, 10 giây đòn đánh đổi sang **hệ khắc mục tiêu**) · 3 Tinh Hoa · 1 Tinh Kim · 40% Bí Kíp (+1 Điểm Kỹ Năng *(rà 31/10)*). Hồi sinh 10 phút (đánh lại được sau kết thúc, không đổi kết thúc) | C9-T4 |
| C9-32 | Đạo Tặc — **Vô Diện** (06) | Dùng ngẫu nhiên 1 kỹ năng boss **đã sao chép** với **×1,5** sát thương (cần ≥ 2 kỹ năng đã học; hồi chiêu = hồi chiêu của kỹ năng được chọn) | C9-T4 |
| C9-33 | **Boss hiếm Thiên Đạo Hư Ảnh** (06: *"xuất hiện ở Endgame, sau khi hạ Ma Tôn"*) | 9-3 (cấp 100, Phép, mọi hệ, 200 đòn; 218.214 HP; `RARE_BOSSES["9-3"]`, chỉ sau khi đã chọn kết thúc). **3 giai đoạn**, mỗi giai đoạn rút 1 trong **6 Thiên phú hạng S trở lên** (không lặp): *Ngũ Hành Linh Căn* — đổi hệ mỗi 6 giây, mỗi lần đổi nổ vòng 6 m ×1,5 · *Thời Gian Ngưng Đọng* — mỗi 20 giây ngưng người chơi 1,5 giây (báo 1 giây, né lăn tránh) · *Bầy Đàn Bóng Tối* — mỗi 15 giây gọi 4 lính bóng · *Thiên Mệnh Khai Giới* — sương dày, tầm nhìn 50% · *Long Mạch* — mỗi 25 giây Long Hồn bay ngang đấu trường (vệt báo 1,5 s, ×1,5) · *Đạo Tặc* — mỗi 12 giây dùng 1 cơ chế boss chương ngẫu nhiên (bản rút gọn ở C9-30…30c) | C9-T4 |
| C9-34 | Hư Ảnh rơi | 3 Tinh Hoa Tiến Hoá · 10 Tinh Hoa · **1 đồ Cam ngẫu nhiên của mọi vùng** (06 mục 4, 17 món) · Bí Kíp (100%, +1 Điểm Kỹ Năng) | C9-T4 |
| C9-35 | **Bộ Thiên Đạo** (đồ Tím vùng 9, 06) | 2 — **+5% mọi chỉ số** · 4 — **khắc hệ +20%** (tổng +50%) · 6 — **kỹ năng L hồi nhanh 30%** | C9-T4 |

## 5. Cốt truyện (M12.3)

| Mã | Yêu cầu | Tiêu chí |
| --- | --- | --- |
| C9-40 | **NPC Thiên Thê Đài I** (9-1): *Vân Hạc* (mang mảnh Bia Đá gốc, người dẫn truyện, chủ trì nghi thức cuối) · *Tuyết Nga* (**cửa hàng**: bình máu, bình MP, Đèn Lồng Tinh Quang, Lông Vũ Gió, Than Hồng — đồ tiêu hao của mọi chương) · *Lam Nhi* (bạn đồng hành chương 4, có lại Thiên phú — đi cùng tới cuối). Ở cảnh kết có thêm *Thạch Lão* (trưởng làng chương 1), *Lạc Phong*, *Mạc Tam*, *Xích Đồng* | Smoke `21c-camp9` |
| C9-41 | **Nhiệm vụ chương 9 — 7 bước**: (1) **Thiên Thê**: tới Thiên Thê Đài gặp Vân Hạc · (2) **Thiên binh**: hạ 30 quái vùng 9 · (3) **Vượt tầng**: mở Cửa Tầng tới **tầng 6** (hạ 5 Thủ Tầng đầu) · (4) **Ánh Hồn**: hạ **9 Tàn Hồn Khai Giới Giả** (mỗi con rơi 1 *Ánh Hồn* — vật phẩm nhiệm vụ) — Vân Hạc dùng 9 Ánh Hồn vá mảnh Bia Đá gốc thành **Ấn Phong Thiên** · (5) mở tới **tầng 9**, khám phá 9-3 ≥ 40% (tìm Thiên Đạo Chi Môn) · (6) hạ **Ma Tôn Vô Diện** · (7) **Lựa chọn** (C9-44). Thưởng EXP ≈ 25% EXP cấp 95 → 100 (13,57 triệu × 25% ≈ **3,39 triệu**); EXP thừa ở cấp 100 chuyển sang cấp sau 100 (C9-50) khi đã chọn kết thúc, trước đó **giữ trong "EXP tích luỹ"** (không mất) | C9-T5 |
| C9-42 | **Thoại tầng**: mỗi lần mở Cửa Tầng mới, 1 dòng ký ức của Ma Tôn hiện trên màn hình (9 dòng — hắn từng là Khai Giới Giả mạnh nhất, bị Thiên Đạo từ chối, rồi đoạt Thiên phú gây Thiên Liệt) — kể dần lý do phản diện, không chỉ là ác | C9-T5 |
| C9-43 | **Trước trận cuối**: vào Thiên Đạo Chi Môn → Ma Tôn nói chuyện (nhân vật mang linh hồn hắn: *"Ngươi là ta mười sáu năm qua"*), Lam Nhi và Vân Hạc ở lại cửa | Smoke `21d-ma-ton` |
| C9-44 | **Lựa chọn kết thúc** (kịch bản): Ma Tôn tan; mảnh thứ hai bừng sáng trong ngực nhân vật; Ấn Phong Thiên mở ra trước Cổng. Màn hình **2 thẻ lớn**: **Hợp nhất** (*"Hấp thụ mảnh thứ hai, trở thành Thiên Đạo mới"*) · **Hiến tế** (*"Trả mảnh thứ hai cho Bia Đá — sương mù tan"*), mỗi thẻ ghi rõ hệ quả (chế độ endgame, trục Thiên phú, sương mù). Chọn → **xác nhận lần 2** (*"Lựa chọn này không thể đổi lại."*). Lựa chọn lưu ở `profile.ending` | C9-T7; smoke `22-ending-choice` |
| C9-45 | **Kết thúc 1 — Hợp nhất**: cảnh kết 6 trang (nhân vật ngồi trên Cổng Thiên Đạo, sương vẫn còn nhưng nghe lệnh mình; Lam Nhi nhìn lên — *"Cậu vẫn là cậu chứ?"*). **Trục Thiên phú mở**: Thiên phú thứ hai **Vô Diện Thiên Đạo** (không chiếm ô Thiên phú phụ TP-05): Ám Khí thành **Thiên Đạo Lực** — tăng cả khi gây sát thương (+1 mỗi 2% HP quái mất), đầy → **Thần Hoá 10 giây** (+30% Tấn công, +15% tốc đánh, đòn đánh mang hệ khắc mục tiêu). Mở chế độ **Thần Vực** (C9-51) | C9-T7; smoke `22b-ending-hop-nhat` |
| C9-46 | **Kết thúc 2 — Hiến tế**: cảnh kết 6 trang (mảnh thứ hai rời khỏi người, nhân vật ngất; tỉnh dậy ở làng Thanh Thạch, sương mù tan khắp lục địa, Bia Đá Thanh Thạch liền lại). **Sương mù tan**: mọi sương bản đồ (`fog`) vùng 1–9 mở hết, mọi ô khai phá chưa mở **lộ sự kiện** (vẫn phải chiếm). Mảnh thứ hai mất → Ám Khí / Ám Hoá **biến mất**. **Trục Thiên phú mở**: Thiên phú thứ hai **Tinh Quang Thủ Hộ**: hiệu lực Thiên phú chính **+20%** (qua `talent_mult`), lãnh địa **+30% sản lượng**, miễn Suy Thiên. Mở chế độ **Tái Thiết Lục Địa** (C9-52) | C9-T7; smoke `22c-ending-hien-te` |
| C9-47 | Sau cảnh kết: **bảng tổng kết hành trình** (thời gian chơi, số quái, boss, ô chiếm, Thiên phú cuối, chức 3) + **danh đề** (credits) cuộn; về game ở Thiên Thê Đài I. Màn hình tiêu đề hiện **biểu tượng kết thúc** đã chọn cạnh tên nhân vật | Smoke `22d-credits` |

## 6. Endgame tối thiểu (M12.4)

Kịch bản Beta: *"chương 1–9, endgame, boss thế giới, shop, sự kiện theo mùa"*. M12.4 chỉ làm **phần lõi** để hai kết thúc có ý nghĩa ngay; Ác mộng / Địa ngục (BD-10), boss thế giới, mùa → đợt Beta riêng.

| Mã | Yêu cầu | Tiêu chí |
| --- | --- | --- |
| C9-50 | **Cấp sau 100** (kịch bản mục 4, NV-09) — mở khi đã chọn kết thúc. Tên theo kết thúc: **Thần Vực N** (Hợp nhất) / **Khai Thế N** (Hiến tế), cùng số liệu. EXP mỗi cấp = EXP(100) × (1 + 0,02·N). Mỗi cấp **+1 Điểm Thiên Đạo**, cộng vào 5 nhánh (mỗi điểm): Tấn công +0,5% · HP +0,8% · Chí mạng +0,2% · Hồi chiêu −0,3% (trần −15%) · Sản lượng lãnh địa +1%. Không có cấp trần; tẩy điểm miễn phí ở vùng an toàn. Chênh cấp EXP (SN9-05) tính với **cấp 100** nên quái cấp 100 vẫn cho đủ EXP. Cấp sau 100 không cho Điểm Kỹ Năng / điểm tiềm năng *(rà 31/10)* | C9-T8 |
| C9-51 | **Thần Vực** (Hợp nhất): cổng **Thần Vực** ở Thiên Thê Đài I → **tháp thử luyện vô tận**. Mỗi tầng: đấu trường tròn, **90 giây** hạ đủ 1 đợt quái + (cứ 5 tầng) **1 boss chương ngẫu nhiên**; cấp quái = 100 + 2 × tầng (công thức 06 chạy tiếp quá cấp 100). Thắng → tầng kế (hồi 30% HP); thua/hết giờ → ra ngoài, giữ **kỷ lục tầng cao nhất**. Thưởng mỗi tầng: Tinh Hoa (tầng/5 + 1), cứ 10 tầng 1 đồ Cam ngẫu nhiên. Tầng cao nhất hiện ở bảng Chỉ số (sẵn cho bảng xếp hạng online KT-09) | C9-T8 |
| C9-52 | **Tái Thiết Lục Địa** (Hiến tế): mỗi vùng 1–9 có 1 **Công trình Tái Thiết** xây ở trạm vùng đó (bảng dưới), giá tăng theo vùng (vùng *k*: 2.000·k vàng, 200·k Gỗ, 150·k Đá, 100·k Sắt, 20·k Tinh Thạch, **k ≥ 8 thêm 2 Lõi Hư Vô**). Xây xong → **buff vĩnh viễn** + vùng đó có **Triều Hư Vô tàn dư** mỗi 30 phút chơi ở vùng (dùng khung đột kích C5-43: 1 đợt quái cấp 100 + 1 boss chương của vùng; thắng: Tinh Hoa + Tinh Thạch; thua: buff vùng đó tắt 30 phút). Xây đủ 9 → danh hiệu **"Người Tái Thiết"** + trung tâm lãnh địa vẽ thành Kinh Thành | C9-T8 |
| C9-53 | Cả hai kết thúc: Thiên Đạo Hư Ảnh (C9-33) xuất hiện; Ma Tôn đánh lại được (rơi đồ như C9-31); EXP thừa trước khi chọn được cộng vào cấp sau 100 | C9-T8 |

**C9-52 — 9 công trình Tái Thiết:**

| Vùng | Công trình | Buff vĩnh viễn |
| --- | --- | --- |
| 1 | Tháp Sương Tan | +10% EXP |
| 2 | Phong Đài | +10% tốc chạy |
| 3 | Giếng Sa Mạc | +1 Đuốc tối đa, Đuốc hồi nhanh 20% |
| 4 | Vườn Mộng | Bình máu hồi +20% |
| 5 | Lò Rèn Viêm Long | Cường hoá +5% tỉ lệ thành công |
| 6 | Đài Cực Quang | +10% vàng |
| 7 | Cảng Thiên Không | Đi đường qua cổng nhanh 50% |
| 8 | Đèn Tinh Quang Vĩnh Cửu | +10% tỉ lệ rơi Bí Kíp |
| 9 | Đền Thiên Đạo | +5% mọi chỉ số |

## 7. Thay đổi save (version 25 → 26)

*(rà 31/10)* M11 = v25 nên **M12 = v26**.

| Trường | Kiểu | Mặc định save cũ |
| --- | --- | --- |
| `quest.ch9`, `quest.kills9`, `quest.souls9` | int, int, int (Ánh Hồn) | 0, 0, 0 |
| `floors9` | Array[int] — tầng đã mở Cửa | [] |
| `ending` | String — `""`, `hop-nhat`, `hien-te` | `""` |
| `exp_bank` | float — EXP tích luỹ ở cấp 100 trước khi chọn kết thúc | 0 |
| `divine_level`, `divine_exp`, `divine_points` | int, float, Dictionary nhánh → điểm | 0, 0, {} |
| `tower_best` | int — tầng Thần Vực cao nhất | 0 |
| `rebuild` | Dictionary vùng → true (Công trình Tái Thiết đã xây) | {} |
| `rebuild_raid` | Dictionary vùng → giây chơi tới lần Triều kế / buff tắt tới | {} |

Hệ tầng, Ấn Hệ, giai đoạn Ma Tôn là trạng thái trong trận (không lưu).

## 8. Kiểm thử

| Mã | Kiểm |
| --- | --- |
| C9-T1 | Điều kiện mở vùng 9 (thiếu chức 3 / Giáo Chủ / cấp); 3 map, 9 tầng, Cửa Tầng khoá tới khi hạ Thủ Tầng, mở vĩnh viễn; Mật Thất |
| C9-T2 | Hệ tầng rút khi vào tầng, không trùng lần trước, quái đổi hệ; Ấn Hệ 60 giây (Ngũ Hành 120), khắc +30%, bệ hồi 90 giây; mật độ quái theo tầng |
| C9-T3 | Kích ngũ hành mang hệ tầng; Tàn Hồn mang Thiên phú + hiệu ứng theo nhóm; Phi nước đại; Gầm tắt khắc hệ 5 giây; Thiên phạt 5 cột; Sứ Giả đổi hệ 8 giây, hệ khác 25%, Âm Dương / Linh Căn đủ |
| C9-T4 | Ma Tôn: GĐ1 (Vồ, Phân thân theo 12% HP — mọi bản không bị tự ngắm, Độn thổ bất tử 1,5 giây không gây sát thương); GĐ2 (Giấc mơ đảo điều khiển 4 giây, né được; ngập dung nham 5 giây + đá nổi, boss đánh được; sao chép theo nhóm kỹ năng); GĐ3 (cung vỡ theo 8% HP / 20 giây, Hút Thiên phú + 3 đèn, đổi hệ 10 giây); dưới 10% mảnh thứ hai (Ám Khí +10/giây, Ám Hoá, hết Hút). Mặt Nạ Vô Diện 100% lần đầu; Vô Diện (Đạo Tặc); Hư Ảnh 3 giai đoạn × 6 Thiên phú; đồ Cam ngẫu nhiên; Bộ Thiên Đạo 2/4/6 |
| C9-T5 | Nhiệm vụ chương 9 đủ 7 bước; EXP ≈ 3,39 triệu; EXP thừa ở cấp 100 vào `exp_bank`; 9 dòng ký ức tầng |
| C9-T6 | Lưới 45 ô (9 × 5), đủ 5 ô một tầng → 1 Tinh Hoa Tiến Hoá |
| C9-T7 | Màn lựa chọn 2 thẻ + xác nhận 2 lần; Hợp nhất: Thiên Đạo Lực, Thần Hoá 10 giây; Hiến tế: sương vùng 1–9 mở hết, ô lộ sự kiện, Ám Khí mất, +20% Thiên phú, +30% lãnh địa; bảng tổng kết, danh đề; không đổi lại được |
| C9-T8 | Cấp sau 100 (EXP công thức, Điểm Thiên Đạo, tẩy điểm, `exp_bank` cộng vào); Thần Vực (90 giây, cấp quái 100 + 2·tầng, boss mỗi 5 tầng, kỷ lục); Tái Thiết (giá theo vùng, Lõi Hư Vô từ vùng 8, 9 buff, Triều tàn dư); save v26 + chuyển đổi v25 |
| TL-B9 | **5 lớp** *(rà 31/10)* × 20 Thiên phú (chức 3, bộ kỹ năng mặc định cấp 99 có Thần Kỹ docs/23, tiến hoá 2 lần Lv10) hạ Ma Tôn (bot cấp 99, bộ đồ chuẩn cấp 99): F/S ≤ 25%, các lớp ≤ 25%, 0 lần chết. Bot: **tự đảo hướng khi Giấc mơ** (mô phỏng người biết cơ chế), lên Đá Nổi, đứng vòng đèn khi bị hút, đánh bản có bóng khi phân thân |
| TL-B9b | Thần Vực: bot mỗi lớp trong **5 lớp** (cấp 100, chưa có Điểm Thiên Đạo) đạt **tầng 10–20**; các lớp chênh ≤ 25% số tầng |
| PACE-T6 | (`--only=PACE`) bot cày vùng 9 cấp 95 → 100: phút, số lần chết |

Smoke mới: `21-region9`, `21b-floor-element`, `21c-camp9`, `21d-ma-ton`, `22-ending-choice`, `22b-ending-hop-nhat`, `22c-ending-hien-te`, `22d-credits`, `23-than-vuc`, `23b-tai-thiet`.

## 9. Liên quan tới các đợt khác

| Mục | Ghi chú |
| --- | --- |
| CT-03, CT-08, CT-12, CT-13 | Chương 9 hoàn tất mạch truyện kịch bản (mảnh thứ hai, Ma Tôn, chương 6–9, hai kết thúc) |
| NV-07 (chức 3) | Ở spec 17 (C8-45) |
| NV-09 (cấp Thần Vực) | C9-50 |
| TP-05 (ô Thiên phú phụ cấp 30/60) | **Vẫn chưa làm** — Thiên phú thứ hai của kết thúc là ô **đặc biệt** riêng, không thay TP-05 |
| BD-10 (Ác mộng / Địa ngục), boss thế giới, mùa, shop | Đợt Beta sau M12 — Thần Vực / Tái Thiết là nền (cấp quái > 100, Triều tàn dư) |
| Hộ Vệ, Triệu Hồi Sư | *(rà 31/10)* Đã có trong game (docs/19) — trong phạm vi M12 như 3 lớp kia |

## 10. Điểm cần duyệt

| # | Câu hỏi | Mặc định đề xuất |
| --- | --- | --- |
| Q90 | Ngũ Hành Sứ Giả *"chỉ nhận sát thương từ hệ khắc"* (06) — lớp chưa có biến thể hệ bị kẹt | Hệ khác / không hệ nhận **25%** (không phải 0); đổi hệ 8 giây có báo; Ấn Hệ, Âm Dương, Linh Căn khắc đủ |
| Q91 | *"Dùng Thiên phú của mọi boss trước đó"* (kịch bản) — hiểu là **cơ chế** boss (06) hay Thiên phú? | **Cơ chế boss** như 06 (bóng 8 boss sau lưng sáng lên khi dùng) — boss không có Thiên phú riêng |
| Q92 | Lựa chọn kết thúc đổi lại được không? | **Không** đổi (giữ trọng lượng lựa chọn của kịch bản); xác nhận 2 lần. Nhân vật mới chọn khác. Ma Tôn đánh lại được để lấy đồ |
| Q93 | Cấp sau 100 cho cả hai kết thúc hay chỉ Hợp nhất (kịch bản mục 2 gắn "Thần Vực" với Hợp nhất, mục 4 ghi chung "cấp Thần Vực vô hạn ở endgame")? | **Cả hai**, khác tên (Thần Vực / Khai Thế), cùng số — không phạt người chọn Hiến tế |
| Q94 | Hai kết thúc có cân nhau? | Hợp nhất mạnh về **chiến đấu** (Thần Hoá, tháp vô tận); Hiến tế mạnh về **lãnh địa / khai phá** (sương tan, +30% sản lượng, 9 buff) — đúng "trục Thiên phú" khác nhau. Không cân bằng bằng số, chỉ bảo đảm cả hai vào được endgame |
| Q95 | Giấc mơ đảo điều khiển — khó với điều khiển cảm ứng (Mobile)? | Né lăn trong 1,5 giây vung để tránh; chỉ 4 giây; có viền tím báo rõ. Xem lại khi chốt nền tảng |
| Q96 | Thần Vực vô tận cần chống "nhờ Điểm Thiên Đạo leo mãi"? | Không cần ở bản chơi đơn; khi có bảng xếp hạng online (KT-09) chia bảng theo mùa |
| Q97 | Kết thúc Hiến tế mở hết sương — mất nội dung khám phá? | Mở **sương bản đồ** và **lộ sự kiện ô**, nhưng ô vẫn phải chiếm (thủ lĩnh, câu đố) — giữ vòng chơi, đổi cảm giác "lục địa được giải phóng" |
| Q98 | Có làm M12.4 (endgame) cùng chương 9 hay tách? | **Cùng M12** ở mức tối thiểu (C9-50…53) — kết thúc mà không mở gì là trái kịch bản |

## 11. Kết quả

Chưa làm.
