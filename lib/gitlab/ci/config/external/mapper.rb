# frozen_string_literal: true

module Gitlab
  module Ci
    class Config
      module External
        class Mapper
          include Gitlab::Utils::StrongMemoize

          MAX_DEPTH = 3

          FILE_CLASSES = [
            External::File::Remote,
            External::File::Template,
            External::File::Local,
            External::File::Project
          ].freeze

          Error = Class.new(StandardError)
          AmbigiousSpecificationError = Class.new(Error)
          TooManyIncludes = Class.new(Error)

          def initialize(values, project:, sha:, user:, depth: 0)
            @locations = Array.wrap(values.fetch(:include, []))
            @project = project
            @sha = sha
            @user = user
            @depth = depth.to_i
          end

          def process
            return [] if locations.empty?

            if @depth >= MAX_DEPTH
              raise TooManyIncludes, "You can nest at most #{MAX_DEPTH} includes"
            end

            locations
              .compact
              .map(&method(:normalize_location))
              .map(&method(:select_first_matching))
          end

          private

          attr_reader :locations, :project, :sha, :user, :depth

          # convert location if String to canonical form
          def normalize_location(location)
            if location.is_a?(String)
              normalize_location_string(location)
            else
              location.deep_symbolize_keys
            end
          end

          def normalize_location_string(location)
            if ::Gitlab::UrlSanitizer.valid?(location)
              { remote: location }
            else
              { local: location }
            end
          end

          def select_first_matching(location)
            matching = FILE_CLASSES.map do |file_class|
              file_class.new(location, context)
            end.select(&:matching?)

            raise AmbigiousSpecificationError, "Include `#{location.to_json}` needs to match exactly one accessor!" unless matching.one?

            matching.first
          end

          def context
            strong_memoize(:context) do
              External::File::Base::Context.new(project, sha, user, depth)
            end
          end
        end
      end
    end
  end
end
