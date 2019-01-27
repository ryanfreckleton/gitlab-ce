# frozen_string_literal: true


class Int4PkStage1Step3of5 < ActiveRecord::Migration[5.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    upper_boarder = connection.select_value("select current_setting('int4_to_int8.events.id')")

    if Gitlab::Database.postgresql?
      # Process existing rowsi (~300M for GitLab.com) in batches
      # If it fails, this step can be repeated again, the processing will
      # automatically continue from the position where it failed.
      # Total time estimate for GitLab.com: ~33 hours
      int4_to_int8_copy("events", "id", "id_new", upper_boarder)
    end
  end

  def down
    # nothing
  end
end
