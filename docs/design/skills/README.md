# Skill Art Review

Thư mục này chỉ dùng để review visual skill trước khi đưa asset vào game.
Các PNG và GIF được sinh bởi `tools/art/export_skill_design_review.py`; không
chạy `build_all.py` và không sửa `godot/assets`. GIF cho thấy ba pha `charge →
cast → impact` để review nhịp kỹ năng.

Phạm vi index là **70 kỹ năng chủ động** trong `classes.gd` (14 mỗi lớp). Năm
đòn đánh thường (Chém, Bắn, Hỏa Cầu, Đập Khiên, Linh Cầu) là hành động cơ bản,
không nằm trong danh mục review skill này.

Quy ước nhãn trên ảnh:

- `SOURCE ART - APPROVED REFERENCE`: cắt trực tiếp từ master sheet đã cung cấp.
- `CONCEPT REVIEW - NOT FOR GAME`: storyboard tham khảo để duyệt ý tưởng; chưa đủ chất lượng để import runtime.

**Đã vào game (02/11/2026, AR-45b — docs/07):** cả 14 kỹ năng Kiếm Khách. Trảm Phong, Kiếm Ý, Vạn Kiếm Quy Tông
dùng hình cắt từ master sheet (`fx-sheet-*`); 11 kỹ năng còn lại dùng keyframe 32×32 `vfx-<id>` (khung giữa
của storyboard, `tools/art/skill_vfx.py`) vẽ khi thi triển ở `godot/scripts/view/class_fx.gd`. Thợ Săn và
Pháp Sư vẫn chỉ ở mức review. Chỉ các card có nhãn `SOURCE ART` được dùng làm chuẩn chất lượng artwork;
các card `CONCEPT REVIEW` là bản phác hướng chuyển động, không phải artwork bàn giao.

## Kiếm Khách

| # | Kỹ năng | Ảnh | Chuyển động |
| ---: | --- | --- |
| 1 | Xoáy Kiếm | [PNG](kiem-khach/01-spin.png) | [GIF](kiem-khach/01-spin.gif) |
| 2 | Đột Kích | [PNG](kiem-khach/02-dash.png) | [GIF](kiem-khach/02-dash.gif) |
| 3 | Trảm Phong | [PNG](kiem-khach/03-wave.png) | [GIF](kiem-khach/03-wave.gif) |
| 4 | Kiếm Ý | [PNG](kiem-khach/04-kiemy.png) | [GIF](kiem-khach/04-kiemy.gif) |
| 5 | Nguyệt Ảnh Liên Trảm | [PNG](kiem-khach/05-lientram.png) | [GIF](kiem-khach/05-lientram.gif) |
| 6 | Hống Kiếm | [PNG](kiem-khach/06-hongkiem.png) | [GIF](kiem-khach/06-hongkiem.gif) |
| 7 | Kiếm Vũ | [PNG](kiem-khach/07-kiemvu.png) | [GIF](kiem-khach/07-kiemvu.gif) |
| 8 | Phi Kiếm | [PNG](kiem-khach/08-phikiem.png) | [GIF](kiem-khach/08-phikiem.gif) |
| 9 | Vạn Kiếm Quy Tông | [PNG](kiem-khach/09-vankiem.png) | [GIF](kiem-khach/09-vankiem.gif) |
| 10 | Thánh Kiếm Trảm | [PNG](kiem-khach/10-thanhkiem.png) | [GIF](kiem-khach/10-thanhkiem.gif) |
| 11 | Kiếm Vực | [PNG](kiem-khach/11-kiemvuc.png) | [GIF](kiem-khach/11-kiemvuc.gif) |
| 12 | Huyết Bạo | [PNG](kiem-khach/12-huyetbao.png) | [GIF](kiem-khach/12-huyetbao.gif) |
| 13 | Huyết Ảnh | [PNG](kiem-khach/13-huyetanh.png) | [GIF](kiem-khach/13-huyetanh.gif) |
| 14 | Nhất Kiếm Khai Thiên | [PNG](kiem-khach/14-nhatkiem.png) | [GIF](kiem-khach/14-nhatkiem.gif) |

## Thợ Săn

| # | Kỹ năng | Ảnh | Chuyển động |
| ---: | --- | --- |
| 1 | Vũ Tiễn | [PNG](tho-san/01-rain.png) | [GIF](tho-san/01-rain.gif) |
| 2 | Xuyên Tâm Tiễn | [PNG](tho-san/02-pierce.png) | [GIF](tho-san/02-pierce.gif) |
| 3 | Lộn Nhào | [PNG](tho-san/03-lanban.png) | [GIF](tho-san/03-lanban.gif) |
| 4 | Ưng Nhãn | [PNG](tho-san/04-eagle.png) | [GIF](tho-san/04-eagle.gif) |
| 5 | Tên Nảy | [PNG](tho-san/05-tennay.png) | [GIF](tho-san/05-tennay.gif) |
| 6 | Bẫy Gai | [PNG](tho-san/06-trap.png) | [GIF](tho-san/06-trap.gif) |
| 7 | Liên Xạ | [PNG](tho-san/07-lienxa.png) | [GIF](tho-san/07-lienxa.gif) |
| 8 | Tên Độc | [PNG](tho-san/08-tendoc.png) | [GIF](tho-san/08-tendoc.gif) |
| 9 | Thiên Tiễn Vũ | [PNG](tho-san/09-thientien.png) | [GIF](tho-san/09-thientien.gif) |
| 10 | Phá Không Tiễn | [PNG](tho-san/10-phakhong.png) | [GIF](tho-san/10-phakhong.gif) |
| 11 | Tam Liên Thần Tiễn | [PNG](tho-san/11-tamlien.png) | [GIF](tho-san/11-tamlien.gif) |
| 12 | Bãi Mìn | [PNG](tho-san/12-baimin.png) | [GIF](tho-san/12-baimin.gif) |
| 13 | Lưới Bẫy | [PNG](tho-san/13-luoibay.png) | [GIF](tho-san/13-luoibay.gif) |
| 14 | Thiên Lạc Tinh Vũ | [PNG](tho-san/14-tinhvu.png) | [GIF](tho-san/14-tinhvu.gif) |

## Pháp Sư

| # | Kỹ năng | Ảnh | Chuyển động |
| ---: | --- | --- |
| 1 | Sét Chuỗi | [PNG](phap-su/01-chain.png) | [GIF](phap-su/01-chain.gif) |
| 2 | Băng Lao | [PNG](phap-su/02-banglao.png) | [GIF](phap-su/02-banglao.gif) |
| 3 | Thiên Thạch | [PNG](phap-su/03-meteor.png) | [GIF](phap-su/03-meteor.gif) |
| 4 | Pháp Thuẫn | [PNG](phap-su/04-barrier.png) | [GIF](phap-su/04-barrier.gif) |
| 5 | Hoả Tường | [PNG](phap-su/05-hoatuong.png) | [GIF](phap-su/05-hoatuong.gif) |
| 6 | Băng Ngục | [PNG](phap-su/06-nova.png) | [GIF](phap-su/06-nova.gif) |
| 7 | Mưa Băng | [PNG](phap-su/07-muabang.png) | [GIF](phap-su/07-muabang.gif) |
| 8 | Cầu Sấm | [PNG](phap-su/08-causam.png) | [GIF](phap-su/08-causam.gif) |
| 9 | Thiên Tai Nguyên Tố | [PNG](phap-su/09-thienhoa.png) | [GIF](phap-su/09-thienhoa.gif) |
| 10 | Thiên Lôi | [PNG](phap-su/10-thienloi.png) | [GIF](phap-su/10-thienloi.gif) |
| 11 | Băng Phong Thiên Hạ | [PNG](phap-su/11-bangphong.png) | [GIF](phap-su/11-bangphong.gif) |
| 12 | Triệu Hồi Xương | [PNG](phap-su/12-trieuhoi.png) | [GIF](phap-su/12-trieuhoi.gif) |
| 13 | Khí Độc Tử Vong | [PNG](phap-su/13-khidoc.png) | [GIF](phap-su/13-khidoc.gif) |
| 14 | Ngũ Hành Luân Chuyển | [PNG](phap-su/14-nguhanh.png) | [GIF](phap-su/14-nguhanh.gif) |

## Hộ Vệ

| # | Kỹ năng | Trạng thái | Ảnh |
| ---: | --- | --- | --- |
| 1 | Khiên Chấn | Cần artwork | — |
| 2 | Khiêu Khích | Source art tham chiếu | [PNG](ho-ve/02-khieukhich.png) · [GIF](ho-ve/02-khieukhich.gif) |
| 3 | Lao Khiên | Cần artwork | — |
| 4 | Khiên Thép | Source art tham chiếu | [PNG](ho-ve/04-khienthep.png) · [GIF](ho-ve/04-khienthep.gif) |
| 5 | Chấn Địa | Source art tham chiếu | [PNG](ho-ve/05-chandia.png) · [GIF](ho-ve/05-chandia.gif) |
| 6 | Phi Thuẫn | Cần artwork | — |
| 7 | Phán Quyết | Cần artwork | — |
| 8 | Xung Phong | Cần artwork | — |
| 9 | Thành Bất Diệt | Source art tham chiếu | [PNG](ho-ve/09-thanhbatdiet.png) · [GIF](ho-ve/09-thanhbatdiet.gif) |
| 10 | Thánh Quang Trảm | Cần artwork | — |
| 11 | Thánh Vực | Cần artwork | — |
| 12 | Thiết Chuỳ Phá Địa | Cần artwork | — |
| 13 | Thành Đồng | Cần artwork | — |
| 14 | Thiên Thuẫn Giáng Thế | Concept review, không dùng trong game | [PNG](ho-ve/14-thienthuan.png) · [GIF](ho-ve/14-thienthuan.gif) |

## Triệu Hồi Sư

| # | Kỹ năng | Trạng thái | Ảnh |
| ---: | --- | --- | --- |
| 1 | Triệu Hồi Sói Bóng | Source art tham chiếu | [PNG](trieu-hoi-su/01-soibong.png) · [GIF](trieu-hoi-su/01-soibong.gif) |
| 2 | Linh Tiễn | Cần artwork | — |
| 3 | Triệu Hồi Tiểu Quỷ | Source art tham chiếu | [PNG](trieu-hoi-su/03-tieuquy.png) · [GIF](trieu-hoi-su/03-tieuquy.gif) |
| 4 | Liên Kết Linh Hồn | Source art tham chiếu | [PNG](trieu-hoi-su/04-lienket.png) · [GIF](trieu-hoi-su/04-lienket.gif) |
| 5 | Gọi Thạch Quỷ | Cần artwork | — |
| 6 | Hoả Điểu | Cần artwork | — |
| 7 | Linh Trận | Cần artwork | — |
| 8 | Gọi Linh Ưng | Cần artwork | — |
| 9 | Quân Đoàn Linh Hồn | Source art tham chiếu | [PNG](trieu-hoi-su/09-quandoan.png) · [GIF](trieu-hoi-su/09-quandoan.gif) |
| 10 | Gọi Ấu Long | Cần artwork | — |
| 11 | Long Hống | Cần artwork | — |
| 12 | Lôi Đồ Đằng | Cần artwork | — |
| 13 | Phong Đồ Đằng | Cần artwork | — |
| 14 | Kỳ Lân Giáng Thế | Concept review, không dùng trong game | [PNG](trieu-hoi-su/14-kylan.png) · [GIF](trieu-hoi-su/14-kylan.gif) |