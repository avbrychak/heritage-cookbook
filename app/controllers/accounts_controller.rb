class AccountsController < ApplicationController
  before_filter :authenticated?, except: [:new, :create, :recover_password, :new_password]

  # Display the signup page.
  def new

    # Redirect the user if already logged
    if current_user
      redirect_to root_path
      return
    end
    
    @user = User.new
  end

  # Create an user account.
  # A welcome email is sent with user credentials.
  # If the user signup to a paid membership plan, it will be redirected to the payment page.
  def create

    @user = User.new params[:user]

    if @user.save
      load_user @user
      flash[:notice] = "Congratulations, your Heritage Cookbook account has been created!"
      
      # Once user is saved, `password` and `password_confirmation` must be cleared.
      # By default, `password` is automatically cleared after save but not `password_confirmation`.
      @user.password_confirmation = nil

      # Send an email to the user with its credentials.
      AccountMailer.delay.signup_details(@user, login_url)

      # Put the user on the proper plan and ask for payment if needed.
      is_payment_needed = @user.switch_to_plan params[:user][:plan_id]
      if is_payment_needed
        redirect_to upgrade_account_path(@user, plan_id: params[:user][:plan_id])
      else
        redirect_to root_path
      end
    else
      render :new
    end
  end

  # Upgrade the user account plan.
  def upgrade
    if params[:plan_id]
      @plans_available = Plan.available_signup_plans.reject!{|p| p[1] == 1}
      @plan = Plan.find params[:plan_id]
      @selected_plan = @plan
    else
      @plans_available = Plan.available_upgrade_plans
      @plan = Plan.find @plans_available.first[1]
    end
  end

  # Process account upgrade payment.
  # Allow payment with credit card for non Paypal user.
  def process_payment
    @plan = Plan.find params[:plan]
    session[:purchased_plan_id] = @plan.id

    response = EXPRESS_GATEWAY.setup_purchase(@plan.price_in_cents,
      ip: request.remote_ip, 
      return_url: payment_processed_account_url(current_user),
      cancel_return_url: root_url,
      no_shipping: true,
      description: @plan.title,
      allow_guest_checkout: true,
      brand_name: "Heritage Cookbook"
    )

    redirect_to EXPRESS_GATEWAY.redirect_url_for(response.token, review: false)
  end

  # Inform the user on its payment status and update the user membership plan.
  # Send an email to inform opertors.
  def payment_processed
    @plan = Plan.find session[:purchased_plan_id]
    session[:purchased_plan_id] = nil
    @user = current_user

    # Ask confirmation for the purchase
    purchase = EXPRESS_GATEWAY.purchase @plan.price_in_cents,
      ip: request.remote_ip,
      token: params[:token],
      payer_id: params[:PayerID]
    
    if purchase.success?

      # Save payment data for this user
      @user.update_attributes(
        express_token: params[:token], 
        express_payer_id: params['PayerID'],
        transaction_data: EXPRESS_GATEWAY.details_for(params[:token])
      )
      @user.switch_to_plan(@plan.id, true)

      # Inform operators an account has been paid
      AdministrativeMailer.delay.account_upgraded(@user)

      redirect_to root_path, notice: "Your payment was successful and your account has been upgraded."
    else
      redirect_to upgrade_account_path(@user), notice: purchase.message
    end
  end

  # Display the page to edit account informations
  def edit
    @user = current_user
  end

  # Change the account informations.
  def update
    @user = current_user
    if @user.update_attributes(params[:user])
      redirect_to edit_account_path(current_user), notice: "Your account information was successfully updated."
    else
      render :edit
    end
  end

  # Display the page to update user password.
  def edit_password
    @user = current_user
  end

  # Change the user password.
  # User must provide the valid currrent password before change are saved.
  def update_password
    @user = current_user
    if @user.authenticate params[:user][:old_password]
      if @user.update_attributes params[:user]
        reset_session
        redirect_to login_path, notice: "Your password was successfully changed. Please login with your new password to verify it worked.\nIf you have a problem, you can always get a new password with the \"Forgot your password\" link"
        return
      end
    else
      @user.errors[:old_password] = "Incorrect current password. Changes were not made."
    end
    render :edit_password
  end

  # Page to recover the user password.
  def recover_password
    @user = User.new
  end

  # Reset the user password and send him a new one.
  def new_password
    @user = User.find_by_email(params[:user][:email])
    if @user
      generated_password = @user.generate_password
      if @user.update_attribute :password, generated_password

        # Send the user its new password
        AccountMailer.delay.forgot_password(@user, generated_password)

        redirect_to login_path, notice: 'A new password has been generated for you, and emailed to the email address you entered.'
      else
        render :recover_password
      end
    else
      @user = User.new
      @user.errors[:email] << "Cannot find provided email, or it is incorrectly typed"
      render :recover_password
    end
  end

  # Ask user additionnal informations.
  # Enable newsletter by default.
  def edit_additional_information
    @user = current_user
    @user.newsletter = true
  end

  # Change optional informations.
  def update_additional_information
    @user = current_user
    if @user.update_attributes(params[:user])

      @user.errors[:address] << "Please enter your address"         unless !@user.address.blank?
      @user.errors[:city]    << "Please enter your city"            unless !@user.city.blank?
      @user.errors[:state]   << "Please enter your state"           unless !@user.state.blank?
      @user.errors[:zip]     << "Please enter your zip/postal code" unless !@user.zip.blank?
      
      if @user.errors.empty?
        redirect_to root_path, notice: "Thank you for filling out the additional information."
        return
      end
    end
    
    render :edit_additional_information
  end
end
