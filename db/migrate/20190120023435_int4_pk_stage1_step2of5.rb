# frozen_string_literal: true

class Int4PkStage1Step2of5 < ActiveRecord::Migration[5.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    if Gitlab::Database.postgresql?
      # Drop invalid index if there was a failed attempt to execute this migration before.
      # remove_concurrent_index_by_name checks itself if the index exists.
      remove_concurrent_index_by_name(:events, :events_id_new_idx)
      remove_concurrent_index_by_name(:push_event_payloads, :push_event_payloads_event_id_new_idx)

      # Time estimate for GitLab.com: ~420s (~7 min)
      add_concurrent_index(:events, :id_new, unique: true, name: :events_id_new_idx)
      # Time estimate for GitLab.com: ~360s (~6 min)
      add_concurrent_index(:push_event_payloads, :event_id_new, unique: true, name: :push_event_payloads_event_id_new_idx)
    end
  end

  def down
    if Gitlab::Database.postgresql?
      remove_concurrent_index_by_name(:push_event_payloads, :push_event_payloads_event_id_new_idx)
      remove_concurrent_index_by_name(:events, :events_id_new_idx)
    end
  end
end
