# Danh mục kỹ năng lớp hiện tại

| | |
| --- | --- |
| Dự án | Thiên Phú Khai Giới |
| Mục đích | Bàn giao danh sách kỹ năng đang có trong game cho thiết kế hình ảnh, hiệu ứng và âm thanh |
| Nguồn xác thực | `godot/scripts/data/classes.gd`, `core/game_world.gd`, `core/skills2.gd` |
| Cập nhật | 27/10/2026 |
| Phạm vi runtime | Kiếm Khách, Thợ Săn, Pháp Sư |

## 1. Quy ước chung

- Game hiện có **3 lớp đã triển khai**, mỗi lớp có 1 đánh thường và 13 kỹ năng chủ động. Hộ Vệ và Triệu Hồi Sư trong [19](19-lop-ho-ve-trieu-hoi-su.md) mới là đặc tả, chưa đưa vào game.
- Người chơi lắp tối đa 4 kỹ năng vào phím 1–4; đổi kỹ năng chỉ ở vùng an toàn.
- Kỹ năng mở ở cấp 1, 4, 8, 15, 22, 30, 45 và 60. Kỹ năng cấp 30 cần chuyển chức 1, kỹ năng cấp 60 chỉ dùng được khi chọn đúng nhánh chuyển chức 2.
- Tất cả kỹ năng có cấp 1–10. Kỹ năng gây sát thương tăng 8% hệ số mỗi cấp; kỹ năng hỗ trợ giảm 4% hồi chiêu mỗi cấp.
- Mọi tối thượng có hồi chiêu 60 giây và tốn 50 MP.
- `×N` là hệ số sát thương trước các bổ trợ từ chỉ số, cấp kỹ năng, trang bị, Thiên phú, biến thể và khắc hệ.

## 2. Kiếm Khách

| | |
| --- | --- |
| Vai trò | Cận chiến · Chí mạng |
| Chỉ số chính | STR |
| Đánh thường | **Chém** — vòng cung trước mặt, cận chiến |
| Hướng hình ảnh | Áo choàng đỏ đen, kiếm sáng đỏ; vệt chém và kiếm khí đỏ |

### Kỹ năng cơ bản và chuyển chức 1

| Mở | Id | Kỹ năng | Hồi / MP | Mô tả gameplay | Gợi ý hiệu ứng chính |
| ---: | --- | --- | --- | --- | --- |
| 1 | `spin` | Xoáy Kiếm | 6 s / 15 | Chém vòng quanh 12,5 m, ×1,8. | Vòng kiếm đỏ xoay tròn, bụi/vệt chém 360°. |
| 1 | `dash` | Đột Kích | 8 s / 20 | Lao 18 m theo hướng ngắm, chém mọi quái trên đường ×1,5; bất tử khi lao. | Vệt lao thẳng, dư ảnh nhân vật, chớp va chạm trên từng mục tiêu. |
| 4 | `wave` | Trảm Phong | 4 s / 15 | Kiếm khí thẳng 40 m, xuyên mọi quái, ×1,6. | Lưỡi gió/kiếm khí đỏ dài, đầu nhọn, vệt đứt khi xuyên mục tiêu. |
| 8 | `kiemy` | Kiếm Ý | 20 s / 25 | Hỗ trợ trong 8 giây: +20% chí mạng, +15% tốc đánh. | Hào quang đỏ quanh kiếm và biểu tượng kiếm phía trên nhân vật. |
| 15 | `lientram` | Nguyệt Ảnh Liên Trảm | 10 s / 20 | Lướt tới quái gần nhất trong 15 m rồi chém 3 nhát nón 90°, mỗi nhát ×1,15. | Dư ảnh lưỡi liềm, 3 nhịp chém rõ ràng, mục tiêu bị khoá ngắn. |
| 22 | `hongkiem` | Hống Kiếm | 12 s / 25 | Gầm vòng 8 m ×1,0; quái thường choáng 1,2 s, boss/tinh anh nhận gấp đôi Phá Thế. | Sóng âm hình kiếm lan tròn, sao choáng trên quái thường. |
| 30 | `kiemvu` | Kiếm Vũ | 10 s / 30 | Cần **Kiếm Sư**. Xoay kiếm 2 giây trong 10 m, 8 lần ×0,45. | Vòng kiếm nhiều lớp, quỹ đạo liên tục, nhịp trúng dày. |
| 30 | `phikiem` | Phi Kiếm | 6 s / 20 | Cần **Kiếm Sư**. Phóng 3 kiếm tỏa góc 30°, xuyên quái, mỗi kiếm ×1,2. | Ba kiếm đỏ xuất phát đồng thời, đuôi sáng dài. |

### Tối thượng và nhánh chuyển chức 2

| Mở | Nhánh | Id | Kỹ năng | Hồi / MP | Mô tả gameplay | Gợi ý hiệu ứng chính |
| ---: | --- | --- | --- | --- | --- | --- |
| 45 | Mọi nhánh | `vankiem` | Vạn Kiếm Quy Tông | 60 s / 50 | Tối thượng: mưa kiếm quanh nhân vật trong 15 m, 12 đợt ×0,67, tổng 800%. | Mưa kiếm từ trên cao, vòng cảnh báo đỏ, nhịp rơi dồn dập. |
| 60 | Kiếm Thánh | `thanhkiem` | Thánh Kiếm Trảm | 9 s / 30 | Đường kiếm thánh dài 50 m, xuyên mọi quái, ×3,0. | Kiếm khí trắng-vàng lớn, lõi sáng, vệt cắt mặt đất. |
| 60 | Kiếm Thánh | `kiemvuc` | Kiếm Vực | 14 s / 35 | Vùng kiếm 10 m quanh người chơi trong 4 giây, ×0,35 mỗi 0,5 s, làm chậm quái. | Kết giới kiếm xoay quanh nhân vật, kiếm nhỏ liên tục cắm xuống. |
| 60 | Huyết Kiếm | `huyetbao` | Huyết Bạo | 10 s / 20 | Đốt 10% HP hiện có, nổ máu 9 m ×2,5, hút lại 20% sát thương gây ra. | Vòng máu đỏ sẫm co lại rồi bùng nổ, luồng máu hồi về nhân vật. |
| 60 | Huyết Kiếm | `huyetanh` | Huyết Ảnh | 8 s / 25 | Lao 2 lần liên tiếp đến quái gần nhất, mỗi lần ×1,2. | Hai lần dịch chuyển đỏ, dư ảnh và dấu chém chữ X. |

## 3. Thợ Săn

| | |
| --- | --- |
| Vai trò | Đánh xa · Cơ động |
| Chỉ số chính | AGI |
| Đánh thường | **Bắn** — tên bay theo hướng ngắm |
| Hướng hình ảnh | Mũ trùm và áo choàng xanh lá, bao tên sau lưng; hiệu ứng gió/cánh chim |

### Kỹ năng cơ bản và chuyển chức 1

| Mở | Id | Kỹ năng | Hồi / MP | Mô tả gameplay | Gợi ý hiệu ứng chính |
| ---: | --- | --- | --- | --- | --- |
| 1 | `rain` | Vũ Tiễn | 8 s / 25 | Mưa tên tại điểm ngắm, vùng 9 m; 5 đợt trong 1,5 s, mỗi đợt ×0,5, tổng 250%. | Vòng báo trên đất, tên rơi gần thẳng đứng, bụi đất nhỏ từng đợt. |
| 1 | `pierce` | Xuyên Tâm Tiễn | 5 s / 15 | Một tên bay 60 m, xuyên tối đa 3 quái, ×1,8. | Tên sáng tập trung, vệt dài, số thứ tự xuyên hoặc lóe sáng trên từng lần trúng. |
| 4 | `lanban` | Lộn Nhào | 8 s / 20 | Lộn lùi, bất tử lúc lộn, bắn 3 mũi tỏa 24° mỗi mũi ×0,8; sau đó +50% né tránh trong 3 giây, trần 60%. | Lăn né nhanh, ba vệt tên hình quạt, buff né bằng gió xoáy nhẹ quanh chân. |
| 8 | `eagle` | Ưng Nhãn | 25 s / 30 | Hỗ trợ 6 giây: +30% tốc đánh, +15% chí mạng. | Biểu tượng mắt/cánh chim vàng, vòng ngắm mảnh trên nhân vật. |
| 15 | `tennay` | Tên Nảy | 6 s / 18 | Tên nảy tối đa 4 quái kế tiếp trong phạm vi mỗi bước 15 m, mỗi lần ×1,1. | Tên đổi hướng bằng tia nối giữa mục tiêu; mục tiêu kế tiếp hiện chớp ngắn. |
| 22 | `trap` | Bẫy Gai | 10 s / 20 | Đặt tối đa 2 bẫy. Quái chạm vào: nổ 6 m ×2,0 và bị trói 2 giây. | Bẫy cơ khí thấp trên đất, gai bật lên, dây leo/dây trói quấn chân. |
| 30 | `lienxa` | Liên Xạ | 9 s / 30 | Cần **Xạ Thủ**. Bắn liên tục 8 mũi trong 1,5 s vào quái gần nhất, mỗi mũi ×0,6; vẫn di chuyển được. | Chuỗi tên liên thanh, nhịp bắn rõ, tay/cung có vệt chuyển động. |
| 30 | `tendoc` | Tên Độc | 7 s / 20 | Cần **Xạ Thủ**. Tên xuyên ×1,0; độc ×0,2 mỗi giây trong 4 giây, cộng dồn tối đa 3. | Tên xanh độc, vệt độc bám mục tiêu và biểu tượng độc có số tầng. |

### Tối thượng và nhánh chuyển chức 2

| Mở | Nhánh | Id | Kỹ năng | Hồi / MP | Mô tả gameplay | Gợi ý hiệu ứng chính |
| ---: | --- | --- | --- | --- | --- | --- |
| 45 | Mọi nhánh | `thientien` | Thiên Tiễn Vũ | 60 s / 50 | Tối thượng: mưa tên vùng 20 m tại điểm ngắm, 10 đợt ×0,7. | Vùng mưa tên lớn, bầu trời tối nhẹ, tên rơi dày và đều. |
| 60 | Thần Tiễn | `phakhong` | Phá Không Tiễn | 10 s / 30 | Một mũi tên xuyên 70 m, luôn chí mạng, ×4,0. | Mũi tên lớn trắng-xanh, đường bắn nứt không khí, điểm va chạm bùng sáng. |
| 60 | Thần Tiễn | `tamlien` | Tam Liên Thần Tiễn | 8 s / 25 | Ba mũi tên xuyên liên tiếp, mỗi mũi ×1,5. | Ba phát liên tục theo trục thẳng, từng phát có sắc độ riêng. |
| 60 | Thợ Bẫy | `baimin` | Bãi Mìn | 14 s / 30 | Rải 5 bẫy nổ quanh mình, mỗi bẫy ×1,2; không tính giới hạn bẫy thường. | Năm mìn nhỏ bố trí vòng tròn, chớp đỏ trước nổ, nổ đất theo từng điểm. |
| 60 | Thợ Bẫy | `luoibay` | Lưới Bẫy | 10 s / 25 | Ném lưới 8 m tại điểm ngắm ×0,8, trói 3 giây. | Lưới lớn bay theo cung, phủ mục tiêu, hiệu ứng co giật khi bị trói. |

## 4. Pháp Sư

| | |
| --- | --- |
| Vai trò | Phép diện rộng · Khống chế |
| Chỉ số chính | INT |
| Đánh thường | **Hỏa Cầu** — cầu lửa tự nhắm, nổ khi chạm mục tiêu đầu tiên |
| Hướng hình ảnh | Mũ phù thủy tím, trượng pha lê; vòng ma pháp dưới chân khi niệm phép |

### Kỹ năng cơ bản và chuyển chức 1

| Mở | Id | Kỹ năng | Hồi / MP | Mô tả gameplay | Gợi ý hiệu ứng chính |
| ---: | --- | --- | --- | --- | --- |
| 1 | `chain` | Sét Chuỗi | 5 s / 15 | Sét đánh quái gần nhất trong 35 m, nảy tối đa 4 quái kế tiếp; 5 mục tiêu, mỗi mục tiêu ×1,2. | Tia sét tím-xanh nảy giữa mục tiêu, chớp rất ngắn khi đổi mục tiêu. |
| 1 | `banglao` | Băng Lao | 6 s / 15 | Mũi băng bay thẳng 40 m, xuyên quái, ×1,5; làm chậm 50% trong 3 giây. | Mũi băng lam sắc, quầng lạnh, mảnh băng vỡ và viền đóng băng trên quái. |
| 4 | `meteor` | Thiên Thạch | 10 s / 30 | Vòng báo 10 m tại điểm ngắm; sau 0,8 giây thiên thạch rơi ×3,0. | Vòng báo đỏ-cam rõ, thiên thạch từ trên rơi, nổ đá/lửa lớn. |
| 8 | `barrier` | Pháp Thuẫn | 20 s / 25 | Hỗ trợ: khiên 6 giây, hấp thụ tối đa 30% HP tối đa. | Bán cầu năng lượng tím-xanh, hiệu ứng nứt dần khi bị đánh. |
| 15 | `hoatuong` | Hoả Tường | 10 s / 25 | Dựng tường lửa dài 12 m trong 4 giây; quái trong tường nhận ×0,4 mỗi 0,5 giây. | Đường lửa trên đất, cột lửa dao động, nhiệt méo không khí. |
| 22 | `nova` | Băng Ngục | 9 s / 20 | Băng nổ quanh mình 11 m, ×1,4, trói quái 2 giây. | Vòng băng nổ từ tâm, cọc băng vây quái, biểu tượng đóng băng. |
| 30 | `muabang` | Mưa Băng | 9 s / 30 | Cần **Pháp Sư Nguyên Tố**. Mưa băng tại điểm ngắm trong 9 m, 5 đợt ×0,5, làm chậm. | Vòng báo xanh băng, mảnh băng rơi theo 5 nhịp, nền đóng tuyết tạm. |
| 30 | `causam` | Cầu Sấm | 11 s / 35 | Cần **Pháp Sư Nguyên Tố**. Cầu sấm bay 25 m, phóng sét quái trong 8 m mỗi 0,3 giây ×0,5; nổ cuối ×1,5. | Cầu điện chậm, tia sét tự tìm mục tiêu, nổ điện tròn ở cuối hành trình. |

### Tối thượng và nhánh chuyển chức 2

| Mở | Nhánh | Id | Kỹ năng | Hồi / MP | Mô tả gameplay | Gợi ý hiệu ứng chính |
| ---: | --- | --- | --- | --- | --- | --- |
| 45 | Mọi nhánh | `thienhoa` | Thiên Tai Nguyên Tố | 60 s / 50 | Tối thượng 3 đợt tại điểm ngắm: Hỏa ×4,0 vòng 12 m, sau 0,7 giây Băng ×3,0 làm chậm 3 giây, sau 0,7 giây Sét nảy 5 quái ×3,0. | Ba pha phân màu rõ: cam đỏ, lam băng, trắng-vàng điện; không được gộp thành một vụ nổ. |
| 60 | Đại Pháp Sư | `thienloi` | Thiên Lôi | 10 s / 35 | Sét trời đánh tối đa 6 quái trong 40 m, mỗi quái ×2,0. | Cột sét thẳng từ trời, dấu mục tiêu ngắn, dư quang điện trên đất. |
| 60 | Đại Pháp Sư | `bangphong` | Băng Phong Thiên Hạ | 14 s / 35 | Băng nổ quanh mình 14 m ×1,5, trói quái 3 giây. | Sóng băng lớn hơn Băng Ngục, cọc băng cao, vòng sương lạnh rộng. |
| 60 | Tử Linh Sư | `trieuhoi` | Triệu Hồi Xương | 20 s / 40 | Gọi 3 Xương Nô chiến đấu 15 giây; không tính giới hạn 3 Xương Nô từ bị động nhánh. | Ba vòng triệu hồi xương dưới đất, linh hồn tím bay lên rồi thành hình. |
| 60 | Tử Linh Sư | `khidoc` | Khí Độc Tử Vong | 12 s / 30 | Vùng khí độc 10 m trong 5 giây, ×0,25 mỗi 0,5 giây và cộng dồn độc. | Mây độc xanh tím thấp, méo không khí, tầng độc hiện rõ trên quái. |

## 5. Chuyển chức và ràng buộc hiển thị

| Lớp | Cấp 30 | Bị động chức 1 | Cấp 60: nhánh A | Cấp 60: nhánh B |
| --- | --- | --- | --- | --- |
| Kiếm Khách | Kiếm Sư | Đòn chém thứ 4 phóng kiếm khí ×0,8; Xoáy Kiếm +30% bán kính | Kiếm Thánh | Huyết Kiếm |
| Thợ Săn | Xạ Thủ | Mỗi phát bắn thêm tên phụ ×0,5 vào quái gần thứ hai; Xuyên Tâm Tiễn hồi nhanh hơn | Thần Tiễn | Thợ Bẫy |
| Pháp Sư | Pháp Sư Nguyên Tố | Hỏa Cầu tự đổi sang hệ khắc mục tiêu; Sét Chuỗi nảy thêm 2 lần | Đại Pháp Sư | Tử Linh Sư |

- Chuyển chức 1 và 2 đều tăng 10% HP và 10% Tấn công.
- Hai kỹ năng cấp 60 của nhánh không chọn không xuất hiện trong bảng Kỹ năng và không thể lắp.
- Kỹ năng cấp 30/60 cần nhãn chức tương ứng trong icon, tooltip và hiệu ứng nhận kỹ năng.

## 6. Biến thể kỹ năng dùng chung

Kỹ năng đạt cấp 4/7/10 lần lượt mở tầng biến thể I/II/III. Đổi biến thể ở vùng an toàn. Các kỹ năng có sát thương và kỹ năng hỗ trợ dùng bảng khác nhau.

| Tầng | Kỹ năng sát thương | Kỹ năng hỗ trợ |
| --- | --- | --- |
| I, cấp 4 | Tiết Kiệm: −20% MP; Thần Tốc: −15% hồi chiêu; Bí Kíp Song Phát: 25% hồi ngay hồi chiêu | Như kỹ năng sát thương |
| II, cấp 7 | Hỏa: thiêu 3 giây; Thủy: chậm 2 giây; Mộc: hút máu 4%; Kim: bỏ qua 25% DEF; Thổ: +50% Phá Thế; Bí Kíp Âm Dương: luôn khắc hệ | Bền Bỉ: hiệu lực +30%; Hồi Phục: hồi 10% HP; Bí Kíp Thanh Tâm: hồi 20% MP |
| III, cấp 10 | Bạo Lực: +25% sát thương; Chí Mạng: +20% tỉ lệ chí mạng; Bí Kíp Vô Song: +40% sát thương boss/tinh anh | Tinh Thông: −20% hồi chiêu; Vô Ngã: không tốn MP; Bí Kíp Kiên Cố: giảm 50% sát thương nhận trong 2 giây |

Ghi chú cho designer:

- Biến thể nguyên tố nên thay màu, hạt và trạng thái trúng đòn rõ ràng: Hỏa đỏ-cam, Thủy xanh lam, Mộc xanh lá, Kim trắng-vàng, Thổ nâu-vàng.
- (31/10, [29](29-bi-kip-diem-ky-nang.md)) Biến thể ✦ nay mở bằng 2 Điểm Kỹ Năng; Bí Kíp nhặt được = +1 Điểm Kỹ Năng, không còn icon Bí Kíp theo kỹ năng.
- Bí Kíp là lựa chọn hiếm, nên có khung vàng hoặc dấu sao khác biệt với biến thể thường.
- Riêng **Thiên Tai Nguyên Tố** luôn theo thứ tự Hỏa → Thủy → Kim; biến thể nguyên tố tầng II không đổi hệ cho kỹ năng này.

## 7. Danh mục asset tối thiểu

| Nhóm | Số lượng | Ghi chú |
| --- | ---: | --- |
| Icon đánh thường | 3 | Chém, Bắn, Hỏa Cầu |
| Icon kỹ năng lớp | 39 | 13 kỹ năng mỗi lớp; icon nhánh cấp 60 cần nhận diện chức rõ |
| VFX kỹ năng | 39 | Có thể tái sử dụng nền tảng theo họ hiệu ứng, nhưng tối thượng và kỹ năng nhánh phải có nhận diện riêng |
| Buff hỗ trợ | 3 | Kiếm Ý, Ưng Nhãn, Pháp Thuẫn |
| Biến thể nguyên tố | 5 bộ | Dùng phủ màu/hạt lên VFX kỹ năng gây sát thương |
| Dấu trạng thái | 5+ | Choáng, trói, chậm, độc, thiêu đốt, khiên, né tránh |

## 8. Ngoài phạm vi tài liệu

- Kỹ năng Thiên phú phím L và kỹ năng boss sao chép của Đạo Tặc thuộc hệ Thiên phú, không phải kỹ năng lớp.
- Hộ Vệ và Triệu Hồi Sư chưa có runtime; chỉ dùng [19](19-lop-ho-ve-trieu-hoi-su.md) làm thiết kế tham khảo, không sản xuất asset final theo tài liệu đó cho tới khi lớp được code.

## 9. Kỹ năng bị động (PV, 30/10/2026)

Mỗi lớp có thêm 4 kỹ năng bị động, mở ở cấp 10 / 20 / 35 / 50, cấp 0–5. Bị động không có hiệu ứng khi dùng (không bấm), nên chỉ cần **icon** (viền trong xanh lục) và, nếu muốn, một hiệu ứng nhỏ khi điều kiện bật (ví dụ Phản Kích sau khi né, Chiến Ý khi HP thấp). Giá trị: mỗi cấp / cấp 5.

| Lớp | Cấp 10 | Cấp 20 | Cấp 35 | Cấp 50 |
| --- | --- | --- | --- | --- |
| Kiếm Khách | **Thiết Cốt** `thietcot`: +3% / +15% HP | **Kiếm Tâm** `kiemtam`: +5% / +25% ST chí mạng | **Phản Kích** `phankich`: né được đòn → 3 giây +6% / +30% sát thương | **Chiến Ý** `chieny`: HP dưới 40% → +4% / +20% sát thương, +3% / +15% tốc đánh |
| Thợ Săn | **Ưng Mục** `ungmuc`: quái xa hơn 15 m +4% / +20% | **Săn Mồi** `sanmoi`: quái dưới 50% HP +4% / +20% | **Bước Gió** `buocgio`: +2% / +10% tốc chạy, +1% / +5% né | **Tên Tẩm Độc** `tamdoc`: 5% / 25% tỉ lệ thêm 1 tầng độc |
| Pháp Sư | **Minh Tưởng** `minhtuong`: +6% / +30% hồi MP | **Tinh Thông Nguyên Tố** `nguyento`: khắc hệ +5% / +25% | **Pháp Lực Dồi Dào** `doidao`: MP trên 70% +4% / +20% | **Hộ Thể Pháp Lực** `hothe`: 4% / 20% sát thương nhận trừ vào MP |
| Hộ Vệ | **Kiên Thủ** `kienthu`: +4% / +20% Phòng thủ | **Ý Chí Sắt** `ychisat`: hồi 0,2% / 1% HP mỗi giây | **Phản Chấn** `phanchan`: phản 6% / 30% sát thương nhận | **Uy Áp** `uyap`: +3% / +15% lên boss, tinh anh |
| Triệu Hồi Sư | **Linh Khế** `linhkhe`: linh thú +4% / +20% sát thương | **Linh Thể** `linhthe`: linh thú +8% / +40% HP | **Linh Hộ** `linhho`: mỗi linh thú (tối đa 3) nhận ít hơn 1% / 5% | **Hồn Lực** `honluc`: +3% / +15% sát thương bản thân |

Chi tiết và cân bằng: [27](27-ky-nang-bi-dong.md).
