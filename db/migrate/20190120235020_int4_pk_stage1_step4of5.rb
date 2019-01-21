# frozen_string_literal: true

class Int4PkStage1Step4of5 < ActiveRecord::Migration[5.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    if Gitlab::Database.postgresql?
      execute <<-SQL.strip_heredoc
        alter table events add constraint id_new_not_null check (id_new is not null) not valid;
        alter table events validate constraint id_new_not_null; -- long
      SQL
    end
  end

  def down
    if Gitlab::Database.postgresql?
      execute <<-SQL.strip_heredoc
        alter table events drop constraint id_new_not_null;
      SQL
    end
  end
end
