# Thiết kế chi tiết Thiên phú

| | |
| --- | --- |
| Dự án | Thiên Phú Khai Giới |
| Nguồn | [Kịch bản](kich-ban-game-thien-phu-khai-gioi.md) mục 3; spec đã làm: [03-mvp-spec](03-mvp-spec.md) mục 4 (M2), CR-01 (Đạo Tặc) |
| Trạng thái | **Đã chốt thiết kế** 20/10/2026 — Q17–Q21 chốt theo phương án ở mục 7 (chủ dự án uỷ quyền chọn phương án hợp thị trường) |
| Cập nhật | 20/10/2026 |

Tài liệu này là "thẻ" đầy đủ của 20 Thiên phú: hiệu ứng ở từng cấp, kỹ năng, tiến hoá, cộng hưởng, tương tác với 4 lớp nhân vật. Phần **đã code** (M2) được đánh dấu; phần còn lại là thiết kế để các đợt sau làm theo.

Quy ước: 1 m = 10 đơn vị trong game. "Lv" = cấp Thiên phú (1–10), khác với cấp nhân vật.

## 1. Quy tắc chung

### 1.1. Sức mạnh theo hạng (kịch bản mục 3)

| Hạng | Tỉ lệ quay | Kịch bản yêu cầu | Cách áp dụng |
| --- | --- | --- | --- |
| F | 30% | Buff chỉ số nhỏ | 1 hiệu ứng chỉ số |
| C | 28% | Buff + 1 hiệu ứng bị động | 1 hiệu ứng có điều kiện |
| B | 22% | Bị động + 1 kỹ năng chủ động | Hiệu ứng chính + kỹ năng L |
| A | 13% | Thay đổi cơ chế chơi | Cơ chế mới (thú cưng, hút máu, nhìn xuyên sương…) |
| S | 5% | Cơ chế riêng + kỹ năng tối thượng | Cơ chế + kỹ năng L mạnh |
| SS | 1,8% | Hiệu ứng lên cả bản đồ / lãnh địa | Ảnh hưởng khai phá, lãnh địa |
| SSS | 0,2% | Độc nhất server | Đạo Tặc ([CR-01](03-mvp-spec.md)) |

**Nguyên tắc cân bằng** (kịch bản): F và S ở cùng cấp chênh sức mạnh ≤ 25%. Hạng cao thắng nhờ **cơ chế**, không nhờ sát thương thuần. Kiểm bằng test TL-B (hiện chênh 7%).

### 1.2. Luyện cấp Lv 1 → 10

| Thành phần | Quy tắc | Trạng thái |
| --- | --- | --- |
| Thưởng chung | Mỗi Lv trên 1: +2% Tấn công, +2% HP (Lv10: +18%) | ✅ Đã code (M2) |
| Hiệu ứng phụ theo nhóm | Mở ở Lv5 và Lv10 (bảng ở [03-mvp-spec](03-mvp-spec.md) mục 4.6) | ✅ Đã code (M2) |
| **Hiệu ứng chính mạnh dần** | Giá trị hiệu ứng chính tăng tuyến tính, Lv10 = ×1,5 Lv1 (trừ các ngoại lệ ghi trong bảng mục 2) | ⬜ Đã chốt (**Q17**), làm ở M3 |
| Chi phí | 1, 1, 2, 2, 3, 3, 4, 4, 5 Thiên Phú Tinh Hoa (tổng 25), tại Đền Thiên Phú | ✅ Đã code (M2) |

Công thức hiệu ứng chính ở Lv n: `giá trị(n) = giá trị(1) × (1 + 0,5 × (n − 1) / 9)`.

### 1.3. Tiến hoá (kịch bản mục 3)

| Hạng gốc | Tiến hoá tối đa | Số bậc | Điều kiện mỗi bậc |
| --- | --- | --- | --- |
| F | B | 2 (F → C → B) | Lv10 + chuỗi nhiệm vụ **"Phế Vật Nghịch Thiên"** (kịch bản) |
| C | A | 2 (C → B → A) | Lv10 + nhiệm vụ tiến hoá riêng + 1 **Tinh Hoa Tiến Hoá** |
| B | S | 2 (B → A → S) | Như trên |
| A | SS | 2 (A → S → SS) | Như trên |
| S | SSS | 2 (S → SS → SSS) | Như trên |
| SS | SSS | 1 | Như trên |
| SSS | — | 0 | — |

- **Tinh Hoa Tiến Hoá** rơi từ boss hiếm (kịch bản mục 5: boss hiếm rơi "vật phẩm tiến hoá").
- Cốt truyện **chương 4 và 7 bắt buộc tiến hoá 1 lần** (kịch bản mục 3). Vùng 5 mở khi tiến hoá 1 lần, vùng 8 mở khi tiến hoá 2 lần (kịch bản mục 6).
- Tiến hoá xong, cấp Thiên phú **đặt lại Lv1**, kèm 2 bảo đảm (**Q18**):
  - **Không tụt sức mạnh:** dạng mới ở Lv1 luôn mạnh bằng hoặc hơn dạng cũ ở Lv10 (cả thưởng chung +18% lẫn hiệu ứng phụ được giữ làm mức sàn cho tới khi dạng mới luyện vượt qua).
  - **Hoàn 50% Tinh Hoa** đã dùng để luyện dạng cũ (12 trên 25).
- Bảng Thiên phú hiện **trước toàn bộ cây tiến hoá** (tên, hạng, điều kiện) ngay từ Lễ Thức Tỉnh, để người quay trúng F thấy đường lên B (**Q20**).
- Thiên phú tiến hoá lên SSS **không** bị giới hạn "độc nhất server". Giới hạn đó chỉ áp dụng cho Đạo Tặc quay trúng từ Lễ Thức Tỉnh (**Q19**). Khi có người tiến hoá lên SSS: thông báo toàn server (Beta, cần KT-09).

### 1.4. Cộng hưởng (kịch bản mục 3)

Cần có ô Thiên phú phụ (mở ở cấp nhân vật 30 và 60). Khi có 2 Thiên phú **cùng nhóm**:

- **Cộng hưởng chung:** hiệu ứng chính của cả hai +10%.
- **Cộng hưởng đặc biệt:** một số cặp có hiệu ứng riêng (mục 4). Trong bảng Thiên phú, mỗi cặp hiện dạng **"???" kèm gợi ý nhóm** cho tới khi người chơi kích hoạt lần đầu; riêng Thợ Săn Di Tích (có trong kịch bản) hiện sẵn tên (**Q21**).

Nhóm Phép thuật, Điều khiển, Đặc biệt chỉ có 1 Thiên phú nên chưa có cộng hưởng; sẽ có khi bổ sung Thiên phú mới.

### 1.5. Tẩy Thiên phú

Vật phẩm hiếm **Nước Thánh Tinh Quang**: quay lại Thiên phú chính (1 lần quay, không bảo hiểm), giữ 50% cấp luyện (làm tròn xuống). Không tẩy được Đạo Tặc sang người khác.

## 2. Thẻ 20 Thiên phú

Cột **Code**: ✅ đã có trong game (M2), 🟡 có nhưng khác thiết kế này, ⬜ chưa có.

### 2.1. Hiệu ứng chính và kỹ năng

| # | Thiên phú | Hạng · Nhóm | Hiệu ứng chính Lv1 → Lv10 | Kỹ năng L (hồi chiêu) Lv1 → Lv10 | Code |
| --- | --- | --- | --- | --- | --- |
| 1 | Thân Thể Cường Tráng | F · Chiến đấu | +8% → +12% HP tối đa | — | ✅ Lv1 |
| 2 | Tay Nhanh | F · Chiến đấu | +5% → +7,5% tốc đánh | — | ✅ Lv1 |
| 3 | May Mắn Nhỏ | F · Kinh tế | Quái thường rơi đồ +5 → +7,5 điểm %; rơi Đá Cường Hoá +5 → +7,5 điểm % | — | ✅ Lv1 |
| 4 | Chân Không Biết Mỏi | F · Khai phá | +10% → +15% tốc chạy trên **bản đồ lục địa** và khi không giao chiến | — | 🟡 Chưa có bản đồ lục địa |
| 5 | Huyết Chiến | C · Chiến đấu | HP < 30%: +20% → +30% sát thương | — | ✅ Lv1 |
| 6 | Thợ Rèn Bẩm Sinh | C · Chế tạo | Cường hoá +10% → +15% tỉ lệ thành công | — | ✅ Lv1 |
| 7 | Khứu Giác Kho Báu | C · Khai phá | Hiện rương ẩn trong 30 m → 45 m; ô sự kiện Di tích 20% → 30% (thay 12% mặc định) | — | 🟡 Thiếu phần Di tích |
| 8 | Kiếm Tâm | B · Chiến đấu | Đòn thứ 5 gây ×2 → ×2,5 sát thương | **Nhất Kiếm Đoạn** (15 giây): đòn kế tiếp ×3 → ×3,5, chắc chắn chí mạng | ✅ Lv1 |
| 9 | Nhà Thảo Dược | B · Chế tạo | Hái thảo dược ×2; bình máu hồi +30% → +45% | **Linh Dược** (45 giây): hồi 30% → 45% HP, không tốn bình | ✅ Lv1 |
| 10 | Trái Tim Lãnh Chúa | B · Lãnh địa | Công trình xây nhanh 25% → 37,5% | **Hiệu Triệu** (300 → 200 giây): hoàn thành ngay 1 công trình đang xây | ✅ Lv1 |
| 11 | Thuần Thú Sư | A · Triệu hồi | Đòn làm quái thường **hoặc quái Ổ quái** tụt dưới 10% → 15% HP thì thu phục (tối đa 2 thú); thú cưng +0% → +50% chỉ số | — | 🟡 Chưa thu phục quái Ổ quái |
| 12 | Mắt Ưng | A · Khai phá | Nhìn xuyên sương mù 2 ô; +10% → +15% chí mạng | — | ✅ Lv1 |
| 13 | Hấp Huyết | A · Chiến đấu | 8% → 12% sát thương thành máu; không dùng được bình máu | — | ✅ Lv1 |
| 14 | Bàn Tay Vàng | A · Kinh tế | Phân rã: 20% → 30% thêm 1 Tinh Kim | — | ✅ Lv1 |
| 15 | Ngũ Hành Linh Căn | S · Phép thuật | Đòn đánh mang hệ; khắc hệ +30% → +40% *(ngoại lệ: ×1,33)* | **Đổi hệ** (0,5 giây). Xoáy Kiếm trong 2 giây sau khi đổi hệ = **Ngũ Hành Bộc Phá** +100% → +150%, bán kính 16 m | ✅ Lv1 |
| 16 | Thời Gian Ngưng Đọng | S · Điều khiển | — | **Ngưng Đọng** (90 giây): quái và đạn đứng yên 3 → 4,5 giây | ✅ Lv1 |
| 17 | Bầy Đàn Bóng Tối | S · Triệu hồi | Quái bị hạ 15% → 22,5% thành lính bóng tối (tối đa 10, sống 60 giây, tấn công = 30% → 45% của nhân vật) | **Bóng Tối Trỗi Dậy** (60 giây): gọi ngay 3 → 5 lính | ✅ Lv1 |
| 18 | Thiên Mệnh Khai Giới | SS · Khai phá | Mỗi Đuốc dọn thêm 2 ô kề bên; sản lượng lãnh địa +20% → +30% | — | ✅ Lv1 |
| 19 | Long Mạch | SS · Lãnh địa | Mở công trình **Long Mạch Đàn**: +10% → +15% Tấn công và HP cho nhân vật và đồng minh | — | ✅ Lv1 |
| 20 | Đạo Tặc (Ẩn) | SSS · Đặc biệt | **Cướp Thuộc Tính** khi hạ quái: tỉ lệ ×1,0 → ×1,5 (bảng ở CR-01), giới hạn 1 × cấp nhân vật | **Kỹ năng sao chép** (8 giây): dùng kỹ năng boss đã sao chép; +0% → +30% sát thương. Danh sách kỹ năng boss ở [06-ban-do-quai-boss](06-ban-do-quai-boss.md) mục 5 | 🟡 Mới có sao chép kỹ năng |

### 2.2. Ghi chú từng Thiên phú

| # | Thiên phú | Dành cho lối chơi | Điểm yếu cố ý | Ghi chú cân bằng |
| --- | --- | --- | --- | --- |
| 1 | Thân Thể Cường Tráng | Người mới, Hộ Vệ | Không tăng sát thương | Lv10 +12% HP cộng thưởng chung +18% |
| 2 | Tay Nhanh | Kiếm Khách, Thợ Săn | Hiệu ứng nhỏ | Mạnh hơn khi có affix tốc đánh |
| 3 | May Mắn Nhỏ | Người thích cày đồ | Không giúp đánh boss | Túi nhanh đầy hơn (phát hiện F3) |
| 4 | Chân Không Biết Mỏi | Người thích khám phá | Không giúp chiến đấu | Có giá trị thật từ M4 (bản đồ lục địa) |
| 5 | Huyết Chiến | Người chơi liều | Phải để HP thấp | Cặp tốt với Hấp Huyết (cộng hưởng) |
| 6 | Thợ Rèn Bẩm Sinh | Người cường hoá cao | Không giúp chiến đấu trực tiếp | Giá trị tăng ở +8 trở lên |
| 7 | Khứu Giác Kho Báu | Người khám phá | Không giúp chiến đấu | Rương ẩn: vàng, đá, 30% đồ |
| 8 | Kiếm Tâm | Đánh nhanh liên tục | Phụ thuộc số đòn | Đang mạnh hơn trung bình ~28% (phát hiện F4); theo dõi playtest |
| 9 | Nhà Thảo Dược | Người chơi an toàn | Sát thương thường | Cần Vườn Thảo Dược (M5) để có nguồn thuốc ổn định |
| 10 | Trái Tim Lãnh Chúa | Người thích xây lãnh địa | Không giúp chiến đấu | Có giá trị hơn khi có nhiều công trình (Alpha) |
| 11 | Thuần Thú Sư | Người thích triệu hồi | Thú cưng yếu dần nếu không thay | Nên thay thú cấp cao hơn ở vùng mới |
| 12 | Mắt Ưng | Khám phá + chí mạng | — | Chí mạng có trần 60% |
| 13 | Hấp Huyết | Đánh lâu, không lùi | Không uống bình máu | Mạnh khi sát thương cao |
| 14 | Bàn Tay Vàng | Người cường hoá +10 trở lên | Không giúp chiến đấu | Tinh Kim cần cho +10…+15 |
| 15 | Ngũ Hành Linh Căn | Người thích chọn hệ | Phải đổi hệ đúng lúc | Mạnh nhất với Pháp Sư (mục 5) |
| 16 | Thời Gian Ngưng Đọng | Né boss, đánh dồn | Hồi chiêu dài | Lv10 + hiệu ứng phụ Điều khiển = 5,5 giây |
| 17 | Bầy Đàn Bóng Tối | Đánh đông quái | Lính không sống lâu | Mạnh ở map đông quái |
| 18 | Thiên Mệnh Khai Giới | Khai phá, lãnh địa | Không giúp chiến đấu | Người chơi hạng SS có thể thất vọng ở chương 1 (phát hiện F5) |
| 19 | Long Mạch | Lãnh địa + chiến đấu | Phải xây xong Long Mạch Đàn | 150 vàng + 100 gỗ, 120 giây |
| 20 | Đạo Tặc | Độc nhất server | Phải tự đi cướp; giới hạn theo cấp | Mạnh hơn trung bình ~15% (CR-01) |

## 3. Tiến hoá

Mỗi dạng tiến hoá **thay thế** hiệu ứng của dạng trước (không cộng dồn). Giá trị ghi ở Lv1 của dạng mới; Lv10 = ×1,5 theo quy tắc 1.2.

| # | Gốc | Bậc 1 (hạng): hiệu ứng | Bậc 2 (hạng): hiệu ứng |
| --- | --- | --- | --- |
| 1 | Thân Thể Cường Tráng (F) | **Thân Thể Sắt Đá** (C): +12% HP, +8% Phòng thủ | **Kim Cang Bất Hoại** (B): +16% HP, +12% Phòng thủ; L *Kim Cang Thân* (40 giây): giảm 50% sát thương nhận 5 giây |
| 2 | Tay Nhanh (F) | **Phong Ảnh Thủ** (C): +10% tốc đánh; né lăn hồi nhanh 20% | **Vô Ảnh Kiếm** (B): +15% tốc đánh; L *Vô Ảnh* (30 giây): tốc đánh ×2 trong 4 giây |
| 3 | May Mắn Nhỏ (F) | **Vận May Lớn** (C): rơi đồ +8 điểm %; 10% đồ rơi được nâng 1 phẩm chất | **Thiên Tuyển Chi Nhân** (B): rơi đồ +10 điểm %; 20% nâng phẩm chất; L *Vận Đỏ* (300 giây): rơi đồ ×2 trong 30 giây |
| 4 | Chân Không Biết Mỏi (F) | **Bước Chân Lữ Khách** (C): +15% tốc chạy bản đồ lục địa; Đuốc hồi nhanh 15% | **Thần Hành** (B): +20% tốc chạy; L *Thần Hành Phù* (120 giây): dịch chuyển tới cứ điểm bất kỳ đã chiếm |
| 5 | Huyết Chiến (C) | **Huyết Nộ** (B): HP < 30%: +30% sát thương, +20% tốc đánh; L *Phẫn Huyết* (30 giây): mất 20% HP, +40% sát thương 8 giây | **Huyết Ma** (A): HP dưới 50% thì sát thương tăng dần, tối đa +50% ở 10% HP; HP < 30% hút 5% sát thương thành máu |
| 6 | Thợ Rèn Bẩm Sinh (C) | **Bậc Thầy Rèn** (B): +15% tỉ lệ cường hoá; thất bại 30% hoàn lại đá; L *Rèn Nóng* (600 giây): lần cường hoá kế tiếp +30% | **Thần Tượng** (A): cường hoá tối đa +18; chế được đồ Cam ở Xưởng Rèn |
| 7 | Khứu Giác Kho Báu (C) | **Mũi Chó Săn** (B): rương ẩn 50 m, Di tích 25%; L *Đánh Hơi* (120 giây): hiện mọi rương ẩn và Di tích trên bản đồ 20 giây | **Thợ Săn Kho Báu** (A): thêm loại **Rương Vàng** (30% đồ Tím); rương ẩn mỗi map 6 → 10 |
| 8 | Kiếm Tâm (B) | **Kiếm Ý** (A): đòn thứ 4 ×2; Nhất Kiếm Đoạn ×4 | **Kiếm Thánh Chi Tâm** (S): mỗi đòn chém 20% chém kép; L *Vạn Kiếm Quy Tông* (45 giây): 12 nhát chém diện rộng 12 m trong 1,5 giây, mỗi nhát ×0,8 |
| 9 | Nhà Thảo Dược (B) | **Dược Sư** (A): bình máu +50%; chế **Thuốc Cuồng Nộ** (+15% Tấn công 60 giây) từ 3 thảo dược | **Thần Y** (S): hồi máu vượt tối đa thành khiên (tối đa 30% HP); L *Hồi Xuân* (60 giây): hồi 60% HP, xoá mọi hiệu ứng xấu |
| 10 | Trái Tim Lãnh Chúa (B) | **Lãnh Chúa** (A): +1 hàng chờ xây; xây nhanh 40% | **Vương Giả** (S): sản lượng lãnh địa +25%; L *Chiếu Chỉ* (600 giây): hoàn thành mọi công trình đang xây |
| 11 | Thuần Thú Sư (A) | **Ngự Thú Sư** (S): 3 thú cưng; thu phục được quái tinh anh dưới 10% HP | **Vạn Thú Chi Vương** (SS): 4 thú; thu phục được 1 boss hiếm; thú cưng lên cấp theo nhân vật |
| 12 | Mắt Ưng (A) | **Thiên Nhãn** (S): nhìn xuyên 4 ô; +15% chí mạng; thấy quái tàng hình | **Toàn Tri** (SS): mọi ô trong lưới khai phá lộ sự kiện; chí mạng vào quái đang choáng +30% |
| 13 | Hấp Huyết (A) | **Huyết Tộc** (S): hút 12%; máu hút vượt tối đa thành khiên (tối đa 20% HP) | **Huyết Đế** (SS): hút 15%; L *Huyết Hải* (60 giây): 6 giây mọi sát thương gây ra hồi 50% |
| 14 | Bàn Tay Vàng (A) | **Điểm Kim** (S): Tinh Kim 30%; bán đồ +50% vàng | **Thần Tài** (SS): phân rã 10% ra 1 Thiên Phú Tinh Hoa; lãnh địa +20% vàng |
| 15 | Ngũ Hành Linh Căn (S) | **Ngũ Hành Hợp Nhất** (SS): khắc hệ +50%; mỗi đòn mang 2 hệ | **Hỗn Độn Linh Căn** (SSS): đòn đánh tự chọn hệ khắc quái; mỗi lần đổi hệ đều kích Bộc Phá |
| 16 | Thời Gian Ngưng Đọng (S) | **Thời Không Đoạn** (SS): ngưng 5 giây, hồi 75 giây; quái bị ngưng nhận +20% sát thương | **Thời Gian Chi Chủ** (SSS): thêm *Tua Ngược* — khi HP về 0, quay về trạng thái 5 giây trước (300 giây hồi) |
| 17 | Bầy Đàn Bóng Tối (S) | **Quân Đoàn Bóng Tối** (SS): 20% thành lính, tối đa 15, sống 90 giây | **Minh Vương** (SSS): boss bị hạ có 50% thành **lính bóng tối tinh anh** giữ 1 kỹ năng của boss, sống tới khi bị hạ |
| 18 | Thiên Mệnh Khai Giới (SS) | **Khai Thiên Tích Địa** (SSS): mỗi Đuốc dọn thêm 4 ô; ô chiếm được +40% tài nguyên; lưới khai phá mỗi map thêm 1 vòng | — |
| 19 | Long Mạch (SS) | **Tổ Long** (SSS): Long Mạch Đàn +20%; mỗi trận boss gọi 1 lần **Long Hồn** đánh cùng 20 giây | — |
| 20 | Đạo Tặc (SSS) | Không tiến hoá | — |

**Nhiệm vụ tiến hoá** (tên dùng cho cốt truyện; nội dung chi tiết viết ở đợt có tiến hoá — Alpha):

| Hạng gốc | Nhiệm vụ | Nơi nhận |
| --- | --- | --- |
| F | Chuỗi **"Phế Vật Nghịch Thiên"** (3 phần): hạ 1 boss vùng khi Thiên phú F, khai phá 100% một vùng, thắng 1 thử thách vượt ải | Trưởng làng Thanh Thạch |
| C, B | **"Thử Luyện Tinh Quang"**: hạ boss hiếm vùng hiện tại mà không chết | Thánh Đường Tinh Quang |
| A, S | **"Vấn Đạo"**: thắng phiên bản Ác mộng của boss chương gần nhất | Thánh Đường Tinh Quang |
| SS | **"Nghịch Thiên Cải Mệnh"**: nhiệm vụ cốt truyện chương 7 (Bia Đá gốc) | Cốt truyện chương 7 |

## 4. Cộng hưởng đặc biệt

| Cặp | Tên | Hiệu ứng | Nguồn |
| --- | --- | --- | --- |
| Mắt Ưng + Khứu Giác Kho Báu | **Thợ Săn Di Tích** | Hiện mọi Di tích trên toàn vùng | Kịch bản mục 3 |
| Huyết Chiến + Hấp Huyết | **Huyết Chiến Thần** | HP < 30%: hút máu ×2 | Đề xuất |
| Tay Nhanh + Kiếm Tâm | **Liên Hoàn Kiếm** | Chém kép mỗi đòn thứ 4 thay vì thứ 5 | Đề xuất |
| Thân Thể Cường Tráng + Huyết Chiến | **Bất Khuất** | Mỗi 60 giây, lần đầu HP về 0 thì giữ lại 1 HP | Đề xuất |
| May Mắn Nhỏ + Bàn Tay Vàng | **Phú Quý** | Quái tinh anh 5% rơi Tinh Kim | Đề xuất |
| Thợ Rèn Bẩm Sinh + Nhà Thảo Dược | **Luyện Kim Sư** | Chế **Dầu Rèn** (+10% tỉ lệ cho 1 lần cường hoá) từ 5 thảo dược | Đề xuất |
| Trái Tim Lãnh Chúa + Long Mạch | **Long Đế** | Long Mạch Đàn xây xong ngay; buff +5% | Đề xuất |
| Thuần Thú Sư + Bầy Đàn Bóng Tối | **Chúa Tể Bầy Đàn** | Lính bóng tối không biến mất khi còn thú cưng sống | Đề xuất |
| Chân Không Biết Mỏi + Thiên Mệnh Khai Giới | **Lữ Khách Thiên Mệnh** | +3 Đuốc tối đa | Đề xuất |

Các cặp cùng nhóm không có trong bảng: cộng hưởng chung +10% hiệu ứng chính.

## 5. Tương tác với 4 lớp nhân vật

Thiên phú quay ngẫu nhiên, không phụ thuộc lớp, nên mỗi Thiên phú phải dùng được với mọi lớp.

| Thiên phú | Kiếm Khách | Thợ Săn (M3) | Pháp Sư (Alpha) | Hộ Vệ (Alpha) |
| --- | --- | --- | --- | --- |
| Kiếm Tâm | Đòn chém thứ 5 | Phát bắn thứ 5 | Phép đơn thứ 5 | Đòn khiên thứ 5 |
| Huyết Chiến, Hấp Huyết | Như mô tả | Như mô tả | Hút máu từ phép diện rộng tính 50% | Rất mạnh (máu dày) |
| Ngũ Hành Linh Căn | Đòn chém mang hệ, Bộc Phá theo Xoáy Kiếm | Mũi tên mang hệ, Bộc Phá theo Mưa Tên | **Đúng nghĩa kịch bản**: dùng cả 5 hệ phép, kết hợp 2 hệ tạo phép mới (bảng dưới) | Khiên mang hệ, giảm sát thương hệ bị khắc 30% |
| Thuần Thú Sư, Bầy Đàn Bóng Tối | Như mô tả | Đồng minh đứng chắn phía trước | Như mô tả | Đồng minh nhận +20% HP |
| Thời Gian Ngưng Đọng | Đánh dồn | Đứng yên bắn | Niệm phép dài an toàn | Kéo quái rồi ngưng |

**Ngũ Hành Linh Căn với Pháp Sư — 10 phép kết hợp:**

| Hệ 1 + Hệ 2 | Phép mới | Hiệu ứng |
| --- | --- | --- |
| Kim + Mộc | Phong Nhận | 5 lưỡi gió xuyên thẳng, mỗi lưỡi ×0,8 |
| Kim + Thủy | Hàn Băng Thương | Thương băng ×2,5, làm chậm 40% trong 3 giây |
| Kim + Hỏa | Luyện Kim Hoả | Vùng lửa 8 m, ×0,5 mỗi giây trong 5 giây |
| Kim + Thổ | Thạch Giáp | Khiên = 25% HP trong 8 giây |
| Mộc + Thủy | Sinh Mệnh Chi Tuyền | Hồi 30% HP trong 6 giây |
| Mộc + Hỏa | Dã Hoả Liệu Nguyên | Lửa lan qua 5 quái gần nhau, mỗi quái ×1,2 |
| Mộc + Thổ | Địa Mạch Đằng | Trói quái 10 m trong 2 giây |
| Thủy + Hỏa | Chưng Vụ | Sương mù 10 m: quái trong đó trượt 50% đòn |
| Thủy + Thổ | Đầm Lầy Bùn | Vùng làm chậm 60%, 6 giây |
| Hỏa + Thổ | Dung Nham Phún | 3 cột dung nham, mỗi cột ×2 |

## 6. Việc cần làm theo đợt

| Đợt | Việc |
| --- | --- |
| M3 | TP-30: Thuần Thú Sư thu phục quái Ổ quái · TP-40: Đạo Tặc Cướp Thuộc Tính · tương tác Thiên phú với Thợ Săn (mục 5) · **TP-41: hiệu ứng chính mạnh dần theo Lv (Q17)** — làm cùng đợt cân bằng M3 để chỉ cân 1 lần |
| M4 | TP-26: Khứu Giác Di tích 20% · TP-23: Chân Không trên bản đồ lục địa · Đạo Tặc học kỹ năng boss 2 |
| Alpha | Ô Thiên phú phụ, tiến hoá (mục 3) kèm bảo đảm không tụt sức mạnh + hoàn 50% Tinh Hoa (TP-42), cây tiến hoá hiện trước (TP-43), cộng hưởng ẩn "???" (TP-44), tẩy Thiên phú, Ngũ Hành với Pháp Sư |
| Beta | Đạo Tặc độc nhất server (CR-01.2) · thông báo toàn server khi có người tiến hoá lên SSS |

## 7. Quyết định đã chốt (20/10/2026)

Chủ dự án uỷ quyền chọn phương án tốt nhất, hợp thị trường. Căn cứ chung: game nhập vai/gacha hiện nay (AFK Journey, Genshin, Solo Leveling: Arise, các ARPG mobile ở Việt Nam và Đông Nam Á) giữ chân người chơi bằng **tiến độ nhìn thấy được** và **không bao giờ làm người chơi thấy mất công sức**; hạng thấp phải có đường đi lên để không bỏ game ngay sau lượt quay.

| # | Câu hỏi | Quyết định | Lý do |
| --- | --- | --- | --- |
| Q17 | Hiệu ứng chính mạnh dần theo cấp Thiên phú? | **Có**, tăng đều tới ×1,5 ở Lv10 (khoảng +5,5% mỗi Lv). Làm ở **M3** cùng đợt cân bằng | Người chơi quen "nâng cấp là thấy số tăng" (nâng sao, chòm sao). Chỉ có +2% chung thì luyện Thiên phú nào cũng như nhau, nhàm. Làm cùng M3 để chỉ cân bằng 1 lần |
| Q18 | Tiến hoá xong đặt lại Lv1? | **Có, kèm bảo đảm**: dạng mới Lv1 không yếu hơn dạng cũ Lv10, hoàn 50% Tinh Hoa | Đặt lại Lv1 tạo mục tiêu luyện mới và chỗ tiêu Tinh Hoa. Nhưng "tụt sức mạnh sau khi nâng cấp" là lý do bị đánh giá thấp phổ biến nhất của thể loại này, nên phải có bảo đảm |
| Q19 | Thiên phú tiến hoá lên SSS có bị giới hạn "độc nhất server"? | **Không**; thông báo toàn server khi có người đạt | Tiến hoá là công sức, giới hạn sẽ làm người chơi lâu năm bực. Thông báo toàn server tạo khoe khoang và động lực |
| Q20 | Tên và hiệu ứng các dạng tiến hoá | **Như bảng mục 3**; cây tiến hoá hiện trước ngay từ đầu | Người quay trúng F cần thấy ngay "F vẫn lên được B" (chuỗi Phế Vật Nghịch Thiên), nếu không dễ xoá game làm lại |
| Q21 | Các cặp cộng hưởng đặc biệt | **Như bảng mục 4**; hiện "???" cho tới khi kích hoạt (trừ Thợ Săn Di Tích) | Cơ chế khám phá ẩn tạo chủ đề cho cộng đồng bàn luận, và vẫn có gợi ý nên không bắt người chơi tra wiki |
