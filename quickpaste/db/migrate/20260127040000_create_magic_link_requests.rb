class CreateMagicLinkRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :magic_link_requests do |t|
      t.string :email, null: false
      t.datetime :requested_at, null: false
      t.string :ip

      t.timestamps
    end

    add_index :magic_link_requests, [:email, :requested_at]
  end
end
