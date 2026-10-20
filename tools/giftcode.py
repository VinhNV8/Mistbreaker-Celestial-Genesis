"""CR-02 (GC-07): sinh gift code cho nhà phát hành.

    python tools/giftcode.py 100              # 100 mã, đợt "default"
    python tools/giftcode.py 500 ra-mat       # 500 mã, ghi tools/giftcode_out/ra-mat.csv
    python tools/giftcode.py --check TPKG-XXXX-XXXX-XXXX

Thuật toán giống hệt godot/scripts/core/gift_code.gd (sửa một bên phải sửa cả hai):
mã = TPKG + 8 ký tự seri + 4 ký tự kiểm tra (20 bit đầu SHA-256(SECRET + seri)), Base32 Crockford.
Mỗi mã dùng 1 lần trên mỗi máy (bản offline) — xem 03-mvp-spec CR-02.2.
"""
import csv
import hashlib
import os
import secrets
import sys

PREFIX = "TPKG"
SECRET = "ThienPhuKhaiGioi::gift::2026-C1"
ALPHABET = "0123456789ABCDEFGHJKMNPQRSTVWXYZ"
OUT_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "giftcode_out")


def check_of(serial: str) -> str:
    h = hashlib.sha256((SECRET + serial).encode("utf-8")).digest()
    bits = (h[0] << 12) | (h[1] << 4) | (h[2] >> 4)
    out = ""
    for _ in range(4):
        out = ALPHABET[bits & 31] + out
        bits >>= 5
    return out


def make(serial: str) -> str:
    c = serial + check_of(serial)
    return "%s-%s-%s-%s" % (PREFIX, c[0:4], c[4:8], c[8:12])


def normalize(raw: str) -> str:
    s = raw.strip().upper().replace("-", "").replace(" ", "").replace("O", "0").replace("I", "1").replace("L", "1")
    return s[len(PREFIX):] if s.startswith(PREFIX) else s


def is_valid(raw: str) -> bool:
    s = normalize(raw)
    return len(s) == 12 and all(ch in ALPHABET for ch in s) and s[8:] == check_of(s[:8])


def main() -> None:
    args = sys.argv[1:]
    if args[:1] == ["--check"]:
        for code in args[1:]:
            print(code, "hợp lệ" if is_valid(code) else "KHÔNG hợp lệ")
        return
    count = int(args[0]) if args else 10
    batch = args[1] if len(args) > 1 else "default"
    seen = set()
    codes = []
    while len(codes) < count:
        serial = "".join(secrets.choice(ALPHABET) for _ in range(8))
        if serial in seen:
            continue
        seen.add(serial)
        codes.append(make(serial))
    os.makedirs(OUT_DIR, exist_ok=True)
    path = os.path.join(OUT_DIR, batch + ".csv")
    with open(path, "w", encoding="utf-8", newline="") as f:
        w = csv.writer(f)
        w.writerow(["code", "batch"])
        for c in codes:
            w.writerow([c, batch])
    for c in codes[:20]:
        print(c)
    if count > 20:
        print("… và %d mã nữa" % (count - 20))
    print("Đã ghi %d mã vào %s" % (count, path))


if __name__ == "__main__":
    main()
