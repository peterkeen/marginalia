require 'test_helper'

class NotesControllerTest < ActionController::TestCase

  include Devise::TestHelpers

  setup do
    @note = notes(:one)
  end

  test "should get index" do
    sign_in users(:one)

    get :index
    assert_response :success
    assert_not_nil assigns(:notes)
  end

  test "should get new" do
    sign_in users(:one)

    get :new
    assert_response :success
  end

  test "should get new for guest" do
    get :new
    assert_response :success

    assert_match(/This is an example note/, response.body)
  end

  test "get new for guest should have email modal" do
    get :new, { :show_email_modal_0002 => true }
    assert_match(/email_modal/, response.body)
  end

  test "post create for guest should have buy modal" do

    @controller.current_or_guest_user

    Note.create(:user_id => session[:guest_user_id], :body => "test", :title => "test")
    Note.create(:user_id => session[:guest_user_id], :body => "test", :title => "test")
    Note.create(:user_id => session[:guest_user_id], :body => "test", :title => "test")
    Note.create(:user_id => session[:guest_user_id], :body => "test", :title => "test")

    post :create, :note => { :title => 'foo', :body => 'bar' }

    assert_match(/buy_modal/, response.body)
  end

  test "should create note" do
    sign_in users(:one)

    assert_difference('Note.count') do
      post :create, note: @note.attributes
    end

    assert_redirected_to note_path(assigns(:note))
  end

  test "should create note from mailgun" do
    assert_difference('Note.count') do
      token = 'hi'
      timestamp = '123'
      ENV['MAILGUN_API_KEY'] = 'key'
      signature = OpenSSL::HMAC.hexdigest(
        OpenSSL::Digest::Digest.new('sha256'),
        'key',
        '123hi'
      )

      post :create_from_mailgun,
        'subject' => "hi",
        'stripped-text' => 'there',
        'from' => 'one@foo.bar',
        'token' => token,
        'timestamp' => timestamp,
        'signature' => signature
    end
  end

  test "should show note" do
    sign_in users(:one)
    get :show, id: notes(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    sign_in users(:one)
    get :edit, id: @note.to_param
    assert_response :success
  end

  test "should update note" do
    sign_in users(:one)
    put :update, id: @note.to_param, note: @note.attributes
    assert_redirected_to note_path(assigns(:note))
  end

  test "should destroy note" do
    sign_in users(:one)
    assert_difference('Note.count', -1) do
      delete :destroy, id: @note.to_param
    end

    assert_redirected_to notes_path
  end

  test "adding email sets email address on user" do
    user = @controller.current_or_guest_user
    get :create, { :note => { :title => "title", :body => "body", :new_email_address => 'foo@bar.com' } }

    user.reload
    assert_equal "foo@bar.com", user.email
  end

  test "adding email sets email address on user email" do
    user = @controller.current_or_guest_user
    get :create, { :note => { :title => "title", :body => "body", :new_email_address => 'foo@bar.com' } }

    user.reload
    assert_equal "foo@bar.com", user.user_emails.first.reload.email
  end

  test "adding password sets password on user" do
    user = @controller.current_or_guest_user
    assert !user.valid_password?('password')

    get :create, { :note => { :title => "title", :body => "body", :new_password => 'password', :user_id => user.id } }

    user.reload
    assert user.valid_password?('password'), "Expected 'password' to be the new password"
  end

end
