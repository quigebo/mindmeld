class CreateParticipants < ActiveRecord::Migration[8.0]
  def change
    create_table :participants do |t|
      t.references :user, null: false, foreign_key: true
      t.references :story, null: false, foreign_key: true
      t.string :status
      t.datetime :invited_at
      t.datetime :joined_at

      t.timestamps
    end

    add_index :participants, [:user_id, :story_id], unique: true
    add_index :participants, :status
  end
end
