extends RefCounted
## CR-02: gift code của nhà phát hành ở Lễ Thức Tỉnh (03-mvp-spec Phụ lục A).
## Mã TPKG-XXXX-XXXX-XXXX = 8 ký tự seri + 4 ký tự kiểm tra (20 bit đầu SHA-256(SECRET + seri)), Base32 Crockford.
## Cùng thuật toán với tools/giftcode.py — sửa ở đây thì sửa cả hai.
## Bản offline: khoá nằm trong game (CR-02.2); bản phát hành phải kiểm ở server (KT-10).

const PREFIX := "TPKG"
const SECRET := "ThienPhuKhaiGioi::gift::2026-C1"
const ALPHABET := "0123456789ABCDEFGHJKMNPQRSTVWXYZ"
const SERIAL_LEN := 8
const CHECK_LEN := 4
## Nơi lưu mã đã dùng trên máy (không nằm trong save, xoá save không dùng lại được). Test đổi đường dẫn này.
static var store_path := "user://redeemed_codes.cfg"


## Bỏ gạch/khoảng trắng, viết hoa, sửa ký tự dễ nhầm (O→0, I/L→1), bỏ tiền tố TPKG.
static func normalize(raw: String) -> String:
	var s := raw.strip_edges().to_upper().replace("-", "").replace(" ", "")
	s = s.replace("O", "0").replace("I", "1").replace("L", "1")
	if s.begins_with(PREFIX):
		s = s.substr(PREFIX.length())
	return s


static func check_of(serial: String) -> String:
	var h := (SECRET + serial).sha256_buffer()
	var bits: int = (int(h[0]) << 12) | (int(h[1]) << 4) | (int(h[2]) >> 4)
	var out := ""
	for i in CHECK_LEN:
		out = ALPHABET[bits & 31] + out
		bits >>= 5
	return out


## Sinh mã từ seri (dùng cho test; nhà phát hành dùng tools/giftcode.py).
## Seri được chuẩn hoá giống lúc nhập (O→0, I/L→1) để mã sinh ra luôn kiểm được.
static func make(serial: String) -> String:
	serial = normalize(serial).substr(0, SERIAL_LEN)
	var c := serial + check_of(serial)
	return "%s-%s-%s-%s" % [PREFIX, c.substr(0, 4), c.substr(4, 4), c.substr(8, 4)]


static func _valid_chars(s: String) -> bool:
	for ch in s:
		if not ALPHABET.contains(ch):
			return false
	return true


static func is_redeemed(serial: String) -> bool:
	var cf := ConfigFile.new()
	if cf.load(store_path) != OK:
		return false
	return cf.has_section_key("codes", serial)


static func mark_redeemed(serial: String) -> void:
	var cf := ConfigFile.new()
	cf.load(store_path)
	cf.set_value("codes", serial, Time.get_unix_time_from_system())
	cf.save(store_path)


## Kiểm mã. Trả về {ok, message, serial}.
static func validate(raw: String) -> Dictionary:
	var s := normalize(raw)
	if s.is_empty():
		return {"ok": false, "message": "Hãy nhập gift code.", "serial": ""}
	if s.length() != SERIAL_LEN + CHECK_LEN or not _valid_chars(s):
		return {"ok": false, "message": "Sai định dạng — mã có dạng TPKG-XXXX-XXXX-XXXX.", "serial": ""}
	var serial := s.substr(0, SERIAL_LEN)
	if s.substr(SERIAL_LEN) != check_of(serial):
		return {"ok": false, "message": "Mã không tồn tại. Kiểm tra lại từng ký tự.", "serial": ""}
	if is_redeemed(serial):
		return {"ok": false, "message": "Mã này đã được dùng trên máy này.", "serial": serial}
	return {"ok": true, "message": "Mã hợp lệ!", "serial": serial}
