# Bản duyệt IC-1 — icon kỹ năng

Tài liệu: [docs/37](../../37-icon-ky-nang.md). **Đã duyệt và vào game 03/11/2026** qua lớp phủ HD (tắt "Đồ hoạ HD" thì về icon cũ).

- `thanh-ky-nang-trong-game.png`: thanh kỹ năng thật của game (`ui/skill_bar.gd`), icon lấy qua `SpriteLib.icon`: hàng trên tắt HD (icon cũ), hàng dưới bật HD (IC-1).
- `<lớp>-so-sanh.png`: hàng trên icon hiện tại, hàng dưới IC-1 (viền vàng = icon vẽ tay giữ nguyên).
- `<lớp>/<icon>.png`: 51 icon chủ động mới 128×128.
- `bi-dong-so-sanh.png`, `bi-dong/pv-<id>.png`: 20 icon bị động (hàng trên icon cũ, hàng dưới IC-1).

Sinh lại: `python tools/art/skill_icons_fx.py`. Ảnh thanh kỹ năng: `Godot_console.exe --path godot --script res://tests/ic1_bar.gd -- --out=<file.png>`.
