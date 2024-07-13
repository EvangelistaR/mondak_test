class NotificationJob < ApplicationJob

  def perform(user_id, message)
    return if user_id.blank? || message.blank?

    ApplicationMailer.notification_email(user_id, message).deliver_later
  end

end
