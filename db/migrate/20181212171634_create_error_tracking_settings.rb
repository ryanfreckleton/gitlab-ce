# frozen_string_literal: true

class CreateErrorTrackingSettings < ActiveRecord::Migration[5.0]
  include Gitlab::Database::MigrationHelpers
  disable_ddl_transaction!

  DOWNTIME = false

  def up
    create_table :project_error_tracking_settings, id: :int, primary_key: :project_id, default: nil do |t|
      t.boolean :enabled, null: false, default: true
      t.string :api_url, null: false
      t.string :encrypted_token
      t.string :encrypted_token_iv
    end

    add_concurrent_foreign_key(:project_error_tracking_settings, :projects, column: :project_id)
  end

  def down
    drop_table :project_error_tracking_settings
  end
end
