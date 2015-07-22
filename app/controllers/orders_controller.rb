class OrdersController < ApplicationController

  # User needs to be authenticated.
  before_filter :authenticated?

  # User need to have a cookbook selected
  before_filter :cookbook_selected?, except: [:reorder, :update_reorder, :guest]

  # Cookbook must not be locked for printing
  before_filter :cookbook_locked_for_printing?, except: [:reorder, :update_reorder, :guest]

  # User account must not be expired.
  before_filter :account_expired?, only: [:new, :update]

  # Selected cookbook design must be set.
  before_filter :design_set?, except: [:reorder, :update_reorder, :guest]

  # User must not be a contributor
  # before_filter :cookbook_owner?, except: [:new, :reorder, :guest]

  # Cookbook must have content
  before_filter :cookbook_have_content?, except: [:reorder, :update_reorder, :guest]

  # Load cookbook and order
  before_filter :load_cookbook!, except: [:reorder, :guest]
  before_filter :load_order!, except: [:reorder, :new, :guest]

  # Order the current cookbook
  def new
    @order = @cookbook.get_active_order if @cookbook.is_owner? current_user

    # Only allow owner to order
    if @order

      # Redirect user if cookbook has too much pages for the selected binding
      if @cookbook.num_pages > @cookbook.book_binding.max_number_of_pages
        redirect_to notify_binding_problem_order_path(@order)
        return
      end

      # Make sure that the active order is not a canceled reorder (from old code)
      @order.update_attribute(:reorder_id, nil) 
    end
  end

  # Explain to the user the selected binding cannot 
  # be use with its cookbook (too much pages)
  def notify_binding_problem
  end

  # Change current order
  def update

    @order.number_of_books = params[:order][:number_of_books]
    @order.ship_country = params[:order][:ship_country]
    @order.ship_state = params[:order][:ship_state]
    @order.ship_zip = params[:order][:ship_zip]

    @order.save
    respond_to do |format|
      format.js { render :update }
    end
  end

  # Ask customers details like shipping and billing address
  def edit_customer_details
  end

  # Update customer details about shipping and billing address
  def update_customer_details

    # Make the order in final state to add specific validations
    @order.is_final
    
    if @order.update_attributes(params[:order])
      redirect_to confirm_order_path(@order)
    else
      render :edit_customer_details
    end
  end

  # Validate and confirm an order
  def confirm
  end

  # Request a price quote
  def ask_price_quote
    if @order.is_reorder?
      AdministrativeMailer.delay.printer_quote(current_user, @order.number_of_books, @order.order_bw_pages, @order.order_color_pages, @order.ship_zip, @cookbook.book_binding)
    else
      AdministrativeMailer.delay.printer_quote(current_user, @order.number_of_books, @cookbook.num_bw_pages, @cookbook.num_color_pages, @order.ship_zip, @cookbook.book_binding)
    end
  end

  # The order has been approved by the payment gateway
  def approved
    if @order && params[:ref1] == @order.id.to_s
      @order.paid_on = Time.now

      # Save transaction data
      @order.transaction_data = params.to_yaml
      
      # Saving cookbook data
      if !@order.is_reorder?
        @order.order_color_pages   = @cookbook.num_color_pages
        @order.order_bw_pages      = @cookbook.num_bw_pages
        @order.cookbook_title      = @cookbook.title
        @order.book_binding        = @cookbook.book_binding.name
      end
      @order.order_printing_cost = @order.printing_cost
      @order.order_shipping_cost = @order.shipping_cost

      @order.save!
      @order.user.increment!(:paid_orders_count)
      
      # Send email notifications to user and operators
      if @order.is_reorder?
        AdministrativeMailer.delay.reorder_submitted(@order)
        AccountMailer.delay.reorder_receipt(current_user, @order, params[:trnAmount])
        AdministrativeMailer.delay.hume_reorder_request(@order)
      else
        AdministrativeMailer.delay.order_submitted(@order)
        AccountMailer.delay.order_receipt(current_user, @order, params[:trnAmount])
      end
      flash[:notice] = "Thank you! Your order was completed successfully."
      
      # Lock the cookbook
      @order.cookbook.update_attribute(:is_locked_for_printing, true) unless @order.is_reorder?
    else
      redirect_to confirm_order_path(@order), alert: "There was an error processing your order. Please confirm your information and try again."
    end
  end

  # The order has been declined by the payment gateway
  def declined
    if @order && params[:ref1] == @order.id.to_s
      @order.transaction_data = params.to_yaml
      @order.save
    end
    redirect_to root_path, alert: "Your order was not processed. It was cancelled by the credit card processor. #{params[:messageText]}"
  end

  # Reorder an old cookbook
  def reorder
    @old_order = current_user.orders.find params[:id]
    @cookbook = @old_order.cookbook
    load_user_cookbook @cookbook
    @order = @cookbook.get_active_reorder(@old_order.id)

    # Redirect user if cookbook has too much pages for the selected binding
    # if @order.num_pages > @cookbook.book_binding.max_number_of_pages
    #   redirect_to notify_binding_problem_order_path(@order)
    #   return
    # end
  end

  # Update the reorder attributes to calculate the price
  def update_reorder
    @order = current_user.orders.find params[:id]
    @order.number_of_books = params[:order][:number_of_books]
    @order.ship_country = params[:order][:ship_country]
    @order.ship_state = params[:order][:ship_state]
    @order.ship_zip = params[:order][:ship_zip]

    @order.save
    respond_to do |format|
      format.js { render :update }
    end
  end

  # Place an order as a guest user.
  # It identify the shared order using the given id and create a re-order on top of it.
  # Verify the cookbook has been generated before accepting guest order.
  def guest
    @old_order = Order.find params[:id]
    if @old_order && @old_order.filename
      @cookbook = @old_order.cookbook
      @order = @cookbook.get_active_reorder(@old_order.id, current_user)
    else
      redirect_to root_url, alert: "Sorry, this cookbook is not available for order yet."
    end
  end

  private

  # Load the current cookbook
  def load_cookbook!
    @cookbook = current_cookbook
  end

  # Load the current order or reorder
  def load_order!
    @order = current_user.orders.find params[:id]
    # @order = @cookbook.get_active_reorder(params[:id]) if @cookbook.is_owner? current_user
  end

  # Check if the cookbook have some extra pages or recipes
  def cookbook_have_content?
    if current_cookbook && current_cookbook.extra_pages.empty? && current_cookbook.recipes.empty?
      redirect_to sections_path, alert: "Sorry, but you cannot order this cookbook until you add some content"
    end
  end
end
