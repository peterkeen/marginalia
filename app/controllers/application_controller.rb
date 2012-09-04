class ApplicationController < ActionController::Base

  include ApplicationHelper

  protect_from_forgery

  before_filter :set_unique_id

  def set_unique_id

    if session[:guest_user_id] || user_signed_in?
      unique_id = cookies.signed[:unique_id] || SecureRandom.hex(10)
      user = current_or_guest_user
      if user.unique_id.nil?
        user.unique_id = unique_id.to_s
        user.save!
      else
        unique_id = user.unique_id
      end
      cookies.permanent.signed[:unique_id] = unique_id
    else
      return if cookies.signed[:unique_id]
      cookies.permanent.signed[:unique_id] = SecureRandom.hex(10)
    end

  end

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
      note.from_address = current_user.email
      note.save
    end
    current_user.unique_id = guest_user.unique_id
    current_user.save
  end

  def create_guest_user
    u = User.create(
      :name      => "guest",
      :email     => "guest_#{Time.now.to_i}#{rand(99)}@example.com",
      :unique_id => cookies.signed[:unique_id],
    )
    u.save(:validate => false)
    log_event("Started Trial")
    u
  end

end
