class CreateSynthesizedMemories < ActiveRecord::Migration[8.0]
  def change
    create_table :synthesized_memories do |t|
      t.references :story, null: false, foreign_key: true
      t.text :content
      t.json :metadata
      t.datetime :generated_at

      t.timestamps
    end
  end
end
