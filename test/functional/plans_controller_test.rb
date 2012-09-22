require 'test_helper'

class PlansControllerTest < ActionController::TestCase

  include Devise::TestHelpers

  setup do
    sign_in users(:one)
    @plan = plans(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:plans)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create plan" do
    Stripe::Plan.expects(:create).with(
      :id => 'another_plan',
      :name => 'PlanOne',
      :amount => 1,
      :interval => 'month',
      :currency => 'usd'
    )

    assert_difference('Plan.count') do
      attributes = @plan.attributes
      attributes[:slug] = 'another_plan'
      post :create, plan: attributes
    end

    assert_redirected_to plan_path(assigns(:plan))
  end

  test "should show plan" do
    get :show, id: @plan.to_param
    assert_response :success
  end

  test "should destroy plan" do
    assert_difference('Plan.count', -1) do
      delete :destroy, id: @plan.to_param
    end

    assert_redirected_to plans_path
  end
end
