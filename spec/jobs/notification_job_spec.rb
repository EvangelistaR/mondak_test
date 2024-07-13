# frozen_string_literal: true

require "rails_helper"

RSpec.describe NotificationJob do
  subject(:job) { described_class }

  it "is enqueueable" do
    expect { job.perform_later }.to have_enqueued_job(described_class)
  end

  describe "#perform" do
    it "sends no emails" do
      expect { job.perform_now("", "") }.not_to have_enqueued_job(ActionMailer::MailDeliveryJob)
    end

    it "sends email" do
      expect { job.perform_now("email@example.com", Faker::Lorem.sentence) }.to have_enqueued_job(ActionMailer::MailDeliveryJob)
    end
  end
end
