# frozen_string_literal: true

require 'spec_helper'

describe Ci::CreateBuildAnnotationsService do
  describe '#execute' do
    let(:ci_build) { create(:ci_build) }
    let(:service) { described_class.new(ci_build) }

    context 'when there is no annotations artifact' do
      it 'does nothing' do
        service.execute

        expect(Ci::BuildAnnotation.count).to be_zero
      end
    end

    context 'when there is an annotation artifact' do
      it 'imports the artifact' do
        artifact = double(:artifact, job_id: ci_build.id, size: 1)
        json = JSON.dump([{ severity: 'warning', summary: 'hello' }])

        allow(artifact)
          .to receive(:each_blob)
          .and_yield(json)

        allow(ci_build)
          .to receive(:first_build_annotation_artifact)
          .and_return(artifact)

        service.execute

        expect(Ci::BuildAnnotation.count).to eq(1)
      end
    end
  end

  describe '#parse_annotations' do
    let(:service) { described_class.new(double(:build, id: 1)) }

    context 'when the annotations are valid' do
      it 'returns the database rows to insert' do
        artifact = double(:artifact, job_id: 1, size: 1)
        json = JSON.dump([{ severity: 'warning', summary: 'hello' }])

        allow(artifact)
          .to receive(:each_blob)
          .and_yield(json)

        expect(service.parse_annotations(artifact)).to eq([
          {
            build_id: 1,
            severity: Ci::BuildAnnotation.severities[:warning],
            summary: 'hello',
            description: nil,
            line_number: nil,
            file_path: nil
          }
        ])
      end
    end

    context 'when the annotations are not valid' do
      it 'returns an error row to insert' do
        artifact = double(:artifact, job_id: 1, size: 1)
        json = JSON.dump([{ summary: 'hello' }])

        allow(artifact)
          .to receive(:each_blob)
          .and_yield(json)

        annotations = service.parse_annotations(artifact)

        expect(annotations.length).to eq(1)

        expect(annotations[0][:severity])
          .to eq(Ci::BuildAnnotation.severities[:error])

        expect(annotations[0][:summary]).to be_an_instance_of(String)
      end
    end
  end

  describe '#insert_annotations' do
    it 'inserts the build annotations into the database' do
      build = create(:ci_build)
      row = {
        build_id: build.id,
        severity: Ci::BuildAnnotation.severities[:warning],
        summary: 'hello',
        description: nil,
        line_number: nil,
        file_path: nil
      }

      service = described_class.new(build)

      service.insert_annotations([row])

      expect(Ci::BuildAnnotation.count).to eq(1)
    end
  end

  describe '#build_error_annotation' do
    it 'returns an annotation to use when an error was produced' do
      build = create(:ci_build)
      service = described_class.new(build)

      expect(service.build_error_annotation('foo')).to eq([
        {
          build_id: build.id,
          severity: Ci::BuildAnnotation.severities[:error],
          summary: 'foo'
        }
      ])
    end
  end
end
