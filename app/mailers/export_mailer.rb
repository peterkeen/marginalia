class ExportMailer < ActionMailer::Base
  default from: "Marginalia <exports@marginalia.io>"

  def export_done(user_id, export_id)
    @user = User.find(user_id)

    @export = Export.find(export_id)

    mail(
      :to => "#{@user.name} <#{@user.email}>",
      :subject => "Your export is finished"
    )
  end
  
end
