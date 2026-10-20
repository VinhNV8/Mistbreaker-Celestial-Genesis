import { OFFLINE_CAP_SEC } from './config';
import { regenTorches, tickProduction } from './explore';
import { PROFILE_VERSION, type Profile } from './profile';

const SAVE_KEY = 'thien-phu-khai-gioi/save';

export function loadProfile(): Profile | null {
  try {
    const raw = localStorage.getItem(SAVE_KEY);
    if (!raw) return null;
    const data = JSON.parse(raw) as Profile;
    return data.version === PROFILE_VERSION ? data : null;
  } catch {
    return null;
  }
}

export function saveProfile(p: Profile): void {
  try {
    localStorage.setItem(SAVE_KEY, JSON.stringify(p));
  } catch {
    // Trình duyệt chặn lưu trữ (chế độ ẩn danh…): game vẫn chạy, chỉ không lưu được.
  }
}

export function clearSave(): void {
  try {
    localStorage.removeItem(SAVE_KEY);
  } catch {
    // bỏ qua
  }
}

export interface OfflineSummary {
  seconds: number;
  gold: number;
  wood: number;
  torches: number;
}

/** Lãnh địa tiếp tục sản xuất khi người chơi vắng mặt, tối đa 12 giờ. */
export function applyOffline(p: Profile, now: number): OfflineSummary {
  const seconds = Math.min(OFFLINE_CAP_SEC, Math.max(0, (now - p.lastSeen) / 1000));
  const { gold, wood } = tickProduction(p, seconds);
  const torches = regenTorches(p, seconds);
  p.lastSeen = now;
  return { seconds, gold, wood, torches };
}
