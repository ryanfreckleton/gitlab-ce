# frozen_string_literal: true

class Int4PkStage1Step4of5 < ActiveRecord::Migration[5.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    if Gitlab::Database.postgresql?
      add_concurrent_check_constraint(:events, :id_new_not_null, 'id_new is not null)')
      add_concurrent_check_constraint(:push_event_payloads, :event_id_new_not_null, 'event_id_new is not null)')
    end
  end

  def down
    if Gitlab::Database.postgresql?
      execute <<-SQL.strip_heredoc
        alter table push_event_payloads drop constraint if exists event_id_new_not_null;
        alter table events drop constraint if exists id_new_not_null;
      SQL
    end
  end
end
