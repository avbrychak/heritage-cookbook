# If section has error, display them else clean the errors area content.
<% if @section.errors.any? %>
$('#form-errors').hide().html('<%=j errors_for @section %>').slideDown().scrollintoview()
<% else %>
$('#form-errors').slideUp().html("")
<% end %>

# Display warning for photos
<% if @section.warnings.any? %>
alert "<%=j @section.warnings.messages.map{|attribute, message| message.join("\n")}.join("\n").html_safe %>"
<% end %>