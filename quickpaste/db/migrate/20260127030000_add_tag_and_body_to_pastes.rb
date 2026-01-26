class AddTagAndBodyToPastes < ActiveRecord::Migration[8.1]
  def change
    add_column :pastes, :tag, :string
    rename_column :pastes, :content, :body
  end
end
