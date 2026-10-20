# Thiên Phú Khai Giới (Mistbreaker: Celestial Genesis)

Game nhập vai hành động: nhận Thiên phú khi vào game, đánh quái lên cấp, vượt map, khai phá vùng đất bị sương mù che phủ.

Trạng thái: Chương 1 chơi được trên Godot 4.7.2. Đang làm **MVP**: đã xong M1 (trang bị, cường hoá), M2 (đủ 20 Thiên phú), G1 (hình pixel art sinh bằng code) và M3 (lớp Thợ Săn, 4 kỹ năng mỗi lớp, MP, né tránh, công thức chỉ số quái mới); đã xong đợt **C1 — hoàn chỉnh Chương 1** ([08](docs/08-chuong-1-hoan-chinh.md): tạo nhân vật, cốt truyện, hướng dẫn, Lõi Sương, boss hiếm, cửa hàng, âm thanh); tiếp theo M4 (Chương 2).

## Thư mục

| Thư mục | Nội dung |
| --- | --- |
| [docs/](docs/) | Tài liệu: kịch bản, đặc tả yêu cầu, đặc tả kỹ thuật |
| [godot/](godot/) | Project Godot — bản đang phát triển |

## Tài liệu

| File | Dành cho | Nội dung |
| --- | --- | --- |
| [docs/kich-ban-game-thien-phu-khai-gioi.md](docs/kich-ban-game-thien-phu-khai-gioi.md) | Cả nhóm | Kịch bản đầy đủ: thế giới, Thiên phú, combat, bản đồ, lộ trình |
| [docs/01-requirement-spec.md](docs/01-requirement-spec.md) | Review phạm vi, nghiệm thu | Yêu cầu có mã (AWK-01…), tiêu chí nghiệm thu, trạng thái, chỗ lệch so với kịch bản |
| [docs/02-technical-spec.md](docs/02-technical-spec.md) | Lập trình, cài đặt | Cài Godot, import project, kiến trúc, định dạng save, chạy test, quyết định kỹ thuật, lỗi đã gặp |
| [docs/03-mvp-spec.md](docs/03-mvp-spec.md) | Review trước khi code | Lộ trình MVP (M1–M5), spec chi tiết từng đợt, kết quả và phát hiện |
| [docs/05-thien-phu-chi-tiet.md](docs/05-thien-phu-chi-tiet.md) | Thiết kế nội dung | 20 Thiên phú: hiệu ứng theo cấp, kỹ năng, tiến hoá 2 bậc, cộng hưởng, tương tác 4 lớp. Đã chốt Q17–Q21 |
| [docs/06-ban-do-quai-boss.md](docs/06-ban-do-quai-boss.md) | Thiết kế nội dung | Công thức chỉ số; 9 vùng, môi trường, quái, tinh anh, boss chương, boss hiếm, đồ Cam. Sinh bằng script — xem đầu file. Đã chốt Q22–Q27 |
| [docs/07-do-hoa-ke-hoach.md](docs/07-do-hoa-ke-hoach.md) | Đồ hoạ | Nghiên cứu, phong cách pixel art đã chốt, hạng mục AR-xx, kết quả G1. Sinh hình: `python tools/art/build_all.py` (skill `game-art`) |
| [docs/08-chuong-1-hoan-chinh.md](docs/08-chuong-1-hoan-chinh.md) | Kế hoạch | Đợt C1: hoàn chỉnh Chương 1, kết hợp ghi chú Spec_Notes (N1–N7), hạng mục C1-xx |
| [docs/04-ke-hoach-tien-do.md](docs/04-ke-hoach-tien-do.md) | **Theo dõi tiến độ** | 173 hạng mục của kịch bản: đã làm / một phần / chưa làm, đợt sẽ làm, việc cần làm từng đợt, quyết định đang chờ |

## Chạy nhanh

1. Mở **Godot 4.7.2** (lối tắt trên Desktop) → **Import** → chọn `godot/project.godot` → bấm **F5**.
2. Chạy test logic:

   ```bash
   "C:/Users/ADMIN/AppData/Local/Programs/Godot/Godot_v4.7.2-stable_win64_console.exe" --headless --path godot --script res://tests/run_tests.gd
   ```

Chi tiết xem [đặc tả kỹ thuật](docs/02-technical-spec.md).

## Quy ước

- Mỗi đợt phát triển: viết spec trong `03-mvp-spec.md` → duyệt → code → test → cập nhật kết quả vào spec.
- Xong mỗi đợt: cập nhật trạng thái và bảng Tổng quan trong `04-ke-hoach-tien-do.md`.
- Mỗi khi thay đổi kỹ thuật, cập nhật `02-technical-spec.md` trong cùng lần sửa code.
