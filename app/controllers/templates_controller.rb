class TemplatesController < ApplicationController
  
  # User needs to be authenticated.
  before_filter :authenticated?

  # User need to have a cookbook selected
  before_filter :cookbook_selected?

  # Cookbook must not be locked for printing
  before_filter :cookbook_locked_for_printing?

  # User account must not be expired.
  before_filter :account_expired?

  # User must not be a contributor
  before_filter :cookbook_owner?

  # Display all the template to choose from for the current cookbook.
  def index
    @cookbook = current_cookbook
    @current_template_id = (current_cookbook.template) ? current_cookbook.template.id : 0
    @templates = Template.order("position ASC")
  end

  # Update the template for the current cookbook.
  def select
    @cookbook = current_cookbook
    template = Template.find_by_id params[:id]
    if template && @cookbook.update_attribute(:template, template)
      redirect_to edit_cookbook_path(@cookbook), notice: "Your design template is set"
    else
      redirect_to templates_path
    end
  end
end
