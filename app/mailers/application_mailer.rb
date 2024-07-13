class ApplicationMailer < ActionMailer::Base

  default from: "from@example.com"
  layout "mailer"

  def notification_email(user_id, message)
    @message = message
    mail(to: user_id, subject: "Notification", from: "from@example.com")
  end

  def mailer(user_email)
    mail(to: user_email, subject: "Default", from: "from@example.com")
  end

end
