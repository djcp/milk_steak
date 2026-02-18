$(function() {
  var images = [];
  var currentIndex = 0;
  var $overlay;

  // Collect all lightbox trigger links
  $('.lightbox-trigger').each(function() {
    images.push({
      src: $(this).attr('href'),
      caption: $(this).data('caption') || ''
    });
  });

  if (images.length === 0) return;

  // Build lightbox DOM
  $overlay = $('<div class="lightbox-overlay">' +
    '<div class="lightbox-content">' +
      '<button class="lightbox-close" aria-label="Close">&times;</button>' +
      '<button class="lightbox-nav lightbox-prev" aria-label="Previous">&lsaquo;</button>' +
      '<img src="" alt="">' +
      '<button class="lightbox-nav lightbox-next" aria-label="Next">&rsaquo;</button>' +
      '<div class="lightbox-caption"></div>' +
      '<div class="lightbox-counter"></div>' +
    '</div>' +
  '</div>');

  $('body').append($overlay);

  function showImage(index) {
    currentIndex = index;
    var image = images[currentIndex];
    $overlay.find('img').attr('src', image.src);
    $overlay.find('.lightbox-caption').text(image.caption).toggle(!!image.caption);
    $overlay.find('.lightbox-counter').text((currentIndex + 1) + ' / ' + images.length);

    // Hide nav buttons if only one image
    $overlay.find('.lightbox-nav').toggle(images.length > 1);
  }

  function openLightbox(index) {
    showImage(index);
    $overlay.addClass('active');
  }

  function closeLightbox() {
    $overlay.removeClass('active');
  }

  function showPrev() {
    showImage((currentIndex - 1 + images.length) % images.length);
  }

  function showNext() {
    showImage((currentIndex + 1) % images.length);
  }

  // Open on thumbnail click
  $('.lightbox-trigger').on('click', function(e) {
    e.preventDefault();
    var src = $(this).attr('href');
    for (var i = 0; i < images.length; i++) {
      if (images[i].src === src) {
        openLightbox(i);
        return;
      }
    }
    openLightbox(0);
  });

  // Navigation
  $overlay.find('.lightbox-prev').on('click', function(e) {
    e.stopPropagation();
    showPrev();
  });

  $overlay.find('.lightbox-next').on('click', function(e) {
    e.stopPropagation();
    showNext();
  });

  // Close button
  $overlay.find('.lightbox-close').on('click', function(e) {
    e.stopPropagation();
    closeLightbox();
  });

  // Close on overlay click (but not on content click)
  $overlay.on('click', function(e) {
    if ($(e.target).hasClass('lightbox-overlay')) {
      closeLightbox();
    }
  });

  // Keyboard navigation
  $(document).on('keydown', function(e) {
    if (!$overlay.hasClass('active')) return;

    switch (e.keyCode) {
      case 27: // Escape
        closeLightbox();
        break;
      case 37: // Left arrow
        showPrev();
        break;
      case 39: // Right arrow
        showNext();
        break;
    }
  });
});
