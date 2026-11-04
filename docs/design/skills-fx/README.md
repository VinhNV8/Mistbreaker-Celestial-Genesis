# Bản duyệt FX-1 — hiệu ứng 70 kỹ năng (HD)

Tài liệu: [docs/36](../../36-thiet-ke-lai-vfx-ky-nang.md). Chủ dự án duyệt 03/11/2026 (Q180–Q183). **Đã vào game** (`godot/scripts/view/fx1.gd`) và là **mặc định cho cả 70 kỹ năng**; hình cũ chọn lại được ở Cài đặt → "Hiệu ứng kỹ năng".

- `<lop>.png`: bảng tổng của lớp, mỗi ô là khung va chạm của một kỹ năng.
- `<lop>/NN-<id>.gif`: 12 khung (4 tụ lực · phát · va chạm · 6 tan). Dải màu ở góc dưới phải cho biết pha hiện tại.
- `<lop>/NN-<id>.png`: các khung 1, 3, 4, 5, 7, 10.

Ảnh HD: vẽ ở ×6 rồi thu về ×3 (Lanczos). Nhân vật, linh thú và quái là sprite gốc của game, chỉ phóng to để làm ngữ cảnh.
Sinh lại: `python tools/art/skill_fx_design.py` (thêm danh sách id nếu chỉ muốn sinh vài kỹ năng).
Xem trong game thật: `Godot_console.exe --path godot --script res://tests/fx1_smoke.gd -- --class=<lop> --out=<thu-muc>`.
