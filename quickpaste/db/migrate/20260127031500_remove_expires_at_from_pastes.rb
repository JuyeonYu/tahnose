class RemoveExpiresAtFromPastes < ActiveRecord::Migration[8.1]
  def change
    remove_column :pastes, :expires_at, :datetime
  end
end
