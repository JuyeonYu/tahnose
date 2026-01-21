class FixReadOnceOnPastes < ActiveRecord::Migration[8.1]
  def change
    add_column :pastes, :read_once, :boolean, default: false, null: false
    remove_column :pastes, :read_once_boolean
  end
end
