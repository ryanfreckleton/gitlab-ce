# frozen_string_literal: true


class Int4PkStage1Step3of5 < ActiveRecord::Migration[5.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up

    if Gitlab::Database.postgresql?
      # Process existing rows (~300M for GitLab.com) in batches
      # If it fails, this step can be repeated again, the processing will
      # automatically continue from the position where it failed.
      # Total time estimate for GitLab.com: ~11.5 hours
      int4_to_int8_copy("events", "id", "id_new")

      #
      int4_to_int8_copy("push_event_payloads", "event_id", "event_id_new")
    end
  end

  def down
    # nothing
  end
end
