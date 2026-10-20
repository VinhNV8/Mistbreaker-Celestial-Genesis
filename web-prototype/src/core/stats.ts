import type { TalentId } from '../data/talents';

export interface StatPoints {
  str: number;
  agi: number;
  vit: number;
}

export type StatKey = keyof StatPoints;

export interface DerivedStats {
  maxHp: number;
  atk: number;
  def: number;
  /** Hệ số nhân tốc đánh, 1 = gốc. */
  atkSpeed: number;
  crit: number;
  moveSpeed: number;
}

export function deriveStats(level: number, pts: StatPoints, talent: TalentId): DerivedStats {
  const lv = level - 1;
  return {
    maxHp: Math.round(100 + lv * 15 + pts.vit * 12),
    atk: 10 + lv * 2 + pts.str * 2,
    def: 5 + lv * 1.5 + pts.vit * 0.5,
    atkSpeed: 1 + pts.agi * 0.01 + (talent === 'tay-nhanh' ? 0.05 : 0),
    crit: Math.min(0.6, 0.05 + pts.agi * 0.005 + (talent === 'mat-ung' ? 0.1 : 0)),
    moveSpeed: 230,
  };
}
