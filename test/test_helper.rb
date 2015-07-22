ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

# Do not delay jobs
Delayed::Worker.delay_jobs = false

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...

  # Model must have errors on the given fields.
  def assert_errors_on(model, *fields)
    assert !model.valid?
    fields.each do |field|
      assert !model.errors[field].empty?, "no error on the #{field} field"
    end
  end

  # Simulates user login  
  def login_as(user)
    session[:user_id] = user.id
    session[:expire_at] = Time.now + 1000
  end
  
  # Simulates user login
  def login_as_with_cookbook(user, cookbook)
    login_as(user)
    session[:cookbook_id] = cookbook.id
  end

  # Return a Lorem Ipsum string
  def self.lorem
    return "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
  end
  def lorem; ActiveSupport::TestCase.lorem; end

  # Return the path to an image in the fixture/images folder.
  def self.fixture_image(filename)
    pathname = Rails.root.join("test", "fixtures", "images", filename)
    return File.new(pathname.to_path)
  end
  def fixture_image(filename); ActiveSupport::TestCase.fixture_image(filename); end
end
