class FetchNewsBatchJob < ApplicationJob
  queue_as :default

  def perform
    Keyword.find_each do |keyword|
      FetchNewsJob.perform_later(keyword.id)
    end
  end
end
