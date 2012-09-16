require 'test_helper'

class StripeExportControllerTest < ActionController::TestCase
  include Devise::TestHelpers


  setup do
    @user = users(:one)
    @user.is_admin = true
    @user.save!

  end

  test "should get index" do
    sign_in @user

    u = User.new(
      :name => 'guest',
      :email => 'one@one.com',
      :password => 'foobar',
      :password_confirmation => 'foobar')
    u.stripe_id = "stripe_one"
    u.purchase_price = 1900
    u.purchased_at = Date.new(2011,1,1)
    u.save!

    u = User.new(
      :name => 'guest',
      :email => 'two@two.com',
      :password => 'foobar',
      :password_confirmation => 'foobar')
    u.stripe_id = "stripe_two"
    u.purchase_price = 1500
    u.purchased_at = Date.new(2011,1,2)
    u.save!

    get :index
    assert_response :success

    assert_equal """2011/01/01 * Marginalia Purchase
    ; StripeID: stripe_one
    Assets:Stripe:Marginalia                  $18.15
    Expenses:Stripe:Marginalia                 $0.85
    Income:Marginalia

2011/01/02 * Marginalia Purchase
    ; StripeID: stripe_two
    Assets:Stripe:Marginalia                  $14.26
    Expenses:Stripe:Marginalia                 $0.74
    Income:Marginalia

""", response.body
  end
  
end
