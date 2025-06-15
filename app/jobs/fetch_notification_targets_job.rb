class FetchNotificationTargetsJob < ApplicationJob
  sidekiq_options retry: false

  def perform
  end
end
