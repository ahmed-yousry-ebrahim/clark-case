class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :body
      t.integer :user_id
      t.integer :comments_count, :default => 0

      t.timestamps null: false
    end
  end
end
