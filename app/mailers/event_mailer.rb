class EventMailer < ActionMailer::Base

  def welcome_to_marginalia(user_id)
    @user = User.find(user_id)

    mail(
      :to      => @user.email,
      :from    => 'Pete Keen at Marginalia <pete@marginalia.io>',
      :bcc     => 'pete@marginalia.io',
      :subject => 'Welcome to Marginalia!',
    )
  end
end

