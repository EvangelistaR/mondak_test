require "rails_helper"
require "redis"

RSpec.describe NotificationService, type: :service do
  let(:notification_service) { described_class.new }

  before { Redis.new.flushdb }

  context "with invalid params" do
    it "does not enqueue email with a invalid type" do
      expect { notification_service.send("tech", "user@example.com", "news 2") }.not_to have_enqueued_job(NotificationJob)
    end

    it "does not enqueue email with a blank user_id" do
      expect { notification_service.send("status", nil, "news 2") }.not_to have_enqueued_job(NotificationJob)
    end

    it "does not enqueue email with a blank type" do
      expect { notification_service.send("", "user@example.com", "news 2") }.not_to have_enqueued_job(NotificationJob)
    end
  end

  context "with valid params" do
    context "when the notification type is 'marketing'" do
      it "allows sending up to 3 notifications per hour" do
        expect do
          3.times { notification_service.send("marketing", "user@example.com", "news 2") }
        end.to have_enqueued_job(NotificationJob).exactly(3).times
      end

      context "when calls the notifications multiple time" do
        it "rejects sending more than 3 notifications per hour" do
          expect do
            4.times { notification_service.send("marketing", "user@example.com", "news 2") }
          end.to have_enqueued_job(NotificationJob).exactly(3).times
        end

        it "resets the limit after 1 hour" do
          3.times { notification_service.send("marketing", "user@example.com", "news 2") }

          travel_to(Time.current + 1.hour) do
            expect { notification_service.send("marketing", "user@example.com", "news 2") }.to have_enqueued_job(NotificationJob)
          end
        end
      end
    end

    context "when the notification type is 'news'" do
      it "allows sending 1 notification per day" do
        expect { notification_service.send("news", "user@example.com", "news 2") }.to have_enqueued_job(NotificationJob)
      end

      context "when calls the notifications multiple time" do
        it "rejects sending more than 1 notification per day" do
          expect do
            2.times { notification_service.send("news", "user@example.com", "news 2") }
          end.to have_enqueued_job(NotificationJob).exactly(:once)
        end

        it "resets the limit after 1 day" do
          notification_service.send("news", "user@example.com", "news 2")

          travel_to(Time.current.tomorrow) do
            expect { notification_service.send("news", "user@example.com", "news 2") }.to have_enqueued_job(NotificationJob)
          end
        end
      end
    end

    context "when the notification type is 'status'" do
      it "allows sending up to 2 notifications per minute" do
        expect do
          2.times { notification_service.send("status", "user@example.com", "news 2") }
        end.to have_enqueued_job(NotificationJob).exactly(:twice)
      end

      context "when calls the notifications multiple time" do
        it "rejects sending more than 2 notifications per minute" do
          expect do
            2.times { notification_service.send("status", "user@example.com", "news 2") }
          end.to have_enqueued_job(NotificationJob).exactly(:twice)
        end

        it "resets the limit after 1 minute" do
          2.times { notification_service.send("status", "user@example.com", "news 2") }

          travel_to(Time.current + 1.minute) do
            expect { notification_service.send("status", "user@example.com", "news 2") }.to have_enqueued_job(NotificationJob)
          end
        end
      end
    end
  end
end
