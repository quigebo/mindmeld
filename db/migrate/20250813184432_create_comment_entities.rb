class CreateCommentEntities < ActiveRecord::Migration[8.0]
  def change
    create_table :comment_entities do |t|
      t.references :comment, null: false, foreign_key: true
      t.references :entity, null: false, foreign_key: true
      t.decimal :confidence_score, precision: 3, scale: 2, null: false

      t.timestamps
    end

    add_index :comment_entities, [:comment_id, :entity_id], unique: true
    add_index :comment_entities, [:entity_id, :confidence_score]
  end
end
