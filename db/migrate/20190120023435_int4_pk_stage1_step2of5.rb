# frozen_string_literal: true

class Int4PkStage1Step2of5 < ActiveRecord::Migration[5.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    if Gitlab::Database.postgresql?
      # drop invalid index if there were a failed attempt to run it already
      # the method checks itself if the index exists
      remove_concurrent_index_by_name(:events, :events_id_new_idx)
      remove_concurrent_index_by_name(:push_event_payloads, :push_event_payloads_events_id_new_idx)

      # time estimate for GitLab.com: 422s (~7 min)
      add_concurrent_index(:events, :id_new, unique: true, name: :events_id_new_idx)
      # time estimate for GitLab.com: ???s (~?? min)
      add_concurrent_index(:push_event_payloads, :event_id_new, unique: true, name: :push_event_payloads_events_id_new_idx)
    end
  end

  def down
    if Gitlab::Database.postgresql?
      remove_concurrent_index_by_name(:push_event_payloads, :push_event_payloads_events_id_new_idx)
      remove_concurrent_index_by_name(:events, :events_id_new_idx)
    end
  end
end
