# Âm thanh sinh bằng code (C1-40, C1-41)

Mọi hiệu ứng và nhạc nền được **tổng hợp bằng code** (Python thư viện chuẩn: `wave`, `math`, `random`, `struct` — không cần cài thêm), giống cách sinh hình ở `tools/art/`. Chạy lại cho ra đúng các file cũ (seed cố định).

```bash
python tools/audio/gen_audio.py              # sinh tất cả (khoảng 20 giây)
python tools/audio/gen_audio.py slash boss   # chỉ sinh các id này
```

Kết quả: `godot/assets/audio/sfx/<id>.wav` và `godot/assets/audio/music/<id>.wav` — WAV 16-bit mono 22050 Hz. Lệnh in danh sách file kèm thời lượng.

## Hiệu ứng (`sfx.py`, 0,05–0,8 giây, đỉnh 0,85)

| id | Dùng cho | Cách tạo |
| --- | --- | --- |
| `slash` | Chém | Tiếng gió (nhiễu lọc cao) + sóng vuông trượt xuống |
| `shot` | Bắn cung | Dây cung (tam giác trượt lên) + gió |
| `hit` | Trúng đòn | Tiếng đập trầm 160 → 60 Hz + tiếng tách |
| `crit` | Chí mạng | `hit` + tiếng ngân cao |
| `enemy_die` | Quái chết | 5 nốt vuông đi xuống + bụi |
| `player_hurt` | Người chơi trúng đòn | Răng cưa trượt xuống, rung nhanh |
| `dodge` | Né lăn | Nhiễu quét bộ lọc lên |
| `perfect` | Né Hoàn hảo | 4 tiếng chuông đi lên |
| `pickup_gold` | Nhặt vàng | 2 nốt vuông nhanh |
| `pickup_item` | Nhặt đồ | 4 nốt tam giác đi lên |
| `levelup` | Lên cấp | Ngũ cung đi lên + hợp âm trưởng |
| `skill` | Dùng kỹ năng | Quét lên + lấp lánh |
| `ui_click` | Nút giao diện | Tiếng bíp 1.500 Hz |
| `boss_roar` | Boss gầm | Răng cưa trầm rung mạnh + hơi thở |
| `explode` | Nổ (bẫy, Nấm Con) | Sin trầm 120 → 40 Hz + nhiễu tắt dần |
| `heal` | Hồi máu | 5 nốt sin đi lên |
| `skill_blade` | Kỹ năng Kiếm Khách *(01/11)* | Ngân kim loại + gió |
| `skill_bow` | Kỹ năng Thợ Săn | 3 tiếng dây cung liền nhau |
| `skill_magic` | Kỹ năng Pháp Sư | Quét sáng đi lên + lấp lánh + ù trầm |
| `skill_shield` | Kỹ năng Hộ Vệ | Khiên va nặng + vang |
| `skill_summon` | Kỹ năng Triệu Hồi Sư | Hợp âm thứ đi lên + gió hồn |
| `ultimate` | Tối thượng / Thần Kỹ | Nổ trầm + hợp âm trưởng ngân dài |
| `unlock` | Mở kỹ năng mới | Kèn 3 nốt + chuông |
| `portal` | Tới map mới | Xoáy lung linh đi xuống rồi lên |
| `tele_elite` | Tinh anh bắt đầu lấy đà *(04/11, FX-1 §9.13)* | Gió vút lên (nhiễu lọc cao quét lên) + gầm gừ răng cưa |
| `tele_boss` | Boss bắt đầu lấy đà *(04/11)* | Răng cưa trầm 55 → 80 Hz + hơi thở lọc thấp dâng lên |

## Nhạc nền thế hệ 2 (MU-1, [docs/46](../../docs/46-nghien-cuu-nhac-nen.md)) — `songs2.py` + `inst2.py`

Thay nhạc chiptune cũ (`music.py`, mono 22 kHz, vòng 30–40 giây — giữ để tham khảo, không còn ghi file). Cần **numpy + soundfile** (`pip install numpy soundfile`).

```bash
python tools/audio/songs2.py                 # sinh 13 bài + 5 nhạc báo + 11 âm môi trường (song song, vài phút)
python tools/audio/songs2.py forest st_boss  # chỉ các id này
python tools/audio/songs2.py --list
```

Ra OGG Vorbis stereo 44,1 kHz: `godot/assets/audio/music/<id>.ogg`, `stinger/<id>.ogg`, `ambient/<id>.ogg`. Sinh xong mở Godot (hoặc `godot --headless --path godot --import`) để nhập file mới.

- `inst2.py`: nhạc cụ mô phỏng — đàn tranh, tỳ bà (vê), sáo trúc, đàn nhị, dàn dây, dây nảy, hợp xướng, contrabass, kèn trầm, taiko, trống khung, trống tay, mõ, chuông gió, chiêng; bàn trộn `Mix` (stereo, vang phòng tích chập, vòng lặp quấn đuôi nốt, độ lớn đích `target_db`); `write_ogg` ghi từng khối 1 giây (ghi một lần làm libsndfile 1.2.2 treo).
- `songs2.py`: `SONGS` — mỗi bài là dữ liệu (nhịp, chủ âm, vòng hợp âm La Mã từng đoạn, 2 câu giai điệu soạn tay theo độ lệch nửa cung, mỗi câu 32 phách, nhạc cụ theo vai); cấu trúc dạo đầu → A → B → C (lắng, đàn gảy hát lại A) → A' (+ bè) → kết. `STINGERS` (st_levelup, st_quest, st_region, st_boss, st_victory), `AMBIENTS` (vòng 40 giây liền mạch: gió, chim, côn trùng, ếch, giọt nước, dung nham, băng, chuông, ù trầm…).

| id | Nơi phát | Nhịp · giọng | Giai điệu A / B | Lặp |
| --- | --- | --- | --- | --- |
| `village` | Làng (vùng an toàn) | 76 · Rê trưởng ngũ cung | sáo / nhị, đàn tranh rải, trống khung | liền |
| `forest` | Vùng 1 Rừng Sương | 84 · La thứ ngũ cung | sáo / nhị | 1 lượt + nghỉ |
| `core` | Lõi Sương, hang | 64 · Mi thứ (Phrygian) | nhị / sáo, thưa, vang dài | liền |
| `plains` | Vùng 2 | 104 · Mi trưởng ngũ cung | sáo / nhị | 1 lượt + nghỉ |
| `desert` | Vùng 3 | 92 · La Hijaz | nhị / sáo, tỳ bà vê, trống tay | 1 lượt + nghỉ |
| `swamp` | Vùng 4 | 70 · Rê thứ ngũ cung | nhị / sáo trầm, mõ | 1 lượt + nghỉ |
| `volcano` | Vùng 5 | 124 · La thứ | nhị dồn, dây nảy, taiko, kèn | 1 lượt + nghỉ |
| `tundra` | Vùng 6 | 72 · La trưởng ngũ cung | đàn tranh / sáo, hợp xướng | 1 lượt + nghỉ |
| `sky` | Vùng 7 | 96 · Sol trưởng ngũ cung | sáo / nhị, hợp xướng | 1 lượt + nghỉ |
| `void` | Vùng 8 | 58 · Đô thang tối | nhị / sáo, chiêng | 1 lượt + nghỉ |
| `heaven` | Vùng 9 | 88 · Đô trưởng (chủ đề chính) | sáo / nhị, dàn đầy đủ | 1 lượt + nghỉ |
| `boss` | Trận boss | 140 · Rê thứ | nhị dồn, taiko, kèn, chiêng | liền |
| `boss_final` | Boss vùng 7–9 | 156 · Rê Hijaz | nhị dồn, taiko, hợp xướng | liền |

Phát trong game: `scripts/audio/audio_manager.gd` (nghỉ 30–90 giây sau mỗi lượt bài khám phá, âm môi trường bus "Ambient", nhạc báo hạ nhạc nền 8 dB); chọn bài / âm môi trường ở `main.gd` `_music_for`, `ambient_for`.

## Sửa, thêm âm

- Hiệu ứng mới: viết hàm trong `sfx.py`, thêm vào bảng `SFX`. Âm kỹ năng chọn theo lớp ở `GameWorld.SKILL_SFX` / `skill_sfx()`; nhạc theo vùng ở `main.gd` `REGION_MUSIC` (vùng an toàn: `village`, hang phụ: `core`).
- Bản nhạc mới: thêm 1 mục vào `SONGS` trong `songs2.py` (giai điệu mỗi câu đúng 32 phách), id vào `main.gd` `REGION_MUSIC`; bài cần lặp liền thêm vào `AudioManager.LOOP_IDS`.
- `synth.py`: dao động (vuông/tam giác/răng cưa/sin/nhiễu), bao hình ADSR, lọc 1 cực, tiếng vang, chuẩn hoá, ghi WAV.
