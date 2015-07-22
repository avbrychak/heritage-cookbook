$(document).ready ->

  # Display cookbook name when user move hover the thumb
  $(".cookbook").aToolTip({  
    toolTipClass: 'tooltip'
  });

  # When the user click on the 'NEXT' button while form is 
  # still processing, wait for it and only after redirect the user
  $('.edit_cookbook').processing ->
    $form = $(this)
    finished = false
    $(".next-button").click (e) ->
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

  # Enable auto saving form
  $('.edit_cookbook').heritageAutoSaveForm
    imageDeleted: ->
      $(".close-modal").click()
    imageUploaded: ->
      $(".close-modal").click()

  # On 'Check my book price' page, au reload the page when user change the number of books
  typingTimer = null
  doneTypingInterval = 5000 #ms
  $('#num-cookbooks-field').keyup ->
    clearTimeout(typingTimer)
    $this = $(this)
    $input = $($this.find('input')[0])
    if $input.val 
      typingTimer = setTimeout ->
        url = $this.data('url')+'?num_cookbooks='+$input.val()
        window.location = url
      , 1000

