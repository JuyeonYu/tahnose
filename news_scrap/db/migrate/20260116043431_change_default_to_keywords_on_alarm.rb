class ChangeDefaultToKeywordsOnAlarm < ActiveRecord::Migration[8.1]
  def change
    change_column_default :keywords, :on_alarm, false
  end
end
