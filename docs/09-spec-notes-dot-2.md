# Đợt SN2 — Spec_Notes đợt 2: Pháp Sư, phân rã/bán nhanh, chuyển cường hoá, bản đồ khám phá

| | |
| --- | --- |
| Dự án | Thiên Phú Khai Giới |
| Nguồn | [Spec_Notes](Spec_Notes.md) (ghi chú của chủ dự án, 20/10/2026) · [Kịch bản](kich-ban-game-thien-phu-khai-gioi.md) mục 4 (lớp Pháp Sư) · [05](05-thien-phu-chi-tiet.md) mục 5 |
| Mục tiêu | Làm toàn bộ 7 ghi chú mới của chủ dự án ("triển khai toàn bộ") |
| Thứ tự | Sau M4 (commit db98221). Làm theo thứ tự: chuyển cường hoá → phân rã/bán nhanh → bản đồ + sương → Pháp Sư |
| Quy trình | Spec (file này) → code → test → cập nhật 02/03/04 và mục Kết quả cuối file |
| Trạng thái | ✅ **Xong 20/10/2026** (phiên game-bc) |

Ký hiệu: ✅ xong · 🟡 một phần · ⬜ chưa làm.

## 1. Đối chiếu Spec_Notes

| # | Ghi chú của chủ dự án | Xử lý | Hạng mục |
| --- | --- | --- | --- |
| S1 | Bổ sung class Pháp sư | Lớp thứ 3 chọn được khi tạo nhân vật: đánh phép diện rộng, chỉ số chính INT | SN-01…03 |
| S2 | Inventory: phân rã nhanh | Nút **Phân rã nhanh** trong túi đồ, phân rã cùng lúc mọi món khớp bộ lọc | SN-11 |
| S3 | Phân rã nhanh cần bộ lọc | Bộ lọc dùng chung với bán nhanh (S5) | SN-10 |
| S4 | Mặc đồ mới: chuyển toàn bộ cấp cường hoá của đồ cũ sang | Tự chuyển khi mặc, không tốn gì, không bao giờ làm mất cấp | SN-20 |
| S5 | Cửa hàng: bán nhanh, có bộ lọc | Nút **Bán nhanh** ở cửa hàng, cùng bộ lọc S3 | SN-12 |
| S6 | Bản đồ các chương khá hẹp, thiếu cảm giác khám phá | Mọi map rộng ×1,6 mỗi chiều (diện tích ×2,56), quái/cây/thảo dược/rương tăng theo diện tích | SN-30 |
| S7 | Đi tới đâu thấy đất tới đó | **Sương che bản đồ** (fog of war) lưu theo map; % khám phá; thưởng khi khám phá 50% và 90% | SN-31…33 |

## 2. Hạng mục

### Phần A — Lớp Pháp Sư (S1)

Theo kịch bản mục 4: *"Pháp Sư — Sát thương phép diện rộng — Trí tuệ"*. Máu mỏng nhất, bù bằng phép diện rộng, khống chế (trói) và khiên.

| Mã | Yêu cầu | Tiêu chí nghiệm thu |
| --- | --- | --- |
| SN-01 | **Lớp Pháp Sư** (`phap-su`) chọn được ở màn Tạo nhân vật, có xem trước nhân vật (áo choàng tím dài, trượng gắn ngọc; đủ 2 giới tính × 3 màu da × 4 kiểu tóc). Vũ khí của lớp tên **Trượng** | Smoke `03c-mage`; save giữ lớp |
| SN-02 | **Chỉ số**: Tấn công = 10 + 2/cấp + **2 × INT** + trang bị; HP gốc 85 + 12/cấp (thấp nhất 3 lớp); MP gốc +30, hồi MP +1/giây; không có né gốc. Tự cộng điểm: 3 INT : 2 VIT | Test SN-T1 |
| SN-03 | **Đánh thường Hỏa Cầu** (J/chuột trái): cầu lửa bay 40 m, tự nhắm như Thợ Săn (quái theo hướng ngắm ±15°, không có thì quái gần nhất). Nổ khi chạm quái đầu tiên: quái đó ×1,0, quái khác trong 4 m ×0,5. Nhịp 0,6 giây ÷ tốc đánh | Test SN-T2 |
| SN-04 | **4 kỹ năng**: (1) **Lôi Xích** — 6 s, 15 MP: sét đánh quái gần nhất trong 35 m rồi nảy sang tối đa 4 quái kế tiếp (mỗi bước ≤ 15 m), mỗi quái ×1,6. (2) **Băng Ngục** — 9 s, 20 MP: băng nổ quanh mình 11 m, ×1,4, **trói** quái 2 giây. (3) **Thiên Thạch** — 10 s, 30 MP: vòng báo hiệu 10 m tại điểm ngắm (không có quái thì quái gần nhất trong 42 m), 0,8 giây sau thiên thạch rơi ×3,0. (4) **Pháp Thuẫn** — 20 s, 25 MP: khiên 6 giây hút sát thương tới 30% HP tối đa | Test SN-T2 |
| SN-05 | Thiên phú dùng được với Pháp Sư theo [05](05-thien-phu-chi-tiet.md) mục 5: Kiếm Tâm = phép đơn thứ 5 (Hỏa Cầu thứ 5), Ngũ Hành = Hỏa Cầu mang hệ, Bộc Phá theo **Băng Ngục** (vòng nổ lớn hơn). 10 phép kết hợp 2 hệ để Alpha (Q46) | TL-B chạy 3 lớp × 20 Thiên phú |
| SN-06 | **Hình** (skill `game-art`): sprite `hero-phap-su-<giới tính>-<da>` + tóc, 5 icon kỹ năng (`fireball`, `chain`, `nova`, `meteor`, `barrier`), hiệu ứng cầu lửa, sét, vòng băng, thiên thạch, khiên | AR-35 không thiếu hình |
| SN-07 | **Cân bằng**: TL-B (vùng 1, Sói Chúa) và TL-B2 (vùng 2, Huyền Ảnh) chạy thêm lớp Pháp Sư; giữ F/S ≤ 25%, chênh thời gian hạ boss giữa các lớp ≤ 25%, 0 lần chết với bộ đồ chuẩn | TL-B, TL-B2 |

### Phần B — Túi đồ và cửa hàng (S2–S5)

| Mã | Yêu cầu | Tiêu chí nghiệm thu |
| --- | --- | --- |
| SN-10 | **Bộ lọc** dùng chung: chọn phẩm chất (Trắng · Xanh lá · Xanh dương · Tím · Cam — mặc định bật 3 loại đầu), và 3 tuỳ chọn: **Giữ đồ đã cường hoá** (+1 trở lên, mặc định bật), **Giữ đồ bộ** (mặc định bật), **Chỉ đồ yếu hơn đồ đang mặc** (Lực chiến khi mặc thấp hơn hiện tại, mặc định bật). Đồ đang mặc không bao giờ bị lọc. Lưu lựa chọn bộ lọc trong save | Test SN-T3 |
| SN-11 | **Phân rã nhanh** (túi đồ, phím I): nút hiện số món khớp lọc và số Đá nhận được (*"Phân rã nhanh 7 món (+12 đá)"*); bấm → hộp xác nhận → phân rã tất cả. Bàn Tay Vàng vẫn tung Tinh Kim cho từng món | Test SN-T3 |
| SN-12 | **Bán nhanh** (cửa hàng, phím E ở làng/thành): cùng bộ lọc, nút *"Bán nhanh 7 món (+340 vàng)"* → xác nhận → bán tất cả | Test SN-T3; smoke `05f-shop` |
| SN-20 | **Chuyển cấp cường hoá khi mặc đồ**: mặc món mới vào ô đang có đồ, nếu đồ cũ có cấp cường hoá **cao hơn** đồ mới thì **đổi cấp** cho nhau (đồ mới nhận cấp của đồ cũ, đồ cũ nhận cấp của đồ mới — thường là +0). Đồ mới cấp cao hơn hoặc bằng thì giữ nguyên. Không tốn vàng/đá/Tinh Kim. Thông báo *"Chuyển +8 từ Kiếm Sắt sang Kiếm Tinh Luyện."* Chi tiết đồ trong túi ghi trước *"Mặc vào: nhận +8 từ đồ đang mặc"* và Lực chiến so sánh tính cả cấp được chuyển | Test SN-T4 |

Lý do "đổi cấp" thay vì "dồn cấp": người chơi không bao giờ mất cấp cường hoá (đồ cũ giữ cấp thấp hơn của đồ mới), và mặc lại đồ cũ thì cấp chuyển về đúng như cũ. Đây là cách các game ARPG di động phổ biến dùng (cường hoá gắn với ô trang bị) nhưng vẫn giữ cường hoá trên từng món như hệ thống M1.

### Phần C — Bản đồ khám phá (S6, S7)

| Mã | Yêu cầu | Tiêu chí nghiệm thu |
| --- | --- | --- |
| SN-30 | **Bản đồ rộng hơn**: mọi map (1-1, 1-3, 2-1, 2-2, 2-3) ×1,6 mỗi chiều; vị trí làng/trại, hang boss, dải cấp quái (`zone_x`) nhân theo. Quái thường tối đa = 16 × diện tích / (2.600 × 1.600), trần 40; cây, thảo dược, rương nhân theo diện tích | Test SN-T5; smoke `03-combat` |
| SN-31 | **Sương che**: map chia ô 64 px; ô chưa tới bị phủ tối (gần như đen), ô đã tới mở vĩnh viễn. Mở các ô trong bán kính 36 m quanh nhân vật (cập nhật 5 lần/giây). Mép sương mờ dần (vẽ bằng texture lọc tuyến tính). Vào map lần đầu mở sẵn vùng an toàn | Test SN-T5 |
| SN-32 | **% khám phá**: HUD (dòng tên map) ghi *"Khám phá 34%"*; bảng Lục địa (N) ghi % từng map. Thưởng 1 lần mỗi map: **50%** → +1 Đuốc; **90%** → +1 Tinh Hoa + 100 × vùng vàng (*"Khám phá trọn Rừng Sương!"*) | Test SN-T5 |
| SN-33 | **Save v7**: `fog` = {map_id: chuỗi base64 bitset ô đã mở}, `fog_rewards` = {map_id: [50, 90]}, `bulk_filter`. Save v6 nạp được (sương trống) | Test SN-T6 |

## 3. Thay đổi save (version 6 → 7)

| Trường | Kiểu | Mặc định khi nạp save cũ |
| --- | --- | --- |
| `fog` | {map_id: String base64} | {} — mọi map phủ sương, mở lại khi đi qua |
| `fog_rewards` | {map_id: Array[int]} | {} |
| `bulk_filter` | {rarities: Array, keep_plus, keep_set, only_weaker: bool} | Mặc định SN-10 |

Lớp `phap-su` không cần trường mới (`class_id` đã có từ v4).

## 4. Kiểm thử tự động cần có

| Mã | Kiểm |
| --- | --- |
| SN-T1 | Chỉ số Pháp Sư: Tấn công theo INT, HP thấp nhất 3 lớp, MP cao nhất; vũ khí tên Trượng |
| SN-T2 | Hỏa Cầu nổ lan; Lôi Xích nảy đủ 5 quái và dừng khi hết quái trong 15 m; Băng Ngục trói 2 giây; Thiên Thạch rơi sau 0,8 giây; Pháp Thuẫn hút sát thương rồi vỡ |
| SN-T3 | Bộ lọc: đúng phẩm chất, giữ đồ cường hoá, giữ đồ bộ, chỉ đồ yếu hơn; phân rã nhanh cộng đúng đá; bán nhanh cộng đúng vàng; đồ đang mặc không bị đụng |
| SN-T4 | Mặc đồ +0 thay đồ +8 → đồ mới +8, đồ cũ +0; mặc lại đồ cũ → cấp về như cũ; đồ mới +10 thay đồ +3 → giữ nguyên |
| SN-T5 | Map ×1,6; sương: ô quanh người chơi mở, ô xa còn phủ; % khám phá tăng; thưởng 50% / 90% đúng 1 lần |
| SN-T6 | Save v7 giữ sương, thưởng, bộ lọc; save v6 nạp được |
| TL-B, TL-B2 | Chạy thêm Pháp Sư (SN-07) |

## 5. Điểm cần duyệt

Đã chọn mặc định hợp thị trường; chủ dự án xem lại khi có thời gian.

| # | Câu hỏi | Mặc định đã chọn |
| --- | --- | --- |
| Q46 | 10 phép kết hợp Ngũ Hành của Pháp Sư (05 mục 5) làm luôn hay để Alpha? | Để Alpha (cần thêm cơ chế "nạp 2 hệ"); SN2 dùng Ngũ Hành kiểu Thợ Săn (đòn mang hệ + Bộc Phá) |
| Q47 | Chuyển cường hoá: đổi cấp (giữ cho cả 2 món) hay dồn cấp (đồ cũ về +0)? | Đổi cấp — không bao giờ mất cấp |
| Q48 | Bộ lọc mặc định có bật "Chỉ đồ yếu hơn đồ đang mặc"? | Bật — tránh lỡ tay phân rã đồ tốt |
| Q49 | Kích thước map ×1,6 mỗi chiều có vừa? | ×1,6 (chạy ngang map 1-1 ≈ 18 giây) |
| Q50 | Sương che có che quái ở vùng đã mở nhưng đang ngoài tầm nhìn? | Không — vùng đã mở thấy rõ (kiểu Diablo/Torchlight); chỉ vùng chưa tới bị che |

## 6. Kết quả

| Mã | Trạng thái | Ghi chú |
| --- | --- | --- |
| SN-01…04 | ✅ | `classes.gd` khối `phap-su`; `game_world.gd`: `_cast_fireball`, `_splash`, `_chain`, `_nova`, `_meteor`, `_update_mage`, Pháp Thuẫn trong `_damage_player`; `stats.gd`; vũ khí `style = "staff"` |
| SN-05 | 🟡 | Kiếm Tâm (Hỏa Cầu thứ 5), Ngũ Hành (Hỏa Cầu mang hệ, Bộc Phá theo Băng Ngục) chạy qua code chung. **Chưa làm**: Huyết Chiến/Hấp Huyết tính 50% từ phép diện rộng (05 mục 5) — hiện hút máu như lớp khác; 10 phép kết hợp để Alpha (Q46) |
| SN-06 | ✅ | AR-55 ([07](07-do-hoa-ke-hoach.md)); smoke `02-create`, `03c-mage` |
| SN-07 | ✅ | Xem bảng cân bằng dưới |
| SN-10…12 | ✅ | `ui/bulk_box.gd` dùng chung; túi đồ đánh dấu chấm đỏ món khớp lọc; smoke `05b-inventory`, `05f-shop` |
| SN-20 | ✅ | `Items.plus_after_equip`, `Items.equip`; chi tiết đồ báo *"Mặc vào: nhận +N từ đồ đang mặc"* |
| SN-30 | ✅ | `maps.gd` ×1,6; `GameWorld.area_factor()`, `field_mob_cap()` (1-1: 40 quái) |
| SN-31…33 | ✅ | `core/fog.gd`, `world_view.FogLayer`; HUD *"Khám phá N%"*, bảng N ghi % từng map; save v7 |

**Cân bằng (SN-07)** — bot, bộ đồ chuẩn, 20 Thiên phú mỗi lớp; trung bình giây hạ boss:

| Lớp | Sói Chúa (vùng 1, cấp 5) | F / S chênh | Huyền Ảnh (vùng 2, cấp 17) | F / S chênh |
| --- | --- | --- | --- | --- |
| Kiếm Khách | 30,1 | 5% | 46,3 | 9% |
| Thợ Săn | 34,4 | 5% | 40,4 | 20% |
| Pháp Sư | 30,2 | 8% | 45,6 | 9% |
| Lớp nhanh nhất / chậm nhất | chênh 12% | | chênh 13% | |

**Phát hiện:**

- **F1 — Thợ Săn quá mạnh ở cấp cao.** Đo sạch (không có quái thường) trước khi sửa: vùng 2 Thợ Săn 32,1 giây, 2 lớp kia ≈ 46 giây (chênh 31%). Nguyên nhân: mỗi điểm AGI cho cả +2 Tấn công, +1% tốc đánh, +0,5% chí mạng — ở 48 AGI gộp lại vượt xa STR/INT. Thử giảm Tấn công/AGI còn 1,5 thì vùng 1 Thợ Săn tụt 32 → 53 giây (Tấn công cấp thấp sát Phòng thủ Sói Chúa); chọn giảm **tốc đánh/AGI của Thợ Săn còn 0,6%** — gần như không đổi vùng 1, kéo vùng 2 về 40 giây.
- **F2 — Test cân bằng nhiễu theo RNG.** Map to hơn → nhiều quái hơn → thứ tự gọi RNG đổi → Ngũ Hành Linh Căn của Thợ Săn dao động 25–37 giây giữa 2 lần chạy. TL-B2 nay đánh 4 trận mỗi tổ hợp và tắt sinh quái thường (D32); thời gian chạy TL-B + TL-B2 còn 1 phút 23 giây (trước > 10 phút).
- **F3 — Thưởng khám phá chỉ kiểm khi người chơi mở ô mới.** Sửa: kiểm mỗi khi sương đổi (`fog.version`).

**Kiểm thử:** 82 test (thêm SN-T1…T6), smoke 21 ảnh (thêm `03c-mage`).
