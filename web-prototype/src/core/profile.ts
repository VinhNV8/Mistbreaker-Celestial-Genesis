import type { TalentId } from '../data/talents';
import { START_TORCHES } from './config';
import { createTiles, type TileState } from './explore';
import type { Rng } from './rng';
import type { StatPoints } from './stats';

export const PROFILE_VERSION = 1;

/** Tiến trình được lưu lại giữa các lần chơi. */
export interface Profile {
  version: number;
  talent: TalentId;
  level: number;
  exp: number;
  points: StatPoints;
  unspent: number;
  gold: number;
  wood: number;
  torches: number;
  torchTimer: number;
  tiles: TileState[];
  campLevel: number;
  bossDefeated: boolean;
  kills: number;
  playSeconds: number;
  /** Thời điểm (ms) lần cuối lưu, dùng để tính thu hoạch offline. */
  lastSeen: number;
}

export function newProfile(talent: TalentId, rng: Rng, now: number): Profile {
  return {
    version: PROFILE_VERSION,
    talent,
    level: 1,
    exp: 0,
    points: { str: 0, agi: 0, vit: 0 },
    unspent: 0,
    gold: 0,
    wood: 0,
    torches: START_TORCHES,
    torchTimer: 0,
    tiles: createTiles(rng),
    campLevel: 1,
    bossDefeated: false,
    kills: 0,
    playSeconds: 0,
    lastSeen: now,
  };
}
