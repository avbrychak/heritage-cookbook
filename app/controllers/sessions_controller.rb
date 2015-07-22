class SessionsController < ApplicationController
  before_filter :authenticated?, only: [:testing]

  # Redirect sessions url to login page
  def index
    redirect_to login_path
  end
  
  # User login page.
  def new

    # Redirect the user if already logged
    if current_user
      redirect_to root_path
      return
    end
  end

  # User authentication.
  # Ask user to renew his membership if account is expired.
  # Ask user additionnal informations if missing.
  # Support for administrative backdoor.
  # Support for session timeout.
  def create
    @user = User.find_by_email(params[:email].strip)
    if @user && @user.authenticate(params[:password].strip)
      
      load_user @user

      # Ask the user additionnal informations if some are not provided
      if (@user.address.blank? || @user.city.blank? || @user.state.blank? || @user.zip.blank?) && @user.plan.purchaseable != 0
        redirect_to edit_additional_information_account_path(@user), notice: "You have been sucessfully logged in.\nCould you please enter some additional info? You may skip it at this time, but we'll ask you again later on."

      else
        redirect_to cookbooks_path, notice: "You have been logged into your Heritage Cookbook account !"
      end
    else
      flash[:alert] = "Incorrect email/password combination."
      render :new
    end
  end

  # User de-authentication.
  # If 'admin_id' is in sessions (meaning an admin used the 'login as' feature),
  # log back that admin and redirect to the user admin page.
  def destroy
    admin_id = session[:admin_id]
    reset_session
    
    if admin_id
      admin_user = User.find(admin_id)
      load_user admin_user
      redirect_to admin_users_path
    else
      redirect_to wordpress_url
    end
  end

  # Needed to test authentication expiry time.
  def testing
    redirect_to root_url
  end
end
