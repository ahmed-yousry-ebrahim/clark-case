class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :body
      t.integer :user_id
      t.integer :comments_count

      t.timestamps null: false
    end
  end
end
