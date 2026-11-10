# 46. Nghiên cứu cải thiện nhạc nền (MU-1)

| Mục | Nội dung |
| --- | --- |
| Ngày | 09/11/2026 |
| Yêu cầu | [Spec_Notes](Spec_Notes.md): *"Người chơi comment — tiếng nhạc trong game giả quá, không giống như game hiện tại → hãy nghiên cứu và đề xuất cải thiện giúp tôi."* |
| Bản nghe thử | Bản thử 09/11 (`mu1-forest`, `mu1-boss`, công cụ `music2.py`) đã được thay bằng bản trong game: `godot/assets/audio/music/*.ogg` (13 bài), `stinger/*.ogg` (5), `ambient/*.ogg` (11). Công cụ: `tools/audio/songs2.py` + `inst2.py` |
| Trạng thái | ✅ **Đợt 1 đã làm 09/11/2026** — chủ dự án: "làm theo đề xuất" (Q224–Q228 theo cột Đề xuất §8), kết quả §9. ✅ **Đợt 2 (S4 tầng chiến đấu) đã làm 10/11/2026** — §10. |

## 1. Hiện trạng (đo từ file)

13 bản nhạc nền (`village`, `forest`, `core`, `boss`, `plains`… `heaven`, `boss_final`) do `tools/audio/music.py` sinh bằng code (C1-41, rà soát 01/11).

| Đặc điểm | Hiện có | Ghi chú |
| --- | --- | --- |
| Âm sắc | Sóng **vuông / tam giác / răng cưa / sin trần** — kiểu máy chơi game 8-bit (chiptune) | Không có nhạc cụ nào nghe ra là nhạc cụ thật |
| Định dạng | **Mono, 22.050 Hz**, 16-bit | Mất toàn bộ dải trên 11 kHz (độ "trong", tiếng gió, độ bóng của dây) và không có trái / phải |
| Không gian | Chỉ có tiếng vọng lặp (echo), **không có vang phòng** | Âm "khô", dính sát tai |
| Giai điệu | 4 motif 1 ô nhịp **sinh ngẫu nhiên** (đi lên / xuống 1–2 bậc), xếp A A B A | Không có câu hỏi – đáp, không có cao trào, không có điểm kết |
| Độ dài | Vòng lặp **29–44 giây**, phát liên tục không nghỉ | Sau 2–3 phút người chơi đã nghe cùng một vòng 4–5 lần |
| Biểu cảm | Mọi nốt đúng nhịp tuyệt đối, cùng lực, không rung, không luyến | Nghe "máy" |
| Chuyển nhạc | Mờ ra / vào 0,6 giây khi đổi vùng / gặp boss | Không có đoạn nối, không có nhạc báo (stinger) |
| Âm môi trường | Không có (gió, chim, suối… đều không) | Khi tắt nhạc thế giới im lặng |

Số đo (bản `forest` cũ): RMS −19,7 dB, trọng tâm phổ 3.384 Hz, 13% năng lượng trên 8 kHz (phần lớn là răng cưa / vuông chói, không phải độ trong), tương quan trái – phải 1,00 (mono).

## 2. Vì sao người chơi thấy "giả"

1. **Sai thể loại âm thanh so với hình ảnh.** Đồ hoạ đã lên HD cartoon (docs/39, 40), VFX vector HD (docs/36), nhưng nhạc vẫn là chiptune 8-bit. Chiptune không xấu, nhưng nó là phong cách "retro" có chủ đích; đặt cạnh hình HD thì nghe như nhạc tạm.
2. **Không nhạc cụ nào "thở".** Nhạc cụ thật có bao hình phức tạp (tiếng móng gảy, hơi thở, tiếng vĩ), rung cao độ, họa âm tắt không đều. Sóng trần thiếu tất cả các thứ đó.
3. **Không gian phẳng.** Mono + không vang = mọi nhạc cụ chồng lên một điểm. Nhạc game hiện đại luôn có không gian (trái / phải, gần / xa).
4. **Giai điệu không có ý.** Random walk trong thang ngũ cung luôn "nghe được" nhưng không đọng lại. Người chơi không nhớ được câu nào.
5. **Lặp quá ngắn và không nghỉ.** Vòng 30–40 giây lặp liên tục là nguyên nhân chính của cảm giác "nhạc máy" khi chơi lâu (game cày cấp, người chơi ở một vùng hàng giờ).

## 3. Game hiện đại làm thế nào (nhập vai châu Á, góc nhìn trên xuống)

| Cách làm | Ý nghĩa với game này |
| --- | --- |
| **Dàn nhạc + nhạc cụ dân tộc.** Các game nhập vai thế giới mở / MMORPG bối cảnh Á Đông thường dùng dàn dây làm nền, nhạc cụ dân tộc (đàn tranh, sáo trúc, đàn nhị, tỳ bà, trống) làm giai điệu và màu vùng. | Bối cảnh "Thiên Phú Khai Giới" (tu luyện, linh thú, Thiên Đạo) hợp với hướng này: mỗi vùng một nhạc cụ chủ đạo. |
| **Bài dài, có đoạn.** Nhạc khám phá thường dài 2–4 phút, có dạo đầu, đoạn chính, đoạn phát triển, kết. | Thay vòng 30–40 giây bằng bài ~2–3 phút (hoặc nối nhiều đoạn ngẫu nhiên — §5 S1). |
| **Nghỉ xen kẽ.** Nhạc khám phá không phát liên tục: hết bài thì vài chục giây chỉ còn âm môi trường rồi mới vào lại. | Giảm mệt tai khi cày lâu; khi nhạc vào lại thì người chơi để ý hơn. |
| **Nhạc theo tầng (adaptive).** Cùng một bài có tầng khám phá và tầng chiến đấu chạy đồng bộ; gặp quái thì tầng trống / dây nảy dâng lên, hết đánh thì lắng xuống — không cắt bài. | Godot 4.3+ có sẵn `AudioStreamSynchronized` (nhiều tầng cùng nhịp) và `AudioStreamInteractive` (chuyển đoạn theo nhịp). |
| **Nhạc báo (stinger).** Câu nhạc ngắn 2–5 giây cho sự kiện: boss xuất hiện, lên cấp, hoàn thành nhiệm vụ, mở vùng mới. | Hiện chỉ có SFX 0,5–0,8 giây (`levelup`, `boss_roar`). |
| **Âm môi trường theo vùng.** Gió, lá, chim, côn trùng, suối, dung nham, gió tuyết — luôn chạy dưới nhạc. | Lấp chỗ im khi nhạc nghỉ, làm thế giới "sống". |
| **Chủ đề nhạc (leitmotif).** Một câu nhạc chủ đề của game, xuất hiện biến tấu ở màn hình tiêu đề, làng, trận boss cuối. | Tăng nhận diện. |

## 4. Các hướng làm nhạc

| Hướng | Cách | Chất lượng | Chi phí / công | Rủi ro |
| --- | --- | --- | --- | --- |
| **A. Bộ tổng hợp mô phỏng nhạc cụ** *(đã làm thử — §6)* | Giữ cách "mọi thứ sinh bằng code" của dự án, nhưng thay sóng chip bằng mô hình nhạc cụ: dây gảy (họa âm tắt dần, nhấn nốt), sáo (hơi thở, rung trễ, luyến), nhị (vĩ kéo qua thân cộng hưởng, vuốt nốt), dàn dây nhiều bè, trống taiko, chiêng; stereo 44,1 kHz, vang phòng; giai điệu soạn tay theo câu. | Khá — rõ ràng "nhạc cụ", có không gian; vẫn nhận ra là tổng hợp ở nốt dài của nhị / kèn | Miễn phí; ~3–5 ngày cho đủ 13 bài + stinger | Trần chất lượng thấp hơn nhạc thu thật |
| **B. Soạn bằng code + phát bằng mẫu âm thật (sampler)** | Giữ phần soạn (nốt, nhịp, cấu trúc) trong code, nhưng mỗi nốt phát từ **mẫu thu âm nhạc cụ thật** có giấy phép mở (thư viện dàn nhạc miễn phí kiểu CC0). Viết bộ phát mẫu bằng numpy, không cần phần mềm ngoài. | Tốt với dàn dây / kèn / gõ; nhạc cụ Á Đông mẫu miễn phí **hiếm**, có thể phải trộn A cho tranh / sáo / nhị | Miễn phí – thấp; ~1 tuần (tìm mẫu, kiểm giấy phép, viết sampler) | Phải kiểm kỹ giấy phép từng thư viện mẫu cho bản phát hành thương mại; dung lượng mẫu |
| **C. Mua gói nhạc bản quyền (royalty-free)** | Mua gói nhạc "Asian fantasy / RPG" trên các chợ tài nguyên game, dùng thẳng. | Tốt – rất tốt (thu thật / sản xuất chuyên nghiệp) | Trả tiền một lần cho mỗi gói; nhanh nhất | Không độc quyền (game khác cũng dùng); khó khớp đúng 13 vùng; phải đọc kỹ điều khoản phát hành thương mại |
| **D. Thuê nhà soạn nhạc** | Đặt bài chủ đề + nhạc vùng + boss. | Tốt nhất, độc quyền, đúng chất game | Cao nhất; vài tuần | Ngân sách, quản lý đặt hàng |
| **E. Nhạc sinh bằng AI (dịch vụ tạo nhạc)** | Tạo bài từ mô tả chữ. | Nghe "thật" nhanh | Thấp | **Không khuyên dùng cho bản bán**: điều khoản quyền sử dụng thương mại khác nhau theo dịch vụ / gói và đang có tranh chấp pháp lý về dữ liệu huấn luyện; khó sửa chi tiết, khó làm tầng / vòng lặp chuẩn |

*Chi phí C / D không ghi số vì giá thay đổi theo chợ / người soạn — cần chủ dự án khảo giá nếu chọn.*

## 5. Cải tiến hệ thống phát nhạc (dùng được với mọi hướng ở §4)

| Mã | Việc | Code |
| --- | --- | --- |
| S1 | Bài khám phá 2–3 phút có đoạn (dạo đầu / A / B / A' / kết), hoặc 4–6 đoạn 20–30 giây nối ngẫu nhiên theo nhịp (đỡ lặp, nhẹ file) | `music2.py` + `AudioStreamPlaylist` / `AudioStreamInteractive` |
| S2 | **Nghỉ xen kẽ**: hết bài khám phá → 30–90 giây chỉ còn âm môi trường → bài vào lại (mờ vào 3 giây). Làng, hang, boss phát liên tục. | `audio_manager.gd` |
| S3 | **Âm môi trường theo vùng** (rừng: gió lá + chim; đồng bằng: gió lớn; sa mạc: gió cát; đầm lầy: ếch / côn trùng; núi lửa: dung nham sôi; băng nguyên: gió tuyết; thiên không: gió cao; hư vô: ù trầm), lớp riêng, bus riêng, có thanh âm lượng | `tools/audio` sinh + `audio_manager.gd` |
| S4 | **Tầng chiến đấu**: bài khám phá có tầng trống + dây nảy cùng nhịp; đánh quái thường → tầng dâng lên 1,5 giây, hết đánh 6 giây → lắng. Boss vẫn có bài riêng. | `AudioStreamSynchronized` |
| S5 | **Nhạc báo**: boss xuất hiện, lên cấp, hoàn thành chương / nhiệm vụ, mở vùng mới, Thiên phú tiến hoá; nhạc nền tự hạ 6 dB trong lúc nhạc báo phát | `audio_manager.gd` `stinger(id)` |
| S6 | Định dạng: stereo 44,1 kHz; nhập vào Godot với nén **QOA** (Godot 4.3+, nhẹ hơn WAV thô nhiều lần, giải nén rẻ) hoặc chuyển OGG Vorbis nếu có công cụ mã hoá | cài đặt import |
| S7 | Âm lượng trung bình giữ như cũ (~−18 dB khám phá, ~−15 dB boss) để người chơi không phải chỉnh lại thanh âm lượng | `music2.py` `target_db` |

## 6. Bản nghe thử (hướng A)

*(Bản thử 09/11 — đã thay bằng bản trong game ở §9; số đo dưới đây là của bản thử.)*

| File | Nội dung | Cấu trúc |
| --- | --- | --- |
| `mu1-forest.wav` | Rừng Sương (khám phá), La thứ ngũ cung, 84 BPM | Dạo đầu 4 ô (dàn dây + đàn tranh rải, chuông gió) → A 8 ô (**sáo trúc** hát giai điệu chính, trống khung nhẹ) → B 8 ô (**đàn nhị** đáp, mõ) → A' 8 ô (sáo + nhị bè dưới) → kết 4 ô; cuối mỗi đoạn có tiếng **vuốt dây đàn tranh** |
| `mu1-boss.wav` | Trận boss, Rê thứ, 140 BPM | 4 ô dây nảy + taiko + chiêng → giai điệu **đàn nhị** dồn dập, kèn đồng trầm, dàn dây → lặp lại quãng tám trên có sáo bè |

So với bản cũ (đo bằng cùng một công cụ):

| | `forest` cũ | `mu1-forest` | `boss` cũ | `mu1-boss` |
| --- | --- | --- | --- | --- |
| Kênh / tần số mẫu | mono 22 kHz | stereo 44,1 kHz | mono 22 kHz | stereo 44,1 kHz |
| Độ dài vòng lặp | 38 giây | 91 giây | 32 giây | 41 giây |
| RMS (độ lớn TB) | −19,7 dB | −18,0 dB | −17,1 dB | −15,5 dB |
| Dải động (đỉnh / TB) | 15,3 dB | 16,5 dB | 12,7 dB | 13,8 dB |
| Độ lớn theo đoạn (5 giây) | phẳng −19…−20 | −22 (dạo đầu) → −16…−18 (thân) → −20 (kết) | phẳng −17 | −17 → −15 |
| Trọng tâm phổ | 3.384 Hz (chói) | 1.913 Hz (ấm) | 2.649 Hz | 1.796 Hz |
| Tương quan trái – phải | 1,00 (mono) | 0,90 (có không gian) | 1,00 | 0,91 |
| Cắt tiếng (clip) | 0 | 0 | 0 | 0 |

**Lưu ý:** các số trên chỉ chứng minh bản mới ấm hơn, có không gian và có cấu trúc; **cảm nhận "thật / giả" phải do người nghe đánh giá** — mời chủ dự án nghe 2 file bằng tai nghe, so với bản cũ trong game.

Những chỗ dự kiến còn "lộ" là tổng hợp (sẽ cải thiện nếu chọn A, hoặc là lý do chọn B / C / D): nốt dài của đàn nhị và kèn đồng (thiếu biến đổi âm sắc theo vĩ / hơi), dàn dây hơi đều.

Bản thử sinh bằng `music2.py` (đã gộp vào `inst2.py` + `songs2.py`).

## 7. Đề xuất

1. **Đợt 1 (khuyên làm ngay): hướng A + S1, S2, S3, S5, S6, S7.** Làm lại đủ 13 bài theo cách của bản nghe thử, mỗi vùng một nhạc cụ chủ đạo (rừng: sáo; đồng bằng: sáo + dây; sa mạc: tỳ bà + trống tay, thang Hijaz; đầm lầy: nhị trầm + tiếng nước; núi lửa: taiko + kèn; băng nguyên: chuông + đàn tranh thưa; thiên không: sáo cao + hợp xướng tổng hợp; hư vô: dàn dây chênh + chiêng; thiên đạo: dàn đầy đủ, chủ đề chính), thêm âm môi trường + nhạc báo + nghỉ xen kẽ. Miễn phí, giữ nguyên cách làm "sinh bằng code" (sửa nốt / nhịp chỉ cần sửa dữ liệu).
2. **Đợt 2 (tuỳ chọn):** S4 tầng chiến đấu.
3. **Khi có ngân sách / trước khi phát hành:** cân nhắc D (đặt 1 bài chủ đề + nhạc boss cuối) hoặc C, giữ A cho phần còn lại. Hệ thống ở §5 dùng chung nên đổi file nào cũng không phải sửa code.

## 8. Câu hỏi cho chủ dự án (đã trả lời 09/11: "làm theo đề xuất" — lấy cột Đề xuất)

| Mã | Câu hỏi | Đề xuất |
| --- | --- | --- |
| Q224 | Nghe `mu1-forest.wav`, `mu1-boss.wav`: hướng A có đủ "thật" để làm tiếp không, hay đi thẳng B / C / D? | A cho đợt 1, D cho bài chủ đề sau |
| Q225 | Phong cách: dân tộc Á Đông (tranh, sáo, nhị, trống), dàn nhạc phương Tây, hay lai (dàn dây nền + nhạc cụ dân tộc làm giai điệu — như bản thử)? | Lai |
| Q226 | Có làm nghỉ xen kẽ (S2) + âm môi trường (S3) không? Nghỉ bao lâu? | Có; 30–90 giây ngẫu nhiên |
| Q227 | Tầng chiến đấu khi đánh quái thường (S4) — làm ở đợt 1 hay để sau? | Để đợt 2 |
| Q228 | Dung lượng: 13 bài stereo 2–3 phút + âm môi trường làm bản cài tăng thêm khoảng 60–80 MB nếu nén QOA (WAV thô sẽ ~350 MB), ít hơn nhiều nếu dùng OGG hoặc nối đoạn ngắn (S1). Chấp nhận? | Chấp nhận |

## 9. Kết quả triển khai đợt 1 (09/11/2026)

Hướng A + S1, S2, S3, S5, S6, S7. Code: `tools/audio/inst2.py`, `tools/audio/songs2.py`, `scripts/audio/audio_manager.gd`, `main.gd` (`ambient_for`, `REGION_AMBIENT`, nhạc báo ở `_handle_event`), `settings.gd` (`ambient`), `pause_menu.gd` (thanh "Âm thanh môi trường").

### 9.1. Bài nhạc (OGG Vorbis stereo 44,1 kHz)

| id | Độ dài | RMS | Ghi chú |
| --- | --- | --- | --- |
| `village` | 101 giây | −19 dB | lặp liền |
| `forest` | 119 giây | −18 dB | |
| `core` | 120 giây | −20 dB | lặp liền |
| `plains` | 97 giây | −18 dB | |
| `desert` | 109 giây | −18 dB | |
| `swamp` | 142 giây | −19 dB | |
| `volcano` | 82 giây | −16,5 dB | |
| `tundra` | 138 giây | −19 dB | |
| `sky` | 105 giây | −18 dB | |
| `void` | 170 giây | −20 dB | |
| `heaven` | 114 giây | −17 dB | chủ đề chính |
| `boss` | 55 giây | −15,5 dB | lặp liền |
| `boss_final` | 49 giây | −15 dB | lặp liền |

Bài khám phá + khoảng nghỉ 30–90 giây → mỗi vòng nghe 2,5–4 phút (cũ: 30–40 giây lặp liên tục). Nhạc báo: `st_levelup` 4,5 giây, `st_quest` 4, `st_region` 6, `st_boss` 5, `st_victory` 7. Âm môi trường: 11 vòng 40 giây, RMS −25…−28 dB (nằm dưới nhạc ~8 dB).

Dung lượng: nhạc 17 MB + nhạc báo / môi trường ~7 MB (cũ: 13 WAV mono ~20 MB, đã xoá). Thấp hơn nhiều mức 60–80 MB dự tính ở Q228 nhờ OGG.

### 9.2. Kiểm tra

- **MU1-T1** (`run_tests.gd`): đủ 13 bài OGG, bài khám phá ≥ 75 giây, bài lặp / không lặp đúng, nghỉ 30–90 giây, âm môi trường 9 vùng + làng + hang, 5 nhạc báo < 8 giây, Cài đặt `ambient` 0.7, `ambient_for` (làng / rừng), main nối nhạc báo.
- **`tests/mu1_play.gd`** (AudioManager thật trong cây scene, chạy headless được): forest phát không lặp → tua tới cuối → nghỉ → hết nghỉ vào lại; vào boss → `st_boss` + nhạc nền hạ còn 0,40; boss lặp; đổi âm môi trường mờ chéo; lên cấp: nhạc báo, bỏ âm `levelup` cũ. Kết quả: `MU1 PLAY ok`.
- Smoke test game: không lỗi script, `SMOKE audio music=forest`.
- **Chưa kiểm bằng tai trong game** — Claude không nghe được; cần chủ dự án / người chơi nghe và góp ý (bài nào to / nhỏ, nhạc cụ nào còn "giả"). Sửa nhanh: đổi số trong `SONGS` (nhịp, nhạc cụ, `target`) rồi `python tools/audio/songs2.py <id>` + mở Godot để nhập lại.

### 9.3. Còn lại

- ~~Đợt 2 — S4 tầng chiến đấu (Q227)~~ → đã làm 10/11, §10.
- Nốt dài của đàn nhị / kèn vẫn có thể lộ là tổng hợp (§6). Nếu người chơi còn chê, thay riêng các bài quan trọng (chủ đề `heaven`, `boss_final`) bằng hướng D, hệ thống phát giữ nguyên.

## 10. Đợt 2 — tầng chiến đấu (S4, 10/11/2026)

Chủ dự án: "triển khai đợt 2".

| Phần | Cách làm |
| --- | --- |
| File | 10 bài có tầng: 9 bài khám phá + `core` (hang có quái). `music/<id>_combat.ogg` sinh bằng `songs2.py` `render_layer` từ **cùng kế hoạch ô nhịp** với bài chính (`song_plan`) → cùng nhịp, cùng hợp âm, cùng độ dài (sai số < 0,05 giây). Nội dung: taiko lớn đầu phách 1 & 3 + taiko nhỏ nghịch phách, trống khung móc, dây nảy chạy (16 phần khi nhịp < 96, 8 phần khi nhanh hơn) trên chủ âm – quãng 5 của hợp âm, kèn trầm dâng mỗi 2 ô; nhẹ ở dạo đầu / kết. RMS −21 dB (hang / hư vô −22) — nằm dưới bài chính ~3 dB, cộng lại ~−16 dB khi đánh. |
| Phát | `AudioManager._start_pending`: bài có tầng → `AudioStreamSynchronized` 2 luồng (bài chính + tầng), luồng tầng ở `layer_db(combat_level)`. `set_combat(on)` — `main.gd` gọi mỗi khung với `GameWorld.in_combat()` (đánh / bị đánh trong 3 giây gần nhất). `step()`: `combat_level` dâng tới 1 trong `COMBAT_IN` 1,5 giây, lắng về 0 trong `COMBAT_OUT` 4 giây (tổng ~7 giây sau đòn cuối), đặt lại âm lượng luồng tầng mỗi khung — không cắt bài, không lệch nhịp. |
| Khi đang nghỉ (S2) | Vào trận → bài (có tầng) vào luôn, mờ vào 1,5 giây, không chờ hết khoảng nghỉ. |
| Không có tầng | Làng (khu an toàn), boss / boss cuối (bài boss đã dồn sẵn). |

Kiểm tra: MU1-T1 (đủ 10 tầng, cùng độ dài bài chính, làng / boss không có tầng, `layer_db`, main nối `set_combat`); `tests/mu1_play.gd` (forest phát dạng đồng bộ, tầng câm khi chưa đánh, dâng đủ sau ~1,5 giây, lắng dần khi hết đánh, đang nghỉ vào trận thì bài vào luôn). Dung lượng thêm ~11 MB.

**Cần nghe thử trong game**: độ to của tầng so với bài chính (đổi `LAYER_DB` trong `songs2.py`), tốc độ dâng / lắng (`COMBAT_IN` / `COMBAT_OUT` trong `audio_manager.gd`).
