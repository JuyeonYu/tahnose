# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

require 'csv'

def seed_csv(path, &block)
  CSV.read(path, headers: true).map(&block)
end

Keyword.insert_all(
  seed_csv('db/seeds/kospi100.csv') do |row|
    {
      title: row['title'],
      created_at: Time.current,
      updated_at: Time.current
    }
  end
)
