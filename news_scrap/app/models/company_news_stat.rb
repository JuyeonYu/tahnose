# app/models/company_news_stat.rb
class CompanyNewsStat < ApplicationRecord
  belongs_to :company

  # 유효성 검사
  validates :news_date, presence: true
  validates :news_count, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :news_date, uniqueness: { scope: :company_id }

  # 스코프 - 날짜 범위로 검색
  scope :for_date_range, lambda { |start_date, end_date|
    where(news_date: start_date..end_date)
  }

  # 스코프 - 최근 통계
  scope :recent, lambda { |days = 7|
    where('news_date >= ?', days.days.ago.to_date)
  }

  # 스코프 - 날짜 내림차순
  scope :latest_first, -> { order(news_date: :desc) }

  # 특정 날짜의 통계 가져오기 또는 생성
  def self.find_or_initialize_for(company, date)
    find_or_initialize_by(company: company, news_date: date)
  end

  # 통계 증가
  def increment_count!(amount = 1)
    increment!(:news_count, amount)
  end
end
