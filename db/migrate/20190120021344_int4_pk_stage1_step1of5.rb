# frozen_string_literal: true

class Int4PkStage1Step1of5 < ActiveRecord::Migration[5.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    if Gitlab::Database.postgresql?
      add_column(:events, :id_new, :bigint)
      install_rename_triggers_for_postgresql(:_int4_to_int8, :events, :id, :id_new, 'INSERT')

      execute <<-SQL.strip_heredoc
        do $do$
        begin
          execute format(
            $sql$ alter database %I set int4_to_int8.events.id = '%s'; $sql$,
            current_database(),
            (select id from events where id_new is null order by id desc limit 1)
          );
        end;
        $do$ language plpgsql;
      SQL

      #execute "alter table public.events set (autovacuum_enabled = false);"
    end
  end

  def down
    if Gitlab::Database.postgresql?
      execute <<-SQL.strip_heredoc
        do $$
        begin
          execute format(
            e'alter database %I reset int4_to_int8.events.id;',
            current_database()
          );
        end;
        $$ language plpgsql;
      SQL

      remove_rename_triggers_for_postgresql(:events, :_int4_to_int8)
      remove_column(:events, :id_new)
    end
  end
end
