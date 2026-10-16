/* notifications + textUI */
(function () {
  'use strict';
  const Ox = window.Ox;

  // ------------------------------------------------------------------ notifications
  const POSITIONS = ['top', 'top-right', 'top-left', 'bottom', 'bottom-right', 'bottom-left', 'center-right', 'center-left'];
  const TYPES = {
    success: { color: 'var(--success)', icon: 'circle-check' },
    warning: { color: 'var(--warning)', icon: 'triangle-exclamation' },
    error: { color: 'var(--danger)', icon: 'circle-xmark' },
    info: { color: 'var(--info)', icon: 'circle-info' },
  };
  const stacks = {};
  const live = {};   // id -> element

  function stack(pos) {
    if (!stacks[pos]) {
      const el = document.createElement('div');
      el.className = 'ox-notify-stack ' + pos;
      document.body.appendChild(el);
      stacks[pos] = el;
    }
    return stacks[pos];
  }

  function remove(el, id) {
    if (!el.parentNode) return;
    el.classList.add('out');
    if (id != null && live[id] === el) delete live[id];
    setTimeout(() => el.remove(), 260);
  }

  Ox.on('notify', function (data) {
    if (!data || (!data.title && !data.description)) return;
    const id = data.id != null ? String(data.id) : null;
    if (id && live[id]) return;                        // same id: already on screen

    let pos = data.position || 'top-right';
    if (POSITIONS.indexOf(pos) === -1) pos = 'top-right';
    const type = TYPES[data.type] ? data.type : 'info';
    const kind = TYPES[type];
    const duration = Number(data.duration) > 0 ? Number(data.duration) : 3000;
    const showRing = data.showDuration !== false;
    const icon = data.icon || kind.icon;
    const color = data.iconColor || kind.color;

    const el = document.createElement('div');
    el.className = 'ox-toast ox-surface' + (data.alignIcon === 'top' ? ' top-icon' : '');
    el.style.setProperty('--c', color);
    el.style.setProperty('--dur', duration + 'ms');
    el.innerHTML =
      '<div class="ox-toast-icon">' + Ox.icon(icon, { animation: data.iconAnimation }) +
        (showRing ? '<svg viewBox="0 0 40 40"><circle cx="20" cy="20" r="18"></circle></svg>' : '') + '</div>' +
      '<div class="ox-toast-body">' +
        (data.title ? '<div class="ox-toast-title">' + Ox.esc(data.title) + '</div>' : '') +
        (data.description ? '<div class="ox-toast-desc' + (data.title ? '' : ' only') + '">' + Ox.md(data.description) + '</div>' : '') +
      '</div>';
    if (data.style && typeof data.style === 'object') {
      Object.keys(data.style).forEach((k) => { try { el.style[k] = data.style[k]; } catch (e) { /* ignore */ } });
    }

    const container = stack(pos);
    container.appendChild(el);
    if (id) live[id] = el;
    setTimeout(() => remove(el, id), duration);
  });

  // ------------------------------------------------------------------ textUI
  let tui = null, tuiTimer = null;

  Ox.on('textUi', function (data) {
    if (!data) return;
    const pos = ['right-center', 'left-center', 'top-center', 'bottom-center'].indexOf(data.position) !== -1 ? data.position : 'right-center';
    let text = String(data.text == null ? '' : data.text);
    // a leading [E] becomes a key chip, like lulu_interact's prompt
    let key = null;
    const m = /^\s*\[([^\]]{1,6})\]\s*(.*)$/s.exec(text);
    if (m) { key = m[1]; text = m[2].replace(/^[-–—:]\s*/, ''); }

    clearTimeout(tuiTimer);
    if (!tui) {
      tui = document.createElement('div');
      document.body.appendChild(tui);
    }
    tui.className = 'ox-textui ox-surface ' + pos + (data.alignIcon === 'top' ? ' top-icon' : '');
    tui.removeAttribute('style');
    if (data.style) {
      if (typeof data.style === 'string') tui.style.cssText = data.style;
      else Object.keys(data.style).forEach((k) => { try { tui.style[k] = data.style[k]; } catch (e) { /* ignore */ } });
    }
    tui.innerHTML =
      (key ? '<span class="key">' + Ox.esc(key) + '</span>' : '') +
      (data.icon ? '<span class="ic">' + Ox.icon(data.icon, { animation: data.iconAnimation, color: data.iconColor }) + '</span>' : '') +
      '<span class="tx">' + Ox.md(text) + '</span>';
    void tui.offsetWidth;                         // restart the transition
    tui.classList.add('show');
  });

  Ox.on('textUiHide', function () {
    if (!tui) return;
    tui.classList.remove('show');
    const el = tui;
    tuiTimer = setTimeout(() => { if (el === tui && !el.classList.contains('show')) { el.remove(); tui = null; } }, 260);
  });
})();
