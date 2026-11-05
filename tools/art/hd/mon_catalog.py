"""MD-1 (docs/39): danh mục thiết kế lại 94 quái / boss / linh thú theo phong cách ảnh mẫu (docs/39 §2–§3).

Mỗi mục: id (khớp godot/scripts/data/monsters.gd + catalog pixel) → builder + tham số + "concept" (ý tưởng thiết kế,
ghi vào bảng docs/39 §4 bằng `python tools/art/hd/mon_build.py --doc`). Thêm quái mới: thêm 1 mục ở đây,
xem skill .claude/skills/monster-design.

Khoá chung: b (builder: biped | beast | spirit | mushroom | treant | bird | bug | serpent | frog | mirror | pylon | eye),
region (1–9, "pet" = linh thú Triệu Hồi Sư), tier (thuong | tinh_anh | boss), L (24 / 32 / 48 — độ phân giải),
concept, death (fall | crumble | fade). Các khoá còn lại là tham số của builder (xem docstring từng file mon_*.py).
"""

M = {}


def add(mid, b, region, tier, concept, L=24, **kw):
    M[mid] = dict(b=b, region=region, tier=tier, concept=concept, L=L, **kw)


# ============================================================ Vùng 1 · Rừng Sương (Mộc — lục, sương lam)
add("wolf", "beast", 1, "thuong", "Sói xám lông xù, gáy dựng gai lông, mắt vàng hổ phách; dáng thấp sẵn lao", head="canine",
    fur="fur_grey", belly="white", eye="#ffd23c")
add("mushroom", "mushroom", 1, "thuong", "Nấm tím chấm kem có khuôn mặt cau có trên thân, chân ngắn lạch bạch, phun bào tử xanh",
    cap="purple", spots="#fff2c8", spore="#c8ff7a")
add("wisp", "spirit", 1, "thuong", "Đốm hồn sương xanh ngọc, đuôi khói, mặt cười tinh nghịch", form="wisp", body="wisp", glow="#9de0e6")
add("moc-tinh", "treant", 1, "thuong", "Gốc cây biết đi: thân vỏ nứt, rêu xanh, mắt hốc phát sáng lục, tay cành", L=32, bark="wood",
    leaf="leaf", eye="#c8ff7a", moss="leaf_dark")
add("nam-con", "mushroom", 1, "thuong", "Nấm con mũ cam chấm kem — nhỏ, nổ bào tử cam", cap="fire", spots="#fff2c8", spore="#ff9a3c")
add("goc-re", "treant", 1, "thuong", "Gốc rễ nhỏ, tán lá thấp, mắt tím — trụ triệu hồi của Lão Thụ", bark="wood", leaf="leaf",
    eye="#c878ff", crown=0.75)
add("boss", "beast", 1, "boss", "Sói Chúa Hư Vô: lông tím than, bờm sư tử tím, sừng cong, khói Hư Vô bốc từ lưng, mắt hồng rực", L=48,
    head="canine", fur="fur_void", belly="void", mane="void", mane_style="lion", horns="pair", horn="bone", eye="#ff5ad1",
    aura="#a066ff", spikes="void")
add("lao-thu", "treant", 1, "boss", "Lão Thụ Sương Mù: cổ thụ tán tím sương, quả đỏ độc, mắt đỏ, rễ cuộn lớn", L=48, bark="bark",
    leaf="purple", eye="#ff5470", crown=1.15, fruit="#ff5470", moss="swamp")
add("bach-ho", "beast", 1, "boss", "Bạch Hổ Phong Vân: hổ trắng vằn than, bờm thép, mắt xanh gió, gió trắng quấn thân", L=48,
    head="feline", fur="white", belly="snow", mane="steel", mane_style="lion", stripes="#3c4454", eye="#4fc3ff", tail="thin",
    aura="#dce6f2")

# ============================================================ Vùng 2 · Đồng Bằng Gió Hú (Kim — bạc, thép)
add("ung-gio", "bird", 2, "thuong", "Ưng gió trắng cánh thép, mào nhọn, mắt đỏ — bổ nhào", body="white", wing="steel",
    eye="#ff5470", crest="steel")
add("linh-danh-thue", "biped", 2, "thuong", "Lính đánh thuê trùm mũ, mặt khuất bóng mắt tím, giáp vai sắt, áo choàng Hư Vô, kiếm",
    head="hood", cloth="steel", hood_tone="iron", pants="leather", trim="void", weapon="sword", cape="void", pauldron="iron",
    eye="#c080ff")
add("doi-truong", "biped", 2, "tinh_anh", "Đội trưởng đánh thuê: mũ giáp chùm lông đỏ, giáp vai vàng, rìu lớn — xoáy rìu", L=32,
    head="helm", helm="steel", plume="cloth_red", cloth="steel", pants="cloth_red", trim="gold", weapon="axe", cape="cloth_red",
    pauldron="gold", eye="#ffd23c", bulk=1.1)
add("cung-thu", "biped", 2, "thuong", "Cung thủ thảo nguyên tóc nâu buộc, áo lá, cung gỗ lớn", head="human", hair="hair_brown",
    skin="skin", cloth="leaf", pants="leather", trim="leather", weapon="bow", belt="leather")
add("loc-xoay", "spirit", 2, "thuong", "Lốc xoáy con trắng bạc có đôi mắt xếch — hút người chơi", form="tornado", body="white",
    glow="#e8e2c8")
add("phu-thuy-gio", "biped", 2, "tinh_anh", "Phù thuỷ gió: mũ trùm tím, áo dài, trượng ngọc gió, gió nhẹ quanh chân", L=32,
    head="hood", cloth="purple", robe="purple", trim="white", weapon="staff", orb="#bfe8ff", eye="#9ae8ff", aura="#c8e8ff")
add("huyen-anh", "biped", 2, "boss", "Huyền Ảnh: gián điệp trùm mũ Hư Vô, khăn che mặt đỏ máu, áo choàng tím, kiếm mảnh", L=48,
    head="hood", cloth="void", hood_tone="abyss", pants="hair_dark", trim="blood", weapon="sword", cape="purple", pauldron="abyss",
    mask="blood", eye="#ff3b4e")
add("huyen-anh-ao", "biped", 2, "boss", "Bản sao Huyền Ảnh: giống hệt bản thật nhưng KHÔNG có bóng dưới chân (gợi ý kịch bản)", L=48,
    head="hood", cloth="void", hood_tone="abyss", pants="hair_dark", trim="blood", weapon="sword", cape="purple", pauldron="abyss",
    mask="blood", eye="#ff3b4e", no_shadow=True)

# ============================================================ Vùng 3 · Sa Mạc Xích Sa (Thổ — cát, nâu đỏ)
add("bo-cat", "bug", 3, "thuong", "Bọ cát vỏ đỏ gạch, hàm kìm, mắt vàng", shell="sand_red", leg="chitin", eye="#ffd23c", scale=0.9,
    death="crumble")
add("ran-cat", "serpent", 3, "thuong", "Rắn đồi cát cuộn khoanh, bành mang, vảy đốm nâu", body="sand_red", belly="sand", eye="#ffd23c",
    death="crumble")
add("xac-uop", "biped", 3, "thuong", "Xác ướp băng vải ngả vàng, một mắt lục lộ qua kẽ băng, tay dài lê bước", head="mummy",
    skin="bandage", cloth="bandage", pants="bandage", boots="bandage", wrap=True, bare_arms=True, glove="bandage", belt="sand",
    eye="#9aff5a", tunic=False)
add("phap-su-cat", "biped", 3, "thuong", "Pháp sư cát áo choàng vàng cát, mắt cam trong mũ trùm, trượng cầu lửa", head="hood",
    cloth="sand", robe="sand", pants="sand_red", trim="fire", weapon="staff", orb="#ff9a3c", skin="skin_dark", eye="#ffb040")
add("bo-hung", "bug", 3, "tinh_anh", "Bọ hung giáp vàng sừng cong — lăn húc", L=32, shell="gold", leg="chitin", horn=True,
    eye="#ff5470", scale=1.2, death="crumble")
add("thu-linh-xac-uop", "biped", 3, "tinh_anh", "Thủ lĩnh xác ướp: vương miện vàng, áo choàng tím, trượng cầu tím — hồi sinh", L=32,
    head="mummy", skin="bandage", cloth="gold", pants="bandage", boots="bandage", wrap=True, bare_arms=True, glove="bandage",
    trim="blood", weapon="staff", orb="#c080ff", cape="purple", crown="gold", eye="#9aff5a")
add("sa-hoang", "bug", 3, "boss", "Bọ Cạp Sa Hoàng: vỏ nâu sẫm bóng, càng lớn, đuôi độc phát sáng lục", L=48, scorpion=True,
    shell="chitin", sting="#8cff5a", eye="#ff3b4e", scale=1.3, death="crumble")
add("nhan-su", "beast", 3, "boss", "Nhân Sư Đá: thân sư tử cát, khăn nemes sọc vàng–lam, mắt lam phát sáng", L=48, head="feline",
    fur="sand", belly="sand", nemes="gold", nemes2="#2a5aa8", tail="tuft", mane="gold", eye="#4fc3ff", bulk=1.15)

# ============================================================ Vùng 4 · Đầm Lầy U Minh (Thủy — lục rêu, tím đêm)
add("ech-doc", "frog", 4, "thuong", "Ếch độc da lục đốm lam, mắt lồi vàng, túi cổ phồng — lưỡi dài", skin="toad", belly="sand",
    spots="#2a4a8a", eye="#ffd23c", death="crumble")
add("dia", "serpent", 4, "thuong", "Đỉa hút máu đỏ thẫm, miệng giác hút răng tròn", leech=True, body="leech", belly="leech",
    eye="#ff5470", death="crumble")
add("hon-ma", "spirit", 4, "thuong", "Hồn ma đầm: vải trắng rách, miệng há rên (hét)", form="ghost", body="white", glow="#9ab8c8",
    death="fade")
add("phu-thuy-dam", "biped", 4, "tinh_anh", "Phù thuỷ đầm lầy: mũ trùm rêu, áo dài rách, trượng cầu độc lục — mưa độc", L=32,
    head="hood", cloth="swamp", robe="swamp", pants="purple", trim="leaf", weapon="staff", orb="#9aff5a", eye="#c8ff7a")
add("ca-sau", "beast", 4, "thuong", "Cá sấu bùn: thân dài thấp, gai lưng, mõm dài răng trắng", head="croc", fur="swamp", belly="sand",
    tail="lizard", leg=0.55, length=1.25, spikes="swamp", eye="#ffd23c", death="crumble")
add("ca-sau-chua", "beast", 4, "tinh_anh", "Cá sấu chúa: to gấp rưỡi, vương miện vàng, mắt đỏ — cuộn tử thần", L=32, head="croc",
    fur="mud", belly="sand", tail="lizard", leg=0.55, length=1.25, spikes="swamp", crown="gold", eye="#ff5470", death="crumble")
add("nu-vuong", "biped", 4, "boss", "Nữ Vương Phệ Mộng: tóc bạc dài, vương miện, áo choàng tím mộng, trượng ngọc, hào quang tím", L=48,
    head="human", skin="skin_light", hair="white", hair_style="long", cloth="purple", robe="purple", trim="crystal", weapon="staff",
    orb="#c28af0", cape="void", crown="gold", aura="#c28af0", glow_eyes=True, eye="#e0b0ff")
add("mong-chau", "spirit", 4, "thuong", "Mộng châu: ngọc tím xoáy sương, một mắt lơ mơ", form="orb", body="purple", glow="#c28af0",
    death="fade")
add("thuy-quai", "serpent", 4, "boss", "Thuỷ Quái Thất Đầu: bảy cổ rắn biển vây lam mọc từ vòng nước", L=48, heads=7, body="sea",
    belly="crystal", eye="#ff5470", fins="sea", death="crumble")
add("dau-thuy-quai", "serpent", 4, "thuong", "Đầu thuỷ quái: cổ rắn biển vây lam ngẩng lên phun nước", body="sea", belly="crystal",
    eye="#ffd23c", fins="sea", hood=False, death="crumble")

# ============================================================ Vùng 5 · Núi Viêm Long (Hỏa — đỏ, nham thạch)
add("than-lan-lua", "beast", 5, "thuong", "Thằn lằn lửa: vảy đỏ, vân nham thạch phát sáng, gai lưng lửa", head="lizard", fur="ember",
    belly="sand", tail="lizard", leg=0.7, spikes="lava", cracks="#ffb040", eye="#ffd23c", death="crumble")
add("nguoi-da", "biped", 5, "thuong", "Người đá dung nham: khối bazan vai u, khe nứt cam cháy, mắt lửa", L=32, body="brute",
    head="stone", skin="basalt", cloth="basalt", pants="basalt", boots="basalt", glove="basalt", bare_arms=True, rocks="basalt",
    cracks="#ff8a2a", eye="#ffb040", belt=None, death="crumble")
add("manh-da", "bug", 5, "thuong", "Mảnh đá bò: tảng bazan có chân, vết nứt cam", shell="basalt", leg="ash", rock=True,
    cracks="#ff9a3c", eye="#ff9a3c", scale=0.85, death="crumble")
add("linh-hon-lua", "spirit", 5, "thuong", "Linh hồn lửa: ngọn lửa có mặt, lõi vàng — tự nổ", form="flame", body="lava", glow="#ff9a3c",
    death="fade")
add("phap-su-hoa-diem", "biped", 5, "thuong", "Pháp sư hoả diệm: áo choàng đỏ than, viền vàng, trượng cầu lửa", head="hood",
    cloth="ember", robe="ember", pants="basalt", trim="gold", weapon="staff", orb="#ff6a2a", eye="#ffb040")
add("rong-non", "beast", 5, "tinh_anh", "Rồng non lửa: cánh màng cam, sừng ngà, gai lưng nham — phun lửa", L=32, head="dragon",
    fur="ember", belly="sand", tail="lizard", wings="lava", span=0.8, horns="pair", horn="bone", spikes="lava", breath="#ff9a3c",
    eye="#ffd23c", death="crumble")
add("tho-ren-hu-vo", "biped", 5, "tinh_anh", "Thợ rèn Hư Vô: đầu trọc, vai u thịt bắp, tạp dề da, râu đen, búa rèn, mắt tím bị ăn mòn", L=32,
    head="human", skin="skin_dark", beard="hair_dark", cloth="basalt", pants="leather", trim="void",
    weapon="hammer", bare_arms=True, glow_eyes=True, eye="#c080ff", bulk=1.2, cuff="iron")
add("linh-kim-luan", "biped", 5, "thuong", "Lính Kim Luân: mũ giáp vàng, áo giáp vàng viền đỏ, giáo dài", head="helm", helm="gold",
    cloth="gold", pants="steel", trim="cloth_red", weapon="spear", eye="#ffd23c", pauldron="gold")
add("doi-truong-kim-luan", "biped", 5, "tinh_anh", "Đội trưởng Kim Luân: mũ vàng chùm lông đỏ, khiên vàng, kiếm, áo choàng đỏ", L=32,
    head="helm", helm="gold", plume="cloth_red", cloth="gold", pants="cloth_red", trim="steel", weapon="sword", cape="cloth_red",
    shield="gold", emblem="#c03a3a", pauldron="steel", eye="#ffd23c")
add("vien-long", "beast", 5, "boss", "Viêm Long: rồng bazan vân nham thạch, cánh đen màng lửa, sừng ngà, phun lửa", L=48,
    head="dragon", fur="ember", belly="sand", tail="lizard", wings="basalt", membrane="lava", span=1.15, horns="pair", horn="bone",
    spikes="basalt", cracks="#ffb040", aura="#ff7a1a", breath="#ff9a3c", eye="#ffd23c", death="crumble")
add("phuong-hoang", "bird", 5, "boss", "Phượng Hoàng Tro: chim lửa đuôi ba dải cháy, mào lửa, hào quang cam", L=48, phoenix=True,
    body="lava", wing="ember", beak="#ffd23c", eye="#4fc3ff", glow="#ff9a3c", crest="lava", death="fade")
add("xuong-no", "biped", 5, "thuong", "Xương nô: bộ xương cầm kiếm mẻ, hốc mắt tím", body="thin", head="skull", skin="bone",
    cloth="bone", pants="bone", boots="bone", ribs=True, weapon="sword", bare_arms=True, glove="bone", belt=None, eye="#c080ff",
    tunic=False, death="crumble")

# ============================================================ Vùng 6 · Băng Nguyên Bắc Cực (Thủy — trắng, băng lam)
add("soi-bang", "beast", 6, "thuong", "Sói băng lông tuyết, gai băng dọc gáy, mắt lam", head="canine", fur="fur_snow", belly="white",
    mane="ice", mane_style="spikes", spikes="ice", eye="#4fc3ff")
add("nguoi-tuyet", "biped", 6, "thuong", "Người tuyết: khối tuyết vai u, gai băng trên đầu, mắt than lam", L=32, body="brute",
    head="snow", skin="snow", cloth="snow", pants="snow", boots="snow", glove="snow", bare_arms=True, rocks="ice", eye="#4fc3ff",
    belt=None, death="crumble")
add("tinh-linh-bang", "spirit", 6, "thuong", "Tinh linh băng: cụm tinh thể băng có mắt, phát sáng lam", form="crystal", body="ice",
    glow="#8ad8ff", death="fade")
add("cung-thu-bang", "biped", 6, "thuong", "Cung thủ băng: mũ trùm lam sương, cung gỗ, mũi tên băng", head="hood", cloth="frost",
    pants="steel", trim="ice", weapon="bow", orb="#bfeaff", eye="#8ad8ff")
add("gau-bang", "beast", 6, "tinh_anh", "Gấu băng khổng lồ: lông trắng dày, gai băng trên lưng, mắt lam", L=48, head="bear",
    fur="fur_snow", belly="ice", bulk=1.35, leg=0.85, spikes="ice", eye="#4fc3ff", tail="thin", death="crumble")
add("phap-su-bao-tuyet", "biped", 6, "tinh_anh", "Pháp sư bão tuyết: áo dài băng, áo choàng tuyết, trượng ngọc băng, bão nhỏ", L=32,
    head="hood", cloth="ice", robe="frost", trim="white", weapon="staff", orb="#bfeaff", cape="snow", aura="#bfeaff", eye="#e8f8ff")
add("ban-nga", "biped", 6, "boss", "Bản Ngã Bóng Tối: cái bóng của người chơi — thân tím than, mắt và miệng sáng tím, kiếm", L=48,
    head="shadow", skin="shadow", cloth="shadow", pants="shadow", boots="shadow", glove="shadow", cape="shadow", weapon="sword",
    blade="void", aura="#6a3aa8", eye="#e080ff", trim="purple")
add("guong-bang", "mirror", 6, "thuong", "Gương băng: khung băng gai nhọn, mặt gương phản chiếu", L=32, death="crumble")
add("anh-bong", "biped", 6, "thuong", "Ảnh bóng: bóng nhỏ, dao găm, mắt tím", head="shadow", skin="shadow", cloth="shadow",
    pants="shadow", boots="shadow", glove="shadow", weapon="dagger", eye="#e080ff", h=0.92, trim="purple", death="fade")
add("long-bang", "beast", 6, "boss", "Long Băng Bắc Cực: rồng trắng băng, cánh màng lam, gai tinh thể, hơi thở băng", L=48,
    head="dragon", fur="ice", belly="snow", tail="lizard", wings="frost", membrane="ice", span=1.2, horns="pair", horn="snow",
    spikes="ice", aura="#8ad8ff", breath="#bfeaff", eye="#d8f2ff", death="crumble")

# ============================================================ Vùng 7 · Quần Đảo Thiên Không (Kim / Mộc — trời, mây, vàng)
add("dai-bang-may", "bird", 7, "thuong", "Đại bàng mây: lông trắng mây, cánh lam trời, mào vàng", L=32, body="cloud", wing="sky",
    beak="#f0c050", eye="#ffd86a", crest="sky_gold")
add("nguoi-go-dao", "treant", 7, "thuong", "Người gỗ đảo bay: tán lá ngọc, quả vàng, mắt lục nhạt", L=32, bark="wood", leaf="leaf_sky",
    eye="#c8f4a8", crown=1.05, fruit="#ffe080")
add("tien-gio", "biped", 7, "thuong", "Tiên gió: tóc lá dài, cánh chuồn trong suốt, bay lơ lửng, trượng lá", head="human",
    skin="skin_light", hair="leaf_light", hair_style="long", cloth="leaf_sky", robe="leaf_sky", trim="sky_gold", weapon="staff",
    orb="#a8f0c0", hover=6, aura="#a8f0c0", wings="crystal", glow_eyes=True, eye="#5ad08a")
add("hiep-si-thien-khong", "biped", 7, "thuong", "Hiệp sĩ thiên không: mũ thép chùm lông trời, áo choàng lam, giáo", head="helm",
    helm="steel", plume="sky", cloth="steel", pants="sky", boots="steel", trim="sky_gold", weapon="spear", cape="sky",
    pauldron="sky_gold", eye="#9ad8ff")
add("thu-ho-dao", "biped", 7, "tinh_anh", "Thủ hộ đảo: giáp đá cẩm thạch viền vàng, khiên trời, kiếm, hào quang vàng", L=32,
    head="helm", helm="sky_gold", cloth="marble", pants="steel", boots="steel", trim="sky_gold", weapon="sword", cape="sky_gold",
    shield="sky", emblem="#fff0b0", aura="#fff0b0", pauldron="sky_gold", eye="#9ad8ff", bulk=1.12)
add("rong-may", "beast", 7, "tinh_anh", "Rồng mây: thân ngọc, bờm mây, sừng gạc vàng, cánh mây, đuôi mây", L=48, head="dragon",
    fur="leaf_sky", belly="cloud", mane="cloud", mane_style="spikes", wings="cloud", span=1.0, tail="cloud", horns="antler",
    horn="sky_gold", aura="#c8f4a8", eye="#ffffff", death="crumble")
add("neo-hu-vo", "pylon", 7, "thuong", "Neo Hư Vô: cột đá đen lơ lửng, vân tím, mảnh vỡ quay quanh", L=32, kind="anchor",
    death="crumble")
add("cu-than", "biped", 7, "boss", "Thiên Không Cự Thần: khổng lồ cẩm thạch, vai vàng, vết nứt sáng trời", L=48, body="brute",
    head="stone", skin="marble", cloth="marble", pants="marble", boots="marble", glove="marble", bare_arms=True, rocks="sky_gold",
    cracks="#fff0b0", pauldron="sky_gold", trim="sky_gold", eye="#9ad8ff", belt=None, death="crumble")
add("ky-lan-may", "beast", 7, "tinh_anh", "Kỳ Lân Mây: ngựa ngọc một sừng vàng, bờm gai vàng, đuôi mây", L=48, head="horse",
    fur="leaf_sky", belly="cloud", mane="sky_gold", mane_style="spikes", horns="unicorn", horn="sky_gold", tail="cloud",
    eye="#bcdcff", aura="#9ad8ff", leg=1.15)

# ============================================================ Vùng 8 · Vực Hư Vô (Hư Vô — tím, đen)
add("bong-hu-vo", "biped", 8, "thuong", "Bóng Hư Vô: sát thủ trùm mũ tím đen, dao găm — đâm sau lưng", head="hood", skin="shadow",
    cloth="abyss", hood_tone="abyss", pants="abyss", boots="abyss", trim="purple", weapon="dagger", cape="abyss", eye="#c080ff",
    h=0.95)
add("ke-nuot", "biped", 8, "thuong", "Kẻ Nuốt Thiên Phú: pháp sư áo tím, mắt hồng, trượng cầu Hư Vô hút sáng", head="hood",
    cloth="purple", robe="abyss", trim="silver", weapon="staff", orb="#8a5ad0", aura="#8a5ad0", eye="#ff5ad0")
add("giap-si-hu-vo", "biped", 8, "thuong", "Giáp sĩ Hư Vô: mũ giáp sắt, khiên Hư Vô, giáp vai bạc", head="helm", helm="iron",
    cloth="abyss", pants="steel", boots="steel", trim="purple", weapon="sword", shield="void", emblem="#c080ff", pauldron="silver",
    eye="#c080ff", bulk=1.08)
add("mat-hu-vo", "eye", 8, "thuong", "Mắt Hư Vô: nhãn cầu lơ lửng, xúc tu tím, đồng tử hồng — bắn tia", iris="#ff5ad0",
    death="fade")
add("tu-te-hu-vo", "biped", 8, "tinh_anh", "Tư tế Hư Vô: áo dài đỏ máu viền vàng, trượng cầu máu, hào quang đỏ — hiến tế", L=32,
    head="hood", cloth="blood", robe="blood", trim="gold", weapon="staff", orb="#ff5a7a", aura="#ff5a7a", eye="#ff5a7a")
add("khong-mat", "biped", 8, "tinh_anh", "Quái vật không mặt: mặt nạ bạc trơn, khiên bạc, kiếm, hào quang xám", L=32,
    head="faceless", skin="silver", cloth="abyss", pants="abyss", boots="steel", trim="silver", weapon="sword", shield="silver",
    emblem="#c8c0d8", aura="#c8c0d8", eye="#c8c0d8", bulk=1.15)
add("long-hu-vo", "pylon", 8, "thuong", "Lồng Hư Vô: lồng song đá tím giam lõi sáng", L=32, kind="cage", death="crumble")
add("tru-phong-an", "pylon", 8, "thuong", "Trụ phong ấn: cột cẩm thạch quấn xích, chữ ấn tím", L=32, kind="seal", death="crumble")
add("giao-chu", "biped", 8, "boss", "Giáo Chủ Hư Vô: mũ trùm sâu, mặt nạ bạc, vương miện vàng, trượng sao, hào quang vàng", L=48,
    head="hood", cloth="abyss", hood_tone="abyss", robe="abyss", cape="abyss", trim="gold", weapon="staff", orb="#f0dc8a",
    aura="#f0dc8a", mask="silver", crown="gold", eye="#f0dc8a", pauldron="gold")
add("hu-vo-thu", "beast", 8, "tinh_anh", "Hư Vô Thú: mãnh thú tím than vằn hồng, bờm vực thẳm, sừng cong, gai tím", L=48,
    head="feline", fur="fur_void", belly="abyss", mane="abyss", mane_style="lion", stripes="#c04ad0", aura="#6a3aa8",
    eye="#ff5ad0", horns="pair", horn="bone", spikes="void", tail="thin")

# ============================================================ Vùng 9 · Cổng Thiên Đạo (Ngũ hành — vàng thiên, ngọc)
add("thien-binh", "biped", 9, "thuong", "Thiên binh ngũ hành: mũ vàng, giáp vàng quần ngọc, giáo", head="helm", helm="heaven_gold",
    cloth="heaven_gold", pants="jade", boots="jade", trim="white", weapon="spear", eye="#7ad0ff", pauldron="jade")
add("tan-hon", "spirit", 9, "thuong", "Tàn hồn khai giới giả: hồn ma lam bạc còn đội mũ giáp cũ của người khai giới", form="ghost",
    body="spirit", glow="#bcd8f0", helm="steel", plume="heaven_gold", death="fade")
add("thien-ma", "beast", 9, "thuong", "Thiên mã: ngựa trắng cánh trắng, bờm vàng thiên, đuôi mây", head="horse", fur="white",
    belly="white", mane="heaven_gold", mane_style="spikes", wings="white", span=0.75, tail="cloud", aura="#fff4c0", eye="#7ad0ff",
    leg=1.1)
add("linh-thu-ngu-hanh", "beast", 9, "thuong", "Ngũ hành linh thú: sư tử vàng thiên, bờm ngọc, vằn lục, sừng gạc ngọc", L=32,
    head="feline", fur="heaven_gold", belly="white", mane="jade", mane_style="lion", stripes="#3aa88a", horns="antler",
    horn="jade", eye="#ff6a3c")
add("thien-tuong", "biped", 9, "tinh_anh", "Thiên tướng: giáp vàng thiên, mũ chùm lông đỏ, khiên vàng, kiếm, hào quang", L=32,
    head="helm", helm="heaven_gold", plume="cloth_red", cloth="heaven_gold", pants="steel", boots="steel", trim="white",
    weapon="sword", cape="cloth_red", shield="heaven_gold", emblem="#ff6a3c", aura="#fff4c0", pauldron="heaven_gold",
    eye="#7ad0ff", bulk=1.15)
add("ngu-hanh-su-gia", "biped", 9, "tinh_anh", "Ngũ hành sứ giả: lão nhân tóc râu bạc, áo ngọc, trượng tinh thể, hào quang", L=32,
    head="human", skin="skin_light", hair="white", hair_style="long", beard="white", cloth="jade", robe="jade", trim="heaven_gold",
    weapon="staff", orb="#a8d8ff", aura="#86d8e4", glow_eyes=True, eye="#a8f0ff")
add("ma-ton", "biped", 9, "boss", "Ma Tôn Vô Diện: ma vương không mặt, sừng bazan, giáp vai tím, áo choàng đen, kiếm Hư Vô", L=48,
    head="faceless", skin="void_black", cloth="void_black", pants="void_black", boots="void_black", glove="void_black",
    horns="basalt", cape="void_black", weapon="sword", blade="void", pauldron="purple", trim="purple", aura="#6a3aa8",
    eye="#c080ff", bulk=1.2)
add("ma-ton-ao", "biped", 9, "boss", "Ảo ảnh Ma Tôn: giống hệt bản thật (cơ chế đánh lừa)", L=48, head="faceless", skin="void_black",
    cloth="void_black", pants="void_black", boots="void_black", glove="void_black", horns="basalt", cape="void_black",
    weapon="sword", blade="void", pauldron="purple", trim="purple", aura="#6a3aa8", eye="#c080ff", bulk=1.2)
add("thien-dao-hu-anh", "biped", 9, "boss", "Thiên Đạo Hư Ảnh: hư ảnh trắng bán trong suốt, tóc bạc dài, bay, trượng vàng", L=48,
    head="human", skin="spirit", hair="white", hair_style="long", cloth="white", robe="white", trim="heaven_gold", weapon="staff",
    orb="#fff0b0", aura="#fff4c0", hover=6, ghost=0.88, glow_eyes=True, eye="#fff0b0")

# ============================================================ Linh thú Triệu Hồi Sư (chờ Q190 — chưa bật trong game)
add("linh-ho", "beast", "pet", "linh_thu", "Linh hồ: cáo hồn xanh ngọc đuôi xù", head="canine", fur="wisp", belly="white",
    eye="#ffffff", aura="#9de0e6", death="fade")
add("hoa-ho", "beast", "pet", "linh_thu", "Hoả hồ: cáo lửa đuôi cháy", head="canine", fur="fire", belly="sand", tail="flame",
    mane="lava", eye="#ffffff", aura="#ff9a3c", death="fade")
add("soi-bong", "beast", "pet", "linh_thu", "Sói bóng: sói tím than mắt tím", head="canine", fur="fur_void", belly="void",
    eye="#e080ff", death="fade")
add("tieu-quy", "spirit", "pet", "linh_thu", "Tiểu quỷ: quỷ nhỏ tím sừng nhọn đuôi roi", form="imp", body="purple", glow="#e080ff",
    death="fade")
add("thach-quy", "biped", "pet", "linh_thu", "Thạch quỷ: người đá xám, vân tinh thể lam", L=32, body="brute", head="stone",
    skin="stone", cloth="stone", pants="stone", boots="stone", glove="stone", bare_arms=True, rocks="stone", cracks="#a8d8ff",
    eye="#a8d8ff", belt=None, death="crumble")
add("linh-ung", "bird", "pet", "linh_thu", "Linh ưng: chim hồn ngọc cánh tinh thể", body="wisp", wing="crystal", eye="#ffffff",
    beak="#c4e4ff", death="fade")
add("linh-hon", "spirit", "pet", "linh_thu", "Linh hồn nhỏ xanh ngọc", form="wisp", body="wisp", glow="#86d8e4", scale=0.8,
    death="fade")
add("au-long", "beast", "pet", "linh_thu", "Ấu long: rồng con lửa, bờm vàng, cánh nhỏ", head="dragon", fur="fire", belly="sand",
    mane="gold", mane_style="spikes", wings="fire", span=0.6, horns="pair", horn="bone", tail="lizard", eye="#ffd23c",
    death="fade")
add("ky-lan", "beast", "pet", "linh_thu", "Kỳ lân thần thú: ngựa trắng sừng vàng, bờm vàng, đuôi mây", L=32, head="horse",
    fur="white", belly="white", mane="gold", mane_style="spikes", horns="unicorn", horn="gold", tail="cloud", eye="#4a9df8",
    aura="#fff4c0", leg=1.1, death="fade")

REGION_NAMES = {1: "Rừng Sương", 2: "Đồng Bằng Gió Hú", 3: "Sa Mạc Xích Sa", 4: "Đầm Lầy U Minh", 5: "Núi Viêm Long",
                6: "Băng Nguyên Bắc Cực", 7: "Quần Đảo Thiên Không", 8: "Vực Hư Vô", 9: "Cổng Thiên Đạo",
                "pet": "Linh thú Triệu Hồi Sư"}
# Linh thú là một phần kỹ năng Triệu Hồi Sư → chỉ vẽ bản duyệt, chưa đưa vào lớp phủ HD cho tới khi chủ dự án đồng ý (Q190).
LIVE_EXCLUDE = {k for k, v in M.items() if v["region"] == "pet"}
