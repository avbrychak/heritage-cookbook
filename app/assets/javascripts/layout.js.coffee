$(document).ready ->

  # Disable link on disabled menu tabs
  $('.tabs .disabled, .tabs .disabled a').click (e) ->
  	e.preventDefault()

  # Disable link action for 'close modal' buttons
  $('.close-modal').click (e) ->
  	e.preventDefault()

  # Alert the user if errors are present on the form (for 'DONE' buttons)
  $(".alert-on-form-errors").click (e) ->
    $this = $(this)
    if $("#form-errors").text() != "" && $(".form-status").text() != "saving..."
      ask = confirm "You still have some errors to correct. Click 'OK' to correct them or 'Cancel' to leave the page."
      if ask
        e.preventDefault()
        $("#form-errors").scrollintoview()
      else
        return true

  # Display the calendar selector on date input fields
  $('.calendar').datepicker
    dateFormat: 'yy-mm-dd'