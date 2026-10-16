/* ox_lib NUI — lulu design system. Plain JS, no build step.
   core: NUI plumbing, icons, markdown, theme, color picker. */
(function () {
  'use strict';

  const Ox = (window.Ox = {});
  const RES = typeof window.GetParentResourceName === 'function' ? window.GetParentResourceName() : 'ox_lib';

  // ------------------------------------------------------------------ NUI plumbing
  Ox.post = function (name, data) {
    return fetch('https://' + RES + '/' + name, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json; charset=UTF-8' },
      body: JSON.stringify(data === undefined ? {} : data),
    }).then((r) => r.json()).catch(() => null);
  };

  const handlers = {};
  Ox.on = (action, fn) => { handlers[action] = fn; };
  window.addEventListener('message', (e) => {
    const d = e.data;
    if (!d || !d.action) return;
    const fn = handlers[d.action];
    if (fn) { try { fn(d.data); } catch (err) { console.error('[ox_lib] ' + d.action, err); } }
  });

  // one keydown router: the top-most open component gets the key first
  const keyLayers = [];
  Ox.pushKeys = (fn) => { keyLayers.push(fn); return fn; };
  Ox.popKeys = (fn) => { const i = keyLayers.lastIndexOf(fn); if (i !== -1) keyLayers.splice(i, 1); };
  window.addEventListener('keydown', (e) => {
    for (let i = keyLayers.length - 1; i >= 0; i--) { if (keyLayers[i](e) !== false) return; }
  });

  // ------------------------------------------------------------------ helpers
  const ESC = { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' };
  Ox.esc = (s) => String(s == null ? '' : s).replace(/[&<>"']/g, (c) => ESC[c]);
  Ox.clamp = (n, a, b) => Math.max(a, Math.min(b, n));
  Ox.el = (html) => { const t = document.createElement('template'); t.innerHTML = html.trim(); return t.content.firstChild; };
  Ox.$ = (sel, root) => (root || document).querySelector(sel);

  // ------------------------------------------------------------------ icons (Font Awesome names, as ox_lib passes them)
  const ANIM = { spin: 'fa-spin', spinPulse: 'fa-spin-pulse', spinReverse: 'fa-spin-reverse', pulse: 'fa-pulse', beat: 'fa-beat', fade: 'fa-fade', beatFade: 'fa-beat-fade', bounce: 'fa-bounce', shake: 'fa-shake' };
  const STYLE = { fas: 'fa-solid', far: 'fa-regular', fab: 'fa-brands', fal: 'fa-solid', fat: 'fa-solid', fad: 'fa-solid', fass: 'fa-solid', fak: 'fa-solid' };

  Ox.iconClass = function (icon) {
    if (!icon) return '';
    if (Array.isArray(icon)) return (STYLE[icon[0]] || 'fa-solid') + ' fa-' + icon[1];
    const s = String(icon);
    if (/^(fa-solid|fa-regular|fa-brands|fas|far|fab|fal|fat|fad)\b/.test(s)) {
      return s.split(/\s+/).map((p) => STYLE[p] || p).join(' ');
    }
    if (s.indexOf('fa-') !== -1) return 'fa-solid ' + s;
    return 'fa-solid fa-' + s;
  };
  const isImage = (s) => typeof s === 'string' && (/^(https?:|nui:|data:|\.\/|\/)/.test(s) || /\.(png|jpe?g|webp|gif|svg)$/i.test(s));

  // returns markup for an icon (font icon or image)
  Ox.icon = function (icon, opts) {
    if (!icon) return '';
    opts = opts || {};
    if (isImage(icon)) return '<img class="ox-icon-img" src="' + Ox.esc(icon) + '" alt="">';
    const anim = opts.animation && ANIM[opts.animation] ? ' ' + ANIM[opts.animation] : '';
    const color = opts.color ? ' style="color:' + Ox.esc(opts.color) + '"' : '';
    return '<i class="' + Ox.iconClass(icon) + anim + '"' + color + ' aria-hidden="true"></i>';
  };

  // ------------------------------------------------------------------ small markdown subset (descriptions, alerts)
  function inline(s) {
    s = Ox.esc(s);
    s = s.replace(/`([^`]+)`/g, '<code>$1</code>');
    s = s.replace(/!\[([^\]]*)\]\(([^)\s]+)\)/g, '<img class="ox-md-img" alt="$1" src="$2">');
    s = s.replace(/\[([^\]]+)\]\(([^)\s]+)\)/g, '<span class="ox-md-link">$1</span>');
    s = s.replace(/\*\*([^*]+)\*\*/g, '<strong>$1</strong>');
    s = s.replace(/(^|[^*])\*([^*\s][^*]*)\*/g, '$1<em>$2</em>');
    s = s.replace(/~~([^~]+)~~/g, '<del>$1</del>');
    return s;
  }
  Ox.md = function (text) {
    if (text == null || text === '') return '';
    const lines = String(text).split(/\r?\n/);
    let out = '', list = false;
    for (const raw of lines) {
      const li = /^\s*[-*]\s+(.*)$/.exec(raw);
      if (li) { if (!list) { out += '<ul>'; list = true; } out += '<li>' + inline(li[1]) + '</li>'; continue; }
      if (list) { out += '</ul>'; list = false; }
      const h = /^(#{1,3})\s+(.*)$/.exec(raw);
      if (h) { out += '<div class="ox-md-h">' + inline(h[2]) + '</div>'; continue; }
      const q = /^>\s?(.*)$/.exec(raw);
      if (q) { out += '<blockquote>' + inline(q[1]) + '</blockquote>'; continue; }
      out += raw.trim() === '' ? '<br>' : '<div>' + inline(raw) + '</div>';
    }
    if (list) out += '</ul>';
    return out;
  };

  // ------------------------------------------------------------------ theme (Settings > accent / text / background / opacity)
  const THEME_KEY = 'ox_lib:theme';
  Ox.themeDefaults = { accent: '#FF6FAE', text: '#F8F6FA', bg: '#17151C', opacity: 100 };
  const HEX = /^#[0-9a-f]{6}$/i;
  Ox.HEX = HEX;
  const rgb = (h) => [parseInt(h.slice(1, 3), 16), parseInt(h.slice(3, 5), 16), parseInt(h.slice(5, 7), 16)];
  const toHex = (r, g, b) => '#' + [r, g, b].map((n) => Math.round(Ox.clamp(n, 0, 255)).toString(16).padStart(2, '0')).join('').toUpperCase();
  const alpha = (h, a) => { const c = rgb(h); return 'rgba(' + c[0] + ',' + c[1] + ',' + c[2] + ',' + a + ')'; };
  const mix = (a, b, t) => { const x = rgb(a), y = rgb(b); return toHex(x[0] + (y[0] - x[0]) * t, x[1] + (y[1] - x[1]) * t, x[2] + (y[2] - x[2]) * t); };
  const lum = (h) => { const c = rgb(h); return (0.2126 * c[0] + 0.7152 * c[1] + 0.0722 * c[2]) / 255; };
  const hsl = (h, s, l) => 'hsl(' + h + ',' + s + '%,' + l + '%)';
  function hue(hex) {
    const c = rgb(hex).map((n) => n / 255), mx = Math.max.apply(null, c), mn = Math.min.apply(null, c), d = mx - mn, l = (mx + mn) / 2;
    let h = 0, s = 0;
    if (d) {
      s = l > 0.5 ? d / (2 - mx - mn) : d / (mx + mn);
      h = mx === c[0] ? (c[1] - c[2]) / d + (c[1] < c[2] ? 6 : 0) : mx === c[1] ? (c[2] - c[0]) / d + 2 : (c[0] - c[1]) / d + 4;
      h *= 60;
    }
    return [Math.round(h), Math.round(s * 100)];
  }
  Ox.mix = mix; Ox.alpha = alpha; Ox.rgb = rgb;

  Ox.theme = Object.assign({}, Ox.themeDefaults);
  // the saved theme lives in Lua (KVP, set in the /ox_lib settings dialog); the NUI asks for it on load
  Ox.setTheme = function (t) {
    if (t && typeof t === 'object') Ox.theme = Object.assign({}, Ox.themeDefaults, t);
    Ox.applyTheme();
  };
  Ox.on('setTheme', Ox.setTheme);
  Ox.applyTheme = function () {
    const t = Ox.theme, d = Ox.themeDefaults, root = document.documentElement.style;
    const accent = HEX.test(t.accent) ? t.accent.toUpperCase() : d.accent;
    const text = HEX.test(t.text) ? t.text.toUpperCase() : d.text;
    const bg = HEX.test(t.bg) ? t.bg.toUpperCase() : d.bg;
    const dark = lum(bg) < 0.5;
    const c = rgb(bg);
    root.setProperty('--bg-rgb', c[0] + ', ' + c[1] + ', ' + c[2]);
    root.setProperty('--bg', bg);
    root.setProperty('--ink', text);
    root.setProperty('--ink-muted', alpha(text, 0.72));
    root.setProperty('--ink-faint', alpha(text, 0.5));
    root.setProperty('--fill', alpha(text, 0.04));
    root.setProperty('--fill-2', alpha(text, 0.08));
    root.setProperty('--line', alpha(text, 0.14));
    root.setProperty('--line-strong', alpha(text, 0.25));
    root.setProperty('--line-faint', alpha(text, 0.06));
    root.setProperty('--pop', mix(bg, text, 0.06));
    root.setProperty('--field', mix(bg, text, 0.09));
    root.setProperty('--track', mix(bg, text, 0.22));
    root.setProperty('--knob', mix(bg, text, 0.8));
    root.setProperty('--knob-on', dark ? '#211923' : '#FFFFFF');
    root.setProperty('--shadow', dark ? '0 10px 40px rgba(0,0,0,.45)' : '0 10px 40px rgba(23,21,28,.18)');
    const h = hue(accent), s = Ox.clamp(h[1], 35, 72);
    root.setProperty('--accent', accent);
    root.setProperty('--accent-surface', hsl(h[0], s, 46));
    root.setProperty('--accent-press', hsl(h[0], s, 40));
    root.setProperty('--accent-text', dark ? hsl(h[0], Math.max(s, 60), 78) : hsl(h[0], s, 44));
    root.setProperty('--accent-soft', alpha(accent, dark ? 0.125 : 0.14));
    root.setProperty('--accent-2', hsl((h[0] + 45) % 360, 90, dark ? 80 : 60));
    root.setProperty('--alpha', String(Ox.clamp(Number(t.opacity) || 100, 40, 100) / 100));
  };

  // ------------------------------------------------------------------ hex field + color popup (same picker as lulu_hud)
  const hsv2hex = (h, s, v) => {
    const f = (n) => { const k = (n + h / 60) % 6; return v - v * s * Math.max(0, Math.min(k, 4 - k, 1)); };
    return '#' + [f(5), f(3), f(1)].map((x) => Math.round(x * 255).toString(16).padStart(2, '0')).join('').toUpperCase();
  };
  const hex2hsv = (hex) => {
    const c = rgb(hex).map((n) => n / 255), mx = Math.max.apply(null, c), mn = Math.min.apply(null, c), d = mx - mn;
    let h = 0;
    if (d) { h = mx === c[0] ? ((c[1] - c[2]) / d) % 6 : mx === c[1] ? (c[2] - c[0]) / d + 2 : (c[0] - c[1]) / d + 4; h = (h * 60 + 360) % 360; }
    return [h, mx ? d / mx : 0, mx];
  };

  let pop = null;
  Ox.closeColorPop = function () { if (pop) { pop.remove(); pop = null; } };
  document.addEventListener('pointerdown', (e) => {
    if (pop && !pop.contains(e.target) && !e.target.closest('.ox-swatch')) Ox.closeColorPop();
  });

  function openPop(swatch, input) {
    Ox.closeColorPop();
    let v0 = input.value.trim();
    if (v0 && v0[0] !== '#') v0 = '#' + v0;
    let hsv = hex2hsv(HEX.test(v0) ? v0 : '#FF6FAE');
    const el = document.createElement('div');
    el.className = 'ox-colorpop';
    el.innerHTML = '<div class="ox-cp-sv"><i></i></div><input type="range" class="ox-cp-hue" min="0" max="360" step="1" aria-label="Hue"><div class="ox-cp-hex"><span></span><b></b></div>';
    const sv = el.querySelector('.ox-cp-sv'), knob = sv.firstChild, hueEl = el.querySelector('.ox-cp-hue');
    const chip = el.querySelector('.ox-cp-hex span'), label = el.querySelector('.ox-cp-hex b');
    const paint = () => {
      const c = hsv2hex(hsv[0], hsv[1], hsv[2]);
      sv.style.background = 'linear-gradient(to top,#000,transparent),linear-gradient(to right,#fff,' + hsv2hex(hsv[0], 1, 1) + ')';
      knob.style.left = hsv[1] * 100 + '%'; knob.style.top = (1 - hsv[2]) * 100 + '%';
      hueEl.value = hsv[0]; chip.style.background = c; label.textContent = c;
      return c;
    };
    const commit = () => { input.value = paint(); input.dispatchEvent(new Event('input', { bubbles: true })); };
    const pick = (e) => { const r = sv.getBoundingClientRect(); hsv[1] = Ox.clamp((e.clientX - r.left) / r.width, 0, 1); hsv[2] = 1 - Ox.clamp((e.clientY - r.top) / r.height, 0, 1); commit(); };
    sv.addEventListener('pointerdown', (e) => { sv.setPointerCapture(e.pointerId); pick(e); sv.onpointermove = pick; });
    sv.addEventListener('pointerup', () => { sv.onpointermove = null; });
    hueEl.addEventListener('input', () => { hsv[0] = Number(hueEl.value); commit(); });
    document.body.append(el);
    paint();
    const r = swatch.getBoundingClientRect();
    el.style.left = Ox.clamp(r.left, 8, window.innerWidth - el.offsetWidth - 8) + 'px';
    const below = r.bottom + 8, above = r.top - el.offsetHeight - 8;
    el.style.top = (below + el.offsetHeight > window.innerHeight - 8 ? Math.max(8, above) : below) + 'px';
    pop = el; pop.__for = swatch;
  }

  // <div class="ox-hex"> swatch + hex text; onChange(hex) fires for valid values only
  Ox.hexField = function (value, onChange) {
    const val = HEX.test(value) ? value.toUpperCase() : '#FF6FAE';
    const el = Ox.el('<div class="ox-hex" style="--c:' + val + '"><button type="button" class="ox-swatch" aria-label="Pick color"></button><input type="text" spellcheck="false" maxlength="7" value="' + val + '"></div>');
    const input = el.querySelector('input'), sw = el.querySelector('.ox-swatch');
    sw.addEventListener('click', () => { if (pop && pop.__for === sw) Ox.closeColorPop(); else openPop(sw, input); });
    input.addEventListener('input', () => {
      let v = input.value.trim(); if (v && v[0] !== '#') v = '#' + v;
      if (HEX.test(v)) { el.classList.remove('bad'); el.style.setProperty('--c', v.toUpperCase()); onChange(v.toUpperCase()); }
      else el.classList.add('bad');
    });
    el.setValue = (v) => { input.value = v; el.style.setProperty('--c', v); el.classList.remove('bad'); };
    return el;
  };

  // ------------------------------------------------------------------ shared bits
  Ox.setClipboard = function (value) {
    const t = document.createElement('textarea');
    t.value = value; document.body.appendChild(t); t.select();
    try { document.execCommand('copy'); } catch (e) { /* ignore */ }
    document.body.removeChild(t);
  };
  Ox.on('setClipboard', (v) => Ox.setClipboard(v));

  // colors for progress bars (ox_lib passes Mantine color names)
  const SCHEME = { red: '#FF6B7A', pink: '#FF6FAE', grape: '#C77DFF', violet: '#9B7FE8', indigo: '#7C8CFF', blue: '#6FB1FF', cyan: '#4ED8E8', teal: '#4ED8C8', green: '#3DDB93', lime: '#A8E05F', yellow: '#F5D547', orange: '#F0AA43' };
  Ox.scheme = (name) => (name && SCHEME[String(name).split('.')[0]]) || null;

  // ------------------------------------------------------------------ locale (ox_lib's locales/*.json, sent by Lua)
  Ox.locale = {};
  Ox.t = (key, fallback) => (Ox.locale && Ox.locale.ui && Ox.locale.ui[key]) || fallback;
  Ox.on('setLocale', (d) => { Ox.locale = d || {}; });

  document.addEventListener('DOMContentLoaded', () => {
    Ox.applyTheme();
    Ox.post('init');                                       // -> setLocale
    Ox.post('uiReady').then((t) => Ox.setTheme(t));        // -> saved theme
  });
  // never show the browser context menu / text selection ghosting inside the game
  document.addEventListener('contextmenu', (e) => e.preventDefault());
})();
