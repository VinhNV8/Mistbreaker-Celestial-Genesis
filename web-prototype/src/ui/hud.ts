import { BOSS_LEVEL_REQ, EXPLORE_REQ, TORCH_MAX, TORCH_REGEN_SEC } from '../core/config';
import { exploreTotal, ownedCount } from '../core/explore';
import { comboExpMultiplier, expToNext } from '../core/formulas';
import { DODGE_CD, SKILL_CD, TALENT_CD, type Tone, type World } from '../core/world';
import { RANK_COLOR } from '../data/talents';

const HUD_HTML = `
  <div class="hud-tl panel">
    <div class="row"><span class="lv">Cấp <b data-k="level"></b></span><span class="talent-badge" data-k="talent"></span></div>
    <div class="bar hp"><i data-k="hpFill"></i><span data-k="hpText"></span></div>
    <div class="bar exp"><i data-k="expFill"></i><span data-k="expText"></span></div>
    <div class="points" data-k="points"></div>
  </div>
  <div class="hud-tr panel">
    <div title="Vàng">💰 <b data-k="gold"></b></div>
    <div title="Gỗ">🪵 <b data-k="wood"></b></div>
    <div title="Đuốc Khai Giới">🔥 <b data-k="torch"></b> <small data-k="torchTimer"></small></div>
  </div>
  <div class="hud-obj panel">
    <h4>Chương 1 · Thức Tỉnh</h4>
    <ul>
      <li data-k="o1"></li>
      <li data-k="o2"></li>
      <li data-k="o3"></li>
    </ul>
    <div class="hint">M: Bản đồ khai phá · C: Chỉ số</div>
  </div>
  <div class="hud-boss hidden" data-k="boss">
    <div class="boss-name" data-k="bossName"></div>
    <div class="bar boss-hp"><i data-k="bossHp"></i></div>
    <div class="bar boss-poise"><i data-k="bossPoise"></i><span>Phá Thế</span></div>
  </div>
  <div class="hud-combo hidden" data-k="combo"></div>
  <div class="hud-skills">
    <div class="slot"><kbd>Chuột trái / J</kbd><span>Chém</span></div>
    <div class="slot" data-k="slotSkill"><kbd>K / Chuột phải</kbd><span>Xoáy Kiếm</span><i class="cd" data-k="cdSkill"></i></div>
    <div class="slot" data-k="slotDodge"><kbd>Space</kbd><span>Né lăn</span><i class="cd" data-k="cdDodge"></i></div>
    <div class="slot talent-slot" data-k="slotTalent"><kbd>L</kbd><span data-k="talentSlot"></span><i class="cd" data-k="cdTalent"></i></div>
  </div>
  <div class="hud-log" data-k="log"></div>
  <div class="hud-banner" data-k="banner"></div>
  <div class="hud-dead hidden" data-k="dead">Bạn đã gục ngã…</div>
`;

const fmt = (n: number): string => Math.floor(n).toLocaleString('vi-VN');
const mmss = (sec: number): string => {
  const s = Math.max(0, Math.ceil(sec));
  return `${Math.floor(s / 60)}:${String(s % 60).padStart(2, '0')}`;
};

export class Hud {
  private readonly el: HTMLDivElement;
  private readonly refs = new Map<string, HTMLElement>();
  private readonly cache = new Map<string, string>();

  constructor(root: HTMLElement) {
    this.el = document.createElement('div');
    this.el.className = 'hud';
    this.el.innerHTML = HUD_HTML;
    root.appendChild(this.el);
    this.el.querySelectorAll<HTMLElement>('[data-k]').forEach((n) => this.refs.set(n.dataset.k ?? '', n));
  }

  private ref(k: string): HTMLElement {
    const r = this.refs.get(k);
    if (!r) throw new Error(`HUD thiếu phần tử ${k}`);
    return r;
  }

  private text(k: string, v: string): void {
    if (this.cache.get(k) === v) return;
    this.cache.set(k, v);
    this.ref(k).textContent = v;
  }

  private css(k: string, prop: string, v: string): void {
    const key = `${k}|${prop}`;
    if (this.cache.get(key) === v) return;
    this.cache.set(key, v);
    this.ref(k).style.setProperty(prop, v);
  }

  private flag(k: string, cls: string, on: boolean): void {
    this.ref(k).classList.toggle(cls, on);
  }

  log(text: string, tone: Tone = 'info'): void {
    const log = this.ref('log');
    const line = document.createElement('div');
    line.className = `log-line ${tone}`;
    line.textContent = text;
    log.appendChild(line);
    while (log.children.length > 6) log.firstElementChild?.remove();
    setTimeout(() => line.classList.add('fade'), 7000);
    setTimeout(() => line.remove(), 8000);
  }

  banner(text: string): void {
    const b = this.ref('banner');
    b.textContent = text;
    b.classList.remove('show');
    void b.offsetWidth; // khởi động lại animation
    b.classList.add('show');
  }

  update(w: World): void {
    const p = w.profile;
    const pl = w.player;
    const s = w.stats;
    const talent = w.talent;

    this.text('level', String(p.level));
    this.text('talent', `${talent.rank} · ${talent.name}`);
    this.css('talent', '--rank', RANK_COLOR[talent.rank]);
    this.css('hpFill', 'width', `${(Math.max(0, pl.hp) / s.maxHp) * 100}%`);
    this.text('hpText', `${Math.ceil(Math.max(0, pl.hp))} / ${s.maxHp}`);
    const need = expToNext(p.level);
    this.css('expFill', 'width', `${Math.min(100, (p.exp / need) * 100)}%`);
    this.text('expText', `EXP ${fmt(p.exp)} / ${fmt(need)}`);
    this.flag('points', 'hidden', p.unspent <= 0);
    this.text('points', `+${p.unspent} điểm tiềm năng — nhấn C`);

    this.text('gold', fmt(p.gold));
    this.text('wood', fmt(p.wood));
    this.text('torch', `${p.torches}/${TORCH_MAX}`);
    this.text('torchTimer', p.torches < TORCH_MAX ? `+1 sau ${mmss(TORCH_REGEN_SEC - p.torchTimer)}` : '');

    const owned = ownedCount(p.tiles);
    const total = exploreTotal(p.tiles);
    const needTiles = Math.ceil(total * EXPLORE_REQ);
    this.objective('o1', p.level >= BOSS_LEVEL_REQ, `Đạt cấp ${BOSS_LEVEL_REQ} (${Math.min(p.level, BOSS_LEVEL_REQ)}/${BOSS_LEVEL_REQ})`);
    this.objective('o2', owned >= needTiles, `Khai phá ${owned}/${total} ô đất (cần ${needTiles})`);
    this.objective(
      'o3',
      p.bossDefeated,
      w.bossUnlocked ? 'Hạ Sói Chúa Hư Vô (hang phía đông)' : 'Hạ Sói Chúa Hư Vô — sương mù còn chặn lối',
    );

    const showCombo = w.combo >= 5;
    this.flag('combo', 'hidden', !showCombo);
    if (showCombo) this.text('combo', `${w.combo} combo · +${Math.round((comboExpMultiplier(w.combo) - 1) * 100)}% EXP`);

    this.cooldown('cdSkill', pl.skillCd / SKILL_CD);
    this.cooldown('cdDodge', pl.dodgeCd / DODGE_CD);
    if (talent.active) {
      this.text('talentSlot', pl.talentCd > 0 ? `${talent.name} · ${Math.ceil(pl.talentCd)}s` : talent.name);
      this.cooldown('cdTalent', pl.talentCd / TALENT_CD);
    } else {
      this.text('talentSlot', `${talent.name} · bị động`);
      this.cooldown('cdTalent', 0);
    }
    this.css('slotTalent', '--rank', RANK_COLOR[talent.rank]);

    const boss = w.boss;
    this.flag('boss', 'hidden', !boss);
    if (boss) {
      this.text('bossName', `${boss.name}${boss.phase > 1 ? ' · Giai đoạn 2' : ''}${boss.broken ? ' · CHOÁNG' : ''}`);
      this.css('bossHp', 'width', `${(Math.max(0, boss.hp) / boss.maxHp) * 100}%`);
      this.css('bossPoise', 'width', `${(boss.poise / boss.maxPoise) * 100}%`);
    }
    this.flag('dead', 'hidden', pl.deadTimer <= 0);
  }

  private objective(k: string, done: boolean, label: string): void {
    this.text(k, `${done ? '✔' : '○'} ${label}`);
    this.flag(k, 'done', done);
  }

  private cooldown(k: string, frac: number): void {
    this.css(k, 'height', `${Math.max(0, Math.min(1, frac)) * 100}%`);
  }
}
