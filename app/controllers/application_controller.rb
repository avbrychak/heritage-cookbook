class ApplicationController < ActionController::Base
  protect_from_forgery

  private

  # Log more info on CSRF token issue, some user have problems to login 
  # and I cannot find/reproduce the issue
  def handle_unverified_request
    logger.warn "         Form token: #{params[request_forgery_protection_token]}" if logger
    logger.warn "         Header token: #{request.headers['X-CSRF-Token']}" if logger
    logger.warn "         Session token: #{session[:_csrf_token]}" if logger
    super
  end

  # Tell if the user as a contributor plan
  def has_contributor_plan?
    (current_user.plan.id == 5)
  end

  # Return a wordpress URL
  def wordpress_url(path=nil)
    return (path) ? "#{WORDPRESS_URL}/#{path}" : WORDPRESS_URL
  end
  helper_method :wordpress_url

  # Load an user cookbook in the session.
  # If not cookbook is given, select the first one.
  def load_user_cookbook(cookbook=nil)
    if session[:user_id]
      user = User.find session[:user_id]
      if cookbook
        if user && (user.owns_cookbook(cookbook) || user.contributes_to(cookbook))
          session[:cookbook_id] = cookbook.id
        end
      else
        if user && !user.owned_cookbooks.empty?
          session[:cookbook_id] = user.owned_cookbooks.first.id
        elsif user && !user.contributed_cookbooks.empty?
          cookbook = user.contributed_cookbooks.first
          session[:cookbook_id] = cookbook.id unless cookbook.owner.expired?
        end
      end
    end
  end

  # Load an user in the session.
  # Log login count and last login date.
  def load_user(user)
    session[:user_id]   = user.id
    session_reset_timeout!
    user.update_attributes last_login_on: Time.now, login_count: user.login_count + 1
  end

  # Get the current logged in user
  def current_user
    @current_user ||= begin
      if session[:user_id]
        user = User.where(id: session[:user_id])
        user[0] if user.any?
      end
    end
    # @current_user ||= User.find session[:user_id] if session[:user_id]
  end
  helper_method :current_user

  # Get the selected cookbook
  def current_cookbook
    @current_cookbook ||= Cookbook.find session[:cookbook_id] if session[:cookbook_id]
  end
  helper_method :current_cookbook

  # True or false the user is a contributor
  def user_is_contributor?
    !current_cookbook.is_owner?(current_user)
  end
  helper_method :user_is_contributor?

  # True or false the user is the cookbook owner
  def user_is_owner?
    current_cookbook.is_owner?(current_user)
  end
  helper_method :user_is_owner?

  # Redirect the user if cookbook is locked for printing (no more modifications allowed)
  def cookbook_locked_for_printing?
    if current_cookbook && current_cookbook.is_locked_for_printing?
      redirect_to cookbooks_path, alert: "This cookbook is locked and cannot be edited until the file has been sent to the printer"
    end
  end

  # Tell if a session has expired
  def session_expired?
    ! (Time.now < session[:expire_at])
  end

  # Update the session time out
  def session_reset_timeout! 
    session[:expire_at] = Time.now + MAX_SESSION_TIME.seconds
  end

  # Redirect the user if he's not authorized to do an action.
  def authenticated?
    if current_user.nil? || session_expired?
      reset_session

      flash[:alert] = "Your session has expired, please log in."
      if request.xhr?
        flash.keep(:notice)
        render js: "window.location = '#{login_url}'"
      else
        redirect_to login_url
      end
    else
      session_reset_timeout!
    end
  end

  # Redirect the user if he as no admin rights
  def admin?
    if !ALLOWED_USERS.include? current_user.email
      redirect_to root_path
    end
  end

  # Return a boolean if an user is an administrator
  def user_is_admin?
    ALLOWED_USERS.include? current_user.email
  end
  helper_method :user_is_admin?

  # Redirect the user working on its cookbook if its account has expired
  def account_expired?
    if current_user.expired? && current_user.owns_cookbook(current_cookbook)
      redirect_to upgrade_account_path(current_user)
    end
  end

  # Redirect the user to choose a cookbook to work on
  def cookbook_selected?
    if !current_cookbook
      redirect_to cookbooks_path, alert: "You must have selected a Cookbook project to work on first."
    end
  end

  # Redirect the user if he's not the cookbook owner
  def cookbook_owner?
    if current_cookbook && current_user.id != current_cookbook.owner.id
      redirect_to sections_path, alert: "As a Contributor you may only access the \"Recipes\" and \"Preview\" pages for the cookbook."
    end
  end

  # Redirect the user to choose a design if its cookbook has none set
  def design_set?
    if current_cookbook && !current_cookbook.template
      flash[:alert] = 'Sorry, You cannot do this action until you set the design'
      redirect_to templates_path
    end
  end
end