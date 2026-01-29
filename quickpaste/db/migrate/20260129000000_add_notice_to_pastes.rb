class AddNoticeToPastes < ActiveRecord::Migration[8.0]
  def change
    add_column :pastes, :notice, :boolean, null: false, default: false
    add_index :pastes, :notice
  end
end
