# Spec_Notes đợt 9 — 9 việc còn lại

| | |
| --- | --- |
| Dự án | Thiên Phú Khai Giới |
| Nguồn | [Spec_Notes.md](Spec_Notes.md) (các dòng chưa làm sau UI-22, UI-24, UI-25) — chủ dự án 28/10/2026: *"Triển khai các công việc chưa làm trong spec_notes"* |
| Loại tài liệu | Đặc tả + kết quả. Những chỗ ghi chú hỏi "đề xuất" dùng phương án ở cột **Quyết định** (Q153–Q160, mục 3) — chủ dự án sửa được |
| Phiên | game-ca |
| Trạng thái | ✅ **Xong 28/10/2026** (phiên game-ca, chưa commit theo yêu cầu chủ dự án) — xem mục 4 |

## 1. Yêu cầu

| Mã | Ghi chú của chủ dự án | Yêu cầu | Test |
| --- | --- | --- | --- |
| SN9-01 | *"Hiển thị Tên nhân vật + Chức nghiệp hiện tại. Ví dụ: Anh Vinh Đẹp Zai - Kiếm đồ"* | Khung nhân vật (góc trái trên): biển tên ghi **"Tên · Chức"** (chức = `Classes.title` theo lớp + chức 1/2/3, ví dụ "Lâm Phong · Kiếm Sư"), một dòng, tự thu cỡ chữ. Chữ trên đầu nhân vật: tên (trắng) + dòng nhỏ chức nghiệp (màu lớp) | SN9-T1 |
| SN9-02 | *"Có thể tạo tối đa 5 nhân vật… đề xuất xem có cần giới hạn gì không"* | **5 ô nhân vật** trên một máy. Màn tiêu đề: "Chọn nhân vật" (mở màn danh sách) + "Tiếp tục" (vào ngay nhân vật chơi gần nhất). Màn danh sách: 5 thẻ — thẻ có nhân vật hiện chân dung lớp, tên, "Lv N · Chức", Thiên phú (hạng + tên), thời gian chơi, nút **Vào game** và **Xoá** (hỏi xác nhận, gõ lại tên); thẻ trống ghi "+ Tạo nhân vật mới". Hết ô thì phải xoá một nhân vật. Mỗi ô một file (`user://save.json` cho ô 1 — giữ save cũ, `save_2.json`…`save_5.json`); ô chơi gần nhất lưu ở `user://slots.cfg`. **Giới hạn** (Q153): tên nhân vật không trùng giữa các ô; mã quà tặng dùng một lần cho cả máy (đã vậy — `redeemed_codes.cfg`); mỗi nhân vật có lãnh địa, túi đồ riêng (chưa có kho chung) | SN9-T2 |
| SN9-03 | *"Sát thương lên quái phải có dấu trừ (-)… Sát thương khác thường thì màu phải khác"* | Số sát thương lên quái ghi **"−50"**; chí mạng **"−120!"** to hơn. Màu theo loại (bảng mục 2.1). Đòn **khắc hệ** có thêm chữ nhỏ "Khắc" lần đầu trong 1 giây | SN9-T3 |
| SN9-04 | *"Tuần thú sư: quái (thú) phải phi ra đầu tiên tiếp cận quái vật khi nhìn thấy trong phạm vi…"* | Thú cưng, lính bóng tối, Xương Nô (đồng minh cận chiến): **tầm phát hiện 32 m quanh người chơi** (26 m cũ), chạy **×1,4 tốc người chơi**, lao vào quái **trước**. Khi **Tự đánh** và còn đồng minh cận chiến sống: nhân vật **chờ** cho tới khi đồng minh đã áp sát mục tiêu (≤ 4 m) hoặc quái tự lao tới gần nhân vật (≤ 10 m) — rồi mới vào đánh. Lớp đánh xa vẫn giữ khoảng cách như cũ. Linh thú Triệu Hồi Sư giữ hành vi riêng (Classes2) | SN9-T4 |
| SN9-05 | *"EXP khi đánh quái vượt cấp tăng thêm, thấp hơn thì giảm?"* | Thay 2 bậc cũ (≥ +5: ×2, ≤ −10: 10%) bằng **bảng mượt** (mục 2.2). Mốc ≥ +5 giữ ×2 (Thử thách vượt ải của kịch bản, BD-09); quái thấp hơn từ 10 cấp giữ 10% (NV-25). Màu cấp trên bảng tên quái (UI-15) đã báo quái "đáng" hay "rẻ" EXP | SN9-T5 |
| SN9-06 | *"Quái trong 1 bản đồ có nên chia khu vực theo cấp… bãi quái cấp 1, bãi quái cấp 2…?"* | **Bãi quái theo cấp** (Q156): mỗi map chia dải cấp (từ trái sang phải như hiện nay) thành **bãi**: mỗi cấp trong `levels` của map 1 bãi (map cấp 1–6 → 6 bãi), tâm bãi đặt dọc theo trục cấp, bán kính 9–14 m, tránh vùng an toàn / hang boss / cổng. Quái sinh **75% trong bãi** (cấp = cấp bãi, 80% là loại quái của bãi), 25% rải ngoài như cũ (cấp theo vị trí); **mỗi bãi tối đa 6 quái** — quá thì quái đó rải ngoài, quái rải không rơi vào bãi đã đủ. Bản đồ nhỏ hiện chấm bãi + số cấp; bước vào bãi lần đầu: chữ nổi "Bãi Sói Sương · Lv3" | SN9-T6 |
| SN9-07 | *"Khi cường hoá thì thuộc tính cơ bản giữ nguyên, điểm cộng thêm hiển thị. Ví dụ: 9 + 15 Tấn công (gốc)"* | Mọi nơi hiện chỉ số gốc của món đồ (chi tiết Túi đồ, Lò Rèn, Cửa hàng): **"+9 + 15 Tấn công (gốc)"** — phần cường hoá màu xanh lá; đồ +0 chỉ "+9 Tấn công (gốc)". Hàm chung `Items.base_text(item, plus)` | SN9-T7 |
| SN9-08 | *"Khi nhân vật tăng cấp, máu và các thuộc tính khác được tăng thêm như thế nào"* | Lên cấp: nhật ký ghi **"Lên cấp N! HP +15 · Tấn công +2 · Phòng thủ +1,5 · MP +5 · +5 điểm tiềm năng, +1 Điểm Kỹ Năng"** (số tính bằng `Stats.derive` trước/sau, cùng điểm đang có). Biểu ngữ lên cấp thêm dòng phụ HP/Tấn công | SN9-T8 |
| SN9-09 | *"Khi focus vào đánh quái, cần hiển thị đang focus vào quái nào: avatar, thanh máu… nghiên cứu và đề xuất"* | **Khung mục tiêu** (như Diablo Immortal, Lost Ark, MU): ở giữa trên, dưới thanh tài nguyên. Mục tiêu = quái người chơi vừa đánh trúng hoặc đang khoá (soft-lock) trong 6 giây gần nhất, hoặc quái đang rê chuột. Gồm **chân dung** (hình quái trong khung tròn, viền màu theo loại), **tên + loại + cấp** (màu cấp như UI-15), biểu tượng hệ, **thanh máu** + số "HP / tối đa" + %, **thanh Phá Thế** (tinh anh), hàng **trạng thái** (Choáng, Chậm, Thiêu, Độc, Trói). Quái đang có **vòng đánh dấu** dưới chân (elip vàng). Ẩn khi mục tiêu chết / ra xa > 45 m / quá 6 giây không đánh. Khi đánh boss: thanh boss có sẵn thay cho khung này | SN9-T9 |

## 2. Số liệu

### 2.1. Màu số sát thương lên quái (SN9-03)

| Loại | Ví dụ | Màu |
| --- | --- | --- |
| Đánh thường / kỹ năng | −50 | Trắng |
| Chí mạng | −120! (to) | Vàng #ffc940 |
| Khắc hệ (+30%) | −65 | Cam #ff9a3c |
| Sát thương theo thời gian (thiêu, độc, vùng kéo dài) | −12 | Cam đỏ (thiêu) / xanh lá (độc) — theo nguồn; không rõ nguồn: hồng #ff8fa3 |
| Đồng minh, thú cưng, linh thú | −30 | Tím #c9b6ff |
| Bị khiên chặn | "Chặn!" + −15 | Xám |

### 2.2. EXP theo chênh cấp (SN9-05) — chênh = cấp quái − cấp người chơi

| Chênh | ≤ −10 | −9 | −8 | −7 | −6 | −5 | −4 | −3 … +0 | +1 | +2 | +3 | +4 | ≥ +5 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Hệ số | 0,1 | 0,25 | 0,4 | 0,55 | 0,7 | 0,8 | 0,9 | 1,0 | 1,05 | 1,1 | 1,15 | 1,2 | 2,0 |

Áp cho quái thường, tinh anh, boss hiếm (boss chương dùng EXP riêng, không đổi).

## 3. Quyết định đã chọn (chủ dự án có thể đổi)

| # | Câu hỏi | Quyết định |
| --- | --- | --- |
| Q153 | Giới hạn khi có 5 nhân vật | Tên không trùng giữa các ô; mã quà tặng 1 lần cho cả máy; không có kho chung / chuyển đồ giữa nhân vật (để khi có tài khoản online); Đạo Tặc "độc nhất server" vẫn tính theo từng nhân vật vì chưa có server |
| Q154 | Xoá nhân vật | Hỏi xác nhận + gõ lại tên; không khôi phục được |
| Q155 | Tự đánh có thú: nhân vật chờ thú vào trước? | Có (chỉ khi Tự đánh). Điều khiển tay thì người chơi tự quyết |
| Q156 | Bãi quái cố định theo cấp hay ngẫu nhiên? | **Cố định** theo cấp (dễ hiểu, người chơi tìm đúng bãi để cày) + 25% quái rải ngoài bãi |
| Q157 | EXP vượt cấp | Bảng mượt mục 2.2, giữ 2 mốc kịch bản (+5 → ×2, −10 → 10%) |
| Q158 | Khung mục tiêu: chọn mục tiêu thế nào | Tự động (vừa đánh trúng / khoá / rê chuột), không cần phím; Tab chuyển mục tiêu để sau |
| Q159 | Có cần số "HP / tối đa" trên khung mục tiêu? | Có, kèm % |
| Q160 | Save | Không đổi version (ô nhân vật là file riêng); `slots.cfg` mới |

## 4. Kết quả

| Mã | Trạng thái | Ghi chú kỹ thuật |
| --- | --- | --- |
| SN9-01 | ✅ | `char_frame.gd` biển tên 2 màu (tên vàng · chức tím, tự thu cỡ); `hud.gd` truyền `title` = `Classes.title(lớp, job, job2, job3)`; `world_view.gd` tên + dòng chức trên đầu |
| SN9-02 | ✅ | `save_system.gd` ô nhân vật (D60); `screens.gd` `slots()`; `main.gd` `_open_slots`, `_play_slot`, `_ask_delete_slot` (gõ lại tên), `_continue_last`, `_on_new_game` (ô trống đầu, đủ 5 thì báo), kiểm tên trùng ở `_on_hero_created`. Smoke `00-slots` |
| SN9-03 | ✅ | `_apply_damage(…, kind)` + `DMG_COLORS` (D62); khắc hệ dò ở `_hit_enemy` (Ngũ Hành hoặc biến thể hệ khắc hệ quái); thiêu/chảy máu `burn`, Tên Độc/Đuôi Sa Hoàng `poison` |
| SN9-04 | ✅ | `ALLY_RANGE` 260 → 320, `PET_SPEED` 320 cho đồng minh cận chiến (linh thú Triệu Hồi Sư giữ `ALLY_SPEED` 210 — không đổi cân bằng LH2); đồng minh đánh cùng mục tiêu người chơi vừa đánh; `_pet_should_lead` trong `_auto_input` |
| SN9-05 | ✅ | `EXP_GAP_UP` / `EXP_GAP_DOWN` trong `exp_level_mult` |
| SN9-06 | ✅ | `_build_camps`, `_camp_kind`, `camp_at`, `_camp_count`, `_update_camps` (D61); bản đồ nhỏ vẽ vòng + số cấp |
| SN9-07 | ✅ | `Items.base_text(item, plus)` dùng ở Túi đồ (chi tiết + dòng cường hoá kế), Lò Rèn, Cửa hàng |
| SN9-08 | ✅ | `GameWorld.level_growth_text` → nhật ký + dòng phụ biểu ngữ (`hud.banner(text, sub)`) |
| SN9-09 | ✅ | `ui/target_frame.gd`; `GameWorld.focus` (`_compute_focus`: rê chuột → quái vừa đánh trong 6 giây); `main.gd` đặt `hover_pos`; vòng vàng dưới chân trong `world_view._draw_enemy_overlay` |

**Đổi so với spec (sau khi chạy test):**

| Mục | Spec | Đã làm | Lý do |
| --- | --- | --- | --- |
| SN9-05 | "+N EXP (×1,2)" | Bỏ chữ hệ số | Màu cấp trên bảng tên quái đã báo |
| SN9-05 | Vượt cấp +1…+4: ×1,1…×1,5; thấp hơn −3: ×0,85 | +1…+4: ×1,05…×1,2; 0…−3 vẫn ×1,0 (bảng mục 2.2) | Cùng bãi quái, bản đầu làm bot cày cấp 1 → 5 nhanh hơn ~30% |
| SN9-06 | Không giới hạn số quái / bãi | **Tối đa 6 quái mỗi bãi**; quái rải không đứng trong bãi đầy | Ảnh smoke vùng 3: hơn chục quái dồn một chỗ |
| SN9-06 | Tránh vùng an toàn / hang boss / cổng | Tránh thêm **mọi danh sách toạ độ của map** (đèn, lửa trại, Đá Neo, trụ…) ≥ 45 m ngoài mép bãi | Test C6-T5: bãi cạnh Đèn Cực Quang làm nhân vật bị đánh gục khi đứng thắp đèn |
| SN9-06 | — | Dời quái vào bãi bằng RNG riêng; chữ nổi mới không lệch ngẫu nhiên (`_note`) | Bãi + chữ mới làm lệch chuỗi ngẫu nhiên của trận đánh → TL-B, TL-B4, SK2-T4 (vốn sát ngưỡng 23%) lệch qua 25%. Sau khi tách RNG, TL-B về 22% |

**Kiểm thử:** SN9-T2 (5 ô), SN9-T3…T5/T8/T9, SN9-T6/T7 qua; smoke 55 ảnh, `boss_defeated=true`, 0 `SCRIPT ERROR` (ảnh `00-slots`, `03-combat` có khung mục tiêu + dòng lên cấp, `05c` có "+24 + 24 Tấn công (gốc)").

**Ảnh hưởng nhịp lên cấp** (bot M1-12 cày cấp 1 → 5 ở Rừng Sương rồi đánh Sói Chúa, 5 seed):

| | Bản cuối (bãi quái, trần 6, RNG riêng) — seed 13 / 11 / 12 | Trước SN9 (seed 13) |
| --- | --- | --- |
| Cày tới cấp 5 | 651 / 685 / 744 giây (trung bình 693) | 905 giây |
| Hạ boss | 24,2 / 20,9 / 21,5 giây (trung bình 22,2) | 31,2 giây |

Bãi quái làm cày nhanh hơn (quái tập trung, đỡ đi lại) — cấp 5 ở phút ~11,5, vẫn trong mục tiêu kịch bản (phút 10–15). Test M1-12 đổi sang **trung bình 3 seed** (1 seed dao động 16–33 giây theo đồ rơi), ngưỡng > 20 giây giữ nguyên. Nên chạy lại `--only=PACE` khi cân nhịp lần tới.
