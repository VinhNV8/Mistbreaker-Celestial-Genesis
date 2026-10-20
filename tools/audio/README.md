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

## Nhạc nền (`music.py`, vòng lặp liền mạch, đỉnh 0,6)

| id | Nơi phát | Nhịp | Giọng | Thời lượng |
| --- | --- | --- | --- | --- |
| `village` | Làng Thanh Thạch | 84 BPM | Rê ngũ cung trưởng — êm, sáng | 34,3 giây (12 ô nhịp) |
| `forest` | Rừng Sương | 100 BPM | La ngũ cung thứ — bí ẩn | 38,4 giây (16 ô nhịp) |
| `core` | Lõi Sương | 70 BPM | Mi ngũ cung thứ — u ám, thưa, tiếng vang dài | 34,3 giây (10 ô nhịp) |
| `boss` | Trận boss | 150 BPM | Rê ngũ cung thứ — dồn dập | 32,0 giây (20 ô nhịp) |

Mỗi bản gồm: giai điệu (4 motif sinh từ seed, xếp theo dạng A A B A…; nốt đầu ô nhịp kéo về âm của hợp âm), rải hợp âm, bass, trống chip (kick, snare, hi-hat), đệm ngân (village, core). Nốt và tiếng vang tràn qua cuối bài được **quấn về đầu bài**, và bước khử DC lọc trên tín hiệu nhân đôi, nên chỗ nối vòng lặp liền mạch. Trong Godot nên bật **Loop** khi import (hoặc `AudioStreamWAV.loop_mode = LOOP_FORWARD`, `loop_end = số mẫu`).

## Sửa, thêm âm

- Hiệu ứng mới: viết hàm trong `sfx.py`, thêm vào bảng `SFX`.
- Bản nhạc mới: thêm 1 mục vào `SONGS` trong `music.py` (nhịp, số ô nhịp, chủ âm MIDI, thang, vòng hợp âm, nhạc cụ, `form`). Giữ 24–40 giây.
- `synth.py`: dao động (vuông/tam giác/răng cưa/sin/nhiễu), bao hình ADSR, lọc 1 cực, tiếng vang, chuẩn hoá, ghi WAV.
