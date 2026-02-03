$(function() {
  $('.active_filters .remove_filter').on('click', function(event) {
    event.preventDefault();
    $('#filter_set_' + $(this).data('filter-name')).val('');
    $('#new_filter_set').submit();
  });
});
