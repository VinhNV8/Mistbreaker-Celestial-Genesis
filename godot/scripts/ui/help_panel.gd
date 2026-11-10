extends "res://scripts/ui/modal.gd"
## UI-17 (Spec_Notes đợt 7): bảng Trợ giúp (F1 / H, hoặc nút trong menu Esc) — toàn bộ phím tắt và vài mẹo chơi.
## Thay dòng "M: Khai phá · N: Lục địa…" trước đây nằm trong khung nhiệm vụ.

const Screens = preload("res://scripts/ui/screens.gd")

const TIPS := [
	"Cổng dịch chuyển: bước vào cổng vàng ở rìa phải để sang map sau, cổng xanh ở rìa trái để về map trước. Cổng xám ghi điều kiện còn thiếu.",
	"Cổng Dịch Chuyển (tím) trong vùng an toàn: về nhanh các map đã từng tới.",
	"Cửa hang (cam) ở mỗi map: vào dọn quái, hạ Chúa Hang để nhận đồ Xanh dương trở lên. Hang mở lại sau 20 phút.",
	"Bảng tên quái: Thường · Tinh anh · Thủ lĩnh · Hiếm · Chúa Hang. Cấp đỏ = mạnh hơn bạn từ 5 cấp.",
	"Cổng dungeon hạng E → S thỉnh thoảng mở trên map đã tới (xem bản đồ lục địa, phím N), tồn tại 2 giờ chơi. Hạ Chúa Cổng: EXP, đồ, Tinh Hoa theo hạng.",
	"Quái bị đánh từ xa sẽ lao tới nhanh hơn — đừng đứng yên khi thả diều.",
	"Đảo bay: rơi khỏi mép về Đá Neo gần nhất, mất 10% HP. Lông Vũ Gió (Q) giúp lướt qua khe.",
	"Có điểm tiềm năng: huy hiệu \"+N\" trên khung nhân vật nhấp nháy — nhấn C để cộng.",
	"Túi đồ (I): rê chuột lên món rồi bấm S bán, D phân rã, L khoá (món khoá không bị bán / phân rã / tự xử lý). Tab Tự động: tự bán hoặc phân rã đồ khi nhặt theo phẩm chất; tab Mua lại: chuộc 10 món vừa bán.",
	"Kỹ năng mới tự lắp vào ô trống. Đổi kỹ năng: phím U, kéo kỹ năng vào hàng Thanh kỹ năng, hoặc chuột phải một ô trên thanh. Phím X đổi Bộ 1 / Bộ 2.",
	"Tăng Lực chiến ngoài cường hoá (Lò Rèn, phím R): khảm ngọc Ngũ Hành (từ chương 2), tẩy luyện dòng phụ (chương 3), thăng phẩm (chương 4), luyện cấp đồ Cam / bộ, thức tỉnh (sau chuyển chức 3), Bảo Giám. Bấm huy hiệu Lực chiến để xem việc làm được ngay.",
]


func _render(content: VBoxContainer) -> void:
	content.custom_minimum_size.x = 760
	_header(content, "Trợ giúp", "Đóng (F1)")
	var body := UiTheme.hbox(28)
	var left := UiTheme.vbox(6)
	left.add_child(UiTheme.label("PHÍM TẮT", "Eyebrow"))
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 16)
	grid.add_theme_constant_override("v_separation", 5)
	for c in Screens.CONTROLS:
		var k := UiTheme.label(c[0])
		k.add_theme_font_override("font", UiTheme.bold_font())
		k.add_theme_color_override("font_color", UiTheme.GOLD)
		grid.add_child(k)
		grid.add_child(UiTheme.label(c[1], "Muted", 300))
	left.add_child(grid)
	body.add_child(left)
	var right := UiTheme.vbox(8)
	right.add_child(UiTheme.label("MẸO", "Eyebrow"))
	for t in TIPS:
		right.add_child(UiTheme.label("◆ " + t, "Muted", 300))
	body.add_child(right)
	content.add_child(body)
