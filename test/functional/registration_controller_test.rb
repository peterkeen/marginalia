require 'test_helper'

class RegistrationControllerTest < ActionController::TestCase

  include Devise::TestHelpers

  test "should get new" do
    get :new
    assert_response :success
  end

end
