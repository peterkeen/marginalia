require 'test_helper'

class RegistrationControllerTest < ActionController::TestCase

  include Devise::TestHelpers

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should get new with user with non-guest email populates email" do
    user = @controller.current_or_guest_user
    user.email = "foo@bar.com"
    user.save!

    get :new
    assert_response :success
    assert_match(/foo@bar.com/, response.body)
  end

  test "should get new with user with non_nil password skips password fields" do
    user = @controller.current_or_guest_user
    user.password = "password"
    user.password_confirmation = "password"
    user.save!

    get :new
    assert_not_match(/password/, response.body)
  end

end
