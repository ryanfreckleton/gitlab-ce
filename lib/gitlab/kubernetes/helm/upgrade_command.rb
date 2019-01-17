# frozen_string_literal: true

module Gitlab
  module Kubernetes
    module Helm
      class UpgradeCommand
        include BaseCommand
        include ClientCommand

        attr_reader :name, :chart, :version, :repository, :files

        def initialize(name, chart:, files:, rbac:, version: nil, repository: nil)
          @name = name
          @chart = chart
          @rbac = rbac
          @version = version
          @files = files
          @repository = repository
        end

        def generate_script
          super + [
            init_command,
            wait_for_tiller_command,
            repository_command,
            upgrade_command
          ].compact.join("\n")
        end

        def rbac?
          @rbac
        end

        def pod_name
          "upgrade-#{name}"
        end

        private

        def upgrade_command
          command = ["helm", "upgrade", name, chart] + helm_upgrade_flags

          command.shelljoin
        end

        def helm_upgrade_flags
          reset_values_flag = ['--reset-values']
          install_flag = ['--install']
          namespace_flag = ['--namespace', Gitlab::Kubernetes::Helm::NAMESPACE]
          value_flag     = ['-f', "/data/helm/#{name}/config/values.yaml"]

          optional_version_flag +
            optional_tls_flags +
            reset_values_flag +
            install_flag +
            namespace_flag +
            value_flag
        end

        def optional_version_flag
          return [] unless version

          ['--version', version]
        end

        def optional_tls_flags
          return [] unless files.key?(:'ca.pem')

          [
            '--tls',
            '--tls-ca-cert', "#{files_dir}/ca.pem",
            '--tls-cert', "#{files_dir}/cert.pem",
            '--tls-key', "#{files_dir}/key.pem"
          ]
        end
      end
    end
  end
end
