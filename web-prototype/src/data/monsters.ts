export type MonsterKind = 'wolf' | 'mushroom' | 'wisp' | 'boss';
export type MonsterAttack = 'melee' | 'spore';

export interface MonsterDef {
  name: string;
  hp: number;
  atk: number;
  def: number;
  speed: number;
  radius: number;
  /** Tầm đánh tính từ mép thân quái. */
  range: number;
  /** Thời gian vung đòn (báo hiệu) trước khi gây sát thương — cửa sổ để người chơi né. */
  windup: number;
  recover: number;
  attack: MonsterAttack;
  color: string;
}

/** Chỉ số gốc ở cấp 1; quái thường được nhân theo cấp khi sinh ra (xem World.spawnEnemy). */
export const MONSTERS: Record<MonsterKind, MonsterDef> = {
  wolf: {
    name: 'Sói Sương',
    hp: 40,
    atk: 8,
    def: 3,
    speed: 150,
    radius: 16,
    range: 34,
    windup: 0.45,
    recover: 0.6,
    attack: 'melee',
    color: '#8fa3b8',
  },
  mushroom: {
    name: 'Nấm Độc',
    hp: 55,
    atk: 7,
    def: 4,
    speed: 70,
    radius: 18,
    range: 240,
    windup: 0.7,
    recover: 1.3,
    attack: 'spore',
    color: '#b86fd6',
  },
  wisp: {
    name: 'Tinh Linh Sương',
    hp: 70,
    atk: 12,
    def: 6,
    speed: 115,
    radius: 15,
    range: 30,
    windup: 0.35,
    recover: 0.5,
    attack: 'melee',
    color: '#9de0e6',
  },
  boss: {
    name: 'Sói Chúa Hư Vô',
    hp: 3600,
    atk: 27,
    def: 12,
    speed: 175,
    radius: 40,
    range: 58,
    windup: 0.55,
    recover: 0.8,
    attack: 'melee',
    color: '#6a5a92',
  },
};
