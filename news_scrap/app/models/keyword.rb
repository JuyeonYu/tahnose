class Keyword < ApplicationRecord
  validates :title, presence: true
  has_many :company_news_stats, dependent: :destroy

  # 특정 날짜의 뉴스 수 가져오기
  def news_count_on(date)
    company_news_stats.find_by(news_date: date)&.news_count || 0
  end

  # 날짜 범위의 총 뉴스 수
  def total_news_count(start_date, end_date)
    company_news_stats.for_date_range(start_date, end_date).sum(:news_count)
  end

  # 최근 7일 뉴스 수
  def recent_news_count(days = 7)
    company_news_stats.recent(days).sum(:news_count)
  end
end
