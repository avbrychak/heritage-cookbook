class Admin::OrdersController < ApplicationController
  layout 'admin'

  before_filter :authenticated?
  before_filter :admin?

  def index
    page = (params[:page]) ? params[:page].to_i : 1
    per_page = 20
    @search = Order.paid.search(params[:q])
    @search.sorts = 'paid_on desc'
    @orders = @search.result.paginate(:page => page, :per_page => per_page)
    @current_range = [1+per_page*(page-1), per_page*(page-1)+@orders.length]

    respond_to do |format|
      format.html
      format.csv { send_data Order.to_csv(@search.result) }
    end
  end

  def show
    @order = Order.find(params[:id])
  end

  def new
    @cookbook = Cookbook.find(params[:cookbook_id])
    @order = @cookbook.get_active_order
  end

  def update
    @order = Order.find(params[:id])
    @cookbook = @order.cookbook

    # Make the order in final state to add specific validations
    @order.is_final

    # Tell no payment was made using the site
    transaction_data = HashWithIndifferentAccess.new(:trnAmount=> 'OFFLINE')

    if @order.update_attributes params[:order].merge(paid_on: Time.now, transaction_data: transaction_data)

      # Increment the user order count
      @order.user.increment!(:paid_orders_count)

      # Save additional informations
      @order.order_color_pages   = @cookbook.num_color_pages
      @order.order_bw_pages      = @cookbook.num_bw_pages
      @order.cookbook_title      = @cookbook.title
      @order.book_binding        = @cookbook.book_binding.name
      @order.order_printing_cost = @order.printing_cost
      @order.order_shipping_cost = @order.shipping_cost
      @order.save!

      # Lock the cookbook
      @order.cookbook.update_attribute(:is_locked_for_printing, true) unless @order.is_reorder?

      redirect_to admin_user_path(@order.user), notice: "A new order for cookbook '#{@cookbook.title}' has been created"
    else
      render :new
    end
  end
end
