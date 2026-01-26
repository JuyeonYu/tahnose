class AddOwnerToPastes < ActiveRecord::Migration[8.1]
  def change
    add_reference :pastes, :owner, foreign_key: { to_table: :users }
  end
end
