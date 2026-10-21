# 15 — Hang phụ trong từng map (Spec_Notes đợt 6)

Ghi chú của chủ dự án: *"Map: bản đồ quá bé, tôi nghĩ nên có thêm bản đồ hang, hầm… nữa thì nhiều trải nghiệm hơn."*
Có 3 hướng được đề xuất: (1) hang phụ trong từng map, (2) hầm ngục nhiều tầng, (3) hầm ngẫu nhiên mở bằng chìa khoá. Chủ dự án chọn **hướng 1 — "làm theo đề xuất"** (21/10/2026).

## 1. Ý tưởng

Mỗi map ngoài trời có **1 cửa hang**. Bước vào cửa hang (cổng loại "cave", dùng chung hệ cổng MP-09) để vào một bản đồ nhỏ, tối, dài theo chiều ngang. Trong hang có 3 khu: 2 khu quái dày đặc kèm tinh anh, khu cuối có **Chúa Hang**. Hạ Chúa Hang thì nhận rương thưởng lớn, và một cổng ra hiện ngay tại chỗ. Hang đã dọn thì **đóng lại 20 phút chơi**, sau đó mở lại (quái và Chúa Hang mới).

Mục đích: thêm trải nghiệm "đi hang" ngắn (3–5 phút), thưởng đồ tốt hơn đánh quái ngoài đồng, không cần vẽ thêm nhiều hình (dùng lại quái của map cha).

## 2. Yêu cầu

| Mã | Yêu cầu | Kiểm chứng |
| --- | --- | --- |
| HP-01 | Mỗi map đã làm (16 map, vùng 1–6) có 1 **cửa hang** ở giữa phía dưới map (`size.x × 0,5`, `size.y × 0,82`). Cửa hang là cổng loại `cave`: vòng đá tối, bảng tên "Hang <tên>", dòng phụ cấp hang hoặc thời gian mở lại. Hiện trên bản đồ nhỏ (chấm nâu) | SN6-T4 |
| HP-02 | Tên hang theo vùng: 1 Hang Sương Mù · 2 Hang Gió Lốc · 3 Hầm Cát Cổ · 4 Hang Bùn Lầy · 5 Hang Dung Nham · 6 Hang Băng Vĩnh Cửu. Id bản đồ hang: `cave-<id map cha>` | SN6-T4 |
| HP-03 | Vào hang: không đang giao chiến, hang không đang đóng. Đi đường 1,5 giây (thay vì 4). Không mở "điểm dịch chuyển" và không tính vào khai phá / `unlocked_maps` | SN6-T4 |
| HP-04 | Bản đồ hang: 2600 × 1100, nền của map cha tô tối, sương dày, không cây; cửa vào (vùng an toàn nhỏ, bán kính 90) ở bên trái; **cổng ra** ngay cạnh cửa vào để về map cha (tới nơi đứng cạnh cửa hang) | SN6-T4 |
| HP-05 | Quái trong hang lấy từ bảng quái của map cha, cấp = cấp cao nhất của map cha (+1 ở khu cuối). Khu 1 (x ≈ 900): 5 quái + 1 tinh anh; khu 2 (x ≈ 1600): 6 quái + 1 tinh anh; khu 3 (x ≈ 2250): **Chúa Hang** + 2 quái. Không sinh quái thêm (quái ngoài đồng không hồi) trong hang | SN6-T5 |
| HP-06 | **Chúa Hang**: tinh anh của loại quái mạnh nhất map, tên "Chúa Hang · <tên quái>", HP ×5, tấn công ×1,3, to ×1,4; bảng tên loại "Chúa Hang" (đỏ cam) | SN6-T5 |
| HP-07 | Hạ Chúa Hang: rơi **1 món chắc chắn Xanh dương trở lên** (25% Tím), +vàng (= 40 × cấp), +Đá Cường Hoá (2 + cấp/10), dòng chữ "Hang đã dọn!"; hiện cổng ra tại chỗ Chúa Hang ngã; hang đóng 20 phút chơi (`profile.caves[map cha]` = `play_seconds` + 1200) | SN6-T5 |
| HP-08 | Hang đóng: bước vào cửa hang thì báo "Hang đã dọn — mở lại sau m:ss"; cửa hang màu xám. Hết giờ thì mở lại | SN6-T5 |
| HP-09 | Save: thêm `caves` (Dictionary map cha → giây chơi khi mở lại). Thoát game khi đang ở trong hang thì vào lại ở **map cha** (cạnh cửa vào làng như bình thường), không mất tiến độ hang khác | SN6-T5 |
| HP-10 | Logic chương (dung nham, nhiệt, gió, đêm…) **không** áp trong hang (hang không thuộc `MAPS` của module chương) | SN6-T4 |

## 3. Kỹ thuật

- `core/caves.gd` (mới, static): `is_cave(id)`, `parent(id)`, `cave_id(parent)`, `name_of(parent)`, `build_map(parent)` → Dictionary map hang (đủ khoá như map thường: size, levels, zone_x, safe {kind "cave"}, arena null, gate false, mobs = mobs của map cha, ground, fog, tint, wind 0, trees 0, `cave: true`), `entrance(parent)`, `blocker(w, id)`, `populate(w)` (sinh 3 khu), `on_kill(w, e)` (Chúa Hang → thưởng, cổng ra, đóng hang), `reopen_in(w, parent)`.
- `Maps.get_map(id)`: id `cave-…` → `Caves.build_map` (có cache).
- `Portals.list(id)`: map ngoài trời thêm cổng `cave` (tới `cave-<id>`); map hang chỉ có cổng `exit` (tới map cha) ở cửa vào, không có Cổng Dịch Chuyển.
- `GameWorld`: `travel_blocker` / `travel` / `_arrive` / `_load_map` / khởi tạo gọi `Caves` cho id hang; `in_cave()`; `_kill_enemy` gọi `Caves.on_kill`; trong hang tắt sinh quái ngoài đồng.
- `Enemy.cave_boss` (bool).
- Save **v15**: `caves`.
- `world_view`: cổng `cave`/`exit` có kiểu vẽ riêng (vòng đá, màu nâu cam), nền hang tối + đá rải; `minimap` chấm nâu.

## 4. Test

| Mã | Nội dung |
| --- | --- |
| SN6-T4 | Mỗi map có cửa hang trong map, tránh cổng khác; vào hang (1,5 giây), id `cave-…`, không vào `unlocked_maps`, có cổng ra, không có Cổng Dịch Chuyển; ra hang về map cha đứng cạnh cửa hang |
| SN6-T5 | Hang có 3 khu, đúng số quái + tinh anh + 1 Chúa Hang (HP ×5); không sinh thêm quái; hạ Chúa Hang → món ≥ Xanh dương, cổng ra, hang đóng; vào lại bị chặn, sau 20 phút mở lại; save/load giữ `caves`, load khi đang trong hang → map cha |
