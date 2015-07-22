require "test_helper"

class UserTest < ActiveSupport::TestCase
  
  test "user authentication" do
    user = users(:brian_smith)
    assert user.authenticate "password"
    assert !user.authenticate("wrong_password")
  end
end
