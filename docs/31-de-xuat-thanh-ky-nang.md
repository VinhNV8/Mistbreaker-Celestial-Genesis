# Đề xuất: thanh kỹ năng khi có nhiều kỹ năng (Spec_Notes đợt 12)

| | |
| --- | --- |
| Dự án | Thiên Phú Khai Giới |
| Nguồn | [Spec_Notes.md](Spec_Notes.md) (chủ dự án, 01/11/2026) |
| Loại tài liệu | Đề xuất + đặc tả + kết quả |
| Trạng thái | ✅ Đã làm (01/11/2026) — chủ dự án chọn **phương án A + cả 4 tiện ích**; save v27, test SN12-T1, SN12-T2 |

## 1. Ghi chú của chủ dự án

| Mã | Ghi chú | Cách hiểu |
| --- | --- | --- |
| SN12-01 | *"Bình HP đang bị giới hạn 5 Bình, bỏ giới hạn đi giống MP."* | Bỏ trần 5 bình máu — **đã làm** (xem mục 5) |
| SN12-02 | *"Các kỹ năng mở mới thì làm thế nào để sử dụng, trong khi thanh kỹ năng ở màn hình game đang chỉ có giới hạn vài skills? — Đề xuất giải pháp"* | Đề xuất cách dùng nhiều kỹ năng hơn số ô trên thanh |

## 2. Hiện trạng

| Hạng mục | Hiện tại |
| --- | --- |
| Ô kỹ năng | **4 ô** (phím 1–4), ngoài ra J đánh thường, Space né, L Thiên phú, Q bình máu, F bình MP |
| Kỹ năng mỗi lớp | 14: 6 kỹ năng lớp (mở cấp 1–20) · 2 chuyển chức 1 · 1 Tối thượng (cấp 45) · 4 nhánh chuyển chức 2 (chỉ dùng 2 của nhánh đã chọn, cấp 60) · 1 Thần Kỹ (chức 3, cấp 90) → **dùng được 12 kỹ năng** cuối game |
| Đổi kỹ năng | Bảng Kỹ năng (U) → chọn kỹ năng → bấm ô 1–4. **Chỉ đổi được ở vùng an toàn** (làng, trại, thành) |
| Khi mở kỹ năng mới | Không báo, không tự lắp. Ô 3–4 lúc đầu hiện kỹ năng chưa mở ("Cấp 4", "Cấp 8") |

Vấn đề: người chơi không biết có kỹ năng mới; chỉ dùng được 4/12; muốn đổi phải về làng.

## 3. Các phương án

### A. Thêm ô theo tiến trình + ô Tuyệt kỹ riêng (khuyên dùng) — ✅ ĐÃ CHỌN

| Ô | Phím | Mở khi |
| --- | --- | --- |
| 1–4 | 1–4 | như hiện tại |
| 5 | 5 | Chuyển chức 1 (cấp 30) |
| 6 | 6 | Chuyển chức 2 (cấp 60) |
| **Tuyệt kỹ** (ô lớn, viền vàng) | G | Cấp 45 — chỉ lắp Tối thượng hoặc Thần Kỹ |

- Cuối game dùng cùng lúc **7 / 12** kỹ năng — vẫn phải chọn build (giữ chiều sâu), nhưng mỗi mốc chuyển chức có chỗ cho kỹ năng mới.
- Đầu game (cấp 1–29) **không đổi gì** → cân bằng chương 1–3 giữ nguyên; các trận từ cấp 30 trở lên phải đo lại cân bằng (bot dùng thêm ô).
- Thanh kỹ năng: 9 ô hiện tại + 3 ô ≈ 760 px, vừa màn hình 1366.

### B. Hai thanh kỹ năng (8 ô), phím X đổi thanh

- Thanh 1 và thanh 2, mỗi thanh 4 ô, phím X chuyển (kiểu game nhập vai di động).
- Dùng được 8 kỹ năng; nhưng giữa trận phải bấm đổi thanh → khó với bàn phím, dễ nhầm.

### C. Giữ 4 ô, chỉ làm tiện hơn

- Không thêm ô; thêm các tiện ích mục 4. Ít thay đổi nhất, cân bằng giữ nguyên; nhưng vẫn chỉ 4/12 kỹ năng.

## 4. Tiện ích đi kèm (dùng được với cả A, B, C)

| Mã | Tiện ích |
| --- | --- |
| Q1 | **Báo kỹ năng mới**: mở kỹ năng → chữ giữa màn hình "Kỹ năng mới: …" + dòng nhật ký "Nhấn U để lắp"; ô trống thì **tự lắp** |
| Q2 | **Đổi ô ở mọi nơi khi ngoài giao tranh** (không đánh / bị đánh trong 5 giây), thay vì chỉ ở vùng an toàn |
| Q3 | **Kéo – thả** kỹ năng từ bảng Kỹ năng vào ô; nhấp chuột phải ô trên thanh → danh sách chọn nhanh |
| Q4 | **2 bộ kỹ năng đã lưu** (Bộ đánh quái / Bộ đánh boss), đổi bằng 1 nút ngoài giao tranh |
| Q5 | Ô chưa mở hiện ổ khoá + "Cấp N" (như hiện tại); ô 5 / 6 / Tuyệt kỹ chưa mở thì ẩn |

## 5. SN12-01 — bình máu không giới hạn (đã làm, 01/11/2026)

- Bỏ trần 5 bình: mua ở cửa hàng, chế từ thảo dược (đủ 2 thảo dược tự chế 1 bình, không còn dừng ở 5), thưởng nhiệm vụ, thưởng chương 3.
- Cửa hàng: thẻ Bình máu "Mang bao nhiêu cũng được", nút Tối đa = số mua được bằng vàng (trần 99 mỗi lần), thanh tiền bỏ "(tối đa 5)". Mục Tài nguyên cập nhật.
- Code: bỏ `GameWorld.POTION_MAX`; `_brew_potions`, `shop_buy("potion")`, phần thưởng (`game_world.gd`, `chapter3.gd`), `ShopPanel._supply_rows`, `Resources`. Không đổi save.
- Test: C1-T10 (mua bình thứ 6), UI-24 (nút Tối đa theo vàng, 50 bình vẫn mua được, hết vàng thì khoá).

## 6. SN12-02 — kết quả (phương án A + Q1–Q4, 01/11/2026)

| Mã | Đã làm |
| --- | --- |
| A | **7 ô**: 1–4 (như cũ) · **5** mở khi chuyển chức 1 · **6** mở khi chuyển chức 2 · **Tuyệt kỹ (G)** mở ở cấp 45, chỉ lắp Tối thượng / Thần Kỹ. Ô chưa mở **ẩn** trên thanh (đầu game thanh giữ nguyên 4 ô); ô đã mở mà trống hiện "+"; ô G to hơn, viền vàng sáng. Bộ mặc định: 4 kỹ năng đầu + 3 ô trống |
| Q1 | Kỹ năng vừa mở (lên cấp, chuyển chức 1 / 2 / 3, cấp 45): chữ vàng lớn "Kỹ năng mới: …" trên đầu nhân vật + nhật ký. Chưa lắp thì **tự lắp** vào ô trống (Tối thượng / Thần Kỹ ưu tiên ô G); hết ô thì nhắc "phím U, kéo kỹ năng vào ô". Mở thêm ô cũng báo. Lúc nạp save không báo lại |
| Q2 | Đổi ô / đổi bộ ở **vùng an toàn** hoặc **bất cứ đâu khi 5 giây không đánh trúng / bị đánh** (đòn né được không tính). Tẩy điểm và biến thể vẫn chỉ ở vùng an toàn. *SN14-02 (02/11): trong bảng Kỹ năng (game dừng) luôn đổi được; khoá 5 giây chỉ cho phím X / menu chuột phải trên HUD* |
| Q3 | Bảng Kỹ năng: **kéo** ô kỹ năng trên cây **thả** vào hàng "Thanh kỹ năng" ở chân bảng (7 ô; nhấp trái chọn kỹ năng, chuột phải bỏ trống). Thanh kỹ năng HUD: **chuột phải** một ô → menu chọn nhanh (kỹ năng đã mở lắp được vào ô đó, "Bỏ trống ô"); cũng nhận thả kỹ năng. Nút "Lắp vào ô" trong cột chi tiết có đủ 7 nút (ô khoá có tooltip lý do) |
| Q4 | **2 bộ kỹ năng**: phím **X** hoặc nút "⇄ Bộ 2 (X)" ở chân bảng. Lần đầu đổi: Bộ 2 chép Bộ 1 để chỉnh. Mỗi bộ nhớ riêng 7 ô |
| — | Hồi chiêu **đi theo kỹ năng**: rời ô (đổi ô, bỏ trống, đổi bộ) rồi lắp lại vẫn còn đúng thời gian — không lách hồi chiêu bằng cách đổi |

**Phím:** 5, 6, G, X (bảng Trợ giúp có thêm 2 dòng). **Save v27:** `loadout` 7 phần tử ("" = trống; save cũ 4 ô được thêm 3 ô trống), `loadout_alt`, `loadout_set`.

**Cân bằng:** đầu game không đổi. Đo SN12-T3 (01/11/2026) — Viêm Long cấp 60, 2 seed, bộ 4 ô so với bộ 7 ô (thêm chuyển chức 1, nhánh chuyển chức 2, Tối thượng):

| Lớp | 4 ô | 7 ô | Nhanh hơn |
| --- | --- | --- | --- |
| Kiếm Khách | 35,4 giây | 35,3 giây | 0% |
| Thợ Săn | 32,8 | 31,7 | 3% |
| Pháp Sư | 25,4 | 28,9 | −12% (chậm hơn: MP chia cho kỹ năng yếu hơn) |
| Hộ Vệ | 35,0 | 34,3 | 2% |
| Triệu Hồi Sư | 37,0 | 31,1 | 19% |

MP là giới hạn chính → thêm ô **không làm trận dễ hẳn**, không cần tăng máu boss. Lợi ích chính của 7 ô là linh hoạt (đổi bộ, dùng kỹ năng hỗ trợ / né). Test SN12-T3 giữ: 7 ô không chết, không nhanh hơn 4 ô quá 25%.

Code: `Classes.SKILL_SLOTS` 7, `BASE_SLOTS`, `SLOT_ULT`, `ULT_SLOT_LEVEL`, `SLOT_KEYS`, `is_ult()`, `default_loadout()`; `GameWorld.slot_open / open_slot_count / slot_accepts / can_change_loadout / swap_loadout / _valid_loadout / _apply_loadout / _snapshot_skills / _check_new_skills / _on_new_skill`, hằng `COMBAT_LOCK` 5 (dùng mốc `_last_combat` có sẵn); `Profile.loadout_alt / loadout_set` (v27); `SkillBar` khoá `hidden / big / empty`, tín hiệu `slot_menu / skill_dropped`, `accept_drop`; `Hud.SLOT_SKILL0 / BAR_COUNT / loadout_slot`, `PopupMenu` "SlotMenu"; `SkillPanel.LoadoutSlot`, `_loadout_bar`, `SkillNode.drag_id`; `main.gd` hành động `skill_5 / skill_6 / skill_7 / swap_loadout`.

## SN14 — Spec_Notes 02/11/2026 (done 02/11/2026)

| Mã | Ghi chú | Nguyên nhân / đã làm |
| --- | --- | --- |
| SN14-01 | "Thiên phú hút máu đang bị cấm sử dụng bình máu → bỏ hạn chế" | Bỏ khoá ở `GameWorld.drink_potion` và ô Q "Khoá" trên HUD; mô tả Thiên phú bỏ vế "không dùng được bình máu". Áp dụng cả khi Hấp Huyết là Thiên phú phụ. Test TL-C, TP5-T2 sửa theo |
| SN14-02 | "Không thay đổi được kỹ năng đang sử dụng thành kỹ năng mới" | **Nguyên nhân:** khoá đổi ô khi giao tranh (Q2: 5 giây không đánh / bị đánh) — nhưng mở bảng Kỹ năng (U) thì game **dừng**, đồng hồ giao tranh không chạy → mở bảng trong 5 giây sau trận thì nút "Lắp vào ô", kéo-thả, đổi bộ bị khoá suốt. **Sửa:** mọi thao tác trong bảng Kỹ năng (nút Lắp vào ô, kéo vào hàng Thanh kỹ năng / thanh HUD, chuột phải bỏ trống, nút đổi bộ) **luôn được** — `can_change_loadout(in_menu)`, `set_slot(…, in_menu)`, `swap_loadout(in_menu)`. Khoá 5 giây chỉ còn cho phím X và menu chuột phải trên thanh HUD lúc game đang chạy. Hồi chiêu vẫn đi theo kỹ năng nên không lách được. Bỏ dòng nhắc viết nhầm "Biến thể: ở vùng an toàn". Test SN12-T1 thêm 2 kiểm |
