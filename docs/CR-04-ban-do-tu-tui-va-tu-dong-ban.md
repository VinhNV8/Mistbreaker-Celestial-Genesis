# CR-04 — Bán đồ ngay trong Túi đồ + Tự động xử lý đồ theo cấu hình

| Mục | Nội dung |
| --- | --- |
| Mã | CR-04 (nối tiếp CR-01…03 ở [03-mvp-spec](03-mvp-spec.md)) |
| Ngày | 06/11/2026 |
| Nguồn | Đánh giá của người chơi: *"Tại sao Inventory lại không cho phép bán đồ luôn? Tại sao không có chỗ nào để cấu hình tự động bán đồ theo cấu hình đặt sẵn?"* |
| Ảnh hưởng | TB-01 (túi đồ), TB-12 (bán đồ), TB-16/17 (phân rã / bán nhanh có bộ lọc), EQ-09 (túi đầy tự phân rã) |
| Trạng thái | ✅ **Đã làm 08/11/2026** (chủ dự án: "Triển khai CR" — Q211–Q215 theo đề xuất, Q216 lệch nhẹ — §10). Mã yêu cầu **TD-01…13** (Túi Đồ; "BD-" đã dùng cho Dungeon ở docs/34) |
| Ảnh | [design/cr04/](design/cr04/): `cr4-tui-tu-dong.png`, `cr4-tui-ban-nhanh.png`, `cr4-tui-mua-lai.png`, `cr4-the-do-gia.png` |

## 1. Hiện trạng (đọc từ code)

| Chỗ | Hiện có | Code |
| --- | --- | --- |
| Túi đồ (phím I) | Chi tiết món chỉ có **Mặc / Phân rã / Cường hoá**. Khung "Phân rã nhanh" có bộ lọc. **Không có nút Bán.** | `ui/inventory_panel.gd` `_detail`, `_bag_grid` → `BulkBox.build(world, "salvage", …)` |
| Cửa hàng làng (E trong làng) | Tab **Bán đồ**: bán từng món + khung "Bán nhanh" (cùng bộ lọc). | `ui/shop_panel.gd` tab `sell`; `GameWorld.sell_item`, `sell_many` |
| Bộ lọc | **Một** bộ lọc dùng chung cho cả phân rã và bán: phẩm chất, giữ đồ cường hoá, giữ đồ bộ, chỉ đồ yếu hơn. Chỉ áp dụng khi người chơi tự bấm. | `Items.default_filter`, `profile.bulk_filter` |
| Túi đầy (30 ô) | Món mới nhặt **tự phân rã** thành Đá Cường Hoá — cố định, không chọn được "bán" hay "bỏ qua". | `Items.add_item` (EQ-09) |
| Giá bán | `5 × cấp × hệ số phẩm chất × (1 + plus/3)`; hệ số Trắng 1 · Lục 2 · Lam 4 · Tím 8 · Cam 20. | `GameWorld.sell_price`, `SELL_MULT` |
| Khoá đồ | **Không có.** Mọi thao tác hàng loạt chỉ dựa vào bộ lọc. | — |

### Vì sao người chơi khó chịu

1. **Phải chạy về làng mới bán được.** Túi 30 ô đầy rất nhanh khi farm / tự đánh; người chơi buộc phải dừng, về Làng Thanh Thạch (vùng 1) rồi bấm E. Ở vùng xa, việc này cắt nhịp chơi.
2. **Túi đầy = mất vàng.** EQ-09 luôn phân rã, nên người chơi muốn lấy vàng (giai đoạn thiếu vàng để cường hoá) không có lựa chọn.
3. **Bộ lọc đã có nhưng chỉ chạy tay.** Người chơi đã cấu hình bộ lọc, nhưng vẫn phải mở bảng và bấm mỗi lần.
4. **Một bộ lọc cho hai việc.** Không thể "Trắng/Lục thì bán, Lam thì phân rã lấy đá" — kiểu cấu hình phổ biến ở các game nhập vai cày đồ.

### Phát hiện kèm (cần xác minh khi làm)

- Thiên phú **Bàn Tay Vàng — dạng Điểm Kim** ghi *"bán đồ +50% vàng"* (`data/talents.gd:115`) nhưng `sell_price` **không** cộng phần này (grep không thấy chỗ áp dụng). Gộp sửa vào CR-04 (§4.4).

## 2. Mục tiêu

- Bán được đồ **ở mọi nơi**, ngay trong Túi đồ, từng món hoặc hàng loạt.
- Người chơi **đặt sẵn quy tắc** một lần; game tự **bán / phân rã / giữ** món mới nhặt theo quy tắc đó.
- **Không bao giờ mất đồ tốt ngoài ý muốn**: khoá đồ, mặc định an toàn, có thông báo, có mua lại.
- Không phá cân bằng kinh tế hiện tại (giá bán giữ nguyên công thức).

## 3. Ngoài phạm vi

- Chợ / giao dịch giữa người chơi (không có backend).
- Tự động **mặc** đồ tốt hơn (có thể làm CR riêng sau).
- Tự xử lý tài nguyên / bình thuốc (chỉ trang bị).

## 4. Giải pháp đề xuất

### 4.1. Bán ngay trong Túi đồ (CR-04.1)

| # | Yêu cầu |
| --- | --- |
| TD-01 | Khung chi tiết món trong túi thêm nút **"Bán (+N vàng)"** cạnh "Phân rã (+N đá)". Món Tím trở lên hoặc đã cường hoá ≥ +4: hỏi xác nhận 1 lần (bấm lần 2). |
| TD-02 | Khung "Phân rã nhanh" trong túi đổi thành khung **Xử lý nhanh** có 2 nút chế độ **Phân rã / Bán** (dùng lại `BulkBox`, mode `"salvage"` / `"sell"`), giữ bước hỏi xác nhận hiện có. |
| TD-03 | Bán được **ở mọi nơi, đủ giá** (đề xuất — Q211). Tab Bán đồ ở cửa hàng làng vẫn giữ. |
| TD-04 | Phím tắt: chuột phải / phím **S** khi rê lên món trong túi = bán (có xác nhận như TD-01); phím **D** = phân rã. Ghi vào bảng phím tắt (`keybinds.gd`), đổi được. |
| TD-05 | Thẻ đồ (item tip) hiện thêm dòng giá: *"Bán: 120 vàng · Phân rã: 3 đá"*. |

### 4.2. Khoá đồ (CR-04.2) — điều kiện bắt buộc trước khi có tự động

| # | Yêu cầu |
| --- | --- |
| TD-06 | Mỗi món có cờ **Khoá** (biểu tượng ổ khoá nhỏ góc ô). Bật/tắt bằng nút trong khung chi tiết hoặc phím **L**. |
| TD-07 | Món khoá **không** bán, phân rã, tự xử lý, kể cả khi khớp bộ lọc; nút Bán/Phân rã của món đó bị khoá kèm lý do (UI-62). |
| TD-08 | Đồ **đang mặc** khi tháo ra tự giữ (không bị tự xử lý). Đồ Cam mới nhặt **tự khoá** (đề xuất — Q214). |

### 4.3. Tự động xử lý đồ theo cấu hình (CR-04.3)

Thêm tab **"Tự động"** trong bảng Túi đồ (cạnh lưới túi), cấu hình lưu trong save.

**Bảng quy tắc theo phẩm chất** (thay cho bộ lọc chung một chiều):

| Phẩm chất | Lựa chọn | Mặc định |
| --- | --- | --- |
| Trắng | Giữ / **Bán** / Phân rã | Giữ |
| Lục | Giữ / Bán / Phân rã | Giữ |
| Lam | Giữ / Bán / Phân rã | Giữ |
| Tím | Giữ / Bán / Phân rã | Giữ |
| Cam | Giữ (cố định, không cho tự xử lý — Q214) | Giữ |

**Ngoại lệ luôn giữ** (áp dụng trước bảng trên; dùng lại các ô của bộ lọc SN-10):

- ☑ Giữ đồ đã cường hoá (plus > 0)
- ☑ Giữ đồ bộ
- ☑ Giữ đồ **mạnh hơn** đồ đang mặc (Lực chiến khi mặc > hiện tại) — thay cho "chỉ đồ yếu hơn"
- ☐ Giữ đồ có cấp ≥ cấp nhân vật − N (N chỉnh 0–10)
- Món khoá: luôn giữ (TD-07)

**Thời điểm chạy** (Q212):

| Chế độ | Hành vi | Ghi chú |
| --- | --- | --- |
| Tắt | Như hiện nay | Mặc định khi cập nhật bản mới |
| **Khi nhặt** (đề xuất) | Món mới nhặt khớp "Bán"/"Phân rã" được xử lý ngay, không vào túi | Hợp tự đánh / farm lâu |
| Chỉ khi túi đầy | Túi còn chỗ thì vào túi; túi đầy thì món mới xử lý theo quy tắc (thay EQ-09). Món khớp "Giữ" mà túi đầy → phân rã như cũ | Người chơi muốn tự xem đồ trước |

Ngoài ra nút **"Áp dụng cho túi hiện tại"** chạy quy tắc một lần lên đồ đang có trong túi (có xác nhận, liệt kê số món + vàng + đá).

**Mẫu cấu hình sẵn** (chọn nhanh, sau đó chỉnh tiếp được):

| Mẫu | Trắng | Lục | Lam | Tím |
| --- | --- | --- | --- | --- |
| Cày vàng | Bán | Bán | Bán | Giữ |
| Cày đá | Phân rã | Phân rã | Phân rã | Giữ |
| Cân bằng (đề xuất) | Bán | Bán | Phân rã | Giữ |
| Tuỳ chỉnh | — | — | — | — |

**Phản hồi cho người chơi** (để không "mất đồ trong im lặng" — tinh thần EQ-09):

| # | Yêu cầu |
| --- | --- |
| TD-09 | Cột chữ nhặt đồ (`pickup_feed`) gộp theo 2 giây: *"Tự bán 3 món +84 vàng · Tự phân rã 2 món +5 đá"*. Không hiện từng món để khỏi rối. |
| TD-10 | Tab Tự động có dòng thống kê phiên: *"Phiên này: tự bán 47 món (+1.320 vàng), phân rã 18 món (+41 đá)"*. |
| TD-11 | **Mua lại**: 10 món tự bán / bán tay gần nhất mua lại được đúng giá đã bán, trong phiên chơi (không lưu save — Q213). Món tự phân rã không hoàn lại. |
| TD-12 | Biểu tượng nhỏ trên nút Túi đồ (char_bar) khi tự động đang bật, tooltip ghi chế độ. |

### 4.4. Sửa kèm (CR-04.4)

| # | Yêu cầu |
| --- | --- |
| TD-13 | `sell_price` nhận profile, cộng **+50% vàng** khi có Bàn Tay Vàng dạng Điểm Kim (đúng mô tả thiên phú). Mọi chỗ bán (tay, nhanh, tự động, giá hiện trên thẻ) dùng chung một hàm. |

## 5. Thiết kế kỹ thuật (dự kiến)

### 5.1. Dữ liệu / save

- `Profile.VERSION` 30 → **31**.
- `profile.loot_rules` (mới), thay vai trò của `bulk_filter`:

```gdscript
{
  "mode": "off",            # "off" | "pickup" | "full"
  "by_rarity": {"white": "keep", "green": "keep", "blue": "keep", "purple": "keep"},
  "keep_plus": true, "keep_set": true, "keep_better": true,
  "keep_level_gap": -1,     # -1 = tắt; N = giữ đồ cấp >= cấp nhân vật - N
  "preset": "custom"
}
```

- Nâng cấp save v30 → v31: `bulk_filter.rarities` chuyển thành `by_rarity` = `"salvage"` cho các phẩm chất đang chọn (giữ đúng hành vi khung Phân rã nhanh cũ), `mode = "off"`.
- Mỗi món có thêm khoá `"locked": bool` (thiếu = false). Đồ Cam đang có trong túi khi nâng cấp save: tự khoá (nếu Q214 duyệt).
- Lịch sử mua lại: `GameWorld._buyback: Array` (tối đa 10, không lưu).

### 5.2. Logic

| Hàm | Vị trí | Việc |
| --- | --- | --- |
| `Items.default_rules()`, `normalize_rules(r)` | `core/items.gd` | Thay `default_filter` / `normalize_filter` (giữ hàm cũ làm lớp chuyển đổi cho `BulkBox`). |
| `Items.decide(p, item, rules, better: Callable) -> String` | `core/items.gd` | Trả `"keep" / "sell" / "salvage"`: khoá → keep; Cam → keep; ngoại lệ → keep; còn lại theo `by_rarity`. Hàm thuần, dễ test. |
| `GameWorld.sell_price(item, p = null)` | `core/game_world.gd` | Thêm hệ số Điểm Kim (TD-13). |
| `GameWorld._auto_process(item) -> Dictionary` | `core/game_world.gd` | Gọi `decide`; bán/phân rã, đẩy vào bộ gộp thông báo, ghi buyback. |
| Điểm chèn | `game_world.gd:3685` (nhặt đồ rơi) | `mode == "pickup"` → `_auto_process` trước `Items.add_item`; `mode == "full"` và túi đầy → `_auto_process` thay nhánh tự phân rã của EQ-09. Phần thưởng nhiệm vụ / gift / sự kiện (`quests.gd`, `game_world.gd:4013, 4450, 4509, 5273`) **không** tự xử lý — chỉ đồ rơi từ quái / rương. |
| `GameWorld.toggle_lock(id)`, `buyback(idx)` | `core/game_world.gd` | TD-06, TD-11. |
| `sell_item`, `sell_many`, `salvage`, `salvage_many` | hiện có | Bỏ qua món `locked`. |

### 5.3. Giao diện

- `ui/inventory_panel.gd`: nút Bán + Khoá trong `_detail`; tab "Tự động"; ổ khoá trên ô (`_item_button`).
- `ui/bulk_box.gd`: thêm nút chuyển chế độ Phân rã / Bán trong túi; đọc quy tắc mới.
- `ui/item_tip.gd`: dòng giá bán / phân rã.
- `ui/pickup_feed.gd`: dòng gộp "Tự bán / Tự phân rã".
- `ui/char_bar.gd`: chấm báo tự động đang bật.
- `core/keybinds.gd`: S (bán), D (phân rã), L (khoá).

### 5.4. Test (dự kiến)

| Mã | Nội dung |
| --- | --- |
| CR4-T1 | Bán trong túi ở ngoài làng: vàng + đúng `sell_price`, món rời túi; món đang mặc / món khoá bị từ chối. |
| CR4-T2 | `Items.decide`: bảng phẩm chất × ngoại lệ (khoá, Cam, plus, bộ, mạnh hơn, chênh cấp). |
| CR4-T3 | Chế độ "pickup": 100 món rơi giả lập → tổng vàng / đá khớp, túi chỉ chứa món "keep". |
| CR4-T4 | Chế độ "full": túi chưa đầy không xử lý; đầy thì xử lý theo quy tắc; món "keep" khi đầy vẫn phân rã (EQ-09). |
| CR4-T5 | Nâng cấp save v30 → v31: bộ lọc cũ chuyển đúng, `mode = off`, đồ Cam tự khoá. |
| CR4-T6 | Mua lại: tối đa 10, đúng giá, túi đầy thì từ chối; phần thưởng nhiệm vụ không bị tự xử lý. |
| CR4-T7 | Điểm Kim: giá bán ×1,5 ở mọi đường bán. |
| Smoke | Ảnh `05g-bag-sell`, `05h-bag-auto` (tab Tự động), `05i-pickup-autosell`. |

## 6. Tiêu chí nghiệm thu

1. Đứng ở bất kỳ vùng nào, mở Túi đồ (I) bán được 1 món và bán nhanh nhiều món mà không cần về làng.
2. Bật "Tự động — Khi nhặt" với mẫu "Cân bằng", tự đánh 5 phút: túi không chứa đồ Trắng / Lục / Lam (trừ ngoại lệ), có dòng thông báo gộp, thống kê phiên đúng.
3. Món đã khoá, đồ Cam, đồ cường hoá, đồ bộ, đồ mạnh hơn đồ đang mặc không bao giờ bị tự xử lý.
4. Món vừa bán nhầm mua lại được trong phiên.
5. Save cũ mở lên không đổi hành vi cho đến khi người chơi bật tự động.
6. Toàn bộ test cũ (SN-T3, EQ-09, C1-T10) vẫn qua.

## 7. Kế hoạch làm

| Pha | Nội dung | Ước lượng |
| --- | --- | --- |
| 1 | CR-04.1 (bán trong túi) + CR-04.2 (khoá đồ) + CR-04.4 (Điểm Kim) + save v31 | 0,5 ngày |
| 2 | CR-04.3 quy tắc + chế độ pickup / full + thông báo gộp + tab Tự động + mẫu | 1 ngày |
| 3 | Mua lại, thống kê phiên, phím tắt, ảnh smoke, cập nhật spec 01 / 02 / 04 | 0,5 ngày |

Có thể giao pha 1 trước — giải quyết ngay câu hỏi thứ nhất của người chơi.

## 8. Điểm cần chủ dự án duyệt

| Mã | Câu hỏi | Đề xuất |
| --- | --- | --- |
| Q211 | Bán từ túi ở ngoài làng: đủ giá, hay giảm giá (vd 70%) để cửa hàng làng còn ý nghĩa? | **Đủ giá** — game chơi đơn, giá bán vốn thấp; cửa hàng làng vẫn là nơi mua thuốc / đá / Thương nhân lữ hành |
| Q212 | Chế độ tự động mặc định khi người chơi bật lần đầu: "Khi nhặt" hay "Chỉ khi túi đầy"? | **Khi nhặt** (đúng ý người chơi phản ánh); cập nhật bản mới vẫn **Tắt** cho tới khi người chơi bật |
| Q213 | Mua lại có lưu qua lần mở game sau không? | **Không** — chỉ trong phiên, 10 món |
| Q214 | Đồ Cam: cấm tự xử lý + tự khoá khi nhặt? | **Có** — Cam hiếm, mất là rất khó chịu |
| Q215 | Đồ Tím có cho chọn "Bán / Phân rã" trong tự động không? | **Có**, mặc định Giữ |
| Q216 | Tách hẳn bộ lọc Phân rã nhanh và Bán nhanh, hay cả hai dùng chung bảng quy tắc theo phẩm chất? | **Dùng chung bảng quy tắc** — nút "Áp dụng cho túi hiện tại" làm cả bán lẫn phân rã một lần, đỡ phải cấu hình 2 nơi |

## 9. Tài liệu cần cập nhật khi làm

- [01-requirement-spec](01-requirement-spec.md): thêm TD-01…13, trạng thái.
- [02-technical-spec](02-technical-spec.md): save v31, `loot_rules`, `Items.decide`, quyết định D88 (điểm chèn tự xử lý chỉ cho đồ rơi), test CR4-T1…T7.
- [03-mvp-spec](03-mvp-spec.md): ghi chú EQ-09 có thể bị thay bởi chế độ "Chỉ khi túi đầy".
- [04-ke-hoach-tien-do](04-ke-hoach-tien-do.md): TB-18.
- Bảng phím tắt / Trợ giúp (`help_panel.gd`).

## 10. Kết quả triển khai (08/11/2026)

### 10.1. Quyết định

| Mã | Chốt |
| --- | --- |
| Q211 | Bán ở mọi nơi, **đủ giá** |
| Q212 | Bản cập nhật / save cũ: **Tắt**. Lần đầu bật mà bảng phẩm chất đang "Giữ hết" thì tự áp mẫu **Cân bằng** (báo trong nhật ký) để bật lên là có tác dụng |
| Q213 | Mua lại chỉ trong phiên, 10 món, đúng giá đã bán (cả bán tay, bán nhanh, tự bán, áp dụng cho túi) |
| Q214 | Đồ Cam: không có trong bảng tự động (luôn giữ) + tự khoá khi vào túi; save cũ khoá đồ Cam đang có một lần |
| Q215 | Đồ Tím chọn được Bán / Phân rã, mặc định Giữ |
| Q216 | **Lệch đề xuất**: giữ bộ lọc cũ (SN-10) cho "Phân rã nhanh" / "Bán nhanh" bấm tay — người chơi đã quen, test SN-T3 giữ nguyên; bảng quy tắc mới chỉ dùng cho Tự động + nút "Áp dụng cho túi (N)" (làm cả bán lẫn phân rã một lần). Không chuyển `bulk_filter` sang `loot_rules` khi nâng save |
| Q217 | *(chốt 09/11)* Lên Thần Tài **vẫn giữ** +50% vàng bán đồ của Điểm Kim — tiến hoá cộng dồn, cùng với Tinh Hoa khi phân rã và lãnh địa +20% vàng |

### 10.2. Đã làm

- **Túi đồ** (`ui/inventory_panel.gd`): chi tiết món có **Bán +N vàng / Phân rã +N đá** (Tím, Cam hoặc ≥ +4 bấm 2 lần: "Chắc chắn? …"), **Khoá (L) / Mở khoá (L)**; ô đã khoá có ổ khoá vàng góc trên trái. Khung dưới lưới có 4 nút: **Phân rã nhanh · Bán nhanh · Tự động ● · Mua lại (N)**. Ở tab Tự động, dấu góc ô = món quy tắc sẽ xử lý (vàng = bán, đỏ = phân rã). Rê chuột lên món trong túi: **S** bán, **D** phân rã, **L** khoá.
- **Tab Tự động** (`ui/loot_box.gd`): hàng tiêu đề + 3 mẫu (Cày vàng / Cày đá / Cân bằng; tooltip ghi từng phẩm chất); chế độ Tắt / Khi nhặt / Khi túi đầy; 4 nút phẩm chất bấm để xoay Giữ → Bán → Phân rã; ngoại lệ (đồ cường hoá, đồ bộ, đồ mạnh hơn đang mặc, đồ cấp ≥ cấp mình − N với N 0–10); dòng thống kê phiên + nút "Áp dụng cho túi (N)" có bước xác nhận.
- **Lõi**: `Items.decide / default_rules / normalize_rules / rules_preset / toggle_lock / is_locked / salvage_gain`; `GameWorld.loot_rules / set_loot_rules / loot_decide / _auto_loot / loot_preview / loot_apply / buyback / toggle_lock / is_upgrade`, `buyback_list`, `loot_stats`. Điểm chèn duy nhất là `_update_pickups` (đồ rơi từ quái / rương) — thưởng nhiệm vụ, gift code, sự kiện vẫn vào túi qua `Items.add_item`.
- **Khoá**: `sell_item`, `sell_many`, `Items.salvage`, `bulk_candidates`, `decide` đều bỏ qua món khoá; nút Bán ở cửa hàng làng thành "Đã khoá".
- **Thông báo**: cột nhặt đồ gộp 2 dòng "Tự bán đồ: +N vàng" / "Tự phân rã đồ: +N đá" (gộp trong 1 giây như dòng vàng); tab Trang bị trên thanh tiêu đề có chấm "●" + tooltip chế độ khi Tự động đang bật.
- **Thẻ đồ** (`ui/item_tip.gd`): dòng cuối "Bán: N vàng · Phân rã: M đá (· Đã khoá)".
- **CR-04.4**: `GameWorld.sell_price(item, p)` ×1,5 khi Thiên phú chính là Bàn Tay Vàng đã tiến hoá (Điểm Kim); giá Thương nhân lữ hành vẫn tính theo giá gốc.
- **Save v31**: `loot_rules`, `item.locked`.
- **Test** CR4-T1…T7 (`tests/run_tests.gd`); ảnh `tests/cr4_shot.gd -- --dir=<thư mục>` (cần cửa sổ).

### 10.3. Chưa làm / khác đề xuất

- TD-04: phím S / D / L chỉ có tác dụng trong Túi đồ khi rê chuột lên món, **không** nằm trong bảng đổi phím (Cài đặt → Điều khiển) vì trùng phím di chuyển S / D ngoài bản đồ.
- TD-08 vế "đồ tháo ra tự giữ": không làm — tự động chỉ xử lý món **mới nhặt**, đồ tháo ra không bị đụng; "Áp dụng cho túi" luôn hỏi lại và có ngoại lệ "giữ đồ mạnh hơn".
- TD-09: dòng gộp hiện tổng vàng / đá, không hiện số món (số món xem ở dòng thống kê phiên).
- Bảng phẩm chất là nút bấm xoay vòng thay cho 3 nút / ô chọn mỗi dòng, để khung vừa cửa sổ 1366×768.

## 11. Rà soát sau triển khai (09/11/2026) — R1–R8 ✅ đã sửa 09/11 (§11.4), U1–U5 ✅ pha sau (§12)

### 11.1. Lỗi / rủi ro (đề xuất sửa ngay)

| # | Vấn đề | Tình huống | Đề xuất |
| --- | --- | --- | --- |
| R1 | Đồ **Cam / đồ đã khoá vẫn bị phân rã khi túi đầy** (EQ-09 trong `Items.add_item` chạy trước mọi kiểm tra khoá) | Túi 30/30, rơi Nanh Sói Chúa → "Túi đầy: … tự phân rã thành N đá" — mất món hiếm dù CR-04 hứa "không bao giờ mất đồ tốt" | Món Cam (và món khoá khi mua lại / thưởng) gặp túi đầy thì **nằm lại trên đất**, không hết hạn, cảnh báo "Túi đầy — dọn túi để nhặt …"; Trắng–Tím giữ EQ-09 |
| R2 | Phím S / D / L dùng **món rê chuột cũ** (`_hover_id` không xoá khi đóng / mở bảng) | Đang rê chuột lên ô → I đóng túi → mở lại, chuột ở chỗ khác → bấm S: bán món cũ (Trắng / Lục bán luôn, không hỏi) | Xoá `_hover_id` khi mở / đóng / dựng lại bảng; chỉ nhận phím khi `gui_get_hovered_control()` đúng là ô đó |
| R3 | Bước "Chắc chắn?" **không tự huỷ** | Bấm Bán đồ Tím 1 lần → chọn món khác → quay lại → 1 lần bấm là bán | Xoá `_confirm` khi đổi món, đổi tab, đóng bảng, hoặc sau ~3 giây |
| R4 | Thẻ "ĐANG MẶC" cũng hiện "Bán: N vàng" | Đồ đang mặc không bán được — gây hiểu nhầm | Chỉ hiện dòng giá cho món trong túi |

### 11.2. Thiếu sót liên quan

| # | Vấn đề | Đề xuất |
| --- | --- | --- |
| R5 | **Thần Tài** (tiến hoá 2 của Bàn Tay Vàng) chưa có hiệu ứng nào trong code: "phân rã 10% ra 1 Thiên Phú Tinh Hoa; lãnh địa +20% vàng" (cùng loại lỗi với Điểm Kim) | Làm 2 hiệu ứng, áp cả cho tự phân rã. **Q217**: lên Thần Tài có giữ +50% vàng bán đồ của Điểm Kim không? (đang giữ — `evo >= 1`) |
| R6 | Bán ở cửa hàng làng có vào danh sách mua lại nhưng cửa hàng không có chỗ mua lại | Thêm mục "Mua lại" ở tab Bán đồ của cửa hàng (dùng lại `LootBox.build_buyback`) |
| R7 | Bảng Trợ giúp chưa có phím S / D / L và cách khoá đồ | Thêm vào `help_panel.gd` |
| R8 | Số lớn chưa có dấu chấm ngăn nghìn ("+1320 vàng") trong nút / thống kê CR-04 | Dùng `Ornate.group` như phần còn lại |

### 11.3. Nâng cấp (pha sau)

| # | Đề xuất | Lý do |
| --- | --- | --- |
| U1 | Nút **Sắp xếp túi** (theo ô / phẩm chất / Lực chiến) | Game chưa có; đi đôi với bán / khoá |
| U2 | "Giữ đồ bộ" thông minh: chỉ giữ món bộ cho ô **chưa có** hoặc tốt hơn món bộ đang giữ | Hiện giữ mọi món bộ → túi vẫn đầy nhanh khi farm vùng có bộ |
| U3 | Quy tắc theo **dòng chỉ số / ô** (vd luôn giữ đồ có Chí mạng, luôn bán Bùa) | Kiểu lọc phổ biến ở game cày đồ |
| U4 | Khoá nhanh mọi đồ đang mặc (1 nút) | Đồ tháo ra khi đổi đồ được bảo vệ ngay |
| U5 | Tóm tắt khi mở Túi đồ: "Từ lần mở trước: tự bán 12 món +340 vàng" | Người chơi thấy tự động đang làm gì mà không cần nhìn cột nhặt đồ |

### 11.4. Đã sửa (09/11/2026, chủ dự án: "tiếp tục")

| # | Cách làm |
| --- | --- |
| R1 | `_update_pickups`: món `Items.must_keep` (Cam hoặc đã khoá) gặp túi đầy → `Pickup.blocked`, nằm lại (`BLOCKED_PICKUP_TTL` 600 giây, không bị hút theo nhân vật), nhắc "Túi đầy — dọn túi … để nhặt …" mỗi 6 giây khi đứng trên nó + dòng "Túi đầy!" ở cột nhặt đồ; túi có chỗ thì nhặt lại bình thường. Trắng–Tím vẫn EQ-09. *Giới hạn*: đồ trên đất mất khi rời map / thoát game (như mọi đồ rơi); thưởng nhiệm vụ đồ Cam khi túi đầy vẫn đi đường `Items.add_item` cũ |
| R2 | `_hover_id` xoá khi mở / đóng bảng; phím S / D / L chỉ nhận khi `gui_get_hovered_control()` đúng ô có `meta cr4_item` = món đó (sau khi bảng dựng lại phải rê chuột lại) |
| R3 | `_confirm` có thời điểm, hết hiệu lực sau 4 giây (`CONFIRM_MS`); huỷ khi chọn món khác, đổi khung dưới, mở / đóng bảng |
| R4 | Dòng giá chỉ ở thẻ món trong túi (thẻ có so sánh) |
| R5 | Thần Tài: phân rã (tay, nhanh, tự động, áp dụng cho túi) 10% ra +1 Thiên Phú Tinh Hoa (`Items.GOD_OF_WEALTH_ESSENCE`, `salvage_gain.essence`); `Explore.production_per_minute` vàng ×1,2. **Q217 chốt 09/11** (chủ dự án: "làm theo đề xuất"): lên Thần Tài vẫn giữ +50% vàng bán đồ (`Items.golden_form(p) >= 1`, tiến hoá cộng dồn) |
| R6 | Tab Bán đồ ở cửa hàng: khi chưa chọn món, cột phải hiện "Mua lại" (`LootBox.build_buyback`); ô đã khoá trong lưới cửa hàng có ổ khoá |
| R7 | Trợ giúp (F1): mẹo về S / D / L, khoá, tab Tự động, Mua lại |
| R8 | `Ornate.group` cho nút Bán, thẻ giá, thống kê, xác nhận, Mua lại, nút Bán nhanh / Phân rã nhanh (`bulk_box.gd`) |

Test **CR4-T8**; ảnh thêm `design/cr04/cr4-cua-hang-mua-lai.png`.

## 12. Pha sau U1–U5 (09/11/2026, chủ dự án: "tiếp tục pha sau") — ✅

| Mã | U | Đã làm |
| --- | --- | --- |
| TD-15 | U1 | Nút **Sắp xếp ▾** ở đầu lưới túi (menu: theo phẩm chất / theo ô trang bị / theo Lực chiến khi mặc). Món khoá luôn đứng đầu; hoà thì theo cấp, cường hoá, id. `Items.sort_bag(p, mode, power)`, `GameWorld.sort_bag` |
| TD-16 | U2 | "Giữ đồ bộ" trong **quy tắc tự động** thành thông minh: món bộ bị bán / phân rã theo bảng nếu đã có món **cùng bộ, cùng ô, hạng ≥** (phẩm chất → cấp → cường hoá; bằng nhau giữ món id nhỏ) ở túi hoặc đang mặc (`Items.set_duplicate`). Bộ lọc Bán / Phân rã nhanh bấm tay (SN-10) giữ nguyên "giữ mọi đồ bộ" |
| TD-17 | U3 | Nút **Nâng cao ▸** (đếm số quy tắc đang bật) trong tab Tự động → trang Quy tắc nâng cao: 8 nút ô xoay Bảng → Giữ → Bán → Rã (ghi đè bảng phẩm chất), 12 nút dòng chỉ số "luôn giữ"; "Xoá hết", "◂ Quay lại". Thứ tự xét: khoá / Cam → dòng chỉ số → ô → phẩm chất → ngoại lệ. Dữ liệu `loot_rules.by_slot`, `loot_rules.keep_stats` (save v31 giữ nguyên số phiên bản — `normalize_rules` điền mặc định khi thiếu) |
| TD-18 | U4 | Nút **Khoá đồ mặc / Mở khoá đồ mặc** ở đầu lưới túi: khoá mọi món đang mặc (đã khoá hết thì mở hết); khoá đi theo món khi tháo ra. `GameWorld.toggle_lock_worn`, `worn_all_locked` |
| TD-19 | U5 | Thẻ **TỰ XỬ LÝ ĐỒ · <chế độ>** ở cột trái tab Trang bị: "Từ lần mở túi trước: tự bán N món (+G vàng), tự phân rã M món (+S đá)" (ẩn khi Tắt và chưa xử lý gì). Mốc `GameWorld.loot_seen`, cập nhật mỗi lần mở Túi đồ (`loot_since_seen`) |

Test **CR4-T9**; ảnh `design/cr04/cr4-tui-tu-dong.png` (nút đầu túi + thẻ tóm tắt), `cr4-tui-nang-cao.png`. Đã kiểm vừa khung 1366×768.
