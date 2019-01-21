# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::Ci::Parsers::BuildAnnotation do
  let(:parser) { described_class.new }

  describe '#parse!' do
    context 'when the annotations artifact is too large' do
      it 'raises a ParserError' do
        artifact = double(:artifact, job_id: 1, size: 20.megabytes)

        expect { parser.parse!(artifact) }
          .to raise_error(described_class::ParserError)
      end
    end

    context 'when the annotations artifact is small enough' do
      it 'parses the JSON and returns the build annotations' do
        json = JSON.dump([
          {
            'severity' => 'info',
            'summary' => 'summary here',
            'description' => 'description here',
            'line_number' => 14,
            'file_path' => 'README.md'
          }
        ])

        artifact = double(:artifact, job_id: 1, size: 4)

        allow(artifact)
          .to receive(:each_blob)
          .and_yield(json)

        annotations = parser.parse!(artifact)

        expect(annotations).to eq([
          {
            build_id: 1,
            severity: Ci::BuildAnnotation.severities[:info],
            summary: 'summary here',
            description: 'description here',
            line_number: 14,
            file_path: 'README.md'
          }
        ])
      end
    end
  end

  describe '#parse_json' do
    context 'when the JSON object contains too many nested objects' do
      it 'raises a ParserError' do
        json = JSON.dump([[[[[[{}]]]]]])

        expect { parser.parse_json(json) }
          .to raise_error(described_class::ParserError)
      end
    end

    context 'when the JSON contains too many entries' do
      it 'raises a ParserError' do
        json = JSON.dump(Array.new(described_class::MAX_ENTRIES + 1) { {} })

        expect { parser.parse_json(json) }
          .to raise_error(described_class::ParserError)
      end
    end

    context 'when the JSON is valid' do
      it 'returns the annotations' do
        json = JSON.dump([{}])

        expect(parser.parse_json(json)).to eq([{}])
      end
    end
  end

  describe '#build_annotation_rows' do
    context 'when one of the entries is not a JSON object' do
      it 'raises a ParserError' do
        artifact = double(:artifact)

        expect { parser.build_annotation_rows(artifact, [10]) }
          .to raise_error(described_class::ParserError)
      end
    end

    context 'when one of the JSON objects is invalid' do
      it 'raises a ParserError' do
        artifact = double(:artifact, job_id: 1)

        expect { parser.build_annotation_rows(artifact, [{}]) }
          .to raise_error(described_class::ParserError)
      end
    end

    context 'when the JSON objects are valid' do
      it 'returns the database attributes' do
        artifact = double(:artifact, job_id: 1)
        annotations = [
          {
            'severity' => 'info',
            'summary' => 'summary here',
            'description' => 'description here',
            'line_number' => 14,
            'file_path' => 'README.md'
          }
        ]

        attributes = parser.build_annotation_rows(artifact, annotations)

        expect(attributes).to eq([
          {
            build_id: 1,
            severity: Ci::BuildAnnotation.severities[:info],
            summary: 'summary here',
            description: 'description here',
            line_number: 14,
            file_path: 'README.md'
          }
        ])
      end
    end
  end

  describe '#validate_database_attributes!' do
    context 'when the attributes are invalid' do
      it 'raises a ParserError' do
        annotation = {
          'severity' => 'info',
          'summary' => 'summary here',
          'description' => 'description here',
          'line_number' => 14
        }

        attributes = {
          build_id: 1,
          severity: Ci::BuildAnnotation.severities[:info],
          summary: 'summary here',
          description: 'description here',
          line_number: 14
        }

        expect { parser.validate_database_attributes!(annotation, attributes) }
          .to raise_error(described_class::ParserError)
      end
    end

    context 'when the attributes are valid' do
      it 'returns nil' do
        annotation = {
          'severity' => 'info',
          'summary' => 'summary here',
          'description' => 'description here'
        }

        attributes = {
          build_id: 1,
          severity: Ci::BuildAnnotation.severities[:info],
          summary: 'summary here',
          description: 'description here'
        }

        expect(parser.validate_database_attributes!(annotation, attributes))
          .to be_nil
      end
    end

    it 'does not execute any SQL queries' do
      annotation = {
        'severity' => 'info',
        'summary' => 'summary here',
        'description' => 'description here',
        'line_number' => 14,
        'file_path' => 'README.md'
      }

      attributes = {
        build_id: 1,
        severity: Ci::BuildAnnotation.severities[:info],
        summary: 'summary here',
        description: 'description here',
        line_number: 14,
        file_path: 'README.md'
      }

      # It's possible that in a rare case this test is the very first test to
      # run. This means the schema for `Ci::BuildAnnotation` might not be loaded
      # yet, which would cause the below assertion to fail.
      #
      # To prevent this from happening, we ensure the schema is always present
      # before testing the number of queries executed during validation.
      Ci::BuildAnnotation.columns

      queries = ActiveRecord::QueryRecorder
        .new { parser.validate_database_attributes!(annotation, attributes) }
        .count

      expect(queries).to be_zero
    end
  end

  describe '#parser_error!' do
    it 'raises a ParserError' do
      expect { parser.parser_error!({}, 'foo') }.to raise_error(
        described_class::ParserError,
        'The annotation {} is invalid: foo'
      )
    end
  end
end
