class ContributorsController < ApplicationController

  # User needs to be authenticated.
  before_filter :authenticated?

  # User need to have a cookbook selected
  before_filter :cookbook_selected?

  # User account must not be expired.
  before_filter :account_expired?

  # User must not be a contributor
  before_filter :cookbook_owner?

  # List all contributors to your cookbooks.
  # Invite new contributors.
  def index
    @contributor = User.new
    @contributors = current_cookbook.contributors
  end

  # Send an invite and enable the contributor account.
  def create
    contributor_email   = params[:user][:email]
    @contributor_message = params[:user][:contributor_message]

    # Verify the user isn't trying to invite himself
    if contributor_email == current_user.email
      redirect_to contributors_path, alert: "You cannot add yourself as a contributor"
      return
    end

    @contributor = User.find_by_email(contributor_email)

    # User add a non-existing user as contributor
    if !@contributor
      @new_contributor = true
      @contributor = User.new_contributor(params[:user])
      @contributor_password = @contributor.password

      if !@contributor.save
        @contributors = current_cookbook.contributors
        render :index
        return
      end
    end

    # Add authorship to the current cookbook
    @authorship = Authorship.new(user: @contributor, cookbook: current_cookbook, role: 2)
    if @authorship.save

      # Send email to the contributor.
      if @new_contributor
        AccountMailer.delay.added_as_new_contributor(@contributor, current_user, @contributor_password, login_url, @contributor_message)
      else
        AccountMailer.delay.added_as_contributor(@contributor, current_user, login_url, @contributor_message)      
      end

      flash[:notice] = "#{@contributor.name} was added to your list of contributors."
    else
      flash[:alert] = "This contributor is already on your list"
    end

    redirect_to contributors_path
  end

  # Resend a contributor invitation.
  def resend_invite
    if User.exists?(params[:id])
      @contributor = User.find params[:id]

      if current_cookbook.is_contributor? @contributor

        # Contributor is a new user, regenerate a password
        if @contributor.login_count == 0
          new_password = @contributor.save_new_password
          AccountMailer.delay.added_as_new_contributor(@contributor, current_user, new_password, login_url)

        # Contributor is an existing user
        else
          AccountMailer.delay.added_as_contributor(@contributor, current_user, login_url)
        end

        flash[:notice] = "Invitational Email to #{@contributor.email} was resent."
      end
    end

    redirect_to contributors_path
  end

  # Remove a contributor.
  def destroy

    if User.exists?(params[:id])
      @contributor = User.find params[:id]

      if current_cookbook.is_contributor? @contributor
        authorship = current_cookbook.authorships.find_by_user_id @contributor.id
        authorship.destroy
        flash[:notice] = "That contributor was removed from your contributor list"
      end
    end

    redirect_to contributors_path
  end
end
