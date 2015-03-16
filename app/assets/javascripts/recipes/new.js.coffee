$ ->
  addMoreIngredients = (event) ->
    event.preventDefault()
    lastIngredient = $('#ingredients_container div.ingredient:last-child')
    lastIngredientIndex = $(lastIngredient).data('ingredient-index')
    nextIngredientIndex = lastIngredientIndex + 1

    regex = new RegExp(lastIngredientIndex,'gm')
    ingredientHtml =
      "<div class='ingredient' data-ingredient-index='#{nextIngredientIndex}'>" +
      $(lastIngredient).clone().html() +
      '</div>'

    $('#ingredients_container').append(
      ingredientHtml.replace(regex, nextIngredientIndex)
    )

  $('#more_ingredients_control').on
    click: (event) ->
      addMoreIngredients(event)

  target = ''

  $(document).on('keyup.autocomplete_single', '.autocomplete_single', ->
    $(@).autocomplete
      source: (request, response) ->
        $.getJSON target, q: request.term, response
      minLength: 2
      search: ->
        target = $(@).data('target')
        true
  )

  split = (val) ->
    val.split /,\s*/
  extractLast = (term) ->
    split(term).pop()

  # don't navigate away from the field on tab when selecting an item
  $(".autocomplete_multiple").bind("keydown", (event) ->
    event.preventDefault()  if event.keyCode is $.ui.keyCode.TAB and $(this).data("ui-autocomplete").menu.active
    return
  ).autocomplete
    source: (request, response) ->
      $.getJSON target,
        q: extractLast(request.term)
      , response
      return

    search: ->
      # Minlength of the last element
      target = $(@).data('target')
      term = extractLast(@value)
      false if term.length < 2

    focus: ->
      # prevent value inserted on focus
      false

    select: (event, ui) ->
      terms = split(@value)
      # remove the current input
      terms.pop()
      # add the selected item
      terms.push ui.item.value
      # add placeholder to get the comma-and-space at the end
      terms.push ""
      @value = terms.join(", ")
      false
