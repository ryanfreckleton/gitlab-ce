# frozen_string_literal: true

module Gitlab
  module Ci
    module Pipeline
      module Seed
        class Stage < Seed::Base
          include Gitlab::Utils::StrongMemoize

          attr_reader :pipeline, :options

          delegate :size, to: :seeds
          delegate :dig, to: :seeds

          Options = Struct.new(:name, :index, :builds)

          def initialize(pipeline, options_hash)
            @pipeline = pipeline
            @options = Options.new

            options_hash.to_h.each do |key, value|
              @options[key] = value
            end
          end

          def builds
            strong_memoize(:builds) do
              options.builds.map do |attributes|
                Seed::Build.new(@pipeline, attributes.merge(
                  stage: options.name, stage_index: options.index))
              end
            end
          end

          def attributes
            { name: @options.name,
              position: @options.index,
              pipeline: @pipeline,
              project: @pipeline.project }
          end

          def seeds
            strong_memoize(:seeds) do
              builds.select(&:included?)
            end
          end

          def included?
            seeds.any?
          end

          def to_resource
            strong_memoize(:stage) do
              ::Ci::Stage.new(attributes).tap do |stage|
                seeds.each { |seed| stage.builds << seed.to_resource }
              end
            end
          end
        end
      end
    end
  end
end
