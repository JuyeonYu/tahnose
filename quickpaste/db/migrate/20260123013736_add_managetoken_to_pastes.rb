class AddManagetokenToPastes < ActiveRecord::Migration[8.1]
  def change
    add_column :pastes, :manage_token_digest, :string

    add_column :pastes, :manage_token_created_at, :datetime
    add_index :pastes, :manage_token_digest, unique: true
  end
end
