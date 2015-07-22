$(document).ready ->

  # Display the template description when user click on a template thumb
  $("#templates .template .thumb").click ->
    $description = $("#"+$(this).data("description"))
    $("#templates-description .selected").removeClass("selected").slideUp()
    $description.addClass("selected").slideDown()
    $("#templates-description").scrollintoview()