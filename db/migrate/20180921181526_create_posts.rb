class CreatePosts < ActiveRecord::Migration[5.2]
  def change
    create_table :posts do |t|
      t.integer :user_id, null: false # the user who created this post
      t.integer :game_id # the IGDB id for the game this post is about
      t.text :game_title, null: false # title of the game
      t.text :title, null: false # title of the post
      t.text :content, null: false # content of the post
      t.timestamps
    end
    add_foreign_key :posts, :users
  end
end
