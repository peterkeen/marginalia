require 'test_helper'

class ProjectsControllerTest < ActionController::TestCase

  include Devise::TestHelpers

  setup do
    @project = projects(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:projects)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create project" do
    assert_difference('Project.count') do
      post :create, project: @project.attributes
    end

    assert_redirected_to project_path(assigns(:project))
  end

  test "should show project" do
    sign_in users(:one)
    get :show, id: @project.to_param
    assert_response :success
  end

  test "should get edit" do
    sign_in users(:one)
    get :edit, id: @project.to_param
    assert_response :success
  end

  test "should update project" do
    sign_in users(:one)
    put :update, id: @project.to_param, project: @project.attributes
    assert_redirected_to project_path(assigns(:project))
  end

  test "should destroy project" do
    sign_in users(:one)
    assert_difference('Project.count', -1) do
      delete :destroy, id: @project.to_param
    end

    assert_redirected_to notes_path
  end
end
