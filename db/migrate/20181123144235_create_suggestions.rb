class CreateSuggestions < ActiveRecord::Migration[5.0]
  def change
    create_table :suggestions do |t|
      t.text :changing, null: false
      t.text :suggestion, null: false
      t.integer :position, null: false
      t.references :note, foreign_key: { on_delete: :cascade }, index: true
    end
  end
end
