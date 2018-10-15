class CreatePasswordSets < ActiveRecord::Migration[5.2]
  def change
    create_table :password_sets do |t|
      t.string :access_token
      t.boolean :decrypted, default: false
      t.references :user, foreign_key: true
      t.timestamps null: false
    end
  end
end
