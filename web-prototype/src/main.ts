import './style.css';
import { Awakening } from './core/awakening';
import { newProfile, type Profile } from './core/profile';
import { mulberry32 } from './core/rng';
import { applyOffline, clearSave, loadProfile, saveProfile } from './core/save';
import { WORLD_H, WORLD_W, World, type GameEvent, type Input } from './core/world';
import { Renderer, type Camera } from './render/renderer';
import { Hud } from './ui/hud';
import { MapPanel, StatsPanel } from './ui/panels';
import { showAwakening, showTitle, showVictory } from './ui/screens';

const canvas = document.getElementById('game') as HTMLCanvasElement;
const uiRoot = document.getElementById('ui') as HTMLDivElement;
const ctx = canvas.getContext('2d');
if (!ctx) throw new Error('Trình duyệt không hỗ trợ Canvas 2D');
const renderer = new Renderer(ctx);
const cam: Camera = { x: 0, y: 0, w: window.innerWidth, h: window.innerHeight };

interface Session {
  world: World;
  hud: Hud;
  stats: StatsPanel;
  map: MapPanel;
  victoryOpen: boolean;
}
let session: Session | null = null;

// ------------------------------------------------------------------ điều khiển

const keys = new Set<string>();
const pressed = { skill: false, talent: false, dodge: false };
let mouseX = 0;
let mouseY = 0;
let mouseDown = false;
let lastMouseMove = 0;

window.addEventListener('keydown', (e) => {
  keys.add(e.code);
  if (!session || session.victoryOpen) return;
  const s = session;
  switch (e.code) {
    case 'Space':
      e.preventDefault();
      if (!e.repeat) pressed.dodge = true;
      break;
    case 'KeyK':
      if (!e.repeat) pressed.skill = true;
      break;
    case 'KeyL':
      if (!e.repeat) pressed.talent = true;
      break;
    case 'KeyC':
      s.map.close();
      s.stats.toggle(s.world);
      break;
    case 'KeyM':
    case 'Tab':
      e.preventDefault();
      s.stats.close();
      s.map.toggle(s.world);
      break;
    case 'Escape':
      s.stats.close();
      s.map.close();
      break;
  }
});
window.addEventListener('keyup', (e) => keys.delete(e.code));
window.addEventListener('blur', () => {
  keys.clear();
  mouseDown = false;
});
canvas.addEventListener('mousemove', (e) => {
  mouseX = e.clientX;
  mouseY = e.clientY;
  lastMouseMove = performance.now();
});
canvas.addEventListener('mousedown', (e) => {
  if (e.button === 0) mouseDown = true;
  if (e.button === 2) pressed.skill = true;
});
window.addEventListener('mouseup', (e) => {
  if (e.button === 0) mouseDown = false;
});
canvas.addEventListener('contextmenu', (e) => e.preventDefault());

function readInput(world: World): Input {
  const right = keys.has('KeyD') || keys.has('ArrowRight');
  const left = keys.has('KeyA') || keys.has('ArrowLeft');
  const down = keys.has('KeyS') || keys.has('ArrowDown');
  const up = keys.has('KeyW') || keys.has('ArrowUp');
  const moveX = (right ? 1 : 0) - (left ? 1 : 0);
  const moveY = (down ? 1 : 0) - (up ? 1 : 0);
  let aimX = cam.x + mouseX;
  let aimY = cam.y + mouseY;
  // Chơi chỉ bằng bàn phím: chuột đứng yên lâu thì hướng chém theo hướng di chuyển.
  if ((moveX || moveY) && performance.now() - lastMouseMove > 1500) {
    aimX = world.player.x + moveX * 100;
    aimY = world.player.y + moveY * 100;
  }
  const input: Input = {
    moveX,
    moveY,
    aimX,
    aimY,
    attack: mouseDown || keys.has('KeyJ'),
    skill: pressed.skill,
    talent: pressed.talent,
    dodge: pressed.dodge,
  };
  clearPressed();
  return input;
}

function clearPressed(): void {
  pressed.skill = false;
  pressed.talent = false;
  pressed.dodge = false;
}

// ------------------------------------------------------------------ màn hình

function persist(): void {
  if (!session) return;
  session.world.profile.lastSeen = Date.now();
  saveProfile(session.world.profile);
}

function goTitle(): void {
  persist();
  session = null;
  uiRoot.innerHTML = '';
  const saved = loadProfile();
  showTitle(uiRoot, {
    hasSave: saved !== null,
    onNew: () => {
      if (saved && !window.confirm('Hành trình mới sẽ xoá tiến trình đang lưu. Tiếp tục?')) return;
      clearSave();
      goAwakening();
    },
    onContinue: () => {
      const profile = loadProfile();
      if (!profile) return;
      const off = applyOffline(profile, Date.now());
      startWorld(profile);
      if (off.seconds > 60 && (off.gold >= 1 || off.wood >= 1 || off.torches > 0)) {
        session?.hud.log(
          `Lãnh địa thu hoạch khi bạn vắng mặt: +${Math.floor(off.wood)} gỗ, +${Math.floor(off.gold)} vàng, +${off.torches} Đuốc.`,
          'good',
        );
      }
    },
  });
}

function goAwakening(): void {
  uiRoot.innerHTML = '';
  const seed = (Date.now() ^ (Math.random() * 0xffffffff)) >>> 0;
  showAwakening(uiRoot, new Awakening(mulberry32(seed)), (talent) => {
    const profile = newProfile(talent, mulberry32(seed + 1), Date.now());
    saveProfile(profile);
    startWorld(profile);
    session?.hud.log('Quái Sương đang tràn vào Rừng Sương. Hãy đánh chúng, lên cấp và khai phá vùng đất (phím M).', 'info');
  });
}

function startWorld(profile: Profile): void {
  uiRoot.innerHTML = '';
  const world = new World(profile, mulberry32((Date.now() & 0x7fffffff) >>> 0));
  const hud = new Hud(uiRoot);
  session = {
    world,
    hud,
    stats: new StatsPanel(uiRoot),
    map: new MapPanel(uiRoot, () => hud.log('Thủ lĩnh ổ quái đã xuất hiện trước mặt bạn!', 'bad')),
    victoryOpen: false,
  };
}

function handleEvent(s: Session, ev: GameEvent): void {
  switch (ev.type) {
    case 'message':
      s.hud.log(ev.text, ev.tone);
      break;
    case 'levelup':
      s.hud.banner(`Lên cấp ${ev.level}!`);
      persist();
      break;
    case 'tile':
      persist();
      break;
    case 'victory':
      persist();
      s.victoryOpen = true;
      mouseDown = false;
      showVictory(uiRoot, s.world, {
        onContinue: () => {
          s.victoryOpen = false;
        },
        onTitle: goTitle,
      });
      break;
    case 'death':
      break;
  }
}

// ------------------------------------------------------------------ vòng lặp

function resize(): void {
  const dpr = window.devicePixelRatio || 1;
  cam.w = window.innerWidth;
  cam.h = window.innerHeight;
  canvas.width = Math.floor(cam.w * dpr);
  canvas.height = Math.floor(cam.h * dpr);
  canvas.style.width = `${cam.w}px`;
  canvas.style.height = `${cam.h}px`;
  ctx?.setTransform(dpr, 0, 0, dpr, 0, 0);
}
window.addEventListener('resize', resize);
window.addEventListener('beforeunload', persist);
resize();

const clamp = (v: number, lo: number, hi: number): number => Math.min(hi, Math.max(lo, v));

let last = performance.now();
let saveTimer = 0;

function frame(now: number): void {
  const dt = Math.min(0.05, (now - last) / 1000);
  last = now;
  const s = session;
  if (s && ctx) {
    const paused = s.victoryOpen || s.stats.isOpen || s.map.isOpen;
    if (paused) clearPressed();
    else s.world.update(dt, readInput(s.world));
    for (const ev of s.world.drainEvents()) handleEvent(s, ev);

    const p = s.world.player;
    cam.x = cam.w >= WORLD_W ? (WORLD_W - cam.w) / 2 : clamp(p.x - cam.w / 2, 0, WORLD_W - cam.w);
    cam.y = cam.h >= WORLD_H ? (WORLD_H - cam.h) / 2 : clamp(p.y - cam.h / 2, 0, WORLD_H - cam.h);
    renderer.draw(s.world, cam);
    s.hud.update(s.world);

    saveTimer += dt;
    if (saveTimer > 5) {
      saveTimer = 0;
      persist();
    }
  } else if (ctx) {
    ctx.clearRect(0, 0, cam.w, cam.h);
  }
  requestAnimationFrame(frame);
}

goTitle();
requestAnimationFrame(frame);
