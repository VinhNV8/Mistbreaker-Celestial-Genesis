# Brief thiết kế hình ảnh kỹ năng

| Dự án | Thiên Phú Khai Giới |
| --- | --- |
| Phạm vi | Hình ảnh đánh giá và hiệu ứng thi triển cho kỹ năng chủ động của 5 lớp |
| Nguồn dữ liệu kỹ năng | `godot/scripts/data/classes.gd` |
| Quy ước hiện có | PNG key art + GIF 3 pha: `charge -> cast -> impact` |

## 1. Mục tiêu bàn giao

Mỗi kỹ năng chủ động cần có một bộ review hình ảnh để duyệt trước khi cắt asset vào game:

1. **PNG key art:** Khoảnh khắc dễ nhận biết nhất của kỹ năng.
2. **GIF storyboard:** Ba pha `charge`, `cast`, `impact`; thể hiện rõ hướng, tầm ảnh hưởng và loại sát thương/hỗ trợ.
3. **Ghi chú implementation:** Hiệu ứng bám theo nhân vật, bay theo hướng ngắm, hay đặt tại điểm ngắm; tồn tại bao lâu nếu là vùng/triệu hồi.

Không thiết kế lại icon UI trong đợt này: icon, cây kỹ năng, tooltip, cấp kỹ năng, khóa/mở và thanh kỹ năng đã có trong game cho toàn bộ skill. Tài liệu này chỉ quản lý **visual khi thi triển**.

## 2. Trạng thái tổng quan

| Lớp | Số kỹ năng chủ động | Source art tham chiếu | Concept review | Cần artwork |
| --- | ---: | ---: | ---: | ---: |
| Kiếm Khách | 14 | 4 | 10 | 10 |
| Thợ Săn | 14 | 4 | 10 | 10 |
| Pháp Sư | 14 | 4 | 10 | 10 |
| Hộ Vệ | 14 | 4 | 1 | 10 |
| Triệu Hồi Sư | 14 | 4 | 1 | 10 |
| **Tổng** | **70** | **20** | **32** | **50** |

`Source art tham chiếu` là ảnh cắt trực tiếp từ master sheet và là chuẩn chất lượng cho artwork mới. `Concept review` là storyboard sinh thủ tục để diễn đạt ý tưởng/chuyển động; không phải artwork bàn giao và phải được thay thế. Không cột nào mặc định đồng nghĩa với asset runtime đã import vào game.

## 3. Danh sách theo lớp

### Kiếm Khách

Thư mục review hiện có: `docs/design/skills/kiem-khach/`. **Đã đưa vào game 02/11/2026 (AR-45b):** 14/14 kỹ năng có hình khi thi triển — xem `godot/scripts/view/class_fx.gd` (`CAST_FX`).

| Cấp/mở khóa | Kỹ năng | Trạng thái visual review | Hướng thiết kế |
| --- | --- | --- | --- |
| 1 | Xoáy Kiếm | Đã có | Vòng chém cần rõ bán kính và nhiều mục tiêu. |
| 1 | Đột Kích | Đã có | Vệt lao thẳng, cảm giác bất tử trong khi lao. |
| 4 | Trảm Phong | Đã có | Sóng kiếm khí bay thẳng, xuyên mục tiêu. |
| 8 | Kiếm Ý | Đã có | Hào quang buff bám theo nhân vật. |
| 15 | Nguyệt Ảnh Liên Trảm | Đã có | Lướt tới mục tiêu, ba nhát chém liên tiếp. |
| 22 | Hống Kiếm | Đã có | Xung kích tròn, đọc rõ hiệu ứng choáng. |
| 30, Kiếm Sư | Kiếm Vũ | Đã có | Vùng xoay quanh thân, nhiều nhát theo thời gian. |
| 30, Kiếm Sư | Phi Kiếm | Đã có | Ba kiếm tỏa 30 độ, bay xuyên. |
| 45, tối thượng | Vạn Kiếm Quy Tông | Đã có | Mưa kiếm trong vùng quanh người dùng. |
| 60, Kiếm Thánh | Thánh Kiếm Trảm | Đã có | Đường chém thánh sáng, dài và xuyên. |
| 60, Kiếm Thánh | Kiếm Vực | Đã có | Vùng kiếm trường tồn tại 4 giây, có slow. |
| 60, Huyết Kiếm | Huyết Bạo | Đã có | Vụ nổ máu, có nhịp hút máu trở lại. |
| 60, Huyết Kiếm | Huyết Ảnh | Đã có | Hai cú lao liên tiếp, vệt máu/ảo ảnh. |
| 90, Kiếm Thần | Nhất Kiếm Khai Thiên | Đã có concept review | Wind-up 0,5 giây -> một đường chém rộng 5 m, dài 40 m; cảm giác dồn sát thương đơn mục tiêu/boss. |

### Thợ Săn

Thư mục review hiện có: `docs/design/skills/tho-san/`.

| Cấp/mở khóa | Kỹ năng | Trạng thái visual review | Hướng thiết kế |
| --- | --- | --- | --- |
| 1 | Vũ Tiễn | Đã có | Mưa tên tại điểm ngắm, vùng tròn 9 m. |
| 1 | Xuyên Tâm Tiễn | Đã có | Một tên tốc độ cao, đường bay dài và xuyên 3 quái. |
| 4 | Lộn Nhào | Đã có | Lướt lùi, vệt né tránh và ba tên tỏa sau khi lộn. |
| 8 | Ưng Nhãn | Đã có | Buff thị giác/tốc đánh/chí mạng bám theo nhân vật. |
| 15 | Tên Nảy | Đã có | Một tên nhảy giữa tối đa 5 mục tiêu. |
| 22 | Bẫy Gai | Đã có | Bẫy nằm trên mặt đất, kích nổ và hiệu ứng trói. |
| 30, Xạ Thủ | Liên Xạ | Đã có | Tầm bắn liên tục 8 tên, vẫn có thể di chuyển. |
| 30, Xạ Thủ | Tên Độc | Đã có | Tên độc xuyên và dấu hiệu độc cộng dồn. |
| 45, tối thượng | Thiên Tiễn Vũ | Đã có | Mưa tên lớn tại điểm ngắm, 10 đợt. |
| 60, Thần Tiễn | Phá Không Tiễn | Đã có | Một phát tên xuyên 70 m, hình ảnh chí mạng chắc chắn. |
| 60, Thần Tiễn | Tam Liên Thần Tiễn | Đã có | Ba phát tên thần liên tiếp. |
| 60, Thợ Bẫy | Bãi Mìn | Đã có | Rải 5 mìn quanh người, nhận diện từng vùng nổ. |
| 60, Thợ Bẫy | Lưới Bẫy | Đã có | Lưới ném tới điểm ngắm, vùng trói 8 m. |
| 90, Thiên Lạc Xạ Thủ | Thiên Lạc Tinh Vũ | Đã có concept review | 8 mũi tên sao rơi từ trên xuống, ưu tiên quái nhiều HP; cần phân biệt với Vũ Tiễn bằng quỹ đạo và điểm rơi riêng lẻ. |

### Pháp Sư

Thư mục review hiện có: `docs/design/skills/phap-su/`.

| Cấp/mở khóa | Kỹ năng | Trạng thái visual review | Hướng thiết kế |
| --- | --- | --- | --- |
| 1 | Sét Chuỗi | Đã có | Tia sét nối tiếp 5 mục tiêu. |
| 1 | Băng Lao | Đã có | Mũi băng bay thẳng, vệt băng và slow. |
| 4 | Thiên Thạch | Đã có | Vòng cảnh báo tại điểm ngắm, sau đó thiên thạch rơi. |
| 8 | Pháp Thuẫn | Đã có | Khiên bảo vệ quanh thân trong 6 giây. |
| 15 | Hỏa Tường | Đã có | Tường lửa dài 12 m, sát thương lặp lại. |
| 22 | Băng Ngục | Đã có | Vùng băng nổ quanh thân, thể hiện trói. |
| 30, Pháp Sư Nguyên Tố | Mưa Băng | Đã có | Vùng mưa băng tại điểm ngắm, nhiều đợt rơi. |
| 30, Pháp Sư Nguyên Tố | Cầu Sấm | Đã có | Cầu sấm bay chậm, sét đến mục tiêu gần và nổ cuối đường. |
| 45, tối thượng | Thiên Tai Nguyên Tố | Đã có | Ba pha rõ ràng: thiên thạch lửa -> băng -> sét. |
| 60, Đại Pháp Sư | Thiên Lôi | Đã có | Sét trời đánh tối đa 6 mục tiêu. |
| 60, Đại Pháp Sư | Băng Phong Thiên Hạ | Đã có | Vụ nổ băng lớn quanh thân, trói 3 giây. |
| 60, Tử Linh Sư | Triệu Hồi Xương | Đã có | Nghi thức gọi 3 Xương Nô, có hiệu ứng xuất hiện. |
| 60, Tử Linh Sư | Khí Độc Tử Vong | Đã có | Vùng khí độc tồn tại 5 giây, độc cộng dồn. |
| 90, Hiền Giả | Ngũ Hành Luân Chuyển | Đã có concept review | 5 cầu Kim/Mộc/Thủy/Hỏa/Thổ quay quanh điểm ngắm; màu và biểu tượng từng hệ phải phân biệt rõ. |

### Hộ Vệ

Đã có source art tham chiếu cho Khiên Thép, Khiêu Khích, Chấn Địa, Thành Bất Diệt. Thiên Thuẫn Giáng Thế hiện chỉ có concept review; cần artwork cho 10 skill còn lại:

| Cấp/mở khóa | Kỹ năng | Hướng thiết kế |
| --- | --- | --- |
| 1 | Khiên Chấn | Cú đập khiên nón 90 độ, choáng. |
| 1 | Khiêu Khích | **Đã có source art tham chiếu.** Xung kích tròn 12 m kéo quái. |
| 4 | Lao Khiên | Lao thẳng 18 m, đẩy lùi quái. |
| 8 | Khiên Thép | **Đã có source art tham chiếu.** Lớp giáp/khiên thép buff phòng thủ. |
| 15 | Chấn Địa | **Đã có source art tham chiếu.** Đập đất vùng tròn 10 m, choáng. |
| 22 | Phi Thuẫn | Khiên bay xuyên rồi quay về. |
| 30, Hiệp Sĩ | Phán Quyết | Búa ánh sáng giáng xuống điểm ngắm. |
| 30, Hiệp Sĩ | Xung Phong | Lao 25 m, choáng. |
| 45, tối thượng | Thành Bất Diệt | **Đã có source art tham chiếu.** Hào quang phòng thủ và sát thương trong 8 giây. |
| 60, Thánh Kỵ Sĩ | Thánh Quang Trảm | Nón ánh sáng 120 độ, kèm hồi máu. |
| 60, Thánh Kỵ Sĩ | Thánh Vực | Vùng thánh quang đi theo nhân vật, hồi máu mỗi nhịp. |
| 60, Thiết Vệ | Thiết Chùy Phá Địa | Đập đất vùng tròn 12 m, choáng. |
| 60, Thiết Vệ | Thành Đồng | Nổ khiên và lớp khiên chắn sau nổ. |
| 90, Thủ Hộ Thần | Thiên Thuẫn Giáng Thế | **Đã có concept review.** Khiên thần giáng xuống, choáng và tạo khiên lớn. |

### Triệu Hồi Sư

Đã có source art tham chiếu cho Triệu Hồi Sói Bóng, Triệu Hồi Tiểu Quỷ, Liên Kết Linh Hồn, Quân Đoàn Linh Hồn. Kỳ Lân Giáng Thế hiện chỉ có concept review; cần artwork cho 10 skill còn lại:

| Cấp/mở khóa | Kỹ năng | Hướng thiết kế |
| --- | --- | --- |
| 1 | Triệu Hồi Sói Bóng | **Đã có source art tham chiếu.** Vòng triệu hồi và Sói Bóng xuất hiện. |
| 1 | Linh Tiễn | 5 tia linh hồn tỏa 40 độ. |
| 4 | Triệu Hồi Tiểu Quỷ | **Đã có source art tham chiếu.** Gọi 3 Tiểu Quỷ đánh xa. |
| 8 | Liên Kết Linh Hồn | **Đã có source art tham chiếu.** Dây liên kết người chơi - linh thú, hiệu ứng buff. |
| 15 | Gọi Thạch Quỷ | Triệu hồi Thạch Quỷ, đòn đánh nổ lan. |
| 22 | Hỏa Điểu | Chim lửa bay xuyên, thiêu đốt. |
| 30, Linh Sư | Linh Trận | Trận pháp tại điểm ngắm; linh thú trong vùng được buff. |
| 30, Linh Sư | Gọi Linh Ưng | Gọi 2 Linh Ưng đánh xa. |
| 45, tối thượng | Quân Đoàn Linh Hồn | **Đã có source art tham chiếu.** Gọi 10 linh hồn, cần đọc rõ số lượng đồng minh. |
| 60, Ngự Long Sư | Gọi Ấu Long | Nghi thức gọi rồng con; phun lửa nổ lan. |
| 60, Ngự Long Sư | Long Hống | Sóng âm rồng quanh người và quanh Ấu Long nếu đang tồn tại. |
| 60, Đồ Đằng Sư | Lôi Đồ Đằng | Cột totem đặt tại điểm ngắm, sét lặp lại. |
| 60, Đồ Đằng Sư | Phong Đồ Đằng | Totem gió tạo vùng slow, buff tốc đánh linh thú. |
| 90, Vạn Linh Chi Chủ | Kỳ Lân Giáng Thế | **Đã có concept review.** Triệu hồi Kỳ Lân thần thú, hồi đầy máu cho linh thú và đánh nổ lan. |

## 4. Thứ tự ưu tiên để sản xuất

1. **Đợt 1 - Hộ Vệ:** 13 skill còn lại, ưu tiên 4 skill cấp 1-8 và tối thượng Thành Bất Diệt để có loop chơi sớm.
2. **Đợt 2 - Triệu Hồi Sư:** 13 skill còn lại, ưu tiên các linh thú có thể tái sử dụng model/animation: Sói Bóng, Tiểu Quỷ, Thạch Quỷ, Linh Ưng, Ấu Long.

## 5. Ghi chú cho designer và implementer

- Những skill đặt tại điểm ngắm phải có vòng/cảnh báo để người chơi đọc được phạm vi.
- Skill tồn tại theo thời gian cần có hình dáng để phân biệt vùng gây sát thương, vùng buff và vùng khống chế.
- Skill triệu hồi cần ưu tiên silhouette để phân biệt linh thú đồng minh với quái.
- Hệ Kim, Mộc, Thủy, Hỏa, Thổ là biến thể của skill sát thương; giữ ngôn ngữ màu nhất quán để có thể mở rộng sau này.
- Hình review hiện có dùng để duyệt ý tưởng. Asset runtime chỉ được tạo/cắt và thêm vào `godot/assets/` sau khi duyệt.

## 6. Tham chiếu kỹ thuật

- UI cây và thanh kỹ năng: `godot/scripts/ui/skill_panel.gd`.
- Dữ liệu tên, mốc mở khóa, mô tả và tham số: `godot/scripts/data/classes.gd`.
- Các hiệu ứng được vẽ riêng hiện tại: `godot/scripts/view/skills2_view.gd` và `godot/scripts/view/class_fx.gd`.
- Quy ước asset review đang dùng: `docs/design/skills/README.md`.