class AddDefaultToKeywordsOnAlarm < ActiveRecord::Migration[8.1]
  def change
    change_column_default :keywords, :on_alarm, true
  end
end
