# If recipe has error, display them else clean the errors area content.
<% if @recipe.errors.any? %>
$('#form-errors').hide().html('<%=j errors_for @recipe %>').slideDown().scrollintoview()
<% else %>
$('#form-errors').slideUp().html("")
<% end %>

# Display warning for photos
<% if @recipe.warnings.any? %>
alert "<%=j @recipe.warnings.messages.map{|attribute, message| message.join("\n")}.join("\n").html_safe %>"
<% end %>