class CreateLoginTokens < ActiveRecord::Migration[8.1]
  def change
    create_table :login_tokens do |t|
      t.references :user, null: false, foreign_key: true
      t.string :token_digest
      t.datetime :expires_at
      t.datetime :used_at
      t.string :request_ip
      t.string :user_agent

      t.timestamps
    end
  end
end
