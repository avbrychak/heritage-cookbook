class Admin::ImageLibraryController < ApplicationController
  layout 'admin'

  before_filter :authenticated?
  before_filter :admin?

  def index
    @tags = Tag.order(:name)
    @images = params[:tag] ? LibImage.find_tagged_with(params[:tag]) : LibImage.order("id desc")
    @tag = params[:tag] || "All tags"
  end

  def new
    @image = LibImage.new
  end

  def create
    @image = LibImage.new(params[:lib_image])
    @image.tag_with params[:tag_names]
    if @image.save
      redirect_to admin_image_library_index_path
    else
      render :new
    end
  end

  def edit
    @image = LibImage.find(params[:id])
  end

  def update
    @image = LibImage.find(params[:id])
    @image.tag_with params[:tag_names]
    if @image.save
      redirect_to admin_image_library_index_path
    else
      render :edit
    end
  end

  def destroy
    @image = LibImage.find(params[:id])
    @image.destroy
    redirect_to admin_image_library_index_path
  end

  private

  def verify_tags_are_included(tagged_object)
    if params[:tags].empty?
      tagged_object.errors.add :tag, "You need to add at least one tag to this image"
      return []
    end
    return params[:tags].split
  end
end
