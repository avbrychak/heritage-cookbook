class Admin::UsersController < ApplicationController
  layout 'admin'

  before_filter :authenticated?
  before_filter :admin?

  def index
    page = (params[:page]) ? params[:page].to_i : 1
    per_page = 20
    @search = User.search(params[:q])
    @search.sorts = 'created_on desc'
    @users = @search.result.paginate(:page => page, :per_page => per_page)
    @current_range = [1+per_page*(page-1), per_page*(page-1)+@users.length]

    respond_to do |format|
      format.html
      format.csv { send_data User.to_csv(@search.result) }
    end
  end

  def show
    @user = User.find params[:id]
    @owned_cookbooks = @user.owned_cookbooks
    @contributed_cookbooks = @user.contributed_cookbooks
    @membership_changes = @user.membership_changes
    @orders = @user.orders.where('paid_on IS NOT NULL AND reorder_id IS NULL')
    @reorders = @user.orders.where('paid_on IS NOT NULL AND reorder_id IS NOT NULL')
  end

  def edit
    @user = User.find params[:id]
  end

  # Used to update a list of attributes
  # * expiry_date
  # * notes
  def update
    @user = User.find params[:id]
    @user.expiry_date = params[:user][:expiry_date] if params[:user][:expiry_date]
    @user.notes = params[:user][:notes] if params[:user][:notes]
    if @user.expiry_date_changed?
      @user.record_membership_change
    end
    @user.save!
    redirect_to admin_user_path(@user), notice: "The user (#{@user.name}) has been updated"
  end

  def destroy
    @user = User.find params[:id]
    @user.destroy
    redirect_to admin_users_path, notice: "The user #{@user.name} <#{@user.email}> has been removed"
  end

  # Login as the specified user ID
  # Admin user need to logout to return to the admin pannel
  def login_as
    admin_id = current_user.id
    user = User.find params[:id]
    reset_session
    session[:admin_id] = admin_id
    load_user user
    redirect_to root_path, notice: "You are now logged in as '#{user.name}'"
  end

  # Add given days to the current date and set this as the expiry date for the given account
  def update_expiry_date
    user = User.find params[:id]
    user.update_attribute(:expiry_date, Time.now + params[:days].to_i.days)
    user.record_membership_change
    redirect_to :back, notice: "Expiry date for '#{user.name}' extented until #{user.expiry_date.strftime('%B %-d, %Y')}"
  end
end
