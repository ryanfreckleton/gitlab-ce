# frozen_string_literal: true

module Gitlab
  module Ci
    class Config
      module Entry
        ##
        # This class represents a global entry - root Entry for entire
        # GitLab CI Configuration file.
        #
        class Root < ::Gitlab::Config::Entry::Node
          include ::Gitlab::Config::Entry::Configurable

          entry :global, Entry::Global,
            description: 'Global configuration.',
            default: {}

          entry :before_script, Entry::Script,
            description: 'Script that will be executed before each job.'

          entry :image, Entry::Image,
            description: 'Docker image that will be used to execute jobs.'

          entry :services, Entry::Services,
            description: 'Docker images that will be linked to the container.'

          entry :after_script, Entry::Script,
            description: 'Script that will be executed after each job.'

          entry :variables, Entry::Variables,
            description: 'Environment variables that will be used.'

          entry :stages, Entry::Stages,
            description: 'Configuration of stages for this pipeline.'

          entry :types, Entry::Stages,
            description: 'Deprecated: stages for this pipeline.'

          entry :cache, Entry::Cache,
            description: 'Configure caching between build jobs.'

          helpers :global, :jobs

          def initialize(config, **metadata)
            super

            # Rewrite config hash
            # to split it into a hash of `jobs`: the @jobs_config
            # to split it into a hash of `non-jobs`: the @config
            if @config.is_a?(Hash)
              @jobs_config = @config.select { |key, hash| a_job?(hash) }
              @config = @config.except(*@jobs_config.keys)
            end
          end

          def compose!(_deps = nil)
            super(self) do
              compose_jobs!
            end
          end

          private

          # rubocop: disable CodeReuse/ActiveRecord
          def compose_jobs!
            factory = ::Gitlab::Config::Entry::Factory.new(Entry::Jobs)
              .value(@jobs_config)
              .with(key: :jobs, parent: self,
                    description: 'Jobs definition for this pipeline')

            @entries[:jobs] = factory.create!
          end
          # rubocop: enable CodeReuse/ActiveRecord

          def a_job?(hash)
            hash.is_a?(Hash) && hash[:script].present?
          end
        end
      end
    end
  end
end
