# frozen_string_literal: true

module Gitlab
  module Ci
    module Pipeline
      module Seed
        class Build < Seed::Base
          include Gitlab::Utils::StrongMemoize

          attr_reader :pipeline, :options

          delegate :dig, to: :options

          Options = Struct.new(
            :name,
            :stage, :stage_index,
            :ref, :tags,
            :only, :except,
            :commands, # legacy field
            :before_script, :script, :after_script,
            :when, :allow_failure, :coverage_regex,
            :environment, :variables,
            :image, :services,
            :artifacts, :cache, :dependencies,
            :retry, :parallel, :instance, :start_in)

          def initialize(pipeline, options_hash)
            @pipeline = pipeline
            @options = Options.new

            options_hash.to_h.each do |key, value|
              @options[key] = value
            end
          end

          def only
            strong_memoize(:only) do
              Gitlab::Ci::Build::Policy
                .fabricate(options.only)
            end
          end

          def except
            strong_memoize(:except) do
              Gitlab::Ci::Build::Policy
                .fabricate(options.except)
            end
          end

          def included?
            strong_memoize(:inclusion) do
              only.all? { |spec| spec.satisfied_by?(pipeline, self) } &&
                except.none? { |spec| spec.satisfied_by?(pipeline, self) }
            end
          end

          def attributes
            pipeline_attributes.merge(options_attributes).compact
          end

          def to_resource
            strong_memoize(:resource) do
              ::Ci::Build.new(attributes)
            end
          end

          private

          def pipeline_attributes
            {
              pipeline: pipeline,
              project: pipeline.project,
              user: pipeline.user,
              ref: pipeline.ref,
              tag: pipeline.tag,
              trigger_request: pipeline.legacy_trigger,
              protected: pipeline.protected_ref?
            }
          end

          def options_attributes
            {
              name: options.name,
              stage_idx: options.stage || 0,
              commands: options.commands,
              tag_list: options.tags || [],
              allow_failure: options.allow_failure,
              when: options.when || 'on_success',
              environment: options.dig(:environment, :name),
              coverage_regex: options.coverage_regex,
              yaml_variables: variables_attributes,
              options: {
                image: options.image,
                services: options.services,
                artifacts: options.artifacts,
                cache: options.cache,
                dependencies: options.dependencies,
                before_script: options.before_script,
                script: options.script,
                after_script: options.after_script,
                environment: options.environment,
                retry: options.retry,
                parallel: options.parallel,
                instance: options.instance,
                start_in: options.start_in
              }.compact
            }
          end

          def variables_attributes
            return unless options.variables

            options.variables.map do |key, value|
              { key: key.to_s, value: value, public: true }
            end
          end
        end
      end
    end
  end
end
