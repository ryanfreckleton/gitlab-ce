# frozen_string_literal: true

module Clusters
  module Applications
    class CheckInstallationProgressService < BaseHelmService
      INTERVAL = 10.seconds
      TIMEOUT = 20.minutes

      def execute
        return unless app.installing?

        case phase
        when Gitlab::Kubernetes::Pod::SUCCEEDED
          on_success
        when Gitlab::Kubernetes::Pod::FAILED
          on_failed
        else
          check_timeout
        end
      rescue Kubeclient::HttpError => e
        log_error(e)
        app.make_errored!("Kubernetes error: #{e.error_code}") unless app.errored?
      end

      def pod_name
        install_command.pod_name
      end

      private

      def on_success
        app.make_installed!
      ensure
        remove_pod
      end

      def on_failed
        app.make_errored!("Installation failed. Check pod logs for #{pod_name} for more details.")
      end

      def check_timeout
        if timeouted?
          app.make_errored!("Installation timed out. Check pod logs for #{pod_name} for more details.")
        else
          ClusterWaitForAppInstallationWorker.perform_in(
            INTERVAL, app.name, app.id)
        end
      end

      def timeouted?
        Time.now.utc - app.updated_at.to_time.utc > TIMEOUT
      end

      def remove_pod
        helm_api.delete_pod!(pod_name)
      end

      def phase
        helm_api.status(pod_name)
      end
    end
  end
end
