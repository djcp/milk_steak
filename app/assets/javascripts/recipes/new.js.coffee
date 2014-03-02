$ ->
  split = (val) ->
    val.split /,\s*/
  extractLast = (term) ->
    split(term).pop()

  target = ''

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
      # custom minLength
      target = $(@).data('target')
      term = extractLast(@value)
      false  if term.length < 2

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
