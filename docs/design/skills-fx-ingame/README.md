# FX-1: so sánh bản thiết kế với trong game

Mỗi `<lớp>/NN-<id>-so-sanh.jpg`: **hàng trên** là 6 khung của bản thiết kế [`../skills-fx`](../skills-fx), **hàng dưới** là 6 khung chụp từ game thật (`tests/fx1_smoke.gd --frames=34`, thi triển bằng `use_skill` thật, bước 1/60 giây).

Bản thiết kế là chuẩn; trong game phải theo. Lệch có chủ đích duy nhất là **kích thước vùng = tầm đánh thật** của gameplay, cùng với vị trí linh thú, điểm rơi và hướng đạn theo gameplay. Xem [docs/36 §9.6](../../36-thiet-ke-lai-vfx-ky-nang.md).

Sinh lại sau mỗi lần sửa FX-1:

```bash
Godot_console.exe --path godot --script res://tests/fx1_smoke.gd -- --class=<lớp> --frames=34 --mode= --out=<dir>/<lớp>
python tools/art/skill_fx_ingame.py <dir> [--gif]
```
