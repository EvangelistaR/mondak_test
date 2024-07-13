class NotificationService

  attr_reader :rate_limiter

  def initialize
    @rate_limiter = RateLimiterService.new
  end

  def send(type, user_id, message)
    return unless rate_limiter.allowed?(type, user_id)

    NotificationJob.perform_later(user_id, message)
  end

end
