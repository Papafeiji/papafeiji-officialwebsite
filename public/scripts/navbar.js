(function () {
  const btn = document.getElementById('mobile-menu-btn');
  const menu = document.getElementById('mobile-menu');
  if (!btn || !menu) return;

  const close = () => {
    menu.classList.add('opacity-0', 'scale-95');
    setTimeout(() => menu.classList.add('hidden'), 200);
    btn.setAttribute('aria-expanded', 'false');
    document.removeEventListener('click', onDocClick, true);
    document.removeEventListener('keydown', onKeydown, true);
  };

  const onDocClick = (e) => {
    if (!menu.contains(e.target) && !btn.contains(e.target)) close();
  };

  const onKeydown = (e) => {
    if (e.key === 'Escape') {
      close();
      btn.focus();
    }
  };

  btn.addEventListener('click', () => {
    if (menu.classList.contains('hidden')) {
      menu.classList.remove('hidden');
      requestAnimationFrame(() => menu.classList.remove('opacity-0', 'scale-95'));
      btn.setAttribute('aria-expanded', 'true');
      document.addEventListener('click', onDocClick, true);
      document.addEventListener('keydown', onKeydown, true);
    } else {
      close();
    }
  });

  menu.querySelectorAll('a').forEach((a) => a.addEventListener('click', close));
})();
