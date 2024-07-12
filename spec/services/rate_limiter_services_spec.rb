require 'rails_helper'
require 'redis'

RSpec.describe RateLimiterService do
  let(:redis) { Redis.new }
  let(:rate_limiter) { RateLimiterService.new }

  before(:each) do
    redis.flushdb
  end

  context 'when the notification type is "status"' do
    it 'allows sending up to 2 notifications per minute (success scenario)' do
      2.times do
        expect(rate_limiter.allowed?('status', 'user1')).to be true
      end
    end

    it 'rejects sending more than 2 notifications per minute (failure scenario)' do
      2.times { rate_limiter.allowed?('status', 'user1') }
      expect(rate_limiter.allowed?('status', 'user1')).to be false
    end
  end

  context 'when the notification type is "news"' do
    it 'allows sending 1 notification per day (success scenario)' do
      expect(rate_limiter.allowed?('news', 'user1')).to be true
    end

    it 'rejects sending more than 1 notification per day (failure scenario)' do
      rate_limiter.allowed?('news', 'user1')
      expect(rate_limiter.allowed?('news', 'user1')).to be false
    end
  end

  context 'when the notification type is "marketing"' do
    it 'allows sending up to 3 notifications per hour (success scenario)' do
      3.times do
        expect(rate_limiter.allowed?('marketing', 'user1')).to be true
      end
    end

    it 'rejects sending more than 3 notifications per hour (failure scenario)' do
      3.times { rate_limiter.allowed?('marketing', 'user1') }
      expect(rate_limiter.allowed?('marketing', 'user1')).to be false
    end
  end

  context 'when the notification type is not limited' do
    it 'allows sending unlimited notifications (success scenario)' do
      100.times do
        expect(rate_limiter.allowed?('unlimited', 'user1')).to be true
      end
    end
  end
end
