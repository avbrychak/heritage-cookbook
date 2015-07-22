$(document).ready ->

  # When the user click on the 'DONE' button while form is 
  # still processing, wait for it and only after redirect the user
  $('.edit_extra_page').processing ->
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
	
  # Enable auto saving for the form
  $('.edit_extra_page').heritageAutoSaveForm
    imageDeleted: ->
      $(".close-modal").click()
      $(".photo-button").text("Add a photo")
      $(".grayscale").slideUp()
      $("#form-image-thumb .thumb").slideUp().html ""
    imageUploaded: ($img) ->
      $('#form-image-thumb .thumb').html($img).slideDown()
      $(".close-modal").click()
      $(".photo-button").text("Modify my photo")
      $(".grayscale").slideDown()
