class CreateStoryThemes < ActiveRecord::Migration[8.0]
  def change
    create_table :story_themes do |t|
      t.references :story, null: false, foreign_key: true, index: { unique: true }
      t.references :source_entity, null: false, foreign_key: { to_table: :entities }
      t.string :background_image_url
      t.string :icon_pack
      t.json :metadata, default: {}
      t.timestamps
    end
  end
end
