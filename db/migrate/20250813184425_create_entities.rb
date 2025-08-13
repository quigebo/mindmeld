class CreateEntities < ActiveRecord::Migration[8.0]
  def change
    create_table :entities do |t|
      t.string :name, null: false
      t.string :entity_type, null: false
      t.references :story, null: false, foreign_key: true

      t.timestamps
    end

    add_index :entities, [:story_id, :name, :entity_type], unique: true
    add_index :entities, [:entity_type, :name]
  end
end
