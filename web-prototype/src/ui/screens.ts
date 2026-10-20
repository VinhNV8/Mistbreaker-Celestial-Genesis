import type { Awakening } from '../core/awakening';
import { exploreTotal, ownedCount } from '../core/explore';
import type { World } from '../core/world';
import { RANK_COLOR, RANK_WEIGHT, TALENTS, type TalentDef, type TalentId } from '../data/talents';

function mount(root: HTMLElement, html: string): HTMLDivElement {
  const el = document.createElement('div');
  el.innerHTML = html;
  const screen = el.firstElementChild as HTMLDivElement;
  root.appendChild(screen);
  return screen;
}

const CONTROLS = `
  <table class="controls">
    <tr><td><kbd>W A S D</kbd></td><td>Di chuyển</td></tr>
    <tr><td><kbd>Chuột</kbd></td><td>Ngắm hướng chém</td></tr>
    <tr><td><kbd>Chuột trái</kbd> / <kbd>J</kbd></td><td>Chém (giữ để chém liên tục)</td></tr>
    <tr><td><kbd>K</kbd> / <kbd>Chuột phải</kbd></td><td>Xoáy Kiếm (đánh vòng quanh)</td></tr>
    <tr><td><kbd>Space</kbd></td><td>Né lăn — bất tử 0,3 giây</td></tr>
    <tr><td><kbd>L</kbd></td><td>Kỹ năng Thiên phú (nếu có)</td></tr>
    <tr><td><kbd>M</kbd> · <kbd>C</kbd></td><td>Bản đồ khai phá · Chỉ số</td></tr>
  </table>`;

export function showTitle(root: HTMLElement, opts: { hasSave: boolean; onNew: () => void; onContinue: () => void }): void {
  const el = mount(
    root,
    `<div class="screen title">
      <div class="title-box">
        <div class="eyebrow">Bản prototype · Chương 1</div>
        <h1>Thiên Phú Khai Giới</h1>
        <p class="tagline">Nhận Thiên phú từ Bia Đá, đánh quái lên cấp, xua tan sương mù Hư Vô và hạ Sói Chúa.</p>
        <div class="btns">
          <button class="btn primary" data-a="new">Hành trình mới</button>
          <button class="btn" data-a="continue" ${opts.hasSave ? '' : 'disabled'}>Tiếp tục</button>
        </div>
        ${CONTROLS}
      </div>
    </div>`,
  );
  el.querySelector('[data-a="new"]')?.addEventListener('click', opts.onNew);
  el.querySelector('[data-a="continue"]')?.addEventListener('click', opts.onContinue);
}

export function showAwakening(root: HTMLElement, awakening: Awakening, onDone: (talent: TalentId) => void): void {
  let selected = -1;
  let rolling: TalentDef | null = null;
  const el = mount(root, `<div class="screen awakening"></div>`);
  const totalWeight = TALENTS.reduce((s, t) => s + RANK_WEIGHT[t.rank], 0);
  const rates = TALENTS.map((t) => `${t.rank} ${((RANK_WEIGHT[t.rank] / totalWeight) * 100).toFixed(1)}%`).join(' · ');

  const card = (t: TalentDef | null, spinning: boolean): string => {
    if (!t) return `<div class="card empty"><span class="rank">?</span><p>Bia Đá đang chờ bàn tay của con.</p></div>`;
    return `<div class="card ${spinning ? 'spinning' : 'reveal'}" style="--rank:${RANK_COLOR[t.rank]}">
      <span class="rank">${t.rank}</span>
      <h3>${t.name}</h3>
      <small>${t.group}${t.active ? ' · Chủ động' : ' · Bị động'}</small>
      <p>${spinning ? '…' : t.description}</p>
    </div>`;
  };

  const render = (): void => {
    const current = rolling ?? (selected >= 0 ? awakening.rolls[selected] : null);
    const history = awakening.rolls
      .map(
        (t, i) =>
          `<button class="chip ${i === selected ? 'active' : ''}" data-a="pick" data-v="${i}" style="--rank:${RANK_COLOR[t.rank]}">
            Lần ${i + 1}: ${t.rank} · ${t.name}</button>`,
      )
      .join('');
    const first = awakening.rolls.length === 0;
    el.innerHTML = `
      <div class="aw-box">
        <div class="eyebrow">Lễ Thức Tỉnh · Làng Thanh Thạch</div>
        <h2>Bia Đá Thiên Đạo</h2>
        <p class="speech">Trưởng làng: “Đặt tay lên Bia Đá, để Thiên Đạo phán xét con.”</p>
        <div class="stone">${card(current, rolling !== null)}</div>
        <div class="history">${history}</div>
        <div class="btns">
          <button class="btn primary" data-a="roll" ${awakening.canRoll && !rolling ? '' : 'disabled'}>
            ${first ? 'Chạm Bia Đá' : `Quay lại (còn ${awakening.rerollsLeft} lần)`}
          </button>
          <button class="btn" data-a="accept" ${selected >= 0 && !rolling ? '' : 'disabled'}>Nhận Thiên phú này</button>
        </div>
        <p class="note">Có thể chọn lại bất kỳ lần quay nào. Bảo hiểm: nếu cả 4 lần đều dưới hạng B, lần cuối được nâng lên hạng B.<br/>
        Tỉ lệ trong bản prototype: ${rates}. Lớp nhân vật: Kiếm Khách.</p>
      </div>`;
  };

  el.addEventListener('click', (ev) => {
    const btn = (ev.target as HTMLElement).closest<HTMLElement>('[data-a]');
    if (!btn || btn.hasAttribute('disabled')) return;
    const action = btn.dataset.a;
    if (action === 'roll' && awakening.canRoll && !rolling) {
      const started = performance.now();
      const tick = (): void => {
        if (performance.now() - started < 1100) {
          rolling = TALENTS[Math.floor(Math.random() * TALENTS.length)];
          render();
          setTimeout(tick, 80);
          return;
        }
        rolling = null;
        awakening.roll();
        selected = awakening.rolls.length - 1;
        render();
      };
      tick();
    } else if (action === 'pick') {
      selected = Number(btn.dataset.v);
      render();
    } else if (action === 'accept' && selected >= 0) {
      onDone(awakening.rolls[selected].id);
    }
  });
  render();
}

export function showVictory(root: HTMLElement, world: World, opts: { onContinue: () => void; onTitle: () => void }): void {
  const p = world.profile;
  const minutes = Math.round(p.playSeconds / 60);
  const el = mount(
    root,
    `<div class="screen victory">
      <div class="title-box">
        <div class="eyebrow">Chương 1 hoàn thành</div>
        <h1>Sói Chúa Hư Vô đã ngã xuống</h1>
        <p class="tagline">Ánh sáng từ Bia Đá lan tới tận hang sói. Phía đông, Đồng Bằng Gió Hú đang chờ… và Thiên phú trong bạn khẽ rung động.</p>
        <div class="derived">
          <span>Thời gian chơi <b>${minutes} phút</b></span>
          <span>Cấp <b>${p.level}</b></span>
          <span>Quái đã hạ <b>${p.kills}</b></span>
          <span>Khai phá <b>${ownedCount(p.tiles)}/${exploreTotal(p.tiles)}</b></span>
          <span>Thiên phú <b>${world.talent.rank} · ${world.talent.name}</b></span>
        </div>
        <p class="muted">Đây là hết nội dung của bản prototype. Hãy ghi lại cảm nhận: combat có vui không, Thiên phú có tạo khác biệt không, khai phá có hấp dẫn không.</p>
        <div class="btns">
          <button class="btn primary" data-a="continue">Tiếp tục khám phá</button>
          <button class="btn" data-a="title">Về màn hình chính</button>
        </div>
      </div>
    </div>`,
  );
  el.querySelector('[data-a="continue"]')?.addEventListener('click', () => {
    el.remove();
    opts.onContinue();
  });
  el.querySelector('[data-a="title"]')?.addEventListener('click', opts.onTitle);
}
