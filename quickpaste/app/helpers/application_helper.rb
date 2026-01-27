module ApplicationHelper
  def ga_measurement_id
    return nil unless Rails.env.production?

    ENV["GA_MEASUREMENT_ID"].presence
  end
end
