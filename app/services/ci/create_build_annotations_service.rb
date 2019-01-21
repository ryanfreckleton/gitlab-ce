# frozen_string_literal: true

module Ci
  # Parses and stores the build annotations of a single CI build.
  class CreateBuildAnnotationsService
    attr_reader :build

    # @param [Ci::Build] build
    def initialize(build)
      @build = build
    end

    def execute
      artifact = build.first_build_annotation_artifact

      return unless artifact

      annotations = parse_annotations(artifact)

      insert_annotations(annotations) if annotations.any?
    end

    # @param [Ci::JobArtifact] artifact
    def parse_annotations(artifact)
      Gitlab::Ci::Parsers.fabricate!(:build_annotation).parse!(artifact)
    rescue Gitlab::Ci::Parsers::BuildAnnotation::ParserError => error
      build_error_annotation(error.message)
    end

    # @param [Array<Hash>] rows
    def insert_annotations(rows)
      Gitlab::Database.bulk_insert(::Ci::BuildAnnotation.table_name, rows)
    end

    # @param [String] message
    def build_error_annotation(message)
      [
        {
          build_id: build.id,
          severity: Ci::BuildAnnotation.severities[:error],
          summary: message
        }
      ]
    end
  end
end
