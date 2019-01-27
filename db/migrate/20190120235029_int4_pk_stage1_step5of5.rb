# frozen_string_literal: true

class Int4PkStage1Step5of5 < ActiveRecord::Migration[5.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    if Gitlab::Database.postgresql?
      execute <<-SQL.strip_heredoc
        alter table push_event_payloads add constraint fk_36c74129da_new
          foreign key (event_id) references events(id_new) not valid; -- ON DELETE CASCADE
        alter table push_event_payloads validate constraint fk_36c74129da_new; -- long
        alter table push_event_payloads drop constraint fk_36c74129da;
        alter table push_event_payloads rename constraint fk_36c74129da_new to fk_36c74129da;
      SQL

      execute <<-SQL.strip_heredoc
        alter table events drop constraint events_pkey;
        alter table events add constraint events_pkey_new
          primary key using index events_id_new_idx;
        alter index events_pkey_new rename to events_pkey;
        alter table events drop constraint id_new_not_null;
      SQL

      execute <<-SQL.strip_heredoc
        alter table events rename id to id_old;
        alter table events rename id_new to id;
        alter table events alter column id set default nextval('events_id_seq');
        alter sequence events_id_seq owned by events.id;
      SQL

      #execute "alter table public.events set (autovacuum_enabled = false);"

      remove_rename_triggers_for_postgresql(:events, :_int4_to_int8)
      remove_column :events, :id_old

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
    end
  end

  def down
    if Gitlab::Database.postgresql?
      change_column(:events, :id, :integer, :limit => 4) # TODO: improve this
      add_column(:events, :id_new, :bigint)
      install_rename_triggers_for_postgresql(:_int4_to_int8, :events, :id, :id_new, 'INSERT')

      execute <<-SQL.strip_heredoc
        alter table events add constraint id_new_not_null check (id_new is not null) not valid;
        alter table events validate constraint id_new_not_null; -- long
        alter table public.events set (autovacuum_enabled = false);
      SQL
      add_index(:events, :id_new, unique: true, name: :events_id_new_idx)
    end
  end
end
