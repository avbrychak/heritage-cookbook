# If cookbook has error, display them else clean the errors area content.
<% if @cookbook.errors.any? %>
$('#form-errors').hide().html('<%=j errors_for @cookbook %>').slideDown().scrollintoview()
<% else %>
$('#form-errors').slideUp().html("")
<% end %>

# Display warning for photos
<% if @cookbook.warnings.any? %>
alert "<%=j @cookbook.warnings.messages.map{|attribute, message| message.join("\n")}.join("\n").html_safe %>"
<% end %>