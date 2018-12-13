# frozen_string_literal: true

class CreateProjectDailyStatistics < ActiveRecord::Migration[5.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def change
    create_table :project_daily_statistics, id: :bigserial do |t|
      t.integer :project_id, null: false
      t.integer :fetch_count, null: false
      t.date :date
    end

    add_index :project_daily_statistics, [:project_id, :date], unique: true, order: { date: :desc }
    # rubocop:disable Migration/AddConcurrentForeignKey
    add_foreign_key :project_daily_statistics, :projects, on_delete: :cascade
  end
end
