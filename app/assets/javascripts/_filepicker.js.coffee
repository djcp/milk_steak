$ ->
  imagePreview = (file) ->
    $('<a>').attr(
      href: file.url
      target: '_blank'
    ).text(file.filename)

  textPreview = (file) ->
    $('<span>').attr(
      class: 'upload_preview'
    ).text(file.filename)

  window.photoUploaded = (event) ->
    preview = textPreview(event.fpfile)
    $(event.target).next().after(preview)
