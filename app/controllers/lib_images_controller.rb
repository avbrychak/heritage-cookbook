class LibImagesController < ApplicationController

  # Display all tags containing images.
  def index
    @tags = Tag.order(:name)
    @field = params[:field]
    @images = @tags.first.tagged
  end

  # Display all images in the selected tag.
  def show
    @tag = Tag.find(params[:id])
    @images = @tag.tagged
    @field = params[:field]
  end

  # Select an image to be used in the cookbook.
  def select
    @image = LibImage.find(params[:id])
    @field = params[:field]
  end
end