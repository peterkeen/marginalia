class ApplicationController < ActionController::Base

  include ApplicationHelper

  protect_from_forgery

  before_filter :set_unique_id
  before_filter :set_abingo_id

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

  def set_abingo_id
    return if request.env['USER_AGENT'].try(:match, /NewRelic/)
    Abingo.identity = cookies.signed[:unique_id]
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
    newpass = SecureRandom.hex(50)
    u = User.create(
      :name      => "guest",
      :email     => "guest_#{Time.now.to_i}#{rand(99)}@example.com",
      :unique_id => cookies.signed[:unique_id],
      :password  => newpass,
      :password_confirmation => newpass
    )
    u.is_guest = true
    u.save!
    log_event("Started Trial")
    u
  end

end
