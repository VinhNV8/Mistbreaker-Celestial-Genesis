# Bản duyệt IC-1 — icon kỹ năng

Tài liệu: [docs/37](../../37-icon-ky-nang.md). **Đã duyệt và vào game 03/11/2026** qua lớp phủ HD (tắt "Đồ hoạ HD" thì về icon cũ).

- `thanh-ky-nang-trong-game.png`: thanh kỹ năng thật của game (`ui/skill_bar.gd`), icon lấy qua `SpriteLib.icon`: hàng trên tắt HD (icon cũ), hàng dưới bật HD (IC-1).
- `<lớp>-so-sanh.png`: hàng trên icon hiện tại, hàng dưới IC-1 (viền vàng = icon vẽ tay giữ nguyên).
- `<lớp>/<icon>.png`: 51 icon chủ động mới 128×128.
- `bi-dong-so-sanh.png`, `bi-dong/pv-<id>.png`: 20 icon bị động (hàng trên icon cũ, hàng dưới IC-1).

- `thien-phu-so-sanh.png`, `trang-bi-so-sanh.png`: IC-2 ([37 §7](../../37-icon-ky-nang.md)), 20 icon Thiên phú + 18 icon trang bị (hàng trên icon cũ, hàng dưới mới). `tai-nguyen-chi-so-so-sanh.png`: 14 icon tài nguyên + 24 icon chỉ số ([37 §8](../../37-icon-ky-nang.md)). `thien-phu-trang-bi-trong-game.png`: cả 4 nhóm chụp trong game ở 64 / 32 px.

Sinh lại: `python tools/art/skill_icons_fx.py`, `python tools/art/talent_icons_fx.py`, `python tools/art/hd/items_hd_more.py`, `python tools/art/hd/res_stat_hd.py` (thêm `--apply` để ghi vào game). Ảnh thanh kỹ năng: `Godot_console.exe --path godot --script res://tests/ic1_bar.gd -- --out=<file.png>`.
