module ApplicationHelper
  def ga_measurement_id
    enabled = Rails.env.production? || ActiveModel::Type::Boolean.new.cast(ENV["ENABLE_GA"])
    return nil unless enabled

    ENV["GA_MEASUREMENT_ID"].presence
  end
end
