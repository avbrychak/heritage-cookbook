# If extra page has error, display them else clean the errors area content.
<% if @extra_page.errors.any? %>
$('#form-errors').hide().html('<%=j errors_for @extra_page %>').slideDown().scrollintoview()
<% else %>
$('#form-errors').slideUp().html("")
<% end %>

# Display warning for photos
<% if @extra_page.warnings.any? %>
alert "<%=j @extra_page.warnings.messages.map{|attribute, message| message.join("\n")}.join("\n").html_safe %>"
<% end %>