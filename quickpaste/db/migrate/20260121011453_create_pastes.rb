class CreatePastes < ActiveRecord::Migration[8.1]
  def change
    create_table :pastes do |t|
      t.text :content
      t.datetime :expires_at
      t.string :read_once_boolean
      t.integer :view_count

      t.timestamps
    end
  end
end
