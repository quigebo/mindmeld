class CreateStories < ActiveRecord::Migration[8.0]
  def change
    create_table :stories do |t|
      t.string :title
      t.text :description
      t.references :creator, null: false, foreign_key: { to_table: :users }
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end
end
