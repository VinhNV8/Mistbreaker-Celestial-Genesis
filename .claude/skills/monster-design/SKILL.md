---
name: monster-design
description: "Thiết kế và vẽ quái / boss / linh thú HD cho game Thiên Phú Khai Giới theo phong cách 'cartoon vẽ tay' đã chốt ở docs/39 (viền tối dày, cel-shade mềm, màu theo hệ, mắt phát sáng, dáng chunky). Dùng khi thêm quái mới, sửa hình quái, đổi màu / dáng quái, làm boss mới, hoặc khi người dùng nói 'design quái', 'vẽ quái', 'quái HD', 'boss mới', 'monster'."
---

# Skill: monster-design — quái HD theo phong cách docs/39

Quái HD **sinh bằng code** (Python + Pillow, thư viện vector `tools/art/hd/vec.py`), không vẽ tay, không AI tạo ảnh. Một danh mục khai báo tham số → bộ dựng theo dáng → sheet 5 hoạt ảnh → lớp phủ `manifest["hd"]["sprites"]` (bật / tắt ở Cài đặt → Đồ hoạ HD; bản pixel cũ vẫn còn).

Tài liệu gốc: `docs/39-thiet-ke-lai-quai-vat.md` (nghiên cứu ảnh mẫu, quy chuẩn, bảng thiết kế 94 con). **Ảnh duyệt trong `docs/design/monsters/` là spec** — game phải khớp ảnh duyệt.

## 1. Quy chuẩn phong cách (bắt buộc)

Rút ra từ ảnh mẫu Pinterest (bảng ~100 nhân vật cartoon vẽ tay trên nền đen). Chỉ học **phong cách**, không chép nhân vật nào của ảnh mẫu.

| # | Quy tắc | Cách làm trong code |
| --- | --- | --- |
| S1 | **Silhouette đọc được ở 50 px**: mỗi quái có 1 đặc điểm nhận diện từ xa (sừng, mũ trùm, vũ khí to, cánh, bờm, đuôi lửa) | Tham số `horns`, `head`, `weapon`, `wings`, `mane`, `tail` |
| S2 | **Dáng chunky**: đầu ≈ 1/3 chiều cao, vai rộng, bàn tay / bàn chân / vũ khí phóng to, chân ngắn | Có sẵn trong `mon_biped` (`body: normal / brute / thin`) |
| S3 | **Viền tối dày, ấm** (`#1b1022`, không đen tuyền), dày ≈ 2,4 đơn vị | `Frame.render(outline, width)` — không tắt viền thân |
| S4 | **Cel 3 tông** (nền / bóng tím lạnh / sáng kem ấm), nguồn sáng trên-trái | Dải màu `mon_kit.PAL`; thêm màu mới = thêm 1 bộ 3 (nền, bóng, sáng) |
| S5 | **Đầu sáng, chân tối** (chuyển sáng dọc) + **viền sáng ngược** dưới-phải | Tự động trong `Frame.render` (`grad`, `rim`) |
| S6 | **Một màu nhấn phát sáng** / quái: mắt, ngọc trượng, vết nứt, hào quang — cùng màu hệ | `eye`, `orb`, `cracks`, `aura`; vẽ ở lớp `front` / `back` (không viền) |
| S7 | **Mặt khuất = mắt sáng**: quái đội mũ trùm / mũ giáp / bóng tối chỉ lộ 2 mắt sáng | `head: hood / helm / shadow` |
| S8 | **Màu theo hệ & vùng** (bảng §2) — quái cùng vùng có cùng "họ màu", tinh anh / boss thêm vàng, vương miện, hào quang | `region`, `tier` trong danh mục |
| S9 | **Quay mặt phải, 3/4**, chân ở gốc (0, 0) của không gian 96 × 96 | Game tự lật khi đi trái |
| S10 | **Hoạt ảnh đủ 5**: idle 4 · run 4 · attack 3 (lấy đà → ra đòn → thu) · hurt 2 · death 3 | `mon_kit.build` tự dựng hurt / death; frame attack 0 phải đọc được là "lấy đà" (cửa sổ né) |

Không được: vẽ lại nhân vật người chơi (`pc-*`, `hero-*`) hay hình / hiệu ứng kỹ năng (bộ hình chủ dự án) — xem memory keep-owner-art. Linh thú Triệu Hồi Sư (`region: "pet"`) chỉ làm ảnh duyệt, **không** đưa vào game khi chưa được duyệt (Q190, `LIVE_EXCLUDE`).

## 2. Họ màu theo vùng

| Vùng | Hệ | Họ màu (tên trong `PAL`) | Màu nhấn |
| --- | --- | --- | --- |
| 1 Rừng Sương | Mộc | fur_grey, leaf, wood, purple (nấm) | lục `#c8ff7a`, vàng hổ phách |
| 2 Đồng Bằng Gió Hú | Kim | steel, iron, white, cloth_red | tím Hư Vô `#c080ff`, trắng gió |
| 3 Sa Mạc Xích Sa | Thổ | sand, sand_red, bandage, gold, chitin | lục độc `#9aff5a`, cam `#ff9a3c` |
| 4 Đầm Lầy U Minh | Thủy | swamp, toad, mud, sea, leech, purple | lục độc, tím mộng `#c28af0` |
| 5 Núi Viêm Long | Hỏa | ember, basalt, lava, gold | cam nham `#ff8a2a` / `#ffb040` |
| 6 Băng Nguyên | Thủy | snow, ice, frost, fur_snow, shadow | lam băng `#8ad8ff` |
| 7 Thiên Không | Kim/Mộc | sky, cloud, leaf_sky, marble, sky_gold | lam trời `#9ad8ff`, vàng `#fff0b0` |
| 8 Vực Hư Vô | Hư Vô | abyss, void, fur_void, silver, blood | hồng `#ff5ad0`, tím `#c080ff` |
| 9 Cổng Thiên Đạo | Ngũ hành | heaven_gold, jade, white, spirit | lam `#7ad0ff`, vàng thiên |

## 3. File

| File | Vai trò |
| --- | --- |
| `tools/art/hd/mon_kit.py` | Khung: không gian 96 × 96, 3 lớp (back / body / front), `PAL`, `Frame.part/flat/glow/eyes/shadow/render`, hurt / death chung, `build()` → sheet + meta |
| `tools/art/hd/mon_biped.py` | Dáng người: lính, pháp sư, cung thủ, xác ướp, xương, người đá / tuyết, bóng, boss người |
| `tools/art/hd/mon_beast.py` | Thú 4 chân: sói, hổ, gấu, thằn lằn, cá sấu, nhân sư, ngựa / kỳ lân, rồng có cánh |
| `tools/art/hd/mon_misc.py` | spirit, mushroom, treant, bird (phượng hoàng), bug (bọ cạp), serpent (đỉa, thuỷ quái nhiều đầu), frog, mirror, pylon, eye |
| `tools/art/hd/mon_catalog.py` | **Danh mục 94 quái**: id → builder + tham số + `concept` (ý tưởng) |
| `tools/art/hd/mon_build.py` | Dựng, tự hiệu chỉnh `size_mul` theo bản pixel, ảnh duyệt `docs/design/monsters/vung-*.png`, `--doc` in bảng thiết kế |
| `tools/art/hd/build_hd.py` | Ghi lớp phủ HD vào `godot/assets/art_manifest.json` (gọi `mon_build.build_all`) |

## 4. Quy trình thêm / sửa quái

1. **Có bản pixel trước** (skill `game-art`: id trong `monsters.gd` `DEFS` + `tools/art/catalog.py`) — bản HD hiệu chỉnh cỡ theo bản pixel cùng id.
2. **Viết ý tưởng** (1 câu `concept`): vai trò (thường / tinh anh / boss), đặc điểm nhận diện từ xa (S1), họ màu vùng (§2), màu nhấn phát sáng (S6), đòn đánh thể hiện trong tư thế attack.
3. **Khai báo** 1 mục `add(...)` trong `mon_catalog.py`. Ưu tiên dùng tham số có sẵn; dáng mới thật sự → viết hàm `draw(spec, pose)` mới (theo mẫu `mon_misc.frog`: dùng `Frame`, `attack_k`, `cyc`; vẽ từ xa ra gần: bóng → phía sau (dải `darker`) → thân → phía trước → đầu → vũ khí → mắt) và thêm vào `BUILDERS`.
4. **Dựng & xem**: `python tools/art/hd/mon_build.py <id>` → mở `docs/design/monsters/vung-<n>.png` bằng Read (ảnh). Kiểm: silhouette rõ ở cỡ nhỏ (dải hoạt ảnh 58 px), không mảng rời, mắt thấy được, vũ khí không bị tay che, frame attack 0 rõ là lấy đà, death không tràn khung, `size_mul` hợp lý (0,6–4,5; độ nét tự tính theo cỡ hiển thị). Sửa → dựng lại tới khi đạt. Lưu ý: dựng 1 id sẽ ghi đè ảnh duyệt vùng đó chỉ với id đó — dựng lại cả vùng trước khi gửi duyệt.
5. **Ghi vào game**: `python tools/art/hd/build_hd.py` (ghi `godot/assets/hd/sprites/<id>.png` + manifest), rồi `godot --headless --path godot --import`.
6. **Kiểm trong game**: test `MD1-T1` (`godot --headless --path godot --script res://tests/run_tests.gd -- --only=MD1`) và ảnh smoke (`godot --path godot -- --smoke=<thư mục>`): quái trên nền cỏ / tuyết / dưới tán cây.
7. **Cập nhật tài liệu**: bảng §4 docs/39 (`python tools/art/hd/mon_build.py --doc`), trạng thái MD-x ở docs/07 + docs/04, danh sách file ở docs/02 nếu thêm file.

## 5. Mẹo

- Toạ độ thiết kế: x phải là phía trước, y âm là lên. Thân người chuẩn: hông −17, vai −41, tâm đầu −53, bán kính đầu 10,5.
- `f.part(fn, tone, sd, ld)`: `sd` = độ dời bóng cel (to → mảng bóng dày), `ld` = viền sáng. Chi tiết nhỏ dùng `sd` 0,4–1.
- Màu phát sáng luôn đặt ở lớp `front` (`f.eyes`, `f.glow(..., front=True)`, `f.fx`) để không bị viền tối và không bị tối theo chuyển sáng dọc.
- Quái nhân bản / mồi nhử (cơ chế boss) phải **giống hệt** bản thật, khác biệt chỉ ở thứ kịch bản yêu cầu (vd `no_shadow`).
- Ở 24 px logic, chi tiết nhỏ hơn ~3 đơn vị thiết kế sẽ thành nhiễu — gom lại thành mảng lớn.
