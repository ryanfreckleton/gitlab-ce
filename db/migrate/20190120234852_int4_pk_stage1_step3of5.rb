# frozen_string_literal: true


class Int4PkStage1Step3of5 < ActiveRecord::Migration[5.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    if Gitlab::Database.postgresql?
      # Process existing rowsin batches.
      # If it fails, it is OK to re-run this migration. The processing will
      # automatically continue from the position where it failed.

      # Once this migration successfully finished, there are no NULL values
      # in there "new" columns.

      # GitLab.com: ~300M rows, ~11.5 hours of processing
      int4_to_int8_copy("events", "id", "id_new")

      # GitLab.com: ~210M rows, ~9 hours of processing
      int4_to_int8_copy("push_event_payloads", "event_id", "event_id_new")
    end
  end

  def down
    # nothing here
  end
end
