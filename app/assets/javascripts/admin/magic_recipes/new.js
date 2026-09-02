document.querySelectorAll('.source-toggle-btn').forEach(function(btn) {
  btn.addEventListener('click', function() {
    var target = this.getAttribute('data-target');
    document.getElementById('url-input').classList.toggle('hidden', target !== 'url-input');
    document.getElementById('text-input').classList.toggle('hidden', target !== 'text-input');

    // aria-pressed carries the selection to assistive tech; the colour swap
    // below only conveys it visually.
    document.querySelectorAll('.source-toggle-btn').forEach(function(b) {
      b.classList.remove('bg-terra', 'text-white');
      b.classList.add('bg-gray-100', 'text-gray-700');
      b.setAttribute('aria-pressed', 'false');
    });
    this.classList.remove('bg-gray-100', 'text-gray-700');
    this.classList.add('bg-terra', 'text-white');
    this.setAttribute('aria-pressed', 'true');

    if (target === 'url-input') {
      document.getElementById('source_text').value = '';
    } else {
      document.getElementById('source_url').value = '';
    }
  });
});
