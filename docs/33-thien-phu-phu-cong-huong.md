# Thiên phú phụ, cộng hưởng, tẩy Thiên phú (TP-05, TP-13, TP-44, TP-14)

| | |
| --- | --- |
| Dự án | Thiên Phú Khai Giới |
| Nguồn | Kịch bản mục 3 (*"Mở khoá ô Thiên phú phụ ở cấp 30 và cấp 60 (nhận qua nhiệm vụ hoặc boss), tối đa 3 Thiên phú"*, *"Cộng hưởng: 2 Thiên phú cùng nhóm tạo hiệu ứng thưởng"*, *"Tẩy Thiên phú: Nước Thánh Tinh Quang, giữ lại 50% cấp luyện"*) · [05](05-thien-phu-chi-tiet.md) mục 1.4, 1.5, 4 (đã chốt) · chủ dự án 02/11/2026 chọn 4 phương án đề xuất |
| Loại tài liệu | Đặc tả + kết quả |
| Trạng thái | ✅ Đã làm (02/11/2026), save v28 |

## 1. Quyết định của chủ dự án (02/11)

| Câu hỏi | Chọn |
| --- | --- |
| Ô phụ mở thế nào | **Gắn chuyển chức**: ô 2 khi chuyển chức 1 (cấp 30), ô 3 khi chuyển chức 2 (cấp 60) |
| Chọn Thiên phú phụ | **Quay như Lễ Thức Tỉnh**: 1 lần + 3 lần quay lại, chọn bất kỳ lần nào, bảo hiểm hạng B; không trùng Thiên phú đang có; không ra Đạo Tặc |
| Cấp, kỹ năng | **Cấp riêng 1–10, chỉ bị động**. Phím L dùng kỹ năng Thiên phú chính; chính không có kỹ năng thì L dùng kỹ năng của Thiên phú phụ đầu tiên có kỹ năng |
| Tẩy Thiên phú | **Làm luôn** |

## 2. Đặc tả

| Mã | Nội dung |
| --- | --- |
| TP5-01 | Tối đa **2 Thiên phú phụ** (tổng 3). Ô 2 mở khi `job` ≠ "", ô 3 khi `job2` ≠ "". Save cũ đã chuyển chức → ô mở ngay, chờ làm lễ |
| TP5-02 | **Lễ Thức Tỉnh (ô phụ)**: chuyển chức xong → thông báo + bảng Lễ Thức Tỉnh tự mở. Còn ô trống thì nút "Lễ Thức Tỉnh" ở bảng Thiên phú. Bể quay = 20 Thiên phú trừ Thiên phú đang có và Đạo Tặc; tỉ lệ theo hạng như lễ đầu; 1 + 3 lần quay lại; bảo hiểm hạng B; không có gift code. Có thể đóng bảng và làm sau (lượt đã quay giữ tới khi nhận) |
| TP5-03 | **Cấp phụ** 1–10 riêng, luyện ở Đền Thiên Phú bằng Thiên Phú Tinh Hoa (cùng bảng giá). Không tiến hoá. Hiệu ứng phụ nhóm ở cấp 5 / 10 có tác dụng như Thiên phú chính. "+2% Tấn công / HP mỗi cấp" chỉ tính Thiên phú chính |
| TP5-04 | **Hiệu ứng chính** của Thiên phú phụ có tác dụng đầy đủ theo cấp phụ (mọi chỗ trong game kiểm "có Thiên phú X" thay vì "Thiên phú chính là X"). Thiên phú gắn với lúc tạo bản đồ (Khứu Giác Kho Báu: thêm Di tích) chỉ tính Thiên phú chính |
| TP5-05 | **Kỹ năng L** (`skill_talent()`): Thiên phú chính nếu có kỹ năng; không thì Thiên phú phụ đầu tiên có kỹ năng (cấp kỹ năng theo cấp Thiên phú đó). Đạo Tặc chỉ là Thiên phú chính |
| TP13-01 | **Cộng hưởng chung**: 2 Thiên phú **cùng nhóm** (không phải cặp đặc biệt) → hiệu ứng chính của cả hai **+10%** (phần thưởng của hiệu ứng ×1,1) |
| TP13-02 | **Cộng hưởng đặc biệt** — 9 cặp (05 mục 4), thay cho +10%: |

| Cặp | Tên | Hiệu ứng (code) |
| --- | --- | --- |
| Mắt Ưng + Khứu Giác Kho Báu | **Thợ Săn Di Tích** | Mọi ô Di tích hiện trên bản đồ khai phá dù còn sương |
| Huyết Chiến + Hấp Huyết | **Huyết Chiến Thần** | HP < 30%: hút máu ×2 |
| Tay Nhanh + Kiếm Tâm | **Liên Hoàn Kiếm** | Đòn mạnh của Kiếm Tâm ở đòn thứ 4 thay vì thứ 5 |
| Thân Thể Cường Tráng + Huyết Chiến | **Bất Khuất** | Mỗi 60 giây, lần đầu HP về 0 thì giữ lại 1 HP |
| May Mắn Nhỏ + Bàn Tay Vàng | **Phú Quý** | Quái tinh anh 5% rơi 1 Tinh Kim |
| Thợ Rèn Bẩm Sinh + Nhà Thảo Dược | **Luyện Kim Sư** | Cường hoá khi có ≥ **2 bình máu**: tự dùng 2 bình làm Dầu Rèn, +10% tỉ lệ lần đó *(05 ghi "5 thảo dược"; từ SN12-01 thảo dược tự chế thành bình máu nên không bao giờ tích đủ 5 — đổi sang 2 bình = 4 thảo dược)* |
| Trái Tim Lãnh Chúa + Long Mạch | **Long Đế** | Long Mạch Đàn xây xong ngay; buff Long Mạch +5% |
| Thuần Thú Sư + Bầy Đàn Bóng Tối | **Chúa Tể Bầy Đàn** | Lính bóng tối không hết thời gian khi còn thú cưng sống |
| Chân Không Biết Mỏi + Thiên Mệnh Khai Giới | **Lữ Khách Thiên Mệnh** | +3 Đuốc tối đa |

| Mã | Nội dung |
| --- | --- |
| TP44-01 | Bảng Thiên phú liệt kê cộng hưởng đang có. Cặp đặc biệt **chưa kích hoạt lần nào** hiện "???" kèm gợi ý nhóm (khi đang có 1 trong 2 Thiên phú); riêng **Thợ Săn Di Tích** hiện sẵn tên (Q21). Kích hoạt lần đầu: chữ vàng + nhật ký, ghi vào `resonance_seen` |
| TP14-01 | **Nước Thánh Tinh Quang** (`starwater`): rơi từ boss hiếm 30%; mua ở cửa hàng làng (tab Tạp hoá) **3.000 vàng** từ vùng 4 (Thánh Đường Tinh Quang) |
| TP14-02 | **Tẩy**: chọn Thiên phú chính hoặc 1 Thiên phú phụ → dùng 1 Nước Thánh → quay **1 lần** (không quay lại, không bảo hiểm) → Thiên phú mới thay chỗ, **giữ 50% cấp luyện** (làm tròn xuống, tối thiểu 1). Thiên phú chính đã tiến hoá → mất tiến hoá. Không tẩy được Đạo Tặc; bể tẩy không có Đạo Tặc và Thiên phú đang có |

## 3. Giao diện

- Bảng Thiên phú (phím T): hàng **"Thiên phú phụ & Cộng hưởng"** dưới 3 cột — 2 ô (khoá: "Mở khi chuyển chức 1 / 2"; trống: nút **Lễ Thức Tỉnh**; có: hạng, tên, nhóm, cấp, hiệu ứng chính hiện tại, **Luyện cấp**, **Tẩy**), danh sách cộng hưởng. Nút **Tẩy** cạnh thẻ Thiên phú chính.
- Bảng **Lễ Thức Tỉnh** (`ui/sub_talent_panel.gd`): Bia Đá, thẻ Thiên phú vừa quay, các lần quay (bấm để chọn lại), Quay lại (còn N), Nhận. Chế độ **Tẩy**: 1 lần quay, kết quả thay ngay.

## 4. Code

`core/talent_slots.gd` (mới): `ids`, `has`, `level_of`, `value` (cấp + cộng hưởng), `has_group_sub`, `sub_slots_open`, `pending`, `sub_pool`, `wash_pool`, `special_pairs`, `has_special`, `general_k`, `resonances`. `GameWorld`: `has_talent`, `tvt`, `skill_talent`, `accept_sub`, `level_sub`, `wash_talent`, `_check_resonance_seen`; mọi chỗ `profile.talent == "x"` có hiệu ứng chính → `has_talent("x")` + `tvt("x", …)`. `Stats.derive` nhận giá trị Thiên phú tính sẵn qua `bonus.talent_vals` / `combat_sub1/2` / `dragon_val`. `Profile` v28: `subs` [{id, level}], `starwater`, `resonance_seen`.

## 5. Test

| Mã | Kiểm |
| --- | --- |
| TP5-T1 | Ô mở theo chuyển chức; lễ ô phụ: bể không có Thiên phú đang có / Đạo Tặc, 4 lượt, nhận; save v28 giữ subs; save cũ v27 → không có subs |
| TP5-T2 | Hiệu ứng chính của Thiên phú phụ: Thân Thể (+HP), Mắt Ưng (+chí mạng), Hấp Huyết (hút máu), Kiếm Tâm (đòn thứ 5); cấp phụ luyện ở Đền; L dùng kỹ năng phụ khi chính không có kỹ năng |
| TP13-T1 | Cộng hưởng chung +10% (Thân Thể + Tay Nhanh); 9 cặp đặc biệt (Liên Hoàn Kiếm đòn thứ 4, Bất Khuất giữ 1 HP, Lữ Khách +3 Đuốc, Thợ Săn Di Tích thấy Di tích…); "???" tới khi kích hoạt |
| TP14-T1 | Tẩy chính / phụ: tốn Nước Thánh, giữ 50% cấp, mất tiến hoá, không Đạo Tặc; mua ở cửa hàng vùng 4+ |

## 6. Kết quả

- Test TP5-T1, TP5-T2, TP13-T1, TP14-T1 qua; smoke `14d-sub-ritual` (bảng Lễ Thức Tỉnh ô phụ), `14e-talent-subs` (bảng Thiên phú: ô phụ + cộng hưởng ???).
- Nước Thánh Tinh Quang dùng lại icon `res-holy_water` (bình nước thánh chương 5); trường save riêng `starwater` (khác `holy_water` của chương 5).
- Chưa làm: cộng hưởng đặc biệt cho nhóm Phép thuật / Điều khiển / Đặc biệt (mỗi nhóm 1 Thiên phú — cần thêm Thiên phú mới, như 05 mục 1.4).
