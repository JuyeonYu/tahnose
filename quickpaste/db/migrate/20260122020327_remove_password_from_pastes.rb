class RemovePasswordFromPastes < ActiveRecord::Migration[8.1]
  def change
    remove_column :pastes, :password, :string
  end
end
