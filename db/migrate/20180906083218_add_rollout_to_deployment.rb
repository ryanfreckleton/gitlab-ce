# frozen_string_literal: true

class AddRolloutToDeployment < ActiveRecord::Migration
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  ROLLOUT_PERCENTAGE = 100

  def up
    add_column_with_default(:deployments, :rollout, :integer,
      limit: 2, default: ROLLOUT_PERCENTAGE)
  end

  def down
    remove_column(:deployments, :rollout)
  end
end
