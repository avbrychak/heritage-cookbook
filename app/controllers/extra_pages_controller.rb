class ExtraPagesController < ApplicationController
  
  # User needs to be authenticated.
  before_filter :authenticated?

  # User need to have a cookbook selected.
  before_filter :cookbook_selected?

  # Cookbook must not be locked for printing
  before_filter :cookbook_locked_for_printing?

  # User account must not be expired.
  before_filter :account_expired?

  # Load section.
  before_filter :load_extra_page!, except: [:new]
  before_filter :load_section!

  # User must be owner or author.
  before_filter :authorized?, except: [:new, :preview]

  # Add a new extra page.
  def new
    @extra_page = @section.extra_pages.create(name: "My extra page", user: current_user, text: "")
    flash[:notice] = "#{@extra_page.name} was added to the #{@extra_page.section.name} as an extra page"
  end

  # Edit an existing extra page
  def edit
  end

  # Update a modified extra page
  # Respond with a content type of plain/text to support IE and Opera
  # see: https://github.com/blueimp/jQuery-File-Upload/wiki/Setup#content-type-negotiation
  def update

    # Process Paperclip attachments
    @extra_page.process_attachments(params)

    if @extra_page.update_attributes_individually params[:extra_page]
      flash[:notice] = "#{@extra_page.name} was successfully updated."
    end
    respond_to do |format|
      format.js { render :update, content_type: "text/plain" }
    end
  end

  # Remove an extra page.
  def destroy
    @extra_page.destroy
    redirect_to sections_path, notice: "#{@extra_page.name} was deleted from #{@extra_page.section.name}"
  end

  # Preview an extra page.
  def preview
    preview_path = "#{PDF_PREVIEW_FOLDER}/preview_extra_page-#{@extra_page.id}_#{Time.now.to_i}.pdf"
    session[:preview_filename] = preview_path
    preview = CookbookPreviewWorker.new(
      cookbook: current_cookbook, 
      filename: preview_path
    )
    preview.extra_page @extra_page.id
    render "previews/preview"
  end

  private

  # Load the extra page section.
  def load_section!
    if @extra_page
      @section = current_cookbook.sections.find @extra_page.section_id
    else
      @section = current_cookbook.sections.find params[:section_id]
    end
  end

  # Load the extra page.
  def load_extra_page!
    @extra_page = current_cookbook.extra_pages.find params[:id]
  end

  # User must be author or owner to edit this extra page.
  def authorized?
    if !@extra_page.editable_by? current_user, current_cookbook
      redirect_to sections_path, alert: "You are not allowed to edit this extra page."
    end
  end
end