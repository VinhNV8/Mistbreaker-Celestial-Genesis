"""Sinh docs/06-ban-do-quai-boss.md từ công thức chỉ số + dữ liệu thiết kế.
Chạy lại script này mỗi khi đổi công thức hoặc thêm quái, để mọi bảng luôn khớp công thức."""
import math
import sys

OUT = sys.argv[1]

# ---------------------------------------------------------------- công thức
def player(L):
    return {"atk": 10 + 13 * (L - 1), "hp": 100 + 50 * (L - 1), "def": 5 + 3.5 * (L - 1)}

def exp_to_next(L):
    return math.floor(100 * L ** 2.2 + 500 * (L // 10) ** 3)

def mob_exp(L):
    return round(30 * L ** 1.5)

TIERS = {  # số đòn để hạ (H), đòn của quái lấy bao nhiêu % HP người chơi (h), hệ số phòng thủ
    "thuong": (3, 0.06, 1.0),
    "tinhanh": (12, 0.09, 1.5),
    "boss": (130, 0.10, 2.0),
    "hiem": (200, 0.12, 2.0),
}
ARCH = {  # HP, ATK, DEF, tốc (đơn vị/giây), tầm (m)
    "Nhanh": (0.8, 0.9, 0.8, 160, 3.4),
    "Bầy": (0.5, 0.6, 0.6, 140, 3.0),
    "Lì": (1.4, 0.9, 1.3, 80, 3.6),
    "Giáp": (1.2, 1.0, 2.0, 70, 4.0),
    "Xa": (0.9, 0.9, 0.8, 70, 24),
    "Phép": (0.9, 1.2, 0.8, 110, 18),
    "Tự nổ": (0.6, 2.5, 0.5, 170, 2.0),
    "Boss": (1.0, 1.0, 1.0, 175, 5.8),
}

def boss_hits(chapter):
    # Q23: boss đầu tiên nằm trong 30 phút đầu nên ngắn hơn (≈ 35–40 giây), tăng dần theo chương.
    return 90 if chapter == 1 else (110 if chapter <= 3 else 130)

def stats(L, tier, arch, ref_level=None, hits=None):
    H, h, dmul = TIERS[tier]
    H = hits or H
    mh, ma, md, spd, rng = ARCH[arch]
    P = player(ref_level or L)
    dfn = (3 + 1.5 * L) * dmul * md
    dmg_p = P["atk"] ** 2 / (P["atk"] + dfn)
    # Boss hiếm: loại quái chỉ đổi Tấn công/Phòng thủ, không nhân thêm HP (tránh 200 đòn × 1,4).
    hp = H * dmg_p * (1.0 if tier == "hiem" else mh)
    k = h * P["hp"]
    atk = (k + math.sqrt(k * k + 4 * k * P["def"])) / 2 * ma
    return {"hp": round(hp), "atk": round(atk), "def": round(dfn), "spd": spd, "rng": rng}

def fmt_range(a, b):
    return f"{a:,}".replace(",", ".") if a == b else f"{a:,} → {b:,}".replace(",", ".")

# ---------------------------------------------------------------- dữ liệu thiết kế
REGIONS = [
 dict(n=1, name="Rừng Sương", lv=(1, 10), el="Mộc", unlock="Bắt đầu game",
  next_req="Hạ Sói Chúa Hư Vô + cấp 10 + khai phá ≥ 60% vùng 1",
  env=[("Sương mù nhẹ", "Tầm nhìn còn khoảng 60% màn hình (vignette). Ở Lõi Sương, quái cách xa hơn 20 m bị mờ."),
       ("Vùng hướng dẫn", "Quái không theo vào Làng Thanh Thạch; hồi sinh ở làng sau 2,5 giây")],
  maps=[("1-1 Bìa Rừng Sương", "1–4", "Làng Thanh Thạch, Lễ Thức Tỉnh, lưới khai phá đầu tiên (10 ô)"),
        ("1-2 Rừng Sương Sâu", "4–7", "Lưới khai phá 15 ô, Ổ quái, lối vào Hang Sói Chúa"),
        ("1-3 Lõi Sương", "7–10", "Mở sau khi hạ Sói Chúa; lưới 15 ô; boss hiếm Lão Thụ Sương Mù"),
        ("Dungeon: Hang Sói Chúa", "6", "Boss chương 1")],
  grid="40 ô (10 + 15 + 15)", res="Rừng gỗ → Xưởng Gỗ; thảo dược",
  set=("Bộ Thợ Săn Sương", "2: +8% HP · 4: +10% Tấn công · 6: Xoáy Kiếm hồi chiêu 6 → 4 giây", "✅ Đã có"),
  mobs=[("Sói Sương", "Nhanh", "Mộc", (1, 7), "**Cắn** (vung 0,45 s, ×1,0). Đi bầy 2–3 con", "STR 35 · AGI 50 · VIT 15", "wolf"),
        ("Nấm Độc", "Xa", "Thổ", (2, 7), "**Phun bào tử** (vung 0,7 s, đạn 28 m/s, ×1,0). Chết để lại vũng độc 3 m, 2% HP/giây trong 3 giây", "VIT 45 · INT 35 · LUK 20", "mushroom"),
        ("Tinh Linh Sương", "Phép", "Thủy", (5, 10), "**Lao sương** (vung 0,35 s, lao 15 m, ×1,0). Ở Lõi Sương: tàng hình khi cách hơn 20 m", "AGI 35 · INT 45 · LUK 20", "wisp"),
        ("Mộc Tinh", "Giáp", "Mộc", (6, 10), "**Dậm đất** (vung 1,0 s, vòng 6 m, ×1,4). Chậm nhưng khó hạ", "STR 40 · VIT 60", None)],
  elites=[("Sói Đầu Đàn", "Nhanh", "Mộc", (3, 8), "**Hú gọi** (hồi 15 s): gọi 2 Sói Sương; cả bầy +20% tốc chạy 6 giây", "STR 35 · AGI 50 · VIT 15"),
          ("Nấm Mẹ", "Lì", "Thổ", (5, 10), "**Sinh sôi** (mỗi 8 s): đẻ 2 nấm con (loại Bầy), nấm con tự nổ sau 3 giây, vòng 3 m, ×1,5", "VIT 45 · INT 35 · LUK 20")],
  boss=dict(name="Sói Chúa Hư Vô", lv=6, ref=5, el="Mộc", arch="Boss", code="boss",
   phases=[("1 (100% → 50%)", "**Cắn** (vung 0,55 s, ×1,0, 5,8 m) · **Vồ** (khi người chơi cách hơn 15 m, hồi 5 s: vòng đỏ 8 m tại chỗ người chơi, vung 0,85 s, ×2,0)"),
           ("2 (dưới 50%)", "Gọi 3 Sói Sương cấp 5 · **Ẩn mình trong sương**: chỉ hiện khi vung đòn, bị choáng, hoặc người chơi đứng gần dưới 14 m")],
   steal="**Vồ Mồi**: lao tới điểm ngắm (tối đa 30 m), ×2,5 sát thương vòng 9 m", steal_code="✅",
   drop="1 đồ Tím (25% thuộc Bộ Thợ Săn Sương) · 15% **Nanh Sói Chúa** (vũ khí Cam: đòn chém thứ 3 thêm 60% sát thương) ✅"),
  rare=dict(name="Lão Thụ Sương Mù", lv=9, el="Mộc", arch="Lì", where="Lõi Sương",
   skills="**Rễ Trói** (vung 1,2 s: 3 vòng 3 m quanh người chơi, ×1,2, trói 1,5 s) · **Lá Độc** (nón 60°, 10 m, ×1,0 + độc 2% HP/giây 4 giây). Dưới 40% HP: **Rừng Thức Tỉnh** — gọi 2 Mộc Tinh, hồi 1% HP/giây khi còn rễ (phá 3 gốc rễ để ngắt)",
   drop="**Vỏ Lão Thụ** (bùa Cam: đứng yên 1 giây thì hồi 2% HP/giây) · 1 Tinh Hoa Tiến Hoá · 5 Thiên Phú Tinh Hoa")),

 dict(n=2, name="Đồng Bằng Gió Hú", lv=(10, 20), el="Kim", unlock="Hạ Sói Chúa (kịch bản)",
  next_req="Hạ Tướng Gián Điệp Huyền Ảnh + **Lực chiến 5.000** (kịch bản)",
  env=[("Gió đổi hướng", "Mỗi 12 giây đổi hướng (mũi tên báo trước 2 giây). Đẩy người chơi 6 m/giây theo hướng gió; ngược gió −30% tốc chạy, xuôi gió +20%"),
       ("Đạn bị lệch", "Đạn và mũi tên lệch 15° theo hướng gió (cả của người chơi lẫn quái)")],
  maps=[("2-1 Cửa Gió", "10–13", "Lưới 15 ô"),
        ("2-2 Thảo Nguyên Hú", "13–17", "Lưới 15 ô; Mỏ đá đầu tiên"),
        ("Thành Biên Đài", "—", "Thành an toàn: Liên minh Khai Giới, cửa hàng, nhiệm vụ cốt truyện chương 2"),
        ("2-3 Mắt Bão", "17–20", "Lưới 15 ô; gió đổi mỗi 8 giây; boss hiếm Bạch Hổ Phong Vân"),
        ("Dungeon: Phủ Huyền Ảnh", "18", "Boss chương 2")],
  grid="45 ô", res="Rừng thưa → Xưởng Gỗ; Núi đá → **Mỏ** (Đá); Suối → **Bến Cá** (buff lãnh địa: +3% HP tối đa mỗi cấp công trình, tối đa +15%; không tạo tài nguyên mới — Q26)",
  set=("Bộ Phong Hành", "2: +8% tốc chạy · 4: +8% tốc đánh · 6: né lăn hồi 3 → 2 giây", "⬜"),
  mobs=[("Ưng Gió", "Nhanh", "Kim", (10, 16), "**Bổ nhào** (bay lên 0,6 s rồi lao 12 m, ×1,3). Xuôi gió +50% tốc", "AGI 60 · LUK 40", None),
        ("Lính Đánh Thuê Hư Vô", "Giáp", "Kim", (11, 18), "**Khiên chặn**: giảm 70% sát thương từ phía trước — đánh từ bên hoặc sau. **Đâm** (vung 0,6 s, ×1,2)", "STR 50 · VIT 50", None),
        ("Cung Thủ Thảo Nguyên", "Xa", "Mộc", (12, 19), "**Bắn ba mũi** (vung 0,8 s, nón 30°, mỗi mũi ×0,7)", "AGI 70 · LUK 30", None),
        ("Lốc Xoáy Con", "Phép", "Kim", (14, 20), "**Hút** (vung 1,0 s): kéo người chơi trong 8 m về phía nó 3 m/giây trong 2 giây, rồi nổ vòng 4 m ×1,5", "INT 60 · AGI 40", None)],
  elites=[("Đội Trưởng Đánh Thuê", "Giáp", "Kim", (13, 19), "**Chém xoáy** (hồi 10 s): 3 vòng chém 360°, 5 m, mỗi vòng ×1,6", "STR 60 · VIT 40"),
          ("Phù Thuỷ Gió", "Phép", "Kim", (15, 20), "**Nghịch Phong** (hồi 14 s): đổi hướng gió ngay lập tức, gió mạnh ×2 trong 6 giây", "INT 60 · LUK 40")],
  boss=dict(name="Tướng Gián Điệp Huyền Ảnh", lv=18, ref=17, el="Kim", arch="Boss",
   phases=[("1 (100% → 60%)", "**Ám tiễn** (vung 0,5 s: 3 phi tiêu nón 40°, mỗi phi tiêu ×0,8) · **Thoắt ẩn** (hồi 6 s: dịch chuyển ra sau lưng người chơi, vung 0,4 s, ×1,5)"),
           ("2 (60% → 25%)", "**Phân thân**: tạo 2 bản sao (mỗi bản 8% HP boss, đánh ×0,5). **Chỉ bản thật có bóng** (kịch bản). Đánh trúng bản giả: nó nổ vòng 4 m ×0,8"),
           ("3 (dưới 25%)", "**Vạn Ảnh**: 4 bản sao, cả 5 đổi chỗ cho nhau mỗi 6 giây")],
   steal="**Phân Thân**: tạo 2 ảo ảnh hút đòn của quái trong 6 giây", steal_code="⬜",
   drop="1 đồ Tím · 15% **Mặt Nạ Huyền Ảnh** (mũ Cam: né lăn để lại 1 phân thân hút đòn trong 2 giây)"),
  rare=dict(name="Bạch Hổ Phong Vân", lv=20, el="Kim", arch="Nhanh", where="Mắt Bão",
   skills="**Hổ Vồ** (chuỗi 3 cú vồ liên tiếp, mỗi cú vòng 6 m, ×1,4) · **Gầm Gió** (vòng 10 m: đẩy lùi 8 m, choáng 1 giây). Dưới 50%: **Cưỡi Gió** — luôn xuôi gió, tốc ×1,5. *Code (M5-01): Hổ Vồ mỗi 4 giây, Gầm Gió hồi riêng 9 giây khi đứng sát; đòn cắn thường vung 0,6 s, nghỉ 1,2 s; chỉ xuất hiện sau khi hạ Huyền Ảnh*",
   drop="**Vuốt Bạch Hổ** (găng Cam: đòn chí mạng gây chảy máu ×0,3 mỗi giây trong 4 giây) · 1 Tinh Hoa Tiến Hoá · 5 Thiên Phú Tinh Hoa")),

 dict(n=3, name="Sa Mạc Xích Sa", lv=(20, 32), el="Thổ", unlock="Lực chiến 5.000 (kịch bản)",
  next_req="Hạ Bọ Cạp Sa Hoàng + **chuyển chức 1** (kịch bản)",
  env=[("Ngày / đêm", "Chu kỳ 6 phút: 4 phút ngày, 2 phút đêm"),
       ("Nắng gắt (ban ngày)", "Mất 1% HP mỗi 5 giây khi không đứng trong bóng râm hoặc ốc đảo; uống nước ở ốc đảo xoá 60 giây"),
       ("Đêm", "Quái +15% Tấn công; tầm nhìn 70%"),
       ("Bão cát", "Ngẫu nhiên mỗi 3–5 phút, 30 giây: tầm nhìn 40%, đạn bay chậm 30%")],
  maps=[("3-1 Rìa Cát Đỏ", "20–24", "Lưới 15 ô"),
        ("3-2 Ốc Đảo Lãng Quên", "24–28", "Lưới 15 ô; ốc đảo là vùng an toàn khỏi nắng"),
        ("3-3 Di Tích Khai Giới Giả", "28–32", "Lưới 15 ô; cốt truyện chương 3; boss hiếm Nhân Sư Đá"),
        ("Dungeon: Sào Huyệt Sa Hoàng", "30", "Boss chương 3")],
  grid="45 ô", res="Mỏ đá, Mỏ sắt (**Sắt**), ốc đảo → Vườn Thảo Dược",
  set=("Bộ Sa Hành Giả", "2: miễn nhiễm Nắng gắt · 4: +10% Phòng thủ · 6: Xoáy Kiếm để lại lốc cát 4 giây làm chậm 40%", "⬜"),
  mobs=[("Bọ Cát", "Bầy", "Thổ", (20, 26), "Đi bầy 5 con. **Cắn** (vung 0,4 s, ×1,0)", "VIT 50 · STR 50", None),
        ("Rắn Đồi Cát", "Nhanh", "Thổ", (21, 28), "**Chui cát** 1,5 giây (bất tử, có vệt cát báo), trồi lên dưới chân người chơi, ×1,4", "AGI 60 · STR 40", None),
        ("Xác Ướp Khai Giới", "Lì", "Thổ", (24, 32), "**Nguyền rủa** (vung 0,8 s): −20% hồi máu trong 6 giây", "VIT 60 · INT 40", None),
        ("Pháp Sư Cát", "Phép", "Hỏa", (26, 32), "**Lốc cát** (vung 1,0 s, vòng 7 m, ×1,0, làm chậm 40% trong 3 giây)", "INT 70 · LUK 30", None)],
  elites=[("Bọ Hung Giáp Vàng", "Giáp", "Kim", (23, 30), "**Lăn cầu** (hồi 9 s): lăn thẳng 20 m, ×1,8; giáp phía trước như Lính Đánh Thuê", "VIT 70 · STR 30"),
          ("Thủ Lĩnh Xác Ướp", "Lì", "Thổ", (27, 32), "**Hồi sinh** (hồi 20 s): dựng lại 2 Xác Ướp vừa bị hạ", "INT 50 · VIT 50")],
  boss=dict(name="Bọ Cạp Sa Hoàng", lv=30, ref=29, el="Thổ", arch="Boss",
   phases=[("1 (100% → 50%)", "**Kìm kẹp** (vung 0,6 s, ×1,3, giữ người chơi 1 giây) · **Đuôi độc** (vòng 8 m tại chỗ người chơi, vung 0,9 s, ×1,5 + độc 2% HP/giây 5 giây)"),
           ("2 (dưới 50%)", "**Chui xuống cát** (kịch bản): bất tử 3 giây, trồi lên dưới chân người chơi vòng 7 m, ×2,2 (vết cát báo 1,2 s) · **Bão cát** (kịch bản): tầm nhìn 40% suốt giai đoạn")],
   steal="**Độn Thổ**: chui đất 1,5 giây (bất tử), trồi lên vòng 7 m ×2,0", steal_code="⬜",
   drop="1 đồ Tím · 15% **Đuôi Sa Hoàng** (vũ khí Cam: đòn đánh gây độc ×0,2 mỗi giây trong 4 giây, cộng dồn 3 lần)"),
  rare=dict(name="Nhân Sư Đá", lv=32, el="Thổ", arch="Giáp", where="Di Tích Khai Giới Giả",
   skills="**Câu Đố Nhân Sư**: mỗi khi mất 25% HP, hiện 3 cột đá mang 3 hệ — đứng vào cột mang hệ **khắc Thổ** (Mộc) trong 4 giây, sai cột nhận ×3. **Ánh mắt hoá đá** (nón 45°, 14 m: hoá đá 1,5 giây)",
   drop="**Mắt Nhân Sư** (dây chuyền Cam: +10% chí mạng; chí mạng vào quái bị khắc hệ ×1,2) · 1 Tinh Hoa Tiến Hoá · 5 Thiên Phú Tinh Hoa")),

 dict(n=4, name="Đầm Lầy U Minh", lv=(32, 45), el="Thủy", unlock="Chuyển chức 1 (kịch bản)",
  next_req="Hạ Nữ Vương Phệ Mộng + **Thiên phú tiến hoá 1 lần** (kịch bản)",
  env=[("Độc tích luỹ", "Mỗi 10 giây trong nước đầm +1 tầng độc (tối đa 10; mỗi tầng mất 0,3% HP/giây). Đứng trên đất khô 3 giây giảm 1 tầng; Thuốc Giải xoá hết"),
       ("Ảo ảnh", "20% quái là ảo ảnh: trúng 1 đòn là tan, không cho EXP, không rơi đồ")],
  maps=[("4-1 Bãi Lau Mù", "32–36", "Lưới 15 ô"),
        ("4-2 Đầm Sâu", "36–41", "Lưới 15 ô; phần lớn là nước"),
        ("4-3 Cung Mộng", "41–45", "Lưới 15 ô; cốt truyện chương 4 (tiến hoá bắt buộc); boss hiếm Thuỷ Quái Thất Đầu"),
        ("Dungeon: Cung Phệ Mộng", "43", "Boss chương 4")],
  grid="45 ô", res="Bãi lau → Xưởng Gỗ; đầm → **Vườn Thảo Dược** (Thuốc Giải)",
  set=("Bộ U Minh", "2: độc tích luỹ chậm 50% · 4: +12% HP · 6: đòn đánh 15% gây 1 tầng độc lên quái", "⬜"),
  mobs=[("Ếch Độc", "Xa", "Thủy", (32, 38), "**Lưỡi độc** (vung 0,7 s, 12 m): kéo người chơi 4 m, +1 tầng độc", "AGI 50 · VIT 50", None),
        ("Đỉa Hút Máu", "Nhanh", "Thủy", (33, 40), "**Bám**: dính vào người chơi, hút 1% HP/giây và hồi cho nó; né lăn để gỡ", "VIT 60 · LUK 40", None),
        ("Hồn Ma Đầm", "Phép", "Thủy", (36, 45), "**Phân ảnh** (hồi 12 s): tạo 2 ảo ảnh 1 HP · **Tiếng than** (vòng 8 m, ×1,1)", "INT 70 · LUK 30", None),
        ("Cá Sấu Bùn", "Giáp", "Thổ", (38, 45), "**Đớp** (vung 0,8 s, ×1,8) + kéo xuống nước: choáng 1 giây", "STR 60 · VIT 40", None)],
  elites=[("Phù Thuỷ Đầm Lầy", "Phép", "Thủy", (36, 43), "**Mưa độc** (hồi 12 s): vùng 10 m trong 5 giây, +2 tầng độc mỗi giây", "INT 70 · VIT 30"),
          ("Cá Sấu Chúa", "Giáp", "Thổ", (40, 45), "**Cuộn tử thần** (hồi 14 s): giữ người chơi 2 giây, ×0,6 mỗi 0,5 s; né lăn đúng lúc vung để thoát", "STR 70 · VIT 30")],
  boss=dict(name="Nữ Vương Phệ Mộng", lv=43, ref=42, el="Thủy", arch="Boss",
   phases=[("1 (100% → 60%)", "**Lời ru** (sóng vòng 12 m, vung 1,0 s, ×1,0, chậm 50% trong 3 giây) · **Gai mộng** (3 gai thẳng, ×1,4)"),
           ("2 (60% → 25%)", "**Giấc mơ** (kịch bản): kéo người chơi vào giấc mơ 12 giây, **đảo ngược điều khiển** (trái ↔ phải, lên ↔ xuống); phá 3 Mộng Châu để thoát sớm"),
           ("3 (dưới 25%)", "**Phệ mộng**: hút 2% HP/giây với người chơi trong 15 m nếu không đứng trong vòng sáng (vòng sáng di chuyển chậm)")],
   steal="**Mộng Cảnh**: quái trong 10 m đánh nhau trong 4 giây", steal_code="⬜",
   drop="1 đồ Tím · 15% **Gối Mộng** (bùa Cam: 15% né hoàn toàn một đòn)"),
  rare=dict(name="Thuỷ Quái Thất Đầu", lv=45, el="Thủy", arch="Lì", where="Cung Mộng",
   skills="**7 đầu**, mỗi đầu thanh máu riêng (14% HP boss). Đầu bị chặt mọc lại sau 20 giây nếu không bị đòn **hệ Hỏa** trong 5 giây sau khi chặt (Thủy bị Hỏa khắc ngược — dùng ngọc/Ngũ Hành). Mỗi đầu: **Phun nước** (thẳng 15 m, ×1,2)",
   drop="**Vảy Thất Đầu** (áo Cam: hồi 1% HP/giây, +20% kháng Thủy) · 1 Tinh Hoa Tiến Hoá · 5 Thiên Phú Tinh Hoa")),

 dict(n=5, name="Núi Viêm Long", lv=(45, 60), el="Hỏa", unlock="Thiên phú tiến hoá 1 lần (kịch bản)",
  next_req="Hạ Viêm Long + **chuyển chức 2** (kịch bản)",
  env=[("Dung nham", "Ô dung nham: mất 5% HP/giây"),
       ("Núi lửa phun", "Mỗi 45 giây: 8 thiên thạch, mỗi viên có vòng báo 1,5 giây, trúng mất 25% HP"),
       ("Nhiệt", "Đứng trong 5 m quanh dung nham: +10% tốc đánh (thưởng cho người dám đứng gần)")],
  maps=[("5-1 Chân Núi Tro", "45–50", "Lưới 15 ô"),
        ("5-2 Sườn Dung Nham", "50–55", "Lưới 15 ô"),
        ("5-3 Miệng Núi Lửa", "55–60", "Lưới 15 ô; boss hiếm Phượng Hoàng Tro"),
        ("Dungeon: Long Huyệt", "58", "Boss chương 5")],
  grid="45 ô", res="Mỏ sắt, **Mỏ Tinh Thạch**",
  set=("Bộ Hoả Ngục", "2: +30% kháng Hỏa · 4: +10% Tấn công · 6: Xoáy Kiếm để lại vòng lửa 5 giây, ×0,3 mỗi giây", "⬜"),
  mobs=[("Thằn Lằn Lửa", "Nhanh", "Hỏa", (45, 52), "Chạy để lại vệt lửa 3 giây (×0,2 mỗi giây). **Cắn** ×1,0", "AGI 60 · STR 40", None),
        ("Người Đá Dung Nham", "Giáp", "Thổ", (47, 56), "**Đấm** (×1,3). Khi bị hạ vỡ thành 3 mảnh đá nhỏ (loại Bầy)", "VIT 60 · STR 40", None),
        ("Linh Hồn Lửa", "Tự nổ", "Hỏa", (48, 58), "Lao tới người chơi, **tự nổ** sau vung 0,8 s, vòng 5 m", "INT 50 · LUK 50", None),
        ("Pháp Sư Hoả Diệm", "Phép", "Hỏa", (52, 60), "**Cột lửa** (vung 1,0 s: 3 cột nối tiếp về phía người chơi, mỗi cột ×1,2)", "INT 70 · LUK 30", None)],
  elites=[("Rồng Non Lửa", "Nhanh", "Hỏa", (50, 58), "**Phun lửa** (hồi 10 s): nón 60°, 12 m, ×0,5 mỗi 0,2 s trong 2 giây", "STR 50 · INT 50"),
          ("Thợ Rèn Hư Vô", "Giáp", "Kim", (54, 60), "**Búa rèn** (hồi 12 s): đập vòng 6 m ×2,0; quái trong 10 m +20% Tấn công 8 giây", "STR 70 · VIT 30")],
  boss=dict(name="Viêm Long", lv=58, ref=57, el="Hỏa", arch="Boss",
   phases=[("1 (100% → 60%)", "**Vuốt** (×1,5) · **Long tức** (nón 70°, 18 m, ×0,6 mỗi 0,25 s trong 2,5 giây)"),
           ("2 (60% → 20%)", "Bay lên. **Dung nham dâng theo lượt** (kịch bản): mỗi 20 giây nền ngập dung nham 6 giây, chỉ 5 đá nổi an toàn; mưa thiên thạch như môi trường"),
           ("3 (dưới 20%)", "Rơi xuống, **Cuồng nộ**: +30% tốc đánh, Long tức mỗi 8 giây")],
   steal="**Long Tức**: phun lửa nón 12 m, ×0,5 mỗi 0,25 s trong 2 giây", steal_code="⬜",
   drop="1 đồ Tím · 15% **Long Tâm** (nhẫn Cam: +20% sát thương hệ Hỏa; miễn dung nham 2 giây sau khi né)"),
  rare=dict(name="Phượng Hoàng Tro", lv=60, el="Hỏa", arch="Phép", where="Miệng Núi Lửa",
   skills="**Niết bàn**: lần đầu bị hạ hồi sinh 50% HP, **trừ khi** trúng đòn hệ Thủy trong 5 giây cuối · **Mưa lông lửa** (12 vòng 3 m ngẫu nhiên, ×1,0)",
   drop="**Lông Phượng** (bùa Cam: mỗi 5 phút, lần đầu bị hạ thì hồi sinh 30% HP) · 1 Tinh Hoa Tiến Hoá · 5 Thiên Phú Tinh Hoa")),

 dict(n=6, name="Băng Nguyên Bắc Cực", lv=(60, 72), el="Thủy + Kim", unlock="Chuyển chức 2 (kịch bản)",
  next_req="Hạ Bản Ngã Bóng Tối + **lãnh địa cấp 5, xây Cảng Khí Cầu** (kịch bản)",
  env=[("Băng giá", "Đứng yên quá 2 giây: +1 tầng (−10% tốc chạy mỗi tầng); 5 tầng → đông cứng 1,5 giây. Di chuyển hoặc đứng cạnh lửa trại để giảm"),
       ("Đêm dài", "Chu kỳ 8 phút, 6 phút đêm: tầm nhìn 60%"),
       ("Mặt băng trơn", "Dừng lại vẫn trượt thêm 0,3 giây")],
  maps=[("6-1 Đồng Tuyết", "60–64", "Lưới 15 ô"),
        ("6-2 Rừng Băng", "64–68", "Lưới 15 ô"),
        ("6-3 Đỉnh Cực Quang", "68–72", "Lưới 15 ô; cốt truyện chương 6 (mảnh Thiên phú thứ hai thức giấc); boss hiếm Long Băng"),
        ("Dungeon: Gương Băng Vĩnh Dạ", "70", "Boss chương 6")],
  grid="45 ô", res="Mỏ Tinh Thạch, rừng thông → Xưởng Gỗ",
  set=("Bộ Cực Quang", "2: miễn băng giá dưới 3 tầng · 4: +10% chí mạng · 6: đòn chí mạng làm chậm quái 30%", "⬜"),
  mobs=[("Sói Băng", "Bầy", "Thủy", (60, 66), "Đi bầy 4 con. **Cắn** ×1,0 + 1 tầng băng giá", "AGI 60 · STR 40", None),
        ("Người Tuyết", "Lì", "Thủy", (61, 68), "**Ném cầu tuyết** (vung 0,9 s, ×1,3, vòng 3 m)", "VIT 60 · STR 40", None),
        ("Tinh Linh Băng", "Phép", "Thủy", (63, 72), "**Băng trụ** (vung 1,0 s, vòng 4 m, ×1,1, đóng băng 1 giây)", "INT 70 · LUK 30", None),
        ("Cung Thủ Băng", "Xa", "Kim", (65, 72), "**Mũi tên xuyên** (xuyên mọi mục tiêu trên đường, ×1,0)", "AGI 70 · LUK 30", None)],
  elites=[("Gấu Băng Khổng Lồ", "Lì", "Thủy", (63, 70), "**Đập băng** (hồi 10 s): nứt nền 3 đường thẳng 15 m, mỗi đường ×1,8", "STR 60 · VIT 40"),
          ("Pháp Sư Bão Tuyết", "Phép", "Kim", (66, 72), "**Bão tuyết** (hồi 15 s): vùng 14 m trong 6 giây, +1 tầng băng giá mỗi giây", "INT 70 · VIT 30")],
  boss=dict(name="Bản Ngã Bóng Tối", lv=70, ref=69, el="theo hệ người chơi", arch="Boss",
   phases=[("1 (100% → 50%)", "**Sao chép Thiên phú và kỹ năng của chính người chơi** (kịch bản): dùng lại kỹ năng người chơi vừa dùng 3 giây trước, với 80% chỉ số của người chơi"),
           ("2 (50% → 20%)", "**Gương vỡ**: 4 tấm gương, boss ẩn trong 1 tấm (tấm có bóng tối). Đánh nhầm gương: gương phản 50% sát thương"),
           ("3 (dưới 20%)", "Dùng Thiên phú của người chơi ở **dạng tiến hoá cao nhất** của Thiên phú đó")],
   steal="**Kính Ảnh**: tạo 1 bản sao của bản thân 8 giây, gây 50% sát thương", steal_code="⬜",
   drop="1 đồ Tím · 15% **Gương Bản Ngã** (bùa Cam: 10% phản 50% sát thương nhận)"),
  rare=dict(name="Long Băng Bắc Cực", lv=72, el="Thủy", arch="Lì", where="Đỉnh Cực Quang",
   skills="**Hơi thở vĩnh đông** (nón 90°, 20 m: đóng băng nền 3 giây, ai đứng trên bị +2 tầng băng giá mỗi giây) · **Mưa băng** (15 vòng 3 m, ×1,2)",
   drop="**Vảy Long Băng** (giày Cam: miễn băng giá, +15% tốc chạy) · 1 Tinh Hoa Tiến Hoá · 5 Thiên Phú Tinh Hoa")),

 dict(n=7, name="Quần Đảo Thiên Không", lv=(72, 84), el="Kim + Mộc", unlock="Lãnh địa cấp 5, xây Cảng Khí Cầu (kịch bản)",
  next_req="Hạ Thiên Không Cự Thần + **Thiên phú tiến hoá 2 lần** (kịch bản)",
  env=[("Đảo bay", "Rơi khỏi mép đảo: về điểm lưu gần nhất, mất 10% HP (kịch bản)"),
       ("Cầu gió", "Cầu nối giữa các đảo tắt 5 giây sau mỗi 30 giây"),
       ("Đảo vỡ", "Ở Thiên Cung Đổ Nát, mép đảo sụp 1 m mỗi 10 giây")],
  maps=[("7-1 Đảo Mây Trôi", "72–76", "Lưới 15 ô"),
        ("7-2 Đảo Rừng Treo", "76–80", "Lưới 15 ô"),
        ("7-3 Thiên Cung Đổ Nát", "80–84", "Lưới 15 ô; cốt truyện chương 7 (Bia Đá gốc, tiến hoá bắt buộc); boss hiếm Kỳ Lân Mây"),
        ("Dungeon: Đài Cự Thần", "82", "Boss chương 7")],
  grid="45 ô", res="Rừng treo → Xưởng Gỗ, **Mỏ Tinh Thạch**",
  set=("Bộ Thiên Phong", "2: không bị đẩy lùi · 4: +10% tốc đánh · 6: rơi khỏi mép không mất HP (1 lần/phút)", "⬜"),
  mobs=[("Đại Bàng Mây", "Nhanh", "Kim", (72, 78), "**Quạt cánh** (vung 0,6 s): đẩy lùi 5 m (thường về phía mép đảo)", "AGI 70 · LUK 30", None),
        ("Người Gỗ Đảo Bay", "Giáp", "Mộc", (73, 80), "**Rễ quật** (vòng 5 m, ×1,3)", "VIT 60 · STR 40", None),
        ("Tiên Gió", "Phép", "Mộc", (75, 84), "**Hồi phục**: hồi 5% HP cho đồng bọn trong 10 m mỗi 2 giây — nên hạ trước", "INT 60 · LUK 40", None),
        ("Hiệp Sĩ Thiên Không", "Lì", "Kim", (78, 84), "**Thương phá** (vung 0,8 s, đâm xuyên 15 m, ×1,6)", "STR 60 · VIT 40", None)],
  elites=[("Thủ Hộ Đảo", "Giáp", "Kim", (75, 82), "**Khiên trời** (hồi 18 s): đồng bọn trong 10 m bất tử 4 giây", "VIT 70 · INT 30"),
          ("Rồng Mây", "Nhanh", "Mộc", (78, 84), "Bay vòng quanh; **Lao mây** (hồi 8 s, ×2,0)", "AGI 60 · STR 40")],
  boss=dict(name="Thiên Không Cự Thần", lv=82, ref=81, el="Kim", arch="Boss",
   phases=[("1 (100% → 60%)", "**Đấm đất** (vòng 8 m, ×2,0, ô nền đó vỡ 10 giây) · **Mưa đá** (10 vòng 3 m, ×1,0)"),
           ("2 (60% → 20%)", "**Đảo bay vỡ dần, chiến trường thu nhỏ** (kịch bản): mỗi 15 giây mất 1 vòng mép; rơi khỏi mép → về điểm lưu, boss hồi 5% HP"),
           ("3 (dưới 20%)", "**Thiên chuỳ**: nện 3 lần liên tiếp vòng 12 m, mỗi lần ×3,0 (vung 1,2 s mỗi lần)")],
   steal="**Thiên Chuỳ**: nện đất vòng 10 m ×3,0, choáng 1 giây", steal_code="⬜",
   drop="1 đồ Tím · 15% **Búa Cự Thần** (vũ khí Cam: đòn thứ 3 tạo sóng chấn vòng 6 m ×0,8)"),
  rare=dict(name="Kỳ Lân Mây", lv=84, el="Mộc", arch="Nhanh", where="Thiên Cung Đổ Nát",
   skills="Chạy vòng quanh đảo, để lại vệt sấm (×0,4 mỗi giây). **Chỉ đánh được khi nó dừng 3 giây** giữa các vòng · **Sấm sét** (5 vòng 4 m, ×1,5)",
   drop="**Sừng Kỳ Lân** (dây chuyền Cam: +20% hiệu lực hồi máu; mỗi 10 giây hồi 5% HP) · 1 Tinh Hoa Tiến Hoá · 5 Thiên Phú Tinh Hoa")),

 dict(n=8, name="Vực Hư Vô", lv=(84, 95), el="Hư Vô (không hệ)", unlock="Thiên phú tiến hoá 2 lần (kịch bản)",
  next_req="Hạ Giáo Chủ Hư Vô + **chuyển chức 3** (kịch bản)",
  env=[("Thiên phú yếu dần", "Mỗi 60 giây ở trong vực, hiệu lực Thiên phú −10% (tối đa −50%) (kịch bản). Đứng cạnh **Đèn Tinh Quang** 5 giây để hồi lại"),
       ("Không hệ", "Quái không có hệ: khắc hệ không có tác dụng, cả với người chơi lẫn quái")],
  maps=[("8-1 Rìa Vực", "84–88", "Lưới 15 ô"),
        ("8-2 Đáy Vực", "88–92", "Lưới 15 ô; Đèn Tinh Quang thưa dần"),
        ("8-3 Sào Huyệt Hư Vô", "92–95", "Lưới 15 ô; cốt truyện chương 8; boss hiếm Hư Vô Thú"),
        ("Dungeon: Điện Giáo Chủ", "93", "Boss chương 8")],
  grid="45 ô", res="Không có tài nguyên thường; khai phá cho **Tinh Thạch** ×3; boss rơi **Lõi Hư Vô** (vật phẩm cốt truyện, nâng Hoàng Thành — không phải tiền tệ, Q26)",
  set=("Bộ Tinh Quang", "2: Thiên phú yếu dần chậm 50% · 4: +12% HP · 6: mỗi 60 giây miễn 1 lần bị vô hiệu Thiên phú", "⬜"),
  mobs=[("Bóng Hư Vô", "Nhanh", "Hư Vô", (84, 90), "Tàng hình khi đứng yên; **Đâm lén** từ sau lưng ×1,8", "AGI 70 · LUK 30", None),
        ("Kẻ Nuốt Thiên Phú", "Phép", "Hư Vô", (85, 92), "Đòn trúng xoá 1 hiệu ứng có lợi và làm Thiên phú yếu thêm 5%", "INT 70 · LUK 30", None),
        ("Giáp Sĩ Hư Vô", "Giáp", "Hư Vô", (87, 95), "**Chém nặng** (vung 1,0 s, ×1,6)", "STR 50 · VIT 50", None),
        ("Mắt Hư Vô", "Xa", "Hư Vô", (89, 95), "**Tia nhìn**: chiếu liên tục ×0,3 mỗi 0,2 s; nấp sau vật cản để tránh", "INT 60 · AGI 40", None)],
  elites=[("Tư Tế Hư Vô", "Phép", "Hư Vô", (88, 94), "**Tế lễ** (hồi 15 s): hiến 1 quái gần đó để hồi 30% HP và +30% Tấn công cho đồng bọn trong 12 m", "INT 70 · VIT 30"),
          ("Quái Vật Không Mặt", "Lì", "Hư Vô", (90, 95), "**Vô diện**: miễn nhiễm sát thương từ phía trước, chỉ đánh được sau lưng", "VIT 60 · STR 40")],
  boss=dict(name="Giáo Chủ Hư Vô", lv=93, ref=92, el="Hư Vô", arch="Boss",
   phases=[("1 (100% → 60%)", "**Phong ấn hư vô** (vòng 10 m tại chỗ người chơi, vung 1,0 s, ×1,8) · **Tia hư vô** (thẳng 25 m, ×1,2)"),
           ("2 (60% → 25%)", "**Hút Thiên phú** (kịch bản): vô hiệu hoá Thiên phú người chơi 10 giây, mỗi 30 giây"),
           ("3 (dưới 25%)", "Gọi 4 Tư Tế Hư Vô; mỗi lần Tư Tế tế lễ, boss +10% Tấn công")],
   steal="**Hút Thiên Phú**: quái trong 12 m mất mọi tăng cường 6 giây, hút 10% HP của chúng", steal_code="⬜",
   drop="1 đồ Tím · 15% **Ấn Hư Vô** (nhẫn Cam: miễn hiệu ứng Thiên phú yếu dần)"),
  rare=dict(name="Hư Vô Thú", lv=95, el="Hư Vô", arch="Lì", where="Sào Huyệt Hư Vô",
   skills="**Nuốt ánh sáng**: mỗi 20 giây tắt 1 Đèn Tinh Quang trong trận (4 đèn) · **Hàm hư vô** (nón 60°, 10 m, ×2,0)",
   drop="**Nanh Hư Vô** (vũ khí Cam: bỏ qua 30% Phòng thủ của quái) · 1 Tinh Hoa Tiến Hoá · 5 Thiên Phú Tinh Hoa")),

 dict(n=9, name="Cổng Thiên Đạo", lv=(95, 100), el="Tất cả (theo tầng)", unlock="Chuyển chức 3 (kịch bản)",
  next_req="Hạ Ma Tôn Vô Diện → chọn 1 trong 2 kết thúc, mở endgame",
  env=[("Mỗi tầng một hệ", "9 tầng; khi vào tầng, hệ của tầng chọn ngẫu nhiên (kịch bản). Mọi quái trong tầng mang hệ đó"),
       ("Ấn Hệ", "Mỗi tầng có 1 Ấn Hệ: nhặt được thì đòn đánh tạm mang hệ khắc của tầng trong 60 giây")],
  maps=[("9-1 Tầng 1–3", "95–97", "Mỗi tầng 5 ô khai phá"),
        ("9-2 Tầng 4–6", "97–99", "Mỗi tầng 5 ô khai phá"),
        ("9-3 Tầng 7–9", "99–100", "Mỗi tầng 5 ô khai phá"),
        ("Dungeon: Thiên Đạo Chi Môn", "100", "Boss chương 9")],
  grid="45 ô (9 tầng × 5)", res="Không có; phần thưởng là Tinh Hoa Tiến Hoá",
  set=("Bộ Thiên Đạo", "2: +5% mọi chỉ số · 4: khắc hệ +20% · 6: kỹ năng L hồi nhanh 30%", "⬜"),
  mobs=[("Thiên Binh Ngũ Hành", "Giáp", "theo tầng", (95, 100), "**Kích ngũ hành** (×1,4, hệ của tầng)", "STR 50 · VIT 50", None),
        ("Tàn Hồn Khai Giới Giả", "Phép", "theo tầng", (95, 100), "Mang 1 Thiên phú ngẫu nhiên trong 20 và dùng kỹ năng L của Thiên phú đó", "INT 50 · LUK 50", None),
        ("Thiên Mã", "Nhanh", "theo tầng", (96, 100), "**Phi nước đại** (lao 20 m, ×1,5)", "AGI 70 · VIT 30", None),
        ("Ngũ Hành Linh Thú", "Lì", "theo tầng", (97, 100), "**Gầm ngũ hành** (vòng 8 m, ×1,2, đổi hệ người chơi... không: làm người chơi mất khắc hệ 5 giây)", "VIT 50 · STR 50", None)],
  elites=[("Thiên Tướng", "Giáp", "theo tầng", (96, 100), "**Thiên phạt** (hồi 12 s): 5 cột sét vòng 4 m, mỗi cột ×1,6", "STR 60 · VIT 40"),
          ("Ngũ Hành Sứ Giả", "Phép", "đổi mỗi 8 s", (97, 100), "Đổi hệ mỗi 8 giây; chỉ nhận sát thương từ hệ khắc hệ hiện tại", "INT 60 · LUK 40")],
  boss=dict(name="Ma Tôn Vô Diện", lv=100, ref=99, el="đổi mỗi 10 s", arch="Boss",
   phases=[("1 (100% → 66%)", "Dùng kỹ năng của boss chương 1–3: Vồ, Phân thân, Chui xuống cát"),
           ("2 (66% → 33%)", "Kỹ năng boss chương 4–6: Giấc mơ (đảo điều khiển), Dung nham dâng, Sao chép Thiên phú người chơi"),
           ("3 (dưới 33%)", "Kỹ năng boss chương 7–8: Chiến trường thu nhỏ, Hút Thiên phú; thêm **Vô Diện** — đổi hệ mỗi 10 giây (kịch bản: \"3 giai đoạn, dùng Thiên phú của mọi boss trước đó\")")],
   steal="**Vô Diện**: dùng ngẫu nhiên 1 kỹ năng boss đã sao chép với ×1,5 sát thương", steal_code="⬜",
   drop="2 đồ Tím · 100% lần đầu **Mặt Nạ Vô Diện** (mũ Cam: mỗi 30 giây đòn đánh đổi sang hệ khắc mục tiêu)"),
  rare=dict(name="Thiên Đạo Hư Ảnh", lv=100, el="Tất cả", arch="Phép", where="Endgame (sau khi hạ Ma Tôn)",
   skills="Dùng ngẫu nhiên 3 Thiên phú hạng S trở lên trong 20, đổi mỗi giai đoạn (3 giai đoạn)",
   drop="3 Tinh Hoa Tiến Hoá · 10 Thiên Phú Tinh Hoa · đồ Cam ngẫu nhiên của mọi vùng")),
]

# sửa lỗi văn bản tạm trong dữ liệu
REGIONS[8]["mobs"][3] = ("Ngũ Hành Linh Thú", "Lì", "theo tầng", (97, 100), "**Gầm ngũ hành** (vòng 8 m, ×1,2): người chơi mất thưởng khắc hệ 5 giây", "VIT 50 · STR 50", None)

CODE_R1 = {  # chỉ số đang dùng trong code (godot/scripts/data/monsters.gd + game_world.spawn_enemy)
    "wolf": (40, 8, 3), "mushroom": (55, 7, 4), "wisp": (70, 12, 6), "boss": (3600, 27, 12),
}

def code_stats(key, L):
    hp, atk, d = CODE_R1[key]
    if key == "boss":
        return hp, atk, d
    return round(hp * (1 + 0.35 * (L - 1))), round(atk * (1 + 0.25 * (L - 1))), d + L


# ---------------------------------------------------------------- xuất markdown
o = []
w = o.append
w("""# Thiết kế bản đồ, quái vật, boss

| | |
| --- | --- |
| Dự án | Thiên Phú Khai Giới |
| Nguồn | [Kịch bản](kich-ban-game-thien-phu-khai-gioi.md) mục 2, 5, 6, 7 |
| Trạng thái | **Đã chốt thiết kế** 20/10/2026 — Q22–Q27 chốt theo phương án ở mục 7. Đã code: vùng 1 (một phần) — **chỉ số quái trong game tính bằng công thức mục 1 từ M3** (`Formulas.mob_stats`) |
| Cập nhật | 20/10/2026 |
| Cách tạo | Các bảng chỉ số được **sinh bằng script** `tools/gen_world_doc.py` từ công thức ở mục 1. Đổi công thức hoặc thêm quái: sửa script rồi chạy `python tools/gen_world_doc.py docs/06-ban-do-quai-boss.md`, không sửa tay từng số |

Quy ước: 1 m = 10 đơn vị trong game. Tốc chạy tính bằng đơn vị/giây (người chơi: 230). "×1,5" = 1,5 lần Tấn công của quái đó. Chỉ số quái ghi ở **cấp thấp nhất → cấp cao nhất** nơi nó xuất hiện.

## 1. Công thức chỉ số

### 1.1. Người chơi chuẩn

Mọi chỉ số quái được tính để cân với **người chơi chuẩn** ở cùng cấp: Kiếm Khách, cộng điểm 60% STR / 40% VIT, mặc đồ đúng vùng cường hoá trung bình.

| Chỉ số | Công thức (L = cấp) | Cấp 1 | Cấp 10 | Cấp 30 | Cấp 60 | Cấp 100 |
| --- | --- | --- | --- | --- | --- | --- |""")
for key, label, f in [("atk", "Tấn công", "10 + 13·(L−1)"), ("hp", "HP", "100 + 50·(L−1)"), ("def", "Phòng thủ", "5 + 3,5·(L−1)")]:
    vals = " | ".join(f"{round(player(L)[key]):,}".replace(",", ".") for L in (1, 10, 30, 60, 100))
    w(f"| {label} | {f} | {vals} |")

w("""
Đối chiếu: nhân vật cấp 5 trong test M1 (cộng điểm, mặc 2–3 món) có Tấn công khoảng 55–62; công thức cho 62.

### 1.2. Quái

Sát thương dùng công thức kịch bản mục 5: `DMG = ATK × hệ số × ATK / (ATK + DEF)`.

| Thành phần | Công thức |
| --- | --- |
| Phòng thủ quái | `(3 + 1,5·L) × hệ số bậc × hệ số loại` |
| HP quái | `số đòn mục tiêu × sát thương 1 đòn của người chơi chuẩn × hệ số loại` |
| Tấn công quái | Chọn sao cho 1 đòn thường của quái lấy đúng `% HP mục tiêu` của người chơi chuẩn, rồi × hệ số loại |
| EXP | Quái thường `30·L^1,5` (đã code); tinh anh ×3 (đã code); boss vùng `0,3 × EXP lên cấp L`; boss hiếm `0,5 × EXP lên cấp L` |
| Vàng | Quái thường `3·L`, tinh anh `12·L` (đã code); boss vùng `50·L`; boss hiếm `80·L` |
| Phá Thế | Boss: 1/6 HP (Sói Chúa đang dùng 600/3600); tinh anh: 30% HP (CB-07, M3) |

**Theo bậc quái:**

| Bậc | Số đòn để hạ (người chơi chuẩn, đòn thường) | 1 đòn của quái lấy | Hệ số phòng thủ |
| --- | --- | --- | --- |""")
for k, label in [("thuong", "Quái thường"), ("tinhanh", "Quái tinh anh"), ("boss", "Boss vùng"), ("hiem", "Boss hiếm")]:
    H, h, dm = TIERS[k]
    if k == "boss":
        H = f"{boss_hits(1)} (chương 1) · {boss_hits(2)} (chương 2–3) · {boss_hits(4)} (chương 4+)"
    w(f"| {label} | {H} | {round(h*100)}% HP | ×{str(dm).replace('.', ',')} |")
w("""
Boss vùng tính với người chơi **thấp hơn boss 1 cấp** (cấp khuyến nghị khi vào hang). 90 đòn ≈ 35–40 giây, 130 đòn ≈ 45–60 giây có né đòn (Q23). Boss hiếm: loại quái chỉ đổi Tấn công/Phòng thủ, HP không nhân theo loại.

**Theo loại quái:**

| Loại | HP | Tấn công | Phòng thủ | Tốc chạy | Tầm đánh | Vai trò |
| --- | --- | --- | --- | --- | --- | --- |""")
roles = {"Nhanh": "Áp sát nhanh, máu mỏng", "Bầy": "Đi đông, yếu từng con", "Lì": "Máu dày, chậm", "Giáp": "Phòng thủ cao, chậm nhất",
         "Xa": "Bắn từ xa, đứng yên", "Phép": "Sát thương cao, kỹ năng vùng", "Tự nổ": "Lao tới nổ một lần", "Boss": "—"}
for a, (mh, ma, md, spd, r) in ARCH.items():
    if a == "Boss":
        continue
    f = lambda x: f"×{x}".replace(".", ",")
    w(f"| {a} | {f(mh)} | {f(ma)} | {f(md)} | {spd} | {str(r).replace('.', ',')} m | {roles[a]} |")

w("""
### 1.3. So với chỉ số của prototype (trước M3)

Trước M3, code dùng công thức cũ của prototype (`HP × (1 + 0,35·(L−1))`, `ATK × (1 + 0,25·(L−1))`). Công thức mới **làm quái cứng hơn ở cấp 5 trở lên** — khớp với phát hiện F2 (người chơi lên cấp quá nhanh). **Đã áp dụng ở M3** (Q22): `godot/scripts/core/formulas.gd` `mob_stats()` tính giống hệt script này; test CB-T1 so khớp bảng dưới. M5 chỉ tinh chỉnh hệ số từ dữ liệu playtest. Cột trái là số cũ để so sánh.

| Quái | Cấp | Code hiện tại (HP / ATK / DEF) | Thiết kế mới (HP / ATK / DEF) |
| --- | --- | --- | --- |""")
r1 = REGIONS[0]
for (name, arch, el, (a, b), skill, steal, key) in r1["mobs"]:
    if not key:
        continue
    for L in (a, b):
        c = code_stats(key, L)
        s = stats(L, "thuong", arch)
        w(f"| {name} | {L} | {c[0]} / {c[1]} / {c[2]} | {s['hp']} / {s['atk']} / {s['def']} |")
bs = r1["boss"]
c = code_stats("boss", bs["lv"])
s = stats(bs["lv"], "boss", "Boss", bs["ref"], boss_hits(1))
w(f"| {bs['name']} | {bs['lv']} | {c[0]} / {c[1]} / {c[2]} | {s['hp']} / {s['atk']} / {s['def']} |")

# ---------------------------------------------------------------- tổng quan vùng
w("""
## 2. Tổng quan 9 vùng

| # | Vùng | Cấp | Hệ chủ đạo | Mở khoá (kịch bản) | Boss chương | Boss hiếm | Trạng thái |
| --- | --- | --- | --- | --- | --- | --- | --- |""")
for R in REGIONS:
    st = "✅ C1" if R["n"] == 1 else ("✅ M4–M5" if R["n"] == 2 else ("⬜ Alpha" if R["n"] <= 5 else "⬜ Beta"))
    w(f"| {R['n']} | {R['name']} | {R['lv'][0]}–{R['lv'][1]} | {R['el']} | {R['unlock']} | {R['boss']['name']} (cấp {R['boss']['lv']}) | {R['rare']['name']} (cấp {R['rare']['lv']}) | {st} |")

w("""
Mỗi vùng gồm 3 map con (Ngoài rìa → Trung tâm → Lõi) và 1 dungeon boss (kịch bản mục 6). Lưới khai phá 15 ô mỗi map con, tổng khoảng 45 ô mỗi vùng (kịch bản: 40–60). Vùng 1 giữ lưới 10 ô hiện có cho map đầu.

## 3. Chi tiết từng vùng
""")

def mob_row(name, arch, el, lv, skill, steal, tier):
    a, b = lv
    s1, s2 = stats(a, tier, arch), stats(b, tier, arch)
    exp1 = mob_exp(a) * (3 if tier == "tinhanh" else 1)
    exp2 = mob_exp(b) * (3 if tier == "tinhanh" else 1)
    return (f"| {name} | {arch} | {el} | {a}–{b} | {fmt_range(s1['hp'], s2['hp'])} | {fmt_range(s1['atk'], s2['atk'])} | "
            f"{fmt_range(s1['def'], s2['def'])} | {s1['spd']} · {str(s1['rng']).replace('.', ',')} m | {fmt_range(exp1, exp2)} | {skill} | {steal} |")

for R in REGIONS:
    w(f"### Vùng {R['n']} — {R['name']} (cấp {R['lv'][0]}–{R['lv'][1]}, hệ {R['el']})\n")
    w(f"**Mở khoá:** {R['unlock']}. **Sang vùng tiếp theo:** {R['next_req']}.\n")
    w("**Môi trường**\n\n| Cơ chế | Chi tiết |\n| --- | --- |")
    for n_, d in R["env"]:
        w(f"| {n_} | {d} |")
    w("\n**Map con**\n\n| Map | Cấp | Nội dung |\n| --- | --- | --- |")
    for m in R["maps"]:
        w(f"| {m[0]} | {m[1]} | {m[2]} |")
    w(f"\n**Khai phá:** lưới {R['grid']}. Tài nguyên: {R['res']}.  ")
    sname, sbonus, sst = R["set"]
    w(f"**Bộ trang bị vùng:** {sname} — {sbonus}. {sst}\n")
    w("**Quái thường**\n\n| Quái | Loại | Hệ | Cấp | HP | Tấn công | Phòng thủ | Tốc · Tầm | EXP | Kỹ năng | Đạo Tặc cướp |\n| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |")
    for (name, arch, el, lv, skill, steal, key) in R["mobs"]:
        w(mob_row(name + (" ✅" if key else ""), arch, el, lv, skill, steal, "thuong"))
    w("\n**Quái tinh anh** (viền sáng, có 1 kỹ năng riêng; luôn rơi đồ Xanh dương/Tím; 30% Đạo Tặc cướp)\n\n| Quái | Loại | Hệ | Cấp | HP | Tấn công | Phòng thủ | Tốc · Tầm | EXP | Kỹ năng | Đạo Tặc cướp |\n| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |")
    for (name, arch, el, lv, skill, steal) in R["elites"]:
        w(mob_row(name, arch, el, lv, skill, steal, "tinhanh"))
    B = R["boss"]
    s = stats(B["lv"], "boss", "Boss", B["ref"], boss_hits(R["n"]))
    poise = round(s["hp"] / 6)
    bexp = round(0.3 * exp_to_next(B["lv"]))
    code_note = " — **đã có trong game** (chỉ số theo công thức mục 1 từ M3)" if R["n"] == 1 else ""
    w(f"\n**Boss chương {R['n']}: {B['name']}**{code_note}\n")
    w(f"| Cấp | Hệ | HP | Tấn công | Phòng thủ | Phá Thế | Cấp khuyến nghị | EXP | Vàng |\n| --- | --- | --- | --- | --- | --- | --- | --- | --- |")
    w(f"| {B['lv']} | {B['el']} | {s['hp']:,} | {s['atk']} | {s['def']} | {poise:,} | {B['ref']} | {bexp:,} | {50*B['lv']:,} |".replace(",", "."))
    w("\n| Giai đoạn | Kỹ năng |\n| --- | --- |")
    for ph, sk in B["phases"]:
        w(f"| {ph} | {sk} |")
    w(f"\n- **Rơi:** {B['drop']} · 3 Thiên Phú Tinh Hoa · 1 Tinh Kim.")
    w(f"- **Đạo Tặc sao chép:** {B['steal']} ({B['steal_code']}).\n")
    Rr = R["rare"]
    s = stats(Rr["lv"], "hiem", Rr["arch"])
    rexp = round(0.5 * exp_to_next(Rr["lv"]))
    w(f"**Boss hiếm: {Rr['name']}** — xuất hiện ngẫu nhiên 2 lần/ngày ở {Rr['where']} (kịch bản mục 5)\n")
    w(f"| Cấp | Hệ | Loại | HP | Tấn công | Phòng thủ | EXP | Vàng |\n| --- | --- | --- | --- | --- | --- | --- | --- |")
    w(f"| {Rr['lv']} | {Rr['el']} | {Rr['arch']} | {s['hp']:,} | {s['atk']} | {s['def']} | {rexp:,} | {80*Rr['lv']:,} |".replace(",", "."))
    w(f"\n- **Kỹ năng:** {Rr['skills']}")
    w(f"- **Rơi:** {Rr['drop']}\n")

# ---------------------------------------------------------------- tổng hợp kỹ năng Đạo Tặc
w("""## 4. Đồ Cam theo vùng

| Vùng | Từ boss chương (15%) | Từ boss hiếm |
| --- | --- | --- |""")
import re
def unique(text):
    m = re.search(r"\*\*([^*]+)\*\* \(([^)]+)\)", text)
    return f"{m.group(1)} — {m.group(2)}" if m else text
for R in REGIONS:
    w(f"| {R['n']}. {R['name']} | {unique(R['boss']['drop'])} | {unique(R['rare']['drop'])} |")

w("""
## 5. Kỹ năng Đạo Tặc sao chép từ boss

Dùng bằng phím L (Thiên phú Đạo Tặc, [05-thien-phu-chi-tiet](05-thien-phu-chi-tiet.md)). Học được khi hạ boss lần đầu; chọn kỹ năng đang dùng trong bảng Thiên phú.

| Boss | Kỹ năng sao chép | Code |
| --- | --- | --- |""")
for R in REGIONS:
    w(f"| {R['boss']['name']} (chương {R['n']}) | {R['boss']['steal']} | {R['boss']['steal_code']} |")

w("""
## 6. Kế hoạch làm

| Đợt | Nội dung |
| --- | --- |
| M3 | ✅ Xong 20/10/2026 — **Áp công thức chỉ số mới cho vùng 1 (Q22)**: quái lấy chỉ số từ công thức trong code thay cho bảng số cứng · boss chương 1 = 90 đòn (Q23) · Thanh Phá Thế + kỹ năng riêng cho quái tinh anh vùng 1 (Sói Đầu Đàn, Nấm Mẹ) · thêm Mộc Tinh |
| M4 | Vùng 1 đủ 3 map con, 40 ô (Bìa Rừng, Rừng Sâu, Lõi Sương mở sau boss — Q24, Q25) · toàn bộ vùng 2, 45 ô · Mỏ (Đá, Sắt), Bến Cá dạng buff (Q26) · bộ Phong Hành · Mặt Nạ Huyền Ảnh |
| M5 | Boss hiếm vùng 1–2 (Lão Thụ, Bạch Hổ) · tinh chỉnh hệ số công thức (số đòn, % HP) từ dữ liệu playtest |
| Alpha | Vùng 3–5 |
| Beta | Vùng 6–9 |

## 7. Quyết định đã chốt (20/10/2026)

Chủ dự án uỷ quyền chọn phương án tốt nhất, hợp thị trường. Căn cứ chung: ARPG/idle hiện nay (Diablo Immortal, Vampire Survivors, Solo Leveling: Arise, các game nhập vai mobile ở Việt Nam và Đông Nam Á) cần **30 phút đầu trơn tru** (quyết định tỉ lệ giữ chân ngày 1), **trận đấu ngắn** hợp phiên chơi 5–15 phút, và **ít loại tiền tệ** (nhiều tài nguyên là lời chê phổ biến).

| # | Câu hỏi | Quyết định | Lý do |
| --- | --- | --- | --- |
| Q22 | Áp công thức chỉ số mới cho vùng 1? | **Có, áp ở M3** (không đợi M5); M5 chỉ tinh chỉnh hệ số | M3 phải cân bằng 20 Thiên phú × 2 lớp; cân trên số cũ rồi M5 đổi công thức là làm 2 lần. Công thức trong code còn giúp thêm vùng mới không phải nhập tay chỉ số (KT-02) |
| Q23 | Số đòn mục tiêu | **Quái thường 3, tinh anh 12 giữ nguyên; boss chương 1 = 90 đòn, chương 2–3 = 110, chương 4+ = 130; boss hiếm 200** | Quái chết nhanh là cảm giác "đã tay" của thể loại. Boss đầu tiên nằm trong 30 phút đầu nên phải thắng được ngay lần đầu (≈ 35–40 giây); boss sau dài dần để có chỗ cho cơ chế giai đoạn |
| Q24 | Mỗi map con 15 ô (45 ô/vùng) | **Giữ**; vùng 1 = 40 ô (10 + 15 + 15) | Nằm trong khoảng 40–60 của kịch bản; mỗi map con chơi xong trong 1–2 phiên ngắn |
| Q25 | Vùng 1: boss cấp 6 giữa vùng, Lõi Sương (7–10) mở sau boss | **Giữ** | Khớp 30 phút đầu của kịch bản (boss ở phút 23–28). Lõi Sương thành nội dung "sau boss" có boss hiếm, giữ người chơi ở lại chương 1 tới cấp 10 |
| Q26 | Tài nguyên mới | **Giữ Đá, Sắt, Tinh Thạch** (kịch bản có). **Bỏ Tinh Thạch Hư Vô** khỏi danh sách tiền tệ: thay bằng Tinh Thạch ×3 và vật phẩm cốt truyện Lõi Hư Vô. **Bến Cá không tạo tài nguyên**, chỉ cho buff lãnh địa +3% HP mỗi cấp (tối đa +15%) | Giữ số tài nguyên trên HUD ở mức hiện tại + 3. Mỗi tài nguyên mới phải có chỗ tiêu rõ ràng |
| Q27 | Tên, kỹ năng, đồ Cam do thiết kế đặt | **Như tài liệu**; tên theo phong cách Hán-Việt của kịch bản | Giữ đúng cơ chế 1 dòng của kịch bản cho 9 boss chương. Tên có thể đổi khi có người viết cốt truyện mà không ảnh hưởng chỉ số |
""")

open(OUT, "w", encoding="utf-8").write("\n".join(o))
print("ok", len(o), "lines")
