# 48. Tự đánh thông minh (AF-1) và lời chào khi vào lại game (WB-1)

| Mục | Nội dung |
| --- | --- |
| Ngày | 10/11/2026 |
| Yêu cầu | [Spec_Notes](Spec_Notes.md) 10/11: *"Chế độ tự động đánh đang chưa được tối ưu → nhất là phần ra skills → đang ra toàn bộ skills cùng 1 lúc → cần nghiên cứu kỹ lại chế độ tự đánh thông minh hơn → Check và đề xuất giải pháp"*; *"Khi người chơi chọn nhân vật xong và back lại game → thì cần có lời chào người chơi quay lại chứ nhỉ?"* |
| Quyết định | Chủ dự án: "triển khai đi em" → làm luôn cả hai, không qua bước duyệt đề xuất |
| Mã yêu cầu | `AF-` (Auto Fight), `WB-` (Welcome Back) — đã kiểm tra chưa dùng |
| Ảnh | [design/af1/](design/af1/): `loi-chao.png` (thẻ chào), `cai-dat-tu-danh.png` (Cài đặt → Điều khiển) |
| Trạng thái | ✅ Đã làm 10/11/2026 — test AF1-T1, WB1-T1 |

## A. Tự đánh thông minh (AF-1)

### A.1. Vì sao "ra toàn bộ skills cùng 1 lúc"

Code cũ (`GameWorld._auto_input`): mỗi khung hình duyệt 7 ô kỹ năng, tung **kỹ năng đầu tiên vừa hồi xong** nếu nó có sát thương, quái trong tầm và còn MP. Hệ quả:

| Vấn đề | Do đâu |
| --- | --- |
| Xả cả 7 chiêu trong khoảng 0,1 giây | Mỗi khung tung 1 chiêu, khung sau tung tiếp chiêu kế tiếp — không có nhịp nghỉ giữa các chiêu |
| Đốt chiêu mạnh vào 1 con quái sắp chết | Không xét máu quái, số quái, quái thường hay tinh anh |
| Chiêu diện rộng tung khi chỉ có 1 quái; chiêu đặt điểm nhắm vào con gần nhất chứ không vào giữa đàn | Không đếm số quái trong vùng chiêu |
| Không bao giờ dùng Kiếm Ý, Ưng Nhãn, Pháp Thuẫn, Khiên Thép, Liên Kết, Triệu Hồi Xương… | Điều kiện `mul > 0` loại mọi kỹ năng không gây sát thương |
| Hết MP giữa trận, không còn MP cho khiên khi nguy | Không giữ MP dự trữ |
| Gọi lại linh thú khi linh thú cũ còn sống | Không nhớ đã gọi |
| Máu thấp vẫn đứng đánh | Không tự uống bình |

### A.2. Cách mới

Mỗi kỹ năng có **chiến thuật** (`data/auto_tactics.gd`, đủ 70 kỹ năng 5 lớp):

| Loại | Kỹ năng ví dụ | Khi nào dùng |
| --- | --- | --- |
| Diện rộng quanh mình (`aoe_self`, bán kính) | Xoáy Kiếm, Băng Ngục, Chấn Địa | ≥ 2 quái trong vòng; 1 quái chỉ khi là mục tiêu trâu |
| Diện rộng tại điểm ngắm (`aoe_at`) / nảy (`chain`) | Thiên Thạch, Vũ Tiễn, Sét Chuỗi | Như trên, **nhắm vào chỗ đông quái nhất** trong tầm ném |
| Đường thẳng xuyên quái (`line`) | Trảm Phong, Xuyên Tâm Tiễn, Băng Lao | Đếm quái trên đường; 1 quái vẫn dùng được (điểm thấp) |
| Lao (`dash`) | Đột Kích, Lao Khiên, Xung Phong | Cận chiến: áp sát quái đang ở xa (7 m tới hết tầm lao); hoặc đường lao có ≥ 2 quái |
| Một mục tiêu (`single`) | Liên Xạ | Ưu tiên mục tiêu trâu |
| Tăng sức mạnh (`buff`) | Kiếm Ý, Ưng Nhãn, Liên Kết | Có đàn ≥ 2 quanh mục tiêu hoặc mục tiêu trâu; Liên Kết cần linh thú đang sống |
| Phòng thủ (`defense`) | Pháp Thuẫn, Khiên Thép, Thánh Bất Diệt | HP < 50% (ưu tiên cao nhất), hoặc ≥ 3 quái áp sát khi HP < 85% |
| Gọi linh thú (`summon`, thời gian sống) | Sói Bóng, Tiểu Quỷ, Ấu Long | Khi vào trận; không gọi lại khi lần gọi trước còn sống |
| Thoát (`escape`) | Lộn Nhào | Quái áp sát dưới 8 m |
| Cờ `big` | Nhất Kiếm Khai Thiên, Phá Không Tiễn, Kỳ Lân | Để dành cho tinh anh / đàn ≥ 3 |
| Cờ `ult` (Tối thượng) | Vạn Kiếm Quy Tông, Thiên Tai Nguyên Tố, Quân Đoàn | Chỉ khi đàn ≥ 4 hoặc mục tiêu trâu |
| Cờ `hp_cost` | Huyết Bạo | Không dùng khi HP < 50% |

**Mục tiêu trâu** = tinh anh, thủ lĩnh / chúa hang / quái hiếm, hoặc còn ≥ 8 đòn thường. **Quái sắp chết** = chỉ còn 1 quái, quái thường, máu ≤ 3 đòn thường → chỉ đánh thường.

Mỗi nhịp, mọi kỹ năng đang sẵn sàng được **chấm điểm** (đàn càng đông điểm càng cao, phòng thủ khi nguy 100, tối thượng 90, chiêu hệ số cao / hồi lâu được cộng nhẹ), tung **đúng 1 chiêu điểm cao nhất**, rồi nghỉ một nhịp:

| Kiểu (Cài đặt → Điều khiển → "Tự đánh: kỹ năng") | Nhịp giữa 2 chiêu | Giữ MP | Ghi chú |
| --- | --- | --- | --- |
| **Thông minh** (mặc định) | 0,45 giây | Dưới 30% MP chỉ dùng chiêu điểm ≥ 70 (khiên, tối thượng) | |
| **Tiết kiệm MP** | 0,8 giây | Dưới 50% MP | Không dùng chiêu diện rộng / đường thẳng cho đàn nhỏ (điểm < 60) với quái thường |
| **Xả hết** | Không nghỉ | Không | Cách cũ (tung ngay khi hồi xong), có thêm buff / khiên / gọi linh thú |

**Tự uống bình** (mọi kiểu): HP < 35% → bình máu; MP < 12% khi đang đánh → bình MP (khi còn bình và hết hồi).

Không đổi: boss vẫn đánh tay (Tự đánh tự tắt), di chuyển để tạm nhường, thú cưng / linh thú lao vào trước (SN9-04).

### A.3. Kỹ thuật

- `scripts/data/auto_tactics.gd` (`TACTICS`, `MODES`), `scripts/core/auto_fight.gd` (`choose(w, mục tiêu, khoảng cách, kiểu)`, `potions`, `foes`, `count_near`, `count_line`, `best_center`). `GameWorld._auto_input` gọi `AutoFight.choose` (bỏ qua khi đang lao / né / choáng), ghi `_auto_skill_at`, `_auto_cast[kỹ năng]`.
- `GameWorld.auto_mode` — `main.gd` chép từ `Settings.values.auto_skills` mỗi khung; Cài đặt mới `auto_skills` (mặc định `smart`).
- Bot cân bằng trong test (TL-B…) dùng đường riêng, không qua `_auto_input` → số liệu cân bằng cũ giữ nguyên.

## B. Lời chào khi vào lại game (WB-1)

Khi chọn **nhân vật đã có** ở màn hình chọn nhân vật (`main._on_continue`), giữa màn hình hiện thẻ chào, game tạm dừng tới khi bấm **Vào game** (hoặc Esc / bấm ra ngoài). Nhân vật mới tạo không hiện (đã có Lễ Thức Tỉnh).

| Phần | Nội dung |
| --- | --- |
| Tiêu đề | Chào theo giờ máy: sáng (5–10 giờ) / trưa (11–13) / chiều (14–17) / tối — "Chào buổi tối, Anh Vinh Đẹp Zai!"; chân dung lớp; dòng phụ "Chào mừng trở lại · Pháp Sư · Cấp 24" |
| Lần trước | "Bạn đã rời đi 2 ngày 3 giờ." (vắng ≥ 3 ngày: "Lâu rồi mới gặp lại — …"); nơi dừng lần trước; bước nhiệm vụ chính đang làm (chương, bước, tên, gợi ý) |
| Trong lúc vắng mặt | EXP lãnh địa; vàng, gỗ, Đá, Sắt, Đuốc, thảo dược thu hoạch (chỉ khi vắng > 1 phút và có thu hoạch) |
| Nên làm ngay | Uỷ thác hôm nay còn N việc (O); điểm tiềm năng chưa cộng (C); Điểm Kỹ Năng chưa dùng (U); số việc tăng Lực chiến làm được ngay (NL-1) |

Kỹ thuật: dữ liệu `scripts/core/welcome.gd` (`greeting`, `away_text`, `build`), giao diện `scripts/ui/welcome_panel.gd` (kế thừa `modal.gd`, nằm trong `main._panels()` nên game dừng). Thời gian vắng tính **trước** `SaveSystem.apply_offline` (hàm đó cắt theo giới hạn lãnh địa). Các dòng nhật ký thu hoạch cũ vẫn giữ.

## C. Test

- `run_tests.gd --only=AF1`: đủ chiến thuật 70 kỹ năng; 1 quái yếu → chỉ đánh thường; đàn 4 quái → đúng 1 chiêu (Xoáy Kiếm / Kiếm Ý), nhịp sau không tung tiếp; 6 giây không có 2 chiêu cùng khung; HP 40% → Pháp Thuẫn trước, HP 30% → uống bình; Thiên Thạch nhắm giữa đàn; Triệu Hồi Sư mở bằng Sói Bóng, không gọi lại khi còn sống, Liên Kết cần linh thú; Xả hết = cách cũ; Tiết kiệm MP; Thợ Săn Tự đánh hạ được quái.
- `--only=WB1`: chào theo buổi, thời gian vắng, 3 phần, thu hoạch, nhắc điểm, vắng lâu.
- Ảnh: `tests/wb1_shot.gd --out=<file>`; Cài đặt: `tests/settings_shot.gd --tab=controls`.
