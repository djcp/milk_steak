$(function() {
  var addMoreIngredients = function(event) {
    event.preventDefault();
    var lastIngredient = $('#ingredients_container div.ingredient:last-child');
    var lastIngredientIndex = $(lastIngredient).data('ingredient-index');
    var nextIngredientIndex = lastIngredientIndex + 1;

    var regex = new RegExp(lastIngredientIndex, 'gm');
    var ingredientHtml = "<div class='ingredient' data-ingredient-index='" + nextIngredientIndex + "'>" +
      $(lastIngredient).clone().html() +
      '</div>';

    $('#ingredients_container').append(
      ingredientHtml.replace(regex, nextIngredientIndex)
    );
  };

  $('#more_ingredients_control').on('click', function(event) {
    addMoreIngredients(event);
  });

  var target = '';

  $(document).on('keyup.autocomplete_single', '.autocomplete_single', function() {
    $(this).autocomplete({
      source: function(request, response) {
        $.getJSON(target, { q: request.term }, response);
      },
      minLength: 2,
      search: function() {
        target = $(this).data('target');
        return true;
      }
    });
  });

  var split = function(val) {
    return val.split(/,\s*/);
  };

  var extractLast = function(term) {
    return split(term).pop();
  };

  // don't navigate away from the field on tab when selecting an item
  $(".autocomplete_multiple").on("keydown", function(event) {
    if (event.keyCode === $.ui.keyCode.TAB && $(this).data("ui-autocomplete").menu.active) {
      event.preventDefault();
    }
  }).autocomplete({
    source: function(request, response) {
      $.getJSON(target, { q: extractLast(request.term) }, response);
    },
    search: function() {
      // Minlength of the last element
      target = $(this).data('target');
      var term = extractLast(this.value);
      if (term.length < 2) {
        return false;
      }
    },
    focus: function() {
      // prevent value inserted on focus
      return false;
    },
    select: function(event, ui) {
      var terms = split(this.value);
      // remove the current input
      terms.pop();
      // add the selected item
      terms.push(ui.item.value);
      // add placeholder to get the comma-and-space at the end
      terms.push("");
      this.value = terms.join(", ");
      return false;
    }
  });
});
