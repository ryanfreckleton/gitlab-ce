# frozen_string_literal: true

class Int4PkStage1Step1of5 < ActiveRecord::Migration[5.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    if Gitlab::Database.postgresql?
      add_column(:events, :id_new, :bigint)
      install_rename_triggers_for_postgresql(:_int4_to_int8, :events, :id, :id_new, 'INSERT')
      execute <<-SQL.strip_heredoc
        do $$
        begin
          execute format(
            e'alter database %I set int4_to_int8.events.id = \'%s\';',
            current_database(),
            (select id from events where id_new is null order by id desc limit 1)
          );
        end;
        $$ language plpgsql;
      SQL

      execute <<-SQL.strip_heredoc
        alter table public.events set (autovacuum_enabled = false);
      SQL
    end
  end

  def down
    if Gitlab::Database.postgresql?
      remove_rename_triggers_for_postgresql(:events, :_int4_to_int8)
      remove_column(:events, :id_new)
    end
  end
end
