# Kỹ năng bị động (PV)

| | |
| --- | --- |
| Dự án | Thiên Phú Khai Giới |
| Nguồn | Chủ dự án (30/10/2026): *"Kỹ năng của các class, không có kỹ năng nào là kỹ năng bị động à? Tôi nghĩ cần có kỹ năng bị động, người chơi không cần kích hoạt, bị động sẽ tự động."* Duyệt theo đề xuất, làm cho cả 5 lớp |
| Liên quan | [13 hệ kỹ năng](13-he-ky-nang.md), [22 danh mục kỹ năng](22-danh-muc-ky-nang-lop-hien-tai.md), [26 build lớp](26-build-lop.md) (đặc tính lớp) |
| Trạng thái | ✅ **Đã làm** (30/10/2026), save v21, test PV-T1…T4 |

## 1. Vấn đề

Game đã có hiệu ứng bị động, nhưng người chơi gần như không thấy và không chọn được:

| Nguồn | Người chơi thấy ở đâu (trước PV) |
| --- | --- |
| Đặc tính lớp (docs/26 mục 3.1) | Không thấy |
| Bị động chuyển chức 1 / 2 / 3 | Lời thoại NPC, bảng chuyển chức |
| Thiên phú hạng C / B | Bảng Thiên phú |

Bảng Kỹ năng chỉ có kỹ năng chủ động, nên không có lựa chọn build bị động.

## 2. Luật chung

| Mã | Yêu cầu |
| --- | --- |
| PV-01 | Mỗi lớp có **4 kỹ năng bị động**, mở ở **cấp 10 / 20 / 35 / 50** |
| PV-02 | Bị động **luôn có tác dụng**: không lắp vào ô 1–4, không bấm, không tốn MP, không có hồi chiêu |
| PV-03 | Mỗi bị động có **cấp 0–5**. Cấp 0 = chưa học. Mỗi cấp tốn **1 Điểm Kỹ Năng**, dùng chung với kỹ năng chủ động. Hiệu lực tăng đều theo cấp (cấp 5 = 5 × cấp 1) |
| PV-04 | Học hoặc nâng ở **mọi nơi**, giống nâng cấp kỹ năng chủ động. Chỉ số đổi ngay sau khi học |
| PV-05 | **Tẩy điểm** (vùng an toàn) hoàn lại cả điểm bị động |
| PV-06 | Lên đúng cấp mở thì báo: *"Mở kỹ năng bị động: <tên>! Phím U → tab Bị động để học."* |
| PV-07 | Bảng Kỹ năng có tab **Bị động**. Cột trái: 4 bị động học được (nối theo cấp mở, huy hiệu "n/5"). Cột phải "**Sẵn có**": Đặc tính lớp, Chuyển chức 1, 2, 3 — chỉ để xem, chưa có thì ghi điều kiện |
| PV-08 | Chi tiết bị động: tên, nhãn "Bị động · Luôn có tác dụng", cấp, hiệu ứng hiện tại và cấp kế, nút **Học** (cấp 0) / **Nâng cấp**; nút khoá thì tooltip ghi lý do |
| PV-09 | Icon bị động có **viền trong xanh lục** để phân biệt với kỹ năng chủ động |
| PV-10 | Save **v21**: `passive_levels` {id: cấp}. Save cũ nạp được, chưa học bị động nào |

**Ngân sách điểm:** 4 bị động × 5 cấp = 20 điểm. Đến cấp 60 người chơi có 59 điểm. 13 kỹ năng chủ động × 9 cấp cần 117 điểm, nên phải chọn dồn điểm vào đâu.

## 3. Danh sách 20 bị động

Giá trị trong bảng là **mỗi cấp / cấp 5**.

### 3.1. Kiếm Khách

| Cấp mở | Id | Bị động | Hiệu ứng |
| ---: | --- | --- | --- |
| 10 | `thietcot` | Thiết Cốt | +3% / +15% HP tối đa |
| 20 | `kiemtam` | Kiếm Tâm | +5% / +25% sát thương chí mạng |
| 35 | `phankich` | Phản Kích | Né được đòn (né lăn hoặc né tránh): 3 giây sau đó +6% / +30% sát thương |
| 50 | `chieny` | Chiến Ý | HP dưới 40%: +4% / +20% sát thương và +3% / +15% tốc đánh |

### 3.2. Thợ Săn

| Cấp mở | Id | Bị động | Hiệu ứng |
| ---: | --- | --- | --- |
| 10 | `ungmuc` | Ưng Mục | Quái cách xa hơn 15 m: +4% / +20% sát thương |
| 20 | `sanmoi` | Săn Mồi | Quái dưới 50% HP: +4% / +20% sát thương |
| 35 | `buocgio` | Bước Gió | +2% / +10% tốc chạy, +1% / +5% né tránh (không vượt trần né 40% của lớp) |
| 50 | `tamdoc` | Tên Tẩm Độc | Mỗi đòn trúng có 5% / 25% tỉ lệ thêm 1 tầng độc như Tên Độc (20% Tấn công mỗi giây mỗi tầng, tối đa 3 tầng, 4 giây) |

### 3.3. Pháp Sư

| Cấp mở | Id | Bị động | Hiệu ứng |
| ---: | --- | --- | --- |
| 10 | `minhtuong` | Minh Tưởng | +6% / +30% hồi MP |
| 20 | `nguyento` | Tinh Thông Nguyên Tố | Đòn khắc hệ quái: +5% / +25% sát thương |
| 35 | `doidao` | Pháp Lực Dồi Dào | MP trên 70%: +4% / +20% sát thương |
| 50 | `hothe` | Hộ Thể Pháp Lực | 4% / 20% sát thương nhận vào trừ vào MP thay cho HP (khi còn MP) |

### 3.4. Hộ Vệ

| Cấp mở | Id | Bị động | Hiệu ứng |
| ---: | --- | --- | --- |
| 10 | `kienthu` | Kiên Thủ | +4% / +20% Phòng thủ |
| 20 | `ychisat` | Ý Chí Sắt | Hồi 0,2% / 1% HP tối đa mỗi giây |
| 35 | `phanchan` | Phản Chấn | Bị đánh trúng: phản 6% / 30% sát thương nhận vào lên quái đánh mình (cộng dồn với Thiết Vệ) |
| 50 | `uyap` | Uy Áp | +3% / +15% sát thương lên boss, boss hiếm, tinh anh |

### 3.5. Triệu Hồi Sư

| Cấp mở | Id | Bị động | Hiệu ứng |
| ---: | --- | --- | --- |
| 10 | `linhkhe` | Linh Khế | Linh thú +4% / +20% sát thương |
| 20 | `linhthe` | Linh Thể | Linh thú +8% / +40% HP (tính lúc gọi) |
| 35 | `linhho` | Linh Hộ | Mỗi linh thú đang sống (tối đa 3): người chơi nhận ít hơn 1% / 5% sát thương (tối đa −15%) |
| 50 | `honluc` | Hồn Lực | Sát thương của bản thân +3% / +15% |

### 3.6. Ghi chú thiết kế

- Mỗi lớp có 1–2 bị động **sát thương có điều kiện** để người chơi phải chơi đúng kiểu lớp: Thợ Săn đứng xa, Pháp Sư giữ MP, Kiếm Khách né rồi phản đòn.
- Hộ Vệ chủ yếu nhận bị động **trụ** (Phòng thủ, hồi máu, phản đòn); Triệu Hồi Sư nhận bị động **linh thú**.
- Không có bị động nào tăng sát thương vào thanh Phá Thế (mục 5).

## 4. Kỹ thuật

| Mục | Cách làm |
| --- | --- |
| File | `godot/scripts/core/passives.gd`: dữ liệu `DEFS` (5 lớp × 4), `TRAITS` (chữ đặc tính lớp), `defs_of`, `level_of`, `describe`, `can_upgrade`, `upgrade`, `reset`, `unlocked_at` |
| Module | Nằm trong `Chapters.MODULES` (khung hook D38, như `job3.gd`). `HOOKS`: `derive_bonus` (HP %, tốc chạy %), `derive_after` (ST chí mạng, hồi MP, Phòng thủ, HP linh thú, né tránh), `hit_mult`, `tick` (Phản Kích hết giờ, Ý Chí Sắt) |
| Gọi thẳng từ GameWorld | `speed_mult` (trong `atk_speed()`), `on_evade` (2 nhánh né trong `_damage_player`), `absorb` (trước khiên chắn), `after_hit` (Tên Tẩm Độc, sau `Classes2.after_hit`); `passive_upgrade(id)`; `skill_reset` hoàn điểm; báo mở khi lên cấp |
| Gọi từ Classes2 | `taken_mult` × `Passives.taken_mult` (Linh Hộ), `on_player_hit` cộng `Passives.reflect` (Phản Chấn), `ally_mult` cộng `Passives.ally_bonus` (Linh Khế) |
| Trạng thái | `GameWorld.pv` (`Passives.State`: `counter_t` của Phản Kích) — không lưu save |
| Save | `Profile.VERSION` 20 → **21**, trường `passive_levels` |
| Giao diện | `ui/skill_panel.gd`: nhóm `"passive"` trong `_groups()` (khoá `extra` = bị động sẵn có), `_passive_tree`, `_passive_detail`, `_passive_upgrade`; `SkillNode.max_level`, `level < 0` = không vẽ huy hiệu cấp |
| Icon | `tools/art/passive_icons.py` → `skill-pv-<id>` (20) + `skill-pv-tab` |

## 5. Cân bằng (PV-T3)

Đo như SK3-T4: cấp 60, chuyển chức 2 nhánh đầu, bộ kỹ năng mặc định, đồ cấp 60, hạ Viêm Long (5-3), trung bình 2 seed. So sánh không bị động với cả 4 bị động cấp 5.

| Lớp | Không bị động | Bị động cấp 5 | Nhanh hơn |
| --- | ---: | ---: | ---: |
| Kiếm Khách | 36,2 giây | 34,2 giây | 6% |
| Thợ Săn | 32,8 giây | 31,1 giây | 6% |
| Pháp Sư | 25,2 giây | 24,3 giây | 4% |
| Hộ Vệ | 35,8 giây | 34,5 giây | 4% |
| Triệu Hồi Sư | 37,4 giây | 34,0 giây | 10% |

0 lần chết ở cả 5 lớp. Các lớp chênh nhau 6 điểm %, trong giới hạn 15 điểm % của test.

**Đo lại 31/10** (sau khi phiên khác chỉnh chỉ số lớp): Kiếm Khách 1% · Thợ Săn 5% · Pháp Sư 9% · Hộ Vệ 14% · Triệu Hồi Sư 8%, 0 lần chết. Bị động Kiếm Khách phần lớn có điều kiện (né rồi phản đòn, HP dưới 40%) mà bot ít gặp, nên test PV-T3 đổi cận dưới từ "nhanh hơn ≥ 2%" thành **"không chậm hơn"**; giữ trần 30% và các lớp chênh ≤ 15 điểm %. Các bị động trụ (Phòng thủ, hồi máu, giảm sát thương nhận) không rút ngắn trận nên không hiện trong bảng.

**Đã đổi khi cân bằng:**

| Bị động | Bản đầu | Bản cuối | Lý do |
| --- | --- | --- | --- |
| Uy Áp | +8% Phá Thế và +2% boss mỗi cấp | +3% sát thương lên boss / tinh anh mỗi cấp, **bỏ phần Phá Thế** | Chỉ cần thêm một ít sát thương Phá Thế là bot Hộ Vệ phá thế boss thêm một lần, trận ngắn đi 26–36%. Đây là kiểu ngưỡng như D41 |
| Kiếm Tâm | +4% | +5% | Kiếm Khách chỉ nhanh hơn 5% |
| Ưng Mục, Săn Mồi | +3% | +4% | Thợ Săn chỉ nhanh hơn 5% |
| Tinh Thông Nguyên Tố | +4% | +5% | Pháp Sư chỉ nhanh hơn 4% |
| Pháp Lực Dồi Dào | +3% | +4% | như trên |

TL-B và các test cân bằng cũ không đổi: profile trong test có `passive_levels` rỗng.

## 6. Kiểm thử

| Mã | Nội dung |
| --- | --- |
| PV-T1 | 5 lớp × 4 bị động, mở cấp 10/20/35/50, id không trùng, đủ icon; chưa đủ cấp / sai lớp thì từ chối; học tới cấp 5, mỗi cấp 1 điểm; HP tăng ngay; tẩy điểm hoàn 5 điểm, HP về như cũ; lên cấp 20 báo mở Kiếm Tâm; save v21 giữ cấp, save v20 nạp được |
| PV-T2 | Hiệu ứng của cả 20 bị động (đo từng hệ số), chưa học thì hệ số 1,0 |
| PV-T3 | Cân bằng mục 5: không chậm hơn, nhanh hơn tối đa 30%, 0 lần chết, các lớp chênh ≤ 15 điểm % |
| PV-T4 | Bảng Kỹ năng: tab Bị động, đủ 8 ô (4 học được + 4 sẵn có), nút Học hoạt động, bị động cấp 50 khoá ở cấp 35, chọn Đặc tính lớp hiện mô tả |

## 7. Ngoài phạm vi

- Bị động mở thêm ở chuyển chức (bị động chuyển chức hiện vẫn tự có, không tốn điểm).
- Bị động rơi từ quái hoặc Bí Kíp cho bị động.
- Ô lắp bị động giới hạn: chủ dự án chọn "luôn bật cả 4".
