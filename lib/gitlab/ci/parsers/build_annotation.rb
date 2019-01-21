# frozen_string_literal: true

module Gitlab
  module Ci
    module Parsers
      # Parsing of CI build annotation artifacts.
      #
      # This class parses a CI build annotations artifact file, and inserts
      # valid entries into the database.
      class BuildAnnotation
        ParserError = Class.new(Parsers::ParserError)

        # The maximum nesting level to allow when parsing JSON.
        #
        # This value is deliberately set to a low value, as valid annotation
        # files won't use deeply nested structures.
        MAX_JSON_NESTING = 5

        # The maximum number of annotations a single artifact is allowed to
        # produce.
        #
        # This limit exists to prevent users from creating tens of thousands
        # very small entries, which could still have a negative impact on
        # performance and availability.
        MAX_ENTRIES = 1_000

        # The maximum allowed size of an artifacts file.
        MAXIMUM_SIZE = 10.megabytes

        # Parses an annotations file in JSON format, returning database rows to
        # insert.
        #
        # The returned rows are validated and can thus be inserted straight into
        # a database table.
        #
        # @param [Ci::JobArtifact] artifact The CI artifact to parse.
        # @return [Array<Hash>]
        def parse!(artifact)
          if artifact.size > MAX_ENTRIES
            raise(
              ParserError,
              _(
                'Build annotation artifacts can not be greater than %{bytes} bytes'
              ) % { bytes: MAXIMUM_SIZE }
            )
          end

          entries = []

          artifact.each_blob do |json|
            entries.concat(parse_json(json))
          end

          build_annotation_rows(artifact, entries)
        end

        # @param [String] json
        # @return [Array<Hash>]
        def parse_json(json)
          begin
            entries = JSON.parse(json, max_nesting: MAX_JSON_NESTING)
          rescue JSON::NestingError
            raise(
              ParserError,
              _('The annotations artifact has too many nested objects')
            )
          end

          if entries.length > MAX_ENTRIES
            raise(
              ParserError,
              _('Only up to %{maximum} annotations are allowed per build') % {
                maximum: MAX_ENTRIES
              }
            )
          end

          entries
        end

        # @param [Ci::JobArtifact] artifact
        # @param [Hash] annotations
        # @return [Array<Hash>]
        def build_annotation_rows(artifact, annotations)
          annotations.map do |annotation|
            unless annotation.is_a?(Hash)
              parser_error!(
                annotation,
                _('each annotation must be a JSON object')
              )
            end

            attributes = {
              build_id: artifact.job_id,
              severity: ::Ci::BuildAnnotation.severities[annotation['severity']],
              summary: annotation['summary'],
              description: annotation['description'],
              line_number: annotation['line_number'],
              file_path: annotation['file_path']
            }

            validate_database_attributes!(annotation, attributes)

            # We do not return the model attributes as they may include
            # additional columns without the right values, such as the `id`
            # column (which will default to `nil`).
            attributes
          end
        end

        # @param [Hash] annotation
        # @param [Hash] attributes
        def validate_database_attributes!(annotation, attributes)
          model = ::Ci::BuildAnnotation.new(attributes)

          return if model.valid?

          parser_error!(annotation, model.errors.full_messages.join(', '))
        end

        # @param [#inspect] annotation
        # @param [String] error
        def parser_error!(annotation, error)
          formatted_error =
            _('The annotation %{annotation} is invalid: %{error}') % {
              annotation: annotation.inspect,
              error: error
            }

          raise ParserError, formatted_error
        end
      end
    end
  end
end
