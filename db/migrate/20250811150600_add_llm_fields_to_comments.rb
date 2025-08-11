class AddLlmFieldsToComments < ActiveRecord::Migration[8.0]
  def change
    add_column :comments, :is_memory_worthy, :boolean, default: false
    add_column :comments, :llm_analysis, :json
    add_column :comments, :location, :string
    add_column :comments, :occurred_at, :datetime

    add_index :comments, :is_memory_worthy
    add_index :comments, :occurred_at
  end
end
