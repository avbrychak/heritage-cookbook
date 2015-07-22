$(document).ready ->

  # Sortable sections
  $('#sections').sortable
    axis: 'y'
    handle: '.handle'
    update: ->
      $.post($(this).data('sort-url'), $(this).sortable('serialize'))

  # Section loader
  $('.section-bar h3 a').click (e) ->
  	$(this).next('.loader').show()

  # When the user click on the 'DONE' button while form is 
  # still processing, wait for it and only after redirect the user
  $('.edit_section').processing ->
    $form = $(this)
    finished = false
    $(".done-button").click (e) ->
      window.onbeforeunload = ->
      if !finished
        e.preventDefault()
        $button = $(this)
        $button.text "Saving changes..."
        $form.processed (stillActive) ->
          if stillActive == 1
            if $("#form-errors").text() == ""
              url = $button.attr('href')
              window.location.href = url
            else
              $button.text "DONE"
    $form.processed ->
      finished = true

  # Auto saving form
  $(".edit_section").heritageAutoSaveForm
    imageDeleted: ->
      $(".close-modal").click()
    imageUploaded: ->
      $(".close-modal").click()

  # Get the number of pages for the current cookbook
  $numPages = $("#num-pages")
  $pagesNumberArea = $("#cookbook-pages-number")
  $note = $pagesNumberArea.find('.note')
  bindingMaxPages = $("#binding-pages").text()
  if $numPages.length
    $.ajax(
      url: $numPages.data("url"),
      success: (json) ->
        numPages = json.num_pages
        $numPages.html(numPages)
        if parseFloat(numPages) > parseFloat(bindingMaxPages)
          $note.text "You can get cookbooks with up to 400 page by selecting a different type of binding."
          $pagesNumberArea.addClass("alert-color")
        else
          $note.text "You can have up to #{bindingMaxPages} pages with the current binding"
        $pagesNumberArea.slideDown()

    )
