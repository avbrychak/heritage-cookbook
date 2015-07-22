# Hide the loader and display the submit button
$('.loader').hide()
$('.calculate-order-price').fadeIn()

# If order has error, display them else clean the errors area content.
# Else display the order grid
<% if @order.errors.any? %>
$('#cookbook-order-grid').slideUp()
$('#form-errors').hide().html('<%=j errors_for @order %>').slideDown().scrollintoview()
<% else %>
$('#form-errors').slideUp().html("")

# If its a reorder, load data from the order and not from the cookbook
<% if @order.is_reorder? %>
$('#cookbook-order-grid').slideUp().html('<%=j render "cookbook_reorder_grid" %>').slideDown()
<% else %>
$('#cookbook-order-grid').slideUp().html('<%=j render "cookbook_order_grid" %>').slideDown()

<% end %>
<% end %>