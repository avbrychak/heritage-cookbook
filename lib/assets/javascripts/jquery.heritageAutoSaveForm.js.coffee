$ = jQuery

# Event: 'processing' event is called each time the form is submitted
$.fn.processing = (event) ->
  $(this).on 'processing', ->
    event()

# Event: 'processed' event is called each time the form processing is ended (saved or error)
$.fn.processed = (event) ->
  $(this).on 'processed', (e, processingQueue) ->
    event(processingQueue)

# Manage auto saving for forms
# Auto save the form when an input content change, only the change is sent
# Auto save image by using "JQuery file upload" plugin
$.fn.heritageAutoSaveForm = (options) ->

  # Settings
  settings = $.extend
    thumb: ".thumb"
    deleteImageLink: ".remove-image-link"
    deleteImageInput: "input[type=checkbox]"
    attachmentFormPart: ".image-upload-form-part"
    progressBarDiv: ".progress-bar"
    progressBar: ".progress-bar .percent"
    transferStatus: ".progress-bar .text"
    imageDeleted: ->
    imageUploaded: ->
    onError: (e, data) ->
  , options

  return this.each ->
    
    $form = $(this)
    $formErrors = $("#form-errors")

    method = $form.find('input[name=_method]').val().toUpperCase()
    url = $form.attr('action')

    # Form autosaving queue to lock user on the page and 
    # inform content is saving
    processingQueue = 0
    $form.processing ->
      ++processingQueue
      if processingQueue == 1
        lockPage()
        updateFormStatus "saving..."
    $form.processed ->
      --processingQueue
      if processingQueue == 0
        unlockPage()
        if $formErrors.text() == ""
          updateFormStatus "done!" 
        else
          updateFormStatus "errors to fix!" 

    # Build the form status div
    $formStatus = $('<div>').addClass('form-status').attr('id', "form_status_#{$form.attr('id')}").hide()
    $('body').append($formStatus)

    # Update the form status text
    updateFormStatus = (text) ->
      $formStatus.hide().text(text).fadeIn()
      #console.log "form status: #{text}"

    lockPage = ->
      window.onbeforeunload = ->
        return 'Your content is not saved yet!';

    unlockPage = ->
      window.onbeforeunload = ->

    # Listen for change on inputs
    $form.find('input:not(input[type=file]), textarea, select').change ->

      $input = $(this)

      # Serialize the changes
      # If data is a checkbox, also send the attached hidden input (rails way)
      # See: http://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-check_box
      serializeInput = ($input) ->
        if $input.attr('type') == "checkbox"
          inputName = $input.attr("name")
          data = $input.add("input[name='#{inputName}']").serialize()
        else
          data = $input.serialize()
        return data

      # Submit inputs data
      submitChange = ->
        $.ajax
          method: method,
          url: url,
          #data: serializeInput($input),
          data: $form.serialize(),
          dataType: 'script',
          success: ->
            #console.log "form submitted!"
            $form.trigger 'processed', processingQueue
          error: (jqXHR, textStatus, errorThrown) ->
            #console.log textStatus
            #console.log errorThrown
            #console.log jqXHR
            $form.trigger 'processed', processingQueue
            updateFormStatus "failed!"
          # statusCode:
          #   404: ->
          #     #console.log "HTTP 404"
          #   500: ->
          #     #console.log "HTTP 500"

      # Submit the change
      $form.trigger 'processing'
      submitChange()


    # Listen for change on file inputs
    # Use XHR or iframe transport to send file
    $formParts = $form.find(settings.attachmentFormPart)

    # Manage each file upload part in the form
    $formParts.each ->

      $formPart = $(this)
      $thumb = $formPart.find(settings.thumb)
      $fileInput = $formPart.find('input[type=file]')
      $progressBar = $formPart.find(settings.progressBar)
      $progressBarDiv = $formPart.find(settings.progressBarDiv)
      $transferStatus = $formPart.find(settings.transferStatus)

      # Update the transfer status text
      updateTransferStatus = (text) ->
        $transferStatus.hide().text(text).fadeIn()
        #console.log "transfert status: #{text}"

      # Display the progress bar to the user
      displayProgressBar = ->
        $progressBarDiv.slideDown()

      # Hide the progress bar
      hideProgressBar = (time=1) ->
        $progressBarDiv.delay(time*1000).slideUp ->
          resetProgressBar()

      # Update the file upload progress bar with
      updateProgressBar = (progress) ->
        $progressBar.css 'width', "#{progress}%"
        #console.log "progress bar: #{progress}%"

      # Reset the progress bar for next upload
      resetProgressBar = ->
        $progressBar.css('width', '0%')
        updateTransferStatus ""

      # Display the uploaded file thumb
      displayThumb = (file) ->
        if file
          loadingImage = loadImage file, (img) ->
            if img.type != "error"
              $img = $(img).removeAttr('width').removeAttr('height')
              $thumb.slideUp ->
                $(this).html $img
                $(this).slideDown('slow')
          if !loadingImage
            $thumb.slideUp ->
              $(this).html("<span class='note'>New image: '#{file.name}'<br>The image preview function is not available with your browser.<br>Reload the page, or move to the next step, then back on to this page to view your image.</span>").slideDown('slow')
        else
          $thumb.slideUp ->
            $(this).html("")

      # Use the AJAX Files Upload JQuery plugin on 
      # the file input to manage file upload
      $fileInput.fileupload
        url: $form.attr('action')
        type: "PUT"
        dataType: 'script'
        progressall: (e, data) ->
          progress = parseInt(data.loaded / data.total * 100, 10)
          updateProgressBar progress
          if progress == 100
            updateTransferStatus "Waiting..."
        send: (e, data) ->
          file = data.files[0]
          displayThumb file
        start: (e) ->
          displayProgressBar()
          updateTransferStatus "Uploading..."
          $form.trigger 'processing'
        done: (e, data) ->
          updateTransferStatus "Completed."
          $form.trigger 'processed', processingQueue
          displayDeleteImageLink()
          hideProgressBar(5)
          file = data.files[0]
          loadingImage = loadImage file, (img) ->
            settings.imageUploaded($(img).removeAttr('width').removeAttr('height'))
        fail: (e, data) ->
          updateTransferStatus "Failed."
          $form.trigger 'processed', processingQueue
          updateFormStatus "image not saved!"
          hideProgressBar(5)
          displayThumb false
          settings.onError(e, data)

      $deleteImageLink = $formPart.find(settings.deleteImageLink)
      $deleteImageInput = $formPart.find(settings.deleteImageInput)

      # Display the link to delete the current image
      displayDeleteImageLink = ->
        $deleteImageLink.fadeIn()

      # Remove the link to delete the current image
      hideDeleteImageLink = ->
        $deleteImageLink.fadeOut()

      # Remove the current image
      deleteImage = ->
        $deleteImageInput.prop 'checked', true
        $.ajax
          method: "PUT"
          url: $form.attr('action')
          data: $deleteImageInput.serialize()
          dataType: 'script'
          beforeSend: ->
            $form.trigger 'processing'
          complete: ->
            $form.trigger 'processed', processingQueue
            $deleteImageInput.prop 'checked', false
            hideDeleteImageLink()
            settings.imageDeleted()

      # Manage the image deletion using AJAX
      $deleteImageLink.click (e) ->
        e.preventDefault()
        ask = confirm "Are you sure ?";
        if ask==true
          displayThumb false
          deleteImage()