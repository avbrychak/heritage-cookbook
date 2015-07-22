require 'test_helper'

class TemplateConfigurationTest < ActiveSupport::TestCase

	def setup
    @config = TemplateConfiguration.new(1, template_folder: Rails.root.join("test", "book_templates"))
	end

	test "should load template properties into a hash" do
		assert @config.properties.is_a? Hash
	end

	test "each template properties stored in the config file must have a getter" do
    assert_equal "Times", @config.book_font
    assert @config.respond_to? :book_font
  end

  test "support for boolean properties" do
    assert_equal true, @config.has_image?
    assert @config.respond_to? :has_image?
  end

  test "Cannot load template config error" do
  	assert_raise TemplateConfigurationError do
  		TemplateConfiguration.new(1, template_folder: Rails.root.join("unknow", "folder"))
  	end
  end
end