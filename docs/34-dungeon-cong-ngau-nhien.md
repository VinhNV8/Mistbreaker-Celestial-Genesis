# Dungeon cổng ngẫu nhiên (BD-11, KP-10, NV-23)

| | |
| --- | --- |
| Dự án | Thiên Phú Khai Giới |
| Nguồn | Kịch bản mục 6 (*"Dungeon cổng ngẫu nhiên: cổng hạng E→S mở ngẫu nhiên trên map đã khai phá, tồn tại 2 giờ"*), mục 7 (sự kiện ô *"Cổng dungeon 7% — Dungeon ngẫu nhiên hạng E→S"*), mục 4 (nguồn EXP: dungeon) · chủ dự án 02/11/2026 "triển khai theo đề xuất" |
| Loại tài liệu | Đặc tả + kết quả |
| Trạng thái | ✅ Đã làm (02/11/2026), save v29 |

## 1. Phạm vi

Kịch bản chỉ ghi 1 dòng, nên spec tự thiết kế các con số (mục 2), giữ đúng 3 ý: **hạng E → S**, **mở ngẫu nhiên trên map đã tới**, **tồn tại 2 giờ**. Dungeon trong cổng dùng lại khung **hang phụ** ([15](15-hang-phu.md)): bản đồ nhỏ tối, 3 khu quái, trùm cuối, cổng ra tại chỗ.

## 2. Đặc tả

| Mã | Nội dung |
| --- | --- |
| BD11-01 | **Mở cổng**: từ cấp 6, cứ **5 phút chơi** quay 1 lần, **50%** mở 1 cổng trên 1 map ngẫu nhiên **đã đặt chân** (`unlocked_maps`). Tối đa **2 cổng** cùng lúc, mỗi map 1 cổng. Mở cổng → thông báo + nhật ký "Cổng dungeon hạng X mở ở <map> (cấp N) — tồn tại 2 giờ chơi" |
| BD11-02 | **Hạng** E 40% · D 28% · C 18% · B 9% · A 4% · S 1% |
| BD11-03 | **Tồn tại 2 giờ chơi** (`play_seconds`, như hồi hang phụ — offline không trừ). Hết giờ → cổng biến mất. Đang ở trong lúc hết giờ: đánh tiếp được tới khi ra |
| BD11-04 | **Vị trí**: điểm ngẫu nhiên trong map, xa vùng an toàn / các cổng khác (≥ 520 nếu tìm được), không trong hang boss; map đảo bay → trên đảo |
| BD11-05 | **Trong cổng**: bản đồ `gate-<hạng>-<map cha>` (khung hang phụ: tối, không sương, không quái ngoài đồng, không tính khai phá, 1,5 giây đi đường). 3 khu quái (4 / 5 / 2 quái thường + 1 tinh anh mỗi khu, **+0…3 quái mỗi khu theo hạng**) + **Chúa Cổng** cuối hang. Vào lại sau khi ra → quái sinh lại (cổng còn mở tới khi dọn hoặc hết giờ) |
| BD11-06 | **Theo hạng** (so với cấp cao nhất của map cha): |

| Hạng | Cấp | HP quái | Tấn công | Quái thêm / khu | Chúa Cổng HP | EXP dọn (× EXP 1 tinh anh) | Vàng / Đá ×  | Tinh Hoa | Đồ rơi |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| E | −3 | ×1 | ×1 | 0 | ×4 | 10 | ×1 | — | 1 Xanh dương |
| D | −1 | ×1,1 | ×1,05 | 1 | ×5 | 15 | ×1,5 | — | 2 Xanh dương |
| C | +1 | ×1,25 | ×1,12 | 1 | ×6 | 22 | ×2 | 1 | 1 Tím |
| B | +3 | ×1,45 | ×1,2 | 2 | ×7 | 32 | ×3 | 1 | 1 Tím + 1 Xanh dương |
| A | +5 | ×1,7 | ×1,3 | 2 | ×8 | 45 | ×4 | 2 | 2 Tím |
| S | +8 | ×2 | ×1,45 | 3 | ×10 | 65 | ×6 | 3 | 1 **Cam** + 1 Tím |

| Mã | Nội dung |
| --- | --- |
| BD11-07 | **Dọn cổng** (hạ Chúa Cổng): đồ theo bảng, vàng 40 × cấp × hệ số, Đá Cường Hoá, Thiên Phú Tinh Hoa, **EXP thưởng** (NV-23) cộng thẳng; cổng đóng; cổng ra tại chỗ; ghi số cổng đã dọn + hạng cao nhất |
| KP-10 | **Sự kiện Cổng dungeon khi khai phá**: dọn sương 1 ô (Đuốc Khai Giới) có **7%** (tỉ lệ kịch bản) lộ ra Cổng dungeon trên map ngoài trời đang đứng (nếu map chưa có cổng). Không đổi bảng sự kiện ô (bảng KP-11 giữ nguyên để không đổi lưới đã tạo) |
| NV-23 | **Nguồn EXP dungeon**: EXP quái trong cổng (cấp cao hơn map) + EXP thưởng dọn cổng (bảng BD11-06) |
| BD11-08 | **Giao diện**: cổng trên map vẽ như cổng dịch chuyển, **màu theo hạng** (E xám · D lục · C lam · B tím · A cam · S đỏ), bảng tên "Cổng hạng X · Cấp N · còn h:mm"; chấm to trên bản đồ nhỏ; **bản đồ lục địa (N)**: dòng "Cổng dungeon đang mở: hạng X ở <map> (còn h:mm)…" + "⚔ Cổng X" cạnh tên map; HUD trong cổng: "còn N quái · Chúa Cổng đang chờ / đã dọn ✓"; bảng tên + khung mục tiêu "Chúa Cổng" |
| BD11-09 | **Save v29**: `gates` {map cha: {rank, until, x, y}}, `gates_cleared`, `gate_best`. Save cũ: chưa có cổng |

## 3. Code

- `core/gates.gd` (mới): hằng số (`LIFE`, `MAX_OPEN`, `ROLL_EVERY`, `ROLL_CHANCE`, `MIN_LEVEL`, `FOG_CHANCE`, `WEIGHT`, `RANK`, `COLORS`, `ZONES`), `is_gate / gate_id / parent / rank_in / rank_of / left / level_range`, `build_map`, `blocker`, `portal_of`, `roll_rank`, `open_gate`, `tick`, `on_reveal`, `populate`, `clear_exp`, `on_kill`.
- `core/caves.gd`: `is_cave` đúng cho cả `gate-…` (bản đồ cổng hưởng mọi xử lý của hang); `parent / blocker / populate / on_kill` chuyển sang `Gates` khi là cổng.
- `data/maps.gd` `get_map`: id `gate-…` → `Gates.build_map` (hạng nằm trong id nên dựng được không cần hồ sơ).
- `GameWorld`: `_gate_rng` (RNG riêng — không đổi chuỗi `_rng` của trận đánh), `_gate_clock`; `update` gọi `Gates.tick`; `reveal_tile` gọi `Gates.on_reveal`; `_load_map` thêm cổng `dgate` vào `portals`; `Enemy.gate_boss`.
- `Profile` v29. UI: `world_view` (`_portal_style` "dgate", bảng tên Chúa Cổng), `minimap`, `world_map_panel` (`GateInfo`), `hud`, `target_frame`.

## 4. Test

| Mã | Kiểm |
| --- | --- |
| BD11-T1 | Mở cổng hạng C ở 1-1 (2 giờ, trong map, ngoài vùng an toàn, mỗi map 1 cổng); chỉ vào đúng cổng đang mở; trong cổng: cấp +1, số quái theo hạng + 1 Chúa Cổng (HP ×1,25 × 6), chỉ có cổng ra; hạ Chúa Cổng → 1 Tím, EXP thưởng, +1 Tinh Hoa, cổng đóng, số cổng đã dọn / hạng cao nhất, cổng ra; ra về 1-1 cổng đã biến mất |
| BD11-T2 | Tỉ lệ hạng (20.000 lần, ±1,5 điểm %); dưới cấp 6 không mở; mỗi 5 phút có thể mở, tối đa 2, chỉ trên map đã tới; hết 2 giờ đóng + biến mất, không vào được; hết giờ khi đang ở trong vẫn ở lại; KP-10 dọn sương ≈ 7% (2.000 lần), qua `GameWorld.reveal_tile` |
| BD11-T3 | Hạng S so với E: cấp +11, Chúa Cổng HP / tấn công cao hơn; EXP thưởng S > 5 lần E; save v29 giữ cổng / số đã dọn / hạng cao nhất, nạp save cổng vẫn trên map; save v28 không có cổng; bản đồ lục địa có dòng cổng; tên cổng trên map |

## 5. Kết quả

- BD11-T1…T3 qua. Smoke `09a3-gate` (cổng hạng B trên Cửa Gió, bảng tên "Cổng hạng B · Cấp 16 · còn 2:00"), `09a4-gate-inside` (trong cổng: 21 quái, HUD "Chúa Cổng đang chờ").
- Chưa làm: cổng dành cho tổ đội / bảng xếp hạng dọn cổng (cần backend KT-09); cổng hạng S có boss riêng (đang dùng quái tinh anh của map phóng to).
