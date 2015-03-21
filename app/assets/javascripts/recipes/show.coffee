$ ->
  $('.modalDialog').on
    click: (event) ->
      window.location.hash = 'image_list'

  $(document).keyup( (event) ->
    if event.keyCode == 27
      window.location.hash = 'image_list'
  )
