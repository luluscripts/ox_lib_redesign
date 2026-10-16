/* context menu (lib.registerContext / lib.showContext) */
(function () {
  'use strict';
  const Ox = window.Ox;

  let root = null, data = null, meta = null, keyFn = null;

  function entries(options) {
    // options is an array or an object keyed by id; Lua expects the same key back in clickContext
    if (Array.isArray(options)) return options.map((o, i) => [String(i), o]);
    return Object.keys(options || {}).map((k) => [k, options[k]]);
  }

  function hideMeta() { if (meta) { meta.remove(); meta = null; } }

  function metaRows(opt) {
    const m = opt.metadata;
    let rows = [];
    if (Array.isArray(m)) {
      rows = m.map((x) => (typeof x === 'string' ? { text: x } : x));
    } else if (m && typeof m === 'object') {
      rows = Object.keys(m).map((k) => ({ label: k, value: m[k] }));
    } else if (typeof m === 'string') {
      rows = [{ text: m }];
    }
    return rows;
  }

  function showMeta(opt, anchor) {
    hideMeta();
    const rows = metaRows(opt);
    if (!rows.length && !opt.image) return;
    meta = document.createElement('div');
    meta.className = 'ox-meta ox-surface';
    meta.innerHTML = (opt.image ? '<img src="' + Ox.esc(opt.image) + '" alt="">' : '') + rows.map((r) => {
      const label = r.text != null ? '<b>' + Ox.esc(r.text) + '</b>' : '<b>' + Ox.esc(r.label) + '</b>' + (r.value != null ? ': ' + Ox.esc(r.value) : '');
      const bar = r.progress != null ? '<div class="ox-progress"' + (Ox.scheme(r.colorScheme || opt.colorScheme) ? ' style="--c:' + Ox.scheme(r.colorScheme || opt.colorScheme) + '"' : '') + '><i style="width:' + Ox.clamp(Number(r.progress), 0, 100) + '%"></i></div>' : '';
      return '<div class="row">' + label + bar + '</div>';
    }).join('');
    document.body.appendChild(meta);
    const a = anchor.getBoundingClientRect(), p = root.getBoundingClientRect();
    meta.style.left = Math.max(8, p.left - meta.offsetWidth - 12) + 'px';
    meta.style.top = Ox.clamp(a.top, 8, window.innerHeight - meta.offsetHeight - 8) + 'px';
  }

  function render() {
    const opts = entries(data.options);
    const canClose = data.canClose !== false;
    root.innerHTML =
      '<div class="ox-context-head">' +
        (data.menu ? '<button class="ox-iconbtn" data-back title="Back"><i class="fa-solid fa-chevron-left"></i></button>' : '') +
        '<h2>' + Ox.esc(data.title || '') + '</h2>' +
        (canClose ? '<button class="ox-iconbtn" data-close title="' + Ox.esc(Ox.t('close', 'Close')) + '"><i class="fa-solid fa-xmark"></i></button>' : '') +
      '</div>' +
      '<div class="ox-context-list">' + opts.map((pair, i) => {
        const o = pair[1] || {};
        const cls = 'ox-opt' + (o.disabled ? ' disabled' : '') + (o.readOnly ? ' readonly' : '');
        const color = Ox.scheme(o.colorScheme);
        const iconHtml = o.image && !o.icon ? '' : Ox.icon(o.icon, { animation: o.iconAnimation, color: o.iconColor });
        return '<button class="' + cls + '" data-i="' + i + '" ' + (o.disabled ? 'disabled' : '') + '>' +
          (iconHtml ? '<span class="ic">' + iconHtml + '</span>' : '') +
          '<span class="tx"><span class="t">' + Ox.esc(o.title || pair[0]) + '</span>' +
            (o.description ? '<span class="d">' + Ox.md(o.description) + '</span>' : '') +
            (o.progress != null ? '<span class="ox-progress"' + (color ? ' style="--c:' + color + '"' : '') + '><i style="width:' + Ox.clamp(Number(o.progress), 0, 100) + '%"></i></span>' : '') +
          '</span>' +
          ((o.menu || o.arrow) && o.arrow !== false ? '<span class="arrow"><i class="fa-solid fa-chevron-right"></i></span>' : '') +
        '</button>';
      }).join('') + '</div>';

    const buttons = root.querySelectorAll('.ox-opt');
    buttons.forEach((b) => {
      const pair = opts[Number(b.getAttribute('data-i'))], o = pair[1] || {};
      b.addEventListener('mouseenter', () => showMeta(o, b));
      b.addEventListener('mouseleave', hideMeta);
      b.addEventListener('click', () => {
        if (o.disabled || o.readOnly) return;
        hideMeta();
        if (o.menu) Ox.post('openContext', { id: o.menu, back: false });
        else Ox.post('clickContext', pair[0]);
      });
    });
    const back = root.querySelector('[data-back]');
    if (back) back.addEventListener('click', () => { hideMeta(); Ox.post('openContext', { id: data.menu, back: true }); });
    const close = root.querySelector('[data-close]');
    if (close) close.addEventListener('click', () => { requestClose(); });
  }

  function hide() {
    hideMeta();
    if (keyFn) { Ox.popKeys(keyFn); keyFn = null; }
    if (root) {
      const el = root; root = null;
      el.classList.remove('show');
      setTimeout(() => el.remove(), 220);
    }
    data = null;
  }

  function requestClose() {
    if (!data || data.canClose === false) return;
    Ox.post('closeContext');
    hide();
  }

  Ox.on('showContext', function (d) {
    hideMeta();
    data = d || {};
    const fresh = !root;
    if (fresh) {
      root = document.createElement('div');
      root.className = 'ox-context ox-surface';
      document.body.appendChild(root);
      keyFn = Ox.pushKeys((e) => {
        if (e.key === 'Escape') { requestClose(); return true; }
        return false;
      });
      void root.offsetWidth;
    }
    render();
    root.classList.add('show');
  });

  Ox.on('hideContext', hide);
})();
