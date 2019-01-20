# frozen_string_literal: true

class Int4PkStage1Step1 < ActiveRecord::Migration[5.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def remove_rename_triggers_for_postgresql(table)
    execute("drop trigger if exists #{trigger} on #{table}")
    execute("drop function if exists #{trigger}()")
  end

  def up
    add_column :events, :id_new, :bigint
    if Gitlab::Database.postgresql?
      install_rename_triggers_for_postgresql(:_int4_to_int8, :events, :id, :id_new, 'INSERT')
    end

    execute <<-SQL.strip_heredoc
      alter table public.events set (autovacuum_enabled = false);
    SQL
  end

  def down
    if Gitlab::Database.postgresql?
      remove_rename_triggers_for_postgresql(:events, :_int4_to_int8)
    end
    remove_column :events, :id_new
  end
end
