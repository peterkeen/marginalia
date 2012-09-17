require 'test_helper'

class RegistrationControllerTest < ActionController::TestCase

  include Devise::TestHelpers

  test "should get new" do
    get :new
    assert_response :success
    assert_match(/user_email/, response.body)
    assert_match(/user_password/, response.body)
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

    user.email = "foo@bar.com"
    user.password = "password"
    user.password_confirmation = "password"
    user.save!

    p user.id
    p user.encrypted_password

    user.reload

    get :new
    assert_not_match(/Password/, response.body)
  end

  test "should get new with existing user and discount code" do
    user = users(:one)

    user.password = "password"
    user.password_confirmation = "password"
    user.save!

    get :new, :user_id => user.id, :discount_code => 'TWENTYSEPT'
    assert_not_match(/Password/, response.body)
    assert_match(/\$15/, response.body)

    assert_equal 1500, session[:price]
  end

end
