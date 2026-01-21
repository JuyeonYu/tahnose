# app/jobs/fetch_news_job.rb
class FetchNewsJob < ApplicationJob
  queue_as :default

  def perform(keyword_id)
    keyword = Keyword.find(keyword_id)
    articles = NewsFetcher.call(keyword: keyword)

    return if articles.blank?

    upsert_statistics(keyword, articles)
  end

  private

  def upsert_statistics(keyword, articles)
    # 날짜별 카운트 계산
    stats_data = calculate_date_counts(articles).map do |date, count|
      {
        company_id: keyword.id, # keyword가 company
        news_date: date,
        news_count: count,
        created_at: Time.current,
        updated_at: Time.current
      }
    end

    # 한 번에 upsert (기존 값에 더하기)
    CompanyNewsStat.upsert_all(
      stats_data,
      unique_by: %i[company_id news_date],
      on_duplicate: Arel.sql('news_count = news_count + EXCLUDED.news_count')
    )
  end

  def calculate_date_counts(articles)
    articles.group_by do |article|
      parse_date(article[:pubDate])
    end.transform_values(&:count)
  end

  def parse_date(pub_date_string)
    Date.parse(pub_date_string)
  rescue ArgumentError => e
    Rails.logger.warn("Failed to parse date: #{pub_date_string}")
    Date.today
  end
end
