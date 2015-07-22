class CookbooksController < ApplicationController

  # User needs to be authenticated.
  before_filter :authenticated?

  # User need to have a cookbook selected
  before_filter :cookbook_selected?, except: [:index, :select, :new]

  # User account must not be expired.
  before_filter :account_expired?, except: [:index, :select]

  # Selected cookbook design must be set.
  before_filter :design_set?, except: [:index, :select, :new, :edit_title, :update_title, :update]

  # User must not be a contributor
  before_filter :cookbook_owner?, except: [
    :index, :select, :new, :show_introduction,
    :preview, :preview_cover, :preview_title_and_toc, :preview_index, :preview_introduction, :count_page
  ]

  # Cookbook must not be locked for printing
  before_filter :cookbook_locked_for_printing?, except: [:index, :new, :select, :preview]

  # List all cookbooks user has access to.
  def index
    @page_title = "Welcome, #{current_user.first_name}! Let's Get Cooking..."
    @info_panel_title = "Membership info"
    @user = current_user
    @cookbooks = @user.owned_cookbooks
    @contributed_cookbooks = @user.contributed_cookbooks
    @completed_orders = @user.completed_orders
  end

  # Select a cookbook to work on.
  # Alert the user if the cookbook owner account has expired.
  def select
    @cookbook = Cookbook.find params[:id]
    user_is_owner = current_user.owns_cookbook(@cookbook)
    user_is_contributor = current_user.contributes_to(@cookbook)

    # Verify the user is authorized to work on this cookbook.
    if @cookbook && (user_is_owner || user_is_contributor)
      
      # User must have a paid account to work on its cookbooks
      # (Contributor wasn't allowed to create cookbooks but due to a bug some contributors may have cookbooks to works on)
      if has_contributor_plan? && user_is_owner
        redirect_to upgrade_account_path(current_user.id), alert: "You must have a paid membership to work on your own cookbooks"
        return
      end

      load_user_cookbook @cookbook

      # Alert the user it will not be able to work on this cookbook if its owner has expired.
      if current_cookbook.owner.expired?
        if user_is_owner
          flash[:alert]  = "Because your membership has expired you can no longer work on your cookbooks."
        elsif user_is_contributor
          flash[:alert]  = "The owner of this cookbook's membership has expired. They will have to extend it for you to gain access to this cookbook."
        end
      end
      redirect_to templates_path
    else
      redirect_to cookbooks_path, alert: "Unable to select cookbook. Either it doesn't exist or you have no permission accessing it."
    end
  end

  # Create a new cookbook.
  # The cookbook is created automatically and assigned as the current cookbook.
  def new
    cookbook_id = current_user.create_cookbook
    if cookbook_id
      @cookbook = Cookbook.find cookbook_id
      load_user_cookbook @cookbook
      redirect_to templates_path, notice: "A new cookbook was created for you."
    else
      redirect_to upgrade_account_path(current_user.id), alert: "You must have a paid membership to work on your own cookbooks"
    end
  end

  # Edit the cookbook informations
  # Respond with a content type of plain/text to support IE and Opera
  # see: https://github.com/blueimp/jQuery-File-Upload/wiki/Setup#content-type-negotiation
  def edit
    @cookbook = current_cookbook
  end

  # Update the cookbook attributes.
  def update
    @cookbook = current_cookbook

    # Process Paperclip attachments
    @cookbook.process_attachments(params)
    
    if @cookbook.update_attributes_individually params[:cookbook]
      flash[:notice] = 'The template was updated.'
    end
    respond_to do |format|
      format.js { render :update, content_type: "text/plain" }
    end
  end

  # Edit the cookbook title.
  def edit_title
    @cookbook = current_cookbook
  end

  # Update the cookbook title
  def update_title
    @cookbook = current_cookbook
    @cookbook.title = params[:cookbook][:title]
    if @cookbook.save
      redirect_to templates_path, notice: "Your Cookbook name has been changed!"
    else
      render :edit_title
    end
  end

  # Edit the cookbook introduction
  def edit_introduction
    @cookbook = current_cookbook
  end

  # Update introduction elements
  # Respond with a content type of plain/text to support IE and Opera
  # see: https://github.com/blueimp/jQuery-File-Upload/wiki/Setup#content-type-negotiation
  def update_introduction
    @cookbook = current_cookbook

    # Process Paperclip attachments
    @cookbook.process_attachments(params)

    if params[:cookbook]
      @cookbook.intro_type = params[:cookbook][:intro_type] if params[:cookbook][:intro_type]
      @cookbook.center_introduction = params[:cookbook][:center_introduction] if params[:cookbook][:center_introduction]
      @cookbook.intro_text = params[:cookbook][:intro_text] if params[:cookbook][:intro_text]
      @cookbook.intro_image_grayscale = params[:cookbook][:intro_image_grayscale] if params[:cookbook][:intro_image_grayscale]
      @cookbook.intro_image = params[:cookbook][:intro_image] if !params[:cookbook][:intro_image].nil?

      # If the user has checked the "Do not include this page" checkbox, set the intro_type do '2'
      @cookbook.intro_type = 2 if params[:do_not_include]
      @cookbook.intro_type = 0 if !params[:do_not_include] && @cookbook.intro_type == 2
    end

    if @cookbook.save
      flash[:notice] = 'The introduction of your cookbook was saved.'
    end
    respond_to do |format|
      format.js { render :update_introduction, content_type: "text/plain" }
    end
  end

  # Display the cookbook price
  def check_price
    @num_cookbooks = (params[:num_cookbooks] && params[:num_cookbooks].to_i > 3) ? params[:num_cookbooks].to_i : 4
    ccc = CookbookCostCalculator.new(
      num_bw_pages: current_cookbook.num_bw_pages, 
      num_color_pages: current_cookbook.num_color_pages, 
      num_books: @num_cookbooks, 
      binding: current_cookbook.book_binding.to_sym
    )
    @cookbook = current_cookbook
    @printing_cost = ccc.printing_cost || "Unknown"
    @cost_per_book = (@printing_cost != "Unknown") ? (@printing_cost.to_f / @num_cookbooks).round(2) : "Unknown"
  end

  # Preview the cookbook
  # This can be the current cookbook or a cookbook of another person if an order has been created (guest order)
  def preview
    order = current_user.orders.find_by_cookbook_id(params[:id])
    @cookbook = (order) ? order.cookbook : current_cookbook
    preview_path = "#{PDF_PREVIEW_FOLDER}/preview_cookbook-#{@cookbook.id}_#{Time.now.to_i}.pdf"
    session[:preview_filename] = preview_path
    preview = CookbookPreviewWorker.new(
      cookbook: @cookbook, 
      filename: preview_path
    )
    preview.cookbook
    render "previews/preview"
  end

  # Preview the cookbook cover
  def preview_cover
    preview_path = "#{PDF_PREVIEW_FOLDER}/preview_cover-#{current_cookbook.id}_#{Time.now.to_i}.pdf"
    session[:preview_filename] = preview_path
    preview = CookbookPreviewWorker.new(
      cookbook: current_cookbook, 
      filename: preview_path
    )
    preview.cover
    render "previews/preview"
  end

  # Preview the title and the table of contents pages
  def preview_title_and_toc
    preview_path = "#{PDF_PREVIEW_FOLDER}/preview_title_toc-#{current_cookbook.id}_#{Time.now.to_i}.pdf"
    session[:preview_filename] = preview_path
    preview = CookbookPreviewWorker.new(
      cookbook: current_cookbook, 
      filename: preview_path
    )
    preview.title_and_toc
    render "previews/preview"
  end

  # Preview the index page
  def preview_index
    preview_path = "#{PDF_PREVIEW_FOLDER}/preview_index-#{current_cookbook.id}_#{Time.now.to_i}.pdf"
    session[:preview_filename] = preview_path
    preview = CookbookPreviewWorker.new(
      cookbook: current_cookbook, 
      filename: preview_path
    )
    preview.index
    render "previews/preview"
  end

  # Preview the introduction
  def preview_introduction
    preview_path = "#{PDF_PREVIEW_FOLDER}/preview_introduction-#{current_cookbook.id}_#{Time.now.to_i}.pdf"
    session[:preview_filename] = preview_path
    preview = CookbookPreviewWorker.new(
      cookbook: current_cookbook, 
      filename: preview_path
    )
    preview.introduction
    render "previews/preview"
  end

  # Respond with the number of pages for the current cookbook
  def count_page
    num_pages = current_cookbook.num_pages
    render json: {num_pages: num_pages}
  end
end
