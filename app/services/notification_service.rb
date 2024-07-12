class NotificationService

  def initialize(rate_limiter)
    @rate_limiter = rate_limiter
  end

  def send(type, user_id, message)
    return puts "Rate limit exceeded for #{user_id} on #{type}" unless @rate_limiter.allowed?(type, user_id)

    NotificationMailer.send_email(user_id, message).deliver_now
  end

end
