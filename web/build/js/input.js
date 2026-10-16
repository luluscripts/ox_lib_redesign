/* input dialog (lib.inputDialog) */
(function () {
  'use strict';
  const Ox = window.Ox;

  const SIZES = { xs: '30rem', sm: '38rem', md: '46rem', lg: '60rem', xl: '80rem' };
  let wrap = null, keyFn = null, fields = [];

  // ------------------------------------------------------------------ helpers
  const pad = (n, l) => String(n).padStart(l || 2, '0');
  function fmt(d, f) {
    return String(f).replace(/YYYY|YY|MM|DD|HH|mm|ss|M|D|H/g, (t) => ({
      YYYY: d.getFullYear(), YY: pad(d.getFullYear() % 100), MM: pad(d.getMonth() + 1), M: d.getMonth() + 1,
      DD: pad(d.getDate()), D: d.getDate(), HH: pad(d.getHours()), H: d.getHours(), mm: pad(d.getMinutes()), ss: pad(d.getSeconds()),
    }[t]));
  }
  function toDate(v) {
    if (v == null || v === '') return null;
    const d = typeof v === 'number' ? new Date(v) : new Date(String(v));
    return isNaN(d.getTime()) ? null : d;
  }
  const dateValue = (d) => (d ? d.getFullYear() + '-' + pad(d.getMonth() + 1) + '-' + pad(d.getDate()) : '');
  const timeValue = (d) => (d ? pad(d.getHours()) + ':' + pad(d.getMinutes()) : '');
  function parseDateInput(s) { if (!s) return null; const p = s.split('-').map(Number); return new Date(p[0], p[1] - 1, p[2]); }
  function parseTimeInput(s) { if (!s) return null; const p = s.split(':').map(Number); const d = new Date(); d.setHours(p[0], p[1] || 0, 0, 0); return d; }
  const out = (d, row, defFmt) => (d ? (row.returnString ? fmt(d, row.format || defFmt) : d.getTime()) : null);

  // color values: stored as #RRGGBB, returned in the requested format
  function colorOut(hex, format) {
    if (!hex) return null;
    if (format === 'rgb' || format === 'rgba') {
      const c = Ox.rgb(hex);
      return format === 'rgba' ? 'rgba(' + c.join(', ') + ', 1)' : 'rgb(' + c.join(', ') + ')';
    }
    return hex.toUpperCase();
  }

  function label(row, i) {
    return '<label>' + Ox.esc(row.label || '') + (row.required ? '<span class="req">*</span>' : '') + '</label>' +
      (row.description ? '<div class="desc">' + Ox.md(row.description) + '</div>' : '');
  }

  // ------------------------------------------------------------------ one builder per row type; each returns { el, get(), valid() }
  const BUILD = {
    input(row) {
      const wrapEl = Ox.el('<div class="ox-inwrap"></div>');
      const input = document.createElement('input');
      input.className = 'ox-input';
      input.type = row.password ? 'password' : 'text';
      input.placeholder = row.placeholder || '';
      input.value = row.default != null ? row.default : '';
      input.disabled = !!row.disabled;
      if (row.maxLength) input.maxLength = row.maxLength;
      if (row.icon) { wrapEl.insertAdjacentHTML('beforeend', '<span class="ico">' + Ox.icon(row.icon, { color: row.iconColor }) + '</span>'); }
      wrapEl.appendChild(input);
      if (row.password) {
        const eye = Ox.el('<button type="button" class="eye" tabindex="-1"><i class="fa-solid fa-eye"></i></button>');
        eye.addEventListener('click', () => { input.type = input.type === 'password' ? 'text' : 'password'; eye.firstChild.className = input.type === 'password' ? 'fa-solid fa-eye' : 'fa-solid fa-eye-slash'; });
        wrapEl.appendChild(eye);
      }
      return { el: wrapEl, focus: () => input.focus(), get: () => input.value, valid: () => {
        const v = input.value;
        if (row.required && !v.trim()) return 'Required';
        if (row.minLength && v.length < row.minLength) return 'At least ' + row.minLength + ' characters';
        return '';
      }, mark: (bad) => input.classList.toggle('err', bad), input };
    },
    number(row) {
      const wrapEl = Ox.el('<div class="ox-inwrap"></div>');
      const input = document.createElement('input');
      input.className = 'ox-input'; input.type = 'number';
      input.placeholder = row.placeholder || '';
      if (row.min != null) input.min = row.min;
      if (row.max != null) input.max = row.max;
      input.step = row.step != null ? row.step : 'any';
      if (row.default != null) input.value = row.default;
      input.disabled = !!row.disabled;
      if (row.icon) wrapEl.insertAdjacentHTML('beforeend', '<span class="ico">' + Ox.icon(row.icon, { color: row.iconColor }) + '</span>');
      wrapEl.appendChild(input);
      const num = () => (input.value === '' ? null : Number(input.value));
      return { el: wrapEl, focus: () => input.focus(), get: num, valid: () => {
        const v = num();
        if (v == null) return row.required ? 'Required' : '';
        if (row.min != null && v < row.min) return 'Minimum is ' + row.min;
        if (row.max != null && v > row.max) return 'Maximum is ' + row.max;
        return '';
      }, mark: (bad) => input.classList.toggle('err', bad), input };
    },
    textarea(row) {
      const ta = document.createElement('textarea');
      ta.className = 'ox-textarea';
      ta.placeholder = row.placeholder || '';
      ta.value = row.default != null ? row.default : '';
      ta.disabled = !!row.disabled;
      if (row.maxLength) ta.maxLength = row.maxLength;
      ta.rows = row.autosize ? 2 : Math.max(2, Number(row.min) || 3);
      const grow = () => { if (row.autosize) { ta.style.height = 'auto'; ta.style.height = Math.min(ta.scrollHeight + 2, window.innerHeight * 0.3) + 'px'; } };
      ta.addEventListener('input', grow);
      setTimeout(grow, 0);
      return { el: ta, focus: () => ta.focus(), get: () => ta.value, valid: () => {
        if (row.required && !ta.value.trim()) return 'Required';
        if (row.minLength && ta.value.length < row.minLength) return 'At least ' + row.minLength + ' characters';
        return '';
      }, mark: (bad) => ta.classList.toggle('err', bad), input: ta };
    },
    checkbox(row) {
      let on = !!row.checked;
      const el = Ox.el('<div class="ox-check' + (row.disabled ? ' disabled' : '') + '"><span>' + Ox.esc(row.label || '') + '</span><span class="ox-switch' + (on ? ' on' : '') + '"><i></i></span></div>');
      el.addEventListener('click', () => { if (row.disabled) return; on = !on; el.querySelector('.ox-switch').classList.toggle('on', on); });
      return { el, noLabel: true, get: () => on, valid: () => (row.required && !on ? 'Required' : ''), mark: () => {} };
    },
    select(row) {
      const sel = document.createElement('select');
      sel.className = 'ox-select';
      sel.disabled = !!row.disabled;
      const opts = row.options || [];
      const placeholder = row.placeholder || (row.clearable || row.required ? 'Select…' : '');
      sel.innerHTML = (placeholder ? '<option value="">' + Ox.esc(placeholder) + '</option>' : '') +
        opts.map((o) => '<option value="' + Ox.esc(o.value) + '">' + Ox.esc(o.label || o.value) + '</option>').join('');
      const def = row.default != null ? row.default : (opts.find((o) => o.default) || {}).value;
      if (def != null) sel.value = def; else if (!placeholder && opts.length) sel.value = opts[0].value;
      return { el: sel, focus: () => sel.focus(), get: () => (sel.value === '' ? null : sel.value), valid: () => (row.required && sel.value === '' ? 'Required' : ''), mark: (bad) => sel.classList.toggle('err', bad), input: sel };
    },
    'multi-select'(row) {
      const opts = row.options || [];
      const max = row.maxSelectedValues;
      const chosen = new Set(Array.isArray(row.default) ? row.default : opts.filter((o) => o.default).map((o) => o.value));
      const el = Ox.el('<div class="ox-multi"></div>');
      let q = null;
      if (row.searchable) {
        q = document.createElement('input'); q.className = 'ox-input'; q.placeholder = 'Search…';
        q.addEventListener('input', paint);
        el.appendChild(q);
      }
      const list = document.createElement('div'); list.style.display = 'contents'; el.appendChild(list);
      function paint() {
        const term = q ? q.value.toLowerCase() : '';
        list.innerHTML = opts.filter((o) => !term || String(o.label || o.value).toLowerCase().includes(term)).map((o) => {
          const on = chosen.has(o.value), full = max && chosen.size >= max && !on;
          return '<div class="opt' + (on ? ' on' : '') + (full ? ' off' : '') + '" data-v="' + Ox.esc(o.value) + '"><span>' + Ox.esc(o.label || o.value) + '</span>' + (on ? '<i class="fa-solid fa-check"></i>' : '') + '</div>';
        }).join('');
      }
      el.addEventListener('click', (e) => {
        const opt = e.target.closest('.opt'); if (!opt || row.disabled) return;
        const v = opts.map((o) => o.value).find((x) => String(x) === opt.getAttribute('data-v'));
        if (chosen.has(v)) chosen.delete(v); else if (!max || chosen.size < max) chosen.add(v);
        paint();
      });
      paint();
      return { el, get: () => Array.from(chosen), valid: () => (row.required && !chosen.size ? 'Select at least one' : ''), mark: (bad) => { el.style.borderColor = bad ? 'var(--danger)' : ''; } };
    },
    slider(row) {
      const min = row.min != null ? row.min : 0, max = row.max != null ? row.max : 100, step = row.step != null ? row.step : 1;
      const el = Ox.el('<div class="ox-slider"><input type="range" class="ox-range"><span class="val"></span></div>');
      const r = el.querySelector('input'), val = el.querySelector('.val');
      r.min = min; r.max = max; r.step = step; r.disabled = !!row.disabled;
      r.value = row.default != null ? row.default : min;
      const show = () => { val.textContent = r.value; };
      r.addEventListener('input', show); show();
      return { el, get: () => Number(r.value), valid: () => '', mark: () => {}, set: (v) => { r.value = v; show(); } };
    },
    date(row) {
      const input = document.createElement('input');
      input.className = 'ox-input'; input.type = 'date'; input.disabled = !!row.disabled;
      const min = toDate(row.min), max = toDate(row.max);
      if (min) input.min = dateValue(min); if (max) input.max = dateValue(max);
      input.value = dateValue(toDate(row.default));
      return { el: input, focus: () => input.focus(), get: () => out(parseDateInput(input.value), row, 'DD/MM/YYYY'), valid: () => (row.required && !input.value ? 'Required' : ''), mark: (bad) => input.classList.toggle('err', bad), input };
    },
    'date-range'(row) {
      const el = Ox.el('<div class="ox-range2"><input class="ox-input" type="date"><input class="ox-input" type="date"></div>');
      const [a, b] = el.querySelectorAll('input');
      const def = Array.isArray(row.default) ? row.default : [];
      a.value = dateValue(toDate(def[0])); b.value = dateValue(toDate(def[1]));
      a.disabled = b.disabled = !!row.disabled;
      return { el, get: () => [out(parseDateInput(a.value), row, 'DD/MM/YYYY'), out(parseDateInput(b.value), row, 'DD/MM/YYYY')], valid: () => (row.required && (!a.value || !b.value) ? 'Required' : ''), mark: (bad) => { a.classList.toggle('err', bad); b.classList.toggle('err', bad); } };
    },
    time(row) {
      const input = document.createElement('input');
      input.className = 'ox-input'; input.type = 'time'; input.disabled = !!row.disabled;
      // default may be a 'HH:mm' string or a timestamp
      const dflt = typeof row.default === 'string' && /^\d{1,2}:\d{2}/.test(row.default) ? row.default.split(':').slice(0, 2).map((x) => pad(x)).join(':') : timeValue(toDate(row.default));
      input.value = dflt;
      return { el: input, focus: () => input.focus(), get: () => out(parseTimeInput(input.value), row, 'HH:mm'), valid: () => (row.required && !input.value ? 'Required' : ''), mark: (bad) => input.classList.toggle('err', bad), input };
    },
    color(row) {
      let hex = Ox.HEX.test(row.default) ? row.default.toUpperCase() : '#FFFFFF';
      const field = Ox.hexField(hex, (v) => { hex = v; });
      field.style.width = '100%'; field.style.justifyContent = 'flex-start';
      return { el: field, get: () => colorOut(hex, row.format), valid: () => '', mark: () => {}, set: (v) => { if (!Ox.HEX.test(v)) return; hex = String(v).toUpperCase(); field.setValue(hex); } };
    },
    // action button: row.resets = [{ index = 0-based field index, value = v }] sets those fields back in place; submits false
    button(row) {
      const b = document.createElement('button');
      b.type = 'button'; b.className = 'ox-btn ox-rowbtn'; b.textContent = row.label || '';
      b.disabled = !!row.disabled;
      b.addEventListener('click', () => {
        (row.resets || []).forEach((x) => { const f = x && fields[Number(x.index)]; if (f && f.set && x.value != null) f.set(x.value); });
      });
      return { el: b, noLabel: true, get: () => false, valid: () => '', mark: () => {} };
    },
  };

  // ------------------------------------------------------------------ dialog
  function teardown() {
    Ox.closeColorPop();
    if (keyFn) { Ox.popKeys(keyFn); keyFn = null; }
    if (wrap) {
      const el = wrap; wrap = null;
      el.classList.remove('show');
      setTimeout(() => el.remove(), 200);
    }
    fields = [];
  }

  function submit() {
    let ok = true, first = null;
    fields.forEach((f) => {
      const msg = f.valid();
      f.mark(!!msg);
      const slot = f.wrapper && f.wrapper.querySelector('.err-msg');
      if (slot) slot.textContent = msg;
      if (msg) { ok = false; if (!first) first = f; }
    });
    if (!ok) { if (first && first.focus) first.focus(); return; }
    const values = fields.map((f) => f.get());
    Ox.post('inputData', values);
    teardown();
  }

  function cancel() {
    Ox.post('inputData', null);
    teardown();
  }

  Ox.on('openDialog', function (d) {
    if (!d) return;
    teardown();
    const rows = d.rows || [];
    const opts = d.options || {};
    const allowCancel = opts.allowCancel !== false;
    const size = SIZES[opts.size] || SIZES.md;

    wrap = document.createElement('div');
    wrap.className = 'ox-modal-wrap';
    wrap.innerHTML =
      '<div class="ox-modal ox-surface" style="--w:' + size + '">' +
        '<h2>' + Ox.esc(d.heading || '') + '</h2>' +
        '<form class="ox-form" novalidate></form>' +
        '<div class="ox-modal-actions">' +
          (allowCancel ? '<button type="button" class="ox-btn" data-cancel>' + Ox.esc(Ox.t('cancel', 'Cancel')) + '</button>' : '') +
          '<button type="button" class="ox-btn primary" data-ok>' + Ox.esc(Ox.t('confirm', 'Confirm')) + '</button>' +
        '</div>' +
      '</div>';
    const form = wrap.querySelector('form');
    fields = rows.map((row, i) => {
      const build = BUILD[row.type] || BUILD.input;
      const f = build(row);
      const w = document.createElement('div');
      w.className = 'ox-field';
      if (!f.noLabel) w.insertAdjacentHTML('beforeend', label(row, i));
      w.appendChild(f.el);
      w.insertAdjacentHTML('beforeend', '<div class="err-msg"></div>');
      f.wrapper = w;
      form.appendChild(w);
      return f;
    });

    document.body.appendChild(wrap);
    wrap.querySelector('[data-ok]').addEventListener('click', submit);
    const c = wrap.querySelector('[data-cancel]');
    if (c) c.addEventListener('click', cancel);
    form.addEventListener('submit', (e) => e.preventDefault());
    void wrap.offsetWidth;
    wrap.classList.add('show');
    const firstFocus = fields.find((f) => f.focus);
    if (firstFocus) setTimeout(() => firstFocus.focus(), 60);

    keyFn = Ox.pushKeys((e) => {
      if (e.key === 'Escape') { if (allowCancel) cancel(); return true; }
      if (e.key === 'Enter' && !(e.target && e.target.tagName === 'TEXTAREA')) { e.preventDefault(); submit(); return true; }
      return true;
    });
  });

  Ox.on('closeInputDialog', teardown);
})();
