class RecipesController < ApplicationController

  # User needs to be authenticated.
  before_filter :authenticated?

  # User need to have a cookbook selected.
  before_filter :cookbook_selected?

  # Cookbook must not be locked for printing
  before_filter :cookbook_locked_for_printing?

  # User account must not be expired.
  before_filter :account_expired?

  # Load recipe and section
  before_filter :load_recipe!, except: [:new]
  before_filter :load_section!

  # User must be owner or author.
  before_filter :authorized?, except: [:new, :preview]

  # Add a new recipe to the section.
  # Create the recipe with minimal validation to be able to support auto save on form.
  def new
    @recipe = @section.recipes.create(
      name: "My new recipe", 
      ingredient_list: "",
      instructions: "",
      story: "",
      user: current_user
    )
    flash[:notice] = "#{@recipe.name} was added to the #{@section.name} recipes"
  end

  # Modify a section recipe.
  def edit
  end

  # Update changes on a section recipe.
  # Respond with a content type of plain/text to support IE and Opera
  # see: https://github.com/blueimp/jQuery-File-Upload/wiki/Setup#content-type-negotiation
  def update
    
    # Process Paperclip attachments
    @recipe.process_attachments(params)

    if @recipe.update_attributes_individually params[:recipe]
      flash[:notice] = "'#{@recipe.name}' was successfully updated."
    end
    respond_to do |format|
      format.js { render :update, content_type: "text/plain" }
    end
  end

  # Should delete a recipe.
  def destroy
    @recipe.destroy
    redirect_to sections_path
  end

  # Preview a recipe
  def preview
    preview_path = "#{PDF_PREVIEW_FOLDER}/preview_recipe-#{@recipe.id}_#{Time.now.to_i}.pdf"
    session[:preview_filename] = preview_path
    preview = CookbookPreviewWorker.new(
      cookbook: current_cookbook, 
      filename: preview_path
    )
    preview.recipe @recipe.id
    render "previews/preview"
  end

  private

  def load_section!
    if @recipe
      @section = current_cookbook.sections.find @recipe.section_id
    else
      @section = current_cookbook.sections.find params[:section_id]
    end
  end

  def load_recipe!
    @recipe = current_cookbook.recipes.find params[:id]
  end

  def authorized?
    if !@recipe.editable_by? current_user, current_cookbook
      redirect_to sections_path, alert: "You are not allowed to edit this recipe."
    end
  end
end
