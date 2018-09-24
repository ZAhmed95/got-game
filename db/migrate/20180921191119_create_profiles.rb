class CreateProfiles < ActiveRecord::Migration[5.2]
  def change
    create_table :profiles do |t|
      t.integer :user_id, null: false # id of user who owns this profile
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false
      t.datetime :birth_date, null: false
      t.timestamps
    end
    add_foreign_key :profiles, :users 
  end
end
