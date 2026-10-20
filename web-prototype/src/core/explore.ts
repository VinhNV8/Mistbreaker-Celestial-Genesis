import type { TalentId } from '../data/talents';
import { CAMP_UPGRADE_COST, LUMBER_COST_GOLD, TORCH_MAX, TORCH_REGEN_SEC } from './config';
import type { Profile } from './profile';
import { shuffle, type Rng } from './rng';

export type TileEvent = 'camp' | 'resource' | 'nest' | 'relic' | 'survivor' | 'wonder';
export type TileStatus = 'fog' | 'revealed' | 'owned';

export interface TileState {
  id: number;
  /** Toạ độ lục giác dạng axial. */
  q: number;
  r: number;
  event: TileEvent;
  status: TileStatus;
}

export interface ActionResult {
  ok: boolean;
  message: string;
  exp?: number;
  /** Ổ quái: World phải sinh quái tinh anh; ô chỉ được chiếm khi hạ nó. */
  startNest?: boolean;
}

export const EVENT_INFO: Record<TileEvent, { name: string; icon: string; desc: string; color: string }> = {
  camp: { name: 'Trại Khai Giới', icon: '⛺', desc: 'Trung tâm lãnh địa của bạn.', color: '#c9a45c' },
  resource: {
    name: 'Rừng gỗ',
    icon: '🌲',
    desc: 'Xây Xưởng Gỗ để khai thác gỗ và vàng, kể cả khi offline (tối đa 12 giờ).',
    color: '#4f9a5b',
  },
  nest: { name: 'Ổ quái', icon: '💀', desc: 'Quái tinh anh canh giữ. Hạ nó để chiếm ô đất.', color: '#b8484f' },
  relic: { name: 'Di tích', icon: '📜', desc: 'Rương báu và một trang sách cốt truyện.', color: '#c08a3e' },
  survivor: { name: 'Người sống sót', icon: '🧑', desc: 'Gia nhập lãnh địa: +10% sản lượng.', color: '#5a8fd0' },
  wonder: { name: 'Suối Linh Khí', icon: '✨', desc: 'Kỳ quan: +10% EXP nhận được từ chiến đấu.', color: '#9b6be0' },
};

/** Lưới khai phá 10 ô của prototype: vòng 1 (6 ô) + 4 ô vòng 2, quanh Trại Khai Giới. */
const RING1: readonly [number, number][] = [
  [1, 0],
  [1, -1],
  [0, -1],
  [-1, 0],
  [-1, 1],
  [0, 1],
];
const RING2: readonly [number, number][] = [
  [2, 0],
  [-1, -1],
  [-2, 2],
  [1, 1],
];
const RING1_EVENTS: readonly TileEvent[] = ['resource', 'resource', 'resource', 'relic', 'survivor', 'nest'];
const RING2_EVENTS: readonly TileEvent[] = ['resource', 'nest', 'relic', 'wonder'];

const RELIC_LORE = [
  'Trang sách cũ: “Ngày trời nứt làm chín, Khai Giới Giả mạnh nhất đã đứng trước Bia Đá và vươn tay đoạt lấy ánh sáng…”',
  'Trang sách cũ: “Kẻ không mặt ấy không còn Thiên phú của riêng mình. Hắn sẽ quay lại, tìm mảnh linh hồn đã đánh mất.”',
];

export function createTiles(rng: Rng): TileState[] {
  const tiles: TileState[] = [{ id: 0, q: 0, r: 0, event: 'camp', status: 'owned' }];
  const ring1 = shuffle(RING1_EVENTS, rng);
  const ring2 = shuffle(RING2_EVENTS, rng);
  RING1.forEach(([q, r], i) => tiles.push({ id: tiles.length, q, r, event: ring1[i], status: 'fog' }));
  RING2.forEach(([q, r], i) => tiles.push({ id: tiles.length, q, r, event: ring2[i], status: 'fog' }));
  return tiles;
}

export function hexDistance(a: { q: number; r: number }, b: { q: number; r: number }): number {
  const dq = a.q - b.q;
  const dr = a.r - b.r;
  return (Math.abs(dq) + Math.abs(dr) + Math.abs(dq + dr)) / 2;
}

export function distanceToOwned(tiles: readonly TileState[], tile: TileState): number {
  let best = Infinity;
  for (const t of tiles) if (t.status === 'owned') best = Math.min(best, hexDistance(t, tile));
  return best;
}

export function ownedCount(tiles: readonly TileState[]): number {
  return tiles.filter((t) => t.event !== 'camp' && t.status === 'owned').length;
}

export function exploreTotal(tiles: readonly TileState[]): number {
  return tiles.filter((t) => t.event !== 'camp').length;
}

export function exploredRatio(tiles: readonly TileState[]): number {
  const total = exploreTotal(tiles);
  return total === 0 ? 0 : ownedCount(tiles) / total;
}

export function hasWonder(tiles: readonly TileState[]): boolean {
  return tiles.some((t) => t.event === 'wonder' && t.status === 'owned');
}

/** Thiên phú Mắt Ưng nhìn xuyên sương mù các ô cách lãnh địa tối đa 2 ô. */
export function isEventVisible(tiles: readonly TileState[], tile: TileState, talent: TalentId): boolean {
  if (tile.status !== 'fog') return true;
  return talent === 'mat-ung' && distanceToOwned(tiles, tile) <= 2;
}

/** Lý do không thể dùng Đuốc lên ô này, hoặc null nếu được phép. */
export function revealBlocker(p: Profile, tile: TileState): string | null {
  if (tile.status !== 'fog') return 'Ô đất đã được dọn sương.';
  if (distanceToOwned(p.tiles, tile) > 1) return 'Chỉ dọn được ô kề lãnh địa.';
  if (p.torches <= 0) return 'Hết Đuốc Khai Giới — đợi hồi hoặc hạ quái tinh anh.';
  return null;
}

function findTile(p: Profile, id: number): TileState | undefined {
  return p.tiles.find((t) => t.id === id);
}

export function revealTile(p: Profile, id: number): ActionResult {
  const tile = findTile(p, id);
  if (!tile) return { ok: false, message: 'Không tìm thấy ô đất.' };
  const blocker = revealBlocker(p, tile);
  if (blocker) return { ok: false, message: blocker };
  p.torches -= 1;
  tile.status = 'revealed';
  return { ok: true, message: `Sương mù tan: phát hiện ${EVENT_INFO[tile.event].name}.`, exp: 40 * p.level };
}

export function claimTile(p: Profile, id: number): ActionResult {
  const tile = findTile(p, id);
  if (!tile || tile.status !== 'revealed') return { ok: false, message: 'Ô đất này chưa thể chiếm.' };
  switch (tile.event) {
    case 'resource':
      if (p.gold < LUMBER_COST_GOLD) return { ok: false, message: `Cần ${LUMBER_COST_GOLD} vàng để xây Xưởng Gỗ.` };
      p.gold -= LUMBER_COST_GOLD;
      tile.status = 'owned';
      return { ok: true, message: 'Đã xây Xưởng Gỗ: gỗ và vàng sẽ chảy về lãnh địa.' };
    case 'relic': {
      const opened = p.tiles.filter((t) => t.event === 'relic' && t.status === 'owned').length;
      p.gold += 80;
      tile.status = 'owned';
      return { ok: true, message: `Mở rương: +80 vàng. ${RELIC_LORE[opened % RELIC_LORE.length]}`, exp: 150 };
    }
    case 'survivor':
      tile.status = 'owned';
      return { ok: true, message: 'Một người sống sót gia nhập Trại Khai Giới: +10% sản lượng.' };
    case 'wonder':
      tile.status = 'owned';
      return { ok: true, message: 'Chiếm Suối Linh Khí: +10% EXP từ chiến đấu.' };
    case 'nest':
      return { ok: true, message: 'Quái tinh anh xuất hiện phía trước! Hạ nó để chiếm Ổ quái.', startNest: true };
    case 'camp':
      return { ok: false, message: 'Đây đã là trại của bạn.' };
  }
}

export function conquerTile(p: Profile, id: number): boolean {
  const tile = findTile(p, id);
  if (!tile || tile.status === 'owned') return false;
  tile.status = 'owned';
  return true;
}

export function productionPerMinute(p: Profile): { gold: number; wood: number } {
  const lumber = p.tiles.filter((t) => t.event === 'resource' && t.status === 'owned').length;
  const survivors = p.tiles.filter((t) => t.event === 'survivor' && t.status === 'owned').length;
  const mult = 1 + 0.1 * survivors + (p.campLevel > 1 ? 0.2 : 0);
  return { gold: lumber * 3 * mult, wood: lumber * 6 * mult };
}

export function tickProduction(p: Profile, seconds: number): { gold: number; wood: number } {
  const rate = productionPerMinute(p);
  const gold = (rate.gold * seconds) / 60;
  const wood = (rate.wood * seconds) / 60;
  p.gold += gold;
  p.wood += wood;
  return { gold, wood };
}

/** Hồi Đuốc theo thời gian; trả về số Đuốc vừa hồi. */
export function regenTorches(p: Profile, seconds: number): number {
  if (p.torches >= TORCH_MAX) {
    p.torchTimer = 0;
    return 0;
  }
  p.torchTimer += seconds;
  const gained = Math.min(TORCH_MAX - p.torches, Math.floor(p.torchTimer / TORCH_REGEN_SEC));
  p.torches += gained;
  p.torchTimer = p.torches >= TORCH_MAX ? 0 : p.torchTimer - gained * TORCH_REGEN_SEC;
  return gained;
}

export function upgradeCamp(p: Profile): ActionResult {
  if (p.campLevel > 1) return { ok: false, message: 'Trại đã là Thôn (cấp tối đa của prototype).' };
  if (p.gold < CAMP_UPGRADE_COST.gold || p.wood < CAMP_UPGRADE_COST.wood) {
    return { ok: false, message: `Cần ${CAMP_UPGRADE_COST.gold} vàng và ${CAMP_UPGRADE_COST.wood} gỗ.` };
  }
  p.gold -= CAMP_UPGRADE_COST.gold;
  p.wood -= CAMP_UPGRADE_COST.wood;
  p.campLevel = 2;
  return { ok: true, message: 'Trại Khai Giới nâng cấp thành Thôn: +20% sản lượng.' };
}
