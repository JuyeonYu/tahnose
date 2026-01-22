class AddPasswordDigestToPastes < ActiveRecord::Migration[8.1]
  def change
    add_column :pastes, :password_digest, :string
  end
end
