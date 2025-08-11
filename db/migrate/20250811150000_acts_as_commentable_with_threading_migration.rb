class ActsAsCommentableWithThreadingMigration < ActiveRecord::Migration[8.0]
  def self.up
    create_table :comments, force: true do |t|
      t.integer :commentable_id
      t.string :commentable_type
      t.string :title
      t.text :body
      t.string :subject
      t.integer :user_id, null: false
      t.integer :parent_id
      t.integer :lft
      t.integer :rgt
      t.timestamps
    end

    add_index :comments, :user_id
    add_index :comments, [:commentable_id, :commentable_type]
    add_index :comments, :parent_id
    add_index :comments, [:lft, :rgt]
  end

  def self.down
    drop_table :comments
  end
end
