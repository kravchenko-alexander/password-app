class CreateSessions < ActiveRecord::Migration[5.2]
  def change
    create_table :sessions do |t|
      t.string :device
      t.string :access_token
      t.string :refresh_token
      t.string :push_token
      t.datetime :access_token_expired_at
      t.datetime :refresh_token_expired_at
      t.references :user, foreign_key: true
      t.timestamps null: false
    end
  end
end
