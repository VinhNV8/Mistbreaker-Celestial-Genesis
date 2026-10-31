# Spec_Notes đợt 10: kết quả cường hoá giữa màn hình, bình MP

| | |
| --- | --- |
| Dự án | Thiên Phú Khai Giới |
| Nguồn | [Spec_Notes.md](Spec_Notes.md) (chủ dự án, 30/10/2026) — đã chuyển sang [Spec_Notes_Done.md](Spec_Notes_Done.md) |
| Loại tài liệu | Đặc tả + kết quả |
| Trạng thái | ✅ Đã làm (30/10/2026), save v22, test SN10-T1, SN10-T2 |

## 1. Yêu cầu

| Mã | Ghi chú của chủ dự án | Cách hiểu |
| --- | --- | --- |
| SN10-01 | *"Khi nâng cấp thành công/thất bại, thì nên có hiệu ứng bay giữa bàn mình thông báo thất bại hoặc thất bại thì tốt hơn nhỉ? (đừng để thông báo inline tại inventory)"* | Kết quả cường hoá hiện **giữa màn hình**, to và rõ, thay cho hiệu ứng nhỏ đặt trên chân dung trong Túi đồ (R1-02) và trong Lò Rèn |
| SN10-02 | *"Thiếu bình MP → Cần build các thứ liên quan tới bình MP này."* | Thêm bình MP đủ vòng: phím dùng, ô trên thanh kỹ năng, mua ở cửa hàng, rơi từ quái, lưu save, mục trong danh sách tài nguyên và Trợ giúp |

## 2. SN10-01 — kết quả cường hoá giữa màn hình

| | Thành công | Thất bại |
| --- | --- | --- |
| Tiêu đề | **CƯỜNG HOÁ THÀNH CÔNG** (màu theo cấp cường hoá) | **CƯỜNG HOÁ THẤT BẠI** (xám) |
| Dòng 2 | Tên món kèm cấp mới, ví dụ "Kiếm Sắt Thường +7" | "Mất nguyên liệu · món đồ vẫn +N" |
| Hiệu ứng | Vòng sáng + 18 tia toả ra, xoay nhẹ | Vết nứt xám rơi xuống |

- Khung 460 × 230 canh giữa khung nhìn (lệch lên 40 px), đè lên mọi bảng (`top_level`, `z_index` 100), **không chặn chuột** — bấm Cường hoá liên tục vẫn được.
- Hiện 0,12 giây, giữ, mờ dần 0,5 giây cuối; tổng 1,8 giây rồi tự huỷ. Bấm nhiều lần thì các khung chồng lên nhau, khung mới nhất ở trên.
- Dùng chung ở **Túi đồ** (nút Cường hoá trong khung chi tiết) và **Lò Rèn** (tab Cường hoá).
- Dòng nhật ký góc màn hình giữ nguyên (để xem lại lịch sử).

Code: `ui/enhance_toast.gd` (`EnhanceToast.pop(parent, success, plus, label)`); `InventoryPanel._play_burst`, `ForgePanel._burst` gọi hàm này. Lớp `InventoryPanel.EnhanceBurst` cũ giữ lại nhưng không còn dùng.

## 3. SN10-02 — bình MP

| Mục | Giá trị |
| --- | --- |
| Phím | **F** (bình máu vẫn Q) |
| Tác dụng | Hồi **40% MP tối đa** |
| Hồi chiêu | 8 giây, **riêng** với bình máu (uống liền cả hai được) |
| Mang theo | **Không giới hạn** (chủ dự án 30/10: "không muốn có hạn chế"); nhân vật mới / save cũ có sẵn 2 bình |
| Không phí bình | MP đang đầy hoặc đang hồi chiêu thì không uống |
| Cửa hàng làng | 30 vàng (bằng bình máu) — tab Tạp hoá, thanh tiền trên cùng hiện số bình MP |
| Rơi từ quái | Quái thường **3%**, tinh anh **25%**, boss / boss hiếm **chắc chắn 1 bình**; vào thẳng túi, chữ "+1 Bình MP" ở góc |
| Thanh kỹ năng | Ô thứ 9 (sau bình máu), icon bình xanh lam, số bình ở góc, quét hồi chiêu; hết bình thì mờ |
| Thiên phú Hấp Huyết | Vẫn uống được bình MP (Hấp Huyết chỉ khoá bình máu) |
| Trợ giúp, Tài nguyên | Thêm dòng "F — Uống bình MP" và mục "Bình MP" |

Lý do số liệu: MP lớp phép sau CS (docs/26) lớn (Pháp Sư 122 MP cấp 1, ~1.900 cấp 60) nhưng hồi MP mỗi giây thấp; 40% đủ để tung lại 2–3 kỹ năng mà không thay hồi MP tự nhiên. Rơi đồ dùng **RNG riêng** (`_loot_rng`, giống bãi quái D61) nên không đổi chuỗi số ngẫu nhiên của trận đánh — các test cân bằng giữ nguyên số.

Code: `GameWorld.drink_mp_potion()`, `mp_potion_restore()`, `_drop_mp_potion()`, `shop_buy("mp_potion")`, hằng `MP_POTION_*`, `SHOP_MP_POTION`, `MP_DROP_*`; `Profile.mp_potions` (save **v22**); `Player.mp_potion_cd`; `main.gd` hành động `mp_potion` (F); `Hud.SLOT_MP_POTION`; `ShopPanel._supply_rows`; `Resources` mục `mp_potions`; icon `res-mp_potion`, `skill-mp_potion` (`tools/art/icons.py` `g_mp_potion`).

## 4. Test

| Mã | Kiểm |
| --- | --- |
| SN10-T1 | Toast đè lên bảng, không chặn chuột, canh giữa; thành công / thất bại; tự huỷ sau 1,8 giây; Túi đồ và Lò Rèn dùng toast |
| SN10-T2 | Phím F hồi 40% MP; hồi chiêu riêng 8 giây; không uống khi đang hồi chiêu / MP đầy; mua ở cửa hàng, không giới hạn; boss rơi 1 bình, quái thường ~3%; RNG riêng; save giữ số bình, save v21 nhận 2 bình; ô bình MP phím F trên thanh kỹ năng |
