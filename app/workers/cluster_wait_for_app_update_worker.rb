# frozen_string_literal: true

class ClusterWaitForAppUpdateWorker
  include ApplicationWorker
  include ClusterQueue
  include ClusterApplications

  def perform(app_name, app_id)
    find_application(app_name, app_id) do |app|
      ::Clusters::Applications::CheckUpgradeProgressService.new(app).execute
    end
  end
end
