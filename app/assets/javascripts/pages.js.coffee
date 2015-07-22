$(document).ready ->

  # Build the index
  $index = $('<ul>').hide()
  $('#pages-faq h3').each ->
    $title = $(this)
    title = $title.text()
    id = title.toLowerCase().replace(/\ /g, '_')
    $title.attr 'id', id
    $indexEntry = $('<li>').html("<a href='##{id}'>#{title}</a>")
    $index.append $indexEntry
  $('#faq-index').prepend($index)
  $index.slideDown()
