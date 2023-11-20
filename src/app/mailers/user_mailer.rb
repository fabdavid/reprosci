include Rails.application.routes.url_helpers


class UserMailer < ApplicationMailer
  default from: 'from@example.com'
  layout 'mailer'
  add_template_helper(ApplicationHelper)
  
  def invitation_mail(user, share, password)
    @user = user
    @share = share
    @share_user = share.user
    @workspace = @share.workspace
    @password = password
    mail(:from => "ReproRes_Team<noreply@epfl.ch>",
         :to => share.email,
         :subject => "ReproRes invitation")
  end
  
end
