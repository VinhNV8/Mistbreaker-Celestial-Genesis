# 47. Đề xuất thêm cách tăng Lực chiến cho trang bị (NL-1)

| Mục | Nội dung |
| --- | --- |
| Ngày | 09/11/2026 |
| Yêu cầu | [Spec_Notes](Spec_Notes.md) 09/11: *"Người chơi nói — Ngoài việc nâng cấp đồ thì cần thêm các hình thức khác để nâng lực chiến cho đồ → hãy đề xuất giải pháp giúp tôi."* |
| Mã yêu cầu | `NL-` (Nâng Lực) — đã kiểm tra chưa bị dùng |
| Trạng thái | ✅ **Đã làm 09/11/2026** — chủ dự án: "triển khai theo đề xuất" → làm cả 6 đường, P1 → P3, Q229–Q236 theo cột Đề xuất §8. Kết quả §9 |
| Ảnh | [design/nl1/](design/nl1/): `ngoc-ngu-hanh.png` (icon ngọc), `nl1-*.png` (Lò Rèn trong game, thẻ đồ) |

## 1. Hiện trạng

Một món đồ hiện chỉ mạnh lên theo **một đường duy nhất**: cường hoá.

| Thành phần của món | Người chơi tác động được không? | Ghi chú |
| --- | --- | --- |
| Chỉ số gốc (`a + b·L` × hệ số phẩm chất) | Chỉ qua **cường hoá** +0 → +15 (mỗi cấp +10% chỉ số gốc) | EQ-12, [03 §3.5](03-mvp-spec.md) |
| Dòng phụ (affix) 0–4 dòng | ❌ Rơi ra thế nào giữ thế ấy | Giá trị ×0,8–1,2 ngẫu nhiên, cường hoá không ảnh hưởng |
| Phẩm chất (Trắng → Cam) | ❌ | Muốn tốt hơn chỉ có cách nhặt món khác |
| Cấp đồ L | ❌ | Đồ Cam boss chương 1 (Nanh Sói Chúa) bị bỏ sau vài vùng |
| Đồ bộ 9 vùng (2/4/6 món) | Chỉ bằng cách gom đủ món | — |
| Hệ của đòn đánh | Chỉ Thiên phú Ngũ Hành Linh Căn đổi được | Kịch bản mục 8 đã hẹn **khảm ngọc ngũ hành** nhưng chưa làm (Q40 để sau MVP) |

Hệ quả người chơi cảm thấy:

1. **Hết việc để làm với món đồ đẹp.** Đồ +15 rồi thì chỉ còn cách chờ món mới rơi.
2. **Rơi món "gần đúng" là vô dụng.** Món Tím có 3 dòng nhưng 1 dòng sai (vd Kháng Thổ trên đồ của Kiếm Khách đánh vùng Hỏa) — không sửa được, chỉ phân rã.
3. **Tài nguyên thừa** sau giữa game: Tinh Thạch, Thiên Phú Tinh Hoa, vàng không có chỗ tiêu ổn định cho trang bị.
4. **Đồ trùng ô** chỉ để phân rã → ra Đá Cường Hoá → lại quay về đúng một đường cường hoá.

## 2. Game khác làm thế nào

| Cách | Game tiêu biểu | Ý chính |
| --- | --- | --- |
| Khảm ngọc / socket | Diablo, MU, Võ Lâm, Lost Ark | Lỗ trên đồ, ngọc tháo lắp được, ghép ngọc cấp cao |
| Tẩy luyện / rèn lại dòng | Diablo 3 (Enchant), PoE (Orb), Lineage | Đổi 1 dòng phụ, giữ phần còn lại — sửa món "gần đúng" |
| Thăng phẩm | Genshin (ascend), MU (Excellent), các game Trung Quốc | Hút đồ trùng để nâng phẩm chất món chính |
| Thăng cấp đồ yêu thích | Genshin, Lost Ark (honing tiers) | Món cũ theo kịp cấp nhân vật |
| Thức tỉnh / Ấn ký | Black Desert, Dragon Nest, Ragnarok | Dòng đặc biệt gắn lối chơi / lớp, mở ở cuối game |
| Bộ sưu tập (đồ giám) | Lineage 2M, Ragnarok M, Black Desert | Ghi danh món đã sở hữu → cộng chỉ số vĩnh viễn nhỏ |

Điểm chung ở các game được khen: **mỗi đường có một vai trò riêng**, không phải 6 cách cùng "+% tấn công"; **không phạt nặng khi thất bại** (đúng nguyên tắc của dự án ở EQ-12); và **giữ được công sức** khi đổi đồ.

## 3. Đề xuất: 6 đường nâng Lực chiến

Mỗi đường giải đúng một vấn đề ở §1. Đề xuất làm theo 3 đợt (§6).

| # | Tên | Giải vấn đề | Tiền tiêu | Mở khi | Đợt |
| --- | --- | --- | --- | --- | --- |
| A | **Khảm Ngọc Ngũ Hành** | Hết việc với đồ +15; đòn đánh không đổi hệ được | Ngọc (rơi theo hệ quái), vàng | Chương 2 | P1 |
| B | **Tẩy Luyện dòng phụ** | Món "gần đúng" vô dụng | Vàng, Tinh Thạch, Tinh Kim | Chương 3 | P1 |
| C | **Thăng Phẩm** | Đồ trùng ô chỉ để phân rã | Món cùng ô, Tinh Thạch, vàng | Chương 4 | P2 |
| D | **Luyện Cấp đồ Cam / đồ bộ** | Đồ yêu thích bị bỏ | Tinh Kim, vàng | Chương 3 | P2 |
| E | **Thức Tỉnh trang bị** | Cuối game thiếu mục tiêu theo lối chơi | Thiên Phú Tinh Hoa, Lõi Hư Vô | Chuyển chức 3 | P3 |
| F | **Bảo Giám (sưu tập)** | Đồ đã bỏ không còn giá trị gì | Không tốn — chỉ cần từng sở hữu | Chương 1 | P3 |

### 3.A. Khảm Ngọc Ngũ Hành (NL-A)

Đúng như kịch bản mục 8 *"Khảm ngọc: ngọc ngũ hành, đổi hệ vũ khí để khắc boss"*.

**Lỗ ngọc theo phẩm chất**

| Trắng | Xanh lá | Xanh dương | Tím / đồ bộ | Cam |
| --- | --- | --- | --- | --- |
| 0 | 1 | 1 | 2 | 3 |

**Đục lỗ**: thêm 1 lỗ (tối đa 3) ở Lò Rèn — 1 Tinh Kim + 500 × (số lỗ đang có + 1) vàng; luôn thành công.

**5 loại ngọc**, mỗi loại một vai trò (theo tính chất ngũ hành):

| Ngọc | Chỉ số chính | Trên đồ phòng thủ (mũ, áo, giày, dây chuyền, bùa) cộng thêm |
| --- | --- | --- |
| Kim (Bạch Ngọc) | Tấn công | Kháng Kim |
| Mộc (Bích Ngọc) | HP | Kháng Mộc |
| Thủy (Lam Ngọc) | Tốc đánh | Kháng Thủy |
| Hỏa (Hồng Ngọc) | Sát thương chí mạng | Kháng Hỏa |
| Thổ (Hoàng Ngọc) | Phòng thủ | Kháng Thổ |

**Cấp ngọc 1 → 10.** Ghép **3 viên cùng loại cùng cấp → 1 viên cấp sau**, luôn thành công (Lò Rèn tab Khảm ngọc, có nút "Ghép tất cả"). Giá trị đề xuất (chỉnh ở `data/gems.gd`):

| Ngọc | Cấp 1 | Cấp 5 | Cấp 10 |
| --- | --- | --- | --- |
| Kim: Tấn công | +2 | +16 | +42 |
| Mộc: HP | +25 | +155 | +420 |
| Thủy: Tốc đánh | +0,6% | +3% | +6% |
| Hỏa: ST chí mạng | +1,5% | +7% | +14% |
| Thổ: Phòng thủ | +3 | +18 | +52 |
| Kháng hệ (đồ phòng thủ) | +0,5% | +2,5% | +5% |

**Ấn hệ vũ khí.** Vũ khí có **≥ 2 viên cùng hệ** thì đòn đánh thường + kỹ năng không có hệ riêng mang hệ đó, khắc hệ **+15%** sát thương (Ngũ Hành Linh Căn vẫn là +30% và đổi hệ tức thì — Thiên phú giữ giá trị, Q231). Thẻ đồ và khung nhân vật hiện biểu tượng hệ (UI-13).

**Nguồn ngọc** — rơi **theo hệ của quái** (đã có ở mọi quái, TL-S6), nên mỗi vùng là nơi "cày" một hệ ngọc:

| Nguồn | Tỉ lệ / số lượng |
| --- | --- |
| Quái thường | 2% ra ngọc cấp 1 cùng hệ quái |
| Tinh anh | 25%, cấp 1–2 |
| Boss vùng | 1 viên cấp 3 (cùng hệ boss) + 1 viên cấp 1 ngẫu nhiên |
| Cổng dungeon hạng C trở lên | 1–3 viên, cấp theo hạng (C = 2, A = 3, S = 4) |
| Uỷ thác hằng ngày | rương ngày thêm 1 viên cấp 2 |
| Phân rã đồ Cam | 1 viên cấp 2 ngẫu nhiên |

**Tháo ngọc**: 100 × cấp ngọc vàng, **ngọc không vỡ**. Phân rã / bán đồ còn ngọc thì ngọc **tự về túi ngọc** (không mất trong im lặng, cùng tinh thần EQ-09). Ngọc nằm trong **Túi Ngọc** riêng (không chiếm 30 ô túi đồ).

### 3.B. Tẩy Luyện dòng phụ (NL-B)

Lò Rèn tab **Tẩy luyện**. Chọn món → chọn **1 dòng phụ** → 1 trong 2 cách:

| Cách | Kết quả | Chi phí (món cấp L) |
| --- | --- | --- |
| **Luyện giá trị** | Giữ loại dòng, quay lại hệ số 0,8–1,2 | 20 × L vàng + 1 Tinh Thạch |
| **Đổi dòng** | Quay loại khác (không trùng các dòng còn lại, theo quy tắc ô như M4-F1) + giá trị mới | 50 × L vàng + 1 Tinh Kim |

- **Không phạt:** sau khi quay, màn hình hiện **dòng cũ ↔ dòng mới**, người chơi chọn giữ cái nào (chỉ mất nguyên liệu).
- Mỗi món chỉ được tẩy **1 dòng cố định** — dòng đầu tiên bị tẩy được đánh dấu ✦; các dòng khác khoá. Tránh việc tẩy cả 4 dòng thành món hoàn hảo (giữ giá trị của đồ rơi tốt). Q232.
- Hiệu ứng riêng đồ Cam và hiệu ứng bộ **không tẩy** được.
- Chi phí tăng ×1,25 mỗi lần tẩy trên cùng món (tối đa ×3), hiện rõ trên nút.

### 3.C. Thăng Phẩm (NL-C)

Lò Rèn tab **Thăng phẩm**: dùng **1 món cùng ô, cùng phẩm chất, cấp ≥ L − 5** làm nguyên liệu để nâng món chính lên 1 bậc.

| Từ → tới | Chi phí thêm |
| --- | --- |
| Xanh lá → Xanh dương | 2 Tinh Thạch + 30 × L vàng |
| Xanh dương → Tím | 5 Tinh Thạch + 1 Tinh Kim + 60 × L vàng |

- Món chính **giữ** cấp cường hoá, ngọc, dòng phụ cũ, dòng đã tẩy; hệ số phẩm chất tăng (1,1 → 1,2 → 1,35), **thêm 1 dòng phụ ngẫu nhiên** và thêm lỗ ngọc theo bảng §3.A.
- Không lên Cam (Cam chỉ có từ boss — giữ giá trị đồ độc nhất). Đồ bộ không thăng phẩm (luôn là Tím).
- Món nguyên liệu bị tiêu; nếu nó còn ngọc thì ngọc về túi; nếu nó có cấp cường hoá cao hơn thì hỏi *"Chuyển +N sang món chính?"* (giống SN-20).
- Luôn thành công.

### 3.D. Luyện Cấp đồ Cam / đồ bộ (NL-D)

Đồ Cam (17 món boss) và đồ bộ nâng **cấp đồ L** để theo kịp nhân vật:

- Mỗi lần +5 cấp, tối đa bằng cấp nhân vật. Chi phí: `1 + ⌊L/20⌋` Tinh Kim + 40 × L vàng.
- Chỉ số gốc và dòng phụ tính lại theo L mới (giữ hệ số ngẫu nhiên đã quay). Giữ cường hoá, ngọc, dòng đã tẩy.
- Chỉ áp cho Cam + đồ bộ (đồ thường cứ thay đồ mới — vòng lặp nhặt đồ vẫn có ý nghĩa).

### 3.E. Thức Tỉnh trang bị (NL-E)

Mở sau **chuyển chức 3**. Món **Tím / Cam đạt +12** mở dòng **Thức Tỉnh** (dòng vàng riêng trên thẻ đồ):

- Khi mở: chọn **1 trong 3** dòng rút từ bể theo **lớp + nhóm Thiên phú** của nhân vật. Ví dụ: *"Xoáy Kiếm +12% sát thương"*, *"+6% sát thương lên boss"*, *"Linh thú +8% HP"*, *"Hút 1,5% sát thương thành máu"*, *"Đòn khắc hệ +5%"*.
- Bậc 1 → 5, nâng bằng **Thiên Phú Tinh Hoa** (5 / 10 / 20 / 35 / 50) + **Lõi Hư Vô** từ bậc 4. Luôn thành công.
- Mỗi nhân vật tối đa **4 món** có Thức Tỉnh đang mặc có hiệu lực (giới hạn trần sức mạnh, Q234).
- Đổi dòng Thức Tỉnh: tốn 50% tổng Tinh Hoa đã nâng, giữ bậc.

### 3.F. Bảo Giám (NL-F)

Bảng mới trong Túi đồ (tab **Bảo Giám**): ghi danh **lần đầu sở hữu** mỗi món đặc biệt — không cần giữ hay mặc.

| Hạng mục | Số mục | Điểm |
| --- | --- | --- |
| Món đồ bộ (9 bộ × 8 ô) | 72 | 2 / món; đủ 6 ô khác nhau của 1 bộ +6 |
| Đồ Cam (boss, boss hiếm) | 17 | 5 / món |
| Mốc cường hoá lần đầu mỗi ô (+10 / +13 / +15) | 24 | 1 / 2 / 4 |
| Ngọc cấp 7 / 10 lần đầu mỗi hệ | 10 | 3 / 6 |

Mốc điểm cho thưởng **vĩnh viễn nhỏ** (tổng tối đa ≈ +5% chỉ số chính): 20 điểm +1% HP · 50 +1% Tấn công · 90 +1% Phòng thủ · 140 +1% Tấn công · 200 +1% HP và khung chân dung "Bảo Giám Sư" (trang trí). Tận dụng 336 icon EQ-HD đã có ([40](40-icon-trang-bi.md)) — món chưa có hiện bóng xám + gợi ý nơi rơi.

## 4. Cân bằng: ngân sách Lực chiến

Lực chiến = `atk×10 + max_hp + def×8 + crit×1000 + crit_dmg×300 + (atk_speed−1)×800` (`Items.combat_power`). Mục tiêu khi **đầu tư tối đa** mỗi đường, so với Lực chiến từ trang bị hiện nay (gốc + cường hoá + dòng phụ):

| Đường | Phần Lực chiến trang bị thêm vào | Ghi chú |
| --- | --- | --- |
| Hiện có: cường hoá +15 | (đã có, = +150% chỉ số gốc) | Vẫn là đường lớn nhất |
| A. Ngọc (8 món, ngọc cấp 10) | +25 … +30% | Chủ yếu cuối game; giữa game (ngọc cấp 3–5) ≈ +8% |
| B. Tẩy luyện | +5 … +10% | Tối ưu hoá, không phải tăng thô |
| C. Thăng phẩm | Đưa món lên bậc trên (≈ +12% / bậc + 1 dòng) | Không vượt trần đồ Tím rơi sẵn |
| D. Luyện cấp | Không tăng trần — giữ đồ Cam/bộ ngang đồ mới | — |
| E. Thức tỉnh (4 món bậc 5) | +8 … +12% sát thương hiệu dụng | Phần lớn là hiệu ứng, không phải chỉ số |
| F. Bảo Giám | +≈ 5% toàn nhân vật | Thưởng cho người chơi lâu |

Tổng thêm khoảng **+45 … +55%** ở cuối game, **+10 … +15%** ở giữa game. Vì độ khó các chương tính theo cấp, cần (Q235):

- Chạy lại bot chương 7–9 + Tháp Thần Vực sau P1 và P3; nếu boss chết nhanh hơn mục tiêu > 20% thì tăng `TOWER_HP_GROWTH` / số đòn boss chương cuối.
- Không đổi chương 1–3 (ngọc lúc đó chỉ cấp 1–2).

## 5. Giao diện

- **Lò Rèn** thêm 3 tab: *Khảm ngọc* (ô lỗ + Túi Ngọc + Ghép), *Tẩy luyện* (so sánh cũ ↔ mới), *Thăng phẩm* (gộp Luyện cấp). Thức Tỉnh mở tab thứ 8 sau chuyển chức 3. Tab chưa mở hiện khoá kèm *"Mở ở chương N"*.
- **Thẻ đồ** ([42](42-giao-dien-xem-do.md)): thêm hàng lỗ ngọc (ô tròn có màu hệ, lỗ trống viền mờ), dòng đã tẩy có ✦, dòng Thức Tỉnh màu vàng; cuối thẻ **"Lực chiến món này: N"** tách phần *Gốc · Cường hoá · Dòng phụ · Ngọc · Thức tỉnh* (rê chuột).
- **Gợi ý tăng Lực chiến**: nút ↑ cạnh huy hiệu Lực chiến trên khung nhân vật mở danh sách việc làm được ngay ("Mũ còn 1 lỗ trống — có 3 Lam Ngọc", "Ghép được 2 Hồng Ngọc cấp 4", "Áo đủ điều kiện Thăng phẩm"). Đây là phần người chơi thường thiếu: có đường nâng nhưng không biết.
- Icon ngọc 5 hệ × 10 cấp vẽ bằng skill `equipment-design` (dáng ngọc theo cấp: viên tròn → cắt giác → ngọc có lõi sáng).

## 6. Lộ trình

| Đợt | Nội dung | Ước lượng | Ghi chú kỹ thuật |
| --- | --- | --- | --- |
| **P1** | A Khảm ngọc + B Tẩy luyện + thẻ đồ + gợi ý tăng Lực chiến | 2–3 ngày | `data/gems.gd`, `core/gems.gd`; item thêm `sockets`, `gems`, `reforged`; `Items.item_stats` cộng ngọc; profile thêm `gem_bag`; rơi ngọc ở `on_kill` theo `element` quái; save +1 phiên bản (đồ cũ tự có số lỗ theo phẩm chất) |
| **P2** | C Thăng phẩm + D Luyện cấp | 1–2 ngày | Tái dùng `ItemData.RARITIES`, `Items.new_item` để rút dòng mới; tính lại affix theo L giữ `roll` đã lưu |
| **P3** | E Thức tỉnh + F Bảo Giám + chỉnh cân bằng cuối game | 2–3 ngày | Bể dòng Thức Tỉnh theo lớp / nhóm Thiên phú trong `data/awaken_lines.gd`; `codex` trong profile; ghi danh ở `add_item` |

Test dự kiến: `NL1-T1` (rơi ngọc theo hệ, ghép 3→1, khảm / tháo không mất ngọc, ấn hệ +15%, phân rã trả ngọc), `NL1-T2` (tẩy luyện chỉ 1 dòng, giữ cũ / mới, không tẩy dòng Cam), `NL2-T1` (thăng phẩm giữ cường hoá + ngọc, thêm 1 dòng, không lên Cam), `NL2-T2` (luyện cấp chỉ Cam / bộ, ≤ cấp nhân vật), `NL3-T1` (thức tỉnh ≤ 4 món, bảo giám ghi danh 1 lần), bot cân bằng chương 7–9.

## 7. Không đề xuất (đã cân nhắc)

| Ý tưởng | Lý do bỏ |
| --- | --- |
| Cường hoá theo ô (luyện ô, không theo món) | SN-20 đã chuyển cấp cường hoá khi đổi đồ — làm thêm sẽ trùng |
| Cường hoá vượt +15 / tụt cấp khi thất bại | Trái nguyên tắc "không phạt nặng" (EQ-12); chỉ thêm cùng một đường |
| Ngọc / đá tăng tỉ lệ bán bằng tiền thật | Ngoài phạm vi; kịch bản chỉ cho Ngọc Thiên Đạo dùng cho ngoại hình |
| Rèn đồ hoàn toàn theo ý (chọn đủ 4 dòng) | Làm mất giá trị đồ rơi; Tẩy luyện 1 dòng là đủ |

## 8. Câu hỏi cho chủ dự án

| # | Câu hỏi | Đề xuất |
| --- | --- | --- |
| Q229 | Làm những đường nào, theo thứ tự nào? | Cả 6, theo P1 → P2 → P3; P1 trước (A + B) |
| Q230 | Mở Khảm ngọc ở chương mấy? | Chương 2 (Thợ rèn Thiết Ngưu dạy, kèm 1 bước nhiệm vụ chính) |
| Q231 | Ấn hệ vũ khí bằng ngọc bao nhiêu %? | +15% (Ngũ Hành Linh Căn giữ +30%) |
| Q232 | Tẩy luyện được 1 dòng hay mọi dòng? | 1 dòng cố định mỗi món |
| Q233 | Thăng phẩm có cho lên Cam không? | Không |
| Q234 | Thức tỉnh giới hạn bao nhiêu món? | 4 món đang mặc |
| Q235 | Có tăng độ khó chương 7–9 / Tháp Thần Vực sau khi thêm không? | Có, theo bot (§4) |
| Q236 | Túi Ngọc riêng hay chung túi đồ? | Riêng, không giới hạn ô |

## 9. Kết quả triển khai (09/11/2026)

Chủ dự án: *"hãy triển khai theo đề xuất"* → làm hết P1–P3, mọi câu Q229–Q236 lấy cột Đề xuất §8.

### 9.1. Đã làm

| Mã | Nội dung trong game | Test |
| --- | --- | --- |
| NL-A | Lỗ ngọc theo phẩm chất (0/1/1/2/3), đục thêm tới 3 lỗ (1 Tinh Kim + 500 × (lỗ + 1) vàng). 5 loại ngọc cấp 1–10, Túi Ngọc riêng; ghép 3 → 1 và nút "Ghép tất cả". Ngọc rơi theo hệ quái (quái thường 2%, tinh anh 25% cấp 1–2, boss / boss hiếm 1 viên cấp 3 cùng hệ + 1 viên cấp 1), cổng dungeon C/B 1 viên cấp 2, A 2 viên cấp 3, S 3 viên cấp 4, rương uỷ thác ngày 1 viên cấp 2, phân rã đồ Cam 1 viên cấp 2. Chỉ rơi khi đã tới vùng 2. Tháo 100 × cấp vàng, ngọc không vỡ. Bán / phân rã / túi đầy tự phân rã / làm nguyên liệu thăng phẩm → ngọc về túi. Vũ khí ≥ 2 viên cùng hệ → ấn hệ, khắc hệ +15% (có Ngũ Hành Linh Căn thì lấy mức cao hơn). | NL1-T1 |
| NL-B | Tẩy luyện (vùng 3): luyện giá trị (20 × L vàng + 1 Tinh Thạch) hoặc đổi dòng (50 × L vàng + 1 Tinh Kim), so sánh cũ ↔ mới rồi chọn; 1 dòng cố định ✦ mỗi món; chi phí ×1,25 mỗi lần, tối đa ×3. | NL1-T2 |
| NL-C | Thăng phẩm (vùng 4): Xanh lá → Xanh dương → Tím, hút 1 món cùng ô cùng phẩm chất cấp ≥ L − 5 (không khoá); giữ cường hoá / ngọc / dòng cũ, thêm 1 dòng + lỗ; nguyên liệu +N cao hơn thì chuyển +N sang món chính. Không lên Cam, đồ bộ không thăng. | NL2-T1 |
| NL-D | Luyện cấp đồ Cam / đồ bộ (vùng 3): +5 cấp mỗi lần, tối đa cấp nhân vật, `1 + ⌊L/20⌋` Tinh Kim + 40 × L vàng; dòng phụ giữ hệ số quay. | NL2-T2 |
| NL-E | Thức Tỉnh (sau chuyển chức 3): Tím / Cam +12, mở = rút 3 dòng theo lớp + nhóm Thiên phú (12 dòng), chọn 1; bậc 1 → 5 (5/10/20/35/50 Tinh Hoa, bậc 4–5 thêm 1 / 2 Lõi Hư Vô); đổi dòng 50% Tinh Hoa đã dùng, giữ bậc, lượt rút có cả dòng cũ; tối đa 4 món hiệu lực (bậc cao trước). Dòng mới chạm combat: sát thương boss, sát thương kỹ năng, hút máu, khắc hệ, Phòng thủ %, HP linh thú. | NL3-T1 |
| NL-F | Bảo Giám: 72 món bộ + 17 đồ Cam + 24 mốc cường hoá + 10 mốc ngọc, tổng 384 điểm; mốc 20/50/90/140/200 → +1% HP / Tấn công / Phòng thủ / Tấn công / HP + danh hiệu "Bảo Giám Sư". Ghi danh khi nhặt / nhận đồ, cường hoá thành công, ghép ngọc; save cũ ghi danh lại từ đồ đang có. | NL3-T2 |
| NL-G | Lò Rèn thêm 6 tab: Gợi ý · Khảm ngọc · Tẩy luyện · Thăng phẩm (+ Luyện cấp) · Thức tỉnh · Bảo Giám; tab chưa mở mờ đi, bấm vào thấy điều kiện. Thẻ đồ: hàng lỗ ngọc, ấn hệ, dòng ✦, dòng Thức Tỉnh, "Lực chiến món" tách Gốc · Cường hoá · Dòng phụ · Ngọc. Huy hiệu Lực chiến trên khung nhân vật bấm được → tab Gợi ý; mũi tên xanh khi có việc làm được ngay. Mẹo mới ở bảng Trợ giúp (F1). | NL3-T2 + ảnh |

### 9.2. Chỗ khác so với đề xuất

| Chỗ | Đề xuất | Đã làm | Lý do |
| --- | --- | --- | --- |
| Giá trị ngọc Kim / Mộc / Thổ | Kim cấp 10 +80… | Kim +42, Mộc +420, Thổ +52 (bảng §3.A đã sửa) | Tính lại theo ngân sách §4: 24 viên cấp 10 ≈ +30% Lực chiến trang bị cấp 100. Bảng cũ cho tới +60% |
| Bảo Giám đồ bộ | 9 bộ × 6 ô | 9 bộ × 8 ô, đủ 6 ô khác nhau +6 | Món bộ rơi ở cả 8 ô |
| Mở theo "chương" | Chương 2 / 3 / 4 | Theo vùng cao nhất đã mở (map "R-x") | Cùng ý, không phụ thuộc bước nhiệm vụ |
| Thức Tỉnh trong Lực chiến | — | Cộng `cp_extra` ước lượng (sát thương boss / kỹ năng × 50%, khắc hệ × 40%, hút máu theo HP) | Để Lực chiến tăng khi thức tỉnh |
| Q235 chỉnh độ khó cuối game | Chạy bot chương 7–9 | Chưa đổi số | Ngọc / Thức Tỉnh cần cày lâu; theo dõi khi chơi thử, nếu boss chương 7–9 chết nhanh hơn > 20% thì tăng `TOWER_HP_GROWTH` / số đòn boss |

### 9.3. Kỹ thuật

- Dữ liệu `scripts/data/gear_data.gd`, logic `scripts/core/gear.gd`; chỉ số ngọc / ấn hệ / Thức Tỉnh / Bảo Giám cộng ở `Items.item_stats`, `Items.equipment_bonus`, `GameWorld._derive` → `_derive_gear`. Giao diện `scripts/ui/forge_gear.gd` (tab Lò Rèn), `item_card.gd`, `char_frame.gd` (nút Lực chiến).
- Món đồ thêm `sockets, gems, reforged, reforges, awaken`; profile thêm `gem_bag, codex`; **save v32**.
- Ngọc rơi dùng `_loot_rng` (RNG rơi đồ riêng) → không đổi chuỗi `_r()` của trận đánh, test cân bằng cũ giữ nguyên.
- Icon ngọc: `tools/art/hd/gem_icons.py --apply` (5 hệ × 3 kiểu cắt + lỗ trống).
- Test: `run_tests.gd --only=NL` (NL1-T1, NL1-T2, NL2-T1, NL2-T2, NL3-T1, NL3-T2); ảnh: `tests/nl1_shot.gd --dir=<thư mục>` (cần cửa sổ).
