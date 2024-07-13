class RateLimiterService

  STATUS = { limit: 2, interval: 60 }.freeze
  NEWS = { limit: 1, interval: 86_400 }.freeze
  MARKETING = { limit: 3, interval: 3_600 }.freeze
  LIMITERS = { status: STATUS, news: NEWS, marketing: MARKETING }.freeze

  def allowed?(type, user_id)
    return false if invalid?(type, user_id)

    limit = LIMITERS.dig(type.to_sym, :limit)
    interval = LIMITERS.dig(type.to_sym, :interval)
    key = "rate_limit:#{type}:#{user_id}"

    current_time = Time.now.to_i

    # Remove entries older than the interval
    redis_client.zremrangebyscore(key, 0, current_time - interval)
    # Get the current count of entries within the interval
    current_count = redis_client.zcard(key)
    # Add the current timestamp to the sorted set
    redis_client.zadd(key, current_time, current_time)
    # Set the expiry of the key to the interval if it does not exist already
    redis_client.expire(key, interval) if redis_client.ttl(key) == -1

    current_count < limit
  end

  private

  def invalid?(type, user_id)
    type.blank? || user_id.blank? || LIMITERS.keys.exclude?(type.to_sym)
  end

  def redis_client
    @redis_client ||= Redis.new
  end

end
