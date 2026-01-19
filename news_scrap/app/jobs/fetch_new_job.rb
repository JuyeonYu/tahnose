class FetchNewsJob < ApplicationJob
  queue_as :default

  def perform(keyword_id)
    keyword = Keyword.find(keyword_id)
    NewsFetcher.call(keyword: keyword)
  end
end
