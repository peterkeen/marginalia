class ApplicationController < ActionController::Base

  include ApplicationHelper

  protect_from_forgery
  before_filter :set_current_user

  def set_current_user
    User.current = current_or_guest_user
  end

  # find guest_user object associated with the current session,
  # creating one as needed
  def guest_user
    User.find(session[:guest_user_id].nil? ? session[:guest_user_id] = create_guest_user.id : session[:guest_user_id])
  end

  private

  # called (once) when the user logs in, insert any code your application needs
  # to hand off from guest_user to current_user.
  def logging_in
    guest_user.notes.all.each do |note|
      note.user_id = current_user.id
      note.save
    end
  end

  def create_guest_user
    u = User.create(:name => "guest", :email => "guest_#{Time.now.to_i}#{rand(99)}@example.com")
    u.save(:validate => false)
    u
  end
  
end
