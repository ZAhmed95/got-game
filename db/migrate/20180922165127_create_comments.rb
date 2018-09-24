class CreateComments < ActiveRecord::Migration[5.2]
  def change
    create_table :comments do |t|
      t.integer :user_id, null: false # user who made the comment
      t.integer :post_id, null: false # the post thread this comment was made in
      t.text :comment, null: false # the comment itself
      t.timestamps
    end
    add_foreign_key :comments, :users
    add_foreign_key :comments, :posts
  end
end
