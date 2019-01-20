# frozen_string_literal: true

class Int4PkStage1Step2 < ActiveRecord::Migration[5.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    if index_exists_by_name?(:events, :events_id_new_idx)
      remove_concurrent_index_by_name(:events_id_new_idx)
    end
    add_concurrent_index(:events, :id_new, unique: true, name: :events_id_new_idx)
  end

  def down
    remove_concurrent_index_by_name(:events_id_new_idx)
  end
end
