require 'rails_helper'
require 'redis'

RSpec.describe NotificationService, type: :service do
  let(:rate_limiter) { RateLimiterService.new }
  let(:notification_service) { NotificationService.new(rate_limiter) }

  before(:each) do
    Redis.new.flushdb
    ActionMailer::Base.deliveries.clear
  end

  it 'sends messages within rate limit' do
    expect {
      notification_service.send('news', 'user@example.com', 'news 1')
    }.to change { ActionMailer::Base.deliveries.count }.by(1)
  end

  it 'rejects messages over the rate limit' do
    notification_service.send('news', 'user@example.com', 'news 1')
    expect {
      notification_service.send('news', 'user@example.com', 'news 2')
    }.to_not change { ActionMailer::Base.deliveries.count }
  end
end