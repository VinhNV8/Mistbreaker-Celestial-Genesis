import { RANK_WEIGHT, TALENTS, rankIndex, type TalentDef } from '../data/talents';
import { pickWeighted, type Rng } from './rng';

export const MAX_REROLLS = 3;
const MAX_ROLLS = MAX_REROLLS + 1;

/**
 * Lễ Thức Tỉnh: 1 lần quay + 3 lần quay lại miễn phí; người chơi chọn bất kỳ kết quả nào.
 * Bảo hiểm: nếu cả 4 lần đều dưới hạng B, lần cuối được nâng lên hạng B.
 */
export class Awakening {
  readonly rolls: TalentDef[] = [];

  constructor(
    private readonly rng: Rng,
    private readonly pool: readonly TalentDef[] = TALENTS,
  ) {}

  get canRoll(): boolean {
    return this.rolls.length < MAX_ROLLS;
  }

  get rerollsLeft(): number {
    return Math.min(MAX_REROLLS, MAX_ROLLS - this.rolls.length);
  }

  roll(): TalentDef {
    if (!this.canRoll) throw new Error('Đã hết lượt quay Thiên phú');
    let talent = pickWeighted(this.pool, (t) => RANK_WEIGHT[t.rank], this.rng);
    const minRank = rankIndex('B');
    const isLast = this.rolls.length === MAX_ROLLS - 1;
    const allBelow = this.rolls.every((t) => rankIndex(t.rank) < minRank);
    if (isLast && allBelow && rankIndex(talent.rank) < minRank) {
      const rankB = this.pool.filter((t) => t.rank === 'B');
      if (rankB.length > 0) talent = pickWeighted(rankB, () => 1, this.rng);
    }
    this.rolls.push(talent);
    return talent;
  }
}
