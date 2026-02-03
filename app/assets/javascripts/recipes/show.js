$(function() {
  $('.modalDialog').on('click', function(event) {
    window.location.hash = 'image_list';
  });

  $(document).keyup(function(event) {
    if (event.keyCode === 27) {
      window.location.hash = 'image_list';
    }
  });
});
