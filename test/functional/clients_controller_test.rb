require 'test_helper'

class ClientsControllerTest < ActionController::TestCase

  include Devise::TestHelpers

  setup do
    sign_in users(:one)
    @client = Devise::Oauth2Providable::Client.create(:name => "foo", :website => "www.bar.com")
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:clients)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create client" do
    assert_difference('Devise::Oauth2Providable::Client.count') do
      post :create, client: { :name => 'foo2', :website => 'www.bar2.com' }
    end

    assert_redirected_to client_path(assigns(:client))
  end

  test "should show client" do
    get :show, id: @client.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @client.to_param
    assert_response :success
  end

  test "should update client" do
    put :update, id: @client.to_param, client: @client.attributes
    assert_redirected_to client_path(assigns(:client))
  end

  test "should destroy client" do
    assert_difference('Devise::Oauth2Providable::Client.count', -1) do
      delete :destroy, id: @client.to_param
    end

    assert_redirected_to clients_path
  end
end
