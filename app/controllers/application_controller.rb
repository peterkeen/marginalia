class ApplicationController < ActionController::Base

  include ApplicationHelper

  protect_from_forgery

  # find guest_user object associated with the current session,
  # creating one as needed
  def guest_user
    guest_id = session[:guest_user_id]
    if guest_id.nil? || User.find(guest_id).nil?
      user = create_guest_user
      session[:guest_user_id] = user.id
      return User.find(user.id)
    end
    User.find(guest_id)
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
