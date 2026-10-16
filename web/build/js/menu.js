/* list menu (lib.registerMenu / lib.showMenu): keyboard driven, mouse works too */
(function () {
  'use strict';
  const Ox = window.Ox;

  let root = null, tip = null, keyFn = null, M = null;
  let sel = 0;
  let scroll = {};   // item index -> current values index (0 based)
  let checked = {};  // item index -> boolean
  const timers = {};

  const label = (v) => (v && typeof v === 'object' ? v.label : v);
  const hasValues = (it) => Array.isArray(it.values);
  const hasCheck = (it) => it.checked !== undefined;

  // Lua reads these back (indexes are 0 based here, Lua adds 1)
  function later(key, fn) { clearTimeout(timers[key]); timers[key] = setTimeout(fn, 100); }

  function itemHtml(it, i) {
    const iconHtml = Ox.icon(it.icon, { animation: it.iconAnimation, color: it.iconColor });
    let body, right = '';
    if (hasValues(it)) {
      body = '<span class="t">' + Ox.esc(it.label) + '</span><span class="v">' + Ox.esc(label(it.values[scroll[i]])) + '</span>';
      right = '<span class="scroll"><button data-dir="-1" tabindex="-1"><i class="fa-solid fa-chevron-left"></i></button>' +
        '<span>' + (scroll[i] + 1) + '/' + it.values.length + '</span>' +
        '<button data-dir="1" tabindex="-1"><i class="fa-solid fa-chevron-right"></i></button></span>';
    } else if (hasCheck(it)) {
      body = '<span class="t">' + Ox.esc(it.label) + '</span>';
      right = '<span class="ox-switch' + (checked[i] ? ' on' : '') + '"><i></i></span>';
    } else if (it.progress !== undefined) {
      const c = Ox.scheme(it.colorScheme);
      body = '<span class="t">' + Ox.esc(it.label) + '</span><span class="ox-progress"' + (c ? ' style="--c:' + c + '"' : '') + '><i style="width:' + Ox.clamp(Number(it.progress), 0, 100) + '%"></i></span>';
    } else {
      body = '<span class="t">' + Ox.esc(it.label) + '</span>';
    }
    return '<div class="ox-mi' + (i === sel ? ' sel' : '') + '" data-i="' + i + '">' +
      (iconHtml ? '<span class="ic">' + iconHtml + '</span>' : '') + '<span class="tx">' + body + '</span>' + right + '</div>';
  }

  function description() {
    const it = M.items[sel];
    if (!it) return '';
    if (hasValues(it) && it.values[scroll[sel]] && typeof it.values[scroll[sel]] === 'object') return it.values[scroll[sel]].description || '';
    return it.description || '';
  }

  function placeTip() {
    if (!tip) return;
    const d = description();
    if (!d) { tip.classList.remove('show'); return; }
    tip.innerHTML = Ox.md(d);
    const row = root.querySelector('.ox-mi.sel');
    const r = root.getBoundingClientRect(), a = row ? row.getBoundingClientRect() : r;
    const right = M.position === 'top-right' || M.position === 'bottom-right';
    tip.classList.add('show');
    tip.style.left = right ? Math.max(8, r.left - tip.offsetWidth - 12) + 'px' : Math.min(window.innerWidth - tip.offsetWidth - 8, r.right + 12) + 'px';
    tip.style.top = Ox.clamp(a.top, 8, window.innerHeight - tip.offsetHeight - 8) + 'px';
  }

  function render() {
    const list = root.querySelector('.ox-menu-list');
    const top = list.scrollTop;
    list.innerHTML = M.items.map(itemHtml).join('');
    list.scrollTop = top;
    const row = list.querySelector('.ox-mi.sel');
    if (row) row.scrollIntoView({ block: 'nearest' });
    placeTip();
  }

  function selectedPayload() {
    const it = M.items[sel];
    return [sel, hasValues(it) ? scroll[sel] : undefined, hasCheck(it) ? !!checked[sel] : undefined];
  }

  function announceSelected() {
    const it = M.items[sel];
    if (!it) return;
    later('selected', () => {
      Ox.post('changeSelected', [sel, hasValues(it) ? scroll[sel] : hasCheck(it) ? !!checked[sel] : null, hasValues(it) ? 'isScroll' : hasCheck(it) ? 'isCheck' : null]);
    });
  }

  function move(delta) {
    const n = M.items.length;
    sel = (sel + delta + n) % n;
    render();
    announceSelected();
  }

  function scrollValue(i, dir) {
    const it = M.items[i];
    if (!hasValues(it)) return;
    const n = it.values.length;
    scroll[i] = (scroll[i] + dir + n) % n;
    render();
    later('index', () => Ox.post('changeIndex', [i, scroll[i]]));
    announceSelected();
  }

  function toggleCheck(i) {
    checked[i] = !checked[i];
    render();
    later('checked', () => Ox.post('changeChecked', [i, !!checked[i]]));
    announceSelected();
  }

  function confirm(i) {
    const it = M.items[i];
    if (!it) return;
    if (hasCheck(it) && !hasValues(it)) return toggleCheck(i);
    sel = i;
    const payload = selectedPayload();
    Ox.post('confirmSelected', payload);
    if (it.close !== false) teardown();
  }

  function requestClose(key) {
    if (!M || M.canClose === false) return;
    Ox.post('closeMenu', key);
    teardown();
  }

  function onKey(e) {
    switch (e.code) {
      case 'ArrowDown': move(1); return true;
      case 'ArrowUp': move(-1); return true;
      case 'ArrowRight': scrollValue(sel, 1); return true;
      case 'ArrowLeft': scrollValue(sel, -1); return true;
      case 'Enter': case 'NumpadEnter': confirm(sel); return true;
      case 'Escape': case 'Backspace': requestClose(e.code); return true;
      default: return false;
    }
  }

  function teardown() {
    if (keyFn) { Ox.popKeys(keyFn); keyFn = null; }
    Object.keys(timers).forEach((k) => clearTimeout(timers[k]));
    if (tip) { tip.remove(); tip = null; }
    if (root) {
      const el = root; root = null;
      el.classList.remove('show');
      setTimeout(() => el.remove(), 220);
    }
    M = null;
  }

  Ox.on('setMenu', function (data) {
    if (!data || !data.items || !data.items.length) return;
    const wasOpen = !!root;
    if (wasOpen) { Object.keys(timers).forEach((k) => clearTimeout(timers[k])); }
    M = data;
    M.position = ['top-left', 'top-right', 'bottom-left', 'bottom-right'].indexOf(M.position) !== -1 ? M.position : 'top-left';
    sel = Ox.clamp(Number(M.startItemIndex) || 0, 0, M.items.length - 1);
    scroll = {}; checked = {};
    M.items.forEach((it, i) => {
      if (hasValues(it)) scroll[i] = Math.max(0, (Number(it.defaultIndex) || 1) - 1);
      if (hasCheck(it)) checked[i] = !!it.checked;
    });

    if (!root) {
      root = document.createElement('div');
      document.body.appendChild(root);
      tip = document.createElement('div');
      tip.className = 'ox-menu-tip ox-surface';
      document.body.appendChild(tip);
      keyFn = Ox.pushKeys(onKey);
    }
    root.className = 'ox-menu ox-surface ' + M.position;
    root.innerHTML = '<div class="ox-menu-head">' + Ox.esc(M.title || '') + '</div><div class="ox-menu-list"></div>';
    render();
    void root.offsetWidth;
    root.classList.add('show');
    announceSelected();

    root.querySelector('.ox-menu-list').addEventListener('click', (e) => {
      const row = e.target.closest('.ox-mi');
      if (!row) return;
      const i = Number(row.getAttribute('data-i'));
      const dirBtn = e.target.closest('[data-dir]');
      if (dirBtn) { sel = i; scrollValue(i, Number(dirBtn.getAttribute('data-dir'))); return; }
      if (sel !== i) { sel = i; render(); announceSelected(); }
      confirm(i);
    });
  });

  Ox.on('closeMenu', teardown);
})();
