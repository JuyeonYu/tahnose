# app/services/news_fetcher.rb

require 'faraday'
require 'json'

class NewsFetcher
  API_ENDPOINT = 'https://openapi.naver.com/v1/search/news.json'

  def self.call(keyword:)
    new(keyword).call
  end

  def initialize(keyword)
    @keyword = keyword
  end

  def call
    resp = Faraday.get(API_ENDPOINT) do |req|
      req.params['query'] = @keyword.title
      req.params['display'] = 100
      req.params['sort'] = 'date'

      req.headers['X-Naver-Client-Id'] = ENV['NAVER_CLIENT_ID']
      req.headers['X-Naver-Client-Secret'] = ENV['NAVER_CLIENT_SECRET']
      req.headers['Accept'] = 'application/json'
    end

    return [] unless resp.success?

    json = JSON.parse(resp.body)
    items = json['items']

    items.map do |item|
      {
        title: item['title'],
        originallink: item['originallink'],
        description: item['description'],
        pubDate: item['pubDate']
      }
    end
  end
end
