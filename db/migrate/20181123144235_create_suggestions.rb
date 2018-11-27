class CreateSuggestions < ActiveRecord::Migration
  DOWNTIME = false

  def change
    create_table :suggestions do |t|
      t.text :changing, null: false
      t.text :suggestion, null: false
      t.integer :relative_order, null: false
      t.boolean :applied, null: false, default: false
      t.references :diff_note,
        references: :notes,
        index: true,
        null: false
    end

    add_foreign_key :suggestions, :notes,
      column: :diff_note_id,
      on_delete: :cascade
  end
end
