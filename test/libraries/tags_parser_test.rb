require 'test_helper'

class CookbookGeneratorTest < ActiveSupport::TestCase

  test "load a csv file and parse tags" do
    parser = TagsParser.new "#{fixture_path}/wordpress_tags.csv"
    assert_equal ["Fresh coriander"], parser.match("Fresh coriander", "Wrong")
  end
end