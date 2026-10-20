import { CAMP_UPGRADE_COST, EXPLORE_REQ, FREE_RESPEC_LEVEL, LUMBER_COST_GOLD } from '../core/config';
import {
  EVENT_INFO,
  exploreTotal,
  isEventVisible,
  ownedCount,
  productionPerMinute,
  revealBlocker,
  type TileState,
} from '../core/explore';
import type { StatKey } from '../core/stats';
import type { World } from '../core/world';
import { RANK_COLOR } from '../data/talents';

const fmt = (n: number): string => Math.floor(n).toLocaleString('vi-VN');

abstract class Modal {
  protected readonly el: HTMLDivElement;
  protected world: World | null = null;

  constructor(root: HTMLElement, className: string) {
    this.el = document.createElement('div');
    this.el.className = `modal hidden ${className}`;
    root.appendChild(this.el);
    this.el.addEventListener('click', (ev) => {
      if (ev.target === this.el) return this.close();
      const btn = (ev.target as HTMLElement).closest<HTMLElement>('[data-a]');
      if (btn && !btn.hasAttribute('disabled') && this.world) this.onAction(btn.dataset.a ?? '', btn.dataset.v ?? '');
    });
  }

  get isOpen(): boolean {
    return !this.el.classList.contains('hidden');
  }

  open(world: World): void {
    this.world = world;
    this.render();
    this.el.classList.remove('hidden');
  }

  close(): void {
    this.el.classList.add('hidden');
  }

  toggle(world: World): void {
    if (this.isOpen) this.close();
    else this.open(world);
  }

  protected abstract onAction(action: string, value: string): void;
  protected abstract render(): void;
}

const STAT_ROWS: { key: StatKey; name: string; effect: string }[] = [
  { key: 'str', name: 'Sức mạnh (STR)', effect: '+2 Tấn công' },
  { key: 'agi', name: 'Nhanh nhẹn (AGI)', effect: '+1% tốc đánh, +0,5% chí mạng' },
  { key: 'vit', name: 'Thể lực (VIT)', effect: '+12 HP, +0,5 Phòng thủ' },
];

export class StatsPanel extends Modal {
  constructor(root: HTMLElement) {
    super(root, 'stats-modal');
  }

  protected onAction(action: string, value: string): void {
    const w = this.world;
    if (!w) return;
    if (action === 'close') return this.close();
    if (action === 'add') w.allocate(value as StatKey);
    if (action === 'respec') w.respec();
    this.render();
  }

  protected render(): void {
    const w = this.world;
    if (!w) return;
    const p = w.profile;
    const s = w.stats;
    const t = w.talent;
    const rows = STAT_ROWS.map(
      (r) => `
      <div class="stat-row">
        <div><b>${r.name}</b><small>${r.effect}</small></div>
        <span class="stat-val">${p.points[r.key]}</span>
        <button class="btn small" data-a="add" data-v="${r.key}" ${p.unspent > 0 ? '' : 'disabled'}>+</button>
      </div>`,
    ).join('');
    const canRespec = p.level < FREE_RESPEC_LEVEL && p.points.str + p.points.agi + p.points.vit > 0;
    this.el.innerHTML = `
      <div class="modal-box">
        <header><h3>Kiếm Khách · Cấp ${p.level}</h3><button class="btn ghost" data-a="close">Đóng (C)</button></header>
        <div class="talent-card" style="--rank:${RANK_COLOR[t.rank]}">
          <span class="rank">${t.rank}</span>
          <div><b>${t.name}</b> <small>· ${t.group}</small><p>${t.description}</p></div>
        </div>
        <p class="muted">Điểm tiềm năng còn lại: <b>${p.unspent}</b></p>
        ${rows}
        <div class="derived">
          <span>HP <b>${s.maxHp}</b></span>
          <span>Tấn công <b>${s.atk.toFixed(0)}</b></span>
          <span>Phòng thủ <b>${s.def.toFixed(1)}</b></span>
          <span>Tốc đánh <b>${Math.round(s.atkSpeed * 100)}%</b></span>
          <span>Chí mạng <b>${(s.crit * 100).toFixed(1)}%</b></span>
        </div>
        <button class="btn ghost" data-a="respec" ${canRespec ? '' : 'disabled'}>Tẩy điểm (miễn phí trước cấp ${FREE_RESPEC_LEVEL})</button>
      </div>`;
  }
}

const HEX = 46;
const SQRT3 = Math.sqrt(3);

function hexCenter(t: TileState): [number, number] {
  return [220 + HEX * SQRT3 * (t.q + t.r / 2), 130 + HEX * 1.5 * t.r];
}

function hexPoints(cx: number, cy: number, size: number): string {
  const pts: string[] = [];
  for (let i = 0; i < 6; i++) {
    const a = (Math.PI / 180) * (60 * i - 30);
    pts.push(`${(cx + size * Math.cos(a)).toFixed(1)},${(cy + size * Math.sin(a)).toFixed(1)}`);
  }
  return pts.join(' ');
}

export class MapPanel extends Modal {
  private selected = 0;

  constructor(
    root: HTMLElement,
    private readonly onNestStarted: () => void,
  ) {
    super(root, 'map-modal');
  }

  protected onAction(action: string, value: string): void {
    const w = this.world;
    if (!w) return;
    switch (action) {
      case 'close':
        return this.close();
      case 'select':
        this.selected = Number(value);
        break;
      case 'reveal':
        w.revealTile(this.selected);
        break;
      case 'claim': {
        const res = w.claimTile(this.selected);
        if (res.ok && res.startNest) {
          this.close();
          this.onNestStarted();
          return;
        }
        break;
      }
      case 'camp':
        w.upgradeCamp();
        break;
    }
    this.render();
  }

  protected render(): void {
    const w = this.world;
    if (!w) return;
    const p = w.profile;
    const tiles = p.tiles;
    const sel = tiles.find((t) => t.id === this.selected) ?? tiles[0];

    const hexes = tiles
      .map((t) => {
        const [cx, cy] = hexCenter(t);
        const info = EVENT_INFO[t.event];
        const seen = isEventVisible(tiles, t, p.talent);
        const revealable = t.status === 'fog' && revealBlocker(p, t) === null;
        const cls = [`hex`, t.status, revealable ? 'revealable' : '', t.id === sel.id ? 'selected' : ''].join(' ');
        const fill = t.status === 'fog' ? (revealable ? '#3a4152' : '#232731') : info.color;
        const icon = seen ? info.icon : '☁';
        return `
          <g class="${cls}" data-a="select" data-v="${t.id}">
            <polygon points="${hexPoints(cx, cy, HEX - 3)}" fill="${fill}" />
            <text x="${cx}" y="${cy + 8}" text-anchor="middle" class="${t.status === 'fog' && seen ? 'ghost-icon' : ''}">${icon}</text>
          </g>`;
      })
      .join('');

    const owned = ownedCount(tiles);
    const total = exploreTotal(tiles);
    const rate = productionPerMinute(p);
    const campName = p.campLevel > 1 ? 'Thôn' : 'Trại Khai Giới';

    this.el.innerHTML = `
      <div class="modal-box wide">
        <header>
          <h3>Bản đồ khai phá · Rừng Sương</h3>
          <button class="btn ghost" data-a="close">Đóng (M)</button>
        </header>
        <div class="map-summary">
          <span>Khai phá <b>${owned}/${total}</b> ô (${Math.round((owned / total) * 100)}% · cần ${EXPLORE_REQ * 100}% để mở hang Sói Chúa)</span>
          <span>🔥 Đuốc <b>${p.torches}</b> · 💰 <b>${fmt(p.gold)}</b> · 🪵 <b>${fmt(p.wood)}</b></span>
          <span>Sản lượng: +${rate.gold.toFixed(1)} vàng, +${rate.wood.toFixed(1)} gỗ / phút</span>
        </div>
        <div class="map-body">
          <svg viewBox="0 0 440 330" class="hexmap">${hexes}</svg>
          <aside class="tile-info">${this.tileInfo(sel)}
            <hr />
            <p class="muted">${campName} — ${p.campLevel > 1 ? 'đã nâng cấp (+20% sản lượng).' : `nâng lên Thôn: ${CAMP_UPGRADE_COST.gold} vàng + ${CAMP_UPGRADE_COST.wood} gỗ, +20% sản lượng.`}</p>
            ${p.campLevel > 1 ? '' : '<button class="btn small" data-a="camp">Nâng cấp trại</button>'}
          </aside>
        </div>
      </div>`;
  }

  private tileInfo(t: TileState): string {
    const w = this.world;
    if (!w) return '';
    const p = w.profile;
    const info = EVENT_INFO[t.event];
    const seen = isEventVisible(p.tiles, t, p.talent);

    if (t.status === 'fog') {
      const blocker = revealBlocker(p, t);
      const hint = seen ? `<p class="eagle">Mắt Ưng nhìn thấy: <b>${info.icon} ${info.name}</b></p>` : '';
      return `
        <h4>☁ Ô đất bị sương mù che</h4>
        ${hint}
        <p class="muted">Dùng 1 Đuốc Khai Giới để dọn sương. Mỗi ô dọn được cho EXP.</p>
        <button class="btn primary" data-a="reveal" ${blocker ? 'disabled' : ''}>Dùng Đuốc (còn ${p.torches})</button>
        ${blocker ? `<p class="warn">${blocker}</p>` : ''}`;
    }

    const status = t.status === 'owned' ? '<span class="tag good">Đã thuộc lãnh địa</span>' : '<span class="tag">Đã dọn sương</span>';
    let action = '';
    if (t.status === 'revealed') {
      const label: Record<string, string> = {
        resource: `Xây Xưởng Gỗ (${LUMBER_COST_GOLD} vàng)`,
        nest: 'Chinh phục (gọi quái tinh anh ra)',
        relic: 'Mở rương di tích',
        survivor: 'Mời gia nhập lãnh địa',
        wonder: 'Chiếm Kỳ quan',
      };
      const nestActive = w.enemies.some((e) => e.nestTileId === t.id);
      action = nestActive
        ? '<p class="warn">Quái tinh anh đang chờ bạn ngoài Rừng Sương.</p>'
        : `<button class="btn primary" data-a="claim">${label[t.event] ?? 'Chiếm'}</button>`;
    }
    return `<h4>${info.icon} ${info.name}</h4>${status}<p>${info.desc}</p>${action}`;
  }
}
