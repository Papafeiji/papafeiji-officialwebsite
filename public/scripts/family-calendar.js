(function () {
  const colors = ['#FCD34D', '#93C5FD', '#6EE7B7', '#C4B5FD'];
  const now = new Date();
  const today = now.getDate();
  const y = now.getFullYear();
  const m = now.getMonth();

  const el = document.getElementById('cal-month');
  if (el) {
    const isEn = document.documentElement.lang === 'en';
    el.textContent = isEn
      ? now.toLocaleString('en', { month: 'long', year: 'numeric' })
      : `${y}年${m + 1}月`;
  }

  const grid = document.getElementById('cal-grid');
  if (!grid) return;

  grid.querySelectorAll('.cal-cell').forEach((cell) => {
    const day = parseInt(cell.dataset.day, 10);
    if (!day || day > today) return;

    const count = 1 + ((day * 7 + 3) % 4);
    const active = new Set();
    for (let i = 0; i < count; i++) active.add((day * 3 + i * 2) % 4);

    cell.classList.add('bg-surface-03');
    const num = cell.querySelector('span');
    if (num) num.className = 'text-[9px] md:text-[10px] leading-none text-text-primary font-medium';

    const dots = cell.querySelector('.cal-dots');
    if (dots) {
      dots.classList.remove('hidden');
      active.forEach((mIdx) => {
        const dot = document.createElement('div');
        dot.className = 'w-1 h-1 rounded-full';
        dot.style.background = colors[mIdx];
        dots.appendChild(dot);
      });
    }
  });
})();
