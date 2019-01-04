# frozen_string_literal: true

class CreateErrorTrackingSettings < ActiveRecord::Migration[5.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def change
    create_table :project_error_tracking_settings, id: :bigserial do |t|
      t.references :project, null: false, index: { unique: true }, foreign_key: { on_delete: :cascade }
      t.boolean :enabled, null: false, default: true
      t.string :api_url, null: false
      t.string :encrypted_token
      t.string :encrypted_token_iv
    end
  end
end
