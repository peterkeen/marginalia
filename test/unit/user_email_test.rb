require 'test_helper'

class UserEmailTest < ActiveSupport::TestCase

  test "stripe fee calculated correctly" do
    user = users(:one)
    user.purchase_price = 1900

    assert_equal 85, user.stripe_fee
  end

  test "stripe fee calculated for discount" do
    user = users(:one)
    user.purchase_price = 1500
    assert_equal 74, user.stripe_fee
  end

end
