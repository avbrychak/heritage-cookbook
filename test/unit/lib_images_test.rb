require "test_helper"

class LibImageTest < ActiveSupport::TestCase

  test "should create a new image" do
    image_file = fixture_image "family-landscape.jpg"
    image = LibImage.new lib_image: image_file
    assert image.valid?
    assert image.save
  end

  test "should be able to list images tagged with a given tag name" do
    images = LibImage.find_tagged_with "family"
    assert images.count == 2
  end

  test "should be able to tag an image" do
    image_file = fixture_image "family-landscape.jpg"
    image = LibImage.new lib_image: image_file
    image.tag_with "portrait"
    assert_equal "portrait", image.tag_list.split.last
  end

  test "should be able to parse a tag with comma" do
    tags_list = "family, portrait, landscape"
    tags = Tag.parse tags_list
    assert tags.count == 3
  end

  test "should output a collection of all tags currently in use" do
    assert_equal "family", Tag.alltags.first.name
    Tag.create name: "testing"
    assert Tag.alltags.count == 1
    LibImage.first.tag_with "testing"
    assert Tag.alltags.count == 2
  end

  test "should tag an object and retrieve tagged objects" do
    tag = Tag.create name: "testing"
    image = LibImage.first
    tag.on image
    tag.tagged.first.lib_image_file_name == image.lib_image_file_name
  end
end