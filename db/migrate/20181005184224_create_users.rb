class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :email, null: false, default: ''
      t.string :password_digest, null: false, default: ''

      t.timestamps null: false
    end
  end
end
