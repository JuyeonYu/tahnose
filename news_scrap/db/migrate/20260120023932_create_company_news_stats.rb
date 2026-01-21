class CreateCompanyNewsStats < ActiveRecord::Migration[8.1]
  def change
    create_table :company_news_stats do |t|
      t.references :company, null: false, foreign_key: true
      t.date :news_date, null: false
      t.integer :news_count, null: false, default: 0

      t.timestamps
    end

    # 같은 회사의 같은 날짜는 하나만 존재하도록
    add_index :company_news_stats, %i[company_id news_date], unique: true

    # 날짜로 검색할 때 성능 향상
    add_index :company_news_stats, :news_date
  end
end
