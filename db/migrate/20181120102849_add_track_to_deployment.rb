# frozen_string_literal: true

class AddTrackToDeployment < ActiveRecord::Migration
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  STABLE_TRACK = 0

  def up
    add_column_with_default(:deployments, :track, :integer,
      limit: 2, default: STABLE_TRACK)
  end

  def down
    remove_column(:deployments, :track)
  end
end
