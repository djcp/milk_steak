$ ->
  $('.modalDialog').on
    click: (event) ->
      window.location.hash = ''

  $(document).keyup( (event) ->
    if event.keyCode == 27
      window.location.hash = ''
  )
