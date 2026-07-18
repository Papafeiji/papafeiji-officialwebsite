(function () {
  const btn = document.getElementById('copy-btn');
  const icon = document.getElementById('copy-icon');
  const text = document.getElementById('copy-text');
  const cmd = document.getElementById('install-cmd');
  if (!btn || !cmd) return;

  const copyText = btn.dataset.copyText || 'Copy';
  const copiedText = btn.dataset.copiedText || 'Copied';

  btn.addEventListener('click', async () => {
    try {
      await navigator.clipboard.writeText(cmd.textContent || '');
    } catch (e) {
      // Fallback for contexts without clipboard permission
      return;
    }
    icon.innerHTML = '<polyline points="20 6 9 17 4 12"/>';
    text.textContent = copiedText;
    setTimeout(() => {
      icon.innerHTML = '<rect width="14" height="14" x="8" y="8" rx="2" ry="2"/><path d="M4 16c-1.1 0-2-.9-2-2V4c0-1.1.9-2 2-2h10c1.1 0 2 .9 2 2"/>';
      text.textContent = copyText;
    }, 2000);
  });
})();
