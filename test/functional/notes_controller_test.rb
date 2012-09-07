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

end
