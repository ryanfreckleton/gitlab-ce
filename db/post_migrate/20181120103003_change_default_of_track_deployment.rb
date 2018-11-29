# frozen_string_literal: true

class ChangeDefaultOfTrackDeployment < ActiveRecord::Migration
  DOWNTIME = false

  STABLE_TRACK = 0

  def up
    change_column_default(:deployments, :track, nil)
  end

  def down
    change_column_default(:deployments, :track, STABLE_TRACK)
  end
end
