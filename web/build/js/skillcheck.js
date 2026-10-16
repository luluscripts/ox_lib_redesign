/* skill check (lib.skillCheck): a needle sweeps the ring, press the key while it is inside the highlighted zone */
(function () {
  'use strict';
  const Ox = window.Ox;

  const AREA = { easy: 50, medium: 40, hard: 25 };       // degrees
  const SPEED = { easy: 1, medium: 1.5, hard: 1.75 };    // x 250 deg/s
  const R = 90, C = 2 * Math.PI * R;

  let root = null, keyFn = null, raf = 0, S = null;

  const rand = (a, b) => Math.floor(Math.random() * (b - a)) + a;

  // the pressed key, as a lowercase latin letter/digit even on non-latin layouts
  function pressed(e) {
    let k = (e.key || '').toLowerCase();
    if (k.length === 1 && k.charCodeAt(0) >= 880) {
      if (e.code.indexOf('Key') === 0 && e.code.length === 4) k = e.code.charAt(3).toLowerCase();
      if (e.code.indexOf('Digit') === 0 && e.code.length === 6) k = e.code.charAt(5);
    }
    return k;
  }

  function stepConfig(d) {
    if (d && typeof d === 'object') return { size: Number(d.areaSize) || 40, speed: Number(d.speedMultiplier) || 1 };
    const name = AREA[d] ? d : 'easy';
    return { size: AREA[name], speed: SPEED[name] };
  }

  function teardown() {
    cancelAnimationFrame(raf); raf = 0;
    if (keyFn) { Ox.popKeys(keyFn); keyFn = null; }
    if (root) {
      const el = root; root = null;
      el.classList.remove('show');
      setTimeout(() => el.remove(), 180);
    }
    S = null;
  }

  function finish(success) {
    Ox.post('skillCheckOver', !!success);
    teardown();
  }

  function setup(step) {
    const cfg = stepConfig(S.steps[step]);
    S.cfg = cfg;
    S.start = rand(120, 360 - cfg.size);                      // zone start, degrees clockwise from the top
    S.key = S.inputs[rand(0, S.inputs.length)];
    S.angle = 0;
    S.last = 0;
    S.locked = false;
    const area = root.querySelector('.area'), key = root.querySelector('.ox-skill-key');
    area.setAttribute('stroke-dasharray', (C * cfg.size / 360) + ' ' + C);
    area.setAttribute('stroke-dashoffset', String(-C * S.start / 360));
    key.textContent = S.key;
    key.className = 'ox-skill-key';
    root.querySelector('[data-count]').textContent = (step + 1) + '/' + S.steps.length;
    root.querySelector('[data-hint]').textContent = S.key.toUpperCase();
  }

  function tick(t) {
    if (!S || S.locked) return;
    if (!S.last) S.last = t;
    S.angle += (t - S.last) * 0.25 * S.cfg.speed;             // 250 deg/s at 1x
    S.last = t;
    if (S.angle >= 360) return resolve(false);
    root.querySelector('.needle').setAttribute('transform', 'rotate(' + S.angle + ' 100 100)');
    raf = requestAnimationFrame(tick);
  }

  // ends the current attempt, flashes the result, then moves on / finishes
  function resolve(ok) {
    if (!S || S.locked) return;
    S.locked = true;
    cancelAnimationFrame(raf);
    root.querySelector('.ox-skill-key').classList.add(ok ? 'hit' : 'miss');
    setTimeout(() => {
      if (!S) return;
      if (!ok) return finish(false);
      S.step += 1;
      if (S.step >= S.steps.length) return finish(true);
      setup(S.step);
      raf = requestAnimationFrame(tick);
    }, 220);
  }

  Ox.on('startSkillCheck', function (data) {
    if (!data) return;
    teardown();
    const diff = data.difficulty;
    const steps = Array.isArray(diff) ? diff : [diff];
    const inputs = (Array.isArray(data.inputs) && data.inputs.length ? data.inputs : ['e']).map((k) => String(k).toLowerCase());
    S = { steps, inputs, step: 0 };

    root = document.createElement('div');
    root.className = 'ox-skill';
    root.innerHTML =
      '<div class="ox-skill-dial">' +
        '<svg viewBox="0 0 200 200"><circle class="track" cx="100" cy="100" r="' + R + '"></circle>' +
        '<circle class="area" cx="100" cy="100" r="' + R + '"></circle>' +
        '<line class="needle" x1="178" y1="100" x2="204" y2="100"></line></svg>' +
        '<div class="ox-skill-key"></div>' +
      '</div>' +
      '<div class="ox-skill-info ox-surface"><span>Skill check</span><b data-count></b><span>Press <b data-hint></b> inside the zone</span></div>';
    document.body.appendChild(root);
    setup(0);
    void root.offsetWidth;
    root.classList.add('show');

    keyFn = Ox.pushKeys((e) => {
      if (!S || S.locked || e.repeat) return true;
      const k = pressed(e);
      if (S.inputs.length && S.inputs.indexOf(k) === -1) return true;   // not one of this check's keys: ignored
      const inZone = S.angle >= S.start && S.angle <= S.start + S.cfg.size;
      resolve(k === S.key && inZone);
      return true;
    });
    raf = requestAnimationFrame(tick);
  });

  Ox.on('skillCheckCancel', function () {
    if (!S) return;
    finish(false);
  });
})();
