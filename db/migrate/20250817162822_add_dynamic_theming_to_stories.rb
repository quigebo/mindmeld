class AddDynamicThemingToStories < ActiveRecord::Migration[8.0]
  def change
    add_column :stories, :dynamic_theming_enabled, :boolean, default: true, null: false
  end
end
