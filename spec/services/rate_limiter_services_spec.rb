require 'rails_helper'
require 'redis'

RSpec.describe RateLimiterService do
  let(:rate_limiter) { described_class.new }
  let(:user_id) { "user1" }

  before { Redis.new.flushdb }

  context "with invalid parameters" do
    it "rejects sending notification for type as null" do
      expect(rate_limiter.allowed?(nil, user_id)).to be false
    end

    it "rejects sending notification for type as not expected" do
      expect(rate_limiter.allowed?("techology", user_id)).to be false
    end

    it "rejects sending notification for valid type and user_id as null" do
      expect(rate_limiter.allowed?("status", nil)).to be false
    end
  end

  context "with valid parameters" do
    context "when the notification type is 'status'" do
      let(:type) { "status" }

      it "allows sending up to 2 notifications per minute" do
        2.times { expect(rate_limiter.allowed?(type, user_id)).to be true }
      end

      context "when sends multiples notifications" do
        before { 2.times { rate_limiter.allowed?(type, user_id) } }

        it "rejects sending more than 2 notifications per minute" do
          expect(rate_limiter.allowed?(type, user_id)).to be false
        end

        it "resets the limit after 1 minute" do
          travel_to(Time.current + 1.minute) { expect(rate_limiter.allowed?(type, user_id)).to be true }
        end
      end
    end

    context "when the notification type is news'" do
      let(:type) { "news" }

      it "allows sending 1 notification per day" do
        expect(rate_limiter.allowed?(type, user_id)).to be true
      end

      context "when sends multiples notifications" do
        before { rate_limiter.allowed?(type, user_id) }

        it "rejects sending more than 1 notification per day" do
          expect(rate_limiter.allowed?(type, user_id)).to be false
        end

        it "resets the limit after 1 day" do
          travel_to(Time.current.tomorrow) { expect(rate_limiter.allowed?(type, user_id)).to be true }
        end
      end
    end

    context "when the notification type is 'marketing'" do
      let(:type) { "marketing" }

      it "allows sending up to 3 notifications per hour" do
        3.times { expect(rate_limiter.allowed?(type, user_id)).to be true }
      end

      context "when sends multiples notifications" do
        before { 3.times { rate_limiter.allowed?(type, user_id) } }

        it "rejects sending more than 3 notifications per hour" do
          expect(rate_limiter.allowed?(type, user_id)).to be false
        end

        it "resets the limit after 1 hour" do
          travel_to(Time.current + 1.hour) { expect(rate_limiter.allowed?(type, user_id)).to be true }
        end
      end
    end
  end
end
