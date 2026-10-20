# Thiên Phú Khai Giới — Prototype web (tham khảo)

> **Không còn phát triển.** Bản chính đã chuyển sang Godot: xem [../godot/](../godot/) và [đặc tả kỹ thuật](../docs/02-technical-spec.md). Bản này giữ lại để so sánh; thông số cân bằng đã được mang sang Godot.

Bản chơi thử Chương 1 của game, dựng theo [kịch bản](../docs/kich-ban-game-thien-phu-khai-gioi.md) (mục 9, giai đoạn Prototype). Mục tiêu duy nhất: kiểm chứng **combat có vui không** và **Thiên phú có tạo khác biệt không**, trước khi chọn engine và đầu tư đồ hoạ.

## Chạy game

Cần Node.js 18 trở lên.

```bash
npm install
npm run dev        # mở http://localhost:5173
```

Lệnh khác: `npm test` (test logic + mô phỏng trận đấu), `npm run build` (bản phát hành trong `dist/`).

## Điều khiển

| Phím | Hành động |
| --- | --- |
| W A S D | Di chuyển |
| Chuột | Ngắm hướng chém |
| Chuột trái / J | Chém (giữ để chém liên tục) |
| K / Chuột phải | Xoáy Kiếm, hồi 6 giây |
| Space | Né lăn, bất tử 0,3 giây, hồi 3 giây |
| L | Kỹ năng Thiên phú (chỉ Thời Gian Ngưng Đọng có) |
| M · C | Bản đồ khai phá · Bảng chỉ số |

## Nội dung đã có

| Hệ thống trong kịch bản | Trong prototype |
| --- | --- |
| Lễ Thức Tỉnh | 1 lần quay + 3 lần quay lại, chọn lại bất kỳ lần nào, bảo hiểm hạng B |
| Thiên phú | 5 Thiên phú F → S: Tay Nhanh, Huyết Chiến, Kiếm Tâm, Mắt Ưng, Thời Gian Ngưng Đọng |
| Nhân vật | Kiếm Khách, cộng điểm STR/AGI/VIT, tẩy điểm miễn phí, công thức EXP theo tài liệu |
| Combat | Chém theo hướng chuột, Xoáy Kiếm, né lăn, combo (+20% EXP ở 100 combo), quái báo hiệu trước khi đánh |
| Quái | Sói Sương, Nấm Độc (bắn bào tử), Tinh Linh Sương, quái tinh anh; cấp quái tăng dần về phía đông |
| Boss | Sói Chúa Hư Vô: cắn, vồ (vòng đỏ), thanh Phá Thế → choáng 5 giây; dưới 50% HP gọi bầy sói và tàng hình |
| Khai phá | Lưới 10 ô lục giác, Đuốc Khai Giới, 5 loại sự kiện, Ổ quái phải đánh mới chiếm được |
| Lãnh địa | Xưởng Gỗ sinh gỗ/vàng kể cả khi offline (tối đa 12 giờ), nâng Trại thành Thôn |
| Vượt map | Hang Sói Chúa chỉ mở khi đạt cấp 5 **và** khai phá ≥ 60% ô đất |
| Lưu game | Tự lưu mỗi 5 giây vào trình duyệt (localStorage) |

**Chưa làm (để dành cho MVP):** trang bị và cường hoá, lớp nhân vật thứ 2, chuyển chức, tiến hoá Thiên phú, thương nhân, cổng dungeon, Triều Hư Vô, né "Hoàn hảo", âm thanh, đồ hoạ thật (hiện là hình khối placeholder), điều khiển cảm ứng.

**Chỗ lệch so với tài liệu (cố ý, để test nhanh):** Đuốc hồi 1 cái/2 phút (tài liệu: 20 phút); lên cấp và hạ quái tinh anh được thêm Đuốc. Tất cả nằm trong [src/core/config.ts](src/core/config.ts).

## Cấu trúc mã

```
src/data/      Dữ liệu thiết kế: Thiên phú, quái — designer chỉnh ở đây
src/core/      Logic thuần, không phụ thuộc trình duyệt (port sang Unity/Godot được)
  world.ts     Mô phỏng: di chuyển, combat, AI quái, boss, EXP
  explore.ts   Lưới khai phá, sản lượng lãnh địa
  awakening.ts Lễ Thức Tỉnh
src/render/    Vẽ canvas
src/ui/        HUD, bảng, các màn hình
tests/         Test logic + bot tự đánh boss để đo độ khó
```

Độ khó boss được cân bằng bằng bot mô phỏng: bot né đúng lúc thắng trong khoảng 40 giây, còn 10–30% HP; bot không né chết 1–5 lần.

## Phiếu playtest

Cho 3–5 người chơi thử từ đầu đến khi hạ boss (khoảng 20–30 phút), không hướng dẫn gì thêm, rồi hỏi:

1. Lúc quay Thiên phú có hồi hộp không? Có muốn quay lại không?
2. Đánh quái có "đã tay" không? Chỗ nào thấy nhàm?
3. Có hiểu vì sao bị chặn ở sương mù phía đông không?
4. Khai phá ô đất có hấp dẫn, hay chỉ là việc phải làm?
5. Trận boss: khó quá, dễ quá, hay vừa? Có dùng né lăn không?
6. Thiên phú của bạn có làm cách chơi khác đi không?
7. Có muốn chơi tiếp chương 2 không?

Ghi lại thời gian hoàn thành, số lần chết, và Thiên phú đã chọn.
