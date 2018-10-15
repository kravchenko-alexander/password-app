class CreatePasswordViews < ActiveRecord::Migration[5.2]
  def change
    create_table :password_views do |t|
      t.string :status
      t.string :ip
      t.references :password_set, foreign_key: true
      t.integer :viewer_id
      t.timestamps null: false
    end
  end
end
