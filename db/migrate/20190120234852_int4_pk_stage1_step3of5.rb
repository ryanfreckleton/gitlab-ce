# frozen_string_literal: true


class Int4PkStage1Step3of5 < ActiveRecord::Migration[5.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    if Gitlab::Database.postgresql?
      int4_to_int8_copy("events", "id", "id_new")
    end
  end

  def down
    # nothing
  end
end
