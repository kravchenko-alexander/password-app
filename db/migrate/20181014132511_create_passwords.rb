class CreatePasswords < ActiveRecord::Migration[5.2]
  def change
    create_table :passwords do |t|
      t.string :encrypted_password
      t.references :password_set, foreign_key: true
      t.timestamps null: false
    end
  end
end
