# frozen_string_literal: true

module Clusters
  module Applications
    class InstallService < BaseHelmService
      INTERVAL = 10.seconds

      def execute
        return unless app.scheduled?

        begin
          app.make_installing!
          helm_api.install(install_command)

          ClusterWaitForAppInstallationWorker.perform_in(
            INTERVAL, app.name, app.id)
        rescue Kubeclient::HttpError => e
          log_error(e)
          app.make_errored!("Kubernetes error: #{e.error_code}")
        rescue StandardError => e
          log_error(e)
          app.make_errored!("Can't start installation process.")
        end
      end
    end
  end
end
