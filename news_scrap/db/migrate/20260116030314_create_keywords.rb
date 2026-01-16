class CreateKeywords < ActiveRecord::Migration[8.1]
  def change
    create_table :keywords do |t|
      t.string :title
      t.boolean :on_alarm
      t.string :exeption

      t.timestamps
    end
  end
end
