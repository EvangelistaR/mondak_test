class RateLimiterService

  def initialize
    @redis = Redis.new
    @limits = {
      'status' => { limit: 2, interval: 60 },
      'news' => { limit: 1, interval: 86400 },
      'marketing' => { limit: 3, interval: 3600 }
    }
  end

  def allowed?(type, user_id)
    return true unless @limits.key?(type)

    limit = @limits[type][:limit]
    interval = @limits[type][:interval]
    key = "rate_limit:#{type}:#{user_id}"

    current_time = Time.now.to_i
    pipeline = @redis.pipelined do |redis|
      redis.zremrangebyscore(key, 0, current_time - interval)
      redis.zcard(key)
      redis.zadd(key, current_time, current_time)
      redis.expire(key, interval)
    end

    puts "Current count for #{key}: #{pipeline[1]}, limit: #{limit}"
    pipeline[1] < limit
  end

end
