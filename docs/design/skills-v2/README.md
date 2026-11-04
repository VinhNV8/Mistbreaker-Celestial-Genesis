# Skill Review V2

Bộ ảnh review V2 độc lập với [bộ V1](../skills/README.md); không thay đổi asset runtime của Godot.

## Khác biệt V2

- Mỗi skill gây sát thương có quái mục tiêu thật, di chuyển/hit reaction ở pha cuối.
- Biome đổi theo nguyên tố và hành vi: rừng cho cung, hỏa giới cho lửa, băng tinh thể cho băng, thánh thạch cho Hộ Vệ và hư không cho triệu hồi.
- Skill triệu hồi hiển thị linh thú/đơn vị thật ở các pha xuất hiện.

Mỗi class có 14 PNG card và 14 GIF review:

- [Kiếm Khách](kiem-khach/)
- [Thợ Săn](tho-san/)
- [Pháp Sư](phap-su/)
- [Hộ Vệ](ho-ve/)
- [Triệu Hồi Sư](trieu-hoi-su/)

Tái tạo bộ V2:

```powershell
python tools/art/export_skill_design_review.py --v2
```

Đây là visual review concept bằng pixel art code. Chỉ source art đã được phê duyệt mới nên trở thành asset runtime cuối cùng.