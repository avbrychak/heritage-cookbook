$(document).ready ->

  # Display the order part after user has click on the preview checkbox
  $("#preview-confirm-checkbox input").change ->
    $checkbox = $(this)
    if $(this).prop('checked')
      $('#cookbook-price-calculator').slideDown()
    else
      $('#cookbook-price-calculator').slideUp()

  # Hide the calculate button and display the loader instead
  $('.calculate-order-price').click ->
    $('.loader').fadeIn()
    $(this).hide()

  $("#order_token").change ->
    $checkbox = $(this)
    if $checkbox.prop('checked')
      $("#order-token-link").slideDown()
    else
      $("#order-token-link").slideUp()