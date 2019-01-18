# frozen_string_literal: true

module Clusters
  module Applications
    class UpdateService < BaseHelmService
      def execute
        return if app.updating?

        begin
          app.make_updating!
          helm_api.update(upgrade_command)

          ::ClusterWaitForAppUpdateWorker.perform_in(::ClusterWaitForAppUpdateWorker::INTERVAL, app.name, app.id)
        rescue Kubeclient::HttpError => e
          log_error(e)
          app.make_update_errored!("Kubernetes error: #{e.error_code}")
        rescue StandardError => e
          log_error(e)
          app.make_update_errored!("Can't start installation process.")
        end
      end
    end
  end
end
