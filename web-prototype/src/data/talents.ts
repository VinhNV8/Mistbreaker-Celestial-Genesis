export type Rank = 'F' | 'C' | 'B' | 'A' | 'S' | 'SS' | 'SSS';

export const RANK_ORDER: readonly Rank[] = ['F', 'C', 'B', 'A', 'S', 'SS', 'SSS'];

/** Tỉ lệ quay theo tài liệu kịch bản (mục 3 — Độ hiếm). */
export const RANK_WEIGHT: Record<Rank, number> = { F: 30, C: 28, B: 22, A: 13, S: 5, SS: 1.8, SSS: 0.2 };

export const RANK_COLOR: Record<Rank, string> = {
  F: '#9aa0a6',
  C: '#f1f3f4',
  B: '#5bd16a',
  A: '#4a9df8',
  S: '#b36bff',
  SS: '#ffc940',
  SSS: '#ff5470',
};

export function rankIndex(rank: Rank): number {
  return RANK_ORDER.indexOf(rank);
}

export type TalentId = 'tay-nhanh' | 'huyet-chien' | 'kiem-tam' | 'mat-ung' | 'thoi-gian-ngung-dong';

export interface TalentDef {
  id: TalentId;
  name: string;
  rank: Rank;
  group: string;
  description: string;
  /** Có kỹ năng chủ động (phím L) hay chỉ bị động. */
  active: boolean;
}

/** 5 Thiên phú của bản prototype, lấy từ danh sách 20 Thiên phú mẫu trong tài liệu. */
export const TALENTS: readonly TalentDef[] = [
  {
    id: 'tay-nhanh',
    name: 'Tay Nhanh',
    rank: 'F',
    group: 'Chiến đấu',
    description: '+5% tốc đánh.',
    active: false,
  },
  {
    id: 'huyet-chien',
    name: 'Huyết Chiến',
    rank: 'C',
    group: 'Chiến đấu',
    description: 'Khi HP dưới 30%: +20% sát thương.',
    active: false,
  },
  {
    id: 'kiem-tam',
    name: 'Kiếm Tâm',
    rank: 'B',
    group: 'Chiến đấu',
    description: 'Mỗi đòn chém thứ 5 gây sát thương chém kép.',
    active: false,
  },
  {
    id: 'mat-ung',
    name: 'Mắt Ưng',
    rank: 'A',
    group: 'Khai phá',
    description: 'Nhìn xuyên sương mù 2 ô trên bản đồ khai phá; thấy điểm yếu của quái (+10% chí mạng).',
    active: false,
  },
  {
    id: 'thoi-gian-ngung-dong',
    name: 'Thời Gian Ngưng Đọng',
    rank: 'S',
    group: 'Điều khiển',
    description: 'Kỹ năng chủ động (phím L): ngưng thời gian của quái 3 giây, hồi chiêu 90 giây.',
    active: true,
  },
];

export function getTalent(id: TalentId): TalentDef {
  const talent = TALENTS.find((t) => t.id === id);
  if (!talent) throw new Error(`Không có Thiên phú: ${id}`);
  return talent;
}
