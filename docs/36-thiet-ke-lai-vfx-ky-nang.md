# 36. Thiết kế lại hiệu ứng kỹ năng 5 lớp (FX-1)

| Mục | Nội dung |
| --- | --- |
| Ngày | 03/11/2026 |
| Yêu cầu | Chủ dự án: "nghiên cứu cách design skills trong pinterest.com/trangtrandamg/game-skill-effects → design lại skills cho toàn bộ class" |
| Phạm vi | Hình **khi thi triển** (VFX) của 70 kỹ năng chủ động (14 × 5 lớp). Không đổi sát thương, hồi chiêu, hitbox, icon UI |
| Bản duyệt | [docs/design/skills-fx/](design/skills-fx/) — 70 GIF 12 khung (HD) + 70 PNG dải 6 khung + 5 bảng tổng lớp |
| Trong game | `godot/scripts/view/fx1.gd` + `fx1_kit.gd` (vẽ vector HD), Cài đặt → "Hiệu ứng kỹ năng" |
| Công cụ | `tools/art/skill_fx_kit.py` (nguyên tố vẽ), `tools/art/skill_fx_design.py` (70 kỹ năng + xuất) |
| Trạng thái | ✅ **Đã duyệt và đưa vào game (03/11/2026)**: Q180 áp dụng cả 70 · Q181 song song · Q182 HD · Q183 theo thứ tự đề xuất (mục 8, 9) |

## Trạng thái hiện tại (04/11/2026) — đọc mục này trước

File này ghi theo dòng thời gian (§0–9.13), nhiều mục sau sửa mục trước. Trạng thái **đang chạy trong game**:

| Phần | Hiện tại | Chi tiết |
| --- | --- | --- |
| Hiệu ứng 70 kỹ năng | FX-1 vẽ vector HD, **mặc định cho cả 70**; Cài đặt → Hiển thị → "Hiệu ứng kỹ năng": FX-1 / FX-1 giữ hình đã duyệt / Hình cũ | §9.1–9.6 |
| Nguồn duyệt chính | **Ảnh chụp trong game** (`docs/design/skills-fx-ingame`, `tests/fx1_smoke.gd`); bản Python `docs/design/skills-fx` chỉ là phác ý tưởng | §9.10 |
| Hiệu năng | 1,25 ms / khung tình huống thực tế khi máy rảnh (1,7–2,1 ms khi máy chạy tiến trình khác); cảnh báo tự nhiên 20 quái lấy đà 0,65 ms (`tests/fx1_perf.gd`) | §9.7, §9.13 |
| Cảm giác đánh trúng | Rung + khựng đòn + âm nổ ở khung va chạm; cài đặt "Rung màn hình", "Giảm chớp sáng" (Trợ năng) | §9.8 |
| Cảnh báo đòn quái | **Kiểu tự nhiên (mặc định)** như ARPG: quái thường báo bằng động tác (co người, ngả, run, ánh loé, vệt bụi), tinh anh / boss / cơ chế chương có vết đất theo chất liệu nằm dưới quái, boss đậm hơn + quầng mép; âm báo tinh anh / boss. Cài đặt "Cảnh báo đòn quái": Tự nhiên / Rõ ràng (kiểu vòng / dải / nón §9.9–9.11) | §9.12, §9.13 |
| Vật che | Cây / đá che người chơi, boss, điểm rơi đòn tinh anh / boss hoặc thân quái lấy đà trong 300 px → mờ còn 40% | §9.13, §9.14 |
| Mọi nền / mù màu | Vết có nét sẫm dưới nét sáng (đọc được trên cát, mây, đá trắng, hư vô); chế độ mù màu: đỏ → cam, xanh lá → lam ngọc | §9.14 |
| Icon | Kỹ năng, bị động, Thiên phú, trang bị, tài nguyên, chỉ số: HD (chân dung giữ nguyên) | [37](37-icon-ky-nang.md) |

## 0. Tóm tắt

- Board tham khảo có 618 pin. Đã tải và xem trực tiếp 50 pin mới nhất. Khoảng 60% là bộ icon kỹ năng, 40% là hiệu ứng 2D: vụ nổ, tia sét, vệt chém, vòng phép, cầu năng lượng, khói.
- Điểm chung của các hiệu ứng đẹp trên board là **cel-shade 2D**: hình có 3–4 dải màu ranh giới cứng, lõi gần trắng, một lớp glow mềm phía sau, hình khối dứt khoát, và nhịp "vào nhanh, giữ khung va chạm, tan chậm".
- FX-1 đưa ngôn ngữ đó về lưới pixel của game, thành một bộ nguyên tố vẽ dùng chung: vệt trăng khuyết, sao va chạm, vòng xung kích, vòng trận, tia sét, cột sáng, khiên vòm, tia lửa, khói. Mỗi lớp có bảng màu và hình khối riêng.
- Đã có bản duyệt cho đủ **70/70 kỹ năng**. Sprite nhân vật, linh thú và quái trong ảnh là **hình gốc dán nguyên**, chỉ để làm ngữ cảnh, không vẽ lại.
- Hình đã duyệt trước đó (`docs/design/skills`, `skills-v2`, AR-44/45b/45d/46) **giữ nguyên**. FX-1 là phương án mới đặt song song để chủ dự án so sánh.

## 1. Ràng buộc

| # | Ràng buộc | Cách tuân thủ |
| --- | --- | --- |
| 1 | Không vẽ lại sprite nhân vật hoặc hình kỹ năng đã duyệt (rollback 03/11) | FX-1 nằm ở thư mục riêng `docs/design/skills-fx`. Nhân vật và linh thú cắt nguyên khung từ `godot/assets/sprites/pc-*`, `soi-bong`, `au-long`… |
| 2 | Không đổi gameplay | Chỉ vẽ hình. Phạm vi trên ảnh theo số liệu ở [22](22-danh-muc-ky-nang-lop-hien-tai.md) và [classes.gd](../godot/scripts/data/classes.gd) |
| 3 | Đọc được khi chơi | Có vòng cảnh báo trên đất cho kỹ năng đặt điểm. Quái trúng đòn nháy trắng. Buff có ký hiệu trên đầu. Tối thượng làm tối nền |
| 4 | Sinh bằng code, chạy lại được | Python + Pillow + numpy, dùng chung `pixel`/manifest của skill `game-art` |

## 2. Nghiên cứu board tham khảo

### 2.1. Nội dung board

| Nhóm | Ví dụ (tên pin / nguồn) | Điều rút ra |
| --- | --- | --- |
| Vụ nổ, va chạm | jkFX Explosion 04, "Bursts" (Real Time VFX), Sparks Radial, "Electric Explosion 2D FX" | Sao nhiều gai không đều + vòng mỏng + tia lửa bắn ra. Khung đầu gần như trắng |
| Vệt chém, xoáy | Bộ trăng khuyết xanh, "Arcane Fan VFX", vệt tím xoáy, nhân vật lướt chém của TaoziR | Trăng khuyết **thon hai đầu, dày ở 2/3 cung**. Nhiều lớp lệch nhau tạo chuyển động |
| Tia sét | Hướng dẫn "発光エフェクト" (Parblo), bolt trên nền xám, RTFX lightning | Sét gồm lõi trắng, viền màu và glow. Có 1–2 nhánh phụ. Bước 1 vẽ hình, bước 2 nhân lớp làm mờ, bước 3 tăng sáng lõi |
| Vòng phép, mặt đất | Vòng tím có hình người đứng giữa, vòng lửa, vòng rune xanh | Vòng nén dẹt theo góc nhìn. Mép sáng, có ký tự hoặc vạch quanh vành |
| Đạn bay | Fireball / meteor icon, đạn xanh có vòng đuôi, beam hồng, Gunshot | Đầu đạn sáng nhất. Đuôi thuôn dần, có thể có vòng khí phía sau |
| Khói, bụi | Bộ FX Artem Grechko (khói xám hai tông), Dofus × Deeamo "Animer des FX 2D" | Khói **hai tông phẳng**, phình rồi teo, kết thúc hiệu ứng nhẹ nhàng |
| Icon kỹ năng | Juggernaut Wars, A-Ravlik, 封神, Elemental Magic Icons, Hero Abilities (Julia Titova) | Mỗi hệ một màu chủ đạo. Hình khối đọc được ở kích thước nhỏ. Nền tối, hình sáng |

### 2.2. Tám nguyên tắc áp dụng

1. **Bốn dải màu cứng**: viền tối → màu bão hoà → màu sáng → lõi trắng. Ranh giới dải là đường cứng, không chuyển mượt.
2. **Glow cộng sáng, lượng tử hoá** 3 bậc. Glow có độ mềm nhưng vẫn hợp lưới pixel.
3. **Hình khối dứt khoát.** Đạn có đầu nhọn và đuôi thuôn. Vệt chém thon hai đầu. Va chạm là sao nhiều gai không đều.
4. **Nhịp anticipation → impact → dissipate.** 4 khung tụ lực, 1 khung phát, khung va chạm giữ lâu nhất (190 ms), 6 khung tan với khung cuối 260 ms.
5. **Ba lớp chuyển động** trong một hiệu ứng: hình chính, hạt (tia lửa, mảnh vỡ), khói/bụi.
6. **Mặt đất là thông tin**: vòng cảnh báo, vết nứt và vòng xung kích cho biết đúng phạm vi.
7. **Màu = hệ / nhánh.** Người chơi nhận ra kỹ năng từ màu trước khi thấy hình.
8. **Độ lớn theo cấp kỹ năng.** Kỹ năng cấp 1 gọn. Chuyển chức sáng hơn. Tối thượng làm tối nền và có chớp sáng. Kỹ năng cấp 90 chiếm cả khung.

## 3. Ngôn ngữ hình ảnh FX-1

### 3.1. Nhịp 12 khung (dùng chung)

| Khung | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Pha | tụ lực | tụ lực | tụ lực | tụ lực | phát | **va chạm** | tan | tan | tan | tan | tan | tan |
| ms | 110 | 90 | 80 | 70 | 50 | **190** | 80 | 80 | 90 | 100 | 110 | 260 |

Tổng 1,31 giây. Trong game, nhịp này co giãn theo thời gian thật của kỹ năng (mục 7). Kỹ năng kéo dài như vùng hoặc kênh lặp lại các khung 5–10.

### 3.2. Bộ nguyên tố (skill_fx_kit.py)

| Nguyên tố | Hàm | Dùng cho |
| --- | --- | --- |
| Vệt trăng khuyết | `crescent` | chém, xoáy, cánh chim, sóng âm |
| Vệt thẳng thuôn | `streak` | lao, đuôi đạn, tia sáng |
| Sao va chạm | `star` | mọi va chạm, nổ |
| Vòng xung kích / vòng đất | `ring`, `decal` | phạm vi, cảnh báo, trận pháp |
| Tia sét | `bolt` | sét chuỗi, sét trời, totem |
| Cột sáng | `pillar` | triệu hồi, buff, thánh quang |
| Khiên vòm | `dome` | Pháp Thuẫn, Thành Bất Diệt, Thành Đồng |
| Tia lửa, khói | `sparks`, `smoke` | lớp hạt và lớp tan |
| Biểu tượng | `sword`, `arrow`, `shard`, `shield`, `orb`, `hammer`, `glyph` | đạn, buff, choáng, trói, độc |

Có 11 nguyên mẫu ghép từ các nguyên tố trên (`a_spin`, `a_dash`, `a_projectile`, `a_buff`, `a_rain`, `a_explode`, `a_chain`, `a_summon`, `a_field`, `a_meteor`, `a_trap`). Mỗi kỹ năng chọn một nguyên mẫu rồi thêm chi tiết riêng.

### 3.3. Quy tắc đọc gameplay

| Tình huống | Hiển thị |
| --- | --- |
| Kỹ năng đặt điểm (mưa, thiên thạch, trận) | Vòng trận trên đất xuất hiện **trước** khi sát thương đến, đúng bán kính |
| Quái trúng đòn | Nháy trắng 1 khung, rung 1 px, sao va chạm có màu của kỹ năng |
| Choáng / trói / độc | Sao xoay, vòng xích, giọt độc trên đầu. Độc hiện số tầng cộng dồn bằng số giọt |
| Buff | Cột sáng 1 khung, vòng chân, hạt bay lên, biểu tượng trên đầu |
| Tối thượng (cấp 45 / 90) | Nền tối 35–55%, chớp sáng cộng sáng ở khung va chạm |
| Hồi máu | Hạt xanh lá bay lên. Màu này dành riêng cho hồi máu, không dùng cho sát thương |

## 4. Bản sắc từng lớp

| Lớp | Chủ đề | Bảng màu chính → nhánh | Hình khối | Chuyển động |
| --- | --- | --- | --- | --- |
| Kiếm Khách | Kiếm Khí | đỏ son `#ff4248` → Kiếm Thánh vàng thánh `#f2b83a`, Huyết Kiếm máu sẫm `#b80c2a`, Kiếm Thần bạch lam `#78c4ff` | Đường cong: trăng khuyết, kiếm | Nhanh, cắt ngang, dư ảnh |
| Thợ Săn | Phong Tiễn | ngọc bích `#2fd090` + vàng ưng `#e09a1e`; độc `#62b81c`, bẫy gỉ sắt `#d2581c`, tinh tú `#a4b4ff` | Đường thẳng, mũi tên, lông vũ | Chính xác, vệt dài, nhịp dồn |
| Pháp Sư | Nguyên Tố | Hoả `#ff6418`, Băng `#54c2ff`, Lôi `#9e6cff`, Huyền `#cc4cff`, Tử Linh `#5ec83e` + tím sẫm; Ngũ Hành có 5 dải | Hình tròn, rune, gai băng, sét gãy | Tụ lực rõ, nổ lớn |
| Hộ Vệ | Thánh Thuẫn | vàng kim `#f0be3a`, thép lam `#86a6d0`, đất đá `#a26a3a` | Khối vuông/khiên, búa, vết nứt | Nặng, nện xuống, rung |
| Triệu Hồi Sư | Linh Hồn | tím linh `#9868ff` + ngọc lam `#2ebeae`; rồng `#ff7626`, lôi `#6caeff`, phong `#46cfa0`, kỳ lân vàng-lam | Xoắn, vòng trận, cột sáng | Bay lên, xuất hiện từ ánh sáng |

## 5. Danh mục 70 kỹ năng

Mỗi kỹ năng có file `NN-<id>.gif` (12 khung, có dải tiến trình) và `NN-<id>.png` (khung 1, 3, 4, 5, 7, 10). Cột "Tụ lực → Va chạm → Tan" mô tả 3 pha.

### 5.1. Kiếm Khách — [bảng tổng](design/skills-fx/kiem-khach.png)

| # | Kỹ năng | Nguyên mẫu | Tụ lực → Va chạm → Tan | Màu |
| ---: | --- | --- | --- | --- |
| 1 | [Xoáy Kiếm](design/skills-fx/kiem-khach/01-spin.gif) | xoáy | trăng khuyết cuộn ngược sau lưng → 3 trăng khuyết xoay 1,6 vòng nở ra 12,5 m → vòng đất mờ + bụi | đỏ son |
| 2 | [Đột Kích](design/skills-fx/kiem-khach/02-dash.gif) | lao | tia ngắm mảnh trên đường → vệt lao + 3 dư ảnh, sao va chạm trên từng quái → vệt tắt dần | đỏ son |
| 3 | [Trảm Phong](design/skills-fx/kiem-khach/03-wave.gif) | đạn | tụ ở mũi kiếm → trăng khuyết lớn bay xuyên → tia lửa | đỏ son |
| 4 | [Kiếm Ý](design/skills-fx/kiem-khach/04-kiemy.gif) | buff | vòng trận chân → cột sáng → 2 kiếm xoay quanh người, kiếm trên đầu | đỏ son |
| 5 | [Nguyệt Ảnh Liên Trảm](design/skills-fx/kiem-khach/05-lientram.gif) | lướt + chuỗi | lướt tới (dư ảnh) → 3 nhát trăng khuyết các hướng khác nhau → trăng khuyết bạc khép chuỗi | đỏ + bạc |
| 6 | [Hống Kiếm](design/skills-fx/kiem-khach/06-hongkiem.gif) | nổ quanh thân | vòng co lại + hạt hút vào → sao nổ, 8 kiếm khí toả tròn → sao choáng | đỏ son |
| 7 | [Kiếm Vũ](design/skills-fx/kiem-khach/07-kiemvu.gif) | quỹ đạo | tụ lực → 4 kiếm bay quanh, vệt quỹ đạo, trúng mỗi nhịp → tắt | đỏ son |
| 8 | [Phi Kiếm](design/skills-fx/kiem-khach/08-phikiem.gif) | đạn ×3 | tụ lực → 3 kiếm toả 30° có vệt đuôi → va chạm xuyên | đỏ son |
| 9 | [Vạn Kiếm Quy Tông](design/skills-fx/kiem-khach/09-vankiem.gif) | mưa (tối thượng) | nền tối, hàng kiếm hiện trên trời → mưa kiếm lớn trong vòng 15 m → bụi | đỏ son |
| 10 | [Thánh Kiếm Trảm](design/skills-fx/kiem-khach/10-thanhkiem.gif) | tia | thánh kiếm hiện trước tay → tia vàng dài 50 m + chớp → tia thu hẹp | vàng thánh |
| 11 | [Kiếm Vực](design/skills-fx/kiem-khach/11-kiemvuc.gif) | vùng | vòng trận nở → 8 kiếm cắm quanh mép, kiếm rơi mỗi nhịp → tắt | vàng thánh |
| 12 | [Huyết Bạo](design/skills-fx/kiem-khach/12-huyetbao.gif) | nổ quanh thân | giọt máu bốc từ người (đốt HP) → nổ máu → cầu máu bay về người (hút) | máu sẫm |
| 13 | [Huyết Ảnh](design/skills-fx/kiem-khach/13-huyetanh.gif) | lao ×2 | tụ lực → 2 lần lao, dấu chém chữ X → va chạm kép | máu sẫm |
| 14 | [Nhất Kiếm Khai Thiên](design/skills-fx/kiem-khach/14-nhatkiem.gif) | chém xẻ trời (cấp 90) | nền tối, kiếm lớn dần 0,5 s → chớp trắng, đường chém cả khung + chuỗi trăng khuyết → tia lửa | bạch lam |

### 5.2. Thợ Săn — [bảng tổng](design/skills-fx/tho-san.png)

| # | Kỹ năng | Nguyên mẫu | Tụ lực → Va chạm → Tan | Màu |
| ---: | --- | --- | --- | --- |
| 1 | [Vũ Tiễn](design/skills-fx/tho-san/01-rain.gif) | mưa | bắn lên trời, vòng đất 9 m → tên rơi lệch, mỗi tên một sao nhỏ → bụi | ngọc bích |
| 2 | [Xuyên Tâm Tiễn](design/skills-fx/tho-san/02-pierce.gif) | đạn xuyên | tụ ở dây cung → tên lớn vệt dài → vòng vàng trên mỗi quái bị xuyên | ngọc + vàng |
| 3 | [Lộn Nhào](design/skills-fx/tho-san/03-lanban.gif) | đạn ×3 + né | trăng khuyết cuộn (lộn) → 3 tên toả 24° → gió xoáy quanh chân (buff né) | ngọc bích |
| 4 | [Ưng Nhãn](design/skills-fx/tho-san/04-eagle.gif) | buff | vòng trận → cột sáng → mắt ưng + hai cánh trên đầu | vàng ưng |
| 5 | [Tên Nảy](design/skills-fx/tho-san/05-tennay.gif) | chuỗi | tụ lực → tên đổi hướng qua 4 mục tiêu, có tia nối → sao trên từng mục tiêu | ngọc bích |
| 6 | [Bẫy Gai](design/skills-fx/tho-san/06-trap.gif) | bẫy | ném bẫy theo vòng cung → bẫy nhấp nháy → gai bật, nổ, vòng trói | gỉ sắt + ngọc |
| 7 | [Liên Xạ](design/skills-fx/tho-san/07-lienxa.gif) | liên thanh | tụ ngắn → 8 tên dồn dập, chớp ở đầu cung → va chạm liên tiếp | ngọc bích |
| 8 | [Tên Độc](design/skills-fx/tho-san/08-tendoc.gif) | đạn + độc | tụ lực → tên độc xuyên → vũng độc, giọt độc theo số tầng | độc |
| 9 | [Thiên Tiễn Vũ](design/skills-fx/tho-san/09-thientien.gif) | mưa (tối thượng) | nền tối, vòng 20 m → mưa tên dày → bụi | ngọc bích |
| 10 | [Phá Không Tiễn](design/skills-fx/tho-san/10-phakhong.gif) | tia | 3 vòng khí nén trước cung → tia xuyên 70 m + chớp → dấu "chí mạng" trên quái | tinh tú |
| 11 | [Tam Liên Thần Tiễn](design/skills-fx/tho-san/11-tamlien.gif) | đạn ×3 nối tiếp | tụ lực → 3 phát, mỗi phát một màu (ngọc / vàng / tinh tú) → va chạm | 3 dải |
| 12 | [Bãi Mìn](design/skills-fx/tho-san/12-baimin.gif) | bẫy ×5 | rải 5 mìn quanh người → đèn đỏ nhấp nháy → nổ từng điểm | gỉ sắt |
| 13 | [Lưới Bẫy](design/skills-fx/tho-san/13-luoibay.gif) | ném + vùng | lưới bay theo vòng cung, bung rộng dần → lưới phủ vùng 8 m → xích trói | ngọc bích |
| 14 | [Thiên Lạc Tinh Vũ](design/skills-fx/tho-san/14-tinhvu.gif) | mưa sao (cấp 90) | nền tối, sao lấp lánh trên trời → 8 tên sao rơi chéo vào từng mục tiêu → nổ sao | tinh tú |

### 5.3. Pháp Sư — [bảng tổng](design/skills-fx/phap-su.png)

| # | Kỹ năng | Nguyên mẫu | Tụ lực → Va chạm → Tan | Màu |
| ---: | --- | --- | --- | --- |
| 1 | [Sét Chuỗi](design/skills-fx/phap-su/01-chain.gif) | chuỗi | tụ ở trượng → sét gãy khúc nảy 5 mục tiêu, có nhánh phụ → tia lửa | Lôi |
| 2 | [Băng Lao](design/skills-fx/phap-su/02-banglao.gif) | đạn | tụ lực → mũi băng xuyên → vòng băng + gai nhỏ dưới chân (làm chậm) | Băng |
| 3 | [Thiên Thạch](design/skills-fx/phap-su/03-meteor.gif) | rơi | vòng rune 10 m lớn dần → thiên thạch rơi chéo, đuôi lửa → nổ, đá văng, khói | Hoả |
| 4 | [Pháp Thuẫn](design/skills-fx/phap-su/04-barrier.gif) | khiên | vòng trận → vòm khiên lưới lục giác dâng lên → vết nứt tăng dần khi bị đánh | Huyền |
| 5 | [Hoả Tường](design/skills-fx/phap-su/05-hoatuong.gif) | vùng | đường rune → 9 ngọn lửa dao động + tàn lửa bay → trúng mỗi nhịp | Hoả |
| 6 | [Băng Ngục](design/skills-fx/phap-su/06-nova.gif) | nổ quanh thân | vòng co + hạt hút → nổ băng 11 m, 10 gai băng mọc → sương + vòng trói | Băng |
| 7 | [Mưa Băng](design/skills-fx/phap-su/07-muabang.gif) | mưa | vòng xanh → mảnh băng rơi 5 nhịp → vỡ | Băng |
| 8 | [Cầu Sấm](design/skills-fx/phap-su/08-causam.gif) | cầu bay | tụ lực → cầu sấm bay chậm, phóng sét vào quái gần → nổ điện ở cuối | Lôi |
| 9 | [Thiên Tai Nguyên Tố](design/skills-fx/phap-su/09-thienhoa.gif) | 3 pha (tối thượng) | nền tối, vòng trận → **Hoả** nổ cam → **Băng** gai lam → **Sét** trắng tím trên 4 quái | 3 dải tách |
| 10 | [Thiên Lôi](design/skills-fx/phap-su/10-thienloi.gif) | sét trời | nền tối → cột sét từ trời đánh lần lượt từng quái, vòng dưới chân → tia lửa | Lôi |
| 11 | [Băng Phong Thiên Hạ](design/skills-fx/phap-su/11-bangphong.gif) | nổ quanh thân lớn | như Băng Ngục nhưng 14 m, 16 gai, nền tối nhẹ | Băng |
| 12 | [Triệu Hồi Xương](design/skills-fx/phap-su/12-trieuhoi.gif) | triệu hồi ×3 | 3 vòng trận → 3 cột sáng → 3 Xương Nô hiện từ ánh sáng | Tử Linh |
| 13 | [Khí Độc Tử Vong](design/skills-fx/phap-su/13-khidoc.gif) | vùng | vòng trận → mây độc xoay, bong bóng bay lên → giọt độc cộng dồn trên quái | Tử Linh |
| 14 | [Ngũ Hành Luân Chuyển](design/skills-fx/phap-su/14-nguhanh.gif) | quỹ đạo (cấp 90) | vòng 5 rune → 5 cầu Kim/Mộc/Thuỷ/Hoả/Thổ quay, mỗi cầu một màu → hội tụ nổ | 5 dải |

### 5.4. Hộ Vệ — [bảng tổng](design/skills-fx/ho-ve.png)

| # | Kỹ năng | Nguyên mẫu | Tụ lực → Va chạm → Tan | Màu |
| ---: | --- | --- | --- | --- |
| 1 | [Khiên Chấn](design/skills-fx/ho-ve/01-khienchan.gif) | nón | tụ ở khiên → khiên đẩy tới + sóng nón 90° → sao choáng | thép lam |
| 2 | [Khiêu Khích](design/skills-fx/ho-ve/02-khieukhich.gif) | nổ quanh thân | sóng vàng 12 m → dấu chevron kéo quái về, mắt đỏ trên đầu quái (bị khiêu khích) | vàng kim |
| 3 | [Lao Khiên](design/skills-fx/ho-ve/03-laokhien.gif) | lao | tụ lực → khiên dẫn đầu, vệt lao, dư ảnh → va chạm đẩy lùi | thép lam |
| 4 | [Khiên Thép](design/skills-fx/ho-ve/04-khienthep.gif) | buff | vòng trận → cột sáng → 4 khiên nhỏ xoay quanh, khiên trên đầu | thép lam |
| 5 | [Chấn Địa](design/skills-fx/ho-ve/05-chandia.gif) | nổ quanh thân | tụ lực → nện đất 10 m, đá văng → sao choáng + bụi | đất đá |
| 6 | [Phi Thuẫn](design/skills-fx/ho-ve/06-phanthuan.gif) | bay đi rồi về | tụ lực → khiên xoay bay xuyên 3 quái → quay về, trúng lần 2 | thép lam |
| 7 | [Phán Quyết](design/skills-fx/ho-ve/07-phanquyet.gif) | rơi | vòng rune → búa ánh sáng giáng theo cột sáng → nổ vàng, đá văng | vàng kim |
| 8 | [Xung Phong](design/skills-fx/ho-ve/08-xungphong.gif) | lao | tụ lực → lao 25 m, 4 dư ảnh, bụi → sao choáng | vàng kim |
| 9 | [Thành Bất Diệt](design/skills-fx/ho-ve/09-thanhbatdiet.gif) | buff + vùng (tối thượng) | cột sáng → vòm vàng + 6 khiên xoay ngược + sóng mỗi nhịp → trúng quái gần | vàng kim |
| 10 | [Thánh Quang Trảm](design/skills-fx/ho-ve/10-thanhquang.gif) | nón | tụ lực → trăng khuyết sáng nón 120° lan rộng → hạt hồi máu xanh lá | vàng kim + hồi máu |
| 11 | [Thánh Vực](design/skills-fx/ho-ve/11-thanhvuc.gif) | vùng theo người | vòng trận → 6 cột sáng xoay + hạt bay lên → hạt hồi máu mỗi nhịp | vàng kim |
| 12 | [Thiết Chuỳ Phá Địa](design/skills-fx/ho-ve/12-thietchuy.gif) | nện | búa giơ cao → nện, sao lớn, vòng 12 m → 7 vết nứt toả + đá văng + sao choáng | đất đá + thép |
| 13 | [Thành Đồng](design/skills-fx/ho-ve/13-thanhdong.gif) | nổ + khiên | khiên lớn dần → nổ khiên → vòm khiên dựng lên | thép lam |
| 14 | [Thiên Thuẫn Giáng Thế](design/skills-fx/ho-ve/14-thienthuan.gif) | rơi (cấp 90) | nền tối, vòng rune lớn → khiên thần giáng theo cột sáng → nổ + vòm khiên lớn | vàng kim |

### 5.5. Triệu Hồi Sư — [bảng tổng](design/skills-fx/trieu-hoi-su.png)

| # | Kỹ năng | Nguyên mẫu | Tụ lực → Va chạm → Tan | Màu |
| ---: | --- | --- | --- | --- |
| 1 | [Triệu Hồi Sói Bóng](design/skills-fx/trieu-hoi-su/01-soibong.gif) | triệu hồi | vòng trận xoay → cột sáng → Sói Bóng hiện từ trắng → sóng + hạt bay lên | tím linh |
| 2 | [Linh Tiễn](design/skills-fx/trieu-hoi-su/02-linhtien.gif) | đạn ×5 | tụ lực → 5 cầu linh hồn toả 40° → va chạm | ngọc lam |
| 3 | [Triệu Hồi Tiểu Quỷ](design/skills-fx/trieu-hoi-su/03-tieuquy.gif) | triệu hồi ×3 | 3 vòng lệch nhịp → 3 cột → 3 Tiểu Quỷ | tím linh |
| 4 | [Liên Kết Linh Hồn](design/skills-fx/trieu-hoi-su/04-lienket.gif) | dây nối | tụ lực → dây sóng nối người với linh thú, hạt chạy dọc dây → vòng buff dưới linh thú | ngọc lam |
| 5 | [Gọi Thạch Quỷ](design/skills-fx/trieu-hoi-su/05-thachquy.gif) | triệu hồi | vòng trận → cột đất → Thạch Quỷ hiện, đá văng | đất đá |
| 6 | [Hoả Điểu](design/skills-fx/trieu-hoi-su/06-hoadieu.gif) | đạn | tụ lực → chim lửa (thân cầu + 2 cánh trăng khuyết vỗ) bay xuyên → tàn lửa trên quái | rồng |
| 7 | [Linh Trận](design/skills-fx/trieu-hoi-su/07-linhtran.gif) | vùng | vòng trận lớn → 6 hạt quay + vòng trong → dấu buff trên linh thú đứng trong trận | tím linh |
| 8 | [Gọi Linh Ưng](design/skills-fx/trieu-hoi-su/08-linhung.gif) | triệu hồi ×2 | 2 vòng → 2 cột → 2 Linh Ưng hiện rồi bắn tia | ngọc lam |
| 9 | [Quân Đoàn Linh Hồn](design/skills-fx/trieu-hoi-su/09-quandoan.gif) | triệu hồi ×10 (tối thượng) | nền tối, vòng 50 → 10 cột nối tiếp → đủ 10 linh hồn, **đếm được** | tím linh |
| 10 | [Gọi Ấu Long](design/skills-fx/trieu-hoi-su/10-aulong.gif) | triệu hồi | vòng trận → cột lửa → Ấu Long hiện → phun lửa nổ lan | rồng |
| 11 | [Long Hống](design/skills-fx/trieu-hoi-su/11-longhong.gif) | nổ quanh thân | tụ lực → sóng âm quanh người + 3 sóng trăng khuyết từ Ấu Long → va chạm | rồng |
| 12 | [Lôi Đồ Đằng](design/skills-fx/trieu-hoi-su/12-loidodang.gif) | totem | cột sáng cắm xuống → totem có cầu sấm → sét đánh 3 quái mỗi nhịp | lôi |
| 13 | [Phong Đồ Đằng](design/skills-fx/trieu-hoi-su/13-phongdodang.gif) | totem + vùng | vòng trận → totem + 3 trăng khuyết gió xoay (làm chậm) → linh thú chạy nhanh (buff) | phong |
| 14 | [Kỳ Lân Giáng Thế](design/skills-fx/trieu-hoi-su/14-kylan.gif) | triệu hồi (cấp 90) | nền tối, vòng lớn → cột vàng → Kỳ Lân hiện, linh thú quanh được hồi máu → nổ lan | kỳ lân |

## 6. Công cụ và cách chạy

```bash
python tools/art/skill_fx_design.py              # 70 kỹ năng, khoảng 50 giây
python tools/art/skill_fx_design.py spin meteor  # chỉ vài id, không ghi bảng tổng
```

- Khung cảnh 192×112 đơn vị. **HD (Q182):** vẽ ở ×6 (`HD = 6`) rồi thu về ×3 bằng Lanczos (576×366 kèm dải chú thích), nên nét hiệu ứng mịn, không còn răng cưa pixel. Sprite gốc chỉ phóng to Nearest, không vẽ lại. Đặt `HD = 1` thì ra bản pixel cũ. Bảng tổng lớp ×2.
- GIF duyệt xuất ở 75% kích thước với 128 màu cho nhẹ repo (thư mục 30 → 23 MB); PNG dải khung giữ đủ độ phân giải.
- Thêm kỹ năng: viết `xx_<id>(f)` trả `Scene` (thường gọi một nguyên mẫu `a_*`) rồi thêm vào `SKILLS`.
- Thư viện cần có: Pillow, numpy (đã có trong Python 3.14 của máy dự án).

## 7. Đưa vào game — kế hoạch ban đầu (đã thay bằng mục 9)

| Bước | Nội dung |
| --- | --- |
| FX-2 | Tách lớp: xuất mỗi kỹ năng thành sheet 12 khung **chỉ có hiệu ứng** (nền trong suốt, không sprite), hai lớp `fx-skill-<id>` (thường) + `fx-skill-<id>-glow` (vẽ với `CanvasItemMaterial.BLEND_MODE_ADD`). Hình đặt theo neo: thân / điểm ngắm / đường bay |
| FX-3 | `view/class_fx.gd`: phát sheet theo thời gian thật của kỹ năng (co giãn 12 khung theo `dur`, lặp khung 5–10 cho vùng/kênh). Dùng chung đường vẽ `_draw_source_phase` của AR-46 (mở rộng 3 → 12 khung). Giữ nguyên dữ liệu `classes.gd` |
| FX-4 | Đưa vào theo lớp, mỗi lớp một lần duyệt. Thứ tự đề xuất là Pháp Sư → Thợ Săn → Triệu Hồi Sư → Hộ Vệ, vì các lớp này hiện chỉ có hình review. Kiếm Khách để cuối vì đã có AR-45b/45d do chủ dự án duyệt |
| Kiểm thử | Test manifest có đủ `fx-skill-<id>` cho mọi kỹ năng. Smoke chụp khung va chạm từng lớp. Đo FPS khi 3 tối thượng nổ cùng lúc (ngân sách ≤ 2 ms vẽ FX) |

## 8. Câu hỏi chờ duyệt

| Mã | Câu hỏi | Đề xuất | Chủ dự án (03/11/2026) |
| --- | --- | --- | --- |
| Q180 | Duyệt hướng hình FX-1 (cel-shade 4 dải + glow cộng, bản sắc 5 lớp ở mục 4) cho toàn bộ 70 kỹ năng? | Duyệt hướng, góp ý từng kỹ năng trên GIF | ✅ **Áp dụng cho cả 70 kỹ năng** |
| Q181 | FX-1 **thay** hay **chạy song song** với hình đã duyệt (19 kỹ năng source art, Kiếm Khách AR-45b/45d, slice AR-46)? | Song song: chỉ thay kỹ năng chủ dự án chọn. Mặc định giữ hình gốc | ✅ Theo đề xuất |
| Q182 | Độ phân giải: giữ lưới pixel như bản duyệt, hay vẽ lại ở độ phân giải HD theo hướng Q176 (docs/35)? | Giữ lưới pixel | ✅ **Vẽ lại HD** |
| Q183 | Thứ tự đưa vào game (mục 7 FX-4) | Pháp Sư → Thợ Săn → Triệu Hồi Sư → Hộ Vệ → Kiếm Khách | ✅ Theo đề xuất |

## 9. Đã đưa vào game (FX-2…4, 03/11/2026)

### 9.1. Cách làm

Không dùng ảnh sheet. Bộ nguyên tố được viết lại bằng GDScript và **vẽ vector ở toạ độ thế giới**, nên nét theo độ phân giải màn hình (HD thật, Q182), bám đúng vị trí gameplay và không tốn bộ nhớ texture. Nếu dùng ảnh sheet 12 khung cho 70 kỹ năng thì tốn hàng trăm MB VRAM mà vẫn không theo được đạn, tia nảy hay điểm rơi thật.

| Phần | File | Nội dung |
| --- | --- | --- |
| Nguyên tố | `godot/scripts/view/fx1_kit.gd` | `Painter` vẽ lên CanvasItem; khi `ci = null` thì chỉ đếm lệnh để test headless. Gồm trăng khuyết, vệt thuôn, sao va chạm, vòng, vòng trận, sét, tia lửa, khói, cột sáng, khiên vòm, kiếm / tên / mảnh băng / khiên / cầu / búa, ký hiệu trên đầu. Mỗi hình vẽ 4 dải màu; glow 2 bậc (×1,35 / ×1,75) ghi vào `Painter.glow`. Hình suy biến bị bỏ, hình tự cắt được thay bằng bao lồi |
| Điều phối | `godot/scripts/view/fx1.gd` | Bảng màu (mục 4), bảng `SK` cho 70 kỹ năng (lớp, bảng màu, kiểu dàn cảnh, thời lượng, bán kính gameplay), chính sách song song, dàn cảnh thi triển, lớp phủ vật thể |
| Lớp glow | `world_view.gd` (node con `Fx1Glow`, `CanvasItemMaterial.BLEND_MODE_ADD`) | Vẽ sau mọi thứ của world_view → glow cộng sáng thật |
| Cài đặt | `core/settings.gd` `skill_fx` (+ `skill_fx_rev`), `ui/pause_menu.gd` | "Hiệu ứng kỹ năng": **FX-1 (mặc định)** / FX-1, giữ hình đã duyệt / Hình cũ |

### 9.2. Bám gameplay

| Loại | Nguồn vị trí thật | Kỹ năng |
| --- | --- | --- |
| Dàn cảnh thi triển | Lúc thi triển (bước nhảy hồi chiêu, như AR-45b), người chơi, hướng nhìn, đường lao ghi theo khung | Xoáy, nổ quanh thân, nón, lao, buff, xoay quanh người, chém xẻ trời, tụ lực ở tay |
| Đạn | `world.shots` theo `s.skill` | Trảm Phong, Phi Kiếm, Thánh Kiếm, Xuyên Tâm, Lộn Nhào, Liên Xạ, Tên Độc, Phá Không, Tam Liên, Băng Lao, Linh Tiễn, Hoả Điểu |
| Tia | `world.bolts` (không ghi kỹ năng thì lấy kỹ năng vừa thi triển) | Sét Chuỗi, Thiên Lôi, Cầu Sấm, Lôi Đồ Đằng, Tên Nảy, đợt sét Thiên Tai |
| Vùng / vật thể | `rains`, `meteors`, `sk2.ice/walls/orbs`, `cl2.totems/shields/slams`, `traps`, `j3.stars`, `Job3.orb_pos` | Vũ Tiễn, Thiên Tiễn, Thiên Thạch / Thiên Tai (nổ khi vật thể biến mất), Mưa Băng, Khí Độc, Thánh Vực, Linh Trận, Kiếm Vực, Hoả Tường, Cầu Sấm, Đồ Đằng, Phi Thuẫn, Phán Quyết, Bẫy / Mìn, Thiên Lạc Tinh Vũ, Ngũ Hành |
| Linh thú | `world.allies` mới xuất hiện có `skill` | Nghi thức gọi của mọi kỹ năng triệu hồi (Sói Bóng, Tiểu Quỷ, Thạch Quỷ, Linh Ưng, Quân Đoàn, Ấu Long, Kỳ Lân, Xương Nô) |
| Trúng đòn | `_hit_fx` của world_view | Sao va chạm theo màu kỹ năng vừa thi triển (trong 1,5 giây) |

### 9.3. Chính sách song song (Q181) và mặc định

**03/11/2026, sau khi thử trong game:** chủ dự án hỏi vì sao Kiếm Khách trong game khác bản duyệt. Nguyên nhân: ở mặc định cũ "auto", cả 14 kỹ năng Kiếm Khách giữ hình AR-45b/45d. Chủ dự án chọn **(a): FX-1 là mặc định cho cả 70 kỹ năng**, hình cũ vẫn còn trong Cài đặt. `Settings.migrate`: file cài đặt lưu trước đó (`skill_fx_rev` 0) đang "auto" (mặc định cũ) được chuyển sang "fx1" một lần; sau đó người chơi chọn lại "auto" / "old" thì giữ nguyên.

- **FX-1** (`fx1`, mặc định): cả 70 kỹ năng.
- **FX-1, giữ hình đã duyệt** (`auto`): FX-1 cho **48 kỹ năng**. 22 kỹ năng đã có hình runtime được duyệt thì giữ hình cũ (`Fx1.APPROVED`): 14 kỹ năng Kiếm Khách (AR-44/45b/45d); Xuyên Tâm Tiễn, Thiên Tiễn Vũ, Băng Lao, Thiên Thạch, Thiên Tai Nguyên Tố (AR-44); Tên Nảy, Thiết Chuỳ Phá Địa, Gọi Ấu Long (AR-46).
- Muốn chuyển một kỹ năng đã duyệt sang FX-1: thêm id vào `Fx1.REPLACE` trong `fx1.gd`.
- **Hình cũ** (`old`) tắt FX-1.
- Khi FX-1 nhận vẽ một kỹ năng, hình cũ của kỹ năng đó không vẽ nữa, nên không bị chồng hai bộ hình.

### 9.4. Kiểm thử

| Kiểm thử | Nội dung | Kết quả |
| --- | --- | --- |
| FX1-T1 (`run_tests.gd`) | Đủ 70 kỹ năng, đúng lớp; bảng màu; 3 chế độ; mọi dàn cảnh vẽ được ở 14 thời điểm, không có đa giác lỗi, số đa giác phải sửa ≤ 1%; có glow; 13 loại đạn; mọi lớp phủ; nổ khi Thiên Thạch biến mất | ✅ |
| AR45d-T1 | Cập nhật vì AR-46 chuyển Đột Kích sang SOURCE_PHASED → CHOREO còn 9 kỹ năng | ✅ |
| Smoke `tests/fx1_smoke.gd` | Game thật, có cửa sổ: với mỗi lớp và mỗi kỹ năng, thi triển bằng `use_skill` thật trước 4 quái rồi chụp 3 thời điểm. World và world_view chạy cùng bước 1/60 giây (view tắt `_process` tự động) để ảnh khớp thời gian gameplay dù cửa sổ chạy chậm. Lệnh: `--class=<lớp> --out=<thư mục> [--mode=fx1\|auto\|old]`; `--mode=` (rỗng) = theo Cài đặt | ✅ 5 lớp, mục 9.5 |

Lỗi gặp khi làm:
1. Lớp glow chưa kiểm tra đa giác nên Godot báo "Invalid polygon data, triangulation failed". Đã sửa bằng `Painter.fix_poly`, áp dụng cho cả lớp glow.
2. Hoả Tường dựng theo chiều dọc bị dẹt thành một vệt, vì bề ngang ngọn lửa lấy theo hướng tường. Nay bề ngang luôn lấy theo trục x.
3. Thiên Tai và Ngũ Hành lúc đầu tự đoán điểm ngắm nên lệch với vật thể thật. Nay bám `meteors` / `Job3.orb_pos`.
4. Phán Quyết (`cl2.slams`) và Cầu Sấm (`sk2.orbs`) là Dictionary đổi nội dung mỗi khung, nên khi làm khoá Dictionary để theo dõi lúc nổ thì báo "Invalid access to property or key". Nay theo dõi bằng danh sách và so tham chiếu bằng `is_same`.
5. Gặp kèm: `class_fx.draw_bolt_accents` gọi `bolt.get("skill", "")`, nhưng `Bolt` là object nên `get` chỉ nhận 1 tham số. Đã đổi thành `bolt.skill`. Lỗi này xảy ra khi dùng Tên Nảy ở chế độ mặc định.

### 9.5. Kết quả smoke trong game (03/11/2026, chế độ mặc định = FX-1 cả 70 kỹ năng, bước 1/60 giây)

| Thứ tự (Q183) | Lớp | Kỹ năng | Ảnh chụp | SCRIPT ERROR | Lỗi tam giác hoá |
| ---: | --- | ---: | ---: | ---: | ---: |
| 1 | Pháp Sư | 14 | 42 | 0 | 0 |
| 2 | Thợ Săn | 14 | 42 | 0 | 0 |
| 3 | Triệu Hồi Sư | 14 | 42 | 0 | 0 |
| 4 | Hộ Vệ | 14 | 42 | 0 | 0 |
| 5 | Kiếm Khách | 14 | 42 | 0 | 0 |

### 9.6. Khớp bản thiết kế với trong game (03/11/2026)

**Chủ dự án hỏi:** "Xoáy Kiếm trong game khác `docs/design/skills-fx/kiem-khach/01-spin.gif` — thiết kế ở đây không tính cho game à?" Câu trả lời là có: **bản thiết kế là chuẩn, trong game phải theo**. Lúc đó hai bên lệch nhau vì đây là **hai bộ vẽ riêng**. Bản thiết kế vẽ bằng Python (`tools/art/skill_fx_design.py`), còn trong game là bản viết lại bằng GDScript (`view/fx1.gd`). Khi viết lại, một số chỗ đã bị đổi mà không báo chủ dự án.

| # | Bản thiết kế | Trong game (trước khi sửa) | Đã sửa |
| --- | --- | --- | --- |
| 1 | Vòng, vòng trận, trăng khuyết quanh thân **nằm dẹt trên mặt đất 3/4** (nén trục y 0,55) | Vẽ tròn đều như nhìn thẳng từ trên xuống | `Kit.SQ = 0.55`: `ring` / `decal` vẽ elip; vị trí trên mặt đất dùng `Kit.gp(a)` (gai băng, kiếm cắm, mưa, vùng, mìn, vết nứt…); nón Khiên Chấn / Thánh Quang nén 0,7 như thiết kế |
| 2 | Nhịp 12 khung (va chạm 190 ms, khung cuối 260 ms, tổng 1,31 giây) | Chia đều trong thời lượng ngắn (Xoáy Kiếm 0,55 giây) nên tan quá nhanh | `DUR_MS` + `frame_of`: kiểu xoay / nổ quanh thân / nón / lao / liên trảm chạy đúng nhịp thiết kế. Vì sát thương xảy ra ngay lúc bấm nên bắt đầu ở khung 3 (lao: khung 2) thay vì khung 0 |
| 3 | Xoáy Kiếm: trăng khuyết dày 25% bán kính, xoay 1,6 vòng, vòng mờ khi tan | Mảnh hơn (16%), cách xoay khác | `_spin` viết lại theo đúng `a_spin`: mọi độ dày / khoảng cách nhân hệ số tầm gameplay / 36 |
| 4 | Không có hình nào khác chồng lên | Vòng xanh nhạt của động tác xoay cũ và vòng nổ chung `blasts` vẽ đè | `Fx1.owns_burst`: trong 1,2 giây sau một chiêu FX-1 có vùng quanh thân, world_view bỏ hai hình cũ đó. Tương tự cho đôi cánh cũ và vùng sáng cũ của Thành Bất Diệt, Liên Kết, Khiên Thép |
| 5 | Hống Kiếm / Huyết Bạo / Băng Ngục: chớp sáng ở khung phát | Không có | `glow_dot` lớn ở khung 4 |
| 6 | Thánh Kiếm Trảm: thanh kiếm thánh lớn hiện trước tay | Chỉ có tia lửa nhỏ | Kiếm thánh 44 px + chớp ở khung 4–7 |
| 7 | Nhất Kiếm Khai Thiên: nền tối khi tụ lực | Không tối | `dim` |
| 8 | Thiên Tai Nguyên Tố: 3 pha Hoả → Băng → Sét | Chỉ thấy pha Hoả (pha Băng / Sét nằm trong `sk2.queue`, chưa vẽ) | `draw_queue`: vòng báo Băng / Sét co lại tới lúc nổ, pha Băng nổ thành vòng gai băng, tia pha Sét màu Lôi |
| 9 | Triệu Hồi Xương: 3 cột sáng gọi Xương Nô | Không có, vì Xương Nô có `kind = "bone"` | Nghi thức gọi nhận cả linh thú `bone` (= Triệu Hồi Xương) |

**Khác biệt giữ lại có chủ đích.** Kích thước vùng trong game là **tầm đánh thật** (Xoáy Kiếm 12,5 m ≈ 1,5 lần chiều cao nhân vật). Bản thiết kế vẽ vùng nhỏ hơn thực tế (≈ 0,7 lần chiều cao nhân vật). Nếu vẽ nhỏ đi theo thiết kế thì người chơi sẽ hiểu sai vùng trúng đòn. Tương tự, vị trí linh thú, điểm rơi và hướng đạn trong game theo gameplay thật, không theo vị trí đặt sẵn trong cảnh thiết kế.

**Quy trình từ nay.** Mỗi lần sửa FX-1 thì chạy lại bộ ảnh so sánh và đặt cạnh bản thiết kế trước khi báo xong:

```bash
Godot_console.exe --path godot --script res://tests/fx1_smoke.gd -- --class=<lớp> --frames=34 --mode= --out=<dir>/<lớp>
python tools/art/skill_fx_ingame.py <dir>        # → docs/design/skills-fx-ingame/<lớp>/NN-<id>-so-sanh.jpg
```

Mỗi ảnh `NN-<id>-so-sanh.jpg` có hàng trên là 6 khung thiết kế, hàng dưới là 6 khung chụp từ game thật (`use_skill` thật, world và view cùng bước 1/60 giây, khung 480×280 quanh người chơi để tỉ lệ nhân vật gần bằng bản thiết kế). GIF chụp trong game chỉ xuất khi thêm `--gif`, vì nền rừng làm GIF nặng khoảng 0,6 MB mỗi kỹ năng.

Lưu ý khi chụp: chạy 14 kỹ năng × 34 khung liền trong một lần, Godot trên máy dự án (Intel Arc, OpenGL Compatibility) đôi khi tự thoát mà không có log. Ba lần thoát dừng ở ba kỹ năng khác nhau, còn chạy riêng từng kỹ năng thì không lỗi. Cách xử lý: chụp theo nhóm `--only=<id>,<id>,…` (3 kỹ năng một lần), nhóm nào thoát thì chạy lại.

### 9.7. Hiệu năng (03/11/2026)

`godot/tests/fx1_perf.gd` (headless) đo thời gian CPU mà FX-1 dựng hình mỗi khung. Painter không vẽ, `strict = false` như trong game.

| Tình huống | Trước tối ưu | Sau tối ưu |
| --- | --- | --- |
| Thực tế: 7 ô của một lớp cùng lúc + 10 linh thú vừa gọi + 4 vùng | 2,07 ms | **1,65 ms** (ngân sách 2 ms) |
| Cực đoan: cả 70 kỹ năng cùng lúc + 10 linh thú + 4 vùng | 7,46 ms | 4,49 ms |

Đã tối ưu ba chỗ:
- **Tam giác hoá chỉ chạy khi test.** `Painter.strict` mặc định bật khi `ci = null` (test) và tắt trong game. Trăng khuyết giới hạn độ dày (vành trong luôn lớn hơn 0) nên không tự cắt. Smoke trong game vẫn bắt được nếu có đa giác lỗi, vì Godot sẽ báo.
- **Trăng khuyết tính hình dạng một lần.** Hướng và độ dày tương đối được tính trước; 4 dải màu và 2 bậc glow chỉ đổi hệ số độ dày; mảng được cấp phát sẵn.
- **Nghi thức gọi linh thú.** Mỗi khung chỉ 4 nghi thức đầy đủ (Quân Đoàn gọi 10 con); từ con thứ 5 trở đi chỉ vẽ cột sáng và vòng.

### 9.8. Cảm giác đánh trúng + giảm chớp sáng (03/11/2026)

- **Rung màn hình.** Chiêu mạnh bắn "lực va chạm" đúng khung 5 của nhịp thiết kế: xoay 0,35, nổ quanh thân 0,55 (bán kính ≥ 12 m thì 0,7), chém xẻ trời 1,0, tối thượng ≥ 0,8; thiên thạch, búa nện và cầu sấm khi nổ 0,4–0,65. `world_view` rung `camera.offset` (vị trí camera vẫn do main điều khiển) trong 0,22–0,32 giây, biên độ 3–10 px.
- **Khựng đòn.** Lực ≥ 0,6 thì `Engine.time_scale = 0.08` trong 45 ms (timer không theo time_scale), sau đó **trả về đúng giá trị cũ**, vì smoke chạy ×3.
- **Âm thanh.** Chiêu có lực ≥ 0,55 phát `explode` đúng khung va chạm của hình, qua hàng đợi `world._sfx` sẵn có (main phát).
- **Cài đặt mới.** "Rung màn hình khi chiêu mạnh va chạm" (`fx_shake`, mặc định bật): tắt thì không rung, không khựng đòn. "Giảm chớp sáng hiệu ứng" (`fx_soft`, mặc định tắt): bật thì không làm tối nền và lớp glow còn 55%, dành cho người nhạy cảm ánh sáng hoặc máy yếu.
- Test: FX1-T1 kiểm tra Xoáy Kiếm không rung trước khung 5 và có rung từ khung 5; tắt cài đặt thì không rung.

### 9.9. Vòng cảnh báo đòn của quái (bước 8, lát 1, 03/11/2026)

`Fx1.draw_danger` + `world_view._fx1_telegraph`. Các đòn có vùng tròn (vồ, lao bổ, Hổ Vồ, gầm, rễ, nện, nổ, trồi cát, bổ nhào cát, đuôi độc, xoáy cát) vẽ theo ngôn ngữ FX-1: nền mờ, phần lấp đầy tăng theo tiến độ vung đòn, viền 3 dải + glow, 8 vạch chỉ vào tâm, gần lúc đánh thì sáng lên. Màu theo loại đòn: đỏ (vồ / nện / nổ), lam nhạt (gầm / lao bổ), vàng đất (rễ / cát), xanh độc (đuôi độc).

**Vùng nguy hiểm giữ đúng hình tròn gameplay**, không nén 3/4, để người chơi né chính xác. Dạng nón và dạng đường: xem §9.11. Chọn "Hình cũ" trong Cài đặt thì về kiểu cũ. Ảnh: `godot/tests/fx1_telegraph.gd`. Test FX1-T1.

**Bước 8, lát 2:** cảnh báo của từng chương và cảnh báo dạng nón / đường, xem §9.11. Icon Thiên phú và trang bị nằm trong lộ trình G1 (UI-42…45, [35](35-de-xuat-giao-dien-moi.md)) của phiên giao diện, nên tách riêng.

### 9.10. Chỉnh hình (bước 9) và nguồn duyệt chính (bước 5)

- Hoả Tường có dải than hồng dọc chân tường, ngọn lửa so le và nhỏ dần về phía xa. Lưu ý: gameplay dựng tường **vuông góc với hướng ngắm**, nên khi ngắm ngang thì tường nằm dọc màn hình và trông như một cột lửa. Hiệu ứng giữ đúng vị trí tường thật, không vẽ theo bố cục ảnh thiết kế.
- Linh thú xuất hiện sát người chơi (dưới 45 px): cột sáng gọi mảnh và nhạt hơn (×0,45) để không che nhân vật.
- Thiên Tai: ảnh so sánh chụp 44 khung (2,9 giây), nên có đủ 3 pha Hoả → Băng → Sét.
- Icon Ấu Long thêm đôi cánh trăng khuyết, sừng và lửa phun; icon Linh Ưng dùng khung dang cánh của sprite.
- **Nguồn duyệt chính (bước 5).** Từ nay **ảnh chụp trong game** (`docs/design/skills-fx-ingame`, `tests/fx1_smoke.gd --frames`) là bản duyệt chính của hiệu ứng kỹ năng. Bản thiết kế Python (`docs/design/skills-fx`) chỉ còn là bản phác ý tưởng. Mọi thay đổi FX-1 phải chụp lại ảnh so sánh trước khi báo xong. Bản thiết kế không vẽ lại theo đúng tầm đánh: ở tỉ lệ thật, vùng của Băng Phong (14 m) hay Thiên Tiễn (20 m) rộng hơn cả khung cảnh 192×112, nên ảnh phác sẽ không còn đọc được.

### 9.11. Cảnh báo đòn quái: từng chương + dạng nón / đường (bước 8, lát 2, 04/11/2026)

Ba hàm dùng chung trong `fx1.gd`, vẽ qua `Fx1.painter` (world_view gán ở đầu mỗi `_draw`), nên view từng chương gọi được mà không cần painter riêng. Hình **giữ đúng kích thước gameplay** (tâm, bán kính, độ dài, nửa bề rộng, nửa góc lấy từ hằng số của chương). Trả `false` khi chọn "Hình cũ" (hoặc chưa có painter) → nơi gọi vẽ kiểu cũ.

| Hàm | Hình | Dùng cho |
| --- | --- | --- |
| `danger_zone` | Vòng tròn như §9.9 | Vòng báo của chương 6–9 (`marks`, màu theo dữ liệu qua `pal_of`), thiên thạch / cột lửa / lông lửa vùng 5, Nổ Lửa, Búa, Ném Tuyết, Cột Băng, Xoay Ma, Nện / Búa Cự Thần, Quất Rễ, Phong Ấn, Hiến Tế, Gầm / Xoay vùng 9, Vồ Ma Tôn, Hút (vùng 1–4) |
| `danger_line` | Dải chữ nhật: nền mờ, lấp đầy chạy dọc theo tiến độ, hai mép 3 dải + glow, vạch chặn cuối, mũi tên chạy về phía trước | Bắn loạt / phi tiêu, bào tử, lao, lăn (vùng 1–4); bổ nhào / cột lửa vùng 5; nứt băng, lao / tia Ma vùng 6; Thương / Lướt Mây vùng 7; Tia Hư Vô vùng 8; Thương Nguyên Tố / Phi Ngựa / Lao vùng 9 |
| `danger_cone` | Nón: nền mờ, lấp đầy lan ra theo tiến độ, vành 3 dải + glow, 2 cạnh, 5 vạch chỉ vào trong | Lá, ánh nhìn (vùng 1–4); Thở Lửa Rồng vùng 5 (trước là vòng tròn, nay đúng nón 35° như đòn thật); Thở Băng vùng 6; Chém Nặng, Hàm vùng 8 |

Bảng màu mới: `P_FIRE` (lửa), `P_VOID` (hư vô), `P_GOLD` (vàng), `P_LEAF` (lá), `P_ICE` (băng đậm, riêng vùng 6 vì `P_FROST` nhạt chìm vào nền tuyết), cùng `pal_of(màu)` cho vòng báo có màu riêng.

Giữ kiểu cũ (không phải vùng sát thương hoặc là chỉ báo trạng thái): Dịch Chuyển, đòn cận chiến mặc định (vòng nở quanh quái), Nuốt vùng 8, dây hút / tia nhìn đang khoá, khiên, mũi tên chỉ đèn.

Mã: `world_view._fx1_telegraph`, `region5/6/8/9_view._fx1`, region7 ngay trong `draw_over`. Ảnh: `tests/fx1_telegraph.gd --set=lines` → [canh-bao-day-non.jpg](design/skills-fx-ingame/canh-bao-day-non.jpg); `tests/fx1_regions.gd --region=5…9` (map thật của vùng, quái đang vung từng đòn riêng + vòng báo) → [canh-bao-vung-5-9.jpg](design/skills-fx-ingame/canh-bao-vung-5-9.jpg).

Sửa lỗi có từ trước: với các đòn riêng của vùng 5–9, `world_view._draw_telegraph` rơi vào nhánh mặc định và vẽ thêm vòng đỏ nhỏ quanh quái, chồng lên cảnh báo của chương. Nay nhánh mặc định bỏ qua các đòn trong `world_view.REGION_TELEGRAPHS` (đã kiểm tra không trùng tên đòn của vùng 1–4). Test FX1-T1: dải / nón / vòng vẽ được, không đa giác lỗi, "Hình cũ" và không có painter thì trả về kiểu cũ, mọi loại đòn của region5/6/8/9 đều vẽ qua FX-1.

### 9.12. Cảnh báo kiểu tự nhiên — mặc định (04/11/2026)

**Chủ dự án hỏi:** ARPG thực tế (Diablo…) có cảnh báo đòn quái không, có rõ như mình không; "đừng để người chơi nhìn thấy giả trân quá". **Trả lời:** có, nhưng chia cấp và vẽ như một phần của thế giới. Diablo 3/4, Path of Exile, Grim Dawn: quái thường gần như không có vòng, người chơi đọc động tác lấy đà; tinh anh có hiệu ứng tại chỗ; boss có vùng trên đất nhưng trông như lửa, đất nứt, bóng đổ. Vòng đỏ có vạch cho mọi đòn là kiểu MMO (Lost Ark). Bản §9.9–9.11 đi theo hướng đó, nên làm lại theo hướng ARPG. Chủ dự án duyệt: "làm như đề xuất, chú ý cảm nhận của người chơi".

**Cài đặt mới "Cảnh báo đòn quái"** (`tele_style`, thẻ Hỗ trợ): **Tự nhiên** (mặc định) / **Rõ ràng** (kiểu §9.9–9.11, cho người mới hoặc khó quan sát). Chọn "Hình cũ" ở Hiệu ứng kỹ năng thì về kiểu cũ như trước.

| Cấp | Kiểu tự nhiên |
| --- | --- |
| Quái thường, đòn lao / bắn / chém nón (`BODY_ONLY`: vồ, lao, bắn loạt, lá, ánh nhìn, lăn, thương…) | **Không vẽ vùng.** Chỉ động tác (`windup_cue`): bụi dưới chân, từ 60% thân loé ánh đỏ cam + ánh kim ở đầu, từ 45% vệt bụi mờ chỉ hướng đòn |
| Quái thường, đòn vùng (nện, nổ, gầm, rễ…) | Vết mặt đất hiện dần từ 35% thời gian lấy đà |
| Tinh anh, cơ chế chương (thiên thạch, vòng báo…) | Vết mặt đất hiện dần từ 10% |
| Boss | Như tinh anh, đậm hơn ×1,6 + quầng sáng nhẹ ở đúng mép trên lớp glow (thấy xuyên tán cây) |

**Vết theo chất liệu** (suy từ bảng màu của đòn), kích thước vẫn đúng gameplay, mép là viền nhạt chập chờn, không có vạch chia hay mũi tên:
- Lửa: bóng cháy sẫm lớn dần, viền hơi nóng, than hồng rơi.
- Đất (`P_DANGER`): đất nứt toả ra từ tâm, bụi bốc ở mép.
- Băng: sương giá lan, gai băng.
- Cát: cát xoáy, bụi.
- Hư vô / vàng: vòng ấn xoay chậm.
- Độc: vũng sủi bọt.
- Lá: dây leo bò vào.
- Màu riêng của vòng báo: bóng vật rơi.
- Dải: rãnh mờ cày dọc đường đòn, bụi / than / sương trôi về phía trước.
- Nón: hơi nóng / sương đặc ở gốc, nhạt dần ra xa, hạt trôi ra ngoài.

**Nằm dưới quái.** Vết mặt đất ghi vào `Fx1.tele_queue`; `world_view` gọi `Fx1.flush_ground` trước lớp quái / cây ở khung sau (trễ 1 khung ≈ 16 ms, không nhận ra). Kiểu rõ ràng vẫn vẽ ngay, đè lên như trước.

**Cảm nhận người chơi — đã chỉnh trong lúc làm (đo trên ảnh chụp):**
1. Bản đầu, ánh loé và vệt bụi của quái thường quá mờ trên nền cỏ. Quái của mình nhỏ và đánh nhanh (lấy đà 0,4–1 giây) hơn Diablo, nên tăng một bậc: ánh kim to hơn, thân loé ánh đỏ cam, vệt bụi có nền sẫm để nổi trên cỏ.
2. Vết nện của boss chìm dưới tán cây → boss đậm ×1,6 và có quầng sáng mép trên lớp glow.
3. Quái thường đòn vùng hiện muộn hơn (35%) để màn hình không rối khi đánh bầy, nhưng vẫn đủ thời gian né.
4. Theo dõi khi chơi thử: nếu quái thường khó né quá thì kéo dài thời gian lấy đà của quái thường 10–15% (chưa đổi gameplay).

Mã: `fx1.gd` (`tele_natural`, `_nat_alpha`, `flush_ground`, `_nat_zone` / `_nat_line` / `_nat_cone`, `windup_cue`); `danger_zone` / `danger_line` / `danger_cone` nhận thêm tham số quái `e`. Ảnh so sánh: [canh-bao-tu-nhien.jpg](design/skills-fx-ingame/canh-bao-tu-nhien.jpg) (`tests/fx1_telegraph.gd`, `tests/fx1_regions.gd` thêm `--elite`, `--k=`). Test FX1-T1: mặc định tự nhiên; quái thường đòn lao không có vết; tinh anh / cơ chế có vết; vẽ dưới quái không có đa giác lỗi; động tác lấy đà vẽ được.

### 9.13. Cảm giác chơi: vật che, tư thế lấy đà, âm báo, đo nguồn sát thương (04/11/2026)

Chủ dự án duyệt đề xuất cải thiện tiếp (thứ tự 1 → 2 → 3 → 5 → 4 → 6).

1. **Kiểm tra lại.** Chạy lại bộ test đầy đủ; ảnh thẻ Trợ năng có "Cảnh báo đòn quái" (`tests/settings_shot.gd`); đo hiệu năng thêm tình huống 20 quái lấy đà kiểu tự nhiên ≈ 1,0 ms (tối đa 1,5 ms).
2. **Làm mờ vật che** (như Diablo). `world_view._occlusion_focus`: điểm cần thấy = thân người chơi, boss, điểm rơi đòn của tinh anh / boss đang lấy đà. `_tree_fade`: cây / đá / bụi có khung hình chứa một điểm đó (điểm nằm sau gốc) → mờ dần còn 40% (0,08 mỗi khung), hết che thì hiện lại dần. Áp cho mọi kiểu trang trí 9 vùng.
3. **Tư thế lấy đà** (`Fx1.windup_pose`, mọi quái trừ "Hình cũ"): tới 75% thời gian lấy đà co người (cao −12%, rộng +8%) và ngả ngược hướng đòn 0,1 rad; 25% cuối run lên rồi bật ra. `SpriteLib.draw_frame` thêm tham số tuỳ chọn `squash` / `lean` (mặc định không đổi chỗ gọi cũ).
4. **Đo nguồn sát thương** — `PACE-TELE` (chạy riêng `--only=PACE-TELE`). Bot không "nhìn" màn hình, nên đo phần sát thương đến từ đòn mất vết ở kiểu tự nhiên (bot chơi 240 giây, gán máu mất cho con quái ra đòn gần nhất trong 0,8 giây):

   | Vùng | Mất vết (lao / bắn / cận chiến quái thường) | Đòn vùng quái thường | Tinh anh / boss | Theo đòn |
   | --- | --- | --- | --- | --- |
   | 1 (1-1, cấp 5) | 91% | 2% | 6% | **Sói lao 56%**, đánh thường 28%, bào tử 12% |
   | 5 (5-1, cấp 47) | 57% (+ đấm 33% cũng chỉ báo bằng động tác) | 8% | 0% | Đánh thường 57%, đấm 33%, nổ lửa 8% |

   **Quyết định:** đòn cận chiến (đánh thường, đấm) giữ chỉ báo bằng động tác (kiểu cũ cũng chỉ có vòng nở quanh quái; Diablo không có gì). **Sói lao** gây hơn nửa sát thương ở vùng 1 — vùng người mới học né — nên đưa `dash` ra khỏi `BODY_ONLY`: có rãnh bụi mờ từ 35% thời gian lấy đà. Chưa kéo dài thời gian lấy đà; chờ chơi thử.
5. **Âm báo** (`Fx1._tele_audio` trong `Fx1.tick`): tinh anh / boss bắt đầu lấy đà trong 700 px quanh người chơi → `tele_elite` (gió vút + gầm gừ, 0,42 giây) / `tele_boss` (ầm trầm dâng, 0,75 giây), một lần mỗi đòn; "Hình cũ" thì không phát. Âm sinh bằng code (`tools/audio/sfx.py`).
6. **Tài liệu:** mục "Trạng thái hiện tại" ở đầu file.

Ảnh: `docs/design/skills-fx-ingame/che-cay-tu-the.jpg` (cây che boss trước / sau; sói đầu và 70% nhịp lấy đà; rãnh bụi Sói lao). Test FX1-T1 thêm âm báo (1 lần, quái xa không phát).

### 9.14. Soát cảnh báo tự nhiên trên mọi nền, trong chuyển động, cho người mù màu (04/11/2026)

1. **Mọi nền.** Chụp kiểu tự nhiên với quái tinh anh trên sa mạc (3), đầm lầy (4), trời mây (7), hư vô (8), Thiên Thê (9) (`fx1_telegraph.gd --map=`, `fx1_regions.gd`). Thấy vết chìm khi cùng tông với nền: cát xoáy trên cát, dải xám trên đá trắng, nón đỏ trên nền tím sẫm, rễ xanh trên cỏ xanh. Sửa chung cho mọi nền:
   - Mọi viền, mép dải và vành nón có **nét sẫm mảnh nằm dưới nét màu**. Nét màu dùng tông **sáng** của chất liệu: nền sáng thì nét sẫm nổi, nền tối thì nét sáng nổi.
   - Mép dải và nón đậm hơn (0,22 → 0,34; 0,3 → 0,38). Cát xoáy có bóng sẫm. Rễ đổi sang **nâu** (đúng chất "rễ", nổi trên cỏ).
2. **Vật che.** Cây mờ cả khi che thân **mọi quái đang lấy đà trong 300 px** (trước chỉ tính điểm rơi đòn của tinh anh / boss; chuỗi khung cho thấy tinh anh nấp sau cây thông suốt cả nhịp lấy đà).
3. **Chuyển động.** `fx1_telegraph.gd --seq`: chụp một nhịp lấy đà 1 giây (world.time chạy thật), mỗi 0,1 giây một ảnh. Vết hiện dần đều, run người và ánh loé không chớp giật.
4. **Mù màu đỏ – lục** (Trợ năng → "Bảng màu cho người mù màu"): cảnh báo đỏ → cam, xanh lá (độc, lá) → lam ngọc, theo quy ước "tốt / xấu = lam / cam" của giao diện. Áp cho cả kiểu tự nhiên và kiểu rõ ràng; chất liệu không đổi. `Fx1._cb`.
5. Sửa lỗi: đổi map thì xoá hàng đợi vết cảnh báo và danh sách âm báo (không còn vết của map cũ hiện 1 khung).

Ảnh: [canh-bao-nen-chuyen-dong.jpg](design/skills-fx-ingame/canh-bao-nen-chuyen-dong.jpg). Test FX1-T1 thêm chế độ mù màu.
