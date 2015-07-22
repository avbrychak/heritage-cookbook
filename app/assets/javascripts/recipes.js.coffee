$(document).ready ->
  
  # Switch to two column ingredients list
  if !$('#recipe_ingredients_uses_two_columns').prop('checked')
  	$('#recipe_ingredient_list_2').hide();
  $('#recipe_ingredients_uses_two_columns').click -> 
    $('#recipe_ingredient_list_2').toggle();

  # When the user click on the 'DONE' button while form is 
  # still processing, wait for it and only after redirect the user.
  # If form has error, do not redirect and rollback the button text.
  $('.edit_recipe').processing ->
    $form = $(this)
    finished = false
    $(".done-button").click (e) ->
      $button = $(this)
      window.onbeforeunload = ->
      if !finished
        e.preventDefault()
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

  # Enable auto saving form
  $(".edit_recipe").heritageAutoSaveForm
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