extends RefCounted
## Hằng số cân bằng của game. Chỗ nào lệch so với tài liệu kịch bản đều có ghi chú.

const MAX_LEVEL := 100
const POINTS_PER_LEVEL := 5
const FREE_RESPEC_LEVEL := 30

const TORCH_MAX := 10
## Tài liệu: hồi 1 Đuốc / 20 phút. Tạm rút xuống 2 phút để test nhanh (01-requirement-spec mục 5).
const TORCH_REGEN_SEC := 120.0
const START_TORCHES := 3

## Thu hoạch offline tối đa 12 giờ (tài liệu mục 7).
const OFFLINE_CAP_SEC := 12.0 * 3600.0

## Điều kiện mở hang boss: đủ cấp + khai phá ít nhất 60% ô đất (tài liệu mục 6).
const BOSS_LEVEL_REQ := 5
const EXPLORE_REQ := 0.6
## C1-21: lưới vùng 1 thành 40 ô; điều kiện vào hang giữ nguyên số ô như trước (6 ô = 60% của 10 ô Bìa Rừng).
const BOSS_TILES_REQ := 6
## C1-23: boss hiếm xuất hiện 2 lần mỗi ngày (kịch bản mục 5) = mỗi 12 giờ thực.
const RARE_BOSS_PERIOD := 12.0 * 3600.0

const MAX_FIELD_MOBS := 16
const LUMBER_COST_GOLD := 30
const CAMP_UPGRADE_GOLD := 100
const CAMP_UPGRADE_WOOD := 100
