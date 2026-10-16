/* alert dialog (lib.alertDialog) */
(function () {
  'use strict';
  const Ox = window.Ox;

  const SIZES = { xs: '30rem', sm: '38rem', md: '46rem', lg: '60rem', xl: '80rem' };
  let wrap = null, keyFn = null, current = null;

  function teardown() {
    if (keyFn) { Ox.popKeys(keyFn); keyFn = null; }
    if (wrap) {
      const el = wrap; wrap = null;
      el.classList.remove('show');
      setTimeout(() => el.remove(), 200);
    }
    current = null;
  }

  function answer(value) {
    if (!current) return;
    Ox.post('closeAlert', value);
    teardown();
  }

  Ox.on('sendAlert', function (d) {
    if (!d) return;
    teardown();
    current = d;
    const size = SIZES[d.size] || (typeof d.size === 'string' && /^\d/.test(d.size) ? d.size : SIZES.md);
    wrap = document.createElement('div');
    wrap.className = 'ox-modal-wrap';
    const labels = d.labels || {};
    wrap.innerHTML =
      '<div class="ox-modal ox-surface' + (d.centered ? ' center' : '') + '" style="--w:' + size + '">' +
        (d.header ? '<h2>' + Ox.esc(d.header) + '</h2>' : '') +
        '<div class="ox-modal-body' + (d.overflow ? ' inside' : '') + '">' + Ox.md(d.content) + '</div>' +
        '<div class="ox-modal-actions">' +
          (d.cancel ? '<button class="ox-btn" data-cancel>' + Ox.esc(labels.cancel || Ox.t('cancel', 'Cancel')) + '</button>' : '') +
          '<button class="ox-btn primary" data-confirm>' + Ox.esc(labels.confirm || Ox.t('confirm', 'Confirm')) + '</button>' +
        '</div>' +
      '</div>';
    document.body.appendChild(wrap);
    wrap.querySelector('[data-confirm]').addEventListener('click', () => answer('confirm'));
    const cancel = wrap.querySelector('[data-cancel]');
    if (cancel) cancel.addEventListener('click', () => answer('cancel'));
    void wrap.offsetWidth;
    wrap.classList.add('show');
    wrap.querySelector('[data-confirm]').focus();

    keyFn = Ox.pushKeys((e) => {
      if (e.key === 'Escape') { if (d.cancel) answer('cancel'); return true; }
      if (e.key === 'Enter') { answer('confirm'); return true; }
      return true;   // modal: swallow everything else
    });
  });

  Ox.on('closeAlertDialog', teardown);
})();
