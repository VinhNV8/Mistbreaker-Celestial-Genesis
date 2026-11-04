"""IC-1 (docs/37 §6): vẽ lại 20 icon kỹ năng bị động (+ icon tab "Bị động") cùng phong cách 51 icon chủ động IC-1.

Được skill_icons_fx.build() gọi: khoá "pv-<id>" → icon game "skill-pv-<id>" (passives.gd DEFS "icon").
Bị động không có icon vẽ tay của chủ dự án (tất cả trước đây vẽ bằng code ở tools/art/passive_icons.py).
"""
import math

from skill_fx_kit import pal

MANA = pal("#ffffff", "#bfe0ff", "#4a8cff", "#162a7a")
HEAL = pal("#f4fff0", "#c8ffb0", "#6ad870", "#1c6a2a")


def _heart(S, c, s, p, glow=1.2):
    pts = []
    for i in range(40):
        t = i / 40 * math.tau
        x = 16 * math.sin(t) ** 3
        y = -(13 * math.cos(t) - 5 * math.cos(2 * t) - 2 * math.cos(3 * t) - math.cos(4 * t))
        pts.append((c[0] + x * s / 16, c[1] + y * s / 16))
    S.poly(pts, p, glow=glow)


def _skull(S, c, s, p):
    S.disc((c[0], c[1] - s * 0.15), s * 0.62, p, glow=0.9)
    S.poly([(c[0] - s * 0.38, c[1] + s * 0.2), (c[0] + s * 0.38, c[1] + s * 0.2), (c[0] + s * 0.28, c[1] + s * 0.62),
            (c[0] - s * 0.28, c[1] + s * 0.62)], p, glow=0.4)
    d = S.draw("fx")
    for ex in (-0.24, 0.24):
        d.ellipse((c[0] + s * ex - s * 0.15, c[1] - s * 0.22, c[0] + s * ex + s * 0.15, c[1] + s * 0.06), fill=(20, 8, 6, 255))
    d.polygon([(c[0], c[1] + s * 0.08), (c[0] - s * 0.07, c[1] + s * 0.22), (c[0] + s * 0.07, c[1] + s * 0.22)], fill=(20, 8, 6, 255))


def make(P, silhouette):
    """Trả {khoá: (khoá bảng màu, hàm vẽ)}; P = bảng màu FX-1, silhouette = hàm bóng linh thú của skill_icons_fx."""

    def thietcot(S):  # Thiết Cốt: +HP tối đa — trái tim đỏ bọc vòng thép
        _heart(S, (32, 34), 20, P["kk"])
        S.ring((32, 34), 24, 3, P["metal"], squash=1.0, where="fx")
        for k in range(4):
            a = k * math.pi / 2 + math.pi / 4
            S.shard((32 + math.cos(a) * 24, 34 + math.sin(a) * 24), a, 9, P["metal"], glow=0.5)

    def kiemtam(S):  # Kiếm Tâm: +ST chí mạng — kiếm dựng, sao chí mạng ở mũi
        p = P["kk"]
        S.sword((32, 36), -math.pi / 2, 46, p, glow=1.3)
        S.star((32, 12), 11, 8, p, glow=1.8)
        S.crescent((32, 36), 22, 2.5, 4.0, 5, p, glow=0.6)
        S.crescent((32, 36), 22, 5.4, 6.9, 5, p, glow=0.6)

    def phankich(S):  # Phản Kích: né rồi đánh trả — vệt vòng ngược + kiếm
        p = P["kk"]
        S.crescent((32, 32), 20, 0.6, 4.6, 7, p, head=0.85)
        S.arrow((44, 14), -0.6, 8, p, glow=0.8)
        S.sword((30, 34), -math.pi / 4, 34, p, glow=1.2)
        S.star((44, 20), 8, 6, p, glow=1.2)

    def chieny(S):  # Chiến Ý: HP thấp mạnh hơn — kiếm giữa lửa
        S.poly([(9, 56), (14, 35), (18, 26), (22, 38), (27, 56)], P["fire"], glow=1.0)
        S.poly([(37, 56), (42, 38), (46, 26), (50, 35), (55, 56)], P["fire"], glow=1.0)
        S.poly([(23, 56), (28, 27), (32, 14), (36, 31), (41, 56)], P["fire"], glow=1.0)
        S.sword((32, 38), -math.pi / 2, 36, P["kk_blood"], glow=1.4)
        S.sparks((32, 30), 0.4, 10, 24, P["fire"], seed=4, up=True)

    def ungmuc(S):  # Ưng Mục: bắn xa — mắt ưng trong vòng ngắm
        p = P["ts_gold"]
        S.ring((32, 32), 24, 2, P["ts"], squash=1.0, where="fx")
        d = S.draw("fx")
        for a, b in (((32, 4), (32, 14)), ((32, 50), (32, 60)), ((4, 32), (14, 32)), ((50, 32), (60, 32))):
            d.line((a, b), fill=P["ts"][1] + (255,), width=2)
        S.crescent((24, 34), 18, math.radians(190), math.radians(265), 6, p)
        S.crescent((40, 34), 18, math.radians(275), math.radians(350), 6, p)
        d.ellipse((20, 27, 44, 39), fill=p[3] + (255,))
        d.ellipse((22, 28.5, 42, 37.5), fill=p[1] + (255,))
        S.disc((32, 33), 4.5, P["ts"], glow=1.4)
        d.ellipse((30.5, 31.5, 33.5, 34.5), fill=(20, 20, 20, 255))

    def sanmoi(S):  # Săn Mồi: quái máu thấp — bia ngắm đỏ + vết vuốt
        S.ring((32, 32), 20, 2.5, P["kk"], squash=1.0, where="fx")
        S.ring((32, 32), 10, 2, P["kk"], squash=1.0, where="fx")
        for k in range(3):
            x = 22 + k * 9
            S.streak((x - 6, 14), (x + 6, 52), 4, P["kk_blood"], tail=0.2, glow=0.9)
        S.arrow((50, 14), 2.4, 12, P["ts"], glow=0.8)

    def buocgio(S):  # Bước Gió: tốc chạy + né — gió xoáy + vệt tốc độ
        p = P["ts"]
        for k in range(3):
            a = k * math.tau / 3 + 0.2
            S.crescent((32, 34), 20 - k * 3, a, a + 2.0, 6, p, squash=0.7)
        for k in range(3):
            S.streak((6, 22 + k * 8), (24 + k * 4, 22 + k * 8), 2.5, p, alpha=200, glow=0.5)
        S.shard((40, 30), -0.5, 22, p, glow=1.2)

    def tamdoc(S):  # Tên Tẩm Độc: mũi tên nhỏ giọt độc
        p = P["ts_poison"]
        S.arrow((40, 22), math.pi / 2 + 0.6, 22, P["ts"], trail=10)
        S.shard((34, 30), math.pi / 2 + 0.6, 18, p, glow=1.3)
        for x, y, r in ((30, 42, 4), (26, 50, 3), (34, 54, 2.5)):
            S.disc((x, y), r, p, glow=0.8)
        S.glyph((46, 46), "poison", 7, p)

    def minhtuong(S):  # Minh Tưởng: hồi MP — cầu pháp lực trên vòng tĩnh toạ
        for k in range(3):
            S.ring((32, 46), 10 + k * 7, 2, MANA, alpha=230 - k * 50, where="fx")
        S.orb((32, 28), 12, MANA, glow=1.8)
        S.sparks((32, 40), 0.5, 10, 22, MANA, seed=3, up=True)

    def nguyento(S):  # Tinh Thông Nguyên Tố: khắc hệ — 3 cầu Hoả / Băng / Lôi quanh sao
        S.star((32, 32), 10, 10, P["arcane"], glow=1.6)
        for k, key in enumerate(("fire", "ice", "bolt")):
            a = -math.pi / 2 + k * math.tau / 3
            S.orb((32 + math.cos(a) * 19, 32 + math.sin(a) * 19), 8, P[key], glow=1.3)
            S.crescent((32, 32), 19, a + 0.3, a + 1.6, 3, P[key], glow=0.5)

    def doidao(S):  # Pháp Lực Dồi Dào: MP đầy — cầu pháp lực tràn giọt
        S.orb((32, 30), 16, MANA, glow=1.8)
        for x, y, r in ((18, 50, 4), (32, 54, 5), (46, 50, 4), (25, 58, 2.5), (40, 58, 2.5)):
            S.disc((x, y), r, MANA, glow=0.9)
        S.ring((32, 30), 20, 2, MANA, squash=1.0, where="fx", alpha=200)

    def hothe(S):  # Hộ Thể Pháp Lực: MP chịu đòn — vòm phép bọc cầu pháp lực
        S.dome((32, 52), 26, P["arcane"], 1.5, alpha=200)
        S.orb((32, 34), 10, MANA, glow=1.6)
        S.shield((32, 34), 6, MANA, glow=0.4)

    def kienthu(S):  # Kiên Thủ: +Phòng thủ — khiên thép lớn
        p = P["hv_steel"]
        S.glow_dot((32, 32), 24, p[2], 0.35)
        S.shield((32, 28), 19, p, glow=0.7)
        S.ring((32, 50), 20, 2, P["hv"], where="fx")

    def ychisat(S):  # Ý Chí Sắt: hồi HP — trái tim thép + hạt hồi máu
        _heart(S, (32, 32), 19, P["hv_steel"])
        S.ring((32, 32), 24, 2.5, P["hv"], squash=1.0, where="fx")
        S.sparks((32, 38), 0.5, 12, 24, HEAL, seed=5, up=True, size=2)

    def phanchan(S):  # Phản Chấn: phản sát thương — khiên dội tia ra ngoài
        S.shield((26, 32), 15, P["hv_steel"], glow=1.3)
        for k, a in enumerate((-0.5, 0.0, 0.5)):
            S.streak((40, 32 + k * 2 - 2), (40 + math.cos(a) * 20, 32 + math.sin(a) * 20), 3, P["hv"], glow=0.8)
        S.star((40, 32), 9, 8, P["hv"], glow=1.5)

    def uyap(S):  # Uy Áp: +ST lên boss — đầu lâu dưới áp lực vàng
        p = P["hv"]
        for k in range(3):
            y = 10 + k * 7
            S.poly([(18, y), (32, y + 7), (46, y), (46, y + 3), (32, y + 10), (18, y + 3)], p, glow=0.8)
        _skull(S, (32, 44), 18, P["hv_earth"])

    def linhkhe(S):  # Linh Khế: linh thú +ST — hai linh hồn nối khế ước
        p = P["th_teal"]
        S.decal((32, 34), 24, P["th"], rot=0.2, runes=6, alpha=230)
        S.streak((16, 32), (48, 32), 3, p, tail=1.0, glow=1.0)
        S.orb((16, 32), 8, P["th"], glow=1.5)
        S.orb((48, 32), 8, p, glow=1.5)
        S.star((32, 32), 6, 6, p, glow=1.2)

    def linhthe(S):  # Linh Thể: linh thú +HP — bóng Sói Bóng + trái tim
        silhouette(S, "soi-bong", (30, 52), 34, P["th"])
        _heart(S, (46, 20), 9, P["kk"], glow=1.4)

    def linhho(S):  # Linh Hộ: linh thú che chở — khiên + 3 linh hồn xoay
        p = P["th_teal"]
        S.shield((32, 32), 13, P["th"], glow=1.3)
        for k in range(3):
            a = -math.pi / 2 + k * math.tau / 3
            S.orb((32 + math.cos(a) * 22, 32 + math.sin(a) * 22), 5.5, p, glow=1.3)
        S.ring((32, 32), 22, 1.6, p, squash=1.0, where="fx", alpha=200)

    def honluc(S):  # Hồn Lực: +ST bản thân — ngọn lửa linh hồn
        p = P["th"]
        S.poly([(32, 6), (42, 26), (46, 40), (40, 52), (32, 56), (24, 52), (18, 40), (22, 26)], p, glow=1.6)
        S.disc((32, 40), 9, P["th_teal"], glow=1.6)
        S.sparks((32, 40), 0.5, 10, 24, p, seed=7, up=True)

    def tab(S):  # icon tab "Bị động" trong bảng kỹ năng: 5 cầu màu 5 lớp quanh sao vàng
        S.ring((32, 32), 22, 3, P["hv"], squash=1.0, where="fx")
        for k, key in enumerate(("kk", "ts", "arcane", "hv_steel", "th")):
            a = -math.pi / 2 + k * math.tau / 5
            S.orb((32 + math.cos(a) * 22, 32 + math.sin(a) * 22), 5, P[key], glow=1.1)
        S.star((32, 32), 10, 8, P["hv"], glow=1.6)

    return {
        "pv-thietcot": ("kk", thietcot), "pv-kiemtam": ("kk", kiemtam), "pv-phankich": ("kk", phankich), "pv-chieny": ("kk_blood", chieny),
        "pv-ungmuc": ("ts_gold", ungmuc), "pv-sanmoi": ("ts", sanmoi), "pv-buocgio": ("ts", buocgio), "pv-tamdoc": ("ts_poison", tamdoc),
        "pv-minhtuong": ("arcane", minhtuong), "pv-nguyento": ("arcane", nguyento), "pv-doidao": ("arcane", doidao), "pv-hothe": ("arcane", hothe),
        "pv-kienthu": ("hv_steel", kienthu), "pv-ychisat": ("hv", ychisat), "pv-phanchan": ("hv_steel", phanchan), "pv-uyap": ("hv", uyap),
        "pv-linhkhe": ("th", linhkhe), "pv-linhthe": ("th", linhthe), "pv-linhho": ("th_teal", linhho), "pv-honluc": ("th", honluc),
        "pv-tab": ("hv", tab),
    }


CLASS = {"kiem-khach": ["thietcot", "kiemtam", "phankich", "chieny"], "tho-san": ["ungmuc", "sanmoi", "buocgio", "tamdoc"],
         "phap-su": ["minhtuong", "nguyento", "doidao", "hothe"], "ho-ve": ["kienthu", "ychisat", "phanchan", "uyap"],
         "trieu-hoi-su": ["linhkhe", "linhthe", "linhho", "honluc"]}
