class SectionsController < ApplicationController

  # User needs to be authenticated.
  before_filter :authenticated?

  # User need to have a cookbook selected
  before_filter :cookbook_selected?

  # User account must not be expired.
  before_filter :account_expired?

  # Cookbook must not be locked for printing
  before_filter :cookbook_locked_for_printing?

  # Verify a new section can be added to the current cookbook.
  before_filter :verify_sections_number!, only: [:new]

  # Selected cookbook design must be set.
  before_filter :design_set?

  # User must not be a contributor.
  before_filter :authorized?, except: [:index, :preview, :show]
  
  # List and edit each book sections content.
  def index
    @sections = current_cookbook.sections.order "sections.position"
  end

  def show
    @section = current_cookbook.sections.find(params[:id])
    @recipes = @section.recipes.includes(:user)
    @extra_pages = @section.extra_pages.includes(:user)
  end

  # Add a section to the current cookbook.
  def new
    @section = current_cookbook.sections.create(name: "My new section")
  end

  # Modify an existing cookbook section.
  def edit
    @section = current_cookbook.sections.find(params[:id])
  end

  # Update an existing cookbook section
  # Respond with a content type of plain/text to support IE and Opera
  # see: https://github.com/blueimp/jQuery-File-Upload/wiki/Setup#content-type-negotiation
  def update
    @section = current_cookbook.sections.find(params[:id])

    # Process Paperclip attachments
    @section.process_attachments(params)
    
    if @section.update_attributes_individually(params[:section])
      flash[:notice] = "#{@section.name} was successfully updated."
    end
    respond_to do |format|
      format.js { render :update, content_type: "text/plain" }
    end
  end

  # Remove a cookbook section.
  def destroy
    @section = current_cookbook.sections.find(params[:id])
    @section.destroy
    redirect_to sections_path, notice: "Section: #{@section.name} was successfully removed"
  end

  # Preview a section.
  def preview
    section = current_cookbook.sections.find(params[:id])
    preview_path = "#{PDF_PREVIEW_FOLDER}/preview_section-#{section.id}_#{Time.now.to_i}.pdf"
    session[:preview_filename] = preview_path
    preview = CookbookPreviewWorker.new(
      cookbook: current_cookbook, 
      filename: preview_path
    )
    preview.section section.id
    render "previews/preview"
  end

  # Sort sections by position.
  def sort
    params['section'].each_with_index do |id, index|
      Section.update_all({position: index+1}, {id: id})
    end
    render nothing: true
  end

  private

  # Same as `cookbook_owner?` filter but with different redirection path and message.
  def authorized?
    if current_user.id != current_cookbook.owner.id
      redirect_to sections_path, alert: "Sorry, but you are not allowed to manage sections."
    end
  end

  # Verify the cookbook does not have more sections than allowed by the cookbook layout.
  def verify_sections_number!
    if current_cookbook.sections.count >= Section::MAX_SECTIONS
      redirect_to sections_path, alert: "You may only have #{Section::MAX_SECTIONS} sections. Try deleting a section first, or renaming an existing section."
    end
  end
end
