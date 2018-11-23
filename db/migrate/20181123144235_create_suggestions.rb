class CreateSuggestions < ActiveRecord::Migration[5.0]
  def change
    create_table :suggestions do |t|
      t.text :changing, null: false
      t.text :suggestion, null: false
      t.references :note, foreign_key: true, index: true

      t.timestamps
    end
  end
end
