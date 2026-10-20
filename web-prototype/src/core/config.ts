/** Hằng số cân bằng của bản prototype. Chỗ nào lệch so với tài liệu kịch bản đều có ghi chú. */
export const MAX_LEVEL = 100;
export const POINTS_PER_LEVEL = 5;
export const FREE_RESPEC_LEVEL = 30;

export const TORCH_MAX = 10;
/** Tài liệu: hồi 1 Đuốc / 20 phút. Prototype rút xuống 2 phút để test nhanh. */
export const TORCH_REGEN_SEC = 120;
export const START_TORCHES = 3;

/** Thu hoạch offline tối đa 12 giờ (tài liệu mục 7). */
export const OFFLINE_CAP_SEC = 12 * 3600;

/** Điều kiện mở map/boss: đủ cấp + khai phá ít nhất 60% ô đất (tài liệu mục 6). */
export const BOSS_LEVEL_REQ = 5;
export const EXPLORE_REQ = 0.6;

export const MAX_FIELD_MOBS = 16;
export const LUMBER_COST_GOLD = 30;
export const CAMP_UPGRADE_COST = { gold: 100, wood: 100 };
