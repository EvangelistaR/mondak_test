class NotificationMailer < ApplicationMailer
  default from: 'no-reply@example.com'

  def send_email(user_id, message)
    @message = message
    mail(to: user_id, subject: 'Notification')
  end
end